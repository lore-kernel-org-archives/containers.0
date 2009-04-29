From: Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>
Subject: [patch 29/58] sched: do not count frozen tasks toward load
Date: Wed, 29 Apr 2009 15:07:28 -0700
Message-ID: <20090429220927.416887820@mini.kroah.org>
References: <20090429220659.339950874@mini.kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline;
	filename=0060-sched-do-not-count-frozen-tasks-toward-load.patch
In-Reply-To: <20090429221657.GA11765-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Cc: Justin Forbes <jmforbes-a5Mqy2EUIFVAfugRpC6u6w@public.gmane.org>, Domenico Andreoli <cavokz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Randy Dunlap <rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, Eugene Teo <eteo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Chris Wedgwood <reviews-vFB7bnJMxjixIvdkapsUdQ@public.gmane.org>, Michael Krufky <mkrufky-dJidKbW2IEtAfugRpC6u6w@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Rodrigo Rubira Branco <rbranco-OG872enO0lhw4vQD1pnt9QC/G2K4zDHf@public.gmane.org>, Chuck Wolber <chuckw-lrwSPXAIdEw7YuNMryXyOw@public.gmane.org>, Zwane Mwaikambo <zwane-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>, Jake Edge <jake-T1hC0tSOHrs@public.gmane.org>, Chris Wright <chrisw-69jw2NvuJkxg9hUCZPvPmw@public.gmane.org>, Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nigel Cunningham <nigel-jrkICu/7yk3k1uMJSBkQmQ@public.gmane.org>, Chuck Ebbert <cebbert-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Willy Tarreau <w@1>
List-Id: containers.vger.kernel.org

2.6.27-stable review patch.  If anyone has any objections, please let us know.

------------------

From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>

upstream commit: e3c8ca8336707062f3f7cb1cd7e6b3c753baccdd

Freezing tasks via the cgroup freezer causes the load average to climb
because the freezer's current implementation puts frozen tasks in
uninterruptible sleep (D state).

Some applications which perform job-scheduling functions consult the
load average when making decisions.  If a cgroup is frozen, the load
average does not provide a useful measure of the system's utilization
to such applications.  This is especially inconvenient if the job
scheduler employs the cgroup freezer as a mechanism for preempting low
priority jobs.  Contrast this with using SIGSTOP for the same purpose:
the stopped tasks do not count toward system load.

Change task_contributes_to_load() to return false if the task is
frozen.  This results in /proc/loadavg behavior that better meets
users' expectations.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Acked-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Acked-by: Nigel Cunningham <nigel-jrkICu/7yk3k1uMJSBkQmQ@public.gmane.org>
Tested-by: Nigel Cunningham <nigel-jrkICu/7yk3k1uMJSBkQmQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
LKML-Reference: <20090408194512.47a99b95-qBK8ZvQsWF7hXIiyNabO3w@public.gmane.org>
Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Signed-off-by: Chris Wright <chrisw-69jw2NvuJkxg9hUCZPvPmw@public.gmane.org>
Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>
---
 include/linux/sched.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -201,7 +201,8 @@ extern unsigned long long time_sync_thre
 #define task_is_stopped_or_traced(task)	\
 			((task->state & (__TASK_STOPPED | __TASK_TRACED)) != 0)
 #define task_contributes_to_load(task)	\
-				((task->state & TASK_UNINTERRUPTIBLE) != 0)
+				((task->state & TASK_UNINTERRUPTIBLE) != 0 && \
+				 (task->flags & PF_FROZEN) == 0)
 
 #define __set_task_state(tsk, state_value)		\
 	do { (tsk)->state = (state_value); } while (0)
