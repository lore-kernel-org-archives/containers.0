From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 5/7] cgroup: fix subsys bitops
Date: Tue, 19 Feb 2008 18:57:54 -0800
Message-ID: <6599ad830802191857w13387324ja5d8327d1ff2343d__10744.3331311972$1203476641$gmane$org@mail.gmail.com>
References: <47B91C82.7010407@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47B91C82.7010407-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Feb 17, 2008 9:49 PM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> Cgroup uses unsigned long for subsys bitops, not unsigned long long.
>
> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

> ---
>  kernel/cgroup.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index aa76bbd..e8c8e58 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -320,7 +320,7 @@ static struct css_set *find_existing_css_set(
>         /* Built the set of subsystem state objects that we want to
>          * see in the new css_set */
>         for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
> -               if (root->subsys_bits & (1ull << i)) {
> +               if (root->subsys_bits & (1UL << i)) {
>                         /* Subsystem is in this hierarchy. So we want
>                          * the subsystem state from the new
>                          * cgroup */
> @@ -696,7 +696,7 @@ static int rebind_subsystems(struct cgroupfs_root *root,
>         added_bits = final_bits & ~root->actual_subsys_bits;
>         /* Check that any added subsystems are currently free */
>         for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
> -               unsigned long long bit = 1ull << i;
> +               unsigned long bit = 1UL << i;
>                 struct cgroup_subsys *ss = subsys[i];
>                 if (!(bit & added_bits))
>                         continue;
> --
> 1.5.4.rc3
>
>
