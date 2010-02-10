From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/6][RFC] user-cr: restart: Make task table portable
Date: Tue, 9 Feb 2010 18:13:57 -0800
Message-ID: <20100210021357.GM3714@count0.beaverton.ibm.com>
References: <1265666243-29046-1-git-send-email-matthltc@us.ibm.com>
	<4B709D90.6000605@cs.columbia.edu>
	<20100209232252.GK3714@count0.beaverton.ibm.com>
	<4B71FCBA.9060408@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4B71FCBA.9060408-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Feb 09, 2010 at 07:24:26PM -0500, Oren Laadan wrote:
> Matt Helsley wrote:
> >On Mon, Feb 08, 2010 at 06:26:08PM -0500, Oren Laadan wrote:
> >>Matt Helsley wrote:

<snip>

> >chmod executable
> >----------------
> >u+s   /bin/restart
> >og-x  /foo/restart32
> >og-x  /foo/restart64
> >
> >/bin/restart only execs the two helpers, does not use exec*p() [glibc],
> >and uses constant strings (e.g. no sprintf) for locating the executable.
> >At that point I think we can be sure that users cannot pass arbitrary
> >data into the helpers which did not also get into the suid restart
> >"frontend".
> 
> Hmmm...  I don't like the idea of being able to cause a program
> (restart32/restart64) to segfault with bad input. Even if only
> root can do it.

OK.

> IOW, we want to sanitize the data to the backend anyway. This
> means checking index boundaries and testing for loops. If we
> do that, then there is no need for the global, and we can do
> with only two binaries: restart32 and restart64.

The difference is now userspace can pass arbitrary data into two
different "files" -- the checkpoint image and the task table.
With the design above unprivileged users can only pass arbitrary
data to one file -- the checkpoint image. Only privileged
users can pass arbitrary data to both. My feeling is that
offers additional protection but I honestly haven't worked out
whether that's truly the case :/.

> >In the frontend we can check things like number of tasks in the checkpoint
> >image to make sure they won't exceed per-user limits. There are different
> >ways/times we can enforce that. Since the table is one block we can check
> >indices or even pointers for illegal values. Perhaps we could check the pids
> >somehow, or modify the way pids are specified to avoid the checks.
> >I'd need to think about the pid checking some more..
> 
> What do you have in mind to check about the pids ?

Well, this may be a stupid suggestion but I was thinking we could
make sure some of the pids match the way indexes link table entries. Like
I said -- I'd need to think about it some more.

> >>>The patches:
> >>>	1/6 Make context global
> >>I suppose this is only necessary to because the ->ctx pointer in
> >>the @task will be invalid in the address space of the exec'ed
> >>instance.
> >>
> >>To avoid the need for @ctx as global, we can (as noted above) make
> >>a local copy of the tasks array and set adjust the @ctx pointer in
> >>each entry.
> >
> >Except pointers are different sizes and have different alignment
> >constraints too. If we need to change too much of the table we may
> >as well rebuild the table from scratch, no? That may even be
> >perferrable if the code would be simpler to read.
> 
> To avoid changing the too much of the table, we can use:
> 
>     union {
>         struct ckpt_ctx *ctx;
>         u64 dummy;
>     } ctx;

My review of the code suggested all the table entries use the same context.
That seems like a waste -- the pointer could be put before table if getting
rid of the global is truly necessary. The only thing getting rid of the
global buys us, it seems, is reentrancy. Is that really useful during
restart? It probably is during checkpoint -- but that's a separate binary
and we haven't even started incremental checkpoint support..

> >>I actually want to remove globals altogether, so that we can make
> >>the restart functionality available as a library. Unfortunately I'm
> >>not sure it's possible because we use most of them in the signal
> >>handling context.
> >
> >I don't think removing the globals is necessary for a library. We
> >just need to be careful about the symbols it exports.
> >
> >Libraries handling signals? I've never written one and conventional
> >wisdom says to run away from such a beasts. Libraries that handle
> >signals greatly limit usefulness (applications use the same signals)
> >and introduce ample opportunities for ugly bugs. Most applications
> >frequently mess up signal handling in obscure, possibly
> >arch or system-dependent ways. Combining those applications with a
> >library that handles signals is just asking for trouble.
> 
> I totally agree.

OK, sorry if I jumped to conclusions and assumed you were proposing
libraries registering signal handlers. :)

> My concern is/was about the restart library being able to detect
> all failures and properly cleanup after itself. I looked at it
> again now, and, yes, there may be a way around using SIGCHLD,
> although that is not asking for troubles in tasks forked by the
> library itself.

Yup.

> As for SIGINT, well, that's purely for 'restart'. However, there
> should be a way for a program to be able to catch SIGINT and then
> properly cleanup a failed restart, too.

OK, that's just a library function. The application can do whatever
it needs to ensure that the function is called after a SIGINT but
we don't need to make it safe for execution during a signal handler.

> I'm putting this on hold for now.

Sure, there's plenty of other stuff to do.

Cheers,
	-Matt Helsley
