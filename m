From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: RFC: I/O bandwidth controller
Date: Wed, 13 Aug 2008 19:56:12 +0200
Message-ID: <48A3203C.6090104__45152.5044780739$1218650522$gmane$org@gmail.com>
References: <1218117578.11703.81.camel@sebastian.kern.oss.ntt.co.jp>	
	<48A0A689.40908@gmail.com>
	<loom.20080812T071504-212@post.gmane.org>	
	<20080812.201025.57762305.taka@valinux.co.jp>	
	<48A18854.9020000@gmail.com> <48A18B1F.6080000@gmail.com>	
	<1218549276.4456.100.camel@sebastian.kern.oss.ntt.co.jp>	
	<48A1F62E.4090202@gmail.com>
	<2891419e0808130047o702c9174tf36a4316ed247497@mail.gmail.com>
Reply-To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <2891419e0808130047o702c9174tf36a4316ed247497-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dong-Jae Kang <baramsori72-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ranjitm-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, =?windows-1252?Q?Fernando_Luis_V=E1zquez_Cao?= <fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Dong-Jae Kang wrote:
> Hi,
> =

> 2008/8/13 Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>:
>> Fernando Luis V=E1zquez Cao wrote:
>>> On Tue, 2008-08-12 at 22:29 +0900, Andrea Righi wrote:
>>>> Andrea Righi wrote:
>>>>> Hirokazu Takahashi wrote:
>>>>>>>>>>> 3. & 4. & 5. - I/O bandwidth shaping & General design aspects
>>>>>>>>>>>
>>>>>>>>>>> The implementation of an I/O scheduling algorithm is to a certa=
in extent
>>>>>>>>>>> influenced by what we are trying to achieve in terms of I/O ban=
dwidth
>>>>>>>>>>> shaping, but, as discussed below, the required accuracy can det=
ermine
>>>>>>>>>>> the layer where the I/O controller has to reside. Off the top o=
f my
>>>>>>>>>>> head, there are three basic operations we may want perform:
>>>>>>>>>>>   - I/O nice prioritization: ionice-like approach.
>>>>>>>>>>>   - Proportional bandwidth scheduling: each process/group of pr=
ocesses
>>>>>>>>>>> has a weight that determines the share of bandwidth they receiv=
e.
>>>>>>>>>>>   - I/O limiting: set an upper limit to the bandwidth a group o=
f tasks
>>>>>>>>>>> can use.
>>>>>>>>>> Use a deadline-based IO scheduling could be an interesting path =
to be
>>>>>>>>>> explored as well, IMHO, to try to guarantee per-cgroup minimum b=
andwidth
>>>>>>>>>> requirements.
>>>>>>>>> Please note that the only thing we can do is to guarantee minimum
>>>>>>>>> bandwidth requirement when there is contention for an IO resource=
, which
>>>>>>>>> is precisely what a proportional bandwidth scheduler does. An I m=
issing
>>>>>>>>> something?
>>>>>>>> Correct. Proportional bandwidth automatically allows to guarantee =
min
>>>>>>>> requirements (instead of IO limiting approach, that needs addition=
al
>>>>>>>> mechanisms to achive this).
>>>>>>>>
>>>>>>>> In any case there's no guarantee for a cgroup/application to susta=
in
>>>>>>>> i.e. 10MB/s on a certain device, but this is a hard problem anyway=
, and
>>>>>>>> the best we can do is to try to satisfy "soft" constraints.
>>>>>>> I think guaranteeing the minimum I/O bandwidth is very important. I=
n the
>>>>>>> business site, especially in streaming service system, administrato=
r requires
>>>>>>> the functionality to satisfy QoS or performance of their service.
>>>>>>> Of course, IO throttling is important, but, personally, I think gua=
ranteeing
>>>>>>> the minimum bandwidth is more important than limitation of maximum =
bandwidth
>>>>>>> to satisfy the requirement in real business sites.
>>>>>>> And I know Andrea's io-throttle patch supports the latter case well=
 and it is
>>>>>>> very stable.
>>>>>>> But, the first case(guarantee the minimum bandwidth) is not support=
ed in any
>>>>>>> patches.
>>>>>>> Is there any plans to support it? and Is there any problems in impl=
ementing it?
>>>>>>> I think if IO controller can support guaranteeing the minimum bandw=
idth and
>>>>>>> work-conserving mode simultaneously, it more easily satisfies the r=
equirement
>>>>>>> of the business sites.
>>>>>>> Additionally, I didn't understand "Proportional bandwidth automatic=
ally allows
>>>>>>> to guarantee min
>>>>>>> requirements" and "soft constraints".
>>>>>>> Can you give me a advice about this ?
>>>>>>> Thanks in advance.
>>>>>>>
>>>>>>> Dong-Jae Kang
>>>>>> I think this is what dm-ioband does.
>>>>>>
>>>>>> Let's say you make two groups share the same disk, and give them
>>>>>> 70% of the bandwidth the disk physically has and 30% respectively.
>>>>>> This means the former group is almost guaranteed to be able to use
>>>>>> 70% of the bandwidth even when the latter one is issuing quite
>>>>>> a lot of I/O requests.
>>>>>>
>>>>>> Yes, I know there exist head seek lags with traditional magnetic dis=
ks,
>>>>>> so it's important to improve the algorithm to reduce this overhead.
>>>>>>
>>>>>> And I think it is also possible to add a new scheduling policy to
>>>>>> guarantee the minimum bandwidth. It might be cool if some group can
>>>>>> use guranteed bandwidths and the other share the rest on proportional
>>>>>> bandwidth policy.
>>>>>>
>>>>>> Thanks,
>>>>>> Hirokazu Takahashi.
>>>>> With IO limiting approach minimum requirements are supposed to be
>>>>> guaranteed if the user configures a generic block device so that the =
sum
>>>>> of the limits doesn't exceed the total IO bandwidth of that device. B=
ut,
>>>>> in principle, there's nothing in "throttling" that guarantees "fairne=
ss"
>>>>> among different cgroups doing IO on the same block devices, that means
>>>>> there's nothing to guarantee minimum requirements (and this is the
>>>>> reason because I liked the Satoshi's CFQ-cgroup approach together with
>>>>> io-throttle).
>>>>>
>>>>> A more complicated issue is how to evaluate the total IO bandwidth of=
 a
>>>>> generic device. We can use some kind of averaging/prediction, but
>>>>> basically it would be inaccurate due to the mechanic of disks (head
>>>>> seeks, but also caching, buffering mechanisms implemented directly in=
to
>>>>> the device, etc.). It's a hard problem. And the same problem exists a=
lso
>>>>> for proportional bandwidth as well, in terms of IO rate predictabilit=
y I
>>>>> mean.
>>>> BTW as I said in a previous email, an interesting path to be explored
>>>> IMHO could be to think in terms of IO time. So, look at the time an IO
>>>> request is issued to the drive, look at the time the request is served,
>>>> evaluate the difference and charge the consumed IO time to the
>>>> appropriate cgroup. Then dispatch IO requests in function of the
>>>> consumed IO time debts / credits, using for example a token-bucket
>>>> strategy. And probably the best place to implement the IO time
>>>> accounting is the elevator.
>>> Please note that the seek time for a specific IO request is strongly
>>> correlated with the IO requests that preceded it, which means that the
>>> owner of that request is not the only one to blame if it takes too long
>>> to process it. In other words, with the algorithm you propose we may end
>>> up charging the wrong guy.
>> mmh.. yes. The only scenario I can imagine where this solution is not
>> fair is when there're a lot of guys always requesting the same near
>> blocks and a single guy looking for a single distant block (supposing
>> disk seeks are more expensive than read/write ops).
>>
>> In this case it would be fair to charge a huge amount only to the guy
>> requesting the single distant block and distribute the cost of the seek
>> to move back the head equally among the other guys. Using the algorighm
>> I proposed, instead, both the single "bad" guy and the first "good" guy
>> that moves back the disk head would spend a large sum of IO credits.
>>
> =

> I have a question about your description.
> In I/O controlling, how do you think about the meaning of "fair" among cg=
roups ?

Good question, thanks!

fair =3D equally distribute the IO cost and throttling among cgroups,
instead of equal distribution among processes, and equally among the
processes belonging to the same cgroup.

In the previous scenario the process that moves back the disk head
wouldn't be charged for the whole IO cost. It's the belonging cgroup
that would be charged instead. So, the accounting is perfectly fair from
this point of view, because the cgroup credits are shared among the
processes within the cgroup.

The IO controller instead should be able to apply throttling in a "fair"
way, that means, when the credits are over it should distribute the
throttling time equally among the processes within the cgroup, i.e.
imposing a total_time_to_sleep/N to each process (where N is the number
of processes into the cgroup) or, even better, distribute the
total_time_to_sleep as a function of the previously generated task's IO,
looking at the IO taskstats for example (/proc/PID/io). But this is
another problem anyway.

So, it seems I used a bad example, sorry.

> These days I was confused about it.
> IMHO, if they have a same access time and same access opportunity for
> disk I/O regardless of their I/O style(sequential / random / mixed /
> =85), I think it is fare.
> Of course, in this fair situation, the cgroups with same priority or
> weight can have a different I/O bandwidth. but, I think it will be in
> reasonable range.
> So, if other cgroups with fast I/O was sacrificed for the cgroup with
> too late I/O to equaliz the I/O quantity, it can be considered
> "unfair" for the cgroup with fast I/O
> Do I have something wrong about the "fair" concept?
> This is just my opinion :)
> I welcome and appreciate for other opinions and comments about this
> =

> PS)
> Andrea, this question is not related to the io-controller
> But, I just wonder your another project, network io-throttle, is going
> on now? My colleague has researched the similar project and he is try
> to implement another one. And i am also interested in net
> io-controller. Thank you

For net-io-controller there's a better solution than mine, have a look
at this:

http://lkml.org/lkml/2008/7/24/455

-Andrea
