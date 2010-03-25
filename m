From: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
Subject: Re: Testing lxc 0.6.5 in Fedora 13
Date: Thu, 25 Mar 2010 22:33:56 +0100
Message-ID: <20100325213356.GB20541@megiteam.pl>
References: <20100321195044.GA23757@megiteam.pl>
	<20100323212834.GH20796@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100323212834.GH20796-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On wto, mar 23, 2010 at 02:28:34 -0700, Matt Helsley wrote:
> On Sun, Mar 21, 2010 at 08:50:44PM +0100, Grzegorz Nosek wrote:
> 
> <snip>
> 
> > 2. Weird strace behaviour across pidns boundary
> > 
> > When strace'ing (with -ff) lxc-start, I get a proper strace for the
> > directly spawned process and the container init. However, any processes
> > spawned by the container's init are not straced properly (I get two
> > empty files, named <foo>.<pid-in-root-ns> and <foo>.2 -- presumably pid
> > inside the container). The container also seems to malfunction under
> > strace (looks like exec() failing as lxc-ps shows two "init" processes).
> > 
> > This is quite painful as it prevents strace'ing processes in containers
> > even after startup. Here's a snippet of strace'ing a bash (pid 179
> > inside, pid 2959 outside) trying to run 'ls'. The shell hangs until I
> > kill the strace process.
> > 
> > pipe([3, 4])                            = 0
> > clone(Process 197 attached
> > child_stack=0, flags=CLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|SIGCHLD, child_tidptr=0xb7859708) = 197
> > Process 2999 attached (waiting for parent)
> > [pid  2959] setpgid(197, 197)           = 0
> > [pid  2959] rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
> > [pid  2959] rt_sigprocmask(SIG_BLOCK, [CHLD], [], 8) = 0
> > [pid  2959] close(3)                    = 0
> > [pid  2959] close(4)                    = 0
> > [pid  2959] rt_sigprocmask(SIG_BLOCK, [CHLD TSTP TTIN TTOU], [CHLD], 8) = 0
> > [pid  2959] ioctl(255, TIOCSPGRP, [197]) = 0
> > [pid  2959] rt_sigprocmask(SIG_SETMASK, [CHLD], NULL, 8) = 0
> > [pid  2959] rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
> > [pid  2959] rt_sigprocmask(SIG_BLOCK, [CHLD], [], 8) = 0
> > [pid  2959] waitpid(-1, Process 2959 suspended
> > ^C <unfinished ...>
> > Process 2959 detached
> > Process 197 detached
> > Process 2999 detached
> > 
> > 'strace ls' ran completely inside the container works as expected.
> 
> I'm suprised strace of ls works across pid namespaces. I've been looking
> at strace and it seemed to me that one kernel change and a bunch of strace
> changes are needed to make strace'ing in child pid namespaces work. Eric
> Biederman's setns() patches also might help.

Thanks for the patch and the detailed explanation.

> Can you get a little farther with the kernel fix below?

No, not really. Attaching from outside to a shell running in a container
and running a command yields:

| rt_sigprocmask(SIG_BLOCK, [INT CHLD], [], 8) = 0
| pipe([3, 4])                            = 0
| clone(Process 2581 attached (waiting for parent)
| Process 190 attached

Without the patch the order of reported pids is reversed (and at least
with the patched kernel the outside pid is consistently reported first)

| child_stack=0, flags=CLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|SIGCHLD, child_tidptr=0xb7713708) = 190
| [pid  2549] setpgid(190, 190)           = 0
| [pid  2549] rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
| [pid  2549] rt_sigprocmask(SIG_BLOCK, [CHLD], [], 8) = 0
| [pid  2549] close(3)                    = 0
| [pid  2549] close(4)                    = 0
| [pid  2549] rt_sigprocmask(SIG_BLOCK, [CHLD TSTP TTIN TTOU], [CHLD], 8) = 0
| [pid  2549] ioctl(255, TIOCSPGRP, [190]) = 0
| [pid  2549] rt_sigprocmask(SIG_SETMASK, [CHLD], NULL, 8) = 0
| [pid  2549] rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
| [pid  2549] rt_sigprocmask(SIG_BLOCK, [CHLD], [], 8) = 0
| [pid  2549] waitpid(-1, Process 2549 suspended

(the shell hangs here)

^C <unfinished ...>
| Process 2549 detached
| Process 2581 detached
| Process 190 detached

(the command executes here normally).

Best regards,
 Grzegorz Nosek
