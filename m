From: Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>
Subject: Re: [PATCH 1/1] implement s390 clone_with_pids syscall
Date: Wed, 11 Nov 2009 10:59:53 -0600
Message-ID: <1257958793.7132.1068.camel@localhost.localdomain>
References: <20091110163708.GA19122@us.ibm.com>
	<1257924442.7132.467.camel@localhost.localdomain>
	<20091111144600.GA6925@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091111144600.GA6925-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 2009-11-11 at 08:46 -0600, Serge E. Hallyn wrote:
> Quoting Nathan Lynch (nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org):
> > 
> > > +	parent_tid_ptr = (int *)kca.parent_tid_ptr;
> > > +	child_tid_ptr =  (int *)kca.child_tid_ptr;
> > > +
> > > +	stack_size = (unsigned long)kca.child_stack_size;
> > > +	child_stack = (unsigned long)kca.child_stack_base;
> > > +	if (child_stack)
> > > +		child_stack += stack_size;
> > 
> > Should this calculation not be of the form:
> > child_stack = arch_dependent_alignment(child_stack + stack_size - 1)
> > ?
> > 
> > Is overflow a concern?
> > 
> > Same questions apply to the x86 version.
> 
> Hmm...  if the stack isn't valid, the task will just segfault, so
> it's not dangerous for the kernel, right?  Note that for instance
> arch/s390/kernel/process.c:SYS_clone() doesn't check the validity
> of the new stack pointer passed in either.

clone expects the stack argument to be the desired value of the stack
pointer in the child.  cwp is different in that the clone_args struct
specifies the base and size of the region the child is to use for stack,
meaning that the kernel must derive from these a sane value for the
child's stack pointer (on every arch where the stack grows down).

Your current calculation results in an unaligned SP outside of the
region that the caller has presumably allocated for the child stack.
How is that useful behavior?
