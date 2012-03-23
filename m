From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH v2] futex: mark get_robust_list as deprecated
Date: Fri, 23 Mar 2012 15:06:02 -0700
Message-ID: <m1fwczvuph.fsf@fess.ebiederm.org>
References: <20120323190855.GA27213@www.outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120323190855.GA27213-0X9Bc/hWBUTk6RaD4rd5nQ@public.gmane.org> (Kees Cook's message of
	"Fri, 23 Mar 2012 12:08:55 -0700")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: spender-JNS0hek0TMl4qEwOxq4T+Q@public.gmane.org, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>, Darren Hart <dvhart-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Randy Dunlap <rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org> writes:

> Notify get_robust_list users that the syscall is going away.

Has anyone asked the question if the folks working on checkpoint/restart
are going to need this.

This seems like important information to know if you want to checkpoint
a process.

Eric

> Suggested-by: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
> Signed-off-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> ---
> v2:
>  - add note to feature-removal-schedule.txt.
> ---
>  Documentation/feature-removal-schedule.txt |   10 ++++++++++
>  kernel/futex.c                             |    2 ++
>  kernel/futex_compat.c                      |    2 ++
>  3 files changed, 14 insertions(+), 0 deletions(-)
>
> diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
> index 4bfd982..e3bf119 100644
> --- a/Documentation/feature-removal-schedule.txt
> +++ b/Documentation/feature-removal-schedule.txt
> @@ -543,3 +543,13 @@ When:	3.5
>  Why:	The old kmap_atomic() with two arguments is deprecated, we only
>  	keep it for backward compatibility for few cycles and then drop it.
>  Who:	Cong Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> +
> +----------------------------
> +
> +What:	get_robust_list syscall
> +When:	2013
> +Why:	There appear to be no production users of the get_robust_list syscall,
> +	and it runs the risk of leaking address locations, allowing the bypass
> +	of ASLR. It was only ever intended for debugging, so it should be
> +	removed.
> +Who:	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> diff --git a/kernel/futex.c b/kernel/futex.c
> index d701be5..e2b0fb9 100644
> --- a/kernel/futex.c
> +++ b/kernel/futex.c
> @@ -2449,6 +2449,8 @@ SYSCALL_DEFINE3(get_robust_list, int, pid,
>  	if (!futex_cmpxchg_enabled)
>  		return -ENOSYS;
>  
> +	WARN_ONCE(1, "deprecated: get_robust_list will be deleted in 2013.\n");
> +
>  	rcu_read_lock();
>  
>  	ret = -ESRCH;
> diff --git a/kernel/futex_compat.c b/kernel/futex_compat.c
> index a9642d5..83e368b 100644
> --- a/kernel/futex_compat.c
> +++ b/kernel/futex_compat.c
> @@ -142,6 +142,8 @@ compat_sys_get_robust_list(int pid, compat_uptr_t __user *head_ptr,
>  	if (!futex_cmpxchg_enabled)
>  		return -ENOSYS;
>  
> +	WARN_ONCE(1, "deprecated: get_robust_list will be deleted in 2013.\n");
> +
>  	rcu_read_lock();
>  
>  	ret = -ESRCH;
