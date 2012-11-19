From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH review 03/16] userns: Allow chown and setgid preservation
Date: Mon, 19 Nov 2012 11:49:52 -0600
Message-ID: <20121119174951.GA1883@serge-ThinkPad-X130e>
References: <87lidx8wbo.fsf@xmission.com>
	<1353337961-12962-1-git-send-email-ebiederm@xmission.com>
	<1353337961-12962-3-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1353337961-12962-3-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> 
> - Allow chown if CAP_CHOWN is present in the current user namespace
>   and the uid of the inode maps into the current user namespace, and
>   the destination uid or gid maps into the current user namespace.
> 
> - Allow perserving setgid when changing an inode if CAP_FSETID is
>   present in the current user namespace and the owner of the file has
>   a mapping into the current user namespace.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Acked-by: Serge E. Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>

> ---
>  fs/attr.c |   11 +++++++----
>  1 files changed, 7 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/attr.c b/fs/attr.c
> index cce7df5..1449adb 100644
> --- a/fs/attr.c
> +++ b/fs/attr.c
> @@ -49,14 +49,15 @@ int inode_change_ok(const struct inode *inode, struct iattr *attr)
>  	/* Make sure a caller can chown. */
>  	if ((ia_valid & ATTR_UID) &&
>  	    (!uid_eq(current_fsuid(), inode->i_uid) ||
> -	     !uid_eq(attr->ia_uid, inode->i_uid)) && !capable(CAP_CHOWN))
> +	     !uid_eq(attr->ia_uid, inode->i_uid)) &&
> +	    !inode_capable(inode, CAP_CHOWN))
>  		return -EPERM;
>  
>  	/* Make sure caller can chgrp. */
>  	if ((ia_valid & ATTR_GID) &&
>  	    (!uid_eq(current_fsuid(), inode->i_uid) ||
>  	    (!in_group_p(attr->ia_gid) && !gid_eq(attr->ia_gid, inode->i_gid))) &&
> -	    !capable(CAP_CHOWN))
> +	    !inode_capable(inode, CAP_CHOWN))
>  		return -EPERM;
>  
>  	/* Make sure a caller can chmod. */
> @@ -65,7 +66,8 @@ int inode_change_ok(const struct inode *inode, struct iattr *attr)
>  			return -EPERM;
>  		/* Also check the setgid bit! */
>  		if (!in_group_p((ia_valid & ATTR_GID) ? attr->ia_gid :
> -				inode->i_gid) && !capable(CAP_FSETID))
> +				inode->i_gid) &&
> +		    !inode_capable(inode, CAP_FSETID))
>  			attr->ia_mode &= ~S_ISGID;
>  	}
>  
> @@ -157,7 +159,8 @@ void setattr_copy(struct inode *inode, const struct iattr *attr)
>  	if (ia_valid & ATTR_MODE) {
>  		umode_t mode = attr->ia_mode;
>  
> -		if (!in_group_p(inode->i_gid) && !capable(CAP_FSETID))
> +		if (!in_group_p(inode->i_gid) &&
> +		    !inode_capable(inode, CAP_FSETID))
>  			mode &= ~S_ISGID;
>  		inode->i_mode = mode;
>  	}
> -- 
> 1.7.5.4
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
