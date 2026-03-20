#include "SteppingAction.hh"
#include "EventAction.hh"
#include "RunAction.hh"

#include "G4EventManager.hh"
#include "G4Ions.hh"
#include "G4Step.hh"
#include "G4StepPoint.hh"
#include "G4SystemOfUnits.hh"
#include "G4Track.hh"
#include "G4VPhysicalVolume.hh"
#include "G4VProcess.hh"

SteppingAction::SteppingAction(EventAction* eventAction, RunAction* runAction)
    : fEventAction(eventAction), fRunAction(runAction)
{}

void SteppingAction::UserSteppingAction(const G4Step* step)
{
    auto* prePoint = step->GetPreStepPoint();
    if (!prePoint) {
        return;
    }

    auto* volume = prePoint->GetTouchableHandle()->GetVolume();
    if (!volume || volume->GetName() != "SiliconSlab") {
        return;
    }

    const G4double edep = step->GetTotalEnergyDeposit();
    const G4double z = prePoint->GetPosition().z();

    if (fEventAction) {
        fEventAction->AddEdep(edep);
    }
    if (fRunAction) {
        fRunAction->AccumulateDepthEdep(z, edep);
    }

    const auto* secondaries = step->GetSecondaryInCurrentStep();
    const G4int eventID = G4EventManager::GetEventManager()->GetConstCurrentEvent()->GetEventID();

    for (const auto* secondary : *secondaries) {
        if (!secondary) {
            continue;
        }

        auto* definition = secondary->GetDefinition();
        const bool isIon = dynamic_cast<const G4Ions*>(definition) != nullptr;
        if (!isIon) {
            continue;
        }

        if (fRunAction) {
            fRunAction->RecordRecoilCandidate(eventID,
                                              z,
                                              definition->GetParticleName(),
                                              secondary->GetKineticEnergy());
        }
    }
}
