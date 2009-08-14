From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/4] Expose may_setuid() in user.h
Date: Thu, 13 Aug 2009 19:52:41 -0500
Message-ID: <20090814005241.GA18538@us.ibm.com>
References: <1250191750-3864-1-git-send-email-danms@us.ibm.com>
	<1250191750-3864-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1250191750-3864-3-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Make this helper available to others.
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  include/linux/user.h |    9 +++++++++
>  kernel/user.c        |   16 +++++++++++++++-
>  2 files changed, 24 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/user.h b/include/linux/user.h
> index 68daf84..713bae7 100644
> --- a/include/linux/user.h
> +++ b/include/linux/user.h
> @@ -1 +1,10 @@
> +#ifndef _LINUX_USER_H
> +#define _LINUX_USER_H
> +
>  #include <asm/user.h>
> +#include <linux/sched.h>
> +
> +extern int may_setuid(struct user_namespace *ns, uid_t uid);
> +extern int may_setgid(struct group_info *groupinfo, gid_t gid);
> +
> +#endif
> diff --git a/kernel/user.c b/kernel/user.c
> index a535ed6..38b8b50 100644
> --- a/kernel/user.c
> +++ b/kernel/user.c
> @@ -604,7 +604,7 @@ int checkpoint_user(struct ckpt_ctx *ctx, void *ptr)
>  	return do_checkpoint_user(ctx, (struct user_struct *) ptr);
>  }
> 
> -static int may_setuid(struct user_namespace *ns, uid_t uid)
> +int may_setuid(struct user_namespace *ns, uid_t uid)
>  {
>  	/*
>  	 * this next check will one day become
> @@ -631,6 +631,20 @@ static int may_setuid(struct user_namespace *ns, uid_t uid)
>  	return 0;
>  }
> 
> +int may_setgid(struct group_info *groupinfo, gid_t gid)
> +{
> +	if (capable(CAP_SETGID))
> +		return 1;
> +
> +	if (current_cred_xxx(group_info) != groupinfo)
> +		return 0;
> +
> +	if (in_egroup_p(gid))
> +		return 1;
> +
> +	return 0;
> +}

All right, so unless you want to implement sticking a struct user
or struct cred in the peercreds :), just take out the middle part,
so make it:

> +int may_setgid(gid_t gid)
> +{
> +	if (capable(CAP_SETGID))
> +		return 1;
> +
> +	if (in_egroup_p(gid))
> +		return 1;
> +
> +	return 0;
> +}
