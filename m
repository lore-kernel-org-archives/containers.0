From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH 1/9] Add a user_namespace as creator/owner of uts_namespace
Date: Fri, 18 Feb 2011 17:57:41 +0100
Message-ID: <4D5EA505.8020702__14040.9422027462$1298048330$gmane$org@free.fr>
References: <20110217150224.GA26334@mail.hallyn.com>
	<20110217150257.GA26395@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110217150257.GA26395-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
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
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On 02/17/2011 04:02 PM, Serge E. Hallyn wrote:
> copy_process() handles CLONE_NEWUSER before the rest of the
> namespaces.  So in the case of clone(CLONE_NEWUSER|CLONE_NEWUTS)
> the new uts namespace will have the new user namespace as its
> owner.  That is what we want, since we want root in that new
> userns to be able to have privilege over it.
>
> Changelog:
> 	Feb 15: don't set uts_ns->user_ns if we didn't create
> 		a new uts_ns.
>
> Signed-off-by: Serge E. Hallyn<serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

Acked-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

A couple of comments.

> ---
>   include/linux/utsname.h |    3 +++
>   init/version.c          |    2 ++
>   kernel/nsproxy.c        |    5 +++++
>   kernel/user.c           |    8 ++++++--
>   kernel/utsname.c        |    4 ++++
>   5 files changed, 20 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/utsname.h b/include/linux/utsname.h
> index 69f3997..85171be 100644
> --- a/include/linux/utsname.h
> +++ b/include/linux/utsname.h
> @@ -37,9 +37,12 @@ struct new_utsname {
>   #include<linux/nsproxy.h>
>   #include<linux/err.h>
>
> +struct user_namespace;
> +
>   struct uts_namespace {
>   	struct kref kref;
>   	struct new_utsname name;
> +	struct user_namespace *user_ns;
>   };
>   extern struct uts_namespace init_uts_ns;
>
> diff --git a/init/version.c b/init/version.c
> index adff586..97bb86f 100644
> --- a/init/version.c
> +++ b/init/version.c
> @@ -21,6 +21,7 @@ extern int version_string(LINUX_VERSION_CODE);
>   int version_string(LINUX_VERSION_CODE);
>   #endif
>
> +extern struct user_namespace init_user_ns;
>   struct uts_namespace init_uts_ns = {
>   	.kref = {
>   		.refcount	= ATOMIC_INIT(2),
> @@ -33,6 +34,7 @@ struct uts_namespace init_uts_ns = {
>   		.machine	= UTS_MACHINE,
>   		.domainname	= UTS_DOMAINNAME,
>   	},
> +	.user_ns =&init_user_ns,
>   };
>   EXPORT_SYMBOL_GPL(init_uts_ns);
>
> diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
> index f74e6c0..034dc2e 100644
> --- a/kernel/nsproxy.c
> +++ b/kernel/nsproxy.c
> @@ -74,6 +74,11 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
>   		err = PTR_ERR(new_nsp->uts_ns);
>   		goto out_uts;
>   	}
> +	if (new_nsp->uts_ns != tsk->nsproxy->uts_ns) {
> +		put_user_ns(new_nsp->uts_ns->user_ns);
> +		new_nsp->uts_ns->user_ns = task_cred_xxx(tsk, user)->user_ns;
> +		get_user_ns(new_nsp->uts_ns->user_ns);
> +	}

IMO you should add a comment telling this code assume create_user_ns was 
called before (via copy_cred).

>
>   	new_nsp->ipc_ns = copy_ipcs(flags, tsk->nsproxy->ipc_ns);
>   	if (IS_ERR(new_nsp->ipc_ns)) {

[ ... ]

>   static struct uts_namespace *create_uts_ns(void)
>   {
> @@ -40,6 +41,8 @@ static struct uts_namespace *clone_uts_ns(struct uts_namespace *old_ns)
>
>   	down_read(&uts_sem);
>   	memcpy(&ns->name,&old_ns->name, sizeof(ns->name));
> +	ns->user_ns = old_ns->user_ns;
> +	get_user_ns(ns->user_ns);

ns->user_ns = get_user_ns(old_ns->user_ns);
