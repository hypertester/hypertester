#ifndef __HT_COLLECT_H__
#define __HT_COLLECT_H__

#define CPU_PORT_ID 64

#define COLLECT(idx) 	\
header_type collect##idx##_md_t { \
	fields { \
		timestamp : 48; \
	} \
} \
metadata collect##idx##_md_t collect##idx##_md; \
register collect##idx##_timer { \
	width : 48; \
	instance_count : 1; \
} \
action do_load_collect##idx##_ts(){ \
	register_read(collect##idx##_md.timestamp, collect##idx##_timer, 0); \
} \
table collect##idx##_load_ts { \
	actions { \
		do_load_collect##idx##_ts; \
	} \
	size : 1; \
} \
action do_save_collect##idx##_ts(){ \
	generate_digest(CPU_PORT_ID, collect##idx##_flist); \
	register_write(collect##idx##_timer, 0, ig_ts); \
} \
table collect##idx##_save_ts { \
	actions { \
		do_save_collect##idx##_ts; \
	} \
	size : 1; \
} \
control collect##idx { \
	apply(collect##idx##_load_ts); \
	if ( ig_ts - collect##idx##_md.timestamp > COLLECT##idx##_TIME ){ \
		apply(collect##idx##_save_ts);	 \
	} \
}


#endif
