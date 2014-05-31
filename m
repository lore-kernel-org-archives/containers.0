From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH RFC - TAKE TWO - 00/12] New version of the BFQ I/O
	Scheduler
Date: Sat, 31 May 2014 01:16:35 -0400
Message-ID: <20140531051635.GA19925__20822.5388116718$1401513413$gmane$org@mtj.dyndns.org>
References: <20140528221929.GG1419@htj.dyndns.org>
	<1401354343-5527-1-git-send-email-paolo.valente@unimore.it>
	<20140530160712.GG24871@htj.dyndns.org>
	<538926F6.7080409@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <538926F6.7080409-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
Cc: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paolo Valente <posta_paolo-whZMOeQn8C0@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello, Jens.

On Fri, May 30, 2014 at 06:48:54PM -0600, Jens Axboe wrote:
> What I really like about the implementation is, as Tejun highlights, that
> the algorithm is detailed and characterized. Nobody ever wrote any detailed
> documentation on CFQ - I think the closest is a talk I gave at LCA in 2007
> or so. That said, the devil is _always_ in the details when it comes to nice
> algorithms. When theory meets practice, then the little tweaks and tunings
> required to not drop 10% there or 20% here is when it gets ugly. And that's
> where CFQ has the history going for it, at least. Which is another reason

That's the thing I like about the new paper.  It looks like the
original BFQ was the naive ideal implementation but the new paper
basically takes most, if not all, heuristics implemented in cfq,
properly characterizes them and applies the improved versions.  The
end result, AFAICS, really is an evolution of cfq with the core
round-robin + preemption scheduler replaced by something a lot firmer.
It doesn't really lose much of what cfq has accumulated over time.

> for turning patch #2 into a series of changes for CFQ instead. We need to
> end up with something where we can potentially bisect our way down to
> whatever caused any given regression. The worst possible situation is "CFQ
> works fine for this workload, but BFQ does not" or vice versa. Or hangs, or
> whatever it might be.

It's likely that there will be some workloads out there which may be
affected adversely, which is true for any change really but with both
the core scheduling and heuristics properly characterized at least
finding a reasonable trade-off should be much less of a crapshoot and
the expected benefits seem to easily outweigh the risks as long as we
can properly sequence the changes.

Thanks.

-- 
tejun
