From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: updated x86_64 eclone() stub
Date: Fri, 04 Dec 2009 07:29:27 -0800
Message-ID: <1259940567.32391.4950.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

This more closely resembles what glibc does.

The last version had a push/popq %ebp.  But, after looking at the glibc
code, I believe this to be unnecessary on 64-bit.  Suka also pointed out
that we were neglecting to pull the subthread's function argument off
the stack.

I also changed the register being used  for the subthread variable to be
rax.  This is just to more closely resemble the glibc code.  It doesn't
hurt to use it this way mostly because we overwrite it for the exit
syscall anyway.

int eclone(long flags_low, struct clone_args *clone_args, long args_size,
                 int *pids)
{
        long retval;

        __asm__  __volatile__(
                 "movq %5, %%r10\n\t"   /* pids in r10*/
                 "syscall\n\t"          /* Linux/x86_64 system call */
                 "testq %0,%0\n\t"      /* check return value */
                 "jne 1f\n\t"           /* jump if parent */
                 "popq %%rax\n\t"       /* get subthread function */
                 "popq %%rdi\n\t"       /* get the subthread function arg */
                 "call *%%rax\n\t"      /* start subthread function */
                 "movq %6,%0\n\t"
                 "syscall\n"            /* exit system call: exit subthread */
                 "1:\n\t"
                :"=a" (retval)
                :"0" (__NR_clone3),/* eax */
                 "D" (flags_low),  /* rdi */
                 "S" (clone_args), /* rsi */
                 "d" (args_size),  /* rdx */
                 "m" (pids),       /* gets moved to r10 */
                 "i" (__NR_exit)
                :"rbx", "rcx", "r8", "r9", "r10"
        );

        if (retval < 0) {
                errno = -retval;
                retval = -1;
        }
        return retval;
}

-- Dave
