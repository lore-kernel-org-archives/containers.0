From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [REVIEW][PATCH 3/5] mnt: Correct permission checks in do_remount
Date: Thu, 31 Jul 2014 23:06:49 +0000
Message-ID: <20140731230649.GC7954@ubuntumail>
References: <20140724194920.GU26600@ubuntumail>
	<CAOP=4wh-AXf7qPy0rPaQ6RFbbJGRWKo0h1Rn=9vLUeJ6b6Q7YA@mail.gmail.com>
	<8738dqh2j1.fsf@x220.int.ebiederm.org>
	<20140725060810.GC31313@1wt.eu>
	<877g2xou2u.fsf@x220.int.ebiederm.org>
	<87r415nf3k.fsf_-_@x220.int.ebiederm.org>
	<874my1neyr.fsf_-_@x220.int.ebiederm.org>
	<CAOP=4wj7m+w4aDJCuQaf3r9aFraPN1SvPgFSz=_UNkyC8gEHyQ@mail.gmail.com>
	<87ppgnjyx4.fsf_-_@x220.int.ebiederm.org>
	<877g2vjyd7.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <877g2vjyd7.fsf_-_-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: Andrew Lutomirski <andy-RHosVwM/Cj8@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Willy Tarreau <w@1wt.eu>, security-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> 
> While invesgiating the issue where in "mount --bind -oremount,ro ..."
> would result in later "mount --bind -oremount,rw" succeeding even if
> the mount started off locked I realized that there are several
> additional mount flags that should be locked and are not.
> 
> In particular MNT_NOSUID, MNT_NODEV, MNT_NOEXEC, and the atime
> flags in addition to MNT_READONLY should all be locked.  These
> flags are all per superblock, can all be changed with MS_BIND,
> and should not be changable if set by a more privileged user.
> 
> The following additions to the current logic are added in this patch.
> - nosuid may not be clearable by a less privileged user.
> - nodev  may not be clearable by a less privielged user.
> - noexec may not be clearable by a less privileged user.
> - atime flags may not be changeable by a less privileged user.
> 
> The logic with atime is that always setting atime on access is a
> global policy and backup software and auditing software could break if
> atime bits are not updated (when they are configured to be updated),
> and serious performance degradation could result (DOS attack) if atime
> updates happen when they have been explicitly disabled.  Therefore an
> unprivileged user should not be able to mess with the atime bits set
> by a more privileged user.
> 
> The additional restrictions are implemented with the addition of
> MNT_LOCK_NOSUID, MNT_LOCK_NODEV, MNT_LOCK_NOEXEC, and MNT_LOCK_ATIME
> mnt flags.
> 
> Taken together these changes and the fixes for MNT_LOCK_READONLY
> should make it safe for an unprivileged user to create a user
> namespace and to call "mount --bind -o remount,... ..." without
> the danger of mount flags being changed maliciously.
> 
> Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

Acked-by: Serge E. Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>

> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>  fs/namespace.c        | 36 +++++++++++++++++++++++++++++++++---
>  include/linux/mount.h |  5 +++++
>  2 files changed, 38 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/namespace.c b/fs/namespace.c
> index 1105a577a14f..dd9c93b5a9d5 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -890,8 +890,21 @@ static struct mount *clone_mnt(struct mount *old, struct dentry *root,
>  
>  	mnt->mnt.mnt_flags = old->mnt.mnt_flags & ~(MNT_WRITE_HOLD|MNT_MARKED);
>  	/* Don't allow unprivileged users to change mount flags */
> -	if ((flag & CL_UNPRIVILEGED) && (mnt->mnt.mnt_flags & MNT_READONLY))
> -		mnt->mnt.mnt_flags |= MNT_LOCK_READONLY;
> +	if (flag & CL_UNPRIVILEGED) {
> +		mnt->mnt.mnt_flags |= MNT_LOCK_ATIME;
> +
> +		if (mnt->mnt.mnt_flags & MNT_READONLY)
> +			mnt->mnt.mnt_flags |= MNT_LOCK_READONLY;
> +
> +		if (mnt->mnt.mnt_flags & MNT_NODEV)
> +			mnt->mnt.mnt_flags |= MNT_LOCK_NODEV;
> +
> +		if (mnt->mnt.mnt_flags & MNT_NOSUID)
> +			mnt->mnt.mnt_flags |= MNT_LOCK_NOSUID;
> +
> +		if (mnt->mnt.mnt_flags & MNT_NOEXEC)
> +			mnt->mnt.mnt_flags |= MNT_LOCK_NOEXEC;
> +	}
>  
>  	/* Don't allow unprivileged users to reveal what is under a mount */
>  	if ((flag & CL_UNPRIVILEGED) && list_empty(&old->mnt_expire))
> @@ -1931,6 +1944,23 @@ static int do_remount(struct path *path, int flags, int mnt_flags,
>  	    !(mnt_flags & MNT_READONLY)) {
>  		return -EPERM;
>  	}
> +	if ((mnt->mnt.mnt_flags & MNT_LOCK_NODEV) &&
> +	    !(mnt_flags & MNT_NODEV)) {
> +		return -EPERM;
> +	}
> +	if ((mnt->mnt.mnt_flags & MNT_LOCK_NOSUID) &&
> +	    !(mnt_flags & MNT_NOSUID)) {
> +		return -EPERM;
> +	}
> +	if ((mnt->mnt.mnt_flags & MNT_LOCK_NOEXEC) &&
> +	    !(mnt_flags & MNT_NOEXEC)) {
> +		return -EPERM;
> +	}
> +	if ((mnt->mnt.mnt_flags & MNT_LOCK_ATIME) &&
> +	    ((mnt->mnt.mnt_flags & MNT_ATIME_MASK) != (mnt_flags & MNT_ATIME_MASK))) {
> +		return -EPERM;
> +	}
> +
>  	err = security_sb_remount(sb, data);
>  	if (err)
>  		return err;
> @@ -2129,7 +2159,7 @@ static int do_new_mount(struct path *path, const char *fstype, int flags,
>  		 */
>  		if (!(type->fs_flags & FS_USERNS_DEV_MOUNT)) {
>  			flags |= MS_NODEV;
> -			mnt_flags |= MNT_NODEV;
> +			mnt_flags |= MNT_NODEV | MNT_LOCK_NODEV;
>  		}
>  	}
>  
> diff --git a/include/linux/mount.h b/include/linux/mount.h
> index b637a89e1fae..b0c1e6574e7f 100644
> --- a/include/linux/mount.h
> +++ b/include/linux/mount.h
> @@ -45,12 +45,17 @@ struct mnt_namespace;
>  #define MNT_USER_SETTABLE_MASK  (MNT_NOSUID | MNT_NODEV | MNT_NOEXEC \
>  				 | MNT_NOATIME | MNT_NODIRATIME | MNT_RELATIME \
>  				 | MNT_READONLY)
> +#define MNT_ATIME_MASK (MNT_NOATIME | MNT_NODIRATIME | MNT_RELATIME )
>  
>  #define MNT_INTERNAL_FLAGS (MNT_SHARED | MNT_WRITE_HOLD | MNT_INTERNAL | \
>  			    MNT_DOOMED | MNT_SYNC_UMOUNT | MNT_MARKED)
>  
>  #define MNT_INTERNAL	0x4000
>  
> +#define MNT_LOCK_ATIME		0x040000
> +#define MNT_LOCK_NOEXEC		0x080000
> +#define MNT_LOCK_NOSUID		0x100000
> +#define MNT_LOCK_NODEV		0x200000
>  #define MNT_LOCK_READONLY	0x400000
>  #define MNT_LOCKED		0x800000
>  #define MNT_DOOMED		0x1000000
> -- 
> 1.9.1
> 
