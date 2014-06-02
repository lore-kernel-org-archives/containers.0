From: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
Subject: Re: [PATCH RFC - TAKE TWO - 00/12] New version of the BFQ I/O
	Scheduler
Date: Mon, 2 Jun 2014 14:57:30 -0600
Message-ID: <20140602205713.GB8357@kernel.dk>
References: <1401354343-5527-1-git-send-email-paolo.valente@unimore.it>
	<20140530160712.GG24871@htj.dyndns.org>
	<538926F6.7080409@kernel.dk>
	<20140531051635.GA19925@mtj.dyndns.org>
	<538C8A47.1050502@kernel.dk> <20140602172454.GA8912@htj.dyndns.org>
	<538CB515.3090700@kernel.dk> <20140602174250.GC8912@htj.dyndns.org>
	<538CB87C.7030600@kernel.dk> <20140602185138.GD8912@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140602185138.GD8912-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paolo Valente <posta_paolo-whZMOeQn8C0@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Jun 02 2014, Tejun Heo wrote:
> Hello,
> 
> On Mon, Jun 02, 2014 at 11:46:36AM -0600, Jens Axboe wrote:
> > But blk-mq will potentially drive anything, so it might not be out of
> > the question with a more expensive scheduling variant, if it makes any
> > sense to do of course. At least until there's no more rotating stuff out
> > there :-). But it's not a priority at all to me yet. As long as we have
> > coexisting IO paths, it'd be trivial to select the needed one based on
> > the device characteristics.
> 
> Hmmm... yeah, moving rotating devices over to blk-mq doesn't really
> seem beneficial to me.  I think there are fundamental behavioral
> differences for rotating rusts and newer solid state devices to share
> single code path for things like scheduling and selecting the
> appropriate path depending on the actual devices sounds like a much
> better plan even in the long term.

It's not so much about it being more beneficial to run in blk-mq, as it
is about not having two code paths. But yes, we're likely going to
maintain that code for a long time, so it's not going anywhere anytime
soon.

And for scsi-mq, it's already opt-in, though on a per-host basis. Doing
finer granularity than that is going to be difficult, unless we let
legacy-block and blk-mq share a tag map (though that would not be too
hard).

-- 
Jens Axboe
