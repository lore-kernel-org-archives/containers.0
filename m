From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 17/24] blkcg: implement blkcg_policy->on/offline_pd_fn()
	and blkcg_gq->online
Date: Wed, 2 Jan 2013 15:37:18 -0500
Message-ID: <20130102203718.GE11220__1533.37738379395$1357159067$gmane$org@mtj.dyndns.org>
References: <1356726946-26037-1-git-send-email-tj@kernel.org>
	<1356726946-26037-18-git-send-email-tj@kernel.org>
	<20130102193828.GE4306@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130102193828.GE4306-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

On Wed, Jan 02, 2013 at 02:38:28PM -0500, Vivek Goyal wrote:
> On Fri, Dec 28, 2012 at 12:35:39PM -0800, Tejun Heo wrote:
> 
> [..]
> > diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
> > index 40f5b97..678e89e 100644
> > --- a/block/blk-cgroup.h
> > +++ b/block/blk-cgroup.h
> > @@ -106,12 +106,17 @@ struct blkcg_gq {
> >  	/* reference count */
> >  	int				refcnt;
> >  
> > +	/* is this blkg online? protected by both blkcg and q locks */
> > +	bool				online;
> > +
> 
> Hi Tejun,
> 
> What does above mean? One needs to take one lock or both the locks to
> check/modify blkg->online.

Needs both locks to modify, so either lock is enough for checking.

-- 
tejun
