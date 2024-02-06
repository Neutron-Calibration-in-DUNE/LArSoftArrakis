# generate_neutrons_fdsp.py
"""
    Code for generating pions for neutron cross-section studies.
    Laura Pérez-Molina [laurapm@FNAL.GOV]   -   06/12/2023


"""
import os, sys
sys.path.append("../");
import numpy as np
from LArSoftArrakis.generator.pns_generator import *
# ; from lib import *

PGD_PION = 211      # PDG code for a pion
MassPion = 0.139570 # pion rest mass in GeV
EnerPion = 1.0      # pion energy in GeV
# 1x2x6 coordinates
# center of the active volume
x_center = 0
y_center = 0
z_center = 700
# ddg location
x_ddg = 355
y_ddg = 630
z_ddg = 60

output_dir = "../../inputs/protodune/"
if not os.path.isdir(output_dir): os.makedirs(output_dir)


def generate_ddg_pions(
    num_events:         int,
    num_pions:          int,
    x_pos:              int, 
    y_pos:              int,
    z_pos:              int,
    momentum_magnitude: float,
    output_file:        str,
) -> None:
    """
    Generate pions with momentum vectors pointing uniformly
    on a sphere of radius |p|.
    """
    events = []
    for i in range(num_events):
        px, py, pz = sample_spherical_mag(num_pions, momentum_magnitude) # generate mono-energtic momentum distribution
        events.append([str(i) + " " + str(len(px))]) # insert event header for HEPevt format
        for j in range(len(px)):
            energy = np.sqrt( px[j]**2 + py[j]**2 + pz[j]**2)
            hepevt_string = "1 "                        # particle status (final state)
            hepevt_string += str(PGD_PION) + " "        # pdg code
            hepevt_string += "0 0 0 0 "                 # 1st, 2nd mother and 1st, 2nd daughter
            hepevt_string += str(px[j]) + " "           # px in GeV
            hepevt_string += str(py[j]) + " "           # py in GeV
            hepevt_string += str(pz[j]) + " "           # pz in GeV
            hepevt_string += str(energy) + " "          # total energy (E^2 = m^2 + p^2)
            hepevt_string += str(MassPion) + " "        # mass of the pion
            hepevt_string += str(x_pos) + " "           # x position in G4 coordinates
            hepevt_string += str(y_pos) + " "           # y position in G4 coordinates
            hepevt_string += str(z_pos) + " "           # z position in G4 coordinates
            hepevt_string += "0"                        # production time (not needed)
            events.append([hepevt_string])
        # save output to a file
        with open(output_file,"w") as file:
            writer = csv.writer(file,delimiter="\t")
            writer.writerows(events)

if __name__ == "__main__":
    # DDG mono-energetic total energy
    # (same as the settings for protoDUNE)

    momentum_magnitude = 1.0 # GeV
    energy = np.sqrt(MassPion**2 + momentum_magnitude**2)
    x_pos = 180       
    y_pos = 350
    z_pos = 305     
    
    num_events = 10 # number of events to generate
    num_pions = 1   # number of pions to generate per event
    num_files = 1
    
    for ii in range(num_files):
        output_file = f"{output_dir}protodune_{num_events}_{num_pions}_{ii}.dat" # automatic output file name
        generate_ddg_pions(
            num_events, 
            num_pions, 
            momentum_magnitude, 
            x_pos, 
            y_pos, 
            z_pos, 
            output_file
        )

