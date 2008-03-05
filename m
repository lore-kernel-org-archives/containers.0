From: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 2/2] CGroups _s64 files: Use read_s64/write_s64 in CFS cgroup
	for rt_runtime file
Date: Wed, 05 Mar 2008 02:20:27 -0800
Message-ID: <20080305102513.610692000@menage.corp.google.com>
References: <20080305102025.677459000@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=cfs_use_readwrite_s64.patch
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

This removes some filesystem boilerplate from the CFS cgroup subsystem.

Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

---
 kernel/sched.c |   52 +++++++++-------------------------------------------
 1 file changed, 9 insertions(+), 43 deletions(-)

Index: read_s64-2.6.25-rc3-mm1/kernel/sched.c
===================================================================
--- read_s64-2.6.25-rc3-mm1.orig/kernel/sched.c
+++ read_s64-2.6.25-rc3-mm1/kernel/sched.c
@@ -8081,48 +8081,14 @@ static u64 cpu_shares_read_u64(struct cg
 
 #ifdef CONFIG_RT_GROUP_SCHED
 static int cpu_rt_runtime_write(struct cgroup *cgrp, struct cftype *cft,
-				struct file *file,
-				const char __user *userbuf,
-				size_t nbytes, loff_t *unused_ppos)
-{
-	char buffer[64];
-	int retval = 0;
-	s64 val;
-	char *end;
-
-	if (!nbytes)
-		return -EINVAL;
-	if (nbytes >= sizeof(buffer))
-		return -E2BIG;
-	if (copy_from_user(buffer, userbuf, nbytes))
-		return -EFAULT;
-
-	buffer[nbytes] = 0;     /* nul-terminate */
-
-	/* strip newline if necessary */
-	if (nbytes && (buffer[nbytes-1] == '\n'))
-		buffer[nbytes-1] = 0;
-	val = simple_strtoll(buffer, &end, 0);
-	if (*end)
-		return -EINVAL;
-
-	/* Pass to subsystem */
-	retval = sched_group_set_rt_runtime(cgroup_tg(cgrp), val);
-	if (!retval)
-		retval = nbytes;
-	return retval;
-}
-
-static ssize_t cpu_rt_runtime_read(struct cgroup *cgrp, struct cftype *cft,
-				   struct file *file,
-				   char __user *buf, size_t nbytes,
-				   loff_t *ppos)
-{
-	char tmp[64];
-	long val = sched_group_rt_runtime(cgroup_tg(cgrp));
-	int len = sprintf(tmp, "%ld\n", val);
+				s64 val)
+{
+	return sched_group_set_rt_runtime(cgroup_tg(cgrp), val);
+}
 
-	return simple_read_from_buffer(buf, nbytes, ppos, tmp, len);
+static s64 cpu_rt_runtime_read(struct cgroup *cgrp, struct cftype *cft)
+{
+	return sched_group_rt_runtime(cgroup_tg(cgrp));
 }
 #endif
 
@@ -8137,8 +8103,8 @@ static struct cftype cpu_files[] = {
 #ifdef CONFIG_RT_GROUP_SCHED
 	{
 		.name = "rt_runtime_us",
-		.read = cpu_rt_runtime_read,
-		.write = cpu_rt_runtime_write,
+		.read_s64 = cpu_rt_runtime_read,
+		.write_s64 = cpu_rt_runtime_write,
 	},
 #endif
 };

--
