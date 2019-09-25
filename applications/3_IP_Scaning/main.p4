#include "ht_defines.p4"
#include "include/common.p4"
#include "libht/hypertester.p4"
#include "ht_controls.p4"

control ingress {
	if ( valid(ht) ){
		//trigger pkts, from cpu or reciculation, do multicast and rate control here
		if ( ht.pop_fifo == POP_FIFO1 ){
			dequeue_fifo1();	
			//poped pkts are passed to egress to be recirculated 
		}else{
			replicator();
		}
	}else{
		//HTPR received pkts 
		query_recv();
		//dropped, do not enter egress; may generate digest to CPU
	}
}
control egress {
	if ( standard_metadata.instance_type == PKT_INSTANCE_TYPE_NORMAL ){
	// if ( standard_metadata.egress_port == A_SPECFIC_PORT ){
		//template pkts, will be recirculated here
		if ( ht.pop_fifo == POP_FIFO1 ){
			recirc_fifo1();
		}else{
			accelerator();
		}
	}else{
		//test pkts we generated, will be modified by editor here, then sent out.
		if ( valid(ht) ){
			editor();
		}
	}
}
