"""
"""
import numpy as np
import scipy as sp
from matplotlib import pyplot as plt
import uproot

def print_details(input_file):
    f = uproot.open(input_file)
    for key in f.keys():
        for item in f[key]:
            print(f"{key}-{item}: {item.array(library='np')[0]}")



if __name__ == "__main__":
    print_details("larPyBridge_output.root")