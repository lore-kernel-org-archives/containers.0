From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v2 05/11] memcg: add dirty page accounting
 infrastructure
Date: Mon, 18 Oct 2010 09:45:55 +0900
Message-ID: <20101018094555.f1d77414.kamezawa.hiroyu@jp.fujitsu.com>
References: <1287177279-30876-1-git-send-email-gthelen@google.com>
	<1287177279-30876-6-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1287177279-30876-6-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-Id: containers.vger.kernel.org

On Fri, 15 Oct 2010 14:14:33 -0700
Greg Thelen <gthelen@google.com> wrote:

> Add memcg routines to track dirty, writeback, and unstable_NFS pages.
> These routines are not yet used by the kernel to count such pages.
> A later change adds kernel calls to these new routines.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>
> Signed-off-by: Andrea Righi <arighi@develer.com>

BTW, please add "Changelog" for each patch in a series.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
