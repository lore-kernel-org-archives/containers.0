From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 03/08] allow sethostname in a container
Date: Tue, 11 Jan 2011 16:14:31 +0000
Message-ID: <20110111161431.GA1406__16570.461417041$1294762440$gmane$org@mail.hallyn.com>
References: <20110111064342.GA27515@mail.hallyn.com>
	<20110111064420.GD27515@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110111064420.GD27515-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Bastian Blank <bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org):
> Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> ---
>  kernel/sys.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/kernel/sys.c b/kernel/sys.c
> index 2745dcd..9b9b03b 100644
> --- a/kernel/sys.c
> +++ b/kernel/sys.c
> @@ -1171,7 +1171,7 @@ SYSCALL_DEFINE2(sethostname, char __user *, name, int, len)
>  	int errno;
>  	char tmp[__NEW_UTS_LEN];
>  
> -	if (!capable(CAP_SYS_ADMIN))
> +	if (!ns_capable(current->nsproxy->uts_ns->user_ns, CAP_SYS_ADMIN))
>  		return -EPERM;
>  	if (len < 0 || len > __NEW_UTS_LEN)
>  		return -EINVAL;
> -- 
> 1.7.0.4

An interesting note here is that since the task doing ns_exec (and
therefore in the init_user_ns) requires CAP_SYS_ADMIN to unshare,
this check will actually always be true if uts_ns was not unshared.
If uts is unshared, then regular capabilities semantics in the
child user_ns apply (that is, root can do sethostname, unpriv user
cannot)  The intent is that user namespaces will eventually allow
unprivileged users to unshare, after which this will make much more
sense.

-serge
