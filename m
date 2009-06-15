From: Thomas Graf <tgraf-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [HELP] for using class group classifier network controller
Date: Mon, 15 Jun 2009 06:30:20 -0400
Message-ID: <20090615103020.GA8894__44694.5756477819$1245061868$gmane$org@bombadil.infradead.org>
References: <4C86297B4AC6554B8BA018F0806590CE01C8AFA5@email1>
	<20090615113609.db5c0613.usui@mxm.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090615113609.db5c0613.usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
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
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Jun 15, 2009 at 11:36:09AM +0900, Minoru Usui wrote:
> Hi, Cheiyol
> 
> > # classid 1:10
> > 
> > echo 0x1000A > /dev/cpuctl/foo/net_cls.classid
> > 
> > #classid 1:20
> > 
> > echo 0x10014 > /dev/cpuctl/bob/net_cls.classid
> 
> (snip)
> 
> > # add class 1:10 for foo group
> > 
> > $TC class add dev eth0 parent 1:0 classid 1:10 htb rate 50mbit
> > 
> > # add class 1:20 for bob group
> > 
> > $TC class add dev eth0 parent 1:0 classid 1:20 htb rate 30mbit
> > 
> > # default class
> > 
> > $TC class add dev eth0 parent 1:0 classid 1:30 htb rate 10mbit
> 
> In class ID to use TC, both a major number and a minor number are hexadecimal.
> So 1:10 equals 0x00010010.
> 
> I think, you should set 0x10010 to net_cls.classid if you classify to 1:10.

That's right, both net_cls.classid and tc use integers in hexadecimal form
for both, printing and parsing.

10:10 -> 0x100010
10:20 -> 0x100020

This seems to be the weak point regarding usability that's why I like
Minoru Usui's patch so much. It would no longer be necessary to really
understand the internals of classids etc.
