From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 04/11] memcg: add lock to synchronize page accounting
 and migration
Date: Tue, 19 Oct 2010 09:45:12 +0900
Message-ID: <20101019094512.11eabc62.kamezawa.hiroyu@jp.fujitsu.com>
References: <1287448784-25684-1-git-send-email-gthelen@google.com>
	<1287448784-25684-5-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1287448784-25684-5-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-Id: containers.vger.kernel.org

On Mon, 18 Oct 2010 17:39:37 -0700
Greg Thelen <gthelen@google.com> wrote:

> Performance Impact: moving a 8G anon process.
> 
> Before:
> 	real    0m0.792s
> 	user    0m0.000s
> 	sys     0m0.780s
> 
> After:
> 	real    0m0.854s
> 	user    0m0.000s
> 	sys     0m0.842s
> 
> This score is bad but planned patches for optimization can reduce
> this impact.
> 

I'll post optimization patches after this set goes to -mm.
RFC version will be posted soon.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
