#include "common/common.p4"
#include "hypertester/trigger.p4"
#include "hypertester/query.p4"


control ingress {
	trigger_ingress();
	query_ingress;
}

control egress {
	trigger_egress();
	query_egress();
}
