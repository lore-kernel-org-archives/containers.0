From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 09/11] fuse: Restrict allow_other to the superblock's
	namespace or a descendant
Date: Fri, 22 Dec 2017 21:50:47 -0600
Message-ID: <20171223035046.GI6837__47957.8579579995$1514000959$gmane$org@mail.hallyn.com>
References: <cover.1512741134.git.dongsu@kinvolk.io>
	<d055925e5d5c0099e9e9c871004fb45fab67e4bc.1512041070.git.dongsu@kinvolk.io>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <d055925e5d5c0099e9e9c871004fb45fab67e4bc.1512041070.git.dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dongsu Park <dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
Cc: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Dec 22, 2017 at 03:32:33PM +0100, Dongsu Park wrote:
> From: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> 
> Unprivileged users are normally restricted from mounting with the
> allow_other option by system policy, but this could be bypassed
> for a mount done with user namespace root permissions. In such
> cases allow_other should not allow users outside the userns
> to access the mount as doing so would give the unprivileged user
> the ability to manipulate processes it would otherwise be unable
> to manipulate. Restrict allow_other to apply to users in the same
> userns used at mount or a descendant of that namespace. Also
> export current_in_userns() for use by fuse when built as a
> module.
> 
> Patch v4 is available: https://patchwork.kernel.org/patch/8944671/
> 
> Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> Cc: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
> Cc: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> Signed-off-by: Dongsu Park <dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>

Reviewed-by: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>

> ---
>  fs/fuse/dir.c           | 2 +-
>  kernel/user_namespace.c | 1 +
>  2 files changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/fuse/dir.c b/fs/fuse/dir.c
> index ad1cfac1..d41559a0 100644
> --- a/fs/fuse/dir.c
> +++ b/fs/fuse/dir.c
> @@ -1030,7 +1030,7 @@ int fuse_allow_current_process(struct fuse_conn *fc)
>  	const struct cred *cred;
>  
>  	if (fc->allow_other)
> -		return 1;
> +		return current_in_userns(fc->user_ns);
>  
>  	cred = current_cred();
>  	if (uid_eq(cred->euid, fc->user_id) &&
> diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
> index 246d4d4c..492c255e 100644
> --- a/kernel/user_namespace.c
> +++ b/kernel/user_namespace.c
> @@ -1235,6 +1235,7 @@ bool current_in_userns(const struct user_namespace *target_ns)
>  {
>  	return in_userns(target_ns, current_user_ns());
>  }
> +EXPORT_SYMBOL(current_in_userns);

I have to say I'm not happy with this name.  I wish it had been
called current_under_userns or something to indicate it may also
be in a child.

>  
>  static inline struct user_namespace *to_user_ns(struct ns_common *ns)
>  {
> -- 
> 2.13.6
