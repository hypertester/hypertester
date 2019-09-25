#ifndef __HT_REDUCE_H__
#define __HT_REDUCE_H__

#include "fifo.p4"
#include "hashpipe.p4"

#define REDUCE(idx) \
header_type reduce##idx##_md_t { \
	fields {	\
		hp_index : 16; \
		hp_dgst : 16; \
		hp_cached_dgst : 16; \
		hp_cnt : 16; \
		fifo_read_or_write : 1; \
		fifo_loc : 8; \
		fifo_read_loc : 32; \
		fifo_write_loc : 32; \
	} 	\
}		\
metadata reduce##idx##_md_t reduce##idx##_md; \
field_list reduce##idx##_recirc_fl { \
	reduce##idx##_md.hp_index; \
	reduce##idx##_md.hp_dgst; \
}\
FIFO(idx) \
HASHPIPE(idx)

#endif
