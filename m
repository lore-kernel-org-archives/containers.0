From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroups: fix a serious bug in cgroupstats
Date: Wed, 19 Nov 2008 14:31:30 -0800
Message-ID: <6599ad830811191431k1994017dr5a08bb4811eb7466__24134.6942763359$1227134058$gmane$org@mail.gmail.com>
References: <4923CAF1.1020404@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4923CAF1.1020404-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Nov 19, 2008 at 12:14 AM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> Try this, and you'll get oops immediately:
>  # cd Documentation/accounting/
>  # gcc -o getdelays getdelays.c
>  # mount -t cgroup -o debug xxx /mnt
>  # ./getdelays -C /mnt/tasks
>
> Because a normal file's dentry->d_fsdata is a pointer to struct cftype,
> not struct cgroup.
>
> After the patch, it returns EINVAL if we try to get cgroupstats
> from a normal file.
>
> CC: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Good catch, thanks.

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>



> ---
>  kernel/cgroup.c |    7 +++++--
>  1 files changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 358e775..f6f5219 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -2039,10 +2039,13 @@ int cgroupstats_build(struct cgroupstats *stats, struct dentry *dentry)
>        struct cgroup *cgrp;
>        struct cgroup_iter it;
>        struct task_struct *tsk;
> +
>        /*
> -        * Validate dentry by checking the superblock operations
> +        * Validate dentry by checking the superblock operations,
> +        * and make sure it's a directory.
>         */
> -       if (dentry->d_sb->s_op != &cgroup_ops)
> +       if (dentry->d_sb->s_op != &cgroup_ops ||
> +           !S_ISDIR(dentry->d_inode->i_mode))
>                 goto err;
>
>        ret = 0;
> --
> 1.5.4.rc3
>
