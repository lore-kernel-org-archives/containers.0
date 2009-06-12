From: Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
Subject: Re: [PATCH 1/1] cls_cgroup: unify classid syntax to tc
Date: Fri, 12 Jun 2009 12:40:28 +0900
Message-ID: <20090612124028.fe4c2100.usui__20078.3898741522$1244781310$gmane$org@mxm.nes.nec.co.jp>
References: <20090611180555.f2c76568.usui@mxm.nes.nec.co.jp>
	<20090611.021347.142243970.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090611.021347.142243970.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: tgraf-G/eBtMaohhA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org, jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Hi, David

Thank you for your comments.

On Thu, 11 Jun 2009 02:13:47 -0700 (PDT)
David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:

> From: Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
> Date: Thu, 11 Jun 2009 18:05:55 +0900
> 
> > This patch unifies classid syntax of cls_cgroup to tc.
> 
> Won't this break existing users?
> 
> We really can't say "oh sorry" and change things after it's
> been effectively deployed already.

It's true. If my patch applied, old syntax can't use.
But I think compatibility is important, too.
So I'll make a new patch which can use both old and new syntax, when we write classid to net_cls.classid file.

Present implementation is an asymmetry with read and write.(read: decimal, write: hexadecimal)
I think this might be interface bug, so I think we should unify to read/write syntax. 
Of course, if read syntax change from decimal expression, there isn't compatibility.
But I think it's better to fix this problem. 
What do you think?

If it's ok, I'd like to be able to use tc syntax(X:Y style),
because cls_cgroup's purpose is select class which create by tc command.
tc command can only use classid syntax X:Y style, so we should be able to use X:Y style to cls_cgroup. 
-- 
Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
