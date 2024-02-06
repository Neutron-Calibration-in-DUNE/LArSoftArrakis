# generate_gammas_fdsp.py
"""
    Code for generating gammas for gamma calibration studies
    in the far detector.
    Nicholas Carrara [ncarrara.physics@gmail.com]   -   09/29/2021
"""
import os
import sys
import numpy as np
sys.path.append("../")
import LArSoftArrakis.generator.pns_generator as pns_generator
from LArSoftArrakis.generator.pns_generator import *
import gamma_generator
from gamma_generator import *
import argparse

# ProtoDUNE center 
x_center = 0
y_center = 0
z_center = 700

# ProtoDUNE DDG location
x_ddg = 355
y_ddg = 630
z_ddg = 60

# Rough center location of TPC2
x_center_TPC2 = 180.
y_center_TPC2 = 303.
z_center_TPC2 = 115.

output_dir = "../../inputs/protodune/"
#if not os.path.isdir(output_dir):
#    os.makedirs(output_dir)

parser = argparse.ArgumentParser(description='PNS generator')
parser.add_argument(
    '--num_runs', type=int, default=1,
    help='Number of runs to generate. Default value is 1.'
)
parser.add_argument(
    '--num_events', type=int, default=1,
    help='Number of events to generate. Default value is 1.'
)
parser.add_argument(
    '--num_gammas', type=int, default=1,
    help='Number of gammas per event to generate. Default value is 1450.'
)
parser.add_argument(
    '--momentum_magnitude', type=float, default=0.004745,
    help='Mono-energetic gamma momentum in [GeV]. Default value is ~0.004745 GeV.'
)
parser.add_argument(
    '--x_position', type=float, default=x_center_TPC2,
    help='x position of the gamma source in [cm]. Default value is 180 cm.'
)
parser.add_argument(
    '--y_position', type=float, default=y_center_TPC2,
    help='y position of the gamma source in [cm]. Default value is 303 cm.'
)
parser.add_argument(
    '--z_position', type=float, default=z_center_TPC2,
    help='z position of the gamma source in [cm]. Default value is 115 cm.'
)
parser.add_argument(
    '--output_dir', type=str, default='../../inputs/protodune/',
    help='Name of the output dir for this batch. Default value is "../../inputs/protodune/".'
)
parser.add_argument(
    '--output_file', type=str, default='protodune_ddg_gammas',
    help='Name of the output file for this batch. Default value is "protodune_ddg_gammas".'
)
parser.add_argument(
    '--plot_momentum_distribution', type=bool, default=False,
    help='Whether to plot the momentum distribution. Default value is False.'
)
parser.add_argument(
    '--check_momentum_magnitude', type=bool, default=False,
    help='Check for a disagreement between input momentum and energy. Default value is False.'
)

if __name__ == "__main__":

    args = parser.parse_args()
    num_runs = args.num_runs
    num_events = args.num_events
    num_gammas = args.num_gammas
    momentum_magnitude = args.momentum_magnitude
    x_position = args.x_position
    y_position = args.y_position
    z_position = args.z_position
    output_dir = args.output_dir
    output_file = args.output_file

    if not os.path.isdir(output_dir):
        os.makedirs(output_dir)
    
    for ii in range(num_runs):
        output = f"{output_dir}{output_file}_{num_events}_{num_gammas}_{momentum_magnitude}_{ii}.dat"
        gamma_generator.generate_ddg_gammas(
            num_events, 
            x_position, 
            y_position, 
            z_position, 
            False,
            num_gammas,
            momentum_magnitude,
            output
        )
