From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/5] pid: use namespaced iteration on processes while
	setting capability
Date: Thu, 18 Dec 2008 11:04:34 -0600
Message-ID: <20081218170434.GA13188@us.ibm.com>
References: <1229618553-6348-1-git-send-email-gowrishankar.m@linux.vnet.ibm.com>
	<1229618553-6348-4-git-send-email-gowrishankar.m@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1229618553-6348-4-git-send-email-gowrishankar.m-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dave <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Eric <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Sukadev <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Balbir <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Gowrishankar M (gowrishankar.m-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> From: Gowrishankar M <gomuthuk-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> 
> In piece of dead code, cap_set_all() propogates through processes outside
> PID namespace, as iteration is always in init PID namespace.
> 
> Below patch adjusts macro controller to use do_each_thread_in_ns() so that
> only processes in current namespace are scanned
> 
> Signed-off-by: Gowrishankar M <gowrishankar.m-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> ---
>  kernel/capability.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/kernel/capability.c b/kernel/capability.c
> index 33e51e7..e3e3765 100644
> --- a/kernel/capability.c
> +++ b/kernel/capability.c
> @@ -201,7 +201,7 @@ static inline int cap_set_all(kernel_cap_t *effective,
>  	spin_lock(&task_capability_lock);
>  	read_lock(&tasklist_lock);
> 
> -	do_each_thread(g, target) {
> +	do_each_thread_in_ns(g, target, current->nsproxy->pid_ns) {
>  		if (target == current
>  		    || is_container_init(target->group_leader))
>  			continue;
> -- 
> 1.5.5.1
