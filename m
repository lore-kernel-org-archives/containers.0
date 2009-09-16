From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr annotated tag, v2.6.29-rc4, created. v2.6.29-rc4
Date: Wed, 16 Sep 2009 14:36:42 -0400
Message-ID: <200909161836.n8GIagVQ001258@gorgona.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2994278068885041656=="
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

--===============2994278068885041656==
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by smtp1.linux-foundation.org id n8GJTvvp009607

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The annotated tag, v2.6.29-rc4 has been created
        at  87c16e9e8bb74f14f4504305957e4346e7fc46ea (tag)
   tagging  8e4921515c1a379539607eb443d51c30f4f7f338 (commit)
  replaces  v2.6.29-rc3
 tagged by  Linus Torvalds
        on  Sun Feb 8 12:37:36 2009 -0800

- Log -----------------------------------------------------------------
Linus 2.6.29-rc4
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkmPQpUACgkQF3YsRnbiHLtjIQCgrDkhmrdpMou2QBF3tgZfv2UT
18wAoI0wpUeCvqte/csVEOnnR09vtIfU
=3Dww1w
-----END PGP SIGNATURE-----

Aaro Koskinen (1):
      ARM: OMAP: gptimer min_delta_ns corrected

Adrian Hunter (5):
      UBIFS: ensure orphan area head is initialized
      UBIFS: fix LPT out-of-space bug (again)
      UBIFS: sync wbufs after syncing inodes and pages
      UBIFS: spelling fix 'date' -> 'data'
      UBIFS: remount ro fixes

Al Viro (1):
      braino in sg_ioctl_trans()

Alberto Bertogli (3):
      Fix small typo in bio.h's documentation
      Fix misleading comment in bio.h
      bio.h: If they MUST be inlined, then use __always_inline

Alex Buell (1):
      fbdev: incorrect URL given in drivers/video/Kconfig

Alex Chiang (1):
      PCI: properly clean up ASPM link state on device remove

Alexander Beregalov (1):
      sata_sil: Fix build breakage

Alexander Duyck (3):
      igb: Fix DCA errors and do not use context index for 82576
      igb: prevent skb_over panic w/ mtu smaller than 1K
      igb: fix link reporting when using sgmii

Alexey Dobriyan (3):
      sky2: fix hard hang with netconsoling and iface going up
      alpha: fixup BUG macro
      seq_file: fix big-enough lseek() + read()

Alexey Klimov (1):
      V4L/DVB (10317): radio-mr800: fix radio->muted and radio->stereo

Andre Noll (1):
      md: Fix a bug in linear.c causing which_dev() to return the wrong d=
evice.

Andrea Righi (1):
      fbmem: don't call copy_from/to_user() with mutex held

Andreas Schwab (1):
      x86 setup: fix asm constraints in vesa_store_edid

Andrew Morton (4):
      drivers/gpu/drm/i915/intel_lvds.c: fix locking snafu
      kernel/async.c: fix printk warnings
      revert "rlimit: permit setting RLIMIT_NOFILE to RLIM_INFINITY"
      hp-wmi: fix error path in hp_wmi_bios_setup()

Andy Fleming (2):
      gianfar: Fix BD_LENGTH_MASK definition
      gianfar: Fix potential soft reset race

Andy Walls (3):
      V4L/DVB (10218): cx23885: Fix Oops for mixed install of analog and =
digital only cards
      V4L/DVB (10219): saa7134: Prevent Oops due to stale IRQ status when=
 enabling interrupts
      V4L/DVB (10229): cx88-dvb: Fix order of frontend allocations

Anton Vorontsov (1):
      gianfar: Fix Wake-on-LAN support

Antti Palosaari (2):
      V4L/DVB (10287): af9015: fix second FE
      V4L/DVB (10288): af9015: bug fix: stick does not work always when p=
lugged

Arjan van de Ven (1):
      ahci: add a module parameter to ignore the SSS flags for async scan=
ning

Artem Bityutskiy (20):
      UBI: improve ioctl commentaries
      UBI: remove unnecessry header inclusion
      UBI: allow all ioctls
      UBIFS: do not commit twice
      UBIFS: constify operations
      UBI: add ioctl compatibility
      UBI: use nicer 64-bit math
      UBIFS: do not treat all data as short term
      UBIFS: document dark_wm and dead_wm better
      UBI: remove unused variable
      UBI: fix resource de-allocation
      UBIFS: simplify locking
      UBIFS: fix LEB list freeing
      UBIFS: add re-mount debugging checks
      UBIFS: always clean up GC LEB space
      UBIFS: fix assertions
      UBIFS: fix no_chk_data_crc
      UBIFS: return sensible error codes
      UBIFS: remove fast unmounting
      write-back: fix nr_to_write counter

Arve Hj=C3=B8nnev=C3=A5g (3):
      Staging: android: binder: fix arm build errors
      Staging: android: timed_gpio: Fix build to build on kernels after 2=
.6.25.
      Staging: android: Add lowmemorykiller documentation.

Atsushi Nemoto (2):
      MIPS: TXx9: Add support for TX4939 internal RTC
      tx4939ide: typo fix and minor cleanup

Atsushi SAKAI (1):
      lguest: typos fix

Balaji Rao (1):
      mfd: Remove non exported references from pcf50633

Bartlomiej Zolnierkiewicz (4):
      block: export SSD/non-rotational queue flag through sysfs
      ide: fix ide_register_port() failure handling
      ide: add CS5536 host driver (v3)
      icside: fix PCB version 6 support (v2)

Ben Hutchings (5):
      sfc: SFN4111T: Fix GPIO sharing between I2C and FLASH_CFG_1
      sfc: Update board info for hardware monitor on SFN4111T-R5 and late=
r
      sfc: SFT9001: Always enable XNP exchange on SFT9001 rev B
      sfc: SFX7101/SFT9001: Fix AN advertisements
      sfc: Replace stats_enabled flag with a disable count

Benjamin Herrenschmidt (4):
      powerpc: Fix oops on some machines due to incorrect pr_debug()
      atyfb: Properly save PCI state before changing PCI PM level
      aty128fb: Properly save PCI state before changing PCI PM level
      radeonfb: Fix resume from D3Cold on some platforms

Benjamin Zores (1):
      ipv4: fix infinite retry loop in IP-Config

Bernd Schmidt (1):
      Blackfin arch: fix bug - traps test case 19 for exception 0x2d fail=
s

Bharath Ramesh (1):
      hwmon: applesmc: add support for MacPro 3 temperature sensors

Bill Nottingham (1):
      Documentation/Changes: add required versions for new filesystems

Boaz Harrosh (1):
      include/linux: Add bsg.h to the Kernel exported headers

Bob Copeland (1):
      ath5k: fix locking in ath5k_config

Borislav Petkov (2):
      ide-cd: fix DMA for non bio-backed requests
      x86: APIC: enable workaround on AMD Fam10h CPUs

Bryan Wu (1):
      Blackfin arch: Add ANOMALY_05000380 to BF54x to kill the compile wa=
rning

Carmelo AMOROSO (1):
      sh: fcnvds fix with denormalized numbers on SH-4 FPU.

Carsten Otte (1):
      do_wp_page: fix regression with execute in place

Chris Ball (1):
      Btrfs: Handle SGID bit when creating inodes

Chris Mason (19):
      Btrfs: stop providing a bmap operation to avoid swapfile corruption=
s
      Btrfs: do less aggressive btree readahead
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/mason/btrfs-unstable
      Btrfs: fix readdir on 32 bit machines
      Btrfs: Catch missed bios in the async bio submission thread
      Btrfs: async threads should try harder to find work
      Btrfs: sort references by byte number during btrfs_inc_ref
      Btrfs: disable leak debugging checks in extent_io.c
      Btrfs: hash_lock is no longer needed
      Btrfs: Change btree locking to use explicit blocking points
      Btrfs: Make btrfs_drop_snapshot work in larger and more efficient c=
hunks
      Btrfs: Don't try to compress pages past i_size
      Btrfs: Change btrfs_truncate_inode_items to stop when it hits the i=
node
      Btrfs: change btrfs_del_leaf to drop locks earlier
      Btrfs: fix btrfs_unlock_up_safe to walk the entire path
      Btrfs: Only prep for btree deletion balances when nodes are mostly =
empty
      Btrfs: don't return congestion in write_cache_pages as often
      Btrfs: Fix memory leak in cache_drop_leaf_ref
      Btrfs: Make sure dir is non-null before doing S_ISGID checks

Christian Hesse (1):
      Btrfs: make btrfs acls selectable

Christopher SMITH (1):
      sh: Only reserve memory under CONFIG_ZERO_PAGE_OFFSET when it !=3D =
0.

Clemens Ladisch (1):
      sound: usb-audio: handle wMaxPacketSize for FIXED_ENDPOINT devices

Cliff Brake (2):
      pxamci: replace #ifdef CONFIG_PXA27x with if (cpu_is_pxa27x())
      pxamci: enable DMA for write ops after CMD/RESP

Cord Walter (1):
      pcnet_cs: Fix misuse of the equality operator.

Corentin Chary (10):
      UBI: add ioctl for map operation
      UBI: add ioctl for unmap operation
      UBI: add ioctl for is_mapped operation
      eeepc-laptop: split eeepc_backlight_exit()
      asus_acpi: Add R1F support
      asus-laptop: use generic netlink interface
      asus-laptop: hotkeys via the generic input interface
      asus-laptop: update Kconfig for input layer
      asus-laptop: fix label indentation
      eeepc-laptop: use netlink interface

Cornelia Huck (4):
      async: Fix running list handling.
      async: Handle kthread_run() return codes.
      async: Add some documentation.
      async: Rename _special -> _domain for clarity.

Daisuke Nishimura (1):
      memcg: get/put parents at create/free

Dan Carpenter (2):
      fix emacs indenting howto filename expansion
      sx.c: fix missed unlock_kernel() on error path in sx_fw_ioctl()

Daniel Marjam=C3=A4ki (1):
      netxen: fix memory leak in drivers/net/netxen_nic_init.c

Darren Salt (1):
      eeepc-laptop: fix oops when changing backlight brightness during ee=
epc-laptop init

Darrick J. Wong (1):
      PCI hotplug: fakephp: Allocate PCI resources before adding the devi=
ce

Dave Chinner (1):
      xfs: Check buffer lengths in log recovery

Dave Jones (2):
      ipv6: compile fix for ip6mr.c
      x86: add cache descriptors for Intel Core i7

Dave Kleikamp (1):
      vfs: Don't call attach_nobh_buffers() with an empty list

David Altobelli (2):
      hpilo: increment version
      hpilo: open/close fix

David Brownell (1):
      rtc: rtc-dm355evm driver

David Daney (3):
      MIPS: Fix a typo in watchpoint register structure.
      MIPS: Read watch registers with interrupts disabled.
      MIPS: Use hardware watchpoints on all R1 and R2 CPUs.

David Howells (1):
      CRED: Fix SUID exec regression

David Rientjes (1):
      slub: fix per cpu kmem_cache_cpu array memory leak

David S. Miller (13):
      ipv6: Make mc_forwarding sysctl read-only.
      sparc64: Move generic PCR support code to seperate file.
      sparc: Probe PMU type and record in sparc_pmu_type.
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-2.6
      tun: Add some missing TUN compat ioctl translations.
      sparc64: Implement NMI watchdog on capable cpus.
      net: Fix userland breakage wrt. linux/if_tunnel.h
      sparc64: On non-Niagara, need to touch NMI watchdog in NOHZ mode.
      sparc64: Validate kernel generated fault addresses on sparc64.
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/torvalds/linux-2.6
      sparc64: Kill bogus TPC/address truncation during 32-bit faults.
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-2.6
      Revert "tcp: Always set urgent pointer if it's beyond snd_nxt"

David Vrabel (7):
      uwb: safely remove all reservations
      wusb: return -ENOTCONN when resetting a port with no connected devi=
ce
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6 into for-upstream
      wusb: timeout when waiting for ASL/PZL updates in whci-hcd
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6 into for-upstream
      uwb: lock rc->rsvs_lock with spin_lock_bh()
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6 into for-upstream

Davide Libenzi (1):
      epoll: drop max_user_instances and rely only on max_user_watches

Dean Nelson (2):
      sgi-xp: link XPNET's net_device_ops to its net_device structure
      sgi-xp: fix writing past the end of kzalloc()'d space

Devin Heitmueller (2):
      V4L/DVB (10261): em28xx: fix kernel panic on audio shutdown
      V4L/DVB (10411): s5h1409: Perform s5h1409 soft reset after tuning

Dhananjay Phadke (1):
      netxen: revert jumbo ringsize

Dimitris Michailidis (1):
      tcp: Fix length tcp_splice_data_recv passes to skb_splice_bits.

Divy Le Ray (1):
      cxgb3: Fix lro switch

Divyesh Shah (1):
      cfq-iosched: Allow RT requests to pre-empt ongoing BE timeslice

Ed Swierk (1):
      signals, debug: fix BUG: using smp_processor_id() in preemptible co=
de in print_fatal_signal()

Eero Nurkkala (1):
      OMAP: ASoC: Fix spinlock misuse in omap-pcm.c

Eric Biederman (1):
      seq_file: move traverse so it can be used from seq_read

Eric Dumazet (4):
      udp: optimize bind(0) if many ports are in use
      net: wrong test in inet_ehash_locks_alloc()
      udp: increments sk_drops in __udp_queue_rcv_skb()
      modules: Use a better scheme for refcounting

Eric Piel (1):
      lis3lv02d: add axes knowledge for HP 6530

Eric Sandeen (1):
      don't reallocate sxp variable passed into xfs_swapext

Evgeniy Polyakov (1):
      mm: OOM documentation update

Felix Blyakher (2):
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6 into for-linus
      [XFS] Warn on transaction in flight on read-only remount

Filip Aben (1):
      hso: add new device id's

Frank Seidel (1):
      ACPI: add missing KERN_* constants to printks

Frans Pop (2):
      hp-wmi: fix regressions caused by missing if statement
      hp-wmi: set initial docking state

Frederic Weisbecker (2):
      tracing/function-graph-tracer: fix a regression while suspend to di=
sk
      hrtimers: increase clock min delta threshold while interrupt hangin=
g

Geert Uytterhoeven (1):
      staging: agnx: drivers/staging/agnx/agnx.h needs <linux/io.h>

Gerhard Pircher (1):
      ide: Force VIA IDE legacy interrupts for AmigaOne boards

Grace Pan (1):
      Blackfin arch: Add in cflag to support mlong-calls for kgdb_test

Graf Yang (3):
      Blackfin arch: Fix bug - BF518 port F, G, and H have different mux =
offset compare to BF527
      Blackfin arch: Fix bug - 561 SMP kernel can't boot from jffs2
      Blackfin arch: add platform device bfin_mii-bus and KSZ8893M switch=
 driver platform resources to board files

Grant Likely (3):
      powerpc/5200: update defconfigs
      powerpc/5200: Bugfix for PCI mapping of memory and IMMR
      powerpc/5200: update device tree binding documentation

Greg Kroah-Hartman (3):
      Staging: comedi: fix Kbuild
      Staging: meilhaus: fix Kbuild
      Staging: android: fix build error on 64bit boxes

H. Peter Anvin (2):
      x86: correct the CPUID pattern for MSR_IA32_MISC_ENABLE availabilit=
y
      x86: add x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org to MAINTAINERS

Haiying Wang (1):
      ucc_geth: Change uec phy id to the same format as gianfar's

Hans J. Koch (1):
      UIO: Add missing documentation of features added recently

Hans Verkuil (8):
      V4L/DVB (10214): Fix 'stb0899_get_srate' defined but not used warni=
ng
      V4L/DVB (10230): v4l2-device: fix buggy macro
      V4L/DVB (10243): em28xx: fix compile warning
      V4L/DVB (10248): v4l-dvb: fix a bunch of compile warnings.
      V4L/DVB (10250): cx25840: fix regression: fw not loaded on first us=
e
      V4L/DVB (10270): saa7146: fix unbalanced mutex_lock/unlock
      V4L/DVB (10314): cx25840: ignore TUNER_SET_CONFIG in the command ca=
llback.
      V4L/DVB (10229): ivtv: fix memory leak

Hans-Christian Egtvedt (1):
      atmel-ssc: fix misuse of dev_dbg when requested ssc instance is not=
 found

Herbert Xu (3):
      net: Fix frag_list handling in skb_seq_read
      packet: Avoid lock_sock in mmap handler
      ipv6: Copy cork options in ip6_append_data

Holger Macht (1):
      ACPI: dock: Don't eval _STA on every show_docked sysfs read

Huang Weiyi (5):
      uwb: remove unused #include <version.h>'s
      Btrfs: removed unused #include <version.h>'s
      Btrfs: remove duplicated #include
      V4L/DVB (10193): removed unused #include <version.h>'s
      MIPS: Octeon: Remove duplicated #includes

Ian Campbell (1):
      IDE: Unregister and disable devices if initialization fails.

Inaky Perez-Gonzalez (1):
      wimax: fix build issue when debugfs is disabled

Ingo Molnar (3):
      irq: export __set_irq_handler() and handle_level_irq()
      x86: tone down mtrr_trim_uncached_memory() warning
      Merge branch 'core/xen' into x86/urgent

Ira W. Snyder (1):
      virtio_net: use correct accessors for scatterlists

Ivan Kokshaysky (3):
      alpha: use syscall wrappers
      alpha: compile fixes
      alpha: fix the BUG() macro

James Bottomley (1):
      x86/Voyager: make it build and boot

Jan Engelhardt (2):
      UBI: constify file operations
      Btrfs: change/remove typedef

Jan Kara (2):
      ocfs2: Push out dropping of dentry lock to ocfs2_wq
      ocfs2: Fix possible deadlock in ocfs2_write_dquot()

Jarkko Nikula (1):
      ARM: OMAP: DMA: Fix uninitialized channel flags

Jarod Wilson (1):
      HID: add antec-branded soundgraph imon devices to blacklist

Jaswinder Singh Rajput (90):
      headers_check fix: can/bcm.h
      headers_check fix: dvb/audio.h
      headers_check fix: dvb/dmx.h
      headers_check fix: dvb/frontend.h
      headers_check fix: dvb/net.h
      headers_check fix: dvb/video.h
      headers_check fix: netfilter/xt_conntrack.h
      headers_check fix: nfsd/export.h
      headers_check fix: nfsd/nfsfh.h
      headers_check fix: nfsd/syscall.h
      headers_check fix: raid/md_p.h
      headers_check fix: spi/spidev.h
      headers_check fix: tc_act/tc_gact.h
      headers_check fix: tc_act/tc_mirred.h
      headers_check fix: tc_act/tc_pedit.h
      headers_check fix: tc_ematch/tc_em_cmp.h
      headers_check fix: tc_ematch/tc_em_meta.h
      headers_check fix: tc_ematch/tc_em_nbyte.h
      headers_check fix: tc_ematch/tc_em_text.h
      headers_check fix: usb/cdc.h
      headers_check fix: usb/gadgetfs.h
      headers_check fix: linux/aio_abi.h
      headers_check fix: linux/atalk.h
      headers_check fix: linux/atmbr2684.h
      headers_check fix: linux/auto_fs4.h
      headers_check fix: linux/bfs_fs.h
      headers_check fix: linux/blktrace_api.h
      headers_check fix: linux/capability.h
      headers_check fix: linux/cdrom.h
      headers_check fix: linux/cgroupstats.h
      headers_check fix: linux/dlm_plock.h
      headers_check fix: linux/dn.h
      headers_check fix: linux/edd.h
      headers_check fix: linux/efs_fs_sb.h
      headers_check fix: linux/elf-fdpic.h
      headers_check fix: linux/elf.h
      headers_check fix: linux/errqueue.h
      headers_check fix: linux/genetlink.h
      headers_check fix: linux/gfs2_ondisk.h
      headers_check fix: linux/hid.h
      headers_check fix: linux/hiddev.h
      headers_check fix: linux/icmpv6.h
      headers_check fix: linux/if_addr.h
      headers_check fix: linux/if_addrlabel.h
      headers_check fix: linux/if_fc.h
      headers_check fix: linux/if_hippi.h
      headers_check fix: linux/if_link.h
      headers_check fix: linux/if_ppp.h
      headers_check fix: linux/if_strip.h
      headers_check fix: linux/if_tr.h
      headers_check fix: linux/igmp.h
      headers_check fix: linux/inet_diag.h
      headers_check fix: linux/ip6_tunnel.h
      headers_check fix: linux/ipv6.h
      headers_check fix: linux/ipv6_route.h
      headers_check fix: linux/ipx.h
      headers_check fix: linux/irda.h
      headers_check fix: linux/minix_fs.h
      headers_check fix: linux/msdos_fs.h
      headers_check fix: linux/neighbour.h
      headers_check fix: linux/nfs_idmap.h
      headers_check fix: linux/phonet.h
      headers_check fix: linux/pkt_cls.h
      headers_check fix: linux/pkt_sched.h
      headers_check fix: linux/ppp_defs.h
      headers_check fix: linux/random.h
      headers_check fix: linux/signalfd.h
      headers_check fix: linux/sound.h
      headers_check fix: linux/synclink.h
      headers_check fix: linux/taskstats.h
      headers_check fix: linux/video_decoder.h
      headers_check fix: linux/video_encoder.h
      headers_check fix: linux/videodev.h
      headers_check fix: linux/virtio_blk.h
      headers_check fix: linux/virtio_console.h
      headers_check fix: linux/virtio_net.h
      headers_check fix: mtd/inftl-user.h
      headers_check fix: sound/hdsp.h
      headers_check fix: video/sisfb.h
      headers_check fix: video/uvesafb.h
      headers_check fix: linux/nubus.h
      headers_check fix: linux/rtnetlink.h
      headers_check fix: x86, e820.h
      headers_check fix: x86, kvm.h
      headers_check fix: x86, mce.h
      headers_check fix: x86, mtrr.h
      headers_check fix: x86, ptrace-abi.h
      headers_check fix: x86, sigcontext.h
      headers_check fix: x86, sigcontext32.h
      headers_check fix: x86, swab.h

Jean-Francois Moine (1):
      V4L/DVB (10385): gspca - main: Fix memory leak when USB disconnecti=
on while streaming.

Jeff Layton (2):
      cifs: turn smb_send into a wrapper around smb_sendv
      cifs: make sure we allocate enough storage for socket address

Jeff Mahoney (1):
      kmalloc: return NULL instead of link failure

Jens Axboe (8):
      block: get rid of the manual directory counting in blktrace
      block: seperate bio/request unplug and sync bits
      block: add bio_rw_flagged() for testing bio->bi_rw
      block: silently error an unsupported barrier bio
      block: add sysfs file for controlling io stats accounting
      block: fix oops in blk_queue_io_stat()
      block: fix inconsistent parenthesisation of QUEUE_FLAG_DEFAULT
      block: add text file detailing queue/ sysfs files

Jeremy Fitzhardinge (2):
      xen: make sysfs files behave as their names suggest
      xen: disable interrupts before saving in percpu

Jesper Dangaard Brouer (1):
      udp: Fix UDP short packet false positive

Jesse Brandeburg (1):
      e1000: fix bug with shared interrupt during reset

Jie Zhang (2):
      Blackfin arch: Add one more check on `fp' to prevent double fault
      Blackfin arch: fix 2 bugs related to debug

Jim Owens (1):
      Btrfs: selinux support

Jiri Kosina (2):
      HID: adjust report descriptor fixup for MS 1028 receiver
      HID: document difference between hid_blacklist and hid_ignore_list

Jiri Pirko (1):
      net: fix xfrm reverse flow lookup for icmp6

Jiri Tersel (1):
      lis3lv02d: add axes knowledge for HP 6510b

Joe Perches (1):
      Btrfs: MAINTAINERS entry

Joel Becker (1):
      configfs: Silence lockdep on mkdir(), rmdir() and configfs_depend_i=
tem()

Joerg Schirottke (1):
      ALSA: hda - Add quirk for HP DV6700 laptop

Johannes Berg (1):
      mac80211: remove Michael Wu as maintainer

Johannes Weiner (1):
      wait: prevent exclusive waiter starvation

Josef Bacik (2):
      Btrfs: cleanup xattr code
      Btrfs: join the transaction in __btrfs_setxattr

Juha Yrjola (1):
      ARM: OMAP: Fix race in OMAP2/3 DMA IRQ handling

KAMEZAWA Hiroyuki (4):
      cgroups: use hierarchy mutex in creation failure path
      memcg: fix refcnt handling at swapoff
      memcg: update document to mention that swapoff should be tested
      memcg: NULL pointer dereference at rmdir on some NUMA systems

Karsten Keil (1):
      e1000: Fix PCI enable to honor the need_ioport flag

Kay Sievers (2):
      ide: struct device - replace bus_id with dev_name(), dev_set_name()
      ACPI: struct device - replace bus_id with dev_name(), dev_set_name(=
)

Kevin Hilman (1):
      ARM: OMAP: fix fault in enter_full_retention()

Kuninori Morimoto (4):
      sh: mach-migor: Enable ov772x and tw9910 in defconfig.
      sh: ap325rxa: control camera power toggling.
      sh: ap325rxa: Add ov772x support.
      sh: ap325rxa: Enable ov772x in defconfig.

Lai Jiangshan (1):
      ring_buffer: reset write when reserve buffer fail

Larry Finger (1):
      rtl8187: Fix error in setting OFDM power settings for RTL8187L

Laurent Pinchart (3):
      V4L/DVB (10197): uvcvideo: Whitespace and comments cleanup, copyrig=
ht updates.
      V4L/DVB (10198): uvcvideo: Print the UVC version number in binary-c=
oded decimal.
      V4L/DVB (10199): uvcvideo: Fix GET_DEF failure detection.

Len Brown (7):
      ACPI: remove locking from PM1x_STS register reads
      ACPI: remove BM_RLD access from idle entry path
      ACPICA: add debug dump of BIOS _OSI strings
      ACPI: make some IO ports off-limits to AML
      ACPI: delete CPU_IDLE=3Dn code
      ACPI: disable ACPI cleanly when bad RSDP found
      Merge branches 'release', 'asus', 'bugzilla-12450', 'cpuidle', 'deb=
ug', 'ec', 'misc', 'printk' and 'processor' into release

Li Zefan (2):
      cgroups: fix lock inconsistency in cgroup_clone()
      fork.c: fix NULL pointer dereference when nr_threads =3D=3D threads=
-max

Liam Girdwood (1):
      ALSA: ASoC: email - update email addresses.

Linus Torvalds (60):
      Fix OOPS in mmap_region() when merging adjacent VM_LOCKED file segm=
ents
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/ieee1394/linux1394-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/rusty/linux-2.6=
-for-linus
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jikos/hid
      Merge branch 'linux-next' of git://git.infradead.org/ubi-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-c=
ore-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging-=
2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/sfrench/cifs-2.=
6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'for-linus' of git://git.kernel.dk/linux-2.6-block
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tytso/ext4
      Allow opportunistic merging of VM_CAN_NONLINEAR areas
      Stop playing silly games with the VM_ACCOUNT flag
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'upstream' of git://ftp.linux-mips.org/pub/scm/upstrea=
m-linus
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/lrg/voltage-2.6
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'tracing-fixes-for-linus' of git://git.kernel.org/pub/=
scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'timers-fixes-for-linus' of git://git.kernel.org/pub/s=
cm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'irq-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'core-fixes-for-linus' of git://git.kernel.org/pub/scm=
/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'header-fixes-for-linus' of git://git.kernel.org/pub/s=
cm/linux/kernel/git/tip/linux-2.6-tip
      Manually revert "mlock: downgrade mmap sem while populating mlocked=
 regions"
      Merge branch 'for-linus' of git://git.kernel.dk/linux-2.6-block
      Merge branch 'for-upstream' of git://git.kernel.org/pub/scm/linux/k=
ernel/git/dvrabel/uwb
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/bart/ide-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/drzeus/mmc
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/mchehab/linux-2.6
      Merge branch 'sched-fixes-for-linus' of git://git.kernel.org/pub/sc=
m/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/benh/powerpc
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/penberg/slab-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jbarnes/pci-2.6
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/jgarzik/libata-dev
      Merge branch 'for-linus' of git://oss.sgi.com/xfs/xfs
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/mfasheh/ocfs2
      Merge master.kernel.org:/home/rmk/linux-2.6-arm
      Merge branch 'linux-next' of git://git.infradead.org/ubifs-2.6
      Merge branch 'for-linus' of git://git.o-hand.com/linux-mfd
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/cooloney/blackfin-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge branch 'tracing-fixes-for-linus' of git://git.kernel.org/pub/=
scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'sched-fixes-for-linus' of git://git.kernel.org/pub/sc=
m/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'sh/for-2.6.29' of git://git.kernel.org/pub/scm/linux/=
kernel/git/lethal/sh-2.6
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/mfasheh/ocfs2
      Merge branch 'for-linus' of git://neil.brown.name/md
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/ieee1394/linux1394-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge branch 'to-linus' of git://git.kernel.org/pub/scm/linux/kerne=
l/git/frob/linux-2.6-roland
      Merge branch 'x86/fixes' of git://git.kernel.org/pub/scm/linux/kern=
el/git/frob/linux-2.6-roland
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/mason/btrfs-uns=
table
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jmorris/security-testing-2.6
      Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel=
/git/lenb/linux-acpi-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jbarnes/pci-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/arjan/linux-2.6=
-async-update
      Linux 2.6.29-rc4

Linus Walleij (1):
      mmci: Add support for ST Micro derivate

Luis R. Rodriguez (2):
      cfg80211: Fix sanity check on 5 GHz when processing country IE
      cfg80211: print correct intersected regulatory domain

Luke Yelavich (1):
      ALSA: hda - add another MacBook Pro 4, 1 subsystem ID

Maciej Sosnowski (1):
      dca: redesign locks to fix deadlocks

Magnus Damm (1):
      gpiolib: fix request related issue

Manish Katiyar (2):
      r6040: Remove unused variable pdev from drivers/net/r6040.c
      rtc-ds1390: fix compilation warnings in drivers/rtc/rtc-ds1390.c

Manuel Lauss (1):
      MIPS: Alchemy: time.c build fix

Mark Brown (1):
      ASoC: Fix null string usage with WM8753 DAIs

Mark Eggleston (1):
      ALSA: hda - Add support of iMac 24 Aluminium

Mark Fasheh (2):
      ocfs2: add quota call to ocfs2_remove_btree_range()
      Revert "configfs: Silence lockdep on mkdir(), rmdir() and configfs_=
depend_item()"

Mark Lord (1):
      sata_mv: Fix chip type for Hightpoint RocketRaid 1740/1742

Mark McLoughlin (1):
      virtio-pci: do not oops on config change if driver not loaded

Mark Wallis (1):
      lguest: Fix a memory leak with the lg object during launcher close

Markus Metzger (1):
      x86, ds, bts: cleanup/fix DS configuration

Martin Dauskardt (1):
      V4L/DVB (10216): saa7127: fix broken S-Video with saa7129

Martin Hicks (1):
      x86: push old stack address on irqstack for unwinder

Martin K. Petersen (3):
      block: Don't verify integrity metadata on read error
      block: Remove obsolete BUG_ON
      block: Allow empty integrity profile

Martin Kebert (1):
      lis3lv02d: add axes knowledge for HP 6710

Masami Hiramatsu (2):
      kprobes: fix module compilation error with CONFIG_KPROBES=3Dn
      prevent kprobes from catching spurious page faults

Matthew Garrett (5):
      eeepc-laptop: Add support for extended hotkeys
      eeepc-laptop: Check return values from rfkill_register
      eeepc-laptop: Implement rfkill hotplugging in eeepc-laptop
      PCI hotplug: Change link order of pciehp & acpiphp
      misc: dell-laptop should depend on POWER_SUPPLY

Matthew Wilcox (1):
      PCI MSI: Fix undefined shift by 32

Matthias Dahl (1):
      V4L/DVB (9054): implement proper locking in the dvb ca en50221 driv=
er

Mauro Carvalho Chehab (6):
      V4L/DVB (10192): em28xx: fix input selection
      V4L/DVB (10201): Fixes cx88 compilation bug
      V4L/DVB (10208): zoran: Re-adds udev entry removed by changeset 60b=
4bde4
      V4L/DVB (10209): tveeprom: Properly initialize tuner type (BZ#11367=
)
      V4L/DVB (10228): em28xx: fix audio output PCM IN selection
      V4L/DVB (10403): saa7134-alsa: saa7130 doesn't support digital audi=
o

Miao Xie (1):
      cpuset: fix possible deadlock in async_rebuild_sched_domains

Michael Hennerich (9):
      Blackfin arch: Fix Bug - Kernel does not boot if re-program clocks
      Blackfin arch: Fix Bug - request lines with peripheral_request_list=
, but don't get freed with peripheral_free_list
      Blackfin arch: reset POLAR setting when acquiring a gpio for the fi=
rst time
      Blackfin arch: Faster Implementation of csum_tcpudp_nofold()
      Blackfin arch: Update CM-BF527 kernel config
      Blackfin arch: Add BF561 PPI POLS, POLC Masks
      Blackfin arch: Update Copyright information
      Blackfin arch: Fix udelay implementation
      Blackfin arch: Remove outdated code

Mike Frysinger (15):
      Blackfin arch: scrub comments/whitespace/cvs keywords
      Blackfin arch: add support for mobile ddr bf54x parts
      Blackfin arch: line up machine-/cpu- vars after BF54xM addition
      Blackfin arch: fix bug - Dmacopy failed in BF537-STAMP
      Blackfin arch: cleanup bf54x ifdef mess in gpio code
      MAINTIANERS: Blackfin: remove subscribers-only marking
      Blackfin arch: sync reboot handler with version in u-boot
      Blackfin arch: bfin_reset->_bfin_reset redirection no longer needed
      Blackfin arch: drop CONFIG_I2C_BOARDINFO ifdefs
      Blackfin arch: fixup board init function name
      Blackfin arch: read SYSCR on newer parts that mirror the bits of SW=
RST in it
      Blackfin arch: base SIC_IWR# programming on whether the MMR exists
      Blackfin arch: build jtag tty driver as a module by default
      Blackfin arch: cplb mananger: use a do...while loop rather than a f=
or loop
      Blackfin arch: define bfin_memmap as static since it is only used h=
ere

Mike Galbraith (1):
      sched: clear buddies more aggressively

Mike Isely (1):
      V4L/DVB (10240): Fix obvious swapped names in v4l2_subdev logic

Mike Rapoport (1):
      drivers/video/backlight: rename da903x to da903x_bl

Mikulas Patocka (1):
      Fix memory corruption in console selection

Misael Lopez Cruz (1):
      ASoC: OMAP: Initialize XCCR and RCCR registers in McBSP DAI driver

Myron Stowe (1):
      ACPICA: Fix table entry truncation calculation

NeilBrown (2):
      md: Allow read error in a single drive raid1 to be passed up.
      md: Ensure an md array never has too many devices.

Nicolas Fournier (1):
      V4L/DVB (10233): [PATCH] Terratec Cinergy DT XS Diversity new USB I=
D (0ccd:0081)

Nicolas Pitre (1):
      [ARM] 5366/1: fix shared memory coherency with VIVT L1 + L2 caches

Nikanth Karthikesan (1):
      Mark mandatory elevator functions in the biodoc.txt

Oleg Nesterov (2):
      Staging: android: task_get_unused_fd_flags: fix the wrong usage of =
tsk->signal
      ftrace: do_each_pid_task() needs rcu lock

Oliver Neukum (1):
      HID: fix reversed logic in disconnect testing of hiddev

Pallipadi, Venkatesh (1):
      ACPI: Enable bit 11 in _PDC to advertise hw coord

Pasi K=C3=A4rkk=C3=A4inen (1):
      [libata] sata_sil: Fix compilation error with libata debugging enab=
led

Paul Larson (1):
      Add enable_ms to jsm driver

Paul Menage (2):
      cgroups: add cpu_relax() calls in css_tryget() and cgroup_clear_css=
_refs()
      cgroup: fix root_count when mount fails due to busy subsystem

Paul Mundt (1):
      sh: Fix up spurious syscall restarting.

Pavel Herrmann (1):
      lis3lv02d: add axes knowledge for HP 6730

Pekka Enberg (1):
      Merge branches 'topic/slab/fixes' and 'topic/slub/fixes' into for-l=
inus

Peter Zijlstra (4):
      sched: fix sync wakeups
      sched: symmetric sync vs avg_overlap
      sched: fix buddie group latency
      generic swap(): don't return a value from swap()

Petr Vandrovec (1):
      firewire: core: Remove card from list of cards when enable fails

Phil Sutter (14):
      MIPS: RB532: Fix bit swapping in rb532_set_bit()
      MIPS: RC32434: Define io_map_base for PCI controller
      MIPS: RB532: Add set_type() function to IRQ struct.
      MIPS: RB532: Auto disable GPIO alternate function
      MIPS: RB532: remove useless CF GPIO initialisation
      MIPS: RB532: Detect uart type, add platform device
      MIPS: RB532: Use driver_data instead of platform_data
      MIPS: RB532: Fix init of rb532_dev3_ctl_res
      MIPS: RB532: Fix set_latch_u5()
      MIPS: RB532: Move dev3 init code to devices.c
      MIPS: RB532: Remove {get,set}_434_reg()
      MIPS: RB532: Simplify dev3 init
      MIPS: RB532: Update headers
      MIPS: RB532: Export rb532_gpio_set_func()

Philipp Zabel (1):
      regulator: move bq24022 init back to module_init instead of subsys_=
initcall

Philippe De Muyter (1):
      tulip: fix 21142 with 10Mbps without negotiation

Qinghuang Feng (3):
      Btrfs: check return value for kthread_run() correctly
      Btrfs: simplify iteration codes
      Btrfs: open_ctree() error handling can oops on fs_info

Rafael J. Wysocki (13):
      PM: Fix compilation warning in kernel/power/main.c
      ACPI suspend: Fix compilation warnings in drivers/acpi/sleep.c
      PCI PM: Fix suspend error paths and testing facility breakage
      PCI PM: Fix hibernation breakage on EeePC 701
      PCI PM: Power up devices before restoring their state
      PCI PM: Do not wait for buses in B2 or B3 during resume
      PCI PM: Fix handling of devices without drivers
      PCI PM: Check if the state has been saved before trying to restore =
it
      PCI PM: Fix saving of device state in pci_legacy_suspend
      PCI: PCIe portdrv: Simplify suspend and resume
      PCI PM: Do not disable and enable bridges during suspend-resume
      PCI PM: Read power state from device after trying to change it on r=
esume
      PCI PM: make the PM core more careful with drivers using the new PM=
 framework

Ralf Baechle (7):
      MIPS: SMTC: Fix build after recent creditial changes.
      MIPS: Avoid destructive invalidation on partial cachelines.
      MIPS: Port "mm: invoke oom-killer from page fault" from UML / x86
      MIPS: atomic_*(): Change type of intermediate variables.
      MIPS: Add return value checks to user_termio_to_kernel_termios()
      MIPS: IP27: Switch from DMA_IP27 to DMA_COHERENT
      MIPS: R2: Fix broken installation of cache error handler.

Randy Dunlap (7):
      driver-core: fix kernel-doc parameter name
      Documentation: move DMA-mapping.txt to Doc/PCI/
      libata: fix kernel-doc warnings
      sched: add missing kernel-doc in sched.h
      sunrpc: fix rdma dependencies
      maintainers: general-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org is moderated
      atyfb: fix CONFIG_ namespace violations

Reinette Chatre (2):
      iwlwifi: clean key table in iwl_clear_stations_table
      iwlwifi: save PCI state before suspend, restore after resume

Risto Suominen (1):
      fbdev/atyfb: Fix DSP config on some PowerMacs & PowerBooks

Robert Krakora (4):
      V4L/DVB (10254): em28xx: Fix audio URB transfer buffer race conditi=
on
      V4L/DVB (10256): em28xx: Fix for KWorld 330U AC97
      V4L/DVB (10257): em28xx: Fix for KWorld 330U Board
      V4L/DVB (10325): em28xx: Fix for fail to submit URB with IRQs and P=
re-emption Disabled

Robin Getz (5):
      Blackfin arch: Print out where the bootmode is coming from (for eas=
ier debugging).
      Blackfin arch: don't accidently re-enable interrupts
      Blackfin arch: Fix URL
      Blackfin arch: Add a few more instructions that can cause the trace=
 buffer to be discontiguous
      Blackfin arch: Add ability to count and display number of NMI inter=
rupts

Robin Holt (3):
      sgi-xpc: ensure flags are updated before bte_copy
      sgi-xpc: Remove NULL pointer dereference.
      sgi-xpc: fix up stale DBUG_ON statements

Roel Kluin (10):
      panasonic-laptop: fix X[ ARRAY_SIZE(X) ]
      Staging: usbip: usbip_start_threads(): handle kernel_thread failure
      Staging: poch: fix verification of memory area
      smsc911x: timeout reaches -1
      drivers/net/skfp: if !capable(CAP_NET_ADMIN): inverted logic
      leds: Fix bounds checking of wm8350->pmic.led
      ALSA: alsa: time reaches -1, tested 0
      net: variables reach -1, but 0 tested
      cassini/sungem: limit reaches -1, but 0 tested
      ALSA: pcm_oss: AFMT_S24_LE is set twice in return value

Roland Dreier (1):
      Btrfs: Remove extra KERN_INFO in the middle of a line

Roland McGrath (2):
      elf core dump: fix get_user use
      x86-64: fix int $0x80 -ENOSYS return

Ron Mercer (3):
      qlge: bugfix: Fix endian issue when reading flash.
      qlge: bugfix: Add flash offset for second port.
      qlge: bugfix: Add missing netif_napi_del call.

Russell King (4):
      [ARM] etherh: continue fixing build failure
      [ARM] msm: fix build errors
      [ARM] call undefined instruction exception handler with irqs enable=
d
      Merge branch 'omap-fixes' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/tmlind/linux-omap-2.6

Rusty Russell (3):
      cpumask: convert lib/smp_processor_id to new cpumask ops
      sched_rt: don't use first_cpu on cpumask created with cpumask_and
      module: remove over-zealous check in __module_get()

Samuel Thibault (1):
      Fix my email address in qd65xx.[ch]/pata_qdi.c

Sascha Hauer (1):
      mmc: Add a MX2/MX3 specific SDHC driver

Sebastian Andrzej Siewior (1):
      V4L/DVB (10202): [PATCH] v4l/tvp514x: Don't write after line end

Sebastiano Di Paola (1):
      net: packet socket packet_lookup_frame fix

Sebastien Dugue (1):
      hrtimers: allow the hot-unplugging of all cpus

Sergei Shtylyov (1):
      ide/libata: fix ata_id_is_cfa() (take 4)

Seth Heasley (1):
      PCI: irq and pci_ids patch for Intel Tigerpoint DeviceIDs

Shyam Iyer (1):
      net: Fix OOPS in skb_seq_read().

Sidney Amani (1):
      UBI: allow direct user-space I/O

Simon Harrison (1):
      V4L/DVB (10210): Fix a bug on v4lgrab.c

Simon Holm Th=C3=B8gersen (1):
      ext4: fix wrong use of do_div

Sonic Zhang (2):
      Blackfin arch: enable bfin_eth in bf51x by default
      Blackfin arch: Fix bug - Run "reboot" hangs bf518-ezbrd

Stanley.Miao (1):
      ARM: OMAP: Fix McBSP spin_lock deadlock

Stefan Richter (18):
      firewire: insist on successive self ID complete events
      firewire: unnecessary BM delay after generation rollover
      firewire: keep highlevel drivers attached during brief connection l=
oss
      firewire: ohci: change "context_stop: still active" log message
      firewire: ohci: increase AT req. retries, fix ack_busy_X from Panas=
onic camcorders and others
      ieee1394: ohci1394: increase AT req. retries, fix ack_busy_X from P=
anasonic camcorders and others
      firewire: core: optimize card shutdown
      ieee1394: support for speeds greater than S800
      ieee1394: sbp2: update a help string
      ieee1394: sbp2: fix payload limit at S1600 and S3200
      ieee1394: sbp2: don't assume zero model_id or firmware_revision if =
there is none
      firewire: sbp2: fix payload limit at S1600 and S3200
      firewire: sbp2: define some magic numbers as macros
      firewire: sbp2: fix DMA mapping leak on the failure path
      firewire: sbp2: add workarounds for 2nd and 3rd generation iPods
      ieee1394: sbp2: add workarounds for 2nd and 3rd generation iPods
      ieee1394: dv1394: move deprecation message from module init to file=
 open
      async: use list_move_tail

Stephen Hemminger (1):
      net: update documentation ip aliases

Stephen Rothwell (2):
      powerpc/ps3: Printing fixups for l64 to ll64 convserion drivers/net
      sparc: fixup for sparseirq changes

Steve French (4):
      [CIFS] Rename md5 functions to avoid collision with new rt modules
      [CIFS] revalidate parent inode when rmdir done within that director=
y
      [CIFS] some cleanup to dir.c prior to addition of posix_open
      [CIFS] Make socket retry timeouts consistent between blocking and n=
onblocking cases

Steve Glendinning (1):
      smsc9420: fix interrupt signalling test failures

Steve Hodgson (6):
      sfc: SFT9001: Enable robust link training
      sfc: SFX7101: Remove workaround for bad link training
      sfc: SFT9001: Fix speed reporting in 1G PHY loopback
      sfc: Fix post-reset MAC selection
      sfc: Reinitialise the PHY completely in case of a PHY or NIC reset
      sfc: Test for PHYXS faults whenever we cannot test link state bits

Steven Rostedt (6):
      ring-buffer: fix alignment problem
      trace: print ftrace_dump at KERN_EMERG log level
      trace: stop all recording to ring buffer on ftrace_dump
      trace: set max latency variable to zero on default
      ring-buffer: reset timestamps when ring buffer is reset
      generic-ipi: use per cpu data for single cpu ipi calls

Stuart Menefy (1):
      sh: Handle calling csum_partial with misaligned data

Sunil Mushran (1):
      ocfs2: Wakeup the downconvert thread after a successful cancel conv=
ert

Takashi Iwai (14):
      ALSA: hda - Fix PCM reference NID for STAC/IDT analog outputs
      ALSA: hda - Fix compile warning with CONFIG_SND_JACK=3Dn
      Merge branch 'fix/asoc' into for-linus
      Merge branch 'fix/hda' into for-linus
      ALSA: hda - Add quirk for another HP dv5 model
      ALSA: hda - No widget selection for volume knob widgets in proc out=
put
      Merge branch 'fix/hda' into for-linus
      Merge branch 'fix/asoc' into for-linus
      ALSA: hda - Add quirk for FSC Amilo Xi2550
      ALSA: hda - Fix misc workqueue issues
      ALSA: hda - Add missing initialization for ALC272
      ALSA: hda - Add missing COEF initialization for ALC887
      Merge branch 'fix/hda' into for-linus
      Merge branch 'fix/usb-audio' into for-linus

Takashi Yoshii (1):
      sh: Fix up T-bit error handling in SH-4A mutex fastpath.

Tao Ma (1):
      ocfs2: Access the xattr bucket only before modifying it.

Teemu Likonen (1):
      Documentation: update CodingStyle tips for Emacs users

Tejun Heo (9):
      sata_nv: ck804 has borked hardreset too
      libata: fix EH device failure handling
      libata: move ata_dev_disable() to libata-eh.c
      libata: check onlineness before using SPD in sata_down_spd_limit()
      libata: clear dev->ering in smarter way
      libata: add @spd_limit to sata_down_spd_limit()
      libata: improve probe failure handling
      libata: add no penalty retry request for EH device handling routine=
s
      libata: implement HORKAGE_1_5_GBPS and apply it to WD My Book

Tero Roponen (1):
      ACPI: Fix crash on ASUS laptops

Thadeu Lima de Souza Cascardo (1):
      ext4: Fix building with EXT4FS_DEBUG

Theodore Ts'o (8):
      ext4: only use i_size_high for regular files
      ext4: Add sanity check to make_indexed_dir
      ext3: Add sanity check to make_indexed_dir
      jbd2: On a __journal_expect() assertion failure printk "JBD2", not =
"EXT3-fs"
      ext4: Fix ext4_free_blocks() w/o a journal when files have indirect=
 blocks
      ext4: Initialize the new group descriptor when resizing the filesys=
tem
      ext4: Remove bogus BUG() check in ext4_bmap()
      block: Fix documentation for blkdev_issue_flush()

Thierry Vignaud (1):
      ACPI: Kconfig text - Fix the ACPI_CONTAINER module name according t=
o the real module name.

Thomas Gleixner (1):
      hrtimer: prevent negative expiry value after clock_was_set()

Thomas Goff (1):
      IPv6: Fix multicast routing bugs.

Thomas Renninger (1):
      ACPI: cpufreq: Remove deprecated /proc/acpi/processor/../performanc=
e proc entries

Tim 'mithro' Ansell (1):
      lguest: disable the FORTIFY for lguest.

Timothy S. Nelson (1):
      PCI: return error on failure to read PCI ROMs

Tony Battersby (1):
      shm: fix shmctl(SHM_INFO) lockup with !CONFIG_SHMEM

Tony Broad (1):
      V4L/DVB (10265): budget.c driver: Kernel oops: "BUG: unable to hand=
le kernel paging request at ffffffff

Tony Lindgren (2):
      ARM: OMAP: Fix omap34xx revision detection for ES3.1
      ARM: OMAP: Fix hsmmc init, v2

Trent Piepho (6):
      V4L/DVB (10212): Convert to be a pci driver
      V4L/DVB (10222): zoran: Better syntax for initializing array module=
 params
      V4L/DVB (10223): zoran: Remove global device array
      V4L/DVB (10224): zoran: Use pci device table to get card type
      V4L/DVB (10225): zoran: Remove zr36057_adr field
      V4L/DVB (10226): zoran: Get rid of extra module ref count

Tsugikazu Shibata (1):
      Sync patch for jp_JP/stable_kernel_rules.txt

Tyler Hicks (1):
      eCryptfs: Regression in unencrypted filename symlinks

Uwe Kleine-Koenig (1):
      Blackfin arch: explicit add a might sleep to gpio_free

Uwe Kleine-K=C3=B6nig (6):
      Use __SPIN_LOCK_UNLOCKED to initialize bad_irq_desc.lock
      annotate that [fp, #-4] is the saved lr
      rename platform_driver name "flash" to "sa1100-mtd"
      NVRAM depends on RTC_DRV_CMOS
      add another mailmap entry for Uwe Kleine-K=C3=B6nig
      Add Sascha Hauer to .mailmap

Wang Cong (1):
      Btrfs: cleanup fs/btrfs/super.c::btrfs_control_ioctl()

Yan Zheng (4):
      Btrfs: fix locking issue in btrfs_remove_block_group
      Btrfs: Fix infinite loop in btrfs_extent_post_op
      Btrfs: fix stop searching test in replace_one_extent
      Btrfs: fix tree logs parallel sync

Yehuda Sadeh (1):
      Btrfs: fiemap support

Yinghai Lu (1):
      irq, x86: fix lock status with numa_migrate_irq_desc

Yusuf Altin (1):
      V4L/DVB (10195): [PATCH] add Terratec Cinergy T Express to dibcom d=
river

Zhao Yakui (2):
      ACPI: Skip the first two elements in the _BCL package
      ACPI: proc_dir_entry 'video/VGA' already registered

Zhu, Yi (1):
      iwlwifi: fix kernel oops when ucode DMA memory allocation failure

philipl-tB29R6EoPa3YtjvyW6yDsg@public.gmane.org (1):
      ricoh_mmc: Use suspend_late/resume_early

=EA=B9=80=EA=B7=9C=EC=9B=90 (1):
      ARM: OMAP: Mask interrupts when disabling interrupts, v2

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr

--===============2994278068885041656==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============2994278068885041656==--
