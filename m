From: Changli Gao <xiaosuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 0/9] mm: generic adaptive large memory allocation APIs
Date: Thu, 13 May 2010 17:49:07 +0800
Message-ID: <1273744147-7594-1-git-send-email-xiaosuo__17579.9625031233$1273744328$gmane$org@gmail.com>
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
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andreas Dilger <adilger-xsfywfwIY+M@public.gmane.org>, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "James E.J. Bottomley" <James.Bottomley-l3A5Bk7waGM@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Christoph Raisch <raisch-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, Hoang-Nam Nguyen <hnguyen-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Changli Gao <xiaosuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Roland Dreier <rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>, Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Divy Le Ray <divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
List-Id: containers.vger.kernel.org

generic adaptive large memory allocation APIs

kv*alloc are used to allocate large contiguous memory and the users don't mind
whether the memory is physically or virtually contiguous. The allocator always
try its best to allocate physically contiguous memory first.

In this patch set, some APIs are introduced: kvmalloc(), kvzalloc(), kvcalloc(),
kvrealloc(), kvfree() and kvfree_inatomic().

Some code are converted to use the new generic APIs instead.

Signed-off-by: Changli Gao <xiaosuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
----
 drivers/infiniband/hw/ehca/ipz_pt_fn.c |   22 +-----
 drivers/net/cxgb3/cxgb3_defs.h         |    2 
 drivers/net/cxgb3/cxgb3_offload.c      |   31 ---------
 drivers/net/cxgb3/l2t.c                |    4 -
 drivers/net/cxgb4/cxgb4.h              |    3 
 drivers/net/cxgb4/cxgb4_main.c         |   37 +----------
 drivers/net/cxgb4/l2t.c                |    2 
 drivers/scsi/cxgb3i/cxgb3i_ddp.c       |   12 +--
 drivers/scsi/cxgb3i/cxgb3i_ddp.h       |   26 -------
 drivers/scsi/cxgb3i/cxgb3i_offload.c   |    6 -
 fs/ext4/super.c                        |   21 +-----
 fs/file.c                              |  109 ++++-----------------------------
 include/linux/mm.h                     |   31 +++++++++
 include/linux/vmalloc.h                |    1 
 kernel/cgroup.c                        |   47 +-------------
 kernel/relay.c                         |   35 ----------
 mm/nommu.c                             |    6 +
 mm/util.c                              |  104 +++++++++++++++++++++++++++++++
 mm/vmalloc.c                           |   14 ++++
 19 files changed, 207 insertions(+), 306 deletions(-)
