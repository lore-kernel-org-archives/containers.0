From: "Luis R. Rodriguez" <mcgrof-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 03/11] fs: Allow superblock owner to change ownership of
	inodes
Date: Fri, 5 Jan 2018 20:24:07 +0100
Message-ID: <20180105192407.GF22430__24146.6470215984$1515180179$gmane$org@wotan.suse.de>
References: <cover.1512741134.git.dongsu@kinvolk.io>
	<ac3d34002d7690f6ca5928b57b7fc4d707104b04.1512041070.git.dongsu@kinvolk.io>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <ac3d34002d7690f6ca5928b57b7fc4d707104b04.1512041070.git.dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
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
Cc: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, "Luis R. Rodriguez" <mcgrof-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Dec 22, 2017 at 03:32:27PM +0100, Dongsu Park wrote:
> diff --git a/fs/attr.c b/fs/attr.c
> index 12ffdb6f..bf8e94f3 100644
> --- a/fs/attr.c
> +++ b/fs/attr.c
> @@ -18,6 +18,30 @@
>  #include <linux/evm.h>
>  #include <linux/ima.h>
>  
> +static bool chown_ok(const struct inode *inode, kuid_t uid)
> +{
> +	if (uid_eq(current_fsuid(), inode->i_uid) &&
> +	    uid_eq(uid, inode->i_uid))
> +		return true;
> +	if (capable_wrt_inode_uidgid(inode, CAP_CHOWN))
> +		return true;
> +	if (ns_capable(inode->i_sb->s_user_ns, CAP_CHOWN))
> +		return true;
> +	return false;
> +}
> +
> +static bool chgrp_ok(const struct inode *inode, kgid_t gid)
> +{
> +	if (uid_eq(current_fsuid(), inode->i_uid) &&
> +	    (in_group_p(gid) || gid_eq(gid, inode->i_gid)))
> +		return true;
> +	if (capable_wrt_inode_uidgid(inode, CAP_CHOWN))
> +		return true;
> +	if (ns_capable(inode->i_sb->s_user_ns, CAP_CHOWN))
> +		return true;
> +	return false;
> +}
> +
>  /**
>   * setattr_prepare - check if attribute changes to a dentry are allowed
>   * @dentry:	dentry to check
> @@ -52,17 +76,11 @@ int setattr_prepare(struct dentry *dentry, struct iattr *attr)
>  		goto kill_priv;
>  
>  	/* Make sure a caller can chown. */
> -	if ((ia_valid & ATTR_UID) &&
> -	    (!uid_eq(current_fsuid(), inode->i_uid) ||
> -	     !uid_eq(attr->ia_uid, inode->i_uid)) &&
> -	    !capable_wrt_inode_uidgid(inode, CAP_CHOWN))
> +	if ((ia_valid & ATTR_UID) && !chown_ok(inode, attr->ia_uid))
>  		return -EPERM;

I think this patch would read much better and easier to review if it was
split up by first adding the helpers, and then extending them afterwards.

>  
>  	/* Make sure caller can chgrp. */
> -	if ((ia_valid & ATTR_GID) &&
> -	    (!uid_eq(current_fsuid(), inode->i_uid) ||
> -	    (!in_group_p(attr->ia_gid) && !gid_eq(attr->ia_gid, inode->i_gid))) &&
> -	    !capable_wrt_inode_uidgid(inode, CAP_CHOWN))
> +	if ((ia_valid & ATTR_GID) && !chgrp_ok(inode, attr->ia_gid))
>  		return -EPERM;
>  
>  	/* Make sure a caller can chmod. */
> diff --git a/fs/proc/base.c b/fs/proc/base.c
> index 31934cb9..9d50ec92 100644
> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -665,10 +665,17 @@ int proc_setattr(struct dentry *dentry, struct iattr *attr)
>  {
>  	int error;
>  	struct inode *inode = d_inode(dentry);
> +	struct user_namespace *s_user_ns;
>  
>  	if (attr->ia_valid & ATTR_MODE)
>  		return -EPERM;
>  
> +	/* Don't let anyone mess with weird proc files */
> +	s_user_ns = inode->i_sb->s_user_ns;
> +	if (!kuid_has_mapping(s_user_ns, inode->i_uid) ||
> +	    !kgid_has_mapping(s_user_ns, inode->i_gid))
> +		return -EPERM;
> +
>  	error = setattr_prepare(dentry, attr);
>  	if (error)
>  		return error;

Are we sure proc is the only special one? How was it observed first that this was
require for proc? Has anyone tried fuzzing by trying this op with a slew of other
filesystems on all files?

  Luis
