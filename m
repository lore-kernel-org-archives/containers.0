From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] debug cgroup: remove unneeded cgroup_lock
Date: Wed, 11 Mar 2009 19:43:32 -0700
Message-ID: <6599ad830903111943u2799333dh680470f9daa6ccbb__17930.0588010394$1236825965$gmane$org@mail.gmail.com>
References: <49B869B7.1090108@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49B869B7.1090108-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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

On Wed, Mar 11, 2009 at 6:47 PM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> Since we are in cgroup write handler, so the cgrp is valid, so we
> don't have to hold cgroup_mutex when calling cgroup_task_count().
> One similar example is in cgroup_tasks_open().
>
> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

(Although this conflicts with a patch that I'm about to send out that
moves the code from cgroup_debug.c into cgroup.c to allow internal
details to be reported in the debug.* files.)

> ---
>  kernel/cgroup_debug.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
>
> diff --git a/kernel/cgroup_debug.c b/kernel/cgroup_debug.c
> index daca620..0c92d79 100644
> --- a/kernel/cgroup_debug.c
> +++ b/kernel/cgroup_debug.c
> @@ -40,9 +40,7 @@ static u64 taskcount_read(struct cgroup *cont, struct cftype *cft)
>  {
>        u64 count;
>
> -       cgroup_lock();
>        count = cgroup_task_count(cont);
> -       cgroup_unlock();
>        return count;
>  }
>
> --
> 1.5.4.rc3
>
>
