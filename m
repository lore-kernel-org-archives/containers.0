From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cls_cgroup: remove unneeded cgroup_lock
Date: Wed, 11 Mar 2009 19:41:06 -0700
Message-ID: <6599ad830903111941n5f244bb1n6d4df9268fe18fcb__43024.1310074509$1236825880$gmane$org@mail.gmail.com>
References: <49B869B2.1020303@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49B869B2.1020303-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Mar 11, 2009 at 6:47 PM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> We can remove this lock here, since we are in cgroup write handler
> and thus the cgrp is guaranteed to be valid, and no lock is needed
> when writing a u32 variable.

There's no guarantee that the group isn't dead, so we could be writing
into a value that's never going to be used again, but I guess that's
not really a big deal.

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

>
> Signed-off-by: Li Zefan <lizf-BthXqXjhjHWHlK3f2culvg@public.gmane.org>
> ---
>  net/sched/cls_cgroup.c |    6 ------
>  1 files changed, 0 insertions(+), 6 deletions(-)
>
> diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
> index 91a3db4..1ab4542 100644
> --- a/net/sched/cls_cgroup.c
> +++ b/net/sched/cls_cgroup.c
> @@ -62,13 +62,7 @@ static u64 read_classid(struct cgroup *cgrp, struct cftype *cft)
>
>  static int write_classid(struct cgroup *cgrp, struct cftype *cft, u64 value)
>  {
> -       if (!cgroup_lock_live_group(cgrp))
> -               return -ENODEV;
> -
>        cgrp_cls_state(cgrp)->classid = (u32) value;
> -
> -       cgroup_unlock();
> -
>        return 0;
>  }
>
> --
> 1.5.4.rc3
>
>
