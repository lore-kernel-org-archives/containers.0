From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 7/7] CGroup API: Update cpusets to use cgroup
	structured file API
Date: Sun, 17 Feb 2008 09:18:44 -0800
Message-ID: <6599ad830802170918q4c748f7fs32e5b8ea63e49f15__19818.3199427605$1203268839$gmane$org@mail.gmail.com>
References: <20080215204418.535025000@menage.corp.google.com>
	<20080215204821.778088000@menage.corp.google.com>
	<20080216212901.70fe35ce.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080216212901.70fe35ce.pj-sJ/iWh9BUns@public.gmane.org>
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
To: Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On Feb 16, 2008 7:29 PM, Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org> wrote:
>
> From: Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org>
>
> Strip all trailing whitespace (such as carriage returns)
> when parsing integer writes to cgroup files, not just
> one trailing newline if present.

Sounds like a good idea to me. Thanks for this.

>
> Signed-off-by: Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org>
> Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

>
> ---
>  kernel/cgroup.c |    5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
>
> --- 2.6.24-mm1.orig/kernel/cgroup.c     2008-02-16 04:20:33.000000000 -0800
> +++ 2.6.24-mm1/kernel/cgroup.c  2008-02-16 19:00:41.207478218 -0800
> @@ -1321,10 +1321,7 @@ static ssize_t cgroup_write_uint(struct
>                 return -EFAULT;
>
>         buffer[nbytes] = 0;     /* nul-terminate */
> -
> -       /* strip newline if necessary */
> -       if (nbytes && (buffer[nbytes-1] == '\n'))
> -               buffer[nbytes-1] = 0;
> +       strstrip(buffer);       /* strip -just- trailing whitespace */
>         val = simple_strtoull(buffer, &end, 0);
>         if (*end)
>                 return -EINVAL;
>
>
> --
>                   I won't rest till it's the best ...
>                   Programmer, Linux Scalability
>                   Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org> 1.940.382.4214
>
