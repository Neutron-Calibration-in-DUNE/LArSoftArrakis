# generate_neutrons_fdsp.py
"""
    Code for generating neutrons for neutron calibration studies
    in the far detector.
    Nicholas Carrara [ncarrara.physics@gmail.com]   -   09/29/2021
"""
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import axes3d
import csv

# PDG code for a neutron
PDG_NEUTRON         = 2112
# neutron rest mass in GeV
M_NEUTRON           = .939565
# DDG mono-energetic total energy
MONO_E_NEUTRON      = .942065
# magnitude for protoDUNE run 1 DDG study
P_MAG_PROTODUNE_DDG = 0.0685863
# position for protoDUNE run 1 DDG study
X_POS_PROTODUNE_DDG = 355   #cm
Y_POS_PROTODUNE_DDG = 630   #cm
Z_POS_PROTODUNE_DDG = 60    #cm

# position for protoDUNE run 1 DDG study
X_POS_DUNE10kt_1x2x6_DDG = 600      #cm
Y_POS_DUNE10kt_1x2x6_DDG = 700      #cm
Z_POS_DUNE10kt_1x2x6_DDG = 2910     #cm

def sample_spherical_unit(
    num_events:         int,
):
    """
    Generate "num_events" random points on the unit sphere
    """
    vecs = np.random.randn(3, num_events)
    vecs /= np.linalg.norm(vecs, axis=0)
    return vecs

def sample_spherical_mag(
    num_events:         int,
    magnitude:          float,
):
    """
    Generate "num_events" random points on a sphere of radius
    "magnitude"
    """
    assert magnitude > 0., "Magnitude must be greater than 0.!"

    vecs = np.random.randn(3, num_events)
    vecs /= np.linalg.norm(vecs, axis=0)
    vecs *= magnitude
    return vecs

def generate_ddg_neutrons(
    num_events:         int,
    num_neutrons:       int,
    momentum_magnitude: float,
    energy:             float,
    x_position:              int, 
    y_position:              int,
    z_position:              int,
    output_file:        str,
    plot_momentum_distribution:          bool=False,
    check_momentum_magnitude:         bool=False,
) -> None:
    """
    Generate neutrons with momentum vectors pointing uniformly
    on a sphere of radius |p|.
    """
    delta_E = (energy - np.sqrt(M_NEUTRON**2 + momentum_magnitude**2))
    print(f"Generating {num_events} event(s) with {num_neutrons} neutron(s) each.")
    print("Value of input energy:     ", energy)
    print("Value of sqrt(p^2 + m^2):  ", np.sqrt(M_NEUTRON**2 + momentum_magnitude**2))
    print("Difference:                ", delta_E)
    events = []
    for i in range(num_events):
        # insert event header for HEPevt format
        events.append([str(i+1) + " " + str(num_neutrons)])
        # generate mono-energtic momentum distribution
        px, py, pz = sample_spherical_mag(num_neutrons, momentum_magnitude)
        if check_momentum_magnitude:
            # check that the sum of px^2 + py^2 + pz^2 is equal to the 
            # desired magnitude
            delta_mag = np.abs(momentum_magnitude - np.sqrt(px*px + py*py + pz*pz))
            print("Difference in momentum magnitude for event-"+str(i)+": ",sum(delta_mag))
        for j in range(len(px)):
            hepevt_string = "1 "                        # particle status (final state)
            hepevt_string += str(PDG_NEUTRON) + " "     # pdg code (2112 for neutrons)
            hepevt_string += "0 0 0 0 "                 # 1st, 2nd mother and 1st, 2nd daughter
            hepevt_string += str(px[j]) + " "           # px in GeV
            hepevt_string += str(py[j]) + " "           # py in GeV
            hepevt_string += str(pz[j]) + " "           # pz in GeV
            hepevt_string += str(energy) + " "          # total energy (E^2 = m^2 + p^2)
            hepevt_string += str(M_NEUTRON) + " "       # mass (.93956563 for neutrons)
            hepevt_string += str(x_position) + " "           # x position in G4 coordinates
            hepevt_string += str(y_position) + " "           # y position in G4 coordinates
            hepevt_string += str(z_position) + " "           # z position in G4 coordinates
            hepevt_string += "0"                        # production time (not needed)
            events.append([hepevt_string])

        # make a plot
        if plot_momentum_distribution:
            phi = np.linspace(0, np.pi, 20)
            theta = np.linspace(0, 2*np.pi, 40)
            x = np.outer(np.sin(theta), np.cos(phi))*momentum_magnitude
            y = np.outer(np.sin(theta), np.sin(phi))*momentum_magnitude
            z = np.outer(np.cos(theta), np.ones_like(phi))*momentum_magnitude

            fig, axs = plt.subplots(1, 1, subplot_kw={'projection':'3d', 'aspect':'auto'},figsize=(10,10))
            axs.plot_wireframe(x, y, z, color='k', rstride=1, cstride=1)
            axs.scatter(px, py, pz ,c='r',zorder=10)
            axs.set_xlabel("p_x")
            axs.set_ylabel("p_y")
            axs.set_zlabel("p_z")
            axs.set_title("Neutron momentum distribution event-"+str(i))
            plt.savefig(output_file+"-event-"+str(i)+".png")

        # save output to a file
        with open(output_file,"w") as file:
            writer = csv.writer(file,delimiter="\t")
            writer.writerows(events)