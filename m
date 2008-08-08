From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC][PATCH 1/4] checkpoint-restart: general infrastructure
Date: Fri, 08 Aug 2008 19:27:09 -0400
Message-ID: <489CD64D.7030500__42402.9327500195$1218238322$gmane$org@cs.columbia.edu>
References: <20080807224033.FFB3A2C1@kernel>	 <20080807224034.735B1F84@kernel>
	<200808081146.54834.arnd@arndb.de>	
	<1218221451.19082.36.camel@nimitz>
	<489CB3CA.6050304@cs.columbia.edu>
	<1218233855.19082.52.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1218233855.19082.52.camel@nimitz>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
List-Id: containers.vger.kernel.org


Dave Hansen wrote:
> On Fri, 2008-08-08 at 16:59 -0400, Oren Laadan wrote:
>> To avoid repetitive malloc/free, ctx->hbuf is a buffer to host headers
>> as they are read;
> 
> kmalloc/kfree() area really, really fast.  I wonder if the code gets
> easier or harder to read if we just alloc/free as we need to.

The ctx->hbuf interface is a pair of cr_hbuf_get(ctx, length) and a
matching cr_hbuf_put(ctx, length), almost like using kmalloc/kfree().
The main difference is that cleanup in error paths is implicit (the
whole buffer is freed when the ctx is deallocated).

> How large are these allocations, usually?  Will stack allocation work in
> most cases?

That depends on how we construct the headers. In Zap there are some
headers that use relatively long structures to be put on the stack,
and it wouldn't make much sense to divide them into smaller headers
artificially.

However, I forgot to mention earlier that an important reason to use
this construct is actually in anticipation for a future optimization:
during application downtime the checkpoint state will be aggregated
into an in-memory buffer, and only after the application is allowed
to continue execution (unfrozen) the buffer will be written-back to
the FD. In that scenario, we will allocate a larger buffer in the ctx
(eg based on some heuristics) and cr_hbuf_get() will return the next
location in that buffer, while cr_hbuf_put() will do nothing.

Oren.
