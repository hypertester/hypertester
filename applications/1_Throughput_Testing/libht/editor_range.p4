#ifndef __HT_EDITOR_RANGE_H__
#define __HT_EDITOR_RANGE_H__

/* editor supports 4 types of modification on header fields*/
/* 3. follows an arithmetic progression */
/* initial value of reg can be updated by control plane before task starts, or use reset table*/

/* the workflow of editor3 is:
* (1) read value from reg to header fields;
* (2) add/subtract a step value to/from header fields;
* (3) write updated header fields value back to reg;
* Thus, to keep range as [RANGE_BEGIN, RANGE_END), the initial value of reg should be set to RANGE_BEGIN-1.
*/

#define EDT_RANGE(H,F)		\
register edt_reg_##H##_##F { 	\
	width : 32; 		\
	instance_count : 1; 	\
}				\
action do_edt_by_range_reset_##H##_##F () {	\
	register_write(edt_reg_##H##_##F, 0, H##_##F##_RANGE_BEGIN); \
	/*register_write(edt_reg_##H##_##F, 0, 0);*/ \
}				\
table edt_range_reset_##H##_##F {	\
	reads { 		\
		ht.template_id : exact; \
	}			\
	actions {		\
		do_edt_by_range_reset_##H##_##F; \
	}			\
	size : TEMPLATE_NUM;	\
}				\
action do_edt_by_range_load_##H##_##F (){ \
	register_read(H.F, edt_reg_##H##_##F, 0); \
}				\
table edt_range_load_##H##_##F {	\
	reads { 		\
		ht.template_id : exact; \
	}			\
	actions {		\
		do_edt_by_range_load_##H##_##F; \
	}			\
	size : TEMPLATE_NUM;	\
}				\
action do_edt_by_range_add_##H##_##F (step){ \
	/*add_to_field(H.F, H##_##F##_RANGE_STEP);*/ \
	add_to_field(H.F, step); \
}				\
action do_edt_by_range_sub_##H##_##F (step){ \
	/*subtract_from_field(H.F, H##_##F##_RANGE_STEP);*/ \
	subtract_from_field(H.F, step); \
}				\
table edt_range_step_##H##_##F {	\
	reads { 		\
		ht.template_id : exact; \
	}			\
	actions {		\
		do_edt_by_range_add_##H##_##F; \
		do_edt_by_range_sub_##H##_##F; \
	}			\
	size : TEMPLATE_NUM;	\
}				\
action do_edt_by_range_update_##H##_##F (){ \
	register_write(edt_reg_##H##_##F, 0, H.F); \
}				\
table edt_range_save_##H##_##F {	\
	reads { 		\
		ht.template_id : exact; \
	}			\
	actions {		\
		do_edt_by_range_update_##H##_##F; \
		do_edt_by_range_reset_##H##_##F; \
	}			\
	size : TEMPLATE_NUM;	\
}				
#endif
