From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH RFC - TAKE TWO - 10/12] block, bfq: add Early Queue Merge
	(EQM)
Date: Wed, 4 Jun 2014 09:04:46 -0400
Message-ID: <20140604130446.GA5004__7312.18075748092$1401887104$gmane$org@htj.dyndns.org>
References: <20140528221929.GG1419@htj.dyndns.org>
	<1401354343-5527-1-git-send-email-paolo.valente@unimore.it>
	<1401354343-5527-11-git-send-email-paolo.valente@unimore.it>
	<20140601000331.GA29085@htj.dyndns.org>
	<3B7B1A46-46EB-4C52-A52C-4F79C71D14C2@unimore.it>
	<20140603162844.GD26210@htj.dyndns.org>
	<91383F1F-69C3-4B88-B51E-30204818F1AB@unimore.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <91383F1F-69C3-4B88-B51E-30204818F1AB-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
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
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mauro Andreolini <mauro.andreolini-rcYM44yAMweonA0d6jMUrA@public.gmane.org>, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

On Wed, Jun 04, 2014 at 01:47:36PM +0200, Paolo Valente wrote:
> > I think I'm a bit confused because it's named "early" queue merge
> > while it actually moves queue merging later than cfq - set_request()
> > happens before bio/rq merging.
> 
> 
> There is probably something I am missing here, because, as can be seen in blk-core.c,
> around line 1495, elv_set_request() is invoked in the context of the get_request() function,
> which in its turn is called from blk_queue_bio() *after* attempting both a plug merge
> and a merge with one of the requests in the block layer's cache. The first
> attempt is lockless and doesn't involve the I/O scheduler, but the
> second attempt includes invoking the allow_merge_fn hook of the scheduler
> (elv_merge() -> elv_rq_merge_ok() -> elv_iosched_allow_merge()).

Ah, you're right, set_request doesn't happen if a bio is merged into
an existing request.

> > Oh, as long as it makes measureable difference, I have no objection;
> > however, I do think more explanation and comments would be nice.  I
> > still can't quite understand why retrying on each merge attempt would
> > make so much difference.  Maybe I just failed to understand what you
> > wrote in the commit message.
> 
> If we remember well, one of the problems was exactly that a different request
> may become the head request of the in-service queue between two rq merge
> attempts. If we do not retry on every attempt, we lose the chance
> to merge the queue at hand with the in-service queue. The two queues may
> then diverge, and hence have no other opportunity to be merged.
> 
> > Is it because the cooperating tasks
> > issue IOs which grow large and close enough after merges but not on
> > the first bio issuance?  If so, why isn't doing it on rq merge time
> > enough?  Is the timing sensitive enough for certain workloads that
> > waiting till unplug time misses the opportunity?  But plugging should
> > be relatively short compared to the time actual IOs take, so why would
> > it be that sensitive?  What am I missing here?
> 
> The problem is not the duration of the plugging, but the fact that, if a request merge
> succeeds for a bio, then there will be no set_request invocation for that bio.
> Therefore, without early merging, there will be no queue merge at all.
> 
> If my replies are correct and convince you, then I will use them to integrate and
> hopefully improve the documentation for this patch.

Ah, okay, so it's about missing the chance to look for cooperating
queues when merge succeeds.  Yeah, that makes a lot more sense to me.
If that's the case, wouldn't it be better to try finding cooperating
queues after each merge success rather than each allow_merge()
invocation?  And let's please document what we're catching with the
extra attempts.

Thanks.

-- 
tejun
