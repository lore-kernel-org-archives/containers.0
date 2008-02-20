From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/7] cgroup: fix memory leak in cgroup_get_sb()
Date: Tue, 19 Feb 2008 19:04:39 -0800
Message-ID: <6599ad830802191904y5bdc78bbm8a1bb61b4e2c3e5c__42253.774617757$1203476837$gmane$org@mail.gmail.com>
References: <47B91C7F.6080602@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47B91C7F.6080602-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
> opts.release_agent is not kfree()ed in all necessary places.
>
> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Good catch, although hopefully something that would be extremely rare
in practice.

Thanks,

Paul

> ---
>  kernel/cgroup.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
>
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 0c35022..aa76bbd 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -961,8 +961,11 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
>         }
>
>         root = kzalloc(sizeof(*root), GFP_KERNEL);
> -       if (!root)
> +       if (!root) {
> +               if (opts.release_agent)
> +                       kfree(opts.release_agent);
>                 return -ENOMEM;
> +       }
>
>         init_cgroup_root(root);
>         root->subsys_bits = opts.subsys_bits;
> --
> 1.5.4.rc3
>
>
