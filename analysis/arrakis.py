"""
"""
import numpy as np
from matplotlib import pyplot as plt
import uproot

def print_details(input_file):
    f = uproot.open(input_file)
    for key in f.keys():
        for item in f[key]:
            print(f"{key}-{item}: {item.array(library='np')[0]}")


def plot_u1(input_file, event):
    f = uproot.open(input_file)['array_tree'].arrays(library="np")
    u1_tdc = f['u1_tdc'][event]
    u1_channel = f['u1_channel'][event]
    u1_adc = f['u1_adc'][event]
    u1_trackid = f['u1_trackID'][event]
    u1_pdg = f['u1_pdg_code'][event]

    unique_track_ids = np.unique(u1_trackid)

    fig, axs = plt.subplots(figsize=(15,10))
    for unique in unique_track_ids:
        temp_channel = u1_channel[(u1_trackid == unique)]
        temp_tdc = u1_tdc[(u1_trackid == unique)]
        temp_adc = u1_adc[(u1_trackid == unique)]
        axs.scatter(temp_channel, temp_tdc, label=f"{unique}")
    axs.set_xlabel("Channel")
    axs.set_ylabel("TDC")
    plt.legend(bbox_to_anchor=(1.05, 1.0), loc='upper left')
    plt.tight_layout()
    plt.show()

if __name__ == "__main__":
    print_details("../../larPyBridge_output.root")
    plot_u1("../../larPyBridge_output.root", 0)