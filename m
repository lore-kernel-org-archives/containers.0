From: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/1] introduce user_ns inheritance in user-sched
Date: Sun, 22 Mar 2009 13:30:55 +0530
Message-ID: <20090322080055.GA4274@linux.vnet.ibm.com>
References: <20090319211615.GA18383@us.ibm.com> <1237537460.24626.32.camel@twins> <20090321024639.GB21064@hallyn.com> <1237635409.4667.186.camel@laptop>
Reply-To: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753733AbZCVICM@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1237635409.4667.186.camel@laptop>
Sender: linux-kernel-owner@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Serge E. Hallyn" <serge@hallyn.com>, "Serge E. Hallyn" <serue@us.ibm.com>, Linux Containers <containers@lists.osdl.org>, mingo@elte.hu, Bharata B Rao <bharata@linux.vnet.ibm.com>, lkml <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

On Sat, Mar 21, 2009 at 12:36:49PM +0100, Peter Zijlstra wrote:
> On Fri, 2009-03-20 at 21:46 -0500, Serge E. Hallyn wrote:
> > Quoting Peter Zijlstra (peterz@infradead.org):
> > > On Thu, 2009-03-19 at 16:16 -0500, Serge E. Hallyn wrote:
> > > > In a kernel compiled with CONFIG_USER_SCHED=y, cpu shares are
> > > > allocated according to uid.  Shares are specifiable under
> > > > /sys/kernel/uids/<uid>/
> > > > 
> > > > In a kernel compiled with CONFIG_USER_NS=y, clone(2) with the
> > > > CLONE_NEWUSER flag creates a new user namespace, and the newly
> > > > cloned task will belong to uid 0 in the new user namespace.
> > > 
> > > We seem to be adding more and more stuff for USER_SCHED, is anybody
> > > actually using that cruft?
> > > 
> > > How far along with cgroups are we to fully simulate that behaviour?
> > > 
> > > I think if we have a capable cgroup based replacement for USER_SCHED we
> > > should axe it from the kernel, would save lots of code...
> > 
> > I didn't realize that was the plan.  Using PAM to move users
> > around cgroups? 
> 
> Right, thing is, distro's will all want cgroup enabled, since that's the
> latest fad :-), so this user sched thing will only be for people who
> build their own kernels -- but I suspect most of those simply disable
> all this group scheduling.
> 

But if they do not, then the behavior is wrong now, and I would prefer
it to be fixed, which is why this patch.

> >  If so, then yeah that would simplify quite a bit
> > of code.   Won't catch all setuid()s of course 
> 
> Right, so if we could somehow get a setuid notification hooked into
> cgroups,.. not sure that would be worth the trouble though.
> 

Does anyone really care about uid based grouping? (I do realize the
userspace daemon classifies on the basis of uids as of now, but still,
how many use cases really want uid based grouping as opposed to process
type (as in browser, compiler..) type of grouping)

> > - I don't know who uses USER_SCHED and if that would matter.
> 
> Right, me neither... I would just love to be able to cut all that code
> out :-)
> 

me too :)

-- 
regards,
Dhaval
