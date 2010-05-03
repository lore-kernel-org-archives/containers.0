From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v21 001/100] eclone (1/11): Factor out code to allocate
	pidmap page
Date: Mon, 03 May 2010 14:02:31 -0700
Message-ID: <1272920551.12034.4729.camel__5669.45273099027$1272920600$gmane$org@nimitz>
References: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
	<1272723382-19470-2-git-send-email-orenl@cs.columbia.edu>
	<20100501.151022.190375136.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100501.151022.190375136.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On Sat, 2010-05-01 at 15:10 -0700, David Miller wrote:
> NO WAY, there is no way in the world you should post 100 patches
> at a time to any mailing list, especially those at vger.kernel.org
> that have thousands upon thousands of subscribers.
> 
> Post only small, well contained, sets of patches at a time.  At most
> 10 or so in one go.

Hi Dave,

I really do apologize if these caused undue traffic on vger.  It
certainly wasn't our intention to cause any problems.

We've had a fear all along that we'll just go back into our little
containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, and go astray of what the
community wants done with these patches.  It's also important to
remember that these really do affect the entire kernel.  Unfortunately,
it's not really a single feature or something that fits well on any
other mailing list.  It has implications _everywhere_.  I think Andrew
Morton also asked that these continue coming to LKML, although his
request probably came at a time when the set was a wee bit smaller.

> Do you realize how much mail traffic you generate by posting so many
> patches at one time, and how unlikely it is for anyone to actually
> sift through and review your patches after you've spammed them by
> posting so many at one time?

I honestly don't expect people to be reading the whole thing at once.
But, I do hope that people can take a look at their individual bits that
are touched.

> A second infraction and I will have no choice but to block you at the
> SMTP level at vger.kernel.org so please do not do it again.

I know these patches are certainly not at the level of importance as,
say the pata or -stable updates, but they're certainly not of
unprecedented scale.  I've seen a number of patchbombs of this size
recently.

I hope Andrew pulls this set into -mm so this doesn't even come up
again.  But, if it does, can you make some suggestions on how to be more
kind to vger in the process?

-- Dave
