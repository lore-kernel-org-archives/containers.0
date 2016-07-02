From: Omar Sandoval <osandov-nWWhXC5lh1RBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 1/3] namei: add LOOKUP_DFD_ROOT to use dfd as root
Date: Fri, 1 Jul 2016 17:55:25 -0700
Message-ID: <20160702005525.GA28451@vader.dhcp.thefacebook.com>
References: <1467135510-2564-1-git-send-email-avagin@openvz.org>
	<1467135510-2564-2-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1467135510-2564-2-git-send-email-avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "J. Bruce Fields" <bfields-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Shuah Khan <shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>, criu-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Jun 28, 2016 at 10:38:28AM -0700, Andrey Vagin wrote:
> The problem is that a pathname can contain absolute symlinks and now
> they are resolved relative to the current root.
> 
> If we want to open a file in another mount namespaces and we have a file
> descriptor to its root directory, we probably want to resolve pathname
> in the target mount namespace. For this we add this new flag.
> 
> If LOOKUP_DFD_ROOT is set, path_init() initializes nd->root and nd->path
> to the same value.
> 
> Signed-off-by: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

Hi, Andrey,

Seems like a useful feature. Make sure to cc linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
for new userspace interfaces. One comment on the implementation below.

> ---
>  fs/namei.c            | 12 +++++++++++-
>  include/linux/namei.h |  2 ++
>  2 files changed, 13 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/namei.c b/fs/namei.c
> index 70580ab..5f08b69 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -2148,7 +2148,7 @@ static const char *path_init(struct nameidata *nd, unsigned flags)
>  	nd->path.dentry = NULL;
>  
>  	nd->m_seq = read_seqbegin(&mount_lock);
> -	if (*s == '/') {
> +	if (*s == '/' && !(flags & LOOKUP_DFD_ROOT)) {
>  		if (flags & LOOKUP_RCU)
>  			rcu_read_lock();
>  		set_root(nd);
> @@ -2174,6 +2174,11 @@ static const char *path_init(struct nameidata *nd, unsigned flags)
>  			get_fs_pwd(current->fs, &nd->path);
>  			nd->inode = nd->path.dentry->d_inode;
>  		}
> +		if (flags & LOOKUP_DFD_ROOT) {
> +			nd->root = nd->path;
> +			if (!(flags & LOOKUP_RCU))
> +				path_get(&nd->root);

You're not initializing nd->root_seq here. That means that if we end up
going through unlazy_walk(), we're going to call legitimize_path() (and
thus read_seqcount_retry()) with stack garbage, get a spurious ECHILD,
and do an unnecessary restart of the path lookup instead of dropping
into ref-walk mode.

> +		}
>  		return s;
>  	} else {
>  		/* Caller must check execute permissions on the starting path component */
> @@ -2202,6 +2207,11 @@ static const char *path_init(struct nameidata *nd, unsigned flags)
>  			nd->inode = nd->path.dentry->d_inode;
>  		}
>  		fdput(f);
> +		if (flags & LOOKUP_DFD_ROOT) {
> +			nd->root = nd->path;
> +			if (!(flags & LOOKUP_RCU))
> +				path_get(&nd->root);
> +		}

Same here.

The following should do the trick:

diff --git a/fs/namei.c b/fs/namei.c
index 9958b605e822..101d1fb8d3cb 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2176,7 +2176,9 @@ static const char *path_init(struct nameidata *nd, unsigned flags)
 		}
 		if (flags & LOOKUP_DFD_ROOT) {
 			nd->root = nd->path;
-			if (!(flags & LOOKUP_RCU))
+			if (flags & LOOKUP_RCU)
+				nd->root_seq = nd->seq;
+			else
 				path_get(&nd->root);
 		}
 		return s;
@@ -2209,7 +2211,9 @@ static const char *path_init(struct nameidata *nd, unsigned flags)
 		fdput(f);
 		if (flags & LOOKUP_DFD_ROOT) {
 			nd->root = nd->path;
-			if (!(flags & LOOKUP_RCU))
+			if (flags & LOOKUP_RCU)
+				nd->root_seq = nd->seq;
+			else
 				path_get(&nd->root);
 		}
 		return s;

-- 
Omar
