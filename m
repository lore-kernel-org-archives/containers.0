From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: memcg creates an unkillable task in 3.11-rc2
Date: Wed, 31 Jul 2013 09:37:26 +0200
Message-ID: <20130731073726.GC30514@dhcp22.suse.cz>
References: <8761vui4cr.fsf@xmission.com>
	<20130729075939.GA4678@dhcp22.suse.cz>
	<87ehahg312.fsf@xmission.com>
	<20130729095109.GB4678@dhcp22.suse.cz>
	<20130729161026.GD22605@mtj.dyndns.org>
	<87r4eh70yg.fsf@xmission.com> <51F71DE2.4020102@huawei.com>
	<87ppu0a298.fsf_-_@tw-ebiederman.twitter.com>
	<20130730123120.GA15847@dhcp22.suse.cz>
	<874nbc3sx1.fsf@tw-ebiederman.twitter.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <874nbc3sx1.fsf-HxuHnoDHeQZYhcs0q7wBk77fW72O3V7zAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Glauber Costa <glommer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, kent.overstreet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

[I am CCing David here as well]

On Tue 30-07-13 09:37:46, Eric W. Biederman wrote:
> Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org> writes:
> 
> > On Tue 30-07-13 01:19:31, Eric W. Biederman wrote:
> > [...]
> >> Hmm. Looking farther I see what is going on. And it has nothing to do
> >> with the freezer. (I have commented out that code and reproduced it
> >> without the freezer to be doubly certain).
> >> 
> >> 
> >> On the exit path exit_robust_list is triggering a page fault to fault a
> >> page back in.  Which since we have no memory causes the exit path
> >> to get stuck in mem_cgroup_handle_oom.
> >
> > Hmm, interesting. I assume the exit is caused by the SIGKILL, right?
> > If yes, then why it hasn't coughed early in __mem_cgroup_try_charge
> 
> Interesting question.  This isn't the primary thread but we do send
> SIGKILL to the secondary threads as well.
> 
> We definitely need those checks on both paths making my change valid.
> 
> Oh. Duh!  This is after we act on SIGKILL so SIGKILL is no longer
> pending.

Very well spotted Eric! What do you think about the following patch?
I would have to check since when the exit path could trigger the fault
but I guess this is worth stable backport.
---
From 411408558f2858328ea25e69567e9a53a8314032 Mon Sep 17 00:00:00 2001
From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Date: Wed, 31 Jul 2013 08:48:54 +0200
Subject: [PATCH] memcg: Do not hang on OOM when killed by userspace OOM

Eric has reported that he can see task(s) stuck in memcg OOM handler
regularly. The only way out is to
	echo 0 > $GROUP/memory.oom_controll

His usecase is:
- Setup a hierarchy with memory and the freezer
  (disable kernel oom and have a process watch for oom).
- In that memory cgroup add a process with one thread per cpu.
- In one thread slowly allocate once per second I think it is 16M of ram
  and mlock and dirty it (just to force the pages into ram and stay there).
- When oom is achieved loop:
  * attempt to freeze all of the tasks.
  * if frozen send every task SIGKILL, unfreeze, remove the directory in
    cgroupfs.

Eric has then pinpointed the issue to be memcg specific.

All tasks are sitting on the memcg_oom_waitq when memcg oom is disabled.
Those that have received fatal signal will bypass the charge and should
continue on their way out. The tricky part is that that exit path might
trigger a page fault (e.g. exit_robust_list) thus the memcg charge
while its memcg is still under OOM because nobody has released any
charges. Unlike with the in-kernel OOM handler the exiting task doesn't
get TIF_MEMDIE set so it doesn't shortcut charges and falls to the
memcg OOM again without any way out of it as there are no fatal signals
pending anymore.

This patch sets the TIF_MEMDIE flag pro actively in mem_cgroup_handle_oom
if the memcg is disabled after the task is woken up with fatal signal
pending. This means that any further charges will be bypassed early in
__mem_cgroup_try_charge and the task will have chance to exit finally.

Strictly speaking we might mark also a task which hasn't been killed by
userspace OOM handler but this is not harmful as the task is going away
anyway and under-oom group would like to see it go as soon as possible.

Reported-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Debugged-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
---
 mm/memcontrol.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d12ca6f..d4103b0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2235,8 +2235,19 @@ static bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask,
 
 	mem_cgroup_unmark_under_oom(memcg);
 
-	if (test_thread_flag(TIF_MEMDIE) || fatal_signal_pending(current))
+	if (test_thread_flag(TIF_MEMDIE))
 		return false;
+
+	/*
+	 * Userspace OOM killer might have killed this task but
+	 * there is no way it could have set TIF_MEMDIE as well
+	 * so we have to set it manually.
+	 */
+	if (fatal_signal_pending(current)) {
+		if (memcg->oom_kill_disable)
+			set_thread_flag(TIF_MEMDIE);
+		return false;
+	}
 	/* Give chance to dying process */
 	schedule_timeout_uninterruptible(1);
 	return true;
-- 
1.8.3.2

-- 
Michal Hocko
SUSE Labs
