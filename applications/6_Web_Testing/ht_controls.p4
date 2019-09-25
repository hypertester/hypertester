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

EDT_RANGE(ipv4, src_addr)
EDT_RANGE(tcp, src_port)
control editor {
	apply(edt_range_load_tcp_src_port);		
	apply(edt_range_load_ipv4_src_addr);		
	apply(edt_range_step_tcp_src_port);		
	if (tcp.src_port == tcp_src_port_RANGE_END ){
		apply(edt_range_reset_tcp_src_port);		
		apply(edt_range_step_ipv4_src_addr);		
		if ( ipv4.src_addr == ipv4_src_addr_RANGE_END ){
			apply(edt_range_reset_ipv4_src_addr);		
			apply(acc_step_loop_cnt);
		}else{
			apply(edt_range_save_ipv4_src_addr);		
		}
	}else{
		apply(edt_range_save_tcp_src_port);		
	}
	apply(edt_rm_ht_hdr);
}

/* HTPR */

field_list map_keys1 {
	ipv4.dst_addr;
}
REDUCE(1)
field_list collect1_flist {
	map_keys1;
}
COLLECT(1)
table reduce1_fp_filter {
	reads {
		ipv4.dst_addr : exact;
	}
	actions {
		nop;
	}
	size : 512;
}
control query_recv {
	apply(reduce1_fp_filter){
		miss {	
			reduce1();
		}
	}
	collect1();
}

/**/
action do_response_synack() {
	modify_field(standard_metadata.egress_port, HT_STATELESS_CONN1);
}
table response_synack {
	actions {
		do_response_synack;	
	}
	size : 1;
}
control response_synack {
	apply(response_synack);
}

action do_response_ack() {
	modify_field(standard_metadata.egress_port, HT_STATELESS_CONN1);
}
table response_ack {
	actions {
		do_response_ack;	
	}
	size : 1;
}
control response_ack {
	apply(response_ack);
}

action do_edt_response_synack(){
	modify_field(ipv4.dst_addr, ipv4.src_addr);
	modify_field(ipv4.src_addr, ipv4.dst_addr);
	modify_field(tcp.dst_port, tcp.src_port);
	modify_field(tcp.src_port, tcp.dst_port);
	modify_field(tcp.ctrl, 0x10000);
}
table edt_response_synack {
	actions {
		do_edt_response_synack;
	}
	size : 1;
}

action do_edt_response_ack(){
	modify_field(ipv4.dst_addr, ipv4.src_addr);
	modify_field(ipv4.src_addr, ipv4.dst_addr);
	modify_field(tcp.dst_port, tcp.src_port);
	modify_field(tcp.src_port, tcp.dst_port);
	modify_field(tcp.ctrl, 0x11000);
	//modify payload
}
table edt_response_ack {
	actions {
		do_edt_response_ack;
	}
	size : 1;
}
#endif
