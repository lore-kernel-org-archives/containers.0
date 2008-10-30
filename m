From: Andreas B Aaen <andreas.aaen-546VmZ+UeKYX2WXlbB3fKg@public.gmane.org>
Subject: Re: [PATCH 0/6] netns: add linux-vrf features via network namespaces
Date: Thu, 30 Oct 2008 15:38:07 +0100
Message-ID: <200810301538.08032.andreas.aaen@tietoenator.com>
References: <4909B10A.8090403@thomson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4909B10A.8090403-L+G57L1VLRbR7s880joybQ@public.gmane.org>
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

On Thursday 30 October 2008 14:05, Vivien Chappelier wrote:
>     The recently introduced network namespaces allow separate standalone
> network stacks to coexist on the same machine. This is a very useful
> functionality that we have been needing and using in our products for
> some time, through the VRF ptchset (http://linux-vrf.sourceforge.net/).
> The goal of the VRF patchset and network namespaces are very similar,
> yet some features of the VRF are missing that these patches intend to
> provide.

I have worked with a similar patchset. the goal was to be able to terminate 
traffic from different IPv4 nets with possible overlapping IP addresses. You 
should be able to communicate with all IPv4 nets from the same process.

>     The network namespaces are currently tied to a process, and
> referenced by its pid. However, a networking stack has no particular
> reason to be associated with any process and it should be possible to
> use and setup additional networking stacks without the need to clone()

Right.

> or unshare(). The initial version of the "Coexist with the sysfs
> limitations" patches by Benjamin Thery introduced the notion of a unique
> network namespace identifier (nsid)  that is perfectly fit for the
> purpose of referencing networking stacks independently of any process.
> The first two patches of his set are therefore reused here to identify
> networking stacks.

I have proposed such a global namespace before on this list, but no one seemed 
interested.

>     These patches additionally introduce the following features that
> were initially provided by the VRF patchset:
> - the ability to move a socket to a different network namespace, through
> the new SO_NSID setsockopt(), given the nsid

This was exactly our solution although the name of the option was different.
Very elegant solution for scaleability. A huge number of networks can be 
reached from within the same process through different sockets.

> - the ability to move a process to an existing network namespace,
> through the new SO_NETNS setsockopt(), given the nsid

I don't see the need for this. The current network namespace implementation 
handles this just fine without giving the network namespaces numbers.
I see the usecase for this as isolation. Standard applications without any 
setsockopt() use of SO_NSID 

> - the ability to move an interface to a different namespace by nsid
> instead of pid

Here use can use the SO_NSID option through the netlink socket.

> - the ability to create additional network namespaces on startup

Why do it at startup?

> (dynamic addition/deletion is not supported but should be easy to add)

I have only one problem left here on this. When I call copy_net_ns() through 
the netlink socket the rtnl_lock() is already taken.

>    Also attached is a patch to iproute2 to add the ability to move an
> interface to a different namespace by nsid, used this way:
>
> $ ip link set eth0 nsid 1    # This will move eth0 to network namespace 1

ip netns add 1    # create network namespace with index 1
ip link set eth1 nsid 1    # move eth1 to network namespace with index 1
ip -nsid 1 addr add 192.168.50.1/24 dev eth1
ip -nsid 1 addr add 127.0.0.1/8 dev lo
ip -nsid 1 link set eth1 up
ip -nsid 1 link set lo up

The nsid option uses SO_NSID on the socket. This makes sure that the device 
name to index conversion inside iproute2 and the kernel works as it should.

Regards,
-- 
Andreas Bach Aaen              System Developer, M. Sc. 
Tieto Enator A/S               tel: +45 89 38 51 00
Skanderborgvej 232             fax: +45 89 38 51 01
8260 Viby J      Denmark       andreas.aaen-546VmZ+UeKYX2WXlbB3fKg@public.gmane.org
