From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Network namespaces without isolation
Date: Fri, 04 Jul 2008 15:45:38 -0700
Message-ID: <m1hcb546b1.fsf@frodo.ebiederm.org>
References: <200807020918.50997.andreas.aaen@tietoenator.com>
	<m1zloydliv.fsf@frodo.ebiederm.org>
	<200807041707.28865.andreas.aaen@tietoenator.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <200807041707.28865.andreas.aaen-546VmZ+UeKYX2WXlbB3fKg@public.gmane.org> (Andreas
	B. Aaen's message of "Fri, 4 Jul 2008 17:07:28 +0200")
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
>
> How do you actually use multiple name spaces in the current implementation in 
> the same task if you refer to them indirectly through pids?
> So if I need 500 network namespaces then I need to fork 500 processes.

Currently sockets are explicitly tagged with the namespace they are in.
And you can pass sockets between processes.  The only case we have where
we need to refer to a namespace other then our current one is when
passing network devices between namespaces.

ip link set eth0 netns <pid>.

>> A socket option sounds like a nice idea.
>
> And quite easy to implement except  for the handling of which network 
> namespaces you should be allowed to talk to.

Yes.

>> There have been a number of discussions about identifiers none of which
>> have led to any sort of agreement.  One of the goals in the design is
>> that we don't introduce new global identifiers allowing us to ultimately
>> have nested containers.
>
> In this case this means that the index' should be a namespace of itself just 
> like pids. It seems to be overkill. At lest for my purpose.

Well the index should be in a namespace and hopefully an existing namespace.

>> So far we have been referring to namespaces indirectly by the pids of the
>> processes which are using them.
>
> Right. And with namespaces into namespaces and usage of pid namespaces you 
> could have two different namespaces named with the same numerical value of 
> pid.

I each pid namespaces the pid values are unique, and since the pid namespace
is hierarchical with all pids showing up in the initial pid namespace.

>> > It would also be nice to be able to see the network statistics from all
>> > the namespaces through the proc filesystem at least in an uncloned
>> > (isolated) namespace.
>>
>> Currently this is possible by looking at /proc/<pid>/net.
>
> Which was what lead me to the question of how you can have more name spaces in 
> a single task with the current implementation.

Well you can't look at them very well.

>> > So you would be able to see the network statistics in
>> > /proc/net/ns/<index>/
>
> Or maybe this should have been /proc/<pid>/net/<index>/ ?

I'm not certain.  If I can figure out how to break /proc/net into it's own filesystem
it gets easier to manage.  Despite being possible I haven't figured out how to
do that cleanly yet.

>> If we can work out the details on how to do that cleanly it seems totally
>> reasonable to enhance network namespaces in that direction.  You are not
>> the first to express those kind of requirements, and probably won't be the
>> last.
>
> So it seems that we need to restart the naming discussion.

I had the clear realization a while back that if we had done this cleanly everything
would have been in the mount namespace from the start.

Since we have the problem of when to free a network namespace as well as how to
open a socket I have relatively simple suggestion.  Create a netnsfs.  By default
have that filesystem refer to the mounters current network namespace or if passed
-o create generate a new one.

Opening a socket is a bit trickier to map because sockets have the triple of
options.  But I expect you could open a socket like:
open("/path/to/netnsfs/mount/inet;stream;tcp", O_RDWR | O_CREAT,  0777);

I suppose a socket option that takes the path to the mount point might also work.  Just
generating the socket cleanly the first time seems better though.

With a netnsfs you could make the lifetime of the namespace the lifetime of the mount.
Which you could make automatically reap when you process or set of processes go away
by using a new mount namespace to hold it all in.

Eric
