From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: multi-threaded app fails to restart
Date: Mon, 26 Jul 2010 10:11:24 -0700
Message-ID: <8739v6tbgj.fsf@caffeine.danplanet.com>
References: <AANLkTilxfsYGyYLwO__VmDLSFQ_s_Qe03G49kIEztVja@mail.gmail.com>
	<1279569285.25071.98.camel@localhost>
	<AANLkTimpXSXQr1wew1wvZKnBFsOXD7f2tblY4EGmJoFM@mail.gmail.com>
	<4C4516DD.1000809@cs.columbia.edu>
	<AANLkTimPENgm-LSh6iMv2uxegRdHEivbGMTYmEfiOEJG@mail.gmail.com>
	<Pine.LNX.4.64.1007201906370.15255@takamine.ncl.cs.columbia.edu>
	<AANLkTinZYiWPtSegjRJWnlc6hipFAZyujr8-2ug6ettF@mail.gmail.com>
	<Pine.LNX.4.64.1007210143120.22870@takamine.ncl.cs.columbia.edu>
	<AANLkTinOFIzK8RZnp9NHouKv-WA7Omr08pPTGfrfVLfP@mail.gmail.com>
	<Pine.LNX.4.64.1007212102010.6257@takamine.ncl.cs.columbia.edu>
	<AANLkTimW98q0sFZeCAk3xHsEfBV9yhL4kUKHjNGxn_2P@mail.gmail.com>
	<Pine.LNX.4.64.1007260711310.1050@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.1007260711310.1050-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
	(Oren Laadan's message of "Mon\,
	26 Jul 2010 07\:18\:34 -0400 \(EDT\)")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

OL> diff --git a/kernel/checkpoint/sys.c b/kernel/checkpoint/sys.c
OL> index 171c867..c5517c2 100644
OL> --- a/kernel/checkpoint/sys.c
OL> +++ b/kernel/checkpoint/sys.c
OL> @@ -625,8 +625,11 @@ int walk_task_subtree(struct task_struct *root,
OL>  		}

OL>  		/* if we arrive at root again -- done */
OL> -		if (task == root)
OL> -			break;
OL> +		if (task == root) {
OL> +			/* if not last thread - proceed with thread */
OL> +			task = root = next_thread(task);
OL> +			if (thread_group_leader(task))
OL> +				break;

                } // Need to close this block

Otherwise it seems to work for me:

Tested-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
