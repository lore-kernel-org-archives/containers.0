From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 5/5][v5][cr]: Document design of C/R of file-locks
Date: Thu, 28 Oct 2010 23:16:41 -0700
Message-ID: <1288333001-28838-6-git-send-email-sukadev__4949.14184459976$1288332609$gmane$org@linux.vnet.ibm.com>
References: <1288333001-28838-1-git-send-email-sukadev@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1288333001-28838-1-git-send-email-sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Steven Whitehouse <swhiteho-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Summarize the file-system consistency requirements and the design of
the C/R of file-locks and leases.

Changelog[v5]:
	- This version of the patchset only checkpoints/restores file-locks.
	  C/R of file-owner information requires additional work with struct
	  pids and will be addressed in a follow-on patch. C/R of file-leases,
	  depends on C/R of file-owner info Removed the design information of
	  C/R of file leases from the Documenation for now.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 Documentation/checkpoint/file-locks |   52 +++++++++++++++++++++++++++++++++++
 1 files changed, 52 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/checkpoint/file-locks

diff --git a/Documentation/checkpoint/file-locks b/Documentation/checkpoint/file-locks
new file mode 100644
index 0000000..ccffdef
--- /dev/null
+++ b/Documentation/checkpoint/file-locks
@@ -0,0 +1,52 @@
+
+Filesystem consistency across C/R.
+==================================
+
+To checkpoint/restart a process that is using any filesystem resource, the
+kernel assumes that the file system state at the time of restart is consistent
+with its state at the time of checkpoint. In general, this consistency can be
+achieved by:
+
+	a. running the application inside a container (to ensure no process
+	   outside the container modifies the filesystem/IPC or other states)
+
+	b. freezing the application before checkpoint
+	c. taking a snapshot of the file system while application is frozen
+	d. checkpointing the application while it is frozen
+
+	e. restoring the file system state to its snapshot
+	f. restart the application inside a container
+
+i.e the kernel assumes that file system state is consistent but it does/can
+NOT verify that it is. The administrator must provide this consistency taking
+into account the file system type including whether it is local or remote,
+and the tools available in the file system (snapshot tools in btrfs or rsync
+etc).
+
+For distributed applications operating on distributed filesystems, it is
+expected that an external mechanism will coordinate the freeze/checkpoint/
+snapshot/restart across the nodes. IOW, the current semantics in the kernel
+provide for C/R on a single node.
+
+Checkpoint/restart of file-locks.
+================================
+
+To checkpoint file-locks in an application, we start with each file-descriptor
+and count the number of file-locks on that file-descriptor. We save this count
+in the checkpoint image, and then information about each file-lock on the
+file-descriptor.
+
+When restarting the application from the checkpoint, we read the file-lock
+count for each file-descriptor and then read the information about each
+file-lock. For each file-lock, we call flock_set() to set a new file-lock.
+
+No special handling is necessary for a process P2 in the checkpointed container
+that is blocked on a file-lock, L1 held by another process P1. Processes in the
+restarted container begin execution only after all processes have restored.
+If the blocked process P2 is restored first, it will prepare to return an
+-ERESTARTSYS from the fcntl() system call, but wait for P1 to be restored.
+When P1 is restored, it will re-acquire the file-lock L1 before P1 and P2 begin
+actual execution.
+
+This ensures that even if P2 is scheduled to run before P1, P2 will go
+back to waiting for the file-lock L1.
-- 
1.6.0.4
