#ifndef __HT_CONTROLS_H__
#define __HT_CONTROLS_H__


/* HTPS */
control replicator {
	//replicator_fullspeed(); 
	replicator_ratecontrol();
}

control accelerator {
	if ( acc_md.loop_cnt < MAX_LOOP_NUM ){
		apply(acc_recirculation) ;
	}
}

EDT_VLIST(ipv4, src_addr)
EDT_RANGE(ipv4, dst_addr)
control editor {
	apply(edt_range_load_ipv4_dst_addr);		
	apply(edt_range_step_ipv4_dst_addr);		
	if ( ipv4.src_addr == ipv4_dst_addr_RANGE_END ){
		apply(edt_range_reset_ipv4_dst_addr);		
	}else {
		apply(edt_range_save_ipv4_dst_addr);		
	}
	apply(edt_value_list_ipv4_src_addr);
	apply(edt_rm_ht_hdr);
}

/* HTPR */
header_type query_mapkey_md_t {
	fields {
		mask_ipv4_src_addr : 16;
	}
}
metadata query_mapkey_md_t query_mapkey_md;
action do_map_query_keys(){
	shift_right(query_mapkey_md.mask_ipv4_src_addr, ipv4.src_addr, 16);
}
table query_map_keys {
	reads {
		ht.template_id : exact;
	}
	actions {
		do_map_query_keys;
	}
	size : 1;
}
field_list map_keys1 {
	query_mapkey_md.mask_ipv4_src_addr;
	ipv4.dst_addr;
}
REDUCE(1)
table reduce1_fp_filter {
	reads {
		query_mapkey_md.mask_ipv4_src_addr : exact;
		ipv4.dst_addr : exact;
	}
	actions {
		nop;
	}
	size : 512;
}
control query_recv {
	apply(query_map_keys);
	apply(reduce1_fp_filter){
		miss {	
			reduce1();
		}
	}
}
#endif
