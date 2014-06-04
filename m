From: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Subject: Re: [PATCH RFC - TAKE TWO - 00/12] New version of the BFQ I/O
	Scheduler
Date: Thu, 5 Jun 2014 00:31:52 +0200
Message-ID: <20140604223152.GA7881@amd.pavel.ucw.cz>
References: <20140528221929.GG1419@htj.dyndns.org>
	<1401354343-5527-1-git-send-email-paolo.valente@unimore.it>
	<20140530160712.GG24871@htj.dyndns.org>
	<464F6CBE-A63E-46EF-A90D-BF8450430444@unimore.it>
	<20140530232804.GA5057@htj.dyndns.org>
	<20140602111432.GA3737@amd.pavel.ucw.cz>
	<20140602173332.GB8912@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140602173332.GB8912-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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

Hi!

On Mon 2014-06-02 13:33:32, Tejun Heo wrote:
> On Mon, Jun 02, 2014 at 01:14:33PM +0200, Pavel Machek wrote:
> > Now.. I see it is more work for storage maintainers, because there'll
> > be more code to maintain in the interim. But perhaps user advantages
> > are worth it?
> 
> I'm quite skeptical about going that route.  Not necessarily because
> of the extra amount of work but more the higher probability of getting
> into situation where we can neither push forward or back out.  It's
> difficult to define clear deadline and there will likely be unforeseen
> challenges in the planned convergence of the two schedulers,
> eventually, it isn't too unlikely to be in a situation where we have
> to admit defeat and just keep both schedulers.  Note that developer

Yes, that might happen. But it appears that conditions that would
make us stuck with CFQ&BFQ are the same conditions that would make us
stuck with CFQ alone.

And if BFQ is really better for interactivity under load, I'd really
really like option to use it, even if it leads to regression under
batch loads (or something else)... 

> overhead isn't the only factor here.  Providing two slightly different
> alternatives inevitably makes userland grow dependencies on subtleties
> of both and there's a lot less pressure to make judgement calls and

Dunno. It is just the scheduler. It makes stuff slower or faster, but
should not affect userland too badly.

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
