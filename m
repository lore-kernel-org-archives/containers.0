From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/5] user-cr: align powerpc sp for eclone, clean up
	__eclone
Date: Wed, 16 Dec 2009 20:29:25 -0800
Message-ID: <20091217042925.GC30702@count0.beaverton.ibm.com>
References: <1259989351-28552-1-git-send-email-ntl@pobox.com>
	<1259989351-28552-3-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1259989351-28552-3-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Dec 04, 2009 at 11:02:28PM -0600, Nathan Lynch wrote:
> Using genstack in nsexeccwp exposed this bug.  The child_stack value
> being passed to the kernel via clone_args was not properly aligned,
> causing the child function to access the guard page.
> 
> And it turns out we needn't pass child_sp [r4] to the __eclone wrapper
> at all, so remove it.
> 
> Finally, the flags value as passed to __eclone in r4 is not used after the
> system call, so there is no need to save it in a nonvolatile register
> (r29).
> 
> Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
> ---
>  clone_ppc.c  |   12 ++++++++----
>  clone_ppc_.S |   40 ++++++++++++++++------------------------
>  2 files changed, 24 insertions(+), 28 deletions(-)
> 
> diff --git a/clone_ppc.c b/clone_ppc.c
> index 47b8290..f047a9e 100644
> --- a/clone_ppc.c
> +++ b/clone_ppc.c
> @@ -25,7 +25,6 @@
>  #include "eclone.h"
> 
>  extern int __eclone(int (*fn)(void *arg),
> -		    void *child_sp,
>  		    int flags,
>  		    void *fn_arg,
>  		    struct clone_args *args,
> @@ -39,9 +38,15 @@ int eclone(int (*fn)(void *), void *fn_arg, int clone_flags_low,
>  	unsigned long child_sp;
>  	int newpid;
> 
> +	/* The stack pointer for the child is communicated to the
> +	 * kernel via clone_args.child_stack, and to the __eclone
> +	 * assembly wrapper via the child_sp argument [r4].  So we
> +	 * need to align child_sp here and ensure that the wrapper and
> +	 * the kernel receive the same value.
> +	 */
>  	if (clone_args->child_stack)
> -		child_sp = clone_args->child_stack +
> -			clone_args->child_stack_size - 1;
> +		child_sp = (clone_args->child_stack +
> +			    clone_args->child_stack_size - 1) & ~0xf;
>  	else
>  		child_sp = 0;
> 
> @@ -50,7 +55,6 @@ int eclone(int (*fn)(void *), void *fn_arg, int clone_flags_low,
>  	my_args.child_stack_size = 0;
> 
>  	newpid = __eclone(fn,
> -			  (void *)child_sp,
>  			  clone_flags_low,
>  			  fn_arg,
>  			  &my_args,
> diff --git a/clone_ppc_.S b/clone_ppc_.S
> index ebc07f3..b7e50e3 100644
> --- a/clone_ppc_.S
> +++ b/clone_ppc_.S
> @@ -20,12 +20,11 @@
>  #endif
> 
>  /* int [r3] eclone(int (*fn)(void *arg) [r3],
> - *                          void *child_sp [r4],
> - *                          int flags [r5],
> - *                          void *fn_arg [r6],
> - *                          struct clone_args *args [r7],
> - *                          size_t args_size [r8],
> - *                          pid_t *pids [r9]);
> + *                          int flags [r4],
> + *                          void *fn_arg [r5],
> + *                          struct clone_args *args [r6],
> + *                          size_t args_size [r7],
> + *                          pid_t *pids [r8]);
>   * Creates a child task with the pids specified by pids.
>   * Returns to parent only, child execution and exit is handled here.
>   * On error, returns negated errno.  On success, returns the pid of the child
> @@ -40,25 +39,18 @@ __eclone:
>  	/* Set up parent's stack frame. */
>  	stwu	r1,-32(r1)
> 
> -	/* Save non-volatiles (r28-r31) which we plan to use. */
> -	stmw	r28,16(r1)
> +	/* Save non-volatiles (r30-r31) which we plan to use. */
> +	stmw	r30,16(r1)
> 
> -	/* Set up child's stack frame. */
> -	clrrwi	r4,r4,4
> -	li	r0,0
> -	stw	r0,-16(r4)

Am I correct that this is was clearing the "last" backchain pointer?
I guess we're assuming the mmap'd areas of the genstack APIs are filled
with 0s then. If that's the case then, strictly speaking, the genstack
patches should precede this one.

Otherwise omitting child_sp looks good.

> -
> -	/* Save fn, stack pointer, flags, and fn_arg across system call. */
> -	mr	r28,r3
> -	mr	r29,r4
> -	mr	r30,r5
> -	mr	r31,r6
> +	/* Save fn and fn_arg across system call. */
> +	mr	r30,r3
> +	mr	r31,r5
> 
>  	/* Set up arguments for system call. */
> -	mr	r3,r5	/* flags */
> -	mr	r4,r7	/* clone_args */
> -	mr	r5,r8	/* clone_args' size */
> -	mr	r6,r9	/* pids */
> +	mr	r3,r4	/* flags */
> +	mr	r4,r6	/* clone_args */
> +	mr	r5,r7	/* clone_args' size */
> +	mr	r6,r8	/* pids */

Wouldn't it be possible to avoid some mr instructions above by re-arranging
the function arguments? Then you're just saving things in the two non-volatile
gprs before making the eclone syscall. I think this amounts to making the
prototype:

int [r3] eclone(int flags [r3],
		struct clone_args *args [r4],
		size_t args_size [r6],
		pid_t *pids [r7],
		int (*fn)(void *arg) [r8],
		void *fn_arg [r9]);

Cheers,
	-Matt Helsley
