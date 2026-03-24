#include "SteppingAction.hh"

#include "EventAction.hh"
#include "RunAction.hh"

#include "G4Event.hh"
#include "G4EventManager.hh"
#include "G4Ions.hh"
#include "G4LogicalVolume.hh"
#include "G4ParticleDefinition.hh"
#include "G4Step.hh"
#include "G4StepPoint.hh"
#include "G4SystemOfUnits.hh"
#include "G4Track.hh"
#include "G4VPhysicalVolume.hh"
#include "G4VProcess.hh"

namespace {
constexpr G4double kMinReportedRecoilEnergy = 10.0 * eV;
}

SteppingAction::SteppingAction(EventAction* eventAction, RunAction* runAction)
    : fEventAction(eventAction),
      fRunAction(runAction),
      fLastEventID(-1) {}

void SteppingAction::UserSteppingAction(const G4Step* step) {
    if (!step) {
        return;
    }

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

    if (!IsRecoilCandidate(step)) {
        return;
    }

    const auto* currentEvent = G4EventManager::GetEventManager()->GetConstCurrentEvent();
    if (!currentEvent) {
        return;
    }
    const G4int eventID = currentEvent->GetEventID();

    const auto* secondaries = step->GetSecondaryInCurrentStep();
    if (!secondaries) {
        return;
    }

    for (const auto* secondary : *secondaries) {
        if (!secondary) {
            continue;
        }

        auto* definition = secondary->GetDefinition();
        const bool isIon = dynamic_cast<G4Ions*>(definition) != nullptr;
        if (!isIon) {
            continue;
        }
        if (secondary->GetParentID() <= 0) {
            continue;
        }
        if (secondary->GetKineticEnergy() < kMinReportedRecoilEnergy) {
            continue;
        }
        if (!IsFirstRecordForTrack(eventID, secondary->GetTrackID())) {
            continue;
        }

        RecoilRecord record;
        record.eventID = eventID;
        record.trackID = secondary->GetTrackID();
        record.parentID = secondary->GetParentID();
        record.particleName = definition->GetParticleName();
        record.kineticEnergy = secondary->GetKineticEnergy();
        record.localStepEdep = edep;
        record.x = secondary->GetPosition().x();
        record.y = secondary->GetPosition().y();
        record.z = secondary->GetPosition().z();
        record.dirX = secondary->GetMomentumDirection().x();
        record.dirY = secondary->GetMomentumDirection().y();
        record.dirZ = secondary->GetMomentumDirection().z();
        record.volumeName = volume->GetName();
        record.materialName = volume->GetLogicalVolume()->GetMaterial()->GetName();
        record.globalTime = secondary->GetGlobalTime();

        const auto* creator = secondary->GetCreatorProcess();
        record.creatorProcess = creator ? creator->GetProcessName() : "primary_or_unknown";

        if (fRunAction) {
            fRunAction->RecordRecoilCandidate(record);
        }
    }
}

bool SteppingAction::IsRecoilCandidate(const G4Step* step) const {
    const auto* secondaries = step->GetSecondaryInCurrentStep();
    if (!secondaries || secondaries->empty()) {
        return false;
    }
    return true;
}

bool SteppingAction::IsFirstRecordForTrack(G4int eventID, G4int trackID) {
    if (eventID != fLastEventID) {
        fRecordedTrackIDs.clear();
        fLastEventID = eventID;
    }

    const auto [it, inserted] = fRecordedTrackIDs.insert(trackID);
    (void)it;
    return inserted;
}
