From: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Subject: Re: memcg: fix fatal livelock in kswapd
Date: Tue, 3 May 2011 08:11:56 +0200
Message-ID: <20110503061156.GC10278__3900.4304715947$1304403210$gmane$org@cmpxchg.org>
References: <1304366849.15370.27.camel@mulgrave.site>
	<20110502224838.GB10278@cmpxchg.org>
	<BANLkTikDyL9-XLpwyLwUQNuUfkBwbUBcZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <BANLkTikDyL9-XLpwyLwUQNuUfkBwbUBcZg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ying Han <yinghan-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, James Bottomley <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, linux-mm <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Chris Mason <chris.mason-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, May 02, 2011 at 04:14:09PM -0700, Ying Han wrote:
> On Mon, May 2, 2011 at 3:48 PM, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org> wrot=
e:
> > Hi,
> >
> > On Mon, May 02, 2011 at 03:07:29PM -0500, James Bottomley wrote:
> >> The fatal livelock in kswapd, reported in this thread:
> >>
> >> http://marc.info/?t=3D130392066000001
> >>
> >> Is mitigateable if we prevent the cgroups code being so aggressive in
> >> its zone shrinking (by reducing it's default shrink from 0 [everything]
> >> to DEF_PRIORITY [some things]). =A0This will have an obvious knock on
> >> effect to cgroup accounting, but it's better than hanging systems.
> >
> > Actually, it's not that obvious. =A0At least not to me. =A0I added Balb=
ir,
> > who added said comment and code in the first place, to CC: Here is the
> > comment in full quote:
> >
> > =A0 =A0 =A0 =A0/*
> > =A0 =A0 =A0 =A0 * NOTE: Although we can get the priority field, using it
> > =A0 =A0 =A0 =A0 * here is not a good idea, since it limits the pages we=
 can scan.
> > =A0 =A0 =A0 =A0 * if we don't reclaim here, the shrink_zone from balanc=
e_pgdat
> > =A0 =A0 =A0 =A0 * will pick up pages from other mem cgroup's as well. W=
e hack
> > =A0 =A0 =A0 =A0 * the priority and make it zero.
> > =A0 =A0 =A0 =A0 */
> >
> > The idea is that if one memcg is above its softlimit, we prefer
> > reducing pages from this memcg over reclaiming random other pages,
> > including those of other memcgs.
> >
> > But the code flow looks like this:
> >
> > =A0 =A0 =A0 =A0balance_pgdat
> > =A0 =A0 =A0 =A0 =A0mem_cgroup_soft_limit_reclaim
> > =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_shrink_node_zone
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0shrink_zone(0, zone, &sc)
> > =A0 =A0 =A0 =A0 =A0shrink_zone(prio, zone, &sc)
> >
> > so the success of the inner memcg shrink_zone does at least not
> > explicitely result in the outer, global shrink_zone steering clear of
> > other memcgs' pages. =A0It just tries to move the pressure of balancing
> > the zones to the memcg with the biggest soft limit excess. =A0That can
> > only really work if the memcg is a large enough contributor to the
> > zone's total number of lru pages, though, and looks very likely to hit
> > the exceeding memcg too hard in other cases.
> yes, the logic is selecting one memcg(the one exceeding the most) and
> starting hierarchical reclaim on it. It will looping until the the
> following condition becomes true:
> 1. memcg usage is below its soft_limit
> 2. looping 100 times
> 3. reclaimed pages equal or greater than (excess >>2) where excess is
> the (usage - soft_limit)

There is no need to loop if we beat up the memcg in question with a
hammer during the first iteration ;-)

That is, we already did the aggressive scan when all these conditions
are checked.

> hmm, the worst case i can think of is the memcg only has one page
> allocate on the zone, and we end up looping 100 time each time and not
> contributing much to the global reclaim.

Good point, it should probably bail earlier on a zone that does not
really contribute to the soft limit excess.
