From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 21/31] blk-throttle: implement sq_to_tg(), sq_to_td() and
	throtl_log()
Date: Mon, 6 May 2013 13:36:44 -0400
Message-ID: <20130506173644.GD11731@redhat.com>
References: <1367455189-6957-1-git-send-email-tj@kernel.org>
	<1367455189-6957-22-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1367455189-6957-22-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, May 01, 2013 at 05:39:39PM -0700, Tejun Heo wrote:

[..]
> +#define throtl_log(sq, fmt, args...)	do {				\
> +	struct throtl_grp *__tg = sq_to_tg((sq));			\
> +	struct throtl_data *__td = sq_to_td((sq));			\
>  	char __pbuf[128];						\
>  									\
> -	blkg_path(tg_to_blkg(tg), __pbuf, sizeof(__pbuf));		\
> -	blk_add_trace_msg((tg)->td->queue, "throtl %s " fmt, __pbuf, ##args); \
> +	__pbuf[0] = ' ';						\
> +	__pbuf[1] = '\0';						\
> +	if ((__tg))							\
> +		blkg_path(tg_to_blkg(__tg), __pbuf + 1, sizeof(__pbuf) - 1); \
> +	blk_add_trace_msg(__td->queue, "throtl%s" fmt, __pbuf, ##args); \
						^^

We need one extra space ("throtl%s "), otherwise all the messages
start right after cgroup path. We need a space between cgroup path
and actual message.

Thanks
Vivek
