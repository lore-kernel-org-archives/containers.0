From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 4/5] Protect cinit from fatal signals
Date: Tue, 2 Dec 2008 12:51:30 -0800
Message-ID: <20081202205130.GB20077@us.ibm.com>
References: <20081126034242.GA23120@us.ibm.com> <20081126034634.GD23238@us.ibm.com> <20081127010753.GB13545@wavehammer.waldi.eu.org> <20081201202112.GC12493@us.ibm.com> <20081202120606.GD1132@wavehammer.waldi.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753981AbYLBUxP@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081202120606.GD1132@wavehammer.waldi.eu.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Bastian Blank <bastian@waldi.eu.org>, oleg@redhat.com, ebiederm@xmission.com, roland@redhat.com, containers@lists.osdl.org, linux-kernel@vger.kernel.org, xemul@openvz.org
List-Id: containers.vger.kernel.org

First of, thanks for taking the time to review/comment.


Bastian Blank [bastian@waldi.eu.org] wrote:
| On Mon, Dec 01, 2008 at 12:21:12PM -0800, Sukadev Bhattiprolu wrote:
| > Container-inits are special in some ways and this change requires SIGKILL
| > to terminate them.
| 
| No. They have are not special from the outside namespace.


I agree that they should not be. But they are special today in at least one
respect - terminating a container-init will terminate all processes in the
container even those that are in unrelated process groups.

Secondly, a poorly written container-inits can take the entire container down,
So we expect that container-inits to handle/ignore all signals rather than
SIG_DFL them. Current global inits do that today and container-inits should
too. It does not look like an unreasonable requirement.
  
If container-inits do not properly handle signals, it is appearing that
we need to make a trade-off in terms of semantics/complexity. See
following URL for the history.

https://lists.linux-foundation.org/pipermail/containers/2008-November/013991.html

So the basic requirements are:

	- container-init receives/processes all signals from ancestor namespace.
	- container-init ignores fatal signals from own namespace.

We are simplifying the first to say that:

	- parent-ns must have a way to terminate container-init
	- cinit will ignore SIG_DFL signals that may terminate cinit even if
	  they come from parent ns

| 
| Also it was discussed to use pid namespaces to preserve the local pid of
| a process during snapshot/restore. This means that every process may get
| the state of a container-init. And then it is not longer a wise idea to
| make them behave different from the outside.

The one change in the state of the process I see is if someone relies on
following fields from /proc/<pid>/status

	SigPnd: 0000000000000000
	ShdPnd: 0000000000000000
	SigBlk: 0000000000000000
	SigIgn: 0000000000000000
	SigCgt: 0000000000000000

to decide if they can send, say SIGUSR1, to terminate the process. If
they do, they maybe in for a surprise. But if the container-init properly
handles/ignores signals, this info will be consistent. 

Yes its not ideal and yes, the semantic change described above is a trade-off.
We are trying to find out if this change is unreasonable or will break
something really bad way.
