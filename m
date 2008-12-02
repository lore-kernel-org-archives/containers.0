From: Roland McGrath <roland@redhat.com>
Subject: Re: [RFC][PATCH 3/5] Determine if sender is from ancestor ns
Date: Mon,  1 Dec 2008 19:07:25 -0800 (PST)
Message-ID: <20081204005203.8C9ADFC3CD@magilla.sf.frob.com>
References: <20081126034242.GA23120@us.ibm.com>
	<20081126034611.GC23238@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758170AbYLDAyp@vger.kernel.org>
In-Reply-To: Sukadev Bhattiprolu's message of  Tuesday, 25 November 2008 19:46:11 -0800 <20081126034611.GC23238@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: oleg@redhat.com, ebiederm@xmission.com, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org, sukadev@us.ibm.com
List-Id: containers.vger.kernel.org

I don't quarrel with the intent, but I don't like this approach.
I think we can do it more cleanly.  I don't have it all worked out,
but a couple of thoughts come to mind.

Firstly, it's no problem to split SIGNAL_UNKILLABLE out into multiple
flags.  It's quite noninvasive, only signal.c looks at those flags.  Then
we can implement the signal magic cleanly keyed on a few separate flags,
using different flag combinations for global init and container inits.

I don't mind a feature that lets an unprivileged container init magically
ignore normal exit signals.  That just does something it could do itself
with sigaction, except its /proc/pid/status "SigIgn:" line will lie.
That's OK.  Key that on its own flag and set that in both inits.  Just
check that flag in prepare_signal() and in get_signal_to_deliver().

It's a different story for the signals that cannot be caught, blocked, or
ignored, SIGKILL and SIGSTOP.  At least when sent from outside the
container, circumventing either of those would be a privilege escalation
from what's always been understood by admins and so on.  

It's convenient for the implementation that we can treat these differently
from other signals, precisely because they can never be caught, blocked, or
ignored.  That is, when we decide in prepare_signal() to queue a SIGKILL or
SIGSTOP, it can never turn out that we're later going to drop it because it
went from caught or ignored or blocked to uncaught, unignored, and
unblocked.  (It's only because of that possibility that there is any need
to check for a suppressed exit signal in get_signal_to_deliver() rather
than only in prepare_signal().)  That means that when the decision hinges
on the namespace correlation of the sender and receiver, you can check that
when it's handy (current vs p in prepare_signal) rather than trying to
reconstruct the answer for a queued signal.

Finally, one more thought.  This may be moot for the problem at hand if you
take the approach I just suggested, but probably should be fixed anyway.
It seems to me that the si_pid and si_uid fields of siginfo_t ought to be
translated to the namespaces of the receiver.  I think it makes most sense
to do this on the front end, i.e. in the callers that fill in the siginfo_t
in the first place (sys_kill et al, or maybe a few layers down?).
Currently it's inconsistent, but mostly wrong.  do_notify_parent() and
do_notify_parent_cldstop() use the receiver's namespace to compute si_pid,
but the rest of the signal.c routines do not.  A free side effect of doing
this is that si_pid for a sender whose PID is not visible to the receiver
(i.e. outside its container) would be distinctively 0 or -1 or something.
(-1 might be the best choice, since si_[pu]id=0 already arises now in case
of signal queue exhaustion and the like.)  Hence, possibly one could simply
use si_pid>0 as a "sent from inside the container" check on a queued siginfo_t.


Thanks,
Roland
