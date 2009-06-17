From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 100/148] cgroups: convert tasks file to use a seq_file
	with shared pid array
Date: Tue, 16 Jun 2009 21:46:54 -0700
Message-ID: <6599ad830906162146n5a79b9b8n3b7dd0e72c72ab7@mail.gmail.com>
References: <200810190328.m9J3S4aB000311@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <200810190328.m9J3S4aB000311-AB4EexQrvXRQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

It just struck me that this patch broke access to the tasks file in
the presence of multiple pid namespaces, since the pids in the cached
pid array are always from the namespace of the last process to open
the file. Since I suspect no-one uses pid namespaces in production
environments this probably isn't a show-stopper, but to be technically
correct we need to maintain a list of cached pid arrays keyed by pid
namespace. (This list should generally be very short, usually of
length 1).

Paul

On Sat, Oct 18, 2008 at 8:28 PM, <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
> From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>
> Rather than pre-generating the entire text for the "tasks" file each
> time the file is opened, we instead just generate/update the array of
> process ids and use a seq_file to report these to userspace. =A0All open
> file handles on the same "tasks" file can share a pid array, which may
> be updated any time that no thread is actively reading the array. =A0By
> sharing the array, the potential for userspace to DoS the system by
> opening many handles on the same "tasks" file is removed.
>
> [Based on a patch by Lai Jiangshan, extended to use seq_file]
>
> Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Reviewed-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> Cc: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Cc: Balbir Singh <balbir-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
> ---
>
> =A0include/linux/cgroup.h | =A0 10 +
> =A0kernel/cgroup.c =A0 =A0 =A0 =A0| =A0226 ++++++++++++++++++++++++------=
---------
> =A02 files changed, 151 insertions(+), 85 deletions(-)
>
> diff -puN include/linux/cgroup.h~cgroups-convert-tasks-file-to-use-a-seq_=
file-with-shared-pid-array include/linux/cgroup.h
> --- a/include/linux/cgroup.h~cgroups-convert-tasks-file-to-use-a-seq_file=
-with-shared-pid-array
> +++ a/include/linux/cgroup.h
> @@ -14,6 +14,7 @@
> =A0#include <linux/rcupdate.h>
> =A0#include <linux/cgroupstats.h>
> =A0#include <linux/prio_heap.h>
> +#include <linux/rwsem.h>
>
> =A0#ifdef CONFIG_CGROUPS
>
> @@ -136,6 +137,15 @@ struct cgroup {
> =A0 =A0 =A0 =A0 * release_list_lock
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0struct list_head release_list;
> +
> + =A0 =A0 =A0 /* pids_mutex protects the fields below */
> + =A0 =A0 =A0 struct rw_semaphore pids_mutex;
> + =A0 =A0 =A0 /* Array of process ids in the cgroup */
> + =A0 =A0 =A0 pid_t *tasks_pids;
> + =A0 =A0 =A0 /* How many files are using the current tasks_pids array */
> + =A0 =A0 =A0 int pids_use_count;
> + =A0 =A0 =A0 /* Length of the current tasks_pids array */
> + =A0 =A0 =A0 int pids_length;
> =A0};
>
> =A0/* A css_set is a structure holding pointers to a set of
> diff -puN kernel/cgroup.c~cgroups-convert-tasks-file-to-use-a-seq_file-wi=
th-shared-pid-array kernel/cgroup.c
> --- a/kernel/cgroup.c~cgroups-convert-tasks-file-to-use-a-seq_file-with-s=
hared-pid-array
> +++ a/kernel/cgroup.c
> @@ -868,6 +868,14 @@ static struct super_operations cgroup_op
> =A0 =A0 =A0 =A0.remount_fs =3D cgroup_remount,
> =A0};
>
> +static void init_cgroup_housekeeping(struct cgroup *cgrp)
> +{
> + =A0 =A0 =A0 INIT_LIST_HEAD(&cgrp->sibling);
> + =A0 =A0 =A0 INIT_LIST_HEAD(&cgrp->children);
> + =A0 =A0 =A0 INIT_LIST_HEAD(&cgrp->css_sets);
> + =A0 =A0 =A0 INIT_LIST_HEAD(&cgrp->release_list);
> + =A0 =A0 =A0 init_rwsem(&cgrp->pids_mutex);
> +}
> =A0static void init_cgroup_root(struct cgroupfs_root *root)
> =A0{
> =A0 =A0 =A0 =A0struct cgroup *cgrp =3D &root->top_cgroup;
> @@ -876,10 +884,7 @@ static void init_cgroup_root(struct cgro
> =A0 =A0 =A0 =A0root->number_of_cgroups =3D 1;
> =A0 =A0 =A0 =A0cgrp->root =3D root;
> =A0 =A0 =A0 =A0cgrp->top_cgroup =3D cgrp;
> - =A0 =A0 =A0 INIT_LIST_HEAD(&cgrp->sibling);
> - =A0 =A0 =A0 INIT_LIST_HEAD(&cgrp->children);
> - =A0 =A0 =A0 INIT_LIST_HEAD(&cgrp->css_sets);
> - =A0 =A0 =A0 INIT_LIST_HEAD(&cgrp->release_list);
> + =A0 =A0 =A0 init_cgroup_housekeeping(cgrp);
> =A0}
>
> =A0static int cgroup_test_super(struct super_block *sb, void *data)
> @@ -1995,16 +2000,7 @@ int cgroup_scan_tasks(struct cgroup_scan
> =A0* but we cannot guarantee that the information we produce is correct
> =A0* unless we produce it entirely atomically.
> =A0*
> - * Upon tasks file open(), a struct ctr_struct is allocated, that
> - * will have a pointer to an array (also allocated here). =A0The struct
> - * ctr_struct * is stored in file->private_data. =A0Its resources will
> - * be freed by release() when the file is closed. =A0The array is used
> - * to sprintf the PIDs and then used by read().
> =A0*/
> -struct ctr_struct {
> - =A0 =A0 =A0 char *buf;
> - =A0 =A0 =A0 int bufsz;
> -};
>
> =A0/*
> =A0* Load into 'pidarray' up to 'npids' of the tasks using cgroup
> @@ -2086,42 +2082,132 @@ static int cmppid(const void *a, const v
> =A0 =A0 =A0 =A0return *(pid_t *)a - *(pid_t *)b;
> =A0}
>
> +
> =A0/*
> - * Convert array 'a' of 'npids' pid_t's to a string of newline separated
> - * decimal pids in 'buf'. =A0Don't write more than 'sz' chars, but return
> - * count 'cnt' of how many chars would be written if buf were large enou=
gh.
> + * seq_file methods for the "tasks" file. The seq_file position is the
> + * next pid to display; the seq_file iterator is a pointer to the pid
> + * in the cgroup->tasks_pids array.
> =A0*/
> -static int pid_array_to_buf(char *buf, int sz, pid_t *a, int npids)
> +
> +static void *cgroup_tasks_start(struct seq_file *s, loff_t *pos)
> =A0{
> - =A0 =A0 =A0 int cnt =3D 0;
> - =A0 =A0 =A0 int i;
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Initially we receive a position value that corresponds=
 to
> + =A0 =A0 =A0 =A0* one more than the last pid shown (or 0 on the first ca=
ll or
> + =A0 =A0 =A0 =A0* after a seek to the start). Use a binary-search to fin=
d the
> + =A0 =A0 =A0 =A0* next pid to display, if any
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 struct cgroup *cgrp =3D s->private;
> + =A0 =A0 =A0 int index =3D 0, pid =3D *pos;
> + =A0 =A0 =A0 int *iter;
> +
> + =A0 =A0 =A0 down_read(&cgrp->pids_mutex);
> + =A0 =A0 =A0 if (pid) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int end =3D cgrp->pids_length;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int i;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 while (index < end) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int mid =3D (index + end) /=
 2;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cgrp->tasks_pids[mid] =
=3D=3D pid) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 index =3D m=
id;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else if (cgrp->tasks_pids=
[mid] <=3D pid)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 index =3D m=
id + 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 end =3D mid;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 /* If we're off the end of the array, we're done */
> + =A0 =A0 =A0 if (index >=3D cgrp->pids_length)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> + =A0 =A0 =A0 /* Update the abstract position to be the actual pid that w=
e found */
> + =A0 =A0 =A0 iter =3D cgrp->tasks_pids + index;
> + =A0 =A0 =A0 *pos =3D *iter;
> + =A0 =A0 =A0 return iter;
> +}
> +
> +static void cgroup_tasks_stop(struct seq_file *s, void *v)
> +{
> + =A0 =A0 =A0 struct cgroup *cgrp =3D s->private;
> + =A0 =A0 =A0 up_read(&cgrp->pids_mutex);
> +}
> +
> +static void *cgroup_tasks_next(struct seq_file *s, void *v, loff_t *pos)
> +{
> + =A0 =A0 =A0 struct cgroup *cgrp =3D s->private;
> + =A0 =A0 =A0 int *p =3D v;
> + =A0 =A0 =A0 int *end =3D cgrp->tasks_pids + cgrp->pids_length;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Advance to the next pid in the array. If this goes off=
 the
> + =A0 =A0 =A0 =A0* end, we're done
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 p++;
> + =A0 =A0 =A0 if (p >=3D end) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 *pos =3D *p;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return p;
> + =A0 =A0 =A0 }
> +}
> +
> +static int cgroup_tasks_show(struct seq_file *s, void *v)
> +{
> + =A0 =A0 =A0 return seq_printf(s, "%d\n", *(int *)v);
> +}
>
> - =A0 =A0 =A0 for (i =3D 0; i < npids; i++)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 cnt +=3D snprintf(buf + cnt, max(sz - cnt, =
0), "%d\n", a[i]);
> - =A0 =A0 =A0 return cnt;
> +static struct seq_operations cgroup_tasks_seq_operations =3D {
> + =A0 =A0 =A0 .start =3D cgroup_tasks_start,
> + =A0 =A0 =A0 .stop =3D cgroup_tasks_stop,
> + =A0 =A0 =A0 .next =3D cgroup_tasks_next,
> + =A0 =A0 =A0 .show =3D cgroup_tasks_show,
> +};
> +
> +static void release_cgroup_pid_array(struct cgroup *cgrp)
> +{
> + =A0 =A0 =A0 down_write(&cgrp->pids_mutex);
> + =A0 =A0 =A0 BUG_ON(!cgrp->pids_use_count);
> + =A0 =A0 =A0 if (!--cgrp->pids_use_count) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(cgrp->tasks_pids);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cgrp->tasks_pids =3D NULL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cgrp->pids_length =3D 0;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 up_write(&cgrp->pids_mutex);
> +}
> +
> +static int cgroup_tasks_release(struct inode *inode, struct file *file)
> +{
> + =A0 =A0 =A0 struct cgroup *cgrp =3D __d_cgrp(file->f_dentry->d_parent);
> +
> + =A0 =A0 =A0 if (!(file->f_mode & FMODE_READ))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> +
> + =A0 =A0 =A0 release_cgroup_pid_array(cgrp);
> + =A0 =A0 =A0 return seq_release(inode, file);
> =A0}
>
> +static struct file_operations cgroup_tasks_operations =3D {
> + =A0 =A0 =A0 .read =3D seq_read,
> + =A0 =A0 =A0 .llseek =3D seq_lseek,
> + =A0 =A0 =A0 .write =3D cgroup_file_write,
> + =A0 =A0 =A0 .release =3D cgroup_tasks_release,
> +};
> +
> =A0/*
> - * Handle an open on 'tasks' file. =A0Prepare a buffer listing the
> + * Handle an open on 'tasks' file. =A0Prepare an array containing the
> =A0* process id's of tasks currently attached to the cgroup being opened.
> - *
> - * Does not require any specific cgroup mutexes, and does not take any.
> =A0*/
> +
> =A0static int cgroup_tasks_open(struct inode *unused, struct file *file)
> =A0{
> =A0 =A0 =A0 =A0struct cgroup *cgrp =3D __d_cgrp(file->f_dentry->d_parent);
> - =A0 =A0 =A0 struct ctr_struct *ctr;
> =A0 =A0 =A0 =A0pid_t *pidarray;
> =A0 =A0 =A0 =A0int npids;
> - =A0 =A0 =A0 char c;
> + =A0 =A0 =A0 int retval;
>
> + =A0 =A0 =A0 /* Nothing to do for write-only files */
> =A0 =A0 =A0 =A0if (!(file->f_mode & FMODE_READ))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
>
> - =A0 =A0 =A0 ctr =3D kmalloc(sizeof(*ctr), GFP_KERNEL);
> - =A0 =A0 =A0 if (!ctr)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err0;
> -
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * If cgroup gets more users after we read count, we won't=
 have
> =A0 =A0 =A0 =A0 * enough space - tough. =A0This race is indistinguishable=
 to the
> @@ -2129,57 +2215,31 @@ static int cgroup_tasks_open(struct inod
> =A0 =A0 =A0 =A0 * show up until sometime later on.
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0npids =3D cgroup_task_count(cgrp);
> - =A0 =A0 =A0 if (npids) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 pidarray =3D kmalloc(npids * sizeof(pid_t),=
 GFP_KERNEL);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!pidarray)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err1;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 npids =3D pid_array_load(pidarray, npids, c=
grp);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 sort(pidarray, npids, sizeof(pid_t), cmppid=
, NULL);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Call pid_array_to_buf() twice, first jus=
t to get bufsz */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ctr->bufsz =3D pid_array_to_buf(&c, sizeof(=
c), pidarray, npids) + 1;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ctr->buf =3D kmalloc(ctr->bufsz, GFP_KERNEL=
);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!ctr->buf)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err2;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ctr->bufsz =3D pid_array_to_buf(ctr->buf, c=
tr->bufsz, pidarray, npids);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(pidarray);
> - =A0 =A0 =A0 } else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ctr->buf =3D NULL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ctr->bufsz =3D 0;
> - =A0 =A0 =A0 }
> - =A0 =A0 =A0 file->private_data =3D ctr;
> - =A0 =A0 =A0 return 0;
> -
> -err2:
> - =A0 =A0 =A0 kfree(pidarray);
> -err1:
> - =A0 =A0 =A0 kfree(ctr);
> -err0:
> - =A0 =A0 =A0 return -ENOMEM;
> -}
> -
> -static ssize_t cgroup_tasks_read(struct cgroup *cgrp,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 str=
uct cftype *cft,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 str=
uct file *file, char __user *buf,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 siz=
e_t nbytes, loff_t *ppos)
> -{
> - =A0 =A0 =A0 struct ctr_struct *ctr =3D file->private_data;
> -
> - =A0 =A0 =A0 return simple_read_from_buffer(buf, nbytes, ppos, ctr->buf,=
 ctr->bufsz);
> -}
> -
> -static int cgroup_tasks_release(struct inode *unused_inode,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 struct file *file)
> -{
> - =A0 =A0 =A0 struct ctr_struct *ctr;
> + =A0 =A0 =A0 pidarray =3D kmalloc(npids * sizeof(pid_t), GFP_KERNEL);
> + =A0 =A0 =A0 if (!pidarray)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> + =A0 =A0 =A0 npids =3D pid_array_load(pidarray, npids, cgrp);
> + =A0 =A0 =A0 sort(pidarray, npids, sizeof(pid_t), cmppid, NULL);
>
> - =A0 =A0 =A0 if (file->f_mode & FMODE_READ) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ctr =3D file->private_data;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(ctr->buf);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(ctr);
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Store the array in the cgroup, freeing the old
> + =A0 =A0 =A0 =A0* array if necessary
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 down_write(&cgrp->pids_mutex);
> + =A0 =A0 =A0 kfree(cgrp->tasks_pids);
> + =A0 =A0 =A0 cgrp->tasks_pids =3D pidarray;
> + =A0 =A0 =A0 cgrp->pids_length =3D npids;
> + =A0 =A0 =A0 cgrp->pids_use_count++;
> + =A0 =A0 =A0 up_write(&cgrp->pids_mutex);
> +
> + =A0 =A0 =A0 file->f_op =3D &cgroup_tasks_operations;
> +
> + =A0 =A0 =A0 retval =3D seq_open(file, &cgroup_tasks_seq_operations);
> + =A0 =A0 =A0 if (retval) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 release_cgroup_pid_array(cgrp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return retval;
> =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 ((struct seq_file *)file->private_data)->private =3D cgrp;
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> @@ -2208,7 +2268,6 @@ static struct cftype files[] =3D {
> =A0 =A0 =A0 =A0{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.name =3D "tasks",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.open =3D cgroup_tasks_open,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .read =3D cgroup_tasks_read,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.write_u64 =3D cgroup_tasks_write,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.release =3D cgroup_tasks_release,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.private =3D FILE_TASKLIST,
> @@ -2298,10 +2357,7 @@ static long cgroup_create(struct cgroup
>
> =A0 =A0 =A0 =A0mutex_lock(&cgroup_mutex);
>
> - =A0 =A0 =A0 INIT_LIST_HEAD(&cgrp->sibling);
> - =A0 =A0 =A0 INIT_LIST_HEAD(&cgrp->children);
> - =A0 =A0 =A0 INIT_LIST_HEAD(&cgrp->css_sets);
> - =A0 =A0 =A0 INIT_LIST_HEAD(&cgrp->release_list);
> + =A0 =A0 =A0 init_cgroup_housekeeping(cgrp);
>
> =A0 =A0 =A0 =A0cgrp->parent =3D parent;
> =A0 =A0 =A0 =A0cgrp->root =3D parent->root;
> _
>
