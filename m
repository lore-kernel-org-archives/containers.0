From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 2/7] [PATCH] Have alloc_pidmap() return actual error code
Date: Wed, 27 May 2009 10:27:42 -0700
Message-ID: <1243445262.8071.54.camel@nimitz>
References: <20090527154212.GA3107@us.ibm.com>
	<20090527154259.GB3107@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090527154259.GB3107-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 2009-05-27 at 08:42 -0700, Sukadev Bhattiprolu wrote:
> From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Date: Mon, 4 May 2009 01:17:40 -0700
> Subject: [PATCH 2/7] [PATCH] Have alloc_pidmap() return actual error code
> 
> alloc_pidmap() can fail either because all pid numbers are in use or
> we can't allocate memory. With support for setting a specific pid
> number, alloc_pidmap() would also fail if either the given pid
> number is invalid or in use.
> 
> Rather than have caller assume -ENOMEM, have alloc_pidmap() return
> the actual error.
> 
> Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> ---
>  kernel/fork.c |    5 +++--
>  kernel/pid.c  |    9 ++++++---
>  2 files changed, 9 insertions(+), 5 deletions(-)
> 
> diff --git a/kernel/fork.c b/kernel/fork.c
> index b9e2edd..f8411a8 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -1119,10 +1119,11 @@ static struct task_struct *copy_process(unsigned long clone_flags,
>  		goto bad_fork_cleanup_io;
> 
>  	if (pid != &init_struct_pid) {
> -		retval = -ENOMEM;
>  		pid = alloc_pid(p->nsproxy->pid_ns);
> -		if (!pid)
> +		if (IS_ERR(pid)) {
> +			retval = PTR_ERR(pid);
>  			goto bad_fork_cleanup_io;
> +		}
> 
>  		if (clone_flags & CLONE_NEWPID) {
>  			retval = pid_ns_prepare_proc(p->nsproxy->pid_ns);
> diff --git a/kernel/pid.c b/kernel/pid.c
> index c0aaebe..fd72ad9 100644
> --- a/kernel/pid.c
> +++ b/kernel/pid.c
> @@ -151,6 +151,7 @@ static int alloc_pidmap(struct pid_namespace *pid_ns)
>  {
>  	int i, offset, max_scan, pid, last = pid_ns->last_pid;
>  	struct pidmap *map;
> +	int rc = -EAGAIN;
> 
>  	pid = last + 1;
>  	if (pid >= pid_max)
> @@ -159,8 +160,10 @@ static int alloc_pidmap(struct pid_namespace *pid_ns)
>  	map = &pid_ns->pidmap[pid/BITS_PER_PAGE];
>  	max_scan = (pid_max + BITS_PER_PAGE - 1)/BITS_PER_PAGE - !offset;
>  	for (i = 0; i <= max_scan; ++i) {
> -		if (alloc_pidmap_page(map))
> +		if (alloc_pidmap_page(map)) {
> +			rc = -ENOMEM;
>  			break;
> +		}

OK, pet peeve time:

	rc = alloc_pidmap_page(map);
	if (rc)
		break;

It saves the bracket and saves a line of assignment, *and* it clarifies
program flow.

-- Dave
