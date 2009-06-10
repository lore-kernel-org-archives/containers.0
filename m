From: Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
Subject: Re: [PATCH 10/10] cr: lsm: restore file->f_security
Date: Tue, 09 Jun 2009 20:39:52 -0700
Message-ID: <4A2F2B08.40701@schaufler-ca.com>
References: <20090610014412.GA5628@us.ibm.com>
	<20090610014704.GI5658@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090610014704.GI5658-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, SELinux <selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Andrew Morgan <morgan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> file->f_cred is the cred of the task which opened it.  file->f_security
> can be separately set by the LSM.  Checkpoint the file->f_security,
> and at restart ask the LSM, using security_file_restore, based on the current
> task's context and the checkpointed f_security, which f_security to apply (or
> whether to refuse the restart altogether).
>
> For Smack, accept the checkpointed label if the restarting task has
> CAP_MAC_ADMIN.
>
> For SELinux, I currently ignore the checkpointed label and call
> file_alloc_security().  Do we want to have 'restore' permission for
> class file?
>
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/files.c             |   33 +++++++++++++++++++++++++++++++++
>  include/linux/checkpoint_hdr.h |    1 +
>  include/linux/security.h       |   13 +++++++++++++
>  security/capability.c          |    6 ++++++
>  security/security.c            |    5 +++++
>  security/selinux/hooks.c       |   11 +++++++++++
>  security/smack/smack_lsm.c     |   26 +++++++++++++++++++++++++-
>  7 files changed, 94 insertions(+), 1 deletions(-)
>
>   

> ...

> diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
> index dfc0f7a..7bcdfde 100644
> --- a/security/smack/smack_lsm.c
> +++ b/security/smack/smack_lsm.c
> @@ -831,6 +831,30 @@ static int smack_file_alloc_security(struct file *file)
>  }
>  
>  /**
> + * smack_file_restore_security - assign a file security blob
> + * @file: the object
> + * @stored: the label stored in the checkpoint file
> + *
> + * Returns 0
>   

Or -EINVAL if the label is not acceptable

> + */
> +static int smack_file_restore_security(struct file *file, void *stored)
> +{
> +	char *str = smk_import(stored, 0);
> +
> +	if (str == NULL)
> +		return -EINVAL;
> +
> +	file->f_security = current_security();
> +	if (current_security() != str) {
> +		if (!capable(CAP_MAC_ADMIN))
> +			return -EPERM;
> +		file->f_security = str;
> +	}
> +
> +	return 0;
> +}
> +
> +/**
>   * smack_file_free_security - clear a file security blob
>   * @file: the object
>   *
> @@ -1630,7 +1654,6 @@ static int smack_msg_msg_restore_security(struct msg_msg *msg,
>  		msg->security = str;
>  	}
>  	return 0;
> -	return 0;
>   

Looks like you caught that. Thank you

>  }
>  
>  /**
> @@ -2996,6 +3019,7 @@ struct security_operations smack_ops = {
>  
>  	.file_permission = 		smack_file_permission,
>  	.file_alloc_security = 		smack_file_alloc_security,
> +	.file_restore_security =	smack_file_restore_security,
>  	.file_free_security = 		smack_file_free_security,
>  	.file_ioctl = 			smack_file_ioctl,
>  	.file_lock = 			smack_file_lock,
>   
