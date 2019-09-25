#ifndef __HT_DELAY_H__
#define __HT_DELAY_H__

header_type delay_md_t {
	fields {
		delay_ts : 48;
		index : DELAY_RANGE;
		cnt : 32;
	}
}
metadata delay_md_t delay_md;

action do_get_delay() {
	modify_field(delay_md.delay_ts, ig_ts - ethernet.src_addr);
}
table get_delay {
	actions {
		do_get_delay;
	}
	size : 1;
}
action do_align_delay(scale) {
	shift_right(delay_md.delay_ts, delay_md.delay_ts, scale);
}
table align_delay {
	actions {
		do_align_delay;
	}
	size : 1;
}
action set_index_within_range() {
	modify_field(delay_md.index, delay_md.delay_ts - DELAY_LOW_BOUND);	
}
action set_index_outof_range() {
	modify_field(delay_md.index, DELAY_RANGE - 1);
}
table get_delay_index {
	reads {
		delay_md.delay_ts : range;	
	}
	actions {
		set_index_within_range;
		set_index_outof_range;
	}
	size : 2;
}
register delay_reg {
	width : 32;
	instance_count : DELAY_RANGE;
}
action do_load_delay_cnt() {
	register_read(delay_md.cnt, delay_reg, delay_md.index);
}
table load_delay_cnt {
	actions {
		do_load_delay_cnt;
	}
	size : 1;
}
action do_update_delay_cnt() {
	register_write(delay_reg, delay_md.index, delay_md.cnt + 1);
}
table update_delay_cnt {
	actions {
		do_update_delay_cnt;
	}
	size : 1;
}
control reduce_delay{
	apply(get_delay);
	apply(align_delay);
	apply(get_delay_index);
	apply(load_delay_cnt);
	apply(update_delay_cnt);
}




#endif
