From: Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] mm: clear N_HIGH_MEMORY map before se set it again -v4
Date: Fri, 19 Jun 2009 01:18:02 -0700
Message-ID: <4A3B49BA.40100__31969.8924351998$1245399652$gmane$org@kernel.org>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m3bpokiv0u.fsf-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: steiner-sJ/iWh9BUns@public.gmane.org, Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, suresh.b.siddha-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

Nathan Lynch wrote:
> Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> writes:
>> SRAT tables may contains nodes of very small size. The arch code may
>> decide to not activate such a node. However, currently the early boot code
>> sets N_HIGH_MEMORY for such nodes. These nodes therefore seem to be active
>> although these nodes have no present pages.
>>
>> for 64bit N_HIGH_MEMORY == N_NORMAL_MEMORY, so that works for 64 bit too
>>
>> v4: update description according to Christoph
>>
>> Signed-off-by: Yinghai Lu <Yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
>> Tested-by: Jack Steiner <steiner-sJ/iWh9BUns@public.gmane.org>
>> Acked-by: Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
>>
>> ---
>>  mm/page_alloc.c |    5 +++++
>>  1 file changed, 5 insertions(+)
>>
>> Index: linux-2.6/mm/page_alloc.c
>> ===================================================================
>> --- linux-2.6.orig/mm/page_alloc.c
>> +++ linux-2.6/mm/page_alloc.c
>> @@ -4041,6 +4041,11 @@ void __init free_area_init_nodes(unsigne
>>  						early_node_map[i].start_pfn,
>>  						early_node_map[i].end_pfn);
>>  
>> +	/*
>> +	 * find_zone_movable_pfns_for_nodes/early_calculate_totalpages init
>> +	 * that node_mask, clear it at first
>> +	 */
>> +	nodes_clear(node_states[N_HIGH_MEMORY]);
>>  	/* Initialise every node */
>>  	mminit_verify_pageflags_layout();
>>  	setup_nr_node_ids();
> 
> This patch breaks the cpuset.mems cgroup attribute on an i386 kvm guest.
> 
> With v2.6.30:
> 
> # uname -r
> 2.6.30
> # cat /cgroup/cpuset.mems
> 0
> # mkdir /cgroup/test
> # for i in cpus mems ; do cat /cgroup/cpuset.$i > /cgroup/test/cpuset.$i ; done
> # echo $$ > /cgroup/test/tasks
> # echo $?
> 0
> 
> With a pulled-today Linus tree:
> 
> # uname -r
> 2.6.30-06725-g1d89b30
> # cat /cgroup/cpuset.mems
> 
> # mkdir /cgroup/test
> # for i in cpus mems ; do cat /cgroup/cpuset.$i > /cgroup/test/cpuset.$i ; done
> # echo $$ > /cgroup/test/tasks
> -bash: echo: write error: No space left on device
> 
> (Note that in addition to the ENOSPC error, /cgroup/cpuset.mems is empty
> rather than '0' in the second test.)
> 
> I bisected to the commit containing this change.  Reverting fixes the
> problem.
> 

can you use following patch to see what happens to that nodemask?

YH

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a5f3c27..eb89e8b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4189,6 +4189,7 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
 {
 	unsigned long nid;
 	int i;
+	char buf[512];
 
 	/* Sort early_node_map as initialisation assumes it is sorted */
 	sort_node_map();
@@ -4244,6 +4245,9 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
 	 * find_zone_movable_pfns_for_nodes/early_calculate_totalpages init
 	 * that node_mask, clear it at first
 	 */
+	memset(buf, 0, 512);
+	nodemask_scnprintf(buf, 512, node_states[N_HIGH_MEMORY]);
+	printk(KERN_DEBUG "before clear: node_states [%d]: %s\n", N_HIGH_MEMORY, buf);
 	nodes_clear(node_states[N_HIGH_MEMORY]);
 	/* Initialise every node */
 	mminit_verify_pageflags_layout();
@@ -4258,6 +4262,9 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
 			node_set_state(nid, N_HIGH_MEMORY);
 		check_for_regular_memory(pgdat);
 	}
+	memset(buf, 0, 512);
+	nodemask_scnprintf(buf, 512, node_states[N_HIGH_MEMORY]);
+	printk(KERN_DEBUG "after online check: node_states [%d]: %s\n", N_HIGH_MEMORY, buf);
 }
 
 static int __init cmdline_parse_core(char *p, unsigned long *core)
