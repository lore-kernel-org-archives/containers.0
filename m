From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v4 05/11] writeback: create dirty_info structure
Date: Fri, 29 Oct 2010 16:50:12 +0900
Message-ID: <20101029165012.ec0574ea.kamezawa.hiroyu@jp.fujitsu.com>
References: <1288336154-23256-1-git-send-email-gthelen@google.com>
	<1288336154-23256-6-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1288336154-23256-6-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>
List-Id: containers.vger.kernel.org

On Fri, 29 Oct 2010 00:09:08 -0700
Greg Thelen <gthelen@google.com> wrote:

> Bundle dirty limits and dirty memory usage metrics into a dirty_info
> structure to simplify interfaces of routines that need all.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
