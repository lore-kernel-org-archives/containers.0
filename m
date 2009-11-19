From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH] clone_with_pids()^w eclone() for x86_64
Date: Thu, 19 Nov 2009 09:48:49 -0800
Message-ID: <1258652929.20093.8941.camel@nimitz>
References: <20091119004838.AD278DE0@kernel>
	<20091119095844.GP4379@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091119095844.GP4379-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 2009-11-19 at 10:58 +0100, Louis Rilling wrote:
> > int clone_with_pids(long flags_low, struct clone_args *clone_args, long args_size,
> >                  int *pids)
> > {
> >         long retval;
> > 
> >         __asm__  __volatile__(
> >                  "movq %3, %%r10\n\t"           /* pids in r10*/
> >                  "pushq %%rbp\n\t"              /* save value of ebp */
> >                 :
> >                 :"D" (flags_low), /* rdi */
> >                  "S" (clone_args),/* rsi */
> >                  "d" (args_size), /* rdx */
> >                  "a" (pids)       /* use rax, which gets moved to r10 */
> >                 );
> 
> 1. The fourth C arg is not in rax, but in rcx.

Hey Louis,

So, try as I might, I couldn't get that to work.  I thought it was rcx,
too.

So, changing that instruction to:

                "movq %3, %%rcx\n\t"           /* pids in r10*/

and putting 0x11111, etc... in for the args the strace output for the
syscall looks like this:

        syscall_299(0x11111, 0x22222, 0x33333, 0x1, 0x1, 0x2, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0) = -1 (errno 22)

and I get -EFAULT back from the function doing the copy_from_user() of
the pids argument, even when using good values.

If I use the asm posted above, I get this:
        
        syscall_299(0x11111, 0x22222, 0x33333, 0x44444, 0x1, 0x2, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0) = -1 (errno 22)
        
Or, this from a real call:
        
        syscall_299(0x1100011, 0x7fff19f0fd40, 0x38, 0x602070, 0x1, 0x2,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0[2992, 377]: Child:
        
I had to find r10 basically by trial and error.  I have no idea why it
works.

> > 
> >         __asm__ __volatile__(
> >                  "syscall\n\t"  /* Linux/x86_64 system call */
> >                  "testq %0,%0\n\t"      /* check return value */
> >                  "jne 1f\n\t"           /* jump if parent */
> >                  "popq %%rbx\n\t"       /* get subthread function */
> >                  "call *%%rbx\n\t"      /* start subthread function */
> >                  "movq %2,%0\n\t"
> >                  "syscall\n"            /* exit system call: exit subthread */
> >                  "1:\n\t"
> >                  "popq %%rbp\t"         /* restore parent's ebp */
> >                 :"=a" (retval)
> >                 :"0" (__NR_clone3), "i" (__NR_exit)
> >                 :"ebx", "ecx", "edx"
> >                 );
> 
> 2. You should probably not separate this into two asm statements. In particular,
>    the compiler has no way to know that r10 should be preserved between the two
>    statements, and may be confused by the change of rsp.

Yeah, I wondered about that.  Suka, we should probably fix your tests
and the i386 code, too.

> 3. r10 and r11 should be listed as clobbered.

D'oh!  I didn't even touch the bottom registers because it continued to
work from the i386 version that I stole from Suka.  

> 4. I fail to see the magic that puts the subthread function pointer in the
>    stack.
> 
> 5. Maybe rdi should contain the subthread argument before calling the subthread?
> 
> 6. rdi, rsi, rdx, rcx, r8 and r9 should be added to the clobber list because of
>    the call to the subthread function.
> 
> 7. rsi could be used in place of rbx to hold the function pointer, which would
>    allow you to remove ebx from the clobber list.
> 
> 8. I don't see why rbp should be saved. The ABI says it must be saved by the
>    callee.
> 
> 9. Before calling exit(), maybe put some exit code in rdi?

Thanks for looking through this, Louis.  I'll send out another version
in a bit.

-- Dave
