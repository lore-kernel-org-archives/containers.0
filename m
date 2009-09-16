From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr annotated tag, v2.6.30-rc3, created. v2.6.30-rc3
Date: Wed, 16 Sep 2009 14:36:49 -0400
Message-ID: <200909161836.n8GIanMr001421@gorgona.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============9091839667122234308=="
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

--===============9091839667122234308==
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by smtp1.linux-foundation.org id n8GJIFSB008029

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The annotated tag, v2.6.30-rc3 has been created
        at  b2fdb301af8f488952aaab7de3ff8d3294c3274f (tag)
   tagging  091069740304c979f957ceacec39c461d0192158 (commit)
  replaces  v2.6.30-rc2
 tagged by  Linus Torvalds
        on  Tue Apr 21 20:07:15 2009 -0700

- Log -----------------------------------------------------------------
Linux 2.6.30-rc3
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAknuiekACgkQF3YsRnbiHLsmGgCdHtIQKhBM9qBPw/ma0vTXZDOU
kesAoKqbiIeaVVPcoJpBkbonwQv4hQ19
=3DXgA3
-----END PGP SIGNATURE-----

Aaro Koskinen (1):
      [ARM] 5450/1: Flush only the needed range when unmapping a VMA

Adrian McMenamin (1):
      Documentation/filesystems: remove out of date reference to BKL bein=
g held

Ajit Khaparde (1):
      be2net: fix for default setting of pause auto-negotiation

Akinobu Mita (1):
      hugetlbfs: return negative error code for bad mount option

Al Viro (7):
      Fix AUTOFS_DEV_IOCTL_REQUESTER_CMD
      Touch all affected namespaces on propagation of mount
      Safer nfsd_cross_mnt()
      No need for crossing to mountpoint in audit_tag_tree()
      Fix autofs_expire()
      autofs4: use memchr() in invalid_string()
      reiserfs: fix j_last_flush_trans_id type

Alan Cox (4):
      ata: Report 16/32bit PIO as best we can
      vfat: Note the NLS requirement
      Staging: aten2011: Clean up some tty bits
      pata_via: Cache and rewrite the device bit

Alan Stern (2):
      USB: usb-storage: augment unusual_devs entry for Simple Tech/Datafa=
b
      usb-storage: fix mistake in Makefile

Alex Chiang (1):
      sysfs: don't use global workqueue in sysfs_schedule_callback()

Alexander Beregalov (38):
      fs_enet: convert to netdev_ops
      ibm_newemac: convert to netdev_ops
      ariadne: convert to net_device_ops
      am79c961a: convert to net_device_ops
      at91_ether: convert to net_device_ops
      ep93xx_eth: convert to net_device_ops
      ether1: convert to net_device_ops
      ether3: convert to net_device_ops
      xtsonic: convert to net_device_ops
      tsi108_eth: convert to net_device_ops
      tc35815: convert to net_device_ops
      sun3_82586: convert to net_device_ops
      sh_eth: convert to net_device_ops
      macsonic: convert to net_device_ops
      macb: convert to net_device_ops
      mac89x0: convert to net_device_ops
      isa-skeleton: convert to net_device_ops
      ioc3-eth: convert to net_device_ops
      eth_v10: convert to net_device_ops
      ehea: Fix incomplete conversion to net_device_ops
      a2065: convert to net_device_ops
      atarilance: convert to net_device_ops
      au1000: convert to net_device_ops
      bfin_mac: convert to net_device_ops
      declance: convert to net_device_ops
      Input: hp_sdc_rtc should depend on serio
      Staging: at76: convert to netdev_ops
      Staging: epl: convert to netdev_ops
      Staging: et131x: convert to netdev_ops
      Staging: otus: convert to netdev_ops
      Staging: rt2860: convert to netdev_ops
      Staging: rt2870: convert to netdev_ops
      Staging: rt3070: convert to netdev_ops
      Staging: slicoss: convert to netdev_ops
      Staging: sxg: convert to netdev_ops
      Staging: wlan-ng: convert to netdev_ops
      Staging: line6: convert to snd_card_create()
      fs/compat_ioctl: fix build when !BLOCK

Alexander Duyck (5):
      net: netif_device_attach/detach should start/stop all queues
      ixgbe: only allow WOL for 82599 KX4 NIC
      igb: fix unused external references introduced with sr-iov changes
      igbvf: fix unused external references
      igb: do not check for vf_data if we didn't enable vfs

Anatolij Gustschin (2):
      phylib: Allow early-out in phy_change
      phylib: Add interrupt source check function to M88E1121R driver

Andi Kleen (1):
      Don't set relatime when noatime is specified

Arjan van de Ven (4):
      Input: i8042 - introduce a tougher reset
      Input: i8042 - add a DMI table for the i8042.reset option
      Input: remove unnecessary synchronize_rcu() call
      driver synchronization: make scsi_wait_scan more advanced

Arve Hj=C3=B8nnev=C3=A5g (8):
      Staging: binder: Remove VM_EXEC check.
      Staging: binder: Don't create two proc entries with the same name i=
f the driver is opened twice in one process.
      Staging: binder: mmap fixes.
      Staging: binder: Add more offset validation.
      Staging: binder: Keep a reference to the files_struct while the dri=
ver is mmapped
      Staging: binder: Cast to uintptr_t instead of size_t when aligning =
pointers
      Staging: binder: Prevent the wrong thread from adding a transaction=
 to the stack.
      Staging: binder: Defer flush and release operations to avoid deadlo=
cks.

Atsushi Nemoto (1):
      phylib: Fix delay argument of schedule_delayed_work

Barry Carroll (1):
      Input: atkbd - add forced release keys quirk for Samsung NC20

Bartlomiej Zolnierkiewicz (1):
      ide: fix barriers support

Ben Dooks (20):
      [ARM] s3c2410_defconfig: update to 2.6.30-rc2
      [ARM] s3c2410_defconfig: Update network options
      [ARM] s3c2410_defconfig: Update machine configuration
      [ARM] s3c2410_defconfig: Add MMC/SD core and drivers
      [ARM] s3c2410_defconfig: Add sound drivers
      [ARM] s3c2410_defconfig: Add video/radio drivers
      [ARM] s3c2410_defconfig: Update filesystem options
      [ARM] s3c2410_defconfig: Update USB device drivers
      [ARM] s3c2410_defconfig: Update miscellaneous drivers
      [ARM] S3C: Export s3c_gpio_cfgpin and s3c_gpio_setpull for modules
      ASoC: Fix jive_wm8750.c build problems
      ASoC: s3c-i2s-v2.c fix for s3c_i2sv2_iis_calc_rate
      ASoC: Fix s3c-i2s-v2.c snd_soc_dai changes
      ASoC: Fix include build error in s3c2412-i2s.c
      [ARM] S3C24XX: Fix sparse error in gpiolib.c
      [ARM] S3C: Fix sparse warning from missing 's3c_device_hwmon'
      [ARM] JIVE: Fix sparse warnings about items which should be static
      [ARM] Anubis: Fix sparse warnings for items that should be static
      [ARM] Osiris: Fix double initialisation in machine block
      [ARM] S3C: Fix ADC driver sparse warning

Ben Hutchings (3):
      net: Update maintainers
      sfc: Match calls to netif_napi_add() and netif_napi_del()
      sfc: Use correct macro to set event bitfield

Ben Nizette (1):
      Input: ads7846 - fix unsafe disable_irq

Brian Haley (1):
      Bonding: fix zero address hole bug in arp_ip_target list

Chris Mason (7):
      Export filemap_write_and_wait_range
      Add block_write_full_page_endio for passing endio handler
      Btrfs: use WRITE_SYNC for synchronous writes
      Btrfs: add a priority queue to the async thread helpers
      Btrfs: fix oops on page->mapping->host during writepage
      Btrfs: use the right node in reada_for_balance
      Btrfs: fix btrfs fallocate oops and deadlock

Christian Ehrhardt (1):
      [S390] s390: move machine flags to lowcore

Christoph Hellwig (4):
      md: tiny md.h cleanups
      block: move bio list helpers into bio.h
      GFS2: cleanup file_operations mess
      kill vfs_stat_fd / vfs_lstat_fd

Cliff Wickman (4):
      x86: UV BAU and nodes with no memory
      x86: UV BAU messaging timeouts
      x86: UV: BAU partition-relative distribution map
      x86: UV BAU distribution and payload MMRs

Corey Minyard (3):
      ipmi: fix platform return check
      ipmi: test for event buffer before using
      ipmi: fix statistics counting issues

Cornelia Huck (1):
      [S390] dasd: Use the new async framework for autoonlining.

Dan Carpenter (1):
      phy: error handling for platform_device_register_simple()

Daniel Mack (3):
      ALSA: snd-usb-caiaq: clean up header includes
      ALSA: snd-usb-caiaq: rename files to remove redundant information i=
n file pathes
      ASoC: pxa-ssp: allow setting of dai format 0

Daniel Ribeiro (2):
      [ARM] pxa: fix typo of cs_deassert() in pxa2xx-spi.c
      pxa2xx_spi: restore DRCMR on resume

Daniel T Chen (2):
      ALSA: Intel8x0: Remove conflicting quirk for SSID 0x103c0934
      ALSA: Intel8x0: Add hp_only quirk for SSID 0x1028016a (Dell Inspiro=
n 8600)

Daniele Napolitano (2):
      Staging: rt2870: add ID for Sitecom WL-315
      otus/zdusb.c: additional USB idnetifier

Darius Augulis (2):
      MX1ADS: remove I2C ifdefs
      Fix ifdef in plat-mxc/irc.c

Dave Airlie (1):
      drm: check for minor master before allowing drop master.

Dave Jiang (1):
      edac: ppc mpc85xx fix mc err detect

David Brownell (3):
      USB: musb_host, minor enqueue locking fix (v2)
      USB: musb_host, fix ep0 fifo flushing
      spi: documentation: emphasise spi_master.setup() semantics

David Howells (10):
      MN10300: Discard duplicate PFN_xxx() macros
      MN10300: Wire up missing system calls
      MN10300: Stop gcc from generating uninitialised variable warnings a=
fter BUG()
      The default CONFIG_BUG=3Dn version of BUG() should have an empty do=
...while
      RCU: Don't try and predeclare inline funcs as it upsets some versio=
ns of gcc
      FRV: Don't attempt to #include <linux/blk.h> as it doesn't exist
      FS-Cache: Add MAINTAINERS record for FS-Cache and CacheFiles
      frv: insert PCI root bus resources for the MB93090 devel motherboar=
d
      FRV: Fix the section attribute on UP DECLARE_PER_CPU()
      PERCPU: Collect the DECLARE/DEFINE declarations together

David S. Miller (4):
      forcedeth: Use napi_complete() not __napi_complete().
      Merge branch 'master' of /home/davem/src/GIT/linux-2.6/
      sparc64: Fix smp_callin() locking.
      Revert "rose: zero length frame filtering in af_rose.c"

David Vrabel (6):
      USB: add reset endpoint operations
      USB: whci-hcd: provide a endpoint_reset method
      USB: whci-hcd: check return value of usb_hcd_link_urb_to_ep()
      WUSB: disconnect all devices when stopping a WUSB HCD
      WUSB: fix oops when completing URBs for disconnected devices
      WUSB: correct format of wusb_chid sysfs file

David Woodhouse (1):
      Fix i_mutex vs. readdir handling in nfsd

Denis V. Lunev (1):
      pxafb: lcsr1 is unused without CONFIG_FB_PXA_OVERLAY

Dimitri Sivanich (1):
      [IA64] smp_flush_tlb_mm() should only send IPI's to cpus in cpu_vm_=
mask

Dmitry Adamushko (1):
      x86: fix microcode driver newly spewing warnings

Dmitry Torokhov (3):
      Input: gameport - fix attach driver code
      Input: atkbd - add forced release keys quirk for Samsung Q45
      Merge branch 'next' into for-linus

Dr. Greg Wettstein (1):
      USB device codes for Motorola phone.

Eric Dumazet (1):
      packet: avoid warnings when high-order page allocation fails

Eric Miao (5):
      [ARM] pxa/colibri: fix missing variable name in inline functions
      ASoC: magician: remove un-necessary #include of pxa-regs.h and hard=
ware.h
      Input: ads7846 - introduce platform specific way to synchronize sam=
pling
      Input: da9034-ts - add Bin Yang as co-author of the driver
      Input: da9034-ts - make pen {down,up} events more reliable

Eric Paris (1):
      scsi: mpt: suppress debugobjects warning

Etienne Basset (1):
      Smack: check for SMACK xattr validity in smack_inode_setxattr

Evgeniy Polyakov (13):
      Staging: pohmelfs: Populate dentry cache when receiving the new rea=
ddir entry.
      Staging: Pohmelfs: Move parent lock to the place where we really ha=
ve to send a lookup request to the server.
      Staging: Pohmelfs: Disable read lock in pohmelfs_getattr().
      Staging: Pohmelfs: Added 'need_lock' variable into debug print.
      Staging: Pohmelfs: Set NETFS_INODE_REMOTE_SYNCED and clear NETFS_IN=
ODE_OWNED bits in the root inode.
      Staging: Pohmelfs: Extend remount option.
      Staging: Pohmelfs: Sync fs before killing it, since dentry cache is=
 shrunk before writeback is invoked via generic_shutdown_super()
      Staging: Pohmelfs: Reduce debugging noise about non-existing object=
s.
      Staging: Pohmelfs: Use wait_on_page_timeout when waiting for remote=
 directory sync instead of hardcoded 25 seconds.
      Staging: Pohmelfs: Drop ftrans debugging code.
      Staging: Pohmelfs: Added ->show_stats() callback.
      Staging: Pohmelfs: Added IO permissions and priorities.
      Staging: Pohmelfs: Add load balancing between network states with t=
he same priority.

FUJITA Tomonori (1):
      block: fix SG_IO to return a proper error value

Gautham R Shenoy (1):
      sched: Avoid printing sched_group::__cpu_power for default case

Geert Uytterhoeven (1):
      Staging: STLC45XX should depend on GENERIC_HARDIRQS

Gerald Schaefer (1):
      [S390] appldata: Use new mod_virt_timer_periodic() function.

Greg Kroah-Hartman (3):
      driver core: prevent device_for_each_child from oopsing
      Revert USB: usb-serial ch341: support for DTR/RTS/CTS
      Staging: go7007: fix build issues

H Hartley Sweeten (1):
      kernel/softirq.c: fix sparse warning

Hans J. Koch (1):
      UIO: fix specific device driver missing statement for depmod

Hartley Sweeten (2):
      [ARM] 5451/1: ep93xx:core.c: build warning fix
      [ARM] 5454/1: ep93xx_eth: fix sparse warnings

Heiko Carstens (3):
      [S390] wire up preadv/pwritev system calls
      [S390] call nmi_enter/nmi_exit on machine checks
      [S390] smp: fix cpu_possible_map initialization

Helge Deller (1):
      drivers/input/serio/hp_sdc.c: fix crash when removing hp_sdc module

Herbert Xu (3):
      gro: Normalise skb before bypassing GRO on netpoll VLAN path
      tun: Fix crash with non-GSO users
      gro: Restore correct value to gso_size

Hirokazu Takata (2):
      m32r: move include/asm-m32r headers to arch/m32r/include/asm
      m32r: move include/asm-m32r/* to arch/m32r/include/asm/

Holger Schurig (2):
      imx21: fixes some clocknames
      imx21: activate i2c

Huang Weiyi (2):
      [ARM] pxa/em-x270: remove duplicated #include
      [ARM] S3C: remove duplicated #include

Hugh Dickins (3):
      powerpc: Allow 256kB pages with SHMEM
      Revert "kobject: don't block for each kobject_uevent".
      mm: pass correct mm when growing stack

Igor Mammedov (1):
      Remote DFS root support.

Ilpo J=C3=A4rvinen (2):
      tcp: fix >2 iw selection
      Input: pc110pad - remove unused variable dev

Ilya Yanok (1):
      qong: remove AIPS[12] mappings from machine-specific iotable

Ingo Molnar (1):
      x86: disable X86_PTRACE_BTS for now

Isaku Yamahata (1):
      [IA64] fix allmodconfig compilation breakage.

Jack Steiner (2):
      x86, UV: Fix for nodes with memory and no cpus
      x86, uv: add Kconfig dependency on NUMA for UV systems

Jack Stone (1):
      ide: Remove void casts

James Bottomley (1):
      tg3: fix big endian MAC address collection failure

Jan Glauber (2):
      [S390] extend virtual timer interface by mod_virt_timer_periodic
      [S390] qdio: remove dead timeout handler

Jarkko Nikula (2):
      ASoC: OMAP: Fix DSP_B format in OMAP McBSP DAI driver
      ASoC: OMAP: Fix FS polarity in OSK5912 machine driver

Jaroslav Kysela (6):
      [ALSA] hda_intel: fix unexpected ring buffer positions
      [ALSA] pcm-midlevel: Add more strict buffer position checks based o=
n jiffies
      [ALSA] intel8x0: an attempt to make ac97_clock measurement more rel=
iable
      [ALSA] intel8x0: do not use zero value from PICB register
      [ALSA] intel8x0: fix wrong conditions in ac97_clock measure routine
      [ALSA] intel8x0: add one retry to the ac97_clock measurement routin=
e

Jason Baron (1):
      Driver core: remove pr_fmt() from dynamic_dev_dbg() printk

Jaswinder Singh Rajput (2):
      x86: pci-swiotlb.c swiotlb_dma_ops should be static
      x86, documentation: kernel-parameters replace X86-32,X86-64 with X8=
6

Jay Vosburgh (1):
      bonding: Remove debug printk

Jean Delvare (1):
      go7007: Convert to the new i2c device binding model

Jeff Layton (9):
      cifs: flush data on any setattr
      cifs: vary timeout on writes past EOF based on offset (try #5)
      cifs: remove dnotify thread code
      cifs: no need to use rcu_assign_pointer on immutable keys
      cifs: fix unicode string area word alignment in session setup
      cifs: fix buffer size for tcon->nativeFileSystem field
      cifs: add cFYI messages with some of the saved strings from ssetup/=
tcon
      cifs: remove unneeded bcc_ptr update in CIFSTCon
      cifs: when renaming don't try to unlink negative dentry

Jens Axboe (13):
      block: fix bad spelling of quiesce
      Document and move the various READ/WRITE types
      cfq-iosched: use rw_is_sync() to see if rw flags are sync or not
      cfq-iosched: get rid of private SYNC/ASYNC defines
      as-iosched: get rid of private REQ_SYNC/REQ_ASYNC defines
      block: update biodoc.txt on plugging
      buffer: switch do_emergency_thaw() away from pdflush_operation()
      cfq-iosched: don't delay queue kick for a merged request
      bio: add documentation to bio_alloc()
      cfq-iosched: no need to save interrupts in cfq_kick_queue()
      cfq-iosched: tweak kick logic a bit more
      cfq-iosched: log responsible 'cfqq' in idle timer arm
      cfq-iosched: add close cooperator code

Jesse Brandeburg (1):
      e1000/e1000: fix compile warning

Jiri Slaby (1):
      Input: mainstone-wm97xx - fix condition in pen_up

Joe Perches (4):
      ALSA: hda_intel.c - Consolidate bitfields
      ALSA: MAINTAINERS - Update SOUND
      MAINTAINERS: remove include/asm-*/suspend* file patterns
      MAINTAINERS: update KMEMTRACE pattern after file rename

Jonas Bonn (1):
      drm: set/clear is_master when master changed

Jonathan Corbet (1):
      Trivial: fix a typo in slow-work.h

Jonathan McDowell (1):
      usb gadget: fix ethernet link reports to ethtool

Justin Mattock (1):
      ALSA: add missing definitions(letters) to HD-Audio.txt

KAMEZAWA Hiroyuki (1):
      memcg: use rcu_dereference to access mm->owner

KOSAKI Motohiro (3):
      sysfs: sysfs poll keep the poll rule of regular file.
      proc: mounts_poll() make consistent to mdstat_poll
      vmscan,memcg: reintroduce sc->may_swap

Kay Sievers (2):
      driver core: allow non-root users to listen to uevents
      driver: dont update dev_name via device_add path

Kim Kyuwon (1):
      USB: musb: fix possible panic while resuming

Krzysztof Halasa (1):
      rtc-cmos: fix printk output

Kumar Gala (3):
      powerpc: Fix tlbilx opcode
      powerpc: Add support for early tlbilx opcode
      powerpc/mm: Fix compile warning

Lai Jiangshan (1):
      tracing, sched: mark get_parent_ip() notrace

Li Zefan (10):
      ALSA: sound/core: use memdup_user()
      ALSA: sound/isa: use memdup_user()
      ALSA: sound/usb: use memdup_user()
      ALSA: sound/pci: use memdup_user()
      xattr: use memdup_user()
      btrfs: use memdup_user()
      sysfs: use memdup_user()
      xfs: use memdup_user()
      ncpfs: use memdup_user()
      ecryptfs: use memdup_user()

Linus Torvalds (39):
      acpi-cpufreq: fix 'smp_call_function_many()' confusion
      Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/paulus/powerpc
      Merge branch 'for-linus' of git://git.kernel.dk/linux-2.6-block
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/steve/gfs2-2.6-=
fixes
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge branch 'for-linus' of git://git390.marist.edu/pub/scm/linux-2=
.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/jgarzik/libata-dev
      Merge branch 'x86/uv' of git://git.kernel.org/pub/scm/linux/kernel/=
git/tip/linux-2.6-tip
      Merge branch 'core-fixes-for-linus' of git://git.kernel.org/pub/scm=
/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'sched-fixes-for-linus' of git://git.kernel.org/pub/sc=
m/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'tracing-fixes-for-linus' of git://git.kernel.org/pub/=
scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for-linus' of git://www.linux-m32r.org/git/takata/lin=
ux-2.6_dev
      Get rid of final remnants of include/asm-$(ARCH)
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/dtor/input
      Merge master.kernel.org:/home/rmk/linux-2.6-arm
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/usb-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-c=
ore-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging-=
2.6
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/jgarzik/libata-dev
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jmorris/security-testing-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/bart/ide-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/sfrench/cifs-2.=
6
      Remove 'recurse into child resources' logic from 'reserve_region_wi=
th_split()'
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/sam/kbuild-fixe=
s
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/rusty/linux-2.6=
-lguest-and-virtio
      Merge branch 'for-linus' of git://neil.brown.name/md
      Merge branch 'drm-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/airlied/drm-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/rafael/suspend-2.6
      Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel=
/git/aegl/linux-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/viro/vfs-2.6
      Merge branch 'sh/for-2.6.30' of git://git.kernel.org/pub/scm/linux/=
kernel/git/lethal/sh-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/steve/gfs2-2.6-=
fixes
      Merge branch 'i2c-for-linus' of git://jdelvare.pck.nerim.net/jdelva=
re-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/mason/btrfs-uns=
table
      Linux 2.6.30-rc3

Linus Walleij (1):
      [ARM] 5455/1: Fix IRQ noise from VIC code

Lior Dotan (1):
      Revert Staging: SLICOSS: use gfp_kernel where possible

Ma Ling (1):
      drm: clean dirty memory after device release

Magnus Damm (3):
      Driver Core: early platform driver
      clocksource: pass clocksource to read() callback
      clocksource: add enable() and disable() callbacks

Marcelo Tosatti (2):
      [IA64] export smp_send_reschedule
      virtio: fix suspend when using virtio_balloon

Marek Vasut (2):
      [ARM] pxa: add missing declaration of pxa26x_init_irq()
      [ARM] pxa: PalmTX and PalmT5 USB fixes

Mark Brown (7):
      ASoC: Disable S3C64xx support in Kconfig
      Input: wm97xx - don't specify IRQF_SAMPLE_RANDOM
      [ARM] 5449/1: S3C: Use disable_irq_nosync() to fix boot lockups
      [ARM] SMDK6410: Request GPIOs for LCD power control
      mx31ads: imoux pins should be passed in as unsigned int
      mx31ads: Depend on all the WM8350 core dependencies for WM1133-EV1 =
board
      mx31ads: Mark as having full regulatoion constraints with 1133-EV1 =
board

Mark Lord (2):
      sata_mv: tidy up qc->tf usage in qc_prep() functions
      sata_mv: workaround for multi_count errata sata24

Markus Brunner (1):
      gianfar: stop send queue before resetting gianfar

Martin Schwidefsky (5):
      [S390] stp synchronization retry timer
      [S390] fix idle time accounting
      [S390] cpu hotplug and accounting values
      [S390] add read_persistent_clock
      [S390] boot cputime accounting

Matias Zabaljauregui (1):
      lguest: fix crash on vmlinux images

Matt Kraai (2):
      AFS: Guard afs_file_readpage_read_complete() definition with CONFIG=
_AFS_FSCACHE
      lguest: tell git to ignore Documentation/lguest/lguest

Matt Mackall (1):
      MAINTAINERS: add Matt Mackall to embedded maintainers

Matthew Garrett (1):
      USB: qcserial: Add extra device IDs

Michael Ellerman (1):
      dynamic debug: resurrect old pr_debug() semantics as pr_devel()

Michael Hennerich (2):
      Input: ad7877, ad7879 - remove depreciated IRQF_SAMPLE_RANDOM flag
      Input: bf54x-keys - remove depreciated IRQF_SAMPLE_RANDOM flag

Michal Schmidt (1):
      skge: fix occasional BUG during MTU change

Mike Mason (1):
      powerpc/pseries: Set error_state to pci_channel_io_normal in eeh_re=
port_reset()

Mike Rapoport (1):
      [ARM] pxa/em-x270: explicitly set .gpio_cs in TDO35S SPI chip data

Miklos Szeredi (6):
      splice: split up __splice_from_pipe()
      splice: remove i_mutex locking in splice_from_pipe()
      splice: fix i_mutex locking in generic_splice_write()
      ocfs2: fix i_mutex locking in ocfs2_splice_to_file()
      splice: remove generic_file_splice_write_nolock()
      splice: add helpers for locking pipe inode

Ming Lei (1):
      driver core: fix driver_match_device

Mithlesh Thukral (4):
      Staging: sxg: Fire watchdog timer at end of open routine to change =
the link
      Staging: sxg: Use correct queue_id for transmitting non-TCP packets
      Staging: sxg: Fix sleep in atomic context warning while loading dri=
ver
      Staging: sxg: Fix leaks and checksum errors in transmit code path

NeilBrown (4):
      md: allow setting newly added device to 'in_sync' via sysfs.
      md: improve usefulness and accuracy of sysfs file md/sync_completed.
      md: update sync_completed and reshape_position even more often.
      md: support bitmaps on RAID10 arrays larger then 2 terabytes

Nick Piggin (2):
      brd: support barriers
      brd: fix cacheflushing

Nikanth Karthikesan (5):
      block: Remove code handling bio_alloc failure with __GFP_WAIT
      dio: Remove code handling bio_alloc failure with __GFP_WAIT
      ext4: Remove code handling bio_alloc failure with __GFP_WAIT
      gfs2: Remove code handling bio_alloc failure with __GFP_WAIT
      swap: Remove code handling bio_alloc failure with __GFP_WAIT

Oleg Drokin (1):
      Separate out common fstatat code into vfs_fstatat

Oliver Neukum (1):
      USB: fix oops in cdc-wdm in case of malformed descriptors

PJ Waskiewicz (1):
      ixgbe: Move the LED blink code to common, since 82599 also uses it

Pallipadi, Venkatesh (1):
      x86, PAT: Remove page granularity tracking for vm_insert_pfn maps

Pascal Terjan (1):
      USB: option: Add ids for D-Link DWM-652 3.5G modem

Paul E. McKenney (1):
      rcu: Make hierarchical RCU less IPI-happy

Paul Mackerras (1):
      powerpc: Fix data-corrupting bug in __futex_atomic_op

Paul Mundt (4):
      rtc: rtc-sh: clock framework support.
      sh: sh7722: Don't default enable the RTC clock.
      sh: sh7723: Don't default enable the RTC clock.
      Merge branch 'sh/stable-updates' into sh/for-2.6.30

Paulius Zaleckas (1):
      MXC: remove orphan imx_init_uart() definition

Peter Korsgaard (1):
      USB: ftdi_sio: add vendor/project id for JETI specbos 1201 spectrom=
eter

Rafael J. Wysocki (5):
      NET/e1000: Fix powering off during shutdown
      NET/e1000e: Fix powering off during shutdown
      NET/ixgbe: Fix powering off during shutdown
      PM/Hibernate: Fix memory shrinking
      PM/Suspend: Introduce two new platform callbacks to avoid breakage

Ralf Baechle (1):
      <linux/seccomp.h> needs to include <linux/errno.h>.

Ramax Lo (1):
      [ARM] S3C24XX: ADC: Check pending queue before freeing adc client

Randy Dunlap (2):
      splice: fix new kernel-doc warnings
      doc: fix kernel-parameters.txt mistaken deletions

Robert P. J. Day (1):
      MAINTAINERS: add a more searchable string for the H8300 architectur=
e.

Robin Holt (1):
      sgi-xp/sgi-gru: allow modules to load on non-uv systems

Roel Kluin (4):
      ALSA: emu10k1 - off by 1 in snd_emu10k1_wait()
      drm: count reaches -1
      spi: pxa2xx: limit reaches -1
      bfin_5xx: misplaced parentheses

Russ Anderson (2):
      x86, UV: system table in bios accessed after unmap
      x86: prevent /sys/firmware/sgi_uv from being created on non-uv syst=
ems

Russell King (6):
      Merge branch 'fix' of git://git.kernel.org/pub/scm/linux/kernel/git=
/ycmiao/pxa-linux-2.6
      Update MAINTAINERS
      [ARM] remove .gitignore from include/asm-arm
      Merge branch 'for-rmk' of git://git.pengutronix.de/git/imx/linux-2.=
6
      Merge branch 'v2630-rc2-fixes' of git://aeryn.fluff.org.uk/bjdooks/=
linux
      Merge branch 'defconfig-s3c2410' of git://aeryn.fluff.org.uk/bjdook=
s/linux

Rusty Russell (2):
      lguest: fix guest crash on non-linear addresses in gdt pvops
      lguest: document 32-bit and PAE requirements

Sachin Sant (1):
      powerpc: pseries/dtl.c should include asm/firmware.h

Sam Ravnborg (2):
      kbuild: support include/generated
      kbuild: introduce subdir-ccflags-y

Samuel Thibault (1):
      Revert "console ASCII glyph 1:1 mapping"

Sascha Hauer (3):
      pcm037 board support: Fix eth interrupt gpio setting
      MX31: Add more alternate pin definitions
      mxc defconfig updates

Sergei Poselenov (1):
      phylib: Basic support for the M88E1121R Marvell chip

Sergei Shtylyov (8):
      pata_hpt37x: fix HPT370 DMA timeouts
      libata: use ATA_ID_CFA_*
      USB: musb: bugfixes for multi-packet TXDMA support
      USB: musb: sanitize clearing TXCSR DMA bits (take 2)
      USB: musb: fix isochronous TXDMA (take 2)
      hpt366: fix HPT370 DMA timeouts
      hpt366: use ATA_DMA_* constants
      cs5536: define dma_sff_read_status() method

Shaohua Li (1):
      agp: zero pages before sending to userspace

Stanislaw Gruszka (1):
      myr10ge: again fix lro_gen_skb() alignment

Stefan Weinhuber (1):
      [S390] dasd: fix idaw boundary checking for track based ccw

Stephen Hemminger (2):
      netsched: Allow meta match on vlan tag on receive
      staging: slicoss: update README

Stephen Rothwell (1):
      sparc: asm/atomic.h on 32bit should include asm/system.h for xchg

Steve French (6):
      [CIFS] Endian convert UniqueId when reporting inode numbers from se=
rver files
      [CIFS] Fix build break from recent DFS patch when DFS support not e=
nabled
      [CIFS] remove some build warnings
      [CIFS] Add support for posix open during lookup
      [CIFS] Fix sparse warnings
      [CIFS] Fix build break caused by change to new current_umask helper=
 function

Steven Whitehouse (5):
      GFS2: Make quotad's waiting interruptible
      GFS2: Fix symlink creation race
      GFS2: Move umount flush rwsem
      GFS2: Clear dirty bit at end of inode glock sync
      GFS2: Fix page_mkwrite() return code

Stoyan Gaydarov (1):
      sbus: changed ioctls to unlocked

Suresh Siddha (3):
      x86, CPA: Change idmap attribute before ioremap attribute setup
      x86, PAT: Consolidate code in pat_x_mtrr_type() and reserve_memtype=
()
      x86, PAT: Remove duplicate memtype reserve in devmem mmap

S=C3=A9guier R=C3=A9gis (1):
      via-velocity : fix compilation warning.

Takashi Iwai (19):
      Merge branch 'for-2.6.30' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/broonie/sound-2.6 into topic/asoc
      ALSA: add private_data to struct snd_jack
      ALSA: hda - Avoid call of snd_jack_report at release
      ALSA: hda - Add quirk mask for Fujitsu Amilo laptops with ALC883
      Merge branch 'master' of git://git.alsa-project.org/alsa-kernel int=
o for-linus
      Merge branch 'topic/jack-free-fix' into topic/hda
      Merge branch 'topic/hda' into for-linus
      Merge branch 'topic/asoc' into for-linus
      Merge branch 'topic/usb-caiaq' into for-linus
      Merge branch 'topic/memdup_user' into for-linus
      ALSA: hda - Fix the cmd cache keys for amp verbs
      Merge branch 'topic/hda' into for-linus
      ALSA: hda - Fix headphone-detection on some machines with STAC/IDT =
codecs
      ALSA: hda - Add upper-limit of mixer amp for AD1884A-laptop model, =
too
      ALSA: hda - Set function_id only on FG nodes
      Merge branch 'fix/asoc' into for-linus
      Merge branch 'fix/hda' into for-linus
      Merge branch 'fix/intel8x0' into for-linus
      Merge branch 'fix/misc' into for-linus

Tejun Heo (2):
      libata: handle SEMB signature better
      pata_legacy: fix no device fail path

Tetsuo Handa (1):
      fs: Mark get_filesystem_list() as __init function.

Thomas Bogendoerfer (1):
      Fix SYSCALL_ALIAS for older MIPS assembler

Toshinobu Sugioka (1):
      sh: Fix mmap2 for handling differing PAGE_SIZEs.

Trond Myklebust (1):
      NFS: Fix the XDR iovec calculation in nfs3_xdr_setaclargs

Valentin Longchamp (2):
      MX31: pin definition for sdhc2
      mx31: pin definition for csi

Vlad Yasevich (1):
      ipv6: Fix NULL pointer dereference with time-wait sockets

Vlada Peric (1):
      asiliantfb: add missing return statement

Vladimir Barinov (1):
      MX31: Add I2C pin definitions

WANG Cong (1):
      uml: kill a kconfig warning

Wei Yongjun (3):
      tr: fix leakage of device in net/802/tr.c
      sparc: remove some pointless conditionals before kfree()
      cifs: remove some pointless conditionals before kfree()

Werner Cornelius (1):
      USB: usb-serial ch341: support for DTR/RTS/CTS

Wolfgang Grandegger (4):
      powerpc/85xx: TQM85xx: correct address of LM75 I2C device nodes
      powerpc/85xx: TQM8548: use proper phy-handles for enet2 and enet3
      powerpc/85xx: TQM8548: update defconfig
      powerpc: Document new FSL I2C bindings and cleanup

Wu Fengguang (2):
      ixgbe: fix tx queue index
      ixgbe: update real_num_tx_queues on changing num_rx_queues

Xu Gang (1):
      GFS2: Use DEFINE_SPINLOCK

Yang Hongyang (1):
      ipv6:remove useless check

Zhaolei (2):
      tracing: Fix power tracer header
      tracing: Fix branch tracer header

Zhenwen Xu (1):
      [libata] fix build error on drivers/ata/pata_legacy.c

dann frazier (1):
      ipmi: add oem message handling

eric miao (1):
      [ARM] 5453/1: fix building breakage of sys_oabi-compat.c due to mis=
sing kmalloc/kfree

venkatesh.pallipadi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org (3):
      x86, PAT: Change order of cpa and free in set_memory_wb
      x86, PAT: Handle faults cleanly in set_memory_ APIs
      x86, PAT: Changing memtype to WC ensuring no WB alias

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr

--===============9091839667122234308==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============9091839667122234308==--
