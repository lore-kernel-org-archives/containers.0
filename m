From: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
Subject: Re: [PATCH -mm 5/5] swapcgroup (v3): implement force_empty
Date: Mon, 7 Jul 2008 15:23:51 +0900
Message-ID: <20080707152351.f6077c4d.nishimura@mxp.nes.nec.co.jp>
References: <20080704151536.e5384231.nishimura@mxp.nes.nec.co.jp>
	<20080704152423.f65932b3.nishimura@mxp.nes.nec.co.jp>
	<20080704191638.b63892f5.kamezawa.hiroyu@jp.fujitsu.com>
	<20080704213301.7d476941.nishimura@mxp.nes.nec.co.jp>
	<20080705132944.7cf07bd8.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080705132944.7cf07bd8.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org, Linux MM <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sat, 5 Jul 2008 13:29:44 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> On Fri, 4 Jul 2008 21:33:01 +0900
> Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org> wrote:
> 
> > On Fri, 4 Jul 2008 19:16:38 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> > > On Fri, 4 Jul 2008 15:24:23 +0900
> > > Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org> wrote:
> > > 
> > > > This patch implements force_empty of swapcgroup.
> > > > 
> > > > Currently, it simply uncharges all the charges from the group.
> > > > 
> > > > I think there can be other implementations.
> > > > 
> > > > What I thought are:
> > > > - move all the charges to its parent.
> > > > - unuse(swap in) all the swap charged to the group.
> > > > 
> > > 3. move all swap back to memory (see swapoff.)
> > > 
> > > 
> > Do you mean swapping in all the swap including used by
> > other groups?
> 
> swapping in all swap used by the group (not by all group)
> 
O.K. I intended to say the same thing in 2.
I'll try it and I think some part of this implementation can be
used by shrinking support too.

(snip)

> > > Hmm...but handling limit_change (at least, returns -EBUSY) will be necessary.
> > I think so too.
> > But I'm not sure now it's good or bad to support shrinking at limit_change
> > about swap.
> > Shrinking swap means increasing the memory usage and that may cause
> > another swapout.
> yes. but who reduce the limit ? it's the admin or users.
> 
> At leaset, returning -EBUSY is necesary. You can use 
> res_counter: check limit change patch which I posted yesterday.
> 
I saw your patch, and I agree that returning -EBUSY is the first step.

> > > Do you consider a some magical way to move pages in swap back to memory ?
> > > 
> > In this patch, I modified the find_next_to_unuse() to find
> > the entry charged to a specific group.
> > It might be possible to modify try_to_unuse()(or define another function
> > based on try_to_unuse()) to reduce swap usage of a specified group
> > down to some threashold.
> > But, I think, one problem here is from which device the swaps
> > should be back to memory, or usage balance between swap devices.
> > 
> Ah, that's maybe difficult one.
> As memcg has its own LRU, add MRU to swap .......is not a choice ;(
> 
Swap devices are used in order of their priority,
so storing per device usage might be usefull for this porpose...
Anyway, I should consider more.

> > > In general, I like this set but we can't change the limit on demand. (maybe)
> > > (just putting it to TO-DO-List is okay to me.)
> > > 
> > I'm sorry but what do you mean by "change the limit on demand"?
> > Could you explain more?
> > 
> In short, the administrator have to write the perfect plan to set
> each group's swap limit beforehand because we cannot decrease used swap.
> 
> 1st problem is that the user cannot reduce the usage of swap by hand.
> (He can reduce by killing process or deleting shmem.)
> Once the usage of swap of a group grows, other groups can't use much.
> 
> 2nd problem is there is no entity who controls the total amount of swap.
> The user/admin have to check the amount of free swap space by himself at planning
> each group's swap limit more carefully than memcg.
> 
> So, I think rich-control of hierarchy will be of no use ;)
> All things should be planned before the system starts.
> 
> In memcg, the amount of free memory is maintained by global LRU. It does much jobs
> for us. But free swap space isn't. It's just used on demand.
> 
> If we can't decrease usage of swap by a group by hand, the problem which this
> swap-space-controller want to fix will not be fixed at pleasant level.
> 
Thank you for your explanation.
I see your point and agree that the shrinking support is desireble.
I'll add it to my ToDo.

> Anyway, please return -EBUSY at setting limit < usage, at first :)
> That's enough for me, now.
> 
Yes, again.



Thanks,
Daisuke Nishimura.
