From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 30/43] userns: Fail exec for suid and sgid binaries
	with ids outside our user namespace.
Date: Wed, 18 Apr 2012 19:05:14 +0000
Message-ID: <20120418190514.GH5186__30093.6129446656$1334775873$gmane$org@mail.hallyn.com>
References: <m11unyn70b.fsf@fess.ebiederm.org>
	<1333862139-31737-30-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1333862139-31737-30-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Beiderman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Beiderman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> From: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> 
> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

> ---
>  fs/exec.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/exec.c b/fs/exec.c
> index 00ae2ef..e001bdf 100644
> --- a/fs/exec.c
> +++ b/fs/exec.c
> @@ -1291,8 +1291,11 @@ int prepare_binprm(struct linux_binprm *bprm)
>  	if (!(bprm->file->f_path.mnt->mnt_flags & MNT_NOSUID)) {
>  		/* Set-uid? */
>  		if (mode & S_ISUID) {
> +			if (!kuid_has_mapping(bprm->cred->user_ns, inode->i_uid))
> +				return -EPERM;
>  			bprm->per_clear |= PER_CLEAR_ON_SETID;
>  			bprm->cred->euid = inode->i_uid;
> +
>  		}
>  
>  		/* Set-gid? */
> @@ -1302,6 +1305,8 @@ int prepare_binprm(struct linux_binprm *bprm)
>  		 * executable.
>  		 */
>  		if ((mode & (S_ISGID | S_IXGRP)) == (S_ISGID | S_IXGRP)) {
> +			if (!kgid_has_mapping(bprm->cred->user_ns, inode->i_gid))
> +				return -EPERM;
>  			bprm->per_clear |= PER_CLEAR_ON_SETID;
>  			bprm->cred->egid = inode->i_gid;
>  		}
> -- 
> 1.7.2.5
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
