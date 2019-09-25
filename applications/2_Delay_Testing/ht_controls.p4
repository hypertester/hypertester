#ifndef __HT_CONTROLS_H__
#define __HT_CONTROLS_H__


/* HTPS */
control replicator {
	//replicator_fullspeed(); 
	replicator_ratecontrol();
}

control accelerator {
		apply(acc_recirculation) ;
}

EDT_TS
control editor {
	apply(edt_set_ts);
	apply(edt_rm_ht_hdr);
}

/* HTPR */
control query_recv {
	reduce_delay();
}
#endif
