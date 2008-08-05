From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Too many I/O controller patches
Date: Tue,  5 Aug 2008 11:28:27 +0200 (MEST)
Message-ID: <48981D3B.2020701__10436.8662498475$1217928662$gmane$org@gmail.com>
References: <20080804.175126.193692178.ryov@valinux.co.jp>
	<1217870433.20260.101.camel@nimitz> <489748E6.5080106@gmail.com>
	<000901c8f6a5$fe64ba30$fb2e2e90$@jp.nec.com>
Reply-To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <000901c8f6a5$fe64ba30$fb2e2e90$@jp.nec.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Satoshi UCHIDA <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, 'Dave Hansen' <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, vtaras-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Satoshi UCHIDA wrote:
>  Andrea's requirement is
>    * to be able to set and control by absolute(direct) performance.

     * improve IO performance predictability of each cgroup
       (try to guarantee more precise IO performance values)

> And, he gave a advice "Can't a framework which organized each way,
> such as I/O elevator, be made?".
> I try to consider such framework (in elevator layer or block layer).

It would be probably the best place to evaluate the "cost" of each
IO operation.

> I think that OOM problems caused by memory/cache systems.
> So, it will be better that I/O controller created out of these problems
> first, although a lateness of the I/O device would be related.
> If these problem can be resolved, its technique should be applied into 
> normal I/O control as well as cgroups.
> 
> Buffered write I/O is also related with cache system.
> We must consider this problem as I/O control.

Agree. At least, maybe we should consider if an IO controller could be
a valid solution also for these problems.

>> I did some experiments trying to implement minimum bandwidth requirements
>> for my io-throttle controller, mapping the requirements to CFQ prio and
>> using the Satoshi's controller. But this needs additional work and
>> testing right now, so I've not posted anything yet, just informed
>> Satoshi about this.
> 
> I'm very interested in this results.

I'll collect some numbers and keep you informed.

-Andrea
