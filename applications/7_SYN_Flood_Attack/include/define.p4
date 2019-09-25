#ifndef _DEFINE_H_
#define _DEFINE_H_

#define ETHERTYPE_VLAN          0x8100
#define ETHERTYPE_IPV4          0x0800
#define ETHERTYPE_IPV6          0x86dd
#define ETHERTYPE_ARP           0x0806
#define ETHERTYPE_RARP          0x8035
#define ETHERTYPE_NSH           0x894f
#define ETHERTYPE_HT            0x0808


#define IP_PROTOCOLS_ICMP              1
#define IP_PROTOCOLS_IGMP              2
#define IP_PROTOCOLS_IPV4              4
#define IP_PROTOCOLS_TCP               6
#define IP_PROTOCOLS_UDP               17
#define IP_PROTOCOLS_IPV6              41
#define IP_PROTOCOLS_SR                43
#define IP_PROTOCOLS_GRE               47
#define IP_PROTOCOLS_IPSEC_ESP         50
#define IP_PROTOCOLS_IPSEC_AH          51
#define IP_PROTOCOLS_ICMPV6            58
#define IP_PROTOCOLS_EIGRP             88
#define IP_PROTOCOLS_OSPF              89
#define IP_PROTOCOLS_ETHERIP           97
#define IP_PROTOCOLS_PIM               103
#define IP_PROTOCOLS_VRRP              112

#define ICMP_TYPE_ECHO_REPLY                0
#define ICMP_TYPE_ECHO_REQUEST              8

#endif
