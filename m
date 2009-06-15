From: Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
Subject: Re: [HELP] for using class group classifier network controller
Date: Mon, 15 Jun 2009 11:36:09 +0900
Message-ID: <20090615113609.db5c0613.usui__18036.4578766332$1245034285$gmane$org@mxm.nes.nec.co.jp>
References: <4C86297B4AC6554B8BA018F0806590CE01C8AFA5@email1>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4C86297B4AC6554B8BA018F0806590CE01C8AFA5@email1>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: =?UTF-8?B?6rmA7J6s7Je0?= <gauri-mINagvnPBMnWF1p7bDn8Kw@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, tgraf-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
List-Id: containers.vger.kernel.org

Hi, Cheiyol

> # classid 1:10
> 
> echo 0x1000A > /dev/cpuctl/foo/net_cls.classid
> 
> #classid 1:20
> 
> echo 0x10014 > /dev/cpuctl/bob/net_cls.classid

(snip)

> # add class 1:10 for foo group
> 
> $TC class add dev eth0 parent 1:0 classid 1:10 htb rate 50mbit
> 
> # add class 1:20 for bob group
> 
> $TC class add dev eth0 parent 1:0 classid 1:20 htb rate 30mbit
> 
> # default class
> 
> $TC class add dev eth0 parent 1:0 classid 1:30 htb rate 10mbit

In class ID to use TC, both a major number and a minor number are hexadecimal.
So 1:10 equals 0x00010010.

I think, you should set 0x10010 to net_cls.classid if you classify to 1:10.
-- 
Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
