From: sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Subject: Signals to cinit
Date: Sat, 1 Nov 2008 11:05:05 -0700
Message-ID: <20081101180505.GA24268@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, daniel-nym3zxDgnZcAvxtiuMwx3w@public.gmane.org
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>
List-Id: containers.vger.kernel.org


Signals to container-init

Its been almost a year since we tried to address the signals to
container-init issue. We have two patchsets both of which address
the main issues and should work for current 'sysV init' (since init
explicitly ignores signals it does not handle).

But both patchsets fail in some corner cases and so the approaches
have stalled.

Can we choose one of these approaches and clearly define limitations
(with maybe noisy warnings for known corner-cases) ?  That way, cinits
have an option of working-around in user-space till a better solution
is in place.

Or should we explore other, potentially more expensive/intrusive
solutions ?  

I have below a brief summary of the two patchsets we tried before
and a very high-level suggestion for an more expensive/intrusive
fix.

Eric's patchset:

	https://lists.linux-foundation.org/pipermail/containers/2007-December/009152.html

	- Defines a semantic that drops signals to cinit if handler for signal
	  is SIG_DFL.

	- SIG_DFL signal is ignored even when blocked.

	- Fails with blocked signal if handler is SIG_DFL when blocked.

		  cinit: signal set to SIG_DFL
		  cinit: block signal
		  ancestor sends a fatal signal to cinit
		  signal is ignored (since handler is SIG_DFL)

	- cinit uses sigtimedwait() for a fatal signal set to SIG_DFL.
	  The patchset ignores the signal (due to the SIG_DFL).

	- /sbin/init blocks SIGCHLD, execs a new program which then installs
	  a handler for SIGCHLD. But since SIGCHLD == SIG_DFL just after
	  exec(), the SIGCHLD could be missed.


Oleg's patchset:

	Originally posted here:
	http://marc.info/?l=linux-kernel&m=118753610515859

	An updated patch is included in this mail:

	https://lists.linux-foundation.org/pipermail/containers/2007-December/009308.html

	- Fails with blocked signals

		cinit: block fatal signal
		descendant posts signal to cinit
		signal is queued since it was blocked
		cinit sets handler for signal to SIG_DFL
		cinit unblocks signal and terminates even though its from
		descendant.

	- Fails with ptraced cinit ?

	- Drops a signal in sigaction() or get_signal_to_deliver() after we
	  enqueuing it ("started processing it") 

	  (side-note:  But isn't there a precedent for it anyway ?
	  get_signal_to_deliver() currently does ignore signals it does not
	  want. sigaction() drops signals that were set to SIG_IGN)

	- To quote Eric, "does not start with a 'solid' definition and can
	  become unmaintainable", but I am not too clear on this comment.
		

Track ancestor-signals separately: (not implemented)

	Add a second 'sigset_t' to sigpending:

	struct sigpending {
		struct list_head list;
		sigset_t signal;
		sigset_t ancestor_signal;
	};

	'ancestor_signal' is only used for container-inits. Global inits
	have no ancestors so it is not affected.

	If a cinit receives a signal from a descendant, signal gets added
	to 'sigpending->signal' set (as is done today).

	If cinit receives a signal from an ancestor, signal is added to
	'ancestor_signal' set.

	When delivering the signal, (maybe in get_signal_to_deliver(), the
	cinit can determine if the signal was from ancestor/descendant
	and act accordingly.

	If the same signal is received from both ancestor and descendant it
	would be set in both sets and we make a policy maybe that ancestor
	has priority (i.e signal from descendant is ignored/dropped)

	Other observations:
		- when queuing the signal, we use the same 'sigpending->list' 
		  regardless of the sender's namespace so the order of
		  processing of signals is unchanged.

		- when dequeuing a signal, dequeue from both sets

		- when checking for a pending signal (eg: sigkill_pending()),
		  check the OR of both sets 
		  
	This would be intrusive since we need to replace reads/writes of 
	'current->pending.signal' and 'current->signal.shared_pending' with
	wrappers.
	
	It maybe a bit more expensive runtime and adds a new 'sigset_t' to
	task_struct/signal_struct.
	
	I can send a small prototype if this makes sense at all.

Other approaches to try ?


Thanks,

Sukadev
