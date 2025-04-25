#!/usr/bin/env python

def division_function(a, b):
    try:
        print(a/b)
    except TypeError as e:
        print(e)
    except ZeroDivisionError as e:
        print(e)

division_function(a="a", b=1)
division_function(a=1, b=0)
division_function(a=4, b=2)