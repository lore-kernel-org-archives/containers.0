From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 01/10] Documentation
Date: Sun, 05 Apr 2009 17:15:35 +0200
Message-ID: <49D8CB17.7040501__49084.9561560482$1238944843$gmane$org@gmail.com>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>
	<1236823015-4183-2-git-send-email-vgoyal@redhat.com>
	<20090312001146.74591b9d.akpm@linux-foundation.org>
	<20090312180126.GI10919@redhat.com>
Reply-To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090312180126.GI10919-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, oz-kernel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2009-03-12 19:01, Vivek Goyal wrote:
> On Thu, Mar 12, 2009 at 12:11:46AM -0700, Andrew Morton wrote:
>> On Wed, 11 Mar 2009 21:56:46 -0400 Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
[snip]
>> Also..  there are so many IO controller implementations that I've lost
>> track of who is doing what.  I do have one private report here that
>> Andreas's controller "is incredibly productive for us and has allowed
>> us to put twice as many users per server with faster times for all
>> users".  Which is pretty stunning, although it should be viewed as a
>> condemnation of the current code, I'm afraid.
>>
> 
> I had looked briefly at Andrea's implementation in the past. I will look
> again. I had thought that this approach did not get much traction.

Hi Vivek, sorry for my late reply. I periodically upload the latest
versions of io-throttle here if you're still interested:
http://download.systemimager.org/~arighi/linux/patches/io-throttle/

There's no consistent changes respect to the latest version I posted to
the LKML, just rebasing to the recent kernels.

> 
> Some quick thoughts about this approach though.
> 
> - It is not a proportional weight controller. It is more of limiting
>   bandwidth in absolute numbers for each cgroup on each disk.
>  
>   So each cgroup will define a rule for each disk in the system mentioning
>   at what maximum rate that cgroup can issue IO to that disk and throttle
>   the IO from that cgroup if rate has excedded.

Correct. Add also the proportional weight control has been in the TODO
list since the early versions, but I never dedicated too much effort to
implement this feature, I can focus on this and try to write something
if we all think it is worth to be done.

> 
>   Above requirement can create configuration problems.
> 
> 	- If there are large number of disks in system, per cgroup one shall
> 	  have to create rules for each disk. Until and unless admin knows
> 	  what applications are in which cgroup and strictly what disk
> 	  these applications do IO to and create rules for only those
>  	  disks.

I don't think this is a huge problem anyway. IMHO a userspace tool, e.g.
a script, would be able to efficiently create/modify rules parsing user
defined rules in some human-readable form (config files, etc.), even in
presence of hundreds of disk. The same is valid for dm-ioband I think.

> 
> 	- I think problem gets compounded if there is a hierarchy of
> 	  logical devices. I think in that case one shall have to create
> 	  rules for logical devices and not actual physical devices.

With logical devices you mean device-mapper devices (i.e. LVM, software
RAID, etc.)? or do you mean that we need to introduce the concept of
"logical device" to easily (quickly) configure IO requirements and then
map those logical devices to the actual physical devices? In this case I
think this can be addressed in userspace. Or maybe I'm totally missing
the point here.

> 
> - Because it is not proportional weight distribution, if some
>   cgroup is not using its planned BW, other group sharing the
>   disk can not make use of spare BW.  
> 	

Right.

> - I think one should know in advance the throughput rate of underlying media
>   and also know competing applications so that one can statically define
>   the BW assigned to each cgroup on each disk.
> 
>   This will be difficult. Effective BW extracted out of a rotational media
>   is dependent on the seek pattern so one shall have to either try to make
>   some conservative estimates and try to divide BW (we will not utilize disk
>   fully) or take some peak numbers and divide BW (cgroup might not get the
>   maximum rate configured).

Correct. I think the proportional weight approach is the only solution
to efficiently use the whole BW. OTOH absolute limiting rules offer a
better control over QoS, because you can totally remove performance
bursts/peaks that could break QoS requirements for short periods of
time. So, my "ideal" IO controller should allow to define both rules:
absolute and proportional limits.

I still have to look closely at your patchset anyway. I will do and give
a feedback.

-Andrea
