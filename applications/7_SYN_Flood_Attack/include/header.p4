#ifndef _HEADER_H_
#define _HEADER_H_


/* template header */
header_type hypertester_header_t {
    fields {
        prefix : 8;
        template_id : 8;
        packet_id : 16;
        time_gap : 32;
	ether_type : 16;
    }
}

header_type ethernet_t {
    fields {
        dst_addr : 48;
        src_addr : 48;
        ether_type : 16;
    }
}


header_type ipv4_t {
    fields {
        version : 4;
        ihl : 4;
        diffserv : 8;
        total_len : 16;
        identification : 16;
        flags : 3;
        frag_offset : 13;
        ttl : 8;
        protocol : 8;
        checksum : 16;
        src_addr : 32;
        dst_addr: 32;
    }
}

header_type tcp_t {
    fields {
        src_port : 16;
        dst_port : 16;
        seq_no : 32;
        ack_no : 32;
        data_offset : 4;
        res : 3;
        ecn : 3;
        ctrl : 6;
        window : 16;
        checksum : 16;
        urgent_ptr : 16;
    }
}

header_type udp_t {
    fields {
        src_port : 16;
        dst_port : 16;
        hdr_length : 16;
        checksum : 16;
    }
}

header_type icmp_t {
    fields {
        msg_type : 8;
        code : 16;
        checksum : 16;
    }
}

header_type icmp_request_t {
    fields {
        identifier_be : 16;
        identifier_le : 16;
        seq_num_be : 16;
        seq_num_le : 16;
    }
}

header_type vlan_t {
    fields {
        pri     : 3;
        cfi     : 1;
        vlan_id : 12;
        ether_type : 16;
    }
}

//header_type dns_t {
//    fields {
//        trsaction_id : 16;
//        reponse : 1;
//        opcode : 4;
//        truncated : 1;
//        recursioon : 1;
//        z : 1;
//        non_authenticated: 1;
//        resv : 4;
//        questions : 16;
//        anser_rrs : 16;
//        authority_rrs : 16;
//        additional_rrs : 16;
//    }
//}
//
//
//header_type url_byte_t {
//    fields {
//        byte : 8;
//    }
//}
//
//header_type dns_query_t {
//    fields {
//        type : 16;
//        class : 16;
//    }
//}
//
//header_type dns_answer_t {
//    fields {
//        name  : 16;
//        type  : 16;
//        class : 16;
//        ttl  : 32;
//        data_len : 16;
//        data : *;
//    }
//    length: data_len + 96;
//}

#endif
