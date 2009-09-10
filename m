From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][v6][PATCH 9/9]: Document clone_with_pids() syscall
Date: Wed, 9 Sep 2009 23:14:13 -0700
Message-ID: <20090910061413.GH25883__24748.5550040894$1252564868$gmane$org@us.ibm.com>
References: <20090910060627.GA24343@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090910060627.GA24343-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: arnd-r2nGTMty4D4@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org


Subject: [RFC][v6][PATCH 9/9]: Document clone_with_pids() syscall

This gives a brief overview of the clone_with_pids() system call.  We should
eventually describe more details either in clone(2) or in a new man page.

Signed-off-by: Sukadev Bhattiprolu <sukadev-8jLBTbqmX/OZamtmwQBW5tBPR1lH4CV8@public.gmane.org>
---
 Documentation/clone-with-pids |   58 ++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 58 insertions(+)

Index: linux-2.6/Documentation/clone-with-pids
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/Documentation/clone-with-pids	2009-09-09 21:53:30.000000000 -0700
@@ -0,0 +1,58 @@
+
+struct pid_set {
+	unsigned int num_pids;
+	pid_t pids[];
+};
+
+clone_with_pids(int flags, void *child_stack_base, int *parent_tid_ptr,
+			int *child_tid_ptr, NULL, struct pid_set *pid_setp)
+
+	The clone_with_pids() system call is identical to clone(), except
+	that it allows the user to specify a pid for the child process
+	in each of the child processes' pid name spaces.
+
+	This system call is meant to be used when restarting an application
+	from an earlier checkpoint. When restarting the application, the
+	processes in the application must get the same pids they had at the
+	time of the checkpoint.
+
+	The 'pid_setp' parameter defines a set of pids to use, one for each
+	pid-namespace of the child process.  The order pids in '->pids[]'
+	corresponds to the nesting order of pid-namespaces, with ->pids[0]
+	corresponding to the init_pid_ns.
+
+	If a pid in the ->pids list is 0, the kernel will assign the next
+	available pid in the pid namespace, for the process.
+
+	If a pid in the ->pids[] list is non-zero, the kernel tries to assign
+	the specified pid in that namespace.  If that pid is already in use
+	by another process, the system call fails with -EBUSY.
+
+	On success, the system call returns the pid of the child process in
+	the parent's active pid namespace.
+
+	On failure, clone_with_pids() returns -1 and sets 'errno' to one of
+	following values (the child process is not created).
+
+	EPERM	Caller does not have the SYS_ADMIN privilege needed to excute
+		this call.
+
+	EINVAL	The number of pids specified in 'pid_set.num_pids' exceeds
+		the current nesting level of parent process
+
+	EBUSY	A requested 'pid' is in use by another process in that name
+		space.
+
+Example:
+
+	struct pid_set pid_set { 3, {0, 99, 177} };
+	void *child_stack = malloc(STACKSIZE);
+
+	/* set up child_stack, like with clone() */
+	rc = clone_with_pids(clone_flags, child_stack, NULL, NULL, &pid_set);
+
+	if (rc < 0) {
+		perror("clone_with_pids()");
+		exit(1);
+	}
+
