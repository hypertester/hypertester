#ifndef __HT_EDITOR_H__
#define __HT_EDITOR_H__

#include "editor_range.p4"

//action do_remove_ht_hdr(ether_type) {
action do_remove_ht_hdr() {
    modify_field(ethernet.ether_type, ht.ether_type);
    remove_header(ht);
}
table edt_rm_ht_hdr {
    actions {
        do_remove_ht_hdr;
    }
    size : 1; //256; //the number of defined ethertype is 213
}
#endif
