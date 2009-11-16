From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH user-cr 2/2] add nsexeccwp to test clone-with-pids
Date: Mon, 16 Nov 2009 05:12:49 -0600
Message-ID: <20091116111249.GA32340@us.ibm.com>
References: <1258089886-10034-1-git-send-email-serue@us.ibm.com>
	<1258089886-10034-3-git-send-email-serue@us.ibm.com>
	<1258325156.4031.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1258325156.4031.3.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> On Thu, 2009-11-12 at 23:24 -0600, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> > +	if (use_clone) {
> > +		int stacksize = 4*getpagesize();
> > +		void *stack = malloc(stacksize);
> > +
> > +		if (!stack) {
> > +			perror("malloc");
> > +			return -1;
> > +		}
> > +
> > +		printf("about to clone with %lx\n", flags);
> > +		if (chosen_pid)
> > +			printf("Will choose pid %d\n", chosen_pid);
> > +		flags |= SIGCHLD;
> > +		pid = clone_with_pids(do_child, stack, flags, &pid_set,
> > +					(void *)argv);
> 
> The stack argument should be adjusted with the usual stack += stacksize
> - 1 or similar, right?

the clone_with_pids() helper in user-cr/clone_s390x.c (and IIRC the
x86 one by Suka also) does this implicitly, by doing:

	s = child_stack;
	*--s = arg;
	*--s = fn;
	child_stack -= 16

-serge
