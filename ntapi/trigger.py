from utils import *

RPLC_TYPE_FULL_SPEED = "FULL_SPEED"
RPLC_TYPE_CONSTANT_RATE = "CONSTANT_RATE"
RPLC_TYPE_RANDOM_RATE = "RANDOM_RATE"

class trigger:
    ## outputs
    tmpl_pkts = {} # tmpl_id->list[tuple(key,value), ...]
    replicators = {} # (unique identifier)->(replicator data structure)
    editors = {}   # (unique identifier)->(editor data structure)
    ## global counter
    tmpl_id = 0
    ## definations
    #CTRL_FIELDS = set(["pktlen", "interval", "port", "loop"]) # +qid +postpone??

    def __init__(self, *args, **kwargs):
        self.tmpl_id = trigger.tmpl_id
        trigger.tmpl_id += 1
        self.tmpl_pkt = {}
        trigger.tmpl_pkts[self.tmpl_id] = self.tmpl_pkt

        #control fields
        self.tmpl_pkt["qid"] = 0 # 0 for None
        if "qid" in kwargs:
            self.set_qid(kwargs["qid"])

        self.tmpl_pkt["postpone"] = 0 # no delay
        if "postpone" in kwargs:
            self.set_postpone(kwargs["postpone"])

        self.tmpl_pkt["pktlen"] = 64
        if "pktlen" in kwargs:
            self.set_pktlen(kwargs["pktlen"])

        if "port" in kwargs:
            self.set_output_port(kwargs["port"]) # configure multicast engine
        self.multicast_grp = 0

        if "interval" in kwargs:
            self.set_interval(kwargs["interval"])
        else:
            self.set_interval(HTValue("CONSTANT", 0)) # Full Speed

        if "loop" in kwargs:
            pass

    def __repr__(self):
        pass

    def set_qid(self, htval):
        if not isinstance(htval, HTValue):
            raise HTTriggerError("set value must have a type of HTValue.")
        if htval.type != "CONSTANT":
            raise HTTriggerError("qid must have a type of CONSTANT")
        self.tmpl_pkt["qid"] = htval.value

    def set_postpone(self, htval):
        if not isinstance(htval, HTValue):
            raise HTTriggerError("set value must have a type of HTValue.")
        if htval.type != "CONSTANT":
            raise HTTriggerError("postpone must have a type of CONSTANT")
        self.tmpl_pkt["postpone"] = htval.value

    def set_pktlen(self, htval):
        if not isinstance(htval, HTValue):
            raise HTTriggerError("set value must have a type of HTValue.")
        if htval.type != "CONSTANT":
            raise HTTriggerError("pktlen must have a type of CONSTANT")
        self.tmpl_pkt["pktlen"] = htval.value

    def set_interval(self, htval):
        if not isinstance(htval, HTValue):
            raise HTTriggerError("set value must have a type of HTValue.")
        if htval.type == "CONSTANT":
            if htval.value == 0:
                rplc_type = RPLC_TYPE_FULL_SPEED
            else:
                rplc_type = RPLC_TYPE_CONSTANT_RATE
            if rplc_type in trigger.replicators:
                rplctor = trigger.replicators[rplc_type]
            else:
                rplctor = emptyclass()
                trigger.replicators[rplc_type] = rplctor
                rplctor.type = rplc_type
                rplctor.size = 0
                rplctor.templates = []

            self.tmpl_pkt["ht.pkt_interval"] = htval.value
            template = emptyclass()
            template.id = self.tmpl_id
            template.reg_id = rplctor.size
            rplctor.size += 1
            template.multicast_grp = self.multicast_grp
            rplctor.templates.append(template)

        elif htval.type == "RANDOM_ARRAY":
            if "RANDOM_RATE" in trigger.replicators:
                rplctor = trigger.replicators[RPLC_TYPE_RANDOM_RATE]
            else:
                rplctor = emptyclass()
                trigger.replicators[RPLC_TYPE_RANDOM_RATE] = rplctor
                rplctor.type = "RANDOM_RATE"
                rplctor.name = generate_uid("replicator", "RANDOM_RATE")
                rplctor.size = 0
                rplctor.rsize = 0
                rplctor.templates = []
            self.tmpl_pkt["ht.pkt_interval"] = 0
            template = emptyclass()
            template.id = self.tmpl_id
            template.reg_id = rplctor.size
            rplctor.size += 1
            template.multicast_grp = self.multicast_grp
            template.slices = inverse_transform(htval.value)
            rplctor.rsize += len(template.slices)
            rplctor.templates.append(template)
        else:
            raise HTTriggerError("type of interval value must be CONSTANT or RANDOM_ARRAY.")

    def set_output_port(self, htval):
        #TODO: configuration of multicast_grp
        pass

    def set(self, f, htval):
        #TODO: support for field_list and value_list

        if f not in HEADER_FIELDS.keys():
            raise HTTriggerError("cannot recognize field: " + f + " in trigger set method.")
        if not isinstance(htval, HTValue):
            raise HTTriggerError("set value must have a type of HTValue.")
        edt_name = generate_uid("editor", htval.type, f)
        if htval.type == "CONSTANT":
            self.tmpl_pkt[f] = htval.value
            if edt_name not in trigger.editors:
                edt = emptyclass()
                edt.name = edt_name
                edt.type = htval.type
                trigger.editors[edt_name] = edt
        elif htval.type == "ARRAY":
            self.tmpl_pkt[f] = htval.value[0]
            if edt_name in trigger.editors:
                edt = trigger.editors[edt_name]
            else:
                edt = emptyclass()
                edt.name = edt_name
                edt.type = htval.type
                edt.size = 0
                field = emptyclass() 
                field.p4 = f # field name in p4 codes
                field.id = f.replace('.','_') # formal parameter in action defination
                edt.fields = [field]
                edt.templates = []
                trigger.editors[edt_name] = edt
            template = emptyclass()
            template.id = self.tmpl_id
            template.reg_id = edt.size
            edt.size += 1
            template.packets = []
            for pkt_id in range(len(htval.value)):
                pkt = emptyclass()
                pkt.id = pkt_id
                pkt.values = [htval.value[pkt_id]]
                template.packets.append(pkt)
            edt.templates.append(template)
        elif htval.type == "RANGE_ARRAY":
            start, stop, step = htval.value
            self.tmpl_pkt[f] = start
            if edt_name in trigger.editors:
                edt = trigger.editors[edt_name]
            else:
                edt = emptyclass()
                edt.name = edt_name
                edt.type = htval.type
                edt.size = 0
                field = emptyclass() 
                field.p4 = f # field name in p4 codes
                field.id = f.replace('.','_') # formal parameter in action defination
                field.size = HEADER_FIELDS[f]
                edt.fields = [field]
                edt.templates = []
                trigger.editors[edt_name] = edt
            template = emptyclass()
            template.id = self.tmpl_id
            template.reg_id = edt.size
            edt.size += 1
            template.initial_value = start - step
            template.interval = step
            template.last_value = stop
            edt.templates.append(template)
        elif htval.type == "RANDOM_ARRAY":
            self.tmpl_pkt[f] = 0
            if edt_name in trigger.editors:
                edt = trigger.editors[edt_name]
            else:
                edt = emptyclass()
                edt.name = edt_name
                edt.type = htval.type
                edt.size = 0
                edt.rsize = 0
                field = emptyclass() 
                field.p4 = f # field name in p4 codes
                field.id = f.replace('.','_') # formal parameter in action defination
                field.size = HEADER_FIELDS[f]
                edt.fields = [field]
                edt.templates = []
                trigger.editors[edt_name] = edt
            template = emptyclass()
            template.id = self.tmpl_id
            edt.size += 1
            template.slices = inverse_transform(htval.value)
            edt.rsize += len(template.slices)
            edt.templates.append(template)
        return self




if __name__ == "__main__":
    # example

    trigger(interval=HTValue("CONSTANT", 1000)).set("ipv4.src_addr", HTValue("CONSTANT", "10.0.0.1"))
    trigger(interval= HTValue("CONSTANT", 0)).set("ipv4.src_addr", HTValue("ARRAY", [1,2,3,4]))
    trigger(interval= HTValue("CONSTANT", 0)).set("ipv4.src_addr", HTValue("RANGE_ARRAY", (0, 100, 10)))
    trigger(interval= HTValue("CONSTANT", 0)).set("ipv4.src_addr", HTValue("RANDOM_ARRAY", ("Uniform",[1000, 2000], 100)))
    trigger(interval=HTValue("RANDOM_ARRAY", ("Uniform", [1000, 2000], 2000))).set("ipv4.src_addr", HTValue("CONSTANT", "10.0.0.1"))
    # final outputs, static varibables of class
    print(trigger.tmpl_pkts)
    print(trigger.replicators)
    print(trigger.editors)


