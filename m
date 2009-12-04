From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: updated x86_64 eclone() stub
Date: Fri, 04 Dec 2009 08:21:29 -0800
Message-ID: <1259943689.32391.5111.camel@nimitz>
References: <1259940567.32391.4950.camel@nimitz>
	<20091204160123.GJ2430@hawkmoon.kerlabs.com>
	<1259942713.32391.5061.camel@nimitz>
	<20091204160825.GL2430@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091204160825.GL2430-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
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

On Fri, 2009-12-04 at 17:08 +0100, Louis Rilling wrote:
> On 04/12/09  8:05 -0800, Dave Hansen wrote:
> > > syscall also destroys r11, so it should be added to the clobber list.
> > 
> > Even though it is a ptregscall?
> 
> The assembly instruction itself destroys r11 (same for rcx).

Thanks again for the help, Louis.  How does this look?

int clone_with_pids(long flags_low, struct clone_args *clone_args, long args_size,
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
                :"rcx", "r10", "r11", "cc" 
        );
        /*
         * glibc lists 'cc' as clobbered, so we might as
	 * well do it too.  'r11' and 'rcx' are clobbered
	 * by the 'syscall' instruction itself.  'r8' and
	 * 'r9' are clobbered by the clone, but that
	 * thread will exit before getting back out to C.
         */

        if (retval < 0) {
                errno = -retval;
                retval = -1;
        }
        return retval;
}



> Thanks,
> 
> Louis
> 
-- Dave
