From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][v4][PATCH 7/7]: Define clone_with_pids syscall
Date: Mon, 10 Aug 2009 10:07:12 -0500
Message-ID: <20090810150712.GA20358__38427.4432472468$1249917605$gmane$org@us.ibm.com>
References: <20090807061103.GA19343@us.ibm.com>
	<20090807061517.GG20672@us.ibm.com> <20090810145425.GA1378@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090810145425.GA1378-+ZI9xUNit7I@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Pavel Machek (pavel-+ZI9xUNit7I@public.gmane.org):
> > Unlike clone(), clone_with_pids() needs CAP_SYS_ADMIN, at least for now, to
> > prevent unprivileged processes from misusing this interface.
> > 
> > Call clone_with_pids as follows:
> > 
> > 	pid_t pids[] = { 0, 77, 99 };
> > 	struct pid_set pid_set;
> > 
> > 	pid_set.num_pids = sizeof(pids) / sizeof(int);
> > 	pid_set.pids = &pids;
> > 
> > 	syscall(__NR_clone_with_pids, flags, stack, NULL, NULL, NULL, &pid_set);
> > 
> > If a target-pid is 0, the kernel continues to assign a pid for the process in
> > that namespace. In the above example, pids[0] is 0, meaning the kernel will
> > assign next available pid to the process in init_pid_ns. But kernel will assign
> > pid 77 in the child pid namespace 1 and pid 99 in pid namespace 2. If either
> > 77 or 99 are taken, the system call fails with -EBUSY.
> > 
> > If 'pid_set.num_pids' exceeds the current nesting level of pid namespaces,
> > the system call fails with -EINVAL.
> 
> Does it make sense to set the pid in anything but innermost container?

Yup, we might be restarting an app using a nested pid namespace, in which
case restart would specify pids for 2 (or more) of the innermost containers.

thanks,
-serge
