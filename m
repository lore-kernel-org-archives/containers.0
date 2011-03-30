From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: 2.6.38 containers bug: Infinite loop in
	/proc/sys/net/ipv6/neigh/neigh/neigh...
Date: Wed, 30 Mar 2011 03:48:20 -0700 (PDT)
Message-ID: <20110330.034820.124005354.davem__30570.3464583077$1301482174$gmane$org@davemloft.net>
References: <4D9302F3.6080206@parallels.com>
	<20110330.033529.71582712.davem@davemloft.net>
	<4D9309B4.2000501@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4D9309B4.2000501-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

From: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Date: Wed, 30 Mar 2011 05:45:08 -0500

> So you think letting it soak in the merge window and the churn of -rc1
> (which currently doesn't boot for me due to an ide issue) will provide
> more validity than a specific "There was an infinite loop in the
> filesystem, there is now no longer an infinite loop in the filesystem,
> here's the specific test for it" and visual inspection ofthe patch?

Yes I absolutely do think it's better to let it soak somewhere than
to repeat the reason why this patch is necessary in the first place.

This patch is necessary because Eric already screwed up trying to fix
this neigh dirctory under ipv6 once, and he got it wrong.

That patch looked correct and straightforward.

Yet it introduced the bug you're seeing.

Given that consideration, are you still holding steady to your
opinion wise guy? :-)
