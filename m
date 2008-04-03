From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC][patch 3/11][CFQ-cgroup] Introduce cgroup subsystem
Date: Thu, 03 Apr 2008 10:39:09 +0800
Message-ID: <47F4434D.9030800__8854.52088336951$1207190598$gmane$org@cn.fujitsu.com>
References: <007801c893d9$d89726f0$89c574d0$@jp.nec.com>	
	<008001c893db$4e2eccf0$ea8c66d0$@jp.nec.com>
	<6599ad830804021541s3c1e3197y77d87f63bf47e4b3@mail.gmail.com>
	<003001c89532$dae5dd20$90b19760$@jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <003001c89532$dae5dd20$90b19760$@jp.nec.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Satoshi UCHIDA <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, 'Paul Menage' <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, tom-sugawara-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org
List-Id: containers.vger.kernel.org

Satoshi UCHIDA wrote:
> Thank you for reply.
> 
>>>  +
>>>  +static struct cgroup_subsys_state *
>>>  +cfq_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>>>  +{
>>>  +       struct cfq_cgroup *cfqc;
>>>  +
>>>  +       if (!capable(CAP_SYS_ADMIN))
>>>  +               return ERR_PTR(-EPERM);
>>>  +
>>>  +       if (!cgroup_is_descendant(cont))
>>>  +               return ERR_PTR(-EPERM);
>> What are these checks for? Cgroups already provides filesystem
>> permissions to control directory creation, and the "descendant" check
>> looks like it may have been cut/pasted from the nsproxy subsystem.
>>
> 
> This code was referred one of io-throttle.
> Is it not necessary these checks?
> IF not necessary, remove this code.
> 
>>>   /* */
>>>  +
>>>  +#ifdef CONFIG_CGROUP_CFQ
>>>  +SUBSYS(cfq_cgroup)
>>>  +#endif
>>>  +
>>>  +/* */
>> To fit with the convention for other subsystems, simply "cfq" would be
>> a better name than "cfq_cgroup". (Clearly it's a cgroup subsystem from
>> context).
>>
> 
> Ok, I change name.
> I hesitated whether using "_cgroup".
> The cpuset and the cpuacct does not use it,
> but cpu and memory uses it(cpu_cgroup and mem_cgroup).
> In this patchset, I select the latter case.
> 

+struct cgroup_subsys cfq_cgroup_subsys = {
+	.name = "cfq_cgroup",
+	...
+};

but memory controller has the name 'memory', similar for cgroup sched.

So we do this:
	mount -t cgroup -omemory xxx /dev/memcg
but not:
	mount -t cgroup -omemory_cgroup xxx /dev/memcg
