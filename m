From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] task containersv11 automatic userspace notification of
	idle containers fix
Date: Sat, 6 Oct 2007 14:34:45 -0700
Message-ID: <6599ad830710061434q77ef054bw349ab455068e7765@mail.gmail.com>
References: <20071006083454.17561.99757.sendpatchset@jackhammer.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071006083454.17561.99757.sendpatchset-M4CL5g1PSvWbsYJBcxZrRbCf4lofQVJ7@public.gmane.org>
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
To: Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

On 10/6/07, Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org> wrote:
> From: Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org>
>
> Need to include kmod.h to define UMH_WAIT_EXEC, at least
> for my configuration (sn2_defconfig).
>
> Signed-off-by: Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org>

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

> Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>
> ---
>
>  kernel/cgroup.c |    1 +
>  1 file changed, 1 insertion(+)
>
> --- 2.6.23-rc8-mm2.orig/kernel/cgroup.c 2007-10-05 23:35:15.615380128 -0700
> +++ 2.6.23-rc8-mm2/kernel/cgroup.c      2007-10-05 23:36:55.692927139 -0700
> @@ -43,6 +43,7 @@
>  #include <linux/spinlock.h>
>  #include <linux/string.h>
>  #include <linux/sort.h>
> +#include <linux/kmod.h>
>  #include <asm/atomic.h>
>
>  static DEFINE_MUTEX(cgroup_mutex);
>
> --
>                           I won't rest till it's the best ...
>                           Programmer, Linux Scalability
>                           Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org> 1.650.933.1373
>
