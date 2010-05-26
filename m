From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 0/3][cr][v2]: Checkpoint/restart file leases
Date: Tue, 25 May 2010 18:07:40 -0700
Message-ID: <1274836063-13271-1-git-send-email-sukadev__40604.5867166997$1274835783$gmane$org@linux.vnet.ibm.com>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, matthew-Ztpu424NOJ8@public.gmane.org
List-Id: containers.vger.kernel.org

Checkpoint/restart file leases. See comments in patches 2 and 3 for
details. These patches apply on top of the following patchset which
implements checkpoint/restart of posix locks and file-owners:

https://lists.linux-foundation.org/pipermail/containers/2010-May/024613.html

Changelog[v2]:

	- Added patch 3/3 to ensure that lease-holder gets only one SIGIO
	  and that the total time the lease-breaker waits is limited to
	  lease_break_time (these two were TODOs in [v1]).

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

Sukadev Bhattiprolu (3):
  Define do_setlease()
  Checkpoint/restart file leases
  fileleases: C/R of an in-progress lease.

 fs/checkpoint.c                |   30 ++++++++++-
 fs/locks.c                     |  111 +++++++++++++++++++++++++++++++++++-----
 include/linux/checkpoint_hdr.h |    3 +
 include/linux/fs.h             |    4 ++
 4 files changed, 132 insertions(+), 16 deletions(-)
