From: Tao Ma <tm-d1IQDZat3X0@public.gmane.org>
Subject: Re: IOPS based scheduler (Was: Re: [PATCH 18/21] blkcg: move
	blkio_group_conf->weight to cfq)
Date: Wed, 04 Apr 2012 00:36:24 +0800
Message-ID: <4F7B2708.6080504__1981.38605705953$1333470999$gmane$org@tao.ma>
References: <1332975091-10950-1-git-send-email-tj@kernel.org>
	<1332975091-10950-19-git-send-email-tj@kernel.org>
	<4F7A1C8B.3010402@tao.ma>
	<20120402214938.GA19634@dhcp-172-17-108-109.mtv.corp.google.com>
	<4F7A2217.2030201@tao.ma>
	<20120402221702.GA21017@dhcp-172-17-108-109.mtv.corp.google.com>
	<4F7A261A.9000200@tao.ma> <20120402222504.GA2672@redhat.com>
	<4F7A2B21.5000907@tao.ma> <20120403153736.GI5913@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120403153736.GI5913-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Shaohua Li <shli-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

add Shaohua to the cc list,
On 04/03/2012 11:37 PM, Vivek Goyal wrote:
> On Tue, Apr 03, 2012 at 06:41:37AM +0800, Tao Ma wrote:
>> On 04/03/2012 06:25 AM, Vivek Goyal wrote:
>>> On Tue, Apr 03, 2012 at 06:20:10AM +0800, Tao Ma wrote:
>>>
>>> [..]
>>>>> Yeah, just add config and stat files prefixed with the name of the new
>>>>> blkcg policy.
>>>> OK, I will add a new config file for it.
>>>
>>> Only if CFQ could be modified to add one iops mode, flippable through a
>>> sysfs tunable, things will be much simpler. You will not have to add a
>>> new IO scheduler, no new configuration/stat files in blkcg (which is
>>> already crowded now).
>>>
>>> I don't think anybody has shown the code that why CFQ can't be modified
>>> to support iops mode.
>> Yes, I have thought of it, but it seems to me that time slice is deeply
>> involved within the cfq(even current cfq's iops mode has used time slice
>> to calculate). So I don't think it is feasible for me to change it. And
>> cfq works perfectly well for sas/sata environment and the code is quite
>> stable, more codes and more complicate algorithm does mean more bugs. So
>> I guess a new iops based scheduler is easy and not intrusive for the
>> user(since he can choose whether to use it or not).
> 
> Ok, let me take one step back.
> 
> - What's the goal of iops based scheduler. In what kind of workload and
>   storage it is going to help.
> 
> - Can't we just set the slice_idle=0 and "quantum" to some high value
>   say "64" or "128" and achieve similar results to iops based scheduler?
yes, I should say cfq with slice_idle = 0 works well in most cases. But
if it comes to blkcg with ssd, it is really a disaster. You know, cfq
has to choose between different cgroups, so even if you choose 1ms as
the service time for each cgroup(actually in my test, only >2ms can work
reliably). the latency for some requests(which have been sent by the
user while not submitting to the driver) is really too much for the
application. I don't think there is a way to resolve it in cfq.

> 
> In theory, above will cut down on idling and try to provide fairness in
> terms of time. I thought fairness in terms of time is most fair. The
> most common problem is measurement of time is not attributable to
> individual queue in an NCQ hardware. I guess that throws time measurement
> of out the window until and unless we have a better algorithm to measure
> time in NCQ environment.
> 
> I guess then we can just replace time with number of requests dispatched
> from a process queue. Allow it to dispatch requests for some time and
> then schedule it out and put it back on service tree and charge it 
> according to its weight.
As I have said, in this case, the minimal time(1ms) multiple the group
number is too much for a ssd.

If we can use iops based scheduler, we can use iops_weight for different
cgroups and switch cgroup according to this number. So all the
applications can have a moderate response time which can be estimated.

btw, I have talked with Shaohua in LSF and we made a consensus that I
will continue his work and try to add cgroup support to it.

Thanks
Tao
> 
> This all works only if we have right workload. The workloads which are
> not doing dependent reads and can keep the disk busy continuously. If
> there is think time involved, and we do not idle, process will lose its
> share and whole scheme of trying to differentiate between processes will
> become ineffective.
> 
> So if you have come with a better algorith which can keep track of iops
> without idling and still provide service differentiation for common 
> workloads, it will be interesting. 
> 
> Thanks
> Vivek
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
