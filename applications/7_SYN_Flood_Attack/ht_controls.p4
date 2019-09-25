#ifndef __HT_CONTROLS_H__
#define __HT_CONTROLS_H__

control replicator {
	replicator_fullspeed(); 
	//replicator_ratecontrol();
}

control accelerator {
	if ( acc_md.loop_cnt < MAX_LOOP_NUM ){
		apply(acc_recirculation) ;
	}
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

#endif
