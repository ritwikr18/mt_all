//
// MulticastConfigurator.h
//
// Simple helper module that installs a static IPv4 multicast route
// in the satellite's routing table at start-up.
//
// Parameters are normally provided from omnetpp.ini via the
// McastSatellite wrapper:
//
//   mcastGroupAddress   = "239.1.1.1"
//   mcastOriginAddress  = "0.0.0.0"
//   mcastOriginNetmask  = "0.0.0.0"
//   mcastInInterface    = "satNic0"
//   mcastOutInterfaces  = "satNic1"
//
// This corresponds to a (*,G) route that forwards any traffic for
// 239.1.1.1 arriving on satNic0 out onto satNic1.
//

#ifndef _MCAST_MULTICASTCONFIGURATOR_H__
#define _MCAST_MULTICASTCONFIGURATOR_H__

#include <omnetpp.h>
#include "inet/common/InitStages.h"

namespace inet {

// Forward declarations for older INET versions.  Note that the class names use
// 'Ipv4' (lowercase v) rather than 'IPv4' in the SpaceVeins/INET code base.
class Ipv4RoutingTable;
class InterfaceTable;
class Ipv4MulticastRoute;

/**
 * A simple module that adds a static IPv4 multicast route at start-up.  The
 * route can be configured via NED parameters:
 *
 *   groupAddress     – multicast group (e.g. "239.1.1.1")
 *   originAddress    – source address (use "0.0.0.0" for any)
 *   originNetmask    – source mask (use "0.0.0.0" for any)
 *   inInterface      – name of input interface (e.g. "satNic0")
 *   outInterfaces    – space-separated list of output interfaces
 *
 * It locates the IPv4 routing table and interface table of the containing
 * host and installs a corresponding Ipv4MulticastRoute.
 */
class MulticastConfigurator : public omnetpp::cSimpleModule
{
  protected:
    // Parameters specifying where to find the tables (optional)
    std::string routingTableModulePath;
    std::string interfaceTableModulePath;

    // Multicast route specification
    std::string groupAddress;
    std::string originAddress;
    std::string originNetmask;
    std::string inInterface;
    std::string outInterfaces;

    // Cached pointers to the tables
    Ipv4RoutingTable *rt = nullptr;
    InterfaceTable *ift = nullptr;

  protected:
    virtual void initialize(int stage) override;
    virtual int numInitStages() const override { return inet::NUM_INIT_STAGES; }

    // Helper to resolve the routing and interface tables
    void resolveTables();

    // Add the multicast route to the routing table
    void addMulticastRoute();
};

} // namespace inet

#endif // _MCAST_MULTICASTCONFIGURATOR_H__
