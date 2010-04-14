From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH -mmotm 1/5] memcg: disable irq at page cgroup lock
Date: Wed, 14 Apr 2010 10:04:30 -0400
Message-ID: <20100414140430.GB13535__3209.5457114794$1271254103$gmane$org@redhat.com>
References: <20100317115855.GS18054@balbir.in.ibm.com>
	<20100318085411.834e1e46.kamezawa.hiroyu@jp.fujitsu.com>
	<20100318041944.GA18054@balbir.in.ibm.com>
	<20100318133527.420b2f25.kamezawa.hiroyu@jp.fujitsu.com>
	<20100318162855.GG18054@balbir.in.ibm.com>
	<20100319102332.f1d81c8d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100319024039.GH18054@balbir.in.ibm.com>
	<20100319120049.3dbf8440.kamezawa.hiroyu@jp.fujitsu.com>
	<xr931veiplpr.fsf@ninji.mtv.corp.google.com>
	<20100414182904.2f72a63d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100414182904.2f72a63d.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Apr 14, 2010 at 06:29:04PM +0900, KAMEZAWA Hiroyuki wrote:
> On Tue, 13 Apr 2010 23:55:12 -0700
> Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> =

> > On Thu, Mar 18, 2010 at 8:00 PM, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.=
fujitsu.com> wrote:
> > > On Fri, 19 Mar 2010 08:10:39 +0530
> > > Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> > >
> > >> * KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> [2010-03-19 10:=
23:32]:
> > >>
> > >> > On Thu, 18 Mar 2010 21:58:55 +0530
> > >> > Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> > >> >
> > >> > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> [2010-03-18=
 13:35:27]:
> > >> >
> > >> > > > Then, no probelm. It's ok to add mem_cgroup_udpate_stat() indp=
endent from
> > >> > > > mem_cgroup_update_file_mapped(). The look may be messy but it'=
s not your
> > >> > > > fault. But please write "why add new function" to patch descri=
ption.
> > >> > > >
> > >> > > > I'm sorry for wasting your time.
> > >> > >
> > >> > > Do we need to go down this route? We could check the stat and do=
 the
> > >> > > correct thing. In case of FILE_MAPPED, always grab page_cgroup_l=
ock
> > >> > > and for others potentially look at trylock. It is OK for differe=
nt
> > >> > > stats to be protected via different locks.
> > >> > >
> > >> >
> > >> > I _don't_ want to see a mixture of spinlock and trylock in a funct=
ion.
> > >> >
> > >>
> > >> A well documented well written function can help. The other thing is=
 to
> > >> of-course solve this correctly by introducing different locking arou=
nd
> > >> the statistics. Are you suggesting the later?
> > >>
> > >
> > > No. As I wrote.
> > > =A0 =A0 =A0 =A0- don't modify codes around FILE_MAPPED in this series.
> > > =A0 =A0 =A0 =A0- add a new functions for new statistics
> > > Then,
> > > =A0 =A0 =A0 =A0- think about clean up later, after we confirm all thi=
ngs work as expected.
> > =

> > I have ported Andrea Righi's memcg dirty page accounting patches to lat=
est
> > mmtom-2010-04-05-16-09.  In doing so I have to address this locking iss=
ue.  Does
> > the following look good?  I will (of course) submit the entire patch fo=
r review,
> > but I wanted make sure I was aiming in the right direction.
> > =

> > void mem_cgroup_update_page_stat(struct page *page,
> > 			enum mem_cgroup_write_page_stat_item idx, bool charge)
> > {
> > 	static int seq;
> > 	struct page_cgroup *pc;
> > =

> > 	if (mem_cgroup_disabled())
> > 		return;
> > 	pc =3D lookup_page_cgroup(page);
> > 	if (!pc || mem_cgroup_is_root(pc->mem_cgroup))
> > 		return;
> > =

> > 	/*
> > 	 * This routine does not disable irq when updating stats.  So it is
> > 	 * possible that a stat update from within interrupt routine, could
> > 	 * deadlock.  Use trylock_page_cgroup() to avoid such deadlock.  This
> > 	 * makes the memcg counters fuzzy.  More complicated, or lower
> > 	 * performing locking solutions avoid this fuzziness, but are not
> > 	 * currently needed.
> > 	 */
> > 	if (irqs_disabled()) {
> > 		if (! trylock_page_cgroup(pc))
> > 			return;
> > 	} else
> > 		lock_page_cgroup(pc);
> > =

> =

> I prefer trylock_page_cgroup() always.
> =

> I have another idea fixing this up _later_. (But I want to start from sim=
ple one.)
> =

> My rough idea is following.  Similar to your idea which you gave me befor=
e.
> =

> =3D=3D
> DEFINE_PERCPU(account_move_ongoing);
> DEFINE_MUTEX(move_account_mutex):
> =

> void memcg_start_account_move(void)
> {
> 	mutex_lock(&move_account_mutex);
> 	for_each_online_cpu(cpu)
> 		per_cpu(cpu, account_move_ongoing) +=3D 1;
> 	mutex_unlock(&move_account_mutex);
> 	/* Wait until there are no lockless update */
> 	synchronize_rcu();
> 	return;
> }
> =

> void memcg_end_account_move(void)
> {
> 	mutex_lock(&move_account_mutex);
> 	for_each_online_cpu(cpu)
> 		per_cpu(cpu, account_move_ongoing) -=3D 1;
> 	mutex_unlock(&move_account_mutex);
> }
> =

> /* return 1 when we took lock, return 0 if lockess OPs is guarantedd to b=
e safe */
> int memcg_start_filecache_accounting(struct page_cgroup *pc)
> {
> 	rcu_read_lock();
> 	smp_rmb();
> 	if (!this_cpu_read(move_account_ongoing))
> 		return 0; /* no move account is ongoing */
> 	lock_page_cgroup(pc);
> 	return 1;
> }
> =

> void memcg_end_filecache_accounting(struct page_cgroup *pc, int unlock)
> {
> 	if (unlock)
> 		unlock_page_cgroup(pc);
> =

> 	rcu_read_unlock();
> }
> =

> and call memcg_start_account_move()/end_account_move() in the start/end of
> migrainting chunk of pages.
> =


Hi Kame-san,

May be I am missing something but how does it solve the issue of making sure
lock_page_cgroup() is not held in interrupt context? IIUC, above code will
make sure that for file cache accouting, lock_page_cgroup() is taken only
if task migration is on. But say task migration is on, and then some IO
completes and we update WRITEBACK stat (i think this is the one which can
be called from interrupt context), then we will still take the
lock_page_cgroup() and again run into the issue of deadlocks?

Thanks
Vivek
