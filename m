From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 07/12] memcg: always create memsw files if
	CONFIG_CGROUP_MEM_RES_CTLR_SWAP
Date: Wed, 21 Mar 2012 15:17:40 -0700
Message-ID: <1332368265-21586-8-git-send-email-tj@kernel.org>
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
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Instead of conditioning creation of memsw files on do_swap_account,
always create the files if compiled-in and fail read/write attempts
with -EOPNOTSUPP if !do_swap_account.

This is suggested by KAMEZAWA to simplify memcg file creation so that
it can use cgroup->subsys_cftypes.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
---
 mm/memcontrol.c |   65 ++++++++++++++++++++++++++----------------------------
 1 files changed, 31 insertions(+), 34 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ae2f0a8..1e2a9d1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3818,14 +3818,21 @@ static inline u64 mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
 	return val << PAGE_SHIFT;
 }
 
-static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
+static ssize_t mem_cgroup_read(struct cgroup *cont, struct cftype *cft,
+			       struct file *file, char __user *buf,
+			       size_t nbytes, loff_t *ppos)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
+	char str[64];
 	u64 val;
-	int type, name;
+	int type, name, len;
 
 	type = MEMFILE_TYPE(cft->private);
 	name = MEMFILE_ATTR(cft->private);
+
+	if (!do_swap_account && type == _MEMSWAP)
+		return -EOPNOTSUPP;
+
 	switch (type) {
 	case _MEM:
 		if (name == RES_USAGE)
@@ -3843,7 +3850,9 @@ static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
 		BUG();
 		break;
 	}
-	return val;
+
+	len = scnprintf(str, sizeof(str), "%llu\n", (unsigned long long)val);
+	return simple_read_from_buffer(buf, nbytes, ppos, str, len);
 }
 /*
  * The user of this function is...
@@ -3859,6 +3868,10 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
 
 	type = MEMFILE_TYPE(cft->private);
 	name = MEMFILE_ATTR(cft->private);
+
+	if (!do_swap_account && type == _MEMSWAP)
+		return -EOPNOTSUPP;
+
 	switch (name) {
 	case RES_LIMIT:
 		if (mem_cgroup_is_root(memcg)) { /* Can't set limit on root */
@@ -3925,12 +3938,15 @@ out:
 
 static int mem_cgroup_reset(struct cgroup *cont, unsigned int event)
 {
-	struct mem_cgroup *memcg;
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
 	int type, name;
 
-	memcg = mem_cgroup_from_cont(cont);
 	type = MEMFILE_TYPE(event);
 	name = MEMFILE_ATTR(event);
+
+	if (!do_swap_account && type == _MEMSWAP)
+		return -EOPNOTSUPP;
+
 	switch (name) {
 	case RES_MAX_USAGE:
 		if (type == _MEM)
@@ -4599,7 +4615,7 @@ static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "usage_in_bytes",
 		.private = MEMFILE_PRIVATE(_MEM, RES_USAGE),
-		.read_u64 = mem_cgroup_read,
+		.read = mem_cgroup_read,
 		.register_event = mem_cgroup_usage_register_event,
 		.unregister_event = mem_cgroup_usage_unregister_event,
 	},
@@ -4607,25 +4623,25 @@ static struct cftype mem_cgroup_files[] = {
 		.name = "max_usage_in_bytes",
 		.private = MEMFILE_PRIVATE(_MEM, RES_MAX_USAGE),
 		.trigger = mem_cgroup_reset,
-		.read_u64 = mem_cgroup_read,
+		.read = mem_cgroup_read,
 	},
 	{
 		.name = "limit_in_bytes",
 		.private = MEMFILE_PRIVATE(_MEM, RES_LIMIT),
 		.write_string = mem_cgroup_write,
-		.read_u64 = mem_cgroup_read,
+		.read = mem_cgroup_read,
 	},
 	{
 		.name = "soft_limit_in_bytes",
 		.private = MEMFILE_PRIVATE(_MEM, RES_SOFT_LIMIT),
 		.write_string = mem_cgroup_write,
-		.read_u64 = mem_cgroup_read,
+		.read = mem_cgroup_read,
 	},
 	{
 		.name = "failcnt",
 		.private = MEMFILE_PRIVATE(_MEM, RES_FAILCNT),
 		.trigger = mem_cgroup_reset,
-		.read_u64 = mem_cgroup_read,
+		.read = mem_cgroup_read,
 	},
 	{
 		.name = "stat",
@@ -4665,14 +4681,11 @@ static struct cftype mem_cgroup_files[] = {
 		.mode = S_IRUGO,
 	},
 #endif
-};
-
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
-static struct cftype memsw_cgroup_files[] = {
 	{
 		.name = "memsw.usage_in_bytes",
 		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_USAGE),
-		.read_u64 = mem_cgroup_read,
+		.read = mem_cgroup_read,
 		.register_event = mem_cgroup_usage_register_event,
 		.unregister_event = mem_cgroup_usage_unregister_event,
 	},
@@ -4680,35 +4693,22 @@ static struct cftype memsw_cgroup_files[] = {
 		.name = "memsw.max_usage_in_bytes",
 		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_MAX_USAGE),
 		.trigger = mem_cgroup_reset,
-		.read_u64 = mem_cgroup_read,
+		.read = mem_cgroup_read,
 	},
 	{
 		.name = "memsw.limit_in_bytes",
 		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_LIMIT),
 		.write_string = mem_cgroup_write,
-		.read_u64 = mem_cgroup_read,
+		.read = mem_cgroup_read,
 	},
 	{
 		.name = "memsw.failcnt",
 		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_FAILCNT),
 		.trigger = mem_cgroup_reset,
-		.read_u64 = mem_cgroup_read,
+		.read = mem_cgroup_read,
 	},
-};
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
 #endif
+};
 
 static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 {
@@ -4969,9 +4969,6 @@ static int mem_cgroup_populate(struct cgroup_subsys *ss,
 				ARRAY_SIZE(mem_cgroup_files));
 
 	if (!ret)
-		ret = register_memsw_files(cont, ss);
-
-	if (!ret)
 		ret = register_kmem_files(cont, ss);
 
 	return ret;
-- 
1.7.7.3
