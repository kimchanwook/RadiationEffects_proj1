#include "G4RunManagerFactory.hh"
#include "G4UImanager.hh"
#include "FTFP_BERT.hh"
#include "G4VisExecutive.hh"
#include "G4UIExecutive.hh"

#include "DetectorConstruction.hh"
#include "ActionInitialization.hh"

int main(int argc, char** argv)
{
    auto* runManager = G4RunManagerFactory::CreateRunManager(G4RunManagerType::Default);
    runManager->SetUserInitialization(new DetectorConstruction());
    runManager->SetUserInitialization(new FTFP_BERT);
    runManager->SetUserInitialization(new ActionInitialization());

    auto* visManager = new G4VisExecutive;
    visManager->Initialize();

    auto* UImanager = G4UImanager::GetUIpointer();

    if (argc == 1) {
        auto* ui = new G4UIExecutive(argc, argv);
        UImanager->ApplyCommand("/control/execute macros/vis.mac");
        ui->SessionStart();
        delete ui;
    } else {
        G4String macroFile = argv[1];
        UImanager->ApplyCommand("/control/execute " + macroFile);
    }

    delete visManager;
    delete runManager;
    return 0;
}
