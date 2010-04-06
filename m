From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Testing lxc 0.6.5 in Fedora 13
Date: Tue, 06 Apr 2010 08:17:21 -0700
Message-ID: <m1k4sk8vb2.fsf__5052.82787275991$1270567111$gmane$org@fess.ebiederm.org>
References: <20100321195044.GA23757@megiteam.pl>
	<20100323212834.GH20796@count0.beaverton.ibm.com>
	<20100325213356.GB20541@megiteam.pl>
	<20100326111131.GA8604@redhat.com>
	<20100326115357.GA3345@count0.beaverton.ibm.com>
	<20100326124522.GD17113@megiteam.pl>
	<20100326134709.GB15790@redhat.com>
	<20100406034443.8B40ED477@magilla.sf.frob.com>
	<20100406135345.GC3345@count0.beaverton.ibm.com>
	<20100406143635.GA12315@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100406143635.GA12315-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (Oleg Nesterov's message of
	"Tue\, 6 Apr 2010 16\:36\:35 +0200")
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> On 04/06, Matt Helsley wrote:
>>
>> On Mon, Apr 05, 2010 at 08:44:43PM -0700, Roland McGrath wrote:
>>
>> > tracehook_report_clone_complete() call is made when that task_struct is no
>> > longer guaranteed to be valid.
>
> Hmm. I missed this.
>
>> Also, if utrace allows multiple tracers and they each
>> exist in a different namespace then storing a pid nr isn't going to work.
>
> Yes, but utrace is simple. ptrace_report_clone() does
>
> 	ctx->eventmsg = child->pid;
>
> we should fix this line and that is all, afaics. Every tracer has a
> separate "struct ptrace_context *ctx".
>
>> So my hunch is, in the long run, we'll need to hold a reference there and
>> drop it when the last tracer detaches
>
> Without utrace only one tracer is possible.
>
> So, I think we should either change do_fork() to get the right tracee_pid_nr,
> or add get/put into do_fork() and change tracehooks as Roland suggested.

For a unicast path where the is no danger of the destination process changing
I don't see why we can't compute the userspace pid_nr.  It only get's tricky
for things like broadcast signals (pgrp, session) when we don't who the
final recipient process will be.

I think that only gets truly bad in the case of unix domain sockets.

Eric
