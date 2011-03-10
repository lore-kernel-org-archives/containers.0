From: Eric B Munson <emunson-CVBTeua0HjReoWH0uzbU5w@public.gmane.org>
Subject: [PATCH V2] Documentation: cgroups: Add notes on removing PIDs from
	tasks and cgroups requiring setup
Date: Thu, 10 Mar 2011 12:07:42 -0500
Message-ID: <1299776862-6931-1-git-send-email-emunson__4406.49628076262$1299776908$gmane$org@mgebm.net>
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
To: linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org, Eric B Munson <emunson-CVBTeua0HjReoWH0uzbU5w@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

The cgroup documentation does not specify how a process can be removed from a
particular group.  This patch adds a note at the end of the simple example
about how this is done.  Also, some cgroups (like cpusets) require user input
before a new group can be used.  This is noted in the patch as well.

Signed-off-by: Eric B Munson <emunson-CVBTeua0HjReoWH0uzbU5w@public.gmane.org>
---
Changes from V1:
 Rework the note about removing a process from a cgroup
 Add note about ns cgroup causing failure when moving processes between groups

 Documentation/cgroups/cgroups.txt |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index 44b8b7a..cbdfb7d 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -349,6 +349,10 @@ To mount a cgroup hierarchy with all available subsystems, type:
 The "xxx" is not interpreted by the cgroup code, but will appear in
 /proc/mounts so may be any useful identifying string that you like.
 
+Note: Some subsystems do not work without some user input first.  For instance,
+if cpusets are enabled the user will have to populate the cpus and mems files
+for each new cgroup created before that group can be used.
+
 To mount a cgroup hierarchy with just the cpuset and memory
 subsystems, type:
 # mount -t cgroup -o cpuset,memory hier1 /dev/cgroup
@@ -426,6 +430,14 @@ You can attach the current shell task by echoing 0:
 
 # echo 0 > tasks
 
+Note: Since every task is always a member of exactly one cgroup in each
+mounted hierarchy, to remove a task from its current cgroup you must
+move it into a new cgroup (possibly the root cgroup) by writing to the
+new cgroup's tasks file.
+
+Note: If the ns cgroup is active, moving a process to another cgroup can
+fail.
+
 2.3 Mounting hierarchies by name
 --------------------------------
 
-- 
1.7.1
