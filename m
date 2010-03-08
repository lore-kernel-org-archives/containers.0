From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: user-cr: Extra unshare() calls ?
Date: Mon, 8 Mar 2010 12:13:39 -0800
Message-ID: <20100308201338.GA16446@us.ibm.com>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


Came across this while testing LXC.


1. Does ckpt_remount_proc() need to unshare() ? Or can we have the
   clone() that calls __ckpt_coordinator() clone with CLONE_NEWNS|CLONE_FS
   instead ?

   The problem with the unshare() in ckpt_remount_proc() is that it
   creates an extra level in cgroup hierarchy (see below) after restart.
   So applications expecting the cgroup hierarchy before chckpoint will
   be surprised.

2. When --mount-pty (or --mntns) is specified, do we need to unshare() 
   in the parent process ? Considering only the full-container restart
   for now (ignore self-restart and subtree restart), can we just
   specify (CLONE_NEWNS|CLONE_FS) at the time of creating the first
   restarted process ?

Here is an example (using LXC) that shows the problems I am running into
Attached is a quick hack to point out the unshare() calls I am referring
to.
   
If I create a simple container with LXC

	$ lxc-execute --name foo --rcfile lxc-macvlan.conf -- /bin/sleep 1000

It creates the following three processes:

	PID   PPID  CMD

        3350  3239  lxc-execute --name foo -- /bin/sleep 1000
        3353  3350  /usr/local/libexec/lxc-init -- /bin/sleep 1000
        3357  3353  /bin/sleep 1000

A new cgroup is created named 'foo' (which is basically a user-space
rename of the pid of the lxc-init). This cgroup is in the root cgroup
directory and has two tasks (lxc-init, sleep)

        $ cat /cgroup/foo/tasks
        3353
        3357

When I checkpoint and restart this container (using the equivalent of
--pidns --pids --mount-pty options to /bin/restart). I get three
processes:

        3434  3375  ./lxc_restart --name bar --statefile=/root/foo.ckpt
        3436  3434  /usr/local/libexec/lxc-init -- /bin/sleep 1000
        3437  3436  /bin/sleep 1000

But the directory in /cgroup referring to lxc-init is 3 levels deep:

	ls /cgroup/3434/3436/1
	cgroup.procs  freezer.state  notify_on_release  tasks

Here is the complete hierarchy created after the restart:

        $ ls -R /cgroup/3434
        /cgroup/3434:
        3436  cgroup.procs  freezer.state  notify_on_release  tasks

        /cgroup/3434/3436:
        1  cgroup.procs  freezer.state  notify_on_release  tasks

        /cgroup/3434/3436/1:
        cgroup.procs  freezer.state  notify_on_release  tasks

        $ cat /cgroup/3434/tasks
        3434

        $ cat /cgroup/3434/3436/tasks   # empty

        $ cat /cgroup/3434/3436/1/tasks
        3436
        3437

I think we get the directory /cgroup/3434 due to the following unshare()

		/* private mounts namespace ? */
		if (args->mntns && unshare(CLONE_NEWNS | CLONE_FS) < 0) {
			ckpt_perror("unshare");
			exit(1);
		}

And we get the "3436/1" directory due to the unshare() in ckpt_remount_proc().

Following hack seems to fix both the levels and the lxc_restart command
correctly creates just the "/cgroup/3436" (which LXC renames to "/cgroup/bar"
cgroup).

---
From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Mon, 8 Mar 2010 12:03:46 -0800
Subject: [PATCH 1/1] Minimize unshare() calls

---
 restart.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/restart.c b/restart.c
index c82de21..6ac51e3 100644
--- a/restart.c
+++ b/restart.c
@@ -459,10 +459,12 @@ int app_restart(struct app_restart_args *args)
 		exit(1);
 
 	/* private mounts namespace ? */
+#if 0
 	if (args->mntns && unshare(CLONE_NEWNS | CLONE_FS) < 0) {
 		ckpt_perror("unshare");
 		exit(1);
 	}
+#endif
 
 	/* chroot ? */
 	if (args->root && chroot(args->root) < 0) {
@@ -717,10 +719,12 @@ static int ckpt_probe_child(pid_t pid, char *str)
  */
 static int ckpt_remount_proc(struct ckpt_ctx *ctx)
 {
+#if 0
 	if (unshare(CLONE_NEWNS | CLONE_FS) < 0) {
 		ckpt_perror("unshare");
 		return -1;
 	}
+#endif
 	/* this is unlikely, but we don't want to fail */
 	if (umount2("/proc", MNT_DETACH) < 0) {
 		if (ckpt_cond_fail(ctx, CKPT_COND_MNTPROC)) {
@@ -778,6 +782,7 @@ static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
 	int copy, ret;
 	genstack stk;
 	void *sp;
+	unsigned long flags = SIGCHLD;
 
 	ckpt_dbg("forking coordinator in new pidns\n");
 
@@ -802,7 +807,9 @@ static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
 	copy = ctx->args->copy_status;
 	ctx->args->copy_status = 1;
 
-	coord_pid = clone(__ckpt_coordinator, sp, CLONE_NEWPID|SIGCHLD, ctx);
+	flags |= CLONE_NEWPID|CLONE_NEWNS|CLONE_FS;
+
+	coord_pid = clone(__ckpt_coordinator, sp, flags, ctx);
 	genstack_release(stk);
 	if (coord_pid < 0) {
 		ckpt_perror("clone coordinator");
-- 
1.6.6.1
