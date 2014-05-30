From: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Subject: Re: [PATCH RFC - TAKE TWO - 11/12] block,
	bfq: boost the throughput on NCQ-capable flash-based devices
Date: Sat, 31 May 2014 00:01:21 +0200
Message-ID: <2BC999D0-F9FC-427B-A371-B9B4D951B693@unimore.it>
References: <20140528221929.GG1419@htj.dyndns.org>
	<1401354343-5527-1-git-send-email-paolo.valente@unimore.it>
	<1401354343-5527-12-git-send-email-paolo.valente@unimore.it>
	<20140530154654.GE24871@htj.dyndns.org>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140530154654.GE24871-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Il giorno 30/mag/2014, alle ore 17:46, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> ha scritto:

> On Thu, May 29, 2014 at 11:05:42AM +0200, Paolo Valente wrote:
>> This patch boosts the throughput on NCQ-capable flash-based devices,
>> while still preserving latency guarantees for interactive and soft
>> real-time applications. The throughput is boosted by just not idling
>> the device when the in-service queue remains empty, even if the queue
>> is sync and has a non-null idle window. This helps to keep the drive's
>> internal queue full, which is necessary to achieve maximum
>> performance. This solution to boost the throughput is a port of
>> commits a68bbdd and f7d7b7a for CFQ.
>> 
>> As already highlighted in patch 10, allowing the device to prefetch
>> and internally reorder requests trivially causes loss of control on
>> the request service order, and hence on service guarantees.
>> Fortunately, as discussed in detail in the comments to the function
>> bfq_bfqq_must_not_expire(), if every process has to receive the same
>> fraction of the throughput, then the service order enforced by the
>> internal scheduler of a flash-based device is relatively close to that
>> enforced by BFQ. In particular, it is close enough to let service
>> guarantees be substantially preserved.
>> 
>> Things change in an asymmetric scenario, i.e., if not every process
>> has to receive the same fraction of the throughput. In this case, to
>> guarantee the desired throughput distribution, the device must be
>> prevented from prefetching requests. This is exactly what this patch
>> does in asymmetric scenarios.
> 
> Does it even make sense to use this type of heavy iosched on ssds?
> It's highly likely that ssds will soon be served through blk-mq
> bypassing all these.  I don't feel too enthused about adding code to
> support ssds to ioscheds.  A lot better approach would be just default
> to deadline for them anyway.
> 

This was basically my opinion before I started running test also with SSDs. As you can see from, e.g., Figure 8 in
http://algogroup.unimore.it/people/paolo/disk_sched/extra_results.php
or Figure 9 in
http://algogroup.unimore.it/people/paolo/disk_sched/results.php
with deadline, as with NOOP and even worse with CFQ, start-up times become unbearably high while some files are being read sequentially. I have got even higher latencies on Intel SSDs.

One of the main reasons is that these schedulers allow the drive to queue more than one request. Maybe adding some of the low-latency heuristics of bfq to deadline may help, but it should be investigated.

Paolo


> Thanks.
> 
> -- 
> tejun


--
Paolo Valente                                                 
Algogroup
Dipartimento di Fisica, Informatica e Matematica		
Via Campi, 213/B
41125 Modena - Italy        				  
homepage:  http://algogroup.unimore.it/people/paolo/
