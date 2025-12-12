//
// Network definition for a simple grid-based satellite communication scenario.
//
// This network instantiates the modules required to run a Veins/INET based
// simulation where vehicles are controlled by SUMO via TraCI and all
// communication is routed through a single low earth orbit satellite.
// The simulation uses a satellite radio medium for vehicle‑to‑satellite links

//
//package custom.satellitegrid;

//veins
import org.car2x.veins.visualizer.roads.RoadsCanvasVisualizer;
import org.car2x.veins.modules.world.annotations.AnnotationManager;
import org.car2x.veins.subprojects.veins_inet.IVeinsInetManager;
import org.car2x.veins.subprojects.veins_inet.VeinsInetTraCIVehicleInserter;

//Inet
import inet.environment.common.PhysicalEnvironment;
import inet.physicallayer.contract.packetlevel.IRadioMedium;
import inet.networklayer.configurator.ipv4.Ipv4NetworkConfigurator;
import inet.visualizer.integrated.IntegratedMultiVisualizer;
import inet.node.inet.INetworkNode;
import inet.networklayer.ipv4.Ipv4NetworkLayer;

//space_veins
import space_veins.nodes.Satellite;
import space_veins.nodes.SatCar;
import space_veins.modules.statistics.GlobalStatistics.GlobalStatistics;
import space_veins.modules.mobility.SatelliteInserter.SatelliteInserter;
import space_veins.modules.SatelliteObservationPoint.SatelliteObservationPoint;

// This network contains a TraCI manager, a vehicle inserter, a single
// satellite and the visualiser infrastructure.  Vehicles are not
// instantiated explicitly here; instead they are dynamically created by
// VeinsInetManager when SUMO reports new vehicles entering the region of
// interest.  The vehicle type is configured in the ini file.
network SatelliteAlertGrid
{
    parameters:
        double playgroundSizeX @unit(m) = default(100km); // size of the simulation area in x dimension
        double playgroundSizeY @unit(m) = default(100km); // size of the simulation area in y dimension
        double playgroundSizeZ @unit(m) = default(600km); // height of the 3D box; must exceed satellite altitude
        string satelliteType = default("space_veins.nodes.Satellite");
        @display("bgb=1803.93,1001.0663");
		
		// for geo satellites
        int numGeos = default(0);  // 0 = no GEOs by default
		
    submodules:
        // IPv4 configurator to automatically assign IP addresses and routing tables
        // to all network nodes.  This is required when using INET's Satellite
        // modules so that packets are forwarded correctly between the cars and
        // the satellite.  The configurator is configured in the ini file.


        configurator: Ipv4NetworkConfigurator {
            @display("p=100,43");
        }
        // Draw road network from SUMO on the 2D canvas
        annotations: AnnotationManager {
            @display("p=727,285");
        }
        roadsCanvasVisualizer: RoadsCanvasVisualizer {
            @display("p=727,198");
        }
        // TraCI manager that launches SUMO and creates SatCar modules for vehicles
        manager: <default("VeinsInetManager")> like IVeinsInetManager {
            @display("p=31,111");
        }
        // Optional vehicle inserter – set numVehicles to zero in the ini file
        vehicleInserter: VeinsInetTraCIVehicleInserter {
            @display("p=211,111");
        }
        // Physical environment describing the ground plane
        physicalEnvironment: PhysicalEnvironment {
            @display("p=31,187");
        }
        // Medium for 802.11 radios (not used in this example but kept for completeness)
        wlanRadioMedium: <default("Ieee80211ScalarRadioMedium")> like IRadioMedium {
            @display("p=352,110");
        }
        // Medium for satellite links.  This medium is configured via ini to
        // disable direct satellite to satellite communication and to define
        // elevation angle limits.
        satelliteRadioMedium: <default("UnitDiskRadioMedium")> like IRadioMedium {
            @display("p=211,186");
        }
        // Integrated visualiser that draws radios, transmissions and mobility
        visualizer: IntegratedMultiVisualizer {
            @display("p=727,118");
        }
        // Global statistics collection module.  This module records
        //scalar and vector results for satellites and vehicles.
        globalStatistics: GlobalStatistics {
            @display("p=189,315");
        }
        // Satellite inserter: responsible for creating satellites from TLE
        // files at runtime.  It adjusts the size of the constellation
        // vectors below.  Parameters for this module (e.g., path to TLE
        // file) are set in the ini file.
        satelliteInserter: SatelliteInserter {
            @display("p=130,378");
        }
        // Observation point used by the satellite inserter to determine
        // which satellites are visible over the simulation area.  Its
        // parameters are configured in the ini file and may reference the
        // SUMO network file.
        sop: SatelliteObservationPoint {
            @display("p=31,43");
        }
        // Constellation modules act as vectors.  Sizes are adjusted at
        // runtime by the satelliteInserter based on the selected TLE file.
        // At least one vector per constellation must exist in the network
        // definition so that dynamic instantiation can attach to it.
        leoSTARLINK[0]: <default(satelliteType)> like INetworkNode {
            @display("p=130,444");
        }
        leoIRIDIUM[0]: <default(satelliteType)> like INetworkNode {
            @display("p=130,512");
        }
        leoONEWEB[0]: <default(satelliteType)> like INetworkNode {
            @display("p=130,588");
        }
        leoORBCOMM[0]: <default(satelliteType)> like INetworkNode {
            @display("p=250,378");
        }
        leoGLOBALSTAR[0]: <default(satelliteType)> like INetworkNode {
            @display("p=250,444");
        }
        leoSPACEBEE[0]: <default(satelliteType)> like INetworkNode {
            @display("p=250,518");
        }


        // GEO satellite array (for GEO scenario configs)
        geo[numGeos]: <default(satelliteType)> like INetworkNode {
            @display("p=1029.7913,604.66125");
        }

        // Vehicle array.  New vehicles will be added by the TraCI manager at
        // runtime.  The module name 'node' is used by the manager to
        // create additional instances of SatCar as needed.
        node[0]: SatCar {
            @display("p=109,111");
        }
    connections allowunconnected:
}
