From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][v4][PATCH 0/7] clone_with_pids() system call
Date: Thu, 13 Aug 2009 01:00:49 -0700
Message-ID: <20090813080049.GA16639__39756.1830621727$1250150527$gmane$org@us.ibm.com>
References: <20090807061103.GA19343@us.ibm.com>
	<m1vdks5qc8.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m1vdks5qc8.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
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
| Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:
| 
| > === NEW CLONE() SYSTEM CALL:
| >
| > To support application checkpoint/restart, a task must have the same pid it
| > had when it was checkpointed.  When containers are nested, the tasks within
| > the containers exist in multiple pid namespaces and hence have multiple pids
| > to specify during restart.
| >
| > This patchset implements a new system call, clone_with_pids() that lets a
| > process specify the pids of the child process.
| >
| > Patches 1 through 5 are helpers and we believe they are needed for application
| > restart, regardless of the kernel implementation of application restart.
| 
| I'm not very impressed.
| 
| - static int alloc_pidmap(struct pid_namespace *pid_ns)
| + static int alloc_pidmap(struct pid_namespace *pid_ns, int pid_max, int last_pid)
| 
| Do that.
| 
| That is pass in pid_max and last_pid, and you don't have to do weird
| things in alloc_pidmap, and no set_pidmap is needed.

But last_pid is from the pid_ns. Do you mean to have alloc_pidmap()
take a pid_min and pid_max and when choosing a specific pid, have
pid_min == pid_max == target_pid ?

| 
| No changes to copy_process are needed it already takes a struct pid
| argument.


I see your point about passing in both 'struct pid*' and target_pids[].
But in the common case the struct pid passed into copy_process() is
NULL - allocating pid in do_fork() would significantly alter the
existing control flow - no ? alloc_pid() assumes any new pid namespace
has been created - in copy_namespaces(). Moving the alloc_pid() to
do_fork() would require parsing clone_flags in do_fork() and pulling
pid namespace code out of copy_namespaces().

| 
| I haven't been following closely what is gained by having a clone_with_pids
| syscall?  

When restarting an application from a checkpoint, the application must get
the same pid it had at the time of checkpoint. clone_with_pids() would be
used during restart so the child can be created with a specific set of pids.

| 
| As for new namespaces that don't need to happen at process creation time
| (which is just about anything that is left) we can create a new syscall that
| unshares just that one.
| 

Ok. If all new namespaces can be handled with a variant of unshare(), we can
decouple clone_with_pids() from the clone-flags issue.

| 
| Eric
