From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] hijack: update task_alloc_security
Date: Mon, 3 Dec 2007 08:50:12 -0600
Message-ID: <20071203145012.GB9008__6231.84653600237$1196693618$gmane$org@sergelap.austin.ibm.com>
References: <474B78CB.5070607@au1.ibm.com> <474B7A51.3080300@au1.ibm.com>
	<474BB095.8080302@manicmethod.com>
	<1196174188.3925.32.camel@moss-spartans.epoch.ncsc.mil>
	<20071127154356.GA32362@sergelap.austin.ibm.com>
	<474D0188.2040600@crispincowan.com>
	<20071128145422.GC3820@sergelap.austin.ibm.com>
	<474E3E4E.3060908@crispincowan.com>
	<20071129153815.GA8140@sergelap.austin.ibm.com>
	<47520568.6030108@crispincowan.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <47520568.6030108-RL8T2ARnKKfZw9hOtrW0rA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Crispin Cowan <crispin-RL8T2ARnKKfZw9hOtrW0rA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Joshua Brindle <method-PzTJMJMxY2mwxnkjfAeQoA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Crispin Cowan (crispin-RL8T2ARnKKfZw9hOtrW0rA@public.gmane.org):
> Serge E. Hallyn wrote:
> > Quoting Crispin Cowan (crispin-RL8T2ARnKKfZw9hOtrW0rA@public.gmane.org):
> >   
> >> I find that ptrace, specifically CAP_SYS_PTRACE, is overloaded. AppArmor
> >> is having problems because we have to choose between granting
> >> cap_sys_ptrace, or not allowing the process to read /proc/pid/self &
> >> such like. So there, the problem is that we have to grant too much power
> >> to a process to just let it read some /proc stuff about itself.
> >>
> >> Here the problem appears to be the other way. cap_sys_ptrace is powerful
> >> enough to mess with other user's processes on the system, but if ptrace
> >> gives you hijack, then that seems to give you the power to control
> >> processes in someone else's namespace.
> >>     
> > The user namespace patchset I'm working on right now to start having
> > signals respect user namespaces introduces CAP_NS_OVERRIDE.  Once that
> > is in, then hijack would require CAP_NS_OVERRIDE|CAP_SYS_PTRACE.
> >
> > Of course, since we're considering only allowing HIJACK_NS which is
> > only allowed into a different namespace, hijack would then always
> > require CAP_NS_OVERRIDE...
> >
> > Does that suffice?
> >   
> I think that CAP_NS_OVERRIDE|CAP_SYS_PTRACE is a problem because of the

Oops, yeah I meant &.

> | making ptrace more powerful than it is now. If you make it
> CAP_NS_OVERRIDE only, then the problem goes away.

I was seeing CAP_NS_OVERRIDE as more of a modifier to other
capabilities.  So (CAP_NS_OVERRIDE&CAP_KILL) means you can
signal processes in another namespace.
(CAP_NS_OVERRIDE&CAP_DAC_OVERRIDE) means you can override (currently
nonexistent) DAC file access checks in another user namespace.
(CAP_NS_OVERRIDE&CAP_MKNOD) means you can create devices which your
container isn't allowed to create.

Yup, this is all somewhat looking ahead...

-serge
