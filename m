From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH mmotm 2.5/4] memcg: disable irq at page cgroup lock (Re:
	[PATCH -mmotm 3/4] memcg: dirty pages accounting and limiting
	infrastructure)
Date: Fri, 12 Mar 2010 08:46:14 +0900
Message-ID: <20100312084614.a79f9ffd.kamezawa.hiroyu__5230.53753790936$1268351536$gmane$org@jp.fujitsu.com>
References: <20100308170711.4d8b02f0.nishimura@mxp.nes.nec.co.jp>
	<20100308173100.b5997fd4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100309001252.GB13490@linux>
	<20100309091914.4b5f6661.kamezawa.hiroyu@jp.fujitsu.com>
	<20100309102928.9f36d2bb.nishimura@mxp.nes.nec.co.jp>
	<20100309045058.GX3073@balbir.in.ibm.com>
	<20100310104309.c5f9c9a9.nishimura@mxp.nes.nec.co.jp>
	<20100310035624.GP3073@balbir.in.ibm.com>
	<20100311133123.ab10183c.nishimura@mxp.nes.nec.co.jp>
	<20100311134908.48d8b0fc.kamezawa.hiroyu@jp.fujitsu.com>
	<20100311165413.GD29246@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100311165413.GD29246-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 11 Mar 2010 11:54:13 -0500
Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:

> On Thu, Mar 11, 2010 at 01:49:08PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Thu, 11 Mar 2010 13:31:23 +0900
> > Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org> wrote:
> > 
> > > On Wed, 10 Mar 2010 09:26:24 +0530, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> > > > * nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org> [2010-03-10 10:43:09]:
> > 
> > > I made a patch(attached) using both local_irq_disable/enable and local_irq_save/restore.
> > > local_irq_save/restore is used only in mem_cgroup_update_file_mapped.
> > > 
> > > And I attached a histogram graph of 30 times kernel build in root cgroup for each.
> > > 
> > >   before_root: no irq operation(original)
> > >   after_root: local_irq_disable/enable for all
> > >   after2_root: local_irq_save/restore for all
> > >   after3_root: mixed version(attached)
> > > 
> > > hmm, there seems to be a tendency that before < after < after3 < after2 ?
> > > Should I replace save/restore version to mixed version ?
> > > 
> > 
> > IMHO, starting from after2_root version is the easist.
> > If there is a chance to call lock/unlock page_cgroup can be called in
> > interrupt context, we _have to_ disable IRQ, anyway.
> > And if we have to do this, I prefer migration_lock rather than this mixture.
> > 
> > BTW, how big your system is ? Balbir-san's concern is for bigger machines.
> > But I'm not sure this change is affecte by the size of machines.
> > I'm sorry I have no big machine, now.
> 
> FWIW, I took andrea's patches (local_irq_save/restore solution) and
> compiled the kernel on 32 cores hyperthreaded (64 cpus) with make -j32
> in /dev/shm/. On this system, I can't see much difference.
> 
> I compiled the kernel 10 times and took average.
> 
> Without andrea's patches: 28.698 (seconds)
> With andrea's patches: 28.711 (seconds).
> Diff is .04%
> 
> This is all should be in root cgroup. Note, I have not mounted memory cgroup
> controller but it is compiled in. So I am assuming that root group
> accounting will still be taking place. Also assuming that it is not
> required to do actual IO to disk and /dev/shm is enough to see the results
> of local_irq_save()/restore.
> 

Thank you!. Hmm.then, irq_xxxx is not core of problem. The overhead problem
is using spinlock or not... 

Regards,
-Kame
