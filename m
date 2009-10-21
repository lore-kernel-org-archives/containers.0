From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/4] Adjust TCP timestamp values by a scalar value
Date: Wed, 21 Oct 2009 13:06:38 -0500
Message-ID: <20091021180638.GA24465@us.ibm.com>
References: <1256072803-3518-1-git-send-email-danms@us.ibm.com>
	<1256072803-3518-4-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1256072803-3518-4-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> Adjust the sent and received TCP timestamp value by a scalar value
> in the tcp_sock structure.  This will be zero most of the time, except
> when the socket has been migrated with c/r.  If a socket is re-migrated,
> we take the new adjusted value as the saved value so that on restart it
> can be re-adjusted.  Also, copy this into the timewait sock so that
> timestamps can continue to be adjusted in timewait state in the
> minisocks code.
> 
> Note that TCP timestamps are just a jiffies stamp, which means they
> have no relation to wall-clock time and thus a simple correction
> factor should be enough to ensure correctness.
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

...

> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index 8afac76..b845e21 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -399,6 +399,8 @@ struct tcp_sock {
>  		u32		  probe_seq_end;
>  	} mtu_probe;
> 
> +	s32	ts_adjust;	/* tcp_time_stamp adjustment factor */
> +
>  #ifdef CONFIG_TCP_MD5SIG
>  /* TCP AF-Specific parts; only used by MD5 Signature support so far */
>  	struct tcp_sock_af_ops	*af_specific;
> @@ -420,6 +422,7 @@ struct tcp_timewait_sock {
>  	u32			  tw_rcv_wnd;
>  	u32			  tw_ts_recent;
>  	long			  tw_ts_recent_stamp;
> +	s32			  tw_ts_adjust;
>  #ifdef CONFIG_TCP_MD5SIG
>  	u16			  tw_md5_keylen;
>  	u8			  tw_md5_key[TCP_MD5SIG_MAXKEYLEN];

I think this definately needs to go by netdev to see if they object
to the extra fields, and the (negligable?) extra processing in
frequent paths like tcp_send_ack.

-serge
