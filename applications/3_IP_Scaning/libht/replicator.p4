#ifndef _HYPERTESTER_REPLICATOR_H_
#define _HYPERTESTER_REPLICATOR_H_

header_type replicator_md_t {
	fields {
		last_timestamp : 32;
		pkt_interval : 32;
	}
}
metadata replicator_md_t rep_md;

/* replicator fullspeed */
table fullspeed_replicator {
	reads {
		ht.template_id : exact;
	}
	actions {
		do_multicast;
	}
	size : TEMPLATE_NUM;
}

control replicator_fullspeed {
	apply(fullspeed_replicator);
}

/* replicator with rate control */
register replicator_ts_reg {
	width : 48;
	instance_count : TEMPLATE_NUM;
}

action do_rep_load_timestamp(pkt_interval){
	register_read(rep_md.last_timestamp, replicator_ts_reg, ht.template_id);
	modify_field(rep_md.pkt_interval, pkt_interval);
}
table rep_load_timestamp {
	reads {
		ht.template_id : exact;
	}
	actions {
		do_rep_load_timestamp;
	}
	size : TEMPLATE_NUM;
}

action do_rep_mcast(mcast_group){
	register_write(replicator_ts_reg, ht.template_id, ig_ts);	
	modify_field(intrinsic_metadata.mcast_grp, mcast_group);
}
table rep_mcast_engine {
	reads {
		ht.template_id : exact;	
	}
	actions {
		do_rep_mcast;
	}
	size : TEMPLATE_NUM;
}

/* replicator: performs rate-controled packet replication to template pkts.*/
control replicator_ratecontrol {
	apply(rep_load_timestamp);
	if ( ig_ts - rep_md.last_timestamp> rep_md.pkt_interval ){
		apply(rep_mcast_engine);
	}
}

#endif
