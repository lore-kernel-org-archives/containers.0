From: Andrei Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
Subject: Re: [PATCH] kernel: show current values of ucounts
Date: Thu, 11 Aug 2016 12:57:26 -0700
Message-ID: <20160811195725.GA12438@outlook.office365.com>
References: <1470898933-5336-1-git-send-email-avagin@openvz.org>
	<CAGXu5j+foRDQqe9vTfB1KnE1WZBODFfQz=fUa_kq009uR2i-ng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAGXu5j+foRDQqe9vTfB1KnE1WZBODFfQz=fUa_kq009uR2i-ng-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Aug 11, 2016 at 12:05:12PM -0700, Kees Cook wrote:
> On Thu, Aug 11, 2016 at 12:02 AM, Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> wrote:
> > This patch adds /proc/ucounts where all non-zero ucounts for a current
> > userns are shown.
> 
> Eric would have a better sense of this, but I think we would normally
> avoid putting something in the top-level /proc directory, especially
> for namespace things (which IIUC usually appear in /proc/$pid/ns/).

/proc/$pid/ns contains links to namespaces handles. I am not sure that
it's a good place for this file.

And I'm agree that it may be a good idea to move this file to
/proc/$pid/.  It's like /proc/PID/net.

In thise case we will not need to switch into a user namespace to get
its ucounts.

> 
> Also, this should describe what ucounts are for people unfamiliar with
> them. (i.e. this commit message doesn't really contain a detailed
> description of what's being added.)
> 
> And finally, any changes to /proc need an associated entry in
> Documentation/filesystems/proc.txt

I will add documentation and a better description for this patch.

Thank you for the comments.

> 
> >
> > $ cat /proc/ucounts
> > user:         1000               1
> > net:          1000               1
> > mnt:          1000               2
> > mnt:             0              10
> > cgroup:          0               1
> >
> > There are three columns: type, uid, value.
> >
> > Signed-off-by: Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> > ---
> >  kernel/ucount.c | 121 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
> >  1 file changed, 121 insertions(+)
> >
> > diff --git a/kernel/ucount.c b/kernel/ucount.c
> > index 9d20d5d..02a7b7f 100644
> > --- a/kernel/ucount.c
> > +++ b/kernel/ucount.c
> > @@ -9,6 +9,8 @@
> >  #include <linux/sysctl.h>
> >  #include <linux/slab.h>
> >  #include <linux/hash.h>
> > +#include <linux/seq_file.h>
> > +#include <linux/proc_fs.h>
> >  #include <linux/user_namespace.h>
> >
> >  #define UCOUNTS_HASHTABLE_BITS 10
> > @@ -232,4 +234,123 @@ static __init int user_namespace_sysctl_init(void)
> >  }
> >  subsys_initcall(user_namespace_sysctl_init);
> >
> > +#ifdef CONFIG_PROC_FS
> > +struct ucounts_iterator {
> > +       int     hash;
> > +};
> > +
> > +static void *ucounts_start(struct seq_file *f, loff_t *pos)
> > +{
> > +       struct ucounts_iterator *iter = f->private;
> > +       struct user_namespace *ns = current_user_ns();
> > +       int h, i = 0;
> > +
> > +       spin_lock(&ucounts_lock);
> > +       for (h = 0; h < (1 << UCOUNTS_HASHTABLE_BITS); h++) {
> > +               struct ucounts *ucounts;
> > +
> > +               hlist_for_each_entry(ucounts, &ucounts_hashtable[h], node) {
> > +                       if (ucounts->ns != ns)
> > +                               continue;
> > +                       if (i++ < *pos)
> > +                               continue;
> > +
> > +                       iter->hash = h;
> > +
> > +                       return ucounts;
> > +               }
> > +       }
> > +
> > +       return NULL;
> > +}
> > +
> > +static void ucounts_stop(struct seq_file *f, void *v)
> > +{
> > +       spin_unlock(&ucounts_lock);
> > +}
> 
> I don't see where ucounts_lock is defined, but even still, holding a
> spinlock across start/stop will provide a way DoS anyone else using
> that lock. And sparse will yell at you very loudly for the unbalanced
> locking too. :)
> 
> > +static void *ucounts_next(struct seq_file *f, void *v, loff_t *pos)
> > +{
> > +       struct ucounts_iterator *iter = f->private;
> > +       struct user_namespace *ns = current_user_ns();
> > +       struct ucounts *ucounts = v;
> > +       int h;
> > +
> > +       ++*pos;
> > +
> > +       for (h = iter->hash; h < (1 << UCOUNTS_HASHTABLE_BITS); h++) {
> > +               struct hlist_node *node;
> > +
> > +               if (ucounts == NULL) {
> > +                       node = ucounts_hashtable[h].first;
> > +                       iter->hash = h;
> > +               } else
> > +                       node = ucounts->node.next;
> > +
> > +               ucounts = hlist_entry(node, struct ucounts, node);
> > +
> > +               hlist_for_each_entry_from(ucounts, node) {
> > +                       if (ucounts->ns != ns)
> > +                               continue;
> > +
> > +                       return ucounts;
> > +               }
> > +
> > +               ucounts = NULL;
> > +       }
> > +
> > +       return NULL;
> > +}
> > +
> > +static int ucounts_show(struct seq_file *f, void *v)
> > +{
> > +       static const char * const ns_strs[] = {
> > +                                "user", "pid", "uts", "ipc",
> > +                                "net", "mnt", "cgroup", NULL
> > +       };
> > +       struct user_namespace *ns = current_user_ns();
> > +       struct ucounts *ucounts = v;
> > +       uid_t uid;
> > +       int i;
> > +
> > +       uid = from_kuid_munged(ns, ucounts->uid);
> > +
> > +       for (i = 0; ns_strs[i]; i++) {
> > +               int val = atomic_read(&ucounts->ucount[i]);
> > +
> > +               if (val == 0)
> > +                       continue;
> > +
> > +               seq_printf(f, "%s:\t%10u\t%10d\n", ns_strs[i], uid, val);
> > +       }
> >
> > +       return 0;
> > +}
> > +
> > +static const struct seq_operations ucounts_seq_operations = {
> > +       .start  = ucounts_start,
> > +       .next   = ucounts_next,
> > +       .stop   = ucounts_stop,
> > +       .show   = ucounts_show,
> > +};
> > +
> > +static int ucounts_open(struct inode *inode, struct file *filp)
> > +{
> > +       return seq_open_private(filp, &ucounts_seq_operations,
> > +                                       sizeof(struct ucounts_iterator));
> > +}
> > +
> > +static const struct file_operations proc_ucounts_operations = {
> > +       .open           = ucounts_open,
> > +       .read           = seq_read,
> > +       .llseek         = seq_lseek,
> > +       .release        = seq_release_private,
> > +};
> > +
> > +static int __init proc_ucounts_init(void)
> > +{
> > +       proc_create("ucounts", 0, NULL, &proc_ucounts_operations);
> > +       return 0;
> > +}
> > +fs_initcall(proc_ucounts_init);
> > +#endif /* CONFIG_PROC_FS */
> > --
> > 2.5.5
> >
> 
> -Kees
> 
> -- 
> Kees Cook
> Nexus Security
