From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 00/11] checkpoint: various mm-related bits
Date: Wed, 20 Oct 2010 13:56:35 -0500
Message-ID: <1287601006-13794-1-git-send-email-ntl@pobox.com>
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
To: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Oren,

Here is the hugetlb code rebased to latest ckpt-v22-dev, along with
support for BSR device mappings and a minor fix or two.

Nathan Lynch (11):
  checkpoint: fix leak in VMA restore error path
  checkpoint: check actual array size before dereferencing
  checkpoint: reformat CKPT_VMA_NOT_SUPPORTED
  checkpoint: introduce device vma type
  checkpoint: allow VM_{IO,RESERVED,PFNMAP} mappings
  checkpoint: enable c/r for bsr driver
  checkpoint/ipc: allow shmat callers to specify ipc namespace
  checkpoint/restart of anonymous hugetlb mappings
  hugetlbfs checkpoint/restart hooks
  checkpoint/restart of SysV SHM_HUGETLB regions
  remove VM_HUGETLB from CKPT_VMA_NOT_SUPPORTED

 drivers/char/bsr.c             |   13 ++
 fs/hugetlbfs/inode.c           |   24 ++++-
 include/linux/checkpoint.h     |   17 ++-
 include/linux/checkpoint_hdr.h |   18 +++
 include/linux/hugetlb.h        |   11 ++
 include/linux/shm.h            |    8 +-
 ipc/checkpoint_shm.c           |  154 ++++++++++++++++++++++--
 ipc/shm.c                      |   18 ++--
 mm/checkpoint.c                |   55 ++++++++-
 mm/hugetlb.c                   |  257 ++++++++++++++++++++++++++++++++++++++++
 10 files changed, 543 insertions(+), 32 deletions(-)

-- 
1.7.2.2
