From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr annotated tag, v2.6.31-rc3, created. v2.6.31-rc3
Date: Wed, 16 Sep 2009 14:36:56 -0400
Message-ID: <200909161836.n8GIau5Q001615@gorgona.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7154814501442414722=="
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

--===============7154814501442414722==
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by smtp1.linux-foundation.org id n8GJSYmN009053

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The annotated tag, v2.6.31-rc3 has been created
        at  c361304f4a17c05992b1cf68172a5ea8389649ee (tag)
   tagging  6847e154e3cd74fca6084124c097980a7634285a (commit)
  replaces  v2.6.31-rc2
 tagged by  Linus Torvalds
        on  Mon Jul 13 18:19:13 2009 -0700

- Log -----------------------------------------------------------------
Linux 2.6.31-rc3
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkpb3RUACgkQF3YsRnbiHLtidgCeIeSRVhH8I2ltGOZ1eKcydkUj
3HAAoJgrSwiVp+KZ3bR3M04XpCXh7YqU
=3Dh74p
-----END PGP SIGNATURE-----

Abhishek Kulkarni (1):
      net/9p: Fix crash due to bad mount parameters.

Adrian Hunter (4):
      UBIFS: fix integer overflow warning
      UBIFS: fix 64-bit divisions in debug print
      UBIFS: minor spelling and grammar fixes
      UBI: add image sequence number to EC header

Ajay Kumar Gupta (1):
      USB: otg: fix module reinsert issue

Akinobu Mita (1):
      x86: fix usage of bios intcall()

Alan Cox (7):
      PCI: More PATA quirks for not entering D3
      pty: Rework the pty layer to use the normal buffering logic
      tty: maintainers data was edited wrongly by someone
      tty: Sort out the USB sysrq changes that wrecked performance
      tty: Fix USB kref leak
      tty: Fix the PL2303 private methods for sysrq
      Staging: vt6655: compile fix

Alan Stern (9):
      USB: EHCI: update toggle state for linked QHs
      USB: fix the clear_tt_buffer interface
      USB: EHCI: use the new clear_tt_buffer interface
      USB: EHCI: check for STALL before other errors
      USB: Sierra: fix oops upon device close
      USB: cypress_m8: remove invalid Clear-Halt
      USB: option: remove unnecessary and erroneous code
      USB: EHCI: report actual_length for iso transfers
      USB: handle zero-length usbfs submissions correctly

Alexander Beregalov (3):
      wm97xx_batery: replace driver_data with dev_get_drvdata()
      Staging: comedi: jr3_pci.c: add required includes
      Staging: stlc45xx: convert config_interface to bss_info_changed, fi=
xing a build error

Alexander Duyck (2):
      if_ether: add define for 1588 aka Timesync
      igb: set lan id prior to configuring phy

Alexey Dobriyan (2):
      headers: mnt_namespace.h redux
      headers: smp_lock.h redux

Alexey Zaytsev (1):
      PCI: make pci_name() take const argument

Alistair John Strachan (1):
      hwmon: (abituguru3) DMI probing for AB9, AB9 QuadQT and IX38 QuadGT

Amerigo Wang (2):
      Doc: update Documentation/exception.txt
      Doc: move Documentation/exception.txt into x86 subdir

Amit Kucheria (1):
      USB: Serial: Add support for Arkham Technology adapters

Andiry Brienza (1):
      ALSA: hda - Disable AMD SB600 64bit address support only

Andrey Yurovsky (1):
      mac80211: fix allocation in mesh_queue_preq

Andy Walls (5):
      V4L/DVB (12167): tuner-xc2028: Fix 7 MHz DVB-T
      V4L/DVB (12180): cx18: Update Yuan MPC-718 card entry with better i=
nformation and guesses
      V4L/DVB (12181): get_dvb_firmware: Add Yuan MPC718 MT352 DVB-T "fir=
mware" extraction
      V4L/DVB (12182): cx18: Add DVB-T support for Yuan MPC-718 cards wit=
h an MT352 or ZL10353
      V4L/DVB (12206): get_dvb_firmware: Correct errors in MPC718 firmwar=
e extraction logic

Andy Whitcroft (1):
      drm/i915: fix up a raw 64bit divide

Aneesh Kumar K.V (5):
      ext4: Calculate required journal credits for inserting an extent pr=
operly
      ext4: Don't look at buffer_heads outside i_size.
      ext4: Fix mmap/truncate race when blocksize < pagesize && delayed a=
llocation
      ext4: Fix mmap/truncate race when blocksize < pagesize && !nodellao=
c
      ext4: Move __ext4_journalled_writepage() to avoid forward declarati=
on

Anssi Hannula (1):
      USB: option.c: add A-Link 3GU device id

Anton Blanchard (7):
      perf report: Fix -z option
      perf_counter tools: Remove zlib dependency
      perf top: Move skip symbols to an array
      perf top: Add ppc64 specific skip symbols and strip ppc64 . prefix
      perf report: Fix reporting of hypervisor
      perf report: Add hypervisor dso
      powerpc/perf_counter: Enable alternate PR/HV bits for POWER7

Anton Vorontsov (2):
      powerpc: Don't use alloc_bootmem() in init_IRQ() path
      netpoll: Fix carrier detection for drivers that are using phylib

Arnaldo Carvalho de Melo (3):
      perf_counter tools: Share rbtree.with the kernel
      perf_counter tools: Share list.h with the kernel
      perf_counter tools: Adjust symbols in ET_EXEC files too

Arnd Bergmann (5):
      microblaze: fall back on generic header files for the ABI
      microblaze: clean up signal handling
      microblaze: use generic syscalls.h
      signals: declare sys_rt_tgsigqueueinfo in syscalls.h
      USB: buildfix ppc randconfig

Arseniy Lartsev (1):
      USB: cdc-acm: work around some broken devices

Artem Bityutskiy (16):
      UBIFS: improve debugging messaged
      UBIFS: slightly optimize write-buffer timer usage
      UBIFS: set write-buffer timout to 3-5 seconds
      UBIFS: few spelling fixes
      UBIFS: fix assertion warning
      MAINTAINERS: update ahunter's e-mail address
      UBI: add empty eraseblocks verification
      UBI: remove bogus debugging checks
      UBI: nicify image sequence number handling
      UBI: fix NOR flash recovery
      UBI: fix compilation warnings
      UBIFS: dump a little more in case of corruptions
      UBIFS: small amendments in the LEB scanning code
      UBIFS: clean up free space checking
      UBIFS: fix corruption dump
      AFS: Fix compilation warning

Bartlomiej Zolnierkiewicz (2):
      isofs: fix Joliet regression
      Staging: rtl8192su: convert to net_device_ops

Ben Gamari (3):
      drm/i915: Remove gtt_bound from drm_i915_gem_object
      drm/i915: Add gtt_offset to gem object list debugfs output
      drm/i915: Move lock to more reasonable location

Benjamin Herrenschmidt (2):
      Merge commit 'jwb/merge' into merge
      devres: WARN() and return, don't crash on device_del() of uninitial=
ized device

Bill Pemberton (2):
      Staging: serqt_usb2: fix qt_close parameters in serqt_usb2
      Staging: serqt_usb2: declare qt_open static in serqt_usb2

Boaz Harrosh (5):
      exofs: Fix bio leak in error handling path (sync read)
      exofs: Remove IBM copyrights
      exofs: Avoid using file_fsync()
      MAINTAINERS: Add osd maintained files (F:)
      osdblk: Adjust queue limits to lower device's limits

Brad Lu (1):
      USB: option.c to support Qisda H21/H20 usb modem

Brian Haley (1):
      IPv6: preferred lifetime of address not getting updated

Bruce Allan (6):
      e1000e: PHY loopback broken on 82578
      e1000e: delay after LCD reset and proper checks for PHY configurati=
on done
      e1000e: do not write SmartSpeed register bits on parts without supp=
ort
      e1000e: prevent NVM corruption on sectors larger than 4K
      e1000e: delay second read of PHY_STATUS register on failure of firs=
t read
      e1000e: disable K1 at 1000Mbps for 82577/82578

Catalin Marinas (11):
      kmemleak: Renice the scanning thread to +10
      kmemleak: Add more cond_resched() calls in the scanning thread
      kmemleak: Remove the reported leaks number limitation
      kmemleak: Do not acquire scan_mutex in kmemleak_open()
      kmemleak: Scan objects allocated during a scanning episode
      kmemleak: Trace the kmalloc_large* functions in slub
      kmemleak: Allow partial freeing of memory blocks
      kmemleak: Add callbacks to the bootmem allocator
      Free the memory allocated by memdup_user() in fs/sysfs/bin.c
      Free struct device in fw_dev_release()
      kmemleak: Remove alloc_bootmem annotations introduced in the past

Chris Wilson (1):
      drm/i915: Refactor calls to unmap_mapping_range

Christian Borntraeger (1):
      [S390] improve suspend/resume error messages

Clyde McPherson (2):
      b43: Add support for 4318E
      ssb: Add support for 4318E

Curt Wohlgemuth (1):
      ext4: Fix buffer head reference leak in no-journal mode

Dan Aloni (2):
      Staging: prevent rtl8187se from crashing dev_ioctl() in SIOCGIWNAME
      Staging: prevent rtl8192su from crashing dev_ioctl in SIOCGIWNAME

Dan Williams (1):
      USB: option: add Novatel Ovation MC760

Daniel Mack (2):
      UBIFS: allow more than one volume to be mounted
      USB: fix LANGID=3D0 regression

Darren Salt (1):
      ALSA: hda - Missing volume controls for Intel HDA (ALC269/EeePC)

Dave Jones (2):
      [CPUFREQ] Fix compile failure in cpufreq.c
      Fix compile error in bmac.c

Dave Kleikamp (1):
      update JFS entry in MAINTAINERS

David Brownell (5):
      Input: dm355evm_keys - fix kconfig symbol names
      USB: musb: davinci dm355 updates (remainder)
      USB: gadget: pxa25x compiler warning fix
      USB: musb: silence "suspend as a_wait_vrise is_active" msgs
      USB: RNDIS gadget, fix issues talking from PXA

David Heidelberger (1):
      ALSA: hda - targa and targa-2ch fix

David S. Miller (3):
      Revert "ide: improve handling of Power Management requests"
      Revert "p54: Use SKB list handling helpers instead of by-hand code.=
"
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-2.6

David Woodhouse (8):
      intel-iommu: Fix dma vs. mm page confusion with aligned_nrpages()
      intel-iommu: Don't set identity mapping for bypassed graphics devic=
es
      intel-iommu: Fix reattaching of devices to identity mapping domain
      intel-iommu: Add iommu_should_identity_map() function
      intel-iommu: Restore DMAR_BROKEN_GFX_WA option for broken graphics =
drivers
      intel-iommu: No mapping for non-PCI devices
      intel-iommu: Use iommu_should_identity_map() at startup time too.
      intel-iommu: Don't use identity mapping for PCI devices behind brid=
ges

Devin Heitmueller (1):
      V4L/DVB (12156): em28xx: Fix tuning for Terratec Cinergy T XS USB (=
zl10353 version)

Dhananjay Phadke (2):
      netxen: fix the version code macro
      netxen: avoid frequent firmware reset

Dmitry Torokhov (1):
      Input: arrange keyboards alphabetically

Don Skidmore (3):
      ixgbe: fix issues with failing to detect insert of unsupported modu=
le
      ixgbe: fix regression on some 82598 adapters
      ixgbe: fix inconsistent SFP/SFP+ failure results.

Eilon Greenstein (2):
      bnx2x: Disable HC coalescing when setting timeout to zero.
      bnx2x: Fix the maximal values of coalescing timeouts.

Elina Pasheva (1):
      USB: serial: sierra driver id_table additions

Eric Anholt (3):
      drm/i915: Disable GEM when a broken video BIOS takes up the whole a=
perture.
      drm/i915: Fix harmless warning from patch merged after i2c rework.
      drm/i915: Zap the GTT mapping when transitioning from untiled to ti=
led.

Eric Dumazet (6):
      x86: atomic64: The atomic64_t data type should be 8 bytes aligned o=
n 32-bit too
      x86: atomic64: Improve atomic64_read()
      x86: atomic64: Improve cmpxchg8b()
      x86: atomic64: Improve atomic64_read()
      x86: atomic64: Inline atomic64_read() again
      forcedeth: Fix NAPI race.

Eric Miao (1):
      Input: add support for generic GPIO-based matrix keypad

Eric Sandeen (2):
      ext4: mark several more functions in mballoc.c as noinline
      ext4: naturally align struct ext4_allocation_request

FUJITA Tomonori (2):
      block: call blk_scsi_ioctl_init()
      block: fix sg SG_DXFER_TO_FROM_DEV regression

Fernando Luis V=C3=A1zquez Cao (1):
      PCI: remove pci_dac_dma_... APIs on mn10300

Florian Fainelli (3):
      vlynq: fix typo in Kconfig to enable debugging
      r6040: restore MIER register correctly when IRQ line is shared
      r6040: bump driver version to 0.24 and date to 08 July 2009

Folkert van Heusden (1):
      USB: serial: FTDI with product code FB80 and vendor id 0403

Frank Munzert (1):
      [S390] shutdown actions: save/return rc from init function

Frans Pop (1):
      USB: add missing class descriptions used in usb/devices file

Frederic Weisbecker (16):
      perf_counter tools: Fix storage size allocation of callchain list
      perf_counter tools: Resolve symbols in callchains
      perf_counter tools: Various fixes for callchains
      perf_counter: Ignore the nmi call frames in the x86-64 backtraces
      perf stat: Handle pipe read failures in perf stat
      perf_counter tools: Create new chain_for_each_child() iterator
      perf_counter tools: Add new OPT_CALLBACK_DEFAULT option
      perf report: Add support for callchain graph output
      perf_counter tools: Set the minimum percent for callchains to be di=
splayed
      perf_counter tools: Provide helper to print percents color
      perf_counter tools: Display percents of hits in callchain with over=
head colors
      perf report: Warn on callchain output request from non-callchain fi=
le
      perf report: Use a modifiable string for default callchain options
      perf report: Change default callchain parameters
      perf_counter tools: callchains: Manage the cumul hits on the fly
      perf report: Add "Fractal" mode output - support callchains with re=
lative overhead rate

Gianpaolo Cugola (1):
      USB: pl2303: New vendor and product id for the prolific driver

Grant Likely (3):
      ASoC: Fix mpc5200-psc-ac97 to ensure the data ready bit is cleared
      ASoC: add locking to mpc5200-psc-ac97 driver
      powerpc: Fix spin_event_timeout() to be robust over context switche=
s

Greg Kroah-Hartman (7):
      Sound: remove direct access of driver_data
      omap: video: remove direct access of driver_data
      Staging: meilhaus: add email address to TODO
      Revert "USB: Add Intel Langwell USB OTG Transceiver Drive"
      USB: gadget: audio: provide correct device id
      USB: ti_usb_3410_5052: fix duplicate device ids.
      Revert USB: usbfs: deprecate and hide option for !embedded

Greg Ungerer (2):
      fec: remove extra ";" from definition names
      fec: fix definition of 5272 version of FEC_X_DES_ACTIVE register

Guennadi Liakhovetski (1):
      V4L/DVB (12160): soc-camera: fix missing clean up on error path

Hans Verkuil (1):
      V4L/DVB (12153): ttpci: config TTPCI_EEPROM depends on I2C

Heiko Carstens (7):
      [S390] sclp: fix compile error for !SCLP_CONSOLE
      [S390] monreader: fix dev_set_drvdata conversion
      [S390] udelay: disable lockdep to avoid false positives
      [S390] perf_counter build fix
      [S390] add __ucmpdi2() helper function
      [S390] add generic atomic64 support for 31 bit
      partitions: fix broken uevent_suppress conversion

Herbert Xu (1):
      tun: Fix device unregister race

Herton Ronaldo Krzesinski (2):
      ALSA: hda - move 8086:fb30 quirk (stac9205) to the proper section
      Staging: comedi: s626: use subvendor:subdevice ids for SAA7146 boar=
d

Hidetoshi Seto (4):
      PCI MSI: Return if alloc_msi_entry for MSI-X failed
      PCI MSI: shorten PCI_MSIX_ENTRY_* symbol names
      PCI MSI: Unmask MSI if setup failed
      PCI MSI: Fix restoration of MSI/MSI-X mask states in suspend/resume

Hin-Tak Leung (1):
      zd1211rw: adding SONY IFU-WLM2 (054c:0257) as a zd1211b device

Huang Weiyi (2):
      powerpc/perf_counter: Remove duplicated #include
      mn10300: remove duplicated #include

Hui Zhu (1):
      elf: fix multithreaded program core dumping on arm

InKi Dae (1):
      drivers/video/s3c-fb.c: fix clock setting for Samsung SoC Framebuff=
er

Ingo Molnar (18):
      dma-debug: Put all hash-chain locks into the same lock class
      ia64/PCI: adjust section annotation for pcibios_setup()
      Merge branch 'linus' into perfcounters/urgent
      perf report: Fix HV bit mismerge
      perf_counter tools: Add more warnings and fix/annotate them
      x86: Fix printk call in print_local_apic()
      Merge branch 'dma-debug/fixes' of git://git.kernel.org/pub/scm/linu=
x/kernel/git/joro/linux-2.6-iommu into core/urgent
      perf report: Annotate variable initialization
      x86: atomic64: Move the 32-bit atomic64_t implementation to a .c fi=
le
      x86: atomic64: Improve atomic64_add_return()
      x86: atomic64: Reduce size of functions
      x86: atomic64: Make atomic_read() type-safe
      x86: atomic64: Fix unclean type use in atomic64_xchg()
      Merge branch 'amd-iommu/fixes' of git://git.kernel.org/pub/scm/linu=
x/kernel/git/joro/linux-2.6-iommu into x86/urgent
      x86: atomic64: Export APIs to modules
      x86: atomic64: Improve atomic64_xchg()
      x86: atomic64: Clean up atomic64_sub_and_test() and atomic64_add_ne=
gative()
      dma-debug: Fix the overlap() function to be correct and readable

Jan Beulich (1):
      x86: Fix fixmap ordering

Jan Capek (1):
      USB: ftdi_sio - product ID's for CCS PIC programmers

Jan Kara (2):
      jbd2: Fix a race between checkpointing code and journal_get_write_a=
ccess()
      ext4: Fix truncation of symlinks after failed write

Jani Nikula (2):
      Input: gpio-keys - revert 'change timer to workqueue'
      Input: gpio-keys - avoid possibility of sleeping in timer function

Jarek Poplawski (1):
      ipv4: Fix fib_trie rebalancing, part 4 (root thresholds)

Jason Wessel (1):
      USB: console: Fix regression in usb console on kernel boot

Jaswinder Singh Rajput (8):
      perf stat: Define MATCH_EVENT for easy attr checking
      x86: Remove double declaration of MSR_P6_EVNTSEL0 and MSR_P6_EVNTSE=
L1
      perf list: Add cache events
      x86: Mark device_nb as static and fix NULL noise
      x86: Declare check_efer() before it gets used
      x86: Remove unused variable disable_x2apic
      x86: Remove unused function lapic_watchdog_ok()
      includecheck fix: include/linux, rfkill.h

Jay Sternberg (1):
      Atheros Kconfig needs to be dependent on WLAN_80211

Jean Delvare (1):
      Fix staging drivers after smp_lock.h redux

Jeff Garzik (1):
      osdblk: a Linux block device for OSD objects

Jeff Layton (9):
      cifs: add new cifs_iget function and convert unix codepath to use i=
t
      cifs: fix regression with O_EXCL creates and optimize away lookup
      cifs: add pid of initiating process to spnego upcall info
      cifs: rename CIFSSMBUnixSetInfo to CIFSSMBUnixSetPathInfo
      cifs: make a separate function for filling out FILE_UNIX_BASIC_INFO
      cifs: add and use CIFSSMBUnixSetFileInfo for setattr calls
      cifs: convert cifs_get_inode_info and non-posix readdir to use cifs=
_iget
      cifs: remove cifsInodeInfo->inUse counter
      cifs: when ATTR_READONLY is set, only clear write bits on non-direc=
tories

Jens Axboe (1):
      Fix congestion_wait() sync/async vs read/write confusion

Jesper Dangaard Brouer (1):
      ext4: Use rcu_barrier() on module unload.

Jesse Barnes (1):
      drm/i915: enable error detection & state collection

Jiaying Zhang (1):
      quota: Fix possible deadlock during parallel quotaon and quotaoff

Jiri Olsa (2):
      net: adding memory barrier to the poll and receive callbacks
      memory barrier: adding smp_mb__after_lock

Jiri Slaby (7):
      V4L/DVB (12202): em28xx, fix lock imbalance
      V4L/DVB (12203): radio-si470x: fix lock imbalance
      rtc: ds1374, fix lock imbalance
      Wireless: nl80211, fix lock imbalance
      [WATCHDOG] w83697ug, fix lock imbalance
      hwmon: (max6650) Fix lock imbalance
      Firmware: firmware_class, fix lock imbalance

Jiro SEKIBA (1):
      nilfs2: fix disorder in cp count on error during deleting checkpoin=
ts

Joe Perches (5):
      PCI ECRC: Remove unnecessary semicolons
      powerpc: Remove unnecessary semicolons
      Remove multiple KERN_ prefixes from printk formats
      [WATCHDOG] drivers/watchdog/bcm47xx_wdt.c: Remove unnecessary semic=
olons
      hwmon: (sht15) Remove unnecessary semicolon

Joerg Roedel (3):
      dma-debug: fix off-by-one error in overlap function
      amd-iommu: handle alias entries correctly in init code
      amd-iommu: set evt_buf_size correctly

Johann Lombardi (1):
      ext4: Fix goal inum check in the inode allocator

Johannes Berg (4):
      hp-wmi: fix rfkill bug
      cfg80211: fix refcount leak
      mac80211_hwsim: avoid NULL access
      mac80211: fix docbook

Jonathan McDowell (1):
      USB: Fix option_ms regression in 2.6.31-rc2

Jorrit Schippers (1):
      Staging: rt2870: Add USB ID for Sitecom WL-608

Josef Bacik (1):
      mm: mark page accessed before we write_end()

Josh Boyer (1):
      powerpc/44x: Fix build error with -Werror for Warp platform

Julia Lawall (1):
      drivers/net/smsc911x.c: Fix resource size off by 1 error

Julien Tinnes (1):
      personality: fix PER_CLEAR_ON_SETID

Kai Engert (1):
      USB: option.c: add Qualcomm/Option iCON 210 modem

Kay Sievers (2):
      sparc: remove driver-core BUS_ID_SIZE
      Driver Core: remove BUS_ID_SIZE

Keith Packard (2):
      drm/i915: Make driver less chatty
      drm/i915: Adjust DisplayPort clocks to use 96MHz reference

Ken Kawasaki (1):
      pcnet_cs: add new id

Kevin Cernekee (1):
      Fix virt_to_phys() warnings

Kevin Hilman (1):
      USB: musb: davinci dm6446evm GPIO renumbering

Krzysztof Halasa (1):
      USB serial: Add ID for Turtelizer, an FT2232L-based JTAG/RS-232 ada=
pter.

Krzysztof Helt (10):
      sisfb: fix regression with uninitalized fb_info->mm_lock mutex
      i810fb: fix regression with uninitalized fb_info->mm_lock mutex
      atafb: fix regression with uninitalized fb_info->mm_lock mutex
      w100fb: fix regression with uninitalized fb_info->mm_lock mutex
      matroxfb: fix regression with uninitalized fb_info->mm_lock mutex
      matroxfb: fix regression with uninitalized fb_info->mm_lock mutex (=
second head)
      fsl-diu-fb: fix regression with uninitalized fb_info->mm_lock mutex
      atmel_lcdfb: fix regression with uninitalized fb_info->mm_lock mute=
x
      sm501fb: fix regression with uninitalized fb_info->mm_lock mutex
      mx3fb: fix regression with uninitalized fb_info->mm_lock mutex

Lai Jiangshan (1):
      trace_export: Repair missed fields

Larry Finger (3):
      b43/b43legacy: fix radio LED initialization
      p54: tx refused but queue active
      fuse: Fix build error

Lars-Peter Clausen (1):
      ASoC: Fix wm8753 register cache size and initialization

Li Zefan (2):
      tracing: Fix stack tracer sysctl handling
      tracing/fastboot: Document the need of initcall_debug

Linus Torvalds (41):
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/ieee1394/linux1394-2.6
      Merge git://git.infradead.org/iommu-2.6
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/mchehab/linux-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/penberg/slab-2.6
      Merge branch 'fixes-for-linus' of git://git.monstr.eu/linux-2.6-mic=
roblaze
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jbarnes/pci-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/ide-2.6
      Merge master.kernel.org:/home/rmk/linux-2.6-arm
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Revert "fb: Initialize fb_info mutexes in framebuffer_alloc()"
      Merge branch 'sh/for-2.6.31' of git://git.kernel.org/pub/scm/linux/=
kernel/git/lethal/sh-2.6
      Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/benh/powerpc
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/dtor/input
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/rafael/suspend-2.6
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jack/linux-quota-2.6
      Merge branch 'fixes' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/davej/cpufreq
      Merge branch 'fixes' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/davej/cpufreq
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/sfrench/cifs-2.=
6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/wim/linux-2.6-w=
atchdog
      Merge branch 'tracing-fixes-for-linus' of git://git.kernel.org/pub/=
scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'perfcounters-fixes-for-linus' of git://git.kernel.org=
/pub/scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'core-fixes-for-linus-2' of git://git.kernel.org/pub/s=
cm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/ryusuke/nilfs2
      Merge branch 'for-linus' of git://git.kernel.dk/linux-2.6-block
      Merge branch 'drm-intel-next' of git://git.kernel.org/pub/scm/linux=
/kernel/git/anholt/drm-intel
      Merge branch 'for-linus' of git://git.open-osd.org/linux-open-osd
      Merge branch 'for-linus' of git://git390.marist.edu/pub/scm/linux-2=
.6
      Merge branch 'linux-next' of git://git.infradead.org/ubifs-2.6
      Merge branch 'linux-next' of git://git.infradead.org/ubi-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Revert "fuse: Fix build error" as unnecessary
      Merge branch 'hwmon-for-linus' of git://git.kernel.org/pub/scm/linu=
x/kernel/git/jdelvare/staging
      Don't use '-fwrapv' compiler option: it's buggy in gcc-4.1.x
      Merge branch 'kmemleak' of git://linux-arm.org/linux-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/usb-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-c=
ore-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging-=
2.6
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tytso/ext4
      Linux 2.6.31-rc3

Linus Walleij (2):
      [ARM] 5579/1: Updated U300 defconfig
      [ARM] 5581/1: U300 clock updates

Luciano Coelho (1):
      mac80211: minstrel: avoid accessing negative indices in rix_to_ndx(=
)

Magnus Damm (3):
      sh-sci: update receive error handling for muxed irqs
      usb: allow sh7724 to enable on-chip r8a66597
      sh: add r8a66597 usb0 host to the se7724 board

Mallikarjuna R Chilakala (1):
      ixgbe: Not allow 8259x unsupported wol options change from ethtool

Mariusz Kozlowski (1):
      tun/tap: Fix crashes if open() /dev/net/tun and then poll() it.

Mark Brown (1):
      ASoC: Fix register cache initialisation for WM8753

Mark Langsdorf (1):
      [CPUFREQ] Powernow-k8: support family 0xf with 2 low p-states

Martin Geleynse (1):
      USB: ftdi: support NDI devices

Martin Schwidefsky (2):
      [S390] set SCHED_OMIT_FRAME_POINTER for s390
      [S390] define KTIME_SCALAR for 32-bit s390

Masami Hiramatsu (1):
      kprobes: No need to unlock kprobe_insn_mutex

Mathieu Desnoyers (2):
      x86: Fix fixmap page order for FIX_TEXT_POKE0,1
      [CPUFREQ] fix (utter) cpufreq_add_dev mess

Matthew Wilcox (1):
      PCI: Fix IRQ swizzling for ARI-enabled devices

Matthias Kaehlcke (1):
      [ARM] 5576/1: Update kb9202_defconfig

Mauro Carvalho Chehab (12):
      V4L/DVB (12134): vivi: bug: don't assume that S_STD will be called =
before streaming
      V4L/DVB (12148): move V4L2_PIX_FMT_SGRBG8 to the proper place
      V4L/DVB (12135): Add a driver for mt9v011 sensor
      V4L/DVB (12136): mt9v011: Some fixes at the register initialization=
 table
      V4L/DVB (12137): mt9v011: CodingStyle fixes
      V4L/DVB (12173): mt9v011: properly calculate image resolution regis=
ters
      V4L/DVB (12174): mt9v011: let's stick with datasheet values where i=
t works
      V4L/DVB (12138): em28xx: add support for Silvercrest Webcam
      V4L/DVB (12139): em28xx: add other video formats
      V4L/DVB (12169): em28xx-video: fix VIDIOC_G_FMT and VIDIOC_ENUMFMT =
with webcams
      V4L/DVB (12171): em28xx: fix webcam usage with different output for=
mats
      V4L/DVB (12172): em28xx: Add autodetection code for Silvercrest 1.3=
 mpix

Maynard Johnson (1):
      oprofile: reset bt_lost_no_mapping with other stats

Michael Ellerman (7):
      powerpc/pseries: Use pr_devel() in pseries LPAR HPTE routines
      powerpc/pseries: Use pr_devel() in xics.c
      powerpc: Use pr_devel() in arch/powerpc/mm/mmu_context_nohash.c
      powerpc: Cleanup & use pr_devel() in arch/powerpc/mm/slb.c
      powerpc: Use pr_devel() in arch/powerpc/mm/gup.c
      powerpc/cell: Use pr_devel() in axon_msi.c
      powerpc: Use pr_devel() in do_dcache_icache_coherency()

Michael Krufky (2):
      V4L/DVB (12165): cx23885: override set_frontend to allow rf input p=
ath switching on the HVR1275
      V4L/DVB (12166): cx23885: add FIXME comment above set_frontend over=
ride

Michal Simek (2):
      microblaze: Wire up new syscalls
      microblaze: Fix cast warning for init.c

Mike Frysinger (1):
      USB: isp1760: use __devexit_p() for remove function

Mike Galbraith (6):
      x86: Fix symbol annotation for arch/x86/lib/clear_page_64.S::clear_=
page_c
      perf_counter tools: Make symbol loading consistently return number =
of loaded symbols
      perf_counter tools: Add infrastructure to support loading of kernel=
 module symbols
      perf_counter tools: Connect module support infrastructure to symbol=
 loading infrastructure
      perf_counter tools: Enable kernel module symbol loading in tools
      x86: Add missing annotation to arch/x86/lib/copy_user_64.S::copy_to=
_user

Oleg Nesterov (1):
      cred_guard_mutex: do not return -EINTR to user-space

Oliver Neukum (4):
      USB: fix memory leak in usbtmc
      USB: fix uninitialised variable in ti_do_download
      USB: fix memleak in usbfs
      USB: fix race leading to a write after kfree in usbfs

Pablo Bitton (1):
      davinci_emac: fix kernel oops when changing MAC address while inter=
face is down

Parag Warudkar (1):
      elfcore.h : Fix UML build breakage

Pascal Terjan (1):
      zd1211rw: 07b8:6001 is a ZD1211B

Paul E. McKenney (2):
      rcu: Mark Hierarchical RCU no longer experimental
      fix RCU-callback-after-kmem_cache_destroy problem in sl[aou]b

Paul Mackerras (2):
      perf_counter tools: Rework event string parsing/syntax
      x86: atomic64: Code atomic(64)_read and atomic(64)_set in C not CPP

Paul Mundt (6):
      sh: define PERF_COUNTER_INDEX_OFFSET.
      fb: Initialize fb_info mutexes in framebuffer_alloc()
      video: sh_mobile_lcdcfb: Convert to framebuffer_alloc().
      video: hitfb: Convert to framebuffer_alloc().
      video: hitfb: Move over to dev_pm_ops.
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6 into sh/for-2.6.31

Paul Vojta (1):
      ALSA: hda - fix beep tone calculation for IDT/STAC codecs

Paulius Zaleckas (1):
      USB: gadget: fix imx_udc entry in Kconfig

Pekka Enberg (3):
      SLAB: Fix lockdep annotations
      xen: Use kcalloc() in xen_init_IRQ()
      Merge branch 'slab/urgent' into for-linus

Peng Tao (1):
      ext4: fix null handler of ioctls in no journal mode

Pete Zaitcev (1):
      Staging: rspiusb: use NULL virtual address instead of a bogus one

Peter Chubb (1):
      x86: Fix resume from suspend when CONFIG_CC_STACKPROTECTOR

Peter Oberparleiter (1):
      gcov: exclude code operating in userspace from profiling

Peter Zijlstra (2):
      sched: INIT_PREEMPT_COUNT
      sched: optimize cond_resched()

Philipp Zabel (1):
      USB: gadget: pxa25x uses gpio_is_valid

Ping Cheng (1):
      Input: wacom - add DTF720a support and fix rotation on Intuos3

Qiuping Chen (1):
      USB: gadget: rndis conformance tweak

Rakib Mullick (1):
      x86, kvm: Fix section mismatches in kvm.c

Randy Dunlap (3):
      PCI: fix kernel-doc warnings
      USB: usb.h: fix kernel-doc notation
      USB: gadget audio: select SND_PCM

Raphael Assenat (1):
      [WATCHDOG] SA1100 watchdog maximum timeout

Remis Lima Baima (2):
      microblaze: use the generic lib/checksum.c
      microblaze: convert all simple headers to use asm-generic

Robert P. J. Day (1):
      vlynq: correct typo of missing "CONFIG_" prefix in ifdef

Robert Richter (1):
      x86/oprofile: rename kernel parameter for architectural perfmon to =
arch_perfmon

Roel Kluin (1):
      USB: fhci: mutually exclusive port_status

Roland Dreier (2):
      fealnx: Fix build breakage -- PR_CONT should be KERN_CONT
      cxgb3: Fix crash caused by stashing wrong netdev_queue

Ron Mercer (8):
      qlge: Expand coverage of hw lock for config register.
      qlge: Clear frame to queue routing before reset.
      qlge: Fix carrier on condition.
      qlge: Fix redundant call to free resources.
      qlge: Fix tx byte counter.
      qlge: Fix MAC address bonding issue.
      qlge: Add/use function for link up/down.
      qlge: Fix sizeof usage.

Russell King (4):
      [ARM] export __cpu_flush_dcache_page
      [ARM] pgtable: swp pte layout documentation, definitions, and check
      [ARM] pgtable: file pte layout documentation
      [ARM] amba: fix amba device resources

Ryusuke Konishi (4):
      nilfs2: remove unlikely directive causing mis-conversion of error c=
ode
      nilfs2: fix hang problem of log writer which occurs after write fai=
lures
      nilfs2: fix incorrect KERN_CRIT messages in case of write failures
      nilfs2: fix lockdep warning between regular file and inode file

SUGIOKA Toshinobu (1):
      serial: sh-sci: fix sci interrupt handler

Saeed Bishara (1):
      Input: gpio_mouse - use standard driver registration method

Samuel Ortiz (1):
      iwmc3200wifi: add Kconfig help

Sathya Perla (1):
      be2net: fix spurious interrupt handling in intx mode

Sean MacLennan (2):
      powerpc/44x: Update Warp defconfig
      powerpc/4xx: Have Warp take advantage of GPIO LEDs default-state =3D=
 keep

Sebastian Ott (1):
      PM: Clear -EAGAIN in dpm_prepare

Sergei Shtylyov (1):
      USB: musb_host: undo incorrect change in musb_advance_schedule()

Shaohua Li (1):
      drm/i915: add FIFO watermark support

Sheng Yang (1):
      intel-iommu: Fix intel_iommu_unmap_range() with size 0

Slobodan Tomi=C4=87 (1):
      [WATCHDOG] w83627hf_wdt.c: add support for the W83627EHF support

Stefan Haberland (1):
      [S390] dasd: correct debugfeature sense dump

Stefan Herbrechtsmeier (1):
      V4L/DVB (12159): soc_camera: Fix debug output of supported formats =
count

Stefan Richter (3):
      firewire: core: do not DMA-map stack addresses
      firewire: sbp2: add support for disks >2 TB (and 16 bytes long CDBs=
)
      ieee1394: sbp2: add support for disks >2 TB (and 16 bytes long CDBs=
)

Stephane Contri (1):
      dsa: fix 88e6xxx statistics counter snapshotting

Steve French (1):
      [CIFS] update cifs version number

Takashi Iwai (7):
      ALSA: hda - Fix error path in the sanity check in azx_pcm_open()
      ALSA: hda - Clean up VT170x dig-in initialization code
      ALSA: hda - Add missing EAPD initialization for VIA codecs
      ALSA: hda - Fix capture source selection in patch_via.c
      ALSA: hda - Check widget types while parsing capture source in patc=
h_via.c
      Merge branch 'fix/asoc' into for-linus
      Merge branch 'fix/hda' into for-linus

Thadeu Lima de Souza Cascardo (1):
      Input: mark serio and i8042 as suspended when hibernating too

Theodore Ts'o (5):
      ext4: Fix type warning on 64-bit platforms in tracing events header
      jbd2: Remove GFP_ATOMIC kmalloc from inside spinlock critical regio=
n
      ext4: Fix potential reclaim deadlock when truncating partial block
      ext4: fix no journal corruption with locale-gen
      ext4: Fix ext4_mb_initialize_context() to initialize all fields

Tilman Schmidt (2):
      gigaset: accept connection establishment messages in any order
      gigaset: drop pointless check

Tobias Doerffel (1):
      linux/sysrq.h needs linux/errno.h

Trond Myklebust (1):
      Fix compile error due to congestion_wait() changes

Vasanthakumar Thiagarajan (1):
      ath9k: Fix leak in tx descriptor

Vivek Goyal (1):
      cfq-iosched: reset oom_cfqq in cfq_set_request()

Wade Farnsworth (1):
      phylib: fixes for PHY_RESUMING state changes

Wei Yongjun (3):
      xfrm4: fix the ports decode of sctp protocol
      xfrm6: fix the proto and ports decode of sctp protocol
      sctp: fix warning at inet_sock_destruct() while release sctp socket

Xiao Guangrong (1):
      tracing: Fix trace_print_seq()

Yan Li (1):
      Input: i8042 - more reset quirks for MSI Wind-clone netbooks

Yi Zou (1):
      ixgbe: Fix coexistence of FCoE and Flow Director in 82599

Yinghai Lu (3):
      x86/PCI: fix boundary checking when using root CRS
      x86/PCI: get root CRS before scanning children
      x86: don't clear nodes_states[N_NORMAL_MEMORY] when numa is not com=
piled in

Yu Zhao (1):
      PCI: check if bus has a proper bridge device before triggering SBR

Zhang, Yanmin (1):
      sys_sync(): fix 16% performance regression in ffsb create_4k test

Zhao Yakui (4):
      drm/i915: Check the LID device to decide whether the LVDS should be=
 initialized
      drm/i915: Restore the KMS modeset for every activated CRTC
      drm: Disable the unused connectors explicitly when resuming with KM=
S.
      drm/i915: Avoid saving/restore the modesetting registers twice in K=
MS mode

Zhenyu Wang (2):
      drm/i915: Don't update display FIFO watermark on IGDNG
      drm/i915: Fix for LVDS VBT change on IGDNG

dingdinghua (1):
      jbd2: fix race between write_metadata_buffer and get_write_access

ling.ma-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org (4):
      drm/i915: Set SSC frequency for 8xx chips correctly
      drm/i915: enable sdvo lvds scaling function.
      drm/i915: crt fetch EDID by DVI-I converter on G4x platform
      drm/i915: Disable VGA output when doing DRM_MODE_DPMS_OFF.

venkatesh.pallipadi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org (4):
      [CPUFREQ] Eliminate the recent lockdep warnings in cpufreq
      [CPUFREQ] Mark policy_rwsem as going static in cpufreq.c wont be ex=
ported
      [CPUFREQ] Cleanup locking in ondemand governor
      [CPUFREQ] Cleanup locking in conservative governor

vibi sreenivasan (1):
      driver model: fix show/store prototypes in doc.

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr

--===============7154814501442414722==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============7154814501442414722==--
