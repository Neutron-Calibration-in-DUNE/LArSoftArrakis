# generate_neutrons_fdsp.py
"""
    Code for generating neutrons for neutron calibration studies
    in the far detector.
    Nicholas Carrara [ncarrara.physics@gmail.com]   -   09/29/2021
"""
import numpy as np
#import matplotlib.pyplot as plt
#from mpl_toolkits.mplot3d import axes3d
import csv

# PDG code for different particles
pdg_map = {
    11:     "electron",
    -11:    "positron",
    12:     "electron_neutrino",
    -12:    "anti-electron_neutrino",
    13:     "muon",
    -13:    "anti-muon",
    14:     "muon_neutrino",
    -14:    "anti-muon_neutrino",
    15:     "tauon",
    -15:    "anti-tauon",
    16:     "tauon_neutrino",
    -16:    "anti-tauon_neutrino",
    22:     "gamma",
    111:    "pion0",
    211:    "pion_plus",
    -211:   "pion_minus",
    311:    "kaon0",
    321:    "kaon_plus",
    -321:   "kaon_minus",
    2112:   "neutron",
    -2112:  "anti-neutron",
    2212:   "proton",
    -2212:  "anti-proton",
    1000010020: "deuteron",
    1000010030: "triton",
    1000020040: "alpha"
}
pdg_mass = {
    11:     0.000510998,
    -11:    0.000510998,
    12:     1e-9,
    -12:    1e-9,
    13:     0.105658,
    -13:    0.105658,
    14:     1e-9,
    -14:    1e-9,
    15:     1.77686,
    -15:    1.77686,
    16:     1e-9,
    -16:    1e-9,
    22:     0.0,
    111:    0.134976,
    211:    0.139570,
    -211:   0.139570,
    311:    0.497611,
    321:    0.493677,
    -321:   0.493677,
    2112:   0.939565,
    -2112:  0.939565,
    2212:   0.938272,
    -2212:  0.938272,
    1000010020:     1.875,
    1000010030:     2.80892,
    1000020040:     3.72737
}

def momentum_mag(
    energy: float,
    mass:   float
):
    if energy**2 < mass**2:
        return mass
    return np.sqrt(energy**2 - mass**2)

def generate_hepevt(
    pdg:    int,
    px:     float,
    py:     float,
    pz:     float,
    energy: list=[],
    x_position: int=0, 
    y_position: int=0,
    z_position: int=0,
    output_file:    str='hepevt.dat',
) -> None:
    """
    Generate hepevt style dat file with len(energy) events, each
    event contains a single particle denoted by the pdg label,
    whose momentum is determined by the energy and mass.
    """
    events = []
    for ii in range(len(energy)):
        # insert event header for HEPevt format
        events.append([str(ii+1) + " 1"])
        # compute momentum magnitude
        momentum_norm = np.sqrt(px*px + py*py + pz*pz)
        momentum = momentum_mag(energy[ii], pdg_mass[pdg]) / momentum_norm

        hepevt_string = "1 "                        # particle status (final state)
        hepevt_string += str(pdg) + " "             # pdg code
        hepevt_string += "0 0 0 0 "                 # 1st, 2nd mother and 1st, 2nd daughter
        hepevt_string += str(px) + " "   # px in GeV
        hepevt_string += str(py) + " "   # py in GeV
        hepevt_string += str(pz) + " "   # pz in GeV
        hepevt_string += str(energy[ii]) + " "      # total energy (E^2 = m^2 + p^2)
        hepevt_string += str(pdg_mass[pdg]) + " "   # mass in GeV
        hepevt_string += str(x_position) + " "      # x position in G4 coordinates
        hepevt_string += str(y_position) + " "      # y position in G4 coordinates
        hepevt_string += str(z_position) + " "      # z position in G4 coordinates
        hepevt_string += "0"                        # production time (not needed)
        events.append([hepevt_string])

    # save output to a file
    with open(output_file,"w") as file:
        writer = csv.writer(file, delimiter="\t")
        writer.writerows(events)