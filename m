From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v6 6/9] memcg: add cgroupfs interface to memcg dirty
 limits
Date: Wed, 16 Mar 2011 09:00:42 +0900
Message-ID: <20110316090042.e1f0183b.kamezawa.hiroyu@jp.fujitsu.com>
References: <1299869011-26152-1-git-send-email-gthelen@google.com>
	<1299869011-26152-7-git-send-email-gthelen@google.com>
	<4D7F7121.5040009@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <4D7F7121.5040009@librato.com>
Sender: owner-linux-mm@kvack.org
To: Mike Heffner <mike@librato.com>
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Andrea Righi <arighi@develer.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, Vivek Goyal <vgoyal@redhat.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-Id: containers.vger.kernel.org

On Tue, 15 Mar 2011 10:01:05 -0400
Mike Heffner <mike@librato.com> wrote:

> On 03/11/2011 01:43 PM, Greg Thelen wrote:
> > Add cgroupfs interface to memcg dirty page limits:
> >    Direct write-out is controlled with:
> >    - memory.dirty_ratio
> >    - memory.dirty_limit_in_bytes
> >
> >    Background write-out is controlled with:
> >    - memory.dirty_background_ratio
> >    - memory.dirty_background_limit_bytes
> 
> 
> What's the overlap, if any, with the current memory limits controlled by 
> `memory.limit_in_bytes` and the above `memory.dirty_limit_in_bytes`? If 
> I want to fairly balance memory between two cgroups be one a dirty page 
> antagonist (dd) and the other an anonymous page (memcache), do I just 
> set `memory.limit_in_bytes`? Does this patch simply provide a more 
> granular level of control of the dirty limits?
> 

dirty_ratio is for control
 - speed of write() within cgroup.
 - risk of huge latency at memory reclaim (and OOM)
   Small dirty ratio means big ratio of clean page within cgroup.
   This will make memory reclaim, pageout easier.

memory.limit_in_bytes controls the amount of memory.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
