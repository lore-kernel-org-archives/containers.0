From: Vivien Chappelier <vivien.chappelier-L+G57L1VLRbR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH 0/6] netns: add linux-vrf features via network namespaces
Date: Thu, 30 Oct 2008 17:20:24 +0100
Message-ID: <4909DEC8.9090102@thomson.net>
References: <4909B10A.8090403@thomson.net>
	<200810301538.08032.andreas.aaen@tietoenator.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <200810301538.08032.andreas.aaen-546VmZ+UeKYX2WXlbB3fKg@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

Andreas B Aaen wrote:
> I have worked with a similar patchset. the goal was to be able to terminate 
> traffic from different IPv4 nets with possible overlapping IP addresses. You 
> should be able to communicate with all IPv4 nets from the same process.
>   
> I have proposed such a global namespace before on this list, but no one seemed 
> interested.
>
>   
Good, that makes at least two people interested in this feature. It has 
actually nothing to do with isolation, which is probably why interest 
may be low here, but I tried posting on netdev and was redirected here.

>> - the ability to move a process to an existing network namespace,
>> through the new SO_NETNS setsockopt(), given the nsid
>>     
>
> I don't see the need for this. The current network namespace implementation 
> handles this just fine without giving the network namespaces numbers.
>   
Maybe I missed something: how do you join an existing namespace without 
being the child of the process that created it?

> I see the usecase for this as isolation. Standard applications without any 
> setsockopt() use of SO_NSID
>   
Here the use case is rather to use existing tools (without adding 
SO_NSID setsockopt() and recompiling) in a different namespace easily, e.g.
$ chnetns 1 ifconfig

> Here use can use the SO_NSID option through the netlink socket.
>   
This is indeed an elegant solution (works with ioctl() like interfaces 
too by the way) to avoid adding a lot of options to the already existing 
netlink interface.

>> - the ability to create additional network namespaces on startup
>>     
>
> Why do it at startup?
>   
Mostly because I've not ported dynamic addition/deletion yet like you did...

>> (dynamic addition/deletion is not supported but should be easy to add)
>>     
>
> I have only one problem left here on this. When I call copy_net_ns() through 
> the netlink socket the rtnl_lock() is already taken.
>   
I see. And locking order with net_mutex has to be maintained, so perhaps 
defering adding/deletion to a workqueue would be the solution?

> ip netns add 1    # create network namespace with index 1
> ip link set eth1 nsid 1    # move eth1 to network namespace with index 1
> ip -nsid 1 addr add 192.168.50.1/24 dev eth1
> ip -nsid 1 addr add 127.0.0.1/8 dev lo
> ip -nsid 1 link set eth1 up
> ip -nsid 1 link set lo up
>
> The nsid option uses SO_NSID on the socket. This makes sure that the device 
> name to index conversion inside iproute2 and the kernel works as it should.
>   
I really like this idea of calling setsockopt(SO_NSID) on the netlink 
socket directly. Did you post any patches of your implementation?

To bring back the discussion you had with Eric W. Biederman, it seems to 
me that the only real issue is on the addition of the global nsid index 
that is not really fit to be used hierarchically. However, I don't 
understand why having both this global nsid interface and the pid 
interface would hurt, as the goals of isolation and VRF-like support are 
really separate. The idea being those patches is to provide a way to 
manage the networking stack instances easily. The fact that new 
networking stacks instances are created and used for process isolation 
is independent and mostly unrelated. So the IFLA_NET_NS_PID option would 
be kept anyway for this purpose of nesting containers, although adding a 
new internal get_nsid_from_pid() or something similar would make sense 
to avoid duplication of code.

regards,
Vivien.
