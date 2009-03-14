From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH] Document signal-semantics changes of container-init
Date: Sat, 14 Mar 2009 16:23:53 -0700
Message-ID: <20090314232353.GA29682@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: mtk.manpages-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org
Cc: linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org


Hi Michael,

The kernel changes corresponding to his update were added to -mm
on 2009-02-19. Please review and let me know if other man pages
should be updated to document these semantics.
---

From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Sat, 14 Mar 2009 16:08:42 -0700
Subject: [PATCH] Document signal-semantics changes of container-init

Container-inits have some special signal semantics depending on
whether the signal was sent from the same container or a parent
container. These changes were implemented by the patchset:

	http://lkml.org/lkml/2009/2/18/493


Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 man2/clone.2 |    7 ++++++-
 man2/kill.2  |   27 +++++++++++++++++++++++++++
 2 files changed, 33 insertions(+), 1 deletions(-)

diff --git a/man2/clone.2 b/man2/clone.2
index 5d07f7c..975b321 100644
--- a/man2/clone.2
+++ b/man2/clone.2
@@ -396,7 +396,8 @@ will produce processes with PIDs that are unique within the namespace.
 The first process created in a new namespace
 (i.e., the process created using the
 .BR CLONE_NEWPID
-flag) has the PID 1, and is the "init" process for the namespace.
+flag) has the PID 1, and is the "init" process for the namespace,
+also referred to as "container-init" process.
 Children that are orphaned within the namespace will be reparented
 to this process rather than
 .BR init (8).
@@ -405,6 +406,10 @@ Unlike the traditional
 process, the "init" process of a PID namespace can terminate,
 and if it does, all of the processes in the namespace are terminated.
 
+See NOTES section of
+.B kill(2)
+for special signal semantics of the "container-init" process.
+
 PID namespaces form a hierarchy.
 When a PID new namespace is created,
 the processes in that namespace are visible
diff --git a/man2/kill.2 b/man2/kill.2
index 5cfa9a4..d0ba8bb 100644
--- a/man2/kill.2
+++ b/man2/kill.2
@@ -128,6 +128,33 @@ has explicitly installed signal handlers.
 This is done to assure the
 system is not brought down accidentally.
 .LP
+A
+.I container-init
+process (i.e a process created by a call to
+.I clone() 
+with
+.I CLONE_NEWPID
+flag) is also similarly immune to 'unhandled' signals
+sent by a descendant process.
+But the
+.I container-init
+recieves the unhandled signal and may terminate, if the signal is sent
+by a process in the parent namespace of the
+.I container-init.
+i.e the 
+.I container-init
+appears like an 
+.I init
+process to its descendant process and they cannot accidentally terminate
+the
+.I container-init
+and thereby, the entire pid-namespace.
+But
+.I container-init
+appears like a normal process to another process in its parent-pid-namespace,
+allowing an administrator to terminate any run-away
+.I container-inits.
+.LP
 POSIX.1-2001 requires that \fIkill(\-1,sig)\fP send \fIsig\fP
 to all processes that the calling process may send signals to,
 except possibly for some implementation-defined system processes.
-- 
1.5.2.5

--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
