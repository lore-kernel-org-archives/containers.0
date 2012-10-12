From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: uevent when moving nic between network namespaces?
Date: Thu, 11 Oct 2012 22:13:28 -0500
Message-ID: <20121012031328.GA5472@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, Dan Kegel <dank-XdDNpL9cdsoAvxtiuMwx3w@public.gmane.org>, =?iso-8859-1?Q?St=E9phane?= Graber <stephane.graber-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, Daniel Lezcano <dlezcano-GANU6spQydw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

Dan Kegel (cc:d) found an interesting nuisance relating to upstart
and network interfaces with lxc containers.  In particular, when you
start a container, two veths are created.  A uevent for their creation
is sent, and so a 'network-interface' upstart job is created for each.
One of the veths is passed into the container.  When the container
shuts down, the veth in the init-net-ns gets a net-device-removed
uevent, so the network-interface upstart job goes away.  But the veth
in the container doesn't cause a net-device-removed upstart uevent
to be sent.  So its network-interface upstart job sticks around.

The details are at:

https://bugs.launchpad.net/ubuntu/+source/lxc/+bug/1065589

I notice that when simply renaming a netdev (sudo ip link set veth1 name
veth2) then udevadm monitor shows:

KERNEL[17945.234850] move     /devices/virtual/net/veth2 (net)
UDEV  [17945.235758] move     /devices/virtual/net/veth2 (net)

but when I do 'sudo ip link set veth2 netns 27689' then 'udevadm
monitor' shows nothing.

When I do

	sudo ip link set veth1 netns 32296
	(in process 32296) sudo ip link set veth1 name veth2

then, again udevadm monitor shows nothing.

So the question is, should the kernel be sending uevents for
net-device-removed and then net-device-added when a nic is moved
between network namespaces?  Or should lxc just fake that?

-serge
