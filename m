From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v9 13/13] memcg: check memcg dirty limits in page
 writeback
Date: Thu, 18 Aug 2011 10:40:20 +0900
Message-ID: <20110818104020.cb025fe1.kamezawa.hiroyu@jp.fujitsu.com>
References: <1313597705-6093-1-git-send-email-gthelen@google.com>
	<1313597705-6093-14-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1313597705-6093-14-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <andrea@betterlinux.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-Id: containers.vger.kernel.org

On Wed, 17 Aug 2011 09:15:05 -0700
Greg Thelen <gthelen@google.com> wrote:

> If the current process is in a non-root memcg, then
> balance_dirty_pages() will consider the memcg dirty limits as well as
> the system-wide limits.  This allows different cgroups to have distinct
> dirty limits which trigger direct and background writeback at different
> levels.
> 
> If called with a mem_cgroup, then throttle_vm_writeout() queries the
> given cgroup for its dirty memory usage limits.
> 
> Signed-off-by: Andrea Righi <andrea@betterlinux.com>
> Signed-off-by: Greg Thelen <gthelen@google.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
