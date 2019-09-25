#ifndef _ACTION_H_
#define _ACTION_H_



header_type ingress_intrinsic_metadata_t {
	fields {
		resubmit_flag : 1;              // flag distinguishing original packets
						// from resubmitted packets.
		
		ingress_global_timestamp : 48;     // global timestamp (ns) taken upon
						   // arrival at ingress.
		
		mcast_grp : 16;                 // multicast group id (key for the
					        // mcast replication table)
		
		deflection_flag : 1;            // flag indicating whether a packet is
						// deflected due to deflect_on_drop.
		deflect_on_drop : 1;            // flag indicating whether a packet can
						// be deflected by TM on congestion drop
		
		enq_congest_stat : 2;           // queue congestion status at the packet
						// enqueue time.
		
		deq_congest_stat : 2;           // queue congestion status at the packet
						// dequeue time.
		
		mcast_hash : 13;                // multicast hashing
		
		egress_rid : 16;                // Replication ID for multicast
		
		lf_field_list : 32;             // Learn filter field list
		
		priority : 3;                   // set packet priority
		
		ingress_cos: 3;                 // ingress cos
		
		packet_color: 2;                // packet color
		
		qid: 5;                         // queue id
	}
}
metadata ingress_intrinsic_metadata_t intrinsic_metadata;

action do_forward (port) {
    modify_field(standard_metadata.egress_spec, port);
}

action do_multicast (mcast_group) {
    modify_field(intrinsic_metadata.mcast_grp, mcast_group);
}

action nop() {
	no_op();
}

action _drop() {
	drop();
}


#endif
