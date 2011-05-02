From: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Subject: Re: memcg: fix fatal livelock in kswapd
Date: Tue, 3 May 2011 00:48:38 +0200
Message-ID: <20110502224838.GB10278__27239.1335027807$1304376615$gmane$org@cmpxchg.org>
References: <1304366849.15370.27.camel@mulgrave.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1304366849.15370.27.camel-0iu6Cu4xQGLYCGPCin2YbQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-mm <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Chris Mason <chris.mason-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

On Mon, May 02, 2011 at 03:07:29PM -0500, James Bottomley wrote:
> The fatal livelock in kswapd, reported in this thread:
> 
> http://marc.info/?t=130392066000001
> 
> Is mitigateable if we prevent the cgroups code being so aggressive in
> its zone shrinking (by reducing it's default shrink from 0 [everything]
> to DEF_PRIORITY [some things]).  This will have an obvious knock on
> effect to cgroup accounting, but it's better than hanging systems.

Actually, it's not that obvious.  At least not to me.  I added Balbir,
who added said comment and code in the first place, to CC: Here is the
comment in full quote:

	/*
	 * NOTE: Although we can get the priority field, using it
	 * here is not a good idea, since it limits the pages we can scan.
	 * if we don't reclaim here, the shrink_zone from balance_pgdat
	 * will pick up pages from other mem cgroup's as well. We hack
	 * the priority and make it zero.
	 */

The idea is that if one memcg is above its softlimit, we prefer
reducing pages from this memcg over reclaiming random other pages,
including those of other memcgs.

But the code flow looks like this:

	balance_pgdat
	  mem_cgroup_soft_limit_reclaim
	    mem_cgroup_shrink_node_zone
	      shrink_zone(0, zone, &sc)
	  shrink_zone(prio, zone, &sc)

so the success of the inner memcg shrink_zone does at least not
explicitely result in the outer, global shrink_zone steering clear of
other memcgs' pages.  It just tries to move the pressure of balancing
the zones to the memcg with the biggest soft limit excess.  That can
only really work if the memcg is a large enough contributor to the
zone's total number of lru pages, though, and looks very likely to hit
the exceeding memcg too hard in other cases.

I am very much for removing this hack.  There is still more scan
pressure applied to memcgs in excess of their soft limit even if the
extra scan is happening at a sane priority level.  And the fact that
global reclaim operates completely unaware of memcgs is a different
story.

However, this code came into place with v2.6.31-8387-g4e41695.  Why is
it only now showing up?

You also wrote in that thread that this happens on a standard F15
installation.  On the F15 I am running here, systemd does not
configure memcgs, however.  Did you manually configure memcgs and set
soft limits?  Because I wonder how it ended up in soft limit reclaim
in the first place.

	Hannes

> Signed-off-by: James Bottomley <James.Bottomley-l3A5Bk7waGM@public.gmane.org>
> 
> ---
> 
> >From 74b62fc417f07e1411d98181631e4e097c8e3e68 Mon Sep 17 00:00:00 2001
> From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
> Date: Mon, 2 May 2011 14:56:29 -0500
> Subject: [PATCH] vmscan: move containers scan back to default priority
> 
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index f6b435c..46cde92 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2173,8 +2173,12 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
>  	 * if we don't reclaim here, the shrink_zone from balance_pgdat
>  	 * will pick up pages from other mem cgroup's as well. We hack
>  	 * the priority and make it zero.
> +	 *
> +	 * FIXME: jejb: zero here was causing a livelock in the
> +	 * shrinker so changed to DEF_PRIORITY to fix this. Now need to
> +	 * sort out cgroup accounting.
>  	 */
> -	shrink_zone(0, zone, &sc);
> +	shrink_zone(DEF_PRIORITY, zone, &sc);
>  
>  	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
>  
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
