def return_interval(string, delim1, delim2):
    '''
    Return the range in a string that is delimited by delim1 and delim2
    '''

    return (string.find(delim1), string.find(delim2) - 1)


###############################################################################

'''
creating translation tables for characters
'''

trans_table = str.maketrans("abc", "def")
result = "aabbcc".translate(trans_table)
# >>> print(result)
#     → "ddeeff"

# to remove certain characters
trans_table = str.maketrans('abcde', '     ')
value = 'abcdefg'
value.translate(trans_table)
    
trans_table = str.maketrans("78", "12", "9")
# 7 and 8 are translated to 1 and 2. 9 is translated to None
value = "123456789"
result = value.translate(trans_table)
# >>> print(result)
#     → 12345612    # 9 has been removed

###############################################################################

# very simple webserver

python -m http.server [port]

########################################################################

# Class

class Dog:

    kind = 'canine'

    def __init__(self, name):
        self.name = name

########################################################################

# returning a closure
# or "factory of functions"

def addn(n):
    return lambda x: x + n

add1 = addn(1)
add1(2)
>>> 3

addn(1)(2)
>>> 3

########################################################################

# Closure

define startat(x):
    define incrementby(y):
        return x + y
    return incrementby

>> closure1 = startat(1)
>> closure2 = startat(5)

>> closure1(3)
4

>> closure2(5)
10

########################################################################
