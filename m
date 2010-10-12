From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 04/10] memcg: disable local interrupts in
 lock_page_cgroup()
Date: Tue, 12 Oct 2010 11:09:35 +0530
Message-ID: <20101012053935.GD25875@balbir.in.ibm.com>
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
 <1286175485-30643-5-git-send-email-gthelen@google.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <1286175485-30643-5-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-Id: containers.vger.kernel.org

* Greg Thelen <gthelen@google.com> [2010-10-03 23:57:59]:

> If pages are being migrated from a memcg, then updates to that
> memcg's page statistics are protected by grabbing a bit spin lock
> using lock_page_cgroup().  In an upcoming commit memcg dirty page
> accounting will be updating memcg page accounting (specifically:
> num writeback pages) from softirq.  Avoid a deadlocking nested
> spin lock attempt by disabling interrupts on the local processor
> when grabbing the page_cgroup bit_spin_lock in lock_page_cgroup().
> This avoids the following deadlock:
> statistic
>       CPU 0             CPU 1
>                     inc_file_mapped
>                     rcu_read_lock
>   start move
>   synchronize_rcu
>                     lock_page_cgroup
>                       softirq
>                       test_clear_page_writeback
>                       mem_cgroup_dec_page_stat(NR_WRITEBACK)
>                       rcu_read_lock
>                       lock_page_cgroup   /* deadlock */
>                       unlock_page_cgroup
>                       rcu_read_unlock
>                     unlock_page_cgroup
>                     rcu_read_unlock
> 
> By disabling interrupts in lock_page_cgroup, nested calls
> are avoided.  The softirq would be delayed until after inc_file_mapped
> enables interrupts when calling unlock_page_cgroup().
> 
> The normal, fast path, of memcg page stat updates typically
> does not need to call lock_page_cgroup(), so this change does
> not affect the performance of the common case page accounting.
> 
> Signed-off-by: Andrea Righi <arighi@develer.com>
> Signed-off-by: Greg Thelen <gthelen@google.com>
-- 


It will take more convincing, all important functions (charge/uncharge
use lock_page_cgroup()). I'd like to see the page fault scalability
test results. I am not against this patch, just want to see the
scalability numbers.

	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
