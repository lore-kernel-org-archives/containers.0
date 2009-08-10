From: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Subject: Re: [RFC][v4][PATCH 7/7]: Define clone_with_pids syscall
Date: Mon, 10 Aug 2009 16:54:25 +0200
Message-ID: <20090810145425.GA1378__4672.56105407632$1249916337$gmane$org@ucw.cz>
References: <20090807061103.GA19343@us.ibm.com>
	<20090807061517.GG20672@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090807061517.GG20672-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi!

> 
> Subject: [RFC][v4][PATCH 7/7]: Define clone_with_pids syscall
> 
> Container restart requires that a task have the same pid it had when it was
> checkpointed. When containers are nested the tasks within the containers
> exist in multiple pid namespaces and hence have multiple pids to specify
> during restart.
> 
> clone_with_pids(), intended for use during restart, is the same as clone(),
> except that it takes a 'target_pid_set' paramter. This parameter lets caller
> choose specific pid numbers for the child process, in the process's active
> and ancestor pid namespaces. (Descendant pid namespaces in general don't
> matter since processes don't have pids in them anyway, but see comments
> in copy_target_pids() regarding CLONE_NEWPID).

This should go to documentation/manpage somewhere.


> Unlike clone(), clone_with_pids() needs CAP_SYS_ADMIN, at least for now, to
> prevent unprivileged processes from misusing this interface.
> 
> Call clone_with_pids as follows:
> 
> 	pid_t pids[] = { 0, 77, 99 };
> 	struct pid_set pid_set;
> 
> 	pid_set.num_pids = sizeof(pids) / sizeof(int);
> 	pid_set.pids = &pids;
> 
> 	syscall(__NR_clone_with_pids, flags, stack, NULL, NULL, NULL, &pid_set);
> 
> If a target-pid is 0, the kernel continues to assign a pid for the process in
> that namespace. In the above example, pids[0] is 0, meaning the kernel will
> assign next available pid to the process in init_pid_ns. But kernel will assign
> pid 77 in the child pid namespace 1 and pid 99 in pid namespace 2. If either
> 77 or 99 are taken, the system call fails with -EBUSY.
> 
> If 'pid_set.num_pids' exceeds the current nesting level of pid namespaces,
> the system call fails with -EINVAL.

Does it make sense to set the pid in anything but innermost container?


-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
