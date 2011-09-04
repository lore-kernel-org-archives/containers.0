From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 02/15] user ns: setns: move capable checks into per-ns
	attach helper
Date: Sat, 3 Sep 2011 18:51:40 -0700
Message-ID: <20110904015140.GB32295__7538.93744336001$1315101186$gmane$org@count0.beaverton.ibm.com>
References: <1314993400-6910-1-git-send-email-serge@hallyn.com>
	<1314993400-6910-5-git-send-email-serge@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1314993400-6910-5-git-send-email-serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Sep 02, 2011 at 07:56:27PM +0000, Serge Hallyn wrote:
> From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>

I was confused about this patch until I realized that you're not
simply "moving" the capability checks but "distributing" them. Then
you're showing that you'll soon change some to nsown_capable() or
ns_capable() using the strange cpp pattern in the snippet below.

At least I think that's what you intended. A commit message would
help :).

Cheers,
	-Matt Helsley

> 
> Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> Cc: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>  ipc/namespace.c          |    7 +++++++
>  kernel/fork.c            |    5 +++++
>  kernel/nsproxy.c         |   11 ++++++++---
>  kernel/utsname.c         |    7 +++++++
>  net/core/net_namespace.c |    7 +++++++
>  5 files changed, 34 insertions(+), 3 deletions(-)
> 
> diff --git a/ipc/namespace.c b/ipc/namespace.c
> index ce0a647..a0a7609 100644
> --- a/ipc/namespace.c
> +++ b/ipc/namespace.c
> @@ -163,6 +163,13 @@ static void ipcns_put(void *ns)
> 
>  static int ipcns_install(struct nsproxy *nsproxy, void *ns)
>  {
> +#if 0
> +	struct ipc_namespace *newns = ns;
> +	if (!ns_capable(newns->user_ns, CAP_SYS_ADMIN))
> +#else
> +	if (!capable(CAP_SYS_ADMIN))
> +#endif
> +		return -1;
>  	/* Ditch state from the old ipc namespace */
>  	exit_sem(current);
>  	put_ipc_ns(nsproxy->ipc_ns);
