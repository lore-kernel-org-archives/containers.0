From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v8 11/12] writeback: make background writeback cgroup
 aware
Date: Tue, 7 Jun 2011 17:56:34 +0900
Message-ID: <20110607175634.b07f2e57.kamezawa.hiroyu@jp.fujitsu.com>
References: <1307117538-14317-1-git-send-email-gthelen@google.com>
	<1307117538-14317-12-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1307117538-14317-12-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Chinner <david@fromorbit.com>
List-Id: containers.vger.kernel.org

On Fri,  3 Jun 2011 09:12:17 -0700
Greg Thelen <gthelen@google.com> wrote:

> When the system is under background dirty memory threshold but a cgroup
> is over its background dirty memory threshold, then only writeback
> inodes associated with the over-limit cgroup(s).
> 
> In addition to checking if the system dirty memory usage is over the
> system background threshold, over_bground_thresh() also checks if any
> cgroups are over their respective background dirty memory thresholds.
> The writeback_control.for_cgroup field is set to distinguish between a
> system and memcg overage.
> 
> If performing cgroup writeback, move_expired_inodes() skips inodes that
> do not contribute dirty pages to the cgroup being written back.
> 
> After writing some pages, wb_writeback() will call
> mem_cgroup_writeback_done() to update the set of over-bg-limits memcg.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>



> ---
> Changelog since v7:
> - over_bground_thresh() now sets shared_inodes=1.  In -v7 per memcg
>   background writeback did not, so it did not write pages of shared
>   inodes in background writeback.  In the (potentially common) case
>   where the system dirty memory usage is below the system background
>   dirty threshold but at least one cgroup is over its background dirty
>   limit, then per memcg background writeback is queued for any
>   over-background-threshold cgroups.  Background writeback should be
>   allowed to writeback shared inodes.  The hope is that writing such
>   inodes has good chance of cleaning the inodes so they can transition
>   from shared to non-shared.  Such a transition is good because then the
>   inode will remain unshared until it is written by multiple cgroup.
>   Non-shared inodes offer better isolation.

If you post v9,  please adds above explanation as the comments in the code.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
