#include "RunAction.hh"

#include "G4Run.hh"
#include "G4SystemOfUnits.hh"
#include "G4ios.hh"

#include <filesystem>
#include <iomanip>

RunAction::RunAction()
    : G4UserRunAction(),
      fZMin(-150.0 * um),
      fZMax(150.0 * um),
      fNBins(150) {
    fBinWidth = (fZMax - fZMin) / fNBins;
    fDepthEdep.assign(fNBins, 0.0);
}

RunAction::~RunAction() {
    CloseOutputFiles();
}

void RunAction::BeginOfRunAction(const G4Run*) {
    G4cout << "### Run started" << G4endl;
    std::fill(fDepthEdep.begin(), fDepthEdep.end(), 0.0);
    OpenOutputFiles();
}

void RunAction::EndOfRunAction(const G4Run*) {
    WriteDepthProfile();
    CloseOutputFiles();
    G4cout << "### Run ended" << G4endl;
}

void RunAction::RecordEventSummary(G4int eventID, G4double eventEdep) {
    if (fEventFile.is_open()) {
        fEventFile << eventID << "," << std::setprecision(12) << eventEdep / eV << "\n";
    }
}

void RunAction::AccumulateDepthEdep(G4double zGlobal, G4double edep) {
    if (edep <= 0.0) {
        return;
    }
    if (zGlobal < fZMin || zGlobal >= fZMax) {
        return;
    }

    const G4int bin = static_cast<G4int>((zGlobal - fZMin) / fBinWidth);
    if (bin >= 0 && bin < fNBins) {
        fDepthEdep[bin] += edep;
    }
}

void RunAction::RecordRecoilCandidate(const RecoilRecord& record) {
    if (!fRecoilFile.is_open()) {
        return;
    }

    fRecoilFile
        << record.eventID << ","
        << record.trackID << ","
        << record.parentID << ","
        << Sanitize(record.particleName) << ","
        << std::setprecision(12) << record.kineticEnergy / eV << ","
        << record.localStepEdep / eV << ","
        << record.x / um << ","
        << record.y / um << ","
        << record.z / um << ","
        << record.dirX << ","
        << record.dirY << ","
        << record.dirZ << ","
        << Sanitize(record.volumeName) << ","
        << Sanitize(record.materialName) << ","
        << Sanitize(record.creatorProcess) << ","
        << record.globalTime / ns
        << "\n";
}

void RunAction::OpenOutputFiles() {
    std::filesystem::create_directories("output");

    fEventFile.open("output/event_summary.csv", std::ios::out);
    fRecoilFile.open("output/recoil_candidates.csv", std::ios::out);

    if (fEventFile.is_open()) {
        fEventFile << "event_id,total_edep_eV\n";
    }

    if (fRecoilFile.is_open()) {
        fRecoilFile
            << "event_id,track_id,parent_id,particle_name,kinetic_energy_eV,edep_eV,"
            << "x_um,y_um,z_um,dir_x,dir_y,dir_z,volume_name,material_name,"
            << "creator_process,global_time_ns\n";
    }
}

void RunAction::CloseOutputFiles() {
    if (fEventFile.is_open()) {
        fEventFile.close();
    }
    if (fRecoilFile.is_open()) {
        fRecoilFile.close();
    }
}

void RunAction::WriteDepthProfile() {
    std::ofstream depthFile("output/depth_edep.csv", std::ios::out);
    if (!depthFile.is_open()) {
        return;
    }

    depthFile << "z_center_um,edep_eV\n";
    for (G4int i = 0; i < fNBins; ++i) {
        const G4double zCenter = fZMin + (i + 0.5) * fBinWidth;
        depthFile << std::setprecision(12) << zCenter / um << "," << fDepthEdep[i] / eV << "\n";
    }
}

std::string RunAction::Sanitize(const G4String& text) const {
    std::string out = text;
    for (auto& c : out) {
        if (c == ',') {
            c = ';';
        }
    }
    return out;
}
