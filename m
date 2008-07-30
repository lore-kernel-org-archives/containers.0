From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroup: fix possible memory leak
Date: Wed, 30 Jul 2008 01:16:40 -0700
Message-ID: <6599ad830807300116x13c308bck80b0629e5808357f__20266.1708266989$1217405942$gmane$org@mail.gmail.com>
References: <488D2D08.2090903@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <488D2D08.2090903-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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

On Sun, Jul 27, 2008 at 7:20 PM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> There's a leak if copy_from_user() returns failure.
>
> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Thanks, good catch.

> ---
>  kernel/cgroup.c |    7 +++++--
>  1 files changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 657f8f8..28debe4 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -1424,14 +1424,17 @@ static ssize_t cgroup_write_string(struct cgroup *cgrp, struct cftype *cft,
>                if (buffer == NULL)
>                        return -ENOMEM;
>        }
> -       if (nbytes && copy_from_user(buffer, userbuf, nbytes))
> -               return -EFAULT;
> +       if (nbytes && copy_from_user(buffer, userbuf, nbytes)) {
> +               retval = -EFAULT;
> +               goto out;
> +       }
>
>        buffer[nbytes] = 0;     /* nul-terminate */
>        strstrip(buffer);
>        retval = cft->write_string(cgrp, cft, buffer);
>        if (!retval)
>                retval = nbytes;
> +out:
>        if (buffer != local_buffer)
>                kfree(buffer);
>        return retval;
> --
> 1.5.4.rc3
>
