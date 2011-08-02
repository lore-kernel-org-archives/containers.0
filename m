From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH 2/4] limit nr_dentries per superblock
Date: Tue, 2 Aug 2011 09:46:23 -0300
Message-ID: <4E37F19F.6080107@parallels.com>
References: <1311947059-17209-1-git-send-email-glommer@parallels.com>
	<1311947059-17209-3-git-send-email-glommer@parallels.com>
	<20110731011531.GL5404@dastard>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110731011531.GL5404@dastard>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Cc: Andrea Arcangeli <aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Nick Piggin <npiggin-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James Bottomley <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi David,

Thank you for your comments. I actually agree with most of the things 
you pointed out, so I'll focus my reply here only.

> Also, this doesn't address the problem I originally commented on -
> it only shrinks the dcache, not the inode or filesystem caches that
> hold all the memory.

I understand that the icache is a greater memory user than the dcache.
I also understand that the icache can be dirty due to pending IO.
I am also okay to shrink some of the icache every time we shrink the 
dcache - and see below, this might happen if I change they way I am 
calling the shrinker.

However, since the dcache precedes the icache in the cache hierarchy,
and is the actual entity pinning the icache into memory, I don't see a 
reason to *limit* the icache size, since once the dcache is limited,
anything holding the icache into memory will go away eventually, and the 
shrinkers that run during memory pressure will be able to get rid of it.

> I mentioned the new per-sb shrinkers for a
> reason - you should be calling them, not __shrink_dcache_sb(). i.e.
> building a scan_control structure and calling
> sb->shrinker.shrink(&sb->shrinker,&sc);
>

Would you be okay with having prune_super() being called whenever the
nr_dentries_max limit is reached? It will effectively shrink both
the icache and the dcache, using the dentry limit as a trigger only.

> I'm seriously starting to think that this needs to share an
> implementation with the mm shrinker code, because it already
> solves most of these problems...

I have to think more about that. Hold on!
