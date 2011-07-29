From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: [PATCH][BUGFIX] cgroups: more safe tasklist locking in
	cgroup_attach_proc
Date: Fri, 29 Jul 2011 10:28:43 -0400
Message-ID: <20110729142842.GA8462__27636.0176074833$1311949985$gmane$org@unix33.andrew.cmu.edu>
References: <20110727171101.5e32d8eb@notabene.brown>
	<20110727150710.GB5242@unix33.andrew.cmu.edu>
	<20110727234235.GA2318@linux.vnet.ibm.com>
	<20110728110813.7ff84b13@notabene.brown>
	<20110728062616.GC15204@unix33.andrew.cmu.edu>
	<20110728171345.67d3797d@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110728171345.67d3797d-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
List-Id: containers.vger.kernel.org

Fix unstable tasklist locking in cgroup_attach_proc.

From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>

According to this thread - https://lkml.org/lkml/2011/7/27/243 - RCU is
not sufficient to guarantee the tasklist is stable w.r.t. de_thread and
exit. Taking tasklist_lock for reading, instead of rcu_read_lock,
ensures proper exclusion.

Signed-off-by: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
---
 kernel/cgroup.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff a/kernel/cgroup.c b/kernel/cgroup.c
--- a/kernel/cgroup.c	2011-07-21 19:17:23.000000000 -0700
+++ b/kernel/cgroup.c	2011-07-29 06:17:47.000000000 -0700
@@ -2024,7 +2024,7 @@
 		goto out_free_group_list;
 
 	/* prevent changes to the threadgroup list while we take a snapshot. */
-	rcu_read_lock();
+	read_lock(&tasklist_lock);
 	if (!thread_group_leader(leader)) {
 		/*
 		 * a race with de_thread from another thread's exec() may strip
@@ -2033,7 +2033,7 @@
 		 * throw this task away and try again (from cgroup_procs_write);
 		 * this is "double-double-toil-and-trouble-check locking".
 		 */
-		rcu_read_unlock();
+		read_unlock(&tasklist_lock);
 		retval = -EAGAIN;
 		goto out_free_group_list;
 	}
@@ -2054,7 +2054,7 @@
 	} while_each_thread(leader, tsk);
 	/* remember the number of threads in the array for later. */
 	group_size = i;
-	rcu_read_unlock();
+	read_unlock(&tasklist_lock);
 
 	/*
 	 * step 1: check that we can legitimately attach to the cgroup.
