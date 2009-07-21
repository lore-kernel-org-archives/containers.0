From: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 21/25] io-controller: Per cgroup request descriptor
	support
Date: Tue, 21 Jul 2009 10:57:09 -0700
Message-ID: <e98e18940907211057p629a4f20g693e156217de5a2d__30966.5509303615$1248199843$gmane$org@mail.gmail.com>
References: <1246564917-19603-1-git-send-email-vgoyal@redhat.com>
	<1246564917-19603-22-git-send-email-vgoyal@redhat.com>
	<4A655434.5060404@cn.fujitsu.com>
	<e98e18940907202255y5c7c546ei95d87e5a451ad0c2@mail.gmail.com>
	<20090721140134.GB540@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090721140134.GB540-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Jul 21, 2009 at 7:01 AM, Vivek Goyal<vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Mon, Jul 20, 2009 at 10:55:31PM -0700, Nauman Rafique wrote:
>> On Mon, Jul 20, 2009 at 10:37 PM, Gui
>> Jianfeng<guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>> > Vivek Goyal wrote:
>> >> o Currently a request queue has got fixed number of request descripto=
rs for
>> >> =A0 sync and async requests. Once the request descriptors are consume=
d, new
>> >> =A0 processes are put to sleep and they effectively become serialized=
. Because
>> >> =A0 sync and async queues are separate, async requests don't impact s=
ync ones
>> >> =A0 but if one is looking for fairness between async requests, that i=
s not
>> >> =A0 achievable if request queue descriptors become bottleneck.
>> >>
>> >> o Make request descriptor's per io group so that if there is lots of =
IO
>> >> =A0 going on in one cgroup, it does not impact the IO of other group.
>> >>
>> >> o This is just one relatively simple way of doing things. This patch =
will
>> >> =A0 probably change after the feedback. Folks have raised concerns th=
at in
>> >> =A0 hierchical setup, child's request descriptors should be capped by=
 parent's
>> >> =A0 request descriptors. May be we need to have per cgroup per device=
 files
>> >> =A0 in cgroups where one can specify the upper limit of request descr=
iptors
>> >> =A0 and whenever a cgroup is created one needs to assign request desc=
ritor
>> >> =A0 limit making sure total sum of child's request descriptor is not =
more than
>> >> =A0 of parent.
>> >>
>> >> =A0 I guess something like memory controller. Anyway, that would be t=
he next
>> >> =A0 step. For the time being, we have implemented something simpler a=
s follows.
>> >>
>> >> o This patch implements the per cgroup request descriptors. request p=
ool per
>> >> =A0 queue is still common but every group will have its own wait list=
 and its
>> >> =A0 own count of request descriptors allocated to that group for sync=
 and async
>> >> =A0 queues. So effectively request_list becomes per io group property=
 and not a
>> >> =A0 global request queue feature.
>> >>
>> >> o Currently one can define q->nr_requests to limit request descriptors
>> >> =A0 allocated for the queue. Now there is another tunable q->nr_group=
_requests
>> >> =A0 which controls the requests descriptr limit per group. q->nr_requ=
ests
>> >> =A0 supercedes q->nr_group_requests to make sure if there are lots of=
 groups
>> >> =A0 present, we don't end up allocating too many request descriptors =
on the
>> >> =A0 queue.
>> >>
>> >
>> > =A0Hi Vivek,
>> >
>> > =A0In order to prevent q->nr_requests from becoming the bottle-neck of=
 allocating
>> > =A0requests, whether we can update nr_requests accordingly when alloca=
ting or removing
>> > =A0a cgroup?
>>
>> Vivek,
>> I agree with Gui here. In fact, it does not make much sense to keep
>> the nr_requests limit if we already have per cgroup limit in place.
>> This change also simplifies code quite a bit, as we can get rid of all
>> that sleep_on_global logic.
>>
>
> Hi Nauman, Gui,
>
> There were few reasons to keep a total limit on number of request
> descriptors (q->nr_requests) apart from per group limit.
>
> - We have this notion of queue being congested or not depending on out of
> =A0q->nr_requests how many are currently being used. Writeback threads,
> =A0some filesystems and other places make use of this information to eith=
er
> =A0not to block or to avoid pushing too much of data on device if queue is
> =A0congested.
>
> =A0With q->nr_requests removed, how do you define queue full and congested
> =A0semantics?

We can still keep q->nr_requests around, but don't use that number to
deny request descriptor allocation; only use it for defining queue
full and congested semantics.

>
> - I think slee_on_global logic makes sense even without q->nr_requests.
> =A0Assume that a group allows request descriptor allocation but due to la=
ck
> =A0of memory, allocation fails. Where do you make this process wait to
> =A0attempt next time? Making all such failed processes on gloabl list on
> =A0queue instead of per group list makes more sense to me for following
> =A0reasons.
>
> =A0 =A0 =A0 =A0- If this is the first request allocation from the group a=
nd we
> =A0 =A0 =A0 =A0 =A0make the process sleep on group list, it will never be=
 woken up
> =A0 =A0 =A0 =A0 =A0as no request from that group will complete.
>
> =A0 =A0 =A0 =A0- If there are many processes who failed request descriptor
> =A0 =A0 =A0 =A0 =A0allocation, when some request completes, I think it is=
 more
> =A0 =A0 =A0 =A0 =A0fair to wake these up in FIFO manner to try out alloca=
tion again
> =A0 =A0 =A0 =A0 =A0instead of waiting for request to complete from the gr=
oup
> =A0 =A0 =A0 =A0 =A0process belongs to. The reason being that io controlle=
r did not
> =A0 =A0 =A0 =A0 =A0fail the request descriptor allocation.
>
> =A0So even if you get rid of q->nr_requests, you still shall have to have
> =A0some logic of global wait list where failed allocations can wait.
>
> - It is backward compatible and there are less chances of higher layers
> =A0being broken due to this.
>
>
> Gui, I think automatic updation of q->nr_requests is probably not a very
> good thing. It is user defined tunable and user does not expect this to
> change automatically.
>
> At this point of time I really can't think of simpler and cleaner way.
> Ideas are welcome.
>
> Thanks
> Vivek
>
