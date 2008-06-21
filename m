From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] introduce task cgroup v2
Date: Sun, 22 Jun 2008 02:01:12 +0900
Message-ID: <2f11576a0806211001w375d440dua42b56edce25bfda@mail.gmail.com>
References: <6599ad830806210056n44c7ff37g7cd643f95aef4aa0@mail.gmail.com>
	 <485CC255.9010504@linux.vnet.ibm.com>
	 <20080621180530.E82D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <6599ad830806210848q1a1538bcw79c2f3217dd49303@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753406AbYFURB1@vger.kernel.org>
In-Reply-To: <6599ad830806210848q1a1538bcw79c2f3217dd49303@mail.gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: balbir@linux.vnet.ibm.com, Pavel Emelianov <xemul@openvz.org>, containers@lists.osdl.org, LKML <linux-kernel@vger.kernel.org>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

>> I am going to convert spinlock in task limit cgroup to atomic_t.
>> task limit cgroup has following caractatics.
>>        - many write (fork, exit)
>>        - few read
>>        - fork() is performance sensitive systemcall.
>
> This is true, but I don't see how it can be more performance-sensitive
> than the overhead of allocating/freeing a page.
>
> What kinds of performance regressions did you see?

I ran spawn test of unix bench, thus

implement way                   performance degression
-------------------------------------------------------------------------
use res_counter                  15-20%
use spin_lock()                    nealy 10%
use atomic_t                       nealy 5%

Yes, this is really roughly number.
Of cource, I'll post more detail result at next week.

>>          if increase fork overhead, system total performance cause degression.
>
> What kind of overhead were you seeing? How about if you delay doing
> any task accounting until the task_limit subsystem is bound to a
> hierarchy? That way there's no noticeable overhead for people who
> aren't using your subsystem.

honestly, I am seeing it on micro-benchmark only.
but, I'm afraid to performance degression because many people check
performance regression periodically.
So if my implement cause performance regression, they never used mine.

Or, if you strongly want to task_limit subsystem use res_counter,
I can be working on improve to res_counter performance instead.
