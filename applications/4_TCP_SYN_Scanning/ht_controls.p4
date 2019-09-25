#ifndef __HT_CONTROLS_H__
#define __HT_CONTROLS_H__


/* HTPS */
control replicator {
	//replicator_fullspeed(); 
	replicator_ratecontrol();
}

control accelerator {
	//if (acc_md.loop_cnt < MAX_LOOP_NUM)
		apply(acc_recirculation) ;
}

EDT_RANGE(ipv4, dst_addr)
EDT_RANGE(tcp, dst_port)
control editor {
	apply(edt_range_load_tcp_dst_port);		
	apply(edt_range_load_ipv4_dst_addr);		
	apply(edt_range_step_tcp_dst_port);		
	if (tcp.dst_port == tcp_dst_port_RANGE_END ){
		apply(edt_range_reset_tcp_dst_port);		
		apply(edt_range_step_ipv4_dst_addr);		
		if ( ipv4.dst_addr == ipv4_dst_addr_RANGE_END ){
			apply(edt_range_reset_ipv4_dst_addr);		
			apply(acc_step_loop_cnt);
		}else{
			apply(edt_range_save_ipv4_dst_addr);		
		}
	}else{
		apply(edt_range_save_tcp_dst_port);		
	}

	/*rm ht header is always needed*/
	apply(edt_rm_ht_hdr);
}

/* HTPR */
field_list map_keys1 {
	ipv4.src_addr;
	ipv4.dst_addr;
	ipv4.protocol;
	tcp.src_port;
	tcp.dst_port;
}
REDUCE(1)
control dequeue_fifo {
	if (ht.pop_fifo == 1){
		dequeue_fifo1();
	}		
}
control recirc_fifo_poped {
	if (ht.pop_fifo == 1){
		recirc_fifo1();
	}		
}

field_list collect1_flist {
	map_keys1;
}
COLLECT(1)
/* cuckoo need a false positive filter */
table reduce1_fp_filter {
	reads {
		ipv4.src_addr : exact;
		ipv4.dst_addr : exact;
		ipv4.protocol : exact;
		tcp.src_port : exact;
		tcp.dst_port : exact;
	}
	actions {
		nop;
	}
	size : 512;
}
/* query_send and query_recv are deprecated */
control query_all {
	if (tcp.ctrl == 0x10010 or ht_md.pop_fifo_id == 1) {
		apply(reduce1_fp_filter){
			miss {	
				reduce1();
			}
		}
	}
	collect1();
}

action do_relay_fifo_id() {
	modify_field(ht_md.pkt_type, ht.pkt_type);
	modify_field(ht_md.pop_fifo_id, ht.pop_fifo);
}
table relay_fifo_id {
	reads {
		ht.pkt_type : exact;	
	}
	actions {
		do_relay_fifo_id;
	}
	size : 256;
}
control relay {
	apply(relay_fifo_id);
}

action do_response_synack_reset(){
	modify_field(ipv4.dst_addr, ipv4.src_addr);
	modify_field(ipv4.src_addr, ipv4.dst_addr);
	modify_field(tcp.dst_port, tcp.src_port);
	modify_field(tcp.src_port, tcp.dst_port);
	modify_field(tcp.seq_no, tcp.ack_no);
	modify_field(tcp.ack_no, tcp.seq_no+1);
	modify_field(tcp.ctrl, 0x10100);//ACK+RST
}
table response_synack_reset {
	reads {
		tcp.ctrl : exact;
	}
	actions {
		do_response_synack_reset;
	}
	size : 1;
}
control response {
	apply(response_synack_reset);
}

#endif
