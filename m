From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/2 v2] cgroup: Drop task_lock(parent) on cgroup_fork()
Date: Wed, 21 Dec 2011 03:48:52 +0100
Message-ID: <20111221024849.GC17668__36957.3717508048$1324435749$gmane$org@somewhere>
References: <1324432958-20414-1-git-send-email-fweisbec@gmail.com>
	<1324432958-20414-3-git-send-email-fweisbec@gmail.com>
	<4EF14176.9040206@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4EF14176.9040206-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Dec 21, 2011 at 10:16:22AM +0800, Li Zefan wrote:
> Frederic Weisbecker wrote:
> > We don't need to hold the parent task_lock() on the
> > parent in cgroup_fork() because we are already synchronized
> > against the two places that may change the parent css_set
> > concurrently:
> > 
> > - cgroup_exit(), but the parent obviously can't exit concurrently
> > - cgroup migration: we are synchronized against threadgroup_lock()
> > 
> > So we can safely remove the task_lock() there.
> > 
> > Signed-off-by: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> > Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> > Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
> > Cc: Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
> > Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> > Cc: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> > Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
> > Cc: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
> > Cc: Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> > ---
> >  kernel/cgroup.c |   10 +++++++---
> >  1 files changed, 7 insertions(+), 3 deletions(-)
> > 
> > diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> > index 24f6d6f..1999f60 100644
> > --- a/kernel/cgroup.c
> > +++ b/kernel/cgroup.c
> > @@ -4556,7 +4556,7 @@ static const struct file_operations proc_cgroupstats_operations = {
> >   *
> >   * A pointer to the shared css_set was automatically copied in
> >   * fork.c by dup_task_struct().  However, we ignore that copy, since
> > - * it was not made under the protection of RCU or cgroup_mutex, so
> > + * it was not made under the protection of threadgroup_change_begin(), so
> 
> I think the original comment still stands, but now threadgroup_change_begin()
> can also protect the cgroup pointer from becoming invalid.

Right but I'm not sure it's worth quoting RCU and cgroup_mutex. The reason
why we use threadgroup_change_begin() is not only to ensure the pointer
validity but also to synchronize the whole cgroup proc logic. This way
when we attach a whole proc with cgroup_attach_proc(), we are sure that
no thread forked too soon or too late such that it wouldn't be migrated with
the rest.

RCU or cgroup_mutex on dup_task_struct() (+ a get_css_set()) would have
protected the pointer validity but not the whole above described machinery.
So I don't think it's even worth quoting those solutions. But if you prefer
I can keep the old comment.

OTOH what I think is missing in the comment is that explanation on the synchronization
against entire proc migration. I can edit that.

> 
> >   * might no longer be a valid cgroup pointer.  cgroup_attach_task() might
> >   * have already changed current->cgroups, allowing the previously
> >   * referenced cgroup group to be removed and freed.
> > @@ -4566,10 +4566,14 @@ static const struct file_operations proc_cgroupstats_operations = {
> >   */
> >  void cgroup_fork(struct task_struct *child)
> >  {
> > -	task_lock(current);
> > +	/*
> > +	 * We don't need to task_lock() current because current->cgroups
> > +	 * can't be changed concurrently here. The parent obviously hasn't
> > +	 * exited and called cgroup_exit(), and we are synchronized against
> > +	 * cgroup migration through threadgroup_change_begin().
> > +	 */
> >  	child->cgroups = current->cgroups;
> >  	get_css_set(child->cgroups);
> > -	task_unlock(current);
> >  	INIT_LIST_HEAD(&child->cg_list);
> >  }
> >  
