From: Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Testing lxc 0.6.5 in Fedora 13
Date: Mon,  5 Apr 2010 20:44:43 -0700 (PDT)
Message-ID: <20100406034443.8B40ED477__34797.044148627$1270525529$gmane$org@magilla.sf.frob.com>
References: <20100321195044.GA23757@megiteam.pl>
	<20100323212834.GH20796@count0.beaverton.ibm.com>
	<20100325213356.GB20541@megiteam.pl>
	<20100326111131.GA8604@redhat.com>
	<20100326115357.GA3345@count0.beaverton.ibm.com>
	<20100326124522.GD17113@megiteam.pl>
	<20100326134709.GB15790@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: Oleg Nesterov's message of  Friday,
	26 March 2010 14:47:09 +0100 <20100326134709.GB15790-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

(I've been away for a couple of weeks.)
I concur with the things Oleg's said in this thread.

As to what's "correct" for the kernel in theory, it would certainly make
sense to clean up the ptrace cases to use the tracer (parent) pid_ns when
reporting any PID as such.  The wait and SIGCHLD code already does this, so
that would be consistent.  Off hand I don't see anything other than
tracehook_report_clone{,_complete}() that sees the wrong value now.

Fixing that requires a bit of hair.  The simple and clean approach is to
just have the tracehook calls (i.e. ptrace layer) extract the PID from the
task_struct using the desired pid_ns.  The trouble there is that the
tracehook_report_clone_complete() call is made when that task_struct is no
longer guaranteed to be valid.  The contrary approach of extracting the
appropriate value for the tracer earlier breaks the clean layering because
the fork.c code really should not know at all that ->parent->nsproxy is the
place to look for what values to pass to tracehook calls.  I guess the
simple and clean fix is to get_task_struct() before wake_up_new_task()
and put_task_struct() after tracehook_report_clone_complete().  That does
add some gratuitous atomic incr/decr overhead, though.

None of this has much of anything to do with strace, of course.  As I've
said, I don't see anything other than the PTRACE_GETEVENTMSG value for
PTRACE_EVENT_{CLONE,FORK,VFORK} reports that is wrong in the kernel.  As
Oleg said, strace doesn't use that at all.  (This is not the place to
discuss the details of strace further.)


Thanks,
Roland
