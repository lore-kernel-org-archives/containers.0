From: Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] mm: clear N_HIGH_MEMORY map before se set it again -v4
Date: Fri, 19 Jun 2009 09:16:57 -0700
Message-ID: <4A3BB9F9.6090203__19459.9545248368$1245428467$gmane$org@kernel.org>
References: <4A05269D.8000701@kernel.org> <20090512111623.GG25923@csn.ul.ie>
	<4A0A64FB.4080504@kernel.org> <20090513145950.GB28097@csn.ul.ie>
	<4A0C4910.7090508@kernel.org> <4A0C4A2A.6080009@kernel.org>
	<20090514095414.ba8356e5.akpm@linux-foundation.org>
	<4A0C4F67.5080802@kernel.org>
	<20090514102554.b3a36f19.akpm@linux-foundation.org>
	<4A0C563A.3020100@kernel.org> <4A2758CB.9090404@kernel.org>
	<alpine.DEB.1.10.0906041236520.5377@gentwo.org>
	<4A27FAD4.2010104@kernel.org>
	<alpine.DEB.1.10.0906041309230.8080@gentwo.org>
	<4A2803D1.4070001@kernel.org> <m3bpokiv0u.fsf@pobox.com>
	<4A3B49BA.40100@kernel.org> <m3prd0havh.fsf@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m3prd0havh.fsf-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>
Cc: steiner-sJ/iWh9BUns@public.gmane.org, Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, suresh.b.siddha-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Mel Gorman <mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org
List-Id: containers.vger.kernel.org

Nathan Lynch wrote:
> Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> writes:
>>> I bisected to the commit containing this change.  Reverting fixes the
>>> problem.
>>>
>> can you use following patch to see what happens to that nodemask?
> 
> # dmesg | grep node_states
> before clear: node_states [3]: 1
> after online check: node_states [3]: 0
> 

/*
 * Array of node states.
 */
nodemask_t node_states[NR_NODE_STATES] __read_mostly = {
        [N_POSSIBLE] = NODE_MASK_ALL,
        [N_ONLINE] = { { [0] = 1UL } },
#ifndef CONFIG_NUMA
        [N_NORMAL_MEMORY] = { { [0] = 1UL } },
#ifdef CONFIG_HIGHMEM
        [N_HIGH_MEMORY] = { { [0] = 1UL } },
#endif
        [N_CPU] = { { [0] = 1UL } },
#endif  /* NUMA */
};
EXPORT_SYMBOL(node_states);

preset that


and

Zone PFN ranges:
  DMA      0x00000000 -> 0x00001000
  Normal   0x00001000 -> 0x0001fff0
  HighMem  0x0001fff0 -> 0x0001fff0
Movable zone start PFN for each node
early_node_map[2] active PFN ranges
    0: 0x00000000 -> 0x0000009f
    0: 0x00000100 -> 0x0001fff0
before clear: node_states [3]: 1
On node 0 totalpages: 130959
free_area_init_node: node 0, pgdat c0976960, node_mem_map c1151000
  DMA zone: 60 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 3939 pages, LIFO batch:0
  Normal zone: 1860 pages used for memmap
  Normal zone: 125100 pages, LIFO batch:31
after online check: node_states [3]: 0


you don't have high mem, so we should it.

really hate those preset value assume node 0 has RAM...


YH
