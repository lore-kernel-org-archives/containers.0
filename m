From: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Subject: Re: [PATCH RFC - TAKE TWO - 00/12] New version of the BFQ I/O
	Scheduler
Date: Mon, 2 Jun 2014 13:14:33 +0200
Message-ID: <20140602111432.GA3737__22711.8623246954$1401708070$gmane$org@amd.pavel.ucw.cz>
References: <20140528221929.GG1419@htj.dyndns.org>
	<1401354343-5527-1-git-send-email-paolo.valente@unimore.it>
	<20140530160712.GG24871@htj.dyndns.org>
	<464F6CBE-A63E-46EF-A90D-BF8450430444@unimore.it>
	<20140530232804.GA5057@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140530232804.GA5057-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri 2014-05-30 19:28:04, Tejun Heo wrote:
> Hello,
> 
> On Sat, May 31, 2014 at 12:23:01AM +0200, Paolo Valente wrote:
> > I do agree that bfq has essentially the same purpose as cfq. I am
> > not sure that it is what you are proposing, but, in my opinion,
> > since both the engine and all the new heuristics of bfq differ from
> > those of cfq, a replacement would be most certainly a much easier
> > solution than any other transformation of cfq into bfq (needless to
> > say, leaving the same name for the scheduler would not be a problem
> > for me). Of course, before that we are willing to improve what has
> > to be improved in bfq.
> 
> Well, it's all about how to actually route the changes and in general
> whenever avoidable we try to avoid whole-sale code replacement
> especially when most of the structural code is similar like in this
> case.  Gradually evolving cfq to bfq is likely to take more work but
> I'm very positive that it'd definitely be a lot easier to merge the
> changes that way and people involved, including the developers and
> reviewers, would acquire a lot clearer picture of what's going on in
> the process.  For example, AFAICS, most of the heuristics added by

Would it make sense to merge bfq first, _then_ turn cfq into bfq, then
remove bfq?

That way

1. Users like me would see improvements soon 

2. BFQ would get more testing early. 

3. If there are some problems in some workload, switching between bfq
and cfq will be easier than playing with git/patches.

Now.. I see it is more work for storage maintainers, because there'll
be more code to maintain in the interim. But perhaps user advantages
are worth it?

Thanks,

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
