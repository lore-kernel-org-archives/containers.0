From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 08/11] cpuset: separate configured masks and efffective
	masks
Date: Fri, 23 Aug 2013 11:33:28 -0400
Message-ID: <20130823153328.GD3277__27841.3736996756$1377272028$gmane$org@htj.dyndns.org>
References: <52148F52.0@huawei.com> <52148FCA.8010704@huawei.com>
	<20130821140846.GH19286@mtj.dyndns.org> <52171367.90005@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <52171367.90005-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello, Li.

On Fri, Aug 23, 2013 at 03:46:47PM +0800, Li Zefan wrote:
> On 2013/8/21 22:08, Tejun Heo wrote:
> > On Wed, Aug 21, 2013 at 06:00:42PM +0800, Li Zefan wrote:
> >> @@ -2261,7 +2271,8 @@ static void cpuset_hotplug_workfn(struct work_struct *work)
> >>  	/* synchronize mems_allowed to N_MEMORY */
> >>  	if (mems_updated) {
> >>  		mutex_lock(&callback_mutex);
> >> -		top_cpuset.mems_allowed = new_mems;
> >> +		if (!sane)
> >> +			top_cpuset.mems_allowed = new_mems;
> > 
> > Can you please further explain how the top cgroup behaves?
> > 
> 
> top_cpuset.cpus_allowed will always be cpu_active_mask if sane_behavior
> is not set, otherwise it will always be cpu_possible_mask. While
> top_cpuset.effective_cpus will always be cpu_active_mask in either
> case.

Just in case it wasn't clear, it'd be great if you can also explain
what's going on w.r.t. sane_behavior in the comments and patch
description.  Having dual modes of operation can always be quite
confusing so I think some documentation could be very beneficial.

Thanks!

-- 
tejun
