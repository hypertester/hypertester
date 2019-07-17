#ifndef _HYPERTESTER_ACCELERATOR_H_
#define _HYPERTESTER_ACCELERATOR_H_


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
	size : 1;
	default_action : do_recirc_acc();
}

control accelerator {
	apply(acc_recirculation) ;
}

#endif /* _HYPERTESTER_ACCELERATOR_H_ */
