From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr annotated tag, v2.6.28-rc4, created. v2.6.28-rc4
Date: Wed, 16 Sep 2009 14:36:31 -0400
Message-ID: <200909161836.n8GIaVlH001041@gorgona.ncl.cs.columbia.edu>
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
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The annotated tag, v2.6.28-rc4 has been created
        at  b65a80a5ee7923355cbca669cead08e067fc7ada (tag)
   tagging  f7160c7573615ec82c691e294cf80d920b5d588d (commit)
  replaces  v2.6.28-rc3
 tagged by  Linus Torvalds
        on  Sun Nov 9 16:36:31 2008 -0800

- Log -----------------------------------------------------------------
Linux 2.6.28-rc4
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkkXghMACgkQF3YsRnbiHLs6rgCgnoaEp7pi1M/FQYF4KId701DP
gl0An0GVTbGzNkR4CxkeVkecJ/G4ErUr
=l/gf
-----END PGP SIGNATURE-----

Al Viro (1):
      tracing, alpha: undefined reference to `save_stack_trace'

Alan Cox (2):
      trivial: dmi_scan typo
      trivial: MPT fusion - remove long dead code

Alan Stern (2):
      Add round_jiffies_up and related routines
      Block: use round_jiffies_up()

Alex Deucher (1):
      drm/radeon: fixup further bus mastering confusion.

Alexey Dobriyan (6):
      proc: revert /proc/uptime to ->read_proc hook
      fs_enet: fix polling
      xfrm: Fix xfrm_policy_gc_lock handling.
      powerpc/ps3: Fix compile error in ps3-lpm.c
      powerpc/cell: Fix compile error in ras.c
      netfilter: netns ct: walk netns list under RTNL

Alok Kataria (1):
      x86: don't use tsc_khz to calculate lpj if notsc is passed

Anatolij Gustschin (1):
      fbdev: add new framebuffer driver for Fujitsu MB862xx GDCs

Andi Kleen (1):
      oprofile: Fix p6 counter overflow check

Andre Noll (1):
      md: linear: Fix a division by zero bug for very small arrays.

Andreas Steffen (1):
      xfrm: Have af-specific init_tempsel() initialize family field of temporary selector

Andrew Morton (1):
      MAINTAINERS: make IOAT easier to find

Andrew Victor (3):
      [WATCHDOG] SAM9 watchdog - update for moved headers
      [WATCHDOG] SAM9 watchdog - supported on all SAM9 and CAP9 processors
      SAM9 watchdog: update for moved headers

Andrey Borzenkov (1):
      cpqarry: fix return value of cpqarray_init()

Andy Whitcroft (2):
      hugetlbfs: handle pages higher order than MAX_ORDER
      hugetlb: pull gigantic page initialisation out of the default path

Aneesh Kumar K.V (3):
      ext4: fix missing ext4_unlock_group in error path
      ext4: Convert to host order before using the values.
      ext4: Mark the buffer_heads as dirty and uptodate after prepare_write

Arjan van de Ven (1):
      regression: disable timer peek-ahead for 2.6.28

Arnaud Ebalard (1):
      XFRM: copy_to_user_kmaddress() reports local address twice

Arthur Jones (1):
      ext3: wait on all pending commits in ext3_sync_fs

Bart Trojanowski (1):
      fat: document additional vfat mount options

Ben Hutchings (1):
      x86: don't allow nr_irqs > NR_IRQS

Benjamin Thery (1):
      ipv6: fix run pending DAD when interface becomes ready

Bjorn Helgaas (2):
      x86: mention ACPI in top-level Kconfig menu
      [IA64] reorder Kconfig options to match x86

Bob Copeland (1):
      ath5k: correct handling of rx status fields

Carl Love (2):
      Cell OProfile: Incorrect local array size in activate spu profiling function
      Cell OProfile: Incorrect local array size in activate spu profiling function

Christoph Lameter (1):
      mm: move migrate_prep out from under mmap_sem

Dan Williams (1):
      [ARM] xsc3: fix xsc3_l2_inv_range

Daniel Drake (1):
      zd1211rw: Add 2 device IDs

Darren Jenkins (1):
      fat: cleanup fat_parse_long() error handling

David Brownell (1):
      atmel_serial: keep clock off when it's not needed

David Howells (1):
      Fix accidental implicit cast in HR-timer conversion

David Miller (1):
      net: Fix recursive descent in __scm_destroy().

David Rientjes (2):
      oom: do not dump task state for non thread group leaders
      vmemmap: warn about page_structs with remote distance

David S. Miller (5):
      SMC91x: Fix compilation on some platforms.
      niu: Use pci_ioremap_bar().
      tcp: Fix recvmsg MSG_PEEK influence of blocking behavior.
      net: Fix recursive descent in __scm_destroy().
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6

David Woodhouse (1):
      [JFFS2] Fix lack of locking in thread_should_wake()

Doug Chapman (1):
      [IA64] fix boot panic caused by offline CPUs

Doug Nazar (1):
      Fix nfsd truncation of readdir results

Ed Swierk (1):
      PCI: fix range check on mmapped sysfs resource files

Eduardo Habkost (1):
      Revert "x86: default to reboot via ACPI"

Eilon Greenstein (4):
      bnx2x: Removing the PMF indication when unloading
      bnx2x: PCI configuration bug on big-endian
      bnx2x: Calling netif_carrier_off at the end of the probe
      bnx2x: Version Update

Elias Oltmanns (1):
      libata: Fix a potential race condition in ata_scsi_park_show()

Eric Anholt (1):
      i915: Add GEM ioctl to get available aperture size.

Eric W. Biederman (1):
      [MTD] [NOR] Fix cfi_send_gen_cmd handling of x16 devices in x8 mode (v4)

FUJITA Tomonori (2):
      [IA64] remove dead BIO_VMERGE_BOUNDARY definition
      block: remove unused ll_new_mergeable()

Frans Pop (1):
      rtc-cmos: fix boot log message

Frederic Bohe (1):
      ext4: add checksum calculation when clearing UNINIT flag in ext4_new_inode

Geert Uytterhoeven (2):
      [JFFS2] fix race condition in jffs2_lzo_compress()
      fbdev: fix fb_compat_ioctl() deadlocks

Gerald Schaefer (1):
      memory hotplug: fix page_zone() calculation in test_pages_isolated()

Greg Kroah-Hartman (2):
      Staging: only build the tree if we really want to
      Staging: make usbip depend on CONFIG_NET

Harvey Harrison (1):
      PCI: annotate return value of pci_ioremap_bar with __iomem

Henrik Rydberg (4):
      hwmon: applesmc: add support for iMac 5
      hwmon: applesmc: add support for Macbook 5
      hwmon: applesmc: add support for Macbook Pro 5
      hwmon: applesmc: add support for iMac 8

Huang Weiyi (3):
      [MTD] [NAND] OMAP2: remove duplicated #include
      [IA64] remove duplicated #include from pci-dma.c
      9p: rdma: remove duplicated #include

Hugh Dickins (1):
      x86: align DirectMap in /proc/meminfo

Ian Kent (2):
      autofs4: correct offset mount expire check
      autofs4: collect version check return

Ingo Molnar (6):
      sched: re-tune balancing
      Merge branch 'iommu-fixes-2.6.28' of git://git.kernel.org/pub/scm/linux/kernel/git/joro/linux-2.6-iommu into x86/urgent
      sched: fine-tune SD_SIBLING_INIT
      Merge branch 'oprofile-for-tip' of git://git.kernel.org/pub/scm/linux/kernel/git/rric/oprofile into x86/urgent
      sched: improve sched_clock() performance
      sched: optimize sched_clock() a bit

James Bottomley (1):
      x86, voyager: fix smp_intr_init() compile breakage

Jay Lan (1):
      [IA64] Reserve elfcorehdr memory in CONFIG_CRASH_DUMP

Jeff Kirsher (1):
      net: kconfig cleanup

Jeff Layton (1):
      cifs: fix renaming one hardlink on top of another

Jeremy Fitzhardinge (4):
      bio: define __BIOVEC_PHYS_MERGEABLE
      x86, xen: fix use of pgd_page now that it really does return a page
      vmap: cope with vm_unmap_aliases before vmalloc_init()
      xen: make sure stray alias mappings are gone before pinning

Jesper Dangaard Brouer (1):
      Change UTF8 chars in Kconfig help text about Oprofile AMD barcelona

Jianjun Kong (1):
      drivers: remove duplicated #include

Joerg Roedel (3):
      AMD IOMMU: fix detection of NP capable IOMMUs
      [IA64] use common header for software IO/TLB
      AMD IOMMU: fix lazy IO/TLB flushing in unmap path

John W. Linville (2):
      Revert "ath5k: honor FIF_BCN_PRBRESP_PROMISC in STA mode"
      iwlagn: avoid sleep in softirq context

Jonathan McDowell (2):
      Fix logic error in rfkill_check_duplicity
      kbuild: Fixup deb-pkg target to generate separate firmware deb

Kay Sievers (4):
      firewire: struct device - replace bus_id with dev_name(), dev_set_name()
      ieee1394: struct device - replace bus_id with dev_name(), dev_set_name()
      sound: struct device - replace bus_id with dev_name(), dev_set_name()
      mmc: struct device - replace bus_id with dev_name(), dev_set_name()

Keith Packard (5):
      x86: add iomap_atomic*()/iounmap_atomic() on 32-bit using fixmaps
      resources: add io-mapping functions to dynamically map large device apertures
      i915: use io-mapping interfaces instead of a variety of mapping kludges
      io mapping: improve documentation
      io mapping: clean up #ifdefs

Ken'ichi Ohmichi (1):
      [IA64] fix the difference between node_mem_map and node_start_pfn

Len Brown (1):
      build fix: CONFIG_DRM_I915=y && CONFIG_ACPI=n

Lennert Buytenhek (1):
      mv643xx_eth: fix SMI bus access timeouts

Li Zefan (4):
      cgroups: fix invalid cgrp->dentry before cgroup has been completely removed
      Documentation/kernel-parameters.txt: update 'isolcpus' kernel option
      sched: fix a bug in sched domain degenerate
      sched: fix memory leak in a failure path

Linus Torvalds (34):
      Merge branch 'drm-next' of git://git.kernel.org/pub/scm/linux/kernel/git/airlied/drm-2.6
      Merge branch 'proc-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/adobriyan/proc
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tiwai/sound-2.6
      Merge branch 'io-mappings-for-linus-2' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'tracing-fixes-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6-tip
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/sfrench/cifs-2.6
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/libata-dev
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge git://git.infradead.org/mtd-2.6
      Merge branch 'sched-fixes-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/ericvh/v9fs
      Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/git/paulus/powerpc
      Merge branch 'for-linus' of git://neil.brown.name/md
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/wim/linux-2.6-watchdog
      Merge branch 'for-linus' of git://git.kernel.dk/linux-2.6-block
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/ieee1394/linux1394-2.6
      Merge master.kernel.org:/home/rmk/linux-2.6-arm
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6-tip
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tytso/ext4
      Merge branch 'core-fixes-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'sched-fixes-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/jbarnes/pci-2.6
      Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging-2.6
      Merge branch 'oprofile-fixes-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'sched-fixes-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/drzeus/mmc
      Merge branch 'cpus4096' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for-2.6.28' of git://linux-nfs.org/~bfields/linux
      Don't ask twice about not including staging drivers
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/sam/kbuild-fixes
      Linux 2.6.28-rc4

Marcin Slusarz (1):
      sata_via: restore vt*_prepare_host error handling

Mark Brown (1):
      rtc: fix handling of missing tm_year data when reading alarms

Mark McLoughlin (1):
      x86/docs: remove noirqbalance param docs

Matthew Ranostay (1):
      ALSA: hda: make a STAC_DELL_EQ option

Mikael Pettersson (1):
      sata_promise: add ATA engine reset to reset ops

Mike Anderson (1):
      blk: move blk_delete_timer call in end_that_request_last

Mike Galbraith (1):
      sched: fine-tune SD_MC_INIT

Mike Miller (3):
      cciss: new hardware support
      cciss: fix sysfs broken symlink regression
      cciss: fix regression firmware not displayed in procfs

Miklos Szeredi (1):
      net: unix: fix inflight counting bug in garbage collector

Mohamed Abbas (2):
      iwlwifi: clear scanning bits upon failure
      iwl3945: clear scanning bits upon failure

NeilBrown (2):
      md: revert the recent addition of a call to the BLKRRPART ioctl.
      md: fix bug in raid10 recovery.

Nick Piggin (1):
      oprofile: fix memory ordering

Nicolas Pitre (1):
      clarify usage expectations for cnt32_to_63()

OGAWA Hirofumi (19):
      fat: move fs/vfat/* and fs/msdos/* to fs/fat
      fat: split include/msdos_fs.h
      fat: Fix and cleanup timestamp conversion
      fat: use generic_file_llseek() for directory
      fat: improve fat_hash()
      fat: Fix fat_ent_update_ptr() for FAT12
      fat: use fat_detach() in fat_clear_inode()
      vfat: Fix vfat_find() error path in vfat_lookup()
      fat: Fix/Cleanup dcache handling for vfat
      fat: Kill d_invalidate() in vfat_lookup()
      fat: Cleanup msdos_lookup()
      fat: Cleanup FAT attribute stuff
      fat: Fix ATTR_RO in the case of (~umask & S_WUGO) == 0
      fat: Fix ATTR_RO for directory
      fat: Fix _fat_bmap() race
      fat: Add printf attribute to fat_fs_panic()
      fat: mmu_private race fix
      fat: ->i_pos race fix
      fat: i_blocks warning fix

Patrick McHardy (1):
      net: fix packet socket delivery in rx irq handler

Peter Zijlstra (4):
      sched: cleanup fair task selection
      sched: fix fair preempt check
      sched: backward looking buddy
      sched: fix buddies for group scheduling

Pierre Ossman (1):
      mmc: increase SD write timeout for crappy cards

Qinghuang Feng (1):
      mm/oom_kill.c: fix badness() kerneldoc

Rafael J. Wysocki (1):
      Fix __pfn_to_page(pfn) for CONFIG_DISCONTIGMEM=y

Randy Dunlap (3):
      PCI: remove excess kernel-doc notation
      net/9p: fix printk format warnings
      net/9p: fix printk format warnings

Reinette Chatre (1):
      iwl3945: do not send scan command if channel count zero

Robert Richter (1):
      Revert "Cell OProfile: Incorrect local array size in activate spu profiling function"

Roel Kluin (1):
      unsigned fid->fid cannot be negative

Russ Anderson (3):
      [IA64] Simplify SGI uv vs. sn2 driver issues
      [IA64] Add UV watchlist support.
      [IA64] Add error_recovery_info field to SAL section header

Russell King (5):
      [ARM] fix VFP+softfloat binaries
      [ARM] fix naming of MODULE_START / MODULE_END
      [ARM] mm: fix page table initialization
      Merge branch 'fixes' of git://git.kernel.org/pub/scm/linux/kernel/git/djbw/xscaleiop
      Merge branch 'omap-fixes' of git://git.kernel.org/pub/scm/linux/kernel/git/tmlind/linux-omap-2.6

Rusty Russell (3):
      cpumask: introduce new API, without changing anything
      cpumask: new API, v2
      cpumask: introduce new API, without changing anything, v3

Sami Liedes (1):
      jbd2: deregister proc on failure in jbd2_journal_init_inode

Sanjeev Premi (1):
      ARM: OMAP: Fix compiler warnings in gpmc.c

Stefan Richter (2):
      ieee1394: raw1394: fix possible deadlock in multithreaded clients
      ieee1394: dv1394: fix possible deadlock in multithreaded clients

Stephen Rothwell (1):
      powerpc: Fix "unused variable" warning in pci_dlpar.c

Steve French (2):
      [CIFS] Reduce number of socket retries in large write path
      [CIFS] fix error in smb_send2

Steve Glendinning (1):
      [JFFS2] Fix build failure with !CONFIG_JFFS2_FS_WRITEBUFFER

Steven Rostedt (2):
      ftrace: use kretprobe trampoline name to test in output
      tracing, ring-buffer: add paranoid checks for loops

Suresh Siddha (2):
      generic-ipi: fix the smp_mb() placement
      x86: add smp_mb() before sending INVALIDATE_TLB_VECTOR

Takashi Iwai (8):
      ALSA: hda - Disable broken mic auto-muting in Realtek codes
      ALSA: hda - Add digital-mic for ALC269 auto-probe mode
      ALSA: rawmidi - Add open check in rawmidi callbacks
      ALSA: remove direct access of dev->bus_id in sound/isa/*
      ALSA: hda - Add a quirk for another Acer Aspire (1025:0090)
      ALSA: emu10k1 - Add more invert_shared_spdif flag to Audigy models
      Merge branches 'topic/fix/misc' and 'topic/fix/hda' into for-linus
      regulator: Use menuconfig in Kconfig

Tejun Heo (5):
      sata_nv: fix generic, nf2/3 detection regression
      libata: implement ATA_HORKAGE_ATAPI_MOD16_DMA and apply it
      libata: mask off DET when restoring SControl for detach
      block: add timer on blkdev_dequeue_request() not elv_next_request()
      block: fix __blkdev_get() for removable devices

Theodore Ts'o (4):
      jbd: don't give up looking for space so easily in __log_wait_for_space
      jbd2: don't give up looking for space so easily in __jbd2_log_wait_for_space
      ext4: wait on all pending commits in ext4_sync_fs()
      ext4: calculate journal credits correctly

Tim Hockin (1):
      Documentation/email-clients.txt: add some info about gmail

Tom Tucker (4):
      9p: rdma: Set trans prior to requesting async connection ops
      9p: Make all client spin locks IRQ safe
      9p: Remove unneeded free of fcall for Flush
      p9: Fix leak of waitqueue in request allocation path

Tony Lindgren (2):
      ARM: OMAP: Fix get_irqnr_and_base to clear spurious interrupt bits
      ARM: OMAP: Fix define for twl4030 irqs

Tony Luck (1):
      [IA64] Build VT-D iommu support into generic kernel

Wei Yongjun (2):
      udp: Fix the SNMP counter of UDP_MIB_INDATAGRAMS
      udp: Fix the SNMP counter of UDP_MIB_INERRORS

Will Newton (1):
      drivers/net/smc911x.c: Fix lockdep warning on xmit.

Wolfgang Kroworsch (1):
      vt: incomplete initialization of vc_tab_stop

Yinghai Lu (2):
      x86: size NR_IRQS on 32-bit systems the same way as 64-bit
      x86: remove VISWS and PARAVIRT around NR_IRQS puzzle

Yu Zhao (1):
      PCI: fix VPD limit quirk for Broadcom 5708S

Zhaolei (1):
      ARM: OMAP: Fix debugfs_create_*'s error checking method for arm/plat-omap

Zhu, Yi (1):
      iwl3945: fix deadlock on suspend

Zoltan Devai (1):
      ALSA: Fix PIT lockup on some chipsets when using the PC-Speaker

dann frazier (1):
      cciss: add P700m to list of supported controllers

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr
