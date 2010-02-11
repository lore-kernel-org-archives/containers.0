From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: containerized syslog
Date: Thu, 11 Feb 2010 13:29:52 -0600
Message-ID: <20100211192952.GA20191@us.ibm.com>
References: <1265915683.19130.166.camel@Mercier.safe.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Resent-Message-ID: <20100211193253.GA20422-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Resent-To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1265915683.19130.166.camel-4BUXZ/Ty1v7iqR6jatDSCA@public.gmane.org>
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
List-Id: containers.vger.kernel.org

Quoting Jean-Marc Pigeon (jmp-4qkeo2rQ0gg@public.gmane.org):
> Hello,
> 
> 
> > 
> > Thanks Jean-Marc.  But this really isn't doing most of what I'd
> > recommended in my last emails (both public and private.  In
> > particular:
> [....]	
> > 
> > syslog_ns should be moved into nsproxy and unshared with a
> > separate clone(CLONE_SYSLOG);
> 	This this not a problem.
> 	My understanding a new clone flag was not an option
> 	as we are short in CLONE flag.
> 	No design nor arch problem if we set  CLONE_SYSLOG
> 	to be 0x100000000  ?????
> 
> 	If moved in nsproxy what is the hook to
> 	get the "current context". (used current_user_ns()
> 	as it was in user_namespace).
> 
> 
> [...]	
> 
> > That was why I suggested:
> [...]
> > >! 4. take a printk call like the iptables ones you want and turn
> > >! int into nsprintk syscall.
> > >! 
> 
> 	If my understanding is right you propose to use a
> 	special nsprintk to be used by iptable such
> 	we can send "packet log" in "container context"
> 	Right?
> 
> 	Logic is weak.

No logic is irrefutable :)  Because:

> 	1)
> 	The way I changed printk, so far, make of it a "de facto"
> 	nsprintk. So when called from netfilter, nsprintk
> 	is still stay in HOST: context. My understanding,

No, it could be called from the context of a task in any
random container.

-serge
