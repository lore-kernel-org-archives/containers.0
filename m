From: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH] procfs: change the owner of non-dumpable and writeable
	files
Date: Wed, 18 Jan 2017 15:22:48 -0800
Message-ID: <CAGXu5jL4R-rqv-33XvvsMOqcxBgPRm-eAeRThdN515Ux3TSiFw@mail.gmail.com>
References: <20170118040159.4751-1-asarai@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20170118040159.4751-1-asarai-l3A5Bk7waGM@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Cc: Michal Hocko <mhocko-IBi9RG/b67k@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, dev-IGmTWi+3HBZvNhPySn5qfx2eb7JE58TQ@public.gmane.org, John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Janis Danisevskis <jdanis-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Jan 17, 2017 at 8:01 PM, Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org> wrote:
> In order to protect against ptrace(2) and similar attacks on container
> runtimes when they join namespaces, many runtimes set mm->dumpable to
> SUID_DUMP_DISABLE. However, doing this means that attempting to set up
> an unprivileged user namespace will fail because an unprivileged process
> can no longer access /proc/self/{setgroups,{uid,gid}_map} for the
> container process (which is the same uid as the runtime process).
>
> Fix this by changing pid_getattr to *also* change the owner of regular
> files that have a mode of 0644 (when the process is not dumpable). This
> ensures that the important /proc/[pid]/... files mentioned above are
> properly accessible by a container runtime in a rootless container
> context.
>
> The most blantant issue is that a non-dumpable process in a rootless
> container context is unable to open /proc/self/setgroups, because it
> doesn't own the file.

This changes a lot more than just setgroups, doesn't it? This bypasses
the task_dumpable check for all kinds of things. Though, I expect the
has_pid_permissions() check to be the harder one to pass. Why does
has_pid_permissions() succeed in the case you've given?

-Kees

> int main(void)
> {
>         prctl(PR_SET_DUMPABLE, 0, 0, 0, 0);
>         unshare(CLONE_NEWUSER);
>
>         /* This will fail. */
>         int fd = open("/proc/self/setgroups", O_WRONLY);
>         if (fd < 0)
>                 abort();
>
>         return 0;
> }
>
> Cc: dev-IGmTWi+3HBZvNhPySn5qfx2eb7JE58TQ@public.gmane.org
> Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> Signed-off-by: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
> ---
>  fs/proc/base.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/fs/proc/base.c b/fs/proc/base.c
> index ca651ac00660..ebabb12f4536 100644
> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -1729,6 +1729,7 @@ int pid_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
>                         return -ENOENT;
>                 }
>                 if ((inode->i_mode == (S_IFDIR|S_IRUGO|S_IXUGO)) ||
> +                   (inode->i_mode == (S_IFREG|S_IRUGO|S_IWUSR)) ||
>                     task_dumpable(task)) {
>                         cred = __task_cred(task);
>                         stat->uid = cred->euid;
> @@ -1770,6 +1771,7 @@ int pid_revalidate(struct dentry *dentry, unsigned int flags)
>
>         if (task) {
>                 if ((inode->i_mode == (S_IFDIR|S_IRUGO|S_IXUGO)) ||
> +                   (inode->i_mode == (S_IFREG|S_IRUGO|S_IWUSR)) ||
>                     task_dumpable(task)) {
>                         rcu_read_lock();
>                         cred = __task_cred(task);
> @@ -2394,7 +2396,7 @@ static int proc_pident_instantiate(struct inode *dir,
>         return -ENOENT;
>  }
>
> -static struct dentry *proc_pident_lookup(struct inode *dir,
> +static struct dentry *proc_pident_lookup(struct inode *dir,
>                                          struct dentry *dentry,
>                                          const struct pid_entry *ents,
>                                          unsigned int nents)
> @@ -2536,7 +2538,7 @@ static const struct pid_entry attr_dir_stuff[] = {
>
>  static int proc_attr_dir_readdir(struct file *file, struct dir_context *ctx)
>  {
> -       return proc_pident_readdir(file, ctx,
> +       return proc_pident_readdir(file, ctx,
>                                    attr_dir_stuff, ARRAY_SIZE(attr_dir_stuff));
>  }
>
> --
> 2.11.0
>



-- 
Kees Cook
Nexus Security
