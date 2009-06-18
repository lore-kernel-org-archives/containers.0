From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Devel] Re: [PATCH 1/1] cls_cgroup: unify classid syntax to tc
Date: Thu, 18 Jun 2009 08:21:12 -0700
Message-ID: <6599ad830906180821q2c357112s39c0da4e157b555c__14472.4360936836$1245338655$gmane$org@mail.gmail.com>
References: <20090611180555.f2c76568.usui@mxm.nes.nec.co.jp>
	<20090611.021347.142243970.davem@davemloft.net>
	<20090612124028.fe4c2100.usui@mxm.nes.nec.co.jp>
	<6599ad830906112206n745fb0dw19cdb75d7c40b2a4@mail.gmail.com>
	<20090615120035.a8b7b38f.usui@mxm.nes.nec.co.jp>
	<20090615101919.GC7768@bombadil.infradead.org>
	<20090617094907.e8cd77bd.usui@mxm.nes.nec.co.jp>
	<4A399FF7.5060209@cn.fujitsu.com>
	<20090618151516.73daf5d8.usui@mxm.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090618151516.73daf5d8.usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
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
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, tgraf-G/eBtMaohhA@public.gmane.org, Thomas Graf <tgraf-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Jun 17, 2009 at 11:15 PM, Minoru Usui<usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org> wrote:
>
> net_cls.classid's core purpose is to read/write classid.
> If we add net_cls.tc_classid, its core purpose is same.
> Their difference is only read/write value of expression.

I still feel that it's unnecessary bloat to put that parsing/printing
logic in the kernel when userspace can do it just as easily. But
having it as a separate file would at least remove the compatibility
concerns.

Paul
