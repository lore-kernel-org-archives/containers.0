From: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: Containers and /proc/sys/vm/drop_caches
Date: Fri, 7 Jan 2011 07:03:48 -0600
Message-ID: <4D270F34.8080305@parallels.com>
References: <20110105094022.GA5366@glandium.org>
	<4D243EC3.1050101@free.fr>	<20110105140159.GC2718@hallyn.com>	<AANLkTi=x=6gUZTxJC8LXxYNu029+firyzKqjMa6m+R-x@mail.gmail.com>
	<20110106214315.GJ29064@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110106214315.GJ29064-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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

On 01/06/2011 03:43 PM, Matt Helsley wrote:
> On Wed, Jan 05, 2011 at 07:46:17PM +0530, Balbir Singh wrote:
>> On Wed, Jan 5, 2011 at 7:31 PM, Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:
>>> Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
>>>> On 01/05/2011 10:40 AM, Mike Hommey wrote:
>>>>> [Copy/pasted from a previous message to lkml, where it was suggested to
>>>>>  try containers@]
>>>>>
>>>>> Hi,
>>>>>
>>>>> I noticed that from within a lxc container, writing "3" to
>>>>> /proc/sys/vm/drop_caches would flush the host page cache. That sounds a
>>>>> little dangerous for VPS offerings that would be based on lxc, as in one
>>>>> VPS instance root user could impact the overall performance of the host.
>>>>> I don't know about other containers but I've been told openvz isn't
>>>>> subject to this problem.
>>>>> I only tested the current Debian Squeeze kernel, which is based on
>>>>> 2.6.32.27.
>>>>
>>>> There is definitively a big work to do with /proc.
>>>>
>>>> Some files should be not accessible (/proc/sys/vm/drop_caches,
>>>> /proc/sys/kernel/sysrq, ...) and some other should be virtualized
>>>> (/proc/meminfo, /proc/cpuinfo, ...).
>>>>
>>>> Serge suggested to create something similar to the cgroup device
>>>> whitelist but for /proc, maybe it is a good approach for denying
>>>> access a specific proc's file.
>>>
>>> Long-term, user namespaces should fix this - /proc will be owned
>>> by the user namespace which mounted it, but we can tell proc to
>>> always have some files (like drop_caches) be owned by init_user_ns.

Changing ownership so a script can't open a file that it otherwise
could may cause scripts to fail when run in a container.  Makes the
containers less transparent.

>>> I'm hoping to push my final targeted capabilities prototype in the
>>> next few weeks, and after that I start seriously attacking VFS
>>> interaction.
>>>
>>> In the meantime, though, you can use SELinux/Smack, or a custom
>>> cgroup file does sound useful.  Can cgroups be modules nowadays?
>>> (I can't keep up)  If so, an out of tree proc-cgroup module seems
>>> like a good interim solution.
>>>
>>
>> Ideally a drop_cache should drop page cache in that container, but
>> given container have a lot of shared page cache, what is suggested
>> might be a good way to work around the problem
> 
> One gross hack that comes to mind: Instead of a hard permission model
> limit the frequency with which the container could actually drop caches.
> Then the container's ability to interfere with host performance is more
> limited (but still non-zero). Or limit frequency on a per-user basis
> (more like Serge's design) because running more containers by a
> compromised user account shouldn't allow more frequent cache dropping.

Disk access causes at best multi-milisecond latency spikes, which can cause
a heavily loaded server to go into thrashing meltdown.  So a container
could screw up another container with this pretty badly.

The easy short-term fix is to make containers silently ignore writes to
drop_caches.

> That said, the more important question is why should we provide
> drop_caches inside a container? My understanding is it's largely a
> workload-debugging tool and not something meant to truly solve
> problems.

A heavily loaded system that goes deep into swap without triggering
the OOM killer can become pretty useless.  My home laptop with 2 gigs
of ram gets so sluggish whenever I compile something that you can't
use the touchpad anymore because hitting the boundary of a widget
with the mouse pointer causes a 5 second freeze while it bounces a
off three or four processes to handle the message, evicting yet more
pages to fault in the pages to handle the X events.  By the time
the pointer moves again it's way overshot.  (Ok, having firefox,
chrome, and kmail open with several dozen tabs open in each may have
something to do with this.)

When it does this, ctrl-alt-f1 echo 1 > /proc/sys/vm/drop_caches
is just about the only thing that will snap it out of it short of
killing processes.  The system has ~600 megs of ram tied up in
disk cache while being so short of anonymous pages the mouse is
useless.

That doesn't necessarily apply to containers but that's one use case
of using it as a stick to hit the darn overburdened machine when it's
making stupid memory allocation decisions.  (Playing with swappiness
puts the OOM killer on a hair trigger, depending on kernel version
du jour.)

However, it's not guaranteed to do anything (the cached data could
be dirty, mmaped by some process, immediately faulted back in
by some other process), so ignoring writes to drop_caches from a
container is probably legal behavior anyway.

Rob
