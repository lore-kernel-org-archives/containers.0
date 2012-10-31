From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [V5 PATCH 08/26] memcontrol: use N_MEMORY instead N_HIGH_MEMORY
Date: Wed, 31 Oct 2012 14:18:10 +0100
Message-ID: <20121031131810.GA27381__24463.2186288529$1351689518$gmane$org@dhcp22.suse.cz>
References: <5090CD48.30604@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5090CD48.30604-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
	<1351524078-20363-7-git-send-email-laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, Wen Congyang <wency-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>, x86 maintainers <x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Jiang Liu <jiang.liu-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Hillf Danton <dhillf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Yasuaki ISIMATU <isimatu.yasuaki-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed 31-10-12 15:03:36, Wen Congyang wrote:
> At 10/30/2012 04:46 AM, David Rientjes Wrote:
> > On Mon, 29 Oct 2012, Lai Jiangshan wrote:
[...]
> >> In one word, we need a N_MEMORY. We just intrude it as an alias to
> >> N_HIGH_MEMORY and fix all im-proper usages of N_HIGH_MEMORY in late patches.
> >>
> > 
> > If this is really that problematic (and it appears it's not given that 
> > there are many use cases of it and people tend to get it right), then why 
> > not simply rename N_HIGH_MEMORY instead of introducing yet another 
> > nodemask to the equation?
> 
> The reason is that we need a node which only contains movable memory. This
> feature is very important for node hotplug. So we will add a new nodemask
> for movable memory. N_MEMORY contains movable memory but N_HIGH_MEMORY
> doesn't contain it.

OK, so the N_MOVABLE_MEMORY (or how you will call it) requires that all
the allocations will be migrateable?
How do you want to achieve that with the page_cgroup descriptors? (see
bellow)

On Mon 29-10-12 23:20:58, Lai Jiangshan wrote:
[...]
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index 5ddad0c..c1054ad 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -271,7 +271,7 @@ void __init page_cgroup_init(void)
>  	if (mem_cgroup_disabled())
>  		return;
>  
> -	for_each_node_state(nid, N_HIGH_MEMORY) {
> +	for_each_node_state(nid, N_MEMORY) {
>  		unsigned long start_pfn, end_pfn;
>  
>  		start_pfn = node_start_pfn(nid);

This will call init_section_page_cgroup(pfn, nid) later which allocates
page_cgroup descriptors which are not movable. Or is there any code in
your patchset that handles this?
-- 
Michal Hocko
SUSE Labs
