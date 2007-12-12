From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 6/9] pid: Implement pid_in_pid_ns.
Date: Wed, 12 Dec 2007 16:33:29 +0300
Message-ID: <475FE329.8020303@openvz.org>
References: <m13au8ytos.fsf@ebiederm.dsl.xmission.com>	<m1y7c0xezt.fsf@ebiederm.dsl.xmission.com>	<m1tzmoxexb.fsf_-_@ebiederm.dsl.xmission.com>	<m1prxcxeum.fsf_-_@ebiederm.dsl.xmission.com>	<m1lk80xeps.fsf_-_@ebiederm.dsl.xmission.com>	<m1hcioxenh.fsf_-_@ebiederm.dsl.xmission.com>
	<m1d4tcxelu.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1d4tcxelu.fsf_-_-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
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
> Implement a simple check to see if a specified pid resides
> in a specified pid namespace.  Generally we are smart enough
> just to operate on single pid namespace and avoid this test.
> However in the case of sending a signal to init we must check
> to see if our sender is a child of init and so this test is needed.
> 
> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>  include/linux/pid.h |    3 +++
>  kernel/pid.c        |    6 ++++++
>  2 files changed, 9 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/pid.h b/include/linux/pid.h
> index c4b56c0..e409cc5 100644
> --- a/include/linux/pid.h
> +++ b/include/linux/pid.h
> @@ -156,6 +156,9 @@ static inline pid_t pid_nr(struct pid *pid)
>  pid_t pid_nr_ns(struct pid *pid, struct pid_namespace *ns);
>  pid_t pid_vnr(struct pid *pid);
>  
> +/* Test to see if pid is present in pid namespace ns */
> +extern int pid_in_pid_ns(struct pid *pid, struct pid_namespace *ns);
> +
>  #define do_each_pid_task(pid, type, task)				\
>  	do {								\
>  		struct hlist_node *pos___;				\
> diff --git a/kernel/pid.c b/kernel/pid.c
> index a7ecfce..873c00f 100644
> --- a/kernel/pid.c
> +++ b/kernel/pid.c
> @@ -429,6 +429,12 @@ struct pid *find_get_pid(pid_t nr)
>  	return pid;
>  }
>  
> +int pid_in_pid_ns(struct pid *pid, struct pid_namespace *ns)

Can we give it a better name? Like pid_in_ns() if we do want it
to be as short as possible, or pid_visible_in_ns() if we want
it ti reflect its nature.

> +{
> +	return pid && ns && (ns->level <= pid->level) &&
> +		pid->numbers[ns->level].ns == ns;
> +}
> +
>  pid_t pid_nr_ns(struct pid *pid, struct pid_namespace *ns)
>  {
>  	struct upid *upid;

Thanks,
Pavel
