From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v5][PATCH 9/9] Restore open file descriprtors
Date: Mon, 22 Sep 2008 09:02:09 -0700
Message-ID: <1222099329.8533.56.camel@nimitz>
References: <1221347167-9956-1-git-send-email-orenl@cs.columbia.edu>
	<1221347167-9956-10-git-send-email-orenl@cs.columbia.edu>
	<20080916230850.GB25445@us.ibm.com> <48D04B19.9060502@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48D04B19.9060502-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 2008-09-16 at 20:11 -0400, Oren Laadan wrote:
> 
> No. (this was discussed earlier already).
> 
> cr_hbuf_get() "allocates" space inside a dedicated buffer for headers
> in the checkpoint context (ctx->hbuf). It does not allocate new kernel
> memory. Instead, it returns the current position in that buffer
> ctx->hbuf[ctx->hpos], and advances ctx->hpos appropriately. On the
> other side, cr_hbuf_put() reverses that effect, reducing ctx->hpos
> accordingly.
> 
> If an error occurs, the checkpoint (or restart) operation is aborted,
> and eventually the context (ctx) will be cleaned up; at that point the
> special purpose buffer will be freed.

I think this is like claiming that my malloc() will get freed if my
applications exits, so I don't have to worry about free().  It is messy,
it makes lifetime rules and use less explicit, and it makes bugs harder
to find.  If I were a good programmer (which I'm not) I probably
wouldn't do that.

-- Dave
