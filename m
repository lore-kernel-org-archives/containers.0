From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/4] Update the UNIX buffer restore code to match the
	new format saved in the image file
Date: Wed, 11 Nov 2009 15:38:51 -0600
Message-ID: <20091111213851.GE8761@us.ibm.com>
References: <1257878856-25520-1-git-send-email-danms@us.ibm.com>
	<1257878856-25520-4-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1257878856-25520-4-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
>  	/* Make sure there's room in the send buffer */
>  	sndbuf = sk->sk_sndbuf;
> -	if (((sk->sk_sndbuf - atomic_read(&sk->sk_wmem_alloc)) < len) &&
> +	if (((sk->sk_sndbuf - atomic_read(&sk->sk_wmem_alloc)) < h->lin_len) &&
>  	    capable(CAP_NET_ADMIN))
> -		sk->sk_sndbuf += len;
> +		sk->sk_sndbuf += h->lin_len;
>  	else
>  		sk->sk_sndbuf = sysctl_wmem_max;

Can you explain what's going on here?  'if the size of the send buffer
minus tranmit queue bytes committed is less than linear length,
then if you're privileged you add h->len to sk->sk_sndbuf, but if
either you're not privileged or the length was greater than linear
length, then you add sysctl_wmem_max.'  ?

I realize that's a question on the original code, not on this
patch...

-serge
