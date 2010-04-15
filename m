From: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH -mmotm 1/5] memcg: disable irq at page cgroup lock
Date: Wed, 14 Apr 2010 21:48:25 -0700
Message-ID: <g2u49b004811004142148i3db9fefaje1f20760426e0c7e__40653.3609530472$1271307002$gmane$org@mail.gmail.com>
References: <1268609202-15581-2-git-send-email-arighi@develer.com>
	<20100318133527.420b2f25.kamezawa.hiroyu@jp.fujitsu.com>
	<20100318162855.GG18054@balbir.in.ibm.com>
	<20100319102332.f1d81c8d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100319024039.GH18054@balbir.in.ibm.com>
	<20100319120049.3dbf8440.kamezawa.hiroyu@jp.fujitsu.com>
	<xr931veiplpr.fsf@ninji.mtv.corp.google.com>
	<20100414140523.GC13535@redhat.com>
	<xr9339yxyepc.fsf@ninji.mtv.corp.google.com>
	<20100415114022.ef01b704.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100415114022.ef01b704.nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Apr 14, 2010 at 7:40 PM, Daisuke Nishimura
<nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org> wrote:
> On Wed, 14 Apr 2010 13:14:07 -0700, Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrot=
e:
>> Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
>>
>> > On Tue, Apr 13, 2010 at 11:55:12PM -0700, Greg Thelen wrote:
>> >> On Thu, Mar 18, 2010 at 8:00 PM, KAMEZAWA Hiroyuki <kamezawa.hiroyu@j=
p.fujitsu.com> wrote:
>> >> > On Fri, 19 Mar 2010 08:10:39 +0530
>> >> > Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
>> >> >
>> >> >> * KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> [2010-03-19 1=
0:23:32]:
>> >> >>
>> >> >> > On Thu, 18 Mar 2010 21:58:55 +0530
>> >> >> > Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
>> >> >> >
>> >> >> > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> [2010-03-=
18 13:35:27]:
>> >> >> >
>> >> >> > > > Then, no probelm. It's ok to add mem_cgroup_udpate_stat() in=
dpendent from
>> >> >> > > > mem_cgroup_update_file_mapped(). The look may be messy but i=
t's not your
>> >> >> > > > fault. But please write "why add new function" to patch desc=
ription.
>> >> >> > > >
>> >> >> > > > I'm sorry for wasting your time.
>> >> >> > >
>> >> >> > > Do we need to go down this route? We could check the stat and =
do the
>> >> >> > > correct thing. In case of FILE_MAPPED, always grab page_cgroup=
_lock
>> >> >> > > and for others potentially look at trylock. It is OK for diffe=
rent
>> >> >> > > stats to be protected via different locks.
>> >> >> > >
>> >> >> >
>> >> >> > I _don't_ want to see a mixture of spinlock and trylock in a fun=
ction.
>> >> >> >
>> >> >>
>> >> >> A well documented well written function can help. The other thing =
is to
>> >> >> of-course solve this correctly by introducing different locking ar=
ound
>> >> >> the statistics. Are you suggesting the later?
>> >> >>
>> >> >
>> >> > No. As I wrote.
>> >> > =A0 =A0 =A0 =A0- don't modify codes around FILE_MAPPED in this seri=
es.
>> >> > =A0 =A0 =A0 =A0- add a new functions for new statistics
>> >> > Then,
>> >> > =A0 =A0 =A0 =A0- think about clean up later, after we confirm all t=
hings work as expected.
>> >>
>> >> I have ported Andrea Righi's memcg dirty page accounting patches to l=
atest
>> >> mmtom-2010-04-05-16-09. =A0In doing so I have to address this locking=
 issue. =A0Does
>> >> the following look good? =A0I will (of course) submit the entire patc=
h for review,
>> >> but I wanted make sure I was aiming in the right direction.
>> >>
>> >> void mem_cgroup_update_page_stat(struct page *page,
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum mem_cgroup_write_page_sta=
t_item idx, bool charge)
>> >> {
>> >> =A0 =A0static int seq;
>> >> =A0 =A0struct page_cgroup *pc;
>> >>
>> >> =A0 =A0if (mem_cgroup_disabled())
>> >> =A0 =A0 =A0 =A0 =A0 =A0return;
>> >> =A0 =A0pc =3D lookup_page_cgroup(page);
>> >> =A0 =A0if (!pc || mem_cgroup_is_root(pc->mem_cgroup))
>> >> =A0 =A0 =A0 =A0 =A0 =A0return;
>> >>
>> >> =A0 =A0/*
>> >> =A0 =A0 * This routine does not disable irq when updating stats. =A0S=
o it is
>> >> =A0 =A0 * possible that a stat update from within interrupt routine, =
could
>> >> =A0 =A0 * deadlock. =A0Use trylock_page_cgroup() to avoid such deadlo=
ck. =A0This
>> >> =A0 =A0 * makes the memcg counters fuzzy. =A0More complicated, or low=
er
>> >> =A0 =A0 * performing locking solutions avoid this fuzziness, but are =
not
>> >> =A0 =A0 * currently needed.
>> >> =A0 =A0 */
>> >> =A0 =A0if (irqs_disabled()) {
>> > =A0 =A0 =A0 =A0 =A0 =A0 ^^^^^^^^^
>> > Or may be in_interrupt()?
>>
>> Good catch. =A0I will replace irqs_disabled() with in_interrupt().
>>
> I think you should check both. __remove_from_page_cache(), which will upd=
ate
> DIRTY, is called with irq disabled(iow, under mapping->tree_lock) but not=
 in
> interrupt context.

The only reason to use trylock in this case is to prevent deadlock
when running in a context that may have preempted or interrupted a
routine that already holds the bit locked.  In the
__remove_from_page_cache() irqs are disabled, but that does not imply
that a routine holding the spinlock has been preempted.  When the bit
is locked, preemption is disabled.  The only way to interrupt a holder
of the bit for an interrupt to occur (I/O, timer, etc).  So I think
that in_interrupt() is sufficient.  Am I missing something?

> Anyway, I tend to agree with KAMEZAWA-san: use trylock always(except for =
FILE_MAPPED),
> or add some new interfaces(e.g. mem_cgroup_update_stat_locked/safe...).

Thank you for the input.  I'm thinking more on this.

--
Greg
