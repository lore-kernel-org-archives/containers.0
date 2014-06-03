From: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Subject: Re: [PATCH RFC - TAKE TWO - 00/12] New version of the BFQ I/O
	Scheduler
Date: Tue, 3 Jun 2014 22:40:57 +0200
Message-ID: <20140603204057.GA18900@amd.pavel.ucw.cz>
References: <20140528221929.GG1419@htj.dyndns.org>
	<1401354343-5527-1-git-send-email-paolo.valente@unimore.it>
	<20140530160712.GG24871@htj.dyndns.org>
	<464F6CBE-A63E-46EF-A90D-BF8450430444@unimore.it>
	<20140530232804.GA5057@htj.dyndns.org>
	<20140602111432.GA3737@amd.pavel.ucw.cz>
	<20140602130226.GA14654@amd.pavel.ucw.cz>
	<FCFE0106-A4DD-4DEF-AAAE-040F3823A447@unimore.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <FCFE0106-A4DD-4DEF-AAAE-040F3823A447-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
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
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi!

> >>> Well, it's all about how to actually route the changes and in general
> >>> whenever avoidable we try to avoid whole-sale code replacement
> >>> especially when most of the structural code is similar like in this
> >>> case.  Gradually evolving cfq to bfq is likely to take more work but
> >>> I'm very positive that it'd definitely be a lot easier to merge the
> >>> changes that way and people involved, including the developers and
> >>> reviewers, would acquire a lot clearer picture of what's going on in
> >>> the process.  For example, AFAICS, most of the heuristics added by
> >> 
> >> Would it make sense to merge bfq first, _then_ turn cfq into bfq, then
> >> remove bfq?
> >> 
> >> That way
> >> 
> >> 1. Users like me would see improvements soon 
> >> 
> >> 2. BFQ would get more testing early. 
> > 
> > Like this: I applied patch over today's git... 
> > 
> > I only see last bits of panic...
> > 
> > Call trace:
> > __bfq_bfqq_expire
> > bfq_bfqq_expire
> > bfq_dispatch_requests
> > sci_request_fn
> > ...
> > EIP: T.1839+0x26
> > Kernel panic - not syncing: Fatal exception in interrupt
> > Shutting down cpus with NMI
> > 
> > ...
> > 
> > Will retry.
> > 
> > Any ideas?
> > 			

>  We have tried to think about ways to trigger this failure, but in
> vain. Unfortunately, so far no user has reported any failure with
> this last version of bfq either. Finally, we have gone through a new
> static analysis, but also in this case uselessly.

Ok, it is pretty much reproducible here: system just will not finish
booting.

> So, if you are willing to retry, we have put online a version of the code filled with many BUG_ONs. I hope they can make it easier to track down the bug. The archive is here:
> http://algogroup.unimore.it/people/paolo/disk_sched/debugging-patches/3.15.0-rc8-v7rc5.tgz
> 

Ok, let me try.

> Should this attempt be useless as well, I will, if you do not mind, try by asking you more details about your system and reproducing your configuration as much as I can.
> 

It is thinkpad x60 notebook, x86-32 machine with 2GB ram.

But I think it died on my x86-32 core duo desktop, too. 

Best regards,
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
