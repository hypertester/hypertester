#ifndef __HT_EDITOR_TS_H__
#define __HT_EDITOR_TS_H__

/* editor support 4 types of modification to header field*/
/* keep timestamp in eth src addr*/

#define EDT_TS		\
action do_edt_set_timestamp() { \
	modify_field(ethernet.src_addr, ig_ts); \
} \
table edt_set_ts { \
	actions { \
		do_edt_set_timestamp; \
	} \
	size : 1; \
}

#endif
