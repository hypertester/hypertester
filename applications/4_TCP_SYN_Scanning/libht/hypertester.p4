#ifndef _HYPERTESTER_H_
#define _HYPERTESTER_H_

#include "accelerator.p4"
#include "replicator.p4"
#include "editor.p4"
#include "collect.p4"

#include "libquery/query.p4"

header_type ht_md_t {
	fields {
		pkt_type : 8;
		pop_fifo_id : 8;
	}
}
metadata ht_md_t ht_md;


#endif
