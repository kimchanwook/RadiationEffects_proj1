#ifndef SteppingAction_h
#define SteppingAction_h 1

#include "G4UserSteppingAction.hh"

#include <unordered_set>

class G4Step;
class EventAction;
class RunAction;

class SteppingAction : public G4UserSteppingAction {
public:
    SteppingAction(EventAction* eventAction, RunAction* runAction);
    ~SteppingAction() override = default;

    void UserSteppingAction(const G4Step* step) override;

private:
    bool IsRecoilCandidate(const G4Step* step) const;
    bool IsFirstRecordForTrack(G4int eventID, G4int trackID);

    EventAction* fEventAction;
    RunAction* fRunAction;

    G4int fLastEventID;
    std::unordered_set<G4int> fRecordedTrackIDs;
};

#endif
