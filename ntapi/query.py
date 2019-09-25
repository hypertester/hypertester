from utils import *

class query:
    ## outputs
    ingress_queries = []
    egress_queries = []
    filters = []
    distinct_queries = []

    ## global counter
    qid  = 0 # 0 for None

    ## definitions
    P4_LOG_OPS = ["==", "!=", "<", ">", "<=", ">="]
    def __init__(self, *args, **kwargs):
        self.qrycb = emptyclass()
        
        if "tid" in kwargs and kwargs["tid"] != 0:
            query.egress_queries.append(self.qrycb)
        else:
            query.ingress_queries.append(self.qrycb)

        query.qid += 1
        self.qrycb.id = query.qid

        self.qrycb.name = generate_uid("query")
        self.qrycb.primitives = []
        self.prev_primitive = None
    def __repr__(self):
        pass
    def filter(self, *args):
        fl = self.init_primitive("FILTER")
        fl.predicate = emptyclass()
        fl.predicate.left, fl.predicate.op, fl.predicate.right = args
        if fl.predicate.op not in query.P4_LOG_OPS:
            raise HTQueryError("op in query filter can only be: " + repr(query.P4_LOG_OPS))
        query.filters.append(fl)
        return self
    def map(self):
        #TODO 
        pass
    def distinct(self, keys):
        dstnct = self.init_primitive("DISTINCT")
        dstnct.key_fields = []
        for k in keys:
            key = emptyclass()
            if k not in HEADER_FIELDS.keys():
                raise HTQueryError("cannot recognize filed "+ k +" in query distinct.")
            key.p4 = k
            dstnct.key_fields.append(key)
        #TODO: all false positive enties: fps = [fp, ...];
        #      a combination of all keys: fp.values = [v, ...];
        #      v = value of a single field
        dstnct.fps = [] #calc_hash_collision()
        dstnct.conflict_num = len(dstnct.fps)
        query.distinct_queries.append(dstnct)
        return self
    def reduce(self, keys, func='sum'):
        #TODO: parameter func now makes no sense
        rdc = self.init_primitive("REDUCE")
        rdc.key_fields = []
        for k in keys:
            key = emptyclass()
            if k not in HEADER_FIELDS.keys():
                raise HTQueryError("cannot recognize filed "+ k +" in query reduce.")
            key.p4 = k
            rdc.key_fields.append(key)
        rdc.fps = [] #calc_hash_collision()
        rdc.conflict_num = len(dstnct.fps)
        query.reduce_queries.append(rdc)
        return self
    def init_primitive(self, ptype):
        prmtv = emptyclass()
        prmtv.prev = self.prev_primitive
        self.prev_primitive = prmtv
        prmtv.type = ptype
        prmtv.name = generate_uid(ptype.lower())
        self.qrycb.primitives.append(prmtv)
        return prmtv

if __name__ == "__main__":
    q = query().filter(1, '<', 3).distinct( keys=('ipv4.dst_addr', 'ipv4.src_addr', 'ipv4.total_len') )
    q = query().filter(1, '<', 3).distinct(('ipv4.src_addr', 'tcp.dst_port'))
    print(query.ingress_queries)

