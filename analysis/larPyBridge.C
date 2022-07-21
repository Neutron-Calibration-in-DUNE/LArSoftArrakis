/**
 * @file larPyBridge.C
 * @author Yashwanth Bezawada [ysbezawada@ucdavis.edu]
 * @brief 
 * Bridge between 
 * @version 0.1
 * @date 2022-07-12
 * Bridge between Arrakis and uproot/event display module
 * @copyright Copyright (c) 2022
 * 
 */
#include <TROOT.h>
#include <TChain.h>
#include <TFile.h>
#include <iostream>
#include <vector>
#include <map>

#include "TTree.h"
#include "TRandom.h"
#include "TSystem.h"

#include "TCanvas.h"
#include "TGraph.h"
#include "TFrame.h"
#include "TH2.h"
#include "TStyle.h"
#include "TLine.h"
#include "TAxis.h"
#include "TColor.h"
#include "TAttMarker.h"

std::vector<int> *u1_tdc = 0;
std::vector<int> *u1_channel = 0;
std::vector<int> *u1_adc = 0;
std::vector<int> *u1_trackID = 0;
std::vector<int> *u1_pdg_code = 0;

std::vector<int> *v1_tdc = 0;
std::vector<int> *v1_channel = 0;
std::vector<int> *v1_adc = 0;
std::vector<int> *v1_trackID = 0;
std::vector<int> *v1_pdg_code = 0;

std::vector<int> *z1_tdc = 0;
std::vector<int> *z1_channel = 0;
std::vector<int> *z1_adc = 0;
std::vector<int> *z1_trackID = 0;
std::vector<int> *z1_pdg_code = 0;

std::vector<int> *u2_tdc = 0;
std::vector<int> *u2_channel = 0;
std::vector<int> *u2_adc = 0;
std::vector<int> *u2_trackID = 0;
std::vector<int> *u2_pdg_code = 0;

std::vector<int> *v2_tdc = 0;
std::vector<int> *v2_channel = 0;
std::vector<int> *v2_adc = 0;
std::vector<int> *v2_trackID = 0;
std::vector<int> *v2_pdg_code = 0;

std::vector<int> *z2_tdc = 0;
std::vector<int> *z2_channel = 0;
std::vector<int> *z2_adc = 0;
std::vector<int> *z2_trackID = 0;
std::vector<int> *z2_pdg_code = 0;

void reserArrays(){
    u1_tdc->clear();
    u1_channel->clear();
    u1_adc->clear();
    u1_trackID->clear();
    u1_pdg_code->clear();

    v1_tdc->clear();
    v1_channel->clear();
    v1_adc->clear();
    v1_trackID->clear();
    v1_pdg_code->clear();

    z1_tdc->clear();
    z1_channel->clear();
    z1_adc->clear();
    z1_trackID->clear();
    z1_pdg_code->clear();

    u2_tdc->clear();
    u2_channel->clear();
    u2_adc->clear();
    u2_trackID->clear();
    u2_pdg_code->clear();

    v2_tdc->clear();
    v2_channel->clear();
    v2_adc->clear();
    v2_trackID->clear();
    v2_pdg_code->clear();

    z2_tdc->clear();
    z2_channel->clear();
    z2_adc->clear();
    z2_trackID->clear();
    z2_pdg_code->clear();
}

int getTrackID(std::vector<int> trackID_vec, std::vector<double> energy_vec){
    int track_id = 0;
    double track_energy;
    int track_index = 0;
    track_energy = energy_vec[0];
    for (int i = 0; i < energy_vec.size(); i++)
    {
        if (energy_vec[i] > track_energy)
        {
            track_energy = energy_vec[i];
            track_index = i;
        }
    }
    track_id = trackID_vec[track_index];
    return track_id;
}

void larPyBridge() {

    TTree* arrayTree;
    TTree* mapTree;

    std::vector<int> *u1_temp_tdc = 0;
    std::vector<int> *u1_temp_channel = 0;
    std::vector<int> *u1_temp_adc = 0;
    std::vector<std::vector<int> > * u1_track_ids = 0;
    std::vector<std::vector<double> > * u1_energy = 0;

    std::vector<int> *v1_temp_tdc = 0;
    std::vector<int> *v1_temp_channel = 0;
    std::vector<int> *v1_temp_adc = 0;
    std::vector<std::vector<int> > * v1_track_ids = 0;
    std::vector<std::vector<double> > * v1_energy = 0;

    std::vector<int> *z1_temp_tdc = 0;
    std::vector<int> *z1_temp_channel = 0;
    std::vector<int> *z1_temp_adc = 0;
    std::vector<std::vector<int> > * z1_track_ids = 0;
    std::vector<std::vector<double> > * z1_energy = 0;

    std::vector<int> *u2_temp_tdc = 0;
    std::vector<int> *u2_temp_channel = 0;
    std::vector<int> *u2_temp_adc = 0;
    std::vector<std::vector<int> > * u2_track_ids = 0;
    std::vector<std::vector<double> > * u2_energy = 0;

    std::vector<int> *v2_temp_tdc = 0;
    std::vector<int> *v2_temp_channel = 0;
    std::vector<int> *v2_temp_adc = 0;
    std::vector<std::vector<int> > * v2_track_ids = 0;
    std::vector<std::vector<double> > * v2_energy = 0;

    std::vector<int> *z2_temp_tdc = 0;
    std::vector<int> *z2_temp_channel = 0;
    std::vector<int> *z2_temp_adc = 0;
    std::vector<std::vector<int> > * z2_track_ids = 0;
    std::vector<std::vector<double> > * z2_energy = 0;

    std::map<int, int> * temp_AncestorPDGMap = 0;

    gInterpreter->GenerateDictionary("vector<vector<int> >", "vector");
    gInterpreter->GenerateDictionary("vector<vector<double> >", "vector");
    gInterpreter->GenerateDictionary("map<int, int>", "map");

    //Opening the root file
   	TFile *f1 = (TFile*)gROOT->GetListOfFiles()->FindObject("arrakis_output_0.root");
    if (!f1 || !f1->IsOpen()) {
       f1 = new TFile("arrakis_output_0.root", "READ");
    }

	TDirectory * dir1 = (TDirectory*)f1->Get("arrakis_output_0.root:/ana");
    dir1->GetObject("Array_Tree", arrayTree); //Array Tree
    dir1->GetObject("Map_Tree", mapTree); //Map Tree

    arrayTree->SetBranchAddress("u1_tdc", &u1_temp_tdc);
	arrayTree->SetBranchAddress("u1_channel", &u1_temp_channel);
	arrayTree->SetBranchAddress("u1_adc", &u1_temp_adc);
	arrayTree->SetBranchAddress("u1_track_ids", &u1_track_ids);
    arrayTree->SetBranchAddress("u1_energy", &u1_energy);

    arrayTree->SetBranchAddress("v1_tdc", &v1_temp_tdc);
	arrayTree->SetBranchAddress("v1_channel", &v1_temp_channel);
	arrayTree->SetBranchAddress("v1_adc", &v1_temp_adc);
	arrayTree->SetBranchAddress("v1_track_ids", &v1_track_ids);
    arrayTree->SetBranchAddress("v1_energy", &v1_energy);

    arrayTree->SetBranchAddress("z1_tdc", &z1_temp_tdc);
	arrayTree->SetBranchAddress("z1_channel", &z1_temp_channel);
	arrayTree->SetBranchAddress("z1_adc", &z1_temp_adc);
	arrayTree->SetBranchAddress("z1_track_ids", &z1_track_ids);
    arrayTree->SetBranchAddress("z1_energy", &z1_energy);

    arrayTree->SetBranchAddress("u2_tdc", &u2_temp_tdc);
	arrayTree->SetBranchAddress("u2_channel", &u2_temp_channel);
	arrayTree->SetBranchAddress("u2_adc", &u2_temp_adc);
	arrayTree->SetBranchAddress("u2_track_ids", &u2_track_ids);
    arrayTree->SetBranchAddress("u2_energy", &u2_energy);

    arrayTree->SetBranchAddress("v2_tdc", &v2_temp_tdc);
	arrayTree->SetBranchAddress("v2_channel", &v2_temp_channel);
	arrayTree->SetBranchAddress("v2_adc", &v2_temp_adc);
	arrayTree->SetBranchAddress("v2_track_ids", &v2_track_ids);
    arrayTree->SetBranchAddress("v2_energy", &v2_energy);

    arrayTree->SetBranchAddress("z2_tdc", &z2_temp_tdc);
	arrayTree->SetBranchAddress("z2_channel", &z2_temp_channel);
	arrayTree->SetBranchAddress("z2_adc", &z2_temp_adc);
	arrayTree->SetBranchAddress("z2_track_ids", &z2_track_ids);
    arrayTree->SetBranchAddress("z2_energy", &z2_energy);

    mapTree->SetBranchAddress("AncestorPDGMap", &temp_AncestorPDGMap);

    Long64_t Events = arrayTree->GetEntriesFast();

    /////////////////////////////////////////////////////////////////////////////////////

    TFile *f = new TFile("larPyBridge_output.root","recreate");
    TTree *array_tree = new TTree("array_tree","larPyBridge output tree");
    array_tree->Branch("u1_tdc", &u1_tdc);
    array_tree->Branch("u1_channel", &u1_channel);
	array_tree->Branch("u1_adc", &u1_adc);
    array_tree->Branch("u1_trackID", &u1_trackID);
	array_tree->Branch("u1_pdg_code", &u1_pdg_code);

    array_tree->Branch("v1_tdc", &v1_tdc);
    array_tree->Branch("v1_channel", &v1_channel);
	array_tree->Branch("v1_adc", &v1_adc);
    array_tree->Branch("v1_trackID", &v1_trackID);
	array_tree->Branch("v1_pdg_code", &v1_pdg_code);

    array_tree->Branch("z1_tdc", &z1_tdc);
    array_tree->Branch("z1_channel", &z1_channel);
	array_tree->Branch("z1_adc", &z1_adc);
    array_tree->Branch("z1_trackID", &z1_trackID);
	array_tree->Branch("z1_pdg_code", &z1_pdg_code);

    array_tree->Branch("u2_tdc", &u2_tdc);
    array_tree->Branch("u2_channel", &u2_channel);
	array_tree->Branch("u2_adc", &u2_adc);
    array_tree->Branch("u2_trackID", &u2_trackID);
	array_tree->Branch("u2_pdg_code", &u2_pdg_code);

    array_tree->Branch("v2_tdc", &v2_tdc);
    array_tree->Branch("v2_channel", &v2_channel);
	array_tree->Branch("v2_adc", &v2_adc);
    array_tree->Branch("v2_trackID", &v2_trackID);
	array_tree->Branch("v2_pdg_code", &v2_pdg_code);

    array_tree->Branch("z2_tdc", &z2_tdc);
    array_tree->Branch("z2_channel", &z2_channel);
	array_tree->Branch("z2_adc", &z2_adc);
    array_tree->Branch("z2_trackID", &z2_trackID);
	array_tree->Branch("z2_pdg_code", &z2_pdg_code);

    for (int i=0; i< Events;i++) { //Loop over Events

        reserArrays();

		arrayTree->GetEntry(i);
        mapTree->GetEntry(i);

        std::map<int, int> AncestorPDGMap;
        AncestorPDGMap = *temp_AncestorPDGMap;

		for(int j = 0; j< (int) u1_temp_tdc->size(); j++){ //Loop over the vector

            if(u1_track_ids->at(j).empty() == 0 && u1_energy->at(j).empty() == 0){

                u1_tdc->emplace_back(u1_temp_tdc->at(j));
                u1_channel->emplace_back(u1_temp_channel->at(j));
                u1_adc->emplace_back(u1_temp_adc->at(j));
                int temp_trackID = getTrackID(u1_track_ids->at(j), u1_energy->at(j));
                u1_trackID->emplace_back( temp_trackID );
                u1_pdg_code->emplace_back( (AncestorPDGMap[temp_trackID]) );
            }
		}

        for(int j = 0; j< (int) v1_temp_tdc->size(); j++){ //Loop over the vector

            if(v1_track_ids->at(j).empty() == 0 && v1_energy->at(j).empty() == 0){

                v1_tdc->emplace_back(v1_temp_tdc->at(j));
                v1_channel->emplace_back(v1_temp_channel->at(j));
                v1_adc->emplace_back(v1_temp_adc->at(j));
                int temp_trackID = getTrackID(v1_track_ids->at(j), v1_energy->at(j));
                v1_trackID->emplace_back( temp_trackID );
                v1_pdg_code->emplace_back( (AncestorPDGMap[temp_trackID]) );
            }
		}

        for(int j = 0; j< (int) z1_temp_tdc->size(); j++){ //Loop over the vector

            if(z1_track_ids->at(j).empty() == 0 && z1_energy->at(j).empty() == 0){

                z1_tdc->emplace_back(z1_temp_tdc->at(j));
                z1_channel->emplace_back(z1_temp_channel->at(j));
                z1_adc->emplace_back(z1_temp_adc->at(j));
                int temp_trackID = getTrackID(z1_track_ids->at(j), z1_energy->at(j));
                z1_trackID->emplace_back( temp_trackID );
                z1_pdg_code->emplace_back( (AncestorPDGMap[temp_trackID]) );
            }
		}

        for(int j = 0; j< (int) u2_temp_tdc->size(); j++){ //Loop over the vector

            if(u2_track_ids->at(j).empty() == 0 && u2_energy->at(j).empty() == 0){

                u2_tdc->emplace_back(u2_temp_tdc->at(j));
                u2_channel->emplace_back(u2_temp_channel->at(j));
                u2_adc->emplace_back(u2_temp_adc->at(j));
                int temp_trackID = getTrackID(u2_track_ids->at(j), u2_energy->at(j));
                u2_trackID->emplace_back( temp_trackID );
                u2_pdg_code->emplace_back( (AncestorPDGMap[temp_trackID]) );
            }
		}

        for(int j = 0; j< (int) v2_temp_tdc->size(); j++){ //Loop over the vector

            if(v2_track_ids->at(j).empty() == 0 && v2_energy->at(j).empty() == 0){

                v2_tdc->emplace_back(v2_temp_tdc->at(j));
                v2_channel->emplace_back(v2_temp_channel->at(j));
                v2_adc->emplace_back(v2_temp_adc->at(j));
                int temp_trackID = getTrackID(v2_track_ids->at(j), v2_energy->at(j));
                v2_trackID->emplace_back( temp_trackID );
                v2_pdg_code->emplace_back( (AncestorPDGMap[temp_trackID]) );
            }
		}

        for(int j = 0; j< (int) z2_temp_tdc->size(); j++){ //Loop over the vector

            if(z2_track_ids->at(j).empty() == 0 && z2_energy->at(j).empty() == 0){

                z2_tdc->emplace_back(z2_temp_tdc->at(j));
                z2_channel->emplace_back(z2_temp_channel->at(j));
                z2_adc->emplace_back(z2_temp_adc->at(j));
                int temp_trackID = getTrackID(z2_track_ids->at(j), z2_energy->at(j));
                z2_trackID->emplace_back( temp_trackID );
                z2_pdg_code->emplace_back( (AncestorPDGMap[temp_trackID]) );
            }
		}

        array_tree->Fill();
	}

    array_tree->Write();

    cout << "" << endl;

    cout << "No. events: " << Events << endl;
    //cout << "No. of Pixels " << u1_temp_tdc->size() << endl;

}