From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH -mmotm 1/5] memcg: disable irq at page cgroup lock
Date: Thu, 15 Apr 2010 09:14:44 +0900
Message-ID: <20100415091444.aa743668.kamezawa.hiroyu__3676.27030141211$1271290873$gmane$org@jp.fujitsu.com>
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
	<20100414140430.GB13535@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100414140430.GB13535-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: Trond-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, Andrew-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Andrea-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 14 Apr 2010 10:04:30 -0400
Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:

> On Wed, Apr 14, 2010 at 06:29:04PM +0900, KAMEZAWA Hiroyuki wrote:

> Hi Kame-san,
> 
> May be I am missing something but how does it solve the issue of making sure
> lock_page_cgroup() is not held in interrupt context? IIUC, above code will
> make sure that for file cache accouting, lock_page_cgroup() is taken only
> if task migration is on. But say task migration is on, and then some IO
> completes and we update WRITEBACK stat (i think this is the one which can
> be called from interrupt context), then we will still take the
> lock_page_cgroup() and again run into the issue of deadlocks?
> 
Yes and No.

At "Set", IIRC, almost all updates against DIRTY and WRITBACK accountings
can be done under mapping->tree_lock, which disables IRQ always.
(ex. I don't mention TestSetPageWriteback but account_page_diritied().)
Then, save/restore irq flags is just a cost and no benefit, in such cases.
Of course, there are cases irqs doesn't enabled.

About FILE_MAPPED, it's not updated under mapping->tree_lock. 
So, we'll have race with charge/uncharge. We have to take lock_page_cgroup(), always.


So, I think we'll have 2 or 3 interfaces, finally.
	mem_cgroup_update_stat_fast()  // the caller must disable IRQ and lock_page()
and
	mem_cgroup_update_stat_locked() // the caller has lock_page().
and
	mem_cgroup_update_stat_safe()  // the caller don't have to do anything.

Why update_stat_fast() is for avoiding _unnecessary_ costs.
When we lock a page and disables IRQ, we don't have to do anything.
There are no races. 

But yes, it's complicated. I'd like to see what we can do.


Thanks,
-Kame
