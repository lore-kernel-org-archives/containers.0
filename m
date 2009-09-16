From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr annotated tag, v2.6.30-rc6, created. v2.6.30-rc6
Date: Wed, 16 Sep 2009 14:36:51 -0400
Message-ID: <200909161836.n8GIapYr001481@gorgona.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6812421356684794723=="
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

--===============6812421356684794723==
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by smtp1.linux-foundation.org id n8GIwx8J006292

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The annotated tag, v2.6.30-rc6 has been created
        at  6492b02a211a5fd0fc92e68d171fc3644cda71a7 (tag)
   tagging  1406de8e11eb043681297adf86d6892ff8efc27a (commit)
  replaces  v2.6.30-rc5
 tagged by  Linus Torvalds
        on  Fri May 15 21:13:13 2009 -0700

- Log -----------------------------------------------------------------
Linux 2.6.30-rc6
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkoOPWAACgkQF3YsRnbiHLuhmQCfcHa5nZ4r1eJwf98Bp3cGxB65
r4sAn3dDoClfb18N0tlRsCdUEScgFAQn
=3D1bzd
-----END PGP SIGNATURE-----

Adrian Batzill (1):
      Input: atkbd - add force release keys quirk for Amilo Xi 3650

Al Viro (11):
      Always lookup priv_root on reiserfs mount and keep it
      New helper: deactivate_locked_super()
      Convert obvious places to deactivate_locked_super()
      Fix a leak in failure exit in 9p ->get_sb()
      Fix deadlock in ipathfs ->get_sb()
      Reduce path_lookup() abuses
      Make open_exec() and sys_uselib() use may_open(), instead of duplic=
ating its parts
      Switch open_exec() and sys_uselib() to do_open_filp()
      switch ufs directories to ufs_sync_file()
      Fix races around the access to ->s_options
      Fix the race between capifs remount and node creation

Alan Cox (2):
      ata_piix: ICH7 does not support correct MWDMA timings
      ata_piix: The Sony TZ90 needs the cable type hardcoding

Alan Stern (3):
      USB: Gadget: fix UTF conversion in the usbstring library
      usb-serial: ftdi_sio: fix reference counting of ftdi_private
      HID: add NOGET quirk for devices from CH Products

Alessio Igor Bogani (1):
      vfs: umount_begin BKL pushdown

Alexander Beregalov (1):
      viocd: needs to depend on BLOCK

Alexander Duyck (1):
      igb: resolve panic on shutdown when SR-IOV is enabled

Andre Przywara (1):
      KVM: SVM: Fix cross vendor migration issue with unusable bit

Andreas Schwab (1):
      iwlwifi: remove EXPORT_SYMBOL for static symbol

Andy Adamson (1):
      nfsd41: slots are freed with session

Andy Lutomirski (1):
      USB: Fix makefile so that CONFIG_WDM and CONFIG_TMC work.

Aneesh Kumar K.V (3):
      ext4: Fix sub-block zeroing for writes into preallocated extents
      ext4: Use a fake block number for delayed new buffer_head
      ext4: Clear the unwritten buffer_head flag after the extent is init=
ialized

Anton Vorontsov (1):
      powerpc/fsl_soc: Remove mpc83xx_wdt_init, again

Arnd Bergmann (1):
      syscalls.h add the missing sys_pipe2 declaration

Ashish Karkare (1):
      net: remove stale reference to fastroute from Kconfig help text

Atsushi Nemoto (4):
      MIPS: RBTX4939: Fix typo in system name
      MIPS: Do not include seccomp.h from compat.h
      MIPS: Synchronize dma_map_page and dma_map_single
      MIPS: TXx9: Fix possible overflow in clock calculations

Avi Kivity (3):
      KVM: Fix NX support reporting
      KVM: Make EFER reads safe when EFER does not exist
      KVM: SVM: Remove port 80 passthrough

Bartlomiej Zolnierkiewicz (1):
      pata_pdc202xx_old: fix UDMA33 handling

Becky Bruce (1):
      powerpc: Allow mem=3Dx cmdline to work with 4G+

Ben Nizette (1):
      ipu_idmac: Use disable_irq_nosync() from within irq handlers.

Benjamin Herrenschmidt (2):
      powerpc/pseries: Really fix the oprofile CPU type on pseries
      powerpc: Fix PCI ROM access

Benjamin Krill (1):
      serial/nwpserial: Fix wrong register read address and add interrupt=
 acknowledge.

Bob Copeland (1):
      ath5k: update channel in sw state after stopping RX and TX

Borislav Petkov (1):
      libata: fix suspend/resume for ATA SEMB devices

Carl Worth (1):
      drm/i915: Add new GET_PIPE_FROM_CRTC_ID ioctl.

Chris Mason (3):
      Btrfs: init inode ordered_data_close flag properly
      Btrfs: Don't loop forever on metadata IO failures
      Btrfs: remove some WARN_ONs in the IO failure path

Chris Zankel (3):
      xtensa: Fix architecture specific Kconfig
      xtensa: Fix checksum header file
      xtensa: Fix linker script to include .literal sections

Christoph Hellwig (1):
      romfs: cleanup romfs_fs.h

Christoph Paasch (1):
      netfilter: ip6t_ipv6header: fix match on packets ending with NEXTHD=
R_NONE

Clemens Ladisch (2):
      sound: serial-u16550: fix buffer overflow
      sound: via82xx: fix DXS volume range

Coly Li (1):
      MIPS: Cavium: Add struct clocksource * argument to octeon_cvmcount_=
read()

Dan Carpenter (1):
      Remove unreached code in drivers/net/mlx4/en_rx.c

Dan Williams (1):
      dmatest: fix max channels handling

Daniel Ribeiro (1):
      pxa2xx_spi: prevent panic case setup() fails

Dave Hayes (1):
      Staging: rt2870: new device id

Dave Liu (1):
      sata_fsl: Fix the command description of FSL SATA controller

David Brownell (3):
      ASoC: davinci-pcm buildfixes
      ASoC: DaVinci I2S updates
      ASoC: DaVinci EVM board support buildfixes

David Daney (2):
      MIPS: Compat: Use generic 32-bit wrapers for sys_timerfd_{g,s}ettim=
e
      MIPS: Use force_sig when handling address errors.

David Milburn (1):
      [libata] sata_sx4: fixup interrupt handling

David S. Miller (5):
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-2.6
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/kaber/nf-2.6
      Merge branch 'linux-2.6.30.y' of git://git.kernel.org/pub/scm/linux=
/kernel/git/inaky/wimax
      ipv4: Make INET_LRO a bool instead of tristate.
      Merge branch 'net-fixes' of git://git.kernel.org/pub/scm/linux/kern=
el/git/chris/linux-2.6

David Woodhouse (1):
      intel-iommu: PAE memory corruption fix

Davide Libenzi (1):
      epoll: fix size check in epoll_create()

Dmitri Vorobiev (4):
      MIPS: IP32: Two symbols can become static
      MIPS: IP32: ip32_be_handler symbol is needlessly defined global
      MIPS: IP32: Fix needlessly global symbols in arch/mips/sgi-ip32/ip3=
2-irq.c
      MIPS: gbe: Make needlessly global symbols static in drivers/video/g=
befb.c

Doug Chapman (1):
      Squashfs: fix breakage when page size > metadata block size

Eric Anholt (1):
      drm/i915: Don't allow binding objects into the last page of the ape=
rture.

Florian Westphal (1):
      bonding: fix panic if initialization fails

Frank Rowand (1):
      kgdb: gdb documentation fix

Gerhard Stenzel (1):
      powerpc/cell: Make ptcal more reliable

Grant Likely (2):
      powerpc/boot: add simpleImage.* to clean-files list
      powerpc/virtex: Add uImage to the default images list

Greg Kroah-Hartman (2):
      Revert driver core: move platform_data into platform_device
      Staging: comedi: David doesn't want to get comedi patches

Guennadi Liakhovetski (1):
      dma: fix ipu_idmac.c to not discard the last queued buffer

H Hartley Sweeten (1):
      NULL noise in fs/super.c:kill_bdev_super()

Hans Verkuil (5):
      V4L/DVB (11668): ivtv: fix compiler warning.
      V4L/DVB (11669): uvc: fix compile warning
      V4L/DVB (11674): ivtv: fix incorrect bit tests
      V4L/DVB (11675): ivtv/radio: fix V4L2_TUNER_MODE/V4L2_TUNER_SUB con=
fusion
      V4L/DVB (11679): cafe_ccic: fix sensor detection

Harald Welte (1):
      viafb: make it work on x86_64

Henrik Austad (1):
      Doc/sysfs-rules: Swap the order of the words so the sentence makes =
more sense

Inaky Perez-Gonzalez (2):
      wimax: fix oops if netlink fails to add attribute
      wimax: oops: wimax_dev_add() is the only one that can initialize th=
e state

J. Bruce Fields (3):
      nfsd4: check for negative dentry before use in nfsv4 readdir
      lockd: fix list corruption on lockd restart
      nfsd: silence lockdep warning

Jack Morgenstein (1):
      IB/mlx4: Don't overwrite fast registration page list when posting w=
ork request

Jarod Wilson (1):
      drm/i915: ignore LVDS on intel graphics systems that lie about havi=
ng it

Jaroslav Kysela (1):
      ALSA: Release v1.0.20

Jason Baron (1):
      Remove old PRINTK_DEBUG config item

Jason Wessel (2):
      sysrq, intel_fb: fix sysrq g collision
      kgdb,i386: use address that SP register points to in the exception =
frame

Jay Sternberg (1):
      iwlwifi: fix device id registration for 6000 series 2x2 devices

Jean Delvare (1):
      fbdev: remove outdated advice about I2C configuration

Jeff Garzik (1):
      [libata] sata_sx4: convert to new exception handling methods

Jeff Layton (1):
      cifs: fix error handling in parse_DFS_referrals

Jeff Mahoney (5):
      reiserfs: Expand i_mutex to enclose lookup_one_len
      reiserfs: fixup xattr_root caching
      reiserfs: dont associate security.* with xattr files
      reiserfs: remove privroot hiding in lookup
      dup2: Fix return value with oldfd =3D=3D newfd and invalid fd

Jens Axboe (1):
      Revert "mm: add /proc controls for pdflush threads"

Jesper Nilsson (4):
      CRIS: Merge machine dependent boot/compressed and boot/rescue
      CRISv32: Remove obsolete vcs_hook.o from Makefile
      CRIS: Wire up syscalls signalfd4 to writev.
      CRISv32: Fix typo compile error in ARTPEC-3 gpio driver.

Jesse Barnes (2):
      drm/i915: automatically select FRAMEBUFFER_CONSOLE if !EMBEDDED
      drm/i915: sanity check IER at wait_request time

Jinyoung Park (1):
      ASoC: Fix errors in WM8990

Jiri Slaby (2):
      mac80211: minstrel, fix memory corruption
      mac80211: pid, fix memory corruption

Joel Becker (1):
      ocfs2: Use nd_set_link().

Johannes Berg (2):
      mac80211: correct fragmentation threshold check
      cfg80211: fix truncated IEs

Johannes Weiner (2):
      xtensa: always use correct stack pointer for stack traces
      xtensa: register gpio chip before use

John Linn (1):
      powerpc/virtex: Fix duplicate level irq events.

John W. Linville (3):
      airo: airo_get_encode{,ext} potential buffer overflow
      mac80211: avoid NULL ptr deref when finding max_rates in PID and mi=
nstrel
      rtl8187: use DMA-aware buffers with usb_control_msg

Jussi Kivilinna (1):
      Input: ff-memless - fix signed to unsigned bit overflow

Kazuhisa Ichikawa (1):
      block: fix the bio_vec array index out-of-bounds test

Keith Packard (2):
      drm/i915: x86 always has writeq. Add I915_READ64 for symmetry.
      drm/i915: save/restore fence registers across suspend/resume

Kevin D. Kissell (2):
      MIPS: SMTC: Bring set/clear/change_c0_## return value semantics upt=
odate.
      MIPS: SMTC: Fix xxx_clockevent_init() naming conflict for SMTC

Kim Kyuwon (1):
      rtc: rtc-twl4030 don't mask alarm interrupts on suspend

Krzysztof Ha=C5=82asa (2):
      IXP4xx: use "ENODEV" instead of "ENOSYS" in module initialization.
      IXP4xx: complete Ethernet netdev setup before calling register_netd=
ev().

Kumar Gala (7):
      powerpc/83xx: Update defconfigs
      powerpc/85xx: Update defconfigs
      powerpc/86xx: Update defconfigs
      powerpc/embedded6xx: Update defconfigs
      powerpc/8xx: Update defconfigs
      powerpc/mpic: Fix incorrect allocation of interrupt rev-map
      sata_fsl: Fix compile warnings

Larry Finger (1):
      Staging: rtl8187se: Fix compilation warnings and procfs directory l=
eak

Lennert Buytenhek (1):
      net: update skb_recycle_check() for hardware timestamping changes

Li Hong (1):
      Btrfs: remove outdated comment in btrfs_ioctl_resize()

Linus Torvalds (37):
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/mchehab/linux-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/steve/gfs2-2.6-=
fixes
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/viro/vfs-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-c=
ore-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/usb-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging-=
2.6
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/jgarzik/libata-dev
      Merge branch 'for-linus' of git://repo.or.cz/cris-mirror
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/dtor/input
      Merge branch 'i2c-for-2630-rc5' of git://aeryn.fluff.org.uk/bjdooks=
/linux
      Merge branch 'for-2.6.30' of git://linux-nfs.org/~bfields/linux
      Merge branch 'fixes' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/djbw/async_tx
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jikos/hid
      Revert "Ignore madvise(MADV_WILLNEED) for hugetlbfs-backed regions"
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jbarnes/drm-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/roland/infiniband
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/ryusuke/nilfs2
      Merge branch 'kvm-updates/2.6.30' of git://git.kernel.org/pub/scm/v=
irt/kvm/kvm
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/mszeredi/fuse
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/pkl/squashfs-li=
nus
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/czankel/xtensa-=
2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/mason/btrfs-uns=
table
      Merge branch 'upstream' of git://ftp.linux-mips.org/pub/scm/upstrea=
m-linus
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/sfrench/cifs-2.=
6
      Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/benh/powerpc
      Merge branch 'for-linus' of git://git.kernel.dk/linux-2.6-block
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jwessel/linux-2.6-kgdb
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tytso/ext4
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/linville/wirele=
ss-2.6
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/jgarzik/libata-dev
      Merge branch 'drm-intel-next' of git://git.kernel.org/pub/scm/linux=
/kernel/git/anholt/drm-intel
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/blueto=
oth-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jbarnes/pci-2.6
      Linux 2.6.30-rc6

Luis R. Rodriguez (3):
      cfg80211: fix race condition with wiphy_apply_custom_regulatory()
      cfg80211: fix bug while trying to process beacon hints on init
      cfg80211: fix comment on regulatory hint processing

Ma Ling (3):
      drm/i915: Use the GM45 VGA hotplug workaround on G45 as well.
      drm/i915: Include 965GME pci ID in IS_I965GM(dev) to match UMS.
      drm/i915: Set HDMI hot plug interrupt enable for only the output in=
 question.

Maciej Sosnowski (1):
      ioatdma: fix "ioatdma frees DMA memory with wrong function"

Manish Katiyar (1):
      Make checkpatch.pl shut up on fs/inode.c

Manuel Lauss (4):
      MIPS: Alchemy: Fix AU1100 interrupt numbers off-by-one
      MIPS: Alchemy: Add missing Au1200 GPIO203 interrupt
      MIPS: au1xxx-ide: Fix build with CONFIG_PM
      MIPS: Alchemy: Timer build fix

Marcel Holtmann (4):
      Bluetooth: Move dev_set_name() to a context that can sleep
      Bluetooth: Fix wrong module refcount when connection setup fails
      Bluetooth: Don't use hci_acl_connect_cancel() for incoming connecti=
ons
      Bluetooth: Don't trigger disconnect timeout for security mode 3 pai=
ring

Mark Brown (1):
      i2c: Enable i2c-s3c2410 for S3C64XX too

Mark Ware (1):
      i2c-cpm: Pass dev ptr to dma_*_coherent rather than NULL

Martin K. Petersen (2):
      libata: Report disk alignment and physical block size
      libata: Media rotation rate and form factor heuristics

Martin Michlmayr (1):
      sata_mv: use new sata phy register settings for new devices

Matthew Wilcox (1):
      PCI MSI: Fix MSI-X with NIU cards

Mauro Carvalho Chehab (1):
      V4L/DVB (11680): cafe_ccic: use =3D instead of =3D=3D for setting a=
 value at a var

Maynard Johnson (1):
      powerpc: Fix oprofile sampling of marked events on POWER7

Mel Gorman (1):
      Remove implementation of readpage from the hugetlbfs_aops

Michael Chan (1):
      bnx2: Fix panic in bnx2_poll_work().

Mike Rapoport (2):
      ASoC: soc-core: fix crash when removing not instantiated card
      pxa2xx-ac97: fix reset gpio mode setting

Miklos Szeredi (1):
      fuse: destroy bdi on error

Ming Lei (2):
      Revert driver core: fix passing platform_data
      V4L/DVB (11575): uvcvideo: fix uvc resume failed

Nicolas Pitre (1):
      USB: ftdi_sio: add vendor/product id for the Marvell SheevaPlug

Oskar Schirmer (3):
      xtensa: fix wrong extern declaration renamed in code using it
      xtensa: implement ccount calibration for s6000
      xtensa: update s6105_defconfig for ccount calibration

Pablo Neira Ayuso (2):
      netfilter: xt_cluster: fix use of cluster match with 32 nodes
      netfilter: ctnetlink: fix wrong message type in user updates

Patrick McHardy (2):
      netfilter: add missing linux/types.h include to xt_LED.h
      net-sched: fix bfifo default limit

Pekka Enberg (1):
      Staging: w35und: unregister device from the ieee80211 stack upon ->=
disconnect()

Phil Dibowitz (1):
      USB: unusual_devs: extend nokia 6288 bcd range

Phillip Lougher (2):
      Squashfs: check page size is not larger than the filesystem block s=
ize
      Squashfs: cody tidying, remove commented out line in Makefile

Ralf Baechle (14):
      MIPS: Print the actual detected I-cache associativity on bootup.
      MIPS: Fix build error if CONFIG_CEVT_R4K is undefined.
      MIPS: Enable CLO / CLZ instructions via separate CPU property
      MIPS: Cavium: Add support for 8k and 32k page sizes.
      MIPS: Kconfig: Delete duplicate definition of RWSEM_GENERIC_SPINLOC=
K.
      MIPS: Make access_ok() sideeffect proof.
      MIPS: Make uaccess.h slightly more sparse friendly.
      MIPS: uaccess: Switch lock annotations to might_fault().
      MIPS: IP27: Get rid of #ident.  Gcc 4.4.0 doesn't like it.
      MIPS: Set compiler options only after the compiler prefix has ben s=
et.
      MIPS: Use -mno-check-zero-division
      MIPS: Fix sign-extension bug in 32-bit kernel on 32-bit hardware.
      MIPS: Fix highmem.
      MIPS: Rewrite <asm/div64.h> to work with gcc 4.4.0.

Randy Dunlap (2):
      Driver core: platform: fix kernel-doc warnings
      ALSA: pcsp: fix printk format warning

Reinette Chatre (1):
      iwlwifi: update key flags at time key is set

Roel Kluin (3):
      i2c-pxa.c: timeouts off by 1
      ROMFS: romfs_dev_read() error ignored
      ALSA: riptide: postfix increment and off by one

Roland Dreier (1):
      Merge branches 'cxgb3' and 'mlx4' into for-linus

Ryusuke Konishi (6):
      nilfs2: fix possible recovery failure due to block creation without=
 writer
      nilfs2: fix circular locking dependency of writer mutex
      nilfs2: ensure to clear dirty state when deleting metadata file blo=
ck
      nilfs2: fix possible circular locking for get information ioctls
      nilfs2: fix lock order reversal in nilfs_clean_segments ioctl
      nilfs2: check size of array structured data exchanged via ioctls

Sage Weil (1):
      Btrfs: make show_options result match actual option names

Sankar P (1):
      Btrfs: Spelling fix in btrfs_lookup_first_block_group comments

Shane McDonald (3):
      MIPS: MSP71xx: Resolve multiple definition of plat_timer_setup
      MIPS: MSP71xx: Resolve use of non-existent GPIO routines in msp71xx=
 reset
      MIPS: MSP71xx: Remove the RAMROOT functions

Shaohua Li (1):
      drm/i915: workaround IGD i2c bus issue in kernel side (v2)

Simon Arlott (1):
      USB: cxacru: Fix negative dB output

Simon Horman (1):
      ipvs: Fix IPv4 FWMARK virtual services

Stephen Rothwell  x (1):
      powerpc/iseries: Fix pci breakage due to bad dma_data initializatio=
n

Steve Wise (3):
      svcrdma: Fix dma map direction for rdma read targets
      RDMA/cxgb3: Don't complete flushed send work requests twice
      svcrdma: clean up error paths.

Steven Toth (1):
      V4L/DVB (11664): cx23885: Frontend wasn't locking on HVR-1500

Steven Whitehouse (1):
      GFS2: Fix glock ref counting bug

Sukadev Bhattiprolu (1):
      devpts: correctly set default options

Takashi Iwai (7):
      ALSA: hda - Fix line-in on Mac Mini Core2 Duo
      Merge branch 'fix/misc' into for-linus
      Merge branch 'topic/misc' into for-linus
      Merge branch 'fix/hda' into for-linus
      Merge branch 'fix/asoc' into for-linus
      Merge branch 'fix/misc' into for-linus
      Merge branch 'fix/asoc' into for-linus

Tejun Heo (3):
      libata: fix attach error handling
      libata: clear ering on resume
      alpha: unbreak percpu again

Theodore Ts'o (1):
      ext4: Fix race in ext4_inode_info.i_cached_extent

Thierry Reding (1):
      Input: tsc2007 - fix locking in hrtimer handler

Thomas Bogendoerfer (2):
      MIPS: IP27: Fix clash with NMI_OFFSET from hardirq.h
      MIPS: Sibyte: Fix locking in set_irq_affinity

Tim Cole (1):
      Input: joydev - blacklist digitizers

Timur Tabi (1):
      powerpc: Fix mktree build error on Mac OS X host

Trent Piepho (3):
      V4L/DVB (11660): zoran: fix bug when enumerating format -1
      V4L/DVB (11661): v4l2-ioctl: Check buffer types using g_fmt instead=
 of try_fmt
      V4L/DVB (11662): v4l2-ioctl: Clear buffer type specific trailing fi=
elds/padding

Vitaly Mayatskikh (1):
      Avoid world-writable sysfs files in libata driver.

Wolfgang Grandegger (1):
      i2c-mpc: bug fix for MPC52xx clock setting and printout

Zhang Le (2):
      MIPS: Add Loongson cpu-feature-overrides.h
      MIPS: Loongson 2 needs no hazard barriers.

Zhang, Yanmin (1):
      PCI: Fix pci-e port driver slot_reset bad default return value

Zoltan Karcagi (1):
      HID: fix dropped device-specific quirks

npiggin-l3A5Bk7waGM@public.gmane.org (1):
      fs: dcache fix LRU ordering

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr

--===============6812421356684794723==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============6812421356684794723==--
