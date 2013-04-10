From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH v2 02/28] vmscan: take at least one pass with shrinkers
Date: Wed, 10 Apr 2013 11:32:38 +0400
Message-ID: <51651596.7090903__16329.4552629397$1365579130$gmane$org@parallels.com>
References: <1364548450-28254-1-git-send-email-glommer@parallels.com>
	<1364548450-28254-3-git-send-email-glommer@parallels.com>
	<515936B5.8070501@jp.fujitsu.com>
	<515940E4.8050704@parallels.com> <5164F416.8040903@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <5164F416.8040903-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ric Mason <ric.masonn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Shrinnker <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On 04/10/2013 09:09 AM, Ric Mason wrote:
>> Before it, we will try to shrink 512 objects and succeed at 0 (because
>> > batch is 1024). After this, we will try to free 512 objects and succeed
>> > at an undefined quantity between 0 and 512.
> Where you get the magic number 512 and 1024? The value of SHRINK_BATCH
> is 128.
> 
This is shrinker-defined. For instance, the super-block shrinker reads:

                s->s_shrink.shrink = prune_super;
                s->s_shrink.batch = 1024;

And then vmscan:
                long batch_size = shrinker->batch ? shrinker->batch
                                                  : SHRINK_BATCH;

I am dealing too much with the super block shrinker these days, so I
just had that cached in my mind and forgot to check the code and be more
explicit.

In any case, that was a numeric example that is valid nevertheless.
