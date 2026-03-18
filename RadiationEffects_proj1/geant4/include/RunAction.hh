#ifndef RunAction_h
#define RunAction_h 1

#include "G4UserRunAction.hh"
#include "globals.hh"

#include <fstream>
#include <string>
#include <vector>

class G4Run;

class RunAction : public G4UserRunAction
{
public:
    RunAction();
    ~RunAction() override;

    void BeginOfRunAction(const G4Run*) override;
    void EndOfRunAction(const G4Run*) override;

    void RecordEventSummary(G4int eventID, G4double eventEdep);
    void AccumulateDepthEdep(G4double zGlobal, G4double edep);
    void RecordRecoilCandidate(G4int eventID,
                               G4double zGlobal,
                               const G4String& particleName,
                               G4double kineticEnergy);

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
