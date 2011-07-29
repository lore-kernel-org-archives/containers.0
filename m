From: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH v3 RESEND] cgroup/kmemcheck: Annotate alloc_page() for
	cgroup allocations
Date: Fri, 29 Jul 2011 09:31:41 -0400
Message-ID: <1311946302.21143.37.camel__5185.21215203709$1311946376$gmane$org@gandalf.stny.rr.com>
References: <1311699911.3526.87.camel@gandalf.stny.rr.com>
	<20110726173816.GA26597@tiehlicka.suse.cz>
	<1311702110.3526.98.camel@gandalf.stny.rr.com>
	<1311702244.3526.100.camel@gandalf.stny.rr.com>
	<1311704249.3526.106.camel@gandalf.stny.rr.com>
	<20110726184342.GB26597@tiehlicka.suse.cz>
	<1311707088.21143.0.camel@gandalf.stny.rr.com>
	<1311732644.21143.5.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1311732644.21143.5.camel-f9ZlEuEWxVcI6MkJdU+c8EEOCMrvLtNR@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Randy Dunlap <rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>, Minchan Kim <minchan.kim-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Andrew,

On Tue, 2011-07-26 at 22:10 -0400, Steven Rostedt wrote:
> [ Resending with CGROUP maintainers Cc'd this time ]

Paul sent me a note saying that these patches usually go through -mm,
want to take them?

Thanks,

-- Steve

> 
> When the cgroup base was allocated with kmalloc, it was necessary to
> annotate the variable with kmemcheck_not_leak(). But because it has
> recently been changed to be allocated with alloc_page() (which skips
> kmemleak checks) causes a warning on boot up.
> 
> I was triggering this output:
> 
> allocated 8388608 bytes of page_cgroup
> please try 'cgroup_disable=memory' option if you don't want memory cgroups
> kmemleak: Trying to color unknown object at 0xf5840000 as Grey
> Pid: 0, comm: swapper Not tainted 3.0.0-test #12
> Call Trace:
>  [<c17e34e6>] ? printk+0x1d/0x1f^M
>  [<c10e2941>] paint_ptr+0x4f/0x78
>  [<c178ab57>] kmemleak_not_leak+0x58/0x7d
>  [<c108ae9f>] ? __rcu_read_unlock+0x9/0x7d
>  [<c1cdb462>] kmemleak_init+0x19d/0x1e9
>  [<c1cbf771>] start_kernel+0x346/0x3ec
>  [<c1cbf1b4>] ? loglevel+0x18/0x18
>  [<c1cbf0aa>] i386_start_kernel+0xaa/0xb0
> 
> After a bit of debugging I tracked the object 0xf840000 (and others)
> down to the cgroup code. The change from allocating base with kmalloc to
> alloc_page() has the base not calling kmemleak_alloc() which adds the
> pointer to the object_tree_root, but kmemleak_not_leak() adds it to the
> crt_early_log[] table. On kmemleak_init(), the entry is found in the
> early_log[] but not the object_tree_root, and this error message is
> displayed.
> 
> If alloc_page() fails then it defaults back to vmalloc() which still
> uses the kmemleak_alloc() which makes us still need the
> kmemleak_not_leak() call. The solution is to call the kmemleak_alloc()
> directly if the alloc_page() succeeds.
> 
> Reviewed-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
> Reviewed-by: Minchan Kim <minchan.kim-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Acked-by: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> Signed-off-by: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
> 
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index 53bffc6..1eb534a 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -133,10 +133,13 @@ struct page *lookup_cgroup_page(struct page_cgroup *pc)
>  static void *__meminit alloc_page_cgroup(size_t size, int nid)
>  {
>  	void *addr = NULL;
> +	gfp_t flags = GFP_KERNEL | __GFP_NOWARN;
>  
> -	addr = alloc_pages_exact_nid(nid, size, GFP_KERNEL | __GFP_NOWARN);
> -	if (addr)
> +	addr = alloc_pages_exact_nid(nid, size, flags);
> +	if (addr) {
> +		kmemleak_alloc(addr, size, 1, flags);
>  		return addr;
> +	}
>  
>  	if (node_state(nid, N_HIGH_MEMORY))
>  		addr = vmalloc_node(size, nid);
> 
> 
