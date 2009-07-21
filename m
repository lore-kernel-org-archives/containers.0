From: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 21/25] io-controller: Per cgroup request descriptor
	support
Date: Mon, 20 Jul 2009 22:55:31 -0700
Message-ID: <e98e18940907202255y5c7c546ei95d87e5a451ad0c2__15427.5662768216$1248155772$gmane$org@mail.gmail.com>
References: <1246564917-19603-1-git-send-email-vgoyal@redhat.com>
	<1246564917-19603-22-git-send-email-vgoyal@redhat.com>
	<4A655434.5060404@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A655434.5060404-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Jul 20, 2009 at 10:37 PM, Gui
Jianfeng<guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> Vivek Goyal wrote:
>> o Currently a request queue has got fixed number of request descriptors =
for
>> =A0 sync and async requests. Once the request descriptors are consumed, =
new
>> =A0 processes are put to sleep and they effectively become serialized. B=
ecause
>> =A0 sync and async queues are separate, async requests don't impact sync=
 ones
>> =A0 but if one is looking for fairness between async requests, that is n=
ot
>> =A0 achievable if request queue descriptors become bottleneck.
>>
>> o Make request descriptor's per io group so that if there is lots of IO
>> =A0 going on in one cgroup, it does not impact the IO of other group.
>>
>> o This is just one relatively simple way of doing things. This patch will
>> =A0 probably change after the feedback. Folks have raised concerns that =
in
>> =A0 hierchical setup, child's request descriptors should be capped by pa=
rent's
>> =A0 request descriptors. May be we need to have per cgroup per device fi=
les
>> =A0 in cgroups where one can specify the upper limit of request descript=
ors
>> =A0 and whenever a cgroup is created one needs to assign request descrit=
or
>> =A0 limit making sure total sum of child's request descriptor is not mor=
e than
>> =A0 of parent.
>>
>> =A0 I guess something like memory controller. Anyway, that would be the =
next
>> =A0 step. For the time being, we have implemented something simpler as f=
ollows.
>>
>> o This patch implements the per cgroup request descriptors. request pool=
 per
>> =A0 queue is still common but every group will have its own wait list an=
d its
>> =A0 own count of request descriptors allocated to that group for sync an=
d async
>> =A0 queues. So effectively request_list becomes per io group property an=
d not a
>> =A0 global request queue feature.
>>
>> o Currently one can define q->nr_requests to limit request descriptors
>> =A0 allocated for the queue. Now there is another tunable q->nr_group_re=
quests
>> =A0 which controls the requests descriptr limit per group. q->nr_requests
>> =A0 supercedes q->nr_group_requests to make sure if there are lots of gr=
oups
>> =A0 present, we don't end up allocating too many request descriptors on =
the
>> =A0 queue.
>>
>
> =A0Hi Vivek,
>
> =A0In order to prevent q->nr_requests from becoming the bottle-neck of al=
locating
> =A0requests, whether we can update nr_requests accordingly when allocatin=
g or removing
> =A0a cgroup?

Vivek,
I agree with Gui here. In fact, it does not make much sense to keep
the nr_requests limit if we already have per cgroup limit in place.
This change also simplifies code quite a bit, as we can get rid of all
that sleep_on_global logic.

>
> --
> Regards
> Gui Jianfeng
>
>
