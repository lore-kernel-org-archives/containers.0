From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH v7 04/14] memcg: add dirty page accounting
 infrastructure
Date: Fri, 13 May 2011 18:33:08 +0900
Message-ID: <20110513183308.0c34201d.kamezawa.hiroyu@jp.fujitsu.com>
References: <1305276473-14780-1-git-send-email-gthelen@google.com>
	<1305276473-14780-5-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1305276473-14780-5-git-send-email-gthelen@google.com>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Chinner <david@fromorbit.com>
List-Id: containers.vger.kernel.org

On Fri, 13 May 2011 01:47:43 -0700
Greg Thelen <gthelen@google.com> wrote:

> Add memcg routines to count dirty, writeback, and unstable_NFS pages.
> These routines are not yet used by the kernel to count such pages.  A
> later change adds kernel calls to these new routines.
> 
> As inode pages are marked dirty, if the dirtied page's cgroup differs
> from the inode's cgroup, then mark the inode shared across several
> cgroup.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>
> Signed-off-by: Andrea Righi <arighi@develer.com>


Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


