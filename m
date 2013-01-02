From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 21/24] blkcg: make blkcg_print_blkgs() grab q locks
	instead of blkcg lock
Date: Wed, 2 Jan 2013 15:45:27 -0500
Message-ID: <20130102204527.GG11220__37185.4680277922$1357159551$gmane$org@mtj.dyndns.org>
References: <1356726946-26037-1-git-send-email-tj@kernel.org>
	<1356726946-26037-22-git-send-email-tj@kernel.org>
	<20130102192700.GA9552@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130102192700.GA9552-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Jan 02, 2013 at 02:27:00PM -0500, Vivek Goyal wrote:
> On Fri, Dec 28, 2012 at 12:35:43PM -0800, Tejun Heo wrote:
> > Instead of holding blkcg->lock while walking ->blkg_list and executing
> > prfill(), RCU walk ->blkg_list and hold the blkg's queue lock while
> > executing prfill().  This makes prfill() implementations easier as
> > stats are mostly protected by queue lock.
> > 
> > This will be used to implement hierarchical stats.
> > 
> 
> Hi Tejun,
> 
> I think dropping blkcg->lock might be a problem. Using RCU we have made
> sure that blkg and q are around. But what about blkg->q.backing_dev_info.dev.
> 
> We can follow bdi->dev pointer in blkg_dev_name(). I am not sure if we
> ever clear it from q or not when device goes away.

If the queue is dead, it wouldn't have policy enabled bit set which is
tested while holding queue lock, so I don't think it's gonna be a
problem.

Thanks.

-- 
tejun
