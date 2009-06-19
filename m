From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/1] mktree: use clone_with_pid on s390
Date: Fri, 19 Jun 2009 02:56:14 -0400
Message-ID: <4A3B368E.4050204@cs.columbia.edu>
References: <20090615171337.GA15152@us.ibm.com>
	<20090615190821.GA16990@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090615190821.GA16990-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org


Applied.

However, I removed the #define __NR_clone_with_pids (if it isn't
defined), so mktree can run on s390 kernels that don't have this
syscall (fallback to no-pids).

Oren.

Serge E. Hallyn wrote:
> Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
>> Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>> ---
>>  mktree.c |   41 +++++++++++++++++++++++++++++++++++++++++
>>  1 files changed, 41 insertions(+), 0 deletions(-)
>>
>> diff --git a/mktree.c b/mktree.c
>> index db5a060..af18b57 100644
>> --- a/mktree.c
>> +++ b/mktree.c
>> @@ -1720,6 +1720,47 @@ static int clone_with_pids(int (*fn)(void *), void *child_stack, int flags,
>>  }
>>  #else
>>
>> +#elif defined __s390__
> 
> Boy, I am having a BAD patching day.  Clearly, the chunk of new code
> should come before the #else.  Here's the trivial update.
> 
> -serge
> 
> From 12ef5d382693f3e47adf36d0211e3ae1f94c2b02 Mon Sep 17 00:00:00 2001
> From: root <root-4X4tz4w3nuxpk64qw6wm7cxtgHpCUUYS@public.gmane.org>
> Date: Mon, 15 Jun 2009 13:14:08 -0400
> Subject: [PATCH 1/1] mktree: use clone_with_pid on s390
> 
> Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  mktree.c |   41 +++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 41 insertions(+), 0 deletions(-)
> 
> diff --git a/mktree.c b/mktree.c
> index db5a060..504e2c6 100644
> --- a/mktree.c
> +++ b/mktree.c
> @@ -1718,6 +1718,47 @@ static int clone_with_pids(int (*fn)(void *), void *child_stack, int flags,
>  	}
>  	return retval;
>  }
> +#elif defined __s390__
> +
> +#ifndef __NR_clone_with_pids
> +#define __NR_clone_with_pids	332
> +#endif
> +
> +#define do_clone_with_pids(stack, flags, ptid, ctid, setp) ({ \
> +	register unsigned long int __r2 asm ("2") = (unsigned long int)(stack);\
> +	register unsigned long int __r3 asm ("3") = (unsigned long int)(flags);\
> +	register unsigned long int __r4 asm ("4") = (unsigned long int)(ptid); \
> +	register unsigned long int __r5 asm ("5") = (unsigned long int)(ctid); \
> +	register unsigned long int __r6 asm ("6") = (unsigned long int)(NULL); \
> +	register unsigned long int __r7 asm ("7") = (unsigned long int)(setp); \
> +	register unsigned long int __result asm ("2"); \
> +	__asm__ __volatile__( \
> +		" lghi %%r1,332\n" \
> +		" svc 0\n" \
> +		: "=d" (__result) \
> +		: "0" (__r2), "d" (__r3), \
> +		  "d" (__r4), "d" (__r5), "d" (__r6), "d" (__r7) \
> +		: "1", "cc", "memory" \
> +	); \
> +		__result; \
> +	})
> +
> +int clone_with_pids(int (*fn)(void *), void *child_stack, int flags,
> +			struct target_pid_set *target_pids, void *arg)
> +{
> +	long retval;
> +	retval = do_clone_with_pids(child_stack, flags, NULL, NULL,
> +			target_pids);
> +
> +	if (retval < 0) {
> +		errno = -retval;
> +		return -1;
> +	} else if (retval == 0) {
> +		return fn(arg);
> +	} else
> +		return retval;
> +}
> +
>  #else
>  
>  #error mktree requires arch support for clone_with_pids() syscall
