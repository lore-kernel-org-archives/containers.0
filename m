From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 5/9] pid: Update pid_vnr to use task_active_pid_ns
Date: Wed, 12 Dec 2007 16:28:33 +0300
Message-ID: <475FE201.7060104@openvz.org>
References: <m13au8ytos.fsf@ebiederm.dsl.xmission.com>	<m1y7c0xezt.fsf@ebiederm.dsl.xmission.com>	<m1tzmoxexb.fsf_-_@ebiederm.dsl.xmission.com>	<m1prxcxeum.fsf_-_@ebiederm.dsl.xmission.com>	<m1lk80xeps.fsf_-_@ebiederm.dsl.xmission.com>
	<m1hcioxenh.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1hcioxenh.fsf_-_-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> There is no real additional cost in using task_active_pid_ns and
> by doing so it means we do not need to audit the callers of pid_vnr
> closely, to ensure they are always called on living processes.
> 
> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>  kernel/pid.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/kernel/pid.c b/kernel/pid.c
> index 54d7634..a7ecfce 100644
> --- a/kernel/pid.c
> +++ b/kernel/pid.c
> @@ -444,7 +444,7 @@ pid_t pid_nr_ns(struct pid *pid, struct pid_namespace *ns)
>  
>  pid_t pid_vnr(struct pid *pid)
>  {
> -	return pid_nr_ns(pid, current->nsproxy->pid_ns);
> +	return pid_nr_ns(pid, task_active_pid_ns(current));

NAK. Your version will make more dereferences and one
condition check (if (pid != NULL)). Besides, dead process
can never call this thing - it is even never scheduled 
for execution.

>  }
>  EXPORT_SYMBOL_GPL(pid_vnr);
>  
