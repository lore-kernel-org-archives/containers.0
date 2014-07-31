From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [REVIEW][PATCH 2/5] mnt: Move the test for MNT_LOCK_READONLY
	from change_mount_flags into do_remount
Date: Thu, 31 Jul 2014 23:11:41 +0000
Message-ID: <20140731231141.GD7954@ubuntumail>
References: <20140724194920.GU26600@ubuntumail>
	<CAOP=4wh-AXf7qPy0rPaQ6RFbbJGRWKo0h1Rn=9vLUeJ6b6Q7YA@mail.gmail.com>
	<8738dqh2j1.fsf@x220.int.ebiederm.org>
	<20140725060810.GC31313@1wt.eu>
	<877g2xou2u.fsf@x220.int.ebiederm.org>
	<87r415nf3k.fsf_-_@x220.int.ebiederm.org>
	<874my1neyr.fsf_-_@x220.int.ebiederm.org>
	<CAOP=4wj7m+w4aDJCuQaf3r9aFraPN1SvPgFSz=_UNkyC8gEHyQ@mail.gmail.com>
	<87ppgnjyx4.fsf_-_@x220.int.ebiederm.org>
	<87bns7jye1.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87bns7jye1.fsf_-_-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
> There are no races as locked mount flags are guaranteed to never change.
> 
> Moving the test into do_remount makes it more visible, and ensures all
> filesystem remounts pass the MNT_LOCK_READONLY permission check.  This
> second case is not an issue today as filesystem remounts are guarded
> by capable(CAP_DAC_ADMIN) and thus will always fail in less privileged
> mount namespaces, but it could become an issue in the future.
> 
> Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Acked-by: Serge E. Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>

> ---
>  fs/namespace.c | 13 ++++++++++---
>  1 file changed, 10 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/namespace.c b/fs/namespace.c
> index cb40449ea0df..1105a577a14f 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -1896,9 +1896,6 @@ static int change_mount_flags(struct vfsmount *mnt, int ms_flags)
>  	if (readonly_request == __mnt_is_readonly(mnt))
>  		return 0;
>  
> -	if (mnt->mnt_flags & MNT_LOCK_READONLY)
> -		return -EPERM;
> -
>  	if (readonly_request)
>  		error = mnt_make_readonly(real_mount(mnt));
>  	else
> @@ -1924,6 +1921,16 @@ static int do_remount(struct path *path, int flags, int mnt_flags,
>  	if (path->dentry != path->mnt->mnt_root)
>  		return -EINVAL;
>  
> +	/* Don't allow changing of locked mnt flags.
> +	 *
> +	 * No locks need to be held here while testing the various
> +	 * MNT_LOCK flags because those flags can never be cleared
> +	 * once they are set.
> +	 */
> +	if ((mnt->mnt.mnt_flags & MNT_LOCK_READONLY) &&
> +	    !(mnt_flags & MNT_READONLY)) {
> +		return -EPERM;
> +	}
>  	err = security_sb_remount(sb, data);
>  	if (err)
>  		return err;
> -- 
> 1.9.1
> 
