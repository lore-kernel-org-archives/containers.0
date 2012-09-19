From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: [PATCH 3.0] memcg: warn on deeper hierarchies with use_hierarchy==0
Date: Wed, 19 Sep 2012 16:03:57 +0200
Message-ID: <20120919140357.GC5398@dhcp22.suse.cz>
References: <20120913205827.GO7677@google.com>
	<20120914150306.GQ28039@dhcp22.suse.cz>
	<20120919140203.GA5398@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120919140203.GA5398-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

From 9364396ddc0c8843fce3a7fda0255b39ba7e4f31 Mon Sep 17 00:00:00 2001
From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Date: Tue, 4 Sep 2012 15:55:03 +0200
Subject: [PATCH] memcg: warn on deeper hierarchies with use_hierarchy==0

The memory controller supports both hierarchical and non-hierarchical
behavior which is controlled by use_hierarchy knob (0 by default).
The primary motivation for this distinction was an ineffectiveness
of hierarchical accounting. This has improved a lot since it was
introduced.

This schizophrenia makes the code and integration with other controllers
more complicated (e.g. mounting it with fully hierarchical one could
have an unexpected side effects) for no good reason so it would be good
to make the memory controller behave only hierarchically.

It seems that there is no good reasons for deep cgroup hierarchies which
are not truly hierarchical so we could set the default to 1. This might,
however, lead to unexpected regressions when somebody relies on the
current default behavior. For example, consider the following setup:
		 Root[cpuset,memory]
		  |
		  A (use_hierarchy=0)
		 / \
		B  C

All three A, B, C have some tasks and their memory limits. The hierarchy
is created only because of the cpuset and its configuration.
Say the default is changed. Then a memory pressure in C could influence
both A and B which wouldn't happen before. The problem might be really
hard to notice (unexpected slowdown).
This configuration could be fixed up easily by reorganization, though:
		 Root
		  |
		  A' (use_hierarchy=1, limit=unlimited, no tasks)
		 /|\
		A B C

The problem is that we don't know whether somebody has an use case which
cannot be transformed like that. Therefore this patch starts the slow
transition to hierarchical only memory controller by warning users who
are using flat hierarchies. The warning triggers only if a subgroup of
non-root group is created with use_hierarchy==0.

Signed-off-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
---
 mm/memcontrol.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e013b8e..d8ec0cd 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4976,6 +4976,11 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 		parent = mem_cgroup_from_cont(cont->parent);
 		mem->use_hierarchy = parent->use_hierarchy;
 		mem->oom_kill_disable = parent->oom_kill_disable;
+		WARN_ONCE(!mem->use_hierarchy && parent != root_mem_cgroup,
+				"Creating hierarchies with use_hierarchy==0 "
+				"(flat hierarchy) is considered deprecated. "
+				"If you believe that your setup is correct, "
+				"we kindly ask you to contact linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org and let us know");
 	}
 
 	if (parent && parent->use_hierarchy) {
-- 
1.7.10.4

-- 
Michal Hocko
SUSE Labs
