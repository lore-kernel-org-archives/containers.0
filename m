From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: [PATCH 0/7][v6] Container-init signal semantics
Date: Tue, 6 Jan 2009 23:45:58 -0800
Message-ID: <20090107074558.GA27881@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755247AbZAGHsk@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: oleg@redhat.com, ebiederm@xmission.com, roland@redhat.com, bastian@waldi.eu.org
Cc: daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
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

	 [PATCH 1/7] Remove 'handler' parameter to tracehook functions
	 [PATCH 2/7] Protect init from unwanted signals more
	 [PATCH 3/7] Add from_ancestor_ns parameter to send_signal()
	 [PATCH 4/7] Define siginfo_from_ancestor_ns()
	 [PATCH 5/7] Protect cinit from unblocked SIG_DFL signals
	 [PATCH 6/7] Protect cinit from blocked fatal signals
	 [PATCH 7/7] SI_USER: Masquerade si_pid when crossing pid ns boundary

Changelog[v6]:

	- Patches 3,4: Have kill_pid_info_as_uid() pass in 'from_ancestor_ns'
	  parameter to __send_signal() and remove SI_ASYNCIO check in
	  siginfo_from_user().
	- Patches 4,6: Update changelog and simplify code

Changelog[v5]:
	- Patch 2/6: Remove SIG_IGN check in sig_task_ignored() and let
	  sig_handler_ignored() check SIG_IGN.
        - Patch 3/6. Put siginfo_from_ancestor_ns() back under CONFIG_PID_NS
	  and remove warning in rt_sigqueueinfo().
	- (Patch 5/6)Simplify check in get_signal_to_deliver()
	- (Patch 6/6)Simplify masquerading pid
	- LTP-20081219-intermediate showed no new errors on 2.6.28-rc5-mm2.

Changelog[v4]:
	- [Bugfix] Patch 3/7. Check ns == NULL in siginfo_from_ancestor_ns().
	  Although http://lkml.org/lkml/2008/12/16/502 makes it less likely
	  that ns == NULL, looks like an explicit check won't hurt ?
	- Remove SIGNAL_UNKILLABLE_FROM_NS flag and simplify logic as
	  suggested by Oleg Nesterov.
	- Dropped patch that set SIGNAL_UNKILLABLE_FROM_NS and set
	  SIGNAL_UNKILLABLE in patch 5/7 to be bisect-safe.
	- Add a warning in rt_sigqueueinfo() if SI_ASYNCIO is used
	  (patch 3/7)
	- Added two patches (6/7 and 7/7) to masquerade si_pid for
	  SI_USER and SI_TKILL


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

TODO:
	- Add a check in fs/proc/array.c:task_sig() to include SIG_DFL
	  signals from same namespace in 'ignored signals' set for
	  container/global init.


Limitations/side-effects of current design

	- Container-init is immune to suicide - kill(getpid(), SIGKILL) is
	  ignored. Use exit() :-)
