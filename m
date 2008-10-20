From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroup: tiny cleanups
Date: Mon, 20 Oct 2008 13:31:37 -0700
Message-ID: <6599ad830810201331t639dbd55h5f17c382ca3a7fbd__45201.6961797655$1224541971$gmane$org@mail.gmail.com>
References: <48FC1784.70108@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48FC1784.70108-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Content-Disposition: inline
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sun, Oct 19, 2008 at 10:30 PM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> - remove 'private' field from struct subsys
> - remove cgroup_init_smp()
> - remove unused 'i' in cgroup_tasks_start()
>
> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Thanks. The cgroup_subsys.private field was originally for some
experiments for automatically emulating CKRM/BeanCounters over early
versions of cgroups, but I don't think anything is using it currently.

Paul

> ---
>  include/linux/cgroup.h |    4 ----
>  kernel/cgroup.c        |    1 -
>  2 files changed, 5 deletions(-)
>
> --- linux-mm/include/linux/cgroup.h.orig        2008-10-20 13:25:39.000000000 +0800
> +++ linux-mm/include/linux/cgroup.h     2008-10-20 13:26:08.000000000 +0800
> @@ -25,7 +25,6 @@ struct cgroup;
>
>  extern int cgroup_init_early(void);
>  extern int cgroup_init(void);
> -extern void cgroup_init_smp(void);
>  extern void cgroup_lock(void);
>  extern bool cgroup_lock_live_group(struct cgroup *cgrp);
>  extern void cgroup_unlock(void);
> @@ -348,8 +347,6 @@ struct cgroup_subsys {
>        struct cgroupfs_root *root;
>
>        struct list_head sibling;
> -
> -       void *private;
>  };
>
>  #define SUBSYS(_x) extern struct cgroup_subsys _x ## _subsys;
> @@ -410,7 +407,6 @@ void cgroup_mm_owner_callbacks(struct ta
>
>  static inline int cgroup_init_early(void) { return 0; }
>  static inline int cgroup_init(void) { return 0; }
> -static inline void cgroup_init_smp(void) {}
>  static inline void cgroup_fork(struct task_struct *p) {}
>  static inline void cgroup_fork_callbacks(struct task_struct *p) {}
>  static inline void cgroup_post_fork(struct task_struct *p) {}
> --- linux-mm/kernel/cgroup.c.orig       2008-10-20 13:25:56.000000000 +0800
> +++ linux-mm/kernel/cgroup.c    2008-10-20 13:26:08.000000000 +0800
> @@ -2104,7 +2104,6 @@ static void *cgroup_tasks_start(struct s
>        down_read(&cgrp->pids_mutex);
>        if (pid) {
>                int end = cgrp->pids_length;
> -               int i;
>                while (index < end) {
>                        int mid = (index + end) / 2;
>                        if (cgrp->tasks_pids[mid] == pid) {
>
