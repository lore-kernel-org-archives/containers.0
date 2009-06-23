From: Jeff Moyer <jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 02/20] io-controller: Common flat fair queuing code in
	elevaotor layer
Date: Mon, 22 Jun 2009 22:20:24 -0400
Message-ID: <x49k533ofmf.fsf@segfault.boston.devel.redhat.com>
References: <1245443858-8487-1-git-send-email-vgoyal@redhat.com>
	<1245443858-8487-3-git-send-email-vgoyal@redhat.com>
	<20090622084612.GD3728@balbir.in.ibm.com>
	<20090623020515.GA3620@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090623020515.GA3620-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (Vivek Goyal's message of
	"Mon, 22 Jun 2009 22:05:15 -0400")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> On Mon, Jun 22, 2009 at 02:16:12PM +0530, Balbir Singh wrote:
>> > +	ioq->pid = current->pid;
>> 
>> Is pid used for cgroup association later? I don't see why we save the
>> pid otherwise? If yes, why not store the cgroup of the current->pid?
>> 
>
> This is just for logging purposes (blktrace), useful for CFQ where every task
> context sets up one queue and this number becomes the identifier for the queue.
> Look at elv_log_ioq(), which uses ioq->pid.

Well, that's not 100% accurate as tasks can share I/O contexts.
However, the 1:1 mapping does hold true most of the time.

> [..]
>> > + * coop tells that io scheduler selected a queue for us and we did not
>> 
>> coop?
>
> coop refers to "cooperating". I guess "coop" is not descriptive. I will
> change the name to "cooperating" and also put more description for
> clarity.

I think just more description is fine.  I'm not sure you need to spell
out cooperating (that will make for some long lines!).

>> > +	struct io_queue *async_idle_queue;
>> > +
>> > +	/*
>> > +	 * Used to track any pending rt requests so we can pre-empt current
>> > +	 * non-RT cfqq in service when this value is non-zero.
>> > +	 */
>> > +	unsigned int busy_rt_queues;
>> > +};
>> > +
>> > +struct elv_fq_data {
>> 
>> What does fq stand for?
>
> Fair queuing. Any suggestions to make it better?

I think you could just put it in the comment.

Cheers,
Jeff
