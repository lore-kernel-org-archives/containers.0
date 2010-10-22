From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 7/7] cgroups: Update documentation for bindable subsystems
Date: Fri, 22 Oct 2010 16:12:25 +0800
Message-ID: <4CC14769.2000406__22379.03341088$1287735453$gmane$org@cn.fujitsu.com>
References: <4CC146A4.9090505@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4CC146A4.9090505-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "akpm >> Andrew Morton" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Stephane Eranian <eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Provide a usage example, and update the bind() callback API.

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 Documentation/cgroups/cgroups.txt |   26 +++++++++++++++++---------
 1 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index 190018b..5b5382a 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -363,17 +363,23 @@ Note this will add ns to the hierarchy but won't remove memory or
 cpuset, because the new options are appended to the old ones:
 # mount -o remount,ns /dev/cgroup
 
+For some subsystems you can bind them to a mounted hierarchy or
+remove them from it, even if there're sub-cgroups in it:
+# mount -t cgroup -o freezer hier1 /dev/cgroup
+# echo $$ > /dev/cgroup/my_cgroup
+# mount -o freezer,cpuset hier1 /dev/cgroup
+(failed)
+# mount -o freezer,cpuacct hier1 /dev/cgroup
+# mount -o cpuacct hier1 /dev/cgroup
+
+Note cpuacct should be sit in the default hierarchy before remount.
+
 To Specify a hierarchy's release_agent:
 # mount -t cgroup -o cpuset,release_agent="/sbin/cpuset_release_agent" \
   xxx /dev/cgroup
 
 Note that specifying 'release_agent' more than once will return failure.
 
-Note that changing the set of subsystems is currently only supported
-when the hierarchy consists of a single (root) cgroup. Supporting
-the ability to arbitrarily bind/unbind subsystems from an existing
-cgroup hierarchy is intended to be implemented in the future.
-
 Then under /dev/cgroup you can find a tree that corresponds to the
 tree of the cgroups in the system. For instance, /dev/cgroup
 is the cgroup that holds the whole system.
@@ -623,13 +629,15 @@ initialization which might be required before a task could attach.  For
 example in cpusets, no task may attach before 'cpus' and 'mems' are set
 up.
 
-void bind(struct cgroup_subsys *ss, struct cgroup *root)
+void bind(struct cgroup_subsys *ss, struct cgroup *cgrp, bool unbind)
 (cgroup_mutex and ss->hierarchy_mutex held by caller)
 
 Called when a cgroup subsystem is rebound to a different hierarchy
-and root cgroup. Currently this will only involve movement between
-the default hierarchy (which never has sub-cgroups) and a hierarchy
-that is being created/destroyed (and hence has no sub-cgroups).
+and root cgroup. For some subsystems this will only involve movement
+between the default hierarchy (which never has sub-cgroups) and a
+hierarchy that is being created/destroyed (and hence has no sub-cgroups).
+For some other subsystems this can involve movement between the default
+hierarchy and a mounted hierarchy which may have sub-cgroups in it.
 
 4. Questions
 ============
-- 
1.7.0.1
