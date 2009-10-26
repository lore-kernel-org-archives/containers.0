From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/2] [RFC] Add file f_flags to cgroup write_string ops
Date: Mon, 26 Oct 2009 08:15:29 -0700
Message-ID: <1256570129-13107-1-git-send-email-matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

cgroup subsystems may find the O_APPEND and O_NONBLOCK flags useful
in determining the way they handle writes. For now only pass these
flags through the write_string op.

A subsequent patch will make use of the O_NONBLOCK flag in the
cgroup freezer write_string op.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

(Cc'ing mem controller maintainers in case they find this useful..)
Cc: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
---
 include/linux/cgroup.h   |    3 ++-
 kernel/cgroup.c          |    5 +++--
 kernel/cgroup_freezer.c  |    5 ++---
 kernel/cpuset.c          |    2 +-
 mm/memcontrol.c          |    2 +-
 security/device_cgroup.c |    2 +-
 6 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 90bba9e..627da35 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -315,8 +315,9 @@ struct cftype {
 	 * buffer of maximum length determined by max_write_len.
 	 * Returns 0 or -ve error code.
 	 */
+#define CFTYPE_F_FLAGS (O_APPEND|O_NONBLOCK)
 	int (*write_string)(struct cgroup *cgrp, struct cftype *cft,
-			    const char *buffer);
+			    unsigned int f_flags, const char *buffer);
 	/*
 	 * trigger() callback can be used to get some kick from the
 	 * userspace, when the actual string written is not important
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index b6eadfe..af07d05 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1449,7 +1449,7 @@ bool cgroup_lock_live_group(struct cgroup *cgrp)
 }
 
 static int cgroup_release_agent_write(struct cgroup *cgrp, struct cftype *cft,
-				      const char *buffer)
+				      unsigned int f_flags, const char *buffer)
 {
 	BUILD_BUG_ON(sizeof(cgrp->root->release_agent_path) < PATH_MAX);
 	if (!cgroup_lock_live_group(cgrp))
@@ -1534,7 +1534,8 @@ static ssize_t cgroup_write_string(struct cgroup *cgrp, struct cftype *cft,
 
 	buffer[nbytes] = 0;     /* nul-terminate */
 	strstrip(buffer);
-	retval = cft->write_string(cgrp, cft, buffer);
+	retval = cft->write_string(cgrp, cft, file->f_flags & CFTYPE_F_FLAGS,
+				   buffer);
 	if (!retval)
 		retval = nbytes;
 out:
diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index 7925850..c97680f 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -343,9 +343,8 @@ out:
 	return retval;
 }
 
-static int freezer_write(struct cgroup *cgroup,
-			 struct cftype *cft,
-			 const char *buffer)
+static int freezer_write(struct cgroup *cgroup, struct cftype *cft,
+			 unsigned int f_flags, const char *buffer)
 {
 	int retval;
 	enum freezer_state goal_state;
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 7e75a41..de7f397 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1470,7 +1470,7 @@ static int cpuset_write_s64(struct cgroup *cgrp, struct cftype *cft, s64 val)
  * Common handling for a write to a "cpus" or "mems" file.
  */
 static int cpuset_write_resmask(struct cgroup *cgrp, struct cftype *cft,
-				const char *buf)
+				unsigned int f_flags, const char *buf)
 {
 	int retval = 0;
 	struct cpuset *cs = cgroup_cs(cgrp);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index fd4529d..fd9c737 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2072,7 +2072,7 @@ static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
  * RES_LIMIT.
  */
 static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
-			    const char *buffer)
+			    unsigned int f_flags, const char *buffer)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
 	int type, name;
diff --git a/security/device_cgroup.c b/security/device_cgroup.c
index b8186ba..65d32ce 100644
--- a/security/device_cgroup.c
+++ b/security/device_cgroup.c
@@ -428,7 +428,7 @@ handle:
 }
 
 static int devcgroup_access_write(struct cgroup *cgrp, struct cftype *cft,
-				  const char *buffer)
+				  unsigned int f_flags, const char *buffer)
 {
 	int retval;
 
-- 
1.5.6.3
