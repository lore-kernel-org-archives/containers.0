From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: containerized syslog
Date: Sat, 13 Feb 2010 07:58:13 -0800
Message-ID: <20100213155813.GU3714@count0.beaverton.ibm.com>
References: <1265915683.19130.166.camel@Mercier.safe.ca>
	<20100211192952.GA20191@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100211192952.GA20191-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Feb 11, 2010 at 01:29:52PM -0600, Serge E. Hallyn wrote:
> Quoting Jean-Marc Pigeon (jmp-4qkeo2rQ0gg@public.gmane.org):
> > Hello,
> > 
> > 
> > > 
> > > Thanks Jean-Marc.  But this really isn't doing most of what I'd
> > > recommended in my last emails (both public and private.  In
> > > particular:
> > [....]	
> > > 
> > > syslog_ns should be moved into nsproxy and unshared with a
> > > separate clone(CLONE_SYSLOG);
> > 	This this not a problem.
> > 	My understanding a new clone flag was not an option
> > 	as we are short in CLONE flag.
> > 	No design nor arch problem if we set  CLONE_SYSLOG
> > 	to be 0x100000000  ?????
> > 
> > 	If moved in nsproxy what is the hook to
> > 	get the "current context". (used current_user_ns()
> > 	as it was in user_namespace).
> > 
> > 
> > [...]	
> > 
> > > That was why I suggested:
> > [...]
> > > >! 4. take a printk call like the iptables ones you want and turn
> > > >! int into nsprintk syscall.
> > > >! 
> > 
> > 	If my understanding is right you propose to use a
> > 	special nsprintk to be used by iptable such
> > 	we can send "packet log" in "container context"
> > 	Right?
> > 
> > 	Logic is weak.
> 
> No logic is irrefutable :)  Because:
> 
> > 	1)
> > 	The way I changed printk, so far, make of it a "de facto"
> > 	nsprintk. So when called from netfilter, nsprintk
> > 	is still stay in HOST: context. My understanding,
> 
> No, it could be called from the context of a task in any
> random container.

Your comments seem good. However, I do have an issue with the
idea of finding a single syslog corresponding to the netns for
a hypothetical printk in iptables.

What happens with:

/* in init_syslog_ns */
clone(CLONE_SYSLOG) /* syslog_ns 1 */
clone(CLONE_SYSLOG) /* syslog_ns 2 */
<do something with iptables in the netns which triggers a printk>

Even though that same printk is relevant to three "syslogs", it'll
only go to one, correct? If so, my feeling is that nsprintk
shouldn't take a syslog_ns directly. It should take some other
form of namespace and then write to the syslog of all the
nsproxies which share that namespace (a netns in this case).

Cheers,
	-Matt Helsley
