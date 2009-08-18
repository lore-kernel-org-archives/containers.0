From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][v4][PATCH 0/7] clone_with_pids() system call
Date: Mon, 17 Aug 2009 20:31:23 -0700
Message-ID: <20090818033123.GC4713__1784.2905283489$1250566230$gmane$org@us.ibm.com>
References: <20090807061103.GA19343@us.ibm.com>
	<m1vdks5qc8.fsf@fess.ebiederm.org>
	<20090813080049.GA16639@us.ibm.com>
	<m1vdks2iea.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m1vdks2iea.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Eric W. Biederman [ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org] wrote:

| > But last_pid is from the pid_ns. Do you mean to have alloc_pidmap()
| > take a pid_min and pid_max and when choosing a specific pid, have
| > pid_min == pid_max == target_pid ?
| 
| Yes. It already takes a pid_min and a pid_max from the environment.
| I guess the pid_min is RESERVED_PIDS by default.

Well, defining alloc_pidmap() as:

	int alloc_pidmap(pid_ns, int min, int max)

seems to unnecessarily complicate alloc_pidmap() - what if 'min' is 0
but 'max' is not or vice-versa. Generalizing alloc_pidmap() to handle
all combinations seems like an overkill and/or expose RESERVED_PIDS and
pid_max caller.

Maybe we can drop the set_pidmap() call by sticking to 

	int alloc_pidmap(pid_ns, target_pid)

and setting 'max_scan' to 1 when target_pid is set (see quick patch below).

| 
| > | No changes to copy_process are needed it already takes a struct pid
| > | argument.
| >
| >
| > I see your point about passing in both 'struct pid*' and target_pids[].
| > But in the common case the struct pid passed into copy_process() is
| > NULL - allocating pid in do_fork() would significantly alter the
| > existing control flow - no ? alloc_pid() assumes any new pid namespace
| > has been created - in copy_namespaces(). Moving the alloc_pid() to
| > do_fork() would require parsing clone_flags in do_fork() and pulling
| > pid namespace code out of copy_namespaces().
| 
| Why change do_fork?

Sorry, maybe I am missing something. If we don't pass target_pids as a
parameter to copy_process(), how do we specify the target pids ?
Fill in a dummy struct pid with the target-pids and pass it into
copy_process() ?

| 
| > | I haven't been following closely what is gained by having a clone_with_pids
| > | syscall?  
| >
| > When restarting an application from a checkpoint, the application must get
| > the same pid it had at the time of checkpoint. clone_with_pids() would be
| > used during restart so the child can be created with a specific set of pids.
| 
| That part I understand.  What I don't understand is why have that one part be
| special and have user space do the work?

By 'work' do you mean the rest of the process-restart logic ?

The user-level restart program creates the necessary process using
clone_with_pids() and each child process calls another system call,
sys_restart() which restores the process state.

Sukadev

---

Index: linux-2.6/kernel/pid.c
===================================================================
--- linux-2.6.orig/kernel/pid.c	2009-08-17 18:43:15.000000000 -0700
+++ linux-2.6/kernel/pid.c	2009-08-17 19:41:57.000000000 -0700
@@ -122,18 +122,29 @@
 	atomic_inc(&map->nr_free);
 }
 
-static int alloc_pidmap(struct pid_namespace *pid_ns)
+static int alloc_pidmap(struct pid_namespace *pid_ns, int target_pid)
 {
 	int i, offset, max_scan, pid, last = pid_ns->last_pid;
 	struct pidmap *map;
 	int rc;
 
-	pid = last + 1;
-	if (pid >= pid_max)
-		pid = RESERVED_PIDS;
+	if (target_pid) {
+		if (target_pid < 0 || target_pid >= pid_max)
+			return -EINVAL;
+		pid = target_pid;
+		max_scan = 1;
+	} else {
+		pid = last + 1;
+		if (pid >= pid_max)
+			pid = RESERVED_PIDS;
+	}
+
 	offset = pid & BITS_PER_PAGE_MASK;
 	map = &pid_ns->pidmap[pid/BITS_PER_PAGE];
+
 	max_scan = (pid_max + BITS_PER_PAGE - 1)/BITS_PER_PAGE - !offset;
+	if (target_pid)
+		max_scan = 1;
 
 	rc = -EAGAIN;
 	for (i = 0; i <= max_scan; ++i) {
@@ -258,7 +269,7 @@
 
 	tmp = ns;
 	for (i = ns->level; i >= 0; i--) {
-		nr = alloc_pidmap(tmp);
+		nr = alloc_pidmap(tmp, 0);
 		if (nr < 0)
 			goto out_free;
