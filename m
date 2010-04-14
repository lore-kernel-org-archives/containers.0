From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH -mmotm 1/5] memcg: disable irq at page cgroup lock
Date: Wed, 14 Apr 2010 10:05:23 -0400
Message-ID: <20100414140523.GC13535__9342.83777974105$1271254511$gmane$org@redhat.com>
References: <1268609202-15581-2-git-send-email-arighi@develer.com>
	<20100317115855.GS18054@balbir.in.ibm.com>
	<20100318085411.834e1e46.kamezawa.hiroyu@jp.fujitsu.com>
	<20100318041944.GA18054@balbir.in.ibm.com>
	<20100318133527.420b2f25.kamezawa.hiroyu@jp.fujitsu.com>
	<20100318162855.GG18054@balbir.in.ibm.com>
	<20100319102332.f1d81c8d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100319024039.GH18054@balbir.in.ibm.com>
	<20100319120049.3dbf8440.kamezawa.hiroyu@jp.fujitsu.com>
	<xr931veiplpr.fsf@ninji.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <xr931veiplpr.fsf-Pk7ff2FLCuk9fRMx9H/SexPsWskHk0ljAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Apr 13, 2010 at 11:55:12PM -0700, Greg Thelen wrote:
> On Thu, Mar 18, 2010 at 8:00 PM, KAMEZAWA Hiroyuki <kamezawa.hiroyu-LsJlEDOdPhs@public.gmane.org=
jitsu.com> wrote:
> > On Fri, 19 Mar 2010 08:10:39 +0530
> > Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> >
> >> * KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> [2010-03-19 10:23=
:32]:
> >>
> >> > On Thu, 18 Mar 2010 21:58:55 +0530
> >> > Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> >> >
> >> > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> [2010-03-18 1=
3:35:27]:
> >> >
> >> > > > Then, no probelm. It's ok to add mem_cgroup_udpate_stat() indpen=
dent from
> >> > > > mem_cgroup_update_file_mapped(). The look may be messy but it's =
not your
> >> > > > fault. But please write "why add new function" to patch descript=
ion.
> >> > > >
> >> > > > I'm sorry for wasting your time.
> >> > >
> >> > > Do we need to go down this route? We could check the stat and do t=
he
> >> > > correct thing. In case of FILE_MAPPED, always grab page_cgroup_lock
> >> > > and for others potentially look at trylock. It is OK for different
> >> > > stats to be protected via different locks.
> >> > >
> >> >
> >> > I _don't_ want to see a mixture of spinlock and trylock in a functio=
n.
> >> >
> >>
> >> A well documented well written function can help. The other thing is to
> >> of-course solve this correctly by introducing different locking around
> >> the statistics. Are you suggesting the later?
> >>
> >
> > No. As I wrote.
> > =A0 =A0 =A0 =A0- don't modify codes around FILE_MAPPED in this series.
> > =A0 =A0 =A0 =A0- add a new functions for new statistics
> > Then,
> > =A0 =A0 =A0 =A0- think about clean up later, after we confirm all thing=
s work as expected.
> =

> I have ported Andrea Righi's memcg dirty page accounting patches to latest
> mmtom-2010-04-05-16-09.  In doing so I have to address this locking issue=
.  Does
> the following look good?  I will (of course) submit the entire patch for =
review,
> but I wanted make sure I was aiming in the right direction.
> =

> void mem_cgroup_update_page_stat(struct page *page,
> 			enum mem_cgroup_write_page_stat_item idx, bool charge)
> {
> 	static int seq;
> 	struct page_cgroup *pc;
> =

> 	if (mem_cgroup_disabled())
> 		return;
> 	pc =3D lookup_page_cgroup(page);
> 	if (!pc || mem_cgroup_is_root(pc->mem_cgroup))
> 		return;
> =

> 	/*
> 	 * This routine does not disable irq when updating stats.  So it is
> 	 * possible that a stat update from within interrupt routine, could
> 	 * deadlock.  Use trylock_page_cgroup() to avoid such deadlock.  This
> 	 * makes the memcg counters fuzzy.  More complicated, or lower
> 	 * performing locking solutions avoid this fuzziness, but are not
> 	 * currently needed.
> 	 */
> 	if (irqs_disabled()) {
            ^^^^^^^^^
Or may be in_interrupt()?

> 		if (! trylock_page_cgroup(pc))
> 			return;
> 	} else
> 		lock_page_cgroup(pc);
> =

> 	__mem_cgroup_update_page_stat(pc, idx, charge);
> 	unlock_page_cgroup(pc);
> }

Vivek
