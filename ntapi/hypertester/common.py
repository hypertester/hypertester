# Author: Dai Zhang


import re
def parse_p4_headers():
    d = {}
    with open('parser.p4', 'r') as f:
        data = ''.join(f.readlines())
    hdr_def = {hdr[1]:hdr[2] for hdr in [hdrline.strip(';').split() for hdrline in re.findall('header.*?;', data)]}
    with open('header.p4', 'r') as f:
        data = ''.join(f.readlines())
    for k in hdr_def.keys():
        hdr = re.findall(k+'.*?}',data, re.DOTALL)[0]
        for hdr_field in re.findall('.*?:.*?;', hdr):
            field, width = hdr_field.replace(';','').split(':')
            d[hdr_def[k]+'.'+field.strip()]=int(width)
    return d
# HEADER_FIELDS = parse_p4_headers()
# CONTRL_FIELDS = ["pktlen", "port", "loop", "postpone"] #interval, qid moved to trigger init

####
# Base Container
####

class emptyclass:
    idt_cnt = 0
    def __repr__(self):
        emptyclass.idt_cnt += 1
        out = '{\n'
        out += '\n'.join( ['\t'*emptyclass.idt_cnt + attr + ' : ' + repr(getattr(self, attr)) for attr in dir(self) if not callable(getattr(self, attr)) and not attr.startswith("__") and attr != 'idt_cnt'])
        emptyclass.idt_cnt -= 1
        out += '\n' + '\t'*emptyclass.idt_cnt + '}\n'
        return out


####
# Errors
####

class HTError(Exception):
    def __init__(self, message=None):
        self.message = message


class HTValueTypeError(HTError):
    pass


class HTTriggerError(HTError):
    pass


class HTQueryError(HTError):
    pass


class HTUtilError(HTError):
    pass


####
# Data Structures
####

## Tests
if __name__ == "__main__":
    # print(len(HEADER_FIELDS))
    # print(HEADER_FIELDS)

    a = emptyclass()
    a.a = 1
    a.b = 'hello'
    a.c = emptyclass()
    a.c.a = 1
    a.c.b = 'world'
    print(a)

    print( HTValue('CONSTANT', 100) )
    print( HTValue('ARRAY', [ 1, 2, 3, 4]) )
    print( HTValue('RANGE_ARRAY', (0, 100, 1)) )
    print( HTValue('RANDOM_ARRAY', ('Uniform', [1, 100], 2000)) )
    # negative tests
    # print( HTValue('RANDOM_ARRAY', 1, 2) )
    # print( HTValue('abc', ('Uniform', [1, 100], 2000)) )
