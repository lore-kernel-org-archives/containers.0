From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 09/11] cgroup: drop const from @buffer of
	cftype->write_string()
Date: Thu, 13 Mar 2014 15:50:11 -0400
Message-ID: <1394740213-17626-10-git-send-email-tj@kernel.org>
References: <1394740213-17626-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1394740213-17626-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

cftype->write_string() just passes on the writeable buffer from kernfs
and there's no reason to add const restriction on the buffer.  The
only thing const achieves is unnecessarily complicating parsing of the
buffer.  Drop const from @buffer.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
Cc: Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>
Cc: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
---
 block/blk-throttle.c      | 4 ++--
 block/cfq-iosched.c       | 4 ++--
 include/linux/cgroup.h    | 2 +-
 kernel/cgroup.c           | 2 +-
 kernel/cgroup_freezer.c   | 2 +-
 kernel/cpuset.c           | 2 +-
 mm/hugetlb_cgroup.c       | 2 +-
 mm/memcontrol.c           | 4 ++--
 net/core/netprio_cgroup.c | 2 +-
 net/ipv4/tcp_memcontrol.c | 2 +-
 security/device_cgroup.c  | 4 ++--
 11 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 861c363..033745c 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -1408,13 +1408,13 @@ static int tg_set_conf(struct cgroup_subsys_state *css, struct cftype *cft,
 }
 
 static int tg_set_conf_u64(struct cgroup_subsys_state *css, struct cftype *cft,
-			   const char *buf)
+			   char *buf)
 {
 	return tg_set_conf(css, cft, buf, true);
 }
 
 static int tg_set_conf_uint(struct cgroup_subsys_state *css, struct cftype *cft,
-			    const char *buf)
+			    char *buf)
 {
 	return tg_set_conf(css, cft, buf, false);
 }
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 4611879..f5de45b 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -1701,13 +1701,13 @@ static int __cfqg_set_weight_device(struct cgroup_subsys_state *css,
 }
 
 static int cfqg_set_weight_device(struct cgroup_subsys_state *css,
-				  struct cftype *cft, const char *buf)
+				  struct cftype *cft, char *buf)
 {
 	return __cfqg_set_weight_device(css, cft, buf, false);
 }
 
 static int cfqg_set_leaf_weight_device(struct cgroup_subsys_state *css,
-				       struct cftype *cft, const char *buf)
+				       struct cftype *cft, char *buf)
 {
 	return __cfqg_set_weight_device(css, cft, buf, true);
 }
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 77294fc..79993ac 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -454,7 +454,7 @@ struct cftype {
 	 * Returns 0 or -ve error code.
 	 */
 	int (*write_string)(struct cgroup_subsys_state *css, struct cftype *cft,
-			    const char *buffer);
+			    char *buffer);
 	/*
 	 * trigger() callback can be used to get some kick from the
 	 * userspace, when the actual string written is not important
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 04f6262..36d1a53 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2143,7 +2143,7 @@ static int cgroup_procs_write(struct cgroup_subsys_state *css,
 }
 
 static int cgroup_release_agent_write(struct cgroup_subsys_state *css,
-				      struct cftype *cft, const char *buffer)
+				      struct cftype *cft, char *buffer)
 {
 	struct cgroup_root *root = css->cgroup->root;
 
diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index 2ea98b2..2bc4a22 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -442,7 +442,7 @@ static void freezer_change_state(struct freezer *freezer, bool freeze)
 }
 
 static int freezer_write(struct cgroup_subsys_state *css, struct cftype *cft,
-			 const char *buffer)
+			 char *buffer)
 {
 	bool freeze;
 
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 8d53245..efbf9ba 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1610,7 +1610,7 @@ out_unlock:
  * Common handling for a write to a "cpus" or "mems" file.
  */
 static int cpuset_write_resmask(struct cgroup_subsys_state *css,
-				struct cftype *cft, const char *buf)
+				struct cftype *cft, char *buf)
 {
 	struct cpuset *cs = css_cs(css);
 	struct cpuset *trialcs;
diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index b135853..595d7fd 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -254,7 +254,7 @@ static u64 hugetlb_cgroup_read_u64(struct cgroup_subsys_state *css,
 }
 
 static int hugetlb_cgroup_write(struct cgroup_subsys_state *css,
-				struct cftype *cft, const char *buffer)
+				struct cftype *cft, char *buffer)
 {
 	int idx, name, ret;
 	unsigned long long val;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d9c6ac1..96f94a9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5242,7 +5242,7 @@ static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
  * RES_LIMIT.
  */
 static int mem_cgroup_write(struct cgroup_subsys_state *css, struct cftype *cft,
-			    const char *buffer)
+			    char *buffer)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	enum res_type type;
@@ -6063,7 +6063,7 @@ static void memcg_event_ptable_queue_proc(struct file *file,
  * Interpretation of args is defined by control file implementation.
  */
 static int memcg_write_event_control(struct cgroup_subsys_state *css,
-				     struct cftype *cft, const char *buffer)
+				     struct cftype *cft, char *buffer)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	struct mem_cgroup_event *event;
diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index f9f3a40..3825f66 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -186,7 +186,7 @@ static int read_priomap(struct seq_file *sf, void *v)
 }
 
 static int write_priomap(struct cgroup_subsys_state *css, struct cftype *cft,
-			 const char *buffer)
+			 char *buffer)
 {
 	char devname[IFNAMSIZ + 1];
 	struct net_device *dev;
diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
index 20a0aca..d4f015a 100644
--- a/net/ipv4/tcp_memcontrol.c
+++ b/net/ipv4/tcp_memcontrol.c
@@ -103,7 +103,7 @@ static int tcp_update_limit(struct mem_cgroup *memcg, u64 val)
 }
 
 static int tcp_cgroup_write(struct cgroup_subsys_state *css, struct cftype *cft,
-			    const char *buffer)
+			    char *buffer)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	unsigned long long val;
diff --git a/security/device_cgroup.c b/security/device_cgroup.c
index 7f88bcd..8365909 100644
--- a/security/device_cgroup.c
+++ b/security/device_cgroup.c
@@ -496,7 +496,7 @@ static inline bool has_children(struct dev_cgroup *devcgroup)
  * parent cgroup has the access you're asking for.
  */
 static int devcgroup_update_access(struct dev_cgroup *devcgroup,
-				   int filetype, const char *buffer)
+				   int filetype, char *buffer)
 {
 	const char *b;
 	char temp[12];		/* 11 + 1 characters needed for a u32 */
@@ -652,7 +652,7 @@ static int devcgroup_update_access(struct dev_cgroup *devcgroup,
 }
 
 static int devcgroup_access_write(struct cgroup_subsys_state *css,
-				  struct cftype *cft, const char *buffer)
+				  struct cftype *cft, char *buffer)
 {
 	int retval;
 
-- 
1.8.5.3
