From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCHSET pm-freezer] freezer: fixes & simplifications
Date: Sat,  3 Sep 2011 03:27:44 +0900
Message-ID: <1314988070-12244-1-git-send-email-tj__8478.32026561282$1314988164$gmane$org@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

These six patches are fixes and simplifications for the recent freezer
changes.  The first four have been posted twice.  Changes since the
last posting[L] are

* freezer->state setting bug fix updated per Matt Helsley so that the
  actual per-task freeze/thaw operations are always performed.

* fixed a bug caused by forgetting to unlock freezer_lock in "freezer:
  restructure __refrigerator()".

* Two patches added.  The fifth one is mostly trivial.  The sixth a
  bit more involved but still shouldn't cause any noticeable
  functional difference.  This removes the buggy and unused
  freezable_with_signal.

Properly tested this time.  As hera is still down, no git branch
available at this point.  Patch list and diffstat follow.

Thanks.

 [PATCH 1/6] cgroup_freezer: fix freezer->state setting bug in
 [PATCH 2/6] freezer: set PF_NOFREEZE on a dying task right before
 [PATCH 3/6] freezer: restructure __refrigerator()
 [PATCH 4/6] freezer: use lock_task_sighand() in
 [PATCH 5/6] freezer: remove unused @sig_only from freeze_task()
 [PATCH 6/6] freezer: kill unused set_freezable_with_signal()

 include/linux/freezer.h |   22 +------------
 include/linux/sched.h   |    1
 kernel/cgroup_freezer.c |   18 +++++------
 kernel/exit.c           |   10 ++----
 kernel/freezer.c        |   78 ++++++++++++++++--------------------------------
 kernel/kthread.c        |    2 -
 kernel/power/process.c  |    8 ++--
 7 files changed, 47 insertions(+), 92 deletions(-)

--
tejun

[L] http://thread.gmane.org/gmane.linux.kernel/1186387
