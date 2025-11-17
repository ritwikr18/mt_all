//
// MulticastConfigurator.ned
//
// Defines the NED interface for the MulticastConfigurator simple module.  This
// module adds static IPv4 multicast routes to a host's routing table during
// initialization.  It should be inserted as a submodule of a host or router
// and configured via parameters.

package mcast;

// No external type imports are necessary; this module derives from
// cSimpleModule in C++ and does not depend on INETDefs here.

simple MulticastConfigurator
{
    parameters:
        @class(inet::MulticastConfigurator);
        // Module paths for locating the IPv4 routing table and interface table.
        // These default to sensible values relative to the containing host.
        string routingTableModule = default("^.ipv4.routingTable");
        string interfaceTableModule = default("^.interfaceTable");
        // IPv4 multicast group address for which to add a route, e.g. "239.1.1.1".
        string groupAddress;
        // IPv4 origin and netmask.  Use "0.0.0.0"/"0.0.0.0" for a (*,G) entry.
        string originAddress = default("0.0.0.0");
        string originNetmask = default("0.0.0.0");
        // Name of the incoming interface from which multicast traffic is accepted.
        // Leave empty to accept on all interfaces.
        string inInterface = default("");
        // Space-separated list of outgoing interface names.  Multicast traffic
        // will be forwarded on these interfaces.
        string outInterfaces;
        @display("i=block/cogwheel");
    gates:
        // No message passing needed; the configurator works purely on
        // initialization.  We provide dummy input and output gates to keep the
        // module flexible if the user wants to hook up control messages later.
        input in;
        output out;
}