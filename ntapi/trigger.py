from utils import *

RPLC_TYPE_FULL_SPEED = "FULL_SPEED"
RPLC_TYPE_CONSTANT_RATE = "CONSTANT_RATE"
RPLC_TYPE_RANDOM_RATE = "RANDOM_RATE"

class trigger:
    ## outputs
    tmpl_pkts = {} # tmpl_id->list[tuple(key,value), ...]
    replicators = {} # (unique identifier)->(replicator data structure)
    editors = {} # (unique identifier)->(editor data structure)
    trigger_fifos = []
    ## global counter
    tmpl_id = 0
    ## definations

    def __init__(self, *args, **kwargs):
        self.tmpl_id = trigger.tmpl_id
        trigger.tmpl_id += 1
        self.tmpl_pkt = {}
        trigger.tmpl_pkts[self.tmpl_id] = self.tmpl_pkt

        self.fifo_edt = None
        # self.multicast_grp = 0

        if "interval" in kwargs:
            if isinstance(kwargs["interval"], HTValue):
                self.set_replicator(kwargs["interval"])
            else:
                raise HTTriggerError("interval value must be a type of HTValue.")
        else:
            self.set_replicator(HTValue("CONSTANT", 0)) # Full Speed

    def __repr__(self):
        pass
    def set(self, f, v):
        if isinstance(f, list):
            if not isinstance(v, list) or (len(f) != len(v)):
                raise HTTriggerError("expect a list of HTValues of the same length with field list")
        elif isinstance(f, str):
            f = [f]; v = [v]
        else:
            raise HTTriggerError("type error in trigger set method.")
        for field, htval in zip(f, v):
            if not isinstance(htval, HTValue):
                raise HTTriggerError("set value must have a type of HTValue.")
            if field in HEADER_FIELDS.keys():
                self.set_editor(field, htval)
            elif field in CONTRL_FIELDS:
                if field == "postpone":
                    if htval.type != "CONSTANT":
                        raise HTTriggerError("postpone must have a type of CONSTANT")
                    self.tmpl_pkt["postpone"] = htval.value
                elif field == "pktlen":
                    if htval.type != "CONSTANT":
                        raise HTTriggerError("postpone must have a type of CONSTANT")
                    self.tmpl_pkt["pktlen"] = htval.value
                elif field == "port":
                    self.set_output_port(htval)
                # move "interval" to trigger parameters.
                # elif field == "interval": 
                #     self.set_replicator(htval)
                elif field == "loop":
                    pass
            else:
                raise HTTriggerError("cannot recognize field: " + field + " in trigger set method.")
        return self

    def set_output_port(self, htval):
        #TODO: lack configuration of multicast_grp
        self.multicast_grp = 0
        # if self.rplc_template:
        self.rplc_template.multicast_grp = self.multicast_grp

    def set_replicator(self, htval):
        if htval.type == "CONSTANT":
            if htval.value == 0:
                rplc_type = RPLC_TYPE_FULL_SPEED
                pkt_intvl = 0
            else:
                rplc_type = RPLC_TYPE_CONSTANT_RATE
                pkt_intvl = htval.value
        elif htval.type == "RANDOM_ARRAY":
            rplc_type = RPLC_TYPE_RANDOM_RATE
            pkt_intvl = 0
        else:
            raise HTTriggerError("type of interval value must be CONSTANT or RANDOM_ARRAY.")

        if rplc_type in trigger.replicators:
            rplctr = trigger.replicators[rplc_type]
        else:
            rplctr = emptyclass()
            trigger.replicators[rplc_type] = rplctr 
            rplctr.type = rplc_type
            rplctr.size = 0
            rplctr.rsize = 0
            rplctr.templates = []
        self.rplc_template = emptyclass()
        self.rplc_template.id = self.tmpl_id
        rplctr.templates.append(self.rplc_template)
        self.rplc_template.reg_id = rplctr.size
        rplctr.size += 1
        if rplc_type == RPLC_TYPE_RANDOM_RATE:
            self.rplc_template.slices = inverse_transform(htval.value)
            rplctr.rsize += len(self.rplc_template.slices)

        self.tmpl_pkt["ht.pkt_interval"] = pkt_intvl

    def set_editor(self, f, htval):
        if htval.type == "QUERY_FIELD":
            self.set_fifo_editor(f, htval)
            return self

        edt_uid = generate_uid("editor", htval.type, f)
        if edt_uid in trigger.editors:
            edt = trigger.editors[edt_uid]
        else:
            edt = emptyclass()
            trigger.editors[edt_uid] = edt
            edt.name = edt_uid
            edt.type = htval.type
            edt.size = 0
            edt.rsize = 0
            edt.templates = []
            field = emptyclass()
            field.p4 = f # field name in p4 codes
            field.id = f.replace('.','_') # formal parameter in action defination
            field.size = HEADER_FIELDS[f]
            edt.fields = [field]
        template = emptyclass()
        edt.templates.append(template)
        template.id = self.tmpl_id
        template.reg_id = edt.size
        edt.size += 1

        if htval.type == 'CONSTANT':
            self.tmpl_pkt[f] = htval.value
        elif htval.type == 'ARRAY':
            self.tmpl_pkt[f] = htval.value[0]
            template.packets = []
            for pkt_id in range(len(htval.value)):
                pkt = emptyclass()
                pkt.id = pkt_id
                pkt.values = [htval.value[pkt_id]]
                template.packets.append(pkt)
        elif htval.type == 'RANGE_ARRAY':
            start, stop, step = htval.value
            self.tmpl_pkt[f] = start
            template.initial_value = start - step
            template.interval = step
            template.last_value = stop
        elif htval.type == 'RANDOM_ARRAY':
            self.tmpl_pkt[f] = 0
            template.slices = inverse_transform(htval.value)
            edt.rsize += len(template.slices)
        # elif htval.type == 'QUERY_FIELD':
        #     self.tmpl_pkt[f] = 0
        return self
    def set_fifo_editor(self, f, htval):
        if self.fifo_edt is None:
            self.fifo_edt = emptyclass()
            self.fifo_edt.type = "FIFO_EDITOR"
            self.fifo_edt.templates = []
            template = emptyclass()
            template.id = self.tmpl_id
            self.fifo_edt.templates.append(template)

            self.fifo_edt.fifo = emptyclass()
            trigger.trigger_fifos.append(self.fifo_edt.fifo)
            self.fifo_edt.fifo.name = generate_uid("fifo") 
            self.fifo_edt.fifo.size = 256
            self.fifo_edt.fifo.template_id = self.tmpl_id
            self.fifo_edt.fifo.fields = []
            self.fifo_edt.name = "edt" + self.fifo_edt.fifo.name
            trigger.editors[self.fifo_edt.name] = self.fifo_edt

        field = emptyclass()
        field.p4 = f # field name in p4 codes
        field.name = f.replace('.','_') # formal parameter in action defination
        field.size = HEADER_FIELDS[f]
        self.fifo_edt.fifo.fields.append(field)

if __name__ == "__main__":
    # test example
    trigger(interval=HTValue("CONSTANT", 1000)).set("ipv4.src_addr", HTValue("CONSTANT", "10.0.0.1"))
    trigger(interval= HTValue("CONSTANT", 0)).set("ipv4.src_addr", HTValue("ARRAY", [1,2,3,4])).set(["ipv4.dst_addr", "tcp.src_port"],[HTValue("CONSTANT", "10.0.0.2"), HTValue("CONSTANT", 10022)])
    trigger(interval= HTValue("CONSTANT", 0)).set("ipv4.src_addr", HTValue("RANGE_ARRAY", (0, 100, 10)))
    trigger(interval= HTValue("CONSTANT", 0)).set("ipv4.src_addr", HTValue("RANDOM_ARRAY", ("Uniform",[1000, 2000], 100)))
    trigger(interval=HTValue("RANDOM_ARRAY", ("Uniform", [1000, 2000], 2000))).set("ipv4.src_addr", HTValue("CONSTANT", "10.0.0.1"))
    trigger(interval=HTValue("CONSTANT", 1000)).set("ipv4.src_addr", HTValue("CONSTANT", "10.0.0.1")).set("tcp.src_port", HTValue("QUERY_FIELD", "placeholder")).set("tcp.dst_port", HTValue("QUERY_FIELD", "placeholder"))
    # final outputs, static varibables of class
    print(trigger.tmpl_pkts)
    print(trigger.replicators)
    print(trigger.editors)
