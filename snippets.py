def return_interval(string, delim1, delim2):
    '''
    Return the range in a string that is delimited by delim1 and delim2
    '''

    return (string.find(delim1), string.find(delim2) - 1)

'''
creating translation tables for characters
'''

trans_table = str.maketrans("abc", "def")
result = "aabbcc".translate(trans_table)
'''
>>> print(result)
"ddeeff"
'''

# to remove certain characters
trans_table = str.maketrans('abcde', '     ')
value = 'abcdefg'
value.translate(trans_table)

'''
>>> print(value)
'     fg'
'''

#
trans_table = str.maketrans("78", "12", "9")
# 7 and 8 are translated to 1 and 2. 9 is translated to None
value = "123456789"
result = value.translate(trans_table)

'''
>>> print(result)
12345612    # 9 has been removed
'''


# Very simple webserver ~~~~~~~~~~~~~~~~~~~~
'''
>>> python -m http.server [port]
'''


# Classes ~~~~~~~~~~~~~~~~~~~~

class Dog:
    kind = 'canine'

    def __init__(self, name):
        self.name = name

# Higher order functions~~~~~~~~~~~~~~~

# returning a closure
# or "factory of functions"


def addn(n):
    return lambda x: x + n

'''
>>> add1 = addn(1)
>>> add1(2)
3
>>> addn(1)(2)
3
'''

# closures ~~~~~~~~~~~~~~~~~~~~


def startat(x):
    def incrementby(y):
        return x + y
    return incrementby

'''
>>> closure1 = startat(1)
>>> closure2 = startat(5)
>>> closure1(3)
4
>>> closure2(5)
10
'''

# Accumulator generator~~~~~~~~~~~~~~~~~~~~


class foo:
    # using a class
    def __init__(self, n):
        self.n = n

    def __call__(self, i):
        self.n = i + n

'''
>>> a = foo(1)
>>> a(2)
3
>>> a(5)
8
>>> a(12)
20
'''


def foo(n):
    # using a function
    def innerfoo(i):
        nonlocal n
        n += i
        return n
    return innerfoo
'''
>>> a = foo(2)
>>> a(4)
6
>>> a(10)
16
>>> a(4)
20
'''

"""
zip

>>> list(zip("abcd", "123"))
[('a', '0'), ('b', '1'), ('c', '2'), ('d', '3')]
"""

"""
compress: takes a list and maps it onto a truth list

>>> list(compress("ABCD", "1010"))
['A', 'B', 'C', 'D']
"""
