//
// McastSatellite.ned
//
// Defines a satellite node type that extends the SpaceVeins satellite and
// attaches a MulticastConfigurator submodule.  This allows multicast
// routing entries to be installed automatically at simulation start-up.

package mcast;

import mcast.MulticastConfigurator;
import space_veins.nodes.Satellite;

module McastSatellite extends space_veins.nodes.Satellite
{
    parameters:
        // Parameters of the multicast configurator.  These can be overridden
        // per-instance in the omnetpp.ini file.
        string mcastGroupAddress = default("239.1.1.1");
        string mcastOriginAddress = default("0.0.0.0");
        string mcastOriginNetmask = default("0.0.0.0");
        string mcastInInterface = default("satNic0");
        string mcastOutInterfaces = default("satNic1");
    submodules:
        mcastConfigurator: MulticastConfigurator {
            parameters:
                groupAddress = mcastGroupAddress;
                originAddress = mcastOriginAddress;
                originNetmask = mcastOriginNetmask;
                inInterface = mcastInInterface;
                outInterfaces = mcastOutInterfaces;
                routingTableModule = "^.ipv4.routingTable";
                interfaceTableModule = "^.interfaceTable";
        }
}