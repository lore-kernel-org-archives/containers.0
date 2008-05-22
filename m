From: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
Subject: Re: [PATCH 4/4] swapcgroup: modify vm_swap_full for cgroup
Date: Thu, 22 May 2008 21:22:05 +0900
Message-ID: <4835656D.4020706@mxp.nes.nec.co.jp>
References: <48350F15.9070007@mxp.nes.nec.co.jp>
	<48351120.6000800@mxp.nes.nec.co.jp>
	<20080522165322.F516.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080522165322.F516.KOSAKI.MOTOHIRO-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Lee Schermerhorn <Lee.Schermerhorn-VXdhtT5mjnY@public.gmane.org>, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Linux MM <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

On 2008/05/22 17:00 +0900, KOSAKI Motohiro wrote:
> Hi,
> 
>> +#ifndef CONFIG_CGROUP_SWAP_RES_CTLR
>>  /* Swap 50% full? Release swapcache more aggressively.. */
>> -#define vm_swap_full() (nr_swap_pages*2 < total_swap_pages)
>> +#define vm_swap_full(page) (nr_swap_pages*2 < total_swap_pages)
>> +#else
>> +#define vm_swap_full(page) swap_cgroup_vm_swap_full(page)
>> +#endif
> 
> I'd prefer #ifdef rather than #ifndef.
> 
> so...
> 
> #ifdef CONFIG_CGROUP_SWAP_RES_CTLR
>   your definition
> #else
>   original definition
> #endif
> 
OK.
I'll change it.

> and vm_swap_full() isn't page granularity operation.
> this is memory(or swap) cgroup operation.
> 
> this argument is slightly odd.
> 
But what callers of vm_swap_full() know is page,
not mem_cgroup.
I don't want to add to callers something like:

  pc = get_page_cgroup(page);
  mem = pc->mem_cgroup;
  vm_swap_full(mem);


Thanks,
Daisuke Nishimura.
