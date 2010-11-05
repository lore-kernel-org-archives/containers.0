From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 00/49] Use vzalloc not vmalloc/kmemset
Date: Thu,  4 Nov 2010 20:07:24 -0700
Message-ID: <cover.1288925424.git.joe__29427.0017221153$1288926680$gmane$org@perches.com>
References: <alpine.DEB.2.00.1011031108260.11625@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.00.1011031108260.11625-sBS69tsa9Uj/9pzu0YdTqQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jiri Kosina <trivial-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-atm-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, virtualization-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, osst-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cbe-oss-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, amd64-microcode-HnHVZv34qLXYtjvyW6yDsg@public.gmane.org, reiserfs-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kvm-ppc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, xfs-VZNHf3L845pBDgjK7y7TUQ@public.gmane.org, linux-raid-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, codalist-OCorLXSLWn+MVn35/9/JlcWGCVk0P7UB@public.gmane.org, netdev@
List-Id: containers.vger.kernel.org

Converted vmalloc/memset and vmalloc_node/memset to
vzalloc or vzalloc_node using a cocci script and some editing

Reduces text a little bit.

Compiled x86 only.

There are still vmalloc_32 with memset calls still around.

Broken out to multiple patches to cc appropriate maintainers.

Joe Perches (49):
  arch/ia64: Use vzalloc
  arch/mips: Use vzalloc
  arch/powerpc: Use vzalloc
  arch/s390: Use vzalloc
  arch/x86: Use vzalloc
  crypto: Use vzalloc
  drivers/atm: Use vzalloc
  drivers/block: Use vzalloc
  drivers/char: Use vzalloc
  drivers/gpu: Use vzalloc
  drivers/hid: Use vzalloc
  drivers/infiniband: Use vzalloc
  drivers/isdn: Use vzalloc
  drivers/md: Use vzalloc
  drivers/media: Use vzalloc
  drivers/mtd: Use vzalloc
  drivers/net/cxgb3: Use vzalloc
  drivers/net/cxgb4: Use vzalloc
  drivers/net/e1000: Use vzalloc
  drivers/net/e1000e: Use vzalloc
  drivers/net/ehea: Use vzalloc
  drivers/net/igb: Use vzalloc
  drivers/net/igbvf: Use vzalloc
  drivers/net/ixgb: Use vzalloc
  drivers/net/ixgbe: Use vzalloc
  drivers/net/ixgbevf: Use vzalloc
  drivers/net/netxen: Use vzalloc
  drivers/net/pch_gbe: Use vzalloc
  drivers/net/qlcnic: Use vzalloc
  drivers/net/sfc: Use vzalloc
  drivers/net/vxge: Use vzalloc
  drivers/net/bnx2.c: Use vzalloc
  drivers/s390: Use vzalloc
  drivers/scsi: Use vzalloc
  drivers/staging: Use vzalloc
  drivers/video: Use vzalloc
  fs/ext4: Use vzalloc
  fs/jffs2: Use vzalloc
  fs/reiserfs: Use vzalloc
  fs/udf: Use vzalloc
  fs/xfs: Use vzalloc
  include/linux/coda_linux.h: Use vzalloc
  kernel: Use vzalloc
  mm: Use vzalloc
  net/core/pktgen.c: Use vzalloc
  net/netfilter: Use vzalloc
  net/rds: Use vzalloc
  sound/oss/dev_table.c: Use vzalloc
  virt/kvm/kvm_main.c: Use vzalloc

 arch/ia64/kernel/perfmon.c                      |    3 +-
 arch/mips/sibyte/common/sb_tbprof.c             |    3 +-
 arch/powerpc/kvm/book3s.c                       |    6 +--
 arch/powerpc/platforms/cell/spufs/lscsa_alloc.c |    3 +-
 arch/s390/hypfs/hypfs_diag.c                    |    3 +-
 arch/x86/kernel/microcode_amd.c                 |    3 +-
 arch/x86/kvm/x86.c                              |    3 +-
 arch/x86/mm/pageattr-test.c                     |    3 +-
 crypto/deflate.c                                |    3 +-
 crypto/zlib.c                                   |    3 +-
 drivers/atm/idt77252.c                          |   11 ++++---
 drivers/atm/lanai.c                             |    3 +-
 drivers/block/drbd/drbd_bitmap.c                |    5 +--
 drivers/char/agp/backend.c                      |    3 +-
 drivers/char/mspec.c                            |    5 +--
 drivers/gpu/drm/via/via_dmablit.c               |    4 +-
 drivers/hid/hid-core.c                          |    3 +-
 drivers/infiniband/hw/amso1100/c2_rnic.c        |    5 +--
 drivers/infiniband/hw/ehca/ipz_pt_fn.c          |    5 +--
 drivers/infiniband/hw/ipath/ipath_driver.c      |    3 +-
 drivers/infiniband/hw/ipath/ipath_file_ops.c    |   11 ++-----
 drivers/infiniband/hw/ipath/ipath_init_chip.c   |    5 +--
 drivers/infiniband/hw/qib/qib_init.c            |    7 +---
 drivers/infiniband/ulp/ipoib/ipoib_cm.c         |   10 ++----
 drivers/infiniband/ulp/ipoib/ipoib_main.c       |    3 +-
 drivers/isdn/i4l/isdn_common.c                  |    4 +-
 drivers/isdn/mISDN/dsp_core.c                   |    3 +-
 drivers/isdn/mISDN/l1oip_codec.c                |    6 +--
 drivers/md/dm-log.c                             |    3 +-
 drivers/md/dm-snap-persistent.c                 |    3 +-
 drivers/md/dm-table.c                           |    4 +--
 drivers/media/dvb/ngene/ngene-core.c            |    3 +-
 drivers/media/video/mx3_camera.c                |    3 +-
 drivers/media/video/pwc/pwc-if.c                |    3 +-
 drivers/media/video/videobuf-dma-sg.c           |    3 +-
 drivers/mtd/nand/nandsim.c                      |    3 +-
 drivers/mtd/ubi/vtbl.c                          |    6 +--
 drivers/net/bnx2.c                              |   10 +-----
 drivers/net/cxgb3/cxgb3_offload.c               |    7 ++--
 drivers/net/cxgb4/cxgb4_main.c                  |    7 ++--
 drivers/net/e1000/e1000_main.c                  |    6 +--
 drivers/net/e1000e/netdev.c                     |    6 +--
 drivers/net/ehea/ehea_main.c                    |    4 +--
 drivers/net/igb/igb_main.c                      |    6 +--
 drivers/net/igbvf/netdev.c                      |    6 +--
 drivers/net/ixgb/ixgb_main.c                    |    6 +--
 drivers/net/ixgbe/ixgbe_main.c                  |   10 ++----
 drivers/net/ixgbevf/ixgbevf_main.c              |    6 +--
 drivers/net/netxen/netxen_nic_init.c            |    7 +---
 drivers/net/pch_gbe/pch_gbe_main.c              |    6 +--
 drivers/net/qlcnic/qlcnic_init.c                |    7 +---
 drivers/net/sfc/filter.c                        |    3 +-
 drivers/net/vxge/vxge-config.c                  |   37 +++++-----------------
 drivers/s390/cio/blacklist.c                    |    3 +-
 drivers/scsi/bfa/bfad.c                         |    3 +-
 drivers/scsi/bfa/bfad_debugfs.c                 |    8 +----
 drivers/scsi/cxgbi/libcxgbi.h                   |    9 ++----
 drivers/scsi/osst.c                             |    3 +-
 drivers/scsi/qla2xxx/qla_attr.c                 |    3 +-
 drivers/scsi/qla2xxx/qla_bsg.c                  |    3 +-
 drivers/scsi/scsi_debug.c                       |    7 +---
 drivers/staging/comedi/drivers.c                |    4 +--
 drivers/staging/rtl8192e/r8192E_core.c          |    4 +--
 drivers/staging/udlfb/udlfb.c                   |    5 +--
 drivers/staging/xgifb/XGI_main_26.c             |    3 +-
 drivers/staging/zram/zram_drv.c                 |    3 +-
 drivers/video/arcfb.c                           |    5 +--
 drivers/video/broadsheetfb.c                    |    4 +--
 drivers/video/hecubafb.c                        |    5 +--
 drivers/video/metronomefb.c                     |    4 +--
 drivers/video/xen-fbfront.c                     |    3 +-
 fs/ext4/super.c                                 |    4 +--
 fs/jffs2/build.c                                |    5 +--
 fs/reiserfs/journal.c                           |    9 ++----
 fs/reiserfs/resize.c                            |    4 +--
 fs/udf/super.c                                  |    5 +--
 fs/xfs/linux-2.6/kmem.h                         |    7 +----
 include/linux/coda_linux.h                      |   26 ++++++++++------
 kernel/profile.c                                |    6 +--
 kernel/relay.c                                  |    4 +--
 mm/memcontrol.c                                 |    5 +--
 mm/page_cgroup.c                                |    3 +-
 mm/percpu.c                                     |    8 +----
 mm/swapfile.c                                   |    3 +-
 net/core/pktgen.c                               |    3 +-
 net/netfilter/x_tables.c                        |    5 +--
 net/rds/ib_cm.c                                 |    6 +--
 sound/oss/dev_table.c                           |    6 +--
 virt/kvm/kvm_main.c                             |   13 ++------
 89 files changed, 167 insertions(+), 328 deletions(-)

-- 
1.7.3.1.g432b3.dirty
