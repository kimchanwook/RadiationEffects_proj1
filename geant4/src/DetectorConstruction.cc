#include "DetectorConstruction.hh"

#include "G4Box.hh"
#include "G4LogicalVolume.hh"
#include "G4Material.hh"
#include "G4NistManager.hh"
#include "G4PVPlacement.hh"
#include "G4SystemOfUnits.hh"

G4VPhysicalVolume* DetectorConstruction::Construct() {
    auto* nist = G4NistManager::Instance();

    auto* worldMat = nist->FindOrBuildMaterial("G4_Galactic");
    auto* silicon = nist->FindOrBuildMaterial("G4_Si");

    auto* solidWorld = new G4Box("World", 5 * cm, 5 * cm, 5 * cm);
    auto* logicWorld = new G4LogicalVolume(solidWorld, worldMat, "World");
    auto* physWorld =
        new G4PVPlacement(nullptr, {}, logicWorld, "World", nullptr, false, 0, true);

    auto* solidSi = new G4Box("SiliconSlab", 0.5 * cm, 0.5 * cm, 150 * um);
    auto* logicSi = new G4LogicalVolume(solidSi, silicon, "SiliconSlab");
    new G4PVPlacement(nullptr, {}, logicSi, "SiliconSlab", logicWorld, false, 0, true);

    return physWorld;
}
