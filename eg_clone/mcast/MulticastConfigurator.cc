//
// MulticastConfigurator.cc
//
// Debug-friendly version tailored to Space_Veins 0.3 / INET 3.x.
//

#include "MulticastConfigurator.h"

#include "inet/common/ModuleAccess.h"
#include "inet/networklayer/ipv4/Ipv4RoutingTable.h"
#include "inet/networklayer/ipv4/Ipv4Route.h"
#include "inet/networklayer/common/InterfaceTable.h"
#include "inet/networklayer/contract/ipv4/Ipv4Address.h"

using namespace omnetpp;

namespace inet {

Define_Module(MulticastConfigurator);

void MulticastConfigurator::initialize(int stage)
{
    cSimpleModule::initialize(stage);

    if (stage == INITSTAGE_LOCAL) {
        // Read parameters once and log them
        routingTableModulePath   = par("routingTableModule").stdstringValue();
        interfaceTableModulePath = par("interfaceTableModule").stdstringValue();
        groupAddress   = par("groupAddress").stdstringValue();
        originAddress  = par("originAddress").stdstringValue();
        originNetmask  = par("originNetmask").stdstringValue();
        inInterface    = par("inInterface").stdstringValue();
        outInterfaces  = par("outInterfaces").stdstringValue();

        EV_INFO << "[MulticastConfigurator] INITSTAGE_LOCAL on "
                << getFullPath() << "\n"
                << "  routingTableModule = '" << routingTableModulePath << "'\n"
                << "  interfaceTableModule = '" << interfaceTableModulePath << "'\n"
                << "  groupAddress = '" << groupAddress << "'\n"
                << "  originAddress = '" << originAddress << "'\n"
                << "  originNetmask = '" << originNetmask << "'\n"
                << "  inInterface = '" << inInterface << "'\n"
                << "  outInterfaces = '" << outInterfaces << "'\n";
    }
    else if (stage == INITSTAGE_NETWORK_LAYER) {
        EV_INFO << "[MulticastConfigurator] INITSTAGE_NETWORK_LAYER on "
                << getFullPath() << " – resolving tables and installing route\n";

        resolveTables();
        addMulticastRoute();
    }
}

void MulticastConfigurator::resolveTables()
{
    cModule *host = getContainingNode(this);
    if (!host)
        throw cRuntimeError("MulticastConfigurator: cannot find containing host module");

    EV_INFO << "[MulticastConfigurator] resolveTables() for host "
            << host->getFullPath() << endl;

    // ---- Routing table via parameter path ----
    if (routingTableModulePath.empty())
        throw cRuntimeError("MulticastConfigurator: routingTableModule parameter is empty on %s",
                            getFullPath().c_str());

    rt = getModuleFromPar<Ipv4RoutingTable>(par("routingTableModule"), this);
    EV_INFO << "  Routing table resolved to: " << rt->getFullPath() << endl;

    // ---- Interface table via parameter path ----
    if (interfaceTableModulePath.empty())
        throw cRuntimeError("MulticastConfigurator: interfaceTableModule parameter is empty on %s",
                            getFullPath().c_str());

    ift = getModuleFromPar<InterfaceTable>(par("interfaceTableModule"), this);
    EV_INFO << "  Interface table resolved to: " << ift->getFullPath() << endl;

    // Log the interfaces we see – very helpful to match names
    EV_INFO << "[MulticastConfigurator] InterfaceTable has "
            << ift->getNumInterfaces() << " interfaces:\n";
    for (int i = 0; i < ift->getNumInterfaces(); ++i) {
        InterfaceEntry *ie = ift->getInterface(i);
        EV_INFO << "  IF[" << i << "]: name=" << ie->getInterfaceName()
                << " id=" << ie->getInterfaceId()
                << " isUp=" << (ie->isUp() ? "true" : "false")
                << "\n";
    }
}

void MulticastConfigurator::addMulticastRoute()
{
    cModule *host = getContainingNode(this);

    if (groupAddress.empty()) {
        EV_WARN << "[MulticastConfigurator] groupAddress is empty on host "
                << (host ? host->getFullPath() : std::string("<unknown>"))
                << " – NOT installing any multicast route.\n";
        return;
    }

    Ipv4Address group(groupAddress.c_str());
    Ipv4Address origin(originAddress.c_str());
    Ipv4Address mask(originNetmask.c_str());

    EV_INFO << "[MulticastConfigurator] Installing multicast route on host "
            << (host ? host->getFullPath() : std::string("<unknown>")) << "\n"
            << "  origin = " << origin << "\n"
            << "  originMask = " << mask << "\n"
            << "  group = " << group << "\n"
            << "  inInterface = '" << inInterface << "'\n"
            << "  outInterfaces = '" << outInterfaces << "'\n";

    // Create the route
    Ipv4MulticastRoute *route = new Ipv4MulticastRoute();
    route->setOrigin(origin);
    route->setOriginNetmask(mask);

    // NOTE: in your INET, the group setter may be called setGroup().
    // If this line fails to compile, change to the exact name from Ipv4Route.h.
    route->setMulticastGroup(group);


    // ---- Input interface ----
    if (!inInterface.empty()) {
        InterfaceEntry *ieIn = ift->findInterfaceByName(inInterface.c_str());
        if (!ieIn) {
            EV_ERROR << "[MulticastConfigurator] inInterface '" << inInterface
                     << "' NOT FOUND on host "
                     << (host ? host->getFullPath() : std::string("<unknown>"))
                     << " – aborting route installation\n";
            delete route;
            throw cRuntimeError("MulticastConfigurator: inInterface '%s' not found on host %s",
                                inInterface.c_str(),
                                host ? host->getFullPath().c_str() : "<unknown>");
        }

        // Older INET: directly construct InInterface wrapper
        Ipv4MulticastRoute::InInterface *in =
            new Ipv4MulticastRoute::InInterface(ieIn);
        route->setInInterface(in);

        EV_INFO << "  Using input interface: " << ieIn->getInterfaceName()
                << " (id=" << ieIn->getInterfaceId() << ")\n";
    }
    else {
        EV_INFO << "  No inInterface specified – packets from any input interface will match.\n";
    }

    // ---- Output interfaces ----
    if (!outInterfaces.empty()) {
        cStringTokenizer tok(outInterfaces.c_str());
        const char *token;
        while ((token = tok.nextToken()) != nullptr) {
            InterfaceEntry *ieOut = ift->findInterfaceByName(token);
            if (!ieOut) {
                EV_ERROR << "[MulticastConfigurator] outInterface '" << token
                         << "' NOT FOUND on host "
                         << (host ? host->getFullPath() : std::string("<unknown>"))
                         << " – aborting route installation\n";
                delete route;
                throw cRuntimeError("MulticastConfigurator: outInterface '%s' not found on host %s",
                                    token,
                                    host ? host->getFullPath().c_str() : "<unknown>");
            }

            Ipv4MulticastRoute::OutInterface *out =
                new Ipv4MulticastRoute::OutInterface(ieOut);
            route->addOutInterface(out);

            EV_INFO << "  Added output interface: " << ieOut->getInterfaceName()
                    << " (id=" << ieOut->getInterfaceId() << ")\n";
        }
    }
    else {
        // Fallback: try to automatically add sensible output interfaces.
        // Many satellite node definitions name their satellite NICs "satNic0", "satNic1", ...
        // If outInterfaces is empty, add all interfaces whose name begins with "satNic"
        // except the input interface (if specified).
        EV_WARN << "  WARNING: outInterfaces is empty – attempting automatic discovery of output interfaces.\n";
        for (int i = 0; i < ift->getNumInterfaces(); ++i) {
            InterfaceEntry *ieCandidate = ift->getInterface(i);
            std::string ifName = ieCandidate->getInterfaceName();
            if (ifName.rfind("satNic", 0) == 0) { // starts with "satNic"
                if (!inInterface.empty() && ifName == inInterface)
                    continue;
                Ipv4MulticastRoute::OutInterface *out =
                    new Ipv4MulticastRoute::OutInterface(ieCandidate);
                route->addOutInterface(out);
                EV_INFO << "  Auto-added output interface: " << ieCandidate->getInterfaceName()
                        << " (id=" << ieCandidate->getInterfaceId() << ")\n";
            }
        }
        if (route->getNumOutInterfaces() == 0) {
            EV_WARN << "  Automatic discovery found no 'satNic*' interfaces – route will NOT forward anywhere.\n";
        }
    }

    // Finally, install the route
    rt->addMulticastRoute(route);

    EV_INFO << "[MulticastConfigurator] Multicast route installed successfully. "
            << "Routing table now has " << rt->getNumMulticastRoutes()
            << " multicast routes.\n";
}

} // namespace inet
