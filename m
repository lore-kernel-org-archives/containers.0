From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Mon, 28 Sep 2009 13:48:09 -0400
Message-ID: <20090928174809.GB3643__30806.6154052087$1254160297$gmane$org@redhat.com>
References: <1253820332-10246-1-git-send-email-vgoyal@redhat.com>
	<4ABC28DE.7050809@datenparkplatz.de>
	<20090925202636.GC15007@redhat.com>
	<1253976676.7005.40.camel@marge.simson.net>
	<1254034500.7933.6.camel@marge.simson.net>
	<20090927164235.GA23126@kernel.dk>
	<1254075359.7354.66.camel@marge.simson.net>
	<1254110648.7683.3.camel@marge.simson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1254110648.7683.3.camel-YqMYhexLQo1vAv1Ojkdn7Q@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Ulrich Lukas <stellplatz-nr.13a-7vBoImwI/YtIVYojq0lqJrNAH6kLmebB@public.gmane.org>, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Sep 28, 2009 at 06:04:08AM +0200, Mike Galbraith wrote:
> On Sun, 2009-09-27 at 20:16 +0200, Mike Galbraith wrote:
> > On Sun, 2009-09-27 at 18:42 +0200, Jens Axboe wrote:
> 
> > I'll give it a shot first thing in the A.M.
> 
> > > diff --git a/block/elevator.c b/block/elevator.c
> > > index 1975b61..d00a72b 100644
> > > --- a/block/elevator.c
> > > +++ b/block/elevator.c
> > > @@ -497,9 +497,17 @@ int elv_merge(struct request_queue *q, struct request **req, struct bio *bio)
> > >  	 * See if our hash lookup can find a potential backmerge.
> > >  	 */
> > >  	__rq = elv_rqhash_find(q, bio->bi_sector);
> > > -	if (__rq && elv_rq_merge_ok(__rq, bio)) {
> > > -		*req = __rq;
> > > -		return ELEVATOR_BACK_MERGE;
> > > +	if (__rq) {
> > > +		/*
> > > +		 * If requests are queued behind this one, disallow merge. This
> > > +		 * prevents streaming IO from continually passing new IO.
> > > +		 */
> > > +		if (elv_latter_request(q, __rq))
> > > +			return ELEVATOR_NO_MERGE;
> > > +		if (elv_rq_merge_ok(__rq, bio)) {
> > > +			*req = __rq;
> > > +			return ELEVATOR_BACK_MERGE;
> > > +		}
> > >  	}
> > >  
> > >  	if (e->ops->elevator_merge_fn)
> 
> - = virgin tip v2.6.31-10215-ga3c9602
> + = with patchlet
>                                                             Avg
> dd pre         67.4     70.9     65.4     68.9     66.2     67.7-
>                65.9     68.5     69.8     65.2     65.8     67.0-     Avg
>                70.4     70.3     65.1     66.4     70.1     68.4-     67.7-
>                73.1     64.6     65.3     65.3     64.9     66.6+     65.6+     .968
>                63.8     67.9     65.2     65.1     64.4     65.2+
>                64.9     66.3     64.1     65.2     64.8     65.0+
> perf stat      8.66    16.29     9.65    14.88     9.45     11.7-
>               15.36     9.71    15.47    10.44    12.93     12.7-
>               10.55    15.11    10.22    15.35    10.32     12.3-     12.2-
>                9.87     7.53    10.62     7.51     9.95      9.0+      9.1+     .745
>                7.73    10.12     8.19    11.87     8.07      9.1+
>               11.04     7.62    10.14     8.13    10.23      9.4+
> dd post        63.4     60.5     66.7     64.5     67.3     64.4-
>                64.4     66.8     64.3     61.5     62.0     63.8-
>                63.8     64.9     66.2     65.6     66.9     65.4-     64.5-
>                60.9     63.4     60.2     63.4     65.5     62.6+     61.8+     .958
>                63.3     59.9     61.9     62.7     61.2     61.8+
>                60.1     63.7     59.5     61.5     60.6     61.0+
> 

Hmm.., so close to 25% reduction on average in completion time of konsole.
But this is in presece of writer. Does this help even in presence of 1 or
more sequential readers going?

So here latency seems to be coming from three sources.

- Wait in CFQ before request is dispatched (only in case of competing seq readers).
- seek latencies
- latencies because of bigger requests are already dispatched to disk.

So limiting the size of request will help with third factor but not with first  
two factors and here seek latencies seem to be the biggest contributor. 

Thanks
Vivek
