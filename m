From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v14][PATCH 08/54] Dump memory address space
Date: Mon, 04 May 2009 03:58:12 -0400
Message-ID: <49FEA014.7030605@cs.columbia.edu>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>	
	<1240961064-13991-9-git-send-email-orenl@cs.columbia.edu>
	<1241191632.29485.177.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1241191632.29485.177.camel@nimitz>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org



Dave Hansen wrote:
> On Tue, 2009-04-28 at 19:23 -0400, Oren Laadan wrote:
>> +/* return (and detach) first empty page-array in the pool, if exists */
>> +static inline struct ckpt_pgarr *pgarr_from_pool(struct ckpt_ctx *ctx)
>> +{
>> +       struct ckpt_pgarr *pgarr;
>> +
>> +       if (list_empty(&ctx->pgarr_pool))
>> +               return NULL;
>> +       pgarr = list_first_entry(&ctx->pgarr_pool, struct ckpt_pgarr, list);
>> +       list_del(&pgarr->list);
>> +       return pgarr;
>> +}
> 
> What's the pool for, again?  If we're alloc/freeing a bunch of these,
> I'd vote for a slab cache rather than managing our own pool.

It's not about the 'struct ckpt_pgarr' per se. Each ckpt_pgarr in
itself points to two page-size buffers allocate as well. The pool
avoids redundant alloc/dealloc of those buffers while iterating
through all VMAs of all tasks.

Oren.
