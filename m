From: Eric B Munson <emunson-CVBTeua0HjReoWH0uzbU5w@public.gmane.org>
Subject: [PATCH] Documentation: cgroups: Add notes on removing PIDs from tasks
	and cgroups requiring setup
Date: Wed,  9 Mar 2011 16:09:29 -0500
Message-ID: <1299704969-4485-1-git-send-email-emunson__47539.9290015504$1299705264$gmane$org@mgebm.net>
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
Cc: Eric B Munson <emunson-CVBTeua0HjReoWH0uzbU5w@public.gmane.org>, rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

The cgroup documentation does not specify how a process can be removed from a
particular group.  This patch adds a note at the end of the simple example
about how this is done.  Also, some cgroups (like cpusets) require user input
before a new group can be used.  This is noted in the patch as well.

Signed-off-by: Eric B Munson <emunson-CVBTeua0HjReoWH0uzbU5w@public.gmane.org>
---
 Documentation/cgroups/cgroups.txt |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index 44b8b7a..6c975a1 100644
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
@@ -426,6 +430,9 @@ You can attach the current shell task by echoing 0:
 
 # echo 0 > tasks
 
+Note: To remove a task from a cgroup you must write its PID to the root
+tasks file.
+
 2.3 Mounting hierarchies by name
 --------------------------------
 
-- 
1.7.1
