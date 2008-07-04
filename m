From: yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org (YAMAMOTO Takashi)
Subject: Re: [PATCH -mm 5/5] swapcgroup (v3): implement force_empty
Date: Fri,  4 Jul 2008 15:54:31 +0900 (JST)
Message-ID: <20080704065431.A8BDC5A19@siro.lan>
References: <20080704152423.f65932b3.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: Your message of "Fri, 4 Jul 2008 15:24:23 +0900"
	<20080704152423.f65932b3.nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

hi,

> +/*
> + * uncharge all the entries that are charged to the group.
> + */
> +void __swap_cgroup_force_empty(struct mem_cgroup *mem)
> +{
> +	struct swap_info_struct *p;
> +	int type;
> +
> +	spin_lock(&swap_lock);
> +	for (type = swap_list.head; type >= 0; type = swap_info[type].next) {
> +		p = swap_info + type;
> +
> +		if ((p->flags & SWP_ACTIVE) == SWP_ACTIVE) {
> +			unsigned int i = 0;
> +
> +			spin_unlock(&swap_lock);

what prevents the device from being swapoff'ed while you drop swap_lock?

YAMAMOTO Takashi

> +			while ((i = find_next_to_unuse(p, i, mem)) != 0) {
> +				spin_lock(&swap_lock);
> +				if (p->swap_map[i] && p->memcg[i] == mem)
> +					swap_cgroup_uncharge(p, i);
> +				spin_unlock(&swap_lock);
> +			}
> +			spin_lock(&swap_lock);
> +		}
> +	}
> +	spin_unlock(&swap_lock);
> +
> +	return;
> +}
>  #endif
