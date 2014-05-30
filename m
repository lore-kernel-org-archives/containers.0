From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH RFC RESEND 00/14] New version of the BFQ I/O Scheduler
Date: Fri, 30 May 2014 13:59:37 -0400
Message-ID: <20140530175937.GK24871__7706.00490873239$1401472791$gmane$org@htj.dyndns.org>
References: <1401194558-5283-1-git-send-email-paolo.valente@unimore.it>
	<20140530153228.GE16605@redhat.com>
	<20140530161650.GH24871@htj.dyndns.org>
	<20140530170958.GF16605@redhat.com>
	<20140530172609.GI24871@htj.dyndns.org>
	<20140530175527.GH16605@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140530175527.GH16605-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, paolo <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paolo Valente <posta_paolo-whZMOeQn8C0@public.gmane.org>
List-Id: containers.vger.kernel.org

Hey, Vivek.

On Fri, May 30, 2014 at 01:55:27PM -0400, Vivek Goyal wrote:
> Now CFQ also dynamically adjusts the slice length based on the how
> many queues are ready to do IO. One problem with fixed slice lenth
> round robin was that if there are lot of queues doing IO, then after
> serving one queue, same queue will get time slice after a long time.
> 
> Corrado Zoccolo did work in this area in an attempt to improve latency.
> Now slice length is calculated dynamically in an attempt to achieve
> better latency.

Consdier it a better version of that.

> Ok, so you prefer to have another IO scheduler instead of improving
> CFQ?

As I wrote in another reply, I think the best approach would be
morphing cfq to accomodate the scheduling algorithm and heristics of
bfq.

> Tejun, I have spent significant amount of time on BFQ few years ago. And
> that's the reason I have not read it again yet. My understanding was
> that there was nothing which would not be done in CFQ (atleast things
> which mattered).

THERE IS A NEW PAPER.

> Looks like you prefer introducing a new scheduler instead of improving
> CFQ. My preference is to improve CFQ. Borrow good ideas from BFQ and
> implement them in CFQ.

LOOKS LIKE YOU ARE NOT READING ANYTHING AND JUST WRITING IRRELEVANT
SHIT.

> So why not improve CFQ instead of carrying and maintaining another 
> scheduler. And then have a discussion that what's the default scheduler.

For fuck's sake, I'm out.  This is total waste of time.  You don't
read what others are writing and refuse to study what's right there.
What are you doing?

-- 
tejun
