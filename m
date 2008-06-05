From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroup: anotate two variables with __read_mostly
Date: Wed, 4 Jun 2008 23:35:56 -0700
Message-ID: <6599ad830806042335o7d8b93bdw13072267e4c5b455__22991.8128381998$1212648029$gmane$org@mail.gmail.com>
References: <48478187.7080204@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48478187.7080204-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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

On Wed, Jun 4, 2008 at 11:02 PM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>
> - need_forkexit_callback will be read only after system boot.
> - use_task_css_set_links will be read only after it's set.
>
> And these 2 variables are checked when a new process is forked.
>
> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Thanks.

Paul

> ---
>  kernel/cgroup.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 15ac0e1..f5a1273 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -118,7 +118,7 @@ static int root_count;
>  * extra work in the fork/exit path if none of the subsystems need to
>  * be called.
>  */
> -static int need_forkexit_callback;
> +static int need_forkexit_callback __read_mostly;
>  static int need_mm_owner_callback __read_mostly;
>
>  /* convenient tests for these bits */
> @@ -220,7 +220,7 @@ static struct hlist_head *css_set_hash(struct cgroup_subsys_state *css[])
>  * task until after the first call to cgroup_iter_start(). This
>  * reduces the fork()/exit() overhead for people who have cgroups
>  * compiled into their kernel but not actually in use */
> -static int use_task_css_set_links;
> +static int use_task_css_set_links __read_mostly;
>
>  /* When we create or destroy a css_set, the operation simply
>  * takes/releases a reference count on all the cgroups referenced
> --
> 1.5.4.rc3
>
