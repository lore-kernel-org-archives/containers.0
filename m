From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 23/24] cfq-iosched: collect stats from dead cfqgs
Date: Wed, 2 Jan 2013 11:52:42 -0500
Message-ID: <20130102165242.GD11220__12810.8774348677$1357145590$gmane$org@mtj.dyndns.org>
References: <1356726946-26037-1-git-send-email-tj@kernel.org>
	<1356726946-26037-24-git-send-email-tj@kernel.org>
	<20130102162415.GA4306@redhat.com>
	<20130102163010.GC11220@mtj.dyndns.org>
	<20130102164415.GB4306@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130102164415.GB4306-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

Hey, Vivek.

On Wed, Jan 02, 2013 at 11:44:15AM -0500, Vivek Goyal wrote:
> > > In fact if we have a realiable way of resetting status then online/offline
> > > infrastructure might not be required? I think per cpu stats will be a
> > > problem though and that's why we probably require logic to online/offline
> > > the group?
> > 
> > Hmmm?  What do you mean?
> 
> I mean if we had a reliable way of resetting stats after transferring
> then we would not need to keep a track of whether group is online/offline.
> We could add everything and adding zero will not change anything. In fact
> it will also take care of residual IO (IO which happened after transfer
> of stats).

Ah... yeah, if we can do atomic transfer, we might be able to do away
with on/offlining.  Couldn't think of a way to do that without
incurring overhead to hot paths.

> Or I missed the real reason of why do we have group online/offline
> infrastructure.

But given that on/offline state is something common to cgroup, I don't
think adding the states to blkcg is a bad idea.  We need it for
reliable iterations anyways.

Thanks.

-- 
tejun
