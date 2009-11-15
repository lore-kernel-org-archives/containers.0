From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH user-cr 2/2] add nsexeccwp to test clone-with-pids
Date: Sun, 15 Nov 2009 17:49:44 -0600
Message-ID: <1258328984.4031.21.camel@localhost.localdomain>
References: <1258089886-10034-1-git-send-email-serue@us.ibm.com>
	<1258089886-10034-3-git-send-email-serue@us.ibm.com>
	<1258325156.4031.3.camel@localhost.localdomain>
	<20091116111249.GA32340@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091116111249.GA32340-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 2009-11-16 at 05:12 -0600, Serge E. Hallyn wrote:
> Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> > On Thu, 2009-11-12 at 23:24 -0600, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> > > +	if (use_clone) {
> > > +		int stacksize = 4*getpagesize();
> > > +		void *stack = malloc(stacksize);
> > > +
> > > +		if (!stack) {
> > > +			perror("malloc");
> > > +			return -1;
> > > +		}
> > > +
> > > +		printf("about to clone with %lx\n", flags);
> > > +		if (chosen_pid)
> > > +			printf("Will choose pid %d\n", chosen_pid);
> > > +		flags |= SIGCHLD;
> > > +		pid = clone_with_pids(do_child, stack, flags, &pid_set,
> > > +					(void *)argv);
> > 
> > The stack argument should be adjusted with the usual stack += stacksize
> > - 1 or similar, right?
> 
> the clone_with_pids() helper in user-cr/clone_s390x.c (and IIRC the
> x86 one by Suka also) does this implicitly, by doing:
> 
> 	s = child_stack;
> 	*--s = arg;
> 	*--s = fn;
> 	child_stack -= 16

That's setting up arguments for the function to run in the child, and
afaict that code assumes the value of child_stack is the _end_ of the
stack region.  The code I quoted above is passing the beginning of the
region (the return value from malloc).

On powerpc the segfaults went away when I made the following change.

diff --git a/nsexeccwp.c b/nsexeccwp.c
index a71d9a4..92eb092 100644
--- a/nsexeccwp.c
+++ b/nsexeccwp.c
@@ -309,8 +309,8 @@ int main(int argc, char *argv[])
                if (chosen_pid)
                        printf("Will choose pid %d\n", chosen_pid);
                flags |= SIGCHLD;
-               pid = clone_with_pids(do_child, stack, flags, &pid_set,
-                                       (void *)argv);
+               pid = clone_with_pids(do_child, stack + stacksize - 1,
+                                     flags, &pid_set, (void *)argv);
