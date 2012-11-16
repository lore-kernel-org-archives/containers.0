From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 11/11] pidns: Support unsharing the pid namespace.
Date: Fri, 16 Nov 2012 08:35:50 -0800
Message-ID: <1353083750-3621-11-git-send-email-ebiederm@xmission.com>
References: <8739097bkk.fsf@xmission.com>
	<1353083750-3621-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353083750-3621-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Unsharing of the pid namespace unlike unsharing of other namespaces
does not take affect immediately.  Instead it affects the children
created with fork and clone.  The first of these children becomes the init
process of the new pid namespace, the rest become oddball children
of pid 0.  From the point of view of the new pid namespace the process
that created it is pid 0, as it's pid does not map.

A couple of different semantics were considered but this one was
settled on because it is easy to implement and it is usable from
pam modules.  The core reasons for the existence of unshare.

I took a survey of the callers of pam modules and the following
appears to be a representative sample of their logic.
{
	setup stuff include pam
	child = fork();
	if (!child) {
		setuid()
                exec /bin/bash
        }
        waitpid(child);

        pam and other cleanup
}

As you can see there is a fork to create the unprivileged user
space process.  Which means that the unprivileged user space
process will appear as pid 1 in the new pid namespace.  Further
most login processes do not cope with extraneous children which
means shifting the duty of reaping extraneous child process to
the creator of those extraneous children makes the system more
comprehensible.

The practical reason for this set of pid namespace semantics is
that it is simple to implement and verify they work correctly.
Whereas an implementation that requres changing the struct
pid on a process comes with a lot more races and pain.  Not
the least of which is that glibc caches getpid().

These semantics are implemented by having two notions
of the pid namespace of a proces.  There is task_active_pid_ns
which is the pid namspace the process was created with
and the pid namespace that all pids are presented to
that process in.  The task_active_pid_ns is stored
in the struct pid of the task.

Then there is the pid namespace that will be used for children
that pid namespace is stored in task->nsproxy->pid_ns.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 kernel/fork.c          |   32 +++++++++++++++++++++++++-------
 kernel/nsproxy.c       |    2 +-
 kernel/pid_namespace.c |    2 --
 3 files changed, 26 insertions(+), 10 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index 0f2bbce..811ffba 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1565,9 +1565,11 @@ long do_fork(unsigned long clone_flags,
 	 * Do some preliminary argument and permissions checking before we
 	 * actually start allocating stuff
 	 */
-	if (clone_flags & CLONE_NEWUSER) {
-		if (clone_flags & CLONE_THREAD)
+	if (clone_flags & (CLONE_NEWUSER | CLONE_NEWPID)) {
+		if (clone_flags & (CLONE_THREAD|CLONE_PARENT))
 			return -EINVAL;
+	}
+	if (clone_flags & CLONE_NEWUSER) {
 		/* hopefully this check will go away when userns support is
 		 * complete
 		 */
@@ -1692,7 +1694,8 @@ static int check_unshare_flags(unsigned long unshare_flags)
 {
 	if (unshare_flags & ~(CLONE_THREAD|CLONE_FS|CLONE_NEWNS|CLONE_SIGHAND|
 				CLONE_VM|CLONE_FILES|CLONE_SYSVSEM|
-				CLONE_NEWUTS|CLONE_NEWIPC|CLONE_NEWNET))
+				CLONE_NEWUTS|CLONE_NEWIPC|CLONE_NEWNET|
+				CLONE_NEWPID))
 		return -EINVAL;
 	/*
 	 * Not implemented, but pretend it works if there is nothing to
@@ -1763,15 +1766,30 @@ SYSCALL_DEFINE1(unshare, unsigned long, unshare_flags)
 	int do_sysvsem = 0;
 	int err;
 
-	err = check_unshare_flags(unshare_flags);
-	if (err)
-		goto bad_unshare_out;
-
+	/*
+	 * If unsharing a pid namespace must also unshare the thread.
+	 */
+	if (unshare_flags & CLONE_NEWPID)
+		unshare_flags |= CLONE_THREAD;
+	/*
+	 * If unsharing a thread from a thread group, must also unshare vm.
+	 */
+	if (unshare_flags & CLONE_THREAD)
+		unshare_flags |= CLONE_VM;
+	/*
+	 * If unsharing vm, must also unshare signal handlers.
+	 */
+	if (unshare_flags & CLONE_VM)
+		unshare_flags |= CLONE_SIGHAND;
 	/*
 	 * If unsharing namespace, must also unshare filesystem information.
 	 */
 	if (unshare_flags & CLONE_NEWNS)
 		unshare_flags |= CLONE_FS;
+
+	err = check_unshare_flags(unshare_flags);
+	if (err)
+		goto bad_unshare_out;
 	/*
 	 * CLONE_NEWIPC must also detach from the undolist: after switching
 	 * to a new ipc namespace, the semaphore arrays from the old
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index cf37d52..2a11447 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -188,7 +188,7 @@ int unshare_nsproxy_namespaces(unsigned long unshare_flags,
 	int err = 0;
 
 	if (!(unshare_flags & (CLONE_NEWNS | CLONE_NEWUTS | CLONE_NEWIPC |
-			       CLONE_NEWNET)))
+			       CLONE_NEWNET | CLONE_NEWPID)))
 		return 0;
 
 	if (!capable(CAP_SYS_ADMIN))
diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
index c6514f5..a385b98 100644
--- a/kernel/pid_namespace.c
+++ b/kernel/pid_namespace.c
@@ -143,8 +143,6 @@ struct pid_namespace *copy_pid_ns(unsigned long flags,
 {
 	if (!(flags & CLONE_NEWPID))
 		return get_pid_ns(old_ns);
-	if (flags & (CLONE_THREAD|CLONE_PARENT))
-		return ERR_PTR(-EINVAL);
 	if (task_active_pid_ns(current) != old_ns)
 		return ERR_PTR(-EINVAL);
 	return create_pid_namespace(user_ns, old_ns);
-- 
1.7.5.4
