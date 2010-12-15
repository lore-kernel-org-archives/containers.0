From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH v2 6/6] cgroups: Update documentation for bindable subsystems
Date: Wed, 15 Dec 2010 17:36:38 +0800
Message-ID: <4D088C26.5090205__23500.479051336$1292405827$gmane$org@cn.fujitsu.com>
References: <4D088BB5.30903@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4D088BB5.30903-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Stephane Eranian <eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Provide a usage example, update the bind() callback API, etc.

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 Documentation/cgroups/cgroups.txt |   37 +++++++++++++++++++++++++++++--------
 1 files changed, 29 insertions(+), 8 deletions(-)

diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index 190018b..4e772cc 100644
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
@@ -523,6 +529,15 @@ module initcall a call to cgroup_load_subsys(), and in its exitcall a
 call to cgroup_unload_subsys(). It should also set its_subsys.module =
 THIS_MODULE in its .c file.
 
+If a subsystem has bindable flag set, normally it has to be able to
+support side-effect free movement of a task into any just-created
+cgroups. i.e. it's probably not suitable for any subsystem where
+can_attach() might return false for the newly-created cgroup, or
+attach() might have side-effects for those same cases.
+
+If a subsystem has unbindable flag set, normally it has to be able to
+support side-effect free movement of a task into the roog cgroup.
+
 Each subsystem may export the following methods. The only mandatory
 methods are create/destroy. Any others that are null are presumed to
 be successful no-ops.
@@ -627,9 +642,15 @@ void bind(struct cgroup_subsys *ss, struct cgroup *root)
 (cgroup_mutex and ss->hierarchy_mutex held by caller)
 
 Called when a cgroup subsystem is rebound to a different hierarchy
-and root cgroup. Currently this will only involve movement between
-the default hierarchy (which never has sub-cgroups) and a hierarchy
-that is being created/destroyed (and hence has no sub-cgroups).
+and root cgroup.
+
+For non-bindable subsystems, this will only involve movement
+between the default hierarchy (which never has sub-cgroups) and a
+hierarchy that is being created/destroyed (and hence has no sub-cgroups).
+
+For binadable subsystems, this may also involve movement between the
+default hierarchy and a mounted hierarchy that's populated with
+sub-cgroups.
 
 4. Questions
 ============
-- 
1.6.3
