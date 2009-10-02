From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Fri, 2 Oct 2009 11:40:20 -0400
Message-ID: <20091002154020.GC4494__23992.39248266$1254498226$gmane$org@redhat.com>
References: <200910021255.27689.czoccolo@gmail.com>
	<20091002124921.GA4494@redhat.com>
	<4e5e476b0910020827s23e827b1n847c64e355999d4a@mail.gmail.com>
	<1254497520.10392.11.camel@marge.simson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1254497520.10392.11.camel-YqMYhexLQo1vAv1Ojkdn7Q@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Corrado Zoccolo <czoccolo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Ulrich Lukas <stellplatz-nr.13a-7vBoImwI/YtIVYojq0lqJrNAH6kLmebB@public.gmane.org>, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Oct 02, 2009 at 05:32:00PM +0200, Mike Galbraith wrote:
> On Fri, 2009-10-02 at 17:27 +0200, Corrado Zoccolo wrote:
> > On Fri, Oct 2, 2009 at 2:49 PM, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > > On Fri, Oct 02, 2009 at 12:55:25PM +0200, Corrado Zoccolo wrote:
> > >
> > > Actually I am not touching this code. Looking at the V10, I have not
> > > changed anything here in idling code.
> > 
> > I based my analisys on the original patch:
> > http://lkml.indiana.edu/hypermail/linux/kernel/0907.1/01793.html
> > 
> > Mike, can you confirm which version of the fairness patch did you use
> > in your tests?
> 
> That would be this one-liner.
> 

Ok. Thanks. Sorry, I got confused and thought that you are using "io
controller patches" with fairness=1.

In that case, Corrado's suggestion of refining it further and disabling idling
for seeky process only on non-rotational media (SSD and hardware RAID), makes
sense to me.

Thanks
Vivek
  
> o CFQ provides fair access to disk in terms of disk time used to processes.
>   Fairness is provided for the applications which have their think time with
>   in slice_idle (8ms default) limit.
> 
> o CFQ currently disables idling for seeky processes. So even if a process
>   has think time with-in slice_idle limits, it will still not get fair share
>   of disk. Disabling idling for a seeky process seems good from throughput
>   perspective but not necessarily from fairness perspecitve.
> 
> 0 Do not disable idling based on seek pattern of process if a user has set
>   /sys/block/<disk>/queue/iosched/fairness = 1.
> 
> Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---
>  block/cfq-iosched.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-2.6/block/cfq-iosched.c
> ===================================================================
> --- linux-2.6.orig/block/cfq-iosched.c
> +++ linux-2.6/block/cfq-iosched.c
> @@ -1953,7 +1953,7 @@ cfq_update_idle_window(struct cfq_data *
>  	enable_idle = old_idle = cfq_cfqq_idle_window(cfqq);
>  
>  	if (!atomic_read(&cic->ioc->nr_tasks) || !cfqd->cfq_slice_idle ||
> -	    (cfqd->hw_tag && CIC_SEEKY(cic)))
> +	    (!cfqd->cfq_fairness && cfqd->hw_tag && CIC_SEEKY(cic)))
>  		enable_idle = 0;
>  	else if (sample_valid(cic->ttime_samples)) {
>  		if (cic->ttime_mean > cfqd->cfq_slice_idle)
> 
