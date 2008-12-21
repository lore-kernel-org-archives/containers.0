From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: [RFC][PATCH 0/6][v3] Container-init signal semantics
Date: Sat, 20 Dec 2008 16:51:06 -0800
Message-ID: <20081221005106.GA4912@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754428AbYLUAwe@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: oleg@redhat.com, ebiederm@xmission.com, roland@redhat.com, bastian@waldi.eu.org
Cc: daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org, sukadev@us.ibm.com
List-Id: containers.vger.kernel.org


Container-init must behave like global-init to processes within the
container and hence it must be immune to unhandled fatal signals from
within the container (i.e SIG_DFL signals that terminate the process).

But the same container-init must behave like a normal process to 
processes in ancestor namespaces and so if it receives the same fatal
signal from a process in ancestor namespace, the signal must be
processed.

Implementing these semantics requires that send_signal() determine pid
namespace of the sender but since signals can originate from workqueues/
interrupt-handlers, determining pid namespace of sender may not always
be possible or safe.

Changelog[v3]:
	Changes based on discussions of previous version:
		http://lkml.org/lkml/2008/11/25/458

	Major changes:

	- Define SIGNAL_UNKILLABLE_FROM_NS and use in container-inits to
	  skip fatal signals from same namespace but process SIGKILL/SIGSTOP
	  from ancestor namespace.
	- Use SI_FROMUSER() and si_code != SI_ASYNCIO to determine if
	  it is safe to dereference pid-namespace of caller. Highly
	  experimental :-)
	- Masquerading si_pid when crossing namespace boundary: relevant
	  patches merged in -mm and dropped from this set.

	Minor changes:

	- Remove 'handler' parameter to tracehook functions
	- Update sig_ignored() to drop SIG_DFL signals to global init early
	  (tried to address Roland's  and Oleg's comments)
	- Use 'same_ns' flag to drop SIGKILL/SIGSTOP to cinit from same
	  namespace

This patchset implements the design/simplified semantics suggested by
Oleg Nesterov.  The simplified semantics for container-init are:

	- container-init must never be terminated by a signal from a
	  descendant process.

	- container-init must never be immune to SIGKILL from an ancestor
	  namespace (so a process in parent namespace must always be able
	  to terminate a descendant container).

	- container-init may be immune to unhandled fatal signals (like
	  SIGUSR1) even if they are from ancestor namespace (SIGKILL is
	  the only reliable signal from ancestor namespace).

Patches in this set:

	[PATCH 1/6] Remove 'handler' parameter to tracehook functions
	[PATCH 2/6] Protect init from unwanted signals more
	[PATCH 3/6] Define/set SIGNAL_UNKILLABLE_FROM_NS
	[PATCH 4/6] Define siginfo_from_ancestor_ns()
	[PATCH 5/6] Protect cinit from unblocked SIG_DFL signals
	[PATCH 6/6] Protect cinit from blocked fatal signals

TODO:
	- Use sig_task_unkillable() in fs/proc/array.c:task_sig() to
	  correctly report ignored signals for container/global init.
	- Make SI_ASYNCIO a kernel signal ?
	- Compile/touch tested. Need so real testing ;-)

Limitations/side-effects of current design

	- Container-init is immune to suicide - kill(getpid(), SIGKILL) is
	  ignored. Use exit() :-)
