From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/4] signal: Introduce kill_pid_ns_info
Date: Wed, 12 Dec 2007 19:09:03 +0300
Message-ID: <4760079F.9060200@openvz.org>
References: <m13au8ytos.fsf@ebiederm.dsl.xmission.com>	<m1y7c0xezt.fsf@ebiederm.dsl.xmission.com>	<m1tzmoxexb.fsf_-_@ebiederm.dsl.xmission.com>	<m1prxcxeum.fsf_-_@ebiederm.dsl.xmission.com>	<m1lk80xeps.fsf_-_@ebiederm.dsl.xmission.com>	<m1hcioxenh.fsf_-_@ebiederm.dsl.xmission.com>	<m1d4tcxelu.fsf_-_@ebiederm.dsl.xmission.com>	<m18x40xeg6.fsf_-_@ebiederm.dsl.xmission.com>	<m13au8xe8m.fsf_-_@ebiederm.dsl.xmission.com>	<m1y7c0vzm4.fsf_-_@ebiederm.dsl.xmission.com>	<m1odcwvz3d.fsf_-_@ebiederm.dsl.xmission.com>	<m1ir34vyaj.fsf_-_@ebiederm.dsl.xmission.com>	<m1ejdsvy54.fsf_-_@ebiederm.dsl.xmission.com>	<m1abogvy39.fsf_-_@ebiederm.dsl.xmission.com>	<m163z4vxzs.fsf_-_@ebiederm.dsl.xmission.com>	<m11w9svxeb.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ve74uio4.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1ve74uio4.fsf_-_-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
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
> Implement the basic helper function that walks all of the processes in
> a pid namespace and sends them all a signal. 
> 
> Both locations that could use this functions are also updated to use
> this function.
> 
> I use find_ge_pid instead of for_each_process because it has a chance
> of not touching every process in the system.
> 
> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Looks sane.

Acked-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

but one comment inside.

[snip]

> diff --git a/kernel/signal.c b/kernel/signal.c
> index 074905f..1eb0661 100644
> --- a/kernel/signal.c
> +++ b/kernel/signal.c
> @@ -1083,6 +1083,45 @@ int group_send_sig_info(int sig, struct siginfo *info, struct task_struct *p)
>  	return ret;
>  }
>  
> +int __kill_pid_ns_info(int sig, struct siginfo *info, struct pid_namespace *ns)

Shouldn't it be static?

> +{
> +	int retval = 0, count = 0;
> +	struct task_struct *p;
> +	struct pid *pid;
> +	int nr;
> +
> +	/* Since there isn't a pid namespace list of tasks use the closet
> +	 * approximation we have: find_ge_pid.
> +	 */
> +	nr = 0;
> +	while ((pid = find_ge_pid(nr + 1, ns))) {
> +		int err;
> +
> +		nr = pid_nr_ns(pid, ns);
> +		p = pid_task(pid, PIDTYPE_PID);
> +		if (!p || (nr <= 1) || !thread_group_leader(p) ||
> +		    same_thread_group(p, current))
> +			continue;
> +
> +		err = group_send_sig_info(sig, info, p);
> +		++count;
> +		if (err != -EPERM)
> +			retval = err;
> +	}
> +	return count ? retval : -ESRCH;
> +}
> +

[snip]

Thanks,
Pavel
