#ifndef __HT_HASH_PIPE_H__
#define __HT_HASH_PIPE_H__

#define HASHPIPE(idx) 	\
field_list hp##idx##_keys { \
	map_keys##idx; 	\
}			\
field_list_calculation hp##idx##_hash_dgst { \
	input { \
		hp##idx##_keys;  \
	} \
	algorithm : crc16; \
	output_width : 16;  \
} \
field_list_calculation hp##idx##_hash_index1 { \
	input { \
		hp##idx##_keys;  \
	} \
	algorithm : crc32; \
	output_width : 16;  \
} \
action do_calc_hp##idx##_index1() { \
	modify_field_with_hash_based_offset(reduce##idx##_md.hp_dgst, 0, hp##idx##_hash_dgst, 65536); \
	modify_field_with_hash_based_offset(reduce##idx##_md.hp_index, 0, hp##idx##_hash_index1, 65536); \
} \
action do_calc_hp##idx##_index1_poped() { \
	bit_xor(reduce##idx##_md.hp_index, reduce##idx##_md.hp_index, reduce##idx##_md.hp_dgst); \
} \
table hp##idx##_calc_hash_index1 { \
	reads { \
		packet_instance : exact; \
	} \
	actions { \
		do_calc_hp##idx##_index1; \
		do_calc_hp##idx##_index1_poped; \
	} \
	size : 2; \
} \
action do_calc_hp##idx##_index2() { \
	bit_xor(reduce##idx##_md.hp_index, reduce##idx##_md.hp_index, reduce##idx##_md.hp_dgst); \
} \
table hp##idx##_calc_hash_index2 { \
	actions { \
		do_calc_hp##idx##_index2; \
	} \
	size : 1; \
} \
register hp##idx##_stage1_dgst { \
	width : 16; \
	instance_count : 65536; \
} \
register hp##idx##_stage2_dgst { \
	width : 16; \
	instance_count : 65536; \
} \
register hp##idx##_stage1_cnt { \
	width : 16; \
	instance_count : 65536; \
} \
register hp##idx##_stage2_cnt { \
	width : 16; \
	instance_count : 65536; \
} \
action do_load_hp##idx##_stage1_dgst() { \
	register_read(reduce##idx##_md.hp_cached_dgst, hp##idx##_stage1_dgst, reduce##idx##_md.hp_index); \
} \
table hp##idx##_load_stage1_dgst { \
	actions { \
		do_load_hp##idx##_stage1_dgst; \
	} \
	size : 1; \
} \
action do_update_stage1_dgst_empty() { \
	register_write(hp##idx##_stage1_dgst, reduce##idx##_md.hp_index, reduce##idx##_md.hp_dgst); \
	register_write(hp##idx##_stage1_cnt, reduce##idx##_md.hp_index, 1); \
} \
table hp##idx##_update_stage1_when_empty { \
	actions { \
		do_update_stage1_dgst_empty; \
	} \
	size : 1; \
} \
action do_load_hp##idx##_stage1_cnt() { \
	register_read(reduce##idx##_md.hp_cnt, hp##idx##_stage1_cnt, reduce##idx##_md.hp_index); \
} \
table hp##idx##_load_stage1_cnt { \
	actions { \
		do_load_hp##idx##_stage1_cnt; \
	} \
	size : 1; \
} \
action do_step_hp##idx##_stage1_cnt() { \
	add_to_field(reduce##idx##_md.hp_cnt, 1); \
} \
table hp##idx##_step_stage1_cnt { \
	actions { \
		do_step_hp##idx##_stage1_cnt; \
	} \
	size : 1; \
} \
action do_save_hp##idx##_stage1_cnt() { \
	register_write(hp##idx##_stage1_cnt, reduce##idx##_md.hp_index, reduce##idx##_md.hp_cnt); \
} \
table hp##idx##_save_stage1_cnt { \
	actions { \
		do_save_hp##idx##_stage1_cnt; \
	} \
	size : 1; \
} \
control hp##idx##_update_stage1_when_hit { \
	apply(hp##idx##_load_stage1_cnt); \
	apply(hp##idx##_step_stage1_cnt); \
	apply(hp##idx##_save_stage1_cnt); \
} \
action do_swap_hp##idx##_stage1_dgst(){ \
	register_write(hp##idx##_stage1_dgst, reduce##idx##_md.hp_index, reduce##idx##_md.hp_dgst); \
	modify_field(reduce##idx##_md.hp_dgst, reduce##idx##_md.hp_cached_dgst); \
} \
table hp##idx##_swap_stage1_dgst { \
	actions { \
		do_swap_hp##idx##_stage1_dgst; \
	} \
	size : 1; \
} \
action do_swap_hp##idx##_stage1_cnt(){ \
	register_read(reduce##idx##_md.hp_cnt, hp##idx##_stage1_cnt, reduce##idx##_md.hp_index); \
	register_write(hp##idx##_stage1_cnt, reduce##idx##_md.hp_index, 1); \
} \
table hp##idx##_swap_stage1_cnt { \
	actions { \
		do_swap_hp##idx##_stage1_cnt; \
	} \
	size : 1; \
} \
control hp##idx##_update_stage1_when_miss { \
	if ( packet_instance == PKT_INSTANCE_TYPE_INGRESS_RECIRC ){ \
		apply(hp##idx##_swap_stage1_dgst); \
		apply(hp##idx##_swap_stage1_cnt); \
	} \
} \
action do_load_hp##idx##_stage2_dgst() { \
	register_read(reduce##idx##_md.hp_cached_dgst, hp##idx##_stage2_dgst, reduce##idx##_md.hp_index); \
} \
table hp##idx##_load_stage2_dgst { \
	actions { \
		do_load_hp##idx##_stage2_dgst; \
	} \
	size : 1; \
} \
action do_update_stage2_dgst_empty() { \
	register_write(hp##idx##_stage2_dgst, reduce##idx##_md.hp_index, reduce##idx##_md.hp_dgst); \
	register_write(hp##idx##_stage2_cnt, reduce##idx##_md.hp_index, 1); \
} \
table hp##idx##_update_stage2_when_empty { \
	actions { \
		do_update_stage2_dgst_empty; \
	} \
	size : 1; \
} \
action do_load_hp##idx##_stage2_cnt() { \
	register_read(reduce##idx##_md.hp_cnt, hp##idx##_stage2_cnt, reduce##idx##_md.hp_index); \
} \
table hp##idx##_load_stage2_cnt { \
	actions { \
		do_load_hp##idx##_stage2_cnt; \
	} \
	size : 1; \
} \
action do_step_hp##idx##_stage2_cnt() { \
	add_to_field(reduce##idx##_md.hp_cnt, 1); \
} \
table hp##idx##_step_stage2_cnt { \
	actions { \
		do_step_hp##idx##_stage2_cnt; \
	} \
	size : 1; \
} \
action do_save_hp##idx##_stage2_cnt() { \
	register_write(hp##idx##_stage2_cnt, reduce##idx##_md.hp_index, reduce##idx##_md.hp_cnt); \
} \
table hp##idx##_save_stage2_cnt { \
	actions { \
		do_save_hp##idx##_stage2_cnt; \
	} \
	size : 1; \
} \
control hp##idx##_update_stage2_when_hit { \
	apply(hp##idx##_load_stage2_cnt); \
	apply(hp##idx##_step_stage2_cnt); \
	apply(hp##idx##_save_stage2_cnt); \
} \
action do_swap_hp##idx##_stage2_dgst(){ \
	register_write(hp##idx##_stage2_dgst, reduce##idx##_md.hp_index, reduce##idx##_md.hp_dgst); \
	modify_field(reduce##idx##_md.hp_dgst, reduce##idx##_md.hp_cached_dgst); \
} \
table hp##idx##_swap_stage2_dgst { \
	actions { \
		do_swap_hp##idx##_stage2_dgst; \
	} \
	size : 1; \
} \
action do_swap_hp##idx##_stage2_cnt(){ \
	register_read(reduce##idx##_md.hp_cnt, hp##idx##_stage2_cnt, reduce##idx##_md.hp_index); \
	register_write(hp##idx##_stage2_cnt, reduce##idx##_md.hp_index, reduce##idx##_md.hp_cnt); \
} \
table hp##idx##_swap_stage2_cnt { \
	actions { \
		do_swap_hp##idx##_stage2_cnt; \
	} \
	size : 1; \
} \
control hp##idx##_update_stage2_poped_miss { \
	apply(hp##idx##_swap_stage2_dgst); \
	apply(hp##idx##_swap_stage2_cnt); \
} \
control reduce##idx { \
	apply(hp##idx##_calc_hash_index1); \
	apply(hp##idx##_load_stage1_dgst); \
	if ( reduce##idx##_md.hp_cached_dgst == 0 ){ \
		apply(hp##idx##_update_stage1_when_empty); \
	}else{ \
		if ( reduce##idx##_md.hp_cached_dgst == reduce##idx##_md.hp_dgst ) { \
			hp##idx##_update_stage1_when_hit(); \
		}else{ \
			hp##idx##_update_stage1_when_miss(); \
			apply(hp##idx##_calc_hash_index2); \
			apply(hp##idx##_load_stage2_dgst); \
			if ( reduce##idx##_md.hp_cached_dgst == 0 ){ \
				apply(hp##idx##_update_stage2_when_empty); \
			}else{ \
				if ( reduce##idx##_md.hp_cached_dgst == reduce##idx##_md.hp_dgst ) { \
					hp##idx##_update_stage2_when_hit(); \
				}else{ \
					if ( packet_instance == PKT_INSTANCE_TYPE_INGRESS_RECIRC ){ \
						hp##idx##_update_stage2_poped_miss(); \
						/*generate_digest();*/ \
					}else{ \
						enqueue_fifo##idx(); \
					} \
				} \
			} \
		} \
	} \
}
#endif
