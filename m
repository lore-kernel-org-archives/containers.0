From: Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
Subject: Re: [PATCH 1/1] cls_cgroup: unify classid syntax to tc
Date: Fri, 12 Jun 2009 10:02:07 +0900
Message-ID: <20090612100207.6f21b208.usui__32873.6588861377$1244769253$gmane$org@mxm.nes.nec.co.jp>
References: <20090611180555.f2c76568.usui@mxm.nes.nec.co.jp>
	<20090611093149.GA12543@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090611093149.GA12543-PfSpb0PWhxZc2C7mugBRk2EX/6BAtgUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Thomas Graf <tgraf-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: tgraf-G/eBtMaohhA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org, jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Hi, Thomas

Thank you for your comments.

On Thu, 11 Jun 2009 05:31:49 -0400
Thomas Graf <tgraf-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org> wrote:

> Very nice, this is a big improvement.
> 
> On Thu, Jun 11, 2009 at 06:05:55PM +0900, Minoru Usui wrote:
> > +static int get_tc_classid(u32 *classid, const char *str)
> 
> Maybe make this return u32?

Yes, you are right.
I'll fix it.

> 
> >  {
> > -	return cgrp_cls_state(cgrp)->classid;
> > +	u32 maj, min;
> > +	char *p;
> > +
> > +	/* check "0" for reset request */
> > +	if (!strcmp(str, "0")) {
> > +		*classid = 0;
> > +		return 0;
> > +	}
> > +
> > +	/* parse major number */
> > +	maj = simple_strtoul(str, &p, 16);
> > +	if (p == str) {
> > +		maj = 0;
> > +		if (*p != ':')
> > +			return -EINVAL;
> > +	}
> > +
> > +	/* parse minor number */
> > +	if (*p == ':') {
> > +		if (maj >= (1<<16))
> > +			return -EINVAL;
> > +
> > +		str = p + 1;
> > +		min = simple_strtoul(str, &p, 16);
> > +		if (*p != 0)
> > +			return -EINVAL;
> > +		if (min >= (1<<16))
> > +			return -EINVAL;
> > +	} else if (*p != 0)
> > +		return -EINVAL;
> 
> What do you think about keeping things backwards compatible by
> accepting both the X:Y and XY format?
> 
> } else if (*p != 0)
> 	return strtoul(str, NULL, 0);

OK. I'll do it.
-- 
Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
