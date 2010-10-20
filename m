From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 09/11] memcg: add cgroupfs interface to memcg dirty
 limits
Date: Wed, 20 Oct 2010 12:44:45 +0900
Message-ID: <20101020124445.5a3f9e37.kamezawa.hiroyu@jp.fujitsu.com>
References: <1287448784-25684-1-git-send-email-gthelen@google.com>
	<1287448784-25684-10-git-send-email-gthelen@google.com>
	<20101020123110.fd269ab4.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20101020123110.fd269ab4.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-Id: containers.vger.kernel.org

On Wed, 20 Oct 2010 12:31:10 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Mon, 18 Oct 2010 17:39:42 -0700
> Greg Thelen <gthelen@google.com> wrote:
> 
> > Add cgroupfs interface to memcg dirty page limits:
> >   Direct write-out is controlled with:
> >   - memory.dirty_ratio
> >   - memory.dirty_limit_in_bytes
> > 
> >   Background write-out is controlled with:
> >   - memory.dirty_background_ratio
> >   - memory.dirty_background_limit_bytes
> > 
> > Other memcg cgroupfs files support 'M', 'm', 'k', 'K', 'g'
> > and 'G' suffixes for byte counts.  This patch provides the
> > same functionality for memory.dirty_limit_in_bytes and
> > memory.dirty_background_limit_bytes.
> > 
> > Signed-off-by: Andrea Righi <arighi@develer.com>
> > Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> > Signed-off-by: Greg Thelen <gthelen@google.com>
> 
> Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> One question: shouldn't we return -EINVAL when writing to dirty(_background)_limit_bytes
> a bigger value than that of global one(if any) 

This should be checked. I'm now writing one add-on.

> ? Or do you intentionally
> set the input value without comparing it with the global value ?

please see my patch sent(memcg+dirtylimit] Fix  overwriting global vm dirty limit setting by memcg)

IMHO, check at setting value is not helpful because global value can be changed
after we set this. My patch checks it at calculating dirtyable bytes.


> But, hmm..., IMHO we should check it in __mem_cgroup_dirty_param() or something
> not to allow dirty pages more than global limit.
> 
yes.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
