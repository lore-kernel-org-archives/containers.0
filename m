From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH v2 02/28] vmscan: take at least one pass with shrinkers
Date: Tue, 9 Apr 2013 11:43:33 +0400
Message-ID: <5163C6A5.5050307__35774.4744200774$1365493391$gmane$org@parallels.com>
References: <1364548450-28254-1-git-send-email-glommer@parallels.com>
	<1364548450-28254-3-git-send-email-glommer@parallels.com>
	<20130408084202.GA21654@lge.com> <51628412.6050803@parallels.com>
	<20130408090131.GB21654@lge.com> <51628877.5000701@parallels.com>
	<20130409005547.GC21654@lge.com> <20130409012931.GE17758@dastard>
	<20130409020505.GA4218@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130409020505.GA4218-Hm3cg6mZ9cc@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Joonsoo Kim <iamjoonsoo.kim-Hm3cg6mZ9cc@public.gmane.org>
Cc: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On 04/09/2013 06:05 AM, Joonsoo Kim wrote:
> I don't think so.
> Yes, lowmem_shrink() return number of (in)active lru pages
> when nr_to_scan is 0. And in shrink_slab(), we divide it by lru_pages.
> lru_pages can vary where shrink_slab() is called, anyway, perhaps this
> logic makes total_scan below 128.
> 
You may benefit from looking at the lowmemory patches in this patchset
itself. We modified the shrinker API to separate the count and scan
phases. With this, the whole nr_to_scan == 0 disappears and the code
gets easier to follow.

>> > 
>> > And, interestingly enough, when the file cache has been pruned down
>> > to it's smallest possible size, that's when the shrinker *won't run*
>> > because the that's when the total_scan will be smaller than the
>> > batch size and hence shrinker won't get called.
>> > 
>> > The shrinker is hacky, abuses the shrinker API, and doesn't appear
>> > to do what it is intended to do.  You need to fix the shrinker, not
>> > use it's brokenness as an excuse to hold up a long overdue shrinker
>> > rework.
> Agreed. I also think shrinker rework is valuable and I don't want
> to become a stopper for this change. But, IMHO, at least, we should
> notify users of shrinker API to know how shrinker API behavior changed,

Except that the behavior didn't change.

> because this is unexpected behavior change when they used this API.
> When they used this API, they can assume that it is possible to control
> logic with seeks and return value(when nr_to_scan=0), but with this patch,
> this assumption is broken.
> 

Jonsoo, you are still missing the point. nr_to_scan=0 has nothing to do
with this, or with this patch. nr_to_scan will reach 0 ANYWAY if you
shrink all objects you have to shrink, which is a *very* common thing to
happen.

The only case changed here is where this happen when attempting to
shrink a small number of objects that is smaller than the batch size.

Also, again, the nr_to_scan=0 checks in the shrinker calls have nothing
to do with that. They reflect the situation *BEFORE* the shrinker was
called. So how many objects we shrunk afterwards have zero to do with
it. This is just the shrinker API using the magic value of 0 to mean :
"don't shrink, just tell me how much do you have", vs a positive number
meaning "try to shrink as much as nr_to_scan objects".
