From: Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>
Subject: Re: [PATCH 1/1] implement s390 clone_with_pids syscall
Date: Wed, 11 Nov 2009 14:19:38 -0600
Message-ID: <1257970778.7132.1364.camel@localhost.localdomain>
References: <20091110163708.GA19122@us.ibm.com>
	<1257924442.7132.467.camel@localhost.localdomain>
	<20091111144600.GA6925@us.ibm.com>
	<1257958793.7132.1068.camel@localhost.localdomain>
	<20091111183303.GA8761@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091111183303.GA8761-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

On Wed, 2009-11-11 at 12:33 -0600, Serge E. Hallyn wrote:
> Quoting Nathan Lynch (nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org):
> > On Wed, 2009-11-11 at 08:46 -0600, Serge E. Hallyn wrote:
> > > Quoting Nathan Lynch (nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org):
> > > > 
> > > > > +	parent_tid_ptr = (int *)kca.parent_tid_ptr;
> > > > > +	child_tid_ptr =  (int *)kca.child_tid_ptr;
> > > > > +
> > > > > +	stack_size = (unsigned long)kca.child_stack_size;
> > > > > +	child_stack = (unsigned long)kca.child_stack_base;
> > > > > +	if (child_stack)
> > > > > +		child_stack += stack_size;
> > > > 
> > > > Should this calculation not be of the form:
> > > > child_stack = arch_dependent_alignment(child_stack + stack_size - 1)
> > > > ?
> > > > 
> > > > Is overflow a concern?
> > > > 
> > > > Same questions apply to the x86 version.
> > > 
> > > Hmm...  if the stack isn't valid, the task will just segfault, so
> > > it's not dangerous for the kernel, right?  Note that for instance
> > > arch/s390/kernel/process.c:SYS_clone() doesn't check the validity
> > > of the new stack pointer passed in either.
> > 
> > clone expects the stack argument to be the desired value of the stack
> > pointer in the child.
> 
> And doesn't verify it.

That's not the point.  Garbage inputs will get garbage behavior with
either interface and that's fine.


> > cwp is different in that the clone_args struct
> > specifies the base and size of the region the child is to use for stack,
> > meaning that the kernel must derive from these a sane value for the
> > child's stack pointer (on every arch where the stack grows down).
> 
> And with regular clone, the kernel must expect userspace to do that
> calculation correctly!  Userspace always still has to do
> 	base = malloc(size);
> 	base += size - 1;
> 
> > Your current calculation results in an unaligned SP outside of the
> 
> Can you send the patch to align it properly? 

For powerpc I have
usp = _ALIGN_DOWN((stack_base + stack_sz - 1), 16);

Afraid I don't have s390 ABI docs at hand.  But my remarks were based on
the incorrect assumption that kca.child_stack_size conveys, well, the
stack size; see below.


> 
> > region that the caller has presumably allocated for the child stack.
> > How is that useful behavior?
> 
> It's useful because stack_size still gets passed through copy_process
> to the arch-dependent copy_thread().  That then mostly ignores the
> size, but in theory we could start tracking it.

Something I missed earlier is that the stack_size you are passing in
from user space is not actually the size of the stack.  It's adjusted to
account for arguments that have been placed at the end of the stack
region.  So stack_size becomes a value that you want the kernel to add
to stack_base to get the desired stack pointer value in the child --
it's not a size at all.  At this point we may as well communicate the
desired stack pointer value directly (which could be denoted by
stack_size == 0, or we could add another member to clone_args), or
rename stack_size to stack_offset or similar.
