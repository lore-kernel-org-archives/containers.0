From: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH -mmotm 1/5] memcg: disable irq at page cgroup lock
Date: Sat, 24 Apr 2010 08:53:27 -0700
Message-ID: <xr93aassvoco.fsf__34678.3297173262$1272124491$gmane$org@ninji.mtv.corp.google.com>
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
	<1272056074.1821.40.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org> writes:

> On Fri, 2010-04-23 at 13:17 -0700, Greg Thelen wrote:
>> -       lock_page_cgroup(pc);
>> +       /*
>> +        * Unless a page's cgroup reassignment is possible, then avoid grabbing
>> +        * the lock used to protect the cgroup assignment.
>> +        */
>> +       rcu_read_lock();
>
> Where is the matching barrier?

Good catch.  A call to smp_wmb() belongs in
mem_cgroup_begin_page_cgroup_reassignment() like so:

static void mem_cgroup_begin_page_cgroup_reassignment(void)
{
	VM_BUG_ON(mem_cgroup_account_move_ongoing);
	mem_cgroup_account_move_ongoing = true;
	smp_wmb();
	synchronize_rcu();
}

I'll add this to the patch.

>> +       smp_rmb();
>> +       if (unlikely(mem_cgroup_account_move_ongoing)) {
>> +               local_irq_save(flags);
>
> So the added irq-disable is a bug-fix?

The irq-disable is not needed for current code, only for upcoming
per-memcg dirty page accounting which will be refactoring
mem_cgroup_update_file_mapped() into a generic memcg stat update
routine.  I assume these locking changes should be bundled with the
dependant memcg dirty page accounting changes which need the ability to
update counters from irq routines.  I'm sorry I didn't make that more
clear.

>> +               lock_page_cgroup(pc);
>> +               locked = true;
>> +       }
>> +
>>         mem = pc->mem_cgroup;
>>         if (!mem || !PageCgroupUsed(pc))
>>                 goto done;
>> @@ -1449,6 +1468,7 @@ void mem_cgroup_update_file_mapped(struct page *page, int val)
>>         /*
>>          * Preemption is already disabled. We can use __this_cpu_xxx
>>          */
>> +       VM_BUG_ON(preemptible());
>
> Insta-bug here, there is nothing guaranteeing we're not preemptible
> here.

My addition of VM_BUG_ON() was to programmatic assert what the comment
was asserting.  All callers of mem_cgroup_update_file_mapped() hold the
pte spinlock, which disables preemption.  So I don't think this
VM_BUG_ON() will cause panic.  A function level comment for
mem_cgroup_update_file_mapped() declaring that "callers must have
preemption disabled" will be added to make this more clear.

>>         if (val > 0) {
>>                 __this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
>>                 SetPageCgroupFileMapped(pc);
>> @@ -1458,7 +1478,11 @@ void mem_cgroup_update_file_mapped(struct page *page, int val)
>>         }
>>  
>>  done:
>> -       unlock_page_cgroup(pc);
>> +       if (unlikely(locked)) {
>> +               unlock_page_cgroup(pc);
>> +               local_irq_restore(flags);
>> +       }
>> +       rcu_read_unlock();
>>  } 

--
Greg
