From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/6][RFC] user-cr: restart: Make task table portable
Date: Tue, 9 Feb 2010 15:22:52 -0800
Message-ID: <20100209232252.GK3714@count0.beaverton.ibm.com>
References: <1265666243-29046-1-git-send-email-matthltc@us.ibm.com>
	<4B709D90.6000605@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4B709D90.6000605-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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

On Mon, Feb 08, 2010 at 06:26:08PM -0500, Oren Laadan wrote:
> Matt,
> 
> Thanks for the patch-set.
> 
> Matt Helsley wrote:
> >This series modifies the task table entries to use indexes rather than
> >pointers to create the tree. This is one step that enables the same
> >table to be shared between multiple restart processes regardless of
> >whether they are 32 or 64-bit.
> >
> >Further steps, not in this set, include:
> >	1. Mark bitness of each task in the table.
> >	2. Share the table contents.
> >		Probably via an fd passed during execve() then mmap()'ed
> 
> As I said before, I'm concerned about the security implications.
> 
> Assume the 'restart' is setuid.
> 
> When 'restart' starts with a switch, e.g. --cont-fd=FD --cont-nr=NN,
> it will map that FD to memory and expect valid data there. But what
> if the data is bogus ?

As far as I can see there are two broad security concerns with a setuid
restart:

	1. Make sure it can't be used to invoke arbitrary code.
	2. Make sure the incoming data is as "safe" as what
		would come in for the "non-exec" design.

#2 can be taken care of by making a setuid "frontend" which builds the
tables and runs a "backend" that isn't runnable by normal users and
does not have the suid bit set. Roughly something like:

chmod executable
----------------
u+s   /bin/restart
og-x  /foo/restart32
og-x  /foo/restart64

/bin/restart only execs the two helpers, does not use exec*p() [glibc],
and uses constant strings (e.g. no sprintf) for locating the executable.
At that point I think we can be sure that users cannot pass arbitrary
data into the helpers which did not also get into the suid restart
"frontend".

In the frontend we can check things like number of tasks in the checkpoint
image to make sure they won't exceed per-user limits. There are different
ways/times we can enforce that. Since the table is one block we can check
indices or even pointers for illegal values. Perhaps we could check the pids
somehow, or modify the way pids are specified to avoid the checks.
I'd need to think about the pid checking some more..

> At the very least, we'll need to verify that the data in the array
> is valid. That is, iterating through entries to verify contents.
> 
> (We might as well pass the data via a pipe and make a local copy of
> the data at the exec'ed instance)
> 
> 
> >	3. Find/modify restart to do execve() at the right spot.
> >
> >The patches:
> >	1/6 Make context global
> 
> I suppose this is only necessary to because the ->ctx pointer in
> the @task will be invalid in the address space of the exec'ed
> instance.
> 
> To avoid the need for @ctx as global, we can (as noted above) make
> a local copy of the tasks array and set adjust the @ctx pointer in
> each entry.

Except pointers are different sizes and have different alignment
constraints too. If we need to change too much of the table we may
as well rebuild the table from scratch, no? That may even be
perferrable if the code would be simpler to read.

> I actually want to remove globals altogether, so that we can make
> the restart functionality available as a library. Unfortunately I'm
> not sure it's possible because we use most of them in the signal
> handling context.

I don't think removing the globals is necessary for a library. We
just need to be careful about the symbols it exports.

Libraries handling signals? I've never written one and conventional
wisdom says to run away from such a beasts. Libraries that handle
signals greatly limit usefulness (applications use the same signals)
and introduce ample opportunities for ugly bugs. Most applications
frequently mess up signal handling in obscure, possibly
arch or system-dependent ways. Combining those applications with a
library that handles signals is just asking for trouble.

There are better ways of doing things. Perhaps eventfds. [Ab]using pipes.
Abusing robust futexes. Put any/all fds you need under a single epoll fd
and let the library API caller be responsible for poll'ing it if you must.
If the library caller is ok with blocking calls then the library itself
can poll those fds. waitid() with WNOWAIT -- which sort of peeks at the
wait "events" -- might also be useful.

Cheers,
	-Matt Helsley
