From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] Syslog are now containerized
Date: Sat, 13 Feb 2010 10:26:57 -0800
Message-ID: <20100213182657.GZ3714@count0.beaverton.ibm.com>
References: <201002110552.o1B5qwbL024561@kernel.safe.ca>
	<20100211174843.GF6884@us.ibm.com>
	<20100213181158.GY3714@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100213181158.GY3714-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sat, Feb 13, 2010 at 10:11:58AM -0800, Matt Helsley wrote:
> On Thu, Feb 11, 2010 at 11:48:43AM -0600, Serge E. Hallyn wrote:
> > Quoting Jean-Marc Pigeon (jmp-4qkeo2rQ0gg@public.gmane.org):
> > > 	Added syslog.c such container /proc/kmsg and host /proc/kmsg
> > > 	do not leak in each other.
> > > 	Running rsyslog daemon within a container won't destroy
> > > 	host kernel messages.
> > 
> > Thanks Jean-Marc.  But this really isn't doing most of what I'd
> > recommended in my last emails (both public and private.  In
> > particular:
> > 
> > > index cc4f453..3d0c73e 100644
> > > --- a/include/linux/user_namespace.h
> > > +++ b/include/linux/user_namespace.h
> > > @@ -14,6 +14,7 @@ struct user_namespace {
> > >  	struct hlist_head	uidhash_table[UIDHASH_SZ];
> > >  	struct user_struct	*creator;
> > >  	struct work_struct	destroyer;
> > > +	struct syslog_ns        *syslog;
> > 
> > syslog_ns should be moved into nsproxy and unshared with a
> > separate clone(CLONE_SYSLOG);
> 
> I agree. Keeping it in the user_namespace is strange. It should
> be in the nsproxy along with all of the other namespace pointers.
> 
> > 
> > > -static void emit_log_char(char c)
> > > +static void emit_log_char(struct syslog_ns *syslog_ns, char c)
> > >  {
> > > -	LOG_BUF(log_end) = c;
> > > -	log_end++;
> > > -	if (log_end - log_start > log_buf_len)
> > > -		log_start = log_end - log_buf_len;
> > > -	if (log_end - con_start > log_buf_len)
> > > -		con_start = log_end - log_buf_len;
> > > -	if (logged_chars < log_buf_len)
> > > -		logged_chars++;
> > > +	LOG_BUF(syslog_ns, sys_log_end) = c;
> > 
> > Taking syslog_ns from current in emit_log_char is not right.
> > Emit_log_char() is called from printk which (the comment above
> > printk warns us) can be called from any context.
> > 
> > That was why I suggested:
> > 
> > >! I think my patch is fundamentally wrong anyway:  we should not
> > >! use current's context at vprintk like i did.  We should use an
> > >! optional passed-in context from those callsites where we want to,
> > >! and default to init otherwise.  That means
> > >! 
> > >! 1. put the core of vprintk() into vnsprintk() which takes a syslog
> > >! namespace as argument
> > >! 
> > >! 2. make vprintk() a wrapper around vnsprintk() which passes in
> > >! init_syslog_ns to vnsprintk().  printk can remain unchanged.
> > >! 
> > >! 4. make nsprintk() a wrapper around vnsprintk() which takes a syslog
> > >! ns argument and pass it to vnsprintk()
> > >! 
> > >! 3. do_syslog() can obviously be containerized the same way it
> > >! is now.
> > >! 
> > >! 4. take a printk call like the iptables ones you want and turn
> > >! int into nsprintk syscall.
> 
> Definitely. Actually, I think we can go one step further and say that
> passing syslog_ns directly to nsprintk() is wrong too. It's wrong
> because we only know the namespace that's relevant to the printk
> contents -- and that won't usually be a syslog_ns.
> 
> Better to have the "find corresponding syslog_ns" logic inside
> nsprintk(). The great thing about doing it this way is if we
> ever decide to duplicate printk output to multiple containers it
> can be done inside nsprintk rather than doing a flag-day patch.

It's also easy to see that current's nsproxy won't always point to
the right namespace. Consider kernel threads that do "work" which
was initiated by a userspace task (e.g. a process doing a read on
an NFS file triggers rpc IO kthreads). Usually the relevant namespace
pointer will referenced from the kernel objects related to the work --
not "current" since that's the kernel thread. But those structures
don't reference nsproxies -- they refer to a netns for example. So
being able to obtain a syslog_ns from a netns is critical yet can't
rely on current.

Cheers,
	-Matt Helsley
