From: Andrei Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
Subject: Re: [PATCH 1/2] kernel: show current values of user namespace counters
Date: Tue, 16 Aug 2016 15:44:07 -0700
Message-ID: <20160816224406.GA20375@outlook.office365.com>
References: <1471291822-539-1-git-send-email-avagin@openvz.org>
	<1471291822-539-2-git-send-email-avagin@openvz.org>
	<CAGXu5jK0vt9WAaX4a5ihV+iVGFSnn0JJOKAVXocg2VqMV+rxBg@mail.gmail.com>
	<20160816200529.GA1280@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160816200529.GA1280-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Aug 16, 2016 at 03:05:29PM -0500, Serge E. Hallyn wrote:
> Quoting Kees Cook (keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org):
> > On Mon, Aug 15, 2016 at 1:10 PM, Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> wrote:
> > > Recently Eric added user namespace counters.  User namespace counters is
> > > a feature that allows to limit the number of various kernel objects a
> > > user can create. These limits are set via /proc/sys/user/ sysctls on a
> > > per user namespace basis and are applicable to all users in that
> > > namespace.
> > >
> > > This patch adds /proc/PID/userns_counts files to provide current usage
> > > of user namespace counters.
> > >
> > >   > cat /proc/813/userns_counts
> > >   user_namespaces          101000               1
> > >   pid_namespaces           101000               1
> > >   ipc_namespaces           101000               4
> > >   net_namespaces           101000               2
> > >   mnt_namespaces           101000               5
> > >   mnt_namespaces           100000               1
> > >
> > > The meanings of the columns are as follows, from left to right:
> > >
> > >   Name         Object name
> > >   UID          User ID
> > >   Usage        Current usage
> > >
> > > Cc: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> > > Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> > > Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> > > Signed-off-by: Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> > > ---
> > >  fs/proc/array.c                |  57 +++++++++++++++++++++++
> > >  fs/proc/base.c                 |   3 ++
> > >  fs/proc/internal.h             |   1 +
> > >  include/linux/user_namespace.h |   8 ++++
> > >  kernel/ucount.c                | 102 +++++++++++++++++++++++++++++++++++++++++
> > >  5 files changed, 171 insertions(+)
> > >
> > > diff --git a/fs/proc/array.c b/fs/proc/array.c
> > > index 88c7de1..f186625 100644
> > > --- a/fs/proc/array.c
> > > +++ b/fs/proc/array.c
> > > @@ -734,3 +734,60 @@ const struct file_operations proc_tid_children_operations = {
> > >         .release = children_seq_release,
> > >  };
> > >  #endif /* CONFIG_PROC_CHILDREN */
> > > +
> > > +#ifdef CONFIG_USER_NS
> > > +static int ucounts_open(struct inode *inode, struct file *filp)
> > > +{
> > > +       struct ucounts_iterator *iter;
> > > +       struct seq_file *seq;
> > > +       int ret;
> > > +
> > > +       struct task_struct *task;
> > > +       struct user_namespace *ns;
> > > +
> > > +       task = get_proc_task(inode);
> > > +       if (!task)
> > > +               return -ESRCH;
> > > +
> > > +       rcu_read_lock();
> > > +       ns = get_user_ns(__task_cred(task)->user_ns);
> > > +       rcu_read_unlock();
> > > +
> > > +       put_task_struct(task);
> > > +
> > > +       if (ns == NULL)
> > > +               return -ESRCH;
> > > +
> > > +       ret = seq_open_private(filp, &ucounts_seq_operations,
> > > +                                       sizeof(struct ucounts_iterator));
> > > +
> > > +       if (ret) {
> > > +               put_user_ns(ns);
> > > +               return ret;
> > > +       }
> > > +
> > > +       seq = filp->private_data;
> > > +       iter = seq->private;
> > > +       iter->ns = ns;
> > > +
> > > +       return 0;
> > > +}
> > > +
> > > +int ucounts_release(struct inode *inode, struct file *file)
> > > +{
> > > +       struct seq_file *seq = file->private_data;
> > > +       struct ucounts_iterator *iter = seq->private;
> > > +
> > > +       put_user_ns(iter->ns);
> > > +
> > > +       return seq_release_private(inode, file);
> > > +}
> > > +
> > > +
> > > +const struct file_operations proc_ucounts_operations = {
> > > +       .open           = ucounts_open,
> > > +       .read           = seq_read,
> > > +       .llseek         = seq_lseek,
> > > +       .release        = ucounts_release,
> > > +};
> > > +#endif /* CONFIG_USER_NS */
> > > diff --git a/fs/proc/base.c b/fs/proc/base.c
> > > index 54e2702..4252f7a 100644
> > > --- a/fs/proc/base.c
> > > +++ b/fs/proc/base.c
> > > @@ -2910,6 +2910,9 @@ static const struct pid_entry tgid_base_stuff[] = {
> > >         REG("timers",     S_IRUGO, proc_timers_operations),
> > >  #endif
> > >         REG("timerslack_ns", S_IRUGO|S_IWUGO, proc_pid_set_timerslack_ns_operations),
> > > +#ifdef CONFIG_USER_NS
> > > +       REG("userns_counts",  S_IRUGO, proc_ucounts_operations),
> > > +#endif
> > >  };
> > >
> > >  static int proc_tgid_base_readdir(struct file *file, struct dir_context *ctx)
> > > diff --git a/fs/proc/internal.h b/fs/proc/internal.h
> > > index 7931c55..845cadb 100644
> > > --- a/fs/proc/internal.h
> > > +++ b/fs/proc/internal.h
> > > @@ -298,6 +298,7 @@ extern const struct file_operations proc_pid_smaps_operations;
> > >  extern const struct file_operations proc_tid_smaps_operations;
> > >  extern const struct file_operations proc_clear_refs_operations;
> > >  extern const struct file_operations proc_pagemap_operations;
> > > +extern const struct file_operations proc_ucounts_operations;
> > >
> > >  extern unsigned long task_vsize(struct mm_struct *);
> > >  extern unsigned long task_statm(struct mm_struct *,
> > > diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
> > > index 30ffe10..5f824dd 100644
> > > --- a/include/linux/user_namespace.h
> > > +++ b/include/linux/user_namespace.h
> > > @@ -106,6 +106,14 @@ extern ssize_t proc_setgroups_write(struct file *, const char __user *, size_t,
> > >  extern int proc_setgroups_show(struct seq_file *m, void *v);
> > >  extern bool userns_may_setgroups(const struct user_namespace *ns);
> > >  extern bool current_in_userns(const struct user_namespace *target_ns);
> > > +
> > > +struct ucounts_iterator {
> > > +       struct user_namespace *ns;
> > > +       int     hash;
> > > +};
> > > +
> > > +extern const struct seq_operations ucounts_seq_operations;
> > > +
> > >  #else
> > >
> > >  static inline struct user_namespace *get_user_ns(struct user_namespace *ns)
> > > diff --git a/kernel/ucount.c b/kernel/ucount.c
> > > index 6ebbe9b..cef09e3 100644
> > > --- a/kernel/ucount.c
> > > +++ b/kernel/ucount.c
> > > @@ -9,6 +9,8 @@
> > >  #include <linux/sysctl.h>
> > >  #include <linux/slab.h>
> > >  #include <linux/hash.h>
> > > +#include <linux/seq_file.h>
> > > +#include <linux/proc_fs.h>
> > >  #include <linux/user_namespace.h>
> > >
> > >  #define UCOUNTS_HASHTABLE_BITS 10
> > > @@ -232,4 +234,104 @@ static __init int user_namespace_sysctl_init(void)
> > >  }
> > >  subsys_initcall(user_namespace_sysctl_init);
> > >
> > > +#ifdef CONFIG_PROC_FS
> > > +static void *ucounts_start(struct seq_file *f, loff_t *pos)
> > > +{
> > > +       struct ucounts_iterator *iter = f->private;
> > > +       int h, i = 0;
> > > +
> > > +       spin_lock(&ucounts_lock);
> > 
> > This series is much improved, thanks! However, I still don't think
> > it's a good idea to hold this spinlock across the start/stop lifetime.
> > It creates too many opportunities for abuse. :( Perhaps Eric will have
> > some better ideas about how to deal with this...
> 
> Would it be too limiting to pre-allocate a page and simply fill it out
> right at ucounts_start, so that we can drop the spinlock and simply
> return data from that page?

seq_file works like you described here. It allocates a buffer, then
calls ->start(), fills the buffer and calls ->stop().

seq_file calls only ->next() and ->show() between ->start and stop().

ssize_t seq_read(struct file *file, char __user *buf, size_t size, loff_t *ppos)
{
        if (!m->buf) {
                m->buf = seq_buf_alloc(m->size = PAGE_SIZE);
...
        p = m->op->start(m, &pos);
...
	while (m->count < size) {
		...
                p = m->op->next(m, p, &next);
                if (!p || IS_ERR(p)) {
                        err = PTR_ERR(p);
                        break;
                }

		err = m->op->show(m, p);
                if (seq_has_overflowed(m) || err) {
			...
			break;
		}
		...
	}
        m->op->stop(m, p);
}

In our case, a buffer size will not be bigger then one page, because a
bigger buffer is allocated only if it isn't enough to place one record.

Thanks,
Andrei
