From: Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] x86: only clear node_states for 64bit
Date: Mon, 29 Jun 2009 00:39:58 -0700
Message-ID: <4A486FCE.4070206@kernel.org>
References: <alpine.DEB.1.10.0906041309230.8080@gentwo.org>
	<4A2803D1.4070001@kernel.org> <m3bpokiv0u.fsf@pobox.com>
	<4A3B49BA.40100@kernel.org> <m3prd0havh.fsf@pobox.com>
	<4A3D7419.8040305@kernel.org> <m3my807ug3.fsf@pobox.com>
	<4A3FA58A.3010909@kernel.org>
	<20090626135428.d8f88a70.akpm@linux-foundation.org>
	<4A4538FE.2090101@kernel.org> <20090627171714.GD21595@elte.hu>
	<4A4683B2.106@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A4683B2.106-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Cc: steiner-sJ/iWh9BUns@public.gmane.org, cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, suresh.b.siddha-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org
List-Id: containers.vger.kernel.org

Yinghai Lu wrote:
> Ingo Molnar wrote:
>> * Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
>>
>>> Andrew Morton wrote:
>>>> On Mon, 22 Jun 2009 08:38:50 -0700
>>>> Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
>>>>
>>>>> Nathan reported that
>>>>> | commit 73d60b7f747176dbdff826c4127d22e1fd3f9f74
>>>>> | Author: Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
>>>>> | Date:   Tue Jun 16 15:33:00 2009 -0700
>>>>> |
>>>>> |    page-allocator: clear N_HIGH_MEMORY map before we set it again
>>>>> |    
>>>>> |    SRAT tables may contains nodes of very small size.  The arch code may
>>>>> |    decide to not activate such a node.  However, currently the early boot
>>>>> |    code sets N_HIGH_MEMORY for such nodes.  These nodes therefore seem to be
>>>>> |    active although these nodes have no present pages.
>>>>> |    
>>>>> |    For 64bit N_HIGH_MEMORY == N_NORMAL_MEMORY, so that works for 64 bit too
>>>>>
>>>>> the cpuset.mems cgroup attribute on an i386 kvm guest
>>>>>
>>>>> fix it by only clearing node_states[N_NORMAL_MEMORY] for 64bit only.
>>>>> and need to do save/restore for that in find_zone_movable_pfn
>>>>>
>>>> There appear to be some words omitted from this changelog - it doesn't
>>>> make sense.
>>>>
>>>> I think that perhaps a line got deleted before "the cpuset.mems cgroup
>>>> ...".  That was the line which actualy describes the bug which we're
>>>> fixing.  Or perhaps it was a single word?  "zeroes".
>>>>
>>>>
>>>> I did this:
>>>>
>>>> Nathan reported that
>>>> : 
>>>> : | commit 73d60b7f747176dbdff826c4127d22e1fd3f9f74
>>>> : | Author: Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
>>>> : | Date:   Tue Jun 16 15:33:00 2009 -0700
>>>> : |
>>>> : |    page-allocator: clear N_HIGH_MEMORY map before we set it again
>>>> : |
>>>> : |    SRAT tables may contains nodes of very small size.  The arch code may
>>>> : |    decide to not activate such a node.  However, currently the early boot
>>>> : |    code sets N_HIGH_MEMORY for such nodes.  These nodes therefore seem to be
>>>> : |    active although these nodes have no present pages.
>>>> : |
>>>> : |    For 64bit N_HIGH_MEMORY == N_NORMAL_MEMORY, so that works for 64 bit too
>>>> : 
>>> "
>>>> : unintentionally and incorrectly clears the cpuset.mems cgroup attribute on
>>>> : an i386 kvm guest
>>> "
>>> ==> 
>>>
>>> 32bit assume NORMAL_MEMORY bit and HIGH_MEMORY bit are set for 
>>> Node0 always.
>> Where in the code is this assumption?
> 
> in mm/page_alloc.c
> /*
>  * Array of node states.
>  */
> nodemask_t node_states[NR_NODE_STATES] __read_mostly = {
>         [N_POSSIBLE] = NODE_MASK_ALL,
>         [N_ONLINE] = { { [0] = 1UL } },
> #ifndef CONFIG_NUMA
>         [N_NORMAL_MEMORY] = { { [0] = 1UL } },
> #ifdef CONFIG_HIGHMEM
>         [N_HIGH_MEMORY] = { { [0] = 1UL } },
> #endif
>         [N_CPU] = { { [0] = 1UL } },
> #endif  /* NUMA */
> };
> EXPORT_SYMBOL(node_states);
> 
> for x86 64bit, we clear POSSIBLE and ONLINE in arch/x86/mm/numa_64.c::initmem_init
> and this patch clear NORMAL in arch/x86/mm/init_64.c::paging_init
> 
> for x86 32bit: ONLINE get cleared in get_memcfg_from_srat()
> and NORMAL and HIGH_MEMORY are not cleared
> before try to set new in mm/page_alloc.c::free_area_init_nodes
> 
>>> and some code only check if HIGH_MEMORY is there to know if 
>>> NORMAL_MEMORY is there.
>> Which code is that exactly?
>>
> with grep:
> arch/x86/mm/init_64.c:	nodes_clear(node_states[N_NORMAL_MEMORY]);
> drivers/base/node.c:	return print_nodes_state(N_NORMAL_MEMORY, buf);
> include/linux/nodemask.h:	N_NORMAL_MEMORY,	/* The node has regular memory */
> include/linux/nodemask.h:	N_HIGH_MEMORY = N_NORMAL_MEMORY,
> mm/memcontrol.c:	if (!node_state(node, N_NORMAL_MEMORY))
> mm/page_alloc.c:	[N_NORMAL_MEMORY] = { { [0] = 1UL } },
> mm/page_alloc.c:			node_set_state(zone_to_nid(zone), N_NORMAL_MEMORY);
> mm/slub.c:	for_each_node_state(node, N_NORMAL_MEMORY) {
> mm/slub.c:	for_each_node_state(node, N_NORMAL_MEMORY) {
> mm/slub.c:	for_each_node_state(node, N_NORMAL_MEMORY) {
> mm/slub.c:	for_each_node_state(node, N_NORMAL_MEMORY) {
> mm/slub.c:	for_each_node_state(node, N_NORMAL_MEMORY) {
> mm/slub.c:	for_each_node_state(node, N_NORMAL_MEMORY) {
> mm/slub.c:		for_each_node_state(node, N_NORMAL_MEMORY) {
> mm/slub.c:		for_each_node_state(node, N_NORMAL_MEMORY) {
> mm/slub.c:	for_each_node_state(node, N_NORMAL_MEMORY)
> 
> Documentation/cgroups/cpusets.txt:automatically tracks the value of node_states[N_HIGH_MEMORY]--i.e.,
> Documentation/memory-hotplug.txt:status_change_nid is set node id when N_HIGH_MEMORY of nodemask is (will be)
> arch/ia64/kernel/uncached.c:		if (!node_state(nid, N_HIGH_MEMORY))
> drivers/base/node.c:	return print_nodes_state(N_HIGH_MEMORY, buf);
> include/linux/cpuset.h:#define cpuset_current_mems_allowed (node_states[N_HIGH_MEMORY])
> include/linux/nodemask.h:	N_HIGH_MEMORY,		/* The node has regular or high memory */
> include/linux/nodemask.h:	N_HIGH_MEMORY = N_NORMAL_MEMORY,
> kernel/cpuset.c: * found any online mems, return node_states[N_HIGH_MEMORY].
> kernel/cpuset.c: * of node_states[N_HIGH_MEMORY].
> kernel/cpuset.c:					node_states[N_HIGH_MEMORY]))
> kernel/cpuset.c:					node_states[N_HIGH_MEMORY]);
> kernel/cpuset.c:		*pmask = node_states[N_HIGH_MEMORY];
> kernel/cpuset.c:	BUG_ON(!nodes_intersects(*pmask, node_states[N_HIGH_MEMORY]));
> kernel/cpuset.c:	 * top_cpuset.mems_allowed tracks node_stats[N_HIGH_MEMORY];
> kernel/cpuset.c:				node_states[N_HIGH_MEMORY]))
> kernel/cpuset.c:		    nodes_subset(cp->mems_allowed, node_states[N_HIGH_MEMORY]))
> kernel/cpuset.c:						node_states[N_HIGH_MEMORY]);
> kernel/cpuset.c: * Keep top_cpuset.mems_allowed tracking node_states[N_HIGH_MEMORY].
> kernel/cpuset.c: * Call this routine anytime after node_states[N_HIGH_MEMORY] changes.
> kernel/cpuset.c:		top_cpuset.mems_allowed = node_states[N_HIGH_MEMORY];
> kernel/cpuset.c:	top_cpuset.mems_allowed = node_states[N_HIGH_MEMORY];
> kernel/cpuset.c: * subset of node_states[N_HIGH_MEMORY], even if this means going outside the
> mm/memcontrol.c:		for_each_node_state(node, N_HIGH_MEMORY) {
> mm/memory_hotplug.c:		node_set_state(zone_to_nid(zone), N_HIGH_MEMORY);
> mm/mempolicy.c:	if (!nodes_subset(new, node_states[N_HIGH_MEMORY])) {
> mm/mempolicy.c:	for_each_node_state(nid, N_HIGH_MEMORY) {
> mm/mempolicy.c:		if (!nodes_subset(nodes, node_states[N_HIGH_MEMORY]))
> mm/mempolicy.c:			nodes = node_states[N_HIGH_MEMORY];
> mm/mempolicy.c:			&node_states[N_HIGH_MEMORY], MPOL_MF_STATS, md);
> mm/mempolicy.c:	for_each_node_state(n, N_HIGH_MEMORY)
> mm/migrate.c:			if (!node_state(node, N_HIGH_MEMORY))
> mm/oom_kill.c:	nodemask_t nodes = node_states[N_HIGH_MEMORY];
> mm/page-writeback.c:	for_each_node_state(node, N_HIGH_MEMORY) {
> mm/page_alloc.c:	[N_HIGH_MEMORY] = { { [0] = 1UL } },
> mm/page_alloc.c: * tasks mems_allowed, or node_states[N_HIGH_MEMORY].)
> mm/page_alloc.c:					&node_states[N_HIGH_MEMORY];
> mm/page_alloc.c:	for_each_node_state(n, N_HIGH_MEMORY) {
> mm/page_alloc.c:				(nodes_weight(node_states[N_HIGH_MEMORY]) + 1);
> mm/page_alloc.c: * Populate N_HIGH_MEMORY for calculating usable_nodes.
> mm/page_alloc.c:			node_set_state(early_node_map[i].nid, N_HIGH_MEMORY);
> mm/page_alloc.c:	nodemask_t saved_node_state = node_states[N_HIGH_MEMORY];
> mm/page_alloc.c:	int usable_nodes = nodes_weight(node_states[N_HIGH_MEMORY]);
> mm/page_alloc.c:	for_each_node_state(nid, N_HIGH_MEMORY) {
> mm/page_alloc.c:	node_states[N_HIGH_MEMORY] = saved_node_state;
> mm/page_alloc.c:			node_set_state(nid, N_HIGH_MEMORY);
> mm/vmalloc.c:		for_each_node_state(nr, N_HIGH_MEMORY)
> mm/vmscan.c:		for_each_node_state(nid, N_HIGH_MEMORY) {
> mm/vmscan.c:	for_each_node_state(nid, N_HIGH_MEMORY)
> mm/vmstat.c:	if (!node_state(pgdat->node_id, N_HIGH_MEMORY))
> 
> for 64bit N_HIGH_MEMORY == NORMAL_MEMORY
> 
> for 32bit, there are more reference to N_HIGH_MEMORY...
> 

 - Why is this patch good/desired?

fix the broken with cpuset.mems cgroup attribute on an i386 kvm guest

 - What did prior code do, and why was that wrong?

clear node_states[N_HIGH_MEMORY] for 32 bit and 64bit.
actually we only need clear that for 64bit to make that right for some strange
case like small range in one node.

 - What were the bad effects. (crash, right?)

cpuset.mems can not be used ...

 - What does this patch do to achieve that good status?


fix the problem with cpuset.mems and only keep the clearing for x86 64bit.

YH
