#!/usr/bin/env python

def gcd(a, b):
    print("gcd", (a, b))
    while b != 0:
        r = a % b
        a = b
        b = r
    return a

a = int(input("Input first number: "))
b = int(input("Input second number: "))

print(gcd(a, b))
print(f'gcd({a},{b}) of {a}, {b} : {gcd(a, b)}')