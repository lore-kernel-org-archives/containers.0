From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v5][PATCH 0/9] Kernel based checkpoint/restart
Date: Wed, 08 Oct 2008 05:59:22 -0400
Message-ID: <48EC847A.5060900__43589.6576302641$1223460418$gmane$org@cs.columbia.edu>
References: <1221347167-9956-1-git-send-email-orenl@cs.columbia.edu>
	<20080917141601.GA14010@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080917141601.GA14010-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>> These patches implement basic checkpoint-restart [CR]. This version (v5)
>> supports basic tasks with simple private memory, and open files (regular
>> files and directories only). The main changes include rework of memory
>> restart code and response to feedback. See original announcements below.
>>
>> Oren.
> 
> At the kernel summit, it was asked whether at some point this CR work
> could be used as the basis for a new suspend to disk implementation.
> I answered that we don't plan to handle kernel threads.  In your
> experience, are there any reasons why eventually we couldn't eventually
> handle kernel threads?
> 
> -serge

As far as I can see, there isn't an inherent reason not to handle
kernel threads. However, I never looked deep into the problem.

The main issue that I can see with it is similar to what the
hibernation developers must tackle anyway - how to freeze kernel
threads when some of them may still be needed to take the system
down.

Assuming that is solved, then we're left with how to freeze the
kernel threads in a state that makes sense for a restart; for
regular tasks this is right before going back to user-land (*),
for kernel threads it may not be the best place :)

(*) however, tasks that are ptraced or in the middle of a vfork
will require special treatment - since upon freezing they cannot
be forced to that convenient position; so upon restart there must
be special code to make their behavior after restart compatible
with what they would have done originally - probably by emulation
as opposed to rebuilding their old kernel stack. For instance,
if a task was stopped due to ptrace before return from a syscall,
then upon restart it should return to that exact state.

So I'd assume that kernel threads could be treated in a similar
manner by special-casing, if necessary.

Question: I'd assume that at least for some of the kernel threads
a simple re-launch at restart will do; how many really require that
we save and restore their state ?

Oren
