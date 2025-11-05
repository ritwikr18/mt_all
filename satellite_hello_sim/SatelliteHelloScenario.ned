//
// This network is derived from the SatelliteExampleScenario in the
// `space_veins` repository.  It defines a playground with one or more
// vehicles of type `SatCar` and any number of Low‑Earth‑Orbit (LEO)
// satellites created on the fly by the `SatelliteInserter`.  In
// contrast to the original example the network has been renamed and
// simplified for clarity.  Feel free to remove unused submodules or
// add your own.
//
//package satellite_hello_sim;

import org.car2x.veins.visualizer.roads.RoadsCanvasVisualizer;
import org.car2x.veins.modules.world.annotations.AnnotationManager;
import org.car2x.veins.subprojects.veins_inet.IVeinsInetManager;
import org.car2x.veins.subprojects.veins_inet.VeinsInetTraCIVehicleInserter;
import space_veins.nodes.SatCar;
import space_veins.modules.SatelliteObservationPoint.SatelliteObservationPoint;
import space_veins.modules.statistics.GlobalStatistics.GlobalStatistics;
import space_veins.modules.mobility.SatelliteInserter.SatelliteInserter;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;
import inet.visualizer.integrated.IntegratedMultiVisualizer;
import inet.environment.common.PhysicalEnvironment;
import inet.networklayer.configurator.ipv4.Ipv4NetworkConfigurator;  // Modification


 //* A simple scenario for demonstrating Vehicle‑to‑Satellite
 //* communication.  Vehicles are inserted by Veins/TraCI and are of
 //* type `SatCar`, which extends `VeinsInetCar` with an optional
 //* satellite network interface.  Satellites are instantiated
 //* dynamically based on Two Line Element (TLE) files via the
 //* `SatelliteInserter`.  Both the satellite and WLAN radio media are
 //* included so that you can run mixed scenarios.
 //*/
network SatelliteHelloScenario
{
    parameters:
        double playgroundSizeX @unit(m);
        double playgroundSizeY @unit(m);
        double playgroundSizeZ @unit(m);
        string satelliteType = default("Satellite");
        @display("bgb=1007,666");
    submodules:


        // Modification
        configurator: Ipv4NetworkConfigurator {
            @display("p=100,50");
        }



        // Standard Veins components
        annotations: AnnotationManager {
            @display("p=750,744.98");
        }
        roadsCanvasVisualizer: RoadsCanvasVisualizer {
            @display("p=750,750");
        }
        // Veins‑INET manager integrates SUMO and INET
        manager: <default("VeinsInetManager")> like IVeinsInetManager {
            @display("p=192,320");
        }
        vehicleInserter: VeinsInetTraCIVehicleInserter {
            @display("p=64,612");
        }
        // INET physical environment and radio media
        physicalEnvironment: PhysicalEnvironment {
            @display("p=192,224");
        }
        wlanRadioMedium: <default("Ieee80211ScalarRadioMedium")> like IRadioMedium {
            @display("p=64,224");
        }
        satelliteRadioMedium: <default("UnitDiskRadioMedium")> like IRadioMedium {
            @display("p=580,275");
        }
        visualizer: IntegratedMultiVisualizer {
            @display("p=580,125");
        }
        // space_Veins specific components
        globalStatistics: GlobalStatistics {
            @display("p=580,425");
        }
        satelliteInserter: SatelliteInserter {
            @display("p=128,612");
        }
        sop: SatelliteObservationPoint {
            @display("p=0,0");
        }
        // Constellation modules act as vectors; sizes are adjusted at runtime
        // by SatelliteInserter based on the selected TLE file.  At least one
        // vector per constellation must exist in the network definition so
        // that dynamic instantiation can attach to it.
        leoSTARLINK[0]: <default(satelliteType)> like INetworkNode {
            @display("p=250,612");
        }
        leoIRIDIUM[0]: <default(satelliteType)> like INetworkNode {
            @display("p=300,612");
        }
        leoONEWEB[0]: <default(satelliteType)> like INetworkNode {
            @display("p=350,612");
        }
        leoORBCOMM[0]: <default(satelliteType)> like INetworkNode {
            @display("p=400,612");
        }
        leoGLOBALSTAR[0]: <default(satelliteType)> like INetworkNode {
            @display("p=450,612");
        }
        leoSPACEBEE[0]: <default(satelliteType)> like INetworkNode {
            @display("p=500,612");
        }
        // Vehicle array.  New vehicles will be added by the
        // VeinsInetTraCIVehicleInserter at runtime.
        node[0]: SatCar;
    connections allowunconnected:
}
