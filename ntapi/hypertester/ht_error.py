# Author: Yu Zhou
# E-Mail: y-zhou16@mails.tsinghua.edu.cn


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

