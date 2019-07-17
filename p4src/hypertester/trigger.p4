#ifndef _HYPERTESTER_TRIGGER_H_
#define _HYPERTESTER_TRIGGER_H_

#include "trigger_accelerator.p4"
#include "trigger_replicator.p4"
#include "trigger_fifo.p4"
#include "trigger_editor.p4"

action do_remove_ht_hdr() {
    modify_field(ethernet.ether_type, ht.ether_type);
    remove_header(ht);
}
table remove_ht_hdr {
    actions {
        do_remove_ht_hdr;
    }
    size : 1; //256; //the number of defined ethertype is 213
    default_action : do_remove_ht_hdr;
}

control trigger_ingress {
    if (valid(ht)) {
        replicator();
    }
    trigger_fifo();
}

control trigger_egress {
    if (valid(ht)) {
        if ( standard_metadata.instance_type == PKT_INSTANCE_TYPE_NORMAL ){
        // if ( standard_metadata.egress_port == A_SPECFIC_PORT ){
        //template pkts that will be recirculated
            accelerator();
        } else {
        //pkts modified by editor, then sent out
            apply(remove_ht_hdr);
            editor();
        }
    }
}

#endif