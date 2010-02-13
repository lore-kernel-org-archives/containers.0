From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] Syslog are now containerized
Date: Sat, 13 Feb 2010 12:36:10 -0800
Message-ID: <20100213203610.GA3714@count0.beaverton.ibm.com>
References: <201002110552.o1B5qwbL024561@kernel.safe.ca>
	<20100211174843.GF6884@us.ibm.com>
	<20100213181158.GY3714@count0.beaverton.ibm.com>
	<1266088499.19130.295.camel@Mercier.safe.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1266088499.19130.295.camel-4BUXZ/Ty1v7iqR6jatDSCA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jean-Marc Pigeon <jmp-4qkeo2rQ0gg@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sat, Feb 13, 2010 at 02:14:59PM -0500, Jean-Marc Pigeon wrote:
> Hello,
> 
> On Sat, 2010-02-13 at 10:11 -0800, Matt Helsley wrote:
> > On Thu, Feb 11, 2010 at 11:48:43AM -0600, Serge E. Hallyn wrote:
> > > Quoting Jean-Marc Pigeon (jmp-4qkeo2rQ0gg@public.gmane.org):
> > > > 	Added syslog.c such container /proc/kmsg and host /proc/kmsg
> > > > 	do not leak in each other.
> > > > 	Running rsyslog daemon within a container won't destroy
> > > > 	host kernel messages.
> > > 
> > > Thanks Jean-Marc.  But this really isn't doing most of what I'd
> > > recommended in my last emails (both public and private.  In
> > > particular:
> > > 
> > > > index cc4f453..3d0c73e 100644
> > > > --- a/include/linux/user_namespace.h
> > > > +++ b/include/linux/user_namespace.h
> > > > @@ -14,6 +14,7 @@ struct user_namespace {
> > > >  	struct hlist_head	uidhash_table[UIDHASH_SZ];
> > > >  	struct user_struct	*creator;
> > > >  	struct work_struct	destroyer;
> > > > +	struct syslog_ns        *syslog;
> > > 
> > > syslog_ns should be moved into nsproxy and unshared with a
> > > separate clone(CLONE_SYSLOG);
> > 
> > I agree. Keeping it in the user_namespace is strange. It should
> > be in the nsproxy along with all of the other namespace pointers.
> 	I won't argue on this, I put it in user_namespace as
> 	serge proposed it at first and code implementation
> 	was a test/trial to me.
> 	Setting syslog in nsproxy is fine to me (seems
> 	every body agree.. right?)

Good, thanks!

> [...]
> > 
> > Definitely. Actually, I think we can go one step further and say that
> > passing syslog_ns directly to nsprintk() is wrong too. It's wrong
> > because we only know the namespace that's relevant to the printk
> > contents -- and that won't usually be a syslog_ns.
> > 
> > Better to have the "find corresponding syslog_ns" logic inside
> > nsprintk(). The great thing about doing it this way is if we
> > ever decide to duplicate printk output to multiple containers it
> > can be done inside nsprintk rather than doing a flag-day patch.
> 
> 	I tend to agree with you Matt.
> 
> 	I strongly disagree about what I understand 
> 	about Serge proposal to add a "new printk".
> 
> 	What is the purpose of printk?
> 	- Report a system data to the acting authority.
> 
> 	Syslog cant be sent to:
> 	HOST: syslog
> 	CONT: syslog
> 	CONT: + HOST:  syslog (duplication)
> 	Decision to duplicate syslog can be a printk
> 	privilege, lets says "according message level".
> 
> 	Decision to send  to HOST: or CONT: syslog
> 	is depending execution context, which
> 	can be found back within the printk function
> 	itself (so no need to have ns_printk).
> 
> 	What is proposing Serge is to HARD CODE WITHIN kernel
> 	if we call the genuine printk or ns_printk, which
> 	is now a door wide open to coder interpretation ("is
> 	printk message containerised or not", my coding decision
> 	is as good as yours, and nobody will be satisfied).

I think it will be pretty clear from the code which is preferred,
printk or nsprintk. For example, output from the the various module
__init functions obviously does not belong in an nsprintk().

> 
> 	My proposal is to say, if a ressource is containerized
> 	it must be used in containerized context, this means
> 	all printk are called within the context anyway.

But that simply does not happen in all kernel code. Please see my
kernel thread point. Not all work happens in a "containerized
context". Same thing with the __init example above. It doesn't
matter which container caused the module to be loaded -- only
that the kernel has loaded it. So nsprintk() doesn't make sense
there, even though there is the initial namespace to use.

> 	What does that mean in real life?. lets call again the iptable
> 	example.
> 
> 	We already have a HOST: iptables set AND a CONT: iptables
> 	set. I have for my say, to keep consistency we MUST
> 	execute CONT: iptables rules checking within the CONT: context
> 	(which is not the case now... IMHO).

Enforcing this using "current" would require duplicating kernel
threads on a per-container basis. That's simply not going to fly
with the kernel community (and for good reason).

> 
> 	This approach is coherent, if a ressource (iptable,
> 	network device, file system,...) is defined AND managed within

It sounds reasonable except you're hand-waving alot of the complexity
away first.

> 	CONT: report must be done TO CONT: (period). Means
> 	coding level need to take care ONLY about 'ressource'
> 	ownership, if it is "own" by CONT:  then access it in its  
> 	CONT: context.

Tracking all of these accesses down and ensuring they are only done
from "its container context" is difficult or impossible. It's not as
easy as you seem to think. In some cases the same resource could be
shared between containers. Which should we access it from then?

> 	Keep in mind, A fully containerized system can be managed
> 	by someone with full privilege BUT NOT in charge of 
> 	the host itself (IE: without host access).

Sure. (We're not there yet but I think we'd like to get
there eventually.)

> 	My proposal is a clear cut, if a ressource is containerized 
> 	report to CONT: (containerized) syslog... no question ask.

That part of the proposal is simple and makes alot of sense. The
ramifcations of it on kernel code are not simple and often there's
no clean way to do it.

Have a look at the iptables code. I've been looking at it and the
way to make the various printks namespace-clean is far from obvious
without drastically changing the core data structures of iptables.
It's also not obvious that making them namespace clean is
really useful (as Eric seemed to imply). ipt_LOG.c and ipt_ULOG.c are
perhaps the best arguments for nsprintk() in iptables.

> 	(sure enough printk could duplicate message to HOST:
> 	 my guess it won't be really needed in practical life,
> 	 but I could be wrong....)

Yup.

Cheers,
	-Matt Helsley
