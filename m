From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH v6 8/9] memcg: check memcg dirty limits in page writeback
Date: Wed, 16 Mar 2011 14:07:07 -0400
Message-ID: <20110316180707.GD13562@redhat.com>
References: <1299869011-26152-1-git-send-email-gthelen@google.com>
 <1299869011-26152-9-git-send-email-gthelen@google.com>
 <20110314175408.GE31120@redhat.com>
 <20110314211002.GD4998@quack.suse.cz>
 <AANLkTikCt90o2qRV=0cJijtnA_W44dcUCBOmZ53Biv07@mail.gmail.com>
 <20110315231230.GC4995@quack.suse.cz>
 <AANLkTimLNxcLQ23SRtdeynC19Htxe_aBm7sLuax_fQTX@mail.gmail.com>
 <20110316123514.GA4456@quack.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20110316123514.GA4456@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>
List-Id: containers.vger.kernel.org

On Wed, Mar 16, 2011 at 01:35:14PM +0100, Jan Kara wrote:
> On Tue 15-03-11 19:35:26, Greg Thelen wrote:
> > On Tue, Mar 15, 2011 at 4:12 PM, Jan Kara <jack@suse.cz> wrote:
> > > =A0I found out I've already deleted the relevant email and thus hav=
e no good
> > > way to reply to it. So in the end I'll write it here: As Vivek poin=
ted out,
> > > you try to introduce background writeback that honors per-cgroup li=
mits but
> > > the way you do it it doesn't quite work. To avoid livelocking of fl=
usher
> > > thread, any essentially unbounded work (and background writeback of=
 bdi or
> > > in your case a cgroup pages on the bdi is in principle unbounded) h=
as to
> > > give way to other work items in the queue (like a work submitted by
> > > sync(1)). Thus wb_writeback() stops for_background works if there a=
re other
> > > works to do with the rationale that as soon as that work is finishe=
d, we
> > > may happily return to background cleaning (and that other work work=
s for
> > > background cleaning as well anyway).
> > >
> > > But with your introduction of per-cgroup background writeback we ar=
e going
> > > to loose the information in which cgroup we have to get below backg=
round
> > > limit. And if we stored the context somewhere and tried to return t=
o it
> > > later, we'd have the above problems with livelocking and we'd have =
to
> > > really carefully handle cases where more cgroups actually want thei=
r limits
> > > observed.
> > >
> > > I'm not decided what would be a good solution for this. It seems th=
at
> > > a flusher thread should check all cgroups whether they are not exce=
eding
> > > their background limit and if yes, do writeback. I'm not sure how p=
ractical
> > > that would be but possibly we could have a list of cgroups with exc=
eeded
> > > limits and flusher thread could check that?
> >=20
> > mem_cgroup_balance_dirty_pages() queues a bdi work item which already
> > includes a memcg that is available to wb_writeback() in '[PATCH v6
> > 9/9] memcg: make background writeback memcg aware'.  Background
> > writeback checks the given memcg usage vs memcg limit rather than
> > global usage vs global limit.
>   Yes.
>=20
> > If we amend this to requeue an interrupted background work to the end
> > of the per-bdi work_list, then I think that would address the
> > livelocking issue.
>   Yes, that would work. But it would be nice (I'd find that cleaner des=
ign)
> if we could keep just one type of background work and make sure that it
> observes all the imposed memcg limits. For that we wouldn't explicitely
> pass memcg to the flusher thread but rather make over_bground_thresh()
> check all the memcg limits - or to make this more effective have some l=
ist
> of memcgs which crossed the background limit. What do you think?

List of memcg per bdi which need writeback sounds interesting. This
can also allow us to keep track of additional state in memcgroup
regarding how much IO is in flight per memory cgroup on a bdi. One of
the additional things we wanted to do was differentiating between
write speed of two buffered writers in two groups. IO controller at
the end device can differentiate between the rates but that is only
possible if flusher threads are submitting enough IO from faster moving
group and not getting stuck behind slow group.

So if we can also do some accouting of in flight IO per memcg per bdi,
then flusher threads can skip the memcg which have lot of pending IOs.
That means IO controller at the device is holding back on these
requests and prioritizing some other group. And flusher threads can
move onto other memcg in the list and pick inodes from those.

If there are per memcg per bdi structures, then there can be per memcg
per bdi waitlists too and throttled task can sleep on those wait lists
and one can keep count of BDI_WRITTEN per memory cgroup and distribute
completion its tasks. That way, even memory cgroup foreground writeout
becomes IO less.=20

Thanks
Vivek=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
