From: "Daniel Hokka Zakrisson" <daniel-nym3zxDgnZcAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC][PATCH] 'kill sig -1' must only apply to callers namespace
Date: Wed, 22 Oct 2008 05:02:17 +0200 (CEST)
Message-ID: <30287.8026305281$1224644769@news.gmane.org>
References: <20081022014141.GA25355@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081022014141.GA25355-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org wrote:
>
>>From d92b4befe07c6a1e852e4462126a5443342448cd Mon Sep 17 00:00:00 2001
> From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Date: Tue, 21 Oct 2008 18:00:01 -0700
> Subject: [PATCH] kill sig -1 must only apply to callers namespace
>
> Currently "kill <sig> -1" kills processes in all namespaces and breaks the
> isolation of namespaces. Earlier attempt to fix this is discussed at:
>
> 	http://lkml.org/lkml/2008/7/23/148
>
> but nothing seems to have happened since then.
>
> This patch uses the simple fix suggested by Oleg Nesterov.
>
> Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Tested-by: Daniel Hokka Zakrisson <daniel-nym3zxDgnZcAvxtiuMwx3w@public.gmane.org>

Thank you for taking care of this.

> ---
>  kernel/signal.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
>
> diff --git a/kernel/signal.c b/kernel/signal.c
> index 105217d..4530fc6 100644
> --- a/kernel/signal.c
> +++ b/kernel/signal.c
> @@ -1144,7 +1144,8 @@ static int kill_something_info(int sig, struct siginfo *info, pid_t
> pid)
>  		struct task_struct * p;
>
>  		for_each_process(p) {
> -			if (p->pid > 1 && !same_thread_group(p, current)) {
> +			if (task_pid_vnr(p) > 1 &&
> +					!same_thread_group(p, current)) {
>  				int err = group_send_sig_info(sig, info, p);
>  				++count;
>  				if (err != -EPERM)
> --
> 1.5.2.5

-- 
Daniel Hokka Zakrisson
