From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH v8 11/12] writeback: make background writeback cgroup
 aware
Date: Wed, 8 Jun 2011 16:42:18 -0400
Message-ID: <20110608204218.GG1150@redhat.com>
References: <1307117538-14317-1-git-send-email-gthelen@google.com>
 <1307117538-14317-12-git-send-email-gthelen@google.com>
 <20110607193835.GD26965@redhat.com>
 <xr93lixdv0df.fsf@gthelen.mtv.corp.google.com>
 <20110607210540.GB30919@redhat.com>
 <20110608091815.fdef924d.kamezawa.hiroyu@jp.fujitsu.com>
 <BANLkTim-sYkuekCcOA+HXhCtED4xKfT=0Q@mail.gmail.com>
 <20110608130315.0a365dbb.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20110608130315.0a365dbb.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>
List-Id: containers.vger.kernel.org

On Wed, Jun 08, 2011 at 01:03:15PM +0900, KAMEZAWA Hiroyuki wrote:
> On Tue, 7 Jun 2011 21:02:21 -0700
> Greg Thelen <gthelen@google.com> wrote:
>=20
> > On Tue, Jun 7, 2011 at 5:18 PM, KAMEZAWA Hiroyuki
> > <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > On Tue, 7 Jun 2011 17:05:40 -0400
> > > Vivek Goyal <vgoyal@redhat.com> wrote:
> > >
> > >> On Tue, Jun 07, 2011 at 01:43:08PM -0700, Greg Thelen wrote:
> > >> > Vivek Goyal <vgoyal@redhat.com> writes:
> > >> >
> > >> > > On Fri, Jun 03, 2011 at 09:12:17AM -0700, Greg Thelen wrote:
> > >> > >> When the system is under background dirty memory threshold bu=
t a cgroup
> > >> > >> is over its background dirty memory threshold, then only writ=
eback
> > >> > >> inodes associated with the over-limit cgroup(s).
> > >> > >>
> > >> > >
> > >> > > [..]
> > >> > >> -static inline bool over_bground_thresh(void)
> > >> > >> +static inline bool over_bground_thresh(struct bdi_writeback =
*wb,
> > >> > >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 struct writeback_control *wbc)
> > >> > >> =A0{
> > >> > >> =A0 =A0 =A0 =A0 =A0unsigned long background_thresh, dirty_thr=
esh;
> > >> > >>
> > >> > >> =A0 =A0 =A0 =A0 =A0global_dirty_limits(&background_thresh, &d=
irty_thresh);
> > >> > >>
> > >> > >> - =A0 =A0 =A0 =A0return (global_page_state(NR_FILE_DIRTY) +
> > >> > >> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0global_page_state(NR_UNSTABL=
E_NFS) > background_thresh);
> > >> > >> + =A0 =A0 =A0 =A0if (global_page_state(NR_FILE_DIRTY) +
> > >> > >> + =A0 =A0 =A0 =A0 =A0 =A0global_page_state(NR_UNSTABLE_NFS) >=
 background_thresh) {
> > >> > >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0wbc->for_cgroup =3D 0;
> > >> > >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return true;
> > >> > >> + =A0 =A0 =A0 =A0}
> > >> > >> +
> > >> > >> + =A0 =A0 =A0 =A0wbc->for_cgroup =3D 1;
> > >> > >> + =A0 =A0 =A0 =A0wbc->shared_inodes =3D 1;
> > >> > >> + =A0 =A0 =A0 =A0return mem_cgroups_over_bground_dirty_thresh=
();
> > >> > >> =A0}
> > >> > >
> > >> > > Hi Greg,
> > >> > >
> > >> > > So all the logic of writeout from mem cgroup works only if sys=
tem is
> > >> > > below background limit. The moment we cross background limit, =
looks
> > >> > > like we will fall back to existing way of writting inodes?
> > >> >
> > >> > Correct. =A0If the system is over its background limit then the =
previous
> > >> > cgroup-unaware background writeback occurs. =A0I think of the sy=
stem
> > >> > limits as those of the root cgroup. =A0If the system is over the=
 global
> > >> > limit than all cgroups are eligible for writeback. =A0In this si=
tuation
> > >> > the current code does not distinguish between cgroups over or un=
der
> > >> > their dirty background limit.
> > >> >
> > >> > Vivek Goyal <vgoyal@redhat.com> writes:
> > >> > > If yes, then from design point of view it is little odd that a=
s long
> > >> > > as we are below background limit, we share the bdi between dif=
ferent
> > >> > > cgroups. The moment we are above background limit, we fall bac=
k to
> > >> > > algorithm of sharing the disk among individual inodes and forg=
et
> > >> > > about memory cgroups. Kind of awkward.
> > >> > >
> > >> > > This kind of cgroup writeback I think will atleast not solve t=
he problem
> > >> > > for CFQ IO controller, as we fall back to old ways of writting=
 back inodes
> > >> > > the moment we cross dirty ratio.
> > >> >
> > >> > It might make more sense to reverse the order of the checks in t=
he
> > >> > proposed over_bground_thresh(): the new version would first chec=
k if any
> > >> > memcg are over limit; assuming none are over limit, then check g=
lobal
> > >> > limits. =A0Assuming that the system is over its background limit=
 and some
> > >> > cgroups are also over their limits, then the over limit cgroups =
would
> > >> > first be written possibly getting the system below its limit. =A0=
Does this
> > >> > address your concern?
> > >>
> > >> Do you treat root group also as any other cgroup? If no, then abov=
e logic
> > >> can lead to issue of starvation of root group inode. Or unfair wri=
teback.
> > >> So I guess it will be important to treat root group same as other =
groups.
> > >>
> > >
> > > As far as I can say, you should not place programs onto ROOT cgroup=
s if you need
> > > performance isolation.
> >=20
> > Agreed.
> >=20
> > > From the code, I think if the system hits dirty_ratio, "1" bit of b=
itmap should be
> > > set and background writeback can work for ROOT cgroup seamlessly.
> > >
> > > Thanks,
> > > -Kame
> >=20
> > Not quite.  The proposed patches do not set the "1" bit (css_id of
> > root is 1).  mem_cgroup_balance_dirty_pages() (from patch 10/12)
> > introduces the following balancing loop:
> > +       /* balance entire ancestry of current's mem. */
> > +       for (; mem_cgroup_has_dirty_limit(mem); mem =3D
> > parent_mem_cgroup(mem)) {
> >=20
> > The loop terminates when mem_cgroup_has_dirty_limit() is called for
> > the root cgroup.  The bitmap is set in the body of the loop.  So the
> > root cgroup's bit (bit 1) will never be set in the bitmap.  However, =
I
> > think the effect is the same.  The proposed changes in this patch
> > (11/12) have background writeback first checking if the system is ove=
r
> > limit and if yes, then b_dirty inodes from any cgroup written.  This
> > means that a small system background limit with an over-{fg or
> > bg}-limit cgroup could cause other cgroups that are not over their
> > limit to have their inodes written back.  In an system-over-limit
> > situation normal system-wide bdi writeback is used (writing inodes in
> > b_dirty order).  For those who want isolation, a simple rule to avoid
> > this is to ensure that that sum of all cgroup background_limits is
> > less than the system background limit.
> >=20
>=20
> Hmm, should we add the rule ?=20
> How about disallowing to set dirty_ratio bigger than system's one ?

I guess in common case people will use a common dirty ratio for all cgrou=
ps
(same as system dirty ratio). So it might not be of much value.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
