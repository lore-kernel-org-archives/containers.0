From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: [patch 0/4] [RFC] Another proportional weight IO controller
Date: Fri, 28 Nov 2008 22:33:30 +0900 (JST)
Message-ID: <20081128.223330.623571555980968757.ryov__45170.7623120912$1227879366$gmane$org@valinux.co.jp>
References: <20081125162720.GH341@redhat.com>
	<20081126.214707.653026525707335397.ryov@valinux.co.jp>
	<20081126160805.GE27826@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081126160805.GE27826-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Vivek,

> > Thanks for your explanation. 
> > I think that the same thing occurs without the higher level scheduler,
> > because all the tasks issuing I/Os are blocked while the underlying
> > device's request queue is full before those I/Os are sent to the I/O
> > scheduler.
> > 
> 
> True and this issue was pointed out by Divyesh. I think we shall have to
> fix this by allocating the request descriptors in proportion to their
> share. One possible way is to make use of elv_may_queue() to determine
> if we can allocate furhter request descriptors or not. 

At the fist glance, elv_may_queue() seemed to be useful for the purpose
as you mentioned. But I've noticed there are some problems after I
investigated the code more.

 1. Every I/O controller must have its own decision algorithm that
    which I/O requests should be block or not, whose algorithm will be
    similar to that of dm-ioband. It would be a hassle to implement it
    in all the I/O controllers.

 2. When an I/O is completed, one of the slots in the request queue
    become available, then one of the processes being blocked get awakened
    in fifo manner. This won't be the best one in most cases and
    you have to make this process sleep again and you may want to
    wake up another one. It's inefficient.

 3. In elv_may_queue(), we can't determine which process issues an I/O.
    You have no choice but to make any kind of process sleep even if
    it's a kernel thread such as kswapd or pdflush. What do you think
    is going to happen after that?
    It may be possible to modify the code not to block kernel threads,
    but I don't think you can control delayed-write I/Os.

If you want to solve these problems, I think you are going to implement
the algorithm there whose code is very similar to that of dm-ioband.

Thanks,
Ryo Tsuruta
