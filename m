From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 10/11] cpuset: allow writing offlined masks to
	cpuset.cpus/mems
Date: Fri, 23 Aug 2013 15:37:12 +0800
Message-ID: <52171128.3070206@huawei.com>
References: <52148F52.0@huawei.com> <52148FF1.5060503@huawei.com>
	<20130821141851.GJ19286@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130821141851.GJ19286-9pTldWuhBndy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 2013/8/21 22:18, Tejun Heo wrote:
> Hello,
> 
> On Wed, Aug 21, 2013 at 06:01:21PM +0800, Li Zefan wrote:
>> -		if (!cpumask_subset(trialcs->cpus_allowed, cpu_active_mask))
>> +		if (!cpumask_subset(trialcs->cpus_allowed,
>> +				    top_cpuset.cpus_allowed))
> 
> Hmmm... top_cpuset.cpus_allowed is filled using cpumask_setall(),
> which may include more bits than cpu_possible_mask, which is kinda
> weird.  We probably wanna initialize it with cpu_possible_mask and
> also maybe using cpu_possible_mask in the above would be clearer?

In cpuset_init(), all the bits in cpus_allowed are set. Then in
cpuset_init_smp(), it's set to cpu_active_mask.

so we should set top_cpuset.cpus_allowed to possible_mask if mount
with sane_behavior, otherwise set it to active_mask.

> 
> Also, shouldn't this be dependent upon sane_behavior?
> 

We already treat top_cpus.cpus_allowed differently depending on
save_behavior, so the if statement works correctly.
