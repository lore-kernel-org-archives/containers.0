From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 0/6][v3] Container-init signal semantics
Date: Mon, 22 Dec 2008 11:47:37 -0800
Message-ID: <20081222194737.GC9085@us.ibm.com>
References: <20081221005106.GA4912@us.ibm.com> <m1wsds5vij.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754910AbYLVTtU@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1wsds5vij.fsf@frodo.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: oleg@redhat.com, roland@redhat.com, bastian@waldi.eu.org, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org, sukadev@us.ibm.com
List-Id: containers.vger.kernel.org

Eric W. Biederman [ebiederm@xmission.com] wrote:
| Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com> writes:
| 
| > This patchset implements the design/simplified semantics suggested by
| > Oleg Nesterov.  The simplified semantics for container-init are:
| >
| > 	- container-init must never be terminated by a signal from a
| > 	  descendant process.
| >
| > 	- container-init must never be immune to SIGKILL from an ancestor
| > 	  namespace (so a process in parent namespace must always be able
| > 	  to terminate a descendant container).
| >
| > 	- container-init may be immune to unhandled fatal signals (like
| > 	  SIGUSR1) even if they are from ancestor namespace (SIGKILL is
| > 	  the only reliable signal from ancestor namespace).
| 
| It sounds you are still struggling to get something that works and gets
| done what needs to be done.  So let me suggest a simplified semantic that
| should be easier to implement and test, and solves the biggest problem
| that we must solve in the kernel.
| 
| - container-init ignores SIGKILL and SIGSTOP.

Yes.

| 
| - container-init is responsible for setting the rest of the signals
|   to SIG_IGN.

Oleg pointed out that we could drop SIG_DFL signals to global init early
to ensure wait_for_completion_killable/lock_page_killable don't incorrectly
believe that a fatal signal is pending. (patch 2/6).

If that patch is valid regardless of containers, it would be a minor
extension to get container-inits to drop SIG_DFL signals too, right ?

So the bigger problem/unknown for me is the sig_from_user() in patch 4/6
(i.e determining if it safe to deref the pid-ns of sender). We went from
!in_interrupt() to the SIG_FROM_USER flag to this.

If that is correct, I am hoping it would come down to opitmizing the code
if possible (eg: can/should we avoid passing same_ns into sig_ignored()

There is probably some ugliness :-) but do you see any other correctness 
issues ?
