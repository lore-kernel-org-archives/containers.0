From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 5/7] cgroup_freezer: allow moving tasks in and out of a
	frozen cgroup
Date: Tue, 23 Oct 2012 18:14:14 +0200
Message-ID: <20121023161414.GA18138__34531.1372694143$1351008800$gmane$org@redhat.com>
References: <1350426526-14254-1-git-send-email-tj@kernel.org>
	<1350426526-14254-6-git-send-email-tj@kernel.org>
	<20121022192506.GA27163@redhat.com>
	<20121022212505.GG5951@atj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121022212505.GG5951-OlzNCW9NnSVy/B6EtB590w@public.gmane.org>
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
Cc: rjw-KKrjLPT3xs0@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 10/22, Tejun Heo wrote:
>
> Hello,
>
> On Mon, Oct 22, 2012 at 09:25:06PM +0200, Oleg Nesterov wrote:
> > > @@ -190,12 +201,12 @@ static void freezer_fork(struct task_struct *task)
> > >  		goto out;
> > >
> > >  	spin_lock_irq(&freezer->lock);
> > > -	BUG_ON(freezer->state == CGROUP_FROZEN);
> > > -
> > > -	/* Locking avoids race with FREEZING -> THAWED transitions. */
> > > -	if (freezer->state == CGROUP_FREEZING)
> > > +	/*
> > > +	 * @task might have been just migrated into a FROZEN cgroup.
> >
> > Confused. If it was migrated, then freezer_attach() should take care
> > do freeze_task?
>
> Hmmm... there's a window where a task is migrated but ->attach()
> hasn't completed yet, so freezer_attach() might not have kicked in
> yet.

Yes, I see.

Indeed, cgroup_task_migrate() is called before ->attach().

Thanks!

Oleg.
