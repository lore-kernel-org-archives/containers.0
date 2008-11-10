From: Andrea Righi <righi.andrea@gmail.com>
Subject: Re: [patch 0/7] cpuset writeback throttling
Date: Mon, 10 Nov 2008 10:02:13 +0100
Message-ID: <4917F895.109@gmail.com>
References: <alpine.DEB.2.00.0810292337170.23858@chino.kir.corp.google.com>	<20081104124753.fb1dde5a.akpm@linux-foundation.org>	<1225831988.7803.1939.camel@twins>	<20081104131637.68fbe055.akpm@linux-foundation.org>	<1225833710.7803.1993.camel@twins>	<20081104135004.f1717fcf.akpm@linux-foundation.org>	<Pine.LNX.4.64.0811041601100.5077@quilx.com>	<20081104143534.b5c16147.akpm@linux-foundation.org>	<Pine.LNX.4.64.0811041648350.6254@quilx.com>	<20081104153610.bbfd5ed8.akpm@linux-foundation.org>	<Pine.LNX.4.64.0811042036000.31167@quilx.com>	<20081104190505.769b93ec.akpm@linux-foundation.org> <20081105133157.db8bae72.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: righi.andrea@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754888AbYKJJDu@vger.kernel.org>
In-Reply-To: <20081105133157.db8bae72.kamezawa.hiroyu@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, rientjes@google.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, peterz@infradead.org, npiggin@suse.de, menage@google.com, dfults@sgi.com, linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

On 2008-11-05 05:31, KAMEZAWA Hiroyuki wrote:
> On Tue, 4 Nov 2008 19:05:05 -0800
> Andrew Morton <akpm@linux-foundation.org> wrote:
>> Generally, I worry that this is a specific fix to a specific problem
>> encountered on specific machines with specific setups and specific
>> workloads, and that it's just all too low-level and myopic.
>>
>> And now we're back in the usual position where there's existing code and
>> everyone says it's terribly wonderful and everyone is reluctant to step
>> back and look at the big picture.  Am I wrong?
>>
>>
>> Plus: we need per-memcg dirty-memory throttling, and this is more
>> important than per-cpuset, I suspect.  How will the (already rather
>> buggy) code look once we've stuffed both of them in there?
>>
>>
> IIUC, Andrea Righ posted 2 patches around dirty_ratio. (added him to CC:)
> in early October.
> 
>   (1) patch for adding dirty_ratio_pcm. (1/100000)
>   (2) per-memcg dirty ratio. (maybe this..http://lkml.org/lkml/2008/9/12/121)
>  
> (1) should be just posted again.
> 
> Because we have changed page_cgroup implementation, (2) should be reworked.
> "rework" itself will not be very difficult.
> (.... we tend to be stick to "what interface is the best" discussion ;) 
> 
> But memcg itself is not so weak against dirty_pages because we don't call
> try_to_free_pages() becasue of memory shortage but because of memory limitation.
> 
> BTW, in my current stack, followings are queued.
>    a. handle SwapCache in proper way in memcg.
>    b. handle swap_cgroup (if configured)
>    c. make LRU handling easier
> 
> For making per-memcg dirty_ratio sane, (a) should go ahead. I do (a) now.
> If Andrea seems to be too busy, I'll schedule dirty_ratio-for-memcg as my work.
> 

Hi Kame,

sorry for my late. If it's not too late tonight I'll rebase and test (1)
to 2.6.28-rc2-mm1 and start to rework on (2), also considering the
David's suggestion (split NR_UNSTABLE_NFS from NR_FILE_DIRTY).

-Andrea
