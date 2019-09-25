#ifndef _TARGET_H_
#define _TARGET_H_

#define eg_input_port standard_metadata.ingress_port
#define eg_output_port  standard_metadata.egress_port

#define ig_input_port standard_metadata.ingress_port
#define ig_output_port  standard_metadata.egress_spec

//#define ig_ts standard_metadata.ingress_global_timestamp
#define ig_ts intrinsic_metadata.ingress_global_timestamp
#define eg_ts standard_metadata.egress_global_timestamp

#define packet_instance standard_metadata.instance_type 
#define PKT_INSTANCE_TYPE_NORMAL 0
#define PKT_INSTANCE_TYPE_INGRESS_CLONE 1
#define PKT_INSTANCE_TYPE_EGRESS_CLONE 2
#define PKT_INSTANCE_TYPE_COALESCED 3
#define PKT_INSTANCE_TYPE_INGRESS_RECIRC 4
#define PKT_INSTANCE_TYPE_REPLICATION 5
#define PKT_INSTANCE_TYPE_RESUBMIT 6


#endif
