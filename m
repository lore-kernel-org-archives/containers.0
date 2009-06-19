From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] clone_with_pids: define the s390 syscall
Date: Fri, 19 Jun 2009 10:13:41 -0500
Message-ID: <20090619151341.GC22381@us.ibm.com>
References: <20090615170443.GA14808@us.ibm.com>
	<20090615170524.GA14950@us.ibm.com>
	<20090615171645.GA15217@us.ibm.com>
	<20090619131622.3193472d@skybase>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090619131622.3193472d@skybase>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Martin Schwidefsky (schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org):
> Hi Serge,
> 
> On Mon, 15 Jun 2009 12:16:45 -0500
> "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> 
> > diff --git a/arch/s390/kernel/compat_wrapper.S b/arch/s390/kernel/compat_wrapper.S
> > index c2228b2..bf13315 100644
> > --- a/arch/s390/kernel/compat_wrapper.S
> > +++ b/arch/s390/kernel/compat_wrapper.S
> > @@ -1837,3 +1837,13 @@ sys_restore_wrapper:
> >  	lgfr	%r3,%r3			# int
> >  	llgfr	%r4,%r4			# unsigned long
> >  	jg	compat_sys_restore
> > +
> > +	.globl sys_clone_with_pids_wrapper
> > +sys_clone_with_pids_wrapper:
> > +	llgfr	%r2,%r2			# unsigned long
> > +	llgfr	%r3,%r3			# unsigned long
> > +	llgtr	%r4,%r4			# int *
> > +	llgtr	%r5,%r5			# int *
> > +	llgtr	%r6,%r6			# void *
> > +	llgtr	%r7,%r7			# void *
> > +	jg	compat_sys_clone_with_pids
> 
> This is incorrect. If you have a system call that takes 6 parameters
> you need to load/store the 6th parameter from the stack. Check out the
> futex system call wrapper. But before you do that see the next comment.
> 
> > diff --git a/arch/s390/kernel/process.c b/arch/s390/kernel/process.c
> > index a3acd8e..fa187bf 100644
> > --- a/arch/s390/kernel/process.c
> > +++ b/arch/s390/kernel/process.c
> > @@ -246,6 +246,25 @@ SYSCALL_DEFINE0(clone)
> >  		       parent_tidptr, child_tidptr);
> >  }
> > 
> > +SYSCALL_DEFINE0(clone_with_pids)
> > +{
> > +	struct pt_regs *regs = task_pt_regs(current);
> > +	unsigned long clone_flags;
> > +	unsigned long newsp;
> > +	int __user *parent_tidptr, *child_tidptr;
> > +	void __user *upid_setp;
> > +
> > +	clone_flags = regs->gprs[3];
> > +	newsp = regs->orig_gpr2;
> > +	parent_tidptr = (int __user *) regs->gprs[4];
> > +	child_tidptr = (int __user *) regs->gprs[5];
> > +	upid_setp = (void __user *) regs->gprs[7];
> > +	if (!newsp)
> > +		newsp = regs->gprs[15];
> > +	return do_fork_with_pids(clone_flags, newsp, regs, 0, parent_tidptr,
> > +			child_tidptr, upid_setp);
> > +}
> > +
> >  /*
> >   * This is trivial, and on the face of it looks like it
> >   * could equally well be done in user mode.
> 
> clone_with_pids is declared as system call with no paramters. In this
> case the system call wrapper is not needed (empty) and you have to do
> the compat conversion inside the system call. See sys32_clone.

Ah, I see, thanks.

So in that case, is it ok for me to just use gprs[7] to pass in the
upid_setp variable?

thanks,
-serge
