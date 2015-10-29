From: Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
Subject: Re: [PATCH v4 06/11] smack: don't use implicit star to display
	smackfs/syslog
Date: Thu, 29 Oct 2015 15:50:51 -0700
Message-ID: <5632A2CB.1000702@schaufler-ca.com>
References: <1444826525-9758-1-git-send-email-l.pawelczyk@samsung.com>
	<1444826525-9758-7-git-send-email-l.pawelczyk@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1444826525-9758-7-git-send-email-l.pawelczyk-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Lukasz Pawelczyk <l.pawelczyk-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Calvin Owens <calvinowens-b10kYP2dOMg@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>, Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Jiri Slaby <jslaby-IBi9RG/b67k@public.gmane.org>, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>, John Johansen <john.johansen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Mauro Carvalho Chehab <mchehab-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>, NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>, Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>Serge
Cc: Lukasz Pawelczyk <havner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On 10/14/2015 5:42 AM, Lukasz Pawelczyk wrote:
> Smackfs/syslog is analogous to onlycap and unconfined. When not filled
> they don't do anything. In such cases onlycap and unconfined displayed
> nothing when read, but syslog unconditionally displayed star. This
> doesn't work well with namespaces where the star could have been
> unmapped. Besides the meaning of this star was different then a star
> that could be written to this file. This was misleading.
>
> This also brings syslog read/write functions on par with onlycap and
> unconfined where it is possible to reset the value to NULL as should be
> possible according to comment in smackfs.c describing smack_syslog_label
> variable.
>
> Before that the initial state was to allow (smack_syslog_label was
> NULL), but after writing star to it the current had to be labeled star
> as well to have an access, even thought reading the smackfs/syslog
> returned the same result in both cases.
>
> Signed-off-by: Lukasz Pawelczyk <l.pawelczyk-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
> Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

Acked-by: Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>


> ---
>  security/smack/smackfs.c | 42 +++++++++++++++++++++++++++---------------
>  1 file changed, 27 insertions(+), 15 deletions(-)
>
> diff --git a/security/smack/smackfs.c b/security/smack/smackfs.c
> index ce8d503..05e09ee2 100644
> --- a/security/smack/smackfs.c
> +++ b/security/smack/smackfs.c
> @@ -2634,23 +2634,20 @@ static const struct file_operations smk_change_rule_ops = {
>  static ssize_t smk_read_syslog(struct file *filp, char __user *buf,
>  				size_t cn, loff_t *ppos)
>  {
> -	struct smack_known *skp;
> +	char *smack = "";
>  	ssize_t rc = -EINVAL;
>  	int asize;
>  
>  	if (*ppos != 0)
>  		return 0;
>  
> -	if (smack_syslog_label == NULL)
> -		skp = &smack_known_star;
> -	else
> -		skp = smack_syslog_label;
> +	if (smack_syslog_label != NULL)
> +		smack = smack_syslog_label->smk_known;
>  
> -	asize = strlen(skp->smk_known) + 1;
> +	asize = strlen(smack) + 1;
>  
>  	if (cn >= asize)
> -		rc = simple_read_from_buffer(buf, cn, ppos, skp->smk_known,
> -						asize);
> +		rc = simple_read_from_buffer(buf, cn, ppos, smack, asize);
>  
>  	return rc;
>  }
> @@ -2678,16 +2675,31 @@ static ssize_t smk_write_syslog(struct file *file, const char __user *buf,
>  	if (data == NULL)
>  		return -ENOMEM;
>  
> -	if (copy_from_user(data, buf, count) != 0)
> +	if (copy_from_user(data, buf, count) != 0) {
>  		rc = -EFAULT;
> -	else {
> -		skp = smk_import_entry(data, count);
> -		if (IS_ERR(skp))
> -			rc = PTR_ERR(skp);
> -		else
> -			smack_syslog_label = skp;
> +		goto freeout;
>  	}
>  
> +	/*
> +	 * Clear the smack_syslog_label on invalid label errors. This means
> +	 * that we can pass a null string to unset the syslog value.
> +	 *
> +	 * Importing will also reject a label beginning with '-',
> +	 * so "-syslog" will also work.
> +	 *
> +	 * But do so only on invalid label, not on system errors.
> +	 */
> +	skp = smk_import_entry(data, count);
> +	if (PTR_ERR(skp) == -EINVAL)
> +		skp = NULL;
> +	else if (IS_ERR(skp)) {
> +		rc = PTR_ERR(skp);
> +		goto freeout;
> +	}
> +
> +	smack_syslog_label = skp;
> +
> +freeout:
>  	kfree(data);
>  	return rc;
>  }
