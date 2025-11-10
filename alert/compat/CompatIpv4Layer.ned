// Adjust this package to match your folder under the NED source folder.
// If your file path is: alertle/compat/CompatIpv4Layer.ned
// then use:
package compat;

import inet.networklayer.ipv4.Ipv4NetworkLayer;
import inet.common.MessageDispatcher;

module CompatIpv4Layer
{
    parameters:
        // expose these so you can set them from omnetpp.ini
        bool forwarding = default(false);
        bool multicastForwarding = default(false);
        string interfaceTableModule;

        // propagate to inner IPv4 layer and its children
        *.forwarding = forwarding;
        *.multicastForwarding = multicastForwarding;
        *.interfaceTableModule = default(absPath(interfaceTableModule));

        @display("i=block/fork");

    gates:
        // These match what SatCar/Satellite expect on 'nl'
        input  in[];
        output out[];
        input  transportIn;
        output transportOut;

    submodules:
        // Fan-in / fan-out helper modules
        fanin:  inet.common.MessageDispatcher { @display("p=200,140"); }
        fanout: inet.common.MessageDispatcher { @display("p=200,260"); }

        // The actual IPv4 network layer in your INET (scalar ifIn/ifOut)
        l3: inet.networklayer.ipv4.Ipv4NetworkLayer {
            @display("p=400,200");
        }

    connections allowunconnected:
        // Transport up/down stays 1:1
        transportIn  --> l3.transportIn;
        transportOut <-- l3.transportOut;

        // NICs (multiple) -> fan-in (vector) -> l3.ifIn (scalar)
		for i=0..sizeof(in)-1 {
    		in[i] --> fanin.in++;
		}
		fanin.out++ --> l3.ifIn;

		// l3.ifOut (scalar) -> fan-out (vector) -> NICs (multiple)
		l3.ifOut --> fanout.in++;
		for i=0..sizeof(out)-1 {
    		fanout.out++ --> out[i];
		}

}