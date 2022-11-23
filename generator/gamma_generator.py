"""
    Code for generating gammas for single neutron calibration
    studies in ProtoDUNE.
    Yashwanth Bezawada [ysbezawada@ucdavis.edu]
"""
import os
import sys
sys.path.append("../")
import numpy as np
import csv

# PDG code for a Gamma
PDG_GAMMA           = 22
# x position for protoDUNE run 1 DDG study
X_POS_PROTODUNE_DDG = 355
# y position for protoDUNE run 1 DDG study
Y_POS_PROTODUNE_DDG = 630
# z position for protoDUNE run 1 DDG study
Z_POS_PROTODUNE_DDG = 60

################################################################ Gamma Cascade info
e_1 = 0.1673 #MeV
e_2 = 0.5161
e_3 = 1.0347
e_4 = 1.3539
e_5 = 2.3981
e_6 = 2.7334
e_18 = 6.0989

cascades = [
    [e_18-e_4, e_4-e_1, e_1],
    [e_18-e_2, e_2],
    [e_18-e_4, e_4-e_2, e_2],
    [e_18-e_5, e_5-e_4, e_4-e_1, e_1],
    [e_18-e_2, e_2-e_1, e_1],
    [e_18-e_4, e_4],
    [e_18-e_4, e_4-e_2, e_2-e_1, e_1],
    [e_18-e_5, e_5-e_2, e_2],
    [e_18-e_5, e_5-e_4, e_4-e_2, e_2],
    [e_18-e_5, e_5-e_1, e_1],
    [e_18-e_5, e_5-e_2, e_2-e_1, e_1],
    [e_18-e_5, e_5-e_4, e_4],
    [e_18-e_5, e_5-e_4, e_4-e_2, e_2-e_1, e_1],
    [e_18-e_3, e_3-e_1, e_1],
    [e_18-e_6, e_6-e_1, e_1]
]

# cas_prob = np.array([0.5836, 0.1193, 0.085, 0.081, 0.0317, 0.0258, 0.022, 0.0185, 0.0119, 0.0049, 0.0048, 0.0036, 0.003, 0.003, 0.001])
cas_prob = np.array([0.5836, 0.12, 0.085, 0.0811, 0.032, 0.026, 0.022, 0.018, 0.012, 0.0049, 0.0048, 0.0036, 0.003, 0.003, 0.001])
##################################################################################

output_dir = "../inputs/protodune/"
if not os.path.isdir(output_dir):
    os.makedirs(output_dir)

def sample_gamma_momentum(nCap: bool, gamma_E, numGammas = 1):
    if (nCap == True):
        """
        Determine the gamma cascade to generate, sample and return the gamma momentum
        """
        i = np.random.choice(np.arange(15), p=cas_prob)
        cas = np.array(cascades[i])
        num_gammas = len(cas)
        vecs = np.random.randn(3, num_gammas)
        vecs /= np.linalg.norm(vecs, axis=0)
        return vecs*cas*0.001 #converting into GeV
    else:
        """
        Generate "numGammas" random points on a sphere of radius
        "gamma_E" (in MeV)
        """
        gamma_mag = np.random.choice(gamma_E)
        assert gamma_mag > 0., "Magnitude must be greater than 0.!"

        vecs = np.random.randn(3, numGammas)
        vecs /= np.linalg.norm(vecs, axis=0)
        vecs *= gamma_mag
        return vecs*0.001 #converting into GeV


def generate_ddg_gammas(
    num_events:         int,
    x_pos:              int, 
    y_pos:              int,
    z_pos:              int,
    neutronCap:         bool,
    n_gammas:           int,
    momentum_magnitude: float,
    output_file:        str,
) -> None:
    """
    Generate gammas with momentum vectors pointing uniformly
    on a sphere of radius |p|.
    """
    events = []
    for i in range(num_events):
        # generate mono-energtic momentum distribution
        px, py, pz = sample_gamma_momentum(neutronCap, momentum_magnitude, n_gammas)
        # insert event header for HEPevt format
        events.append([str(i) + " " + str(len(px))])
        for j in range(len(px)):
            energy = np.sqrt( px[j]**2 + py[j]**2 + pz[j]**2)
            hepevt_string = "1 "                        # particle status (final state)
            hepevt_string += str(PDG_GAMMA) + " "       # pdg code (22 for gammas)
            hepevt_string += "0 0 0 0 "                 # 1st, 2nd mother and 1st, 2nd daughter
            hepevt_string += str(px[j]) + " "           # px in GeV
            hepevt_string += str(py[j]) + " "           # py in GeV
            hepevt_string += str(pz[j]) + " "           # pz in GeV
            hepevt_string += str(energy) + " "          # total energy (E^2 = m^2 + p^2)
            hepevt_string += "0 " + " "                 # mass of the gamma
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
    # x position
    x_pos = 180
    # y position
    y_pos = 350
    # z position
    z_pos = 305
    # number of events to generate
    num_events = 300
    # number of files to generate
    num_files = 1
    
    for ii in range(num_files):
        # output file name
        # output_file = f"{output_dir}PD_gamma_test_{num_events}_{ii}.dat"
        # generate_ddg_gammas(
        #     num_events,
        #     x_pos, 
        #     y_pos, 
        #     z_pos,
        #     False,
        #     0,
        #     [0],
        #     output_file,
        # )
        output_file = f"{output_dir}gamma_pointCloud_input_{num_events}_{ii}.dat"
        generate_ddg_gammas(
            num_events,
            x_pos, 
            y_pos, 
            z_pos,
            False,
            1,
            [4.745, 1.1866],
            output_file,
        )