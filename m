From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v2 04/11] memcg: disable softirq in lock_page_cgroup()
Date: Mon, 18 Oct 2010 09:44:37 +0900
Message-ID: <20101018094437.e12aae49.kamezawa.hiroyu@jp.fujitsu.com>
References: <1287177279-30876-1-git-send-email-gthelen@google.com>
	<1287177279-30876-5-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1287177279-30876-5-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-Id: containers.vger.kernel.org

On Fri, 15 Oct 2010 14:14:32 -0700
Greg Thelen <gthelen@google.com> wrote:

> If pages are being migrated from a memcg, then updates to that
> memcg's page statistics are protected by grabbing a bit spin lock
> using lock_page_cgroup().  In an upcoming commit memcg dirty page
> accounting will be updating memcg page accounting (specifically:
> num writeback pages) from softirq.  Avoid a deadlocking nested
> spin lock attempt by disabling softirq on the local processor
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
> By disabling softirq in lock_page_cgroup, nested calls are avoided.
> The softirq would be delayed until after inc_file_mapped enables
> softirq when calling unlock_page_cgroup().
> 
> The normal, fast path, of memcg page stat updates typically
> does not need to call lock_page_cgroup(), so this change does
> not affect the performance of the common case page accounting.
> 
> Signed-off-by: Andrea Righi <arighi@develer.com>
> Signed-off-by: Greg Thelen <gthelen@google.com>

I have a patch for this problem.
So, could you reorder patch as

	1,2,3,5,6,7,8,9,10,11 

I'll post an add-on patch."12"

move_charge performance improbement patches will be posted later.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
