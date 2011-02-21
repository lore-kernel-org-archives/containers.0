From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH 1/4] userns: let clone_uts_ns() handle setting uts->user_ns
Date: Mon, 21 Feb 2011 11:03:50 +0100
Message-ID: <4D623886.3010505__8242.01511354676$1298282756$gmane$org@free.fr>
References: <20110221040156.GA12580@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110221040156.GA12580-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On 02/21/2011 05:01 AM, Serge E. Hallyn wrote:
> To do so we need to pass in the task_struct who'll get the utsname,
> so we can get its user_ns.
>
> Signed-off-by: Serge E. Hallyn<serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> ---


>   include/linux/utsname.h |   10 ++++++----
>   kernel/nsproxy.c        |    7 +------
>   kernel/utsname.c        |   12 +++++++-----
>   3 files changed, 14 insertions(+), 15 deletions(-)
>
> diff --git a/include/linux/utsname.h b/include/linux/utsname.h
> index 85171be..165b17b 100644
> --- a/include/linux/utsname.h
> +++ b/include/linux/utsname.h
> @@ -52,8 +52,9 @@ static inline void get_uts_ns(struct uts_namespace *ns)
>   	kref_get(&ns->kref);
>   }
>
> -extern struct uts_namespace *copy_utsname(unsigned long flags,
> -					struct uts_namespace *ns);
> +extern struct uts_namespace *copy_utsname(struct task_struct *tsk,
> +					  unsigned long flags,
> +					  struct uts_namespace *ns);

Why don't we pass 'user_ns' instead of 'tsk' ? that will look 
semantically clearer for the caller no ?
(example below).

>   extern void free_uts_ns(struct kref *kref);
>
>   static inline void put_uts_ns(struct uts_namespace *ns)
> @@ -69,8 +70,9 @@ static inline void put_uts_ns(struct uts_namespace *ns)
>   {
>   }
>
> -static inline struct uts_namespace *copy_utsname(unsigned long flags,
> -					struct uts_namespace *ns)
> +static inline struct uts_namespace *copy_utsname(struct task_struct *tsk,
> +						 unsigned long flags,
> +						 struct uts_namespace *ns)
>   {
>   	if (flags&  CLONE_NEWUTS)
>   		return ERR_PTR(-EINVAL);
> diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
> index b6dbff2..ffa6b67 100644
> --- a/kernel/nsproxy.c
> +++ b/kernel/nsproxy.c
> @@ -69,16 +69,11 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
>   		goto out_ns;
>   	}
>
> -	new_nsp->uts_ns = copy_utsname(flags, tsk->nsproxy->uts_ns);
> +	new_nsp->uts_ns = copy_utsname(tsk, flags, tsk->nsproxy->uts_ns);
>   	if (IS_ERR(new_nsp->uts_ns)) {
>   		err = PTR_ERR(new_nsp->uts_ns);
>   		goto out_uts;
>   	}

...

new_nsp->uts_ns = copy_utsname(flags, tsk->nsproxy->uts_ns, task_cred_xxx(tsk, user)->user_ns);

...

> -	if (new_nsp->uts_ns != tsk->nsproxy->uts_ns) {
> -		put_user_ns(new_nsp->uts_ns->user_ns);
> -		new_nsp->uts_ns->user_ns = task_cred_xxx(tsk, user)->user_ns;
> -		get_user_ns(new_nsp->uts_ns->user_ns);
> -	}
>
>   	new_nsp->ipc_ns = copy_ipcs(flags, tsk->nsproxy->ipc_ns);
>   	if (IS_ERR(new_nsp->ipc_ns)) {
> diff --git a/kernel/utsname.c b/kernel/utsname.c
> index a7b3a8d..9462580 100644
> --- a/kernel/utsname.c
> +++ b/kernel/utsname.c
> @@ -31,7 +31,8 @@ static struct uts_namespace *create_uts_ns(void)
>    * @old_ns: namespace to clone
>    * Return NULL on error (failure to kmalloc), new ns otherwise
>    */
> -static struct uts_namespace *clone_uts_ns(struct uts_namespace *old_ns)
> +static struct uts_namespace *clone_uts_ns(struct task_struct *tsk,
> +					  struct uts_namespace *old_ns)
>   {
>   	struct uts_namespace *ns;
>
> @@ -41,8 +42,7 @@ static struct uts_namespace *clone_uts_ns(struct uts_namespace *old_ns)
>
>   	down_read(&uts_sem);
>   	memcpy(&ns->name,&old_ns->name, sizeof(ns->name));
> -	ns->user_ns = old_ns->user_ns;
> -	get_user_ns(ns->user_ns);
> +	ns->user_ns = get_user_ns(task_cred_xxx(tsk, user)->user_ns);
>   	up_read(&uts_sem);
>   	return ns;
>   }
> @@ -53,7 +53,9 @@ static struct uts_namespace *clone_uts_ns(struct uts_namespace *old_ns)
>    * utsname of this process won't be seen by parent, and vice
>    * versa.
>    */
> -struct uts_namespace *copy_utsname(unsigned long flags, struct uts_namespace *old_ns)
> +struct uts_namespace *copy_utsname(struct task_struct *tsk,
> +				   unsigned long flags,
> +				   struct uts_namespace *old_ns)
>   {
>   	struct uts_namespace *new_ns;
>
> @@ -63,7 +65,7 @@ struct uts_namespace *copy_utsname(unsigned long flags, struct uts_namespace *ol
>   	if (!(flags&  CLONE_NEWUTS))
>   		return old_ns;
>
> -	new_ns = clone_uts_ns(old_ns);
> +	new_ns = clone_uts_ns(tsk, old_ns);
>
>   	put_uts_ns(old_ns);
>   	return new_ns;
