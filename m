From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: [RFC][PATCH 0/5] Container init signal semantics
Date: Tue, 25 Nov 2008 19:42:42 -0800
Message-ID: <20081126034242.GA23120@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754112AbYKZDnP@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: oleg@redhat.com, ebiederm@xmission.com, roland@redhat.com
Cc: daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org, sukadev@us.ibm.com
List-Id: containers.vger.kernel.org


Container-init must behave like global-init to processes within the
container and hence it must be immune to unhandled fatal signals from
within the container (i.e SIG_DFL signals that terminate the process).

But the same container-init must behave like a normal process to 
processes in ancestor namespaces and so if it receives the same fatal
signal from a process in ancestor namespace, the signal must be
processed.

Further, since processes don't have a valid pid numbers in a descendant
pid namespaces, the siginfo->si_pid field must be set to 0.

Implementing these semantics requires that send_signal() determine pid
namespace of the sender but since signals can originate from workqueues/
interrupt-handlers, determining pid namespace of sender may not always
be possible or safe.

This patchset implements the design/simplified semantics suggested by
Oleg Nesterov.  These semantics are:

	- container-init must never be terminated by a signal from a
	  descendant process.

	- container-init must never be immune to SIGKILL from an ancestor
	  namespace (so a process in parent namespace must always be able
	  to terminate a descendant container).

	- container-init may be immune to unhandled fatal signals (like
	  SIGUSR1) even if they are from ancestor namespace (SIGKILL is
	  the only reliable signal from ancestor namespace).

Patches in this set:

	[PATCH 1/5] pid: Implement ns_of_pid
	[PATCH 2/5] pid: Generalize task_active_pid_ns
	[PATCH 3/5] Determine if sender is from ancestor ns
	[PATCH 4/5] Protect cinit from fatal signals
	[PATCH 5/5] Clear si_pid for signal from ancestor ns

TODO:
	- SIGSTOP and ptrace functionality to be reviewed/fixed.

	- siginfo->si_pid may need to be cleared in a few more places
	  (eg; __do_notify(), F_SETSIG ?).

Limitations/side-effects of current design

	- Container-init is immune to suicide - kill(getpid(), SIGKILL) is
	  ignored. Use exit() :-)

	- rt_sigqueueinfo(): siginfo->si_pid value is unreliable/undefined
	  when rt_sigqueueinfo() is used to signal a process in a descendant
	  namespace

Signed-off-by: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
