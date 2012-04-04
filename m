From: Shaohua Li <shli-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: IOPS based scheduler (Was: Re: [PATCH 18/21] blkcg: move
	blkio_group_conf->weight to cfq)
Date: Wed, 4 Apr 2012 05:35:49 -0700
Message-ID: <CANejiEU1qAsvogozY3MjZnpcrbYZO4CkRE8s73WGPc_R5LKV9g__46478.8323770792$1333542961$gmane$org@mail.gmail.com>
References: <1332975091-10950-19-git-send-email-tj@kernel.org>
	<4F7A1C8B.3010402@tao.ma>
	<20120402214938.GA19634@dhcp-172-17-108-109.mtv.corp.google.com>
	<4F7A2217.2030201@tao.ma>
	<20120402221702.GA21017@dhcp-172-17-108-109.mtv.corp.google.com>
	<4F7A261A.9000200@tao.ma> <20120402222504.GA2672@redhat.com>
	<4F7A2B21.5000907@tao.ma> <20120403153736.GI5913@redhat.com>
	<4F7B2708.6080504@tao.ma> <20120403164959.GJ5913@redhat.com>
	<4F7B32AE.7050900@tao.ma>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4F7B32AE.7050900-d1IQDZat3X0@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tao Ma <tm-d1IQDZat3X0@public.gmane.org>
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

2012/4/3 Tao Ma <tm-d1IQDZat3X0@public.gmane.org>:
> On 04/04/2012 12:50 AM, Vivek Goyal wrote:
>> On Wed, Apr 04, 2012 at 12:36:24AM +0800, Tao Ma wrote:
>>
>> [..]
>>>> - Can't we just set the slice_idle=3D0 and "quantum" to some high value
>>>> =A0 say "64" or "128" and achieve similar results to iops based schedu=
ler?
>>> yes, I should say cfq with slice_idle =3D 0 works well in most cases. B=
ut
>>> if it comes to blkcg with ssd, it is really a disaster. You know, cfq
>>> has to choose between different cgroups, so even if you choose 1ms as
>>> the service time for each cgroup(actually in my test, only >2ms can work
>>> reliably). the latency for some requests(which have been sent by the
>>> user while not submitting to the driver) is really too much for the
>>> application. I don't think there is a way to resolve it in cfq.
>>
>> Ok, so now you are saying that CFQ as such is not a problem but blkcg
>> logic in CFQ is an issue.
>>
>> What's the issue there? I think the issue there also is group idling.
>> If you set group_idle=3D0, that idling will be cut down and switching
>> between groups will be fast. That's a different thing that in the
>> process you will most likely lose service differentiation also for
>> most of the workloads.
> No, group_idle=3D0 doesn't help. We don't have problem with idling, the
> disk is busy for all the tasks, we just want it to be proportional and
> time endurable.
>>
>>>
>>>>
>>>> In theory, above will cut down on idling and try to provide fairness in
>>>> terms of time. I thought fairness in terms of time is most fair. The
>>>> most common problem is measurement of time is not attributable to
>>>> individual queue in an NCQ hardware. I guess that throws time measurem=
ent
>>>> of out the window until and unless we have a better algorithm to measu=
re
>>>> time in NCQ environment.
>>>>
>>>> I guess then we can just replace time with number of requests dispatch=
ed
>>>> from a process queue. Allow it to dispatch requests for some time and
>>>> then schedule it out and put it back on service tree and charge it
>>>> according to its weight.
>>> As I have said, in this case, the minimal time(1ms) multiple the group
>>> number is too much for a ssd.
>>>
>>> If we can use iops based scheduler, we can use iops_weight for different
>>> cgroups and switch cgroup according to this number. So all the
>>> applications can have a moderate response time which can be estimated.
>>
>> How iops_weight and switching different than CFQ group scheduling logic?
>> I think shaohua was talking of using similar logic. What would you do
>> fundamentally different so that without idling you will get service
>> differentiation?
> I am thinking of differentiate different groups with iops, so if there
> are 3 groups(the weight are 100, 200, 300) we can let them submit 1 io,
> 2 io and 3 io in a round-robin way. With a intel ssd, every io can be
> finished within 100us. So the maximum latency for one io is about 600us,
> still less than 1ms. But with cfq, if all the cgroups are busy, we have
> to switch between these group in ms which means the maximum latency will
> be 6ms. It is terrible for some applications since they use ssds now.
Yes, with iops based scheduling, we do queue switching for every request.
Doing the same thing between groups is quite straightforward. The only issue
I found is this will introduce more process context switch, this isn't
a big issue
for io bound application, but depends. It cuts latency a lot, which I
guess is more
important for web 2.0 application.
