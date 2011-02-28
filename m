From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v5 3/9] writeback: convert variables to unsigned
Date: Mon, 28 Feb 2011 11:28:46 +0900
Message-ID: <20110228112846.454cea86.kamezawa.hiroyu@jp.fujitsu.com>
References: <1298669760-26344-1-git-send-email-gthelen@google.com>
	<1298669760-26344-4-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1298669760-26344-4-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Vivek Goyal <vgoyal@redhat.com>
List-Id: containers.vger.kernel.org

On Fri, 25 Feb 2011 13:35:54 -0800
Greg Thelen <gthelen@google.com> wrote:

> Convert two balance_dirty_pages() page counter variables (nr_reclaimable
> and nr_writeback) from 'long' to 'unsigned long'.
> 
> These two variables are used to store results from global_page_state().
> global_page_state() returns unsigned long and carefully sums per-cpu
> counters explicitly avoiding returning a negative value.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>

Reviewd-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
