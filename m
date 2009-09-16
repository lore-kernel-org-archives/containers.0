From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr annotated tag, v2.6.31-rc6, created. v2.6.31-rc6
Date: Wed, 16 Sep 2009 14:36:58 -0400
Message-ID: <200909161836.n8GIawZ3001675@gorgona.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5079269748516322817=="
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

--===============5079269748516322817==
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by smtp1.linux-foundation.org id n8GJTIUZ009261

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The annotated tag, v2.6.31-rc6 has been created
        at  73e5ade3a45e2096db80f0e87d6d838d0499f0fe (tag)
   tagging  64f1607ffbbc772685733ea63e6f7f4183df1b16 (commit)
  replaces  v2.6.31-rc5
 tagged by  Linus Torvalds
        on  Thu Aug 13 15:43:45 2009 -0700

- Log -----------------------------------------------------------------
Linux 2.6.31-rc6
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkqElyYACgkQF3YsRnbiHLtsHACffhkcNl3Q5mdvMwPY+rKkfpCX
eGAAnAtPRuz+1Yj6vQAe5q3OArPkGa/6
=3DCpL7
-----END PGP SIGNATURE-----

Adrian Hunter (2):
      UBI: fix double free on error path
      UBI: compatible fallback in absense of sequence numbers

Akinobu Mita (1):
      MIPS: Drop mmap_sem in pagefault oom path

Alan D. Brunelle (1):
      Remove double removal of blktrace directory

Alan Jenkins (1):
      eeepc-laptop: fix hot-unplug on resume

Alan Stern (3):
      USB: usbfs: fix -ENOENT error code to be -ENODEV
      USB: EHCI: fix two new bugs related to Clear-TT-Buffer
      USB: EHCI: fix counting of transaction error retries

Albin Tonnerre (1):
      lib/decompress_*: only include <linux/slab.h> if STATIC is not defi=
ned

Alex Deucher (2):
      drm/radeon: add some new r7xx pci ids
      drm/radeon: Add support for RS880 chips

Alexander Clouter (1):
      MIPS: Fix compile for !CONFIG_SMP

Alexander Duyck (1):
      igbvf: Allow VF driver to correctly recognize failure to set mac

Alok Kataria (1):
      x86: Fix VMI && stack protector

Anders Grafstr=C3=B6m (1):
      jffs2: Fix return value from jffs2_do_readpage_nolock()

Andre Noll (1):
      md: Push down data integrity code to personalities.

Andreas Eversberg (1):
      mISDN: Fix handling of receive buffer size in L1oIP

Andrew Victor (1):
      ARM: 5637/1: [KS8695] Don't reference CLOCK_TICK_RATE in drivers

Arnaldo Carvalho de Melo (10):
      perf top: Add mwait_idle_with_hints to skip_symbols[]
      perf report: Add missing command line options to man page
      perf symbol: Fix symbol parsing in certain cases: use the build-id =
as a symlink
      perf report: Add debug help for the finding of symbol bugs - show t=
he symtab origin (DSO, build-id, kernel, etc)
      perf record: Fix .tid and .pid fill-in when synthesizing events
      perf report: Show the tid too in -D
      perf tools: Fix fallback to cplus_demangle() when bfd_demangle() is=
 not available
      perf tools: Fix dso__new handle() to handle deleted DSOs
      perf list: Fix large list output by using the pager
      perf report: Don't show unresolved DSOs and symbols when -S/-d is u=
sed

Artem Bityutskiy (1):
      mtd: blkdevs: do not forget to get MTD devices

Atsushi Nemoto (1):
      MIPS: RBTX4939: Fix IOC pin-enable register updating

Avi Kivity (1):
      KVM: ia64: fix build failures due to ia64/unsigned long mismatches

Bartlomiej Zolnierkiewicz (2):
      Btrfs: remove superfluous NULL pointer check in btrfs_rename()
      pata_atiixp: fix second channel support

Ben McKeegan (1):
      ppp: fix lost fragments in ppp_mp_explode() (resubmit)

Benjamin Herrenschmidt (2):
      perf_counter/powerpc: Check oprofile_cpu_type for NULL before using=
 it
      powerpc/dma: pci_set_dma_mask() shouldn't fail if mask fits in RAM

Bjorn Helgaas (1):
      ACPI: bind workqueues to CPU 0 to avoid SMI corruption

Borislav Petkov (1):
      x86, msr: execute on the correct CPU subset

Brice Goglin (1):
      perf stat: Fix tool option consistency: rename -S/--scale to -c/--s=
cale

Carlos R. Mafra (1):
      perf: "Longum est iter per praecepta, breve et efficax per exempla"

Chengu Wang (1):
      ALSA: hda: Correct EAPD for Dell Inspiron 1525

Chris Mason (1):
      Btrfs: make sure the async caching thread advances the key

Christian Borntraeger (1):
      KVM: s390: fix wait_queue handling

Christof Schmitt (10):
      [SCSI] zfcp: Acquire qdio_stat_lock when reading the queue utilizat=
ion
      [SCSI] zfcp: Return -ENOMEM for allocation failures in zfcp_fsf
      [SCSI] zfcp: Use correct flags for zfcp_erp_notify
      [SCSI] zfcp: Use unchained mode for small ct and els requests
      [SCSI] zfcp: Use -EIO for SBAL allocation failures
      [SCSI] zfcp: Fix logic for physical port close
      [SCSI] zfcp: Fix erp escalation procedure
      [SCSI] zfcp: Recover from stalled outbound queue
      [SCSI] zfcp: Add port only once to FC transport class
      [SCSI] zfcp: Fix tracing of request id for abort requests

Christoph Hellwig (14):
      vfs: fix inode_init_always calling convention
      vfs: add __destroy_inode
      xfs: fix freeing of inodes not yet added to the inode cache
      xfs: avoid memory allocation under m_peraglock in growfs code
      xfs: switch to NOFS allocation under i_lock in xfs_getbmap
      xfs: switch to NOFS allocation under i_lock in xfs_da_state_alloc
      xfs: switch to NOFS allocation under i_lock in xfs_da_buf_make
      xfs: switch to NOFS allocation under i_lock in xfs_dir_cilookup_res=
ult
      xfs: switch to NOFS allocation under i_lock in xfs_buf_associate_me=
mory
      xfs: switch to NOFS allocation under i_lock in xfs_attr_rmtval_set
      xfs: switch to NOFS allocation under i_lock in xfs_readlink_bmap
      xfs: switch to NOFS allocation under i_lock in xfs_attr_rmtval_get
      xfs: check for dinode realtime flag corruption
      xfs: fix spin_is_locked assert on uni-processor builds

Dan Carpenter (1):
      wireless: ERR_PTR vs null

Dan Williams (1):
      md/raid6: release spare page at ->stop()

Darren Hart (3):
      rtmutex: Avoid deadlock in rt_mutex_start_proxy_lock()
      futex: Update futex_q lock_ptr on requeue proxy lock
      futex: Fix handling of bad requeue syscall pairing

Dave Airlie (3):
      drm/radeon/kms: fix rv515 VRAM initialisation.
      drm/radeon/kms: fix nomodeset.
      drm/radeon/kms: setup MC/VRAM the same way for suspend/resume

Dave Jones (1):
      [CPUFREQ] Make cpufreq suspend code conditional on powerpc.

Dave Young (1):
      bluetooth: rfcomm_init bug fix

David Daney (3):
      MIPS: Avoid clobbering struct pt_regs in kthreads
      MIPS: Octeon PCIe: Make hardware and software bus numbers match.
      MIPS: Octeon: Run IPI code with interrupts disabled.

David S. Miller (2):
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-2.6
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-2.6

Dhananjay Phadke (1):
      netxen: fix coherent dma mask setting

Dhaval Vasa (1):
      USB: ftdi_sio: add product_id for Marvell OpenRD Base, Client

Dinakar Guniguntala (1):
      futex: Fix compat_futex to be same as futex for REQUEUE_PI

Dmitry Torokhov (1):
      x86, mce: therm_throt - change when we print messages

Don Fry (2):
      pcnet32: remove superfluous NULL pointer check in pcnet32_probe1()
      pcnet32: VLB support fixes

Doug Thompson (2):
      amd64_edac: fix ECC checking
      amd64_edac: print debug statements only on error

Eric Anholt (1):
      drm/i915: Use our own workqueue to avoid wedging the system along w=
ith the GPU.

Eric Dumazet (5):
      pppoe: fix /proc/net/pppoe
      pppol2tp: calls unregister_pernet_gen_device() at unload time
      net: net_assign_generic() fix
      ring-buffer: Fix memleak in ring_buffer_free()
      execve: must clear current->clear_child_tid

Eric Miao (1):
      Input: matrix_keypad - make matrix keymap size dynamic

Eric Sandeen (2):
      compat_ioctl: hook up compat handler for FIEMAP ioctl
      use XFS_CORRUPTION_ERROR in xfs_btree_check_sblock

Fenghua Yu (5):
      intel-iommu: Correct sglist size calculation.
      intel-iommu: Mask physical address to correct page size in intel_ma=
p_single()
      Bug Fix arch/ia64/kernel/pci-dma.c: fix recursive dma_supported() c=
all in iommu_dma_supported()
      arch/ia64/Makefile: Remove -mtune=3Dmerced in IA64 kernel build
      ia64/topology.c: exit cache_add_dev when kobject_init_and_add fails

Figo.zhang (1):
      mempool.c: clean up type-casting

Florian Fainelli (8):
      MIPS: MSP71xx: fix build failures on msp_irq_slp.c
      MIPS: MSPxxxx: define MIPS34K_MISSED_ITLB_WAR for other PMC-Sierra =
SoC
      MIPS: AR7: Fix build warning on memory.c
      MIPS: AR7: Fix build failures when CONFIG_SERIAL_8250 is not enable=
d
      MIPS: AR7: Use DMA_BIT_MASK(nn) instead of deprecated DMA_nnBIT_MAS=
K
      MIPS: AR7: Remove unused tnetd7200_get_clock function
      MIPS: AR7: Override CFLAGS with -Werror
      MIPS: MTX-1: Request button GPIO before setting its direction

Florian Mickler (1):
      drm/i915: Set lvds dual channel according to register from vbios

Florian Tobias Schandinat (1):
      viafb: fix rmmod bug

Frans Pop (2):
      hp-wmi: check that an input device exists in resume handler
      drm/i915: silence vblank warnings

Frederic Weisbecker (12):
      perf_counter: Fix/complete ftrace event records sampling
      perf tools: Fix call-chain cumul hit based sub-total (fractal mode)
      perf tools: callchain: Fix spurious 'perf report' warnings: ignore =
empty callchains
      perf tools: callchain: Fix 'perf report' display to be callchain by=
 default
      perf tools: callchain: Fix sum of percentages to be 100% by display=
ing amount of ignored chains in fractal mode
      perf_counter: Work around gcc warning by initializing tracepoint re=
cord unconditionally
      perf_counter: Fix tracepoint sampling to be part of generic samplin=
g
      perf tools: callchain: Fix bad rounding of minimum rate
      perf_counter: Subtract the buffer size field from the event record =
size
      perf_counter: Zero dead bytes from ftrace raw samples size alignmen=
t
      perf tools: Add a per tracepoint counter attribute to get raw sampl=
e
      perf tools: Add a general option to enable raw sample records

Gabor Juhos (1):
      MIPS: Fix loading of modules with unresolved weak symbols

Gleb Natapov (1):
      KVM: Avoid redelivery of edge interrupt before next edge

Goldwyn Rodrigues (2):
      ocfs2: Initialize count in aio_write before generic_write_checks
      ocfs2: Remove redundant BUG_ON in __dlm_queue_ast()

Greg Kroah-Hartman (2):
      TTY: Maintainer change
      Staging: rtl8192su: fix build error

Gregory Haskins (1):
      sched: Fix race in cpupri introduced by cpumask_var changes

Guennadi Liakhovetski (1):
      i.MX31: fix framebuffer locking regressions

Gupta, Ajay Kumar (1):
      USB: musb: fix the nop registration for OMAP3EVM

H. Peter Anvin (2):
      x86: Fix assert syntax in vmlinux.lds.S
      x86: fix assembly constraints in native_save_fl()

Hannes Hering (1):
      ehea: Fix napi list corruption on ifconfig down

Haojian Zhuang (1):
      [ARM] pxa: fix gpio issue in zylonite

Hartley Sweeten (3):
      [ARM] 5611/1: ep93xx: update ts72xx nor flash support
      ARM: 5638/1: arch/arm/kernel/signal.c: use correct address space fo=
r CRUNCH
      ARM: 5639/1: arm: clkdev.c should include <linux/clk.h>

Helge Deller (5):
      parisc: hp_sdc_mlc.c - check return value of down_trylock()
      parisc: dino.c - check return value of pci_assign_resource()
      parisc: sticore.c - check return values
      parisc: parisc-agp.c - use correct page_mask function
      parisc: hppb.c - fix printk format strings

Hendrik Brueckner (1):
      [S390] kernel: Storing machine flags early in lowcore

Henrique de Moraes Holschuh (3):
      thinkpad-acpi: disable broken bay and dock subdrivers
      thinkpad-acpi: remove dock and bay subdrivers
      thinkpad-acpi: fix incorrect use of TPACPI_BRGHT_MODE_ECNVRAM

Hiroshi Shimamoto (1):
      posix-timers: Fix oops in clock_nanosleep() with CLOCK_MONOTONIC_RA=
W

Huang Weiyi (1):
      MIPS: AR7: Remove unused inclusions of <linux/version.h>.

Ingo Molnar (9):
      perf_counter tools: Fix link errors with older toolchains
      Merge branch 'tracing/fixes' of git://git.kernel.org/pub/scm/linux/=
kernel/git/frederic/random-tracing into tracing/urgent
      perf_counter: Set the CONFIG_PERF_COUNTERS default to y if CONFIG_P=
ROFILING=3Dy
      net: Fix spinlock use in alloc_netdev_mq()
      Merge branch 'linus' into tracing/urgent
      perf_counter, x86: Fix lapic printk message
      perf_counter, x86: Fix generic cache events on P6-mobile CPUs
      perf_counter, x86: Fix/improve apic fallback
      perf_counter: Provide hw_perf_counter_setup_online() APIs

Jack Steiner (5):
      x86, UV: Handle missing blade-local memory correctly
      x86, UV: Delete mapping of MMR rangs mapped by BIOS
      x86, UV: Fix macros for accessing large node numbers
      x86, UV: Fix UV apic mode
      x86, UV: Complete IRQ interrupt migration in arch_enable_uv_irq()

Jakob Bornecrantz (2):
      drm: Small logic fix in drm_mode_setcrtc
      drm: Catch stop possible NULL pointer reference

Jakob Gruber (1):
      Staging: rt2870: Add USB ID for Linksys, Planex Communications, Bel=
kin

James Morris (1):
      SELinux: fix memory leakage in /security/selinux/hooks.c

Jan Beulich (1):
      x86, 32-bit: Fix double accounting in reserve_top_address()

Jan Kara (9):
      ocfs2: Fix deadlock on umount
      ocfs2: Make global quota files blocksize aligned
      ocfs2: Mark buffer uptodate before calling ocfs2_journal_access_dq(=
)
      ocfs2: Initialize blocks allocated to local quota file
      ocfs2: Zero out padding of on disk dquot structure
      ocfs2: Fix initialization of blockcheck stats
      ocfs2: Remove syncjiff field from quota info
      ocfs2: Define credit counts for quota operations
      ocfs2: Fix possible deadlock when extending quota file

Jan Kiszka (3):
      KVM: Fix KVM_GET_MSR_INDEX_LIST
      KVM: VMX: Fix locking order in handle_invalid_guest_state
      KVM: VMX: Fix locking imbalance on emulation failure

Jaswinder Singh Rajput (15):
      ARM: includecheck fix: misc.c
      ARM: includecheck fix: atomic.h
      ARM: includecheck fix: board-dm355-evm.c
      ARM: includecheck fix: board-dm355-leopard.c
      ARM: includecheck fix: board-dm644x-evm.c
      ARM: includecheck fix: board-dm646x-evm.c
      ARM: includecheck fix: board-sffsdr.c
      ARM: includecheck fix: mach-omap1/mcbsp.c
      ARM: includecheck fix: mach-omap2/mcbsp.c
      ARM: includecheck fix: plat-s3c64xx/pm.c
      ARM: includecheck fix: plat-stmp3xxx/pinmux.c
      parisc: includecheck fix for ccio-dma.c
      MN10300: includecheck fix: mn10300, pci.h
      IA64: includecheck fix: ia64, ia64_ksyms.c
      IA64: includecheck fix: ia64, pgtable.h

Jean Delvare (1):
      3c59x: Fix build failure with gcc 3.2

Jeff Garzik (1):
      Remove zero-length file drivers/mtd/maps/sbc8240.c

Jeff Layton (3):
      cifs: fix error handling in mount-time DFS referral chasing code
      cifs: reinstate original behavior when uid=3D/gid=3D options are sp=
ecified
      cifs: show noforceuid/noforcegid mount options (try #2)

Jeff Liu (1):
      ocfs2: trivial fix for s/migrate/migration/ in dlmrecovery.c loggin=
g

Jeff Mahoney (2):
      ocfs2: Fixup orphan scan cleanup after failed mount
      staging: add dependencies on PCI for drivers that require it

Jens Axboe (1):
      perf record: Add missing -C option support for specifying profile c=
pu

Jerome Glisse (1):
      drm/radeon/kms: Fix caching mode selection for GTT object

Jesse Barnes (5):
      drm/i915: refactor error detection & collection
      drm/i915: FIFO watermark calculation fixes
      drm/i915: handle FIFO oversubsription correctly
      drm/i915: correct self-refresh calculation in "everything off" case
      drm/i915: fix 845G FIFO size & burst length

Jiajun Wu (1):
      gianfar: fix coalescing setup in ethtool support

Jiri Pirko (1):
      net: restore the original spinlock to protect unicast list

Johannes Berg (3):
      iwlwifi: fix TX queue race
      mac80211: fix suspend
      cfg80211: add two missing NULL pointer checks

Johannes Weiner (2):
      fbcon: don't use vc_resize() on initialization
      ia64: boolean __test_and_clear_bit

John David Anglin (2):
      parisc: Fix GOT overflow during module load on 64bit kernel
      parisc: Set correct bit in protection flags

John Stoffel (1):
      Make SCSI SG v4 driver enabled by default and remove EXPERIMENTAL d=
ependency, since udev depends on BSG

Jonathan Corbet (1):
      flex_array: remove unneeded index calculation

Jory A. Pratt (1):
      Input: i8042 - add Asus G1S to noloop exception list

Josef Bacik (1):
      Btrfs: fix btrfs_remove_from_free_space corner case

Julia Lawall (6):
      net/netlabel: Add kmalloc NULL tests
      MIPS: Use DIV_ROUND_CLOSEST
      drivers/net/wireless/iwlwifi: introduce missing kfree
      drivers/net/wireless: introduce missing kfree
      drivers/mmc: correct error-handling code
      Btrfs: correct error-handling zlib error handling

KAMEZAWA Hiroyuki (1):
      mm: make set_mempolicy(MPOL_INTERLEAV) N_HIGH_MEMORY aware

Karen Higgins (4):
      [SCSI] qla4xxx: Correct Extended Sense Data Errors
      [SCSI] qla4xxx: Fix Driver Fault Recovery Completion
      [SCSI] qla4xxx: Fix srb lookup in qla4xxx_eh_device_reset
      [SCSI] qla4xxx: Remove hiwat code so scsi eh does not get escalated=
 when we can make progress

Keith Packard (2):
      drm/i915: Allow frame buffers up to 4096x4096 on 915/945 class hard=
ware
      drm: When adding probed modes, preserve duplicate mode types

Kenji Kaneshige (2):
      PCI hotplug: SGI hotplug: fix build failure
      PCI hotplug: SGI hotplug: do not use hotplug_slot_attr

Kevin Winchester (1):
      x86: Clear incorrectly forced X86_FEATURE_LAHF_LM flag

Khanh-Dang Nguyen Thu Lam (1):
      USB: pl2303: New vendor and product id

Kurt Martin (1):
      MIPS: SMTC: Move cross VPE writes to after a TC is assigned to VPE.

Lai Jiangshan (2):
      tracing: Fix invalid function_graph entry
      tracing: Fix missing function_graph events when we splice_read from=
 trace_pipe

Lars-Peter Clausen (1):
      S3C24XX: GPIO: Fix pin range check in s3c_gpiolib_getchip

Len Brown (9):
      Revert "ACPICA: Remove obsolete acpi_os_validate_address interface"
      ACPI: root-only read protection on /sys/firmware/acpi/tables/*
      Merge branch 'bugzilla-13620-revert' into release
      Merge branch 'bugzilla-13865' into release
      Merge branch 'thinkpad' into release
      Merge branch 'bugzilla-13751' into release
      Merge branch 'memhotplug-crash' into release
      Merge branch 'bugzilla-13825' into release
      Merge branch 'misc-2.6.31' into release

Li Zefan (2):
      lockdep: Fix file mode of lock_stat
      lockdep: Fix typos in documentation

Linus Torvalds (72):
      do_sigaltstack: avoid copying 'stack_t' as a structure to user spac=
e
      do_sigaltstack: small cleanups
      Make pci_claim_resource() use request_resource() rather than insert=
_resource()
      Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel=
/git/lenb/linux-acpi-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/wim/linux-2.6-w=
atchdog
      Merge branch 'for-linus' of git://neil.brown.name/md
      tty-ldisc: make refcount be atomic_t 'users' count
      tty-ldisc: turn ldisc user count into a proper refcount
      tty-ldisc: be more careful in 'put_ldisc' locking
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/sfrench/cifs-2.=
6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/ryusuke/nilfs2
      Merge branch 'fixes' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/davej/cpufreq
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/sameo/mfd-2.6
      Merge branch 'tracing-fixes-for-linus' of git://git.kernel.org/pub/=
scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'timers-fixes-for-linus' of git://git.kernel.org/pub/s=
cm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'sched-fixes-for-linus' of git://git.kernel.org/pub/sc=
m/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'perfcounters-fixes-for-linus' of git://git.kernel.org=
/pub/scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/deller/parisc-2.6
      Merge branch 'drm-fixes' of git://git.kernel.org/pub/scm/linux/kern=
el/git/airlied/drm-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/bp/bp
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/jejb/scsi-rc-fi=
xes-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'for-linus' of git://git.kernel.dk/linux-2.6-block
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/tty-2.6
      Merge branch 'fix/hda' of git://git.kernel.org/pub/scm/linux/kernel=
/git/tiwai/sound-2.6
      Merge branch 'upstream' of git://ftp.linux-mips.org/pub/scm/upstrea=
m-linus
      flat: fix uninitialized ptr with shared libs
      Merge branch 'drm-fixes' of git://git.kernel.org/pub/scm/linux/kern=
el/git/airlied/drm-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/dtor/input
      Merge git://git.infradead.org/mtd-2.6
      Merge branch 'perfcounters-fixes-for-linus' of git://git.kernel.org=
/pub/scm/linux/kernel/git/tip/linux-2.6-tip
      Merge git://git.infradead.org/~dwmw2/iommu-2.6.31
      Merge branch 'for-linus' of git://git390.marist.edu/pub/scm/linux-2=
.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge master.kernel.org:/home/rmk/linux-2.6-arm
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/hch/xfs-icache-=
races
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/mason/btrfs-uns=
table
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/anholt/drm-intel
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging-=
2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/usb-2.6
      Merge branch 'core-fixes-for-linus-2' of git://git.kernel.org/pub/s=
cm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'tracing-fixes-for-linus' of git://git.kernel.org/pub/=
scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'timers-fixes-for-linus' of git://git.kernel.org/pub/s=
cm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'drm-fixes' of git://git.kernel.org/pub/scm/linux/kern=
el/git/airlied/drm-2.6
      Merge branch 'kvm-updates/2.6.31' of git://git.kernel.org/pub/scm/v=
irt/kvm/kvm
      Merge branch 'for-linus' of git://git.infradead.org/ubi-2.6
      Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/benh/powerpc
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jmorris/security-testing-2.6
      x86: Fix serialization in pit_expect_msb()
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jbarnes/pci-2.6
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'irq-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'perfcounters-fixes-for-linus' of git://git.kernel.org=
/pub/scm/linux/kernel/git/tip/linux-2.6-tip
      pty: fix data loss when stopped (^S/^Q)
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jmorris/security-testing-2.6
      Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel=
/git/fyu/linux-2.6
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/jgarzik/libata-dev
      Merge branch 'zerolen' of git://git.kernel.org/pub/scm/linux/kernel=
/git/jgarzik/misc-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge branch 'for-linus' of git://oss.sgi.com/xfs/xfs
      Merge branch 'for-linus' of git://git.kernel.dk/linux-2.6-block
      Make sock_sendpage() use kernel_sendpage()
      Merge branch 'sh/for-2.6.31' of git://git.kernel.org/pub/scm/linux/=
kernel/git/lethal/sh-2.6
      Merge branch 'for-linus' of git://neil.brown.name/md
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/jlbec/ocfs2
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'core-fixes-for-linus' of git://git.kernel.org/pub/scm=
/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'perfcounters-fixes-for-linus' of git://git.kernel.org=
/pub/scm/linux/kernel/git/tip/linux-2.6-tip
      genirq: prevent wakeup of freed irq thread
      Linux 2.6.31-rc6

Linus Walleij (2):
      ARM: 5624/1: Document cache aliasing region
      [WATCHDOG] Fix COH 901 327 watchdog enablement

Luis R. Rodriguez (2):
      mac80211: do not queue work after suspend in the dynamic ps timer
      cfg80211: fix regression on beacon world roaming feature

Magnus Damm (4):
      PM / Driver Core: Kill dev_pm_ops platform warning for now
      sh: convert processor device setup functions to arch_initcall()
      sh: fix i2c init order on Migo-R V2
      sh: fix i2c init order on ap325rxa V2

Mallikarjuna R Chilakala (1):
      ixgbe: Patch to modify 82598 PCIe completion timeout values

Marcelo Tosatti (5):
      KVM: PIT: fix kpit_elapsed division by zero
      KVM: x86: verify MTRR/PAT validity
      KVM: SVM: force new asid on vcpu migration
      KVM: MMU: handle n_free_mmu_pages > n_alloc_mmu_pages in kvm_mmu_ch=
ange_mmu_pages
      KVM: MMU: limit rmap chain length

Marek Vasut (1):
      [ARM] pxa: add STUART MFP config for PalmTX,T5,LD

Mark Brown (2):
      S3C64XX: Fix get_rate() for ARMCLK
      S3C64XX: Fix ARMCLK configuration

Marko H=C3=A4nninen (1):
      USB: ftdi_sio: add vendor and product id for Bayer glucose meter se=
rial converter cable

Martin K. Petersen (5):
      [SCSI] sd: Avoid sending extended inquiry to legacy devices
      block: Make blk_queue_stack_limits use the new stacking interface
      block: Add a wrapper for setting minimum request size without a que=
ue
      block: Stack optimal I/O size
      block: Update topology documentation

Matt Fleming (2):
      ftrace: Fix the conditional that updates $ref_func
      ftrace: Only update $offset when we update $ref_func

Matthias Kaehlcke (1):
      mtd: mtdblock: introduce mtdblks_lock

Michael Buesch (3):
      thinkpad-acpi: restrict procfs count value to sane upper limit
      parisc: isa-eeprom - Fix loff_t usage
      USB: devio: Properly do access_ok() checks

Michael Chan (1):
      iscsi: Use GFP_ATOMIC in iscsi_offload_mesg().

Michael Prokop (1):
      Documentation/kernel-parameters.txt: document libata's ignore_hpa o=
ption

Michael S. Tsirkin (1):
      KVM: fix ack not being delivered when msi present

Mika Korhonen (2):
      mtd: OneNAND: fix incorrect bufferram offset
      mtd: OneNAND: OMAP2/3: free GPMC CS on module removal

Mike Christie (2):
      [SCSI] libiscsi: disable bh in and abort handler.
      [SCSI] qla4xxx: add timeout handler

Mike Galbraith (6):
      Staging: rt2870: Revert d44ca7 Removal of kernel_thread() API
      perf_counter tools: Fix/resurrect perf top annotation in a simple i=
nteractive form
      perf_counter tools: Allow perf top top users to switch between weig=
hted and individual counter display
      perf top: Improve interactive key handling
      perf top: Update man page
      perf_counter tools: Fix libbfd detection for systems with libz depe=
ndency

Mike McCormack (1):
      sky2: Avoid transmits during sky2_down()

Mike Rapoport (1):
      [ARM] pxa/em-x270: fix compile failure when CONFIG_APM_EMULATION=3D=
n

NeilBrown (12):
      md: when a level change reduces the number of devices, remove the e=
xcess.
      md: avoid array overflow with bad v1.x metadata
      md: Handle growth of v1.x metadata correctly.
      md/raid5: set reshape_position correctly when reshape starts.
      md: allow raid5_quiesce to work properly when reshape is happening.
      md: Use revalidate_disk to effect changes in size of device.
      Remove deadlock potential in md_open
      md: never advance 'events' counter by more than 1.
      md/raid5: allow new reshape modes to be restarted in the middle.
      md/raid5: make sure a reshape restarts at the correct address.
      md/raid5: Properly remove excess drives after shrinking a raid5/6
      md: allow upper limit for resync/reshape to be set when array is re=
ad-only

Nicolas Pitre (1):
      mtd: let include/linux/mtd/partitions.h stand on its own

OGAWA Hirofumi (1):
      vfs: mnt_want_write_file(): fix special file handling

Oleg Nesterov (3):
      mm_for_maps: simplify, use ptrace_may_access()
      mm_for_maps: shift down_read(mmap_sem) to the caller
      mm_for_maps: take ->cred_guard_mutex to fix the race with exec

Oliver Neukum (1):
      USB: fix oops on disconnect in cdc-acm

Ondrej Zary (1):
      x86: Fix oops in identify_cpu() on CPUs without CPUID

Ozan =C3=87a=C4=9Flayan (1):
      x86: Add quirk to make Apple MacBookPro5,1 use reboot=3Dpci

Pallipadi, Venkatesh (2):
      x86, pat: Fix set_memory_wc related corruption
      [CPUFREQ] Fix NULL pointer dereference regression in conservative g=
overnor

Patrick Simmons (1):
      zd1211rw: fix unaligned access in zd_mac_rx

Paul Mackerras (3):
      x86: Add quirk to make Apple MacBook5,2 use reboot=3Dpci
      x86: Make 64-bit efi_ioremap use ioremap on MMIO regions
      perf_counter/powerpc: Fix oops on cpus without perf_counter hardwar=
e support

Paul Rolland (1):
      drm: silence pointless vblank warning.

Pekka Enberg (1):
      perf report: Make --sort comm,dso,symbol the default

Peter Korsgaard (1):
      ARM: S3C: PWM fix for low duty cycle

Peter P Waskiewicz Jr (3):
      ixgbe: Fix netpoll to be properly multiqueue aware
      ixgbe: Fix usage of second flags bitmap when using LRO/RSC
      ixgbe: Fix RSC completion delay causing Rx interrupts to stop

Peter Zijlstra (22):
      tracing, perf_counter: Add help text to CONFIG_EVENT_PROFILE
      perf_counter: Collapse inherit on read()
      perf_counter: Full task tracing
      perf report: Update for the new FORK/EXIT events
      sched: Fix latencytop and sleep profiling vs group scheduling
      perf: Auto-detect libbfd
      ftrace: Fix perf-tracepoint OOPS
      perf: Auto-detect libelf
      perf_counter: Fix double list iteration in per task precise stats
      perf_counter, ftrace: Fix perf_counter integration
      perf_counter: Fix software counters for fast moving event sources
      perf tools: Fix multi-counter stat bug caused by incorrect reading =
of perf.data file header
      perf report: Fix per task mult-counter stat reporting
      perf list: Fix the output to not include tracepoints without an id
      perf_counter: Fix a race on perf_counter_ctx
      perf_counter: Correct PERF_SAMPLE_RAW output
      perf_counter: Require CAP_SYS_ADMIN for raw tracepoint data
      locking, sched: Give waitqueue spinlocks their own lockdep classes
      perf_counter: Fix swcounter context invariance
      perf: Rework/fix the whole read vs group stuff
      perf_counter: Fix an ipi-deadlock
      perf_counter: Report the cloning task as parent on perf_counter_for=
k()

Phillip Lougher (2):
      bzip2/lzma/gzip: fix comments describing decompressor API
      bzip2/lzma: remove nasty uncompressed size hack in pre-boot environ=
ment

Pierre Habouzit (2):
      perf util: Fix do_read() to fail on EOF instead of busy-looping
      perf record: Fix the -A UI for empty or non-existent perf.data

Prarit Bhargava (1):
      [CPUFREQ] Do not set policy for offline cpus

Raghu Gandham (2):
      MIPS: SMTC: Fix compile error
      MIPS: VPE: Fix compiler warning.

Ralf Baechle (8):
      MIPS: Cavium: Move swapped comments to their rightful place.
      MIPS: Eleminate filenames from comments
      MIPS: Module: Make error messages unique.
      MIPS: VPE: Free relocation chain on error.
      MIPS: VPE: Make various functions static.
      MIPS: VPE: Fix bogus indentation.
      MIPS: VPE: Delete unused function get_tc_unused().
      MIPS: Wire up accept4 syscall.

Ramax Lo (2):
      ARM: S3C24XX: serial: Fix section mismatch warnings
      ARM: S3C64XX: serial: Fix section mismatch warning

Reinette Chatre (1):
      iwlagn: do not send key clear commands when rfkill enabled

Robert Richter (2):
      x86: fix section mismatch for i386 init code
      ring-buffer: Fix advance of reader in rb_buffer_peek()

Roel Kluin (20):
      airo: Buffer overflow
      ath9k: Read outside array bounds
      iwlwifi: Read outside array bounds
      libertas: Read outside array bounds
      libertas: Read buffer overflow
      parisc: Fix read buffer overflow in pdc_stable driver
      ALSA: hda - Read buffer overflow
      MIPS: Fix read buffer overflow
      MIPS: Jazz: Fix read buffer overflow
      libertas: Read buffer overflow
      cifs: Read buffer overflow
      drm/radeon: Read buffer overflow
      drm/ttm: Read buffer overflow
      perf: Fix read buffer overflow
      drm/i915: Fix read outside array bounds in restoring the SWF10 rang=
e.
      [S390] KVM: Read buffer overflow
      ocfs2: keep index within status_map[]
      Staging: rspiusb: Fix buffer overflow
      x86: fix buffer overflow in efi_init()
      arch/ia64/kernel/iosapic: missing test after ioremap()

Rogerio Brito (1):
      USB: storage: include Prolific Technology USB drive in unusual_devs=
 list

Russell King (5):
      Merge branch 'fix' of git://git.kernel.org/pub/scm/linux/kernel/git=
/ycmiao/pxa-linux-2.6
      Merge branch 'mxc-defconfig-updates' of git://git.pengutronix.de/gi=
t/imx/linux-2.6
      Merge branch 's3c-fixes-rc4' of git://aeryn.fluff.org.uk/bjdooks/li=
nux
      Merge branch 's3c-fixes-rc4-2' of git://aeryn.fluff.org.uk/bjdooks/=
linux
      mfd: twl4030 irq fixes

Ryusuke Konishi (3):
      nilfs2: fix oops due to inconsistent state in page with discrete b-=
tree nodes
      nilfs2: fix missing unlock in error path of nilfs_mdt_write_page
      documentation: register ioctl entry of nilfs2

Saeed Bishara (1):
      mtd: fix the conversion from dev to mtd_info

Sascha Hauer (2):
      mx27 defconfig update
      mx3 defconfig update

Shane Huang (1):
      ahci: Soften up the dmesg on SB600 PMP softreset failure recovery

Shane McDonald (1):
      MIPS: Simplify and correct interrupt handling for MSP4200

Sheng Yang (1):
      intel-iommu: Fix enabling snooping feature by mistake

Shunichi Fuji (1):
      x86: Add reboot quirk for every 5 series MacBook/Pro

Stanislaw Gruszka (1):
      posix_cpu_timers_exit_group(): Do not use thread_group_cputimer()

Stefani Seibold (1):
      fbcon: fix rotate upside down crash

Stephen Hemminger (1):
      ip: fix logic of reverse path filter sysctl

Stephen Rothwell (1):
      KVM: Make KVM_HPAGES_PER_HPAGE unsigned long to avoid build error o=
n powerpc

Steve French (2):
      [CIFS] Updates fs/cifs/CHANGES
      [CIFS] Update readme to reflect forceuid mount parms

Steven Rostedt (6):
      tracing: show proper address for trace-printk format
      tracing: only truncate ftrace files when O_TRUNC is set
      ring-buffer: fix check of try_to_discard result
      ring-buffer: do not disable ring buffer on oops_in_progress
      tracing: do not use functions starting with .L in recordmcount.pl
      tracing: Fix recordmcount.pl to handle sections with only weak func=
tions

Stoyan Gaydarov (3):
      parisc: fixed faulty check in lba_pci
      perf tools: Fix faulty check
      drivers/w1/masters/omap_hdq.c: fix missing mutex unlock

Subrata Modak (3):
      ocfs2: Fix compilation warning for fs/ocfs2/xattr.c
      mtd: remove 'SBC8240 Wind River' Device Driver Code
      x86: Work around compilation warning in arch/x86/kernel/apm_32.c

Sunil Mushran (1):
      ocfs2: Initialize the cluster we're writing to in a non-sparse exte=
nd

Swen Schillig (3):
      [SCSI] zfcp: Fix invalid command order
      [SCSI] zfcp: avoid double notify in lowmem scenario
      [SCSI] zfcp: Fix wka port processing

TJ (1):
      Input: wistron_btns - support Prestigio Wifi RF kill button

Takashi Iwai (6):
      ALSA: hda - Fix quirk for Toshiba Satellite A135-S4527
      ASoC: Add missing DRV_NAME definitions for fsl/* drivers
      ALSA: hda - Add missing vmaster initialization for ALC269
      ALSA: hda - Don't override ADC definitions for ALC codecs
      Merge branch 'fix/asoc' into for-linus
      Merge branch 'fix/hda' into for-linus

Tao Ma (3):
      ocfs2: Add extra credits and access the modified bh in update_edge_=
lengths.
      ocfs2: Use ocfs2_rec_clusters in ocfs2_adjust_adjacent_records.
      ocfs2/quota: Release lock for error in ocfs2_quota_write.

Tejun Heo (3):
      pata_at91: fix resource release
      libata: OCZ Vertex can't do HPA
      ahci: add workaround for on-board 5723s on some gigabyte boards

Thomas Gleixner (1):
      trace: stop tracer in oops_enter()

Thomas Hellstrom (3):
      x86: Fix CPA memtype reserving in the set_pages_array*() cases
      drm/ttm: Fix a potential comparison of structs.
      drm/ttm: Fix a sync object leak.

Thomas Renninger (1):
      [CPUFREQ] Fix a kobject reference bug related to managed CPUs

Tobias Klauser (1):
      docbook: fix printk of ip address

Tom Peng (2):
      [SCSI] libsas: reuse the original port when hotplugging phys in wid=
e ports
      [SCSI] libsas: fix wide port hotplug issues

Tom Zanussi (2):
      tracing/filters: Don't use pred on alloc failure
      tracing/filters: Always free pred on filter_add_subsystem_pred() fa=
ilure

Tomas Cech (1):
      ARM: 5623/1: Treo680: ir shutdown typo fix

Tony Vroon (1):
      sata_nv: MSI support, disabled by default

Tormod Volden (1):
      drm/i915: ignore lvds on AOpen Mini PC MP-915

Trond Myklebust (1):
      NFS: Fix an O_DIRECT Oops...

Uwe Kleine-K=C3=B6nig (1):
      ARM: 5627/1: Fix restoring of lr at the end of mcount

Vasu Dev (1):
      [SCSI] libfc: fix a circular locking warning during sending RRQ

Wengang Wang (3):
      ocfs2: log the actual return value of ocfs2_file_aio_write()
      ocfs2: Fix error return in ocfs2_write_cluster()
      ocfs2: Fail ocfs2_get_block() immediately when a block needs alloca=
tion

Wu Fengguang (6):
      ALSA: hda: track CIRB/CORB command/response states for each codec
      ALSA: hda: take cmd_mutex in probe_codec()
      ALSA: hda: take reg_lock in azx_init_cmd_io/azx_free_cmd_io
      ALSA: hda: read CORBWP inside reg_lock
      ALSA: hda: remember last command for each codec
      ALSA: hda: warn on spurious response

Xiao Guangrong (1):
      generic-ipi: fix hotplug_cfd()

Xiaotian Feng (1):
      drm/radeon/kms: fix memory leak in radeon_driver_load_kms

Yan Zheng (1):
      Btrfs: fix balancing oops when invalidate_inode_pages2 returns EBUS=
Y

Yegor Yefremov (1):
      ARM: 5597/1: [PCI] reset all internal hardware prior PCI initializa=
tion

Yevgeny Petrilin (1):
      mlx4_en: Fix double pci unmapping.

Yinghai Lu (3):
      x86: Don't use current_cpu_data in x2apic phys_pkg_id
      x86: Fix MSI-X initialization by using online_mask for x2apic targe=
t_cpus
      x86/irq: Fix move_irq_desc() for nodes without ram

Yoichi Yuasa (1):
      MIPS: MIPSsim: Fix unbalance brace in mipssim get_c0_compare_int()

Zhao Yakui (3):
      drm/I915: Fix offset to DVO timings in LVDS data
      ACPI: Don't treat generic error as ACPI error code in acpi memory h=
otplug driver
      ACPI: Ingore the memory block with zero block size in course of mem=
ory hotplug

Zhenyu Wang (6):
      drm/i915: disable VGA plane reliably
      drm/i915: fix issue in display pipe setup on IGDNG
      drm/i915: Fix channel ending action for DP aux transaction
      drm/i915: enable DisplayPort support on IGDNG
      drm/i915: Add eDP support on IGDNG mobile chip
      drm/i915: fix VGA detect on IGDNG

ling.ma-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org (5):
      drm/i915: hdmi detection according by reading edid
      drm/i915: Set preferred mode for integrated TV according to TV form=
at
      drm/i915: Choose real sdvo output according to result from detectio=
n
      drm/i915: Return disconnected for SDVO DVI when there's no digital =
EDID.
      drm/i915: Add support for dual-channel LVDS on 8xx.

reinette chatre (1):
      iwlagn: fix minimum number of queues setting

roel kluin (6):
      3c515: Write outside array bounds
      ipv4: ARP neigh procfs buffer overflow
      eexpress: Read buffer overflow
      tulip: Read buffer overflow
      s6gmac: Read buffer overflow
      mISDN: Read buffer overflow

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr

--===============5079269748516322817==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============5079269748516322817==--
