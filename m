From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr annotated tag, v2.6.31-rc7, created. v2.6.31-rc7
Date: Wed, 16 Sep 2009 14:36:59 -0400
Message-ID: <200909161836.n8GIaxFR001695@gorgona.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4928638683368140246=="
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

--===============4928638683368140246==
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by smtp1.linux-foundation.org id n8GIuWf3005602

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The annotated tag, v2.6.31-rc7 has been created
        at  dcd5e628b7dc7f393dd728999fb0fb73a96d5e1b (tag)
   tagging  422bef879e84104fee6dc68ded0e371dbeb5f88e (commit)
  replaces  v2.6.31-rc6
 tagged by  Linus Torvalds
        on  Fri Aug 21 18:00:58 2009 -0700

- Log -----------------------------------------------------------------
Linux 2.6.31-rc7
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkqPQ04ACgkQF3YsRnbiHLueEACfYdMhUrN56WJfJavKnWQX6R32
P70An0E2WzhePcyqrVwSY1MjmZmV/0vC
=3DJfvo
-----END PGP SIGNATURE-----

Alex Deucher (1):
      drm/radeon: add GET_PARAM/INFO support for Z pipes

Amerigo Wang (1):
      percpu: use the right flag for get_vm_area()

Amit Kumar Salecha (1):
      netxen: remove netxen workqueue

Andreas Schwab (1):
      security: Fix prompt for LSM_MMAP_MIN_ADDR

Andrew Morton (1):
      mmc: add the new linux-mmc mailing list to MAINTAINERS

Andy Walls (1):
      V4L/DVB (12338): cx18: Read buffer overflow

Anton Blanchard (1):
      AFS: Documentation updates

Antonio Ospite (1):
      V4L/DVB (12330): pxa_camera: Fix Oops in pxa_camera_probe

Arnaldo Carvalho de Melo (1):
      perf record: Fix typo in pid_synthesize_comm_event

Atsushi Nemoto (1):
      MIPS: Fix HPAGE_SIZE redefinition

Bartlomiej Zolnierkiewicz (1):
      x86, mce: don't log boot MCEs on Pentium M (model =3D=3D 13) CPUs

Ben Dooks (2):
      spi_s3c24xx: fix clock rate calculation
      spi_s3c24xx: fix transfer setup code

Bo Liu (1):
      mm: build_zonelists(): move clear node_load[] to __build_all_zoneli=
sts()

Bob Dunlop (1):
      libertas: correct packing of rxpd structure

Brian Johnson (1):
      V4L/DVB (12373a): Add gspca sn9c20x subdriver entry to MAINTAINERS =
file

Bruce Allan (3):
      e1000e: fix acquisition of SW/FW/HW semaphore for ICHx parts
      e1000e: fix potential NVM corruption on ICH9 with 8K bank size
      e1000e: WoL does not work on 82577/82578 with manageability enabled

Carlos R. Mafra (1):
      perf: Rename perf-examples.txt to examples.txt

Chris Snook (1):
      MAINTAINERS: update atlx contact info

Christian Lamparter (1):
      ar9170usb: fix spurious firmware related message

Christoph Hellwig (2):
      xfs: fix locking in xfs_iget_cache_hit
      microblaze: use the generic ack_bad_irq implementation

Cliff Wickman (1):
      x86: Fix UV BAU destination subnode id

Dan Carpenter (1):
      ar9170: fix read & write outside array bounds

Dave Airlie (10):
      drm/edid: fixup detailed timings like the X server.
      drm/radeon/kms: add rv530 R300_SU_REG_DEST + reloc for ZPASS_ADDR
      drm/radeon/kms: cut down indirects in register accesses.
      drm/radeon/kms: implement bo busy check + current domain
      drm/radeon/kms: although LVDS might be possible on crtc 1 don't do =
it.
      drm/radeon/kms: memset the allocated framebuffer before using it.
      drm/kms/radeon: cleanup combios TV table like DDX.
      drm/kms: teardown crtc correctly when fb is destroyed.
      drm/radeon/kms: implement the bo busy ioctl properly.
      drm/radeon/kms: add r100/r200 OQ support.

Dave Jones (1):
      security: Make LSM_MMAP_MIN_ADDR default match its help text.

David S. Miller (5):
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/lowpan/lowpan
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-2.6
      Merge branch 'master' of /home/davem/src/GIT/linux-2.6/
      Revert "libertas: Read buffer overflow"
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-2.6

Davide Rizzo (1):
      ARM: S3C24XX: Fix clkout mpx error

Devin Heitmueller (3):
      V4L/DVB (12393): cx88: fix regression in tuning for Geniatech X8000=
 MT
      V4L/DVB (12394): cx88: Disable xc3028 power management for Geniatec=
h x8000
      V4L/DVB (12432): em28xx: fix regression in Empire DualTV digital tu=
ning

Dhananjay Phadke (2):
      netxen: fix dma mask update calculation
      netxen: free napi resources during detach

Dmitry Eremin-Solenikov (2):
      af_ieee802154: fix ioctl processing
      af_ieee802154: provide dummy get/setsockopt

Don Skidmore (1):
      ixgbe: fix issues setting rx-usecs with legacy interrupts

Dongdong Deng (1):
      drivers/net: fixed drivers that support netpoll use ndo_start_xmit(=
)

Eero Nurkkala (1):
      OMAP: PM: CPUfreq: obey min/max settings of policy

Eric Dumazet (8):
      phonet: phonet_device_get() fix
      rose: Fix rose_getname() leak
      econet: Fix econet_getname() leak
      netrom: Fix nr_getname() leak
      appletalk: fix atalk_getname() leak
      irda: Fix irda_getname() leak
      can: Fix raw_getname() leak
      net: restore gnet_stats_basic to previous definition

Eric Paris (7):
      Capabilities: move cap_file_mmap to commoncap.c
      SELinux: call cap_file_mmap in selinux_file_mmap
      Security/SELinux: seperate lsm specific mmap_min_addr
      security: define round_hint_to_min in !CONFIG_SECURITY
      notify: unused event private race
      inotify: tail drop inotify q_overflow events
      inotify: start watch descriptor count at 1

Francois Romieu (1):
      8139cp: balance dma_map_single vs dma_unmap_single pair

From: Nick Piggin (1):
      btrfs: fix inode rbtree corruption

Graff Yang (1):
      nommu: check fd read permission in validate_mmap_request()

Greg Ungerer (1):
      fec: fix FEC driver packet transmission breakage

Guennadi Liakhovetski (2):
      mx3: Fix double pin allocation in pcm037_eet.c
      V4L/DVB (12424): soc-camera: fix recursive locking in .buf_queue()

Guillaume Knispel (1):
      poll/select: initialize triggered field of struct poll_wqueues

Hans Verkuil (2):
      V4L/DVB (12428): hdpvr: add missing initialization of current_norm
      V4L/DVB (12429): v4l2-ioctl: fix G_STD and G_PARM default handlers

Herbert Xu (1):
      tun: Extend RTNL lock coverage over whole ioctl

Hugh Dickins (1):
      x86, mce: therm_throt: Don't log redundant normality

Ingo Molnar (3):
      x86, mce: Don't initialize MCEs on unknown CPUs
      perf_counter: Fix the PARISC build
      perf annotate: Fix segmentation fault

Jan Nikitenko (1):
      V4L/DVB (12341): zl10353 and qt1010: fix stack corruption bug

Janboe Ye (1):
      OMAP3: Fix omap3 sram virtual addres overlap vmalloc space after in=
creasing vmalloc size

Jean Pihet (2):
      OMAP3 SDRC: add support for 2 SDRAM chip selects
      OMAP3: Setup MUX settings for SDRC CKE signals

Jeff Layton (1):
      vfs: make get_sb_pseudo set s_maxbytes to value that can be cast to=
 signed

Jerome Glisse (1):
      drm/radeon/kms: Add specific rs690 authorized register table

Joe Perches (3):
      MAINTAINERS: additional NETWORKING [GENERAL] and NETWORKING DRIVERS=
 patterns
      MAINTAINERS: OSD LIBRARY and FILESYSTEM pattern fix
      REPORTING-BUGS: add get_maintainer.pl blurb

John Williams (1):
      microblaze: Sane handling of missing timer/intc in device tree

Jouni Hogander (1):
      OMAP3: PM: Fix wrong sequence in suspend.

Jussi M=C3=A4ki (1):
      Fix xfrm hash collisions by changing __xfrm4_daddr_saddr_hash to ha=
sh addresses with addition

KOSAKI Motohiro (1):
      mm: revert "oom: move oom_adj value"

Kevin Hilman (11):
      OMAP2/3: PM: make PM __init calls static
      OMAP3: PM: CM_REGADDR macros using wrong name
      OMAP3: PM: Ensure PRCM interrupts are cleared at boot
      OMAP3: PM: Clear pending PRCM reset flags on init
      OMAP3: PM: prevent module wakeups from waking IVA2
      OMAP3: PM: Do not build suspend code if SUSPEND is not enabled
      OMAP4: UART: cleanup special case IRQ handling
      OMAP2/3/4: UART: Allow per-UART disabling wakeup for serial ports
      OMAP2/3/4: UART: allow in-order port traversal
      OMAP: GPIO: clear/restore level/edge detect settings on mask/unmask
      OMAP3: Overo: add missing pen-down GPIO definition

Kyle McMartin (1):
      perf tools: Make 'make html' work

Laurent Pinchart (2):
      V4L/DVB (12328): uvcvideo: Don't apply the FIX_BANDWIDTH quirk to a=
ll ViMicro devices
      V4L/DVB (12380): uvcvideo: Avoid flooding the kernel log with "unkn=
own event type" messages

Lennert Buytenhek (5):
      mwl8k: fix NULL pointer dereference on receive out-of-memory
      mwl8k: add various missing GET_HW_SPEC endian conversions
      mwl8k: call pci_unmap_single() before accessing command structure a=
gain
      mwl8k: prevent crash in ->configure_filter() if no interface was ad=
ded
      mwl8k: prevent module unload hang

Leonardo Potenza (1):
      x86: Annotate section mismatch warnings in kernel/apic/x2apic_uv_x.=
c

Linus Torvalds (26):
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/mchehab/linux-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/steve/gfs2-2.6-=
fixes
      Merge master.kernel.org:/home/rmk/linux-2.6-arm
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jmorris/security-testing-2.6
      Merge branch 'for-linus' of git://oss.sgi.com/xfs/xfs
      Merge branch 'upstream' of git://ftp.linux-mips.org/pub/scm/upstrea=
m-linus
      Merge branch 'for-linus' of git://neil.brown.name/md
      Merge branch 'sh/for-2.6.31' of git://git.kernel.org/pub/scm/linux/=
kernel/git/lethal/sh-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'irq-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tj/percpu
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jmorris/security-testing-2.6
      Merge branch 'perfcounters-fixes-for-linus-2' of git://git.kernel.o=
rg/pub/scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'next' of git://git.monstr.eu/linux-2.6-microblaze
      Merge branch 'drm-fixes' of git://git.kernel.org/pub/scm/linux/kern=
el/git/airlied/drm-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/ryusuke/nilfs2
      Merge branch 'fix/hda' of git://git.kernel.org/pub/scm/linux/kernel=
/git/tiwai/sound-2.6
      Merge branch 'i2c-fixes-rc6' of git://aeryn.fluff.org.uk/bjdooks/li=
nux
      x86: don't send an IPI to the empty set of CPU's
      Make bitmask 'and' operators return a result code
      x86: don't call '->send_IPI_mask()' with an empty mask
      Merge branch 'btrfs' of git://git.kernel.dk/linux-2.6-block
      Merge branch 'drm-fixes' of git://git.kernel.org/pub/scm/linux/kern=
el/git/airlied/drm-2.6
      Re-introduce page mapping check in mark_buffer_dirty()
      Linux 2.6.31-rc7

Linus Walleij (2):
      ARM: 5673/1: U300 fix initsection compile warning
      i2c-stu300: I2C STU300 stability updates

Lucy Liu (1):
      ixgbe: Fix receive on real device when VLANs are configured

Luis R. Rodriguez (1):
      mac80211: fix panic when splicing unprepared TIDs

Magnus Damm (4):
      sh: skip disabled LCDC channels
      sh: CMT suspend/resume
      sh: use in-soc KEYSC on se7724
      sh: sh7724 ddr self-refresh changes

Matthias Schwarzott (1):
      V4L/DVB (12440): Use kzalloc for frontend states to have struct dvb=
_frontend properly

Mauro Carvalho Chehab (12):
      V4L/DVB (12340): mtv9v011: Add a missing chip version to the driver
      V4L/DVB (12344): em28xx: fix support for Plextor ConvertX PX-TV100U
      V4L/DVB (12399): mt9v011: Add support for controlling frame rates
      V4L/DVB (12400): em28xx: Allow changing fps on webcams
      V4L/DVB (12401): m9v011: add vflip/hflip controls to control mirror=
/upside down
      V4L/DVB (12402): em28xx: fix: some em2710 chips use a different ven=
dor ID
      V4L/DVB (12403): em28xx: properly reports some em2710 chips
      V4L/DVB (12406): em28xx: fix: don't do image interlacing on webcams
      V4L/DVB (12407): em28xx: Adjust Silvercrest xtal frequency
      V4L/DVB (12410): em28xx: Move the non-board dependent part to be ou=
tside em28xx_pre_card_setup()
      V4L/DVB (12411): em28xx: Fix artifacts with Silvercrest webcam
      V4L/DVB (12405): em28xx-cards: move register 0x13 setting to the pr=
oper place

Michael Chan (5):
      cnic: Fix symbol_put_addr() panic on ia64.
      cnic: Refine registration with bnx2.
      bnx2: Use mutex on slow path cnic calls.
      cnic: Fix locking in start/stop calls.
      cnic: Fix locking in init/exit calls.

Michael Krufky (5):
      V4L/DVB (12362): cx23885-417: fix manipulation of tvnorms
      V4L/DVB (12374): sms1xxx: fix broken Hauppauge devices
      V4L/DVB (12386): sms1xxx: fix build warning: unused variable 'board=
'
      V4L/DVB (12390): saa7134: Use correct product name for Hauppauge Wi=
nTV-HVR1150 ATSC/QAM-Hybrid
      V4L/DVB (12391): saa7134: Use correct product name for Hauppauge Wi=
nTV-HVR1120 DVB-T/Hybrid

Michal Simek (3):
      microblaze: Enable ppoll syscall
      microblaze: Use klimit instead of _end for memory init
      microblaze: Update Microblaze defconfigs

Michel D=C3=A4nzer (1):
      drm/radeon/kms: Fix up vertical blank interrupt support.

Mikael Pettersson (1):
      IXP4xx: Fix IO_SPACE_LIMIT for 2.6.31-rc core PCI changes

Moiz Sonasath (2):
      i2c-omap: ACK pending [R/X]DR and [R/X]RDY interrupts
      i2c-omap: Enable workaround for Errata 1.153 based on

NeilBrown (1):
      Fix new incorrect error return from do_md_stop.

Nils Kassube (1):
      V4L/DVB (12371): af9015: Fix for crash in dvb-usb-af9015

Nishanth Menon (1):
      i2c-omap: Fix I2C status ACK

Oliver Hartkopp (1):
      can: fix oops caused by wrong rtnl newlink usage

Pascal Terjan (1):
      Add IDs for 3C905B-TX Fast Etherlink XL PCI

Paul Mackerras (1):
      perf_counter: Check task on counter read IPI

Paul Walmsley (4):
      OMAP2/3 SDRC: don't set SDRC_POWER.PWDENA on boot
      OMAP2/3 clock: split, rename omap2_wait_clock_ready()
      OMAP2 clock: 2430 I2CHS uses non-standard CM_IDLEST register
      OMAP3 clock: correct module IDLEST bits: SSI; DSS; USBHOST; HSOTGUS=
B

Pavel Roskin (1):
      rt2x00: fix memory corruption in rf cache, add a sanity check

Petko Manolov (1):
      pegasus: Add new device ID.

Rafael Laufer (1):
      sctp: fix missing destroy of percpu counter variable in sctp_proc_e=
xit()

Rajendra Nayak (2):
      OMAP3 SDRC: Fix freeze when scaling CORE dpll to < 83Mhz
      OMAP3 SDRC: Move the clk stabilization delay to the right place

Ralf Baechle (1):
      NETROM: Fix use of static buffer

Ramax Lo (1):
      ARM: S3C64XX: serial: Fix a typo in Kconfig

Randy Dunlap (3):
      V4L/DVB (12422): media/zr364xx: fix build errors
      V4L/DVB (12437): dvb: siano uses/depends on INPUT
      dm-log-userspace: fix printk format warning

Roel Kluin (6):
      irda: fix read buffer overflow
      atlx: strncpy does not null terminate string
      V4L/DVB (12337): ivtv: Read buffer overflow
      V4L/DVB (12436): stk-webcam: read buffer overflow
      V4L/DVB (12438): Read buffer overflow
      V4L/DVB (12441): siano: read buffer overflow

Roger Quadros (4):
      OMAP: GPIO: Fix incorrect gpio_get logic for output GPIOs
      OMAP3: RX51: Define TWL4030 USB transceiver in board file
      OMAP2/3: mmc-twl4030: Free up MMC regulators while cleaning up
      OMAP3: RX51: Updated rx51_defconfig

Russell King (7):
      Merge branch 'omap-fixes' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/tmlind/linux-omap-2.6
      Merge branch 'omap_fixes_31' of git://git.pwsan.com/linux-2.6
      Merge branch 'pm-upstream/fixes' of git://git.kernel.org/pub/scm/li=
nux/kernel/git/khilman/linux-omap-pm
      Merge branch 'ixp4xx-fixes' of git://git.kernel.org/pub/scm/linux/k=
ernel/git/chris/linux-2.6
      ARM: Fix broken highmem support
      Merge branch 'for-rmk-rc' of git://git.pengutronix.de/git/imx/linux=
-2.6
      Merge branch 's3c-fixes' of git://aeryn.fluff.org.uk/bjdooks/linux

Ryusuke Konishi (1):
      nilfs2: fix oopses with doubly mounted snapshots

Sergio Aguirre (1):
      OMAP3: Overo: Fix smsc911x platform device resource value

Sohail Syyed (1):
      V4L/DVB (12349): cx88: HVR1300 ensure switching from Encoder to DVB=
-T and back is reliable

Steven Whitehouse (1):
      GFS2: Fix permissions on "recover" file

Takashi Iwai (1):
      ALSA: hda - Fix probe of Toshiba laptops with ALC268 codec

Tejun Heo (2):
      init: set nr_cpu_ids before setup_per_cpu_areas()
      percpu, sparc64: fix sparse possible cpu map handling

Tero Kristo (1):
      OMAP3: Fixed crash bug with serial + suspend

Thomas Gleixner (1):
      genirq: Wake up irq thread after action has been installed

Thomas Hellstrom (1):
      drm: Fix sysfs device confusion.

Tom Goff (1):
      gre: Fix MTU calculation for bound GRE tunnels

Tony Lindgren (1):
      OMAP: Fix testing of cpu defines for mach-omap1

Valentin Longchamp (1):
      mx31moboard: invert sdhc ro signal sense

Vikram Pandita (1):
      OMAP2/3: DMA errata correction

Wei Yongjun (1):
      dccp: missing destroy of percpu counter variable while unload modul=
e

Wu Fengguang (2):
      ALSA: hda: enable speaker output for Compaq 6530s/6531s
      ALSA: hda: add model for Intel DG45ID/DG45FC boards

Xiaotian Feng (1):
      e1000e: fix use of pci_enable_pcie_error_reporting

Yi Zou (3):
      ixgbe: Pass rx_ring directly in ixgbe_configure_srrctl()
      ixgbe: Disable packet split only on FCoE queues in 82599
      ixgbe: Do not return 0 in ixgbe_fcoe_ddp() upon FCP_RSP in DDP comp=
letion

Yong Zhang (1):
      gianfar: keep vlan related state when restart

Zhang Qiang (1):
      nilfs2: missing a read lock for segment writer in nilfs_attach_chec=
kpoint()

Zhu Yi (1):
      ipw2x00: Write outside array bounds

roel kluin (4):
      pcnet32: Read buffer overflow
      zorro8390: Fix read buffer overflow in zorro8390_init_one()
      mlx4_en: Fix read buffer overflow in mlx4_en_complete_rx_desc()
      via-velocity: Fix test of mii_status bit VELOCITY_DUPLEX_FULL

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr

--===============4928638683368140246==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============4928638683368140246==--
