####
# Definations
####

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
HEADER_FIELDS = parse_p4_headers()

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

class HTValueTypeError(HTError): pass
class HTTriggerError(HTError): pass
class HTUtilError(HTError): pass
class TriggerParamTypeError(HTError): pass
class TriggerSetListLengthNotMatchError(HTError): pass


####
# Data Structures
####

class HTValue:
    VALUE_TYPE = ['CONSTANT', 'ARRAY', 'RANGE_ARRAY', 'RANDOM_ARRAY']
    def __init__(self, *args, **kwargs):
        if len(args) != 2:
            raise HTValueTypeError("HTValue expects 2 argument but given " + str(len(args)))
        if args[0] not in HTValue.VALUE_TYPE:
            raise HTValueTypeError(repr(args[0]) + " is not a legal type for HTValue.")
        self.type = args[0]
        self.value = args[1]
        if self.type == "ARRAY" and not isinstance(self.value, list):
            raise HTValueTypeError("second arguement of ARRAY type HTValue must have a type of list.")
        if self.type == "RANGE_ARRAY" and ( not isinstance(self.value, tuple) or len(self.value) != 3 ) :
            raise HTValueTypeError("HTValue of RANGE_ARRAY takes (begin, stop, step) as value.")
    def __repr__(self):
        return self.type + ', ' + repr(self.value)


## Tests
if __name__ == "__main__":
    print(len(HEADER_FIELDS))
    print(HEADER_FIELDS)

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
