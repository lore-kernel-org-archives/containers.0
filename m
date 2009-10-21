From: Arnd Bergmann <arndbergmann-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: [RFC][v8][PATCH 10/10]: Document clone3() syscall
Date: Wed, 21 Oct 2009 10:37:38 +0200
Message-ID: <200910211037.38413.arnd__39967.8071881228$1256114346$gmane$org@arndb.de>
References: <20091013044925.GA28181@us.ibm.com>
	<20091013045556.GJ28435@us.ibm.com> <20091019213636.GB1482@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091019213636.GB1482-+ZI9xUNit7I@public.gmane.org>
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
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

> 
> > +struct clone_struct {
> > +	u64 flags;
> > +	u64 child_stack;
> 
> u64 seems wrong  on 32 bit platforms. ulong?

That would make it incompatible between 64 bit kernels and
32 bit user space, requiring a wrapper. Better leave it at u64.

> > +	If a pid in the @pids list is 0, the kernel will assign the next
> > +	available pid in the pid namespace, for the process.
> > +
> > +	If a pid in the @pids list is non-zero, the kernel tries to assign
> > +	the specified pid in that namespace.  If that pid is already in use
> > +	by another process, the system call fails with -EBUSY.
> ...
> > +	On failure, clone3() returns -1 and sets 'errno' to one of following
> > +	values (the child process is not created).
> 
> Inconsistent with above. Syscalls really return -ERRCODE, errno is
> glibc magic.

Quite the opposite is true.

The man page describes what the user space sees, which is errno. Returning
-ERRCODE to libc from the kernel is part of the architecture specific
kernel ABI and should not be documented in this place but in the architecture
documentation.

> > +	pid_t pids[] = { 77, 99 };
> > +	struct clone_struct cs;
> > +
> > +	cs.flags = (u64) SIGCHLD;
> > +	cs.child_stack = (u64) setup_child_stack();
> > +	cs.nr_pids = 2;
> > +	cs.parent_tid = 0LL;
> > +	cs.child_tid = 0LL;
> > +
> > +	rc = syscall(__NR_clone3, &cs, pids);
> 
> Hmm, is there reason why pids are not at the end of struct
> clone_struct? Passing most parameters in special structure, then pids
> separately is strange...

I suggested doing that, it's a lot easier to handle fixed length data
structures than an array at the end.

	Arnd <><
