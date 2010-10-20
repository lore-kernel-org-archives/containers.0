From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH v3 10/11] writeback: make determine_dirtyable_memory()
 static.
Date: Wed, 20 Oct 2010 12:47:24 +0900
Message-ID: <20101020124724.5e50517b.nishimura@mxp.nes.nec.co.jp>
References: <1287448784-25684-1-git-send-email-gthelen@google.com>
	<1287448784-25684-11-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1287448784-25684-11-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-Id: containers.vger.kernel.org

On Mon, 18 Oct 2010 17:39:43 -0700
Greg Thelen <gthelen@google.com> wrote:

> The determine_dirtyable_memory() function is not used outside of
> page writeback.  Make the routine static.  No functional change.
> Just a cleanup in preparation for a change that adds memcg dirty
> limits consideration into global_dirty_limits().
> 
> Signed-off-by: Andrea Righi <arighi@develer.com>
> Signed-off-by: Greg Thelen <gthelen@google.com>

Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
