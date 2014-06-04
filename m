From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH RFC - TAKE TWO - 00/12] New version of the BFQ I/O
	Scheduler
Date: Wed, 4 Jun 2014 10:58:29 -0400
Message-ID: <20140604145829.GF5004@htj.dyndns.org>
References: <538C8A47.1050502@kernel.dk> <20140602172454.GA8912@htj.dyndns.org>
	<538CB515.3090700@kernel.dk> <20140602174250.GC8912@htj.dyndns.org>
	<538CB87C.7030600@kernel.dk> <20140602185138.GD8912@htj.dyndns.org>
	<20140602205713.GB8357@kernel.dk>
	<20140604143136.GA1920@infradead.org>
	<20140604145053.GE5004@htj.dyndns.org>
	<20140604145330.GA2955@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140604145330.GA2955-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paolo Valente <posta_paolo-whZMOeQn8C0@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Jun 04, 2014 at 07:53:30AM -0700, Christoph Hellwig wrote:
> On Wed, Jun 04, 2014 at 10:50:53AM -0400, Tejun Heo wrote:
> > Hmmm... the biggest thing is ioscheds.  They heavily rely on being
> > strongly synchronized and are pretty important for rotating rusts.
> > Maybe they can be made to work with blk-mq by forcing single queue or
> > something but do we wnat that?
> 
> Jens is planning to add an (optional) I/O scheduler to blk-mq, and
> that is indeed required for proper disk support.  I don't think there
> even is a need to limit it to a single queue technically, although
> devices that support multiple queues are unlikely to need I/O
> scheduling.

I think what Jens is planning is something really minimal.  Things
like [cb]fq heavily depend on the old block infrastructure.  I don't
know.  Maybe they can be merged in time but I'm not quite sure we'd
have enough pressure to actually do that.  Host-granular switching
should be good enough, I guess.

Thanks.

-- 
tejun
