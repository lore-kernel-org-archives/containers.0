From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: [PATCH 1/1] introduce user_ns inheritance in user-sched
Date: Fri, 20 Mar 2009 21:46:39 -0500
Message-ID: <20090321024639.GB21064@hallyn.com>
References: <20090319211615.GA18383@us.ibm.com> <1237537460.24626.32.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755937AbZCUCns@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1237537460.24626.32.camel@twins>
Sender: linux-kernel-owner@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, Linux Containers <containers@lists.osdl.org>, mingo@elte.hu, Bharata B Rao <bharata@linux.vnet.ibm.com>, lkml <linux-kernel@vger.kernel.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>
List-Id: containers.vger.kernel.org

Quoting Peter Zijlstra (peterz@infradead.org):
> On Thu, 2009-03-19 at 16:16 -0500, Serge E. Hallyn wrote:
> > In a kernel compiled with CONFIG_USER_SCHED=y, cpu shares are
> > allocated according to uid.  Shares are specifiable under
> > /sys/kernel/uids/<uid>/
> > 
> > In a kernel compiled with CONFIG_USER_NS=y, clone(2) with the
> > CLONE_NEWUSER flag creates a new user namespace, and the newly
> > cloned task will belong to uid 0 in the new user namespace.
> 
> We seem to be adding more and more stuff for USER_SCHED, is anybody
> actually using that cruft?
> 
> How far along with cgroups are we to fully simulate that behaviour?
> 
> I think if we have a capable cgroup based replacement for USER_SCHED we
> should axe it from the kernel, would save lots of code...

I didn't realize that was the plan.  Using PAM to move users
around cgroups?  If so, then yeah that would simplify quite a bit
of code.   Won't catch all setuid()s of course - I don't know
who uses USER_SCHED and if that would matter.

-serge
