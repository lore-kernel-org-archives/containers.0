From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 0/5] blk-throttle: writeback and swap IO control
Date: Tue, 22 Feb 2011 18:12:51 +0100
Message-ID: <1298394776-9957-1-git-send-email-arighi__13185.8000568629$1298394874$gmane$org@develer.com>
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
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Wu Fengguang <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Currently the blkio.throttle controller only support synchronous IO requests.
This means that we always look at the current task to identify the "owner" of
each IO request.

However dirty pages in the page cache can be wrote to disk asynchronously by
the per-bdi flusher kernel threads or by any other thread in the system,
according to the writeback policy.

For this reason the real writes to the underlying block devices may
occur in a different IO context respect to the task that originally
generated the dirty pages involved in the IO operation. This makes the
tracking and throttling of writeback IO more complicate respect to the
synchronous IO from the blkio controller's perspective.

The same concept is also valid for anonymous pages involed in IO operations
(swap).

This patch allow to track the cgroup that originally dirtied each page in page
cache and each anonymous page and pass these informations to the blk-throttle
controller. These informations can be used to provide a better service level
differentiation of buffered writes swap IO between different cgroups.

Testcase
========
- create a cgroup with 1MiB/s write limit:
  # mount -t cgroup -o blkio none /mnt/cgroup
  # mkdir /mnt/cgroup/foo
  # echo 8:0 $((1024 * 1024)) > /mnt/cgroup/foo/blkio.throttle.write_bps_device

- move a task into the cgroup and run a dd to generate some writeback IO

Results:
  - 2.6.38-rc6 vanilla:
  $ cat /proc/$$/cgroup
  1:blkio:/foo
  $ dd if=/dev/zero of=zero bs=1M count=1024 &
  $ dstat -df
  --dsk/sda--
   read  writ
     0    19M
     0    19M
     0     0
     0     0
     0    19M
  ...

  - 2.6.38-rc6 + blk-throttle writeback IO control:
  $ cat /proc/$$/cgroup
  1:blkio:/foo
  $ dd if=/dev/zero of=zero bs=1M count=1024 &
  $ dstat -df
  --dsk/sda--
   read  writ
     0  1024
     0  1024
     0  1024
     0  1024
     0  1024
  ...

TODO
====
 - lots of testing

Any feedback is welcome.
-Andrea

[PATCH 1/5] blk-cgroup: move blk-cgroup.h in include/linux/blk-cgroup.h
[PATCH 2/5] blk-cgroup: introduce task_to_blkio_cgroup()
[PATCH 3/5] page_cgroup: make page tracking available for blkio
[PATCH 4/5] blk-throttle: track buffered and anonymous pages
[PATCH 5/5] blk-throttle: buffered and anonymous page tracking instrumentation

 block/Kconfig               |    2 +
 block/blk-cgroup.c          |   15 ++-
 block/blk-cgroup.h          |  335 ------------------------------------------
 block/blk-throttle.c        |   89 +++++++++++-
 block/cfq.h                 |    2 +-
 fs/buffer.c                 |    1 +
 include/linux/blk-cgroup.h  |  341 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/blkdev.h      |   26 +++-
 include/linux/memcontrol.h  |    6 +
 include/linux/mmzone.h      |    4 +-
 include/linux/page_cgroup.h |   33 ++++-
 init/Kconfig                |    4 +
 mm/Makefile                 |    3 +-
 mm/bounce.c                 |    1 +
 mm/filemap.c                |    1 +
 mm/memcontrol.c             |    6 +
 mm/memory.c                 |    5 +
 mm/page-writeback.c         |    1 +
 mm/page_cgroup.c            |  129 +++++++++++++++--
 mm/swap_state.c             |    2 +
 20 files changed, 649 insertions(+), 357 deletions(-)
