From: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Subject: Re: [PATCH RFC - TAKE TWO - 09/12] block,
	bfq: reduce latency during request-pool saturation
Date: Mon, 2 Jun 2014 11:54:28 +0200
Message-ID: <949E9E1B-87D6-42D6-832C-3C73E44DF668__25716.2038506523$1401702882$gmane$org@unimore.it>
References: <20140528221929.GG1419@htj.dyndns.org>
	<1401354343-5527-1-git-send-email-paolo.valente@unimore.it>
	<1401354343-5527-10-git-send-email-paolo.valente@unimore.it>
	<20140531135402.GC24557@mtj.dyndns.org>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140531135402.GC24557-9pTldWuhBndy/B6EtB590w@public.gmane.org>
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


Il giorno 31/mag/2014, alle ore 15:54, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> ha scritto:

> On Thu, May 29, 2014 at 11:05:40AM +0200, Paolo Valente wrote:
>> This patch introduces an heuristic that reduces latency when the
>> I/O-request pool is saturated. This goal is achieved by disabling
>> device idling, for non-weight-raised queues, when there are weight-
>> raised queues with pending or in-flight requests. In fact, as
>> explained in more detail in the comment to the function
>> bfq_bfqq_must_not_expire(), this reduces the rate at which processes
>> associated with non-weight-raised queues grab requests from the pool,
>> thereby increasing the probability that processes associated with
>> weight-raised queues get a request immediately (or at least soon) when
>> they need one.
> 
> Wouldn't it be more straight-forward to simply control how many
> requests each queue consume by returning ELV_MQUEUE_NO?

Arianna proposed me exactly this improvement about two months ago. The problem was that our TO-ADD list already contained several other improvements. So, to avoid waiting several more years before (re)submitting bfq, I decided that it would have been better to finally freeze the code for a while and pack it for submission.

If you agree, investigating and implementing this improvement will be our next step immediately after, and if the current version of bfq gets merged in some form.

Thanks,
Paolo

>  Seeky ones do
> benefit from larger number of requests in elevator but to only certain
> number given the fifo timeout anyway and controlling that explicitly
> would be a lot easier to anticipate the behavior of than playing
> roulette with random request allocation failures.
> 
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
