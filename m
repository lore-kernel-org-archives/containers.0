From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH v3 01/11] memcg: add page_cgroup flags for dirty page
 tracking
Date: Tue, 19 Oct 2010 13:31:29 +0900
Message-ID: <20101019133129.5853725b.nishimura@mxp.nes.nec.co.jp>
References: <1287448784-25684-1-git-send-email-gthelen@google.com>
	<1287448784-25684-2-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1287448784-25684-2-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-Id: containers.vger.kernel.org

On Mon, 18 Oct 2010 17:39:34 -0700
Greg Thelen <gthelen@google.com> wrote:

> Add additional flags to page_cgroup to track dirty pages
> within a mem_cgroup.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Andrea Righi <arighi@develer.com>
> Signed-off-by: Greg Thelen <gthelen@google.com>

Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
