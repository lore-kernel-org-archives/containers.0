From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/4] cgroup freezer: Avoid lazy state changes when
	convenient
Date: Wed, 3 Jun 2009 10:52:42 -0700
Message-ID: <20090603175242.GQ9285@us.ibm.com>
References: <cover.1244019829.git.matthltc@us.ibm.com>
	<03412f8681d89c99ac575330381ab49f6e5e61ba.1244019829.git.matthltc@us.ibm.com>
	<20090603161046.GC7848@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090603161046.GC7848-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Jun 03, 2009 at 11:10:46AM -0500, Serge E. Hallyn wrote:
> Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> >  When all the tasks of a cgroup were successfully frozen we can avoid
> >  the lazy FREEZING -> FROZEN transition and move into FROZEN during the
> >  write to freezer.state.
> 
> Can you remind us then what the point of the FREEZING state is?
> It doesn't look to me like, after this patch, a cgroup will
> ever be FREEZING?

FREEZING is an intermediate state indicating that the cgroup is
partially frozen and, unless userspace retries, it will remain so. 

This can happen when a task in the cgroup is busy doing vfork. Only
when the vfork completes can the task be frozen. How long it
will take for the vfork to complete is defined by the vfork-ing task.
Rather than sleep, the cgroup freezer proceeds to try to freeze
each remaining task in the cgroup before returning while still in the 
FREEZING state. 

This gives userspace a chance to choose for itself whether to retry
(echo FROZEN > freezer.state) or to cancel (echo THAWED > freezer.state).
It also ensures that userspace can take advantage of forward progress
rather than having each task in the cgroup race to the next vfork and
thereby postpone freezing indefinitely.

Because the FREEZING to FROZEN transition only happens upon entrance
to the read or write paths one additional write or read of freezer.state
is necessary. This patch allows userspace to skip that step when all the
tasks in the cgroup have been successfully frozen (num_cant_freeze_now == 0).

Cheers,
	-Matt

> 
> > Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > ---
> >  kernel/cgroup_freezer.c |    5 ++++-
> >  1 files changed, 4 insertions(+), 1 deletions(-)
> > 
> > diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
> > index 765e2c1..19702ac 100644
> > --- a/kernel/cgroup_freezer.c
> > +++ b/kernel/cgroup_freezer.c
> > @@ -286,7 +286,10 @@ static int try_to_freeze_cgroup(struct cgroup *cgroup, struct freezer *freezer)
> >  	}
> >  	cgroup_iter_end(cgroup, &it);
> > 
> > -	return num_cant_freeze_now ? -EBUSY : 0;
> > +	if (num_cant_freeze_now)
> > +		return -EBUSY;
> > +	freezer->state = CGROUP_FROZEN;
> > +	return 0;
> >  }
> > 
> >  static void unfreeze_cgroup(struct cgroup *cgroup, struct freezer *freezer)
> > -- 
> > 1.5.6.3
> > 
> > 
> > _______________________________________________
> > Containers mailing list
> > Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> > https://lists.linux-foundation.org/mailman/listinfo/containers
