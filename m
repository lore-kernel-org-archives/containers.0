From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 5/5] mm/cgroup: use N_MEMORY instead of N_HIGH_MEMORY
Date: Fri, 30 Aug 2013 09:41:52 +0200
Message-ID: <20130830074152.GA28658__18240.0574013174$1377848529$gmane$org@dhcp22.suse.cz>
References: <52201539.8050003@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <52201539.8050003-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jianguo Wu <wujianguo-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Wen Congyang <wency-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri 30-08-13 11:44:57, Jianguo Wu wrote:
> Since commit 8219fc48a(mm: node_states: introduce N_MEMORY),

But this very same commit also says:
"
    A.example 2) mm/page_cgroup.c use N_HIGH_MEMORY twice:
    
        One is in page_cgroup_init(void):
                for_each_node_state(nid, N_HIGH_MEMORY) {
    
        It means if the node have memory, we will allocate page_cgroup map for
        the node. We should use N_MEMORY instead here to gaim more clearly.
    
        The second using is in alloc_page_cgroup():
                if (node_state(nid, N_HIGH_MEMORY))
                        addr = vzalloc_node(size, nid);
    
        It means if the node has high or normal memory that can be allocated
        from kernel. We should keep N_HIGH_MEMORY here, and it will be better
        if the "any memory" semantic of N_HIGH_MEMORY is removed.
"

Which to me sounds like N_HIGH_MEMORY should be kept here. To be honest,
the distinction is not entirely clear to me. It was supposed to make
code cleaner but it apparently causes confusion.

It would also help if you CCed Lai Jiangshan who has introduced this
distinction. CCed now.

I wasn't CCed on the rest of the series but if you do the same
conversion, please make sure that this is not the case for others as
well.

> we introduced N_MEMORY, now N_MEMORY stands for the nodes that has any memory,
> and N_HIGH_MEMORY stands for the nodes that has normal or high memory.
> 
> The code here need to handle with the nodes which have memory,
> we should use N_MEMORY instead.
> 
> Signed-off-by: Xishi Qiu <qiuxishi-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> ---
>  mm/page_cgroup.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index 6d757e3..f6f7603 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -116,7 +116,7 @@ static void *__meminit alloc_page_cgroup(size_t size, int nid)
>  		return addr;
>  	}
>  
> -	if (node_state(nid, N_HIGH_MEMORY))
> +	if (node_state(nid, N_MEMORY))
>  		addr = vzalloc_node(size, nid);
>  	else
>  		addr = vzalloc(size);
> -- 
> 1.7.1
> 
> 

-- 
Michal Hocko
SUSE Labs
