From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 2/4] swapcgroup: add member to swap_info_struct for cgroup
Date: Thu, 22 May 2008 18:35:14 +0900
Message-ID: <20080522183514.e8b99dc3.kamezawa.hiroyu@jp.fujitsu.com>
References: <48350F15.9070007@mxp.nes.nec.co.jp>
	<4835104B.4040405@mxp.nes.nec.co.jp>
	<20080522162312.a60d914b.kamezawa.hiroyu@jp.fujitsu.com>
	<483532FE.9080707@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <483532FE.9080707-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
Cc: YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Linux MM <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Pavel-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 22 May 2008 17:46:54 +0900
Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org> wrote:

> > ==
> > #ifdef CONFIG_CGROUP_SWAP_RES_CTR
> >   void  swap_cgroup_init_memcg(p, memcg)
> >   {
> >     do something.
> >   }
> > #else
> >    void  swap_cgroup_init_memcg(p, memcg)
> >   {
> >   }
> > #endif
> > ==
> > 
> I think swap_cgroup_init_memcg should return old value
> of p->memcg, and I would like to name it swap_cgroup_clear_memcg,
> because it is called by sys_swapoff, so "clear" rather than "init"
> would be better.
> 
> How about something like this?
> 
> struct mem_cgroup **swap_cgroup_clear_memcg(p, memcg)
> {
> 	struct mem_cgroup **mem;
> 
> 	mem = p->memcg;
> 	p->memcg = NULL;
> 
> 	return mem;
> }
> 
> and at sys_swapoff():
> 
> struct mem_cgroup **memcg;
>  :
> memcg = swap_cgroup_clear_memcg(p, memcg);
>  :
> if (memcg)
> 	vfree(memcg);
> 
seems good.


> >> +#ifdef CONFIG_CGROUP_SWAP_RES_CTLR
> >> +		p->memcg = vmalloc(maxpages * sizeof(struct mem_cgroup *));
> >> +		if (!p->memcg) {
> >> +			error = -ENOMEM;
> >> +			goto bad_swap;
> >> +		}
> >> +		memset(p->memcg, 0, maxpages * sizeof(struct mem_cgroup *));
> >> +#endif
> > void alloc_swap_ctlr_memcg(p)
> > 
> OK.
> I'll implement swap_cgroup_alloc_memcg.
> 
> > But this implies swapon will fail at memory shortage. Is it good ?
> > 
> Hum.
> Would it be better to just disabling this feature?
> 
I have no good idea. IMHO, adding printk() to show 'fatal status of
not-enough-memory-for-vmalloc' will be first step.

I believe vmalloc() tend not to fail on 64bit machine, but on i386,
vmalloc area is not enough.

Thanks,
-Kame
