From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 26/43] userns: Convert in_group_p and in_egroup_p to
	use kgid_t
Date: Wed, 18 Apr 2012 18:58:35 +0000
Message-ID: <20120418185835.GC5186__41482.7087348842$1334775476$gmane$org@mail.hallyn.com>
References: <m11unyn70b.fsf@fess.ebiederm.org>
	<1333862139-31737-26-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1333862139-31737-26-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
>  include/linux/cred.h |    4 ++--
>  kernel/groups.c      |   14 ++++++--------
>  2 files changed, 8 insertions(+), 10 deletions(-)
> 
> diff --git a/include/linux/cred.h b/include/linux/cred.h
> index fac0579..917dc5a 100644
> --- a/include/linux/cred.h
> +++ b/include/linux/cred.h
> @@ -73,8 +73,8 @@ extern int groups_search(const struct group_info *, kgid_t);
>  #define GROUP_AT(gi, i) \
>  	((gi)->blocks[(i) / NGROUPS_PER_BLOCK][(i) % NGROUPS_PER_BLOCK])
>  
> -extern int in_group_p(gid_t);
> -extern int in_egroup_p(gid_t);
> +extern int in_group_p(kgid_t);
> +extern int in_egroup_p(kgid_t);
>  
>  /*
>   * The common credentials for a thread group
> diff --git a/kernel/groups.c b/kernel/groups.c
> index 84156f2..6b2588d 100644
> --- a/kernel/groups.c
> +++ b/kernel/groups.c
> @@ -256,27 +256,25 @@ SYSCALL_DEFINE2(setgroups, int, gidsetsize, gid_t __user *, grouplist)
>  /*
>   * Check whether we're fsgid/egid or in the supplemental group..
>   */
> -int in_group_p(gid_t grp)
> +int in_group_p(kgid_t grp)
>  {
>  	const struct cred *cred = current_cred();
>  	int retval = 1;
>  
> -	if (grp != cred->fsgid)
> -		retval = groups_search(cred->group_info,
> -				       make_kgid(cred->user_ns, grp));
> +	if (!gid_eq(grp, cred->fsgid))
> +		retval = groups_search(cred->group_info, grp);
>  	return retval;
>  }
>  
>  EXPORT_SYMBOL(in_group_p);
>  
> -int in_egroup_p(gid_t grp)
> +int in_egroup_p(kgid_t grp)
>  {
>  	const struct cred *cred = current_cred();
>  	int retval = 1;
>  
> -	if (grp != cred->egid)
> -		retval = groups_search(cred->group_info,
> -				       make_kgid(cred->user_ns, grp));
> +	if (!gid_eq(grp, cred->egid))
> +		retval = groups_search(cred->group_info, grp);
>  	return retval;
>  }
>  
> -- 
> 1.7.2.5
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
