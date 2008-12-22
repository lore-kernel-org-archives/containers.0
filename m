From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH 0/6][v3] Container-init signal semantics
Date: Mon, 22 Dec 2008 02:55:48 -0800
Message-ID: <m1wsds5vij.fsf@frodo.ebiederm.org>
References: <20081221005106.GA4912@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754131AbYLVK5V@vger.kernel.org>
In-Reply-To: <20081221005106.GA4912@us.ibm.com> (Sukadev Bhattiprolu's message
	of "Sat, 20 Dec 2008 16:51:06 -0800")
Sender: linux-kernel-owner@vger.kernel.org
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: oleg@redhat.com, ebiederm@xmission.com, roland@redhat.com, bastian@waldi.eu.org, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org, sukadev@us.ibm.com
List-Id: containers.vger.kernel.org

Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com> writes:

> This patchset implements the design/simplified semantics suggested by
> Oleg Nesterov.  The simplified semantics for container-init are:
>
> 	- container-init must never be terminated by a signal from a
> 	  descendant process.
>
> 	- container-init must never be immune to SIGKILL from an ancestor
> 	  namespace (so a process in parent namespace must always be able
> 	  to terminate a descendant container).
>
> 	- container-init may be immune to unhandled fatal signals (like
> 	  SIGUSR1) even if they are from ancestor namespace (SIGKILL is
> 	  the only reliable signal from ancestor namespace).

It sounds you are still struggling to get something that works and gets
done what needs to be done.  So let me suggest a simplified semantic that
should be easier to implement and test, and solves the biggest problem
that we must solve in the kernel.

- container-init ignores SIGKILL and SIGSTOP.

- container-init is responsible for setting the rest of the signals
  to SIG_IGN.

If that isn't enough for all of the init's we can go back and
solve more in kernel land.  That simplified semantic is certainly
enough for sysvinit.

> Limitations/side-effects of current design
>
> 	- Container-init is immune to suicide - kill(getpid(), SIGKILL) is
> 	  ignored. Use exit() :-)

That sounds like correct behavior.

Eric
