From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 0/6][cr]: Checkpoint/restart file locks and leases
Date: Tue, 4 May 2010 22:30:16 -0700
Message-ID: <20100505053016.GA20483__7153.5358242274$1273037095$gmane$org@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


This patchset is an early draft of checkpoint/restart of file-locks/leases.

This patchset applies on top of the ckpt-v21-rc7 branch of the Checkpoint/
restart git tree (see http://ckpt.wiki.kernel.org for details).

To checkpoint/restart file-locks and leases we find each lock/lease held
by each fd of the process and save the information about the lock/lease
in the checkpoint-image. When restarting, each process reacquires the
locks it held at checkpoint. When all processes have acquired the locks
one-by-one, the entire process tree is allowed to execute. Any processes
blocked on a lock at the time of checkpoint, restart their system call
and end up blocking on the lock again after the restart.

Checkpoint/restart of file-leases, specially the leases that are being
revoked appear to be more tricky - Patch 6/6 has the details.

	[PATCH  1/6] Move file_lock macros into linux/fs.h
	[PATCH  2/6] Checkpoint file-locks
	[PATCH  3/6] Define flock_set()
	[PATCH  4/6] Restore file-locks
	[PATCH  5/6] Define do_setlease()
	[PATCH  6/6] Checkpoint/restart file leases

This patchset has been gently tested with a few C/R testcases and needs
more testing. Pls let me know your comments or if there are semantics that
might change. Patch 6 identifies a couple of semantics for leases and
suggests a way to preserve them. But maybe there is a cleaner/easier way
to do so.

Note:
	For consistency with current uses of for_each_lock(), this patchset
	uses lock_kernel(), but not sure yet if it is required. 

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
