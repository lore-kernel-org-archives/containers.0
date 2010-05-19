From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 0/9][cr][v2]: C/R file owner and posix file locks
Date: Tue, 18 May 2010 20:07:23 -0700
Message-ID: <1274238452-15382-1-git-send-email-sukadev__37380.6983152919$1274238165$gmane$org@linux.vnet.ibm.com>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, matthew-Ztpu424NOJ8@public.gmane.org
List-Id: containers.vger.kernel.org

Checkpoint/restart file-owner and posix file locks.

  [PATCH 1/9] Add uid, euid params to f_modown()
  [PATCH 2/9] Add uid, euid params to __f_setown()
  [PATCH 3/9] Checkpoint file-owner information
  [PATCH 4/9] Restore file_owner info
  [PATCH 5/9] Move file_lock macros into linux/fs.h
  [PATCH 6/9] Checkpoint file-locks
  [PATCH 7/9] Define flock_set()
  [PATCH 8/9] Define flock64_set()
  [PATCH 9/9] Restore file-locks

 drivers/char/tty_io.c          |    3 +-
 drivers/net/tun.c              |    3 +-
 fs/checkpoint.c                |  353 ++++++++++++++++++++++++++++++++++++----
 fs/fcntl.c                     |   19 +-
 fs/locks.c                     |   92 ++++++-----
 fs/notify/dnotify/dnotify.c    |    3 +-
 include/linux/checkpoint_hdr.h |   15 ++
 include/linux/fs.h             |   13 ++-
 8 files changed, 418 insertions(+), 83 deletions(-)

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
