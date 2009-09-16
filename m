From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr annotated tag, v2.6.30-rc2, created. v2.6.30-rc2
Date: Wed, 16 Sep 2009 14:36:48 -0400
Message-ID: <200909161836.n8GIamBp001401@gorgona.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2451863627610355280=="
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

--===============2451863627610355280==
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by smtp1.linux-foundation.org id n8GJI03f007935

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The annotated tag, v2.6.30-rc2 has been created
        at  7c941a7798a5169ee0dd69a9e8d5c40ceb702023 (tag)
   tagging  0882e8dd3aad33eca41696d463bb896e6c8817eb (commit)
  replaces  v2.6.30-rc1
 tagged by  Linus Torvalds
        on  Tue Apr 14 13:51:57 2009 -0700

- Log -----------------------------------------------------------------
Linux 2.6.30-rc2
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAknk93IACgkQF3YsRnbiHLsSswCfQBrEK/y19fyOzKkWfg1iIuAo
TDcAn3SOvXSDAcWbFSGzzFgRw7wbf+rn
=3DetoF
-----END PGP SIGNATURE-----

Adrian McMenamin (1):
      Input: add support for the Maple mouse on the SEGA Dreamcast

Alan Cox (5):
      x86: DMI match for the Dell DXP061 as it needs BIOS reboot
      tty: MAX3100
      cdc-acm: Fix long standing abuse of tty->low_latency
      tty: Fix leak in ti-usb
      parport: Fix various uses of parport_pc

Alasdair G Kergon (3):
      dm: rearrange dm_wq_work
      dm: split DMF_BLOCK_IO flag into two
      dm: simplify dm_request loop

Alex Nixon (1):
      Xen: Add virt_to_pfn helper function

Alex Riesen (1):
      netfilter: fix selection of "LED" target in netfilter

Alexander Beregalov (1):
      befs: fix build on parisc

Alexander Duyck (2):
      igbvf: add new driver to support 82576 virtual functions
      igb: remove sysfs entry that was used to set the number of vfs

Alexey Dobriyan (1):
      aio: remove INIT_KIOCTX

Andi Kleen (2):
      asm-generic/siginfo.h: update NSIGTRAP definition
      kernel/sys.c: clean up sys_shutdown exit path

Andrea Righi (2):
      fbdev: fix info->lock deadlock in fbcon_event_notify()
      res_counter: update documentation

Andrew Morton (2):
      work_on_cpu(): rewrite it to create a kernel thread on demand
      cpufreq: use smp_call_function_[single|many]() in acpi-cpufreq.c

Andy Grover (2):
      x86: Document get_user_pages_fast()
      mm: document get_user_pages_fast()

Andy Whitcroft (1):
      Input: psmouse - add newline to OLPC HGPK touchpad debugging

Atsushi Nemoto (3):
      tx4939ide: remove wmb()
      tx493[89]ide: Remove big endian version of tx493[89]ide_tf_{load,re=
ad}
      tx4939ide: Fix tx4939ide_{in,out}put_data_swap argument

Balaji Rao (2):
      pcf50633_charger: Enable periodic charging restart
      pcf50633_charger: Remove unused mbc_set_status function

Bartlomiej Zolnierkiewicz (3):
      ide-cd: convert cdrom_decode_status() to use switch statements
      ide-cd: unify handling of fs and pc requests in cdrom_decode_status=
()
      ide-cd: fix intendation in cdrom_decode_status()

Bastian Blank (1):
      bnx2: Don't use reserved names

Ben Gamari (1):
      drm/i915: Implement batch and ring buffer dumping

Ben Hutchings (1):
      i2c: Fix sparse warnings for I2C_BOARD_INFO()

Bharata B Rao (3):
      cpuacct: make cpuacct hierarchy walk in cpuacct_charge() safe when =
rcupreempt is used -v2
      cpuacct: add per-cgroup utime/stime statistics
      memcg: fix documentation

Bjorn Helgaas (7):
      ACPI: thermal: use .notify method instead of installing handler dir=
ectly
      ACPI: video: use .notify method instead of installing handler direc=
tly
      fujitsu-laptop: use .notify method instead of installing handler di=
rectly
      fujitsu-laptop: use .notify method instead of installing hotkey han=
dler directly
      panasonic-laptop: use .notify method instead of installing handler =
directly
      sony-laptop: use .notify method instead of installing handler direc=
tly
      ACPI: WMI: use .notify method instead of installing handler directl=
y

Borislav Petkov (5):
      ide-cd: move status checking into the IRQ handler
      ide-cd: carve out an ide_cd_breathe()-helper for fs write requests
      ide-cd: respect REQ_QUIET for fs requests in cdrom_decode_status()
      ide-cd: update debugging support
      ide-cd: reverse NOT_READY sense key logic

Chien Tung (3):
      RDMA/nes: Fix SFP+ PHY initialization
      RDMA/nes: Add wide_ppm_offset parm for switch compatibility
      RDMA/nes: Add support for new SFP+ PHY

Dan Carpenter (1):
      niu: Fix error handling

Daniel Mack (3):
      Input: generic driver for rotary encoders on GPIOs
      [ARM] pxa/colibri: provide MAC address from ATAG_SERIAL
      [ARM] pxa/colibri: get rid of set_irq_type()

Daniel Mierswa (2):
      Input: atkbd - consolidate force release quirk setup
      Input: atkbd - add quirk for Fujitsu Siemens Amilo PA 1510

Darren Hart (1):
      futex: comment requeue key reference semantics

Dave Anderson (1):
      hfs: fix memory leak when unmounting

Dave Chinner (9):
      xfs: validate log feature fields correctly
      xfs: fix double free of inode
      xfs: prevent unwritten extent conversion from blocking I/O completi=
on
      xfs: inform the xfsaild of the push target before sleeping
      xfs: use xfs_sync_inodes() for device flushing
      xfs: make inode flush at ENOSPC synchronous
      xfs: block callers of xfs_flush_inodes() correctly
      xfs: flush delayed allcoation blocks on ENOSPC in create
      xfs: remove xfs_flush_space

David Brownell (2):
      leds: just ignore invalid GPIOs in leds-gpio
      spi: spi_write_then_read() bugfixes

David Howells (11):
      keys: Handle there being no fallback destination keyring for reques=
t_key()
      FRV: Use <asm-generic/pgtable.h> in NOMMU mode
      MN10300: Kill MN10300's own profiling Kconfig
      FRV: Fix indentation errors to keep git-am happy when moving arch h=
eader files
      FRV: Move to arch/frv/include/asm/
      Move arch headers from include/asm-mn10300/ to arch/mn10300/include=
/asm/.
      Separate out the proc- and unit-specific header directories from th=
e general
      kbuild: make it possible for the linker to discard local symbols fr=
om vmlinux
      mm: point the UNEVICTABLE_LRU config option at the documentation
      mm: reformat the Unevictable-LRU documentation
      Fix lpfc_parse_bg_err()'s use of do_div()

David S. Miller (9):
      sparc64: get_cells() can't be marked __init
      sparc64: Fix section mismatch warnings in power driver.
      sparc64: Fix section mismatch warnings in PCI controller drivers.
      sparc: Fix section mismatch warnings in cs4231 sound driver.
      serial: sunsu: sunsu_kbd_ms_init needs to be __devinit
      sparc64: add_node_ranges() must be __init
      sparc: Hook up sys_preadv and sys_pwritev
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/kaber/nf-2.6
      niu: Fix unused variable warning.

David Woodhouse (8):
      Revert "fix modules_install via NFS"
      Partially revert "V4L/DVB (9533): cx88: Add support for TurboSight =
TBS8910 DVB-S PCI card"
      firmware/WHENCE: Add missing origin information for Ambassador atms=
ar11.fw
      firmware: Remove newly-added slicoss and sxg firmware images
      Add README.AddingFirmware file. Basically telling people not to.
      x86, intel-iommu: fix X2APIC && !ACPI build failure
      qla1280: Fix off-by-some error in firmware loading.
      intel-iommu: Avoid panic() for DRHD at address zero.

Dmitry Eremin-Solenikov (1):
      [ARM] pxa/csb701: do not register devices on non-csb726 boads

Dmitry Torokhov (5):
      Merge commit 'v2.6.29-rc7' into next
      Input: fix polling of /proc/bus/input/devices
      Input: arrange drivers/input/misc/Makefile in alphabetical order
      Input: i8042 - add HP DV9700 to the noloop list
      Merge branch 'next' into for-linus

Don Wood (1):
      RDMA/nes: Fix incorrect casts on 32-bit architectures

Eric Anholt (2):
      drm/i915: Correctly set the write flag for get_user_pages in pread.
      drm/i915: Allow tiling of objects with bit 17 swizzling by the CPU.

Eric Dumazet (1):
      netfilter: ip6tables regression fix

Eric Sandeen (1):
      include/linux/fiemap.h: include types.h now that it's exported

Faisal Latif (2):
      RDMA/nes: Fix error handling issues
      RDMA/nes: Fix nes_nic_cm_xmit() error handling

Felix Blyakher (1):
      Merge branch 'master' into for-linus

Fenghua Yu (1):
      Intel-IOMMU Alignment Issue in dma_pte_clear_range()

Ferenc Wagner (1):
      drm/i915: indicate framebuffer restore key in SysRq help message

Florian Fainelli (1):
      r6040: set MODULE_VERSION

Florian Mickler (1):
      drm/i915: Fix use of uninitialized var in 40a5f0de

Francesco VIRLINZI (1):
      sh: intc: Added resume from hibernation support to the intc

Frederic Weisbecker (3):
      tracing/syscalls: use a dedicated file header
      lockdep: warn about lockdep disabling after kernel taint
      lockdep: continue lock debugging despite some taints

From: Thiemo Nagel (1):
      ext4: check block device size on mount

Gautham R Shenoy (1):
      sched: Print sched_group::__cpu_power in sched_domain_debug

Geert Uytterhoeven (5):
      ide: Fix host drivers that need IRQF_SHARED
      ide: falconide/q40ide - Use __ide_mm_{in,out}sw() for data
      namespaces: move get_mq() inside #ifdef CONFIG_SYSCTL
      at24: make input buffers of at24_*write() const
      at25: make input buffers of at25_*write() const

Grant Grundler (1):
      ide: remove wmb() from ide-dma-sff.c and scc_pata.c

Grant Likely (1):
      xsysace: Fix dereferencing of cf_id after hd_driveid removal

H. Peter Anvin (1):
      x86, setup: un-resequence mode setting for VGA 80x34 and 80x60 mode=
s

Hannes Eder (2):
      NULL noise: drivers/platform/x86/panasonic-laptop.c
      NULL noise: arch/x86/xen/smp.c

Heiko Carstens (1):
      mutex: have non-spinning mutexes on s390 by default

Helge Deller (1):
      Input: hilkbd - fix crash when removing hilkbd module

Herbert Xu (1):
      module: try_then_request_module must wait

Hidetoshi Seto (2):
      posixtimers, sched: Fix posix clock monotonicity
      x86: smarten /proc/interrupts output for new counters

Huang Weiyi (5):
      ACPI: cpufreq: remove dupilcated #include
      ide: remove unused #include <linux/version.h>
      hp_accel: remove unused #include <version.h>
      sysrq: remove duplicated #include
      microblaze: remove duplicated #include's

Hugh Dickins (2):
      shmem: respect MAX_LFS_FILESIZE
      x86 microcode: revert some work_on_cpu

Ian Campbell (2):
      xen: resume interrupts before system devices.
      xen: honour VCPU availability on boot

Ingo Molnar (5):
      Merge commit 'v2.6.30-rc1' into core/urgent
      Merge commit 'v2.6.30-rc1' into sched/urgent
      sched: refresh MAINTAINERS entry
      Merge commit 'v2.6.30-rc1' into x86/urgent
      lockdep: warn about lockdep disabling after kernel taint, fix

Jan Beulich (1):
      kbuild: remove pointless strdup() on arguments passed to new_module=
() in modpost

Jan Dumon (1):
      MAINTAINERS: switch maintainer of the hso driver

Jan Kara (3):
      ext3: Try to avoid starting a transaction in writepage for data=3Dw=
ritepage
      jbd: update locking coments
      ext2: fix data corruption for racing writes

Jarkko Lavinen (2):
      mmc: Accept EXT_CSD rev 1.3 since it is backwards compatible with 1=
.2
      omap_hsmmc: Do not expect cmd/data to be non-null when CC/TC occurs

Jaswinder Singh (2):
      firmware: convert av7110 driver to request_firmware()
      Remove fdump tool for av7110 firmware

Jaswinder Singh Rajput (1):
      x86: cpu_debug remove execute permission

Jean Delvare (6):
      ACPI: Adjust Kelvin offset to match local implementation
      i2c-algo-pca: Fix use of uninitialized variable in debug message
      i2c-voodoo3: Deprecate in favor of tdfxfb
      i2c: Let new-style drivers implement attach_adapter
      MAINTAINERS: bluesmoke-devel list is moderated for non-subscribers
      edac: use to_delayed_work()

Jeff Garzik (1):
      [libata] sata_via: kill uninit'd var warning

Jeff Haran (1):
      edac: fix local pci_write_bits32

Jeremy Fitzhardinge (13):
      xen: disable preempt for leave_lazy_mmu
      xen: separate p2m allocation from setting
      xen: split construction of p2m mfn tables from registration
      xen: clean up xen_load_gdt
      xen: make xen_load_gdt simpler
      xen: remove xen_load_gdt debug
      xen: mask XSAVE from cpuid
      x86-64: remove PGE from must-have feature list
      xen/mmu: some early pagetable cleanups
      xen/mmu: weaken flush_tlb_other test
      xen: set _PAGE_NX in __supported_pte_mask before pagetable construc=
tion
      xen: clean up gate trap/interrupt constants
      xen: add FIX_TEXT_POKE to fixmap

Joe Perches (20):
      Add scripts/get_maintainer.pl
      MAINTAINERS - Add file patterns
      MAINTAINERS - Standardize style
      MAINTAINERS - Remove HP Fibre Channel HBA no longer in tree
      MAINTAINERS - standardize "T:       git urls"
      MAINTAINERS - Add Linus Torvalds' git
      MAINTAINERS - i2c_tiny_usb T: should be W:
      MAINTAINERS - Update FPU Emulator contact address and web page
      MAINTAINERS - Remove x86/Voyager no longer in tree
      MAINTAINERS - Remove cyblafb frame buffer no longer in tree
      MAINTAINERS - Coalesce sections "DVB" and "Video for Linux"
      MAINTAINERS - Update M68K patterns
      MAINTAINERS - Update DRIVER CORE patterns
      MAINTAINERS - Add missing "/" to some pattern directories
      MAINTAINERS - Add additional patterns
      MAINTAINERS - Update Freescale sound patterns
      scripts/get_maintainer.pl - Allow multiple files on command line
      MAINTAINERS - Update frv arch patterns
      MAINTAINERS - Update MN10300 patterns
      include/video/cyblafb.h: remove it, it's unused

Johannes Berg (1):
      Input: stop autorepeat timer on key release

Jonathan Cameron (1):
      hwmon: sht15 humidity sensor driver

Justin Waters (2):
      [ARM] 5445/1: AT91: Remove flexible array from USBH platform data
      [ARM] 5446/1: ohci-at91: Limit vbus_pin assignment to the size of t=
he array

KAMEZAWA Hiroyuki (1):
      memcg: remove warning when CONFIG_DEBUG_VM=3Dn

Kevin Hilman (1):
      omap_hsmmc: Flush posted write to IRQ

Kirill Smelkov (1):
      kbuild: fix a few typos in top-level Makefile

Krzysztof Helt (1):
      cirrusfb: do not allow unsupported pixel depth

Kuninori Morimoto (4):
      sh: urquell: Add board comment
      sh: urquell: Fix up address mapping in board comments.
      sh: ap325: use edge control for ov772x camera
      sh: sh7786: modify usb setup timeout judgment bug.

Lai Jiangshan (4):
      tracing: disable seeking for trace_pipe_raw
      tracing: allocate page when needed
      tracing: update file->f_pos when splice(2) it
      tracing: fix splice return too large

Leandro Dorileo (1):
      tty: Update some of the USB kernel doc

Len Brown (3):
      ACPI: delete acpi_device.g_list
      ACPICA: delete check for AML access to port 0x81-83
      Merge branches 'release', 'APERF', 'ARAT', 'misc', 'kelvin', 'devic=
e-lock' and 'bjorn.notify' into release

Lennert Buytenhek (1):
      mv643xx_eth: don't reset the rx coal timer on interface up

Li Zefan (8):
      blktrace: pass the right pointer to kfree()
      tracing: consolidate documents
      tracing: fix document references
      tracing/filters: NIL-terminate user input filter
      tracing/filters: fix NULL pointer dereference
      tracing/filters: allow user input integer to be oct or hex
      tracing/filters: return proper error code when writing filter file
      Documentation/sysctl/net.txt: fix a typo

Linus Torvalds (48):
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/drzeus/mmc
      Merge master.kernel.org:/home/rmk/linux-2.6-arm
      Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel=
/git/lenb/linux-acpi-2.6
      Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel=
/git/aegl/linux-2.6
      Merge branch 'ext3-latency-fixes' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/tytso/ext4
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jmorris/security-testing-2.6
      Merge git://git.infradead.org/battery-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/rusty/linux-2.6=
-for-linus
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/agk/linux-2.6-d=
m
      Merge branches 'core-fixes-for-linus', 'irq-fixes-for-linus' and 't=
imers-fixes-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/t=
ip/linux-2.6-tip
      Merge branch 'sched-fixes-for-linus' of git://git.kernel.org/pub/sc=
m/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'tracing-fixes-for-linus' of git://git.kernel.org/pub/=
scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tytso/ext4
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/roland/infiniband
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/bart/ide-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-=
2.6-frv
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-=
2.6-mn10300
      Merge git://git.infradead.org/~dwmw2/firmware-2.6
      Remove stale include/asm-mn10300/.gitignore file
      async: Fix module loading async-work regression
      Revert "ACPI battery: fix async boot oops"
      Merge branch 'for-linus' of git://git.monstr.eu/linux-2.6-microblaz=
e
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/wim/linux-2.6-w=
atchdog
      Merge branch 'for-linus' of git://git.o-hand.com/linux-rpurdie-leds
      Merge branch 'core-fixes-for-linus' of git://git.kernel.org/pub/scm=
/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'gm_20090410' of git://repo.or.cz/linux-2.6/trivial-mo=
ds
      Merge branch 'i2c-for-linus' of git://jdelvare.pck.nerim.net/jdelva=
re-2.6
      Merge branch 'core-fixes-for-linus' of git://git.kernel.org/pub/scm=
/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'tracing-fixes-for-linus' of git://git.kernel.org/pub/=
scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge git://git.infradead.org/iommu-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/dtor/input
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/jgarzik/libata-dev
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/sam/kbuild-fixe=
s
      Merge branch 'for-linus' of git://oss.sgi.com/xfs/xfs
      Merge branch 'for-rc1/xen/core' of git://git.kernel.org/pub/scm/lin=
ux/kernel/git/jeremy/xen
      Fix quilt merge error in acpi-cpufreq.c
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jmorris/security-testing-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/lethal/sh-2.6
      Merge branch 'fixes-for-linus' of git://git.monstr.eu/linux-2.6-mic=
roblaze
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/ryusuke/nilfs2
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/mszeredi/fuse
      Merge branch 'core-fixes-for-linus' of git://git.kernel.org/pub/scm=
/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'drm-intel-next' of git://git.kernel.org/pub/scm/linux=
/kernel/git/anholt/drm-intel
      Linux 2.6.30-rc2

Linus Walleij (1):
      [ARM] 5447/1: Add SZ_32K

Ma Ling (1):
      drm/i915: sync hdmi detection by hdmi identifier with 2D

Marcin Slusarz (1):
      x86: fix wrong section of pat_disable & make it static

Marek Vasut (4):
      [ARM] pxa: Palm Tungsten E2 basic support
      [ARM] pxa: PalmTE2 support for battery, UDC, IrDA and backlight
      [ARM] pxa: Add support for suspend on PalmTX, T5 and LD
      [ARM] pxa/cm-x2xx: fix ucb1400 not being registered

Mark Brown (3):
      Input: wm97xx - use disable_irq_nosync() for Mainstone
      Input: add accelerated touchscreen support for Marvell Zylonite
      [ARM] pxa: register AC97 controller devices

Martin K. Petersen (1):
      dm: add integrity support

Masami Hiramatsu (2):
      x86: fix set_fixmap to use phys_addr_t
      x86: fix set_fixmap to use phys_addr_t

Matthew Garrett (1):
      efifb: exit if framebuffer address is invalid

Maxime Bizon (1):
      kbuild: fix spurious initramfs rebuild

Michael Ellerman (1):
      mm: add documentation describing what tsk->active_mm means vs tsk->=
mm

Michael Hennerich (3):
      Input: bf54x-keys - fix typo in warning
      Input: add AD7877 touchscreen driver
      Input: add AD7879 Touchscreen driver

Michal Januszewski (5):
      fbdev: fix color component field length documentation
      uvesafb: fix color component length for pseudocolor modes
      s3fb: fix color component length for pseudocolor modes
      sa1100fb: fix color component length for pseudocolor modes
      sisfb: fix color component length for pseudocolor modes

Michal Simek (66):
      microblaze_v8: Cpuinfo handling
      microblaze_v8: Open firmware files
      microblaze_v8: Platform bus registration
      microblaze_v8: exception handling
      microblaze_v8: Signal support
      microblaze_v8: Selfmodified code
      microblaze_v8: cache support
      microblaze_v8: Generic dts file for platforms
      microblaze_v8: kernel modules support
      microblaze_v8: lmb include file
      microblaze_v8: PVR support, cpuinfo support
      microblaze_v8: defconfig file
      microblaze_v8: assembler files head.S, entry-nommu.S, syscall_table=
.S
      microblaze_v8: vmlinux.lds.S - linker script
      microblaze_v8: supported function for memory - kernel/lib
      microblaze_v8: checksum support
      microblaze_v8: early_printk support
      microblaze_v8: uaccess files
      microblaze_v8: heartbeat file
      microblaze_v8: setup.c, setup.h - system setting
      microblaze_v8: asm-offsets.c
      microblaze_v8: process and init task function
      microblaze_v8: delay.h, timex.h
      microblaze_v8: ptrace support
      microblaze_v8: IPC support
      microblaze_v8: traps support
      microblaze_v8: memory inicialization, MMU, TLB
      microblaze_v8: page.h, segment.h, unaligned.h
      microblaze_v8: includes SHM*, msgbuf
      microblaze_v8: bug headers files
      microblaze_v8: definitions of types
      microblaze_v8: ioctl support
      microblaze_v8: io.h IO operations
      microblaze_v8: headers for executables format FLAT, ELF
      microblaze_v8: dma support
      microblaze_v8: headers for irq
      microblaze_v8: atomic.h bitops.h swab.h byteorder.h
      microblaze_v8: headers pgalloc.h pgtable.h
      microblaze_v8: system.h processor.h
      microblaze_v8: clinkage.h linkage.h sections.h kmap_types.h
      microblaze_v8: stats headers
      microblaze_v8: termbits.h termios.h
      microblaze_v8: sigcontext.h siginfo.h
      microblaze_v8: headers simple files - empty or redirect to asm-gene=
ric
      microblaze_v8: gpio.h, serial.h
      microblaze_v8: namei.h
      microblaze_v8: headers files entry.h current.h mman.h registers.h s=
embuf.h
      microblaze_v8: device.h param.h topology.h
      microblaze_v8: pool.h socket.h
      microblaze_v8: fcntl.h sockios.h ucontext.h
      microblaze_v8: unistd.h
      microblaze_v8: string.h thread_info.h
      microblaze_v8: Kbuild file
      microblaze_v8: pci headers
      microblaze_v8: syscalls.h
      microblaze_v8: Interrupt handling and timer support
      microblaze_v8: Kconfig patches
      microblaze_v8: Makefiles for Microblaze cpu
      microblaze_v8: Uartlite for Microblaze
      microblaze_v8: Add MAINTAINERS fragment
      microblaze: Fix problem with removing zero length files
      microblaze: Add missing empty ftrace.h file
      microblaze: Add TIMESTAMPING constants to socket.h
      microblaze: Simplify copy_thread()
      microblaze: struct device - replace bus_id with dev_name()
      microblaze: Add missing FILE tag to MAINTAINERS

Mike Rapoport (3):
      Input: wm97xx - add BTN_TOUCH event to wm97xx to use it with Androi=
d
      Input: ucb1400_ts, mainstone-wm97xx - add BTN_TOUCH events
      [ARM] pxa/em-x270: add libertas device registration

Miklos Szeredi (2):
      fuse: fix argument type in fuse_get_user_pages()
      fuse: fix "direct_io" private mmap

Mikulas Patocka (6):
      dm: remove limited barrier support
      dm: rework queueing and suspension
      dm: remove dm_request loop
      dm: implement basic barrier support
      dm kcopyd: prepare for callback race fix
      dm kcopyd: fix callback race

Nathan Lynch (1):
      sched: do not count frozen tasks toward load

Nikanth Karthikesan (1):
      init/initramfs: fix warning with CONFIG_BLK_DEV_RAM=3Dn

Nobuhiro Iwamatsu (1):
      nommu: fix typo vma->pg_off to vma->vm_pgoff

Oleg Nesterov (4):
      posix-timers: fix RLIMIT_CPU && fork()
      posix-timers: fix RLIMIT_CPU && setitimer(CPUCLOCK_PROF)
      kthread: move sched-realeted initialization from kthreadd context
      ptrace: fix exit_ptrace() vs ptrace_traceme() race

Or Gerlitz (1):
      IPoIB: Document newish features

Pablo Neira Ayuso (1):
      netfilter: ctnetlink: fix regression in expectation handling

Paul Menzel (1):
      drivers/video/aty/radeon_base.c: fix typo in comment

Paul Mundt (8):
      sh: wire up sys_preadv/sys_pwritev() syscalls.
      sh: Provide cpumask_of_pcibus() to fix NUMA build.
      sh: Add support for DMA API debugging.
      sh: Plug in support for ARCH=3Dsh64 using sh SRCARCH.
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6
      MAINTAINERS: Update sh architecture file patterns.
      sh: Pre-allocate a reasonable number of DMA debug entries.
      sh: Add in PCI bus for DMA API debugging.

Paulius Zaleckas (3):
      [WATCHDOG] remove ARM26 sections
      imxmmc: init-exit rework
      imxmmc: move RSSR BLR

Peter Korsgaard (1):
      kbuild: use git svn instead of git-svn in setlocalversion

Peter Zijlstra (1):
      mm: move the scan_unevictable_pages sysctl to the vm table

Phil Sutter (1):
      Input: add driver for S1 button of rb532

Philipp Zabel (2):
      pda_power: Add optional OTG transceiver and voltage regulator suppo=
rt
      [ARM] pxa/magician: Enable bq24022 regulator for gpio_vbus and pda_=
power

Pierre Ossman (1):
      New mail address for Pierre Ossman

Rafael J. Wysocki (1):
      PM/Hibernate: Wait for SCSI devices scan to complete during resume

Rakib Mullick (1):
      x86: Fix section mismatches in mpparse

Randy Dunlap (5):
      timers: add missing kernel-doc
      ethoc: fix library build errors
      docbook: make cleandocs
      MAINTAINERS: fix Andreas's email address
      filemap: fix kernel-doc warnings

Randy Robertson (1):
      initramfs: fix initramfs to work with hardlinked init

Robin Holt (4):
      sgi-xpc: update SGI XP/XPC/XPNET maintainer
      sgi-xpc: prevent false heartbeat failures
      sgi-xpc: implement opencomplete messaging
      sgi-xpc: clean up numerous globals

Roel Kluin (1):
      Input: pc110pad - use no_pci_devices()

Roland Dreier (4):
      IB/mlx4: Use pgprot_writecombine() for BlueFlame pages
      mlx4_core: Don't leak mailbox for SET_PORT on Ethernet ports
      IPoIB: Avoid free_netdev() BUG when destroying a child interface
      Merge branches 'cma', 'cxgb3', 'ipoib', 'mlx4' and 'nes' into for-n=
ext

Roland McGrath (1):
      ptrace: some checkpatch fixes

Russell King (2):
      [ARM] omap: fix omap1 clock usecount decrement bug
      Merge branch 'devel' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/ycmiao/pxa-linux-2.6

Rusty Russell (1):
      sched_rt: don't allocate cpumask in fastpath

Ryusuke Konishi (8):
      nilfs2: return f_fsid for statfs2
      nilfs2: fix lockdep recursive locking warning on bmap
      nilfs2: fix lockdep recursive locking warning on meta data files
      nilfs2: remove module version
      nilfs2: simplify handling of active state of segments fix
      nilfs2: fix wrong accounting and duplicate brelse in nilfs_sufile_s=
et_error
      nilfs2: segment usage file cleanups
      nilfs2: fix possible mismatch of sufile counters on recovery

Sam Ravnborg (3):
      kconfig: fix update-po-config to accect backslash in input
      kbuild: introduce destination-y for exported headers
      Documentation: explain the difference between __bitwise and __bitwi=
se__

Sascha Hauer (1):
      FEC driver: add missing #endif

Serge E. Hallyn (2):
      cap_prctl: don't set error to 0 at 'no_change'
      add some long-missing capabilities to fs_mask

Sergei Shtylyov (9):
      ide-h8300: remove mm_{inw|outw}()
      at91_ide: remove custom tf_{read|load}() methods
      ide-h8300: remove custom tf_{read|load}() methods
      ide: replace IDE_TFLAG_* flags by IDE_VALID_*
      ide: simplify 'struct ide_taskfile'
      ide: move common code out of tf_load() method
      ide: call write_devctl() method from tf_read() method
      ide: refactor tf_load() method
      ide: refactor tf_read() method

Shaohua Li (3):
      ACPI: convert acpi_device_lock spinlock to mutex
      drm/i915: Fix a mismerge of the IGD patch (new .find_pll hooks miss=
ed)
      drm/i915: fix scheduling while holding the new active list spinlock

Shen Feng (1):
      doc: use correct debugfs mountpoint

Stanislaw Gruszka (2):
      at91_ide: remove unused ide_mm_{outb,inb}
      at91_ide: turn on PIO 6 support

Stefan Husemann (1):
      intelfb: support i854

Steve Glendinning (1):
      smsc911x: correct debugging message on mii read timeout

Steve Wise (2):
      RDMA/cxgb3: Handle EEH events
      RDMA/cxgb3: Release dependent resources only when endpoint memory i=
s freed.

Stoyan Gaydarov (1):
      afs: BUG to BUG_ON changes

Suresh Siddha (1):
      x86: add linux kernel support for YMM state

Takashi Iwai (1):
      ALSA: wavefront - Always use request_firmware()

Tejun Heo (2):
      percpu: unbreak alpha percpu
      ahci: force CAP_NCQ for earlier NV MCPs

Tetsuo Handa (3):
      tracing: append a comma to INIT_FTRACE_GRAPH
      tomoyo: add Documentation/tomoyo.txt
      tomoyo: version bump to 2.2.0.

Theodore Ts'o (1):
      block_write_full_page: switch synchronous writes to use WRITE_SYNC_=
PLUG

Thiemo Nagel (2):
      ext4: Fix big-endian problem in __ext4_check_blockref()
      ext4: Fix off-by-one-error in ext4_valid_extent_idx()

Thomas Gleixner (1):
      MN10300: Convert obsolete no_irq_type to no_irq_chip

Thomas Reitmayr (1):
      [WATCHDOG] orion5x_wdt: Add shutdown callback, use watchdog ping fu=
nction

Tony Breeds (1):
      parport_pc: Fix build failure drivers/parport/parport_pc.c for powe=
rpc

Tony Lindgren (1):
      mmc: Fix compile for omap_hsmmc.c

Tony Luck (1):
      [IA64] wire up preadv/pwritev system calls

Uwe Kleine-K=C3=B6nig (4):
      [WATCHDOG] at91rm9200_wdt.c: move probe function to .devinit.text
      [WATCHDOG] ks8695_wdt.c: move probe function to .devinit.text
      [WATCHDOG] omap_wdt.c: move probe function to .devinit.text
      kbuild: fix option processing for -I in headerdep

Vegard Nossum (2):
      ACPI battery: fix async boot oops
      ata: fix obviously wrong comment

Venkatesh Pallipadi (3):
      ACPI x86: Cleanup acpi_cpufreq structures related to aperf/mperf
      ACPI x86: Make aperf/mperf MSR access in acpi_cpufreq read_only
      x86 ACPI: Add support for Always Running APIC timer

Ville Syrjala (3):
      Input: ati_remote2 - complete suspend support
      Input: ati_remote2 - add per device attrs
      Input: ati_remote2 - check module params

Vitaliy Gusev (1):
      kthread: Don't looking for a task in create_kthread() #2

Weidong Han (1):
      x86, intr-remap: fix eoi for interrupt remapping without x2apic

Wim Van Sebroeck (4):
      [WATCHDOG] i6300esb.c: Cleanup
      [WATCHDOG] i6300esb.c: Fix the GETSTATUS and GETBOOTSTATUS ioctls.
      [WATCHDOG] i6300esb.c: Restructure initialization of the device
      Merge branch 'master' of /pub/scm/linux/kernel/git/torvalds/linux-2=
.6

Wolfgang Muees (3):
      mmc_spi: do not check CID and CSD blocks with CRC16
      mmc_spi: convert timeout handling to jiffies and avoid busy waiting
      mmc_spi: support for non-byte-aligned cards

Yang Hongyang (2):
      drivers/net/eql.c: Fix a dev leakage.
      Replace all DMA_nBIT_MASK macro with DMA_BIT_MASK(n)

Yinghai Lu (2):
      irq: fix cpumask memory leak on offstack cpumask kernels
      x86: make 64 bit to use default_inquire_remote_apic

Yoshihiro Shimoda (1):
      sh: sh7785lcr: fix PCI address map for 32-bit mode

Yossi Etigin (2):
      RDMA/cma: Use rate from IPoIB broadcast when joining IPoIB multicas=
t groups
      RDMA/cma: Create cm id even when IB port is down

Yuri Tikhonov (1):
      shmem: fix division by zero

Zhaolei (3):
      printk: fix wrong format string iter for printk
      Make __stringify support variable argument macros too
      ftrace: Output REC->var instead of __entry->var for trace format

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr

--===============2451863627610355280==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============2451863627610355280==--
