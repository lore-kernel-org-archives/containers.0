From: Oren Laadan <orenl@librato.com>
Subject: Re: [PATCH 3/3] cr: add selinux support (v4)
Date: Fri, 02 Oct 2009 17:14:47 -0400
Message-ID: <4AC66D47.5050305@librato.com>
References: <20091002034916.GA16871@us.ibm.com> <20091002035250.GC16920@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20091002035250.GC16920@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org, Stephen Smalley <sds@epoch.ncsc.mil>, SELinux <selinux@tycho.nsa.gov>
List-Id: containers.vger.kernel.org


Serge E. Hallyn wrote:
> Documentation/checkpoint/readme.txt begins:
> """
> Application checkpoint/restart is the ability to save the state
> of a running application so that it can later resume its execution
> from the time at which it was checkpointed.
> """
> 
> This patch adds the ability to checkpoint and restore selinux
> contexts for tasks, open files, and sysvipc objects.  Contexts
> are checkpointed as strings.  For tasks and files, where a security
> struct actually points to several contexts, all contexts are
> written out in one string, separated by ':::'.
> 
> The default behaviors are to checkpoint contexts, but not to
> restore them.  To attempt to restore them, sys_restart() must
> be given the RESTART_KEEP_LSM flag.  If this is given then
> the caller of sys_restart() must have the new 'restore' permission
> to the target objclass, or for instance PROCESS__SETFSCREATE to
> itself to specify a create_sid.
> 
> There are some tests under cr_tests/selinux at
> git://git.sr71.net/~hallyn/cr_tests.git.
> 
> A corresponding simple refpolicy (and /usr/share/selinux/devel/include)
> patch is needed.
> 
> The programs to checkpoint and restart (called 'checkpoint' and
> 'restart') come from git://git.ncl.cs.columbia.edu/pub/git/user-cr.git.
> This patch applies against the checkpoint/restart-enabled kernel
> tree at git://git.ncl.cs.columbia.edu/pub/git/linux-cr.git/.
> 
> Changelog:
> 	oct 01: Remove some debugging that is redundant with
> 		avc log data.
> 	sep 10: (Most addressing suggestions by Stephen Smalley)
> 		1. change xyz_get_ctx() to xyz_checkpoint().
> 		2. check entrypoint permission on cred_restore
> 		3. always dec context length by 1
> 		4. don't allow SECSID_NULL when that's not valid
> 		5. when SECSID_NULL is valid, restore it
> 		6. c/r task->osid
> 		7. Just print nothing instead of 'null' for SECSID_NULL
> 		8. sids are __u32, as are lenghts passed to sid_to_context.
> 
> Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
> Cc: Stephen Smalley <sds@epoch.ncsc.mil>

I don't know much about SElinux, so this is only for
the strict c/r code...

> ---
>  checkpoint/restart.c                         |    1 +
>  kernel/cred.c                                |    2 +
>  security/selinux/hooks.c                     |  371 ++++++++++++++++++++++++++
>  security/selinux/include/av_perm_to_string.h |    4 +
>  security/selinux/include/av_permissions.h    |    4 +
>  5 files changed, 382 insertions(+), 0 deletions(-)
> 
> diff --git a/checkpoint/restart.c b/checkpoint/restart.c
> index 55bd2b5..008a116 100644
> --- a/checkpoint/restart.c
> +++ b/checkpoint/restart.c
> @@ -471,6 +471,7 @@ static int restore_read_header(struct ckpt_ctx *ctx)
>  		/* to be implemented later, per-lsm */
>  		if (strcmp(ctx->lsm_name, "lsm_none") != 0 &&
>  				strcmp(ctx->lsm_name, "smack") != 0 &&
> +				strcmp(ctx->lsm_name, "selinux") != 0 &&
>  				strcmp(ctx->lsm_name, "default") != 0) {

If we expect this to grow, it may make sense to look it up in an
array.

>  			pr_warning("c/r: RESTART_KEEP_LSM unsupported for %s\n",
>  					ctx->lsm_name);
> diff --git a/kernel/cred.c b/kernel/cred.c
> index 06bc676..5eb09b8 100644
> --- a/kernel/cred.c
> +++ b/kernel/cred.c
> @@ -732,6 +732,8 @@ static int do_checkpoint_cred(struct ckpt_ctx *ctx, struct cred *cred)
>  	if (!h)
>  		return -ENOMEM;
>  
> +	ckpt_debug("cred uid %d fsuid %d gid %d secref %d\n", cred->uid,
> +		cred->fsuid, cred->gid, sec_ref);

Please place this (and a few others also in other patches) debug-only
changes in a separate patch - it will make my life tremendously easier
when merging v18-dev to a nice and clean v19.

[...]

> +static inline char *selinux_file_checkpoint(void *security)
> +{
> +	struct file_security_struct *fsec = security;
> +	char *s1 = NULL, *s2 = NULL, *sfull;
> +	__u32 len1, len2, lenfull;
> +	int ret;
> +
> +	if (fsec->sid == 0 || fsec->fown_sid == 0)
> +		return ERR_PTR(-EINVAL);
> +
> +	ret = security_sid_to_context(fsec->sid, &s1, &len1);
> +	if (ret)
> +		return ERR_PTR(ret);
> +	len1--;
> +	ret = security_sid_to_context(fsec->fown_sid, &s2, &len2);
> +	if (ret) {
> +		kfree(s1);
> +		return ERR_PTR(ret);
> +	}
> +	len2--;
> +	lenfull = len1+len2+3;

Would checkpatch.pl complain about no spaces here ?

[...]

Hmm... the rest doesn't make sense to me anyway :o

Oren.

