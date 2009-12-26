From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Subject: [PATCH v3 0/4] cgroup notifications API and memory thresholds
Date: Sat, 26 Dec 2009 02:30:56 +0200
Message-ID: <cover.1261786326.git.kirill__30049.9878394932$1261787625$gmane$org@shutemov.name>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org
Cc: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexander Shishkin <virtuoso-0lOfPCoBze7YtjvyW6yDsg@public.gmane.org>, Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Vladislav Buzov <vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

This patchset introduces eventfd-based API for notifications in cgroups and
implements memory notifications on top of it.

It uses statistics in memory controler to track memory usage.

Output of time(1) on building kernel on tmpfs:

Root cgroup before changes:
	make -j2  506.37 user 60.93s system 193% cpu 4:52.77 total
Non-root cgroup before changes:
	make -j2  507.14 user 62.66s system 193% cpu 4:54.74 total
Root cgroup after changes (0 thresholds):
	make -j2  507.13 user 62.20s system 193% cpu 4:53.55 total
Non-root cgroup after changes (0 thresholds):
	make -j2  507.70 user 64.20s system 193% cpu 4:55.70 total
Root cgroup after changes (1 thresholds, never crossed):
	make -j2  506.97 user 62.20s system 193% cpu 4:53.90 total
Non-root cgroup after changes (1 thresholds, never crossed):
	make -j2  507.55 user 64.08s system 193% cpu 4:55.63 total

Any comments?

v2 -> v3:
 - remove [RFC];
 - rebased to 2.6.33-rc2;
 - fixes based on comments;
 - fixed potential race on event removing;
 - use RCU-protected arrays to track trasholds.

v1 -> v2:
 - use statistics instead of res_counter to track resource usage;
 - fix bugs with locking.

v0 -> v1:
 - memsw support implemented.

Kirill A. Shutemov (4):
  cgroup: implement eventfd-based generic API for notifications
  memcg: extract mem_group_usage() from mem_cgroup_read()
  memcg: rework usage of stats by soft limit
  memcg: implement memory thresholds

 include/linux/cgroup.h |   24 ++++
 kernel/cgroup.c        |  208 ++++++++++++++++++++++++++++-
 mm/memcontrol.c        |  348 ++++++++++++++++++++++++++++++++++++++++++++----
 3 files changed, 552 insertions(+), 28 deletions(-)
