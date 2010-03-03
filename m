From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH -mmotm 3/3] memcg: dirty pages instrumentation
Date: Wed, 03 Mar 2010 11:07:35 +0100
Message-ID: <1267610855.25158.82.camel__28925.5483578474$1267610921$gmane$org@laptop>
References: <1267478620-5276-1-git-send-email-arighi@develer.com>
	<1267478620-5276-4-git-send-email-arighi@develer.com>
	<1267537736.25158.54.camel@laptop>  <20100302221434.GB2369@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100302221434.GB2369@linux>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2010-03-02 at 23:14 +0100, Andrea Righi wrote:
> 
> I agree mem_cgroup_has_dirty_limit() is nicer. But we must do that under
> RCU, so something like:
> 
>         rcu_read_lock();
>         if (mem_cgroup_has_dirty_limit())
>                 mem_cgroup_get_page_stat()
>         else
>                 global_page_state()
>         rcu_read_unlock();
> 
> That is bad when mem_cgroup_has_dirty_limit() always returns false
> (e.g., when memory cgroups are disabled). So I fallback to the old
> interface.

Why is it that mem_cgroup_has_dirty_limit() needs RCU when
mem_cgroup_get_page_stat() doesn't? That is, simply make
mem_cgroup_has_dirty_limit() not require RCU in the same way
*_get_page_stat() doesn't either.

> What do you think about:
> 
>         mem_cgroup_lock();
>         if (mem_cgroup_has_dirty_limit())
>                 mem_cgroup_get_page_stat()
>         else
>                 global_page_state()
>         mem_cgroup_unlock();
> 
> Where mem_cgroup_read_lock/unlock() simply expand to nothing when
> memory cgroups are disabled.

I think you're engineering the wrong way around.

> > 
> > That allows for a 0 dirty limit (which should work and basically makes
> > all io synchronous).
> 
> IMHO it is better to reserve 0 for the special value "disabled" like the
> global settings. A synchronous IO can be also achieved using a dirty
> limit of 1.

Why?! 0 clearly states no writeback cache, IOW sync writes, a 1
byte/page writeback cache effectively reduces to the same thing, but its
not the same thing conceptually. If you want to put the size and enable
into a single variable pick -1 for disable or so.
