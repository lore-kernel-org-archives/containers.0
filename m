From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr annotated tag, v2.6.30-rc1, created. v2.6.30-rc1
Date: Wed, 16 Sep 2009 14:36:45 -0400
Message-ID: <200909161836.n8GIaj1k001379@gorgona.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7877156743762237586=="
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

--===============7877156743762237586==
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by smtp1.linux-foundation.org id n8GJTnAE009519

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The annotated tag, v2.6.30-rc1 has been created
        at  42ae7400074d449189d41fceb6d6f871490d7842 (tag)
   tagging  577c9c456f0e1371cbade38eaf91ae8e8a308555 (commit)
  replaces  v2.6.29
 tagged by  Linus Torvalds
        on  Tue Apr 7 14:25:11 2009 -0700

- Log -----------------------------------------------------------------
Linux 2.6.30-rc1
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAknbxLsACgkQF3YsRnbiHLvCIwCgqsu5W7lJUNRA8KxGJtzopVXn
oR0AoJPnQ9JAKqPW5mvZ5s1fBmFHHqJv
=3D5Vxa
-----END PGP SIGNATURE-----

ADDI-DATA GmbH (1):
      Staging: comedi: add addi-data drivers

Aaro Koskinen (1):
      [SCSI] sym53c8xx: Keep transfer negotiations valid

Abbas, Mohamed (3):
      iwlwifi: allow user to set max rate
      iwlagn: fix agn rate scaling
      iwl3945: fix deep sleep when removing the driver.

Abhijeet Kolekar (27):
      iwl3945: use iwl_rx_mem_buffer
      iwl3945: use iwl_rx_queue in iwl3945
      iwl3945: use iwl_hw_params in iwl3945_priv
      iwl3945: rename iwl3945_priv variables
      iwl3945: replaces iwl3945_priv with iwl_priv
      iwl3945: use iwl-io.h and delete iwl-3945-io.h
      iwl3945: use iwl_rx_scan handlers
      iwl3945: use iwl_mac_hw_scan callback
      iwl3945: use iwl rx handlers
      iwl3945: use iwl_rx_reply_error notification
      iwl3945: remove duplicate interrupt code
      iwl3945: use iwl_isr
      iwl3945: use SW rfkill from iwlwifi
      iwl3945: synchronize timestamp with uCode
      iwl3945: unify set key flow with iwlwifi
      iwl3945: add iwl3945_setup_mac
      iwl3945 : use iwl_activate_qos
      iwl3945: add test for new association
      iwl3945: fix sparse error
      iwl3945: use iwl_led structure
      iwl3945 : fix rate scaling
      iwl3945: use iwl_tx_cmd_complete
      iwl3945: set TFD_QUEUE_MAX to correct value
      iwl3945: use iwl_cmd_queue_free
      iwl3945: fix checkpatch.pl errors
      iwl3945: control rate decrease
      iwl3945: replace stations with stations_39

Abhijith Das (2):
      GFS2: Bring back lvb-related stuff to lock_nolock to support quotas
      GFS2: change gfs2_quota_scan into a shrinker

Abylay Ospan (5):
      V4L/DVB (10796): Add init code for NetUP Dual DVB-S2 CI card
      V4L/DVB (10797): Add EEPROM code for NetUP Dual DVB-S2 CI card.
      V4L/DVB (10798): Add CIMax(R) SP2 Common Interface code for NetUP D=
ual DVB-S2 CI card
      V4L/DVB (11056): Bug fix in NetUP: restore high address lines in CI
      V4L/DVB (11057): Fix CiMax stability in Netup Dual DVB-S2 CI

Adam Baker (3):
      V4L/DVB (10639): gspca - sq905: New subdriver.
      V4L/DVB (10829): Support alternate resolutions for sq905
      V4L/DVB (11387): Sensor orientation reporting

Adam Buchbinder (1):
      trivial: Fix misspelling of "Celsius".

Adam McDaniel (1):
      Staging: rt2860: Ported v1.7.1.1 changes into v1.8.0.0, becoming v1=
.8.1.1

Adam Nielsen (2):
      netfilter: x_tables: add LED trigger target
      leds: Prevent multiple LED triggers with the same name

Adrian Bunk (6):
      [SCSI] ses: #if 0 the unused ses_match_host()
      [SCSI] a3000: make 2 functions static
      [SCSI] a2091: make 2 functions static
      FRV: Fix compile breakage
      net/802/fddi.c: add MODULE_LICENSE
      tty: Correct inline types for tty_driver_kref_get()

Adrian Hunter (16):
      UBIFS: fix dbg_chk_lpt_sz()
      UBIFS: fix bug where page is marked uptodate when out of space
      [MTD] mtdoops: allow MTD selection by name
      [MTD] mtdoops: fix a bit of spin lock usage
      [MTD] [OneNAND] omap2: panic_write may be in an interrupt context
      ARM: OMAP3: mmc-twl4030 fix name buffer length, v2
      ARM: OMAP3: mmc-twl4030 add cover switch
      ARM: OMAP3: mmc-twl4030 allow arbitrary slot names, v3
      mmc: Add Extended CSD register to debugfs
      omap_hsmmc: do not re-power when powering off MMC
      omap_hsmmc: Fix response type for busy after response
      omap_hsmmc: Allow cover switch to cause rescan
      omap_hsmmc: Do not prefix slot name
      omap_hsmmc: Wait for SDBP
      regulator: twl4030 VAUX3 supports 3.0V
      UBIFS: fix recovery bug

Adrian McMenamin (2):
      sh: maple: Support block reads and writes.
      mtd: flash mapping support for Dreamcast VMU.

Adrian-Ken Rueegsegger (1):
      crypto: Fix dead links

Ajay Kumar Gupta (3):
      USB: otg: adding nop usb transceiver
      USB: musb: NAK timeout scheme on bulk RX endpoint
      USB: musb: only turn off vbus in OTG hosts

Akinobu Mita (11):
      x86: unify kmap_atomic_pfn() and iomap_atomic_prot_pfn()
      x86: debug check for kmap_atomic_pfn and iomap_atomic_prot_pfn()
      x86, mm: remove unnecessary include file from iomap_32.c
      slub: use get_track()
      generic debug pagealloc
      mm: introduce debug_kmap_atomic
      mm: use debug_kmap_atomic
      x86, mm: fix misuse of debug_kmap_atomic
      generic debug pagealloc: build fix
      mm: fix misuse of debug_kmap_atomic
      ALSA: hda - add missing comma in ad1884_slave_vols

Al Viro (28):
      constify dentry_operations: NFS
      constify dentry_operations: misc filesystems
      constify dentry_operations: 9p
      constify dentry_operations: autofs, autofs4
      constify dentry_operations: AFS
      constify dentry_operations: CIFS
      constify dentry_operations: ecryptfs
      constify dentry_operations: procfs
      constify dentry_operations: FUSE
      constify dentry_operations: FAT
      constify dentry_operations: GFS2
      constify dentry_operations: OCFS2
      constify dentry_operations: JFS
      constify dentry_operations: sysfs
      constify dentry_operations: configfs
      constify dentry_operations: rest
      Kill unsharing fs_struct in __set_personality()
      Get rid of bumping fs_struct refcount in pivot_root(2)
      Take fs_struct handling to new file (fs/fs_struct.c)
      New locking/refcounting for fs_struct
      check_unsafe_exec() doesn't care about signal handlers sharing
      New helper - current_umask()
      Get rid of indirect include of fs_struct.h
      Don't mess with descriptor table in load_elf_binary()
      Trim includes in binfmt_elf
      Don't crap into descriptor table in binfmt_som
      Trim includes of fdtable.h
      Cleanup after commit 585d3bc06f4ca57f975a5a1f698f65a45ea66225

Alain Knaff (8):
      bzip2/lzma: library support for gzip, bzip2 and lzma decompression
      bzip2/lzma: config and initramfs support for bzip2/lzma decompressi=
on
      bzip2/lzma: x86 kernel compression support
      bzip2/lzma: fix built-in initramfs vs CONFIG_RD_GZIP
      bzip2/lzma: fix decompress_inflate.c vs multi-block-with-embedded-f=
ilename
      bzip2/lzma: don't stop search at first unconfigured compression
      bzip2/lzma: don't leave empty files around on failure
      bzip2/lzma: make internal initramfs compression configurable

Alan Carvalho de Assis (1):
      i.MX31: Fixing cs89x0 network building to i.MX31ADS

Alan Cox (28):
      [ARM] cumana: Fix a long standing bogon
      [ARM] fix leak in iop13xx/pci
      [ARM] twl4030 - leak fix
      pata_artop: Serializing support
      pata_sc1200: Activate secondary channel
      [libata] Drain data on errors
      [libata] Improve timeout handling
      [WATCHDOG] wdt.c: remove #ifdef CONFIG_WDT_501
      dontdiff: Fix asm exclude
      appletalk: this warning can go I think
      af_rose/x25: Sanity check the maximum user frame size
      sony-laptop: Eliminate BKL in ioctls
      V4L/DVB (11243): cx88: Missing failure checks
      V4L/DVB (11244): pluto2: silence spew of card hung up messages
      [SCSI] config: Make need for SCSI_CDROM clearer
      [SCSI] mptsas: remove unneeded check
      LANANA: Change of management and resync
      ucc: Fix leaky error path
      isicom: isicom kref leak fix
      cdc-acm: zydas 1602 identifier needed
      tty: pl2303 needs identifiers for Siemens S81 as well as EF81
      symbol: Remove various bits of left over junk
      8250: Fix warning
      LANANA: Fix dates
      pata_artop: typo
      serqt: initial clean up pass for tty side
      lanana: assign a device name and numbering for MAX3100
      parport: Use the PCI IRQ if offered

Alan McIvor (1):
      V4L/DVB (11124): Add support for ProVideo PV-183 to bttv

Alan Stern (21):
      [SCSI] sd: tell the user when a disk's capacity is adjusted
      [SCSI] fix /proc memory leak in the SCSI core
      USB: add quirk to avoid config and interface strings
      USB: usb-storage: increase max_sectors for tape drives
      USB: EHCI: Make timer_action out-of-line
      USB: EHCI: add software retry for transaction errors
      usb-storage: prepare for subdriver separation
      usb-storage: make sddr09 a separate module
      usb-storage: make isd200 a separate module
      usb-storage: make sddr55 a separate module
      usb-storage: make cypress_atacb a separate module
      usb-storage: make shuttle_usbat a separate module
      usb-storage: make freecom a separate module
      usb-storage: make datafab a separate module
      usb-storage: make jumpshot a separate module
      usb-storage: make alauda a separate module
      usb-storage: make karma a separate module
      usb-storage: make onetouch a separate module
      USB: uhci: don't use pseudo negative values
      USB: don't send Set-Interface after reset
      USB: usbfs: remove unneeded "inline" annotations

Alasdair G Kergon (1):
      dm table: fix upgrade mode race

Alberto Bertogli (1):
      trivial: Fix typo in bio_split()'s documentation

Alessio Igor Bogani (3):
      sony-laptop: Kill the BKL
      nvidiafb: remove open_lock mutex
      sony-laptop: Fix some typos in log messages (Unabe/Unable)

Alex Chiang (19):
      e1000e: normalize usage of serdes_has_link
      PCI: enhance physical slot debug information
      PCI: PCIe portdrv: eliminate double kfree in remove path
      PCIe: portdrv: call pci_disable_device during remove
      PCI: always scan child buses
      PCI: do not initialize bridges more than once
      PCI: do not enable bridges more than once
      PCI: Introduce pci_rescan_bus()
      PCI: Introduce /sys/bus/pci/rescan
      PCI: Introduce /sys/bus/pci/devices/.../remove
      PCI: Introduce /sys/bus/pci/devices/.../rescan
      PCI Hotplug: rename legacy_fakephp to fakephp
      PCI Hotplug: schedule fakephp for feature removal
      sysfs: sysfs_add_one WARNs with full path to duplicate filename
      sysfs: only allow one scheduled removal callback per kobj
      PCI: annotate pci_rescan_bus as __ref, not __devinit
      PCI: allow PCI core hotplug to remove PCI root bus
      PCI Hotplug: acpiphp: grab refcount on p2p subordinate bus
      PCI: pci_slot: grab refcount on slot's bus

Alex Deucher (12):
      drm/radeon: prep for r6xx/r7xx support
      drm/radeon: add r6xx/r7xx microcode
      drm/radeon: add initial support for R6xx/R7xx GPUs
      radeon: add R6xx/R7xx pci ids
      radeon: fix r600 AGP support
      radeon: add support for rs600 GPUs
      radeon: add RS600 pci ids
      drm/radeon: RS600: fix interrupt handling
      drm/radeon: r6xx/r7xx: fix possible oops in r600_page_table_cleanup=
()
      drm/radeon: fix logic in r600_page_table_init() to match ati_gart
      radeon: add some new pci ids
      drm/radeon: load the right microcode on rs780

Alex Stephens (1):
      USB: CP2101 New Device ID

Alex Williamson (6):
      virtio_net: Add a virtqueue for outbound control commands
      virtio_net: Add a set_rx_mode interface
      virtio_net: Add a MAC filter table
      virtio_net: Add support for VLAN filtering in the hypervisor
      virtio_net: Allow setting the MAC address of the NIC
      virtio_net: Set the mac config only when VIRITO_NET_F_MAC

Alexander Beregalov (25):
      MMC: tmio_mmc.h: fix build problem
      ni5010: convert to net_device_ops
      dmascc: fix incomplete conversion to network_device_ops
      wireless: remove duplicated .ndo_set_mac_address
      reiserfs: fix build breakage
      parisc: iosapic: fix build breakage
      parisc: led: remove proc_dir_entry::owner
      parisc: asm/pdc.h should include asm/page.h
      parisc: drivers: fix warnings
      sony-laptop should depend on RFKILL
      Staging: meilhaus: remove dependence on kernel version
      Staging: meilhaus: some checkpatch.pl cleanup
      Staging: otus: remove old irqreturn_t definition
      Staging: pohmelfs: fix build breakage
      Staging: pohmelfs: net.c: include vmalloc.h
      Staging: pohmelfs: fix printk format warnings v2
      Staging: pohmelfs should depend on CRYPTO
      Staging: pohmelfs: should include fs_struct.h
      Staging: echo cleanup
      vxge: should include tcp.h
      drivers/pci/intr_remapping.c: include acpi.h
      mux: fix build problem
      md/raid1: fix build breakage
      V4L/DVB (11438): au0828: fix Kconfig dependance
      loop: mutex already unlocked in loop_clr_fd()

Alexander Clouter (15):
      [ARM] orion5x: add rtc-m48t86 to orion5x_defconfig
      [ARM] orion5x: remove TS-78xx NOR support as it does not exist
      [ARM] orion5x: TS-78xx comment shifting
      [ARM] orion5x: TS-78xx support for 'hotplug' of FPGA devices
      hwrng: timeriomem - New driver
      [CPUFREQ] conservative: amend author's email address
      [CPUFREQ] conservative: fix dbs_cpufreq_notifier so freq is not loc=
ked
      [CPUFREQ] conservative: fixup governor to function more like ondema=
nd logic
      [CPUFREQ] conservative: remove 10x from def_sampling_rate
      [ARM] orion5x: ts78xx make more bulletproof the RTC load/unload cod=
e
      [ARM] orion5x: ts78xx amend RTC registering to not depend on ifdef'=
s
      [ARM] orion5x: ts78xx add NAND support via plat_nand
      [ARM] orion5x: added a new FPGA ID set for the TS-78xx
      [ARM] orion5x: update of FPGA ID's for the TS-78xx
      hwrng: timeriomem - Use phys address rather than virt

Alexander Duyck (63):
      igb: igb should not flag lltx
      igb: make certain to power on optics for 82576 fiber nics
      e1000: drop lltx, remove unnecessary lock
      igb: optimize/refactor receive path
      igb: move setting of buffsz out of repeated path in alloc_rx_buffer=
s
      igb: move initialization of number of queues into set_interrupt_cap=
ability
      igb: remove check for needing an io port
      igb: add link check function
      igb: make dev_spec a union and remove dynamic allocation
      igb: read address from RAH/RAL instead of from EEPROM
      igb: rename phy ops
      igb: rename nvm ops
      igb: remove unused rx_hdr_split statistic
      igb: update feature flags supported in ethtool
      igb: update testing done by ethtool
      igb: add counter for dma out of sync errors
      igb: cleanup igb_netpoll to be more friendly with napi & GRO
      igb: remove redundant timer updates and cleanup watchdog_task
      igb: rename igb_update_mc_addr_list_82575 to not include the 82575
      igb: remove unnecessary adapter->hw calls when just hw-> will do.
      igb: don't read eicr when responding to legacy interrupts
      igb: move get_hw_control within igb_resume.
      igb: change pba size determination from if to switch statement
      igb: remove disable_av variable from mac_info struct
      igb: remove redundant count set and err_hw_init
      igb: update stats before doing reset in igb_down
      igb: fix two minor items found during code review
      igb: update version number and copyright dates
      igb: misc whitespace/formatting cleanups
      igb: reduce size required to trigger low latency
      igb: cleanup incorrect comment and set IP Checksum Enable
      igb: misc cleanup to combine one if statement
      igb: remove unused defines
      igb: transition driver to only using advanced descriptors
      igb: update napi polling to consolidate function and return correct=
 values
      igb: add vfs_allocated_count as placeholder for number of vfs
      igb: add pf side of VMDq support
      igb: Add support for enabling VFs to PF driver.
      igb: this patch addes the sr-iov enablement option via num_vfs para=
meter
      igb: remove skb_orphan calls
      igb: remove netif running call from igb_poll
      igb: resolve warning of unused adapter struct
      igb: support wol on second port
      igb: add PF to pool
      igb: correct typo that was setting vfta mask to 1
      igb: add support for another dual port 82576 non-security nic
      igb: add support for 82576 quad copper adapter
      e1000e: add support for 82583 device id
      e1000e: fix dma error handling issues
      ixgb: refactor tx path to use skb_dma_map/unmap
      igb: remove IGB_DESC_UNUSED since it is better handled by a functio=
n call
      igb: update driver to use setup_timer function
      igb: rework igb_set_multi so that vfs are properly updated
      igb: cleanup tx dma so map & unmap use matching calls
      e1000: fix tx hang detect logic and address dma mapping issues
      e1000: cleanup clean_tx_irq routine so that it completely cleans ri=
ng
      e1000e: commonize tx cleanup routine to match e1000 & igb
      igb: add support for x2 link width configurations
      igb: set num_rx/tx_queues to 0 when queues are freed
      igb: increase delay for copper link setup
      igb: cleanup igb loopback path
      ixgbe: fix build when DEBUG is defined
      ixgbe: refactor tx buffer processing to use skb_dma_map/unmap

Alexander Graf (13):
      KVM: SVM: Clean up VINTR setting
      KVM: SVM: Move EFER and MSR constants to generic x86 code
      KVM: SVM: Add helper functions for nested SVM
      KVM: SVM: Implement GIF, clgi and stgi
      KVM: SVM: Implement hsave
      KVM: SVM: Add VMLOAD and VMSAVE handlers
      KVM: SVM: Add VMRUN handler
      KVM: SVM: Add VMEXIT handler and intercepts
      KVM: SVM: Allow setting the SVME bit
      KVM: SVM: Only allow setting of EFER_SVME when CPUID SVM is set
      KVM: SVM: Add microcode patch level dummy
      x86: Add EFER descriptions for FFXSR
      KVM: Add FFXSR support

Alexander Schulz (1):
      [ARM] 5363/1: Shark cleanup and new defconfig

Alexander Shumakovitch (1):
      USB: qcserial: add device id for HP devices

Alexandros Batsakis (1):
      nfsd: lock state around put client and delegation in nfsd4_cb_recal=
l

Alexey Dobriyan (25):
      pppol2tp: stop using proc internals
      ppp: section fixes re netns
      proc 1/2: do PDE usecounting even for ->read_proc, ->write_proc
      proc 2/2: remove struct proc_dir_entry::owner
      Revert "proc: revert /proc/uptime to ->read_proc hook"
      proc tty: add struct tty_operations::proc_fops
      proc tty: switch cyclades to ->proc_fops
      proc tty: switch ip2 to ->proc_fops
      proc tty: switch istallion to ->proc_fops
      proc tty: switch synclink_cs to ->proc_fops
      proc tty: switch stallion to ->proc_fops
      proc tty: switch synclink to ->proc_fops
      proc tty: switch synclink_gt to ->proc_fops
      proc tty: switch synclinkmp to ->proc_fops
      proc tty: switch sdio_uart to ->proc_fops
      proc tty: switch serial_core to ->proc_fops
      proc tty: switch usb-serial to ->proc_fops
      proc tty: switch ircomm to ->proc_fops
      proc tty: switch amiserial to ->proc_fops
      proc tty: switch ia64 simserial to ->proc_fops
      proc tty: switch xtensa iss console to ->proc_fops
      proc tty: remove struct tty_operations::read_proc
      mm: fix proc_dointvec_userhz_jiffies "breakage"
      serial: fixup /proc/tty/driver/serial after proc_fops conversion
      Simplify copy_thread()

Alexey Klimov (22):
      V4L/DVB (10316): v4l/dvb: use usb_make_path in usb-radio drivers
      V4L/DVB (10324): em28xx: Correct mailing list
      V4L/DVB (10335): gspca - all subdrivers: Fix CodingStyle in sd_mod_=
init function.
      V4L/DVB (10336): gspca - all subdrivers: Return ret instead of -1 i=
n sd_mod_init.
      V4L/DVB (10455): radio-mr800: codingstyle cleanups
      V4L/DVB (10456): radio-mr800: place dev_err instead of dev_warn
      V4L/DVB (10457): radio-mr800: add more dev_err messages in probe
      V4L/DVB (10458): radio-mr800: move radio start and stop in one func=
tion
      V4L/DVB (10459): radio-mr800: fix amradio_set_freq
      V4L/DVB (10460): radio-mr800: add stereo support
      V4L/DVB (10461): radio-mr800: add few lost mutex locks
      V4L/DVB (10462): radio-mr800: increase version and add comments
      V4L/DVB (10463): radio-mr800: fix checking of retval after usb_bulk=
_msg
      V4L/DVB (10464): radio-si470x: use usb_make_path in usb-radio drive=
rs
      V4L/DVB (10465): dsbr100: Add few lost mutex locks.
      V4L/DVB (10522): em28xx-audio: replace printk with em28xx_errdev
      V4L/DVB (10946): radio-rtrack2: fix double mutex_unlock
      V4L/DVB (10961): radio-terratec: remove linux/delay.h which hadn't =
been used.
      V4L/DVB (11391): pci-isa radios: remove open and release functions
      V4L/DVB (11393): radio-si470x: fix possible bug with freeing memory=
 order
      V4L/DVB (11435): dsbr100 radio: convert to to v4l2_device
      V4L/DVB (11436): radio-mr800: convert to to v4l2_device

Alexey Starikovskiy (3):
      ACPI: battery: add power_{now,avg} properties to power_class
      ACPI: EC: Separate delays for MSI hardware
      ACPI: EC: Always parse EC device

Alexey Zaytsev (3):
      trivial: Fix dubious bitwise 'or' usage spotted by sparse.
      trivial: Fix dubious bitwise 'or' usage spotted by sparse.
      trivial: Fix dubious bitwise 'and' usage spotted by sparse.

Alina Friedrichsen (22):
      mac80211: Disallow to set multicast BSSID
      mac80211: Don't scan if BSSID and channel are set manually
      mac80211: Don't merge if BSSID is set manually
      mac80211: Allow to set channel in adhoc properly
      mac80211: Read the TSF via debugfs
      ath5k: Read and write the TSF via debugfs
      ath9k: Read and write the TSF via debugfs
      mac80211: Fixed BSSID handling revisited
      mac80211: Generic TSF debugging
      b43: Accessing the TSF via mac80211
      mac80211: Creating new IBSS with fixed BSSID
      mac80211: IBSS join rework
      mac80211: Remove TSF atomic requirement from the documentation
      ath9k: Don't reset TSF after scanning automatically
      mac80211: Introduce a generic commit() to apply changes
      mac80211: Don't merge with the same BSSID
      mac80211: Give it some time to do the TSF sync
      zd1211rw: Implement get_tsf()
      ath9k: Fix FIF_BCN_PRBRESP_PROMISC handling
      ath9k: Set TSF fix
      ath5k: Set TSF fix
      mac80211: ieee80211_ibss_commit() cleanup

Allan Willcox (1):
      Staging: comedi: add amplc_pci230 driver

Alok Kataria (2):
      x86, apic: fix initialization of wakeup_cpu
      x86, vmi: TSC going backwards check in vmi clocksource, cleanup

Amit Gud (1):
      Btrfs: fix race in worker_loop

Amit Shah (3):
      KVM: x86: Fix typos and whitespace errors
      KVM: VMX: Update necessary state when guest enters long mode
      KVM: is_long_mode() should check for EFER.LMA

Am=C3=A9rico Wang (5):
      slob: clean up the code
      sched: use TASK_NICE for task_struct
      ptrace: remove a useless goto
      x86: ptrace, bts: fix an unreachable statement
      kernel/module.c: fix an unused goto label

Ananth N Mavinakayanahalli (1):
      kprobes: Fix locking imbalance in kretprobes

Anders Blomdell (5):
      Staging: comedi: add jr3_pci driver
      Staging: comedi: add serial2002 driver
      Staging: comedi: add rti802 driver
      Staging: comedi: add multiq3 driver
      Staging: comedi: add daqboard2000 driver

Anders Gnistrup (1):
      Staging: comedi: add fl212 driver

Anders Kaseorg (1):
      Ksplice: Add functions for walking kallsyms symbols

Andi Kleen (21):
      x86: hpet: allow force enable on ICH10 HPET
      x86, mce: disable machine checks on suspend
      x86, mce: don't disable machine checks during code patching
      x86, mce: always use separate work queue to run trigger
      x86, mce: switch machine check polling to per CPU timer
      x86, mce: don't set up mce sysdev devices with mce=3Doff
      x86, mce: disable machine checks on offlined CPUs
      x86, mce: enable machine checks in 64-bit defconfig
      x86, mce: implement dynamic machine check banks support
      x86, mce: factor out duplicated struct mce setup into one function
      x86, mce: separate correct machine check poller and fatal exception=
 handler
      x86, mce, cmci: export MAX_NR_BANKS
      x86, mce, cmci: factor out threshold interrupt handler
      x86, mce, cmci: avoid potential reentry of threshold interrupt
      x86, mce: replace machine check events logged interval with ratelim=
it
      x86, mce, cmci: use polled banks bitmap in machine check poller
      x86, mce, cmci: define MSR names and fields for new CMCI registers
      x86, mce, cmci: add CMCI support
      x86, mce, cmci: disable CMCI on rebooting
      x86, mce, cmci: recheck CMCI banks after APIC has been enabled on C=
PU #0
      x86, mce: enable machine checks in 64-bit defconfig

Andre Haupt (15):
      Bluetooth: Eliminate a sparse warning in bt3c driver
      Staging: asus_oled: fix sparse warnings about using plain integer a=
s NULL pointer
      Staging: asus_oled: do not initialise statics to 0 or NULL
      Staging: asus_oled: trailing statements should be on next line
      Staging: asus_oled: fix various checkpatch.pl issues regarding miss=
ing or obsolete spaces
      Staging: asus_oled: do not use assignment in if condition
      Staging: me4000: use linux/uaccess.h and linux/io.h
      Staging: me4000: return is not a function, no parentheses required
      Staging: me4000: inline keyword should sit between storage class an=
d type
      Staging: me4000: replace some C99 comments
      Staging: me4000: kfree(NULL) is safe, so no extra checks needed.
      Staging: me4000: fix various checkpatch.pl warnings about bracing
      Staging: me4000: do not use C99 style comments.
      Staging: me4000: use tabs for code indentation
      Staging: me4000: make file_operations const

Andre Noll (3):
      md: Make mddev->size sector-based.
      md: Represent raid device size in sectors.
      md: raid5 run(): Fix max_degraded for raid level 4.

Andre Przywara (1):
      KVM: SVM: set accessed bit for VMCB segment selectors

Andrea Arcangeli (1):
      KVM: Fix missing smp tlb flush in invlpg

Andrea Borgia (2):
      ALSA: preliminary support for Toshiba SB-0500
      ALSA: rename "Device" to "Toshiba SB-0500" via quirks

Andrea Righi (1):
      fbmem: fix fb_info->lock and mm->mmap_sem circular locking dependen=
cy

Andreas Bergmeier (2):
      ALSA: usb-audio - Quirk for Serato phono
      ALSA: usbaudio - use printf format instead of hardcoding it

Andreas Herrmann (11):
      x86: hpet: print HPET registers during setup (if hpet=3Dverbose is =
used)
      x86: hpet: provide separate functions to stop and start the counter
      x86: hpet: stop HPET_COUNTER when programming periodic mode
      x86: memtest: reuse test patterns when memtest parameter exceeds nu=
mber of available patterns
      x86: memtest: introduce array to select memtest patterns
      x86: memtest: cleanup memtest function
      x86: memtest: adapt log messages
      x86: memtest: wipe out test pattern from memory
      x86: update description for memtest boot parameter
      x86: memtest: add additional (regular) test patterns
      x86: mtrr: don't modify RdDram/WrDram bits of fixed MTRRs

Andreas Krebbel (1):
      [S390] Add hwcap flag for the etf3 enhancement facility

Andreas Mohr (1):
      ALSA: ALS4000, slight mixer improvements

Andreas Schwab (1):
      x86 setup: fix asm constraints in vesa_store_edid

Andres Salomon (15):
      drivers/video/sgivwfb.c: fix memory leaks in removal path
      tdfxfb: fix memory leaks in removal path
      tridentfb: fix memory leaks in removal path
      vfb: fix memory leaks in removal path
      skeletonfb: check fb_alloc_cmap return value and handle failure pro=
perly
      sm501fb: check fb_alloc_cmap return value and handle failure proper=
ly
      sstfb: check fb_alloc_cmap return value and handle failure properly
      stifb: check fb_alloc_cmap return value and handle failure properly
      valkyriefb: check fb_alloc_cmap return value and handle failure pro=
perly
      sunxvr500: fix cmap memory leaks
      tgafb: fix cmap memory leak
      68328fb: fix cmap memory leaks
      amba-clcd: fix cmap memory leaks
      amifb: check fb_alloc_cmap return value and handle failure properly
      asiliantfb: fix cmap memory leaks

Andrew H. Richter (1):
      claw: fix minor findings from code analysis tool

Andrew Klossner (1):
      powerpc/udbg: Fix lost byte during console handover; change LFCR to=
 CRLF

Andrew Morton (11):
      kernel/trace/ring_buffer.c: reduce inlining
      kernel/trace/ring_buffer.c: use DIV_ROUND_UP
      fix "sparseirq: use kstat_irqs_cpu on non-x86 architectures too"
      x86: use smp_call_function_single() in arch/x86/kernel/cpu/mcheck/m=
ce_amd_64.c
      PCI: constify pci_bus_assign_resources()
      regulator: minor cleanup of virtual consumer
      rtc: convert LEAP_YEAR into an inline
      drivers/video/uvesafb.c: don't use gfp_any()
      fbdev: uninline lock_fb_info()
      __tty_open(): use the correct type for saved_flags
      x86: fix is_io_mapping_possible() build warning on i386 allnoconfig

Andrew Price (1):
      rt2400,rt2500: init led_qual for LED_MODE_DEFAULT

Andrew Vasquez (12):
      [SCSI] qla2xxx: Refactor request/response-queue register handling.
      [SCSI] qla2xxx: Always (re)read firmware version/capabilities infor=
mation.
      [SCSI] qla2xxx: Pass in optional extended-initialization control bl=
ock.
      [SCSI] qla2xxx: Preserve an fcport's loop-id after terminate_rport_=
io().
      [SCSI] qla2xxx: Update MPI/PHY version retrieval codes.
      [SCSI] qla2xxx: Correct abort-semantics in qla2x00_abort_all_cmds().
      [SCSI] qla2xxx: Ensure the timer and DPC routines complete prior to=
 midlayer tear-down.
      [SCSI] qla2xxx: Always use an FLT's NVRAM/VPD region information.
      [SCSI] qla2xxx: Reduce request queue-size overhead with recent ISPs.
      [SCSI] qla2xxx: Explicitly set the execution-throttle with recent I=
SPs.
      [SCSI] qla2xxx: Don't cache VPD data for newer ISPs.
      [SCSI] qla2xxx: Update version number to 8.03.01-k1.

Andrey Borzenkov (5):
      Move orinoco Kconfig entries into drivers/net/wireless/orinoco/Kcon=
fig
      orinoco: convert to struct net_device_ops
      orinoco: trivial cleanup in alloc_orinocodev
      orinoco: checkpatch cleanup
      orinoco: firmware: consistently compile out fw cache support if not=
 requested

Andrey Yurovsky (1):
      rt2x00: Add mesh support

Andy Adamson (21):
      nfsd: embed nfsd4_current_state in nfsd4_compoundres
      nfsd: don't use the deferral service, return NFS4ERR_DELAY
      nfsd41: sessions basic data types
      nfsd41: xdr infrastructure
      nfsd41: proc stubs
      nfsd41: exchange_id operation
      nfsd41: match clientid establishment method
      nfsd41: enforce NFS4ERR_SEQUENCE_POS operation order rules for mino=
rversion !=3D 0 only.
      nfsd41: DRC save, restore, and clear functions
      nfsd41: hard page limit for DRC
      nfsd41: nfsd DRC logic
      nfsd41: clear DRC cache on free_session
      nfsd41: create_session operation
      nfsd41: Add a create session replay cache
      nfsd41: non-page DRC for solo sequence responses
      nfsd41: stateid handling
      nfsd41: check encode size for sessions maxresponse cached
      nfsd41: clientid handling
      nfsd41: access_valid
      nfsd41: add OPEN4_SHARE_ACCESS_WANT nfs4_stateid bmap
      nfsd41: support for 3-word long attribute bitmask

Andy Fleming (5):
      netdev: Merge UCC and gianfar MDIO bus drivers
      gianfar: Add support for skb recycling
      gianfar: Fix stashing support
      gianfar: remove gianfar_mii.c
      gianfar: Convert to use netdev_ops

Andy Green (1):
      [ARM] S3C24XX: Fix bug in IRQ_EINT_BIT() calculation

Andy Grover (29):
      RDS: Socket interface
      RDS: Main header file
      RDS: Congestion-handling code
      RDS: Transport code
      RDS: Info and stats
      RDS: Connection handling
      RDS: loopback
      RDS: sysctls
      RDS: Message parsing
      RDS: send.c
      RDS: recv.c
      RDS: RDMA support
      RDS/IB: Infiniband transport
      RDS/IB: Ring-handling code.
      RDS/IB: Implement RDMA ops using FMRs
      RDS/IB: Implement IB-specific datagram send.
      RDS/IB: Receive datagrams via IB
      RDS/IB: Stats and sysctls
      RDS: Add iWARP support
      RDS: Common RDMA transport code
      RDS: Documentation
      RDS: Add AF and PF #defines for RDS sockets
      RDS: Add userspace header
      RDS: Add RDS to AF key strings
      RDS: Add MAINTAINERS entry
      RDS: Kconfig and Makefile
      RDS: Fix m_rs_lock deadlock
      RDS: Rewrite connection cleanup, fixing oops on rmmod
      RDS: Use spinlock to protect 64b value update on 32b archs

Andy Richter (1):
      kmsg: convert claw printk messages

Andy Walls (44):
      V4L/DVB (10274): cx18: Fix a PLL divisor update for the I2S master =
clock
      V4L/DVB (10275): cx18: Additional debug to display outgoing mailbox=
 parameters
      V4L/DVB (10276): cx18, cx2341x, ivtv: Add AC-3 audio encoding contr=
ol to cx18
      V4L/DVB (10277): cx18, cx2341x: Fix bugs in cx18 AC3 control and co=
mply with V4L2 spec
      V4L/DVB (10278): cx18: Fix bad audio in first analog capture.
      V4L/DVB (10279): cx18: Print driver version number when logging sta=
tus
      V4L/DVB (10280): cx18: Rename structure members: dev to pci_dev and=
 v4l2dev to video_dev
      V4L/DVB (10281): cx18: Conversion to new V4L2 framework: use v4l2_d=
evice object
      V4L/DVB (10283): cx18: Call request_module() with proper argument t=
ypes.
      V4L/DVB (10284): cx18: Add initial entry for a Leadtek DVR3100 H hy=
brid card
      V4L/DVB (10433): cx18: Defer A/V core initialization until a valid =
cx18_av_cmd arrives
      V4L/DVB (10434): cx18: Smarter verification of CX18_AUDIO_ENABLE re=
gister writes
      V4L/DVB (10435): cx18: Normalize APU after second APU firmware load
      V4L/DVB (10436): cx18: Fix coding style of a switch statement per c=
heckpatch.pl
      V4L/DVB (10437): cx18: Remove an unused spinlock
      V4L/DVB (10439): cx18: Clean-up and enable sliced VBI handling
      V4L/DVB (10440): cx18: Fix presentation timestamp (PTS) for VBI buf=
fers
      V4L/DVB (10441): cx18: Fix VBI ioctl() handling and Raw/Sliced VBI =
state management
      V4L/DVB (10442): cx18: Fixes for enforcing when Encoder Raw VBI par=
ams can be set
      V4L/DVB (10443): cx18: Use correct line counts per field in firmwar=
e API call
      V4L/DVB (10444): cx18: Fix sliced VBI PTS and fix artifacts in last=
 raw line of field
      V4L/DVB (10445): cx18: Process Raw VBI on a whole frame basis; fix =
VBI buffer size
      V4L/DVB (10446): cx18: Finally get sliced VBI working - for 525 lin=
e 60 Hz systems at least
      V4L/DVB (10755): cx18: Convert the integrated A/V decoder core inte=
rface to a v4l2_subdev
      V4L/DVB (10756): cx18: Slim down instance handling, build names fro=
m v4l2_device.name
      V4L/DVB (10757): cx18, v4l2-chip-ident: Finish conversion of AV dec=
oder core to v4l2_subdev
      V4L/DVB (10758): cx18: Convert I2C devices to v4l2_subdevices
      V4L/DVB (10759): cx18: Convert GPIO connected functions to act as v=
4l2_subdevices
      V4L/DVB (10760): cx18: Fix a memory leak of buffers used for sliced=
 VBI insertion
      V4L/DVB (10761): cx18: Change log lines for internal subdevs and fi=
x tveeprom reads
      V4L/DVB (10762): cx18: Get rid of unused variables related to video=
 output
      V4L/DVB (10763): cx18: Increment version number due to significant =
changes for v4l2_subdevs
      V4L/DVB (10764): cx18: Disable AC3 controls as the firmware doesn't=
 support AC3
      V4L/DVB (10850): cx18: Use strlcpy() instead of strncpy() for temp =
eeprom i2c_client setup
      V4L/DVB (10851): cx18: Fix a video scaling check problem introduced=
 by sliced VBI changes
      V4L/DVB (10852): cx18: Include cx18-audio.h in cx18-audio.c to elim=
inate s-parse warning
      V4L/DVB (10853): cx18: Fix s-parse warnings and a logic error about=
 extracting the VBI PTS
      V4L/DVB (10854): cx18: Correct comments about vertical and horizont=
al blanking timings
      V4L/DVB (10855): cx18: Fix VPS service register codes
      V4L/DVB (10856): cx18: Add interlock so sliced VBI insertion only h=
appens for an MPEG PS
      V4L/DVB (11042): v4l2-api: Add definitions for V4L2_MPEG_STREAM_VBI=
_FMT_IVTV payloads
      V4L/DVB (11091): cx18, ivtv: Ensure endianess for linemasks in VBI =
embedded in MPEG stream
      V4L/DVB (11092): cx18: Optimize processing of VBI buffers from the =
capture unit
      V4L/DVB (11233): mxl5005s: Switch in mxl5005s_set_params should ope=
rate on correct values

Andy Whitcroft (2):
      mmc: add MODALIAS linkage for MMC/SD devices
      acer-wmi: Cleanup the failure cleanup handling

Aneesh Kumar K.V (4):
      ext4: Add checks to validate extent entries.
      ext4: Validate extent details only when read from the disk
      ext4: Fix discard of inode prealloc space with delayed allocation.
      ext4: Rename pa_linear to pa_type

Anssi Hannula (1):
      HID: add support for another version of 0e8f:0003 device in hid-pl

Antoine Jacquet (1):
      V4L/DVB (10263): zr364xx: add support for Aiptek DV T300

Anton Blanchard (20):
      powerpc/mm: Move 64-bit unmapped_area to top of address space
      powerpc/mm: Reduce hashtable size when using 64kB pages
      powerpc: Move is_32bit_task
      powerpc: Rearrange mmap.c
      powerpc: Randomise mmap start address
      powerpc: More stack randomisation for 64bit binaries
      powerpc: Randomise lower bits of stack address
      powerpc: Randomise the brk region
      powerpc: Ensure random space between stack and mmaps
      powerpc: Increase stack gap on 64bit binaries
      powerpc: Randomise PIEs
      mm: enable hashdist by default on 64bit NUMA
      mm: align vmstat_work's timer
      random: align rekey_work's timer
      powerpc: Print progress of ibm,client-architecture method
      powerpc: Clean up some prom printouts
      powerpc/pseries: Add dispatch dispersion statistics
      powerpc/pseries: Scan for all events in rtasd
      powerpc/pseries: Fix ibm,client-architecture comment
      powerpc/pseries: Enable relay in pseries_defconfig

Anton Veretenenko (1):
      sony-laptop: Add FW specific hotkey events

Anton Vorontsov (41):
      powerpc/fsl_pci: Add MPC83xx PCI-E controller RC mode support
      powerpc/83xx: Add PCI-E support for all MPC83xx boards with PCI-E
      gianfar: Implement proper, per netdevice wakeup management
      phylib: Rework suspend/resume code to check netdev wakeup capabilit=
y
      gianfar: Fix sparse warnings
      powerpc: Document FSL eSDHC bindings
      powerpc/83xx: Convert existing sdhc nodes to new bindings
      powerpc/83xx: Add FSL eSDHC support for MPC837x-RDB boards
      powerpc/83xx: Do not configure or probe disabled FSL DR USB control=
lers
      gianfar: Fix build with CONFIG_PM enabled
      fsl_pq_mdio: Revive Gianfar TBI PHY support
      tracing: Fix TRACING_SUPPORT dependency for PPC32
      fsl_pq_mdio: Use proper address translation
      powerpc/83xx: Add power management support for MPC837x boards
      powerpc/83xx: Move gianfar mdio nodes under the ethernet nodes
      powerpc/85xx: Move gianfar mdio nodes under the ethernet nodes
      powerpc/86xx: Move gianfar mdio nodes under the ethernet nodes
      ucc_geth: Fix build breakage caused by a merge
      sdhci: Add support for bus-specific IO memory accessors
      sdhci: Split card-detection IRQs management from sdhci_init()
      sdhci: Enable only relevant (DMA/PIO) interrupts during transfers
      sdhci: Add support for card-detection polling
      sdhci: Add support for hosts reporting inverted write-protect state
      sdhci: Add set_clock callback and a quirk for nonstandard clocks
      sdhci: Add quirk for controllers that need small delays for PIO
      sdhci: Add quirk for controllers that need IRQ re-init after reset
      sdhci: Add quirk for forcing maximum block size to 2048 bytes
      mmc: Add OpenFirmware bindings for SDHCI driver
      ucc_geth: Fix three oopses in PHY {de,}initialization code
      spi_mpc83xx: fix sparse warnings
      spi_mpc83xx: rework chip selects handling
      spi_mpc83xx: add OF platform driver bindings
      powerpc: add mmc-spi-slot bindings
      powerpc/83xx: add mmc-spi support via the device tree for MPC8323E-=
RDB
      powerpc/fsl_soc: isolate legacy fsl_spi support to mpc832x_rdb boar=
ds
      ucc_geth: Pass proper device to DMA routines, otherwise oops happen=
s
      fsl_pq_mdio: Revive UCC MDIO support
      fsl-diu-fb: Pass the proper device for dma mapping routines
      PCI: Fix oops in pci_vpd_truncate
      ASoC: fsl_dma: Pass the proper device for dma mapping routines
      PCI: Fix oops in pci_vpd_truncate

Antonio Ospite (2):
      V4L/DVB (10344): gspca - ov534: Disable the Hercules webcams.
      V4L/DVB (10676): mt9m111: Call icl->reset() on mt9m111_reset().

Antti Palosaari (8):
      V4L/DVB (10286): af9015: add new USB ID for KWorld DVB-T 395U
      V4L/DVB (10329): af9015: remove dual_mode module param
      V4L/DVB (11215): zl10353: add support for Intel CE6230 and Intel CE=
6231
      V4L/DVB (11216): Add driver for Intel CE6230 DVB-T USB2.0
      V4L/DVB (11336): af9015: remove experimental
      V4L/DVB (11337): af9015: add new USB ID for KWorld USB DVB-T TV Sti=
ck II (VS-DVB-T 395U)
      V4L/DVB (11339): af9015: remove wrong definitions
      V4L/DVB (11340): af9015: add support for AverMedia AVerTV Volar Bla=
ck HD (A850)

Aravind Srinivasan (1):
      relay: fix for possible loss/corruption of produced subbufs

Aristeu Sergio Rozanski Filho (1):
      ALSA: hda: add quirk for Lenovo X200 laptop dock

Arjan van de Ven (14):
      x86: setup stack canary for the idle threads
      x86: add CONFIG_CC_STACKPROTECTOR self-test
      stackprotector: turn not having the right gcc into a #warning
      stackprotector: better self-test
      x86: simplify stackprotector self-check
      x86: don't pretend that non-framepointer stack traces are reliable
      sched, latencytop: incorporate review feedback from Andrew Morton
      genirq: add support for threaded interrupts to devres
      kobject: don't block for each kobject_uevent
      async: remove the temporary (2.6.29) "async is off by default" code
      ide/net: flip the order of SATA and network init
      module: create a request_module_nowait()
      drm/i915: clean up udelay usage
      ACPI: battery: asynchronous init

Arnaldo Carvalho de Melo (20):
      ftrace: add ftrace_vprintk
      blktrace: add ftrace plugin
      tracing/blktrace: fix up checkpatch reported problems in ftrace plu=
gin patch
      blktrace: the ftrace interface needs CONFIG_TRACING
      blktrace: Use tracing_reset_online_cpus
      trace: Use tracing_reset_online_cpus in more places
      trace_sched_wakeup: Remove unused variable
      trace: Change struct trace_event callbacks parameter list
      blkftrace: binary tracing, synthesizing old format
      blktrace: fix coding style in recent patches
      trace: judicious error checking of trace_seq results
      trace: make the trace_event callbacks return enum print_line_t
      trace: assign defaults at register_ftrace_event
      trace_branch: Remove unused function
      trace: Remove unused trace_array_cpu parameter
      ring_buffer: remove unused flags parameter
      tracing: Introduce trace_buffer_{lock_reserve,unlock_commit}
      trace: Call tracing_reset_online_cpus before tracer->init()
      tracing: handle unregistering the current tracer
      ring_buffer: pahole struct ring_buffer

Arnd Bergmann (9):
      powerpc/cell: Fix dependency in cpufreq
      powerpc/spufs: Initialize ctx->stats.tstamp correctly
      make exported headers use strict posix types
      make most exported headers use strict integer types
      make MTD headers use strict integer types
      make drm headers use strict integer types
      make netfilter use strict integer types
      remove __KERNEL_STRICT_NAMES
      emu101k1.h: fix duplicate include of <linux/types.h>

Arne Luehrs (1):
      V4L/DVB (10319): dib0700: enable IR receiver in Nova TD usb stick (=
52009)

Artem Bityutskiy (9):
      UBIFS: improve find function interface
      UBIFS: amend key_hash return value
      UBIFS: fix bogus assertion
      UBIFS: fix lprops committing bug
      UBIFS: use KERN_CONT
      UBIFS: introduce a helpful variable
      UBIFS: fix commentaries
      UBIFS: fully sort GCed nodes
      UBIFS: add R/O compatibility

Artem Makhutov (1):
      V4L/DVB (11248): Remove debug output from stb6100_cfg.h

Arthur Jones (3):
      e1000e: allow tx of pre-formatted vlan tagged packets
      e1000e: fixup merge error
      igb: allow tx of pre-formatted vlan tagged packets

Ashwin Ganti (1):
      Staging: add p9auth driver

Atsushi Nemoto (8):
      ASoC: Only deregister AC97 dev if it's name was not "AC97"
      [MTD] [NAND] TXx9: add NDFMC support
      [MTD] RBTX4939: add MTD support
      [MTD] TXx9 SoC NAND Flash Memory Controller driver
      [MTD] RBTX4939 map driver
      [MTD] mtdpart: Make all partition parsers return allocated array
      dmaengine: Add privatecnt to revert DMA_PRIVATE property
      tc35815: Fix build error if NAPI enabled

Atsushi SAKAI (1):
      md: fix typo in FSF address

Avi Kivity (27):
      KVM: MMU: Inherit a shadow page's guest level count from vcpu setup
      KVM: MMU: Segregate mmu pages created with different cr4.pge settin=
gs
      KVM: MMU: Initialize a shadow page's global attribute from cr4.pge
      KVM: Fix vmload and friends misinterpreted as lidt
      KVM: MMU: Add for_each_shadow_entry(), a simpler alternative to wal=
k_shadow()
      KVM: MMU: Use for_each_shadow_entry() in __direct_map()
      KVM: MMU: Replace walk_shadow() by for_each_shadow_entry() in fetch=
()
      KVM: MMU: Replace walk_shadow() by for_each_shadow_entry() in invlp=
g()
      KVM: MMU: Drop walk_shadow()
      KVM: Fallback support for MSR_VM_HSAVE_PA
      KVM: Move struct kvm_pio_request into x86 kvm_host.h
      KVM: VMX: Fix guest state validity checks
      KVM: VMX: don't clobber segment AR if emulating invalid state
      KVM: VMX: Prevent exit handler from running if emulating due to inv=
alid state
      KVM: x86 emulator: Make emulate_pop() a little more generic
      KVM: VMX: When emulating on invalid vmx state, don't return to user=
space unnecessarily
      KVM: x86 emulator: implement 'ret far' instruction (opcode 0xcb)
      KVM: Properly lock PIT creation
      KVM: MMU: Optimize page unshadowing
      KVM: Add CONFIG_HAVE_KVM_IRQCHIP
      KVM: Interrupt mask notifiers for ioapic
      KVM: Reset PIT irq injection logic when the PIT IRQ is unmasked
      KVM: MMU: Rename "metaphysical" attribute to "direct"
      KVM: MMU: Only enable cr4_pge role in shadow mode
      KVM: Userspace controlled irq routing
      KVM: Avoid using CONFIG_ in userspace visible headers
      KVM: VMX: Don't allow uninhibited access to EFER on i386

Avishay Traeger (1):
      block: Repeated lines in switching-sched.txt

Ayaz Abdulla (18):
      forcedeth: mgmt unit interface
      forcedeth: msi interrupt fix
      forcedeth: ethtool tx csum fix
      forcedeth: recover error support
      forcedeth: bump version to 63
      forcedeth: fix stats version feature
      forcedeth: fix missing napi enable/disable calls
      forcedeth: remove msix + napi
      forcedeth: save irq events for napi processing
      forcedeth: remove overhead
      forcedeth: add/modify tx done with limit
      forcedeth: napi - handle all processing
      forcedeth: add new optimization mode
      forcedeth: remove isr processing loop
      forcedeth: add interrupt moderation logic
      forcedeth: performance changes
      forcedeth: fix irq clearing and napi spin lock changes
      forcedeth: version bump to 64

Balaji Rao (1):
      mmc: During unsafe resume, select the right volatge for the card

Balbir Singh (1):
      memcg: show memcg information during OOM

Baodong Chen (1):
      Documentation/x86/boot.txt: modify fieldname

Bart Joris (1):
      Staging: comedi: add ni_670x driver

Bart Van Assche (1):
      branch tracer: Fix for enabling branch profiling makes sparse unusa=
ble

Bartlomiej Zolnierkiewicz (171):
      x86: fix IO APIC resource allocation error message
      ide: fix IDE_DFLAG_NO_IO_32BIT handling
      ide: move ide_pktcmd_tf_load() to ide-atapi.c
      ide: no need to touch local IRQs in ide_probe_port()
      ide: move ->lock and ->timer init from init_irq() to ide_init_port_=
data()
      ide: init_irq() doesn't need to hold ide_cfg_mtx
      ide: remove superfluous check from ide_proc_port_register_devices()
      ide-acpi: no need to zero ->acpidata for devices
      ide-acpi: init ACPI handles early for devices
      ide: add ide_for_each_present_dev() iterator
      ide: sanitize ACPI initialization
      ide-acpi: cleanup do_drive_get_GTF()
      ide-acpi: cleanup do_drive_set_taskfiles()
      ide-acpi: remove taskfile_load_raw()
      ide: remove stale comments from drive_is_ready()
      ide: unexport ide_devset_execute()
      ide: move drive_is_ready() to ide-io.c
      ide: move ide_dma_timeout_retry() to ide-dma.c
      ide: remove ide_do_drive_cmd()
      ide: factor out processing of special commands from ide_special_rq(=
)
      ide: move ide_do_park_unpark() to ide-park.c
      ide: move device settings code to ide-devsets.c
      ide: move xfer mode tuning code to ide-xfer-mode.c
      ide: move ide_read_bcount_and_ireason() to ide-atapi.c
      ide: move standard I/O code to ide-io-std.c
      ide: fix printk() levels in [atapi_]reset_pollfunc()
      ide: fix comments in ide_config_drive_speed()
      ide: checkpatch.pl fixes for ide-iops.c
      ide: move error handling code to ide-eh.c (v2)
      mn10300: add pci_get_legacy_ide_irq() to <asm/pci.h>
      amd74xx: use ide_pci_is_in_compatibility_mode()
      ns87415: use pci_get_legacy_ide_irq()
      ns87415: small ->init_hwif cleanup
      trm290: small ->init_hwif cleanup
      ide: handle IDE_HFLAG[_FORCE]_LEGACY_IRQS in ide_pci_init_{one,two}=
()
      ide: use pci_get_legacy_ide_irq() in ide_pci_init_{one,two}()
      ide: use ide_pci_is_in_compatibility_mode() in ide_pci_init_{one,tw=
o}()
      ide: remove no longer needed IDE_HFLAG[_FORCE]_LEGACY_IRQS
      amd74xx: remove no longer needed ->init_hwif method
      ide: remove no longer needed IRQ fallback code from hwif_init()
      ide: remove no longer needed IRQ auto-probing from try_to_identify(=
) (v2)
      ide: remove try_to_identify() wrapper
      ide: fix ->init_chipset method to return 'int' value
      ide: remove pciirq argument from ide_pci_setup_ports()
      frv: remove <asm/ide.h>
      mn10300: remove <asm/ide.h>
      ide: fix kmalloc() failure handling in ide_driveid_update()
      ide: propagate AltStatus workarounds to ide_driveid_update()
      ide: shorten timeout value in ide_driveid_update()
      ide: remove broken EXABYTENEST support
      ide: classify device type in do_probe()
      ide: sanitize SELECT_MASK() usage in ide_driveid_update()
      ide: clear drive IRQ after re-enabling local IRQs in ide_driveid_up=
date()
      ide: use try_to_identify() in ide_driveid_update()
      icside: use struct ide_port_info also for PCB version 5 (v2)
      ide_arm: use struct ide_port_info
      ide-generic: use struct ide_port_info
      ide-pnp: use struct ide_port_info
      buddha: use struct ide_port_info
      macide: use struct ide_port_info
      ide: move ->rqsize init from init_irq() to ide_init_port()
      ide: remove IDE_ARCH_INTR (v2)
      ide: remove IDE_ARCH_LOCK (v2)
      ide: make m68k host drivers use IDE_HFLAG_MMIO
      ide: cleanup <asm-m68k/ide.h>
      at91_ide: use readsw()/writesw() directly
      ide: include <asm/ide.h> only when needed
      scc_pata: remove DECLARE_SCC_DEV() macro (v2)
      ide: fix memleak on failure in probe_for_drive()
      ide: fix error message in pre_task_out_intr()
      ide: allow host drivers to specify IRQ flags
      ide: remove now superfluous check from ide_host_register()
      ide: add IDE_HFLAG_DTC2278 host flag
      ide: add IDE_HFLAG_4DRIVES host flag
      ide: add "flagged" taskfile flags to struct ide_taskfile (v2)
      ide: complete power step in ide_complete_pm_request()
      ide: factor out completion of taskfile from ide_end_drive_cmd()
      ide: move request type specific code from ide_end_drive_cmd() to ca=
llers (v3)
      ide: no need to read Status and Error registers for "empty" taskfil=
e requests
      ide: remove ->data_phase field from ide_hwif_t
      ide: move smart_enable() call out from get_smart_data()
      icside: icside_dma_setup() fixes
      trm290: trm290_dma_setup() fix
      au1xxx-ide: auide_dma_end() cleanup
      ide: remove no longer needed PC_FLAG_TIMEDOUT packet command flag
      ide-floppy: remove superfluous check from ide_floppy_end_request()
      ide-tape: remove superfluous tape->lock
      ide: move ->failed_pc to ide_drive_t
      ide: use ->end_request only for private device driver requests
      ide-{floppy,tape}: cleanup ide*_end_request()
      ide: remove ->end_request method
      ide: return request status from ->pc_callback method
      ide: use blk_fs_request() check in ide-taskfile.c
      ide: call ide_build_sglist() prior to ->dma_setup (v2)
      ide: remove ide_task_t typedef
      ide: pass command instead of request to ide_pio_datablock()
      ide: move command related fields from ide_hwif_t to struct ide_cmd
      ide: set IDE_TFLAG_WRITE basing on data phase used in ide_taskfile_=
ioctl()
      ide: use ata_tf_protocols enums
      ide: merge task_{in,out}_intr()
      ide: inline task_in_unexpected() into task_pio_intr()
      ide: unify exit paths in task_pio_intr()
      ide: task_error() -> task_error_cmd()
      ide: use ide_complete_cmd() for head unload commands
      ide: use ide_complete_cmd() for REQ_UNPARK_HEADS
      ide: sanitize ide_finish_cmd()
      ide: make ide_special_rq() BUG() on unknown requests
      ide: add ide_end_rq() (v2)
      ide: sanitize ide_end_rq()
      ide: pass error value to ide_complete_rq()
      ide: move rq->errors quirk out from ide_end_request()
      ide: remove BUG() from ide_complete_rq()
      ide: pass number of bytes to complete to ide_complete_rq()
      ide: use ide_end_rq() in ide_complete_rq()
      ide: remove ide_end_request()
      ide: pass command to ide_map_sg()
      ide: use do_rw_taskfile() for ATA_CMD_PACKET commands
      ide: set hwif->expiry prior to calling [__]ide_set_handler()
      ide: add ->dma_timer_expiry method and remove ->dma_exec_cmd one (v=
2)
      ide: remove ide_execute_pkt_cmd() (v2)
      ide: keep track of number of bytes instead of sectors in struct ide=
_cmd
      at91_ide: fix ->ftf_flags handling
      ide: add support for arbitrary transfer lengths to ide_pio_bytes()
      ide: use PageHighMem() instead of ifdefs in ide_pio_bytes()
      ide-cd: remove dead URLs
      ide-cd: use ide_end_rq() also for failed non-fs requests
      ide-cd: remove dead code from cdrom_decode_status()
      ide-cd: remove needless ide_dump_status_no_sense() wrapper
      ide-cd: remove no longer needed 'ignore' module parameter
      ide-cd: factor out failed request completion from cdrom_end_request=
()
      ide-cd: unify ide_cd_do_request() exit paths
      ide-cd: move setting REQ_FAILED flag out from 'end_request' exit pa=
th
      ide-cd: unify cdrom_newpc_intr() exit paths
      ide-cd: remove cdrom_end_request()
      ide-cd: kill whole failed request in ide_cd_do_request()
      ide-cd: cleanup ide_cd_do_request()
      ide-cd: use scatterlists for PIO transfers (fs requests)
      ide-cd: fix non-SECTOR_SIZE-multiples PIO transfers for fs requests
      ide-cd: merge ide_cd_prepare_rw_request() into cdrom_start_rw()
      ide-cd: use scatterlists for PIO transfers (non-fs requests) (v2)
      ide-cd: use common completion path for DMA requests in cdrom_newpc_=
intr()
      ide-cd: unify transfer padding in cdrom_newpc_intr()
      ide-cd: minor ide_cdrom_setup() cleanup
      ide: add ->dma_clear method and remove ->dma_timeout one
      ide: inline ide_dma_timeout() into ide_dma_timeout_retry()
      ide: destroy DMA mappings after ending DMA (v2)
      ide: add ide_dma_prepare() helper
      ns87415: use custom ->dma_{start,end} to handle ns87415_prepare_dri=
ve()
      trm290: use custom ->dma_{start,end} to handle trm290_prepare_drive=
()
      ide: add ->dma_check method
      ide: move ide_map_sg() call out of ->dma_setup method (take 2)
      ide: set/clear drive->waiting_for_dma flag in the core code
      ide: sanitize ide_build_sglist() and ide_destroy_dmatable()
      ide-generic: remove no longer needed sysfs interface
      ide: merge ide_arm and ide_generic host drivers
      ide: fix locking in drive_release_dev()
      ide: decrease size of ->pc_buf field in struct ide_atapi_pc
      ide: remove CONFIG_BLK_DEV_IDEDOUBLER config option
      ide-{floppy,tape}: fix padding for PIO transfers
      ide-floppy: use ide_pio_bytes()
      MAINTAINERS: move old ide-{floppy,tape} entries to CREDITS (take 2)
      isd200: make it 'struct hd_driveid'-free
      ubd_kern: make it 'struct hd_driveid'-free
      xsysace: make it 'struct hd_driveid'-free
      include/linux/hdreg.h: cover struct hd_driveid with #ifndef/#endif =
__KERNEL__
      isd200: WIN_* -> ATA_CMD_*
      aoe: WIN_* -> ATA_CMD_*
      include/linux/hdreg.h: cover WIN_* and friends with #ifndef/#endif =
__KERNEL__
      isd200: use ATA_* defines instead of *_STAT and *_ERR ones
      include/linux/hdreg.h: remove unused defines
      remove <linux/ata.h> include from <linux/hdreg.h>

Beat Michel Liechti (1):
      DVB: firedtv: FireDTV S2 problems with tuning solved

Ben Dooks (37):
      ASoC: Fix copyright statements on Simtec files
      S3C24XX: Move and update IIS headers
      S3C: Move <mach/audio.h> to <plat/audio.h>
      ASoC: Add JIVE audio support
      ASoC: Split s3c2412-i2s.c into core and SoC specific parts
      ASoC: Add s3c64xx-i2s support
      ASoC: Select DMA if I2S is configured
      [ARM] S3C: Nove <plat/pm.h> from plat-s3c24xx to plat-s3fc
      [ARM] S3C: Move PM support functions to common location
      [ARM] S3C: Split the resume memory check code from pm.c
      [ARM] S3C: Move plat-s3c24xx pm.c support into plat-s3c
      [ARM] S3C: Fix warnings in the PM memory CRC code
      [ARM] S3C24XX: Split PM code from arch/arm/plat-s3c24xx/irq.c
      [ARM] S3C24XX: Remove changelog from arch/arm/plat-s3c24xx/irq.c
      [ARM] S3C: Make IRQ_EINT sleep control common
      [ARM] S3C: Rename s3c2410_pm_init to s3c_pm_init.
      [ARM] S3C: Rename sleep.S functions to be non-cpu specific
      [ARM] S3C: Update UART save over PM suspend/resume
      [ARM] S3C24XX: Add S3C_GPIO_END definition
      [ARM] S3C: Avoid checking the task stackpage in pm-check
      [ARM] S3C: Do not kmalloc/kfree during inner suspend code.
      ASoC: Fix Samsung S3C2412_IISMOD_SDF_{MSB,LSB} definitions
      [ARM] S3C: Tidy sleep code path to fix call flow
      [ARM] S3C64XX: Add modem registers and a virtual map
      [ARM] S3C64XX: Add EINT group regs and move IRQ_EINT to regs-gpio.h
      [ARM] S3C64XX: Add GPIO SPCONSLP and SLPEN register definitions
      [ARM] S3C64XX: Add S3C64XX_SPCON register bit definitions
      [ARM] S3C64XX: SYSCON power and sleep control register defines
      [ARM] S3C64XX: Add definitions for the GPIO memory port configurati=
ons
      [ARM] S3C64XX: add AHB_CON and SPCON register address definitions
      sdhci: Add get_{max,timeout}_clock callbacks
      USB: ohci-s3c2410: remove <mach/hardware.h> include
      USB: ohci-s3c2410: fix name of bus clock
      USB: ohci-hcd: Add ARCH_S3C24XX to the ohci-s3c2410.c glue
      USB: S3C: Move usb-control.h to platform include
      fb: add s3c-fb driver for newer Samsung SoC framebuffer devices
      i2c-s3c2410: sda_delay should be in ns, not clock ticks

Ben Gamari (5):
      drm: Convert proc files to seq_file and introduce debugfs
      drm/i915: Consolidate gem object list dumping
      drm: Convert proc files to seq_file and introduce debugfs
      drm/i915: Convert i915 proc files to seq_file and move to debugfs.
      drm/i915: Consolidate gem object list dumping

Ben Hutchings (25):
      net: Remove redundant NAPI functions
      tehuti: Use request_firmware()
      typhoon: Use request_firmware()
      sfc: SFT9001: Include non-breaking cable diagnostics in online self=
-tests
      sfc: Fix test for MDIO read failure
      sfc: SFT9001/SFN4111T: Check PHY boot status during board initialis=
ation
      sfc: Remove "XFP" from log messages that are not specific to XFP
      sfc: Fix reporting of PHY id
      sfc: Add support for QT2025C PHY
      sfc: Delete unused efx_blinker::led_num field
      sfc: Clean up LED control
      sfc: Add support for SFN4112F SFP+ reference design
      sfc: Fix efx_ethtool_nway_result() to use clause 45 MDIO registers
      sfc: Reject packets from the kernel TX queue during a loopback self=
-test
      sfc: Clean up properly on reset failure paths
      sfc: Clear I2C adapter structure in falcon_remove_nic()
      sfc: Don't wake TX queues while they're being flushed
      sfc: Fix search for flush completion events
      sfc: Improve NIC internal error recovery
      sfc: Pad packets to 33 bytes to prevent TX packet parser lockup
      sfc: Work around unreliable legacy interrupt status
      sfc: Remove unused private PCI register definitions
      sfc: Optimise falcon_writel_page_locked() for page > 0
      sfc: Implement adaptive IRQ moderation
      sfc: Call netif_napi_add() before registering our interrupt handler

Ben Nizette (1):
      avr32: Fix out-of-range rcalls in large kernels

Benjamin Herrenschmidt (34):
      Merge commit 'kumar/next' into next
      Merge commit 'gcl/next' into next
      powerpc/mm: Rework I$/D$ coherency (v3)
      powerpc/4xx: Add missing USB and i2c devices to Canyonlands
      powerpc/4xx: Enable PCI domains on 4xx
      Merge commit 'origin/master' into next
      Merge commit 'kumar/next' into next
      Merge commit 'ftrace/function-graph' into next
      Merge commit 'jwb/next' into next
      Merge commit 'gcl/next' into next
      Merge commit 'origin/master' into next
      powerpc: Wire up /proc/vmallocinfo to our ioremap()
      powerpc/mm: Properly wire up get_user_pages_fast() on 32-bit
      powerpc/kconfig: Kill PPC_MULTIPLATFORM
      drm: Use resource_size_t for drm_get_resource_{start, len}
      drm: Split drm_map and drm_local_map
      drm: Make drm_local_map use a resource_size_t offset
      drm/radeon: Print PCI ID of cards when probing
      powerpc/mm: Split the various pgtable-* headers based on MMU type
      powerpc/mm: Unify PTE_RPN_SHIFT and _PAGE_CHG_MASK definitions
      Merge commit 'kumar/next' into next
      Merge commit 'gcl/next' into next
      Merge commit 'origin/master' into next
      powerpc: Fix prom_init on 32-bit OF machines
      powerpc/mm: Tweak PTE bit combination definitions
      powerpc/mm: Merge various PTE bits and accessors definitions
      powerpc/mm: Rename arch/powerpc/kernel/mmap.c to mmap_64.c
      powerpc/mm: Fix printk type warning in mmu_context_nohash
      powerpc/mm: Add option for non-atomic PTE updates to ppc64
      powerpc/mm: Introduce early_init_mmu() on 64-bit
      powerpc: Fix bugs introduced by sysfs changes
      Merge commit 'kumar/next' into next
      Merge commit 'origin/master' into next
      powerpc/pmac: Fix internal modem IRQ on Wallstreet PowerBook

Benjamin Krill (2):
      powerpc/cell: Add rtas rtc calls for the QPACE platform
      [MTD] ofpart: Check name property to determine partition nodes.

Benjamin LaHaise (1):
      x86-64: remove locked instruction from switch_to()

Benjamin Marzinski (1):
      GFS2: Fix locking bug in failed shared to exclusive conversion

Benjamin Thery (9):
      netns: ipmr: allocate mroute_socket per-namespace.
      netns: ipmr: dynamically allocate vif_table
      netns: ipmr: store netns in struct mfc_cache
      netns: ipmr: dynamically allocate mfc_cache_array
      netns: ipmr: declare counter cache_resolve_queue_len per-namespace
      netns: ipmr: declare mroute_do_assert and mroute_do_pim per-namespa=
ce
      netns: ipmr: declare reg_vif_num per-namespace
      netns: ipmr: declare ipmr /proc/net entries per-namespace
      netns: ipmr: enable namespace support in ipv4 multicast routing cod=
e

Benny Halevy (14):
      NFSD: return nfsv4 error code nfserr_notsupp rather than nfsv[23]'s=
 nfserr_opnotsupp
      nfsd: remove nfsd4_ops array size
      nfs41: common protocol definitions
      nfsd41: sequence operation
      nfsd41: destroy_session operation
      nfsd: pass nfsd4_compound_state* to nfs4_preprocess_{state,seq}id_o=
p
      nfsd41: control nfsv4.1 svc via /proc/fs/nfsd/versions
      nfsd41: pass writable attrs mask to nfsd4_decode_fattr
      nfsd: dynamically skip encoded fattr bitmap in _nfsd4_verify
      nfsd41: SUPPATTR_EXCLCREAT attribute
      nfsd41: CREATE_EXCLUSIVE4_1
      nfsd41: Documentation/filesystems/nfs41-server.txt
      nfsd41: define NFSD_DRC_SIZE_SHIFT in set_max_drc
      nfsd41: define nfsd4_set_statp as noop for !CONFIG_NFSD_V4

Bernard Pidoux (3):
      ax25: SOCK_DEBUG message simplification
      ax25: zero length frame filtering in AX25
      netrom: zero length frame filtering in NetRom

Bernd Porr (4):
      Staging: comedi: add comedi_num_legacy_minors module parameter
      Staging: comedi: add comedi_usb_auto_[un]config functions
      Staging: comedi: usbdux[fast] firmware upload changes
      Staging: comedi: usbduxfast: fix run-time error

Bernd Schmidt (1):
      [MTD] Fix a bad dependency in the Blackfin code

Bill Pemberton (227):
      Staging: comedi: Convert C99 style comments to traditional style co=
mments
      Staging: comedi: Change "foo * bar" to "foo *bar"
      Staging: comedi: Add spaces after commas where suggested by checkpa=
tch.pl
      Staging: comedi: Add spaces around colons as needed
      Staging: comedi: Add spaces around parens as requested by checkpatc=
h.pl
      Staging: comedi: Remove instances of assignments in conditionals
      Staging: comedi: Move trailing statements to next line as requested=
 by checkpatch
      Staging: comedi: Fix cases of open curly on wrong line
      Staging: comedi: Add spaces around colons as requested by checkpatc=
h
      Staging: comedi: Misc code cleanups for checkpatch
      Staging: comedi: Remove checks for NULL before calling kfree()
      Staging: comedi: Remove curly braces where they are not needed
      Staging: comedi: Remove comedi32_chaninfo_struct typedef
      Staging: comedi: Remove boardtype typedef
      Staging: comedi: Remove rtdBoard typedef
      Staging: comedi: Remove s626_board typedef
      Staging: comedi: Remove V_FP_V typedef
      Staging: comedi: Remove comedi_t typedef
      Staging: comedi: Remove lsampl_t and sampl_t typedefs
      Staging: comedi: Remove comedi_device typedef
      Staging: comedi: Remove comedi_subdevice typedef
      Staging: comedi: Remove comedi_async typedef
      Staging: comedi: Remove comedi_driver typedef
      Staging: comedi: Remove comedi_lrange typedef
      Staging: comedi: Remove device_create_result_type typedef
      Staging: comedi: Remove comedi_trig typedef
      Staging: comedi: Remove comedi_cmd typedef
      Staging: comedi: Remove comedi_insn typedef
      Staging: comedi: Remove comedi_insnlist typedef
      Staging: comedi: Remove comedi_chaninfo typedef
      Staging: comedi: Remove comedi_subdinfo typedef
      Staging: comedi: Remove comedi_devinfo typedef
      Staging: comedi: Remove comedi_devconfig typedef
      Staging: comedi: Remove comedi_rangeinfo typedef
      Staging: comedi: Remove comedi_krange typedef
      Staging: comedi: Remove comedi_bufconfig typedef
      Staging: comedi: Remove comedi_bufinfo typedef
      Staging: comedi: Remove DMABUF typedef
      Staging: comedi: Remove pci6208_board typedef
      Staging: comedi: Remove pci6208_private typedef
      Staging: comedi: Remove adl_pci7296_private typedef
      Staging: comedi: Remove adl_pci7432_private typedef
      Staging: comedi: Remove adl_pci8164_private typedef
      Staging: comedi: Remove pci9111_board_struct typedef
      Staging: comedi: Remove pci9111_private_data typedef
      Staging: comedi: Remove pci9111_trigger_sources typedef
      Staging: comedi: Remove pci9111_ISC0_sources typedef
      Staging: comedi: Remove C99 style comments in adl_pci9111.c
      Staging: comedi: Remove boardtype typedef in adl_pci9118.c
      Staging: comedi: Remove pci9118_private typedef
      Staging: comedi: Remove adq12b_board typedef
      Staging: comedi: Remove adq12b_private typedef
      Staging: comedi: Remove boardtype typedef in adv_pci1710.c
      Staging: comedi: Remove pci1710_private typedef
      Staging: comedi: Remove boardtype and pci1723_private typedefs in a=
dv_pci1723.c
      Staging: comedi: Remove hw_cards_id and hw_io_access typedefs in ad=
v_pci_dio.c
      Staging: comedi: Remove diosubd_data typedef
      Staging: comedi: Remove boardtype typedef in adv_pci_dio.c
      Staging: comedi: Remove C99 style comments in adv_pci_dio.c
      Staging: comedi: Remove pci_dio_private typedef
      Staging: comedi: Remove board_type typedef in aio_aio12_8.c
      Staging: comedi: Remove aio12_8_private typedef
      Staging: comedi: Remove counter_mode_register_t typedef
      Staging: comedi: Remove aio_iiro_16_board typedef
      Staging: comedi: Remove aio_iiro_16_private typedef
      Staging: comedi: Remove dio200_board typedef
      Staging: comedi: Remove dio200_layout typedef
      Staging: comedi: Remove dio200_private typedef
      Staging: comedi: Remove dio200_subdev_8254 typedef
      Staging: comedi: Remove dio200_subdev_intr typedef
      Staging: comedi: Remove pc236_board typedef
      Staging: comedi: Remove pc236_private typedef
      Staging: comedi: Remove pc263_board typedef
      Staging: comedi: Remove pc263_private typedef
      Staging: comedi: Remove pci224_board typedef
      Staging: comedi: Remove pci224_private typedef
      Staging: comedi: Remove pci230_board typedef
      Staging: comedi: Remove das16cs_board typedef
      Staging: comedi: Remove das16cs_private typedef
      Staging: comedi: Remove local_info_t typedef
      Staging: comedi: Remove cb_pcidas_board typedef
      Staging: comedi: Remove cb_pcidas_private typedef
      Staging: comedi: Remove cb_pcidda_board typedef
      Staging: comedi: Remove cb_pcidda_private typedef
      Staging: comedi: Remove pcidio_board typedef
      Staging: comedi: Remove pcidio_private typedef
      Staging: comedi: Remove cb_pcimdas_board typedef
      Staging: comedi: Remove timer_private typedef
      Staging: comedi: Remove board_struct typedef
      Staging: comedi: Remove typedef private in cb_pcimdda.c
      Staging: comedi: Remove contec_board typedef
      Staging: comedi: Remove contec_private typedef
      Staging: comedi: Remove contec_model typedef
      Staging: comedi: Remove daqboard2000_hw typedef
      Staging: comedi: Remove boardtype typedef in daqboard2000.c
      Staging: comedi: Remove daqboard2000_private typedef
      Staging: comedi: Remove local_info_t typedef in das08_cs.c
      Staging: comedi: Remove das16_board typedef
      Staging: comedi: Replace C99 comments in jr3_pci.h
      Staging: comedi: Remove u_val_t typedef
      Staging: comedi: Remove s_val_t typedef
      Staging: comedi: Remove raw_channel typedef
      Staging: comedi: Remove force_array_t typedef
      Staging: comedi: Remove six_axis_array_t typedef
      Staging: comedi: Remove vect_bits_t, warning_bits_t, and error_bits=
_t typedefs
      Staging: comedi: Remove thresh_struct typedef
      Staging: comedi: Remove le_struct_t typedef
      Staging: comedi: Remove jr3_t typedef
      Staging: comedi: Remove link_types typedef
      Staging: comedi: Remove intern_transform_t typedef
      Staging: comedi: Remove jr3_channel_t typedef
      Staging: comedi: Remove das16m1_board typedef
      Staging: comedi: Remove das800_board typedef
      Staging: comedi: Remove das1800_board typedef
      Staging: comedi: Remove das1800_private typedef
      Staging: comedi: Remove das6402_private typedef
      Staging: comedi: Remove dmm32at_board typedef
      Staging: comedi: Remove dmm32at_private typedef
      Staging: comedi: Remove boardtype_t typedef in dt282x.c
      Staging: comedi: Remove dt282x_private typedef
      Staging: comedi: Remove boardtype_t typedef in dt2801.c
      Staging: comedi: Remove boardtype typedef in pcl818.c
      Staging: comedi: Remove dt2801_private typedef
      Staging: comedi: Remove dt2814_private typedef
      Staging: comedi: Remove dt2815_private typedef
      Staging: comedi: Remove dt3k_boardtype typedef
      Staging: comedi: Remove fl512_private typedef
      Staging: comedi: Remove hpdi_board typedef
      Staging: comedi: Remove pci20xxx_private typedef
      Staging: comedi: Remove jr3_pci_dev_private typedef
      Staging: comedi: Remove cnt_board_struct typedef
      Staging: comedi: Remove skel_private typedef
      Staging: comedi: Remove mpc8260cpm_private typedef
      Staging: comedi: Remove ni6527_board typedef
      Staging: comedi: Remove ni_65xx_board typedef
      Staging: comedi: Remove NI_660xRegisterData typedef
      Staging: comedi: Remove ni_670x_private typedef
      Staging: comedi: Remove a2150_private typedef
      Staging: comedi: Remove atao_private typedef
      Staging: comedi: Remove atmio16_board_t typedef
      Staging: comedi: Remove dio700_private typedef
      Staging: comedi: Remove dio24_private typedef
      Staging: comedi: Remove ni_private typedef
      Staging: comedi: Remove nidio_board typedef
      Staging: comedi: Remove pcl818_private typedef
      Staging: comedi: Remove pcmda12_private typedef
      Staging: comedi: Remove s526_private typedef
      Staging: comedi: Remove serial2002_private typedef
      Staging: comedi: Remove dnp_private_data typedef
      Staging: comedi: Remove comment mentioning typedefs
      Staging: comedi: Remove dt3k_private typedef
      Staging: comedi: Remove hpdi_private typedef
      Staging: comedi: Remove poll_delay_t typedef
      Staging: comedi: Remove cnt_device_private typedef
      Staging: comedi: Remove pcl711_private typedef
      Staging: comedi: Remove pcl726_private typedef
      Staging: comedi: Remove pcl812_private typedef
      Staging: comedi: Remove dt2811_private typedef
      Staging: comedi: Remove pcmmio_board typedef
      Staging: comedi: Remove pcmuio_board typedef
      Staging: comedi: Remove rti800_private typedef
      Staging: comedi: Remove rti802_private typedef
      Staging: comedi: Remove config_t typedef
      Staging: comedi: Remove pci20xxx_subdev_private typedef
      Staging: comedi: Remove pcmmio_subdev_private typedef
      Staging: comedi: Remove pcmuio_subdev_private typedef
      Staging: comedi: Remove pcmda12_board typedef
      Staging: comedi: Remove S526_GPCT_APP_CLASS typedef
      Staging: comedi: Remove serial2002_board typedef
      Staging: comedi: Remove skel_board typedef
      Staging: comedi: Remove dnp_board typedef
      Staging: comedi: Remove unioxx5_subd_priv typedef
      Staging: comedi: Remove jr3_pci_subdev_private typedef
      Staging: comedi: Remove pcmmio_private typedef
      Staging: comedi: Remove pcmuio_private typedef
      Staging: comedi: Remove s526_gpct_config_t typedef
      Staging: comedi: Remove transform_t typedef
      Staging: comedi: Remove s526_board typedef
      Staging: comedi: Remove six_axis_t typedef
      Staging: comedi: Remove priv_pcm3724 typedef
      Staging: comedi: Remove pcl816_private typedef
      Staging: comedi: acl7225b: Remove boardtype typedef
      Staging: comedi: cb_pcimdas: Remove timer_private typedef
      Staging: comedi: das800: Remove das800_board typedef
      Staging: comedi: dt2811: Remove boardtype typedef
      Staging: comedi: pcl711: Remove boardtype typedef
      Staging: comedi: pcl724: Remove boardtype typedef
      Staging: comedi: pcl726: Remove boardtype typedef
      Staging: comedi: pcl730: Remove boardtype typedef
      Staging: comedi: pcl812: Remove boardtype typedef
      Staging: comedi: pcl816: Remove boardtype typedef
      Staging: comedi: pcm3724: Remove boardtype typedef
      Staging: comedi: rti800: Remove boardtype typedef
      Staging: comedi: skel.c: Remove skel_private typedef
      Staging: comedi: serial2002: Remove serial2002_private typedef
      Staging: comedi: quatech_daqp_cs: Remove local_info_t typedef
      Staging: comedi: Remove 2.4 irqreturn_t compatibility in comedi/int=
errupt.h
      Staging: comedi: Remove hw_fifo_info_t typedef
      Staging: comedi: Remove pcidas64_board typedef
      Staging: comedi: Remove pcidas64_private typedef
      Staging: comedi: comedi: remove C99 comments in skel.c
      Staging: comedi: Remove ni6527_private typedef
      Staging: comedi: Remove ni_65xx_private typedef
      Staging: comedi: Remove ni_65xx_subdevice_private typedef
      Staging: comedi: Remove NI_660x_Register typedef
      Staging: comedi: Remove ni_660x_board typedef
      Staging: comedi: Remove ni_660x_private typedef
      Staging: comedi: Remove ni_670x_board typedef
      Staging: comedi: Remove a2150_board typedef
      Staging: comedi: Remove atao_board typedef
      Staging: comedi: Remove atmio16d_private typedef
      Staging: comedi: Remove dio700_board typedef
      Staging: comedi: ni_daq_700.c: Remove local_info_t typedef
      Staging: comedi: Remove nidio96_private typedef
      Staging: comedi: Remove das08_board typedef
      Staging: comedi: Remove me4000_ao_info_t typedef
      Staging: comedi: Remove me4000_ai_info_t typedef
      Staging: comedi: Remove me4000_dio_info_t typedef
      Staging: comedi: Remove me4000_cnt_info_t typedef
      Staging: comedi: Remove me4000_board_t typedef
      Staging: comedi: Remove me4000_ao_context_t typedef
      Staging: comedi: Remove me4000_ai_context_t typedef
      Staging: comedi: Remove me4000_dio_context_t typedef
      Staging: comedi: Remove me4000_cnt_context_t typedef
      Staging: comedi: Remove me4000_info_t typedef
      Staging: comedi: Remove use of VOID typedef in addi-data
      Staging: comedi: Remove CHAR, *PCHAR, and *PCSTR typedefs in addi-d=
ata

Bing Zhao (1):
      libertas: fix power save issue in libertas_sdio module

Bjorn Helgaas (27):
      ACPI: pci_link: clean up whitespace
      ACPI: pci_link: remove unnecessary casts and initializations
      ACPI: pci_link: remove unnecessary null pointer checks
      ACPI: pci_link: simplify list of link devices
      ACPI: PCI: use generic pci_swizzle_interrupt_pin()
      ACPI: update Kconfig help texts (no functional changes)
      ACPI: move private declarations to internal.h
      PCI/x86: make early dump handle multi-function devices
      PCI/x86: format early dump like other PCI output
      PCI/x86: document pci=3Dearlydump argument
      x86: use dev_printk in quirk message
      ACPI: skip DMI power state check when ACPI disabled
      ACPI: call acpi_scan_init() explicitly rather than as initcall
      ACPI: call acpi_ec_init() explicitly rather than as initcall
      ACPI: call acpi_power_init() explicitly rather than as initcall
      ACPI: call acpi_system_init() explicitly rather than as initcall
      ACPI: call acpi_debug_init() explicitly rather than as initcall
      ACPI: call init_acpi_device_notify() explicitly rather than as init=
call
      ACPI: call acpi_sleep_proc_init() explicitly rather than as initcal=
l
      ACPI: call acpi_wakeup_device_init() explicitly rather than as init=
call
      ACPI: tidy up makefile
      ACPI: remove unused acpi_device_ops .lock and .scan methods
      ACPI: remove unused acpi_device_ops .shutdown method
      ACPI: remove unused acpi_bus_ops flags
      ACPI: support acpi_device_ops .notify methods
      ACPI: button: use .notify method instead of installing handler dire=
ctly
      ACPI: processor: use .notify method instead of installing handler d=
irectly

Blaine Lee (1):
      Staging: comedi: add pcm3730 driver

Boaz Harrosh (32):
      [SCSI] major.h: char-major number for OSD device driver
      [SCSI] add OSD_TYPE
      [SCSI] libosd: OSDv1 Headers
      [SCSI] libosd: OSDv1 preliminary implementation
      [SCSI] osd_uld: OSD scsi ULD
      [SCSI] osd_uld: API for retrieving osd devices from Kernel
      [SCSI] libosd: attributes Support
      [SCSI] libosd: OSD Security processing stubs
      [SCSI] libosd: Add Flush and List-objects support
      [SCSI] libosd: Not implemented commands
      [SCSI] libosd: OSD version 2 Support
      [SCSI] libosd: OSDv2 auto detection
      [SCSI] libosd: SCSI/OSD Sense decoding support
      [SCSI] osd: Documentation for OSD library
      [SCSI] osd: Kconfig file for in-tree builds
      [SCSI] scsi: Add osd library to build system
      [SCSI] libosd: Fix NULL dereference BUG when target is not OSD conf=
ormant
      bsg: add support for tail queuing
      USB: fix USB_STORAGE_CYPRESS_ATACB
      block: WARN in __blk_put_request() for potential bio leak
      bsg: Remove bogus check against request_queue->max_sectors
      exofs: Kbuild, Headers and osd utils
      exofs: file and file_inode operations
      exofs: symlink_inode and fast_symlink_inode operations
      exofs: address_space_operations
      exofs: dir_inode and directory operations
      exofs: super_operations and file_system_type
      exofs: export_operations
      exofs: Documentation
      fs: Add exofs to Kernel build
      [SCSI] libosd: fix blk_put_request called from within request_end_i=
o
      [SCSI] osd_uld: Remove creation of osd_scsi class symlink

Bob Copeland (29):
      ath5k: support LEDs on Acer Aspire One netbook
      ath5k: fix off-by-one in gpio checks
      mac80211: document return codes from ops callbacks
      ath5k: fix bf->skb=3D=3DNULL panic in ath5k_tasklet_rx
      mac80211: add suspend/resume callbacks
      ath5k: remove stop/start calls from within suspend/resume
      ath5k: remove unused led_off parameter
      ath5k: use short preamble when possible
      ath5k: honor the RTS/CTS bits
      mac80211: change workqueue back to non-freezeable
      mac80211: flush workqueue a second time in suspend()
      ath9k: remove write-only current_rd_inuse
      ath9k: save a few calls to ath9k_regd_get_eepromRD
      ath9k: convert isWwrSKU macro into C code
      ath9k: remove ath9k_regd_get_rd()
      ath9k: remove prototype for ath9k_regd_get_current_country
      ath9k: move common regulatory code out of if() branches
      ath5k: don't mask off interrupt bits
      ath5k: use spin_lock_irqsave for beacon lock
      ath5k: move beacon processing to a tasklet
      ath5k: compute rts/cts duration after computing full pktlen
      ath9k: fix 802.11g conformance test limit typo
      ath5k: extract LED code into a separate file
      ath5k: use a table for LED parameters
      ath5k: update LED table with reported devices
      ath5k: disable MIB interrupts
      ath5k: remove dummy PCI "retry timeout" fix
      ath5k: warn and correct rate for unknown hw rate indexes
      ath5k: properly drop packets from ops->tx

Bob Moore (39):
      ACPICA: Add error check to debug object dump routine
      ACPICA: Allow OS override of all ACPI tables
      ACPICA: Remove extraneous parameter in table manager
      ACPICA: Add override for dynamic tables
      ACPICA: Update FADT flag definitions
      ACPICA: Update version to 20090123
      ACPICA: Split out PM1 status registers from the FADT
      ACPICA: Update comments in module header
      ACPICA: Fix writes to optional PM1B registers
      ACPICA: Remove extra write for acpi_hw_clear_acpi_status
      ACPICA: For PM1B registers, do not shift value read or written
      ACPICA: Fix parameter validation for acpi_read/write
      ACPICA: Remove redundant ACPI_BITREG_SLEEP_TYPE_B
      ACPICA: Add function to handle PM1 control registers
      ACPICA: Remove ACPI_GET_OBJECT_TYPE macro
      ACPICA: Conditionally compile acpi_set_firmware_waking_vector64
      ACPICA: Debug output: print result of _OSI invocations
      ACPICA: Debug output: decrease verbosity of DB_INFO debug level
      ACPICA: Formatting update - no functional changes
      ACPICA: Optimize ACPI register locking
      ACPICA: Rename ACPI bit register access functions
      ACPICA: Restructure bit register access functions
      ACPICA: Update table header print function
      ACPICA: Update version to 20090220
      ACPICA: Add manifest constants for bit register values
      ACPICA: Formatting update - no functional changes
      ACPICA: FADT: Fix extraneous length mismatch warning
      ACPICA: Fix AcpiWalkNamespace race condition with table unload
      ACPICA: Change handling of PM1 Status register ignored bit
      ACPICA: Preserve all PM control reserved and ignored bits
      ACPICA: New: I/O port protection
      ACPICA: Remove obsolete acpi_os_validate_address interface
      ACPICA: Remove unused code, no functional change
      ACPICA: Condense some protected ports
      ACPICA: Fix PCI configuration space port address range
      ACPICA: FADT: Favor 32-bit register addresses for compatibility
      ACPICA: FADT: Favor 32-bit FACS and DSDT addresses
      ACPICA: Fix index value in package warning message
      ACPICA: Update version to 20090320

Borislav Petkov (5):
      usb_storage: make Kconfig note visible in the console
      ide: improve debugging scheme
      ide-cd: use ide_drive_t's rq in cdrom_queue_request_sense
      ide-atapi: start DMA after issuing a packet command
      ide-floppy: do not complete rq's prematurely

Brandon Philips (1):
      uio: add the uio_aec driver

Breno Leitao (6):
      s2io: Formatting log message
      e1000: Removing the unused macro PAGE_USE_COUNT()
      jsm: define init function as __devinit
      jsm: Fix the return variable and removing the unused retval.
      icom: remove unused variables
      tty: jsm cleanups

Breno Leit=C3=A3o (1):
      ixgbe: Removing the unused PAGE_USE_COUNT() macro.

Brent Baccala (1):
      Staging: comedi: add quatech_daqp_cs driver

Brian Gerst (48):
      x86-64: Move irq stats from PDA to per-cpu and consolidate with 32-=
bit.
      x86-64: Move TLB state from PDA to per-cpu and consolidate with 32-=
bit.
      x86-64: Convert irqstacks to per-cpu
      x86-64: Convert exception stacks to per-cpu
      x86-64: Move cpu number from PDA to per-cpu and consolidate with 32=
-bit.
      x86-64: Move current task from PDA to per-cpu and consolidate with =
32-bit.
      x86-64: Move kernelstack from PDA to per-cpu.
      x86-64: Move oldrsp from PDA to per-cpu.
      x86-64: Move irqcount from PDA to per-cpu.
      x86-64: Move nodenumber from PDA to per-cpu.
      x86-64: Move isidle from PDA to per-cpu.
      x86-64: Use absolute displacements for per-cpu accesses.
      x86: remove pda_init()
      percpu: refactor percpu.h
      x86: rework __per_cpu_load adjustments
      x86: move stack_canary into irq_stack
      x86: remove pda.h
      x86: clean up gdt_page definition
      x86: fix percpu_write with 64-bit constants
      x86: set %fs to __KERNEL_PERCPU unconditionally for x86_32
      x86: merge mmu_context.h
      x86: merge irq_regs.h
      x86: remove idle_timestamp from 32bit irq_cpustat_t
      x86: remove include of apic.h from hardirq_64.h
      x86: sync hardirq_{32,64}.h
      x86: merge hardirq_{32,64}.h into hardirq.h
      x86: make irq_cpustat_t fields conditional
      generic, x86: fix __per_cpu_load relocation
      x86: merge setup_per_cpu_maps() into setup_per_cpu_areas()
      x86: move 64-bit NUMA code
      x86: move setup_cpu_local_masks()
      x86: always page-align per-cpu area start and size
      x86: move apic variables to apic.c
      x86: only compile setup_percpu.o on SMP
      x86: move this_cpu_offset
      x86: don't assume boot cpu is #0
      x86: make Voyager use x86 per-cpu setup.
      x86: initialize per-cpu GDT segment in per-cpu setup
      x86: remove extra barriers from load_gs_base()
      x86: load new GDT after setting up boot cpu per-cpu area
      x86: pass in cpu number to switch_to_new_gdt()
      percpu: make PER_CPU_BASE_SECTION overridable by arches
      x86: use linker to offset symbols by __per_cpu_load
      x86: fix abuse of per_cpu_offset
      x86: use pt_regs pointer in do_device_not_available()
      x86: pass in pt_regs pointer for syscalls that need it
      x86: drop -fno-stack-protector annotations after pt_regs fixes
      x86: use regparm(3) for passed-in pt_regs pointer

Brian Haley (1):
      ipv6: Fix incorrect disable_ipv6 behavior

Brian King (7):
      powerpc/pseries: Fix partition migration hang under load
      [SCSI] ibmvfc: Better handle other FC initiators
      [SCSI] ibmvfc: Fix dropped interrupts
      [SCSI] ibmvfc: Fixup module parms attributes
      [SCSI] ibmvfc: Show host maxframe_size
      [SCSI] ibmvfc: Improve ADISC timeout handling
      [SCSI] ibmvfc: Driver version 1.0.5

Brian Maly (1):
      efifb: dmi set video type

Brice Goglin (1):
      myri10ge: update firmware headers to 1.4.41

Bruce Allan (2):
      e100: add support for 82552 10/100 adapter
      e1000e: add support for 82574 device ID 0x10F6

Bruno Christo (1):
      V4L/DVB (10827): Add support for GeoVision GV-800(S)

Bryan Donlan (2):
      ext4: return -EIO not -ESTALE on directory traversal through delete=
d inode
      ext3: return -EIO not -ESTALE on directory traversal through delete=
d inode

Calin Culianu (3):
      Staging: comedi: add pcmda12 driver
      Staging: comedi: add pcmmio and pcmuio drivers
      Staging: comedi: add cb_pcimdda driver

Carl Henrik Lunde (1):
      blktrace: NUL-terminate user space messages

Carl Worth (1):
      drm/i915: Add a spinlock to protect the active_list

Carlos Corbacho (2):
      acer-wmi: Blacklist Acer Aspire One
      acer-wmi: Update copyright notice & documentation

Carsten Emde (1):
      tracing: fix command line to pid reverse map

Carsten Otte (2):
      [S390] check addressing mode in s390_enable_sie
      [S390] tape message cleanup

Catalin Marinas (17):
      [ARM] 5387/1: Add ptrace VFP support on ARM
      [ARM] 5388/1: Add hwcap bits for VFPv3 and VFPv3D16
      [ARM] 5389/1: Make sure the pmd entries are visible by the secondar=
y CPU
      [ARM] 5381/1: unwind: Reorganise the traps.c code
      [ARM] 5382/1: unwind: Reorganise the stacktrace support
      [ARM] 5383/2: unwind: Add core support for ARM stack unwinding
      [ARM] 5384/1: unwind: Add stack unwinding support for loadable modu=
les
      [ARM] 5385/2: unwind: Add unwinding information to exception entry =
points
      [ARM] 5386/2: unwind: Add Makefile and Kconfig entries for ARM stac=
k unwinding
      [ARM] 5394/1: Add static bus numbering support to i2c-versatile
      [ARM] 5395/1: RealView: Add support for the DS1338 RTC chip
      [ARM] 5396/1: RealView: Use PATA_PLATFORM to access the CompactFlas=
h
      [ARM] 5397/1: RealView: Add support for the ISP1761 USB chip
      USB: Make the isp1760_register function prototype more generic
      USB: Add platform device support for the ISP1760 USB chip
      USB: isp1760: Add a delay before reading the SKIPMAP registers in i=
sp1760-hcd.c
      [ARM] 5439/1: Do not clear bit 10 of DFSR during abort handling on =
ARMv6

Cesar Eduardo Barros (5):
      sc92031: more useful banner in kernel log
      sc92031: remove meaningless version string
      sc92031: inline SC92031_DESCRIPTION
      sc92031: use device id directly instead of made-up name
      sc92031: add a link to the datasheet

Chatre, Reinette (2):
      iwl3945: add debugging for wrong command queue
      iwlwifi: add test to determine if interface in monitor mode

Chauhan, Vijay (3):
      [SCSI] scsi_dh_rdac: Retry for Quiescence in Progress in rdac devic=
e handler
      [SCSI] scsi_dh_rdac: Retry mode select for NO_SENSE, ABORTED_COMMAN=
D, UNIT_ATTENTION, NOT_READY(02/04/01)
      [SCSI] scsi_dh_rdac: Retry for NOT_READY check condition

Cheng Renquan (4):
      do_pipe cleanup: drop its last user in arch/alpha/
      MAINTAINERS: add the missing linux alpha port mailling list
      dm target: use module refcount directly
      dm target: remove struct tt_internal

Chien Tung (3):
      RDMA/nes: Update copyright to new legal entity and year
      RDMA/nes: Report correct vendor_id and vendor_part_id
      RDMA/nes: Fix tmp_addr compilation warning

Chris Dearman (1):
      MIPS: R2: Fix problem with code that incorrectly modifies ebase.

Chris Leech (2):
      [SCSI] net: reclaim 8 upper bits of the netdev->features from GSO
      [SCSI] net: define feature flags for FCoE offloads

Chris Mason (25):
      mutex: adaptive spinnning, performance tweaks
      Btrfs: stop spinning on mutex_trylock and let the adaptive code spi=
n for us
      Btrfs: don't preallocate metadata blocks during btrfs_search_slot
      Btrfs: do extent allocation and reference count updates in the back=
ground
      Btrfs: reduce stack usage in some crucial tree balancing functions
      Btrfs: try to cleanup delayed refs while freeing extents
      Btrfs: process the delayed reference queue in clusters
      Btrfs: reduce stalls during transaction commit
      Btrfs: reduce stack in cow_file_range
      Btrfs: Check for a blocking lock before taking the spin
      Btrfs: Only let very young transactions grow during commit
      Btrfs: leave btree locks spinning more often
      Btrfs: readahead checksums during btrfs_finish_ordered_io
      Btrfs: limit balancing work while flushing delayed refs
      Btrfs: Make sure i_nlink doesn't hit zero too soon during log repla=
y
      Btrfs: tree logging unlink/rename fixes
      Btrfs: optimize fsyncs on old files
      Btrfs: make sure btrfs_update_delayed_ref doesn't increase ref_mod
      Btrfs: add extra flushing for renames and truncates
      Btrfs: try to free metadata pages when we free btree blocks
      Btrfs: keep processing bios for a given bdev if our proc is batchin=
g
      Btrfs: unplug in the async bio submission threads
      Btrfs: break up btrfs_search_slot into smaller pieces
      Btrfs: Optimize locking in btrfs_next_leaf()
      Btrfs: rework allocation clustering

Chris R. Baugher (1):
      Staging: comedi: add ni_at_atmio16d driver

Chris Samuel (1):
      trivial: cgroups: documentation typo and spelling corrections

Chris Wilson (3):
      drm/i915: Display fence register state in debugfs i915_gem_fence_re=
gs node.
      drm/i915: Display fence register state in debugfs i915_gem_fence_re=
gs node.
      drm/i915: Check for dev->primary->master before dereference.

Chris Wright (1):
      PCI: add remove_id sysfs entry

Chris Zankel (3):
      xtensa: only build platform or variant if they contain a Makefile
      xtensa: we don't need to include asm/io.h
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6 into merge

Christian Borntraeger (7):
      KVM: s390: Fix printk on SIGP set arch
      KVM: s390: Fix problem state check for b2 intercepts
      KVM: s390: Fix SIGP set prefix ioctl
      [S390] fix dump_stack vs. %p and (null)
      [S390] lockdep: trace hardirq off in smp_send_stop
      [S390] Fix hypervisor detection for KVM
      [S390] Fix comments in lowcore structure

Christian Ehrhardt (1):
      [S390] fix dfp elf hwcap/facility bit detection

Christian Hohnstaedt (1):
      crypto: ixp4xx - Fix handling of chained sg buffers

Christian Lamparter (33):
      p54: label queues with their corresponding names
      p54: enable proper frame injection
      p54usb: utilize usb_reset_device for 3887
      p54: prevent upload of wrong firmwares
      p54: regulatory domain hints
      p54: enable rx/tx antenna diversity by eeprom bits
      p54: implement FIF_OTHER_BSS filter setting
      p54: power save management
      p54: return NETDEV_TX_OK in p54_tx and fix sparse warnings
      p54: refactor p54_alloc_skb
      p54: upgrade memrecord to p54_tx_info
      p54: prepare the eeprom parser routines for longbow
      p54: longbow frontend support
      p54spi: stlc45xx eeprom blob
      p54spi: p54spi driver
      p54usb: fix conflict with recent usb changes
      p54spi: remove arch specific dependencies
      p54usb: stop USB core interference in exit path
      p54: unify ieee80211 device registration
      p54pci: convert printk(KERN_* to dev_*
      p54: fix iwconfig txpower off
      p54: initial SoftLED support
      p54: enable power save support
      p54: completely ignore rx'd frames with bad FCS
      p54: fix SoftLED compile dependencies
      ar9170: hardware and eeprom header files
      ar9170: ar9170: mac80211 interaction code
      ar9170: mac/bbp and phy code
      ar9170: ar9170: USB frontend driver
      ar9170: update Makefile, Kconfig and MAINTAINERS
      ar9170: simplify & deBUG tx_status queueing and reporting
      p54: Kconfig maintenance
      ar9170: single module build

Christian Pellegrin (1):
      Add support for the MAX3100 SPI UART.

Christine Caulfield (1):
      dlm: replace idr with hash table for connections

Christof Schmitt (11):
      [SCSI] scsi_transport_fc: Add missing parenthesis to Point-To-Point=
 description
      [SCSI] zfcp: Remove some port flags
      [SCSI] zfcp: Remove UNIT_REGISTERED status flag
      [SCSI] zfcp: Simplify latency lock handling
      [SCSI] zfcp: Only increment req_id for successfully issued requests
      [SCSI] zfcp: Wait for free SBALs when possible
      [SCSI] zfcp: Improve reliability of SCSI eh handlers in zfcp
      [SCSI] zfcp: Send ELS ADISC from workqueue
      [SCSI] zfcp: Remove PCI flag
      [SCSI] zfcp: Block FC transport rports early on errors
      [SCSI] zfcp: Report fc_host_port_type as NPIV

Christoph Hellwig (47):
      xfs: fix dentry aliasing issues in open_by_handle
      xfs: use mnt_want_write in compat_attrmulti ioctl
      xfs: add a separate lock class for the per-mount list of dquots
      xfs: lockdep annotations for xfs_dqlock2
      xfs: add a lock class for group/project dquots
      xfs: fix bad_features2 fixups for the root filesystem
      xfs: sanity check attr fork size
      xfs: cleanup error handling in xfs_mountfs:
      xfs: make sure to free the real-time inodes in the mount error path
      xfs: tiny cleanup for xfs_link
      xfs: remove unused XFS_MOUNT_ILOCK/XFS_MOUNT_IUNLOCK
      xfs: factor out attr fork reset handling
      xfs: merge xfs_inode_flush into xfs_fs_write_inode
      xfs: cleanup xfs_find_handle
      xfs: remove the unused XFS_QMOPT_DQLOCK flag
      xfs: remove iclog calculation special cases
      xfs: remove superflous inobt macros
      xfs: remove uchar_t/ushort_t/uint_t/ulong_t types
      xfs: merge xfs_mkdir into xfs_create
      xfs: remove XFS_QM_LOCK/XFS_QM_UNLOCK/XFS_QM_HOLD/XFS_QM_RELE
      xfs: use mutex_is_locked in XFS_DQ_IS_LOCKED
      xfs: sanitize qh_lock wrappers
      xfs: get rid of indirections in the quotaops implementation
      xfs: fix error handling in xfs_log_mount
      xfs: reject swapext ioctl on swapfiles
      xfs: prevent kernel crash due to corrupted inode log format
      xfs: prevent lockdep false positive in xfs_iget_cache_miss
      xfs: only issues a cache flush on unmount if barriers are enabled
      xfs: cleanup log unmount handling
      xfs: remove another leftover of the old inode log item format
      xfs: cleanup xlog_recover_do_trans
      xfs: cleanup xlog_bread
      xfs: kill vn_atime_* helpers.
      xfs: kill VN_BAD
      affs: fix missing unlocks in affs_remove_link
      generic compat_sys_ustat
      cleanup d_add_ci
      cleanup may_open
      xfs: kill mutex_t typedef
      xfs: kill ino64 mount option
      xfs: remove m_litino
      xfs: remove m_attroffset
      xfs: cleanup uuid handling
      md: stop defining MAJOR_NR
      cleanup drivers/md/Makefile
      md: move headers out of include/linux/raid/
      ubd: stop defintining MAJOR_NR

Christoph Lameter (2):
      SLUB: Introduce and use SLUB_MAX_SIZE and SLUB_PAGE_SHIFT constants
      SLUB: Introduce and use SLUB_MAX_SIZE and SLUB_PAGE_SHIFT constants

Christoph Paasch (2):
      netfilter: change generic l4 protocol number
      netfilter: remove IPvX specific parts from nf_conntrack_l4proto.h

Christoph Plattner (2):
      ALSA: hda - Added HP HDX16/HDX18 notebook support for HDA codecs (8=
2HD71)
      ALSA: hda - Rework on patch_sigmatel.c for HP HDX16/HDX18

Christophe Saout (1):
      xen: fix too early kmalloc call

Chuck Ebbert (1):
      xfrm: spin_lock() should be spin_unlock() in xfrm_state.c

Chuck Lever (24):
      SUNRPC: Avoid spurious wake-up during UDP connect processing
      SUNRPC: Clean up static inline functions in svc_xprt.h
      SUNRPC: Don't flag empty RPCB_GETADDR reply as bogus
      SUNRPC: Clean up static inline functions in svc_xprt.h
      NFSD: If port value written to /proc/fs/nfsd/portlist is invalid, r=
eturn EINVAL
      SUNRPC: Clean up svc_find_xprt() calling sequence
      SUNRPC: Pass a family argument to svc_register()
      SUNRPC: svc_setup_socket() gets protocol family from socket
      SUNRPC: Change svc_create_xprt() to take a @family argument
      SUNRPC: Remove @family argument from svc_create() and svc_create_po=
oled()
      NFS: Revert creation of IPv6 listeners for lockd and NFSv4 callback=
s
      SUNRPC: Set IPV6ONLY flag on PF_INET6 RPC listener sockets
      SUNRPC: Use IPv4 loopback for registering AF_INET6 kernel RPC servi=
ces
      SUNRPC: Don't return EPROTONOSUPPORT in svc_register()'s helpers
      SUNRPC: Clean up address type casts in rpcb_v4_register()
      SUNRPC: rpcbind actually interprets r_owner string
      SUNRPC: Allow callers to pass rpcb_v4_register a NULL address
      SUNRPC: Simplify svc_unregister()
      SUNRPC: Simplify kernel RPC service registration
      SUNRPC: rpcb_register() should handle errors silently
      SUNRPC: Remove CONFIG_SUNRPC_REGISTER_V4
      lockd: Start PF_INET6 listener only if IPv6 support is available
      NFS: Start PF_INET6 callback listener only if IPv6 support is avail=
able
      NFS: Simplify logic to compare socket addresses in client.c

Claudio Scordino (1):
      tty: Use the generic RS485 ioctl on CRIS

Clemens Ladisch (22):
      sound: usb-audio: use normal number of frames for no-data URBs
      sound: usb-audio: limit playback queue length
      sound: usb-audio: make URB sizes more equal
      sound: oxygen: make the owner module a parameter of the probe funct=
ion
      sound: oxygen: allocate model_data dynamically
      sound: oxygen: use static driver name
      sound: oxygen: handle cards with broken EEPROM
      sound: oxygen: automatically restore overwritten EEPROM
      sound: oxygen: handle AK5385 ADC on Claro halo cards
      sound: virtuoso: increase minimum volume to -60 dB
      sound: usb-audio: remove MIN_PACKS_URB
      sound: virtuoso: add Xonar Essence STX support
      sound: oxygen: zero-initialize model data
      sound: usb-audio: fix rules check for 32-channel devices
      sound: usb-audio: fix queue length check for high speed devices
      sound: oxygen: enable headphone output on Claro cards
      udf: fix novrs mount option
      udf: use hardware sector size
      sound: usb-audio: show sample format width in proc file
      sound: usb-audio: remove check_hw_params_convention()
      sound: usb-audio: save data packet interval in audioformat structur=
e
      sound: usb-audio: allow period sizes less than 1 ms

Cliff Cai (3):
      Blackfin arch: add sport-spi related resource stuff to board file
      Blackfin arch: sport spi needs 6 gpio pins
      Blackfin arch: add RSI's definitions to bf514 and bf516

Cliff Wickman (2):
      x86: UV fix uv_flush_send_and_wait()
      x86: UV: remove uv_flush_tlb_others() WARN_ON

Colin McCabe (2):
      libertas: Update libertas core with GSPI constants
      libertas: if_spi, driver for libertas GSPI devices

Colin Watson (1):
      parisc: expose 32/64-bit capabilities in cpuinfo

Coly Li (20):
      jfs: return f_fsid for statfs(2)
      udf: return f_fsid for statfs(2)
      fs/adfs: return f_fsid for statfs(2)
      fs/affs: return f_fsid for statfs(2)
      fs/befs: return f_fsid for statfs(2)
      fs/cramfs: return f_fsid for statfs(2)
      fs/efs: return f_fsid for statfs(2)
      fs/fat: return f_fsid for statfs(2)
      fs/hfs: return f_fsid for statfs(2)
      fs/hfsplus: return f_fsid for statfs(2)
      fs/hpfs: return f_fsid for statfs(2)
      fs/isofs: return f_fsid for statfs(2)
      fs/minix: return f_fsid for statfs(2)
      fs/omfs: return f_fsid for statfs(2)
      fs/qnx4: return f_fsid for statfs(2)
      fs/reiserfs: return f_fsid for statfs(2)
      fs/squashfs: return f_fsid for statfs(2)
      fs/sysv: return f_fsid for statfs(2)
      fs/ufs: return f_fsid for statfs(2)
      fs/romfs: return f_fsid for statfs(2)

Constantin Baranov (2):
      niu: fix PHY template choice for 10G copper
      niu: improve ethtool support for gigabit copper cards

Corentin Chary (1):
      UBI: add fsync capability

Cornelia Huck (4):
      Driver core: Fix device_move() vs. dpm list ordering, v2
      [S390] cio: Use unbind/bind instead of unregister/register.
      [S390] cio: Try harder to disable subchannel.
      [S390] cio: Use ccw_device_set_notoper().

Craig Shelley (2):
      USB: CP2101 Support AN205 baud rates
      USB: CP2101 Reduce Error Logging

Cyrill Gorcunov (33):
      x86: headers cleanup - prctl.h
      x86: headers cleanup - sigcontext32.h
      x86: headers cleanup - setup.h
      x86: headers cleanup - boot.h
      net: pppoe - code cleanup and helpers
      net: pppoe - introduce net-namespace functionality
      net: pppol2tp - introduce net-namespace functionality
      net: ppp_generic - introduce net-namespace functionality v2
      net: pppoe,pppol2tp - register channels with explicit net
      net: pppoe - get rid of DECLARE_MAC_BUF
      net: pppoe - stop using proc internals
      x86: ftrace - simplify wait_for_nmi
      x86: trampoline_64.S - use predefined constants with simplification
      x86: asm linkage - introduce GLOBAL macro
      x86: linkage - get rid of _X86 macros
      x86: copy.S - use GLOBAL,ENDPROC macros
      x86: pmjump - use GLOBAL,ENDPROC macros
      x86: compressed head_64 - use ENTRY,ENDPROC macros
      x86: compressed head_32 - use ENTRY,ENDPROC macros
      x86: head_64.S - remove useless balign
      x86: head_64.S - use IDT_ENTRIES instead of hardcoded number
      x86: invalid_vm86_irq -- use predefined macros
      x86: entry_64.S - add missing ENDPROC
      x86: head_64.S - use GLOBAL macro
      x86: efi_stub_32,64 - add missing ENDPROCs
      x86: linkage.h - guard assembler specifics by __ASSEMBLY__
      x86: shrink __ALIGN and __ALIGN_STR definitions
      net: sysctl_net - use net_eq to compare nets
      net: netfilter conntrack - add per-net functionality for DCCP proto=
col
      x86: headers cleanup - setup.h
      mm: mminit_validate_memmodel_limits(): remove redundant test
      oom_kill: don't call for int_sqrt(0)
      introduce pr_cont() macro

Cyrus Massoumi (1):
      ext3: remove the BKL in ext3/ioctl.c

D.J. Capelis (1):
      USB: pedantic: spelling correction in comment for ch9.h

Daisuke Nishimura (2):
      memcg: charge swapcache to proper memcg
      memcg: cleanup cache_charge

Dan Carpenter (9):
      Add a missing unlock_kernel() in raw_open()
      ext4: fix typo which causes a memory leak on error path
      drm: drm_fops.c unlock missing on error path
      fuse: fix fuse_file_lseek returning with lock held
      Btrfs: remove dead code
      Btrfs: remove dead code
      dock: fix dereference after kfree()
      Staging: altpciechdma: Null deref in altpciechdma.c remove()
      ASoC: Fix null dereference in ak4535_remove()

Dan Smith (1):
      [S390] Expose a constant for the number of words representing the C=
Rs

Dan Williams (25):
      libertas: fix CF firmware loading for some cards
      airo: clean up and clarify interrupt-time task handling
      airo: re-arrange WPA capability checks
      airo: simplify WEP index and capability checks
      airo: clean up WEP key operations
      airo: use __attribute__ ((packed)) not #pragma
      airo: clean up and clarify micinit()
      airo: remove useless #defines
      Revert "i.MX31: framebuffer driver"
      hostap: convert usage of net/ieee80211.h to linux/ieee80211.h
      make net/ieee80211.h private to ipw2x00
      cfg80211: age scan results on resume
      ipw2x00: age scan results on resume
      libertas: use private SDIO workqueue to avoid scheduling latency
      dmaengine: fail device registration if channel registration fails
      dmaengine: initialize tx_list in dma_async_tx_descriptor_init
      dmaengine: kill some unused headers
      async_tx: provide __async_inline for HAS_DMA=3Dn archs
      dmaengine: allow dma support for async_tx to be toggled
      dmatest: add xor test
      dmatest: add dma interrupts and callbacks
      md: add 'size' as a personality method
      md: centralize ->array_sectors modifications
      md: 'array_size' sysfs attribute
      md/raid6: move raid6 data processing to raid6_pq.ko

Daniel Drake (1):
      Staging: add b3dfg driver

Daniel Glockner (1):
      rtc: add m41t62 support to rtc-m41t80 driver

Daniel Gl=C3=B6ckner (2):
      V4L/DVB (11242): allow v4l2 drivers to provide a get_unmapped_area =
handler
      xtensa: make startup code discardable

Daniel Mack (34):
      ALSA: snd-usb-caiaq: support for two more audio devices
      ASoC: Add cs4270 support for slave mode configurations
      ASoC: fix typo and removed unneeded switch case for cs4270
      ASoC: Fix name of register bit in pxa-ssp
      ASoC: add two more bitfields for PXA SSP
      ASoC: bring cs4270 feature/limitations list in sync
      ASoC: Add a driver for AK4104 S/PDIF transmitter
      ASoC: don't touch pxa-ssp registers when stream is running
      ASoC: switch PXA SSP driver from network mode to PSP
      ALSA: snd-usb-caiaq: only warn once on streaming errors
      ALSA: snd-usb-caiaq: drop bogus iso packets
      ALSA: snd-usb-caiaq: bump version number
      [ARM] pxa: add missing pin function for CS2 on GPIO1
      [ARM] pxa: add pxa320 missing pin function for CS2 on GPIO3
      [ARM] pxa: rename colibri.c to colibri-pxa270.c
      [ARM] pxa: add basic support for Colibri PXA300 module
      [ARM] pxa: add MMC support for Colibri PXA300
      [ARM] pxa: add USB support for Colibri PXA300
      [ARM] pxa: rename and update Colibri PXA270 defconfig
      [ARM] pxa: add colibri PXA300 defconfig
      [ARM] pxa: Fix Colibri AX88796 configuration
      [ARM] pxa: Refactor Colibri board support code
      [ARM] pxa: Colibri PXA320 module basics
      [ARM] pxa: Add Colibri LCD functions
      [ARM] pxa: AC97 pin functions for Colibri PXA310/320
      USB: allow malformed LANGID descriptors
      drivers/net/ax88796.c: take IRQ flags from platform_device
      ax88796: Add method to take MAC from platform data
      [ARM] pxa: fix Colibri PXA300 and PXA320 LCD backlight pins
      drivers/misc/isl29003.c: driver for the ISL29003 ambient light sens=
or
      lis3: reorder functions to make forward decl obsolete
      lis3: solve dependency between core and ACPI
      lis3: SPI transport layer
      w1: coding style cleanups in w1_io.c

Daniel Silverstone (6):
      [ARM] 5372/1: ACS5K: Core board support for the ACS-5000
      [ARM] 5376/1: S3C24XX: Fix sparse errors in platform uncompress.h
      [ARM] 5377/1: S3C2410-Framebuffer: Fix resume path in S3C2410 frame=
buffer driver.
      [ARM] 5428/1: Module relocation update for R_ARM_V4BX
      gpiolib: allow GPIOs to be named
      i2c-s3c2410: Simplify bus frequency calculation

Daniel Stone (1):
      [ARM] OMAP2: Fix definition of SGX clock register bits

Daniel Vecino Castel (1):
      Staging: comedi: add ni_daq_dio24 driver

Daniel Vetter (1):
      drm/i915: fix up tiling/fence reg setup on i8xx class hw

Daniel Walker (1):
      panic.c: fix whitespace additions

Danny Kukawka (6):
      iwlwifi: fix led naming
      ath9k: fix led naming
      b43legacy: fix led naming
      rt2x00: fix led naming
      iwlwifi: another led naming fix
      8250_pnp.c: add another Wacom tablet

Darius Augulis (7):
      USB: imx_udc: Fix IMX UDC gadget bugs
      USB: imx_udc: Fix IMX UDC gadget code style
      USB: imx_udc: Fix IMX UDC gadget ep0 irq handling
      USB: imx_udc: Fix IMX UDC gadget general irq handling
      [MTD] [NOR] Fixup for Numonyx M29W128 chips
      i2c: iMX/MXC support
      i2c: imx: Add missing request_mem_region in probe()

Darren Hart (7):
      futex: update futex commentary
      futex: additional (get|put)_futex_key() fixes
      futex: add double_unlock_hb()
      futex: use current->time_slack_ns for rt tasks too
      futex: unlock before returning -EFAULT
      futex: clean up fault logic
      futex: remove the pointer math from double_unlock_hb

Dave Airlie (19):
      drm/radeon: align ring writes to 16 dwords boundaries.
      drm/radeon: split busmaster enable out to a separate function
      drm: add DRM_READ/WRITE64 wrappers around readq/writeq.
      drm/ati_pcigart: use memset_io to reset the memory
      drm/r600: fixup r600 gart table accessor like ati_pcigart.c
      drm/r600: fix rptr address along lines of previous fixes to radeon.
      radeon: call the correct idle function, logic got inverted.
      drm/radeon: fix r600 pci mapping calls.
      drm: fix warnings about new mappings in info code.
      drm/radeon: fix r600 writeback setup.
      drm/radeon: fix r600 writeback across suspend/resume
      drm/radeon: don't call irq changes on r600 suspend/resume
      drm/radeon: r600 ptes are 64-bit, cleanup cleanup function.
      PCI: expose boot VGA device via sysfs.
      drm: merge Linux master into HEAD
      drm/i915: check the return value from the copy from user
      drm: fix missing inline function on 32-bit powerpc.
      drm: fix typo in edid vendor parsing.
      Merge branch 'drm-intel-next' of ../anholt-2.6 into drm-linus

Dave Chinner (3):
      Long btree pointers are still 64 bit on disk
      xfs: Check buffer lengths in log recovery
      xfs: factor out code to find the longest free extent in the AG

Dave Jones (25):
      [CPUFREQ] Stupidly trivial CodingStyle fix
      [CPUFREQ] checkpatch cleanups for cpufreq-nforce2
      [CPUFREQ] nforce2: Use driver prefix, not cpufreq prefix.
      [CPUFREQ] checkpatch cleanups for elanfreq
      [CPUFREQ] checkpatch cleanups for e_powersaver
      [CPUFREQ] checkpatch cleanups for gx-suspmod
      [CPUFREQ] checkpatch cleanups for longhaul
      [CPUFREQ] checkpatch cleanups for longrun
      [CPUFREQ] checkpatch cleanups for powernow-k6
      [CPUFREQ] checkpatch cleanups for sc520
      [CPUFREQ] checkpatch cleanups for cpufreq core
      [CPUFREQ] checkpatch cleanups for conservative governor
      [CPUFREQ] checkpatch cleanups for cpufreq_stats
      [CPUFREQ] checkpatch cleanups for userspace governor
      [CPUFREQ] checkpatch cleanups for freq_table
      [CPUFREQ] checkpatch cleanups for speedstep related drivers.
      [CPUFREQ] checkpatch cleanups for powernow-k7
      [CPUFREQ] checkpatch cleanups for ondemand governor.
      [CPUFREQ] checkpatch cleanups for powernow-k8
      [CPUFREQ] checkpatch cleanups for acpi-cpufreq
      [CPUFREQ] Use swap() in longhaul.c
      [CPUFREQ] powernow-k8: Use a common exit path.
      [CPUFREQ] Prevent p4-clockmod from auto-binding to the ondemand gov=
ernor.
      a2065: skb_padto cleanups
      cpqarray: enable bus mastering

Dave Kleikamp (4):
      jfs: clean up a dangling comment
      jfs: remove xtLookupList()
      jfs: Fix error handling in metapage_writepage()
      Merge branch 'master' of /home/shaggy/git/linus-clean/

Dave Young (4):
      Bluetooth: Remove CONFIG_DEBUG_LOCK_ALLOC ifdefs
      Bluetooth: Move hci_conn_del_sysfs() back to avoid device destruct =
too early
      usb-serial: fix usb_serial_register bug when boot with nousb param
      driver-core: do not register a driver with bus_type not registered

David A. Schleef (1):
      Staging: comedi: add poc driver

David Altobelli (1):
      hpilo: reduce frequency of IO operations

David Brownell (29):
      ASoC: buildfix for OSK
      [MTD] [NAND] fix "raw" reads with ECC syndrome layouts
      [MTD] [NAND] davinci_nand driver
      [MTD] [NAND] fix broken debug messages
      [MTD] we don't need no misc devices
      [MTD] partitioning utility predicates
      ARM: OMAP3: mmc-twl4030 voltage cleanup
      ARM: OMAP3: mmc-twl4030 init passes device nodes back, v2
      ARM: OMAP3: mmc-twl4030 fix for vmmc =3D 0
      USB: gadget: fix rndis regression
      USB: ftdi_sio: remove pointless syslog spew
      USB: musb: partial DaVinci dm355 support
      USB: gadget: composite device-level suspend/resume hooks
      USB: gadget: gadget zero uses new suspend/resume hooks
      regulator: minor cleanup of virtual consumer
      regulator: add get_status()
      regulator: enumerate voltages (v2)
      regulator: get_status() grows kerneldoc
      regulator: twl4030 regulators
      regulator: twl4030 voltage enumeration (v2)
      MMC: regulator utilities
      twl4030-regulator: list more VAUX4 voltages
      regulator: refcount fixes
      twl4030-regulator: expose VPLL2
      memory_accessor: implement the new memory_accessor interfaces for S=
PI EEPROMs
      gpio: gpio_{request,free}() now required (feature removal)
      [MTD] driver model updates
      [MTD] support driver model updates
      leds: just ignore invalid GPIOs in leds-gpio

David Daney (2):
      MIPS: __raw_spin_lock() may spin forever on ticket wrap.
      libata: Remove some redundant casts from pata_octeon_cf.c

David Dillow (1):
      typhoon: repair firmware loading

David Howells (50):
      NOMMU: Present backing device capabilities for MTD chardevs
      NOMMU: Add support for direct mapping through mtdconcat if possible
      NOMMU: Make it possible for RomFS to use MTD devices directly
      NOMMU: Fix the RomFS Kconfig to ensure at least one backing store i=
s selected
      Annotate struct fs_struct's usage count restriction
      nommu: there is no mlock() for NOMMU, so don't provide the bits
      nommu: make CONFIG_UNEVICTABLE_LRU available when CONFIG_MMU=3Dn
      nommu: fix a number of issues with the per-MM VMA patch
      Create a dynamically sized pool of threads for doing very slow work=
 items
      Make slow-work thread pool actually dynamic
      Make the slow work pool configurable
      Document the slow work thread pool
      FS-Cache: Release page->private after failed readahead
      FS-Cache: Recruit a page flags for cache management
      FS-Cache: Add the FS-Cache netfs API and documentation
      FS-Cache: Add the FS-Cache cache backend API and documentation
      FS-Cache: Add main configuration option, module entry points and de=
bugging
      FS-Cache: Add use of /proc and presentation of statistics
      FS-Cache: Root index definition
      FS-Cache: Add cache tag handling
      FS-Cache: Add cache management
      FS-Cache: Provide a slab for cookie allocation
      FS-Cache: Add netfs registration
      FS-Cache: Bit waiting helpers
      FS-Cache: Object management state machine
      FS-Cache: Implement the cookie management part of the netfs API
      FS-Cache: Add and document asynchronous operation handling
      FS-Cache: Implement data I/O part of netfs API
      CacheFiles: Permit the page lock state to be monitored
      CacheFiles: Export things for CacheFiles
      CacheFiles: A cache that backs onto a mounted filesystem
      FS-Cache: Make kAFS use FS-Cache
      NFS: Add comment banners to some NFS functions
      NFS: Add FS-Cache option bit and debug bit
      NFS: Permit local filesystem caching to be enabled for NFS
      NFS: Register NFS for caching and retrieve the top-level index
      NFS: Define and create server-level objects
      NFS: Define and create superblock-level objects
      NFS: Define and create inode-level cache objects
      NFS: Use local disk inode cache
      NFS: Invalidate FsCache page flags when cache removed
      NFS: Add some new I/O counters for FS-Cache doing things for NFS
      NFS: FS-Cache page management
      NFS: Add read context retention for FS-Cache to call back with
      NFS: nfs_readpage_async() needs to be accessible as a fallback for =
local caching
      NFS: Read pages from FS-Cache into an NFS inode
      NFS: Store pages from an NFS inode into a local cache
      NFS: Display local caching state
      NFS: Add mount options to enable local caching on NFS
      Make CONFIG_SLOW_WORK an automatic rather than manual config option

David Kilroy (20):
      wireless: Add channel/frequency conversions to ieee80211.h
      orinoco: Remove unused variable rx_data
      orinoco: address leading and trailing whitespace
      orinoco: spaces in parenthesised expressions
      orinoco: remove unnecessary braces
      orinoco: keep line length below 80 characters
      orinoco: Fix interesting checkpatch errors
      orinoco: Rename orinoco.c
      orinoco: use orinoco_private instead of net_device in scan helper
      orinoco: Move scan helpers to a separate file
      orinoco: Move MIC helpers into new file
      orinoco: Move firmware handling into a separate file
      orinoco: Use accessor functions for bitrate tables
      orinoco: Add hardware function to set multicast mode
      orinoco: Move hardware functions into separate file
      orinoco: Move WEXT handlers into a separate file
      orinoco: hermes_dld does not need to be a module
      orinoco: hermes doesn't need to be a separate module
      orinoco: validate firmware header
      orinoco: prevent accessing memory outside the firmware image

David Milburn (2):
      [libata] ahci: correct enclosure LED state save
      libata: ahci enclosure management bios workaround

David Miller (13):
      sparc64: Fix build by including linux/irq.h into time_64.c
      sparc64: Fix build by using kstat_irqs_cpu()
      drm: ati_pcigart: Do not access I/O MEM space using pointer derefs.
      drm: ati_pcigart: Need to use PCI_DMA_BIDIRECTIONAL.
      drm: radeon: Fix ring_rptr accesses.
      drm: radeon: Fix RADEON_*_EMITED defines.
      drm: radeon: Fix calculation of RB_RPTR_ADDR in non-AGP case.
      drm: radeon: Use surface for PCI GART table.
      drm: ati_pcigart: Fix limit check in drm_ati_pcigart_init().
      drm: Preserve SHMLBA bits in hash key for _DRM_SHM mappings.
      drm: radeon: Fix unaligned access in r300_scratch().
      drm: Only use DRM_IOCTL_UPDATE_DRAW compat wrapper for compat X86.
      sparc64: Fix build of timer_interrupt().

David Moore (1):
      firewire: Include iso timestamp in headers when header_size > 4

David O'Shea (1):
      PCI: Compaq Evo D510 SMBus quirk using USB instead of VGA

David P. Quigley (3):
      SELinux: Condense super block security structure flags and cleanup =
necessary code.
      SELinux: Add new security mount option to indicate security label s=
upport.
      SELinux: Unify context mount and genfs behavior

David Rientjes (7):
      slub: move min_partial to struct kmem_cache
      slub: add min_partial sysfs tunable
      slub: rename calculate_min_partial() to set_min_partial()
      lockdep: remove duplicate CONFIG_DEBUG_LOCKDEP definitions
      vmscan: print shrink_slab symbol name on negative shrinker objects
      cpusets: replace zone allowed functions with node allowed
      cpusets: prevent PF_THREAD_BOUND tasks from attaching to non-root c=
pusets

David S. Miller (72):
      com20020: Fix allyesconfig build failure.
      com0020: Add missing symbol export for com20020_netdev_ops.
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      net: Allow RX queue selection to seed TX queue hashing.
      net: Add skb_record_rx_queue() calls to multiqueue capable drivers.
      net: If SKB has attached socket, use socket's hash for TX queue sel=
ection.
      net: Get rid of by-hand TX queue hashing.
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-next-2.6
      Merge branch 'master' of /home/davem/src/GIT/linux-2.6/
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      net: Increase default NET_SKB_PAD to 32.
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-next-2.6
      net: Kill skbuff macros from the stone ages.
      netdev: Use __netdev_alloc_skb() instead of __dev_alloc_skb().
      irda: Use __netdev_alloc_skb() instead of __dev_alloc_skb().
      net: Move skbuff symbol exports after each symbol's definition.
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-next-2.6
      Merge branch 'master' of /home/davem/src/GIT/linux-2.6/
      Revert "etherh: Get working again."
      Merge branch 'master' of /home/davem/src/GIT/linux-2.6/
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/holtmann/bluetooth-next-2.6
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-next-2.6
      typhoon: Need non-vmalloc memory to DMA firmware to the card.
      ixgbe: Fix some compiler warnings.
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      rds: Fix build on powerpc.
      typhoon: Add missing firmware copy.
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-next-2.6
      sunvnet: Convert to net_device_ops.
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      Merge branch 'master' of git://git.infradead.org/~dwmw2/solos-2.6
      spider_net: Fix build.
      myri_sbus: Convert to net_device_ops.
      sunbmac: Convert to net_device_ops.
      sunlance: Convert to net_device_ops.
      sunqe: Convert to net_device_ops.
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      myri_sbus/sunbmac/sunlance/sunqe: Add missing net_device_ops entrie=
s.
      spider_net: Add missing .ndo_validate_addr
      ucc_geth: Fix merge error.
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/kaber/nf-next-2.6
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/kaber/nf-2.6
      rndis_wlan: Fix build with netdev_ops compat disabled.
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      sparc64: Flush TLB before releasing pages.
      Merge branch 'master' of /home/davem/src/GIT/linux-2.6/
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/kaber/nf-next-2.6
      sparc64: Fix MM refcount check in smp_flush_tlb_pending().
      gianfar: Fix kfree(skb)
      Merge branch 'master' of /home/davem/src/GIT/linux-2.6/
      Merge branch 'master' of /home/davem/src/GIT/linux-2.6/
      Revert "netrom: zero length frame filtering in NetRom"
      Revert "ax25: zero length frame filtering in AX25"
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-2.6
      sparc64: We need to use compat_sys_ustat() as well.
      gianfar: Fix use-after-of_node_put() in gfar_of_init().
      ucc_geth: Fix use-after-of_node_put() in ucc_geth_probe().
      niu: Add GRO support.
      tg3: Add GRO support.
      Merge branch 'master' of /home/davem/src/GIT/linux-2.6/
      sparc64: Fix reset hangs on Niagara systems.
      Merge branch 'master' of ssh://master.kernel.org/home/ftp/pub/scm/l=
inux/kernel/git/rusty/linux-2.6-cpumask-for-sparc
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/jaswinder/net-next-2.6

David Schleef (28):
      Staging: comedi: add 8253.h header
      Staging: comedi: add 8255 driver
      Staging: comedi: add rti800 driver
      Staging: comedi: add plx9052 header file
      Staging: comedi: add nt_atmio driver
      Staging: comedi: add nt_mio_cs driver
      Staging: comedi: add nt_pcimio driver
      Staging: comedi: add das08 drivers
      Staging: comedi: add comedi_rt_timer virtual driver
      Staging: comedi: add skeleton driver
      Staging: comedi: add mpc8260 driver
      Staging: comedi: add ni_mio_common code
      Staging: comedi: add pcmad driver
      Staging: comedi: add pcl711 driver
      Staging: comedi: add cb_das16_cs driver
      Staging: comedi: add pcl725 driver
      Staging: comedi: add pcl726 driver
      Staging: comedi: add ni_6527 driver
      Staging: comedi: add ni_at_ao driver
      Staging: comedi: add ni_pcidio driver
      Staging: comedi: add das16 driver
      Staging: comedi: add dt2601 driver
      Staging: comedi: add dt2811 driver
      Staging: comedi: add dt2814 driver
      Staging: comedi: add dt2815 driver
      Staging: comedi: add dt2817 driver
      Staging: comedi: add dt282x driver
      Staging: comedi: add dt3000 driver

David Shaw (1):
      Short write in nfsd becomes a full write to the client

David Teigland (3):
      dlm: clear defunct cancel state
      dlm: ignore cancel on granted lock
      dlm: fix length calculation in compat code

David T=C3=A4ht (6):
      Staging: frontier: Make checkpatch.pl considerably happier with tra=
nzport driver.
      Staging: frontier: Make checkpatch.pl much happier with alphatrack =
driver
      Staging: frontier: removed now unused frontier_compat.h file
      Staging: frontier: Updated documentation
      Staging: frontier: Make checkpatch.pl happy with alphatrack.h
      Staging: frontier: Remove unused components of the alphatrack/tranz=
port sysfs interface.

David VomLehn (1):
      cramfs: propagate uncompression errors

David Vrabel (1):
      USB: allow libusb to talk to unauthenticated WUSB devices

David Wong (1):
      V4L/DVB (11398): Support for Legend Silicon LGS8913/LGS8GL5/LGS8GXX=
 China DMB-TH digital demodulator

David Woodhouse (36):
      solos: Fix length header in FPGA transfers
      solos: Clean up firmware loading code
      solos: Kill global 'opens' count.
      solos: Handle attribute show/store in kernel more sanely
      solos: Add initial list of parameters
      solos: Handle new line status change packets, hook up to ATM layer =
info
      solos: Kill existing connections on link down event
      solos: Reject non-AAL5 connections.... for now
      solos: Add SNR and Attn to status packet, fix oops on load
      solos: Fix under-allocation of skb size for get/set parameters
      solos: Remove parameter group from sysfs on ATM dev deregister
      solos: First attempt at DMA support
      solos: Tidy up DMA handling a little. Still untested
      solos: Tidy up tx_mask handling for ports which need TX
      solos: Remove unused loopback debug stuff
      solos: Remove IRQF_DISABLED, don't frob IRQ enable on the FPGA in s=
olos_irq()
      solos: Remove superfluous wait_queue_head_t from struct solos_param
      solos: Fix various bugs in status packet handling
      solos: Clean up handling of card->tx_mask a little
      solos: Remove debugging, commented-out test code
      solos: Add 'reset' module parameter to reset the DSL chips on load
      solos: Tidy up status interrupt handling, cope with 'ERROR' status
      solos: Don't clear config registers at startup
      solos: Set RX empty flag at startup only for !dma mode
      solos: Swap upstream/downstream rates in status packet, clean up so=
me more
      dma-debug: add function to dump dma mappings
      dma-debug: print stacktrace of mapping path on unmap error
      solos: Reset device on unload, free pending skbs
      solos: Disable DMA until we have an FPGA update with it actually im=
plemented.
      intel-iommu: Enable DMAR on 32-bit kernel.
      intel-iommu: Add for_each_iommu() and for_each_active_iommu() macro=
s
      intel-iommu: Fix device-to-iommu mapping for PCI-PCI bridges.
      intel-iommu: Handle PCI domains appropriately.
      [MTD] [NAND] Add parent info for CAF=C3=89 controller
      [MTD] [NOR] Add device parent info to physmap_of
      intel-iommu: Fix oops in device_to_iommu() when devices not found.

Davide Libenzi (10):
      epoll: fix epoll's own poll
      epoll: fix epoll's own poll (update)
      epoll: remove debugging code
      eventfd: improve support for semaphore-like behavior
      epoll keyed wakeups: add __wake_up_locked_key() and __wake_up_sync_=
key()
      epoll keyed wakeups: introduce new *_poll() wakeup macros
      epoll keyed wakeups: make sockets use keyed wakeups
      epoll keyed wakeups: teach epoll about hints coming with the wakeup=
 key
      epoll keyed wakeups: make eventfd use keyed wakeups
      epoll keyed wakeups: make tty use keyed wakeups

Davide Rizzo (1):
      hwmon: LM95241 driver

Dean Anderson (1):
      V4L/DVB (11392): patch: s2255drv driver removal problem fixed

Dean Nelson (1):
      SGI IA64 UV: fix ia64 build error in the linux-next tree

Deepika Makhija (1):
      ALSA: oss - volume control for CSWITCH and CROUTE

Denys Fedoryshchenko (1):
      ipv4: arp announce, arp_proxy and windows ip conflict verification

Devin Heitmueller (38):
      V4L/DVB (10320): dib0700: fix i2c error message to make data type c=
lear
      V4L/DVB (10321): dib0700: Report dib0700_i2c_enumeration failures
      V4L/DVB (11059): xc5000: fix bug for hybrid xc5000 devices with IF =
other than 5380
      V4L/DVB (11060): au8522: rename the au8522.c source file
      V4L/DVB (11061): au8522: move shared state and common functions int=
o a separate header files
      V4L/DVB (11062): au8522: fix register read/write high bits
      V4L/DVB (11063): au8522: power down the digital demod when not in u=
se
      V4L/DVB (11064): au8522: make use of hybrid framework so analog/dig=
ital demod can share state
      V4L/DVB (11065): au8522: add support for analog side of demodulator
      V4L/DVB (11066): au0828: add support for analog functionality in br=
idge
      V4L/DVB (11067): au0828: workaround a bug in the au0828 i2c handlin=
g
      V4L/DVB (11068): au0828: add analog profile for the HVR-850
      V4L/DVB (11069): au8522: add mutex protecting use of hybrid state
      V4L/DVB (11070): au0828: Rework the way the analog video binding oc=
curs
      V4L/DVB (11071): tveeprom: add the xc5000 tuner to the tveeprom def=
inition
      V4L/DVB (11072): au0828: advertise only NTSC-M (as opposed to all N=
TSC standards)
      V4L/DVB (11073): au0828: disable VBI code since it doesn't yet work
      V4L/DVB (11074): au0828: fix i2c enumeration bug
      V4L/DVB (11075): au0828: make register debug lines easier to read
      V4L/DVB (11076): au0828: make g_chip_ident call work properly
      V4L/DVB (11077): au0828: properly handle missing analog USB endpoin=
t
      V4L/DVB (11078): au0828: properly handle non-existent analog inputs
      V4L/DVB (11079): au0828: fix panic on disconnect if analog initiali=
zation failed
      V4L/DVB (11080): au0828: Convert to use v4l2_device/subdev framewor=
k
      V4L/DVB (11081): au0828: make sure v4l2_device name is unique
      V4L/DVB (11082): au0828: remove memset calls in v4l2 routines.
      V4L/DVB (11083): au0828: remove some unneeded braces
      V4L/DVB (11084): au0828: add entry for undefined input type
      V4L/DVB (11085): au0828/au8522: Codingstyle fixes
      V4L/DVB (11086): au0828: rename macro for currently non-function VB=
I support
      V4L/DVB (11088): au0828: finish videodev/subdev conversion
      V4L/DVB (11089): au8522: finish conversion to v4l2_device/subdev
      V4L/DVB (11139): em28xx: add remote control definition for HVR-900 =
(both versions)
      V4L/DVB (11140): usbvision: fix oops on ARM platform when allocatin=
g transfer buffers
      V4L/DVB (11141): em28xx: fix oops on ARM platform when allocating t=
ransfer buffers
      V4L/DVB (11142): au0828: fix oops on ARM platform when allocating t=
ransfer buffers
      V4L/DVB (11342): au0828: better document i2c registers
      V4L/DVB (11343): au0828: make i2c clock speed per-board configurabl=
e

Dhananjay Phadke (22):
      netxen: remove superfluous doorbell map
      netxen: fix sparse warnings
      netxen: ratelimit error prints
      netxen: firmware download support
      netxen: advertise wake-on-lan support
      netxen: cleanup unused code
      netxen: refactor pci probe
      netxen: update copyright
      netxen: support larger dma addressing
      netxen: firmware download improvements
      netxen: cleanup rx handling
      netxen: small xmit optimizations
      netxen: refactor netdev open close
      netxen: cleanup superfluous multi-context code
      netxen: annotate board_config and board_type
      netxen: fix endianness in serial number
      netxen: add suspend resume support
      netxen: sanitize variable names
      netxen: remove old lro code
      netxen: add receive side scaling (rss) support
      netxen: update version to 4.0.30
      netxen: fix firmware download warnings

Dimitri Sivanich (5):
      x86, UV: set full apicid in uv_hub_send_ipi
      x86: UV, SGI RTC: add generic system vector
      x86: UV, SGI RTC: loop through installed UV blades
      x86: UV, SGI RTC: add UV RTC clocksource/clockevents
      x86: UV, SGI RTC: fix uv_time.c for UP

Divy Le Ray (18):
      cxgb3: ease msi-x settings conditions
      cxgb3: Notify fatal errors
      iw_cxgb3: handle chip reset notifications
      cxgb3: ring rx door bell less frequently
      cxgb3: release page ref on mapping error
      cxgb3: fix skb truesize in jumbo mode
      cxgb3: prefetch buffer access in GRO mode
      cxgb3: separate TX and RX reclaim handlers
      cxgb3: disable high freq non-data interrupts
      cxgb3: Update Rev3 mac workaround
      cxgb3: detect mac link faults.
      cxgb3: update FW
      cxgb3: update driver version
      cxgb3: start qset timers when setup succeeded
      cxgb3: sge setup fixes
      cxgb3: use resource_size_t for mmio declarations
      cxgb3: differentiate portx and Tx channels
      cxgb3: map entire Rx page, feed map+offset to Rx ring.

Dmitri Vorobiev (9):
      x86: Fix a couple of sparse warnings in arch/x86/kernel/apic/io_api=
c.c
      tracing, Text Edit Lock: Fix one sparse warning in kernel/extable.c
      tracing: fix four sparse warnings
      net: Add missing include into include/linux/netdevice.h
      MIPS: Malta: make a needlessly global integer variable static
      MIPS: Fix global namespace pollution in arch/mips/kernel/smp-up.c
      MIPS: Make a needlessly global symbol static in arch/mips/kernel/sm=
p.c
      Remove two unneeded exports and make two symbols static in fs/mpage=
.c
      kexec: vmcoreinfo_data[] can become static

Dmitry Artamonow (8):
      [ARM] 5407/1: SA1100: drop broken for ages iPAQ h3800 support
      [ARM] 5408/1: SA1100: update defconfigs after h3800 removal
      [ARM] 5423/1: SA1100: remove unused H3600_SLEEVE Kconfig option
      [ARM] 5424/1: h3600: clean up mtd partitions table
      [ARM] 5425/1: h3600: first stage of ipaq_model_ops cleanup
      [ARM] 5426/1: h3600: remove clr_h3600_egpio/set_h3600_egpio helpers
      [ARM] 5427/1: h3600: ipaq_model_ops final cleanup
      ALSA: drop outdated and broken sa11xx-uda1341 driver

Dmitry Baryshkov (3):
      [ARM] 5429/1: collie: start scoop converton to new api
      [ARM] 5430/1: collie_pm: use new GPIO API to control charger
      [ARM] 5431/1: scoop: completely drop old-style SCOOP GPIO accessors

Dmitry Eremin-Solenikov (4):
      [ARM] pxa: add initial support for Cogent CSB726 board
      [ARM] pxa: add support for CSB701 baseboard
      [ARM] pxa: make second argument of clk_add_alias a name instead of =
the device
      [MTD] [MAPS] Drop now unused sharpsl-flash map

Don Skidmore (7):
      ixgbe: fix slow load times on 82598 nics
      ixgbe: add support KX/KX4 device
      ixgbe: Add 82598 support for BX mezzanine devices
      ixgbe: fix for 82598 Si errata causing buffer overflow
      ixgbe: Fix ethtool output with advertised mode.
      ixgbe: feature - driver to default with FC on.
      ixgbe: fix ethtool -A|a behavior

Don Wood (3):
      RDMA/nes: Account for freed PBL after HW operation
      RDMA/nes: Inform hardware that asynchronous event has been handled
      RDMA/nes: Improve use of PBLs

Doug Thompson (1):
      edac: remove EDAC's experimental status

Douglas Gilbert (1):
      [SCSI] bsg: add linux/types.h include to bsg.h

Douglas Kosovic (1):
      V4L/DVB (10299): bttv: Add support for IVCE-8784 support for V4L2 b=
ttv driver

Douglas Schilling Landgraf (14):
      V4L/DVB (10323): em28xx: Add entry for GADMEI TVR200
      V4L/DVB (10326): em28xx: Cleanup: fix bad whitespacing
      V4L/DVB (10327): em28xx: Add check before call em28xx_isoc_audio_de=
init()
      V4L/DVB (10517): em28xx: remove bad check (changeset a31c595188af)
      V4L/DVB (10520): em28xx-audio: Add spinlock for trigger
      V4L/DVB (10521): em28xx-audio: Add lock for users
      V4L/DVB (10523): em28xx-audio: Add macros EM28XX_START_AUDIO / EM28=
XX_STOP_AUDIO
      V4L/DVB (10524): em28xx: Add DVC 101 model to Pinnacle Dazzle descr=
iption
      V4L/DVB (10556): em28xx-cards: Add Pinnacle Dazzle Video Creator Pl=
us DVC107 description
      V4L/DVB (10739): em28xx-cards: remove incorrect entry
      V4L/DVB (10740): em28xx-cards: Add SIIG AVTuner-PVR board
      V4L/DVB (10741): em28xx: Add Kaiser Baas Video to DVD maker support
      V4L/DVB (11222): gspca - zc3xx: The webcam DLink DSB - C320 has the=
 sensor pas106.
      V4L/DVB (11331): em28xx: convert to v4l2_subdev

Dragoslav Zaric (2):
      Staging: otus: ioctl.c: Fix Coding Style
      Staging: otus: 80211core/amsdu.c: Fix Coding Style

Drew Csillag (1):
      Staging: comedi: add pcm3724 driver

Duane Griffin (7):
      ext4: don't inherit inappropriate inode flags from parent
      ext4: tighten restrictions on inode flags
      ufs: validate maximum fast symlink size from superblock
      ufs: don't truncate longer ufs2 fast symlinks
      ufs: ensure fast symlinks are NUL-terminated
      ufs: copy symlink data into the correct union member
      Staging: b3dfg: fixups and improvements

Ed Lin (5):
      [SCSI] stex: small code fixes and changes
      [SCSI] stex: add MSI support
      [SCSI] stex: use config struct for parameters of different controll=
ers
      [SCSI] stex: add new 6G controller support
      [SCSI] stex: update version to 4.6.0000.3

Ed Lin - PTU (5):
      [SCSI] stex: Fix for potential invalid response
      [SCSI] stex: Add new device id
      [SCSI] stex: Fix for controller type st_yosemite
      [SCSI] stex: Small fixes
      [SCSI] stex: Version update

Ed Swierk (3):
      x86/PCI: Detect mmconfig on nVidia MCP55
      rtc-ds1307: true SMBus compatibility
      forcedeth: Fix resume from hibernation regression.

Eduard - Gabriel Munteanu (18):
      SLUB: Replace __builtin_return_address(0) with _RET_IP_.
      kmemtrace: Core implementation.
      kmemtrace: Additional documentation.
      kmemtrace: SLAB hooks.
      kmemtrace: SLOB hooks.
      kmemtrace: SLUB hooks.
      kmemtrace: Fix typos in documentation.
      kmemtrace: Better alternative to "kmemtrace: fix printk format warn=
ings".
      kmemtrace: SLUB hooks for caller-tracking functions.
      kmemtrace: Remove the relay version of kmemtrace
      tracing: splice support for tracing_pipe
      tracing: Move pipe waiting code out of tracing_read_pipe().
      tracing: provide trace_seq_reserve()
      tracing: add missing 'extern' keywords to trace_output.h
      kmemtrace, rcu: don't include unnecessary headers, allow kmemtrace =
w/ tracepoints
      kmemtrace: use tracepoints
      kmemtrace: kmemtrace_alloc() must fill type_id
      kmemtrace: restore original tracing data binary format, improve ABI

Edward Shishkin (1):
      vfs: add/use account_page_dirtied()

Eilon Greenstein (60):
      bnx2x: New FW
      bnx2x: Multi-queue
      bnx2x: MSI support
      bnx2x: System-page alignment
      bnx2x: Disabling interrupts after iSCSI-boot
      bnx2x: Removing microcode assertion check
      bnx2x: Per queue statistics
      bnx2x: Moving skb_record_rx_queue
      bnx2x: BW shaper enhancements
      bnx2x: Flow control enhancement
      bnx2x: Removing the board type
      bnx2x: Removing redundant device parameters
      bnx2x: GPIO accessories
      bnx2x: Supporting BCM8726 PHY
      bnx2x: PHY lock list
      bnx2x: Supporting BCM8481 PHY
      bnx2x: Saving PHY FW version
      bnx2x: EMAC reset
      bnx2x: Using the HW 5th lane
      bnx2x: Removing CL73 code
      bnx2x: GMII not SGMII
      bnx2x: Pre emphasis configuration
      bnx2x: Using registers name
      bnx2x: Manual setting for MRRS
      bnx2x: Returning EBUSY in debug mode as well
      bnx2x: Increasing FW timeout
      bnx2x: smp_mb and not just smp_rmb
      bnx2x: Using nvram default WoL config
      bnx2x: Memory clean up on failure
      bnx2x: Optimize chip MPS configuration
      bnx2x: Loopback in diag mode
      bnx2x: Better struct naming
      bnx2x: Removing redundant macros
      bnx2x: Sparse endianity annotation
      bnx2x: Removing unused struct
      bnx2x: Driver dump
      bnx2x: Moving includes
      bnx2x: Re-arrange module parameters
      bnx2x: Comments and prints
      bnx2x: Clean-up
      bnx2x: Version
      bnx2x: Remove redundant smb_mb on unload
      bnx2x: Misleading name
      bnx2x: Reduce the likelihood of smb_mb
      bnx2x: Add rmb to read status block indices on load
      bnx2x: Unlimited Tx interrupt work
      bnx2x: napi_poll budget check
      bnx2x: Missing module parameter description
      bnx2x: Using DMA engine
      bnx2x: Calling tx disable unconditionally
      bnx2x: Supporting new BCM8726 FW
      bnx2x: Enable BCM8726 module transmitter
      bnx2x: BCM8705 has no microcode
      bnx2x: Display BCM8481 FW version
      bnx2x: Loopback support at external PHY
      bnx2x: Whitespace
      bnx2x: Debug prints
      bnx2x: Register dump
      bnx2x: Version update
      bnx2x: Adding licensing to bnx2x_init_values.h

Elias Oltmanns (1):
      ide: Fix code dealing with sleeping devices in do_ide_request()

Emmanuel Pacaud (1):
      Staging: comedi: add adl_pci9111 driver

Eric Anholt (10):
      drm/i915: Add information on pinning and fencing to the i915 list d=
ebug.
      drm/i915: Change DCC tiling detection case to cover only mobile par=
ts.
      drm/i915: Fix lock order reversal in GTT pwrite path.
      drm/i915: Make GEM object's page lists refcounted instead of get/fr=
ee.
      drm/i915: Fix lock order reversal in shmem pwrite path.
      drm/i915: Fix lock order reversal in shmem pread path.
      drm/i915: Fix lock order reversal with cliprects and cmdbuf in non-=
DRI2 paths.
      drm/i915: Fix lock order reversal in GEM relocation entry copying.
      drm/i915: Add information on pinning and fencing to the i915 list d=
ebug.
      drm: Use a little stash on the stack to avoid kmalloc in most DRM i=
octls.

Eric Biederman (4):
      veth: Allow setting the L3 MTU
      neigh: Allow for user space users of the neighbour table
      macvlan: Support creating macvlans from macvlans
      macvlan: Deterministic ingress packet delivery

Eric Dumazet (18):
      net: move bsockets outside of read only beginning of struct inet_ha=
shinfo
      netfilter: arp_tables: unfold two critical loops in arp_packet_matc=
h()
      netfilter: xt_physdev fixes
      netfilter: xt_physdev: unfold two loops in physdev_mt()
      netfilter: ip6_tables: unfold two loops in ip6_packet_match()
      netfilter: ip_tables: unfold two critical loops in ip_packet_match(=
)
      netfilter: xt_hashlimit fix
      tcp: allow timestamps even if SYN packet has tsval=3D0
      net: reorder fields of struct socket
      net: reorder struct Qdisc for better SMP performance
      net: remove useless prefetch() call
      netfilter: nf_conntrack: Reduce conntrack count in nf_conntrack_fre=
e()
      arp_tables: ifname_compare() can assume 16bit alignment
      netfilter: nf_conntrack: use hlist_add_head_rcu() in nf_conntrack_s=
et_hashsize()
      netfilter: factorize ifname_compare()
      netfilter: nf_conntrack: use SLAB_DESTROY_BY_RCU and get rid of cal=
l_rcu()
      netfilter: use rcu_read_bh() in ipt_do_table()
      socket: use percpu_add() while updating sockets_in_use

Eric Lammerts (1):
      [WATCHDOG] w83697ug: add error checking

Eric Leblond (7):
      netfilter: log invalid new icmpv6 packet with nf_log_packet()
      netfilter: use a linked list of loggers
      netfilter: print the list of register loggers
      netfilter: sysctl support of logger choice
      netfilter: fix warning about invalid const usage
      netfilter: fix warning in ebt_ulog init function.
      netfilter: fix nf_logger name in ebt_ulog.

Eric Miao (42):
      ASoC: make ops a pointer in 'struct snd_soc_dai'
      Merge branch 'fix' of git://git.kernel.org/pub/scm/linux/kernel/git=
/ycmiao/pxa-linux-2.6 into devel
      Merge branch 'devel' of ssh://master.kernel.org/home/rmk/linux-2.6-=
arm into devel
      [ARM] pxa: introduce pxa{25x,27x,300,320,930}.h for board usage
      [ARM] pxa: allow DMA controller IRQ being specified
      [ARM] pxa: move DMA registers definitions into <mach/dma.h>
      [ARM] pxa: move IRQ handling of GPIO 0 and 1 outside of gpio.c
      [ARM] pxa: move pxa_gpio_mode() outside of generic gpio.c
      [ARM] pxa: move GPIO register definitions into <mach/gpio.h>
      [ARM] pxa: move declaration of 'pxa_last_gpio' into <mach/gpio.h>
      [ARM] pxa: access GPIO registers by chip so to make it further gene=
ric
      [ARM] pxa: remove machine class specific stuffs from serial driver
      [ARM] pxa: remove unnecessary #include of pxa-regs.h and hardware.h
      [ARM] pxa: move PCMCIA definitions out of pxa-regs.h into pxa2xx_ba=
se.c
      [ARM] pxa: make lubbock specific debugging stuffs back into lubbock=
.c
      [ARM] pxa: move pxa2xx chip selects definitions out of pxa-regs.h
      [ARM] pxa: separate definitions from pxa-regs.h and remove it final=
ly
      [ARM] pxa: fix typo in BANK_OFF() macro in gpio.h
      [ARM] pxa: fix overlay being un-necessarily initialized on pxa25x
      Merge branch 'fix' of git://git.kernel.org/pub/scm/linux/kernel/git=
/ycmiao/pxa-linux-2.6.git into devel
      [ARM] pxa: introduce plat-pxa for PXA common code and add DMA suppo=
rt
      [ARM] pxa: move common GPIO handling code into plat-pxa
      [ARM] pxa: move common MFP handling code into plat-pxa
      [ARM] pxa: add base support for Marvell's PXA168 processor line
      [ARM] pxa: add iWMMXt support for pxa168
      [ARM] pxa: add GPIO support for pxa168
      [ARM] pxa: add MFP support for pxa168
      [ARM] pxa: allow reuse of serial driver for pxa168
      [ARM] pxa/aspenite: add support for console uart
      [ARM] pxa/aspenite: add support for debug ethernet
      [ARM] pxa: add base support for Marvell PXA910
      [ARM] pxa: add base support for pxa910-based TavorEVB
      [ARM] pxa: add base support for pxa910-based TTC_DKB
      [ARM] pxa: add defconfig for pxa168-based platforms
      [ARM] pxa: add defconfig for pxa910-based platforms
      MAINTAINERS: update pxa168 maintainers
      MAINTAINERS: update pxa910 maintainers
      platform: make better use of to_platform_{device,driver}() macros
      platform: introduce module id table for platform devices
      [ARM] pxa: build arch/arm/plat-pxa/mfp.c only when PXA3xx or ARCH_M=
MP defined
      backlight: fix pwm_bl.c when multiple PWM backlights exist
      spi: pxa2xx_spi: introduce chipselect GPIO to simplify the common c=
ases

Eric Moore (3):
      [SCSI] mpt2sas: add MPT2SAS_MINOR(221) to miscdevice.h
      [SCSI] mpt2sas v00.100.11.15
      [SCSI] mpt2sas: make global symbols unique

Eric Paris (16):
      SELinux: call capabilities code directory
      SELinux: better printk when file with invalid label found
      SELinux: NULL terminate al contexts from disk
      SELinux: check seqno when updating an avc_node
      SELinux: remove the unused ae.used
      SELinux: more careful use of avd in avc_has_perm_noaudit
      SELinux: remove unused av.decided field
      SELinux: code readability with avc_cache
      SELinux: convert the avc cache hash list to an hlist
      SELinux: open perm for sock files
      SELinux: new permission between tty audit and audit socket
      SELinux: inode_doinit_with_dentry drop no dentry printk
      Btrfs: introduce btrfs_show_options
      audit: incorrect ref counting in audit tree tag_chunk
      audit: audit_set_auditable defined but not used
      Audit: remove spaces from audit_log_d_path

Eric Sandeen (6):
      stackprotector: use canary at end of stack to indicate overruns at =
oops time
      [XFS] Remove the rest of the macro-to-function indirections.
      [XFS] remove always-true #ifndef HAVE_FORMAT32 tests
      don't reallocate sxp variable passed into xfs_swapext
      filesystem freeze: allow SysRq emergency thaw to thaw frozen filesy=
stems
      add fiemap.h to header-y

Eric Sesterhenn (4):
      UBIFS: list usage cleanup
      MISDN: list usage cleanup
      [S390] list usage cleanup in s390
      Staging: et131x: list usage cleanup

Eric W. Biederman (17):
      tun: Remove unnecessary tun_get_by_name
      tun: Fix races in tun_set_iff
      tun: Use POLLERR not EBADF in tun_chr_poll
      tun: Introduce tun_file
      tun: Grab the netns in open.
      tun: Make tun_net_xmit atomic wrt tun_attach && tun_detach
      tun: Move read_wait into tun_file
      tun: Fix races between tun_net_close and free_netdev.
      tun: There is no longer any need to deny changing network namespace=
s
      tun: Implement ip link del tunXXX
      netns: Fix icmp shutdown.
      tcp: Like icmp use register_pernet_subsys
      netns: Remove net_alive
      PCI: pcie_portdriver: fix pcie_port_device_remove
      sysfs: Take sysfs_mutex when fetching the root inode.
      sysfs: reference sysfs_dirent from sysfs inodes
      sysfs: don't block indefinitely for unmapped files.

Erik Andr?n (24):
      V4L/DVB (11403): gspca - m5602-s5k4aa: No more "default" mode
      V4L/DVB (11404): gspca - m5602-s5k4aa: Add start function and VGA r=
esolution init.
      V4L/DVB (11405): gspca - m5602: Simplify error handling
      V4L/DVB (11406): gspca - m5602-ov9650: Add QCIF resolution support
      V4L/DVB (11407): gspca - m5602-ov9650: Clean up ov9650_start() func=
tion.
      V4L/DVB (11409): gspca - m5602-ov9650: Set the ov9650 sensor in sof=
t sleep when inactive.
      V4L/DVB (11410): gspca - m5602-ov9650: Always init the ov9650 befor=
e starting a stream
      V4L/DVB (11411): gspca - m5602: Rework v4l ctrl handling in all sen=
sors
      V4L/DVB (11412): gspca - m5602-ov9650: Checkpatch fixes
      V4L/DVB (11413): gspca - m5602-mt9m111: Separate mode vectors per s=
ensor.
      V4L/DVB (11414): gspca - m5602-mt9m111: Move v4l2 controls to main =
sensor file.
      V4L/DVB (11415): gspca - m5602: Remove an unused member in the sd s=
truct.
      V4L/DVB (11416): gspca - m5602: Constify all sensor structs
      V4L/DVB (11417): gspca - m5602-ov9650: Autogain is on by default
      V4L/DVB (11418): gspca - m5602-ov9650: Auto white balancing is on b=
y default
      V4L/DVB (11419): gspca - m5602-ov9650: Don't read exposure data fro=
m COM1.
      V4L/DVB (11420): gspca - m5602: Improve error handling in the ov965=
0 driver
      V4L/DVB (11421): gspca - m5602-ov9650: Synthesize modesetting.
      V4L/DVB (11422): gspca - m5602-ov9650: Replace a magic constant wit=
h a define
      V4L/DVB (11423): gspca - m5602-ov9650: Add a disconnect hook, setup=
 a ctrl cache ctrl.
      V4L/DVB (11424): gspca - m5602-ov9650: Use the local ctrl cache. Ad=
just image on vflip.
      V4L/DVB (11425): gspca - m5602: Move the vflip quirk to probe stage.
      V4L/DVB (11426): gspca - m5602: Don't touch hflip/vflip register on=
 Read/Modify/Write
      V4L/DVB (11427): gspca - m5602: Minor cleanups

Erik Andren (3):
      V4L/DVB (10334): gspca - stv06xx: Rework control description.
      V4L/DVB (10341): gspca - stv06xx: Plug a memory leak in the pb0100 =
sensor driver.
      V4L/DVB (10342): gspca - stv06xx: Add ctrl caching to the vv6410.

Erik Andr=C3=A9n (10):
      Staging: agnx: Fixup agnx.h checkpatch warnings
      Staging: agnx: Fixup debug.h checkpatch warnings
      Staging: agnx: Fixup pci.c checkpatch warnings
      Staging: agnx: Fixup phy.c checkpatch warnings
      Staging: agnx: Fixup rf.c checkpatch warnings
      Staging: agnx: Fixup sta.c checkpatch warnings
      Staging: agnx: Fixup sta.h checkpatch warnings
      Staging: agnx: Fixup table.c checkpatch warnings
      Staging: agnx: Fixup xmit.c checkpatch warnings
      Staging: altpciechdma: checkpatch fixups

Erik Ekman (2):
      pnpbios: fix warning if CONFIG_HOTPLUG=3Dn
      pnpbios: propagate kthread_run() error

Erik Inge Bols=C3=B8 (4):
      include/linux/ata.h: add some more transfer masks
      [libata] convert drivers to use ata.h mode mask defines
      pata_radisys: fix mwdma_mask to exclude mwdma0
      pata_efar: fix *dma_mask

Erik S. Beiser (1):
      V4L/DVB (10826): cx88: Add IR support to pcHDTV HD3000 & HD5500

Etienne Basset (2):
      smack: convert smack to standard linux lists
      smack: Add a new '-CIPSO' option to the network address label confi=
guration

Evan Ko (1):
      Staging: add phison ATA driver to the tree

Everett Wang (1):
      Staging: comedi: add s526 driver

Evgeniy Polyakov (24):
      inet: Allowing more than 64k connections and heavily optimize bind(=
0) time.
      Staging: dst: core files.
      Staging: dst: network state machine.
      Staging: dst: export node.
      Staging: dst: thread pool.
      Staging: dst: transactions.
      Staging: dst: crypto processing.
      Staging: dst: kconfig and makefile changes.
      Staging: dst: kconfig update.
      Staging: DST: optimize bio allocation.
      Staging: DST: extend thread pool exit conditions.
      Staging: DST: Do not allow empty barriers.
      Staging: DST: Kconfig text update.
      Staging: DST: fix build dependancy
      Staging: pohmelfs: documentation.
      Staging: pohmelfs: configuration interface.
      Staging: pohmelfs: crypto processing.
      Staging: pohmelfs: directory operations.
      Staging: pohmelfs: inode operations.
      Staging: pohmelfs: distributed locking and cache coherency protocol.
      Staging: pohmelfs: network operations.
      Staging: pohmelfs: transaction layer.
      Staging: pohmelfs: kconfig/makefile and vfs changes.
      Staging: pohmelfs: select crypto modules from the config.

FUJITA Tomonori (42):
      add map/unmap_single_attr and map/unmap_sg_attr to struct dma_mappi=
ng_ops
      add dma_mapping_ops for SBA IOMMU
      add dma_mapping_ops for SWIOTLB and SBA IOMMU
      add dma_mapping_ops for intel-iommu
      add dma_mapping_ops for SGI Altix
      add dma_mapping_ops for SWIOTLB
      set up dma_ops appropriately
      convert the DMA API to use dma_ops
      remove dma operations in struct ia64_machine_vector
      make sn DMA mapping functions static
      add dma_get_ops to struct ia64_machine_vector
      remove hwsw_dma_ops
      make sba DMA mapping functions static
      x86: add map_page and unmap_page to struct dma_mapping_ops
      x86, swiotlb: add map_page and unmap_page
      x86, gart: add map_page and unmap_page
      x86, calgary: add map_page and unmap_page
      x86, AMD IOMMU: add map_page and unmap_page
      intel-iommu: add map_page and unmap_page
      x86, pci-nommu: add map_page
      x86: remove map_single and unmap_single in struct dma_mapping_ops
      generic: add common struct for dma map operations
      x86, ia64: convert to use generic dma_map_ops struct
      x86, ia64: remove duplicated swiotlb code
      convert to use generic dma_map_ops struct, cleanup
      IA64: fix compile error on IA64_DIG_VTD
      IA64: fix swiotlb alloc_coherent for non DMA_64BIT_MASK devices
      IA64: fix VT-d dma_mapping_error
      intel-iommu: make dma mapping functions static
      AMD IOMMU: remove unnecessary ifdef
      [SCSI] libfc: fix compile warning
      [SCSI] osst: make all the buffer the same size
      [SCSI] osst: replace scsi_execute_async with the block layer API
      [SCSI] remove scsi_req_map_sg
      [SCSI] sg: avoid blk_put_request/blk_rq_unmap_user in interrupt
      [SCSI] sg: remove unnecessary function declarations
      [SCSI] sg: use ALIGN macro
      [SCSI] sg: remove the own list management for struct sg_fd
      dma-debug: warn of unmapping an invalid dma address
      remove unused include/asm-generic/dma-mapping.h
      [SCSI] sg: fix iovec bugs introduced by the block layer conversion
      [SCSI] sg: fix q->queue_lock on scsi_error_handler path

Faisal Latif (2):
      RDMA/nes: Remove LLTX
      RDMA/nes: Handle MPA Reject message properly

Felipe Balbi (5):
      ARM: OMAP: get rid of OMAP_TAG_USB, v2
      ARM: OMAP3: MUSB initialization for omap hw, v2
      USB: composite: avoid inconsistent lock state
      leds: Add gpio-led trigger
      leds: introduce lp5521 led driver

Felipe Contreras (1):
      omapfb: fix argument of blank operation

Felix Beck (1):
      [S390] Add zcrypt section in MAINTAINERS

Felix Blyakher (26):
      Merge branch 'master' of git+ssh://oss.sgi.com/oss/git/xfs/xfs
      [XFS] Warn on transaction in flight on read-only remount
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6
      xfs: Update maintainers
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6
      Merge branch 'master' of git://git.kernel.org/pub/scm/fs/xfs/xfs
      Merge branch 'master' of git://git.kernel.org/pub/scm/fs/xfs/xfs
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6
      Merge branch 'master' of git://git.kernel.org/pub/scm/fs/xfs/xfs
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6
      Revert "[XFS] use scalable vmap API"
      Revert "[XFS] remove old vmap cache"
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6
      Fix xfs debug build breakage by pushing xfs_error.h after
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6
      Merge branch 'master' of git://git.kernel.org/pub/scm/fs/xfs/xfs
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6
      xfs: increase the maximum number of supported ACL entries
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6
      Merge branch 'master' of git://git.kernel.org/pub/scm/fs/xfs/xfs
      Revert "xfs: increase the maximum number of supported ACL entries"
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6 into for-linus

Felix Fietkau (1):
      ath5k: properly free rx dma descriptors

Fenghua Yu (4):
      iwlwifi: dma mapping read and write changes
      Intel IOMMU Suspend/Resume Support - DMAR
      Intel IOMMU Suspend/Resume Support - Queued Invalidation
      Intel IOMMU Suspend/Resume Support - Interrupt Remapping

Flavio Leitner (1):
      i2c-piix4: Add support for the Broadcom HT1100 chipset

Florian Fainelli (5):
      au1000: reorder functions
      pata-rb532-cf: platform_get_irq() fix ignored failure
      r6040: Fix second PHY address
      Bump release date to 25Mar2009 and version to 0.22
      MIPS: Au1000: convert to using gpiolib

Florian Westphal (2):
      netfilter: ctnetlink: remove remaining module refcounting
      netfilter: remove nf_ct_l4proto_find_get/nf_ct_l4proto_put

Francesco VIRLINZI (5):
      sh: clkfwk: add clk_set_parent/clk_get_parent
      sh: clkfwk: Add resume from hibernation support.
      sh: PMB hibernation support
      sh: clkfwk: Safer resume from hibernation.
      sh: Sanitize asm/mmu.h for assembly use.

Francois Romieu (1):
      tg3: remove extra casting

Frank Blaschka (6):
      lcs: convert to net_device_ops
      ctcm: convert to net_device_ops
      netiucv: convert to net_device_ops
      claw: convert to net_device_ops
      qeth: add statistics for tx csum
      qeth: remove EDDP

Frank Mori Hess (13):
      Staging: comedi: add National Instruments infrastructure
      Staging: comedi: add ni_labpc drivers
      Staging: comedi: add gsc_hpdi driver
      Staging: comedi: add das16m1 driver
      Staging: comedi: add cb_pcidas64 driver
      Staging: comedi: add das1800 driver
      Staging: comedi: add das800 driver
      Staging: comedi: add ni_at_a2150 driver
      Staging: comedi: Added reading of board serial number from eeprom f=
or m-series boards
      Staging: comedi: usbduxfast bugfix
      Staging: comedi: Fixed minor numbers for subdevice files.
      Staging: comedi: Added some validation of comedi module parameter v=
alues.
      Staging: comedi: fix bug with invalid minor number usage.

Frank Munzert (2):
      [S390] Automatic IPL after dump
      [S390] Use csum_partial in checksum.h

Frank Seidel (8):
      airo: reduce stack memory footprint
      iwlwifi: reduce stack size
      PCI: add missing KERN_* constants to printks
      USB: add missing KERN_* constants to printks
      i2c: Add missing KERN_* constants to printks
      i2c: Adapt debug macros for KERN_* constants
      hwmon: (hdaps) Allow inversion of separate axis
      hwmon: (hdaps) Fix Thinkpad X41 axis inversion

Frans Pop (2):
      hp-wmi: notify of a potential docking state change on resume
      PCI PM: Consistently use variable name "error" for pm call return v=
alues

Fred Brooks (1):
      Staging: comedi: add ni_daq_700 driver

Frederic Weisbecker (62):
      tracing/function-graph-tracer: strip ending newlines on comments
      hrtimers: increase clock min delta threshold while interrupt hangin=
g
      tracing/ftrace: provide the base infrastructure for histogram traci=
ng
      tracing/branch-tracer: adapt to the stat tracing API
      tracing/kmemtrace: normalize the raw tracer event to the unified tr=
acing API
      tracing/ftrace: fix a memory leak in stat tracing
      tracing/ftrace: handle more than one stat file per tracer
      tracing/ftrace: separate events tracing and stats tracing engine
      tracing: add a new workqueue tracer
      tracing/function-graph-tracer: fix a regression while suspend to di=
sk
      tracing/function-graph-tracer: various fixes and features
      x86: micro-optimize __raw_read_trylock()
      connector: create connector workqueue only while needed once
      trace: better manage the context info for events
      tracing/blktrace: move the tracing file to kernel/trace
      tracing/function-graph-tracer: provide a selftest for the function =
graph tracer
      tracing/power: move the power trace headers to a dedicated file
      tracing/function-graph-tracer: drop the kernel_text_address check
      tracing/function-graph-tracer: handle the leaf functions from trace=
_pipe
      softlockup: ensure the task has been switched out once
      tracing/sysprof: add missing tracing_{start,stop}_record_cmdline()
      tracing/core: use appropriate waiting on trace_pipe
      tracing/core: remove unused parameter in tracing_fill_pipe_page()
      tracing/function-graph-tracer: fix traces weirdness while absolute =
time printing
      tracing/function-graph-tracer: provide documentation for the functi=
on graph tracer
      tracing/function-graph-tracer: make set_graph_function file support=
 ftrace regex
      tracing/markers: make markers select tracepoints
      tracing/core: introduce per cpu tracing files
      tracing/core: make the read callbacks reentrants
      tracing/core: make the per cpu trace files in per cpu directories
      tracing/function-graph-tracer: use the more lightweight local clock
      sched: don't rebalance if attached on NULL domain
      vsprintf: unify the format decoding layer for its 3 users
      tracing/core: drop the old trace_printk() implementation in favour =
of trace_bprintk()
      vsprintf: fix bug in negative value printing
      tracing/core: bring back raw trace_printk for dynamic formats strin=
gs
      tracing/ftrace: syscall tracing infrastructure, basics
      tracing/x86: basic implementation of syscall tracing for x86
      tracing/syscalls: support for syscalls tracing on x86
      tracing/syscalls: core infrastructure for syscalls tracing, enhance=
ments
      tracing/syscalls: fix missing release of tracing
      tracing/syscalls: various cleanups
      tracing/syscalls: protect thread flag toggling from races
      tracing/syscalls: select kallsysms
      tracing/core: fix missing mutex unlock on tracing_set_tracer()
      tracing/ftrace: fix double calls to tracing_start()
      tracing/core: fix early free of cpumasks
      tracing/ftrace: fix the check on nopped sites
      tracing/ftrace: stop {irqs, preempt}soff tracers when tracing is st=
opped
      tracing/ring-buffer: fix non cpu hotplug case
      tracing/ring-buffer: don't annotate rb_cpu_notify with __cpuinit
      tracing/function-graph-tracer: prevent hangs during self-tests
      tracing: keep the tracing buffer after self-test failure
      tracing/events: make the filter files writable
      tracing/events: don't use wake up for events
      tracing/ftrace: make nop-tracer use polling wait for events on pipe
      tracing/events: don't discard an event after commit
      debugfs: function to know if debugfs is initialized
      tracing/ftrace: check if debugfs is registered before creating file=
s
      tracing/function-graph-tracer: fix functions call traces imbalance
      tracing/ftrace: fix missing include string.h
      tracing/ftrace: alloc the started cpumask for the trace file

Frederik Deweerdt (1):
      x86, tlb flush_data: replace per_cpu with an array

Gabor Juhos (20):
      ath9k: use signed format to print HAL status
      ath9k: convert to struct device
      ath9k: convert to use bus-agnostic DMA routines
      ath9k: introduce bus specific cache size routine
      ath9k: introduce bus specific cleanup routine
      ath9k: move PCI code into separate file
      ath9k: introduce platform driver for AHB bus support
      ath9k: get EEPROM contents from platform data on AHB bus
      ath9k: remove (u16) casts from rtc register access
      ath9k: fix ar5416Addac_9100 values
      ath9k: fix null pointer dereference in ani monitor code
      ath9k: enable support for AR9100
      ath9k: fix AR_TXCFG_DMASZ_MASK value
      ath9k: create a common debugfs_root for all device instances
      ath9k: cleanup AR5416 version checking macros
      ath9k: move ar9100 version checking macros into a more appropriate =
place
      ath9k: fix AR_SREV_9100_OR_LATER macro
      ath9k: fix compile error in ahb.c
      ath9k: fix compile error in debug.c
      ath9k: always compile ath_radio_{en,dis}able

Gabriel Paubert (1):
      powerpc: Disable mv643xx Ethernet port 0 on Pegasos

Gabriele Paoloni (1):
      ppp: ppp_mp_explode() redesign

Gautham R Shenoy (11):
      sched: Simple helper functions for find_busiest_group()
      sched: Fix indentations in find_busiest_group() using gotos
      sched: Define structure to store the sched_group statistics for fbg=
()
      sched: Create a helper function to calculate sched_group stats for =
fbg()
      sched: Define structure to store the sched_domain statistics for fb=
g()
      sched: Create a helper function to calculate sched_domain stats for=
 fbg()
      sched: Create helper to calculate small_imbalance in fbg()
      sched: Create a helper function to calculate imbalance
      sched: Optimize the !power_savings_balance during fbg()
      sched: Refactor the power savings balance code
      sched: Add comments to find_busiest_group() function

Geert Uytterhoeven (23):
      netlink: Move netlink attribute parsing support to lib
      crypto: compress - Add pcomp interface
      crypto: testmgr - Add support for the pcomp interface
      crypto: zlib - New zlib crypto module, using pcomp
      crypto: testmgr - add zlib test
      PCI: Use kzalloc() in pci_create_bus()
      m68k: Use dma_addr_t for scatterlist.dma_address
      m68k: Restore correct include guards for <asm/unaligned.h>
      dnet: drivers/net/dnet.c needs <linux/io.h>
      scsi/m68k: Kill NCR_700_detect() warnings
      MAINTAINERS: Replace dead link to m68k CVS repository by link to ne=
w git repository
      m68k: irq_node.handler() should return irqreturn_t
      wireless/p54: P54_SPI should depend on GENERIC_HARDIRQS
      ide: drivers/ide/ide-atapi.c needs <linux/scatterlist.h>
      parisc: rtc: get_rtc_time() returns unsigned int
      parisc: rtc: platform_driver_probe() fixups
      parisc: rtc: Add missing module alias
      parisc: rtc: Rename rtc-parisc to rtc-generic
      m68k: Hook up rtc-generic
      powerpc: Hook up rtc-generic, and kill rtc-ppc
      powerpc/ps3: Add rtc-ps3
      V4L/DVB (11392a): Remove reference to obsolete linux-dvb-dJidKbW2IEvF2uMehF1BdA@public.gmane.org=
g
      powerpc: Correct dependency of KEXEC

Geoff Levand (2):
      powerpc: Add missing DABR flags
      powerpc/ps3: Print memory hotplug errors

George G. Davis (1):
      [ARM] 5440/1: Fix VFP state corruption due to preemption during VFP=
 exceptions

Gerald Schaefer (1):
      [S390] kernel: Disable switch_amode by default

Gerd Hoffmann (5):
      KVM: Fix kvmclock on !constant_tsc boxes
      preadv/pwritev: create compat_readv()
      preadv/pwritev: create compat_writev()
      preadv/pwritev: Add preadv and pwritev system calls.
      preadv/pwritev: switch compat readv/preadv/writev/pwritev from fget=
 to fget_light

Gerhard Pircher (4):
      powerpc/amigaone: Add platform support for AmigaOne
      powerpc/amigaone: Generic device tree for all AmigaOne boards
      powerpc/amigaone: Bootwrapper and serial console support for AmigaO=
ne
      powerpc/amigaone: Default config for AmigaOne boards

Gerrit Renker (6):
      dccp: Initialisation framework for feature negotiation
      dccp: Implement both feature-local and feature-remote Sequence Wind=
ow feature
      dccp: Initialisation and type-checking of feature sysctls
      dccp: Debugging functions for feature negotiation
      dccp: Minimise header option overhead in setting the MPS
      dccp: Do not let initial option overhead shrink the MPS

Gilles Espinasse (1):
      ide: be able to build pmac driver without IDE built-in

Giridhar Malavali (4):
      [SCSI] qla2xxx: Consolidate queuecommand implementations.
      [SCSI] qla2xxx: Initialize FCE debugfs codes with the proper vha st=
ructure.
      [SCSI] qla2xxx: Correct over-allocation of firmware-dump buffer.
      [SCSI] qla2xxx: Drop use of IRQF_DISABLE.

Giuliano Pochini (4):
      powerpc/powermac: Hotplug /sys entries are missing
      ALSA: echoaudio: remove line-out volume from vmixer cards
      ALSA: echoaudio: remove line-out volume from vmixer cards
      ALSA: Echoaudio: add support for Indigo express cards

Giuseppe GORGOGLIONE (1):
      USB: musb: fix init oops crash with static FIFO config

Gleb Natapov (2):
      KVM: Report IRQ injection status to userspace.
      KVM: Report IRQ injection status for MSI delivered interrupts

Gong Jun (2):
      hwmon: (w83627ehf) Add support for W83667HG
      hwmon: (w83627ehf) Only expose in6 or temp3 on the W83667HG

Graf Yang (2):
      net: fix some trailing whitespaces
      blackfin: Subtract ANOMALY_05000230 on quot

Graff Yang (1):
      [MTD] [CHIPS] cfi_cmdset_0001.c: Fix a bug in inval_cache_and_wait_=
for_operation().

Grant Erickson (1):
      edac: new ppc4xx driver module

Grant Likely (15):
      powerpc/5200: Stop using device_type and port-number properties
      powerpc/5200: Trim cruft from device trees
      powerpc/5200: Don't specify IRQF_SHARED in PSC UART driver
      powerpc/5200: Remove pr_debug() from hot paths in irq driver
      powerpc/5200: Refactor mpc5200 interrupt controller driver
      powerpc/5200: Rework GPT driver to also be an IRQ controller
      powerpc/5200: Add support for the Media5200 board from Freescale
      powerpc/5200: Add 'simple-bus' to the of_platform probe list.
      powerpc/4xx: update ml507 .dts file to release reference design
      powerpc/5200: remove sysfs debug file from GPT driver
      powerpc/bootwrapper: add fixed-head.o to simpleimage wrappers
      powerpc/cpm2: fix building fs_enet driver as a module.
      powerpc: Remove unused symbols from fsl_devices.h
      net/fec_mpc52xx: fix BUG on missing dma_ops
      net/fec_mpc52xx: Don't dereference phy_device if it is NULL

Grazvydas Ignotas (3):
      ASoC: Update OMAP3 pandora board file
      ARM: OMAP3: mmc-twl4030 add MMC3 support, v2
      omap_hsmmc: Fix MMC3 dma

Greg Banks (7):
      knfsd: remove the nfsd thread busy histogram
      knfsd: avoid overloading the CPU scheduler with enormous load avera=
ges
      knfsd: add file to export stats about nfsd pools
      Dynamic debug: allow simple quoting of words
      Dynamic debug: fix pr_fmt() build error
      Document /proc/fs/nfsd/pool_stats
      Fix a build warning about leaking CONFIG_NFSD to userspace.

Greg Kroah-Hartman (145):
      USB: serial: opticon: add write support
      USB: serial: opticon: add serial line ioctls
      USB: serial: add symbol serial driver
      USB: symbolserial: log the ioctl commands
      USB: serial: add qualcomm wireless modem driver
      USB: make transfer_buffer_lengths in struct urb field u32
      USB: make actual_length in struct urb field u32
      USB: remove phidget drivers from kernel tree.
      USB: serial: rename cp2101 driver to cp210x
      PS3: replace bus_id usage
      driver core: create a private portion of struct device
      driver core: move klist_children into private structure
      driver core: move knode_driver into private structure
      driver core: move knode_bus into private structure
      Staging: slicoss: remove TRUE/FALSE usage
      Staging: slicoss: remove jiffies macros
      Staging: slicoss: remove DEBUG_REGISTER_TRACE
      Staging: slicoss: remove WRITE_REG64 wrapper
      Staging: slicoss: remove WRITE_REG wrapper
      Staging: slicoss: remove slic_os.h
      Staging: slicoss: remove unused #defines
      Staging: slicoss: delete slicbuild.h
      Staging: slicoss: clean up SLIC_DUMP_ENABLED
      Staging: slicoss: remove SLIC_GET_STATS_TIMER_ENABLED
      Staging: slicoss: delete slicinc.h
      Staging: slicoss: remove SLIC_GET_STATS_ENABLED
      Staging: slicoss: add proper KERN_DEBUG to 2 printks
      Staging: slicoss: remove SLIC_POWER_MANAGEMENT_ENABLED
      Staging: slicoss: remove LINUX_FREES_ADAPTER_RESOURCES
      Staging: slicoss: remove SLIC_PING_TIMER_ENABLED
      Staging: slicoss: remove VALID_ADDRESS macro
      Staging: slicoss: remove DBG_MSG
      Staging: slicoss: remove SLIC_ETHTOOL_SUPPORT
      Staging: slicoss: remove SLICLEVEL and SLIC_DISPLAY macros
      Staging: slicoss: remove DBG_ERROR macro
      Staging: slicoss: remove ASSERTMSG macro
      Staging: slicoss: delete slicdbg.h
      Staging: slicoss: slichw.h cleanup
      Staging: sxg: fix build warnings in sxg_ethtool
      Staging: sxg: remove firmware files from sgx_ethtool.c
      Staging: sxg: fix build warnings in downloadB firmware files
      Staging: sxg: fix build warnings in sxg.c
      Staging: go7007: fix build error
      Staging: rtl8187se: fix \r\n line ends
      staging: dst: replace bus_id with dev_set_name
      Staging: add aten2011 usb to serial converter driver.
      Staging: aten2011: run lindent
      Staging: aten2011: move .h files into the driver
      Staging: aten2011: remove kernel version dependencies
      Staging: aten2011: fix up comments by removing most of them.
      Staging: aten2011: remove unneeded defines
      Staging: aten2011: remove function prototypes.
      Staging: aten2011: fix up sparse warnings
      Staging: aten2011: remove unused fields from structures.
      Staging: aten2011: clean up init and exit functions
      Staging: aten2011: remove paranoia check functions
      Staging: aten2011: fix up the set_reg_sync function
      Staging: aten2011: fix up the get_reg_sync function
      Staging: aten2011: fix up the set_uart_reg function
      Staging: aten2011: fix up the get_uart_reg function
      Staging: aten2011: delete the Dump_serial_port function
      Staging: aten2011: remove wrappers around serial get and put data f=
unctions
      Staging: aten2011: fix up c++ comments
      Staging: aten2011: remove DPRINTK macro
      Staging: aten2011: s/__FUNCTION__/__func__
      Staging: aten2011: fix checkpatch errors and warnings
      Staging: phison: fix up checkpatch and other formatting issues
      Staging: phison: port code to work properly with latest libata
      Staging: phison: add driver to the build system
      Staging: comedi: fix bus_id use in jr3_pci driver
      Staging: comedi: add c6xdigio driver
      Staging: comedi: add new drivers to the kernel build
      Staging: comedi: addi-data header file cleanups
      Staging: comedi: addi-data: APCI1710_82x54 cleanups
      Staging: comedi: fix 64bit build errors
      Staging: epl: remove unneeded files
      Staging: epl: remove complier macros from global.h
      Staging: epl: remove NULL from global.h
      Staging: epl: remove PUBLIC definition
      Staging: epl: remove _WIN_32_ and _NO_OS_ defines
      Staging: epl: remove INLINE mess
      Staging: epl: remove __KERNEL__ checks
      Staging: epl: unwind rest of _LINUX_ #ifdefs
      Staging: epl: remove EplObjDef.h
      Staging: epl: remove GENERIC
      Staging: epl: remove NEAR
      Staging: epl: remove FAR
      Staging: epl: remove ROM
      Staging: epl: remove MEM
      Staging: epl: remove REENTRANT
      Staging: epl: remove compiler warning from SharedBuff.c
      Staging: epl: remove some unused types
      Staging: epl: remove CONST
      Staging: epl: delete EdrvFec5282.h
      Staging: epl: remove BYTE
      Staging: epl: remove QWORD
      Staging: epl: remove DWORD
      Staging: epl: remove WORD
      Staging: epl: fix up some non-ANSI functions
      Staging: epl: clean up demo_main.c
      Staging: epl: remove kernel version checks
      Staging: epl: fix sparse warning in proc_fs.c
      Staging: epl: remove EPLDLLEXPORT
      Staging: epl: fix up epl/user/*.h files
      Staging: epl: fix up epl/kernel/*.h files
      Staging: epl: don't check for devfs
      Staging: epl: remove pointless highres timer check
      Staging: p9auth: fix credential logic
      Staging: p9auth: add to the kernel build
      Staging: p9auth: remove unneeded header file
      Staging: p9auth: fix up codingstyle issues
      Staging: p9auth: fix up sparse warnings
      Staging: p9auth: use kzalloc
      Staging: p9auth: clean up #includes
      Staging: heci: remove kcompat.h
      Staging: heci: fix checkpatch warnings
      Staging: heci: fix some sparse warnings
      Staging: heci: add TODO file
      Staging: add rt3070 wireless driver
      Staging: line6: fix bus_id usage
      Staging: line6: add to the build
      Staging: line6: remove DEVICE_ATTRIBUTE
      Staging: line6: remove PT_REGS
      Staging: line6: remove KERNEL_VERSION checks
      Staging: line6: static function cleanups
      Staging: line6: fix up NULL assignment mistakes
      Staging: line6: coding style cleanups for .h files.
      Staging: line6: fix checkpatch errors in capture.c
      Staging: line6: fix checkpatch errors in control.c
      Staging: line6: fix checkpatch errors in playback.c
      Staging: line6: fix checkpatch errors in pod.c
      Staging: line6: fix checkpatch errors in audio.c
      Staging: line6: fix checkpatch errors in driver.c
      Staging: line6: fix checkpatch errors in dumprequest.c
      Staging: line6: fix checkpatch errors in midi.c
      Staging: line6: fix checkpatch errors in midibuf.c
      Staging: line6: fix checkpatch errors in pcm.c
      Staging: line6: fix checkpatch errors in toneport.c
      Staging: line6: fix checkpatch errors in variax.c
      staging: document that the wifi staging drivers a bit better
      Staging: add USB serial Quatech driver
      Staging: serqt_usb: Lindent the code
      Staging: serqt_usb: add TODO file
      Staging: serqt_usb: fix checkpatch errors
      Staging: serqt_usb: fix build due to proc tty changes

Greg Ungerer (40):
      fec: add FEC platform support to ColdFire CPU's setup code
      m68knommu: remove ColdFire specific setup code from FEC driver
      m68knommu: mark all RAM as ZONE_DMA
      m68knommu: add a local dma_sync_single_for_cpu() function
      m68k: use the mmu pci.h for m68knommu as well
      m68k: swtich non-mmu setups to use the mmu dma-mapping.h
      m68k: use the mc146818rtc.h for non-mmu setups as well.
      m68k: use mmu kmap_types.h for non-mmu setups as well
      m68knommu: remove no longer used mcfpci.h
      m68k: merge the mmu and non-mmu versions of mmu.h
      m68k: use mmu scatterlist.h for non-mmu setups as well
      m68k: use mmu fpu.h for non-mmu builds as well
      m68k: use mmu timex.h for non-mmu setups as well
      m68k: use mmu version of elf.h for non-mmu builds as well
      m68k: use non-mmu version of unaligned.h for all m68k
      m68k: the one hw_irq.h can be used buy all m68k
      m68k: merge the mmu and non-mmu versions of page_offset.h
      m68knommu: mv definition of check_pgt_cache()
      m68k: merge the mmu and non-mmu versions of pgalloc.h
      m68k: merge the mmu and non-mmu versions of ucontext.h
      m68k: merge the mmu and non-mmu versions of segment.h
      m68k: merge the mmu and non-mmu versions of fb.h
      m68k: use the mmu version of bootinfo.h for m68knommu as well
      m68k: use the mmu version of cache.h for m68knommu as well
      m68k: merge the mmu and non-mmu versions of bug.h
      m68k: merge the mmu and non-mmu versions of bugs.h
      m68k: merge the mmu and non-mmu versions of div64.h
      m68k: merge the mmu and non-mmu versions of current.h
      m68k: merge the mmu and non-mmu versions of mmu_context.h
      m68knommu: add missing interrupt line definition for UART 2
      m68k: merge the mmu and non-mmu versions of module.h
      m68knommu: introduce basic clk infrastructure
      m68k: merge the mmu and non-mmu versions of tlbflush.h
      m68knommu: switch to using generic_handle_irq()
      m68knommu: fix end of uart table marker
      m68knommu: fix 5249 ColdFire UART setup
      m68knommu: fix 5249 ColdFire UART vector setup
      m68knommu: fix 5307 ColdFire UART vector setup
      m68knommu: fix 5407 ColdFire UART vector setup
      m68knommu: improve compile arch switch settings

Gregorio Guidi (1):
      ALSA: hda - fix headphone settings and master volume (Conexant CX20=
551)

Gregory Haskins (13):
      sched: cleanup inc/dec_rt_tasks
      sched: track the next-highest priority on each runqueue
      sched: use highest_prio.curr for pull threshold
      sched: use highest_prio.next to optimize pull operations
      sched: only try to push a task on wakeup if it is migratable
      sched: pull only one task during NEWIDLE balancing to limit critica=
l section
      sched: make double-lock-balance fair
      sched: add sched_class->needs_post_schedule() member
      plist: fix PLIST_NODE_INIT to work with debug enabled
      sched: create "pushable_tasks" list to limit pushing to one attempt
      RT: fix push_rt_task() to handle dequeue_pushable properly
      sched: de CPP-ify the scheduler code
      sched: fix build error in kernel/sched_rt.c when RT_GROUP_SCHED && =
!SMP

Grzegorz Bernacki (3):
      powerpc/5200: Add support for the digsy MTC board.
      powerpc/5200: Add digsy-mtc support to mpc5200_defconfig
      powerpc/5200: On the digsy-mtc, configure PSC4 and PSC5 as UARTs

Grzegorz Nosek (1):
      cgroups: relax ns_can_attach checks to allow attaching to grandchil=
d cgroups

Guennadi Liakhovetski (23):
      i.MX31: framebuffer driver
      mxc: first set GPIO level, then switch direction to output
      dma: ipu_idmac driver cosmetic clean-up
      dma: improve section assignment in i.MX31 IPU DMA driver
      dma: i.MX31 IPU DMA robustness improvements
      V4L/DVB (10665): soc-camera: add data signal polarity flags to driv=
ers
      V4L/DVB (10672): sh_mobile_ceu_camera: include NV* formats into the=
 format list only once.
      V4L/DVB (10673): mt9t031: fix gain and hflip controls, register upd=
ate, and scaling
      V4L/DVB (10674): soc-camera: camera host driver for i.MX3x SoCs
      V4L/DVB (10675): soc-camera: extend soc_camera_bus_param_compatible=
 with more tests
      V4L/DVB (11024): soc-camera: separate S_FMT and S_CROP operations
      V4L/DVB (11025): soc-camera: configure drivers with a default forma=
t on open
      V4L/DVB (11026): sh-mobile-ceu-camera: set field to the value, conf=
igured at open()
      V4L/DVB (11027): soc-camera: configure drivers with a default forma=
t at probe time
      dma: Add SoF and EoF debugging to ipu_idmac.c, minor cleanup
      leds: allow led-drivers to use a variable range of brightness value=
s
      leds: Add dac124s085 driver
      V4L/DVB (11323): pxa-camera: simplify the .buf_queue path by mergin=
g two loops
      V4L/DVB (11325): soc-camera: fix breakage caused by 1fa5ae857bb14f6=
046205171d98506d8112dd74e
      V4L/DVB (11326): mt9m001: fix advertised pixel clock polarity
      V4L/DVB (11347): mt9t031: use platform power hook
      V4L/DVB (11349): mx3-camera: adapt the clock definition and the dri=
ver to the new clock naming
      fbdev: i.MX31: fix panning, error handling, clean up

Guillaume Knispel (1):
      printk: correct the behavior of printk_timed_ratelimit()

Guo-Fu Tseng (5):
      jme: Modifies messages to display correct hardware version
      jme: Fix pci sync
      jme: Clear all modified GHC register flags
      jme: Adding {64,40}bits DMA mask back
      jme: Advance version number after previous changes

Gustavo F. Padovan (8):
      x86, fixmap: rename __FIXADDR_SIZE and __FIXADDR_BOOT_SIZE
      x86, fixmap: define FIXADDR_BOOT_* and redefine FIX_ADDR_SIZE
      x86, fixmap: define reserve_top_address for x86_64
      x86, fixmap: add CONFIG_X86_{LOCAL,IO}_APIC
      x86, fixmap: add CONFIG_EFI
      x86, fixmap: prepare fixmap_64.h for unification
      x86, fixmap: prepare fixmap_32.h for unification
      x86, fixmap: unify fixmap.h

H Hartley Sweeten (1):
      auxdisplay: remove PARPORT dependency

H. Peter Anvin (45):
      bzip2/lzma: use a table to search for initramfs compression formats
      bzip2/lzma: handle failures from bzip2 and lzma correctly
      bzip2/lzma: make config machinery an arch configurable
      bzip2/lzma: proper Kconfig dependencies for the ramdisk options
      bzip2/lzma: DECOMPRESS_GZIP should select ZLIB_INFLATE
      bzip2/lzma: move initrd/ramfs options out of BLK_DEV
      bzip2/lzma: fix constant in decompress_inflate
      bzip2/lzma: centralize format detection
      bzip2/lzma: comprehensible error messages for missing decompressor
      init: make initrd/initramfs decompression failure a KERN_EMERG even=
t
      bzip2/lzma: update boot protocol specification
      x86: clean up stray space in <asm/processor.h>
      x86: handle PAT more like other CPU features
      x86: filter CPU features dependent on unavailable CPUID levels
      Merge branch 'core/percpu' into x86/paravirt
      x86 setup: a20: early timeout for a nonexistent keyboard controller
      Merge branch 'core/percpu' into x86/paravirt
      x86: merge sys_rt_sigreturn between 32 and 64 bits
      x86: truncate ISA addresses to unsigned int
      x86, mce: use %ll instead of %L for 64-bit numbers
      x86, mce: remove invalid __cpuinit/__cpuexit annotations
      Merge branch 'x86/urgent' into x86/mce2
      x86, mce, cmci: remove incorrect __cpuinit/__cpuexit annotations
      x86, mce: enable machine checks in 32-bit defconfig
      Merge branch 'x86/defconfig' into x86/mce2
      Merge branch 'x86/core' into x86/mce2
      Merge branch 'x86/core' into x86/mce2
      x86: remove zImage support
      x86: remove additional vestiges of the zImage/bzImage split
      x86: use targets in the boot Makefile instead of CLEAN_FILES
      x86: move brk initialization out of #ifdef CONFIG_BLK_DEV_INITRD
      x86-32: tighten the bound on additional memory to map
      x86-32: move _end to a dummy section
      x86, setup: move 32-bit code to .text32
      x86, setup: fix the setting of 480-line VGA modes
      compiler-gcc4: conditionalize #error on __KERNEL__
      bzip2/lzma: move CONFIG_RD_* options under CONFIG_EMBEDDED
      bzip2/lzma: clarify the meaning of the CONFIG_RD_ options
      bzip2/lzma: consistently capitalize LZMA in Kconfig
      bzip2/lzma: don't ask for compression mode for the default initramf=
s
      x86, setup: preemptively save/restore edi and ebp around INT 15 E82=
0
      x86, setup: ACPI 3, BIOS workaround for E820-probing code
      bzip2/lzma: quiet Kconfig warning for INITRAMFS_COMPRESSION_NONE
      x86, setup: guard against pre-ACPI 3 e820 code not updating %ecx
      x86, setup: compile with -DDISABLE_BRANCH_PROFILING

Haavard Skinnemoen (2):
      avr32: fix out-of-range rjmp instruction on large kernels
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6 into avr32-arch

Hagen Paul Pfeifer (2):
      netfilter: nf_conntrack: table max size should hold at least table =
size
      netfilter: fix hardcoded size assumptions

Han, Weidong (4):
      intel-iommu: fix PCI device detach from virtual machine
      intel-iommu: set compatibility format interrupt
      x86, dmar: check if it's initialized before disable queue invalidat=
ion
      x2apic/intr-remap: decouple interrupt remapping from x2apic

Hannes Eder (86):
      kernel/irq: fix sparse warning: make symbol static
      tracing: fix sparse warnings: make symbols static
      tracing: fix sparse warnings: fix (un-)signedness
      tracing: fix sparse warning: attribute function with __acquires/__r=
eleases
      drivers/isdn/hardware/mISDN: fix sparse warnings: make symbols stat=
ic
      drivers/isdn/mISDN: fix sparse warnings: make symbols static
      drivers/isdn/hardware/mISDN: change type of hfc_jiffies to unsigned=
 long
      drivers/net/at1700.c: fix sparse warning: symbol shadows an earlier=
 one
      drivers/net/e2100.c: fix sparse warning: symbol shadows an earlier =
one
      drivers/net/ni65.c: fix sparse warnings: symbol shadows an earlier =
one
      drivers/net/ns83820.c: fix sparse warnings: fix signedness
      drivers/net/niu.c: fix sparse warning: symbol shadows an earlier on=
e
      drivers/net/lance.c: fix sparse warnings: fix signedness
      drivers/net/ni65.c: fix sparse warnings: fix signedness
      drivers/net/ppp*.c: fix sparse warnings: fix signedness
      drivers/net/r6040.c: fix sparse warning: Using plain integer as NUL=
L pointer
      drivers/net/s2io.c: fix sparse warning: symbol shadows an earlier o=
ne
      drivers/net/arcnet: fix sparse warning: symbol shadows an earlier o=
ne
      drivers/net/atl1e: fix sparse warnings: fix signedness
      drivers/net/atlx: fix sparse warnings: fix signedness
      drivers/net/bonding: fix sparse warnings: context imbalance
      drivers/net/bonding: fix sparse warning: symbol shadows an earlier =
one
      drivers/net/cxgb3: fix sparse warning: symbol shadows an earlier on=
e
      drivers/net/cxgb3: fix sparse warnings: fix signedness
      drivers/net/e1000e: fix sparse warning: Should it be static?
      drivers/net/hamradio: fix warning: format not a string literal and =
no ...
      drivers/net/hamradio: fix sparse warning: context imbalance
      drivers/net/hamradio: fix sparse warning: symbol shadows an earlier=
 one
      drivers/net/hamradio: fix sparse warnings: fix signedness
      drivers/net/ixgbe: fix sparse warning: Should it be static?
      drivers/net/pcmcia: fix warning: format not a string literal and no=
 ...
      drivers/net/sfc: fix sparse warning: symbol shadows an earlier one
      drivers/net/skfp: fix sparse warning: Should it be static?
      drivers/net/tokenring: fix warning: format not a string literal and=
 no ...
      drivers/net/tokenring: fix sparse warning: symbol shadows an earlie=
r one
      drivers/net/tulip: fix warning: format not a string literal and no =
...
      drivers/net/tulip: fix sparse warning: symbol shadows an earlier on=
e
      drivers/net/usb: fix sparse warnings: Should it be static?
      drivers/net/wan: fix warning: format not a string literal and no ...
      drivers/net/wan: fix sparse warning: symbol shadows an earlier one
      drivers/net/wireless: fix sparse warning: context imbalance
      drivers/net/wireless: fix sparse warnings: symbol shadows an earlie=
r one
      drivers/net/wireless: fix sparse warnings: fix signedness
      drivers/net/wireless/ath9k: fix sparse warnings: Should it be stati=
c?
      drivers/net/wireless/b43: fix warning: format not a string literal =
and no ...
      drivers/net/wireless/ipw2x00: fix sparse warnings: fix signedness
      drivers/net/wireless/prism54: fix sparse warning: fix signedness
      drivers/net/tokenring: fix sparse warning: cast truncates bits from=
 const value
      drivers/net/sfc: fix sparse warnings: Should it be static?
      drivers/net/igb: fix sparse warning: symbol shadows an earlier one
      ipv6: fix sparse warning: Using plain integer as NULL pointer
      x86: kexec/i386: fix sparse warnings: Using plain integer as NULL p=
ointer
      x86: numa_32.c: fix sparse warning: Using plain integer as NULL poi=
nter
      sound/oss: fix sparse warnings: different signedness
      sound/oss: fix sparse warning: symbol shadows an earlier one
      ALSA: sound/usb/usx2y: fix sparse warning: Should it be static?
      ALSA: sound/usb/usx2y: fix sparse warning: do-while statement is no=
t a compound ...
      ALSA: sound/drivers/vx: fix sparse warning: different signedness
      ALSA: sound/pci/emu10k1: fix sparse warning: different signedness
      ALSA: sound/pci/hda: fix sparse warning: different signedness
      net/802: fix sparse warnings: context imbalance
      9p: fix sparse warning: cast adds address space
      appletalk: fix warning: format not a string literal and no ...
      sysctl: fix sparse warning: Should it be static?
      decnet: fix sparse warnings: context imbalance
      decnet: fix sparse warnings: symbol shadows an earlier one
      inet fragments: fix sparse warning: context imbalance
      wanrouter: fix sparse warnings: context imbalance
      drivers/isdn/capi: fix sparse warning: context imbalance
      drivers/isdn/act2000: fix sparse warning: symbol shadows an earlier=
 one
      drivers/isdn/hisax: fix sparse warning: Should it be static?
      drivers/isdn/hardware/icon: fix sparse warning: cast truncates bits
      drivers/isdn/hardware/eicon: fix sparse warnings: Should it be stat=
ic?
      IOMMU-API: use ANSI style function declaration for 'iommu_found'
      xfs: move declaration to header file
      xfs: make symbols static
      xfs: include header files for prototypes
      drm/radeon: NULL noise: drivers/gpu/drm/radeon/radeon_*.c
      KVM: fix sparse warnings: context imbalance
      KVM: fix sparse warnings: Should it be static?
      GFS2: fix sparse warnings: constant is so big it is ...
      GFS2: fix sparse warning: Should it be static?
      USB: host: fix sparse warning: Using plain integer as NULL pointer
      trivial: NULL noise: drivers/media/dvb/frontends/drx397xD_fw.h
      trivial: NULL noise: drivers/mtd/tests/mtd_*test.c
      init/main.c: fix sparse warnings: context imbalance

Hannes Hering (1):
      ehea: Fix: Remove adapter from adapter list in error path

Hannes Reinecke (2):
      [SCSI] Check for deleted device in scsi_device_online()
      [SCSI] aic7xxx: leaves timer running on init failure

Hans J. Koch (1):
      UIO: Add name attributes for mappings and port regions

Hans Verkuil (194):
      V4L/DVB (10231): v4l2-subdev: add v4l2_ext_controls support
      V4L/DVB (10244): v4l2: replace a few snprintfs with strlcpy
      V4L/DVB (10246): saa6752hs: convert to v4l2_subdev.
      V4L/DVB (10247): saa7134: convert to the new v4l2 framework.
      V4L/DVB (10249): v4l2-common: added v4l2_i2c_tuner_addrs()
      V4L/DVB (10251): cx25840: add comments explaining what the init() d=
oes.
      V4L/DVB (10252): v4l2 doc: explain why v4l2_device_unregister_subde=
v() has to be called.
      V4L/DVB (10271): saa7146: convert to video_ioctl2.
      V4L/DVB (10272): av7110: test type field in VIDIOC_G_SLICED_VBI_CAP
      V4L/DVB (10291): em28xx: fix VIDIOC_G_CTRL when there is no msp34xx=
 device.
      V4L/DVB (10313): saa7146: fix VIDIOC_ENUMSTD.
      V4L/DVB (10406): gspca: fix compiler warning
      V4L/DVB (10408): v4l2: fix incorrect hue range check
      V4L/DVB (10409): v4l: remove unused I2C_DRIVERIDs.
      V4L/DVB (10486): ivtv/cx18: fix g_fmt and try_fmt for raw video
      V4L/DVB (10487): doc: update hm12 documentation.
      V4L/DVB (10488): ivtv: cleanup naming conventions
      V4L/DVB (10489): doc: use consistent naming conventions for vdev an=
d v4l2_dev.
      V4L/DVB (10490): v4l2: prefill ident and revision from v4l2_dbg_chi=
p_ident.
      V4L/DVB (10496): saa7146: implement v4l2_device support.
      V4L/DVB (10497): saa7146: i2c adapdata now points to v4l2_device.
      V4L/DVB (10498): saa7146: the adapter class will be NULL when v4l2_=
subdev is used.
      V4L/DVB (10499): saa7146: convert saa7146 and mxb in particular to =
v4l2_subdev.
      V4L/DVB (10500): saa7146: setting control while capturing should re=
turn EBUSY, not EINVAL.
      V4L/DVB (10501): saa7146: prevent unnecessary loading of v4l2-commo=
n.
      V4L/DVB (10502): saa7146: move v4l2 device registration to saa7146_=
vv.
      V4L/DVB (10536): saa6588: convert to v4l2-i2c-drv-legacy.h
      V4L/DVB (10537): saa6588: convert to v4l2_subdev.
      V4L/DVB (10538): saa6588: add g_chip_ident support.
      V4L/DVB (10539): saa6588: remove legacy_class, not needed for saa65=
88
      V4L/DVB (10540): cx2341x: fixed bug causing several audio controls =
to be no longer listed
      V4L/DVB (10542): v4l2-subdev: add querystd and g_input_status
      V4L/DVB (10544): v4l2-common: add comments warning that about the s=
ort order
      V4L/DVB (10641): v4l2-dev: remove limit of 32 devices per driver in=
 get_index()
      V4L/DVB (10642): vivi: update comment to reflect that vivi can now =
create more than 32 devs.
      V4L/DVB (10643): v4l2-device: allow a NULL parent device when regis=
tering.
      V4L/DVB (10644): v4l2-subdev: rename dev field to v4l2_dev
      V4L/DVB (10645): vivi: introduce v4l2_device and do several cleanup=
s
      V4L/DVB (10646): vivi: controls are per-device, not global.
      V4L/DVB (10647): vivi: add slider flag to controls.
      V4L/DVB (10685): v4l2: add colorfx support to v4l2-common.c, and ad=
d to 'Changes' in spec.
      V4L/DVB (10686): v4l2: add V4L2_CTRL_FLAG_WRITE_ONLY flag.
      V4L/DVB (10687): v4l2-common/v4l2-spec: support/document write-only=
 and button controls
      V4L/DVB (10691): v4l2-common: add v4l2_i2c_subdev_addr()
      V4L/DVB (10692): usbvision: convert to v4l2_device/v4l2_subdev.
      V4L/DVB (10698): v4l2-common: remove v4l2_ctrl_query_fill_std
      V4L/DVB (10700): saa7115: don't access reg 0x87 if it is not presen=
t.
      V4L/DVB (10701): saa7185: add colorbar support.
      V4L/DVB (10702): saa7115: add querystd and g_input_status support f=
or zoran.
      V4L/DVB (10703): zoran: convert to video_ioctl2 and remove 'ready_t=
o_be_freed' hack.
      V4L/DVB (10704): zoran: remove broken BIGPHYS_AREA and BUZ_HIMEM co=
de, and allow for kmallocs > 128 kB
      V4L/DVB (10705): zoran: use slider flag with volume etc. controls.
      V4L/DVB (10706): zoran: fix field typo.
      V4L/DVB (10707): zoran: set bytesperline to 0 when using MJPEG.
      V4L/DVB (10708): zoran: remove old V4L1 ioctls, use v4l1-compat ins=
tead.
      V4L/DVB (10709): zoran: set correct parent of the video device.
      V4L/DVB (10710): zoran: cleanups in an attempt to make the source a=
 bit more readable.
      V4L/DVB (10711): zoran: fix TRY_FMT support
      V4L/DVB (10712): zoran: fix G_FMT
      V4L/DVB (10713): zoran: if reqbufs is called with count =3D=3D 0, d=
o a streamoff.
      V4L/DVB (10714): zoran et al: convert zoran i2c modules to V4L2.
      V4L/DVB (10715): zoran: clean up some old V4L1 left-overs and remov=
e the MAP_NR macro.
      V4L/DVB (10716): zoran: change buffer defaults to something that wo=
rks with tvtime
      V4L/DVB (10717): zoran: TRY_FMT and S_FMT now do the same parameter=
 checks.
      V4L/DVB (10718): bt866: convert to v4l2_subdev.
      V4L/DVB (10719): bt819: convert to v4l2_subdev.
      V4L/DVB (10720): bt819: that delay include is needed after all.
      V4L/DVB (10721): bt856: convert to v4l2_subdev.
      V4L/DVB (10722): ks0127: convert to v4l2_subdev.
      V4L/DVB (10723): ks0127: add supported ks0127 variants to the i2c d=
evice list.
      V4L/DVB (10724): saa7110: convert to v4l2_subdev.
      V4L/DVB (10725): saa7185: convert to v4l2_subdev.
      V4L/DVB (10726): vpx3220: convert to v4l2_subdev.
      V4L/DVB (10727): adv7170: convert to v4l2_subdev.
      V4L/DVB (10728): adv7175: convert to v4l2-subdev.
      V4L/DVB (10729): zoran: convert to v4l2_device/v4l2_subdev.
      V4L/DVB (10730): v4l-dvb: cleanup obsolete references to v4l1 heade=
rs.
      V4L/DVB (10731): zoran i2c modules: remove i2c autoprobing support.
      V4L/DVB (10732): zoran: s_jpegcomp should return a proper result, n=
ot 0.
      V4L/DVB (10733): zoran: increase bufsize to a value suitable for 76=
8x576.
      V4L/DVB (10858): vino: convert to video_ioctl2.
      V4L/DVB (10859): vino: minor renames
      V4L/DVB (10860): saa7191: convert to v4l2-i2c-drv-legacy.h
      V4L/DVB (10861): vino/indycam/saa7191: convert to i2c modules to V4=
L2.
      V4L/DVB (10862): indycam: convert to v4l2_subdev
      V4L/DVB (10863): saa7191: convert to v4l2_subdev.
      V4L/DVB (10864): vino: introduce v4l2_device.
      V4L/DVB (10865): vino: convert to v4l2_subdev.
      V4L/DVB (10866): saa7191, indycam: remove compat code.
      V4L/DVB (10868): vino: add note that this conversion is untested.
      V4L/DVB (10873): w9968cf: add v4l2_device.
      V4L/DVB (10874): w9968cf/ovcamchip: convert to v4l2_subdev.
      V4L/DVB (10880): radio-aimslab: convert to v4l2_device.
      V4L/DVB (10881): radio-aztech: convert to v4l2_device.
      V4L/DVB (10882): radio-cadet: convert to v4l2_device.
      V4L/DVB (10883): radio-gemtek-pci: convert to v4l2_device.
      V4L/DVB (10884): radio-gemtek: convert to v4l2_device.
      V4L/DVB (10885): radio-maestro: convert to v4l2_device.
      V4L/DVB (10886): radio-maxiradio: convert to v4l2_device.
      V4L/DVB (10887): radio-rtrack2: convert to v4l2_device.
      V4L/DVB (10888): radio-sf16fmi: convert to v4l2_device.
      V4L/DVB (10889): radio-sf16fmr2: convert to v4l2_device.
      V4L/DVB (10890): radio-terratec: convert to v4l2_device.
      V4L/DVB (10891): radio-trust: convert to v4l2_device.
      V4L/DVB (10892): radio-typhoon: convert to v4l2_device.
      V4L/DVB (10893): radio-zoltrix: convert to v4l2_device.
      V4L/DVB (10894): ISA radio drivers: improve kernel log message
      V4L/DVB (10909): tvmixer: remove last remaining references to this =
deleted module.
      V4L/DVB (10910): videodev2.h: remove deprecated VIDIOC_G_CHIP_IDENT=
_OLD
      V4L/DVB (10912): vivi: fix compile warning.
      V4L/DVB (10914): v4l2: fix compile warnings when printing u64 value.
      V4L/DVB (10919): tlv320aic23b: use v4l2-i2c-drv.h instead of drv-le=
gacy.h
      V4L/DVB (10920): v4l2-ioctl: fix partial-copy code.
      V4L/DVB (10921): msp3400: remove obsolete V4L1 code
      V4L/DVB (10959): radio: remove uaccess include
      V4L/DVB (10960): omap24xxcam: don't set vfl_type.
      V4L/DVB (10962): fired-avc: fix printk formatting warning.
      V4L/DVB (10965): ivtv: bump version
      V4L/DVB (10980): doc: improve the v4l2-framework documentation.
      V4L/DVB (10983): v4l2-common: add missing i2c_unregister_device.
      V4L/DVB (10987): cx23885: fix crash on non-netup cards
      V4L/DVB (10988): v4l2-dev: use parent field if the v4l2_device has =
no parent set.
      V4L/DVB (11021): v4l2-device: add a notify callback.
      V4L/DVB (11022): zoran/bt819: use new notify functionality.
      V4L/DVB (11044): v4l2-device: add v4l2_device_disconnect
      V4L/DVB (11045): v4l2: call v4l2_device_disconnect in USB drivers.
      V4L/DVB (11046): bttv: convert to v4l2_device.
      V4L/DVB (11047): cx88: convert to v4l2_device.
      V4L/DVB (11048): zoran: fix incorrect return type of notify functio=
n.
      V4L/DVB (11051): v4l-dvb: replace remaining references to the old m=
ailinglist.
      V4L/DVB (11052): bt819: remove an unused header
      V4L/DVB (11053): saa7134: set v4l2_dev field of video_device
      V4L/DVB (11098): v4l2-common: remove incorrect MODULE test
      V4L/DVB (11100): au8522: fix compilation warning.
      V4L/DVB (11112): v4l2-subdev: add support for TRY_FMT, ENUM_FMT and=
 G/S_PARM.
      V4L/DVB (11113): ov7670: convert to v4l2_subdev
      V4L/DVB (11114): cafe_ccic: convert to v4l2_device.
      V4L/DVB (11115): cafe_ccic: use v4l2_subdev to talk to the ov7670 s=
ensor.
      V4L/DVB (11116): ov7670: cleanup and remove legacy code.
      V4L/DVB (11117): ov7670: add support to get/set registers
      V4L/DVB (11118): cafe_ccic: replace debugfs with g/s_register ioctl=
s.
      V4L/DVB (11120): cafe_ccic: stick in a comment with a request for t=
est results
      V4L/DVB (11253): saa7134: fix RTD Embedded Technologies VFG7350 sup=
port.
      V4L/DVB (11254): cs53l32a: remove legacy support.
      V4L/DVB (11255): dst_ca: fix compile warning.
      V4L/DVB (11256): dabusb: fix compile warning.
      V4L/DVB (11275): tvaudio: fix mute and s/g_tuner handling
      V4L/DVB (11276): tvaudio: add tda9875 support.
      V4L/DVB (11277): tvaudio: always call init_timer to prevent rmmod c=
rash.
      V4L/DVB (11278): bttv: convert to v4l2_subdev since i2c autoprobing=
 will disappear.
      V4L/DVB (11279): bttv: tda9875 is no longer used by bttv, so remove=
 from bt8xx/Kconfig.
      V4L/DVB (11281): bttv: move saa6588 config to the helper chip confi=
g
      V4L/DVB (11282): saa7134: add RDS support.
      V4L/DVB (11283): saa6588: remove legacy code.
      V4L/DVB (11295): cx23885: convert to v4l2_device.
      V4L/DVB (11297): cx23885: convert to v4l2_subdev.
      V4L/DVB (11298): cx25840: remove legacy code for old-style i2c API
      V4L/DVB (11300): cx88: convert to v4l2_subdev.
      V4L/DVB (11301): wm8775: remove legacy code for old-style i2c API
      V4L/DVB (11302): tda9875: remove legacy code for old-style i2c API
      V4L/DVB (11303): tda7432: remove legacy code for old-style i2c API
      V4L/DVB (11304): v4l2: remove v4l2_subdev_command calls where they =
are no longer needed.
      V4L/DVB (11305): cx88: prevent probing rtc and ir devices
      V4L/DVB (11309): cx25840: cleanup: remove intermediate 'ioctl' step
      V4L/DVB (11310): cx18: remove intermediate 'ioctl' step
      V4L/DVB (11311): v4l: replace 'ioctl' references in v4l i2c drivers
      V4L/DVB (11312): tuner: remove V4L1 code from this driver.
      V4L/DVB (11313): v4l2-subdev: add enum_framesizes and enum_frameint=
ervals.
      V4L/DVB (11314): au8522: remove unused I2C_DRIVERID
      V4L/DVB (11315): cx25840: fix 'unused variable' warning.
      V4L/DVB (11316): saa7191: tuner ops wasn't set.
      V4L/DVB (10982): cx231xx: fix compile warning
      V4L/DVB (10989): cx25840: cx23885 detection was broken
      V4L/DVB (11361): msp3400: remove i2c legacy code
      V4L/DVB (11362): saa7115: remove i2c legacy code
      V4L/DVB (11363): tvp5150: remove i2c legacy code.
      V4L/DVB (11364): tuner: remove i2c legacy code.
      V4L/DVB (11365): tvaudio: remove i2c legacy code
      V4L/DVB (11366): v4l: remove obsolete header and source
      V4L/DVB (11367): v4l2-common: remove legacy code
      V4L/DVB (11368): v4l2-subdev: move s_standby from core to tuner.
      V4L/DVB (11369): v4l2-subdev: add load_fw and use that instead of a=
busing core->init.
      V4L/DVB (11370): v4l2-subdev: move s_std from tuner to core.
      V4L/DVB (11371): v4l2: remove legacy fields in v4l2-i2c-drv.h.
      V4L/DVB (11372): v4l2: use old-style i2c API for kernels < 2.6.26 i=
nstead of < 2.6.22
      V4L/DVB (11374): v4l2-common: add v4l2_i2c_new_probed_subdev_addr
      V4L/DVB (11373): v4l2-common: add explicit v4l2_device pointer as f=
irst arg to new_(probed)_subdev
      V4L/DVB (11375): v4l2: use v4l2_i2c_new_probed_subdev_addr where ap=
propriate.
      V4L/DVB (11376): tvaudio.h: add static inline to retrieve the list =
of possible i2c addrs.
      V4L/DVB (11377): v4l: increase version numbers of drivers converted=
 to v4l2_subdev.
      V4L/DVB (11379): mxb: fix copy-and-paste bug in mute.
      V4L/DVB (11380): v4l2-subdev: change s_routing prototype
      V4L/DVB (11381): ivtv/cx18: remove VIDIOC_INT_S_AUDIO_ROUTING debug=
 support.
      V4L/DVB (11390): 2-dev.c: return 0 for NULL open and release callba=
cks

Hans Werner (1):
      V4L/DVB (10392): lnbp21: documentation about the system register

Hans de Goede (4):
      V4L/DVB (11221): gspca - sonixj: Prefer sonixj instead of sn9c102 f=
or 0471:0327.
      i2c-i801: Instantiate FSC hardware montioring chips
      hwmon: (fschmd) Add support for the FSC Syleus IC
      hwmon: (fschmd) Add support for the FSC Hades IC

Hans-Christian Egtvedt (25):
      ALSA: Add ALSA driver for Atmel Audio Bitstream DAC
      ALSA: Add ALSA driver for Atmel AC97 controller
      ALSA: Add Atmel ALSA drivers directory
      atmel-mci: fix sdc_reg typo
      avr32: fix 15-bit LCDC pin mask to use MSB lines
      avr32: add pin mask for 18-bit color on the LCD controller
      avr32: set pin mask to alternative 18 bpp for EVKLCD10x boards
      avr32: configure MCI detect and write protect pins for EVKLCD10x bo=
ards
      avr32: use GPIO line PB15 on EVKLCD10x boards for backlight
      avr32: fix timing LCD parameters for EVKLCD10X boards
      atmel-usba-udc: use gpio_is_valid() to check vbus_pin I/O line
      avr32: use gpio_is_valid() to check USBA vbus_pin I/O line
      avr32: at32ap700x: setup DMA for ABDAC in the machine code
      avr32: at32ap700x: setup DMA for AC97C in the machine code
      dw_dmac: add cyclic API to DW DMA driver
      ALSA: snd-atmel-ac97c: cleanup register definitions
      ALSA: snd-atmel-ac97c: remove dead break statements after return in=
 switch case
      ALSA: snd-atmel-ac97c: do not overwrite OCA and ICA when assigning =
channels
      ALSA: snd-atmel-ac97c: set correct size for buffer hardware paramet=
er
      ALSA: snd-atmel-ac97c: enable interrupts to catch events for error =
reporting
      ALSA: snd-atmel-ac97c: do a proper reset of the external codec
      ALSA: snd-atmel-ac97c: cleanup registers when removing driver
      ALSA: snd-atmel-ac97c: replace bus_id with dev_name()
      ALSA: snd-atmel-abdac: replace bus_id with dev_name()
      ALSA: snd-atmel-abdac: increase periods_min to 6 instead of 4

Hantzis Fotis (1):
      tcp: tcp_init_wl / tcp_update_wl argument cleanup

Harald Jenny (1):
      sony-laptop: VGN-A317M hotkey support

Harald Welte (2):
      panasonic-laptop: Fix autoloading
      panasonic-laptop: use snprintf with PAGE_SIZE in sysfs attributes

Harish Zunjarrao (2):
      [SCSI] qla2xxx: Use byte-address while reading FC boot code version=
s from flash.
      [SCSI] qla2xxx: Get FLT address in dword format.

Harry Ciao (8):
      edac: AMD8111 driver header file
      edac: AMD8111 driver source file
      edac: Add edac_pci_alloc_index()
      pci: Add AMD8111 PCI Bridge PCI Device ID
      edac: AMD8131 driver header file
      edac: AMD8131 driver source file
      edac: AMD8131 driver Kconfig & Makefile
      edac: AMD8111 driver Kconfig & Makefile

Hartley Sweeten (2):
      [ARM] 5371/1: ep93xx: add i2c device to edb9307a
      [ARM] 5406/1: ep93xx: remove unneeded header in ohci-ep93xx.c

Harvey Harrison (19):
      IB: Remove __constant_{endian} uses
      typhoon: replace users of __constant_{endian}
      bnx2: annotate bp->phy_lock functions
      prism54: remove private implementation of le32_add_cpu
      wimax: replace uses of __constant_{endian}
      net: replace uses of __constant_{endian}
      wireless: replace uses of __constant_{endian}
      ALSA: echoaudio - replace uses of __constant_{endian}
      rndis: remove private wrapper of __constant_cpu_to_le32
      net: replace __constant_{endian} uses in net headers
      wimax: replace uses of __constant_{endian}
      nfs: replace uses of __constant_{endian}
      PCI: __FUNCTION__ is gcc-specific, use __func__
      USB: replace uses of __constant_{endian}
      netfilter: fix endian bug in conntrack printks
      netpoll: store local and remote ip in net-endian
      kernel: remove HIPQUAD()
      ntfs: remove private wrapper of endian helpers
      [SCSI] replace __inline with inline

Heiko Carstens (26):
      sysrq: include interrupt.h instead of irq.h
      s390: remove arch specific smp_send_stop()
      hwrng: timeriomem - Breaks an allyesconfig build on s390:
      qeth: fix wait_event_timeout handling
      [S390] page fault: invoke oom-killer
      [S390] dasd: enable compat ioctls
      [S390] move sysinfo.c from drivers/s390 to arch/s390/kernel
      [S390] delete drivers/s390/ebcdic.c
      [S390] arch/s390/kernel/process.c: fix whitespace damage
      [S390] cputime: initialize per thread timer values on fork
      [S390] ftrace: dont trace machine check handler
      [S390] split/move machine check handler code
      [S390] Remove CONFIG_MACHCHK_WARNING.
      [S390] convert bitmap definitions to C
      [S390] move EXPORT_SYMBOLs to definitions
      [S390] cio/crw: add/fix locking
      [S390] cio: ensure single load of irq handler pointer
      [S390] bitops: remove likely annotations
      [S390] use compiler builtin versions of strlen/strcpy/strcat
      [S390] smp: fix memory leak on __cpu_up
      [S390] smp: perform initial cpu reset before starting a cpu
      [S390] fix clock comparator save area usage
      sysrq: include interrupt.h instead of irq.h
      [S390] fix hypfs build failure
      ETHOC: fix build breakage on s390
      Btrfs: fix __ucmpdi2 compile bug on 32 bit builds

Helge Deller (10):
      parisc: fix usage of 32bit PTE page table entries on 32bit kernels
      parisc: use constants instead of numbers in assembly
      parisc: allow to build with 16k default kernel page size
      parisc: add LATENCYTOP_SUPPORT and CONFIG_STACKTRACE_SUPPORT
      parisc: simplify sys_clone()
      parisc: add ftrace (function and graph tracer) functionality
      parisc: blink all or loadavg LEDs on oops
      parisc: document light weight syscall ABI
      parisc: oops_enter()/oops_exit() in die()
      parisc: fix "make tar-pkg"

Helmut Schaa (11):
      ath5k: discard 11g caps if reported by an ar5211 eeprom
      iwl3945: report killswitch changes even if the interface is down
      iwl3945: fix some warnings when compiled without debug
      iwlagn: fix hw-rfkill while the interface is down
      iwlagn: clean up error path in iwl_pci_probe
      libipw: fix debug output
      ipw2x00: remove duplicated defines
      ipw2x00: Use IE definitions from linux/ieee80211.h
      ipw2x00: remove obsolete enums
      mac80211: handle failed scan requests in STA mode
      mac80211: start pending scan after probe/auth/assoc timed out

Hendrik Brueckner (3):
      [S390] hvc_iucv: Update and add missing kernel messages
      [S390] hvc_iucv: Provide IUCV z/VM user ID filtering
      [S390] remove duplicate nul-termination of string

Henk Stegeman (1):
      net/fec_mpc52xx: Migrate to net_device_ops.

Henrik Austad (2):
      sched: idle_at_tick is only used when CONFIG_SMP is set
      documentation: ignore byproducts from latex

Henrique de Moraes Holschuh (12):
      thinkpad-acpi: update copyright notices
      thinkpad-acpi: drop ibm-acpi alias
      thinkpad-acpi: documentation cleanup
      thinkpad-acpi: cleanup debug helpers
      thinkpad-acpi: add missing log levels
      thinkpad-acpi: add new debug helpers and warn of deprecated atts
      thinkpad-acpi: remove HKEY disable functionality
      thinkpad-acpi: restrict access to some firmware LEDs
      thinkpad-acpi: enhanced debugging messages for rfkill subdrivers
      thinkpad-acpi: enhanced debugging messages for the hotkey subdriver
      thinkpad-acpi: enhanced debugging messages for the fan subdriver
      thinkpad-acpi: rework brightness support

Herbert Valerio Riedel (1):
      hwmon: add support for GMT G760A fan speed PWM controller

Herbert Xu (35):
      e1000e: Invoke VLAN GRO handler
      ixgbe: Replace LRO with GRO
      sfc: Replace LRO with GRO
      igb: Replace LRO with GRO
      cxgb3: Replace LRO with GRO
      gro: Move common completion code into helpers
      gro: Avoid copying headers of unmerged packets
      gro: Do not merge paged packets into frag_list
      gro: Open-code memcpy in napi_fraginfo_skb
      gro: Fix handling of imprecisely split packets
      ipv4: Delete redundant sk_family assignment
      net: Partially allow skb destructors to be used on receive path
      net: Reexport sock_alloc_send_pskb
      tun: Limit amount of queued packets per device
      gro: Fix frag_list merging on imprecisely split packets
      gro: Remember number of held packets instead of counting every time
      gro: Optimise Ethernet header comparison
      gro: Optimise IPv4 packet reception
      gro: Optimise TCP packet reception
      tun: Fix merge error
      crypto: shash - Remove superfluous check in init_tfm
      crypto: shash - Add crypto_shash_blocksize
      crypto: sha-s390 - Switch to shash
      crypto: api - crypto_alg_mod_lookup either tested or untested
      crypto: api - Fix crypto_alloc_tfm/create_create_tfm return convent=
ion
      crypto: skcipher - Avoid infinite loop when cipher fails selftest
      crypto: aead - Avoid infinite loop when nivaead fails selftest
      crypto: testmgr - Test skciphers with no IVs
      tcp: Always set urgent pointer if it's beyond snd_nxt
      nlattr: Fix build error with NET off
      GRO: Move netpoll checks to correct location
      gro: Fix vlan/netpoll check again
      crypto: sha512-s390 - Add missing block size
      GRO: Disable GRO on legacy netif_rx path
      gso: Fix support for linear packets

Herton Ronaldo Krzesinski (16):
      ALSA: hda - Consider additional capture source/selector in ALC889
      ALSA: hda - make alc882_auto_init_input_src aware of selectors
      ALSA: hda - Additional pin nids for STAC92HD71Bx and STAC92HD75Bx c=
odecs
      ALSA: hda - Dynamic detection of dmics/dmuxes/smuxes in stac92hd71b=
xx
      ALSA: hda - Don't call stac92xx_parse_auto_config with wrong dig_in
      ALSA: hda - Bind new ecs mobo id (1019:2950) to model=3Decs202
      ALSA: hda - Don't touch non-existent port f on 4-port 92hd71bxx cod=
ecs
      ALSA: hda - Cleanup setting of pin_configs in patch_stac927x
      ALSA: hda - Fix speaker output on HP DV4 1155-SE
      ALSA: hda - Add 4 channel mode for 3stack-hp model (ALC888)
      ALSA: hda - Add headphone automute support for 3stack-hp model (ALC=
888)
      ALSA: hda - Map 3stack-hp model (ALC888) for HP Educ.ar
      mac80211: deauth before flushing STA information
      n411: add missing Makefile entry
      Staging: agnx: mac80211 hw config change flags
      Staging: rtl8187se: fix build warnings

Hidetoshi Seto (1):
      x86, mce: remove incorrect __cpuinit for intel_init_cmci()

Hiroshi DOYU (10):
      omap mailbox: cleanup omap2 register definition with macro
      omap mailbox: add initial omap3 support
      omap mailbox: print hardware revision at startup
      omap mailbox: fix empty struct device for omap_mbox
      omap mailbox: fix empty struct device for omap1
      omap mailbox: fix empty struct device for omap2
      omap mailbox: add save_/restore_ctx() for PM
      omap mailbox: move mailbox.h into mailbox.c
      omap mailbox: convert sequence bit checking to module paramter
      omap mailbox: remove unnecessary header file inclusion

Hiroshi Shimamoto (21):
      x86: uaccess: fix style problems
      x86: uaccess: rename __put_user_u64() to __put_user_asm_u64()
      x86: uaccess: introduce try and catch framework
      x86: signal: use {get|put}_user_try and catch
      x86: ia32_signal: use {get|put}_user_try and catch
      x86: intel_cacheinfo: fix compiler warning
      x86: uaccess: fix compilation error on CONFIG_M386
      x86: mm: introduce helper function in fault.c
      x86: uaccess: use errret as error value in __put_user_size()
      x86: syscalls.h: remove asmlinkage from declaration of sys_rt_sigre=
turn()
      x86: ia32_signal: remove unused debug code
      x86: ia32_signal: introduce GET_SEG() macro
      x86: ia32_signal: introduce {get|set}_user_seg()
      x86: signal: add __user annotation
      x86: signal: intrroduce get_sigframe() and replace get_sigstack()
      x86: signal: use 16 bytes boundary for rt_sigframe
      x86: signal: unify get_sigframe()
      x86: signal: introduce helper align_sigframe()
      x86, signals: fix xine & firefox bustage
      x86: signal: check signal stack overflow properly
      x86: signal: check sas_ss_size instead of sas_ss_flags()

Hisashi Hifumi (3):
      GFS2: Pagecache usage optimization on GFS2
      xfs: pagecache usage optimization
      ocfs2: Pagecache usage optimization on ocfs2

Hitoshi Mitake (1):
      edac: add more verbose debug info

Holger Eitzenberger (7):
      netfilter: ctnetlink: add callbacks to the per-proto nlattrs
      netlink: add nla_policy_len()
      netfilter: limit the length of the helper name
      netfilter: ctnetlink: allocate right-sized ctnetlink skb
      netfilter: nf_conntrack: add generic function to get len of generic=
 policy
      netfilter: nf_conntrack: calculate per-protocol nlattr size
      ctnetlink: compute generic part of event more acurately

Holger Schurig (7):
      arm/imx2x: new IOMUX definitions
      arm/imx21: add kbuild support for the Freescale i.MX21
      arm/imx2x: removes a bunch of sparse-warnings
      arm/imx2x: split i.MX21/i.MX27 register definitions
      arm/imx21: clock support for i.MX21
      arm/imx21: Framebuffer support for i.MX21
      arm/imx: Kconfig beautification

Hollis Blanchard (17):
      KVM: ppc: move struct kvmppc_44x_tlbe into 44x-specific header
      KVM: ppc: cosmetic changes to mmu hook names
      KVM: ppc: small cosmetic changes to Book E DTLB miss handler
      KVM: ppc: change kvmppc_mmu_map() parameters
      KVM: ppc: turn tlb_xlate() into a per-core hook (and give it a bett=
er name)
      KVM: ppc: rename 44x MMU functions used in booke.c
      KVM: ppc: remove last 44x-specific bits from booke.c
      KVM: ppc: use macros instead of hardcoded literals for instruction =
decoding
      KVM: ppc: split out common Book E instruction emulation
      KVM: ppc: Add dbsr in kvm_vcpu_arch
      KVM: ppc: No need to include core-header for KVM in asm-offsets.c c=
urrently
      KVM: ppc: ifdef iccci with CONFIG_44x
      KVM: ppc: E500 core-specific code
      KVM: ppc: Add kvmppc_mmu_dtlb/itlb_miss for booke
      KVM: ppc: distinguish between interrupts and priorities
      KVM: ppc: Add extra E500 exceptions
      KVM: ppc: remove debug support broken by KVM debug rewrite

Huang Weiyi (15):
      dnet: remove duplicated #include
      atl1c: remove duplicated #include
      MIPS: compat: Remove duplicated #include
      avr32: remove duplicated #include
      USB: gadget: remove duplicated #include
      [S390] remove duplicated #includes
      dnet: remove unused #include <version.h>
      glge: remove unused #include <version.h>
      Staging: remove duplicated #include's
      mfd: remove duplicated #include from pcf50633
      smsc911x: remove unused #include <linux/version.h>
      V4L/DVB: usbvision: remove unused #include <version.h>
      V4L/DVB: zr364xx: remove unused #include <version.h>
      powerpc: Remove duplicated #include's
      tracing, x86: remove duplicated #include

Huang Ying (12):
      x86: kexec: Use one page table in x86_64 machine_kexec
      x86, mce: fix a race condition in mce_read()
      crypto: aes - Move key_length in struct crypto_aes_ctx to be the la=
st field
      crypto: aes - Export x86 AES encrypt/decrypt functions
      crypto: cryptd - Add support to access underlying blkcipher
      crypto: aes-ni - Add support to Intel AES-NI instructions for x86_6=
4 platform
      crypto: api - Use dedicated workqueue for crypto subsystem
      crypto: cryptd - Per-CPU thread implementation based on kcrypto_wq
      crypto: chainiv - Use kcrypto_wq instead of keventd_wq
      x86, kexec: fix kexec x86 coding style
      x86, kexec: x86_64: add identity map for pages at image->start
      x86, kexec: x86_64: add kexec jump support for x86_64

Hugh Dickins (6):
      sysfs: fix some bin_vm_ops errors
      compat_do_execve should unshare_files
      fix setuid sometimes doesn't
      fix setuid sometimes wouldn't
      mm: page_mkwrite change prototype to match fault: fix sysfs
      shmem: writepage directly to swap

Hugo Villeneuve (4):
      ASoC: DaVinci: Fix SFFSDR compilation error.
      ASoC: Davinci: Fix incorrect machine type for SFFSDR board
      ALSA: ASoC: Davinci: Replaced DAI format RIGHT_J by DSP_B for SFFSD=
R
      ALSA: ASoC: Davinci: Updated sffsdr_hw_params() function to new for=
mat

Hunter Adrian (1):
      UBIFS: fix compiler warnings

ISHIKAWA Mutsumi (1):
      sony-laptop: detect the ICH9 chipset as Type3

Ian Abbott (13):
      UIO: Take offset into account when determining number of pages that=
 can be mapped
      Staging: comedi: add amplc_pc236 driver
      Staging: comedi: add adv_pci1723 driver
      Staging: comedi: add ampl_dio200 driver
      Staging: comedi: add amplc_pc263 driver
      Staging: comedi: add amplc_pci224 driver
      Staging: comedi: new devices for ni_pcimio.c
      Staging: comedi: Add a module parameter 'comedi_autoconfig'.
      Staging: comedi: Make comedi_auto_config() succeed when auto-config=
uration disabled.
      Staging: comedi: comedi_rt_task_context_t fix
      Staging: comedi: Use explicit value for enumerated constant INSN_CO=
NFIG_GET_HARDWARE_BUFFER_SIZE.
      Staging: comedi: newer gcc warning fixes
      Staging: comedi: comedi_open: Fix null pointer dereference.

Ian Campbell (7):
      swiotlb: range_needs_mapping should take a physical address.
      swiotlb: do not use sg_virt()
      x86: rename arch/x86/kernel/pci-swiotlb_64.c =3D> pci-swiotlb.c
      xen: explicitly initialise the cpu field of irq_info
      xen: expose enable_IO_APIC for 32-bit
      xen: fix xen_flush_tlb_others
      x86, xen: record and display initiator of each multicall when debug=
ging

Ian Kent (3):
      autofs4: cleanup expire code duplication
      autofs4: fix lookup deadlock
      autofs4: fix kernel includes

Ian Molton (8):
      ASoC: dapm: Allow explictly named mixer controls
      ASoC: cleanup duplicated code.
      ASoC: Driver for the WM9705 AC97 codec.
      ASoC: machine driver for Toshiba e750
      ASoC: machine driver for Toshiba e800
      ASoC: machine support for Toshiba e740 PDA
      ASoC: fixes to caching implementations
      ASoC: Fix WM9705 capture switch name

Igor M. Liplianin (18):
      V4L/DVB (10266): Add support for TurboSight TBS6920 DVB-S2 PCI-e ca=
rd.
      V4L/DVB (10267): Add support for TeVii S470 DVB-S2 PCI-e card.
      V4L/DVB (10268): Proper implement set_voltage in cx24116.
      V4L/DVB (10269): Add support for DVBWorld DVBS2 PCI-e 2005.
      V4L/DVB (10413): Bug fix: Restore HVR-4000 tuning.
      V4L/DVB (10743): dm1105: not demuxing from interrupt context.
      V4L/DVB (10744): dm1105: infrared remote code is remaked.
      V4L/DVB (10799): Add support for ST STV6110 silicon tuner.
      V4L/DVB (10800): Add support for ST LNBH24 LNB power controller.
      V4L/DVB (10801): Add headers for ST STV0900 dual demodulator.
      V4L/DVB (10802): Add more headers for ST STV0900 dual demodulator.
      V4L/DVB (10803): Add core code for ST STV0900 dual demodulator.
      V4L/DVB (10804): Add support for ST STV0900 dual demodulator.
      V4L/DVB (10805): Add support for NetUP Dual DVB-S2 CI card
      V4L/DVB (10808): Fix typo in lnbp21.c
      V4L/DVB (10871): stv0900: delete debug messages not related to stv0=
900 tuning algorythm
      V4L/DVB (11054): Shorten some lines in stv0900 to less then 81 char=
acters
      V4L/DVB (11055): Fix typo in stv0900

Ilgu Hong (3):
      [SCSI] scsi dh alua: fix group id masking
      [SCSI] scsi dh alua: add intel Multi-Flex device
      [SCSI] scsi dh alua: handle report luns data changed in check sense=
 callout

Ilpo J=C3=A4rvinen (29):
      ipmr: use goto to common label instead of opencoding
      ax25: more common return path joining
      ipv6/ndisc: join error paths
      ipv6/addrconf: common code located
      net/sunrpc/xprtsock.c: some common code found
      tcp: don't backtrack to sacked skbs
      tcp: fix lost_cnt_hint miscounts
      tcp: deferring in middle of queue makes very little sense
      tcp: Don't clear hints when tcp_fragmenting
      tcp: fix corner case issue in segmentation during rexmitting
      tcp: remove redundant code from tcp_mark_lost_retrans
      tcp: separate timeout marking loop to it's own function
      tcp: cleanup ca_state mess in tcp_timer
      tcp: drop unnecessary local var in collapse
      htcp: merge icsk_ca_state compare
      tcp: add helper for AI algorithm
      tcp: kill eff_sacks "cache", the sole user can calculate itself
      tcp: in sendmsg/pages open code the real goto target
      tcp: get rid of two unnecessary u16s in TCP skb flags copying
      tcp: remove pointless .dsack/.num_sacks code
      tcp: kill dead end_seq variable in clean_rtx_queue
      tcp: consolidate paws check
      tcp: don't check mtu probe completion in the loop
      tcp: simplify tcp_current_mss
      tcp: cache result of earlier divides when mss-aligning things
      tcp: make sure xmit goal size never becomes zero
      net/*: use linux/kernel.h swap()
      tcp: add helper for counter tweaking due mid-wq change
      tcp: miscounts due to tcp_fragment pcount reset

Ilya Yanok (3):
      powerpc: Rework dma-noncoherent to use generic vmalloc layer
      qong: basic support for Dave/DENX QongEVB-LITE board
      mxc: add arch_reset() function

Inaky Perez-Gonzalez (7):
      wimax/i2400m: convert to net_device_ops
      wimax/i2400m: add the ability to fallback to other firmware files i=
f the default is not there
      wimax/i2400m: drop support for deprecated major fw interface, add f=
or new minor
      wimax/i2400m: firmware_check() encodes the firmware version in i240=
0m->fw_version
      wimax/i2400m: allow control of the base-station idle mode timeout
      wimax/i2400m: support extended data RX protocol (no need to realloc=
ate skbs)
      wimax/i2400m: implement RX reorder support

Indika Katugampala (1):
      V4L/DVB (10528): em28xx: support added for IO-DATA GV/MVP SZ - EMPI=
A-2820 chipset

Ingo Molnar (553):
      x86: stackprotector & PARAVIRT fix
      x86: fix stackprotector canary updates during context switches
      x86: fix canary of the boot CPU's idle task
      panic: print more informative messages on stackprotect failure
      panic: print out stacktrace if DEBUG_BUGVERBOSE
      x86: if stackprotector is enabled, thn use stack-protector-all by d=
efault
      stackprotector: include files
      stackprotector: add boot_init_stack_canary()
      x86: fix the stackprotector canary of the boot CPU
      x86: stackprotector: mix TSC to the boot canary
      x86: unify stackprotector features
      Merge branch 'linus' into stackprotector
      stackprotector: remove self-test
      Merge branch 'linus' into stackprotector
      Merge branch 'linus' into timers/hrtimers
      Merge branches 'tracing/docs', 'tracing/function-graph-tracer' and =
'linus' into tracing/core
      tracing/ftrace: make trace_find_cmdline() generally available
      tracing/selftest: remove TRACE_CONT reference
      Merge branch 'topic/kmemtrace' of git://git.kernel.org/pub/scm/linu=
x/kernel/git/penberg/slab-2.6 into tracing/kmemtrace
      kmemtrace: move #include lines
      relayfs: replace BUG() with WARN_ON() in relay_late_setup_files()
      tracing, kvm: change MARKERS to select instead of depends on
      tracing/kmemtrace: export kmemtrace_mark_alloc_node() / kmemtrace_m=
ark_free()
      Merge branch 'linus' into tracing/kmemtrace
      Merge branch 'tracing/kmemtrace' into tracing/kmemtrace2
      Merge branch 'linus' into stackprotector
      tracing/kmemtrace: fix typo
      Merge branch 'linus' into tracing/kmemtrace2
      kmemtrace: add kmemtrace_init()
      Merge branches 'tracing/kmemtrace2' and 'tracing/ftrace' into traci=
ng/urgent
      Merge branch 'linus' into x86/setup-lzma
      bzip2/lzma: make flush_buffer() unconditional
      Merge branch 'linus' into x86/cleanups
      Merge branch 'linus' into core/iommu
      Merge commit 'v2.6.29-rc1' into tracing/urgent
      Merge commit 'v2.6.29-rc1' into irq/urgent
      Merge branch 'sched/latest' of git://git.kernel.org/pub/scm/linux/k=
ernel/git/ghaskins/linux-2.6-hacks into sched/rt
      Merge commit 'v2.6.29-rc1' into x86/cleanups
      Merge commit 'v2.6.29-rc1' into timers/hrtimers
      x86: change the default cache size to 64 bytes
      Merge branch 'master' of ssh://master.kernel.org/pub/scm/linux/kern=
el/git/travis/linux-2.6-cpus4096-for-ingo into cpus4096
      tracing: trace_stat.c cleanup
      x86: fix broken flush_tlb_others_ipi(), fix
      Merge branches 'cpus4096', 'x86/cleanups' and 'x86/urgent' into x86=
/percpu
      Merge branch 'linus' into cpus4096
      fix: crash: IP: __bitmap_intersects+0x48/0x73
      Merge branch 'master' of ssh://master.kernel.org/pub/scm/linux/kern=
el/git/travis/linux-2.6-cpus4096-for-ingo into cpus4096
      Merge branch 'linus' into core/iommu
      sched: fix !CONFIG_SCHEDSTATS build failure
      percpu: add optimized generic percpu accessors
      Merge branch 'linus' into irq/genirq
      irq: provide debug_poll_all_shared_irqs() method under CONFIG_DEBUG=
_SHIRQ
      Merge branch 'tj-percpu' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tj/misc into core/percpu
      Merge branch 'core/percpu' into stackprotector
      x86, rdc321x: remove/move leftover files
      Merge branch 'tracing/ftrace'; commit 'v2.6.29-rc2' into tracing/co=
re
      Merge branch 'stackprotector' into core/percpu
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/travis/linux-2.6-cpus4096-for-ingo into cpus4096
      x86: fully honor "nolapic", fix
      Merge branch 'tj-percpu' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tj/misc into core/percpu
      x86, cpumask: fix tlb flush race
      Merge commit 'v2.6.29-rc2' into x86/mm
      Merge branch 'tj-percpu' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tj/misc into core/percpu
      Merge branch 'cpus4096' into core/percpu
      x86, mm: move tlb.c to arch/x86/mm/
      x86: uv cleanup, build fix
      Merge branch 'x86/mm' into core/percpu
      x86: make x86_32 use tlb_64.c, build fix, clean up X86_L1_CACHE_BYT=
ES
      x86: uv cleanup, build fix #2
      Merge branch 'tracing/ftrace' into tracing/core
      Merge branch 'tj-percpu' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tj/misc into core/percpu
      x86, xen: fix hardirq.h merge fallout
      Merge branch 'tracing/ftrace' into tracing/core
      Merge branches 'tracing/ftrace' and 'tracing/function-graph-tracer'=
 into tracing/core
      x86, debug: remove early_printk() #ifdefs from head_32.S
      x86: improve early fault/irq printout
      Merge branch 'linus' into core/percpu
      Merge branch 'tj-percpu' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tj/misc into core/percpu
      Merge branches 'tracing/blktrace', 'tracing/kmemtrace' and 'tracing=
/urgent' into tracing/core
      Merge branch 'core/percpu' into x86/core
      Merge branches 'x86/asm', 'x86/cleanups', 'x86/cpudetect', 'x86/deb=
ug', 'x86/doc', 'x86/header-fixes', 'x86/mm', 'x86/paravirt', 'x86/pat', =
'x86/setup-v2', 'x86/subarch', 'x86/uaccess' and 'x86/urgent' into x86/co=
re
      x86, genapic: refactor genapic_64.h
      x86, genapic: refactor genapic_32.h
      x86, genapic: unify struct genapic
      x86, genapic: finish unification
      x86, genapic: cleanups
      x86, genapic: provide IPI callbacks unconditionally
      x86: rename 'genapic' to 'apic'
      x86: clean up genapic_flat
      x86: clean up genapic_phys_flat
      x86: clean up apic_x2apic_uv_x
      x86: clean up apic_x2apic_phys
      x86: clean up apic_x2apic_cluster
      x86, genapic: cleanup 32-bit apic_default template
      x86, genapic: cleanup 32-bit apic_bigsmp template
      x86, genapic: cleanup 32-bit apic_numaq template
      x86, genapic: cleanup 32-bit apic_es7000 template
      x86, genapic: cleanup 32-bit apic_summit template
      x86: remove APIC_INIT / APICFUNC / IPIFUNC
      x86: clean up apic->acpi_madt_oem_check methods
      x86: clean up apic->apic_id_registered() methods
      x86, genapic: rename int_delivery_mode, et. al.
      x86, apic: remove IRQ_DEST_MODE / IRQ_DELIVERY_MODE
      x86, apic: remove DEFAULT_IRQ_DELIVERY_MODE and DEFAULT_IRQ_DEST_MO=
DE
      x86, apic: remove SUMMIT_IRQ_DELIVERY_MODE and SUMMIT_IRQ_DEST_MODE
      x86, apic: remove NUMAQ_IRQ_DELIVERY_MODE and NUMAQ_IRQ_DEST_MODE
      x86, apic: remove BIGSMP_IRQ_DELIVERY_MODE and BIGSMP_IRQ_DEST_MODE
      x86, apic: remove ES7000_IRQ_DELIVERY_MODE and ES7000_IRQ_DEST_MODE
      x86, apic: remove IRQ_DEST_MODE
      x86, apic: clean up target_cpus methods
      x86, apic: clean up / remove TARGET_CPUS
      x86: clean up esr_disable() methods
      x86: rename ->ESR_DISABLE to ->disable_esr
      x86: clean up the APIC_DEST_LOGICAL logic
      x86, apic: rename genapic::apic_destination_logical to genapic::des=
t_logical
      x86, apic: clean up check_apicid*() callbacks
      x86, apic: remove no_balance_irq and no_ioapic_check flags
      x86, apic: clean up ->vector_allocation_domain()
      x86, apic: clean up ->init_apic_ldr()
      x86, apic: clean up ->ioapic_phys_id_map()
      x86, apic: clean up ->setup_apic_routing()
      x86, apic: streamline the ->multi_timer_check() quirk
      x86, apic: clean up ->apicid_to_node()
      x86, apic: clean up ->cpu_to_logical_apicid()
      x86, apic: clean up ->cpu_present_to_apicid()
      x86, apic: clean up ->apicid_to_cpu_present()
      x86: refactor ->setup_portio_remap() subarch methods
      x86: refactor ->check_phys_apicid_present() subarch methods
      x86: refactor ->enable_apic_mode() subarch methods
      x86, es7000: clean up es7000_enable_apic_mode()
      x86, apic: unify phys_pkg_id()
      x86, apic: refactor ->phys_pkg_id()
      x86, smp: clean up mps_oem_check()
      x86, mpparse: call the generic quirk handlers early
      x86: consolidate the ->mps_oem_check() code
      x86, apic: refactor ->get_apic_id() & GET_APIC_ID()
      x86, apic: refactor ->apic_id_mask & APIC_ID_MASK
      x86, apic: get rid of *_APIC_ID_MASK definitions
      x86, apic: refactor ->cpu_mask_to_apicid*()
      x86, apic: untangle the send_IPI_*() jungle
      x86, smp: clean up ->trampoline_phys_low/high handling
      x86: set ->trampoline_phys_low/high on 64-bit too
      x86, smp: refactor ->wait_for_init_deassert()
      x86, smp: refactor ->smp_callin_clear_local_apic() methods
      x86, smp: refactor ->store/restore_NMI_vector() methods
      x86, smp: remove ->restore_NMI_vector()
      x86, smp: refactor ->inquire_remote_apic() methods
      x86, ES7000: consolidate the APIC code
      x86, smp: eliminate asm/mach-default/mach_wakecpu.h
      x86: eliminate asm/mach-*/mach_mpparse.h
      x86: remove mach_mpspec.h
      x86: remove mach_apicdef.h
      x86, smp: refactor ->wake_cpu
      x86, numaq: consolidate code
      x86, summit: consolidate code
      x86, summit: consolidate code, fix
      x86: remove mach_apic.h
      x86, ES7000: Consolidate code
      x86, NUMAQ: Consolidate code
      x86, bigsmp: consolidate code
      x86, bigsmp: consolidate header code
      x86, smp: remove mach_ipi.h
      x86: remove subarchitecture support code
      x86: move mach-default/*.h files to asm/
      x86: remove subarchitecture support
      x86/Voyager: clean up BROKEN Kconfig reference
      x86: disable Voyager temporarily
      x86/Voyager: remove MCA Kconfig quirk
      x86/Voyager: remove NATSEMI Kconfig quirk
      x86/Voyager: remove KVM Kconfig quirk
      x86/Voyager: remove KGDB Kconfig quirk
      x86/Voyager: remove HIBERNATION Kconfig quirk
      x86/Voyager: remove ARCH_SUSPEND_POSSIBLE Kconfig quirk
      x86: replace CONFIG_X86_SMP with CONFIG_SMP
      x86: generalize boot_cpu_id
      x86/Voyager: remove X86_HT Kconfig quirk
      x86/Voyager: remove X86_BIOS_REBOOT Kconfig quirk
      x86/Voyager: remove X86_FIND_SMP_CONFIG Kconfig quirk
      x86/VisWS: remove Kconfig quirk
      x86/Voyager: remove VMI Kconfig quirk
      x86/Voyager: remove KVM_CLOCK quirk
      x86/Voyager: remove KVM_GUEST quirk
      x86/Voyager: remove PARAVIRT Kconfig quirk
      x86/Voyager: remove APIC/IO-APIC Kbuild quirk
      x86/Voyager: remove MCE quirk
      x86/Voyager: remove HOTPLUG_CPU Kconfig quirk
      x86/Voyager: remove power management Kconfig quirk
      x86/Voyager: remove ISA quirk
      x86: cleanup, introduce CONFIG_NON_STANDARD_PLATFORMS
      x86: move ELAN to the NON_STANDARD_PLATFORM section
      x86: move VOYAGER to the NON_STANDARD_PLATFORM section
      x86: move non-standard 32-bit platform Kconfig entries
      x86: move X86_VSMP from subarch menu
      x86: remove the subarch menu
      x86: rename X86_GENERICARCH to X86_32_NON_STANDARD
      x86/Voyager: move to the X86_32_NON_STANDARD code section
      Merge branch 'tracing/ftrace' into tracing/core
      Revert "generic, x86: fix __per_cpu_load relocation"
      Merge branch 'linus' into core/percpu
      x86, apic, 32-bit: add self-IPI methods
      x86, irq: add LOCAL_PERF_VECTOR
      x86, apic: clean up header section
      x86: update copyrights
      x86, apic: unify the APIC vector enumeration
      x86, apic: clean up spurious vector sanity check
      x86, voyager: move Voyager-specific defines to voyager.h
      x86, irqs, voyager: remove Voyager quirk
      x86, irq: add IRQ layout comments
      x86, irq_vectors.h: remove needless includes
      x86, irq: describe NR_IRQ sizing details, clean up
      x86, vm86: clean up invalid_vm86_irq()
      Merge branch 'tj-percpu' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tj/misc into core/percpu
      Merge branches 'tracing/ftrace', 'tracing/kmemtrace' and 'linus' in=
to tracing/core
      Merge branch 'core/header-fixes' of git://git.kernel.org/pub/scm/li=
nux/kernel/git/jaswinder/linux-2.6-tipclean into core/header-fixes
      Merge branch 'core/header-fixes' of git://git.kernel.org/pub/scm/li=
nux/kernel/git/jaswinder/linux-2.6-tip into core/header-fixes
      x86: document 64-bit and 32-bit function call convention ABI
      Merge branches 'tracing/blktrace', 'tracing/ftrace', 'tracing/urgen=
t' and 'linus' into tracing/core
      printk: introduce printk_once()
      Merge branches 'tracing/ftrace' and 'linus' into tracing/core
      Merge branch 'tj-percpu' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tj/misc into core/percpu
      smp, generic: introduce arch_disable_smp_support() instead of disab=
le_ioapic_setup()
      x86, apic: explain the purpose of max_physical_apicid
      smp, generic: introduce arch_disable_smp_support(), build fix
      Merge branch 'x86/urgent' into x86/apic
      x86, numaq: cleanups
      x86: clean up arch/x86/Kconfig*
      ring_buffer: remove unused flags parameter, fix
      Merge branch 'linus' into x86/mm
      Merge branch 'core/header-fixes' of git://git.kernel.org/pub/scm/li=
nux/kernel/git/jaswinder/linux-2.6-tip into core/header-fixes
      Merge branch 'linus' into core/locking
      Merge branches 'sched/rt' and 'sched/urgent' into sched/core
      Merge branches 'timers/clockevents', 'timers/hpet', 'timers/hrtimer=
s' and 'timers/urgent' into timers/core
      Merge commit 'v2.6.29-rc4' into tracing/core
      Merge branch 'tip/tracing/core/devel' of git://git.kernel.org/pub/s=
cm/linux/kernel/git/rostedt/linux-2.6-trace into tracing/ftrace
      Merge branch 'jsgf/x86/unify' of git://git.kernel.org/pub/scm/linux=
/kernel/git/jeremy/xen into x86/headers
      x86: early_printk.c - fix pgtable.h unification fallout
      x86, pgtable.h: macro-ify *_page() methods
      x86, pgtable.h: fix 2-level 32-bit build
      tracing/blktrace: move the tracing file to kernel/trace, fix
      Merge branch 'x86/paravirt' into x86/apic
      Merge commit 'v2.6.29-rc4' into core/percpu
      Merge branch 'x86/uaccess' into core/percpu
      Merge branch 'x86/urgent' into core/percpu
      Merge branches 'tracing/ftrace' and 'tracing/urgent' into tracing/c=
ore
      Merge branch 'tip/tracing/ftrace' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/rostedt/linux-2.6-trace into tracing/ftrace
      Merge branches 'tracing/ftrace' and 'tracing/urgent' into tracing/c=
ore
      Merge branch 'tip/tracing/ftrace' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/rostedt/linux-2.6-trace into tracing/ftrace
      Merge commit 'v2.6.29-rc4' into sched/core
      Merge branch 'x86/apic' of git://git.kernel.org/pub/scm/linux/kerne=
l/git/jeremy/xen into x86/apic
      x86, apic: make generic_apic_probe() generally available
      Merge commit 'v2.6.29-rc4' into x86/cleanups
      stackprotector: fix multi-word cross-builds
      x86: make hibernation always-possible
      x86, defconfig: update the 32-bit defconfig
      x86, defconfig: update the 64-bit defconfig
      x86, defconfig: turn off CONFIG_ENABLE_WARN_DEPRECATED
      x86, defconfig: turn off CONFIG_SCSI_ISCSI_ATTRS=3Dy
      Merge branch 'linus' into core/softlockup
      x86: fix warning in find_low_pfn_range()
      x86, 32-bit: clean up find_low_pfn_range()
      x86, 32-bit: refactor find_low_pfn_range()
      softlockup: move 'one' to the softlockup section in sysctl.c
      Merge branch 'linus' into x86/apic
      Merge branch 'core/percpu' into x86/core
      Merge branch 'x86/cleanups' into x86/core
      Merge branches 'x86/acpi', 'x86/asm', 'x86/cpudetect', 'x86/crashdu=
mp', 'x86/debug', 'x86/defconfig', 'x86/doc', 'x86/header-fixes', 'x86/he=
aders' and 'x86/minor-fixes' into x86/core
      Merge branch 'x86/mm' into x86/core
      Merge branches 'x86/paravirt', 'x86/pat', 'x86/setup-v2', 'x86/suba=
rch', 'x86/uaccess' and 'x86/urgent' into x86/core
      Merge branches 'tracing/ftrace', 'tracing/ring-buffer', 'tracing/sy=
sprof', 'tracing/urgent' and 'linus' into tracing/core
      Merge branch 'tip/tracing/ftrace' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/rostedt/linux-2.6-trace into tracing/ftrace
      Merge branch 'tip/tracing/core' of git://git.kernel.org/pub/scm/lin=
ux/kernel/git/rostedt/linux-2.6-trace into tracing/ftrace
      Merge branches 'irq/genirq', 'irq/sparseirq' and 'irq/urgent' into =
irq/core
      Merge branch 'x86/core' into x86/headers
      Merge branch 'x86/untangle2' of git://git.kernel.org/pub/scm/linux/=
kernel/git/jeremy/xen into x86/headers
      x86 headers: remove duplicate pud_large() definition
      x86 headers: include linux/types.h
      x86 headers: include page_types.h in pgtable_types.h
      x86 headers: protect page_32.h via __ASSEMBLY__
      Merge branch 'core/header-fixes' into x86/headers
      Merge commit 'v2.6.29-rc5' into x86/apic
      irq: clean up manage.c
      irq: refactor and clean up the free_irq() code flow
      Merge branches 'tracing/ftrace' and 'tracing/urgent' into tracing/c=
ore
      Merge branch 'tip/tracing/ftrace' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/rostedt/linux-2.6-trace into tracing/power-tracer
      Merge branch 'sched/urgent'; commit 'v2.6.29-rc5' into sched/core
      lockdep: annotate reclaim context (__GFP_NOFS), fix
      Merge branches 'tracing/hw-branch-tracing' and 'tracing/power-trace=
r' into tracing/core
      Merge branch 'tip/tracing/ftrace' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/rostedt/linux-2.6-trace into tracing/ftrace
      ftrace: fix !CONFIG_FTRACE [un_]register_ftrace_command() prototype=
s
      ftrace: fix !CONFIG_DYNAMIC_FTRACE ftrace_swapper_pid definition
      Merge branches 'x86/acpi', 'x86/apic', 'x86/cpudetect', 'x86/header=
s', 'x86/paravirt', 'x86/urgent' and 'x86/xen'; commit 'v2.6.29-rc5' into=
 x86/core
      x86: remove stale arch/x86/include/asm/page_64.h.rej file
      Merge branch 'x86/headers' into x86/core
      x86, apic: fix build fallout of genapic changes
      remove: genapic prepare
      x86, apic: merge genapic.h into apic.h
      x86, apic: remove genapic.h
      x86, apic: remove duplicate asm/apic.h inclusions
      x86, apic: remove stale references to APIC_DEFINITION
      x86, apic: clean up arch/x86/kernel/bigsmp_32.c
      x86, apic: clean up the cpu_2_logical_apiciddeclaration
      x86, es7000: clean up
      x86, apic: remove apicid_cluster()
      x86, es7000: remove externs
      x86, es7000: remove dead code, clean up
      x86, es7000: misc cleanups
      x86, numaq_32: clean up
      x86, numaq_32: clean up, misc
      x86, apic: remove ->store_NMI_vector()
      x86, apic: rename 'genapic' to 'apic'
      x86, apic: move APIC drivers to arch/x86/kernel/apic/*
      irq: further clean up the free_irq() code flow
      x86, apic: move remaining APIC drivers to arch/x86/kernel/apic/*
      irq: name 'p' variables a bit better
      x86, apic: separate 32-bit setup functionality out of apic_32.c
      Merge branches 'tracing/ftrace' and 'tracing/urgent' into tracing/c=
ore
      Merge branch 'tip/tracing/ftrace' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/rostedt/linux-2.6-trace into tracing/ftrace
      timers: add mod_timer_pending()
      Merge branch 'linus' into tracing/blktrace
      Merge branches 'tracing/blktrace', 'tracing/ftrace' and 'tracing/ur=
gent' into tracing/core
      Merge branch 'mainline/function-graph' of git://git.kernel.org/pub/=
scm/linux/kernel/git/rostedt/linux-2.6-trace into tracing/function-graph-=
tracer
      Documentation/ftrace.txt: update
      tracing/function-graph-tracer: fix merge
      Merge branch 'x86/untangle2' of git://git.kernel.org/pub/scm/linux/=
kernel/git/jeremy/xen into x86/headers
      Merge branches 'tracing/function-graph-tracer' and 'linus' into tra=
cing/core
      Merge branch 'for-ingo' of git://git.kernel.org/pub/scm/linux/kerne=
l/git/penberg/slab-2.6 into tracing/kmemtrace
      Merge branch 'x86/urgent' into x86/core
      Merge branches 'x86/asm', 'x86/cleanups' and 'x86/headers' into x86=
/core
      x86, pat: add large-PAT check to split_large_page()
      Merge branch 'tip/x86/urgent' of git://git.kernel.org/pub/scm/linux=
/kernel/git/rostedt/linux-2.6-trace into x86/mm
      x86, mm: fault.c cleanup
      x86, mm: fault.c, refactor/simplify the is_prefetch() code
      x86, mm: fault.c, factor out the vm86 fault check
      x86, mm: fault.c, enable PF_RSVD checks on 32-bit too
      x86, mm: fault.c, simplify kmmio_fault()
      x86, mm, kprobes: fault.c, simplify notify_page_fault()
      x86, mm: fault.c, reorder functions
      x86, mm: fault.c, unify oops printing
      x86, mm: fault.c, unify oops handling
      x86, mm: fault.c, remove #ifdef from do_page_fault()
      x86, mm: rename TASK_SIZE64 =3D> TASK_SIZE_MAX
      x86, mm: fault.c, remove #ifdef from fault_in_kernel_space()
      x86, mm: fault.c, give another attempt at prefetch handing before S=
IGBUS
      x86, mm: fault.c, update copyrights
      x86, mm: fault.c, simplify kmmio_fault(), cleanup
      Merge branch 'linus' into timers/hpet
      Merge branches 'tracing/function-graph-tracer', 'tracing/kmemtrace'=
 and 'tracing/markers' into tracing/core
      Merge branch 'tip/x86/ftrace' of git://git.kernel.org/pub/scm/linux=
/kernel/git/rostedt/linux-2.6-trace into tracing/ftrace
      Merge branch 'linus' into x86/apic
      x86: remove the Voyager 32-bit subarch
      x86: remove various unused subarch hooks
      x86: refactor x86_quirks support
      Merge branch 'tracing/ftrace'; commit 'v2.6.29-rc6' into tracing/co=
re
      Merge branches 'x86/acpi', 'x86/apic', 'x86/asm', 'x86/cleanups', '=
x86/mm', 'x86/signal' and 'x86/urgent'; commit 'v2.6.29-rc6' into x86/cor=
e
      Merge branch 'x86/core' into core/percpu
      Merge branch 'tj-percpu' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tj/misc into core/percpu
      Merge branch 'x86/asm' into x86/mm
      tracing/hw-branch-tracing: convert bts-tracer mutex to a spinlock
      x86, mm: pass in 'total' to __copy_from_user_*nocache()
      x86: usercopy: check for total size when deciding non-temporal cuto=
ff
      tracing: remove /debug/tracing/latency_trace
      Merge branch 'tip/tracing/ftrace' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/rostedt/linux-2.6-trace into tracing/ftrace
      alloc_percpu: add align argument to __alloc_percpu, fix
      alloc_percpu: fix UP build
      Merge branch 'x86/urgent' into x86/pat
      generic-ipi: cleanups
      time: ntp: clean up kernel/time/ntp.c
      time: ntp: simplify the second_overflow() code flow
      time: ntp: simplify the MAX_TICKADJ_SCALED definition
      time: ntp: clean up ntp_update_frequency()
      time: ntp: refactor up ntp_update_frequency()
      time: ntp: refactor and clean up ntp_update_offset()
      time: ntp: simplify ntp_update_offset_fll()
      time: ntp: micro-optimize ntp_update_offset()
      time: ntp: fix bug in ntp_update_offset() & do_adjtimex()
      time: ntp: refactor do_adjtimex()
      time: ntp: refactor do_adjtimex() some more
      time: ntp: make 64-bit constants more robust
      time: ntp: simplify ntp_tick_adj calculations
      time: ntp: clean up second_overflow()
      gpu/drm, x86, PAT: PAT support for io_mapping_*, export symbols for=
 modules
      Merge branches 'tracing/ftrace', 'tracing/hw-branch-tracing' and 'l=
inus' into tracing/core
      Merge branch 'tip/tracing/ftrace' of ssh://master.kernel.org/pub/sc=
m/linux/kernel/git/rostedt/linux-2.6-trace into tracing/ftrace
      Merge branch 'tj-percpu' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tj/misc into core/percpu
      Merge branch 'x86/urgent' into x86/core
      Merge branches 'x86/urgent' and 'x86/pat' into x86/core
      Merge branches 'x86/apic', 'x86/defconfig', 'x86/memtest', 'x86/mm'=
 and 'linus' into x86/core
      x86: remove update_apic from x86_quirks, fix
      Merge branches 'sched/cleanups', 'sched/urgent' and 'linus' into sc=
hed/core
      x86: apic: simplify secondary CPU wakeup methods
      x86: apic: simplify secondary CPU wakeup methods, fix
      x86: fix !ACPI build for es7000_32.c
      sched: sched_clock() improvement: use in_nmi()
      tracing: implement trace_clock_*() APIs
      sched: allow architectures to specify sched_clock_stable
      x86: set X86_FEATURE_TSC_RELIABLE
      Merge branch 'sched/clock' into tracing/ftrace
      fix warning in arch/x86/kernel/cpu/intel_cacheinfo.c
      Merge branch 'sched/clock' into tracing/ftrace
      Merge branches 'tracing/ftrace' and 'linus' into tracing/core
      Merge branch 'tip/tracing/ftrace' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/rostedt/linux-2.6-trace into tracing/ftrace
      Merge branch 'tracing/ftrace' into tracing/core
      Merge branch 'tip/tracing/ftrace' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/rostedt/linux-2.6-trace into tracing/ftrace
      Merge branch 'tip/tracing/ftrace' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/rostedt/linux-2.6-trace into tracing/ftrace
      Revert "gpu/drm, x86, PAT: PAT support for io_mapping_*"
      Merge branch 'x86/urgent' into x86/pat
      Merge branch 'x86/pat' into x86/core
      x86, mm: dont use non-temporal stores in pagecache accesses
      Merge branches 'sched/clock', 'sched/urgent' and 'linus' into sched=
/core
      Merge branch 'linus' into irq/genirq
      Merge branches 'tracing/ftrace', 'tracing/mmiotrace' and 'linus' in=
to tracing/core
      Merge branch 'tip/tracing/ftrace' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/rostedt/linux-2.6-trace into tracing/ftrace
      Merge branch 'tip/tracing/ftrace' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/rostedt/linux-2.6-trace into tracing/ftrace
      x86: set_highmem_pages_init() cleanup, fix !CONFIG_NUMA && CONFIG_H=
IGHMEM=3Dy
      Merge branch 'tip/tracing/ftrace' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/rostedt/linux-2.6-trace into tracing/ftrace
      Merge branches 'x86/apic', 'x86/cpu', 'x86/fixmap', 'x86/mm', 'x86/=
sched', 'x86/setup-lzma', 'x86/signal' and 'x86/urgent' into x86/core
      Merge branch 'x86/core' into core/percpu
      Merge branch 'tracing/ftrace'; commit 'v2.6.29-rc7' into tracing/co=
re
      Merge branch 'rfc/splice/tip/tracing/ftrace' of git://git.kernel.or=
g/pub/scm/linux/kernel/git/rostedt/linux-2.6-trace into tracing/ftrace
      x86, mce: fix build failure in arch/x86/kernel/cpu/mcheck/threshold=
.c
      Merge branch 'core/locking' into tracing/ftrace
      Merge branch 'x86/urgent' into x86/mm
      Merge branch 'tracing/ftrace' into tracing/core
      Merge branch 'tip/tracing/ftrace' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/rostedt/linux-2.6-trace into tracing/ftrace
      tracing: rename ftrace_printk() =3D> trace_printk()
      tracing: move utility functions from ftrace.h to kernel.h
      Merge commit 'v2.6.29-rc7' into core/locking
      Merge commit 'v2.6.29-rc7' into sched/core
      Merge branch 'linus' into core/iommu
      Merge branch 'iommu/fixes-2.6.29' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/joro/linux-2.6-iommu into core/iommu
      x86: move init_memory_mapping() to common mm/init.c, build fix on 3=
2-bit PAE
      x86: UV, SGI RTC: add generic system vector, build fix on UP
      Merge branch 'x86/urgent' into x86/core
      Merge branch 'x86/mce2' into x86/core
      Merge branch 'x86/mm' into x86/core
      Merge branch 'x86/doc' into x86/core
      Merge branch 'x86/uv' into x86/core
      tracing: clean up menu
      Merge branches 'tracing/ftrace' and 'tracing/function-graph-tracer'=
 into tracing/core
      Merge branch 'tip/tracing/ftrace' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/rostedt/linux-2.6-trace into tracing/ftrace
      Merge branch 'sched/core' into sched/cleanups
      tracing, power-trace: make it build even if the power-tracer is tur=
ned off
      Merge branch 'x86/core' into tracing/textedit
      Merge branch 'core/printk' into tracing/ftrace
      tracing: trace_bprintk() cleanups
      Merge branches 'tracing/doc', 'tracing/ftrace', 'tracing/printk' an=
d 'tracing/textedit' into tracing/core
      tracing: trace_printk() fix, move format array to data section
      tracing: optimize trace_printk()
      Merge branches 'x86/apic', 'x86/asm', 'x86/fixmap', 'x86/memtest', =
'x86/mm', 'x86/urgent', 'linus' and 'core/percpu' into x86/core
      Merge branches 'tracing/doc', 'tracing/ftrace', 'tracing/printk' an=
d 'linus' into tracing/core
      Merge branch 'tip/tracing/ftrace' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/rostedt/linux-2.6-trace into tracing/ftrace
      Merge branch 'x86/core' into tracing/ftrace
      Merge branches 'sched/cleanups' and 'linus' into sched/core
      Merge branch 'core/printk' into tracing/ftrace
      x86, sched_clock(): mark variables read-mostly
      Merge branches 'tracing/ftrace', 'tracing/textedit' and 'linus' int=
o tracing/core
      Merge branch 'tip/tracing/ftrace' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/rostedt/linux-2.6-trace into tracing/ftrace
      Merge branch 'linus' into core/percpu
      Merge branch 'tj-percpu' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tj/misc into core/percpu
      Merge branches 'x86/cleanups', 'x86/kexec', 'x86/mce2' and 'linus' =
into x86/core
      Merge branch 'x86/core' into cpus4096
      Merge branch 'tip/tracing/ftrace' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/rostedt/linux-2.6-trace into tracing/ftrace
      Merge branches 'x86/asm', 'x86/debug', 'x86/mm', 'x86/setup', 'x86/=
urgent' and 'linus' into x86/core
      x86: memcpy, clean up
      Merge branch 'linus' into irq/genirq
      Merge branch 'linus' into core/locking
      locking: rename trace_softirq_[enter|exit] =3D> lockdep_softirq_[en=
ter|exit]
      Merge branch 'core/locking' into tracing/ftrace
      Merge branch 'linus' into core/ipi
      x86: unify kmap_atomic_pfn() and iomap_atomic_prot_pfn(), fix
      Merge branches 'tracing/ftrace' and 'linus' into tracing/core
      Merge branch 'tip/tracing/ftrace' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/rostedt/linux-2.6-trace into tracing/ftrace
      Merge branches 'sched/clock', 'sched/urgent' and 'linus' into sched=
/core
      Merge commit 'v2.6.29-rc8' into cpus4096
      Merge branch 'cpus4096' of git://git.kernel.org/pub/scm/linux/kerne=
l/git/rusty/linux-2.6-x86 into cpus4096
      Merge commit 'v2.6.29-rc8' into tracing/ftrace
      Merge branch 'tip/tracing/ftrace' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/rostedt/linux-2.6-trace into tracing/ftrace
      Merge branches 'tracing/ftrace' and 'tracing/syscalls'; commit 'v2.=
6.29-rc8' into tracing/core
      futex: remove the pointer math from double_unlock_hb, fix
      generic-ipi: eliminate WARN_ON()s during oops/panic
      Merge branch 'x86/core' into core/ipi
      panic: decrease oops_in_progress only after having done the panic
      panic, smp: provide smp_send_stop() wrapper on UP too
      panic: clean up kernel/panic.c
      tracing/syscalls: support for syscalls tracing on x86, fix
      Merge branch 'x86/core' into x86/kconfig
      Merge branch 'x86/asm' into tracing/syscalls
      Merge branch 'core/percpu' into x86/core
      x86: cpu/common.c more cleanups
      Merge branches 'x86/apic', 'x86/asm', 'x86/cleanups', 'x86/debug', =
'x86/kconfig', 'x86/mm', 'x86/ptrace', 'x86/setup' and 'x86/urgent'; comm=
it 'v2.6.29-rc8' into x86/core
      Merge branches 'tracing/ftrace', 'tracing/syscalls' and 'linus' int=
o tracing/core
      Merge branches 'irq/genirq' and 'linus' into irq/core
      Merge branch 'tracing/syscalls' into tracing/core
      Merge branch 'tip/tracing/ftrace' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/rostedt/linux-2.6-trace into tracing/ftrace
      Merge branch 'linus' into core/printk
      Merge branches 'tracing/ftrace' and 'linus' into tracing/core
      Merge branch 'tip/tracing/ftrace' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/rostedt/linux-2.6-trace into tracing/ftrace
      Merge branches 'sched/cleanups' and 'linus' into sched/core
      Merge branch 'linus' into core/iommu
      Merge branch 'dma-api/debug' of git://git.kernel.org/pub/scm/linux/=
kernel/git/joro/linux-2.6-iommu into core/iommu
      dma-debug: fix dma_debug_add_bus() definition for !CONFIG_DMA_API_D=
EBUG
      Merge branches 'x86/cleanups', 'x86/cpu', 'x86/debug', 'x86/mce2', =
'x86/mm', 'x86/mtrr', 'x86/setup', 'x86/setup-memory', 'x86/urgent', 'x86=
/uv', 'x86/x2apic' and 'linus' into x86/core
      x86: microcode: cleanup
      tracepoints: dont update zero-sized tracepoint sections
      x86: mpparse: clean up code by introducing a few helper functions, =
fix
      symbols, stacktrace: look up init symbols after module symbols
      Merge branches 'tracing/ftrace', 'tracing/kprobes', 'tracing/tasks'=
 and 'linus' into tracing/core
      Merge branch 'tip/tracing/ftrace' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/rostedt/linux-2.6-trace into tracing/ftrace
      Merge branches 'x86/cleanups', 'x86/mm', 'x86/setup' and 'linus' in=
to x86/core
      tracing, Text Edit Lock - kprobes architecture independent support,=
 nommu fix
      Merge branch 'x86/core' of git://git.kernel.org/pub/scm/linux/kerne=
l/git/jaswinder/linux-2.6-tip into x86/cleanups
      Merge branches 'tracing/ftrace', 'tracing/hw-breakpoints', 'tracing=
/ring-buffer', 'tracing/textedit' and 'linus' into tracing/core
      tracing: add run-time field descriptions for event filtering, kfree=
 fix
      Merge branches 'irq/sparseirq' and 'linus' into irq/core
      Merge branches 'sched/debug' and 'linus' into sched/core
      block: cleanup bio_alloc_bioset()
      Merge branches 'x86/apic', 'x86/cleanups', 'x86/mm', 'x86/pat', 'x8=
6/setup' and 'x86/signal'; commit 'v2.6.29' into x86/core
      Merge branch 'x86/core' of git://git.kernel.org/pub/scm/linux/kerne=
l/git/jaswinder/linux-2.6-tiptop into x86/cleanups
      Merge branch 'sched/cleanups'; commit 'v2.6.29' into sched/core
      Merge branch 'sched/balancing' into sched/core
      Merge commit 'v2.6.29' into timers/core
      Merge branch 'timers/hpet' into timers/core
      Merge branches 'timers/new-apis', 'timers/ntp' and 'timers/urgent' =
into timers/core
      Merge commit 'v2.6.29' into core/header-fixes
      Merge commit 'v2.6.29' into x86/setup-lzma
      Merge branch 'core/percpu' into percpu-cpumask-x86-for-linus-2
      Merge branch 'linus' into percpu-cpumask-x86-for-linus-2
      Merge branches 'x86/apic', 'x86/cleanups' and 'x86/mm' into x86/cor=
e
      Merge branch 'linus' into x86/core
      Merge branch 'linus' into core/iommu
      Merge branch 'linus' into core/futexes
      Merge branch 'linus' into core/printk
      Revert "cpuacct: reduce one NULL check in fast-path"
      lockdep: annotate reclaim context (__GFP_NOFS), fix SLOB
      Merge branch 'linus' into cpumask-for-linus
      tracing, Text Edit Lock: cleanup
      Merge branch 'linus' into locking-for-linus
      Merge branches 'tracing/docs', 'tracing/filters', 'tracing/ftrace',=
 'tracing/kprobes', 'tracing/blktrace-v2' and 'tracing/textedit' into tra=
cing/core-v2
      Merge branch 'tracing/core-v2' into tracing-for-linus
      Merge branch 'linus' into x86/urgent
      kmemtrace, fs: uninline simple_transaction_set()
      kmemtrace, fs: fix linux/fdtable.h header file dependencies
      kmemtrace, rcu: fix linux/rcutree.h and linux/rcuclassic.h dependen=
cies
      kmemtrace, rcu: fix rcu_tree_trace.c data structure dependencies
      kmemtrace, rcu: fix rcupreempt.c data structure dependencies
      kmemtrace: small cleanups
      Merge branch 'dma-debug' of git://git.kernel.org/pub/scm/linux/kern=
el/git/joro/linux-2.6-iommu into x86/urgent
      x86, mtrr: remove debug message
      Merge branch 'linus' into irq/threaded
      softlockup: make DETECT_HUNG_TASK default depend on DETECT_SOFTLOCK=
UP
      Merge branch 'linus' into core/softlockup
      Merge branch 'tracing/blktrace-fixes' into tracing/urgent
      ramfs: fix double freeing s_fs_info on failed mount

Ira Snyder (1):
      hwmon: Add LTC4215 driver

Isaku Yamahata (22):
      ia64/pv_ops/xen: use __initconst instead of __initdata for const da=
ta
      ia64/xen: short-circuit tests for dom0
      ia64/pv_ops: add hooks to paravirtualize fsyscall implementation.
      ia64/pv_ops/xen: preliminary to paravirtualizing fsys.S for xen.
      ia64/pv_ops: paravirtualize fsys.S.
      ia64/pv_ops/pvchecker: support mov =3D ar.itc paravirtualization
      ia64/pv_ops: paravirtualize mov =3D ar.itc.
      ia64/pv_ops/xen: paravirtualize read/write ar.itc and ar.itm
      ia64/pv_ops/pv_time_ops: add sched_clock hook.
      ia64/pv_ops/xen/pv_time_ops: implement sched_clock.
      ia64/pv_ops: gate page paravirtualization.
      ia64/pv_ops/xen: define xen specific gate page.
      ia64/pv_ops: move down __kernel_syscall_via_epc.
      ia64/pv_ops: paravirtualize gate.S.
      ia64/pv_ops/xen/gate.S: xen gate page paravirtualization
      ia64/pv_op/binarypatch: add helper functions to support binary patc=
hing for paravirt_ops.
      ia64/pv_ops: implement binary patching optimization for native.
      ia64/pv_ops/bp/module: support binary patching for kernel module.
      ia64/pv_ops/binary patch: define paravirt_dv_serialize_data() and s=
uppress false positive warning.
      ia64/pv_ops/bp/xen: implemented binary patchable pv_cpu_ops.
      ia64/xen: fix the link error.
      ia64: remove some warnings.

Ivan Kokshaysky (2):
      PCI/alpha: pci sysfs resources
      alpha: xchg/cmpxchg cleanup and fixes

Ivan Martinez (2):
      Staging: comedi: add cb_pcidas driver
      Staging: comedi: add cb_pcidda driver

Ivo van Doorn (33):
      rt2x00: Implement Powersaving
      rt2x00: Move link tuning into seperate file
      rt2x00: Reduce calls to bbp_read()
      rt2x00: Restrict interface between rt2x00link and drivers
      rt2x00: Add RFKILL support to rt2500usb and rt73usb
      rt2x00: Rename CONFIG_CRYPTO_COPY_IV
      rt2x00: Implement WDS support
      rt2x00: Split EEPROM_NIC_TX_RX_FIXED
      rt2x00: Move code into seperate functions
      rt2x00: Remove ENTRY_TXD_OFDM_RATE
      rt2x00: Allow drivers to pass the noise value during rxdone
      rt2x00: Introduce RXDONE_SIGNAL_MASK mask
      rt2x00: Release rt2x00 2.3.0
      rt2x00: Replace RFKILL with INPUT
      rt2x00: Only register rfkill input when key is present
      rt2x00: Update copyright year to 2009
      rt2x00: conf_tx() only need register access for WMM queues
      rt2x00: Add LED_MODE_ASUS support
      rt2x00: rt2x00_rev() should return u32
      rt2x00: Restrict firmware file lengths
      rt2x00: Simplify suspend/resume handling
      rt2x00: Move intf_work to mac82011 workqueue
      rt2x00: Add kill_tx_queue callback function
      rt2x00: Validate firmware in driver
      Add new rt73usb USB ID
      rt2x00: uncomment get_tsf
      rt2x00: Remove check for rf word 0
      rt2x00: Add various new USB IDs for rt73usb
      rt2x00: Fix RF offset
      rt2x00: Fix SW antenna diversity
      rt2x00: Export all register stats through debugfs
      rt2x00: Update MAINTAINERS entry: new mailinglist
      rt2x00: New USB ID for rt73usb

Izik Eidus (2):
      KVM: introduce kvm_read_guest_virt, kvm_write_guest_virt
      KVM: remove the vmap usage

J. Bruce Fields (25):
      nfsd4: split lockstateid/openstateid release logic
      nfsd4: remove a forward declaration
      nfsd4: split open/lockowner release code
      nfsd: clarify exclusive create bitmask result.
      nfsd4: fix misplaced comment
      nfsd4: use helper for copying filehandles for replay
      nfsd4: use helper for copying delegation filehandle
      nfsd4: trivial preprocess_stateid_op cleanup
      nfsd4: move check_stateid_generation check
      nfsd4: remove redundant "if" in nfs4_preprocess_stateid_op
      nfsd4: remove unneeded local variable
      nfsd4: remove some dprintk's
      nfsd4: add a helper function to decide if stateid is delegation
      nfsd4: separate delegreturn case from preprocess_stateid_op
      nfsd4: fail when delegreturn gets a non-delegation stateid
      nfsd4: remove unused CHECK_FH flag
      nfsd4: rename io_during_grace_disallowed
      nfsd4: put_nfs4_client does not require state lock
      nfsd4: remove use of mutex for file_hashtable
      nfsd4: fix do_probe_callback errors
      nfsd4: move rpc_client setup to a separate function
      nfsd4: support putpubfh operation
      nfsd4: don't do lookup within readdir in recovery code
      nfsd4: remove redundant check from nfsd4_open
      nfsd4: don't check ip address in setclientid

J. R. Okajima (1):
      loop: add ioctl to resize a loop device

J.P. Mellor (1):
      Staging: comedi: add ni_660x driver

Jack Morgenstein (3):
      IPoIB: In unicast_arp_send(), only free newly-created paths
      mlx4_core: Add device IDs for MT25458 10GigE devices
      IB/sa_query: Fix AH leak due to update_sm_ah() race

Jack Steiner (16):
      sgi-gru: exclude UV definitions on 32-bit x86
      sgi-gru: add definitions of x86_64 GRU MMRs
      sgi-gru: add definitions of ia64 GRU MMRs
      sgi-gru: add macros for using the UV hub to send interrupts
      sgi-gru: misc GRU cleanup
      sgi-gru: improvements to GRU debug messages & statistics
      sgi-gru: change GRU CCH commands from inline functions to outofline=
 functions
      sgi-gru: add statistics to the GRU context management functions
      sgi-gru: add support for a user to explicitly unload a GRU context
      sgi-gru: aSID (context management) bug fixes
      sgi-gru: restructure the GRU vtop functions
      sgi-gru: add support to the GRU driver for message queue interrupts
      sgi-gru: macro for scanning all gru chiplets
      sgi-gru: fix bugs related to module unload of the GRU driver
      sgi-gru: support multiple pagesizes in GRU
      cpumask: fix slab corruption caused by alloc_cpumask_var_node()

Jaikumar Ganesh (1):
      Bluetooth: When encryption is dropped, do not send RFCOMM packets

James Bottomley (6):
      x86: fix build breakage on voyage
      x86: fix "__udivdi3" [drivers/scsi/aha1542.ko] undefined
      [SCSI] osst: Remove SUGGEST flags
      [SCSI] Make scsi.h independent of the rest of the scsi includes
      parisc: fix macro expansion in atomic.h
      [SCSI] fix recovered error handling

James Hsiao (1):
      crypto: amcc - Add crypt4xx driver

James Morris (26):
      maintainers: add security subsystem wiki
      selinux: remove unused bprm_check_security hook
      selinux: remove secondary ops call to bprm_committing_creds
      selinux: remove secondary ops call to bprm_committed_creds
      selinux: remove secondary ops call to sb_mount
      selinux: remove secondary ops call to sb_umount
      selinux: remove secondary ops call to inode_link
      selinux: remove secondary ops call to inode_unlink
      selinux: remove secondary ops call to inode_mknod
      selinux: remove secondary ops call to inode_follow_link
      selinux: remove secondary ops call to inode_permission
      selinux: remove secondary ops call to inode_setattr
      selinux: remove secondary ops call to file_mprotect
      selinux: remove secondary ops call to task_create
      selinux: remove unused cred_commit hook
      selinux: remove secondary ops call to task_setrlimit
      selinux: remove secondary ops call to task_kill
      selinux: remove secondary ops call to unix_stream_connect
      selinux: remove secondary ops call to shm_shmat
      selinux: remove hooks which simply defer to capabilities
      IMA: fix ima_delete_rules() definition
      Merge branch 'master' into next
      security: change link order of LSMs so security=3Dtomoyo works
      Merge branch 'master' into next
      Merge branch 'master' into next
      Merge branch 'master' of ssh://master.kernel.org/pub/scm/linux/kern=
el/git/torvalds/linux-2.6 into next

James Woodcock (1):
      USB: serial: refuse to open recently removed USB Serial devices

Jan Beulich (17):
      x86: fully honor "nolapic"
      x86: avoid early crash in disable_local_APIC()
      x86: remove leftover unwind annotations
      x86-64: move save_paranoid into .kprobes.text
      x86-64: remove unnecessary spill/reload of rbx from memcpy
      x86: fix HYPERVISOR_update_descriptor()
      x86: move a few device initialization objects into .devinit.rodata
      x86: move various CPU initialization objects into .cpuinit.rodata
      x86: smarten /proc/interrupts output
      x86, 32-bit: also limit NODES_HIGH_SHIFT here
      x86, 32-bit: also use cpuinfo_x86's x86_{phys,virt}_bits members
      x86: move save_mr() into .meminit.text
      x86: properly __init-annotate recent early_printk additions
      x86: clean up output resulting from update_mptable option
      x86: fix code paths used by update_mptable
      x86: create a non-zero sized bm_pte only when needed
      ACPI: constify tables in pci_irq.c

Jan Dumon (3):
      hso: add Vendor/Product ID's for new devices
      hso: fix for crash when unplugging the device
      hso: fix for the 'invalid frame length' messages

Jan Engelhardt (13):
      net: constify VFTs
      netfilter: remove unneeded goto
      netfilter: Combine ipt_TTL and ip6t_HL source
      netfilter: Combine ipt_ttl and ip6t_hl source
      netfilter: xtables: add backward-compat options
      netfilter: install missing headers
      [SCSI] lpfc: constify virtual function tables
      netfilter: xtables: avoid pointer to self
      netfilter: trivial Kconfig spelling fixes
      fs: make struct dentry->d_op const
      V4L/DVB (10391): dvb: constify VFTs
      ACPI: constify VFTs (1/2)
      ACPI: constify VFTs (2/2)

Jan Glauber (9):
      [S390] qdio: add missing tiq_list locking
      [S390] qdio: Dont call qdio_shutdown in case qdio_activate fails
      [S390] qdio: proper kill of qdio tasklets
      [S390] qdio: call qdio_free also if qdio_shutdown fails
      [S390] qdio: move ACK to newest buffer for devices without QEBSM
      [S390] qdio: seperate last move index and polling index
      [S390] qdio: tasklet termination in case of module unload
      [S390] qdio: report SIGA errors directly
      [S390] qdio: merge inbound and outbound handler functions

Jan Kara (30):
      ext3: Remove unnecessary quota functions
      ext4: Remove unnecessary quota functions
      reiserfs: Remove unnecessary quota functions
      quota: Move quota files into separate directory
      quota: Make global quota locks cacheline aligned
      quota: Remove NODQUOT macro
      quota: Remove dqbuf_t and other cleanups
      vfs: Use lowercase names of quota functions
      ramfs: Remove quota call
      ext2: Use lowercase names of quota functions
      ext3: Use lowercase names of quota functions
      ext4: Use lowercase names of quota functions
      reiserfs: Use lowercase names of quota functions
      ufs: Use lowercase names of quota functions
      udf: Use lowercase names of quota functions
      jfs: Use lowercase names of quota functions
      nfsd: Use lowercase names of quota functions
      quota: Remove uppercase aliases for quota functions.
      quota: Remove superfluous inlines
      quota: Coding style fixes
      ext3: Avoid starting a transaction in writepage when not necessary
      jbd2: Update locking coments
      udf: fix sparse warnings:
      udf: Add checks to not underflow sector_t
      udf: Fix oops when invalid character in filename occurs
      udf: Some type fixes and cleanups
      udf: Try anchor in block 256 first
      udf: Don't write integrity descriptor too often
      jbd: fix oops in jbd_journal_init_inode() on corrupted fs
      ext3: avoid false EIO errors

Jan Kiszka (8):
      KVM: VMX: Support for injecting software exceptions
      KVM: New guest debug interface
      KVM: VMX: Allow single-stepping when uninterruptible
      KVM: x86: Virtualize debug registers
      KVM: x86: Wire-up hardware breakpoints for guest debugging
      KVM: Remove old kvm_guest_debug structs
      KVM: Advertise guest debug capability per-arch
      KVM: Drop unused evaluations from string pio handlers

Jan Nikitenko (1):
      MIPS: Fix oops in dma_unmap_page on not coherent mips platforms

Jan-Bernd Themann (1):
      ehea: fix circular locking problem

Jani Nikula (1):
      ALSA: Add support for video out to the jack reporting API

Janne Grunau (20):
      V4L/DVB (11095): adds V4L2_CID_SHARPNESS to v4l2_ctrl_query_fill()
      V4L/DVB (11096): V4L2 Driver for the Hauppauge HD PVR usb capture d=
evice
      V4L/DVB (11097): use video_ioctl2 as ioctl handler directly
      V4L/DVB (11125): fix mispelled Hauppauge in HD PVR and PVR USB2 dri=
ver comments
      V4L/DVB (11152): hdpvr: Fix build with Config_I2C not set
      V4L/DVB (11228): hdpvr: use debugging macro for buffer status
      V4L/DVB (11229): hdpvr: set usb interface dev as parent in struct v=
ideo_device
      V4L/DVB (11230): hdpvr: return immediately from hdpvr_poll if data =
is available
      V4L/DVB (11231): hdpvr: locking fixes
      V4L/DVB (11245): hdpvr: add struct v4l2_device
      V4L/DVB (11246): hdpvr: convert printing macros to v4l2_* with stru=
ct v4l2_device
      V4L/DVB (11247): hdpvr: empty internal device buffer after stopping=
 streaming
      V4L/DVB (11351): v4l: use usb_interface for v4l2_device_register
      V4L/DVB (11352): cx231xx: use usb_interface.dev for v4l2_device_reg=
ister
      V4L/DVB (11353): cx231xx: remove explicitly set v4l2_device.name
      V4L/DVB (11354): usbvision: use usb_interface.dev for v4l2_device_r=
egister
      V4L/DVB (11355): pvrusb2: use usb_interface.dev for v4l2_device_reg=
ister
      V4L/DVB (11356): au0828: use usb_interface.dev for v4l2_device_regi=
ster
      V4L/DVB (11357): au0828: remove explicitly set v4l2_device.name and=
 unused au0828_instance
      V4L/DVB (11358): w9968cf: use usb_interface.dev for v4l2_device_reg=
ister

Jarek Poplawski (7):
      net: Optimize memory usage when splicing from sockets.
      pkt_sched: sch_hfsc: sch_htb: Add non-work-conserving warning handl=
er.
      pkt_sched: sch_htb: Warn on too many events.
      pkt_sched: sch_htb: Use workqueue to schedule after too many events.
      pkt_sched: sch_multiq: Change errno on non-multiqueue devices use.
      net: Fix page seeking for skb_splice_bits().
      pkt_sched: Change misleading code in class delete.

Jarkko Lavinen (3):
      omap_hsmmc: Do dma cleanup also with data CRC errors
      omap_hsmmc: Add 8-bit bus width mode support
      omap_hsmmc: Disable SDBP at suspend

Jarkko Nikula (9):
      ASoC: TLV320AIC3X: Fix volume ranges
      ASoC: TLV320AIC3X: Add TLV information for volume controls
      ASoC: OMAP: N810: Mark not connected input pins
      ASoC: OMAP: N810: Add more jack functions
      ARM: OMAP: Add documentation for function omap_register_i2c_bus
      ARM: OMAP: Add command line option for I2C bus speed, v2
      ARM: OMAP: Add method to register additional I2C busses on the comm=
and line, v2
      ARM: OMAP3: Remove unused CONFIG_I2C2_OMAP_BEAGLE
      ASoC: OMAP: Set minimum buffer size constraint for McBSP2 in OMAP3

Jaroslav Kysela (3):
      ALSA: Release v1.0.19
      ALSA: snd-hda-intel: Fix ALC662/ALC663 Beep Amplifier Index
      ALSA: snd-hda-intel - add checks for invalid values to *query_suppo=
rted_pcm()

Jason Andryuk (7):
      at76c50x-usb: update to latest mac80211 hw scan api
      at76c50x-usb: convert at76_debug to an unsigned int
      at76c50x-usb: fix oops on disconnect
      at76c50x-usb: clean up DMA on stack
      at76c50x-usb: additional disconnect fixes
      iwl3945: initialize is_valid_rtc_data_addr function pointer
      iwl3945: re-add iwl_poll_direct_bit return value check

Jason Baron (6):
      tracing: convert c/p state power tracer to use tracepoints
      tracing, genirq: add irq enter and exit trace events
      tracing: tracepoints for softirq entry/exit - add softirq-to-name a=
rray
      tracing: tracepoints for softirq entry/exit - tracepoints
      dynamic debug: combine dprintk and dynamic printk
      dynamic debug: update docs

Jaswinder Singh Rajput (99):
      x86: smp.h remove obsolete function declaration
      x86: smp.h move zap_low_mappings declartion to tlbflush.h
      x86: smp.h move prefill_possible_map declartion to cpu.h
      x86: smp.h move stack_processor_id declartion to cpu.h
      x86: smp.h move safe_smp_processor_id declartion to cpu.h
      x86: smp.h move cpu_physical_id declartion to cpu.h
      x86: smp.h move boot_cpu_id declartion to cpu.h
      x86: rename intel_mp_floating to mpf_intel
      x86: rename all fields of mpf_intel mpf_X to X
      x86: smp.h move cpu_callin_mask and cpu_callin_map declartion to cp=
umask.h
      x86: smp.h move cpu_callout_mask and cpu_callout_map declartion to =
cpumask.h
      x86: smp.h move cpu_initialized_mask and cpu_initialized declartion=
 to cpumask.h
      x86: smp.h move cpu_sibling_setup_mask and cpu_sibling_setup_map de=
clartion to cpumask.h
      x86: microcode_intel.c fix style problems
      x86: msr.c fix style problems
      x86: module_32.c fix style problems
      x86: module_64.c fix style problems
      x86: replacing mp_config_ioapic with mpc_ioapic
      x86: replacing mp_config_intsrc with mpc_intsrc
      headers_check fix: alpha, statfs.h
      headers_check fix: alpha, swab.h
      headers_check fix: arm, a.out.h
      headers_check fix: arm, setup.h
      headers_check fix: arm, swab.h
      headers_check fix: avr32, swab.h
      headers_check fix: blackfin, swab.h
      headers_check fix: frv, swab.h
      headers_check fix: h8300, swab.h
      headers_check fix: ia64, fpu.h
      headers_check fix: ia64, gcc_intrin.h
      headers_check fix: ia64, intrinsics.h
      headers_check fix: ia64, kvm.h
      headers_check fix: ia64, swab.h
      headers_check fix: m32r, swab.h
      headers_check fix: mips, sigcontext.h
      headers_check fix: mips, swab.h
      headers_check fix: mn10300, swab.h
      headers_check fix: parisc, pdc.h
      headers_check fix: parisc, swab.h
      headers_check fix: powerpc, bootx.h
      headers_check fix: powerpc, elf.h
      headers_check fix: powerpc, kvm.h
      headers_check fix: powerpc, ps3fb.h
      headers_check fix: powerpc, spu_info.h
      headers_check fix: powerpc, swab.h
      headers_check fix: xtensa, swab.h
      headers_check fix: linux/coda_psdev.h
      headers_check fix: linux/in6.h
      headers_check fix: linux/nubus.h
      headers_check fix: linux/socket.h
      headers_check fix: linux/reinserfs_fs.h
      headers_check fix: x86, prctl.h
      headers_check fix: x86, setup.h
      headers_check fix cleanup: linux/coda_psdev.h
      headers_check fix cleanup: linux/nubus.h
      headers_check fix cleanup: linux/reiserfs_fs.h
      Neither asm/types.h nor linux/types.h is required for arch/ia64/inc=
lude/asm/fpu.h
      make linux/types.h as assembly safe
      unconditionally include asm/types.h from linux/types.h
      x86: mm/init_32.c fix compilation warning
      x86: kernel/mpparse.c fix compilation warnings
      drm_proc.c fix compilation warning
      falcon fix compilation warnings
      iscsi_ibft.c fix compilation warning
      ne3210.c fix compilation warning for phys_addr_t
      arlan-main.c fix compilation warnings for phys_addr_t
      x86: include/asm/processor.h remove double declaration of print_cpu=
_info
      x86: remove double copy of show_cpuinfo_core for 32 and 64 bit
      x86: cpu architecture debug code
      x86: cpu architecture debug code, build fix, cleanup
      x86: cpu_debug add write support for MSRs
      x86: cpu/common.c cleanups
      x86: entry_32.S fix compile warnings - fix work mask bit width
      x86: cpu_debug add support for various AMD CPUs
      x86: cpu/mttr/cleanup.c fix compilation warning
      x86: kprobes.c fix compilation warning
      x86: mpparse: clean up code by introducing a few helper functions
      tracing: fix oops in tracepoint_update_probe_range()
      x86: mpparse.c introduce smp_dump_mptable helper function
      x86: mpparse.c introduce check_physptr helper function
      x86: topology.c cleanup
      x86: kdebugfs.c cleanup
      x86: i8253 cleanup
      x86: rtc.c cleanup
      x86: io_delay.c cleanup
      x86: pci-nommu.c cleanup
      x86: cpu/cpu.h cleanup
      x86: irq.c use same path for show_interrupts
      x86: irq.c keep CONFIG_X86_LOCAL_APIC interrupts together
      x86: apic/io_apic.c define msi_ir_chip and ir_ioapic_chip all the t=
ime
      x86: e820 fix various signedness issues in setup.c and e820.c
      unconditionally include asm/types.h from linux/types.h
      yam: use request_firmware
      3C359: use request_firmware
      smc91c92_cs: use request_firmware
      [SCSI] qla1280: use request_firmware
      [SCSI] advansys: use request_firmware
      [SCSI] qlogicpti: use request_firmware
      myri_sbus: use request_firmware

Jay Fenlason (4):
      firewire: add a client_list_lock
      firewire: cdev: use an idr rather than a linked list for resources
      firewire: implement asynchronous stream transmission
      firewire: broadcast channel support

Jay Fenlason, Stefan Richter (2):
      firewire: cdev: add ioctls for isochronous resource management
      firewire: cdev: add ioctl for broadcast write requests

Jay Sternberg (13):
      iwlwifi: correct Kconfig to prevent following entries from not inde=
nting
      iwlwifi: remove static from 5000 structures
      iwlwifi: add recognition of Intel WiFi Link 6000 and 6050 Series
      iwlwifi: add recognition of Intel WiFi Link 100 Series
      iwlwifi: add new HW_REV_TYPEs for Intel WiFi Link 100, 6000 and 605=
0 Series
      iwlwifi: simplify parameter setting to allow support for 6000 serie=
s
      iwlwifi: parametrize configuration of the PLL for exclusion on 6000
      iwlwifi: correct API command overlap
      iwlwifi: define structures and functions externally for customizati=
on
      iwlwifi: remove chain noise calibration functions from 6000 family
      ipw2x00: correct Kconfig to prevent following entries from not inde=
nting
      iwlwifi: update 5150 API version to support new firmware
      iwlwifi: correct device name for 1000 series

Jaya Kumar (2):
      [ARM] 5353/1: fbdev: add E-Ink Broadsheet controller support v3
      [ARM] 5354/1: mach-pxa: add AM300 platform driver v3

Jean Delvare (33):
      [SCSI] libiscsi: fix iscsi pool error path
      i2c: Document the different ways to instantiate i2c devices
      i2c: Let checkpatch shout on users of the legacy model
      i2c: Clarify which clients are auto-removed
      i2c-nforce2: Add support for MCP67, MCP73, MCP78S and MCP79
      i2c: Set a default timeout value for all adapters
      i2c: Adapter timeout is in jiffies
      i2c-davinci: Fix timeout handling
      V4L/DVB (10867): vino: fold i2c-algo-sgi code into vino.
      V4L/DVB (10931): zoran: Drop the lock_norm module parameter
      V4L/DVB (10932): zoran: Don't frighten users with failed buffer all=
ocation
      V4L/DVB (10938): em28xx: Prevent general protection fault on rmmod
      V4L/DVB (10939): ir-kbd-i2c: Prevent general protection fault on rm=
mod
      V4L/DVB (10940): saa6588: Prevent general protection fault on rmmod
      V4L/DVB (10943): cx88: Prevent general protection fault on rmmod
      V4L/DVB (11111a): MAINTAINERS: Drop references to deprecated video4=
linux list
      hwmon: (ds1621) Reorder code statements
      hwmon: (ds1621) Clean up register access
      hwmon: (ds1621) Avoid unneeded register access
      hwmon: (ds1621) Clean up documentation
      hwmon: (w83627ehf) Invert fan pin variables logic
      Move the pcf8591 driver to hwmon
      hwmon: Define a standard interface for chassis intrusion detection
      dmi: Let dmi_walk() users pass private data
      DRM: drm_crtc_helper.h doesn't actually need i2c.h
      workqueue: add to_delayed_work() helper function
      [SCSI] libiscsi: fix iscsi pool error path
      i2c: Deprecate client_register and client_unregister methods
      i2c: Delete many unused driver IDs
      i2c: Delete unused i2c-algo-sgi helper module
      ibm_newemac: Fix dangerous struct assumption
      V4L/DVB (11437): pvrusb2: Drop client_register/unregister stubs
      hwmon: (lm95241) Convert to new-style i2c driver

Jean-Baptiste Joret (1):
      [S390] dasd_eckd / Write format R0 is now allowed BB

Jean-Christop PLAGNIOL-VILLARD (1):
      [ARM] 5412/1: XSCALE: add ice dcc support

Jean-Francois Moine (76):
      V4L/DVB (10332): gspca - main: Version change.
      V4L/DVB (10333): gspca - main and many subdrivers: Remove the epadd=
r variable.
      V4L/DVB (10337): gspca - common: Simplify the debug macros.
      V4L/DVB (10343): gspca - zc3xx / zc0301: Handle the 0ac8:303b inste=
ad of zc0301.
      V4L/DVB (10345): gspca - jpeg subdrivers: One quantization table pe=
r subdriver.
      V4L/DVB (10346): gspca - zc3xx: Fix bad variable type with i2c read.
      V4L/DVB (10347): gspca - mars: Optimize, rewrite initialization and=
 add controls.
      V4L/DVB (10348): gspca - mars: Bad isoc packet scanning.
      V4L/DVB (10350): gspca - tv8532: Cleanup code.
      V4L/DVB (10352): gspca - spca508: Cleanup code.
      V4L/DVB (10353): gspca - some subdrivers: Don't get the control val=
ues from the webcam.
      V4L/DVB (10354): gspca - tv8532: Change the max brightness.
      V4L/DVB (10356): gspca - sonixj: Cleanup code.
      V4L/DVB (10357): gspca - main: Cleanup code.
      V4L/DVB (10360): gspca - mars: Bad interface/altsetting since 0a10a=
0e906be.
      V4L/DVB (10361): gspca - sonixj: Gamma control added.
      V4L/DVB (10363): gspca - spca500: Abnormal error message when start=
ing ClickSmart310.
      V4L/DVB (10367): gspca - spca561: Optimize the isoc scanning functi=
on.
      V4L/DVB (10368): gspca - spca561: Fix bugs and rewrite the init/sta=
rt of the rev72a.
      V4L/DVB (10370): gspca - main: Have 3 URBs instead of 2 for ISOC tr=
ansfers.
      V4L/DVB (10371): gspca - spca561: Fix image problem in the 352x288 =
mode of rev72a.
      V4L/DVB (10372): gspca - sonixj: Cleanup code.
      V4L/DVB (10373): gspca - zc3xx: Sensor adcm2700 added.
      V4L/DVB (10374): gspca - zc3xx: Bad probe of the sensor adcm2700.
      V4L/DVB (10375): gspca - zc3xx: Remove duplicated sequence of senso=
r cs2102k.
      V4L/DVB (10376): gspca - zc3xx: Remove some useless tables of senso=
r adcm2700.
      V4L/DVB (10378): gspca - main: Avoid error on set interface on disc=
onnection.
      V4L/DVB (10380): gspca - t613: Cleanup and optimize code.
      V4L/DVB (10381): gspca - t613: New unknown sensor added.
      V4L/DVB (10382): gspca - t613: Bad returned value when no known sen=
sor found.
      V4L/DVB (10383): gspca - spca505: Cleanup and optimize code.
      V4L/DVB (10384): gspca - spca505: Simplify and add the brightness i=
n start.
      V4L/DVB (10387): gspca - spca505: Move some sequences from probe to=
 streamon.
      V4L/DVB (10389): gspca - zc3xx: Do work the sensor adcm2700.
      V4L/DVB (10419): gspca - sonixj: Sensor mt9v111 added.
      V4L/DVB (10420): gspca - vc032x: Webcam 041e:405b added and mi1310_=
soc updated.
      V4L/DVB (10421): gspca - documentation: Add the webcam 041e:405b.
      V4L/DVB (10423): gspca - sonixj: Bad sensor definition of the webca=
ms 0c45:60c0.
      V4L/DVB (10424): gspca - vc032x: Add resolution 1280x1024 for senso=
r mi1310_soc.
      V4L/DVB (10425): gspca - sonixj: Bad initialization of sensor mt9v1=
11.
      V4L/DVB (10427): gspca - sonixj: Sensor sp80708 added for webcam 0c=
45:6143.
      V4L/DVB (10428): gspca - sonixj: Specific gamma tables per sensor.
      V4L/DVB (10429): gspca - sonixj: Simplify the probe of the sensors =
mi0360/mt9v111.
      V4L/DVB (10430): gspca - sonixj: Adjust some exchanges with the sen=
sor mt9v111.
      V4L/DVB (10431): gspca - vc032x: Bad revision for the webcam 041e:4=
05b.
      V4L/DVB (10432): gspca - vc032x: Cleanup source, optimize and check=
 i2c_write.
      V4L/DVB (10617): gspca - vc032x: Remove the vc0321 reset.
      V4L/DVB (10618): gspca - some drivers: Fix compilation warnings.
      V4L/DVB (10620): gspca - main: More checks of the device disconnect=
ion.
      V4L/DVB (10635): gspca - sonixj: No vertical flip control for mt9v1=
11.
      V4L/DVB (10636): gspca - sonixj: Add autogain for ov7630/48 and vfl=
ip for ov7648.
      V4L/DVB (10637): gspca - t613: Bad sensor name in kernel trace when=
 'other' sensor.
      V4L/DVB (10638): gspca - t613: Bad debug level when displaying the =
sensor type.
      V4L/DVB (10679): gspca - sonixj: Handle the webcam 0c45:613c instea=
d of sn9c102.
      V4L/DVB (10680): gspca - zc3xx: Bad probe of the ov7xxx sensors.
      V4L/DVB (10681): gspca - zc3xx: Bad probe of the ov7630c sensor.
      V4L/DVB (10787): gspca - mars: Bad webcam register values tied to s=
aturation.
      V4L/DVB (10788): gspca - vc032x: Bad matrix for sensor mi1310_soc.
      V4L/DVB (11039): gspca - most jpeg subdrivers: Change the JPEG head=
er creation.
      V4L/DVB (11040): gspca - most jpeg subdrivers: Have the JPEG qualit=
y settable.
      V4L/DVB (11103): gspca - main: May have isochronous transfers on al=
tsetting 0
      V4L/DVB (11104): gspca - ov534: Bad frame pointer after adding the =
last packet
      V4L/DVB (11105): gspca - ov534: Adjust the packet scan function
      V4L/DVB (11106): gspca - ov534: New sensor ov965x and re-enable the=
 webcam 06f8:3003
      V4L/DVB (11143): gspca - t613: Bad sensor detection.
      V4L/DVB (11144): gspca - t613: Don't re-read the ID registers at pr=
obe time.
      V4L/DVB (11145): gspca - t613: Greater delay after om6802 reset.
      V4L/DVB (11146): gspca - vc032x: Change the probe sequence.
      V4L/DVB (11209): gspca - vc032x: New sensor mi1320_soc and webcam 1=
5b8:6001 added.
      V4L/DVB (11211): gspca - vc032x: Simplify the i2c write function.
      V4L/DVB (11212): gspca - vc032x: Use YVYU format for sensor mi1320_=
soc.
      V4L/DVB (11218): gspca - sq905: Update the frame pointer after addi=
ng the last packet.
      V4L/DVB (11219): gspca - sq905: Optimize the resolution setting.
      V4L/DVB (11220): gspca - finepix: Use a workqueue for streaming.
      V4L/DVB (11223): gspca - doc: Add the 15b8:6001 webcam to the Docum=
entation.
      V4L/DVB (11402): gspca - vc032x: Remove the JPEG tables of mi1320_s=
oc.

Jeff Kirsher (1):
      igb: remove LRO Kconfig option

Jeff Layton (2):
      cifs: fix buffer format byte on NT Rename/hardlink
      writeback: guard against jiffies wraparound on inode->dirtied_when =
checks (try #3)

Jeff Mahoney (36):
      reiserfs: add support for mount count incrementing
      reiserfs: audit transaction ids to always be unsigned ints
      reiserfs: use buffer_info for leaf_paste_entries
      reiserfs: use more consistent printk formatting
      reiserfs: make some warnings informational
      reiserfs: rework reiserfs_warning
      reiserfs: prepare_error_buf wrongly consumes va_arg
      reiserfs: eliminate reiserfs_warning from uniqueness functions
      reiserfs: add locking around error buffer
      reiserfs: rework reiserfs_panic
      reiserfs: rearrange journal abort
      reiserfs: introduce reiserfs_error()
      reiserfs: use reiserfs_error()
      reiserfs: small variable cleanup
      reiserfs: xattr reiserfs_get_page takes offset instead of index
      reiserfs: remove link detection code
      reiserfs: remove IS_PRIVATE helpers
      reiserfs: Clean up xattrs when REISERFS_FS_XATTR is unset
      reiserfs: simplify xattr internal file lookups/opens
      reiserfs: eliminate per-super xattr lock
      reiserfs: make per-inode xattr locking more fine grained
      reiserfs: remove i_has_xattr_dir
      reiserfs: use generic xattr handlers
      reiserfs: journaled xattrs
      reiserfs: use generic readdir for operations across all xattrs
      reiserfs: add atomic addition of selinux attributes during inode cr=
eation
      reiserfs: factor out buffer_info initialization
      reiserfs: cleanup path functions
      reiserfs: strip trailing whitespace
      reiserfs: rename p_s_sb to sb
      reiserfs: rename p_s_bh to bh
      reiserfs: rename p_s_inode to inode
      reiserfs: rename p_s_tb to tb
      reiserfs: rename p_._ variables
      reiserfs: rename [cn]_* variables
      reiserfs: xattr_create is unused with xattrs disabled

Jens Axboe (21):
      block: don't create bio_vec slabs of less than the inline number
      cciss: add BUILD_BUG_ON() for catching bad CommandList_struct align=
ment
      block: remove various blk_queue_*() setting functions in blk_init_q=
ueue_node()
      block: get rid of unused blkdev_free_rq() define
      Move the default_backing_dev_info out of readahead.c and into backi=
ng-dev.c
      btrfs: get rid of current_is_pdflush() in btrfs_btree_balance_dirty
      Get rid of pdflush_operation() in emergency sync and remount
      block: change the request allocation/congestion logic to be sync/as=
ync based
      Add WRITE_SYNC_PLUG and SWRITE_SYNC_PLUG
      block: fsync_buffers_list() should use SWRITE_SYNC_PLUG
      jbd: use WRITE_SYNC_PLUG instead of WRITE_SYNC
      jbd2: use WRITE_SYNC_PLUG instead of WRITE_SYNC
      block: enabling plugging on SSD devices that don't do queuing
      block: Add flag for telling the IO schedulers NOT to anticipate mor=
e IO
      block: switch sync_dirty_buffer() over to WRITE_SYNC
      block: elevator quiescing helpers
      cciss: fix residual count for block pc requests
      cfq-iosched: change dispatch logic to deal with single requests at =
the time
      cfq-iosched: kill two unused cfqq flags
      block: remove unused REQ_UNPLUG
      cfq-iosched: don't let idling interfere with plugging

Jeremy Fitzhardinge (112):
      x86/pvops: remove pte_flags pvop
      x86: add pte_set_flags/clear_flags for pte flag manipulation
      x86: unify asm/io.h: IO_SPACE_LIMIT
      xen: move remaining mmu-related stuff into mmu.c
      x86/pvops: add a paravirt_ident functions to allow special patching
      x86: fix paravirt clobber in entry_64.S
      x86/paravirt: selectively save/restore regs around pvops calls
      x86/paravirt: add register-saving thunks to reduce caller register =
pressure
      x86/paravirt: implement PVOP_CALL macros for callee-save functions
      x86/paravirt: use callee-saved convention for pte_val/make_pte/etc
      x86/paravirt: fix missing callee-save call on pud_val
      x86: split loading percpu segments from loading gdt
      xen: setup percpu data pointers
      x86/paravirt: don't restore second return reg
      x86/vmi: fix interrupt enable/disable/save/restore calling conventi=
on.
      x86/paravirt: return full 64-bit result
      xen: fix 32-bit build resulting from mmu move
      xen: setup percpu data pointers
      xen: make direct versions of irq_enable/disable/save/restore to com=
mon code
      xen: use direct ops on 64-bit
      x86: unify pte_none
      x86: unify pte_same
      x86: unify pte_present
      x86: unify pud_present
      x86: unify pgd_present
      x86: unify pmd_present
      x86: unify pmd_none
      x86: unify pgd_page_vaddr
      x86: unify pud_page_vaddr
      x86: include pgtable_SIZE.h earlier
      x86: unify pud_page
      x86: unify pgd_page
      x86: unify pud_index
      x86: unify pud_offset
      x86: unify pmd_page_vaddr
      x86: unify pmd_page
      x86: unify pmd_index
      x86: unify pmd_offset
      x86: remove redundant pfn_pmd definition
      x86: unify pmd_pfn
      x86: unify pmd_pfn
      x86: unify pte_index
      x86: unify pte_offset_kernel
      x86: unify pud_large
      x86: unify pgd_bad
      x86: unify pgd_bad
      x86: unify pmd_bad
      x86: unify pages_to_mb
      x86: unify pud_none
      x86: unify pgd_none
      x86: unify io_remap_pfn_range
      x86: add and use pgd/pud/pmd_flags
      x86: make pgd/pud/pmd/pte_none consistent
      x86: asm/io.h: unify virt_to_phys/phys_to_virt
      x86: asm/io.h: unify ioremap prototypes
      x86: Fix compile error in arch/x86/kernel/early_printk.c
      x86: add handle_irq() to allow interrupt injection
      x86: unify do_IRQ()
      xen: set irq_chip disable
      xen: use our own eventchannel->irq path
      xen: pack all irq-related info together
      xen: remove irq bindcount
      xen: make sure that softirqs get handled at the end of event proces=
sing
      x86: use early_ioremap in __acpi_map_table
      x86: always explicitly map acpi memory
      acpi: remove final __acpi_map_table mapping before setting acpi_gbl=
_permanent_mmap
      x86: make apic_* operations inline functions
      x86: unstatic mp_find_ioapic so it can be used elsewhere
      x86: add mp_find_ioapic_pin
      x86: unstatic ioapic entry funcs
      Merge commit 'remotes/tip/x86/paravirt' into x86/untangle2
      x86: rename *-defs.h to *-_types.h for consistency
      Split pgtable.h into pgtable_types.h and pgtable.h
      x86: Split pgtable_32.h into pgtable_32.h and pgtable_32_types.h
      x86: Split pgtable_64.h into pgtable_64_types.h and pgtable_64.h
      x86: Include pgtable_32|64_types.h in pgtable_types.h
      x86: create _types.h counterparts for page*.h
      x86: move 2 and 3 level asm-generic defs into page-defs
      x86: move defs around to allow paravirt.h to just include page_type=
s.h
      x86: define pud_flags and pud_large properly to allow non-PAE build=
s
      x86: move pte types into pgtable*.h
      x86: use _types.h headers in asm where available
      x86: move more pagetable-related definitions into pgtable*.h
      Merge commit 'tip/x86/headers' into x86/untangle2
      x86, xen: short-circuit tests for dom0
      x86, xen: degrade BUG to WARN when multicall fails
      x86, xen: do multicall callbacks with interrupts disabled
      acpi: add some missing section markers
      x86-32: use non-lazy io bitmap context switching
      x86: unify chunks of kernel/process*.c
      x86: add forward decl for tss_struct
      xen: deal with virtually mapped percpu data
      x86: remove vestigial fix_ioremap prototypes
      x86: un-__init fill_pud/pmd/pte
      x86: clean up old gcc warnings
      x86-32: use specific __vmalloc_start_set flag in __virt_addr_valid
      x86: pre-initialize boot_cpu_data.x86_phys_bits to avoid system_sta=
te tests
      x86-32: make sure virt_addr_valid() returns false for fixmap addres=
ses
      x86: make section delimiter symbols part of their section
      x86: add brk allocation for very, very early allocations
      x86-32: use brk segment for allocating initial kernel pagetable
      x86: use brk allocation for DMI
      x86: allow extend_brk users to reserve brk space
      x86, paravirt: prevent gcc from generating the wrong addressing mod=
e
      x86-32: make sure we map enough to fit linear map pagetables
      x86-32: remove ALLOCATOR_SLOP from head_32.S
      x86/brk: make the brk reservation symbols inaccessible from C
      x86/brk: put the brk reservations in their own section
      x86/32: no need to use set_pte_present in set_pte_vaddr
      x86: with the last user gone, remove set_pte_present
      Revert "x86: create a non-zero sized bm_pte only when needed"
      x86/dmi: fix dmi_alloc() section mismatches

Jeremy Kerr (10):
      powerpc/spufs: Use correct return value for spu_handle_mm_fault
      powerpc/spufs: Clear purge status before setting up isolated mode
      powerpc/spufs: Constify context contents and coredump callback cons=
tants
      powerpc/spufs: Check file offset before calculating write size in f=
ixed-sized files
      powerpc/spufs: Fix incorrect buffer offset in regs write
      powerpc: Fix page_ins details in lppaca comments
      powerpc: Add dispatch trace log fields to lppaca
      powerpc: Add virtual processor dispatch trace log
      powerpc/cell: Fix iommu exception reporting
      powerpc: Add write barrier before enabling DTL flags

Jeremy Theler (1):
      Staging: comedi: add adq12b driver

Jerome Marchand (1):
      block: fix inconsistency in I/O stat accounting code

Jes Sorensen (4):
      KVM: ia64: stack get/restore patch
      KVM: ia64: expose registers in struct kvm_regs
      KVM: ia64: dynamic nr online cpus
      [IA64] Fix kstat_this_cpu build breakage

Jesper Dangaard Brouer (8):
      ipv4: Fix rp_filter description in net/ipv4/Kconfig.
      ipv4: Clean whitespaces in net/ipv4/Kconfig.
      Doc: Fix typos in ip-sysctl.txt about rp_filter.
      Doc: Cleanup whitespaces in ip-sysctl.txt
      Doc: Refer to ip-sysctl.txt for strict vs. loose rp_filter mode
      Doc: Fix missing whitespaces in RCU documentation.
      Doc: Fix wrong API example usage of call_rcu().
      Doc: Fix spelling in RCU/rculist_nulls.txt.

Jesper Juhl (1):
      kernel/cgroup.c: kfree(NULL) is legal

Jesper Nilsson (3):
      ipv6: Plug sk_buff leak in ipv6_rcv (net/ipv6/ip6_input.c)
      CRISv32: Remove extraneous space between -I and the path.
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/rusty/linux-2.6-cpumask-for-cris into for-next

Jesse Barnes (6):
      powerpc/PCI: include pci.h in powerpc MSI implementation
      drm/i915: check for -EINVAL from vm_insert_pfn
      drm/i915: add VGA hotplug support for 945+
      drm: Use pgprot_writecombine in GEM GTT mapping to get the right bi=
ts for !PAT.
      drm: fix EDID backward compat check
      drm: remove unused "can_grow" parameter from drm_crtc_helper_initia=
l_config

Jesse Brandeburg (19):
      e1000e: drop lltx, remove unnecessary lock
      igb: remove dead code in transmit routine
      e1000e: add aer support
      e1000e: remove workaround for e1000 hardware
      ixbge: fix bug when using large pages and jumbo frames
      e1000e: fix unmap bug
      e1000: fix unmap bug
      ixgbe: Fix interrupt configuration for 82599
      ixgbe: fix bug with napi add before request_irq
      ixgbe: Fix the Tx clean logic to return proper status
      ixgbe: Cleanup on the Rx init path
      ixgbe: Add a few safety nets for register writes and descriptor cle=
anups
      ixgbe: Cleanup some whitespace issues, fixup and add some comments
      ixgbe: Fixup the watchdog interrupt scheduling on 82599
      e1000: fix close race with interrupt
      e1000e: fix loss of multicast packets
      e1000e: fix close interrupt race
      e1000e: update version number
      e1000: fix loss of multicast packets

Jim Owens (1):
      Btrfs: remove unused ftrace include

Jiri Kosina (7):
      x86: remove byte locks
      HID: do not try to compile PM code with CONFIG_PM unset
      HID: hid_reset_resume() needs to be defined only when CONFIG_PM is =
set
      HID: bring back possibility to specify vid/pid ignore on module loa=
d
      HID: support for Kensington slimblade device
      HID: add support for Kye/Genius Ergo 525V
      Merge branch 'autosuspend' into for-next

Jiri Pirko (4):
      8139cp: allow to set mac address on running device
      8139too: allow to set mac address on running device
      bonding: select current active slave when enslaving device for mode=
 tlb and alb
      audit: EXECVE record - removed bogus newline

Jiri Slaby (18):
      IWL: fix WARN typo
      x86_32: summit_32, use BAD_APICID
      x86_32: summit_32, de-inline functions
      ipw2200, fix ipw io functions
      x86_32: apic/bigsmp_32, de-inline functions
      x86_32: apic/es7000_32, cpu_mask_to_apicid cleanup
      x86_32: apic/es7000_32, fix cpu_mask_to_apicid
      x86_32: apic/summit_32, fix cpu_mask_to_apicid
      x86_32: apic/es7000_32, fix section mismatch
      x86_32: apic/summit_32, fix section mismatch
      x86_32: apic/numaq_32, fix section mismatch
      ath5k: fix hw rate index condition
      ath5k: constify stuff
      ath5k: don't change mac in eeprom_read_mac on error
      PCI quirk: don't mark one netmos as class other
      HID: remove compat stuff
      tty: moxa, fix refcounting in moxa_poll_port
      mxser: remove tty_port_tty_get from mxser_check_modem_status

Joakim Tjernlund (1):
      ucc_geth: Convert to net_device_ops

Jochen Friedrich (2):
      V4L/DVB (10452): Add Freescale MC44S803 tuner driver
      V4L/DVB (10453): af9015: add MC44S803 support

Jochen Hein (1):
      trivial: Update contact info for Jochen Hein

Jody McIntyre (1):
      tracing: Documentation / sample code fixes for tracepoints

Joe Carnuccio (2):
      [SCSI] qla2xxx: Add Flash-Access-Control support for recent ISPs.
      [SCSI] qla2xxx: Add EDC-update support.

Joe Eykholt (2):
      [SCSI] fcoe: Add a header file defining the FIP protocol for FCoE.
      [SCSI] fcoe, libfcoe: Add support for FIP. FCoE discovery and keep-=
alive.

Joe Perches (4):
      sctp/ipv6.c: use ipv6_addr_copy
      dlm: use ipv6_addr_copy
      dlm: comment typo fixes
      KVM: SVM: Fix typo in has_svm()

Joel A. Fowler (1):
      ctcm: fix minor findings from code analysis tool

Joerg Roedel (26):
      dma-debug: add Kconfig entry
      dma-debug: add header file and core data structures
      dma-debug: add hash functions for dma_debug_entries
      dma-debug: add allocator code
      dma-debug: add initialization code
      dma-debug: add kernel command line parameters
      dma-debug: add debugfs interface
      dma-debug: add core checking functions
      dma-debug: add checking for map/unmap_page/single
      dma-debug: add add checking for map/unmap_sg
      dma-debug: add checking for [alloc|free]_coherent
      dma-debug: add checks for sync_single_*
      dma-debug: add checks for sync_single_range_*
      dma-debug: add checks for sync_single_sg_*
      dma-debug: x86 architecture bindings
      dma-debug: Documentation update
      dma-debug: add checks for kernel text and rodata
      dma-debug: add a check dma memory leaks
      dma-debug/x86: register pci bus for dma-debug leak detection
      dma-debug: make memory range checks more consistent
      KVM: SVM: Allow read access to MSR_VM_VR
      KVM: MMU: handle compound pages in kvm_is_mmio_pfn
      KVM: MMU: remove redundant check in mmu_set_spte
      KVM: MMU: remove assertion in kvm_mmu_alloc_page
      KVM: MMU: Fix another largepage memory leak
      x86/dma: unify definition of pci_unmap_addr* and pci_unmap_len macr=
os

Johannes Berg (82):
      ALSA: snd-aoa: handle older machines
      ALSA: snd-aoa: handle master-amp if present
      ssb/b43: add new N PHY device
      b43: detect N PHY revision/radio
      mac80211: clean up set_key callback
      mac80211: remove user_power_level from driver API
      mac80211: clarify alignment docs, fix up alignment
      mac80211: clean up channel type config
      mac80211: validate SIOCSIWPOWER arguments better
      mac80211: move dynamic PS timeout to hardware config
      mac80211: extend/document powersave API
      cfg80211: add PM hooks
      mac80211: constify ieee80211_if_conf.bssid
      wireless: restrict to 32 legacy rates
      mac80211: Add capability to enable/disable beaconing
      mac80211: add interface list lock
      mac80211: don't try to powersave/config disabled interfaces
      mac80211: remove HW_SIGNAL_DB
      mac80211: convert to net_device_ops
      mac80211: convert master interface to netdev_ops
      zd1211rw: do not ratelimit no-ops
      mac80211: disable IBSS beacon before join
      zd1211rw: honour enable_beacon conf
      mac80211: properly validate/translate IW_AUTH_MFP values
      mac80211: reject extra IEs for probe request when hw_scan
      mac80211: fix beacon enable more
      mac80211: remove bssid argument from prepare_for_handlers
      mac80211: remove stray aggregation debugfs definition
      mac80211: fix RX aggregation timeouts
      mac80211: restructure HT code
      mac80211: restrict aggregation to supported interface modes
      mac80211: hardware should not deny going back to legacy
      mac80211: document TX aggregation (and small cleanup)
      mac80211: fix race in TX aggregation
      mac80211: fix aggregation timer lockups
      mac80211: clean up BA session teardown
      mac80211: RX aggregation: clean up stop session
      mac80211: further cleanups to stopping BA sessions
      cfg80211/nl80211: scanning (and mac80211 update to use it)
      mac80211: dont add BSS when creating IBSS
      cfg80211: free_priv for BSS info
      cfg80211: allow users to request removing a BSS
      cfg80211: add more flexible BSS lookup
      mac80211: use cfg80211s BSS infrastructure
      mac80211: calculate wstats_flags on the fly
      mac80211: fix IBSS auth
      mac80211: split managed/ibss code a little more
      timer: implement lockdep deadlock detection
      mac80211: disallow moving netns
      mac80211: fix aggregation for hardware with ampdu queues
      mac80211: split IBSS/managed code
      cfg80211/mac80211: fill qual.qual value/adjust max_qual.qual
      mac80211: add missing kernel-doc
      nl80211: remove admin requirement from station get
      cfg80211: clean up signal type
      mac80211/cfg80211: move iwrange handler to cfg80211
      mac80211: Fix quality reporting for wireless stats
      mac80211: remove ieee80211_num_regular_queues
      mac80211: reduce max number of queues
      mac80211: fix warnings in ieee80211_if_config
      mac80211: stop queues across suspend/resume
      wireless: radiotap updates
      nl80211: export supported commands
      mac80211: acquire sta_lock for station suspend/resume
      ieee80211: document DS bit usage
      nl80211: rework locking
      mac80211: kill IEEE80211_CONF_SHORT_SLOT_TIME
      mac80211: resume properly, add suspend/resume test
      cfg80211: accept no-op interface mode changes
      mac80211: remove mixed-cell and userspace MLME code
      mac80211: rate control status only for controlled packets
      mac80211: fix RX path
      cfg80211: fix locking in nl80211_set_wiphy
      mac80211: rewrite fragmentation
      mac80211: fix A-MPDU queue assignment
      mac80211: rework the pending packets code
      mac80211: clean up __ieee80211_tx args
      mac80211: unify and fix TX aggregation start
      mac80211: add skb length sanity checking
      mac80211: fix aggregation to not require queue stop
      mac80211/iwlwifi: move virtual A-MDPU queue bookkeeping to iwlwifi
      toshiba-acpi: remove MAINTAINERS entry

Johannes Weiner (28):
      x86: optimise page fault entry, cleanup
      irq: use GFP_KERNEL for action allocation in request_irq()
      USB: use kzfree()
      [S390] use kzfree()
      vmscan: rename sc.may_swap to may_unmap
      vmscan: clip swap_cluster_max in shrink_all_memory()
      vmscan: respect higher order in zone_reclaim()
      mm: move pagevec stripping to save unlock-relock
      mm: don't free swap slots on page deactivation
      ramfs-nommu: use generic lru cache
      ecryptfs: use kzfree()
      dm crypt: use kzfree
      xtensa: remove redefinition of XCHAL_MMU_ASID_BITS
      xtensa: beat Kconfig into shape
      xtensa: use correct stack pointer for stack traces
      xtensa: fix init_bootmem_node() argument order
      xtensa: don't make bootmem bitmap larger than required
      xtensa: cope with ram beginning at higher addresses
      xtensa: nommu support
      xtensa: variant-specific code
      xtensa: variant irq set callbacks
      xtensa: s6000 variant core definitions
      xtensa: s6000 variant
      xtensa: let platform override KERNELOFFSET
      xtensa: platform: s6105
      xtensa: use generic sched_clock()
      xtensa: remove platform rtc hooks
      xtensa: ccount clocksource

John Daiker (4):
      b43: checkpatch.pl cleanups
      airo_cs: checkpatch.pl cleanups
      atmel: checkpatch.pl cleanups
      ray_cs: checkpatch.pl and Lindent cleanups

John Dykstra (1):
      tcp: Discard segments that ack data not yet sent

John Linn (1):
      powerpc/virtex/spi: Xilinx SPI driver not releasing memory

John Stultz (1):
      time: ntp: fix bug in ntp_update_offset() & do_adjtimex(), fix

John W. Linville (2):
      airo: correct improper initialization of local variable
      iwlagn: default to MAX_UCODE_BEACON_INTERVAL in iwl_adjust_beacon_i=
nterval

Jon Grierson (2):
      Staging: comedi: add adl_pci7296 driver
      Staging: comedi: add ni_65xx driver

Jonas Andersson (1):
      ASoC: wm8510 pll settings

Jonas Larsson (2):
      Add Merisc board support
      Add RTC support for Merisc boards

Jonathan Brassow (12):
      dm exception store: separate type from instance
      dm raid1: add is_remote_recovering hook for clusters
      dm exception store: introduce registry
      dm exception store: move dm_target pointer
      dm exception store: move chunk_fields
      dm exception store: move cow pointer
      dm snapshot: remove dm_snap header use
      dm snapshot: remove dm_snap header
      dm snapshot: use DMEMIT macro for status
      dm snapshot: move ctr parsing to exception store
      dm snapshot: move status to exception store
      dm snapshot: persistent fix dtr cleanup

Jonathan Cameron (1):
      Regulator: Push lock out of _notifier_call_chain + add voltage chan=
ge event.

Jonathan Corbet (5):
      Rename struct file->f_ep_lock
      Use f_lock to protect f_flags
      Move FASYNC bit handling to f_op->fasync()
      Rationalize fasync return values
      Fix a lockdep warning in fasync_helper()

Joonyoung Shim (1):
      ASoC: twl4030 - Fix build error

Jorg Schummer (1):
      mmc: delayed_work was never cancelled

Jose Alberto Reguero (1):
      V4L/DVB (10330): af9015: New remote RM-KS for Avermedia Volar-X

Josef 'Jeff' Sipek (1):
      xfs: cleanup error handling in xfs_swap_extents

Josef Bacik (4):
      Btrfs: free space cache cleanups
      Btrfs: clean up find_free_extent
      Btrfs: kill the block group alloc mutex
      Btrfs: kill the pinned_mutex

Josef Jiru (1):
      Staging: rt2870: add Linksys WUSB600N device id

Joseph Cihula (1):
      x86: disable stack-protector for __restore_processor_state()

Josh Boyer (2):
      powerpc: Sanitize stack pointer in signal handling code
      powerpc: Make LOWMEM_CAM_NUM depend on FSL_BOOKE

Josh Stone (1):
      net: Add dependent headers to trace/skb.h

Jos=C3=A9 Luis S=C3=A1nchez (2):
      Staging: comedi: add acl7225b driver
      Staging: comedi: add pcl730 driver

Jouni Hogander (3):
      [ARM] OMAP3: PM: Emu_pwrdm is switched off by hardware even when sd=
ti is in use
      [ARM] OMAP34XX: Add miscellaneous definitions related to 34xx
      USB: TWL: disable VUSB regulators when cable unplugged

Jouni Malinen (59):
      mac80211: 802.11w - STA flag for MFP
      mac80211: 802.11w - CCMP for management frames
      mac80211: 802.11w - Add BIP (AES-128-CMAC)
      mac80211: 802.11w - Use BIP (AES-128-CMAC)
      mac80211: 802.11w - WEXT parameter for setting mgmt cipher
      mac80211: 802.11w - WEXT configuration for IGTK
      mac80211: 802.11w - Configuration of MFP disabled/optional/required
      mac80211: 802.11w - SA Query processing
      mac80211: 802.11w - Do not force Action frames to disable encryptio=
n
      mac80211: 802.11w - Drop unprotected robust management frames if MF=
P is used
      mac80211: 802.11w - Implement Association Comeback processing
      mac80211: 802.11w - Optional software CCMP for management frames
      mac80211: 802.11w - Add driver capability flag for MFP
      ath9k: Fix set_key error codes
      ath9k: Setup MFP options for CCMP
      mac80211_hwsim: Report driver as MFP capable
      mac80211: Mark ieee80211_process_sa_query_req() static
      mac80211: Fix radiotap header it_present on big endian CPUs
      nl80211: Fix documentation errors
      ath9k: Use a defined value for pci_set_power_state()
      nl80211: New command for adding extra IE(s) into management frames
      mac80211: Fix drop-unencrypted for management frames
      mac80211: Fix MFP Association Comeback to use Timeout Interval IE
      nl80211: Optional IEs into scan request
      nl80211: Provide access to STA TX/RX packet counters
      ath9k: Unlock sc->mutex on error path
      nl80211: Avoid AP mode BUG_ON hang with invalid lock assert
      ath9k: Add module parameter to disable hardware crypto
      ath9k: Fix hw crypto configuration for TKIP in AP mode
      ath9k: Document keycache operations
      ath9k: Remove unused key xoring
      ath9k: Clean up setkey operations
      ath9k: Cleanup multiple VIF processing
      ath9k: Set BSSID mask based on configured interfaces
      ath9k: Add data structure for supporting virtual radio/wiphy operat=
ion
      ath9k: Add support for multiple secondary virtual wiphys
      ath9k: Configure RX filter for multi-BSSID broadcast
      ath9k: Virtual wiphy pause/unpause functionality
      ath9k: Add routines for switching between active virtual wiphys
      ath9k: Make start/stop operations aware of virtual wiphys
      ath9k: Register larger listen interval
      ath9k: Pause other virtual wiphys on channel change
      ath9k: Check virtual wiphy state on tx()
      ath9k: Add workaround to recover from failed channel changes
      ath9k: Special processing for channel changes during scan
      ath9k: Add a simple virtual wiphy scheduler
      ath9k: Add a debugfs interface for controlling virtual wiphys
      mac80211: Fix WMM ACM parsing and AC downgrade operation
      ath9k: Fix FIF_PROMISC_IN_BSS processing in station mode
      ath9k: Add support for multiple virtual AP interfaces
      mac80211: Fix a typo in assoc vs. reassoc check
      mac80211: Fix reassociation by not clearing previous BSSID
      nl80211: Event notifications for MLME events
      nl80211: Add MLME primitives to support external SME
      mac80211: Fix memleak in nl80211 authentication on deinit
      nl80211: Remove NL80211_CMD_SET_MGMT_EXTRA_IE
      nl80211: Add more through validation of MLME command parameters
      nl80211: Check that netif_runnin is true in cfg80211 code
      nl80211: Check iftype in cfg80211 code

Juan Grigera (1):
      Staging: comedi: add pcl816 driver

Juan Jes=C3=BAs Garc=C3=ADa de Soria Lucena (1):
      V4L/DVB (11328): Add AVerMedia A310 USB IDs to CE6230 driver.

Juha Yrjola (1):
      omap_hsmmc: Implement scatter-gather emulation

Julia Lawall (19):
      [SCSI] libfc: Correct use of ! and &
      PCI: introduce missing kfree
      USB: Move definitions from usb.h to usb/ch9.h
      USB: ub: use USB API functions rather than constants
      USB: Remove redundant test in pxa27x_udc and ftdi_sio
      USB: drivers: use USB API functions rather than constants
      drivers/watchdog: use USB API functions rather than constants
      Staging: agnx: Move a dereference below a NULL test
      Staging: go7007: Move a dereference below a NULL test
      Staging: go7007: introduce missing kfree
      Staging: meilhaus: Correct use of ! and &
      Staging: meilhaus: Use DEFINE_SPINLOCK
      Staging: rspiusb: use USB API functions rather than constants
      Staging: otus: use USB API functions rather than constants
      Staging: rt2860,rt2870: Correct use of ! and &
      Staging: comedi: Correct use of ! and &
      Staging: comedi: Use DEFINE_SPINLOCK
      Staging: comedi: introduce missing kfree
      Staging: comedi: Move a dereference below a NULL test

Jun'ichi Nomura (1):
      dm: path selector use module refcount directly

Justin Bronder (1):
      Staging: b3dfg: Prepare b3dfg for submission upstream.

KAMEZAWA Hiroyuki (10):
      vmscan: fix it to take care of nodemask
      cgroup: CSS ID support
      cgroup: fix frequent -EBUSY at rmdir
      memcg: use CSS ID
      memcg: hierarchical stat
      memcg: fix shrinking memory to return -EBUSY by fixing retry algori=
thm
      memcg: fix OOM killer under memcg
      cgroups: use css id in swap cgroup for saving memory v5
      memcg: remove redundant message at swapon
      /proc/pid/maps: don't show pgoff of pure ANON VMAs

KOSAKI Motohiro (16):
      sparseirq: make for_each_irq_desc() more robust
      tracing: current tip/master can't enable ftrace
      tracing: fix deadlock when setting set_ftrace_pid
      ftrace: fix documentation typo s/trace_max_latency/tracing_max_late=
ncy/
      ftrace: tracing header should put '#' at the beginning of a line
      tracing: Don't use tracing_record_cmdline() in workqueue tracer
      doc: add trace_buf_size description to kernel-parameters.txt
      tracing: Don't assume possible cpu list have continuous numbers
      x86, mce: use round_jiffies() instead round_jiffies_relative()
      tracing: Don't use tracing_record_cmdline() in workqueue tracer fix
      mm: introduce for_each_populated_zone() macro
      mm: don't call mark_page_accessed() in do_swap_page()
      mm: add comment why mark_page_accessed() would be better than pte_m=
kyoung() in follow_page()
      mm: remove pagevec_swap_free()
      memcg: remove mem_cgroup_calc_mapped_ratio()
      memcg: remove mem_cgroup_reclaim_imbalance() remnants

Kalle Valo (15):
      mac80211: make wake/stop_queue_by_reason() functions static
      mac80211: remove multicast check from check_tim()
      mac80211: use ps-poll when dynamic power save mode is disabled
      at76c50x-usb: add driver
      at76c50x-usb: add link to the TODO list
      at76c50x-usb: use dev_name() instead of struct device.bus_id
      mac80211: don't drop nullfunc frames during software scan
      mac80211: decrease execution of the associated timer
      mac80211: track beacons separately from the rx path activity
      mac80211: disable power save when scanning
      cfg80211: add feature to hold bss
      mac80211: add beacon filtering support
      Staging: at76_usb: mention mac80211 port in TODO file
      Staging: at76_usb: convert to use linux/ieee80211.h
      Staging: Add stlc45xx, wi-fi driver for stlc4550/4560

Karen Xie (5):
      [SCSI] cxgb3i: fix function descriptions
      [SCSI] cxgb3i: subscribe to error notification from cxgb3 driver
      [SCSI] cxgb3i: re-initialize ddp settings after chip reset
      [SCSI] cxgb3i: close all tcp connections upon chip reset
      [SCSI] cxgb3i: merge cxgb3i_ddp into cxgb3i module

Karsten Wiese (1):
      r8169: reset IntrStatus after chip reset

Kay Sievers (35):
      net: struct device - replace bus_id with dev_name(), dev_set_name()
      wimax: struct device - replace bus_id with dev_name(), dev_set_name=
()
      sh: struct device - replace bus_id with dev_name(), dev_set_name()
      PCI: struct device - replace bus_id with dev_name(), dev_set_name()
      mmc: struct device - replace bus_id with dev_name(), dev_set_name()
      edac: struct device - replace bus_id with dev_name(), dev_set_name(=
)
      spi: struct device - replace bus_id with dev_name(), dev_set_name()
      video: struct device - replace bus_id with dev_name(), dev_set_name=
()
      zorro: struct device - replace bus_id with dev_name(), dev_set_name=
()
      mmc: struct device - replace bus_id with dev_name(), dev_set_name()
      mtd: struct device - replace bus_id with dev_name(), dev_set_name()
      pci: struct device - replace bus_id with dev_name(), dev_set_name()
      rapidio: struct device - replace bus_id with dev_name(), dev_set_na=
me()
      s390: struct device - replace bus_id with dev_name(), dev_set_name(=
)
      serial: struct device - replace bus_id with dev_name(), dev_set_nam=
e()
      sh: struct device - replace bus_id with dev_name(), dev_set_name()
      tc: struct device - replace bus_id with dev_name(), dev_set_name()
      pcmcia: struct device - replace bus_id with dev_name(), dev_set_nam=
e()
      rtc: struct device - replace bus_id with dev_name(), dev_set_name()
      net: struct device - replace bus_id with dev_name(), dev_set_name()
      drm: struct device - replace bus_id with dev_name(), dev_set_name()
      v4l: struct device - replace bus_id with dev_name(), dev_set_name()
      amba: struct device - replace bus_id with dev_name(), dev_set_name(=
)
      dio: struct device - replace bus_id with dev_name(), dev_set_name()
      dma: struct device - replace bus_id with dev_name(), dev_set_name()
      eisa: struct device - replace bus_id with dev_name(), dev_set_name(=
)
      gpio: struct device - replace bus_id with dev_name(), dev_set_name(=
)
      mca: struct device - replace bus_id with dev_name(), dev_set_name()
      mfd: struct device - replace bus_id with dev_name(), dev_set_name()
      wimax: struct device - replace bus_id with dev_name(), dev_set_name=
()
      usb: struct device - replace bus_id with dev_name(), dev_set_name()
      driver core: get rid of struct device's bus_id string array
      vcs: hook sysfs devices into object lifetime instead of "binding"
      qeth: struct device - replace bus_id with dev_name(), dev_set_name(=
)
      [MTD] struct device - replace bus_id with dev_name(), dev_set_name(=
)

Kazuo Moriwaka (1):
      trivial: jbd header comment typo fix for JBD_PARANOID_IOFAIL

Ken Kawasaki (1):
      axnet_cs: fix phy_id detection for bogus Asix chip.

Kenji Kaneshige (15):
      PCI: pciehp: fix possible endless loop in pcie_isr
      PCI: pciehp: enable software notification on empty slots
      PCI: pciehp: make cmd_busy flag one bit
      PCI/ACPI: move _OSC code to pci_root.c
      PCI/ACPI: rename pci_osc_control_set()
      PCI/ACPI: fix wrong assumption in acpi_pci_get_bridge_handle
      PCI/ACPI: fix wrong assumption in acpi_find_root_bridge_handle
      PCI hotplug: fix wrong assumption in acpi_get_hp_params_from_firmwa=
re
      PCI hotplug: fix wrong assumption in acpi_get_hp_hw_control_from_fi=
rmware
      PCI: fix wrong assumption in pci_find_upstream_pcie_bridge
      PCI: fix wrong assumption in pci_read_bridge_bases
      PCI: fix wrong assumption in pci_get_interrupt_pin
      PCI: fix wrong assumption in pci_common_swizzle
      PCI: pci_is_root_bus helper
      PCI: fix kernel oops on bridge removal

Kentaro Takeda (8):
      Add in_execve flag into task_struct.
      Memory and pathname management functions.
      Common functions for TOMOYO Linux.
      File operation restriction part.
      Domain transition handler.
      LSM adapter functions.
      Kconfig and Makefile
      MAINTAINERS info

Kevin Cernekee (2):
      [MTD] driver model updates (part 2)
      [MTD] sysfs support should not depend on CONFIG_PROC_FS

Kevin Hilman (7):
      [ARM] OMAP2: Implement CPUfreq frequency table based on PRCM table
      ASoC: Fix DaVinci module unload error
      [MTD] [NAND] davinci: drop usage of cpu_is_* macro
      [WATCHDOG] davinci: convert to ioremap() + io[read|write]
      IDE: palm_bk3710: use ioremap instead of arch-specific IO_ADDRESS()
      memory_accessor: new interface for reading/writing persistent memor=
y
      memory_accessor: implement the new memory_accessor interface for I2=
C EEPROM

Kim Kyuwon (2):
      omap_hsmmc: Initialize hsmmc controller registers when resuming
      leds: add BD2802GU LED driver

Kirill A. Shutemov (1):
      struct linux_binprm: drop unused fields

Klaus Flittner (1):
      V4L/DVB (11290): Add Elgato EyeTV DTT to dibcom driver

Klaus-Dieter Wacker (3):
      Use kthread instead of kernel_thread
      lcs: invalid return codes from hard_start_xmit.
      qeth: unregister MAC addresses during recovery.

Koji Sato (8):
      nilfs2: disk format and userland interface
      nilfs2: integrated block mapping
      nilfs2: B-tree based block mapping
      nilfs2: direct block mapping
      nilfs2: disk address translator
      nilfs2: checkpoint file
      nilfs2: segment usage file
      nilfs2: ioctl operations

Kolekar, Abhijeet (15):
      iwl3945: Change IWLWIFI_VERSION constant name
      iwl3945: include iwl-core.h
      iwl3945: replace iwl_3945_cfg with iwl_cfg
      iwl3945: move structures from iwl-3945.h to iwl-dev.h
      iwl3945: remove duplicate structures from iwl-3945.h
      iwl3945: replace iwl3945_broadcast_addr with iwl_bcast_addr
      iwl3945: use iwl_mod_params for 3945
      iwl3945: cleanup and remove duplicate code
      iwl3945: add load ucode op
      iwl3945: add apm ops
      iwl3945: add set_pwr_src
      iwl3945: simplify iwl3945_pci_probe
      iwl3945: release resources before shutting down
      iwl3945: use iwl_get_hw_mode
      iwl3945: adding utils ops

Krishna Kumar (1):
      net: Optimize skb_tx_hash() by eliminating a comparison

Kristian H=C3=B8gsberg (3):
      drm: claim PCI device when running in modesetting mode.
      drm: Drop unused and broken dri_library_name sysfs attribute.
      drm/i915: Read the right SDVO register when detecting SVDO/HDMI.

Kristoffer Ericson (4):
      [ARM] 5375/1: PATCH - update jornada720.c to reflect driver additio=
ns
      fbdev: update s1d13xxxfb to differ between revisions and production=
 ids
      backlight: Add HP Jornada 700 series LCD driver
      backlight: Adds HP Jornada 700 series backlight driver

Kruchinin Daniil (1):
      Staging: comedi: add unioxx5 driver

Krzysztof Ha=C5=82asa (7):
      WAN: Generic HDLC now uses IFF_WAN_HDLC private flag.
      WAN: Allow hw HDLC drivers to override dev->get_stats.
      WAN: Convert generic HDLC drivers to netdev_ops.
      IXP4xx: workaround for PCI prefetch problems near 64 MB boundary.
      IXP4xx: add Ethernet and NPE support for IXP43x CPU.
      IXP4xx: cpu_is_ixp4*() now recognizes all IXP4xx processors.
      IXP4xx: PCI ixp4xx_scan_bus() is __devinit.

Krzysztof Helt (45):
      ALSA: wss-lib: move AD1845 frequency setting into wss-lib
      ALSA: sscape: fix incorrect timeout after microcode upload
      ALSA: wss-lib: remove "pops" before each played sound
      ALSA: cmi8330: add OPL3 support
      ALSA: sscape: use common MPU401 macros
      ALSA: do not create OPL3 timers if there is no OPL3 irq wired
      ALSA: ad1816a: enable hardware timer
      ALSA: Turtle Beach Multisound Classic/Pinnacle driver
      ALSA: sscape: update Kconfig description about SoundScape cards
      ALSA: gus: update debug messages
      ALSA: cmi8330: add MPU-401 support
      ALSA: ess1688: fix OPL3 port setting
      ALSA: msnd: add module description and license for the snd-msnd-lib
      ALSA: sscape: drop redundant fields from soundscape struct
      ALSA: cs4236: cs4232 and cs4236 driver merge to solve PnP BIOS dete=
ction
      sound: Remove documentation for OSS CS4232 driver
      ALSA: opl3sa2 fix irq releasing and short name of card
      cirrusfb: convert printks to dev_foo
      cirrusfb: fix Laguna chipset memory detection and clock setting
      cirrusfb: add Laguna additional overflow register
      cirrusfb: add mmio registers for Laguna chipsets
      cirrusfb: do not calculate line length twice
      cirrusfb: use 5-6-5 RGB for 16bpp mode
      cirrusfb: various improvements
      cirrusfb: Laguna chipset 8bpp fix
      cirrusfb: check_var improvements
      cirrusfb: various Laguna fixes
      cirrusfb: acceleration improvements
      cirrusfb: add imageblit function
      cirrusfb: fix error paths in cirrusfb_xxx_register()
      cirrusfb: GD5446 fixes
      cirrusfb: use 24bpp instead of 32bpp
      cirrusfb: fix clock doubling
      cirrusfb: add accelerator constant
      cirrusfb: set MCLK in one place
      cirrusfb: GD5434 (aka SD64) support fixed
      cirrusfb: fix threshold register mask for Laguna chips
      cirrusfb: fix interlaced modes
      fbdev: remove cyblafb driver
      fb: hide hardware cursor in graphics mode (Mach64)
      atyfb: speed up Mach64 cursor
      tridentfb: delete acceleration Kconfig option
      ALSA: opl3sa2: add ZV port control
      tdfxfb: move I2C functionality into the tdfxfb
      tdfxfb: make use of DDC information about connected monitor

Krzysztof Kosi=C5=84ski (1):
      tc1100-wmi: Fix state reporting

Kumar Gala (27):
      powerpc/fsl-booke: Cleanup init/exception setup to be runtime
      powerpc/fsl: Ensure PCI_QUIRKS are enabled for FSL_PCI
      powerpc/85xx: Fixed PCI IO region sizes in mpc8572ds*.dts
      powerpc/85xx: Added 36-bit physical device tree for mpc8572ds board
      powerpc/fsl-booke: Add new ISA 2.06 page sizes and MAS defines
      powerpc/book-3e: Introduce concept of Book-3e MMU
      powerpc/fsl-booke: Fix compile warning
      powerpc: Unify opcode definitions and support
      powerpc: Fix warnings from make headers_check
      powerpc: Add support for using doorbells for SMP IPI
      powerpc/fsl-booke: Add support for tlbilx instructions
      powerpc/85xx: Update smp support to handle doorbells and non-mpic i=
nit
      gianfar: pass the proper dev to DMA ops
      powerpc/pci: Default to dma_direct_ops for pci dma_ops
      powerpc: setup default archdata for {of_}platform via bus_register_=
notifier
      powerpc: expect all devices calling dma ops to have archdata set
      powerpc/mm: Remove unused register usage in SW TLB miss handling
      powerpc/mm: Used free register to save a few cycles in SW TLB miss =
handling
      powerpc/mm: e300c2/c3/c4 TLB errata workaround
      powerpc/83xx: Update ranges in gianfar node to match other dts
      powerpc/85xx: Use fsl,mpc85.. as prefix for memory ctrl & l2-cache =
nodes
      gianfar: Remove unused header
      ucc_geth: Remove unused header
      powerpc: Move SPEFSCR defines to common header
      powerpc/math-emu: Change types to work on ppc64
      Fix highmem PPC build failure
      powerpc: Add support for CoreInt delivery of interrupts on MPIC

Kuninori Morimoto (19):
      sh: Add support for SH7786 CPU subtype.
      sh: Urquell board support.
      sh: urquell: Add smc91x support and update defconfig accordingly.
      sh: Add OHCI USB support for SH7786
      V4L/DVB (10616): tw9910: color format check is added on set_fmt
      V4L/DVB (10666): ov772x: move configuration from start_capture() to=
 set_fmt()
      V4L/DVB (10667): ov772x: setting method to register is changed.
      V4L/DVB (10668): ov772x: bit mask operation fix on ov772x_mask_set.
      V4L/DVB (10669): ov772x: Add image flip support
      V4L/DVB (10670): tw9910: bit mask operation fix on tw9910_mask_set.
      V4L/DVB (10671): sh_mobile_ceu: SOCAM flags are not platform depend=
ent
      V4L/DVB (11028): ov772x: use soft sleep mode in stop_capture
      sh: Remove buggy definition from SH7786 pinmux_data[]
      sh: urquell: enable LAN device
      sh: Tidy up sh7786 pinmux table.
      sh: ap325rxa: Add ov772x support, again.
      sh: ap325 and Migo-R use new sh_mobile_ceu_info flags
      V4L/DVB (11324): ov772x: wrong pointer for soc_camera_link is modif=
ied
      V4L/DVB (11327): ov772x: add edge contrl support

Kusanagi Kouichi (1):
      ALSA: hda: Add digital beep generator support for Realtek codecs.

Kyle Guinn (3):
      V4L/DVB (10365): Add Mars-Semi MR97310A format
      V4L/DVB (10366): gspca - mr97310a: New subdriver.
      V4L/DVB (10369): gspca - mr97310a: Fix camera initialization copy/p=
aste bugs.

Kyle McMartin (7):
      debug_objects: add boot-parameter toggle to turn object debugging o=
ff again
      parisc: select BUG always
      Merge branch 'rusty-cpumask-parisc' into parisc
      parisc: fix build when ARCH_HAS_KMAP
      parisc: Move kernel Elf_Fdesc define to <asm/elf.h>
      parisc: move dereference_function_descriptor to process.c
      V4L/DVB (11318): fix misspelling of kconfig option

Kyungmin Park (1):
      [MTD] [OneNAND] Add write-while-program support

Lachlan McIlroy (6):
      [XFS] Update maintainers
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-=
2.6
      Merge branch 'for-linus' of git+ssh://git.melbourne.sgi.com/git/xfs
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-=
2.6
      Merge branch 'master' of git://git.kernel.org/pub/scm/fs/xfs/xfs

Lai Jiangshan (25):
      ring_buffer: reset write when reserve buffer fail
      ftrace: fix trace_output
      trace_workqueue: use percpu data for workqueue stat
      ring_buffer: fix typing mistake
      ring_buffer: fix ring_buffer_read_page()
      x86: use percpu data for 4k hardirq and softirq stacks
      sched: TIF_NEED_RESCHED -> need_reshed() cleanup
      vsprintf: add binary printf
      tracing: infrastructure for supporting binary record
      tracing: add trace_bprintk()
      ftrace: use seq_read
      ftrace: remove struct list_head from struct dyn_ftrace
      kallsyms, tracing: output more proper symbol name
      ftrace: protect running nmi (V3)
      ftrace: show virtual PID
      tracing: use union for multi-usages field
      trace_stat: don't call seq_printf() in seq_operation->start()
      trace_stat: keep original order
      trace_workqueues: fix empty line's output
      init,cpuset: fix initialize order
      rcu: rcu_barrier VS cpu_hotplug: Ensure callbacks in dead cpu are m=
igrated to online cpu
      tracing: move scripts/trace/power.pl to scripts/tracing/power.pl
      workqueue: avoid recursion in run_workqueue()
      cpu hotplug: remove unused cpuhotplug_mutex_lock()
      tracing: fix incorrect return type of ns2usecs()

Lalit Chandivade (4):
      [SCSI] qla2xxx: Correct ISP abort semantics for NVRAM, VPD, and fla=
sh update.
      [SCSI] qla2xxx: Add reset capabilities for application support.
      [SCSI] qla2xxx: Remove implicit ISP-abort after a flash update.
      [SCSI] qla2xxx: Export flash-block-size for application support.

Larry Finger (5):
      b43: Eliminate compilation warning in b43_op_set_key
      rtl8187: Fix locking of private data
      rtl8187: Increase receive queue depth
      rtl8187: Fix driver to return TX retry info for RTL8187L
      kaweth: Fix locking to be SMP-safe

Laurent Pinchart (9):
      cpm2: Round the baud-rate clock divider to the nearest integer.
      V4L/DVB (10293): uvcvideo: replace strn{cpy,cat} with strl{cpy,cat}.
      V4L/DVB (10294): uvcvideo: Add support for the Alcor Micro AU3820 c=
hipset.
      V4L/DVB (10295): uvcvideo: Retry URB buffers allocation when the sy=
stem is low on memory.
      V4L/DVB (10296): uvcvideo: Fix memory leak in input device handling
      V4L/DVB (10650): uvcvideo: Initialize streaming parameters with the=
 probe control value
      V4L/DVB (10651): uvcvideo: Ignore empty bulk URBs
      V4L/DVB (10652): uvcvideo: Add quirk to override wrong bandwidth va=
lue for Vimicro devices
      V4L/DVB (11292): uvcvideo: Add support for Syntek cameras found in =
JAOtech Smart Terminals

Laurent Vivier (3):
      m68k: Add install target
      m68k: mac - Add a new entry in mac_model to identify the floppy con=
troller type.
      m68k: mac - Add SWIM floppy support

Lauri Leukkunen (1):
      ARM OMAP3: Initial support for Nokia RX-51, v3

Lee Schermerhorn (1):
      mm: define a UNIQUE value for AS_UNEVICTABLE flag

Len Brown (27):
      ACPI: fix CONFIG_ACPI=3Dn build
      ACPI: simplify processor lines in Makefile
      ACPI: get_throttling_state() cannot be larger than state_count
      video: build fix
      Merge branch 'bjorn-initcall-cleanup' into release
      Merge branch 'bjorn-cleanups' into release
      Merge branch 'driver-ops-cleanup' into release
      Merge branch 'dynamic-ssdt' into release
      Merge branch 'pmtimer-overflow' into release
      Merge branch 'thermal' into release
      Merge branch 'hp-wmi' into release
      Merge branch 'battery' into release
      Merge branch 'psd' into release
      Merge branch 'video' into release
      Merge branch 'acer' into release
      Merge branch 'thinkpad-acpi' into release
      Merge branch 'sony-laptop' into release
      Merge branch 'acpi-modparam' into release
      Merge branch 'async-battery' into release
      Merge branch 'acpi_enforce_resources' into release
      Merge branches 'bugzilla-12461' and 'bugzilla-9998' into release
      Merge branch 'constify' into release
      Merge branch 'dell-wmi' into release
      Merge branch 'pnpacpi' into release
      Merge branch 'x2apic' into release
      Merge branch 'misc' into release
      Merge branch 'linus' into release

Len Sorensen (1):
      m68knommu: Fix support for console port other than ttyS0 on mcf.c

Lennert Buytenhek (19):
      mv643xx_eth: unify ethtool ops for phy'd and phy-less interfaces
      mv643xx_eth: rework interrupt coalescing, and export via ethtool
      mv643xx_eth: implement ethtool rx/tx ring size query and resizing
      mv643xx_eth: export rx csum get/set methods via ethtool
      mv643xx_eth: allow enabling/disabling tx checksumming via ethtool
      mv643xx_eth: implement Large Receive Offload
      [ARM] Kirkwood: enable both XOR engines on the 6281 RD board
      [ARM] mv78xx0: distinguish between different chip steppings
      [ARM] mv78xx0: force eth2/eth3 to PHYless mode on pre-A0 silicon
      [ARM] mv78xx0: enable eth2/eth3 on the mv78xx0 A0 development board
      mv643xx_eth: make LRO unconditional
      mv643xx_eth: convert to net_device_ops
      mv643xx_eth: move a couple of init actions from ->open() to port pr=
obe
      mv643xx_eth: set sane default receive coalescing timeout
      [ARM] mv78xx0: Add Marvell RD-78x00-mASA Reference Design support
      mwl8k: Marvell TOPDOG wireless driver
      dsa: set ->iflink on slave interfaces to the ifindex of the parent
      dsa: add support for the Marvell 88E6095/6095F switch chips
      dsa: add switch chip cascading support

Leubner, Achim (1):
      [SCSI] aacraid driver update

Li Peng (1):
      drm/i915: Fix LVDS dither setting

Li Xiaodong (1):
      documentation: fix unix_dgram_qlen description

Li Yang (2):
      gianfar: reallocate skb when headroom is not enough for fcb
      gianfar: only check headroom when FCB is needed

Li Zefan (37):
      tracing/ftrace: add missing unlock in register_stat_tracer()
      cpuacct: add a branch prediction
      cpuacct: reduce one NULL check in fast-path
      blktrace: fix possible memory leak
      blktrace: make blk_tracer_enabled a bool flag
      blktrace: remove blk_probe_mutex
      blktrace: don't increase blk_probes_ref if failed to setup blk trac=
e
      blktrace: report EBUSY correctly
      blktrace: remove sysfs_blk_trace_enable_show/store()
      blktrace: avoid accessing NULL bdev->bd_disk
      blktrace: mark ddir_act[] const
      blktrace: fix wrong calculation of RWBS
      blktrace: fix t_error()
      blktrace: print human-readable act_mask
      blktrace: fix timestamp in binary output
      blktrace: fix a race when creating blk_tree_root in debugfs
      blktrace: fix the original blktrace
      blktrace: fix off-by-one bug
      blktrace: make classic output more classic
      blktrace: fix blk_probes_ref chaos
      blktrace: fix memory leak when freeing struct blk_io_trace
      blktrace: extract duplidate code
      blktrace: print out BLK_TN_MESSAGE properly
      trace: make argument 'mem' of trace_seq_putmem() const
      memdup_user(): introduce
      cgroups: more documentation for remount and release_agent
      cgroups: show correct file mode
      cgroups: don't change release_agent when remount failed
      debug cgroup: remove unneeded cgroup_lock
      devcgroup: avoid using cgroup_lock
      cpuset: fix possible races in cpu/memory hotplug
      cgroups: add 'data' field to struct cgroup_scanner
      cpuset: rewrite update_tasks_nodemask()
      cpuset: avoid changing cpuset's mems when errno returned
      cpuset: remove struct cpuset_hotplug_scanner
      blktrace: small cleanup in blk_msg_write()
      blktrace: fix pdu_len when tracing packet command requests

Li, Shaohua (1):
      fastboot: remove duplicate unpack_to_rootfs()

Liam Girdwood (1):
      regulator: email - update email address and regulator webpage.

Lierdakil (1):
      V4L/DVB (10388): gspca - pac207: Webcam 093a:2474 added.

Lin Ming (3):
      ACPICA: Check for non-zero address before being converted to GAS
      ACPICA: Clear PM register write-only bits on reading
      ACPI: cpufreq: use new bit register access function

Linus Torvalds (153):
      Merge branch 'upstream' of git://ftp.linux-mips.org/pub/scm/upstrea=
m-linus
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jmorris/security-testing-2.6
      Merge branch 'next' of git://git.kernel.org/pub/scm/linux/kernel/gi=
t/davej/cpufreq
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/herbert/crypto-=
2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/hskinnemoen/avr=
32-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/steve/gfs2-2.6-=
nmw
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/lethal/sh-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/bart/ide-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-c=
ore-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/usb-2.6
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/jgarzik/libata-dev
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/sfrench/cifs-2.=
6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/roland/infiniband
      Merge branch 'kvm-updates/2.6.30' of git://git.kernel.org/pub/scm/v=
irt/kvm/kvm
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/wim/linux-2.6-w=
atchdog
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-=
2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-2.6
      Merge branch 'for-2.6.30' of git://git.kernel.dk/linux-2.6-block
      Merge branch 'for-linus' of git://git390.marist.edu/pub/scm/linux-2=
.6
      Merge branch 'sched-for-linus' of git://git.kernel.org/pub/scm/linu=
x/kernel/git/tip/linux-2.6-tip
      Merge branch 'timers-for-linus' of git://git.kernel.org/pub/scm/lin=
ux/kernel/git/tip/linux-2.6-tip
      Merge branch 'irq-for-linus' of git://git.kernel.org/pub/scm/linux/=
kernel/git/tip/linux-2.6-tip
      Merge branch 'header-fixes-for-linus' of git://git.kernel.org/pub/s=
cm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'bkl-removal' of git://git.lwn.net/linux-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/geert/linux-m68k
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/penberg/slab-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/teigland/dlm
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jack/linux-quota-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/viro/vfs-2.6
      Merge branch 'drm-intel-next' of git://git.kernel.org/pub/scm/linux=
/kernel/git/anholt/drm-intel
      i915: fix wrong 'size_t' format string
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/ieee1394/linux1394-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/jejb/scsi-misc-=
2.6
      Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel=
/git/aegl/linux-2.6
      Merge branch 'percpu-cpumask-x86-for-linus-2' of git://git.kernel.o=
rg/pub/scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/cooloney/blackfin-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/arjan/linux-2.6=
-async-for-30
      Merge branch 'devel' of master.kernel.org:/home/rmk/linux-2.6-arm
      Merge branch 'i2c-for-linus' of git://jdelvare.pck.nerim.net/jdelva=
re-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jmorris/security-testing-2.6
      Merge branch 'futexes-for-linus' of git://git.kernel.org/pub/scm/li=
nux/kernel/git/tip/linux-2.6-tip
      Merge branch 'bzip2-lzma-for-linus' of git://git.kernel.org/pub/scm=
/linux/kernel/git/x86/linux-2.6-tip
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/shaggy/jfs-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/bart/ide-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/mszeredi/fuse
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/mchehab/linux-2.6
      Merge branch 'next' of git://git.kernel.org/pub/scm/linux/kernel/gi=
t/benh/powerpc
      Merge branch 'upstream' of git://ftp.linux-mips.org/pub/scm/upstrea=
m-linus
      Merge branch 'bkl-removal' of git://git.lwn.net/linux-2.6
      Merge branch 'x86-stage-3-for-linus' of git://git.kernel.org/pub/sc=
m/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'reiserfs-updates' from Jeff Mahoney
      Merge branch 'iommu-for-linus' of git://git.kernel.org/pub/scm/linu=
x/kernel/git/tip/linux-2.6-tip
      Merge branch 'drm-next' of git://git.kernel.org/pub/scm/linux/kerne=
l/git/airlied/drm-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/rafael/suspend-2.6
      Merge branch 'proc-linus' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/adobriyan/proc
      Merge branch 'locking-for-linus' of git://git.kernel.org/pub/scm/li=
nux/kernel/git/tip/linux-2.6-tip
      Merge branch 'hwmon-for-linus' of git://jdelvare.pck.nerim.net/jdel=
vare-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/rusty/linux-2.6=
-lguest-and-virtio
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/rusty/linux-2.6=
-cpumask
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'for-linus' of git://git390.marist.edu/pub/scm/linux-2=
.6
      Merge branch 'linux-next' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/jbarnes/pci-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/bart/ide-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/mason/btrfs-uns=
table
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tytso/ext4
      Merge branch 'for-linus' of git://git.linux-nfs.org/projects/trondm=
y/nfs-2.6
      Merge branch 'x86/setup' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tip/linux-2.6-tip
      qeth: properly delete empty files.
      Merge branch 'x86-setup-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel=
/git/aegl/linux-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'drm-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/airlied/drm-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/viro/vfs-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/bart/linux-hdre=
g-h-cleanup
      Merge master.kernel.org:/home/rmk/linux-2.6-arm
      Merge branch 'for-linus' of git://neil.brown.name/md
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/gerg/m68knommu
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/herbert/crypto-=
2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/rcu-doc-2=
.6
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jack/linux-udf-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/kyle/rtc-parisc
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/kyle/parisc-2.6
      Merge branch 'for-linus' of git://oss.sgi.com/xfs/xfs
      Merge branch 'for-linus' of git://git.open-osd.org/linux-open-osd
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/agk/linux-2.6-d=
m
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-=
2.6-fscache
      Merge git://git.infradead.org/iommu-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/lrg/voltage-2.6
      Merge branch 'ext3-latency-fixes' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/tytso/ext4
      Merge branch 'next' of git://git.kernel.org/pub/scm/linux/kernel/gi=
t/djbw/async_tx
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/mfasheh/ocfs2
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/mason/btrfs-uns=
table
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/czankel/xtensa-=
2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jikos/trivial
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jikos/hid
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/mszeredi/fuse
      Merge branch 'locking-for-linus' of git://git.kernel.org/pub/scm/li=
nux/kernel/git/tip/linux-2.6-tip
      Merge branch 'ipi-for-linus' of git://git.kernel.org/pub/scm/linux/=
kernel/git/tip/linux-2.6-tip
      Merge branch 'rcu-for-linus' of git://git.kernel.org/pub/scm/linux/=
kernel/git/tip/linux-2.6-tip
      Merge branch 'stacktrace-for-linus' of git://git.kernel.org/pub/scm=
/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'core-cleanups-for-linus' of git://git.kernel.org/pub/=
scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Make non-compat preadv/pwritev use native register size
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/drzeus/mmc
      Merge branch 'printk-for-linus' of git://git.kernel.org/pub/scm/lin=
ux/kernel/git/tip/linux-2.6-tip
      Merge branch 'core/debugobjects' of git://git.kernel.org/pub/scm/li=
nux/kernel/git/tip/linux-2.6-tip
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/rusty/linux-2.6=
-module-and-param
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/rusty/linux-2.6=
-cpumask
      Merge branch 'bzip2-lzma-for-linus' of git://git.kernel.org/pub/scm=
/linux/kernel/git/x86/linux-2.6-tip
      Merge branch 'tracing-for-linus' of git://git.kernel.org/pub/scm/li=
nux/kernel/git/tip/linux-2.6-tip
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging-=
2.6
      Merge branch 'avr32-arch' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/hskinnemoen/avr32-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/lethal/sh-2.6
      Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel=
/git/lenb/linux-acpi-2.6
      Merge branch 'for-linus' of git://repo.or.cz/cris-mirror
      Merge branch 'for-next' of git://git.o-hand.com/linux-mfd
      Merge branch 'audit.b62' of git://git.kernel.org/pub/scm/linux/kern=
el/git/viro/audit-current
      Merge branch 'for-linus' of git://git.o-hand.com/linux-rpurdie-leds
      Merge branch 'for-linus' of git://git.o-hand.com/linux-rpurdie-back=
light
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/jejb/scsi-misc-=
2.6
      Merge branch 'i2c-for-linus' of git://jdelvare.pck.nerim.net/jdelva=
re-2.6
      Merge branch 'for-2.6.30' of git://linux-nfs.org/~bfields/linux
      Merge branch 'kmemtrace-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'locking-for-linus' of git://git.kernel.org/pub/scm/li=
nux/kernel/git/tip/linux-2.6-tip
      kernel/sysctl.c: avoid annoying warnings
      Merge branch 'for-linus' of git://neil.brown.name/md
      Merge git://git.infradead.org/iommu-2.6
      Merge git://git.infradead.org/mtd-2.6
      Merge branch 'linux-next' of git://git.infradead.org/ubi-2.6
      Merge branch 'linux-next' of git://git.infradead.org/ubifs-2.6
      ext3: make default data ordering mode configurable
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/mchehab/linux-2.6
      Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/paulus/powerpc
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/rusty/linux-2.6=
-module-and-param
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jmorris/security-testing-2.6
      branch tracer, intel-iommu: fix build with CONFIG_BRANCH_TRACER=3Dy
      Merge branch 'hwmon-for-linus' of git://jdelvare.pck.nerim.net/jdel=
vare-2.6
      Merge branch 'i2c-for-2630-v2' of git://aeryn.fluff.org.uk/bjdooks/=
linux
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/jgarzik/libata-dev
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge branch 'for-2.6.30' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/broonie/sound-2.6
      Fix build errors due to CONFIG_BRANCH_TRACER=3Dy
      Merge branch 'for-linus' of git://git.kernel.dk/linux-2.6-block
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jbarnes/pci-2.6
      Merge branch 'irq/threaded' of git://git.kernel.org/pub/scm/linux/k=
ernel/git/tip/linux-2.6-tip
      Merge branch 'tracing-fixes-for-linus' of git://git.kernel.org/pub/=
scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'core/softlockup' of git://git.kernel.org/pub/scm/linu=
x/kernel/git/tip/linux-2.6-tip
      Linux 2.6.30-rc1

Linus Walleij (1):
      [ARM] 5420/1: MMCI devinit and devexit macros

Lior Dotan (5):
      Staging: slicoss: use request_firmware
      Staging: SLICOSS: remove the static firmware header files
      Staging: slicoss: add binary firmware to firmware directory
      Staging: SLICOSS: free resources on entry_probe error path
      Staging: SLICOSS: use gfp_kernel where possible

Liu Yu (7):
      powerpc/math-emu: Fix efp dependence
      powerpc/fsl-booke: declare tlbcam_index for use in c
      KVM: ppc: Fix e500 warnings and some spelling problems
      KVM: ppc: Move to new TLB invalidate interface
      KVM: ppc: Add emulation of E500 register mmucsr0
      KVM: ppc: e500: Fix the bug that mas0 update to wrong value when re=
ad TLB entry
      KVM: ppc: e500: Fix the bug that KVM is unstable in SMP

Lopez Cruz, Misael (5):
      ASoC: Add GPIO support for jack reporting interface
      ASoC: Add DAPM machine widgets to SDP3430 driver
      ASoC: Add headset jack detection for SDP3430 machine driver
      ASoC: Move headset jack registration to device initialization for S=
DP3430
      ASoC: Declare Headset as Mic and Headphone widgets for SDP3430

Lorenzo Nava (1):
      b43: fix b43_plcp_get_bitrate_idx_ofdm return type

Luca Cappa (1):
      hp_accel: axis conversion for hp compaq 8710w

Luca Tettamanti (2):
      ACPI: acpi_enforce_resource=3Dstrict by default
      hwmon: Add Asus ATK0110 support

Lucas Nussbaum (1):
      sctp: Allow to disable SCTP checksums via module parameter

Luck, Tony (1):
      ia64: fix section mismatch swiotlb_dma_init -> swiotlb_init

Luis Henriques (4):
      sched: fix typos in documentation
      sched: small optimisation of can_migrate_task()
      sched: jiffies not printed per CPU
      sched: remove unused fields from struct rq

Luis R. Rodriguez (81):
      mac80211: add HT conf helpers
      ath9k: use hw->conf on ath_setcurmode()
      ath9k: remove cache of rate preference when using 11g protection
      ath9k: Rename ath_setcurmode() to ath_cache_conf_rate()
      ath9k: consolidate arguments on hw reset
      ath9k: make request to get the noisefloor threshold band specific
      ath9k: use ieee80211_conf on ath9k_hw_iscal_supported()
      ath9k: make use of conf_is_ht*() in the rest of the driver
      iwlwifi: make use of conf_is_ht*() helpers
      mac80211: no need for ht.enabled
      ath9k: Make ANI CCK and OFDM error triggers band specific
      ath9k: remove mode specific default noise floor values
      ath9k: remove ath9k_hw_chan2wmode()
      ath9k: remove ath9k_hw_check_chan()
      ath9k: remove superfluous check on changing channel
      ath9k: fix sparse warnings
      cfg80211: call reg_notifier() once
      cfg80211: allow multiple driver regulatory_hints()
      cfg80211: fix typo on message after intersection
      cfg80211: add wiphy_apply_custom_regulatory()
      cfg80211: export freq_reg_info()
      cfg80211: process user requests only after previous user/driver/cor=
e requests
      cfg80211: ignore consecutive equal regulatory hints
      cfg80211: rename fw_handles_regulatory to custom_regulatory
      cfg80211: move check for ignore_reg_update() on wiphy_update_regula=
tory()
      cfg80211: pass more detailed regulatory request information on reg_=
notifier()
      cfg80211: Allow for strict regulatory settings
      mac80211: allow mac80211 drivers to get to struct ieee80211_hw from=
 wiphy
      cfg80211: allow users to help a driver's compliance
      ath9k: simplify regulatory code
      ath9k: fix debug print on regd
      ath9k: remove useless ath9k driver version information
      cfg80211: do not pass -EALREADY to userspace on regdomain change re=
quest
      ath9k: replace usage of internal wireless_modes for conf
      ath9k: move check for radar freqs into a helper
      ath9k: remove passive scan on 5 GHz if country IE knows better
      mac80211: do not TX injected frames when not allowed
      cfg80211: add get reg command
      ath9k: fix reg_notifier() flags used upon a country IE
      ath9k: add comments for ath9k_hw_configpcipowersave()
      ath9k: add udelay() for AR5416 on ath9k_hw_configpcipowersave()
      cfg80211: rename cfg80211_registered_device's idx to wiphy_idx
      cfg80211: add wiphy_idx_valid to check for wiphy_idx sanity
      cfg80211: rename cfg80211_drv_mutex to cfg80211_mutex
      nl80211: disallow user requests prior to regulatory_init()
      cfg80211: add regulatory_hint_core() to separate the core reg hint
      cfg80211: propagate -ENOMEM during regulatory_init()
      cfg80211: add assert_cfg80211_lock() to ensure proper protection
      cfg80211: make regulatory_request use wiphy_idx instead of wiphy
      cfg80211: protect first access of last_request on 11d hint under mu=
tex
      cfg80211: remove likely from an 11d hint case
      cfg80211: free rd on unlikely event on 11d hint
      cfg80211: move all regulatory hints to workqueue
      cfg80211: comments style cleanup
      cfg80211: allow drivers that agree on regulatory to agree
      cfg80211: rename regdom_changed to regdom_changes() and use it
      cfg80211: enable active-scan / beaconing on Ch 1-11 for world regdo=
m
      cfg80211: enable 5 GHz world roaming channels
      cfg80211: Add AP beacon regulatory hints
      ath9k: follow beacon hints on reg_notifier when world roaming
      cfg80211: make __regulatory_hint() static
      cfg80211: pass the regulatory_request struct in __regulatory_hint()
      cfg80211: do not kzalloc() again for a new request on __regulatory_=
hint
      cfg80211: pass the regulatory_request to ignore_request
      mac80211_hwsim: add support for 5 GHz
      cfg80211: Enable passive scan on channels 12-14 for world roaming
      cfg80211: fix max tx power for world regdom on 5 GHz to 20dBm
      cfg80211: remove REGDOM_SET_BY_INIT
      cfg80211: move enum reg_set_by to nl80211.h
      cfg80211: add regulatory netlink multicast group
      mac80211_hwsim: add regulatory testing options
      ath9k: downgrade xmit queue full message to xmit debug
      ath9k: make few eeprom and calib items static
      ath9k: remove dummy PCI "retry timeout" fix
      mac80211_hwsim: let the reg workqueue breathe when regtest is set
      cfg80211: force last_request to be set for OLD_REG if regdom is EU
      cfg80211: fix incorrect assumption on last_request for 11d
      cfg80211: make regdom module parameter available oustide of OLD_REG
      cfg80211: remove code about country IE support with OLD_REG
      ath9k: fix dma mapping leak of rx buffer upon rmmod
      cfg80211: default CONFIG_WIRELESS_OLD_REGULATORY to n

Lukas Karas (1):
      V4L/DVB (11408): gspca - m5602-s5k83a: Add led support to the s5k83=
a sensor.

Luotao Fu (2):
      pxa2xx-ac97: fix displaying GSR after reset timeout
      leds: simple driver for pwm driven LEDs

Ma Ling (5):
      drm/i915: Use documented PLL timing limits for G4X platform
      drm/i915: Use a different PLL timing search function on G4X.
      drm: read EDID extensions from monitor
      drm: detect hdmi monitor by hdmi identifier (v3)
      drm/i915: avoid hanging on to a stale pointer to raw_edid.

Maciej Cencora (1):
      drm/radeon: add regs required for occlusion queries support

Maciej Grela (1):
      USB: usb-storage: added missing MODULE_LICENSE("GPL") for usb-stora=
ge ums-* modules

Maciej Rutecki (1):
      ahci: Blacklist HP Compaq 6720s that spins off disks during ACPI po=
wer off

Maciej Sosnowski (1):
      igb: switch to new dca API

Madhulika Madishetty (1):
      AMCC PPC 460SX redwood SoC platform initial framework

Maen Suleiman (1):
      mmc: SDIO driver for Marvell SoCs

Magnus Damm (52):
      clockevents: let set_mode() setup delta information
      smc91x: struct net_device_ops
      sh: make gpio_get/set_value() O(1)
      sh: lockless gpio_get_value()
      sh: lockless gpio_set_value()
      sh: use gpiolib
      sh: rework clocksource and sched_clock
      sh: tmu disable support
      sh: fix no sys_timer case
      sh: CMT clockevent platform driver
      sh: CMT platform data for sh7723/sh7722/sh7366/sh7343
      sh: shared register saving code for sh3/sh4/sh4a
      sh: rework register restore code for sh3/sh4/sh4a
      sh: remove EXPEVT vector from stack on sh3/sh4/sh4a
      sh: prefetch early exception data on sh4/sh4a.
      serial: sh-sci: console drainage
      rtc: sh-rtc: Add Single IRQ Support
      sh: fix P4 iounmap() pass-through
      sh: multiple vectors per irq - base
      sh: multiple vectors per irq - sh7750
      sh: multiple vectors per irq - sh7780
      sh: multiple vectors per irq - sh7785
      sh: hibernation support
      sh: Show sleep state with Migo-R LEDs
      input: add suspend wakeup support to sh_keysc
      input: sh_keysc suspend can use to_platform_device()
      sh: improve sh7785lcr power off code
      irq: add remove_irq() for freeing of setup_irq() irqs
      irq: match remove_irq() args with setup_irq()
      irq: export remove_irq() and setup_irq() symbols
      sh: SuperH Mobile suspend support
      sh: add ap325 lcd power off support
      video: sh_mobile_lcdcfb suspend/resume support
      sh: simplify kexec vbr code
      sh: rework kexec segment code
      sh: add kexec jump support
      sh: disallow kexec virtual entry
      sh: sh-rtc carry interrupt rework
      sh: sh-rtc invalid time rework
      sh: sh-rtc wakeup support
      tmio_mmc: Fix one off, use resource_size() in probe()
      tmio_mmc: Fix use after free in remove()
      V4L/DVB (10304): buf-dma-contig: fix USERPTR free handling
      V4L/DVB (11029): video: use videobuf_waiton() in sh_mobile_ceu free=
_buffer()
      pm: rework includes, remove arch ifdefs
      pm: cleanup includes
      clocksource: sh_cmt: use remove_irq() and remove clockevent workaro=
und
      sh: intc: install enable, disable and shutdown callbacks
      sh: intc: set_irq_wake() support
      input: sh_keysc: use enable/disable_irq_wake()
      rtc: rtc-sh: use set_irq_wake()
      input: migor_ts: add wakeup support

Malcolm Parsons (1):
      xfs: fix various typos

Mallikarjuna R Chilakala (2):
      ixgbe: Patch to fix driver panic while freeing up tx & rx resources
      ixgbe: Fix potential memory leak/driver panic issue while setting u=
p Tx & Rx ring parameters

Mandeep Singh Baines (7):
      softlockup: decouple hung tasks check from softlockup detection
      softlockup: fix to allow compiling with !DETECT_HUNG_TASK
      softlockup: fix potential race in hung_task when resetting timeout
      softlockup: remove unused definition for spawn_softlockup_task
      softlockup: check all tasks in hung_task
      softlockup: convert read_lock in hung_task to rcu_read_lock
      softlockup: remove timestamp checking from hung_task

Manish Katiyar (2):
      nfsd : Define NFSD only when FILE_LOCKING is enabled
      ext2: Zero our b_size in ext2_quota_read()

Mans Rullgard (1):
      NSM: Fix unaligned accesses in nsm_init_private()

Manuel Lauss (4):
      MIPS: Alchemy: unify CPU model constants.
      MIPS: Alchemy: provide cpu feature overrides.
      MIPS: Alchemy: MIPS hazard workarounds are not required.
      MIPS: Alchemy: PB1200: use SMC91X platform data.

Marc Eshel (5):
      nfsd41: define nfs41 error codes
      nfsd41: introduce nfs4_client cl_sessions list
      nfsd41: release_session when client is expired
      nfsd41: sessionid hashing
      nfsd41: provide support for minor version 1 at rpc level

Marc Schneider (1):
      V4L/DVB (11338): af9015: add support for TrekStor DVB-T USB Stick

Marcel Holtmann (31):
      Bluetooth: Preparation for usage of SOL_BLUETOOTH
      Bluetooth: Add global deferred socket parameter
      Bluetooth: Add support for deferring RFCOMM connection setup
      Bluetooth: Add support for deferring L2CAP connection setup
      Bluetooth: Reject incoming SCO connections without listeners
      Bluetooth: Fix SCO state handling for incoming connections
      Bluetooth: Add enhanced security model for Simple Pairing
      Bluetooth: Replace L2CAP link mode with security level
      Bluetooth: Replace RFCOMM link mode with security level
      Bluetooth: Pause RFCOMM TX when encryption drops
      Bluetooth: Disconnect L2CAP connections without encryption
      Bluetooth: Restrict application of socket options
      Bluetooth: Update version numbers
      Bluetooth: Submit bulk URBs along with interrupt URBs
      Bluetooth: Don't check encryption for L2CAP raw sockets
      Bluetooth: Add SCO fallback for eSCO connection attempts
      Bluetooth: Use general bonding whenever possible
      Bluetooth: Set authentication requirements if not available
      Bluetooth: Fix race condition with L2CAP information request
      Bluetooth: Fix double L2CAP connection request
      Bluetooth: Don't enforce authentication for L2CAP PSM 1 and 3
      Bluetooth: Request L2CAP fixed channel list if available
      Bluetooth: Add CID field to L2CAP socket address structure
      Bluetooth: Ask upper layers for HCI disconnect reason
      Bluetooth: Fix authentication requirements for L2CAP security check
      Bluetooth: Set authentication requirement before requesting it
      Bluetooth: Fix poll() misbehavior when using BT_DEFER_SETUP
      Bluetooth: Change RFCOMM to use BT_CONNECT2 for BT_DEFER_SETUP
      Bluetooth: Disallow usage of L2CAP CID setting for now
      Bluetooth: Fix RFCOMM usage of in-kernel L2CAP sockets
      Bluetooth: Permit BT_SECURITY also for L2CAP raw sockets

Marcelo Tosatti (4):
      KVM: VMX: initialize TSC offset relative to vm creation time
      KVM: PIT: provide an option to disable interrupt reinjection
      KVM: MMU: drop zeroing on mmu_memory_cache_alloc
      KVM: make irq ack notifications aware of routing table

Marcin Obara (1):
      Staging: add heci driver

Marcin Slusarz (6):
      phylib: convert state_queue work to delayed_work
      udf: reduce stack usage of udf_load_pvoldesc
      udf: reduce stack usage of udf_get_filename
      udf: implement mode and dmode mounting options
      udf: fix default mode and dmode options handling
      [MTD] fix use after free in register_mtd_blktrans

Marco Aurelio da Costa (1):
      i2c-algo-pca: Add PCA9665 support

Marek Vasut (3):
      [ARM] pxa: PalmT5 initial support
      [ARM] pxa: PalmLD initial support
      [ARM] pxa: fix the bad assumption that PCMCIA sockets always start =
with 0

Mario Schwalbe (2):
      backlight: Add support for MacBook 5, MacBook Air 2, and MacBook Pr=
o 5
      backlight: mbp_nvidia_bl - Add a debug switch

Mariusz Kozlowski (12):
      Staging: comedi: usbduxfast: remove kernel version checks
      Staging: comedi: usbduxfast: add comedi debug to Kconfig
      Staging: comedi: usbduxfast: fix checkpatch issues plus some style =
cleanups etc.
      Staging: comedi: usbduxfast: annotate __init and __exit functions
      Staging: comedi: usbduxfast: remove .bss variable initialization
      Staging: comedi: usbduxfast: don't initialize semaphores on init
      Staging: comedi: usbduxfast: balance semaphores up/down in attach e=
rror path
      Staging: comedi: usbdux: remove .bss variable initialization
      Staging: comedi: usbdux: don't initialize semaphores on init
      Staging: comedi: usbdux: annotate __init and __exit functions
      Staging: comedi: remove LINUX_VERSION_CODE checks
      Staging: comedi: remove unnecessary #include <linux/version.h>

Mark Brown (104):
      ALSA: Reduce boilerplate for new jack types
      ASoC: Constify pin names for DAPM pin status APIs
      ASoC: Add jack reporting interface
      ASoC: Implement WM8350 headphone jack detection
      Merge branch 'for-2.6.29' into for-2.6.30
      Merge branch 'for-2.6.29' into for-2.6.30
      ASoC: Ignore output frequency for WM9713 PLL
      ASoC: Implement support for CLK_POUT as MCLK on Zylonite
      ASoC: Staticise PCM operations tables
      Merge branch 'for-2.6.29' into for-2.6.30
      ASoC: Fix merge with PXA tree
      ASoC: Remove unneeded e7x0 inclusion of pxa-regs.h and hardware.h
      ASoC: Configure SSP port PLL for Zylonite
      ASoC: Fix spurious codec driver dependencies
      Merge branch 'for-2.6.29' into for-2.6.30
      ASoC: Include header file in cs4270 and wm9705
      ASoC: Fix L3 bus handling in Kconfig
      ASoC: Push the codec runtime storage into the card structure
      Merge branch 'for-2.6.29' into for-2.6.30
      Merge branch 'for-2.6.29' into for-2.6.30
      Merge branch 'for-2.6.29' into for-2.6.30
      Merge branch 'for-2.6.29' into for-2.6.30
      Merge branch 'for-2.6.29' into for-2.6.30
      ASoC: Remove version display from the WM8731 driver
      ASoC: Clean up WM8731 bias level configuration
      ASoC: Improve diagnostics for AT91SAM9G20-EK probe
      ASoC: Check machine type before loading on AT91SAM9G20-EK
      ASoC: Actively manage MCLK for AT91SAM9G20-EK
      ASoC: Rename AT91SAMG20-EK for applications
      ASoC: Shuffle WM8731 SPI and I2C device registration
      ASoC: Refactor WM8731 device registration
      ASoC: Remove version display from the WM8753 driver
      ASoC: Fix build for corgi and poodle
      ASoC: Implement SPI device unregistration for WM8731
      ASoC: Check for errors when writing WM8731 reset register
      ASoC: Add device init/exit annotations to new-style Wolfson CODEC d=
rivers
      ASoC: Disable WM8731 line bypass by default
      [ARM] 5399/1: [AT91] Configure MCLK and SSC for AT91SAMG20-EK
      ASoC: Report I/O errors from WM8753 reset
      ASoC: Only unregister drivers we registered for WM8753
      ASoC: Improve WM9713 voice DAC shutdown procedure
      ASoC: Fix Zylonite voice interface stereo configurations
      ASoC: Shuffle WM8753 device registration code
      ASoC: Convert WM8753 to register via normal device probe
      ASoC: Only write back non-default registers when resuming WM8753
      ASoC: Add SND_SOC_DAPM_PIN_SWITCH controls for exposing DAPM pins
      Merge commit 's3c-iis-header' into HEAD
      ASoC: Refresh JIVE driver
      ASoC: Factor out DAPM widget power check into separate function
      ASoC: Fix memory allocation for snd_soc_dapm_switch names
      ASoC: Update Kconfig for Samsung CPUs to reflect S3C64xx support
      ASoC: Staticise workqueue function for GPIO jack detection
      ASoC: Re-remove hand-rolled pr_debug() macros
      ASoC: Fix logging severity for some S3C error messages
      ASoC: Remove unneeded forward reference to WM8753 SPI implementatio=
n
      ASoC: Convert PXA AC97 driver to probe with the platform device
      Merge commit 'takashi/topic/asoc' into for-2.6.30
      ASoC: Fix up merge with the ARM tree
      [ARM] Revert extraneous changes from the S3C audio header move
      Merge branch 's3c-iis-header' into for-2.6.30
      ASoC: Add initial driver for the WM8400 CODEC
      ASoC: Remove version display from WM8580 driver
      ASoC: Fix formats for s3c24xx-i2s register prints
      ASoC: Merge dai_ops factor out
      [ARM] Revert futher extraneous changes from the S3C header move
      Merge branch 's3c-iis-header' into for-2.6.30
      ASoC: Move WM8580 to normal I2C device probe
      mx31: Add device definitions for the i.MX3x I2C controllers
      mx31ads: Fix build for missing mx31.h
      mx31ads: Make unexported data static
      mx31ads: Initial support for Wolfson Microelectronics 1133-EV1 modu=
le
      ASoC: Fix non-networked I2S mode for PXA SSP
      ASoC: Fix Zylonite for non-networked SSP mode
      ASoC: Fix some missing dai_ops conversions
      ASoC: Each PXA AC97 DAI needs a separate ops
      Merge branch 'pxa-ssp' into for-2.6.30
      ASoC: Further optimise WM8400 bias configuration sequence
      ASoC: Add separate AVDD for WM8400
      ASoC: Add FLL support for WM8400
      regulator: Pass regulator init data as explict argument when regist=
ering
      regulator: Allow init data to be supplied for bq24022
      regulator: Allow init_data to be passed to fixed voltage regulators
      regulator: Make fixed voltage regulators visible in Kconfig
      regulator: Mark attributes table for virtual regulator static
      regulator: Hoist struct regulator_dev out of core to fix notifiers
      regulator: Suggest use of datasheet supply or pin names for consume=
rs
      regulator: Allow regulators to set the initial operating mode
      regulator: Fix get_mode() for WM835x DCDCs
      regulator: Implement list_voltage() for WM8400 DCDCs and LDOs
      regulator: Don't warn on omitted voltage constraints
      regulator: Implement list_voltage for WM835x LDOs and DCDCs
      regulator: Allow boot_on regulators to be disabled by clients
      regulator: Don't warn if we failed to get a regulator
      regulator: Don't increment use_count for boot_on regulators
      regulator: Support disabling of unused regulators by machines
      rtc: convert wm8350 use new alarm and update operations
      ASoC: Add some documentation for the ASoC jack API
      ASoC: Don't defer resume work for AC97 codecs
      ASoC: Set parent for AC97 devices we register
      ASoC: Implement suspend and resume operations for WM9705
      mfd: Use bulk read to fill WM8350 register cache
      mfd: Support active high IRQs on WM835x
      mfd: Use the value of the final spin when reading the AUXADC
      i2c: i2c-s3c2410: Initialise Samsung I2C controller early

Mark Einon (2):
      Staging: rt2860: Fix remaining build warnings
      Staging: rt2860: Remove dependency on CFLAG RT2860

Mark Ellis (1):
      USB: ipaq: handle 4 endpoint devices

Mark Fasheh (9):
      ocfs2: Introduce dir lookup helper struct
      ocfs2: Add a name indexed b-tree to directory inodes
      ocfs2: Store dir index records inline
      ocfs2: Introduce dir free space list
      ocfs2: Increase max links count
      ocfs2: Add total entry count to dx_root_block
      ocfs2: Enable indexed directories
      ocfs2: re-order ocfs2_empty_dir checks
      ocfs2: fix leaf start calculation in ocfs2_dx_dir_rebalance()

Mark H. Weaver (1):
      netfilter: nf_conntrack_tcp: fix unaligned memory access in tcp_sac=
k

Mark Hills (5):
      ALSA: snd-usb-caiaq: Send the correct command when setting controls
      ALSA: snd-usb-caiaq: Set default input mode of A4DJ
      ALSA: snd-usb-caiaq: Do not expose hardware input mode 0 of A4DJ
      ALSA: snd-usb-caiaq: Remove duplicate A8DJ control
      ALSA: snd-usb-caiaq: Increase version number to 1.3.12

Mark Lord (27):
      sata_mv: cleanup chipset GENeration FLAGS
      sata_mv: rearrange mv_start_dma() and friends
      sata_mv: restructure mv_qc_issue
      sata_mv: update ata_qc_from_tag
      sata_mv: mv_fill_sg fixes v2
      sata_mv: introduce support for ATAPI devices
      sata_mv: optimize use of mv_edma_cfg
      sata_mv: remove leftovers
      [libata] sata_mv: cache frequently-accessed registers
      [libata] sata_mv: Enable use of (basic) DMA for ATAPI on GEN_IIE ch=
ips
      [libata] sata_mv: Tighten up interrupt masking in mv_qc_issue()
      [libata] sata_mv: Add a new mv_sff_check_status() function to sata_=
mv.
      [libata] Export ata_pio_queue_task() so that it can be used from sa=
ta_mv.
      [libata] sata_mv: Implement direct FIS transmission via mv_qc_issue=
_fis().
      sata_mv: cosmetic preparations for IRQ coalescing
      sata_mv: implement IRQ coalescing (v2)
      sata_mv: optimize IRQ coalescing for 8-port chips
      sata_mv: fix LED blinking for SoC+NCQ
      [libata] More robust parsing for IDENTIFY DEVICE multi_count field
      sata_mv: revert SoC irq breakage
      sata_mv: fix irq mask races
      sata_mv: replace 0x1f with ATA_PIO4 (v2)
      sata_mv: workaround errata PCI#7
      sata_mv: workaround errata SATA#26
      sata_mv: cosmetic renames
      sata_mv: workaround errata SATA#13
      sata_mv: shorten register names

Mark McLoughlin (1):
      virtio_net: add link status handling

Mark Nelson (1):
      powerpc/wdrtas: Update wdrtas_get_interval to use rtas_data_buf

Mark Vels (1):
      trivial: PWM: fix of #endif comment

Markus Bollinger (1):
      ALSA: pcxhr - add support for gpio ports and minor bug fix

Markus Grabner (1):
      Staging: add line6 usb driver

Markus Kempf (1):
      Staging: comedi: add ii_pci20kc driver

Markus Metzger (8):
      x86, ftrace, hw-branch-tracer: support hotplug cpus
      x86, ftrace, hw-branch-tracer: dump trace on oops
      x86, ftrace, hw-branch-tracer: reset trace buffer on close
      x86, ftrace, hw-branch-tracer: change trace format
      x86, ftrace, hw-branch-tracer: documentation
      x86, ds, bts: cleanup DS configuration
      x86, ftrace: fix section mismatch in hw-branch-tracer
      x86, ptrace: remove CONFIG guards around declarations

Martin Fuzzey (1):
      V4L/DVB (10945): pwc : fix LED and power setup for first open

Martin K. Petersen (5):
      [SCSI] scsi_debug: DIF/DIX support
      [SCSI] Remove SUGGEST flags
      [SCSI] sd: Make revalidate less chatty
      block: add private bio_set for bio integrity allocations
      MD data integrity support

Martin Michlmayr (4):
      [ARM] Orion: Fix some typos in the DNS-323 support code
      [ARM] Kirkwood: Hook up I2C
      [ARM] Kirkwood: More consistency regarding MPP naming
      [ARM] Kirkwood: Add support for QNAP TS-119/TS-219 Turbo NAS

Martin Peschke (1):
      [SCSI] zfcp: add measurement data for average qdio queue utilisatio=
n

Martin Petermann (1):
      [SCSI] zfcp: erp failed status bit will not be set

Martin Schwidefsky (6):
      [S390] clock sync mode flags
      [S390] module function call optimization
      [S390] eliminate cpuinfo_S390 structure
      [S390] eliminate ipl_device from lowcore
      [S390] cleanup lowcore.h
      mm: do_xip_mapping_read: fix length calculation

Martyn Welch (7):
      powerpc/86xx: Board support for GE Fanuc SBC310
      powerpc/86xx: Default configutation for GE Fanuc's SBC310
      powerpc/86xx: Extend GE Fanuc GPIO driver for the SBC310
      powerpc/86xx: Correct local bus registers in GE Fanuc SBC610 dts fi=
le
      powerpc/86xx: Run sbc310 USB fixup code only on the appropriate pla=
tform.
      powerpc/86xx: Board support for GE Fanuc's PPC9A
      powerpc/86xx: Default configuration for GE Fanuc's PPC9A

Masakazu Mokuno (2):
      PS3: gelic: convert the ethernet part to net_device_ops
      PS3: gelic: wireless: convert the wireless part to net_device_ops

Masami Hiramatsu (10):
      tracing, Text Edit Lock - SMP alternatives support
      x86: implement atomic text_poke() via fixmap
      x86: expand irq-off region in text_poke()
      x86: kretprobe-booster interrupt emulation code fix
      kprobes: cleanup aggr_kprobe related code
      kprobes: move EXPORT_SYMBOL_GPL just after function definitions
      kprobes: cleanup comment style in kprobes.h
      kprobes: rename kprobe_enabled to kprobes_all_disarmed
      kprobes: support per-kprobe disabling
      kprobes: support kretprobe and jprobe per-probe disabling

Masatake YAMATO (1):
      trivial: fix a pdlfush -> pdflush typo in comment

Mathieu Desnoyers (2):
      tracing, Text Edit Lock - Architecture Independent Code
      tracing, Text Edit Lock - kprobes architecture independent support

Matias Zabaljauregui (2):
      lguest: use KVM hypercalls
      lguest: use bool instead of int

Matt Carlson (14):
      tg3: Fix 5906 link problems
      tg3: Drop non-VLAN rx pkts larger than the MTU
      tg3: Update ethtool set_settings error checks
      tg3: Refine tg3_vlan_rx_register()
      tg3: Eliminate nvram routine forward declarations
      tg3: Invert nvram_read() and nvram_read_swab()
      tg3: Correct NVRAM stream endian notations
      tg3: Eliminate tg3_nvram_read_swab()
      tg3: Refactor firmware version routines
      tg3: Add legacy bootcode version decoding
      tg3: Add DASH firmware version reporting
      tg3: Add version reporting for hardware selfboot
      tg3: Update copyright and version
      Update TG3 MAINTAINERS entry

Matt Fleming (2):
      sh: Relax inline assembly constraints
      sh: Use the atomic_t "counter" member

Matt Kraai (1):
      USB: skeleton: Use dev_info instead of info

Matt LaPlante (2):
      trivial: fix typos/grammar errors in fs/Kconfig
      trivial: fix typos/grammar errors in Kconfig texts

Matthew Garrett (16):
      thermal: use integers rather than strings for thermal values
      ACPI: move thermal trip handling to generic thermal layer
      [CPUFREQ] Change link order of x86 cpufreq modules
      [CPUFREQ] Make cpufreq-nforce2 less obnoxious
      Allow relatime to update atime once a day
      Add a strictatime mount option
      Make relatime default
      sony-laptop: Add support for new Sony platform API
      sony-laptop: Enable EC on newer hardware
      sony-laptop: Add support for extra keyboard events
      sony-laptop: Add rfkill support on new models
      sony-laptop: Add support for extended hotkeys
      thermal: support forcing support for passive cooling
      ACPI: Populate DIDL before registering ACPI video device on Intel
      dell-wmi: new driver for hotkey control
      serial: Update PNP IDs

Matthew Ranostay (7):
      Add PCI DFI vendor ID
      ALSA: hda: add reference board SND_PCI_QUIRK
      ALSA: hda: 92hd71xxx disable unmute support for codecs that don't h=
ave input amps
      ALSA: hda: Added stac378x digital slave out struct
      ALSA: hda: Add STAC_DELL_S14 quirk
      ALSA: Add 92HD81B1C device id
      ALSA: hda - Add VREF powerdown sequence for another board

Matthew Wilcox (12):
      [SCSI] Add VPD helper
      [SCSI] ses: Use new scsi VPD helper
      [SCSI] sd: Refactor sd_read_capacity()
      [SCSI] sd: Try READ CAPACITY 16 first for SBC-2 devices
      Rewrite MSI-HOWTO
      PCI MSI: Replace 'type' with 'is_msix'
      PCI MSI: msi_desc->dev is always initialised
      PCI MSI: Use mask_pos instead of mask_base when appropriate
      PCI MSI: Refactor interrupt masking code
      PCI MSI: Add support for multiple MSI
      sysctl: fix suid_dumpable and lease-break-time sysctls
      ata: Add TRIM infrastructure

Matthias Fuchs (1):
      rtc: add EPSON RX8025 support to DS1307 RTC driver

Matthias Schwarzott (5):
      V4L/DVB (10662): remove redundant memset after kzalloc
      V4L/DVB (10822): Add support for Zarlink ZL10036 DVB-S tuner.
      V4L/DVB (10823): saa7134: add DVB support for Avermedia A700 cards
      V4L/DVB (10948): flexcop-pci: Print a message in case the new strea=
m watchdog detects a problem
      V4L/DVB (11386): saa7134: Add analog RF tuner support for Avermedia=
 A700 DVB-S Hybrid+FM card

Matthias Welwarsky (2):
      sony-laptop: new style events typo fixes
      sony-laptop: fix event reporting for new style events

Matthias-Christian Ott (1):
      [CPUFREQ] p4-clockmod reports wrong frequency.

Mattia Dongili (3):
      sony-laptop: merge Type4 into Type3
      sony-laptop: Make sony_pic_set_wwanpower not take mutexes
      sony-laptop: update copyright

Mauro Carvalho Chehab (62):
      V4L/DVB (10211): vivi: Implements 4 inputs on vivi
      V4L/DVB (10298): remove err macro from few usb devices
      V4L/DVB (10305): videobuf-vmalloc: Fix: videobuf memory were never =
freed
      V4L/DVB (10394): KWorld ATSC 115 all static
      V4L/DVB (10404): saa7134-core: remove oss option, since saa7134-oss=
 doesn't exist anymore
      V4L/DVB (10405): saa7134-core: loading saa7134-alsa is now the defa=
ult
      V4L/DVB (10504): tda827x: Be sure that gate will be open/closed at =
the proper time
      V4L/DVB (10505): tda8290: Print an error if i2c_gate is not provide=
d
      V4L/DVB (10506): saa7134: move tuner init code to saa7134-cards
      V4L/DVB (10507): saa7134: Fix analog mode on devices that need to o=
pen an i2c gate
      V4L/DVB (10508): saa7134: Cleanup: remove unused waitqueue from str=
uct
      V4L/DVB (10509): saa7134-video: two int controls lack a step
      V4L/DVB (10511): saa7134: get rid of KBL
      V4L/DVB (10512): tda1004x: Fix eeprom firmware load on boards with =
16MHz Xtal
      V4L/DVB (10514): em28xx: Add support for Kaiomy TVnPC U2 stick
      V4L/DVB (10515): Adds IR table for the IR provided with this board =
and includes it at
      V4L/DVB (10516): em28xx: Add support for Easy Cap Capture DC-60
      V4L/DVB (10570): v4l2-framework: documments videobuf usage on drive=
rs
      V4L/DVB (10571): v4l2-framework.txt: Fixes the videobuf init functi=
ons
      V4L/DVB (10654): em28xx: VideoMate For You USB TV box requires tvau=
dio
      V4L/DVB (10738): Get rid of video_decoder.h header were uneeded
      V4L/DVB(10738a): remove include/linux/video_encoder.h
      V4L/DVB (10769): Update dependencies of the modules converted to V4=
L2
      V4L/DVB (10771): tea575x-tuner: convert it to V4L2 API
      V4L/DVB (10835): Kconfig: Add some missing selects for a required f=
rontends
      V4L/DVB (10836): Kconfig: replace DVB_FE_CUSTOMIZE to DVB_FE_CUSTOM=
ISE
      V4L/DVB (10837): Kconfig: only open the customise menu if selected
      V4L/DVB (10838): get rid of the other occurrences of DVB_FE_CUSTOMI=
ZE typo
      V4L/DVB (10840): em28xx-dvb: Remove an unused header
      V4L/DVB (10842): Adds some missing frontend selects for saa7134 and=
 dvb-usb
      V4L/DVB (10870): v4l2-ioctl: get rid of video_decoder.h
      V4L/DVB (10896): /frontends/Kconfig: Move af9013 Kconfig option to =
its proper place
      V4L/DVB (10897): Fix Kbuild MEDIA_TUNER_CUSTOMIZE dependencies
      V4L/DVB (10870a): remove all references for video_decoder.h
      V4L/DVB (10907): avoid loading the entire videodev.h header on V4L2=
 drivers
      V4L/DVB (10951): xc5000: Fix CodingStyle errors introduced by the l=
ast patch
      V4L/DVB (10908): videobuf-core: also needs a minimal subset of V4L1=
 header
      V4L/DVB (11108): get_dvb_firmware: Add option to download firmware =
for cx231xx
      V4L/DVB (11109): au0828: Fix compilation when VIDEO_ADV_DEBUG =3D n
      V4L/DVB (11110): au8522/au0828: Fix Kconfig dependencies
      V4L/DVB (11111): dvb_dummy_fe: Fix compilation breakage
      V4L/DVB (11127): Kconfig: replace all occurrences of CUSTOMIZE to C=
USTOMISE
      V4L/DVB (11136): get_dvb_firmware: Add download code for cx18 firmw=
ares
      V4L/DVB (11137): get_dvb_firmware: add cx23885 firmwares
      V4L/DVB (11138): get_dvb_firmware: add support for downloading the =
cx2584x firmware for pvrusb2
      V4L/DVB (11225): v4lgrab: fix compilation warnings
      V4L/DVB (11226): avoid warnings for request_ihex_firmware on dabusb=
 and vicam
      V4L/DVB (11227): ce6230: avoid using unitialized var
      V4L/DVB (11308): msp3400: use the V4L2 header since no V4L1 code is=
 there
      V4L/DVB (10953): cx25840: Fix CodingStyle errors introduced by the =
last patch
      V4L/DVB (10955): cx231xx: CodingStyle automatic fixes with Lindent
      V4L/DVB (10956): cx231xx: First series of manual CodingStyle fixes
      V4L/DVB (10957a): cx231xx: Fix compilation breakage
      V4L/DVB (11130): cx231xx: fix an inverted logic at vidioc_streamoff
      V4L/DVB (11131): cx231xx: avoid trying to access unfilled dev struc=
t
      V4L/DVB (11132): cx231xx: usb probe cleanups
      V4L/DVB (11133): cx231xx: don't print pcb config debug messages by =
default
      V4L/DVB (11134): cx231xx: dmesg cleanup
      V4L/DVB (11135): cx231xx: use usb_make_path() for bus_info
      V4L/DVB (11250): cx231xx: Fix Kconfig help items
      V4L/DVB (11360): em28xx: use usb_interface.dev for v4l2_device_regi=
ster
      cx231xx: Convert to snd_card_create()

Maxime Bizon (1):
      [ARM] Kirkwood: invalidate L2 cache before enabling it

Michael Buesch (40):
      b43: Fixup set_key handling
      b43: Use 64bit atomic register access for TSF
      b43/ssb: Add SPROM8 extraction and LP-PHY detection
      b43: Change schedule for old-fw support removal
      b43: Automatically probe for opensource firmware
      b43: Fix phy_g.c compiler warning
      b43: Dynamically control log verbosity
      b43: Add LP-PHY register definitions
      b43: Add LP-PHY baseband init for >=3Drev2
      b43: Add LP 2062 radio init
      ssb: Add PMU support
      b43: Port spec bugfixes for the LP baseband init
      b43: (b2062) Fix crystal frequency calculations
      b43: Add parts of LP-PHY TX power control
      b43: Move DMA stop sanity check
      b43: Fix DMA buffer size handling
      b43: Optimize DMA buffers
      b43: Add slot count compiletime assertion
      b43: Fix radio host flags
      b43: Honor the no-slow-clock boardflag
      b43: Enable PCI slow clock workaround, if needed.
      mac80211: Add software scan notifiers
      b43: Implement sw scan callbacks
      b43: Convert usage of b43_phy_set()
      b43: Convert usage of b43_phy_mask()
      b43: Convert usage of b43_phy_maskset()
      b43: Convert usage of b43_radio_set()
      b43: Convert usage of b43_radio_mask()
      b43: Convert usage of b43_radio_maskset()
      b43: Remove bogus integer truncation warnings
      ssb: Add SPROM fallback support
      b43: Pass more RX flags to mac80211
      b43: Fix compilation for devices without PCI core
      b43: Mask PHY TX error interrupt, if not debugging
      ssb: remove EXPERIMENTAL dependencies.
      b43: Add BCM4307 PCI-ID
      bcm47xx: fix GPIO API return codes
      spi-gpio: allow operation without CS signal
      b44: Fix sizes passed to b44_sync_dma_desc_for_{device,cpu}()
      b44: Use kernel DMA addresses for the kernel DMA API

Michael Chan (1):
      bnx2: Use request_firmware()

Michael Ellerman (28):
      x86: Remove never-called arch_setup_msi_irq()
      powerpc: Remove unused ppc64_terminate_msg()
      powerpc: Allow debugging of LMBs with lmb=3Ddebug
      lmb: Rework lmb_dump_all() output
      powerpc/pseries: Fix MSI-X interrupt querying
      powerpc/pseries: Add support for ibm,req#msi-x
      powerpc/pseries: Check for MSI-X also in rtas_msi_pci_irq_fixup()
      powerpc/pseries: Return the number of MSIs we could allocate
      powerpc/pseries: Return req#msi(-x) if request is larger
      powerpc/pseries: Implement a quota system for MSIs
      powerpc: Deindentify identify_cpu()
      powerpc: Make sure we copy all cpu_spec features except PMC related=
 ones
      powerpc: Remove unused asm-offsets entries for cpu_spec
      powerpc: Print linux_banner in prom_init
      powerpc/pseries: Reject discontiguous/non-zero based MSI-X requests
      powerpc/pseries: The pseries MSI code depends on EEH
      powerpc/cell: Fix Axon MSI driver dependencies
      powerpc/pseries: The RPA PCI hotplug driver depends on EEH
      PCI/MSI: Use #ifdefs instead of weak functions
      PCI/MSI: Allow arch code to return the number of MSI-X available
      PCI MSI: Add example request loop to MSI-HOWTO.txt
      powerpc/cell: Make axonram depends on BLOCK
      powerpc/msi: Mark the MSI bitmap selftest code as __init
      powerpc: Turn on self-tests in ppc64_defconfig
      MAINTAINERS: add hvc_console
      powerpc: Print information about mapping hw irqs to virtual irqs
      powerpc/ftrace: Fix #if that should be #ifdef
      powerpc/ftrace: Fix printf format warning

Michael Hennerich (7):
      Blackfin arch: add a check to make sure only Blackfin GPIOs may gen=
erate IRQs
      Blackfin arch: enable the platfrom PATA driver with CF Cards
      Blackfin arch: Privide BF537-STAMP platform data of ADP5520 Multifu=
nction driver
      Blackfin arch: Blacklist Hibernate (PM_SUSPEND_MEM) on BF561 as wel=
l
      blackfin: BF538/9 serial uart support
      Blackfin SPI Driver: Fix erroneous SPI Clock divisor calculation
      Blackfin SPI Driver: Add GPIO controlled SPI Slave Select support

Michael Hillmann (1):
      Staging: comedi: add ke_counter driver

Michael Holzheu (5):
      [S390] zfcpdump: Prevent zcore from beeing built as a kernel module.
      [S390] s390dbf: Remove redundant initilizations.
      [S390] s390dbf: Remove needless check for NULL pointer.
      [S390] ipl: Improve checking logic and remove switch defaults.
      [S390] Ensure that ipl panic notifier is called late.

Michael K. Johnson (1):
      x86, setup: mark %esi as clobbered in E820 BIOS call

Michael Krufky (36):
      V4L/DVB (10415): dib0700: add data debug to dib0700_i2c_xfer_new
      V4L/DVB (10416): tveeprom: update to include Hauppauge tuners 151-1=
55
      V4L/DVB (10417): sms1xxx: add missing usb id 2040:2011
      V4L/DVB (10746): sms1xxx: enable rf switch on Hauppauge Tiger devic=
es
      V4L/DVB (10747): sms1xxx: move definition of struct smsdvb_client_t=
 into smsdvb.c
      V4L/DVB (10749): sms1xxx: move smsusb_id_table into smsusb.c
      V4L/DVB (10751): sms1xxx: fix checkpatch.pl violations introduced b=
y previous changeset
      V4L/DVB (10752): sms1xxx: load smsdvb module automatically based on=
 device id
      V4L/DVB (10753): siano: convert EXPORT_SYMBOL to EXPORT_SYMBOL_GPL
      V4L/DVB (10772): siano: prevent duplicate variable declaration
      V4L/DVB (10779): mxl5007t: remove analog tuning code
      V4L/DVB (10780): mxl5007t: remove function mxl5007t_check_rf_input_=
power
      V4L/DVB (10781): mxl5007t: mxl5007t_get_status should report if tun=
er is locked
      V4L/DVB (10782): mxl5007t: warn when unknown revisions are detected
      V4L/DVB (10783): mxl5007t: fix devname for hybrid_tuner_request_sta=
te
      V4L/DVB (10784): mxl5007t: update driver for MxL 5007T V4
      V4L/DVB (10876): tda18271: add support for AGC configuration via tu=
ner callback
      V4L/DVB (10877): saa7134: add analog support for Hauppauge HVR1110r=
3 boards
      V4L/DVB (10898): remove build-time dependencies on dib7000m
      V4L/DVB (10899): remove build-time dependencies on dib7000p
      V4L/DVB (10900): remove build-time dependencies on dib3000mc
      V4L/DVB (10901): cleanup linewraps in dib7000p.h
      V4L/DVB (10902): cleanup linewraps in dib7000m.h
      V4L/DVB (10903): cleanup linewraps in dib3000mc.h
      V4L/DVB (10904): remove dib0070_ctrl_agc_filter from dib0070.h
      V4L/DVB (10905): dib0700: enable DVB_FE_CUSTOMISE for dibcom fronte=
nds
      V4L/DVB (10923): saa7134: fix typo in product name
      V4L/DVB (10924): saa7134: enable serial transport streaming interfa=
ce
      V4L/DVB (10925): add support for LG Electronics LGDT3305 ATSC/QAM-B=
 Demodulator
      V4L/DVB (10926): saa7134: enable digital tv support for Hauppauge W=
inTV-HVR1120
      V4L/DVB (10927): dib0700: add support for Hauppauge ATSC MiniCard
      V4L/DVB (10968): lgdt3305: add email address to MODULE_AUTHOR
      V4L/DVB (10969): lgdt3305: add missing space in comment
      V4L/DVB (10970): lgdt3305: add MODULE_VERSION
      V4L/DVB (10984): lgdt3305: avoid OOPS in error path of lgdt3305_att=
ach
      V4L/DVB (11251): tuner: prevent invalid initialization of t->config=
 in set_type

Michael Neuling (4):
      powerpc: Add alignment handler for new lfiwzx instruction
      powerpc: Fix load/store float double alignment handler
      powerpc: Disable VSX or current process in giveup_fpu/altivec
      powerpc: Fix ptrace compat wrapper for FPU register access

Michael Schmitz (2):
      m68k: section mismatch fixes: DMAsound for Atari
      m68k: section mismatch fixes: Atari SCSI

Michael Schwingen (1):
      ALSA: hda - add support for "Maxdata Favorit 100XS" (Intel HDA/ALC2=
60)

Michael Tokarev (1):
      tun: Check supplemental groups in TUN/TAP driver.

Michael Trimarchi (1):
      sh: Fix up DSP context save/restore.

Michal Dobes (7):
      Staging: comedi: add amcc_s5933 header file
      Staging: comedi: add adl_pci9118 driver
      Staging: comedi: add adv_pci1710 driver
      Staging: comedi: add pcl724 driver
      Staging: comedi: add pcl821 driver
      Staging: comedi: add pcl818 driver
      Staging: comedi: add adv_pci_dio driver

Michal Januszewski (2):
      uvesafb: fix selecting mode with the vbemode option
      uvesafb: documentation update

Michel Lachaine (2):
      Staging: comedi: add adl_pci7432 driver
      Staging: comedi: add adl_pci8164 driver

Mikael Pettersson (1):
      [ARM] 5435/1: fix compile warning in sanity_check_meminfo()

Mike Christie (13):
      [SCSI] iser: have iser use its own logging
      [SCSI] libiscsi: replace scsi_debug logging with session/conn loggi=
ng
      [SCSI] libiscsi_tcp: replace tcp_debug/scsi_debug logging with sess=
ion/conn logging
      [SCSI] iscsi_tcp: replace scsi_debug/tcp_debug logging with iscsi c=
onn logging
      [SCSI] libiscsi: don't cap queue depth in iscsi modules
      [SCSI] iscsi class: fix lock dep warning on logout
      [SCSI] iscsi lib: have lib create work queue for transmitting IO
      [SCSI] iscsi lib: remove qdepth param from iscsi host allocation
      [SCSI] libiscsi: pass session failure a session struct
      [SCSI] iscsi class: remove host no argument from session creation c=
allout
      [SCSI] libiscsi: fix possbile null ptr session command cleanup
      [SCSI] cxgb3i: re-read ddp settings information after chip reset
      [SCSI] cxgb3i: call ddp release function directly

Mike Frysinger (31):
      ASoC: Blackfin: cleanup sport handling in ASoC Blackfin AC97 code
      ASoC: Blackfin: drop unnecessary dma casts
      ASoC: Blackfin: move gpio_err behind the define that is only user o=
f it
      ASoC: Blackfin: fix typo in MUTE definition
      [MTD] [NAND] Blackfin NFC Driver: do not clobber DMAC1_PERIMUX
      [MTD] [NAND] Blackfin NFC Driver: mark bf5xx_nand_add_partition() a=
s __devinit
      [MTD] [NAND] Blackfin NFC Driver: drop pointless casts with set_dma=
_callback()
      Blackfin arch: include linux headers that this one uses definitions=
 from fro sport drivers
      Blackfin arch: bf51x processors also have 8 timers
      Blackfin arch: convert BF5{18,27,48}_FAMILY to CONFIG_BF{51,52,54}x
      Blackfin arch: clean up sports header file
      Blackfin arch: add link-time asserts to make sure on-chip regions d=
ont overflow
      bin_elf_fdpic: check the return value of clear_user
      blackfin: Use unsigned long for flags with irq functions
      Blackfin SPI Driver: remove useless <asm/cplbinit.h>
      Blackfin SPI Driver: use len_in_bytes when we care about the number=
 of bytes transferred
      Blackfin SPI Driver: pass DMA overflow error to the higher level
      Blackfin SPI Driver: unify duplicated code in dma read/write paths
      Blackfin SPI Driver: drop bogus cast and touchup dma label
      Blackfin SPI Driver: add a few more DMA debug messages
      Blackfin SPI Driver: do not check for SPI errors if DMA itself did =
not flag any
      Blackfin SPI Driver: use the properl BIT_CTL_xxx defines
      Blackfin SPI Driver: SPI slave select code cleanup
      Blackfin SPI Driver: get dma working for SPI flashes
      Blackfin SPI Driver: add timeout while waiting for SPIF in dma irq =
handler
      Blackfin SPI Driver: tweak magic spi dma sequence to get it working=
 on BF54x
      Blackfin SPI Driver: use bfin_spi_ prefix on all functions
      Blackfin SPI Driver: fix NULL pointer crash
      Change KCONFIG name
      KGDB_SERIAL_CONSOLE check for module
      Adjust path to gpio headers

Mike Galbraith (1):
      sched: add avg_overlap decay

Mike Isely (65):
      V4L/DVB (10236): pvrusb2: Stop advertising VBI capability - it isn'=
t there
      V4L/DVB (10237): pvrusb2: Generate a device-unique identifier
      V4L/DVB (10238): pvrusb2: Change sysfs serial number handling
      V4L/DVB (10239): pvrusb2: Fix misleading comment caused by earlier =
commit
      V4L/DVB (10258): pvrusb2: Issue VIDIOC_INT_INIT to v4l2 modules whe=
n they first attach
      V4L/DVB (10259): pvrusb2: Code module name directly in printk
      V4L/DVB (10303): pvrusb2: Use usb_make_path() to determine device b=
us location
      V4L/DVB (11154): pvrusb2: Split i2c module handling from i2c adapte=
r
      V4L/DVB (11155): pvrusb2: Set up v4l2_device instance
      V4L/DVB (11156): pvrusb2: Changes to further isolate old i2c layer
      V4L/DVB (11157): pvrusb2: whitespace trivial tweaks
      V4L/DVB (11158): pvrusb2: New device attribute mechanism to specify=
 sub-devices
      V4L/DVB (11159): pvrusb2: Providing means to stop tracking an old i=
2c module
      V4L/DVB (11160): pvrusb2: whitespace tweaks
      V4L/DVB (11161): pvrusb2: Set i2c autoprobing to be off by default
      V4L/DVB (11162): pvrusb2: Tie up loose ends with v4l2-subdev setup
      V4L/DVB (11163): pvrusb2: Lay foundation for triggering sub-device =
updates
      V4L/DVB (11164): pvrusb2: Tie-in sub-device log requests
      V4L/DVB (11165): pvrusb2: Tie in debug register access to sub-devic=
es
      V4L/DVB (11166): pvrusb2: Implement status fetching from sub-device=
s
      V4L/DVB (11167): pvrusb2: Tie in various v4l2 operations into the s=
ub-device mechanism
      V4L/DVB (11168): pvrusb2: Define value for a null sub-device ID
      V4L/DVB (11169): pvrusb2: Note who our video decoder sub-device is,=
 and set it up
      V4L/DVB (11170): pvrusb2: Clean-up / placeholders inserted for addi=
tional development
      V4L/DVB (11171): pvrusb2: Tie in sub-device decoder start/stop
      V4L/DVB (11172): pvrusb2: Cause overall initialization to fail if s=
ub-driver(s) fail
      V4L/DVB (11173): pvrusb2: Fix backwards function header comments
      V4L/DVB (11174): pvrusb2: Implement reporting of connected sub-devi=
ces
      V4L/DVB (11175): pvrusb2: Implement sub-device specific update fram=
ework
      V4L/DVB (11176): pvrusb2: Tie in wm8775 sub-device handling
      V4L/DVB (11177): pvrusb2: Tie in saa7115 sub-device handling
      V4L/DVB (11178): pvrusb2: Make audio sample rate update into a sub-=
device broadcast
      V4L/DVB (11179): pvrusb2: make sub-device specific update function =
names uniform
      V4L/DVB (11180): pvrusb2: Tie in msp3400 sub-device support
      V4L/DVB (11181): pvrusb2: Fix silly 80 column issue
      V4L/DVB (11182): pvrusb2: Tie in cx25840 sub-device support
      V4L/DVB (11183): pvrusb2: Implement more sub-device loading trace a=
nd improve error handling
      V4L/DVB (11184): pvrusb2: Define default i2c address for wm8775 sub=
-device
      V4L/DVB (11185): pvrusb2: Fix uninitialized counter
      V4L/DVB (11186): pvrusb2: Fix bugs involved in listing of sub-devic=
es
      V4L/DVB (11187): pvrusb2: Allow sub-devices to insert correctly
      V4L/DVB (11188): pvrusb2: Sub-device update must happen BEFORE stat=
e dirty bits are cleared
      V4L/DVB (11189): pvrusb2: Deal with space-after-comma coding style =
idiocy
      V4L/DVB (11190): pvrusb2: Broadcast tuner type change to sub-device=
s
      V4L/DVB (11191): pvrusb2: Define default I2C address for cx25840 su=
b-device
      V4L/DVB (11192): pvrusb2: Implement trace print for stream on / off=
 action
      V4L/DVB (11193): pvrusb2: Correct some trace print inaccuracies
      V4L/DVB (11194): pvrusb2: Implement mechanism to force a full sub-d=
evice update
      V4L/DVB (11195): pvrusb2: Issue required core init broadcast to all=
 sub-devices
      V4L/DVB (11196): pvrusb2: Define default I2C addresses for msp3400 =
and saa7115 sub-devices
      V4L/DVB (11197): pvrusb2: Fix incorrectly named sub-device ID
      V4L/DVB (11198): pvrusb2: Define default I2C address for CS53L32A s=
ub-device
      V4L/DVB (11199): pvrusb2: Convert all device definitions to use new=
 sub-device declarations
      V4L/DVB (11200): pvrusb2: Make a bunch of dvb config structures con=
st (trivial)
      V4L/DVB (11201): pvrusb2: Fix space-after-comma idiocy
      V4L/DVB (11202): pvrusb2: Fix slightly mis-leading header in debug =
interface output
      V4L/DVB (11203): pvrusb2: Implement better reporting on attached su=
b-devices
      V4L/DVB (11204): pvrusb2: Remove old i2c layer; we use v4l2-subdev =
now
      V4L/DVB (11205): pvrusb2: Remove ancient IVTV specific ioctl functi=
ons
      V4L/DVB (11206): pvrusb2: Add sub-device for demod
      V4L/DVB (11207): pvrusb2: Add composite and s-video input support f=
or OnAir devices
      V4L/DVB (11208): pvrusb2: Use v4l2_device_disconnect()
      V4L/DVB (11332): pvrusb2: Fix incorrect reporting of default value =
for non-integer controls
      V4L/DVB (11333): pvrusb2: Report def_val items in sysfs symbolicall=
y, consistent with cur_val
      V4L/DVB (11334): pvrusb2: Fix uninitialized tuner_setup field(s)

Mike Mason (1):
      powerpc/eeh: Only disable/enable LSI interrupts in EEH

Mike Miller (2):
      cciss: kernel scan thread for MSA2012
      cciss: change to discover first memory BAR

Mike Rapoport (22):
      [ARM] pxa/em-x270: updates for 2.6.29
      [ARM] pxa: update xm_x2xx_defconfig
      [ARM] pxa/em-x270: update MMC/SDIO implementation
      [ARM] pxa/em-x270: introduce macors to to simplify da9030 subdev in=
itialization
      [ARM] pxa/em-x270: add battery charger
      [ARM] pxa/em-x270: prepare addition of eXeda machine to em-x270.c
      [ARM] pxa: add eXeda platform support
      [ARM] pxa: prepare xm_x2xx_defconfig for split
      [ARM] pxa: add em_x270_defconfig for EM-X270 and eXeda
      libertas: if_spi: add ability to call board specific setup/teardown=
 methods
      [ARM] pxa: add DM9000_PLATF_NO_EEPROM flag to CM-X... platforms
      [MTD] [NAND] pxa3xx_nand: use resource_size instead of 'r->end - r-=
>start + 1'
      [MTD] [NAND] pxa3xx_nand: allow building as module
      [MTD] [NAND] pxa3xx_nand: add ability to keep controller settings d=
efined by OBM/bootloader
      regulator: add unset_regulator_supplies to fix regulator_unregister
      rtc-v3020: coding style cleanup
      [ARM] 5442/1: pxa/cm-x255: fix reverse RDY gpios in PCMCIA driver
      rtc-v3020: add ability to access v3020 chip with GPIOs
      spi_bfin5xx: remove unused IS_DMA_ALIGNED macro
      SPI: add dma_alignment field to spi_master
      pxa2xx_spi: set spi_master.dma_alignment =3D 8
      spi_imx: set spi_master.dma_alignment =3D 4

Mike Snitzer (3):
      ext4: Remove stale block allocator references from ext4.h
      dm log: use standard kernel module refcount
      dm log: remove struct dm_dirty_log_internal

Mike Travis (21):
      cpumask: update irq_desc to use cpumask_var_t
      cpumask: fix bug in use cpumask_var_t in irq_desc
      SGI UV cpumask: use static temp cpumask in flush_tlb
      x86: cleanup remaining cpumask_t code in mce_amd_64.c
      x86: reduce stack usage in init_intel_cacheinfo
      cpumask: use cpumask_var_t in dcdbas.c
      cpumask: reduce stack usage in find_lowest_rq
      Xen: reduce memory required for cpu_evtchn_mask
      irq: change references from NR_IRQS to nr_irqs
      irq: use WARN() instead of WARN_ON().
      irq: allocate irq_desc_ptrs array based on nr_irqs
      irq: initialize nr_irqs based on nr_cpu_ids
      kstat: modify kstat_irqs_legacy to be variable sized
      cpumask, irq: non-x86 build failures
      irq: update all arches for new irq_desc
      irq: update all arches for new irq_desc, fix
      x86: fix build warning when CONFIG_NUMA not defined.
      sched: fix warning on ia64
      x86: cleanup early setup_percpu references
      cpufreq: use work_on_cpu in acpi-cpufreq.c for drv_read and drv_wri=
te
      x86: put trigger in to detect mismatched apic versions.

Mikhail Zolotaryov (1):
      powerpc 4xx EMAC driver: device name reported on timeout is not cor=
rect

Miklos Szeredi (7):
      lockd: clean up blocking lock cases of nlsmvc_lock()
      fuse: allow kernel to access "direct_io" files
      fuse: allow private mappings of "direct_io" files
      uml: fix compile error from net_device_ops conversion
      uml: fix link error from prefixing of i386 syscalls with ptregs_
      uml: fix warnings in kernel_execve
      splice: fix deadlock in splicing to file

Mikulas Patocka (17):
      dm: preserve bi_io_vec when resubmitting bios
      dm raid1: switch read_record from kmalloc to slab to save memory
      dm io: make sync_io uninterruptible
      dm snapshot: refactor __find_pending_exception
      dm snapshot: avoid dropping lock in __find_pending_exception
      dm snapshot: avoid having two exceptions for the same chunk
      dm: bio list add bio_list_add_head
      dm: remove unnecessary work queue type field
      dm: remove unnecessary work queue context field
      dm: remove unnecessary struct dm_wq_req
      dm: rename __split_bio
      dm: move bio_io_error into __split_and_process_bio
      dm: merge __flush_deferred_io into caller
      dm: allow uninterruptible wait for pending io
      dm: merge pushback and deferred bio lists
      dm: move wait queue declaration
      dm: set queue ordered mode

Milind Arun Choudhary (1):
      proc: fix sparse warnings in pagemap_read()

Miloslav Trmac (2):
      Audit: fix handling of 'strings' with NULL characters
      audit: ignore terminating NUL in AUDIT_USER_TTY messages

Milton Miller (4):
      powerpc/numa: Avoid possible reference beyond prop. length in find_=
min_common_depth()
      powerpc/numa: Remove redundant find_cpu_node()
      powerpc/pseries: Remove write only variable in PCI DLPAR
      powerpc/pci: Move hose_list and pci_address_to_pio to pci-common

Mimi Zohar (11):
      integrity: IMA hooks
      integrity: IMA as an integrity service provider
      integrity: IMA display
      integrity: IMA policy
      integrity: IMA policy open
      Integrity: IMA file free imbalance
      Integrity: IMA update maintainers
      integrity: shmem zero fix
      integrity: audit update
      integrity: ima scatterlist bug fix
      integrity: ima iint radix_tree_lookup locking fix

MinChan Kim (2):
      vmap: remove needless lock and list in vmap
      mm: shrink_all_memory(): use sc.nr_reclaimed

Ming Lei (7):
      USB: ch341 serial: fix port number changed after resume
      driver core: check bus->match without holding device lock
      platform driver: fix incorrect use of 'platform_bus_type' with 'str=
uct device_driver'
      driver core: remove polling for driver_probe_done(v5)
      driver core: move platform_data into platform_device
      driver core: fix passing platform_data
      Driver core: implement uevent suppress in kobject

Mingming Cao (5):
      quota: Add quota reservation support
      quota: Add quota reservation claim and released operations
      quota: Use inode->i_blkbits to get block bits
      quota: Move EXPORT_SYMBOL immediately next to the functions/varible=
s
      ext4: quota reservation for delayed allocation

Mithlesh Thukral (31):
      Staging: sxg: New SXG_SGL design and MAC Header changes
      Staging: sxg: Typedef removal - pending work
      Staging: sxg: Commenting style fixes - Pending work
      Staging: sxg: Indentation fixes - mostly 80 char lines
      Staging: sxg: Receive code and data structure cleanups
      Staging: sxg: Ethtool framework and Receive code path changes
      Staging: sxg: SXG SGL related cleanup in data structures and code
      Staging: sxg: Locking related changes. Fix locking levels
      Staging: sxg: Add Ethtool functionality enhancement and misc cleanu=
ps
      Staging: sxg: Firmware updates
      Staging: sxg: Fix to load card on low memory machines
      Staging: sxg: Add multicast support for Sahara SXG driver
      Staging: sxg: Add NAPI feature to Sahara SXG Driver
      Staging: sxg: Cleanup the SXG driver of unused space and functions
      Staging: sxg: Add Jumbo frames support to Sahara SXG Driver
      Staging: sxg: Removed unnecessary checks while taking Transmit Lock=
s
      Staging: sxg: Make SXG driver use MSI-X interrupts if possible
      Staging: sxg: Add Checksum Offload support for Sahara SXG driver
      Staging: sxg: Fix memory leak in case of allocation failure
      Staging: sxg: Add firmware files for Rev B card
      Staging: sxg: Add Rev B support in the Sahara SXG driver
      Staging: sxg: Remove unused Rev A microcode files
      Staging: sxg: Add checksum control option through ethtool interface
      Staging: sxg: Fix memory leak caused by double allocation of rings
      Staging: sxg: Fix the module in Kconfig file for Sahara SXG driver
      Staging: sxg: Fix interface bug not working after open is called se=
cond time.
      Staging: sxg: Read the correct MAC address from the card for Rev B =
cards
      Staging: sxg: Fix a warning dump emitted by rtnl_watchdog during LT=
P tests
      Staging: sxg: Add watchdog timer for managing Link states for SXG d=
river
      Staging: sxg: Add support to download the firmware using request_fi=
rmware()
      Staging: sxg: slicoss: Specify the license for Sahara SXG and Slico=
ss drivers

Mohamed Abbas (6):
      iwlagn: fix warning when set WEP key
      iwlagn: use changed in mac_config
      iwl3945: use changed in iwl3945_mac_config
      iwlagn: allow power level setting all the times
      iwlcore: dont commit power command if interface is not up
      iwlwifi: support 11h

Moni Shoua (2):
      IB/mlx4: Fix dispatch of IB_EVENT_LID_CHANGE event
      IB/mthca: Fix dispatch of IB_EVENT_LID_CHANGE event

Moritz Muehlenhoff (64):
      Staging: wlan-ng: Remove use of __WLAN_ATTRIB_PACK__
      Staging: wlan-ng: Remove use of WLAN_ADDR_LEN
      Staging: wlan-ng: Remove stray comments in header files
      Staging: wlan-ng: Cleanup wlan_compat.h more
      Staging: wlan-ng: Remove DBFENTER/DBFEXIT macros
      Staging: wlan-ng: Use generic byteorder macros
      Staging: wlan-ng: Replace BITx with the generic BIT(x)
      Staging: wlan-ng: Move URB_ASYNC_UNLINK and USB_QUEUE_BULK out of w=
lan_compat.h
      Staging: wlan-ng: Remove WLAN_LOG_INFO
      Staging: wlan-ng: Remove wlan_max()/wlan_min()
      Staging: wlan-ng: Replace WLAN_LOG_NOTICE with printk()
      Staging: wlan-ng: Replace WLAN_LOG_ERROR() with printk()
      Staging: wlan-ng: Replace WLAN_LOG_WARNING() with printk()
      Staging: wlan-ng: Replace wlan_isprint() with generic isprint()
      Staging: wlan-ng: Remove dead/unused code from p80211types.h
      Staging: wlan-ng: Remove dead/unused code from p80211hdr.h
      Staging: wlan-ng: Remove dead/unused code from p80211meta.h
      Staging: wlan-ng: Remove dead/unused code from hfa384x.h
      Staging: wlan-ng: Remove dead/unused code from p80211msg.h
      Staging: wlan-ng: Remove dead/unused code from p80211netdev.h
      Staging: wlan-ng: Remove dead/unused code from p80211conv.c
      Staging: wlan-ng: Remove dead/unused code from p80211conv.h
      Staging: wlan-ng: Remove dead/unused code from p80211req.c
      Staging: wlan-ng: Replace SSWAP() with the generic swap(). Also rem=
ove a
      Staging: wlan-ng: Remove more dead/unused code from p80211types.h
      Staging: wlan-ng: Remove dead/unused code from prism2sta.c
      Staging: wlan-ng: Remove dead code from prism2mgmt.c
      Staging: wlan-ng: Remove dead code from hfa384x_usb.c
      Staging: wlan-ng: Remove unused header file p80211metamib.h
      Staging: wlan-ng: Remove dead/unused code from p80211metadef.h
      Staging: wlan-ng: Remove dead/unused code from p80211ioctl.h
      Staging: wlan-ng: Remove dead/unused code from hfa384x.h and p80211=
metamsg.h
      Staging: wlan-ng: Remove more dead/unused code from hfa384x.h
      Staging: wlan-ng: Remove WLAN_INCLUDE_DEBUG and some related, mostl=
y unused
      Staging: wlan-ng: Move netdevice_t typedef into p80211netdev.h
      Staging: wlan-ng: Move wlan_mkprintstr() and wlan_hexchar() macros =
into prism2sta.c
      Staging: wlan-ng: Replace WLAN_LOG_DEBUG() with printk(KERN_DEBUG
      Staging: wlan-ng: p80211req.h: Coding style cleanups
      Staging: wlan-ng: p80211req.c: Coding style cleanups
      Staging: wlan-ng: prism2mgmt.h: Coding style cleanups
      Staging: wlan-ng: hfa384x.h: Coding style cleanups
      Staging: wlan-ng: p80211wext.c: Coding style cleanups
      Staging: wlan-ng: p80211meta.h: Coding style cleanups
      Staging: wlan-ng: p80211ioctl.h: Coding style cleanups
      Staging: wlan-ng: p80211metastruct.h: Coding style cleanups
      Staging: wlan-ng: p80211hdr.h: Coding style cleanups
      Staging: wlan-ng: p80211conv.h: Coding style cleanups
      Staging: wlan-ng: p80211conv.c: Coding style cleanups
      Staging: wlan-ng: p80211types.h: Coding style cleanups
      Staging: wlan-ng: p80211msg.h: Coding style cleanups
      Staging: wlan-ng: p80211netdev.h: Coding style cleanups
      Staging: wlan-ng: p80211mgmt.h: Coding style cleanups
      Staging: wlan-ng: prism2mib.c: Coding style cleanups
      Staging: wlan-ng: prism2usb.c: Coding style cleanups
      Staging: wlan-ng: prism2sta.c: Coding style cleanups
      Staging: wlan-ng: p80211netdev.c: Coding style cleanups
      Staging: wlan-ng: hfa384x_usb.c: Coding style cleanups
      Staging: wlan-ng: prism2mgmt.c: Coding style cleanups
      Staging: wlan-ng: Remove dead code from prism2mib.c
      Staging: wlan-ng: Remove more dead code from hfa384x_usb.c
      Staging: wlan-ng: Remove unnecessary checks for NULL before calling=
 kfree()
      Staging: wlan-ng: Remove dead code from p80211netdev.c
      Staging: wlan-ng: Remove the now empty wlan_compat.h
      Staging: wlan-ng: Replace local byteorder macros

M=C3=A1rton N=C3=A9meth (2):
      V4L/DVB (10633): DAB: fix typo
      V4L/DVB (11293): uvcvideo: Add zero fill for VIDIOC_ENUM_FMT

Nam Ph=E1=BA=A1m Th=C3=A0nh (1):
      V4L/DVB (10242): pwc: add support for webcam snapshot button

Nathan Fontenot (2):
      powerpc/numa: Cleanup hot_add_scn_to_nid
      powerpc/pseries: Failed reconfig notifier chain call cleanup

Nathan Williams (1):
      solos: Automatically determine number of ports

Neil Horman (8):
      crypto: ansi_cprng - Force reset on allocation
      crypto: ansi_cprng - Panic on CPRNG test failure when in FIPS mode
      crypto: ansi_cprng - Add maintainer
      Network Drop Monitor: Add trace declaration for skb frees
      Network Drop Monitor: Adding kfree_skb_clean for non-drops and modi=
fying end-of-line points for skbs
      Network Drop Monitor: Adding drop monitor implementation & Netlink =
protocol
      Network Drop Monitor: Adding Build changes to enable drop monitor
      kexec: add dmesg log symbols to /proc/vmcoreinfo lists

NeilBrown (43):
      NFS: flush cached directory information slightly more readily.
      md: Fix is_mddev_idle test (again).
      md: Allow write-intent bitmaps to have chunksize < PAGE_SIZE
      md: never clear bit from the write-intent bitmap when the array is =
degraded.
      md: write bitmap information to devices that are undergoing recover=
y.
      md: move LEVEL_* definition from md_k.h to md_u.h
      md: move most content from md.h to md_k.h
      md: move lots of #include lines out of .h files and into .c
      md: move md_k.h from include/linux/raid/ to drivers/md/
      md: occasionally checkpoint drive recovery to reduce duplicate effo=
rt after a crash
      md: be more consistent about setting WriteMostly flag when adding a=
 drive to an array
      md/raid5: simplify interface for init_stripe and get_active_stripe
      md/raid5: change raid5_compute_sector and stripe_to_pdidx to take a=
 'previous' argument
      md/raid6: remove expectation that Q device is immediately after P d=
evice.
      md/raid5: simplify raid5_compute_sector interface
      md/raid5: Add support for new layouts for raid5 and raid6.
      md/raid5: finish support for DDF/raid6
      md: make sure new_level, new_chunksize, new_layout always have sens=
ible values.
      md/raid5: refactor raid5 "run"
      md: md_unregister_thread should cope with being passed NULL
      md: enable suspend/resume of md devices.
      md: add ->takeover method to support changing the personality manag=
ing an array
      md: add ->takeover method for raid5 to be able to take over raid1
      md/raid5: allow layout/chunksize to be changed on an active 2-drive=
 raid5.
      md: add takeover support for raid4 -> raid5 conversion.
      md: add takeover support for converting raid6 back into raid5
      md/raid5: drop qd_idx from r6_state
      md/raid5: enhance raid5_size to work correctly with negative delta_=
disks
      md: add explicit method to signal the end of a reshape.
      md/raid5: change reshape-progress measurement to cope with reshapin=
g backwards.
      md: allow number of drives in raid5 to be reduced
      Documentation/md.txt update
      md/raid5: clearly differentiate 'before' and 'after' stripes during=
 reshape.
      md/raid5: prepare for allowing reshape to change chunksize.
      md/raid5: prepare for allowing reshape to change layout
      md/raid5: reshape using largest of old and new chunk size
      md/raid5: allow layout and chunksize to be changed on active array.
      md: don't display meaningless values in sysfs files resync_start an=
d sync_speed
      md/raid5: be more careful about write ordering when reshaping.
      md: remove CONFIG_MD_RAID_RESHAPE config option.
      md/raid5: minor code cleanups in make_request.
      md/raid5 revise rules for when to update metadata during reshape
      md/raid1 - don't assume newly allocated bvecs are initialised.

Nick Andrew (1):
      trivial: Fix misspelling of firmware

Nick Kossifidis (13):
      ath5k: Update EEPROM code
      ath5k: More EEPROM code updates
      ath5k: Minor QCU updates
      ath5k: PHY code cleanup
      ath5k: Update gain_F calibration code and add documentation
      ath5k: Update RF Buffer handling
      ath5k: Update initvals
      ath5k: Update reset code
      ath5k: Disable BMISS interrupts
      ath5k: Don't call reset on config_interface
      ath5k: Choose the right initvals for RF2425
      ath5k: Convert chip specific calibration data to a generic format
      ath5k: Add tx power calibration support

Nick Piggin (12):
      [XFS] remove old vmap cache
      [XFS] use scalable vmap API
      x86: optimise x86's do_page_fault (C entry point for the page fault=
 path)
      x86: make UV support configurable
      lockdep: annotate reclaim context (__GFP_NOFS)
      generic IPI: simplify barriers and locking
      powerpc: Estimate G5 cpufreq transition latency
      slob: fix lockup in slob_free()
      fs: move bdev code out of buffer.c
      fs: avoid I_NEW inodes
      mm: page_mkwrite change prototype to match fault
      fs: fix page_mkwrite error cases in core code and btrfs

Nicola Soranzo (2):
      V4L/DVB (10525): em28xx: Coding style fixes and a typo correction
      V4L/DVB (10555): em28xx: CodingStyle fixes

Nicolas Pitre (24):
      Merge branch 'for-np' of git://git.wormnet.eu/alex/ts78xx into orio=
n/master
      [ARM] Orion: make gpio /input/output validation separate
      [ARM] Kirkwood: MPP initialization code
      [ARM] Kirkwood: SDIO driver registration for DB6281 and RD6281
      [ARM] Kirkwood: add NAND support to the DB88F6281 board
      [ARM] Kirkwood: remove unneeded includes from board setup files
      [ARM] Kirkwood: register internal devices in a common place
      [ARM] fixmap support
      [ARM] kmap support
      [ARM] mem_init(): make highmem pages available for use
      highmem: atomic highmem kmap page pinning
      [ARM] introduce dma_cache_maint_page()
      [ARM] make page_to_dma() highmem aware
      [ARM] Feroceon: add highmem support to L2 cache handling code
      [ARM] xsc3: add highmem support to L2 cache handling code
      [ARM] ignore high memory with VIPT aliasing caches
      [ARM] add CONFIG_HIGHMEM option
      Merge commit '305b07680f' into orion/master
      [ARM] Kirkwood: SheevaPlug USB Power Enable setup
      [ARM] Kirkwood: SheevaPlug LED support
      [ARM] Kirkwood: update defconfig
      [ARM] update mach-types
      [ARM] Kirkwood: fail the probe if internal RTC does not work
      [ARM] Kirkwood: small L2 code cleanup

Niels de Vos (1):
      trivial: MTD: remove EOL from MODULE_DESCRIPTION

Nikanth Karthikesan (4):
      loop: support barrier writes
      loop: fix circular locking in loop_clr_fd()
      vfs: check bh->b_blocknr only if BH_Mapped is set
      Update /debug/tracing/README

Nobuhiro Iwamatsu (10):
      sh: multiple vectors per irq - sh7763
      sh: Restore RTC IRQ setting for SH7763 setup.
      sh: dma-sh updates for multi IRQ and new SH-4A CPUs.
      sh: Revert CONFIG_NR_ONCHIP_DMA_CHANNELS to MAX_DMA_CHANNELS
      sh: Disable get_dma_error_irq for non-SH4 targets.
      sh: Fix compile error by operands(mov.l) in sh3/entry.S
      sh: Move IRQ multi definition of DMAC to defconfig
      sh: espt-giga board support
      sh: sh7763rdp: Change IRQ number for sh_eth of sh7763rdp
      sh: Add MMU dependency for kexec

N=C3=A9meth M=C3=A1rton (1):
      leds: remove experimental flag from leds-clevo-mail

Octavian Purdila (2):
      powerpc/oprofile: G4 oprofile has variable number of counters
      powerpc/oprofile: Enable support for ppc750 processors

Old=C5=99ich Jedli=C4=8Dka (1):
      V4L/DVB (10632): Added support for AVerMedia Cardbus Hybrid remote =
control

Oleg Nesterov (22):
      posix timers: fix RLIMIT_CPU && fork()
      get_mm_hiwater_xxx: trivial, s/define/inline/
      do_wait: fix waiting for the group stop with the dead leader
      signals: remove 'handler' parameter to tracehook functions
      signals: protect init from unwanted signals more
      ptrace: kill __ptrace_detach(), fix ->exit_state check
      ptrace: simplify ptrace_exit()->ignoring_children() path
      ptrace: reintroduce __ptrace_detach() as a callee of ptrace_exit()
      ptrace: fix possible zombie leak on PTRACE_DETACH
      reparent_thread: don't call kill_orphaned_pgrp() if task_detached()
      reparent_thread: fix the "is it traced" check
      reparent_thread: fix a zombie leak if /sbin/init ignores SIGCHLD
      forget_original_parent: split out the un-ptrace part
      forget_original_parent: do not abuse child->ptrace_entry
      tracehook_notify_death: use task_detached() helper
      ptrace_detach: the wrong wakeup breaks the ERESTARTxxx logic
      ptrace_untrace: fix the SIGNAL_STOP_STOPPED check
      pids: document task_pgrp/task_session is not safe without tasklist/=
rcu
      pids: improve get_task_pid() to fix the unsafe sys_wait4()->task_pg=
rp()
      pids: refactor vnr/nr_ns helpers to make them safe
      pids: kill signal_struct-> __pgrp/__session and friends
      exit_notify: kill the wrong capable(CAP_KILL) check

Olga Kornievskaia (1):
      svcrpc: take advantage of tcp autotuning

Oliver Endriss (1):
      V4L/DVB (10843): saa7146: Clean-up i2c error handling

Oliver Neukum (11):
      USB: suspend/resume support for option driver
      USB: suspend/resume for opticon driver
      USB: serial: introduce a flag into the usb serial layer to tell dri=
vers that their URBs are killed due to suspension
      USB: serial generic resume function fix
      USB: serial: export symbol of usb_serial_generic_resume
      USB: serial: use generic method if no alternative is provided in us=
b serial layer
      USB: serial: remove recourse to generic method
      HID: autosuspend support for USB HID
      HID: fix USB HID devices after STD with autosuspend
      HID: autosuspend -- fix lockup of hid on reset
      HID: fix race between usb_register_dev() and hiddev_open()

Or Gerlitz (1):
      IB/iser: Remove hard setting of path MTU

Oskar Schirmer (3):
      xtensa: enforce slab alignment to maximum register width
      xtensa: add flat support
      i2c: xtensa s6000 i2c driver

Owain G. Ainsworth (2):
      i915/drm: Remove two redundant agp_chipset_flushes
      i915/drm: Remove two redundant agp_chipset_flushes

Oystein Svendsen (1):
      Staging: comedi: add das6402 driver

PJ Waskiewicz (13):
      ixgbe: Add hardware specific initialization code for 82599 devices
      ixgbe: Add DCB for 82599, remove BCN support
      ixgbe: Add 82599 device id's, hook it up into the main driver.
      ixgbe: Fix get_supported_physical_layer() due to new 82599 PHY type=
s
      ixgbe: Fix an accounting problem when the Rx FIFO is full
      ixgbe: Disable DROP_EN for Rx queues
      ixgbe: Two small fixes for 82599 when bringing the device down and =
for WoL
      ixgbe: Add documentation for the driver
      ixgbe: Fix PCI bus reporting on driver load for 82598 after 82599 m=
erge
      ixgbe: Correctly report Wake On LAN for 82599 KX4 devices
      ixgbe: Allow Priority Flow Control settings to survive a device res=
et
      ixgbe: Fix DCB netlink layer for 82599 to enable Priority Flow Cont=
rol
      ixgbe: Fix 82598 MSI-X allocation on systems with more than 8 CPU c=
ores

Pablo Mejia (1):
      Staging: comedi: add aio_aio12_8 driver

Pablo Neira Ayuso (12):
      netlink: change return-value logic of netlink_broadcast()
      netlink: add NETLINK_BROADCAST_ERROR socket option
      netfilter: nf_conntrack: account packets drop by tcp_packet()
      netlink: change nlmsg_notify() return value logic
      netfilter: conntrack: increase drop stats if sequence adjustment fa=
ils
      netfilter: ctnetlink: cleanup master conntrack assignation
      netfilter: ctnetlink: cleanup conntrack update preliminary checking=
s
      netfilter: ctnetlink: move event reporting for new entries outside =
the lock
      netfilter: xtables: add cluster match
      nefilter: nfnetlink: add nfnetlink_set_err and use it in ctnetlink
      netlink: add NETLINK_NO_ENOBUFS socket flag
      netfilter: xtables: fix IPv6 dependency in the cluster match

Pallipadi, Venkatesh (4):
      VM, x86, PAT: Change is_linear_pfn_mapping to not use vm_pgoff
      VM, x86, PAT: add a new vm flag to track full pfnmap at mmap
      x86, PAT, PCI: Change vma prot in pci_mmap to reflect inherited pro=
t
      ACPI: cap off P-state transition latency from buggy BIOSes

Pascal Terjan (1):
      V4L/DVB (10825): Add ids for Yuan PD378S DVB adapter

Pascal de Bruijn (1):
      ALSA: hda - Add function id to proc output

Pat Erley (1):
      Add mesh point functionality to ath9k

Patrick Boettcher (2):
      V4L/DVB (11284): Fix i2c code of flexcop-driver for rare revisions
      V4L/DVB (11285): Remove unecessary udelay

Patrick McHardy (3):
      netfilter: ctnetlink: fix rcu context imbalance
      netfilter: fix xt_LED build failure
      netfilter: {ip,ip6,arp}_tables: fix incorrect loop detection

Patrick Ohly (11):
      clocksource: allow usage independent of timekeeping.c
      timecompare: generic infrastructure to map between two time bases
      net: new user space API for time stamping of incoming and outgoing =
packets
      net: infrastructure for hardware time stamping
      net: socket infrastructure for SO_TIMESTAMPING
      ip: support for TX timestamps on UDP and RAW sockets
      net: pass new SIOCSHWTSTAMP through to device drivers
      igb: access to NIC time
      igb: stub support for SIOCSHWTSTAMP
      igb: use timecompare to implement hardware time stamping
      net: kernel panic in dev_hard_start_xmit: remove faulty software TX=
 time stamping

Paul Bolle (1):
      gigaset: return -ENOTTY for unimplemented functions

Paul Collins (1):
      HID: constify arrays of struct apple_key_translation

Paul Fertser (1):
      ASoC: Fix WM8753 DAIs unregistering

Paul Fulghum (1):
      synclink_gt: add clock options

Paul Mackerras (2):
      Merge branch 'next' of master.kernel.org:/pub/scm/linux/kernel/git/=
galak/powerpc into merge
      powerpc: Fix oops when loading modules

Paul Menage (2):
      cgroups: fix cgroup.h comments
      cpusets: allow cpusets to be configured/built on non-SMP systems

Paul Moore (6):
      lsm: Relocate the IPv4 security_inet_conn_request() hooks
      netlabel: Label incoming TCP connections correctly in SELinux
      selinux: Remove the "compat_net" compatibility code
      lsm: Remove the socket_post_accept() hook
      netlabel: Cleanup the Smack/NetLabel code to fix incoming TCP conne=
ctions
      audit: Fix possible return value truncation in audit_get_context()

Paul Mundt (46):
      sh: Fix up GENERIC_GPIO build for ARCH_WANT_OPTIONAL_GPIO cases.
      sh: mach-highlander and mach-rsk require gpiolib.
      Merge branch 'sh/stable-updates'
      sh: Use SYS_SUPPORTS_CMT for managing CMT timer dependencies.
      sh: Fix up MTU2 support for SH7203.
      sh: Don't enable GENERIC_TIME for the CMT clockevent driver yet.
      sh: Restrict old CMT timer code to SH-2/SH-2A.
      Merge branch 'sh/stable-updates'
      sh: Disable unsupportable prefetching on SH-3.
      sh: Fix up SH-X3 general exception handler build.
      sh: SH7786 is an SH-X3 core, select CPU_SHX3.
      sh: Set a sensible default for the SH7786 pclk.
      sh: intc: Make missing unique IRQ mask warning more verbose.
      sh: multiple vectors per irq - sh7203.
      sh: multiple vectors per irq - sh7263.
      sh: multiple vectors per irq - sh7201.
      sh: multiple vectors per irq - sh7206.
      rtc: rtc-sh: Bump version up to reflect single IRQ support changes.
      sh: multiple vectors per irq - sh7619.
      sh: multiple vectors per irq - mxg.
      sh: multiple vectors per irq - sh770x.
      sh: multiple vectors per irq - sh7705.
      sh: multiple vectors per irq - sh7710.
      sh: multiple vectors per irq - sh7720.
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6
      Merge branch 'sh/stable-updates'
      sh: Define ARCH_SHMOBILE for SH-Mobile CPUs.
      sh: Generate uImage by default on Urquell board.
      sh: Consolidate SH-Mobile CPU code in arch/sh/kernel/cpu/shmobile/.
      sh: dma: Make PVR2 DMA configurable.
      sh: dma: Make G2 DMA configurable.
      sh: Support for extended ASIDs on PTEAEX-capable SH-X3 cores.
      sh: tlb-pteaex: Kill off legacy PTEA updates.
      sh: Update debugfs ASID dumping for 16-bit ASID support.
      sh: Flush only the needed range when unmapping a VMA.
      sh: kexec: Drop SR.BL bit toggling.
      sh: kexec jump: fix for ftrace.
      sh: Fix up -Wformat-security whining.
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6
      sh: migor: Fix up CEU use flags.
      sh: Select ARCH_HIBERNATION_POSSIBLE.
      sh: Add a command line option for disabling I/O trapping.
      sh: Wire up ARCH_HAS_DEFAULT_IDLE for cpuidle.
      sh: Kill off broken direct-mapped cache mode.
      sh: update defconfigs.
      sh: Fix up number of on-chip DMA channels on SH7091.

Paul Walmsley (35):
      [ARM] OMAP2/3: Add non-CORE DPLL rate set code and M, N programming
      [ARM] OMAP: Fix sparse, checkpatch warnings in OMAP2/3 PRCM/PM code
      [ARM] OMAP24xx clock: add missing SSI L4 interface clock
      [ARM] OMAP3: move USBHOST SAR handling from clock framework to powe=
rdomain layer
      [ARM] OMAP3 clock: fix 96MHz clocks
      [ARM] OMAP: Make dpll4_m4_ck programmable with clk_set_rate()
      [ARM] OMAP2/3 clockdomains: combine pwrdm, pwrdm_name into union in=
 struct clockdomain
      [ARM] OMAP2/3 clockdomains: add CM and PRM clkdms
      [ARM] OMAP3 clock: move sys_clkout2 clk to core_clkdm
      [ARM] OMAP3 PRCM: add DPLL1-5 powerdomains, clockdomains; mark cloc=
ks
      [ARM] OMAP3 powerdomains: remove RET from SGX power states list
      [ARM] OMAP2/3 clockdomains: autodeps should respect platform flags
      [ARM] OMAP3 clock: fix DPLL jitter correction and rate programming
      [ARM] OMAP3 clock: DPLL{1,2}_FCLK clksel can divide by 4
      [ARM] OMAP3 clock: convert dpll_data.idlest_bit to idlest_mask
      [ARM] OMAP3 clock: remove unnecessary dpll_data dereferences
      [ARM] OMAP3 clock: optimize DPLL rate rounding algorithm
      [ARM] OMAP3 clock: avoid invalid FREQSEL values during DPLL rate ro=
unding
      [ARM] OMAP3 clock: disable DPLL autoidle while waiting for DPLL to =
lock
      [ARM] OMAP2/3 clock: clean up mach-omap2/clock.c
      [ARM] OMAP2 PRCM: clean up CM_IDLEST bits
      [ARM] OMAP2 SDRC: move mach-omap2/memory.h into mach/sdrc.h
      [ARM] OMAP2 SDRC: rename memory.c to sdrc2xxx.c
      [ARM] OMAP2 SDRC: separate common OMAP2/3 code from OMAP2xxx code
      [ARM] OMAP2 SDRC: add SDRAM timing parameter infrastructure
      [ARM] OMAP3 clock: add omap3_core_dpll_m2_set_rate()
      [ARM] OMAP2/3 clock: use standard set_rate fn in omap2_clk_arch_ini=
t()
      [ARM] OMAP2/3 clock: don't use a barrier after clk_disable()
      [ARM] OMAP2xxx clock: consolidate DELAYED_APP clock commits; fix ba=
rrier
      [ARM] OMAP2/3 clock: convert remaining MPU barriers into OCP barrie=
rs
      [ARM] OMAP clock: drop clk_get_usecount()
      [ARM] OMAP2/3 clock: don't tinker with hardirqs when they are suppo=
sed to be disabled
      [ARM] OMAP3: update ES level flags to discriminate between post-ES2=
 revisions
      [ARM] OMAP3 powerdomains: make USBTLL SAR only available on ES3.1 a=
nd beyond
      [ARM] 5422/1: ARM: MMU: add a Non-cacheable Normal executable memor=
y type

Paulius Zaleckas (12):
      ppp_generic: Simplify tx_dropped stats
      hso: remove claiming and releasing of USB interface
      hso: remove hso_free_device()
      ARM: tlbflush.h: introduce TLB_BTB flag
      ARM: Add support for FA526 v2
      MAINTAINERS: Add myself as Faraday ARM core variant maintainer
      ARM: Add Gemini architecture v3
      MAINTAINERS: add myself as Gemini architecture maintainer
      Gemini: gpiolib based GPIO support v2
      Gemini: Add support for Teltonika RUT100
      [ARM] 5437/1: Add documentation for "nohlt" kernel parameter
      V4L/DVB (11350): Add camera (CSI) driver for MX1

Pavel Machek (7):
      HID: make HID_DEBUG defaults consistent
      trivial: document ext3 semantics of 'ro' option a bit better
      hp_accel: small documentation updates
      hp_accel: adev is poor name of exported symbol
      hp_accel: add two more axis information
      nbd: add locking to nbd_ioctl
      nbd: trivial cleanups

Pavel Roskin (1):
      bmac: remove unused variable bp in bmac_misc_intr()

Pekka Enberg (61):
      kmemtrace: remove unnecessary casts
      kmemtrace: allow kmemtrace to be enabled after boot
      kmemtrace: remove config option for enabling tracing at boot
      SLUB: Use ->objsize from struct kmem_cache_cpu in slab_free()
      ext4: allocate ->s_blockgroup_lock separately
      SLUB: Do not pass 8k objects through to the page allocator
      x86: move __VMALLOC_RESERVE to pgtable_32.c
      x86: use roundup() instead of PAGE_ALIGN() in find_early_table_spac=
e()
      x86: add sanity checks to init_32.c
      x86: make sure initmem is writable on 64-bit
      x86: unify free_init_pages() and free_initmem()
      x86: set_highmem_pages_init() cleanup
      x86: move devmem_is_allowed() to common mm/init.c
      x86: set_highmem_pages_init() cleanup, #2
      x86: move free_initrd_mem() to common mm/init.c
      x86: init_memory_mapping() trivial cleanups
      x86: add gbpages support to 32-bit init_memory_mapping()
      x86: find_early_table_space() unification
      x86: move pgd_base out of init_memory_mapping()
      x86: ifdef 32-bit specific setup in init_memory_mapping()
      x86: remove unnecessary save_mr() sanity check
      x86: rename after_init_bootmem to after_bootmem in mm/init_32.c
      x86: unify kernel_physical_mapping_init() call in init_memory_mappi=
ng()
      x86: add table start and end sanity checks to 32-bit init_memory_ma=
pping()
      x86: ifdef 32-bit and 64-bit setup in init_memory_mapping()
      x86: ifdef 32-bit and 64-bit pfn setup in init_memory_mapping()
      x86: ifdef 32-bit and 64-bit NR_RANGE_MR for save_mr() unification
      x86: add stub init_gbpages() for 32-bit init_memory_mapping()
      x86: move init_memory_mapping() to common mm/init.c
      x86: fix up some bad global variable names in mm/init.c
      x86: unify kernel_physical_mapping_init() function signatures
      x86: move function and variable declarations to asm/init.h
      x86: fix uninitialized variable in init_memory_mapping()
      x86: rename do_not_nx to disable_nx in mm/init_64.c
      Merge branches 'topic/slob/cleanups', 'topic/slob/fixes', 'topic/sl=
ub/core', 'topic/slub/cleanups' and 'topic/slub/perf' into for-linus
      Remove struct typedefs from fs/udf/ecma_167.h et al.
      Fix the udf code not to pass structs on stack where possible.
      kmemtrace, fs, security: move alloc_secdata() and free_secdata() to=
 linux/security.h
      kmemtrace, security: fix linux/key.h header file dependencies
      kmemtrace, befs: fix slab.h dependency problem
      kmemtrace, squashfs: fix slab.h dependency problem in squasfs
      kmemtrace, kbuild: fix slab.h dependency problem in lib/decompress_=
inflate.c
      kmemtrace, kbuild: fix slab.h dependency problem in lib/decompress_=
bunzip2.c
      kmemtrace, kbuild: fix slab.h dependency problem in lib/decompress_=
unlzma.c
      kmemtrace, mm: fix slab.h dependency problem in mm/failslab.c
      kmemtrace: trace kfree() calls with NULL or zero-length objects
      Staging: w35und: remove unused header files
      Staging: w35und: remove unnecessary os_common.h header file
      Staging: w35und: remove crazy commented out includes
      Staging: w35und: unify mto.h and mto_f.h header files
      Staging: w35und: convert code to use ETH_ALEN
      Staging: w35und: remove useless macro from common.h
      Staging: w35und: kill WBDEBUG and remove common.h header file
      Staging: w35und: typedef removal
      Staging: w35und: remove hw_data_t typedef
      Staging: w35und: Remove MTO_FUNC_INPUT macro obfuscation
      Staging: w35und: remove unused bssdscpt.h header
      Staging: w35und: remove ds_tkip.h header
      Staging: w35und: remove gl_80211.h header
      Staging: rt2860: remove kernel version compatibility wrappers
      nilfs2: clean up indirect function calling conventions

Pekka Paalanen (3):
      doc: mmiotrace.txt, buffer size control change
      trace: mmiotrace to the tracer menu in Kconfig
      mmiotrace: count events lost due to not recording

Perry J. Piplani (1):
      Staging: comedi: add dmm32at driver

Pete Wyckoff (1):
      [SCSI] iscsi tcp: bidi capable

Pete Zaitcev (2):
      usblp: continuously poll for status
      USB: usbmon: Add binary API v1

Peter Korsgaard (1):
      powerpc: convert dts-bindings/fsl/dma.txt to dts-v1 syntax

Peter Ma (2):
      avr32: add RTS/CTS/CLK pin selection for the USARTs
      avr32: add hardware handshake support to atmel_serial

Peter Oberparleiter (2):
      [S390] cio: incorrect status check in interrogate function
      [S390] cio: prevent workqueue deadlock

Peter P Waskiewicz Jr (8):
      ixgbe: Refactor MSI-X allocation mechanism
      ixgbe: Update copyright dates, bump the driver version number
      ixgbe: Refactor set_num_queues() and cache_ring_register()
      ixgbe: Update link setup code to better support autonegotiation of =
speed
      ixgbe: Display EEPROM version in ethtool -i queries
      ixgbe: Update flow control state machine in link setup
      ixgbe: Defeature Tx Head writeback
      ixgbe: Fix a set_num_queues() bug that can result in num_(r|t)x_que=
ues =3D 0

Peter Teoh (1):
      Staging: rt2870: Removal of kernel_thread() API

Peter Ujfalusi (12):
      ASoC: TWL4030: Syncronize the reg_cache for ANAMICL after the offse=
t cancelation
      ASoC: TWL4030: Code clean up for codec power up and down
      ASoC: TWL4030: Enable Headset Left anti-pop/bias ramp only if the H=
eadset Left is in use
      ASoC: TWL4030: Physical ADC and amplifier power switch change
      ASoC: TWL4030: Move the twl4030_power_up and _power_down function
      ASoC: TWL4030: Add analog loopback support
      ASoC: TWL4030: Add digital loopback support
      ASoC: TWL4030: Make the HS ramp delay configurable
      ASoC: TWL4030: 96KHz playback support
      ASoC: TWL4030: Add constrains for second stream
      ASoC: TWL4030: Add actual support for 96KHz playback support
      ASoC: TWL4030: Compillation error fix

Peter W Morreale (2):
      mm: fix pdflush thread creation upper bound
      mm: add /proc controls for pdflush threads

Peter Zijlstra (48):
      mutex: small cleanup
      mutex: preemption fixes
      mutex: implement adaptive spinning
      sched: introduce avg_wakeup
      sched: prefer wakers
      sched: make plist a library facility
      x86: cpu_init(): remove ugly #ifdef construct around debug register=
 clear
      x86: add might_sleep() to do_page_fault()
      lockdep: sanitize bit names
      lockdep: sanitize reclaim bit names
      lockdep: lockdep_states.h
      lockdep: simplify mark_held_locks
      lockdep: simplify mark_lock()
      lockdep: move state bit definitions around
      lockdep: generate the state bit definitions
      lockdep: generate usage strings
      lockdep: split up mark_lock_irq()
      lockdep: simplify the mark_lock_irq() helpers
      lockdep: further simplify mark_lock_irq() helpers
      lockdep: simplify mark_lock_irq() helpers #3
      lockdep: merge the _READ mark_lock_irq() helpers
      lockdep: merge the !_READ mark_lock_irq() helpers
      lockdep: fully reduce mark_lock_irq()
      lockdep: remove macro usage from mark_held_locks()
      lockdep: add comments to mark_lock_irq()
      lockdep: simplify get_user_chars()
      lockdep: get_user_chars() redo
      lockdep: simplify check_prev_add_irq()
      lockdep: use stringify.h
      lockstat: warn about disabled lock debugging
      lockdep: build fix for !PROVE_LOCKING
      generic-ipi: remove kmalloc()
      generic-ipi: remove CSD_FLAG_WAIT
      x86: make vmap yell louder when it is used under irqs_disabled()
      sched_clock: cleanups
      genirq: assert that irq handlers are indeed running in hardirq cont=
ext
      lockdep: fix incorrect state name
      lockdep: remove extra "irq" string
      lockdep: require framepointers for x86
      tracing: add lockdep tracepoints for lock acquire/release
      sched: optimize ttwu vs group scheduling
      trace_clock: fix preemption bug
      ftrace: provide an id file for each event
      ftrace: ensure every event gets an id
      ftrace: event profile hooks
      lockdep: fix deadlock in lockdep_trace_alloc
      hrtimer: fix rq->lock inversion (again)
      lockdep: add stack dumps to asserts

Petros Koutoupis (2):
      block: genhd.h comment needs updating
      block: genhd.h cleanup patch

Phil Sutter (7):
      pata-rb532-cf: replace rb532_pata_finish_io()
      pata-rb532-cf: use ata_sff_exec_command()
      pata-rb532-cf: use ata_sff_data_xfer32()
      pata-rb532-cf: drop custom freeze and thaw
      [WATCHDOG] rc32434_wdt: clean-up driver
      [WATCHDOG] rc32434_wdt: add timeout module parameter
      leds: Add rb532 LED driver for the User LED

Philipp Zabel (30):
      [ARM] pxa/magician: Update defconfig
      [ARM] pxa/magician: Enable backlight
      [ARM] pxa/magician: setup SSP1 pins for audio
      [ARM] pxa/magician: enable power I2C for max158xx
      [ARM] pxa/magician: Use SZ_64M for physmap resource
      [ARM] pxa/magician: use named initializers for gpio_keys setup
      [ARM] pxa/magician: Enable pxa27x_udc and gpio_vbus
      ASoC: uda1380: split set_dai_fmt into _both, _playback and _capture=
 variants
      ASoC: pxa-ssp: fix SSP port request
      pxa/h5000: Setup I2S pins for pxa2xx-i2s
      pxa/spitz: Setup I2S pins for pxa2xx-i2s
      ASoC: pxa2xx-i2s: remove I2S pin setup
      ASoC: Remove version display from the UDA1380 driver
      ASoC: UDA1380: change decimator/interpolator register handling
      ASoC: Use network mode with 2 slots for 16-bit stereo in pxa-ssp/Zy=
lonite
      ASoC: UDA1380: DATAI is slave only
      [ARM] pxa/magician: fix htc-egpio resource size
      [ARM] pxa/magician: select PXA_SSP for touchscreen and sound
      [ARM] pxa/magician: register pda_power IRQs as rising/falling edge
      [ARM] pxa/magician: default to backlight trigger for keypad illumin=
ation
      [ARM] pxa/magician: remove unused forward declaration of pasic3
      ASoC: Replace remaining uses of snd_soc_cnew with snd_soc_add_contr=
ols.
      ASoC: pxa-ssp: Use 16-bit DMA for magician stereo
      ASoC: Add Magician machine support
      mfd: convert DS1WM to use MFD core
      mfd: convert PASIC3 to use MFD core
      pxa/magician: remove deprecated .bus_shift from PASIC3 platform_dat=
a
      mfd: remove unused PASIC3 bus_shift field
      mfd: remove DS1WM clock handling
      mfd: PASIC3: supply clock_rate to DS1WM via driver_data

Philippe De Muyter (1):
      parport: netmos 9845 & 9855 1P4S fixes

Philippe R=C3=A9tornaz (1):
      V4L/DVB (11035): mt9t031 bugfix

Pierre Ossman (6):
      sdio: handle cis end marker in link field
      sdio: handle null tuples
      sdio: check that addresses are within the address space
      sdhci: change list address
      mmc: add maintainer for mvsdio driver
      tmio_mmc: add maintainer

Qinghuang Feng (2):
      NFSD: cleanup for nfs3proc.c
      SYSFS: use standard magic.h for sysfs

Rafael Ignacio Zurita (1):
      sh: fix the HD64461 level-triggered interrupts handling

Rafael J. Wysocki (23):
      PCI: PCIe portdrv: Use driver data to simplify code
      PCI: PCIe portdrv: Aviod using service devices with wrong interrupt=
s
      PCI: PCIe portdrv: Do not enable port device before setting up inte=
rrupts
      PCI: PCIe portdrv: Remove unnecessary function
      PCI: PCIe portdrv: Simplily probe callback of service drivers
      PCI: PCIe portdrv: Remove struct pcie_port_service_id
      PCI/MSI: Introduce pci_msix_table_size()
      PCI/PCIe portdrv: Fix allocation of interrupts
      PCI: PCIe portdrv: Implement pm object
      PM: Introduce functions for suspending and resuming device interrup=
ts
      PM: Rework handling of interrupts during suspend-resume
      PM: Change suspend code ordering
      PM: Change hibernation code ordering
      kexec: Change kexec jump code ordering
      PCI PM: Use pci_set_power_state during early resume
      PCI PM: Move pci_restore_standard_config to pci-driver.c
      PCI PM: Put devices into low power states during late suspend (rev.=
 2)
      PCI PM: Make pci_set_power_state() handle devices with no PM suppor=
t
      PCI PM: Restore config spaces of all devices during early resume
      PCI PM: Introduce __pci_[start|complete]_power_transition() (rev. 2=
)
      radeonfb: Use __pci_complete_power_transition()
      PCI PM: Make pci_prepare_to_sleep() disable wake-up if needed
      net/igb: Fix kexec with igb (rev. 3)

Rajiv Andrade (3):
      TPM: sysfs functions consolidation
      TPM: integrity interface
      TPM: integrity fix

Rakib Mullick (1):
      tracing: fix section mismatch in trace_hw_branches.c

Ralf Baechle (10):
      MIPS: Change {set,clear,change}_c0_<foo> to return old value.
      Fix build error in <linux/irq.h>
      MIPS: Forward declare struct task_struct to avoid potencial warning.
      MIPS: Compat: Zero upper 32-bit of offset_high and offset_low.
      MIPS: Makefile: Add simple make install target.
      MIPS: Cavium: Add -Werror
      MIPS: Stop using <asm-generic/int-l64.h>.
      MIPS: Enable GENERIC_HARDIRQS_NO__DO_IRQ for all platforms
      MIPS: Use BUG_ON() where possible.
      preadv/pwritev: MIPS: Add preadv(2) and pwritev(2) syscalls.

Ralph Campbell (3):
      IB/mad: Fix null pointer dereference in local_completions()
      IB/mad: initialize mad_agent_priv before putting on lists
      IB/mad: Fix ib_post_send_mad() returning 0 with no generate send co=
mp

Ramachandra K (1):
      IB/mad: Fix RMPP header RRespTime manipulation

Rami Rosen (10):
      mac80211: remove an unnecessary assignment to info in __ieee80211_t=
x().
      mac80211: remove an unused parameter in ieee80211_rx_mgmt_probe_req=
().
      mac80211: remove an unused definition (MAX_STA_COUNT) in sta_info.h.
      mac80211: remove unused variable in ieee80211_local (dot11WEPUndecr=
yptableCount).
      mac80211: remove mesh_plink_close() method.
      mac80211: trivial documentation fixes (enum mesh_path_flags).
      mac80211: trivial documentation fix (mesh_nexthop_lookup()).
      tcp: remove parameter from tcp_recv_urg().
      net: core: remove unneeded include in net/core/utils.c.
      ipv4: remove unused parameter from tcp_recv_urg().

Ramkrishna Vepa (9):
      Neterion: Driver help file
      Neterion: New driver: Update Maintainer list
      Neterion: New driver: register set - vxge-reg.h
      Neterion: New driver: Hardware init & configuration
      Neterion: New driver: Traffic & alarm handler
      Neterion: New driver: Main entry points
      Neterion: New driver: Ethtool related
      Neterion: New driver: Driver version
      Neterion: New driver: Kconfig and Makefile

Randy Dunlap (52):
      sysrq: fix ftrace help msg & doc.
      kmemtrace: fix printk format warnings
      kmemtrace: fix printk formats, fix
      jfs: needs crc32_le
      x86: UV: fix header struct usage
      ima: fix build error
      smack: fix lots of kernel-doc notation
      wireless: fix for CONFIG_NL80211=3Dn
      skbuff.h: fix timestamps kernel-doc
      rds: fix iband RDMA dependencies
      ALSA: Move ALSA docbooks to be with the rest of the kernel docbooks
      wimax: fix i2400m printk formats
      [SCSI] scsi_sysfs: delete extra kernel-doc
      [SCSI] scsi_debug: needs CRC_T10DIF
      [SCSI] libfc: needs CRC32
      USB: fix ehci printk formats
      skbuff.h: fix missing kernel-doc
      maple: fix Error in kernel-doc notation
      sched: fix errors in struct & function comments
      V4L/DVB (10631): zoran: fix printk format
      V4L/DVB (10830): dm1105: uses ir_* functions, select VIDEO_IR
      V4L/DVB (10846): dvb/frontends: fix duplicate 'debug' symbol
      V4L/DVB (11237): media/zoran: fix printk format
      proc: move fs/proc/inode-alloc.txt comment into a source file
      dma-debug: fix printk formats (i386)
      regulator: fix header file missing kernel-doc
      alpha: convert u64 to unsigned long long
      atyfb: fix header file trailing whitespace
      [IA64] Fix typo/thinko in arch/ia64/sn/kernel/sn2/sn2_smp.c
      Staging: sxg: fix napi interface build
      Staging: altera: fix printk format warnings
      Staging: mimio: depends on INPUT
      Staging: otus: fix mixed declarations
      Staging: android: binder: fix printk format warnings
      Staging: android: ram_console: fix printk format warning
      Staging: Android: fix more printk formats
      Staging: rtl8187se: fix printk format warnings
      Staging: rt2860: fix printk format warnings
      Staging: pohmelfs: fix kconfig dependencies
      Staging: stlc45xx: fix printk format warnings
      Staging: phison: fix kconfig for clean build
      Staging: phison: depends on PCI
      Staging: p9auth: fix dependency/build error
      Staging: line6: depends on SND
      Staging: line6: fix build error, select SND_RAWMIDI
      auditsc: fix kernel-doc notation
      PCI-IOV: fix missing kernel-doc
      docbook: fix fatal filename error
      docs: alphabetize entries in kernel-parameters.txt
      V4L/DVB (11439): UVC: uvc_status_cleanup(): undefined reference to =
`input_unregister_device'
      V4L/DVB (11440): PWC: fix build error when CONFIG_INPUT=3Dm
      esp: fix section mismatch warning

Ravikiran G Thirumalai (5):
      x86: cleanup, rename CONFIG_X86_NON_STANDARD to CONFIG_X86_EXTENDED=
_PLATFORM
      x86: improve the help text of X86_EXTENDED_PLATFORM
      Revert "x86: don't compile vsmp_64 for 32bit"
      mm: fix SHM_HUGETLB to work with users in hugetlb_shm_group
      mm: reintroduce and deprecate rlimit based access for SHM_HUGETLB

Reinette Chatre (9):
      iwlwifi: update copyright year to 2009
      iwlwifi: fix FAT channel config for 5000 series
      iwlwifi: use singlethread workqueue
      iwlwifi: Fix and rework Kconfig file
      iwlwifi: fix *pci_probe error flow
      iwl3945: unmap previously mapped memory
      iwlwifi: print contents of control register when error occurs
      iwlwifi: correct log level when error occurs
      cfg80211/nl80211: remove usage of CONFIG_NL80211

Reynes Philippe (3):
      powerpc/83xx: Add i2c eeprom to dts for MPC837x RDB
      powerpc/83xx: Add gpio to MPC837x RDB
      powerpc/83xx: Add lm75 to MPC837x RDB dts

Richard Bytheway (1):
      Staging: comedi: add cb_pcimdas driver

Richard Kennedy (3):
      ipv6: reorder struct inet6_ifaddr to remove padding on 64 bit build=
s
      drm: reorder struct drm_ioctl_desc to save space on 64 bit builds
      Staging: wlan-ng: block ioctls until card fully initialised

Richard Purdie (2):
      leds: Fix leds-gpio driver multiple module_init/exit usage
      leds: Add suspend/resume state flags to leds-gpio

Richard Walmsley (1):
      HID: DragonRise game controller force feedback driver

Rick Farrington (1):
      iwlagn: reduce off channel reception for 4965

Riku Voipio (3):
      [ARM] mv78xx0: wire i2c support
      trivial: Update my email address
      leds: Fix &&/|| confusion in leds-pca9532.c

Risto Suominen (5):
      ALSA: powermac - Correct HP detection and input selectors for PMac =
5500
      ALSA: powermac - Correct volume controls for PowerBook G3 Lombard
      ALSA: powermac - Correct volume controls and HP detection for PMac =
8500/9500
      ALSA: powermac - Allow input from mic in iBook G3 Dual-USB
      ALSA: Add vmaster controls for Pmac 5500, iMac G3 SL, and PBook G3 =
Lombard

Robert Jarzmik (13):
      ASoC: Add initial support of Mitac mioa701 device SoC.
      [ARM] pxa/MioA701: add gpio_vbus driver
      [ARM] pxa/MioA701: Migrate after pxa27x_udc gpio_pullup functionali=
ty.
      ASoC: Allow choice of ac97 gpio reset line
      USB: gpio_vbus: add delayed vbus_session calls
      USB: pxa27x_udc: factor pullup code to prepare otg transceiver
      USB: pxa27x_udc: add vbus session handling
      USB: pxa27x_udc: add otg transceiver support
      USB: pxa27x_udc: add vbus_draw callback
      V4L/DVB (11319): pxa_camera: Enforce YUV422P frame sizes to be 16 m=
ultiples
      V4L/DVB (11320): pxa_camera: Remove YUV planar formats hole
      V4L/DVB (11321): pxa_camera: Redesign DMA handling
      V4L/DVB (11322): pxa_camera: Fix overrun condition on last buffer

Robert Krakora (3):
      V4L/DVB (10255): em28xx: Clock (XCLK) Cleanup
      V4L/DVB (10518): em28xx: Fix for em28xx memory leak and function re=
name
      V4L/DVB (10519): em28xx: Fix for em28xx audio startup

Robert Love (5):
      [SCSI] Improve SCSI_LOGGING Kconfig entry
      [SCSI] fcoe: Initialize all possilbe skb_queue(s) when module is lo=
aded
      [SCSI] fcoe: Use percpu kernel funcs for struct fcoe_percpu_s
      [SCSI] fcoe: Use per-CPU kernel function for dev_stats instead of a=
n array
      [SCSI] fcoe: create/destroy fcoe Rx threads on CPU hotplug events

Robert Millan (1):
      V4L/DVB (10944): Conceptronic CTVFMI2 PCI Id

Robert Richter (1):
      cpumask: modifiy oprofile initialization

Robert Schwebel (1):
      Staging: comedi: add ssv_dnp driver

Robin Getz (1):
      Blackfin arch: be less noisy when gets a gpio conflict after kernel=
 has booted

Robin Holt (5):
      sgi-gru: remove SGI_GRU as a valid config option for ia64 configs w=
ith SGI_UV
      xpc_sn2: fix max() warning about pointers of different types
      Factor out #ifdefs from kernel/spinlock.c to LOCK_CONTENDED_FLAGS
      Allow rwlocks to re-enable interrupts
      ia64: implement interrupt-enabling rwlocks

Roel Kluin (46):
      phylib: unsigneds go unnoticed
      SH: fix start_thread and user_stack_pointer macros
      ath5k: notice a negative keytype
      ASoC: count reaches 10001, not 10000.
      libertas: pos[4] tested twice, 2nd should be pos[5]
      sound: OSS: dmabuf: too many loops
      sound: OSS: &&/|| typo in ad1848.c
      sound: OSS: missing parentheses in pas2_card.c
      atm: Add missing parentheses
      wavelan: Test arraysize before an element of the array.
      p54: misplaced parentheses
      b43: Fix LO calibration txctl reg value
      wireless, wavelan: spin off by 1
      ALSA: snd-powermac: timeout reaches -1
      [SCSI] ses: code_set =3D=3D 1 is tested twice
      x25: '< 0' and '>=3D 0' test on unsigned
      tcp: '< 0' test on unsigned
      PCI hotplug: shpchp: fix bus number check to avoid false positive
      [JFFS2] jffs2_acl_count() tests < 0 on unsigned
      ctcm: avoid wraparound in length of incoming data
      USB: count reaches -1, tested 0
      USB: more u32 conversion after transfer_buffer_length and actual_le=
ngth
      i2c-algo-pcf: Style cleanups
      i2c-algo-pcf: Handle timeout correctly
      virtio: fix BAD_RING, START_US and END_USE macros
      V4L/DVB (10629): tvp514x: try_count reaches 0, not -1
      V4L/DVB: calibration still successful at 10
      V4L/DVB (10657): [PATCH] V4L: missing parentheses?
      hugetlb: chg cannot become less than 0
      alpha: fix macros
      rtc-wm8350: retries will reach -1
      rtc: test before subtraction on unsigned
      fbdev: newport: newport_*wait() return 0 on timeout
      drivers/video/omap/hwa742.c: div reaches max_clk_div
      arkfb: fix misplaced parentheses
      uvesafb: bitwise OR has higher precedence than ?:
      vesafb: bitwise OR has higher precedence than ?:
      viafb: returns 0 two too early
      hppfs: hppfs_read_file() may return -ERROR
      Staging: agnx: i reaches -1, tested 0
      Staging: meilhaus: unsigned won't get negative after subtraction
      Staging: otus: logical/bit and confusion
      Staging: rtl8187se: ! x & y problem in inactive code
      Staging: comedi: rtd520: &&/|| typo
      rio: addition has higher precedence than ?:
      spi: limit reaches -1, tested 0

Roland Dreier (6):
      IB/ipath: Fix memory leak in init_shadow_tids() error path
      IB/ipath: Really run work in ipath_release_user_pages_on_close()
      IB: Remove sysfs files before unregistering device
      IB: Remove useless ibdev_is_alive() tests from sysfs code
      Merge branches 'cxgb3', 'endian', 'ipath', 'ipoib', 'iser', 'mad', =
'misc', 'mlx4', 'mthca', 'nes' and 'sysfs' into for-next
      RDMA/nes: Fix mis-merge

Ron Mercer (33):
      qlge: Clean up mac address and frame route settings.
      qlge: Increase MAC addr hw sem granularity.
      qlge: Change frame route hw semaphore granularity.
      qlge: Optimize rx buffer refill process.
      qlge: Use one path to (re)fill rx buffers.
      qlge: Add defines for firmware support.
      qlge: Clean up firmware reset path.
      qlge: Move firmware event handler.
      qlge: Prepare to add new device.
      qlge: Reduce debug print output.
      qlge: Add support for firmware mailbox commands.
      qlge: Add support for device ID 8000.
      qlge: Add support for getting/setting port config.
      qlge: Add firmware support for insert/remove SFP.
      qlge: Clean up link down processing.
      qlge: Clean up link up processing.
      qlge: Add worker-handler for firmware events.
      qlge: Clean up event handler for firmware init.
      qlge: Improve handling for firmware init failure.
      qlge: Save status from firmware crash (system err).
      qlge: Add support for lost firmware events.
      qlge: Move reset logic into asic_reset_worker func.
      qlge: Remove debug junk from asic reset logic.
      qlge: Increase filtering for inbound csum settings.
      qlge: Add support for GRO.
      qlge: Add tx multiqueue support.
      qlge: bugfix: Tell hw to strip vlan header.
      qlge: Get rid of irqsave/restore in intr disable.
      qlge: Clear shadow registers before use.
      qlge: Remove spinlock from asic init path.
      qlge: bugfix: Move netif_napi_del() to common call point.
      qlge: bugfix: Pad outbound frames smaller than 60 bytes.
      qlge: bugfix: Fix endian issue related to rx buffers.

Russell King (87):
      [ARM] dma: remove dmach_t typedef
      [ARM] dma: factor out code looking up the DMA channel
      [ARM] dma: rejig DMA initialization
      [ARM] dma: move RiscPC specific DMA data out of dma_struct
      [ARM] dma: constify dma controller name and dma ops
      [ARM] dma: ensure that the single entry sg is properly initialized
      [ARM] dma: convert IOMD DMA to use sg_next()
      [ARM] dma: pata_icside's contiguous sg array is now redundant
      [ARM] dma: Use sensible DMA parameters for Acorn drivers
      [ARM] dma: make DMA_MODE_xxx reflect ISA DMA settings
      [ARM] dma: remove usage of dmamode_t from MXC platform support
      [ARM] dma: remove dmamode_t typedef
      [ARM] omap: remove VIRTUAL_CLOCK
      [ARM] omap: introduce clock operations structure
      Merge branch 'devel' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/ycmiao/pxa-linux-2.6 into devel
      [ARM] omap: provide a NULL clock operations structure
      [ARM] omap: kill PARENT_CONTROLS_CLOCK
      [ARM] omap: add default .ops to all remaining OMAP2 clocks
      [ARM] omap: eliminate unnecessary conditionals in omap2_clk_wait_re=
ady
      [ARM] omap: don't use clkops_omap2_dflt_wait for non-ICLK/FCLK cloc=
ks
      [ARM] omap: remove clk->owner
      [ARM] omap: rearrange clock.h structure order
      [ARM] omap: remove clk_deny_idle and clk_allow_idle
      [ARM] omap: provide a standard clk_get_parent() implementation
      [ARM] omap: move clock propagation into core omap clock code
      [ARM] omap: remove unnecessary calls to propagate_rate()
      [ARM] omap: move propagate_rate() calls into generic omap clock cod=
e
      [ARM] omap: handle RATE_CKCTL via .set_rate/.round_rate methods
      [ARM] omap: ensure devname is set for dummy devices
      [ARM] omap: allow double-registering of clocks
      [ARM] omap: convert OMAP1 to use clkdev
      [ARM] omap: convert OMAP2 to use clkdev
      [ARM] omap: convert OMAP3 to use clkdev
      [ARM] omap: remove pre-CLKDEV clk_get/clk_put
      [ARM] omap: provide a dummy clock node
      [ARM] omap: watchdog: convert clocks to match by devid and conid
      [ARM] omap: watchdog: provide a dummy ick for OMAP1
      [ARM] omap: MMC: convert clocks to match by devid and conid
      [ARM] omap: MMC: provide a dummy ick for OMAP1
      [ARM] omap: mcspi: new short connection id names
      [ARM] omap: mcbsp: convert to use fck/ick clocks directly
      [ARM] omap: i2c: use short connection ids
      [ARM] omap: i2c: remove armxor_ck
      [ARM] omap: i2c: remove conditional ick clocks
      [ARM] omap: w1: convert omap HDQ clocks to match by devid and conid
      [ARM] omap: spi: arrange for omap_uwire to use connection ID
      [ARM] omap: convert omap RNG clocks to match by devid and conid
      [ARM] omap: omap24xxcam: use short connection IDs for omap2 clocks
      [ARM] omap: hsmmc: new short connection id names
      [ARM] omap: clks: call recalc after any rate change
      [ARM] omap: create a proper tree of clocks
      [ARM] omap: fix usecount decrement bug
      [ARM] omap: fix clockdomain enable/disable ordering
      [ARM] omap: arrange for clock recalc methods to return the rate
      [ARM] omap: add support for bypassing DPLLs
      [ARM] dma: move IOMD and floppy DMA structures to RiscPC DMA code
      [ARM] dma: RiscPC: don't modify DMA SG entries
      Merge branch 'dma' into devel
      etherh: Get working again.
      [ARM] omap: ensure that failing power domain lookups produce errors
      [ARM] omap: clk_set_parent: deny changing parent if clock is enable=
d
      Merge branch 'for-rmk' of git://git.pengutronix.de/git/imx/linux-2.=
6 into devel
      Merge branch 'devel' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/ycmiao/pxa-linux-2.6 into devel
      Merge branch 'imx-fb-fix' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/djbw/async_tx into devel
      Merge branch 'for-russell' of git://git.kernel.org/pub/scm/linux/ke=
rnel/git/chris/linux-2.6 into devel
      Merge branch 'omap-clks3' into devel
      [ARM] pass reboot command line to arch_reset()
      Merge branch 'master' of git://git.marvell.com/orion into devel
      Merge branch 'fix' of git://git.kernel.org/pub/scm/linux/kernel/git=
/ycmiao/pxa-linux-2.6
      Merge branch 'highmem' into devel
      Merge git://git.marvell.com/orion into devel
      [ARM] collie: fix two minor formatting nits
      [ARM] acorn,ebsa110,footbridge,integrator,sa1100: Convert asm/io.h =
to linux/io.h
      Merge branch 'for-next' of git://git.kernel.org/pub/scm/linux/kerne=
l/git/tmlind/linux-omap-2.6 into devel
      Merge branch 'next-s3c-pm' of git://aeryn.fluff.org.uk/bjdooks/linu=
x into devel
      Merge branch 'next-s3c64xx-regs' of git://aeryn.fluff.org.uk/bjdook=
s/linux into devel
      Merge branch 'for-rmk' of git://gitorious.org/linux-gemini/mainline=
 into devel
      Merge branch 'devel' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/ycmiao/pxa-linux-2.6 into devel
      Merge branch 'for-rmk' of git://git.pengutronix.de/git/imx/linux-2.=
6 into devel
      Merge branch 'origin' into devel
      Merge branch 'master' into devel
      [ARM] arch_reset() now takes a second parameter
      Merge branch 'for-rmk' of git://git.marvell.com/orion
      oprofile: Thou shalt not call __exit functions from __init function=
s
      Merge branch 'smsc911x-armplatforms' of git://github.com/steveglen/=
linux-2.6
      [ARM] fix build-breaking 7a192ec commit
      V4L/DVB (11329): Fix buglets in v4l1 compatibility layer

Rusty Russell (96):
      cpumask: Use topology_core_cpumask()/topology_thread_cpumask()
      cpumask: convert misc driver functions
      cpumask: convert drivers/net/sfc
      cpumask: convert other misc kernel functions
      x86: change flush_tlb_others to take a const struct cpumask
      work_on_cpu: don't try to get_online_cpus() in work_on_cpu.
      work_on_cpu: Use our own workqueue.
      alloc_percpu: change percpu_ptr to per_cpu_ptr
      alloc_percpu: add align argument to __alloc_percpu.
      cpumask: use topology_core_cpumask/topology_thread_cpumask instead =
of cpu_core_map/cpu_sibling_map
      cpumask: replace node_to_cpumask with cpumask_of_node.
      cpumask: remove dangerous CPU_MASK_ALL_PTR, &CPU_MASK_ALL.: x86
      cpumask: remove the now-obsoleted pcibus_to_cpumask(): x86
      cpumask: remove cpu_coregroup_map: x86
      cpumask: remove obsolete topology_core_siblings and topology_thread=
_siblings: x86
      cpumask: convert c1e_mask in arch/x86/kernel/process.c to cpumask_v=
ar_t.
      cpumask: convert arch/x86/kernel/nmi.c's backtrace_mask to a cpumas=
k_var_t
      cpumask: x86: convert cpu_sibling_map/cpu_core_map to cpumask_var_t
      cpumask: convert arch/x86/kernel/cpu/mcheck/mce_64.c
      x86: arch_send_call_function_ipi_mask
      cpumask: remove x86's node_to_cpumask now everyone uses cpumask_of_=
node
      x86: unify 32 and 64-bit node_to_cpumask_map
      cpumask: convert node_to_cpumask_map[] to cpumask_var_t
      cpumask: convert struct cpuinfo_x86's llc_shared_map to cpumask_var=
_t
      x86: unify cpu_callin_mask/cpu_callout_mask/cpu_initialized_mask/cp=
u_sibling_setup_mask
      cpumask: use new cpumask functions throughout x86
      cpumask: clean up summit's send_IPI functions
      cpumask: make Xen use the new operators.
      cpumask: remove cpumask_t assignment from vector_allocation_domain(=
)
      cpumask: use cpumask_var_t in uv_flush_tlb_others.
      cpumask: remove x86 cpumask_t uses.
      cpumask: convert node_to_cpumask_map[] to cpumask_var_t
      numa, cpumask: move numa_node_id default implementation to topology=
.h
      cpumask: prepare for iterators to only go to nr_cpu_ids/nr_cpumask_=
bits.: cris
      cpumask: Use accessors code.: cris
      cpumask: use mm_cpumask() wrapper: cris
      cpumask: remove the now-obsoleted pcibus_to_cpumask(): ia64
      cpumask: arch_send_call_function_ipi_mask: ia64
      cpumask: prepare for iterators to only go to nr_cpu_ids/nr_cpumask_=
bits.: ia64
      cpumask: Use accessors code.: ia64
      cpumask: use mm_cpumask() wrapper: ia64
      cpumask: arch_send_call_function_ipi_mask: parisc
      cpumask: prepare for iterators to only go to nr_cpu_ids/nr_cpumask_=
bits.: parisc
      cpumask: Use accessors code.: parisc
      cpumask: Use smp_call_function_many(): sparc64
      cpumask: arch_send_call_function_ipi_mask: sparc
      cpumask: Use accessors code: sparc
      cpumask: Use accessors code.: sparc64
      cpumask: prepare for iterators to only go to nr_cpu_ids/nr_cpumask_=
bits.: sparc64
      cpumask: prepare for iterators to only go to nr_cpu_ids/nr_cpumask_=
bits.: sparc
      cpumask: remove cpu_coregroup_map: sparc
      cpumask: remove the now-obsoleted pcibus_to_cpumask(): sparc
      cpumask: remove dangerous CPU_MASK_ALL_PTR, &CPU_MASK_ALL.: sparc
      cpumask: use mm_cpumask() wrapper: sparc
      cpumask: fix CONFIG_CPUMASK_OFFSTACK=3Dy cpu hotunplug crash
      x86, uv: fix cpumask iterator in uv_bau_init()
      x86: cpumask: use work_on_cpu in arch/x86/kernel/microcode_core.c
      x86: cpumask: update 32-bit APM not to mug current->cpus_allowed
      x86: cpumask: x86 mmio-mod.c use cpumask_var_t for downed_cpus
      cpumask: remove cpumask allocation from idle_balance
      cpumask: remove cpumask allocation from idle_balance, fix
      powerpc: Make sysfs code use smp_call_function_single
      cpumask: Use mm_cpumask() wrapper instead of cpu_vm_mask
      x86: Correct behaviour of irq affinity
      [S390] allow usage of string functions in linux/string.h
      [S390] cpumask: remove cpu_coregroup_map
      [S390] cpumask: prepare for iterators to only go to nr_cpu_ids/nr_c=
pumask_bits.
      [S390] cpumask: Use accessors code.
      [S390] cpumask: use mm_cpumask() wrapper
      virtio: more neatening of virtio_ring macros.
      lguest: fix spurious BUG_ON() on invalid guest stack.
      lguest: wire up pte_update/pte_update_defer
      lguest: barrier me harder
      cpumask: remove dangerous CPU_MASK_ALL_PTR, &CPU_MASK_ALL
      cpumask: fix seq_bitmap_*() functions.
      cpumask: remove node_to_first_cpu
      cpumask: use set_cpu_active in init/main.c
      cpumask: use mm_cpumask() wrapper: kernel/fork.c
      cpumask: remove references to struct irqaction's mask field.
      cpumask: use new cpumask_ functions in core code.
      cpumask: convert rcutorture.c
      cpumask: remove cpumask_t from core
      cpumask: remove the now-obsoleted pcibus_to_cpumask(): generic
      param: fix charp parameters set via sysfs
      module: __module_address
      module: remove module_text_address()
      module: clarify the force-loading taint message.
      module: remove the SHF_ALLOC flag on the __versions section.
      module: include other structures in module version check
      module: don't use stop_machine on module load
      arm: allow usage of string functions in linux/string.h
      strstarts: helper function for !strncmp(str, prefix, strlen(prefix)=
)
      module: use strstarts()
      Merge branch 'cpumask-for-linus' of git://git.kernel.org/pub/scm/li=
nux/kernel/git/tip/linux-2.6-tip
      ACPI: simplify module_param namespace
      Revert "module: remove the SHF_ALLOC flag on the __versions section=
."

Ryan Finnie (1):
      HID: Support Apple mini aluminum keyboard

Ryan Mallon (4):
      [ARM] 5373/2: Add gpiolib support to AT91
      [ARM] 5413/1: Add ep93xx dma m2p clocks
      [ARM] 5414/2: ep93xx m2p dma core
      [ARM] 5441/1: Use pr_err on error paths in at91 pm

Ryusuke Konishi (39):
      nilfs2: add document
      nilfs2: add inode and other major structures
      nilfs2: B-tree node cache
      nilfs2: buffer and page operations
      nilfs2: meta data file
      nilfs2: persistent object allocator
      nilfs2: inode map file
      nilfs2: inode operations
      nilfs2: file operations
      nilfs2: pathname operations
      nilfs2: operations for the_nilfs core object
      nilfs2: super block operations
      nilfs2: segment buffer
      nilfs2: segment constructor
      nilfs2: fix missed-sync issue for do_sync_mapping_range()
      nilfs2: recovery functions
      nilfs2: another dat for garbage collection
      nilfs2: block cache for garbage collection
      nilfs2: update makefile and Kconfig
      nilfs2: fix problems of memory allocation in ioctl
      nilfs2: cleanup nilfs_clear_inode
      nilfs2: avoid double error caused by nilfs_transaction_end
      nilfs2: insert explanations in gcinode file
      nilfs2: add maintainer
      nilfs2: fix gc failure on volumes keeping numerous snapshots
      nilfs2: fix improper return values of nilfs_get_cpinfo ioctl
      nilfs2: fix buggy behavior seen in enumerating checkpoints
      nilfs2: remove timedwait ioctl command
      nilfs2: use fixed sized types for ioctl structures
      nilfs2: remove compat ioctl code
      nilfs2: use unlocked_ioctl
      nilfs2: extend nilfs_sustat ioctl struct
      nilfs2: replace BUG_ON and BUG calls triggerable from ioctl
      nilfs2: super block operations fix endian bug
      nilfs2: clean up sketch file
      nilfs2: mark minor flag for checkpoint created by internal operatio=
n
      nilfs2: simplify handling of active state of segments
      nilfs2: introduce secondary super block
      nilfs2: support nanosecond timestamp

Sachin S. Prabhu (1):
      Inconsistent setattr behaviour

Sachin Sant (2):
      USB: FHCI: use dev_name() in place of bus_id.
      [S390] Fix appldata build break with !NET

Sage Weil (2):
      Btrfs: notreelog mount option
      Btrfs: add flushoncommit mount option

Salman Qazi (1):
      x86: fix performance regression in write() syscall

Sam Ravnborg (1):
      kbuild: drop check for CONFIG_ in headers_check

Samuel Ortiz (29):
      iwl3945: Getting rid of iwl-3945-debug.h
      iwl3945: Remove DRV_NAME dependenies
      iwl3945: Getting rid of iwl3945_eeprom_channel
      iwl3945: Have consistant and not redefined HW constants
      iwl3945: Use iwl-agn-rs.h rates definitions.
      iwl3945: Getting rid of iwl-3945-led.h
      iwl3945: Remove power related definitions from 3945 code
      iwl3945: iwl3945_queue and iwl3945_channel_info replacement
      iwl3945: sync tx queue data structure with iwlagn
      iwl3945: switch to the iwl-core send_card_state routine
      iwl3945: Change crypto parameter name
      iwl3945: Fix iwl3945_init_drv()
      iwl3945: Use iwl_txq_update_write_ptr
      iwlwifi: Add TFD library operations
      iwl3945: Use iwl-hcmd host command routines
      iwl3945: Use iwl-rfkill
      iwl3945: Define send_tx_power
      iwl3945: Use iwlcore scan code
      iwlwifi: make iwl_tx_queue->tfds void*
      iwl3945: Use iwlcore TX queue management routines
      iwl3945: Use iwl-eeprom.c routines
      iwl3945: Use the iwlcore geos routines
      iwlwifi: Remove IWL3945_DEBUG
      iwl3945: Getting rid of priv->antenna
      iwl3945: Add restart_fw module parameter
      iwl3945: Remaining host command cleanups
      iwl3945: Getting rid of the *39_rxon iwl_priv fields
      mfd: fix MAINTAINERS entry
      mfd: fix da903x warning

Santosh Shilimkar (3):
      ARM: OMAP: Get available DMA channels from cmdline
      ARM: OMAP: Dispatch only relevant DMA interrupts
      [ARM] 5444/1: ARM: Realview: Fix event-device multiplicators in loc=
altimer.c

Santwona Behera (2):
      ethtool: Add RX pkt classification interface
      niu: Add TCAM classification configuration

Sascha Hauer (55):
      fec: remove unused #else branches
      fec: remove empty functions
      fec: use linux/*.h instead of asm/*.h
      fec: do not use memcpy on physical addresses
      fec: use dma_alloc_coherent for descriptor ring
      fec: Fix KS8721BL_ICSR phy register offset
      fec: replace flush_dcache_range with dma_sync_single
      fec: Add support for Freescale MX27
      FEC: Turn FEC driver into platform device driver
      [ARM] MXC: Use a single function for decoding a PLL
      [ARM] MXC: rework timer/clock initialisation
      [ARM] MXC: remove _clk suffix from clock names
      [ARM] MXC: add clkdev support
      [ARM] MX27 Clock rework
      [ARM] MX2: Add FEC platform device
      imxfb: add platform specific init/exit functions
      [ARM] pcm038: Add framebuffer support
      imxfb: add 18 bit support
      [ARM] MXC: add pwm driver for i.MX SoCs
      [ARM] MX2: add pwm device/resources
      [ARM] MX2: Add I2C devices / resources
      [ARM] PCM038 board: Add I2C support
      [ARM] mx1ads: add I2C support
      [ARM] iommux mx3: Add pin definitions for I2C
      [ARM] PCM037 Board: Add I2C support
      [ARM] Add Synertronixx scb9328 board support
      [ARM] mxc: add missing include
      imxfb: add mx27 support
      imxfb: Fix margin settings
      [ARM] MX35: Add register definitions for the i.MX35
      [ARM] MXC: add cpu_is_ macros
      [ARM] add i.MX35 build support
      [ARM] MX35: add clock support
      [ARM] MX35 devices support
      [ARM] MX31/MX35: Add l2x0 cache support
      [ARM] MX31: Move static virtual mappings of AIPS1/2 to common file
      [ARM] pcm038: Fix pins for UART3
      MX31 clkdev support
      Use __force in IO_ADDRESS macro to silence sparse
      mxcmmc: Do not pass clock name, we have only one clock for this dev=
ice
      MX2/MX3 SDHC driver: rename platform driver
      MX2: Add SDHC platform_devices and resources
      MX31: Add sdhc resources/platform devices
      pcm037: Add sdhc support
      pcm970 baseboard: Add SDHC support
      i.MX1: remove fb support from mach-imx
      clkdev: add possibility to get a clock based on the device name
      imxfb: add clock support
      i.MX21/27: remove ifdef CONFIG_FB_IMX
      imxfb: Fix TFT mode
      V4L/DVB (11030): soc-camera: add board hook to specify the buswidth=
 for camera sensors
      V4L/DVB (11031): pcm990 baseboard: add camera bus width switch sett=
ing
      V4L/DVB (11032): mt9m001: allow setting of bus width from board cod=
e
      V4L/DVB (11033): mt9v022: allow setting of bus width from board cod=
e
      V4L/DVB (11034): soc-camera: remove now unused gpio member of struc=
t soc_camera_link

Sathya Perla (1):
      be2net: cleanup rx/tx rate calculations

Scott Feldman (4):
      enic: bug fix: return notify intr credits
      enic: record all bad FCS errs as frame errors
      enic: bug fix: tx_timeout reset path fix-ups
      enic: Add api for link down count and to get firmware notification =
status.

Scott James Remnant (12):
      [SCSI] ch: Add scsi type modalias
      netfilter: auto-load ip6_queue module when socket opened
      netfilter: auto-load ip_queue module when socket opened
      [MTD] Auto-load mtdchar module when device opened.
      [MTD] Auto-load nftl module when device opened.
      V4L/DVB (10947): Auto-load videodev module when device opened.
      floppy: provide a PNP device table in the module.
      applicom: Auto-load applicom module when device opened.
      cyclades: Auto-load cyclades module when device opened.
      specialix: Auto-load specialix module when device opened.
      usb: Auto-load cdc_acm module when device opened.
      riscom8: Auto-load riscom8 module when device opened.

Scott Wood (3):
      cpm_uart: Initialize port.dev before it's used.
      cpm_uart: Disable CPM udbg when re-initing CPM uart, even if not th=
e console.
      powerpc/pq2fads: Update device tree for use with device-tree-aware =
u-boot.

Sebastian Andrzej Siewior (2):
      x86/centaur: merge 32 & 64 bit version
      V4L/DVB (10655): tvp514x: make the module aware of rich people

Sebastian Ott (14):
      [S390] cio: ccw device online store - report rc from ccw driver.
      [S390] cio: device scan oom fallback.
      [S390] cio: airq - fix array boundary
      [S390] cio: ccw group online store - report rcs to the caller.
      [S390] cio: fix sanity checks in ccwgroup driver.
      [S390] cio: ccw group fix unbind behaviour.
      [S390] cio: fix wrong buffer access in cio_ignore_write
      [S390] cio: fix rc generation after chsc call
      [S390] cio: remove unused local variable
      [S390] cio: wake up on failed recognition
      [S390] cio: introduce ccw_device_schedule_sch_unregister
      [S390] cio: introduce notifier for boxed state
      [S390] cio: disallow online setting of device in transient state
      [S390] cio: online_store - trigger recognition for boxed devices

Sebastien Dugue (1):
      hrtimers: allow the hot-unplugging of all cpus

Segher Boessenkool (1):
      fsl_pq_mdio: Fix compile failure

Senthil Balasubramanian (7):
      ath9k: INI update for Atheros AR9280 and AR9285 chipset.
      ath9k: Fix AR9285 specific noise floor eeprom reads.
      ath9k: Add open loop control support
      ath9k: Get rid of unnecessary ATOMIC memory alloc during init time
      ath9k: RX buffers may be accessed/freed even before initialized/all=
oced.
      ath9k: INI update for AR9285 and periodic PA offset caliberation
      ath9k: Incorrect AR9285 version check macro

Seokmann Ju (1):
      [SCSI] qla2xxx: Correct several PCI-EEH issues.

Serge E. Hallyn (10):
      securityfs: fix long-broken securityfs_create_file comment
      keys: distinguish per-uid keys in different namespaces
      keys: consider user namespace in key_permission
      keys: skip keys from another user namespace
      keys: make procfiles per-user-namespace
      proc_sysctl: use CONFIG_PROC_SYSCTL around ipc and utsname proc_han=
dlers
      namespaces: move proc_net_get_sb to a generic fs/super.c helper
      namespaces: mqueue ns: move mqueue_mnt into struct ipc_namespace
      namespaces: ipc namespaces: implement support for posix msqueues
      namespaces: mqueue namespace: adapt sysctl

Sergei Shtylyov (14):
      USB: musb: rewrite host periodic endpoint allocation
      au1xxx-ide: auide_{in|out}sw() should be static
      ide: identify data word 53 bit 1 doesn't cover words 62 and 63 (tak=
e 3)
      ide-iops: only clear DMA words on setting DMA mode
      ide: add support for CFA specified transfer modes (take 3)
      ide-disk: use ATA_ERR
      ide: use ATA_HOB
      ide: turn set_irq() method into write_devctl() method
      ide: rename IDE_TFLAG_IN_[HOB_]FEATURE
      ide-io-std: shorten ide_{in|out}put_data()
      ide: call {in|out}put_data() methods from tf_{read|load}() methods =
(take 2)
      ide: move data register access out of tf_{read|load}() methods (tak=
e 2)
      ide: turn selectproc() method into dev_select() method (take 5)
      ide: inline SELECT_DRIVE()

Sergey Senozhatsky (1):
      fb: nvidiafb recognizes geforcego 7300 chip as mobile

Sergey Yanovich (1):
      sony-laptop: notify the hardware of a state change in wwanpower

Sergio Aguirre (2):
      [ARM] OMAP: Add CSI2 clock struct for handling it with clock API
      V4L/DVB (10575): V4L2: Add COLORFX user control

Shadi Ammouri (1):
      [ARM] Kirkwood: Marvell SheevaPlug support

Shane Huang (1):
      i2c-piix4: Add support to SB800 SMBus changes

Shannon Nelson (1):
      ixgbe: Move ring features into an enum, allowing easier future main=
tenance

Shaohua Li (8):
      ftrace, ia64: make recordmcount distinct module compile
      ftrace, ia64: explictly ignore a file in recordmcount.pl
      ftrace, ia64: Add macro for ftrace_caller
      ftrace, ia64: Add recordmcount for ia64
      ftrace, ia64: IA64 static ftrace support
      ftrace, ia64: IA64 dynamic ftrace support
      agp/intel: Add support for new intel chipset.
      drm/i915: correctly set IGD device's gtt size for KMS.

Shawn Bohrer (1):
      8250_pci: add support for National Instruments 843x RS232 devices

Shen Feng (2):
      Btrfs: free inode struct when btrfs_new_inode fails
      documentation: update Documentation/filesystem/proc.txt and Documen=
tation/sysctls

Sheng Yang (10):
      PCI: Speed up device reset function
      KVM: Remove duplicated prototype of kvm_arch_destroy_vm
      KVM: Add support to disable MSI for assigned device
      KVM: Use irq routing API for MSI
      KVM: VMX: Use kvm_mmu_page_fault() handle EPT violation mmio
      KVM: Get support IRQ routing entry counts
      KVM: Correct deassign device ioctl to IOW
      intel-iommu: Snooping control support
      iommu: Add domain_has_cap iommu_ops
      intel-iommu: VT-d page table to support snooping control bit

Shinya Kuribayashi (5):
      MIPS: VR5500: Enable prefetch
      MIPS: Mark Eins: Fix cascading interrupt dispatcher
      MIPS: EMMA2RH: Use handle_edge_irq() handler for GPIO interrupts
      MIPS: EMMA2RH: Use set_irq_chip_and_handler_name
      MIPS: EMMA2RH: Set UART mapbase

Shyam Sundar (1):
      [SCSI] qla2xxx: Cleanup unused flags and #defines.

Simon Farnsworth (2):
      solos: Slight debugging improvements
      solos: FPGA and firmware update support.

Simon Kitching (1):
      initramfs: prevent initramfs printk message being split by messages=
 from other code.

Sonic Zhang (5):
      Blackfin arch: update default kernel configuration
      blackfin: Fix tty compile error in PIO mode
      Fix DMA rx ring buffer handling
      Change hardware flow control from poll to interrupt driven
      tty: Blackin CTS/RTS

Sri Deevi (8):
      V4L/DVB (10950): xc5000: prepare it to be used by cx231xx module
      V4L/DVB (10952): cx25840: prepare it to be used by cx231xx module
      V4L/DVB (10954): Add cx231xx USB driver
      V4L/DVB (10957): cx231xx: Fix CodingStyle
      V4L/DVB (10958): cx231xx: some additional CodingStyle and minor fix=
es
      V4L/DVB (11038): Fix the issue with audio module & correction of Na=
mes
      V4L/DVB (11128): cx231xx: convert the calls to subdev format
      V4L/DVB (11129): cx231xx: Use generic names for each device block

Srinivas Eeda (1):
      ocfs2: recover orphans in offline slots during recovery and mount

Stanislaw Gruszka (1):
      ACPI: Avoid wiping out pr->performance during preregistering

Stanislaw Raczynski (1):
      Staging: comedi: add mpc624 driver

Stanley.Miao (1):
      arm: update omap_ldp defconfig to use smsc911x

Stas Sergeev (1):
      x86: minor cleanup in the espfix code

Stefan Haberland (1):
      [S390] dasd: message cleanup

Stefan Richter (45):
      firewire: convert client_list_lock to mutex
      firewire: cdev: documentation fixlet
      firewire: cdev: tcodes input validation
      firewire: cdev: fix race of fw_device_op_release with bus reset
      firewire: cdev: address handler input validation
      firewire: core: remove outdated comment
      firewire: core: remove obsolete assertions
      firewire: standardize a variable name
      firewire: remove line breaks before function names
      firewire: core: remove unused definitions
      firewire: cdev: use list_first_entry
      firewire: prevent creation of multiple IR DMA contexts for the same=
 channel
      firewire: cdev: fix documentation of FW_CDEV_IOC_GET_INFO
      firewire: cdev: reference-count client instances
      firewire: cdev: unify names of struct types and of their instances
      firewire: cdev: sort includes
      firewire: core: topology header fix
      firewire: cdev: add ioctls for manual iso resource management
      firewire: cdev: add ioctl to query maximum transmission speed
      firewire: cdev: restrict broadcast write requests to Units Space
      firewire: cdev: extend transaction payload size check
      firewire: cdev: replace some spin_lock_irqsave by spin_lock_irq
      firewire: cdev: shut down iso context before freeing the buffer
      firewire: cdev: increment fw_cdev_version, update documentation
      firewire: cdev: add ioctls for iso resource management, amendment
      firewire: cdev: simplify a schedule_delayed_work wrapper
      firewire: core: clean up includes
      firewire: core: move some functions
      firewire: core: remove condition which is always false
      firewire: normalize a variable name
      firewire: core: normalize a function argument name
      firewire: cdev: amendment to "add ioctl to query maximum transmissi=
on speed"
      firewire: cdev: secure add_descriptor ioctl
      firewire: cdev: fix race of ioctl_send_request with bus reset
      firewire: cdev: simplify FW_CDEV_IOC_SEND_REQUEST return value
      firewire: cdev: add closure to async stream ioctl
      firewire: core: drop unused call parameters of close_transaction
      firewire: core: increase bus manager grace period
      firewire: core: simplify broadcast channel allocation
      firewire: core: optimize propagation of BROADCAST_CHANNEL
      ieee1394: sbp2: follow up on "ieee1394: inherit ud vendor_id from n=
ode vendor_id"
      ieee1394: raw1394: add sparse annotations to raw1394_compat_write
      ieee1394: constify device ID tables
      DVB: firedtv: fix printk format mismatch
      Revert "V4L/DVB (10962): fired-avc: fix printk formatting warning."

Stefan Weinhuber (2):
      [S390] dasd: add large volume support
      [S390] dasd: add High Performance FICON support

Stefano Rivoir (1):
      Staging: comedi: add contec_pci_dio driver

Steffen Klassert (1):
      xfrm: fix fragmentation on inter family tunnels

Stephan Wienczny (1):
      V4L/DVB (10949): Add support for Terratec Cinergy HT PCI MKII

Stephen Hemminger (197):
      atm: br2684 internal stats
      br2684: convert to net_device_ops
      clip: convert to internal network_device_stats
      lec: convert to internal network_device_stats
      lec: convert to net_device_ops
      netrom: convert to internal net_device_stats
      netrom: convert to net_device_ops
      rose: convert to internal net_device_stats
      rose: convert to network_device_ops
      appletalk: remove unneeded stubs
      arcnet: convert to internal stats
      arcnet: convert to net_device_ops
      com20020: convert to net_devic_ops
      3c501: convert to net_device_ops
      3c505: convert to net_device_ops
      3c507: convert to net_device_ops
      3c509: convert to net_device_ops
      3c515: convert to net_device_ops
      3c523: convert to net_device_ops
      3c527: convert to net_device_ops
      3c59x: convert to net_device_ops
      ibmtr: convert to internal network_device_stats
      ibmtr: convert to net_device_ops
      lanstreamer: convert to internal network stats
      lanstreamer: convert to net_device_ops
      olympic: convert to internal network device stats
      olympic: convert to net_device_ops
      tms380tr: convert to net_device_ops
      3c559: convert to net_device_ops
      znet: convert to net_device_ops
      6pack: convert to net_device_ops
      baycom: convert to internal net_device_stats
      baycom: convert to net_device_ops
      bpqether: convert to internal net_device_stats
      bpqether: convert to net_device_ops
      dmascc: convert to internal network device stats
      dmascc: convert to network_device_ops
      hdlcdrv: convert to internal net_device_stats
      hdlcdrv: convert to net_device_ops
      yam: convert to internal net_device_stats
      yam: convert to net_device_ops
      scc: convert to internal net_device_ops
      mkiss: convert to internal network device stats
      dmascc: convert to net_device_ops
      dmascc: convert to internal net_device_ops
      net: add ARP notify option for devices
      inet: Fix virt-manager regression due to bind(0) changes.
      sky2: remove unneede workaround
      sky2: handle dma mapping errors
      sky2: move VPD display into debug interface
      sky2: set VPD size
      netfilter: x_tables: change elements in x_tables
      netfilter: x_tables: remove unneeded initializations
      netfilter: ebtables: remove unneeded initializations
      netfilter: iptables: lock free counters
      ip: add loose reverse path filtering
      ip: ipip compile warning
      llc: fix non-const printk warning
      snap: handle registration error and compile warning
      tulip: get rid of warning for non-const string literal
      lapb: get rid of non-const printk warning
      3c59x: get rid of non-const printk warnings
      ne2k-pci: fix non-constant printk warnings
      sis900: fix non-constant printk warnings
      yellowfin: fix non-constant printk warnings
      acenic: fix non-constant printk warnings
      natsemi: fix non-constant printk warnings
      fealnx: fix non-constant printk warnings
      via-rhine: fix non-constant printk warnings
      starfire: fix non-constant printk warnings
      sundance: fix non-constant printk warnings
      hamachi: fix non-constant printk warnings
      forcedeth: fix non-constant printk warnings
      mdio: fix non-constant printk warnings
      net: convert usage of packet_type to read_mostly
      net: fix warning about non-const string
      netfilter: Kconfig spelling fixes (trivial)
      tipc: fix non-const printf format arguments
      rtnetlink: add new value for DHCP added routes
      atm: lec use dev_change_mtu
      skb: expose and constify hash primitives
      ixgbe: fix select_queue management
      snap: use const for descriptor
      ipx: use constant for strings and desciptor
      atm: fix non-const printk argument
      eql: fix non-constant printk warning
      atm: convert mpc device to using netdev_ops
      atm: convert clip driver to net_device_ops
      infiniband: convert c2 to net_device_ops
      infiniband: convert nes driver to net_device_ops
      infiniband: convert ipoib to net_device_ops
      irda: net_device_ops ioctl fix
      irlan: convert to net_device_ops
      irda: convert irda_usb to net_device_ops
      irda: convert mcs driver to net_device_ops
      stir4200: convert to net_device_ops
      irda: convert w83977af_ir to net_device_ops
      irda: convert nsc_ircc driver to net_device_ops
      irda: convert ali driver to net_device_ops
      irda: convert vlsi driver to net_device_ops
      irda: convert smsc driver to net_device_ops
      irda: convert via-ircc to net_device_ops
      irda: convert sir device to net_device_ops
      irda: convert kingsun device to net_device_ops
      irda: convert ksdazzle device to net_device_ops
      irda: convert ks959 driver to net_device_ops
      usbnet: convert catc to internal net_device_stats
      usbnet: convert catc device to net_device_ops
      usbnet: convert to internal net_device stats
      usbnet: convert rtl driver to net_device_ops
      usbnet: convert hso driver to net_device_ops
      usbnet: convert to internal net_device_stats
      usbnet: support net_device_ops
      usbnet: convert asix driver to net_device_ops
      usbnet: convert dms9601 driver to net_device_ops
      usbnet: convert msc7830 driver to net_device_ops
      usbnet: convert smsc95xx driver to net_device_ops
      usbnet: convert rndis driver to use dev_get_stats
      usbnet: convert rndis driver to net_device_ops
      pcmcia: convert 3c589 to net_device_ops
      pcmcia: convert 3c574 to net_device_ops
      pcmcia: convert fmvj18x driver to internal net_device_stats
      pcmcia: convert fmvj18x driver to net_device_ops
      pcmcia: convert nmclan driver to net_device_ops
      pcnet: convert driver to net_device_ops
      xir2cps: convert to internal net_device stats
      xirc2ps: convert to net_device_ops
      smc91c92: convert to internal net_device_stats
      smc91c92: convert to net_device_ops
      axnet: convert to net_device_ops
      x25_asy: convert to internal net_device_stats
      x25_asy: convert to net_device_ops
      dlci: convert to internal net_device_stats
      dlci: convert to net_device_ops
      cycx: convert to net_device_ops
      lapbether: convert to internal net_device_stats
      labether: convert to net_device_ops
      sbni: use internal net_device_stats
      sbni: convert to net_device_ops
      netwave: convert to internal net_device_stats
      netwave: convert to net_device_ops
      strip: convert to net_device_ops
      wavelan: convert to internal net_device_stats
      wavelan: convert to net_device_ops
      airo: convert to net_device_ops
      atmel: convert to net_device_ops
      raylan: convert to net_device_ops
      wl3501: convert to internal net_device_stats
      wl3501: convert to net_device_ops
      zd1201: convert to internal net_device_stats
      zd1201: convert to net_device_ops
      mac80211_hwsim: convert to net_device_ops
      prism54: convert to net_device_ops
      prism54: convert to internal net_device_stats
      libertas: convert to internal net_device_stats
      libertas: convert to net_device_ops
      ipw2x00: convert to internal net_device_stats
      ipw2x00: convert infrastructure for use by net_device_ops
      ipw2100: convert to net_device_ops
      ipw2200: convert to net_device_ops
      hostap: convert to internal net_device_stats
      hostap: convert to net_device_ops
      netdev: expose net_device_ops compat as config option
      bridge: bad error handling when adding invalid ether address
      benet: use do_div() for 64 bit divide
      gianfar: fix headroom expansion code
      3c503, smc-ultra: netdev_ops bugs
      uml: convert network device to internal network device stats
      uml: convert network device to netdevice ops
      appletalk: convert cops to internal net_device_stats
      appltetalk: convert cops device to net_device ops
      appletalk: convert LTPC to use internal net_device_stats
      appletalk: convert LTPC to net_device_ops
      IRDA: convert donauboe to net_device_ops
      tokenring: convert drivers to net_device_ops
      tokenring: convert smctr to net_device_ops
      wan: convert sdla driver to net_device_ops
      wireless: convert arlan to net_device_ops
      wireless: convert wavelan to net_device_ops
      netdev: seeq8005 convert to net_device_ops
      netdev: smc9194 convert to net_device_ops
      netdev: smc-ultra32 convert to net_device_ops
      netdev: smc-ultra fix netpoll
      lance: convert to net_device_ops
      netdev: ibmlana convert to net_device_ops
      netdev: convert eexpress to net_device_ops
      netdev: convert eexpro to net_device_ops
      netdev: convert at1700 to net_device_ops
      netdev: convert depca to net_device_ops
      netdev: convert ewrk3 to net_device_ops
      netdev: convert ni52 to net_device_ops
      netdev: convert ni65 to net_device_ops
      netdev: convert ac3200 to net_device_ops
      netdev: convert lp486e to net_device_ops
      netdev: convert cs89x0 to net_device_ops
      netdev: convert eth16i to net_device_ops
      net: allow multiple dev per napi with GRO

Stephen Rothwell (10):
      sparseirq, powerpc/cell: fix unused variable warning in interrupt.c
      numa, cpumask: move numa_node_id default implementation to topology=
.h, fix
      powerpc/pmi: Irq handlers return irqreturn_t
      PCI: update fakephp for bus_id removal
      ACPI: update thermal for bus_id removal
      x86: fix mismerge in arch/x86/include/asm/timer.h
      tracing, powerpc: fix powerpc tree and tracing tree interaction
      tracing, net: fix net tree and tracing tree merge interaction
      percpu: __percpu_depopulate_mask can take a const mask
      powerpc: Wire up preadv and pwritev

Steve French (11):
      [CIFS] Send SMB flush in cifs_fsync
      [CIFS] DFS no longer experimental
      [CIFS] Add new nostrictsync cifs mount option to avoid slow SMB flu=
sh
      [CIFS] reopen file via newer posix open protocol operation if avail=
able
      [CIFS] fix build error
      [CIFS] add extra null attr check
      [CIFS] Add definitions for remoteably fsctl calls
      [CIFS] Use posix open on file open when server supports it
      [CIFS] work around bug in Samba server handling for posix open
      [CIFS]  Rename compose_mount_options to cifs_compose_mount_options.
      [CIFS] Fix memory overwrite when saving nativeFileSystem field duri=
ng mount

Steve Glendinning (21):
      smsc95xx: remove unused completion struct
      smsc95xx: fix function prototype of async callback
      smsc911x: leave RX_STOP interrupt permanently enabled
      smsc911x: add support for platform-specific irq flags
      smsc911x: register isr as IRQF_SHARED
      smsc911x: add external phy detection overrides
      smsc911x: allow mac address to be saved before device reset
      smsc911x: check for FFWD success before checking for timeout
      smsc911x: improve EEPROM loading timeout logic in open
      smsc911x: define status word positions as constants
      smsc911x: replace print_mac with %pM
      smsc911x: allow setting of mac address
      smsc9420: fix big endian rx checksum offload
      sh: add support for SMSC Polaris platform
      phy: add new LAN8710 and LAN8720 device ids to smsc phy driver
      smsc911x: enforce read-after-write timing restriction on eeprom acc=
ess
      arm: convert pcm037 platform to use smsc911x
      arm: convert realview platform to use smsc911x
      arm: convert omap ldp platform to use smsc911x
      arm: update pcm037 defconfig to use smsc911x
      arm: update realview defconfigs to use smsc911x

Steve Sakoman (3):
      ASoC: Complete Beagleboard support
      ARM: OMAP3: Add ADS7846 touchscreen support to Overo platform, v3
      ARM: Add SMSC911X support to Overo platform (V2)

Steve Wise (4):
      RDMA/cxgb3: sgl/pbl offset calculation needs 64 bits
      RDMA/cxgb3: Connection termination fixes
      RDMA/cxgb3: Remove modulo math from build_rdma_recv()
      RDMA/cxgb3: Enforce required firmware

Steven Rostedt (176):
      ftrace: remove obsolete print continue functionality
      ftrace: set up trace event hash infrastructure
      ftrace: change trace.c to use registered events
      ftrace: convert unsigned index to signed
      trace: clean up funny line breaks in stat_seq_show
      trace: print ftrace_dump at KERN_EMERG log level
      trace: stop all recording to ring buffer on ftrace_dump
      ftrace: add stack trace to function tracer
      ftrace: move function tracer functions out of trace.c
      trace: add gcc printf check to trace_seq_printf
      trace: clean up format errors in calls to trace_seq_printf
      ftrace: combine stack trace in function call
      ftrace: remove static from function tracer functions
      trace: set max latency variable to zero on default
      ftrace: test for running of recordmcount.pl twice on an object
      trace: do not disable wake up tracer on output of trace
      ring-buffer: do not swap if recording is disabled
      trace: separate out rt tasks from wakeup tracer
      wakeup-tracer: show scheduling data in output
      ring-buffer: reset timestamps when ring buffer is reset
      trace: remove internal irqsoff disabling for trace output
      trace: fix logic to start/stop counting
      trace, lockdep: manual preempt count adding for local_bh_disable
      trace: fix default boot up tracer
      trace: let boot trace be chosen by command line
      trace: code style clean up
      trace: remove deprecated entry->cpu
      ring-buffer: add NMI protection for spinlocks
      ring-buffer: allow tracing_off to be used in core kernel code
      ftrace, x86: rename in_nmi variable
      nmi: add generic nmi tracking state
      ftrace: change function graph tracer to use new in_nmi
      ring-buffer: use generic version of in_nmi
      tracing: clean up splice code
      tracing, x86: fix constraint for parent variable
      preempt-count: force hardirq-count to max of 10
      ring-buffer: rename label out_unlock to out_reset
      sched: do not account for NMIs
      ftrace: state that all functions are enabled in set_ftrace_filter
      ftrace: add do_for_each_ftrace_rec and while_for_each_ftrace_rec
      ftrace: rename ftrace_match to ftrace_match_records
      ftrace: break up ftrace_match_records into smaller components
      ftrace: add module command function filter selection
      ftrace: enable filtering only when a function is filtered on
      ftrace: add command interface for function selection
      ftrace: convert ftrace_lock from a spinlock to mutex
      ftrace: consolidate mutexes
      ftrace: trace different functions with a different tracer
      ring-buffer: add tracing_is_on to test if ring buffer is enabled
      ftrace: add traceon traceoff commands to enable/disable the buffers
      ftrace: show selected functions in set_ftrace_filter
      ftrace: add pretty print to selected fuction traces
      ftrace: add pretty print function for traceon and traceoff hooks
      ftrace: clean up coding style
      ftrace: rename _hook to _probe
      ftrace: show unlimited when traceon or traceoff has no counter
      tracing/function-graph-tracer: make arch generic push pop functions
      x86: check PMD in spurious_fault handler
      ftrace: allow archs to preform pre and post process for code modifi=
cation
      ftrace, x86: make kernel text writable only for conversions
      ftrace: immediately stop code modification if failure is detected
      ftrace: break out modify loop immediately on detection of error
      ftrace, powerpc: replace debug macro with proper pr_deug
      powerpc, ftrace: fix compile error when modules not configured
      powerpc64: port of the function graph tracer
      powerpc64, tracing: add function graph tracer with dynamic tracing
      powerpc64, ftrace: save toc only on modules for function graph
      powerpc32, ftrace: save and restore mcount regs with macro
      powerpc32, ftrace: port function graph tracer to ppc32, static only
      powerpc32, ftrace: dynamic function graph tracer
      powerpc, ftrace: use unsigned int for instruction manipulation
      powerpc, ftrace: use create_branch lib function
      tracing: add DEFINE_TRACE_FMT to tracepoint.h
      tracing: add event trace infrastructure
      tracing: add schedule events to event trace
      tracing: make event directory structure
      tracing: rename DEFINE_TRACE_FMT to just TRACE_FORMAT
      tracing: wrap arguments with PARAMS
      tracing: add options directory and core option files
      tracing: add tracer dependent options to options directory
      tracing: add protection around open use of current_tracer
      tracing: use pointer error returns for __tracing_open
      tracing: use newline separator for trace options list
      tracing: replace kzalloc with kcalloc
      tracing: move trace point formats to files in include/trace directo=
ry
      tracing: add subsystem level to trace events
      tracing: make the set_event and available_events subsystem aware
      tracing: add subsystem irq for irq events
      tracing: add subsystem sched for sched events
      tracing: add interface to write into current tracer buffer
      tracing: add raw trace point recording infrastructure
      tracing: add raw fast tracing interface for trace events
      tracing: create the C style tracing for the sched subsystem
      tracing: create the C style tracing for the irq subsystem
      tracing: add TRACE_FIELD_SPECIAL to record complex entries
      tracing: add protection around modify trace event fields
      tracing: make trace_seq_reset global and rename to trace_seq_init
      tracing: add format file to describe event struct fields
      tracing: add ftrace headers to event format files
      tracing: add trace name and id to event formats
      tracing: add print format to event trace format files
      tracing: fix return value to registering events
      ring-buffer: reset write field for ring_buffer_read_page
      ring-buffer: fix ring_buffer_read_page
      ring-buffer: replace sizeof of event header with offsetof
      ring-buffer: make ring_buffer_read_page read from start on partial =
page
      tracing: add binary buffer files for use with splice
      tracing: add cpu_file intialization for ftrace_dump
      ring-buffer: fix timestamp in partial ring_buffer_page_read
      tracing: do not return EFAULT if read copied anything
      tracing: fix seq read from trace files
      tracing: add latency output format option
      tracing: remove extra latency_trace method from trace structure
      tracing: consolidate print_lat_fmt and print_trace_fmt
      tracing: have latency tracers set the latency format
      tracing: add tracing_on/tracing_off to kernel.h
      tracing: make all file_operations const
      tracing: move print of event format to separate file
      tracing: add format files for ftrace default entries
      tracing: typecast sizeof and offsetof to unsigned int
      tracing: replace TP<var> with TP_<var>
      tracing: use generic __stringify
      tracing: new format for specialized trace points
      tracing: convert the sched trace points to the TRACE_EVENT macros
      tracing: convert irq trace points to new macros
      tracing: remove obsolete TRACE_EVENT_FORMAT macro
      tracing: fix printk format specifier
      tracing: do not allow modifying the ftrace events via the event fil=
es
      tracing: add back the available_events file
      tracing: flip the TP_printk and TP_fast_assign in the TRACE_EVENT m=
acro
      tracing: document TRACE_EVENT macro in tracepoint.h
      tracing: update comments to match event code macros
      tracing: remove funky whitespace in the trace code
      tracing: use raw spinlocks for trace_vprintk
      tracing: keep ring buffer to minimum size till used
      tracing: expand the ring buffers when an event is activated
      tracing: fix trace_wait to know to wait on all cpus or just one
      ring-buffer: only allocate buffers for online cpus
      Merge branch 'tracing/ftrace' of git://git.kernel.org/pub/scm/linux=
/kernel/git/tip/linux-2.6-tip into trace/tip/tracing/ftrace-merge
      tracing: fix comments about trace buffer resizing
      tracing: protect ring_buffer_expanded with trace_types_lock
      ring-buffer: use CONFIG_HOTPLUG_CPU not CONFIG_HOTPLUG
      ring-buffer: remove unneeded get_online_cpus
      tracing: show that buffer size is not expanded
      tracing: make bprint event use the proper event id
      tracing: have event_trace_printk use static tracer
      tracing: export trace formats to user space
      tracing: fix stack tracer header
      tracing: explain why stack tracer is empty
      tracing: show event name in trace for TRACE_EVENT created events
      ring-buffer: document reader page design
      tracing: left align location header in stack_trace
      tracing: add comment for use of double __builtin_consant_p
      tracing: move binary buffers into per cpu directory
      softirq: no need to have SOFTIRQ in softirq name
      tracing: protect reader of cmdline output
      tracing: stop comm recording on tracing off
      ring-buffer: add api to allow a tracer to change clock source
      tracing: add global-clock option to provide cross CPU clock to trac=
es
      tracing: make sched_switch stop/start light weight
      tracing: make power tracer start/stop methods lighter weight
      tracing: give easy way to clear trace buffer
      function-graph: consolidate prologues for output
      tracing: make print_(b)printk_msg_only global
      function-graph: calculate function depth within function graph trac=
er
      tracing: remove recording function depth from trace_printk
      function-graph: show binary events as comments
      tracing: fix memory leak in trace_stat
      function-graph: moved the timestamp from arch to generic code
      function-graph: prevent more than one tracer registering
      function-graph: ignore times across schedule
      function-graph: add option for include sleep times
      function-graph: allow unregistering twice
      ring-buffer: do not remove reader page from list on ring buffer fre=
e
      tracing: remove CALLER_ADDR2 from wakeup tracer
      function-graph: add proper initialization for init task

Steven Toth (1):
      V4L/DVB (11296): cx23885: bugfix error message if firmware is not f=
ound

Steven Whitehouse (17):
      dlm: Change rwlock which is only used in write mode to a spinlock
      GFS2: Fix remount argument parsing
      GFS2: Remove "double" locking in quota
      GFS2: Merge lock_dlm module into GFS2
      GFS2: Remove unused field from glock
      GFS2: Fix error path ref counting for root inode
      GFS2: Fix deadlock on journal flush
      GFS2: Support generation of discard requests
      GFS2: Expose UUID via sysfs/uevent
      GFS2: Add a "demote a glock" interface to sysfs
      GFS2: Fix alignment issue and tidy gfs2_bitfit
      GFS2: Support quota/noquota mount arguments
      GFS2: Clean up of glops.c
      Fix a minor bug in the previous patch
      GFS2: Fix freeze issue
      vfs: Update fs.h to use inline functions when no file locking set
      vfs: Further changes from macro to inline function in fs.h

Stoyan Gaydarov (7):
      x86: BUG to BUG_ON changes
      [S390] BUG to BUG_ON changes
      V4L/DVB (11235): changed ioctls to unlocked
      [IA64] BUG to BUG_ON changes
      BUG to BUG_ON changes
      Btrfs: BUG to BUG_ON changes
      Staging: BUG to BUG_ON changes

Stuart Bennett (1):
      x86: mmiotrace: quieten spurious warning message

Stuart Hall (1):
      V4L/DVB (11345): af9015: support for DigitalNow TinyTwin remote

Sujith (85):
      mac80211: Add 802.11h CSA support
      ath9k: rateCodeToIndex is not used, remove it
      ath9k: Update short guard interval in rate control
      ath9k: Reorganize code in xmit.c
      ath9k: Remove ath_tx_stopdma and call ath9k_hw_stoptxdma directly
      ath9k: Merge queue draining functions
      ath9k: Add a helper function to wake mac80211 queues
      ath9k: Handle holding descriptor in TX completion properly
      ath9k: Revamp TX aggregation
      ath9k: Cleanup buffer type assignment
      mac80211: Add documentation bits for mac80211_rate_control_flags
      ath9k: Fix MCS rates registration bug for AR9285
      ath9k: Fix bug in rate control capability registration
      ath9k: Fix bug in NF calibration
      ath9k: Handle chainmask for A9280
      ath9k: Reconfigure beacons on getting a notification from mac80211
      ath9k: Fix station access in aggregation completion
      ath9k: Setup short preamble properly in rate registration
      ath9k: Fix bug in TX DMA termination
      ath9k: Fix lockdep warning
      mac80211: Reset assoc_scan_tries after an unsuccessful scan run
      ath9k: Fix typo in checking for chip revision
      ath9k: Remove a bunch of unused macros
      ath9k: Cleanup get_rate() interface
      ath9k: Handle mac80211's RC flags for MCS rates
      ath9k: Add debugfs files for printing TX rate details
      ath9k: Lock mac80211 callbacks with a mutex
      ath9k: Remove all the redundant internal buffer types
      ath9k: Handle mac80211's FIF_CONTROL flag properly
      ath9k: Add retry counters to rate control debug file
      ath9k: Header file cleanup
      ath9k: Convert ANI channel to a pointer
      ath9k: Remove all the sc_ prefixes
      ath9k: Store HW version information in a separate structure
      ath9k: Move regulatory information to a separate structure
      ath9k: Remove duplicate variables
      ath9k: Merge ath_hal and ath_hal_5416 structures
      ath9k: Add callbacks hooks for EEPROM operations
      ath9k: Cleanup EEPROM operations
      ath9k: Remove all the useless ah_ variable prefixes
      ath9k: Store the correct max TX power level
      ath9k: Fix rd_ext EEPROM capability for AR9285
      ath9k: Enable Fractional N mode
      ath9k: Enable TSF Out of Range Interrupt
      ath9k: Initialize AGC calibration properly
      ath9k: Fix bug in disabling MIB counters
      ath9k: Fix incorrect noise floor reading for 4k EEPROM
      ath9k: Decrease minimum NF threshold
      mac80211: Extend the rate control API with an update callback
      ath9k: Program the RTC registers correctly
      ath9k: Fix HW wait timeout
      ath9k: Fix antenna assignment bug in TX status processing
      ath9k: Initialize channel change time
      ath9k: Remove a few unused capability macros
      ath9k: Remove ath_txq_depth and get the queue depth directly
      ath9k: Use beacon interval directly
      ath9k: Remove multiple macro occurrences
      ath9k: Add PER to RC debug statistics
      ath9k: Fix bug in EEPROM chainmask retrieval
      ath9k: Fix PCI shutdown sequence
      ath9k: Add appropriate ANI values for AP mode
      mac80211: Notify the driver only when the beacon interval changes
      mac80211: Fix TKIP/WEP HT capability handling
      ath9k: Fill in rate_update mac80211 callback
      mac80211: Update IBSS beacon timestamp properly
      ath9k: Use new scan notifiers from mac80211
      ath9k: Scrub beacon.c
      ath9k: Cleanup beacon stuck processing
      ath9k: Split beacon configuration into mode specific routines
      ath9k: Handle TSF properly for AP mode
      ath9k: Lock config_interface() callback with a mutex
      ath9k: Remove unused variables in struct ath_beacon_config
      ath9k: Initialize ANI properly
      ath9k: Fix bug in TX aggregation
      ath9k: Fix bug in reading debugfs file 'rcstat'
      ath9k: Add spectrum management to HW capabilities
      ath9k: Miscellaneous EEPROM handling cleanup
      ath9k: Move AR5416_VER_MASK to a common location
      ath9k: Introduce a helper function for setting board gain values
      ath9k: Change return type for set_board_values()
      ath9k: Fix bug in 4K EEPROM size calculation
      ath9k: Fill in ack signal in TX status
      ath9k: Fix bug in handling single stream stations
      ath9k: Update copyright in all the files
      mac80211: Tear down aggregation sessions for suspend/resume

Sukadev Bhattiprolu (12):
      devpts: Must release s_umount on error
      vfs: simple_set_mnt() should return void
      Unroll essentials of do_remount_sb() into devpts
      Parse mount options just once and copy them to super block
      Move common mknod_ptmx() calls into caller
      Remove get_init_pts_sb()
      Merge code for single and multiple-instance mounts
      signals: add from_ancestor_ns parameter to send_signal()
      signals: protect cinit from unblocked SIG_DFL signals
      signals: zap_pid_ns_process() should use force_sig()
      signals: protect cinit from blocked fatal signals
      signals: SI_USER: Masquerade si_pid when crossing pid ns boundary

Sunil Mushran (17):
      ocfs2/hb: Expose the list of heartbeating nodes via debugfs
      ocfs2: Move struct recovery_map to a header file
      ocfs2: Expose the file system state via debugfs
      ocfs2: Remove debugfs file local_alloc_stats
      ocfs2/dlm: Encapsulate adding and removing of mle from dlm->master_=
list
      ocfs2/dlm: Clean up struct dlm_lock_name
      ocfs2/dlm: Refactor dlm_clean_master_list()
      ocfs2/dlm: Create and destroy the dlm->master_hash
      ocfs2/dlm: Activate dlm->master_hash for master list entries
      ocfs2/dlm: Indent dlm_cleanup_master_list()
      ocfs2/dlm: Track number of mles
      ocfs2/dlm: Improve lockres counts
      ocfs2/dlm: dlm_set_lockres_owner() and dlm_change_lockres_owner() i=
nlined
      ocfs2/dlm: Show the number of lockres/mles in dlm_state
      ocfs2/dlm: Remove struct dlm_lock_name in struct dlm_master_list_en=
try
      ocfs2/dlm: Do not purge lockres that is being migrated dlm_purge_lo=
ckres()
      ocfs2/dlm: Tweak mle_state output

Suresh Jayaraman (1):
      NFS: Minor __nfs_revalidate_inode cleanup

Suresh Siddha (21):
      x86: fix broken flush_tlb_others_ipi()
      x86: remove mach_apic.h, fix
      x86: unify genapic code, unify subarchitectures, remove old subarch=
itecture code, xapic fix
      x86: select x2apic ops in early apic probe only if x2apic mode is e=
nabled
      x86, x2apic: fix lock ordering during IRQ migration
      x86, dmar: move page fault handling code to dmar.c
      x86, x2apic: enable fault handling for intr-remapping
      x86, dmar: routines for disabling queued invalidation and intr rema=
pping
      x86, dmar: start with sane state while enabling dma and interrupt-r=
emapping
      x86, intr-remapping: fix free_irte() to clear all the IRTE entries
      x86, x2apic: use virtual wire A mode in disable_IO_APIC() with inte=
rrupt-remapping
      x86, x2apic: fix clear_local_APIC() in the presence of x2apic
      x86, x2apic: cleanup the IO-APIC level migration with interrupt-rem=
apping
      x86, x2apic: cleanup ifdef CONFIG_INTR_REMAP in io_apic code
      x86, ioapic: Fix non atomic allocation with interrupts disabled
      x86: fix broken irq migration logic while cleaning up multiple vect=
ors
      x86, dmar: use atomic allocations for QI and Intr-remapping init
      x86: add x2apic_wrmsr_fence() to x2apic flush tlb paths
      x86, PAT: Remove duplicate memtype reserve in pci mmap
      x86, ACPI: add support for x2apic ACPI extensions
      ACPI: update x2apic comments

Swen Schillig (6):
      [SCSI] zfcp: remove undefined subtype for status read response
      [SCSI] zfcp: prevent adapter close on initial adapter open
      [SCSI] zfcp: replace current ERP logging with a more convenient ver=
sion
      [SCSI] zfcp: incorrect reaction on incoming RSCN
      [SCSI] zfcp: fix queue, scheduled work processing.
      [SCSI] zfcp: Ensure all work is cancelled on adapter dequeue

Syed Mohammed Khasim (1):
      ARM: OMAP3: Add support for 3430 SDP, v4

TOMARI Hisanobu (1):
      ide-pmac: IDE cable detection on Apple PowerBook

Takashi Iwai (252):
      ALSA: Introduce snd_card_create()
      ALSA: Convert to snd_card_create() in sound/isa/*
      ALSA: Convert to snd_card_create() in sound/pci/*
      ALSA: Convert to snd_card_create() in other sound/*
      ALSA: Update description of snd_card_create() in documents
      ALSA: Return proper error code at probe in sound/isa/*
      ALSA: Return proper error code at probe in sound/usb/*
      ALSA: pdaudiocf - Fix missing free in the error path
      ALSA: Return proper error code at probe in sound/pcmcia/*
      drivers/media: Convert to snd_card_create()
      drivers/staging: Convert to snd_card_create() for go7007
      drivers/usb/gadget: Convert to snd_card_create()
      ALSA: opti9xx - Fix build breakage by snd_card_create() conversion
      ALSA: usb-audio - Cache mixer values
      Merge branch 'topic/asoc' into next/asoc
      Merge branch 'topic/usb-mixer-cache' into next/usb-audio
      ALSA: ca0106 - Add quirk for GA-G1975X mobo
      ALSA: hda - Add extra volume offset to standard volume amp macros
      ALSA: hda - Halve too large volume scales for STAC/IDT codecs
      ALSA: hda - Add debug prints for digital I/O pin detections
      ALSA: hda - Detect non-SPDIF digital I/O
      ALSA: hda - Improve auto-probing of STAC9872 codec
      ALSA: hda - Don't break the PCM creation loop
      ALSA: hda - Check HDMI jack types in the auto configuration
      ALSA: hda - Assign proper digital I/O type for STAC/IDT
      ALSA: hda - Allow digital-only I/O on ALC262 codec
      Merge branch 'topic/hda' into next/hda
      ALSA: hda - Clean up old VAIO hack codes for STAC9872
      ALSA: hda - Remove old models for STAC9872 from the document
      Merge branch 'test/hda-vol-ofs' into next/hda
      ALSA: hda - Avoid to set the pin control again if already set
      Merge branch 'fix/hda' into topic/hda
      ALSA: hda - Add quirk for Gateway %1616 laptop
      Merge branch 'fix/hda' into topic/hda
      ALSA: hda - Add model=3Dref for Intel board with STAC9221
      Merge branch 'fix/hda' into topic/hda
      ALSA: hda - Create "Input Source" control dynamically for STAC/IDT
      ALSA: hda - Fix initial verbs for mic-boosts on AD1981HD
      ALSA: hda - Remove invalid amp initializations for AD1988* codecs
      ALSA: hda - Fix invalid verbs for mic-boosts on AD1884*
      ALSA: hda - Fix invalid amp init for ALC268 codec
      ALSA: hda - Fix wrong initial verb for AD1984 thinkpad model
      Merge branch 'topic/snd_card_new-err' into topic/asoc
      ALSA: Add description of new snd-msnd-* drivers
      ALSA: enable build of snd-msnd-* drivers
      ALSA: intel8x0 - Fix build with CONFIG_SND_AC97_POWERSAVE=3Dn
      ALSA: Add missing description of snd-cmi8330 module parameters
      ALSA: Add description of new fm_port option for snd-es1688 driver
      Merge branch 'fix/hda' into topic/hda
      ALSA: ice1724 - Dynamic MIDI TX irq control
      Merge branch 'fix/asoc' into topic/asoc
      ALSA: msnd - Fix build error with CONFIG_PNP=3Dn
      Merge branch 'fix/hda' into topic/hda
      Merge branch 'fix/hda' into topic/hda
      ALSA: hwdep - Make open callback optional
      ALSA: hwdep - Fix coding style
      ALSA: Remove superfluous hwdep ops
      ALSA: hda - Add quirk for HP zenith laptop
      ALSA: hda - Add quirk for another HP laptop
      Merge branch 'topic/snd_card_new-err' into topic/atmel
      ALSA: wss - Add missing KERN_* prefix to printk
      ALSA: gus - Add missing KERN_* prefix to printk
      ALSA: isa/*: Add missing KERN_* prefix to printk
      ALSA: usb - Add missing KERN_* prefix to printk
      ALSA: hda - Add missing KERN_* prefix to printk
      ALSA: Add missing KERN_* prefix to printk in sound/core
      ALSA: Add missing KERN_* prefix to printk in sound/drivers
      ALSA: emux - Add missing KERN_* prefix to printk
      ALSA: Add missing KERN_* prefix to printk in sound/pci/ice1712
      ALSA: emu10k1 - Add missing KERN_* prefix to printk
      ALSA: intel8x0 - Add missing KERN_* prefix to printk
      ALSA: Fix missing KERN_* prefix to printk in sound/pci
      ALSA: Add missing KERN_* prefix to printk in other sound/*
      ALSA: ca0106 - Add missing KERN_* prefix to printk
      ALSA: hda - Create beep mixer controls dynamically for Realtek code=
cs
      Merge branch 'fix/hda' into topic/hda
      ALSA: hda - Add missing NULL check in snd_hda_create_spdif_in_ctls(=
)
      ALSA: hda - Clear codec->beep at release
      ALSA: hda - Remove superfluous code in patch_realtek.c
      ALSA: hda - Use digital beep for AD codecs
      ALSA: hda - Fix unused variable compile warning
      ALSA: Add subdevice_mask field to quirk entries
      Merge branch 'topic/quirk-cleanup' into topic/hda
      ALSA: hda - Clean up quirk lists
      Merge branch 'topic/quirk-cleanup' into topic/misc
      ALSA: via82xx - Clean up quirk list
      ALSA: hda - add digital beep support for ALC268
      Merge branch 'fix/hda' into topic/hda
      ASoC: Fix forgotten replacements of socdev->codec
      Merge branch 'fix/hda' into topic/hda
      ALSA: hda - Fix a wrong pin check in snd_hda_parse_pin_def_config()
      ALSA: hda - Detect multiple digital-out pins
      Merge branch 'fix/hda' into topic/hda
      ALSA: hda - Allow fixed codec-probe mask
      ALSA: hda - Add forced codec-slots for ASUS W5F
      ALSA: hda - Update documentation
      Merge branch 'fix/hda' into topic/hda
      ALSA: hda - Add quirk for Acer AX1700-U3700A
      Merge branch 'fix/hda' into topic/hda
      ALSA: hda - Add proper cleanup for multiout-dig for ALC codecs
      ALSA: hda - Support multiple digital outs with auto-probing
      Merge branch 'for-2.6.30' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/broonie/sound-2.6 into topic/asoc
      Merge branch 'fix/hda' into topic/hda
      ALSA: hda - Cleanup IDT92HD7x HP quirks
      ALSA: hda - Clean up quirks for HP laptops with AD1984A
      Merge branch 'topic/snd_card_new-err' into topic/cs423x-merge
      ALSA: Fix documentation for snd-cs4236 driver
      ALSA: au88x0 - Fix &&|| typo
      sound: OSS: ad1848 - Fix another typo
      ALSA: cs4236 - Merge snd-cs4236-lib module into snd-cs4236
      ALSA: hda - Add quirk for Acer X3200
      ALSA: hda - Don't enable beep for digital-only ALC262
      ALSA: hda - Avoid doubly beep attachment in patch_alc268()
      ALSA: hda - Add digital-only mode for ALC268
      Merge branch 'topic/snd_card_new-err' into topic/oxygen
      Merge branch 'fix/hda' into topic/hda
      ALSA: hda - Add generic pincfg initialization
      ALSA: hda - Remove realtek codec-specific pin save/restore function=
s
      ALSA: hda - Remove IDT codec-specific pin save/restore functions
      ALSA: hda - Remove codec-specific pin save/restore functions
      ALSA: hda - Update documentation for pincfg sysfs entries
      Merge branch 'fix/hda' into topic/hda
      Merge branch 'topic/hwdep-cleanup' into topic/hdsp
      ALSA: hda - Use snd_hda_codec_get_pincfg() in the rest places
      ALSA: hda - Rename {override,cur}_pin with {user,driver}_pin
      ALSA: hda - Make user_pin overriding the driver setup
      ALSA: hda - Don't give over 0dB volume for AD1984A HP laptops
      ALSA: hda - Add an example about pin reconfiguration
      Merge branch 'test/hda-pincfg' into topic/hda
      ALSA: hda - Add pseudo device-locking for clear/reconfig
      ALSA: hda - Clean up / fix quirks for HP laptops with AD1984A
      ALSA: hda - Clean up / fix quirk for Sony laptops with ALC262
      ASoC: wm8753 - Fix build error
      ALSA: hda - Clean up the input pin setup in automatic mode
      ALSA: hda - Add model=3Dauto for STAC/IDT codecs
      Merge branch 'fix/hda' into topic/hda
      ALSA: hda - Match all 103c:17xx devices for HP BPC model
      ALSA: hda - Fix an "unused variable" compile warning
      Merge branch 'fix/hda' into topic/hda
      ALSA: hda - Don't create a beep control for digital-only ALC268
      ALSA: hda - Remove Toshiba probe_mask quirk
      ALSA: hda - Intialize more codec fields in snd_hda_codec_reset()
      ALSA: hda - Revert the codec probe at control-creation errors
      ALSA: hda - Don't return a fatal error at PCM-creation errors
      ALSA: hda - Add hint string helper functions
      ALSA: hda - Add show for init_verbs and hints sysfs entries
      ALSA: hda - Create "Analog Loopback" controls optionally
      ALSA: hda - Add more hint options for IDT/Sigmatel codecs
      ALSA: hda - Update documetation for hints sysfs entry
      ALSA: hda - Fix gcc compile warning
      ALSA: hda - Fix HP dv6736 mic input
      ALSA: hda - Fix conflict of mixer controls on Sony VAIO VGN-AR71S
      ALSA: hdsp - Ignore MIDI and PCM events in interrupts until initial=
ized
      ALSA: hda - Fix check of ALC888S-VC in alc888_coef_init()
      ALSA: Fix sample rate of Lenovo Ideapad to 44.1kHz
      Merge branch 'fix/hda' into topic/hda
      ALSA: hda - Create output controls according to pin types for IDT/S=
TAC
      ALSA: hda - Allow slave controls with non-zero indices
      ALSA: hda - Create multiple HP / speaker controls with index
      ALSA: hda - Connect to primary DAC if no individual DAC is availabl=
e
      ALSA: hda - Assign HP and speaker DACs before mic/line-in
      ALSA: ac97 - Add patch entry for Conexant CX20468-31 chip
      ASoC: Fix Kconfig dependency of CONFIG_SND_S3C24XX_SOC_JIVE_WM8750
      Merge branch 'for-2.6.30' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/broonie/sound-2.6 into topic/asoc
      ALSA: Rewrite hw_ptr updaters
      ALSA: Remove unneeded snd_pcm_substream.timer_lock
      ALSA: add snd_ctl_add_slave_uncached()
      ALSA: powermac - Add missing KERN_* prefix to printk
      ALSA: Add kernel-doc comments to vmaster stuff
      ALSA: Add sound/core/jack.c to driver-API docbook entry
      ALSA: Clean up snd_monitor_file management
      ALSA: rawmidi - Fix possible race in open
      ALSA: rawmidi - Refactor rawmidi open/close codes
      Merge branch 'topic/jack' into topic/docbook-fix
      Merge branch 'topic/vmaster-update' into topic/docbook-fix
      ALSA: Fix DocBook headers
      ALSA: hda - Fix coding style issues in last two patches
      ALSA: hda - Add missing models to documentation
      ALSA: hda - Create vmaster for conexant codecs
      ALSA: hda - Create "Capture Source" control dynamically in patch_co=
nexant.c
      ALSA: hda - Remove superfluous verbs for Cxt5047 laptop-eapd model
      ALSA: hda - Fix / clean up init verbs for Cxt5047 codec
      ALSA: hda - Clean up Cxt5047 parser
      ALSA: Remove obsolete snd_xferv struct and ioctls
      ALSA: Use define for ioctl definitions
      ALSA: hda - Add comments for the previous fix for conexant codecs
      ALSA: hda - Print multiple out-amp values of pin widgets on Conext =
codecs
      ALSA: hda - Add model=3Dvaio for STAC9872
      ALSA: hda - power up before codec initialization
      ALSA: hda - Add another HP model with IDT92HD71bx codec
      ALSA: hda - Fix ALC662 beep again
      Merge branch 'fix/opl3sa2-suspend' into topic/isa-misc
      Merge branch 'topic/snd_card_new-err' into topic/drop-l3
      Merge branch 'fix/hda' into topic/hda
      ALSA: pcm - Fix a typo in error messages
      ALSA: pcm - avoid unnecessary inline
      ALSA: pcm - Reset invalid position even without debug option
      ALSA: pcm - Fix delta calculation at boundary overlap
      ALSA: hda - Don't reset BDL unnecessarily
      ALSA: hda - Don't reset stream at each prepare callback
      ALSA: Fix wrong pointer to dev_err() in arm/pxa2xx-ac97-lib.c
      ALSA: hda - Don't show the current connection for power widgets
      ALSA: hda - Detect digital-mic inputs on ALC663 / ALC272
      ALSA: pcm - Safer boundary checks
      Merge branch 'topic/hda-optimize' into topic/hda
      ALSA: hda - Avoid output amp manipulation to digital mic pins
      ALSA: hda - Cache pin-cap values
      ALSA: hda - Fix the wrong pin-cap check in patch_realtek.c
      ALSA: hda - Don't create empty/single-item input source
      ALSA: hda - Use cached calls to get widget caps and pin caps
      ALSA: hda - Add quirk for Acer Ferrari 5000
      Merge branch 'topic/snd_card_new-err' into for-linus
      Merge branch 'topic/hwdep-cleanup' into for-linus
      Merge branch 'topic/jack' into for-linus
      Merge branch 'topic/quirk-cleanup' into for-linus
      Merge branch 'topic/ctl-list-cleanup' into for-linus
      Merge branch 'topic/rawmidi-fix' into for-linus
      Merge branch 'topic/vmaster-update' into for-linus
      Merge branch 'topic/ioctl-use-define' into for-linus
      Merge branch 'topic/pcm-cleanup' into for-linus
      Merge branch 'topic/misc' into for-linus
      Merge branch 'topic/aoa' into for-linus
      Merge branch 'topic/asoc' into for-linus
      Merge branch 'topic/atmel' into for-linus
      Merge branch 'topic/ca0106' into for-linus
      Merge branch 'topic/cs423x-merge' into for-linus
      Merge branch 'topic/docbook-fix' into for-linus
      Merge branch 'topic/drop-l3' into for-linus
      Merge branch 'topic/echoaudio' into for-linus
      Merge branch 'topic/emu10k1' into for-linus
      Merge branch 'topic/hda' into for-linus
      Merge branch 'topic/hdsp' into for-linus
      Merge branch 'topic/ice' into for-linus
      Merge branch 'topic/intel8x0' into for-linus
      Merge branch 'topic/isa-misc' into for-linus
      Merge branch 'topic/msnd' into for-linus
      Merge branch 'topic/oss-fix' into for-linus
      Merge branch 'topic/oxygen' into for-linus
      Merge branch 'topic/pcxhr' into for-linus
      Merge branch 'topic/powermac' into for-linus
      Merge branch 'topic/sscape-fix' into for-linus
      Merge branch 'topic/usb-audio' into for-linus
      Merge branch 'topic/usb-caiaq' into for-linus
      Merge branch 'topic/asoc' into for-linus
      Merge branch 'topic/isa-misc' into for-linus
      Merge branch 'topic/hda' into for-linus
      Merge branch 'topic/misc' into for-linus
      Merge branch 'topic/atmel' into for-linus
      Merge branch 'topic/usb-audio' into for-linus
      Merge branch 'topic/asoc' into for-linus
      Merge branch 'topic/hda' into for-linus
      Merge branch 'topic/misc' into for-linus

Takashi Yoshii (1):
      sh: sh7785lcr: Map whole PCI address space.

Tao Ma (3):
      ocfs2: Optimize inode allocation by remembering last group
      ocfs2: Allocate inode groups from global_bitmap.
      ocfs2: Optimize inode group allocation by recording last used group.

Ted Peters (1):
      powerpc/85xx: Fix MPC8572DS PCI protected interrupt sources

Tejun Heo (82):
      x86: fix pda_to_op()
      x86: make early_per_cpu() a lvalue and use it
      x86: make vmlinux_32.lds.S use PERCPU() macro
      x86: make percpu symbols zerobased on SMP
      x86: load pointer to pda into %gs while brining up a CPU
      x86: use static _cpu_pda array
      x86: fold pda into percpu area on SMP
      x86: merge 64 and 32 SMP percpu handling
      x86: make pda a percpu variable
      x86: convert pda ops to wrappers around x86 percpu accessors
      x86: misc clean up after the percpu update
      x86: fix build bug introduced during merge
      x86_64: initialize this_cpu_off to __per_cpu_load
      linker script: add missing VMLINUX_SYMBOL
      linker script: add missing .data.percpu.page_aligned
      x86: cleanup stack protector
      x86: conditionalize stack canary handling in hot path
      linker script: kill PERCPU_VADDR_PREALLOC()
      x86: update canary handling during switch
      x86: uv cleanup
      x86: prepare for tlb merge
      x86: make x86_32 use tlb_64.c
      x86: rename tlb_64.c to tlb.c
      x86: clean up indentation in setup_per_cpu_areas()
      linker script: use separate simpler definition for PERCPU()
      Merge branch 'master' into tj-percpu
      x86: style cleanups for xen assemblies
      modpost: NOBITS sections may point beyond the end of the file
      elf: add ELF_CORE_COPY_KERNEL_REGS()
      x86: stackprotector.h misc update
      stackprotector: update make rules
      x86: no stack protector for vdso
      x86: use asm .macro instead of cpp #define in entry_32.S
      x86: add %gs accessors for x86_32
      x86: make lazy %gs optional on x86_32
      x86: implement x86_32 stack protector
      x86: fix x86_32 stack protector bugs
      vmalloc: call flush_cache_vunmap() from unmap_kernel_range()
      module: reorder module pcpu related functions
      percpu: kill percpu_alloc() and friends
      vmalloc: implement vm_area_register_early()
      vmalloc: add un/map_kernel_range_noflush()
      percpu: implement new dynamic percpu allocator
      x86: convert to the new dynamic percpu allocator
      percpu: clean up size usage
      percpu: fix pcpu_chunk_struct_size
      bootmem: clean up arch-specific bootmem wrapping
      bootmem: reorder interface functions and add a missing one
      vmalloc: add @align to vm_area_register_early()
      x86: update populate_extra_pte() and add populate_extra_pmd()
      percpu: remove unit_size power-of-2 restriction
      percpu: give more latitude to arch specific first chunk initializat=
ion
      x86: separate out setup_pcpu_4k() from setup_per_cpu_areas()
      x86: add embedding percpu first chunk allocator
      x86: add remapping percpu first chunk allocator
      percpu: add __read_mostly to variables which are mostly read only
      x86, percpu: fix minor bugs in setup_percpu.c
      x86: convert cacheflush macros inline functions
      percpu: fix too low alignment restriction on UP
      percpu: kill compile warning in pcpu_populate_chunk()
      alpha: fix typo in recent early vmalloc change
      bootmem, x86: further fixes for arch-specific bootmem wrapping
      percpu: clean up percpu constants
      percpu: cosmetic renames in pcpu_setup_first_chunk()
      percpu: improve first chunk initial area map handling
      percpu: use negative for auto for pcpu_setup_first_chunk() argument=
s
      x86: make embedding percpu allocator return excessive free space
      percpu: add an indirection ptr for chunk page map access
      percpu, module: implement reserved allocation and use it for module=
 percpu variables
      x86, percpu: setup reserved percpu area for x86_64
      percpu: replace pcpu_realloc() with pcpu_mem_alloc() and pcpu_mem_f=
ree()
      percpu: move chunk area map extension out of area allocation
      percpu: move fully free chunk reclamation into a work
      percpu: finer grained locking to break deadlock and allow atomic fr=
ee
      linker script: define __per_cpu_load on all SMP capable archs
      percpu: make x86 addr <-> pcpu ptr conversion macros generic
      percpu: more flexibility for @dyn_size of pcpu_setup_first_chunk()
      percpu: generalize embedding first chunk setup helper
      percpu: fix spurious alignment WARN in legacy SMP percpu allocator
      ahci: drop intx manipulation on msi enable
      x86,percpu: fix inverted NUMA test in setup_pcpu_remap()
      ata_piix: VGN-BX297XP wants the controller power up on suspend

Tero Kristo (1):
      [ARM] OMAP3: PM: Make sure clk_disable_unused() order is correct

Tero Roponen (1):
      trivial: remove unused variable 'path' in alloc_file()

Tetsuo Handa (6):
      tomoyo: fix sparse warning
      TOMOYO: Fix exception policy read failure.
      TOMOYO: Don't create securityfs entries unless registered.
      TOMOYO: Do not call tomoyo_realpath_init unless registered.
      TOMOYO: Fix a typo.
      tomoyo: remove "undelete domain" command.

Thadeu Lima de Souza Cascardo (5):
      ALSA: Don't cold reset AC97 codecs in some ICH chipsets
      ALSA: AC97: Print AC97 flags in proc file to make debug it easier
      ALSA: AC97: Fix function name type in comment s/updat/update/
      trivial: Give the right path in Documentation example
      trivial: fix where cgroup documentation is not correctly referred t=
o

Theodore Kilgore (2):
      V4L/DVB (10986): mr97310a: don't discard frame headers on stream ou=
tput
      V4L/DVB (11213): gspca - sq905c: New subdriver.

Theodore Ts'o (24):
      ext4: remove call to ext4_group_desc() in ext4_group_used_meta_bloc=
ks()
      ext4: Use unsigned int for blocksize in dx_make_map() and dx_pack_d=
irents()
      ext4: New inode/block allocation algorithms for flex_bg filesystems
      ext4: Add fine print for the 32000 subdirectory limit
      ext4: Simplify delalloc implementation by removing mpd.get_block
      ext4: Save stack space by removing fake buffer heads
      ext4: Simplify delalloc code by removing mpage_da_writepages()
      ext4: add EXT4_IOC_ALLOC_DA_BLKS ioctl
      ext4: Automatically allocate delay allocated blocks on close
      ext4: Automatically allocate delay allocated blocks on rename
      ext4: Track lifetime disk writes
      ext4: Add sysfs support
      ext4: remove /proc tuning knobs
      ext4: Use atomic_t's in struct flex_groups
      ext4: Use struct flex_groups to calculate get_orlov_stats()
      ext4: Add auto_da_alloc mount option
      ext4: Use WRITE_SYNC for commits which are caused by fsync()
      ext4: Check for an valid i_mode when reading the inode from disk
      ext4: fix locking typo in mballoc which could cause soft lockup han=
gs
      block_write_full_page: Use synchronous writes for WBC_SYNC_ALL writ=
ebacks
      ext3: Use WRITE_SYNC for commits which are caused by fsync()
      ext4: Regularize mount options
      ext3: Add replace-on-truncate hueristics for data=3Dwriteback mode
      ext3: Add replace-on-rename hueristics for data=3Dwriteback mode

Thiemo Nagel (1):
      ext4: add checks of block references for non-extent inodes

Thierry MERLE (5):
      V4L/DVB (10306): usbvision: use usb_make_path to report bus info
      V4L/DVB (10307): em28xx: use usb_make_path to report bus info
      V4L/DVB (10308): uvcvideo: use usb_make_path to report bus info
      V4L/DVB (10309): s2255drv: use usb_make_path to report bus info
      V4L/DVB (10379): gspca - main: Use usb_make_path() for VIDIOC_QUERY=
CAP.

Thierry Reding (1):
      net: Add support for the OpenCores 10/100 Mbps Ethernet MAC.

Thierry Vignaud (1):
      usb: kill prehistorical comments about USB_EHCI_HCD

Thomas Gleixner (30):
      Merge branch 'linus' into timers/hrtimers
      hrtimer: prevent negative expiry value after clock_was_set()
      net: replace commatas with semicolons
      powerpc/irq: Convert obsolete irq_desc_t to struct irq_desc
      powerpc/irq: Convert obsolete hw_interrupt_type to struct irq_chip
      x86: convert obsolete irq_desc_t typedef to struct irq_desc
      powerpc/85xx: remove setup_irq(NULL action) in ksi8560
      genirq: remove unused hw_irq_controller typedef
      genirq: remove redundant if condition
      genirq: make irqreturn_t an enum
      genirq: use kzalloc instead of explicit zero initialization
      genirq: add doc to struct irqaction
      genirq: deprecate __do_IRQ
      genirq: deprecate obsolete typedefs and defines
      x86: disable __do_IRQ support
      x86: reduce preemption off section in exit thread
      debugobjects: replace static objects when slab cache becomes availa=
ble
      debugobjects: delay free of internal objects
      tracing: stop command line recording when tracing is disabled
      tracing: replace the crude (unsigned) -1 hackery
      tracing: fix trace_find_cmdline()
      Merge branch 'cpus4096' into irq/threaded
      genirq: add threaded interrupt handler support
      genirq: threaded irq handlers review fixups
      genirq: provide old request_irq() for CONFIG_GENERIC_HARDIRQ=3Dn
      genirq: fix devres.o build for GENERIC_HARDIRQS=3Dn
      x86: disable __do_IRQ support
      MIPS: Convert obsolete irq_desc_t to struct irq_desc
      cris: convert obsolete hw_interrupt_type to struct irq_chip
      [MTD] [NAND] Add support for 4KiB pages.

Thomas Klein (4):
      ehea: Use net_device_ops structure
      ehea: Fix mem allocations which require page alignment
      ehea: Improve driver behaviour in low mem conditions
      ehea: Fix memory hotplug handling

Thomas Mingarelli (1):
      [WATCHDOG] hpwdt.c: Add new HP BMC controller.

Thomas Reitmayr (1):
      [WATCHDOG] orion5x_wdt: fix compile issue by providing tclk as plat=
form data

Thomas Renninger (6):
      [CPUFREQ] Introduce /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_tr=
ansition_latency
      [CPUFREQ] powernow-k8: Always compile powernow-k8 driver with ACPI =
support
      [CPUFREQ] ondemand/conservative: deprecate sampling_rate{min,max}
      [CPUFREQ] ondemand/conservative: sanitize sampling_rate restriction=
s
      [CPUFREQ] powernow-k8: Only print error message once, not per core.
      ACPI: Remove R40e c-state blacklist

Tilman Schmidt (4):
      gigaset: Kconfig cleanup
      bas_gigaset: use tasklet_hi_schedule for timing critical tasklets
      gigaset: in file ops, check for device disconnect before anything e=
lse
      gigaset: documentation update

Tim Abbott (2):
      module: Make find_symbol return a struct kernel_symbol
      module: Export symbols needed for Ksplice

Tim Blechmann (4):
      ALSA: pcxhr: fix trivial typo
      ALSA: snd_pcm_new api cleanup
      ALSA: hdsp - poll for iobox
      ALSA: hdsp - whitespace cleanup

Tim Farrington (1):
      V4L/DVB (10574): saa7134: fix Avermedia E506R composite input

Timo Kokkonen (1):
      ARM: OMAP: Export dmtimer functions

Timo Teras (2):
      gre: strict physical device binding
      gre: optimize hash lookup

Timur Tabi (17):
      ASoC: Allow Freescale MPC8610 audio drivers to be compiled as modul=
es
      ASoC: remove stand-alone mode support from CS4270 codec driver
      ASoC: improve I2C initialization code in CS4270 driver
      ASoC: fix initialization order of the CS4270 codec driver
      ASoC: fix documentation in CS4270 codec driver
      ASoC: fix build break in CS4270 codec driver
      ASoC: fix message display in CS4270 codec driver
      ASoC: optimize init sequence of Freescale MPC8610 sound drivers
      ASoC: add additional controls to the CS4270 codec driver
      ASoC: add support for SSI asynchronous mode to the Freescale SSI dr=
ivers
      ASoC: Improve pause/unpause performance in Freescale 8610 drivers
      i2c-mpc: do not allow interruptions when waiting for I2C to complet=
e
      powerpc: add fsl,fifo-depth property to Freescale SSI device nodes
      powerpc: Add defintion for MSR[GS] to list of MSR bits
      powerpc: clean up ssi.txt, add definition for fsl,ssi-asynchronous
      ASoC: remove trigger delay in Freescale MPC8610 sound driver
      ASoC: trim SSI sysfs statistics in Freescale MPC8610 sound drivers

Tobias Klauser (9):
      tracing: storage class should be before const qualifier
      ath5k: Storage class should be before const qualifier
      orinoco: Storage class should be before const qualifier
      ieee1394: Storage class should be before const qualifier
      trivial: h8300: Storage class should be before const qualifier
      trivial: drivers/char/bsr.c: Storage class should be before const q=
ualifier
      trivial: wusb: Storage class should be before const qualifier
      V4L/DVB (10628): V4L: Storage class should be before const qualifie=
r
      mfd: Storage class should be before const qualifier

Tobias Lorenz (3):
      V4L/DVB (10530): Documentation and code cleanups
      V4L/DVB (10531): Code rearrangements in preparation for other repor=
t types
      V4L/DVB (10534): Output HW/SW version from scratchpad

Tom Arbuckle (1):
      powerpc/pci: Fix PCI<->OF matching of old style multifunc devices

Tom Talpey (5):
      SVCRDMA: remove faulty assertions in rpc/rdma chunk validation.
      XPRTRDMA: correct an rpc/rdma inline send marshaling error
      SUNRPC: dynamically load RPC transport modules on-demand
      NFS: load the rpc/rdma transport module automatically
      SVCRDMA: fix recent printk format warnings.

Tom Zanussi (13):
      tracing: fix leak in event_format_read()
      tracing: add run-time field descriptions for event filtering
      tracing: add ring_buffer_event_discard() to ring buffer
      tracing: add per-event filtering
      tracing: add per-subsystem filtering
      tracing/filters: use list_for_each_entry_safe
      tracing/filters: fix bug in copy_pred()
      tracing/filters: clean up filter_add_subsystem_pred()
      tracing/filters: use list_for_each_entry
      tracing/filters: free pred when clearing filters
      tracing/filters: use trace_seq_printf() to print filters
      tracing/filters: disallow integer values for string filters and vic=
e versa
      tracing: filter fix for TRACE_EVENT_FORMAT events

Tomas Winkler (10):
      iwlwifi: 3945 extract flow handler definitions into iwl-3945-fh.h
      iwlwifi: 3945 unfold iwl-3945-commands.h
      iwlwifi: use iwl-commands.h also in 3945
      iwlwifi: 3945 remove duplicated code from iwl-3945-commands.h
      iwlwifi: 3945 drop usage of union tsf
      iwlwifi: 3945 remove iwl-3945-commands.h
      iwlwifi: clean up printing
      iwlwifi: don't use implicit priv in IWL_DEBUG
      iwlwifi: use pci registers defined in pci_regs.h
      iwlwifi: drop PCIe workaround applicable for development boards

Tomasz Lemiech (1):
      tulip: Fix for MTU problems with 802.1q tagged frames

Tomi Valkeinen (1):
      [ARM] OMAP: wait for pwrdm transition after clk_enable()

Tony Battersby (15):
      [SCSI] sg: fix races during device removal
      [SCSI] sg: fix races with ioctl(SG_IO)
      [SCSI] sym53c8xx: fix shost use-after-free and memory leak
      [SCSI] sym53c8xx: fix NULL deref on error path
      [SCSI] sym53c8xx: fix bogus free_irq() on error path
      [SCSI] sym53c8xx: unmap pci memory after probe errors
      [SCSI] sym53c8xx: handle pci_iomap() failures
      [SCSI] sym53c8xx: use a queue depth of 1 for untagged devices
      [SCSI] sym53c8xx: don't flood syslog with negotiation messages
      epoll: don't use current in irq context
      epoll: remember the event if epoll_wait returns -EFAULT
      epoll: remove unnecessary xchg
      epoll: clean up ep_modify
      epoll: use real type instead of void *
      ipc: make shm_get_stat() more robust

Tony Lindgren (19):
      [ARM] omap: Fix omap1 clock issues
      ARM: OMAP: No need to include board-perseus2.h or board-fsample.h f=
rom hardware.h
      ARM: OMAP: No need to include board-h2.h from hardware.h
      ARM: OMAP: No need to include board-h3.h from hardware.h
      ARM: OMAP: No need to include board-innovator.h from hardware.h
      ARM: OMAP: No need to include board-osk.h from hardware.h
      ARM: OMAP: No need to include board-palm*.h from hardware.h
      ARM: OMAP: No need to include board-omap2430sdp.h from hardware.h
      ARM: OMAP: No need to include board-apollon.h from hardware.h
      ARM: OMAP: No need to include board-h4.h from hardware.h
      ARM: OMAP: No need to include board-ldp.h from hardware.h
      ARM: OMAP: No need to include board-overo.h from hardware.h
      ARM: OMAP: No need to include board-nokia.h from hardware.h
      ARM: OMAP: Remove remaining board-*.h includes from hardware.h
      ARM: OMAP3: Add more GPIO mux options
      ARM: OMAP3: Add base address definitions and resources for OMAP 3 I=
S, v2
      [ARM] OMAP: Fix compile for omap2_init_common_hw()
      [ARM] 5434/1: ARM: OMAP: Fix mailbox compile for 24xx
      [ARM] 5436/1: ARM: OMAP: Fix compile for rx51

Tony Luck (2):
      Pull cpumask into release branch
      Pull pvops into release branch

Tony Vroon (2):
      ALSA: hda - Add tyan model for Realtek ALC262
      ALSA: Document tyan model for Realtek ALC262

Trent Piepho (48):
      powerpc/fsl-booke: Remove code duplication in lowmem mapping
      powerpc/fsl-booke: Allow larger CAM sizes than 256 MB
      powerpc/fsl-booke: Make CAM entries used for lowmem configurable
      PCI: don't scan existing devices
      PCI: pci_scan_slot() returns newly found devices
      PCI Hotplug: restore fakephp interface with complete reimplementati=
on
      V4L/DVB (10558): bttv: norm value should be unsigned
      V4L/DVB (10559): bttv: Fix TDA9880 norm setting code
      V4L/DVB (10560): bttv: make tuner card info more consistent
      V4L/DVB (10561): bttv: store card database more efficiently
      V4L/DVB (10562): bttv: rework the way digital inputs are indicated
      V4L/DVB (10563): bttv: clean up mux code for IVC-120G
      V4L/DVB (10564): bttv: fix external mux for PHYTEC VD-009
      V4L/DVB (10565): bttv: fix external mux for RemoteVision MX
      V4L/DVB (10566): bttv: clean up mux code for IDS Eagle
      V4L/DVB (10567): bttv: shrink muxsel data in card database
      V4L/DVB (10568): bttv: dynamically allocate device data
      V4L/DVB (10791): videodev: not possible to register NULL video_devi=
ce
      V4L/DVB (10792): cx88: remove unnecessary forward declaration of cx=
88_core
      V4L/DVB (10794): v4l2: Move code to zero querybuf output struct to =
v4l2_ioctl
      V4L/DVB (10811): videodev: only copy needed part of RW ioctl's para=
meter
      V4L/DVB (10812): v4l2: Zero out read-only ioctls in one place
      V4L/DVB (10813): v4l2: New function v4l2_video_std_frame_period
      V4L/DVB (10814): saa7146: some small fixes
      V4L/DVB (10815): bttv: Don't need to zero ioctl parameter fields
      V4L/DVB (10816): cx88: Don't need to zero ioctl parameter fields
      V4L/DVB (10817): stkwebcam: Don't need to zero ioctl parameter fiel=
ds
      V4L/DVB (10818): usbvision: Don't need to zero ioctl parameter fiel=
ds
      V4L/DVB (10819): gspca: Don't need to zero ioctl parameter fields
      V4L/DVB (10820): meye: Don't need to zero ioctl parameter fields
      V4L/DVB (10848): zoran: Change first argument to zoran_v4l2_buffer_=
status
      V4L/DVB (10930): zoran: Unify buffer descriptors
      V4L/DVB (10933): zoran: Pass zoran_fh pointers instead of file poin=
ters
      V4L/DVB (10934): zoran: replace functions names in strings with __f=
unc__
      V4L/DVB (11260): v4l2-ioctl:  Check format for S_PARM and G_PARM
      V4L/DVB (11261): saa7146: Remove buffer type check from vidioc_g_pa=
rm
      V4L/DVB (11262): bttv: Remove buffer type check from vidioc_g_parm
      V4L/DVB (11263): gspca: Stop setting buffer type, and avoid memset =
in querycap
      V4L/DVB (11264): omap24xxcam: Remove buffer type check from vidioc_=
s/g_parm
      V4L/DVB (11265): stkwebcam: Remove buffer type check from g_parm an=
d q/dq/reqbufs
      V4L/DVB (11266): vino: Remove code for things already done by video=
_ioctl2
      V4L/DVB (11267): cafe_ccic: Remove buffer type check from XXXbuf
      V4L/DVB (11268): cx23885-417: Don't need to zero ioctl parameter fi=
elds
      V4L/DVB (11269): cx88-blackbird: Stop setting buffer type in XXX_fm=
t_vid_cap
      V4L/DVB (11270): meye: Remove buffer type checks from XXX_fmt_vid_c=
ap, XXXbuf
      V4L/DVB (11271): usbvision: Remove buffer type checks from enum_fmt=
_vid_cap, XXXbuf
      V4L/DVB (11272): zr364xx: Remove code for things already done by vi=
deo_ioctl2
      leds: Add openfirmware platform device support

Trond Myklebust (31):
      NFSv4: Ignore errors on the post-op attributes in SETATTR calls
      NFSv4: Support NFSv4 optional attributes in the struct nfs_fattr
      NFS: Shrink the struct nfs_fattr
      NFS: Fix the type of struct nfs_fattr->mode
      NFSv4: Clean up decode_getfattr()
      NFSv4: Make decode_getfattr() set fattr->valid to reflect what was =
decoded
      NFSv4: A referral is assumed to always point to a directory.
      NFSv4: Simplify some cache consistency post-op GETATTRs
      NFS: cleanup - remove struct nfs_inode->ncommit
      NFS: Throttle page dirtying while we're flushing to disk
      NFS: Kill the "defined but not used" compile error on nommu machine=
s
      SUNRPC: Avoid an unnecessary task reschedule on ENOTCONN
      SUNRPC: Ensure we set XPRT_CLOSING only after we've sent a tcp FIN.=
..
      SUNRPC: Don't disconnect if a connection is still in progress.
      SUNRPC: Handle ECONNREFUSED correctly in xprt_transmit()
      SUNRPC: Handle socket errors correctly
      SUNRPC: Return EAGAIN instead of ENOTCONN when waking up xprt->pend=
ing
      SUNRPC: Delay, then retry on connection errors.
      SUNRPC: Ensure that xs_nospace return values are propagated
      SUNRPC: Add the equivalent of the linger and linger2 timeouts to RP=
C sockets
      SUNRPC: Add a sysctl to control the duration of the socket linger t=
imeout
      SUNRPC:=C2=A0xs_tcp_connect_worker{4,6}: merge common code
      SUNRPC: Ensure we close the socket on EPIPE errors too...
      NFS: Fix up a mismerged patch
      NFS: Fix the notifications when renaming onto an existing file
      NFS: Optimise NFS close()
      Merge commit '9f4c899c0d90e1b51b6864834f3877b47c161a0e' into devel
      SUNRPC: Ensure IPV6_V6ONLY is set on the socket before binding to a=
 port
      Merge branch 'devel' into for-linus
      NFS: Fix a double free in nfs_parse_mount_options()
      NFS: Fix the return value in nfs_page_mkwrite()

Tulio Magno Quites Machado Filho (2):
      ath5k: support LED's on emachines E510 notebook
      ath5k: Support LED's on Acer Extensa 5620z

Uri Shkolnik (2):
      V4L/DVB (10748): sms1xxx: restore smsusb_driver.name to smsusb
      V4L/DVB (10750): import changes from Siano

Ursula Braun (4):
      netiucv: invalid return code from hard_start_xmit
      claw: invalid return codes from hard_start_xmit
      ctcm: invalid return code from hard_start_xmit
      qeth: check for completion of a running recovery

Uwe Bugla (2):
      V4L/DVB (11287): Code cleanup (passes checkpatch now) of the b2c2-f=
lexcop-drivers 1/2
      V4L/DVB (11288): Code cleanup (passes checkpatch now) of the b2c2-f=
lexcop-drivers 2/2

Uwe Kleine-Koenig (7):
      ftrace, trivial: fix typo "resgister" -> "register"
      tracing: make CALLER_ADDRx overwriteable
      trivial: fix typo "thier" -> "their"
      trivial: fix typo "kernal" -> "kernel"
      trivial: fix typo "varaible" -> "variable"
      trivial: fix typo "virual" -> "virtual"
      trivial: fix typo "resgister" -> "register"

Uwe Kleine-K=C3=B6nig (6):
      fix warning "control reaches end of non-void function"
      remove unused static function gpio_fec_inactive
      [MTD] [MAPS] move sa1100 flash's probe function to .devinit.text
      [MTD] [NAND] move gen_nand's probe function to .devinit.text
      ALSA: move snd_powermac's probe function to .devinit.text
      leds: move h1940-leds's probe function to .devinit.text

Valentin Longchamp (8):
      mx31: rework of iomux support
      mx31moboard: use of new iomux implementation
      mx31ads: use of new iomux implementation
      mx31pdk: use of new iomux implementation
      pcm037: use of new iomux implementation
      mx31: add pin definition for LCD
      mx31moboard: initial support for various baseboards
      mx31: add dma and fb devices

Vasanthakumar Thiagarajan (24):
      mac80211: Scale down to non-HT association with TKIP/WEP as pairwis=
e cipher
      mac80211: Fix tx power setting
      ath9k: Enable Bluetooth Coexistence support
      mac80211: Handle power constraint level advertised in 11d+h beacon
      ath9k: Fix basic connectivity issue
      ath9k: Fix typo in chip version check
      ath9k: Remove unnecessary gpio configuration in ath9k_hw_reset()
      ath9k: Remove unused ath9k_hw_select_antconfig() from hw.c
      ath9k: Clean up the way the eeprom antenna configuration is read
      ath9k: Fix LED blink pattern
      mac80211: Remove bss information of the current AP when it goes out=
 of range
      mac80211: Free current bss information in few places where we don't=
 need it any more
      mac80211: Make sure non-HT connection when IEEE80211_STA_TKIP_WEP_U=
SED is set
      ath9k: Fix PTK/GTK handshake timeout
      ath9k: Filter out beacons from other BSS in STA mode
      ath9k: Configure Power control register appropriately for h/w with =
4k eeprom
      ath9k: Remove ununsed ack duration stuff with long/short preamble
      ath9k: Use suitable macros with 4k eeprom data
      ath9k: Set IEEE80211_TX_CTL_RATE_CTRL_PROBE in rate control for pro=
be rate
      mac80211: Populate HT limitation with TKIP/WEP to the handler for S=
IOCSIWENCODE too
      ath9k: Keep LED on in idle state after association
      ath9k: Fix rate control update for aggregated frames
      ath9k: Fix bug in reporting status of tx rate
      ath9k: Nuke struct ath_xmit_status

Vasily Khoruzhick (1):
      ASoC: Don't unconditionally use the PLL in UDA1380

Vasu Dev (8):
      [SCSI] fcoe: prep work to completely remove fc_transport_fcoe code
      [SCSI] fcoe: removes fc_transport_fcoe.[ch] code files
      [SCSI] fcoe: removes default sw transport code file fcoe_sw.c
      [SCSI] fcoe: renames libfcoe.c to fcoe.c as the only fcoe module fi=
le
      [SCSI] fcoe, libfc: add libfcoe module
      [SCSI] fcoe: moves common FCoE library API functions to libfcoe mod=
ule
      [SCSI] fcoe: cleans up libfcoe.h and adds fcoe.h for fcoe module
      [SCSI] fcoe, libfc: fix double fcoe_softc memory alloc

Vegard Nossum (4):
      kmemtrace: add missing newline
      x86: use symbolic constants for MSR_IA32_MISC_ENABLE bits
      fix regression from "vsprintf: unify the format decoding layer for =
its 3 users"
      vsprintf: unify the format decoding layer for its 3 users, cleanup

Venkatesh Pallipadi (2):
      gpu/drm, x86, PAT: routine to keep identity map in sync
      gpu/drm, x86, PAT: PAT support for io_mapping_*

Vernon Sauder (2):
      smc91x: enable ethtool EEPROM interface
      USB: pxa27x_udc: typo fixes and code cleanups

Victor Shcherbatyuk (1):
      Bluetooth: Fix issue with return value of rfcomm_sock_sendmsg()

Vitaly Mayatskikh (1):
      udp: Wrong locking code in udp seq_file infrastructure

Vitaly Wool (1):
      V4L/DVB (10833): em28xx: enable Compro VideoMate ForYou sound

Vitja Makarov (1):
      Blackfin SPI Driver: ensure cache coherency before doing DMA

Vivek Natarajan (10):
      mac80211: Reset the power save timer from master_start_xmit.
      mac80211: A couple of fixes to dynamic power save.
      mac80211: Enhancements to dynamic power save.
      mac80211: Cancel the power save timer in ieee80211_stop.
      ath9k: Enable dynamic power save in ath9k.
      mac80211: Cancel the dynamic ps timer in ioctl_siwpower.
      ath9k: Enable MIB and TIM interrupts for station mode.
      mac80211: Fix the wrong WARN_ON message appearing on enabling power=
 save.
      mac80211: Always send a null data frame if TIM bit is set.
      ath9k: Handle power modes in isr for power save.

Vlad Yasevich (10):
      sctp: Clean up sctp checksumming code
      sctp: Fix the RTO-doubling on idle-link heartbeats
      sctp: Inherit all socket options from parent correctly.
      sctp: Fix broken RTO-doubling for data retransmits
      sctp: simplify sctp listening code
      sctp: Clean up TEST_FRAME hacks.
      ipv6: Disallow binding to v4-mapped address on v6-only socket.
      ipv6: Allow ipv4 wildcard binds after ipv6 address binds
      ipv6: Make v4-mapped bindings consistent with IPv4
      ipv6: Fix conflict resolutions during ipv6 binding

VomLehn (1):
      USB: Fix cp2101 USB serial device driver termios functions for cons=
ole use

WANG Cong (3):
      uml: don't use a too long string literal
      uml: improve error messages
      uml: remove useless comments

Wang Chen (5):
      genirq: check chip->ack before calling
      sched, documentation: remove old O(1) scheduler document
      sched: kill unused parameter of pick_next_task()
      x86: don't define __this_fixmap_does_not_exist()
      x86: early_ioremap_init(), use __fix_to_virt(), because we are sure=
 it's safe

Wayne Boyer (3):
      [SCSI] ipr: add MSI support
      [SCSI] ipr: add message to error table
      [SCSI] ipr: Expose debug and fastfail parameters

Wei Yongjun (38):
      mac80211: cleanup kmalloc/memset -> kcalloc
      ext4: New rec_len encoding for very large blocksizes
      ipv6: Remove some pointless conditionals before kfree_skb()
      gre: used time_before for comparing jiffies
      ipip: used time_before for comparing jiffies
      sit: used time_before for comparing jiffies
      Bluetooth: Remove some pointless conditionals before kfree_skb()
      Bluetooth: Remove some pointless conditionals before kfree_skb()
      isdn: remove some pointless conditionals before kfree_skb()
      irda: remove some pointless conditionals before kfree_skb()
      ppp: remove some pointless conditionals before kfree_skb()
      drivers/net/rionet.c: remove some pointless conditionals before kfr=
ee_skb()
      i2400m: remove some pointless conditionals before kfree_skb()
      wan: remove some pointless conditionals before kfree_skb()
      af_key: remove some pointless conditionals before kfree_skb()
      pktgen: remove some pointless conditionals before kfree_skb()
      unix: remove some pointless conditionals before kfree_skb()
      netlink: remove some pointless conditionals before kfree_skb()
      can: remove some pointless conditionals before kfree_skb()
      packet: remove some pointless conditionals before kfree_skb()
      core: remove some pointless conditionals before kfree_skb()
      decnet: remove some pointless conditionals before kfree_skb()
      iucv: remove some pointless conditionals before kfree_skb()
      llc: remove some pointless conditionals before kfree_skb()
      chelsio: remove some pointless conditionals before kfree_skb()
      ns83820: remove some pointless conditionals before kfree_skb()
      sctp: Add some missing types for debug message
      sctp: remove dup code in net/sctp/socket.c
      sctp: fix the length check in sctp_getsockopt_maxburst()
      sctp: use time_before or time_after for comparing jiffies
      sctp: fix to indicate ASCONF support in INIT-ACK only if peer has s=
uch capable
      sctp: fix to send FORWARD-TSN chunk only if peer has such capable
      [JFFS2] kmem_cache_alloc/memset -> kmem_cache_zalloc
      core: remove pointless conditional before kfree()
      ext3: use unsigned instead of int for type of blocksize in fs/ext3/=
namei.c
      [SCSI] use kmem_cache_zalloc instead of kmem_cache_alloc/memset
      Staging: usbip: kmem_cache_alloc/memset -> kmem_cache_zalloc
      Staging: remove some pointless conditionals before kfree_skb()

Weidong Han (2):
      KVM: define KVM_CAP_DEVICE_DEASSIGNMENT
      KVM: fix kvm_vm_ioctl_deassign_device

Wenji Huang (7):
      trace: trivial fixes in comment typos.
      tracing: remove unneeded variable
      tracing: provide correct return value after outputting the event
      tracing: fix typos in comments
      tracing: use the more proper parameter
      tracing: fix the return value of trace selftest
      tracing: fix typing mistake in hint message and comments

Werner Cornelius (1):
      USB: usb-serial ch341: support for DTR/RTS/CTS

Wey-Yi Guy (9):
      iwlwifi: add valid tx antenna information in rate_scale_table debug=
fs
      iwlwifi: add rf information in rate_scale debugfs command
      iwlwifi: remove un-necessary rs_tl_turn_on_agg() after agg enabled
      iwlwifi: HT performance improvement changes
      iwlwifi: check IEEE80211_TX_STAT_AMPDU for agg pkt
      iwlwifi: verify the antenna selection when receive fixed rate debug=
fs
      iwlwifi: return 0 for AMPDU_TX/RX_STOP request if NIC is going down
      iwlwifi: report error when detect failure during stop agg queue
      iwlwifi: show current driver status in user readable format

Will Page (1):
      8250_pci: add support for National Instruments legacy 8420 RS232 bo=
ards

Wim Van Sebroeck (10):
      [WATCHDOG] cpwd.c & riowd.c - unlocked_ioctl
      [WATCHDOG] rc32434_wdt: add shutdown method
      [WATCHDOG] rc32434_wdt: add spin_locking
      [WATCHDOG] rc32434_wdt: make sure watchdog is not running at startu=
p
      [WATCHDOG] cpwd.c: Coding style - Clean-up
      [WATCHDOG] struct file_operations should be const
      [WATCHDOG] More coding-style and trivial clean-up
      [WATCHDOG] Fix io.h & uaccess.h includes.
      [WATCHDOG] i6300esb.c: convert to platform device driver
      [WATCHDOG] i6300esb.c: start locking

Winkler, Tomas (29):
      iwlwifi: move sysfs status entry to debugfs
      iwlwifi: kill retry_rate sysfs for iwlagn
      iwlwifi: 3945 remove current_rate from station entry.
      iwlwifi: emliminate iwl3945_mac_get_stats mac80211 handler
      iwlwifi: replace IWL_WARNING with IWL_WARN
      iwlwifi: replace IWL_ERROR with IWL_ERR
      iwlwifi: use iwl_cmd instead of iwl3945_cmd
      iwl3945: use iwl_rb_status
      iwl3945: rearrange 3945 tfd
      iwl3945: use iwl3945_tx_cmd instead of iwl_tx_cmd
      iwl3945: use rx queue management infrastructure from iwlcore
      iwl3945: kill hw_params.tx_ant_num
      iwl3945: kill iwl3945_rx_queue_restock
      iwl3945: kill iwl3945_rx_queue_space
      iwl3945: kill iwl3945_x2_queue_used
      iwl3945: remove double defined 3945 tfd structures
      iwl3945: use hw_params.rx_buf_size
      iwlwifi: make iwl-power.c more readable
      iwlwifi: fix iwl_mac_set_key and iwl3945_mac_set_key
      iwlwifi: kill iwl3945_scan_cancel and iwl3945_scan_cancel_timeout
      iwlwifi: kill scan39
      iwlwifi: remove unused or twice defined members in iwl_priv
      iwlwifi: eliminate power_data_39.
      iwlwifi: fix probe mask for 39 scan API
      iwlwifi: iwl_tx_queue_alloc : fix warning in printk formatting
      iwlwifi: suppress unused variable warning when compiling w/o IWLWIF=
I_DEBUG
      iwlwifi: iwl3945_send_tx_power must be static
      iwlwifi: check return value of pci_enable_device
      iwlwifi: unify iwlagn and 3945 power save management

Witold Baryluk (1):
      tracing: optimization of branch tracer

Witold Szczeponik (1):
      Enable PNPACPI _PSx Support, v3

Wolfgang Grandegger (14):
      powerpc/85xx: TQM85xx - fix sensitivity of CAN interrupts
      powerpc/85xx: TQM85xx - add i2c device nodes for LM75
      powerpc/5200: add function to return external clock frequency
      powerpc/85xx: Add support for the "socrates" board (MPC8544).
      powerpc/85xx: Re-add the device_type soc to socrates.dts
      [MTD] [NAND] Add support for NAND on the Socrates board
      [MTD] [NAND] FSL-UPM: add multi chip support
      [MTD] [NAND] FSL-UPM: Add wait flags to support board/chip specific=
 delays
      powerpc: NAND: FSL UPM: document new bindings
      powerpc/85xx: TQM8548: Update DTS file for multi-chip support
      i2c: i2c-mpc: various coding style fixes
      i2c: i2c-mpc: use dev based printout function
      i2c: i2c-mpc: make I2C bus speed configurable
      powerpc/85xx: i2c-mpc: use new I2C bindings for the Socates board

Wolfgang Kroener (1):
      radeonfb: suspend/resume for ATI Mobility Radeon RV350

Wolfgang Muees (5):
      mmc_spi: allow setting of spi mode 3
      mmc_spi: wait more bytes for card response
      mmc_spi: allow higher timeouts for SPI mode
      mmc_spi: adjust for delayed data token response
      Blackfin SPI Driver: Make mmc_spi driver work on Blackfin

Wolfram Sang (8):
      powerpc/pci: Fix typo: s/resouces/resources/ in a pr_debug
      powerpc/5200: add Phytec phyCORE-MPC5200B-IO board (pcm032)
      ALSA: sound/ali5451: typo: s/resouces/resources/
      eeprom/at24: Remove EXPERIMENTAL
      i2c-algo-pca: Rework waiting for a free bus
      i2c-algo-pca: Use timeout for checking the state machine
      i2c-pca-platform: Use defaults if no platform_data given
      i2c: imx: Make disable_delay a per-device variable

Wolfram Strepp (1):
      lib/rbtree.c: optimize rb_erase()

Wu Fengguang (7):
      iwlwifi: beautify code
      ALSA: enable concurrent digital outputs for ALC1200
      writeback: double the dirty thresholds
      ramfs: add support for "mode=3D" mount option
      Btrfs: fix typos in comments
      vfs: skip I_CLEAR state inodes
      ALSA: hda - enable SPDIF output for Intel DX58SO board

Wu, Fengguang (1):
      iwlwifi: report correct and detailed values about requested txpower

Xiantao Zhang (6):
      KVM: ia64: Code cleanup
      KVM: ia64: vTLB change for enabling windows 2008 boot
      KVM: ia64: Add the support for translating PAL Call's pointer args
      KVM: ia64: Implement some pal calls needed for windows 2008
      ia64: Move the macro definitions related to MSI to one header file.
      KVM: ia64: Fix the build errors due to lack of macros related to MS=
I.

Xiaotian Feng (1):
      cpm_uart: fix non-console port startup bug

Xoan Loureiro (1):
      V4L/DVB (11289): Patch for Yuan MC770 DVB-T (1164:0871)

Yang Hongyang (11):
      spider_net: Convert to net_device_ops.
      dma-mapping: replace all DMA_64BIT_MASK macro with DMA_BIT_MASK(64)
      dma-mapping: replace all DMA_48BIT_MASK macro with DMA_BIT_MASK(48)
      dma-mapping: replace all DMA_40BIT_MASK macro with DMA_BIT_MASK(40)
      dma-mapping: replace all DMA_39BIT_MASK macro with DMA_BIT_MASK(39)
      dma-mapping: replace all DMA_32BIT_MASK macro with DMA_BIT_MASK(32)
      dma-mapping: replace all DMA_31BIT_MASK macro with DMA_BIT_MASK(31)
      dma-mapping: replace all DMA_30BIT_MASK macro with DMA_BIT_MASK(30)
      dma-mapping: replace all DMA_28BIT_MASK macro with DMA_BIT_MASK(28)
      dma-mapping: replace all DMA_24BIT_MASK macro with DMA_BIT_MASK(24)
      dma-mapping: update the old macro DMA_nBIT_MASK related documentati=
ons

Yasuaki Ishimatsu (2):
      x86: fix debug message of CPU clock speed
      x86: unify PM-Timer messages

Yasunori Goto (2):
      IA64: fix swiotlb alloc_coherent for non DMA_64BIT_MASK devices, fi=
x
      hpet: fix the possibility of insane return value of hpet_calibrate(=
) against SMI

Yauhen Kharuzhy (1):
      [MTD] mtdpart: Make ecc_stats more realistic.

Yegor Yefremov (1):
      [MTD] [CHIPS] Add JEDEC probe support for the SST 39VF3201 flash ch=
ip

Yehuda Sadeh (1):
      crypto: shash - Fix unaligned calculation with short length

Yevgeny Petrilin (3):
      mlx4_core: Don't perform SET_PORT command for Ethernet ports
      mlx4_core: Add link type autosensing
      IB/mlx4: Unregister IB device prior to CLOSE PORT command

Yi Li (2):
      Blackfin SPI Driver: fix bug - spi controller driver does not asser=
t/deassert CS correctly
      Blackfin SPI Driver: fix bug - correct usage of struct spi_transfer=
.cs_change

Yi Zou (9):
      [SCSI] net, fcoe: add ETH_P_FCOE for Fibre Channel over Ethernet (F=
CoE)
      [SCSI] net: add NETIF_F_FCOE_CRC to can_checksum_protocol
      [SCSI] net: add FCoE offload support through net_device
      [SCSI] fcoe, libfc: check offload features from LLD through netdev
      [SCSI] libfc: use lso_max for sequence offload
      [SCSI] fcoe: add support to large send by gso through net_device fo=
r fcoe_sw
      [SCSI] libfc: add support of large receive offload by ddp in fc_fcp
      [SCSI] fcoe: add support to FCoE offload support in fcoe_sw through=
 net_device
      [SCSI] fcoe: fcoe fc crc offload indication by skb->ip_summed

Yinghai Lu (68):
      sparseirq: make some func to be used with genirq
      sparseirq: use kstat_irqs_cpu instead
      sparseirq: fix build with unknown irq_desc struct
      sparseirq: use kstat_irqs_cpu on non-x86 architectures too
      x86: arch_probe_nr_irqs
      x86: make 32bit MAX_HARDIRQS_PER_CPU to be NR_VECTORS
      irq: clean up irq stat methods
      x86: allow more than 8 cpus to be used on 32-bit
      x86, apic unification: remove left over files
      x86: fix compiling with 64bit with def_to_bigsmp
      x86: seperate default_send_IPI_mask_sequence/allbutself from logica=
l
      x86: don't treat bigsmp as non-standard
      x86, percpu: fix kexec with vmlinux
      x86: move default_ipi_xx back to ipi.c
      forcedeth: make msi-x different name for rx-tx
      forcedeth: don't clear nic_poll_irq too early
      forcedeth: disable irq at first before schedule rx
      forcedeth: ck804 and mcp55 doesn't need timerirq
      forcedeth: enable msix to default
      irq: clear kstat_irqs
      irq: optimize init_kstat_irqs/init_copy_kstat_irqs
      x86/irq: optimize nr_irqs
      x86: use NR_IRQS_LEGACY to replace 16
      x86: check_timer cleanup
      x86: find nr_irqs_gsi with mp_ioapic_routing
      acpi/x86: introduce __apci_map_table, v4
      x86, es7000: fix ACPI table mappings
      pci, x86, acpi: fix early_ioremap() leak
      x86: fix typo in filter_cpuid_features()
      x86: make 32bit to call enable_IO_APIC early like 64bit
      [IA64] fix __apci_unmap_table
      x86: pre init pirq_entries[]
      x86: make APIC_init_uniprocessor() more like smp_prepare_cpus()
      x86: add x2apic config
      x86: fold apic_ops into genapic
      x86: check mptable physptr with max_low_pfn on 32bit
      x86: check range in reserve_early()
      x86: remove update_apic from x86_quirks
      x86: don't compile vsmp_64 for 32bit
      x86: fix bootmem cross node for 32bit numa
      x86: make 32-bit init_memory_mapping range change more like 64-bit
      x86: ioremap mptable
      x86: reserve exact size of mptable
      x86: fix bootmem cross node for 32bit numa, cleanup
      x86/doc: mini-howto for using earlyprintk=3Ddbgp
      x86: make "memtest" like "memtest=3D17"
      x86: remove smp_apply_quirks()/smp_checks()
      x86: fix warning about nodeid
      x86: more MTRR debug printouts
      x86: print out mtrr_range_state when user specify size
      x86: separate mtrr cleanup/mtrr_e820 trim to separate file
      x86: fix e820_update_range()
      x86: make e820_update_range() handle small range update
      x86: fix get_mtrr() warning about smp_processor_id() with CONFIG_PR=
EEMPT=3Dy
      x86: print the continous part of fixed mtrrs together
      x86-32: compute initial mapping size more accurately
      x86: put initial_pg_tables into .bss
      x86: fix 64k corruption-check
      x86: print out more info in e820_update_range()
      x86: MTRR workaround for system with stange var MTRRs
      PCI/x86: detect host bridge config space size w/o using quirks
      x86/PCI: host mmconfig detect clean up
      x86: fix set_extra_move_desc calling
      x86: use default_cpu_mask_to_apicid for 64bit
      x86/PCI: make pci=3Dlastbus=3D255 work when acpi is on
      PCI: don't enable too much HT MSI mapping
      PCI: fix HT MSI mapping fix
      x86: remove duplicated code with pcpu_need_numa()

Yoichi Yuasa (1):
      sound: fix opensound URL in oss Introduction

Yoshihiro Shimoda (5):
      sh: Support fixed 32-bit PMB mappings from bootloader.
      sh: sh7785lcr: Updates for fixed PMB.
      sh: pci-sh7780: fix pci memory address for fixed PMB
      [MTD] [NAND] sh_flctl: fix hardware ecc handling for 2048 byte page
      USB: r8a66597-hcd: suspend/resume support

Yoshiji Amagai (1):
      nilfs2: directory entry operations

Yoshiya Matsuzaka (1):
      Staging: comedi: add cb_pcidio driver

Yu Zhao (13):
      PCI: check if a bus is added when removing it
      PCI: fix incorrect mask of PM No_Soft_Reset bit
      PCI: initialize and release SR-IOV capability
      PCI: restore saved SR-IOV state
      PCI: reserve bus range for SR-IOV device
      PCI: centralize device setup code
      PCI: add SR-IOV API for Physical Function driver
      PCI: handle SR-IOV Virtual Function Migration
      PCI: document SR-IOV sysfs entries
      PCI: manual for SR-IOV user and driver developer
      PCI: fix conflict between SR-IOV and config space sizing
      PCI: save and restore PCIe 2.0 registers
      PCI: SR-IOV quirk for Intel 82576 NIC

Yuji Shimada (3):
      PCI: allow assignment of memory resources with a specified alignmen=
t
      PCI: Setup disabled bridges even if buses are added
      PCI: don't corrupt enable_cnt when doing manual resource alignment

Yuri Tikhonov (1):
      powerpc/44x: Support for 256KB PAGE_SIZE

Zachary Ware (1):
      Staging: comedi: add aio_iiro_16 driver

Zbynek Michl (1):
      [ARM] 5355/1: Adding support for the HTC Himalaya and its framebuff=
er

Zebediah C. McClure (5):
      [OMAP850] Add base support for omap850 cpu
      [OMAP850] Changes to base IO subsystem, v2
      [OMAP850] Changes to memory subsystem
      [OMAP850] IRQ related changes
      [OMAP850] Build system changes

Zhang Rui (9):
      ACPI: introduce sysfs I/F for dynamic tables
      ACPI video: check the return value of acpi_video_device_lcd_get_lev=
el_current
      ACPI video: check the return value of acpi_video_device_lcd_set_lev=
el
      ACPI video: support _BCL packages that don't export brightness leve=
ls when machine is on AC/Battery
      ACPI video: support reversed _BCL method in  ACPI video driver
      ACPI video: support _BQC/_BCL/_BCM methods that use index values
      ACPI video: support buggy BIOSes with _BCQ implemented
      ACPI video: add a warning message if _BQC is not found
      ACPI: update comment

Zhang Yanmin (1):
      SLUB: Fix default slab order for big object sizes

Zhao Yakui (3):
      drm/i915: Sync mode_valid/mode_set with intel video driver
      drm/i915: Sync crt hotplug detection with intel video driver
      ACPI: suspend: Add the Pansonic CF51 box to the dmi check table

Zhao, Yu (1):
      intel-iommu: Fix address wrap on 32-bit kernel.

Zhaolei (5):
      ftrace: avoid double-free of dyn_ftrace
      ftrace: don't try to __ftrace_replace_code on !FTRACE_FL_CONVERTED =
rec
      ftrace: Using FTRACE_WARN_ON() to check "freed record" in ftrace_re=
lease()
      ftrace: Add check of sched_stopped for probe_sched_wakeup
      ftrace: Correct a text align for event format output

Zhenwen Xu (4):
      Driver core: some cleanup on drivers/base/sys.c
      i2c-core: Some style cleanups
      make the e->rule.xxx shorter in kernel auditfilter.c
      leds: remove an unnecessary "goto" on drivers/leds/leds-s3c24.c

Zhenyu Wang (10):
      drm/i915: TV modes' parameters sync up with 2D driver
      drm/i915: Fix TV get_modes to return modes count
      drm/i915: TV mode_set sync up with 2D driver
      drm/i915: TV detection fix
      drm/i915: only set TV mode when any property changed
      drm/i915: fix TV mode setting in property change
      drm/i915: Fix SDVO command debug function
      drm/i915: Fix error in SDVO DTD and modeline convert
      drm/i915: Fix SDVO CREATE_PREFERRED_INPUT_TIMING command
      drm/i915: Fix SDVO TV support

Zhu Yi (1):
      iwlwifi: add more comments to IWL_DL_xx

adam radford (1):
      [SCSI] 3w-9xxx: add power management support

akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org (1):
      PCI: constify pci_bus_add_devices()

alex.shi (1):
      acpi: fix of pmtimer overflow that make Cx states time incorrect

dann frazier (10):
      rtc: add platform driver for EFI
      rtc-parisc: add a missing include for linux/rtc.h
      rtc-parisc: remove redundant locking
      rtc-parisc: remove struct parisc_rtc
      rtc-parisc: use rtc_valid_tm() in parisc_get_time
      rtc-parisc: use platform_driver_probe
      rtc-parisc: declare rtc_parisc_dev as static
      rtc-parisc: remove unnecessary ret variable
      rtc-parisc: remove a couple unnecessary variables
      rtc-parisc: rename p pointer to rtc

dave graham (4):
      e1000e: Disable dynamic clock gating for 82571 per si errata.
      e1000e: remove RXSEQ link monitoring for serdes
      e1000e: Serdes - attempt autoneg when link restored.
      e1000e: Remove mutex_trylock and associated WARN on failure.

dayu-pcEzf3JNfARxfCqBhyfcug@public.gmane.org (1):
      powerpc/83xx: Fix the interrupt loss problem on ipic

etienne (1):
      smack: fixes for unlabeled host support

ideawu (1):
      sunrpc/svc.c: Remove unused line 'rqstp->rq_server =3D serv;' in sv=
c_process

john stultz (1):
      time: apply NTP frequency/tick changes immediately

klaas de waal (1):
      V4L/DVB (11236): tda827x: fix locking issues with DVB-C

malc (1):
      sctp: add Adaptation Layer Indication parameter only when it's set

nsyeow (1):
      Staging: comedi: add adl_pci6208 driver

peerchen (1):
      ALSA: hda - Add the Device IDs for MCP89 and remove IDs of MCP7B

remi.denis-courmont@nokia (6):
      Phonet: move to Networking options like other protocol stacks
      Phonet: check destination before delivering packets locally
      Phonet: allow phonet_device_init() to fail, put it to __init sectio=
n
      Phonet: handle rtnetlink registration failure
      Phonet: remove useless locking in device cleanup
      Phonet: use per-namespace devices list

roel kluin (3):
      therm_adt746x: Fix signed/unsigned confusion
      powerpc/ps3: Make ps3av_set_video_mode mode ID signed
      udf: unsigned last[i] cannot be less than 0

root (1):
      Merge branch 'devel' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/ycmiao/pxa-linux-2.6 into devel

sebastian.blanes-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org (1):
      V4L/DVB (10824): Add "Sony PlayTV" to dibcom driver

unsik Kim (1):
      mflash: initial support

venkatesh.pallipadi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org (4):
      x86 PAT: ioremap_wc should take resource_size_t parameter
      x86, CPA: Add a flag parameter to cpa set_clr()
      x86, PAT: Add support for struct page pointer array in cpa set_clr
      x86, CPA: Add set_pages_arrayuc and set_pages_array_wb

vibi sreenivasan (1):
      macb: fix warning "warning: unused variable `dev' "

wanzongshun (3):
      [ARM] 5374/1: The w90p910 uart0 driver patch
      [ARM] 5392/1: Delete redundant macros for w90p910
      [ARM] 5393/1: Add W90P910 EVB NOR flash driver

wengang wang (2):
      nfsd(v2/v3): fix the failure of creation from HPUX client
      ocfs2: fix rare stale inode errors when exporting via nfs

yakui_zhao (1):
      drm: sync the mode validation for INTERLACE/DBLSCAN

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr

--===============7877156743762237586==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============7877156743762237586==--
