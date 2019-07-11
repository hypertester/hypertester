#ifndef _HYPERTESTER_ACCELERATOR_H_
#define _HYPERTESTER_ACCELERATOR_H_

/* filed_list remaining after recirculation, e.g. loops info*/
header_type acc_recirc_md_t {
	fields {
		placeholder : 1;	
	}
}
metadata acc_recirc_md_t acc_recirc_md;

/* accelerator: a stable high-speed packet source for replicator.
*  it executes recirculation over every non-replicated template packets. 
*/
field_list acc_recirc_fields {
	acc_recirc_md.placeholder;	
}

action do_recirc_acc() {
	recirculate(acc_recirc_fields);
}
table acc_recirculation {
	actions {
		do_recirc_acc;
	}
}

control accelerator {
	apply(acc_recirculation) ;
}

#endif /* _HYPERTESTER_ACCELERATOR_H_ */
