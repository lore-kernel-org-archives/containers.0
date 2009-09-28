From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Mon, 28 Sep 2009 16:30:51 +0900 (JST)
Message-ID: <20090928.163051.71112594.ryov__20837.9296389923$1254123115$gmane$org@valinux.co.jp>
References: <20090925050429.GB12555@redhat.com>
	<20090925.180724.104041942.ryov@valinux.co.jp>
	<20090925143337.GA15007@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090925143337.GA15007-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Vivek,

Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > Because dm-ioband provides faireness in terms of how many IO requests
> > are issued or how many bytes are transferred, so this behaviour is to
> > be expected. Do you think fairness in terms of IO requests and size is
> > not fair?
> > 
> 
> Hi Ryo,
> 
> Fairness in terms of size of IO or number of requests is probably not the
> best thing to do on rotational media where seek latencies are significant.
> 
> It probably should work just well on media with very low seek latencies
> like SSD.
> 
> So on rotational media, either you will not provide fairness to random 
> readers because they are too slow or you will choke the sequential readers
> in other group and also bring down the overall disk throughput.
> 
> If you don't decide to choke/throttle sequential reader group for the sake
> of random reader in other group then you will not have a good control
> on random reader latencies. Because now IO scheduler sees the IO from both
> sequential reader as well as random reader and sequential readers have not
> been throttled. So the dispatch pattern/time slices will again look like..
> 
> 	SR1 SR2 SR3 SR4 SR5 RR.....
> 
> 	instead  of
> 
> 	SR1 RR SR2 RR SR3 RR SR4 RR ....
>  
> SR --> sequential reader,  RR --> random reader

Thank you for elaborating. However, I think that fairness in terms of
disk time has a similar problem. The below is a benchmark result of
randread vs seqread I posted before, rand-readers and seq-readers ran
on individual groups and their weights were equally assigned.

                   Throughput [KiB/s]
             io-controller  dm-ioband
randread         161          314
seqread         9556          631

I know that dm-ioband is needed to improvement on the seqread
throughput, but I don't think that io-controller seems quite fair,
even the disk times of each group are equal, why randread can't get
more bandwidth. So I think that this is how users think about
faireness, and it would be good thing to provide multiple policies of
bandwidth control for uses.

> > The write-starve-reads on dm-ioband, that you pointed out before, was
> > not caused by FIFO release, it was caused by IO flow control in
> > dm-ioband. When I turned off the flow control, then the read
> > throughput was quite improved.
> 
> What was flow control doing?

dm-ioband gives a limit on each IO group. When the number of IO
requests backlogged in a group exceeds the limit, processes which are
going to issue IO requests to the group are made sleep until all the
backlogged requests are flushed out.

> > Now I'm considering separating dm-ioband's internal queue into sync
> > and async and giving a certain priority of dispatch to async IOs.
> 
> Even if you maintain separate queues for sync and async, in what ratio will
> you dispatch reads and writes to underlying layer once fresh tokens become
> available to the group and you decide to unthrottle the group.

Now I'm thinking that It's according to the requested order, but
when the number of in-flight sync IOs exceeds io_limit (io_limit is
calculated based on nr_requests of underlying block device), dm-ioband
dispatches only async IOs until the number of in-flight sync IOs are
below the io_limit, and vice versa. At least it could solve the
write-starve-read issue which you pointed out.
 
> Whatever policy you adopt for read and write dispatch, it might not match
> with policy of underlying IO scheduler because every IO scheduler seems to
> have its own way of determining how reads and writes should be dispatched.

I think that this is a matter of users choise, which a user would
like to give priority to bandwidth or IO scheduler's policy.

> Now somebody might start complaining that my job inside the group is not
> getting same reader/writer ratio as it was getting outside the group.
> 
> Thanks
> Vivek

Thanks,
Ryo Tsuruta
