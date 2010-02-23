From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 1/2] memcg: dirty pages accounting and limiting
	infrastructure
Date: Tue, 23 Feb 2010 10:28:53 +0100
Message-ID: <20100223092853.GB1882__6555.22860256514$1266917386$gmane$org@linux>
References: <1266765525-30890-1-git-send-email-arighi@develer.com>
	<1266765525-30890-2-git-send-email-arighi@develer.com>
	<20100222161442.GE3063@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100222161442.GE3063-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Feb 22, 2010 at 09:44:42PM +0530, Balbir Singh wrote:
[snip]
> > +void mem_cgroup_charge_dirty(struct page *page,
> > +			enum zone_stat_item idx, int charge)
> > +{
> > +	struct mem_cgroup *mem;
> > +	struct mem_cgroup_stat_cpu *cpustat;
> > +	unsigned long flags;
> > +	int cpu;
> > +
> > +	if (mem_cgroup_disabled())
> > +		return;
> > +	/* Translate the zone_stat_item into a mem_cgroup_stat_index */
> > +	switch (idx) {
> > +	case NR_FILE_DIRTY:
> > +		idx = MEM_CGROUP_STAT_FILE_DIRTY;
> > +		break;
> > +	case NR_WRITEBACK:
> > +		idx = MEM_CGROUP_STAT_WRITEBACK;
> > +		break;
> > +	case NR_WRITEBACK_TEMP:
> > +		idx = MEM_CGROUP_STAT_WRITEBACK_TEMP;
> > +		break;
> > +	case NR_UNSTABLE_NFS:
> > +		idx = MEM_CGROUP_STAT_UNSTABLE_NFS;
> > +		break;
> > +	default:
> > +		return;
> > +	}
> > +	/* Charge the memory cgroup statistics */
> > +	mem = get_mem_cgroup_from_page(page);
> > +	if (!mem) {
> > +		mem = root_mem_cgroup;
> > +		css_get(&mem->css);
> > +	}
> > +
> > +	local_irq_save(flags);
> > +	cpu = get_cpu();
> 
> Kamezawa is in the process of changing these, so you might want to
> look at and integrate with those patches when they are ready.

OK, I'll rebase the patch to -mm. Are those changes already included in
mmotm?

Thanks,
-Andrea
