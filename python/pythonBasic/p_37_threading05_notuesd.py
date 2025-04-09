#!/usr/bin/env python
import threading


def exeample():
    for _ in range(1, 10):
        print(_)

threading.Thread(target=exeample).start()
threading.Thread(target=exeample).start()