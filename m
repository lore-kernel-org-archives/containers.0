From: Aaron Carroll <aaronc-M3ycANVxPotyL3EAZA59ERCuuivNXqWP@public.gmane.org>
Subject: Re: [patch 0/4] [RFC] Another proportional weight IO controller
Date: Wed, 19 Nov 2008 12:52:42 +1100
Message-ID: <4923716A.5090104__12066.323697991$1227059860$gmane$org@gelato.unsw.edu.au>
References: <af41c7c40811131457w472e4a86tb5344cc1d3d366fb@mail.gmail.com>
	<20081114160525.GE24624@redhat.com>
	<e98e18940811141444u5947b806v27fac453ed1e8a5@mail.gmail.com>
	<20081117142309.GA15564@redhat.com>
	<4922224A.5030502@cn.fujitsu.com>
	<e98e18940811172101na345b6bh5c73f9e657aac5a7@mail.gmail.com>
	<20081118120508.GD15268@gandalf.sssup.it>
	<20081118140751.GA4283@redhat.com>
	<20081118144139.GE15268@gandalf.sssup.it>
	<20081118191208.GJ26308@kernel.dk>
	<20081118211442.GG15268@gandalf.sssup.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081118211442.GG15268-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Fabio Checconi wrote:
>   - To detect hw tagging in BFQ we consider a sample valid iff the
>     number of requests that the scheduler could have dispatched (given
>     by cfqd->rb_queued + cfqd->rq_in_driver, i.e., the ones still into
>     the scheduler plus the ones into the driver) is higher than the
>     CFQ_HW_QUEUE_MIN threshold.  This obviously caused no problems
>     during testing, but the way CFQ uses now seems a little bit
>     strange.

BFQ's tag detection logic is broken in the same way that CFQ's used to
be.  Explanation is in this patch:

============================x8============================
commit 45333d5a31296d0af886d94f1d08f128231cab8e
Author: Aaron Carroll <aaronc-M3ycANVxPotyL3EAZA59ERCuuivNXqWP@public.gmane.org>
Date:   Tue Aug 26 15:52:36 2008 +0200

    cfq-iosched: fix queue depth detection
    
    CFQ's detection of queueing devices assumes a non-queuing device and detects
    if the queue depth reaches a certain threshold.  Under some workloads (e.g.
    synchronous reads), CFQ effectively forces a unit queue depth, thus defeating
    the detection logic.  This leads to poor performance on queuing hardware,
    since the idle window remains enabled.
    
    This patch inverts the sense of the logic: assume a queuing-capable device,
    and detect if the depth does not exceed the threshold.
============================x8=============================


BFQ seems better than CFQ at avoiding this problem though.  Using the following fio
job, I can routinely trigger it for 10s or so before BFQ detects queuing.


============================x8=============================
[global]
direct=1
ioengine=sync
norandommap
randrepeat=0
filename=/dev/sdb
bs=16k
runtime=200
time_based

[reader]
rw=randread
numjobs=128
============================x8=============================
