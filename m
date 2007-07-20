From: Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Resource Management development plans
Date: Fri, 20 Jul 2007 21:49:39 +0530
Message-ID: <20070720161939.GQ2216@linux.vnet.ibm.com>
Reply-To: vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, ckrm-tech-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Here's a tentative development plan on resource management from our side.
Would request others to comment/add their plans as part of this discussion.

This plan, alongwith appropriate usage scenarios, is being requested for 
kernel-summit discussion. Most likely, the resource management plans
will be presented as part of container discussion.

1. Infrastructure
	Userland interface for task-grouping, specifying group usage limits etc

	Paul Menage's container patches will be the basis for this
	infrastructure.

2. cpu controller

- Atleast 1-level deep hierarchical proportional fair-share scheduling
- Soft and Hard limit cpu usage of group
- Fine grained cpu control (ex: parts per 1000?)
- SCHED_FIFO policy for groups
        Groups having this policy will recv all cpu cycles as long
        as they have any task runnable. This is at the cost of 
	starving other non-SCHED_FIFO groups.
- Sleeper fairness - Will help bursty workloads
- Accounting - group cpu usage

3. memory controller

- Basic rss controller
- user space oom handler
- Improve shared page accounting
- Handling of soft limits
- Provide support for accounting kernel/user memory, slabs, page tables,
  dcache entries, vma's, etc
- Improved statistics (folding)
- Add support for better tuning of containers
        i.  Low and high water marks per container
        ii. Per container swappiness support
- Per container swap file(s)

4. Disk io controller

[I don't have sufficient details at the moment on disk io controller
requirements. Will add after I talk to relevant groups here]

	

	
-- 
Regards,
vatsa
