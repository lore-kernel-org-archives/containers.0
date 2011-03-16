From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v6 8/9] memcg: check memcg dirty limits in page
 writeback
Date: Wed, 16 Mar 2011 13:35:14 +0100
Message-ID: <20110316123514.GA4456@quack.suse.cz>
References: <1299869011-26152-1-git-send-email-gthelen@google.com>
 <1299869011-26152-9-git-send-email-gthelen@google.com>
 <20110314175408.GE31120@redhat.com>
 <20110314211002.GD4998@quack.suse.cz>
 <AANLkTikCt90o2qRV=0cJijtnA_W44dcUCBOmZ53Biv07@mail.gmail.com>
 <20110315231230.GC4995@quack.suse.cz>
 <AANLkTimLNxcLQ23SRtdeynC19Htxe_aBm7sLuax_fQTX@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTimLNxcLQ23SRtdeynC19Htxe_aBm7sLuax_fQTX@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Greg Thelen <gthelen@google.com>
Cc: Jan Kara <jack@suse.cz>, Vivek Goyal <vgoyal@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>
List-Id: containers.vger.kernel.org

On Tue 15-03-11 19:35:26, Greg Thelen wrote:
> On Tue, Mar 15, 2011 at 4:12 PM, Jan Kara <jack@suse.cz> wrote:
> > =A0I found out I've already deleted the relevant email and thus hav=
e no good
> > way to reply to it. So in the end I'll write it here: As Vivek poin=
ted out,
> > you try to introduce background writeback that honors per-cgroup li=
mits but
> > the way you do it it doesn't quite work. To avoid livelocking of fl=
usher
> > thread, any essentially unbounded work (and background writeback of=
 bdi or
> > in your case a cgroup pages on the bdi is in principle unbounded) h=
as to
> > give way to other work items in the queue (like a work submitted by
> > sync(1)). Thus wb_writeback() stops for_background works if there a=
re other
> > works to do with the rationale that as soon as that work is finishe=
d, we
> > may happily return to background cleaning (and that other work work=
s for
> > background cleaning as well anyway).
> >
> > But with your introduction of per-cgroup background writeback we ar=
e going
> > to loose the information in which cgroup we have to get below backg=
round
> > limit. And if we stored the context somewhere and tried to return t=
o it
> > later, we'd have the above problems with livelocking and we'd have =
to
> > really carefully handle cases where more cgroups actually want thei=
r limits
> > observed.
> >
> > I'm not decided what would be a good solution for this. It seems th=
at
> > a flusher thread should check all cgroups whether they are not exce=
eding
> > their background limit and if yes, do writeback. I'm not sure how p=
ractical
> > that would be but possibly we could have a list of cgroups with exc=
eeded
> > limits and flusher thread could check that?
>=20
> mem_cgroup_balance_dirty_pages() queues a bdi work item which already
> includes a memcg that is available to wb_writeback() in '[PATCH v6
> 9/9] memcg: make background writeback memcg aware'.  Background
> writeback checks the given memcg usage vs memcg limit rather than
> global usage vs global limit.
  Yes.

> If we amend this to requeue an interrupted background work to the end
> of the per-bdi work_list, then I think that would address the
> livelocking issue.
  Yes, that would work. But it would be nice (I'd find that cleaner des=
ign)
if we could keep just one type of background work and make sure that it
observes all the imposed memcg limits. For that we wouldn't explicitely
pass memcg to the flusher thread but rather make over_bground_thresh()
check all the memcg limits - or to make this more effective have some l=
ist
of memcgs which crossed the background limit. What do you think?

> To prevent a memcg writeback work item from writing irrelevant inodes
> (outside the memcg) then bdi writeback could call
> mem_cgroup_queue_io(memcg, bdi) to locate an inode to writeback for
> the memcg under dirty pressure.  mem_cgroup_queue_io() would scan the
> memcg lru for dirty pages belonging to the particular bdi.
  And similarly here, we could just loop over all relevant memcg's and
let each of them queue relevant inodes as they wish and after that we g=
o
and write all the queued inodes... That would also solve the problem wi=
th
cgroups competing with each other on the same bdi (writeback thread mak=
es
sure that all queued inodes get comparable amount of writeback). Does i=
t
look OK? It seems cleaner to me than what you propose but maybe I miss
something...

> If mem_cgroup_queue_io() is unable to find any dirty inodes for the
> bdi, then it would return an empty set.  Then wb_writeback() would
> abandon background writeback because there is nothing useful to write
> back to that bdi.  In patch 9/9, wb_writeback() calls
> mem_cgroup_bg_writeback_done() when writeback completes.
> mem_cgroup_bg_writeback_done() could check that cgroup is still over
> background thresh and use the memcg lru to select another bdi to star=
t
> per-memcg bdi writeback on.  This allows one queued per-memcg bdi
> background writeback work item to pass off to another bdi to continue
> per-memcg background writeback.
  Here I'd think that memcg_balance_dirty_pages() would check which mem=
cgs
are over threshold on that bdi and add these to the list of relevant me=
mcgs
for that bdi. Thinking about it it's rather similar to what you propose
just instead of queueing and requeueing work items (which are processed
sequentially, which isn't really what we want) we'd rather maintain a
separate list of memcgs which would be processed in parallel.

> Unfortunately the approach above would only queue a memcg's bg writes
> to one bdi at a time.  Another way to approach the problem would be t=
o
> have a per-memcg flusher thread that is able to queue inodes to
> multiple bdis concurrently.
  Well, in principle there's no reason why memcg couldn't ask for write=
back
(either via work items as you propose or via my mechanism) on several b=
dis
in parallel. I see no reason why a special flusher thread would be need=
ed
for that...

									Honza
--=20
Jan Kara <jack@suse.cz>
SUSE Labs, CR
--
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
