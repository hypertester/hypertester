#ifndef __HT_DEF_H__
#define __HT_DEF_H__

#define HT_PKT_TYPE_TMPL 0
#define HT_PKT_TYPE_POP_FIFO 1
#define TEMPLATE_NUM 256
#define FIFO_BUF_SIZE 256

#define MAX_LOOP_NUM 0
#define COLLECT1_TIME 1000

//DIP (10.1.0.1, 10.1.255.255, 1)
#define ipv4_dst_addr_RANGE_BEGIN (167837697-1)
#define ipv4_dst_addr_RANGE_END 167903231
#define ipv4_dst_addr_RANGE_STEP 1

//dp (1024, 65535, 1)
#define tcp_dst_port_RANGE_BEGIN (1023 -1)
#define tcp_dst_port_RANGE_END 65535
#define tcp_dst_port_RANGE_STEP 1




#define DELAY_LOW_BOUND 100
#define DELAY_RANGE 4096

#endif
