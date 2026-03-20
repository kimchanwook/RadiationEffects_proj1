#include "RunAction.hh"

#include "G4Run.hh"
#include "G4SystemOfUnits.hh"
#include "G4ios.hh"

#include <filesystem>
#include <iomanip>

RunAction::RunAction()
    : G4UserRunAction(),
      fZMin(-150.0 * um),
      fZMax( 150.0 * um),
      fNBins(150)
{
    fBinWidth = (fZMax - fZMin) / fNBins;
    fDepthEdep.assign(fNBins, 0.0);
}

RunAction::~RunAction()
{
    CloseOutputFiles();
}

void RunAction::BeginOfRunAction(const G4Run*)
{
    G4cout << "### Run started" << G4endl;
    std::fill(fDepthEdep.begin(), fDepthEdep.end(), 0.0);
    OpenOutputFiles();
}

void RunAction::EndOfRunAction(const G4Run*)
{
    WriteDepthProfile();
    CloseOutputFiles();
    G4cout << "### Run ended" << G4endl;
}

void RunAction::RecordEventSummary(G4int eventID, G4double eventEdep)
{
    if (fEventFile.is_open()) {
        fEventFile << eventID << "," << std::setprecision(12) << eventEdep / eV << "\n";
    }
}

void RunAction::AccumulateDepthEdep(G4double zGlobal, G4double edep)
{
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

void RunAction::RecordRecoilCandidate(G4int eventID,
                                      G4double zGlobal,
                                      const G4String& particleName,
                                      G4double kineticEnergy)
{
    if (fRecoilFile.is_open()) {
        fRecoilFile << eventID << ","
                    << std::setprecision(12) << zGlobal / um << ","
                    << Sanitize(particleName) << ","
                    << kineticEnergy / eV << "\n";
    }
}

void RunAction::OpenOutputFiles()
{
    std::filesystem::create_directories("output");

    fEventFile.open("output/event_summary.csv", std::ios::out);
    fRecoilFile.open("output/recoil_candidates.csv", std::ios::out);

    if (fEventFile.is_open()) {
        fEventFile << "event_id,total_edep_eV\n";
    }

    if (fRecoilFile.is_open()) {
        fRecoilFile << "event_id,z_um,particle_name,kinetic_energy_eV\n";
    }
}

void RunAction::CloseOutputFiles()
{
    if (fEventFile.is_open()) {
        fEventFile.close();
    }
    if (fRecoilFile.is_open()) {
        fRecoilFile.close();
    }
}

void RunAction::WriteDepthProfile()
{
    std::ofstream depthFile("output/depth_edep.csv", std::ios::out);
    if (!depthFile.is_open()) {
        return;
    }

    depthFile << "z_center_um,edep_eV\n";
    for (G4int i = 0; i < fNBins; ++i) {
        const G4double zCenter = fZMin + (i + 0.5) * fBinWidth;
        depthFile << std::setprecision(12)
                  << zCenter / um << ","
                  << fDepthEdep[i] / eV << "\n";
    }
}

std::string RunAction::Sanitize(const G4String& text) const
{
    std::string out = text;
    for (auto& c : out) {
        if (c == ',') {
            c = ';';
        }
    }
    return out;
}
