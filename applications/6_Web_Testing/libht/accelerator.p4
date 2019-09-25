#ifndef _HYPERTESTER_ACCELERATOR_H_
#define _HYPERTESTER_ACCELERATOR_H_

/* filed_list remaining after recirculation, e.g. loop counter*/
header_type acc_md_t {
	fields {
		loop_cnt : 16;
	}
}
metadata acc_md_t acc_md;

field_list acc_recirc_fields {
	acc_md.loop_cnt;	
}

/* accelerator: a stable high-speed packet source for replicator.
*  it executes recirculation over every non-replicated template packets. 
*/
action do_step_acc_loop_cnt(){
	add_to_field(acc_md.loop_cnt, 1);
}
table acc_step_loop_cnt {
	actions {
		do_step_acc_loop_cnt;
	}
	size : 1;
}

action do_acc_recirc() {
	recirculate(acc_recirc_fields);
}
table acc_recirculation {
	actions {
		do_acc_recirc;
	}
}

#endif /* _HYPERTESTER_ACCELERATOR_H_ */
