#!/usr/bin/env python
from python.pythonBasic.class_animal import Animal


class Rectangle(Animal):
    count = 0

    def __init__(self, width, height):
        self.width = width
        self.height = height
        Rectangle.count += 1

    def __add__(self, other):
        obj = Rectangle(self.width + other.width, self.height + other.height)
        return obj

    def clacArea(self):
        area = self.width * self.height
        return area

    def isSquare(recWidth, recHeight):
        return recWidth == recHeight

    def printCount(cls):
        print(cls.count)