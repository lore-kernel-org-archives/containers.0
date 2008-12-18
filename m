From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 4/5] pid: use namespaced iteration on processes while
	sending signal to all
Date: Thu, 18 Dec 2008 09:10:47 -0800
Message-ID: <1229620248.17206.537.camel@nimitz>
References: <1229618553-6348-1-git-send-email-gowrishankar.m@linux.vnet.ibm.com>
	<1229618553-6348-5-git-send-email-gowrishankar.m@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1229618553-6348-5-git-send-email-gowrishankar.m-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gowrishankar M <gowrishankar.m-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Sukadev <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Eric <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Balbir <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 2008-12-18 at 22:12 +0530, Gowrishankar M wrote:
> At present we scan all processes in init namespace, whether in new namespace
> or not, to send signal to all processes for container. Also we filter out
> processes belonging to same namespace using task_pid_vnr().
> 
> Below patch proposes to use new macro controller to save time using pidmap.
> In init namespace, this saving can be more or less achieved, as we check to
> take every process with task_pid_vnr() otherwise.

> diff --git a/kernel/signal.c b/kernel/signal.c
> index 4530fc6..a2651bc 100644
> --- a/kernel/signal.c
> +++ b/kernel/signal.c
> @@ -1143,9 +1143,8 @@ static int kill_something_info(int sig, struct siginfo *info, pid_t pid)
>  		int retval = 0, count = 0;
>  		struct task_struct * p;
> 
> -		for_each_process(p) {
> -			if (task_pid_vnr(p) > 1 &&
> -					!same_thread_group(p, current)) {
> +		for_each_process_in_ns(p, current->nsproxy->pid_ns) {
> +			if (!same_thread_group(p, current)) {
>  				int err = group_send_sig_info(sig, info, p);
>  				++count;
>  				if (err != -EPERM)

So this is a performance optimization?

Isn't that task_pid_vnr() basically an is_container_init() check?  Why
did it go away?

This patch implies that ever process in another's thread group is also
in the same pid namespace.  That seems like a sane assumption, but I'd
probably hesitate without Oleg or Eric taking a good look.

-- Dave
