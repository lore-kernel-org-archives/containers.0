From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH RFC - TAKE TWO - 12/12] block, bfq: boost the throughput
	with random I/O on NCQ-capable HDDs
Date: Sat, 31 May 2014 09:34:44 -0400
Message-ID: <20140531133444.GA24557@mtj.dyndns.org>
References: <20140528221929.GG1419@htj.dyndns.org>
	<1401354343-5527-1-git-send-email-paolo.valente@unimore.it>
	<1401354343-5527-13-git-send-email-paolo.valente@unimore.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1401354343-5527-13-git-send-email-paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paolo Valente <posta_paolo-whZMOeQn8C0@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello,

Okay, read this one properly too.

On Thu, May 29, 2014 at 11:05:43AM +0200, Paolo Valente wrote:
...
> + * As already said, things change with a rotational device, where idling
> + * boosts the throughput with sequential I/O (even with NCQ). Hence, for
> + * such a device the second component of the compound condition evaluates
> + * to true also if the following additional sub-condition does not hold:
> + * the queue is constantly seeky. Unfortunately, this different behavior
> + * with respect to flash-based devices causes an additional asymmetry: if
> + * some sync queues enjoy idling and some other sync queues do not, then
> + * the latter get a low share of the device throughput, simply because the
> + * former get many requests served after being set as in service, whereas
> + * the latter do not. As a consequence, to guarantee the desired throughput
> + * distribution, on HDDs the compound expression evaluates to true (and
> + * hence device idling is performed) also if the following last symmetry
> + * condition does not hold: no other queue is benefiting from idling. Also

Ummm... doesn't the compound expression evaluating to %true prevent
idling from taking place?  The above sentence is painful to parse.  I
don't really think there's much point in expressing the actual
evaulation of expressions in human language.  It sucks for that.  It'd
be far easier to comprehend if you just state what it actually
achieves.  ie. just say "for rotational queued devices, idling is
allowed if such and such conditions are met" and then explain
rationales for each.  There's no point in walking through the
evaluation process itself.

>  #define cond_for_expiring_non_wr  (bfqd->hw_tag && \
>  				   (bfqd->wr_busy_queues > 0 || \
>  				    (symmetric_scenario && \
> -				     blk_queue_nonrot(bfqd->queue))))
> +				     (blk_queue_nonrot(bfqd->queue) || \
> +				      cond_for_seeky_on_ncq_hdd))))

So, the addition is that for rotational queued devices, idling is
inhibited if all queues are symmetric and all the busy ones are
constantly seeky, right?  Everybody being seeky is probably the only
use case where allowing queued operation is desirable for rotational
devices.  In these cases, do we even care whether every queue is
symmetric?  If we really want this tagged operation optimization,
wouldn't it be far easier to simply charge everybody by bandwidth if
everybody is seeky with idling disabled whether queues are symmetric
or not?  The whole point of charging full slice to seeky queues is
making sure they don't starve non-seeky ones.  If everybody is seeky,
bandwidth charging should be enough for fairness among them, right?

Also, can we please try to avoid double negations where possible?  The
function could easily have been named should_idle() instead of
must_not_expire().  Combined with the complex logic expressions, it
makes things unnecessarily difficult to follow.  Just say yes for not
not.

Thanks.

-- 
tejun
