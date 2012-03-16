From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 06/10] cgroup: convert memcg controller to the new cftype
	interface
Date: Fri, 16 Mar 2012 16:35:59 -0700
Message-ID: <1331940963-15756-7-git-send-email-tj@kernel.org>
References: <1331940963-15756-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1331940963-15756-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Convert memcg to use the new cftype based interface. memcg is rather
special in that

* memsw_cgroup_files creation is dependent on do_swap_account.

* ->populate() is abused for mem_cgroup_sockets_init().

memsw_cgroup_files is converted to use CGROUP_SUBSYS_CFTYPES_COND(),
where the condition is really_do_swap_account.

->populate() is preserved for register_kmem_files() invocation but I
strongly urge moving the initialization to the tail of ->create().  If
there's something which can't be done from ->create(), which isn't
clear from the comment, please let me know.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
 mm/memcontrol.c           |   31 ++++++-------------------------
 net/ipv4/tcp_memcontrol.c |    8 ++++----
 2 files changed, 10 insertions(+), 29 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ae2f0a8..f2221ce 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4665,7 +4665,9 @@ static struct cftype mem_cgroup_files[] = {
 		.mode = S_IRUGO,
 	},
 #endif
+	{ },	/* terminate */
 };
+CGROUP_SUBSYS_CFTYPES(mem_cgroup_subsys, mem_cgroup_files);
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 static struct cftype memsw_cgroup_files[] = {
@@ -4694,20 +4696,10 @@ static struct cftype memsw_cgroup_files[] = {
 		.trigger = mem_cgroup_reset,
 		.read_u64 = mem_cgroup_read,
 	},
+	{ }	/* terminate */
 };
-
-static int register_memsw_files(struct cgroup *cont, struct cgroup_subsys *ss)
-{
-	if (!do_swap_account)
-		return 0;
-	return cgroup_add_files(cont, ss, memsw_cgroup_files,
-				ARRAY_SIZE(memsw_cgroup_files));
-};
-#else
-static int register_memsw_files(struct cgroup *cont, struct cgroup_subsys *ss)
-{
-	return 0;
-}
+CGROUP_SUBSYS_CFTYPES_COND(mem_cgroup_subsys, memsw_cgroup_files,
+			   really_do_swap_account);
 #endif
 
 static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
@@ -4963,18 +4955,7 @@ static void mem_cgroup_destroy(struct cgroup *cont)
 static int mem_cgroup_populate(struct cgroup_subsys *ss,
 				struct cgroup *cont)
 {
-	int ret;
-
-	ret = cgroup_add_files(cont, ss, mem_cgroup_files,
-				ARRAY_SIZE(mem_cgroup_files));
-
-	if (!ret)
-		ret = register_memsw_files(cont, ss);
-
-	if (!ret)
-		ret = register_kmem_files(cont, ss);
-
-	return ret;
+	return register_kmem_files(cont, ss);
 }
 
 #ifdef CONFIG_MMU
diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
index e714c68..21f48f3 100644
--- a/net/ipv4/tcp_memcontrol.c
+++ b/net/ipv4/tcp_memcontrol.c
@@ -35,7 +35,9 @@ static struct cftype tcp_files[] = {
 		.trigger = tcp_cgroup_reset,
 		.read_u64 = tcp_cgroup_read,
 	},
+	{ }	/* terminate */
 };
+CGROUP_SUBSYS_CFTYPES(mem_cgroup_subsys, tcp_files);
 
 static inline struct tcp_memcontrol *tcp_from_cgproto(struct cg_proto *cg_proto)
 {
@@ -65,7 +67,7 @@ int tcp_init_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss)
 
 	cg_proto = tcp_prot.proto_cgroup(memcg);
 	if (!cg_proto)
-		goto create_files;
+		return 0;
 
 	tcp = tcp_from_cgproto(cg_proto);
 
@@ -88,9 +90,7 @@ int tcp_init_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss)
 	cg_proto->sockets_allocated = &tcp->tcp_sockets_allocated;
 	cg_proto->memcg = memcg;
 
-create_files:
-	return cgroup_add_files(cgrp, ss, tcp_files,
-				ARRAY_SIZE(tcp_files));
+	return 0;
 }
 EXPORT_SYMBOL(tcp_init_cgroup);
 
-- 
1.7.7.3
