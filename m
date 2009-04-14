From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 4/9] support checking of cgroup subsystem dependencies
Date: Tue, 14 Apr 2009 22:21:15 +0200
Message-ID: <1239740480-28125-5-git-send-email-righi.andrea__1254.7051570893$1239740738$gmane$org@gmail.com>
References: <1239740480-28125-1-git-send-email-righi.andrea@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1239740480-28125-1-git-send-email-righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

This allows one subsystem to require to be mounted only when some other
subsystems are also present in or not in the proposed hierarchy.

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 Documentation/cgroups/cgroups.txt |    5 +++++
 include/linux/cgroup.h            |    2 ++
 kernel/cgroup.c                   |   19 ++++++++++++++++++-
 3 files changed, 25 insertions(+), 1 deletions(-)

diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index 6eb1a97..6938025 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -552,6 +552,11 @@ and root cgroup. Currently this will only involve movement between
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
index 665fa70..37ace23 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -385,6 +385,8 @@ struct cgroup_subsys {
 			struct cgroup *cgrp);
 	void (*post_clone)(struct cgroup_subsys *ss, struct cgroup *cgrp);
 	void (*bind)(struct cgroup_subsys *ss, struct cgroup *root);
+	int (*subsys_depend)(struct cgroup_subsys *ss,
+			     unsigned long subsys_bits);
 
 	int subsys_id;
 	int active;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 382109b..fad3f08 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -830,6 +830,23 @@ static int cgroup_show_options(struct seq_file *seq, struct vfsmount *vfs)
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
+		if (test_bit(i, &subsys_bits) && ss->subsys_depend) {
+			ret = ss->subsys_depend(ss, subsys_bits);
+			if (ret)
+				return ret;
+		}
+	}
+	return 0;
+}
+
 struct cgroup_sb_opts {
 	unsigned long subsys_bits;
 	unsigned long flags;
@@ -890,7 +907,7 @@ static int parse_cgroupfs_options(char *data,
 	if (!opts->subsys_bits)
 		return -EINVAL;
 
-	return 0;
+	return check_subsys_dependency(opts->subsys_bits);
 }
 
 static int cgroup_remount(struct super_block *sb, int *flags, char *data)
-- 
1.5.6.3
