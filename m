From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH][BUGFIX] cgroups: fix pid namespace bug
Date: Wed, 1 Jul 2009 18:36:36 -0700
Message-ID: <6599ad830907011836x5eccc83eyc896a67295a6486d@mail.gmail.com>
References: <4A4C0C60.4050106@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A4C0C60.4050106-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Thanks Li - but as I said to Serge in the email when I brought this up
originally, I already had a patch in mind for this; I've had an intern
(Ben) at Google working on it. His patch (pretty much ready, and being
sent out tomorrow I hope) is pretty similar to yours, but his is on
top of another patch that provides a (currently read-only)
"cgroup.procs" file in each cgroup dir that lists the unique tgids in
the cgroup. So the key in the list of pid arrays is actually a pid_ns
and a file type (indicating procs or tasks) rather than just a pid_ns.

So I think it makes more sense to not use this patch, but to use the
pair of patches that Ben's written, since they provide more overal
functionality.

Paul

On Wed, Jul 1, 2009 at 6:24 PM, Li Zefan<lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> The bug was introduced by commit cc31edceee04a7b87f2be48f9489ebb72d264844
> ("cgroups: convert tasks file to use a seq_file with shared pid array").
>
> We cache a pid array for all threads that are opening the same "tasks"
> file, but the pids in the array are always from the namespace of the
> last process that opened the file, so all other threads will read pids
> from that namespace instead of their own namespaces.
>
> To fix it, we maintain a list of pid arrays, which is keyed by pid_ns.
> The list will be of length 1 at most time.
>
> Reported-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Idea-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
> =A0include/linux/cgroup.h | =A0 11 ++----
> =A0kernel/cgroup.c =A0 =A0 =A0 =A0| =A0 94 ++++++++++++++++++++++++++++++=
+++++------------
> =A02 files changed, 74 insertions(+), 31 deletions(-)
>
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 665fa70..20411d2 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -179,14 +179,11 @@ struct cgroup {
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0struct list_head release_list;
>
> - =A0 =A0 =A0 /* pids_mutex protects the fields below */
> + =A0 =A0 =A0 /* pids_mutex protects pids_list and cached pid arrays. */
> =A0 =A0 =A0 =A0struct rw_semaphore pids_mutex;
> - =A0 =A0 =A0 /* Array of process ids in the cgroup */
> - =A0 =A0 =A0 pid_t *tasks_pids;
> - =A0 =A0 =A0 /* How many files are using the current tasks_pids array */
> - =A0 =A0 =A0 int pids_use_count;
> - =A0 =A0 =A0 /* Length of the current tasks_pids array */
> - =A0 =A0 =A0 int pids_length;
> +
> + =A0 =A0 =A0 /* Linked list of struct cgroup_pids */
> + =A0 =A0 =A0 struct list_head pids_list;
>
> =A0 =A0 =A0 =A0/* For RCU-protected deletion */
> =A0 =A0 =A0 =A0struct rcu_head rcu_head;
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 3737a68..13dddb4 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -47,6 +47,7 @@
> =A0#include <linux/hash.h>
> =A0#include <linux/namei.h>
> =A0#include <linux/smp_lock.h>
> +#include <linux/pid_namespace.h>
>
> =A0#include <asm/atomic.h>
>
> @@ -960,6 +961,7 @@ static void init_cgroup_housekeeping(struct cgroup *c=
grp)
> =A0 =A0 =A0 =A0INIT_LIST_HEAD(&cgrp->children);
> =A0 =A0 =A0 =A0INIT_LIST_HEAD(&cgrp->css_sets);
> =A0 =A0 =A0 =A0INIT_LIST_HEAD(&cgrp->release_list);
> + =A0 =A0 =A0 INIT_LIST_HEAD(&cgrp->pids_list);
> =A0 =A0 =A0 =A0init_rwsem(&cgrp->pids_mutex);
> =A0}
> =A0static void init_cgroup_root(struct cgroupfs_root *root)
> @@ -2201,12 +2203,30 @@ err:
> =A0 =A0 =A0 =A0return ret;
> =A0}
>
> +/*
> + * Cache pids for all threads in the same pid namespace that are
> + * opening the same "tasks" file.
> + */
> +struct cgroup_pids {
> + =A0 =A0 =A0 /* The node in cgrp->pids_list */
> + =A0 =A0 =A0 struct list_head list;
> + =A0 =A0 =A0 /* The cgroup those pids belong to */
> + =A0 =A0 =A0 struct cgroup *cgrp;
> + =A0 =A0 =A0 /* The namepsace those pids belong to */
> + =A0 =A0 =A0 struct pid_namespace *pid_ns;
> + =A0 =A0 =A0 /* Array of process ids in the cgroup */
> + =A0 =A0 =A0 pid_t *tasks_pids;
> + =A0 =A0 =A0 /* How many files are using the this tasks_pids array */
> + =A0 =A0 =A0 int pids_use_count;
> + =A0 =A0 =A0 /* Length of the current tasks_pids array */
> + =A0 =A0 =A0 int pids_length;
> +};
> +
> =A0static int cmppid(const void *a, const void *b)
> =A0{
> =A0 =A0 =A0 =A0return *(pid_t *)a - *(pid_t *)b;
> =A0}
>
> -
> =A0/*
> =A0* seq_file methods for the "tasks" file. The seq_file position is the
> =A0* next pid to display; the seq_file iterator is a pointer to the pid
> @@ -2221,45 +2241,47 @@ static void *cgroup_tasks_start(struct seq_file *=
s, loff_t *pos)
> =A0 =A0 =A0 =A0 * after a seek to the start). Use a binary-search to find=
 the
> =A0 =A0 =A0 =A0 * next pid to display, if any
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 struct cgroup *cgrp =3D s->private;
> + =A0 =A0 =A0 struct cgroup_pids *cp =3D s->private;
> + =A0 =A0 =A0 struct cgroup *cgrp =3D cp->cgrp;
> =A0 =A0 =A0 =A0int index =3D 0, pid =3D *pos;
> =A0 =A0 =A0 =A0int *iter;
>
> =A0 =A0 =A0 =A0down_read(&cgrp->pids_mutex);
> =A0 =A0 =A0 =A0if (pid) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 int end =3D cgrp->pids_length;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int end =3D cp->pids_length;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0while (index < end) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int mid =3D (index + end) =
/ 2;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cgrp->tasks_pids[mid] =
=3D=3D pid) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cp->tasks_pids[mid] =3D=
=3D pid) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0index =3D =
mid;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else if (cgrp->tasks_pids=
[mid] <=3D pid)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else if (cp->tasks_pids[m=
id] <=3D pid)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0index =3D =
mid + 1;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0end =3D mi=
d;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0/* If we're off the end of the array, we're done */
> - =A0 =A0 =A0 if (index >=3D cgrp->pids_length)
> + =A0 =A0 =A0 if (index >=3D cp->pids_length)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NULL;
> =A0 =A0 =A0 =A0/* Update the abstract position to be the actual pid that =
we found */
> - =A0 =A0 =A0 iter =3D cgrp->tasks_pids + index;
> + =A0 =A0 =A0 iter =3D cp->tasks_pids + index;
> =A0 =A0 =A0 =A0*pos =3D *iter;
> =A0 =A0 =A0 =A0return iter;
> =A0}
>
> =A0static void cgroup_tasks_stop(struct seq_file *s, void *v)
> =A0{
> - =A0 =A0 =A0 struct cgroup *cgrp =3D s->private;
> + =A0 =A0 =A0 struct cgroup_pids *cp =3D s->private;
> + =A0 =A0 =A0 struct cgroup *cgrp =3D cp->cgrp;
> =A0 =A0 =A0 =A0up_read(&cgrp->pids_mutex);
> =A0}
>
> =A0static void *cgroup_tasks_next(struct seq_file *s, void *v, loff_t *po=
s)
> =A0{
> - =A0 =A0 =A0 struct cgroup *cgrp =3D s->private;
> + =A0 =A0 =A0 struct cgroup_pids *cp =3D s->private;
> =A0 =A0 =A0 =A0int *p =3D v;
> - =A0 =A0 =A0 int *end =3D cgrp->tasks_pids + cgrp->pids_length;
> + =A0 =A0 =A0 int *end =3D cp->tasks_pids + cp->pids_length;
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Advance to the next pid in the array. If this goes off =
the
> @@ -2286,26 +2308,32 @@ static struct seq_operations cgroup_tasks_seq_ope=
rations =3D {
> =A0 =A0 =A0 =A0.show =3D cgroup_tasks_show,
> =A0};
>
> -static void release_cgroup_pid_array(struct cgroup *cgrp)
> +static void release_cgroup_pid_array(struct cgroup_pids *cp)
> =A0{
> + =A0 =A0 =A0 struct cgroup *cgrp =3D cp->cgrp;
> +
> =A0 =A0 =A0 =A0down_write(&cgrp->pids_mutex);
> - =A0 =A0 =A0 BUG_ON(!cgrp->pids_use_count);
> - =A0 =A0 =A0 if (!--cgrp->pids_use_count) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(cgrp->tasks_pids);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 cgrp->tasks_pids =3D NULL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 cgrp->pids_length =3D 0;
> + =A0 =A0 =A0 BUG_ON(!cp->pids_use_count);
> + =A0 =A0 =A0 if (!--cp->pids_use_count) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(&cp->list);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(cp->tasks_pids);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(cp);
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0up_write(&cgrp->pids_mutex);
> =A0}
>
> =A0static int cgroup_tasks_release(struct inode *inode, struct file *file)
> =A0{
> - =A0 =A0 =A0 struct cgroup *cgrp =3D __d_cgrp(file->f_dentry->d_parent);
> + =A0 =A0 =A0 struct seq_file *seq;
> + =A0 =A0 =A0 struct cgroup_pids *cp;
>
> =A0 =A0 =A0 =A0if (!(file->f_mode & FMODE_READ))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
>
> - =A0 =A0 =A0 release_cgroup_pid_array(cgrp);
> + =A0 =A0 =A0 seq =3D file->private_data;
> + =A0 =A0 =A0 cp =3D seq->private;
> +
> + =A0 =A0 =A0 release_cgroup_pid_array(cp);
> =A0 =A0 =A0 =A0return seq_release(inode, file);
> =A0}
>
> @@ -2324,6 +2352,8 @@ static struct file_operations cgroup_tasks_operatio=
ns =3D {
> =A0static int cgroup_tasks_open(struct inode *unused, struct file *file)
> =A0{
> =A0 =A0 =A0 =A0struct cgroup *cgrp =3D __d_cgrp(file->f_dentry->d_parent);
> + =A0 =A0 =A0 struct pid_namespace *pid_ns =3D task_active_pid_ns(current=
);
> + =A0 =A0 =A0 struct cgroup_pids *cp;
> =A0 =A0 =A0 =A0pid_t *pidarray;
> =A0 =A0 =A0 =A0int npids;
> =A0 =A0 =A0 =A0int retval;
> @@ -2350,20 +2380,36 @@ static int cgroup_tasks_open(struct inode *unused=
, struct file *file)
> =A0 =A0 =A0 =A0 * array if necessary
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0down_write(&cgrp->pids_mutex);
> - =A0 =A0 =A0 kfree(cgrp->tasks_pids);
> - =A0 =A0 =A0 cgrp->tasks_pids =3D pidarray;
> - =A0 =A0 =A0 cgrp->pids_length =3D npids;
> - =A0 =A0 =A0 cgrp->pids_use_count++;
> +
> + =A0 =A0 =A0 list_for_each_entry(cp, &cgrp->pids_list, list) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pid_ns =3D=3D cp->pid_ns)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto found;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 cp =3D kzalloc(sizeof(*cp), GFP_KERNEL);
> + =A0 =A0 =A0 if (!cp) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 up_write(&cgrp->pids_mutex);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(pidarray);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 cp->cgrp =3D cgrp;
> + =A0 =A0 =A0 cp->pid_ns =3D pid_ns;
> + =A0 =A0 =A0 list_add(&cp->list, &cgrp->pids_list);
> +found:
> + =A0 =A0 =A0 kfree(cp->tasks_pids);
> + =A0 =A0 =A0 cp->tasks_pids =3D pidarray;
> + =A0 =A0 =A0 cp->pids_length =3D npids;
> + =A0 =A0 =A0 cp->pids_use_count++;
> =A0 =A0 =A0 =A0up_write(&cgrp->pids_mutex);
>
> =A0 =A0 =A0 =A0file->f_op =3D &cgroup_tasks_operations;
>
> =A0 =A0 =A0 =A0retval =3D seq_open(file, &cgroup_tasks_seq_operations);
> =A0 =A0 =A0 =A0if (retval) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 release_cgroup_pid_array(cgrp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 release_cgroup_pid_array(cp);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return retval;
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 ((struct seq_file *)file->private_data)->private =3D cgrp;
> + =A0 =A0 =A0 ((struct seq_file *)file->private_data)->private =3D cp;
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> --
> 1.5.4.rc3
>
