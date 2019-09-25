#ifndef __HT_DEF_H__
#define __HT_DEF_H__

#define TEMPLATE_NUM 256

#define FIFO_BUF_SIZE 256

#define MAX_LOOP_NUM 1

//SIP (10.1.0.1, 10.1.255.255, 1)
#define ipv4_src_addr_RANGE_BEGIN (167837697-1)
#define ipv4_src_addr_RANGE_END 167903231
#define ipv4_src_addr_RANGE_STEP 1

//Sp (1024, 65535, 1)
#define tcp_src_port_RANGE_BEGIN (1023 -1)
#define tcp_src_port_RANGE_END 65535
#define tcp_src_port_RANGE_STEP 1

#define COLLECT1_TIME 1000

#define HT_ACC_PORT 1
#define HT_STATELESS_CONN1 2
#define HT_STATELESS_CONN2 3
#define HT_FIFO_POP_PORT 4
#endif
