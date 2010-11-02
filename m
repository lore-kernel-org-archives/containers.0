From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] cgroup: prefer [kv]zalloc over [kv]malloc+memset in
	memory controller code.
Date: Tue, 2 Nov 2010 10:37:53 +0530
Message-ID: <20101102050752.GG3769__14022.3135510043$1288674629$gmane$org@balbir.in.ibm.com>
References: <alpine.LNX.2.00.1011012038490.12889@swampdragon.chaosbits.net>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1011012038490.12889-h2p7t3/P30RzeRGmFJ5qR7ZzlVVXadcDXqFh9Ls21Oc@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

* Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org> [2010-11-01 20:40:56]:

> Hi (please CC me on replies),
> 
> 
> Apologies to those who receive this multiple times. I screwed up the To: 
> field in my original mail :-(
> 
> 
> In mem_cgroup_alloc() we currently do either kmalloc() or vmalloc() then 
> followed by memset() to zero the memory. This can be more efficiently 
> achieved by using kzalloc() and vzalloc().
> 
> 
> Signed-off-by: Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org>
> ---
>  memcontrol.c |    5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 9a99cfa..90da698 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4199,14 +4199,13 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
> 
>  	/* Can be very big if MAX_NUMNODES is very big */
>  	if (size < PAGE_SIZE)
> -		mem = kmalloc(size, GFP_KERNEL);
> +		mem = kzalloc(size, GFP_KERNEL);
>  	else
> -		mem = vmalloc(size);
> +		mem = vzalloc(size);
> 
>  	if (!mem)
>  		return NULL;
> 
> -	memset(mem, 0, size);
>  	mem->stat = alloc_percpu(struct mem_cgroup_stat_cpu);
>  	if (!mem->stat) {
>  		if (size < PAGE_SIZE)
>

 
Acked-by: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
 

-- 
	Three Cheers,
	Balbir
