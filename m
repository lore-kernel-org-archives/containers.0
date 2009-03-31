From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v14-rc2][PATCH 5/7] Infrastructure for work postponed to
	the end of checkpoint/restart
Date: Tue, 31 Mar 2009 12:00:10 -0400
Message-ID: <49D23E0A.2030308@cs.columbia.edu>
References: <1238477552-17083-1-git-send-email-orenl@cs.columbia.edu>	
	<1238477552-17083-6-git-send-email-orenl@cs.columbia.edu>
	<1238512639.8286.658.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1238512639.8286.658.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


Dave Hansen wrote:
> On Tue, 2009-03-31 at 01:32 -0400, Oren Laadan wrote:
>> Add a interface to postpone an action until the end of the entire
>> checkpoint or restart operation. This is useful when during the
>> scan of tasks an operation cannot be performed in place, to avoid
>> the need for a second scan.
> 
> Why aren't we using the existing kernel workqueue mechanism?

Because we need to defer to work until the end of the operation:
not earlier, because it we defer it for a reason; not later, because
we will block waiting for it.

The kernel's workqueue schedules the work for 'some time later'.
It may be in particular too early. Although unlikely, it can also
occur arbitrarily later, so finishing and cleaning up a checkpoint
or a restart will have to block on it.

Also, the kernel workqueue cannot make any assumptions about the task
context in which the work is performed. The restart many times builds
on running in the context of some specific restarting task.

Example: this patch assumes a single (common) ipc namespace, but that
is easy to change. To support more than one, we'll need to perform the
deferred ipc action in the context of the process that has that ipc_ns.
(this means that this mechanism will evolve to per-task.)

If we were to use that workqueue, we would probably need to create a
queue per c/r operation to allow efficient flush; recall that each
workqueue comes with its own thread(s). In general, the mechanism
is too heavy.

What we need is a simple way for the c/r operation as a whole, and
later a task in particular, to defer some action until later _in the
restart_ process (not arbitrarily).

I should have named it cr_deferwork, and wrote this ^^^ in the patch.

Oren.
