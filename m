From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 0/6] netns: add linux-vrf features via network namespaces
Date: Fri, 31 Oct 2008 11:43:43 -0700
Message-ID: <m1wsfotxk0.fsf@frodo.ebiederm.org>
References: <4909B10A.8090403@thomson.net> <4909DEC8.9090102@thomson.net>
	<m14p2tznoz.fsf@frodo.ebiederm.org>
	<200810311046.17506.andreas.aaen@tietoenator.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <200810311046.17506.andreas.aaen-546VmZ+UeKYX2WXlbB3fKg@public.gmane.org> (Andreas
	B. Aaen's message of "Fri, 31 Oct 2008 10:46:17 +0100")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andreas B Aaen <andreas.aaen-546VmZ+UeKYX2WXlbB3fKg@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Andreas B Aaen <andreas.aaen-546VmZ+UeKYX2WXlbB3fKg@public.gmane.org> writes:

> On Friday 31 October 2008 00:07, Eric W. Biederman wrote:

> Ok. Here is my use case.
> I need a to talk to 500 IPv4 networks with possible overlapping IP addresses. 
> The packages arrive on 500 VLANs. I want one process to listen to a port on 
> each of these networks. I don't want 500 processes that runs in each their 
> network namespace and then communicate with each other through e.g. unix 
> sockets. This just complicates the task.

Yep.

>> So from a design point of view I see the following questions.
>> 1) How do we pin a network namespace to allow for routing when no process
>> uses it?
> We introduce a global namespace or at least a namespace that unique for a 
> process and it's sons.
> Maybe a vrf container of network namespaces.
> The vrf container numbers it's network namespaces. Each pid points to a vrf 
> container. New vrf containers can be made through e.g. unshare(). Migration 
> and nesting should be possible.

Ah.  The additional namespace approach.

>> 2) How do we create sockets into that pinned network namespace? 
> Add a socket option that uses an index (global namespace)
>
>> 3) How do we enter that network namespace so that sockets by default are
>> created in it?
> I don't need this feature. The VRF patchset does this, so they can implement a 
> chvrf utillity.
>
>> All of these are technically easy things to implement and design wise a
>> challenge.
> Yes.
>
> As I see it network namespaces has provided the splitting of all the protocols 
> in the network code. This was the huge task. The vrf patches that I have seen 
> a few years back wasn't as mature as this. What's left is actually the 
> management of these network namespaces. 
>
> binding network namespaces to processes isn't a good idea for all use cases.  
>
>> The best solution I see at the moment is to have something (a fs) we can
>> mount in the filesystem, keeping the network namespace alive as long as it
>> is mounted.
>>
>> i.e
>> mount -t netns none /dev/nets/1
>> mount -t netns -o newinstance none /dev/nets/2
>>
>> (The new instance parameter creates the network namespace as well as
>> capturing the current one)
>>
>> char netns[] = "/dev/nets/2"
>> fd = socket();
>> err = setsockopt(fd, SOL_SOCKET, SO_NETPATH, netns, strlen(netns) + 1);
>
> So the idea here is to let the userspace side choose the naming and ensuring 
> the nesting possibility by using the filesystem.
>
> Would you configure this interface on "/dev/nets/2" like this:
>
> ip addr add 10.0.0.1/24 dev eth1 nets "/dev/nets/2" ?


Essentially.  I was thinking that you could document /dev/nets in
devices.txt.  Making it the standard and default place for this to
happen so you would only need to say:

ip -nets 2 addr add  10.0.0.1/24 dev eth1

Very much like was previously discussed on this thread.

> Where the "/dev/nets/2" parameter is set through a SO_NETPATH option to the 
> netlink socket that the iproute2 uses in it's implementation.

Yes.

> Is this better or worse than a vrf container with numbered network namespaces 
> in?

Much better, although possibly a little more boiler plate code.

It uses existing namespaces and in particular the mount namespace so you can
create sets of processes that are using it that when they all exit the namespaces
all go away.

It allows recursive containers.
It allows migration.

And all for slightly fewer unique pieces of code than was in the last patchset.

As for the vrf container idea.  I think it gains us just about nothing
in comparison to using the filesystem aka mount namespace (which is
very good at dealing with names), and there are some very useful
things you can do with the mount namespace like mount propagation
which come for free.

From an implementation standpoint we really need as few namespaces
as we can get away with.

Eric
