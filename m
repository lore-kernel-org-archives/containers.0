From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr annotated tag, v2.6.27-rc7, created. v2.6.27-rc7
Date: Wed, 16 Sep 2009 14:36:26 -0400
Message-ID: <200909161836.n8GIaQpQ000901@gorgona.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1220706709656179452=="
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
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

--===============1220706709656179452==
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by smtp1.linux-foundation.org id n8GIjeFe004126

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The annotated tag, v2.6.27-rc7 has been created
        at  cb1d73008533d7c4a949fc0867de2612dab23572 (tag)
   tagging  72d31053f62c4bc464c2783974926969614a8649 (commit)
  replaces  v2.6.27-rc6
 tagged by  Linus Torvalds
        on  Sun Sep 21 15:30:04 2008 -0700

- Log -----------------------------------------------------------------
Linux 2.6.27-rc7
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkjWyvAACgkQF3YsRnbiHLvx4wCgoZIzs1XiZLhiJNHmSmtZxbYd
GXcAoI5tp6cYOra/4AKeNFmvujqQeAbl
=3DIT1M
-----END PGP SIGNATURE-----

Adrian Bunk (2):
      PCI: fix pciehp_free_irq()
      hwmon: (ad7414) Make ad7414_update_device() static

Akinobu Mita (2):
      mmc_block: handle error from mmc_register_driver()
      mmc_test: initialize mmc_test_lock statically

Alex Chiang (1):
      PCI Hotplug: fakephp: fix deadlock... again

Alex Dubov (1):
      memstick: fix MSProHG 8-bit interface mode support

Alex Nixon (1):
      x86/paravirt: Remove duplicate paravirt_pagetable_setup_{start, don=
e}()

Alexey Dobriyan (1):
      proc: more debugging for "already registered" case

Andrew Morton (1):
      rescan_partitions(): make device capacity errors non-fatal

Andrew Paprocki (1):
      hwmon: (it87) Fix fan tachometer reading in IT8712F rev 0x7 (I)

Arjan van de Ven (1):
      warn: Turn the netdev timeout WARN_ON() into a WARN()

Atsushi Nemoto (3):
      [MIPS] Fix 64-bit IP checksum code
      [MIPS] Fix potential latency problem due to non-atomic cpu_wait.
      [MIPS] vmlinux.lds.S: handle .text.*

Ben Dooks (1):
      spi_s3c24xx: fix section warning

Benjamin Li (1):
      bnx2: Promote vector field in bnx2_irq structure from u16 to unsign=
ed int

Bob Stewart (1):
      sata_inic162x: enable LED blinking

Christof Schmitt (3):
      [SCSI] zfcp: Fix request queue locking
      [SCSI] zfcp: Correctly query end flag in gpn_ft response
      [SCSI] zfcp: Simplify ccw notify handler

Christoph Hellwig (2):
      udf: add llseek method
      [XFS] Fix regression introduced by remount fixup

Christopher Li (1):
      e1000: prevent corruption of EEPROM/NVM

Cornelia Huck (1):
      [S390] cio: Fix driver_data handling for ccwgroup devices.

Daniel J Blueman (1):
      swiotlb: fix back-off path when memory allocation fails

Darius Augulis (1):
      i.MX serial: fix init failure

David Brownell (1):
      Documentation/ABI: /sys/class/gpio

David Chinner (2):
      [XFS] Fix barrier status change detection.
      [XFS] Prevent lockdep false positives when locking two inodes.

David Howells (1):
      MN10300: Change the fault handler to check in_atomic() not in_inter=
rupt()

David Miller (1):
      Fix PNP build failure, bugzilla #11276

David S. Miller (7):
      sparc64: Fix interrupt register calculations on Psycho and Sabre.
      sparc32: Fix function signature of of_bus_sbus_get_flags().
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/holtmann/bluetooth-2.6
      sparc64: Fix PCI error interrupt registry on PSYCHO.
      sparc: Fix user_regset 'n' field values.
      sparc64: Fix OOPS in psycho_pcierr_intr_other().
      sparc64: Fix SMP bootup with CONFIG_STACK_DEBUG or ftrace.

David Woodhouse (1):
      PCI/iommu: blacklist DMAR on Intel G31/G33 chipsets

Dmitry Baryshkov (3):
      [ARM] 5246/1: tosa: add proper clock alias for tc6393xb clock
      [ARM] 5247/1: tosa: SW_EAR_IN support
      tmio_mmc: fix compilation with debug enabled

Dominik Brodowski (1):
      clocksource, acpi_pm.c: fix check for monotonicity

Eric Sesterhenn (1):
      bfs: fix Lockdep warning

FUJITA Tomonori (2):
      add deprecated ide-scsi to feature-removal-schedule.txt
      sg: disable interrupts inside sg_copy_buffer

Faisal Latif (1):
      RDMA/nes: Fix client side QP destroy

Geert Uytterhoeven (2):
      VIDEO_SH_MOBILE_CEU should depend on HAS_DMA
      m68k: Update defconfigs for 2.6.27-rc6

H. Peter Anvin (1):
      x86: completely disable NOPL on 32 bits

Haavard Skinnemoen (6):
      atmel_lcdfb: disable LCD and DMA engines when suspending
      atstk1000: fix build breakage with BOARD_ATSTK100X_SW2_CUSTOM=3Dy
      atmel-mci: debugfs: enable clock before dumping regs
      atmel-mci: Fix memory leak in atmci_regs_show
      atmel-mci: Fix bogus debugfs file size
      atmel-mci: Set MMC_CAP_NEEDS_POLL if no detect_pin

Hans-Christian Egtvedt (2):
      avr32: add generic_find_next_le_bit bit function
      avr32: fix sys_sync_file_range() call convention

Herbert Xu (1):
      udp: Fix rcv socket locking

Hidehiro Kawai (1):
      coredump_filter: add description of bit 4

Hirofumi Nakagawa (1):
      [SCSI] zfcp: Remove duplicated unlikely() macros.

Hiroshi DOYU (1):
      include/linux/ioport.h: add missing macro argument for devm_release=
_* family

Hiroshi Shimamoto (1):
      sched: fix deadlock in setting scheduler parameter to zero

Hugh Dickins (1):
      mm: ifdef Quicklists in /proc/meminfo

Ingo Molnar (1):
      Merge commit 'v2.6.27-rc6' into timers/urgent

James Bottomley (3):
      [SCSI] fix check of PQ and PDT bits for WLUNs
      [IA64] fix compile failure with non modular builds
      Fix compile failure with non modular builds

Jan Kara (2):
      udf: Fix lock inversion between iprune_mutex and alloc_mutex (v2)
      udf: Fix error paths in udf_new_inode()

Jean Delvare (3):
      hwmon: (atxp1) Fix device detection logic
      MAINTAINERS: Trivial whitespace cleanups
      MAINTAINERS: Various fixes

Jens Axboe (1):
      block: disable sysfs parts of the disk command filter

Jeremy Fitzhardinge (2):
      x86: fix possible x86_64 and EFI regression
      xen: fix for xen guest with mem > 3.7G

Jes Sorensen (1):
      KVM: ia64: 'struct fdesc' build fix

Joerg Roedel (2):
      KVM: SVM: fix random segfaults with NPT enabled
      KVM: SVM: fix guest global tlb flushes with NPT

Johann Felix Soden (2):
      PCI: Fix printk warnings in probe.c
      PCI: Fix printk warnings in setup-bus.c

Josh Boyer (1):
      powerpc: Holly board needs dtbImage target

Jouni Malinen (1):
      ath9k: Assign seq# when mac80211 requests this

Julia Lawall (2):
      arch/x86/kernel/kdebugfs.c: introduce missing kfree
      [IA64] arch/ia64/sn/pci/tioca_provider.c: introduce missing kfree

J=C3=BCrgen Schindele (1):
      [ARM] 5245/1: Fix warning about unused return value in drivers/pcmc=
ia

Kim Phillips (1):
      crypto: talitos - Avoid consecutive packets going out with same IV

Kristoffer Ericson (1):
      [ARM] 5255/1: Update jornada ssp to remove build errors/warnings

Lachlan McIlroy (4):
      [XFS] Move memory allocations for log tracing out of the critical p=
ath
      [XFS] Prevent direct I/O from mapping extents beyond eof
      [XFS] Fix use-after-free with buffers
      [XFS] Don't do I/O beyond eof when unreserving space

Li Zefan (2):
      cpuset: avoid changing cpuset's cpus when -errno returned
      cpuset: hotplug documentation fix

Linus Torvalds (33):
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/bart/ide-2.6
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jack/linux-udf-2.6
      Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel=
/git/aegl/linux-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/jejb/scsi-rc-fi=
xes-2.6
      Merge branch 'kvm-updates/2.6.27' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/avi/kvm
      Merge branch 'for-linus' of git://git.kernel.dk/linux-2.6-block
      Merge branch 'for-linus' of git://git.kernel.dk/linux-2.6-block
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jbarnes/pci-2.6
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/jgarzik/libata-dev
      Merge master.kernel.org:/home/rmk/linux-2.6-arm
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/herbert/crypto-=
2.6
      Revert "b43/b43legacy: add RFKILL_STATE_HARD_BLOCKED support"
      Merge branch 'upstream' of git://ftp.linux-mips.org/pub/scm/upstrea=
m-linus
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/penberg/slab-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-2.6
      Merge branch 'for-linus' of git://neil.brown.name/md
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/hskinnemoen/avr32-2.6
      Merge master.kernel.org:/home/rmk/linux-2.6-arm
      Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/paulus/powerpc
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'timers-fixes-for-linus' of git://git.kernel.org/pub/s=
cm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'sched-fixes-for-linus' of git://git.kernel.org/pub/sc=
m/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/roland/infiniband
      Merge git://oss.sgi.com:8090/xfs/linux-2.6
      Merge branch 'for-linus' of git://git390.osdl.marist.edu/pub/scm/li=
nux-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/drzeus/mmc
      Merge branch 'upstream' of git://ftp.linux-mips.org/pub/scm/upstrea=
m-linus
      Merge branch 'kvm-updates/2.6.27' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/avi/kvm
      Merge branch 'hwmon-for-linus' of git://jdelvare.pck.nerim.net/jdel=
vare-2.6
      Linux 2.6.27-rc7

Manfred Spraul (1):
      avr32: nmi_enter() without nmi_exit()

Marc Kleine-Budde (2):
      imx serial: set RXD mux bit on i.MX27 and i.MX31
      imx serial: fix rts handling for non imx1 based hardware

Marcel Holtmann (1):
      [Bluetooth] Fix regression from using default link policy

Markus Heidelberg (1):
      avr32: add .gitignore files

Masoud Sharbiani (1):
      ide: Fix pointer arithmetic in hpt3xx driver code (3rd try)

Mel Gorman (1):
      mm: mark the correct zone as full when scanning zonelists

Mike Anderson (2):
      [SCSI] scsi_dh: make check_sense return ADD_TO_MLQUEUE
      [SCSI] make scsi_check_sense HARDWARE_ERROR return ADD_TO_MLQUEUE o=
n retry

Ming Lei (1):
      MAINTAINERS: fix USB VIDEO CLASS mail list address

Ned Forrester (2):
      pxa2xx_spi: chipselect bugfixes
      pxa2xx_spi: dma bugfixes

NeilBrown (1):
      md: Don't wait UNINTERRUPTIBLE for other resync to finish

Paul E. McKenney (1):
      [IA64] prevent ia64 from invoking irq handlers on offline CPUs

Peter Korsgaard (2):
      spi_mpc83xx: fix clockrate calculation for low speed
      spi_mpc83xx: reject invalid transfer sizes

Rafael J. Wysocki (1):
      e100: Use pci_pme_active to clear PME_Status and disable PME#

Ralf Baechle (1):
      [MIPS] SMTC: Clear TIF_FPUBOUND on clone / fork.

Robin Holt (2):
      [IA64] fix up bte.h
      ia64: fix panic during `modprobe -r xpc'

Roland Dreier (1):
      Merge branches 'ipoib', 'mlx4' and 'nes' into for-linus

Russell King (4):
      [ARM] OMAP: Fix MMC device data
      Merge branch 'for-rmk' of git://pasiphae.extern.pengutronix.de/git/=
imx/linux-2.6.git
      [ARM] Fix PCI_DMA_BUS_IS_PHYS for ARM
      [ARM] omap: back out 'internal_clock' support

Salman Qazi (1):
      slub: fixed uninitialized counter in struct kmem_cache_node

Santwona Behera (1):
      niu: panic on reset

Sascha Hauer (1):
      pcm037: add rts/cts support for serial port

Sheng Yang (1):
      KVM: VMX: Always return old for clear_flush_young() when using EPT

Stefan Richter (1):
      [SCSI] sd: select CRC_T10DIF only when necessary

Stefan Weinhuber (1):
      [S390] cio: fix orb initialization in cio_start_key

Stephen Hemminger (2):
      ata: duplicate variable sparse warning
      hpplus: fix build regression

Swen Schillig (2):
      [SCSI] zfcp: Fix reference counter for remote ports
      [SCSI] zfcp: channel cannot be detached due to refcount imbalance

Taisuke Yamada (1):
      [libata] LBA28/LBA48 off-by-one bug in ata.h

Tao Ma (1):
      ocfs2: Fix a bug in direct IO read.

Thomas Gleixner (2):
      clockevents: remove WARN_ON which was used to gather information
      clockevents: make device shutdown robust

Timur Tabi (1):
      powerpc: Fix interrupt values for DMA2 in MPC8610 HPCD device tree

Uwe Kleine-K=C3=B6nig (1):
      Add Uwe Kleine-K=C3=B6nig to .mailmap

Vegard Nossum (1):
      netlink: fix overrun in attribute iteration

Vlad Yasevich (3):
      sctp: set the skb->ip_summed correctly when sending over loopback.
      sctp: do not enable peer features if we can't do them.
      sctp: Fix oops when INIT-ACK indicates that peer doesn't support AU=
TH

Vladimir Sokolovsky (2):
      mlx4_core: Set RAE and init mtt_sz field in FRMR MPT entries
      IB/mlx4: Fix up fast register page list format

Yinghai Lu (2):
      PCI: re-add debug prints for unmodified BARs
      forcedeth: call restore mac addr in nv_shutdown path

Yossi Etigin (1):
      IPoIB: Fix deadlock on RTNL between bcast join comp and ipoib_stop(=
)

Zhang, Yanmin (1):
      sched: fix 2.6.27-rc5 couldn't boot on tulsa machine randomly

roel kluin (1):
      [MIPS] VR41xx: unsigned irq cannot be negative

roelkluin (1):
      [ARM] 5249/1: davinci: remove redundant check in davinci_psc_config=
()

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr

--===============1220706709656179452==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============1220706709656179452==--
