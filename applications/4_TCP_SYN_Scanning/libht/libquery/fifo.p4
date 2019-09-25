#ifndef __HT_FIFO_H__
#define __HT_FIFO_H__

#define FIFO(idx) \
register fifo##idx##_cb_tail { \
	width : 48; \
	instance_count: 1; \
} \
register fifo##idx##_cb_head { \
	width : 48; \
	instance_count: 1; \
} \
action do_load_fifo##idx##_wt_ptr(){ \
	register_read(reduce##idx##_md.fifo_write_loc, fifo##idx##_cb_tail, 0); \
} \
table fifo##idx##_load_wt_ptr { \
	actions{ \
		do_load_fifo##idx##_wt_ptr; \
	} \
	size : 1; \
} \
action do_load_fifo##idx##_cb_ptr(){ \
	register_read(reduce##idx##_md.fifo_write_loc, fifo##idx##_cb_tail, 0); \
	register_read(reduce##idx##_md.fifo_read_loc, fifo##idx##_cb_head, 0); \
} \
table fifo##idx##_load_cb_ptr { \
	actions{ \
		do_load_fifo##idx##_cb_ptr; \
	} \
	size : 1; \
} \
action do_step_fifo##idx##_head1(){ \
	add_to_field(reduce##idx##_md.fifo_read_loc, 1); \
} \
table step_fifo##idx##_head1 { \
	actions { \
		do_step_fifo##idx##_head1; \
	} \
	size : 1; \
} \
action do_step_fifo##idx##_head2(){ \
	register_write(fifo##idx##_cb_head, 0, reduce##idx##_md.fifo_read_loc); \
} \
table step_fifo##idx##_head2 { \
	actions { \
		do_step_fifo##idx##_head2; \
	} \
	size : 1; \
} \
control step_fifo##idx##_head { \
	apply(step_fifo##idx##_head1); \
	apply(step_fifo##idx##_head2); \
} \
 \
action do_step_fifo##idx##_tail1(){ \
	add_to_field(reduce##idx##_md.fifo_write_loc, 1); \
} \
table step_fifo##idx##_tail1 { \
	actions { \
		do_step_fifo##idx##_tail1; \
	} \
	size : 1; \
} \
action do_step_fifo##idx##_tail2(){ \
	register_write(fifo##idx##_cb_tail, 0, reduce##idx##_md.fifo_write_loc); \
} \
table step_fifo##idx##_tail2 { \
	actions { \
		do_step_fifo##idx##_tail2; \
	} \
	size : 1; \
} \
control step_fifo##idx##_tail { \
	apply(step_fifo##idx##_tail1); \
	apply(step_fifo##idx##_tail2); \
} \
register fifo##idx##_rbuf_dgst { \
	width : 16; \
	instance_count : FIFO_BUF_SIZE; \
} \
register fifo##idx##_rbuf_index { \
	width : 16; \
	instance_count : FIFO_BUF_SIZE; \
} \
action do_read_fifo##idx##_rbuf() { \
	register_read(reduce##idx##_md.hp_dgst, fifo##idx##_rbuf_dgst, reduce##idx##_md.fifo_read_loc); \
	register_read(reduce##idx##_md.hp_index, fifo##idx##_rbuf_index, reduce##idx##_md.fifo_read_loc); \
} \
table fifo##idx##_read_rbuf { \
	actions { \
		do_read_fifo##idx##_rbuf; \
	} \
	size : 1; \
} \
action do_write_fifo##idx##_rbuf() { \
	register_write(fifo##idx##_rbuf_dgst, reduce##idx##_md.fifo_write_loc, reduce##idx##_md.hp_dgst); \
	register_write(fifo##idx##_rbuf_index, reduce##idx##_md.fifo_write_loc, reduce##idx##_md.hp_index); \
} \
table fifo##idx##_write_rbuf { \
	actions { \
		do_write_fifo##idx##_rbuf; \
	} \
	size : 1; \
} \
control enqueue_fifo##idx { \
	apply(fifo##idx##_load_wt_ptr); \
	step_fifo##idx##_tail();	 \
	apply(fifo##idx##_write_rbuf); \
} \
control dequeue_fifo##idx { \
	apply(fifo##idx##_load_cb_ptr); \
	if ( reduce##idx##_md.fifo_read_loc <= reduce##idx##_md.fifo_write_loc ) { \
		apply(fifo##idx##_read_rbuf); \
		step_fifo##idx##_head(); \
	} \
} \
action do_recirc_fifo##idx##_poped() { \
    	remove_header(ht); \
	recirculate(reduce##idx##_recirc_fl); \ 
} \
table fifo##idx##_recirc { \
	actions{ \
		_drop; \
		do_recirc_fifo##idx##_poped; \
	} \
	size : 2; \
} \
control recirc_fifo##idx { \
	apply(fifo##idx##_recirc); \
}
#endif
