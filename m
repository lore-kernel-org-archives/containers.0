From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH 1/1] signal: Introduce kill_pid_ns_info
Date: Thu, 17 Jul 2008 14:10:05 -0700
Message-ID: <20080717141005.5534fbc2.akpm@linux-foundation.org>
References: <58550.192.168.102.6.1216323456.squirrel@intranet>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <58550.192.168.102.6.1216323456.squirrel@intranet>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Hokka Zakrisson <daniel-nym3zxDgnZcAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 17 Jul 2008 21:37:36 +0200 (CEST)
"Daniel Hokka Zakrisson" <daniel-nym3zxDgnZcAvxtiuMwx3w@public.gmane.org> wrote:

> Author: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> 
> Implement the basic helper function that walks all of the processes in a
> pid namespace and sends them all a signal.
> 
> Both locations that could use this functions are also updated to use this
> function.
> 
> I use find_ge_pid instead of for_each_process because it has a chance of
> not touching every process in the system.
> 
> [daniel-nym3zxDgnZcAvxtiuMwx3w@public.gmane.org: Optimize away nr <= 1 check, against latest Linus tree]
> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Daniel Hokka Zakrisson <daniel-nym3zxDgnZcAvxtiuMwx3w@public.gmane.org>
> 
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index ba2f859..83597f8 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1778,6 +1778,8 @@ extern void release_task(struct task_struct * p);
>  extern int send_sig_info(int, struct siginfo *, struct task_struct *);
> extern int force_sigsegv(int, struct task_struct *);

Space-stuffed

>  extern int force_sig_info(int, struct siginfo *, struct task_struct *);
> +extern int __kill_pid_ns_info(int sig, struct siginfo *info, struct
> pid_namespace *ns);

word-wrapped

> +extern int kill_pid_ns_info(int sig, struct siginfo *info, struct
> pid_namespace *ns);
>  extern int __kill_pgrp_info(int sig, struct siginfo *info, struct pid
> *pgrp);
>  extern int kill_pid_info(int sig, struct siginfo *info, struct pid *pid);
> extern int kill_pid_info_as_uid(int, struct siginfo *, struct pid *,
> uid_t, uid_t, u32);
> diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
> index 98702b4..9226423 100644
> --- a/kernel/pid_namespace.c
> +++ b/kernel/pid_namespace.c
> @@ -153,29 +153,14 @@ void free_pid_ns(struct kref *kref)
> 
>  void zap_pid_ns_processes(struct pid_namespace *pid_ns)
>  {
> -	int nr;
>  	int rc;

but at least the tabs weren't replaced with spaces!

Fix and resend, please.
