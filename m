From: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
Subject: Re: [PATCH RFC - TAKE TWO - 00/12] New version of the BFQ I/O
	Scheduler
Date: Mon, 02 Jun 2014 11:46:36 -0600
Message-ID: <538CB87C.7030600@kernel.dk>
References: <20140528221929.GG1419@htj.dyndns.org>
	<1401354343-5527-1-git-send-email-paolo.valente@unimore.it>
	<20140530160712.GG24871@htj.dyndns.org>
	<538926F6.7080409@kernel.dk>
	<20140531051635.GA19925@mtj.dyndns.org>
	<538C8A47.1050502@kernel.dk> <20140602172454.GA8912@htj.dyndns.org>
	<538CB515.3090700@kernel.dk> <20140602174250.GC8912@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140602174250.GC8912-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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

On 06/02/2014 11:42 AM, Tejun Heo wrote:
> Hello, Jens.
> 
> On Mon, Jun 02, 2014 at 11:32:05AM -0600, Jens Axboe wrote:
>> For things like blkcg, I agree, it should be able to be common code and
>> reusable. But there's a need for scheduling beyond that, for people that
>> don't use control groups (ie most...). And it'd be hard to retrofit cfq
>> into blk-mq, without rewriting it. I don't believe we need anything this
>> fancy for blk-mq, hopefully. At least having simple deadline scheduling
>> would be Good Enough for the foreseeable future.
> 
> Heh, looks like we're miscommunicating.  I don't think anything with
> the level of complexity of cfq is realistic for high-iops devices.  It
> has already become a liability for SATA ssds after all.  My suggestion
> is that as hierarchical scheduling tends to be logical extension of
> flat scheduling, it probably would make sense to implement both
> scheduling logics in the same framework as in the cpu scheduler or (to
> a lesser extent) cfq.  So, a new blk-mq scheduler which can work in
> hierarchical mode if blkcg is in active use.

But blk-mq will potentially drive anything, so it might not be out of
the question with a more expensive scheduling variant, if it makes any
sense to do of course. At least until there's no more rotating stuff out
there :-). But it's not a priority at all to me yet. As long as we have
coexisting IO paths, it'd be trivial to select the needed one based on
the device characteristics.

> One part I was wondering about is whether we'd need to continue the
> modular multiple implementation mechanism.  For rotating disks, for
> various reasons including some historical ones, we ended up with
> multiple ioscheds and somewhat uglily layered blkcg implementations.
> Given that the expected characteristics of blk-mq devices are more
> consistent, it could be reasonable to stick with single iops and/or
> bandwidth scheme.

I hope not to do that. I just want something sane and simple (like a
deadline scheduler), nothing more.

-- 
Jens Axboe
