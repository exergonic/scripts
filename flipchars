#!/usr/bin/env python3
# -*- coding: UTF-8 -*-

from sys import stdin, stdout

pchars = "abcdefghijklmnopqrstuvwxyz,.?!'()[]{}"
fchars = "ɐqɔpǝɟƃɥıɾʞlɯuodbɹsʇnʌʍxʎz'˙¿¡,)(][}{"
flipper = dict(zip(pchars, fchars))


def flip(s):
    charList = [flipper.get(x, x) for x in s.lower()]
    charList.reverse()
    return "".join(charList)

stdout.write("{}".format(flip(stdin.read())))
