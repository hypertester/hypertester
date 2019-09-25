#ifndef __HT_EDITOR_PROB_H__
#define __HT_EDITOR_PROB_H__

/* editor support 4 types of modification to header field*/
/* 4. follows a certain distribution, such as normal distribution */

#define EDT_PROB(H,F)		\
header_type edt_prob_md_##H##_##F##_t { \
	fields {		\
		prob_id : 16; \
	}			\
}				\
metadata edt_prob_md_##H##_##F##_t edt_prob_md_##H##_##F##; \
action do_edt_by_prob_init_##H##_##F (low, high) {	\
	modify_field_rng_uniform(edt_prob_md_##H##_##F##.prob_id, low, high); \
}				\
table edt_prob_init_##H##_##F {	\
	reads { 		\
		ht.template_id : exact; \
	}			\
	actions {		\
		 do_edt_by_prob_init_##H##_##F; \
	}			\
	size : TEMPLATE_NUM;	\
}				\
action do_edt_by_prob_set_##H##_##F (v) {	\
	modify_field(H.F, v);	\
}				\
table edt_prob_set_##H##_##F {	\
	reads { 		\
		ht.template_id : exact; \
		edt_prob_md_##H##_##F##.prob_id : range; \
	}			\
	actions {		\
		 do_edt_by_prob_set_##H##_##F; \
	}			\
	size : EDT_PROB_NUM;	\
}				

#endif
