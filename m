From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 0/2] CGroups: cgroup member list enhancement/fix
Date: Thu, 02 Jul 2009 16:26:15 -0700
Message-ID: <20090702231814.3969.44308.stgit__39622.8512320251$1246577219$gmane$org@menage.mtv.corp.google.com>
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
To: lizf-BthXqXjhjHXBeW8qKU6YJg@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

The following series (written by Ben Blum) adds a "cgroup.procs" file
to each cgroup that reports unique tgids rather than pids, and fixes a
pid namespace bug in the existing "tasks" file that could cause
readers in different namespaces to interfere with one another.

The patches as a pair provide similar functionality to Li Zefan's
patch posted yesterday, with the addition on the "cgroup.procs" file;
if it's decided that Li's patch needs to be fast-tracked to 2.6.31,
then these patches can be rebased as a small extension of Li's patch;
if Li'z patch doesn't need to go to 2.6.31 then it makes more sense to
take this pair since they provide more overall functionality.

---

Ben Blum (2):
      Adds a read-only "procs" file similar to "tasks" that shows only unique tgids
      Ensures correct concurrent opening/reading of pidlists across pid namespaces


 include/linux/cgroup.h |   46 +++++-
 kernel/cgroup.c        |  355 +++++++++++++++++++++++++++++++++---------------
 2 files changed, 285 insertions(+), 116 deletions(-)
