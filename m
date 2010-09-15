From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/8] sysvshm: report error on failure to reattach,
	avoid crash
Date: Tue, 14 Sep 2010 19:55:03 -0700
Message-ID: <20100915025502.GG8957@count0.beaverton.ibm.com>
References: <1284494530-25946-1-git-send-email-ntl@pobox.com>
	<1284494530-25946-3-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1284494530-25946-3-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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

On Tue, Sep 14, 2010 at 03:02:04PM -0500, Nathan Lynch wrote:
> If ipcshm_restore fails to look up the file object for the region
> being restored, it should return the error to its caller and not
> proceed to dereference the file pointer.
> 
> Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>

(Important fix. Adding Oren to Cc)

Reviewed-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> ---
>  ipc/shm.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/ipc/shm.c b/ipc/shm.c
> index eed4b9a..1ba9193 100644
> --- a/ipc/shm.c
> +++ b/ipc/shm.c
> @@ -334,7 +334,7 @@ int ipcshm_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
> 
>  	file = ckpt_obj_fetch(ctx, h->ino_objref, CKPT_OBJ_FILE);
>  	if (IS_ERR(file))
> -		PTR_ERR(file);
> +		return PTR_ERR(file);

Odd that the original code didn't trigger any unused result or must check
warnings. In linux/err.h I already see:

	static inline long __must_check PTR_ERR(const void *ptr)
	...

And in linux/compiler-gcc3.h
	if __GNUC_MINOR__ >= 4
	#define __must_check            __attribute__((warn_unused_result))
	#endif

or for those of us using GCC 4.x (linux/compiler-gcc4.h):
	#define __must_check            __attribute__((warn_unused_result))

and in my .config I have:
	CONFIG_SYSVIPC=y
	CONFIG_SYSVIPC_CHECKPOINT=y
	...
	CONFIG_ENABLE_MUST_CHECK=y

plus a simple test:

	#include <stdlib.h>

	static inline void * __attribute__((warn_unused_result)) foo(void)
	{
		return NULL;
	}

	int main (void)
	{
		if (0)
			foo();
		return 0;
	}

even without -Wall triggers the compiler warning just fine. So I can't
see why the warning is not triggering.

Cheers,
	-Matt
