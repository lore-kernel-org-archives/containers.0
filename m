From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 06/16][cr][v3]: Checkpoint file-locks
Date: Wed, 04 Aug 2010 19:26:18 -0400
Message-ID: <4C59F71A.2010002__12718.5641359121$1280964492$gmane$org@cs.columbia.edu>
References: <1280877097-12377-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<1280877097-12377-7-git-send-email-sukadev@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1280877097-12377-7-git-send-email-sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>, John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org



On 08/03/2010 07:11 PM, Sukadev Bhattiprolu wrote:
> While checkpointing each file-descriptor, find all the locks on the
> file and save information about the lock in the checkpoint-image.
> A follow-on patch will use this informaiton to restore the file-locks.
>
> Changelog[v3]:
> 	[Oren Laadan] Add a missing (loff_t) type cast and use a macro
> 		to set the marker/dummy file lock
>
> Changelog[v2]:
> 	[Matt Helsley]: Use fixed sizes (__s64) instead of 'loff_t' in
> 		'struct ckpt_hdr_file_lock'.
> 	[Matt Helsley, Serge Hallyn]: Highlight new use of BKL (using
> 		lock_flocks() macros as suggested by Serge).
> 	[Matt Helsley]: Reorg code a bit to simplify error handling.
> 	[Matt Helsley]: Reorg code to initialize marker-lock (Pass a
> 		NULL lock to checkpoint_one_lock() to indicate marker).
>
> Signed-off-by: Sukadev Bhattiprolu<sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> ---
>   fs/checkpoint.c                |  100 ++++++++++++++++++++++++++++++++++-----
>   include/linux/checkpoint_hdr.h |   18 +++++++
>   2 files changed, 105 insertions(+), 13 deletions(-)
>
> diff --git a/fs/checkpoint.c b/fs/checkpoint.c
> index b5486c1..57b6944 100644
> --- a/fs/checkpoint.c
> +++ b/fs/checkpoint.c
> @@ -26,8 +26,19 @@
>   #include<linux/checkpoint.h>
>   #include<linux/eventpoll.h>
>   #include<linux/eventfd.h>
> +#include<linux/smp_lock.h>
>   #include<net/sock.h>
>
> +/*
> + * TODO: This code uses the BKL for consistency with other uses of
> + * 	 'for_each_lock()'. But since the BKL may be replaced with another
> + * 	 lock in the future, use lock_flocks() macros instead. lock_flocks()
> + * 	 are currently used in BKL-fix sand boxes and when those changes
> + * 	 are merged, the following macros can be removed
> + */
> +#define lock_flocks()		lock_kernel()
> +#define unlock_flocks()	unlock_kernel()
> +
>   /**************************************************************************
>    * Checkpoint
>    */
> @@ -256,8 +267,78 @@ static int checkpoint_file(struct ckpt_ctx *ctx, void *ptr)
>   	return ret;
>   }

I prefer the approach of writing-all-at-once over the current
one-at-a-time-and-mark-the-end. See my previous comment:
(https://lists.linux-foundation.org/pipermail/containers/2010-July/025057.html)

---
   Having looked at the code again - how about the following:
   get rid of this "last entry" altogether; instead, during
   checkpoint, first count the locks, then write a header with
   the number of locks, following by that many records of the
   locks themselves.

   This is what we do for other resource lists/chains as well.
   Also makes it a bit easier to parse since you always know
   what to expect once you see the header.
---

(Yes, I'm aware that if the list is long you may need to send
multiple chunks and for that "remember" where you were in the
list...)

[...]

Oren.
