From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v6 8/9] memcg: check memcg dirty limits in page
 writeback
Date: Wed, 16 Mar 2011 00:12:30 +0100
Message-ID: <20110315231230.GC4995@quack.suse.cz>
References: <1299869011-26152-1-git-send-email-gthelen@google.com>
 <1299869011-26152-9-git-send-email-gthelen@google.com>
 <20110314175408.GE31120@redhat.com>
 <20110314211002.GD4998@quack.suse.cz>
 <AANLkTikCt90o2qRV=0cJijtnA_W44dcUCBOmZ53Biv07@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <AANLkTikCt90o2qRV=0cJijtnA_W44dcUCBOmZ53Biv07@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Jan Kara <jack@suse.cz>, Vivek Goyal <vgoyal@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>
List-Id: containers.vger.kernel.org

On Mon 14-03-11 20:27:33, Greg Thelen wrote:
> On Mon, Mar 14, 2011 at 2:10 PM, Jan Kara <jack@suse.cz> wrote:
> > On Mon 14-03-11 13:54:08, Vivek Goyal wrote:
> >> On Fri, Mar 11, 2011 at 10:43:30AM -0800, Greg Thelen wrote:
> >> > If the current process is in a non-root memcg, then
> >> > balance_dirty_pages() will consider the memcg dirty limits as well=
 as
> >> > the system-wide limits. =A0This allows different cgroups to have d=
istinct
> >> > dirty limits which trigger direct and background writeback at diff=
erent
> >> > levels.
> >> >
> >> > If called with a mem_cgroup, then throttle_vm_writeout() queries t=
he
> >> > given cgroup for its dirty memory usage limits.
> >> >
> >> > Signed-off-by: Andrea Righi <arighi@develer.com>
> >> > Signed-off-by: Greg Thelen <gthelen@google.com>
> >> > Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >> > Acked-by: Wu Fengguang <fengguang.wu@intel.com>
> >> > ---
> >> > Changelog since v5:
> >> > - Simplified this change by using mem_cgroup_balance_dirty_pages()=
 rather than
> >> > =A0 cramming the somewhat different logic into balance_dirty_pages=
(). =A0This means
> >> > =A0 the global (non-memcg) dirty limits are not passed around in t=
he
> >> > =A0 struct dirty_info, so there's less change to existing code.
> >>
> >> Yes there is less change to existing code but now we also have a sep=
arate
> >> throttlig logic for cgroups.
> >>
> >> I thought that we are moving in the direction of IO less throttling
> >> where bdi threads always do the IO and Jan Kara also implemented the
> >> logic to distribute the finished IO pages uniformly across the waiti=
ng
> >> threads.
> > =A0Yes, we'd like to avoid doing IO from balance_dirty_pages(). But i=
f the
> > logic in cgroups specific part won't get too fancy (which it doesn't =
seem
> > to be the case currently), it shouldn't be too hard to convert it to =
the new
> > approach.
>=20
> Handling memcg hierarchy was something that was not trivial to implemen=
t in
> mem_cgroup_balance_dirty_pages.
>=20
> > We can talk about it at LSF but at least with my approach to IO-less
> > balance_dirty_pages() it would be easy to convert cgroups throttling =
to
> > the new way. With Fengguang's approach it might be a bit harder since=
 he
> > computes a throughput and from that necessary delay for a throttled t=
ask
> > but with cgroups that is impossible to compute so he'd have to add so=
me
> > looping if we didn't write enough pages from the cgroup yet. But stil=
l it
> > would be reasonable doable AFAICT.
>=20
> I am definitely interested in finding a way to merge these feature
> cleanly together.
  What my patches do is that instead of calling writeback_inodes_wb() the
process waits for IO on enough pages to get completed. Now if we can tell
for each page against which cgroup it is accounted (and I believe we are
able to do so), we can as well properly account amount of pages completed
against a particular cgroup and thus wait for right amount of pages for
that cgroup to get written. The only difficult part is that for BDI I can
estimate throughput, set sleep time appropriately, and thus avoid
unnecessary looping checking whether pages have already completed or not.
With per-cgroup this is impossible (cgroups share the resource) so we'd h=
ave
to check relatively often...

> >> Keeping it separate for cgroups, reduces the complexity but also for=
ks
> >> off the balancing logic for root and other cgroups. So if Jan Kara's
> >> changes go in, it automatically does not get used for memory cgroups=
.
> >>
> >> Not sure how good a idea it is to use a separate throttling logic fo=
r
> >> for non-root cgroups.
> > =A0Yeah, it looks a bit odd. I'd think that we could just cap
> > task_dirty_limit() by a value computed from a cgroup limit and be don=
e
> > with that but I probably miss something...
>=20
> That is an interesting idea.  When looking at upstream balance_dirty_pa=
ges(),
> the result of task_dirty_limit() is compared per bdi_nr_reclaimable and
> bdi_nr_writeback.  I think we should be comparing memcg usage to memcg =
limits
> to catch cases where memcg usage is above memcg limits.
> Or am I missing something in your apporach?
  Oh right. It was too late yesterday :).
=20
> > Sure there is also a different
> > background limit but that's broken anyway because a flusher thread wi=
ll
> > quickly stop doing writeback if global background limit is not exceed=
ed.
> > But that's a separate topic so I'll reply with this to a more appropr=
iate
> > email ;)
> ;)  I am also interested in the this bg issue, but I should also try
> to stay on topic.
  I found out I've already deleted the relevant email and thus have no go=
od
way to reply to it. So in the end I'll write it here: As Vivek pointed ou=
t,
you try to introduce background writeback that honors per-cgroup limits b=
ut
the way you do it it doesn't quite work. To avoid livelocking of flusher
thread, any essentially unbounded work (and background writeback of bdi o=
r
in your case a cgroup pages on the bdi is in principle unbounded) has to
give way to other work items in the queue (like a work submitted by
sync(1)). Thus wb_writeback() stops for_background works if there are oth=
er
works to do with the rationale that as soon as that work is finished, we
may happily return to background cleaning (and that other work works for
background cleaning as well anyway).

But with your introduction of per-cgroup background writeback we are goin=
g
to loose the information in which cgroup we have to get below background
limit. And if we stored the context somewhere and tried to return to it
later, we'd have the above problems with livelocking and we'd have to
really carefully handle cases where more cgroups actually want their limi=
ts
observed.

I'm not decided what would be a good solution for this. It seems that
a flusher thread should check all cgroups whether they are not exceeding
their background limit and if yes, do writeback. I'm not sure how practic=
al
that would be but possibly we could have a list of cgroups with exceeded
limits and flusher thread could check that?

								Honza
--=20
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
