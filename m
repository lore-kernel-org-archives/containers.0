From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH RFC - TAKE TWO - 00/12] New version of the BFQ I/O
	Scheduler
Date: Fri, 30 May 2014 19:28:04 -0400
Message-ID: <20140530232804.GA5057__4462.89875912971$1401492501$gmane$org@htj.dyndns.org>
References: <20140528221929.GG1419@htj.dyndns.org>
	<1401354343-5527-1-git-send-email-paolo.valente@unimore.it>
	<20140530160712.GG24871@htj.dyndns.org>
	<464F6CBE-A63E-46EF-A90D-BF8450430444@unimore.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <464F6CBE-A63E-46EF-A90D-BF8450430444-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
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
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

On Sat, May 31, 2014 at 12:23:01AM +0200, Paolo Valente wrote:
> I do agree that bfq has essentially the same purpose as cfq. I am
> not sure that it is what you are proposing, but, in my opinion,
> since both the engine and all the new heuristics of bfq differ from
> those of cfq, a replacement would be most certainly a much easier
> solution than any other transformation of cfq into bfq (needless to
> say, leaving the same name for the scheduler would not be a problem
> for me). Of course, before that we are willing to improve what has
> to be improved in bfq.

Well, it's all about how to actually route the changes and in general
whenever avoidable we try to avoid whole-sale code replacement
especially when most of the structural code is similar like in this
case.  Gradually evolving cfq to bfq is likely to take more work but
I'm very positive that it'd definitely be a lot easier to merge the
changes that way and people involved, including the developers and
reviewers, would acquire a lot clearer picture of what's going on in
the process.  For example, AFAICS, most of the heuristics added by the
later patches are refined versions of what's already in cfq and at
least some are applicable regardless of the underlying scheduling
algorithm.  It all depends on the details but, for example, steps like
the following would be it a lot easier to get merged.

* Identify the improvements which can be applied to cfq as-is or with
  some adaptation and apply those improvements to cfq.

* Make prepatory changes to make transition to new base scheduling
  algorithm easier.

* Strip out or disable cfq features which get in the way of
  conversion.

* Switch the base algorithm to the timestamp based one.

* Rebuild stripped down features and apply new heuristics,
  optimizations and follow-up changes.

I understand that this might be non-significant amount of work but at
the same time it's not something which is inherently difficult.  It's
mostly logistical after all and I'd be happy to help where I can.

Thanks.

-- 
tejun
