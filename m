From: Andreas B Aaen <andreas.aaen-546VmZ+UeKYX2WXlbB3fKg@public.gmane.org>
Subject: Re: [PATCH 0/6] netns: add linux-vrf features via network namespaces
Date: Fri, 31 Oct 2008 10:46:17 +0100
Message-ID: <200810311046.17506.andreas.aaen@tietoenator.com>
References: <4909B10A.8090403@thomson.net> <4909DEC8.9090102@thomson.net>
	<m14p2tznoz.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m14p2tznoz.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
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
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Friday 31 October 2008 00:07, Eric W. Biederman wrote:
> A global nsid breaks migration,
Yes.

> it breaks nested containers,
Yes.

> in general it  just hurts.
No.

> So it is a bad choice for an interface. 
Not necessarily. There is a reason why vrf is designed the way it is - and the 
patches that I have worked with had a similar design.

> Personally if I have vrf I want to set up a test environment in a container
> so I can isolate it from the rest of the system.   Allowing me to play with
> the user space side of the functionality without  So these things are not
> completely separate concerns.

Ok. Here is my use case.
I need a to talk to 500 IPv4 networks with possible overlapping IP addresses. 
The packages arrive on 500 VLANs. I want one process to listen to a port on 
each of these networks. I don't want 500 processes that runs in each their 
network namespace and then communicate with each other through e.g. unix 
sockets. This just complicates the task.

> So from a design point of view I see the following questions.
> 1) How do we pin a network namespace to allow for routing when no process
> uses it?
We introduce a global namespace or at least a namespace that unique for a 
process and it's sons.
Maybe a vrf container of network namespaces.
The vrf container numbers it's network namespaces. Each pid points to a vrf 
container. New vrf containers can be made through e.g. unshare(). Migration 
and nesting should be possible.

> 2) How do we create sockets into that pinned network namespace? 
Add a socket option that uses an index (global namespace)

> 3) How do we enter that network namespace so that sockets by default are
> created in it?
I don't need this feature. The VRF patchset does this, so they can implement a 
chvrf utillity.

> All of these are technically easy things to implement and design wise a
> challenge.
Yes.

As I see it network namespaces has provided the splitting of all the protocols 
in the network code. This was the huge task. The vrf patches that I have seen 
a few years back wasn't as mature as this. What's left is actually the 
management of these network namespaces. 

binding network namespaces to processes isn't a good idea for all use cases.  

> The best solution I see at the moment is to have something (a fs) we can
> mount in the filesystem, keeping the network namespace alive as long as it
> is mounted.
>
> i.e
> mount -t netns none /dev/nets/1
> mount -t netns -o newinstance none /dev/nets/2
>
> (The new instance parameter creates the network namespace as well as
> capturing the current one)
>
> char netns[] = "/dev/nets/2"
> fd = socket();
> err = setsockopt(fd, SOL_SOCKET, SO_NETPATH, netns, strlen(netns) + 1);

So the idea here is to let the userspace side choose the naming and ensuring 
the nesting possibility by using the filesystem.

Would you configure this interface on "/dev/nets/2" like this:

ip addr add 10.0.0.1/24 dev eth1 nets "/dev/nets/2" ?

Where the "/dev/nets/2" parameter is set through a SO_NETPATH option to the 
netlink socket that the iproute2 uses in it's implementation.

Is this better or worse than a vrf container with numbered network namespaces 
in?

Regards,
-- 
Andreas Bach Aaen              System Developer, M. Sc. 
Tieto Enator A/S               tel: +45 89 38 51 00
Skanderborgvej 232             fax: +45 89 38 51 01
8260 Viby J      Denmark       andreas.aaen-546VmZ+UeKYX2WXlbB3fKg@public.gmane.org
