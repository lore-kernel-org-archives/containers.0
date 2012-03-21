From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 08/12] cgroup: convert memcg controller to the new cftype
	interface
Date: Wed, 21 Mar 2012 15:17:41 -0700
Message-ID: <1332368265-21586-9-git-send-email-tj@kernel.org>
References: <1332368265-21586-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1332368265-21586-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

Convert memcg to use the new cftype based interface.  kmem support
abuses ->populate() for mem_cgroup_sockets_init() so it can't be
removed at the moment.

tcp_memcontrol is updated so that tcp_files[] is registered via a
__initcall.  This change also allows removing the forward declaration
of tcp_files[].  Removed.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
 mm/memcontrol.c           |   12 +++---------
 net/ipv4/tcp_memcontrol.c |   16 ++++++++++------
 2 files changed, 13 insertions(+), 15 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1e2a9d1..a3eb82f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4708,6 +4708,7 @@ static struct cftype mem_cgroup_files[] = {
 		.read = mem_cgroup_read,
 	},
 #endif
+	{ },	/* terminate */
 };
 
 static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
@@ -4963,15 +4964,7 @@ static void mem_cgroup_destroy(struct cgroup *cont)
 static int mem_cgroup_populate(struct cgroup_subsys *ss,
 				struct cgroup *cont)
 {
-	int ret;
-
-	ret = cgroup_add_files(cont, ss, mem_cgroup_files,
-				ARRAY_SIZE(mem_cgroup_files));
-
-	if (!ret)
-		ret = register_kmem_files(cont, ss);
-
-	return ret;
+	return register_kmem_files(cont, ss);
 }
 
 #ifdef CONFIG_MMU
@@ -5485,6 +5478,7 @@ struct cgroup_subsys mem_cgroup_subsys = {
 	.can_attach = mem_cgroup_can_attach,
 	.cancel_attach = mem_cgroup_cancel_attach,
 	.attach = mem_cgroup_move_task,
+	.base_cftypes = mem_cgroup_files,
 	.early_init = 0,
 	.use_id = 1,
 };
diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
index e0c5b4e..73ba5fd 100644
--- a/net/ipv4/tcp_memcontrol.c
+++ b/net/ipv4/tcp_memcontrol.c
@@ -6,8 +6,6 @@
 #include <linux/memcontrol.h>
 #include <linux/module.h>
 
-static struct cftype tcp_files[4];	/* XXX: will be removed soon */
-
 static inline struct tcp_memcontrol *tcp_from_cgproto(struct cg_proto *cg_proto)
 {
 	return container_of(cg_proto, struct tcp_memcontrol, cg_proto);
@@ -36,7 +34,7 @@ int tcp_init_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss)
 
 	cg_proto = tcp_prot.proto_cgroup(memcg);
 	if (!cg_proto)
-		goto create_files;
+		return 0;
 
 	tcp = tcp_from_cgproto(cg_proto);
 
@@ -59,9 +57,7 @@ int tcp_init_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss)
 	cg_proto->sockets_allocated = &tcp->tcp_sockets_allocated;
 	cg_proto->memcg = memcg;
 
-create_files:
-	return cgroup_add_files(cgrp, ss, tcp_files,
-				ARRAY_SIZE(tcp_files));
+	return 0;
 }
 EXPORT_SYMBOL(tcp_init_cgroup);
 
@@ -266,4 +262,12 @@ static struct cftype tcp_files[] = {
 		.trigger = tcp_cgroup_reset,
 		.read_u64 = tcp_cgroup_read,
 	},
+	{ }	/* terminate */
 };
+
+static int __init tcp_memcontrol_init(void)
+{
+	WARN_ON(cgroup_add_cftypes(&mem_cgroup_subsys, tcp_files));
+	return 0;
+}
+__initcall(tcp_memcontrol_init);
-- 
1.7.7.3
