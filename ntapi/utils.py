from hypertester.common import *

def generate_uid(*args):
    if args[0] == 'replicator':
        return args[1]
    elif args[0] == "editor":
        return args[1]+'_'+args[2].replace('.','_')
    elif args[0] == "query":
        generate_uid.qry_cnt += 1
        return args[0] + '_' + str(generate_uid.qry_cnt)
    elif args[0] == "filter":
        generate_uid.fl_cnt += 1
        return args[0] + '_' + str(generate_uid.fl_cnt)
    elif args[0] == "distinct":
        generate_uid.ds_cnt += 1
        return args[0] + '_' + str(generate_uid.ds_cnt)
    elif args[0] == "reduce":
        generate_uid.rdc_cnt += 1
        return args[0] + '_' + str(generate_uid.rdc_cnt)
    elif args[0] == "fifo":
        generate_uid.fifo_cnt += 1
        return args[0] + '_' + str(generate_uid.fifo_cnt)
generate_uid.qry_cnt = 0
generate_uid.fl_cnt = 0
generate_uid.ds_cnt = 0
generate_uid.rdc_cnt = 0
generate_uid.fifo_cnt = 0

def inverse_transform(ht_val = None, cdf = None):
    """
        return slices=[...], each slice has member {low, high, low_value_bound, high_value_bound}
        cdf^-1 ( x / 65536 )
    """
    slices = []
    if ht_val:
        name, params, size = ht_val
        #print(name, params, size)
        if name == "Uniform":
            s = emptyclass()
            s.low = 0
            s.high = 65535
            s.low_value_bound, s.high_value_bound = params
            slices.append(s)
        elif name == "Gaussian":
            pass
    elif cdf:
        #TODO: support for cdf samples
        pass
    else:
        raise HTUtilError("inverse transform should take an argument of HTValue or cdf.")
    return slices

def calc_hash_collision():
    pass

if __name__ == "__main__":
    print(generate_uid("editor", "CONSTANT", "ipv4.srcIP"))
    print(generate_uid("editor", "ARRAY", "ipv4.srcIP"))
    print(generate_uid("editor", "RANGE_ARRAY", "ipv4.srcIP"))
    print(generate_uid("editor", "RANDOM_ARRAY", "ipv4.srcIP"))
    print(generate_uid("filter"))
    print(generate_uid("filter"))
    print(generate_uid("filter"))
    print(generate_uid("filter"))

