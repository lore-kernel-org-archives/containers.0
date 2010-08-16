From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 17/17][cr][v4]: Document design of C/R of file-locks and leases
Date: Mon, 16 Aug 2010 12:43:21 -0700
Message-ID: <1281987801-1293-18-git-send-email-sukadev__22497.5657569759$1281988258$gmane$org@linux.vnet.ibm.com>
References: <1281987801-1293-1-git-send-email-sukadev@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1281987801-1293-1-git-send-email-sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
Cc: Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>, John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Steven Whitehouse <swhiteho-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Summarize the file-system consistency requirements and the design of
the C/R of file-locks and leases.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 Documentation/checkpoint/file-locks |  126 +++++++++++++++++++++++++++++++++++
 1 files changed, 126 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/checkpoint/file-locks

diff --git a/Documentation/checkpoint/file-locks b/Documentation/checkpoint/file-locks
new file mode 100644
index 0000000..e562990
--- /dev/null
+++ b/Documentation/checkpoint/file-locks
@@ -0,0 +1,126 @@
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
+
+Checkpoint/restart of file leases
+==================================
+
+C/R of file-leases depends on whether the lease is currently being broken
+(i.e F_INPROGRESS is set).  If the file-lease is not being broken, checkpoint/
+restart of file-lease is identical to checkpoint of file-locks (i.e save
+the type of the lease for the file in the checkpoint image. When restarting,
+restore the lease by calling do_setlease().
+
+C/R of file-lease gets complicated, if a process is checkpointed when its lease
+was being revoked. i.e if P1 has a F_WRLCK lease on file F1 and P2 opens F1 for
+write, P2's open is blocked for lease_break_time (45 secs).  P1's lease is
+revoked (i.e set to F_UNLCK) and P1 is notified via a SIGIO to flush any dirty
+data.
+
+Basic design:
+
+To address "in-progress" leases, we checkpoint additional information about
+the lease:
+
+        - the previous lease type (file_lock->fl_type_prev)
+        - the time remaining in the lease (->fl_rem_lease), and
+        - whether we already notified the lease-holder about the lease-break
+	  (->fl_break_notified)
+
+To restore an "in-progrss" lease that, we temporarily re-assign the original
+lease type (that we saved in ->fl_type_prev) to the lease-holder. i.e. in the
+above example, give P1 a F_WRLCK lease). When the lease-breaker (P2) is
+restarted after checkpoint, its open() system fails with -ERESTARTSYS and it
+will retry the open(). This open() will re-initiate the lease-break protocol
+(i.e P2 will go back to waiting and P1 will be notified).
+
+Some observations about this approach:
+
+1. We must use ->fl_type_prev because, when the lease is being broken,
+  ->fl_type is already set to F_UNLCK and would not result in a
+  lease-break protocol when P2 is restarted.
+
+2. When the lease-break is initiated and we signal the lease-holder, we set
+   the ->fl_break_notified field. When restarting the lease and repeating
+   the lease-break protocol, we check the ->fl_break_notified field and
+   signal the lease-holder only if did not signal before the checkpoint.
+
+3. If P1 was was checkpointed 40 seconds into the lease_break_time,(i.e.
+   it had 5 seconds remaining in the lease), we would ideally want to ensure
+   that after restart, P1 gets 5 or at least 5 seconds to finish cleaning up
+   the lease.
+
+   But the actual time that P1 gets after the application is restarted depends
+   on many factors (number of processes in the application process tree, load
+   on system at the time of restart etc).
+
+   Jamie Lokier had suggested that we favor the lease-holder (P1) during
+   restart, even if it meant giving the lease-holder the entire lease-break
+   interval (45 seconds) again after the restart. Oren Laadan suggested
+   that rather than make that a kernel policy, we let the user choose a
+   policy based on the application's behavior.
+
+   The current design computes and checkpoints the remaining-lease and
+   uses this value to restore the lease. i.e the kernel simply uses the
+   "remaining-lease" value stored in the checkpoint image. Userspace tools
+   can be developed to alter the remaining-lease value in the checkpoint
+   image to either favor the lease-holder or the lease-breaker or to add
+   a fixed delta.
+
+4. The current design of C/R of file-leases assumes that both lease-holder
+   and lease-breaker are restarted. If only the lease-holder is restarted,
+   the kernel will re-assign the original lease (F_WRLCK in the example) to
+   lease-holder. If no lease-breaker comes along, the kernel will leave the
+   lease assigned to lease-holder.
+
+   This should not be a problem because, as far as the lease-holder is
+   concerned the lease was revoked and it will/should reacquire the lease.
-- 
1.6.0.4
