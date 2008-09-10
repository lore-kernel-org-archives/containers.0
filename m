From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v4][PATCH 5/9] Memory managemnet (restore)
Date: Wed, 10 Sep 2008 15:48:50 -0400
Message-ID: <48C824A2.8050708__14689.1604680151$1221076398$gmane$org@cs.columbia.edu>
References: <1220946154-15174-1-git-send-email-orenl@cs.columbia.edu>	
	<1220946154-15174-6-git-send-email-orenl@cs.columbia.edu>
	<1221075083.6781.34.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1221075083.6781.34.camel@nimitz>
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
> On Tue, 2008-09-09 at 03:42 -0400, Oren Laadan wrote:
>> +/**
>> + * cr_vma_read_pages_vaddrs - read addresses of pages to page-array chain
>> + * @ctx - restart context
>> + * @npages - number of pages
>> + */
>> +static int cr_vma_read_pages_vaddrs(struct cr_ctx *ctx, int npages)
>> +{
>> +	struct cr_pgarr *pgarr;
>> +	int nr, ret;
>> +
>> +	while (npages) {
>> +		pgarr = cr_pgarr_prep(ctx);
>> +		if (!pgarr)
>> +			return -ENOMEM;
>> +		nr = min(npages, (int) pgarr->nr_free);
>> +		ret = cr_kread(ctx, pgarr->vaddrs, nr * sizeof(unsigned long));
>> +		if (ret < 0)
>> +			return ret;
>> +		pgarr->nr_free -= nr;
>> +		pgarr->nr_used += nr;
>> +		npages -= nr;
>> +	}
>> +	return 0;
>> +}
> 
> cr_pgarr_prep() can return a partially full pgarr, right?  Won't the
> cr_kread() always start at the beginning of the pgarr->vaddrs[] array?
> Seems to me like it will clobber things from the last call.

Note that 'nr' is either equal to ->nr_free - in which case we consume
the entire 'pgarr' vaddr array such that the next call to cr_pgarr_prep()
will get a fresh one, or is smaller than ->nr_free - in which case that
is the last iteration of the loop anyhow, so it won't be clobbered.

Also, after we return - our caller, cr_vma_read_pages(), resets the state
of the page-array chain by calling cr_pgarr_reset().

Oren.
