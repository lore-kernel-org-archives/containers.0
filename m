From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 08/18] io-controller: idle for sometime on sync queue
	before expiring it
Date: Wed, 10 Jun 2009 09:26:38 -0400
Message-ID: <20090610132638.GB19680__5422.13532976366$1244640454$gmane$org@redhat.com>
References: <1241553525-28095-1-git-send-email-vgoyal@redhat.com>
	<1241553525-28095-9-git-send-email-vgoyal@redhat.com>
	<4A2E15B6.8030001@cn.fujitsu.com>
	<20090609175131.GB13476@redhat.com>
	<4A2F0CBE.8030208@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A2F0CBE.8030208-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Jun 10, 2009 at 09:30:38AM +0800, Gui Jianfeng wrote:
> Vivek Goyal wrote:
> > On Tue, Jun 09, 2009 at 03:56:38PM +0800, Gui Jianfeng wrote:
> >> Vivek Goyal wrote:
> >> ...
> >>> +ssize_t elv_fairness_store(struct request_queue *q, const char *name,
> >>> +			  size_t count)
> >>> +{
> >>> +	struct elv_fq_data *efqd;
> >>> +	unsigned int data;
> >>> +	unsigned long flags;
> >>> +
> >>> +	char *p = (char *)name;
> >>> +
> >>> +	data = simple_strtoul(p, &p, 10);
> >>> +
> >>> +	if (data < 0)
> >>> +		data = 0;
> >>> +	else if (data > INT_MAX)
> >>> +		data = INT_MAX;
> >>   Hi Vivek,
> >>
> >>   data might overflow on 64 bit systems. In addition, since "fairness" is nothing 
> >>   more than a switch, just let it be.
> >>
> >> Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> >> ---
> > 
> > Hi Gui,
> > 
> > How about following patch? Currently this should apply at the end of the
> > patch series. If it looks good, I will merge the changes in higher level
> > patches.
> 
>   This patch seems good to me. Some trivial issues comment below.
> 
> > 
> > Thanks
> > Vivek
> > 
> > o Previously common layer elevator parameters were appearing as request
> >   queue parameters in sysfs. But actually these are io scheduler parameters
> >   in hiearchical mode. Fix it.
> > 
> > o Use macros to define multiple sysfs C functions doing the same thing. Code
> >   borrowed from CFQ. Helps reduce the number of lines of by 140.
> > 
> > Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ...	\
> > +}
> > +SHOW_FUNCTION(elv_fairness_show, efqd->fairness, 0);
> > +EXPORT_SYMBOL(elv_fairness_show);
> > +SHOW_FUNCTION(elv_slice_idle_show, efqd->elv_slice_idle, 1);
> > +EXPORT_SYMBOL(elv_slice_idle_show);
> > +SHOW_FUNCTION(elv_async_slice_idle_show, efqd->elv_async_slice_idle, 1);
> > +EXPORT_SYMBOL(elv_async_slice_idle_show);
> > +SHOW_FUNCTION(elv_slice_sync_show, efqd->elv_slice[1], 1);
> > +EXPORT_SYMBOL(elv_slice_sync_show);
> > +SHOW_FUNCTION(elv_slice_async_show, efqd->elv_slice[0], 1);
> > +EXPORT_SYMBOL(elv_slice_async_show);
> > +#undef SHOW_FUNCTION
> > +
> > +#define STORE_FUNCTION(__FUNC, __PTR, MIN, MAX, __CONV)			\
> > +ssize_t __FUNC(struct elevator_queue *e, const char *page, size_t count)	\
> > +{									\
> > +	struct elv_fq_data *efqd = &e->efqd;				\
> > +	unsigned int __data;						\
> > +	int ret = elv_var_store(&__data, (page), count);		\
> 
>   Since simple_strtoul returns unsigned long, it's better to make __data 
>   be that type.
> 

I just took it from CFQ. BTW, what's the harm here in truncating unsigned
long to int? Anyway for our variables we are not expecting any value 
bigger than unsigned int and if it is, we expect to truncate it?

> > +	if (__data < (MIN))						\
> > +		__data = (MIN);						\
> > +	else if (__data > (MAX))					\
> > +		__data = (MAX);						\
> > +	if (__CONV)							\
> > +		*(__PTR) = msecs_to_jiffies(__data);			\
> > +	else								\
> > +		*(__PTR) = __data;					\
> > +	return ret;							\
> > +}
> > +STORE_FUNCTION(elv_fairness_store, &efqd->fairness, 0, 1, 0);
> > +EXPORT_SYMBOL(elv_fairness_store);
> > +STORE_FUNCTION(elv_slice_idle_store, &efqd->elv_slice_idle, 0, UINT_MAX, 1);
> 
>   Do we need to set an actual max limitation rather than UINT_MAX for these entries?

Again these are the same values CFQ was using.  Do you have a better upper
limit in mind? Until and unless there is strong objection to UINT_MAX, we
can stick to what CFQ has been doing so far.

Thanks
Vivek
