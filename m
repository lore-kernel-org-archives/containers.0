From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][v6][PATCH 9/9]: Document clone_with_pids() syscall
Date: Thu, 10 Sep 2009 09:31:40 -0700
Message-ID: <20090910163140.GA14158__15890.4029791758$1252600151$gmane$org@us.ibm.com>
References: <20090910060627.GA24343@us.ibm.com>
	<20090910061413.GH25883@us.ibm.com>
	<20090910082659.033ab8fd.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090910082659.033ab8fd.randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: arnd-r2nGTMty4D4@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org


Thanks for the review. Will fix the typos.

Randy Dunlap [randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org] wrote:
| > +Example:
| > +
| > +	struct pid_set pid_set { 3, {0, 99, 177} };
| > +	void *child_stack = malloc(STACKSIZE);
| > +
| > +	/* set up child_stack, like with clone() */
| > +	rc = clone_with_pids(clone_flags, child_stack, NULL, NULL, &pid_set);
| > +
| > +	if (rc < 0) {
| > +		perror("clone_with_pids()");
| > +		exit(1);
| > +	}
| 
| What happens when one of the pids is busy?  Say the last one in the
| example above [177].  Are the first 2 children already cloned
| or are all pids checked for availability before cloning?

Only _one_ one child process is created (on success). With nested pid
namespaces a process is known by different pids (or pid numbers to be
precise) - one in each pid namespace.

(BTW, looks like we did not document pid-namespaces in the Documentation/
But please see the CLONE_NEWPID section of a recent version of clone(2)).

In short, the above clone_with_pids() tries to create a single child process
with the given pids.

| If the latter, is there a race there?
| and what value is returned?

There is no race - bc just a single process is being created.

If any of the pids are not available, the child process is not created
and the system call returns -EBUSY (if the user requested say 99 and 99
is in use by another process)
