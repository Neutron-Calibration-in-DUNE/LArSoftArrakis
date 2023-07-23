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
import LArSoftArrakis.generator.pns_generator as pns_generator
from LArSoftArrakis.generator.pns_generator import *
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
    '--num_neutrons', type=int, default=1450,
    help='Number of neutrons per event to generate. Default value is 1450.'
)
parser.add_argument(
    '--momentum_magnitude', type=float, default=0.0685863,
    help='Mono-energetic neutron momentum in [GeV]. Default value is ~0.0685863 GeV.'
)
parser.add_argument(
    '--energy', type=float, default=np.sqrt(M_NEUTRON**2 + 0.0685863**2),
    help='Mono-energetic neutron energy in [GeV]. Default value is ~0.942 GeV.'
)
parser.add_argument(
    '--x_position', type=float, default=x_ddg,
    help='x position of the neutron source in [cm]. Default value is 355 cm.'
)
parser.add_argument(
    '--y_position', type=float, default=y_ddg,
    help='y position of the neutron source in [cm]. Default value is 630 cm.'
)
parser.add_argument(
    '--z_position', type=float, default=z_ddg,
    help='z position of the neutron source in [cm]. Default value is 60 cm.'
)
parser.add_argument(
    '--output_dir', type=str, default='../../inputs/protodune/',
    help='Name of the output dir for this batch. Default value is "../../inputs/protodune/".'
)
parser.add_argument(
    '--output_file', type=str, default='protodune_ddg',
    help='Name of the output file for this batch. Default value is "protodune_ddg".'
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
    num_neutrons = args.num_neutrons
    momentum_magnitude = args.momentum_magnitude
    energy = args.energy
    x_position = args.x_position
    y_position = args.y_position
    z_position = args.z_position
    output_dir = args.output_dir
    output_file = args.output_file
    plot_momentum_distribution = args.plot_momentum_distribution
    check_momentum_magnitude = args.check_momentum_magnitude

    if not os.path.isdir(output_dir):
        os.makedirs(output_dir)
    
    for ii in range(num_runs):
        output = f"{output_dir}{output_file}_{num_events}_{num_neutrons}_{ii}.dat"
        pns_generator.generate_ddg_neutrons(
            num_events, 
            num_neutrons, 
            momentum_magnitude, 
            energy, 
            x_position, 
            y_position, 
            z_position, 
            output, 
            plot_momentum_distribution,
            check_momentum_magnitude
        )
