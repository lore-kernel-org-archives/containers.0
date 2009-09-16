From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr annotated tag, v2.6.28-rc7, created. v2.6.28-rc7
Date: Wed, 16 Sep 2009 14:36:33 -0400
Message-ID: <200909161836.n8GIaX8I001101@gorgona.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6068612442839249899=="
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

--===============6068612442839249899==
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by smtp1.linux-foundation.org id n8GIuvxN005845

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The annotated tag, v2.6.28-rc7 has been created
        at  1a0bff987b27da5181f112bcc60f34d6fbb7e67e (tag)
   tagging  061e41fdb5047b1fb161e89664057835935ca1d2 (commit)
  replaces  v2.6.28-rc6
 tagged by  Linus Torvalds
        on  Mon Dec 1 19:59:44 2008 -0800

- Log -----------------------------------------------------------------
Linux 2.6.28-rc7
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkk0srUACgkQF3YsRnbiHLtebgCeOQft4v1NM9rlzE/5zxVMQenl
1PQAn1mRvT5FyM4R3nqBJek8FKesAqQq
=3DjtOh
-----END PGP SIGNATURE-----

Adhemerval Zanella (1):
      powerpc: Fix IRQ assignment for some PCIe devices

Al Viro (31):
      meminit section warnings
      false __cpuinit positives on alpha
      powerpc set_huge_psize() false positive
      sparc32 cpuinit flase positives
      sparc64 trivial section misannotations
      istallion section warnings
      fix talitos
      icside section warnings
      W1_MASTER_DS1WM should depend on HAVE_CLK
      advansys fix on ISA-less configs
      of_platform_driver noise on sparce
      gdth section fixes
      rackmeter section fixes
      ixgbe section fixes
      section misannotation in ibmtr_cs
      m32r: section noise in head.S
      fix the section noise in sparc head.S
      section errors in smc911x/smc91x
      rapidio section noise
      uninorth-agp section mess
      cpuinit fixes in kernel/*
      tricky one: hisax sections
      alpha: pcibios_resource_to_bus() is callable from normal code
      pci_setup() is init, not devinit
      enable_IR_x2apic() needs to be __init
      kvm_setup_secondary_clock() is cpuinit
      xen_setup_vcpu_info_placement() is not init on x86
      xen_play_dead() is __cpuinit
      get xenbus_driver ->probe() "recognized" by modpost
      sn_pci_controller_fixup() should be __init
      hotplug_memory_notifier section annotation

Alan Stern (1):
      USB: storage: unusual_devs entry for Mio C520-GPS

Alessandro Guido (2):
      sony-laptop: brightness regression fix
      sony-laptop: printk tweak

Alexey Starikovskiy (2):
      ACPI: EC: count interrupts only if called from interrupt handler.
      ACPI: battery: Convert discharge energy rate to current properly

Amit Kucheria (1):
      ARM: OMAP: Typo fix for clock_allow_idle

Andreas Herrmann (2):
      [CPUFREQ] powernow-k8: ignore out-of-range PstateStatus value
      x86: fixup config space size of CPU functions for AMD family 11h

Andres Salomon (1):
      Input: psmouse - fix incorrect validate_byte check in OLPC protocol

Andrew Morton (1):
      drivers/gpu/drm/i915/i915_irq.c: fix warning

Anton Vorontsov (2):
      USB: fsl_qe_udc: Report disconnect before unbinding
      USB: fsl_usb2_udc: Report disconnect before unbinding

Arjan van de Ven (4):
      Input: replace spin_lock_bh with spin_lock_irqsave in ml_ff_playbac=
k
      toshiba_acpi: close race in toshiba_acpi driver
      input: replace spin_lock_bh with spin_lock_irqsave in ml_ff_playbac=
k
      taint: add missing comment

Arnd Bergmann (3):
      powerpc/cell/axon-msi: Retry on missing interrupt
      powerpc/mpic: Don't reset affinity for secondary MPIC on boot
      powerpc/cell: Fix GDB watchpoints, again

Ben Dooks (2):
      spi: fix spi_s3c24xx_gpio device handle lookup
      spi: fix spi_s3c24xx_gpio num_chipselect

Benjamin Herrenschmidt (2):
      powerpc/44x: Fix 460EX/460GT machine check handling
      radeonfb: fix problem with color expansion & alignment

Bob Moore (1):
      ACPICA: Allow _WAK method to return an Integer

Christian Borntraeger (2):
      [S390] fix/cleanup sched_clock
      [S390] pgtable.h: Fix oops in unmap_vmas for KVM processes

Christoph Hellwig (1):
      remove __ARCH_WANT_COMPAT_SYS_PTRACE

Coly Li (2):
      ocfs2: comments typo fix
      ocfs2: fix return value set in init_dlmfs_fs()

Daniel Gimpelevich (1):
      Input: cm109 - add keymap for ATCom AU-100 phone

Dave Hansen (1):
      powerpc: Fix boot freeze on machine with empty memory node

David Brownell (1):
      i2c/isp1301_omap: Build fixes

David Daney (1):
      MIPS: Make BUG() __noreturn.

David Howells (1):
      frv: fix mmap2 error handling

David Teigland (2):
      ocfs2: initialize stack_user lvbptr
      ocfs2: fix wake_up in unlock_ast

Davide Libenzi (1):
      epoll: introduce resource usage limits

Devin Heitmueller (4):
      V4L/DVB (9631): Make s2api work for ATSC support
      V4L/DVB (9632): make em28xx aux audio input work
      V4L/DVB (9634): Make sure the i2c gate is open before powering down=
 tuner
      V4L/DVB (9639): Make dib0700 remote control support work with firmw=
are v1.20

Dmitri Vorobiev (1):
      Input: fix the example of an input device driver

Dmitry Baryshkov (1):
      fbdev: fix FB console blanking

Dmitry Torokhov (1):
      Input: i8042 - add Compal Hel80 laptop to nomux blacklist

Douglas Schilling Landgraf (6):
      V4L/DVB (9601): ttusb_dec: Add NULL pointer validation
      V4L/DVB (9602): dvb-ttusb-budget: Add NULL pointer validation
      V4L/DVB (9603): dvb-ttusb-budget: Add validation for ttusb_alloc_is=
o_urbs
      V4L/DVB (9604): ttusb_dec: fix memory leak
      V4L/DVB (9605): usb-urb: fix memory leak
      V4L/DVB (9743): em28xx: fix oops audio

Eric Anholt (3):
      drm/i915: Remove IMR masking during interrupt handler, and restart =
it if needed.
      drm/i915: Avoid BUG_ONs on VT switch with a wedged chipset.
      drm/i915: Fix copy'n'pasteo that broke VT switch if flushing was no=
n-empty.

Eric Dumazet (1):
      oprofile: fix an overflow in ppro code

Eric Miao (5):
      pxafb: introduce LCD_TYPE_MASK and use it.
      pxafb: only initialize the smart panel thread when dealing with a s=
martpanel
      [ARM] pxa: fix I2C controller device being registered twice on Akit=
a
      [ARM] pxa: fix incorrect PCMCIA PSKTSEL pin configuration for spitz
      [ARM] pxa/corgi: update default config to exclude tosa from being b=
uilt

FUJITA Tomonori (1):
      DMA-API.txt: fix description of pci_map_sg/dma_map_sg scatterlists =
handling

Geert Uytterhoeven (1):
      parisc: __kernel_time_t is always long

Grant Erickson (1):
      powerpc/40x: Limit allocable DRAM during early mapping

Grant Likely (4):
      powerpc/mpc5200: fix bestcomm Kconfig dependencies
      powerpc/virtex: fix various format/casting printk mismatches
      powerpc/52xx: update defconfigs
      powerpc/virtex: Update defconfigs

Greg Kroah-Hartman (2):
      Revert "USB: improve ehci_watchdog's side effect in CPU power manag=
ement"
      USB: serial: add more Onda device ids to option driver

Guennadi Liakhovetski (1):
      [ARM] pxa/pcm990: use negative number for an invalid GPIO in camera=
 data

Hannes Eder (1):
      sound/sound_core: Fix sparse warnings

Hans Verkuil (1):
      V4L/DVB (9748): em28xx: fix compile warning

Harvey Harrison (1):
      V4L/DVB (9635): v4l: s2255drv fix firmware test on big-endian

Heiko Carstens (1):
      [S390] Fix alignment of initial kernel stack.

Helge Deller (1):
      parisc: fix kernel crash when unwinding a userspace process

Henrik Rydberg (1):
      hwmon: applesmc: make applesmc load automatically on startup

Henrique de Moraes Holschuh (1):
      ACPI: thinkpad-acpi: fix fan sleep/resume path

Herton Ronaldo Krzesinski (1):
      Input: i8042 - add Dell XPS M1530 to nomux list

Ian Campbell (1):
      xen: pin correct PGD on suspend

Igor M. Liplianin (1):
      V4L/DVB (9608): Fix section mismatch warning for dm1105 during make

Ingo Molnar (6):
      irq: fix typo
      Merge commit 'v2.6.28-rc6' into x86/urgent
      Merge commit 'v2.6.28-rc6' into irq/urgent
      Merge branch 'oprofile-for-tip' of git://git.kernel.org/pub/scm/lin=
ux/kernel/git/rric/oprofile into x86/urgent
      sched, cpusets: fix warning in kernel/cpuset.c
      sched: prevent divide by zero error in cpu_avg_load_per_task, updat=
e

Jack Morgenstein (2):
      mlx4_core: Save/restore default port IB capability mask
      IB/mlx4: Fix MTT leakage in resize CQ

Jan Kara (1):
      udf: Fix BUG_ON() in destroy_inode()

Jan Nikitenko (1):
      spi: au1550_spi full duplex dma fix

Jan Scholz (1):
      HID: Apple ALU wireless keyboards are bluetooth devices

Jarkko Lavinen (2):
      i82875p_edac: fix overflow device resource setup
      i82875p_edac: fix module remove

Jaya Kumar (2):
      [ARM] 5330/1: mach-pxa: Fixup reset for systems using reboot=3Dcold=
 or other strings
      [ARM] 5335/1: pxa25x_udc: Fix is_vbus_present to return 1 or 0

Jean Delvare (2):
      i2c: Remove i2c clients in reverse order
      i2c-parport: Fix misplaced parport_release call

Jean-Francois Moine (3):
      V4L/DVB (9689): gspca: Memory leak when disconnect while streaming.
      V4L/DVB (9690): gspca: Lock the subdrivers via module_get/put.
      V4L/DVB (9691): gspca: Move the video device to a separate area.

Jeff Layton (1):
      [CIFS] fix regression in cifs_write_begin/cifs_write_end

Jeremy Kerr (1):
      powerpc/spufs: Fix spinning in spufs_ps_fault on signal

Jiri Kosina (3):
      HID: fix blacklist entries for greenasia/pantherlord
      HID: unignore mouse on unibody macbooks
      HID: add USB ID for another dual gameron adapter

Jiri Pirko (1):
      Input: atkbd - cancel delayed work before freeing its structure

Jiri Slaby (1):
      HID: remove setup mutex, fix possible deadlock

Joachim Fenkes (1):
      IB/ehca: Change misleading error message on memory hotplug

Joerg Roedel (1):
      x86: always define DECLARE_PCI_UNMAP* macros

Johannes Weiner (1):
      vmscan: protect zone rotation stats by lru lock

Jose Alberto Reguero (1):
      V4L/DVB (9664): af9015: don't reconnect device in USB-bus

Julia Lawall (1):
      arch/x86/kernel/pci-calgary_64.c: change simple_strtol to simple_st=
rtoul

Julien Boibessot (1):
      spi: fix spi_imx probe oopsing

KAMEZAWA Hiroyuki (1):
      memcg: memory hotplug fix for notifier callback

Kay Sievers (1):
      parisc: struct device - replace bus_id with dev_name(), dev_set_nam=
e()

Keith Packard (5):
      drm/i915: Manage PIPESTAT to control vblank interrupts instead of I=
MR.
      drm/i915: Subtract total pinned bytes from available aperture size
      drm/i915: Always read pipestat in irq_handler
      drm/i915: execbuffer pins objects, no need to ensure they're still =
in the GTT
      drm: move drm vblank initialization/cleanup to driver load/unload

Kevin Hao (1):
      Add kref to fake tty used by USB console

Lai Jiangshan (1):
      ftrace: prevent recursion

Len Brown (2):
      Revert "ACPI: don't enable control method power button as wakeup de=
vice when Fixed Power button is used"
      ACPI: delete OSI(Linux) DMI dmesg spam

Li Zefan (1):
      lockdep: consistent alignement for lockdep info

Liming Wang (1):
      function tracing: fix wrong position computing of stack_trace

Lin Ming (1):
      ACPICA: disable _BIF warning

Linus Torvalds (31):
      Merge master.kernel.org:/home/rmk/linux-2.6-arm
      Merge branch 'upstream' of git://ftp.linux-mips.org/pub/scm/upstrea=
m-linus
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/dtor/input
      Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel=
/git/lenb/linux-acpi-2.6
      Merge branch 'for-linus' of git://git390.osdl.marist.edu/pub/scm/li=
nux-2.6
      Merge branch 'i2c-for-linus' of git://jdelvare.pck.nerim.net/jdelva=
re-2.6
      Merge branch 'linux-next' of git://git.infradead.org/~dedekind/ubi-=
2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge branch 'fixes' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/davej/cpufreq
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jack/linux-udf-2.6
      Merge branch 'drm-fixes' of git://git.kernel.org/pub/scm/linux/kern=
el/git/airlied/drm-2.6
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'tracing-fixes-for-linus' of git://git.kernel.org/pub/=
scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'core-fixes-for-linus' of git://git.kernel.org/pub/scm=
/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'irq-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'sched-fixes-for-linus' of git://git.kernel.org/pub/sc=
m/linux/kernel/git/tip/linux-2.6-tip
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/sfrench/cifs-2.=
6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/kyle/parisc-2.6
      Merge master.kernel.org:/home/rmk/linux-2.6-arm
      Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/paulus/powerpc
      Merge branch 'drm-fixes' of git://git.kernel.org/pub/scm/linux/kern=
el/git/airlied/drm-2.6
      Revert "of_platform_driver noise on sparce"
      Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/paulus/powerpc
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/usb-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jikos/hid
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/ieee1394/linux1394-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/roland/infiniband
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/jgarzik/libata-dev
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/mfasheh/ocfs2
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/mchehab/linux-2.6
      Linux 2.6.28-rc7

Manfred Spraul (1):
      lib/idr.c: fix rcu related race with idr_find

Marek Vasut (1):
      [ARM] pxa/palmtx: misc fixes to use generic GPIO API

Mark Fasheh (2):
      ocfs2: Small documentation update
      ocfs2: fix regression in ocfs2_read_blocks_sync()

Mark Nelson (1):
      genirq: __irq_set_trigger: change pr_warning to pr_debug

Markus Metzger (4):
      x86, bts: exclude ds.c from build when disabled
      x86, bts: turn macro into static inline function
      x86, pebs: fix PEBS record size configuration
      x86, bts: fix wrmsr and spinlock over kmalloc

Martin Schwidefsky (2):
      [S390] fix system call parameter functions.
      [S390] Update default configuration.

Martyn Welch (1):
      powerpc: Use generic PHY driver for Marvell 88E1111 PHY on GE Fanuc=
 SBC610

Matthew Garrett (1):
      Input: atkbd - add keymap quirk for Inventec Symphony systems

Matthew Ranostay (2):
      ALSA: hda: STAC_DELL_M6 EAPD
      ALSA: hda: Add STAC_DELL_M4_3 quirk

Mauro Carvalho Chehab (7):
      V4L/DVB (9627): em28xx: Avoid i2c register error for boards without=
 eeprom
      V4L/DVB (9645): em28xx: Avoid memory leaks if registration fails
      V4L/DVB (9646): em28xx: avoid allocating/dealocating memory on ever=
y control urb
      V4L/DVB (9647): em28xx: void having two concurrent control URB's
      V4L/DVB (9668): em28xx: fix a race condition with hald
      V4L/DVB (9742): em28xx-alsa: implement another locking schema
      em28xx: remove backward compat macro added on a previous fix

Michael Barkowski (1):
      powerpc/mpc832x_rdb: fix swapped ethernet ids

Michael Krufky (1):
      V4L/DVB (9732): sms1xxx: use new firmware for Hauppauge WinTV MiniS=
tick

Milton Miller (1):
      powerpc: Fix build for 32-bit SMP configs

Nick Piggin (1):
      mm: vmalloc fix lazy unmapping cache aliasing

Paul Mackerras (4):
      Merge branch 'merge' of git://git.secretlab.ca/git/linux-2.6-mpc52x=
x into merge
      Merge branch 'merge' of ssh://master.kernel.org/pub/scm/linux/kerne=
l/git/jwboyer/powerpc-4xx into merge
      Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/jk/spufs into merge
      powerpc: Fix system calls on Cell entered with XER.SO=3D1

Pavel Machek (1):
      ACPI: scheduling in atomic via acpi_evaluate_integer ()

Pekka Paalanen (2):
      x86, mmiotrace: fix buffer overrun detection
      tracing, doc: update mmiotrace documentation

Peng Li (1):
      drm/i915: Save/restore HWS_PGA on suspend/resume

Phil Sutter (2):
      [libata] pata_rb532_cf: fix and rename register definitions
      [libata] pata_rb532_cf: fix signature of the xfer function

Ping Cheng (1):
      Input: wacom - add support for new USB Tablet PCs

Rafael J. Wysocki (1):
      ACPI suspend: Blacklist boxes that require us to set SCI_EN directl=
y on resume

Rakib Mullick (2):
      x86: fix __cpuinit/__init tangle in init_thread_xstate()
      x86: fixing __cpuinit/__init tangle, xsave_cntxt_init()

Randy Dunlap (3):
      irq.h: fix missing/extra kernel-doc
      kernel-doc: handle varargs cleanly
      ntfs: don't fool kernel-doc

Robert Jarzmik (2):
      [ARM] pxa/MioA701: fix memory corruption.
      [ARM] pxa/MioA701: bluetooth resume fix

Robert P. J. Day (1):
      MN10300: Tighten up the code using case ranges

Robin Getz (1):
      [CPUFREQ] Documentation: Add Blackfin to list of supported processo=
rs

Roland Dreier (1):
      Merge branches 'ehca' and 'mlx4' into for-linus

Russell King (4):
      Merge branch 'for-rmk' of git://git.kernel.org/pub/scm/linux/kernel=
/git/ycmiao/pxa-linux-2.6
      Merge branch 'omap-fixes' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/tmlind/linux-omap-2.6
      Allow architectures to override copy_user_highpage()
      Merge branch 'for-rmk' of git://git.kernel.org/pub/scm/linux/kernel=
/git/ycmiao/pxa-linux-2.6

Shane Huang (1):
      USB: fix SB600 USB subsystem hang bug

Stefan Richter (4):
      ieee1394: sbp2: another iPod mini quirk entry
      firewire: fw-sbp2: another iPod mini quirk entry
      ieee1394: fix list corruption (reported at module removal)
      ieee1394: sbp2: fix race condition in state change

Stefan Roscher (1):
      IB/ehca: Fix problem with generated flush work completions

Stefano Babic (1):
      spi: mpc52xx_psc_spi chipselect bugfix

Steven Rostedt (2):
      x86: use limited register constraint for setnz
      sched: prevent divide by zero error in cpu_avg_load_per_task

Takashi Iwai (9):
      ALSA: hda - Add a quirk for Dell Studio 15
      Merge branches 'topic/fix/hda' and 'topic/fix/sound-core' into for-=
linus
      ALSA: hda - Fix caching of SPDIF status bits
      ALSA: hda - Fix AFG power management on IDT 92HD* codecs
      ALSA: hda - No 'Headphone as Line-out' swich without line-outs
      ALSA: hda - mark Dell studio 1535 quirk
      ALSA: hda - Check model for Dell 92HD73xx laptops
      Merge branch 'topic/fix/hda' into for-linus
      parport_serial: fix array overflow

Tejun Heo (2):
      ata_piix: add borked Tecra M4 to broken suspend list
      libata: blacklist Seagate drives which time out FLUSH_CACHE when us=
ed with NCQ

Tero Kristo (1):
      ARM: OMAP: Fixes for suspend / resume GPIO wake-up handling

Thomas Gleixner (4):
      genirq: keep affinities set from userspace across free/request_irq(=
)
      genirq: fix the affinity setting in setup_irq
      x86: apic honour irq affinity which was set in early boot
      x86: revert irq number limitation

Tobias Kunze Brise=C3=B1o (1):
      USB: usb-storage: unusual_devs entry for Nikon D2H

Tony Lindgren (1):
      ARM: OMAP: Remove broken LCD driver for SX1

Trent Piepho (1):
      powerpc/85xx: L2 cache size wrong in 8572DS dts

Vitaliy Gusev (1):
      UBI: Don't exit from ubi_thread until kthread_should_stop() is true

Vojtech Pavlik (1):
      Input: elo - fix format string in elo driver

Will Newton (1):
      drivers/char/tty_io.c: Avoid panic when no console is configured.

Wolfgang Ocker (1):
      spi: avoid spidev crash when device is removed

Yuri Tikhonov (1):
      xsysace: Fix driver to use resource_size_t instead of unsigned long

Zoltan Sogor (1):
      UBI: fix EBADMSG handling

frans (1):
      Trivial Documentation/filesystems/ramfs-rootfs-initramfs.txt fix

roel kluin (1):
      spi documentation: use __initdata on struct

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr

--===============6068612442839249899==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============6068612442839249899==--
