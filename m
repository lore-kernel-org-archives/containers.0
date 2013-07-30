From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: memcg creates an unkillable task in 3.11-rc2
Date: Tue, 30 Jul 2013 01:19:31 -0700
Message-ID: <87ppu0a298.fsf_-_@tw-ebiederman.twitter.com>
References: <20130723174711.GE21100@mtj.dyndns.org>
	<8761vui4cr.fsf@xmission.com> <20130729075939.GA4678@dhcp22.suse.cz>
	<87ehahg312.fsf@xmission.com> <20130729095109.GB4678@dhcp22.suse.cz>
	<20130729161026.GD22605@mtj.dyndns.org> <87r4eh70yg.fsf@xmission.com>
	<51F71DE2.4020102@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <51F71DE2.4020102-hv44wF8Li93QT0dZR+AlfA@public.gmane.org> (Li Zefan's message of "Tue, 30 Jul
	2013 09:58:58 +0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Glauber Costa <glommer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, kent.overstreet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org> writes:

>> I am also seeing what looks like a leak somewhere in the cgroup code as
>> well.  After some runs of the same reproducer I get into a state where
>> after everything is clean up.  All of the control groups have been
>> removed and the cgroup filesystem is unmounted, I can mount a cgroup
>> filesystem with that same combindation of subsystems, but I can't mount
>> a cgroup filesystem with any of those subsystems in any other
>> combination.  So I am guessing that the superblock is from the original
>> mounting is still lingering for some reason.
>> 
>
> If this happens again, you can check /proc/cgroups, 
>
> #subsys_name    hierarchy       num_cgroups     enabled
> cpuset  0       1       1
> debug   0       1       1
> cpu     0       1       1
> cpuacct 0       1       1
> memory  0       1       1
> devices 0       1       1
> freezer 0       1       1
> blkio   0       1       1
>
> If "hierachy" is not 0, then it didn't really unmounted. If "num_cgroups"
> is not 1, then there're some cgroups not really destroyed though they've
> been rmdired.

Interesting.  It looks at some point I had some cpu and cpuacct
hierarchies that never really unmounted.

#subsys_name    hierarchy       num_cgroups     enabled
cpuset  0       1       1
cpu     89      1       1
cpuacct 89      1       1
memory  0       1       1
devices 0       1       1
freezer 0       1       1
net_cls 0       1       1
blkio   0       1       1
perf_event      0       1       1
hugetlb 0       1       1

And playing a little more I get the leak scenario.

#subsys_name    hierarchy       num_cgroups     enabled
cpuset  0       1       1
cpu     90      3       1
cpuacct 90      3       1
memory  90      3       1
devices 0       1       1
freezer 90      3       1
net_cls 0       1       1
blkio   0       1       1
perf_event      0       1       1
hugetlb 0       1       1

So it definitely did not unmount.

After echo 3 > /proc/sys/vm/drop_caches

#subsys_name    hierarchy       num_cgroups     enabled
cpuset  0       1       1
cpu     90      1       1
cpuacct 90      1       1
memory  90      1       1
devices 0       1       1
freezer 90      1       1
net_cls 0       1       1
blkio   0       1       1
perf_event      0       1       1
hugetlb 0       1       1

Hmm.  But after some time passes I have

#subsys_name    hierarchy       num_cgroups     enabled
cpuset  0       1       1
cpu     0       1       1
cpuacct 0       1       1
memory  0       1       1
devices 0       1       1
freezer 0       1       1
net_cls 0       1       1
blkio   0       1       1
perf_event      0       1       1
hugetlb 0       1       1

Hmm. Looking farther I see what is going on. And it has nothing to do
with the freezer. (I have commented out that code and reproduced it
without the freezer to be doubly certain).


On the exit path exit_robust_list is triggering a page fault to fault a
page back in.  Which since we have no memory causes the exit path
to get stuck in mem_cgroup_handle_oom.

Which means the following change should fix the hang.  I will test it in just
a second.

The problem is that we only handled pending fatal signals and exiting
processes when the OOM logic was enabled. Sigh.

Eric

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 00a7a66..5998a57 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1792,16 +1792,6 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
        unsigned int points = 0;
        struct task_struct *chosen = NULL;
 
-       /*
-        * If current has a pending SIGKILL or is exiting, then automatically
-        * select it.  The goal is to allow it to allocate so that it may
-        * quickly exit and free its memory.
-        */
-       if (fatal_signal_pending(current) || current->flags & PF_EXITING) {
-               set_thread_flag(TIF_MEMDIE);
-               return;
-       }
-
        check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, order, NULL);
        totalpages = mem_cgroup_get_limit(memcg) >> PAGE_SHIFT ? : 1;
        for_each_mem_cgroup_tree(iter, memcg) {
@@ -2220,7 +2210,15 @@ static bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask,
                mem_cgroup_oom_notify(memcg);
        spin_unlock(&memcg_oom_lock);
 
-       if (need_to_kill) {
+       /*
+        * If current has a pending SIGKILL or is exiting, then automatically
+        * select it.  The goal is to allow it to allocate so that it may
+        * quickly exit and free its memory.
+        */
+       if (fatal_signal_pending(current) || current->flags & PF_EXITING) {
+               set_thread_flag(TIF_MEMDIE);
+               finish_wait(&memcg_oom_waitq, &owait.wait);
+       } else if (need_to_kill) {
                finish_wait(&memcg_oom_waitq, &owait.wait);
                mem_cgroup_out_of_memory(memcg, mask, order);
        } else {
