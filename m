From: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 01/10] Documentation
Date: Sun, 5 Apr 2009 23:50:31 -0700
Message-ID: <e98e18940904052350wc44fdffl480d613c661d5fe6__32475.2202876427$1239000866$gmane$org@mail.gmail.com>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>
	<1236823015-4183-2-git-send-email-vgoyal@redhat.com>
	<20090312001146.74591b9d.akpm@linux-foundation.org>
	<20090312180126.GI10919@redhat.com> <49D8CB17.7040501@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49D8CB17.7040501-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, oz-kernel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sun, Apr 5, 2009 at 8:15 AM, Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On 2009-03-12 19:01, Vivek Goyal wrote:
>> On Thu, Mar 12, 2009 at 12:11:46AM -0700, Andrew Morton wrote:
>>> On Wed, 11 Mar 2009 21:56:46 -0400 Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrot=
e:
> [snip]
>>> Also.. =A0there are so many IO controller implementations that I've lost
>>> track of who is doing what. =A0I do have one private report here that
>>> Andreas's controller "is incredibly productive for us and has allowed
>>> us to put twice as many users per server with faster times for all
>>> users". =A0Which is pretty stunning, although it should be viewed as a
>>> condemnation of the current code, I'm afraid.
>>>
>>
>> I had looked briefly at Andrea's implementation in the past. I will look
>> again. I had thought that this approach did not get much traction.
>
> Hi Vivek, sorry for my late reply. I periodically upload the latest
> versions of io-throttle here if you're still interested:
> http://download.systemimager.org/~arighi/linux/patches/io-throttle/
>
> There's no consistent changes respect to the latest version I posted to
> the LKML, just rebasing to the recent kernels.
>
>>
>> Some quick thoughts about this approach though.
>>
>> - It is not a proportional weight controller. It is more of limiting
>> =A0 bandwidth in absolute numbers for each cgroup on each disk.
>>
>> =A0 So each cgroup will define a rule for each disk in the system mentio=
ning
>> =A0 at what maximum rate that cgroup can issue IO to that disk and throt=
tle
>> =A0 the IO from that cgroup if rate has excedded.
>
> Correct. Add also the proportional weight control has been in the TODO
> list since the early versions, but I never dedicated too much effort to
> implement this feature, I can focus on this and try to write something
> if we all think it is worth to be done.
>
>>
>> =A0 Above requirement can create configuration problems.
>>
>> =A0 =A0 =A0 - If there are large number of disks in system, per cgroup o=
ne shall
>> =A0 =A0 =A0 =A0 have to create rules for each disk. Until and unless adm=
in knows
>> =A0 =A0 =A0 =A0 what applications are in which cgroup and strictly what =
disk
>> =A0 =A0 =A0 =A0 these applications do IO to and create rules for only th=
ose
>> =A0 =A0 =A0 =A0 disks.
>
> I don't think this is a huge problem anyway. IMHO a userspace tool, e.g.
> a script, would be able to efficiently create/modify rules parsing user
> defined rules in some human-readable form (config files, etc.), even in
> presence of hundreds of disk. The same is valid for dm-ioband I think.
>
>>
>> =A0 =A0 =A0 - I think problem gets compounded if there is a hierarchy of
>> =A0 =A0 =A0 =A0 logical devices. I think in that case one shall have to =
create
>> =A0 =A0 =A0 =A0 rules for logical devices and not actual physical device=
s.
>
> With logical devices you mean device-mapper devices (i.e. LVM, software
> RAID, etc.)? or do you mean that we need to introduce the concept of
> "logical device" to easily (quickly) configure IO requirements and then
> map those logical devices to the actual physical devices? In this case I
> think this can be addressed in userspace. Or maybe I'm totally missing
> the point here.
>
>>
>> - Because it is not proportional weight distribution, if some
>> =A0 cgroup is not using its planned BW, other group sharing the
>> =A0 disk can not make use of spare BW.
>>
>
> Right.
>
>> - I think one should know in advance the throughput rate of underlying m=
edia
>> =A0 and also know competing applications so that one can statically defi=
ne
>> =A0 the BW assigned to each cgroup on each disk.
>>
>> =A0 This will be difficult. Effective BW extracted out of a rotational m=
edia
>> =A0 is dependent on the seek pattern so one shall have to either try to =
make
>> =A0 some conservative estimates and try to divide BW (we will not utiliz=
e disk
>> =A0 fully) or take some peak numbers and divide BW (cgroup might not get=
 the
>> =A0 maximum rate configured).
>
> Correct. I think the proportional weight approach is the only solution
> to efficiently use the whole BW. OTOH absolute limiting rules offer a
> better control over QoS, because you can totally remove performance
> bursts/peaks that could break QoS requirements for short periods of
> time. So, my "ideal" IO controller should allow to define both rules:
> absolute and proportional limits.

I completely agree with Andrea here. The final solution has to have
both absolute limits and proportions. But instead of adding a token
based approach on top of proportional based system, I have been
thinking about modifying the proportional approach to support absolute
limits. This might not work, but I think this is an interesting idea
to think about.

Here are my thoughts on it so far. We start with the patches that
Vivek has sent, and change the notion of weights to percent. That is,
the user space specifies percents of disk times instead of weights. We
do not put entities in idle tree; whenever an entity is not
backlogged, we still keep them in the active trees, and allocate them
time slices. But since they have not requests in them, no requests
will get dispatched during the time slices allocated to these
entities. Moreover, if the percents of all entities do not add upto
hundred, we introduce a dummy entity at each level to soak up the rest
of "percent". This dummy entity would get time slices just like any
other entity, but will not dispatch any requests. With these
modification, we can limit entities to their allocated percent of disk
time.

We might want a situation in which we want to allow certain entities
to exceed their "percent" of disk time, while others should be
limited. In this case, we can extend the above mentioned approach by
introducing a secondary active tree. All entities which are allowed to
exceed their "percent" can be queued in the secondary tree, besides
the primary tree. Whenever an idle (or dummy) entity gets a time
slice, instead of idling the disk, an entity can be picked from the
secondary tree.

The advantage of an approach like this is that it will be relatively
smaller modification of the proposed proportional approach. Moreover,
entities will be throttled by getting time slices less frequently,
instead of being allowed to send a burst and then getting starved
(like in ticket based approach). The downside is that this approach
sounds unconventional and probably have not been tried in other
domains either. Thoughts? opinions?

I will create patches based on the above idea in a few weeks.

>
> I still have to look closely at your patchset anyway. I will do and give
> a feedback.
>
> -Andrea
>
