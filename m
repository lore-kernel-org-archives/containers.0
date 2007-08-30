From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [PATCH] Use helpers to obtain task pid in printks (arch code)
Date: Thu, 30 Aug 2007 21:11:05 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0708302107510.24730@fbirervta.pbzchgretzou.qr>
References: <46D27D7E.7090806@openvz.org> <1188237708.18004.102.camel@localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760364AbXH3TL2@vger.kernel.org>
In-Reply-To: <1188237708.18004.102.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
To: Joe Perches <joe@perches.com>
Cc: Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@osdl.org>, Alexey Dobriyan <adobriyan@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-arch@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Sukadev Bhattiprolu <sukadev@us.ibm.com>, Oleg Nesterov <oleg@tv-sign.ru>
List-Id: containers.vger.kernel.org


On Aug 27 2007 11:01, Joe Perches wrote:
>On Mon, 2007-08-27 at 11:30 +0400, Pavel Emelyanov wrote:
>> From: Alexey Dobriyan <adobriyan@openvz.org>
>> 
>> One of the easiest things to isolate is the pid printed in kernel
>> log. There was a patch, that made this for arch-independent code,
>> this one makes so for arch/xxx files.
>
>Perhaps it would be worthwhile to standardize the printk
>task information content? Maybe a format knob?
>
>Maybe TASK_FMT/TASK_ARG(task)
>
>#define TASK_FMT "%s"
>#define TASK_ARG(tsk) ({char __buf[MAX_TASK_INFO]; print_task(tsk, buf, sizeof(__buf)); __buf})

Except that __buf goes out of scope before printk() is called...



	Jan
-- 
