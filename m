From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 00/16][cr][v3]: C/R file owner, locks, leases
Date: Tue,  3 Aug 2010 16:11:21 -0700
Message-ID: <1280877097-12377-1-git-send-email-sukadev__24131.6383624964$1280876899$gmane$org@linux.vnet.ibm.com>
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
Cc: Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>, John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Checkpoint/restart file owner, file-locks and file-lease information.

Changelog[v3]:
	- Broke-up C/R of file-leases patches into smaller patches and included
	  them in this set.
	- Addressed comments from Jamie Lokier, Oren Laadan with help from
	  John Stultz on the computation of time offsets.


Sukadev Bhattiprolu (16):
  Add uid, euid params to f_modown()
  Add uid, euid params to __f_setown()
  Checkpoint file-owner information
  Restore file_owner info
  Move file_lock macros into linux/fs.h
  Checkpoint file-locks
  Define flock_set()
  Define flock64_set()
  Restore file-locks
  Initialize ->fl_break_time to 0
  Add ->fl_type_prev field.
  Add ->fl_break_notified field.
  Add jiffies_begin field to ckpt_ctx
  Checkpoint file-leases
  Define do_setlease()
  Restore file-leases

 drivers/char/tty_io.c            |    3 +-
 drivers/net/tun.c                |    3 +-
 fs/checkpoint.c                  |  410 +++++++++++++++++++++++++++++++++++---
 fs/fcntl.c                       |   19 +-
 fs/locks.c                       |  207 +++++++++++++++-----
 fs/notify/dnotify/dnotify.c      |    3 +-
 include/linux/checkpoint_hdr.h   |   26 +++
 include/linux/checkpoint_types.h |    1 +
 include/linux/fs.h               |   17 ++-
 kernel/checkpoint/sys.c          |    1 +
 10 files changed, 596 insertions(+), 94 deletions(-)

Note: Most of the "added lines" in fs/locks.c are comments about C/R :-)
