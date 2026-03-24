#ifndef EventAction_h
#define EventAction_h 1

#include "G4UserEventAction.hh"

class G4Event;
class RunAction;

class EventAction : public G4UserEventAction {
public:
    explicit EventAction(RunAction* runAction);
    ~EventAction() override = default;

    void BeginOfEventAction(const G4Event*) override;
    void EndOfEventAction(const G4Event*) override;

    void AddEdep(double edep) { fEventEdep += edep; }

private:
    RunAction* fRunAction;
    double fEventEdep;
};

#endif
