From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 3/8] create fs flags to mark c/r supported fs's
Date: Fri, 27 Feb 2009 13:20:50 -0800
Message-ID: <1235769650.26788.388.camel__25023.4646992341$1235769865$gmane$org@nimitz>
References: <20090227203425.F3B51176@kernel> <20090227203428.556600DA@kernel>
	<20090227211620.GA3326@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090227211620.GA3326-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sat, 2009-02-28 at 00:16 +0300, Alexey Dobriyan wrote:
> On Fri, Feb 27, 2009 at 12:34:28PM -0800, Dave Hansen wrote:
> > +#define FS_CHECKPOINTABLE 8
> 
> This will ban all sockets, for instance, until all of them are
> C/R-ready. And every new socket type must be made C/R-ready from
> the very beginning, or risk major C/R breakage.

Yes, it is very important to have fine-grained control over what is
checkpointable and not.  We can't simply say "all sockets are OK" all at
once.  I meant this as a high-level things so that I didn't have to go
chase down the several f_ops for each in and every filesystem that is
supported.

Did you look farther down in the patches to see how this can be
overridden with an f_op?

-- Dave
