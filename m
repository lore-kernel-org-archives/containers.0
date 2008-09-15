From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v5][PATCH 2/8] General infrastructure for checkpoint	restart
Date: Mon, 15 Sep 2008 14:52:34 -0400
Message-ID: <48CEAEF2.1050901__22735.9347198673$1221504906$gmane$org@cs.columbia.edu>
References: <1221347167-9956-1-git-send-email-orenl@cs.columbia.edu>	
	<1221347167-9956-3-git-send-email-orenl@cs.columbia.edu>
	<1221501750.16561.15.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1221501750.16561.15.camel@nimitz>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org
List-Id: containers.vger.kernel.org



Dave Hansen wrote:
> On Sat, 2008-09-13 at 19:06 -0400, Oren Laadan wrote:
>> +void *cr_hbuf_get(struct cr_ctx *ctx, int n)
>> +{
>> +       void *ptr;
>> +
>> +       BUG_ON(ctx->hpos + n > CR_HBUF_TOTAL);
>> +       ptr = (void *) (((char *) ctx->hbuf) + ctx->hpos);
>> +       ctx->hpos += n;
>> +       return ptr;
>> +}
> 
> All of the casting here is unnecessary.  'void *' behaves like 'char *'
> when you do arithmetic on it.  

ok.

> 
> I really do detest having a memory allocator BUG_ON() when it runs out
> of space.  

The BUG_ON() statement asserts that we don't run out of buffer space.
Buffer usage is a function of the checkpoint/restart logic, and does
not depend on user input, hence not susceptible to DoS.

In other words, if the code is correct, this should never happen (much
like a kernel stack overflow), and if it happens it's a kernel bug. I
think it was Arnd who recommended with regard to this to crash loudly
if there is a bug in the kernel ...

Oren.
