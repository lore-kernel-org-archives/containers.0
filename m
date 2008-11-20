From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 6/7] support checking of subsystem dependencies
Date: Thu, 20 Nov 2008 19:14:57 +0800
Message-ID: <492546B1.70708__17813.358983449$1227180018$gmane$org@cn.fujitsu.com>
References: <4925445C.10302@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4925445C.10302-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

This allows one subsystem to require that it only be mounted when some
other subsystems are also present in or not in the proposed hierarchy.

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 Documentation/cgroups/cgroups.txt |    5 +++++
 include/linux/cgroup.h            |    2 ++
 kernel/cgroup.c                   |   21 ++++++++++++++++++++-
 3 files changed, 27 insertions(+), 1 deletions(-)

diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index d9014aa..df648c6 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -534,6 +534,11 @@ and root cgroup. Currently this will only involve movement between
 the default hierarchy (which never has sub-cgroups) and a hierarchy
 that is being created/destroyed (and hence has no sub-cgroups).
 
+int subsys_depend(struct cgroup_subsys *ss, unsigned long subsys_bits)
+Called when a cgroup subsystem wants to check if some other subsystems
+are also present in the proposed hierarchy. If this method returns error,
+the mount of the cgroup filesystem will fail.
+
 4. Questions
 ============
 
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 1164963..1899449 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -329,6 +329,8 @@ struct cgroup_subsys {
 			struct cgroup *cgrp);
 	void (*post_clone)(struct cgroup_subsys *ss, struct cgroup *cgrp);
 	void (*bind)(struct cgroup_subsys *ss, struct cgroup *root);
+	int (*subsys_depend)(struct cgroup_subsys *ss,
+			     unsigned long subsys_bits);
 	/*
 	 * This routine is called with the task_lock of mm->owner held
 	 */
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index a512a75..8a07023 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -761,6 +761,25 @@ static int cgroup_show_options(struct seq_file *seq, struct vfsmount *vfs)
 	return 0;
 }
 
+static int check_subsys_dependency(unsigned long subsys_bits)
+{
+	int i;
+	int ret;
+	struct cgroup_subsys *ss;
+	
+	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
+		ss = subsys[i];
+		
+		if (test_bit(i, &subsys_bits) && ss->subsys_depend) {
+			ret = ss->subsys_depend(ss, subsys_bits);
+			if (ret)
+				return ret;
+		}
+	}
+	
+	return 0;
+}
+
 struct cgroup_sb_opts {
 	unsigned long subsys_bits;
 	unsigned long flags;
@@ -821,7 +840,7 @@ static int parse_cgroupfs_options(char *data,
 	if (!opts->subsys_bits)
 		return -EINVAL;
 
-	return 0;
+	return check_subsys_dependency(opts->subsys_bits);
 }
 
 static int cgroup_remount(struct super_block *sb, int *flags, char *data)
-- 1.5.4.rc3
