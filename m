From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: performance drop after using blkcg
Date: Tue, 11 Dec 2012 06:47:18 -0800
Message-ID: <20121211144718.GF7084__27560.013815719$1355237268$gmane$org@htj.dyndns.org>
References: <CAFVn34SxqAJe_4P-WT8MOiG-kmKKD7ge96zoHXQuGqHWPgAt+A@mail.gmail.com>
	<20121211142518.GA5580@redhat.com>
	<20121211142742.GE7084@htj.dyndns.org>
	<20121211144336.GB5580@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121211144336.GB5580-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Zhao Shuai <zhaoshuai-h+KGxgPPiopAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

On Tue, Dec 11, 2012 at 09:43:36AM -0500, Vivek Goyal wrote:
> I think if one sets slice_idle=0 and group_idle=0 in CFQ, for all practical
> purposes it should become and IOPS based group scheduling.

No, I don't think it is.  You can't achieve isolation without idling
between group switches.  We're measuring slices in terms of iops but
what cfq actually schedules are still time slices, not IOs.

> For group accounting then CFQ uses number of requests from each cgroup
> and uses that information to schedule groups.
> 
> I have not been able to figure out the practical benefits of that
> approach. At least not for the simple workloads I played with. This
> approach will not work for simple things like trying to improve dependent
> read latencies in presence of heavery writers. That's the single biggest
> use case CFQ solves, IMO.

As I wrote above, it's not about accounting.  It's about scheduling
unit.

> And that happens because we stop writes and don't let them go to device
> and device is primarily dealing with reads. If some process is doing
> dependent reads and we want to improve read latencies, then either
> we need to stop flow of writes or devices are good and they always
> prioritize READs over WRITEs. If devices are good then we probably
> don't even need blkcg.
> 
> So yes, iops based appraoch is fine just that number of cases where you
> will see any service differentiation should significantly less.

No, using iops to schedule time slices would lead to that.  We just
need to be allocating and scheduling iops, and I don't think we should
be doing that from cfq.

Thanks.

-- 
tejun
