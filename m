From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr annotated tag, v2.6.31-rc1, created. v2.6.31-rc1
Date: Wed, 16 Sep 2009 14:36:53 -0400
Message-ID: <200909161836.n8GIarso001574@gorgona.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8883878038630048753=="
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

--===============8883878038630048753==
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by smtp1.linux-foundation.org id n8GJTerK009418

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The annotated tag, v2.6.31-rc1 has been created
        at  eeadf87f8411b42b9803312d2870aa424602a99c (tag)
   tagging  28d0325ce6e0a52f53d8af687e6427fee59004d3 (commit)
  replaces  v2.6.30
 tagged by  Linus Torvalds
        on  Wed Jun 24 16:26:14 2009 -0700

- Log -----------------------------------------------------------------
Linux 2.6.31-rc1
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkpCthwACgkQF3YsRnbiHLuELgCfdvRmI9hG0WN+s5gLGYWi2Qkw
hN8An2x0VjLr01wqFeomiY8P8G0lpdw2
=3DDjQh
-----END PGP SIGNATURE-----

Aaro Koskinen (4):
      [SCSI] sym53c8xx_2: lun to_clear flag not re-initialized (2.6.27.5)
      [SCSI] sym53c8xx_2: slave_alloc/destroy safety (2.6.27.5)
      i2c: OMAP2/3: Fix scll/sclh calculations
      i2c: OMAP3: Better noise suppression for fast/standard modes

Abhijeet Joglekar (1):
      [SCSI] libfc,fcoe,fnic: Separate rport and lport max retry counts

Abhijeet Kolekar (28):
      iwl3945: use iwl_mac_conf_tx
      iwl3945: use iwl_bss_info_changed
      iwl3945: use iwl_mac_beacon_update
      iwlwifi: add commit_rxon lib
      iwl3945: delay mode setting
      iwlwifi: add station management ops
      iwl3945: replace station function with station ops
      iwlwifi: use station management ops
      iwl3945/iwlwifi: unify add_station function
      iwl3945: use iwl_get_sta_id from iwlwifi
      iwlwifi: add set_rxon_chain op
      iwl3945: use iwl_set_mode in 3945
      iwl3945: use iwl_mac_add_interface from iwlwifi
      iwl3945: use iwl_mac_remove_interface from iwlwifi
      iwl3945: use iwl_mac_config from iwlwifi
      iwlwifi: add config_ap lib op
      iwl3945: use iwl_mac_config_interface from iwlwifi
      iwl3945: use iwl_mac_get_tx_stats from iwlwifi
      iwl3945: use iwl_mac_reset_tsf from iwlwifi
      iwl3945: add debugfs to 3945
      iwl3945: calculate debugfs isr statistics
      iwlwifi: remove radio disable parameter.
      iwl3945: fix lock dependency
      iwl3945: read rev id in nic config
      iwl3945: improve 3945 leds
      iwl3945: port allow skb allocation in tasklet patch
      iwl3945/iwlwifi: fix led bug when SW rfkill
      iwlwifi/iwl3945: fix suspend resume association bug

Abhijith Das (2):
      GFS2: Fix timestamps on write
      GFS2: smbd proccess hangs with flock() call.

Abylay Ospan (3):
      V4L/DVB (11930): TS continuity check: show error message when disco=
ntinuity detected or TEI flag detected in header
      V4L/DVB (12096): Bug fix: stv0900 register read must using i2c in o=
ne transaction
      V4L/DVB (12097): Implement reading uncorrected blocks for stv0900

Adam Lackorzynski (1):
      documentation: make version fix

Adrian Bunk (1):
      mfd/pcf50633-gpio.c: add MODULE_LICENSE

Adrian Hunter (3):
      UBIFS: reset no_space flag after inode deletion
      ARM: OMAP3: RX51: Connect VAUX3 to MMC2
      mtd: OneNAND: add support for OneNAND manufactured by Numonyx

Adriano dos Santos Fernandes (1):
      drivers/char/mem.c: memory_open() cleanup: lookup minor device numb=
er from devlist

Ajay Kumar Gupta (1):
      musb: add high bandwidth ISO support

Ajit Khaparde (1):
      be2net: changes for checksum and segmentation offload

Akinobu Mita (1):
      loop: use BIO list management functions

Akira Fujita (1):
      ext4: online defrag -- Add EXT4_IOC_MOVE_EXT ioctl

Al Viro (64):
      Fix btrfs when ACLs are configured out
      Get rid of path_lookup in autofs4
      Preparations to caching root in path_walk()
      Cache root in nameidata
      Make vfs_path_lookup() use starting point as root
      Don't bother with check_mnt() in do_add_mount() on shrinkable ones
      nfsd struct path use: exp_get_by_name()
      switch exp_parent() to struct path
      switch rqst_exp_get_by_name()
      switch rqst_exp_parent()
      switch follow_up() to struct path
      Switch collect_mounts() to struct path
      switch follow_down()
      switch follow_mount()
      switch lookup_mnt()
      Move junk from proc_fs.h to fs/proc/internal.h
      Make sure that all callers of remount hold s_umount exclusive
      Trim a bit of crap from fs.h
      No need to do lock_super() for exclusion in generic_shutdown_super(=
)
      Push lock_super() into the ->remount_fs() of filesystems that care =
about it
      Push BKL into do_mount()
      Push BKL down beyond VFS-only parts of do_mount()
      Push BKL down into do_remount_sb()
      New helper - simple_fsync()
      Sanitize qnx4 fsync handling
      fs/qnx4: sanitize includes
      Sanitize ->fsync() for FAT
      switch ext2 to simple_fsync()
      switch minix to simple_fsync()
      repair sysv_write_inode(), switch sysv to simple_fsync()
      switch ufs to simple_fsync()
      switch udf to simple_fsync()
      switch omfs to simple_fsync()
      repair adfs ->write_inode(), switch to simple_fsync()
      Fix adfs GET_FRAG_ID() on big-endian
      repair bfs_write_inode(), switch bfs to simple_fsync()
      sanitize ->fsync() for affs
      No instance of ->bmap() needs BKL
      fuse doesn't need BKL in ->umount_begin()
      9P doesn't need BKL in ->umount_begin()
      Cleanup of adfs headers
      befs ->pust_super() doesn't need BKL
      get rid of BKL in fs/efs
      get rid of BKL in fs/minix
      get rid of BKL in fs/sysv
      Fix rule eviction order for AUDIT_DIR
      Make allocation of anon devices cheaper
      ... and the same for vfsmount id/mount group id
      add caching of ACLs in struct inode
      switch ext2 to inode->i_acl
      switch ext3 to inode->i_acl
      switch ext4 to inode->i_acl
      switch jfs to inode->i_acl
      switch jffs2 to inode->i_acl
      switch btrfs to inode->i_acl
      switch nilfs2 to inode->i_acl
      reiserfs: minimal fix for ACL caching
      switch reiserfs to usual conventions for caching ACLs
      switch reiserfs to inode->i_acl
      switch shmem to inode->i_acl
      helpers for acl caching + switch to those
      switch xfs to generic acl caching helpers
      Get "no acls for this inode" right, fix shmem breakage
      another race fix in jfs_check_acl()

Alan Carvalho de Assis (1):
      i.MX31: Add hw-random for RNGA

Alan Cox (42):
      [SCSI] gdth: fix overlapping snprintf users
      ata_piix: Turn on hotplugging support for older chips
      ata_piix: Remove stale comment
      tty: Add carrier processing on close to the tty_port core
      tty: Implement a drain delay in the tty port
      tty: Bring the usb tty port structure into more use
      tty: Update cdc_acm
      tty: cdc_acm add krefs
      tty: Clean up the ACM driver to CodingStyle
      tty: throttling race fix
      serial: update maintainers file
      pty: Fix a comment
      tty: Fix oops when scanning the polling list for kgdb
      tty: Extract various bits of ldisc code
      tty: rewrite the ldisc locking
      tty: Move ldisc_flush
      tty: bring ldisc into CodingStyle
      tty: remove buffer special casing
      tty: simplify buffer allocator cleanups
      parport_pc: Coding style
      parport_pc: clean up the modified while loops using for
      ft232: support the ASYNC_LOW_LATENCY flag
      tty: fix bluetooth scribbling on low latency flags
      ftdi_sio: don't override modem bits
      tty: Untangle termios and mm mutex dependencies
      devpts: unregister the file system on error
      tty: Add URL for ttydev queue
      timbuart: Fix the termios logic
      tty: resolve some sierra breakage
      pty: Narrow the race on ldisc locking
      tty: Fix leaks introduced by the shift to separate ldisc objects
      tty: Fix leaks introduced by the shift to separate ldisc objects
      ldisc: Make sure the ldisc isn't active when we close it
      ldisc: debug aids
      pty: Narrow the race on ldisc locking
      tty: fix sanity check
      V4L/DVB (11959): se401: Fix unsafe use of sprintf with identical so=
urce/destination
      V4L/DVB (11998): se401: Fix coding style
      uml: UML net driver does not allow for vlans
      ppp: Fix throttling bugs
      tty: fix some bogns in the serqt_usb2 driver
      msm: fixups to match current code

Alan D. Brunelle (2):
      blktrace: correct remap names
      blktrace: from-sector redundant in trace_block_remap

Alan Jenkins (7):
      rfkill: remove set_global_sw_state
      sony-laptop: no need to unblock rfkill on load
      rfkill: don't impose global states on resume (just restore the prev=
ious states)
      rfkill: rfkill_set_block() when suspended nitpick
      rfkill: don't restore software blocked state on persistent devices
      eeepc-laptop: read rfkill soft-blocked state on resume
      rfkill: export persistent attribute in sysfs

Alan Nisota (1):
      V4L/DVB (11833): dvb-usb: Remove support for Genpix-CW3K (damages h=
ardware)

Alan Stern (13):
      [SCSI] Increase default timeout for INQUIRY
      PM core: rename suspend and resume functions
      USB: consolidate usb_unbind_interface and usb_driver_release_interf=
ace
      NLS: update handling of Unicode
      USB: g_file_storage: use the "unaligned" accessors
      PCI: add power-state name strings
      USB: move PCI host controllers to new PM framework
      USB: new flag for resume-from-hibernation
      USB: usb-storage: fix return values from init functions
      USB: EHCI: stagger frames for interrupt transfers
      USB: EHCI: update toggle state for linked QHs
      USB: usb-serial: call port_probe and port_remove at the right times
      USB: usb-serial: replace shutdown with disconnect, release

Alasdair G Kergon (1):
      dm: initialise tio in alloc_tio

Alban Browaeys (1):
      rt2x00: Style fix for interval defines

Alberto Bertogli (1):
      jbd2: Fix minor typos in comments in fs/jbd2/journal.c

Alberto Panizzo (3):
      ARM MXC: Make-sure-ipg_per_clk-is-generated-by-ipg_clk-and-not-usb_=
pll
      Atmark Armadillo 500 board support.
      ARM MXC: Atmark Armadillo 500 board support.

Alek Du (1):
      Input: gpio-keys - change timer to workqueue

Alessandro Rubini (2):
      [ARM] 5505/1: serial amba-pl011: move to arch_initcall for earlier =
console
      [ARM] 5541/1: serial/amba-pl011.c: add support for the modified por=
t found in Nomadik

Alessio Igor Bogani (6):
      Push BKL down into ->remount_fs()
      trivial: input/misc: Fix typo in Kconfig
      V4L/DVB (11842): radio-mr800.c: missing mutex include
      Staging: comedi: replace __FUNCTION__ usages
      Staging: sxg: replace __FUNCTION__ usages
      Staging: rt3070: replace __FUNCTION__ usages

Alex Chiang (21):
      ACPICA: Eliminate extra call to NsGetParentNode
      PCI Hotplug: cpqphp: stray whitespace cleanups
      PCI Hotplug: cpqphp: fix comment style
      PCI Hotplug: cpqphp: obey 80 column convention in cpqphp.h
      PCI Hotplug: cpqphp: remove useless prototypes in cpqphp_core.c
      PCI Hotplug: cpqphp: eliminate stray braces
      PCI Hotplug: cpqphp: refactor cpqhp_probe
      PCI Hotplug: cpqphp: clean up cpqphp_ctrl.c
      PCI Hotplug: cpqphp: refactor cpqphp_save_slot_config
      PCI Hotplug: cpqphp: style cleanups
      PCI Hotplug: cpqphp: refactor cpqhp_save_config
      PCI Hotplug: cpqphp: clean up accesses to pcibios_get_irq_routing_t=
able()
      PCI Hotplug: cpqphp: eliminate dead code - PCI_ScanBusNonBridge
      PCI Hotplug: cpqphp: constify slot_name()
      PCI Hotplug: cpqphp: don't use pci_find_slot()
      PCI: remove deprecated pci_find_slot() interface
      PCI: eliminate redundant pci_stop_dev() call from pci_destroy_dev()
      trivial: fix grammo in bus_for_each_dev() kerneldoc
      ACPI: acpi_device_register() should call device_register()
      ACPI: clean up whitespace in drivers/acpi/scan.c
      PCI: drivers/pci/slot.c should depend on CONFIG_SYSFS

Alex Deucher (3):
      drm/radeon: add rv740 drm support.
      drm/radeon: add support for RV790.
      radeon legacy chips: tv dac bg/dac adj updates

Alex Nixon (1):
      Xen: Add virt_to_pfn helper function

Alex Riesen (1):
      crypto: api - Use formatting of module name

Alexander Beregalov (62):
      ASoC: n810: replace BUG() with BUG_ON()
      drivers/net: replace BUG() with BUG_ON() if possible
      ipw2x00: remove old compat_net_dev_ops code
      usbnet: remove old compat_net_dev_ops code
      8390(p): remove old compat_net_dev_ops code
      bmac: convert to net_device_ops
      cpmac: convert to net_device_ops
      dm9000: convert to net_device_ops
      hplance: convert to net_device_ops
      ibmveth: convert to net_device_ops
      irda/au1k_ir: convert to net_device_ops
      irda/pxaficp_ir: convert to net_device_ops
      irda/sa1100_ir: convert to net_device_ops
      iseries_veth: convert to net_device_ops
      ixp2000/ixpdev: convert to net_device_ops
      jazzsonic: convert to net_device_ops
      korina: convert to net_device_ops
      lib82596: convert to net_device_ops
      mace: convert to net_device_ops
      macmace: convert to net_device_ops
      meth: convert to net_device_ops
      mipsnet: convert to net_device_ops
      mvme147: convert to net_device_ops
      netx-eth: convert to net_device_ops
      pasemi_mac: convert to net_device_ops
      pci-skeleton: convert to net_device_ops
      rionet: convert to net_device_ops
      sb1250-mac: convert to net_device_ops
      sgiseeq: convert to net_device_ops
      smc911x: convert to net_device_ops
      sun3lance: convert to net_device_ops
      irda: include etherdevice.h for eth_*() functions
      wan/pc300_drv: convert to net_device_ops
      iseries_veth: fix build breakage
      sa1100_ir: fix build breakage
      8390p: fix build breakage
      vxge: fix possible NULL dereference in vxge-traffic.c
      vxge: use max() instead of VXGE_HW_SET_LEVEL
      lasi_82596: fix printk format warning
      ar9170: fix build when !CONFIG_PM
      ALSA: parisc/harmony: fix printk format warning
      de620: fix forgotten semicolon
      de600: convert PRINTK() to pr_debug()
      de620: convert PRINTK() to pr_debug() and cleanup
      mac89x0: remove PRINTK()
      skfddi: convert PRINTK() to pr_debug()
      Staging: agnx: switch config_interface to bss_info_changed
      net: remove COMPAT_NET_DEV_OPS
      3c50x: convert printk() to pr_<foo>()
      3c5xx: convert printk() to pr_<foo>()
      8139*: convert printk() to pr_<foo>()
      ALSA: hda_intel: fix build error when !PM
      cfg80211: errno.h: define ERFKILL
      sata_sx4: speed up ECC initialization
      SLUB: fix build when !SLUB_DEBUG
      Staging: comedi: comedi_test.c should include timer.h
      Staging: comedi: data.c should include delay.h
      Staging: agnx: replace print_mac with %pM
      Staging: rtl8187se: convert to net_device_ops
      Staging: stlc45xx: replace print_mac with %pM
      Staging: cpc-usb: depends on PROC_FS
      Staging: cpc-usb: fix printk format warnings

Alexander Chiang (12):
      ACPI: make acpi_pci_bind() static
      ACPI: Introduce acpi_is_root_bridge()
      ACPI: Introduce acpi_get_pci_dev()
      ACPI: rearrange acpi_pci_bind/acpi_pci_unbind in pci_bind.c
      ACPI: eviscerate pci_bind.c
      ACPI: simplify acpi_pci_irq_add_prt() API
      ACPI: simplify acpi_pci_irq_del_prt() API
      ACPI: acpi_pci_unbind should clean up properly after acpi_pci_bind
      PCI Hotplug: acpiphp: convert to acpi_get_pci_dev
      ACPI: kill acpi_get_pci_id
      ACPI: video: convert to acpi_get_pci_dev
      ACPI: kill acpi_get_physical_pci_device()

Alexander Clouter (3):
      hwrng: timeriomem - Fix potential oops (request_mem_region/__devini=
t)
      [ARM] orion: add hwrng timeriomem hook to TS-78xx
      mtd: extend plat_nand for (read|write)_buf

Alexander Duyck (20):
      igb: always use adapter->itr as EITR value
      igb: reconfigure mailbox timeout logic
      igb: make rxcsum configuration seperate from multiqueue
      igb/ixgbe: remove unecessary checks for CHECKSUM_UNNECESSARY
      ixgbe: enable HW RSC for 82599
      igbvf: cleanup flags and allow for rx checksum to be disabled
      igb/igbvf: set rx csum always enabled in hw, disable via sw
      pci: update 82576 sr-iov quirk with latest device IDs
      ixgbe: make q_vectors dynamic to reduce netdev size
      ixgbe: skb_record_rx_queue should record rx queue instead of vector
      ixgbe: remove ixgbe_napi_add/del_all references
      ixgbe: always set header length in SRRCTL
      ixgbe: set queue0 for srrctl configuration correctly for DCB
      ixgbe: set max desc to prevent total RSC packet size of 64K
      igb: do not re-register DCA requester on device reset
      ixgbe: only register DCA requester once
      igb/e1000e: update PSSR_MDIX value to reflect correct bit
      ixgbe: use rx_buffer_info->dma instead of nr_frags to determine skb=
 unmap
      ixgbe: move v_idx into q_vector and use as index only
      ixgbe: move tx processing into NAPI context

Alexander Schmidt (1):
      IB/ehca: Bump version number

Alexander Y. Fomichev (1):
      jsm: correctly support multiple 4/8-port boards

Alexander van Heukelum (4):
      x86: fix function definitions after: x86: apic - introduce imcr_ he=
lpers
      i386: fix return to 16-bit stack from NMI handler
      i386: fix/simplify espfix stack switching, move it into assembly
      x86: de-assembler-ize asm/desc.h

Alexandre Becholey (1):
      rt73usb: fix for master mode

Alexandros Batsakis (1):
      nfsd41: move channel attributes from nfsd4_session to a nfsd4_chann=
el_attr struct

Alexey Dobriyan (15):
      netns 1/2: don't get/put old netns on CLONE_NEWNET
      netns 2/2: extract net_create()
      x86, 32-bit: ifdef out struct thread_struct::fs
      x86, 64-bit: ifdef out struct thread_struct::ip
      dcache: extrace and use d_unlinked()
      mm: consolidate init_mm definition
      groups: move code to kernel/groups.c
      pidns: make create_pid_namespace() accept parent pidns
      pidns: rewrite copy_pid_ns()
      utsns: extract creeate_uts_ns()
      ipcns: remove useless get/put while CLONE_NEWIPC
      ipcns: extract create_ipc_ns()
      nsproxy: extract create_nsproxy()
      ipcns: make free_ipc_ns() static
      ipcns: move free_ipcs() proto

Alexey Klimov (7):
      V4L/DVB (11447): gspca - mr97310a: Return good error code in mod_in=
it.
      V4L/DVB (11569): av7110_hw: fix compile warning
      V4L/DVB (11954): dsbr100: remove radio->users counter
      V4L/DVB (11955): dsbr100: remove usb_dsbr100_open/close calls
      V4L/DVB (11956): dsbr100: no need to pass curfreq value to dsbr100_=
setfreq()
      V4L/DVB (11957): dsbr100: change radio->muted to radio->status, upd=
ate suspend/resume
      V4L/DVB (11997): gspca - stv06xx: remove needless if check and goto

Alexey Zaytsev (1):
      [SCSI] compat: don't perform unneeded copy in sg_io code

Ali Gholami Rudi (1):
      trivial: ext2: fix a typo in comment in ext2.h

Amerigo Wang (11):
      x86: merge process.c a bit
      x86: process.c, remove useless headers
      kbuild: clean up scripts/headers.sh
      kbuild/headers_check: refine extern check
      x86 module: merge the same functions in module_32.c and module_64.c
      x86 module: merge the rest functions with macros
      uml module: fix uml build process due to this merge
      module: merge module_alloc() finally
      kbuild: fix a compile warning
      uml: fix a section warning
      kbuild: fix build error during make htmldocs

Amit Kumar Salecha (1):
      netxen: enable GRO support

Amit Shah (1):
      KVM: x86: Ignore reads to EVNTSEL MSRs

Amul Saha (1):
      mtd: OneNAND: Allow setting of boundary information when built as m=
odule

Anand Gadiyar (1):
      musb: use dma mode 1 for TX if transfer size equals maxpacket (v2)

Anant Gole (1):
      net: Add TI DaVinci EMAC driver

Anders Kaseorg (2):
      Staging: rt2860: Don't call sprintf() with overlapping input and ou=
tput.
      Staging: rt2870: Don't call sprintf() with overlapping input and ou=
tput.

Andi Kleen (48):
      oprofile: re-add force_arch_perfmon option
      oprofile: remove undocumented oprofile.p4force option
      oprofile: add support for Core i7 and Atom
      x86, mce: initial steps to make 64bit mce code 32bit clean
      x86, mce: implement the PPro bank 0 quirk in the 64bit machine chec=
k code
      x86, mce: port K7 bank 0 quirk to 64bit mce code
      x86, mce: use a call vector to call the 64bit mce handler
      x86, mce: rename 64bit mce_dont_init to mce_disabled
      x86, mce: move mce_disabled option into common 32bit/64bit code
      x86, mce: remove machine check handler idle notify on 64bit
      x86, mce: remove oops_begin() use in 64bit machine check
      x86, mce: use 64bit machine check code on 32bit
      x86, mce: deprecate old 32bit machine check code
      x86, mce: enable MCE_INTEL for 32bit new MCE
      x86, mce: enable MCE_AMD for 32bit NEW_MCE
      x86, mce: document new 32bit mcelog requirement in Documentation/Ch=
anges
      Export add_timer_on for modules
      x86, mce: add MSR read wrappers for easier error injection
      x86, mce: add basic error injection infrastructure
      x86, mce: synchronize core after machine check handling
      x86, mce: use extended sysattrs for the check_interval attribute.
      x86, mce: remove unused mce_events variable
      x86, mce: rename and align out2 label
      x86, mce: drop BKL in mce_open
      x86, mce: improve documentation
      x86: trivial clean up for irq_vectors.h
      x86, mce: add machine check exception count in /proc/interrupts
      x86, mce: add MCE poll count to /proc/interrupts
      x86, mce: store record length into memory struct mce anchor
      x86, mce: support more than 256 CPUs in struct mce
      x86, mce: extend struct mce user interface with more information.
      x86, mce: log corrected errors when panicing
      x86, mce: remove TSC print heuristic
      x86, mce: add table driven machine check grading
      x86, mce: check early in exception handler if panic is needed
      x86, mce: implement bootstrapping for machine check wakeups
      x86, mce: implement panic synchronization
      x86, mce: switch x86 machine check handler to Monarch election.
      x86, mce: make non Monarch panic message "Fatal machine check" too
      x86, mce: default to panic timeout for machine checks
      x86, mce: print header/footer only once for multiple MCEs
      x86, mce: implement new status bits
      x86: fix panic with interrupts off (needed for MCE)
      x86, mce: rename mce_notify_user to mce_notify_irq
      x86, mce: define MCE_VECTOR
      x86, mce: support action-optional machine checks
      KVM: Add VT-x machine check support
      x86: mce: Handle banks =3D=3D 0 case in K7 quirk

Andre Detsch (1):
      e100: Fix napi_enable BUG_ON when recovering from EEH error

Andre Lopes (1):
      staging: b3dfg: clean up MODULE_PARM_DESC newline

Andre Noll (13):
      md: raid0: Replace hash table lookup by looping over all strip_zone=
s.
      md: raid0: Remove hash table.
      md: raid0: Remove hash spacing and sector shift.
      md: raid0: Make raid0_run() return a proper error code.
      md: raid0: Allocate all buffers for the raid0 configuration in one =
function.
      md: raid0: Fix a memory leak when stopping a raid0 array.
      md: Make mddev->chunk_size sector-based.
      md: Convert mddev->new_chunk to sectors.
      md: convert conf->chunk_size and conf->prev_chunk to sectors.
      md/raid5: Use is_power_of_2() in raid5_reconfig()/raid6_reconfig().
      md: fix some comments.
      md: Push down reconstruction log message to personality code.
      md: Move check for bitmap presence to personality code.

Andre Prendel (2):
      hwmon: (tmp401) Add support for TI's TMP411 sensors chip
      hwmon: (tmp401) Add documentation

Andre Przywara (2):
      KVM: SVM: Fix cross vendor migration issue in segment segment descr=
iptor
      8250_pci: add the OXCB950 chip to the 8250 PCI driver.

Andrea Borgia (3):
      ALSA: usb-audio - quirk for USB Aureon cards
      ALSA: usb-audio - errata corrige for quirk
      ALSA: usb-audio - rework quirk for TerraTec Aureon USB 5.1 MkII

Andreas Dilger (2):
      ext4: super.c whitespace cleanup
      ext4: teach the inode allocator to use a goal inode number

Andreas Eversberg (12):
      mISDN: Add watchdog functionality to hfcmulti driver
      mISDN: DSP now uses ring buffer for echo canceler
      mISDN: Echo canceler now gets delay information from hardware
      mISDN: Fixed missing spin lock on pipeline process
      mISDN: Added layer-1-hold feature
      mISDN: Fix DTMF locking bug issue
      mISDN: Hardware acceleration is now possible in conjunction with au=
dio recording
      mISDN: Fix TEI and SAPI handling
      mISDN: Add "sapi" information to debug messages
      mISDN: Add PCI ID for Junghanns 8S card
      mISDN: Fix DTMF detection enable/disable
      mISDN: Added PCI ID for new Junghanns.net Single E1 cards.

Andreas Herrmann (9):
      x86: cacheinfo: use L3 cache index disable feature only for CPUs th=
at support it
      x86: cacheinfo: correct return value when cache_disable feature is =
not active
      x86: cacheinfo: use cached K8 NB_MISC devices instead of scanning f=
or it
      x86: cacheinfo: complete L2/L3 Cache and TLB associativity field de=
finitions
      x86: fixup numa_node information for AMD CPU northbridge functions
      x86: display extended apic registers with print_local_APIC and cpu_=
debug code
      x86: memtest: remove 64-bit division
      x86: Detect use of extended APIC ID for AMD CPUs
      x86/PCI: add description for check_enable_amd_mmconf boot parameter

Andreas Mohr (2):
      e100: add non-MII PHY support
      mISDN: Free hfcpci IRQ if init was not successful

Andreas Regel (14):
      V4L/DVB (11580): budget-ci: Fix incorrect default CLOCK setup
      V4L/DVB (11583): isl6423: Various fixes to use external modulation
      V4L/DVB (11584): stv090x: add tone burst control
      V4L/DVB (11585): stv090x: fix incorrectly used mode
      V4L/DVB (11592): stv6110x: Fix read bug
      V4L/DVB (11593): stv090x: Fix Rolloff
      V4L/DVB (11594): stv090x: Fix incorrect TSMODE usage
      V4L/DVB (11595): stv090x: fixes a few bugs
      V4L/DVB (11596): stv090x: fixes some register definitions
      V4L/DVB (11597): stv090x: fixes read_status to return 0 in case of =
no error
      V4L/DVB (11598): stv090x: fix missing wakeup in init
      V4L/DVB (11599): S2-1600: Use budget driver instead of budged-ci
      V4L/DVB (11600): budget: Use Continuous clock
      V4L/DVB (11601): stv090x: update demodulator capabilities

Andrew Gallatin (1):
      myri10ge: fix compile error

Andrew Morton (14):
      mutex: add atomic_dec_and_mutex_lock(), fix
      net/rfkill/rfkill.c: fix build with CONFIG_RFKILL_LEDS=3Dn
      splice: fix error return code
      drivers/net/82596.c: suppress warnings
      microblaze: remove unused flat_stack_align() definition
      cciss: use schedule_timeout_interruptible()
      [CPUFREQ] reduce scope of ACPI_PSS_BIOS_BUG_MSG[]
      + drivers-usb-serial-sierrac-fix-printk-warning.patch added to -mm =
tree
      page-allocator: warn if __GFP_NOFAIL is used for a large allocation
      headers: move module_bug_finalize()/module_bug_cleanup() definition=
s into module.h
      Documentation/vm/Makefile: don't try to build slqbinfo
      MAINTAINERS: fbdev is orphaned
      convert some DMA_nnBIT_MASK() callers
      jsm: clean up "serial: jsm: correctly support 4 8 port boards"

Andrew Patterson (2):
      cciss: add cciss driver sysfs entries
      PCI: Add support for turning PCIe ECRC on or off

Andrew Vasquez (28):
      [SCSI] qla2xxx: Export additional FCoE attributes for application s=
upport.
      [SCSI] qla2xxx: Correct compilation failures when DEBUG'n' options =
are enabled.
      [SCSI] qla2xxx: Correct typo in read_nvram() callback.
      [SCSI] qla2xxx: Restrict model-name/description device-table usage.
      [SCSI] qla2xxx: Don't try to 'stop' firmware if already in ROM code.
      [SCSI] qla2xxx: Add an override option to specify ISP firmware load=
 semantics.
      [SCSI] qla2xxx: Update version number to 8.03.01-k2.
      [SCSI] qla2xxx: Export negotiated fabric-parameters for application=
 support.
      [SCSI] qla2xxx: Export XGMAC statistics on supported ISPs.
      [SCSI] qla2xxx: Export TLV data on supported ISPs.
      [SCSI] qla2xxx: Correct logic-bug in set-model-info().
      [SCSI] qla2xxx: Fallback to 'golden-firmware' operation on supporte=
d ISPs.
      [SCSI] qla2xxx: Use 'proper' DID_* status code for dropped-frame sc=
enarios.
      [SCSI] qla2xxx: Check status of qla2x00_get_fw_version() call.
      [SCSI] qla2xxx: Mark a port's state as needing-rediscovery during l=
ink disruptions.
      [SCSI] qla2xxx: Add 10Gb iiDMA support.
      [SCSI] qla2xxx: Add notification message when an NPIV fails to acqu=
ire a port-id.
      [SCSI] qla2xxx: Fallback enode-mac should not be a multicast addres=
s.
      [SCSI] qla2xxx: Avoid redundant RISC reset during (re)-initializati=
on.
      [SCSI] qla2xxx: Query supported RISC registers bits in determining =
a paused-state.
      [SCSI] qla2xxx: Avoid explicit LOGO during driver host tear-down.
      [SCSI] qla2xxx: Reduce lock-contention during do-work processing.
      [SCSI] qla2xxx: Export additional firmware-states for application s=
upport.
      [SCSI] qla2xxx: Synchronize MPI settings after a PE Reset.
      [SCSI] qla2xxx: Update version number to 8.03.01-k3.
      qla2xxx: Limit querying to supported mailbox-registers while readin=
g FW state.
      qla2xxx: Correct (again) overflow during dump-processing on large-m=
emory ISP23xx parts.
      qla2xxx: Update version number to 8.03.01-k4.

Andrew de Quincey (1):
      ARM: OMAP1: Make 770 LCD work

Andrey Yurovsky (3):
      libertas: fix IEEE PS mode in GSPI driver
      cfg80211: allow adding/deleting stations on mesh
      cfg80211: allow setting station parameters in mesh

Andr=C3=A9 Goddard Rosa (1):
      usbnet: ratelimit warning messages invoked from callback handler

Andy Adamson (46):
      nfsd41: sanity check client drc maxreqs
      nfs41: sessions client infrastructure
      nfs41: introduce nfs4_call_sync
      nfs41: set up seq_res.sr_slotid
      nfs41: xdr {encode,decode}_sequence
      nfs41: nfs4_setup_sequence
      nfs41: setup_sequence method
      nfs41: free slot
      nfs41: nfs41_sequence_free_slot
      nfs41: nfs41_sequence_done
      nfs41: nfs41_call_sync_done
      nfs41: close sequence setup/done support
      nfs41: open sequence setup/done support
      nfs41: lock sequence setup/done support
      nfs41: locku sequence setup/done support
      nfs41: unlink sequence setup/done support
      nfs41: read sequence setup/done support
      nfs41 write sequence setup done support
      nfs41 commit sequence setup done support
      nfs41 delegreturn sequence setup done support
      nfs41: get_lease_time
      nfs41: create_session operation
      nfs41: verify session channel attribues
      nfs41: use session attributes for rsize and wsize
      nfs41: destroy_session operation
      nfs41: enable nfs_client only nfs4_async_handle_error
      nfs41: sequence operation
      nfs41: reset the session slot table
      nfs41: add session setup to the state manager
      nfs41: add session reset to state manager
      nfs41: sunrpc: Export the call prepare state for session reset
      nfs41: use rpc prepare call state for session reset
      nfs41: kick start nfs41 session recovery when handling errors
      nfs41: schedule async session reset
      nfs41: introduce get_state_renewal_cred
      nfs41: establish sessions-based clientid
      nfs41: add a get_clid_cred function to nfs4_state_recovery_ops
      nfs41: get_clid_cred for EXCHANGE_ID
      nfs41: only retry EXCHANGE_ID on recoverable errors
      nfs41: sunrpc: add a struct svc_xprt pointer to struct svc_serv for=
 backchannel use
      nfs41: Allow NFSv4 and NFSv4.1 callback services to coexist
      nfs41: Setup the backchannel
      nfs41: Client indicates presence of NFSv4.1 callback channel.
      nfs41: Release backchannel resources associated with session
      nfsd41: Backchannel: cleanup nfs4.0 callback encode routines
      nfsd41: Backchannel: minorversion support for the back channel

Andy Gospodarek (1):
      e1000e: stop unnecessary polling when using msi-x

Andy Green (4):
      [MTD] [NAND] S3C2410: NAND ECC by chip rather than global
      [MTD] [NAND] S3C2410: Fix CFG debug order
      [MTD] [NAND] S3C2410: Allow commandline partition processing
      [ARM] GTA02/FreeRunner: Add machine definition

Andy Grover (4):
      RDS: Correct some iw references in rdma_transport.c
      RDS: Fix ordering in a conditional
      RDS: Establish connection before parsing CMSGs
      RDS: use get_user_pages_fast()

Andy Shevchenko (1):
      V4L/DVB (11442): saa7134: BZ#7524: Add AVerTV Studio 507UA support

Andy Walls (21):
      V4L/DVB (11615): cx18: Rename the work queue to "in_work_queue"
      V4L/DVB (11616): cx18: Add a work queue for deferring empty buffer =
handoffs to the firmware
      V4L/DVB (11617): cx18: Set up to wait for a one-shot response befor=
e sending a firmware cmd
      V4L/DVB (11618): cx18: Convert per stream mutex locks to per queue =
spin locks
      V4L/DVB (11619): cx18: Simplify the work handler for outgoing mailb=
ox commands
      V4L/DVB (11620): cx18: Increment version due to significant buffer =
handling changes
      V4L/DVB (11622): cx18: Allow IVTV format VBI insertion in MPEG-2 SV=
CD and DVD streams
      V4L/DVB (11623): cx18: Verify cx18-av-core digitizer firmware loads=
 correctly
      V4L/DVB (11624): cx18: Toggle the AI1 mux when changing the CX18_AU=
DIO_ENABLE register
      V4L/DVB (11703): cx18: Have audio decoder drive SIF gain control, a=
nd rework AFE config
      V4L/DVB (11752): cx18: Add missing newline to tuner detection error=
 message
      V4L/DVB (11753): tveeprom: Point the TCL MNM05-4 tuner entry to an =
actual tuner definition
      V4L/DVB (11863): cx18: Initial attempt to get sliced VBI working fo=
r 625 line systems
      V4L/DVB (11864): cx18: Complete support for Sliced and Raw VBI for =
625 line systems
      V4L/DVB (11865): cx18: Tweak color burst gate delay and initial col=
or sub-carrier freq
      V4L/DVB (11898): cx18: Perform 64 bit divide so it works for 32 bit=
 systems
      V4L/DVB (11931): lnbp21: Add missing newline
      V4L/DVB (11932): ivtv: Add missing newline
      V4L/DVB (11933): tuner-simple, tveeprom: Add Philips FQ1216LME MK3 =
analog tuner
      V4L/DVB (11950): cx18: Split LeadTek PVR2100 and DVR3100 H into 2 s=
eparate card entries
      V4L/DVB (11951): cx18: Add DVB-T support for the Leadtek WinFast DV=
R3100 H

Andy Yan (7):
      [SCSI] mvsas: add support for 94xx; layout change; bug fixes
      [SCSI] mvsas: bug fix with setting task management frame type
      [SCSI] mvsas: bug fix of dead lock
      [SCSI] mvsas: bug fix, null pointer may be used
      [SCSI] mvsas: correct bit map usage
      [SCSI] mvsas: performance improvement using domain_device->lldd_dev
      [SCSI] mvsas: remove all the casts from void * or to void *

Aneesh Kumar K.V (9):
      ext4: Properly initialize the buffer_head state
      vfs: Add BUG_ON for delayed and unwritten flags in submit_bh()
      ext4: Mark the unwritten buffer_head as mapped during write_begin
      ext4: hook fiemap operation for directories
      vfs: Enable FS_IOC_FIEMAP and FIGETBSZ for all filetypes
      ext4: Convert ext4_lock_group to use sb_bgl_lock
      ext4: Avoid leaking blocks after a block allocation failure
      ext4: truncate the file properly if we fail to copy data from users=
pace
      ext4: Avoid corrupting the uninitialized bit in the extent during t=
runcate

Anirban Chakraborty (8):
      [SCSI] qla2xxx: Add QoS support.
      [SCSI] qla2xxx: Add CPU affinity support.
      [SCSI] qla2xxx: Remove reference to request queue from scsi request=
 block.
      [SCSI] qla2xxx: Use port number to compute nvram/vpd parameter offs=
ets.
      [SCSI] qla2xxx: Correct queue-creation bug when driver loaded in Qo=
S mode.
      [SCSI] qla2xxx: Correct NULL pointer bug in cpu affinity mode.
      [SCSI] qla2xxx: Resolve a performance issue in interrupt
      qla2xxx: Fixed a bug in number of response queue creation logic.

Ankit Jain (1):
      fs: Add new pre-allocation ioctls to vfs for compatibility with leg=
acy xfs ioctls

Anna Neal (1):
      libertas: increase spi driver thread priority

Anton Blanchard (4):
      IB/ehca: Replace vmalloc() with kmalloc() for queue allocation
      powerpc: Improve decrementer accuracy
      powerpc: Convert RTAS event scan from kernel thread to workqueue
      sunrpc: align cache_clean work's timer

Anton Vorontsov (20):
      alim15x3: Remove historical hacks, re-enable init_hwif for PowerPC
      powerpc/85xx: Add PCI IDs for MPC8569 family processors
      powerpc/85xx: Fix mpc8569emds crypto node to include SNOW unit
      powerpc/85xx: Fix reg & interrupts for mpc8569emds localbus added N=
AND
      powerpc/85xx: Add eSDHC support for MPC8569E-MDS boards
      powerpc/85xx: Enable Serial RapidIO for MPC85xx MDS boards
      powerpc/85xx: Add STMicro M25P40 serial flash support for MPC8569E-=
MDS
      powerpc/83xx: Update sdhci nodes per new bindings
      powerpc/5200: convert mpc52xx_psc_spi to use cs_control callback
      mpc52xx_psc_spi: convert to cs_control callback
      spi_mpc83xx: handle other Freescale processors
      spi_mpc83xx: quieten down the "Requested speed is too low" message
      spi_mpc83xx: add small delay after asserting chip-select line
      powerpc/86xx: add MMC SPI support for MPC8610HPCD boards
      spi_mpc83xx: fix checkpatch issues
      spi_mpc83xx: split mpc83xx_spi_work() into two routines
      spi_mpc83xx: remove dead code
      spi_mpc83xx: rename spi_83xx.c to spi_8xxx.c
      spi_mpc8xxx: s/83xx/8xxx/g
      sdhci: Add support for hosts that are only capable of 1-bit transfe=
rs

Antonio Ospite (1):
      [ARM] pxa/ezx: setup gpio-keys for EzX phones

Antti Palosaari (3):
      V4L/DVB (11490): af9015: add new dvb_usb_device_properties entry fo=
r upcoming USB IDs
      V4L/DVB (11491): af9015: support for AverMedia AVerTV Volar GPS 805=
 (A805)
      V4L/DVB (11915): af9015: support for Genius TVGo DVB-T03

Anuj Aggarwal (1):
      ASoC: Added OMAP3 EVM support in ASoC.

Aoi Shinkai (1):
      sh: Fix sh4a llsc-based cmpxchg()

Aristeu Sergio Rozanski Filho (1):
      Input: uinput - flush all pending ff effects before destroying devi=
ce

Arjan van de Ven (4):
      perf_counter tools: Warning fixes on 32-bit
      perf_counter tools: Initialize a stack variable before use
      [libata] ata_piix: Enable parallel scan
      pci: use pci_ioremap_bar() in drivers/serial

Armin Kuster (1):
      Sysfs: fix possible memleak in sysfs_follow_link

Armin Schenker (1):
      V4L/DVB (11571): Add Elgato EyeTV DTT deluxe to dibcom driver

Arnaldo Carvalho de Melo (29):
      inet_diag: Remove dup assignments
      net: Make inet_twsk_put similar to sock_put
      perf record: Allow specifying a pid to record
      mISDN: Use kernel_{send,recv}msg instead of open coding
      perf_counter: First part of 'perf report' conversion to C + elfutil=
s
      perf_counter: Implement dso__load using libelf
      perf_counter: Use rb_trees in perf report
      perf_counter: Add our private copy of list.h
      perf_counter: Use rb_tree for symhists and threads in report
      perf report: Fix kernel symbol resolution
      perf: Don't assume /proc/kallsyms is ordered
      perf report: Sort output by symbol usage
      perf report: Use hex2long instead of sscanf
      perf report: Only load text symbols from kallsyms
      perf report: Show the IP only in --verbose mode
      perf_counter tools: Move symbol resolution classes from report to l=
ibperf
      perf_counter tools: struct symbol priv area
      perf_counter tools: Consolidate dso methods to load kernel symbols
      perf_counter tools: Optionally pass a symbol filter to the dso load=
 routines
      perf_counter tools: Convert builtin-top to use libperf symbol routi=
nes
      perf_counter tools: Shorten the DSO names using cwd
      perf_counter tools: Add locking to perf top
      perf_counter tools: Add string.[ch]
      perf_counter tools: Use hex2u64 in more places
      perf_counter tools: Add missing rb_erase in dso__delete_symbols
      perf_counter tools: Cover PLT symbols too
      perf_counter tools: Fix off-by-one bug in symbol__new
      perf report: Fix rbtree bug
      perf report: Add -vvv to print the list of threads and its mmaps

Arnd Bergmann (36):
      microblaze: export some symbols
      microblaze: fix __user annotations
      microblaze: kill incorrect __bad_xchg definition
      microblaze: remove cacheable_memcpy
      microblaze: add security initcalls
      microblaze: add a dummy pgprot_noncached
      microblaze: do not include types.h in ptrace.h
      microblaze: remove bad_user_access_length
      microblaze: clean up checksum.c
      microblaze: use generic dma-mapping-broken.h
      x86: fix ktermios-termio conversion
      asm-generic: rename termios.h, signal.h and mman.h
      asm-generic: introduce asm/bitsperlong.h
      asm-generic: add generic sysv ipc headers
      asm-generic: add generic ABI headers
      asm-generic: add a generic unistd.h
      asm-generic: rename atomic.h to atomic-long.h
      asm-generic: rename page.h and uaccess.h
      asm-generic: make get_rtc_time overridable
      asm-generic: make pci.h usable directly
      asm-generic: make bitops.h usable
      asm-generic: add generic versions of common headers
      asm-generic: add legacy I/O header files
      asm-generic: add generic atomic.h and io.h
      asm-generic: add generic NOMMU versions of some headers
      asm-generic: add a generic uaccess.h
      add generic lib/checksum.c
      asm-generic: merge branch 'master' of torvalds/linux-2.6
      time: move PIT_TICK_RATE to linux/timex.h
      mb862xxfb: use CONFIG_OF instead of CONFIG_PPC_OF
      ipc: use __ARCH_WANT_IPC_PARSE_VERSION in ipc/util.h
      asm-generic: drop HARDIRQ_BITS definition from hardirq.h
      asm-generic: list Arnd as asm-generic maintainer
      asm-generic: hook up new system calls
      lib/checksum.c: fix endianess bug
      microblaze: remove init_mm

Arne Janbu (1):
      .gitignore: ignore *.lzma files

Artem Bityutskiy (25):
      OMAP3 clock: lessen amount of noisy messages
      UBI: remove redundant mutex
      UBI: re-name volumes_mutex to device_mutex
      UBI: improve debugging messages
      UBI: small debugging code optimization
      UBI: fix races in I/O debugging checks
      UBI: add dump_stack in checking code
      UBI: do not panic if volume check fails
      UBI: minor serialization fix
      UBIFS: use anonymous device
      UBI: fix race condition
      UBIFS: remove dead code
      UBIFS: allow sync option in rootflags
      UBI: introduce new constants
      UBI: fix and clean-up error paths in WL worker
      UBI: do not switch to R/O mode on read errors
      Kill jffs2-user.h
      UBIFS: do not forget to register BDI device
      hrtimer: export ktime_add_safe
      UBIFS: start using hrtimers
      UBI: improve messages in the WL worker
      UBI: print amount of reserved PEBs
      UBI: fix kmem_cache_free on error patch
      UBI: fix multiple spelling typos
      UBI: handle more error codes

Arun R Bharadwaj (4):
      timers: Framework for identifying pinned timers
      timers: Identifying the existing pinned timers
      timers: /proc/sys sysctl hook to enable timer migration
      timers: Logic to move non pinned timers

Arve Hj=C3=B8nnev=C3=A5g (2):
      Staging: android: lowmemorykiller: Only iterate over process list w=
hen needed.
      Staging: android: lowmemorykiller: Don't count free space unless it=
 meets the specified limit by itself

Atsushi Nemoto (15):
      ASoC: Add TXx9 AC link controller driver (v3)
      mtd: nand: Fix memory leak on txx9ndfmc probe failure.
      MIPS: Fix __ndelay build error and add 'ull' suffix for 32-bit kern=
el
      MIPS: TXx9: micro optimization for clocksource and clock_event
      DMA: TXx9 Soc DMA Controller driver
      MIPS: TXx9: Add DMAC support
      MIPS: TXx9: Add ACLC support
      MIPS: TXx9: Add SRAMC support
      MIPS: hwrng: Add TX4939 RNG driver
      MIPS: TXx9: Add TX4939 RNG support
      rtc-tx4939: drop IRQF_SHARED
      rtc-ds1553: drop IRQF_SHARED
      rtc: make rtc_update_irq callable with irqs enabled
      kgdb: kgdboc console poll hooks for serial_txx9 uart
      DMA: txx9dmac: use dma_unmap_single if DMA_COMPL_{SRC,DEST}_UNMAP_S=
INGLE set

Avadh Patel (1):
      tracing: add saved_cmdlines file to show cached task comms

Avi Kivity (18):
      KVM: VMX: Don't use highmem pages for the msr and pio bitmaps
      KVM: VMX: Don't intercept MSR_KERNEL_GS_BASE
      KVM: VMX: Make module parameters readable
      KVM: VMX: Rename kvm_handle_exit() to vmx_handle_exit()
      KVM: VMX: Simplify module parameter names
      KVM: VMX: Annotate module parameters as __read_mostly
      KVM: VMX: Zero the vpid module parameter if vpid is not supported
      KVM: VMX: Zero ept module parameter if ept is not present
      KVM: VMX: Fold vm_need_ept() into callers
      KVM: VMX: Make flexpriority module parameter reflect hardware capab=
ility
      KVM: MMU: Use different shadows when EFER.NXE changes
      KVM: Replace kvmclock open-coded get_cpu_var() with the real thing
      KVM: Fix cpuid feature misreporting
      KVM: Add AMD cpuid bit: cr8_legacy, abm, misaligned sse, sse4, 3dno=
w prefetch
      x86: Add cpu features MOVBE and POPCNT
      KVM: Update cpuid 1.ecx reporting
      KVM: Disable large pages on misaligned memory slots
      KVM: Prevent overflow in largepages calculation

Ayaz Abdulla (4):
      forcedeth: add clock gating feature <resend>
      forcedeth: remove device id macros
      forcedeth: addition of new mcp89 device id
      removal of forcedeth device ids

Balbir Singh (1):
      memcg: add file-based RSS accounting

Barry Kitson (1):
      V4L/DVB (11996): saa7134: add support for AVerMedia M103 (f736)

Barry Song (1):
      ASoC: Blackfin: update the bf5xx_i2s_resume parameters

Bartlomiej Zolnierkiewicz (140):
      Merge branch 'for-linus' into for-next
      Merge branch 'for-linus' into for-next
      mg_disk: fix CONFIG_LBD=3Dy warning
      block: enable by default support for large devices and files on 32-=
bit archs
      mg_disk: fix dependency on libata
      mg_disk: use defines from <linux/ata.h>
      Merge branch 'for-linus' into for-next
      Merge branch 'for-linus' into for-next
      ide: BUG() on unknown flags in ide_disk_special()
      ide: merge ide_disk_special() into do_special() (v2)
      ide: replace special_t typedef by IDE_SFLAG_* flags
      ide: remove chipset field from hw_regs_t
      ide: pass number of ports to ide_host_{alloc,add}() (v2)
      ide: remove hw_regs_t typedef
      Merge branch 'for-linus' into for-next
      partitions: warn about the partition exceeding device capacity
      partitions: add ->set_capacity block device method
      ide-gd: implement block device ->set_capacity method (v2)
      ide: preserve Host Protected Area by default (v2)
      Merge branch 'for-linus' into for-next
      icside: remove superfluous ->maskproc method
      ide: remove superfluous SELECT_MASK() call from ide_driveid_update(=
)
      ide: remove superfluous SELECT_MASK() call from do_rw_taskfile()
      hpt366: sync quirk_drives[] list with pdc202xx_{new,old}.c
      hpt366: enable all quirks for devices on quirk_drives[] list
      ide: respect quirk_drives[] list on all controllers
      ide: add IDE_DFLAG_NIEN_QUIRK device flag
      [SCSI] fix documentation for two functions
      ide: skip probe if there are no devices on the port (v2)
      ide: unexport ide_find_dma_mode()
      ide: re-implement ide_pci_init_one() on top of ide_pci_init_two()
      Merge branch 'bp-remove-pc-buf' into for-next
      ata: add ata_id_pio_need_iordy() helper (v2)
      ide: IORDY handling fixes
      ide: don't enable IORDY at a probe time
      ide: filter out invalid DMA xfer mode changes in HDIO_DRIVE_CMD ioc=
tl handler
      ide: BUG() on unknown requests
      block: rename CONFIG_LBD to CONFIG_LBDAF
      Staging: rt2870: remove unused files
      Staging: rt2870: remove kernel version compatibility wrappers
      Staging: rt3070: remove kernel version compatibility wrappers
      Staging: rt2860: remove IWE_STREAM_ADD_*() macros
      Staging: rt2870: remove IWE_STREAM_ADD_*() macros
      Staging: rt2860: remove dead WIN_NDIS code
      Staging: rt2860: remove dead UNDER_CE code
      Staging: rt2870: remove dead UNDER_CE code
      Staging: rt3070: remove dead UNDER_CE code
      Staging: rt2860: remove dead WSC_AP_SUPPORT code
      Staging: rt2870: remove dead WSC_AP_SUPPORT code
      Staging: rt3070: remove dead *WSC_INCLUDED code
      Staging: rt2860: remove dead WDS_SUPPORT code
      Staging: rt2870: remove dead WDS_SUPPORT code
      Staging: rt3070: remove dead WDS_SUPPORT code
      Staging: rt3070: remove dead MLME_EX code
      Staging: rt2860: remove dead APCLI_SUPPORT code
      Staging: rt2870: remove dead APCLI_SUPPORT code
      Staging: rt2860: remove dead CONFIG_APSTA_MIXED_SUPPORT code
      Staging: rt2870: remove dead CONFIG_APSTA_MIXED_SUPPORT code
      Staging: rt3070: remove dead CONFIG_APSTA_MIXED_SUPPORT code
      Staging: rt2860: remove dead UCOS code
      Staging: rt2870: remove dead UCOS code
      Staging: rt3070: remove dead UCOS code
      Staging: rt2860: remove dead NINTENDO_AP code
      Staging: rt2870: remove dead NINTENDO_AP code
      Staging: rt3070: remove dead NINTENDO_AP code
      Staging: rt2860: remove dead BIN_IN_FILE code
      Staging: rt2870: remove dead BIN_IN_FILE code
      Staging: rt3070: remove dead BIN_IN_FILE code
      Staging: rt2860: remove dead RALINK_ATE code
      Staging: rt2870: remove dead RALINK_ATE code
      Staging: rt3070: remove dead RALINK_ATE code
      Staging: rt2860: remove dead BLOCK_NET_IF code
      Staging: rt2870: remove dead BLOCK_NET_IF code
      Staging: rt3070: remove dead BLOCK_NET_IF code
      Staging: rt2860: remove dead DFS_SUPPORT code
      Staging: rt2870: remove dead DFS_SUPPORT code
      Staging: rt3070: remove dead DFS_SUPPORT code
      Staging: rt2860: remove dead CARRIER_DETECTION_SUPPORT code
      Staging: rt2870: remove dead CARRIER_DETECTION_SUPPORT code
      Staging: rt3070: remove dead CARRIER_DETECTION_SUPPORT code
      Staging: rt2860: remove dead MULTIPLE_CARD_SUPPORT code
      Staging: rt2870: remove dead MULTIPLE_CARD_SUPPORT code
      Staging: rt3070: remove dead MULTIPLE_CARD_SUPPORT code
      Staging: rt2860: remove dead QOS_DLS_SUPPORT code
      Staging: rt2870: remove dead QOS_DLS_SUPPORT code
      Staging: rt3070: remove dead QOS_DLS_SUPPORT code
      Staging: rt2860: remove dead EXT_BUILD_CHANNEL_LIST code
      Staging: rt2870: remove dead EXT_BUILD_CHANNEL_LIST code
      Staging: rt3070: remove dead EXT_BUILD_CHANNEL_LIST code
      Staging: rt2860: remove dead SNMP_SUPPORT code
      Staging: rt2870: remove dead SNMP_SUPPORT code
      Staging: rt3070: remove dead SNMP_SUPPORT code
      Staging: rt2860: remove dead SINGLE_SKU code
      Staging: rt2870: remove dead SINGLE_SKU code
      Staging: rt3070: remove dead SINGLE_SKU code
      Staging: rt2860: remove dead LEAP_SUPPORT code
      Staging: rt2870: remove dead LEAP_SUPPORT code
      Staging: rt3070: remove dead LEAP_SUPPORT code
      Staging: rt2860: remove dead DOT11N_DRAFT3 code
      Staging: rt2870: remove dead DOT11N_DRAFT3 code
      Staging: rt3070: remove dead DOT11N_DRAFT3 code
      Staging: rt2860: remove dead INF_AMAZON_SE code
      Staging: rt2870: remove dead INF_AMAZON_SE code
      Staging: rt3070: remove dead INF_AMAZON_SE code
      Staging: rt2860: remove dead RT_BIG_ENDIAN code
      Staging: rt2870: remove dead RT_BIG_ENDIAN code
      Staging: rt3070: remove dead RT_BIG_ENDIAN code
      Staging: rt2860: remove CONFIG_STA_SUPPORT ifdefs
      Staging: rt2870: remove CONFIG_STA_SUPPORT ifdefs
      Staging: rt3070: remove CONFIG_STA_SUPPORT ifdefs
      Staging: rt2860: remove NATIVE_WPA_SUPPLICANT_SUPPORT ifdefs
      Staging: rt2870: remove NATIVE_WPA_SUPPLICANT_SUPPORT ifdefs
      Staging: rt3070: remove NATIVE_WPA_SUPPLICANT_SUPPORT ifdefs
      Staging: rt2860: remove WPA_SUPPLICANT_SUPPORT ifdefs
      Staging: rt2870: remove WPA_SUPPLICANT_SUPPORT ifdefs
      Staging: rt3070: remove WPA_SUPPLICANT_SUPPORT ifdefs
      Staging: rt2860: remove DOT11_N_SUPPORT ifdefs
      Staging: rt2870: remove DOT11_N_SUPPORT ifdefs
      Staging: rt3070: remove DOT11_N_SUPPORT ifdefs
      Staging: rt2860: remove dead CONFIG_AP_SUPPORT code
      Staging: rt2870: remove dead CONFIG_AP_SUPPORT code
      Staging: rt3070: remove dead CONFIG_AP_SUPPORT code
      Staging: rt2860: use empty ASSERT() macro
      Staging: rt2870: use empty ASSERT() macro
      Staging: rt3070: use empty ASSERT() macro
      Staging: rt2860: remove dead code
      Staging: rt2870: remove dead code
      Staging: rt3070: remove dead code
      Staging: rt2870: prepare for rt{28,30}70/*.[ch] merge
      Staging: rt{28,30}70: merge rt{28,30}70/*.[ch]
      Staging: rt2870: prepare for rt{28,30}70/common/*.[ch] merge
      Staging: rt{28,30}70: merge rt{28,30}70/common/*.[ch]
      Staging: rt2870: prepare for rt{28,30}70/sta/*.[ch] merge
      Staging: rt{28,30}70: merge rt{28,30}70/sta/*.[ch]
      Staging: rt2860: prepare for rt28[67]0/*.[ch] merge
      Staging: rt28[67]0: merge rt28[67]0/*.[ch]
      Staging: rt2860: prepare for rt28[67]0/common/*.[ch] merge
      Staging: rt28[67]0: merge rt28[67]0/common/*.[ch]
      Staging: rt2860: prepare for rt28[67]0/sta/*.[ch] merge
      Staging: rt28[67]0: merge rt28[67]0/sta/*.[ch]

Baruch Siach (2):
      gpio: driver for PrimeCell PL061 GPIO controller
      i2c: driver for the Synopsys DesignWare I2C controller

Bastien Nocera (1):
      HID: Wacom Graphire Bluetooth driver

Becky Bruce (12):
      swiotlb: comment corrections
      swiotlb: fix compile warning
      swiotlb: map_page fix for highmem systems
      swiotlb: allow arch override of address_needs_mapping
      swiotlb: rename unmap_single to do_unmap_single
      swiotlb: use swiotlb_sync_single instead of duplicating code
      swiotlb: change swiotlb_bus_to[phys,virt] prototypes
      powerpc/86xx: Add 36-bit device tree for mpc8641hpcn
      powerpc: make dma_window_* in pci_controller struct avail on 32b
      powerpc: Use sg->dma_length in sg_dma_len() macro on 32-bit
      powerpc: Add support for swiotlb on 32-bit
      powerpc: Add 86xx support for SWIOTLB

Ben Dooks (64):
      [ARM] SMDK6410: Ensure LCD settings are setup
      [ARM] S3C24XX: Move plat/dma.h
      [ARM] S3C24XX: Remove hardware specific registers from DMA
      [ARM] S3C24XX: DMA: Split hardware regs out of <mach/dma.h>
      [ARM] S3C24XX: Fix indentation in <plat/dma-regs.h>
      [ARM] S3C: Make common <plat/dma.h> header
      [ARM] S3C24XX: dma.h should not include <mach/hardware.h>
      [ARM] S3C: Move DMA channel management code to plat-s3c
      [ARM] S3C: Add common USB OHCI device definition
      [ARM] SMDK6410: Add USB OHCI host
      [ARM] S3C: Rename S3C24XX_PA_USBHOST to S3C_PA_USBHOST
      [ARM] S3C64XX: Add USB OHCI support
      [ARM] S3C: Add debug to UART save and a per-arch callback pre-resto=
re
      [ARM] S3C: PM save UART UDIVSLOT if doing PM
      [ARM] S3C64XX: Initial support for PM (suspend to RAM)
      [ARM] S3C64XX: Add s3c6410_sysclass export
      [ARM] S3C64XX: Add generic s3c64xx sys device.
      [ARM] S3C64XX: Add IRQ PM code
      [ARM] S3C: GPIO PM core GPIOlib integration
      [ARM] VIC: Add power management device
      [ARM] SMDK6400: Initial machine support for SMDK6400
      [ARM] S3C6400: Core support for S3C6400 SoC
      [ARM] S3C64XX: Add S3C6400 CPU detection.
      [ARM] S3C64XX: Add S3C6400 SDHCI setup support
      [ARM] SMDK6400: Fix WM8753 i2c board definition
      [ARM] Merge next-s3c-s3c6410 into for-rmk-devel
      [ARM] S3C64XX: Add ARM clock
      [ARM] S3C: Add USB high-speed/OtG device definitions
      [ARM] SMDK6410: Add USB high-speed/OtG gadget device
      [ARM] S3C24XX: GPIO: Remove s3c2410_gpio_irq2pin() call
      [ARM] S3C24XX: GPIO: Remove pin specific input and output defines
      [ARM] S3C: Move watchdog system reset to own file.
      [ARM] S3C64XX: Use common watchdog reset for system reset.
      [ARM] S3C24XX: GPIO: Move gpio functions out of <mach/hardware.h>
      [ARM] S3C24XX: Fix missing <linux/sysdev.h>
      [ARM] S3C24XX: GPIO: Clean out unused definitions in <mach/regs-gpi=
o.h>
      [ARM] S3C24XX: GPIO: Start removal of S3C24XX_GPIO_BASE
      [ARM] S3C24XX: GPIO: Add S3C64XX style GPIO numbering
      [ARM] S3C24XX: GPIO: Change to macros for GPIO numbering
      [ARM] S3C64XX: DMA support
      [ARM] S3C: Merge next-s3c64xx-dma2 into for-rmk-devel
      [ARM] S3C24XX: GPIO: Fix error returns from gpio functions
      [ARM] S3C24XX: GPIO: Move gpiolib initialisation earlier
      [ARM] S3C24XX: GPIO: Fix missing GPIOs in gpiolib
      [ARM] S3C24XX: GPIO: Change usb-simtec.c to use gpiolib.
      [ARM] S3C24XX: Merge devel-gpio
      [MTD] [NAND] S3C2410: Move to using platform device table
      [MTD] [NAND] S3C2410: Basic kerneldoc comment updates
      [MTD] [NAND] S3C2410: Deal with unaligned lengths in S3C2440 buffer=
 read/write
      [MTD] [NAND] S3C2410: Use DIV_ROUND_UP
      i2c-s3c2410: move to using platform idtable to match devices
      sdhci: Print ADMA status and pointer on debug
      mmc_block: do not DMA to stack
      [ARM] MINI2440: Cleanup duplicated header includes
      s3cmci: fix dma configuration call
      USB: Gadget driver for Samsung HS/OtG block
      i2c-s3c2410: use resource_size()
      [ARM] VIC: Fix resume sources usage
      [ARM] S3C2440: Merge branch next-mini2440 into next-s3c
      s3c-fb: CPUFREQ frequency scaling support
      sdhci-s3c: Samsung S3C based SDHCI controller glue
      sdhci: Add better ADMA error reporting
      sdhci: Add SDHCI_QUIRK_NO_MULTIBLOCK quirk
      s3cmci: fix dma configuration call

Ben Gamari (2):
      drm/i915: Warn when inteldrmfb fails to restore its framebuffer con=
fig
      drm/i915: A few debugfs formatting fixes

Ben Hutchings (24):
      ethtool: Add port type PORT_OTHER
      mdio: Add register definitions for MDIO (clause 45)
      mdio: Add generic MDIO (clause 45) support functions
      sfc: Use generic MDIO functions and definitions
      chelsio: Use generic MDIO definitions and mdio_mii_ioctl()
      cxgb3: Use generic MDIO definitions and mdio_mii_ioctl()
      ixgbe: Use generic MDIO definitions and functions
      ixgb: Use generic MDIO definitions
      s2io: Use generic MDIO definitions
      mii: Simplify mii_resolve_flowctrl_fdx()
      mii: Add mii_advertise_flowctrl()
      mdio: Add mdio45_ethtool_spauseparam_an()
      sfc: Use generic MDIO flow control auto-negotiation functions
      ethtool/mdio: Report MDIO mode support and link partner advertising
      ethtool/mdio: Support backplane mode negotiation
      mii: Rewrite mii_ethtool_gset() to report mdio_support and lp_adver=
tising
      mdio: Add 10GBASE-T SNR register definition
      mdio: Add XENPAK LASI register definitions
      sfc: Use generic XENPAK register definitions
      sfc: Remove lro module parameter
      chelsio: Use generic XENPAK LASI register definitions
      cxgb3: Use generic XENPAK LASI register definitions
      mdio: Expose 10GBASE-T MDI-X status via ethtool
      sfc: Expose 100/1000BASE-T MDI-X status via ethtool

Ben Nizette (2):
      avr32: Fix clash in ATMEL_USART_ flags
      atmel-lcdc: fix pixclock upper bound detection

Ben Skeggs (1):
      drm: don't associate _DRM_DRIVER maps with a master

Benjamin Herrenschmidt (22):
      Merge branch 'merge' into next
      powerpc/mm: Fix some SMP issues with MMU context handling
      powerpc/mm: Fix a AB->BA deadlock scenario with nohash MMU context =
lock
      powerpc: Set init_bootmem_done on NUMA platforms as well
      powerpc: Move VMX and VSX asm code to vector.S
      powerpc: Introduce CONFIG_PPC_BOOK3S
      powerpc: Split exception handling out of head_64.S
      powerpc: Separate PACA fields for server CPUs
      powerpc: Shield code specific to 64-bit server processors
      spinlock: Add missing __raw_spin_lock_flags() stub for UP
      Merge commit 'jwb/next' into next
      powerpc: Fix bug in move of altivec code to vector.S
      Merge commit 'origin/master' into next
      Merge commit 'origin/master' into next
      powerpc: Don't do generic calibrate_delay()
      powerpc: Fix invalid construct in our CPU selection Kconfig
      powerpc: Add memory clobber to mtspr()
      Merge commit 'origin/master' into next
      mm: Move pgtable_cache_init() earlier
      Merge commit 'origin/master' into next
      Merge commit 'gcl/merge' into next
      mm: Extend gfp masking to the page allocator

Benny Halevy (39):
      update Documentation/filesystems/00-INDEX with new nfsd related doc=
s.
      nfs41: nfs_client.cl_minorversion
      nfs41: Use mount minorversion option
      nfs41: translate NFS4ERR_MINOR_VERS_MISMATCH to EPROTONOSUPPORT
      nfs41: client xdr definitions
      nfs41: use nfs4_server_caps_arg
      nfs41: use nfs4_readlink_res
      nfs41: use nfs4_statfs_res
      nfs41: use nfs4_fsinfo_res
      nfs41: use nfs4_pathconf_res
      nfs41: use nfs4_getaclres
      NFS: get rid of unused xdr decode_setattr(, res) argument
      nfs41: use nfs4_setaclres
      nfs41: use nfs4_fs_locations_res
      nfs41: nfs41: pass *session in seq_args and seq_res
      NFS: use decode_change_info_maxsz for xdr maxsz calculations
      NFS: define and initialize compound_hdr.replen
      NFS: update hdr->replen for every encode op
      NFS: use dynamically computed compound_hdr.replen for xdr_inline_pa=
ges offset
      nfs41: encode minorversion in compound header
      nfs41: find slot
      nfs41: exchange_id operation
      nfs41: lease renewal
      nfs41: support minorversion 1 for nfs4_check_lease
      nfs41: recover lease in _nfs4_lookup_root
      nfs41: increment_{open,lock}_seqid
      nfs41: Refactor nfs4_{init,destroy}_callback for nfs4.0
      nfs41: minorversion support for nfs4_{init,destroy}_callback
      nfs41: sunrpc: provide functions to create and destroy a svc_xprt f=
or backchannel use
      nfs41: create a svc_xprt for nfs41 callback thread and use for inco=
ming callbacks
      nfs41: store minorversion in cb_compound_hdr_arg
      nfs41: decode minorversion 1 cb_compound header
      nfs41: callback numbers definitions
      nfs41: consider minorversion in callback_xdr:process_op
      nfs41: cb_sequence protocol level data structures
      nfs41: cb_sequence proc implementation
      nfs41: cb_sequence xdr implementation
      nfs41: verify CB_SEQUENCE position in callback compound
      nfs41: Move initialization of nfs4_opendata seq_res to nfs4_init_op=
endata_res

Bernd Porr (2):
      Staging: comedi: convert usbdux* to use firmware_request
      Staging: comedi: usbdux: buffer overflow error handling

Bian Naimeng (1):
      nfsd4: distinguish expired from stale stateids

Bill Pemberton (79):
      Staging: comedi: Remove ni_board typedef
      Staging: comedi: Remove ni_private typedef
      Staging: comedi: Remove local_info_t typedef in ni_labpc_cs
      Staging: comedi: Remove dio24_board_struct typedef
      Staging: comedi: Remove local_info_t typedef in ni_daq_dio24
      Staging: comedi: Remove BYTE and *PBYTE typedefs in addi-data
      Staging: comedi: Remove SHORT and *PSHORT typedefs in addi-data
      Staging: comedi: Remove USHORT and *PUSHORT typedefs in addi-data
      Staging: comedi: Remove WORD and *PWORD typedefs in addi-data
      Staging: comedi: Remove INT and *PINT typedefs in addi-data
      Staging: comedi: Remove UINT and *PUINT typedefs in addi-data
      Staging: comedi: Remove LONG and *PLONG typedefs in addi-data
      Staging: comedi: Remove ULONG and *PULONG typedefs in addi-data
      Staging: comedi: Remove DWORD and *PDWORD typedefs in addi-data
      Staging: comedi: Remove ULONG_PTR typedef in addi-data
      Staging: comedi: Remove PCRANGE typedef in addi-data
      Staging: comedi: Remove boardtype typedef in addi-data
      Staging: comedi: Remove str_ModuleInfo typedef in addi-data
      Staging: comedi: Remove addi_private typedef in addi-data
      Staging: comedi: Remove str_MainHeader typedef in addi-data/addi_ee=
prom.c
      Staging: comedi: Remove str_DigitalInputHeader typedef in addi-data=
/addi_eeprom.c
      Staging: comedi: Remove str_DigitalOutputHeader typedef in addi-dat=
a/addi_eeprom.c
      Staging: comedi: Remove str_TimerDetails typedef in addi-data/addi_=
eeprom.c
      Staging: comedi: Remove str_TimerMainHeader typedef in addi-data/ad=
di_eeprom.c
      Staging: comedi: Remove str_AnalogReadInformation typedef in addi-d=
ata/hwdrv_apci3120.h
      Staging: comedi: Remove str_Module typedef in addi-data/hwdrv_apci3=
200.h
      Staging: comedi: Remove str_BoardInfos typedef in addi-data/hwdrv_a=
pci3200
      Staging: comedi: Remove str_ADDIDATA_RTDStruct typedef in addi-data=
/hwdrv_apci3200
      Staging: comedi: Remove labpc_board_struct typedef
      Staging: comedi: Remove labpc_private typedef
      Staging: comedi: Remove str_AnalogInputHeader typedef in addi-data/=
addi_eeprom.c
      Staging: comedi: remove C99 comments in 8253.h
      Staging: comedi: remove C99 comments in acl7225b.c
      Staging: comedi: remove C99 comments in APCI1710_82x54.c
      Staging: comedi: remove C99 comments in das1800.c
      Staging: comedi: remove C99 comments in pcl818.c
      Staging: comedi: remove C99 comments in hwdrv_apci1500.c
      Staging: comedi: remove C99 comments in APCI1710_Pwm.c
      Staging: comedi: remove C99 comments in hwdrv_apci1564.c
      Staging: comedi: remove C99 comments in hwdrv_apci3200.c
      Staging: comedi: remove C99 comments in hwdrv_apci3120.c
      Staging: comedi: remove C99 comments in adl_pci6208.c
      Staging: comedi: remove C99 comments in adl_pci9118.c
      Staging: comedi: remove C99 comments in adv_pci1723.c
      Staging: comedi: remove C99 comments in c6xdigio.c
      Staging: comedi: remove C99 comments in cb_pcidas64.c
      Staging: comedi: remove C99 comments in cb_pcidas.c
      Staging: comedi: remove C99 comments in cb_pcimdas.c
      Staging: comedi: remove C99 comments in gsc_hpdi.c
      Staging: comedi: remove C99 comments in mpc624.c
      Staging: comedi: remove C99 comments in ni_at_a2150.c
      Staging: comedi: remove C99 comments in ni_labpc.c
      Staging: comedi: remove C99 comments in pcl724.c
      Staging: comedi: remove C99 comments in pcl816.c
      Staging: comedi: remove C99 comments in s526.c
      Staging: comedi: Remove C99 comments
      Staging: comedi: fix "foo * bar" should be "foo *bar"
      Staging: comedi: Add spaces after commas
      Staging Comedi: fix spacing around parens
      Staging: Comedi: change space indentation to tabs
      Staging: comedi: remove assignment in conditionals
      Staging: comedi: Remove parens around return values
      Staging: comedi: fix the way structs are initialized.
      Staging: comedi: more remove C99 comments
      Staging: comedi: remove space after ampersand
      Staging: comedi: more fix "foo * bar" should be "foo *bar"
      Staging: comedi: more fix the way structs are initialized.
      Staging: comedi: make use of ARRAY_SIZE macro
      Staging: comedi: comment out useless if
      Staging: comedi: move while to same line as } in do loops
      Staging: comedi: replace for loop with msleep()
      Staging: comedi: simply read and write functions in adl_pci8164
      staging: comedi: Remove MIN macro
      staging: comedi: Move pcm do_cmdtest function into a single source =
file
      Staging: pohmelfs: move open brace to same line on structs
      Staging: pohmelfs: Remove C99 comments
      Staging: pohmelfs: Remove braces around single statements
      Staging: Add serqt_usb2, a rewrite of serqt_usb for the usb-serial =
layer
      Staging: serqt_usb2 add the driver to the build

Bing Zhao (7):
      libertas: support mesh for various firmware versions
      libertas: add support for Marvell SD8688 chip
      libertas: define macros for SDIO model numbers
      libertas: get SD8688 rx length with one CMD52
      libertas: implement function init/shutdown commands for SD8688
      libertas: read SD8688 firmware status from new register
      libertas: improve function init/shutdown handling for SD8688

Bjorn Helgaas (21):
      ACPI: use LNXCPU, not ACPI_CPU, for Linux-specific processor _HID
      ACPI: processor: check for synthetic _HID, default to "Device" decl=
aration
      ACPI: processor: move device _HID into driver
      PNPACPI: parse Extended Address Space Descriptors
      ACPI: don't check power state after _ON/_OFF
      pnp: add PNP resource range checking function
      ACPI: allow drivers to request both device and system notify events
      ACPI: ac: use .notify method instead of installing handler directly
      ACPI: battery: use .notify method instead of installing handler dir=
ectly
      ACPI: asus-laptop: use .notify method instead of installing handler=
 directly
      ACPI: asus-acpi: use .notify method instead of installing handler d=
irectly
      ACPI: eeepc-laptop: use .notify method instead of installing handle=
r directly
      ACPI: simplify notification debug messages
      ACPI: remove unused "status_changed" return value from Check Device=
 handling
      ACPI: remove unused return values from Bus Check & Device Check han=
dling
      ACPI: use handle, not device, in system notification path
      ACPI: pci_root: check _CRS, then _BBN for downstream bus number
      ACPI: pci_root: simplify acpi_pci_root_add() control flow
      ACPI: pci_root: use driver data rather than list lookup
      ACPI: pci_root: simplify list traversals
      ACPI: pci_root: remove unused dev/fn information

Boaz Harrosh (15):
      libosd: Use new blk_rq_map_kern
      block: Add blk_make_request(), takes bio, returns a request
      libosd: Use of new blk_make_request
      block: Un-export blk_rq_append_bio
      scsi_lib: remove unused variable
      [SCSI] libosd: OSD2r05: Additional command enums
      [SCSI] libosd: OSD2r05: Attribute definitions
      [SCSI] libosd: Better printout of OSD target system information
      [SCSI] libosd: osd_req_{read,write}_kern new API
      [SCSI] libosd: Let _osd_req_finalize_data_integrity receive number =
of out_bytes
      [SCSI] libosd: osd_req_{read,write} takes a length parameter
      [SCSI] libosd: Define an osd_dev wrapper to retrieve the request_qu=
eue
      [SCSI] osduld: use filp_open() when looking up an osd-device
      [SCSI] libosd: Use REQ_QUIET requests.
      [SCSI] osd: Remove out-of-tree left overs

Bob Copeland (22):
      ath5k: reduce exported channel list
      ath9k: separate ath9k specific code from ath9k_regd_get_ctl()
      ath9k: pass regd structure directly to regulatory functions
      atheros: introduce ath module containing common ath5k/ath9k/ar9170 =
code
      ath: move more setup code into ath_regd_init
      ath5k: use regulatory infrastructure
      ath5k: add support for Fukato Datacask Jupiter LEDs
      ath5k: fix initvals errors
      ath5k: use tasklet_hi_schedule for beacon queue
      ath5k: use bool for modparams
      ath5k: use rx hw descriptor pointer for self-linked check
      ath5k: manipulate rxlink and descriptor address under rxbuf lock
      ath5k: correct interrupt storm warning
      ath5k: use ctl settings based on current regdomain
      wl12xx: correct printk format warnings
      ath5k: update beacons in AP mode
      ath5k: avoid and warn on potential infinite loop
      ath5k: remove conf->beacon_int usage
      nl80211: use GFP_ATOMIC for michael mic failure message
      ath5k: disable beacon interrupt when interface is down
      mac80211: fix minstrel single-rate memory corruption
      ath5k: minor rfkill cleanup

Bob Moore (22):
      ACPICA: Update error/warning interfaces
      ACPICA: Fix a few warnings for gcc 3.4.4
      ACPICA: Change behavior of object copy for mutex/event objects
      ACPICA: Remove unused global variables
      ACPICA: Fix possible warnings for ACPI_THREAD_ID on 64-bit build
      ACPICA: Cleanup byte/word/dword extraction macros, fix possible war=
nings
      ACPICA: Fix printf format warnings for 64-bit build
      ACPICA: Fix possible dereference of null pointer
      ACPICA: Miscellaneous lint changes
      ACPICA: Fix miscellaneous warnings under gcc 4+
      ACPICA: Fix implementation of AML BreakPoint operator (break to deb=
ugger)
      ACPICA: Linux OSL: cleanup/update/merge
      ACPICA: Update version to 20090422.
      ACPICA: Mutex support: Fix release ordering issue and current sync =
level
      ACPICA: Fix allowable release order for ASL mutex objects
      ACPICA: Fix DebugObject output for DdbHandle objects
      ACPICA: Additional validation of _PRT packages (resource mgr)
      ACPICA: Simplify and optimize NsGetNextNode function
      ACPICA: Update Load() to use operation region interfaces
      ACPICA: Simplify internal operation region interface
      ACPICA: Disable preservation of SCI enable bit (SCI_EN)
      ACPICA: Update version to 20090521.

Borislav Petkov (31):
      ide: add helpers for preparing sense requests
      ide-cd: convert to using generic sense request
      ide-atapi: convert ide-{floppy,tape} to using preallocated sense bu=
ffer
      ide: add helpers for preparing sense requests
      ide-cd: convert to using generic sense request
      ide-atapi: convert ide-{floppy,tape} to using preallocated sense bu=
ffer
      ide-tape: fix potential fs requests bug
      ide-atapi: switch to blk_rq_bytes() on do_request() path
      ide-atapi: switch to rq->resid_len
      ide-atapi: add a len-parameter to ide_queue_pc_tail
      ide-atapi: add a buffer-arg to ide_queue_pc_tail
      ide-floppy/ide_floppy_get_flexible_disk_page: use local buffer
      ide-floppy/ide_floppy_get_sfrp_bit: use local buffer
      ide-floppy/ide_floppy_format_unit: use local buffer
      ide-atapi: use local sense buffer
      ide-floppy/ide_floppy_get_format_progress: use local sense buffer
      ide-tape/ide_tape_get_bsize_from_bdesc: use local buffer
      ide-tape: fix READ POSITION cmd handling
      ide-atapi: remove pc->buf
      ide-cd: use whole request_sense buffer in EH
      ide: unify interrupt reason checking
      ide-tape: change IDE_AFLAG_IGNORE_DSC non-atomically
      ide-tape: fix IDE_AFLAG_* atomic accesses
      ide-tape: fix proc warning
      x86: MSR: add a struct representation of an MSR
      x86: MSR: add methods for writing of an MSR on several CPUs
      edac: fold __func__ into edac_debug_printk
      amd64_edac: do not enable module by default
      EDAC: do not enable modules by default
      amd64_edac: add MAINTAINERS entry
      ide-tape: fix build issue

Breno Leitao (4):
      ixgbe: Return PCI_ERS_RESULT_DISCONNECT when bus is disabled
      bnx2: no need to check before vfreeing
      icom: fixing a if clause spaghetti
      icom: fix compile errors when defining ICOM_TRACE

Brian Haley (3):
      IPv6: Add 'autoconf' and 'disable_ipv6' module parameters
      IPv6: Print error value when skb allocation fails
      ipv6: Use correct data types for ICMPv6 type and code

Brian King (15):
      [SCSI] ibmvfc: Fix invalid error response handling
      [SCSI] ibmvfc: Fixup GFP flags for target allocations
      [SCSI] ibmvfc: Use DEVICE_ATTR macro
      [SCSI] ibmvfc: Reduce error logging noise
      [SCSI] ibmvfc: Fix deadlock in EH
      [SCSI] ibmvfc: Add support for NPIV Logout
      [SCSI] ibmvfc: Add flush on halt support
      [SCSI] ibmvfc: Improve device rediscovery
      [SCSI] ibmvfc: Improve LOGO/PRLO ELS handling
      [SCSI] ibmvfc: Driver version 1.0.6
      [SCSI] ibmvscsi: Add 16 byte CDB support
      [SCSI] ibmvscsi: Send adapter info before login
      [SCSI] ibmvscsi: Add support for capabilities MAD
      ibmvfc: Process async events before command responses
      ibmvfc: Fix endless PRLI loop in discovery

Brice Goglin (10):
      myri10ge: force stats update in ethtool gstats
      myri10ge: allow per-board firmware overriding
      myri10ge: add MODULE_DEVICE_TABLE
      myri10ge: fix tx ring size in ethtool -g
      myri10ge: allow LRO to be enabled via ethtool
      myri10ge: update version to 1.5.0-1.415
      myri10ge: fix the invokation of lro_flush_all
      myri10ge: drop myri10ge_lro module parameter
      myri10ge: Add support for vlan_features
      migration: only migrate_prep() once per move_pages()

Bruce Allan (7):
      e1000e: enable CRC stripping by default
      e1000e: do not attempt to disable smart powerdown if not supported
      e1000e: correct flow control thresholds
      e1000e: specify max supported frame size in adapter struct
      e1000e: add support for 82577/82578 GbE LOM parts
      e1000e: workaround a Tx hang on 82577/82578
      e1000e: bump the version number

Bryan Stephenson (1):
      Staging: rt2860: fix for driver RT2860 to be able to connect to WPA=
2 networks

Bryan Wu (3):
      usb: misc: SiS usbvga dangle: accept MUSB_HDRC as a fast enough hos=
t controller
      USB: audio: add USB audio class definitions
      USB: gadget: add USB Audio Gadget driver

Carsten Otte (4):
      KVM: s390: Fix memory slot versus run - v3
      KVM: s390: Unlink vcpu on destroy - v2
      KVM: s390: Sanity check on validity intercept
      KVM: s390: Verify memory in kvm run

Catalin Marinas (37):
      [ARM] 5516/1: Flush the D-cache after initialising the SCU
      mtd: Add armflash support for multiple blocks of flash
      RealView: Allow SMP when the Cortex-A9 tile is enabled for EB
      RealView: Allow access to the secure flash memory block on PB1176
      RealView: Toggle one LED per CPU
      Check whether the TLB operations need broadcasting on SMP systems
      Clear the IT state when invoking a Thumb-2 signal handler
      ARMv7: Enable the SWP instruction
      ARMv7: Document the PRRR and NMRR registers setting
      arm: Provide _sdata and __bss_stop in the vmlinux.lds.S file
      RealView: Move the IRQ_* definitions out of the board-*.h files
      Add core support for ARMv6/v7 big-endian
      Fix the VFP handling on the Feroceon CPU
      kmemleak: Add the base support
      kmemleak: Add documentation on the memory leak detector
      kmemleak: Add the slab memory allocation/freeing hooks
      kmemleak: Add the slob memory allocation/freeing hooks
      kmemleak: Add the slub memory allocation/freeing hooks
      kmemleak: Add the vmalloc memory allocation/freeing hooks
      kmemleak: Add kmemleak_alloc callback from alloc_large_system_hash
      kmemleak: Add modules support
      kmemleak: Remove some of the kmemleak false positives
      kmemleak: Enable the building of the memory leak detector
      kmemleak: Simple testing module for kmemleak
      kmemleak: Add the corresponding MAINTAINERS entry
      x86: Provide _sdata in the vmlinux.lds.S file
      kmemleak: Remove the kmemleak.h include in drivers/char/vt.c
      kmemleak: Add more info to the MAINTAINERS entry
      kmemleak: Only use GFP_KERNEL|GFP_ATOMIC for the internal allocatio=
ns
      kmemleak: Rename kmemleak_panic to kmemleak_stop
      kmemleak: Fix some typos in comments
      [ARM] 5555/1: RealView: Include asm/smp_twd.h in realview-pbx.c
      [ARM] 5556/1: Fix the irq_desc.cpu references
      [ARM] 5557/1: Discard some ARM.ex*.*exit.text sections when !HOTPLU=
G or !HOTPLUG_CPU
      [ARM] 5558/1: Add extra checks to ARM unwinder to avoid tracing cor=
rupt stacks
      [ARM] 5559/1: Limit the stack unwinding caused by a kthread exit
      kmemleak: Do not force the slab debugging Kconfig options

Chaitanya Lala (1):
      e1000e: Expose MDI-X status via ethtool change

Chaithrika U S (5):
      davinci: use 32-bit accesses for low-level debug macros
      ASoC: Add dummy S/PDIF codec support
      TI DaVinci EMAC: Remove print_mac, DECLARE_MAC_BUF
      V4L/DVB (11742): TI THS7303 video amplifier driver code
      V4L/DVB (11743): Analog Devices ADV7343 video encoder driver

Chandra Seetharaman (1):
      dm mpath: call activate fn for each path in pg_init

Chauhan, Vijay (1):
      [SCSI] scsi_dh_rdac: Retry for NOT_READY(02/04/01) in rdac device h=
andler

Cheng Renquan (1):
      kbuild: remove extra ifdef/endif of top Makefile

Chris Friesen (1):
      ipv4: teach ipconfig about the MTU option in DHCP

Chris Leech (1):
      [SCSI] fcoe: use ETH_P_FIP for skb->protocol of FIP frames

Chris Mason (14):
      Btrfs: stop avoiding balancing at the end of the transaction.
      Btrfs: balance btree more often
      Btrfs: reduce mount -o ssd CPU usage
      Btrfs: fix metadata dirty throttling limits
      Btrfs: don't allow WRITE_SYNC bios to starve out regular writes
      Btrfs: avoid IO stalls behind congested devices in a multi-device F=
S
      Btrfs: Add mount -o nossd
      Btrfs: avoid allocation clusters that are too spread out
      Btrfs: add mount -o ssd_spread to spread allocations out
      Btrfs: autodetect SSD devices
      Btrfs: avoid races between super writeout and device list updates
      Btrfs: fix -o nodatasum printk spelling
      Btrfs: fix oops when btrfs_inherit_iflags called with a NULL dir
      Btrfs: fix extent_buffer leak during tree log replay

Chris Peterson (1):
      slow-work: use round_jiffies() for thread pool's cull and OOM timer=
s

Chris Pockel=C3=A9 (1):
      ALSA: hda - Add support of Samsung NC10 mini notebook

Chris Sanford (1):
      trivial: unnecessary (void*) cast removal in sound/oss/msnd.c

Chris Wilson (10):
      drm/i915: Sanity check execbuffer arguments before touching state.
      drm/i915: OR in the COMMAND read domain for the batch buffer.
      drm/i915: Call drm_vblank_post_modeset() on error paths.
      drm/i915: no need to hold mutex for object lookup
      drm/i915: use I915_GEM_GPU_DOMAINS
      drm/i915: NOMEM->NOSPC
      drm: Memory fragmentation from lost alignment blocks
      drm/i915: detach/attach get/put pages symmetry
      drm/i915: Install fence register for tiled scanout on i915
      drm/i915: Clear fence register on tiling stride change.

Chris Wright (8):
      x86: use native register access for native tlb flushing
      cfg80211: remove superfluous !last_request check in reg_device_remo=
ve()
      intel-iommu: dmar_set_interrupt return error value
      amd iommu: properly detach from protection domain on ->remove
      KVM: Trivial format fix in setup_routing_entry()
      amd-iommu: flush domain tlb when attaching a new device
      amd-iommu: disable cmd buffer and evt logging before reprogramming =
iommu
      amd-iommu: resume cleanup

Christian Borntraeger (6):
      KVM: declare ioapic functions only on affected hardware
      KVM: s390: use hrtimer for clock wakeup from idle - v2
      KVM: s390: optimize float int lock: spin_lock_bh --> spin_lock
      virtio: fix id_matching for virtio drivers
      virtio: enhance id_matching for virtio drivers
      [S390] pm: vmwatchdog power management callbacks.

Christian Engelmayer (4):
      jffs2: leaking jffs2_summary in function jffs2_scan_medium
      hwmon: (max6650) Add support for alarms
      sunrpc: potential memory leak in function rdma_read_xdr
      sched: Fix out of scope variable access in sched_slice()

Christian Lamparter (30):
      ar9170: fix hang on stop
      p54: clean up p54.h's struct p54_common
      p54: more SoftLED updates
      p54: add beacon filtering support
      Make ar9170 use common ath reg code
      p54: utilize all available key slots for decryption offload
      p54: remove obsolet signal quality calculation
      ath: add module information
      p54: remove module_ stubs
      p54: deactivate broken powersave function (part 2)
      p54: fix ps-poll delivery in ap mode
      mac80211: set CLEAR_PS for pspolled frames
      ar9170: rework rxstream code
      ar9170: handle otus' A-MPDU density definitions
      ar9170: uncomment powermgt case handle
      p54usb: remove some dead code
      p54usb: rework driver for resume
      ar9170usb: reset device on resume
      ar9170: fix beacon plcp settings
      ar9170: update hardware definitions
      ar9170: 40mhz fixes
      ar9170: introduce functions for MAC programming
      ar9170: use bitop macros for tx filter flags
      ar9170: kill duplicated HT feature flag
      ar9170: fix LED power state handling
      ar9170: fix lockdep warning on hibernate
      ar9170usb: more minor fixes
      ar9170: cancel led worker properly on exit
      ar9170: remove deprecated code
      ar9170: xmit code revamp

Christine Caulfield (1):
      dlm: connect to nodes earlier

Christof Schmitt (7):
      [SCSI] zfcp: Use correct req_id for traces
      [SCSI] zfcp: Update message and add description
      [SCSI] zfcp: Make queue_depth adjustable
      [SCSI] zfcp: Remove unnecessary default case and assignments
      [SCSI] zfcp: Add comments to switch/case fallthroughs
      [SCSI] zfcp: Keep ccw device and model id in zfcp_ccw.c
      [SCSI] zfcp: Update FC pass-through support

Christoph Hellwig (51):
      xfs: a couple getbmap cleanups
      xfs: fix getbmap vs mmap deadlock
      tracing: small trave_events sample Makefile cleanup
      virtio_blk: don't blindly derefence req->rq_disk
      cifs: reorganize get_cifs_acl
      cifs: clean up set_cifs_acl interfaces
      fat: split fat_generic_ioctl
      xfs: update max log size
      xfs: validate quota log items during log recovery
      xfs: kill xfs_qmops
      xfs: split inode flushing from xfs_sync_inodes_ag
      xfs: use generic inode iterator in xfs_qm_dqrele_all_inodes
      xfs: split xfs_sync_inodes
      xfs: remove SYNC_IOWAIT
      xfs: remove SYNC_BDFLUSH
      xfs: use generic Posix ACL code
      Btrfs: implement FS_IOC_GETFLAGS/SETFLAGS/GETVERSION
      remove s_async_list
      quota: cleanup dquota sync functions (version 4)
      btrfs: remove ->write_super and stop maintaining ->s_dirt
      ext3: remove ->write_super and stop maintaining ->s_dirt
      gfs2: remove ->write_super and stop maintaining ->s_dirt
      ocfs2: remove ->write_super and stop maintaining ->s_dirt
      qnx4: remove ->write_super
      remove ->write_super call in generic_shutdown_super
      cleanup sync_supers
      enforce ->sync_fs is only called for rw superblock
      push BKL down into ->put_super
      jffs2: move jffs2_write_super to super.c
      ->write_super lock_super pushdown
      xfs: remove ->write_super and stop maintaining ->s_dirt
      affs: add ->sync_fs
      bfs: add ->sync_fs
      exofs: add ->sync_fs
      ext2: add ->sync_fs
      fat: add ->sync_fs
      hfs: add ->sync_fs
      hfsplus: add ->sync_fs
      sysv: add ->sync_fs
      ufs: add ->sync_fs
      jffs2: call jffs2_write_super from jffs2_sync_fs
      nilfs2: call nilfs2_write_super from nilfs2_sync_fs
      remove the call to ->write_super in __sync_filesystem
      xfs: fix warnings with CONFIG_XFS_QUOTA disabled
      xfs: fix small mismerge in xfs_vn_mknod
      sh: remove stray markers.
      hd: stop defining MAJOR_NR
      pids: clean up find_task_by_pid variants
      reiserfs: remove stray unlock_super in reiserfs_resize
      update Documentation/filesystems/Locking
      cleanup __writeback_single_inode

Christoph Lameter (4):
      percpu: remove rbtree and use page->index instead
      security: use mmap_min_addr indepedently of security models
      page allocator: use a pre-calculated value instead of num_online_no=
des() in fast paths
      page-allocator: use integer fields lookup for gfp_zone and check fo=
r errors in flags passed to the page allocator

Chuck Ebbert (4):
      x86: Clear TS in irq_ts_save() when in an atomic section
      crypto: padlock-aes - work around Nano CPU errata in ECB mode
      crypto: padlock-aes - work around Nano CPU errata in CBC mode
      Remove low_latency flag setting from nozomi and mxser drivers

Chuck Lever (32):
      SUNRPC: Fix error return value of svc_addr_len()
      NFSD: Refactor transport removal out of __write_ports()
      NFSD: Refactor transport addition out of __write_ports()
      NFSD: Refactor portlist socket closing into a helper
      NFSD: Refactor socket creation out of __write_ports()
      NFSD: Note an additional requirement when passing TCP sockets to po=
rtlist
      NFSD: Finish refactoring __write_ports()
      NFSD: move lockd_up() before svc_addsock()
      NFSD: Prevent a buffer overflow in svc_xprt_names()
      SUNRPC: pass buffer size to svc_addsock()
      SUNRPC: pass buffer size to svc_sock_names()
      SUNRPC: Switch one_sock_name() to use snprintf()
      SUNRPC: Support PF_INET6 in one_sock_name()
      SUNRPC: Clean up one_sock_name()
      NFSD: Stricter buffer size checking in write_recoverydir()
      NFSD: Stricter buffer size checking in write_versions()
      NFSD: Stricter buffer size checking in fs/nfsd/nfsctl.c
      NFS: Do not display the setting of the "intr" mount option
      NFS: Return error code from nfs_callback_up() to user space
      NFS: Fix false error return from nfs_callback_up() if ipv6.ko is no=
t available
      lockd: Update NSM state from SM_MON replies
      lockd: Don't bother with RPC ping for NSM upcalls
      NFS: Clean up MNT program definitions
      NFS: Use xdr_stream-based XDR encoder for MNT's dirpath argument
      NFS: remove unused function in fs/nfs/mount_clnt.c
      NFS: Add separate mountd status code decoders for each mountd versi=
on
      NFS: add new file handle decoders to in-kernel mountd client
      NFS: add XDR decoder for mountd version 3 auth-flavor lists
      NFS: Update MNT and MNT3 reply decoding functions
      NFS: Remove unused XDR decoder functions
      NFS: Invalid mount option values should always fail, even with "slo=
ppy"
      NFS: More "sloppy" parsing problems

Chumbalkar Nagananda (1):
      [CPUFREQ] minor correction to cpu-freq documentation

Cindy H Kao (2):
      wimax/i2400m: when bootstrap fails, reinitialize the bootrom
      wimax/i2400m: use -EL3RST to indicate device reset instead of -ERES=
TARTSYS

Clemens Ladisch (8):
      sound: oxygen: reset DMA when stream is closed
      sound: virtuoso: add another DX PCI ID
      sound: virtuoso: enable HDAV S/PDIF input
      sound: virtuoso: add Xonar Essence ST support
      nls: utf8_wcstombs: use correct buffer size in error case
      nls: utf8_wcstombs: fix buffer overflow
      usb: return device strings in UTF-8
      sound: seq_midi_event: fix decoding of (N)RPN events

Cliff Cai (6):
      ASoC: SSM2602: remove unsupported sample rates
      ASoC: Blackfin: set the transfer size according the ac97_frame size
      ASoC: SSM2602: assign last substream to the master when shutting do=
wn
      wireless: libertas: fix unaligned accesses
      mtd: blackfin NFC: fix hang when using NAND on BF527-EZKITs
      ASoC: Blackfin: keep better track of SPORT configuration state

Cliff Wickman (2):
      x86: Fix UV BAU activation descriptor init
      x86: correct the conversion of EFI memory types

Clifford Wolf (1):
      i2c: Retry automatically on arbitration loss

Cohen David.A (1):
      V4L/DVB (11840): change kmalloc to vmalloc for sglist allocation in=
 videobuf_dma_map/unmap

Colin Tuckley (2):
      RealView: Add support for the RealView/PBX platform
      RealView: Allow CONFIG_LEDS on this platform

Coly Li (1):
      ocfs2: update comments in masklog.h

Corentin Chary (8):
      UBIFS: return proper error code if the compr is not present
      asus-laptop: platform dev as parent for led and backlight
      acpi4asus: update MAINTAINER and KConfig links
      asus_acpi: Deprecate in favor of asus-laptop
      eeepc-laptop: sync eeepc-laptop with asus_acpi
      eeepc-laptop: cpufv updates
      asus-laptop: use pr_fmt and pr_<level>
      asus-laptop: remove EXPERIMENTAL dependency

Cornelia Huck (3):
      PM/Hibernate: Move NVS routines into a seperate file (v2).
      [S390] pm: io subchannel driver power management callbacks
      [S390] pm: chsc subchannel driver power management callbacks

Craig Shelley (3):
      USB: CP210X Add device IDs
      USB: CP210X Use official request code definitions
      USB: CP210X Replace CP2101 with CP210x

Curt Wohlgemuth (1):
      ext4: Make the length of the mb_history file tunable

Cyrill Gorcunov (18):
      x86: irq.c - tiny cleanup
      x86: apic - introduce imcr_ helpers
      x86: apic - introduce dummy apic operations
      x86: smp.c - align smp_ops assignments
      x86: smpboot - wakeup_secondary should be done via __cpuinit sectio=
n
      x86: es7000, uv - use __cpuinit for kicking secondary cpus
      x86, apic: use pr_ macro
      x86: uv io-apic - use BUILD_BUG_ON instead of BUG_ON
      x86: uv - prevent NULL dereference in uv_system_init()
      x86: apic: Fixmap apic address even if apic disabled
      x86/pci: add 4 more return parameters to IO_APIC_get_PCI_irq_vector=
(), fix
      x86, apic: Fix dummy apic read operation together with broken MP ha=
ndling
      x86, nmi: Use predefined numbers instead of hardcoded one
      mm: setup_per_zone_inactive_ratio - do not call for int_sqrt if not=
 needed
      mm: setup_per_zone_inactive_ratio - fix comment and make it __init
      x86: mce: Don't touch THERMAL_APIC_VECTOR if no active APIC present
      x86, ioapic: Don't call disconnect_bsp_APIC if no APIC present
      proc: vmcore - use kzalloc in get_new_element()

Daisuke Nishimura (3):
      vmscan: handle may_swap more strictly
      memcg: remove mem_cgroup_cache_charge_swapin()
      memcg: add interface to reset limits

Dan Allongo (1):
      ALSA: usb - Add boot quirk for C-Media 6206 USB Audio

Dan Carpenter (3):
      missing unlock in jfs_quota_write()
      ERR_PTR() dereference in net/rds/iw.c
      ERR_PTR() dereference in net/rds/ib.c

Dan Smith (1):
      utsname.h: make new_utsname fields use the proper length constant

Dan Williams (6):
      libertas: simplify and clean up association/start/join setup
      libertas: restyle Marvell & IEEE TLV structure names
      libertas: convert CMD_802_11_AUTHENTICATE to a direct command
      libertas: convert CMD_802_11_ASSOCIATE to a direct command
      libertas: fix WPA adhoc network creation
      md/raid5: add missing call to schedule() after prepare_to_wait()

Daniel C Halperin (2):
      iwlwifi: do not set dual_stream_ant_msk for 3 streams
      iwlwifi: check triple_stream_basic_rates in iwl_full_rxon_required

Daniel Glockner (3):
      xtensa: enable s6gmac in s6105_defconfig
      xtensa: add m41t62 rtc to s6105 platform
      xtensa: enable m41t80 driver in s6105_defconfig

Daniel Gl=C3=B6ckner (9):
      ASoC: Add driver for s6000 I2S interface
      ASoC: s6105 IP camera machine specific ASoC code
      ASoC: correct s6000 I2S clock polarity
      imx: serial: fix one bit field type
      imx: serial: handle initialisation failure correctly
      USB: gadget: g_serial: append zlp when tx buffer becomes empty
      USB: gadget: imx_udc: don't queue more data when zlp is to be sent
      xtensa: allow variant to initialize own irq chips
      xtensa: support s6000 gpio irqs and alternate function selection

Daniel Laird (1):
      [WATCHDOG] Add pnx833x_wdt

Daniel Mack (30):
      ASoC: add SOC_DOUBLE_EXT macro
      ASoC: cs4270: fix Master Capture Switch polarity
      ASoC: cs4270: add Master Playback Switch
      ASoC: cs4270: introduce CS4270_I2C_INCR
      net: smsc911x: add power management functions
      ASoC: cs4270: add power management support
      Input: add driver for EETI touchpanels
      ARM: MX3: basic support for lilly-1131 board
      ARM: MX3: add skeleton for lilly-1131 development board
      ARM: MX3: add lilly-1131 ethernet support
      ARM: MX3: add MMC suuport for lilly1131-db
      ARM: MX3: add framebuffer support for lilly1131-db
      ARM: MX3: add NOR flash support for lilly-1131
      ARM: MX3: add I2C support for lilly-1131
      ALSA: snd_usb_caiaq: clean whitespaces
      ALSA: snd_usb_caiaq: use strlcpy
      ALSA: snd_usb_caiaq: give better longname
      ALSA: snd_usb_caiaq: give better shortname
      ALSA: snd_usb_caiaq: bump version number
      Support for lilly-1131 modules and baseboards [v2]
      ASoC: fix NULL pointer dereference in soc_suspend()
      ds2760_battery: cleanups in ds2760_battery_probe()
      w1: ds2760: add support for EEPROM read and write
      w1: ds2760_battery: add support for sleep mode feature
      ALSA: snd_usb_caiaq: set mixername
      USB: imx_udc: fix leak in imx_ep_alloc_request()
      console: make blank timeout value a boot option
      lis3: add click function
      ALSA: snd_usb_caiaq: fix legacy input streaming
      w1-gpio: add external pull-up enable callback

Daniel Ribeiro (6):
      ASoC: pxa-ssp.c fix clock/frame invert
      mtd: CFI: quirk for PF38F4476.
      mtd: CFI 1.0 and CFI 1.1
      pxamci: add regulator support.
      mfd: add PCAP driver
      pxa2xx_spi: fix for SPI_CS_HIGH

Daniel Schaeffer (1):
      mxc: Add i.MX27LITE board support

Daniel Silverstone (1):
      pca953x: support GPIOLIB GPIO naming

Daniel Suchy (1):
      USB: FTDI-SIO new device ids

Daniel Wagner (1):
      mac80211_hwsim: Group radios

Darren Hart (13):
      futex: separate futex_wait_queue_me() logic from futex_wait()
      futex: add helper to find the top prio waiter of a futex
      futex: split out atomic logic from futex_lock_pi()
      futex: split out fixup owner logic from futex_lock_pi()
      rt_mutex: add proxy lock routines
      futex: add FUTEX_HAS_TIMEOUT flag to restart.futex.flags
      futex: distangle futex_requeue()
      futex: split out futex value validation code
      futex: add requeue_pi functionality
      futex: fixup unlocked requeue pi case
      futex: fix futex_wait_setup key handling
      futex: remove FUTEX_REQUEUE_PI (non CMP)
      futex: add requeue-pi documentation

Darrick J. Wong (1):
      hwmon: (ibmaem) Automatically load on HC10 blade

Dave Airlie (11):
      radeon: remove _DRM_DRIVER from the preadded sarea map
      drm/i915: duplicate desired mode for use by fbcon.
      drm/radeon: fix mobility flags on new PCI IDs.
      drm/radeon: switch to using late_initcall
      fbdev: add support for handoff from firmware to hw framebuffers
      drm/radeon/kms: remove the _DRM_DRIVER from the KMS paths.
      drm/radeon: this VRAM vs aperture test is wrong, just remove it.
      agp: switch AGP to use page array instead of unsigned long array
      drm/radeon: fix unused variables warning
      drm/i915: enable GEM on PAE.
      agp: add user mapping support to ATI AGP bridge.

Dave Chinner (4):
      xfs: split inode data writeback from xfs_sync_inodes_ag
      xfs: factor out inode validation for sync
      xfs: remove unused parameter from xfs_reclaim_inodes
      xfs: introduce a per-ag inode iterator

Dave Graham (1):
      e1000e: Fixes possible phy corrupton on 82571 designs.

Dave Jones (2):
      [CPUFREQ] Clean up convoluted code in arch/x86/kernel/tsc.c:time_cp=
ufreq_notifier()
      via-velocity: Fix velocity driver unmapping incorrect size.

Dave Kleikamp (2):
      jfs: Add missing mutex_unlock call to error path
      jfs: fix regression preventing coalescing of extents

Dave Liu (2):
      serial: Make ucc_uart work in HW UART mode
      sata_fsl: Add power mgmt support

Dave Mitchell (1):
      of_serial: Add UPF_FIXED_TYPE flag

Dave Young (2):
      kobject: make kset_create check kobject_set_name return value
      driver-core: make sysdev_class_register check kobject_set_name retu=
rn value

David Brownell (21):
      Input: add dm355evm_keys driver
      davinci: gpio irq enable tweaks
      ARM: OMAP3: mmc-twl4030 uses regulator framework
      ARM: OMAP3: Initialize regulators for Beagle and Overo
      davinci: remove remnants of IRAM allocator
      davinci: soc-specific SRAM setup
      davinci: add SRAM allocator
      mtd: nand: don't walk past end of oobfree[]
      mtd: nand: minor davinci_nand cleanup
      mtd: nand: davinci_nand, 4-bit ECC for smallpage
      mtd: davinci_nand: cmdlinepart uses MTD IDs
      USB: twl4030-usb: fix minor reporting goofage
      USB: nop-usb-xceiv: behave when linked as a module
      musb: proper hookup to transceiver drivers
      musb: otg timer cleanup
      musb: make initial HNP roleswitch work (v2)
      musb: support disconnect after HNP roleswitch
      USB: pxa27x_udc: introduce pxa27x_clear_otgph()
      spi: move common spi_setup() functionality into core
      spi: move more spi_setup() functionality into core
      usbnet cdc_subset: fix issues talking to PXA gadgets

David Daney (23):
      MIPS: Add register definitions for PCI.
      MIPS: Add Cavium OCTEON PCI support.
      MIPS: Replace some magic numbers with symbolic values in tlbex.c
      MIPS: Fold the TLB refill at the vmalloc path if possible.
      MIPS: Allow R2 CPUs to turn off generation of 'ehb' instructions.
      MIPS: Remove execution hazard barriers for Octeon.
      MIPS: Remove dead case label.
      MIPS: Add named alloc functions to OCTEON boot monitor memory alloc=
ator.
      MIPS: Export cvmx_sysinfo_get needed by octeon-ethernet driver.
      MIPS: Cavium-Octeon: Add more board type constants.
      MIPS: Cavium-Octeon: Add more chip specific feature tests.
      MIPS: Export erratum function needed by octeon-ethernet driver.
      Staging: Add octeon-ethernet driver files.
      MIPS: Remove unused parameters from iPTE_LW.
      MIPS: Add support files for hugetlbfs.
      MIPS: Add hugetlbfs page defines.
      MIPS: TLB support for hugetlbfs.
      Hugetlbfs: Enable hugetlbfs for more systems in Kconfig.
      MIPS: Kconfig Add SYS_SUPPORTS_HUGETLBFS and enable it for some sys=
tems.
      MIPS: Allow CPU specific overriding of CP0 hwrena impl bits.
      MIPS: Move Cavium CP0 hwrena impl bits to cpu-feature-overrides.h
      Staging: octeon-ethernet: Convert to use net_device_ops.
      Staging: octeon-ethernet: Fix race freeing transmit buffers.

David Heidelberger (1):
      ALSA: hda - Add 7.1 support for MSI GX620

David Howells (15):
      sched: Document memory barriers implied by sleep/wake-up primitives
      SELinux: Don't flush inherited SIGKILL during execve()
      CRED: Rename cred_exec_mutex to reflect that it's a guard against p=
trace
      CRED: Guard the setprocattr security hook against ptrace
      FRV: Remove in-kernel strace code
      FRV: Implement TIF_NOTIFY_RESUME
      FRV: Don't turn on TIF_SYSCALL_TRACE unconditionally in syscall pro=
logue
      FRV: Implement new-style ptrace
      MN10300: Don't set the dirty bit in the DTLB entries in the TLB-mis=
s handler
      MN10300: Add utrace/tracehooks support
      FRV: Fix interaction with new generic header stuff
      RxRPC: Don't attempt to reuse aborted connections
      AFS: Correctly translate auth error aborts and don't failover in su=
ch cases
      LDSCRIPT: Name INIT_RAM_FS consistently
      MN10300: Fix the vmlinux ldscript

David Kilroy (2):
      cfg80211: mark ops as pointer to const
      cfg80211: mark wiphy->privid as pointer to const

David Rientjes (7):
      sched: emit thread info flags with stack trace
      oom: move oom_adj value from task_struct to mm_struct
      oom: avoid unnecessary mm locking and scanning for OOM_DISABLE
      oom: invoke oom killer for __GFP_NOFAIL
      oom: only oom kill exiting tasks with attached memory
      Staging: android: lowmemorykiller: cleanup android low memory kille=
r
      Staging: android: lowmemorykiller: fix possible android low memory =
killer NULL pointer

David Rowe (1):
      Staging: oslec bug fix

David S. Miller (85):
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-next-2.6
      Revert "vxge: use max() instead of VXGE_HW_SET_LEVEL"
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      net: Avoid modulus in skb_tx_hash() for forwarding case.
      net: Add missing rculist.h include to netdevice.h
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-next-2.6
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-next-2.6
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      net: Fix arg to trace_napi_poll() in netpoll.
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-next-2.6
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      net: Remove bogus reference to BUS_ID_SIZE in sysfs code.
      ixp4xx_eth: Remove references to BUS_ID_SIZE.
      cpmac: Remove references to BUS_ID_SIZE, use MII_BUS_ID_SIZE.
      sh_eth: Remove references to BUS_ID_SIZE, use MII_BUS_ID_SIZE inste=
ad.
      nl80211: Eliminate reference to BUS_ID_SIZE.
      phy: Eliminate references to BUS_ID_SIZE.
      appletalk: Add proper locking around IPDDP routing table.
      aoe: Remove superfluous clearing of skb fields in new_skb().
      wavelan: Remove bogus debugging on skb->next being non-NULL.
      p54: Use SKB list handling helpers instead of by-hand code.
      rtl8187: Remove pointless check in rtl8187_rx_cb().
      atm: Use SKB queue and list helpers instead of doing it by-hand.
      decnet: Use SKB queue and list helpers instead of doing it by-hand.
      econet: Use SKB queue and list helpers instead of doing it by-hand.
      tcp: Use SKB queue and list helpers instead of doing it by-hand.
      irda: Use SKB queue and list helpers instead of doing it by-hand.
      llc: Kill outdated and incorrect comment.
      Merge branch 'linux-2.6.31.y' of git://git.kernel.org/pub/scm/linux=
/kernel/git/inaky/wimax
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      Merge branch 'net-next' of git://git.kernel.org/pub/scm/linux/kerne=
l/git/vxy/lksctp-dev
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-next-2.6
      bluetooth: Kill skb_frags_no(), unused.
      skbuff: Add frag list abstraction interfaces.
      netdevice.h: Use frag list abstraction interfaces.
      appletalk: Use frag list abstraction interfaces.
      datagram: Use frag list abstraction interfaces.
      net/core/dev.c: Use frag list abstraction interfaces.
      net/core/skbuff.c: Use frag list abstraction interfaces.
      net/core/user_dma.c: Use frag list abstraction interfaces.
      ipv4: Use frag list abstraction interfaces.
      ipv6: Use frag list abstraction interfaces.
      netfilter: Use frag list abstraction interfaces.
      phonet: Use frag list abstraction interfaces.
      sctp: Use frag list abstraction interfaces.
      xfrm: Use frag list abstraction interfaces.
      be2net: Remove unnecessary frag list traversing.
      netfilter: Fix extra semi-colon in skb_walk_frags() changes.
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-next-2.6
      ieee802154: Use '%Zu' printf format for size_t.
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/holtmann/bluetooth-next-2.6
      Merge branch 'linux-2.6.31.y' of git://git.kernel.org/pub/scm/linux=
/kernel/git/inaky/wimax
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/kaber/nf-next-2.6
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/kaber/nf-next-2.6
      Merge branch 'for-next' of git://git.kernel.org/pub/scm/linux/kerne=
l/git/sameo/irda-2.6
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/torvalds/linux-2.6
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-next-2.6
      sparc64: Reclaim trap_block[]->hdesc
      sparc64: Move trap_block[] definitions into a new header file.
      sparc64: Store per-cpu offset in trap_block[]
      sparc64: Use BUILD_BUG_ON() in trap_init().
      sparc64: Refactor OBP cpu scanning code using an iterator.
      sparc64: Refactor MDESC cpu scanning code using an iterator.
      sparc: Call OF and MD cpu scanning explicitly from paging_init()
      sparc64: Make mdesc_fill_in_cpu_data take a cpumask_t pointer.
      sparc64: Defer cpu_data() setup until end of per-cpu data initializ=
ation.
      sparc64: Get rid of real_setup_per_cpu_areas().
      sparc64: Only allocate per-cpu areas for possible cpus.
      sparc64: Use new dynamic per-cpu allocator.
      sparc64: Add proper dynamic ftrace support.
      openprom: Squelch useless GCC warning.
      sparc: Wire up sys_rt_tgsigqueueinfo().
      sparc64: Update defconfig.
      x25: Fix sleep from timer on socket destroy.
      sonic: Fix build after ndo_start_xmit() changes.
      sparc64: Fix UP bootup regression.
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-next-2.6
      ide: Take over as maintainer.
      ide cmd64x: Remove serialize setting.

David T.L. Wong (1):
      V4L/DVB (11803): xc5000: add support for DVB-T tuning

David Teigland (2):
      dlm: fix use count with multiple joins
      dlm: use more NOFS allocation

David VomLehn (1):
      kbuild/Documentation: Incorrect makefile syntax in example

David Wong (3):
      V4L/DVB (11880): cx23885: support for card Mygica X8506 DMB-TH
      V4L/DVB (12000): lgs8gxx: lgs8913 fake signal strength option defau=
lt on
      V4L/DVB (12001): lgs8gxx: update signal strength scale

David Woodhouse (17):
      tun: add IFF_TUN_EXCL flag to avoid opening a persistent device.
      tun: add tun_flags, owner, group attributes in sysfs
      intel-iommu: Clean up handling of "caching mode" vs. context flushi=
ng.
      intel-iommu: Clean up handling of "caching mode" vs. IOTLB flushing.
      intel-iommu: Fix tiny theoretical race in write-buffer flush.
      intel-iommu: Tidy up iommu->gcmd handling
      firmware: speed up request_firmware(), v3
      [MTD] set blkdev parent to the mtd device, not its parent
      [MTD] Restore suspend/resume support for mtd devices
      [MTD] Remove mtd->{suspend,resume} calls from board drivers
      [MTD] Only set partition suspend/resume method if parent not regist=
ered
      [MTD] Remove option for add_mtd_partitions() to not register partit=
ions.
      mtd: DIL/NetPC broken for now
      mtd: Fix handling of mtdname in txx9ndfmc.c
      mtd: Fix pointer handling in compat ioctls to use compat_ptr()
      Merge branch 'next-mtd' of git://aeryn.fluff.org.uk/bjdooks/linux
      Btrfs: remove crc32c.h and use libcrc32c directly.

Davide Libenzi (1):
      epoll: fix nested calls support

Dean Anderson (3):
      V4L/DVB (11605): patch: s2255drv: code cleanup
      V4L/DVB (11851): patch: s2255drv: adding V4L2_MODE_HIGHQUALITY
      V4L/DVB (11738): patch: s2255drv: urb completion routine fixes

Denis Karpov (1):
      FAT: add 'errors' mount option

Denis V. Lunev (1):
      [WATCHDOG] iTCO_wdt: fix memory corruption when RCBA is disabled by=
 hardware

Devin Heitmueller (36):
      V4L/DVB (11786): xc5000: handle tuner reset failures properly
      V4L/DVB (11787): xc5000: cleanup i2c read routines
      V4L/DVB (11788): xc5000: cleanup i2c write routines
      V4L/DVB (11789): xc5000: check xc5000_readreg return value for XC_R=
ESULT_SUCCESS
      V4L/DVB (11790): xc5000: restore sleep routine
      V4L/DVB (11791): xc5000: do not sleep after digital tuning
      V4L/DVB (11792): xc5000: switch to new version of Xceive firmware
      V4L/DVB (11793): xc5000: Properly support power down for newer firm=
ware
      V4L/DVB (11794): au0828: reduce reset time for xc5000 to 10ms
      V4L/DVB (11795): xc5000: add build version to debug info
      V4L/DVB (11796): xc5000: start using the newer "finerfreq" tuning c=
ommand
      V4L/DVB (11797): xc5000: cleanup firmware loading messages
      V4L/DVB (11798): xc5000: add "no_poweroff" module option
      V4L/DVB (11799): xc5000: don't load firmware until a tuning request=
 is made
      V4L/DVB (11800): tuner-xc2028: show the proper module description f=
or no_poweroff option
      V4L/DVB (11801): dib0700: reduce xc5000 sleep time for Pinnacle 801=
e to 10ms
      V4L/DVB (11802): xc5000: switch to new xc5000 firmware 1.6.114 with=
 redistribution rights
      V4L/DVB (11804): xc5000: poll at 5ms interval for register write co=
mmand completion
      V4L/DVB (11805): au0828: send command to power down tuner when done=
 with analog
      V4L/DVB (11806): xc5000: add copyright line
      V4L/DVB (11807): cx88: remove xc5000 reset for Pinnacle 800i
      V4L/DVB (11808): au0828: get rid of debug printk that was causing c=
ompile failures
      V4L/DVB (11810): em28xx: properly set packet size based on the devi=
ce's eeprom configuration.
      V4L/DVB (11923): em28xx: Don't let device work unless connected to =
a high speed USB port
      V4L/DVB (11924): au0828: Don't let device work unless connected to =
a high speed USB port
      V4L/DVB (11925): em28xx: Add support for the K-World 2800d
      V4L/DVB (11926): tuner-core: fix warning introduced when cleaning u=
p xc5000 init routine
      V4L/DVB (11927): em28xx: provide module option to disable USB speed=
 check
      V4L/DVB (11928): au0828: provide module option to disable USB speed=
 check
      V4L/DVB (11979): em28xx: don't create audio device if not supported
      V4L/DVB (11784): cx88: Fix race condition between cx8800 startup an=
d hald
      V4L/DVB (11785): dvb_frontend: fix race condition resulting in drop=
ped tuning commands
      V4L/DVB (11875): dvb_frontend: fix case where fepriv->exit not rese=
t
      V4L/DVB (12100): em28xx: make sure the analog GPIOs are set if we u=
sed a card hint
      V4L/DVB (12101): em28xx: add support for EVGA inDtube
      V4L/DVB (12102): em28xx: add Remote control support for EVGA inDtub=
e

Dhananjay Phadke (25):
      netxen: code cleanup
      netxen: refactor netxen_adapter
      netxen: refactor transmit code
      netxen: defer firmware handshake
      netxen: async link event handling
      netxen: allocate status rings dynamically
      netxen: annotate register access functions
      netxen: sanitize function names
      netxen: enable rss for NX2031
      netxen: cache align register map table
      netxen: fix link event handling
      netxen: refactor netxen_recv_context struct
      netxen: fix firmware download
      netxen: fix race in tx ring acccess
      netxen: fix mac list management
      netxen: fix bonding support
      netxen: cache msi register offset
      netxen: fix irq tear down and msix leak.
      netxen: disable msi-x for NC512m adapter
      netxen: trivial register access cleanup
      netxen: fix msi irq setup
      netxen: fix detection of cut-thru firmware mode
      netxen: fix tx ring accounting
      netxen: fix build with without CONFIG_PM
      netxen: fix firmware init handshake

Diego Liziero (1):
      Staging winbond: boolean negation and bitwise operation in wrong or=
der

Dimitri Sivanich (1):
      mm: fix handling of pagesets for downed cpus

Dirk Brandewie (4):
      wimax/i2400m: Change d_printf() level for secure boot messages
      wimax/i2400m/sdio: Implement I2400M_RT_BUS reset type
      wimax/i2400m: move boot time poke table out of common driver
      wimax/i2400m/sdio: Add device specific poke table.

Dirk Eibach (2):
      moxa: prevent opening unavailable ports
      char: moxa, prevent opening unavailable ports

Divy Le Ray (8):
      cxgb3: set phy's mdio dev before the phy init sequence
      cxgb: set phy's mdio dev before the phy init sequence
      cxgb3: move away from LLTX
      cxgb3: Add Aeluros 2020 phy support
      cxgb3: add support for the Aquantia 10G-BT phy
      cxgb3: Update FW to 7.4.0
      cxgb3: minor aq100x phy fixes
      cxgb3: remove __GFP_NOFAIL usage

Dmitri Belimov (6):
      V4L/DVB (11604): saa7134: split Behold`s card entries to properly i=
dentify the model
      V4L/DVB (11733): increase MPEG encoder timout
      V4L/DVB (11734): remove hw reset of MPEG encoder when lost/found se=
q.
      V4L/DVB (11775): tuner: add support Philips MK5 tuner
      V4L/DVB (11934): Change order for FM tune
      V4L/DVB (11938): big rework of TS for saa7134

Dmitri Vorobiev (1):
      clockevents: tick_broadcast_device can become static

Dmitry Adamushko (1):
      x86: microcode: use smp_call_function_single instead of set_cpus_al=
lowed, cleanup of synchronization logic

Dmitry Baryshkov (3):
      [ARM] 5524/1: at91sam9g20ek: add i2c eeprom info
      ieee802154: use standard routine for printing dumps
      MAINTAINERS: fix address of IEEE 802.15.4 git tree

Dmitry Eremin-Solenikov (8):
      [ARM] pxa/csb726: switch to use smsc911x driver
      [ARM] pxa/csb726: register ac97 controller
      [ARM] pxa/spitz: drop unused header files from spitz.c
      [ARM] sa1100: remove unused collie_pm.c
      [ARM] pxa/sharpsl_pm: merge the two sharpsl_pm.c since it's now pxa=
 specific
      [ARM] pxa/sharpsl_pm: merge pxa-specific code into generic one
      [ARM] pxa/sharpsl_pm: drop set_irq_type calls
      [ARM] pxa/sharpsl_pm: cleanup of gpio-related code.

Dmitry Pervushin (3):
      UBI: add notification API
      UBI: remove built-in gluebi
      UBI: make gluebi a separate module

Dmitry Torokhov (12):
      Input: gtco - add MODULE_DESCRIPTION()
      Input: fp801-gp - add MODULE_DESCRIPTION()
      Input: gameport - rearrange EXPORT_SYMBOL() markings
      Input: serio - rearrange EXPORT_SYMBOL() markings
      Input: gpio-keys - remove depreciated IRQF_SAMPLE_RANDOM flag
      Input: keyboard - remove warning about raw mode not supported
      Merge commit 'v2.6.30-rc5' into next
      Input: ALPS - Dell Latitude D630/D800 have DualPoint
      Input: lifebook - don't send incomplete events
      Input: serio - do not use deprecated dev.power.power_state
      Merge commit 'v2.6.30' into next
      Driver core: fix comment for device_attach()

Don Skidmore (6):
      ixgbe: fix IXGBE_MTQC values
      ixgbe: add support for addition VT_CTL defines
      ixgbe: add define to support 82599 64 IVAR registers
      ixgbe: Use pci_wake_from_d3() instead of multiple pci_enable_wake()
      ixgbe: fix failing to log fan failures
      ixgbe: fix 82598 SFP initialization after driver load.

Dong, Eddie (2):
      KVM: MMU: Emulate #PF error code of reserved bits violation
      KVM: Use rsvd_bits_mask in load_pdptrs()

Dongxiao Xu (8):
      Staging: heci: fix userspace pointer mess
      Staging: heci: fix wrong order of device_lock and file_lock
      Staging: heci: fix spinlock order mess of device_lock and read_io_l=
ock
      Staging: heci: fix softirq safe to unsafe spinlock issue
      Staging: heci: fix typos and add wait after disconnect
      Staging: heci: fix setting h_is bit in h_csr register
      Staging: heci: do not print error when heci_bh_handler is already o=
n workqueue
      Staging: heci: fix the problem that file_ext->state should be prote=
cted by device_lock

Doug Thompson (20):
      amd64_edac: add driver header
      amd64_edac: add debugging/testing code
      amd64_edac: add DRAM error injection logic using sysfs
      amd64_edac: add MCA error types
      amd64_edac: add memory scrubber interface
      amd64_edac: add sys addr to memory controller mapping helpers
      amd64_edac: add functionality to compute the DRAM hole
      amd64_edac: add DRAM address type conversion facilities
      amd64_edac: add helper to dump relevant registers
      amd64_edac: assign DRAM chip select base and mask in a family-speci=
fic way
      amd64_edac: add k8-specific methods
      amd64_edac: add F10h-and-later methods-p1
      amd64_edac: add F10h-and-later methods-p2
      amd64_edac: add F10h-and-later methods-p3
      amd64_edac: add per-family descriptors
      amd64_edac: add ECC chipkill syndrome mapping table
      amd64_edac: add error decoding logic
      amd64_edac: add EDAC core-related initializers
      amd64_edac: add ECC reporting initializers
      amd64_edac: add module registration routines

Douglas Schilling Landgraf (1):
      V4L/DVB (11486): em28xx: Add EmpireTV board support

Dragoslav Zaric (1):
      Staging: otus: 80211core/ccmd.c: Fix Coding Style

Eddie Dong (1):
      KVM: MMU: Fix comment in page_fault()

Edgar E. Iglesias (1):
      microblaze: Add audit and seccomp thread flags.

Eero Nurkkala (2):
      ARM: OMAP: McBSP: Fix legacy interrupts to clear their status
      NOHZ: Properly feed cpufreq ondemand governor

Eli Cohen (2):
      IB/mthca: Add module parameter for number of MTTs per segment
      mlx4_core: Add module parameter for number of MTTs per segment

Elina Pasheva (9):
      sierra: driver urb handling improvements
      sierra: driver interface blacklisting
      USB: serial: sierra driver performance improvements
      USB: serial: sierra driver debug info visibility improvement
      USB: serial: sierra driver write path improvements
      USB: serial: sierra driver read path bug fix
      USB: serial: sierra driver zero length packet fix
      USB: serial: sierra driver interrupt urb resubmit fix
      USB: serial: sierra driver sierra_calc_num_ports() fix

Emil Medve (1):
      mv643xx_eth: Remove a stale PPC_MULTIPLATFORM

Erdem Aktas (1):
      perf_counter tools: fix buffer overwrite problem for perf top comma=
nd

Erez Zilber (1):
      libiscsi: add conn and scsi eh log debug flags

Eric Anholt (3):
      drm/i915: Save/restore cursor state on suspend/resume.
      drm/i915: Change GEM throttling to be 20ms like the comment says.
      drm: Remove memory debugging infrastructure.

Eric Dumazet (42):
      net: remove superfluous call to synchronize_net()
      loopback: packet drops accounting
      net: netif_tx_queue_stopped too expensive
      tcp: tcp_prequeue() cleanup
      tcp: tcp_prequeue() can use keyed wakeups
      bnx2: bnx2_tx_int() optimizations
      net: tx scalability works : trans_start
      net: add tx_packets/tx_bytes/tx_dropped counters in struct netdev_q=
ueue
      vlan: use struct netdev_queue counters instead of dev->stats
      net: release dst entry in dev_hard_start_xmit()
      ppp: unset IFF_XMIT_DST_RELEASE in ppp_setup()
      sch_teql: Use net_device internal stats
      net: txq_trans_update() helper
      atl1: use netdev->stats
      net: ALIGN/PTR_ALIGN cleanup in alloc_netdev_mq()/netdev_priv()
      net: use netdev stats in b44, sundance, via-rhine and via-velocity
      net: net/core/sock.c cleanup
      net: dont update dev->trans_start in 10GB drivers
      net: dont update dev->trans_start
      net: unset IFF_XMIT_DST_RELEASE in ipip_tunnel_setup()
      atm: unset IFF_XMIT_DST_RELEASE in clip_setup()
      net: unset IFF_XMIT_DST_RELEASE in ipgre_tunnel_setup()
      veth: dont release skb->dst in veth_xmit()
      net: unset IFF_XMIT_DST_RELEASE for qeth and ipoib
      net: ipv4/ip_sockglue.c cleanups
      net: add _skb_dst opaque field
      net: skb->rtable accessor
      net: skb->dst accessors
      net: skb cleanup
      net: num_dma_maps is not used
      net: skb_shared_info optimization
      net: dev_addr_init() fix
      r8169: use dev_kfree_skb() instead of dev_kfree_skb_irq()
      net: No more expensive sock_hold()/sock_put() on each tx
      net: ntohs() misuse
      net: use a deferred timer in rt_check_expire
      poll: avoid extra wakeups in select/poll
      net: sk_wmem_alloc has initial value of one, not zero
      net: correct off-by-one write allocations reports
      atm: sk_wmem_alloc initial value is one
      forcedeth: fix dma api mismatches
      netfilter: nf_conntrack: death_by_timeout() fix

Eric Lammerts (1):
      fix oops when using console=3DttymxcN with N > 0

Eric Miao (14):
      ASoC: simplify the SSP DMA parameters settings by run-time generati=
on
      ASoC: change stereo/mono to 32-bit/16-bit for pxa-ssp
      [ARM] pxa: add platform device ID table to pxa i2c driver
      [ARM] pxa: move mach/i2c.h to plat/i2c.h
      [ARM] pxa: add I2C (TWSI) devices to pxa168/pxa910
      [ARM] pxa: simplify secondary PWM handling and use platform_device_=
id table
      [ARM] pxa: allow PWM ID base number to be specified in pwm_id_table
      [ARM] pxa: build pwm.c according to HAVE_PWM instead of PXA_PWM
      [ARM] pxa: move pwm.c to common plat-pxa directory
      [ARM] pxa: add missing IRQ_PXA910_NONE to irqs.h
      [ARM] pxa: add PWM devices support for pxa168/910
      [ARM] pxa/littleton: add support for the Micro-SD slot (MMC1)
      [ARM] pxa: fix the conflicting non-static declarations of global_gp=
ios[]
      MAINTAINERS: update Eric Miao's email address and status

Eric Moore (5):
      [SCSI] mpt2sas: T10 DIF Support
      [SCSI] mpt2sas: LUN Reset Support
      [SCSI] mpt2sas: add query task support for MPT2COMMAND ioctl
      [SCSI] mpt2sas: using the same naming convention for all static fun=
ction
      [SCSI] mpt2sas: bump driver version to 01.100.03.00

Eric Paris (41):
      mutex: add atomic_dec_and_mutex_lock()
      mutex: add atomic_dec_and_mutex_lock()
      SELinux: drop secondary_ops->sysctl
      IMA: use current_cred() instead of current->cred
      IMA: Handle dentry_open failures
      IMA: open all files O_LARGEFILE
      securityfs: securityfs_remove should handle IS_ERR pointers
      TPM: get_event_name stack corruption
      IMA: remove read permissions on the ima policy file
      IMA: do not measure everything opened by root by default
      SELinux: move SELINUX_MAGIC into magic.h
      IMA: Minimal IMA policy and boot param for TCB IMA policy
      IMA: Add __init notation to ima functions
      SELinux: define audit permissions for audit tree netlink messages
      fsnotify: unified filesystem notification backend
      fsnotify: add marks to inodes so groups can interpret how to handle=
 those inodes
      fsnotify: parent event notification
      dnotify: reimplement dnotify using fsnotify
      fsnotify: generic notification queue and waitq
      fsnotify: include pathnames with entries when possible
      fsnotify: add correlations between events
      fsnotify: allow groups to add private data to events
      fsnotify: fsnotify marks on inodes pin them in core
      fsnotify: handle filesystem unmounts with fsnotify marks
      inotify: reimplement inotify using fsnotify
      fsnotify: move events should indicate the event was on a child
      dnotify: do not use ?true:false when assigning to a bool
      dnotify: do not bother to lock entry->lock when reading mask
      inotify/dnotify: should_send_event shouldn't match on FS_EVENT_ON_C=
HILD
      fsnotify: allow groups to set freeing_mark to null
      inotify: inotify_destroy_mark_entry could get called twice
      Audit: fix audit watch use after free
      Audit: better estimation of execve record length
      Audit: dereferencing krule as if it were an audit_watch
      Audit: unify the printk of an skb when auditd not around
      Audit: cleanup netlink mesg handling
      Audit: clean up audit_receive_skb
      audit: seperate audit inode watches into a subfile
      Audit: move audit_get_nd completely into audit_watch
      Audit: clean up all op=3D output to include string quoting
      audit: inode watches depend on CONFIG_AUDIT not CONFIG_AUDIT_SYSCAL=
L

Eric Piel (5):
      [SCSI] Update wording of CONFIG_SCSI_MULTI_LUN help
      lis3: fix misc device unregistering and printk
      lis3: remove automatic shutdown of the device
      lis3: use input_polled_device
      lis3: add three new laptop models

Eric Sandeen (3):
      ext4: fix for fiemap last-block test
      xfs: fix overflow in xfs_growfs_data_private
      ext4: Change all super.c messages to print the device

Eric W. Biederman (10):
      syscall: Implement a convinience function restart_syscall
      net-sysfs: Use rtnl_trylock in sysfs methods.
      net: FIX ipv6_forward sysctl restart
      net: Fix devinet_sysctl_forward
      net: Fix bridgeing sysfs handling of rtnl_lock
      net: Fix ipoib rtnl_lock sysfs deadlock.
      net: FIX bonding sysfs rtnl_lock deadlock
      syscall: Sort out syscall_restart name clash.
      af_packet: Teach to listen for multiple unicast addresses.
      tun: Fix unregister race

Erik Andr?n (62):
      V4L/DVB (11450): gspca - m5602-mt9m111: Convert the mt9m111 to use =
a v4l2 ctrl cache
      V4L/DVB (11452): gspca - m5602-po1030: Convert to have a v4l2 ctrl =
cache
      V4L/DVB (11453): gspca - m5602-s5k4aa: Convert to use the v4l2 ctrl=
 cache
      V4L/DVB (11454): gspca - m5602-mt9m111: Remove the unused power_dow=
n struct member
      V4L/DVB (11455): gspca - m5602-ov9650: Improve the vflip quirk hand=
ling.
      V4L/DVB (11456): gspca - m5602-po1030: Rename register defines, add=
 missing ones.
      V4L/DVB (11457): gspca - m5602-po1030: Simplify register defines
      V4L/DVB (11458): gspca - m5602-po1030: Set all v4l2 controls at sen=
sor init
      V4L/DVB (11459): gspca - m5602-po1030: Add auto white balancing con=
trol
      V4L/DVB (11460): gspca - m5602-po1030: Remove unnecessary error che=
ck
      V4L/DVB (11461): gspca - m5602-po1030: Probe read only register at =
probe time
      V4L/DVB (11462): gspca - m5602-po1030: Split up the init into init =
and start
      V4L/DVB (11463): gspca - m5602-po1030: Remove unneeded init sequenc=
es
      V4L/DVB (11464): gspca - m5602-mt9m111: Set the cached v4l2 ctrl va=
lues
      V4L/DVB (11465): gspca - m5602-s5k4aa: Set all v4l2 ctrls on sensor=
 init.
      V4L/DVB (11466): gspca - m5602: Let all ctrls on all sensors be sta=
tic
      V4L/DVB (11467): gspca - m5602: Move all dump_sensor to the init fu=
nction
      V4L/DVB (11468): gspca - m5602-mt9m111: Remove redundant init seque=
nces
      V4L/DVB (11469): gspca - m5602-mt9m111: More redundant init cleanup
      V4L/DVB (11470): gspca - m5602-mt9m111: Implement an auto white bal=
ancing control
      V4L/DVB (11471): gspca - m5602-mt9m111: Remove more redundant init
      V4L/DVB (11472): gspca - m5602-mt9m111: Remove lots of redundant in=
it code
      V4L/DVB (11473): gspca - m5602-po1030: Release reset when init is d=
one.
      V4L/DVB (11474): gspca - m5602-po1030: Fix sensor probing.
      V4L/DVB (11475): gspca - m5602-po1030: Lower the default blue and g=
ain balance
      V4L/DVB (11476): gspca - m5602: Add some more register defines
      V4L/DVB (11477): gspca - m5602-po1030: Set the blue balance in the =
init not red balance twice
      V4L/DVB (11478): gspca - m5602-mt9m111: Replace various magic const=
ants with defines
      V4L/DVB (11479): gspca - m5602-mt9m111: More magic constants replac=
ement
      V4L/DVB (11480): gspca - m5602-mt9m111: Remove lots of redundant se=
nsor reads
      V4L/DVB (11481): gspca - m5602-mt9m111: More constant replacement
      V4L/DVB (11482): gspca - m5602-mt9m111: Remove lots of redundant in=
it code
      V4L/DVB (11520): gspca - m5602-po1030: Remove redundant init sequen=
ces
      V4L/DVB (11521): gspca - m5602-ov9650: Add auto exposure ctrl
      V4L/DVB (11522): gspca - m5602-po1030: Add auto exposure control
      V4L/DVB (11523): gspca - m5602-po1030: Add private green balance co=
ntrol
      V4L/DVB (11524): gspca - m5602-mt9m111: Add green balance ctrl
      V4L/DVB (11525): gspca - m5602-mt9m111: Add blue balance ctrl
      V4L/DVB (11526): gspca - m5602-mt9m111: Add red balance ctrl
      V4L/DVB (11527): gspca - m5602-s5k4aa: Try to use proper read-modif=
y-write of the vflip/hflip
      V4L/DVB (11528): gspca - m5602-s5k4aa: Consolidate the gain setting=
s, adjust row start
      V4L/DVB (11529): gspca - m5602-s5k4aa: Add noise suppression ctrl
      V4L/DVB (11530): gspca - m5602-s5k4aa: Add brightness v4l2 ctrl
      V4L/DVB (11531): gspca - m5602-po1030: Clean up some comments
      V4L/DVB (11532): gspca - m5602-po1030: Move some code from the star=
t vector to the init vector
      V4L/DVB (11533): gspca - m5602-po1030: Setup window per resolution
      V4L/DVB (11534): gspca - m5602-po1030: Synthesize the hsync/vsync s=
etup
      V4L/DVB (11535): gspca - m5602-po1030: Add experimental QVGA suppor=
t
      V4L/DVB (11536): gspca - m5602-po1030: Impove the bridge vsync/hsyn=
c configuration
      V4L/DVB (11537): gspca - m5602-po1030: Clear subsampling flag when =
setting VGA mode
      V4L/DVB (11538): gscpa - m5602-ov9650: Add defines for some magic c=
onstants
      V4L/DVB (11539): gspca - m5602-ov9650: Be more strict during the hs=
ync/vsync synthesis
      V4L/DVB (11540): gspca - m5602-mt9m111: Replace magic constants wit=
h defines
      V4L/DVB (11541): gspca - m5602-mt9m111: Add a start function
      V4L/DVB (11542): gspca - m5602-mt9m111: Synthesize the hsync/vsync =
setup
      V4L/DVB (11543): gspca - m5602-mt9m111: Setup VGA resolution
      V4L/DVB (11544): gspca - m5602-mt9m111: Add experimental QVGA suppo=
rt
      V4L/DVB (11545): gspca - m5602-mt9m111: Activate vflip/hflip by def=
ault
      V4L/DVB (11546): gspca - m5602-mt9m111: Endianness fixes.
      V4L/DVB (11547): gspca - m5602-s5k83a: Align the v4l2 ctrl definiti=
ons
      V4L/DVB (11548): gspca - m5602-s5k83a: No need to initialize some r=
egisters in init
      V4L/DVB (11549): gspca - m5602-s5k83a: Remove lots of useless init

Erik Andr=C3=A9n (34):
      V4L/DVB (11628): gspca - m5602-s5k83a: Remove more init
      V4L/DVB (11629): gspca - m5602-s5k83a: Move some init code around
      V4L/DVB (11630): gspca - s5k83a: Add resolution annotations
      V4L/DVB (11631): gspca - m5602: Remove useless error check
      V4L/DVB (11632): gspca - m5602-s5k83a: Reset the v4l2 ctrl cache up=
on sensor init
      V4L/DVB (11633): gspca - m5602-s5k83a: Move hsync/vsync setup to st=
art function
      V4L/DVB (11635): gspca - m5602-ov7660: Initial checkin of sensor sk=
eleton code
      V4L/DVB (11636): gspca - m5602-ov7660: Design probe function
      V4L/DVB (11637): gspca - m5602-ov7660: Design init function.
      V4L/DVB (11638): gspca - m5602-ov7660: Make an educated guess on th=
e proper hsync/vsync
      V4L/DVB (11639): gspca - m5602-mt9m111: Correct the hflip/vflip sem=
antics
      V4L/DVB (11640): gspca - m5602-s5k4aa: Flip hflip and vflip togethe=
r
      V4L/DVB (11641): gspca - m5602-ov7660: Remove useless init data
      V4L/DVB (11642): gspca - m5602-ov7660: Add a gain ctrl
      V4L/DVB (11643): gspca - m5602: Add the ov7660 to the module parame=
ter description.
      V4L/DVB (11644): gspca - m5602-s5k4aa: Remove some unneeded init co=
de.
      V4L/DVB (11646): gspca - m5602-mt9m111: Disable QVGA until it has b=
een verified to work
      V4L/DVB (11647): gspca - m5602-po1030: Disable QVGA for now
      V4L/DVB (11648): gspca - m5602: Remove some needless error checking=
 and add comments
      V4L/DVB (11649): gspca - m5602: Probe the ov7660 sensor
      V4L/DVB (11650): gspca - m5602: Sort out macro conflict by adding a=
 prefix
      V4L/DVB (11684): gspca - m5602-s5k4aa: Add experimental SXGA suppor=
t
      V4L/DVB (11685): gspca - gspca-m5602: Constify parameters of two fu=
nctions
      V4L/DVB (11686): gspca - m5602-s5k4aa: Disable SXGA resolution for =
now
      V4L/DVB (11687): gspca - m5602-ov9650: Add missing v4l2 ctrl ids
      V4L/DVB (11690): gspca - m5602-s5k4aa: Add vflip quirk for the MSI =
L735
      V4L/DVB (11691): gspca - m5602-ov9650: Add ASUS A6K vflip quirk
      V4L/DVB (11692): gspca - m5602: Checkpatch.pl fixes
      V4L/DVB (11693): gspca - stv06xx-vv6410: Add exposure ctrl
      V4L/DVB (11694): gspca - stv06xx-vv6410: No need to double set gain=
 and exposure
      V4L/DVB (11695): gspca - stv06xx-vv6410: Set analog gain at init
      V4L/DVB (11940): gspca - m5602-s5k4aa: Add vflip quirk for the Leno=
vo Y300
      V4L/DVB (11941): gspca - m5602-ov9650: Add vflip quirk for the ASUS=
 A6VA
      V4L/DVB (11942): gspca - m5602-ov9650: Reorder quirk list and add A=
7V quirk

Erik Benada (1):
      [ARM] orion: convert gpio to use gpiolib

Etienne Basset (2):
      smack: implement logging V3
      smack: implement logging V3

Evgeni Golov (1):
      [libata] beautify module parameters

Evgeniy Polyakov (2):
      netfilter: x_tables: added hook number into match extension paramet=
er structure.
      netfilter: passive OS fingerprint xtables match

FUJITA Tomonori (27):
      x86: calgary: remove IOMMU_DEBUG
      dma-debug: add dma_debug_resize_entries() to adjust the number of d=
ma_debug_entries
      x86 gart: reimplement IOMMU_LEAK feature by using DMA_API_DEBUG
      block: let blk_end_request_all handle bidi requests
      scsi: simplify the bidi completion
      block: move completion related functions back to blk-core.c
      [SCSI] scsi_debug: fix virtual disk larger than 1TB
      net: replace dma_sync_single with dma_sync_single_for_cpu
      dma-debug: use sg_dma_address accessor instead of using dma_address=
 directly
      dma-debug: use sg_dma_len accessor
      dma-debug: fix debug_dma_sync_sg_for_cpu and debug_dma_sync_sg_for_=
device
      block: needs to set the residual length of a bidi request
      USB: replace dma_sync_single and dma_sync_sg with dma_sync_single_f=
or_cpu and dma_sync_sg_for_cpu
      sparc: move the duplication in dma-mapping_{32|64}.h to dma-mapping=
.h
      sparc: add sync_single_for_device and sync_sg_for_device to struct =
dma_ops
      sparc: use dma_map_page instead of dma_map_single
      sparc: remove dma-mapping_{32|64}.h
      V4L/DVB (11937): vino: replace dma_sync_single with dma_sync_single=
_for_cpu
      dma-mapping: add asm-generic/dma-mapping-common.h
      dma-mapping: x86: use asm-generic/dma-mapping-common.h
      dma-mapping: ia64: use asm-generic/dma-mapping-common.h
      dma-mapping: ia64: add CONFIG_DMA_API_DEBUG support
      dma-mapping: mark dma_sync_single and dma_sync_sg as deprecated
      scsi_transport_sas: needs to call blk_end_request_all for SMP reque=
sts
      block: revert "bsg: setting rq->bio to NULL"
      parport_pc: set properly the dma_mask for parport_pc device
      Blackfin: fix dma-mapping build errors

Fabian Godehardt (3):
      imx: serial: notify higher layers in case xmit IRQ was not called
      imx: serial: be sure to stop xmit upon shutdown
      imx: serial: add IrDA support to serial driver

Fabio Estevam (4):
      MX27: Add basic support to MX27PDK
      MX3: Add missing entry in devices.h
      fec: Add FEC support for MX35 processor
      MX35: Add basic support for MX35PDK board

Fabio Rossi (1):
      ath5k: fix interpolation with equal power levels

Faisal Latif (2):
      RDMA/nes: Fix max_qp_init_rd_atom returned from query device
      RDMA/nes: Fix FIN state handling under error conditions

Felipe Balbi (2):
      Input: add twl4030-pwrbutton driver
      Input: introduce lm8323 keypad driver

Felix Beck (1):
      [S390] ap/zcrypt: Suspend/Resume ap bus and zcrypt

Felix Blyakher (7):
      lockd: call locks_release_private to cleanup per-filesystem state
      xfs: fix double unlock in xfs_swap_extents()
      xfs: prevent deadlock in xfs_qm_shake()
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6
      Merge branch 'master' of git://git.kernel.org/pub/scm/fs/xfs/xfs
      xfs: fix freeing memory in xfs_getbmap()
      Merge branch 'master' of git://oss.sgi.com/xfs/xfs into for-linus

Fenghua Yu (3):
      Intel IOMMU Pass Through Support
      Fix !CONFIG_DMAR build failure introduced by Intel IOMMU Pass Throu=
gh Support
      IOMMU Identity Mapping Support (drivers/pci/intel_iommu.c)

Figo.zhang (14):
      ALSA: sgio2audio.c: clean up checking
      x86, microcode: Simplify vfree() use
      net pkgen.c:fix no need for check
      vxge: No need for check vfree() pointer.
      tehuti: No need check vfree() pointer.
      netxen: No need to check vfree() pointer.
      drm/via: vfree() no need checking before calling it
      V4L/DVB (11953): videobuf-dma-sg: return -ENOMEM if vmalloc fails
      V4L/DVB (11958): usbvision-core.c: vfree does its own NULL check
      V4L/DVB (11991): buf-core.c: add pointer check
      V4L/DVB (11995): zr364xx.c: vfree does its own NULL check
      V4L/DVB (12004): poll method lose race condition
      Documentation/atomic_ops.txt: fix sample code
      x86, io_apic.c: Work around compiler warning

Filipe Rosset (3):
      V4L/DVB (11487): em28xx: fix typo em28xx_errdev message
      V4L/DVB (11838): uvcvideo: Add Lenovo Thinkpad SL400 to device list=
 comments
      V4L/DVB (11895): bt8xx: remove always false if

Finn Thain (1):
      mac8390: use printk MAC address format

Florian Fainelli (10):
      r6040: check for absent PHY
      r6040: bump version to 0.23 and date to 05May2009
      r6040: check and update media status
      korina: periodically poll the media
      cpmac: remove unused variable.
      serial: add support for the TI AR7 internal UART
      drivers: add support for the TI VLYNQ bus
      MIPS: RB532: Cleanup cpu-features-overrides
      MIPS: RB532: Check irq number when handling GPIO interrupts
      lib: add lib/gcd.c

Florian Westphal (5):
      syncookies: remove last_synq_overflow from struct tcp_sock
      netfilter: xt_NFQUEUE: use NFPROTO_UNSPEC
      netfilter: xt_NFQUEUE: queue balancing support
      netfilter: ipt_MASQUERADE: remove redundant rwlock
      r8169: remove unused variable

Forest Bond (8):
      Staging: Add pristine upstream vt6655 driver sources
      Staging: vt6655 Add includes to drivers/staging/vt6655.
      Staging: vt6655: Drop obsolete fsuid/fsgid accesses.
      Staging: vt6655: Build vt6655.ko, not viawget.ko.
      Staging: vt6655: Replace net_device->priv accesses with netdev_priv=
 calls.
      Staging: vt6655: Remove LINUX_VERSION_CODE preprocessor conditional=
s.
      Staging: vt6655: use net_device_ops for management functions
      Staging: vt6655: Integrate drivers/staging/vt6655 into build system.

Frank Blaschka (3):
      [S390] pm: qeth driver power management callbacks
      [S390] pm: ctcm driver power management callbacks
      [S390] pm: claw driver power management callbacks

Frank Dischner (1):
      V4L/DVB (11987): au8522: add support for QAM-64 modulation type

Frank Leipold (1):
      uwb: allow WLP to be used with IPv6.

Frank Mori Hess (5):
      Staging: comedi: Finish removing ni_private typedef
      Staging: comedi: Fixed Kconfig option for COMEDI_PCMCIA_DRIVERS
      Staging: Comedi: ni_600x: Added support for comedi_poll.
      Staging: comedi: Added sysfs attribute files for setting and queryi=
ng subdevice buffer sizes.
      Staging: comedi: jr3_pci: Use struct device from pci_dev for firmwa=
re loading.

Frank Munzert (2):
      [S390] pm: vmur driver power management callbacks
      [S390] pm: tape power management callbacks

Frank Seidel (3):
      mISDN: Reduce stack size in dsp_cmx_send()
      mISDN: Add allocation of recvbuf[1500] at run time to reduce stack =
size
      crypto: tcrypt - Reduce stack size

Frank Shew (1):
      i2c: Blackfin TWI: fix transfer errors with repeat start

Franklin Meng (2):
      V4L/DVB (11976): em28xx: set up tda9887_conf in em28xx_card_setup()
      V4L/DVB (11977): em28xx: Add Kworld 315 entry

Frans Pop (11):
      kbuild, deb-pkg: minor general improvements in builddeb script
      kbuild, deb-pkg: refactor code to reduce duplication
      kbuild, deb-pkg: fix 'file not found' error when building .deb pack=
age for arm
      kbuild, deb-pkg: pass Debian maintainer script parameters to packag=
ing hook scripts
      kbuild, deb-pkg: allow to specify a custom revision for .deb packag=
es
      kbuild, deb-pkg: allow alternative hook scripts directory in .deb p=
ackages
      kbuild, deb-pkg: improve changelog entry and package descriptions
      kbuild, deb-pkg: generate debian/copyright file
      kbuild, deb-pkg: improve Source field
      USB: Avoid PM error messages during resume if a device was disconne=
cted
      PCI PM: consistently use type bool for wake enable variable

Frederic Weisbecker (23):
      tracing/ftrace: factorize the tracing files creation
      tracing/lockdep: report the time waited for a lock
      tracing/core: Add current context on tracing recursion warning
      tracing/ring-buffer: Add unlock recursion protection on discard
      tracing/events: provide string with undefined size support
      tracing/lock: provide lock_acquired event support for dynamic size =
string
      tracing/events: protect __get_str()
      vsprintf: introduce %pf format specifier
      tracing/filters: support for filters of dynamic sized arrays
      tracing/filters: support for operator reserved characters in string=
s
      tracing/stat: replace trace_stat_session by stat_session
      tracing/stat: replace linked list by an rbtree for sorting
      tracing/stat: remove unappropriate safe walk on list
      perf_counter: Sleep before refresh using poll in perf top
      perf_counter tools: Fix warn_unused_result warnings
      perf top: Fix zero or negative refresh delay
      perf top: Wait for a minimal set of events before reading first sna=
pshot
      perf annotate: Print the filename:line for annotated colored lines
      perf annotate: Print a sorted summary of annotated overhead lines
      perf annotate: Fixes for filename:line displays
      tracing/urgent: fix unbalanced ftrace_start_up
      tracing/urgent: warn in case of ftrace_start_up inbalance
      perfcounter: Handle some IO return values

Gabor Juhos (7):
      ath9k: uninline ath9k_io{read,write}32 routines
      ath9k: remove redundant AR9285 checks
      ath9k: restore power mode on error path
      ath9k: prevent sleeping while we are waiting for CAB
      ath9k: process rx packet if we are waiting for CAB
      ath9k: wait for beacon frame along with CAB
      ath9k: restore PS mode, before we put the chip into FULL SLEEP stat=
e.

Gabriel Paubert (1):
      net: Remove obsolete MV64360 config option

Gary Hade (2):
      x86: consolidate SMP code in io_apic.c
      x86/ACPI: Correct maximum allowed _CRS returned resources and warn =
if exceeded

Gautham R Shenoy (3):
      sched: Nominate idle load balancer from a semi-idle package.
      sched: Nominate a power-efficient ilb in select_nohz_balancer()
      sched: Replace first_cpu() with cpumask_first() in ILB nomination c=
ode

Geert Uytterhoeven (37):
      dlm: Make name input parameter of {,dlm_}new_lockspace() const
      wireless: WL12XX should depend on GENERIC_HARDIRQS
      powerpc: Keep track of emulated instructions
      crypto: testmgr - Kill test_comp() sparse warnings
      crypto: pcomp - pcompress.c should include crypto/internal/compress=
.h
      crypto: compress - Return produced bytes in crypto_{,de}compress_{u=
pdate,final}
      ALSA: sound/ps3: Fix checkpatch issues
      ALSA: sound/ps3: Restructure driver source
      ALSA: sound/ps3: Correct existing and add missing annotations
      ps3vram: Fix error path (return -EIO) for short read/write
      ps3vram: Use proc_create_data() instead of proc_create()
      ps3fb: Remove useless debug checks in ps3fb_shutdown()
      ps3fb: Inline functions in ps3fb_probe(), to ease cleanup in the er=
ror path
      ps3fb: Correct handling of device opening in ps3fb_probe()
      powerpc/cell: Extract duplicated IOPTE_* to <asm/iommu.h>
      ps3fb: GPU memory mapping cleanup
      ps3vram: GPU memory mapping cleanup
      ps3fb/vram: Extract common GPU stuff into <asm/ps3gpu.h>
      ps3fb: Tear down FB setup during cleanup
      block: Add bio_list_peek()
      ps3vram: Replace mutex by spinlock + bio_list
      ps3vram: Remove no longer used ps3vram_priv.ddr_base
      ps3vram: Make ps3vram_priv.reports a void *
      ps3: Use dev_[gs]et_drvdata() instead of direct access for system b=
us devices
      ps3: shorten ps3_system_bus_[gs]et_driver_data to ps3_system_bus_[g=
s]et_drvdata
      ps3flash: Use ps3_system_bus_[gs]et_drvdata() instead of direct acc=
ess
      ps3fb: Use ps3_system_bus_[gs]et_drvdata() instead of direct access
      drivers/ps3: Add missing annotations
      ps3: Correct debug message in dma_ioc0_map_pages()
      ps3: Switch ps3_os_area_[gs]et_rtc_diff to EXPORT_SYMBOL_GPL()
      ps3: Replace direct file operations by callback
      ps3flash: Cache the last accessed FLASH chunk
      ps3flash: Always read chunks of 256 KiB, and cache them
      net/ps3: gelic - Add missing annotations
      ps3rom: Use ps3_system_bus_[gs]et_drvdata() instead of direct acces=
s
      usb/ps3: Add missing annotations
      fbdev: move logo externs to header file

Geoff Levand (1):
      powerpc/ps3: Use smp_request_message_ipi

George G. Davis (1):
      [ARM] 5540/1: 32-bit Thumb-2 {ld,st}{m,rd} alignment fault fixup su=
pport

Gerald Schaefer (6):
      [S390] dcssblk: revert devt conversion
      [S390] pm: appldata power management callbacks
      [S390] pm: memory hotplug power management callbacks
      [S390] pm: monwriter power management callbacks.
      [S390] pm: monreader power management callbacks.
      [S390] pm: dcssblk power management callbacks.

Gerard Lledo (1):
      Staging: comedi: cb_pcidas.c: Fix build warning (type mismatch)

Gerhard Pircher (1):
      powerpc: Enable additional BAT registers in setup_745x_specifics()

GeunSik Lim (5):
      ftrace: fix typo about map of kernel priority in ftrace.txt file.
      sched: fix typo in sched-rt-group.txt file
      trivial: ftrace:fix description of trace directory
      debugfs: Fix terminology inconsistency of dir name to mount debugfs=
 filesystem.
      edac: Kconfig: fix the meaning of EDAC abbreviation

Giridhar Malavali (2):
      fc_transport: The softirq_done function registration for BSG reques=
t
      fc_transport: Selective return value from BSG timeout function

Glauber Costa (3):
      KVM: fix apic_debug instances
      KVM: Replace ->drop_interrupt_shadow() by ->set_interrupt_shadow()
      KVM: Deal with interrupt shadow state for emulated instructions

Gleb Natapov (51):
      KVM: APIC: kvm_apic_set_irq deliver all kinds of interrupts
      KVM: ioapic/msi interrupt delivery consolidation
      KVM: consolidate ioapic/ipi interrupt delivery logic
      KVM: change the way how lowest priority vcpu is calculated
      KVM: APIC: get rid of deliver_bitmask
      KVM: MMU: do not free active mmu pages in free_mmu_pages()
      KVM: SVM: Remove duplicate code in svm_do_inject_vector()
      KVM: reuse (pop|push)_irq from svm.c in vmx.c
      KVM: Timer event should not unconditionally unhalt vcpu.
      KVM: Fix interrupt unhalting a vcpu when it shouldn't
      KVM: VMX: Fix handling of a fault during NMI unblocked due to IRET
      KVM: VMX: Rewrite vmx_complete_interrupt()'s twisted maze of if() s=
tatements
      KVM: VMX: Do not zero idt_vectoring_info in vmx_complete_interrupts=
().
      KVM: Fix task switch back link handling.
      KVM: Fix unneeded instruction skipping during task switching.
      KVM: x86 emulator: fix call near emulation
      KVM: x86 emulator: Add decoding of 16bit second immediate argument
      KVM: x86 emulator: Add lcall decoding
      KVM: x86 emulator: Complete ljmp decoding at decode stage
      KVM: x86 emulator: Complete short/near jcc decoding in decode stage
      KVM: x86 emulator: Complete decoding of call near in decode stage
      KVM: x86 emulator: Add unsigned byte immediate decode
      KVM: x86 emulator: Completely decode in/out at decoding stage
      KVM: x86 emulator: Decode soft interrupt instructions
      KVM: x86 emulator: Add new mode of instruction emulation: skip
      KVM: SVM: Skip instruction on a task switch only when appropriate
      KVM: Make kvm_cpu_(has|get)_interrupt() work for userspace irqchip =
too
      KVM: VMX: Consolidate userspace and kernel interrupt injection for =
VMX
      KVM: VMX: Cleanup vmx_intr_assist()
      KVM: Use kvm_arch_interrupt_allowed() instead of checking interrupt=
_window_open directly
      KVM: SVM: Coalesce userspace/kernel irqchip interrupt injection log=
ic
      KVM: Remove exception_injected() callback.
      KVM: Remove inject_pending_vectors() callback
      KVM: Remove kvm_push_irq()
      KVM: sync_lapic_to_cr8() should always sync cr8 to V_TPR
      KVM: Do not report TPR write to userspace if new value bigger or eq=
ual to a previous one.
      KVM: Get rid of arch.interrupt_window_open & arch.nmi_window_open
      KVM: SVM: Add NMI injection support
      KVM: Fix userspace IRQ chip migration
      KVM: Get rid of get_irq() callback
      KVM: SVM: Don't reinject event that caused a task switch
      KVM: Unprotect a page if #PF happens during NMI injection.
      KVM: Do not allow interrupt injection from userspace if there is a =
pending event.
      KVM: Remove irq_pending bitmap
      KVM: skip_emulated_instruction() decode instruction if size is not =
known
      KVM: Do not re-execute INTn instruction.
      KVM: Always request IRQ/NMI window if an interrupt is pending
      KVM: inject NMI after IRET from a previous NMI, not before.
      KVM: Do not migrate pending software interrupts.
      KVM: Disable CR8 intercept if tpr patching is active
      KVM: Move "exit due to NMI" handling into vmx_complete_interrupts()

Graf Yang (19):
      netdev: bfin_mac: add Blackfin MII bus to platform bus to allow DSA=
 access
      Blackfin Serial Driver: fix missing new lines when under load
      Blackfin: fix link failure due to CONFIG_EXCEPTION_L1_SCRATCH
      Blackfin: fix bug found by traps test case 21
      Blackfin: add MDMA defines to make cross-variant coding easier
      Blackfin: work around anomaly 05000287
      Blackfin: BF518F-EZBRD: handle required portmuxing of async pins
      Blackfin: annotate anomaly 05000120
      Blackfin: add support for gptimer0 as a tick source
      Blackfin: add workaround for anomaly 05000287
      Blackfin: work around anomaly 05000220
      Blackfin: drop unused reserve_pda() function
      Blackfin: merge sram init functions
      Blackfin: fix handling of initial L1 reservation
      Blackfin: convert SMP to only use generic time framework
      Blackfin: bf518f-ezbrd: fix SPI CS for SPI flash
      Blackfin: bf526-ezbrd: set SPI flash resources to SST device
      Blackfin: fix typo in TRAS define in mem_init.h header
      Blackfin: bf526-ezbrd: handle different SDRAM chips

Graff Yang (1):
      irda: new Blackfin on-chip SIR IrDA driver

Grant Likely (19):
      of: add of_parse_phandle() helper for parsing phandle properties
      phylib: rework to prepare for OF registration of PHYs
      phylib: add *_direct() variants of phy_connect and phy_attach funct=
ions
      openfirmware: Add OF phylib support code
      net: Rework mpc5200 fec driver to use of_mdio infrastructure.
      net: rework fsl_pq_mdio driver to use of_mdio infrastructure
      net: Rework gianfar driver to use of_mdio infrastructure.
      net: Rework pasemi_mac driver to use of_mdio infrastructure
      net: Rework ucc_geth driver to use of_mdio infrastructure
      powerpc/82xx: Rework Embedded Planet ep8248e platform to use of_mdi=
o
      net: Rework fs_enet driver to use of_mdio infrastructure
      net: add Xilinx ll_temac device driver
      net: fix fsl_pq_mdio driver to use module_init()
      net: Fix ucc_geth.c handling of fixed-link w/o phy-connection-type =
property.
      powerpc/virtex: refactor intc driver and add support for i8259 casc=
ading
      powerpc/install: Bail with error code on error in install script
      Driver Core: Warn driver authors about adding device attributes
      fbdev/xilinxfb: Fix improper casting and tighen up probe path
      Revert "net/ucc_geth: Add SGMII support for UEC GETH driver"

Grazvydas Ignotas (2):
      ARM: OMAP3: pandora: setup regulator framework for MMC
      ARM: OMAP3: pandora: add support for mode devices

Greg Banks (3):
      knfsd: reply cache cleanups
      knfsd: fix reply cache memory corruption
      knfsd: remove unreported filehandle stats counters

Greg Kroah-Hartman (91):
      Input: wm97xx - do not access dev->driver_data directly
      net: remove driver_data direct access of struct device
      net: remove driver_data direct access of struct device from more dr=
ivers
      Wireless: remove driver_data direct access of struct device
      sound: remove driver_data direct access of struct device
      PCIE: remove driver_data direct access of struct device
      regulator: remove driver_data direct access of struct device
      firmware: remove broken example files
      driver core: fix gcc 4.3.3 warnings about string literals
      eisa: remove driver_data direct access of struct device
      firewire: remove driver_data direct access of struct device
      ide: remove driver_data direct access of struct device
      ieee1394: remove driver_data direct access of struct device
      infiniband: remove driver_data direct access of struct device
      input: remove driver_data direct access of struct device
      media: remove driver_data direct access of struct device
      mfd: remove driver_data direct access of struct device
      PCIE: remove driver_data direct access of struct device
      pcmcia: remove driver_data direct access of struct device
      scsi: remove driver_data direct access of struct device
      thermal: remove driver_data direct access of struct device
      xen block: remove driver_data direct access of struct device
      hvcs: remove driver_data direct access of struct device
      ibmvscsi: gadget: at91_udc: remove driver_data direct access of str=
uct device
      infiniband: ehca: remove driver_data direct access of struct device
      ipmi: remove driver_data direct access of struct device
      mips: remove driver_data direct access of struct device
      of_serial: remove driver_data direct access of struct device
      parisc: remove driver_data direct access of struct device
      parport: remove driver_data direct access of struct device
      s390: remove driver_data direct access of struct device
      uml: remove driver_data direct access of struct device
      usb: gadget: at91_udc: remove driver_data direct access of struct d=
evice
      xen: remove driver_data direct access of struct device from more dr=
ivers
      USB: add usb debugfs directory
      USB: EHCI: use the new usb debugfs directory
      USB: FHCI: use the new usb debugfs directory
      USB: OHCI: use the new usb debugfs directory
      USB: UHCI: use the new usb debugfs directory
      USB: usbmon: use the new usb debugfs directory
      USB: add the usbfs devices file to debugfs
      USB: OHCI: use the ohci structure directly in debugfs files.
      USB: EHCI: create sysfs companion files directly in the controller =
device
      USB: remove unused usb_host class
      USB: usbtmc: fix switch statment
      USB: xhci: fix lots of compiler warnings.
      USB: xhci: fix some compiler warnings in xhci.h
      V4L/DVB (11739): remove driver_data direct access of struct device
      Staging: add mailing list address for staging tree
      Staging: comedi: fix build errors in pcmcia comedi drivers
      Staging: comedi: set PCI and PCMCIA defines
      Staging: comedi: vmk80xx.c: get the driver to build properly
      Staging: comedi: remove comedi-specific wrappers
      Staging: comedi: remove RT code
      Staging: comedi: remove some RT code that lingered
      staging: comedi: fix pcmcia build breakage
      Staging: agnx: fix build warnings
      Staging: meilhaus: fix build warnings
      Staging: remove driver_data direct access of struct device
      Staging: rt2870: fix build warnings
      Staging: android: lowmemorykiller: fix up remaining checkpatch warn=
ings
      Staging: android: logger: fix up remaining checkpatch warnings
      Staging: android: ram_console: fix up remaining checkpatch warnings
      Staging: android: binder: fix up some checkpatch warnings
      Staging: android: fix Kconfig issues
      Staging: cpc-usb: fix some build problems in the driver
      Staging: cpc-usb: add driver to the build
      Staging: cpc-usb: fix up checkpatch errors in cpc-usb_drv.c
      Staging: cpc-usb: fix checkpatch warnings in sja2m16c.h
      Staging: cpc-usb: add TODO file
      Staging: cpc-usb: fix build warnings
      Staging: rtl8192su: fix build warnings
      Staging: altpciechdma: fix build warnings
      Staging: slicoss: fix build warnings
      Staging: asus_oled: fix build warnings
      Staging: remove obsolete serqt_usb driver
      Staging: pata_rdc: add driver to the build system
      Staging: pata_rdc: convert code to work in 2.6.29
      Staging: pata_rdc: coding style fixes
      Staging: pata_rdc: remove function prototypes
      Staging: pata_rdc: use PCI_DEVICE
      Staging: pata_rdc: fix build warnings
      Staging: pata_rdc: remove broken flag
      Staging: pata_rdc: remove dbgprintf macro
      Staging: pata_rdc: remove DRIVER macros
      Staging: pata_rdc: remove pointless comments
      Staging: udlfb: add udlfb driver to build
      Staging: udlfb: clean up checkpatch warnings in udlfb.h
      Staging: udlfb: clean up checkpatch warnings in udlfb.c
      Staging: udlfb: fix some sparse warnings.
      Staging: comedi: fix build errors

Greg Ungerer (16):
      m68knommu: fix system reset for ColdFire 527x family
      m68knommu: merge system reset for code ColdFire 523x family
      m68knommu: add CPU reset code for the 5307 ColdFire
      m68knommu: add CPU reset code for the 5407 ColdFire
      m68knommu: add CPU reset code for the 5206 ColdFire
      m68knommu: add CPU reset code for the 5206e ColdFire
      m68knommu: add CPU reset code for the 5249 ColdFire
      m68knommu: add CPU reset code for the 532x ColdFire
      m68knommu: move CPU reset code for the 520x ColdFire into its platf=
orm code
      m68knommu: move CPU reset code for the 523x ColdFire into its platf=
orm code
      m68knommu: move CPU reset code for the 527x ColdFire into its platf=
orm code
      m68knommu: move CPU reset code for the 528x ColdFire into its platf=
orm code
      m68knommu: move CPU reset code for the 5272 ColdFire into its platf=
orm code
      m68knommu: remove obsolete reset code
      m68knommu: enumerate INIT_THREAD fields properly
      m68knommu: remove unecessary include of thread_info.h in entry.S

Gr=C3=A9gory Lardi=C3=A8re (2):
      V4L/DVB (11688): gspca - m5602-s5k4aa: Fixup SXGA resolution.
      V4L/DVB (11689): gspca - m5602-s5k4aa: Fixup the vflip/hflip

Guennadi Liakhovetski (14):
      mxc: emulate GPIO interrupt on both-edges
      ARM: framebuffer support for pcm037
      ARM: add USB device support to pcm037
      FB: fix unsafe use of disable_irq() in mx3fb.c
      USB: gadget: Add i.MX3x support to the fsl_usb2_udc driver
      V4L/DVB (11607): soc-camera: add a free_bus method to struct soc_ca=
mera_link
      V4L/DVB (11608): soc-camera: host-driver cleanup
      V4L/DVB (11609): soc-camera: remove an extra device generation from=
 struct soc_camera_host
      V4L/DVB (11610): soc-camera: simplify register access routines in m=
ultiple sensor drivers
      V4L/DVB (11611): soc-camera: link host drivers after clients
      V4L/DVB (11705): soc-camera: prepare for the platform driver conver=
sion
      soc-camera: unify i2c camera device platform data
      SH: convert ap325rxa to soc-camera as platform-device
      SH: convert migor to soc-camera as platform-device

Gui Jianfeng (1):
      cfq: cleanup for last_end_request in cfq_data

Guido G=C3=BCnther (1):
      ALSA: support Sony Vaio TT

Gustavo F. Padovan (3):
      Bluetooth: Use macros for L2CAP channel identifiers
      Bluetooth: Use macro for L2CAP hint mask on receiving config reques=
t
      Bluetooth: Fix errors and warnings in L2CAP reported by checkpatch.=
pl

G=C3=A1bor Stefanik (7):
      rtl8187: Remove the "8187B chip detected" message when probing RTL8=
187B cards
      mac80211: Fix handling of retry count of NO_ACK frames in minstrel
      mac80211: Fix handling of retry count of NO_ACK frames in PID
      iwlwifi: Fix handling of retry count of NO_ACK frames in iwl-{3945|=
agn}-rs
      ath9k: Fix handling of retry count of NO_ACK frames
      mac80211: Warn if the rate controller requests retries for a NO_ACK=
 frame
      zd1211rw: Replace ZD_CS_MULTICAST with ZD_CS_NO_ACK

H Hartley Sweeten (9):
      Input: rotary_encoder - add support for REL_* axes
      Input: add matrix keypad driver for Cirrus EP93xx
      net/sunrpc/svc_xprt.c: fix sparse warnings
      mtd: plat_nand: add platform probe/remove callbacks
      mtd: plat_nand: allow platform to set partitions
      USB: core/sysfs: fix sparse warnings
      USB: host/ohci-hcd.c: fix sparse warnings
      USB: hub.c: fix sparse warnings
      mm/page-writeback.c: dirty limit type should be unsigned long

H. Peter Anvin (44):
      mutex: drop "inline" from mutex_lock() inside kernel/mutex.c
      x86, setup: "glove box" BIOS calls -- infrastructure
      x86, setup: "glove box" BIOS interrupts in the core boot code
      x86, setup: "glove box" BIOS interrupts in the APM code
      x86, setup: "glove box" BIOS interrupts in the EDD code
      x86, setup: "glove box" BIOS interrupts in the MCA code
      x86, setup: "glove box" BIOS interrupts in the video code
      x86, setup: fix comment in the "glove box" code
      x86: fix typo in address space documentation
      x86, boot: align the .bss section in the decompressor
      kbuild: allow compressors (gzip, bzip2, lzma) to take multiple inpu=
ts
      x86: add a Kconfig symbol for when relocations are needed
      x86, boot: simplify arch/x86/boot/compressed/Makefile
      x86, boot: follow standard Kbuild style for compression suffix
      x86, boot: use BP_scratch in arch/x86/boot/compressed/head_*.S
      x86, boot: stylistic cleanups for boot/compressed/head_32.S
      x86, boot: stylistic cleanups for boot/compressed/head_64.S
      x86, boot: straighten out ranges to copy/zero in compressed/head*.S
      x86, boot: set up the decompression stack as early as possible
      x86, boot: zero EFLAGS on 32 bits
      x86, boot: use appropriate rep string for move and clear
      x86, boot: determine compressed code offset at compile time
      x86, boot: make symbols from the main vmlinux available
      x86, boot: use LOAD_PHYSICAL_ADDR on 64 bits
      x86, boot: remove dead code from boot/compressed/head_*.S
      x86, boot: make kernel_alignment adjustable; new bzImage fields
      x86: document new bzImage fields
      x86: default CONFIG_PHYSICAL_START and CONFIG_PHYSICAL_ALIGN to 16 =
MB
      x86: make CONFIG_RELOCATABLE the default
      x86, defconfig: update to current, no material changes
      x86, defconfig: update kernel position parameters
      x86: add extension fields for bootloader type and version
      x86, boot: correct sanity checks in boot/compressed/misc.c
      x86-64: align __PHYSICAL_START, remove __KERNEL_ALIGN
      x86, boot: correct the calculation of ZO_INIT_SIZE
      Merge branch 'x86/urgent' into x86/setup
      x86, mce: add comment about mce_chrdev_ops being writable
      x86, mce: fix comment style in mce-inject.c
      x86, mce: drop "extern" from function prototypes in asm/mce.h
      Merge branch 'irq/numa' into x86/mce3
      x86: cap iomem_resource to addressable physical memory
      x86, boot: use .code16gcc instead of .code16
      x86, mce: mce_intel.c needs <asm/apic.h>
      devpts: remove module-related code

Haavard Skinnemoen (3):
      Merge branch 'avr32-arch' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/hskinnemoen/avr32-2.6
      avr32: Fix oops on unaligned user access
      atmel_serial: fix hang in set_termios when crtscts is enabled

Haiying Wang (12):
      powerpc/85xx: clean up for mpc8568_mds name
      powerpc/qe: update risc allocation for QE
      net/ucc_geth: update riscTx and riscRx in ucc_geth
      powerpc/qe: update QE Serial Number
      net/ucc_geth: Assign six threads to Rx for UEC
      powerpc/85xx: Add MPC8569MDS board support
      powerpc/qe: add new qe properties for QE based chips
      net/phy/marvell: update m88e1111 support for SGMII mode
      fsl_pq_mido: Set the first UCC as the mii management interface mast=
er
      net/ucc_geth: Add SGMII support for UEC GETH driver
      powerpc/85xx: Add UCC6 and UCC8 nodes in SGMII mode for MPC8569MDS
      net/ucc_geth: Add SGMII support for UCC GETH driver

Hannes Eder (2):
      NULL noise: arch/x86/xen/smp.c
      KVM: make 'lapic_timer_ops' and 'kpit_ops' static

Hannes Hering (1):
      IB/ehca: Tolerate dynamic memory operations before driver load

Hannes Reinecke (3):
      virtio_blk: SG_IO passthru support
      sd, sr: fix Driver 'sd' needs updating message
      dm mpath: change attached scsi_dh

Hans Verkuil (16):
      V4L/DVB (11670): tuner: remove tuner_i2c_address_check
      V4L/DVB (11671): v4l2: add v4l2_device_set_name()
      V4L/DVB (11672): ivtv: use v4l2_device_set_name.
      V4L/DVB (11673): v4l2-device: unregister i2c_clients when unregiste=
ring the v4l2_device.
      V4L/DVB (11676): radio-fm16: cleanups
      V4L/DVB (11677): radio-fm16: fix g_tuner.
      V4L/DVB (11967): v4l: i2c modules must be linked before the v4l2 dr=
ivers
      i2c: New macro to initialize i2c address lists on the fly
      V4L/DVB (12104): ivtv/cx18: fix regression: class controls are no l=
onger seen
      V4L/DVB (12107): smscoreapi: fix compile warning
      V4L/DVB (12108): v4l2-i2c-drv.h: add comment describing when not to=
 use this header.
      V4L/DVB (12109): radio-tea5764: fix incorrect rxsubchans value
      V4L/DVB (12111): tcm825x: remove incorrect __exit_p wrapper
      V4L/DVB (12112): cx231xx: fix uninitialized variable.
      V4L/DVB (12125): v4l2: add new s_config subdev ops and v4l2_i2c_new=
_subdev_cfg/board calls
      V4L/DVB (12128): v4l2: update framework documentation.

Hans de Goede (34):
      hwmon: (tmp401) Add support for TI's TMP401 sensor chip
      hwmon: (f71882fg) Cleanup f8000 pwm handling
      hwmon: (f71882fg) Sanity check f8000 pwm settings
      hwmon: (f71882fg) Add temp#_fault sysfs attr for f8000
      hwmon: (f71882fg) Add support for the F71858F
      V4L/DVB (11448): gspca - main: Use usb interface as parent.
      V4L/DVB (11871): gspca - spca561: Change the Rev12a controls.
      V4L/DVB (11872): gspca - spca561: Rename the 'White Balance' contro=
l to 'Hue'.
      V4L/DVB (11970): gspca - ov519: Add support for the ov518 bridge.
      V4L/DVB (11972): gspca - main: Skip disabled controls.
      V4L/DVB (11870): gspca - main: VIDIOC_ENUM_FRAMESIZES ioctl added.
      V4L/DVB (12071): gspca: fix NULL pointer deref in query_ctrl
      V4L/DVB (12072): gspca-ov519: add extra controls
      V4L/DVB (12073): gspca_ov519: limit ov6630 qvif uv swap fix to ov66=
308AF
      V4L/DVB (12074): gspca_ov519: Add 320x240 and 160x120 support for c=
if sensor cams
      V4L/DVB (12075): gspca_ov519: check ov518 packet numbers
      V4L/DVB (12076): gspca_ov519: Fix led inversion with some cams
      V4L/DVB (12077): gspca_ov519: Fix 320x240 with ov7660 sensor
      V4L/DVB (12078): gspca_ov519: Better default contrast for ov6630
      V4L/DVB (12079): gspca_ov519: add support for the ov511 bridge
      V4L/DVB (12080): gspca_ov519: Fix ov518+ with OV7620AE (Trust space=
cam 320)
      V4L/DVB (12081): gspca_ov519: Cleanup some sensor special cases
      V4L/DVB (12082): gspca_stv06xx: Add support for st6422 bridge and s=
ensor
      V4L/DVB (12083): ov511: remove ov518 usb id's from the driver
      V4L/DVB (12084): ov511: mark as deprecated
      V4L/DVB (12085): gspca_ov519: constify ov518 inititial register val=
ue tables
      V4L/DVB (12086): gspca_sonixj: Fix control index numbering
      V4L/DVB (12087): gspca_sonixj: enable support for 0c45:613e camera
      V4L/DVB (12088): Mark the v4l1 uvcvideo quickcam messenger driver a=
s deprecated
      V4L/DVB (12089): gspca_sonixj: increase 640x480 frame-buffersize
      V4L/DVB (12090): gspca_sonixj: enable autogain control for the ov76=
20
      V4L/DVB (12091): gspca_sonixj: Add light frequency control
      V4L/DVB (12092): gspca_sonixj + ov7630: invert vflip control instea=
d of changing default
      V4L/DVB (12093): gspca_sonixj: Name saturation control saturation, =
not color

Hans-Christian Egtvedt (1):
      Input: add wm97xx accelerated driver for Atmel microprocessors

Hans-Joachim Picht (2):
      [S390] pm: add kernel_page_present
      [S390] s390: hibernation support for s390

Hao Wu (1):
      USB: Add Intel Langwell USB OTG Transceiver Drive

Harald Welte (8):
      hwrng: via_rng - The VIA Hardware RNG driver is for the CPU, not Ch=
ipset
      hwrng: via_rng - Support VIA Nano hardware RNG
      hwrng: via_rng - Support VIA Nano hardware RNG on X86_64 builds
      CPUFREQ: Enable acpi-cpufreq driver for VIA/Centaur CPUs
      CPUFREQ: Mark e_powersaver driver as EXPERIMENTAL and DANGEROUS
      i2c-viapro: Add new PCI device ID for VX855
      mmc: Add new via-sdmmc host controller driver
      sdhci: Specific quirk vor VIA SDHCI controller in VX855ES

Harish Zunjarrao (2):
      [SCSI] qla2xxx: Correct hard-coded address of a second-port's NVRAM.
      qla2xxx: Correct iiDMA-update calling conventions.

Harry Ciao (3):
      edac: add CPC925 Memory Controller driver
      edac: add edac_device_alloc_index()
      edac: cpc925 MC platform device setup

Hartley Sweeten (5):
      [ARM] 5452/1: ep93x: rtc: use ioremap'ed addresses
      [ARM] 5504/1: ep93xx: Merge all edb93xx platforms
      [ARM] 5526/1: ep93xx: usb driver cleanup
      [ARM] 5527/1: ep93xx: core.c: trivial spelling error
      [ARM] 5528/1: ep93xx: add defines for dma clock magic numbers

Hauke Mehrtens (1):
      p54usb: Fixes compile error with CONFIG_PM=3Dn

Hector Martin (2):
      ALSA: hda - Acer Aspire 8930G support
      ALSA: hda - More Aspire 8930G fixes

Heiko Carstens (27):
      tracing: fix build failure on s390
      trace: disable preemption before taking raw spinlocks
      [S390] implement interrupt-enabling rwlocks
      [S390] add mini sclp driver
      [S390] implement is_compat_task
      [S390] secure computing arch backend
      [S390] uaccess: use might_fault() instead of might_sleep()
      [S390] vmalloc: add vmalloc kernel parameter support
      [S390] maccess: add weak attribute to probe_kernel_write
      [S390] maccess: arch specific probe_kernel_write() implementation
      [S390] kprobes: use probe_kernel_write
      [S390] ftrace: add dynamic ftrace support
      [S390] ftrace: add function trace mcount test support
      [S390] ftrace: add function graph tracer support
      [S390] ftrace: add system call tracer support
      [S390] wire up sys_rt_tgsigqueueinfo
      [S390] wire up sys_perf_counter_open
      PM: Add empty suspend/resume device irq functions
      [S390] time: convert from bootmem to slab
      [S390] 3215 console: convert from bootmem to slab
      [S390] 3270 console: convert from bootmem to slab
      [S390] sclp console: convert from bootmem to slab
      [S390] vt220 console: convert from bootmem to slab
      [S390] pm: fix build error for !SMP
      [S390] kprobes: defer setting of ctlblk state
      can: let SJA1000 driver depend on HAS_IOMEM
      net: let KS8842 driver depend on HAS_IOMEM

Heiko Schocher (1):
      83xx: add support for the kmeter1 board.

Hendrik Brueckner (10):
      af_iucv: sync sk shutdown flag if iucv path is quiesced
      af_iucv: add sockopt() to enable/disable use of IPRM_DATA msgs
      af_iucv: Support data in IUCV msg parameter lists (IPRMDATA)
      af_iucv: Modify iucv msg target class using control msghdr
      af_iucv: Provide new socket type SOCK_SEQPACKET
      af_iucv: cleanup and refactor recvmsg() EFAULT handling
      af_iucv: New socket option for setting IUCV MSGLIMITs
      [S390] pm: hvc_iucv power management callbacks
      af_iucv: Change if condition in sendmsg() for more readability
      af_iucv: Return -EAGAIN if iucv msg limit is exceeded

Henrique de Moraes Holschuh (7):
      thinkpad-acpi: store fw version with strict checking
      thinkpad-acpi: add quirklist engine
      thinkpad-acpi: fix BEEP ACPI handler warnings
      thinkpad-acpi: enhance led support
      thinkpad-acpi: silence bogus warning when ACPI video is disabled
      thinkpad-acpi: forbid the use of HBRV on Lenovo ThinkPads
      thinkpad-acpi: support the second fan on the X61

Herbert Xu (32):
      gro: New frags interface to avoid copying shinfo
      gro: Fix handling of headers that extend over the tail
      gro: Fix COMPLETE checksum handling
      tcp: Unexport TCPv6 GRO functions
      skbuff: Move new code into __copy_skb_header
      skbuff: Copy csum instead of csum_start/csum_offset
      gro: Open-code frags copy in skb_gro_receive
      gro: Inline skb_gro_header and cache frag0 virtual address
      gro: Localise offset/headlen in skb_gro_offset
      gro: Only use skb_gro_header for completely non-linear packets
      tcp: Optimise GRO port comparisons
      tcp: Remove unnecessary window comparisons for GRO
      tcp: Optimise len/mss comparison
      gro: Optimise length comparison in skb_gro_header
      gro: Avoid unnecessary comparison after skb_gro_header
      ipv4: Use 32-bit loads for ID and length in GRO
      gro: Open-code final pskb_may_pull
      gro: Nasty optimisations for page frags in skb_gro_receive
      gro: Store shinfo in local variable in skb_gro_receive
      tcp: Do not check flush when comparing options for GRO
      crypto: padlock - Restore dependency on x86
      crypto: testmgr - Dynamically allocate xbuf and axbuf
      crypto: testmgr - Check all test vector lengths
      crypto: testmgr - Allow hash test vectors longer than a page
      gso: Stop fraglists from escaping
      tun: Only wake up writers
      virtio_net: Set correct gso->hdr_len
      tun: Optimise handling of bogus gso->hdr_len
      net: Ensure partial checksum offset is inside the skb head
      [SCSI] cxgb3i: Include net/dst.h for struct dst_cache
      virtio_net: Fix IP alignment on non-mergeable RX path
      net: Move rx skb_orphan call to where needed

Hermann Kneissel (1):
      USB: garmin_gps: removes usb_reset_device from garmin_close

Hidetoshi Seto (32):
      x86: smarten /proc/interrupts output for new counters
      x86, mce: Cleanup param parser
      x86, mce: use strict_strtoull
      x86, mce: trivial clean up for therm_throt.c
      x86, mce: trivial clean up for mce.c
      x86, mce: trivial clean up for mce_amd_64.c
      x86, mce: trivial clean up for mce_intel_64.c
      x86, mce: trivial clean up for mce-inject.c
      x86: trivial clean up for arch/x86/Kconfig
      x86, mce: fix for mce counters
      x86, mce: Fix mce printing
      x86, mce: Add boot options for corrected errors
      PCI MSI: Remove unused/obsolete macros and definitions
      PCI MSI: Define PCI_MSI_MASK_32/64
      x86, mce: don't init timer if !mce_available
      x86, mce: cleanup mce_start()
      x86, mce: add __read_mostly
      x86, mce: rename static variables around trigger
      x86, mce: sysfs entries for new mce options
      x86, mce: unify mce.h
      x86, mce: make mce_disabled boolean
      x86, mce: unify smp_thermal_interrupt, prepare p4
      x86, mce: unify smp_thermal_interrupt, prepare mce_intel_64
      x86, mce: unify smp_thermal_interrupt, prepare
      x86, mce: unify smp_thermal_interrupt
      x86, mce: squash mce_intel.c into therm_throt.c
      x86, mce: remove intel_set_thermal_handler()
      x86, mce: remove therm_throt.h
      x86, mce: mce.h cleanup
      x86, mce: rename _64.c files which are no longer 64-bit-specific
      x86, mce: fix error path in mce_create_device()
      PCI: make msi_free_irqs() to use msix_mask_irq() instead of open co=
ded write

Hin-Tak Leung (1):
      zd1211rw: adding 083a:e503 as a ZD1211B device

Hiroshi DOYU (7):
      omap iommu: tlb and pagetable primitives
      omap iommu: omap2 architecture specific functions
      omap iommu: omap3 iommu device registration
      omap iommu: simple virtual address space management
      omap iommu: entries for Kconfig and Makefile
      omap2 iommu: entries for Kconfig and Makefile
      omap iommu: add MPU_BRIDGE_IOMMU for tidspbridge migration

Hisashi Hifumi (6):
      ocfs2: fdatasync should skip unimportant metadata writeout
      NILFS2: Pagecache usage optimization on NILFS2
      Btrfs: fdatasync should skip metadata writeout
      Btrfs: pin buffers during write_dev_supers
      jbd2: clean up jbd2_journal_try_to_free_buffers()
      jbd: clean up journal_try_to_free_buffers()

Hitoshi Mitake (2):
      sched: Hide runqueues from direct refer at source code level
      Making fs/minix/minix.h double including safe

Holger Schurig (2):
      imx: exit functions can/should be void
      imx: re-work of PWM, add i.MX21 support

Hong H. Pham (1):
      sparc64: fix and optimize irq distribution

Huang Shijie (1):
      lib: do code optimization for radix_tree_lookup() and radix_tree_lo=
okup_slot()

Huang Weiyi (11):
      RDS: remove unused #include <version.h>
      cfg80211: remove duplicated #include
      nl80211: remove duplicated #include
      x86: mce: remove duplicated #include
      sh: pci: remove duplicated #include's
      V4L/DVB: cx231xx: remove unused #include <linux/version.h>'s
      [ARM] S3C24XX: remove duplicated #include
      x86: Remove duplicated #include's
      Staging: comedi: remove dupilcated #include
      Staging: rt3070: remove dupilcated #include
      Staging: remove unused #include <linux/version.h>'s

Huang Ying (13):
      crypto: cryptd - Use nivcipher in cryptd_alloc_ablkcipher
      crypto: fpu - Add template for blkcipher touching FPU
      crypto: aes-ni - Add support for more modes
      x86, mce: improve mce_get_rip
      x86, mce: export MCE severities coverage via debugfs
      PCI: Add pci_bus_set_ops
      PCI: PCIE AER: export aer_irq
      PCI: PCIE AER: Document for PCIE AER software error injection
      PCI AER: software error injection
      x86, mce: fix a race condition about mce_callin and no_way_out
      crypto: aes-ni - Fix cbc mode IV saving
      crypto: aes-ni - Do not sleep when using the FPU
      crypto: aes-ni - Remove CRYPTO_TFM_REQ_MAY_SLEEP from fpu template

Hugh Dickins (5):
      ide: fix PowerMac bootup oops
      mm: alloc_large_system_hash check order
      hugetlb: fault flags instead of write_access
      mm: don't rely on flags coincidence
      mm: pass mm to grab_swap_token

Hugo Villeneuve (1):
      davinci: DM644x: add support for SFFSDR board

Hunter Adrian (1):
      UBIFS: return error if link and unlink race

Ian Abbott (6):
      Staging: comedi: 'pcmcia_parse_tuple()' now has two arguments, not =
three.
      Staging: comedi: pcl818: Fix option handling for FIFO mode (hopeful=
ly!).
      Staging: comedi: pcl818: Tidy up AI command after channel dropout o=
r similar error.
      Staging: comedi: Work around malformed RTAI_VERSION_CODE.
      Staging: comedi: Undo stupid commit made 3 months ago
      Staging: comedi: amplc_pc236: Corrected documentation.

Ian Campbell (8):
      xen: resume interrupts before system devices.
      xen: add irq_from_evtchn
      xen: add /dev/xen/evtchn driver
      xen: export ioctl headers to userspace
      xen: remove suspend_cancel hook
      xen: use device model for suspending xenbus devices
      xen: drop kexec bits from /sys/hypervisor since kexec isn't impleme=
nted yet
      xen: honour VCPU availability on boot

Ian Molton (1):
      tmio_mmc: fix clock setup

Igor M. Liplianin (6):
      V4L/DVB (11981): Remote control debugging for dw2102 driver based U=
SB cards
      V4L/DVB (11982): Add keymaps for TeVii and TBS USB DVB-S/S2 cards
      V4L/DVB (11983): Add support for DVBWorld DVB-C USB Cable card.
      V4L/DVB (11984): Add support for yet another SDMC DM1105 based DVB-=
S card.
      V4L/DVB (12095): Change lnbh24 configure bits for NetUP card.
      V4L/DVB (12098): Create table for customize stv0900 ts registers.

Ilpo J=C3=A4rvinen (2):
      tcp: extend ECN sysctl to allow server-side only ECN
      tcp: fix loop in ofo handling code and reduce its complexity

Imre Deak (2):
      ARM: OMAP2: 2430SDP: Add FB support to board file
      ARM: OMAP3: ZOOM MDK: Add FB support to board file

Imre Kaloz (3):
      [ARM] orion5x: WNR854T switch support
      MIPS: Sibyte: Remove simulator option
      MIPS: Sibyte: Remove standalone kernel support

InKi Dae (1):
      Samsung SoC Framebuffer driver: add Alpha Channel support

Inaky Perez-Gonzalez (24):
      wimax/i2400m: generate fake source MAC address with random_ether_ad=
dr()
      wimax/i2400m: trace commands sent from user space on the "echo" pip=
e
      wimax/i2400m: allow kernel commands to device to be logged too
      wimax/i2400m: factor out 'state report's TLV handling to a function
      wimax/i2400m: remove redundant readiness checks from i2400m_report_=
tlv_*()
      wimax: document why wimax_msg_*() operations can be used in any sta=
te
      wimax/i2400m: sdio: set the block size before enabling the function
      wimax/i2400m: usb: fix device reset on autosuspend while not yet id=
le
      wimax: a new API call was added, increment minor protocol version n=
umber
      wimax/i2400m: introduce module parameter to disable entering power =
save
      wimax/i2400m: don't call netif_start_queue() in _tx_msg_sent()
      wimax/i2400m: i2400m's work queue should be initialized before RX s=
upport
      wimax/i2400m: i2400m_schedule_work() doesn't need i2400m->work_queu=
e
      wimax/i2400m: rename misleading I2400M_PL_PAD to I2400M_PL_ALIGN
      wimax/i2400m: fix panic/warnings caused by missed check on empty TX=
 message
      wimax/i2400m: fix panic due to missed corner cases on tail_room cal=
culation
      wimax/i2400m: don't reset device on i2400m_dev_shutdown()
      wimax/i2400m: fix oops when the TX FIFO fills up due to a missing c=
heck
      wimax/i2400m: if a device reboot happens during probe, handle it
      wimax/i2400m: Allow bus-specific driver to specify retry count
      wimax/i2400m: don't reset device when bootrom init retries are exce=
eded
      wimax/i2400m/sdio: Move all the RX code to a unified, IRQ based rec=
eive routine
      wimax: fix warning caused by not checking retval of rfkill_set_hw_s=
tate()
      wimax: fix gcc warnings in sh4 when calling BUG()

Ingo Molnar (306):
      Merge branches 'x86/signal' and 'x86/irq' into perfcounters/core
      performance counters: documentation
      performance counters: x86 support
      x86, perfcounters: read out MSR_CORE_PERF_GLOBAL_STATUS with counte=
rs disabled
      perfcounters: select ANON_INODES
      perfcounters, x86: simplify disable/enable of counters
      perfcounters, x86: clean up debug code
      perfcounters: consolidate global-disable codepaths
      perf counters: restructure the API
      perf counters: add support for group counters
      perf counters: group counter, fixes
      perf counters: hw driver API
      perf counters: implement PERF_COUNT_CPU_CLOCK
      perf counters: consolidate hw_perf save/restore APIs
      perf counters: implement PERF_COUNT_TASK_CLOCK
      perf counters: add prctl interface to disable/enable counters
      perf counters: clean up state transitions
      perf counters: update docs
      Merge branch 'x86/irq' into perfcounters/core
      x86: implement atomic64_t on 32-bit
      perfcounters: restructure x86 counter math
      perfcounters: implement "counter inheritance"
      perfcounters: fix task clock counter
      perfcounters: add context switch counter
      perfcounters: add task migrations counter
      perfcounters: add nr-of-faults counter
      perfcounters: fix non-intel-perfmon CPUs
      perfcounters, x86: fix sw counters on non-PMC CPUs
      perfcounters: fix lapic initialization
      Merge branch 'linus' into perfcounters/core
      perfcounters: release CPU context when exiting task counters
      perfcounters: flush on setuid exec
      perfcounters: use hw_event.disable flag
      perfcounters: remove warnings
      perfcounters: tweak group scheduling
      x86, perfcounters: rename intel_arch_perfmon.h =3D> perf_counter.h
      x86, perfcounters: prepare for fixed-mode PMCs
      perfcounters: add fixed-mode PMC enumeration
      x86, perfcounters: refactor code for fixed-function PMCs
      perfcounters: hw ops rename
      perfcounters: fix task clock counter
      perfcounters: pull inherited counters
      perfcounters: fix init context lock
      perfcounters: enable lowlevel pmc code to schedule counters
      x86, perfcounters: print out the ->used bitmask
      perfcounters: remove ->nr_inherited
      perfcounters: generalize the counter scheduler
      perfcounters: add PERF_COUNT_BUS_CYCLES
      x86, perfcounters: add support for fixed-function pmcs
      perfcounters: include asm/perf_counter.h only if CONFIG_PERF_COUNTE=
RS=3Dy
      Merge branch 'linus' into perfcounters/core
      Merge commit 'v2.6.29-rc1' into perfcounters/core
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/paulus/perfcounters into perfcounters/core
      Merge branch 'core/percpu' into perfcounters/core
      Merge commit 'v2.6.29-rc2' into perfcounters/core
      Merge branch 'core/percpu' into perfcounters/core
      Merge branch 'core/percpu' into perfcounters/core
      perfcounters: fix "perf counters kills oprofile" bug, v2
      Merge commit 'v2.6.29-rc4' into perfcounters/core
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/paulus/perfcounters into perfcounters/core
      Merge branch 'linus' into perfcounters/core
      Merge branch 'x86/core' into perfcounters/core
      perfcounters: remove duplicate definition of LOCAL_PERF_VECTOR
      perfcounters: fix acpi_idle_do_entry() workaround
      Merge branch 'x86/apic' into perfcounters/core
      Merge branch 'x86/apic' into perfcounters/core
      Merge branch 'x86/core' into perfcounters/core
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/paulus/perfcounters into perfcounters/core
      Merge commit 'v2.6.29-rc7' into perfcounters/core
      Merge branch 'rfc' of git://git.kernel.org/pub/scm/linux/kernel/git=
/paulus/perfcounters into perfcounters/core
      perfcounters: fix reserved bits sizing
      x86, bts: cleanups
      x86, bts: detect size of DS fields, fix
      x86/mm: further cleanups of fault.c's include file section
      Merge branch 'linus' into perfcounters/core-v2
      perf_counter: fix crash on perfmon v1 systems
      perf_counter: create Documentation/perf_counter/ and move perfcount=
ers.txt there
      perf_counter: add sample user-space to Documentation/perf_counter/
      perf_counter tools: tidy up in-kernel dependencies
      perf_counter tools: fix build warning in kerneltop.c
      perf_counter tools: increase cpu-cycles again
      x86, perfcounters: add atomic64_xchg()
      Merge branch 'linus' into perfcounters/core
      Merge branch 'linus' into tracing/hw-branch-tracing
      Merge branch 'linus' into tracing/core
      Merge branch 'tracing/urgent' into tracing/ftrace
      Merge commit 'v2.6.30-rc1' into perfcounters/core
      mm, x86, ptrace, bts: defer branch trace stopping, cleanup
      mm, x86, ptrace, bts: defer branch trace stopping, remove dead code
      x86 early quirks: eliminate unused function
      perf_counter: fix off task->comm by one
      perf_counter tools: include PID in perf-report output, tweak user/k=
ernel printut
      Merge branch 'tracing/urgent' into tracing/core
      x86, irqinit: preempt merge conflicts
      Merge branch 'linus' into tracing/core
      Merge branch 'core/urgent' into core/rcu
      tracing: make the trace clocks available generally
      Merge branch 'linus' into x86/apic
      perf_counter: copy in Git's top Makefile
      perf_counter tools: add in basic glue from Git
      perf_counter tools: clean up after introduction of the Git command =
framework
      perf_counter tools: separate kerneltop into 'perf top' and 'perf st=
at'
      perf_counter tools: add help texts
      perf_counter tools: add 'perf record' command
      perf_counter tools: fix --version
      perf_counter tools: add 'perf help'
      perf_counter tools: fix 'make install'
      perfcounters, sched: remove __task_delta_exec()
      Merge branch 'linus' into x86/mm
      Merge commit 'v2.6.30-rc3' into tracing/hw-branch-tracing
      perf_counter tools: move helper library to util/*
      x86, vmlinux.lds: add copyright
      x86, vmlinux.lds: fix relocatable symbols
      Merge branch 'linus' into perfcounters/core
      perf_counter: add/update copyrights
      perf_counter tools: add perf-report to the Makefile
      perf_counter tools: perf stat: make -l default-on
      perf_counter tools: fix infinite loop in perf-report on zeroed even=
t records
      perf_counter tools: fix x86 syscall numbers
      Merge branch 'x86/apic' into irq/numa
      x86, mm: fault.c, use printk_once() in is_errata93()
      perf_counter: round-robin per-CPU counters too
      perf_counter: initialize the per-cpu context earlier
      perf_counter: convert perf_resource_mutex to a spinlock
      perf_counter: fix fixed-purpose counter support on v2 Intel-PERFMON
      irq: change ->set_affinity() to return status, fix
      Merge branch 'core/locking' into perfcounters/core
      x86: clean up arch/x86/kernel/tsc_sync.c a bit
      Merge branch 'linus' into tracing/core
      Merge branch 'tracing/hw-branch-tracing' into tracing/core
      Merge branch 'x86/urgent' into x86/xen
      perf_counter tools: remove debug code from builtin-stat.c
      Merge commit 'v2.6.30-rc5' into x86/mm
      Merge commit 'v2.6.30-rc5' into x86/apic
      Merge commit 'v2.6.30-rc5' into sched/core
      Merge commit 'v2.6.30-rc5' into core/iommu
      Merge branch 'x86/apic' into irq/numa
      perf_counter: x86: Fix throttling
      perf_counter: x86: Disallow interval of 1
      perf_counter: x86: Protect against infinite loops in intel_pmu_hand=
le_irq()
      perf_counter: Remove ACPI quirk
      perf stat: handle Ctrl-C
      perf_counter: fix threaded task exit
      perf_counter, x86: fix zero irq_period counters
      Merge commit 'v2.6.30-rc6' into perfcounters/core
      Merge commit 'v2.6.30-rc6' into x86/mm
      perf_counter, x86: speed up the scheduling fast-path
      Merge commit 'v2.6.30-rc6' into tracing/core
      sched: properly define the sched_group::cpumask and sched_domain::s=
pan fields
      perf_counter: fix counter freeing logic
      perf_counter: fix counter inheritance race
      perf_counter: Fix context removal deadlock
      perf_counter: fix !PERF_COUNTERS build failure
      perf_counter tools: increase limits
      perf_counter: Increase mmap limit
      perf_counter tools: increase limits, fix
      perf_counter: Move child perfcounter init to after scheduler init
      perf stat: flip around ':k' and ':u' flags
      Revert "perf_counter, x86: speed up the scheduling fast-path"
      perf_counter: fix warning & lockup
      perf_counter, x86: Fix APIC NMI programming
      perf_counter, x86: Make NMI lockups more robust
      perf_counter: Initialize ->oncpu properly
      perf record: Straighten out argv types
      perf stat: Remove unused variable
      perf record: Convert to Git option parsing
      perf_counter tools: Librarize event string parsing
      perf stat: Convert to Git option parsing
      perf top: Convert to Git option parsing
      perf_counter tools: remove the standalone perf-report utility
      perf record: Convert to Git option parsing
      perf report: Add help/manpage
      perf report: add --dump-raw-trace option
      perf report: add counter for unknown events
      perf report: add more debugging
      perf report: Only load text symbols from kallsyms, fix
      perf_counter tools: Introduce stricter C code checking
      perf_counter tools: Rename output.perf to perf.data
      perf_counter tools: Add built-in pager support
      perf report: Remove <ctype.h> include
      pref_counter: tools: report: Add header printout & prettify
      pref_counter: tools: report: Robustify in case of weird events
      perf_counter: Fix perf_counter_init_task() on !CONFIG_PERF_COUNTERS
      perf_counter tools: report: Add help text for --sort
      x86, mce: clean up mce_64.c
      x86, mce: clean up mce_32.c
      x86, mce: clean up p4.c
      x86, mce: clean up p5.c
      x86, mce: clean up p6.c
      x86, mce: clean up k7.c
      x86, mce: clean up winchip.c
      x86, mce: clean up non-fatal.c
      x86, mce: clean up therm_throt.c
      x86, mce: clean up mce_amd_64.c
      x86, mce: unify, prepare 64bit in mce.h
      x86, mce: unify, prepare codes
      x86, mce: unify, prepare for 32-bit v2
      x86, mce: unify
      x86, mce: Rename sysfs variables
      x86, mce: print number of MCE banks
      perf_counter tools: Clean up builtin-stat.c's do_perfstat()
      perf_counter tools: Split display into reading and printing
      perf_counter tools: Also display time-normalized stat results
      perf_counter: Fix cpuctx->task_ctx races
      perf_counter: Robustify counter-free logic
      perf_counter tools: Print 'CPU utilization factor' in builtin-stat
      perf_counter tools: Fix 'make install'
      perf_counter tools: Generate per command manpages (and pdf/html, et=
c.)
      perf_counter tools: Fix unknown command help text
      Merge branch 'linus' into perfcounters/core
      perf_counter: Tidy up style details
      Merge branch 'linus' into irq/numa
      Merge branch 'x86/cpufeature' into irq/numa
      perf report: Clean up the default output
      perf report: Fix column width/alignment of dsos
      perf record: Add --append option
      perf record: Increase mmap buffering default
      perf report: Print more info instead of <unknown> entries
      perf_counter tools: Make source code headers more coherent
      perf record: Print out the number of events captured
      perf report: Print -D to stdout
      perf report: Improve sort key recognition
      perf report: Handle vDSO symbols properly
      perf_counter tools: Clean up old kerneltop references
      perf record: Refine capture printout
      perf report: Display 100% correctly
      perf stat: Print out all arguments
      perf report: Add front-entry cache for lookups
      perf help: Fix bug when there's no perf-* command around
      perf_counter tools: Optimize harder
      perf_counter tools: Work around warnings in older GCCs
      perf_counter: Fix throttling lock-up
      perf report: Clean up event processing
      perf report: Split out event processing helpers
      perf report: Handle all known event types
      perf top: Reduce default filter threshold
      perf record/report: Fix PID/COMM handling
      Merge branch 'tracing/ftrace' into tracing/core
      perf_counter tools: Build with native optimization
      perf_counter tools: Print out symbol parsing errors only if --verbo=
se
      perf report: Print out the total number of events
      perf_counter tools: Add color terminal output support
      perf_counter tools: Dont output in color on !tty
      perf report: Bail out if there are unrecognized options/arguments
      perf stat: Update help text
      perf record: Split out counter creation into a helper function
      perf record, top: Implement --freq
      perf report: Display user/kernel differentiator
      perf_counter tools: Clarify events/samples naming
      Merge branch 'tip/tracing/ftrace-4' of git://git.kernel.org/pub/scm=
/linux/kernel/git/rostedt/linux-2.6-trace into tracing/ftrace
      perf_counter tools: Remove -march=3Dnative
      perf_counter tools: Sample and display frequency adjustment changes
      perf record: Set frequency correctly
      perf_counter: Separate out attr->type from attr->config
      perf_counter: Implement generalized cache event types
      perf_counter tools: Fix cache-event printout
      perf_counter tools: Uniform help printouts
      perf_counter tools: Tidy up manpage details
      perf_counter tools: Prepare for 'perf annotate'
      perf_counter tools: Add 'perf annotate' feature
      Merge branch 'linus' into perfcounters/core
      perf_counter tools: Move from Documentation/perf_counter/ to tools/=
perf/
      perf_counter tools: Fix error condition in parse_aliases()
      perf annotate: Automatically pick up vmlinux in the local directory
      perf annotate: Fix command line help text
      Merge branch 'linus' into core/iommu
      Merge branch 'dma-debug/2.6.31' of git://git.kernel.org/pub/scm/lin=
ux/kernel/git/joro/linux-2.6-iommu into core/iommu
      Merge branch 'linus' into x86/cpu
      perf stat: Continue even on counter creation error
      perf top: Fall back to cpu-clock-tick hrtimer sampling if no cycle =
counter available
      perf record: Fall back to cpu-clock-ticks if no PMU
      perf_counter tools: Handle kernels with !CONFIG_PERF_COUNTER
      perf report: Print more expressive message in case of file open err=
or
      perf stat: Print out instructins/cycle metric
      perf_counter: Clean up x86 boot messages
      perf_counter tools: Standardize color printing
      Merge branch 'amd-iommu/fixes' of git://git.kernel.org/pub/scm/linu=
x/kernel/git/joro/linux-2.6-iommu into core/iommu
      Revert "x86, bts: reenable ptrace branch trace support"
      perf_counter tools: Clean up u64 usage
      perf_counter: Better align code
      perf_counter: Turn off by default
      Merge branch 'linus' into perfcounters/core
      Merge branch 'linus' into x86/mce3
      perf stat: Reorganize output
      perf stat: Add feature to run and measure a command multiple times
      perf stat: Enable raw data to be printed
      [SCSI] cnic: fix error: implicit declaration of function =E2=80=98_=
_symbol_get=E2=80=99
      perf report: Print out raw events in hexa
      perf record/report: Add call graph / call chain profiling
      perf_counter, x86: Fix call-chain walking
      perf_counter, x86: Fix kernel-space call-chains
      perf record: Fix fast task-exit race
      perf report: Add per system call overhead histogram
      perf report: Fix 32-bit printf format
      x86: mm: Read cr2 before prefetching the mmap_lock
      Merge branch 'amd-iommu/fixes' of git://git.kernel.org/pub/scm/linu=
x/kernel/git/joro/linux-2.6-iommu into x86/urgent
      Merge branch 'linus' into x86/urgent
      Merge branch 'linus' into perfcounters/core
      Merge branch 'x86/urgent' into x86/mce3
      perf report: Tidy up the "--parent <regex>" and "--sort parent" cal=
l-chain features
      perf report: Add validation of call-chain entries
      perf report: Filter to parent set by default
      perf_counter, x86: Improve interactions with fast-gup
      Merge branch 'x86/mce3' into x86/urgent
      Merge branch 'tip/tracing/urgent' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/rostedt/linux-2.6-trace into tracing/urgent
      Merge branch 'tip/tracing/urgent-1' of git://git.kernel.org/pub/scm=
/linux/kernel/git/rostedt/linux-2.6-trace into tracing/urgent

Ivo Clarysse (2):
      MXC: mx21ads base support
      MXC: mx2_defconfig file

Ivo van Doorn (15):
      rt2x00: Move Move pci_dev specific access to rt2x00pci
      rt2x00: Fix Sparse warning
      rt2x00: Move iv_len into tx descriptor data
      rt2x00: Add support for L2 padding during TX/RX
      rt2x00: Implement support for 802.11n
      rt2x00: Implement support for rt2800usb
      rt2x00: Add new USB ID for rt2800usb
      rt2x00: Synchronize initialization with rt2870 driver
      rt2x00: Simplify rt2x00_check_rev
      rt2x00: Fix chipset detection for rt73usb
      rt2x00: Add USB ID for rt2800usb
      rt2x00: Add new rt2800usb USB ID's for Sweex
      rt2x00: Remove usage of IEEE80211_CONF_CHANGE_BEACON_INTERVAL
      rt2x00: Add new rt2800usb USB ID's
      rt2x00: Remove last usage of beacon_int from ieee80211_config

J. Bruce Fields (19):
      nfsd: eliminate ENCODE_HEAD macro
      nfsd4: delete obsolete xdr comments
      nfsd: support ext4 i_version
      nfsd: quiet compile warning
      nfsd4: setclientid_confirm callback-change fixes
      nfsd4: set shorter timeout
      nfsd4: set cb_client inside setup_callback_client
      nfsd4: create rpc callback client from server thread
      nfsd4: lookup up callback cred only once
      nfsd4: replace callback thread by asynchronous rpc
      nfsd4: rename callback struct to cb_conn
      nfsd4: eliminate struct nfs4_cb_recall
      nfsd4: remove unused dl_trunc
      nfsd4: track recall retries in nfs4_delegation
      nfsd4: make recall callback an asynchronous rpc
      Merge commit 'v2.6.30' into for-2.6.31
      nfsd: track last inode only in use_wgather case
      nfsd: Pull write-gathering code out of nfsd_vfs_write
      nfsd: minor nfsd_vfs_write cleanup

J. R. Okajima (2):
      remove unlock_kernel() left accidentally
      vfs: fix nd->root leak in do_filp_open()

J.R. Mauro (1):
      Staging: rspiusb: make driver compile

Jack Morgenstein (1):
      IB/mlx4: Add strong ordering to local inval and fast reg work reque=
sts

Jack Steiner (26):
      x86, UV: Fix macros for multiple coherency domains
      gru: bug fixes for GRU exception handling
      gru: dump chiplet state
      gru: dynamic allocation of kernel contexts
      gru: change context load and unload
      gru: support cch_allocate for kernel threads
      gru: change resource assignment for kernel threads
      gru: support contexts with zero dsrs or cbrs
      gru: fix handling of mesq failures
      gru: check context state on reload
      gru: support instruction completion interrupts
      gru: support for asynchronous gru instructions
      gru: update gru kernel self tests
      gru: update to rev 0.9 of gru spec
      gru: fix cache coherency issues with instruction retry
      gru: add user request to explicitly unload a gru context
      gru: fix automatic retry of gru instruction failures
      gru: collect per-context user statistics
      gru: delete user request for fetching chiplet status
      gru: cleanup gru inline functions
      gru: generic infrastructure for context options
      gru: add user request to specify gru slice
      gru: fix potential use-after-free when purging GRU tlbs
      gru: fixes to grudump utility
      gru: remove references to the obsolete global status handle
      gru: copyright fixes

Jack Stone (2):
      infiniband: Remove void casts
      i2c: Remove void casts

James Bottomley (15):
      block: allow blk_rq_map_kern to append to requests
      Merge branch 'scsi-fixes' into merge-base
      block: fix oops with block tag queueing
      block: fix an oops on BLKPREP_KILL
      [SCSI] fix up scsi_eh_lock_door()
      [SCSI] sd: fix bug in SCSI async probing
      [SCSI] mpt fusion: fix up doc book comments
      [SCSI] Merge branch 'linus'
      [SCSI] don't attach ULD to Dell Universal Xport
      [SCSI] aic79xx: make driver respect nvram for IU and QAS settings
      enhance device info matching for multiple tables
      scsi_transport_spi: use spi target settings instead of inquiry data=
 for DV
      scsi_transport_spi: Blacklist Ultrium-3 tape for IU transfers
      Revert "[SCSI] cnic: fix error: implicit declaration of function =E2=
=80=98__symbol_get=E2=80=99"
      [SCSI] scsi_transport_fc: replace BUS_ID_SIZE by fixed count

James Gardiner (1):
      ALSA: hda - Addition for HP dv4-1222nr laptop support

James Morris (5):
      Merge branch 'master' into next
      Merge branch 'master' into next
      Merge branch 'master' into next
      Merge branch 'next' into for-linus
      nfs: remove unnecessary NFS_INO_INVALID_ACL checks

James Smart (15):
      [SCSI] lpfc 8.3.2 : Reorganization for SLI4
      [SCSI] lpfc 8.3.2 : Addition of SLI4 Interface - Base Support
      [SCSI] lpfc 8.3.2 : Addition of SLI4 Interface - Queues
      [SCSI] lpfc 8.3.2 : Addition of SLI4 Interface - Mailbox handling
      [SCSI] lpfc 8.3.2 : Addition of SLI4 Interface - FCOE Discovery sup=
port
      [SCSI] lpfc 8.3.2 : Update of copyrights
      [SCSI] lpfc 8.3.2 : Miscellaneous Changes
      [SCSI] lpfc 8.3.2 : Persistent Vport Support
      [SCSI] lpfc 8.3.2 : Update the lpfc driver version to 8.3.2
      [SCSI] FC Pass Thru support
      [SCSI] lpfc 8.3.3 : Fix various SLI-3 vs SLI-4 differences
      [SCSI] lpfc 8.3.3 : FC/FCOE discovery fixes
      [SCSI] lpfc 8.3.3 : Fix a couple of spin_lock and memory issues and=
 a crash
      [SCSI] lpfc 8.3.3 : Add support for Target Reset handler entrypoint
      [SCSI] lpfc 8.3.3 : Update driver version to 8.3.3

Jan Beulich (1):
      initconst adjustments

Jan Blunck (3):
      powerpc/spufs: Remove double check for non-negative dentry
      KVM: Wake up waitqueue before calling get_cpu()
      atomic: only take lock when the counter drops to zero on UP as well

Jan Ceuleers (1):
      V4L/DVB (11962): dvb: Fix broken link in get_dvb_firmware for nxt20=
04 (A180)

Jan Engelhardt (12):
      netfilter: xtables: use NFPROTO_ for xt_proto_init callsites
      netfilter: queue: use NFPROTO_ for queue callsites
      netfilter: xtables: use NFPROTO_ in standard targets
      netfilter: xtables: remove redundant casts
      netfilter: xtables: fix const inconsistency
      netfilter: xtables: consolidate open-coded logic
      netfilter: xtables: reduce indent level by one
      netfilter: xtables: remove some goto
      netfilter: xtables: remove another level of indent
      netfilter: xtables: consolidate comefrom debug cast access
      netfilter: xtables: print hook name instead of mask
      netfilter: xt_quota: fix incomplete initialization

Jan Glauber (8):
      [S390] qdio: simplify error handling in irq handler
      [S390] qdio: inline qdio_perf_stat_inc
      [S390] qdio: move adapter interrupt tasklet code
      [S390] qdio: fix check for running under z/VM
      [S390] qdio: extract all primed SBALs at once
      [S390] qdio: merge AI tasklet into interrupt handler
      [S390] qdio: leave inbound SBALs primed
      [S390] qdio: Sanitize do_QDIO sanity checks

Jan Kara (22):
      ocfs2: Fix possible deadlock in ocfs2_global_read_dquot()
      ocfs2: Fix lock inversion in ocfs2_local_read_info()
      ocfs2: Fix possible deadlock with quotas in ocfs2_setattr()
      ocfs2: Fix possible deadlock in quota recovery
      ocfs2: Correct ordering of ip_alloc_sem and localloc locks for dire=
ctories
      ext4: Get rid of EXTEND_DISKSIZE flag of ext4_get_blocks_handle()
      vfs: Fix sys_sync() and fsync_super() reliability (version 4)
      vfs: Call ->sync_fs() even if s_dirt is 0 (version 4)
      vfs: Make __fsync_super() a static function (version 4)
      vfs: Make sys_sync() use fsync_super() (version 4)
      vfs: Move syncing code from super.c to sync.c (version 4)
      vfs: Rename fsync_super() to sync_filesystem() (version 4)
      quota: Introduce writeout_quota_sb() (version 4)
      udf: Use device size when drive reported bogus number of written bl=
ocks
      ext2: Do not update mtime of a moved directory
      ext3: fix chain verification in ext3_get_blocks()
      ext3: make sure inode is deleted from orphan list after truncate
      isofs: let mode and dmode mount options override rock ridge mode se=
tting
      isofs: fix setting of uid and gid to 0
      isofs: cleanup mount option processing
      vfs: Set special lockdep map for dirs only if not set by fs
      ocfs2: Add lockdep annotations

Jan Kasprzak (1):
      netfilter: nf_ct_icmp: keep the ICMP ct entries longer

Jan Kiszka (2):
      KVM: MMU: Fix auditing code
      KVM: Drop request_nmi from stats

Jan Nikitenko (1):
      V4L/DVB (11999): af9015: fix stack corruption bug

Jani Monoses (1):
      V4L/DVB (11720): gspca - sonixj: Webcam 06f8:3008 added

Jani Nikula (1):
      gitignore: Add GNU GLOBAL files to top .gitignore

Jarek Poplawski (7):
      pkt_sched: gen_estimator: Fix signed integers right-shifts.
      pkt_sched: Use PSCHED_SHIFT in PSCHED time conversion
      pkt_sched: Change PSCHED_SHIFT from 10 to 6
      ipv4: Fix fib_trie rebalancing
      pkt_sched: Rename PSCHED_US2NS and PSCHED_NS2US
      pkt_sched: Update drops stats in act_police
      ipv4: Fix fib_trie rebalancing, part 2

Jarkko Nikula (1):
      ARM: OMAP: Update contact address of I2C registration helper

Jarod Wilson (11):
      crypto: testmgr - Handle AEAD test vectors expected to fail verific=
ation
      crypto: testmgr - Add self-tests for rfc4309(ccm(aes))
      crypto: testmgr - Add infrastructure for ansi_cprng self-tests
      crypto: testmgr - Add ansi_cprng test vectors
      crypto: testmgr - Catch base cipher self-test failures in fips mode
      crypto: testmgr - Print self-test pass notices in fips mode
      crypto: testmgr - Add ctr(aes) test vectors
      crypto: testmgr - Mark algs allowed in fips mode
      crypto: testmgr - Skip algs not flagged fips_allowed in fips mode
      crypto: tcrypt - Do not exit on success in fips mode
      drm/i915: add ignore lvds quirk info for AOpen Mini PC

Jaroslav Kysela (10):
      ALSA: au88x0: fix .pointer callback
      ALSA: au88x0: fix wrong period_elapsed() call
      ALSA: PCM midlevel: improve fifo_size handling
      ALSA: PCM midlevel: introduce mask for xrun_debug() macro
      ALSA: PCM midlevel: Do not update hw_ptr_jiffies when hw_ptr is not=
 changed
      ALSA: PCM midlevel: lower jiffies check margin using runtime->delay=
 value
      ALSA: hda-intel: improve initialization for ALC262_HP_BPC model
      ALSA: Core - add snd_card_set_id() function
      ALSA: Core - clean up snd_card_set_id* calls and remove possible id=
 collision
      ALSA: pcm - Fix a typo in hw_ptr update check

Jason Baron (3):
      kerneldoc, tracing: make kernel-doc understand TRACE_EVENT() macro =
(take #2)
      tracing: add new tracepoints docbook
      tracing: add irq tracepoint documentation

Jason Wessel (6):
      USB: usb_debug, usb_generic_serial: implement multi urb write
      USB: serial: ftd_sio usb: move status check
      USB: serial: usb_debug,usb_generic_serial: implement sysrq and seri=
al break
      USB: serial: ftd_sio: implement sysrq handling on break
      USB: pl2303 usb_serial: implement sysrq handling on break
      USB: usb_serial: only allow sysrq on a console port

Jaswinder Singh (1):
      x86: perf_counter.c intel_perfmon_event_map and max_intel_perfmon_e=
vents should be static

Jaswinder Singh Rajput (37):
      x86: perf_counter remove unwanted hw_perf_enable_all
      x86: irqinit_32.c fix compilation warning
      x86: prepare perf_counter to add more cpus
      x86: AMD Support for perf_counter
      x86: decent declarations in perf_counter.c
      x86: use pr_info in perf_counter.c
      x86: perf_counter cleanup
      x86: apic/x2apic_cluster.c x86_cpu_to_logical_apicid should be stat=
ic
      x86: clean up declarations and variables
      x86: vdso/vma.c declare vdso_enabled and arch_setup_additional_page=
s before they get used
      x86: page_types.h unification of declarations
      x86: avoid multiple declaration of kstack_depth_to_print
      x86: k8 convert node_to_k8_nb_misc() from a macro to an inline func=
tion
      x86: cpufeature.h fix name for X86_FEATURE_MCE
      tracing: trace_output.c, fix false positive compiler warning
      x86: msr-index.h remove duplicate MSR C001_0015 declaration
      x86, mtrr: replace MTRRcap_MSR with msr-index's MSR_MTRRcap
      x86, mtrr: replace MTRRfix64K_00000_MSR with msr-index's MSR_MTRRfi=
x64K_00000
      x86, mtrr: replace MTRRfix16K_80000_MSR with msr-index's MSR_MTRRfi=
x16K_80000
      x86, mtrr: remove mtrr MSRs double declaration
      x86, mtrr: replace MTRRfix4K_C0000_MSR with msr-index's MSR_MTRRfix=
4K_C0000
      x86, mtrr: replace MTRRdefType_MSR with msr-index's MSR_MTRRdefType
      x86: asm/processor.h: remove double declaration
      x86: cpu_debug: Remove model information to reduce encoding-decodin=
g
      headers_check fix: m68k, swab.h
      powerpc, perf_counter: Fix performance counter event types
      PM/ACPI/x86: Fix sparse warning in arch/x86/kernel/acpi/sleep.c
      perf_counter, x86: Check old-AMD performance monitoring support
      perf_counter, x86: Update AMD hw caching related event table
      headers_check fix: mn10300, ptrace.h
      headers_check fix: mn10300, setup.h
      [IA64] msi_ia64.c dmar_msi_type should be static
      Documentation/accounting/getdelays.c intialize the variable before =
using it
      x86: apic/io_apic.c: dmar_msi_type should be static
      x86: msr.h linux/types.h is only required for __KERNEL__
      Documentation/connector/cn_test.c comment unused cn_test_want_notif=
y()
      scsi_transport_iscsi: return -EOVERFLOW for Too many iscsi targets

Jay Fenlason (1):
      firewire: add IPv4 support

Jean Delvare (41):
      sfc: Don't specify unexistent IRQ
      ALSA: keywest: Get rid of useless i2c_device_name() macro
      r8169: Use a different default for each family
      ALSA: Add missing __devexit_p() markers
      x86: Add quirk for reboot stalls on a Dell Optiplex 360
      trivial: fix ETIMEOUT -> ETIMEDOUT typos
      i2c: Do not probe for TV chips on Voodoo3 adapters
      i2c: Do not give adapters a default parent
      therm_pm72: Convert to a new-style i2c driver
      windfarm: Convert to new-style i2c drivers
      therm_adt746x: Convert to a new-style i2c driver
      therm_windtunnel: Convert to a new-style i2c driver
      hwmon: Fix more __devexit_p glitches
      hwmon: (w83627ehf) Add W83627DHG-P support
      hwmon: PCI quirk for hwmon access on MSI MS-7031 board
      V4L/DVB (11564): tda7432: Delete old driver history
      V4L/DVB (11723): Link firmware to physical device
      V4L/DVB (11737): Drop stray references to i2c_probe
      V4L/DVB (11748): pvrusb2: Don't use the internal i2c client list
      V4L/DVB (11843): ir-kbd-i2c: Don't use i2c_client.name for our own =
needs
      V4L/DVB (11844): ir-kbd-i2c: Switch to the new-style device binding=
 model
      V4L/DVB (11845): ir-kbd-i2c: Use initialization data
      V4L/DVB (11846): ir-kbd-i2c: Don't assume all IR receivers are supp=
orted
      V4L/DVB (11847): saa7134: Simplify handling of IR on MSI TV@nywhere=
 Plus
      V4L/DVB (11848): saa7134: Simplify handling of IR on AVerMedia Card=
bus E506R
      V4L/DVB (11849): ivtv: Probe more I2C addresses for IR devices
      V4L/DVB (11850): pvrusb2: Instantiate ir_video I2C device by defaul=
t
      V4L/DVB (11992): Add missing __devexit_p()
      i2c: Kill client_register and client_unregister methods
      i2c: Get rid of the legacy binding model
      i2c: Drop i2c_probe function
      i2c: Merge i2c_attach_client into i2c_new_device
      i2c: Kill is_newstyle_driver
      i2c: Kill the redundant client list
      i2c: Limit core locking to the necessary sections
      i2c: Add a sysfs interface to instantiate devices
      i2c: Don't advertise i2c functions when not available
      Staging: sxg: Add missing __devexit_p()
      Staging: rtl8187se: Use to_delayed_work
      Staging: altpciechdma: Add missing __devexit_p()
      Staging: slicoss: Add missing __devexit_p()

Jean-Christophe PLAGNIOL-VILLARD (1):
      sh: mach-r2d: add physmap-flash support for R2D+ boards.

Jean-Francois Moine (20):
      V4L/DVB (11446): gspca - t613: Do sensor reset only for sensor om68=
02.
      V4L/DVB (11449): gspca - zc3xx: Bad probe of many webcams since adc=
m2700 addition.
      V4L/DVB (11708): gspca - main: Version change.
      V4L/DVB (11709): gspca - zc3xx: Bad debug level in i2c_read
      V4L/DVB (11710): gspca - main: Webcams cannot do both isoc and bulk=
 image transfers.
      V4L/DVB (11711): gspca - main: Fix a crash when no bandwidth availa=
ble
      V4L/DVB (11712): gspca - main:  Set the current alternate setting o=
nly when needed
      V4L/DVB (11713): gspca - ov534: Don't discard the images when no UV=
C EOF
      V4L/DVB (11714): gspca - spca500 and sunplus: Change the 0x00 inser=
tion mechanism.
      V4L/DVB (11715): gspca - main: Set the number of packets per ISOC m=
essage.
      V4L/DVB (11716): gspca - sonixj: Adjust some exchanges according to=
 traces
      V4L/DVB (11717): gspca - sonixj: Webcams with bridge sn9c128 added
      V4L/DVB (11718): gspca - vc032x: Bad pixelformat for mi1320_soc
      V4L/DVB (11719): gspca - vc032x: mi1320_soc images are upside-down
      V4L/DVB (11867): gspca - spca508: Cleanup source and update copyrig=
ht.
      V4L/DVB (11868): gspca - spca508: Optimize code.
      V4L/DVB (11869): gspca - ov534: JPEG 320x240 and 640x480 formats fo=
r ov965x.
      V4L/DVB (11969): gspca - spca505: Reinitialize the webcam at resume=
 time.
      V4L/DVB (11971): gspca - doc: Add the 05a9:a518 webcam to the Docum=
entation.
      V4L/DVB (11973): gspca - ov534: Do the ov772x work again.

Jean-Mickael Guerin (1):
      sctp: fix sack_timeout sysctl min and max types

Jeff Garzik (3):
      [SCSI] mvsas: move into new directory drivers/scsi/mvsas/
      [SCSI] mvsas: split driver into multiple files
      [libata] ahci: use less error-prone array initializers

Jeff Hansen (3):
      ath9k: Reset SC_OP_TSF_RESET flag after stuck beacon
      ath9k: Combine legacy and 11n rc statistics
      ath9k: Add "debug" file to debugfs

Jeff Kirsher (1):
      igb: add RQDPC (Receive Queue Drop Packet Count) register macro

Jeff Layton (10):
      cifs: fix artificial limit on reading symlinks
      cifs: tighten up default file_mode/dir_mode
      cifs: have cifs_NTtimeToUnix take a little-endian arg
      cifs: make cnvrtDosUnixTm take a little-endian args and an offset
      cifs: rename cifs_iget to cifs_root_iget
      cifs: make serverino the default when mounting
      cifs: fix IPv6 address length check
      cifs: make overriding of ownership conditional on new mount options
      cifs: add addr=3D mount option alias for ip=3D
      cifs: remove never-used in6_addr option

Jeff Mahoney (2):
      reiserfs: allow exposing privroot w/ xattrs enabled
      reiserfs: fix warnings with gcc 4.4

Jeff Moyer (2):
      block: implement blkdev_readpages
      cfq: remove extraneous '\n' in blktrace output

Jens Axboe (16):
      block: make blk_do_io_stat() do the full "is this rq accountable" c=
hecks
      block: include discard requests in IO accounting
      splice: fix misleading comment
      splice: fix repeated kmap()'s in default_file_splice_read()
      virtio_blk: get rid of unused variable
      block: add warning to blk_make_request()
      block: change the tag sync vs async restriction logic
      Merge branch 'master' into for-2.6.31
      Merge branch 'master' into for-2.6.31
      Revert "block: implement blkdev_readpages"
      Revert "block: Fix bounce limit setting in DM"
      [libata] get rid of ATA_MAX_QUEUE loop in ata_qc_complete_multiple(=
) v2
      ntfs: remove old debug check for dirty data in ntfs_put_super()
      block: don't overwrite bdi->state after bdi_init() has been run
      btrfs: properly register fs backing device
      ubifs: register backing_dev_info

Jens Rottmann (1):
      parport_pc: after superio probing restore original register values

Jeremy Fitzhardinge (38):
      mm: disable preemption in apply_to_pte_range
      x86/paravirt: remove lazy mode in interrupts
      x86/pvops: replace arch_enter_lazy_cpu_mode with arch_start_context=
_switch
      x86/paravirt: flush pending mmu updates on context switch
      x86/paravirt: finish change from lazy cpu to context switch start/e=
nd
      x86/paravirt: allow preemption with lazy mmu mode
      mm: allow preemption in apply_to_pte_range
      x86/paravirt: use percpu_ rather than __get_cpu_var
      xen: disable preempt for leave_lazy_mmu
      xen: separate p2m allocation from setting
      xen: split construction of p2m mfn tables from registration
      xen: clean up xen_load_gdt
      xen: make xen_load_gdt simpler
      xen: remove xen_load_gdt debug
      xen: mask XSAVE from cpuid
      x86-64: remove PGE from must-have feature list
      x86-64: non-paravirt systems always has PSE and PGE
      xen/mmu: some early pagetable cleanups
      xen/mmu: weaken flush_tlb_other test
      xen: set _PAGE_NX in __supported_pte_mask before pagetable construc=
tion
      xen: clean up gate trap/interrupt constants
      xen/dev-evtchn: clean up locking in evtchn
      xen/xenbus: export xenbus_dev_changed
      xen: add /sys/hypervisor support
      xen/sys/hypervisor: change writable_pt to features
      xen: add "capabilities" file
      Merge branches 'for-linus/xen/dev-evtchn', 'for-linus/xen/xenbus', =
'for-linus/xen/xenfs' and 'for-linus/xen/sys-hypervisor' into for-linus/x=
en/master
      Merge branch 'for-linus/xen/core' into for-linus/xen/master
      Merge commit 'origin/master' into for-linus/xen/master
      lguest: update lazy mmu changes to match lguest's use of kvm hyperc=
alls
      xen: add FIX_TEXT_POKE to fixmap
      tracing: avoid warnings from zero-arg tracepoints
      xen: reserve Xen start_info rather than e820 reserving
      xen/x86-64: fix breakpoints and hardware watchpoints
      xen/x86-64: clean up warnings about IST-using traps
      xen: cache cr0 value to avoid trap'n'emulate for read_cr0
      x86: make _PAGE_HIDDEN conditional
      x86: unify pte_hidden

Jeremy Huddleston (1):
      Input: appletouch - improve finger detection

Jerome Glisse (5):
      drm: Split out the mm declarations in a separate header. Add atomic=
 operations.
      drm: Export hash table functionality.
      drm: include kernel list header file in hashtab header
      drm/radeon: introduce kernel modesetting for radeon hardware
      drm/radeon: command stream checker for r3xx-r5xx hardware

Jerry Chuang (1):
      Staging: add rtl8192SU wireless usb driver

Jes Sorensen (10):
      KVM: ia64: Map in SN2 RTC registers to the VMM module
      KVM: ia64: Create inline function kvm_get_itc() to centralize ITC r=
eading.
      KVM: ia64: SN2 adjust emulated ITC frequency to match RTC frequency
      KVM: ia64: Drop in SN2 replacement of fast path ITC emulation fault=
 handler
      KVM: ia64: Don't hold slots_lock in guest mode
      KVM: ia64: remove empty function vti_vcpu_load()
      KVM: ia64: restore irq state before calling kvm_vcpu_init
      KVM: ia64: preserve int status through call to kvm_insert_vmm_mappi=
ng
      KVM: ia64: ia64 vcpu_reset() do not call kmalloc() with irqs disabl=
ed
      [IA64] Fix build error in paravirt_patchlist.c

Jesper Dangaard Brouer (7):
      igb: Implement reading of reg RQDPC (Receive Queue Drop Packet Coun=
t)
      igb: Record host memory receive overflow in net_stats
      8021q: Vlan driver should use rcu_barrier() on unload instead of sy=
ncronize_net()
      nfnetlink_queue: Use rcu_barrier() on module unload.
      can: af_can.c use rcu_barrier() on module unload.
      sctp: protocol.c call rcu_barrier() on unload.
      sunrpc/auth_gss: Call rcu_barrier() on module unload.

Jesper Nilsson (4):
      CRISv32: Add arch optimized strcmp.
      CRISv32: Fix potential null reference in cryptocop driver.
      CRISv32: irq.c - Move end brace outside #endif
      MAINTAINERS: Change mailing list info for CRIS

Jesse Barnes (4):
      drm/i915: apply G45 vblank count code to all G4x chips and fix max_=
frame_count
      drm/i915: avoid non-atomic sysrq execution
      drm/i915: enable MCHBAR if needed
      PCI: use ACPI _CRS data by default

Jesse Brandeburg (12):
      ixgbe: fix link down initial state
      ixgb: fix link down initial state
      igb: fix link down inital state
      e1000e: indicate link down at load
      e1000: init link state correctly
      e1000/e1000e/igb/ixgb: do not use netif_wake_queue un-necessarily
      sctp: add feature bit for SCTP offload in hardware
      igb: Enable SCTP checksum offloading
      ixgbe: enable hardware offload for sctp
      e1000/e1000e/igb/ixgb: don't txhang after link down
      ixgbe: Cleanup feature setup code to make the code more readable
      ixgbe: Re-adjust ring layouts to have better cacheline efficiency

Jianjun Kong (1):
      rtl8139: unify the struct's name

Jie Yang (1):
      atl1c: disable L1/L0s when link detected

Jie Zhang (2):
      Blackfin: rename bfin_addr_dcachable to bfin_addr_dcacheable
      Blackfin: decouple unrelated cache settings to get exact behavior

Jim Paris (1):
      ps3vram: Correct exchanged gotos in ps3vram_probe() error path

Jiri Kosina (5):
      HID: fix hid-ff drivers so that devices work even without ff suppor=
t
      HID: hidraw -- fix comment about accepted devices
      HID: no more reinitializtion is needed in post_reset
      HID: fix inverted wheel for bluetooth version of apple mighty mouse
      Merge branches 'upstream' and 'ntrig-multitouch' into for-linus

Jiri Pirko (17):
      rculist.h: introduce list_entry_rcu() and list_first_entry_rcu()
      rculist: use list_entry_rcu in places where it's appropriate
      bonding: use ethtool for link checking first
      bonding: ignore updelay param when there is no active slave
      ne2k-pci: use dev->addr_len instead of "6"
      net: introduce a list of device addresses dev_addr_list (v6)
      bonding: get rid of CONFIG_PROC_FS ifdefs
      net: check retval of dev_addr_init()
      net: remove needless (now buggy) & from dev->dev_addr
      net: remove needless (now buggy) & from dev->dev_addr (part2)
      bridge: avoid an extra space in br_fdb_update()
      net: correct a comment for the final #endif
      bonding: allow bond in mode balance-alb to work properly in bridge =
-try4.3
      bonding: use bond_is_lb() when it's appropriate
      net: convert unicast addr list
      net: group address list and its count
      spi: fix spi_write_then_read() comment

Jiri Slaby (39):
      x86_32: introduce restore_fpu_checking()
      x86: unify restore_fpu_checking
      x86_64: fix incorrect comments
      ath5k: 5211, don't crypt every protected frame
      ath5k: Enable AP mode
      x86, apic: Restore irqs on fail paths
      amd_iommu: fix lock imbalance
      kbuild: allow docproc invocation from external
      tty:cyclades, load firmware even on Ze
      tty: cyclades, don't kill FW
      tty: cyclades, remove spurious check in ISR
      tty: cyclades, plx9060 casts cleanup
      tty: cyclades, cache HW version
      tty: cyclades, convert macros to inlines
      tty: cyclades, remove typedefs
      tty: cyclades, fix nports handling
      tty: cyclades, remove unused variables
      serial: refactor ASYNC_ flags
      rocket: fix test_bit parameters
      epca: fix test_bit parameters
      tty: remove sleep_on
      tty: use prepare/finish_wait
      Char: isicom: fix build warning
      ath5k: fix beacon_int handling
      staging: comedi, remove interrupt.h
      staging: agnx, probe cleanup
      staging: agnx, remove memlens from probe
      staging: agnx, fix fail paths in probe
      staging: agnx, fix bssid compiler warnings
      staging: meilhaus, switch to misc device
      staging: meilhaus, annotate cpi functions
      staging: meilhaus, move tables to .c
      dma-mapping: mark DMA_nBITS_MASK as deprecated
      Net: qla3xxx, remove sleeping in atomic
      fusion: mptsas, fix lock imbalance
      n_r3964: fix lock imbalance
      pcmcia/cm4000: fix lock imbalance
      vt_ioctl: fix lock imbalance
      tty: fix tty_port_block_til_ready waiting

Joachim Fenkes (1):
      IB/ehca: Remove superfluous bitmasks from QP control block

Joakim Tjernlund (2):
      ucc_geth: Move freeing of TX packets to NAPI context
      rtc: rtc-ds1307 add ds1388

Joao Ramos (2):
      ide: try to use PIO Mode 0 during probe if possible
      ide: do not access ide_drive_t 'drive_data' field directly

Joe Carnuccio (1):
      [SCSI] qla2xxx: Perform an implicit login to the Management Server.

Joe Eykholt (3):
      [SCSI] libfcoe: fip: fix non-FIP-mode FLOGI state after reset.
      [SCSI] net, libfcoe: Add the FCoE Initialization Protocol ethertype
      fix race that can give duplicate host number

Joe Perches (33):
      drivers/net: Convert #ifdef DEBUG printk(KERN_DEBUG to pr_debug(
      atl1c_main.c: add wait_for_idle routine
      arch/m68knommu: Convert #ifdef DEBUG printk(KERN_DEBUG to pr_debug(
      x_tables: Convert printk to pr_err
      MAINTAINERS: update 8250 section, give Alan Cox a name
      scripts/get_maintainer.pl: output first field only in mailing lists=
 and after maintainers.
      scripts/get_maintainer.pl: better fix for subscriber-only mailing l=
ists
      scripts/get_maintainer.pl: improve --git-chief-penquins (Linus Torv=
alds) filtering
      scripts/get_maintainer.pl: warn on missing git or git repository
      scripts/get_maintainer.pl: support M: lines with names and multiple=
 entries per M: line
      scripts/get_maintainer.pl: better email name quoting
      scripts/get_maintainer.pl: support both "P:/M:" and integrated "M:"=
 lines
      scripts/get_maintainer.pl: don't print maintainers when not request=
ed
      scripts/get_maintainer.pl: allow 8 bit characters in email addresse=
s
      scripts/get_maintainer.pl: change "die" to "warn" when command line=
 file is not a patch
      MAINTAINERS: swap mismarked ECRYPT FS M: and P: entries
      MAINTAINERS: add file patterns to "THE REST"
      MAINTAINERS: update M32R file patterns after rename
      MAINTAINERS: mark ALSA lists as moderated
      MAINTAINERS: remove L: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org from all but "T=
HE REST"
      MAINTAINERS: mention scripts/get_maintainer.pl in the preface
      MAINTAINERS: add file pattern to CISCO FCOE HBA DRIVER
      MAINTAINERS: add Paul McKenney to RCU and RCUTORTURE
      MAINTAINERS: add file patterns to TTY LAYER
      MAINTAINERS: Fix Atheros pattern paths
      bootmem.c: avoid c90 declaration warning
      MAINTAINERS: pair names/addresses in EDAC-I82975X
      MAINTAINERS: fix Atheros pattern paths
      MAINTAINERS: update Ftrace documentation pattern
      MAINTAINERS: update wireless.h path
      MAINTAINERS: ieee802154 fix pattern typo
      MAINTAINERS: kmemtrace pattern update
      kmemleak: use pr_fmt

Joel Becker (2):
      ocfs2: Add statistics for the checksum and ecc operations.
      ocfs2: Provide the ocfs2_dlm_lvb_valid() stack API.

Joerg Roedel (53):
      dma-debug: re-add dma memory leak detection
      amd-iommu: add amd_iommu_dump parameter
      amd-iommu: add dump for iommus described in ivrs table
      amd-iommu: print ivhd information to dmesg when requested
      amd-iommu: print ivmd information to dmesg when requested
      amd-iommu: move protection domain printk to dump code
      x86/iommu: add IOMMU_STRESS Kconfig entry
      amd-iommu: disable device isolation with CONFIG_IOMMU_STRESS
      amd-iommu: make sure only ivmd entries are parsed
      amd-iommu: introduce for_each_iommu* macros
      amd-iommu: consolidate hardware initialization to one function
      amd-iommu: drop pointless iommu-loop in msi setup code
      amd-iommu: remove support for msi-x
      amd-iommu: add function to disable all iommus
      amd-iommu: add function to flush tlb for all domains
      amd-iommu: add function to flush tlb for all devices
      amd_iommu: un __init functions required for suspend/resume
      amd-iommu: implement suspend/resume
      amd-iommu: introduce aperture_range structure
      amd-iommu: move page table allocation code to seperate function
      amd-iommu: handle page table allocation failures in dma_ops code
      amd-iommu: make address allocator aware of multiple aperture ranges
      amd-iommu: change dma_dom->next_bit to dma_dom->next_address
      amd-iommu: move aperture_range allocation code to seperate function
      amd-iommu: handle exlusion ranges and unity mappings in alloc_new_r=
ange
      amd-iommu: enlarge the aperture dynamically
      amd-iommu: remove amd_iommu_size kernel parameter
      amd-iommu: disable round-robin allocator for CONFIG_IOMMU_STRESS
      amd-iommu: don't preallocate page tables with CONFIG_IOMMU_STRESS
      amd-iommu: don't free dma adresses below 512MB with CONFIG_IOMMU_ST=
RESS
      Merge branches 'amd-iommu/fixes', 'amd-iommu/debug', 'amd-iommu/sus=
pend-resume' and 'amd-iommu/extended-allocator' into amd-iommu/2.6.31
      dma-debug: add variables and checks for driver filter
      dma-debug: add debugfs file for driver filter
      dma-debug: add dma_debug_driver kernel command line
      dma-debug: add documentation for the driver filter
      Merge branches 'dma-debug/fixes' and 'dma-debug/driver-filter' into=
 dma-debug/2.6.31
      dma-debug: change hash_bucket_find from first-fit to best-fit
      dma-debug: comment style fixes
      dma-debug: code style fixes
      dma-debug: use pr_* instead of printk(KERN_* ...)
      dma-debug: disable/enable irqs only once in device_dma_allocations
      dma-debug: simplify logic in driver_filter()
      Merge commit 'tip/core/iommu' into amd-iommu/fixes
      amd-iommu: remove BUS_NOTIFY_BOUND_DRIVER handling
      amd-iommu: detach device explicitly before attaching it to a new do=
main
      amd-iommu: remove unnecessary "AMD IOMMU: " prefix
      KVM: MMU: remove call to kvm_mmu_pte_write from walk_addr
      dma-debug: check for sg_call_ents in best-fit algorithm too
      dma-debug: be more careful when building reference entries
      amd-iommu: disable IOMMU hardware on shutdown
      x86: disable IOMMUs on kernel crash
      amd-iommu: set event buffer head and tail to 0 manually
      driver core: add BUS_NOTIFY_UNBOUND_DRIVER event

Johann Baudy (1):
      net: TX_RING and packet mmap

Johannes Berg (122):
      nl80211: validate some input better
      rfkill: remove deprecated state constants
      rfkill: remove user_claim stuff
      rfkill-input: remove unused code
      mac80211: move ieee80211_enable_ht function to mlme.c
      cfg80211: introduce scan IE limit attribute
      mac80211: pass all probe request IEs to driver
      mac80211: include HT capabilities in probe request
      cfg80211: add cipher capabilities
      mac80211: re-upload keys only after telling driver about associatio=
n
      mac80211: update injection documentation
      cfg80211: convert mutex assert to macro
      mac80211: add hardware restart function
      mac80211: improve powersave implementation
      mac80211: disable powersave if pm_qos asks for low latency
      mac80211: implement beacon filtering in software
      mac80211: enable PS by default
      mac80211: document powersaving/beacon filter future
      nl80211: send wiphy along with netdev
      cfg80211/mac80211: move wext SIWMLME into cfg80211
      cfg80211/nl80211: add IBSS API
      mac80211: convert to cfg80211 IBSS API
      cfg80211: clean up includes
      rndis_wlan: remove nickname support
      ar9170: support HT receive and channel config
      cfg80211: clear WEXT SSID when clearing IBSS
      cfg80211: mark all WEXT handlers _GPL
      mac80211: validate TIM IE length (redux)
      iwlwifi: rename PROBE_OPTION_MAX_API1 to PROBE_OPTION_MAX_3945
      iwlwifi: improve scan support
      iwlwifi: support truly passive scanning
      mac80211: fix IBSS code to not sleep while atomic
      rndis_wlan: make some symbols static
      mac80211: fix variable truncation on 32-bit
      mac80211: remove IEEE80211_CONF_CHANGE_DYNPS_TIMEOUT
      nl80211: allow configuring IBSS beacon interval
      mac80211: calculate maximum sleep interval
      mac80211: fix various problems in ibss code
      mac80211: fix PS vs. scan race
      mac80211: rename max_sleep_interval to max_sleep_period
      mac80211: internally clear failed scans properly
      mac80211: fix scan races and rework scanning
      mac80211: clean up beacon interval settings
      mac80211: unify config_interface and bss_info_changed
      mac80211: add driver ops wrappers
      mac80211_hwsim: fix bogus warning
      mac80211: fix probe response processing
      mac80211: tell driver when idle
      mac80211: report operating frequency rather than current
      mac80211: fix scan channel race
      mac80211: set default QoS values according to spec
      cfg80211: fix wext iw_freq parsing
      iwlwifi: make iwl_set_rate static
      mac80211: improve scan timing
      mac80211: move HT operation mode BSS info
      mac80211: properly track HT operation_mode
      mac80211: remove ieee80211_ht_bss_info
      iwlwifi: do proper hw restart
      iwlwifi: fix PS disable status race
      iwlwifi: clean up PS code
      cfg80211: constify key mac address in ops
      cfg80211: put wext data into substructure
      cfg80211: disallow interfering with stations on non-AP
      wext: fix get_wireless_stats locking
      cfg80211: implement wext key handling
      nl80211: improve station flags handling
      wext: remove seq_start/stop sparse annotations
      mac80211: respond to beacon loss report only once
      mac80211: split out and decrease probe wait time
      mac80211: don't connect to IBSS network with different privacy
      mac80211: IBSS supported rate fixes
      mac80211: make noack test available
      mac80211: move channel switch code
      mac80211: cancel/restart all timers across suspend/resume
      b43/legacy: fix beacon change processing
      cfg80211: allow wext to remove keys that don't exist
      mac80211: fix kernel-doc
      mac80211: don't try to do anything on unchanged genIE
      mac80211: fix parameter confusion when finding IBSS
      mac80211: fix managed mode BSSID handling
      wext: remove atomic requirement for wireless stats
      mac80211: fix probe response wait timing
      mac80211: correct probe wait time
      mac80211: deprecate conf.beacon_int properly
      cfg80211: validate AID of stations being added
      nl80211: bounce scan request back to userspace
      cfg80211: use key size constants
      mac80211: fix transposed min/max CW values
      cfg80211: disallow interfering with stations on non-AP (part 2)
      net: introduce pre-up netdev notifier
      mac80211_hwsim: remove deprecated radio_enabled
      rfkill: rewrite
      rfkill: create useful userspace interface
      cfg80211: move txpower wext from mac80211
      rfkill: add function to query state
      cfg80211: add rfkill support
      iwm: port to new cfg80211 rfkill
      rfkill: always init poll delayed work
      rfkill: document /dev/rfkill
      cfg80211: fix Kconfig for users of cfg80211
      wimax: depend on rfkill properly
      rfkill: include err.h
      iwlwifi: port to cfg80211 rfkill
      ar9170: interpret firmware debug commands
      rfkill: print events when input handler is disabled/enabled
      b43/legacy: port to cfg80211 rfkill
      rfkill: remove input Kconfig
      sony: fix rfkill code
      mac80211: do not pass PS frames out of mac80211 again
      mac80211: don't use master netdev name
      mac80211: clean up return value of __ieee80211_parse_tx_radiotap
      mac80211: disable PS while probing AP
      cfg80211: fix rfkill locking problem
      sony: fix rfkill code again
      iwlwifi: revamp bss_info_changed
      ath9k: port to cfg80211 rfkill
      mac80211: add queue debugfs file
      mac80211: disconnect when user changes channel
      rfkill: improve docs
      dell-laptop: fix rfkill conversion
      mac80211: fix wext bssid/ssid setting
      cfg80211: validate station settings

Johannes Klug (1):
      V4L/DVB (11645): gspca - m5602-ov9650: Add image flip quirk for the=
 ASUS A6VA

Johannes Weiner (7):
      wait: don't use __wake_up_common()
      crypto: api - Use kzfree
      mm: introduce follow_pte()
      mm: use generic follow_pte() in follow_phys()
      mm: introduce follow_pfn()
      mm: page_alloc: clear PG_locked before checking flags on free
      ipc: unbreak 32-bit shmctl/semctl/msgctl

John Dykstra (5):
      pcnet32: Remove redundant set of skb->dev
      pcnet32: Remove pointless memory barriers
      Network Drop Monitor: Fix skb_kill_datagram
      tcp: tcp_prequeue() can use keyed wakeups
      net core: Some interface flags not returned by SIOCGIFFLAGS

John Linn (1):
      fbdev: Add PLB support and cleanup DCR in xilinxfb driver.

John Stoffel (1):
      sym53c8xx: ratelimit parity errors

John W. Linville (9):
      rndis_wlan: initiate cfg80211 conversion
      rndis_wlan: convert get/set mode to cfg80211
      libertas: fix warning about %zd:
      rndis_wlan: select CFG80211 in Kconfig
      libertas: fix format warning
      wireless: remove some (bogus?) 'may be used uninitialized' warnings
      p54: correct merge damage from "p54: more SoftLED updates"
      ath5k: avoid leaking mutex in ath5k_config
      firmware: wireless/libertas: prepare for FIRMWARE_NAME_MAX removal

John Williams (1):
      microblaze: Don't use access_ok for unaligned

Jon Hunter (1):
      timers: allow deferrable timers for intervals tv2-tv5 to be deferre=
d

Jon Smirl (10):
      ASoC: Add SNDRV_PCM_FMTBIT_S32_BE as a valid AC97 format
      ASoC: Codec for STAC9766 used on the Efika
      ASoC: Basic split of mpc5200 DMA code out of mpc5200_psc_i2s
      ASoC: Rename the PSC functions to DMA
      ASoC: Add a few more mpc5200 PSC defines
      ASoC: Main rewite of the mpc5200 audio DMA code
      ASoC: AC97 driver for mpc5200
      ASoC: Support for AC97 on Phytec pmc030 base board.
      ASoC: Fabric bindings for STAC9766 on the Efika
      ASoC: Modify mpc5200 AC97 driver to use V9 of spin_event_timeout()

Jonas Larsson (2):
      atmel-mci: Add support for inverted detect pin
      avr32: Solves problem with inverted MCI detect pin on Merisc board

Jonas Sj=C3=B6quist (1):
      cdc_ether: additional PID's to the whitelist

Jonathan Brassow (1):
      dm exception store: fix exstore lookup to be case insensitive

Jonathan Cameron (7):
      ASoC WM8940 Driver
      ASoC: IMote2 ASoC Support
      [ARM] pxa: Stargate 2 board support
      [ARM] pxa/stargate2: Add board specific elements to the smc91x driv=
er
      [ARM] pxa/stargate2: add support for Compact Flash/PCMCIA
      [ARM] pxa/imote2: add board config for SHT15 humidity sensor
      [ARM] pxa/imote2: add i2c board info for the wm8940 audio codec

Jonathan Corbet (4):
      Document Reported-by in SubmittingPatches
      docs: Encourage better changelogs in the development process docume=
nt
      Document the debugfs API
      debugfs: fix docbook error

Jonthan Brassow (2):
      dm table: improve warning message when devices not freed before des=
truction
      dm raid1: add userspace log

Joonyoung Shim (5):
      ASoC: TWL4030: Add support Voice DAI
      ASoC: OMAP: Add checking to detect bufferless pcms
      ASoC: TWL4030: Add VDL path support
      ASoC: TWL4030: change DAPM for analog microphone selection
      [ARM] Add old Feroceon support to compressed/head.S

Jorg Schummer (1):
      mmc: mmc_rescan detects card change in one run

Jose Luis Perez Diez (1):
      Documentation/Changes: perl is needed to build the kernel

Joseba Goitia Gandiaga (1):
      V4L/DVB (11488): get_dvb_firmware: trivial url change

Josh Boyer (3):
      powerpc/4xx: Disable PCI_LEGACY
      powerpc/40x: Convert AMCC Makalu board to ppc40x_simple
      powerpc/40x: Convert AMCC Kilauea/Halekala boards to ppc40x_simple

Josua Dietze (1):
      USB: usb-storage: add filter to "option_ms" to leave unrecognized d=
evices alone

Jouni Hogander (2):
      OMAP: Add new function to check wether there is irq pending
      OMAP: UART: Add sysfs interface for adjusting UART sleep timeout

Jouni Malinen (37):
      nl80211: Require auth type for NL80211_CMD_AUTHENTICATE
      nl80211: Generate deauth/disassoc event for locally generated frame=
s
      nl80211: Add Michael MIC failure event
      mac80211: Report rejected association to user space SME
      mac80211: Allow scan to be requested in AP mode
      nl80211: Add set/get for frag/rts threshold and retry limits
      nl80211: Add event for authentication/association timeout
      nl80211: Send timeout event on failed direct probe
      mac80211: Use a shared function to release frames from RX reorder b=
uf
      mac80211: Add a timeout for frames in the RX reorder buffer
      mac80211: Comment the order of HT RX reorder handler vs. RX handler=
s
      mac80211: Update SA Query transaction id length
      nl80211 : Add support for configuring MFP
      mac80211: Drop unencrypted frames based on key setup
      mac80211: MFP - Drop unprotected Action frames prior key setup
      mac80211: Robust Action frame categories for MFP
      nl80211: Validate MFP flag type when parsing STA flags
      nl80211: Add IEEE 802.1X PAE control for station mode
      nl80211: Add RSC configuration for new keys
      mac80211: Cancel pending probereq poll on beacon RX
      ath9k: Fix a check for multicast address for virtual wiphy
      ath9k: Clean up RX processing a bit
      ath9k: Fix PS mode operation to receive buffered broadcast/multicas=
t frames
      nl80211: Validate NL80211_ATTR_KEY_SEQ length
      ath9k: Wake up for TX in mac80211 timeout=3D0 sleep mode
      ath9k: Do not try to calibrate radio when in sleep mode
      ath9k: Use TSFOOR interrupt to trigger TSF sync with next Beacon
      ath9k: Wake up for RX filter changes
      ath9k: Set PM field in frame control when in PS mode
      mac80211: PS processing for every Beacon with our AID in TIM
      mac80211: Do not override AID in the duration field
      ath9k: Optimize TBTT/DTIM calculation for timers
      ath9k: Update Beacon timers based on timestamp from the AP
      ath9k: Add sanity check for beacon_int in adhoc/mesh case
      mac80211: Do not try to associate with an empty SSID
      ath9k: Fix PCI FATAL interrupts by restoring RETRY_TIMEOUT disablin=
g
      ath5k: avoid PCI FATAL interrupts by restoring RETRY_TIMEOUT disabl=
ing

Jozsef Kadlecsik (1):
      netfilter: nf_ct_tcp: TCP simultaneous open support

Juha Yrjola (1):
      ARM: OMAP2/3: Add generic onenand support when connected to GPMC

Julia Lawall (5):
      sound: use dev_set_drvdata
      drivers/net: use dev_get_drvdata
      Staging: wlan-ng: p80211wext.c: problem with IW_ENCODE_ALG_WEP
      Staging: cpc-usb: Adjust NULL test
      Staging: rtl8192su: Correct use of ! and &

Julian Calaby (1):
      mb862xxfb: restrict compliation of platform driver to PPC

Jussi Kivilinna (14):
      cfg80211: add cfg80211_inform_bss
      rndis_wlan: change quality level scale
      rndis_wlan: convert get range to cfg80211
      rndis_wlan: convert scan to cfg80211
      rndis_wlan: fix initialization order for workqueue&workers
      rndis_wlan: free priv correctly when rndis_wext_bind fails
      HID: force feedback support for SmartJoy PLUS PS2/USB adapter
      rndis_wlan: fix support for bcm4320a
      rndis_wlan: remove CAP_SUPPORT_TXPOWER/OID_802_11_TX_POWER_LEVEL co=
de
      rndis_wlan: explain bits used in key setup code.
      rndis_wlan: split add_wpa_key from rndis_iw_set_encode_ext
      rndis_wlan: do not try to restore wpa keys using add_wep_key()
      rndis_wlan: cleanup: capitalize enum labels
      rndis_wlan: cleanup: rename all rndis_wext* objects to rndis_wlan*

Justin Chen (1):
      FRV: bitops: Change the bitmap index from int to unsigned long

J=C3=BCrgen Schindele (1):
      [ARM] pxa: add additional mfp definitions for pxa320

KAMEZAWA Hiroyuki (9):
      memcg: fix page_cgroup fatal error in FLATMEM
      mm: add swap cache interface for swap reference
      mm: modify swap_map and add SWAP_HAS_CACHE flag
      mm: reuse unused swap entry if necessary
      mm: fix lumpy reclaim lru handling at isolate_lru_pages
      memcg: fix swap accounting
      memcg: fix behavior under memory.limit equals to memsw.limit
      memcg: fix lru rotation in isolate_pages
      mm: fix incorrect page removal from LRU

KOSAKI Motohiro (3):
      vmscan: low order lumpy reclaim also should use PAGEOUT_IO_SYNC
      page allocator: move free_page_mlock() to page_alloc.c
      mm: remove CONFIG_UNEVICTABLE_LRU config option

Kacper Szczesniak (2):
      ALSA: hda - Add support for MacBook 5.1 (Aluminium)
      ALSA: hda - Macbook[Pro] 5 6ch support

Kai Makisara (1):
      [SCSI] st: fix gcc 4.4 warning

KaiGai Kohei (1):
      Permissive domain in userspace object manager

Kalle Valo (1):
      wl12xx: add driver

Karen Xie (2):
      cxgb3i: use kref to track ddp usage
      cxgb3i: suppot of different kernel page sizes

Karl Beldan (5):
      ASoC: pxa2xx-i2s: Proper initialization
      ASoC: pxa2xx-i2s: Proper hw initialization
      ASoC: pxa2xx-i2s: Handle SACR1_DRPL and SACR1_DREC separately
      ASoC: pxa2xx-i2s: Fix inappropriate release of i2s clock
      ASoC: pxa2xx-i2s: Fix suspend/resume

Karl Relton (2):
      Staging: wlan-ng: Move firmware loading into driver
      Staging: wlan-ng: Change KERN_DEBUG or pr_debug to match orig drive=
r

Karsten Keil (7):
      mISDN: Fix skb leak in error cases
      mISDN: Add XHFC support for embedded Speech-Design board to hfcmult=
i
      mISDN: Cleanup debug messages
      ISDN:Fix DMA alloc for hfcpci
      mISDN: Fix overlapping data access
      mISDN: Do not disable IRQ in ph_data_ind()
      mISDN: cleanup mISDNhw.h

Kashyap, Desai (16):
      [SCSI] mpt fusion: Fixing 1078 data corruption issue for 36GB memor=
y region
      [SCSI] mpt fusion: Added support for MPT discovery completion check
      [SCSI] mpt fusion: Optimized SendEvent notification Using Doorbell =
instead FIFO
      [SCSI] mpt fusion: config path optimized, completion queue is used
      [SCSI] mpt fusion: rewrite of all internal generated functions
      [SCSI] mpt fusion: rewrite taskmgmt request and completion routines
      [SCSI] mpt fusion: Adding DeviceResetCtx for internal Device reset =
frame
      [SCSI] mpt fusion: rewrite of ioctl_cmds internal generated functio=
n
      [SCSI] mpt fusion: Firmware event implementation using seperate Wor=
kQueue
      [SCSI] mpt fusion: SAS topology scan changes, expander events
      [SCSI] mpt fusion: Rescan SAS topology added
      [SCSI] mpt fusion: Code Cleanup patch
      [SCSI] mpt fusion: Put IOC into ready state if it not already in re=
ady state
      [SCSI] mpt fusion: RAID device handling and Dual port Raid support =
is added
      [SCSI] mpt fusion: Queue full event handling
      [SCSI] mpt fusion: Added support for Broadcast primitives Event han=
dling

Kay Sievers (17):
      ALSA: use card device as parent for jack input-devices
      driver core: set default SYSFS_DEPRECATED=3Dn
      sched: delayed cleanup of user_struct
      Driver Core: add nodename callbacks
      Driver Core: misc: add nodename support for misc devices.
      Driver Core: usb: add nodename support for usb drivers.
      Driver Core: block: add nodename support for block drivers.
      Driver Core: x86: add nodename for cpuid and msr drivers.
      Driver Core: dvb: add nodename for dvb drivers
      Driver Core: input: add nodename for input drivers
      Driver Core: sound: add nodename for sound drivers
      Driver Core: raw: add nodename for raw devices
      Driver Core: drm: add nodename for drm devices
      Driver Core: aoe: add nodename for aoe devices
      Driver Core: bsg: add nodename for bsg driver
      usb: convert endpoint devices to bus-less childs of the usb interfa=
ce
      V4L/DVB (11517): v4l: remove driver-core BUS_ID_SIZE

Kees Cook (1):
      modules: sysctl to block module loading

Keika Kobayashi (2):
      softirq: introduce statistics for softirq
      proc: export statistics for softirq to /proc

Keith Packard (4):
      drm/i915: Don't trim cursor addresses to 11 bits
      drm/i915: Add Display Port register defines
      drm/i915: Hook connector to encoder during load detection (fixes tv=
/vga detect)
      drm: Eliminate magic I2C frobbing when reading EDID

Ken Kawasaki (1):
      3c589_cs: add cis(firmware) of 3Com multifunction pcmcia card

Kenji Kaneshige (25):
      PCI: use pci_is_root_bus() in acpi_pci_get_bridge_handle()
      PCI: use pci_is_root_bus() in acpi_find_root_bridge_handle()
      PCI: use pci_is_root_bus() in pci_find_upstream_pcie_bridge()
      PCI: use pci_is_root_bus() in pci_read_bridge_bases()
      PCI: use pci_is_root_bus() in pci_get_interrupt_pin()
      PCI: use pci_is_root_bus() in pci_common_swizzle()
      PCI: Remove untested Electromechanical Interlock (EMI) support in p=
ciehp.
      PCI hotplug: fix return value of has_foo() functions
      PCI hotplug: create symlink to hotplug driver module
      PCI hotplug: remove redundant .owner initializations
      PCI: remove invalid comment of msi_mask_irq()
      PCI ASPM: fix typo in struct pcie_link_state
      PCI ASPM: cleanup aspm state field in struct pcie_link_state
      PCI ASPM: cleanup latency field in struct pcie_link_state
      PCI ASPM: cleanup clkpm state in struct pcie_link_state
      PCI ASPM: cleanup misc in struct pcie_link_state
      PCI ASPM: cleanup change input argument of aspm functions
      PCI ASPM: cleanup initialization
      PCI ASPM: cleanup __pcie_aspm_check_state_one
      PCI ASPM: cleanup clkpm checks
      PCI ASPM: cleanup pcie_aspm_get_cap_device
      PCI ASPM: cleanup calc_Lx_latency
      PCI ASPM: remove has_switch field
      PCI ASPM: cleanup pcie_aspm_sanity_check
      PCI ASPM: remove get_root_port_link

Kevin Cernekee (9):
      Documentation: add MTD sysfs docs
      mtd: add MEMERASE64 ioctl for >4GiB devices
      mtd: compat_ioctl cleanup
      mtd: add OOB ioctls for >4GiB devices
      mtd: Handle compat ioctls directly; remove all trace from compat_io=
ctl.c
      UBI: add reboot notifier
      MIPS: Add size and direction arguments to plat_unmap_dma_mem()
      MIPS: Pass struct device to plat_dma_addr_to_phys()
      MIPS: Support 64-byte D-cache line size

Kevin Hao (2):
      net/ucc_geth: allow to set mac address on running device
      powerpc/85xx: Add nor flash partitions for mpc8569mds

Kevin Hilman (22):
      davinci: fixups for banked GPIO interrupt handling
      davinci: add platform support for watchdog timer
      davinci: DM355: add base SoC and board support
      davinci: DM646x: add base SoC and board support
      davinci: update davinci_all_defconfig for dm355, dm6467
      davinci: MMC platform support
      davinci: EMAC platform support
      Revert "ARM: OMAP: Mask interrupts when disabling interrupts, v2"
      OMAP2/3: PM: push core PM code from linux-omap
      OMAP3: PM: Force IVA2 into idle during bootup
      OMAP3: PM: Add wake-up bit defintiions for CONTROL_PADCONF_X
      OMAP3: PM: UART: disable clocks when idle and off-mode support
      OMAP3: PM: Add D2D clocks and auto-idle setup to PRCM init
      OMAP3: PM: D2D clockdomain supports SW supervised transitions
      OMAP3: PM: Ensure PRCM interrupts are cleared at boot
      OMAP3: PM: Clear pending PRCM reset flags on init
      OMAP3: PM: prevent module wakeups from waking IVA2
      OMAP1: PM: update and decouple from OMAP2/3 PM core
      davinci: cleanup: move dm355 UART2 define to dm355.c
      davinci: defconfig update: add EMAC
      [ARM] 5529/1: davinci: MMC platform support: DMA_32BIT_MASK --> DMA=
_BIT_MASK(32)
      serial@ add OMAP wakeup-enable register

Kevin Huang (1):
      Staging: add pata_rdc driver

Kieran Bingham (2):
      sh: Add in some ptrace definitions from GDB.
      sh: Fix UBC setup and registers for SH2A

Kim Phillips (3):
      crypto: talitos - Whitespace/codingstyle/overrun lines cleanup
      crypto: talitos - containerof related codingstyle
      crypto: talitos - Avoid unnecessary decrypt check

Kir Kolyshkin (1):
      USB: cdc-acm: quirk for Alcatel OT-I650

Kiyoshi Ueda (11):
      block: fix no diskstat problem
      block: fix a possible oops on elv_abort_queue()
      block: add request clone interface (v2)
      dm mpath: add start_io and nr_bytes to path selectors
      dm mpath: add queue length load balancer
      dm mpath: add service time load balancer
      dm: prepare for request based option
      dm: enable request based option
      dm: do not set QUEUE_ORDERED_DRAIN if request based
      dm: disable interrupt when taking map_lock
      dm mpath: change to be request based

Klaus-Dieter Wacket (2):
      qeth: Clear SBALF15 in any case for output buffers.
      [S390] pm: lcs driver power management callbacks

Kleber S. Souza (2):
      [SCSI] ipr: ipr_remove() marked __devexit
      [SCSI] ipr: fix PCI permanent error handler

Kristian H=C3=B8gsberg (1):
      drm_calloc_large: check right size, check integer overflow, use GFP=
_ZERO

Kristoffer Ericson (1):
      fbdev: s1d13xxxfb: add accelerated bitblt functions

Krzysztof Ha=C5=82asa (9):
      IXP4xx: Add support for the second half of the 64 hardware queues.
      IXP4xx: Ethernet and WAN drivers now support "high" hardware queues.
      IXP4xx: Whitespace fixes in the Ethernet driver.
      IXP42x: Identify Intel IXP425 rev. A0 processors.
      IXP42x: add NPE support for IXP425 rev. A0 processors.
      IXP42x: Add QMgr support for IXP425 rev. A0 processors.
      IXP42x: Use __fls() in QMgr interrupt handlers.
      IXP4xx: support for Goramo MultiLink router platform.
      IXP4xx: Change QMgr function names to qmgr_stat_*_watermark and cle=
an the comments.

Krzysztof Helt (17):
      ALSA: sc6000: add support for SC-6600 and SC-7000
      ALSA: sc6000: fix older card initialization
      ALSA: sc6000: enable joystick port
      bw2: use standard fields for framebuffer physical address and lengt=
h
      cg14: use standard fields for framebuffer physical address and leng=
th
      cg3: use standard fields for framebuffer physical address and lengt=
h
      cg6: use standard fields for framebuffer physical address and lengt=
h
      leo: use standard fields for framebuffer physical address and lengt=
h
      p9100: use standard fields for framebuffer physical address and len=
gth
      chipsfb: remove redundant assignment
      igafb: use framebuffer_alloc() to allocate fb_info struct
      offb: use framebuffer_alloc() to allocate fb_info struct
      acornfb: remove fb_mmap function
      s3c-fb: fix resource releasing on error during probing
      fbdev: use framebuffer_release() for freeing fb_info structures
      tcx: use standard fields for framebuffer physical address and lengt=
h
      fbdev: do not allow VESA modes without compiled-in drivers

Kumar Gala (35):
      fs_enet: Remove dead code
      gianfar: Use memset instead of cacheable_memzero
      powerpc/fsl: Remove cell-index from PCI nodes
      powerpc: Refactor board check for PCI quirks on FSL boards with uli=
1575
      powerpc/fsl: use of_iomap() for rstcr mapping
      powerpc/85xx: Add binding for LAWs and ECM
      powerpc/85xx: Add new LAW & ECM device tree nodes for all 85xx syst=
ems
      powerpc/86xx: Add binding for LAWs and MCM
      powerpc/86xx: Add new LAW & MCM device tree nodes for all 86xx syst=
ems
      powerpc/cpm: Remove some cruft code and defines
      powerpc/86xx: clean up smp init code
      powerpc/fsl: Removed reg property from 85xx/86xx soc node
      fsldma: Fix compile warnings
      powerpc/85xx: Add MSI nodes for MPC8568/9 MDS systems
      powerpc/fsl: Support unique MSI addresses per PCIe Root Complex
      powerpc/8xxx: Update PCI outbound window addresses for 36-bit confi=
gs
      powerpc/fsl_rio: Fix compile warnings
      powerpc/fsl: Update FSL esdhc binding
      powerpc/85xx: Add P2020DS board support
      powerpc/fsl: Setup PCI inbound window based on actual amount of mem=
ory
      powerpc: Fix up elf_read_implies_exec() usage
      powerpc/pci: Clean up direct access to sysdata by indirect ops
      powerpc/pci: Clean up direct access to sysdata by FSL platforms
      powerpc/pci: Clean up direct access to sysdata by 52xx platforms
      powerpc/pci: Clean up direct access to sysdata by 4xx platforms
      powerpc/pci: Clean up direct access to sysdata by CHRP platforms
      powerpc/pci: Clean up direct access to sysdata on tsi108 platforms
      powerpc/pci: Clean up direct access to sysdata by powermac platform=
s
      powerpc/pci: Clean up direct access to sysdata by RTAS
      powerpc/pci: Clean up direct access to sysdata by celleb platforms
      powerpc/pci: Move pseries code into pseries platform specific area
      powerpc/pci: Cleanup some minor cruft
      powerpc/pci: Remove redundant pcnet32 fixup
      powerpc/pci: clean up direct access to sysdata by iseries platform
      powerpc/85xx: Add SWIOTLB support to FSL boards

Kuninori Morimoto (14):
      sh: Add support for SH7724 (SH-Mobile R2R) CPU subtype.
      serial: sh-sci: SH7724 support.
      sh: sh7724: Add I2C support.
      sh: sh7724: Add VPU support.
      sh: sh7724: Add VEU support.
      sh: Add ms7724se (SH7724) board support
      sh: SH7724 has an L2 cache.
      sh: fix CONFIG_SH_PCLK_FREQ bug for sh7724
      sh: add RAMCR definition for sh4
      sh: add weak l2_cache_init function.
      sh: sh7724: L2 cache initialization.
      sh: sh7723: L2 cache initialization.
      sh: sh7724: INTC setting update
      sh: sh7724: Add JPU support

Kwangwoo Lee (2):
      S3C64XX: Basic A&W6410 board support patch V2
      Input: tsc2007 - make sure platform provides get_pendown_state()

Kyle McMartin (1):
      MAINTAINERS: rds list is moderated

Kyungmin Park (2):
      [ARM] S3C6410: Basic support for NCP board (v2)
      mtd: onenand: add bbt_wait & unlock_all as replaceable for some pla=
tform

Lachlan McIlroy (1):
      xfs_file_last_byte() needs to acquire ilock

Lai Jiangshan (2):
      ring_buffer: compressed event header
      tracing: add trace_event_read_lock()

Larry Finger (6):
      kaweth: Clean up code
      b43legacy: Do not select HW_RANDOM
      rfkill: Fix broken rfkill LED in 2.6.30-rc1
      b43legacy: Fixes for beaconing
      b43legacy: Clean up beacon IRQ
      rtl8187: Implement TX/RX blink for LED

Laszlo Attila Toth (1):
      netfilter: xt_socket: added new revision of the 'socket' match supp=
orting flags

Laurent Pinchart (8):
      V4L/DVB (11835): uvcvideo: Parse frame descriptors with non-continu=
ous indexes.
      V4L/DVB (11836): uvcvideo: Add missing whitespaces to multi-line fo=
rmat strings.
      V4L/DVB (11837): uvcvideo: Start status polling on device open
      V4L/DVB (11944): uvcvideo: Add generic control blacklist.
      V4L/DVB (11945): uvcvideo: Don't accept to change the format when b=
uffers are allocated.
      V4L/DVB (11946): uvcvideo: Add support for Aveo Technology webcams
      V4L/DVB (11947): uvcvideo: Add support for FSC V30S webcams
      V4L/DVB (11948): uvcvideo: Ignore non-UVC trailing interface descri=
ptors.

Lee Nipper (2):
      crypto: talitos - scaffolding for new algorithm types
      crypto: talitos - Add ablkcipher algorithms

Len Brown (9):
      ACPI: delete acpi.power_nocheck from kernel-parameters.txt
      ACPI: delete dead acpi_disabled setting code
      ACPI, PCI, x86: move MCFG parsing routine from ACPI to PCI file
      ACPI: move declaration acpi_early_init() to acpi.h
      ACPI: #define acpi_disabled 1 for CONFIG_ACPI=3Dn
      ACPI: battery: fix CONFIG_ACPI_PROCFS_POWER=3Dn build warning
      ACPI: idle: rename lapic timer workaround routines
      Merge branches 'acerhdf', 'acpi-pci-bind', 'bjorn-pci-root', 'bugzi=
lla-12904', 'bugzilla-13121', 'bugzilla-13396', 'bugzilla-13533', 'bugzil=
la-13612', 'c3_lock', 'hid-cleanups', 'misc-2.6.31', 'pdc-leak-fix', 'pnp=
acpi', 'power_nocheck', 'thinkpad_acpi', 'video' and 'wmi' into release
      Merge branch 'bjorn-notify' into release

Lennart Poettering (2):
      V4L/DVB (11960): v4l: generate KEY_CAMERA instead of BTN_0 key even=
ts on input devices
      V4L/DVB (11993): V4L/pwc - use usb_interface as parent, not usb_dev=
ice

Lennert Buytenhek (8):
      mv643xx_eth: fix variable shadowing sparse warning
      mv643xx_eth: count handling a link event as one unit of napi work
      mv643xx_eth: minor register definition cleanup
      mv643xx_eth: rework receive skb cache alignment
      [ARM] alternative copy_to_user/clear_user implementation
      mtd: m25p80: add support for Macronix MX25L12805D
      [ARM] Kirkwood: add Marvell 88F6281 GTW GE board support
      fb: add support of LCD display controller on pxa168/910 (base layer=
)

Li Yang (2):
      powerpc/fsl_rio: use LAW address from device tree
      rapidio: fix section mismatch warnings

Li Zefan (45):
      tracing: use macros to denote usec and nsec per second
      blktrace: fix output of unknown events
      blktrace: fix output of BLK_TC_PC events
      blktrace: support per-partition tracing for ftrace plugin
      blktrace: add trace/ to /sys/block/sda
      blktrace: fix context-info when mixed-using blk tracer and trace ev=
ents
      tracing: fix file mode of trace and README
      tracing/filters: don't remove old filters when failed to write subs=
ys->filter
      tracing/filters: allow user-input to be integer-like string
      tracing/events: make struct trace_entry->type to be int type
      tracing/events: don't say hi when loading the trace event sample
      tracing/events: make SAMPLE_TRACE_EVENTS default to n
      tracing/events: fix memory leak when unloading module
      tracing/events: fix concurrent access to ftrace_events list
      tracing/events: fix concurrent access to ftrace_events list, fix
      tracing/events: clean up for ftrace_set_clr_event()
      tracing/events: simplify system_enable_read()
      blktrace: pdu_buf of pc events should be unsigned
      blktrace: from-sector redundant in trace_block_remap, cleanup
      tracing/filters: add missing unlock in a failure path
      tracing/filters: fix off-by-one bug
      cls_cgroup: remove unneeded cgroup_lock
      tracing/events: Documentation updates
      tracing/events: change the type of __str_loc_item to unsigned short
      tracing/stat: change dummpy_cmp() to return -1
      tracing/stat: remember to free root node
      tracing/stat: do some cleanups
      tracing/events: fix a typo in __string() format output
      tracing/events: put TP_fast_assign into braces
      tracing/events: introduce __dynamic_array()
      tracing/events: convert block trace points to TRACE_EVENT()
      tracing/events: convert block trace points to TRACE_EVENT(), fix !C=
ONFIG_BLOCK
      tracing: fix a typo in tracing_cpumask_write()
      tracing: replace a GFP_ATOMIC with GFP_KERNEL allocation
      tracing/filters: operand can be negative
      tracing/filters: strloc should be unsigned short
      block: remove some includings of blktrace_api.h
      tracing/filters: free filter_string in destroy_preds()
      tracing/filters: fix race between filter setting and module unload
      hexdump: remove the trailing space
      sched: Remove unneeded __ref tag
      cgroups: forbid noprefix if mounting more than just cpuset subsyste=
m
      devcgroup: skip superfluous checks when found the DEV_ALL elem
      memcg: remove some redundant checks
      memcg: remove unneeded forward declaration from sched.h

Liam Girdwood (2):
      regulator: build fix for powerpc - renamed show_state
      regulator: lp3971 - fix driver link error when built-in.

Lin Ming (4):
      ACPICA: Fix reference count issues for DdbHandle object
      ACPICA: Invalidate DdbHandle after table unload
      ACPICA: New: AcpiInstallMethod - install a single control method
      ACPICA: Region deletion: Ensure region object is removed from handl=
er list

Linus Torvalds (205):
      x86: unify arch/x86/boot/compressed/vmlinux_*.lds
      ext3: avoid unnecessary spinlock in critical POSIX ACL path
      x86, e820, pci: reserve extra free space near end of RAM
      Make /dev/zero reads interruptible by signals
      Merge branch 'irq-for-linus' of git://git.kernel.org/pub/scm/linux/=
kernel/git/tip/linux-2.6-tip
      Merge branch 'x86-kbuild-for-linus' of git://git.kernel.org/pub/scm=
/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'sched-core-for-linus' of git://git.kernel.org/pub/scm=
/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'sched-docs-for-linus' of git://git.kernel.org/pub/scm=
/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'x86-asm-for-linus' of git://git.kernel.org/pub/scm/li=
nux/kernel/git/tip/linux-2.6-tip
      Merge branch 'x86-cleanups-for-linus' of git://git.kernel.org/pub/s=
cm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'x86-cpu-for-linus' of git://git.kernel.org/pub/scm/li=
nux/kernel/git/tip/linux-2.6-tip
      Merge branch 'x86-fpu-for-linus' of git://git.kernel.org/pub/scm/li=
nux/kernel/git/tip/linux-2.6-tip
      Merge branch 'x86-microcode-for-linus' of git://git.kernel.org/pub/=
scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'x86-mm-for-linus' of git://git.kernel.org/pub/scm/lin=
ux/kernel/git/tip/linux-2.6-tip
      Merge branch 'x86-setup-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'x86-urgent-for-linus' of git://git.kernel.org/pub/scm=
/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'x86-vdso-for-linus' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/tip/linux-2.6-tip
      Merge branch 'x86-xen-for-linus' of git://git.kernel.org/pub/scm/li=
nux/kernel/git/tip/linux-2.6-tip
      Merge branch 'futexes-for-linus' of git://git.kernel.org/pub/scm/li=
nux/kernel/git/tip/linux-2.6-tip
      Merge branch 'iommu-for-linus' of git://git.kernel.org/pub/scm/linu=
x/kernel/git/tip/linux-2.6-tip
      Merge branch 'locking-for-linus' of git://git.kernel.org/pub/scm/li=
nux/kernel/git/tip/linux-2.6-tip
      Merge branch 'percpu-for-linus' of git://git.kernel.org/pub/scm/lin=
ux/kernel/git/tip/linux-2.6-tip
      Merge branch 'printk-for-linus' of git://git.kernel.org/pub/scm/lin=
ux/kernel/git/tip/linux-2.6-tip
      Merge branch 'rcu-for-linus' of git://git.kernel.org/pub/scm/linux/=
kernel/git/tip/linux-2.6-tip
      Merge branch 'signal-for-linus' of git://git.kernel.org/pub/scm/lin=
ux/kernel/git/tip/linux-2.6-tip
      Merge branch 'oprofile-for-linus' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/tip/linux-2.6-tip
      Merge branch 'tracing-for-linus' of git://git.kernel.org/pub/scm/li=
nux/kernel/git/tip/linux-2.6-tip
      Merge branch 'tracing-urgent-for-linus' of git://git.kernel.org/pub=
/scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'serial-from-alan'
      Merge branches 'frv' and 'mn10300'
      Merge branch 'for-2.6.31' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/bart/ide-2.6
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tytso/ext4
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jmorris/security-testing-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/sfrench/cifs-2.=
6
      Merge branch 'kvm-updates/2.6.31' of git://git.kernel.org/pub/scm/v=
irt/kvm/kvm
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/lethal/sh-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/bp/bp
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/steve/gfs2-2.6-=
nmw
      Merge branch 'for-2.6.31' of git://git.kernel.dk/linux-2.6-block
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/jgarzik/libata-dev
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/shaggy/jfs-2.6
      Merge branch 'topic/slab/earlyboot' of git://git.kernel.org/pub/scm=
/linux/kernel/git/penberg/slab-2.6
      Merge branch 'perfcounters-for-linus' of git://git.kernel.org/pub/s=
cm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for-linus' of git://linux-arm.org/linux-2.6
      Merge branch 'for-linus' of git://git.infradead.org/users/eparis/no=
tify
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/mason/btrfs-uns=
table
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/gerg/m68knommu
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/viro/vfs-2.6
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for-2.6.31' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/bart/ide-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/rusty/linux-2.6=
-module-and-param
      Merge branch 'cuse' of git://git.kernel.org/pub/scm/linux/kernel/gi=
t/mszeredi/fuse
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/rusty/linux-2.6=
-virtio
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/rusty/linux-2.6=
-lguest
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/steve/gfs2-2.6-=
nmw
      Merge git://git.infradead.org/~dwmw2/firmware-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/jejb/scsi-misc-=
2.6
      Merge branch 'topic/slab/earlyboot-v2' of git://git.kernel.org/pub/=
scm/linux/kernel/git/penberg/slab-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge branch 'for-linus' of git://linux-arm.org/linux-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/vapier/blackfin
      Merge branch 'for-linus' of git://git.monstr.eu/linux-2.6-microblaz=
e
      Merge branch 'perfcounters-fixes-for-linus' of git://git.kernel.org=
/pub/scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/teigland/dlm
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/rafael/suspend-2.6
      Merge branch 'drm-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/airlied/drm-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/arnd/asm-generic
      Merge branch 'for-linus' of git://git390.marist.edu/pub/scm/linux-2=
.6
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/jlbec/configfs
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/herbert/crypto-=
2.6
      Merge branch 'docs-next' of git://git.lwn.net/linux-2.6
      Merge branch 'for-linus' of git://oss.sgi.com/xfs/xfs
      Merge branch 'x86-mce-for-linus' of git://git.kernel.org/pub/scm/li=
nux/kernel/git/tip/linux-2.6-tip
      Merge branch 'next-i2c' of git://aeryn.fluff.org.uk/bjdooks/linux
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/hskinnemoen/avr=
32-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/jejb/scsi-rc-fi=
xes-2.6
      Merge branch 'for-linus' of master.kernel.org:/home/rmk/linux-2.6-a=
rm
      Merge master.kernel.org:/home/rmk/linux-2.6-arm
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jikos/hid
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jikos/trivial
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/drzeus/mmc
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/jaswinder/heade=
rs-check-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/roland/infiniband
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/sam/kbuild-next
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/ryusuke/nilfs2
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/lrg/voltage-2.6
      Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/benh/powerpc
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-=
2.6
      Merge branch 'timers-for-linus-ntp' of git://git.kernel.org/pub/scm=
/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'timers-for-linus-clocksource' of git://git.kernel.org=
/pub/scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'timers-for-linus-clockevents' of git://git.kernel.org=
/pub/scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'timers-for-linus-migration' of git://git.kernel.org/p=
ub/scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel=
/git/aegl/linux-2.6
      printk: clean up handling of log-levels and newlines
      printk: Add KERN_DEFAULT printk log-level
      printk: add KERN_DEFAULT loglevel to print_modules()
      Merge branch 'acpica' of git://git.kernel.org/pub/scm/linux/kernel/=
git/lenb/linux-acpi-2.6
      Merge branch 'hwmon-for-linus' of git://git.kernel.org/pub/scm/linu=
x/kernel/git/jdelvare/staging
      Merge branch 'i2c-for-linus' of git://git.kernel.org/pub/scm/linux/=
kernel/git/jdelvare/staging
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/hirofumi/fatfs-=
2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/mason/btrfs-uns=
table
      Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/benh/powerpc
      Merge branch 'for-linus' of git://git.kernel.dk/linux-2.6-block
      Merge branch 'for-linus' of git://git390.marist.edu/pub/scm/linux-2=
.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/vapier/blackfin
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-nex=
t-2.6
      Merge branch 'serial'
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/jlbec/ocfs2
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/shaggy/jfs-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-c=
ore-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/usb-2.6
      Merge branch 'for-linus2' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/vegard/kmemcheck
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/ieee1394/linux1394-2.6
      readahead: clean up and simplify the code for filemap page fault re=
adahead
      Merge branch 'akpm'
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/mchehab/linux-2.6
      Merge branch 'drm-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/airlied/drm-2.6
      Merge branch 'next-i2c' of git://aeryn.fluff.org.uk/bjdooks/linux
      ext3: avoid unnecessary spinlock in critical POSIX ACL path
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/viro/vfs-2.6
      Merge branch 'upstream' of git://ftp.linux-mips.org/pub/scm/upstrea=
m-linus
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/penberg/slab-2.6
      Merge branch 'linux-next' of git://git.infradead.org/ubifs-2.6
      Merge branch 'linux-next' of git://git.infradead.org/ubi-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/jejb/scsi-misc-=
2.6
      Merge branch 'fixes' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/davej/cpufreq
      Merge branch 'kmemleak' of git://linux-arm.org/linux-2.6
      Merge branch 'for-next' of git://git.kernel.org/pub/scm/linux/kerne=
l/git/sameo/mfd-2.6
      Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel=
/git/aegl/linux-2.6
      Merge branch 'for-linus' of git://neil.brown.name/md
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/wim/linux-2.6-w=
atchdog
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-=
2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/lethal/sh-2.6
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tytso/ext4
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/vapier/blackfin
      Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/benh/powerpc
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-nex=
t-2.6
      Merge branch 'for-linus' of git://git.kernel.dk/linux-2.6-block
      Merge branch 'i2c-for-linus' of git://git.kernel.org/pub/scm/linux/=
kernel/git/jdelvare/staging
      Merge branch 'for-linus' of git://git.infradead.org/users/eparis/no=
tify
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging-=
2.6
      x86: don't use 'access_ok()' as a range check in get_user_pages_fas=
t()
      Merge branch 'for-2.6.31' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/bart/ide-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/hirofumi/fatfs-=
2.6
      Merge branch 'drm-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/airlied/drm-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/dtor/input
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/sam/kbuild-fixe=
s
      Merge branch 'for-linus' of git://git.monstr.eu/linux-2.6-microblaz=
e
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'timers-fixes-for-linus' of git://git.kernel.org/pub/s=
cm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'tracing-fixes-for-linus' of git://git.kernel.org/pub/=
scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'sched-fixes-for-linus' of git://git.kernel.org/pub/sc=
m/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'perfcounters-fixes-for-linus' of git://git.kernel.org=
/pub/scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'irq-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      x86, 64-bit: Clean up user address masking
      Remove internal use of 'write_access' in mm/memory.c
      Move FAULT_FLAG_xyz into handle_mm_fault() callers
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge branch 'core-fixes-for-linus' of git://git.kernel.org/pub/scm=
/linux/kernel/git/tip/linux-2.6-tip
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/herbert/crypto-=
2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/drzeus/mmc
      Revert "char: moxa, prevent opening unavailable ports"
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-=
2.6
      Merge branch 'linux-next' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/jbarnes/pci-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/czankel/xtensa-=
2.6
      Merge branch 'next-i2c' of git://aeryn.fluff.org.uk/bjdooks/linux
      Merge branch 'for-linus' of git://git390.marist.edu/pub/scm/linux-2=
.6
      Merge branch 'for-2.6.31' of git://git.linux-nfs.org/projects/trond=
my/nfs-2.6
      Merge branch 'for-2.6.31' of git://fieldses.org/git/linux-nfsd
      Merge branch 'devel' of master.kernel.org:/home/rmk/linux-2.6-arm
      Merge git://git.infradead.org/mtd-2.6
      mm/init: cpu_hotplug_init() must be initialized before SLAB
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/ieee1394/linux1394-2.6
      Merge git://git.infradead.org/~dwmw2/iommu-2.6.31
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/vapier/blackfin
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/ide-2.6
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/jgarzik/libata-dev
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/mchehab/linux-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/wim/linux-2.6-w=
atchdog
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge branch 'for-linus' of git://www.jni.nu/cris
      Merge branch 'kmemleak' of git://linux-arm.org/linux-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/arnd/asm-generic
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/jejb/scsi-misc-=
2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/roland/infiniband
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/lethal/sh-2.6
      Merge branch 'next-i2c' of git://aeryn.fluff.org.uk/bjdooks/linux
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/jlbec/ocfs2
      Merge git://git.infradead.org/iommu-2.6
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jack/linux-udf-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-=
2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/viro/vfs-2.6
      Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel=
/git/lenb/linux-acpi-2.6
      Merge branch 'audit.b63' of git://git.kernel.org/pub/scm/linux/kern=
el/git/viro/audit-current
      Merge branch 'for-upstream' of git://git.kernel.org/pub/scm/linux/k=
ernel/git/dvrabel/uwb
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/agk/linux-2.6-d=
m
      Merge branch 'upstream' of git://ftp.linux-mips.org/pub/scm/upstrea=
m-linus
      Don't warn about order-1 allocations with __GFP_NOFAIL
      Merge branch 'futexes-for-linus' of git://git.kernel.org/pub/scm/li=
nux/kernel/git/tip/linux-2.6-tip
      Merge branches 'for-linus' of git://git.kernel.org/pub/scm/linux/ke=
rnel/git/viro/{vfs-2.6,audit-current}
      Merge git://git.infradead.org/battery-2.6
      Revert "PCI: use ACPI _CRS data by default"
      Linux 2.6.31-rc1

Linus Walleij (16):
      [ARM] 5470/1: U300 register definitions
      [ARM] 5471/2: U300 GPIO and PADMUX support
      [ARM] 5474/1: U300 clocking framework
      [ARM] 5473/1: U300 core machine support
      [ARM] 5480/1: U300-v5 integrate into the ARM architecture
      [ARM] 5510/1: U300 GPIO debug and init fixes
      [ARM] 5533/1: Add U300 series defconfig
      [ARM] 5535/1: U300 Makefile.boot
      [ARM] 5546/1: ARM PL022 SSP/SPI driver v3
      [ARM] 5544/1: Trust PrimeCell resource sizes
      driver core: Const-correct platform getbyname functions
      i2c: ST DDC I2C U300 bus driver v3
      i2c: Use resource_size macro
      i2c-stu300: Make driver depend on MACH_U300
      mfd: add U300 AB3100 core support
      [WATCHDOG] U300 COH 901 327 watchdog driver

Lopez Cruz, Misael (4):
      ASoC: TWL4030: Add VDL analog bypass
      ASoC: TWL4030: Add voice digital loopback: sidetone
      ASoC: TWL4030: Add control for selecting codec operation mode
      ASoC: SDP3430: Connect twl4030 voice DAI to McBSP3

Louis Rilling (2):
      configfs: Silence lockdep on mkdir() and rmdir()
      configfs: Rework configfs_depend_item() locking and make lockdep ha=
ppy

Lubomir Rintel (1):
      x86: Fix non-lazy GS handling in sys_vm86()

Luck, Tony (1):
      intel-iommu: Fix one last ia64 build problem in Pass Through Suppor=
t

Luis Henriques (3):
      perf_counter: fix alignment in /proc/interrupts
      locking, rtmutex.c: Documentation cleanup
      [CPUFREQ] powernow-k8.c: mess cleanup

Luis R. Rodriguez (33):
      ath9k: Update maintainers for ath9k
      atheros: put atheros wireless drivers into ath/
      ath: space cleanup
      ath5k: sparse fix ath5k_led_on needs to be static
      cfg80211: respect API on orig_flags on channel for beacon hint
      cfg80211: add netlink channel put helper
      cfg80211: send regulatory beacon hint events to userspace
      atheros: fix propagation of bad EEPROM on regulatory init
      cfg80211: make nl80211_send_mlme_timeout() static
      mac80211: Fix sparse warning for ssid_len on ieee80211_sta_config_a=
uth()
      ath9k: make private driver rate tables const
      cfg80211: Process regulatory max bandwidth checks for HT40
      wireless: rename IEEE80211_CHAN_NO_FAT_* to HT40-/+
      mac80211: check if HT40+/- is allowed before sending assoc
      cfg80211: check allowed channel type upon userspace requests
      mac80211/cfg80211: move wiphy specific debugfs entries to cfg80211
      cfg80211: add debugfs HT40 allow map
      cfg80211: return immediately if num reg rules > NL80211_MAX_SUPP_RE=
G_RULES
      cfg80211: cleanup return calls on nl80211_set_reg()
      cfg80211: fix in nl80211_set_reg()
      ath9k: fix custom regulatory call position
      ath9k: set max default eirp to 20 dBm
      cfg80211: warn when wiphy_apply_custom_regulatory() does nothing
      mac80211: handle -EALREADY on cfg80211 op assoc req
      ar9170: add support for 1-stage firmware
      ar9170: add AVM FRITZ devices
      cfg80211: fix for duplicate userspace replies
      ath: make regulatory parsing more verbose on debug
      cfg80211: make ieee80211_get_mesh_hdrlen() static
      mac80211: extend sta kdoc - explain when they are added
      mac80211: removed unused variable in ieee80211_tx()
      cfg80211: fix for duplicate response for driver reg request
      mac80211: disable moving between PS modes during scan

Luk?? Karas (1):
      V4L/DVB (11451): gspca - m5602-s5k83a: Add rotation, ctrl cache. Re=
name some ctrls.

Lukas Karas (1):
      V4L/DVB (11634): gspca - m5602-s5k83a: Set the sensor_settings poin=
ter correctly

Ma Ling (1):
      drm/i915: Set correct TV detection voltage level override values

Maciej W. Rozycki (2):
      declance: Restore tx descriptor ring locking
      eisa.ids: add Network Peripherals FDDI boards

Magnus Damm (104):
      sh: pass along struct pci_channel
      sh: add init member to pci_channel data
      sh: avoid using PCIBIOS_MIN_xxx
      sh: hook in struct pci_channel in sysdata
      sh: add reg_base member to pci_channel
      sh: add io_base member to pci_channel
      sh: pci memory range checking code
      sh: pci io port base address code
      sh: export board_pci_channels in one place
      clocksource: sh_cmt earlytimer support
      sh: arch earlytimer support
      sh: Add plat_early_device_setup()
      sh: Early Platform Data for SuperH Mobile
      clocksource: sh_cmt clocksource support
      smsc911x: add fifo byteswap support V2
      clocksource: improve sh_cmt clocksource overflow handling
      sh: setup timers in late_time_init()
      sh: pass through ioremap() for non-mmu processors.
      clocksource: sh_cmt 16-bit fixes
      sh: sh2/sh2a 16-bit CMT platform data
      sh: remove old CMT driver
      clocksource: setup mult_orig in clocksource_enable()
      clockevent: export register_device and delta2ns
      clocksource: SuperH MTU2 Timer driver
      sh: sh2a MTU2 platform data
      sh: remove old MTU2 driver
      clocksource: SuperH TMU Timer driver
      sh: TMU platform data for sh7722
      sh: sh7785 early scif fix
      sh: call clock framework init() callback once
      sh: r7785 highlander clock fixes
      sh: TMU platform data for sh7785
      sh: clock framework update, fix count and kill off kref
      sh: enable TMU clocksource on sh7722
      sh: TMU platform data for sh7723
      sh-sci: add platform device private data
      sh-sci: remove early_sci_setup()
      sh-sci: rework serial console support
      sh-sci: use to_sci_port() if possible
      sh-sci: allow single port platform devices
      sh-sci: replace sci_init_ports()
      sh-sci: ioremap() in a single place
      sh-sci: improve clock framework support
      sh: include empty_zero_page in text
      sh: TMU platform data for sh775x
      sh: TMU platform data for sh7760
      sh: multiple vectors per irq - sh7760
      sh: r7780 highlander clock fixes
      sh: TMU platform data for sh7780
      sh: TMU platform data for sh7763
      sh: add sh7770_generic_defconfig
      sh: TMU platform data for sh7770
      sh: TMU platform data for sh4-202
      sh: add sh4-202 INTC tables
      sh: TMU platform data for sh7343
      sh: TMU platform data for sh7366
      sh: TMU platform data for sh7724
      sh: TMU platform data for sh7705
      sh: TMU platform data for sh7706/sh7707/sh7708/sh7709
      sh: TMU platform data for sh7710/sh7712
      sh: TMU platform data for sh7720/sh7721
      sh: CMT platform data for sh7720/sh7721
      sh: remove old TMU driver
      sh: intc tables for sh7770
      sound: oss: sh_dac_audio timer fixes.
      sh: clkfwk branch compile fix for clock-sh7722
      sh: add pll_clk to sh7785
      sh: add shared clock framework frequency table code
      sh: use shared frequency tables on sh7785
      sh: remove clk_ops->build_rate_table()
      sh: boot word / mode pin support V2
      sh: sh7785 mode pin definitions
      sh: sh7785lcr mode pin configuration
      sh: sh7785 pll configuration from mode pin
      sh: shared mstp32 clock code
      sh: hook up shared mstp32 clock code to sh7785
      sh: shared div4 clock code
      sh: hook up shared div4 clock code to sh7785
      sh: 16-bit get_unaligned() sh4a fix
      sh: clock div4 frequency table offset fix
      sh: clock div6 helper code
      sh: rework mode pin code
      sh: sh7723 mode pin V2
      sh: sh7724 mode pin comments
      sh: sh7722 mode pin definitions
      sh: add Migo-R mode pin configuration
      sh: add AP325RXA mode pin configuration
      sh: add enable()/disable()/set_rate() to div6 code
      sh: sh7723 clock framework rewrite V2
      sh: sh7724 clock framework rewrite V3
      sh: sh7343 clock framework rewrite
      sh: sh7366 clock framework rewrite
      sh: sh7722 clock framework rewrite
      PM: Remove unused asm/suspend.h
      PM: Rename device_power_down/up()
      PM: Remove bus_type suspend_late()/resume_early() V2
      PM: Remove device_type suspend()/resume()
      Driver Core: Rework platform suspend/resume, print warning
      sh: smsc911x support for the rsk7203 board
      V4L/DVB (11731): buf-dma-contig: remove sync operation
      videobuf-dma-contig: zero copy USERPTR support
      sh: unbreak WARN_ON()
      sh: use kzalloc() for cpg clocks
      sh: turn off irqs when disabling CMT/TMU timers

Magnus Lilja (9):
      i.MX31: Add UART1 device to Litekit board.
      i.MX31: Removed unused items from board-mx31lite.h.
      i.MX31: Correct comments on CONFIG_DEBUG_LL.
      i.MX31: Add ethernet support to i.MX31 Litekit board.
      i.MX31: Add NAND device driver for Litekit board.
      i.MX31: Restructure UART setup for PDK board.
      i.MX31: Add support for the CPLD on PDK Debug board.
      i.MX31: Add support for LAN9217 on PDK debug board.
      mtd: mxc_nand: add correct dev_id parameter to free_irq() calls

Mallikarjuna R Chilakala (2):
      ixgbe: Fix 82599 adapter link flickering issues
      ixgbe: ethtool support to change advertised link modes of 82599 ada=
pters

Manish Katiyar (5):
      ext4: Fix memory leak in ext4_fill_super() in case of a failed moun=
t
      ext3: Fix memory leak in ext3_fill_super() in case of a failed moun=
t
      ext2: Fix memory leak in ext2_fill_super() in case of a failed moun=
t
      kernel/kallsyms.c: replace deprecated __initcall with device_initca=
ll and fix whitespace
      trivial: kernel/power/poweroff.c: whitespace fix

Mans Rullgard (1):
      ARM: OMAP: Increase VMALLOC_END to allow 256MB RAM

Manu Abraham (12):
      V4L/DVB (11579): Initial go at TT S2-1600
      V4L/DVB (11581): stv090x and stv6110x: fix repeater level setup and=
 ref clock
      V4L/DVB (11582): stv090x: fix Undocumented Registers
      V4L/DVB (11586): stv090x: switch i/p ADC as well during Power manag=
ement
      V4L/DVB (11587): stv090x: set DiSEqC frequency to 22kHz
      V4L/DVB (11588): stv090x: support > 60MSPS, simplify Srate calculat=
ion
      V4L/DVB (11589): stv090x: code simplification
      V4L/DVB (11590): stv090x: code simplification
      V4L/DVB (11591): stv090x: code simplification
      V4L/DVB (11682): STV0900/STV0903: Add support for Silicon cut >=3D =
3
      V4L/DVB (12130): Fix a redundant compiler warning
      V4L/DVB (12131): BUGFIX: An incorrect Carrier Recovery Loop optimiz=
ation table was being

Manuel Gebele (3):
      Staging: comedi: add vmk80xx USB driver
      Staging: comedi: Makefile changes
      Staging: Comedi: vmk80xx: Add k8061 support

Manuel Lauss (5):
      MIPS: Alchemy: Remove unused au1000_gpio.h header
      MIPS: Alchemy: Rewrite GPIO support.
      MIPS: Alchemy: MTX-1: Use linux gpio api.
      MIPS: Alchemy: xxs1500: use linux gpio api.
      MIPS: Alchemy: devboards: Convert to gpio calls.

Marcel Holtmann (10):
      Bluetooth: Remove unnecessary variable initialization
      Bluetooth: Add basic constants for L2CAP ERTM support and use them
      Bluetooth: Remove pointless endian conversion helpers
      Bluetooth: Use only MISC_DYNAMIC_MINOR for virtual driver
      Bluetooth: Use wait_event_interruptible for virtual driver
      Bluetooth: Remove BKL from open callback of virtual driver
      Bluetooth: Remove unused and unneeded support in virtual driver
      Bluetooth: Add native RFKILL soft-switch support for all devices
      Bluetooth: Fix Kconfig issue with RFKILL integration
      Bluetooth: Fix issue with uninitialized nsh.type in DTL-1 driver

Marcel Jueling (1):
      V4L/DVB (11492): af9015: support for Conceptronic USB2.0 DVB-T CTVD=
IGRCU V3.0

Marcelo Tosatti (12):
      KVM: x86: paravirt skip pit-through-ioapic boot check
      KVM: PIT: remove unused scheduled variable
      KVM: PIT: remove usage of count_load_time for channel 0
      KVM: unify part of generic timer handling
      KVM: PIT: fix count read and mode 0 handling
      KVM: MMU: remove global page optimization logic
      KVM: x86: check for cr3 validity in ioctl_set_sregs
      KVM: use smp_send_reschedule in kvm_vcpu_kick
      KVM: protect assigned dev workqueue, int handler and irq acker
      KVM: MMU: protect kvm_mmu_change_mmu_pages with mmu_lock
      KVM: take mmu_lock when updating a deleted slot
      KVM: x86: check for cr3 validity in mmu_alloc_roots

Marek Szyprowski (3):
      LP3971 PMIC regulator driver (updated and combined version)
      [ARM] S3C64XX: add to_irq() support for EINT() GPIO
      [ARM] S3C: Fix gpio-config off-by-one bug

Marek Vasut (6):
      Add support for CF8381 WiFi card.
      ASoC: Support AC97 link off by default on WM9712
      [ARM] pxa/palm: Switch PalmT5, TX, TE2 to GPIO VBUS
      [ARM] pxa/palm: Add Palm27x aSoC driver to PalmTE2
      [ARM] pxa/palm: Palm TX, T5, LD suspend-to-mem rework
      [ARM] pxa/palm: various fixes for PalmZ72 (mostly audio asoc and us=
b)

Marek Va=C5=A1ut (1):
      [ARM] 5522/1: PalmLD: IDE support

Mario Limonciello (2):
      dell-wmi: mask off upper bytes of event response
      dell-wmi: add additional keyboard events

Mariusz Kozlowski (3):
      Blackfin: fix parentheses balance and convert some tab/space mixing
      V4L/DVB (11566): remove broken macro from dvb stv0900_priv.h
      sound: fix check for return value in snd_pcm_hw_refine

Mark A. Greer (17):
      davinci: support different UART bases for zImage uncompress
      davinci: Encapsulate SoC-specific data in a structure
      davinci: Support JTAG ID register at any address
      davinci: Add clock init call to common init routine
      davinci: Add support for multiple PSCs
      davinci: Move pinmux setup info to SoC infrastructure
      davinci: Move interrupt ctlr info to SoC infrastructure
      davinci: Add base address and timer flexibility
      davinci: Add watchdog base address flexibility
      davinci: Make GPIO code more generic
      davinci: Move serial platform_device into SoC-specific files
      davinci: Move emac platform_data to SoC-specific files
      davinci: Remove unused i2c eeprom_read/write routines
      davinci: Factor out emac mac address handling
      davinci: Integrate cp_intc support into low-level irq code
      davinci: Add compare register support to timer code
      davinci: Move PINMUX defines to SoC files

Mark Adamson (2):
      USB: serial: FTDI: add high speed device support
      USB: ftdi_sio: fix hi-speed device packet size calculation

Mark Brown (94):
      ASoC: Display return code when failing to add a DAPM kcontrol
      ASoC: Provide core support for symmetric sample rates
      ASoC: Add WM8988 CODEC driver
      Merge branch 's6000' into for-2.6.31
      ASoC: WM9713 requires symmetric rates on the voice DAI
      ASoC: Factor out application of power for generic widgets
      ASoC: Support DAPM events for DACs and ADCs
      ASoC: Move the WM9713 voice DAC powerdown to a DAPM event
      ASoC: Add WM8960 CODEC driver
      Merge branch 'for-2.6.30' into for-2.6.31
      Merge branch 'for-2.6.30' into for-2.6.31
      ASoC: Check we have DAI ops when calling via accessor functions
      ASoC: Volume controls are never of boolean type
      ASoC: Request shared rates for WM8903
      Merge branch 'for-2.6.30' into for-2.6.31
      Merge branch 'for-2.6.30' into for-2.6.31
      ASoC: Factor out generic widget power checks
      ASoC: Factor out DAPM power checks for DACs and ADCs
      ASoC: Make the DAPM power check an operation on the widget
      ASoC: Add power supply widget to DAPM
      ASoC: Use DAPM supply widget for WM8903 charge pump
      ASoC: Support CLK_DSP in WM8903
      ASoC: Optimise configuration of WM8903 DC servo
      ASoC: Actively manage the DC servo for WM8903
      ASoC: Remove redundant rate constraint for WM8903
      ASoC: Implement WM8903 digital sidetone support
      Merge branch 'for-2.6.30' into for-2.6.31
      Merge branch 'for-2.6.30' into for-2.6.31
      ASoC: Fix S3C64xx IIS device registration and support both ports
      ASoC: S3C2412: Failing to get the I2S clock is an error
      ASoC: Enforce symmetric rates for S3C64xx I2S interface
      ASoC: Include WM8350 register definitions in CODEC header
      ASoC: s3c-i2s-v2 diagnostic improvements
      ASoC: Use our registration function for S3C64xx
      Merge branch 'for-2.6.30' into for-2.6.31
      ASoC: Staticise TLV values in WM8940
      Merge branch 'for-2.6.30' into for-2.6.31
      ASoC: Fix error message formatting in s3c64xx-i2s driver
      ASoC: Check for supported CPUs when building s3c-i2s-v2
      ASoC: Make S3C64xx clock export function to return struct clk
      ASoC: Fix data format configuration for S3C64xx IISv2 and add 24 bi=
t
      ASoC: Fix boot warnings from S3C IISv2
      ASoC: Allow use of resource from the platform device for S3C IISv2
      ASoC: Display the clock rate used as the basis for rate calculation
      ASoC: Display S3C IISv2 mode and MS errors by default
      ASoC: Staticise txctrl and rxctrl for S3C IISv2
      ASoC: Use platform device resource for S3C64xx IISv2
      [ARM] SMDK6410: Add support for SMSC9115 ethernet controller
      [ARM] SMDK6410: Support WM1190-EV1 PMIC board
      [ARM] SMDK6410: Use active high IRQ for the WM8350 on the WM1190-EV=
1
      [ARM] SMDK6410: Mark all supplies as always_on
      [ARM] SMDK6410: Hook regulator control of VDDARM up for WM1190-EV1
      ASoC: Use a shared define for AC97 CODEC data formats
      ASoC: Remove unused DAI format defines
      Merge commit 'takashi/topic/asoc' into for-2.6.31
      Merge branch 'for-2.6.30' into for-2.6.31
      ASoC: Remove redundant codec pointer from DAIs
      ASoC: Add headers to match patterns in MAINTAINERS
      [ARM] S3C64XX: Configure clocks for DMA controller
      ASoC: Fix file patterns for PXA sound drivers
      ASoC: Fix up CODEC DAI formats for big endian CPUs
      ASoC: Enforce symmetric rates for PXA2xx I2S
      Merge branch 'for-2.6.30' into for-2.6.31
      ASoC: Point at kernel.org git
      Merge branch 'pxa2xx-i2s' into for-2.6.31
      Merge branch 'for-2.6.30' into for-2.6.31
      ASoC: Split DAPM power checks from sequencing of power changes
      ASoC: Make DAPM sysfs entries non-optional
      ASoC: Integrate bias management with DAPM power management
      ASoC: Add debug trace for bias level transitions
      [ARM] S3C64XX: Lower severity of DMA logging
      AsoC: Make snd_soc_read() and snd_soc_write() functions
      ASoC: WM9081 mono DAC with integrated 2.6W class AB/D amplifier dri=
ver
      ASoC: Fix WM9081 PowerPC compiler issues
      ASoC: Fix minor issues in STAC9766 driver
      ASoC: Mark MPC5200 AC97 as BROKEN until PowerPC merge issues are re=
solved
      ASoC: Switch FSL SSI DAI over to symmetric_rates
      ASoC: Initialise dev for the dummy S/PDIF DAI
      ALSA: Fix double locking of card list in snd_card_register()
      ASoC: Apostrophe patrol
      ASoC: Fix lm4857 control
      ASoC: Remove odd bit clock ratios for WM8903
      ASoC: Revert duplicated code in SSM2602 driver
      ASoC: Instantiate any forgotten DAPM widgets
      regulator: Move regulator drivers to subsys_initcall()
      regulator: Support list_voltage for fixed voltage regulator
      regulator: Set MODULE_ALIAS for regulator drivers
      [ARM] pxa: register wm8731 explicitly for corgi and poodle
      [ARM] S3C64XX: Provide device for IIS ports
      [ARM] S3C64XX: Add device for IISv4 port
      [ARM] S3C64XX: Initial support for DVFS
      mfd: Correct readability of WM8350 register 227
      mfd: Mark WM8350 mask revision as readable to match silicon
      mfd: Fix Kconfig help text for WM8350

Mark Jackson (1):
      Fix MIMC200 board LCD init

Mark Langsdorf (4):
      x86: cacheinfo: replace sysfs interface for cache_disable feature
      x86: cacheinfo: disable L3 ECC scrubbing when L3 cache index is dis=
abled
      x86/docs: add description for cache_disable sysfs interface
      x86: enable GART-IOMMU only after setting up protection methods

Mark McLoughlin (3):
      virtio: teach virtio_has_feature() about transport features
      virtio: indirect ring entries (VIRTIO_RING_F_INDIRECT_DESC)
      lguest: add support for indirect ring entries

Mark Salter (1):
      MN10300: Add support for new ELF relocs in kernel modules

Mark de Wever (1):
      ide-tape: fix debug call

Markus Heidelberg (11):
      kconfig: fix typo "mconfig" to "menuconfig" in a comment
      kconfig: add a note about the deps to the 'silentoldconfig' help
      kconfig: resort the documentation of the environment variables
      gitignore: ignore Kconfig i18n files
      kconfig qconf: fix -Wall compiler warnings
      kconfig qconf: fix namespace for Horizontal and Vertical enum value=
s
      kconfig qconf: add namespace for use of Key_ enum values
      kconfig qconf: fix the type of the desktop widget
      kconfig: do not hardcode ".config" filename
      kconfig: do not hardcode "include/config/auto.conf" filename
      trivial: remove the trivial patch monkey's name from SubmittingPatc=
hes

Markus Metzger (29):
      x86, bts: detect size of DS fields
      x86, bts: add selftest for BTS
      x86, bts: correct comment style in ds.c
      x86, hw-branch-tracer: keep resources on stop
      x86, hw-branch-tracer: add selftest
      x86, bts: use atomic memory allocation
      x86, bts: fix race when bts tracer is removed
      sched, hw-branch-tracer: add wait_task_context_switch() function to=
 sched.h
      mm, x86, ptrace, bts: defer branch trace stopping
      x86, bts: wait until traced task has been scheduled out
      x86, bts: fix race between per-task and per-cpu branch tracing
      x86, bts: use trace_clock_global() for timestamps
      x86, debugctlmsr: add _on_cpu variants to debugctlmsr functions
      x86, bts, hw-branch-tracer: add _noirq variants to the debug store =
interface
      x86, hw-branch-tracer: allocate selftest iterator on heap
      x86, ds: fix compiler warning
      x86, ds: fix bounds check in ds selftest
      x86, ds: selftest each cpu
      x86, ds: add task tracing selftest
      x86, ds: add leakage warning
      x86, ds: use single debug store cpu configuration
      x86, ptrace: add bts context unconditionally
      x86, ds: dont use TIF_DEBUGCTLMSR
      x86, ds: fix bad ds_reset_pebs()
      x86, ds: allow small debug store buffers
      x86, ds: support Core i7
      x86, ds: fix buffer alignment in debug store selftest
      x86, bts: reenable ptrace branch trace support
      x86, bts, mm: clean up buffer allocation

Markus Trippelsdorf (1):
      inline functions left without protection of ifdef (acl)

Marti Raudsepp (1):
      perf_counter: Fix stack corruption in perf_read_hw

Martin Fuzzey (2):
      MXC : update i.MX21 clock support for USB host.
      USB: usbtest fix endless loop in unlink tests.

Martin K. Petersen (14):
      block: Do away with the notion of hardsect_size
      block: Use accessor functions for queue limits
      block: Move queue limits to an embedded struct
      block: Expose stacked device queues in sysfs
      block: Export I/O topology for block devices and partitions
      ide-disk: fix missing max_sectors accessor function
      block: Fix bounce limit setting in DM
      block: Add missing bounce_pfn stacking and fix comments
      block: Introduce helper to reset queue limits to default values
      block: Fix bounce_pfn setting
      sd: Physical block size and alignment support
      sd: Detect non-rotational devices
      sd: Block limits VPD support
      scsi_debug: Add support for physical block exponent and alignment

Martin Olsson (3):
      trivial: Fix paramater/parameter typo in dmesg and source comments
      trivial: fix typos s/paramter/parameter/ and s/excute/execute/ in d=
ocumentation and source comments.
      trivial: fix typo milisecond/millisecond for documentation and sour=
ce comments.

Martin Petermann (2):
      [SCSI] zfcp: Increase ref counter for port open requests
      [S390] pm: zfcp driver power management callbacks

Martin Schwidefsky (14):
      [S390] vdso: kernel parameter syntax
      [S390] merge cpu.h into cputime.h
      [S390] use facility list for cpu type safety check
      [S390] 3270: do not register with tty_register_device
      [S390] 3270: lock dependency fixes
      [S390] profile_tick called twice
      [S390] cio: force console function
      [S390] pm: con3215 power management callbacks
      [S390] pm: smsgiucv power management callbacks.
      [S390] pm: con3270 power management callbacks.
      [S390] driver_data access
      [S390] lockless idle time accounting
      [S390] Enable tick based perf_counter on s390.
      [S390] Update default configuration.

Marton Balint (3):
      V4L/DVB (11394): cx88: Add support for stereo and sap detection for=
 A2
      V4L/DVB (11395): cx88: audio thread: if stereo detection is hw supp=
orted don't do it manually
      V4L/DVB (11396): cx88: avoid reprogramming every audio register on =
A2 stereo/mono change

Martyn Welch (1):
      powerpc/86xx: Add I2C device mappings in DTS for SBC610

Masakazu Mokuno (1):
      net/ps3: Update maintainer

Masanori Kobayasi (1):
      trivial: Documentation/dell_rbu.txt: fix typos

Masatake YAMATO (2):
      trivial: Fix a typo in comment of addrconf_dad_start()
      syscalls.h: remove duplicated declarations for sys_pipe2

Mateusz Mandera (1):
      8390p: Get rid of init_module/cleanup_module

Mathieu Desnoyers (2):
      x86: clean up alternative.h
      tracepoint: trace_sched_migrate_task(): remove parameter

Matias Zabaljauregui (6):
      lguest: Segment selectors are 16-bit long. Fix lg_cpu.ss1 definitio=
n.
      lguest: map switcher with executable page table entries
      lguest: use native_set_* macros, which properly handle 64-bit entri=
es when PAE is activated
      lguest: replace hypercall name LHCALL_SET_PMD with LHCALL_SET_PGD
      lguest: Add support for kvm_hypercall4()
      lguest: PAE support

Mats Erik Andersson (1):
      PCI: expose SMBus on Asus notebook A6L

Matt Carlson (7):
      tg3: Allow screaming interrupt detection
      tg3: Handle NVRAM absent cases
      tg3: Prevent send BD corruption
      tg3: Allow 5761 WOL and LED fixes to 5761S too
      tg3: Limit CLKREQ fix to A[01] of 57780 asic rev
      tg3: Restore LAA sooner in shutdown sequence
      tg3: Update version to 3.99

Matt Fleming (4):
      sh: Update my email address
      sh: Fix dynamic ftrace's NOP action.
      sh: Make the atomic functions safe for irqsoff tracing
      sh: Fix declaration of __kernel_sigreturn and __kernel_rt_sigreturn

Matt Helsley (1):
      futex: documentation: fix inconsistent description of futex list_op=
_pending

Matt Kraai (1):
      trivial: Remove the hyphen from git commands

Matt LaPlante (1):
      trivial: Miscellaneous documentation typo fixes

Matt T. Yourst (1):
      KVM: x86: silence preempt warning on kvm_write_guest_time

Matthew Garrett (2):
      dell-wmi: don't generate errors on empty messages
      hp-wmi: Add support for reporting tablet state

Matthew Wilcox (8):
      mm: check the argument of kunmap on architectures without highmem
      [IA64] Convert ia64 to use int-ll64.h
      Fix pci_claim_resource
      Delete pcibios_select_root
      x86: Use pci_claim_resource
      ia64: Fix resource assignment for root busses
      PCI: remove redundant __msi_set_enable()
      PCI: Fix the NIU MSI-X problem in a better way

Matthias Kaehlcke (7):
      [ARM] 5552/1: ep93xx get_uart_rate(): use EP93XX_SYSCON_PWRCNT and =
EP93XX_SYSCON_PWRCN
      USB: ci13xxx_udc: use helper functions to determine endpoint type a=
nd direction
      USB: atmel_usba_udc: use helper functions to determine endpoint typ=
e and direction
      USB: at91_udc: use helper functions to determine endpoint type and =
direction
      USB: Goku-S: use helper functions to determine endpoint type and di=
rection
      USB: gadgetfs: use helper functions to determine endpoint type and =
direction
      USB: UHCI queue: use usb_endpoint_type()

Matthias Ludwig (1):
      smsc911x: fix calculation of res_size for ioremap

Matthias Schwarzott (2):
      V4L/DVB (11828): Reducing print-level of I2C error prints
      V4L/DVB (11894): flexcop-pci: dmesg visible names broken

Matthieu CASTET (2):
      mtd: m25p80 nand: add m45pe10 ids
      b43: Fix possible unaligned u32 access

Matthieu Castet (1):
      MIPS: BCM47xx: Fix gpio_direction_output

Maulik Mankad (1):
      USB: gadget : Fix RNDIS code to pass USB Compliance tests (USBCV) w=
ith g_ether

Mauro Carvalho Chehab (11):
      V4L/DVB (11654a): Add a missing end of line at the end of gspca/m56=
02/Makefile
      V4L/DVB (11663): Fix a warning introduced by git commit ec5f5bf8050=
1abfe2da2897cfcde8452b545aacb
      V4L/DVB (11825): em28xx: add Terratec Grabby
      V4L/DVB (11827): Add support for Terratec Grabster AV350
      V4L/DVB (11917): Fix firmware load for DVB-T @ 6MHz bandwidth for x=
c3028/xc3028L
      V4L/DVB (11918): tuner-xc2028: Fix offset frequencies for DVB @ 6MH=
z
      V4L/DVB (11922): tuner-xc2028: cleanup: better use tuner type defin=
es
      V4L/DVB (11966): ov511: Fix unit_video parameter behavior
      V4L/DVB (11986): Kconfig: DVBWorld DVB-C USB Cable card needs tda10=
02x frontend
      V4L/DVB (11780): Siano: fix compilation error due to the lack of EX=
TERNAL_SYMBOL
      V4L/DVB (12010): cx88: Properly support Leadtek TV2000 XP Global

Max Filippov (12):
      p54spi: mask value read from SPI_ADRS_DMA_WRITE_CTRL in p54spi_wait=
_bit
      p54spi: fix p54spi_upload_firmware
      p54spi: fix p54spi_tx_frame DMA transfer initiation and skb cleanup
      p54spi: compensate firmware alignment bug in p54spi_rx
      p54spi: get rid of busy-wait loops
      p54: call p54_wake_free_queues on every p54_free_skb and p54_rx_fra=
me_sent
      p54spi: fix incorrect access sequence to DMA_WRITE_CTRL in p54spi_s=
pi_write_dma
      p54spi: cosmetic fixes: use even byte count in SPI write; drop unus=
ed interrupt status read
      p54spi: return status of p54spi_wakeup
      p54spi: always call p54spi_sleep in p54spi_tx_frame if p54spi_wakeu=
p succeeded
      p54spi: use firmware/DMA bug workaround that work under hight load =
in p54spi_rx
      p54spi: drop test for FW_STATE_RESET in p54spi_work

Mel Gorman (25):
      page allocator: replace __alloc_pages_internal() with __alloc_pages=
_nodemask()
      page allocator: do not sanity check order in the fast path
      page allocator: do not check NUMA node ID when the caller knows the=
 node is valid
      page allocator: check only once if the zonelist is suitable for the=
 allocation
      page allocator: break up the allocator entry point into fast and sl=
ow paths
      page allocator: move check for disabled anti-fragmentation out of f=
astpath
      page allocator: calculate the preferred zone for allocation only on=
ce
      page allocator: calculate the migratetype for allocation only once
      page allocator: remove a branch by assuming __GFP_HIGH =3D=3D ALLOC=
_HIGH
      page allocator: inline __rmqueue_smallest()
      page allocator: inline buffered_rmqueue()
      page allocator: inline __rmqueue_fallback()
      page allocator: do not call get_pageblock_migratetype() more than n=
ecessary
      page allocator: do not disable interrupts in free_page_mlock()
      page allocator: do not setup zonelist cache when there is only one =
node
      page allocator: use allocation flags as an index to the zone waterm=
ark
      page allocator: update NR_FREE_PAGES only as necessary
      page allocator: get the pageblock migratetype without disabling int=
errupts
      page allocator: slab: use nr_online_nodes to check for a NUMA platf=
orm
      page allocator: sanity check order in the page allocator slow path
      mm: use alloc_pages_exact() in alloc_large_system_hash() to avoid d=
uplicated logic
      mm: add a gfp-translate script to help understand page allocation f=
ailure reports
      vmscan: properly account for the number of page cache pages zone_re=
claim() can reclaim
      vmscan: do not unconditionally treat zones that fail zone_reclaim()=
 as full
      vmscan: count the number of times zone_reclaim() scans and fails

Miao Xie (4):
      sched: use group_first_cpu() instead of cpumask_first(sched_group_c=
pus())
      cpusets: restructure the function cpuset_update_task_memory_state()
      cpusets: update tasks' page/slab spread flags in time
      cpuset,mm: update tasks' mems_allowed in time

Michael Buesch (8):
      b43: Do not "select" HW_RANDOM
      b43: Remove unnecessary MMIO in interrupt hotpath
      cfg80211: Remove unnecessary ksize() call
      cfg80211: Use the correct IE buffer pointer
      b43: Add fw capabilities
      parport_pc: Fix subscription bugs
      ppdev: reduce kernel log spam
      pegasus usb-net: Fix endianness bugs

Michael Chan (6):
      [SCSI] iscsi class: Add new NETLINK_ISCSI messages for cnic/bnx2i d=
river.
      [SCSI] bnx2: Add support for CNIC driver.
      [SCSI] cnic: Add new Broadcom CNIC driver.
      [SCSI] bnx2i: Add bnx2i iSCSI driver.
      [SCSI] cnic, bnx2i: Fix build failure when CONFIG_PCI is not set.
      cnic: Fix __symbol_get() build error.

Michael Cousin (1):
      drm/i915: Skip lvds with Aopen i945GTt-VFA

Michael Ellerman (16):
      powerpc/oprofile: Remove unused dump_pmcs() in FSL oprofile
      powerpc/irq: Move #ifdef'ed body of do_IRQ() into a separate functi=
on
      powerpc/irq: Move stack overflow check into a separate function
      powerpc/irq: Move get_irq() comment into header
      powerpc/irq: Remove fallback to __do_IRQ()
      powerpc/powermac: Use generic_handle_irq() in gatwick_action()
      powerpc/irq: We don't need __do_IRQ() anymore
      powerpc/ftrace: Use ppc_function_entry() instead of GET_ADDR
      powerpc/ftrace: Remove unused macros
      powerpc/ftrace: Use PPC_INST_NOP directly
      powerpc: Fix warning in setup_64.c when CONFIG_RELOCATABLE=3Dy
      powerpc/cell: Use driver_data acessors, not platform_data in Axon M=
SI
      powerpc: Only build prom_init.o when CONFIG_PPC_OF_BOOT_TRAMPOLINE=3D=
y
      powerpc/iseries: Fix unused function warning in iSeries DT code
      powerpc/iseries: Mark signal_vsp_instruction() as maybe unused
      powerpc: Add configurable -Werror for arch/powerpc

Michael Hennerich (10):
      netdev: bfin_mac: drop useless IRQF_SHARED from Blackfin EMAC inter=
rupt
      netdev: bfin_mac: fix performance issue found by netperf
      Blackfin SPORT UART: fix data misses while using transmit frame syn=
c
      Blackfin: add comment for anomaly 05000171 to init code
      Blackfin: fix up PATA resource handling in bf537-stamp
      Blackfin: do not error if GPIO IRQ is requested already as GPIO
      Blackfin: update gptimers API
      Blackfin: bf548-ezkit/bf537-stamp: add resources for ADXL345/346
      i2c: Blackfin TWI: make sure we don't end up with a CLKDIV=3D0
      i2c: Blackfin TWI: implement I2C_FUNC_SMBUS_I2C_BLOCK functionality

Michael Holzheu (3):
      [S390] pm: xpram driver power management callbacks
      [S390] pm: power management support for SCLP drivers.
      [S390] Use del_timer instead of del_timer_sync

Michael Krufky (13):
      V4L/DVB (11766): cx23885: mark functions encoder_on_port[bc] as sta=
tic inline
      V4L/DVB (11768): cx23885: add ATSC/QAM tuning support for Hauppauge=
 WinTV-HVR1270
      V4L/DVB (11769): cx23885: add ATSC/QAM tuning support for Hauppauge=
 WinTV-HVR1275
      V4L/DVB (11770): cx23885: add ATSC/QAM tuning support for Hauppauge=
 WinTV-HVR1255
      V4L/DVB (11771): cx23885: add DVB-T tuning support for Hauppauge Wi=
nTV-HVR1210
      V4L/DVB (11772): cx23885: update model matrix for "k2c2" retail boa=
rds
      V4L/DVB (11773): cx23885: clean up struct names for Hauppauge WinTV=
-HVR127X devices
      V4L/DVB (11858): cx23885: fix tda10048 IF frequencies for the Haupp=
auge WinTV-HVR1210
      V4L/DVB (11860): saa7134: fix quirk in saa7134_i2c_xfer for the saa=
7131 bridge
      V4L/DVB (11861): saa7134: enable digital tv support for Hauppauge W=
inTV-HVR1110r3
      V4L/DVB (11877): lgdt3305: fix 64bit division in function lgdt3305_=
set_if
      V4L/DVB (12115): tda10048: add missing entry to pll_tab for 3.8 MHz=
 IF
      V4L/DVB (12116): cx23885: ensure correct IF freq is used on HVR1200=
 & HVR1700

Michael Neuling (3):
      powerpc: Cleanup macros in ppc-opcode.h
      powerpc: Move VSX load/stores into ppc-opcode.h
      powerpc: Make the NR_CPUS max 8192

Michael Reed (3):
      [SCSI] qla2xxx: Conditionally disable automatic queue full tracking.
      [SCSI] qla1280: driver clean up
      [SCSI] qla1280: error recovery rewrite

Michael Roth (3):
      Input: ads7846 - support swapping x and y axes
      Input: ads7846 - more detailed model name in sysfs
      Input: ads7846 - pin change interrupt support

Michael S. Tsirkin (7):
      net: skb_copy_datagram_const_iovec()
      tun: fix tun_chr_aio_read so that aio works
      tun: fix tun_chr_aio_write so that aio works
      PCI MSI: let drivers retry when not enough vectors
      virtio: find_vqs/del_vqs virtio operations
      virtio_pci: split up vp_interrupt
      virtio_pci: optional MSI-X support

Michael Shields (1):
      Doc fix: ext2 can only have 32,000 subdirs, not 32,768

Michael Trimarchi (1):
      i2c: Fix stuck transaction on cpm-i2c driver

Michal Marek (5):
      ALSA: clean up the logic for building sequencer modules
      kbuild: handle non-existing options in scripts/config
      kbuild: simplify argument loop in scripts/config
      kbuild: add generic --set-str option to scripts/config
      kobject: samples: make SAMPLE_KOBJECT module-only

Michal Miroslaw (2):
      PCI quirk: unhide 'Overflow' device on i828{6,7}5P/PE chipsets
      PCI quirk: HP hides SMBus controller in Compaq nx9500 laptops

Michal Simek (42):
      microblaze: Remove POWERPC reference from Microblaze gpio.h
      microblaze: Kconfig: Enable drivers for Microblaze
      microblaze: prepare signal handling for generic unistd.h
      microblaze: Fix early cmdline for CMDLINE_FORCE
      microblaze: Cleanup compiled-in rootfs in BSS section
      Microblaze: Remove unused variable from paging init
      microblaze: Fix cast warning for __va in prom.c
      microblaze: Kbuild update
      microblaze: Fix size of __kernel_mode_t to short
      microblaze_mmu_v2: Add mmu_defconfig
      microblaze_mmu_v2: MMU update for startup code
      microblaze_mmu_v2: Alocate TLB for early console
      microblaze_mmu_v2: TLB low level code
      microblaze_mmu_v2: MMU initialization
      microblaze_mmu_v2: mmu.h update
      microblaze_mmu_v2: Page fault handling high level - fault.c
      microblaze_mmu_v2: Context handling - mmu_context.c/h
      microblaze_mmu_v2: Page table - ioremap - pgtable.c/h, section upda=
te
      microblaze_mmu_v2: io.h MMU update
      microblaze_mmu_v2: pgalloc.h and page.h
      microblaze_mmu_v2: Update process creation for MMU
      microblaze_mmu_v2: Update tlb.h and tlbflush.h
      microblaze_mmu_v2: MMU asm offset update
      microblaze_mmu_v2: Add CURRENT_TASK for entry.S
      microblaze_mmu_v2: entry.S, entry.h
      microblaze_mmu_v2: Update exception handling - MMU exception
      microblaze_mmu_v2: uaccess MMU update
      microblaze_mmu_v2: Add MMU related exceptions handling
      microblaze_mmu_v2: Update linker script for MMU
      microblaze_mmu_v2: Enable fork syscall for MMU and add fork as vfor=
k for noMMU
      microblaze_mmu_v2: Traps MMU update
      microblaze_mmu_v2: Update signal returning address
      microblaze_mmu_v2: Update cacheflush.h
      microblaze_mmu_v2: Update dma.h for MMU
      microblaze_mmu_v2: Elf update
      microblaze_mmu_v2: stat.h MMU update
      microblaze_mmu_v2: Kconfig update
      microblaze_mmu_v2: Makefiles
      microblaze: Fix problem with early_printk in startup
      fs/bio.c: add missing __user annotation
      procfs: remove sparse errors in proc_devtree.c
      microblaze: Add missing symbols for CONSTRUCTORS support

Micha=C5=82 Miros=C5=82aw (10):
      genetlink: Introduce genl_register_family_with_ops()
      irda: Use genl_register_family_with_ops()
      tipc: Use genl_register_family_with_ops()
      ipvs: Use genl_register_family_with_ops()
      netlabel: Use genl_register_family_with_ops()
      wireless: Use genl_register_family_with_ops()
      mtd: add SST39SF040 chip to jedec_probe
      bridge: Simplify interface for ATM LANE
      mmc: Driver for CB710/720 memory card reader (MMC part)
      cb710: more cleanup for the DEBUG case.

Michel D=C3=A4nzer (8):
      therm_adt746x: Always clear hardware bit which inverts fan speed ra=
nge.
      drm: EDID endianness fixes.
      drm/radeon: Respect AGP cant_use_aperture flag.
      radeon: Enable modesetting on non-x86.
      drm/ttm: Add some powerpc cache flush code.
      agp/uninorth: Handle user memory types.
      radeon: Fix CP byte order on big endian architectures with KMS.
      drm/radeon: Fully initialize LVDS info also when we can't get it fr=
om the ROM.

Michel Pollet (5):
      [MTD] [NAND] S3C2410: Added a kerneldoc for s3c2410_nand_set
      [MTD] [NAND] S3C2410: Allow the machine code to get the BBT table f=
rom NAND
      [ARM] MINI2440: Add machine support
      [ARM] MINI2440: Document the mini2440=3D kernel parameter
      [ARM] MINI2440: Create a mini2440_defconfig file

Michele Valzelli (1):
      USB: option.c: add Toshiba 3G HSDPA SM-Bus Minicard device id

Mika Korhonen (1):
      mtd: OneNAND: add missing __devexit_p

Mikael Pettersson (1):
      nvidiafb: fix boot-time printk string

Mike Christie (16):
      [SCSI] iscsi: pass ep connect shost
      [SCSI] libiscsi: check of LLD has a alloc pdu callout.
      [SCSI] libiscsi: handle param allocation failures
      [SCSI] libiscsi: export iscsi_itt_to_task for bnx2i
      [SCSI] libiscsi: have iscsi_data_in_rsp call iscsi_update_cmdsn
      [SCSI] libiscsi: fix nop response/reply and session cleanup race
      [SCSI] libiscsi_tcp: update recv tracking for each skb instead of i=
scsi pdu
      [SCSI] libiscsi: fix iscsi transport checks to account for slower l=
inks
      [SCSI] libiscsi: handle cleanup task races
      [SCSI] libiscsi: don't let io sit in queue when session has failed
      [SCSI] libiscsi: check if iscsi host has work queue before queueing=
 work
      [SCSI] libiscsi: add task aborted state
      [SCSI] libiscsi: add debug printks for iscsi command completion pat=
h
      [SCSI] libfc: use DID_ERROR when we have internall aborted command
      libiscsi: don't run scsi eh if iscsi task is making progress
      iscsi_tcp: propogate EAGAIN from sendpage to libiscsi

Mike Frysinger (107):
      crypto: hifn_795x - fix __dev{init,exit} markings
      mtd: blackfin NFC: remove pointless return value in bf5xx_nand_dma_=
rw
      mtd: uclinux: allow systems to override map addr/size
      mtd: uclinux: do not allow to be built as a module
      mtd: uclinux: mark local stuff static
      mtd: maps: Blackfin async: fix memory leaks in probe/remove funcs
      netdev: smsc911x: allow building on Blackfin systems
      netdev: smsc911x: add missing __devexit_p() usage
      ignore *.patch files
      ftrace/documentation: fix typo in function grapher name
      Blackfin SPORT UART: fix typo in sport_set_termios prototype
      Blackfin SPORT UART: rewrite inline assembly
      tty: bfin_jtag_comm: emulate a TTY over the Blackfin EMUDAT/JTAG in=
terface
      linux/magic.h: move cramfs magic out of cramfs_fs.h
      Blackfin: add some help text to the EBIU_AMBCTL settings
      Blackfin: fix data cache flushing when doing icache flushing
      Blackfin: fix warnings with I/O port macros
      Blackfin: pull updated anomaly lists from toolchain
      Blackfin: set bf51x/bf52x to 0.0 rev by default and bf54x to 0.2
      Blackfin: simplify the do_flush macro
      Blackfin: simplify BF561 coreb driver greatly
      Blackfin: fix detection of cached L2 SRAM
      Blackfin: punt useless GPIO init call
      Blackfin: delete unused sys_getpagesize() function
      Blackfin: workaround anomaly 05000227
      Blackfin: do not append newlines to panic() messages
      Blackfin: rename some Blackfin drivers
      Blackfin: add note about anomaly 05000242 being worked around
      Blackfin: fix command line corruption with DEBUG_DOUBLEFAULT
      Blackfin: override default uClinux MTD addr/size
      Blackfin: check SIC defines rather than variant names
      Blackfin: rename Blackfin relocs according to the toolchain
      Blackfin: document the lsl variants of the L1 allocator
      Blackfin: convert early_printk EVT init to a loop
      Blackfin: punt duplicated search_exception_table() prototype
      Blackfin: push access_ok() L1 attribute down
      Blackfin: kgdb: fix up error return values
      Blackfin: fix unused warnings after nommu update
      Blackfin: fix sparseirq/kstat_irqs fallout
      virtio_blk: add missing __dev{init,exit} markings
      perf_counter: Start documenting HAVE_PERF_COUNTERS requirements
      Blackfin: export ip_compute_csum/csum_partial_copy_from_user symbol=
s
      Blackfin: add support for GENERIC_BUG
      Blackfin: fix trap_c() exit paths
      Blackfin: push down exception oops checking
      Blackfin: fix flag storage for irq funcs
      Blackfin: bf537-stamp: update ADP5520 resources
      Blackfin: bf548-ezkit: update smsc911x resources
      Blackfin: convert Kconfig style to def_bool
      Blackfin: add support for bzip2/lzma compressed kernel images
      Blackfin: add support for irqflags
      Blackfin: punt unused/wrong mutex-dec.h
      Blackfin: move custom sections into sections.h
      Blackfin: add preliminary support for STACKTRACE
      Blackfin: enable support for LOCKDEP
      Blackfin: initial support for ftrace
      Blackfin: initial support for ftrace grapher
      Blackfin: improve CLKIN_HZ config default
      Blackfin: hook up new rt_tgsigqueueinfo syscall
      kallsyms: generalize text region handling
      ramfs: ignore unknown mount options
      drivers/hvc: Add missing __devexit_p()
      tty: fix unused warning when TCGETX is not defined
      i2c-bfin-twi: pull in io.h for ioremap()
      fbdev: blackfin has __raw I/O accessors, so use them in fb.h
      fbdev: bfin-t350mcqb-fb: drop unused local variables
      fbdev: *bfin*: fix __dev{init,exit} markings
      fbdev: bf54x-lq043fb: use kzalloc over kmalloc/memset
      drivers/char/rtc: disable legacy RTC driver on Blackfin systems
      gpio: max7301: add missing __devexit marking
      edac: add missing __devexit_p()
      Blackfin: use common test_bit() rather than __test_bit()
      Blackfin: pull in asm/io.h in ksyms for prototypes
      Blackfin: only build irqpanic.c when needed
      Blackfin: convert asm/ioctls.h to asm-generic/ioctls.h
      Blackfin: convert shm/sysv/ipc to asm-generic
      Blackfin: convert user/elf to asm-generic
      Blackfin: convert socket/poll to asm-generic
      Blackfin: convert simple headers to asm-generic
      Blackfin: convert termios to asm-generic
      Blackfin: convert locking primitives to asm-generic
      Blackfin: convert signal/mmap to asm-generic
      Blackfin: convert irq/process to asm-generic
      Blackfin: convert types to asm-generic
      Blackfin: convert page/tlb to asm-generic
      asm-generic: uaccess: add missing access_ok() check to strnlen_user=
()
      asm-generic: uaccess: fix up local access_ok() usage
      istallion: add missing __devexit marking
      kallsyms: fix inverted valid symbol checking
      bfin_jtag_comm: clean up printk usage
      serial: bfin_5xx: add missing spin_lock init
      serial: bfin_5xx: fix building as module when early printk is enabl=
ed
      Blackfin: unify memory region checks between kgdb and traps
      Blackfin: bf518f-ezbrd: update DSA resources
      Blackfin: bf533-ezkit: add resources for FISP devices
      Blackfin: update anomaly lists
      Blackfin: redo handling of bad irqs
      Blackfin: only build show_interrupts() when procfs is enabled
      Blackfin: simplify irq stack overflow checking
      Blackfin: abstract irq14 lowering in do_irq
      Blackfin: allow people to select BF51x-0.1 silicon rev
      Blackfin: update defconfigs
      Blackfin: unify memory map headers
      Blackfin: drop unused ISP1760 port1_disable from board resources
      Blackfin: fix GPTMR0_CLOCKSOURCE dependency on BFIN_GPTIMERS
      Blackfin: hook up new perf_counter_open syscall
      rmap: fixup page_referenced() for nommu systems

Mike Galbraith (24):
      perfcounters: throttle on too high IRQ rates
      perfcounters: ratelimit performance counter interrupts
      perfcounters fix section mismatch warning in perf_counter.c::perf_c=
ounters_lapic_init()
      perfcounters: fix refcounting bug
      perfcounters: fix "perf counters kill oprofile" bug
      perf_counters: account NMI interrupts
      perfcounters: fix use after free in perf_release()
      perf_counter tools: kerneltop: add real-time data acquisition threa=
d
      perf_counter tools: kerneltop: display per function percentage alon=
g with event count
      perf_counter tools: fix build error
      perf_counter, x86: clean up throttling printk
      perf top: fix segfault
      perf top: Reduce display overhead
      perf top: Remove leftover NMI/IRQ bits
      perf top: fix typo in -d option
      perf record: Fix the profiling of existing pid or whole box
      perf_counter tools: Document '--' option parsing terminator
      perf_counter tools: Fix top symbol table dump typo
      perf_counter tools: Fix top symbol table max_ip typo
      perf_counter tools: Guard against record damaging existing files
      perf_counter tools: Make .gitignore reflect perf_counter tools file=
s
      perf_counter tools: Cleanup Makefile
      perf_counter tools: Fix uninitialized variable in perf-report.c
      x86, boot: add new generated files to the appropriate .gitignore fi=
les

Mike Isely (10):
      V4L/DVB (11744): pvrusb2: Select, track, and report IR scheme in us=
e with the device
      V4L/DVB (11745): pvrusb2: Update to work with upcoming ir_video cha=
nges in v4l-dvb core
      V4L/DVB (11746): pvrusb2: Set ir_video autoloading to default disab=
led
      V4L/DVB (11747): pvrusb2: Bump up version advertised through v4l in=
terface
      V4L/DVB (11750): pvrusb2: Allocate a routing ID for future support =
of Terratec Grabster AV400
      V4L/DVB (12118): pvrusb2: Fix hardware scaling when used with cx258=
40
      V4L/DVB (12119): pvrusb2: Re-fix hardware scaling on video standard=
 change
      V4L/DVB (12120): pvrusb2: Change initial default frequency setting
      V4L/DVB (12121): pvrusb2: Improve handling of routing schemes
      V4L/DVB (12122): pvrusb2: De-obfuscate code which handles routing s=
chemes

Mike Lockwood (1):
      Staging: android: timed_gpio: Separate timed_output class into a se=
parate driver.

Mike Rapoport (20):
      ASoC: em-x270: make the driver support also eXeda and CM-X300 machi=
nes
      [ARM] pxa: update pxa2xx_spi_chip initialization to use .gpio_cs fi=
eld
      [ARM] pxa: add ability to set suspend mode
      [ARM] pxa/em-x270: add exeda GPIO extender and update GPIO mappings
      [ARM] pxa/em-x270: update libertas device setup
      [ARM] pxa/em-x270: change power supply name to "battery"
      [ARM] pxa/em-x270: add support for on-board USB Hub
      [ARM] pxa/em-x270, cm-x270: use DEEPSLEEP for PM_SUSPEND_MEM
      [ARM] pxa/cm-x300: use OBM configuration for NAND flash
      [ARM] pxa/cm-x300: add rtc-v3020 device registration
      [ARM] pxa/cm-x300: use STUART for uncompressor
      [ARM] pxa/cm-x300: add .fixup method to enable second DRAM bank
      [ARM] pxa/cm-x300: update defconfig
      da9030_battery: Fix race between event handler and monitor
      regulator: add userspace-consumer driver
      [ARM] pxa/em-x270: remove .gpio_cs from em_x270_libertas_pdata
      [ARM] pxa/em-x270: add ability to control GPS and GPRS power
      [ARM] pxa/em-x270: always register AC97 controller device
      [ARM] pxa/em-x270: fix type in SND_PXA2XX_LIB_AC97
      Input: add driver for Synaptics I2C touchpad

Mike Sager (3):
      nfs41: define NFS4_MAX_MINOR_VERSION based on CONFIG_NFS_V4_1
      nfs41: add mount command option minorversion
      nfsd41: Remove ip address collision detection case

Mike Snitzer (8):
      block: export blk_stack_limits()
      dm table: ensure targets are aligned to logical_block_size
      dm table: validate device logical_block_size
      dm table: replace struct io_restrictions with struct queue_limits
      dm table: establish queue limits by copying table limits
      dm target:s introduce iterate devices fn
      dm log: fix create_log_context to use logical_block_size of log dev=
ice
      dm: calculate queue limits during resume not load

Mike Travis (1):
      sfc: modify allocation error message

Mike Waychison (1):
      mm: remove __invalidate_mapping_pages variant

Miklos Szeredi (14):
      fuse: use struct path in release structure
      fuse: clean up fuse_write_fill()
      fuse: prepare fuse_direct_io() for CUSE
      fuse: add members to struct fuse_file
      fuse: don't use inode in helpers called by fuse_direct_io()
      fuse: clean up args in fuse_finish_open() and fuse_release_fill()
      fuse: create fuse_do_open() helper for CUSE
      fuse: don't use inode in fuse_sync_release()
      fuse: don't use inode in fuse_do_ioctl() helper
      fuse: don't use inode in fuse_file_poll
      splice: implement pipe to pipe splicing
      splice: implement default splice_read method
      splice: implement default splice_write method
      splice: fix kmaps in default_file_splice_write()

Mikulas Patocka (24):
      dm mpath: validate table argument count
      dm mpath: validate hw_handler argument count
      dm raid1: keep retrying alloc if mempool_alloc failed
      dm mpath: flush keventd queue in destructor
      dm: avoid unsupported spanning of md stripe boundaries
      dm: use i_size_read
      dm: rename suspended_bdev to bdev
      dm: always hold bdev reference
      dm: make dm_flush return void
      dm: process requeue in dm_wq_work
      dm: store only first barrier error
      dm: remove EOPNOTSUPP for barriers
      dm: remove check that prevents mapping empty bios
      dm: introduce num_flush_requests
      dm: send empty barriers to targets in dm_flush
      dm: linear support flush
      dm: stripe support flush
      dm crypt: support flush
      dm delay: support barriers
      dm mpath: support barriers
      dm snapshot: support barriers
      dm io: record eopnotsupp
      dm io: retry after barrier error
      dm snapshot: use barrier when writing exception store

Milan Broz (2):
      dm: sysfs skip output when device is being destroyed
      dm ioctl: support cookies for udev

Milton Miller (2):
      powerpc: Enable MMU feature sections for inline asm
      powerpc: Add 2.06 tlbie mnemonics

Mimi Zohar (7):
      integrity: lsm audit rule matching fix
      integrity: use audit_log_string
      integrity: remove __setup auditing msgs
      integrity: path_check update
      integrity: move ima_counts_get
      integrity: nfsd imbalance bug fix
      integrity: ima audit dentry_open failure

MinChan Kim (1):
      vmscan: prevent shrinking of active anon lru list in case of no swa=
p space V3

Minchan Kim (6):
      page-allocator: clean up functions related to pages_min
      page-allocator: add inactive ratio calculation function of each zon=
e
      page-allocator: reset wmark_min and inactive ratio of zone when hot=
plug happens
      mm: remove annotation of gfp_mask in add_to_swap
      mm: remove file argument from swap_readpage()
      use printk_once() in several places

Ming Lei (4):
      tracing: fix check for return value of register_module_notifier
      ftrace: fix check for return value of register_module_notifier in e=
vent_trace_init
      driver core: firmware_class: replace kfree(dev) with put_device(dev=
)
      driver core: fix documentation of request_firmware_nowait

Minkyu Kang (1):
      Add MAX17040 Fuel Gauge driver

Miroslav Sustek (2):
      V4L/DVB (11879): Adds support for Leadtek WinFast DTV-1800H
      V4L/DVB (11441): cx88-dsp: fixing 64bit math

Misael Lopez Cruz (1):
      ASoC: TWL4030: Enable/disable voice digital filters

Mithlesh Thukral (2):
      Staging: wlan-ng: Lindent cleanups
      Staging: wlan-ng: Update README file. Remove Lindent task

Mohamed Abbas (12):
      iwlagn: Sync rxon active with changes
      iwlcore: fix channel display in debugfs
      iwlcore: Fix stay in table function.
      iwlwifi: allow config if device not ready
      iwlagn: improve rate scale table search
      iwlcore: register locks
      iwlcore: support ICT interrupt
      iwlcore: Allow skb allocation from tasklet.
      iwlcore: Add support for periodic RX interrupt
      iwlcore: Set rb_timeout to 0x10 for devices with ICT
      iwlagn: co-exist with AMT
      iwlagn: delay ict interrupt.

M=C3=A1rton N=C3=A9meth (2):
      V4L/DVB (11573): uvcvideo: Prevent invormation loss with removing i=
mplicit casting
      V4L/DVB (11574): uvcvideo: fill reserved fields with zero of VIDIOC=
_QUERYMENU

Naga Chumbalkar (3):
      x86: Print real IOAPIC version for x86-64
      [CPUFREQ] powernow-k8: read P-state from HW
      [CPUFREQ] powernow-k8: get drv data for correct CPU

Nate Case (8):
      powerpc/fsl-booke: Enable L1 cache on e500v1/e500v2/e500mc CPUs
      powerpc/85xx: cuboot - Fix up ethernet3 MAC address on MPC85xx
      powerpc/85xx: Add platform support for X-ES MPC85xx boards
      powerpc/85xx: Add dts files for X-ES MPC85xx boards
      powerpc/85xx: Add defconfig for X-ES MPC85xx boards
      powerpc/bootwrapper: Custom build options for XPedite52xx targets
      gpio: pca953x: Get platform_data from OpenFirmware
      gpio: pca953x: Add support for PCA9556

Nathan Fontenot (1):
      powerpc: Display processor virtualization resource allocs in lparcf=
g

Neil Horman (6):
      snmp: add missing counters for RFC 4293
      drop_monitor: Update netlink protocol to include netlink attribute =
header in alert message
      dropmon: add ability to detect when hardware dropsrxpackets
      kexec: sysrq: simplify sysrq-c handler
      ipv4: fix NULL pointer + success return in route lookup path
      ipv4 routing: Ensure that route cache entries are usable and reclai=
mable with caching is off

Neil Turton (2):
      amd-iommu: fix an off-by-one error in the AMD IOMMU driver.
      amd-iommu: fix the handling of device aliases in the AMD IOMMU driv=
er.

NeilBrown (16):
      md/raid0: two cleanups in create_stripe_zones.
      md: raid0: remove ->sectors from the strip_zone structure.
      md: raid0: remove ->dev pointer from strip_zone structure
      md: raid0:  remove setting of segment boundary.
      md: remove mddev_to_conf "helper" macro
      md: raid0: chunk_sectors cleanups.
      md: raid5: check stripe cache is large enough in start_reshape
      md: remove unnecessary arguments from ->reconfig method.
      md: merge reconfig and check_reshape methods.
      md: move assignment of ->utime so that it never gets skipped.
      md: raid0/linear: ensure device sizes are rounded to chunk size.
      md: remove chunksize rounding from common code.
      md/linear: use call_rcu to free obsolete 'conf' structures.
      md/raid5: correctly update sync_completed when we reach max_resync
      nfsd: don't take nfsd_mutex twice when setting number of threads.
      nfsd: optimise the starting of zero threads when none are running.

Nelson Castillo (4):
      [ARM] S3C: ADC: Fix lines with more than 80 chars in adc.h
      [ARM] S3C: ADC: Expose number of remaining conversions to
      [MTD] [NAND] S3C2410: Small colon cleanup
      [MTD] [NAND] S3C2410: Uninitialised variable cleanup

Nelson, Shannon (3):
      ixgbe: Interrupt management update for 82599
      ixgbe: Clear out stray tx work on link down
      ixgbe: Typecase '1' for 64 bit shift

Nick Kossifidis (7):
      ath5k: Allow user/driver to set txpower
      ath5k: Read Spur channels from EEPROM
      ath5k: Put remaining EEPROM data on ee struct
      ath5k: Beaconing fixes
      ath5k: Implement antenna control
      ath5k: Add Spur filter support on newer chips
      ath5k: fix mesh beaconing

Nick Piggin (6):
      fs: remove incorrect I_NEW warnings
      fs: block_dump missing dentry locking
      SLUB: Fix early boot GFP_DMA allocations
      mm: clean up get_user_pages_fast() documentation
      page allocator: do not check for compound pages during the page all=
ocator sanity checks
      mm: madvise(): correct return code

Nickolas Lloyd (2):
      ALSA: hda - add controls to toggle DC bias on mic ports
      ALSA: hda - Jack Mode changes for Sigmatel boards

Nico Schottelius (1):
      kbuild: fix delay in setlocalversion on readonly source

Nicolas Ferre (5):
      [ARM] 5438/1: AT91: manage clock by functionality instead of CPUs
      atmel-mci: Integrate AT91 specific definition in header file
      atmel-mci: add MCI2 register definitions
      USB: atmel_usba_udc: change way of specifying bias function
      MAINTAINERS: add myself as atmel-mci maintainer (sd/mmc interface)

Nicolas Pitre (14):
      [ARM] allow for alternative __copy_to_user/__clear_user implementat=
ions
      [ARM] lower overhead with alternative copy_to_user for small copies
      [ARM] alternative copy_to_user: more precise fallback threshold
      mtd: orion_nand: use burst reads with double word accesses
      [ARM] orion: make sure sched_clock() usage of cnt32_to_63() is safe
      [ARM] Kirkwood: only map peripheral register space once
      [ARM] Kirkwood: comment type fix
      [ARM] Kirkwood: rationalize NAND setup a bit
      [ARM] Orion/Kirkwood: rename orion5x_wdt to orion_wdt
      [ARM] Kirkwood: let's use real size for resources
      [ARM] Kirkwood: create a mapping for the Security Accelerator SRAM
      [ARM] Kirkwood: platform device registration for the crypto engine
      [ARM] 5545/2: add flush_kernel_dcache_page() for ARM
      [ARM] orion5x: register the crypto device on SOCs that support it

Niilo Minkkinen (1):
      usb: musb: disable OTG AUTOIDLE only with omap3430

Nikanth Karthikesan (4):
      block: catch trying to use more bits than request->cmd_flags has
      block: prevent possible io_context->refcount overflow
      trivial: fix comment typo in fs/compat.c
      trivial: fix typo in bio_alloc kernel doc

Nitin A Kamble (1):
      KVM: VMX: Rename rmode.active to rmode.vm86_active

Nivedita Singhvi (1):
      ipv4: New multicast-all socket option

Nobuhiro Iwamatsu (3):
      sh: Add support mtd mapping for highlander
      sh: Update r7780mp defconfig
      sh: Revised clock function in highlander

N=C3=A9meth M=C3=A1rton (2):
      trivial: usb: fix missing space typo in doc
      V4L/DVB (11736): videobuf: modify return value of VIDIOC_REQBUFS io=
ctl

OGAWA Hirofumi (1):
      fat: Fix the removal of opts->fs_dmask

Olaf Weber (1):
      xfs: add more checks to superblock validation

Old=C5=99ich Jedli=C4=8Dka (1):
      V4L/DVB (11567): saa7134: Added support for AVerMedia Cardbus Plus

Oleg Nesterov (34):
      selinux: selinux_bprm_committed_creds() should wake up ->real_paren=
t, not ->parent.
      do_wait: do take security_task_wait() into account
      rcu: rcu_sched_grace_period(): kill the bogus flush_signals()
      slow_work_thread() should do the exclusive wait
      shift current_cred() from __f_setown() to f_modown()
      send_sigio_to_task: sanitize the usage of fown->signum
      allow_signal: kill the bogus ->mm check, add a note about CLONE_SIG=
HAND
      ptrace: remove PT_DTRACE from arch/h8300
      ptrace: remove PT_DTRACE from avr32, mn10300, parisc, s390, sh, xte=
nsa
      ptrace: remove PT_DTRACE from m68k, m68knommu
      ptrace: remove PT_DTRACE from arch/m32r
      ptrace: mm_need_new_owner: use ->real_parent to search in the sibli=
ngs
      ptrace: tracehook_unsafe_exec(): remove the stale comment
      ptrace: do not use task->ptrace directly in core kernel
      ptrace: ptrace_attach: check PF_KTHREAD + exit_state instead of ->m=
m
      ptrace: cleanup check/set of PT_PTRACED during attach
      ptrace: do not use task_lock() for attach
      ptrace_get_task_struct: s/tasklist/rcu/, make it static
      ptrace: wait_task_zombie: s/->parent/->real_parent/
      ptrace: do_notify_parent_cldstop: fix the wrong ->nsproxy usage
      ptrace: don't take tasklist to get/set ->last_siginfo
      wait_task_zombie: do not use thread_group_cputime()
      copy_process(): remove the unneeded clear_tsk_thread_flag(TIF_SIGPE=
NDING)
      elf_core_dump: use rcu_read_lock() to access ->real_parent
      shift "ptrace implies WUNTRACED" from ptrace_do_wait() to wait_task=
_stopped()
      introduce "struct wait_opts" to simplify do_wait() patches
      do_wait: simplify retval/tsk_result/notask_error mess
      do_wait: kill the old BUG_ON, use while_each_thread()
      do_wait: fix the theoretical race with stop/trace/cont
      kthreads: simplify the startup synchronization
      kthreads: rework kthread_stop()
      kthreads: simplify migration_thread() exit path
      Staging: epl: do not use CLONE_SIGHAND with allow_signal()
      ptrace: wait_task_zombie: do not account traced sub-threads

Oliver Endriss (5):
      V4L/DVB (11759): dvb-ttpci: Add TS replay capability
      V4L/DVB (11760): dvb-ttpci: Check transport error indicator flag
      V4L/DVB (11761): dvb-ttpci: Fixed VIDEO_SLOWMOTION ioctl
      V4L/DVB (11762): dvb-ttpci: Fixed return code of av7110_av_start_pl=
ay
      V4L/DVB (11763): dvb-ttpci: Some whitespace adjustments

Oliver Neukum (1):
      USB: support for cdc-acm of single interface devices

Olivier Berger (1):
      ACPI: Remove Asus P4B266 from blacklist

Olivier Bornet (4):
      tty: iuu_phoenix: fix locking.
      tty: iuu_phoenix: Fix stopbit when uart goes on.
      tty: iuu_phoenix: set termios.
      tty: iuu_phoenix: update version number.

Ondrej Zary (2):
      floppy: fix hibernation
      agpgart: detected ALi M???? chipset with M1621

Ooiwa Naohiro (1):
      bnx2: Fix the behavior of ethtool when ONBOOT=3Dno

Oskar Schirmer (8):
      imx: serial: fix whitespaces (no changes in functionality)
      lib: isolate rational fractions helper function
      imx: serial: use rational library function
      imx: serial: use tty_encode_baud_rate to set true rate
      xtensa: cache inquiry and unaligned cache handling functions
      xtensa: s6000 dma engine support
      s6gmac: xtensa s6000 on-chip ethernet driver
      xtensa: s6105 specific configuration for s6gmac

Ozan =C3=87a=C4=9Flayan (1):
      ALSA: hda - fix audio on LG R510

PJ Waskiewicz (6):
      ixgbe: Enable another bit for flow control operation
      ixgbe: Don't return error in flow control configuration if FC is of=
f
      ixgbe: Move PHY ops initialization to centralize bus accesses
      ixgbe: Remove unnecessary PHY reset, properly identify multispeed f=
iber modules
      ixgbe: Update the usage of orig_autoc to be more consistent
      ixgbe: Add FCoE Storage MAC Address support

Pablo Neira Ayuso (15):
      net: use NLMSG_DEFAULT_SIZE in nlmsg_new() allocations
      netfilter: conntrack: add support for DCCP handshake sequence to ct=
netlink
      netfilter: nfnetlink: cleanup for nfnetlink_rcv_msg() function
      netfilter: ctnetlink: remove nowait parameter from *fill_info()
      netfilter: ctnetlink: rename tuple() by nf_ct_tuple() macro definit=
ion
      netfilter: ctnetlink: use nlmsg_* helper function to build messages
      netfilter: ctnetlink: cleanup message-size calculation
      netfilter: conntrack: don't report events on module removal
      netfilter: conntrack: remove events flags from userspace exposed fi=
le
      netfilter: conntrack: simplify event caching system
      netfilter: conntrack: replace notify chain by function pointer
      netfilter: conntrack: move event caching to conntrack extension inf=
rastructure
      netfilter: conntrack: move helper destruction to nf_ct_helper_destr=
oy()
      list_nulls: add hlist_nulls_add_head and hlist_nulls_del
      netfilter: conntrack: optional reliable conntrack event delivery

Pallipadi, Venkatesh (2):
      ACPI: Disable ARB_DISABLE on platforms where it is not needed
      ACPI: pdc init related memory leak with physical CPU hotplug

Paride Legovini (1):
      Add LED support for AR5BXB6 IBM Thinkpad PCIe adapters

Pascal Terjan (1):
      USB: Ignore storage device in modem mode on DWN-652

Patrick Boettcher (2):
      V4L/DVB (11829): Rewrote frontend-attach mechanism to gain noise-le=
ss deactivation of submodules
      V4L/DVB (11831): dib0700: added USB IDs for Terratec T3 and T5

Patrick McHardy (23):
      net: factor out ethtool invocation of vlan/macvlan drivers
      Merge branch 'master' of git://dev.medozas.de/linux
      netfilter: nf_conntrack: use per-conntrack locks for protocol data
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/davem/net-next-2.6
      netfilter: nf_ct_tcp: fix up build after merge
      netfilter: ip_tables: fix build error
      net: fix network driver ndo_start_xmit() return values (part 1)
      net: fix network drivers ndo_start_xmit() return values (part 2)
      net: fix network drivers ndo_start_xmit() return values (part 3)
      net: fix network drivers ndo_start_xmit() return values (part 4)
      net: fix network drivers ndo_start_xmit() return values (part 5)
      net: fix network drivers ndo_start_xmit() return values (part 6)
      net: fix network drivers ndo_start_xmit() return values (part 7)
      net: fix network drivers ndo_start_xmit() return values (part 8)
      net: use symbolic values for ndo_start_xmit() return codes
      netfilter: nf_log: fix sleeping function called from invalid contex=
t
      netfilter: nf_conntrack: use mod_timer_pending() for conntrack refr=
esh
      net: fix network drivers ndo_start_xmit() return values
      netfilter: nf_conntrack: fix confirmation race condition
      netfilter: nf_conntrack: fix conntrack lookup race
      netfilter: fix some sparse endianess warnings
      netfilter: nf_log: fix direct userspace memory access in proc handl=
er
      netfilter: xt_rateest: fix comparison with self

Patrick Ringl (1):
      README: fix misleading pointer to the defconf directory

Paul E. McKenney (3):
      RCU: make treercu be default
      rcu: Add __rcu_pending tracing to hierarchical RCU
      rcu: Update RCU tracing documentation for __rcu_pending

Paul Fulghum (3):
      tty: synclink_gt add receive pio mode
      tty: n_hdlc add buffer flushing
      synclink_gt: fix transmit race and timeout

Paul Mackerras (77):
      perf_counter: Fix return value from dummy hw_perf_counter_init
      perf_counter: Fix the cpu_clock software counter
      perf_counter: Add optional hw_perf_group_sched_in arch function
      perf_counter: Add dummy perf_counter_print_debug function
      powerpc/perf_counter: Add perf_counter system call on powerpc
      powerpc: Provide a way to defer perf counter work until interrupts =
are enabled
      powerpc/perf_counter: Add generic support for POWER-family PMU hard=
ware
      powerpc/perf_counter: Add support for PPC970 family
      powerpc/perf_counter: Add support for POWER6
      perf_counter: Always schedule all software counters in
      powerpc/perf_counter: Make sure PMU gets enabled properly
      perf_counter: Add support for pinned and exclusive counter groups
      perf_counter: Add counter enable/disable ioctls
      perf_counters: make software counters work as per-cpu counters
      perf_counters: allow users to count user, kernel and/or hypervisor =
events
      perfcounters: fix refcounting bug, take 2
      perfcounters: make context switch and migration software counters w=
ork again
      perfcounters/powerpc: Make exclude_kernel bit work on Apple G5 proc=
essors
      perfcounters/powerpc: Add support for POWER5 processors
      perfcounters: fix a few minor cleanliness issues
      perfcounters: provide expansion room in the ABI
      perfcounters/powerpc: fix oops with multiple counters in a group
      perfcounters/powerpc: add support for POWER5+ processors
      perfcounters/powerpc: add support for POWER4 processors
      perf_counter: abstract wakeup flag setting in core to fix powerpc b=
uild
      perf_counter: powerpc: clean up perc_counter_interrupt
      perf_counter: fix type/event_id layout on big-endian systems
      perf_counter: add an mmap method to allow userspace to read hardwar=
e counters
      perf_counter tools: remove glib dependency and fix bugs in kernelto=
p.c
      perf_counter: update documentation
      perf_counter: record time running and time enabled for each counter
      perf_counter: powerpc: only reserve PMU hardware when we need it
      perf_counter: make it possible for hw_perf_counter_init to return e=
rror codes
      perf_counter tools: optionally scale counter values in perfstat mod=
e
      perf_counter: fix powerpc build
      perf_counter: powerpc: set sample enable bit for marked instruction=
 events
      perf_counter: add MAINTAINERS entry
      perf_counter: powerpc: add nmi_enter/nmi_exit calls
      perf_counter: powerpc: allow use of limited-function counters
      perf_counter: update copyright notice
      perf_counter: Put whole group on when enabling group leader
      perf_counter: don't count scheduler ticks as context switches
      perf_counter: call atomic64_set for counter->count
      perf_counter: call hw_perf_save_disable/restore around group_sched_=
in
      perf_counter: powerpc: use u64 for event codes internally
      perf_counter: allow arch to supply event misc flags and instruction=
 pointer
      perf_counter: powerpc: supply more precise information on counter o=
verflow events
      perf_counter: powerpc: initialize cpuhw pointer before use
      perf_counter: Dynamically allocate tasks' perf_counter_context stru=
ct
      perf_counter: Optimize context switch between identical inherited c=
ontexts
      perf_counter: powerpc: Implement interrupt throttling
      perf_counter: Fix race in attaching counters to tasks and exiting
      perf_counter: Don't swap contexts containing locked mutex
      perf_counter: Provide functions for locking and pinning the context=
 for a task
      perf_counter: Allow software counters to count while task is not ru=
nning
      perf_counter: Initialize per-cpu context earlier on cpu up
      perf_counter: Fix cpu migration counter
      perf_counter: Remove unused prev_state field
      perf_counter: powerpc: Fix event alternative code generation on POW=
ER5/5+
      perf_counter: powerpc: Fix race causing "oops trying to read PMC0" =
errors
      perf_counter: powerpc: Use new identifier names in powerpc-specific=
 code
      perf_counter: Fix lockup with interrupting counters
      perf_counters: powerpc: Add support for POWER7 processors
      perf_counter: powerpc: Implement generalized cache events for POWER=
 processors
      perf_counter: Fix atomic_set vs. atomic64_t type mismatch
      powerpc: Add compiler memory barrier to mtmsr macro
      lib: Provide generic atomic64_t implementation
      powerpc: Use generic atomic64_t implementation on 32-bit processors
      perf_counter: powerpc: Fix two compile warnings
      perf_counter: Make set_perf_counter_pending() declaration common
      perf_counter: powerpc: Enable use of software counters on 32-bit po=
werpc
      perf_counter: powerpc: Use unsigned long for register and constrain=
t values
      perf_counter: powerpc: Change how processor-specific back-ends get =
selected
      perf_counter: powerpc: Make powerpc perf_counter code safe for 32-b=
it kernels
      perf_counter: powerpc: Add processor back-end for MPC7450 family
      perf_counter: tools: Makefile tweaks for 64-bit powerpc
      perf_counter tools: Define and use our own u64, s64 etc. definition=
s

Paul Menzel (3):
      fbdev: add video modes for resolutions and timings of PAL RGB
      Documentation/fb/vesafb.txt: fix typo
      intelfb: fix a bug when changing video timing

Paul Mundt (200):
      sh: sh7724: Add CMT clockevents support.
      sh: Have SH7724 select ARCH_SHMOBILE.
      sh: Add a generic defconfig for SH7724 platforms.
      sh: drop duplicate symbol export on dreamcast and sh7785lcr.
      sh: sh7785lcr: Update for recent PCI changes.
      sh: pci: drop duplicate PCIC fixups for SE7780 and SH7785LCR.
      sh: pci: Kill off unused SH4_PCIC_NO_RESET code.
      sh: pci: Kill off useless debugging printk() in pci-sh7780 init.
      sh: pci: Move se7780 INTC fixups out of pci-sh7780.c.
      sh: pci: Prefer P1SEG over P1SEGADDR for CONFIG_CMD.
      sh: pci: Set class/sub-class code correctly for SH7780 PCIC.
      sh: pci: Rework SH7780 host controller detection.
      sh: pci: Use the proper write size for class/sub-class code.
      sh: pci: Set pci_cache_line_size on SH7780 via the PCICLS register.
      sh: pci: Set the I/O port base to the SH7780 I/O window default.
      sh: pci: Consolidate PCI I/O and mem window definitions for SH7780.
      sh: pci: Kill off platform-specific multi-window mappings.
      sh: pci: Consolidate SH7780 PCIC IRQ routing.
      sh: pci: Start unifying the SH7780 PCIC initialization.
      Merge branches 'sh/earlytimer' and 'sh/shmobile-r2r-staging'
      sh: sh7724: Don't default enable the RTC clock.
      sh: sh7724: Register CMT as an early platform device here too.
      sh: pci: Drop asm-generic/pci.h, so we can use our own fixups.
      sh: pci: Split out new-style PCI core.
      sh: pci: HAVE_PCI_MMAP support.
      sh: pci: Consolidate pcibios_align_resource() definitions.
      sh: pci: Kill off unused pcibios_fixup().
      sh: pci: Consolidate pci_iomap() and use the generic I/O base.
      sh: pci: Rework fixed region checks in ioremap().
      sh: pci: New-style controller registration.
      sh: pci: Track io and mem_offset per-channel.
      sh: pci: Consolidate bus<->resource mapping in pci-lib.
      sh: pci: Consolidate the remaining common bits.
      sh: pci: Kill off the now unused hose->io_base.
      sh: pci: Kill off superfluous lboxre2 pci fixups.
      sh: pci: Flag the dreamcast BBA as IORESOURCE_PCI_FIXED.
      sh: pci: Kill off dead references to is_pci_ioaddr and friends.
      sh: pci: Consolidate pcibios_setup() in pci-lib.
      sh: pci: Kill off legacy ide quirks.
      sh: pci: Tidy up the dreamcast PCI support.
      sh: pci: Convert the SH-5 code over to the new interface.
      sh: pci: Rename ops-cayman -> fixups-cayman.
      sh: pci: Rewrite SH7751 PCI support to follow SH7780.
      sh: pci: Rename SH7751 platform ops files to fixups.
      sh: pci: Consolidate lboxre2 and r2d IRQ fixups.
      sh: pci: Convert dreamcast to new-style interface.
      sh: pci: Move the se7751 fixups in to arch/sh/drivers/pci/.
      sh: pci: Kill off the last remnants of the now unused pci-auto code.
      sh: pci: Roll pci-lib in to pci-new.
      sh: pci: Rename pci-new.c to pci.c.
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6
      sh: pci: Fix up the build for CONFIG_PCI=3Dn.
      Merge branches 'sh/stable-updates' and 'sh/pci-rework'
      sh: update defconfigs for PCI changes.
      sh: select GENERIC_TIME for new CMT driver.
      sh: rtc-generic support.
      sh: register the rtc-generic platform device properly.
      Merge branch 'timers/clocksource' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/x86/linux-2.6-tip
      sh: Consolidate MTU2/CMT/TMU timer platform data.
      clocksource: sh_mtu2/cmt_register() should be static.
      sh: select both GENERIC_TIME and GENERIC_CLOCKEVENTS.
      sh: Kill off the now unused ARCH_USES_GETTIMEOFFSET code.
      sh: Move dummy clockevents broadcast timer to its new home.
      sh: Flag IRQSTACKS as BROKEN for now.
      sh: Handle shm_align_mask also for HAVE_ARCH_UNMAPPED_AREA_TOPDOWN.
      sh: sh64 still needs ARCH_USES_GETTIMEOFFSET temporarily.
      sh: Integrate the SH-5 onchip_remap() more coherently.
      sh: Kill off unused SH-5 irq_describe cruft.
      sh: Enable new TMU driver support for all SH-3 and SH-4 CPUs.
      sh: Move out rtc-sh registration from time_64.c to setup-sh5.c
      sh: Finish the sh64 migration off of ARCH_USES_GETTIMEOFFSET.
      sh: Rename arch/sh/kernel/time_32.c to arch/sh/kernel/time.c.
      sh: Wire up GENERIC_CMOS_UPDATE for the platforms that need it.
      sh: Kill off dead handle_timer_tick() code.
      sh: Kill off dead timer sysclass pm hooks.
      sh: mach-sh03: Give the sh03 rtc its own spinlock.
      sh: Kill off the global rtc_lock with extreme prejudice.
      sh: Kill off sh64's hand-rolled syscall tracer.
      sh: Kill off unused sh64 debug code.
      sh: Move out cayman-specific panic handler code to its own file.
      sh: Drop dead rules from arch/sh/kernel/Makefile_64.
      sh: Always select RTC_LIB, not just for SUPERH32.
      sh: Kill off extra cflags Kconfig entry.
      sh: Always fixup unaligned userspace accesses on sh64.
      sh: TMU platform data for SH7786.
      sh: TMU platform data for SH-X3 proto CPU.
      sh: Kill off the GENERIC_CALIBRATE_DELAY ifndef.
      sh: Add clock id to sh-sci platform data on SH-Mobile CPUs.
      serial: sh-sci: Fix up section mismatch in error path.
      sh: Fix up the sh64 earlyprintk build.
      sh: Cleanup irqflags size mismatch on SH-5 build.
      sh: Provide __read_{read,write}sl() definitions for sh64.
      sh: Rename opcode_t to insn_size_t.
      sh: Provide an __sdivsi3_2 export for sh64.
      sh: Fix up SHmedia module ELF relocations.
      sh: Integrate sh64 bits in vmlinux_32.lds.S.
      sh: Move the unified linker script in place, kill off old _64 one.
      sh: Tidy up the ldscript output format specifier.
      sh: Fix up the sh64 zImage build.
      sh: Provide a tighter BOOT_LINK_OFFSET definition for the Cayman bo=
ard.
      sh: Provide a BITS definition, use it in the arch/sh/boot/ Makefile=
s.
      sh: Merge the split arch/sh/boot/compressed/ Makefiles.
      sh: Consolidate the boot link and entry offset definitions.
      sh: Hook up cc-cross-prefix support.
      sh: Fix up R0 dependence in __arch_swab16/32.
      sh: Fix up typo in arch/sh/kernel/vmlinux.lds.S
      sh: Account for INITIAL_JIFFIES when using jiffies clocksource.
      sh: clkfwk: Make recalc return an unsigned long.
      sh: clkfwk: Add a followparent_recalc() helper.
      sh: clkfwk: refactor rate propagation.
      sh: clkfwk: Consolidate the ALWAYS_ENABLED / NEEDS_INIT mess.
      sh: clkfwk: Convert SH-Mobile CPUs to use CLK_ENABLE_ON_INIT.
      sh: clkfwk: Fix up the clk_enable() error path.
      sh: clkfwk: Improve the generic clk_set_parent() implementation.
      sh: clkfwk: Tidy up on-chip clock registration and rate propagation.
      sh: clkfwk: Kill off clk_recalc_rate().
      sh: clkfwk: Wire up clk_get_sys() support.
      sh: clkfwk: Handle clk_get_sys() returning an ERR_PTR.
      sh: clkfwk: Use arch_clk_init() for on-chip clock registration.
      sh: Kill off the remnants of the old timer code.
      Merge branch 'master' into sh/clkfwk
      sh: clkfwk: module_clk -> peripheral_clk rename.
      sh: clkfwk: Handle NULL clkops for root clocks.
      sh: clkfwk: Provide a generic clk_set_rate_ex() path for root clock=
s.
      sh: clkfwk: Rework legacy CPG clock handling.
      sh: clkfwk: Update SH7785 for refactored clock framework.
      sh: clkfwk: rate table construction and rounding for SH7785.
      sh: clkfwk: Map tree hierarchy in debugfs.
      sh: clkfwk: Add MSTP bits to SH7785 clock framework.
      sh: Provide FORCE_MAX_ZONEORDER.
      sh: hd64461: Fix up I/O base register offsets.
      sh: mach-hp6xx: Fix up the hp6xx build for hd64461 changes.
      sh: irq: Rework the SR.IMASK bitmap handling.
      sh: irq: Convert from irq_desc[] to irq_to_desc().
      sh: irq: Teach ipr and intc about dynamically allocating irq_descs.
      sh: irq: Provide an arch_probe_nr_irqs() that wraps the machvec def.
      Merge branches 'sh/stable-updates' and 'sh/sparseirq'
      sh: Wrap irq_to_desc_alloc_cpu() around CONFIG_SPARSE_IRQ temporari=
ly.
      sh: Add a NR_IRQS_LEGACY for external IRQ0-7.
      sh: clkfwk: Make clock-cpg usable for non-legacy platforms.
      sh: Prefer slab_is_available() over after_bootmem.
      sparseirq: Allow early irq_desc allocation
      sh: irq: Fix up imask build warnings.
      sh: Record ms7724se in mach-types.
      sh: Add a KBUILD_DEFCONFIG for sh64.
      sh: pci-sh7751: Initialize io_map_base in controller definition.
      sh: pci: Disable MWI and make pci_dma_burst_advice() a bit more acc=
urate.
      Merge branch 'sh/clkfwk'
      sh: pci-sh7780: Fix up for PCI_DISABLE_MWI changes.
      sh: Tidy up the optional L2 probing, wire it up for SH7786.
      sh: Tidy up SH-4A boot_cpu_data.flags probing.
      nommu: Provide mmap_min_addr definition.
      sh: plug vsyscall dir in to archclean.
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6
      sh: Fix sys_pwritev() syscall table entry for sh32.
      sh: Wire up sys_rt_tgsigqueueinfo.
      sh: Tie sparseirq in to Kconfig.
      Merge branch 'sh/ftrace' of git://github.com/mfleming/linux-2.6
      sh: Wire up sys_perf_counter_open.
      sh: intc: alloc_bootmem() -> kzalloc() conversion.
      sh: Bump the earlytimer bits back to time_init().
      sh: Use generic sched_clock().
      sh: Bump the earlytimer probe devices up.
      clocksource: Drop unused irqaction.mask from SH drivers.
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6
      sh: Convert to asm-generic/current.h.
      sh: Convert to asm-generic/dma.h.
      sh: Convert to asm-generic/posix_types.h.
      sh: Convert to asm-generic/termbits.h and termios.h.
      sh: Convert ipc/shm bits to their asm-generic versions.
      sh: Tidy up duplication in irq/swab/timex.h.
      sh: Conver to asm-generic/mmu_context.h.
      sh: Convert to asm-generic/module.h.
      sh: Convert to asm-generic/unaligned.h.
      sh: Convert to asm-generic/scatterlist.h.
      sh: Convert to asm-generic/types.h.
      sh: Convert to asm-generic/signal.h.
      sh: Switch to asm-generic versions for identical headers.
      sh: Derive COMMAND_LINE_SIZE from asm-generic/setup.h.
      sh: Convert sh64 to use the generic checksum code.
      serial: sh-sci: Move over to dev_pm_ops.
      sh: urquell: Add system FPGA mode pin support.
      sh: Set EARLY_SCIF_CONSOLE_PORT sanely for SH7786.
      sh: pci: Allow register_pci_controller() to handle overlapping regi=
ons.
      sh: pci: SH7786 PCI ops.
      wusb: hwa-hc: Drop unused pci_suspend/resume hooks.
      USB: xhci depends on PCI.
      sh: Use generic atomic64_t implementation.
      sh: Generic HAVE_PERF_COUNTER support.
      Merge branches 'sh/pci-express-integration', 'sh/rsk-updates', 'sh/=
platform-updates' and 'sh/perf_counter'
      sh: pci: Initial PCI-Express support for SH7786 Urquell board.
      sh: defconfig updates.
      sh: Enable soc-camera in ap325rxa/migor/se7724 defconfigs.
      sh: Provide cpu_idle_wait() to fix up cpuidle/SMP build.
      sh: Use local TLB flush in set_pte_phys().
      sh: Wire up the uncached fixmap on sh64 as well.
      sh: SH7786 SMP support.
      sh: Fix up more dma-mapping fallout.
      asm-generic: add dummy pgprot_noncached()
      sh: Fix up HAVE_PERF_COUNTERS typo.

Paul Turner (1):
      sched: remove redundant hierarchy walk in check_preempt_wakeup

Paul Walmsley (18):
      OMAP3 SRAM: mark OCM RAM as Non-cacheable Normal memory
      OMAP3 SRAM: add ARM barriers to omap3_sram_configure_core_dpll
      OMAP3 clock: add interconnect barriers to CORE DPLL M2 change
      OMAP3 SRAM: clear the SDRC PWRENA bit during SDRC frequency change
      OMAP3 SDRC: initialize SDRC_POWER at boot
      OMAP3 SRAM: renumber registers to make space for argument passing
      OMAP3 clock: only unlock SDRC DLL if SDRC clk < 83MHz
      OMAP3 clock: use pr_debug() rather than pr_info() in some clock cha=
nge code
      OMAP2xxx clock: rename clk_init_one() to clk_preinit()
      ARM: OMAP3: SDRC: add timing data for Micron MT46H32M32LF-6, v2
      ARM: OMAP3: SDRC: add timing data for Qimonda HYB18M512160AF-6
      OMAP3 clock: remove wait for DPLL3 M2 clock to stabilize
      OMAP3 clock: initialize SDRC timings at kernel start
      OMAP3 clock: add a short delay when lowering CORE clk rate
      OMAP3 clock/SDRC: program SDRC_MR register during SDRC clock change
      OMAP3 SRAM: add more comments on the SRAM code
      OMAP3 SRAM: convert SRAM code to use macros rather than magic numbe=
rs
      OMAP3 SDRC: set FIXEDDELAY when disabling SDRC DLL

Paulius Zaleckas (3):
      wimax: Add netlink interface to get device state
      hso: convert dev_alloc_skb() to netdev_alloc_skb()
      trivial: mtd: fix Kconfig comment about 'armflash'

Pavel Machek (5):
      SubmittingPatches: fix typo
      [ARM] pxa/sharpsl_pm: zaurus needs generic pxa suspend/resume routi=
nes
      trivial: Fix Pavel's address in MAINTAINERS
      trivial: SubmittingPatches: fix typo
      trivial: Kconfig: .ko is normally not included in module names

Pavel Roskin (3):
      ath5k: fix scanning in AR2424
      cfg80211: fix compile error with CONFIG_CFG80211_DEBUGFS
      intelfb: fix spelling of "CLOCK"

Pekka Enberg (67):
      x86: move x86_quirk_pre_intr_init() to irqinit_32.c
      x86: move init_ISA_irqs() in irqinit_32.c to match ordering in irqi=
nit_64.c
      x86: introduce smp_intr_init() in irqinit_32.c
      x86: introduce apic_intr_init() in irqinit_32.c
      x86: use identical loop constructs in 32-bit and 64-bit native_init=
_IRQ()
      x86: unify smp_intr_init() in irqinit_{32,64}.h
      x86: unify init_ISA_irqs() in irqinit_{32,64}.c
      x86: unify native_init_IRQ() in irqinit_{32,64}.c
      x86: unify trivial differences in irqinit_{32,64}.c
      x86: unify apic_intr_init() in irqinit_{32,64}.c
      x86: unify irqinit_{32,64}.c into irqinit.c
      x86: define IA32_SYSCALL_VECTOR on 32-bit to reduce ifdefs
      x86: remove some ifdefs from native_init_IRQ()
      x86: unify noexec handling
      x86: move max_pfn_mapped and max_low_pfn_mapped to setup.c
      x86: move per-cpu mmu_gathers to mm/init.c
      x86: unify 64-bit UMA and NUMA paging_init()
      x86: use sparse_memory_present_with_active_regions() on UMA
      kmemtrace: fix kernel parameter documentation
      slab: document kzfree() zeroing behavior
      perf report: Add support for profiling JIT generated code
      SLUB: Out-of-memory diagnostics
      bootmem: use slab if bootmem is no longer available
      bootmem: fix slab fallback on numa
      slab: setup allocators earlier in the boot sequence
      vmalloc: use kzalloc() instead of alloc_bootmem()
      init: introduce mm_init()
      sched: use kzalloc() instead of the bootmem allocator
      vt: use kzalloc() instead of the bootmem allocator
      sched: use alloc_cpumask_var() instead of alloc_bootmem_cpumask_var=
()
      sched: use slab in cpupri_init()
      irq: use kcalloc() instead of the bootmem allocator
      vgacon: use slab allocator instead of the bootmem allocator
      slab: fix gfp flag in setup_cpu_cache()
      slab,slub: don't enable interrupts during early boot
      slab: setup cpu caches later on when interrupts are enabled
      slab: move struct kmem_cache to headers
      kmemcheck: add Vegard and Pekka to MAINTAINERS
      SLUB: Don't print out OOM warning for __GFP_NOFAIL
      kmemcheck: remove forward declarations from error.c
      kmemcheck: make initialization message less confusing
      kmemcheck: remove multiple ifdef'd definitions of the same global v=
ariable
      kmemcheck: move 64-bit ifdef out of kmemcheck_opcode_decode()
      kmemcheck: use kmemcheck_pte_lookup() instead of open-coding it
      slab: add hooks for kmemcheck
      kmemcheck: make kconfig accessible for other architectures
      Merge branches 'slab/documentation', 'slab/fixes', 'slob/cleanups' =
and 'slub/fixes' into for-linus
      Merge branch 'slub/earlyboot' into for-linus
      Staging: w35und: remove unused code from wbsoft_configure_filter()
      Staging: w35und: replace switch error handling with gotos in wb35_h=
w_init()
      Staging: w35und: move hal_init_hardware() and hal_halt() int wbusb.=
c
      Staging: w35und: simplify error handling in wb35_hw_init()
      Staging: w35und: simplify hal_init_hardware() error handling
      Staging: w35und: more simplify hal_init_hardware() error handling
      Staging: w35und: simplify hal_init_hardware() and hal_halt()
      Staging: w35und: clean up comments in wbusb.c
      Staging: w35und: inline hal_set_phy_type() to wb35_hw_init()
      Staging: w35und: reformat wbusb.c
      Staging: w35und: remove MODULE_AUTHOR
      Staging: w35und: make led lookup tables static
      Staging: w35und: reformat wbhal.c
      Staging: w35und: merge wbhal.c to wbusb.c
      Staging: w35und: inline hal_set_rf_power() to mto.c
      Staging: w35und: merge rest of wbhal.c to phy_calibration.c
      [S390] s390: remove DEBUG_MALLOC
      eeepc-laptop: enable camera by default
      SLUB: Don't pass __GFP_FAIL for the initial allocation

Pete Zaitcev (1):
      USB: janitor storage initializers

Peter 'p2' De Schrijver (1):
      OMAP3: PM: Ensure MUSB block can idle when driver not loaded

Peter Feuerer (1):
      acerhdf: Acer Aspire One fan control

Peter Griffin (2):
      sh: Add ptrace support for NOMMU debugging
      sh: Add UBC trap vector for SH2A

Peter Holik (2):
      export usbnet_get_ethernet_addr from usbnet and fixed cdc_ether.c
      usb driver for intellon int51x1 based PLC like devolo dlan duo

Peter Huewe (2):
      trivial: pci hotplug: adding __init/__exit macros to sgi_hotplug
      RDMA: Add __init/__exit macros to addr.c and cma.c

Peter Korsgaard (9):
      dm9601: trivial comment fixes
      smsc95xx: strip ethernet fcs (crc) on receive path
      mtd: nand: s3c2410_nand_setrate(): use correct macros for 2412/2440
      mtd/nand: s3c6400 support for s3c2410 driver
      kconfig: handle comment entries within choice/endchoice
      powerpc/mpc83xx: Fix usb mux setup for mpc834x
      [ARM] S3C64XX: fix HCLK gate defines
      [ARM] S3C64XX: clock.c: fix typo in usb-host clock ctrlbit
      serial: samsung.c: mark s3c24xx_serial_remove as __devexit

Peter Ma (2):
      avr32: Change Atmel ATNGW100 config to add choice of add-on board
      avr32: Add support for Mediama RMTx add-on board for ATNGW100

Peter Oberparleiter (4):
      kernel: constructor support
      seq_file: add function to write binary data
      gcov: add gcov profiling infrastructure
      gcov: enable GCOV_PROFILE_ALL for x86_64

Peter P Waskiewicz Jr (21):
      ixgbe: Update get_physical_layer() calls, plus a version bump
      ixgbe: Set Priority Flow Control low water threshhold for DCB
      ixgbe: Allow link flow control in DCB mode for 82599 adapters
      ixgbe: When in DCB mode with PFC enabled, show LFC is disabled
      ixgbe: Don't reset the hardware when switching between LFC and PFC
      ixgbe: Add generic XAUI support to 82599
      ixgbe: Increase the driver version number
      ixgbe: Add semaphore access for PHY initialization for 82599
      ixgbe: Change Direct Attach Twinax cable detection for SFP+ NICs
      ixgbe: Remove device ID 0x10d8
      ixgbe: Fix build warning
      ixgbe: Enable ACPI WoL capabilities for 82599
      ixgbe: Change the 82599 PHY DSP restart logic
      ixgbe: Add ethtool offline test support
      ixgbe: Harden the 82599 multispeed fiber autotry mechanism
      ixgbe: Add a second feature flags variable, move HW RSC capability =
there
      ixgbe: Add hardware defines for Flow Director for 82599
      ixgbe: Add Flow Director init and modify functions for 82599
      ixgbe: Enable Flow Director hashing in 82599
      ixgbe: Add FW detection and warning for 82599 SFP+ adapters
      ixgbe: Increase the driver version number

Peter Rajnoha (1):
      dm: sysfs add suspended attribute

Peter Ujfalusi (20):
      ASoC: tlv320aic23: add DSP_A format support
      ASoC: OMAP: Use single-phase for DSP mode
      ASoC: OMAP: Add DSP_A mode support for mcbsp
      ASoC: TWL4030: Fix for the constraint handling
      ASoC: OMAP: Add 4 channel support to mcbsp
      ASoC: TWL4030: Add 4 channel TDM support
      ASoC: Beagle: Add support for 4 channel
      ASoC: TWL4030: Add VIBRA output
      ASoC: TWL4030: Fix typo in twl4030_codec_mute function
      ASoC: TWL4030: Fix Analog capture path for AUXR
      ASoC: TWL4030: Change DAPM routings and controls for DACs and PGAs
      ASoC: TWL4030: Move the Headset pop-attenuation code to PGA event
      ASoC: TWL4030: Add support for platform dependent configuration
      ASoC: SDP4030: Use the twl4030_setup_data for headset pop-removal
      ASoC: TWL4030: Differentiate the playback streams
      ASoC: TWL4030: Handsfree pop removal redesign
      ASoC: TWL4030: Add shadow register
      ASoC: TWL4030: HandsfreeL/R mute DAPM switch
      ASoC: TWL4030: Use reg_cache in twl4030_init_chip
      ASoC: TWL4030: Check the interface format for 4 channel mode

Peter Zijlstra (211):
      perfcounters: IRQ and NMI support on AMD CPUs
      perfcounters: IRQ and NMI support on AMD CPUs, fix
      x86: perf_counter cleanup
      perf_counter: x86: fix 32-bit irq_period assumption
      perf_counter: use list_move_tail()
      perf_counter: add comment to barrier
      perf_counter: x86: use ULL postfix for 64bit constants
      perf_counter: software counter event infrastructure
      perf_counter: provide pagefault software events
      perf_counter: provide major/minor page fault software events
      perf_counter: hrtimer based sampling for software time events
      perf_counter: add an event_list
      perf_counter: fix hrtimer sampling
      perf_counter: fix uninitialized usage of event_list
      perf_counter: generic context switch event
      perf_counter: fix up counter free paths
      perf_counter: hook up the tracepoint events
      perf_counter: revamp syscall input ABI
      perf_counter: unify irq output code
      perf_counter: remove the event config bitfields
      perf_counter: avoid recursion
      perf_counter: new output ABI - part 1
      perf_counter tools: update to new syscall ABI
      perf_counter tools: use mmap() output
      perf_counter tools: remove glib dependency and fix bugs in kernelto=
p.c, fix poll()
      perf_counter: fix perf_poll()
      perf_counter: more elaborate write API
      perf_counter: output objects
      perf_counter: sanity check on the output API
      perf_counter: optionally provide the pid/tid of the sampled task
      perf_counter: kerneltop: mmap_pages argument
      perf_counter: kerneltop: output event support
      perf_counter: allow and require one-page mmap on counting counters
      perf_counter: unify and fix delayed counter wakeup
      perf_counter: fix update_userpage()
      perf_counter: kerneltop: simplify data_head read
      perf_counter: executable mmap() information
      perf_counter: kerneltop: parse the mmap data stream
      perf_counter: x86: proper error propagation for the x86 hw_perf_cou=
nter_init()
      perf_counter: small cleanup of the output routines
      perf_counter: re-arrange the perf_event_type
      perf_counter tools: kerneltop: update event_types
      perf_counter: provide generic callchain bits
      perf_counter: x86: callchain support
      perf_counter: pmc arbitration
      perf_counter: move the event overflow output bits to record_type
      perf_counter: per event wakeups
      perf_counter: kerneltop: update to new ABI
      perf_counter: add more context information
      perf_counter: update mmap() counter read
      perf_counter: update mmap() counter read, take 2
      perf_counter: add more context information
      perf_counter: SIGIO support
      perf_counter: generalize pending infrastructure
      perf_counter: x86: self-IPI for pending work
      perf_counter: theres more to overflow than writing events
      perf_counter: fix the mlock accounting
      perf_counter: PERF_RECORD_TIME
      perf_counter: counter overflow limit
      perf_counter: comment the perf_event_type stuff
      perf_counter: change event definition
      perf_counter: rework context time
      perf_counter: rework the task clock software counter
      perf_counter: remove rq->lock usage
      perf_counter: minimize context time updates
      perf_counter: fix NMI race in task clock
      perf_counter: provide misc bits in the event header
      perf_counter: use misc field to widen type
      perf_counter: kerneltop: keep up with ABI changes
      perf_counter: add some comments
      perf_counter: track task-comm data
      perf_counter: some simple userspace profiling
      perf_counter: move PERF_RECORD_TIME
      perf_counter: allow for data addresses to be recorded
      perf_counter: optimize mmap/comm tracking
      perf_counter: sysctl for system wide perf counters
      perf_counter: log full path names
      sched: remove extra call overhead for schedule()
      perf_counter tools: fix Documentation/perf_counter build error
      perf_counter: fix race in perf_output_*
      perf_counter: fix nmi-watchdog interaction
      perf_counter: tool: handle 0-length data files
      perf_counter: documentation update
      perf_counter: x86: fixup nmi_watchdog vs perf_counter boo-boo
      sched: rt: document the risk of small values in the bandwidth setti=
ngs
      perf_counter: uncouple data_head updates from wakeups
      perf_counter: add ioctl(PERF_COUNTER_IOC_RESET)
      perf_counter: provide an mlock threshold
      perf_counter: fix the output lock
      perf_counter: inheritable sample counters
      perf_counter: tools: update the tools to support process and inheri=
ted counters
      perf_counter: optimize perf_counter_task_tick()
      perf_counter: rework ioctl()s
      perf_counter: add PERF_RECORD_CONFIG
      perf_counter: add PERF_RECORD_CPU
      perf_counter: fix print debug irq disable
      perf_counter: x86: More accurate counter update
      perf_counter: x86: Allow unpriviliged use of NMIs
      perf_counter: Fix perf_output_copy() WARN to account for overflow
      perf_counter: x86: Fix up the amd NMI/INT throttle
      perf_counter: Rework the perf counter disable/enable
      perf_counter: x86: Robustify interrupt handling
      perf_counter: remove perf_disable/enable exports
      perf_counter: per user mlock gift
      perf_counter: frequency based adaptive irq_period
      perf top: update to use the new freq interface
      perf_counter: frequency based adaptive irq_period, 32-bit fix
      perf_counter: Fix inheritance cleanup code
      perf_counter: Fix counter inheritance
      perf_counter: Solve the rotate_ctx vs inherit race differently
      perf_counter: Log irq_period changes
      perf_counter: Optimize disable of time based sw counters
      perf_counter: Optimize sched in/out of counters
      perf_counter: Fix dynamic irq_period logging
      perf_counter: Sanitize counter->mutex
      perf_counter: Sanitize context locking
      perf_counter: Fix userspace build
      perf_counter: Simplify context cleanup
      perf_counter: Change pctrl() behaviour
      perf_counter: Remove perf_counter_context::nr_enabled
      perf_counter: Fix perf-$cmd invokation
      perf_counter: Remove unused ABI bits
      perf_counter: Make pctrl() affect inherited counters too
      perf_counter: Propagate inheritance failures down the fork() path
      perf_counter: Fix PERF_COUNTER_CONTEXT_SWITCHES for cpu counters
      perf_counter: x86: Expose INV and EDGE bits
      perf_counter: x86: Remove interrupt throttle
      perf_counter: Generic per counter interrupt throttle
      perf report: Fix segfault on unknown symbols
      perf report: Fix ELF symbol parsing
      perf report: More robust error handling
      perf_counter: tools: /usr/lib/debug%s.debug support
      perf_counter: tools: report: Add vmlinux support
      perf_counter: tools: report: Rework histogram code
      perf_counter: tools: report: Dynamic sort/print bits
      pref_counter: tools: report: Add --sort option
      perf_counter: tools: report: Add comm sorting
      pref_counter: tools: report: Add dso sorting
      perf_counter tools: report: Implement header output for --sort vari=
ants
      perf_counter: Fix COMM and MMAP events for cpu wide counters
      perf_counter: Clean up task_ctx vs interrupts
      perf_counter: Ammend cleanup in fork() fail
      perf_counter: Use PID namespaces properly
      perf_counter: tools: Expand the COMM,MMAP event synthesizer
      perf_counter: tools: Better handle existing data files
      perf_counter tools: Remove the last nmi bits
      x86: Fix atomic_long_xchg() on 64bit
      perf_counter: Add unique counter id
      perf_counter: Rename various fields
      perf_counter: Remove the last nmi/irq bits
      perf_counter: x86: Emulate longer sample periods
      perf_counter: Change data head from u32 to u64
      perf_counter: Add ioctl for changing the sample period/frequency
      perf_counter: Rename perf_counter_hw_event =3D> perf_counter_attr
      perf_counter tools: Fix up the ABI shakeup
      perf report: Separate out idle threads
      perf_counter: Add a comm hook for pure fork()s
      perf record: Use long arg for counter period
      perf report: Fix comm sorting
      perf_counter: Fix race in counter initialization
      perf report: Simplify symbol output
      perf report: Add consistent spacing rules
      perf_counter: Add fork event
      perf_counter: Remove munmap stuff
      perf_counter tools: Use fork and remove munmap events
      x86: Set context.vdso before installing the mapping
      perf_counter: Generate mmap events for install_special_mapping()
      perf report: Deal with maps
      perf_counter: Change PERF_SAMPLE_CONFIG into PERF_SAMPLE_ID
      perf_counter: Add PERF_SAMPLE_PERIOD
      perf_counter: Fix frequency adjustment for < HZ
      perf_counter: Add mmap event hooks to mprotect()
      ring-buffer: pass in lockdep class key for reader_lock
      perf_counter: More aggressive frequency adjustment
      perf_counter tools: Small frequency related fixes
      perf_counter tools: Propagate signals properly
      perf_counter: Annotate exit ctx recursion
      perf_counter tools: Normalize data using per sample period data
      perf_counter: Introduce struct for sample data
      perf_counter: Accurate period data
      perf_counter: More paranoia settings
      perf_counter: Rename perf_counter_limit sysctl
      perf_counter: Rename enums
      perf_counter: Standardize event names
      perf_counter: Rename L2 to LL cache
      perf_counter: Add counter->id to the throttle event
      perf_counter: PERF_TYPE_HW_CACHE is a hardware counter too
      perf_counter: Remove PERF_TYPE_RAW special casing
      perf record: Explicity program a default counter
      perf_counter: Add forward/backward attribute ABI compatibility
      perf_counter: Fix ctx->mutex vs counter->mutex inversion
      x86, mm: Add __get_user_pages_fast()
      x86: Add NMI types for kmap_atomic
      perf_counter: x86: Fix call-chain support to use NMI-safe methods
      x86: Add NMI types for kmap_atomic, fix
      page allocator: calculate the alloc_flags for allocation only once
      sched, x86: Fix cpufreq + sched_clock() TSC scaling
      perf report: Add --sort <call> --call <$regex>
      perf_counter: x86: Set the period in the intel overflow handler
      perf_counter tools: Replace isprint() with issane()
      perf_counter tools: Add and use isprint()
      fs: Provide empty .set_page_dirty() aop for anon inodes
      perf_counter: Add event overlow handling
      perf_counter tools: Handle lost events
      perf_counter: Make callchain samples extensible
      perf_counter: Update userspace callchain sampling uses
      perf_counter tools: Add a data file header
      perf_counter: Simplify and fix task migration counting
      perf_counter: Close race in perf_lock_task_context()
      perf_counter: Push perf_sample_data through the swcounter code
      lockdep: Select frame pointers on x86

Petr Tesarik (1):
      x86: move rdtsc_barrier() into the TSC vread method

Philipp Reisner (1):
      drbd: add major number to major.h

Philipp Zabel (24):
      [ARM] pxa: allow IRQ_BOARD_END to be customized and make zylonite t=
o use it
      [ARM] pxa/magician: use I2C fast mode
      [ARM] pxa/magician: use ARRAY_AND_SIZE for platform_add_devices
      [ARM] pxa: add basic support for HP iPAQ hx4700 PDAs
      [ARM] pxa: magician_defconfig enable hx4700, asic3 and w100fb
      MAINTAINERS: add a maintainer for iPAQ hx4700
      MFD,mmc: tmio_mmc: make HCLK configurable
      tmio_mmc: add bus_shift support
      tmio_mmc: don't use set_irq_type
      tmio_mmc: correct probe return value for num_resources !=3D 3
      tmio_mmc: map SD control registers after enabling the MFD cell
      tmio_mmc: allow compilation for ASIC3
      ASoC: magician: fix PXA SSP clock polarity
      regulator/max1586: support increased V3 voltage range
      regulator/max1586: fix V3 gain calculation integer overflow
      [ARM] pxa/hx4700: add Maxim 1587A voltage regulator
      [ARM] pxa/mioa701: add V3 gain configuration for Maxim 1586 voltage=
 regulator
      mfd: asic3: add asic3_set_register common operation
      mfd: asic3: add clock handling for MFD cells
      mfd: add ASIC3 IRQ numbers
      mfd: asic3: use resource_size macro instead of local variable
      mfd: asic3: remove SD/SDIO controller register definitions
      mfd: asic3: enable DS1WM cell
      mfd: asic3: enable SD/SDIO cell

Philippe Gerum (5):
      Blackfin: merge Philippe's recent ipipe patch
      Blackfin: convert interrupt pipeline to irqflags
      Blackfin: allow CONFIG_TICKSOURCE_GPTMR0 with interrupt pipeline
      Blackfin: remove obsolete mcount support from I-pipe code
      Blackfin: update I-pipe patch level

Pierre Ossman (6):
      sdhci: avoid changing voltage needlessly
      cb710: fix printk format string
      cb710: add missing parenthesis
      cb710: handle DEBUG define in Makefile
      mxcmmc: remove frequency workaround
      sdhci: remove needless double parenthesis

Pierre Willenbrock (1):
      agp/intel: Make intel_i965_mask_memory use dma_addr_t for physical =
addresses

Pieter Van Schaik (1):
      V4L/DVB (11735): Enables the Winfast TV2000 XP Global TV IR

Ping Cheng (2):
      Input: wacom - add support for Intuos4 tablets
      Input: wacom - clear Intuos4 wheel data when finger leaves proximit=
y

Prabhanjan Sarnaik (1):
      mv643xx_eth: fix unicast filter programming in promiscuous mode

Prarit Bhargava (1):
      x86: nmi: Add Intel processor 0x6f4 to NMI perfctr1 workaround

Rabeeh Khoury (2):
      [ARM] Kirkwood: CPU idle driver
      [ARM] Kirkwood: clock gating for unused peripherals

Rafael J. Wysocki (10):
      NET/r8169: Rework suspend and resume
      PCI PM: Follow PCI_PM_CTRL_NO_SOFT_RESET during transitions from D3
      PM: Warn if interrupts are enabled during suspend-resume of sysdevs
      PM/Suspend: Do not shrink memory before suspend
      PM/Hibernate: Move memory shrinking to snapshot.c (rev. 2)
      PM: Separate suspend to RAM functionality from core
      PM/Hibernate: Rename disk.c to hibernate.c
      PCI PM: Fix handling of devices without PM support by pci_target_st=
ate()
      mm, PM/Freezer: Disable OOM killer when tasks are frozen
      Net / e100: Fix suspend of devices that cannot be power managed

Rahul Iyer (1):
      nfs41: Get the rpc_xprt * from the rpc_rqst instead of the rpc_clnt.

Rainer Weikusat (1):
      ide-cd: prevent null pointer deref via cdrom_newpc_intr

Rakib Mullick (1):
      mfd: Mark clocks_init as non-init in twl4030-core.c

Ralf Baechle (12):
      MIPS: Fix typo resulting in far too long ndelay times.
      MIPS: SMTC: Fix formatting difference to linux-mips.org code
      MIPS: SB1250: Sort out merge mistake.
      MIPS: ioctl.h: Cleanup.
      MIPS: bug.h Build fix - include <linux/compiler.h>.
      MIPS: Build fix - include <linux/smp.h> into all smp_processor_id()=
 users.
      MIPS: Hibernation: Remove SMP TLB and cacheflushing code.
      MIPS: MIPSsim: Fix build error if MSC01E_INT_BASE is undefined.
      MIPS: Sibyte: Fix build error if CONFIG_SERIAL_SB1250_DUART is unde=
fined.
      MIPS: Add arch generic CPU hotplug
      MIPS: SMP: Allow suspend and hibernation if CPU hotplug is availabl=
e
      MIPS: Cavium: Add CPU hotplugging code.

Rami Rosen (8):
      ipv4: remove unused member in fib_table.
      ipv4: remove unused macro (FIB_RES_RESET) from ip_fib.h.
      ipv4: remove an unused parameter from configure method of fib_rules=
_ops.
      ipv4: cleanup - remove two unused parameters from fib_semantic_matc=
h().
      ipv4: cleanup: remove unnecessary include.
      net: Remove unused parameter from fill method in fib_rules_ops.
      iwlwifi: avoid build warning in iwl-core.
      ipv4: remove ip_mc_drop_socket() declaration from af_inet.c.

Randy Dunlap (30):
      nfsd: use C99 struct initializers
      lockd: fix FILE_LOCKING=3Dn build error
      [SCSI] fcoe, libfc: fix function declarations to be ANSI-compliant
      iwmc3200wifi: fix printk format
      menu: fix embedded menu presentation
      kernel-doc: cleanup perl script
      block: fix kernel-doc in recent block/ changes
      kmemcheck: include module.h to prevent warnings
      [SCSI] cnic: fix undefined reference to `ip6_route_output'
      ieee802154: fix kconfig bool/tristate muckup
      x86: atomic_32.h: Fix kernel-doc warnings
      genirq, irq.h: Fix kernel-doc warnings
      fusion: fix recent kernel-doc problems
      [SCSI] qla2xxx: fix printk format warnings
      USB: composite.h: mark private struct members as private:
      USB: usb.h: change private: kernel-doc for new format requirement
      V4L/DVB (11756): soc_camera: depends on I2C
      V4L/DVB (11758): 2: handle unregister for non-I2C builds
      V4L/DVB (11881): one kconfig controls them all
      V4L/DVB (11936): Fix v4l2-device usage of i2c_unregister_device()
      kmap_types: make most arches use generic header file
      skbuff.h: fix skb_dst kernel-doc
      phy_device: fix parameter name in kernel-doc
      cgroups: make messages more readable
      Fix kernel-doc parameter name typo in blk-settings.c:
      Staging: comedi: uses udelay, needs delay.h
      Staging: vt6655: uses pci functions, should depend on PCI
      kernel-doc: ignore kmemcheck_bitfield_begin/end
      kernel-doc: fix param matching for array params
      cnic: add NETDEV_1000 and NETDEVICES to Kconfig select

Raphael Doursenaud (1):
      ALSA: hdsp: allow firmware loading from inside the kernel

Reinette Chatre (6):
      iwlwifi: change check triggering device restart after rfkill change
      iwlagn: disable PS support for iwlagn
      iwlwifi: more descriptive unsupported hardware message
      iwlwifi: fix merge error
      iwlwifi: fix otp access init
      iwlwifi: fix comment describing disable_11n

Remis Lima Baima (1):
      x86: added 'ifndef _ASM_X86_IOMAP_H' to iomap.h

Ricardo Labiaga (21):
      nfs41: Add Kconfig symbols for NFSv4.1
      nfs41: Add ability to read RPC call direction on TCP stream.
      nfs41: Process the RPC call direction
      nfs41: client callback structures
      nfs41: Initialize new rpc_xprt callback related fields
      nfs41: New backchannel helper routines
      nfs41: New include/linux/sunrpc/bc_xprt.h
      nfs41: New xs_tcp_read_data()
      nfs41: Add backchannel processing support to RPC state machine
      nfs41: Backchannel callback service helper routines
      nfs41: Refactor svc_process()
      nfs41: Backchannel bc_svc_process()
      nfs41: Implement NFSv4.1 callback service process.
      nfs41: Rename rq_received to rq_reply_bytes_recvd
      nfs41: Backchannel: update cb_sequence args and results
      nfs41: Backchannel: Refactor nfs4_reset_slot_table()
      nfs41: Backchannel: Refactor nfs4_init_slot_table()
      nfs41: Backchannel: Add a backchannel slot table to the session
      nfs41: Backchannel: New find_client_with_session()
      nfs41: Backchannel: CB_SEQUENCE validation
      nfs41: sunrpc: xprt_alloc_bc_request() should not use spin_lock_bh(=
)

Riccardo Ghetta (4):
      sis190: fix for x86_64 (bug 11509)
      sis190: better message on unknown PHY
      sis190: add new phy found on asus F5Sr laptop
      sis190: fix gigabit negotiation

Richard Genoud (4):
      Remove duplicate slow protocol define in bond_3ad.h
      Staging: rspiusb: clean rspiusb code
      Staging: rspiusb.c: break the huge piusb_ioctl function into severa=
l ones
      Staging: rspiusb: duplicate code in pixis_io

Richard Kennedy (1):
      mm: exit.c reorder wait_opts to remove padding on 64 bit builds

Richard Laager (1):
      USB: Identify Novatel MC760 in option driver

Richard R=C2=9A=C3=B6jfors (1):
      netdev: Added KS8842 driver

Richard R=C3=B6jfors (4):
      serial: Added Timberdale UART driver
      i2c-ocores: Can add I2C devices to the bus
      sdhci: platform driver for SDHCI
      timbuart: Fix for tx_empty

Rik van Riel (2):
      x86: 46 bit physical address support on 64 bits
      vmscan: evict use-once pages first

Risto Suominen (1):
      de2104x: support for systems lacking cache coherence

Robert Hancock (1):
      sata_sil: enable 32-bit PIO

Robert Jarzmik (8):
      [ARM] pxa: add udc support for pxa3xx
      [ARM] pxa: add vcc_core regulation for cpufreq on pxa2xx
      Maxim 1586 regulator driver
      USB: pxa27x_udc: compatibility with pxa320 SoC
      USB: pxa27x_udc: single-thread setup requests
      [ARM] pxa/mioa701: add Maxim 1586 voltage regulator
      MAINTAINERS: add entry for Mitac Mio A701 board
      V4L/DVB (11613): pxa_camera: Documentation of the FSM

Robert Jennings (3):
      powerpc/pseries: CMO unused page hinting
      [SCSI] ibmvscsi: Add specific timeouts for operations
      [SCSI] ibmvscsi: Enable fast fail feature

Robert Krakora (2):
      V4L/DVB (11896): em28xx: Fix for Slow Memory Leak
      V4L/DVB (12002): uvc: Fix for no return value check of uvc_ctrl_set=
() which calls mutex_lock_interruptible()

Robert Love (4):
      fcoe: Add runtime debug logging with module parameter debug_logging
      libfcoe: Add runtime debugging with module param debug_logging
      libfc: Add runtime debugging with debug_logging module parameter
      msm_serial: serial driver for MSM7K onboard serial peripheral.

Robert P. J. Day (9):
      scripts/headers_check.pl: correct RE in header CONFIG leak check
      KVM: Expand on "help" info to specify kvm intel and amd module name=
s
      ramdisk: remove long-deprecated "ramdisk=3D" boot-time parameter
      drm: simplify kcalloc() call to kzalloc().
      sparc: Simplify code using is_power_of_2() routine.
      kernel/kfifo.c: replace conditional test with is_power_of_2()
      ntfs: use is_power_of_2() function for clarity.
      Staging: meilhaus: Remove long-deprecated SA_* interrupt macros.
      h8/300: fix incorrect "select" directives in arch/h8300/Kconfig.cpu.

Robert Reif (1):
      sparc: move of_device common code to of_device_common

Robert Richter (31):
      perf_counter, x86: remove X86_FEATURE_ARCH_PERFMON flag for AMD cpu=
s
      perf_counter, x86: declare perf_max_counters only for CONFIG_PERF_C=
OUNTERS
      perf_counter, x86: add default path to cpu detection
      perf_counter, x86: rework pmc_amd_save_disable_all() and pmc_amd_re=
store_all()
      perf_counter, x86: protect per-cpu variables with compile barriers =
only
      perfcounters: rename struct hw_perf_counter_ops into struct pmu
      perf_counter, x86: rename struct pmc_x86_ops into struct x86_pmu
      perf_counter, x86: make interrupt handler model specific
      perf_counter, x86: remove get_status() from struct x86_pmu
      perf_counter, x86: remove ack_status() from struct x86_pmu
      perf_counter, x86: rename __hw_perf_counter_set_period into x86_per=
f_counter_set_period
      perf_counter, x86: rename intel only functions
      perf_counter, x86: modify initialization of struct x86_pmu
      perf_counter, x86: make x86_pmu data a static struct
      perf_counter, x86: move counter parameters to struct x86_pmu
      perf_counter, x86: make pmu version generic
      perf_counter, x86: make x86_pmu_read() static inline
      perf_counter, x86: rename cpuc->active_mask
      perf_counter, x86: generic use of cpuc->active
      perf_counter, x86: consistent use of type int for counter index
      perf_counter, x86: rework counter enable functions
      perf_counter, x86: rework counter disable functions
      perf_counter, x86: change and remove pmu initialization checks
      perf_counter, x86: implement the interrupt handler for AMD cpus
      perf_counter, x86: return raw count with x86_perf_counter_update()
      perf_counter, x86: introduce max_period variable
      perf_counter, x86: remove vendor check in fixed_mode_idx()
      perf_counter, x86: remove unused function argument in intel_pmu_get=
_status()
      perf_counter: update 'perf top' documentation
      perf_counter, x86: rename bitmasks to ->used_mask and ->active_mask
      oprofile: introduce module_param oprofile.cpu_type

Roberto De Ioris (2):
      Staging: add udlfb driver
      Staging: udlfb: update to version 0.2.3

Robin Getz (20):
      Blackfin Serial Driver: fix baudrate for early_printk
      Blackfin: allow scheduler functions to be placed into L1
      Blackfin: fix early L1 relocation crash
      Blackfin: document anomaly 05000234 workaround
      Blackfin: annotate anomaly 05000119 in core DMA code
      Blackfin: make sure MPU CPLB for first 1k is marked as valid
      Blackfin: make deferred hardware errors more exact
      Blackfin: make sure stack is accessible before dumping it
      Blackfin: add workaround for anomaly 05000461
      Blackfin: include system/processor info in dump messages
      Blackfin: add missing access_ok() checks to user functions
      Blackfin: export the last exception cause via debugfs
      Blackfin: only handle CPLB protection violations when MPU is enable=
d
      Blackfin: include the cpu compiled version in /proc/cpuinfo
      Blackfin: do not configure the UART early if on wrong processor
      kallsyms: support kernel symbols in Blackfin on-chip memory
      debugfs: use specified mode to possibly mark files read/write only
      irqs: add IRQF_SAMPLE_RANDOM to the feature-removal-schedule.txt (d=
eprecated) list
      Blackfin: stick the CPU name into boot image name
      Blackfin: fix early crash when booting on wrong cpu

Roderick Colenbrander (3):
      powerpc/virtex: Add support for Xilinx PCI host bridge
      powerpc/virtex: Add Xilinx ML510 reference design support
      powerpc/virtex: Add ml510 reference design device tree

Rodolfo Giometti (2):
      LinuxPPS: core support
      i2c: Use rwsem instead of mutex for board info

Roel Kluin (49):
      rpcgss: remove redundant test on unsigned
      ar9170: wrong test on outlen in ar9170_usb_exec_cmd() ?
      ASoC: remove driver_data direct access of struct device
      RDMA/nes: Fix off-by-one bugs in reset_adapter_ne020() and init_ser=
des()
      smack: do not beyond ARRAY_SIZE of data
      sh: clkfwk: beyond ARRAY_SIZE of onchip_ops for sh7722.
      xen-blkfront: beyond ARRAY_SIZE of info->shadow
      [SCSI] ibmvscsi: Remove redundant test on unsigned.
      mISDN: get_free_devid() failure ignored
      ASoC: correct print specifiers for unsigneds
      uwb: event_size should be signed
      ALSA: burgundy: timeout message is off by one.
      mtd: nand: max_retries off by one in mxc_nand
      CRIS: assignment/is equal confusion
      drm: fix LOCK_TEST_WITH_RETURN macro
      atl1c: WAKE_MCAST tested twice, not WAKE_UCAST
      drivers/isdn/i4l/isdn_tty.c: fix check for array overindexing
      [S390] qdio: fix access beyond ARRAY_SIZE of irq_ptr->{in,out}put_q=
s
      Blackfin: fix length checking in kgdb_ebin2mem
      lguest: beyond ARRAY_SIZE of cpu->arch.gdt
      irda: smsc wait count reaches -1
      block/ps3: remove driver_data direct access of struct device
      [SCSI] ncr53c8xx: div reaches -1
      [SCSI] nsp_cs: time_out reaches -1
      block/ps3: remove driver_data direct access of struct device
      V4L/DVB: cx23885/cymax2: binary/logical &/&& typo
      V4L/DVB: cleanup redundant tests on unsigned
      V4L/DVB (11741): zoran: Fix &&/|| typo
      V4L/DVB (11961): tvp514x: try_count off by one
      spi: takes size of a pointer to determine the size of the pointed-t=
o type
      alpha: bad macro expansion, parameter is member
      uml: bad macro expansion, parameter is member
      carminefb: fix possible access beyond end of carmine_modedb[]
      radeon: P2G2CLK_ALWAYS_ONb tested twice, should 2nd be P2G2CLK_DAC_=
ALWAYS_ONb?
      spi_bfin5xx: limit reaches -1
      ufs: sector_t cannot be negative
      Staging: comedi: non working tests on unsigned cmd->convert_arg
      staging: comedi: fix missing parentheses
      Staging: rtl8187se: wmm_param[1].ac_aci_acm_aifsn tested twice
      Staging: fix operator precedence errors
      Staging: otus: beyond ARRAY_SIZE of wd->ap.wds.encryMode
      staging: rtlxxxx: off by one in AsicSendCommandToMcu() and NDIS_STA=
TUS NICLoadFirmware()
      staging: wis-sony-tuner.c: fix &&/|| error
      dtlk: off by one in {read,write}_tts()
      OMAP2 clock/powerdomain: off by 1 error in loop timeout comparisons
      serial: fix off by one errors
      IB/ehca: Ensure that guid_entry index is not negative
      CRISv10: remove redundant tests on unsigned
      udf: remove redundant tests on unsigned

Rohit Hagargundgi (1):
      mtd: Flex-OneNAND support

Roland Dreier (6):
      IB/mthca: Don't double-free IRQs when falling back from MSI-X to IN=
Tx
      mlx4_core: Don't double-free IRQs when falling back from MSI-X to I=
NTx
      Merge branches 'cxgb3', 'ehca', 'misc', 'mlx4', 'mthca' and 'nes' i=
nto for-linus
      IB/mthca: Replace dma_sync_single() use with proper functions
      mlx4_core: Fix dma_sync_single_for_cpu() with matching for_device()=
 calls
      Merge branches 'ehca', 'misc', 'mlx4', 'mthca' and 'nes' into for-l=
inus

Roland McGrath (1):
      powerpc: Add PTRACE_SINGLEBLOCK support

Ron Lee (1):
      slab: fix generic PAGE_POISONING conflict with SLAB_RED_ZONE

Ron Mercer (17):
      qlge: Fix firmware event handler loop.
      qlge: Fix bug in firmware event handler.
      qlge: Fix bug in MTU setting process.
      qlge: Fix timeout on indexed register wait.
      qlge: Fix timeout on firmware mailbox commands.
      qlge: Add support for retrieving firmware version.
      qlge: Remove netif_set_gso_max_size() call.
      qlge: Drop inbound error frames.
      qlge: Drop inbound frames > MTU.
      qlge: Add support for using alternate MAC address.
      qlge: Add support for varied pcie function numbers.
      qlge: Add set TX csum ethtool op.
      qlge: bugfix: Get rid of errant spin_unlock().
      qlge: Relax alignment on TX harware queue.
      qlge: Allow RX buf rings to be > than 4096 bytes.
      qla3xxx: Give the PHY time to come out of reset.
      qla3xxx: Don't sleep while holding lock.

Russell King (41):
      [ARM] Convert pmd_page() to be highmem safe
      [ARM] Kconfig: sort ARM machine class support choice list by option=
 name
      [ARM] sort machine- and plat- by CONFIG* name
      [ARM] smp: move core localtimer support out of platform specific fi=
les
      [ARM] smp: SCU is used on non-realview platforms
      [ARM] smp: separate SCU support code from realview
      [ARM] smp: allow re-use of realview localtimer TWD support
      [ARM] smp: fix style issues in smp_twd.c
      Merge branch 'for-rmk-devel' of git://git.pengutronix.de/git/imx/li=
nux-2.6 into devel
      Merge branch 'ixp4xx' of git://git.kernel.org/pub/scm/linux/kernel/=
git/chris/linux-2.6 into devel
      Merge branch 'iommu' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/tmlind/linux-omap-2.6.git into devel
      Merge branch 'ixp4xx' of git://git.kernel.org/pub/scm/linux/kernel/=
git/chris/linux-2.6 into devel
      [ARM] smp: use new cpumask functions
      Merge branch 'for-next' of git://git.kernel.org/pub/scm/linux/kerne=
l/git/khilman/linux-davinci into devel
      Merge branch 'for-next' of git://git.kernel.org/pub/scm/linux/kerne=
l/git/tmlind/linux-omap-2.6 into devel
      [ARM] make U300 clk_set_rate() return a _real_ errno
      [ARM] Kconfig: remove 'default n'
      Merge branch 'smp' into devel
      Merge branch 'mxc-master' of git://git.pengutronix.de/git/imx/linux=
-2.6 into devel
      Merge branch 'for-rmk' of git://git.marvell.com/orion into devel
      kbuild: fix headers_exports with boolean expression
      Merge branch 'for_rmk' of git://dev.omapzoom.org/pub/scm/santosh/ke=
rnel-omap4-base into devel
      Merge branch 'at91' into devel
      Merge branch 'ep93xx' into devel
      Merge branch for-rmk-devel of git://aeryn.fluff.org.uk/bjdooks/linu=
x into devel
      [ARM] Make ARM_VIC_NR depend on ARM_VIC
      Merge branch 'w90x900' into devel
      Merge branch 'for-rmk' of git://linux-arm.org/linux-2.6 into devel
      Merge branch 'copy_user' of git://git.marvell.com/orion into devel
      Merge branch 'for-rmk' of git://git.kernel.org/pub/scm/linux/kernel=
/git/ycmiao/pxa-linux-2.6 into devel
      Merge branch 'stmp' into devel
      Merge branch 'u300' into devel
      MAINTAINERS: EB110ATX is not ebsa110
      Merge branch 'for-rmk' of git://git.kernel.org/pub/scm/linux/kernel=
/git/ycmiao/pxa-linux-2.6 into devel
      Merge branch 'next-s3c' of git://aeryn.fluff.org.uk/bjdooks/linux i=
nto devel
      Merge branch 'for-rmk' of git://git.marvell.com/orion into devel
      Merge branch 'omap-clock-for-next' of git://git.pwsan.com/linux-2.6=
 into devel
      [ARM] wire up rt_tgsigqueueinfo and perf_counter_open
      [ARM] Update mach-types
      Merge branch 'next-s3c' of git://aeryn.fluff.org.uk/bjdooks/linux i=
nto devel
      [ARM] idle: clean up pm_idle calling, obey hlt_counter

Rusty Russell (46):
      cyber2000fb.c: use proper method for stopping unload if CONFIG_ARCH=
_SHARK
      module_param: invbool should take a 'bool', not an 'int'
      module_param: split perm field into flags and perm
      module_param: add __same_type convenience wrapper for __builtin_typ=
es_compatible_p
      module_param: allow 'bool' module_params to be bool, not just int.
      uvesafb: improve parameter handling.
      module: trim exception table on init free.
      module: cleanup FIXME comments about trimming exception table entri=
es.
      virtio: fix obsolete documentation on probe function
      virtio: meet virtio spec by finalizing features before using device
      virtio: add names to virtqueue struct, mapping from devices to queu=
es.
      virtio: expose features in sysfs
      virtio: handle short buffers in virtio_rng.
      lguest: be paranoid about guest playing with device descriptors.
      lguest: cleanup passing of /dev/lguest fd around example launcher.
      lguest: clean up lguest_init_IRQ
      lguest: get more serious about wmb() in example Launcher code
      sched: export kick_process
      lguest: fix lguest wake on guest clock tick, or fd activity
      lguest: remove invalid interrupt forcing logic.
      lguest: fix race in halt code
      lguest: improve interrupt handling, speed up stream networking
      lguest: optimize by coding restore_flags and irq_enable in assemble=
r.
      lguest: clean up example launcher compile flags.
      lguest: clean up length-used value in example launcher
      lguest: fix writev returning short on console output
      lguest: PAE fixes
      lguest: allow any process to send interrupts
      eventfd: export eventfd_signal and eventfd_fget for lguest
      lguest: use eventfds for device notification
      lguest: have example Launcher service all devices in separate threa=
ds
      lguest: remove obsolete LHREQ_BREAK call
      lguest: implement deferred interrupts in example Launcher
      lguest: avoid sending interrupts to Guest when no activity occurs.
      lguest: try to batch interrupts on network receive
      lguest: suppress notifications in example Launcher
      cpumask: remove the now-obsoleted pcibus_to_cpumask(): sh
      cpumask: arch_send_call_function_ipi_mask: sh
      cpumask: use mm_cpumask() wrapper: sh
      cpumask: Use accessors for cpu_*_mask: sh
      cpumask: use new operators in kernel/trace
      [CPUFREQ] cpumask: avoid playing with cpus_allowed in speedstep-ich=
.c
      [CPUFREQ] cpumask: avoid cpumask games in arch/x86/kernel/cpu/cpufr=
eq/speedstep-centrino.c
      [CPUFREQ] cpumask: avoid playing with cpus_allowed in powernow-k8.c
      [CPUFREQ] cpumask: new cpumask operators for arch/x86/kernel/cpu/cp=
ufreq/powernow-k8.c
      [IA64] fix compile error in arch/ia64/mm/extable.c

Ryan Mallon (2):
      [ARM] 5523/1: ep93xx phys offset selection
      [ARM] 5523/2: Updated ep93xx defconfig

Ryusuke Konishi (27):
      nilfs2: remove nilfs_dat_prepare_free function
      nilfs2: unify bmap operations starting use of indirect block addres=
s
      nilfs2: add sufile function that can modify multiple segment usages
      nilfs2: eliminate removal list of segments
      nilfs2: remove header file for segment list operations
      nilfs2: remove nilfs_bmap_put_block
      nilfs2: remove nilfs_bmap_delete_block
      nilfs2: move get block functions in bmap.c into btree codes
      nilfs2: remove pointless NULL check of bpop_commit_alloc_ptr functi=
on
      nilfs2: remove useless b_low and b_high fields from nilfs_bmap stru=
ct
      nilfs2: remove bmap pointer operations
      nilfs2: remove nilfs_direct_operations from direct mapping
      nilfs2: remove nilfs_btree_operations from btree mapping
      nilfs2: allow future expansion of metadata read out via get info io=
ctl
      nilfs2: set bio unplug flag for the last bio in segment
      nilfs2: enable sync_page method
      nilfs2: modify list of unsupported features in caveats
      nilfs2: return EBUSY against delete request on snapshot
      nilfs2: use device's backing_dev_info for btree node caches
      nilfs2: add sync_page method to page caches of meta data
      nilfs2: support contiguous lookup of blocks
      nilfs2: remove meaningless EBUSY case from nilfs_get_sb function
      nilfs2: get rid of sget use for acquiring nilfs object
      nilfs2: get rid of sget use for checking if current mount is presen=
t
      nilfs2: simplify remaining sget() use
      nilfs2: correct exclusion control in nilfs_remount function
      nilfs2: get rid of bd_mount_sem use from nilfs

R=C3=A9mi Denis-Courmont (4):
      Phonet: fix accounting race between gprs_writeable() and gprs_xmit(=
)
      f_phonet: dev_kfree_skb instead of dev_kfree_skb_any in TX callback
      f_phonet: no need to check for carrier - scheduler does it internal=
ly
      usb: gadget: f_phonet: fix memory allocation sizes

SUGIOKA Toshinobu (1):
      serial: sh-sci: Fix up PORT_SCI console output ordering.

Saeed Bishara (1):
      mv643xx_eth: only unmask RX and TX_END interrupts for available que=
ues

Sam Ravnborg (21):
      x86: standardize Kbuild rules
      x86: beautify vmlinux_64.lds.S
      x86: beautify vmlinux_32.lds.S
      x86, vmlinux.lds: unify header/footer
      x86, vmlinux.lds: unify PHDRS
      x86, vmlinux.lds: unify start/end of SECTIONS
      x86, vmlinux.lds: unify .text output sections
      x86, vmlinux.lds: unify exception table
      x86, vmlinux.lds: unify data output sections
      x86, vmlinux.lds: move vsyscall output sections
      x86, vmlinux.lds: unify first part of initdata
      x86, vmlinux.lds: unify parainstructions
      x86, vmlinux.lds: unify .exit.* and .init.ramfs
      x86, vmlinux.lds: unify percpu
      x86, vmlinux.lds: unify remaining parts
      x86: boot/compressed/vmlinux.lds.S: fix build of bzImage with 64 bi=
t compiler
      kbuild: add hint about __refdata to modpost
      Improve vmlinux.lds.h support for arch specific linker scripts
      vmlinux.lds.h update
      [IA64] unexport fpswa.h
      fbdev: generated logo sources depend on scripts/pnmtologo

Samuel Bronson (1):
      x86: use symbolic name for VM86_SIGNAL when used as vm86 default re=
turn

Samuel Ortiz (12):
      iwmc3200wifi: fix fragmentation threshold setting
      iwmc3200wifi: shrink calibration lmac name
      wireless/p54: prepare for FIRMWARE_NAME_MAX removal
      irda: add git tree to MAINTAINERS file
      firmware: allocate firmware id dynamically
      firmware: atm/ueagle-atm: prepare for FIRMWARE_NAME_MAX removal
      firmware: tuners/xc2028: prepare for FIRMWARE_NAME_MAX removal
      firmware: dvb/dvb-usb: prepare for FIRMWARE_NAME_MAX removal
      firmware: pcmcia/ds: prepare for FIRMWARE_NAME_MAX removal
      firmware: FIRMWARE_NAME_MAX removal
      mfd: fix tmio related warnings
      mfd: early init for MFD running regulators

Samuel Thibault (1):
      keyboard: advertise KT_DEAD2 extended diacriticals

Sandeep K Sinha (3):
      md: Removal of hash table in linear raid
      md: Removing num_sector and replacing start_sector with end_sector
      md: Binary search in linear raid

SandeepKsinha (1):
      md linear: Protecting mddev with rcu locks to avoid races

Sankar P (1):
      trivial: spelling fix in ppc code comments

Santosh Shilimkar (15):
      ARM: OMAP: Remove unwanted type casts and fix the compiler warning.
      ARM: OMAP: Remove useless omap_sram_error function.
      ARM: OMAP: Remove unnecessary omap2_globals.
      ARM: OMAP: Remove unwanted type casts and fix the compiler warning.
      ARM: OMAP: Remove useless omap_sram_error function.
      ARM: OMAP: Remove unnecessary omap2_globals.
      ARM: OMAP2/3: sDMA: Correct omap_request_dma_chain(), v2
      ARM: OMAP4: Add minimal support for omap4
      ARM: OMAP4: Clock stubs since CLKDEV not in yet.
      ARM: OMAP4: Add support for 4430 SDP
      ARM: OMAP4: Add defconfig for 4430 SDP
      ARM: OMAP4: SMP: Add OMAP4430 SMP board files
      ARM: OMAP4: SMP: Add mpu timer support for OMAP4430
      ARM: OMAP4: SMP: Enable SMP support for OMAP4430
      ARM: OMAP4: SMP: Update defconfig for OMAP4430

Sarah Sharp (34):
      USB: xhci: Support xHCI host controllers and USB 3.0 devices.
      USB: xhci: BIOS handoff and HW initialization.
      USB: xhci: Ring allocation and initialization.
      USB: xhci: Device context array allocation.
      USB: xhci: No-op command queueing and irq handler.
      USB: Add SuperSpeed to the list of USB device speeds.
      USB: Add USB 3.0 roothub support to USB core.
      USB: Don't reset USB 3.0 devices on port change detection.
      USB: Add route string to struct usb_device.
      USB: xhci: Root hub support.
      USB: Support for addressing a USB device under xHCI
      USB: xhci: Allocate and address USB devices
      USB: Support for submitting control URBs under xHCI.
      USB: xhci: Control transfer support.
      USB: Parse and store the SuperSpeed endpoint companion descriptors.
      USB: Support for bandwidth allocation.
      USB: xhci: Bandwidth allocation support
      USB: xhci: Bulk transfer support
      USB: Push scatter gather lists down to host controller drivers.
      USB: xhci: Scatter gather list support for bulk transfers.
      USB: xhci: URB cancellation support.
      USB: xhci: Fix register write order.
      USB: xhci: Fix Link TRB handoff bit twiddling.
      USB: xhci: Avoid global namespace pollution.
      USB: xhci: Clean up xhci_irq() function.
      USB: xhci: Avoid compiler reordering in Link TRB giveback.
      USB: Change names of SuperSpeed ep companion descriptor structs.
      USB: xhci: drop spinlock in xhci_urb_enqueue() error path.
      USB: xhci: Make xhci-mem.c include linux/dmapool.h
      usb; xhci: Fix TRB offset calculations.
      USB: xhci: Remove packed attribute from structures.
      USB: xHCI: Fix interrupt moderation.
      USB: xhci: Respect critical sections.
      USB: xhci: Add Makefile, MAINTAINERS, and Kconfig entries.

Sascha Hauer (37):
      fec: switch to writel/readl
      fec: do not typedef struct types
      fec: remove unnecessary cast
      fec: Codingstyle cleanups
      fec: refactor set_multicast_list() to make it more readable
      fec: refactor init function
      fec: align receive packets
      fec: remove debugging printks
      fec: switch to net_device_ops
      FEC Buffer rework
      fec: call fec_restart() in fec_open()
      MXC irq: remove unused defines
      MXC: Add iomux support for MX35 SoCs
      MX35: Add iomux pin defintions
      [ARM] MX35: Add PCM043 board support
      i.MX35 clock support: remove automotive path
      pcm037: setup all pins at once and not in init functions
      pcm037: add SDHC card detection
      MX35: Fix IPU/Framebuffer clock names
      pcm037: Add support for UART2
      MXC: rename mxc_map_io to architecture specific versions
      mxc timer: make compile time independent
      mxc irq: make architecture runtime dependent
      [ARM] Remove arch-imx from build system
      [ARM] remove arch-imx
      pcm038: Setup all iomux pins at once
      PCM038: Remove unnecessary ifdefs, reorder includes alphabetically
      mx1ads: remove ifdefs, reorder include alphabetically
      mx1ads: setup iomux pins at once
      mx1: add missing include
      mx1ads: rename mxc_map_io to mx1_map_io
      mxc: fix wrong register access in timer code
      MXC qonq: mxc_map_io is now mx31_map_io
      mx31: calls to gpio_request moved into platform code
      mx3fb: Issue prettier log message
      MMC core: limit minimum initialization frequency to 400kHz
      imx: Check for NULL pointer deref before calling tty_encode_baud_ra=
te

Sascha Hlusiak (5):
      sit: Fail to create tunnel, if it already exists
      sit: strictly restrict incoming traffic to tunnel link device
      sit: ipip6_tunnel_del_prl: return err
      addrconf: refuse isatap eui64 for INADDR_ANY
      sit: stateless autoconf for isatap

Sasha Alexandr (3):
      ALSA: HDA - Add pci-quirk for MSI MS-7350 motherboard.
      ALSA: HDA - Name-fixes in code (tagra/targa)
      ALSA: HDA - Correct trivial typos in comments.

Sathya Perla (9):
      be2net: Use cancel_delayed_work_sync instead of cancel_delayed_work=
()
      be2net: fix netdev stats rx_errors and rx_dropped
      be2net: Fix rx stats updation in non-lro path
      be2net: Fix early reset of rx-completion
      be2net: Fix be_tx_q_clean() being called on freed queues
      be2net: Add MCC queue mechanism for BE cmds
      be2net: Use MCC queue for cmds that may be called in BH context
      be2net: cleanup multicast_set cmd to avoid mc_list copy
      be2net: receive asynchronous link status notifications from BE

Scott James Remnant (1):
      USB: usbfs: deprecate and hide option for !embedded

Sean MacLennan (3):
      powerpc: Update Warp to use leds-gpio driver
      i2c: Fix confusing i2c-ibm_iic message
      powerpc/warp: Fix ISA_DMA_THRESHOLD default

Sebastian Andrzej Siewior (7):
      Input: ucb1400 - move static function from header into core
      crypto: padlock - Enable on x86_64
      net/libertas: make SPI interface big endian aware
      [ARM] orion5x: add sram support for crypto
      net/libertas: remove GPIO-CS handling in SPI interface code
      [ARM] orion5x: increment window counter after adding sram mapping
      net/libertas: don't recursive spin lock in if_spi_e2h()

Sebastian Haas (1):
      Staging: add cpc-usb driver to the staging tree

Sebastian Ott (7):
      [S390] cio: fix sanity checks in device_ops.
      [S390] dasd: check_characteristics cleanup
      [S390] dasd: sync after async probe
      [S390] pm: ccw bus power management callbacks
      [S390] pm: ccwgroup bus power management callbacks
      [S390] pm: css bus power management callbacks
      [S390] dasd: fix refcounting in dasd_change_state

Senthil Balasubramanian (1):
      mac80211: Initialize RX's last received sequence number

Seokmann Ju (1):
      [SCSI] qla2xxx: Correct bus-reset behaviour with recent ISPs.

Serge E. Hallyn (3):
      don't raise all privs on setuid-root file with fE set (v2)
      tomoyo: avoid get+put of task_struct
      staging: p9auth: prevent some oopses and memory leaks

Sergei Poselenov (1):
      kbuild: fix "Argument list too long" error for "make headers_check"=
,

Sergei Shtylyov (25):
      davinci: INTC: add support for TI cp_intc
      pdc202xx_old: use ide_dma_test_irq()
      pdc202xx_old: don't call pdc202xx_reset() on IRQ timeout
      pdc202xx_old: kill resetproc() method
      sl82c105: add printk() logging facility
      libata-sff: avoid byte swapping in ata_sff_data_xfer()
      sgiioc4: coding style cleanup
      ide: call clear_irq() method in ide_timer_expiry()
      cmd64x: implement clear_irq() method (take 2)
      siimage: use ide_dma_test_irq() (take 2)
      ide: move IRQ clearing from ack_intr() method to clear_irq() method=
 (take 2)
      ide: move ack_intr() method into 'struct ide_port_ops' (take 2)
      cmd640: implement test_irq() method
      cmd64x: implement test_irq() method
      pdc202xx_old: implement test_irq() method (take 2)
      siimage: implement test_irq() method
      sl82c105: implement test_irq() method
      musb_gadget: fix unhandled endpoint 0 IRQs
      musb_gadget: suppress "parasitic" TX interrupts with CPPI
      musb_host: refactor musb_save_toggle() (take 2)
      musb_host: factor out musb_ep_{get|set}_qh()
      musb_host: simplify check for active URB
      musb_host: streamline musb_cleanup_urb() calls
      musb_host: refactor URB giveback
      musb: split out CPPI interrupt handler

Sergei Trofimovich (1):
      mm cleanup: shmem_file_setup: 'char *' -> 'const char *' for name a=
rgument

Sergey Belyashov (2):
      HID: autocentering support for Logitech G25 Racing Wheel
      HID: autocentering support for Logitech Force 3D Pro

Sergey Lapin (8):
      ASoC: AFEB9260 driver
      [ARM] 5514/1: AFEB9260 sound support
      [ARM] 5525/1: AFEB9260: fix for MMC support
      Add constants for the ieee 802.15.4 stack
      net: add IEEE 802.15.4 socket family implementation
      net: add NL802154 interface for configuration of 802.15.4 devices
      ieee802154: add documentation about our stack
      ieee802154: add simple HardMAC driver sample

Sergey Matyukevich (1):
      [libata] PATA driver for CF interface on AT91SAM9260 SoC

Sergio Luis (6):
      x86: unify power/cpu_(32|64) headers
      x86: unify power/cpu_(32|64) global variables
      x86: unify power/cpu_(32|64) regarding saving processor state
      x86: unify power/cpu_(32|64) regarding restoring processor state
      x86: unify power/cpu_(32|64) copyright notes
      x86: unify power/cpu_(32|64).c

Shan Wei (1):
      tcp:fix the code indent

Shane Huang (1):
      [libata] ahci: Restore SB600 SATA controller 64 bit DMA

Shane McDonald (1):
      mtd: remove pmcmsp-ramroot.c

Shaohua Li (4):
      x86: make sparse mem work in non-NUMA mode
      PCI: disable ASPM on VIA root-port-under-bridge configurations
      x86: change kernel_physical_mapping_init() __init to __meminit
      driver core: synchronize device shutdown

Shawn Du (1):
      blktrace: support per-partition tracing

Sheng Yang (17):
      KVM: Split IOAPIC structure
      KVM: Unify the delivery of IOAPIC and MSI interrupts
      KVM: Change API of kvm_ioapic_get_delivery_bitmask
      KVM: Update intr delivery func to accept unsigned long* bitmap
      KVM: bit ops for deliver_bitmap
      KVM: Ioctls for init MSI-X entry
      KVM: Add MSI-X interrupt injection logic
      KVM: Enable MSI-X for KVM assigned device
      KVM: Merge kvm_ioapic_get_delivery_bitmask into kvm_get_intr_delive=
ry_bitmask
      KVM: Device assignment framework rework
      KVM: VMX: Correct wrong vmcs field sizes
      KVM: VMX: Clean up Flex Priority related
      KVM: VMX: Fix feature testing
      KVM: MMU: Discard reserved bits checking on PDE bit 7-8
      KVM: Replace get_mt_mask_shift with get_mt_mask
      KVM: Enable snooping control for supported hardware
      KVM: VMX: Disable VMX when system shutdown

Shin Hong (1):
      Btrfs: init worker struct fields before kthread-run

Siddarth Gore (1):
      [ARM] Kirkwood: enable gpio leds/buttons for the mv88f6281gtw_ge bo=
ard

Simon Arlott (3):
      cxacru: Fix negative dB output
      V4L/DVB (11841): core: fix potential mutex_unlock without mutex_loc=
k in dvb_dvr_read
      ALSA: via82xx: add option to disable 500ms delay in snd_via82xx_cod=
ec_wait

Simon Horman (1):
      e1000e: Call e1000e_config_collision_dist() after TCTL has been set

Simon POLETTE (1):
      PATCH] mx27pdk: rename mxc_map_io to mx27_map_io

Simon Polette (1):
      mtd: add on-flash BBT support for Atmel NAND driver

Simos Xenitellis (1):
      ALSA: hda - add quirk for STAC92xx (SigmaTel STAC9205)

Sivakumar Subramani (1):
      vxge: Enable SRIOV support in the driver.

Sonic Zhang (15):
      netdev: bfin_mac: fix malformed UDP packet transmission when pollin=
g with KGDB
      ASoC: Blackfin: document how anomaly 05000250 is handled
      Blackfin Serial Driver: fix error while transferring large files
      Blackfin Serial Driver: handle irregular DMA register status in aut=
o start mode
      Blackfin Serial Driver: annotate anomalies 05000215 and 05000099
      Blackfin Serial Driver: handle anomaly 05000231
      Blackfin Serial Driver: disable dma rx interrupt only rather than a=
ll irqs
      Blackfin: Allow bf548 ATAPI to be routed to GPIO
      Blackfin: update defconfigs
      Blackfin: detect anomaly 05000274
      Blackfin: add SSYNC to set_dma_sg() for descriptor fetching
      i2c: Blackfin TWI: fix REPEAT START mode doesn't repeat
      Blackfin: add blackfin_invalidate_entire_icache for SMP systems
      Blackfin: fix deadlock in SMP IPI handler
      Blackfin: fix accidental reset in some boot modes

Sridhar Samudrala (3):
      net: Fix skb_copy_datagram_from_iovec() to pass the right offset
      net: Fix memcpy_toiovecend() to use the right offset
      tun: Fix copy/paste error in tun_get_user

Srinivas Eeda (2):
      ocfs2: timer to queue scan of all orphan slots
      ocfs2 patch to track delayed orphan scan timer statistics

Stanislaw Gruszka (2):
      bnx2x: free workqueue when driver fail to register
      bnx2x: do not return negative number of received packages

Stefan Agner (1):
      [ARM] orion: sched_clock implementation for orion platforms

Stefan Haberland (2):
      [S390] pm: dasd power management callbacks.
      [S390] dasd_pm: fix stop flag handling

Stefan Raspl (1):
      blktrace: remove debugfs entries on bad path

Stefan Richter (25):
      firewire: core: improve check for local node
      firewire: core: check for missing struct update at build time, not =
run time
      firewire: core: add sysfs attribute for easier udev rules
      firewire: share device ID table type with ieee1394
      firewire: also use vendor ID in root directory for driver matches
      firewire: ohci: access bus_seconds atomically
      firewire: clean up includes
      firewire: reorganize header files
      firewire: rename source files
      firewire: add parent-of-unit accessor
      firewire: core: include linux/uaccess.h instead of asm/uaccess.h
      firewire: core: prepare for non-core children of card devices
      firewire: core: don't update Broadcast_Channel if RFC 2734 conditio=
ns aren't met
      firewire: core: use more outbound tlabels
      firewire: net: add Kconfig item, rename driver
      firewire: net: style changes
      firewire: net: allow for unordered unit discovery
      firewire: net: remove unused code
      firewire: net: adjust net_device ops
      firewire: core: fix DMA unmapping in iso buffer removal
      firewire: core: fix iso context shutdown on card removal
      firewire: net: fix card driver reloading
      firewire: net: better FIFO address range check and rcodes
      firewire: new stack is no longer experimental
      explain the hidden scsi_wait_scan Kconfig variable

Stefan Roese (2):
      powerpc/4xx: Sequoia: Enable NAND support
      mtd: physmap_of: Add multiple regions and concatenation support

Stefan Roscher (3):
      IB/ehca: Fall back to vmalloc() for big allocations
      IB/ehca: Remove unnecessary memory operations for userspace queue p=
airs
      IB/ehca: Increment version number

Stefan Schmidt (1):
      MAINTAINERS: Update entry with file and SCM for EZX

Stefan Weil (1):
      cpmac: prevent fatal exception in cpmac_end_xmit

Stefan Weinhuber (3):
      [S390] dasd: no High Performance FICON in 31-bit mode
      [S390] dasd: forward internal errors to dasd_sleep_on caller
      [S390] pm: vmlogrdr power management callbacks

Stefani Seibold (1):
      proc.txt: update kernel filesystem/proc.txt documentation

Stefano Brivio (1):
      b43legacy: Remove unnecessary MMIO in interrupt hotpath

Stephane Chatty (2):
      HID: add new multitouch and digitizer contants
      HID: Multitouch support for the N-Trig touchscreen

Stephen Hemminger (24):
      netns: remove leftover debugging message
      netns: simplify net_ns_init
      bonding: fix multiple module load problem
      bonding: bond_create always called with default parameters
      bonding: initialize before registration
      bonding: remove bonding read/write semaphore
      bonding: fix destructor
      bonding: fix style issues
      bonding: elminate bad refcount code
      bonding: network device names are case sensative
      bonding: use is_zero_ether_addr
      bonding: initialization rework
      sky2: don't look for VPD size
      skbuff: skb_mac_header_was_set is always true on >32 bit
      skbuff: don't corrupt mac_header on skb expansion
      sky2: turn off pause during shutdown
      sky2: more receive shutdown
      sky2: PCI irq issues
      sky2: fix shutdown synchronization
      sky2: receive counter update
      sky2: reduce default transmit ring
      sky2: skb recycling
      sky2: add GRO support
      sky2: version 1.23

Stephen M. Cameron (2):
      cciss: factor out core of sendcmd() for a more sane interface
      cciss: fix SCSI device reset handler

Stephen Rothwell (13):
      sparc64: extend TI_RESTART_BLOCK space by 8 bytes
      modules: Fix up build when CONFIG_MODULE_UNLOAD=3Dn.
      net/ibmveth: fix panic in probe
      powerpc/pci: Fix annotation of pcibios_claim_one_bus
      ALSA: sound/ppc: update annotations of serveral functions
      powerpc/pseries: Fix warnings when printing resource_size_t
      powerpc/xmon: Remove unused variable in xmon.c
      powerpc: Fix warning when printing a resource_size_t
      powerpc/spufs: Remove unused error path
      perfcounters: remove powerpc definitions of perf_counter_do_pending
      powerpc: Wire up sys_rt_tgsigqueueinfo
      USB: xhci: use xhci_handle_event instead of handle_event
      sparc: replace uses of CPU_MASK_ALL_PTR

Stephen Smalley (1):
      selinux: remove obsolete read buffer limit from sel_read_bool

Steve French (2):
      [CIFS] Update readme to indicate change to default mount (serverino=
)
      [CIFS] Add mention of new mount parm (forceuid) to cifs readme

Steve Ma (1):
      [SCSI] libfc: Check if exchange is completed when receiving a seque=
nce

Steve Magnani (2):
      microblaze: Fix paging init-zone initialization
      microblaze: Guard __HAVE_ARCH macros with __KERNEL__ in string.h

Steve Wise (5):
      RDS/IW+IB: Set recv ring low water mark to 1/2 full.
      RDS/IW+IB: Set the RDS_LL_SEND_FULL bit when we're throttled.
      RDS/IW+IB: Allow max credit advertise window.
      RDMA/cxgb3: Report correct port state and MTU
      RDMA/cxgb3: Limit fast register size based on T3 limitations

Steven Luo (1):
      ath9k: reset after PCI FATAL/PERR interrupts

Steven Rostedt (132):
      tracing: add handler to trace_stat
      tracing: add function profiler
      tracing: move function profiler data out of function struct
      tracing: adding function timings to function profiler
      tracing: make the function profiler per cpu
      function-graph: add option to calculate graph time or not
      tracing: clean up tracing profiler
      tracing: remove on the fly allocator from function profiler
      tracing: add average time in function to function profiler
      function-graph: use int instead of atomic for ftrace_graph_active
      x86, function-graph: only save return values on x86_64
      ring-buffer: add ring_buffer_discard_commit
      tracing/filters: use ring_buffer_discard_commit for discarded event=
s
      tracing: consolidate trace and trace_event headers
      tracing: create automated trace defines
      tracing: make trace_seq operations available for core kernel
      tracing/events: move declarations from trace directory to core incl=
ude
      tracing/events: move the ftrace event tracing code to core
      tracing/events: convert event call sites to use a link list
      tracing/events: add export symbols for trace events in modules
      tracing/events: add support for modules to TRACE_EVENT
      tracing/events: fix compile for modules disabled
      tracing/events: fix lockdep system name
      tracing/events: move trace point headers into include/trace/events
      tracing/events: add trace-events-sample
      ftrace: use module notifier for function tracer
      tracing/events: add startup tests for events
      tracing/events/ring-buffer: expose format of ring buffer headers to=
 users
      tracing/events: perform function tracing in event selftests
      tracing/events: enable code with EVENT_TRACING not EVENT_TRACER
      tracing: add EXPORT_SYMBOL_GPL for trace commits
      tracing: add same level recursion detection
      tracing: protect trace_printk from recursion
      tracing: remove format attribute of inline function
      tracing: change branch profiling to a choice selection
      tracing: create menuconfig for tracing infrastructure
      tracing: rename EVENT_TRACER config to ENABLE_EVENT_TRACING
      tracing/events: call the correct event trace selftest init function
      tracing: remove dangling semicolon
      tracing: fix recursive test level calculation
      tracing: remove recursive test from ring_buffer_event_discard
      tracing: use recursive counter over irq level
      tracing: use nowakeup version of commit for function event trace te=
sts
      ring-buffer: only warn on wrap if buffer is bigger than two pages
      tracing/wakeup: move access to wakeup_cpu into spinlock
      tracing: increase size of number of possible events
      tracing: add size checks for exported ftrace internal structures
      tracing: fix cut and paste macro error
      tracing/lockdep: convert lockdep to use TRACE_EVENT macro
      tracing/irq: convert irq traces to use TRACE_EVENT macro
      tracing: remove deprecated TRACE_FORMAT
      tracing/events: reuse trace event ids after overflow
      tracing/events: make modules have their own file_operations structu=
re
      tracing: convert ftrace_dump spinlocks to raw
      tracing: fix ref count in splice pages
      tracing: only add splice page if entries exist
      tracing: have splice only copy full pages
      ring-buffer: fix printk output
      ring-buffer: export symbols
      ring-buffer: add counters for commit overrun and nmi dropped entrie=
s
      tracing: export stats of ring buffers to userspace
      ring-buffer: convert cpu buffer entries to local_t
      ring-buffer: record page entries in buffer page descriptor
      ring-buffer: have read page swap increment counter with page entrie=
s
      ring-buffer: disable writers when resetting buffers
      tracing: use proper export symbol for tracing api
      ring-buffer: move big if statement down
      ring-buffer: add benchmark and tester
      ring-buffer: remove unneeded conditional in rb_reserve_next
      ring-buffer: check for failed allocation in ring buffer benchmark
      ring-buffer: make moving the tail page a separate function
      ring-buffer: change test to be more latency friendly
      tracing: update sample with TRACE_INCLUDE_FILE
      tracing: reset ring buffer when removing modules with events
      tracing: add hierarchical enabling of events
      ring-buffer: remove complex calculations in ring-buffer-test
      tracing: append ":*" to internal setting of system events
      tracing: have menu default enabled when kernel debug is configured
      ring-buffer: only periodically call cond_resched to ring-buffer-ben=
chmark
      ring-buffer: add total count in ring-buffer-benchmark
      ring-buffer: change WARN_ON from checking preempt_count to preempti=
ble
      tracing: initialize return value for __ftrace_set_clr_event
      tracing: add trace_set_clr_event to export event enabling function
      ring-buffer: replace constants with time macros in ring-buffer-benc=
hmark
      ring-buffer: check for divide by zero in ring-buffer-benchmark
      ring-buffer: remove type parameter from rb_reserve_next_event
      ring-buffer: move calculation of event length
      ring-buffer: small optimizations
      ring-buffer: use internal time stamp function
      ring-buffer: move code around to remove some branches
      genirq: fix comment to say IRQ_WAKE_THREAD
      x86/stacktrace: return 0 instead of -1 for stack ops
      tracing: stop stack trace on first empty entry
      tracing: add __print_flags for events
      tracing: add previous task state info to sched switch event
      tracing: add flag output for kmem events
      tracing: add __print_symbolic to trace events
      tracing: convert irq events to use __print_symbolic
      ftrace: add kernel command line function filtering
      tracing: fix config options to not show when automatically selected
      tracing: combine the default tracers into one config
      tracing: remove redundant SOFTIRQ from softirq event traces
      tracing: make trace pipe recognize latency format flag
      ftrace: do not profile functions when disabled
      function-graph: only allocate init tasks if it was not already done
      function-graph: enable the stack after initialization of other vari=
ables
      function-graph: add memory barriers for accessing task's ret_stack
      function-graph: move initialization of new tasks up in fork
      function-graph: always initialize task ret_stack
      ring-buffer: try to discard unneeded timestamps
      ring-buffer: discard timestamps that are at the start of the buffer
      tracing: add annotation to what type of stack trace is recorded
      ring-buffer: fix ret in rb_add_time_stamp
      tracing: fix the block trace points print size
      tracing: add trace_seq_vprint interface
      tracing: add protection around module events unload
      tracing: do not translate event helper macros in print format
      ring-buffer: prevent adding write in discarded area
      debugfs: dont stop on first failed recursive delete
      ring-buffer: have benchmark test handle discarded events
      ring-buffer: remove unused variable
      ring-buffer: use commit counters for commit pointer accounting
      tracing: update sample event documentation
      ring-buffer: use BUF_PAGE_HDR_SIZE in calculating index
      ring-buffer: remove useless warn on check
      ring-buffer: remove useless compile check for buffer_page size
      ring-buffer: check for less than two in size allocation
      ring-buffer: add locks around rb_per_cpu_empty
      ring-buffer: do not grab locks in nmi
      ring-buffer: have benchmark test print to trace buffer
      function-graph: disable when both x86_32 and optimize for size are =
configured
      function-graph: add stack frame test

Steven Toth (13):
      V4L/DVB (11665): cx88: Add support for the Hauppauge IROnly board.
      V4L/DVB (11666): cx23885: Don't assume GPIO interrupts are cam rela=
ted.
      V4L/DVB (11697): tda10048: Add ability to select I/F at attach time.
      V4L/DVB (11698): cx23885: For tda10048 boards ensure we specify the=
 I/F
      V4L/DVB (11699): pvrusb2: Ensure we specify the I/F at attach time
      V4L/DVB (11700): tda10048: Added option to block i2c gate control f=
rom other drivers.
      V4L/DVB (11701): pvrusb2: Ensure the PVRUSB2 disabled the i2c gate =
on the tda10048.
      V4L/DVB (11765): cx23885: Add generic functions for driving GPIO's
      V4L/DVB (11767): cx23885: Add preliminary support for the HVR1270
      V4L/DVB (11854): TDA10048: Ensure the I/F changes during DVB-T 6/7/=
8 bandwidth changes.
      V4L/DVB (11855): cx23885: Ensure we specify I/F's for all bandwidth=
s
      V4L/DVB (11856): pvrusb2: Ensure we specify I/F's for all bandwidth=
s
      V4L/DVB (11857): TDA10048: Missing two I/F's / Pll combinations fro=
m the PLL table

Steven Whitehouse (29):
      perfcounters: export perf_tpcounter_event
      decnet: Use data ready call back, rather than hand coding it
      GFS2: Update the rw flags
      GFS2: Optimise writepage for metadata
      GFS2: Something nonlinear this way comes!
      GFS2: Move journal live test at transaction start
      GFS2: Add commit=3D mount option
      GFS2: Remove a couple of unused sysfs entries
      GFS2: Umount recovery race fix
      GFS2: Update docs
      GFS2: Don't warn when delete inode fails on ro filesystem
      GFS2: Improve resource group error handling
      GFS2: Add a rgrp bitmap full flag
      GFS2: Be more aggressive in reclaiming unlinked inodes
      GFS2: Clean up some file names
      GFS2: Merge mount.c and ops_super.c into super.c
      GFS2: Move gfs2_rmdiri into ops_inode.c
      GFS2: Move gfs2_readlinki into ops_inode.c
      GFS2: Move gfs2_unlink_ok into ops_inode.c
      GFS2: Remove lockstruct subdir from gfs2 sysfs files
      GFS2: Remove args subdir from gfs2 sysfs files
      tracing: add exports to use __print_symbolic and __print_flags from=
 a module
      GFS2: Remove unused variable
      tracing: fix multiple use of __print_flags and __print_symbolic
      GFS2: Fix locking issue mounting gfs2meta fs
      GFS2: Fix cache coherency between truncate and O_DIRECT read
      GFS2: Merge gfs2_get_sb into gfs2_get_sb_meta
      GFS2: Add tracepoints
      GFS2: Remove lock_kernel from gfs2_put_super()

Stoyan Gaydarov (1):
      FRV: BUG to BUG_ON changes

Stuart Bennett (3):
      tracing: x86, mmiotrace: code consistency/legibility improvement
      tracing: x86, mmiotrace: refactor clearing/restore of page presence
      tracing: x86, mmiotrace: only register for die notifier when tracer=
 active

Sujith (28):
      ath9k: Remove a few unused flags
      ath9k: Remove redundant chainmask check
      ath9k: Cleanup debug messages
      ath9k: Change return value of ath9k_hw_fill_cap_info
      ath9k: Remove redundant variable for Interrupt Mitigation
      ath9k: Avoid unneeded casts
      ath9k: Cleanup buffer status handling
      ath9k: Remove a couple of unused variables in descriptor handling
      ath9k: Remove unused structures
      ath9k: Check for root debugfs file
      ath9k: Remove TIM from the interrupt mask
      ath9k: Remove the useless do..while loops
      ath9k: Initialize values when setting up the queue parameters
      ath9k: Trivial fix to handle AMPDU params properly
      ath9k: Clean Interrupt handling routine
      ath9k: Determine number of streams from HT capabilities
      ath9k: Fix bug in determining HT40 mode
      ath9k: Handle ASPM properly for RFKILL
      ath9k: Fix memleak on TX DMA failure
      ath9k: Fix bug in scan termination
      ath9k: Remove unused channel flags
      ath9k: Fix bug in checking HT flag
      ath9k: Fix bug in determining calibration support
      ath9k: Initialize ANI timers
      ath9k: Cleanup calibration interface
      ath9k: Use a consistent naming convention
      ath9k: Fix bug in calibration initialization
      ath9k: Remove CHANNEL_CW_INT handling in ath9k_hw_calibrate

Sukanto Ghosh (1):
      sysctl.c: remove unused variable

Sunil Mushran (6):
      ocfs2/net: Use wait_event() in o2net_send_message_vec()
      ocfs2: Pin journal head before accessing jh->b_committed_data
      ocfs2: Fix ocfs2_osb_dump()
      ocfs2: Stop orphan scan as early as possible during umount
      ocfs2: Do not initialize lvb in ocfs2_orphan_scan_lock_res_init()
      ocfs2: Disable orphan scanning for local and hard-ro mounts

Suresh Jayaraman (1):
      NFS: add support for splice writes

Suresh Siddha (5):
      x86: x2apic, IR: Clean up X86_X2APIC and INTR_REMAP config checks
      x86: x2apic, IR: Move eoi_ioapic_irq() into a CONFIG_INTR_REMAP sec=
tion
      x86: x2apic, IR: Clean up panic() with nox2apic boot option
      x86: x2apic, IR: Make config X86_UV dependent on X86_X2APIC
      x86: x2apic, IR: remove reinit_intr_remapped_IO_APIC()

Sven Schuetz (1):
      [SCSI] zfcp: Add FC pass-through support

Swen Schillig (1):
      [SCSI] zfcp: Changed D_ID left port disabled

Syed Mohammed Khasim (2):
      ARM: OMAP3: Add omap3 EVM support
      ARM: OMAP3: Add omap3 EVM defconfig

S=C3=A9guier R=C3=A9gis (1):
      via-velocity : fix no link detection on boot

Tadashi Abe (1):
      irda-usb: suspend/resume support

Takahiro Yasui (1):
      [SCSI] limit state transitions in scsi_internal_device_unblock

Takashi Iwai (175):
      ALSA: lx6464es - Use snd_card_create()
      ALSA: lx6464es - Disable lx_message_send()
      ALSA: Add missing description of lx6464es to ALSA-Configuration.txt
      ALSA: hda - Add Creative CA0110-IBG support
      ALSA: hda - Check strcpy length
      ALSA: hda - Fix channels_max setting for CA0110
      ALSA: hda - Use snd_hda_codec_get_pincfg() in patch_ca0110.c
      Merge branch 'fix/hda' into topic/hda
      ALSA: Remove deprecated snd_card_new()
      ALSA: Remove deprecated include/sound/driver.h
      ALSA: hda - Cache PCM and STREAM parameters queries
      ALSA: hda - Retry codec-verbs at errors
      ALSA: hda - Add debug prints for Realtek auto-init
      Merge branch 'topic/hda-cache' into topic/hda
      ALSA: hda - minor optimization in hda_set_power_state()
      ALSA: hda - Fix a typo in debug print for realtek auto-detection
      Merge branch 'fix/hda' into topic/hda
      ALSA: hda - Add amp initialization for realtek auto mode
      Merge branch 'fix/hda' into topic/hda
      Merge branch 'topic/hda-realtek-amp' into topic/hda
      ALSA: hda - Don't enable auto-mute but for speakers in patch_realte=
k.c
      ALSA: hda - Fix a typo in patch_realtek.c again
      Merge branch 'fix/asoc' into topic/asoc
      ALSA: Add extra delay count in PCM
      ALSA: usbaudio - Add delay account
      ALSA: ice1724 - Check error in set_rate function
      ALSA: ice1724 - Clean up definitions of DMA records
      ALSA: ice1724 - Add PCI postint to reset sequence
      ALSA: ice1724 - Allow spec driver to create own routing controls
      ALSA: ice1724 - Add ESI Maya44 support
      ALSA: hda - Fix secondary SPDIF on VT1708S and VT1702 codecs
      ALSA: hda - Fix and clean up hippo-compat HP auto-muting
      ALSA: hda - Clean up for ALC262 HP model auto-mute functions
      ALSA: hda - Clean up Realtek auto-mute unsol routines
      Merge branch 'fix/hda' into topic/hda
      ALSA: hda - Add missing models for Realtek codecs
      Merge branch 'topic/hda-vt-spdif' into topic/hda
      ALSA: hdsp - Add a comment about external firmwares for hdsp
      Merge branch 'topic/drvdata-fix' into topic/asoc
      Merge branch 'for-2.6.31' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/broonie/sound-2.6 into topic/asoc
      ALSA: hda - Disable fallback to model=3Dacer for Acer laptops
      ALSA: ctxfi - Add missing inclusion of linux/delay.h
      ALSA: ctxfi - Move PCI ID definitions to linux/pci_ids.h
      ALSA: ctxfi - Avoid unneeded pci_read_config_*() calls
      ALSA: ctxfi - Add prefix to debug prints
      ALSA: hda - Add a quirk entry for Macbook Pro 5,1
      Merge branch 'for-2.6.31' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/broonie/sound-2.6 into topic/asoc
      ASoC: Add missing __devexit in wm8940.c
      ASoC: Optimize switch/case in magician.c
      ALSA: hda - Split codec->name to vendor and chip name strings
      ALSA: hda - Show the actual chip name in 'unkown model' messages
      ALSA: hda - Avoid conflicts with snd-ctxfi driver
      ALSA: hda - Add prefix to kernel messages
      ALSA: hda - Fix digital beep tone calculation
      ALSA: ctxfi - Add depends on X86
      ALSA: hda - Reset CORB/RIRB at retrying the verb communication
      ALSA: riptide - Code clean up
      ALSA: riptide - Fix joystick resource handling
      ALSA: hda - Minor clean up of patch_sigmatel.c
      Merge branch 'fix/hda' into topic/hda
      ALSA: hda - Allow concurrent RIRB access in single_cmd mode
      ALSA: hda - Support sync after writing a verb
      ALSA: ctxfi - Add missing module parameter definitions
      ALSA: hda - Always sync writes in single_cmd mode
      ALSA: hda - Add more register bits definitions
      Merge branch 'fix/hda' into topic/hda
      Merge branch 'fix/pcm-jiffies-check' into topic/pcm-jiffies-check
      ALSA: hda - Fix reverted LED setup for HP
      ALSA: hda - Fix a typo in the previous patch
      ALSA: usb-audio - Add quirk for Roland/Edirol M-16DX
      ALSA: hda - Reorder and clean-up ALC268 quirk table
      ALSA: hda - Add codec bus reset and verb-retry at critical errors
      ALSA: hda - Limit codec-verb retry to limited hardwares
      ALSA: ctxfi - Fix Oops at mmapping
      ALSA: ctxfi - Fix a typo in MODULE_LICENSE
      ALSA: ca0106 - Add missing registrations of vmaster controls
      Merge branch 'topic/hda-ctl-reset' into topic/hda
      Merge branch 'topic/core-id-check' into topic/caiaq
      ALSA: Remove invalid GENERIC_MIX PCM sublass
      ALSA: ALSA: ctxfi - Release PCM resources at each prepare call
      ALSA: ctxfi - Fix surround mixer names
      ALSA: ctxfi - Fix PCM device naming
      ALSA: ctxfi - Fix supported PCM formats
      ALSA: ctxfi - Remove PAGE_SIZE limitation
      ALSA: ctxfi - Support SG-buffers
      Merge branch 'topic/ctxfi-fix' into topic/ctxfi
      ALSA: ca0106 - Add missing card->mixername field setup
      ALSA: bt87x - Add a quirk entry for Askey Computer Corp. MagicTView=
'99
      ALSA: powermac - Replace the rest of __init*
      ASoC: Fix build error in twl4030.c
      ALSA: ctxfi - Allow 64bit DMA
      ALSA: ctxfi - Fix endian-dependent codes
      ALSA: ctxfi - Fix previous fix for 64bit DMA
      ALSA: ctxfi - Use native timer interrupt on emu20k1
      ALSA: ctxfi - Set periods_min to 2
      ALSA: ctxfi - Clean up / optimize
      ALSA: ctxfi - Set device 0 for mixer control elements
      ALSA: Clean up 64bit division functions
      ALSA: ctxfi - Add missing inclusion of linux/math64.h
      ALSA: pcm - Fix update of runtime->hw_ptr_interrupt
      ALSA: ctxfi - Optimize the native timer handling using wc counter
      ALSA: ca0106 - Fix master volume scale
      ALSA: ctxfi - Make volume controls more intuitive
      ALSA: ctxfi - Fix DMA mask for emu20k2 chip
      ALSA: ctxfi - Remove useless initializations and cast
      ALSA: ctxfi - Fix possible buffer pointer overrun
      ALSA: ctxfi - Fix / clean up hw20k2 chip code
      ALSA: emu10k1 - Fix minimum periods for efx playback
      ALSA: pcm - A helper function to compose PCM stream name for debug =
prints
      ALSA: hda - Fix the previous tagra-8ch patch
      ALSA: ctxfi - Clean up probe routines
      ALSA: ctxfi - Fix wrong model id for UAA
      ALSA: ctxfi - Add use_system_timer module option
      ALSA: ctxfi - Add missing start check in atc_pcm_playback_start()
      ALSA: ctxfi - Check the presence of SRC instance in PCM pointer cal=
lbacks
      ALSA: ctxfi - Clear PCM resources at hw_params and hw_free
      Merge branch 'topic/asoc' into for-linus
      Merge branch 'topic/au88x0' into for-linus
      Merge branch 'topic/ca0106' into for-linus
      Merge branch 'topic/caiaq' into for-linus
      Merge branch 'topic/cleanup' into for-linus
      Merge branch 'topic/core-id-check' into for-linus
      Merge branch 'topic/ctxfi' into for-linus
      Merge branch 'topic/div64-cleanup' into for-linus
      Merge branch 'topic/emu10k1' into for-linus
      Merge branch 'topic/hda' into for-linus
      Merge branch 'topic/hdsp' into for-linus
      Merge branch 'topic/lx6464es' into for-linus
      Merge branch 'topic/maya44' into for-linus
      Merge branch 'topic/misc' into for-linus
      Merge branch 'topic/oxygen' into for-linus
      Merge branch 'topic/pcm-delay' into for-linus
      Merge branch 'topic/pcm-jiffies-check' into for-linus
      Merge branch 'topic/pcm-subclass-fix' into for-linus
      Merge branch 'topic/riptide' into for-linus
      Merge branch 'topic/sc6000' into for-linus
      Merge branch 'topic/section-fix' into for-linus
      Merge branch 'topic/seq-kconfig-cleanup' into for-linus
      Merge branch 'topic/usb-audio' into for-linus
      ALSA: pcm - Update document about xrun_debug proc file
      Merge branch 'topic/asoc' into for-linus
      Merge branch 'topic/caiaq' into for-linus
      Merge branch 'topic/hda' into for-linus
      Merge branch 'topic/lx6464es' into for-linus
      Merge branch 'topic/misc' into for-linus
      Merge branch 'topic/pcm-jiffies-check' into for-linus
      Merge branch 'topic/ps3' into for-linus
      ALSA: ctxfi - Replace atc lock to mutex
      ALSA: hda - Add quirk for Acer Aspire 6935G
      ALSA: intel8x0 - Fix PCM position craziness
      ALSA: ctxfi - Fix deadlock with xfi-timer
      Merge branch 'topic/asoc' into for-linus
      Merge branch 'topic/ctxfi' into for-linus
      Merge branch 'topic/hda' into for-linus
      Merge branch 'topic/intel8x0' into for-linus
      Merge branch 'topic/usb-audio' into for-linus
      ALSA: hda - Fix memory leak at codec creation
      ASoC: Kill BUS_ID_SIZE
      ALSA: hda - Add model=3D6530g option
      Merge branch 'topic/asoc' into for-linus
      Merge branch 'topic/caiaq' into for-linus
      Merge branch 'topic/hda' into for-linus
      ALSA: ctxfi - Allow unknown PCI SSIDs
      ALSA: hda - Fix unsigned comparison in patch_sigmatel.c
      ALSA: hda - Get back Input Source for ALC262 toshiba-s06 model
      ALSA: hda - Add quirk for Sony VAIO Z21MN
      ALSA: hda - Fix check of input source type for realtek codecs
      ALSA: hda - Add digital-mic support to ALC262 auto model
      ALSA: hda - Make jack-plug notification selectable
      Merge branch 'topic/asoc' into for-linus
      Merge branch 'topic/ctxfi' into for-linus
      Merge branch 'topic/hda' into for-linus
      Merge branch 'topic/misc' into for-linus
      Merge branch 'topic/pcm-jiffies-check' into for-linus
      Merge branch 'topic/seq-midi-fix' into for-linus

Tanli Chang (1):
      niu: Add support for C10NEM

Tao Ma (5):
      ocfs2: Don't printk the error when listing too many xattrs.
      ocfs2: Remove redundant gotos in ocfs2_mount_volume()
      ocfs2: Adjust rightmost path in ocfs2_add_branch.
      ocfs2: Update atime in splice read if necessary.
      ocfs2/trivial: Wrap ocfs2_sysfile_cluster_lock_key within define.

Tejun Heo (115):
      percpu: don't put the first chunk in reverse-map rbtree
      block: clear req->errors on bio completion only for fs requests
      ide-tape: remove back-to-back REQUEST_SENSE detection
      ide: use blk_run_queue() instead of blk_start_queueing()
      ide: don't set REQ_SOFTBARRIER
      ide kill unused ide_cmd->special
      ide-cd: clear sense buffer before issuing request sense
      ide-floppy: block pc always uses bio
      ide-taskfile: don't abuse rq->buffer
      ide-atapi: don't abuse rq->buffer
      ide-cd: don't abuse rq->buffer
      ide-cd,atapi: use bio for internal commands
      ide-pm: don't abuse rq->data
      ide-tape,floppy: fix failed command completion after request sense
      ide-atapi,tape,floppy: allow ->pc_callback() to change rq->data_len
      ide-tape: use single continuous buffer
      ide-tape: use standard data transfer mechanism
      ide-tape: kill idetape_bh
      ide-tape: unify r/w init paths
      ide-tape: use byte size instead of sectors on rw issue functions
      ide-tape: simplify read/write functions
      ide-atapi: kill unused fields and callbacks
      ide: drop rq->data handling from ide_map_sg()
      ide-dma: don't reset request fields on dma_timeout_retry()
      mg_disk: fix locking
      hd: fix locking
      block: clear req->errors on bio completion only for fs requests
      ide-tape: remove back-to-back REQUEST_SENSE detection
      ide: use blk_run_queue() instead of blk_start_queueing()
      ide: don't set REQ_SOFTBARRIER
      ide kill unused ide_cmd->special
      ide-cd: clear sense buffer before issuing request sense
      ide-floppy: block pc always uses bio
      ide-taskfile: don't abuse rq->buffer
      ide-atapi: don't abuse rq->buffer
      ide-cd: don't abuse rq->buffer
      ide-cd,atapi: use bio for internal commands
      ide-pm: don't abuse rq->data
      ide-tape,floppy: fix failed command completion after request sense
      ide-atapi,tape,floppy: allow ->pc_callback() to change rq->data_len
      ide-tape: use single continuous buffer
      ide-tape: use standard data transfer mechanism
      ide-tape: kill idetape_bh
      ide-tape: unify r/w init paths
      ide-tape: use byte size instead of sectors on rw issue functions
      ide-tape: simplify read/write functions
      ide-atapi: kill unused fields and callbacks
      ide: drop rq->data handling from ide_map_sg()
      ide-dma: don't reset request fields on dma_timeout_retry()
      block: merge blk_invoke_request_fn() into __blk_run_queue()
      block: kill blk_start_queueing()
      block: don't set REQ_NOMERGE unnecessarily
      block: cleanup REQ_SOFTBARRIER usages
      block: clean up misc stuff after block layer timeout conversion
      block: reorder request completion functions
      block: reorganize request fetching functions
      block: kill blk_end_request_callback()
      block: clean up request completion API
      block: move rq->start_time initialization to blk_rq_init()
      block: implement and use [__]blk_end_request_all()
      block: replace end_request() with [__]blk_end_request_cur()
      arm-omap: don't abuse rq->data
      block: kill rq->data
      block: make blk_end_request_cur() return bool
      block: don't init rq fields unnecessarily
      amiflop,ataflop,xd,mg_disk: clean up unnecessary stuff from block d=
rivers
      ps3disk: simplify request completion
      sunvdc: kill vdc_end_request()
      ubd: cleanup completion path
      ubd: drop unnecessary rq->sector manipulation
      hd: clean up request completion paths
      swim3: clean up request completion paths
      swim: clean up request completion paths
      mg_disk: fold mg_disk.h into mg_disk.c
      mg_disk: clean up request completion paths
      fuse: misc cleanups
      fuse: update fuse_conn_init() and separate out fuse_conn_kill()
      fuse: export symbols to be used by CUSE
      nbd: don't clear rq->sector and nr_sectors unnecessarily
      ide-tape: don't initialize rq->sector for rw requests
      block: add rq->resid_len
      block: implement blk_rq_pos/[cur_]sectors() and convert obvious one=
s
      block: convert to pos and nr_sectors accessors
      ide: convert to rq pos and nr_sectors accessors
      block: drop request->hard_* and *nr_sectors
      block: cleanup rq->data_len usages
      ide: cleanup rq->data_len usages
      block: hide request sector and data_len
      block: blk_rq_[cur_]_{sectors|bytes}() usage cleanup
      ide: dequeue in-flight request
      mg_disk: fix queue hang / infinite retry on !fs requests
      mg_disk: dequeue and track in-flight request
      hd: dequeue and track in-flight request
      ataflop: dequeue and track in-flight request
      swim3: dequeue in-flight request
      xsysace: dequeue in-flight request
      paride: dequeue in-flight request
      ps3disk: dequeue in-flight request
      amiflop: dequeue in-flight request
      swim: dequeue in-flight request
      xd: dequeue in-flight request
      mtd_blkdevs: dequeue in-flight request
      jsflash: dequeue in-flight request
      z2ram: dequeue in-flight request
      block: convert to dequeueing model (easy ones)
      gdrom: dequeue in-flight request
      block: implement and enforce request peek/start/fetch
      scsi: fix resid_len mis-conversion in scsi_end_request()
      ub: use __blk_end_request_all()
      block: set rq->resid_len to blk_rq_bytes() on issue
      bio: always copy back data for copied kernel requests
      CUSE: implement CUSE - Character device in Userspace
      ahci: misc cleanups for EM stuff
      sata_nv: use hardreset only for post-boot probing
      libata: don't set IORDY for reset

Tero Kristo (1):
      OMAP3: Add support for DPLL3 divisor values higher than 2

Tero Saarni (1):
      Input: synaptics - add support for reporting x/y resolution

Tetsuo Handa (9):
      tomoyo: remove "undelete domain" command.
      rootplug: Remove redundant initialization.
      smack: Remove redundant initialization.
      TOMOYO: Remove unused mutex.
      TOMOYO: Remove redundant markers.
      TOMOYO: Simplify policy reader.
      TOMOYO: Remove unused parameter.
      TOMOYO: Remove unused field.
      TOMOYO: Add description of lists and structures.

Thadeu Lima de Souza Cascardo (5):
      Input: fix typo in documentation
      Input: simplify name handling for certain input handles
      trivial: typo (en|dis|avail|remove)bale -> (en|dis|avail|remove)abl=
e
      Trivial: fix typo s/balence/balance/
      trivial: fix typo compatiable/compatiability has extra 'a'.

Theodore Kilgore (1):
      V4L/DVB (11483): gspca - mr97310a: Webcam 093a:010f added.

Theodore Ts'o (46):
      tracing: Add documentation for the power tracer
      tracing: Document the event tracing system
      ext4: Fallback to vmalloc if kmalloc can't allocate s_flex_groups a=
rray
      ext4: Use is_power_of_2() for clarity
      ext4: Simplify ext4_commit_super()'s function signature
      ext4: Fix and simplify s_dirt handling
      ext4: Use separate super_operations structure for no_journal filesy=
stems
      ext4: Avoid races caused by on-line resizing and SMP memory reorder=
ing
      ext4: Remove outdated comment about lock_super()
      ext4: ext4_mark_recovery_complete() doesn't need to use lock_super
      ext4: Replace lock/unlock_super() with an explicit lock for the orp=
han list
      ext4: Replace lock/unlock_super() with an explicit lock for resizin=
g
      jbd2: convert instrumentation from markers to tracepoints
      ext4: convert instrumentation from markers to tracepoints
      ext4: avoid unnecessary spinlock in critical POSIX ACL path
      ext4: Don't avoid using BLOCK_UNINIT block groups in mballoc
      ext4: Move the ext4_i.h header file into ext4.h
      ext4: Move the ext4_sb.h header file into ext4.h
      ext4: Move fs/ext4/namei.h into ext4.h
      ext4: Move fs/ext4/group.h into ext4.h
      ext4: fix the length returned by fiemap for an unallocated extent
      ext4: Simplify function signature for ext4_da_get_block_write()
      ext4: Rename ext4_get_blocks_handle() to be ext4_ind_get_blocks()
      ext4: Rename ext4_get_blocks_wrap() to be ext4_get_blocks()
      ext4: Define a new set of flags for ext4_get_blocks()
      ext4: Add documentation to the ext4_*get_block* functions
      ext4: Add BUG_ON debugging checks to noalloc_get_block_write()
      ext4: Merge ext4_da_get_block_write() into mpage_da_map_blocks()
      ext4: Clean up ext4_get_blocks() so it does not depend on bh_result=
->b_state
      ext4: Add a comprehensive block validity check to ext4_get_blocks()
      ext4: down i_data_sem only for read when walking tree for fiemap
      ext4: remove unused function __ext4_write_dirty_metadata
      ext4: Clean up calls to ext4_get_group_desc()
      Documentation: Add "how to write a good patch summary" to Submittin=
gPatches
      ext4: Don't treat a truncation of a zero-length file as replace-via=
-truncate
      fs: Remove i_cindex from struct inode
      fs: Rearrange inode structure elements to avoid waste due to paddin=
g
      ext4: change s_mount_opt to be an unsigned int
      ext4: update the s_last_mounted field in the superblock
      ext4: move the abort flag from s_mount_opts to s_mount_flags
      ext4: document the "abort" mount option
      ext4: Use a hash of the topdir directory name for the Orlov parent =
group
      ext4: Fix 64-bit block type problem on 32-bit platforms
      ext4: Fix up whitespace issues in fs/ext4/inode.c
      ext4: Don't update ctime for non-extent-mapped inodes
      ext4: avoid unnecessary spinlock in critical POSIX ACL path

Thomas Chou (2):
      microblaze: clean LDFLAGS to build kernel
      mtd: plat_nand: fix section error

Thomas Gleixner (46):
      performance counters: core code
      perf counters: protect them against CSTATE transitions
      perf counters: clean up 'raw' type API
      perf counters: expand use of counter->event
      signals: split do_tkill
      signals: implement sys_rt_tgsigqueueinfo
      x86: hookup sys_rt_tgsigqueueinfo
      Merge branch 'core/signal' into perfcounters/core
      perf_counter tools: remove build generated files
      perfcounter tools: move common defines ... to local header file
      perfcounter tools: make rdclock an inline function
      perfcounter tools: fix pointer mismatch
      perfcounter tools: get the syscall number from arch/*/include/asm/u=
nistd.h
      sh: remove obsolete no_irq_type
      sh: remove obsolete hw_interrupt_type
      avr32: remove obsolete hw_interrupt_type
      futex: remove the wait queue
      sched, timers: move calc_load() to scheduler
      sched, timers: cleanup avenrun users
      Merge branch 'core/urgent' into core/futexes
      futex: cleanup error exit
      futex: fix restart for early wakeup in futex_wait_requeue_pi()
      futex: fix restart in wait_requeue_pi
      x86, mce: unify Intel thermal init, prepare
      x86, mce: unify Intel thermal init
      x86, mce: Cleanup symbols in intel thermal codes
      x86, mce: Cleanup MCG definitions
      x86, mce: remove mce_init unused argument
      perf_counter tools: Add 'perf list' to list available events
      perf_counter tools: Add help for perf list
      perf_counter, x86: Implement generalized cache event types, add Cor=
e2 support
      perf_counter, x86: Implement generalized cache event types, add Ato=
m support
      perf_counter, x86: Implement generalized cache event types, add AMD=
 support
      perf_counter, x86: Clean up hw_cache_event ids copies
      x86: memtest: use pointers of equal type for comparison
      clocksource: prevent selection of low resolution clocksourse also f=
or nohz=3Don
      x86: hpet: Mark per cpu interrupts IRQF_TIMER to prevent resume fai=
lure
      [IA64] remove obsolete no_irq_type
      [IA64] remove obsolete irq_desc_t typedef
      [IA64] remove obsolete hw_interrupt_type
      alpha: remove obsolete hw_interrupt_type
      m32r: remove obsolete hw_interrupt_type
      um: remove obsolete hw_interrupt_type
      remove put_cpu_no_resched()
      drivers/mfd: remove obsolete irq_desc_t typedef
      futex: Fix the write access fault problem for real

Thomas Hellstrom (4):
      drm: Add the TTM GPU memory manager subsystem.
      ttm: Return -ERESTART when a signal interrupts bo eviction.
      drm: Apply "Memory fragmentation from lost alignment blocks"
      drm/ttm: fix an error path to exit function correctly

Thomas Mingarelli (1):
      [WATCHDOG] hpwdt: Add NMI sourcing

Thomas Petazzoni (1):
      macb: Add support of the netpoll API

Thomas Reitmayr (2):
      [ARM] orion5x: Change names of defines for Reset-Out-Mask register
      [ARM] Kirkwood: Add the watchdog timer as a platform device.

Thomas Renninger (3):
      [CPUFREQ] ondemand: Uncouple minimal sampling rate from HZ in NO_HZ=
 case
      [CPUFREQ] powernow-k8: Set transition latency to 1 if ACPI tables e=
xport 0
      [CPUFREQ] Only set sampling_rate_max deprecated, sampling_rate_min =
is useful

Tilman Schmidt (14):
      ISDN: update Documentation/isdn/00-INDEX
      gigaset: remove obsolete references to m10x state table
      gigaset: fix possible oops in error handling
      gigaset: skip unnecessary hex formatting
      gigaset: fix error return code
      gigaset: documentation update
      gigaset: move up Kconfig inclusion point
      gigaset: remove UNDOCREQ config option
      gigaset: remove unused structure member rcvbytes
      isdn: rename capi_ctr_reseted() to capi_ctr_down()
      isdn: kerneldoc for capiutil.c
      isdn: prevent NULL ptr Oops in capi_cmsg2str()
      isdn: extend INTERFACE.CAPI document
      isdn: clean up documentation index

Tim Abbott (1):
      ftrace: use .sched.text, not .text.sched in recordmcount.pl

Tim Bird (1):
      ring-buffer: fix bug in ring_buffer_discard_commit

Tim Blechmann (3):
      perf_counter: include missing header
      ALSA: lx6464es - driver for the digigram lx6464es interface
      ALSA: lx6464es - support standard alsa module parameters

Tim Gardner (1):
      Staging: winbond: mac80211 - unify config_interface and bss_info_ch=
anged

Timo Kokkonen (1):
      [WATCHDOG] twl4030 watchdog driver

Timo Teras (1):
      neigh: fix state transition INCOMPLETE->FAILED via Netlink request

Timo Ter=C3=A4s (1):
      ipv4: update ARPD help text

Timur Tabi (1):
      powerpc: Introduce macro spin_event_timeout()

Tobias Doerffel (1):
      ath5k: added cfg80211 based rfkill support

Tobias Klauser (5):
      ath5k: Storage class should be before const qualifier
      s2io: Remove private boolean definitions
      V4L/DVB (11654): gspca - m5602: Storage class should be before cons=
t qualifier
      V4L/DVB (11724): firedtv: Storage class should be before const qual=
ifier
      Staging: pohmelfs: Storage class should be before const qualifier

Tom Goff (1):
      PIM-SM: namespace changes

Tom Mingarelli (1):
      [WATCHDOG] hpwdt: Add NMI priority option

Tom Zanussi (9):
      tracing/filters: add run-time field descriptions to TRACE_EVENT_FOR=
MAT events
      tracing/filters: add TRACE_EVENT_FORMAT_NOFILTER event macro
      tracing/infrastructure: separate event tracer from event support
      tracing/filters: use ring_buffer_discard_commit() in filter_check_d=
iscard()
      tracing/filters: allow on-the-fly filter switching
      tracing/filters: add filter_mutex to protect filter predicates
      tracing/filters: move preds into event_filter object
      tracing/filters: distinguish between signed and unsigned fields
      tracing/filters: a better event parser

Tomas 'Sleep_Walker' Cech (2):
      [ARM] pxa/treo680: initial support
      MAINTAINERS: add entry for Palm Treo680

Tomas Szepe (1):
      CONFIG_FILE_LOCKING should not depend on CONFIG_BLOCK

Tomas Winkler (4):
      iwlwifi: replace test_and_set_bit by set_bit in clear stations func=
tion
      iwlwifi: drop struct iwl3945_hw_key
      iwlwifi: drop iwl3945_tid_data
      iwlwifi: unify station management

Tomi Valkeinen (1):
      ARM: OMAP2/3: DMA: implement trans copy and const fill

Tony Breeds (2):
      ixgbe: Be explict with what we are !'ing in ixgbe_sfp_config_module=
_task()
      powerpc/mpic: Cleanup mpic_find() implementation

Tony Cook (1):
      USB: mos7840: fix debug log messages

Tony Lindgren (24):
      ARM: OMAP2/3: Remove OMAP2_32KSYNCT_BASE
      ARM: OMAP2/3: Remove OMAP_PRM_REGADDR and OMAP2_PRM_BASE
      ARM: OMAP2/3: Move define of OMAP2_VA_IC_BASE to be local to entry-=
macro.S
      ARM: OMAP2/3: Remove OMAP2_PRCM_BASE
      ARM: OMAP2/3: Remove OMAP_CM_REGADDR
      ARM: OMAP2/3: Reorganize Makefile to add omap4 support
      ARM: OMAP1: Misc clean-up
      ARM: OMAP2/3: Remove OMAP2_32KSYNCT_BASE
      ARM: OMAP2/3: Remove OMAP_PRM_REGADDR and OMAP2_PRM_BASE
      ARM: OMAP2/3: Move define of OMAP2_VA_IC_BASE to be local to entry-=
macro.S
      ARM: OMAP2/3: Remove OMAP2_PRCM_BASE
      ARM: OMAP2/3: Remove OMAP_CM_REGADDR
      ARM: OMAP2/3: Reorganize Makefile to add omap4 support
      Merge branch 'omap-clock-upstream' of git://git.pwsan.com/linux-2.6=
 into for-next
      ARM: OMAP2/3: Add generic smc91x support when connected to GPMC
      ARM: OMAP: Add some entries to MAINTAINERS
      ARM: OMAP2/3: Remove L4_WK_OMAP_BASE, L4_PER_OMAP_BASE, L4_EMU_BASE=
, L3_OMAP_BASE
      ARM: OMAP3: Initialize more devices for LDP
      Merge branch 'omap-upstream' into for-next
      Merge branch 'omap3-upstream' into for-next
      Merge branch 'omap3-boards' into for-next
      Merge branch 'omap4' into for-next
      [ARM] 5536/1: Move clk_add_alias() to arch/arm/common/clkdev.c
      i2c-omap: Fix build breaking typo cpu_is_omap_2430

Tony Luck (3):
      [IA64] hook up new rt_tgsigqueueinfo syscall
      [IA64] ia64 does not need umount2() syscall
      Pull for-2.6.31 into release

Tony Thompson (1):
      ARMv7: Mark the PTWs inner WBWA on SMP and WB on UP

Tony Vroon (1):
      ALSA: hda - Acer Inspire 6530G model for Realtek ALC888

Torben Schulz (1):
      ALSA: hda - Improved MacBook 3,1 support

Torsten Ertbjerg Rasmussen (1):
      rtc: rtc-ds1742 nvram attribute fix

Toshiyuki Okajima (1):
      ext4: fix dx_map_entry to support 256k directory blocks

Trent Piepho (15):
      V4L/DVB (11964): b2c2: Fix problems with frontend attachment
      V4L/DVB (11901): v4l2: Create helper function for bounding and alig=
ning images
      V4L/DVB (11902): pxa-camera: Use v4l bounding/alignment function
      V4L/DVB (11903): sh_mobile_ceu_camera: Use v4l bounding/alignment f=
unction
      V4L/DVB (11904): zoran: Use v4l bounding/alignment functiob
      V4L/DVB (11905): vivi: Use v4l bounding/alignment function
      V4L/DVB (11906): saa7134: Use v4l bounding/alignment function
      V4L/DVB (11907): cx88: Use v4l bounding/alignment function
      V4L/DVB (11908): w8968cf: Use v4l bounding/alignment function
      V4L/DVB (11909): cx23885: Use v4l bounding/alignment function
      V4L/DVB (11910): mt9: Use v4l bounding/alignment function
      V4L/DVB (11911): cx231xx: Use v4l bounding/alignment function
      V4L/DVB (11912): em28xx: Use v4l bounding/alignment function
      V4L/DVB (11913): cx231xx: TRY_FMT should not actually set anything
      V4L/DVB (12003): v4l2: Move bounding code outside I2C ifdef block

Trond Myklebust (16):
      nfsd: Use write gathering only with NFSv2
      SUNRPC: Fix a missing "break" option in xs_tcp_setup_socket()
      NFSv4: Fix the 'nolock' option regression
      NFSv4: Move error handling out of the delegation generic code
      NFSv4: Handle more errors when recovering open file and locking sta=
te
      NFS: Ensure we always hold the BKL when dereferencing inode->i_floc=
k
      NFSv4/NLM: Push file locking BKL dependencies down into the NLM lay=
er
      Merge commit 'linux-pnfs/nfs41-for-2.6.31' into nfsv41-for-2.6.31
      Merge branch 'devel-for-2.6.31' into for-2.6.31
      SUNRPC: Fix the TCP server's send buffer accounting
      VFS: Uninline the function put_mnt_ns()
      VFS: Add VFS helper functions for setting up private namespaces
      NFSv4: Replace nfs4_path_walk() with VFS path lookup in a private n=
amespace
      NFS: Fix nfs_path() to always return a '/' at the beginning of the =
path
      NFS: Correct the NFS mount path when following a referral
      VFS: Switch init_mount_tree() to use the new create_mnt_ns() helper

Troy Kisky (2):
      davinci: interrupts: get_irqnr_and_base: save an instruction
      ASoC: codec tlv320aic23 fix bogus divide by 0 message

Troy Moure (1):
      acer-wmi: fix rfkill conversion

Ulrich Dangel (1):
      Input: ALPS - handle touchpoints buttons correctly

Ulrik Bech Hald (1):
      [WATCHDOG] OMAP fixes: enable clock in probe, trigger timer reload

Uri Shkolnik (42):
      V4L/DVB (11812): Siano: smsusb - add big endian support
      V4L/DVB (11239): sdio: add cards ids for sms (Siano Mobile Silicon)=
 MDTV receivers
      V4L/DVB (11240): siano: add high level SDIO interface driver for SM=
S based cards
      V4L/DVB (11552): Siano: SDIO interface driver - remove two redundan=
t lines
      V4L/DVB (11554): Siano: core header - add definitions and structure=
s
      V4L/DVB (11555): Siano: core - move and update the main core struct=
ure declaration
      V4L/DVB (11556): Siano: core header - indentation
      V4L/DVB (11559): Siano: add support for infra-red (IR) controllers
      V4L/DVB (11561): Siano: add messages handling for big-endian target
      V4L/DVB (11726): Modify the file license to match all other Siano's=
 files
      V4L/DVB (11727): Siano: core header - update include files
      V4L/DVB (11728): Siano: smsdvb - modify license
      V4L/DVB (11729): Siano: smsdvb - remove redundent complete instruct=
ion
      V4L/DVB (11776): Siano: smsusb - update license
      V4L/DVB (11777): Siano: smsusb - handle byte ordering and big endia=
nity
      V4L/DVB (11778): Siano: smsusb - lost buffers bug fix
      V4L/DVB (11779): Siano: Makefile - add smsendian to build
      V4L/DVB (11781): Siano: smsdvb - add big endian support
      V4L/DVB (11782): Siano: smsdvb - use 'push' status mechanism
      V4L/DVB (11783): Siano: smsdvb - small typo fix ad module author
      V4L/DVB (11813): Siano: move dvb-api headers' includes to dvb adapt=
er
      V4L/DVB (11814): Siano: smscards - add gpio look-up table
      V4L/DVB (11815): Siano: bind infra-red component
      V4L/DVB (11816): Siano: USB - move the device id table to the cards=
 module
      V4L/DVB (11817): Siano: smscards - fix wrong firmware assignment
      V4L/DVB (11818): Siano: smscards - assign gpio to HPG targets
      V4L/DVB (11819): Siano: smscore - fix get_common_buffer bug
      V4L/DVB (11820): Siano: smscore - fix byte ordering bug
      V4L/DVB (11821): Siano: smscore - fix isdb-t firmware name
      V4L/DVB (11822): Siano: smscore - bug fix at get_device_mode
      V4L/DVB (11823): Siano: smsusb - fix typo in module description
      V4L/DVB (11824): Siano: smsusb - change exit func debug msg
      V4L/DVB (11883): Siano: cards - add two additional (USB) devices
      V4L/DVB (11884): Siano: smssdio - revert to stand alone module
      V4L/DVB (11885): Siano: Add new GPIO management interface
      V4L/DVB (11886): Siano: smscore - fix some new GPIO definitions nam=
es
      V4L/DVB (11887): Siano: smscards - add board (target) events
      V4L/DVB (11888): Siano: smsusb - remove redundant ifdef
      V4L/DVB (11889): Siano: smsdvb - add DVB v3 events
      V4L/DVB (11890): Siano: smscore - remove redundant code
      V4L/DVB (11891): Siano: smscore - bind the GPIO SMS protocol
      V4L/DVB (11892): Siano: smsendian - declare function as extern

Ursula Braun (10):
      iucv: provide second per-cpu IUCV command parameter block
      af_iucv: Fix merge.
      qeth: avoid crash after detach of replugged device
      ctcm: avoid crash in ctcm_remove_device
      qeth: support z/VM VSWITCH Port Isolation
      qeth: omit upstream checksumming for HiperSockets
      [S390] iucv: establish reboot notifier
      [S390] pm: iucv power management callbacks.
      [S390] pm: netiucv power management callbacks.
      [S390] PM: af_iucv power management callbacks.

Uwe Kleine-K=C3=B6nig (5):
      hwrng: omap - Move probe function to .devinit.text
      mmc/omap: make mmci-omap using platform_driver_probe
      USB: move twl4030_usb's probe function to .devinit.text
      USB: move r8a66597_hcd's probe function to .devinit.text
      USB: move orion-ehci's probe function to .devinit.text

Vaidyanathan Srinivasan (1):
      sched: Don't export sched_mc_power_savings on multi-socket single c=
ore system

Valentin Longchamp (10):
      mx31moboard: clean-up of board support
      mx31: define various pins used on mx31moboard (v2)
      mx31moboard: setup all pins (v2)
      mx31moboard: add i2c support (v2)
      mx31moboard: add sdhc support (v3)
      mx31: remove gpio_request calls from iomux code
      mx31moboard: add support for usb OTG device (v3)
      mx31: add camera device
      mx31: changed CONSISTENT_DMA_SIZE to 8M for mx31 video
      mx31: correct csi_clk parent (v2)

Vasanthakumar Thiagarajan (12):
      mac80211: Don't access managed mode bits in non-managed mode
      ath9k: Remove bogus break after return
      ath9k: Cleanup ineffective return values
      ath9k: Print hw reset failure status as signed int
      ath9k: Remove unused parameters which are passed to ath_beacon_conf=
ig_X()
      ath9k: cleanup beacon parameters configuration
      ath9k: Move PS wakeup/restore calls from isr to tasklet
      ath9k: Fix write callback of 'debug' which configures debug mask
      mac80211: Fix the way ADDBA request count being modified
      ath9k: Fix tx stuck when connected to aggr disabled HT AP
      ath9k: Add helper to get ath9k specific current channel
      ath9k: Make sure we have current channel in ah_curchan before rf di=
sable/enable

Vasu Dev (5):
      fcoe: consolidates netdev related config and cleanup for spma mode
      fcoe: adds spma mode support
      [SCSI] fcoe: reduces lock cost when adding a new skb to fcoe_pendin=
g_queue
      [SCSI] fcoe: removes fcoe_watchdog
      [SCSI] fcoe: removes reserving memory for vlan_ethdr on tx path

Vegard Nossum (28):
      x86: add save_stack_trace_bp() for tracing from a specific stack fr=
ame
      stacktrace: add forward-declaration struct task_struct
      tasklets: new tasklet scheduling function
      kmemcheck: add the kmemcheck documentation
      kmemcheck: add the kmemcheck core
      x86: add hooks for kmemcheck
      kmemcheck: add mm functions
      kmemcheck: add DMA hooks
      slub: add hooks for kmemcheck
      crypto: don't track xor test pages with kmemcheck
      kmemcheck: don't track page tables
      kmemcheck: add hooks for page- and sg-dma-mappings
      kmemcheck: add hooks for the page allocator
      kmemcheck: enable in the x86 Kconfig
      kmemcheck: add opcode self-testing at boot
      kmemcheck: introduce bitfield API
      net: use kmemcheck bitfields API for skbuff
      net: annotate bitfields in struct inet_sock
      ieee1394: annotate bitfield
      ieee1394/csr1212: fix false positive kmemcheck report
      net: annotate inet_timewait_sock bitfields
      c2port: annotate bitfield for kmemcheck
      net: annotate struct sock bitfield
      trace: annotate bitfields in struct ring_buffer_event
      fs: introduce __getname_gfp()
      fs: fix do_mount_root() false positive kmemcheck warning
      signal: fix __send_signal() false positive kmemcheck warning
      Merge commit 'linus/master' into HEAD

Vikram Pandita (3):
      ARM: OMAP2/3: Serial: Remove arch_initcall dependency
      ARM: OMAP3: Add support for OMAP3 Zoom2 board
      ARM: OMAP3: Defconfig for Zoom2 board

Ville Syrjala (1):
      Input: ati_remote2 - use non-atomic bitops

Vimal Singh (2):
      mtd: nand: fix 512 byte software ecc support
      mtd: nand: add OMAP2/OMAP3 NAND driver

Vinay Sridhar (1):
      powerpc/xmon: Add dl command to dump contents of __log_buf

Vincent Minet (1):
      ext4: Fix spinlock assertions on UP systems

Viral Mehta (2):
      trivial: remove extra space
      USB: xhci: replace if-elseif-else with switch-case

Vivek Kutal (1):
      fbdev: *bfin*: drop unnecessary calls to memset

Vivek Natarajan (2):
      ath9k: No need to abort Rx path when autosleep is enabled.
      ath9k: Disable autosleep feature for AR9285 based chipsets.

Vlad Yasevich (1):
      sctp: support non-blocking version of the new sctp_connectx() API

Vladimir Barinov (7):
      MX27ADS: setup all pins at once in one table
      MX27ADS: Add NAND support
      MX27ADS: Add I2C support
      MX27ADS: Add framebuffer support
      MX27ADS: Add 1-wire support
      MX27ADS: Add SDHC support
      mtd: MXC NAND support for 2KiB page size flashes

Vladislav Zolotarov (4):
      bnx2x: FW 4.8.53.0
      bnx2x: Separated FW from the source.
      bnx2x: Removed blob file
      bnx2x: driver version 1.48.105-1

Wai Yew CHAY (2):
      ALSA: SB X-Fi driver merge
      ALSA: ctxfi - Add PM support

Wan ZongShun (1):
      Input: add support for touchscreen on W90P910 ARM platform

Wang Chen (1):
      nfsd: nfs4_stat_init cleanup

Wang Tinggong (1):
      trivial: rbtree.txt: fix rb_entry() parameters in sample code

Waskiewicz Jr, Peter P (2):
      ixgbe: Disallow SFP 1G modules in the SFP+ cages for 82598 and 8259=
9
      ixgbe: Add SAN MAC address to the RAR, return the address to DCB

Wayne Boyer (2):
      ipr: add test for MSI interrupt support
      ipr: differentiate pci-x and pci-e based adapters

Wei Ni (1):
      ALSA: hda - Support NVIDIA 8 channel HDMI audio

Wei Yongjun (12):
      rds: use kmem_cache_zalloc instead of kmem_cache_alloc/memset
      at76c50x-usb: remove pointless conditional before kfree_skb()
      wireless: fix to set dev->broadcast correctly
      sctp: fix error cause codes of ADD-IP extension
      sctp: fix report unrecognized parameter in ACSONF-ACK
      sctp: fix the error code when ASCONF is received with invalid addre=
ss
      sctp: fix a typo in net/sctp/sm_statetable.c
      sctp: fix to only enable IPv6 address support on PF_INET6 socket
      sctp: fix panic when T2-shutdown timer expire on removed transport
      sctp: fix panic when T4-rto timer expire on removed transport
      sctp: fix to choose alternate destination when retransmit ASCONF ch=
unk
      KVM: remove pointless conditional before kfree() in lapic initializ=
ation

Weidong Han (7):
      docs, x86: add nox2apic back to kernel-parameters.txt
      x86, intr-remap: fix ack for interrupt remapping
      x86, intr-remap: enable interrupt remapping early
      x86, intr-remap: add option to disable interrupt remapping
      x86, intr-remap: fix x2apic/intr-remap resume
      Intel-IOMMU, intr-remap: set the whole 128bits of irte when modify/=
free it
      Intel-IOMMU, intr-remap: source-id checking

Wen-chien Jesse Sung (1):
      V4L/DVB (11730): af9015: support for KWorld MC810

Werner Almesberger (2):
      [ARM] S3C6410: Add CAMIF clock
      [ARM] S3C64XX: Add HCLKx2

Wey-Yi Guy (22):
      iwlwifi: merge and better support of suspend/resume for iwlagn and =
iwl3945
      iwlwifi: adding triple stream rate support for MIMO3
      iwlwifi: adding MIMO3 support in rate scaling
      iwlwifi: add debug messages when start aggregation queue
      iwlwifi: Display decoded rate/mcs information
      iwlwifi: adding interrupt counter in debugfs for debugging
      iwlwifi: clean up unused NL80211_IFTYPE_MONITOR for Monitor mode
      iwlwifi: "is_fat" bit in rate scale match RXON flag
      iwlwifi: use #define instead of hard coded value
      iwlagn: show current rate scale data in debugfs
      iwlwifi: show qos AC parameters
      iwlwifi: default WMM AC parameters
      iwlwifi: add Greenfield support for 11n
      iwlwifi: Temperature sensor voltage reading for 5150
      iwlwifi: support NVM access (EEPROM/OTP)
      iwlwifi: report the rate index as an MCS rate number
      iwlwifi: support "pure 40MHz" in RXON command
      iwlwifi: check for valid band for channel info
      iwlwifi: add value and range define for link quality command
      iwlwifi: checking for 40MHz mode
      iwlwifi: check control channel for pure 40MHz
      iwlwifi: check for channel location for 40MHz

Wim Van Sebroeck (6):
      [WATCHDOG] iTCO_wdt: Cleanup code
      [WATCHDOG] Some more general cleanup
      [WATCHDOG] move platform probe and remove function to devinit and d=
evexit
      [WATCHDOG] Correct WDIOF_MAGICCLOSE flag
      [WATCHDOG] iTCO_wdt: Fix ICH7+ reboot issue.
      [WATCHDOG] wdt_pci.c: remove #ifdef CONFIG_WDT_501_PCI

Wolfgang Denk (2):
      powerpc/mpc8272ads: fix device tree for 8 MB flash size
      powerpc/5xxx: Add common mpc5xxx_get_bus_frequency() function

Wolfgang Grandegger (12):
      can: Documentation for the CAN device driver interface
      can: Update MAINTAINERS and CREDITS file
      can: CAN Network device driver and Netlink interface
      can: Driver for the SJA1000 CAN controller
      can: SJA1000 generic platform bus driver
      can: SJA1000 driver for EMS PCI cards
      The patch adds support for the PCI cards: PCIcan and PCIcanx (1, 2 =
or 4 channel) from Kvaser (http://www.kvaser.com).
      can: some fixes and cleanups to the initial device driver interface
      can: sja1000: stop misusing member base_addr of struct net_device
      can: sja1000: generic OF platform bus driver
      can: sja1000_of_platform: fix build problems with printk format
      rtc: add stand-alone driver for RX8025 chip

Wolfgang Muees (2):
      mmc_spi: speedup for slow cards, less wear-out
      mmc_spi: don't use EINVAL for possible transmission errors

Wolfram Sang (5):
      trivial: fs/inode: Fix typo in file_update_time nanodoc
      i2c/chips: Move max6875 to drivers/misc/eeprom
      powerpc/5200: Update pcm030.dts to add i2c eeprom and delete cruft
      powerpc/5121: make clock debug output more readable
      rtc: rtc-ds1307 add ds3231

Wolfram Strepp (3):
      rb_tree: reorganize code in rb_erase() for additional changes
      rb_tree: make clear distinction between two different cases in rb_e=
rase()
      rb_tree: remove redundant if()-condition in rb_erase()

Wu Fengguang (37):
      perf_counter tools: Merge common code into perfcounters.h
      perf_counter tools: Move perfstat supporting code into perfcounters=
.h
      perf_counter tools: support symbolic event names in kerneltop
      perf_counter tools: Reuse event_name() in kerneltop
      perf_counter tools: move remaining code into kerneltop.c
      perf_counter tools: fix comment for sym_weight()
      perf_counter tools: fix event_id type
      perf_counter tools: cut down default count for cpu-cycles
      perf_counter tools: when no command is feed to perfstat, display he=
lp and exit
      slob: use PG_slab for identifying SLOB pages
      readahead: make mmap_miss an unsigned int
      readahead: move max_sane_readahead() calls into force_page_cache_re=
adahead()
      readahead: apply max_sane_readahead() limit in ondemand_readahead()
      readahead: remove one unnecessary radix tree lookup
      readahead: increase interleaved readahead size
      readahead: remove sync/async readahead call dependency
      readahead: sequential mmap readahead
      readahead: enforce full readahead size on async mmap readahead
      readahead: record mmap read-around states in file_ra_state
      radix-tree: add radix_tree_prev_hole()
      readahead: move the random read case to bottom
      readahead: introduce context readahead algorithm
      readahead: remove redundant test in shrink_readahead_size_eio()
      readahead: enforce full sync mmap readahead size
      mm: introduce PageHuge() for testing huge/gigantic pages
      proc: kpagecount/kpageflags code cleanup
      proc: export more page flags in /proc/kpageflags
      pagemap: document clarifications
      pagemap: document 9 more exported page flags
      pagemap: add page-types tool
      vmscan: cleanup the scan batching code
      vmscan: don't export nr_saved_scan in /proc/zoneinfo
      vmscan: ZVC updates in shrink_active_list() can be done once
      vmscan: report vm_flags in page_referenced()
      vmscan: make mapped executable pages the first class citizen
      vmscan: merge duplicate code in shrink_active_list()
      writeback: skip new or to-be-freed inodes

Wu Zhangjin (2):
      tracing: fix undeclared 'PAGE_SIZE' in include/linux/trace_seq.h
      MIPS: Add hibernation support

Xiantao Zhang (1):
      KVM: ia64: Flush all TLBs once guest's memory mapping changes.

Xiaochen Shen (1):
      USB: Add Intel Langwell USB Device Controller driver

Yan Zheng (4):
      btrfs: Fix set/clear_extent_bit for 'end =3D=3D (u64)-1'
      Btrfs: Mixed back reference  (FORWARD ROLLING FORMAT CHANGE)
      Btrfs: check duplicate backrefs for both data and metadata
      Btrfs: always update root items for fs trees at commit time

Yang Li (1):
      rio: warn_unused_result warnings fix

Yang Zhang (2):
      KVM: ia64: fix compilation error in kvm_get_lowest_prio_vcpu
      KVM: ia64: enable external interrupt in vmm

Yevgeny Petrilin (17):
      mlx4_en: Removed redundant stride variable
      mlx4_en: Fix partial rings feature
      mlx4_en: Giving interface name in debug messages
      mlx4_en: Moved all module parameters handling to en_main.c
      mlx4_en renamed en_params.c to en_ethtool.c
      mlx4_en: Work with part of the ports.
      mlx4_en: Coalescing target is equal for all mtu's
      mlx4_en: multiqueue support
      mlx4_en: Added vlan_features support
      mlx4_en: Updated driver version
      mlx4: FIX error flow when initializing EQ table
      mlx4_en: Counting all the dropped packets on the TX side
      mlx4_en: Removed redundant skb->len check
      mlx4_en: using stop/start_all_queues
      mlx4_en: Cancel port_up check in transmit function
      mlx4_en: Removed redundant check on lso header size
      mlx4_en: Remove redundant refill code on RX

Yi Li (4):
      Blackfin: bf527-ezkit: add support for mmc-spi
      Blackfin: define SPI IRQ in board resources
      Blackfin: update aedos-ipipe code to upstream 1.10-00
      Blackfin: drop BF535-specific text for exception 0x2A (unaligned in=
struction)

Yi Zou (13):
      ixgbe: Enable L2 header split in 82599
      ixgbe: Add FCoE feature register defines to 82599
      ixgbe: Add FCoE feature header to 82599
      ixgbe: Add FCoE feature code to 82599
      ixgbe: Add infrastructure code for FCoE large send offload to 82599
      ixgbe: Implement FCoE Tx side offload features in base driver of 82=
599
      ixgbe: Add infrastructure code for FCoE large receive offload to 82=
599
      ixgbe: Implement FCoE Rx side large receive offload feature to 8259=
9
      ixgbe: Add FCoE related statistics to 82599
      ixgbe: Add RING_F_FCOE for FCoE feature in 82599
      ixgbe: Enable FCoE redirection table feature in 82599
      ixgbe: Enable jumbo frame for FCoE feature in 82599
      ixgbe: Include offloaded FCoE data into total rx/tx statistics for =
82599

Yinghai Lu (56):
      perf_counter: more barrier in blank weak function
      x86: make irqinit_32.c more like irqinit_64.c, v2
      x86: make wakeup_secondary_cpu_via_init static
      x86: consistent about warm_reset_vector for UN_NON_UNIQUE_APIC
      x86: remove (null) in /sys kernel_page_tables
      x86: use used_vectors in init_IRQ()
      x86: apic: Remove duplicated macros
      x86: Use dmi check in apic_is_clustered() on 64-bit to mark the TSC=
 unstable
      irq, cpumask: correct CPUMASKS_OFFSTACK typo and fix fallout
      x86/irq: remove leftover code from NUMA_MIGRATE_IRQ_DESC
      irq: change ->set_affinity() to return status
      irq: only update affinity if ->set_affinity() is sucessfull
      x86/irq: change irq_desc_alloc() to take node instead of cpu
      irq: change ACPI GSI APIs to also take a device argument
      irq: change io_apic_set_pci_routing() to use device parameter
      x86/irq: change MSI irq_desc to be more numa aware
      irq: make ht irq_desc more numa aware
      x86/irq: use move_irq_desc() in create_irq_nr()
      x86/pci: remove rounding quirk from e820_setup_gap()
      x86/acpi: remove irq-compression trick on 32-bit
      x86: fix alloc_mptable()
      x86/acpi: call mp_config_acpi_gsi() in mp_register_gsi()
      x86/acpi: move pin_programmed bit map to io_apic.c
      x86/pci: add 4 more return parameters to IO_APIC_get_PCI_irq_vector=
()
      x86/acpi: move setup io apic routing out of CONFIG_ACPI scope
      x86/pci: update pirq_enable_irq() to setup io apic routing
      x86: apic: Check rev 3 fadt correctly for physical_apic bit
      x86: clean up and fix setup_clear/force_cpu_cap handling
      x86: clean up and and print out initial max_pfn_mapped
      x86: read apic ID in the !acpi_lapic case
      x86: Sanity check the e820 against the SRAT table using e820 map on=
ly
      x86: Allow 1MB of slack between the e820 map and SRAT, not 4GB
      x86: read apic ID in the !acpi_lapic case
      x86, apic: introduce io_apic_irq_attr
      x86: don't call read_apic_id if !cpu_has_apic
      mm, x86: remove MEMORY_HOTPLUG_RESERVE related code
      x86, mm: Fix node_possible_map logic
      x86: fix system without memory on node0
      x86, irq: update_mptable needs pci_routeirq
      x86, irq: don't call mp_config_acpi_gsi() if update_mptable is not =
enabled
      x86, io-apic: Don't mark pin_programmed early
      x86: enable_update_mptable should be a macro
      x86: remove some alloc_bootmem_cpumask_var calling
      irq/cpumask: make memoryless node zero happy
      memcg: don't use bootmem allocator in setup code
      PCI/x86: don't assume prefetchable ranges are 64bit
      PCI: improve resource allocation under transparent bridges
      x86: handle initrd that extends into unusable memory
      x86: use zalloc_cpumask_var in arch_early_irq_init
      kvm: remove the duplicated cpumask_clear
      irq: slab alloc for default irq_affinity
      x86: make zap_low_mapping could be used early
      firmware_map: fix hang with x86/32bit
      page-allocator: clear N_HIGH_MEMORY map before we set it again
      x86: fix duplicated sysfs attribute
      x86: use zalloc_cpumask_var for mce_dev_initialized

Yong Wang (8):
      perf_counter/x86: Always use NMI for performance-monitoring interru=
pt
      perf_counter/x86: Remove the IRQ (non-NMI) handling bits
      perf_counter: Documentation update
      perf_counter tools: Fix incorrect printf formats
      perf_counter, x86: Correct some event and umask values for Intel pr=
ocessors
      perf_counter/x86: Fix the model number of Intel Core2 processors
      perf_counter tools: Remove one L1-data alias
      perf_counter/x86: Add a quirk for Atom processors

Yoshihiro Shimoda (12):
      sh: sh7785lcr: fix I2C device address map for 32-bit mode
      net: sh_eth: fix cache coherency issue
      net: sh_eth: fix TX/RX descriptor not set physical memory
      net: sh_eth: fix receive desciptor loop
      net: sh_eth: CPU dependency code collect to "struct sh_eth_cpu_data=
"
      net: sh_eth: Add support SH7724
      USB: r8a66597-hcd: use platform_data instead of module_param
      sh: sh7785lcr: add platform data for r8a66597-hcd
      sh: highlander: add platform data for r8a66597-hcd
      sh: x3proto: add platform data for r8a66597-hcd
      sh: add platform data for r8a66597-hcd in setup-sh7366
      sh: add platform data for r8a66597-hcd in setup-sh7723

Yoshinori Sato (1):
      serial: sh-sci: Fix up h8300 support.

Yu Zhao (11):
      VT-d: fix invalid domain id for KVM context flush
      PCI: support the ATS capability
      PCI: handle Virtual Function ATS enabling
      VT-d: parse ATSR in DMA Remapping Reporting Structure
      VT-d: add device IOTLB invalidation support
      VT-d: cleanup iommu_flush_iotlb_psi and flush_unmaps
      VT-d: support the device IOTLB
      PCI: fix SR-IOV function dependency link problem
      PCI: cleanup Function Level Reset
      PCI: support PM D0hot->D3 transition reset
      PCI: support Secondary Bus Reset

Yu Zhiguo (3):
      NFSv4: do exact check about attribute specified
      NFSv4: kill off complicated macro 'PROC'
      NFS: kill off complicated macro 'PROC'

Zephaniah E. Hull (1):
      Input: psmouse - ESD workaround fix for OLPC XO touchpad

Zhang Rui (5):
      Show the physical device node of backlight class device.
      ACPI: fix a deadlock in hotplug case
      ACPI: DMI to disable Vista compatibility on some Sony laptops
      ACPI: run ACPI device hot removal in kacpi_hotplug_wq
      ACPI: video: DMI workaround broken Acer 7720 BIOS enabling display =
brightness

Zhang, Xiantao (1):
      KVM: ia64: make kvm depend on CONFIG_MODULES.

Zhang, Yanmin (3):
      PCI AER: support Multiple Error Received and no error source id
      PCI AER: support invalid error source IDs
      PCI AER: multiple error support

Zhao Yakui (3):
      ACPI: increase size of acpi_bus_id[]
      ACPI: Add the reference count to avoid unloading ACPI video bus twi=
ce
      ACPI: Rename ACPI processor device bus ID

Zhaolei (13):
      ftrace: clean up enable logic for sched_switch
      printk: add support of hh length modifier for printk
      tracing, net, skb tracepoint: make skb tracepoint use the TRACE_EVE=
NT() macro
      tracing, kmemtrace: Separate include/trace/kmemtrace.h to kmemtrace=
 part and tracepoint part
      tracing, kmemtrace: Make kmem tracepoints use TRACE_EVENT macro
      tracing: Remove include/trace/kmem_event_types.h
      ftrace: Add task_comm support for trace_event
      ftrace: clean up of using ftrace_event_enable_disable()
      ftrace: don't convert function's local variable name in macro
      ftrace, workqueuetrace: make workqueue tracepoints use TRACE_EVENT =
macro
      trace_workqueue: use list_for_each_entry() instead of list_for_each=
_entry_safe()
      trace_workqueue: remove cpu_workqueue_stats->first_entry
      trace_workqueue: remove blank line between each cpu

Zhenwen Xu (1):
      [SCSI] NCR_D700: fix IRQ handler return type

Zhenyu Wang (10):
      agp/intel: Add support for new chipsets
      drm/i915: Add chipset/feature defines for for new chipsets
      drm/i915: Add new chipset register definitions
      drm/i915: Disable opregion on IGDNG for now
      drm/i915: Disable tiling on IGDNG for now
      drm/i915: enable kernel modesetting on IGDNG
      drm/i915: Add HDMI support on IGDNG
      drm/i915: Add LVDS support for IGDNG
      drm/i915: handle interrupt on new chipset
      drm/i915: Enable probe on new chipset

Zhu Yi (7):
      wireless: move some utility functions from mac80211 to cfg80211
      iwmc3200wifi: Add new Intel Wireless Multicomm 802.11 driver
      iwmc3200wifi: fix link error when CFG80211 is not selected
      iwmc3200wifi: check for iwm_priv_init error
      iwmc3200wifi: add iwm_if_add and iwm_if_remove
      iwmc3200wifi: fix potential kernel oops on module removal
      iwmc3200wifi: add a mutex to protect iwm_reset_worker

Zygo Blaxell (1):
      lib/genalloc.c: remove unmatched write_lock() in gen_pool_destroy

akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org (1):
      PCI: ibmphp_core.c: fix warning due to missing module_exit()

andrey-W/OLz77bvjtBDgjK7y7TUQ@public.gmane.org (1):
      libertas: fix GSPI card event handling

chaithrika-l0cyMroinI0@public.gmane.org (1):
      TI DaVinci EMAC : Fix rmmod error

dann frazier (1):
      Remove bashisms from scripts

dmitry pervushin (18):
      [ARM] 5461/1: Freescale STMP platform support
      [ARM] 5469/1: Freescale STMP platform support [2/10]
      [ARM] 5468/1: Freescale STMP platform support [3/10]
      [ARM] 5467/1: Freescale STMP platform support [4/10]
      [ARM] 5466/1: Freescale STMP platform support [5/10]
      [ARM] 5477/1: Freescale STMP platform support [6/10]
      [ARM] 5465/1: Freescale STMP platform support [7/10]
      [ARM] 5464/1: Freescale STMP platform support [7/10]
      [ARM] 5463/1: Freescale STMP platform support [10/10]
      [ARM] 5483/1: Freescale STMP: add Kconfig/Makefile entries
      [ARM] 5501/1: Freescale STMP: fix compilation warning
      [ARM] 5530/1: Freescale STMP: get rid of HW_zzz macros [1/3]
      [ARM] 5531/1: Freescale STMP: get rid of HW_zzz macros [2/3]
      [ARM] 5532/1: Freescale STMP: register definitions [3/3]
      [ARM] 5537/1: Freescale STMP: 37nn registers definition
      [ARM] 5538/1: Freescale STMP: 378n registers definition
      [ARM] 5539/1: Freescale STMP: onboard devices declaration
      [WATCHDOG] Freescale STMP: watchdog driver

figo.zhang (4):
      trivial: Documentation/rbtree.txt: cleanup kerneldoc of rbtree.txt
      V4L/DVB (11852): saa7134-video.c: poll method lose race condition
      V4L/DVB (11853): minor have assigned value twice
      V4L/DVB (11990): saa7134-video.c: fix the block bug

fran=C3=A7ois romieu (4):
      r8169: remove useless struct member
      r8169: allow true forced mode setting
      sis190: use an adequate phy list entry as a fallback
      r8169: do not bring device down when suspending

gouji-new (1):
      ixgbe: Proposed PARCH PCIE legacy I/O port free intel 10Gb NIC driv=
er

hermann pitton (1):
      V4L/DVB (11732): saa7134: disable not yet existing IR and DVB suppo=
rt on the Compro T750

john cooper (1):
      Add serial number support for virtio_blk, V4a

john stultz (5):
      timekeeping: create arch_gettimeoffset infrastructure
      time: sh: convert to use arch_getoffset() infrastructure
      ntp: adjust SHIFT_PLL to improve NTP convergence
      ntp: fix comment typos
      clocksource: sanity check sysfs clocksource changes

leon.woestenberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org (1):
      powerpc/83xx: Add MSI interrupts to DTS of MPC8315E-RDB

matthieu castet (3):
      mac80211 : fix unaligned rx skb
      V4L/DVB (11832): dibusb_mc: fix i2c to not corrupt eeprom in case o=
f strange read pattern
      [WATCHDOG] add bcm47xx watchdog driver

maximilian attems (5):
      kbuild, deb-pkg: improve maintainer identification
      kbuild, deb-pkg: fix generated package name
      kbuild, deb-pkg: fix Provides field
      kbuild, deb-pkg: fix Section field
      kbuild, deb-pkg: bump standards version

mware-CkBdp7X+a1oIQCUVoCVjmQ@public.gmane.org (1):
      powerpc/fsl: Increase the number of possible localbus banks

nathan binkert (1):
      KVM: Make kvm header C++ friendly

npiggin-l3A5Bk7waGM@public.gmane.org (3):
      fs: mnt_want_write speedup
      fs: introduce mnt_clone_write
      fs: move mark_files_ro into file_table.c

raz ben yehuda (7):
      md: have raid0 compile with MD_DEBUG on
      md: have raid0 report its formation
      md: raid0: chunk size check in raid0_run
      md: raid10: chunk size check in run
      md: raid5: chunk size check in setup_conf
      md: prepare for non-power-of-two chunk sizes
      md: raid0 :Enables chunk size other than powers of 2.

roel kluin (2):
      pasemi_mac: mac_to_intf() error not noticed
      tape: beyond ARRAY_SIZE of viocd_diskinfo

scameron-3C9H9nn4BS5stOSx8vMUiLIexByqKVI1@public.gmane.org (8):
      cciss: Use schedule_timeout_uninterruptible in SCSI error handling =
code
      cciss: factor out core of sendcmd_withirq() for use by SCSI error h=
andling code
      cciss: simplify interface of sendcmd() and sendcmd_withirq()
      cciss: factor out fix target status processing code from sendcmd fu=
nctions
      cciss: separate error processing and command retrying code in sendc=
md_withirq_core()
      cciss: change SCSI error handling routines to work with interrupts =
enabled.
      cciss: Remove no longer needed sendcmd reject processing code
      cciss: decode unit attention in SCSI error handling code

sebastian.blanes-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org (1):
      ps3av: Set 16:9 aspect ratio for 720p video modes

sg.tweak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org (1):
      drivers/net/macvlan.c: fix cloning of tagged VLAN interfaces

tomas petr (1):
      V4L/DVB (11830): dib0700: add support for Leadtek WinFast DTV Dongl=
e H

unsik Kim (1):
      mg_disk: seperate mg_disk.h again

vibi sreenivasan (3):
      Removed reference to non-existing file Documentation/PCI/PCI-DMA-ma=
pping.txt
      Staging: rspiusb: Fix a bunch of warnings.
      Staging: rspiusb: copy_to/from_user related fixes

walimis (3):
      tracing/trace_stack: fix the number of entries in the header
      tracing/events: fix output format of kernel stack
      tracing/events: fix output format of user stack

wanzongshun (13):
      [ARM] 5493/1: Add w90p910 IC interface controller regester map
      [ARM] 5494/1: Add w90p910 irq number define
      [ARM] 5495/1: Add w90p910 usb host driver relevant kernel parts[1/2=
]
      [ARM] 5496/1: Add w90p910 touch screen driver relevant kernel parts=
[2/2].
      [ARM] 5497/1: Add usb and ts relevant kernel maping option
      [ARM] 5498/1: w90p910 Clock register controller header file dfine
      [ARM] 5499/1: Add Usb register controller header file dfine
      [ARM] 5511/1: Add w90p910 rtc,kpi and usbd device map_desc define.
      [ARM] 5512/1: Add w90p910 rtc,kpi and usbd device platform_device d=
efine.
      [ARM] 5551/1: Add multi-function pin api for w90p910 platform.
      [ARM] 5548/1: Add gpio api for w90p910 platform
      [ARM] 5549/1: Add clock api for w90p910 platform.
      [ARM] 5550/1: Add default configure file for w90p910 platform

yakui_zhao (8):
      drm/i915: Add the structure of child_device_config in video BIOS ta=
bles.
      drm/i915: parse VBT general definition block to get the SDVO device=
 info
      drm/i915: Initialize the SDVO device based on the sdvo info parsed =
from VBT
      drm: add separate drm debugging levels
      drm/i915: replace DRM_DEBUG with DRM_DEBUG_KMS in intel_lvds
      drm/i915: Replace DRM_DEBUG with DRM_DEBUG_KMS in intel_sdvo
      drm: Replace DRM_DEBUG with DRM_DEBUG_MODE in drm_mode
      drm: Replace DRM_DEBUG with DRM_DEBUG_DRIVER in i915 driver

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr

--===============8883878038630048753==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============8883878038630048753==--
