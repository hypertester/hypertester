#ifndef __HT_DEF_H__
#define __HT_DEF_H__

#define TEMPLATE_NUM 256

#define MAX_LOOP_NUM 1000

//SIP (10.1.0.1, 10.1.255.255, 1)
#define ipv4_src_addr_RANGE_BEGIN (167837697-1)
#define ipv4_src_addr_RANGE_END 167903231
#define ipv4_src_addr_RANGE_STEP 1

//Sp (1024, 65535, 1)
#define tcp_src_port_RANGE_BEGIN (1023 -1)
#define tcp_src_port_RANGE_END 65535
#define tcp_src_port_RANGE_STEP 1

#endif
