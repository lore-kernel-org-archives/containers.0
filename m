From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH RFC linux-cr] add rpid to ckpt_pids struct
Date: Tue, 9 Mar 2010 15:04:51 -0600
Message-ID: <20100309210450.GA5789@us.ibm.com>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

When we restart an application, we won't try to restore the original
pid in the parent pid_ns, so we don't checkpoint that pid.

However, if we are going to dump mount info from userspace using
/proc/pid/mountinfo, then it will be easiest for a restart wrapper
to use the pids from the checkpoint image.  So add rpid to the
pids info we dump.

The rpid is taken as the vpid in the checkpointer's pidnamespace.
The container may not have valid pids in the checkpointer's
pid namespace, in which case the rpid will be 0, and the checkpoint
wrapper will not be able to access the mountinfo.

Note that eventually, in order to restore nested pid namespaces,
we will need to change our approach again, so as to print out
the pid in every ancestor pid_ns.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/checkpoint.c        |    6 ++++--
 include/linux/checkpoint_hdr.h |    1 +
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index b3c1c4f..c9b5966 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -329,13 +329,15 @@ static int checkpoint_pids(struct ckpt_ctx *ctx)
 		for (n = 0; n < min(nr_tasks, CKPT_HDR_PIDS_CHUNK); n++) {
 			task = tasks_arr[pos];
 
+			h[n].rpid = task_pid_vnr(task);
 			h[n].vpid = task_pid_nr_ns(task, ns);
 			h[n].vtgid = task_tgid_nr_ns(task, ns);
 			h[n].vpgid = task_pgrp_nr_ns(task, ns);
 			h[n].vsid = task_session_nr_ns(task, ns);
 			h[n].vppid = task_tgid_nr_ns(task->real_parent, ns);
-			ckpt_debug("task[%d]: vpid %d vtgid %d parent %d\n",
-				   pos, h[n].vpid, h[n].vtgid, h[n].vppid);
+			ckpt_debug("task[%d]: rpid %d vpid %d vtgid %d "
+				"parent %d\n", pos, h[n].rpid, h[n].vpid,
+				h[n].vtgid, h[n].vppid);
 			pos++;
 		}
 		rcu_read_unlock();
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 41412d1..d3fff0b 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -327,6 +327,7 @@ struct ckpt_hdr_tree {
 } __attribute__((aligned(8)));
 
 struct ckpt_pids {
+	__s32 rpid; /* pid in checkpointer's pidns */
 	__s32 vpid;
 	__s32 vppid;
 	__s32 vtgid;
-- 
1.6.0.6
