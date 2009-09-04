From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [RFC PATCH 2/2] cr: debug security_checkpoint_header and	security_may_restart
Date: Thu, 03 Sep 2009 22:20:46 -0700
Message-ID: <4AA0A3AE.9040106@schaufler-ca.com>
References: <20090903222824.GB27377@us.ibm.com> <20090903222853.GA27556@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090903222853.GA27556@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org, SELinux <selinux@tycho.nsa.gov>, Casey Schaufler <casey@schaufler-ca.com>
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> This patch, for debugging only, introduces a silly admin-controlled
> 'policy version' for smack.  By default the version is 1.  An
> admin (with CAP_MAC_ADMIN) can change it by echoing a new value
> into /smack/version.
>   

The scheme you have suggested is just one step off of completely
acceptable for real. More detail below, but if you make the "version"
a string instead of a number I'm happy with it. In particular, a
string that would itself be a valid Smack label makes everything
really simple.

It would take me a few days, but if you're not in a real hurry or
you're lazier than I am (yeah, right) I could provide a patch that
does it. Or, if I haven't been completely incomprehensible, you
could do a revision.


> It then defines security_checkpoint_header() to add this 'policy
> version' into the checkpoint header, and defines security_may_restart()
> to refuse restart if both:
> 	1. the caller asked for RESTART_KEEP_LSM
> and
> 	2. the checkpointed version was different from the current.
>
> This of course is easy enough to test by doing
>
> 	echo 1 > /smack/version
> 	ckpt > out
> 	mktree < out
> 		succeed
> 	mktree -k < out
> 		succeed
> 	echo 2 > /smack/version
> 	mktree < out
> 		succeed
> 	mktree -k < out
> 		fail
>
> Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
> ---
>  security/smack/smack_lsm.c |   46 +++++++++++++++++++++++++++
>  security/smack/smackfs.c   |   75 ++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 121 insertions(+), 0 deletions(-)
>
> diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
> index 279fdce..f0d4a08 100644
> --- a/security/smack/smack_lsm.c
> +++ b/security/smack/smack_lsm.c
> @@ -27,6 +27,7 @@
>  #include <linux/udp.h>
>  #include <linux/mutex.h>
>  #include <linux/pipe_fs_i.h>
> +#include <linux/checkpoint.h>
>  #include <net/netlabel.h>
>  #include <net/cipso_ipv4.h>
>  #include <linux/audit.h>
> @@ -3111,6 +3112,47 @@ static void smack_release_secctx(char *secdata, u32 seclen)
>  {
>  }
>  
> +#ifdef CONFIG_CHECKPOINT
> +extern int smack_version;
>   

Make this a char * instead of an int and set it to
smack_known_floor.smk_known (which will be "_").


> +
> +static int smack_may_restart(struct ckpt_ctx *ctx)
>   

So as to reduce confusion between ctx's and checkpoint thingies,

   static int smack_may_restart(struct ckpt_ctx *ckptx)
> +{
> +	struct ckpt_hdr *h;
>   

How about:
          struct ckpt_hdr *chp;

instead for a little more consistency with Smack code.

> +	char *smackv;
> +	int v = 0, slen, ret;
> +
> +	h = ckpt_read_buf_type(ctx, CKPT_LSM_INFO_LEN, CKPT_HDR_LSM_INFO);
> +	if (IS_ERR(h))
> +		return PTR_ERR(h);
> +
> +	if (strcmp(ctx->lsm_name, "smack") != 0)
> +		return 0;
> +
> +	smackv = (char *) (h + 1);
>   

And delete from here ...

> +	slen = h->len - sizeof(*h);
> +	if (smackv[slen-1] != '\0')
> +		smackv[slen-1] = '\0';
> +	ret = sscanf(smackv, "%d", &v);
>   

... to here. How about we say that the version name meet the same
requirements as a label? A call to smk_import() can verify that and
take care of all the memory allocation business.

> +	ckpt_hdr_put(ctx, h);
> +	if (!(ctx->uflags & RESTART_KEEP_LSM))
> +		return 0;
> +	if (ret != 1 || v != smack_version) {
>   

Make this a strcmp()

> +		ckpt_debug("Smack version at checkpoint was %d, now is %d\n",
>   

%s instead of %d all around.

> +			v, smack_version);
> +		return -EINVAL;
> +	}
> +	return 0;
> +}
> +
> +static int smack_checkpoint_header(struct cpt_ctx *ctx)
> +{
> +	char smackv[10];
> +	sprintf(smackv, "%d", smack_version);
>   

You can drop this ...

> +	return ckpt_write_obj_type(ctx, smackv, strlen(smackv)+1,
> +				  CKPT_HDR_LSM_INFO);
>   

And pass back smack_version, which is a string.

> +}
> +#endif
> +
>  struct security_operations smack_ops = {
>  	.name =				"smack",
>  
> @@ -3245,6 +3287,10 @@ struct security_operations smack_ops = {
>  	.secid_to_secctx = 		smack_secid_to_secctx,
>  	.secctx_to_secid = 		smack_secctx_to_secid,
>  	.release_secctx = 		smack_release_secctx,
> +#ifdef CONFIG_CHECKPOINT
> +	.may_restart =			smack_may_restart,
> +	.checkpoint_header =		smack_checkpoint_header,
> +#endif
>  };
>  
>  
> diff --git a/security/smack/smackfs.c b/security/smack/smackfs.c
> index f83a809..7b20ad9 100644
> --- a/security/smack/smackfs.c
> +++ b/security/smack/smackfs.c
> @@ -42,6 +42,7 @@ enum smk_inos {
>  	SMK_NETLBLADDR	= 8,	/* single label hosts */
>  	SMK_ONLYCAP	= 9,	/* the only "capable" label */
>  	SMK_LOGGING	= 10,	/* logging */
> +	SMK_VERSION	= 11,	/* logging */
>  };
>  
>  /*
> @@ -51,6 +52,7 @@ static DEFINE_MUTEX(smack_list_lock);
>  static DEFINE_MUTEX(smack_cipso_lock);
>  static DEFINE_MUTEX(smack_ambient_lock);
>  static DEFINE_MUTEX(smk_netlbladdr_lock);
> +static DEFINE_MUTEX(smack_version_lock);
>  
>  /*
>   * This is the "ambient" label for network traffic.
> @@ -60,6 +62,11 @@ static DEFINE_MUTEX(smk_netlbladdr_lock);
>  char *smack_net_ambient = smack_known_floor.smk_known;
>  
>  /*
> + * this is the policy version, a simple integer
> + */
> +int smack_version = 1;
> +
>   

Make this a char * instead of an int and set it to
smack_known_floor.smk_known (which will be "_"). As above.


> +/*
>   * This is the level in a CIPSO header that indicates a
>   * smack label is contained directly in the category set.
>   * It can be reset via smackfs/direct
> @@ -1255,6 +1262,72 @@ static const struct file_operations smk_logging_ops = {
>  	.read		= smk_read_logging,
>  	.write		= smk_write_logging,
>  };
> +
> +#define SMK_VERSIONLEN 12
>   

    #define SMK_VERSIONLEN SMK_LABELLEN

> +/**
> + * smk_read_version - read() for /smack/version
> + * @filp: file pointer, not actually used
> + * @buf: where to put the result
> + * @cn: maximum to send along
> + * @ppos: where to start
> + *
> + * Returns number of bytes read or error code, as appropriate
> + */
> +static ssize_t smk_read_version(struct file *filp, char __user *buf,
> +				size_t count, loff_t *ppos)
> +{
> +	char temp[SMK_VERSIONLEN];
> +
> +	if (*ppos != 0)
> +		return 0;
> +
> +	mutex_lock(&smack_version_lock);
> +	sprintf(temp, "%d\n", smack_version);
>   

In the scheme I'm suggesting, no need for the sprintf.

> +	mutex_unlock(&smack_version_lock);
> +
> +	return simple_read_from_buffer(buf, count, ppos, temp, strlen(temp));
> +}
> +
> +/**
> + * smk_write_version - write() for /smack/version
> + * @file: file pointer, not actually used
> + * @buf: where to get the data from
> + * @count: bytes sent
> + * @ppos: where to start
> + *
> + * Returns number of bytes written or error code, as appropriate
> + */
> +static ssize_t smk_write_version(struct file *file, const char __user *buf,
> +				 size_t count, loff_t *ppos)
> +{
> +	char in[SMK_VERSIONLEN];
> +	int tmp, ret;
> +
> +	if (!capable(CAP_MAC_ADMIN))
> +		return -EPERM;
> +
> +	if (count >= SMK_VERSIONLEN)
> +		return -EINVAL;
> +
> +	if (copy_from_user(in, buf, count) != 0)
> +		return -EFAULT;
>   

This would become smk_import(), replacing ....

> +
> +	in[count-1] = '\0';
> +	ret = sscanf(in, "%d", &tmp);
> +	if (ret != 1)
> +		return -EINVAL;
>   

... this

> +	mutex_lock(&smack_version_lock);
> +	smack_version = tmp;
>   

and smack_version gets the return from smk_import unless it is NULL.

> +	mutex_unlock(&smack_version_lock);
> +
> +	return count;
> +}
> +
> +static const struct file_operations smk_version_ops = {
> +	.read		= smk_read_version,
> +	.write		= smk_write_version,
> +};
> +
>  /**
>   * smk_fill_super - fill the /smackfs superblock
>   * @sb: the empty superblock
> @@ -1287,6 +1360,8 @@ static int smk_fill_super(struct super_block *sb, void *data, int silent)
>  			{"onlycap", &smk_onlycap_ops, S_IRUGO|S_IWUSR},
>  		[SMK_LOGGING]	=
>  			{"logging", &smk_logging_ops, S_IRUGO|S_IWUSR},
> +		[SMK_VERSION]	=
> +			{"version", &smk_version_ops, S_IRUGO|S_IWUSR},
>  		/* last one */ {""}
>  	};
>  
>   

