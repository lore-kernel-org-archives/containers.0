From: Andreas B Aaen <andreas.aaen-546VmZ+UeKYX2WXlbB3fKg@public.gmane.org>
Subject: Network namespaces without isolation
Date: Wed, 2 Jul 2008 09:18:50 +0200
Message-ID: <200807020918.50997.andreas.aaen@tietoenator.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

I am looking into the network namespace implementation because I need an IP 
stack that is capable of talking with a number of separate IP nets with 
possible overlapping IP adresses. My connection to each separate IP-net is 
through a tunnel e.g. a VLAN interface.

A special application will then be able to listen to traffic on all the nets 
through a socket option SO_NS that sets the namespace to talk/listen to for a 
particular socket. For this to work network namespaces needs to be indexed.
It would also be very handy if the configuration can be made without a clone() 
call.
Something like:

ip ns add ns 1
ip link set eth0.42 ns 1
ip addr add 192.168.50.4/24 dev eth0.42 ns 1

It would be fairly ok if this possibility to set up interfaces on other 
namespaces only is possible from the default namespace.

It would also be nice to be able to see the network statistics from all the 
namespaces through the proc filesystem at least in an uncloned (isolated) 
namespace.

So you would be able to see the network statistics in /proc/net/ns/<index>/

It should be said that we have an implementation of all this already, but NOT 
based on network namespaces and for elder kernels. We don't want to forward 
port this, put instead add a few features to the network namespace 
implementation to be able to fullfill the requirement of our application: 
talk to a number of IP networks with possible overlapping IP addresses.

Regards,
-- 
Andreas Bach Aaen              System Developer, M. Sc. 
Tieto Enator A/S               tel: +45 89 38 51 00
Skanderborgvej 232             fax: +45 89 38 51 01
8260 Viby J      Denmark       andreas.aaen-546VmZ+UeKYX2WXlbB3fKg@public.gmane.org
