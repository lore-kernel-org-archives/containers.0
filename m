From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/7] C/R: Basic support for network namespaces and
	devices (v6)
Date: Thu, 18 Mar 2010 19:27:36 -0500
Message-ID: <20100319002736.GB5505@us.ibm.com>
References: <1268945512-18814-1-git-send-email-danms@us.ibm.com>
	<1268945512-18814-4-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1268945512-18814-4-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> - Remove init_netns_ref from container header and checkpoint context
...
> @@ -313,6 +323,7 @@ struct ckpt_hdr_tail {
>  /* container configuration section header */
>  struct ckpt_hdr_container {
>  	struct ckpt_hdr h;
> +	__s32 init_netns_ref;
>  	/*
>  	 * the header is followed by the string:
>  	 *   char lsm_name[SECURITY_NAME_MAX + 1]
...
> +++ b/include/linux/checkpoint_types.h
> @@ -82,6 +82,7 @@ struct ckpt_ctx {
>  	wait_queue_head_t ghostq;	/* waitqueue for ghost tasks */
>  	struct cred *realcred, *ecred;	/* tmp storage for cred at restart */
>  	struct list_head listen_sockets;/* listening parent sockets */
> +	int init_netns_ref;             /* Objref of root net namespace */
> 
>  	struct ckpt_stats stats;	/* statistics */
> 

Near as I can tell by grepping you don't seem to actually set
or use init_netns_ref anywhere.  Did it stay in these headers
by accident?

-serge
