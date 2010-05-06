From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v21 015/100] cgroup freezer: Update stale locking comments
Date: Thu, 6 May 2010 13:31:17 -0700
Message-ID: <20100506203117.GM31830__48868.9264901497$1273182208$gmane$org@count0.beaverton.ibm.com>
References: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
	<1272723382-19470-16-git-send-email-orenl@cs.columbia.edu>
	<201005062140.19821.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <201005062140.19821.rjw-KKrjLPT3xs0@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Cc: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, May 06, 2010 at 09:40:19PM +0200, Rafael J. Wysocki wrote:
> On Saturday 01 May 2010, Oren Laadan wrote:
> > From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > 
> > Update stale comments regarding locking order and add a little more detail
> > so it's easier to follow the locking between the cgroup freezer and the
> > power management freezer code.
> 
> I guess these three patches are for me.
> 
> Do you want me to handle them?
> 
> Rafael

Hi Rafael,

	I think you can take 15 as it's an update to the comments.

16 and 17 are specific to checkpoint/restart. There are no other in-kernel
uses, that we've identified, for them. So I was under the impression that it's
inappropriate to add them without also adding the checkpoint/restart patches
that use them.

Thanks!

Cheers,
	-Matt Helsley

> 
> 
> > Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > Cc: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> > Cc: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>
> > Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> > Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> > Cc: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>
> > Cc: linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> > ---
> >  kernel/cgroup_freezer.c |   21 +++++++++++++--------
> >  1 files changed, 13 insertions(+), 8 deletions(-)
> > 
> > diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
> > index da5e139..85f19cc 100644
> > --- a/kernel/cgroup_freezer.c
> > +++ b/kernel/cgroup_freezer.c
> > @@ -89,10 +89,10 @@ struct cgroup_subsys freezer_subsys;
> >  
> >  /* Locks taken and their ordering
> >   * ------------------------------
> > - * css_set_lock
> >   * cgroup_mutex (AKA cgroup_lock)
> > - * task->alloc_lock (AKA task_lock)
> >   * freezer->lock
> > + * css_set_lock
> > + * task->alloc_lock (AKA task_lock)
> >   * task->sighand->siglock
> >   *
> >   * cgroup code forces css_set_lock to be taken before task->alloc_lock
> > @@ -100,33 +100,38 @@ struct cgroup_subsys freezer_subsys;
> >   * freezer_create(), freezer_destroy():
> >   * cgroup_mutex [ by cgroup core ]
> >   *
> > - * can_attach():
> > - * cgroup_mutex
> > + * freezer_can_attach():
> > + * cgroup_mutex (held by caller of can_attach)
> >   *
> > - * cgroup_frozen():
> > + * cgroup_freezing_or_frozen():
> >   * task->alloc_lock (to get task's cgroup)
> >   *
> >   * freezer_fork() (preserving fork() performance means can't take cgroup_mutex):
> > - * task->alloc_lock (to get task's cgroup)
> >   * freezer->lock
> >   *  sighand->siglock (if the cgroup is freezing)
> >   *
> >   * freezer_read():
> >   * cgroup_mutex
> >   *  freezer->lock
> > + *   write_lock css_set_lock (cgroup iterator start)
> > + *    task->alloc_lock
> >   *   read_lock css_set_lock (cgroup iterator start)
> >   *
> >   * freezer_write() (freeze):
> >   * cgroup_mutex
> >   *  freezer->lock
> > + *   write_lock css_set_lock (cgroup iterator start)
> > + *    task->alloc_lock
> >   *   read_lock css_set_lock (cgroup iterator start)
> > - *    sighand->siglock
> > + *    sighand->siglock (fake signal delivery inside freeze_task())
> >   *
> >   * freezer_write() (unfreeze):
> >   * cgroup_mutex
> >   *  freezer->lock
> > + *   write_lock css_set_lock (cgroup iterator start)
> > + *    task->alloc_lock
> >   *   read_lock css_set_lock (cgroup iterator start)
> > - *    task->alloc_lock (to prevent races with freeze_task())
> > + *    task->alloc_lock (inside thaw_process(), prevents race with refrigerator())
> >   *     sighand->siglock
> >   */
> >  static struct cgroup_subsys_state *freezer_create(struct cgroup_subsys *ss,
> > 
> 
