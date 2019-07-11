#ifndef _PARSER_H_
#define _PARSER_H_

parser start {
    return select(current(0, 8)) {
        0x80: parse_hypertester; // TODO: HyperTester prefix needs further udpate.
        default: parse_ethernet;
    }
}

// Layout: HT -> Ethernet -> IPv4/IPv6 -> TCP/UDP -> Payload
header hypertester_hdr_t ht;
parser parse_hypertester {
    extract(ht);
    return parse_ethernet;
}

header ethernet_t ethernet;
parser parse_ethernet {
    extract(ethernet);
    return select(latest.ether_type) {
        ETHERTYPE_IPV4 : parse_ipv4;  
        ETHERTYPE_VLAN : parse_vlan;  
        default: ingress;
    }
}

header vlan_t vlan;
parser parse_vlan {
    extract(vlan);
    return select(latest.ether_type) {
        ETHERTYPE_IPV4 : parse_ipv4;
        default: ingress;
    }
}

header ipv4_t ipv4;
parser parse_ipv4 {
    extract(ipv4);
    return select(latest.protocol) {
        IP_PROTOCOLS_TCP : parse_tcp;
        IP_PROTOCOLS_UDP : parse_udp;
        IP_PROTOCOLS_ICMP : parse_icmp;
        default: ingress;
    }
}

header tcp_t tcp;
parser parse_tcp {
    extract(tcp);
    return ingress;
}

header udp_t udp;
parser parse_udp {
    extract(udp);
    return ingress;
}

header icmp_t icmp;
parser parse_icmp {
    extract(icmp);
    return ingress;
}

#endif
