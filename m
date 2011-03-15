From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v6 0/9] memcg: per cgroup dirty page accounting
Date: Tue, 15 Mar 2011 11:54:51 +0900
Message-ID: <20110315115451.7a7d3605.kamezawa.hiroyu@jp.fujitsu.com>
References: <1299869011-26152-1-git-send-email-gthelen@google.com>
	<20110311171006.ec0d9c37.akpm@linux-foundation.org>
	<AANLkTimT-kRMQW3JKcJAZP4oD3EXuE-Bk3dqumH_10Oe@mail.gmail.com>
	<20110315105612.f600a659.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTineM7M1R6fVFJe0ax-DN=_Rnb+7Cmk5HTH0D+Na@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <AANLkTineM7M1R6fVFJe0ax-DN=_Rnb+7Cmk5HTH0D+Na@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Vivek Goyal <vgoyal@redhat.com>
List-Id: containers.vger.kernel.org

On Mon, 14 Mar 2011 19:51:22 -0700
Greg Thelen <gthelen@google.com> wrote:

> On Mon, Mar 14, 2011 at 6:56 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Mon, 14 Mar 2011 11:29:17 -0700
> > Greg Thelen <gthelen@google.com> wrote:
> >
> >> On Fri, Mar 11, 2011 at 5:10 PM, Andrew Morton
> The foreign dirtier issue is all about identifying the memcg (or
> possibly multiple bdi) that need balancing.    If the foreign dirtier
> issue is not important then we can focus on identifying inodes to
> writeback that will lower the current's memcg dirty usage.  I am fine
> ignoring the foreign dirtier issue for now and breaking the problem
> into smaller pieces.
> 
ok.

> I think this can be done with out any additional state.  Can just scan
> the memcg lru to find dirty file pages and thus inodes to pass to
> sync_inode(), or some other per-inode writeback routine?
> 

I think it works, finding inodes to be cleaned by LRU scanning.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
