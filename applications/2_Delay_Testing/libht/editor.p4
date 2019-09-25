#ifndef __HT_EDITOR_H__
#define __HT_EDITOR_H__

/* editor support 4 types of modification to header field*/
/* 1. a constant value set in template packets by switch CPU */
/* nop */
/* 2. follows a given value list */
/* 3. follows an arithmetic progression */
/* 4. follows a certain distribution, such as normal distribution */

#include "editor_vlist.p4"
#include "editor_range.p4"
#include "editor_prob.p4"
#include "editor_ts.p4"

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
