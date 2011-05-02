From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: memcg: fix fatal livelock in kswapd
Date: Mon, 2 May 2011 15:53:31 -0700
Message-ID: <BANLkTimhZAdL-HXftE86SyjRrDy9KB+qsg__17478.2096328729$1304376940$gmane$org@mail.gmail.com>
References: <1304366849.15370.27.camel@mulgrave.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
To: James Bottomley <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, Balbir Singh <balbir-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-mm <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Chris Mason <chris.mason-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

[ Adding the memcg maintainers ]

On Mon, May 2, 2011 at 1:07 PM, James Bottomley
<James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org> wrote:
> The fatal livelock in kswapd, reported in this thread:
>
> http://marc.info/?t=3D130392066000001
>
> Is mitigateable if we prevent the cgroups code being so aggressive in
> its zone shrinking (by reducing it's default shrink from 0 [everything]
> to DEF_PRIORITY [some things]). =A0This will have an obvious knock on
> effect to cgroup accounting, but it's better than hanging systems.
>
> Signed-off-by: James Bottomley <James.Bottomley-l3A5Bk7waGM@public.gmane.org>
>
> ---
>
> From 74b62fc417f07e1411d98181631e4e097c8e3e68 Mon Sep 17 00:00:00 2001
> From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
> Date: Mon, 2 May 2011 14:56:29 -0500
> Subject: [PATCH] vmscan: move containers scan back to default priority
>
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index f6b435c..46cde92 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2173,8 +2173,12 @@ unsigned long mem_cgroup_shrink_node_zone(struct m=
em_cgroup *mem,
> =A0 =A0 =A0 =A0 * if we don't reclaim here, the shrink_zone from balance_=
pgdat
> =A0 =A0 =A0 =A0 * will pick up pages from other mem cgroup's as well. We =
hack
> =A0 =A0 =A0 =A0 * the priority and make it zero.
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* FIXME: jejb: zero here was causing a livelock in the
> + =A0 =A0 =A0 =A0* shrinker so changed to DEF_PRIORITY to fix this. Now n=
eed to
> + =A0 =A0 =A0 =A0* sort out cgroup accounting.
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 shrink_zone(0, zone, &sc);
> + =A0 =A0 =A0 shrink_zone(DEF_PRIORITY, zone, &sc);
>
> =A0 =A0 =A0 =A0trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaime=
d);
>
>
>
>
