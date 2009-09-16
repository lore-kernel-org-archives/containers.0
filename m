From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr annotated tag, v2.6.30-rc5, created. v2.6.30-rc5
Date: Wed, 16 Sep 2009 14:36:51 -0400
Message-ID: <200909161836.n8GIapbD001461@gorgona.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============9036249145828696642=="
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

--===============9036249145828696642==
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by smtp1.linux-foundation.org id n8GJ79qu006968

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The annotated tag, v2.6.30-rc5 has been created
        at  4266b00c9dc3e1e071bde0ebfeadc40bbc1e8316 (tag)
   tagging  091bf7624d1c90cec9e578a18529f615213ff847 (commit)
  replaces  v2.6.30-rc4
 tagged by  Linus Torvalds
        on  Fri May 8 17:14:31 2009 -0700

- Log -----------------------------------------------------------------
Linux 2.6.30-rc5
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkoEyusACgkQF3YsRnbiHLu3aQCeNJiumKBbB+tGyvr7p0kiW2Zx
liIAn0JZJIZURk81PX4Y7gQc35zOUPWg
=3Dwkdx
-----END PGP SIGNATURE-----

Abhijeet Joglekar (6):
      [SCSI] libfc: Hold disc mutex while processing gpn ft resp
      [SCSI] libfc: Do not retry if the new state is not the same as old =
state
      [SCSI] libfc: Track rogue remote ports
      [SCSI] libfc: During fabric logoff, flush the rport Q after logging=
 off dns port
      [SCSI] libfc: Change state to NONE in fc_lport_destroy
      [SCSI] libfc: whenever queueing delete ev for rport, set state to N=
ONE

Alan Cox (1):
      vt: Add a note on the historical abuse of CLOCK_TICK_RATE

Alan Jenkins (1):
      mac80211: fix modprobe deadlock by not calling wep_init under rtnl_=
lock

Alex Williamson (2):
      virtio_net: Cleanup command queue scatterlist usage
      virtio_net: Fix function name typo

Anders Kaseorg (2):
      kbuild, modpost: Check the section flags, to catch missing "ax"/"aw=
"
      kbuild, modpost: fix unexpected non-allocatable section when cross =
compiling

Andi Kleen (3):
      x86, mce: make polling timer interval per CPU
      x86, mce: fix boot logging logic
      Eliminate thousands of warnings with gcc 3.2 build

Andrea Righi (1):
      mm: prevent divide error for small values of vm_dirty_bytes

Andreas Herrmann (1):
      x86: show number of core_siblings instead of thread_siblings in /pr=
oc/cpuinfo

Andrew Morton (2):
      vmscan: avoid multiplication overflow in shrink_zone()
      drivers/base/iommu.c: add missing includes

Arjan Opmeer (2):
      Input: elantech - provide a workaround for jumpy cursor on firmware=
 2.34
      Input: elantech - make sure touchpad is really in absolute mode

Artem Bityutskiy (1):
      mtd: expose subpage size via sysfs

Arun KS (1):
      OMAP1: clock: Typo fix for clock in omap1

Ashutosh Naik (1):
      ibft: fix the display of a few fields in the NIC attribute structur=
e in sysfs

Ben Dooks (3):
      [ARM] S3C64XX: Add S3C64XX_PA_IIS{0,1} to <mach/map.h>
      [ARM] S3C: Add UDIVSLOT support for newer UARTS
      [ARM] S3C2412: Add missing cache flush in suspend code

Ben Nizette (4):
      Input: omap-keypad - use disable_irq_nosync() in irq handler
      Input: sa1111ps2 - use disable_irq_nosync() in irq handlers
      Input: tsc2007 - use disable_irq_nosync() in irq handler
      Input: ucb1400 - use disable_irq_nosync() in irq handler

Ben Skeggs (2):
      drm: clean the map list before destroying the hash table
      drm: cleanup properly in drm_get_dev() failure paths

Benjamin Herrenschmidt (1):
      powerpc: Fix setting of oprofile cpu type

Boaz Harrosh (3):
      [SCSI] libosd: OSD2r05: Prepare for rev5 attribute list changes
      [SCSI] libosd: OSD2r05: OSD_CRYPTO_KEYID_SIZE will grow 20 =3D> 32 =
bytes
      [SCSI] libosd: OSD2r05: on-the-wire changes for latest OSD2 revisio=
n 5.

Bob Copeland (2):
      Input: appletouch - fix DMA to/from stack buffer
      ath5k: fix buffer overrun in rate debug code

Borislav Petkov (1):
      ide-cd: fix REQ_QUIET tests in cdrom_decode_status

Breno Leitao (1):
      jsm: removing unused spinlock

Brian King (1):
      [SCSI] ipr: Fix sleeping function called with interrupts disabled

Bruno Pr=C3=A9mont (1):
      netconsole: take care of NETDEV_UNREGISTER event

Catalin Marinas (4):
      [ARM] 5488/1: ARM errata: Invalidation of the Instruction Cache ope=
ration can fail
      [ARM] 5487/1: ARM errata: Stale prediction on replaced interworking=
 branch
      [ARM] 5490/1: ARM errata: Processor deadlock when a false hazard is=
 created
      [ARM] 5489/1: ARM errata: Data written to the L2 cache can be overw=
ritten with stale data

Cedric Hombourger (1):
      kbuild: fix Module.markers permission error under cygwin

Chris Leech (2):
      [SCSI] fcoe: don't export functions that are internal to fcoe
      [SCSI] fcoe: fix spelling typos and bad comments

Christof Schmitt (5):
      [SCSI] zfcp: Dont call zfcp_fsf_req_free on NULL pointer
      [SCSI] zfcp: Let actcli handle control file errors
      [SCSI] zfcp: Fix abort handler for completions in progress
      [SCSI] zfcp: Reference counting for cfdc requests
      [SCSI] zfcp: Fix oops when port disappears

Christoph Hellwig (3):
      xfs: a couple getbmap cleanups
      xfs: fix getbmap vs mmap deadlock
      MAINTAINERS: add ptrace entry

Christophe Borivant (1):
      HID: Add support for the G25 force feedback wheel in native mode

Daisuke Nishimura (2):
      memcg: fix try_get_mem_cgroup_from_swapcache()
      memcg: fix mem_cgroup_shrink_usage()

Dan Carpenter (4):
      HID: hidraw -- fix missing unlocks in unlocked_ioctl
      [SCSI] fcoe: kfree() -> kfree_skb()
      [SCSI] libosd: fix potential ERR_PTR dereference in osd_initiator.c
      sdhci-pci: bad error handling in probe function

Daniel Mack (1):
      isl29003: fix resume functionality

Dave Airlie (3):
      drm/kms: don't try to shortcut drm mode set function
      i2c-algo-bit: Fix timeout test
      drm/r128: fix r128 ioremaps to use ioremap_wc.

Dave Hansen (1):
      [SCSI] fix sign extension with 1.5TB usb-storage LBD=3Dy

David Brownell (2):
      davinci: gpio bugfixes
      davinci: DM644x: NAND: update partitioning

David Gibson (1):
      Move dtc and libfdt sources from arch/powerpc/boot to scripts/dtc

David Howells (4):
      mm: use roundown_pow_of_two() in zone_batchsize()
      nommu: clamp zone_batchsize() to 0 under NOMMU conditions
      nommu: make the initial mmap allocation excess behaviour Kconfig co=
nfigurable
      NOMMU: Don't check vm_region::vm_start is page aligned in add_nommu=
_region()

David Rientjes (2):
      x86, srat: do not register nodes beyond e820 map
      oom: prevent livelock when oom_kill_allocating_task is set

David S. Miller (2):
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-2.6
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/holtmann/bluetooth-2.6

Denis V. Lunev (1):
      mtd: mtd in mtd_release is unused without CONFIG_MTD_CHAR

Dmitry Torokhov (2):
      Input: ALPS - add signature for Toshiba Satellite Pro M10
      Input: lifebook - add DMI entry for Fujitsu B-2130

Enrik Berkhan (1):
      i2c-algo-pca: Let PCA9564 recover from unacked data byte (state 0x3=
0)

Eric Dumazet (4):
      sched: account system time properly
      net: Fix skb_tx_hash() for forwarding workloads.
      netfilter: use likely() in xt_info_rdlock_bh()
      bonding: bond_slave_info_query() fix

Eric Miao (5):
      [ARM] pxa: fix issue of muxed GPIO irq_chip functions touching non-=
muxed GPIOs
      [ARM] pxa: make ads7846 on corgi and spitz to sync on HSYNC
      [ARM] pxa/zylonite: fix the issue of unused SDATA_IN_1 pin get AC97=
 not working
      [ARM] pxa/zylonite: configure GPIO18/19 correctly, used by 2 GPIO e=
xpanders
      [ARM] pxa/littleton: add missing da9034 touchscreen support

Eric Moore (10):
      [SCSI] mpt2sas : unique ioctl magic number
      [SCSI] mpt2sas : the sanity check in base_interrupt needs to be on =
dword boundary
      [SCSI] mpt2sas : fix oops when firmware sends large sense buffer si=
ze
      [SCSI] mpt2sas : running out of message frames
      [SCSI] mpt2sas : driver name needs to be in the MPT2IOCINFO ioctl
      [SCSI] mpt2sas : Identify Dell series-7 adapters at driver load tim=
e
      [SCSI] mpt2sas : Broadcast Primative AEN bug fix
      [SCSI] mpt2sas : release diagnotic buffers prior host reset
      [SCSI] mpt2sas: fix hotplug event processing
      [SCSI] mpt2sas : bump driver version to 01.100.02.00

Eric Piel (1):
      initramfs: clean up messages related to initramfs unpacking

FUJITA Tomonori (1):
      [SCSI] sg: return EFAULT for an invalid user address

Florian Fainelli (1):
      MAINTAINERS: Florian has moved

Fr=C3=A9d=C3=A9ric Bri=C3=A8re (1):
      kbuild: clean Module.markers and modules.order for out-of-tree modu=
les

Giuliano Pochini (1):
      ALSA: indigo-express: add missing 64KHz flags

Grant Likely (3):
      powerpc: Update MPC5xxx and Xilinx Virtex maintainer entries
      virtio: add missing include to virtio_net.h
      of: make of_(un)register_platform_driver common code

Guennadi Liakhovetski (2):
      [ARM] pxa: remove duplicate select statements from Kconfig
      ARM: ARCH_MXC should select HAVE_CLK

H Hartley Sweeten (1):
      kernel/posix-cpu-timers.c: fix sparse warning

Hannes Hering (1):
      ehea: fix invalid pointer access

Heiko Carstens (1):
      atomic: fix atomic_long_cmpxchg/xchg for 64 bit architectures

Henrik Rydberg (8):
      Input: bcm5974 - prepare for a new trackpad header type
      Input: bcm5974 - add quad-finger tapping
      Input: bcm5974 - Add support for the Macbook 5 (Unibody)
      Input: bcm5974 - augment debug information
      Input: bcm5974 - add documentation for the driver
      Input: allow certain EV_ABS events to bypass all filtering
      Input: add detailed multi-touch finger data report protocol
      Input: document the multi-touch (MT) protocol

Hidetoshi Seto (1):
      x86: MCE: make cmci_discover_lock irq-safe

Hirokazu Takata (2):
      m32r: build fix for __stringify macro
      m32r: use __stringify() macro in assembler.h

Huang Weiyi (1):
      ARM: OMAP3: remove duplicated #include

Huang Ying (1):
      x86, kexec: fix crashdump panic with CONFIG_KEXEC_JUMP

Hugh Dickins (1):
      doc: hashdist defaults on for 64bit

Ian Kent (1):
      autofs4: fix incorrect return in autofs4_mount_busy()

Igor Mammedov (2):
      Enable dfs submounts to handle remote referrals.
      Added loop check when mounting DFS tree.

Ivan Kokshaysky (4):
      alpha: titan and marvel build fixes
      alpha: exception table sorting
      alpha: futex implementation
      alpha: binfmt_aout fix

Jake Edge (1):
      proc: avoid information leaks to non-privileged processes

James Smart (3):
      [SCSI] lpfc 8.3.1 : Fix up kernel-doc function comments
      [SCSI] lpfc 8.3.1: misc fixes/changes
      [SCSI] lpfc 8.3.1 : Update version to 8.3.1

Jan Beulich (3):
      [IA64] xen_domu_defconfig: fix build issues/warnings
      x86: fix boot hang in early_reserve_e820()
      x86-64: finish cleanup_highmaps()'s job wrt. _brk_end

Jan Engelhardt (1):
      md: constify VFTs

Jarek Poplawski (1):
      net: Fix oops when splicing skbs from a frag_list.

Jarkko Nikula (1):
      ARM: OMAP2: Remove defines and resource init for OMAP24XX EAC

Jay Vosburgh (1):
      bonding: fix alb mode locking regression

Jean Delvare (1):
      hwmon: (w83781d) Fix W83782D support (NULL pointer dereference)

Jeff Layton (11):
      nls: add a nls_nullsize inline
      cifs: move #defines for mapchars into cifs_unicode.h
      cifs: add replacement for cifs_strtoUCS_le called cifs_from_ucs2
      cifs: add new function to get unicode string length in bytes
      cifs: rename cifs_strlcpy_to_host and make it use new functions
      cifs: convert CIFSTCon to use new unicode helper functions
      cifs: fix session setup unicode string saving to use new unicode he=
lpers
      cifs: change CIFSSMBUnixQuerySymLink to use new helpers
      cifs: change cifs_get_name_from_search_buf to use new unicode helpe=
r
      cifs: fix length handling in cifs_get_name_from_search_buf
      [CIFS] remove cifs_strfromUCS_le

Jeremy Fitzhardinge (1):
      x86: xen, i386: reserve Xen pagetables

Jesper Nilsson (1):
      CRISv10: fix serial driver proc-usage

Jesse Brandeburg (1):
      e1000: fix virtualization bug

Jiri Kosina (1):
      HID: fix oops in hid_check_keys_pressed()

Jiri Pirko (1):
      bonding: correct the cleanup in bond_create()

Joe Eykholt (1):
      [SCSI] fcoe: fip: add multicast filter to receive FIP advertisement=
s.

Joel Becker (3):
      ocfs2: Fix some printk() warnings.
      ocfs2: Fix a missing credit when deleting from indexed directories.
      ocfs2: Change repository in MAINTAINERS.

Joerg Roedel (2):
      dma-debug: remove broken dma memory leak detection for 2.6.30
      amd-iommu: fix iommu flag masks

Johannes Berg (2):
      iwlwifi: notify on scan completion even when shutting down
      mac80211: default to automatic power control

Johannes Weiner (1):
      mm: fix pageref leak in do_swap_page()

John Wright (1):
      x86: gettimeofday() vDSO: fix segfault when tv =3D=3D NULL

Jon Smirl (1):
      ASoC: Set the MPC5200 i2s driver to BROKEN status.

Jonas Bonn (2):
      drm: add control node checks missing from kms merge
      drm: remove unreachable code in drm_sysfs.c

Joonyoung Shim (1):
      ASoC: TWL4030: Fix gain control for earpiece amplifier

Josef Bacik (1):
      fiemap: fix problem with setting FIEMAP_EXTENT_LAST

Jos=C3=A9 M. Fern=C3=A1ndez (1):
      mmc: increase power up delay

Jussi Kivilinna (1):
      rndis_wlan: fix initialization order for workqueue&workers

KOSAKI Motohiro (1):
      mm: fix Committed_AS underflow on large NR_CPUS environment

Kevin Hilman (13):
      davinci: add default Kconfig, add HAVE_IDE
      davinci: add runtime CPU detection support
      davinci: major rework of clock, PLL, PSC infrastructure
      davinci: add arch_ioremap() which uses existing static mappings
      ARM: OMAP2/3: GPIO: do not attempt to wake-enable
      OMAP: dmtimer: enable all timers to be wakeup events
      davinci: timers: use clk_get_rate()
      davinci: add EDMA driver
      davinci: serial: generalize for more SoCs
      davinci: update pin-multiplexing support
      davinci: DM644x: rename board file
      davinci: update DM644x support in preparation for more SoCs
      [ARM] 5506/1: davinci: DMA_32BIT_MASK --> DMA_BIT_MASK(32)

Krzysztof Helt (1):
      fbdev: remove makefile reference to removed driver

Lachlan McIlroy (1):
      xfs_file_last_byte() needs to acquire ilock

Ladislav Michl (3):
      ARM: OMAP: MMC: Remove unused power_pin
      ARM: OMAP1: Simplify board-h2 MMC setup
      ARM: OMAP1: Fix mmc_set_power GPIO usage

Laszlo Attila Toth (1):
      xt_socket: checks for the state of nf_conntrack

Latchesar Ionkov (3):
      net/9p: set correct stat size when sending Twstat messages
      net/9p: return error when p9_client_stat fails
      net/9p: handle correctly interrupted 9P requests

Lennert Buytenhek (2):
      mv643xx_eth: OOM handling fixes
      mv643xx_eth: 64bit mib counter read fix

Linus Torvalds (36):
      Merge branch 'for-linus' of git://www.linux-m32r.org/git/takata/lin=
ux-2.6_dev
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jikos/hid
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/jlbec/ocfs2
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/sam/kbuild-fixes
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/dtor/input
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/jejb/scsi-rc-fi=
xes-2.6
      Merge branch 'x86-mce-for-linus' of git://git.kernel.org/pub/scm/li=
nux/kernel/git/x86/linux-2.6-tip
      Merge master.kernel.org:/home/rmk/linux-2.6-arm
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/bart/ide-2.6
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/jlbec/configfs
      Merge branch 'for-linus' of git://oss.sgi.com/xfs/xfs
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/drzeus/mmc
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/ericvh/v9fs
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jmorris/security-testing-2.6
      Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/benh/powerpc
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'i2c-for-linus' of git://jdelvare.pck.nerim.net/jdelva=
re-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/sam/kbuild-fixe=
s
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'tracing-fixes-for-linus' of git://git.kernel.org/pub/=
scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'core-fixes-for-linus' of git://git.kernel.org/pub/scm=
/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'sched-fixes-for-linus' of git://git.kernel.org/pub/sc=
m/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'irq/urgent' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/tip/linux-2.6-tip
      Merge branch 'timers/urgent' of git://git.kernel.org/pub/scm/linux/=
kernel/git/tip/linux-2.6-tip
      Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel=
/git/aegl/linux-2.6
      Merge branch 'drm-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/airlied/drm-2.6
      Merge master.kernel.org:/home/rmk/linux-2.6-arm
      random: make get_random_int() more random
      Merge branch 'for-linus' of git://neil.brown.name/md
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/sfrench/cifs-2.=
6
      Merge branch 'fixes-for-linus' of git://git.monstr.eu/linux-2.6-mic=
roblaze
      Merge branch 'hwmon-for-linus' of git://jdelvare.pck.nerim.net/jdel=
vare-2.6
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge git://git.infradead.org/mtd-2.6
      Linux 2.6.30-rc5

Lubomir Rintel (1):
      ne2k-pci: Do not register device until initialized.

Luca Tettamanti (1):
      hwmon: (asus_atk0110) Fix compiler warning

Maciej Cencora (1):
      drm/radeon: bump minor version for occlusion queries support

Magnus Lilja (1):
      i.MX31: Disable CPU_32v6K in mx3_defconfig.

Marcel Holtmann (1):
      Bluetooth: Fix issue with sysfs handling for connections

Mark A. Greer (1):
      davinci: PSC: Clear bits in MDCTL reg before setting new bits

Mark Brown (1):
      ASoC: Fix logic in WM8350 master clocking check

Martin Fuzzey (2):
      mxc : Clean up properly when imx_dma_free() used without imx_dma_di=
sable()
      mxc : BUG in imx_dma_request

Martin Petermann (4):
      [SCSI] zfcp: Avoid referencing freed memory in req send
      [SCSI] zfcp: remove unit will fail if add unit is not finished
      [SCSI] zfcp: revert previous patch for sbal counting
      [SCSI] zfcp: Fix port reference counting

Masami Hiramatsu (1):
      kprobes: fix to use text_mutex around arm/disarm kprobe

Matt Kraai (1):
      kbuild: remove a tag file before it is regenerated

Mel Gorman (1):
      Ignore madvise(MADV_WILLNEED) for hugetlbfs-backed regions

Michael Wolf (1):
      powerpc adjust oprofile_cpu_type version 3

Michal Januszewski (1):
      fbdev: fix fillrect for 24bpp modes

Michal Simek (1):
      microblaze: Fix return value for sys_ipc

Mike Christie (5):
      [SCSI] fix q->lock not held warning when target is busy
      [SCSI] iscsi_tcp: don't fire conn error if pdu init fails
      [SCSI] cxgb3i, iser, iscsi_tcp: set target can queue
      [SCSI] cxgb3i: fix can_queue and cmd_per_lun initialization
      [SCSI] cxgb3i: fix cpu use abuse during writes

Ming Lei (1):
      locking: Documentation: lockdep-design.txt, fix note of state bits

NeilBrown (6):
      md: fix loading of out-of-date bitmap.
      md/raid10: don't clear bitmap during recovery if array will still b=
e degraded.
      md: fix some (more) errors with bitmaps on devices larger than 2TB.
      md: tidy up status_resync to handle large arrays.
      md: remove ability to explicit set an inactive array to 'clean'.
      md: remove rd%d links immediately after stopping an array.

Nick Piggin (1):
      mm: close page_mkwrite races

Nico Schottelius (1):
      kbuild: fix scripts/setlocalversion with git

Nicolas Pitre (3):
      [ARM] Kirkwood: update defconfig
      [ARM] orion5x: update defconfig
      [ARM] mv78xx0: update defconfig

Nikanth Karthikesan (1):
      x86: Fix a typo in a printk message

Olaf Weber (1):
      xfs: add more checks to superblock validation

Oleg Nesterov (1):
      ptrace: s/parent/real_parent/ in binfmt_elf_fdpic.c

Oliver Neukum (1):
      HID: fix possible deadlock in usbhid_close()

Omar Laazimani (1):
      usbnet: CDC EEM support (v5)

Paul Gortmaker (1):
      [ARM] 5507/1: support R_ARM_MOVW_ABS_NC and MOVT_ABS relocation typ=
es

Paul Walmsley (4):
      OMAP2xxx clock: pre-initialize struct clks early
      OMAP2xxx clock: fix broken cpu_mask code
      OMAP3 GPTIMER: fix GPTIMER12 IRQ
      OMAP2/3 GPTIMER: allow system tick GPTIMER to be changed in board-*=
.c files

Peter Horton (1):
      mtd: fix timeout in M25P80 driver

Peter Jones (1):
      [SCSI] sr: report more accurate drive status after closing the tray.

Philipp Zabel (1):
      [ARM] pxa: remove unused CPU_FREQ_PXA Kconfig symbol

Pierre Ossman (2):
      mmc_block: be prepared for oversized requests
      sdhci: catch ADMA errors

Ping Cheng (1):
      Input: wacom - fix TabletPC touch bug

Rabin Vincent (3):
      Subject: [PATCH] br2684: restore net_dev initialization
      mmci: fix crash with debug enabled
      mvsdio: fix CONFIG_PM=3Dy build

Ralph Wuerthner (1):
      alloc_vmap_area: fix memory leak

Randy Dunlap (3):
      docs: also clean index.html
      kernel-doc: restrict syntax for private: and public:
      doc: small kernel-parameters updates

Robert Love (2):
      [SCSI] libfc: Fix compilation warnings with allmodconfig
      net: Only store high 16 bits of kernel generated filter priorities

Robert Moore (1):
      acpica: validate package element more carefully in acpi_rs_get_pci_=
routing_table_length

Robert P. J. Day (2):
      kbuild: "make prepare" should be "make modules_prepare"
      [ARM] Kconfig typo fix:  "PXA930" -> "CPU_PXA930".

Roel Kluin (2):
      ARM: OMAP2: possible division by 0
      i2c: Timeouts off by 1

Roger Quadros (2):
      ARM: OMAP3: Fixed spurious IRQ issue for GPIO interrupts
      ARM: OMAP3: Clean up spurious interrupt check logic

Russell King (7):
      Merge branch 'omap-fixes' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/tmlind/linux-omap-2.6
      [ARM] lart: fix build error
      Merge branch 'for-rmk' of git://git.kernel.org/pub/scm/linux/kernel=
/git/khilman/linux-davinci
      Merge branch 'fix' of git://git.kernel.org/pub/scm/linux/kernel/git=
/ycmiao/pxa-linux-2.6
      Merge branch 'v2630-rc3-fixes' of git://aeryn.fluff.org.uk/bjdooks/=
linux
      Merge branch 'for-rmk' of git://git.marvell.com/orion
      Merge branch 'for-rmk' of git://git.pengutronix.de/git/imx/linux-2.=
6

Sam Ravnborg (4):
      avr32: drop unused CLEAN_FILES
      kbuild: fix comment in modpost.c
      kbuild, modpost: fix "unexpected non-allocatable" warning with SUSE=
 gcc
      kbuild, modpost: fix unexpected non-allocatable warning with mips

Santosh Shilimkar (1):
      ARM: OMAP: Fix for possible race condition in omap_free_dma()

Sascha Hauer (2):
      MXC: remove BUG_ON in interrupt handler
      mx3fb: Fix compilation with CONFIG_PM

Satoru SATOH (1):
      tcp: Fix tcp_prequeue() to get correct rto_min value

Sergey Senozhatsky (1):
      cxgb3: fixing gcc 4.4 compiler warning: suggest parentheses around =
operand of =E2=80=98!=E2=80=99

Sergio Aguirre (1):
      OMAP3: clock: Camera module doesn't have IDLEST bit

Stefan Bader (1):
      vgacon: return the upper half of 512 character fonts

Stephen Rothwell (1):
      wireless: remove unneeded EXPORT_SYMBOL the tickles a powerpc compi=
ler bug

Stephen Smalley (1):
      selinux: Fix send_sigiotask hook

Steve French (19):
      [CIFS] Make cifs_unlink consistent in checks for null inode
      Merge branch 'master' of /pub/scm/linux/kernel/git/torvalds/linux-2=
.6
      Merge branch 'master' of /pub/scm/linux/kernel/git/torvalds/linux-2=
.6
      [CIFS] Remove older session setup implementation
      [CIFS] rename cifs_strndup to cifs_strndup_from_ucs
      [CIFS] Remove unneeded QuerySymlink call and fix mapping for unmapp=
ed status
      [CIFS] Fix build warning
      [CIFS] Add remaining ntlmssp flags and standardize field names
      [CIFS] Remove sparse endian warnings
      [CIFS] Remove trailing whitespace
      [CIFS] Fix endian conversion of vcnum field
      [CIFS] NTLMSSP support moving into new file, old dead code removed
      [CIFS] Fix final user of old string conversion code
      [CIFS] remove checkpatch warning
      [CIFS] Remove sparse warning
      [CIFS] NTLMSSP reenabled after move from connect.c to sess.c
      [CIFS] Fix SMB uid in NTLMSSP authenticate request
      [CIFS] Allow raw ntlmssp code to be enabled with sec=3Dntlmssp
      [CIFS] Fix double list addition in cifs posix open code

Steve Glendinning (2):
      smsc95xx: configure LED outputs
      smsc95xx: add support for LAN9512 and LAN9514

Steven A. Falco (1):
      mtd: Bug in m25p80.c during whole-chip erase

Steven Rostedt (1):
      tracing: fix ref count in splice pages

Stuart Bennett (1):
      tracing: x86, mmiotrace: fix range test

Subrata Modak (1):
      configfs: Fix Trivial Warning in fs/configfs/symlink.c

Sudhakar Rajashekhara (1):
      davinci: DM646x: add interrupt number and priorities

Sunil Mushran (1):
      ocfs2: Add missing iput() during error handling in ocfs2_dentry_att=
ach_lock()

Suresh Jayaraman (2):
      cifs: Rename cifs_strncpy_to_host and fix buffer size
      cifs: Increase size of tmp_buf in cifs_readdir to avoid potential o=
verflows

Swen Schillig (6):
      [SCSI] zfcp: Enable auto-port discovery for NPIV.
      [SCSI] zfcp: Dont block zfcp_wq with scan
      [SCSI] zfcp: Set WKA-port to offline on adapter deactivation
      [SCSI] zfcp: avoid false ERP complete due to sema race
      [SCSI] zfcp: no port recovery after storage side error inject
      [SCSI] zfcp: no port recovery after ADISC request timeout

Takashi Iwai (7):
      ALSA: Add missing SNDRV_PCM_INFO_BATCH flag to some drivers
      ALSA: pcm core - Avoid jiffies check for devices with BATCH flag
      Merge branch 'fix/pcm-jiffies-check' into fix/asoc
      ASoC: Remove BROKEN from mpc5200 kconfig
      Merge branch 'fix/pcm-jiffies-check' into for-linus
      Merge branch 'fix/asoc' into for-linus
      Merge branch 'fix/misc' into for-linus

Tao Ma (3):
      ocfs2: Reserve 1 more cluster in expanding_inline_dir for indexed d=
ir.
      ocfs2: Fix 2 warning during ocfs2 make.
      ocfs2/trivial: Remove unused variable in ocfs2_rename.

Thomas Gleixner (2):
      Revert "genirq: assert that irq handlers are indeed running in hard=
irq context"
      x86: initialize io_bitmap_base on 32bit

Tobias Klauser (1):
      microblaze: Storage class should be before const qualifier

Tony Lindgren (2):
      ARM: OMAP: Remove old dead gpio expander code
      Merge branch 'omap-clock-fixes' into omap-fixes

Trond Myklebust (2):
      SUNRPC: Fix the problem of EADDRNOTAVAIL syslog floods on reconnect
      NFS: Close page_mkwrite() races

Ulrich Dangel (1):
      HID: Fix the support for apple mini aluminium keyboard

Uwe Kleine-K=C3=B6nig (1):
      mx27ads: move PBC mapping out of vmalloc space

Valentin Longchamp (1):
      mx31: remove mx31moboard_defconfig

Vitaly Mayatskikh (1):
      pagemap: require aligned-length, non-null reads of /proc/pid/pagema=
p

Wu Fengguang (1):
      inotify: use GFP_NOFS in kernel_event() to work around a lockdep fa=
lse-positive

john stultz (1):
      clockevents: prevent endless loop in tick_handle_periodic()

kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org (1):
      [SCSI] cxgb3i: fix ddp map overrun

s-paulraj-l0cyMroinI0@public.gmane.org (1):
      davinci: DM355 IRQ Definitions

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr

--===============9036249145828696642==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============9036249145828696642==--
