From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v8 08/12] memcg: dirty page accounting support routines
Date: Tue, 7 Jun 2011 16:44:08 +0900
Message-ID: <20110607164408.f4e92ff8.kamezawa.hiroyu@jp.fujitsu.com>
References: <1307117538-14317-1-git-send-email-gthelen@google.com>
	<1307117538-14317-9-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1307117538-14317-9-git-send-email-gthelen@google.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Chinner <david@fromorbit.com>
List-Id: containers.vger.kernel.org

On Fri,  3 Jun 2011 09:12:14 -0700
Greg Thelen <gthelen@google.com> wrote:

> Added memcg dirty page accounting support routines.  These routines are
> used by later changes to provide memcg aware writeback and dirty page
> limiting.  A mem_cgroup_dirty_info() tracepoint is is also included to
> allow for easier understanding of memcg writeback operation.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
