#include "EventAction.hh"
#include "RunAction.hh"

#include "G4Event.hh"

EventAction::EventAction(RunAction* runAction)
    : fRunAction(runAction), fEventEdep(0.0)
{}

void EventAction::BeginOfEventAction(const G4Event*)
{
    fEventEdep = 0.0;
}

void EventAction::EndOfEventAction(const G4Event* event)
{
    if (fRunAction) {
        fRunAction->RecordEventSummary(event->GetEventID(), fEventEdep);
    }
}
