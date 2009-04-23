From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 9/9] ext3: do not throttle metadata and journal IO
Date: Thu, 23 Apr 2009 09:05:35 +0900
Message-ID: <20090423090535.ec419269.kamezawa.hiroyu__13044.0337038182$1240445495$gmane$org@jp.fujitsu.com>
References: <20090421140631.GF19186@mit.edu> <20090421143130.GA22626@linux>
	<20090421163537.GI19186@mit.edu>
	<20090421172317.GM19637@balbir.in.ibm.com>
	<20090421174620.GD15541@mit.edu>
	<20090421181429.GO19637@balbir.in.ibm.com>
	<20090421191401.GF15541@mit.edu> <20090421204905.GA5573@linux>
	<20090422093349.1ee9ae82.kamezawa.hiroyu@jp.fujitsu.com>
	<20090422102153.9aec17b9.kamezawa.hiroyu@jp.fujitsu.com>
	<20090422102239.GA1935@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090422102239.GA1935@linux>
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
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Jens-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Gui-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 22 Apr 2009 12:22:41 +0200
Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
 
> Actually I was proposing something quite similar, if I've understood
> well. Just add a hook in balance_dirty_pages() to throttle tasks in
> cgroups that exhausted their IO BW.
> 
> The way to do so will be similar to the per-bdi write throttling, taking
> in account the IO requests previously submitted per cgroup, the pages
> dirtied per cgroup (considering that are not necessarily dirtied by the
> owner of the page) and apply something like congestion_wait() to
> throttle the tasks in the cgroups that exceeded the BW limit.
> 
> Maybe we can just introduce cgroup_dirty_limit() simply replicating what
> we're doing for task_dirty_limit(), but using per cgroup statistics of
> course.
> 
> I can change the io-throttle controller to do so. This feature should be
> valid also for the proportional BW approach.
> 
> BTW Vivek's proposal to also dispatch IO requests according to cgroup
> proportional BW limits can be still valid and it is worth to be tested
> IMHO. But we must also find a way to say to the right cgroup: hey! stop
> to waste the memory with dirty pages, because you've directly or
> indirectly generated too much IO in the system and I'm throttling and/or
> not scheduling your IO requests.
> 
> Objections?
> 
No objections. plz let me know my following understanding is right.

  1. dirty_ratio should be supported per cgroup.
     - Memory cgroup should support dirty_ratio or dirty_ratio cgroup should be implemented.
       For doing this, we can make use of page_cgroup.

       One good point of dirty-ratio cgroup is that dirty-ratio accounting is done
       against a cgroup which made pages dirty not against a owner of the page. But
       if dirty_ratio cgroup is completely independent from mem_cgroup, it cannot
       be a help for memory reclaiming.
       Then,
         - memcg itself should have dirty_ratio check.
         - like bdi/task_dirty_limit(), a cgroup (which is not memcg) can be used
           another filter for dirty_ratio.

  2. dirty_ratio is not I/O BW control.

  3. I/O BW(limit) control cgroup should be implemented and it should be exsiting
     in I/O scheduling layer or somewhere around. But it's not easy.

  4. To track bufferred I/O, we have to add "tag" to pages which tell us who
     generated the I/O. Now it's called blockio-cgroup and implementation details
     are still under discussion.

So, current status is.

  A. memcg should support dirty_ratio for its own memory reclaim.
     in plan.

  B. another cgroup can be implemnted to support cgroup_dirty_limit().
     But relationship with "A" should be discussed.
     no plan yet.

  C. I/O cgroup and bufferred I/O tracking system.
     Now under patch review.

And this I/O throttle is mainly for "C" discussion. 

Right ?

-Kame



Regards,
-Kame
