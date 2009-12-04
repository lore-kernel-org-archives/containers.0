From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: updated x86_64 eclone() stub
Date: Fri, 04 Dec 2009 08:05:13 -0800
Message-ID: <1259942713.32391.5061.camel@nimitz>
References: <1259940567.32391.4950.camel@nimitz>
	<20091204160123.GJ2430@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091204160123.GJ2430-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
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
Cc: containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 2009-12-04 at 17:01 +0100, Louis Rilling wrote:
> On 04/12/09  7:29 -0800, Dave Hansen wrote:
> > This more closely resembles what glibc does.
> > 
> > The last version had a push/popq %ebp.  But, after looking at the glibc
> > code, I believe this to be unnecessary on 64-bit.  Suka also pointed out
> > that we were neglecting to pull the subthread's function argument off
> > the stack.
> > 
> > I also changed the register being used  for the subthread variable to be
> > rax.  This is just to more closely resemble the glibc code.  It doesn't
> > hurt to use it this way mostly because we overwrite it for the exit
> > syscall anyway.
> > 
> > int eclone(long flags_low, struct clone_args *clone_args, long args_size,
> >                  int *pids)
> > {
> >         long retval;
> > 
> >         __asm__  __volatile__(
> >                  "movq %5, %%r10\n\t"   /* pids in r10*/
> >                  "syscall\n\t"          /* Linux/x86_64 system call */
> >                  "testq %0,%0\n\t"      /* check return value */
> >                  "jne 1f\n\t"           /* jump if parent */
> >                  "popq %%rax\n\t"       /* get subthread function */
> >                  "popq %%rdi\n\t"       /* get the subthread function arg */
> >                  "call *%%rax\n\t"      /* start subthread function */
> >                  "movq %6,%0\n\t"
> >                  "syscall\n"            /* exit system call: exit subthread */
> >                  "1:\n\t"
> >                 :"=a" (retval)
> >                 :"0" (__NR_clone3),/* eax */
> >                  "D" (flags_low),  /* rdi */
> >                  "S" (clone_args), /* rsi */
> >                  "d" (args_size),  /* rdx */
> >                  "m" (pids),       /* gets moved to r10 */
> >                  "i" (__NR_exit)
> >                 :"rbx", "rcx", "r8", "r9", "r10"
> 
> Why is rbx in the clobber list? It's not used at all.

Because I forgot to take it out when I removed the popq into rbx. :)

> r8 and r9 can be removed from the clobber list, since they can only be clobbered
> when calling the subthread, and then exit() is called without returning to C.

OK, that makes sense.

> syscall also destroys r11, so it should be added to the clobber list.

Even though it is a ptregscall?

> Libc also adds "cc" to the clobber list. I'm not sure that this matters though.

I guess it can't hurt.  I'll add a comment about it.

-- Dave
