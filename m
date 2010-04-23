From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH -mmotm 1/5] memcg: disable irq at page cgroup lock
Date: Fri, 23 Apr 2010 22:54:34 +0200
Message-ID: <1272056074.1821.40.camel__24193.4463302188$1272056218$gmane$org@laptop>
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
	<g2u49b004811004142148i3db9fefaje1f20760426e0c7e@mail.gmail.com>
	<20100415152104.62593f37.nishimura@mxp.nes.nec.co.jp>
	<20100415155432.cf1861d9.kamezawa.hiroyu@jp.fujitsu.com>
	<xr93k4rxx6sd.fsf@ninji.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <xr93k4rxx6sd.fsf-Pk7ff2FLCuk9fRMx9H/SexPsWskHk0ljAL8bYrjMMd8@public.gmane.org>
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
Cc: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, 2010-04-23 at 13:17 -0700, Greg Thelen wrote:
> -       lock_page_cgroup(pc);
> +       /*
> +        * Unless a page's cgroup reassignment is possible, then avoid grabbing
> +        * the lock used to protect the cgroup assignment.
> +        */
> +       rcu_read_lock();

Where is the matching barrier?

> +       smp_rmb();
> +       if (unlikely(mem_cgroup_account_move_ongoing)) {
> +               local_irq_save(flags);

So the added irq-disable is a bug-fix?

> +               lock_page_cgroup(pc);
> +               locked = true;
> +       }
> +
>         mem = pc->mem_cgroup;
>         if (!mem || !PageCgroupUsed(pc))
>                 goto done;
> @@ -1449,6 +1468,7 @@ void mem_cgroup_update_file_mapped(struct page *page, int val)
>         /*
>          * Preemption is already disabled. We can use __this_cpu_xxx
>          */
> +       VM_BUG_ON(preemptible());

Insta-bug here, there is nothing guaranteeing we're not preemptible
here.

>         if (val > 0) {
>                 __this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
>                 SetPageCgroupFileMapped(pc);
> @@ -1458,7 +1478,11 @@ void mem_cgroup_update_file_mapped(struct page *page, int val)
>         }
>  
>  done:
> -       unlock_page_cgroup(pc);
> +       if (unlikely(locked)) {
> +               unlock_page_cgroup(pc);
> +               local_irq_restore(flags);
> +       }
> +       rcu_read_unlock();
>  } 
