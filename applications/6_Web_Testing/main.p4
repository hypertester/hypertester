#include "ht_defines.p4"
#include "include/common.p4"
#include "libht/hypertester.p4"
#include "ht_controls.p4"

control ingress {
	if ( valid(ht) ){
		//trigger pkts, from cpu or reciculation, do multicast and rate control here
		replicator();
	}else{
		//HTPR received pkts 
		if ( tcp.ctrl == 0x10010 ){
			//SYN+ACK
			query_recv();
			response_synack();
		}else if ( tcp.ctrl == 0x10000 ){
			//ACK
			response_ack();
		}

		//dropped, do not enter egress; may generate digest to CPU
	}
}
control egress {
	//need a good planning for using output port
	if ( standard_metadata.egress_port == HT_ACC_PORT){
		accelerator();
	}else if (standard_metadata.egress_port == HT_STATELESS_CONN1){
		apply(edt_response_synack);	
	}else if (standard_metadata.egress_port == HT_STATELESS_CONN2) {
		apply(edt_response_ack);	
	}else if (standard_metadata.egress_port == HT_FIFO_POP_PORT) {
		//for recirculate pkts poped from fifo	
	}else{
		//editor port
		if ( valid(ht) ){
			editor();
		}
	}
}


