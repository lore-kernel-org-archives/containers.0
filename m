From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 23/24] cfq-iosched: collect stats from dead cfqgs
Date: Wed, 2 Jan 2013 11:44:15 -0500
Message-ID: <20130102164415.GB4306@redhat.com>
References: <1356726946-26037-1-git-send-email-tj@kernel.org>
	<1356726946-26037-24-git-send-email-tj@kernel.org>
	<20130102162415.GA4306@redhat.com>
	<20130102163010.GC11220@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130102163010.GC11220-9pTldWuhBndy/B6EtB590w@public.gmane.org>
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
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Jan 02, 2013 at 11:30:10AM -0500, Tejun Heo wrote:
> Hey, Vivek.
> 
> On Wed, Jan 02, 2013 at 11:24:15AM -0500, Vivek Goyal wrote:
> > On Fri, Dec 28, 2012 at 12:35:45PM -0800, Tejun Heo wrote:
> > > To support hierarchical stats, it's necessary to remember stats from
> > > dead children.  Add cfqg->dead_stats and make a dying cfqg transfer
> > > its stats to the parent's dead-stats.
> > 
> > Hi Tejun,
> > 
> > Why not directly transfer stats to cfqg->stats. IOW, what's the advantage
> > of maintaining dead_stats separately.
> 
> Backward compatibility?  The existing stat cgroupfs files expect to
> see non-recursive stats.

Oh yes. Missed that. So dead_stats makes sense.

[..]
> > In fact if we have a realiable way of resetting status then online/offline
> > infrastructure might not be required? I think per cpu stats will be a
> > problem though and that's why we probably require logic to online/offline
> > the group?
> 
> Hmmm?  What do you mean?

I mean if we had a reliable way of resetting stats after transferring
then we would not need to keep a track of whether group is online/offline.
We could add everything and adding zero will not change anything. In fact
it will also take care of residual IO (IO which happened after transfer
of stats).

Or I missed the real reason of why do we have group online/offline
infrastructure.

Thanks
Vivek
