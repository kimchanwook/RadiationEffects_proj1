#ifndef RunAction_h
#define RunAction_h 1

#include "G4UserRunAction.hh"
#include "globals.hh"

#include <fstream>
#include <string>
#include <vector>

class G4Run;

struct RecoilRecord {
    G4int eventID = -1;
    G4int trackID = -1;
    G4int parentID = -1;
    G4String particleName;
    G4double kineticEnergy = 0.0;
    G4double localStepEdep = 0.0;
    G4double x = 0.0;
    G4double y = 0.0;
    G4double z = 0.0;
    G4double dirX = 0.0;
    G4double dirY = 0.0;
    G4double dirZ = 0.0;
    G4String volumeName;
    G4String materialName;
    G4String creatorProcess;
    G4double globalTime = 0.0;
};

class RunAction : public G4UserRunAction {
public:
    RunAction();
    ~RunAction() override;

    void BeginOfRunAction(const G4Run*) override;
    void EndOfRunAction(const G4Run*) override;

    void RecordEventSummary(G4int eventID, G4double eventEdep);
    void AccumulateDepthEdep(G4double zGlobal, G4double edep);
    void RecordRecoilCandidate(const RecoilRecord& record);

private:
    void OpenOutputFiles();
    void CloseOutputFiles();
    void WriteDepthProfile();
    std::string Sanitize(const G4String& text) const;

    std::ofstream fEventFile;
    std::ofstream fRecoilFile;
    std::vector<G4double> fDepthEdep;

    G4double fZMin;
    G4double fZMax;
    G4double fBinWidth;
    G4int fNBins;
};

#endif
