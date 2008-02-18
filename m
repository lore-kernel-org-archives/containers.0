From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] memcgroup: remove a useless VM_BUG_ON()
Date: Mon, 18 Feb 2008 17:48:55 +0900
Message-ID: <20080218174855.de9182c3.kamezawa.hiroyu__2225.39158207855$1203324459$gmane$org@jp.fujitsu.com>
References: <47B9223C.9020106@linux.vnet.ibm.com>
	<20080218062209.DA59B1E3C58@siro.lan>
	<47B923C8.3090904@linux.vnet.ibm.com>
	<47B929EE.7080202@cn.fujitsu.com>
	<47B92D47.2050008@linux.vnet.ibm.com> <47B93518.6@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47B93518.6-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 18 Feb 2008 15:34:48 +0800
Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:

> Remove this VM_BUG_ON(), as Balbir stated:
> 
> We used to have a for loop with !list_empty() as a termination condition
> and VM_BUG_ON(!pc) is a spill over. With the new loop, VM_BUG_ON(!pc) does not
> make sense.
> 
> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  mm/memcontrol.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 718acf8..631002d 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -534,7 +534,6 @@ unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
>  		if (scan >= nr_to_scan)
>  			break;
>  		page = pc->page;
> -		VM_BUG_ON(!pc);
>  
>  		if (unlikely(!PageLRU(page)))
>  			continue;
> -- 
> 1.5.4.rc3
> 
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>

Thanks,
-Kame
