From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [Devel] Re: [PATCH 1/1] cls_cgroup: unify classid syntax to tc
Date: Thu, 18 Jun 2009 10:01:27 +0800
Message-ID: <4A399FF7.5060209__5566.78254292837$1245290441$gmane$org@cn.fujitsu.com>
References: <20090611180555.f2c76568.usui@mxm.nes.nec.co.jp>	<20090611.021347.142243970.davem@davemloft.net>	<20090612124028.fe4c2100.usui@mxm.nes.nec.co.jp>	<6599ad830906112206n745fb0dw19cdb75d7c40b2a4@mail.gmail.com>	<20090615120035.a8b7b38f.usui@mxm.nes.nec.co.jp>	<20090615101919.GC7768@bombadil.infradead.org>
	<20090617094907.e8cd77bd.usui@mxm.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090617094907.e8cd77bd.usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
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
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, tgraf-G/eBtMaohhA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Thomas Graf <tgraf-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Minoru Usui wrote:
> On Mon, 15 Jun 2009 06:19:19 -0400
> Thomas Graf <tgraf-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org> wrote:
> 
>> On Mon, Jun 15, 2009 at 12:00:35PM +0900, Minoru Usui wrote:
>>> Actually, In tc <-> kernel I/F (which uses netlink), tc sets classid to hexadecimal style not X:Y style.
>>> X:Y style is result of translating by tc command.
>>>
>>> I thought this patch was very useful at first, but it's not necessary to implementing to the kernel.
>>> This function can be implemented on user space if we need.
>>> And we can also keep compatibility of net_cls.classid I/F. :-)
>>>
>>> I drop this patch. I'm sorry for confusing a lot of people.
>> I found this patch to be extremely useful if it wasn't to break
>> compatibility but that issue can be resolved by accepting both
>> formats easly.
> 
> Thank you for agreeing my patch.
> 
> I think you said write format only. Am I right?
> What do you think about read format?
> Do you think you should keep read format as current implementation?
> 
> I think we should need to unify read/write format, if we make cls_cgroup is more userfriendly. 
> Because some of people are confused about having to read their write value as different format.
> (Unfortunately, current implementation is so...)
> 
> But this approach breaks compatibility, so I drop this patch.

How about adding a new control file net_cls.tc_classid?
