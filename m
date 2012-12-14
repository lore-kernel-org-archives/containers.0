From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/4] userns: Require CAP_SYS_ADMIN for most uses of setns.
Date: Fri, 14 Dec 2012 23:35:24 +0000
Message-ID: <20121214233524.GA13659@mail.hallyn.com>
References: <87txroxpgq.fsf@xmission.com>
 <87hanoxpdh.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87hanoxpdh.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> 
> Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> found a nasty little bug in
> the permissions of setns.  With unprivileged user namespaces it
> became possible to create new namespaces without privilege.
> 
> However the setns calls were relaxed to only require CAP_SYS_ADMIN in
> the user nameapce of the targed namespace.
> 
> Which made the following nasty sequence possible.
> 
> pid = clone(CLONE_NEWUSER | CLONE_NEWNS);
> if (pid == 0) { /* child */
> 	system("mount --bind /home/me/passwd /etc/passwd");
> }
> else if (pid != 0) { /* parent */
> 	char path[PATH_MAX];
> 	snprintf(path, sizeof(path), "/proc/%u/ns/mnt");
> 	fd = open(path, O_RDONLY);
> 	setns(fd, 0);
> 	system("su -");
> }
>
> Prevent this possibility by requiring CAP_SYS_ADMIN
> in the current user namespace when joing all but the user namespace.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

> ---
>  fs/namespace.c           |    3 ++-
>  ipc/namespace.c          |    3 ++-
>  kernel/pid_namespace.c   |    3 ++-
>  kernel/utsname.c         |    3 ++-
>  net/core/net_namespace.c |    3 ++-
>  5 files changed, 10 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/namespace.c b/fs/namespace.c
> index c1bbe86..398a50f 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -2781,7 +2781,8 @@ static int mntns_install(struct nsproxy *nsproxy, void *ns)
>  	struct path root;
>  
>  	if (!ns_capable(mnt_ns->user_ns, CAP_SYS_ADMIN) ||
> -	    !nsown_capable(CAP_SYS_CHROOT))
> +	    !nsown_capable(CAP_SYS_CHROOT) ||
> +	    !nsown_capable(CAP_SYS_ADMIN))
>  		return -EPERM;
>  
>  	if (fs->users != 1)
> diff --git a/ipc/namespace.c b/ipc/namespace.c
> index cf3386a..7c1fa45 100644
> --- a/ipc/namespace.c
> +++ b/ipc/namespace.c
> @@ -170,7 +170,8 @@ static void ipcns_put(void *ns)
>  static int ipcns_install(struct nsproxy *nsproxy, void *new)
>  {
>  	struct ipc_namespace *ns = new;
> -	if (!ns_capable(ns->user_ns, CAP_SYS_ADMIN))
> +	if (!ns_capable(ns->user_ns, CAP_SYS_ADMIN) ||
> +	    !nsown_capable(CAP_SYS_ADMIN))
>  		return -EPERM;
>  
>  	/* Ditch state from the old ipc namespace */
> diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
> index 560da0d..fdbd0cd 100644
> --- a/kernel/pid_namespace.c
> +++ b/kernel/pid_namespace.c
> @@ -325,7 +325,8 @@ static int pidns_install(struct nsproxy *nsproxy, void *ns)
>  	struct pid_namespace *active = task_active_pid_ns(current);
>  	struct pid_namespace *ancestor, *new = ns;
>  
> -	if (!ns_capable(new->user_ns, CAP_SYS_ADMIN))
> +	if (!ns_capable(new->user_ns, CAP_SYS_ADMIN) ||
> +	    !nsown_capable(CAP_SYS_ADMIN))
>  		return -EPERM;
>  
>  	/*
> diff --git a/kernel/utsname.c b/kernel/utsname.c
> index f6336d5..08b197e 100644
> --- a/kernel/utsname.c
> +++ b/kernel/utsname.c
> @@ -113,7 +113,8 @@ static int utsns_install(struct nsproxy *nsproxy, void *new)
>  {
>  	struct uts_namespace *ns = new;
>  
> -	if (!ns_capable(ns->user_ns, CAP_SYS_ADMIN))
> +	if (!ns_capable(ns->user_ns, CAP_SYS_ADMIN) ||
> +	    !nsown_capable(CAP_SYS_ADMIN))
>  		return -EPERM;
>  
>  	get_uts_ns(ns);
> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
> index 2e9a313..8acce01 100644
> --- a/net/core/net_namespace.c
> +++ b/net/core/net_namespace.c
> @@ -649,7 +649,8 @@ static int netns_install(struct nsproxy *nsproxy, void *ns)
>  {
>  	struct net *net = ns;
>  
> -	if (!ns_capable(net->user_ns, CAP_SYS_ADMIN))
> +	if (!ns_capable(net->user_ns, CAP_SYS_ADMIN) ||
> +	    !nsown_capable(CAP_SYS_ADMIN))
>  		return -EPERM;
>  
>  	put_net(nsproxy->net_ns);
> -- 
> 1.7.5.4
