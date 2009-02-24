From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] cgroups: more documentation for remount and release_agent
Date: Tue, 24 Feb 2009 10:33:53 +0800
Message-ID: <49A35C91.6000904__3915.8534179025$1235443003$gmane$org@cn.fujitsu.com>
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
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

This won't remove cpuacct from the mounted hierachy:
 # mount -t cgroup -o cpu,cpuacct xxx /mnt
 # mount -o remount,cpu /mnt

Because for this usage mount(8) will append the new options to the original
options.

And this will get you right:
 # mount [-t cgroup] -o remount,cpu xxx /mnt

Also document how to specify or change release_agent.

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 Documentation/cgroups/cgroups.txt |   20 ++++++++++++++++++--
 1 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index 93feb84..df295c6 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -333,12 +333,23 @@ The "xxx" is not interpreted by the cgroup code, but will appear in
 
 To mount a cgroup hierarchy with just the cpuset and numtasks
 subsystems, type:
-# mount -t cgroup -o cpuset,numtasks hier1 /dev/cgroup
+# mount -t cgroup -o cpuset,memory hier1 /dev/cgroup
 
 To change the set of subsystems bound to a mounted hierarchy, just
 remount with different options:
+# mount -o remount,cpuset,ns hier1 /dev/cgroup
 
-# mount -o remount,cpuset,ns  /dev/cgroup
+Now memory is removed from the hierarchy and ns is added.
+
+Note this will add ns to the hierarchy but won't remove memory or
+cpuset, because the new options are appended to the old ones:
+# mount -o remount,ns /dev/cgroup
+
+To Specify a hierarchy's release_agent:
+# mount -t cgroup -o cpuset,release_agent="/sbin/cpuset_release_agent" \
+  xxx /dev/cgroup
+
+Note that specifying 'release_agent' more than once will return failure.
 
 Note that changing the set of subsystems is currently only supported
 when the hierarchy consists of a single (root) cgroup. Supporting
@@ -349,6 +360,11 @@ Then under /dev/cgroup you can find a tree that corresponds to the
 tree of the cgroups in the system. For instance, /dev/cgroup
 is the cgroup that holds the whole system.
 
+If you want to change the value of release_agent:
+# echo "/sbin/new_release_agent" > /dev/cgroup/release_agent
+
+It can also be changed via remount.
+
 If you want to create a new cgroup under /dev/cgroup:
 # cd /dev/cgroup
 # mkdir my_cgroup
-- 
1.5.4.rc3
