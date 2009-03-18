From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 0/6] /proc/pid/checkpointable
Date: Wed, 18 Mar 2009 04:55:27 -0400
Message-ID: <49C0B6FF.5030104@cs.columbia.edu>
References: <20090317062754.GA2377@us.ibm.com>
	<20090317063940.GF2377@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090317063940.GF2377-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org



Sukadev Bhattiprolu wrote:
> From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Date: Fri, 13 Mar 2009 17:25:42 -0700
> Subject: [PATCH 5/6] Define and use proc_pid_checkpointable()
> 
> Create a proc file, /proc/pid/checkpointable, which shows '1' if
> task is checkpointable and '0' if it is not.
> 
> To determine whether a task is checkpointable, the handler for this
> new proc file, shares the same code with sys_checkpoint().

I still don't understand why we would like to do it this way.

First, it makes little sense to do it per-task, because we are supposed
to checkpoint an entire container.

Second, what's wrong with doing a "dry" checkpoint on the container (or
if you prefer, the task, for what it's worth), that will not buffer nor
write out any data - just say "yes" or "no" ?

(we could use a flag "CR_CTX_DRYRUN" when calling sys_checkpoint() for
this, and test for this flag in, say, kwrite/kread).

After all, we don't expect applications or users to continuously and
repeatedly test if they can checkpoint, so it isn't performance critical.
So we simply reuse the existing code.

This would also catch cases where we can't checkpoint because the kernel
is low on memory - which wouldn't show up otherwise.

And in any case, this is orthogonal to what Dave is pushing, following
Ingo's comment, to know when a task _becomes_ not-checkpointable. (And
in any case, I think our time is better spent on adding functionality
instead).

Oren.
