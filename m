From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Update documentation of cgroups tasks and procs files
Date: Wed, 23 Sep 2009 17:12:49 -0700
Message-ID: <20090924001249.4783.91619.stgit__5792.98360175944$1253751327$gmane$org@menage.mtv.corp.google.com>
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
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Update documentation of cgroups tasks and procs files

Document the cgroup.procs file.

Clarify the semantics of the cgroup.procs and tasks files.  Although
the current cgroup.procs interface returns a sorted and uniqified list
of pids, potential future performance enhancements could result in
those properties being removed - explicitly document this aspect of
the API.

There are no existing users of cgroup.procs, so compatibility isn't an
issue.  There are users of the "tasks" file, but none that would
appear to break in the event of the sorted property being broken. The
standard "libcpuset" explicitly sorts the results of reading from the
tasks file, and "libcg" and other users don't appear to care about
ordering.

Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

---

 Documentation/cgroups/cgroups.txt |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index d5be8ae..20face8 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -227,7 +227,14 @@ as the path relative to the root of the cgroup file system.
 Each cgroup is represented by a directory in the cgroup file system
 containing the following files describing that cgroup:
 
- - tasks: list of tasks (by pid) attached to that cgroup
+ - tasks: list of tasks (by pid) attached to that cgroup.  This list
+   is not guaranteed to be sorted.  Writing a thread id into this file
+   moves the thread into this cgroup.
+ - cgroup.procs: list of tgids in the cgroup.  This list is not
+   guaranteed to be sorted or free of duplicate tgids, and userspace
+   should sort/uniquify the list if this property is required.
+   Writing a tgid into this file moves all threads with that tgid into
+   this cgroup.
  - notify_on_release flag: run the release agent on exit?
  - release_agent: the path to use for release notifications (this file
    exists in the top cgroup only)
@@ -374,7 +381,7 @@ Now you want to do something with this cgroup.
 
 In this directory you can find several files:
 # ls
-notify_on_release tasks
+cgroup.procs notify_on_release tasks
 (plus whatever files added by the attached subsystems)
 
 Now attach your shell to this cgroup:
