From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr annotated tag, v2.6.29-rc6, created. v2.6.29-rc6
Date: Wed, 16 Sep 2009 14:36:43 -0400
Message-ID: <200909161836.n8GIahjx001298@gorgona.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3936261529609628114=="
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

--===============3936261529609628114==
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by smtp1.linux-foundation.org id n8GJ1TaO006529

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The annotated tag, v2.6.29-rc6 has been created
        at  0715562512ca6cf14c1b8f08e09d5907118deaf0 (tag)
   tagging  20f4d6c3a2a23c5d7d9cc7f42fbb943ca7a03d1f (commit)
  replaces  v2.6.29-rc5
 tagged by  Linus Torvalds
        on  Sun Feb 22 20:19:54 2009 -0800

- Log -----------------------------------------------------------------
Linux 2.6.29-rc6
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkmiI/AACgkQF3YsRnbiHLv/eQCbBsy+I+x4hmnyUa2qmeV0vCPE
ViwAnift2Mc0j/7UFHRfpGz7ialRtHdn
=3Do65b
-----END PGP SIGNATURE-----

Adam Baker (1):
      V4L/DVB (10619): gspca - main: Destroy the URBs at disconnection ti=
me.

Adam Lackorzynski (1):
      jsm: additional device support

Al Viro (1):
      Fix incomplete __mntput locking

Alan Jenkins (1):
      PM/hibernate: fix "swap breaks after hibernation failures"

Alex Chiang (3):
      PCI: Documentation: fix minor PCIe HOWTO thinko
      [IA64] Revert "prevent ia64 from invoking irq handlers on offline C=
PUs"
      [IA64] Remove redundant cpu_clear() in __cpu_disable path

Alexey Dobriyan (3):
      kbuild: fix tags generation of config symbols
      mfd: fix sm501 section mismatches
      eeepc: should depend on INPUT

Alexey Starikovskiy (1):
      ACPI: EC: Add delay for slow MSI controller

Alok N Kataria (1):
      x86, vmi: TSC going backwards check in vmi clocksource

Andi Kleen (4):
      kbuild: create the source symlink earlier in the objdir
      x86, mce: reinitialize per cpu features on resume
      x86, mce: use force_sig_info to kill process in machine check
      x86, mce: fix ifdef for 64bit thermal apic vector clear on shutdown

Andrew Vasquez (3):
      [SCSI] qla2xxx: Properly acknowledge IDC notification messages.
      [SCSI] qla2xxx: Mask out 'reserved' bits while processing FLT regio=
ns.
      [SCSI] qla2xxx: Update version number to 8.03.00-k3.

Andrew Victor (2):
      [ARM] 5390/1: AT91: Watchdog fixes
      [ARM] 5391/1: AT91: Enable GPIO clocks earlier

Andrey Borzenkov (1):
      PM: Fix pm_notifiers during user mode hibernation

Aneesh Kumar K.V (3):
      ext4: Fix lockdep warning
      ext4: Initialize preallocation list_head's properly
      ext4: Implement range_cyclic in ext4_da_writepages instead of write=
_cache_pages

Anirban Chakraborty (2):
      [SCSI] qla2xxx: Remove interrupt request bit check in the response =
processing path in multiq mode.
      [SCSI] qla2xxx: Correct slab-error overwrite during vport creation =
and deletion.

Anssi Hannula (1):
      HID: move tmff and zpff devices from ignore_list to blacklist

Arjan van de Ven (4):
      scripts: add x86 register parser to markup_oops.pl
      scripts: add x86 64 bit support to the markup_oops.pl script
      Consolidate driver_probe_done() loops into one place
      PM/resume: wait for device probing to finish

Arve Hj=C3=B8nnev=C3=A5g (2):
      PM: Wait for console in resume
      PM: Fix suspend_console and resume_console to use only one semaphor=
e

Atsushi Nemoto (1):
      atmel_serial might lose modem status change

Avi Kivity (2):
      KVM: Avoid using CONFIG_ in userspace visible headers
      KVM: VMX: Flush volatile msrs before emulating rdmsr

Benjamin Herrenschmidt (1):
      vmalloc: add __get_vm_area_caller()

Bernhard Walle (1):
      Bernhard has moved

Bill Nottingham (1):
      vt: Declare PIO_CMAP/GIO_CMAP as compatbile ioctls.

Bjorn Helgaas (1):
      ACPI: remove CONFIG_ACPI_SYSTEM

Boaz Harrosh (1):
      bsg: Fix sense buffer bug in SG_IO

Brian King (3):
      [SCSI] ibmvfc: Fix command timeout errors
      [SCSI] ibmvfc: Fix rport relogin
      [SCSI] ibmvfc: Increase cancel timeout

Chip Coldwell (1):
      cciss: PCI power management reset for kexec

Chris Ball (1):
      x86, olpc: fix model detection without OFW

Chris Mason (5):
      Btrfs: process mount options on mount -o remount,
      Btrfs: use larger metadata clusters in ssd mode
      Btrfs: don't clean old snapshots on sync(1)
      Btrfs: make a lockdep class for the extent buffer locks
      Btrfs: check file pointer in btrfs_sync_file

Chris Wilson (16):
      drm: Potential use-after-free on error path.
      drm: Free the object ref on error.
      drm/i915: Cleanup trivial leak on execbuffer error path.
      drm/i915: hold mutex for unreference() in i915_gem_tiling.c
      drm/i915: refleak along pin() error path.
      drm: Do not leak a new reference for flink() on an existing name
      drm/i915: Set framebuffer alignment based upon the fence constraint=
s.
      drm/i915: Release and unlock on mmap_gtt error path.
      drm/i915: unpin for an invalid memory domain.
      drm/i915: Unpin the ringbuffer if we fail to ioremap it.
      drm/i915: Unpin the hws if we fail to kmap.
      drm/i915: Unpin the fb on error during construction.
      drm/i915: Cleanup the hws on ringbuffer constrution failure.
      drm: Check for a NULL encoder when reverting on error path
      drm: Propagate failure from setting crtc base.
      drm/i915: Fix regression in 95ca9d

Christian Borntraeger (1):
      [S390] Fix timeval regression on s390

Clemens Ladisch (2):
      sound: usb-audio: fix uninitialized variable with M-Audio MIDI inte=
rfaces
      sound: virtuoso: revert "do not overwrite EEPROM on Xonar D2/D2X"

Dan Carpenter (3):
      ext4: Fix NULL dereference in ext4_ext_migrate()'s error handling
      HID: unlock properly on error paths in hidraw_ioctl()
      sx.c: avoid referencing freed memory if copy_from_user() fails

Dan Williams (1):
      atmel-mci: fix initialization of dma slave data

Dave Hansen (1):
      powerpc/mm: Fix numa reserve bootmem page selection

David Brownell (2):
      omap_hsmmc: card detect irq bugfix
      omap_hsmmc: only MMC1 allows HCTL.SDVS !=3D 1.8V

David Howells (1):
      mn10300: fix oprofile

David Vrabel (1):
      wusb: whci-hcd: always lock whc->lock with interrupts disabled

David Woodhouse (2):
      iommu: fix Intel IOMMU write-buffer flushing
      Fix Intel IOMMU write-buffer flushing

Davide Libenzi (1):
      timerfd: add flags check

Ed Cashin (1):
      aoe: ignore vendor extension AoE responses

Eric Anholt (3):
      drm/i915: Cut two args to set_to_gpu_domain that confused this tric=
ky path.
      drm/i915: Don't let a device flush to prepare buffers clear new wri=
te_domains.
      drm/i915: Retire requests from i915_gem_busy_ioctl.

Eric Biederman (1):
      seq_file: properly cope with pread

Felix Blyakher (2):
      Revert "[XFS] use scalable vmap API"
      Revert "[XFS] remove old vmap cache"

Frank Seidel (1):
      MAINTAINERS: Switch hdaps to Frank Seidel

Frederic Weisbecker (1):
      tracing/function-graph-tracer: trace the idle tasks

Geert Uytterhoeven (1):
      m68k: atari - Rename "mfp" to "st_mfp"

Geoff Levand (1):
      powerpc/ps3: Move ps3_mm_add_memory to device_initcall

Giuseppe Bilotta (2):
      lis3lv02d: support both one- and two-byte sensors
      lis3lv02d: add axes knowledge of HP Pavilion dv5 models

Gregory CLEMENT (1):
      [ARM] 5400/1: Add support for inverted rdy_busy pin for Atmel nand =
device controller

H. Peter Anvin (1):
      x86, mce: remove incorrect __cpuinit for mce_cpu_features()

Hannes Reinecke (1):
      block: fix deadlock in blk_abort_queue() for drivers that readd to =
timeout list

Hans Verkuil (2):
      V4L/DVB (10625): ivtv: fix decoder crash regression
      V4L/DVB (10626): ivtv: fix regression in get sliced vbi format

Hans de Goede (1):
      hwmon: Fix ACPI resource check error handling

Hartley Sweeten (1):
      [ARM] 5405/1: ep93xx: remove unused gesbc9312.h header

Heiko Carstens (1):
      [S390] fix "mem=3D" handling in case of standby memory

Helmut Schaa (1):
      sdhci: fix led naming

Herbert Xu (1):
      crypto: lrw - Fix big endian support

Igor Mammedov (1):
      [CIFS] Prevent OOPs when mounting with remote prefixpath.

Ilpo J=C3=A4rvinen (1):
      sx.c: fix dbl statement if - add missing braces

Ingo Molnar (5):
      sched: cpu hotplug fix
      inotify: fix GFP_KERNEL related deadlock
      Merge branch 'tip/tracing/urgent' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/rostedt/linux-2.6-trace into tracing/urgent
      x86: use the right protections for split-up pagetables
      PM: Split up sysdev_[suspend|resume] from device_power_[down|up], f=
ix

Isaku Yamahata (1):
      [IA64] fixes configs and add default config for ia64 xen domU

James Smart (1):
      [SCSI] scsi_scan: add missing interim SDEV_DEL state if slave_alloc=
 fails

Jan Kara (3):
      jbd2: Fix return value of jbd2_journal_start_commit()
      Revert "ext4: wait on all pending commits in ext4_sync_fs()"
      jbd2: Avoid possible NULL dereference in jbd2_journal_begin_ordered=
_truncate()

Jean Delvare (2):
      mfd: terminate pcf50633 i2c_device_id list
      hwmon: (f71882fg) Hide misleading error message

Jean Pihet (2):
      omap_hsmmc: recover from transfer failures
      omap_hsmmc: Change while(); loops with finite version

Jeff Layton (3):
      cifs: refactor new_inode() calls and inode initialization
      cifs: properly handle case where CIFSGetSrvInodeNumber fails
      cifs: posix fill in inode needed by posix open

Jeff Mahoney (2):
      Btrfs: balance_level checks !child after access
      Btrfs: remove btrfs_init_path

Jens Axboe (2):
      block: fix bad definition of BIO_RW_SYNC
      block: revert part of 18ce3751ccd488c78d3827e9f6bf54e6322676fb

Jeremy Fitzhardinge (2):
      x86/cpa: make sure cpa is safe to call in lazy mmu mode
      x86/paravirt: make arch_flush_lazy_mmu/cpu disable preemption

Jesse Barnes (4):
      drm/i915: take struct mutex around fb unref
      drm/i915: Keep refs on the object over the lifetime of vmas for GTT=
 mmap.
      drm/i915: suspend/resume GEM when KMS is active
      drm/i915: fix WC mapping in non-GEM i915 code.

Jiri Slaby (3):
      HID: fix bus endianity in file2alias
      x86_64: acpi/wakeup_64 cleanup
      x86_64: Fix S3 fail path

Johannes Weiner (3):
      slab: introduce kzfree()
      swsusp: dont fiddle with swappiness
      swsusp: clean up shrink_all_zones()

Joris van Rantwijk (1):
      ALSA: usb-audio - Workaround for misdetected sample rate with CM620=
7

Josef Bacik (1):
      Btrfs: make sure all pending extent operations are complete

Josh Hunt (1):
      kbuild: add vmlinux to kernel rpm

Julia Lawall (3):
      [SCSI] lpfc: introduce missing kfree
      Btrfs: fs/btrfs/volumes.c: remove useless kzalloc
      mfd: Fix egpio kzalloc return test

KAMEZAWA Hiroyuki (2):
      mm: clean up for early_pfn_to_nid()
      mm: fix memmap init for handling memory hole

Kristian H=C3=B8gsberg (5):
      drm: Release user fbs in drm_release
      drm: Add locking around cursor gem operations.
      drm: Bring PLL limits in sync with DDX values.
      drm: Collapse identical i8xx_clock() and i9xx_clock().
      drm: Use spread spectrum when the bios tells us it's ok.

Krzysztof Helt (1):
      fbdev/drm: fix Kconfig submenu mess in "Graphics support"

Len Brown (1):
      Merge branches 'release', 'bugzilla-12011', 'bugzilla-12632', 'misc=
' and 'suspend' into release

Li Zefan (4):
      cgroups: update documentation about css_set hash table
      cgroups: fix possible use after free
      README: fix a wrong filename
      cpuset: various documentation fixes and updates

Linus Torvalds (41):
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/rusty/linux-2.6=
-for-linus
      Merge branch 'kvm-updates/2.6.29' of git://git.kernel.org/pub/scm/v=
irt/kvm/kvm
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tytso/ext4
      Merge branch 'for-upstream' of git://git.kernel.org/pub/scm/linux/k=
ernel/git/dvrabel/uwb
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/wim/linux-2.6-w=
atchdog
      Merge branch 'for-linus' of git://git.o-hand.com/linux-mfd
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jikos/hid
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/mchehab/linux-2.6
      Merge branch 'hwmon-for-linus' of git://jdelvare.pck.nerim.net/jdel=
vare-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/sam/kbuild-fixe=
s
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/jgarzik/libata-dev
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/mason/btrfs-uns=
table
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/herbert/crypto-=
2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jbarnes/pci-2.6
      Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/benh/powerpc
      Merge branch 'core-fixes-for-linus' of git://git.kernel.org/pub/scm=
/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'tracing-fixes-for-linus' of git://git.kernel.org/pub/=
scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'timers-fixes-for-linus' of git://git.kernel.org/pub/s=
cm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'sched-fixes-for-linus' of git://git.kernel.org/pub/sc=
m/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/drzeus/mmc
      Merge branch 'for-linus' of git://git.kernel.dk/linux-2.6-block
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge branch 'for-linus' of git://git390.marist.edu/pub/scm/linux-2=
.6
      Merge branch 'tracing-fixes-for-linus' of git://git.kernel.org/pub/=
scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge master.kernel.org:/home/rmk/linux-2.6-arm
      Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel=
/git/aegl/linux-2.6
      Merge branch 'for-linus' of git://oss.sgi.com/xfs/xfs
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/mason/btrfs-uns=
table
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/jejb/scsi-rc-fi=
xes-2.6
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'drm-fixes' of git://git.kernel.org/pub/scm/linux/kern=
el/git/airlied/drm-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/sfrench/cifs-2.=
6
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'hibernate'
      Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel=
/git/lenb/linux-acpi-2.6
      x86: Add IRQF_TIMER to legacy x86 timer interrupt descriptors
      Merge branch 'core/urgent' of git://git.kernel.org/pub/scm/linux/ke=
rnel/git/tip/linux-2.6-tip
      Merge branch 'drm-fixes' of git://git.kernel.org/pub/scm/linux/kern=
el/git/airlied/drm-2.6
      Linux 2.6.29-rc6

Luca Bigliardi (1):
      uml: fix vde network backend in user mode linux

Makito SHIOKAWA (1):
      [ARM] 5404/1: Fix condition in arm_elf_read_implies_exec() to set R=
EAD_IMPLIES_EXEC

Marcelo Tosatti (4):
      KVM: mmu_notifiers release method
      KVM: PIT: fix i8254 pending count read
      KVM: x86: disable kvmclock on non constant TSC hosts
      KVM: x86: fix LAPIC pending count calculation

Mark Brown (5):
      mfd: Initialise WM8350 interrupts earlier
      mfd: Improve diagnostics for WM8350 ID register probe
      mfd: Mark WM835x USB_SLV_500MA bit as accessible
      mfd: Fix TWL4030 build on some ARM variants
      mfd: Ensure all WM8350 IRQs are masked at startup

Mark McLoughlin (1):
      KVM: Fix assigned devices circular locking dependency

Markus Metzger (1):
      x86, ptrace, mm: fix double-free on race

Martin Peschke (1):
      [SCSI] sg: fix device number in blktrace data

Matthew Wilcox (1):
      PCI/MSI: fix msi_mask() shift fix

Mauro Carvalho Chehab (3):
      V4L/DVB (10527): tuner: fix TUV1236D analog/digital setup
      V4L/DVB (10572): Revert commit dda06a8e4610757def753ee3a541a0b1a1fe=
b36b
      8250: fix boot hang with serial console when using with Serial Over=
 Lan port

Michael Buesch (2):
      spi-gpio: sanitize MISO bitvalue
      spi_bitbang: add more lowlevel function documentation

Michael Neuling (2):
      powerpc/vsx: Fix VSX alignment handler for regs 32-63
      bootgraph: fix for use with dot symbols

Michael Tokarev (1):
      HID: blacklist Powercom USB UPS

Mike Christie (1):
      [SCSI] libiscsi: Fix scsi command timeout oops in iscsi_eh_timed_ou=
t

Mike Frysinger (1):
      kbuild,setlocalversion: shorten the make time when using svn

Mike Murphy (2):
      PATCH [1/2] Documentation/driver-model/device.txt: fix struct devic=
e_attribute
      PATCH [2/2] Documentation/filesystems/sysfs.txt: fix descriptions o=
f device attributes

Neil Brown (1):
      block: fix booting from partitioned md array

Nick Piggin (1):
      mm: task dirty accounting fix

Nicolas Pitre (2):
      [ARM] 5401/1: Orion: fix edge triggered GPIO interrupt support
      [ARM] 5402/1: fix a case of wrap-around in sanity_check_meminfo()

Paul E. McKenney (1):
      x86, rcu: fix strange load average and ksoftirqd behavior

Paul Moore (2):
      cipso: Fix documentation comment
      selinux: Fix the NetLabel glue code for setsockopt()

Paul Turner (1):
      vfs: separate FMODE_PREAD/FMODE_PWRITE into separate flags

Pavel Machek (2):
      Pavel has moved
      hp accelerometer: add freefall detection

Pekka Paalanen (3):
      mmiotrace: count events lost due to not recording
      trace: mmiotrace to the tracer menu in Kconfig
      doc: mmiotrace.txt, buffer size control change

Peter Oberparleiter (1):
      [S390] sclp: handle empty event buffers

Peter Zijlstra (3):
      futex: fix reference leak
      timers: more consistently use clock vs timer
      fs/super.c: add lockdep annotation to s_umount

Philipp Zabel (1):
      mfd: fix htc-egpio iomem resource handling using resource_size

Philippe De Muyter (1):
      floppy: request and release only the ports we actually use

Philippe Gerum (1):
      powerpc/mm: Fix _PAGE_CHG_MASK to protect _PAGE_SPECIAL

Pierre Ossman (1):
      Revert "sdhci: force high speed capability on some controllers"

Pierre Willenbrock (1):
      drm/i915: Add missing mutex_lock(&dev->struct_mutex)

Qinghuang Feng (1):
      Btrfs: remove unused code in split_state()

Rabin Vincent (2):
      kbuild: add sys_* entries for syscalls in tags
      mmc_test: fix basic read test

Rafael J. Wysocki (4):
      USB/PCI: Fix resume breakage of controllers behind cardbus bridges
      pm: fix build for CONFIG_PM unset
      PM: fix build for CONFIG_PM unset
      PM: Split up sysdev_[suspend|resume] from device_power_[down|up]

Rakib Mullick (1):
      mfd: Fix sm501_register_gpio section mismatch

Randy Dunlap (7):
      PCI: fix rom.c kernel-doc warning
      PCI: fix struct pci_platform_pm_ops kernel-doc
      PCI: fix missing kernel-doc and typos
      x86: dell-laptop: depends on POWER_SUPPLY
      docsrc: use config instead of menuconfig
      docbook: split kernel-api for device-drivers
      acpi/doc: add missing param value

Richard Hughes (1):
      battery: don't assume we are fully charged when not charging or dis=
charging

Robert Jennings (1):
      [SCSI] ibmvscsi: Correct DMA mapping leak

Robin Holt (1):
      [IA64] bte_copy of BTE_MAX_XFER trips BUG_ON.

Roel Kluin (4):
      mfd: wm8350 tries reaches -1
      FRV: __pte_to_swp_entry doesn't expand correctly
      paride/pg.c: xs(): &&/|| confusion
      [ARM] 5403/1: pxa25x_ep_fifo_flush() *ep->reg_udccs always set to 0

Roland Dreier (1):
      drm/i915: Fix potential AB-BA deadlock in i915_gem_execbuffer()

Russell King (3):
      [ARM] omap: fix omap2_divisor_to_clksel() error return value
      [ARM] omap: fix _omap2_clksel_get_src_field()
      [ARM] omap: fix clock reparenting in omap2_clk_set_parent()

Rusty Russell (2):
      cpumask: fix powernow-k8: partial revert of 2fdf66b491ac70665794644=
2789ec644cc317e1a
      cpumask: Use cpu_*_mask accessors code: alpha

Sergei Shtylyov (1):
      libata-sff: fix 32-bit PIO ATAPI regression

Sheng Yang (4):
      KVM: Add kvm_arch_sync_events to sync with asynchronize events
      KVM: Fix racy in kvm_free_assigned_irq
      KVM: MMU: Map device MMIO as UC in EPT
      KVM: Fix INTx for device assignment

Shyam_Iyer-DYMqY+WieiM@public.gmane.org (1):
      [SCSI] qla2xxx: fix Kernel Panic with Qlogic 2472 Card.

Steve Aarnio (1):
      drm/i915: Don't add panel_fixed_mode to the probed modes list at LV=
DS init.

Steve French (5):
      [CIFS] ipv6_addr_equal for address comparison
      Merge branch 'master' of /pub/scm/linux/kernel/git/torvalds/linux-2=
.6
      [CIFS] Fix oops in cifs_strfromUCS_le mounting to servers which do =
not specify their OS
      [CIFS] improve posix semantics of file create
      [CIFS] Fix multiuser mounts so server does not invalidate earlier s=
ecurity contexts

Steven Rostedt (3):
      tracing: disable tracing while testing ring buffer
      tracing: have function trace select kallsyms
      tracing: limit the number of loops the ring buffer self test can ma=
ke

Subhash Peddamallu (1):
      fs/bio: bio_alloc_bioset: pass right object ptr to mempool_free

Suresh Siddha (1):
      x86, pat: fix warn_on_once() while mapping 0-1MB range with /dev/me=
m

Takashi Iwai (6):
      Revert "Sound: hda - Restore PCI configuration space with interrupt=
s off"
      ALSA: usb-audio - Fix non-continuous rate detection
      ALSA: jack - Use card->shortname for input name
      Merge branch 'fix/hda' into for-linus
      Merge branch 'fix/misc' into for-linus
      Merge branch 'fix/usb-audio' into for-linus

Tejun Heo (2):
      sata_nv: give up hardreset on nf2
      vmalloc: call flush_cache_vunmap() from unmap_kernel_range()

Thomas Gleixner (3):
      x86: warn if arch_flush_lazy_mmu_cpu is called in preemptible conte=
xt
      x86: CPA avoid repeated lazy mmu flush
      x86, vm86: fix preemption bug

Tobias Klauser (1):
      drm/i915: Storage class should be before const qualifier

Tobias Lorenz (2):
      V4L/DVB (10532): Correction of Stereo detection/setting and signal =
strength indication
      V4L/DVB (10533): fix LED status output

Tony Luck (2):
      [IA64] Build fix for __early_pfn_to_nid() undefined link error
      [IA64] xen_domu build fix

Tony Vroon (1):
      fujitsu-laptop: Use RFKILL support bitmask from firmware

Trent Piepho (1):
      V4L/DVB (10516a): zoran: Update MAINTAINERS entry

Wei Yongjun (2):
      ext4: Fix to read empty directory blocks correctly in 64k
      mn10300: fix typo && -> || in arch/mn10300/unit-asb2305/pci.c

Wim Van Sebroeck (1):
      [WATCHDOG] iTCO_wdt: fix SMI_EN regression 2

Yan Zheng (2):
      Btrfs: Avoid using __GFP_HIGHMEM with slab allocator
      Btrfs: hold trans_mutex when using btrfs_record_root_in_trans

Yang Hongyang (1):
      atyfb: remove unused local variable `pwr_command'

Yang Zhang (1):
      KVM: ia64: fix fp fault/trap handler

Yauhen Kharuzhy (1):
      s3cmci: Fix hangup in do_pio_write()

Yi Li (1):
      MMC: fix bug - SDHC card capacity not correct

Zachary Amsden (1):
      MAINTAINERS: paravirt-ops maintainers update

Zlatko Calusic (1):
      Add support for VT6415 PCIE PATA IDE Host Controller

etienne (1):
      drm/radeon: update sarea copies of last_ variables on resume.

john stultz (1):
      x86, hpet: fix for LS21 + HPET =3D boot hang

wanzongshun (1):
      [ARM] 5398/1: Add Wan ZongShun to MAINTAINERS for W90P910

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr

--===============3936261529609628114==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============3936261529609628114==--
