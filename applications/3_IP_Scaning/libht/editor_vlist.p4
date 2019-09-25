#ifndef __HT_EDITOR_VLIST_H__
#define __HT_EDITOR_VLIST_H__

/* editor support 4 types of modification to header field*/
/* 2. follows a given value list */

#define EDT_VLIST(H,F)		\
action do_edt_by_value_list_##H##_##F(v) { \ 	
	modify_field(H.F, v);   \		
}			        \ 
table edt_value_list_##H##_##F {	\
	reads { 		\
		ht.template_id : exact; \
		ht.packet_id : exact; \
	}			\
	actions {		\
		do_edt_by_value_list_##H##_##F; \
	}			\
	size : EDT_VLIST_NUM;	\
}				

#endif
