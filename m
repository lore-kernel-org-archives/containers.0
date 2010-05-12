From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 2/4][cr]: Define __f_setown_uid()
Date: Wed, 12 May 2010 03:06:29 -0500
Message-ID: <20100512080629.GB2636@us.ibm.com>
References: <1273617500-13653-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<1273617500-13653-3-git-send-email-sukadev@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1273617500-13653-3-git-send-email-sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Sukadev Bhattiprolu (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):

[From patch 2]

> @@ -222,9 +222,16 @@ int __f_setown(struct file *filp, struct pid *pid, enum pid_type type,
>  	if (err)
>  		return err;
> 
> -	f_modown(filp, pid, type, current_uid(), current_euid(), force);
> +	f_modown(filp, pid, type, uid, euid, force);
>  	return 0;
>  }
> +
> +int __f_setown(struct file *filp, struct pid *pid, enum pid_type type,
> +		int force)
> +{
> +	return __f_setown_uid(filp, pid, type, current_uid(), current_euid(),
> +			force);
> +}
>  EXPORT_SYMBOL(__f_setown);

[From patch 4]

> +	/*
> +	 * TODO: Do we need to force==1 or can it be 0 ? 'force' is used to
> +	 * 	 modify the owner, if one is already set. Can it be set when
> +	 * 	 we restart an application ?
> +	 */
> +	ret = __f_setown_uid(file, pid, h->f_owner_pid_type, h->f_owner_uid,
> +			h->f_owner_euid, 1);
> +	rcu_read_unlock();

I think you need to modify how __f_setown() is calling
security_file_set_fowner().  Though I guess noone looks at the
current_uid(), so maybe it's not so important at this point.

(I do wonder whether converting fowner to using a struct cred
is the way to go)

-serge
