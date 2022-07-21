"""
"""
import numpy as np
from matplotlib import pyplot as plt
import uproot
from sklearn.cluster import DBSCAN
from sklearn.metrics import adjusted_rand_score

def print_details(input_file):
    f = uproot.open(input_file)
    for key in f.keys():
        for item in f[key]:
            try:
                print(f"{key}-{item}: {item.array(library='np')[0]}")
            except:
                print(f"{key}-{item}")


def plot_u1(input_file, event):
    f = uproot.open(input_file)['ana/Array_Tree'].arrays(library="np")
    u1_tdc = f['u1_tdc'][event]
    u1_channel = f['u1_channel'][event]
    u1_adc = f['u1_adc'][event]
    
    g = uproot.open(input_file)['ana/labels'].arrays(library="np")
    u1_gamma_id = g['u1_gamma_id'][event]
    u1_gamma_type = g['u1_gamma_type'][event]
    u1_ancestor_pdg = g['u1_ancestor_pdg'][event]
    u1_ancestor_id = g['u1_ancestor_id'][event]

    unique_track_ids = np.unique(u1_gamma_id)
    unique_gamma_type = np.unique(u1_gamma_type)
    unique_pdg = np.unique(u1_ancestor_pdg)
    unique_ancestor_id = np.unique(u1_ancestor_id)

    fig, axs = plt.subplots(figsize=(15,10))
    # for unique in unique_pdg:
    #     if unique != 0:
    #         temp_channel = u1_channel[(u1_pdg == unique)]
    #         temp_tdc = u1_tdc[(u1_pdg == unique)]
    #         temp_adc = u1_adc[(u1_pdg == unique)]
    #         axs.scatter(temp_channel, temp_tdc, s=temp_adc, label=f"{unique}")
    # for unique in unique_gamma_type:
    #     if unique != 0:
    #         temp_channel = u1_channel[(u1_gamma_type == unique)]
    #         temp_tdc = u1_tdc[(u1_gamma_type == unique)]
    #         temp_adc = u1_adc[(u1_gamma_type == unique)]
    #         axs.scatter(temp_channel, temp_tdc, s=temp_adc, label=f"{unique}")
    # for unique in unique_track_ids:
    #     if unique != -1:
    #         temp_channel = u1_channel[(u1_gamma_id == unique)]
    #         temp_tdc = u1_tdc[(u1_gamma_id == unique)]
    #         temp_adc = u1_adc[(u1_gamma_id == unique)]
    #         axs.scatter(temp_channel, temp_tdc, s=temp_adc, label=f"{unique}")
    for unique in unique_ancestor_id:
        if unique != -1:
            temp_channel = u1_channel[(u1_ancestor_id == unique)]
            temp_tdc = u1_tdc[(u1_ancestor_id == unique)]
            temp_adc = u1_adc[(u1_ancestor_id == unique)]
            axs.scatter(temp_channel, temp_tdc, s=temp_adc, c='k', label=f"{unique}")
    axs.set_xlabel("Channel")
    axs.set_ylabel("TDC")
    plt.legend(bbox_to_anchor=(1.05, 1.0), loc='upper left')
    plt.tight_layout()
    plt.show()

def dbscan(input_file, event, eps, min_samples):
    f = uproot.open(input_file)['ana/Array_Tree'].arrays(library="np")
    u1_tdc = f['u1_tdc'][event]
    u1_channel = f['u1_channel'][event]
    u1_adc = f['u1_adc'][event]
    
    g = uproot.open(input_file)['ana/labels'].arrays(library="np")
    u1_gamma_id = g['u1_gamma_id'][event]
    u1_gamma_type = g['u1_gamma_type'][event]
    u1_ancestor_pdg = g['u1_ancestor_pdg'][event]
    u1_ancestor_id = g['u1_ancestor_id'][event]

    unique_track_ids = np.unique(u1_gamma_id)
    unique_gamma_type = np.unique(u1_gamma_type)
    unique_pdg = np.unique(u1_ancestor_pdg)
    unique_ancestor_id = np.unique(u1_ancestor_id)

    X = np.vstack((u1_tdc,u1_channel)).T
    
    eps = np.linspace(1,100,100)
    scores = []
    for val in eps:
        clustering = DBSCAN(eps=val, min_samples=min_samples).fit(X)
        output = clustering.labels_
        scores.append(adjusted_rand_score(u1_ancestor_id, output))
    fig, axs = plt.subplots()
    axs.plot(eps, scores)
    plt.show()

    best_eps = eps[np.argmax(scores)]
    clustering = DBSCAN(eps=best_eps, min_samples=min_samples).fit(X)
    output = clustering.labels_
    unique_output = np.unique(output)

    fig, axs = plt.subplots(1,2,figsize=(15,10))
    for unique in unique_ancestor_id:
        if unique != -1:
            temp_channel = u1_channel[(u1_ancestor_id == unique)]
            temp_tdc = u1_tdc[(u1_ancestor_id == unique)]
            temp_adc = u1_adc[(u1_ancestor_id == unique)]
            axs[0].scatter(temp_channel, temp_tdc, s=temp_adc, label=f"{unique}")
    for unique in unique_output:
        temp_channel = u1_channel[(output == unique)]
        temp_tdc = u1_tdc[(output == unique)]
        temp_adc = u1_adc[(output == unique)]
        axs[1].scatter(temp_channel, temp_tdc, s=temp_adc, label=f"{unique}")
    axs[0].set_xlabel("Channel")
    axs[1].set_xlabel("Channel")
    axs[0].set_title("Ancestor Track ID")
    axs[1].set_title("DBSCAN labels")
    axs[0].set_ylabel("TDC")
    #axs[0].legend(bbox_to_anchor=(1.05, 1.0), loc='upper left')
    plt.tight_layout()
    plt.show()

if __name__ == "__main__":
    # print_details("../../arrakis_output_0.root")
    # plot_u1("../../arrakis_output_0.root", 0)
    dbscan("../../arrakis_output_0.root", 0, 100, 5)