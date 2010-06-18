From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC] checkpoint: handle more siginfo->si_code values
Date: Fri, 18 Jun 2010 11:58:17 -0400
Message-ID: <4C1B9799.5040302@cs.columbia.edu>
References: <1276814259.6401.21.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1276814259.6401.21.camel@localhost>
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



On 06/17/2010 06:37 PM, Nathan Lynch wrote:
> I have a multithreaded testcase that easily hits the BUG() in
> fill_siginfo() by raise()'ing a signal it has blocked before
> checkpoint.  The value of si_code in this case is SI_TKILL.

Thanks for pointing out - this was indeed overlooked.

> 
> This gets my testcase to pass, but I'm not sure it's a complete
> solution...  comments?
> ---
>  kernel/signal.c |    8 ++++++--
>  1 files changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/signal.c b/kernel/signal.c
> index e4ca9a6..cd25592 100644
> --- a/kernel/signal.c
> +++ b/kernel/signal.c
> @@ -2919,6 +2919,9 @@ static void fill_siginfo(struct ckpt_siginfo *si, siginfo_t *info)
>  	si->_errno = info->si_errno;
>  	si->code = info->si_code;
>  
> +	if (info->si_code < 0)
> +		return;
> +

This means that we do not save (nor restore) additional state
related to signals from tkill() syscall, or from other kernel
generated signals.

For example -

---
static int do_tkill(pid_t tgid, pid_t pid, int sig)
{
        struct siginfo info;

        info.si_signo = sig;
        info.si_errno = 0;
        info.si_code = SI_TKILL;
        info.si_pid = task_tgid_vnr(current);
        info.si_uid = current_uid();

        return do_send_specific(tgid, pid, sig, &info);
}
---

In this case, we lose the values of @si_pid and @si_uid fields.

The correct solution would be to examine each si_code < 0 and
add to the switch() statements (both checkpoint and restart)
to save/restart the additional information. (If it does not
carry more info, then add to the switch and do nothing).

>  	/* TODO: convert info->si_uid to uid_objref */
>  
>  	switch (info->si_code & __SI_MASK) {
> @@ -2953,7 +2956,8 @@ static void fill_siginfo(struct ckpt_siginfo *si, siginfo_t *info)
>  		si->sigval_ptr = (unsigned long) info->si_ptr;
>  		break;
>  	default:
> -		BUG();
> +		ckpt_debug("unknown si_code 0x%x\n", info->si_code);
> +		break;

The reason I put a BUG there, is to make a kernel bug visible...
and it surely worked :)

>  	}
>  }
>  
> @@ -3002,7 +3006,7 @@ static int load_siginfo(siginfo_t *info, struct ckpt_siginfo *si)
>  		info->si_ptr = (void __user *) (unsigned long) si->sigval_ptr;
>  		break;
>  	default:
> -		return -EINVAL;
> +		break;

Nack. This will allow users to inject arbitrary values here (at
the moment it's probably harmless, I think, but the kernel could
rely on values there).

Instead, let's add the missing si_code values explicitly to the
switch statement.

Thanks,

Oren.
