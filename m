From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v4][PATCH 5/9] Memory managemnet (restore)
Date: Thu, 11 Sep 2008 02:59:59 -0400
Message-ID: <48C8C1EF.40507@cs.columbia.edu>
References: <1220946154-15174-1-git-send-email-orenl@cs.columbia.edu>	
	<1220946154-15174-6-git-send-email-orenl@cs.columbia.edu>	
	<1221075083.6781.34.camel@nimitz>
	<48C824A2.8050708@cs.columbia.edu>
	<1221079757.6781.54.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1221079757.6781.54.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org



Dave Hansen wrote:
> On Wed, 2008-09-10 at 15:48 -0400, Oren Laadan wrote:
>> Dave Hansen wrote:
>>> On Tue, 2008-09-09 at 03:42 -0400, Oren Laadan wrote:
>>>> +/**
>>>> + * cr_vma_read_pages_vaddrs - read addresses of pages to page-array chain
>>>> + * @ctx - restart context
>>>> + * @npages - number of pages
>>>> + */
>>>> +static int cr_vma_read_pages_vaddrs(struct cr_ctx *ctx, int npages)
>>>> +{
>>>> +	struct cr_pgarr *pgarr;
>>>> +	int nr, ret;
>>>> +
>>>> +	while (npages) {
>>>> +		pgarr = cr_pgarr_prep(ctx);
>>>> +		if (!pgarr)
>>>> +			return -ENOMEM;
>>>> +		nr = min(npages, (int) pgarr->nr_free);
>>>> +		ret = cr_kread(ctx, pgarr->vaddrs, nr * sizeof(unsigned long));
>>>> +		if (ret < 0)
>>>> +			return ret;
>>>> +		pgarr->nr_free -= nr;
>>>> +		pgarr->nr_used += nr;
>>>> +		npages -= nr;
>>>> +	}
>>>> +	return 0;
>>>> +}
>>> cr_pgarr_prep() can return a partially full pgarr, right?  Won't the
>>> cr_kread() always start at the beginning of the pgarr->vaddrs[] array?
>>> Seems to me like it will clobber things from the last call.
>> Note that 'nr' is either equal to ->nr_free - in which case we consume
>> the entire 'pgarr' vaddr array such that the next call to cr_pgarr_prep()
>> will get a fresh one, or is smaller than ->nr_free - in which case that
>> is the last iteration of the loop anyhow, so it won't be clobbered.
>>
>> Also, after we return - our caller, cr_vma_read_pages(), resets the state
>> of the page-array chain by calling cr_pgarr_reset().
> 
> Man, that's awfully subtle for something which is so simple.
> 
> I think it is a waste of memory to have to hold *all* of the vaddrs in
> memory at once.  Is there a real requirement for that somehow?  The code
> would look a lot simpler use less memory if it was done (for instance)
> using a single 'struct pgaddr' at a time.  There are an awful lot of HPC
> apps that have nearly all physical memory in the machine allocated and
> mapped into a single VMA.  This approach could be quite painful there.
> 
> I know it's being done this way because that's what the dump format
> looks like.  Would you consider changing the dump format to have blocks
> of pages and vaddrs together?  That should also parallelize a bit more
> naturally.

It's being done this way to allow for a future optimization that will aim
at reducing downtime of the application by buffering all the data that is
to be saved while the container is frozen, so that the write-back of the
buffer happens after the container resumes execution.

(It is this reasoning that dictates the dump format and the code, not the
other way around).

That said, the point about reducing memory footprint of checkpoint/restart
is valid as well. Moreover, it conflicts with the above in requiring small
buffering, if any.

To enable both modes of operation, I'll modify the dump format to allow
multiple blocks of (addresses list followed by pages contents).

Oren.
