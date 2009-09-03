From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH/user_cr] pass a valid stack address to clone_with_pids
Date: Thu, 03 Sep 2009 16:44:36 -0400
Message-ID: <4AA02AB4.7080703@librato.com>
References: <1251846857.23305.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1251846857.23305.5.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


Pulled, thanks.

Nathan Lynch wrote:
> Off-by-one error: the stack address passed to clone/clone_with_pids
> must be within the region allocated.  (Also, arithmetic on void * is a
> gcc extension; change the relevant variables to char *).
> 
> Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
> ---
>  mktree.c |   15 ++++++++-------
>  1 files changed, 8 insertions(+), 7 deletions(-)
> 
> diff --git a/mktree.c b/mktree.c
> index 63be82d..2d8d796 100644
> --- a/mktree.c
> +++ b/mktree.c
> @@ -1367,18 +1367,19 @@ int ckpt_fork_stub(void *data)
>  static pid_t ckpt_fork_child(struct ckpt_ctx *ctx, struct task *child)
>  {
>  	struct target_pid_set pid_set;
> -	void *stack = NULL;
> +	char *stack_region;
> +	char *stack_start;
>  	unsigned long flags = SIGCHLD;
>  	pid_t pid = 0;
>  
>  	ckpt_dbg("forking child vpid %d flags %#x\n", child->pid, child->flags);
>  
> -	stack = malloc(PTHREAD_STACK_MIN);
> -	if (!stack) {
> +	stack_region = malloc(PTHREAD_STACK_MIN);
> +	if (!stack_region) {
>  		perror("stack malloc");
>  		return -1;
>  	}
> -	stack += PTHREAD_STACK_MIN;
> +	stack_start = stack_region + PTHREAD_STACK_MIN - 1;
>  
>  	pid_set.target_pids = &pid;
>  	pid_set.num_pids = 1;
> @@ -1406,15 +1407,15 @@ static pid_t ckpt_fork_child(struct ckpt_ctx *ctx, struct task *child)
>  	else
>  		child->real_parent = _getpid();
>  
> -	pid = clone_with_pids(ckpt_fork_stub, stack, flags, &pid_set, child);
> +	pid = clone_with_pids(ckpt_fork_stub, stack_start, flags, &pid_set, child);
>  	if (pid < 0) {
>  		perror("clone");
> -		free(stack - PTHREAD_STACK_MIN);
> +		free(stack_region);
>  		return -1;
>  	}
>  
>  	if (!(child->flags & TASK_THREAD))
> -		free(stack - PTHREAD_STACK_MIN);
> +		free(stack_region);
>  
>  	ckpt_dbg("forked child vpid %d (asked %d)\n", pid, child->pid);
>  	return pid;
