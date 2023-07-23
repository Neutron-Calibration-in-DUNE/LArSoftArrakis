# generate_neutrons_fdsp.py
"""
    Code for generating neutrons for neutron calibration studies
    in the far detector.
    Nicholas Carrara [ncarrara.physics@gmail.com]   -   09/29/2021
"""
import os
import sys
import numpy as np
sys.path.append("../")
import hepevt_generator as hepevt_generator
from hepevt_generator import *
import argparse

# ProtoDUNE center 
x_center = 0
y_center = 0
z_center = 700

# ProtoDUNE DDG location
x_ddg = 355
y_ddg = 630
z_ddg = 60

output_dir = "../../inputs/protodune/"

if __name__ == "__main__":
    energies = [0.10, 0.25, 0.50, 1.00, 2.00, 3.00, 4.00, 5.00, 10.00, 20.00]
    pdgs = [11, -11, 13, -13, 15, -15, 22, 111, 211, -211, 311, 321, -321, 2112, 2212]
    for ii, pdg in enumerate(pdgs):
        hepevt_generator.generate_hepevt(
            pdg=pdg,
            px=0.0, 
            py=0.0, 
            pz=1.0,
            energy=energies,
            x_position=25, 
            y_position=25, 
            z_position=z_center,
            output_file=f'../../inputs/arrakis_tests/arrakis_test_{pdg_map[pdg]}.dat'
        )