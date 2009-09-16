From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr annotated tag, v2.6.31-rc2, created. v2.6.31-rc2
Date: Wed, 16 Sep 2009 14:36:56 -0400
Message-ID: <200909161836.n8GIauWk001595@gorgona.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1953819156677962967=="
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

--===============1953819156677962967==
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by smtp1.linux-foundation.org id n8GJSm8E009127

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The annotated tag, v2.6.31-rc2 has been created
        at  c5d511255186f0bba081f11cbe11c856cadaedf7 (tag)
   tagging  8e4a718ff38d8539938ec3421935904c27e00c39 (commit)
  replaces  v2.6.31-rc1
 tagged by  Linus Torvalds
        on  Sat Jul 4 10:59:57 2009 -0700

- Log -----------------------------------------------------------------
Linux 2.6.31-rc2
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkpPmKIACgkQF3YsRnbiHLvszgCcCexk9CUU4/b+jSc9N3OpEgk2
IEcAn2BjgAbk4CeY5FKHT6q5qtQn8ved
=3DgQFm
-----END PGP SIGNATURE-----

Aaro Koskinen (1):
      [ARM] 5560/1: Avoid buffer overrun in case of an invalid IRQ

Abhijeet Joglekar (1):
      [SCSI] fnic: use DMA_BIT_MASK(nn) instead of deprecated DMA_nnBIT_M=
ASK

Adrian Hunter (2):
      OMAP2/3: gpmc-onenand: correct use of async timings
      OMAP3: RX51: Use OneNAND sync read / write

Adrian Reber (1):
      powerpc/rtas: Fix watchdog driver temperature read functionality

Ajit Khaparde (1):
      be2net: Fix to avoid a crash seen on PPC with LRO and Jumbo frames.

Alan Cox (2):
      tty: Fix the leak in tty_ldisc_release
      [IA64] sprintf should not be used with same source & destination ad=
dress

Alexander Beregalov (5):
      parisc: stifb: should depend on STI_CONSOLE
      parisc: ccio-dma: fix build failure without procfs
      parisc: remove CVS keywords
      parisc: decode_exc.c should include kernel.h
      parisc: superio: fix build breakage

Alexander Duyck (1):
      igb: return PCI_ERS_RESULT_DISCONNECT on permanent error

Amerigo Wang (3):
      gitignore: ignore gcov output files
      kbuild: finally remove the obsolete variable $TOPDIR
      elf: fix one check-after-use

Amit Shah (1):
      KVM: Ignore reads to K7 EVNTSEL MSRs

Andre Detsch (1):
      e1000: return PCI_ERS_RESULT_DISCONNECT on permanent error

Andre Noll (1):
      Trivial typo fixes in Documentation/block/data-integrity.txt.

Andreas Herrmann (1):
      x86: Set cpu_llc_id on AMD CPUs

Andrew de Quincey (1):
      OMAP1: Fix N770 MMC support

Anton Vorontsov (2):
      powerpc/85xx: Make eSDHC 1-bit only transfer mode default for MPC85=
69E-MDS
      sky2: Fix checksum endianness

Antonio Ospite (2):
      leds: pca9532 - Indent using tabs, not spaces.
      leds: LED driver for National Semiconductor LP3944 Funlight Chip

Arnaldo Carvalho de Melo (4):
      perf_counter tools: Adjust only prelinked symbol's addresses
      perf report: Add --dsos parameter
      perf report: Add --comms parameter
      perf report: Add --symbols parameter

Arun R Bharadwaj (1):
      timers: Fix timer_migration interface which accepts any number as i=
nput

Avi Kivity (2):
      KVM: MMU: Allow 4K ptes with bit 7 (PAT) set
      KVM: VMX: Handle vmx instruction vmexits

Aviv Laufer (1):
      backlight: Fix tdo24m crash on kmalloc

Bartlomiej Zolnierkiewicz (7):
      ide: fix handling of unexpected IRQs vs request_irq()
      ide: relax DMA info validity checking
      ide: add QUANTUM FIREBALLct20 30 with firmware APL.090 to ivb_list[=
]
      ide: improve handling of Power Management requests
      ide: fix ide_kill_rq() for special ide-{floppy,tape} driver request=
s
      ide: always kill the whole request on error
      ide: fix resume for CONFIG_BLK_DEV_IDEACPI=3Dy

Baruch Siach (2):
      gpio: pl061: fix probe error handling code
      gpio: pl061: fix IRQ handling for GPIOs >=3D PL061_GPIO_NR

Bastian Blank (1):
      parisc: Remove casts from atomic macros

Ben Dooks (10):
      MAINTAINERS: Update file list for ARM/S3C2410 and ARM/S3C2440
      MAINTAINERS: Add ARM S3C2442, S3C2443, S3C6400, S3C6410 and ARM/SAM=
SUNG
      [ARM] S3C24XX: Fix use of CONFIG_S3C24XX_PWM
      [ARM] S3C: Remove unused CONFIG_DEBUG_S3C_PORT
      [ARM] S3C24XX: Fix spi-bus configuration build errors
      [ARM] S3C24XX: Fix missing s3c_iis_device.
      [ARM] S3C: Fix S3C24XX build to not include s3c64xx IIS devices
      [ARM] s3c2410_defconfig: add MINI2440 machine to build
      [ARM] MINI2440: Add missing flash_bbt flat to NAND
      [ARM] S3C maintainer updates merge branch maintainers-updates into =
s3c-fixes

Benjamin Herrenschmidt (13):
      powerpc/mpic: Fix mapping of "DCR" based MPIC variants
      powerpc/pmac: Fix issues with PowerMac "PowerSurge" SMP
      powerpc/mm: Make k(un)map_atomic out of line
      powerpc/pmac: Fix DMA ops for MacIO devices
      powerpc: Map more memory early on 601 processors
      powerpc: Add irqtrace support for 32-bit powerpc
      powerpc/rtas: Turn rtas lock into a raw spinlock
      powerpc: Use one common impl. of RTAS timebase sync and use raw spi=
nlock
      powerpc/pasemi: Use raw spinlock in SMP TB sync
      powerpc/of: Fix usage of dev_set_name() in of_device_alloc()
      powerpc/440: Fix warning early debug code
      powerpc/mm: Fix potential access to freed pages when using hugetlbf=
s
      Merge commit 'kumar/next' into merge

Borislav Petkov (4):
      amd64_edac: check only ECC bit in amd64_determine_edac_cap
      amd64_edac: fix ecc_enable_override handling
      amd64_edac: misc small cleanups
      ide-cd: handle fragmented packet commands gracefully

Brandon Philips (1):
      atl1*: add device_set_wakeup_enable to atl1*_set_wol

Brian King (1):
      [SCSI] ibmvscsi: Fix module load hang

Bryan Donlan (1):
      ext2: return -EIO not -ESTALE on directory traversal through delete=
d inode

Catalin Marinas (8):
      kmemleak: Allow the early log buffer to be configurable.
      kmemleak: Enable task stacks scanning by default
      kmemleak: Simplify the reports logged by the scanning thread
      kmemleak: Do not trigger a scan when reading the debug/kmemleak fil=
e
      kmemleak: Slightly change the policy on newly allocated objects
      kmemleak: Do not report new leaked objects if the scanning was stop=
ped
      kmemleak: Do not warn if an unknown object is freed
      kmemleak: Inform kmemleak about pid_hash

Chris Mason (3):
      Btrfs: don't log the inode in file_write while growing the file
      Btrfs: fix the file clone ioctl for preallocated extents
      Btrfs: honor nodatacow/sum mount options for new files

Chris Wright (1):
      intel-iommu: fix Identity Mapping to be arch independent

Christian Borntraeger (1):
      KVM: s390: Allow stfle instruction in the guest

Christian Engelmayer (1):
      ide: memory overrun in ide_get_identity_ioctl() on big endian machi=
nes using ioctl HDIO_OBSOLETE_IDENTITY

Christof Schmitt (1):
      [SCSI] FC transport: Locking fix for common-code FC pass-through pa=
tch

Christoph Hellwig (1):
      parisc: remove dead code from sys_parisc32.c

Clemens Ladisch (2):
      sound: oxygen: make mic volume control mono
      sound: virtuoso: fix Xonar D1/DX silence after resume

Cliff Wickman (1):
      x86: Fix uv bau sending buffer initialization

Coly Li (1):
      parisc: add parameter to read_cr16()

Corentin Chary (6):
      eeepc-laptop: Register as a pci-hotplug device
      eeepc-laptop: rfkill refactoring
      eeepc-laptop: right parent device
      eeepc-laptop: makes get_acpi() returns -ENODEV
      eeepc-laptop: get the right value for CMSG
      eeepc-laptop: add rfkill support for the 3G modem in Eee PC 901 Go

Csaba Henk (1):
      fuse: fix return value of fuse_dev_write()

Daniel Mack (1):
      ALSA: snd_usb_caiaq: reparent sound device

Daniel Ribeiro (1):
      mfd: fix pcap adc locking

Dave Airlie (1):
      Merge remote branch 'origin/drm-intel-next' of ../drm-intel into dr=
m-fixes

David Brownell (3):
      spi: new spi->mode bits
      spi: add spi_master flag word
      spi: bitbang bugfix in message setup

David Daney (3):
      MIPS: Hookup new syscalls sys_rt_tgsigqueueinfo and sys_perf_counte=
r_open.
      MIPS: Define __arch_swab64 for all mips r2 cpus
      MIPS: Reorganize Cavium OCTEON PCI support.

David Howells (5):
      FRV: Wire up new syscalls
      MN10300: Wire up new syscalls
      FRV: Implement atomic64_t
      FRV: Add basic performance counter support
      NFSD: Don't hold unrefcounted creds over call to nfsd_setuser()

David S. Miller (6):
      ide-cd: Don't warn on bogus block size unless it actually matters.
      ide cs5520: Initialize second port's interrupt number.
      Revert "veth: prevent oops caused by netdev destructor"
      sparc64: Don't use alloc_bootmem() in init_IRQ() code paths.
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/kaber/nf-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/lowpan/lowpan

David Woodhouse (41):
      jffs2: fix another potential leak on error path in scan.c
      mtd: maps: Remove BUS_ID_SIZE from integrator_flash
      intel-iommu: Create new iommu_domain_identity_map() function
      intel-iommu: Clean up identity mapping code, remove CONFIG_DMAR_GFX=
_WA
      intel-iommu: Change dma_set_pte_addr() to dma_set_pte_pfn()
      intel-iommu: Change address_level_offset() to pfn_level_offset()
      intel-iommu: Change dma_addr_level_pte() to dma_pfn_level_pte()
      intel-iommu: Make dma_pte_clear_one() take pfn not address
      intel-iommu: Don't just mask out too-big physical addresses; BUG() =
instead
      intel-iommu: Make dma_pte_clear_range() use pfns
      intel-iommu: Make dma_pte_clear_range() take pfns as argument
      intel-iommu: Make dma_pte_free_pagetable() use pfns
      intel-iommu: Make dma_pte_free_pagetable() take pfns as argument
      intel-iommu: Clean up intel_iommu_unmap_range()
      intel-iommu: Change addr_to_dma_pte() to pfn_to_dma_pte()
      intel-iommu: Clean up address handling in domain_page_mapping()
      intel-iommu: Introduce domain_pfn_mapping()
      intel-iommu: Use domain_pfn_mapping() in __intel_map_single()
      intel-iommu: Use domain_pfn_mapping() in intel_iommu_map_range()
      intel-iommu: Clean up intel_map_sg(), remove domain_page_mapping()
      intel-iommu: Change aligned_size() to aligned_nrpages()
      intel-iommu: Make iommu_flush_iotlb_psi() take pfn as argument
      intel-iommu: Remove last use of PHYSICAL_PAGE_MASK, for reserving P=
CI BARs
      intel-iommu: Clean up iommu_domain_identity_map()
      intel-iommu: Performance improvement for dma_pte_clear_range()
      intel-iommu: Performance improvement for domain_pfn_mapping()
      intel-iommu: Simplify __intel_alloc_iova()
      intel-iommu: Introduce domain_sg_mapping() to speed up intel_map_sg=
()
      intel-iommu: Combine domain_pfn_mapping() and domain_sg_mapping()
      intel-iommu: dump mappings but don't die on pte already set
      intel-iommu: Don't free too much in dma_pte_free_pagetable()
      intel-iommu: Performance improvement for dma_pte_free_pagetable()
      intel-iommu: Make iommu=3Dpt work on i386 too
      Fix pci_unmap_addr() et al on i386.
      Fix iommu address space allocation
      intel-iommu: Ensure that PTE writes are 64-bit atomic, even on i386
      intel-iommu: Kill superfluous mapping_lock
      intel-iommu: Warn about unmatched unmap requests
      intel-iommu: Use cmpxchg64_local() for setting PTEs
      intel-iommu: Introduce first_pte_in_page() to simplify PTE-setting =
loops
      intel-iommu: Don't keep freeing page zero in dma_pte_free_pagetable=
()

Davide Libenzi (1):
      eventfd: revised interface and cleanups

Dmitri Vorobiev (1):
      MIPS: Malta: Remove unnecessary function prototypes

Dmitry Eremin-Solenikov (3):
      MAINTAINERS: ieee802154 lists are moderated for non-subscribers.
      nl802154: fix Oops in ieee802154_nl_get_dev
      nl802154: add module license and description

Don Skidmore (1):
      ixgbe: Fix SFP log messages

Emilio L=C3=B3pez (1):
      ALSA: hda - Fix acer-aspire-6530g model quirk

Eric Anholt (2):
      drm/i915: Add missing dependency on Intel AGP support.
      Merge commit 'keithp/drm-intel-next' into drm-intel-next

Eric W. Biederman (1):
      Revert "ipv4: arp announce, arp_proxy and windows ip conflict verif=
ication"

Fernando Guzman Lugo (1):
      OMAP: IOMMU: function flush_iotlb_page is not flushing correct entr=
y

Florian Fainelli (2):
      cpmac: fix compilation failure introduced with netdev_ops conversio=
n
      MIPS: Add support for Texas Instruments AR7 System-on-a-Chip

Floris Kraak (1):
      Kbuild: Disable the -Wformat-security gcc flag

Frans Pop (1):
      ide-cd: Improve "weird block size" error message

Frederic Weisbecker (3):
      perf record: Fix unhandled io return value
      perf_counter tools: Prepare a small callchain framework
      perf report: Print sorted callchains per histogram entries

Gerhard Pircher (1):
      powerpc/amigaone: Limit ISA I/O range to 4k in the device tree

Graf Yang (1):
      net/irda: convert bfin_sir to net_device_ops

Grant Grundler (3):
      parisc: advertise PCI devs after "assign_resources"
      parisc: Fix gcc 4.4 warning in lba_pci.c
      parisc: fix "delay!" timer handling

Grant Likely (2):
      ASoC: Fix typo in MPC5200 PSC AC97 driver Kconfig
      ASoC: remove BROKEN from Efika and pcm030 fabric drivers

Grazvydas Ignotas (1):
      OMAP2/3: mmc-twl4030: use correct controller in twl_mmc23_set_power

Gr=C3=A9goire Henry (1):
      drm/i915: initialize fence registers to zero when loading GEM

H. Peter Anvin (2):
      x86, setup: correct include file in <asm/boot.h>
      Revert "x86: cap iomem_resource to addressable physical memory"

Hannes Reinecke (1):
      cciss: Ignore stale commands after reboot

Heiko Carstens (2):
      timer stats: Optimize by adding quick check to avoid function calls
      gcov: fix __ctors_start alignment

Helge Deller (3):
      parisc: fix ldcw inline assembler
      parisc: fix irq compile bugs in arch/parisc/kernel/irq.c
      parisc: ensure broadcast tlb purge runs single threaded

Herbert Xu (12):
      ipsec: Fix name of CAST algorithm
      inet: Call skb_orphan before tproxy activates
      gro: Flush GRO packets in napi_disable_pending path
      tcp: Stop non-TSO packets morphing into TSO
      tcp: Do not tack on TSO data to non-TSO packet
      cdc_eem: Use netdev stats structure
      dm9601: Use netdev stats structure
      net1080: Use netdev stats structure
      rndis_host: Use netdev stats structure
      smsc95xx: Use netdev stats structure
      usbnet: Use netdev stats structure
      usbnet: Remove private stats structure

Hidetoshi Seto (2):
      x86, mce: Fix mce resume on 32bit
      x86, mce: percpu mcheck_timer should be pinned

Hu Tao (1):
      Btrfs: fix error message formatting

Huang Weiyi (4):
      OMAP1: remove duplicated #include
      powerpc/85xx: remove duplicated #include
      [ARM] MINI2440: remove duplicated #include
      drm: remove unused #include <linux/version.h>'s

Ingo Molnar (11):
      perf_counter tools: Fix vmlinux fallback when running on a differen=
t kernel
      Merge branch 'for-tip' of git://git.kernel.org/pub/scm/linux/kernel=
/git/tj/percpu into x86/urgent
      perf report: Fix help text typo
      perf_counter tools: Add CREDITS file for Git contributors
      i2c: fix build bug in i2c-designware.c
      perf_counter tools: Remove dead code
      perf stat: Add -n/--null option to run without counters
      perf stat: Fix multi-run stats
      eeepc-laptop: Fix build failure with HOTPLUG_PCI && !SYSFS
      perf stat: Use percentages for scaling output
      kmemleak: Fix scheduling-while-atomic bug

Ionut Nicu (1):
      fsl_pq_mdio: Fix fsl_pq_mdio to work with modules

Izik Eidus (1):
      KVM: Fix dirty bit tracking for slots with large pages

James Bottomley (1):
      [SCSI] zalon: fix oops on attach failure

Jan Beulich (1):
      [IA64] address compiler warnings perfmon.c/salinfo.c

Jan Engelhardt (1):
      netfilter: xtables: conntrack match revision 2

Janusz Krzysztofik (1):
      ASoC: OMAP: fix OMAP1510 broken PCM pointer callback

Jarek Poplawski (1):
      ipv4: Fix fib_trie rebalancing, part 3

Jaswinder Singh Rajput (16):
      perf_counter, x8: Fix L1-data-Cache-Store-Referencees for AMD
      perf_counter tools: Define separate declarations for H/W and S/W ev=
ents
      perf_counter tools: Introduce alias member in event_symbol
      perf_counter tools: Set alias for page-faults
      perf stat: Fix command option / manpage
      perf stat: Fix verbose for perf stat
      perf stat: Remove dead code
      perf_counter tools: Check for valid cache operations
      perf_counter tools: Shorten names for events
      perf_counter tools: Add alias for 'l1d' and 'l1i'
      gitignore: ignore scripts/ihex2fw
      perf stat: Improve output
      KVM: kvm/x86_emulate.c toggle_interruptibility() should be static
      KVM: shut up uninit compiler warning in paging_tmpl.h
      perf stat: Micro-optimize the code: memcpy is only required if no e=
vent is selected and !null_run
      netfilter: headers_check fix: linux/netfilter/xt_osf.h

Jeff Layton (8):
      cifs: remove unneeded NULL checks from cifs_show_options
      cifs: have cifs_show_options show forceuid/forcegid options
      cifs: add new routine for converting AF_INET and AF_INET6 addrs
      cifs: display scopeid in /proc/mounts
      cifs: have cifs parse scope_id out of IPv6 addresses and use it
      cifs: fix problems with earlier patches
      cifs: remove rw/ro options
      cifs: fix fh_mutex locking in cifs_reopen_file

Jens Axboe (3):
      cfq-iosched: move cfqq initialization out of cfq_find_alloc_queue()
      cfq-iosched: get rid of the need for __GFP_NOFAIL in cfq_find_alloc=
_queue()
      block: get rid of queue-private command filter

Jens Rosenboom (1):
      ipv6: avoid wraparound for expired preferred lifetime

Jeremy Kerr (1):
      fs: allow d_instantiate to be called with negative parent dentry

Jerome Glisse (2):
      drm/radeon: fix radeon kms framebuffer device
      drm/radeon: fix driver initialization order so radeon kms can be bu=
iltin

Jes Sorensen (1):
      KVM: ia64: fix ia64 build due to missing kallsyms_lookup() and doub=
le export

Jesper Dangaard Brouer (6):
      nf_conntrack: Use rcu_barrier()
      decnet: Use rcu_barrier() on module unload.
      ipv6: Use rcu_barrier() on module unload.
      bridge: Use rcu_barrier() instead of syncronize_net() on unload.
      sunrpc: Use rcu_barrier() on unload.
      mac80211: Use rcu_barrier() on unload.

Jesse Barnes (2):
      drm/i915: correct suspend/resume ordering
      drm/i915: fix LFP data fetch

Jesse Brandeburg (3):
      ixgbe: fix unmap length bug
      igb: fix unmap length bug
      e1000: fix unmap bug

Jiri Slaby (5):
      sound: OSS: mpu401, fix deadlock
      AFS: Fix lock imbalance
      floppy: fix lock imbalance
      Btrfs: fix use after free in btrfs_start_workers fail path
      mfd: sm501, fix lock imbalance

Joe Perches (8):
      sound: Use PCI_VDEVICE
      sound: Use PCI_VDEVICE for CREATIVE and ECTIVA
      eeepc-laptop.c: use pr_fmt and pr_<level>
      arch/sh/boards/mach-se/7206/io.c: Remove unnecessary semicolons
      [IA64] Remove unnecessary semicolons
      MAINTAINERS: update EDAC-I82975X
      MAINTAINERS: STARFIRE/DURALAN update
      MIPS: MT: Remove unnecessary semicolons

Johannes Weiner (1):
      perf record: Fix filemap pathname parsing in /proc/pid/maps

John Muir (1):
      fuse: invalidation reverse calls

Jon Smirl (1):
      powerpc: Have git ignore generated files from dtc compile

Jonathan McDowell (1):
      OMAP1: Fix compilation of arch/arm/mach-omap1/mailbox.c

Josef Bacik (1):
      Btrfs: account for space we may use in fallocate

Julia Lawall (1):
      mtd: Use BLOCK_NIL consistently in NFTL/INFTL

Julian Calaby (3):
      sparc64: Fix build warnings in piggyback_64.c
      sparc32: Fix tftpboot.img Makefile
      sparc32: Fix makefile not generating required files

KAMEZAWA Hiroyuki (1):
      elf: limit max map count to safe value

Kalle Jokiniemi (1):
      OMAP3: DMA: Enable idlemodes for DMA OCP

Karen Xie (1):
      [SCSI] cxgb3i: fix connection error when vlan is enabled

Kay Sievers (1):
      sound: do not set DEVNAME for OSS devices

Keith Packard (13):
      drm/i915: Require digital monitor on HDMI ports for detect
      drm/i915: Apple DMI info has inconsistent SYS_VENDOR information
      drm/i915: check for CONFIG_PNP before using pnp function
      drm/i915: Change I2C api to pass around i2c_adapters
      drm/i915: Clean up SDVO i2c handling
      drm/i915: add per-output hotplug callback for KMS
      drm/i915: Add Display Port support
      drm/i915: Use hotplug callback to retrain DP link
      drm/i915: Split array of DAC limits into separate structures.
      drm/i915: Add CLKCFG register definition
      drm/i915: Clarify error returns from display port aux channel I/O
      drm/i915: Generate 2MHz clock for display port aux channel I/O. Ret=
ry I/O.
      fs/notify/inotify: decrement user inotify count on close

Kevin Hilman (1):
      OMAP2/3: Add omap_type() for determining GP/EMU/HS

Kim Kyuwon (3):
      leds: fix led-bd2802 errors while resuming
      leds: change the license information
      leds: add the sysfs interface into the leds-bd2802 driver for chang=
ing wave pattern and led current.

Krzysztof Halasa (2):
      drm/i915: Fix size_t handling in off-by-default debug printfs
      drm/i915: Catch up to obj_priv->page_list rename in disabled debug =
code.

Krzysztof Helt (1):
      fbdev: add mutex for fb_mmap locking

Kumar Gala (6):
      powerpc/cpm1: Remove IMAP_ADDR
      powerpc/85xx: Stop using ppc_md.init on socrates
      powerpc/85xx: Fix issue found by lockdep trace in smp_85xx_kick_cpu
      powerpc: Refactor device tree binding
      powerpc: Fix output from show_regs
      powerpc: Fix mpic alloc warning

Kuninori Morimoto (2):
      sh: ms7724se: Add sh_eth support
      sh: ms7724se: Enable sh_eth in defconfig.

Kurt Garloff (1):
      x86: Add sysctl to allow panic on IOCK NMI error

Kyle McMartin (10):
      parisc: wire up preadv/pwritev syscalls
      parisc: kill WARN in free_initmem when DEBUG_KERNEL
      parisc: wire up rt_tgsigqueueinfo
      parisc: fix compile warning in mm/init.c
      parisc: processor.c, fix bloated stack frame
      parisc: inventory.c, fix bloated stack frame
      parisc: wire sys_perf_counter_open to sys_ni_syscall
      parisc: add task_pt_regs macro
      parisc: perf: wire up sys_perf_counter_open
      parisc: use generic atomic64 on 32-bit

Li Zefan (10):
      tracing/events: Don't increment @pos in s_start()
      tracing_bprintk: Don't increment @pos in t_start()
      trace_stat: Don't increment @pos in seq start()
      tracing: Reset iterator in t_start()
      ftrace: Don't increment @pos in g_start()
      ftrace: Don't manipulate @pos in t_start()
      ftrace: Fix t_hash_start()
      tracing: Fix trace_buf_size boot option
      ftrace: Remove duplicate newline
      ftrace: Fix the output of profile

Linus Torvalds (46):
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/ide-2.6
      Merge branch 'futexes-for-linus' of git://git.kernel.org/pub/scm/li=
nux/kernel/git/tip/linux-2.6-tip
      Merge branch 'drm-fixes' of git://git.kernel.org/pub/scm/linux/kern=
el/git/airlied/drm-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/sfrench/cifs-2.=
6
      Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel=
/git/lenb/linux-acpi-2.6
      Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/benh/powerpc
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/bp/bp
      Merge branch 'for-linus' of git://git.o-hand.com/linux-rpurdie-leds
      Merge branch 'tracing-fixes-for-linus' of git://git.kernel.org/pub/=
scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'timers-fixes-for-linus' of git://git.kernel.org/pub/s=
cm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge git://git.infradead.org/iommu-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/sfrench/cifs-2.=
6
      Merge branch 'kvm-updates/2.6.31' of git://git.kernel.org/pub/scm/v=
irt/kvm/kvm
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'for-linus' of git://git.o-hand.com/linux-rpurdie-back=
light
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'bugfixes' of git://git.kernel.org/pub/scm/linux/kerne=
l/git/jmorris/security-testing-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge branch 'for-linus' of git://git.infradead.org/users/eparis/no=
tify
      Merge master.kernel.org:/home/rmk/linux-2.6-arm
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/ide-2.6
      Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel=
/git/aegl/linux-2.6
      Merge branch 'perfcounters-fixes-for-linus' of git://git.kernel.org=
/pub/scm/linux/kernel/git/tip/linux-2.6-tip
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/agk/linux-2.6-d=
m
      Merge branch 'kmemleak' of git://linux-arm.org/linux-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'for-linus' of git://neil.brown.name/md
      Merge branch 'for-linus' of git://git.kernel.dk/linux-2.6-block
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/mszeredi/fuse
      Merge git://git.infradead.org/mtd-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/lethal/sh-2.6
      x86: fix power-of-2 round_up/round_down macros
      Merge git://git.infradead.org/iommu-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/jejb/scsi-rc-fi=
xes-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/mason/btrfs-uns=
table
      Merge branch 'for-linus' of git://git.infradead.org/users/eparis/no=
tify
      Merge branch 'for-linus' of git://git.kernel.dk/linux-2.6-block
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/sam/kbuild-fixe=
s
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge branch 'upstream' of git://ftp.linux-mips.org/pub/scm/upstrea=
m-linus
      Merge branch 'for-2.6.31' of git://linux-nfs.org/~bfields/linux
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/sameo/mfd-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/kyle/parisc-2.6
      Linux 2.6.31-rc2

Linus Walleij (1):
      [ARM] 5565/2: Use PAGE_SIZE and RO_DATA() in link script

Magnus Damm (2):
      sh: fix se7724 ceu names
      sh: re-add LCDC fbdev support to the Migo-R defconfig

Mallikarjuna R Chilakala (2):
      ixgbe: Fix device capabilities of 82599 single speed fiber NICs.
      ixgbe: Fix link capabilities during adapter resets

Marcelo Tosatti (1):
      KVM: protect concurrent make_all_cpus_request

Mark Brown (2):
      leds: Further document parameters for blink_set()
      ASoC: Only disable pxa2xx-i2s clocks if we enabled them

Martin K. Petersen (2):
      md: Use new topology calls to indicate alignment and I/O sizes
      block: Create bip slabs with embedded integrity vectors

Matt Fleming (1):
      sh: Fix compiler error and include the definition of IS_ERR_VALUE

Matthew Wilcox (1):
      parisc: Fix PCI resource allocation on non-PAT SBA machines

Michael Buesch (1):
      parport/serial: add support for NetMos 9901 Multi-IO card

Michael Ellerman (1):
      powerpc: Swiotlb breaks pseries

Michel D=C3=A4nzer (3):
      drm/radeon: Don't initialize acceleration related fields of struct =
fb_info.
      drm/radeon: Clear surface registers at initialization time.
      drm: Fix shifts which were miscalculated when converting from bitfi=
elds.

Mike Frysinger (1):
      bfin: delay IRQ registration until driver is ready

Mike Mason (1):
      e1000e: io_error_detected callback should return PCI_ERS_RESULT_DIS=
CONNECT

Mike Snitzer (1):
      dm table: fix blk_stack_limits arg to use bytes not sectors

Miklos Szeredi (2):
      fuse: fix bad return value in fuse_file_poll()
      fuse: allow umask processing in userspace

Milan Broz (1):
      dm exception store: really fix type lookup

Mimi Zohar (3):
      integrity: ima mq_open imbalance msg fix
      integrity: ima audit hash_exists fix
      integrity: add ima_counts_put (updated)

Naohiro Ooiwa (1):
      bnx2x: Fix the behavior of ethtool when ONBOOT=3Dno

NeilBrown (6):
      md: avoid dereferencing NULL pointer when accessing suspend_* sysfs=
 attributes.
      md: fix error path when duplicate name is found on md device creati=
on.
      md: tidy up error paths in md_alloc
      md/raid5: suspend shouldn't affect read requests.
      md: use interruptible wait when duration is controlled by userspace.
      blocK: Restore barrier support for md and probably other virtual de=
vices.

Nelson Castillo (1):
      [ARM] GTA02: build fixes (s3c2410_nand_set usage)

Nicolas Ferre (2):
      [ARM] 5563/1: at91: at91sam9rlek lcd interface correction
      [ARM] 5562/2: at91: add gpio button support for at91sam9g20ek

Nicolas Reinecke (1):
      mdio add missing GPL flag

Nikanth Karthikesan (1):
      cpusets: document adding/removing cpus to cpuset elaborately

Ondrej Zary (1):
      ALSA: cmi8330: fix MPU-401 PnP init copy&paste bug

Pallipadi, Venkatesh (1):
      x86, delay: tsc based udelay should have rdtsc_barrier

Patrick McHardy (1):
      netfilter: tcp conntrack: fix unacknowledged data detection with NA=
T

Paul Mackerras (2):
      perf_counter tools: Reduce perf stat measurement overhead/skew
      perf_counter: Provide a way to enable counters on exec

Paul Menage (1):
      UML: Fix some apparent bitrot

Paul Mundt (10):
      sh: make set_perf_counter_pending() static inline.
      sh: Hook up page fault events for software perf counters.
      sh64: Hook up page fault events for software perf counters.
      perf_counter tools: add cpu_relax()/rmb() definitions for sh.
      ring-buffer: Make it generally available
      sh: Kill off unused DEBUG_BOOTMEM symbol.
      nommu: provide follow_pfn().
      asm-generic/vmlinux.lds.h: Fix up RW_DATA_SECTION definition.
      sh: LCDC dcache flush for deferred io
      video: sm501fb: Early initialization of mm_lock mutex.

Pekka J Enberg (1):
      x86: Move init_gbpages() to setup_arch()

Peter Oberparleiter (1):
      gcov: fix documentation

Peter Ujfalusi (1):
      MAINTAINERS: Add entry for twl4030 series soc codec driver

Peter Zijlstra (16):
      perf report: Output more symbol related debug data
      perf_counter tools: Handle overlapping MMAP events
      perf_counter: Optimize perf_swcounter_event()
      perf_counter: Push inherit into perf_counter_alloc()
      perf_counter: Optimize perf_counter_alloc()'s inherit case
      clarify get_user_pages() prototype
      perf_counter tools: Rework the file format
      perf_counter: Split the mmap control page in two parts
      perf_counter: Add scale information to the mmap control page
      perf_counter, x86: Add mmap counter read support
      perf_counter: Add PERF_EVENT_READ
      perf_counter: Implement more accurate per task statistics
      perf_counter: Rework the sample ABI
      perf-report: Add modes for inherited stats and no-samples
      perf-report: Add bare minimum PERF_EVENT_READ parsing
      perf_counter: Complete counter swap

Ralf Baechle (2):
      MIPS: Allow suspend and hibernation again on uniprocessor kernels.
      MIPS: Fix CONFIG_FLATMEM version of pfn_valid()

Randolph Chung (1):
      parisc: fix mismatched parenthesis in memcpy.c

Randy Dunlap (1):
      kernel-doc: move ignoring kmemcheck

Randy Vinson (1):
      powerpc/85xx: Fix FSL RapidIO probing on MDS boards

Renaud Lottiaux (1):
      bsdacct: fix access to invalid filp in acct_on()

Richard Kennedy (1):
      mm: prevent balance_dirty_pages() from doing too much work

Richard Purdie (2):
      leds: Remove an orphan Kconfig entry
      leds: Futher document blink_set

Robert P. J. Day (1):
      x86, setup: Fix typo "CONFIG_x86_64" in <asm/boot.h>

Robert Reif (1):
      sparc32: Fix obvious build issues for tftpboot.img build.

Roel Kluin (3):
      OMAP2/3: omap mailbox: platform_get_irq() error ignored
      perf_counter tools: Fix strbuf_fread() error path handling
      [SCSI] fnic: remove redundant BUG_ONs and fix checks on unsigned

Russell King (2):
      Merge branch 'omap-fixes' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/tmlind/linux-omap-2.6
      Merge branch 's3c-fixes' of git://aeryn.fluff.org.uk/bjdooks/linux

R=C3=A9mi Denis-Courmont (2):
      Phonet: publicize the Netlink notification function
      Phonet: generate Netlink RTM_DELADDR when destroying a device

Sam Ravnborg (1):
      sparc: fix tftpboot.img build

Sean MacLennan (1):
      powerpc/warp: Platform fix for i2c change

Shan Wei (1):
      cfq-iosched: remove redundant check for NULL cfqq in cfq_set_reques=
t()

Shin-ichiro KAWASAKI (1):
      clocksource: sh_tmu: Make undefined TCOR behaviour less undefined.

Simo Leone (1):
      [CIFS] Copy struct *after* setting the port, instead of before.

Sonny Rao (2):
      powerpc/BSR: add 4096 byte BSR size
      powerpc/BSR: Fix BSR to allow mmap of small BSR on 64k kernel

Stephen Rothwell (1):
      fbdev: work around old compiler bug

Steve French (6):
      Merge branch 'master' of /pub/scm/linux/kernel/git/torvalds/linux-2=
.6
      [CIFS] Fix build break
      [CIFS] Do not send tree disconnect if session is already disconnect=
ed
      [CIFS] cleanup asn handling for ntlmssp
      [CIFS] remove bkl usage from umount begin
      [CIFS] remove unknown mount option warning message

Steven A. Falco (1):
      mtd: m25p80 timeout too short for worst-case m25p16 devices

Suresh Jayaraman (1):
      cifs: Fix incorrect return code being printed in cFYI messages

Takashi Iwai (27):
      ALSA: hda - Simplify AD1986A mixer definitions
      ALSA: hda - Generalize the pin-detect quirk for Lenovo N100
      ALSA: hda - Fix support for Samsung P50 with AD1986A codec
      ALSA: hda - Add pin-sense trigger when needed for Realtek codecs
      ALSA: hda - Use model=3Dacer-aspire-6530g for Acer Aspire 6930G
      Merge branch 'for-2.6.31' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/broonie/sound-2.6 into fix/asoc
      ALSA: hda - Add missing initializations for ALC268 and ALC269
      Merge branch 'fix/hda' into for-linus
      Merge branch 'fix/hda-samsung-p50' into for-linus
      Merge branch 'fix/lx6464es' into for-linus
      Merge branch 'fix/misc' into for-linus
      Merge branch 'fix/oxygen' into for-linus
      Merge branch 'fix/pci-vdevice' into for-linus
      ALSA: hda - Add missing static to patch_ca0110()
      ALSA: hda - Add quirk for HP 6930p
      ALSA: usx2y - reparent sound device
      Merge branch 'fix/asoc' into for-linus
      Merge branch 'fix/caiaq' into for-linus
      Merge branch 'fix/hda' into for-linus
      Merge branch 'fix/oxygen' into for-linus
      ALSA: hda - Add GPIO1 control at muting with HP laptops
      ALSA: hda - Improve ASUS eeePC 1000 mixer
      ALSA: hda - Avoid invalid formats and rates with shared SPDIF
      ALSA: hda - Call snd_pcm_lib_hw_rates() again after codec open call=
back
      ALSA: hda - Add sanity check in PCM open callback
      Merge branch 'fix/hda' into for-linus
      Merge branch 'fix/soundcore' into for-linus

Tejun Heo (10):
      percpu: fix too lazy vunmap cache flushing
      x86: fix duplicate free in setup_pcpu_remap() failure path
      x86: rename remap percpu first chunk allocator to lpage
      x86: prepare setup_pcpu_lpage() for pageattr fix
      x86: reorganize cpa_process_alias()
      x86: fix pageattr handling for lpage percpu allocator and re-enable=
 it
      x86: implement percpu_alloc kernel parameter
      x86: ensure percpu lpage doesn't consume too much vmalloc space
      alpha: fix percpu build breakage
      block: don't merge requests of different failfast settings

Tero Kristo (1):
      OMAP3: SRAM size fix for HS/EMU devices

Thadeu Lima de Souza Cascardo (5):
      mtd: cmdlineparts: Use 64-bit format when printing a debug message.
      mtd: atmel_nand: Fix typo s/parititions/partitions/
      acm: Return ENODEV instead of EINVAL when trying to open ACM device.
      acm: Fix oops when closing ACM tty device right after open has fail=
ed.
      usb_serial: Fix oops when unexisting usb serial device is opened.

Thomas Gleixner (3):
      futex: request only one page from get_user_pages()
      dmapools: protect page_list walk in show_pools()
      parisc: remove obsolete hw_interrupt_type

Tim Abbott (3):
      Add new macros for page-aligned data and bss sections.
      asm-generic/vmlinux.lds.h: shuffle INIT_TASK* macro names in vmlinu=
x.lds.h
      Add new __init_task_data macro to be used in arch init_task.c files.

Tim Anderson (5):
      MIPS: CMP: Extend the GIC IPI interrupts beyond 32
      MIPS: CMP: Extend IPI handling to CPU number
      MIPS: CMP: activate CMP support
      MIPS: CMP: Move gcmp_probe to before the SMP ops
      MIPS: CMP: Update sync-r4k for current kernel

Tim Blechmann (1):
      ALSA: lx6464es - configure ethersound io channels

Timur Tabi (1):
      powerpc/qe: add polling timeout to qe_issue_cmd()

Tobias Mueller (1):
      leds: alix-leds2 fixed for Award BIOS

Tony Lindgren (1):
      OMAP: Fix IOMEM macro for assembly

Tony Luck (1):
      Add Fenghua Yu as temporary co-maintainer for ia64

Tony Vroon (1):
      ALSA: hda - Line In for Acer Inspire 6530G model

Trent Piepho (1):
      leds: Add options to have GPIO LEDs start on or keep their state

Troy Moure (1):
      ACPI: video: prevent NULL deref in acpi_get_pci_dev()

Ville Syrjala (2):
      atyfb: fix HP OmniBook 500 reboot hang
      atyfb: fix alignment for block writes

Wei Yongjun (3):
      tcp: missing check ACK flag of received segment in FIN-WAIT-2 state
      xfrm: use xfrm_addr_cmp() instead of compare addresses directly
      sctp: xmit sctp packet always return no route error

Wolfgang Illmeyer (1):
      hostfs: set maximum filesize in superblock for proper LFS support

Yan Zheng (1):
      Btrfs: update backrefs while dropping snapshot

Yang Shi (1):
      edac: add DDR3 memory type for MPC85xx EDAC

Yinghai Lu (3):
      perf_counter, x86: Update x86_pmu after WARN()
      x86: only clear node_states for 64bit
      x86: add boundary check for 32bit res before expand e820 resource t=
o alignment

Yoichi Yuasa (2):
      MIPS: Update VR41xx GPIO driver to use gpiolib
      Update Yoichi Yuasa's e-mail address

Yong Wang (1):
      perf_counter, x86: Set global control MSR correctly

Yong Zhang (1):
      MIPS: 64-bit: Fix o32 core dump

Yu Zhao (1):
      intel-iommu: Only avoid flushing device IOTLB for domain ID 0 in ca=
ching mode

Zhang Rui (1):
      kernel/resource.c: fix sign extension in reserve_setup()

Zhao Yakui (2):
      drm/i915: Add support for changing LVDS panel fitting using an outp=
ut property.
      drm/i915: Don't change the blank/sync width when calculating scaled=
 modes

Zhenwen Xu (1):
      leds: leds-gpio - fix a section mismatch

Zhenyu Wang (1):
      drm/i915: Fix HDMI regression introduced in new chipset support

janboe (1):
      OMAP2/3: Initialize gpio debounce register

ling.ma-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org (1):
      drm/i915: set TV detection mode when tv is already connected

matthieu castet (1):
      MIPS: BC47xx: Fix SSB irq setup

maximilian attems (1):
      kbuild: deb-pkg ship changelog

roel kluin (1):
      sh_eth: remove redundant test on unsigned

vimal singh (1):
      mtd: nand: fix build failure and incorrect return from omap_wait()

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr

--===============1953819156677962967==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============1953819156677962967==--
