From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v5][PATCH 2/8] General infrastructure for checkpoint	restart
Date: Mon, 15 Sep 2008 12:13:18 -0700
Message-ID: <1221505998.16561.34.camel__12166.5685940117$1221506145$gmane$org@nimitz>
References: <1221347167-9956-1-git-send-email-orenl@cs.columbia.edu>
	<1221347167-9956-3-git-send-email-orenl@cs.columbia.edu>
	<1221501750.16561.15.camel@nimitz> <48CEAEF2.1050901@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48CEAEF2.1050901-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 2008-09-15 at 14:52 -0400, Oren Laadan wrote:
> Dave Hansen wrote:
> > On Sat, 2008-09-13 at 19:06 -0400, Oren Laadan wrote:
> >> +void *cr_hbuf_get(struct cr_ctx *ctx, int n)
> >> +{
> >> +       void *ptr;
> >> +
> >> +       BUG_ON(ctx->hpos + n > CR_HBUF_TOTAL);
> >> +       ptr = (void *) (((char *) ctx->hbuf) + ctx->hpos);
> >> +       ctx->hpos += n;
> >> +       return ptr;
> >> +}
...
> > I really do detest having a memory allocator BUG_ON() when it runs out
> > of space.  
> 
> The BUG_ON() statement asserts that we don't run out of buffer space.
> Buffer usage is a function of the checkpoint/restart logic, and does
> not depend on user input, hence not susceptible to DoS.

OK, that's fair enough.  But, can we document it as such?  "Only headers
and things of known, static sizes can go in here.  We don't use
kmalloc() instead of this because..."

> In other words, if the code is correct, this should never happen (much
> like a kernel stack overflow), and if it happens it's a kernel bug. I
> think it was Arnd who recommended with regard to this to crash loudly
> if there is a bug in the kernel ...

Yes, it does mean that there is a bug because someone either made a
structure bigger, PAGE_SIZE smaller, or a call path got deeper than we
expected.  I'm just having visions of the email hitting my inbox in 18
months. :)

The structures are sized consistently across all architectures and
configurations.  However, PAGE_SIZE and the size of that buffer are not.
The buffer will be 8k on x86, but 128k on most ppc64 configurations.

Can we at least make it sized in numbers of bytes rather than pages?
Also, please remember that using kmalloc() buys you lots of fun stuff on
top of get_free_pages(), like redzones and easier debugging.

-- Dave
