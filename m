From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH][memcg+dirtylimit] Fix  overwriting global vm dirty
 limit setting by memcg (Re: [PATCH v3 00/11] memcg: per cgroup dirty page
 accounting
Date: Wed, 20 Oct 2010 13:14:27 +0900
Message-ID: <20101020131427.a4998c33.kamezawa.hiroyu@jp.fujitsu.com>
References: <1287448784-25684-1-git-send-email-gthelen@google.com>
	<20101020122144.47f2b60b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20101020122144.47f2b60b.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-Id: containers.vger.kernel.org

On Wed, 20 Oct 2010 12:21:44 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> 
> One bug fix here.
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Now, at calculating dirty limit, vm_dirty_param() is called.
> This function returns dirty-limit related parameters considering
> memory cgroup settings.
> 
> Now, assume that vm_dirty_bytes=100M (global dirty limit) and
> memory cgroup has 1G of pages and 40 dirty_ratio, dirtyable memory is
> 500MB.
> 
> In this case, global_dirty_limits will consider dirty_limt as
> 500 *0.4 = 200MB. This is bad...memory cgroup is not back door.
> 
> This patch limits the return value of vm_dirty_param() considring
> global settings.
> 
> 

Sorry, this one is buggy. I'll post a new one later.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
