From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 0/5][v5][cr] Checkpoint/restart file locks
Date: Thu, 28 Oct 2010 23:16:36 -0700
Message-ID: <1288333001-28838-1-git-send-email-sukadev__32435.4679360569$1288332623$gmane$org@linux.vnet.ibm.com>
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
Cc: Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Steven Whitehouse <swhiteho-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Checkpoint/restart file locks.

Changelog[v5]:
	- This patchset only checkpoints/restores file locks. C/R of
	  file-owner and file-leases will be addressed in follown patches.
	  C/R of file-owner information must deal with nested-containers
	  and, will need a way to C/R struct pids. C/R of file-leases depends
	  on C/R of file-owner information.


Sukadev Bhattiprolu (5):
  Move file_lock macros into linux/fs.h
  Define flock_set()
  Define flock64_set()
  Checkpoint/restore file-locks
  Document design of C/R of file-locks and leases

 Documentation/checkpoint/file-locks |   52 ++++++
 fs/checkpoint.c                     |  318 +++++++++++++++++++++++++++++++++--
 fs/locks.c                          |   89 ++++++----
 include/linux/checkpoint_hdr.h      |   17 ++
 include/linux/fs.h                  |   10 +
 5 files changed, 433 insertions(+), 53 deletions(-)
 create mode 100644 Documentation/checkpoint/file-locks
