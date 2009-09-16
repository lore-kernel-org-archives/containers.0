From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr annotated tag, v2.6.31-rc5, created. v2.6.31-rc5
Date: Wed, 16 Sep 2009 14:36:58 -0400
Message-ID: <200909161836.n8GIawSp001655@gorgona.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4994770047321562215=="
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

--===============4994770047321562215==
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by smtp1.linux-foundation.org id n8GJAi5q007322

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The annotated tag, v2.6.31-rc5 has been created
        at  948e7a0b0e000a8d646b72fcfd8ccaa047e046ab (tag)
   tagging  ed680c4ad478d0fee9740f7d029087f181346564 (commit)
  replaces  v2.6.31-rc4
 tagged by  Linus Torvalds
        on  Fri Jul 31 17:40:58 2009 -0700

- Log -----------------------------------------------------------------
Linux 2.6.31-rc5
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkpzjx8ACgkQF3YsRnbiHLtNLQCeJtacWtnNxC2ucwFGgrxiVvD+
XQ8An2gUzJ3ODsYYD+bDVr5tbKwISgVL
=3D6ZzL
-----END PGP SIGNATURE-----

Ajay Kumar Gupta (1):
      USB: musb: fix CONFIGDATA register read issue

Ajit Khaparde (1):
      be2net: Bug fix in the non-lro path. Size of received packet was no=
t updated in statistics properly.

Alan Cox (3):
      tty: Fix a USB serial crash/scribble
      pty: quickfix for the pty ENXIO timing problems
      usb_serial: Fix remaining ref count/lock bugs

Alan Jenkins (4):
      rfkill: fix rfkill_set_states() to set the hw state
      rfkill: remove too-strict __must_check
      acer-wmi: fix rfkill conversion
      PM / Hibernate: Replace bdget call with simple atomic_inc of i_coun=
t

Alan Stern (1):
      USB: usbtest: no need for USB_DEVICEFS

Albin Tonnerre (1):
      drivers/serial/atmel_serial.c: fix compile when CONFIG_SERIAL_ATMEL=
=3DY and CONFIG_SERIAL_ATMEL_CONSOLE=3DN

Alessandro Rubini (1):
      smc91x.h: add config for Nomadik evaluation kit

Alex Deucher (5):
      drm/radeon/kms: fix quirk for MSI laptop
      drm/radeon/kms: get lvds info for DIG LVTMA and UNIPHY encoders
      drm/radeon/kms: add PLL flag to prefer frequencies <=3D the target =
freq
      drm/radeon/kms: enable frac fb divs on rs600/rs690/rs740
      drm/radeon/kms: fix hotspot handling on pre-avivo chips

Alexander Beregalov (1):
      net: KS8851 needs to depend on MII

Alexey Fisher (2):
      x86: Add quirk for Intel DG45ID board to avoid low memory corruptio=
n
      ALSA: usb-audio - Volume control quirk for QuickCam E 3500

Amit Kucheria (2):
      staging: udlfb: Add vmalloc.h include
      USB: musb: Refer to musb_otg_timer_func under correct #ifdef

Anand Gadiyar (1):
      USB: OMAP: OHCI: hc_driver's stop method should call ohci_stop

Andi Kleen (1):
      x86-64: Fix bad_srat() to clear all state

Andreas Eversberg (1):
      mISDN: Fix handling of receive buffer size in L1oIP

Andres Salomon (2):
      olpc_battery: Fix up eeprom read function
      olpc_battery: Ensure that the TRICKLE bit is checked

Andy Gospodarek (1):
      ixgbe: remove unnecessary call to device_init_wakeup

Andy Whitcroft (1):
      rt2x00: Fix chipset detection for rt2500usb

Anton Vorontsov (8):
      of/mdio: Add support function for Ethernet fixed-link property
      fs_enet: Revive fixed link support
      gianfar: Revive fixed link support
      ucc_geth: Revive fixed link support
      sdhci: get rid of "frequency too high" flood when using eSDHC
      powerpc/85xx: Fix ethernet link detection on MPC8569E-MDS boards
      powerpc/85xx: Don't scan for TBI PHY addresses on MPC8569E-MDS boar=
ds
      powerpc/83xx: Fix PCI IO base address on MPC837xE-RDB boards

Antti Palosaari (1):
      V4L/DVB (12269): af9013: auto-detect parameters in case of garbage =
given by app

Arnd Bergmann (1):
      microblaze: remove sys_ipc

Bartlomiej Zolnierkiewicz (4):
      mg_disk: fix issue with data integrity on error in mg_write()
      libata: add missing NULL pointer check to ata_eh_reset()
      libata: remove superfluous NULL pointer checks
      PM / ACPI: HP G7000 Notebook needs a SCI_EN resume quirk

Benjamin Herrenschmidt (2):
      mm: Pass virtual address to [__]p{te,ud,md}_free_tlb()
      mm: Remove duplicate definitions in MIPS and SH

Benjamin Marzinski (5):
      GFS2: keep statfs info in sync on grows
      GFS2: Fix panic in glock memory shrinker
      GFS2: Don't put unlikely reclaim candidates on the reclaim list.
      GFS2: Fix incorrent statfs consistency check
      GFS2: remove dcache entries for remote deleted inodes

Bill Pemberton (1):
      Staging: serqt_usb2: add missing calls to tty_kref_put()

Bob Copeland (1):
      ath5k: temporarily disable crypto for AP mode

Brian Johnson (2):
      V4L/DVB (12282): gspca - main: Support for vidioc_g_chip_ident and =
vidioc_g/s_register.
      V4L/DVB (12283): gspca - sn9c20x: New subdriver for sn9c201 and sn9=
c202 bridges.

Carlos R. Mafra (1):
      USB: option: Remove unused variable

Catalin Marinas (3):
      x86: Include all of .data.* sections in _edata on 64-bit
      kmemleak: Protect the seq start/next/stop sequence by rcu_read_lock=
()
      fs/ramfs/file-nommu.c needs include/linux/sched.h

Chaithrika U S (1):
      ASoC: tlv320aic3x: Enable PLL when not bypassed

Chris Mason (3):
      Btrfs: clear all space_info->full after removing a block group
      Btrfs: find smallest available device extent during chunk allocatio=
n
      Btrfs: be more polite in the async caching threads

Christian Lamparter (1):
      cfg80211: double free in __cfg80211_scan_done

Craig Shelley (1):
      USB: CP210x Add new device IDs

Dan Carpenter (2):
      p54spi: fix potential null deref in p54spi.c
      lguest: dereferencing freed mem in add_eventfd()

Dan Williams (1):
      dmaengine: move HIGHMEM64G restriction to ASYNC_TX_DMA

Daniel Cadete (1):
      Btrfs: remove of redundant btrfs_header_level

Daniel Mack (1):
      ALSA: snd_usb_caiaq: add support for Audio2DJ

Dave Airlie (17):
      drm/radeon/kms: fix some GART table entry bugs.
      drm/radeon/kms: mmio base/size should be resource_size_t.
      drm/radeon/kms: remove IB flushing trick.
      drm/radeon/kms: set crtc and cursor offsets correctly on legacy chi=
ps.
      drm/radeon/kms: respect TOM on rs100->rs480 IGP variants.
      drm/radeon: fix support for vline relocations.
      drm/radeon/kms: fix vram vs aper size check.
      drm/radeon/kms: drop zero length CS indirect buffers.
      drm/radeon/kms: don't swap PCIEGART PTEs in VRAM.
      drm/ttm/radeon: add dma32 support.
      drm/radeon/kms: fix VRAM sizing like DDX does it.
      drm/radeon/kms: block RN50 from using 3D engine.
      drm/radeon/kms: add initial colortiling support.
      drm/radeon/kms: vram sizing on certain r100 chips needs workaround.
      drm/radeon/kms: allow interruptible waits for objects.
      drm/ttm: fix highuser vs dma32 confusion.
      drm/radeon: set fb aperture sizes for framebuffer handoff.

Dave Hansen (1):
      lib: flexible array implementation

Dave Jones (1):
      pps.h needs <linux/types.h>

David Milburn (1):
      ahci: add device IDs for Ibex Peak ahci controllers

David Rientjes (2):
      Staging: android: lowmemorykiller.c: fix it for "oom: move oom_adj =
value from task_struct to mm_struct"
      mm: avoid endless looping for oom killed tasks

David S. Miller (1):
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-2.6

David Woodhouse (2):
      Btrfs: Remove broken sanity check from btrfs_rmap_block()
      Btrfs: Fix crash on read failures at mount

Deepak Saxena (1):
      net: irda: init spinlock after memcpy

Denis Turischev (1):
      x86: Add reboot fixup for SBC-fitPC2

Devin Heitmueller (7):
      V4L/DVB (12257): em28xx: make tuning work for Terratec Cinergy T XS=
 USB (mt352 variant)
      V4L/DVB (12258): em28xx: fix typo in mt352 init sequence for Terrat=
ec Cinergy T XS USB
      V4L/DVB (12260): em28xx: make support work for the Pinnacle Hybrid =
Pro (eb1a:2881)
      V4L/DVB (12261): em28xx: set GPIO properly for Pinnacle Hybrid Pro =
analog support
      V4L/DVB (12262): em28xx: Make sure the tuner is initialized if gene=
ric empia USB id was used
      V4L/DVB (12263): em28xx: set demod profile for Pinnacle Hybrid Pro =
320e
      V4L/DVB (12265): em28xx: fix tuning problem in HVR-900 (R1)

Dhananjay Phadke (1):
      netxen: reset ring consumer during cleanup

Diego Calleja (1):
      Btrfs: Remove code duplication in comp_keys

Don Skidmore (1):
      ixgbe: fix for 82599 errata marking UDP checksum errors

Eero Nurkkala (1):
      spi: omap2_mcspi rxdma bugfix

Eric Paris (7):
      inotify: drop user watch count when a watch is removed
      inotify: do not leak inode marks in inotify_add_watch
      inotify: fix error paths in inotify_update_watch
      fsnotify: use def_bool in kconfig instead of letting the user choos=
e
      inotify: check filename before dropping repeat events
      fsnotify: fix inotify tail drop check with path entries
      inotify: use GFP_NOFS under potential memory pressure

Eric Sandeen (3):
      hugetlbfs: fix i_blocks accounting
      xfs: reduce bmv_count in xfs_vn_fiemap
      xfs: bump up nr_to_write in xfs_vm_writepage

Erik Andr=C3=A9n (4):
      V4L/DVB (12221): gspca - stv06xx-hdcs: Actually update the sensor s=
tate
      V4L/DVB (12222): gspca - stv06xx-hdcs: Fix sensor sequence bug
      V4L/DVB (12223): gspca - stv06xx-hdcs: Correct the pixelformat
      V4L/DVB (12224): gspca - m5602-s5k4aa: Remove erroneous register wr=
ites

Felix Beck (1):
      [S390] zcrypt: fix scheduling of hrtimer ap_poll_timer

Giacomo Lozito (1):
      USB: storage: raise timeout in usb_stor_Bulk_max_lun

Greg Kroah-Hartman (1):
      staging: remove aten2011 driver

H. Peter Anvin (1):
      x86: Fix movq immediate operand constraints in uaccess.h

Hans Verkuil (1):
      V4L/DVB (12300): bttv: fix regression: tvaudio must be loaded befor=
e tuner

Heiko Carstens (3):
      [S390] hibernation: fix lowcore handling
      [S390] hibernation: fix register corruption on machine checks
      [S390] vdso: fix per cpu area allocation

Herton Ronaldo Krzesinski (1):
      USB: option: add ZTE device ids and remove ONDA ids

Hidehiro Kawai (1):
      x86, mce: Rename incorrect macro name "CONFIG_X86_THRESHOLD"

Hidetoshi Seto (2):
      kexec: fix omitting offset in extended crashkernel syntax
      sysrq, kdump: make sysrq-c consistent

Huang Weiyi (1):
      microblaze: remove duplicated #include

Ira Snyder (2):
      fsldma: enable external start for the 83xx controller
      fsldma: do not clear bandwidth control bits on the 83xx controller

Ira W. Snyder (1):
      fsldma: use PCI Read Multiple command

Jan Beulich (1):
      x86, mce: Fix set_trigger() accessor

Jan Kara (6):
      jbd: Fail to load a journal if it is too short
      ext3: Fix truncation of symlinks after failed write
      jbd: Fix a race between checkpointing code and journal_get_write_ac=
cess()
      ext3: Get rid of extenddisksize parameter of ext3_get_blocks_handle=
()
      udf: Fix loading of VAT inode when drive wrongly reports number of =
recorded blocks
      quota: Silence lockdep on quota_on

Javier Cardona (1):
      mac80211: use correct address for mesh Path Error

Javier Martin (1):
      USB: option.c to support Alcatel X060S/X200 broadband modems

Jean Delvare (1):
      hwmon: (smsc47m1) Differentiate between LPC47M233 and LPC47M292

Jean-Francois Moine (1):
      V4L/DVB (12267): gspca - sonixj: Bad sensor init of non ov76xx sens=
ors.

Jeff Garzik (1):
      Remove zero-length file drivers/char/vr41xx_giu.c

Jeff Layton (2):
      cifs: disable serverino if server doesn't support it
      cifs: fix sb->s_maxbytes so that it casts properly to a signed valu=
e

Jens Axboe (2):
      block: always assign default lock to queues
      block: make the end_io functions be non-GPL exports

Jeremy Fitzhardinge (1):
      x86, amd: Don't probe for extended APIC ID if APICs are disabled

Jerome Glisse (1):
      drm/radeon/kms: fix bandwidth computation on avivo hardware

Jiri Slaby (1):
      uio: mark uio.h functions __KERNEL__ only

Joe Perches (22):
      drivers/dma/fsldma.c: Remove unnecessary semicolons
      drivers/dma: Remove unnecessary semicolons
      MAINTAINERS: IA64 - pair P:/M: entries properly
      MAINTAINERS: Remove ivtv-user lists, add CX18 url
      MAINTAINERS: QLGE 10Gb ETHERNET - pair P:/M: entries properly
      MAINTAINERS: Use tabs in ACER ASPIRE ONE
      MAINTAINERS: Remove L: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
      MAINTAINERS: Move ARPD to CREDITS
      MAINTAINERS: Update KERNEL JANITORS
      MAINTAINERS: Add PPS patterns
      MAINTAINERS: USB Serial Digi Acceleport: use separate P: for Al Bor=
chers
      MAINTAINERS: INPUT: Add Dmitry's name to his email address
      MAINTAINERS: Remove CS461x sound card section
      MAINTAINERS: QLOGIC QLA2XXX - add Andrew Vasquez email address
      MAINTAINERS: QLOGIC QLA3XXX - Add Ron Mercer email address
      MAINTAINERS: Scott Murray is no longer with SomaNetworks
      scripts/get_maintainer.pl: Add -f directory use
      get_maintainer.pl: Add git-min-percent option
      get_maintainerpl-add-git-min-percent-option-fix
      MAINTAINERS: coalesce name and email address lines
      MAINTAINERS: finish off the email address coalescing
      imxmmc: Remove unnecessary semicolons

Johannes Berg (4):
      mac80211: disable mesh
      rfkill: allow toggling soft state in sysfs again
      mac80211_hwsim: fix unregistration
      mac80211_hwsim: fix use after free

John Williams (2):
      microblaze: Final support for statically linked DTB
      microblaze: Get module loading working

John Youn (2):
      USB: xhci: Scratchpad buffer allocation
      USB: xhci: Support for 64-byte contexts

Josef Bacik (3):
      Btrfs: use hybrid extents+bitmap rb tree for free space
      Btrfs: async block group caching
      Btrfs: change how we unpin extents

Jouni Hogander (1):
      spi: omap2_mcspi supports wake events

Julia Lawall (5):
      Btrfs: convert nested spin_lock_irqsave to spin_lock
      Btrfs: adjust NULL test
      V4L/DVB (12284): gspca - jpeg subdrivers: Check the result of kmall=
oc(jpeg header).
      Btrfs: Correct redundant test in add_inode_ref
      ALSA: sound/aoa: Add kmalloc NULL tests

KAMEZAWA Hiroyuki (1):
      cgroup avoid permanent sleep at rmdir

Kristoffer Ericson (2):
      drivers/video/backlight/jornada720_bl.c: fix build
      MAINTAINERS: update HP Jornada 700-series and Epson s1d13xxxfb supp=
ort

Kumar Gala (2):
      powerpc/mm: Fix SMP issue with MMU context handling code
      powerpc: Update defconfigs for embedded 6xx/7xxx, 8xx, 8{3,5,6}xxx

Larry Finger (1):
      rtl8187: Fix for kernel oops when unloading with LEDs enabled

Li Zefan (5):
      trace_stack: Fix seqfile memory leak
      function-graph: Fix seqfile memory leak
      tracing/stat: Fix seqfile memory leak
      cgroups: fix pid namespace bug
      io context: fix ref counting

Linus Torvalds (39):
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/sfrench/cifs-2.=
6
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jack/linux-fs-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/shaggy/jfs-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/agk/linux-2.6-d=
m
      Merge branch 'for-linus' of git://git390.marist.edu/pub/scm/linux-2=
.6
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/mchehab/linux-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'fixes-for-linus' of git://git.monstr.eu/linux-2.6-mic=
roblaze
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/bp/bp
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'for-linus' of git://git.infradead.org/users/eparis/no=
tify
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/mason/btrfs-uns=
table
      Merge branch 'i2c-for-linus' of git://git.kernel.org/pub/scm/linux/=
kernel/git/jdelvare/staging
      Merge branch 'hwmon-for-linus' of git://git.kernel.org/pub/scm/linu=
x/kernel/git/jdelvare/staging
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/usb-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging-=
2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-c=
ore-2.6
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/jgarzik/libata-dev
      Merge branch 'zero-length' of git://git.kernel.org/pub/scm/linux/ke=
rnel/git/jgarzik/misc-2.6
      Merge branch 'drm-radeon-kms' of git://git.kernel.org/pub/scm/linux=
/kernel/git/airlied/drm-2.6
      Merge branch 'pm-fixes' of git://git.kernel.org/pub/scm/linux/kerne=
l/git/rafael/suspend-2.6
      Merge branch 'i2c-fixes-rc4' of git://aeryn.fluff.org.uk/bjdooks/li=
nux
      Alan doesn't want to maintain tty code any more
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/rusty/linux-2.6=
-for-linus
      Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/benh/powerpc
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/steve/gfs2-2.6-=
fixes
      Merge git://git.infradead.org/users/cbou/battery-2.6.31
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jack/linux-quota-2.6
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jack/linux-udf-2.6
      Merge branch 'next' of git://git.kernel.org/pub/scm/linux/kernel/gi=
t/djbw/async_tx
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/mason/btrfs-uns=
table
      Merge branch 'tracing-fixes-for-linus' of git://git.kernel.org/pub/=
scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/drzeus/mmc
      Merge branch 'timers-fixes-for-linus' of git://git.kernel.org/pub/s=
cm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for-linus' of git://git.kernel.dk/linux-2.6-block
      Merge branch 'for-linus' of git://oss.sgi.com/xfs/xfs
      Linux 2.6.31-rc5

Lu Zhihe (1):
      edac: x38 fix mchbar high register addr

Luca Tettamanti (1):
      hwmon: (asus_atk0110) Fix upper limit readings

Lucian Adrian Grijincu (1):
      driver core: documentation: make it clear that sysfs is optional

Lucy Liu (1):
      ixgbe: Don't priority tag control frames in DCB mode

Luis R. Rodriguez (2):
      ath9k: Tune ANI function processing on AP mode during ANI reset
      ath: add support for special 0x8000 regulatory domain

Magnus Damm (2):
      i2c-sh_mobile: change module_init() to subsys_initcall()
      clocksource: Save mult_orig in clocksource_disable()

Marek Vasut (1):
      libertas: Fix problem with broken V4 firmware on CF8381

Mark Ware (2):
      net: Rework mdio-ofgpio driver to use of_mdio infrastructure
      cpm_uart: Don't use alloc_bootmem in cpm_uart_cpm2.c

Martin Schwidefsky (1):
      [S390] vdso: clock_gettime of CLOCK_THREAD_CPUTIME_ID with noexec=3D=
on

Martyn Welch (2):
      powerpc/86xx: Update defconfig for GE Fanuc's PPC9A
      powerpc/86xx: Update GE Fanuc sbc310 default configuration

Masami Hiramatsu (1):
      kprobes: Use kernel_text_address() for checking probe address

Matthew Wilcox (1):
      markup_oops: fix it with 32-bit userspace on a 64-bit kernel

Mauro Carvalho Chehab (14):
      V4L/DVB (12233): em28xx: rename is_27xx to is_webcam
      V4L/DVB (12234): em28xx-cards: use is_webcam flag for devices that =
are known to be webcams
      V4L/DVB (12235): em28xx: detects sensors also with the generic em27=
50/2750 entry
      V4L/DVB (12236): em28xx: stop abusing of board->decoder for sensor =
information
      V4L/DVB (12237): mt9v011: implement VIDIOC_QUERYCTRL
      V4L/DVB (12238): em28xx: call sensor detection code for all webcam =
entries
      V4L/DVB (12239): em28xx: fix webcam scaling
      V4L/DVB (12240): mt9v011: add a function to calculate frames per se=
cond rate
      V4L/DVB (12241): mt9v011: Fix vstart
      V4L/DVB (12242): mt9v011: implement core->s_config to allow adjusti=
ng xtal frequency
      V4L/DVB (12243): em28xx: allow specifying sensor xtal frequency
      V4L/DVB (12244): em28xx: adjust vinmode/vinctl based on the stream =
input format
      V4L/DVB (12245): em28xx: add support for mt9m001 webcams
      V4L/DVB (12286): sn9c20x: reorder includes to be like other drivers

Mel Gorman (5):
      profile: Suppress warning about large allocations when profile=3D1 =
is specified
      page-allocator: preserve PFN ordering when __GFP_COLD is set
      page-allocator: allow too high-order warning messages to be suppres=
sed with __GFP_NOWARN
      profile: suppress warning about large allocations when profile=3D1 =
is specified
      net-dccp: suppress warning about large allocations from DCCP

Michael Chan (1):
      cnic: Fix ISCSI_KEVENT_IF_DOWN message handling.

Michael Krufky (2):
      V4L/DVB (12302): cx23885-417: fix broken IOCTL handling
      V4L/DVB (12303): cx23885: check pointers before dereferencing in dp=
rintk macro

Michael S. Tsirkin (3):
      virtio: fix memory leak on device removal
      virtio: delete vq from list
      virtio: refactor find_vqs

Michal Simek (11):
      microblaze: Define tlb_flush macro
      microblaze: Add messages about FDT blob
      microblaze: Not to clear r7 after copying DTB to kernel
      microblaze: Clear print messages for DTB passing via r7
      microblaze: Fix put_user macro for 64bits arguments
      microblaze: Add _PAGE_FILE macros to pgtable.h
      microblaze: Fix do_page_fault for no context
      microblaze: Detect new Microblaze 7.20 versions
      microblaze: Support unaligned address for put/get_user macros
      microblaze: Add support for R_MICROBLAZE_64_NONE
      microblaze: Typo fix for cpu param inconsistency

Michel D=C3=A4nzer (6):
      drm/radeon: Endianness fixes for radeondrmfb.
      drm/radeon: Don't unreserve twice on failure to validate.
      drm/radeon: Fall back to evicting BOs with memcpy if necessary.
      drm/radeon: Pay more attention to object placement requested by use=
rspace.
      drm/radeon: Add radeon.test parameter for running BO GPU copy tests.
      drm/radeon: Fix size used for benchmarking BO copies.

Michele Jr De Candia (1):
      i2c/tsl2550: Fix lux value in dark environment

Mike Frysinger (1):
      module: use MODULE_SYMBOL_PREFIX with module_layout

Mike Snitzer (2):
      dm: remove queue next_ordered workaround for barriers
      dm table: pass correct dev area size to device_area_is_valid

Mikulas Patocka (1):
      dm raid1: wake kmirrord when requeueing delayed bios after remote r=
ecovery

Ming Lei (1):
      driver core: firmware_class:fix memory leak of page pointers array

Nicolas Ferre (4):
      dmaengine: dmatest: add a maximum number of test iterations
      dmaengine: dmatest: correct thread_count while using multiple threa=
d per channel
      dmaengine: at_hdmac: new driver for the Atmel AHB DMA Controller
      dmaengine: at_hdmac: add DMA slave transfers

Niko Jokinen (1):
      nl80211: Memory leak fixed

OGAWA Hirofumi (1):
      pty: avoid forcing 'low_latency' tty flag

Oleg Nesterov (1):
      update the comment in kthread_stop()

Oliver Neukum (2):
      Staging: serqt_usb2: fix memory leak in error case
      USB: let the option driver compile without CONFIG_PM

Pavel Roskin (1):
      mac80211: fix injection in monitor mode

Pawel Osciak (1):
      s3c-fb: fix off-by-one bug in loop indexes

Peng Huang (1):
      USB: serial: option: Add ZTE AC8710 usb modem device.

Peter Korsgaard (1):
      i2c-s3c2410: s3c24xx_i2c_init: don't clobber IICLC value

Peter Oberparleiter (1):
      sysfs: fix hardlink count on device_move

Pierre Ossman (1):
      mmc: orphan subsystem

Rafael J. Wysocki (1):
      skge: Enable WoL by default if supported

Ralf Baechle (1):
      NET: ROSE: Don't use static buffer.

Ramon de Carvalho Valle (1):
      eCryptfs: parse_tag_3_packet check tag 3 packet encrypted key size

Reinette Chatre (2):
      iwlwifi: only show active power level via sysfs
      iwlwifi: only update byte count table during aggregation

Rik van Riel (1):
      mm: copy over oom_adj value at fork time

Roel Kluin (7):
      eepro: Read buffer overflow
      Dynamic debug: fix typo: -/->
      USB: xhci: fix less- and greater than confusion
      ALSA: hda: fix out-of-bound hdmi_eld.sad[] write
      sound: aedsp16: Buffer overflow
      sound: mpu401.c: Buffer overflow
      i2c: strncpy does not null terminate string

Roland Dreier (1):
      lib: export generic atomic64_t functions

Russell Lang (1):
      USB: aten uc2324 is really a moschip 7840

Rusty Russell (4):
      lguest: fix descriptor corruption in example launcher
      lguest: fix comment style
      lguest: update commentry
      lguest and virtio: cleanup struct definitions to Linux style.

Ryan Mallon (1):
      Add ds2782 battery gas gauge driver

Sage Weil (1):
      Btrfs: make flushoncommit mount option correctly wait on ordered_ex=
tents

Sam Ravnborg (1):
      microblaze: Makefile cleanup

Sarah Sharp (15):
      USB: xhci: Set TD size in transfer TRB.
      USB: xhci: Deal with stalled endpoints.
      USB: xhci: Use GFP_ATOMIC while holding spinlocks.
      USB: xhci: Represent 64-bit addresses with one u64.
      USB: xhci: Handle short control packets correctly.
      USB: xhci: Correct Event Handler Busy flag usage.
      USB: xhci: Make debugging more verbose.
      USB: xhci: Don't oops if the host doesn't halt.
      USB: xhci: Check if the host controller died in IRQ handler.
      USB: xhci: Setup HW retries correctly.
      USB: xhci: Handle babble errors on transfers.
      USB: xhci: Fail gracefully if there's no SS ep companion descriptor.
      USB: Fix parsing of SuperSpeed Endpoint Companion descriptor.
      USB: xhci: Always align output device contexts to 64 bytes.
      USB: xhci: Stall handling bug fixes.

Sebastian Andrzej Siewior (3):
      lib/scatterlist: add a flags to signalize mapping direction
      sdhci: use SG_MITER_TO_SG/SG_MITER_FROM_SG
      cb710: use SG_MITER_TO_SG/SG_MITER_FROM_SG

Sebastian Heutling (1):
      eeprom/at25: bugfix "not ready" timeout after write

Sergei Shtylyov (1):
      USB: musb_gadget_ep0: fix typo in service_zero_data_request()

Sergey Matyukevich (1):
      libata: Updates and fixes for pata_at91 driver

Simon Kagstrom (1):
      USB: ehci-orion: Call ehci_reset before ehci_halt

Sonasath, Moiz (3):
      i2c-omap: Bug in reading the RXSTAT/TXSTAT values from the I2C_BUFF=
STAT register
      i2c-omap: In case of a NACK|ARDY|AL return from the ISR
      i2c-omap: OMAP3430 Silicon Errata 1.153

Stefan Bader (1):
      jfs: Fix early release of acl in jfs_get_acl

Steve Conklin (2):
      ata_piix: Add new laptop short cable IDs
      ata_piix: Add new short cable ID

Steve French (1):
      [CIFS] fix sparse warning

Steven Whitehouse (2):
      GFS2: Shrink the shrinker
      GFS2: Don't try and dealloc own inode

Takashi Iwai (19):
      ALSA: pcm - Fix regressions with VMware
      ALSA: hda - Use snprintf() to be safer
      ALSA: ctxfi - Fix uninitialized error checks
      ALSA: hda - Restore GPIO1 properly at resume with AD1984A
      ALSA: pcm - Add logging of hwptr updates and interrupt updates
      ALSA: pcm - Fix warnings in debug loggings
      ALSA: pcm - Fix hwptr buffer-size overlap bug
      ALSA: hda - Fix mute control with some ALC262 models
      Merge branch 'fix/asoc' into for-linus
      Merge branch 'fix/caiaq' into for-linus
      Merge branch 'fix/ctxfi' into for-linus
      Merge branch 'fix/hda' into for-linus
      Merge branch 'fix/pcm-hwptr' into for-linus
      Merge branch 'fix/usb-audio' into for-linus
      ALSA: hda - Add quirk for Dell Studio 1555
      ALSA: hda - Increase PCM stream name buf in patch_realtek.c
      Merge branch 'fix/hda' into for-linus
      Merge branch 'fix/misc' into for-linus
      Merge branch 'fix/oss' into for-linus

Tejun Heo (1):
      libata: accept late unlocking of HPA

Thadeu Lima de Souza Cascardo (1):
      rtc: mark if rtc-cmos drivers were successfully registered

Thomas Gleixner (1):
      x86: geode: Mark mfgpt irq IRQF_TIMER to prevent resume failure

Thomas Hellstrom (6):
      ttm: Make messages more readable.
      ttm: Fix caching mode selection.
      drm/ttm: Fix an oops and sync object leak.
      drm/ttm: Fix ttm in-kernel copying of pages with non-standard cachi=
ng attributes.
      x86: Export kmap_atomic_prot() needed for TTM.
      drm/ttm: powerpc: Fix Highmem cache flushing.

Tim Gardner (1):
      USB: option: Add USB ID for Novatel MC727/U727/USB727 refresh

Trent Piepho (1):
      V4L/DVB (12291): b2c2: fix frontends compiled into kernel

Tyler Hicks (1):
      eCryptfs: Check Tag 11 literal data buffer size

Uros Bizjak (1):
      x86: Fix movq immediate operand constraints in uaccess_64.h

Uwe Kleine-K=C3=B6nig (1):
      register at91_ether using platform_driver_probe

Ville Sundberg (1):
      USB: ftdi_sio: Add support for GN Otometrics Aurical USB Audiometer

Wan Wei (1):
      amd64_edac: read the right F2 maskoffset reg

Wolfram Sang (1):
      pata_pcmcia: add CNF-CDROM-ID

Xiaotian Feng (3):
      net/bridge: use kobject_put to release kobject in br_add_if error p=
ath
      block: fix improper kobject release in blk_integrity_unregister
      driver core: sysdev: do not send KOBJ_ADD uevent if kobject_init_an=
d_add fails

Yan Zheng (10):
      Btrfs: fix definition of struct btrfs_extent_inline_ref
      Btrfs: properly update space information after shrinking device.
      Btrfs: fix double increment of path->slots[0] in btrfs_next_leaf
      Btrfs: fix locking issue in btrfs_find_next_key
      Btrfs: make sure all dirty blocks are written at commit time
      Btrfs: find_free_dev_extent doesn't handle holes at the start of th=
e device
      Btrfs: Fix ordering of key field checks in btrfs_previous_item
      Btrfs: Avoid delayed reference update looping
      Btrfs: Fix async caching interaction with unmount
      Btrfs: preserve commit_root for async caching

Yi Zou (1):
      ixgbe: Enable FCoE offload when DCB is enabled for 82599

Zhu Yi (1):
      iwmc3200wifi: fix NULL pointer dereference in iwm_if_free

dingdinghua (1):
      jbd: fix race between write_metadata_buffer and get_write_access

fran=C3=A7ois romieu (1):
      r8169: WakeOnLan fix for the 8168

roel kluin (3):
      fealnx: Write outside array bounds
      at1700: Read buffer overflow
      tokenring: Read buffer overflow

unsik Kim (3):
      mg_disk: remove prohibited sleep operation
      mg_disk: fix reading invalid status when use polling driver
      mg_disk: Add missing ready status check on mg_write()

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr

--===============4994770047321562215==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============4994770047321562215==--
