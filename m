From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] CGROUPS: includecheck fix for include/linux/page_cgroup.h
Date: Mon, 10 Aug 2009 11:50:26 -0700
Message-ID: <6599ad830908101150q10f87capc02222b3a1bc6903@mail.gmail.com>
References: <1249829145.2957.20.camel@ht.satnam>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1249829145.2957.20.camel-6Ww87KsxWewAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jaswinder Singh Rajput <jaswinder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sun, Aug 9, 2009 at 7:45 AM, Jaswinder Singh
Rajput<jaswinder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
>
> fix the following 'make includecheck' warning:
>
> =A0include/linux/page_cgroup.h: linux/swap.h is included more than once.
>
> Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Thanks.

Paul

> ---
> =A0include/linux/page_cgroup.h | =A0 =A04 ++--
> =A01 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> index 13f126c..ada779f 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -105,14 +105,14 @@ static inline void __init page_cgroup_init_flatmem(=
void)
>
> =A0#endif
>
> -#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> =A0#include <linux/swap.h>
> +
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> =A0extern unsigned short swap_cgroup_record(swp_entry_t ent, unsigned sho=
rt id);
> =A0extern unsigned short lookup_swap_cgroup(swp_entry_t ent);
> =A0extern int swap_cgroup_swapon(int type, unsigned long max_pages);
> =A0extern void swap_cgroup_swapoff(int type);
> =A0#else
> -#include <linux/swap.h>
>
> =A0static inline
> =A0unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
> --
> 1.6.0.6
>
>
>
