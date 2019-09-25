#include "ht_defines.p4"
#include "include/common.p4"
#include "libht/hypertester.p4"
#include "ht_controls.p4"

control ingress {
	if ( valid(ht) ){
		//trigger pkts, from cpu or reciculation
		//1. normal template pkts, do replica and recirc to generate testing traffic
		//2. pkts used to pop fifo
		if (ht.pkt_type == HT_PKT_TYPE_TMPL){
			replicator();
		}else if (ht.pkt_type == HT_PKT_TYPE_POP_FIFO){
			//the logic of distinguish multi-fifos is inside this func.
			dequeue_fifo();
		}
	}else{
		//received pkts 
		//1.statistics, recv correct response, or fifo poped(we have stripped ht header when recirc fifo poped pkts)
		//2. fast response in dataplane
		//query_recv();
		//fast_response();
		//response must be in egress, cause it will send pkt
		//so we also put hashpipe+enqueue_fifo into egress, cause query for send-out traffic must behind editor, which have to settle in egress

		//cause pkts must have a egress port, otherwise it will be dropped before entering egress, we need a relay-forwarder here.
		//the relay is also a filter, and add some control metadata cause we dont have ht header anymore.
		//like put pop_fifo_id from ht header to a md, cause we need to know which fifo to re-enter.
		relay();
	}
}
control egress {
	if ( valid(ht) ){
		if (ht.pkt_type == HT_PKT_TYPE_TMPL){
			if (standard_metadata.instance_type == PKT_INSTANCE_TYPE_NORMAL){
				accelerator();
			}else{
				editor();
				//query_send();
			}
		}else if (ht.pkt_type == HT_PKT_TYPE_POP_FIFO){
			//because fifo is behind hashpipe, so we have to recirculate fifo poped pkts, to let them re-enter hashpipe
			//when recirc, we remove ht header, so it will get into "received pkts" part of code.
			//here we need to retain the info we need after recirc by providing a field list when recirc
			recirc_fifo_poped();
		}
	}else{
		//pkts from ingress received
		//we need to do statistics(moved behind), and fast reponse here
		//like generate SYN+ACK from received SYN
		response();
	}
	//there may exists needs for query sending traffics, it must behind editor
	//what's more, what we want to query varies, from testing-traffic generated from templates, to fast-responding traffic, or even how many pkts being poped from fifo. But how to identify them and which hashpipe to enter when multi fifos exist leave to the function logic below.
	query_all();
}


