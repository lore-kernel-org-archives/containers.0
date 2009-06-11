From: Thomas Graf <tgraf-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH 1/1] cls_cgroup: unify classid syntax to tc
Date: Thu, 11 Jun 2009 05:31:49 -0400
Message-ID: <20090611093149.GA12543__47968.2719837458$1244712760$gmane$org@bombadil.infradead.org>
References: <20090611180555.f2c76568.usui@mxm.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090611180555.f2c76568.usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
Cc: tgraf-G/eBtMaohhA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org, jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Very nice, this is a big improvement.

On Thu, Jun 11, 2009 at 06:05:55PM +0900, Minoru Usui wrote:
> +static int get_tc_classid(u32 *classid, const char *str)

Maybe make this return u32?

>  {
> -	return cgrp_cls_state(cgrp)->classid;
> +	u32 maj, min;
> +	char *p;
> +
> +	/* check "0" for reset request */
> +	if (!strcmp(str, "0")) {
> +		*classid = 0;
> +		return 0;
> +	}
> +
> +	/* parse major number */
> +	maj = simple_strtoul(str, &p, 16);
> +	if (p == str) {
> +		maj = 0;
> +		if (*p != ':')
> +			return -EINVAL;
> +	}
> +
> +	/* parse minor number */
> +	if (*p == ':') {
> +		if (maj >= (1<<16))
> +			return -EINVAL;
> +
> +		str = p + 1;
> +		min = simple_strtoul(str, &p, 16);
> +		if (*p != 0)
> +			return -EINVAL;
> +		if (min >= (1<<16))
> +			return -EINVAL;
> +	} else if (*p != 0)
> +		return -EINVAL;

What do you think about keeping things backwards compatible by
accepting both the X:Y and XY format?

} else if (*p != 0)
	return strtoul(str, NULL, 0);
