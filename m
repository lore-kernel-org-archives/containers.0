From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 9/9] ext3: do not throttle metadata and journal IO
Date: Wed, 22 Apr 2009 09:33:49 +0900
Message-ID: <20090422093349.1ee9ae82.kamezawa.hiroyu__9623.44973017952$1240360789$gmane$org@jp.fujitsu.com>
References: <20090417143903.GA30365@linux> <20090421001822.GB19186@mit.edu>
	<20090421083001.GA8441@linux> <20090421140631.GF19186@mit.edu>
	<20090421143130.GA22626@linux> <20090421163537.GI19186@mit.edu>
	<20090421172317.GM19637@balbir.in.ibm.com>
	<20090421174620.GD15541@mit.edu>
	<20090421181429.GO19637@balbir.in.ibm.com>
	<20090421191401.GF15541@mit.edu> <20090421204905.GA5573@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090421204905.GA5573@linux>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, Gui-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 21 Apr 2009 22:49:06 +0200
Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> yep! right. Anyway, it's not completely wrong to account dirty pages in
> this way. The dirty pages actually belong to cgroup A and providing per
> cgroup upper limits of dirty pages could help to equally distribute
> dirty pages, that are hard/slow to reclaim, among cgroups.
> 
> But this is definitely another problem.
> 
Hmm, my motivation for dirty accounting in memcg is for supporting dirty_ratio
to do smooth page reclaiming and to kick background-write-out.


> And it doesn't help for the problem described by Ted, expecially for the
> IO controller. The only way I see to correctly handle that case is to
> limit the rate of dirty pages per cgroup, accounting the dirty activity
> to the cgroup that firstly touched the page (and not the owner as
> intended by the memory controller).
> 
Owner of the page should know dirty ratio, too.

> And this should be probably strictly connected to the IO controller. If
> we throttle or delay the dispatching/submission of some IO requests
> without throttling the dirty pages rate a cgroup could completely waste
> its own available memory with dirty (hard and slow to reclaim) pages.
> 
> That is in part the approach I used in io-throttle v12, adding a hook in
> balance_dirty_pages_ratelimited_nr() to throttle the current task when
> cgroup's IO limit are exceeded. Argh!
> 
> So, another proposal could be to re-add in io-throttle v14 the old hook
> also in balance_dirty_pages_ratelimited_nr().
> 
> In this way io-throttle would:
> 
> - use page_cgroup infrastructure and page_cgroup->flags to encode the
>   cgroup id that firstly dirtied a generic page
> - account and opportunely throttle sync and writeback IO requests in
>   submit_bio()
> - at the same time throttle the tasks in
>   balance_dirty_pages_ratelimited_nr() if the cgroup they belong has
>   exhausted the IO BW (or quota, share, etc. in case of proportional BW
>   limit)
> 

IMHO, io-controller should just work as I/O subsystem as bdi. Now, per-bdi dirty_ratio
is suppoted and it seems to work well.  

Can't we write a function like  bdi_writeout_fraction() ?;
It will be a simple choice.

Thanks,
-Kame
