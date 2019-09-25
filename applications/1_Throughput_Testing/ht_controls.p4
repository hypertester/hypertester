#ifndef __HT_CONTROLS_H__
#define __HT_CONTROLS_H__

/* HTPS */
control replicator {
	replicator_fullspeed(); 
	//replicator_ratecontrol();
}

control accelerator {
	apply(acc_recirculation) ;
}

control editor {
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
field_list collect1_flist {
	map_keys1;
}
COLLECT(1)
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
control query_recv {
	apply(reduce1_fp_filter){
		miss {	
			reduce1();
		}
	}
	collect1();
}
field_list map_keys2 {
	ipv4.src_addr;
	ipv4.dst_addr;
	ipv4.protocol;
	tcp.src_port;
	tcp.dst_port;
}
REDUCE(2)
field_list collect2_flist {
	map_keys2;
}
COLLECT(2)
table reduce2_fp_filter {
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
control query_send {
	apply(reduce2_fp_filter){
		miss {	
			reduce2();
		}
	}
	collect2();
}

#endif
