From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr annotated tag, v2.6.29-rc1, created. v2.6.29-rc1
Date: Wed, 16 Sep 2009 14:36:35 -0400
Message-ID: <200909161836.n8GIaZPx001181@gorgona.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2751593004607479287=="
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

--===============2751593004607479287==
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by smtp1.linux-foundation.org id n8GJTkFp009468

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The annotated tag, v2.6.29-rc1 has been created
        at  7a3862d6e9934ffe107fe7ddfbe2c63dba321793 (tag)
   tagging  c59765042f53a79a7a65585042ff463b69cb248c (commit)
  replaces  v2.6.28
 tagged by  Linus Torvalds
        on  Sat Jan 10 15:43:15 2009 -0800

- Log -----------------------------------------------------------------
Linux 2.6.29-rc1
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAklpMpgACgkQF3YsRnbiHLsCVQCfYMnTXkmXMmoh5fCD02ZnHKlB
B9YAnjqxNxK1hTAvk9lg8r/xXA6jE1xB
=3DaNdq
-----END PGP SIGNATURE-----

Abbas, Mohamed (3):
      iwl3945: add debugfs support
      iwl3945: Fix iwl3945 rate scaling.
      iwl3945: Fix rate scale for B-mode connection

Abhijeet Kolekar (3):
      iwlwifi : fix checkpatch.pl errors
      iwl3945 : Fix ad-hoc mode for 3945
      iwl3945 : Fix a-band association for passive channels

Adam Jackson (1):
      PCI quirks: piix3: warn softer about enabling passive release

Adam Lackorzynski (1):
      vmalloc.c: fix flushing in vmap_page_range()

Adrian Bunk (3):
      The overdue eepro100 removal.
      parisc: lib/: make code static
      parisc: drivers/parisc/: make code static

Adrian Hunter (5):
      MTD: nandsim: suppress unnecessary warning
      MTD: nandsim: add option to use a file to cache pages
      [MTD] update internal API to support 64-bit device size
      mmc_block: print better error messages
      mmc_block: ensure all sectors that do not have errors are read

Adrian McMenamin (1):
      Input: add support for Maple controller as a joystick

Adrian-Ken Rueegsegger (10):
      libcrc32c: Fix "crc32c undefined" compilation error
      crypto: sha1 - Switch to shash
      crypto: md4 - Switch to shash
      crypto: md5 - Switch to shash
      crypto: sha256 - Switch to shash
      crypto: tgr192 - Switch to shash
      crypto: wp512 - Switch to shash
      crypto: michael_mic - Switch to shash
      crypto: sha512 - Move message schedule W[80] to static percpu area
      crypto: sha512 - Switch to shash

Akinobu Mita (4):
      SLUB: failslab support
      backlight: hp680_bl - Use platform_device_register_simple()
      backlight: progear_bl - Use platform_device_register_simple()
      backlight: crbllcd_bl - Use platform_device_register_simple()

Al Viro (42):
      ixgbe: section fixes
      sparc32: pdev_to_pnode() is used from __devinit
      Audit: Log TIOCSTI
      [S390] audit: get s390 ret_from_fork in sync with other architectur=
es
      fix switch_names() breakage in short-to-short case
      take init_fs to saner place
      kill ->dir_notify()
      nfsd/create race fixes, infrastructure
      nfsd race fixes: ext2
      nfsd race fixes: ext3
      nfsd race fixes: ext4
      nfsd race fixes: reiserfs
      remove the rudiment of a.out for sparc
      sanitize ifdefs in binfmt_aout
      get rid of special-casing the /sbin/loader on alpha
      don't reallocate buffer in every audit_sockaddr()
      sanitize audit_socketcall
      sanitize audit_ipc_obj()
      sanitize audit_ipc_set_perm()
      sanitize audit_mq_getsetattr()
      sanitize audit_mq_notify()
      sanitize AUDIT_MQ_SENDRECV
      sanitize audit_mq_open()
      sanitize audit_fd_pair()
      sanitize audit_log_capset()
      audit_update_lsm_rules() misses the audit_inode_hash[] ones
      fixing audit rule ordering mess, part 1
      audit rules ordering, part 2
      make sure that filterkey of task,always rules is reported
      clean up audit_rule_{add,del} a bit
      audit: validate comparison operations, store them in sane form
      affs: do not zero ->i_op
      isofs check for NULL ->i_op in root directory is dead code
      ntfs: don't NULL i_op
      inode->i_op is never NULL
      zero i_uid/i_gid on inode allocation
      fix the treatment of jfs special inodes
      fix breakage in reiserfs_new_inode()
      get rid of the last symlink in uml build
      uml got broken by commit 30742d5c2277c325fb0e9d2d817d55a19995fe8f
      X86_DEBUGCTLMSR won't work on uml
      [SCSI] cxgb3i: add missing include

Alain Kalker (1):
      V4L/DVB (9665): af9015: Add support for the Digittrade DVB-T USB St=
ick remote

Alain Knaff (1):
      vfs: lseek(fd, 0, SEEK_CUR) race condition

Alan Cox (50):
      tty: Flags should be accessed via the foo_bit interfaces
      tty: driverdata and discdata are void *
      [SCSI] Clean up my email address and use a single standard address =
for everything
      V4L/DVB (9491): rationalise addresses to one common one
      n_tty: clean up coding style
      devpts: Coding style clean up
      sierra: Fix formatting
      pty: simplify resize
      tty: Fix close races in USB serial
      tty: Fix PPP hang under load
      tty_port: Add a port level carrier detect operation
      rio: Kill off ckmalloc
      tty: Pull the dtr raise into tty port
      isicom: redo locking to use tty port locks
      tty: relock generic_serial
      tty: rocketport uses different port flags to everyone else
      tty: relock riscom8 using port locks
      tty: relock the mxser driver
      tty: Introduce a tty_port generic block_til_ready
      tty: Rework istallion to use the tty port changes
      tty: rework stallion to use the tty_port bits
      tty: ESP has been broken for locking etc forver
      tty: tty port zero baud open
      tty: Introduce some close helpers for ports
      tty: USB tty devices can block in tcdrain when unplugged
      tty: PTYs set TTY_DO_WRITE_WAKEUP when they don't need to
      tty: Remove some pointless casts
      tty: kref nozomi
      hso: net driver using tty without locking
      tty: Fix the HSO termios handling a bit
      tty: relock epca
      tty: refcount the epca driver
      tty: Make epca use the port helpers
      tty: Redo the rocket driver locking
      tty: make rocketport use standard port->flags
      tty: kref the rocket driver
      tty: use port methods for the rocket driver
      synclink_cs: Convert to tty_port
      tty: Drop the lock_kernel in the private ioctl hook
      tty: We want the port object to be persistent
      tty: Fix an ircomm warning and note another bug
      x86: update Alan Cox's email addresses
      mm: update my address
      i2o: Update my address
      touchscreen: Fix build of da9034
      pata_hpt3x3: Workarounds for chipset
      pata_ali: force initialise a few bits
      pata_ali: Fix and workaround for FIFO DMA bug
      libata: Add 32bit PIO support
      libata: clean up the SFF code for coding style

Alan Horstmann (1):
      ALSA: ice1724 - Fix a typo in IEC958 PCM name

Alan McIvor (2):
      V4L/DVB (9522): Increase number of SAA7134 devices supported in a s=
ystem
      V4L/DVB (9523): Increase number of BT8XX devices supported in a sys=
tem

Alan Nisota (1):
      V4L/DVB (9928): Convert GP8PSK module to use S2API

Alan Stern (28):
      [SCSI] simplify scsi_io_completion()
      [SCSI] Fix uninitialized variable error in scsi_io_completion
      HID: automatically call usbhid_set_leds in usbhid driver
      Fix misspellings in pm.h macros
      Driver core: move the bus notifier call points
      USB: straighten out inline code in sysfs.c
      USB: change interface to usb_lock_device_for_reset()
      USB: usb-storage: add "quirks=3D" module parameter
      USB: add asynchronous autosuspend/autoresume support
      USB: announce new devices earlier
      usb-storage: clean up unusual_devs.h
      USB: usb-storage: remove us->sensebuf
      USB: g_file_storage: add CD-ROM emulation
      USB: usb-storage: merge CB and CBI transport routines
      USB: usb-storage: merge ATAPI and QIC-157 protocol routines
      USB: storage: set bounce limit for non-DMA-capable host controllers
      USB: utilize round_jiffies_up_relative()
      USB: Enhance usage of pm_message_t
      USB: usb-storage: merge DPCM support into SDDR09
      USB: utilize the bus notifiers
      USB: storage: add last-sector hacks
      USB: storage: make the "quirks=3D" module parameter writable
      USB: storage: set CAPACITY_HEURISTICS flag for bad vendors
      USB: fix up suspend and resume for PCI host controllers
      USB: automatically enable wakeup for PCI host controllers
      USB: cancel pending Set-Config requests if userspace gets there fir=
st
      USB: re-enable interface after driver unbinds
      PCI: fix incorrect error return in pci_enable_wake

Alasdair G Kergon (2):
      dm mpath: move trigger_event to system workqueue
      dm snapshot: split out exception store implementations

Aleksey Senin (2):
      RDMA/addr: Add support for translating IPv6 addresses
      RDMA/cma: Add IPv6 support

Ales Jurik (1):
      V4L/DVB (9470): Disable PLL Loop while tuning

Alessandro Zummo (8):
      rtc: add alarm/update irq interfaces
      rtc: pxa27x/pxa3xx driver fixes, revised
      rtc: rtc-ds1390 probe sequence and misc fixes
      rtc: kconfig cleanup
      rtc: rtc-max6902 fixes
      rtc: rtc-ds3234 fixes
      rtc: use set_mmss when set_time is not available
      rtc: rtc-ds1216 fixes

Alex Chiang (2):
      btrfs-progs: Stop stomping on 'name' input parameter
      PCI hotplug: acpiphp whitespace cleanup

Alex Raimondi (2):
      avr32: Allow reserving multiple pins at once
      avr32: Hammerhead board support

Alex Zeffertt (1):
      xen: add xenfs to allow usermode <-> Xen interaction

Alexander Beregalov (6):
      ext4: fix printk format warning
      ASoC: switch davinci DPRINTK to pr_debug()
      fix for tty-serial-move-port
      Staging: otus: remove dependence on kernel version
      Staging: me4000: switch to list_for_each*()
      Staging: usbip: switch to list_for_each_entry()

Alexander Duyck (20):
      e1000e: enable ECC correction on 82571 silicon
      igb: update name to reflect new hardware
      igb: simplify swap in clean_rx_irq if using packet split
      igb: Fix tx/rx_ring_count parameters for igb on suspend/resume/ring=
 resize
      ixgbe: this patch adds support for DCB to the kernel and ixgbe driv=
er
      DCB: Add interface to query for the DCB capabilities of an device.
      DCB: Add interface to query # of TCs supported by device
      DCB: Add interface to query the state of PFC feature.
      DCB: Add support for DCB BCN
      e1000e: disable correctable errors for quad ports while going to D3
      igb: do not use phy ops in ethtool test cleanup for non-copper part=
s
      igb: remove unneeded bit refrence when enabling jumbo frames
      igb: loopback bits not correctly cleared from RCTL register
      igb: link up/down messages must follow a specific format
      igb: Add support for pci-e Advanced Error Reporting
      igb/e1000e: Naming interrupt vectors
      igb: update handling of RCTL for smaller buffer sizes
      igb: Correctly determine pci-e function number in virtual environme=
nt
      igb: defeature tx head writeback
      igb: re-order queues to support cleaner use of ivar on 82576

Alexander van Heukelum (19):
      i386, dumpstack: move crash_kexec before bust_spinlocks(0) in oops_=
end
      x86, dumpstack: let signr=3D0 signal no do_exit
      x86_64, dumpstack: move kexec_crash from __die to oops_end
      x86, dumpstack: always call oops_exit from oops_end
      i386, dumpstack: use x86_64's method to account die_nest_count
      i386, dumpstack: use oops_begin/oops_end in die_nmi
      i386, dumpstack: unify die()
      x86: irq: fix apicinterrupts on 64 bits
      x86: entry_64.S: remove whitespace at end of lines
      x86: move entry_64.S register saving out of the macros
      x86: clean up after: move entry_64.S register saving out of the mac=
ros
      x86: introduce save_rest and restructure the PTREGSCALL macro in en=
try_64.S
      x86: entry_64.S: factor out save_paranoid and paranoid_exit
      x86: entry_64.S: split out some macro's and move common code to par=
anoid_exit
      x86: split out some macro's and move common code to paranoid_exit, =
fix
      x86: include ENTRY/END in entry handlers in entry_64.S
      x86: KPROBE_ENTRY should be paired wth KPROBE_END
      x86_64: get rid of the use of KPROBE_ENTRY / KPROBE_END
      i386: get rid of the use of KPROBE_ENTRY / KPROBE_END

Alexey Dobriyan (92):
      net: reduce structures when XFRM=3Dn
      net: don't use INIT_RCU_HEAD
      xfrm: C99 for xfrm_dev_notifier
      xfrm: remove unused struct xfrm_policy::next
      net: '&' redux
      netfilter: netns-aware ipt_addrtype
      netfilter: arptable_filter: merge forward hook
      netfilter: netns ebtables: part 1
      netfilter: netns ebtables: part 2
      netfilter: netns ebtables: more cleanup during ebt_unregister_table=
()
      netfilter: netns ebtables: ebtable_broute in netns
      netfilter: netns ebtables: ebtable_filter in netns
      netfilter: netns ebtables: ebtable_nat in netns
      netfilter: netns ebtables: br_nf_pre_routing_finish() fixup
      net: #ifdef ->sk_security
      net: mark flow_cache_cpu_prepare() as __init
      net: remove struct neigh_table::pde
      net: remove struct dst_entry::entry_size
      net: ifdef struct sock::sk_async_wait_queue
      net: use %pF for /proc/net/ptype
      ematch: simpler tcf_em_unregister()
      netfilter: xt_recent: don't save proc dirs
      netfilter: ip6table_filter: merge LOCAL_IN and FORWARD hooks
      netfilter: nf_conntrack_proto_gre: spread __exit
      net: fix tunnels in netns after ndo_ changes
      ah4/ah6: remove useless NULL assignments
      xfrm: remove useless forward declarations
      xfrm: initialise xfrm_policy_gc_work statically
      netns xfrm: add netns boilerplate
      netns xfrm: add struct xfrm_state::xs_net
      netns xfrm: per-netns xfrm_state_all list
      netns xfrm: per-netns xfrm_state_bydst hash
      netns xfrm: per-netns xfrm_state_bysrc hash
      netns xfrm: per-netns xfrm_state_byspi hash
      netns xfrm: per-netns xfrm_state_hmask
      netns xfrm: per-netns xfrm_state counts
      netns xfrm: per-netns xfrm_hash_work
      netns xfrm: per-netns state GC list
      netns xfrm: per-netns state GC work
      netns xfrm: per-netns km_waitq
      netns xfrm: add struct xfrm_policy::xp_net
      netns xfrm: per-netns policy list
      netns xfrm: per-netns xfrm_policy_byidx hash
      netns xfrm: per-netns xfrm_policy_byidx hashmask
      netns xfrm: per-netns inexact policies
      netns xfrm: per-netns xfrm_policy_bydst hash
      netns xfrm: per-netns policy counts
      netns xfrm: per-netns policy hash resizing work
      netns xfrm: propagate netns into bydst/bysrc/byspi hash functions
      netns xfrm: trivial netns propagations
      netns xfrm: state flush in netns
      netns xfrm: state lookup in netns
      netns xfrm: fixup xfrm_alloc_spi()
      netns xfrm: finding states in netns
      netns xfrm: state walking in netns
      netns xfrm: propagate netns into policy byidx hash
      netns xfrm: policy insertion in netns
      netns xfrm: policy flushing in netns
      netns xfrm: finding policy in netns
      netns xfrm: policy walking in netns
      netns xfrm: lookup in netns
      netns xfrm: xfrm_policy_check in netns
      netns xfrm: xfrm_route_forward() in netns
      netns xfrm: flushing/pruning bundles in netns
      netns xfrm: dst garbage-collecting in netns
      netns xfrm: xfrm_input() fixup
      netns xfrm: per-netns NETLINK_XFRM socket
      netns xfrm: xfrm_user module in netns
      netns xfrm: pass netns with KM notifications
      netns xfrm: KM reporting in netns
      netns xfrm: ->dst_lookup in netns
      netns xfrm: ->get_saddr in netns
      netns xfrm: flush SA/SPDs on netns stop
      netns PF_KEY: part 1
      netns PF_KEY: part 2
      netns PF_KEY: per-netns /proc/pfkey
      netns xfrm: AH/ESP in netns!
      netns xfrm: per-netns MIBs
      netns xfrm: /proc/net/xfrm_stat in netns
      netns xfrm: per-netns sysctls
      sched: move double_unlock_balance() higher
      netdev: remove pathetic compile-command lines
      UBIFS: fix section mismatch
      hydra: fix compilation
      simeth: convert to net_device_ops
      netns: igmp: allow IPPROTO_IGMP sockets in netns
      netns: igmp: make /proc/net/{igmp,mcfilter} per netns
      smsc911x: compile fix re netif_rx signature changes
      proc: stop using BKL
      proc: remove useless WARN_ONs
      proc: remove '##' usage
      Remove remaining unwinder code

Alexey Fisher (1):
      ipw2200: make association only if SSID is known.

Alexey Klimov (14):
      V4L/DVB (9518): radio-mr800: remove warn, info and err messages
      V4L/DVB (9539): dsbr100: add suspend and resume
      V4L/DVB (9540): dsbr100: add disabled controls and fix version
      V4L/DVB (9655): radio-mr800: fix unplug
      V4L/DVB (10052): radio-mr800: correct unplug, fix to previous patch
      V4L/DVB (10053): radio-mr800: disable autosuspend support
      V4L/DVB (10054): dsbr100: fix unplug oops
      V4L/DVB (10057): dsbr100: place dev_warn instead of printk
      V4L/DVB (10058): dsbr100: fix codingstyle, add dev_err messages
      V4L/DVB (10059): dsbr100: dev_err instead of dev_warn
      V4L/DVB (10060): dsbr100: fix and add right comments
      V4L/DVB (10061): dsbr100: increase driver version
      V4L/DVB (10062): dsbr100: change return values in 3 functions
      HID: don't allow DealExtreme usb-radio be handled by usb hid driver

Alexey Korolev (8):
      MTD: nandsim: use less RAM
      [MTD] LPDDR qinfo probing.
      [MTD] LPDDR QINFO records definitions
      [MTD] LPDDR PFOW definition
      [MTD] LPDDR Command set driver
      [MTD] LPDDR added new pfow_base parameter
      [MTD] LPDDR extended physmap driver to support LPDDR flash
      [MTD] LPDDR Makefile and KConfig

Alexey Starikovskiy (2):
      ACPI: EC: Add some basic check for ECDT data
      Newly inserted battery might differ from one just removed, so

Alok Kataria (7):
      x86: add a synthetic TSC_RELIABLE feature bit
      x86: add X86_FEATURE_HYPERVISOR feature bit
      x86: Hypervisor detection and get tsc_freq from hypervisor
      x86: Add a synthetic TSC_RELIABLE feature bit.
      x86: Skip verification by the watchdog for TSC clocksource.
      x86: VMware: Fix vmware_get_tsc code
      x86: vmware: look for DMI string in the product serial key

Amit Shah (4):
      KVM: x86: Fix typo in function name
      KVM: SVM: Set the 'g' bit of the cs selector for cross-vendor migra=
tion
      KVM: SVM: Set the 'busy' flag of the TR selector
      KVM: x86 emulator: Fix handling of VMMCALL instruction

Anders Blomdell (1):
      Staging: comedi: add usb dt9812 driver

Anders Larsen (1):
      qnx: include <linux/types.h> for definitions of __[us]{8,16,32,64} =
types

Andi Kleen (6):
      x86: remove simnow earlyprintk support
      dm: support barriers on simple devices
      kconfig: add script to manipulate .config files on the command line
      kbuild: add a symlink to the source for separate objdirs
      x86: only scan the root bus in early PCI quirks
      compiler-gcc.h: add more comments to RELOC_HIDE

Andre Noll (9):
      md: raid0_make_request(): Replace chunksize_bits by chunksect_bits.
      md: raid0_make_request(): Remove local variable chunk_size.
      md: raid0_make_request(): Replace local variable block by sector.
      md: raid0: Represent device offset in sectors.
      md: raid0: Represent zone->zone_offset in sectors.
      md: raid0 create_strip_zones(): Make two local variables sector-bas=
ed.
      md: raid0 create_strip_zones(): Add KERN_INFO/KERN_ERR to printk's.
      md: raid0: Represent the size of strip zones in sectors.
      md: raid0: make hash_spacing and preshift sector-based.

Andreas Eversberg (14):
      mISDN: Add feature via MISDN_CTRL_FILL_EMPTY to fill fifo if empty
      mISDN: Add some debug option for clock problems
      mISDN: Fix queue limit counting problem
      mISDN: Fixed more indexing bugs
      mISDN: Add ISDN sample clock API to mISDN core
      mISDN: Fix irq detection
      mISDN: Fix deactivation, if peer IP is removed from l1oip instance.
      mISDN: Correct busy device detection
      mISDN: Minor fixes
      mISDN: Add different different timer settings for hfc-pci
      mISDN: Add missing release functions
      mISDN: Minor cleanups
      mISDN: Added missing create_l1() call
      mISDN: Fix kernel crash when doing hardware conference with more th=
an two members

Andreas Gruenbacher (2):
      genksyms: track symbol checksum changes
      genksyms: allow to ignore symbol checksum changes

Andreas Herrmann (10):
      x86: microcode_amd: fix wrong handling of equivalent CPU id
      x86: microcode_amd: fix typos and trailing whitespaces in log messa=
ges
      x86: microcode_amd: fix checkpatch warnings/errors
      x86: microcode_amd: fix compile warning
      x86: microcode_amd: don't pass superfluous function pointer for get=
_ucode_data
      x86: microcode_amd: replace inline asm by common rdmsr/wrmsr functi=
ons
      x86: microcode_amd: consolidate macro definitions
      x86: microcode_amd: remove (wrong) chipset deivce ID checks
      x86: microcode_amd: use 'packed' attribute for structs
      x86: microcode_amd: modify log messages

Andreas Oberritter (1):
      V4L/DVB (9361): Dynamic DVB minor allocation

Andres Salomon (13):
      ALSA: cs5535audio: stick AD1888 bitshift values into a header file
      ALSA: cs5535audio: suspend/resume callbacks are only defined with C=
ONFIG_PM
      ALSA: cs5535audio: invert EAPD for OLPC (newer than B3)
      ALSA: cs5535audio: drop ec_analog_input flag for OLPC stuff
      ALSA: cs5535audio: decouple HPF from V_REFOUT in OLPC code
      ALSA: cs5535audio: create function for setting OLPC's Analog Input =
mode
      ALSA: cs5535audio: rename OLPC's analog input control && drop AD188=
8's HPF
      ALSA: cs5535audio: check OLPC's Analog Input status vis GPIO
      ALSA: cs5535audio: rename V_REFOUT control to MIC Bias
      ALSA: cs5535audio: for OLPC, default to Analog Input being off
      ALSA: cs5535audio: turn off mic bias on OLPCs by default
      ALSA: cs5535audio: clean up OLPC code
      ALSA: cs5535audio: ensure MIC Bias/Analog Input bail if not on an O=
LPC machine

Andrew Morton (11):
      lock debug: sit tight when we are already in a panic
      profiling: clean up profile_nop()
      drivers/net/smc911x.c: smc911x_drv_probe() cleanup
      dlm: fs/dlm/ast.c: fix warning
      devpts: fix unused function warning
      drivers/char/cyclades.c: cy_pci_probe: fix error path
      mm: write_cache_pages more terminate quickly
      vmscan: shrink_active_list(): reduce lru_lock hold time
      dma_alloc_from_coherent(): fix fallback to generic memory
      dma_alloc_coherent: clean it up
      PCI: uninline pci_ioremap_bar()

Andrew Patterson (8):
      ACPI/PCI: include missing acpi.h file in pci-acpi.h.
      ACPI/PCI: call _OSC support during root bridge discovery
      ACPI/PCI: PCI extended config _OSC support called when root bridge =
added
      ACPI/PCI: PCIe ASPM _OSC support capabilities called when root brid=
ge added
      ACPI/PCI: PCIe AER _OSC support capabilities called when root bridg=
e added
      ACPI/PCI: PCI MSI _OSC support capabilities called when root bridge=
 added
      ACPI/PCI: remove obsolete _OSC capability support functions
      PCI: Use msleep instead of cpu_relax during ASPM link retraining

Andrew Vasquez (8):
      [SCSI] qla2xxx: Remove support for reading/writing HW-event-log.
      [SCSI] qla2xxx: Don't fallback to interrupt-polling during re-initi=
alization with MSI-X enabled.
      [SCSI] qla2xxx: Don't pollute kernel logs with ZIO/RIO status messa=
ges.
      [SCSI] qla2xxx: Collapse EFT/FCE copy procedures during a firmware =
dump.
      [SCSI] qla2xxx: Correct MQ-chain information retrieval during a fir=
mware dump.
      [SCSI] qla2xxx: Use proper request/response queues with MQ instanti=
ations.
      [SCSI] qla2xxx: Add ISP81XX support.
      [SCSI] qla2xxx: Update version number to 8.03.00-k1.

Andrew Victor (4):
      [ARM] 5287/2: [AT91] Configuration of Static Memory Controller
      [ARM] 5288/1: [AT91] Remove SMC configuration from devices.c files
      [ARM] 5289/1: [AT91] Convert boards to use sam9_smc_configure()
      [ARM] 5290/1: [AT91] Add support for the Adeneo NeoCore 926 board

Andrey Borzenkov (3):
      orinoco: reload firmware on resume
      orinoco: cache downloadable firmware image in memory for use during=
 resume
      orinoco: indicate it is using dBm in wireless_stats and spy

Andrey Yurovsky (4):
      ath5k: fix mesh point operation
      mac80211: allow all interfaces types to handle RX action frames
      mac80211: disable BSSID filtering for mesh interfaces
      mac80211_hwsim: enable Mesh Point operation

Andy Adamson (4):
      NFS: remove white space from nfs4xdr.c
      NFS: fix tabs in nfs4xdr.c
      NFS: increment number of operations in each encode routine
      NFS: remove unused status from encode routines

Andy Fleming (6):
      gianfar: Use gfar_halt to stop DMA in gfar_probe
      gianfar: Convert gianfar to an of_platform_driver
      gianfar: Add macros for stepping through BDs
      phylib: Remove unnecessary "reset" fixups in genphy_setup_forced
      gianfar: Fix packet drop when out of memory
      gianfar: Continue polling until both tx and rx are empty

Andy Gospodarek (1):
      bonding: update docs to correctly reflect arp_ip_target behavior

Andy Spencer (1):
      i8k: Enable i8k on Dell Precision Systems

Andy Walls (39):
      V4L/DVB (9474): cx18: Remove redundant block scope variable in cx18=
_probe() for sparse
      V4L/DVB (9512): cx18: Fix write retries for registers that always c=
hange - part 3.
      V4L/DVB (9514): cx18: Fix PLL freq computation for debug display
      V4L/DVB (9513): cx18: Reduce number of mmio read retries
      V4L/DVB (9592): cx18: Use default kernel work queue; fix streaming =
flag for work handler
      V4L/DVB (9593): cx18: Add outgoing mailbox mutexes and check for ac=
k via waitq vs poll
      V4L/DVB (9594): cx18: Roll driver version number due to significant=
 changes
      V4L/DVB (9595): cx18: Improve handling of outgoing mailboxes detect=
ed to be busy
      V4L/DVB (9596): cx18: Further changes to improve mailbox protocol i=
ntegrity & performnce
      V4L/DVB (9597): cx18: Minor fixes to APU firmware load process
      V4L/DVB (9598): cx18: Prevent CX23418 from clearing it's outgoing a=
ck interrupts to driver
      V4L/DVB (9599): cx18: Fix unitialized variable problem upon APU fir=
mware file read failure
      V4L/DVB (9720): cx18: Major rewrite of interrupt handling for incom=
ing mailbox processing
      V4L/DVB (9721): cx18: Change to singlethreaded global work queue th=
read for deferable work
      V4L/DVB (9722): cx18: Convert per stream queue spinlocks into mutex=
es
      V4L/DVB (9723): cx18: Propagate staleness of mailbox and mdl ack da=
ta to work handler
      V4L/DVB (9724): cx18: Streamline cx18-io[ch] wrappers and enforce M=
MIO retry strategy
      V4L/DVB (9725): cx18: Remove unnecessary MMIO accesses in time crit=
ical irq handling path
      V4L/DVB (9726): cx18: Restore buffers that have fallen out of the t=
ransfer rotation
      V4L/DVB (9727): cx18: Adjust outgoing mailbox timeouts and remove s=
tatistics logging
      V4L/DVB (9728): cx18: Copyright attribution update for files modifi=
ed by awalls
      V4L/DVB (9729): cx18: Update version due to significant irq handlin=
g changes
      V4L/DVB (9730): cx18: Quiet a sometimes common warning that often h=
as benign consequences
      V4L/DVB (9776): cx18: Change to per CX23418 device work queues for =
deferrable work handling
      V4L/DVB (9778): cx18: cx18_writel_expect() should not declare succe=
ss on a PCI read error
      V4L/DVB (9800): cx18: Eliminate q_io from stream buffer handling
      V4L/DVB (9801): cx18: Allow more than 63 capture buffers in rotatio=
n per stream
      V4L/DVB (9802): cx18: Add module parameters for finer control over =
buffer allocations
      V4L/DVB (9803): cx18: Increment version number due to siginificant =
buffering changes
      V4L/DVB (9804): cx18: Avoid making firmware API calls with the queu=
e lock held
      V4L/DVB (9805): cx18: Port fix for raw/sliced VBI mixup from ivtv a=
nd cx25840
      V4L/DVB (9806): cx18: Enable raw VBI capture
      V4L/DVB (9891): cx18 Replace magic number 63 with CX18_MAX_FW_MDLS_=
PER_STREAM
      V4L/DVB (9892): cx18: VBI comment corrections and comments about VB=
I issues
      V4L/DVB (9893): cx18: Convert some list manipulations to emphasize =
entries not lists
      V4L/DVB (9894): cx18: Use a known open task handle when setting str=
eam CX2341x parameters
      V4L/DVB (9895): cx18: Refine the firmware load and firmware startup=
 process
      V4L/DVB (9936): cx18: Disable locking of Video and Audio PLL for an=
alog captures
      V4L/DVB (9937): cx18: Use a consistent crystal value for computing =
all PLL parameters

Andy Whitcroft (22):
      netfilter: ip{,6}t_policy.h should include xp_policy.h
      serial: RS485 ioctl structure uses __u32 include linux/types.h
      checkpatch: add checks for in_atomic()
      checkpatch: comment detection may miss an implied comment on the la=
st hunk
      checkpatch: widen implied comment detection to allow multiple stars
      checkpatch: structure member assignments are not complex
      checkpatch: __weak is an official attribute
      checkpatch: detect multiple bitfield declarations
      checkpatch: comment ends inside strings is most likely not an open =
comment
      checkpatch: dissallow spaces between stars in pointer types
      checkpatch: version: 0.25
      checkpatch: update MAINTAINERS entry
      checkpatch: update copyrights
      checkpatch: allow parentheses on return for comparisons
      checkpatch: loosen spacing on typedef function checks
      checkpatch: fix continuation detection when handling spacing on ope=
rators
      checkpatch: track #ifdef/#else/#endif when tracking blocks
      checkpatch: do not report nr_static as a static declaration
      checkpatch: ensure we actually detect if assignments split across l=
ines
      checkpatch: struct file_operations should normally be const
      checkpatch: fix the perlcritic errors
      checkpatch: version: 0.26

Aneesh (2):
      btrfs: Code cleanup
      Btrfs: Some code cleanups

Aneesh Kumar K.V (21):
      ext4: Fix the delalloc writepages to allocate blocks at the right o=
ffset.
      ext4: avoid ext4_error when mounting a fs with a single bg
      ext4: Don't overwrite allocation_context ac_status
      ext4: sparse fixes
      ext4: Add blocks added during resize to bitmap
      ext4: Use EXT4_GROUP_INFO_NEED_INIT_BIT during resize
      ext4: cleanup mballoc header files
      jbd2: Call journal commit callback without holding j_list_lock
      tracing: branch tracer, fix writing to trace/trace_options
      ext4: don't use blocks freed but not yet committed in buddy cache i=
nit
      ext4: Fix lockdep recursive locking warning
      ext4: fix BUG when calling ext4_error with locked block group
      ext4: Fix race between read_block_bitmap() and mark_diskspace_used(=
)
      ext4: Use high 16 bits of the block group descriptor's free counts =
fields
      ext4: code cleanup
      ext4: Fix the race between read_inode_bitmap() and ext4_new_inode()
      ext4: Use new buffer_head flag to check uninit group bitmaps initia=
lization
      ext4: mark the blocks/inode bitmap beyond end of group as used
      ext4: Don't allow new groups to be added during block allocation
      ext4: Init the complete page while building buddy cache
      ext4: Fix s_dirty_blocks_counter if block allocation failed with no=
delalloc

Anirban Chakraborty (6):
      [SCSI] qla2xxx: Refactor qla data structures
      [SCSI] qla2xxx: Code changes for qla data structure refactoring
      [SCSI] qla2xxx: Fix for build warning
      [SCSI] qla2xxx: Code changes for vport bus reset
      [SCSI] qla2xxx: add support for multi-queue adapter
      [SCSI] qla2xxx: changes in multiq code

Anisse Astier (1):
      trivial: chack -> check typo fix in main Makefile

Anna Neal (2):
      libertas: Fine grained configuration of wake-on-lan.
      libertas: Create sysfs entry for changing the mesh probe response l=
imit

Anne Smorthit (1):
      Staging: comedi: add icp_multi driver

Anton Vorontsov (41):
      powerpc: Remove device_type =3D "rtc" properties in .dts files
      [ARM] pxa: add basic support for HP iPAQ h5000
      powerpc and sparc: Introduce dev_archdata node accessors
      of/i2c: Fill the archdata for I2C devices
      of/gpio: Implement of_get_gpio_flags()
      powerpc/qe: Move cmxgcr_lock definition from the ucc.c into the qe.=
c
      powerpc: Remove `have_of' global variable
      ucc_geth: Fix endless loop in stop_{tx,rx} routines
      ucc_geth: Fix TX watchdog timeout handling
      ucc_geth: Fix IRQ freeing code in ucc_geth_open()
      ucc_geth: Cleanup repetitive ucc_geth_memclean() calls
      ucc_geth: Fix IO memory (un)mapping code
      ucc_geth: Remove UGETH_FILTERING dead code
      of: Minor simplification for the of_parse_phandles_with_args()
      of: of_parse_phandles_with_args() learns to differentiate 'hole' ce=
lls
      of/gpio: Implement of_gpio_count()
      powerpc: Make default kexec/crash_kernel ops implicit
      powerpc: Remove default kexec/crash_kernel ops assignments
      powerpc: Prepare xmon_save_regs for use with kdump
      powerpc/32/kdump: Implement crash_setup_regs() using ppc_save_regs(=
)
      powerpc/32: Allow __ioremap on RAM addresses for kdump kernel
      ucc_geth: Eliminate the need for forward references
      powerpc: Implement get_brgfreq() and get_baudrate() stubs
      powerpc/83xx: Fix sparse warnings in board files
      powerpc/83xx: Fix sparse warnings in mpc836x_mds.c
      powerpc/qe: Implement QE Pin Multiplexing API
      powerpc: Add device tree bindings for BCSR GPIO banks
      powerpc: Implement GPIO driver for simple memory-mapped banks
      powerpc/83xx: Add USB Host/Gadget support for MPC8360E-MDS boards
      powerpc/83xx: Add USB Host support for MPC8360E-RDK boards
      powerpc/fsl_pci: Fix sparse warnings
      powerpc/83xx: Fix few build errors with CONFIG_QUICC_ENGINE=3Dn
      powerpc/qe: Fix few build errors with CONFIG_QUICC_ENGINE=3Dn
      powerpc/qe: Select QE_USB with USB_GADGET_FSL_QE
      mmc: Add mmc_vddrange_to_ocrmask() helper function
      mmc_spi: Add support for OpenFirmware bindings
      rtc: bunch of drivers: fix 'no irq' case handing
      USB: protect hcd.h from multiple inclusions
      USB: fsl_qe_udc: Check for muram allocation errors
      powerpc/kdump: Use ppc_save_regs() in crash_setup_regs()
      powerpc/mm: Make clear_fixmap() actually work

Antonio Ospite (7):
      V4L/DVB (9682): gspca: New subdriver parameter 'bulk_nurbs'.
      V4L/DVB (9712): gspca:Subdriver ov534 added.
      V4L/DVB (9855): gspca: Simplify frame rate setting and debug in ov5=
34.
      V4L/DVB (9856): gspca: Use u8 values for USB control messages in ov=
534.
      V4L/DVB (9857): gspca: Use smaller chunks for urb buffer in ov534.
      V4L/DVB (9882): gspca - ov534: Fix typo.
      V4L/DVB (9883): gspca - ov534: Show sensor ID.

Antti Palosaari (1):
      V4L/DVB (9526): af9015: add support for KWorld USB DVB-T TV Stick I=
I (VS-DVBT 395U)

Aoi Shinkai (1):
      sh: Delete unnecessary mov in the interrupt exception entry point.

Aristeu Rozanski (3):
      x86, NMI watchdog: add support to enable and disable IOAPIC NMI
      x86, NMI watchdog: disable NMIs on LVT0 in case NMI watchdog is not=
 working
      x86, nmi-watchdog: update procfs nmi_watchdog file documentation v2

Arjan van de Ven (38):
      debug: add notifier chain debugging
      debug: add notifier chain debugging, v2
      x86: corruption-check: fix some style issues
      x86: corruption check: move the corruption checks into their own fi=
le
      x86: corruption check: run the corruption checks from a work queue
      x86: corruption-check: some post-move cleanups
      mutex: improve header comment to be actually informative about the =
API
      pci: use pci_ioremap_bar() in drivers/net
      tracing: add "power-tracer": C/P state tracer to help power optimiz=
ation
      debug warnings: consolidate warn_slowpath and warn_on_slowpath
      debug warnings: print the DMI board info name in a WARN/WARN_ON
      scripts: improve the decodecode script
      resources: skip sanity check of busy resources
      [SCSI] advansys, arcmsr, ipr, nsp32, qla1280, stex: use pci_ioremap=
_bar()
      pci: use pci_ioremap_bar() in drivers/mmc
      expand some comments (d_path / seq_path)
      UIO: use pci_ioremap_bar() in drivers/uio
      pci: use pci_ioremap_bar() in drivers/misc
      oops: increment the oops UUID every time we oops
      scripts: script from kerneloops.org to pretty print oops dumps
      pci: use pci_ioremap_bar() in drivers/video
      pci: use pci_ioremap_bar() in drivers/edac
      async: Asynchronous function calls to speed up kernel boot
      fastboot: make scsi probes asynchronous
      fastboot: make the libata port scan asynchronous
      fastboot: Make libata initialization even more async
      async: make the final inode deletion an asynchronous event
      bootchart: improve output based on Dave Jones' feedback
      async: don't do the initcall stuff post boot
      USB: use pci_ioremap_bar() in drivers/usb
      resource: allow MMIO exclusivity for device drivers
      bootchart: improve output based on Dave Jones' feedback
      async: make async_synchronize_full() more serializing
      partial revert of asynchronous inode delete
      async: make async a command line option for now
      libata: Add a per-host flag to opt-in into parallel port probes
      libata: only ports >=3D 0 need to synchronize
      bootgraph: make the bootgraph script show async waiting time

Arnaldo Carvalho de Melo (3):
      markers: add missing stdargs.h include, needed due to va_list usage
      blktrace: port to tracepoints
      dccp_diag: LISTEN sockets don't have CCIDs

Arnaud Ebalard (1):
      net: Remove unused parameter of xfrm_gen_index()

Arnd Bergmann (1):
      powerpc/cell: fix build breakage with CONFIG_SPUFS disabled

Artem Bityutskiy (51):
      UBIFS: slight compression optimization
      UBIFS: use bit-fields to store compression type
      UBIFS: introduce compression mount options
      UBIFS: separate debugging fields out
      UBIFS: add debugfs support
      UBIFS: run debugging checks only if they are enabled
      UBIFS: dump stack in LPT check functions
      UBIFS: introduce LPT dump function
      UBI: fix warnings when debugging is enabled
      UBI: fix deadlock
      UBI: some code re-structuring
      UBI: fix error path
      UBI: handle write errors in WL worker
      MTD: tests: add mtd_oobtest
      MTD: tests: add mtd_pagetest
      MTD: tests: add mtd_readtest
      MTD: tests: add mtd_speedtest
      MTD: tests: add mtd_stresstest
      MTD: tests: add mtd_subpagetest
      UBI: document UBI ioctls
      MTD: tests: add mtd_torturetest
      MTD: add MTD tests to compilation
      [MTD] fix dataflash 64-bit divisions
      [MTD] fix m25p80 64-bit divisions
      UBIFS: use PAGE_CACHE_MASK correctly
      UBIFS: fix tnc dumping
      UBIFS: improve budgeting dump
      UBIFS: various comment improvements and fixes
      UBIFS: fix available blocks count
      UBIFS: use nicer 64-bit math
      UBIFS: re-calculate min_idx_size after the commit
      UBIFS: avoid unnecessary calculations
      UBI: fix checkpatch.pl warnings
      UBIFS: fix constants initialization
      UBIFS: fix file-system synchronization
      UBIFS: always commit in sync_fs
      UBIFS: use ubi_sync
      UBIFS: always commit on unmount
      UBIFS: restore budg_uncommitted_idx
      UBIFS: do not lie about used blocks
      UBIFS: simplify make_free_space
      UBIFS: fix sparse warnings
      UBIFS: fix checkpatch.pl warnings
      UBIFS: fix writing uncompressed files
      UBIFS: allow mounting when short of space
      UBIFS: fix numerous spelling mistakes
      UBIFS: print debugging messages properly
      UBIFS: add more useful debugging prints
      UBIFS: do not use WB_SYNC_HOLD
      [JFFS2] remove junk prototypes
      rbtree: add const qualifier to some functions

Arun KS (3):
      ASoC: Add support for omap2evm board
      ASoC: Fix TWL4030 Kconfig dependency
      ARM: OMAP3: Pin multiplexing updates for 24xx and 34xx

Arun R Bharadwaj (1):
      sched: add uid information to sched_debug for CONFIG_USER_SCHED

Arve Hj=C3=B8nnev=C3=A5g (2):
      Staging: android: add binder driver
      Staging: android: add ram_console driver

Arvo Jarve (7):
      V4L/DVB (9345): Add event with changed status only
      V4L/DVB (9429): Add support for the Satelco Easywatch DVB-S2 PCI ca=
rd
      V4L/DVB (9430): stb0899: avoid parameter overwriting
      V4L/DVB (9432): Increment the AGC1 and AGC2 gain respectively, impr=
oves sensitivity slightly
      V4L/DVB (9433): Limit bandwidth with a 3dB response fall
      V4L/DVB (9438): Bug! RTF is signed
      V4L/DVB (9440): Bug in previous commit

Atsushi Nemoto (6):
      tc35815: Define more Rx status bits
      [MTD] physmap: fix leak of memory returned by parse_mtd_partitions
      tc35815: Enable StripCRC feature
      tx4939ide: Do not use zero count PRD entry
      tx493[89]ide: Fix length for __ide_flush_dcache_range
      rtc: add rtc-tx4939 driver

Avi Kivity (13):
      KVM: VMX: Conditionally request interrupt window after injecting ir=
q
      KVM: x86 emulator: reduce duplication in one operand emulation thun=
ks
      KVM: x86 emulator: consolidate emulation of two operand instruction=
s
      KVM: x86 emulator: Extract 'pop' sequence into a function
      KVM: x86 emulator: allow pop from mmio
      KVM: x86 emulator: switch 'pop reg' instruction to emulate_pop()
      KVM: x86 emulator: fix ret emulation
      KVM: x86 emulator: fix popf emulation
      KVM: Remove extraneous semicolon after do/while
      KVM: Advertise the bug in memory region destruction as fixed
      KVM: Consolidate userspace memory capability reporting into common =
code
      KVM: MMU: Don't treat a global pte as such if cr4.pge is cleared
      KVM: Add locking to virtual i8259 interrupt controller

BARRE Sebastien (1):
      rtc-ds1307: SMBus compatibility

Babu Moger (1):
      [SCSI] scsi_dh_rdac: Add LSI vendor and product ids in rdac device =
list

Bahadir Balban (1):
      RealView: Add support for the Cortex-A8 Platform Baseboard

Balaji Rao (3):
      Btrfs: Remove unused variable in fixup_tree_root_location
      Introduce btrfs_iget helper
      NFS support for btrfs - v3

Balazs Scheidler (1):
      TPROXY: implemented IP_RECVORIGDSTADDR socket option

Balbir Singh (4):
      memcg: memory cgroup hierarchy documentation
      memcg: memory cgroup resource counters for hierarchy
      memcg: memory cgroup hierarchical reclaim
      memcg: memory cgroup hierarchy feature selector

Baodong Chen (1):
      Documentation/x86/boot.txt: payload length was changed to payload_l=
ength

Barry Naujok (4):
      [XFS] Remove final remnants of dirv1 macros and other stuff
      [XFS] Sync up kernel and user-space headers
      [XFS] Check agf_btreeblks is valid when reading in the AGF
      [XFS] Show buffer address with debug hexdump on corruption

Bartlomiej Zolnierkiewicz (72):
      ide: fix IDE ACPI regression breaking suspend
      ide: unify ide_intr()'s exit points
      ide: IDE settings don't need an ide_lock held
      ide: __ide_port_unregister_devices() doesn't need an ide_lock held
      ide: ide_hwgroup_t.rq doesn't need an ide_lock held
      ide: push ide_lock to __ide_end_request()
      ide: ide_lock + __blk_end_request() -> blk_end_request()
      ide: use queue lock instead of ide_lock when possible
      ide: replace the global ide_lock spinlock by per-hwgroup spinlocks =
(v2)
      ide: cleanup ide_do_request()
      ide-cd: remove obsolete seek optimization
      ali14xx: doesn't use shared IRQs
      cmd64x: set IDE_HFLAG_SERIALIZE explictly for CMD646
      gayle: set IDE_HFLAG_SERIALIZE explictly
      ide: fix ->quirk_list checking in ide_do_request()
      ide: always set nIEN on idle devices
      rz1000: apply chipset quirks early (v2)
      ide: add ->max_sectors field to struct ide_port_info
      trm290: add IDE_HFLAG_TRM290 host flag
      cy82c693: remove superfluous ide_cy82c693 chipset type
      ide: rework handling of serialized ports (v2)
      ide: remove redundant code from ide_end_drive_cmd()
      ide: remove inline tags from ide-probe.c
      ide: checkpatch.pl fixes for ide-lib.c
      ide: use ATA_DMA_* defines in ide-dma-sff.c
      ide: move Power Management support to ide-pm.c
      ide: move legacy ISA/VLB ports handling to ide-legacy.c (v2)
      ide: remove superfluous local_irq_{save,restore}() from ide_dump_st=
atus()
      ide: push local_irq_{save,restore}() to do_identify()
      ide-cd: remove dead dsc_overlap setting
      tx493x: fix indentation
      ide: remove chipset type fixup from ide_host_register()
      ide: small ide_register_port() cleanup
      ide: factor out device type classifying from do_identify()
      ide: move sysfs support to ide-sysfs.c
      ide: don't execute the next queued command from the hard-IRQ contex=
t (v2)
      ide: remove IDE PM hack from do_ide_request()
      ide: remove "paranoia" checks for hwgroup->busy
      ide: add ide_[un]lock_hwgroup() helpers
      ide: use per-device request queue locks (v2)
      ide: fix LOCKDEP warning
      ide: fix setting nIEN on idle devices
      ide: add ->cur_port to struct ide_host and use it for serialized ho=
sts
      ide: use per-port IRQ handlers
      ide: remove hwgroup->hwif and {drive,hwif}->next
      ide: use lock bitops for ports serialization (v2)
      ide: merge ide_hwgroup_t with ide_hwif_t (v2)
      ide: update ide_unregister() documentation
      ide: move ide_init_port_data() and friends to ide-probe.c
      ide: remove HWIF() macro
      ide: remove local_irq_set() macro
      ide: remove ide_pci_enablebit_t typedef
      ide: remove 'byte' typedef
      ide: remove ide_driver_t typedef
      ide: unexport ide_wait_not_busy()
      ide: remove ->error method from struct ide_driver
      amd74xx: use ide_get_pair_dev() helper
      cmd640: use ide_get_pair_dev() helper
      cmd64x: use ide_get_pair_dev() helper
      it821x: use ide_get_pair_dev() helper
      ide: NUMA aware allocation of host and port structures
      ide: dynamic allocation of device structures
      ide: add port and host iterators
      ide: make "paranoia" ->handler check in ide_intr() more strict
      ide: use ide_pci_is_in_compatibility_mode() helper in setup-pci.c
      ide: remove superfluous hwif variable assignment from ide_timer_exp=
iry()
      ide: struct ide_atapi_pc - remove unused fields and update document=
ation
      ide: remove unused ide_hwif_t.sg_mapped field
      ide: remove now redundant ->cur_dev checks
      ide: fix ide_port_scan() to do ACPI setup after initializing reques=
t queues
      ide: update warm-plug HOWTO
      piix: sync ich_laptop[] with ata_piix.c

Baruch Siach (2):
      enc28j60: reduce the number of spi transfers in enc28j60_set_bank()
      enc28j60: fix RX buffer overflow

Bastian Blank (1):
      sparc: Use 64BIT config entry

Becky Bruce (5):
      powerpc: Add sync_*_for_* to dma_ops
      powerpc: Fix !CONFIG_PPC_NEED_DMA_SYNC_OPS build warning
      swiotlb: store phys address in io_tlb_orig_addr array
      swiotlb: add support for systems with highmem
      powerpc/86xx: Update 8641hpcn dts file to match latest u-boot

Ben Dooks (137):
      [ARM] S3C: Move regs-watchdog.h to arch/arm/plat-s3c/include/plat
      [ARM] S3C: Move i2c headers to arch/arm/plat-s3c/include/plat.
      [ARM] S3C: Move regs-rtc.h to arch/arm/plat-s3c/include/plat
      [ARM] S3C: Move nand headers to arch/arm/plat-s3c/include/plat
      [ARM] S3C: Move regs-ac97.h to arch/arm/plat-s3c/include/plat.
      [ARM] S3C24XX: Movev udc headers to arch/arm/plat-s3c24xx/include/p=
lat
      [ARM] S3C: Move plat/regs-spi.h to arch/arm/plat-s3c/include/plat.
      [ARM] S3C24XX: Move mci.h to arch/arm/plat-s3c24xx/include/plat
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6 into s3c-moves2
      [ARM] KS8695: Add GPIO to IRQ mapping function
      [ARM] S3C24XX: Default SPI pin configuration for SPI
      [ARM] S3C: Add <plat/cpu-freq.h> for initial cpufreq definitions
      [ARM] S3C2410: Move base clock code to plat-s3c24xx
      [ARM] S3C: Make <mach/timex.h> common
      [ARM] S3C24XX: Move vmalloc.h to plat-s3c
      [ARM] S3C24XX: Add default <mach/io.h> header
      [ARM] S3C24XX: Move initialisation code to arch/arm/plat-s3c
      [ARM] S3C24XX: Split DCLK/CLKOUT definitions out of clock.c
      [ARM] S3C24XX: Split pll code out of regs-clock.h
      [ARM] CPUFREQ: S3C24XX serial CPU frequency scaling support.
      [ARM] S3C24XX: Change clock locking to use spinlocks.
      [ARM] S3C24XX: Update clock data on resume
      [ARM] S3C24XX: Move headers from plat-s3c24xx to plat-s3c
      [ARM] S3C: Move S3C2410_EXTINT to common regs-irqtype.h header
      [ARM] S3C: Move time.c to arch/arm/plat-s3c
      [ARM] S3C: Move core clock support to plat-s3c
      [ARM] S3C: Move pwm-clock.c to arch/arm/plat-s3c
      [ARM] S3C: BUG_ON() if clock has already been registered
      [ARM] S3C24XX: Reduce code lineage of gpiolib.c
      [ARM] S3C: Add set_rate/round_rate methods for pwm-scaler clock
      [ARM] S3C: Fix scaler1 clock rate information
      [ARM] S3C24A0: Debug macro definitions
      [ARM] S3C24XX: Split map.h into plat-s3c24xx and mach-s3c2410
      [ARM] S3C24A0: Initial architecture support files
      [ARM] S3C24XX: Split timer pending code out
      [ARM] S3C64XX: Initial arch directory
      [ARM] S3C64XX: Initial arch header files
      [ARM] S3C64XX: Add <mach/entry-macro.S>
      [ARM] S3C64XX: Add <mach/debug-macro.S>
      [ARM] S3C64XX: Add <plat/regs-clock.h>
      [ARM] S3C64XX: Add system boot-time support
      [ARM] S3C64XX: Add UARTdevice definitions
      [ARM] S3C64XX: Add IRQ definitions for VIC0 and VIC1
      [ARM] S3C64XX: Basic CPU detection and map initialisation
      [ARM] S3C6410: Initial CPU support code
      [ARM] S3C64XX: Add VIC0 and VIC1 sourced interripts
      [ARM] S3C6400: Add <mach/tick.h>
      [ARM] S3C: Fix PWM build on S3C6400
      [ARM] S3C64XX: Map timer memory and interrupts
      [ARM] S3C64XX: Common init code for S3C6400 and S3C6410
      [ARM] S3C64XX: Add PLL definitions
      [ARM] S3C64XX: Add initial clock framework
      [ARM] S3C: Add TICK_MAX for timer code
      [ARM] S3C64XX: Clock support for S3C6400/S3C6410
      [ARM] S3C6400: serial support for S3C6400 and S3C6410 SoCs
      [ARM] S3C: Update serial driver IRQ handling
      [ARM] S3C64XX: Demux UART interrupts
      [ARM] VIC: Update asm/hardware/vic.h with PL192 information
      [ARM] S3C64XX: Map GPIO block
      [ARM] S3C64XX: Add IRQ_EINT support
      [ARM] SMDK6410: Initial machine support
      [ARM] S3C64XX: Add s3c6400_defconfig
      [ARM] S3C64XX: Reduce some output from INFO to DEBUG
      [ARM] S3C64XX: Fix warnings from map_io initilaisers
      [ARM] S3C64XX: Add external interrupt group definitions
      [ARM] S3C: Move HSMMC device definition to plat-s3ec
      [ARM] SMDK6410: Add HSMMC0 device
      [ARM] S3C64XX: Add gpio bank numbering
      [ARM] S3C: Move common GPIO code from plat-s3c24xx
      [ARM] S3C: Add GPIO chip tracking
      [ARM] S3C64XX: GPIO library support
      [ARM] S3C: Add new GPIO configuration calls
      [ARM] S3C6400: Register clk_fout_epll
      [ARM] S3C6XX: Add enable for clk_48
      [ARM] S3C: Add Samsung SDHCI register definitions
      [ARM] S3C6410: Add helper for setting SDHCI device information
      [ARM] S3C: Add SDHCI (HSMMC) channel 1 device definition
      [ARM] S3C: Make i2c device definition common to plat-s3c
      [ARM] S3C64XX: GPIO definitions for BANKS A,B,C
      [ARM] S3C64XX: GPIO definitions for BANKS D,E,F
      [ARM] S3C64XX: GPIO definitions for BANKS G,H,I,J
      [ARM] S3C64XX: GPIO definitions for BANKS N,O,P,Q
      [ARM] S3C64XX: Add i2c device setup for I2C device 0
      [ARM] SMDK6410: Add i2c device
      [ARM] S3C64XX: Setup functions for i2c bus 1.
      [ARM] SMDK6410: Add second I2C channel.
      [ARM] SMDK6410: Add I2C device board information
      [ARM] S3C: Add header for initial i2c device core setup.
      [ARM] S3C64XX: Fix missing definition of s3c64xx_init_io()
      [ARM] S3C64XX: Fix MMC0 clock source register mask
      [ARM] SMDK6410: Add availability of second hsmmc channel
      [ARM] s3c6400_defconfig: Add I2C driver and devices
      [ARM] s3c6400_defconfig: Add SDHCI driver
      [ARM] S3C6410: Fix gpio configuration for channel 1.
      [ARM] S3C: Fix SDHCI setup compilation
      [ARM] S3C: Add register defines for new style framebuffer
      [ARM] S3C: Add i2c1 device definition
      [ARM] S3C: Add new FB device definition
      [ARM] S3C64XX: Add standard S3C64XX 24BPP LCD GPIO setup
      [ARM] SMDK6410: Add LCD (LCD48WVGA) definitions
      [ARM] S3C64XX: Update TCFG for new timer divider settings.
      [ARM] S3C: Update time initialisation to fix S3C64XX time problems
      [ARM] S3C: Add UART FIFO selection during arch decompression
      i2c-s3c2410: Fixup style problems from checkpatch.pl
      i2c-s3c2410: Use platform data for gpio configuration
      i2c-s3c2410: Remove default platform data.
      i2c-s3c2410: Allow more than one i2c-s3c2410 adapter
      i2c-s3c2410: Change IRQ to be plain integer.
      Merge branch 'i2c-for-ben' of git://git.kernel.org/pub/scm/linux/ke=
rnel/git/tmlind/linux-omap-2.6 into i2c-next
      i2c-omap: fix type of irq handler function
      [ARM] S3C24XX: ADC driver core
      [ARM] JIVE: fix spi gpio implementation
      [ARM] S3C24XX: Add extra GPIOs via Kconfig
      [ARM] ANUBIS: Add SM501 GPIO and update I2C setup
      [ARM] S3C24XX: AT2440EVB MMC
      [ARM] AT2440EVB: LCD frame buffer support.
      Merge branch 'next-s3c24xx' into next-merged
      Merge branch 'next-s3c64xx' into next-merged
      Merge branch 'next-s3c64xx-device' into next-merged
      [ARM] S3C: Update number of serial ports
      [ARM] S3C: Update CONFIG_SERIAL_SAMSUNG_UARTS handling
      [ARM] S3C24XX: Add fourth UART definition for S3C2443
      [ARM] S3C64XX: Remove __virt_to_bus/__bus_to_virt macros
      [ARM] S3C: Remove cpufreq warnings for unset serial information
      [ARM] S3C24A0: Remove duplicate <mach/io.h> file
      [ARM] S3C: Remove unnecessary <linux/delay.h> includes
      [ARM] 5349/1: VFP: Add PM code to save and restore current VFP stat=
e
      [ARM] S3C64XX: Ensure CPU_V6 is selected
      Merge branch 'i2c-next-s3c' into i2c-next
      spi: use generic gpio calls in spi_s3c24xx_gpio
      USB: gadget: s3c2410_udc uses standard GPIO calls
      [ARM] arch/arm/kernel/isa.c: missing definition of register_isa_por=
ts
      [ARM] footbridge: add isa_init_irq() to common header
      [ARM] footbridge: dc21285.c warning fixes
      [ARM] S3C24XX: Add gpio_to_irq() facility
      [ARM] S3C24XX: Add gpio_to_irq implementation
      [ARM] Ensure CONFIG_SERIAL_SAMSUNG_UARTS is always set.

Ben Efros (2):
      USB: storage devices and SAT
      USB: storage: Flag devices known to support SANE_SENSE

Ben Greear (1):
      ipv4: Fix ARP behavior with many mac-vlans

Ben Hutchings (43):
      sfc: Correct address of gPXE boot configuration in EEPROM
      sfc: Clean up non-volatile memory partitioning
      sfc: Expose flash region storing boot code as MTD
      sfc: Use lm87 and lm90 drivers for board temperature/power monitori=
ng
      sfc: Do not reset when hardware monitor detects a fault
      sfc: Fix dependency for SFC_MTD
      sfc: Board support fixes
      sfc: Change SPI lengths to type size_t
      sfc: Remove unneeded register write
      sfc: Correct interpretation of second param to ethtool phys_id()
      sfc: Clean up waits for flash/EEPROM operations
      sfc: Work around unreliable strap pins
      sfc: Restore phy_flash_cfg module parameter
      sfc: Provide hints to irqbalance daemon
      sfc: Abbreviate self-test names so they are not truncated
      sfc: Don't count RX checksum errors during loopback self-test
      sfc: Remove MII extension cruft
      sfc: Add support for MMDs numbered >15
      sfc: Add phy_type device attribute
      sfc: Clean up board identification
      sfc: Clean up MDIO flag setting
      sfc: Add support for sub-10G speeds
      sfc: Implement auto-negotiation
      sfc: Rework MAC, PHY and board event handling
      sfc: Add support for Solarflare 10Xpress SFT9001
      sfc: Add support for SFN4111T
      sfc: Remove leading spaces
      sfc: Specify a meaningful component for loopback RX-side and PHY te=
sts
      sfc: Use mutex_lock_interruptible() for ethtool EEPROM access
      sfc: Use model numbers for PHY type names
      sfc: Use kzalloc() to ensure struct efx_spi_device is fully initial=
ised
      sfc: Fix synchronisation of efx_mtd_{probe,rename,remove}
      sfc: Version 2.3
      sfc: Generate unique names for per-NIC workqueues
      sfc: Fix unreliable link detection in some loopback modes
      sfc: Clean up PHY mode management in loopback self-test
      sfc: Merge top-level functions for self-tests
      sfc: Add support for multiple PHY self-tests
      sfc: SFT9001: Add cable diagnostics
      sfc: When disabling the NIC, close the device rather than unregiste=
ring it
      sfc: If AN is enabled, always read speed/duplex from the AN adverti=
sing bits
      PCI: Add pci_clear_master() as opposite of pci_set_master()
      net: sfc: Use pci_clear_master() to disable bus mastering

Ben Nizette (1):
      avr32: Remove DMATEST from defconfigs

Ben Stanley (2):
      ALSA: ca0106 Add comments to snd_ca0106_details struct
      ALSA: ca0106 MSI K8N Diamond MB spi_dac 2->1

Benjamin Herrenschmidt (33):
      powerpc: Fix domain numbers in /proc on 64-bit
      powerpc: Silence software timebase sync
      powerpc/pci: Cleanup debug printk's
      powerpc/pci: Use common PHB resource hookup
      powerpc/pci: Remove pcibios_do_bus_setup()
      powerpc/pci: Split pcibios_fixup_bus() into bus setup and device se=
tup
      powerpc/eeh: Make EEH device add/remove more robust
      powerpc/pci: Make pcibios_allocate_bus_resources more robust
      powerpc/pci: Fix various pseries PCI hotplug issues
      powerpc/pci: Cosmetic cleanups of pci-common.c
      powerpc: Fix ppc32 mm_struct CPU tracking in SMP
      powerpc/4xx: Add support for ISA holes on 4xx PCI/X/E
      powerpc: Fix bogus cache flushing on all 40x and BookE processors v=
2
      powerpc: Fix asm EMIT_BUG_ENTRY with !CONFIG_BUG
      powerpc/mm: Add local_flush_tlb_mm() to SW loaded TLB implementatio=
ns
      powerpc/mm: Rename tlb_32.c and tlb_64.c to tlb_hash32.c and tlb_ha=
sh64.c
      powerpc/mm: Remove flush_HPTE()
      powerpc/4xx: Extended DCR support v2
      powerpc/mm: Split mmu_context handling
      powerpc/mm: Rework context management for CPUs with no hash table
      powerpc/mm: Introduce MMU features
      powerpc/mm: Add SMP support to no-hash TLB handling
      powerpc/mm: Split low level tlb invalidate for nohash processors
      powerpc/44x: No need to mask MSR:CE, ME or DE in _tlbil_va on 440
      powerpc/mm: Runtime allocation of mmu context maps for nohash CPUs
      powerpc/mm: Rework usage of _PAGE_COHERENT/NO_CACHE/GUARDED
      powerpc/44x: 44x TLB doesn't need "Guarded" set for all pages
      powerpc: Fix missing 'blr' in _tlbia()
      Merge commit 'kumar/kumar-next' into next
      PCI: Add legacy_io/mem to all busses
      Merge commit 'origin/master' into next
      powerpc/pci: Reserve legacy regions on PCI
      powerpc: Fix missing semicolons in mmu_decl.h

Benjamin Krill (2):
      powerpc/cell: add QPACE as a separate Cell platform
      serial: Add driver for the Cell Network Processor serial port NWP d=
evice

Benjamin Marzinski (1):
      GFS2: Fix typo in gfs_page_mkwrite()

Benjamin Thery (11):
      net: fix /proc/net/ip_mr_cache display - V2
      net: /proc/net/ip_mr_cache, display Iif as a signed short
      netns: ip6mr: allocate mroute6_socket per-namespace.
      netns: ip6mr: dynamically allocates vif6_table
      netns: ip6mr: store netns in struct mfc6_cache
      netns: ip6mr: dynamically allocate mfc6_cache_array
      netns: ip6mr: declare counter cache_resolve_queue_len per-namespace
      netns: ip6mr: declare mroute_do_assert and mroute_do_pim per-namesp=
ace
      netns: ip6mr: declare reg_vif_num per-namespace
      netns: ip6mr: declare ip6mr /proc/net entries per-namespace
      netns: ip6mr: enable namespace support in ipv6 multicast forwarding=
 code

Benny Halevy (8):
      sunrpc: get rid of rpc_rqst.rq_bufsize
      nfs: return compound hdr.status when there are no op replies
      nfs: remove incorrect usage of nfs4 compound response hdr.status
      NFS: fix comment placement in nfs4xdr.c
      nfsd: dprint each op status in nfsd4_proc_compound
      nfsd: git rid of nfs4_cb_null_ops declaration
      nfsd: last_byte_offset
      nfsd: get rid of NFSD_VERSION

Benoit PAPILLAULT (2):
      ath9k : Display MAC/BB and RF version at startup (v2)
      ath5k: fix 802.11 header padding on RX, unpadding on TX

Bernd Porr (2):
      Staging: comedi: add usb usbdux driver
      Staging: comedi: add usb usbduxfast driver

Bernd Schmidt (5):
      Blackfin arch: Remove all traces of the relocation stack
      Blackfin arch: fix bugs in linker script when using upstream binuti=
ls
      Blackfin arch: fix bug - crashes in tcp_v4_send_reset
      Blackfin arch: Replace C version of 64 bit multiply with hand optim=
ized assembly
      Blackfin arch: Faster C implementation of  no-MPU CPLB handler

Bernhard Walle (1):
      pci, acpi: reroute PCI interrupt to legacy boot interrupt equivalen=
t, warning fix

Bharata B Rao (3):
      sched: include group statistics in /proc/sched_debug
      sched: add hierarchical accounting to cpu accounting controller
      sched: use RCU variant of list traversal in for_each_leaf_rt_rq()

Bjorn Helgaas (44):
      clocksource, acpi_pm.c: put acpi_pm_read_slow() under CONFIG_PCI
      ACPI: PCI: use conventional PCI address format
      ACPI: PCI: remove unnecessary null pointer checks
      ACPI: PCI: simplify buffer management for evaluating _PRT
      ACPI: PCI: ignore _PRT function information
      ACPI: PCI: fix GSI/IRQ naming confusion
      ACPI: PCI: move struct acpi_prt_entry declaration out of public hea=
der file
      ACPI: PCI: add a helper to convert _PRT INTx pin number to name
      ACPI: PCI: always use the PCI INTx pin values, not the _PRT ones
      ACPI: PCI: use 1-based encoding for _PRT quirks
      ACPI: PCI: lookup _PRT entry by PCI dev and pin, not segment/bus/de=
v/pin
      ACPI: PCI: tweak _PRT lookup debug
      ACPI: PCI: remove callback from acpi_pci_irq_lookup & acpi_pci_irq_=
derive
      ACPI: PCI: use positive logic to simplify code
      ACPI: PCI: follow typical PCI INTx swizzling pattern
      ACPI: PCI: combine lookup and derive
      ACPI: PCI: simplify list of _PRT entries
      ACPI: PCI: simplify struct acpi_prt_entry
      ACPI: PCI: expand acpi_pci_allocate_irq() and acpi_pci_free_irq() i=
nline
      ACPI: PCI: whitespace and useless initialization cleanup
      ACPI: PCI: add HP copyright
      PCI: make PCI bus resource messages more meaningful
      x86/PCI: make PCI bus locality messages more meaningful
      PCI: pcie port driver: remove extra printks
      PCI hotplug: cpqphp: use config space PCI interrupt pin encoding
      PCI: use config space encoding in pci_get_interrupt_pin()
      x86/PCI: use config space encoding for interrupt pins
      x86/PCI: minor logic simplications
      PCI: add pci_swizzle_interrupt_pin()
      PCI: arm: use generic pci_swizzle_interrupt_pin()
      PCI: sh: use generic pci_swizzle_interrupt_pin()
      PCI: powerpc: use generic pci_swizzle_interrupt_pin()
      PCI: alpha: use generic pci_swizzle_interrupt_pin()
      PCI: x86: use generic pci_swizzle_interrupt_pin()
      PCI: mips: use generic pci_swizzle_interrupt_pin()
      PCI: parisc: use generic pci_swizzle_interrupt_pin()
      PCI: add pci_common_swizzle() for INTx swizzling
      PCI: alpha: use generic INTx swizzle from PCI core
      PCI: arm: use generic INTx swizzle from PCI core
      PCI: mips: use generic INTx swizzle from PCI core
      PCI: sh: use generic INTx swizzle from PCI core
      PCI: x86/visws: use generic INTx swizzle from PCI core
      PCI: use dev_printk for PCI bus resource mssages
      x86/PCI: use dev_printk for PCI bus locality messages

Bob Copeland (11):
      mac80211: fix a few typos in mac80211 kernel doc
      ath9k: remove useless conditional
      ath5k: fix keytable type buglet in ath5k_hw_reset_key
      ath5k: enable hardware encryption for WEP
      ath5k: update keycache to support TKIP handling
      ath5k: set mac address in add_interface
      ath5k: preserve higher order bits when setting mac address
      ath5k: clean up ath5k_hw_set_key
      ath5k: enable combined michael mic in key cache
      ath5k: fix endianness of bitwise ops when installing mic
      ath5k: correct packet length in tx descriptors

Bob Moore (25):
      ACPICA: Fix several warnings under gcc 4 compiler
      ACPICA: Update FACS waking vector interfaces
      ACPICA: Optimize execution of AML While loops
      ACPICA: Add a mechanism to escape infinite AML While() loops
      ACPICA: Update debug output for IndexField I/O
      ACPICA: Fix namestring for the SystemCMOS address space
      ACPICA: Emit warning if two FACS or DSDT tables found in the FADT
      ACPICA: Add global pointer for FACS table to simplify FACS access
      ACPICA: Reformat comments, no functional changes
      ACPICA: Add support to externally execute _OSI method
      ACPICA: Remove references to obsolete ACPI_DUMP_APP
      ACPICA: Fix to allow aliases within ASL namepaths
      ACPICA: Add Buffer->String conversion for predefined methods
      ACPICA: Consolidate method arg count validation code
      ACPICA: Update version to 20081031
      ACPICA: New: acpi_get_gpe_device interface
      ACPICA: New: Public GPE group enable/disable interfaces
      ACPICA: New: acpi_read and acpi_write public interfaces
      ACPICA: Move all public H/W interfaces to new hwxface
      ACPICA: New: acpi_reset interface - write to reset register
      ACPICA: Restructure includes into public/private
      ACPICA: Fixes for various ACPI data tables
      ACPICA: Add ACPI_MUTEX_TYPE configuration option
      ACPICA: FADT parsing changes and fixes
      ACPICA: FADT: Update error msgs for consistency

Borislav Petkov (23):
      ide-cd: move debug defines into header
      ide: make IDE_AFLAG_.. numbering continuous again
      ide-atapi: add a dev_is_idecd-inline
      ide-atapi: combine drive-specific assignments
      ide-atapi: setup dma for ide-cd
      ide-atapi: accomodate transfer length calculation for ide-cd
      ide-atapi: teach ide atapi about drive->waiting_for_dma
      ide-cd: move cdrom_timer_expiry to ide-atapi.c
      ide-atapi: remove ide-scsi remnants from ide_issue_pc
      ide-atapi: remove ide-scsi remnants from ide_transfer_pc()
      ide-atapi: remove ide-scsi remnants from ide_pc_intr()
      ide: remove the last ide-scsi remnants
      ide-atapi: compute cmd_len based on device type in ide_transfer_pc
      ide-atapi: assign expiry and timeout based on device type
      ide-atapi: split drive-specific functionality in ide_issue_pc
      ide-cd: remove xferlen arg to cdrom_start_packet_command
      ide-cd: remove handler wrappers
      ide-atapi: remove timeout arg to ide_issue_pc
      ide-atapi: put the rest of non-ide-cd code into the else-clause of =
ide_transfer_pc
      ide-atapi: start dma in a drive-specific way
      ide-cd: wait for DRQ to get set per default
      ide-cd: start DMA before sending the actual packet command
      ide-cd: convert to ide-atapi facilities

Brent Casavant (1):
      ioc4: automatically load sgiioc4 subordinate module

Brian Haley (1):
      bonding: send IPv6 neighbor advertisement on failover

Brian King (19):
      powerpc: Update page-in counter for CMM
      powerpc: Disable Collaborative Memory Manager for kdump
      powerpc: Add reboot notifier to Collaborative Memory Manager
      [SCSI] ibmvfc: Fix log level filtering
      [SCSI] ibmvfc: Fix error reporting for some FC errors
      [SCSI] ibmvfc: Error handling fixes
      [SCSI] ibmvfc: Fix target initialization failure retry handling
      [SCSI] ibmvfc: Quiet gcc warning in ibmvfc_reset_device
      [SCSI] ibmvfc: Driver version 1.0.3
      [SCSI] ibmvfc: Fix oops in interrupt handler
      [SCSI] ibmvfc: Fix command timeouts due to cached CRQ access
      [SCSI] ibmvfc: Handle port login required response
      [SCSI] ibmvfc: Driver version 1.0.4
      [SCSI] ibmvfc: Delay NPIV login retry and add retries
      [SCSI] ibmvfc: Fix errors due to inconsistent command data
      [SCSI] ibmvscsi: Don't fail EH due to insufficient resources
      [SCSI] ibmvfc: Improve async event handling
      [SCSI] ibmvfc: Fixup command response translation
      [SCSI] ibmvscsi: Make max_requests module parameter more accurate

Brice Goglin (10):
      myri10ge: fix per-slice rx/tx_dropped counters
      myri10ge: remove hardcoded sram_size
      myri10ge: update DCA comments
      myri10ge: update firmware headers
      myri10ge: check fragmentation in LRO get_frag_header()
      myri10ge: update firmware headers to 1.4.37
      myri10ge: update driver version to 1.4.4-1.395
      myri10ge: print MAC and serial number on probe failure
      mm: rework do_pages_move() to work on page_sized chunks
      mm: move_pages: no need to set pp->page to ZERO_PAGE(0) by default

Bruce Allan (12):
      e1000e: commit speed/duplex changes for m88 PHY
      e1000e: 82571 check for link fix on 82571 serdes
      e1000e: update comments listing supported parts for each MAC family
      e1000e: check return of pci_save_state
      e1000e: ESB2 config after link up
      e1000e: link up/down messages must follow a specific format
      e1000e: sync change flow control variables with ixgbe
      e1000e: cosmetic newline in debug message
      e1000e: store EEPROM version number to prevent unnecessary NVM read=
s
      e1000e: fix incorrect link status when switch module pulled
      e1000e: check return code from NVM accesses and fix bank detection
      e100: cosmetic cleanup

Bruno Pr=C3=A9mont (1):
      viafb: fix crashes due to 4k stack overflow

Bryan Wu (13):
      Blackfin arch: add support for Blackfin latest processor family BF5=
1x
      Blackfin arch: fix bug - gpio_bank() macros messed up bank number c=
aculating with positioning a gpio
      Blackfin arch: Use GPIO_BANKSIZE macro to replace const number 16 f=
or GPIO_BANK_NUM macro caculating
      ASoC: Blackfin: Simplify the MMAP_SUPPORT macros protected code
      Blackfin arch: Fix bug - wrong endpoint number and dma channels of =
USB
      USB: musb: use new platform data interface of musb to replace old o=
ne
      USB: musb: add Blackfin driver to MUSB framework (v2)
      USB: musb: add Blackfin version low level register accessing helper=
 functions
      USB: musb: enable low level DMA operation for Blackfin
      USB: musb: add Blackfin specific configuration to MUSB
      USB: musb: add Blackfin Kconfig options and Makefile
      USB: musb: Blackfin provides read/write I/O accessor in header file=
s
      USB: musb: Kill some compiling warning in musb Blackfin part

Carl Love (2):
      powerpc/oprofile: IBM CELL: cleanup and restructuring
      powerpc/oprofile: IBM CELL: add SPU event profiling support

Casey Schaufler (1):
      smack: Add support for unlabeled network hosts and networks

Catalin Marinas (20):
      Add "thumbee" to the hwcap_str array
      Add HWCAP_NEON to the ARM hwcap.h file
      ARMv7: Add extra barriers for flush_cache_all compressed/head.S
      ARMv7: Branch over conditional undefined instructions in vfphw.S
      Do not flush the cache in flush_cache_v(un)map for VIPT caches
      ARMv7: Do not set TTBR0 in __v7_setup
      RealView: Change the clcd panel controls to use RGB instead of BGR
      RealView: Add debug-macro.S support for the PB1176 platform
      RealView: Make more vmalloc space by changing IO_ADDRESS
      Modern processors may need to drain the WB before WFI
      Fix the teehbr_read function prototype
      slab: Update the kmem_cache_create documentation regarding the name=
 parameter
      RealView: Allow PHYS_OFFSET at 0x70000000
      RealView: Use only the shadow mapping of ARM11MPCore local timers
      RealView: Clean up the machine_is_*() calls in platsmp.c
      RealView: Refactor the Ethernet device registration
      RealView: Allow the in-kernel smc911x.c driver on RealView
      RealView: Update the realview_defconfig file to a newer kernel
      RealView: Update the realview-smp_defconfig file to a newer kernel
      RealView: Select CPU_V6 for MACH_REALVIEW_PB11MP

Chaithrika U S (1):
      phy: Add LSI ET1011C PHY driver

Chandra Seetharaman (2):
      [SCSI] scsi_dh: Make sure the state of a path is set properly when =
controller is swapped from passive to active
      [SCSI] scsi_dh: Retry mode select in rdac device handler

Chandra shekhar (1):
      i2c-omap: Add support for omap34xx

Chatre, Reinette (2):
      iwlwifi: replace magic constants with define
      iwlwifi: store ucode version number

Cheng Renquan (3):
      block: use cancel_work_sync() instead of kblockd_flush_work()
      md: use list_for_each_entry macro directly
      md: need another print_sb for mdp_superblock_1

Chien Tung (2):
      RDMA/nes: Add loopback check to make_cm_node()
      RDMA/nes: Cleanup warnings

Chr (1):
      p54: initialize all deprecated fields

Chris Bagwell (1):
      LSA: hda - Add HP Acacia detection

Chris Ball (1):
      ALSA: cs5535audio: enable OLPC's V_REFOUT bias when recording

Chris J Arges (1):
      serial/pmac_zilog: Add console polling support

Chris Mason (648):
      Btrfs: Initial checkin, basic working tree code
      Btrfs: Faster deletes, add Makefile and kerncompat
      Btrfs: Add backing store, memory management
      Btrfs: Commenting/cleanup
      Btrfs: early extent mapping support
      Btrfs: add mkfs.c
      Btrfs: extent fixes
      Btrfs: switch to early splits
      Btrfs: Block sized tree extents and extent deletion
      Btrfs: Break up ctree.c a little
      Btrfs: push_leaf_right
      Btrfs: cleanup & comment
      Btrfs: Add fsx-style randomized tree tester
      Btrfs: fixup dbfile perms
      Btrfs: u64 cleanups
      Btrfs: 32bit cleanups
      Btrfs: more 32 bit cleanups
      Btrfs: Take out the merge-during-search-on-delete code, it is buggy.
      Btrfs: Add sparse checking to Makefile
      Btrfs: return code checking
      Btrfs: more return code checking
      Btrfs: merge on the way down during deletes
      Btrfs: Fixup the code to merge during path walks
      Btrfs: pretend page cache & commit code
      Btrfs: Fix extent code to use merge during delete
      Btrfs: period commit during initial fill in the random tester
      Btrfs: early reference counting
      Btrfs: Fixup reference counting on cows
      Btrfs: get rid of add recursion
      Btrfs: Fixup last found extent caching
      Btrfs: recursion free-first pass
      fix leak in btrfs_drop_snapshot
      Btrfs: get/set for struct header fields
      Btrfs: Add sparse endian annotations to struct header
      Btrfs: struct key endian fixes
      Btrfs: struct item endian fixes
      Btrfs: node->blockptrs endian fixes
      Btrfs: struct extent_item endian
      rename funcs and structs to btrfs
      Btrfs: make some funcs static
      Btrfs: merge leaves before split
      Btrfs: Change the super to point to a tree of trees to enable persi=
stent snapshots
      Btrfs: properly reset block cache on free
      Btrfs: add leaf data casting helper
      Btrfs: variable block size support
      Btrfs: reorder key offset and flags
      Btrfs: Use a chunk of the key flags to record the item type.
      Btrfs: add hash.h
      Btrfs: directory testing code and dir item fixes
      Btrfs: add inode item
      Btrfs: add a name_len to dir items, reorder key
      Btrfs: pin freed blocks from the FS tree too
      Btrfs: transaction handles everywhere
      Btrfs: minor comments
      Btrfs: add transaction.h to the Makefile
      Btrfs: Add inode map, and the start of file extent items
      Btrfs: Update TODO
      Btrfs: change dir-test to insert inode_items
      Btrfs: Better block record keeping, real mkfs
      Btrfs: initial move to kernel module land
      Mountable btrfs, with readdir
      Btrfs: transaction rework
      btrfs_create, btrfs_write_super, btrfs_sync_fs
      Btrfs: properly set new buffers for new blocks up to date
      Add generation number to btrfs_header, readdir fixes, hash collisio=
n fixes
      Btrfs: very minimal locking
      Btrfs: leak fixes, pinning fixes
      Btrfs: unlink and delete_inode
      Btrfs: very simple readdir readahead
      btrfs_mkdir
      Btrfs: add a radix back bit tree
      Btrfs: TODO update
      btrfs_dirty_inode
      btrfs_get_block, file read/write
      Btrfs: reference counts on data extents
      Btrfs: split out level field in struct header
      Btrfs: add generation field to file extent
      btrfs_truncate
      Btrfs: byte offsets for file keys
      btrfs_rmdir
      Btrfs: use a btree inode instead of sb_getblk
      Btrfs: sha256 csums on metadata
      Btrfs: btree address space fixes
      btrfs_file_write -- first pass
      Btrfs: verify csums on read
      Btrfs: hunting slab corruption
      Btrfs: corruption hunt continues
      Btrfs: still corruption hunting
      Btrfs: dynamic allocation of path struct
      Btrfs: corruptions fixed
      Btrfs: csum_verify_file_block locking fix
      Btrfs: don't wait on uptodate buffers on read
      Btrfs: early inline file data code
      Btrfs: support for items bigger than 1/2 the blocksize
      Btrfs: disable inline data code for now
      Btrfs: tweak the inode-map and free extent search starts on cold mo=
unt
      Btrfs: add dir inode index
      Btrfs: more inode indexed directory work
      Btrfs: finish off inode indexing in dirs, add overflows
      Btrfs: dirindex optimizations
      Btrfs: uuids
      Btrfs: start of support for many FS volumes
      Btrfs: groundwork for subvolume and snapshot roots
      Btrfs: snapshot progress
      Btrfs: drop the inode map tree
      Btrfs: drop owner and parentid
      Btrfs: cow file extents before writing
      Btrfs: only cow in get_block when create=3D=3D1
      Btrfs: when forced to cow for file_write, get the page uptodate fir=
st
      Btrfs: subvolumes
      Btrfs: detect duplicate subvol names
      Btrfs: use a dedicated inode num for root root dir
      Btrfs: early support for multiple devices
      Btrfs: create a logical->phsyical block number mapping scheme
      Btrfs: add disk ioctl, mostly working
      Btrfs: add a device id to device items
      Btrfs: early work to file_write in big extents
      Btrfs: progress on file_write
      Btrfs: rework csums and extent item ordering
      Btrfs: working file_write, reorganized key flags
      Btrfs: many file_write fixes, inline data
      Btrfs: directory inode index is back
      Btrfs: early fsync support
      Btrfs: write barriers on commit, balance level before split
      Btrfs: node balance optimizations
      Btrfs: add owner and type fields to the extents aand block headers
      Btrfs: fix extent owner/type setting on extent tree blocks
      Btrfs: new subvolume oops fix
      Btrfs: add dirty_inode call
      Btrfs: get rid of the extent_item type field
      Btrfs: fixup dirty_inode related deadlocks
      Btrfs: change around extent-tree prealloc
      Btrfs: start of block group code
      Btrfs: more block allocator work
      Btrfs: allocator tweaks
      Btrfs: try to drop dead cow pages from ram
      Btrfs: smarter transaction writeback
      Btrfs: prealloc more blocks for the extent map
      Btrfs: allocator improvements, inode block groups
      Btrfs: directory readahead
      Btrfs: fix page cache memory leak
      Btrfs: early metadata/data split
      Btrfs: more allocator enhancements
      Btrfs: allocator and tuning
      Btrfs: many allocator fixes, pretty solid
      Btrfs: fix check_node and check_leaf to use less cpu
      Btrfs: switch to crc32c instead of sha256
      Btrfs: patch queue: fix corruption when splitting large items
      Btrfs: allocator optimizations, truncate readahead
      Btrfs: 2.6.21-git fixes
      Btrfs: rename
      Btrfs: symlinks and hard links
      Btrfs: sparse files!
      Btrfs: fixup various fsx failures
      Btrfs: block group switching
      Btrfs: use a separate flag for search_start vs a hint in find_free_=
extent
      Btrfs: d_type optimization
      Btrfs: add compat ioctl
      Btrfs: get forced transaction commits via workqueue
      Btrfs: reap dead roots right after commit
      Btrfs: remove device tree
      Btrfs: fix oops after block group lookup
      Btrfs: split up super.c
      Btrfs: 64 bit div fixes
      Btrfs: printk fixes
      Btrfs: no slashes in subvolume names
      Btrfs: add GPLv2
      Btrfs: i386 fixes from axboe
      Btrfs: Added tag v0.2 for changeset 8edac0ff7fb5
      Btrfs: patch queue: page_mkwrite
      Subject: Rework btrfs_file_write to only allocate while page locks =
are held
      Btrfs: Added tag v0.3 for changeset edfcc0faa35c
      Btrfs: cache the extent tree preallocation
      Btrfs: reada while dropping snapshots
      Btrfs: Switch to libcrc32c to avoid problems with cryptomgr on high=
mem machines
      Btrfs: Audit callers and return codes to make sure -ENOSPC gets up =
the stack
      Btrfs: Add the ability to find and remove dead roots after a crash.
      Btrfs: Documentation update
      Btrfs: Added tag v0.4 for changeset d4bf0a71f074
      Btrfs: Fix mtime and ctime updates on parent dirs
      Btrfs: Fix super block updates during transaction commit
      Btrfs: Allow find_free_extent callers to pass in an exclusion range
      Btrfs: crash recovery fixes
      Btrfs: Added tag v0.5 for changeset 080c0640a527
      Btrfs: deal with api changes in 2.6.23-rc1
      Btrfs: Do snapshot deletion in smaller chunks.
      Btrfs: Fold some btree readahead routines into something more gener=
ic.
      Btrfs: Add run time btree defrag, and an ioctl to force btree defra=
g
      Btrfs: Added tag v0.6 for changeset c13e9a0bf9b4
      Btrfs: Let some locks go during defrag and snapshot dropping
      Btrfs: Replace extent tree preallocation code with some bit radix m=
agic.
      Btrfs: Further reduce the concurrency penalty of defrag and drop_sn=
apshot
      Btrfs: Btree defrag on the extent-mapping tree as well
      Btrfs: Add BH_Defrag to mark buffers that are in need of defragging
      Btrfs: Added tag v0.7 for changeset 6125224d77d0
      Btrfs: Do more extensive readahead during tree searches
      Btrfs: Make sure to cow the root during a snapshot
      Btrfs: Extent based page cache code.  This uses an rbtree of extent=
s and tests
      Btrfs: Add delayed allocation to the extent based page tree code
      Btrfs: Use mount -o subvol to select the subvol directory instead o=
f dev:
      Btrfs: Add file data csums back in via hooks in the extent map code
      Btrfs: fsx delalloc fixes
      Btrfs: remove extra drop_extent_cache call
      Add support for defragging files via btrfsctl -d.  Avoid OOM on ext=
ent tree
      Btrfs: Add more synchronization before creating a snapshot
      Btrfs: Reorder tests in set_extent_bit to properly find holes
      Btrfs: Find and remove dead roots the first time a root is loaded.
      Btrfs: Added tag v0.8 for changeset f5ce4cc64def
      Btrfs: Fix extra link count dec in rename
      Btrfs: add modules_install target
      Btrfs: Use balance_dirty_pages_nr on btree blocks
      Btrfs: Fix duplicate ENOSPC checks in find_free_extent
      btrfs_get_extent should treat inline extents as though they hold a =
whole block
      Btrfs: Create extent_buffer interface for large blocksizes
      Btrfs: Optimizations for the extent_buffer code
      Btrfs: Avoid memcpy where possible in extent_buffers
      Btrfs: Go back to kmaps instead of page_address in extent_buffers
      Btrfs: Fix extent_buffer and extent_state leaks
      Btrfs: Stop using radix trees for the block group cache
      Btrfs: Change the remaining radix trees used by extent-tree.c to ex=
tent_map trees
      Btrfs: Allow tree blocks larger than the page size
      Btrfs: Cache extent buffer mappings
      Btrfs: Use an array of pages in the extent buffers to reduce the co=
st of find_get_page
      Btrfs: Add back the online defragging code
      Btrfs: Fix allocation routines to avoid intermixing data and metada=
ta allocations
      Btrfs: Add an extent buffer LRU to reduce radix tree hits
      Btrfs: Allow tails larger than one page
      Btrfs: extent_map optimizations to cut down on CPU usage
      Breakout BTRFS_SETGET_FUNCS into a separate C file, the inlines wer=
e too big.
      Btrfs: Add back metadata checksumming
      Btrfs: Large block related defrag optimizations
      Btrfs: balance_dirty_pages_ratelimited is causing problems, use nr =
=3D=3D 1 always
      Btrfs: Defrag: only walk into nodes with the defrag bit set
      Btrfs: Add back file data checksumming
      Btrfs: Defrag only leaves, and only when the parent node has a sing=
le objectid
      Btrfs: Default to 8k max packed tails
      Btrfs: Fix typo: owner is a 64 bit field
      Btrfs: Fix read/write_extent_buffer to use KM_USER1 instead of KM_U=
SER0
      Btrfs: CPU usage optimizations in push and the extent_map code
      Btrfs: Avoid recursive KM_USER1 mappings in copy_extent_buffer
      Btrfs: Fix split_leaf to avoid incorrect double splits
      Btrfs: Optimize csum insertion to create larger items when possible
      Btrfs: Fix split_leaf to detect when it is extending an item
      Btrfs: Tune the automatic defrag code
      Btrfs: Compile fixes for 2.6.24-rc1
      Add O_SYNC support to btrfs_file_write
      Btrfs: Fix PAGE_CACHE_SHIFT shifts on 32 bit machines
      Btrfs: Fix a number of inline extent problems that Yan Zheng report=
ed.
      Btrfs: Add writepages support
      Btrfs: Make defrag check nodes against the progress key to prevent =
repeating work
      Btrfs: Optimize allocations as we need to mix data and metadata int=
o one group
      Fix recursive KM_USER1 usage in btrfs_realloc_node
      Btrfs: Change push_leaf_{leaf,right} to empty the src leave during =
item deletion
      Btrfs: Use writepages for the metadata too
      Btrfs: Fix failure cleanups when allocating extent buffers fail
      Btrfs: Allow large data extents in a single file to span into metad=
ata block groups
      Btrfs: Avoid extent_buffer lru corruption
      Btrfs: Add readpages support
      Btrfs: Fix extent bit range testing
      Btrfs: Avoid fragmentation from parallel delalloc filling
      Btrfs: Make sure page mapping dirty tag is properly cleared
      Btrfs: Add check for null block group to find_search_start
      Btrfs: Handle writeback under high memory pressure better
      Btrfs: Limit btree writeback to prevent seeks
      Btrfs: Only limit btree writeback for pdflush
      Btrfs: Fine tune the btree writeback exclusion some more
      Btrfs: Add efficient dirty accounting to the extent_map tree
      btrfs_drop_extents: make sure the item is getting smaller before tr=
uncate
      Btrfs: Add simple stripe size parameter
      Btrfs: Fix extent allocation for btree blocks as the disk fills
      Btrfs: Implement generation numbers in block pointers
      Btrfs: Add back pointers from extents to the btree or file referenc=
ing them
      Btrfs: Add lowest key information to back refs for extent tree bloc=
ks as well.
      Btrfs: Add back pointers from the inode to the directory that refer=
ences it
      Btrfs: Extra NULL block group checks in find_free_extent
      Btrfs: Add backrefs for symbolic link inodes
      Btrfs: Fix typo in .. check (thanks Yan)
      Fix btrfs_inc_ref to add backref hints
      Btrfs: Reorder extent back refs to differentiate btree blocks from =
file data
      Fixes for loopback files in btrfs
      Btrfs: Add mount -o nodatasum to turn of file data checksumming
      Btrfs: Add mount option to turn off data cow
      Btrfs: Fix extent_map and extent_state leaks by flushing lrus on FS=
 unmount
      Btrfs: Add mount option to enforce a max extent size
      Btrfs: Back port to 2.6.18-el kernels
      kmalloc a few large stack objects in the btrfs_ioctl path
      Btrfs: Fix delayed allocation to avoid missing delalloc extents
      Btrfs: Fix nodatacow extent lookup
      Btrfs: Less aggressive readahead on deletes
      Btrfs: Implement basic support for -ENOSPC
      Btrfs: Fix an off by one in the extent_map prepare write code
      Btrfs: Support for online FS resize (grow and shrink)
      Btrfs: Fix NULL block groups on reading the inode
      Btrfs: Add readahead to the online shrinker, and a mount -o alloc_s=
tart=3D for testing
      Btrfs: Explicitly send a root objectid to count_snapshots_in_path
      Btrfs: Reduce stack usage in the resizer, fix 32 bit compiles
      Btrfs: 32 bit compile fixes for the resizer and enospc checks
      Btrfs: Force inlining off in a few places to save stack usage
      count_snapshots: Properly update the leaf pointer after btrfs_next_=
leaf
      Btrfs: Fix lock ordering of the snapshot semaphore against the page=
 lock
      Btrfs: Change st_blocksize to 4k
      Btrfs: Lower the max inline size to 8k
      Properly call btrfs_search_slot while shrinking
      Btrfs: resizer: don't hold the fs_mutex for long periods of time
      Btrfs: Change tree block csum tagging to avoid false error messages
      Btrfs: Add data=3Dordered support
      Btrfs: Move snapshot creation to commit time
      Btrfs: Add some simple throttling to wait for data=3Dordered and sn=
apshot deletion
      Btrfs: Disable btree reada during extent backref lookups.
      Btrfs: online shrinking fixes
      Btrfs: Remove extent_map debugging message
      Btrfs: Add flush barriers on commit
      Btrfs: Fix extent_buffer usage when nodesize !=3D leafsize
      Btrfs: Remove verbose WARN_ON
      Btrfs: Change magic string to reflect new format
      Btrfs: Only delete roots from sysfs when they were added to sysfs
      Btrfs: Delete any remaining extent_maps before freeing the inode
      Btrfs: Add drop inode func to avoid data=3Dordered deadlock
      Rework btrfs_drop_inode to avoid scheduling
      Btrfs: Disable delalloc accounting for now
      Btrfs: Run igrab on data=3Dordered inodes to prevent deadlocks duri=
ng writeout
      Btrfs: Fix data=3Dordered vs wait_on_inode deadlock on older kernel=
s
      Btrfs: Use blk_congestion_wait on older kernels
      Btrfs: Add mount -o ssd, which includes optimizations for seek free=
 storage
      Btrfs: Include sched.h in the acl code for current (fixes compile o=
n 2.6.23)
      Btrfs: Fix hole insertion corner cases
      Btrfs: Split the extent_map code into two parts
      Btrfs: Tune readahead during defrag to avoid reading too much at on=
ce
      Btrfs: Force f_pos to the max when a readdir hits the end of the di=
rectory.
      Btrfs: Add some extra debugging around file data checksum failures
      Btrfs: extent_io and extent_state optimizations
      Btrfs: During deletes and truncate, remove many items at once from =
the tree
      Btrfs: Add inode item and backref in one insert, reducing cpu usage
      Btrfs: Do delalloc accounting via hooks in the extent_state code
      Btrfs: mount -o max_inline=3Dsize to control the maximum inline ext=
ent size
      Btrfs: Leave on the tree defragger in mount -o ssd, it still helps =
there
      Btrfs: Copy correct tree when inserting into slot 0
      Properly align the hole size in btrfs_setattr
      Fix hole start calculation in btrfs_settar
      Btrfs: Enable delalloc accounting
      Btrfs: Add data block hints to SSD mode too
      Btrfs: Add a lookup cache to the extent state tree
      Btrfs: Insert extent record and the first backref in a single balan=
ce
      Btrfs: Hash in the offset and owner for file extent backref keys
      Btrfs: Use last_alloc optimizations for metadata, even without -o s=
sd
      Btrfs: Fix delalloc account on state deletion
      Btrfs: Lower stack usage in transaction.c
      Btrfs: Add debugging for block group update failure
      Btrfs: Update magic
      Btrfs: Add checks for last byte in disk to allocator grouping
      Btrfs: Use 2MB as the empty_size for clustered allocations
      Btrfs: Don't case unsigned long to int in bio submission
      Btrfs: Create larger bios for btree blocks
      Btrfs: Fix i_blocks accounting
      Btrfs: Disable tree defrag in SSD mode
      Btrfs: Allocator improvements
      Btrfs: Remove extent back refs in batches, and avoid duplicate sear=
ches
      Btrfs: Properly clear dirty and delalloc extent bits while preparin=
g the file for write
      Btrfs: Take the extent lock before dropping the delalloc bits
      Btrfs: Properly cast before shifting
      Btrfs: checksum file data at bio submission time instead of during =
writepage
      Btrfs: While doing checksums on bios, cache the extent_buffer mappi=
ng
      Btrfs: Misc 2.6.25 updates
      Btrfs: Make sure bio pages are adjacent during bulk csumming
      Btrfs: Disable sysfs files on older kernels
      Btrfs: Use KM_USERN instead of KM_IRQ during data summing
      Match the extent tree code to btrfs-progs for multi-device merging
      Btrfs: Add support for multiple devices per filesystem
      Btrfs: Dynamic chunk and block group allocation
      Btrfs: Bring back find_free_extent CPU usage optimizations
      Add /dev/btrfs-control for device scanning ioctls
      Btrfs: Make the FS tree the last objectid in the tree of tree roots
      Btrfs: Move device information into the super block so it can be sc=
anned
      Btrfs: Bring back mount -o ssd optimizations
      Btrfs: Add support for device scanning and detection ioctls
      Btrfs: Implement raid0 when multiple devices are present
      Create a btrfs backing dev info
      Btrfs: Use a higher default ra pages
      Btrfs: Add leak debugging for extent_buffer and extent_state
      Reorder the flags field in struct btrfs_header and record a flag on=
 writeout
      Btrfs: Keep fs_mutex during reads done by snapshot deletion
      Btrfs: Verify checksums on tree blocks found without read_tree_bloc=
k
      Btrfs: Properly dirty buffers in the split corner cases
      Btrfs: Add support for mirroring across drives
      Btrfs: Add support for duplicate blocks on a single spindle
      Btrfs: Don't allow written blocks from this transaction to be reall=
ocated
      Btrfs: Fix allocation profile init
      Change btrfs_map_block to return a structure with mappings for all =
stripes
      Btrfs: Add additional debugging for metadata checksum failures
      Btrfs: Do metadata checksums for reads via a workqueue
      Btrfs: Handle data block end_io through the async work queue
      Btrfs: Retry metadata reads in the face of checksum failures
      Btrfs: Handle checksumming errors while reading data blocks
      Btrfs: Disable extra debugging checks on tree blocks
      Btrfs: Add O_DIRECT read and write (writes =3D=3D buffered + cache =
flush)
      Btrfs: Write out all super blocks on commit, and bring back proper =
barrier support
      Btrfs: Add extra checks to avoid removing extent_state from pages w=
e can't free
      Btrfs: Fixup a few u64<->pointer casts for 32 bit
      Add a min size parameter to btrfs_alloc_extent
      Btrfs: A few updates for 2.6.18 and versions older than 2.6.25
      Btrfs: Add chunk uuids and update multi-device back references
      Btrfs: Add RAID10 support
      Btrfs: Create a work queue for bio writes
      Btrfs: Write bio checksumming outside the FS mutex
      Btrfs: Don't wait on tree block writeback before freeing them anymo=
re
      Btrfs: Only do async bio submission for pdflush
      Btrfs: Use the extent map cache to find the logical disk block duri=
ng data retries
      Btrfs: Avoid 64 bit div for RAID10
      Btrfs: Remove bogus max_sector warnings from the extent_io code
      Btrfs: Check device uuids along with devids
      Btrfs: Add support for labels in the super block
      Btrfs: Don't drop extent_map cache during releasepage on the btree =
inode
      Btrfs: Calculate appropriate chunk sizes for both small and large f=
ilesystems
      Btrfs: Fix chunk allocation when some devices don't have enough roo=
m for stripes
      Btrfs: Set the btree inode i_size to OFFSET_MAX
      Force page->private removal in btrfs_invalidatepage
      Btrfs: Scale the bdi ra_pages by the number of devices in the FS
      Btrfs: Add 1MB to the min_free in alloc_chunk
      Btrfs: Remove debugging statements from the invalidatepage calls
      Btrfs: Make an unplug function that doesn't unplug every spindle
      Btrfs: Simplify device selection for mirrored reads
      Btrfs: Add a special device list for chunk allocations
      Deal with page =3D=3D NULL in the btrfs_unplug_io_fn
      Btrfs: Set nodatasum on the inode when written by a nodatasum mount
      Fix btrfs_get_extent and get_block corner cases, and disable O_DIRE=
CT reads
      Btrfs: Fix the unplug_io_fn to grab a consistent copy of page->mapp=
ing
      Btrfs: Make sure nodes have enough room for a double split
      Btrfs: Fix split_node to require more empty slots in the node as we=
ll
      Btrfs: Don't empty the middle buffer in push_nodes_for_insert
      Btrfs: Fix balance_level to free the middle block if there is room =
in the left one
      Btrfs: Throttle file_write when data=3Dordered is flushing the inod=
e
      Btrfs: write_extent_pages came in 2.6.23
      Btrfs: Add failure handling for read_sys_array
      Btrfs: write_cache_pages came in 2.6.22
      Btrfs: Make the resizer work based on shrinking and growing devices
      Btrfs: Avoid recursive chunk allocations
      Btrfs: Do more optimal file RA during shrinking and defrag
      Btrfs: Add new ioctl to add devices
      Btrfs: Add balance ioctl to restripe the chunks
      Btrfs: Drop some verbose printks
      Btrfs: Deal with failed writes in mirrored configurations
      Btrfs: Tune stripe selection for raid1 and raid10
      Btrfs: Fixes for 2.6.18 enterprise kernels
      Btrfs: Compile warning fixup in volume.c
      Btrfs: Fix do_sync_file_range ifdefs (2.6.22)
      Btrfs: Silence bogus inode.c compiler warnings
      Btrfs: Fix clone ioctl to not hold the path over inserts
      Btrfs: Add support for online device removal
      Btrfs: Properly find the root for snapshotted blocks during chunk r=
elocation
      Btrfs: Update nodatacow mode to support cloned single files and res=
izing
      Btrfs: Only open block devices once during mount -o subvol=3D
      Btrfs: A number of nodatacow fixes
      Btrfs: Chunk relocation fine tuning, and add a few printks to show =
progress
      Btrfs: Don't do btree balance_dirty_pages on old kernels, it stalls=
 forever
      Btrfs: Pass down the expected generation number when reading tree b=
locks
      Btrfs: Handle write errors on raid1 and raid10
      Btrfs: Add mount -o degraded to allow mounts to continue with missi=
ng devices
      Fix btrfs_open_devices to deal with changes since the scan ioctls
      Fix corners in writepage and btrfs_truncate_page
      Btrfs: Change the congestion functions to meter the number of async=
 submits as well
      Btrfs: Enable btree balancing on old kernels again
      Btrfs: Handle transid =3D=3D 0 while opening devices
      Btrfs: Use kzalloc on the fs_devices allocation
      Btrfs: Allocator fix variety pack
      Btrfs: Always use the async submission queue for checksummed writes
      Btrfs: Fix race in running_transaction checks
      Btrfs: Add async worker threads for pre and post IO checksumming
      Btrfs: Fix mount -o max_inline=3D0
      Btrfs: Add backport for the kthread work on kernels older than 2.6.=
20
      Btrfs: Worker thread optimizations
      Btrfs: Add a mount option to control worker thread pool size
      Btrfs: Add a thread pool just for submit_bio
      Btrfs: Start btree concurrency work.
      Btrfs: Replace the big fs_mutex with a collection of other locks
      Drop locks in btrfs_search_slot when reading a tree block.
      Fix btrfs_del_ordered_inode to allow forcing the drop during unlink=
s
      Fix btrfs_next_leaf to check for new items after dropping locks
      Btrfs: Add a skip_locking parameter to struct path, and make variou=
s funcs honor it
      Btrfs: Fix snapshot deletion to release the alloc_mutex much more o=
ften.
      Add btrfs_end_transaction_throttle to force writers to wait for pen=
ding commits
      Btrfs: Replace the transaction work queue with kthreads
      Btrfs: Add btree locking to the tree defragmentation code
      Btrfs: Change find_extent_buffer to use TestSetPageLocked
      Btrfs: Add a per-inode csum mutex to avoid races creating csum item=
s
      Btrfs: Online btree defragmentation fixes
      Btrfs: Reduce contention on the root node
      Btrfs: Fix deadlock while searching for dead roots on mount
      Btrfs: Add locking around volume management (device add/remove/bala=
nce)
      Btrfs: Drop some verbose printks
      Btrfs: New data=3Dordered implementation
      Btrfs: Use async helpers to deal with pages that have been improper=
ly dirtied
      Btrfs: Update on disk i_size only after pending ordered extents are=
 done
      btrfs_start_transaction: wait for commits in progress to finish
      Btrfs: Don't pin pages in ram until the entire ordered extent is on=
 disk.
      Add a per-inode lock around btrfs_drop_extents
      btrfs_next_leaf: do readahead when skip_locking is turned on
      Btrfs: Force caching of metadata block groups on mount to avoid dea=
dlock
      Btrfs: Cleanup and comment ordered-data.c
      Btrfs: Handle data checksumming on bios that span multiple ordered =
extents
      Btrfs: Don't allow releasepage to succeed if EXTENT_ORDERED is set
      Btrfs: Keep extent mappings in ram until pending ordered extents ar=
e done
      Fix btrfs_wait_ordered_extent_range to properly wait
      Btrfs: Data ordered fixes
      Btrfs: Index extent buffers in an rbtree
      Btrfs: Use a mutex in the extent buffer for tree block locking
      Btrfs: Fix some data=3Dordered related data corruptions
      Btrfs: Use mutex_lock_nested for tree locking
      Btrfs: Add some conditional schedules near the alloc_mutex
      Btrfs: alloc_mutex latency reduction
      Btrfs: Take the csum mutex while reading checksums
      Btrfs: Fix 32 bit compiles by using an unsigned long byte count in =
the ordered extent
      Btrfs: Search data ordered extents first for checksums on read
      Btrfs: Fix some build problems on 2.6.18 based enterprise kernels
      Btrfs: Add version strings on module load
      Btrfs: Fix the defragmention code and the block relocation code for=
 data=3Dordered
      Btrfs: Rev the disk format magic
      Btrfs: Leaf reference cache update
      Btrfs: Fix version.sh when used outside of an hg repo
      Btrfs: Throttle operations if the reference cache gets too large
      Btrfs: Fix verify_parent_transid
      Btrfs: Add missing hunk from Yan Zheng's cache reclaim patch
      Btrfs: Throttle tuning
      Btrfs: Fix streaming read performance with checksumming on
      Btrfs: Drop some debugging around the extent_map pinned flag
      Btrfs: Hold a reference on bios during submit_bio, add some extra b=
io checks
      Btrfs: Improve and cleanup locking done by walk_down_tree
      Btrfs: Throttle less often waiting for snapshots to delete
      btrfs_search_slot: reduce lock contention by cowing in two stages
      Btrfs: More throttle tuning
      Btrfs: Hold csum mutex while reading in sums during readpages
      Btrfs: Add support for HW assisted crc32c
      Btrfs: Don't corrupt ram in shrink_extent_tree, leak it instead
      Btrfs: Maintain a list of inodes that are delalloc and a way to wai=
t on them
      btrfs_lookup_bio_sums seems broken, go back to the readpage_io_hook=
 for now
      Btrfs: Fix the multi-bio code to save the original bio for completi=
on
      Get rid of BTRFS_I(inode)->index and use local vars instead
      Btrfs: Avoid calling into the FS for the final iput on fake root in=
odes
      Btrfs: Update version.sh to v0.16
      Btrfs: Init address_space->writeback_index properly
      Btrfs: Limit the number of async bio submission kthreads to the num=
ber of devices
      Btrfs: Count async bios separately from async checksum work items
      Btrfs: Transaction commit: don't use filemap_fdatawait
      Btrfs: Give all the worker threads descriptive names
      Btrfs: Wait for kernel threads to make progress during async submis=
sion
      Btrfs: Lower contention on the csum mutex
      Btrfs: Fix add_extent_mapping to check for duplicates across the wh=
ole range
      Btrfs: Lookup readpage checksums on bio submission again
      Btrfs: Wait for async bio submissions to make some progress at queu=
e time
      Btrfs: Rev the disk format
      Btrfs: Throttle for async bio submits higher up the chain
      Btrfs: Fix variable init during csum creation
      Btrfs: Add debugging checks to track down corrupted metadata
      Btrfs: Add a write ahead tree log to optimize synchronous operation=
s
      Btrfs: Rev the disk format
      Btrfs: Tree logging fixes
      Btrfs: Update the highest objectid in a root after log replay is do=
ne
      Btrfs: Fix releasepage to properly keep dirty and writeback pages
      Btrfs: Dir fsync optimizations
      Btrfs: Optimize btree walking while logging inodes
      Btrfs: Optimize tree log block allocations
      Btrfs: Copy into the log tree in big batches
      Btrfs: Record dirty pages tree-log pages in an extent_io tree
      Btrfs: Disable the dir fsync optimization to skip logging the dir s=
ometimes
      Btrfs: Fix mismerge in block header checks
      Fix leaf overflow check in btrfs_insert_empty_items
      Btrfs: Checksum tree blocks in the background
      Add check for tree-log roots in btrfs_alloc_reserved_extents
      Btrfs: Fix race against disk_i_size updates
      Merge Btrfs into fs/btrfs
      Update Btrfs files for in-kernel usage
      Add Btrfs to fs/Kconfig and fs/Makefile
      Btrfs: Fix allocation completions in tree log replay
      Remove Btrfs compat code for older kernels
      Btrfs: fix sleep with spinlock held during unmount
      Btrfs: Raise thresholds for metadata writeback
      Btrfs: Wait for IO on the block device inodes of newly added device=
s
      Btrfs: drop WARN_ON from btrfs_add_leaf_ref
      Btrfs: add and improve comments
      Btrfs: fix multi-device code to use raid policies set by mkfs
      Btrfs: don't read leaf blocks containing only checksums during trun=
cate
      Btrfs: O_DIRECT writes via buffered writes + invaldiate
      Btrfs: remove last_log_alloc allocator optimization
      Btrfs: cast bio->bi_sector to a u64 before shifting
      Btrfs: Rev the disk format for the new back reference format
      Btrfs: Don't call security_inode_mkdir during subvol creation
      Merge branch 'master' of ssh://mason-OweEgu2LU2WbHZsODdEbfti2O/JbrIOy@public.gmane.org/pub/scm/linu=
x/kernel/git/mason/btrfs-unstable
      Btrfs: Add zlib compression support
      Btrfs: Rev the disk format for compression and root pointer generat=
ion fields
      Btrfs: prevent looping forever in finish_current_insert and del_pen=
ding_extents
      Btrfs: walk compressed pages based on the nr_pages count instead of=
 bytes
      Btrfs: Fix logic to avoid reading checksums for -o nodatasum,compre=
ss
      Btrfs: Compression corner fixes
      Btrfs: rev the disk format for fallocate
      Btrfs: Add ordered async work queues
      Btrfs: Optimize compressed writeback and reads
      Btrfs: enforce metadata allocation clustering
      Btfs: More metadata allocator optimizations
      Btrfs: make sure compressed bios don't complete too soon
      Btrfs: Fix more false enospc errors and an oops from empty clusteri=
ng
      Btrfs: Avoid unplug storms during commit
      Btrfs: Don't substract too much from the allocation target (avoid w=
rapping)
      Btrfs: Make sure pages are dirty before doing delalloc for them
      Btrfs: Fix use after free during compressed reads
      Btrfs: Try harder while searching for free space
      Btrfs: Use invalidatepage when writepage finds a page outside of i_=
size
      Btrfs: Fix usage of struct extent_map->orig_start
      Btrfs: Turn off extent state leak debugging
      Btrfs: tune btrfs unplug functions for a small number of devices
      Btrfs: empty_size allocation fixes again
      Btrfs: Fix compile warnings on 32 bit machines
      Btrfs: Improve metadata read latencies
      Btrfs: Fix handling of space info full during allocations
      Btrfs: Allow subvolumes and snapshots anywhere in the directory tre=
e
      Btrfs: Give each subvol and snapshot their own anonymous devid
      Btrfs: Add backrefs and forward refs for subvols and snapshots
      Btrfs: prevent loops in the directory tree when creating snapshots
      Btrfs: unplug all devices in the unplug call back
      Btrfs: Update the disk format for the seed device and new root code
      Btrfs: switch back to wait_on_page_writeback to wait on metadata wr=
ites
      Btrfs: Avoid writeback stalls
      Btrfs: Do fsync log replay when mount -o ro, except when on readonl=
y media
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/mason/btrfs-unstable
      Btrfs: Fixes for 2.6.28-rc API changes
      Btrfs: Use current_fsuid/gid
      Btrfs: compat code fixes
      Btrfs: only flush down bios for writeback pages
      Btrfs: delete unused function: btrfs_invalidate_dcache_root
      Btrfs: rev the disk format for the inode compat and csum selection =
changes
      Btrfs: Fix sparse endian warnings in struct-funcs.c
      Btrfs: move data checksumming into a dedicated tree
      Btrfs: Use map_private_extent_buffer during generic_bin_search
      Btrfs: Add inode sequence number for NFS and reserved space in a fe=
w structs
      Btrfs: Fix compressed checksum fsync log copies
      Btrfs: Delete csum items when freeing extents
      Btrfs: Fix compressed writes on truncated pages
      Btrfs: Don't use spin*lock_irq for the delalloc lock
      Btrfs: delete checksum items before marking blocks free
      Btrfs: shift all end_io work to thread pools
      Btrfs: Fix compile warning around num_online_cpus() in a min statem=
ent
      Btrfs: add permission checks to the ioctls
      Btrfs: Fix checkpatch.pl warnings
      Btrfs: drop EXPORT symbols from extent_io.c
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/mason/btrfs-unstable
      Btrfs: drop remaining LINUX_KERNEL_VERSION checks and compat code
      Btrfs: Don't use kmap_atomic(..., KM_IRQ0) during checksum verifies
      Btrfs: kmap_atomic(KM_USER0) is safe for btrfs_readpage_end_io_hook
      Btrfs: Drop the hardware crc32c asm code
      Btrfs: explicitly mark the tree log root for writeback

Chris Wright (2):
      PCI: allow pci driver to support only dynids
      PCI: pci-stub module to reserve pci device

Chris Zankel (3):
      xtensa: move headers files to arch/xtensa/include
      xtensa: Add xt2000 support files.
      xtensa: Update platform files to reflect new location of the header=
 files.

Christian Borntraeger (9):
      [S390] vmcp: remove BKL
      [S390] convert vmcp printks to pr_xxx macros.
      [S390] convert cpcmd printks to pr_xxx macros.
      virtio_console: support console resizing
      kvm-s390: implement config_changed for virtio on s390
      KVM: s390: Fix refcounting and allow module unload
      KVM: s390: Fix memory leak of vcpu->run
      anon_inodes: use fops->owner for module refcount
      KVM: set owner of cpu and vm file operations

Christian Hesse (1):
      Btrfs: section mismatch warnings

Christian Lamparter (30):
      p54: honour bss_info_changed's short slot time settings
      p54: broken out edcf changes
      p54: refactor statistic timer code
      p54: p54: refactor p54_rx_frame_sent
      p54: fix memory management
      p54: borrow some setup code from stlc45xx
      p54: introduce new names for device firmwares
      p54: more definitions form lmac_longbow.h and pda.h
      p54: put broadcast frames into the right queues
      p54: AP & Ad-hoc testing
      p54: enable Mesh Point support
      p54: minor fixes
      p54pci: cache firmware for suspend/resume
      p54: honour bss_info_changed's basic_rates and other settings
      p54: fix wmm queue settings
      mac80211: add sta_notify_ps callback
      p54: revamp station power save management in access point mode
      p54: utilize cryptographic accelerator
      p54: include support for 2.13.24.0 USB LM87 Firmwares
      p54: refactoring
      p54: per-device names
      p54usb: rewriting rx/tx routines to make use of usb_anchor's facili=
ties
      mac80211: integrate sta_notify_ps cmds into sta_notify
      p54: enforce strict tx_queue limits
      p54: fix oops on faulty devices
      p54: move statistic timer update routine into a workqueue
      p54: update ACK failure statistic counter in real-time
      p54: more accurate rssi to dBm conversion
      p54: remove free_on_tx parameter
      p54usb: bring first generation devices back to life

Christian Maaser (1):
      [S390] ap: Minor code beautification.

Christian Pellegrin (3):
      ASoC: s3c24xx 8 bit sound fix
      ASoC: UDA134x codec driver
      ASoC: Machine driver for for s3c24xx with uda134x

Christof Schmitt (11):
      [S390] zfcp: Report microcode level through service level interface
      [S390] convert zfcp printks to pr_xxx macros.
      [SCSI] zfcp: Fix message line break
      [SCSI] zfcp: Simplify SBAL allocation to fix sparse warnings
      [SCSI] zfcp: Remove adapter list
      [SCSI] zfcp: Remove initial device data from zfcp_data
      [SCSI] zfcp: Simplify mask lookups for incoming RSCNs
      [SCSI] zfcp: remove DID_DID flag
      [SCSI] zfcp: Remove busid macro
      [SCSI] zfcp: Add support for unchained FSF requests
      [SCSI] zfcp: Remove unnecessary warning message

Christoph Hellwig (126):
      btrfs: fix printk format warning
      Btrfs: [PATCH] extent_map: fix locking for bio completion
      Btrfs: [PATCH] extent_map: provide generic bmap
      Btrfs: [PATCH] extent_map: make the writepage_io hook optional
      Btrfs: [PATCH] extent_map: add writepage_end_io hook
      Btrfs: use unlocked_ioctl
      split up btrfs_ioctl
      Btrfs: factor page private preparations into a helper
      btrfs: tiny makefile cleanup
      btrfs: fix strange indentation in lookup_extent_mapping
      btrfs: sanity mount option parsing and early mount code
      btrfs: allow scanning multiple devices during mount
      Btrfs: kerneldoc comments for extent_map.c
      Btrfs: split out ioctl.c
      BTRFS_IOC_TRANS_START should be privilegued
      btrfs: optmize listxattr
      Btrfs: optimize btrget/set/removexattr
      Btrfs: cleanup d_obtain_alias useage
      Btrfs: missing endianess conversion in insert_new_root
      remove unused function btrfs_ilookup
      Btrfs: trivial sparse fixes
      Btrfs: Fix subvolume creation locking rules
      [XFS] kill struct xfs_btree_hdr
      [XFS] split up xfs_btree_init_cursor
      [XFS] add generic btree types
      [XFS] make btree root in inode support generic
      [XFS] add a long pointers flag to xfs_btree_cur
      [XFS] refactor xfs_btree_readahead
      [XFS] refactor btree validation helpers
      [XFS] make btree tracing generic
      [XFS] add get_maxrecs btree operation
      [XFS] add helpers for addressing entities inside a btree block
      [XFS] implement generic xfs_btree_increment
      [XFS] implement generic xfs_btree_decrement
      [XFS] implement generic xfs_btree_lookup
      [XFS] implement generic xfs_btree_updkey
      [XFS] implement generic xfs_btree_update
      [XFS] implement generic xfs_btree_rshift
      [XFS] implement generic xfs_btree_lshift
      [XFS] implement generic xfs_btree_split
      [XFS] implement semi-generic xfs_btree_new_root
      [XFS] move xfs_bmbt_newroot to common code
      [XFS] implement generic xfs_btree_insert/insrec
      [XFS] move xfs_bmbt_killroot to common code
      [XFS] implement generic xfs_btree_delete/delrec
      [XFS] implement generic xfs_btree_get_rec
      [XFS] kill xfs_bmbt_log_block and xfs_bmbt_log_recs
      [XFS] add keys_inorder and recs_inorder btree methods
      [XFS] mark various functions in xfs_btree.c static
      [XFS] make btree tracing generic
      [XFS] Cleanup maxrecs calculation.
      [XFS] cleanup btree record / key / ptr addressing macros.
      [XFS] Always use struct xfs_btree_block instead of short / longform
      [XFS] Move XFS_BMAP_SANITY_CHECK out of line.
      [XFS] split out two helpers from xfs_syncsub
      [XFS] fix instant oops with tracing enabled
      [XFS] kill struct xfs_mount_args
      [XFS] fix the noquota mount option
      [XFS] fix biosize option
      [XFS] Trivial xfs_remove comment fixup
      [XFS] stop using xfs_itobp in xfs_bulkstat
      Inode: export symbol destroy_inode
      [XFS] free partially initialized inodes using destroy_inode
      [XFS] kill sys_cred
      fat: make sure to set d_ops in fat_get_parent
      [XFS] fix NULL pointer dereference in xfs_log_force_umount
      [XFS] wire up ->open for directories
      [XFS] allow inode64 mount option on 32 bit systems
      [XFS] fix spurious gcc warnings
      [XFS] remove bhv_statvfs_t typedef
      [XFS] remove xfs_vfs.h
      [XFS] remove xfs_vfsops.h
      [XFS] factor out xfs_read_agi helper
      [XFS] sanitize xlog_in_core_t definition
      [XFS] kill xfs_ialloc_log_di
      [XFS] kill xfs_dinode_core_t
      [XFS] kill XFS_DINODE_VERSION_ defines
      [XFS] split up xlog_recover_process_iunlinks
      [XFS] stop using xfs_itobp in xfs_iread
      [XFS] remove dead code for old inode item recovery
      [XFS] merge xfs_imap into xfs_dilocate
      [XFS] embededd struct xfs_imap into xfs_inode
      [XFS] kill the XFS_IMAP_BULKSTAT flag
      [XFS] move inode allocation out xfs_iread
      [XFS] fix error handling in xlog_recover_process_one_iunlink
      Btrfs: sparse lock verification annotations for wait_on_state
      Btrfs: make things static and include the right headers
      Btrfs: fix shadowed variable declarations
      Btrfs: corret fmode_t annotations
      Btrfs: clean up btrfs_ioctl a little bit
      Btrfs: btrfs: pass void __user * to btrfs_ioctl_clone_range
      [XFS] fix compile on 32 bit systems
      remove useless mnt_want_write call in xfs_write
      remove unused behvavior cruft in xfs_super.h
      remove unused prototypes for xfs_ihash_init / xfs_ihash_free
      cleanup the inode reclaim path
      kill xfs_buf_iostart
      stop using igrab in xfs_vn_link
      reduce l_icloglock roundtrips
      remove dead code from sv_t implementation
      kill dead quota flags
      cleanup xfs_sb.h feature flag helpers
      kill dead inode flags
      remove unused m_inode_quiesce member from struct xfs_mount
      remove leftovers of shared read-only support
      use xfs_trans_ijoin in xfs_trans_iget
      no explicit xfs_iflush for special inodes during unmount
      kill xfs_unmount_flush
      kill vn_ioerror
      move vn_iowait / vn_iowake into xfs_aops.c
      move inode tracing out of xfs_vnode.
      [XFS] Fix compile with CONFIG_COMPAT enabled
      [XFS] replace b_fspriv with b_mount
      [XFS] simplify projid check in xfs_rename
      [XFS] resync headers with libxfs
      [XFS] add a FMODE flag to make XFS invisible I/O less hacky
      [XFS] use inode_change_ok for setattr permission checking
      [XFS] avoid memory allocations in xfs_fs_vcmn_err
      [XFS] handle unaligned data in xfs_bmbt_disk_get_all
      remove incorrect comment in inode_permission
      kill walk_init_root
      pass a struct path * to may_open
      kill vfs_permission
      [SCSI] remove severly outdated comment in scsi_dispatch_cmd
      [SCSI] clean up scsi_times_out
      add a vfs_fsync helper

Chuck Lever (55):
      NFS: rename nfs_path variable
      NFS: Move declaration of nfs_mount() to fs/nfs/internal.h
      NFS: introduce nfs_mount_info struct for calling nfs_mount()
      NFS: expand flags passed to nfs_create_rpc_client()
      NFS: move nfs_server flag initialization
      NFS: add "[no]resvport" mount option
      NFS: "[no]resvport" mount option changes mountd client too
      NLM: allow lockd requests from an unprivileged port
      NLM: Use modern style for pointer fields in nlm_host
      NLM: Remove address eye-catcher buffers from nlm_host
      NLM: Remove AF_UNSPEC arm in nlm_display_address()
      NLM: Support IPv6 scope IDs in nlm_display_address()
      NLM: Add helper to handle IPv4 addresses
      NSM: Use C99 structure initializer to initialize nsm_args
      NSM: convert printk(KERN_DEBUG) to a dprintk()
      NSM: Use modern style for sm_name field in nsm_handle
      NSM: Support IPv6 version of mon_name
      NSM: Use sm_name instead of h_name in nsm_monitor() and nsm_unmonit=
or()
      NLM: Remove redundant printk() in nlmclnt_lock()
      NSM: Remove BUG_ON() in nsm_monitor()
      NSM: Make sure to return an error if the SM_MON call result is not =
zero
      NLM: Move the public declaration of nsm_monitor() to lockd.h
      NSM: Release nsmhandle in nlm_destroy_host
      NLM: Move the public declaration of nsm_unmonitor() to lockd.h
      NSM: Check result of SM_UNMON upcall
      NSM: Move NSM-related XDR data structures to lockd's xdr.h
      NSM: Move NSM program and procedure numbers to fs/lockd/mon.c
      NSM: move to xdr_stream-based XDR encoders and decoders
      NSM: Move nsm_find() to fs/lockd/mon.c
      NSM: Add dprintk() calls in nsm_find and nsm_release
      NSM: Remove NULL pointer check from nsm_find()
      NSM: Remove !nsm check from nsm_release()
      NSM: Generate NSMPROC_MON's "priv" argument when nsm_handle is crea=
ted
      NSM: Encode the new "priv" cookie for NSMPROC_MON requests
      NLM: Change nlm_host_rebooted() to take a single nlm_reboot argumen=
t
      NLM: Decode "priv" argument of NLMPROC_SM_NOTIFY as an opaque
      NSM: Add nsm_lookup() function
      NLM: Call nsm_reboot_lookup() instead of nsm_find()
      NLM: Remove "create" argument from nsm_find()
      NSM: Refactor nsm_handle creation into a helper function
      NSM: More clean up of nsm_get_handle()
      NSM: Replace IP address as our nlm_reboot lookup key
      NSM: Remove include/linux/lockd/sm_inter.h
      NSM: Move nsm_addr() to fs/lockd/mon.c
      NSM: Move nsm_use_hostnames to mon.c
      NSM: Move nsm_create()
      NLM: nlm_privileged_requester() doesn't recognize mapped loopback a=
ddress
      NLM: Rewrite IPv4 privileged requester's check
      lockd: Enable NLM use of AF_INET6
      NFSD: clean up failover sysctl function naming
      NFSD: Fix a handful of coding style issues in write_filehandle()
      NFSD: Replace open-coded integer with macro
      NFSD: Add documenting comments for nfsctl interface
      NLM: Refactor make_socks() function
      NLM: Clean up flow of control in make_socks() function

Claudio Scordino (1):
      Unused variable 'reg' removed.

Clemens Ladisch (1):
      ALSA: oxygen: add Claro halo support

Cliff Cai (5):
      ASoC: AD1980 codec: add multi-channel function support
      ASoC: Blackfin: add multi-channel function support
      ASoC: Blackfin: Fix AD1980/1 build with MMAP support disabled
      Blackfin arch: add sdh support for bf518f-ezbrd
      Blackfin arch: add SDIO host driver platform data

Cliff Wickman (2):
      x86, UV: fix redundant creation of sgi_uv
      x86, UV: remove erroneous BAU initialization

Colin McCabe (1):
      ath9k: Replace ath9k_opmode with nl80211_iftype

Colin Tuckley (2):
      RealView: Use the correct oscillator for the CLCD on PB1176
      RealView: Allow XVGA (1024x768) CLCD resolution on the RealView boa=
rds

Coly Li (1):
      fix similar typos to successfull

Constantin Baranov (1):
      leds: ALIX.2 LEDs driver

Corentin Chary (1):
      eeepc-laptop: use select and not depends on

Cornelia Huck (9):
      [S390] dasd: Use accessors instead of using driver_data directly.
      [S390] cio: Put referernce on correct device after moving.
      [S390] cio: Fix reference counting for online/offline.
      [S390] cio: Fix I/O subchannel refcounting.
      [S390] cio: Only register ccw_device for registered subchannel.
      [S390] cio: Dont fail probe for I/O subchannels.
      [S390] cio: Dont call ->release directly.
      [S390] cio: Use device_is_registered().
      Make DEBUG take precedence over DYNAMIC_PRINTK_DEBUG

Cyrill Gorcunov (20):
      x86: nmi - add sensible names to nmi_watchdog boot param
      x86: nmi - nmi_watchdog boot param docs cleanup
      x86: apic - calibrate_APIC_clock remove redundant irq-enable-disabl=
e
      x86: apic - use pr_ macros for logging
      x86: move dwarf2 related macro to dwarf2.h
      x86: introduce ENTRY(KPROBE_ENTRY)_X86 assembly helpers to catch un=
balanced declaration v3
      SLUB: cleanup - define macros instead of hardcoded numbers
      slub - fix get_object_page comment
      x86: entry_64.S - use ENTRY to define child_rip
      x86: uv bau interrupt -- use proper interrupt number
      x86: entry_64.S - trivial: space, comments fixup
      x86: entry_64 - introduce FTRACE_ frame macro v2
      net: ppp_generic - use idr technique instead of cardmaps
      net: ppp_generic - use DEFINE_IDR for static initialization
      x86: mach-default setup.c cleanups
      x86: early_printk - use sizeof instead of hardcoded number
      V4L/DVB (10144): cx24116: build fix
      x86: setup_per_cpu_areas() cleanup
      mm: hugetlb: remove redundant `if' operation
      fs: fix name overwrite in __register_chrdev_region()

Dai Haruki (9):
      gianfar: Optimize interrupt coalescing configuration
      gianfar: Fix eTSEC configuration procedure
      gianfar: Fix VLAN HW feature related frame/buffer size calculation.
      gianfar: Enable padding and Optimize the frame prepended bytes hand=
ling
      gianfar: Remove unused gfar_add_fcb() function parameter
      gianfar: Make all BD status writes 32-bit
      gianfar: Add Scatter Gather support
      gianfar: Use interface name in interrupt name to distinguish the so=
urce.
      gianfar: Merge Tx and Rx interrupt for scheduling clean up ring

Daisuke Nishimura (6):
      memcg: memory swap controller: fix limit check
      memcg: hierarchy avoid unnecessary reclaim
      memcg: don't trigger oom at page migration
      memcg: remove mem_cgroup_try_charge
      memcg: avoid deadlock caused by race between oom and cpuset_attach
      memcg: change try_to_free_pages to hierarchical_reclaim

Dale Farnsworth (4):
      powerpc: Setup OF properties for ppc32 kexec
      powerpc/32: Setup OF properties for kdump
      powerpc/32: Add the ability for a classic ppc kernel to be loaded a=
t 32M
      powerpc/32: Wire up the trampoline code for kdump

Dan Christian (1):
      Staging: comedi: add rtd520 driver

Dan McGee (1):
      x86: remove dead IRQBALANCE code

Dan Williams (23):
      async_tx, dmaengine: document channel allocation and api rework
      dmaengine: remove dependency on async_tx
      dmaengine: up-level reference counting to the module level
      dmaengine: centralize channel allocation, introduce dma_find_channe=
l
      dmaengine: provide a common 'issue_pending_all' implementation
      net_dma: convert to dma_find_channel
      dmaengine: introduce dma_request_channel and private channels
      dmatest: convert to dma_request_channel
      atmel-mci: convert to dma_request_channel and down-level dma_slave
      dmaengine: replace dma_async_client_register with dmaengine_get
      dmaengine: kill struct dma_client and supporting infrastructure
      dmaengine: remove 'bigref' infrastructure
      dmaengine: kill enum dma_state_client
      iop-adma: let devm do its job, don't duplicate free
      iop-adma: kill debug BUG_ON
      iop-adma: enable module removal
      ioat: do not perform removal actions at shutdown
      dmaengine: add a release for dma class devices and dependent infras=
tructure
      dmaengine: use idr for registering dma device numbers
      dmaengine: advertise all channels on a device to dma_filter_fn
      dmaengine: bump initcall level to arch_initcall
      ioat: fix self test for multi-channel case
      USB: unusual dev for Option N.V. ZeroCD modems

Daniel C. Halperin (1):
      iwlwifi: convert correctly rate_n_flags to PLCP index for mimo3 pac=
kets

Daniel Drake (1):
      USB: unusual_devs.h additions for Pentax K10D

Daniel Halperin (1):
      iwlwifi: Update reclaim flag

Daniel Krueger (1):
      Staging: add epl stack

Daniel Lezcano (3):
      veth: Remove useless veth field
      veth: remove unused list
      netns: filter out uevent not belonging to init_net

Daniel Mack (4):
      ASoC: Allow more routing features for tlv320aic3x
      ALSA: snd-usb-caiaq: clean up the control adding code
      ASoC: tlv320aic3x: headset/button press support
      ASoC: tlv320aic3x: control additions and cleanups

Daniel Silverstone (5):
      net: Add support for the KS8695 ethernet devices.
      [ARM] KS8695: Fix up device registration.
      [ARM] KS8695: Fixup the KS8695 GPIO to be GPIOLIB
      [ARM] DSM320: Add support for the DSM320
      [ARM] DSM320: Update KS8695 defconfig to include DSM320

Darius Augulis (4):
      patch-iomux-mx1-mx2-cleanup
      patch-mx1-add-devices
      patch-mx1-mtd-xip
      USB: add imx udc gadget driver

Darren Hart (4):
      futex: rename field in futex_q to clarify single waiter semantics
      futex: clean up futex_(un)lock_pi fault handling
      futex: make futex_(get|put)_key() calls symmetric
      futex: catch certain assymetric (get|put)_futex_key calls

Darrick J. Wong (6):
      Create a DIV_ROUND_CLOSEST macro to do division with rounding
      adt74{62, 70, 73}: Use DIV_ROUND_CLOSEST for rounded division
      adt7470: fix pwm at a certain level during temperature sensor scan
      adt7470: observe the number of temperature sensors to shorten updat=
e time
      adt7470: make automatic fan control really work
      hwmon: (i5k_amb) Load automatically on all 5000/5400 chipsets

Darron Broad (8):
      V4L/DVB (9500): cx88-dvb: MFE attachment fix-up
      V4L/DVB (9576): cx88-dvb: MFE attachment clean-up for HVR-3000/4000
      V4L/DVB (9577): saa7134-dvb: MFE attachment clean-up for saa-7134 d=
vb
      V4L/DVB (9914): cx24116: bugfix: add missing delsys in FEC lookup
      V4L/DVB (9915): cx24116: fix retune regression introduced in 70ee86=
a7c630
      V4L/DVB (9916): dvb-core: don't add an event when in ONE SHOT mode =
for algo type HW
      V4L/DVB (9917): cx24116: change to ALGO_HW
      V4L/DVB (9918): cx88: advise/acquire clean-up for HVR-1300/3000/400=
0

Dave Airlie (15):
      drm: cleanup exit path for module unload
      drm: move to kref per-master structures.
      drm: reorganise start and load.
      DRM: add mode setting support
      drm: pick an 800x600@60HZ mode by default for unknown CRT.
      drm: PAGE_CACHE_WC is x86 only so far
      drm: kconfig have drm core select i2c for kms
      drm/radeon: fix warning due to PAGE_SIZE max
      drm: fix useless gcc unused variable warning
      drm/radeon: fix missing hunk from the master changes.
      drm/radeon: use locked rmmap to remove sarea mapping.
      drm: fix allowing master ioctls on non-master fds.
      i915/drm: provide compat defines for userspace for certain struct m=
embers.
      drm/i915: fix modeset devname allocation + agp init return check.
      drm: fix ordering of driver unload vs agp unload.

Dave Chinner (8):
      [XFS] handle memory allocation failures during log initialisation
      [XFS] fix uninitialised variable bug in dquot release
      [XFS] Avoid using inodes that haven't been completely initialised
      [XFS] Fix double free of log tickets
      [XFS] fix error inversion problems with data flushing
      [XFS] fix uninitialised variable bug in dquot release.
      [XFS] remove i_gen from incore inode
      [XFS] Fix hang after disallowed rename across directory quota domai=
ns

Dave Hansen (4):
      powerpc/mm: Add better comment on careful_allocation()
      powerpc/mm:: Cleanup careful_allocation(): bootmem already panics
      powerpc/mm: Make careful_allocation() return virtual addrs
      powerpc/mm: Cleanup careful_allocation(): consolidate memset()

Dave Jones (2):
      x86: remove init_mm export as planned for 2.6.26
      net: Allow dependancies of FDDI & Tokenring to be modular.

Dave Kleikamp (3):
      jfs: ensure symlinks are NUL-terminated
      nfsd race fixes: jfs
      async: Don't call async_synchronize_full_special() while holding sb=
_lock

Dave Liu (1):
      powerpc: Remove the redundant _tlbil_pid at SMP case

Dave Olson (4):
      IB/ipath: Don't count IB symbol and link errors unless link is UP
      IB/ipath: Only do 1X workaround on rev1 chips
      IB/ipath: Fix spi_pioindex value
      IB/ipath: Add locking for interrupt use of ipath_pd contexts vs fre=
e

Dave Peverley (1):
      sh: oprofile: Backtrace support.

David Anders (1):
      ASoC: Add new parameter to s3c24xx_pcm_enqueue

David Brownell (42):
      rtc-cmos: export second NVRAM bank
      pegasus: minor resource shrinkage
      genirq: record IRQ_LEVEL in irq_desc[]
      genirq: warn when IRQF_DISABLED may be ignored
      ARM: OMAP: gpios implement new to_irq()
      ARM: OMAP: switch to standard gpio get/set calls
      ARM: OMAP: switch to gpio_direction_input
      ARM: OMAP: switch to gpio_direction_output
      ARM: OMAP: use gpio_to_irq
      ARM: OMAP: minor gpio bugfixes
      ARM: OMAP1: osk5912: Mistral eeprom support
      ARM: OMAP1: osk5912: LED trigger update for CF
      ARM: OMAP2: bard-h4: list those eeproms
      mmc: warn about voltage mismatches
      HID: switch specialized drivers from "default y" to !EMBEDDED
      mfd: allow reading entire register banks on twl4030
      mfd: twl4030: simplified child creation code
      mfd: twl4030: cleanup symbols and OMAP dependency
      mfd: twl4030: create some regulator devices
      mfd: twl4030 regulator bug fixes
      mfd: dm355evm msp430 driver
      mfd: move drivers/i2c/chips/tps65010.c to drivers/mfd
      mfd: move drivers/i2c/chips/menelaus.c to drivers/mfd
      ASoC: fix davinci-sffsdr buglet
      ASoC: Clocking fixes for davinci-evm.c
      documentation: when to BUG(), and when to not BUG()
      spi_gpio driver
      twl4030-gpio: cleanup debounce
      gpio: pca953x handles more chips, i2c fault codes
      USB: musb: sysfs mode updates
      USB: musb: minor locking fix
      USB: musb: host side diagnostics tweaks
      USB: gadget: pxa25x_udc vbus sense initialization
      USB: move isp1301_omap to drivers/usb/otg
      USB: otg: twl4030 transceiver driver
      regulator: enable/disable refcounting
      regulator: improved mode error checks
      regulator: code shrink (v2)
      regulator: sysfs attribute reduction (v2)
      regulator: init/link earlier
      regulator: catch some registration errors
      CORE_DUMP_DEFAULT_ELF_HEADERS depends on ELF_CORE

David Chinner (44):
      [XFS] Make use of the init-once slab optimisation.
      [XFS] add new btree statistics
      [XFS] move sync code to its own file
      [XFS] move xfssyncd code to xfs_sync.c
      [XFS] Remove xfs_iflush_all and clean up xfs_finish_reclaim_all()
      [XFS] don't block in xfs_qm_dqflush() during async writeback.
      [XFS] Use the inode tree for finding dirty inodes
      [XFS] Traverse inode trees when releasing dquots
      [XFS] remove the mount inode list
      [XFS] Use struct inodes instead of vnodes to kill vn_grab
      [XFS] use xfs_sync_inodes rather than xfs_syncsub
      [XFS] kill xfs_syncsub
      [XFS] xfssyncd: don't call xfs_sync
      [XFS] make SYNC_ATTR no longer use xfs_sync
      [XFS] make SYNC_DELWRI no longer use xfs_sync
      [XFS] Kill SYNC_CLOSE
      [XFS] Kill xfs_sync()
      [XFS] Move remaining quiesce code.
      [XFS] factor xfs_iget_core() into hit and miss cases
      [XFS] Never call mark_inode_dirty_sync() directly
      Inode: Allow external initialisers
      Inode: Allow external list initialisation
      [XFS] Combine the XFS and Linux inodes
      [XFS] Prevent use-after-free caused by synchronous inode reclaim
      [XFS] move inode reclaim functions to xfs_sync.c
      [XFS] rename inode reclaim functions
      [XFS] mark inodes for reclaim via a tag in the inode radix tree
      [XFS] use the inode radix tree for reclaiming inodes
      [XFS] kill deleted inodes list
      [XFS] Prevent looping in xfs_sync_inodes_ag
      [XFS] Account for allocated blocks when expanding directories
      [XFS] Allocate the struct xfs_ail
      [XFS] Use a cursor for AIL traversal.
      [XFS] move the AIl traversal over to a consistent interface
      [XFS] Allow 64 bit machines to avoid the AIL lock during flushes
      [XFS] Move the AIL lock into the struct xfs_ail
      [XFS] Given the log a pointer to the AIL
      [XFS] Add ail pointer into log items
      [XFS] Finish removing the mount pointer from the AIL API
      [XFS] XFS: Check for valid transaction headers in recovery
      [XFS] Can't lock inodes in radix tree preload region
      [XFS] avoid all reclaimable inodes in xfs_sync_inodes_ag
      [XFS] correctly select first log item to push
      [XFS] Fix race when looking up reclaimable inodes

David Daney (5):
      8250: Don't clobber spinlocks.
      8250: Serial driver changes to support future Cavium OCTEON serial =
patches.
      Serial: Allow port type to be specified when calling serial8250_reg=
ister_port.
      Serial: UART driver changes for Cavium OCTEON.
      libata: Add special ata_pio_need_iordy() handling for Compact Flash.

David Disseldorp (1):
      IB/iser: Avoid recv buffer exhaustion caused by unexpected PDUs

David Gibson (1):
      powerpc: udbg-based backend for hvc_console

David Howells (95):
      CRED: Wrap task credential accesses in the XFS filesystem
      CRED: Wrap task credential accesses in the IA64 arch
      CRED: Wrap task credential accesses in the MIPS arch
      CRED: Wrap task credential accesses in the PA-RISC arch
      CRED: Wrap task credential accesses in the PowerPC arch
      CRED: Wrap task credential accesses in the S390 arch
      CRED: Wrap task credential accesses in the x86 arch
      CRED: Wrap task credential accesses in the block loopback driver
      CRED: Wrap task credential accesses in the tty driver
      CRED: Wrap task credential accesses in the ISDN drivers
      CRED: Wrap task credential accesses in the network device drivers
      CRED: Wrap task credential accesses in the USB driver
      CRED: Wrap task credential accesses in 9P2000 filesystem
      CRED: Wrap task credential accesses in the AFFS filesystem
      CRED: Wrap task credential accesses in the autofs filesystem
      CRED: Wrap task credential accesses in the autofs4 filesystem
      CRED: Wrap task credential accesses in the BFS filesystem
      CRED: Wrap task credential accesses in the CIFS filesystem
      CRED: Wrap task credential accesses in the Coda filesystem
      CRED: Wrap task credential accesses in the devpts filesystem
      CRED: Wrap task credential accesses in the eCryptFS filesystem
      CRED: Wrap task credential accesses in the Ext2 filesystem
      CRED: Wrap task credential accesses in the Ext3 filesystem
      CRED: Wrap task credential accesses in the Ext4 filesystem
      CRED: Wrap task credential accesses in the FAT filesystem
      CRED: Wrap task credential accesses in the FUSE filesystem
      CRED: Wrap task credential accesses in the GFS2 filesystem
      CRED: Wrap task credential accesses in the HFS filesystem
      CRED: Wrap task credential accesses in the HFSplus filesystem
      CRED: Wrap task credential accesses in the HPFS filesystem
      CRED: Wrap task credential accesses in the hugetlbfs filesystem
      CRED: Wrap task credential accesses in the JFS filesystem
      CRED: Wrap task credential accesses in the Minix filesystem
      CRED: Wrap task credential accesses in the NCPFS filesystem
      CRED: Wrap task credential accesses in the NFS daemon
      CRED: Wrap task credential accesses in the OCFS2 filesystem
      CRED: Wrap task credential accesses in the OMFS filesystem
      CRED: Wrap task credential accesses in the RAMFS filesystem
      CRED: Wrap task credential accesses in the ReiserFS filesystem
      CRED: Wrap task credential accesses in the SMBFS filesystem
      CRED: Wrap task credential accesses in the SYSV filesystem
      CRED: Wrap task credential accesses in the UBIFS filesystem
      CRED: Wrap task credential accesses in the UDF filesystem
      CRED: Wrap task credential accesses in the UFS filesystem
      CRED: Wrap task credential accesses in the XFS filesystem
      CRED: Wrap task credential accesses in the filesystem subsystem
      CRED: Wrap task credential accesses in the SYSV IPC subsystem
      CRED: Wrap task credential accesses in the AX25 protocol
      CRED: Wrap task credential accesses in the IPv6 protocol
      CRED: Wrap task credential accesses in the netrom protocol
      CRED: Wrap task credential accesses in the ROSE protocol
      CRED: Wrap task credential accesses in the SunRPC protocol
      CRED: Wrap task credential accesses in the UNIX socket protocol
      CRED: Wrap task credential accesses in the networking subsystem
      CRED: Wrap task credential accesses in the key management code
      CRED: Wrap task credential accesses in the capabilities code
      CRED: Wrap task credential accesses in the core kernel
      KEYS: Disperse linux/key_ui.h
      KEYS: Alter use of key instantiation link-to-keyring argument
      CRED: Neuter sys_capset()
      CRED: Constify the kernel_cap_t arguments to the capset LSM hooks
      CRED: Separate task security context from task_struct
      CRED: Detach the credentials from task_struct
      CRED: Wrap current->cred and a few other accessors
      CRED: Use RCU to access another task's creds and to release a task'=
s own creds
      CRED: Wrap access to SELinux's task SID
      CRED: Separate per-task-group keyrings from signal_struct
      CRED: Rename is_single_threaded() to is_wq_single_threaded()
      CRED: Make inode_has_perm() and file_has_perm() take a cred pointer
      CRED: Pass credentials through dentry_open()
      CRED: Inaugurate COW credentials
      CRED: Make execve() take advantage of copy-on-write credentials
      CRED: Prettify commoncap.c
      CRED: Use creds in file structs
      CRED: Documentation
      CRED: Differentiate objective and effective subjective credentials =
on a task
      CRED: Add a kernel_service object class to SELinux
      CRED: Allow kernel services to override LSM settings for task actio=
ns
      powerpc: Rename struct vm_region to avoid conflict with NOMMU
      KEYS: Fix variable uninitialisation warnings
      CRED: Wrap task credential accesses in the devpts filesystem
      CRED: Fix regression in cap_capable() as shown up by sys_faccessat(=
) [ver #2]
      CRED: Fix regression in cap_capable() as shown up by sys_faccessat(=
) [ver #3]
      CRED: Fix NFSD regression
      NOMMU: Fix cleanup handling in ramfs_nommu_get_umapped_area()
      NOMMU: Rename ARM's struct vm_region
      NOMMU: Delete askedalloc and realalloc variables
      NOMMU: Make VMAs per MM as for MMU-mode linux
      NOMMU: Improve procfs output using per-MM VMAs
      FDPIC: Don't attempt to expand the userspace stack to fill the spac=
e allocated
      FLAT: Don't attempt to expand the userspace stack to fill the space=
 allocated
      NOMMU: Support XIP on initramfs
      CRED: Fix commit_creds() on a process that has no mm
      CRED: Missing put_cred() in prepare_kernel_cred()
      CRED: Must initialise the new creds in prepare_kernel_cred()

David John (1):
      RTC: Remove the BKL.

David Kiliani (1):
      Staging: Add the Meilhaus ME-IDS driver package

David Kilroy (8):
      orinoco: Move sources to a subdirectory
      orinoco: Separate fw caching from download
      orinoco: Cache Symbol firmware
      orinoco: Resume spectrum_cs in the same way as orinoco_cs
      orinoco: Provide option to avoid unnecessary fw caching
      orinoco: Fix function names used in debug strings
      orinoco: Fix inappropriate use of IRQ_BAP
      spectrum_cs: Fix function names used in debug strings

David Lopo (1):
      USB: gadget: MIPS ci13xxx_udc

David Miller (2):
      Btrfs: unaligned access fixes
      topology: Fix sparc64 build.

David Rientjes (6):
      slub: make early_kmem_cache_node_alloc void
      slub: avoid leaking caches or refcounts on sysfs error
      oom: fix zone_scan_mutex name
      oom: print triggering task's cpuset and mems allowed
      mm: change dirty limit type specifiers to unsigned long
      mm: add dirty_background_bytes and dirty_bytes sysctls

David S. Miller (98):
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      Merge branch 'davem-next' of master.kernel.org:/pub/scm/linux/kerne=
l/git/jgarzik/netdev-2.6
      sunrpc: Fix build warning due to typo in %pI4 format changes.
      drivers/net: Kill now superfluous ->last_rx stores.
      net/: Kill now superfluous ->last_rx stores.
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      Merge branch 'davem-next' of master.kernel.org:/pub/scm/linux/kerne=
l/git/jgarzik/netdev-2.6
      Revert "net: Guaranetee the proper ordering of the loopback device.=
"
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-next-2.6
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-next-2.6
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      dm9000: Fix build error.
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      inet_diag: Missed conversion after changing inet ehash lockl to spi=
nlocks.
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-next-2.6
      Merge branch 'for-david' of git://git.kernel.org/pub/scm/linux/kern=
el/git/chris/linux-2.6
      net: Make sure BHs are disabled in sock_prot_inuse_add()
      axnet_cs: Fix build after net device ops ne2k conversion.
      Revert "hso: Add TIOCM ioctl handling."
      Revert "hso: Fix free of mutexes still in use."
      Revert "hso: Fix crashes on close."
      smc-mca: Fix build failure due to typo.
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-next-2.6
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/kaber/nf-next-2.6
      phy: Add file missed in previous commit.
      Merge branch 'master' of ssh://master.kernel.org/pub/scm/linux/kern=
el/git/rusty/linux-2.6-for-linus
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/holtmann/bluetooth-next-2.6
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/sparc-2.6
      sparc64: Rework auxio driver to save some text space.
      of: Fix comment, sparc no longer uses of_device objects on special =
busses.
      sparc64: Run the kernel always in the TSO memory model.
      sparc64: Stop using memory barriers for atomics and locks.
      sparc64: Add tsb-ratio sysctl.
      sparc64: Add interface for registering a performance counter IRQ ha=
ndler.
      sparc: Include drivers/pcmcia/Kconfig
      sparc64: Make %pil level 15 a pseudo-NMI.
      sparc64: Make special trap return path for TRAP_NMI().
      sparc64: Block NMIs in critical section of context switch.
      sparc64: Add write_pic() helper.
      sparc64: Use NMI oprofile profiling on cheetah and derivative cpus.
      sparc32: Don't btfixup cache flush ops for viking multiple times.
      sparc64: Add save_stack_trace_tsk().
      sparc64: Add performance counter hypervisor calls for sun4v.
      sparc64: Provide oprofile pseudo-NMI on Niagara.
      sparc: Create common header file for prom_{32,64}.c
      sparc: Const'ify prom_*prop*() on sparc32.
      sparc: Create common area for OF device layer code.
      sparc: Mark prom_early_alloc non-static.
      sparc: Move irq_trans_init() and support code into seperate file.
      sparc: Move 'unique_id' into prom_common.c and rename to 'prom_uniq=
ue_id'
      sparc: Move property building code into prom_common.c
      sparc: Commonize get_one_property() implementations.
      sparc: Make sparc32's create_node() assign parent pointer.
      sparc: Move create_node() and friends into prom_common.c
      sparc: Match sparc32's build_tree() up to sparc64's
      sparc: Move core of OF device tree building code into prom_common.c
      sparc: Move prom_build_devicetree() into prom_common.c
      sparc: Move of_console_{device,path,options} info prom_common.c
      sparc: Always set AUDIT_ARCH, not just on sparc64.
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-next-2.6
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      sparc: Restore irq_trans_init() call in prom_create_node().
      cyber2000fb: Kill the one modular sparc prom_printf call.
      sparc: Kill memcmp_32.S code which has been ifdef'd out for centuri=
es.
      bluetooth: Fix rfcomm_sock_ioctl() build failure with debugging ena=
bled.
      sparc: Add asm/asm.h
      bluetooth: Fix unused var warning properly in rfcomm_sock_ioctl().
      sparc: Unify strlen assembler.
      sparc: Commonize memcmp assembler.
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-next-2.6
      8390/8390p: Fix compat netdev ops handling.
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      bnx2: Don't redefine FLOW_CTRL_{RX,TX}.
      bnx2x: Fix namespace collision with FLOW_CTRL_{TX,RX}
      Revert "net: release skb->dst in sock_queue_rcv_skb()"
      Revert "xfrm: Accept ESP packets regardless of UDP encapsulation mo=
de"
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-next-2.6
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      Merge branch 'for-david' of git://git.kernel.org/pub/scm/linux/kern=
el/git/chris/linux-2.6
      net: Fix warning fallout from recent NAPI interface changes.
      igb: Fix build warning when DCA is disabled.
      net: Fix unused variable warnings in pasemi_mac.c and spider_net.c
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/torvalds/linux-2.6
      sparc: Kill bogus comment about IRQF_SHARED in pci_psycho.c
      sparc: Update 64-bit defconfig.
      ipv6: Fix sporadic sendmsg -EINVAL when sending to multicast groups.
      sparc: Kill asm/reg*.h
      sparc: Remove reg*.h from Kbuild
      tcp: Kill extraneous SPLICE_F_NONBLOCK checks.
      Revert "net: Fix for initial link state in 2.6.28"
      acenic: Missed delete of acenic_firmware.h
      sparc64: Work around branch tracer warning.
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/torvalds/linux-2.6

David Schleef (8):
      Staging: add comedi core
      Staging: comedi: add kcomedilib to the tree
      Staging: comedi: add local copy of interrupt.h
      Staging: comedi: add pci and usb wrapper header files
      Staging: comedi: comedi driver common function module
      Staging: comedi: add mite comedi pci driver
      Staging: comedi: add comedi_bond driver
      Staging: comedi: add comedi_parport driver

David Smith (1):
      tpm: clean up tpm_nsc driver for platform_device suspend/resume com=
pliance

David Taht (1):
      Staging: add frontier tranzport and alphatrack drivers

David Teigland (5):
      dlm: remove extra blocking callback check
      dlm: improve how bast mode handling
      dlm: change lock time stamping
      dlm: add time stamp of blocking callback
      dlm: add new debugfs entry

David Vrabel (27):
      uwb: target reservations shouldn't get streams
      wusb: release mutex in the error path of whci-hcd's whc_do_gencmd()
      uwb: reference count reservations
      wusb: disable verification of the key generation algorithms
      wusb: do a proper channel stop
      uwb: order IEs by element ID
      wusb: reset WUSB devices with SetAddress(0)
      uwb: don't unbind the radio controller driver when resetting
      uwb: fix races between events and neh timers
      uwb: add pal parameter to new reservation callback
      uwb: add basic radio manager
      wlp: start/stop radio on network interface up/down
      uwb: remove unused beacon group join/leave events
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6 into for-upstream
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6 into for-upstream
      wusb: whci-hcd shouldn't do ASL/PZL updates while channel is inacti=
ve
      uwb: clean up whci_wait_for() timeout error message
      uwb: fix oops in debug PAL's reservation callback
      wusb: add debug files for ASL, PZL and DI to the whci-hcd driver
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6 into for-upstream
      uwb: fix oops when terminating an already terminated reservation
      wusb: fix oops when terminating a non-existant reservation
      uwb: fix memory leak in uwb_rc_notif()
      uwb: use dev_dbg() for debug messages
      uwb: use print_hex_dump()
      uwb: remove unused include/linux/uwb/debug.h
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6 into for-upstream

David Woodhouse (27):
      Btrfs: Use assert_spin_locked instead of spin_trylock
      Btrfs: Change TestSetPageLocked() to trylock_page()
      Btrfs: Remove broken optimisations in end_bio functions.
      Btrfs: Implement our own copy of the nfsd readdir hack, for older k=
ernels
      Btrfs: Discard sector data in __free_extent()
      Btrfs: Remove special cases for "." and ".."
      Minor cleanup of btrfs_real_readdir()
      Btrfs: Optimise NFS readdir hack slightly; don't call readdir() aga=
in when done
      Fill f_fsid field in btrfs_statfs()
      Mask root object ID into f_fsid in btrfs_statfs()
      Simplify btrfs_get_parent(), fix use-after-free bug
      Btrfs: Reinstate '-osubvol=3D.' option to mount entire tree
      Switch btrfs_name_hash() to crc32c
      Btrfs: Fix NFS exporting of subvol roots.
      Clean up btrfs_get_parent() a little more, fix a free-after-free bu=
g
      atm: 32-bit ioctl compatibility
      [MTD] [NAND] Remove strange u_int64_t types from nandsim
      [MTD] Remove strange u_int32_t types from FTL
      [MTD] Remove more strange u_intxx_t types
      [JFFS2] Clean up fs/jffs2/compr_rubin.c
      Merge branch 'misc/mtd/sharpsl-nand' of git://git.kernel.org/pub/sc=
m/linux/kernel/git/lumag/tosa-2.6
      atm: Driver for Solos PCI ADSL2+ card.
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6
      Merge branch 'master' of git://git.infradead.org/users/dedekind/mtd=
-tests-2.6
      [MTD] [TESTS] Fix some size_t printk format warnings
      Btrfs: Add Documentation/filesystem/btrfs.txt, remove old COPYING
      [MTD] [MAPS] Fix printk format warning in nettel.c

Dean Hildebrand (1):
      nfsd: add etoosmall to nfserrno

Dean Nelson (4):
      sgi-xp: define xp_expand_memprotect() and xp_restrict_memprotect()
      sgi-xp: create activate and notify gru message queues
      sgi-xp: define xp_partition_id and xp_region_size
      sgi-xp: support getting the address of a partition's reserved page

Denis ChengRq (1):
      fs/block_dev.c: __read_mostly improvement and sb_is_blkdev_sb utili=
zation

Denis Joseph Barrow (9):
      hso: Add new usb device id's.
      hso: Fix crashes on close.
      hso: Fix URB submission -EINVAL.
      hso: Fix free of mutexes still in use.
      hso: Add TIOCM ioctl handling.
      hso: Hook up ->reset_resume
      tty: Modem functions for the HSO driver
      hso modem detect fix patch against Alan Cox'es tty tree
      hso maintainers update patch

Denis V. Lunev (3):
      x86: correct link to HPET timer specification
      ipc: do not goto to the next line
      backlight: Value of ILI9320_RGB_IF2 register should not be hardcode=
d

Detlef Riekenberg (1):
      linux/types.h: Don't depend on __GNUC__ for __le64/__be64

Devin Heitmueller (30):
      V4L/DVB (9580): Add chip id for em2874 to list of known chips
      V4L/DVB (9581): Remove unused variable from em28xx-audio.c
      V4L/DVB (9582): Add a EM28XX_NODECODER option to the list of availa=
ble decoders
      V4L/DVB (9583): Remember chip id of devices at initialization
      V4L/DVB (9584): Support different GPIO/GPO registers for newer devi=
ces
      V4L/DVB (9585): Skip reading eeprom in newer Empia devices
      V4L/DVB (9586): Fix possible null pointer dereference in info messa=
ge
      V4L/DVB (9587): Handle changes to endpoint layout in em2874
      V4L/DVB (9588): Don't load em28xx audio module for digital-only dev=
ices
      V4L/DVB (9589): Properly support capture start on em2874
      V4L/DVB (9590): Add registration for Pinnacle 80e ATSC tuner
      V4L/DVB (9628): em28xx: refactor IR support
      V4L/DVB (9629): Add support for the ATI TV Wonder HD 600 USB Remote=
 Control
      V4L/DVB (9633): Put s5h1411 into low power mode at end of attach() =
call
      V4L/DVB (9644): em28xx: add em2750 to the list of known em28xx chip=
 ids
      V4L/DVB (9648): em28xx: get audio config from em28xx register
      V4L/DVB (9657): em28xx: add a functio to write on a single register
      V4L/DVB (9658): em28xx: use em28xx_write_reg() for i2c clock setup
      V4L/DVB (9744): em28xx: cleanup XCLK register usage
      V4L/DVB (9745): em28xx: Cleanup GPIO/GPO setup code
      V4L/DVB (9921): em28xx: add chip id for em2874
      V4L/DVB (9922): em28xx: don't assume every eb1a:2820 reference desi=
gn is a Prolink PlayTV USB2
      V4L/DVB (9923): xc5000: remove init_fw option
      V4L/DVB (10119): em28xx: fix corrupted XCLK value
      V4L/DVB (10120): em28xx: remove redundant Pinnacle Dazzle DVC 100 p=
rofile
      V4L/DVB (10121): em28xx: remove worthless Pinnacle PCTV HD Mini 80e=
 device profile
      V4L/DVB (10122): em28xx: don't load em28xx-alsa for em2870 based de=
vices
      V4L/DVB (10123): em28xx: fix reversed definitions of I2S audio mode=
s
      V4L/DVB (10124): em28xx: expand output formats available
      V4L/DVB (10125): em28xx: Don't do AC97 vendor detection for i2s aud=
io devices

Dhaval Giani (1):
      sched/rt: removed unneeded defintion

Dimitri Sivanich (1):
      sched/rt: small optimization to update_curr_rt()

Dirk Heer (1):
      V4L/DVB (9677): bttv: fix some entries on Phytec boards and add mis=
sing ones

Divy Le Ray (8):
      cxgb3 - enable lro control through ethtool
      cxgb3: set hard_xmit in the netdev_ops
      cxgb3: avoid potential memory leak.
      cxgb3: integrate FW and protocol engines in the kernel
      cxgb3: Update FW loading path.
      cxgb3: Add multiple Tx queue support.
      cxgb3: untie strict FW matching
      cxgb3: add control to access embedded images

Dmitri Belimov (3):
      V4L/DVB (10151): Fix I2C bridge error in zl10353
      V4L/DVB (10152): Change configuration of the Beholder H6 card
      V4L/DVB (10153): Add the Beholder H6 card to DVB-T part of sources.

Dmitri Monakhov (2):
      kill suid bit only for regular files
      fs: truncate blocks outside i_size after O_DIRECT write error

Dmitri Vorobiev (21):
      [MTD] Make init_sharpsl symbol static
      [MTD] Make init_sbc8240_mtd function static
      [MTD] Make lart_flash_init, lart_flash_exit static
      [MTD] Make uclinux_mtd_cleanup and uclinux_mtd_init static
      [MTD] Make init_tqm_mtd function static
      [MTD] Make init_rpxlite function static
      [MTD] Make init_sbc82xx_flash function static
      [MTD] Make the init_edb7312nor function static
      [MTD] Make init_oct5066 function static
      [MTD] Make init_flagadm function static
      [MTD] Make init_dbox2_flash static
      [MTD] Make ipaq_mtd_init function static
      [MTD] Make alchemy_mtd_init function static
      [MTD] Make init_fortunet function static
      [MTD] Make the function init_vmax301 static
      [MTD] Make init_mbx function static
      [MTD] Make h720x_mtd_init function static
      [MTD] Make init_msp_flash function static
      [MTD] Make init_redwood_flash function static
      [MTD] Make init_impa7 static
      [SCSI] sgiwd93: Fix compilation warning

Dmitry Baryshkov (15):
      [MTD] sharpsl_nand: switch to driver model usage.
      [MTD] sharpsl_nand: make drvdata non-static
      [MTD] sharpsl_nand: move io addr to struct sharpsl_nand
      [MTD] sharpsl-nand: cleanup partitions support
      [MTD] sharpsl-nand: use platform_data for model-specific values
      [MTD] sharpsl-nand: move registration to board code
      ASoC: tosa: move gpio probing to machine callbacks
      [ARM] pxa/tosa: support tc6393xb/tmiofb.
      [ARM] pxa/tosa: fix building w/o TC6393XB driver
      [ARM] pxa/tosa: add physmap mapping for ROM
      [ARM] pxa/spitz: add physmap mapping for ROM
      [ARM] pxa/corgi: add physmap mapping for ROM
      [ARM] pxa/poodle: add physmap mapping for ROM
      pxa2xx-ac97: switch AC unit to correct state before probing
      backlight: Support VGA/QVGA mode switching in tosa_lcd

Dmitry Eremin-Solenikov (1):
      Dmitry has been renamed

Dmitry Torokhov (3):
      Input: libps2 - handle 0xfc responses from devices
      Merge commit 'v2.6.28-rc9' into next
      Merge branch 'next' into for-linus

Dominic Curran (1):
      Input: gpio-keys - add flag to allow auto repeat

Dominik Brodowski (1):
      [CPUFREQ] p4-clockmod: reduce noise

Don Skidmore (4):
      net: fix dcbnl_setnumtcs operation check
      net: fix DCB setstate to return success/failure
      net: add DCNA attribute to the BCN interface for DCB
      ixgbe: fix the display of DCB control stats in ethtool

Donald Skidmore (1):
      ixgbe: add SFP+ driver support

Douglas Schilling Landgraf (3):
      V4L/DVB (9793): em28xx: Add specific entry for WinTV-HVR 850
      V4L/DVB (10055): em28xx: Add entry for PixelView PlayTV Box 4
      V4L/DVB (10056): em28xx: Add snapshot button on Pixelview Prolink P=
layTV USB 2.0

Duane Griffin (13):
      eCryptfs: check readlink result was not an error before using it
      vfs: introduce helper function to safely NUL-terminate symlinks
      vfs: ensure page symlinks are NUL-terminated
      ext2: ensure fast symlinks are NUL-terminated
      ext3: ensure fast symlinks are NUL-terminated
      ext4: ensure fast symlinks are NUL-terminated
      sysv: ensure fast symlinks are NUL-terminated
      freevxfs: ensure fast symlinks are NUL-terminated
      befs: ensure fast symlinks are NUL-terminated
      ext2: don't inherit inappropriate inode flags from parent
      ext2: tighten restrictions on inode flags
      ext3: don't inherit inappropriate inode flags from parent
      ext3: tighten restrictions on inode flags

Ed Swierk (1):
      forcedeth: power down phy when interface is down

Eduard - Gabriel Munteanu (1):
      SLUB: Replace __builtin_return_address(0) with _RET_IP_.

Eduardo Habkost (21):
      x86 kdump: extract kdump-specific code from crash_nmi_callback()
      x86 kdump: move crashing_cpu assignment to nmi_shootdown_cpus()
      x86 kdump: create kdump_nmi_shootdown_cpus()
      x86 kdump: make kdump_nmi_callback() a function ptr on crash_nmi_ca=
llback()
      x86 kdump: make nmi_shootdown_cpus() non-static
      x86: move nmi_shootdown_cpus() to reboot.c
      x86: make nmi_shootdown_cpus() available on !SMP and !X86_LOCAL_API=
C
      x86: disable IRQs before doing anything on nmi_shootdown_cpus()
      KVM: VMX: move vmx.h to include/asm
      KVM: SVM: move svm.h to include/asm
      KVM: VMX: move ASM_VMX_* definitions from asm/kvm_host.h to asm/vmx=
.h
      KVM: VMX: move cpu_has_kvm_support() to an inline on asm/virtext.h
      x86: asm/virtext.h: add cpu_vmxoff() inline function
      KVM: VMX: extract kvm_cpu_vmxoff() from hardware_disable()
      x86: cpu_emergency_vmxoff() function
      KVM: SVM: move has_svm() code to asm/virtext.h
      KVM: SVM: move svm_hardware_disable() code to asm/virtext.h
      x86: cpu_emergency_svm_disable() function
      kdump: forcibly disable VMX and SVM on machine_crash_shutdown()
      x86: disable VMX on all CPUs on reboot
      x86: KVM guest: kvm_get_tsc_khz: return khz, not lpj

Eilon Greenstein (1):
      bnx2x: Prevent eeprom set when driver is down

Emmanuel Grumbach (2):
      iwlwifi: rename generic iwlagn functions that had a HW specific nam=
e
      iwlwifi: rename double inclusion protection name in iwl-commands.h

Eric Anholt (15):
      agp/intel: Fix broken =C2=AE symbol in device name.
      drm/i915: Add /proc debugging entry for reading out the HWS.
      drm/i915: Register module dependencies for the modesetting code.
      drm/i915: Fix stolen memory detection on G45 and GM45.
      drm/i915: Add missing userland definitions for gem init/execbuffer.
      drm/i915: Fix fbcon setup to align display pitch to 64b.
      drm/i915: Don't double-unpin buffers if we take a signal in evict_e=
verything().
      drm/i915: Delete unused, pointless i915_driver_firstopen.
      drm/i915: Don't print to dmesg when taking signal during object_pin.
      drm: Avoid use-before-null-test on dev in drm_cleanup().
      drm: Add a debug node for vblank state.
      drm/i915: Don't allow objects to get bound while VT switched.
      drm/i915: Add support for integrated HDMI on G4X hardware.
      drm/i915: Non-mobile parts don't have integrated TV-out.
      drm/i915: Respect the other stolen memory sizes we know of.

Eric Dumazet (46):
      udp: introduce struct udp_table and multiple spinlocks
      udp: RCU handling for Unicast packets.
      udp: calculate udp_mem based on low memory instead of all memory
      udp: udp_get_next() should use spin_unlock_bh()
      udp: introduce sk_for_each_rcu_safenext()
      udp: Should use spin_lock_bh()/spin_unlock_bh() in udp_lib_unhash()
      udp: add a missing smp_wmb() in udp_lib_get_port()
      net: sk_free_datagram() should use sk_mem_reclaim_partial()
      net: Introduce read_pnet() and write_pnet() helpers
      net: ib_net pointer should depends on CONFIG_NET_NS
      net: Cleanup of neighbour code
      net: speedup dst_release()
      rcu: Introduce hlist_nulls variant of hlist
      udp: Use hlist_nulls in UDP RCU code
      net: Convert TCP & DCCP hash tables to use RCU / hlist_nulls
      rcu: documents rculist_nulls
      net: make sure struct dst_entry refcount is aligned on 64 bytes
      net: Cleanup of af_unix
      net: af_unix can make unix_nr_socks visbile in /proc
      net: af_unix should update its inuse counter
      net: sctp should update its inuse counter
      net: af_packet should update its inuse counter
      net: make /proc/net/protocols namespace aware
      net: inet_diag_handler structs can be const
      net: af_unix should use KERN_INFO instead of KERN_DEBUG
      net: listening_hash get a spinlock per bucket
      net: convert TCP/DCCP ehash rwlocks to spinlocks
      net: use net_eq() in INET_MATCH and INET_TW_MATCH
      net: some optimizations in af_inet
      net: af_netlink should update its inuse counter
      net: Convert TCP/DCCP listening hash tables to use RCU
      eth: Declare an optimized compare_ether_addr_64bits() function
      net: Make sure BHs are disabled in sock_prot_inuse_add()
      net: Make sure BHs are disabled in sock_prot_inuse_add()
      net: avoid a pair of dst_hold()/dst_release() in ip_append_data()
      net: avoid a pair of dst_hold()/dst_release() in ip_push_pending_fr=
ames()
      net: Make sure BHs are disabled in sock_prot_inuse_add()
      net: udp_unhash() can test if sk is hashed
      net: Use a percpu_counter for sockets_allocated
      net: Use a percpu_counter for orphan_count
      net: release skb->dst in sock_queue_rcv_skb()
      net: percpu_counter_inc() should not be called in BH-disabled secti=
on
      vlan: fix convertion to net_device_ops
      fix f_count description in Documentation/filesystems/files.txt
      filp_cachep can be static in fs/file_table.c
      percpu_counter: FBC_BATCH should be a variable

Eric Leblond (4):
      netfilter: xt_NFLOG: don't call nf_log_packet in NFLOG module.
      netfilter: nfmark routing in OUTPUT, mangle, NFQUEUE
      netfilter: nfmark IPV6 routing in OUTPUT, mangle, NFQUEUE
      netfilter: xt_NFLOG is dependant of nfnetlink_log

Eric Miao (48):
      [ARM] pxa: explicit #include <mach/dma.h> in various drivers
      [ARM] pxa: use 'pxa_last_gpio' instead of 'gpio_nr' in mfp-pxa2xx.c
      Revert "[ARM] pxa: introduce cpu_is_pxa26x()"
      [ARM] pxa: add support for additional GPIOs on PXA26x
      [ARM] pxa: use <linux/gpio.h> instead of unnecessary <mach/gpio.h>
      [ARM] pxa: removed unused declarations of pxa_gpio_* in hardware.h
      [ARM] pxa: move camera (QCI) registers definition out of pxa-regs.h
      [ARM] pxa: move FICP register definitions into pxaficp_ir.c
      [ARM] pxa: remove unused PWM register definitions, use generic PWM =
API
      [ARM] pxa: remove the now unused IMPMCR/IMPMSR register definitions
      [ARM] pxa: move pxa2xx specific PWRMODE definitions into pxa2xx-reg=
s.h
      [ARM] pxa: move UART register definitions into dedicated regs-uart.=
h
      [ARM] pxa: move AC97 register definitions into dedicated regs-ac97.=
h
      [ARM] pxa: move GPIOx_BASE and GPIO register offsets to gpio.c
      [ARM] pxa: further cleanup of pxa-regs.h
      [ARM] pxa: include <mach/hardware.h> in pxa-regs.h
      [ARM] pxa: remove unnecessary #include of pxa2xx-gpio.h in clock.c
      [ARM] pxa: move power I2C device definitions into devices.c
      [ARM] pxa: register Power I2C device only when necessary
      [ARM] pxa: move I2C pin configurations out into board specific file=
s
      [ARM] pxa: introduced cpu_is_pxa935() and cpu_is_pxa9xx()
      [ARM] pxa: add base PXA935 support due to CPUID change
      [ARM] pxa: add missing GPIOs definitions
      [ARM] locomo: export locomo_frontlight_set()
      [ARM] pxafb: make {backlight,lcd}_power() members of struct pxafb_i=
nfo
      [ARM] pxafb: add color TFT 8BPP LCD panel type
      [ARM] pxa: convert legacy LCD setup of other boards to new one
      [ARM] pxafb: remove now unused pxafb_setup_gpio() and related stuff=
s
      [ARM] pxafb: small cleanup of the smart panel code
      [ARM] pxafb: allow better platform configurable smart panel timing
      [ARM] pxafb: allow insertion of delay to the smart panel command se=
quence
      [ARM] pxafb: avoid the racing condition in pxafb_smart_thread
      [ARM] pxa/saar: add support for the on-board smart panel LCD
      [ARM] pxa/littleton: add preliminary I2C board info (da9034 + max73=
20)
      Input: add da9034 touchscreen support
      [ARM] pxa/tavorevb: update board support (smartpanel LCD + keypad)
      [ARM] rtc-sa1100: don't assume CLOCK_TICK_RATE to be a constant
      [ARM] sa1100_wdt: don't assume CLOCK_TICK_RATE to be a constant
      [ARM] pxa: add document on the MFP design and how to use it
      [ARM] pxafb: allow video memory size to be configurable
      [ARM] pxafb: allow pxafb_set_par() to start from arbitrary yoffset
      [ARM] pxafb: add support for FBIOPAN_DISPLAY by dma braching
      [ARM] pxafb: add palette format support for LCCR4_PAL_FOR_3
      [ARM] pxafb: cleanup of the color format manipulation code
      [ARM] pxafb: cleanup of the timing checking code
      [ARM] pxafb: add support for overlay1 and overlay2 as framebuffer d=
evices
      V4L/DVB: pxa-camera: use memory mapped IO access for camera (QCI) r=
egisters
      V4L/DVB (10176b): pxa-camera: fix redefinition warnings and missing=
 DMA definitions

Eric Paris (16):
      SELinux: check open perms in dentry_open not inode_permission
      SELinux: hold tasklist_lock and siglock while waking wait_chldexit
      SELinux: Use unknown perm handling to handle unknown netlink msg ty=
pes
      Document the order of arguments for cap_issubset.  It's not instant=
ly clear
      This patch add a generic cpu endian caps structure and externally a=
vailable
      This patch will print cap_permitted and cap_inheritable data in the=
 PATH
      Any time fcaps or a setuid app under SECURE_NOROOT is used to resul=
t in a
      When the capset syscall is used it is not possible for audit to rec=
ord the
      Capabilities: BUG when an invalid capability is requested
      Add a new capable interface that will be used by systems that use a=
udit to
      The oomkiller calculations make decisions based on capabilities.  S=
ince
      Currently SELinux jumps through some ugly hoops to not audit a capb=
ility
      capabilities: define get_vfs_caps_from_disk when file caps are not =
enabled
      filesystem notification: create fs/notify to contain all fs notific=
ation
      SELinux: shrink sizeof av_inhert selinux_class_perm and context
      sys_execve and sys_uselib do not call into fsnotify

Eric Piel (1):
      LIS3LV02D: separate the core from HP ACPI API

Eric Sandeen (4):
      Btrfs: fix RHEL test for ClearPageFsMisc
      [XFS] convert xfs_getbmap to take formatter functions
      [XFS] Add new getbmap flags.
      [XFS] Hook up the fiemap ioctl.

Eric Sesterhenn (2):
      bfs: add some basic sanity checks
      bfs: check that filesystem fits on the blockdevice

Eric W. Biederman (9):
      netns: Coexist with the sysfs limitations v2
      netns: Delete virtual interfaces during namespace cleanup
      net: Guaranetee the proper ordering of the loopback device.
      net: Don't leak packets when a netns is going down
      net: fib_rules ordering fixes.
      net: Guaranetee the proper ordering of the loopback device. v2
      netns: foreach_netdev_safe is insufficient in default_device_exit
      pid: implement ns_of_pid
      pid: generalize task_active_pid_ns

Erik Andren (1):
      V4L/DVB (10048): gspca - stv06xx: New subdriver.

Erik Andr=C3=A9n (48):
      V4L/DVB (9693): Remove some unused defines
      V4L/DVB (9694): Indent the m5602 register definitions
      V4L/DVB (9696): Remove accidental typo
      V4L/DVB (9698): Add another vflip quirk for the s5k4aa
      V4L/DVB (9701): Add a minor comment to the sensor init
      V4L/DVB (9702): Move the ov9650 vflip table to avoid compilation wa=
rnings on older kernels
      V4L/DVB (9703): Move the s5k4aa vflip quirk table to the main senso=
r file in order to avoid compilation errors on older kernels
      V4L/DVB (10000): gspca - m5602: Add lost ampersand
      V4L/DVB (10001): gspca - m5602: Minor fixes
      V4L/DVB (10002): m5602: Simplify error handling in the mt9m111 sens=
or code
      V4L/DVB (10003): m5602: Simplify the error handling in the ov9650 s=
ensor
      V4L/DVB (10004): m5602: Cleanup the po1030 sensor error handling
      V4L/DVB (10005): m5602: Cleanup the s5k4aa error handling, cull som=
e comments
      V4L/DVB (10006): gspca - m5602: Align some defines
      V4L/DVB (10007): gspca - m5602: Refactor the error handling in the =
s5k83a
      V4L/DVB (10008): gspca - m5602: Checkpatch.pl fixes on m5602_ov9650=
.c
      V4L/DVB (10009): gspca - m5602: Convert some functions to be static
      V4L/DVB (10010): gspca - m5602: Add vflip quirk for the ASUS A6Ja
      V4L/DVB (10011): m5602: Remove the write and read sensor from the m=
ain struct
      V4L/DVB (10012): m5602: Start to unify read/write sensor functions
      V4L/DVB (10013): Convert all sensors to use the unified write senso=
r function
      V4L/DVB (10014): gspca - m5602: Remove all sensor specific write fu=
nctions.
      V4L/DVB (10015): gspca - m5602: Add initial read sensor implementat=
ion
      V4L/DVB (10018): gspca - m5602 - ov9650: Use generic read_sensor fu=
nction
      V4L/DVB (10019): m5602: Let the ov9650 use the common read sensor f=
unction
      V4L/DVB (10020): m5602: Remove the ov9650 implementation of the rea=
d sensor function
      V4L/DVB (10021): m5602: Let the po1030 use the common read_sensor f=
unction
      V4L/DVB (10022): m5602: Remove the po1030 read_sensor function
      V4L/DVB (10023): m5602: Convert the mt9m111 to use the common read_=
sensor function
      V4L/DVB (10024): m5602: Remove the mt9m111 implementation of the re=
ad_sensor function.
      V4L/DVB (10025): m5602: convert the s5k4aa sensor to use the common=
 function
      V4L/DVB (10026): m5602: remove the s5k4aa implementation of the rea=
d_sensor
      V4L/DVB (10027): m5602: convert the s5k83a sensor to use the common=
 function
      V4L/DVB (10028): mt5602: Remove the s5k83a specific read_sensor fun=
ction
      V4L/DVB (10029): m5602: remove uneeded test on po1030
      V4L/DVB (10030): m5602: Use read/modify/write when toggling vflip o=
n the po1030
      V4L/DVB (10031): m5602: correct the name of the Pascal Stangs libra=
ry
      V4L/DVB (10032): m5602: add vflip quirk for Alienware m9700
      V4L/DVB (10033): m5602: add some comments
      V4L/DVB (10034): m5602: fixup offset in order to align image
      V4L/DVB (10035): m5602: add a start sending hook in the sensor stru=
ct
      V4L/DVB (10036): m5602 - ov9650: Prepare the sensor to set multiple=
 resolutions
      V4L/DVB (10037): m5602: add QVGA mode for the ov9650 sensor
      V4L/DVB (10038): m5602: tweak the hsync. Remove redundant init sequ=
ence
      V4L/DVB (10039): m5602 - ov9650: Add CIF mode
      V4L/DVB (10040): m5602 - ov9650: Activate variopixel
      V4L/DVB (10041): m5602 - rework parts of the resolution initializat=
ion
      V4L/DVB (10127): stv06xx: Avoid having y unitialized

Evgeniy Dushistov (1):
      minix: fix add link's wrong position calculation

Evgeniy Polyakov (11):
      crypto: hifn - Disable driver when physical size exceeds 32 bits
      crypto: hifn_795x - Fix queue management
      crypto: hifn_795x - Use softirq kernel mapping in bh context
      w1: add list masters w1 command
      w1: add touch block command
      w1: list slaves commands
      w1: documentation update
      w1: allow master IO commands
      w1: move w1 commands from defines to enum
      w1: added w1 reset command
      w1: send status messages after command processing

F. Duncan M. Haldane (1):
      Staging: Kconfig for ARCH=3Darm,8300, cris

FUJITA Tomonori (42):
      x86: fix dma_mapping_error for 32bit x86, cleanup
      x86: remove dead BIO_VMERGE_BOUNDARY definition
      powerpc: Remove dead BIO_VMERGE_BOUNDARY definition
      swiotlb: replace architecture-specific swiotlb.h with linux/swiotlb=
.h
      swiotlb: remove unnecessary declaration
      swiotlb: clean up EXPORT_SYMBOL usage
      block: use min_not_zero in blk_queue_stack_limits
      alpha: remove dead BIO_VMERGE_BOUNDARY
      [SCSI] aacraid: check pci_alloc_consistent errors
      [SCSI] add residual argument to scsi_execute and scsi_execute_req
      [SCSI] retry with missing data for INQUIRY
      [SCSI] st: move st_request initialization to st_allocate_request fo=
rm st_do_scsi
      [SCSI] st: add st_scsi_kern_execute helper function
      [SCSI] st: convert test_ready to use st_scsi_kern_execute
      [SCSI] st: convert set_location to use st_scsi_kern_execute
      [SCSI] st: convert do_load_unload to use st_scsi_kern_execute
      [SCSI] st: convert cross_eof to use st_scsi_kern_execute
      [SCSI] st: convert st_flush to use st_scsi_kern_execute
      [SCSI] st: convert check_tape to use st_scsi_kern_execute
      [SCSI] st: convert read_mode_page to use st_scsi_kern_execute
      [SCSI] st: convert write_mode_page to use st_scsi_kern_execute
      [SCSI] st: convert get_location to use st_scsi_kern_execute
      [SCSI] st: convert st_int_ioctl to use st_scsi_kern_execute
      [SCSI] scsi_transport_spi: fix the misuse of scsi_execute return va=
lue
      [SCSI] eata: fix the data buffer accessors conversion regression
      V4L/DVB (9472): dm1105: fix the misuse of pci_dma_mapping_error
      remove ide-scsi
      [SCSI] block: fix bio_add_page misuse with rq_map_data
      [SCSI] block: fix the partial mappings with struct rq_map_data
      [SCSI] block: make blk_rq_map_user take a NULL user-space buffer fo=
r WRITE
      [SCSI] st: make all the fragment buffers the same size
      [SCSI] st: add struct rq_map_data support
      [SCSI] st: add st_scsi_execute helper function
      [SCSI] st: convert non-dio path to use st_scsi_execute
      [SCSI] st: convert dio path to use st_scsi_execute
      [SCSI] st: remove buf_to_sg
      [SCSI] st: kill struct st_buff_fragment
      [SCSI] st: remove struct scatterlist
      [SCSI] st: simplify new_tape_buffer
      [SCSI] st: remove unused orig_frp_segs
      [SCSI] st: remove unused frp_sg_current
      parisc: remove dead BIO_VMERGE_BOUNDARY and BIO_VMERGE_MAX_SIZE def=
initions

Fabio Belavenuto (1):
      V4L/DVB (10155): Add TEA5764 radio driver

Fabio Estevam (2):
      Add basic support for MX31PDK board.
      Add default configuration for MX31PDK board.

Fabio Rossi (2):
      mac80211: accept empty strings for hidden SSIDs
      V4L/DVB (9999): gspca - zc3xx: Webcam 046d:089d added.

Fabrice Bellet (1):
      iwl3945: iwl3945_mac_get_tsf() should not return zero

Faisal Latif (7):
      RDMA/nes: Cleanup cqp_request list usage
      RDMA/nes: Lock down connected_nodes list while processing it
      RDMA/nes: Avoid race between MPA request and reset event to rdma_cm
      RDMA/nes: Forward packets for a new connection with stale APBVT ent=
ry
      RDMA/nes: Fix TCP compliance test failures
      RDMA/nes: Check cqp_avail_reqs is empty after locking the list
      RDMA/nes: Remove tx_free_list

Federico Heinz (1):
      i8k: Add Dell Vostro systems

Felipe Balbi (3):
      USB: musb: Add musb git tree to maintainers entry
      USB: musb: check if set_irq_wake succeded and remember it
      USB: gadget: don't wait for completion twice

Felix Beck (1):
      [S390] zcrypt: Use of Thin Interrupts

Felix Fietkau (4):
      minstrel: improve performance for non-MRR drivers
      ath5k: ignore the return value of ath5k_hw_noise_floor_calibration
      mac80211: fix BUILD_BUG_ON() caused by misalignment on arm
      ath5k: Clean up eeprom parsing and add missing calibration data

Fernando Carrijo (1):
      remove lots of double-semicolons

Fernando Luis Vazquez Cao (1):
      memcg: do not recalculate section unnecessarily in init_section_pag=
e_cgroup

Fernando Luis V=C3=A1zquez Cao (3):
      block: add queue flag for paravirt frontend drivers
      virtio_blk: set queue paravirt flag
      xen-blkfront: set queue paravirt flag

Finn Thain (9):
      m68k: Reinstate mac rtc
      m68k: Mac via cleanup and commentry
      m68k: machw.h cleanup
      m68k: mac baboon interrupt enable/disable
      macfb annotations and compiler warning fix
      m68k: fix trigraph ignored warning in setox.S
      fbcon: remove broken mac vbl handler
      [SCSI] m68k: mac_esp asm fix
      [SCSI] mac_esp: fix for quadras with two esp chips

Flavio Leitner (1):
      serial_8250: support for Sealevel Systems Model 7803 COMM+8

Florian Fainelli (5):
      r6040: bump release number to 0.19
      r6040: make printks consistent with DRV_NAME
      r6040: check PHY status when bringing interface up
      r6040: warn about MAC address being unset
      r6040: bump release number to 0.20

Franck Bui-Huu (2):
      do_mpage_readpage(): remove useless clear_buffer_mapped() call
      block_write_begin(): remove useless goto

Francois Romieu (1):
      r8169: convert to net_device_ops

Frank Blaschka (4):
      [S390] convert qeth printks to dev_xxx and pr_xxx macros.
      qeth: do not spin for SETIP ip assist command
      vlan: add neigh_setup
      qeth: convert to net_device_ops

Frank Mayhar (1):
      ext4: Allow ext4 to run without a journal

Frank Munzert (1):
      [S390] convert vmur printks to pr_xxx macros.

Frans Pop (1):
      ieee1394: ohci1394: don't leave interrupts enabled during suspend/r=
esume

Frederic CAND (1):
      V4L/DVB (9497): tda9887/cx88: Adds SECAM/BGH standards

Frederic Cand (2):
      V4L/DVB (9548): gspca: Properly indent Kconfig
      V4L/DVB (9548): gspca: Fix Kconfig CodingStyle

Frederic Weisbecker (47):
      ftrace: add a script to produce a hierarchical view of a function t=
race
      tracing/fastboot: Enable boot tracing only during initcalls
      tracing/ftrace: fix a race condition in sched_switch tracer
      tracing/ftrace: remove unused code in sched_switch tracer
      tracing/fastboot: use sched switch tracer from boot tracer
      tracing/ftrace: types and naming corrections for sched tracer
      tracing/ftrace: fix a bug when switch current tracer to sched trace=
r
      tracing, x86: add low level support for ftrace return tracing
      tracing: add a tracer to catch execution time of kernel functions
      tracing/fastboot: move boot tracer structs and funcs into their own=
 header.
      tracing/fastboot: Use the ring-buffer timestamp for initcall entrie=
s
      tracing/function-return-tracer: make the function return tracer loc=
kless
      tracing/function-return-tracer: call prepare_ftrace_return by regis=
ters
      tracing/ftrace: fix unexpected -EINVAL when longest tracer name is =
set
      tracing/ftrace: change the type of the init() callback
      tracing/branch-tracer: fix a trace recursion on branch tracer
      tracing/function-return-tracer: add a barrier to ensure return stac=
k index is incremented in memory
      tracing/function-return-tracer: support for dynamic ftrace on funct=
ion return tracer
      tracing/ftrace: implement a set_flag callback for tracers
      tracing/ftrace: make nop tracer using tracer flags
      tracing/function-return-tracer: add the overrun field
      tracing/function-return-tracer: store return stack into task_struct=
 and allocate it dynamically
      tracing/function-return-tracer: don't trace kfree while it frees th=
e return stack
      tracing/function-return-tracer: free the return stack on free_task(=
)
      tracing/function-return-tracer: change the name into function-graph=
-tracer
      tracing/function-return-tracer: set a more human readable output
      tracing/function-graph-tracer: enhancements for the trace output
      tracing/function-graph-tracer: adjustments of the trace information=
s
      tracing/branch-tracer: include missing irqflags.h
      tracing/function-graph-tracer: support for x86-64
      tracing/function-graph-tracer: display unified style cmdline and pi=
d
      tracing/function-graph-tracer: improve duration output
      tracing/function-graph-tracer: handle ftrace_printk entries
      tracing/ftrace: don't insert TRACE_PRINT during selftests
      tracing/ftrace: fix the check of ftrace_trace_task
      tracing/ftrace: provide the macro task_curr_ret_stack()
      tracing/function-graph-tracer: implement a print_headers function
      tracing/function-graph-tracer: introduce __notrace_funcgraph to fil=
ter special functions
      tracing/function-graph-tracer: turn tracing_selftest_running into a=
n int
      tracing/function-graph-tracer: append the tracing_graph_flag
      tracing/fastboot: include missing headers
      tracing/function-graph-tracer: add a new .irqentry.text section
      tracing/function-graph-tracer: annotate do_IRQ and smp_apic_timer_i=
nterrupt
      tracing/function-graph-tracer: Output arrows signal on hardirq call=
/return
      tracing/ftrace: use preempt_enable_no_resched_notrace in ring_buffe=
r_time_stamp()
      tracing/ftrace: add the printk-msg-only option
      tracing/ftrace: don't trace on early stage of a secondary cpu boot,=
 v3

Frederik Schwarzer (3):
      trivial: fix singal -> signal typo
      trivial: fix then -> than typos in comments and documentation
      trivial: fix an -> a typos in documentation and comments

From: Christoph Hellwig (1):
      [XFS] factor out xfs_read_agf helper

Gary Hade (2):
      x86: add memory hotremove config option
      mm: show node to memory section relationship with symlinks in sysfs

Gautham R Shenoy (1):
      sched: framework for sched_mc/smt_power_savings=3DN

Geert Uytterhoeven (9):
      powerpc/ps3: Replace the flip_ctl logic in ps3av and ps3fb by a mut=
ex
      powerpc/ps3: Add sub-match id modalias support
      crypto: testmgr - Validate output length in (de)compression tests
      crypto: testmgr - Correct comment about deflate parameters
      fbcon: Protect free_irq() by MACH_IS_ATARI check
      [SCSI] a2091, gvp11: kill warn_unused_result warnings
      Remove obsolete CONFIG_RESOURCES_64BIT
      fbdev/logo: check compatibility of main and extra logos
      mtd/ps3vram: Add modalias support to the ps3vram driver

Geoff Levand (7):
      powerpc: Fix typo in pgtable-ppc64.h
      powerpc/ps3: Quiet dmesg output
      mtd/ps3vram: Remove ps3vram debug routines
      mtd/ps3vram: Cleanup ps3vram driver messages
      mtd/ps3vram: Use proper kernel types
      mtd/ps3vram: Use msleep in waits
      mtd/ps3vram: Use _PAGE_NO_CACHE in memory ioremap

Gerald Schaefer (2):
      [S390] convert appldata printks to pr_xxx macros.
      [S390] convert monreader printks to pr_xxx macros.

Gerd Hoffmann (1):
      add missing accounting calls to compat_sys_{readv,writev}

Gerrit Renker (37):
      dccp: Basic data structure for feature negotiation
      dccp: Implement lookup table for feature-negotiation information
      dccp: List management for new feature negotiation
      dccp: Per-socket initialisation of feature negotiation
      dccp: Cleanup routines for feature negotiation
      dccp: Limit feature negotiation to connection setup phase
      dccp: Registration routines for changing feature values
      dccp: Query supported CCIDs
      dccp: Resolve dependencies of features on choice of CCID
      dccp: Mechanism to resolve CCID dependencies
      dccp: Deprecate old setsockopt framework
      dccp: Feature negotiation for minimum-checksum-coverage
      dccp: Deprecate Ack Ratio sysctl
      dccp: Tidy up setsockopt calls
      dccp: Fix bracing in dccp_feat_list_lookup.
      dccp: Set per-connection CCIDs via socket options
      dccp: API to query the current TX/RX CCID
      dccp: Increase the scope of variable-length htonl/ntohl functions
      dccp: Support for Mandatory options
      dccp: Header option insertion routine for feature-negotiation
      dccp: Insert feature-negotiation options into skb
      dccp: Integrate feature-negotiation insertion code
      dccp: Preference list reconciliation
      dccp: Process incoming Change feature-negotiation options
      dccp: Processing Confirm options
      dccp: Feature activation handlers
      dccp: Integration of dynamic feature activation - part 1 (socket se=
tup)
      dccp: Integration of dynamic feature activation - part 2 (server si=
de)
      dccp: Integration of dynamic feature activation - part 3 (client si=
de)
      dccp: Clean up old feature-negotiation infrastructure
      dccp: Remove obsolete parts of the old CCID interface
      dccp: Remove manual influence on NDP Count feature
      dccp ccid-2: Phase out the use of boolean Ack Vector sysctl
      tun: Eliminate sparse signedness warning
      dccp: Lockless integration of CCID congestion-control plugins
      dccp: Clean up ccid.c after integration of CCID plugins
      dccp: Integrate the TFRC library with DCCP

Gianluca Palli (1):
      Staging: comedi: add s626 driver

Giuseppe Cavallaro (3):
      phy: add natsemi PHY driver
      phy: power management support
      phy: add the ST ste10Xp PHYs

Glauber Costa (4):
      x86: KVM guest: sign kvmclock as paravirt
      KVM: Really remove a slot when a user ask us so
      mm: vmalloc tweak failure printk
      mm: vmalloc improve vmallocinfo

Gleb Natapov (1):
      KVM: call kvm_arch_vcpu_reset() instead of the kvm_x86_ops callback

Gowrishankar M (1):
      cgroups: skip processes from other namespaces when listing a cgroup

Grace Pan (1):
      Blackfin arch: Enlarge flash partition for kenel for bf533/bf537 bo=
ards

Graf Yang (20):
      Blackfin arch: fix bug - kernel with SMP patch can not bootup
      Blackfin arch: SMP supporting patchset: BF561 related code
      Blackfin arch: SMP supporting patchset: Blackfin header files and m=
achine common code
      Blackfin arch: SMP supporting patchset: Blackfin CPLB related code
      Blackfin arch: SMP supporting patchset: Blackfin kernel and memory =
management code
      Blackfin arch: SMP supporting patchset: some other misc code
      Blackfin arch: Add code to free gpio when shutdown irq
      Blackfin arch: Request the gpio resource when making it as an irq p=
in, avoiding override it.
      Blackfin Serial Driver: fix bug - SIR driver stop receiving randoml=
y
      Blackfin arch: Allow a gpio pin be requested both as gpio and irq.
      Blackfin arch: Add document about bfin-gpio
      Blackfin arch: get oprofile work for user space
      Blackfin arch: smp patch cleanup from LKML review
      Blackfin arch: implement support for /proc/dma
      Blackfin arch: update header to match new location
      Blackfin arch: Modify bfin_sir device configuration to board file
      Blackfin arch: Remove wasted SIR header files
      Blackfin arch: Fix bug - IrDA SIR build failed for BF533.
      Blackfin arch: remove hardware PM code, oprofile not use it
      Blackfin arch: Clean oprofile build path for blackfin

Grant Erickson (1):
      powerpc: Const-qualify Device Node Argument to DCR Resource Extent =
API

Grant Grundler (1):
      sata_sil24: remove unused sil24_port_multiplier

Grant Likely (5):
      powerpc/mpc5200: Document and tidy irq driver
      powerpc/mpc5200: Make internal 5200 PIC the default interrupt contr=
oller
      powerpc/mpc5200: Bugfix on handling variable sized buffer descripto=
rs
      powerpc/mpc5200: Disable bestcomm prefetching when ATA DMA enabled
      powerpc: Copy bootable images in the default install script

Grazvydas Ignotas (5):
      ALSA: ASoC: TWL4030 codec - fix 256*Fs clock
      ASoC: TWL4030: Add input selection and gain controls
      ASoC: Add support for OMAP3 Pandora
      ARM: OMAP3: Add basic support for Pandora handheld console
      ASoC: Mark non-connected TWL4030 pins for pandora

Greg KH (1):
      btrfs: fixes for kobject changes in mainline

Greg Kroah-Hartman (95):
      driver core: create a private portion of struct device
      driver core: move klist_children into private structure
      driver core: move knode_driver into private structure
      driver core: move knode_bus into private structure
      Staging: go7007: fixes due to video_usercopy api change
      Staging: go7007: fixes due v4l2_file_operations api change
      Staging: w35und: remove usb_submit_urb wrapper function
      Staging: w35und: remove usb_alloc_urb wrapper function
      Staging: w35und: fix config build warnings
      Staging: wlan-ng: fix compiler warnings
      Staging: at76_usb: fix build breakage
      Staging: at76_usb: remove compiler warnings
      Staging: at76_usb: fix up all remaining checkpatch.pl warnings
      Staging: go7007: fix minor build warnings
      Staging: go7007: add some more v4l2 ioctls
      Staging: agnx: fix build errors due to ssid removal
      Staging: agnx: fix build errors due to rate control API changes
      Staging: agnx: fix build warnings
      Staging: otus: fix netdev->priv usage
      Staging: otus: fix urb callback function type
      Staging: add rt2860 wireless driver
      Staging: rt2860: disable root hack for reading files
      Staging: rt2860: fix up netdev->priv usage
      Staging: rt2860: Fix minor compiler warnings
      Staging: rt2860: enable WPA_SUPPLICANT support
      Staging: benet: fix netif api breakage
      Staging: benet: fix up netdev->priv change
      Staging: benet: build is broken unless CONFIG_NETPOLL is enabled
      Staging: benet: fix build error.
      Staging: comedi: fix up a lot of checkpatch.pl warnings
      Staging: comedi: fix checkpatch.pl errors in comedi_fops.c
      Staging: comedi: fix build error in comedilib.h
      Staging: comedi: set up infrastructure for individual drivers
      Staging: comedi: dt9812: fix up a lot of coding style issues
      Staging: comedi: dt9812: remove dt9812.h
      Staging: comedi: dt9812: remove typedefs
      Staging: comedi: dt9812: fix sparse warnings
      Staging: comedi: usbdux: remove kernel version checks
      Staging: comedi: usbdux: code style cleanups
      Staging: comedi: usbdux: remove // comments
      Staging: comedi: usbdux: fix up printk calls
      Staging: comedi: usbdux: remove checkpatch.pl warnings
      Staging: comedi: usbdux: remove typedef
      Staging: comedi: usbdux: remove comedi usb wrappers
      Staging: comedi: usbduxfast: remove comedi usb wrappers
      Staging: comedi: dt9812: remove #ifdef that is not needed
      Staging: comedi: remove usb wrappers
      Staging: comedi: remove PCI wrappers
      Staging: comedi: fix checkpatch.pl issues in comedi_bond.c
      Staging: comedi: fix checkpatch.pl issues in comedi_fc.c
      Staging: comedi: remove typedefs from comedi_bond.c
      Staging: comedi: fix sparse issues in comedi_bond.c
      Staging: comedi: fix checkpatch.pl issues in comedi_test.c
      Staging: comedi: fix sparse issues in comedi_test.c
      Staging: comedi: remove typedefs from comedi_test.c
      Staging: comedi: fix comedi_parport.c checkpatch.pl issues.
      Staging: comedi: fix comedi_fc.h checkpatch.pl issues.
      Staging: comedi: fix comedi_pci.h checkpatch.pl issues.
      Staging: comedi: comedi_pci.h: remove unneeded wrapper
      Staging: comedi: comedi_pci.h: remove comedi_pci_enable_no_regions
      Staging: comedi: comedi_pci.h: remove comedi_pci_disable_no_regions
      Staging: comedi: me_daq: fix checkpatch.pl issues
      Staging: comedi: me_daq: remove typedefs
      Staging: comedi: me_daq: fix sparse issues
      Staging: comedi: fix checkpatch.pl warning in interrupt.h
      Staging: add rtl8187se driver
      Staging: rtl8187se: remove unneeded files
      Staging: rtl8187se: make the built module be the proper name
      Staging: rtl8187se: remove duplicate pci ids
      Staging: add princeton instruments usb camera driver
      Staging: add mimio xi driver
      Staging: add rt2870 wireless driver
      Staging: rt2870: disable root hack for reading files
      Staging: rt2870: fix up netdev->priv usage
      Staging: frontier: remove unused alphatrack_sysfs.c file
      Staging: frontier: fix compiler warnings
      Staging: epl: run Lindent on all kernel/*.h files
      Staging: epl: run Lindent on all user/*.h files
      Staging: epl: run Lindent on *.h files
      Staging: epl: run Lindent on *.c files
      Staging: epl: hr timers all run in hard irq context now
      Staging: epl: fix netdev->priv b0rkage
      Staging: add android framework
      Staging: android: remove dummy android.c driver
      Staging: android: binder: fix build errors
      USB: serial: fix up urb->status usage
      USB: option: increase outgoing buffer size and number
      USB: add new opticon serial driver
      USB: add siemens_mpi usb-serial "stub" driver
      USB: remove warn() macro from usb.h
      USB: remove info() macro from usb.h
      Revert "driver core: move knode_bus into private structure"
      Revert "driver core: move knode_driver into private structure"
      Revert "driver core: move klist_children into private structure"
      Revert "driver core: create a private portion of struct device"

Guennadi Liakhovetski (20):
      i.MX31: fix mxc_iomux_set_pad()
      [ARM] pcm037: add support for the on-board LAN9217 network controll=
er
      V4L/DVB (9785): soc-camera: merge .try_bus_param() into .try_fmt_ca=
p()
      V4L/DVB (9786): soc-camera: formatting fixes
      V4L/DVB (9787): soc-camera: let camera host drivers decide upon pix=
el format
      V4L/DVB (9788): soc-camera: simplify naming
      V4L/DVB (9789): soc-camera: add a per-camera device host private da=
ta pointer
      V4L/DVB (9790): soc-camera: pixel format negotiation - core support
      V4L/DVB (10066): mt9m001 mt9v022: fix bus-width switch GPIO availab=
ility test
      V4L/DVB (10072): soc-camera: Add signal inversion flags to be used =
by camera drivers
      V4L/DVB (10074): soc-camera: add camera sense data
      V4L/DVB (10075): pxa-camera: setup the FIFO inactivity time-out reg=
ister
      V4L/DVB (10080): soc-camera: readability improvements, more strict =
operations checks
      V4L/DVB (10081): pxa-camera: call try_fmt() camera device method wi=
th correct pixel format
      V4L/DVB (10083): soc-camera: unify locking, play nicer with videobu=
f locking
      V4L/DVB (10090): soc-camera: let drivers decide upon supported fiel=
d values
      V4L/DVB (10091): mt9m001 mt9v022: simplify pointer derefernces
      V4L/DVB (10093): soc-camera: add new bus width and signal polarity =
flags
      V4L/DVB (10099): soc-camera: add support for MT9T031 CMOS camera se=
nsor from Micron
      V4L/DVB (10176a): Switch remaining clear_user_page users over to cl=
ear_user_highpage

Guenter Gebhardt (1):
      Staging: comedi: add me4000 driver

Guillaume Thouvenin (9):
      KVM: x86 emulator: consolidate push reg
      KVM: x86 emulator: Add decode entries for 0x04 and 0x05 opcodes (ad=
d acc, imm)
      KVM: allow emulator to adjust rip for emulated pio instructions
      KVM: VMX: Handle mmio emulation when guest state is invalid
      KVM: x86 emulator: Extend the opcode descriptor
      KVM: x86 emulator: add Src2 decode set
      KVM: x86 emulator: add a new "implied 1" Src decode type
      KVM: x86 emulator: add the assembler code for three operands
      KVM: x86 emulator: add the emulation of shld and shrd instructions

Guo-Fu Tseng (1):
      jme: Remove 64 and 40 bit dma_mask

H. Peter Anvin (10):
      x86: 32 bit: interrupt stub consistency with 64 bit
      x86: 32 bits: shrink and align IRQ stubs
      x86: 64 bits: shrink and align IRQ stubs
      x86: attempt reboot via port CF9 if we have standard PCI ports
      x86: fix up the new IRQ code for older versions of gas
      x86: revert default reboot method to REBOOT_KBD
      x86: drop REBOOT_CF9_COND from reboot fallback chain
      x86: prioritize the FPU traps for the error code
      x86: PAT: fix address types in track_pfn_vma_new()
      x86: unify the implementation of FPU traps

Haavard Skinnemoen (9):
      favr-32: Remove deprecated call
      Merge branch 'cleanups' into boards
      Merge branch 'move-atmel-mci-h' into boards
      avr32: data param to at32_add_device_mci() must be non-NULL
      atmel_spi: clean up SPIv1 quirk handling
      spi: atmel_spi update chipselect handling
      avr32: Define DIE_OOPS
      Merge branches 'fixes', 'cleanups' and 'boards'
      avr32: Move syscalls.h under arch/avr32/include/asm/

Haiying Wang (3):
      powerpc/85xx: Add localbus node in mpc8572ds dts file
      powerpc/85xx: Don't reset the MPIC for CAMP mode on MPC8572DS
      powerpc/85xx: Create dts for each core in CAMP mode for MPC8572DS

Halperin, Daniel C (2):
      iwlwifi: update iwl-commands.h for 3 stream support
      iwlwifi: implement iwl_debug_report_frame for iwlagn

Hannes Eder (66):
      sound: Fix warnings relating to ignored return value in snd_card_re=
gister
      ALSA: hda - fix sparse warning
      x86: vmware - fix sparse warnings
      x86: hypervisor - fix sparse warnings
      x86: remove duplicate #define from 'cpufeature.h'
      x86: boot - fix sparse warnings
      x86: HPET: fix sparse warning
      CRED: fix sparse warnings
      x86: microcode: fix sparse warnings
      pkt_sched: fix sparse warning
      ACPI: EC: fix compilation warning
      mISDN: use NULL pointer instead of plain integer
      mISDN: consistently define 'debug' as '*u_int'
      mISDN: make global symbols static or include header files
      mISDN: un-export symbol 'plx_lock'
      mISDN: fix sparse warning: symbol 'nskb' shadows an earlier one
      mISDN: fix sparse warning: symbol 'id' shadows an earlier one
      mISDN: comment out unused symbols
      mISDN: timerdev: use __user for mISDN_read's buffer argument
      mISDN: hfcmulti: use __iomem address space modifier
      isdn: eicon: fix sparse warning: make global functions static
      drivers/net: fix sparse warning: use ANSI-style function declaratio=
n
      drivers/net: fix sparse warnings: make do-while a compound statemen=
t
      drivers/net: fix sparse warning: returning void-valued expression
      drivers/net: fix sparse warnings: make symbols static
      drivers/net/arcnet: fix sparse warnings: make symbols static
      drivers/net/atlx: fix sparse warnings: make symbols static
      drivers/net/bonding: fix sparse warnings: move decls to header file
      drivers/net/cxgb3: comment out dead code
      drivers/net/e1000e: fix sparse warnings: make symbols static
      drivers/net/enic: fix sparse warning: make symbol static
      drivers/net/igb: remove dead code (function 'igb_read_pci_cfg')
      drivers/net/irda: fix sparse warnings: make symbols static
      drivers/net/ixgbe: fix sparse warnings: make symbols static
      drivers/net/netxen: fix sparse warnings: use NULL pointer instead o=
f plain integer
      drivers/net/qlge: fix sparse warnings: make symbols static
      drivers/net/skfp: fix sparse warnings: make symbols static
      drivers/net/tokenring: fix sparse warnings: make symbols static
      drivers/net/tulip: fix sparse warnings: make do-while a compound st=
atement
      drivers/net/wan: fix sparse warnings: make do-while a compound stat=
ement
      drivers/net/wan: fix sparse warning: make symbol static
      drivers/net/wan/z85230.c: fix sparse warnings: un-EXPORT symbols
      drivers/net/wireless: fix sparse warnings: make symbols static
      drivers/net/wireless/ath9k: fix sparse warnings: make symbols stati=
c
      drivers/net/wireless/b43: fix sparse warnings: make symbols static
      drivers/net/wireless/ipw2x00: fix sparse warnings: make symbols sta=
tic
      drivers/net/wireless/prism54: fix sparse warnings: make symbols sta=
tic
      drm/i915: fix sparse warnings: declare one-bit bitfield as unsigned
      drm/i915: fix sparse warnings: make symbols static
      drm/i915: fix sparse warnings: move 'extern' decls to header file
      drm/i915: fix sparse warnings: returning void-valued expression
      drm/i915: un-EXPORT and make 'intelfb_panic' static
      KVM: fix sparse warning
      KVM: VMX: fix sparse warning
      kbuild: disable sparse warning "returning void-valued expression"
      HID: avoid sparse warning in HID_COMPAT_LOAD_DRIVER
      proc: fix sparse warning
      trivial: rtc-ds1511: fix sparse warning
      trivial: rtc-stk17ta8: fix sparse warning
      hugetlb: fix sparse warnings
      nvidia: fix sparse warnings
      viafb: fix sparse warnings
      pm3fb: fix sparse warning
      neofb: fix sparse warnings
      i810: fix sparse warnings
      intelfb: fix sparse warnings

Hannes Hering (1):
      ehea: Fix some whitespace issues

Hans J. Koch (2):
      UIO: Pass information about ioports to userspace (V2)
      UIO: Documentation for UIO ioport info handling

Hans Verkuil (57):
      V4L/DVB (9484): v4l: rename compat_ioctl32.c to v4l2-compat-ioctl32=
.c
      V4L/DVB (9502): ov772x: CodingStyle improvements
      V4L/DVB (9503): v4l: remove inode argument from video_usercopy
      V4L/DVB (9504): dvbdev: fix typo causing 2.6.28 compile error
      V4L/DVB (9507): v4l: remove EXPERIMENTAL from several drivers
      V4L/DVB (9508): ivtv: enable tuner support for Yuan PG600-2
      V4L/DVB (9678): af9015: Cleanup switch for usb ID
      V4L/DVB (9820): v4l2: add v4l2_device and v4l2_subdev structs to th=
e v4l2 framework.
      V4L/DVB (9821): v4l2-common: add i2c helper functions
      V4L/DVB (9822): cs53l32a: convert to v4l2_subdev.
      V4L/DVB (9823): cx25840: convert to v4l2_subdev.
      V4L/DVB (9824): m52790: convert to v4l2_subdev.
      V4L/DVB (9825): msp3400: convert to v4l2_subdev.
      V4L/DVB (9826): saa7115: convert to v4l2_subdev.
      V4L/DVB (9827): saa7127: convert to v4l2_subdev.
      V4L/DVB (9828): saa717x: convert to v4l2_subdev.
      V4L/DVB (9829): tuner: convert to v4l2_subdev.
      V4L/DVB (9830): upd64031a: convert to v4l2_subdev.
      V4L/DVB (9831): upd64083: convert to v4l2_subdev.
      V4L/DVB (9832): vp27smpx: convert to v4l2_subdev.
      V4L/DVB (9833): wm8739: convert to v4l2_subdev.
      V4L/DVB (9834): wm8775: convert to v4l2_subdev.
      V4L/DVB (9835): ivtv/ivtvfb: convert to v4l2_device/v4l2_subdev.
      V4L/DVB (9904): v4l: fix compile warning.
      V4L/DVB (9905): v4l2-compat32: add missing newline after kernel mes=
sage
      V4L/DVB (9932): v4l2-compat32: fix 32-64 compatibility module
      V4L/DVB (9934): v4l2-compat32: add two additional #ifdef __OLD_VIDI=
OC_ lines
      V4L/DVB (9939): tuner: fix tuner_ioctl compile error if V4L1 ioctls=
 are disabled.
      V4L/DVB (9940): bt832: remove this driver
      V4L/DVB (9941): cx24113: fix compile warnings
      V4L/DVB (9942): v4l2-dev: check for parent device in get_index.
      V4L/DVB (9943): v4l2: document video_device.
      V4L/DVB (9944): videodev2.h: fix typo.
      V4L/DVB (9957): v4l2-subdev: add g_sliced_vbi_cap and add NULL poin=
ter checks
      V4L/DVB (9958): tvp5150: convert to v4l2_subdev.
      V4L/DVB (9959): tvaudio: convert to v4l2_subdev.
      V4L/DVB (9960): v4l2-subdev: ioctl ops should use unsigned for cmd =
arg.
      V4L/DVB (9961): tea6415c: convert to v4l2_subdev.
      V4L/DVB (9962): tea6420: convert to v4l2_subdev.
      V4L/DVB (9963): tlv320aic23b: convert to v4l2_subdev.
      V4L/DVB (9964): tda7432: convert to v4l2_subdev.
      V4L/DVB (9965): tda9840: convert to v4l2_subdev.
      V4L/DVB (9966): tda9875: convert to v4l2_subdev.
      V4L/DVB (9967): cs5345: convert to v4l2_subdev and fix broken s_ctr=
l.
      V4L/DVB (9973): v4l2-dev: use the release callback from device inst=
ead of cdev
      V4L/DVB (9974): v4l2-dev: allow drivers to pass v4l2_device as pare=
nt
      V4L/DVB (9975): ivtv: set v4l2_dev instead of parent.
      V4L/DVB (10132): v4l2-compat-ioctl32: remove dependency on videodev.
      V4L/DVB (10133): v4l2-framework: use correct comment style.
      V4L/DVB (10134): v4l2 doc: set v4l2_dev instead of parent.
      V4L/DVB (10135): v4l2: introduce v4l2_file_operations.
      V4L/DVB (10136): v4l2 doc: update v4l2-framework.txt
      V4L/DVB (10137): v4l2-compat32: only build if needed
      V4L/DVB (10138): v4l2-ioctl: change to long return type to match un=
locked_ioctl.
      V4L/DVB (10139): v4l: rename v4l_compat_ioctl32 to v4l2_compat_ioct=
l32
      V4L/DVB (10140): gp8psk: fix incorrect return code (EINVAL instead =
of -EINVAL)
      V4L/DVB (10141): v4l2: debugging API changed to match against drive=
r name instead of ID.

Hans de Goede (28):
      V4L/DVB (9543): gspca: Adjust autoexpo values for cams with a vga s=
ensor in sonixb.
      V4L/DVB (9685): gspca: Correct restart of webcams in spca501.
      V4L/DVB (9686): gspca: Don't return the control values from the web=
cams in spca501.
      V4L/DVB (9687): gspca: Split brightness and red and blue balance in=
 spca501.
      V4L/DVB (9706): gspca: Use the ref counting of v4l2 for disconnecti=
on.
      V4L/DVB (9707): gspca: Remove the event counter and simplify the fr=
ame wait.
      V4L/DVB (9878): gspca - vc032x: Fix frame overflow errors with vc03=
21.
      V4L/DVB (9982): gspca - pac207: Update my email address.
      V4L/DVB (9992): gspca - pac207: Webcam 093a:2461 added.
      V4L/DVB (10044): gspca - pac7311: Webcam 093a:2620 added.
      hwmon: (f71882fg) Style cleanups and put some repeating code into f=
unctions
      hwmon: (f71882fg) Add support for the F71862FG superio sensors
      hwmon: (f71882fg) Move some io access from the detect to the probe =
function
      hwmon: (f71882fg) Prepare for adding F8000 support
      hwmon: (f71882fg) Fix various sysfs callback function issues
      hwmon: (f71882fg) Cleanup fan and temp hyst functions
      hwmon: (f71882fg) Check for hwmon powerdown state
      hwmon: (f71882fg) Separate max and crit alarm and beep
      hwmon: (f71882fg) Remove the fan_mode module option
      hwmon: (f71882fg) Add F8000 support
      hwmon: (f71882fg) Add missing pwm3 attr for f71862fg
      hwmon: (f71882fg) Fix auto_channels_temp temp numbering with f8000
      hwmon: (f71882fg) Add documentation
      hwmon: (f71882fg) Printout fan modes
      hwmon: (f71882fg) Fix fan_to/from_reg prototypes
      hwmon: (fschmd) Cleanups for watchdog support
      hwmon: (fschmd) Add watchdog support
      hwmon: Deprecate the fscher and fscpos drivers

Harry Fearnhamm (1):
      RealView: Use flush_cache_all() rather than MCR in cpu_enter_lowpow=
er()

Hartley Sweeten (5):
      [ARM] 5309/1: ep93xx: add edb9307a platform
      [ARM] 5311/1: ep93xx: add core support for built in i2c bus
      [ARM] 5324/2: ep93xx: support gpio interrupt debounce
      [ARM] 5342/1: ep93xx: platform init cleanup
      [ARM] 5343/1: ep93xx: include linux/i2c.h

Harvey Harrison (96):
      printk: add %pM format specifier for MAC addresses
      x86: use the new byteorder headers
      printk: add %p6 format specifier for IPv6 addresses
      net: replace all current users of NIP6_SEQFMT with %#p6
      misc: replace NIP6_FMT with %p6 format specifier
      netfilter: replace uses of NIP6_FMT with %p6
      net: replace uses of NIP6_FMT with %p6
      net, misc: replace uses of NIP6_FMT with %p6
      infiniband: use %p6 for printing message ids
      infiniband: ipoib replace IPOIB_GID_FMT with %p6
      infiniband: remove IPOIB_GID_RAW_ARG, IPOIB_GID_ARG, IPOIB_GID_FMT
      uwb: use the %pM formatting specifier in eda.c
      net: remove NIP6(), NIP6_FMT, NIP6_SEQFMT and final users
      printk: add %I4, %I6, %i4, %i6 format specifiers
      net: replace %#p6 format specifier with %pi6
      net: replace %p6 with %pI6
      printk: remove %p6 format specifier, fix up comments
      net: easy removals of HIPQUAD using %pI4 format
      net: replace NIPQUAD() in net/ipv4/netfilter/
      net: replace NIPQUAD() in net/ipv4/ net/ipv6/
      net: replace NIPQUAD() in net/netfilter/
      net: replace NIPQUAD() in net/*/
      drivers: replace NIPQUAD()
      fs: replace NIPQUAD()
      misc: replace NIPQUAD()
      printk: ipv4 address digits printed in reverse order
      powerpc: Use the new byteorder headers
      xtensa: use the new byteorder headers
      ipvs: oldlen, newlen should be be16, not be32
      phonet: sparse annotations of protocol, remove forward declaration
      tipc: trivial endian annotation in debug statement
      x86: x86_32 has its own irq_regs definition
      xtensa: switch to packed struct unaligned access implementation
      isdn: use %pI4, remove get_{u8/u16/u32} and put_{u8/u16/u32} inline=
s
      net: ip_sockglue.c add static, annotate ports' endianness
      isdn: isdn_net.c annotate struct ip_ports and trivial sparse fixes
      aoe: remove private mac address format function
      decnet: remove private wrappers of endian helpers
      decnet: compile fix for removal of byteorder wrapper
      fuse: clean up annotations of fc->lock
      iwlwifi: remove uses of __constant_{endian} helpers
      [MTD] remove private wrapper of endian helpers in rfd_ftl.c
      Input: ads7846 - strict_strtoul takes unsigned long
      dlm: trivial annotation of be16 value
      crypto: camellia - use kernel-provided bitops, unaligned access
      crypto: remove uses of __constant_{endian} helpers
      crypto: salsa20 - Remove private wrappers around various operations
      [S390] s390: use the new byteorder headers
      m68k: use the new byteorder headers
      V4L/DVB (9636): dvb: cinergyt2 annotate struct endianness, remove u=
nused variable, add static
      V4L/DVB (9637): usb vendor_ids/product_ids are __le16
      mmc: trivial annotation of 'blocks'
      __FUNCTION__ is gcc-specific, use __func__
      ieee1394: consolidate uses of IEEE1934_BUSID_MAGIC
      ieee1394: pcilynx: trivial endian annotation
      ieee1394: replace CSR_SET_BUS_INFO_GENERATION macro
      ieee1394: mark bus_info_data as a __be32 array
      ieee1394: eth1394: trivial sparse annotations
      ieee1394: dv1394: annotate frame input/output structs as little end=
ian
      ieee1934: dv1394: interrupt enabling/disabling broken on big-endian
      GFS2: sparse annotation of gl->gl_spin
      parisc: use the new byteorder headers
      staging: correct dubious use of !x & y
      Staging: go7007: annotate code pointers
      lib: fix sparse shadowed variable warning
      lib: radix_tree.c make percpu variable static
      lib: proportions.c trivial sparse lock annotation
      ibmpex: add endian annotation to extract_data() helper
      blackfin: remove __FUNCTION__ in video driver
      fb: carminefb: trivial annotation packing color register
      byteorder: only use linux/swab.h
      avr32: introduce asm/swab.h
      mips: introduce asm/swab.h
      powerpc: introduce asm/swab.h
      s390: introduce asm/swab.h
      sh: introduce asm/swab.h
      sparc: introduce asm/swab.h
      x86: introduce asm/swab.h
      m68k: introduce asm/swab.h
      alpha: introduce asm/swab.h
      arm: introduce asm/swab.h
      blackfin: introduce asm/swab.h
      ia64: introduce asm/swab.h
      h8300: introduce asm/swab.h
      m68knommu: introduce asm/swab.h
      m32r: introduce asm/swab.h
      frv: introduce asm/swab.h
      mn10300: introduce asm/swab.h
      byteorder: remove the now unused byteorder.h
      USB: avoid needless address-taking of function parameters
      USB: wusb: annotate association types withe proper endianness
      xtensa: introduce swab.h
      trivial: replace last usages of __FUNCTION__ in kernel
      staging: __FUNCTION__ is gcc-specific, use __func__
      parisc: introduce asm/swab.h
      memstick: annotate endianness of attribute structs

Heiko Carstens (27):
      ftrace: preemptoff selftest not working
      nohz: no softirq pending warnings for offline cpus
      sched: let arch_update_cpu_topology indicate if topology changed
      sched: add missing arch_update_cpu_topology() call
      [S390] cpu topology: fix cpu_core_map initialization
      [S390] cpu topology: dont destroy cpu sets on topology change
      [S390] convert etr/stp to stop_machine interface
      [S390] convert s390 to generic IPI infrastructure
      [S390] Move stfle to header file.
      [S390] ftrace: function tracer backend for s390
      [S390] cio: get rid of compile warning
      [S390] mark disabled_wait as noreturn function
      [S390] sclp vt220: fix compile warning
      [S390] Remove initial kernel stack backchain initialization.
      [S390] cpu topology: introduce kernel parameter
      [S390] cpu topology: remove dead code
      [SCSI] zfcp: fix compile warning
      stop_machine: introduce stop_machine_create/destroy.
      module: convert to stop_machine_create/destroy.
      qeth: get rid of extra argument after printk to dev_* conversion
      iucv: fix cpu hotplug
      stop_machine/cpu hotplug: fix disable_nonboot_cpus
      [S390] ptrace: no extern declarations for userspace
      [S390] types: add/fix types.h include in header files
      [S390] remove code for oldselect system call
      [S390] vdso: compile fix
      [S390] Use unsigned long long for u64 on 64bit.

Helge Deller (7):
      Input: HIL drivers - add MODULE_ALIAS()
      module: fix module loading failure of large kernel modules for pari=
sc
      parisc: fix module loading failure of large kernel modules
      parisc: fix GFP_KERNEL use while atomic in unwinder
      parisc: trivial fixes
      parisc: Replace NR_CPUS in parisc code
      parisc: add uevent helper for parisc bus

Helmut Schaa (2):
      iwl3945: remove obsolete irq handling
      ipw2200: fix scanning while associated

Hendrik Brueckner (14):
      hvc_console: Always schedule resize work on resize
      hvc_console: Escape magic sysrq key
      [S390] s390/hvc_console: z/VM IUCV hypervisor console support
      [S390] iucv: Locking free version of iucv_message_(receive|send)
      [S390] s390/setup: set default preferred console device "ttyS"
      [S390] provide documentation for hvc_iucv kernel parameter.
      af_iucv: New error return codes for connect()
      af_iucv: Free iucv path/socket in path_pending callback
      [S390] hvc_iucv: Change IUCV term id and use one device as default
      [S390] hvc_iucv: Limit rate of outgoing IUCV messages
      [S390] hvc_iucv: Update function documentation
      [S390] hvc_iucv: Refactor console and device initialization
      [S390] hvc_iucv: Special handling of IUCV HVC devices
      [S390] update documentation for hvc_iucv kernel parameter.

Henning Rogge (1):
      nl80211: Add signal strength and bandwith to nl80211station info

Henrik Rydberg (1):
      hwmon: applesmc: Add support for MacBook Air 2

Henrique de Moraes Holschuh (7):
      rfkill: use killable locks instead of interruptible
      rfkill: export global states to rfkill-input
      rfkill: add master_switch_mode and EPO lock to rfkill and rfkill-in=
put
      rfkill: honour EPO state when resuming a rfkill controller
      rfkill: rate-limit rfkill-input workqueue usage (v3)
      rfkill: preserve state across suspend
      rfkill: always call get_state() hook on resume

Herbert Xu (39):
      net: Add frag_list support to skb_segment
      net: Add frag_list support to GSO
      net: Add Generic Receive Offload infrastructure
      ipv4: Add GRO infrastructure
      net: Add skb_gro_receive
      tcp: Add GRO support
      ethtool: Add GGRO and SGRO ops
      e1000e: Add GRO support
      crypto: padlock - Avoid resetting cword on successive operations
      crypto: api - Move type exit function into crypto_tfm
      crypto: api - Rebirth of crypto_alloc_tfm
      crypto: hash - Add shash interface
      crypto: hash - Export shash through ahash
      crypto: hash - Add import/export interface
      crypto: api - Call type show function before legacy for proc
      crypto: hash - Export shash through hash
      crypto: crc32c - Switch to shash
      crypto: crc32c-intel - Switch to shash
      crypto: crc32c - Test descriptor context format
      libcrc32c: Move implementation to crypto crc32c
      libcrc32c: Add crc32c_le macro
      libcrc32c: Select CRYPTO in Kconfig
      crypto: hash - Make setkey optional
      crypto: null - Switch to shash
      crypto: rmd128 - Switch to shash
      crypto: rmd160 - Switch to shash
      crypto: rmd256 - Switch to shash
      crypto: rmd320 - Switch to shash
      crypto: aes - Precompute tables
      tcp: Always set urgent pointer if it's beyond snd_nxt
      ipsec: Remove useless ret variable
      gro: Fix potential use after free
      net: Fix percpu counters deadlock
      gro: Use gso_size to store MSS
      gro: Add page frag support
      gro: Add internal interfaces for VLAN
      vlan: Add GRO interfaces
      ipv6: Add GRO support
      tcp6: Add GRO support

Hermann Pitton (1):
      V4L/DVB (9798): saa7134: add analog and DVB-T support for Medion/Cr=
eatix CTX946

Herton Ronaldo Krzesinski (8):
      rtl8187: adapt for deprecated IEEE80211_CONF_SHORT_SLOT_TIME flag
      rtl8187: add short slot handling for 8187B
      rtl8187: fix 8187B throughput regression
      rtl8187: implement conf_tx callback to configure tx queues
      rtl8187: feedback transmitted packets using tx close descriptor for=
 8187B
      [CPUFREQ] add to speedstep-lib additional fsb values for core proce=
ssors
      [CPUFREQ] Add Celeron Core support to p4-clockmod.
      rtl8187: Fix crash on unload when using SLUB debug

Hidehiro Kawai (1):
      coredump_filter: permit changing of the default filter

Hidetoshi Seto (1):
      PCI hotplug: aerdrv: fix a typo in error message

Hirokazu Takahashi (1):
      memcg: add mem_cgroup_disabled()

Hiroshi Shimamoto (48):
      uaccess: fix parameters inversion for __copy_from_user_inatomic()
      x86: signal: cosmetic unification of restore_sigcontext()
      x86: signal_64.c: get_stack() doesn't need entire regs
      x86: signal: cosmetic unification of signr_convert()
      x86: signal: cosmetic unification of macros for setup_rt_frame()
      x86: signal: cosmetic unification of NR_restart_syscall
      x86: signal_64: remove unused code in __setup_rt_frame()
      x86: signal_32: do save_i387_xstate() at get_sigframe()
      x86: ia32_signal: do save_i387_xstate_ia32 at get_sigframe()
      x86: signal_64: setup fpstate in setup_sigcontext()
      x86: signal_64: make setup_sigcontext() similar
      x86: signal: cosmetic unification of setup_sigcontext()
      x86: signal_32: introduce retcode and rt_retcode
      x86: ia32_signal: remove unnecessary padding
      x86: ia32_signal: cleanup macro COPY
      x86: ia32_signal: introduce COPY_SEG_CPL3
      x86: ia32_signal: cleanup macro RELOAD_SEG
      x86: ia32_signal: remove using temporary variable
      x86: ia32_signal: change order of storing in setup_sigcontext()
      x86: signal: rename COPY_SEG_STRICT to COPY_SEG_CPL3
      x86: signal: cosmetic unification of including headers
      x86: signal: cosmetic unification of sys_sigaltstack()
      x86: signal: cosmetic unification of sys_rt_sigreturn()
      x86: signal: move {setup|restore}_sigcontext()
      x86: signal: cosmetic unification of __setup_sigframe() and __setup=
_rt_sigframe()
      x86: signal: unify signal_{32|64}.c, prepare
      x86: signal: unify signal_{32|64}.c
      x86: signal: change type of paramter for sys_rt_sigreturn()
      x86: uaccess: return value of __{get|put}_user() can be int
      x86: kill #ifdef for exit_idle()
      x86: hardirq: introduce inc_irq_stat()
      x86: hardirq: use inc_irq_stat() in non-unified functions
      x86: signal: use signal_fault() in sys_sigreturn()
      x86: ia32_signal: use __put_user() instead of __copy_to_user()
      x86: ia32_signal: use proper macro __USER32_DS
      x86: signal: move ia32 func declarations into arch/x86/kernel/signa=
l.c
      x86: signal: rename sigframe and rt_sigframe on 32-bit
      x86: signal: move sigframe.h to arch/x86/include/asm
      x86: signal: prepare to include from ia32_signal.c
      x86: ia32_signal: rename struct sigframe and rt_sigframe
      x86: ia32_signal: use sigframe.h
      x86: sigframe.h: add guard macro
      x86: sigframe.h: include headers for dependency
      x86: asm-offset_64: use rt_sigframe_ia32
      x86: ia32.h: remove unused struct sigfram32 and rt_sigframe32
      printk: fix discarding message when recursion_bug
      x86: ia32_signal: remove unnecessary declaration
      binfmts.h: include list.h

Hitoshi Mitake (1):
      x86: provide readq()/writeq() on 32-bit too

Holger Eitzenberger (23):
      bonding: add and use bond_is_lb()
      bonding: use table for mode names
      bonding: fix compile error if debug enabled
      bonding: use pr_debug instead of own macros
      bonding: remove duplicate declarations
      bonding: make tbl argument to bond_parse_parm() const
      bonding: turn all bond_parm_tbls const
      bonding: improve elaborate port_state assignment
      bonding: introduce and use port_params structure
      bonding: use port_params in __record_pdu()
      bonding: use plain memcpy in __record_default()
      bonding: init port_params from template
      bonding: remove various function declarations
      bonding: use port_params in __update_selected()
      bonding: use port_params in __update_default_selected()
      bonding: use port_params in __update_lacpdu_from_port
      802.3ad: make ntt bool
      802.3ad: turn ports is_enabled into a bool
      802.3ad: turn ports is_individual into a bool
      802.3ad: remove typedef around ad_system
      802.3ad: initialize ports LACPDU from const initializer
      802.3ad: generalize out mac address initializer
      802.3ad: use standard ethhdr instead of ad_header

Holger Schurig (1):
      wireless: fix two bad print_ssid conversions

Holger Smolinski (1):
      [S390] dasd: add device attribute to disable blocking on lost paths

Hollis Blanchard (30):
      powerpc: Remove superfluous WARN_ON() from dma-noncoherent.c
      powerpc/kvm: update KVM config options in ppc44x_defconfig
      powerpc: Force memory size to be a multiple of PAGE_SIZE
      virtio-pci queue allocation not page-aligned
      virtio: avoid implicit use of Linux page size in balloon interface
      KVM: ppc: Move 440-specific TLB code into 44x_tlb.c
      KVM: ppc: Rename "struct tlbe" to "struct kvmppc_44x_tlbe"
      KVM: ppc: combine booke_guest.c and booke_host.c
      KVM: ppc: Refactor powerpc.c to relocate 440-specific code
      ppc: Create disassemble.h to extract instruction fields
      KVM: ppc: refactor instruction emulation into generic and core-spec=
ific pieces
      KVM: ppc: Move the last bits of 44x code out of booke.c
      KVM: ppc: create struct kvm_vcpu_44x and introduce container_of() a=
ccessor
      KVM: ppc: adjust vcpu types to support 64-bit cores
      KVM: ppc: fix set regs to take care of msr change
      KVM: ppc: optimize kvm stat handling
      KVM: ppc: optimize find first bit
      KVM: ppc: optimize irq delivery path
      KVM: ppc: improve trap emulation
      KVM: ensure that memslot userspace addresses are page-aligned
      KVM: ppc: fix Kconfig constraints
      KVM: ppc: use MMUCR accessor to obtain TID
      KVM: ppc: use prefetchable mappings for guest memory
      KVM: ppc: fix userspace mapping invalidation on context switch
      KVM: ppc: support large host pages
      powerpc/44x: declare tlb_44x_index for use in C code
      KVM: ppc: directly insert shadow mappings into the hardware TLB
      KVM: ppc: save and restore guest mappings on context switch
      KVM: ppc: Implement in-kernel exit timing statistics
      KVM: ppc: mostly cosmetic updates to the exit timing accounting cod=
e

Hongjie Yang (1):
      [S390] convert dcssblk and extmem printks messages to pr_xxx macros.

Huang Weiyi (10):
      uwb: remove unused #include <version.h>
      wusb: remove unused #include <version.h>
      ALSA: ASoC codec: remove unused #include <version.h>
      V4L/DVB: remove unused #include <version.h>
      V4L/DVB: remove unused #include <version.h>
      net: KS8695: removed duplicated #include
      tracing: removed duplicated #include
      x86: remove duplicated #include's
      Staging: wlan-ng: remove unused #include <version.h>
      [S390] gettimeofday.S: removed duplicated #includes

Huang Ying (3):
      kexec/i386: remove PAGE_SIZE alignment from relocate_kernel
      kexec/i386: allocate page table pages dynamically
      kexec/i386: setup kexec page table in C

Hugh Blemings (1):
      Updated contact info for CREDITS file

Hugh Dickins (36):
      mm: don't mark_page_accessed in shmem_fault
      mm: remove cgroup_mm_owner_callbacks
      mm: remove GFP_HIGHUSER_PAGECACHE
      mm: add Set,ClearPageSwapCache stubs
      mm: replace some BUG_ONs by VM_BUG_ONs
      mm: add_active_or_unevictable into rmap
      mm: make page_lock_anon_vma() static
      mm: further cleanup page_add_new_anon_rmap
      mm: gup persist for write permission
      mm: wp lock page before deciding cow
      mm: reuse_swap_page replaces can_share_swap_page
      mm: try_to_free_swap replaces remove_exclusive_swap_page
      mm: try_to_unuse check removing right swap
      mm: remove try_to_munlock from vmscan
      mm: remove gfp_mask from add_to_swap
      mm: add add_to_swap stub
      mm: optimize get_scan_ratio for no swap
      swapfile: swapon needs larger size type
      swapfile: remove SWP_ACTIVE mask
      swapfile: remove surplus whitespace
      swapfile: remove v0 SWAP-SPACE message
      swapfile: rearrange scan and swap_info
      swapfile: swapon use discard (trim)
      swapfile: swap allocation use discard
      swapfile: swapon randomize if nonrot
      swapfile: swap allocation cycle if nonrot
      swapfile: change discard pgoff_t to sector_t
      swapfile: let others seed random
      badpage: simplify page_alloc flag check+clear
      badpage: keep any bad page out of circulation
      badpage: replace page_remove_rmap Eeek and BUG
      badpage: vm_normal_page use print_bad_pte
      badpage: zap print_bad_pte on swap and file
      badpage: remove vma from page_remove_rmap
      badpage: ratelimit print_bad_pte and bad_page
      badpage: KERN_ALERT BUG instead of KERN_EMERG

Hugo Villeneuve (3):
      ASoC: Add Right-Justified mode and Codec clock master to davinci-i2=
s
      ASoC: Add PCM3008 ALSA SoC driver
      ASoC: Add driver for the Lyrtech SFFSDR board

Ian Campbell (7):
      swiotlb: move some definitions to header
      swiotlb: add comment where we handle the overflow of a dma mask on =
32 bit
      swiotlb: allow architectures to override phys<->bus<->phys conversi=
ons
      swiotlb: add arch hook to force mapping
      swiotlb: consolidate swiotlb info message printing
      x86/swiotlb: add default phys<->bus conversion
      x86/swiotlb: add default swiotlb_arch_range_needs_mapping

Ian Kent (4):
      autofs4: improve parameter usage
      autofs4: fix var shadowed by local delaration
      autofs4: make autofs type usage explicit
      autofs4: fix string validation check order

Ian Molton (6):
      [ARM] IrDA support for e7xx
      [ARM] pxa: e740 MFP fix
      [ARM] pxa: Add multi-io support for e-series
      [PCMCIA] e740 PCMCIA socket driver.
      [ARM] pxa: Update eseries defconfig
      [ARM] pxa: add e750 MFP config

Igor M. Liplianin (7):
      V4L/DVB (9520): stb0899 Remove double .read_status assignment
      V4L/DVB (9533): cx88: Add support for TurboSight TBS8910 DVB-S PCI =
card
      V4L/DVB (9534): cx88: Add support for Prof 6200 DVB-S PCI card
      V4L/DVB (9535): cx88-dvb: Remove usage core->prev_set_voltage from =
cx24116 based cards.
      V4L/DVB (9537): Add TerraTec Cinergy S USB support
      V4L/DVB (9795): Add Compro VideoMate E650F (DVB-T part only).
      V4L/DVB (9797): Fix stv0299 support in dw2102 USB DVB-S/S2 driver

Ilpo J=C3=A4rvinen (45):
      b43legacy: reindent misleading statement
      tcp: collapse more than two on retransmission
      tcp: move tcp_simple_retransmit to tcp_input
      tcp: more aggressive skipping
      tcp: Make SACK code to split only at mss boundaries
      tcp: make tcp_sacktag_one able to handle partial skb too
      tcp: Try to restore large SKBs while SACK processing
      tcp: Make shifting not clear the hints
      tcp: add some mibs to track collapsing
      tcp: handle shift/merge of cloned skbs too
      tcp: tcp_limit_reno_sacked can become static
      tcp: skb_shift cannot cache frag ptrs past pskb_expand_head
      niu: use net_device_stats nowadays available in net_device
      bnx2: use net_device_stats nowadays available in net_device
      ne2: silence static never defined warnings
      dccp: use roundup instead of opencoding
      tcp: force mss equality with the next skb too.
      tcp: Fix thinko making the not-shiftable to cover S|R as well
      tcp: make mtu probe failure to not break gso'ed skbs unnecessarily
      tcp: introduce struct tcp_sacktag_state to reduce arg pressure
      tcp: no need to pass prev skb around, reduces arg pressure
      tcp: drop tcp_bound_rto, merge content of it tcp_set_rto
      tcp: share code through function, not through copy-paste. :-)
      tcp: move some parts from tcp_write_xmit
      tcp: use tcp_write_xmit also in tcp_push_one
      tcp: fix tso_should_defer in 64bit
      icsk: join error paths using goto
      xfrm6_tunnel: join error paths using goto
      ipv6/mcast: join error paths using goto
      ip6mr: use goto to common label instead of opencoding
      xfrm: join error paths
      can: merge error paths
      ax25: join the return paths that free skb
      bt/rfcomm/tty: join error paths
      irda: merge exit paths
      nf/dccp: merge errorpaths
      rpc/rdma: goto instead of copypaste
      hp100: use roundup instead of open coding
      ipmr: merge common code
      libertas: use roundup instead of opencoding
      [SCSI] tmscsim: fix indentation and braces disagreement - add brace=
s
      [SCSI] scsi_error: fix indentation and braces disagreement - add br=
aces
      ipv6: IPV6_PKTINFO relied userspace providing correct length
      consolemap: indentation & braces disagree - reindent
      USB: usbtmc: indent & braces disagree, something else is desired

Ilya Yanok (1):
      powerpc/44x: Support 16K/64K base page sizes on 44x

Inaky Perez-Gonzalez (35):
      USB: Introduce usb_queue_reset() to do resets from atomic contexts
      debugfs: add helpers for exporting a size_t simple value
      wimax: documentation for the stack
      wimax: headers for kernel API and user space interaction
      wimax: internal API for the kernel space WiMAX stack
      wimax: debug macros and debug settings for the WiMAX stack
      wimax: generic device management (registration, deregistration, loo=
kup)
      genetlink: export genl_unregister_mc_group()
      wimax: basic API: kernel/user messaging, rfkill and reset
      wimax: debugfs controls
      wimax: Makefile, Kconfig and docbook linkage for the stack
      i2400m: documentation and instructions for usage
      i2400m: host/device procotol and core driver definitions
      i2400m: Generic probe/disconnect, reset and message passing
      i2400m: linkage to the networking stack
      i2400m: firmware loading and bootrom initialization
      i2400m: RX and TX data/control paths
      i2400m: various functions for device management
      i2400m: debugfs controls
      i2400m/USB: header for the USB bus driver
      i2400m/USB: probe/disconnect, dev init/shutdown and reset backends
      i2400m/USB: firmware upload backend
      i2400m/USB: TX and RX path backends
      i2400m/SDIO: header for the SDIO subdriver
      i2400m/SDIO: probe/disconnect, dev init/shutdown and reset backends
      i2400m/SDIO: firmware upload backend
      i2400m/SDIO: TX and RX path backends
      i2400m: Makefile and Kconfig
      wimax: export linux/wimax.h and linux/wimax/i2400m.h with headers_i=
nstall
      wimax/i2400m: add CREDITS and MAINTAINERS entries
      wimax: fix '#ifndef CONFIG_BUG' layout to avoid warning
      wimax: fix kconfig interactions with rfkill and input layers
      wimax: testing for rfkill support should also test for CONFIG_RFKIL=
L_MODULE
      i2400m/usb: wrap USB power saving in #ifdef CONFIG_PM
      wimax: fix kernel-doc for debufs_dentry member of struct wimax_dev

Ingo Brueckl (2):
      x86: convert permanent_kmaps_init() from macro to inline
      Fix compiler warning in arch/x86/mm/init_32.c

Ingo Molnar (232):
      x86: boot IRQ quirks and rerouting, fix
      Merge branch 'linus' into x86/pci-ioapic-boot-irq-quirks
      Merge branch 'linus' into x86/pci-ioapic-boot-irq-quirks
      softlockup: increase hung tasks check from 2 minutes to 8 minutes
      Merge branch 'linus' into core/debug
      Merge commit 'v2.6.27-rc6' into core/locking
      x86: some lock annotations for user copy paths, v3
      Revert "lockdep: fix compilation when CONFIG_TRACE_IRQFLAGS_SUPPORT=
 is not set"
      Merge commit 'v2.6.27-rc7' into core/locking
      Merge commit 'v2.6.28-rc2' into x86/uv
      Merge commit 'v2.6.28-rc2' into x86/pci-ioapic-boot-irq-quirks
      Merge commit 'v2.6.28-rc2' into x86/doc
      Merge commit 'v2.6.28-rc2' into core/locking
      Merge branch 'linus' into tracing/ftrace
      Merge commit 'v2.6.28-rc3' into sched/core
      Merge commit 'v2.6.28-rc3' into tracing/ftrace
      Merge branches 'tracing/ftrace', 'tracing/markers', 'tracing/mmiotr=
ace', 'tracing/nmisafe', 'tracing/tracepoints' and 'tracing/urgent' into =
tracing/core
      rcu: make rcu-stall debug printout more standard
      x86 debug: mark early_printk.o as notrace
      Merge branch 'tracing/fastboot' into tracing/ftrace
      Merge branch 'sched/urgent' into sched/core
      Merge branches 'tracing/ftrace', 'tracing/fastboot', 'tracing/nmisa=
fe' and 'tracing/urgent' into tracing/core
      Merge branch 'linus' into x86/cleanups
      x86: clean up rdtsc_barrier() use
      x86: clean up vget_cycles()
      Merge commit 'v2.6.28-rc4' into x86/cleanups
      Merge commit 'v2.6.28-rc4' into timers/rtc
      Merge commit 'v2.6.28-rc4' into x86/apic
      sched: rename SCHED_NO_NO_OMIT_FRAME_POINTER =3D> SCHED_OMIT_FRAME_=
POINTER
      Merge branch 'tracing/urgent' into tracing/ftrace
      Merge branches 'tracing/ftrace' and 'tracing/urgent' into tracing/c=
ore
      tracing, x86: clean up FUNCTION_RET_TRACER Kconfig
      tracing, x86: function return tracer, fix assembly constraints
      tracing: function return tracer, build fix
      x86: fix documentation typo in arch/x86/Kconfig
      Merge branches 'tracing/ftrace' and 'tracing/urgent' into tracing/c=
ore
      Merge branch 'tracing/function-return-tracer' into tracing/fastboot
      Merge branches 'tracing/fastboot', 'tracing/function-return-tracer'=
 and 'tracing/ring-buffer' into tracing/core
      tracing: branch tracer, tweak output
      Merge branch 'linus' into core/locking
      lockdep: include/linux/lockdep.h - fix warning in net/bluetooth/af_=
bluetooth.c
      tracing: branch tracer, fix vdso crash
      tracing: finetune branch-tracer output
      Merge branch 'linus' into x86/crashdump
      Merge branches 'tracing/branch-tracer', 'tracing/fastboot', 'tracin=
g/function-return-tracer' and 'tracing/urgent' into tracing/core
      Merge branches 'tracing/fastboot', 'tracing/ftrace' and 'tracing/ur=
gent' into tracing/core
      Merge branch 'tracing/ftrace' into tracing/function-return-tracer
      tracepoints: format documentation
      markers/tracpoints: fix non-modular build
      Merge branches 'tracing/branch-tracer', 'tracing/ftrace', 'tracing/=
function-return-tracer', 'tracing/tracepoints' and 'tracing/urgent' into =
tracing/core
      Merge commit 'v2.6.28-rc5' into x86/cleanups
      Merge branches 'tracing/branch-tracer' and 'tracing/urgent' into tr=
acing/core
      Merge branch 'x86/urgent' into x86/cleanups
      x86: fix wakeup_cpu with numaq/es7000, v2, fix #2
      Merge branch 'linus' into sched/core
      ftrace: fix selftest locking
      Merge branches 'tracing/ftrace' and 'tracing/urgent' into tracing/c=
ore
      Merge branch 'linus' into x86/uv
      Merge branch 'linus' into x86/memory-corruption-check
      Merge branch 'x86/cleanups' into x86/irq
      Merge commit 'v2.6.28-rc6' into sched/core
      x86: clean up after: move entry_64.S register saving out of the mac=
ros, fix
      x86: entry_64.S: rename
      Merge commit 'v2.6.28-rc6' into x86/debug
      x86: clean up stack overflow debug check
      Merge branches 'tracing/profiling', 'tracing/options' and 'tracing/=
urgent' into tracing/core
      tracing/function-return-tracer: clean up task start/exit callbacks
      tracing: allow tracing of suspend/resume & hibernation code again
      Merge branch 'ppc/ftrace' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/rostedt/linux-2.6-trace into tracing/powerpc
      x86 defconfig: increase CONFIG_LOG_BUF_SHIFT
      Merge branch 'sched/rt' into sched/core
      Merge branches 'core/debug', 'core/futexes', 'core/locking', 'core/=
rcu', 'core/signal', 'core/urgent' and 'core/xen' into core/core
      Merge branches 'tracing/branch-tracer', 'tracing/fastboot', 'tracin=
g/ftrace', 'tracing/function-return-tracer', 'tracing/power-tracer', 'tra=
cing/powerpc', 'tracing/ring-buffer', 'tracing/stack-tracer' and 'tracing=
/urgent' into tracing/core
      Merge branches 'sched/core', 'core/core' and 'tracing/core' into cp=
us4096
      tracing, tty: fix warnings caused by branch tracing and tty_kref_ge=
t()
      x86: fix unused variable warning in arch/x86/kernel/hpet.c
      lockdep: fix unused function warning in kernel/lockdep.c
      Merge branches 'tracing/core', 'x86/urgent' and 'x86/ptrace' into t=
racing/hw-branch-tracing
      netfilter: fix warning in net/netfilter/nf_conntrack_proto_tcp.c
      netfilter: fix warning in net/netfilter/nf_conntrack_ftp.c
      s2io: fix warning in drivers/net/s2io.c
      niu: fix warnings in drivers/net/niu.c
      niu: fix another warning in drivers/net/niu.c
      qla3xxx: fix warning in drivers/net/qla3xxx.c
      sunrpc: fix warning in net/sunrpc/xprtrdma/svc_rdma_transport.c
      pkt_sched: fix warning in net/sched/sch_hfsc.c
      ipv6: fix warning in net/ipv6/ip6_flowlabel.c
      dsa: fix warning in net/dsa/mv88e6xxx.c
      dsa: fix warning in net/dsa/mv88e6060.c
      fix warning in fs/dlm/netlink.c
      sis900: fix warning in drivers/net/sis900.c
      z85230: fix warning in drivers/net/wan/z85230.c
      mlx4: fix error path in drivers/net/mlx4/en_rx.c
      cassini: fix warning in drivers/net/cassini.c
      dccp: fix warning in net/dccp/options.c
      mlx4: fix warning in drivers/net/mlx4/mcg.c
      Merge branches 'tracing/hw-branch-tracing' and 'tracing/branch-trac=
er' into tracing/core
      ax25: fix warning in net/ax25/sysctl_net_ax25.c
      sunrpc: fix warning in net/sunrpc/xprtrdma/verbs.c
      bluetooth: fix warning in net/bluetooth/rfcomm/sock.c
      atlx: fix warning in drivers/net/atlx/atl2.c
      depca: fix warning in drivers/net/depca.c
      3c523: fix warning in drivers/net/3c523.c
      tracing: function graph tracer, fix
      Merge commit 'v2.6.28-rc6' into core/debug
      debugobjects: add boot parameter default value
      blktrace: port to tracepoints, update
      sched: convert struct root_domain to cpumask_var_t, fix
      Merge branches 'tracing/blktrace', 'tracing/ftrace', 'tracing/funct=
ion-graph-tracer' and 'tracing/power-tracer' into tracing/core
      tracing/function-graph-tracer: more output tweaks
      Merge branch 'x86/debug' into x86/irq
      x86: ret_from_fork - get rid of jump back
      debug warnings: eliminate warn_on_slowpath()
      vfs, seqfile: export mangle_path() generally
      Merge branch 'sched/urgent' into sched/core
      x86: provide readq()/writeq() on 32-bit too, cleanup
      x86: provide readq()/writeq() on 32-bit too, complete
      Merge branch 'x86/urgent' into x86/iommu
      Merge branch 'tracing/urgent' into tracing/core
      Merge branches 'tracing/branch-tracer', 'tracing/ftrace', 'tracing/=
function-graph-tracer', 'tracing/markers', 'tracing/powerpc', 'tracing/st=
ack-tracer' and 'tracing/tracepoints' into tracing/core
      Merge branch 'linus' into cpus4096
      Merge branch 'x86/io' into x86/iommu
      Merge branches 'tracing/ftrace' and 'tracing/function-graph-tracer'=
 into tracing/core
      Merge commit 'v2.6.28-rc7'; branch 'x86/dumpstack' into tracing/ftr=
ace
      tracing/function-graph-tracer: enabled by default
      Merge commit 'v2.6.28-rc7' into core/locking
      Merge commit 'v2.6.28-rc7' into tracing/core
      Merge branches 'tracing/ftrace' and 'tracing/function-graph-tracer'=
 into tracing/core
      tracing: fix typo and missing inline function
      Merge commit 'v2.6.28-rc7' into x86/cleanups
      Merge branches 'tracing/ftrace', 'tracing/function-graph-tracer' an=
d 'tracing/urgent' into tracing/core
      Merge branch 'sched/urgent' into sched/core
      Merge branch 'linus' into x86/quirks
      tracing/function-graph-tracer: fix 'flags' variable mismatch
      sparseirq: fix typo in !CONFIG_IO_APIC case
      Merge branches 'tracing/function-graph-tracer' and 'tracing/ring-bu=
ffer' into tracing/core
      x86, bts: fix build error
      x86: soften multi-BAR mapping sanity check warning message
      oprofile: select RING_BUFFER
      Merge commit 'v2.6.28-rc8' into sched/core
      x86, debug: remove EBDA debug printk
      Merge commit 'v2.6.28-rc8' into x86/mm
      Merge commit 'v2.6.28-rc8' into x86/irq
      tracing/function-graph-tracer: add a new .irqentry.text section, fi=
x
      sparse irqs: handle !GENIRQ platforms
      sparse irqs: add irqnr.h to the user headers list
      Merge branch 'tracing/fastboot' into cpus4096
      Merge branch 'sched/core' into cpus4096
      Merge branches 'irq/sparseirq', 'x86/quirks' and 'x86/reboot' into =
cpus4096
      Merge branches 'tracing/fastboot', 'tracing/ftrace', 'tracing/funct=
ion-graph-tracer' and 'tracing/hw-branch-tracing' into tracing/core
      Merge branch 'linus' into cpus4096
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/rusty/linux-2.6-for-ingo into cpus4096
      x86, mm: limit MAXMEM on 64-bit
      Merge commit 'v2.6.28-rc8' into x86/cpufeature
      x86: support always running TSC on Intel CPUs, add cpufeature defin=
ition
      Merge branch 'x86/cpufeature' into x86/tsc
      Merge commit 'v2.6.28-rc8' into x86/doc
      Merge commit 'v2.6.28-rc8' into x86/uv
      Merge branch 'linus' into cpus4096
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/travis/linux-2.6-cpus4096-for-ingo into cpus4096
      Merge branch 'irq/sparseirq' into cpus4096
      Merge branch 'x86/crashdump' into cpus4096
      x86: update io_apic.c to the new cpumask code
      Merge branch 'linus' into cpus4096
      Merge branch 'x86/apic' into cpus4096
      Merge branches 'tracing/ftrace' and 'tracing/hw-branch-tracing' int=
o tracing/core
      Merge branch 'linus' into core/rcu
      hrtimers: fix warning in kernel/hrtimer.c
      tracing: fix warning in kernel/trace/trace.c
      tracing: fix warnings in kernel/trace/trace_sched_switch.c
      x86: fix warning in arch/x86/kernel/microcode_amd.c
      sched: move test_sd_parent() to an SMP section of sched.h
      sched: fix warning in kernel/sched.c
      x86: fix warning in arch/x86/kernel/io_apic.c
      Merge branches 'tracing/ftrace', 'tracing/ring-buffer' and 'tracing=
/urgent' into tracing/core
      sched: fix warning in fs/proc/base.c
      Merge commit 'v2.6.28-rc9' into x86/apic
      Merge branch 'x86/apic' into x86/irq
      Merge branches 'x86/apic', 'x86/cleanups', 'x86/cpufeature', 'x86/c=
rashdump', 'x86/debug', 'x86/defconfig', 'x86/detect-hyper', 'x86/doc', '=
x86/dumpstack', 'x86/early-printk', 'x86/fpu', 'x86/idle', 'x86/io', 'x86=
/memory-corruption-check', 'x86/microcode', 'x86/mm', 'x86/mtrr', 'x86/nm=
i-watchdog', 'x86/pat2', 'x86/pci-ioapic-boot-irq-quirks', 'x86/ptrace', =
'x86/quirks', 'x86/reboot', 'x86/setup-memory', 'x86/signal', 'x86/sparse=
-fixes', 'x86/time', 'x86/uv' and 'x86/xen' into x86/core
      Merge branch 'x86/ptrace' into x86/tsc
      Merge branch 'x86/tsc' into x86/core
      Merge branch 'x86/iommu' into x86/core
      Merge branch 'x86/irq' into x86/core
      x86: export vector_used_by_percpu_irq
      Merge branch 'linus' into tracing/hw-branch-tracing
      Revert "x86: disable X86_PTRACE_BTS"
      crypto: testmgr - Fix error flow of test_comp
      rcu: provide RCU options on non-preempt architectures too
      stacktrace: provide save_stack_trace_tsk() weak alias
      Merge branches 'x86/pat2' and 'x86/fpu'; commit 'v2.6.28' into x86/=
core
      x86: turn CONFIG_SPARSE_IRQ off by default
      Merge branch 'x86/tsc' into tracing/core
      Merge branches 'tracing/ftrace', 'tracing/hw-branch-tracing' and 't=
racing/ring-buffer'; commit 'v2.6.28' into tracing/core
      Merge branch 'sched/urgent'; commit 'v2.6.28' into sched/core
      Merge commit 'v2.6.28' into core/core
      Merge branch 'core/debug' into core/core
      Merge branch 'core/futexes' into core/core
      Merge branches 'core/debugobjects', 'core/iommu', 'core/locking', '=
core/printk', 'core/rcu', 'core/resources', 'core/softirq' and 'core/stac=
ktrace' into core/core
      x86, sparseirq: clean up Kconfig entry
      Merge branches 'irq/sparseirq', 'irq/genirq' and 'irq/urgent'; comm=
it 'v2.6.28' into irq/core
      Merge branches 'timers/clocksource', 'timers/hpet', 'timers/hrtimer=
s', 'timers/nohz', 'timers/ntp', 'timers/posixtimers' and 'timers/rtc' in=
to timers/core
      Merge branch 'x86/fpu' into x86/cleanups
      x86: clean up comment style in arch/x86/kernel/traps.c
      sparseirq: do not printk when migrating IRQ descriptors
      sparseirq: fix desc->lock init
      Merge branch 'x86/core' into x86/cleanups
      sparseirq: work around __weak alias bug
      Merge branch 'linus' into x86/cleanups
      kbuild: Remove gcc 4.1.0 quirk from init/main.c
      Disallow gcc versions 3.{0,1}
      Merge branch 'linus' into x86/cleanups
      Merge branches 'x86/cleanups', 'x86/fpu' and 'x86/urgent' into x86/=
core
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/rusty/linux-2.6-cpumask into cpus4096-v2
      cpumask: convert RCU implementations, fix
      ia64: cpumask fix for is_affinity_mask_valid()
      Merge branch 'linus' into core/urgent
      intel-iommu: fix build error with INTR_REMAP=3Dy and DMAR=3Dn
      Merge branch 'linus' into sched/urgent
      hrtimer: splitout peek ahead functionality, fix
      Merge branch 'core/iommu' into core/urgent
      genirq: provide irq_to_desc() to non-genirq architectures too
      Merge branch 'linus' into cpus4096
      Merge branches 'core/futexes', 'core/locking', 'core/rcu' and 'linu=
s' into core/urgent
      Merge branches 'sched/clock', 'sched/cleanups' and 'linus' into sch=
ed/urgent
      [IA64] fix typo in cpumask_of_pcibus()
      Merge branches 'x86/cleanups', 'x86/mpparse', 'x86/numa' and 'x86/u=
v' into x86/urgent
      x86: offer frame pointers in all build modes
      PCI: Don't carp about BAR allocation failures in quiet boot
      powerpc: Use correct type in prom_init.c
      powerpc/cell: Use correct types in beat files
      powerpc/cell: Fix some u64 vs. long types
      powerpc/pasemi: local_irq_save uses an unsigned long

Ira Snyder (1):
      hwmon: Add LTC4245 driver

Isaku Yamahata (3):
      xen: portability clean up and some minor clean up for xencomm.c
      xen: compilation fix fo xen CPU hotplugging
      xen: compilation fix of drivers/xen/events.c on IA64

Ivan Kuten (1):
      mac80211: fix unaligned access in ieee80211_wep_encrypt_data

Ivan Vecera (1):
      x86: call machine_shutdown and stop all CPUs in native_machine_halt

Ivo van Doorn (26):
      rt2x00: Optimize configuration handling
      rt2x00: Remove ieee80211_bss_conf from rt2x00_intf
      rt2x00: Improve interface_modes initialization
      rt2x00: Release rt2x00 2.2.2
      rt2x00: Remove debugfs CSR access wrappers
      rt2x00: Remove RATE_BASIC flag
      rt2x00: Fix LED state handling
      rt2x00: Block set_key() during suspend/shutdown
      rt2x00: Fix BUG_ON() with antenna handling
      rt2x00: Cleanup TX/RX entry handling
      rt2x00: Optimize get_duration / get_duration_res
      rt2x00: Fix race condition when using inderect registers
      rt2x00: Cleanup indirect register access
      rt2x00: Move rt73usb register access wrappers into rt2x00usb
      rt2x00: Fix TX failure path
      rt2x00: Detect USB BULK in/out endpoints
      rt2x00: Don't switch off LED on initialization
      rt2x00: Optimize IV/EIV handling
      rt2x00: Store retry limit values
      rt2x00: Remove duplicate code
      rt2x00: Implement HW encryption (rt2500usb)
      rt2x00: Release rt2x00 2.2.3
      rt2x00: Add RXDONE_CRYPTO_IV/ICV flags
      rt2x00: Fix check for BSS info changes
      rt2x00: Move crypto TX descriptor handling to rt2x00crypto.c
      rt2x00: Correctly initialize AID during set_key()

Izik Eidus (1):
      KVM: MMU: Fix aliased gfns treated as unaliased

J. Bruce Fields (4):
      nfsd: update fh_verify description
      nfsd: document new filehandle fsid types
      nfsd: Ensure nfsv4 calls the underlying filesystem on LOCKT
      nfsd: fix double-locks of directory mutex

J.R. Mauro (11):
      Staging: sxg: remove typedefs
      Staging: sxg: break the build in a cleaner way when !x86
      Staging: sxg: update README
      Staging: echo: remove typedefs
      Staging: echo: Lindent drivers/staging/echo
      Staging: et131x: fix build failure
      Staging: otus: fix name clash
      Staging: rt2860: use standard bit-reverse function
      Staging: comedi: fix build if CONFIG_PROC_FS is not set
      Staging: android: binder: Fix gcc warnings about improper format sp=
ecifiers for size_t in printk
      staging: android: binder: Fix use of euid

Jack Morgenstein (1):
      IB/mlx4: Set ownership bit correctly when copying CQEs during CQ re=
size

Jack Steiner (1):
      x86: UV fix for global physical addresses

Jacob Pan (1):
      PCI: avoid early PCI mmconfig init if pci=3Dnoearly is given in cmd=
line

Jaime Velasco Juan (1):
      V4L/DVB (9978): stkwebcam: Implement VIDIOC_ENUM_FRAMESIZES ioctl

Jakob Bornecrantz (1):
      drm: sanitise drm modesetting API + remove unused hotplug

Jakub Schmidtke (1):
      Staging: add asus_oled driver

James Bottomley (7):
      [SCSI] st: update to use block timeout
      [SCSI] remove timeout from struct scsi_device
      [SCSI] fcoe: fix incorrect use of struct module
      [SCSI] cxgb3i: fix select/depend problem
      [SCSI] fcoe: fix configuration problems
      [SCSI] scsi_lib: don't decrement busy counters when inserting comma=
nds
      [SCSI] scsi_lib: fix DID_RESET status problems

James Chapman (1):
      l2tp: fix UDP checksum support

James Morris (14):
      Merge branch 'master' into next
      security: remove broken and useless declarations
      Merge branch 'master' into next
      Merge branch 'master' into next
      Merge branch 'serge-next' into next
      Merge branch 'master' into next
      security: pass mount flags to security_sb_kern_mount()
      SELinux: don't check permissions for kernel mounts
      Merge branch 'next' into for-linus
      Merge branch 'next' into for-linus
      keys: fix sparse warning by adding __user annotation to cast
      Merge branch 'master' of git://git.infradead.org/users/pcmoore/lbln=
et-2.6_next into next
      Revert "CRED: Fix regression in cap_capable() as shown up by sys_fa=
ccessat() [ver #2]"
      Merge branch 'next' into for-linus

James Smart (17):
      [SCSI] lpfc 8.3.0 : Rework RSCN netlink event to send entire RSCN p=
ayload
      [SCSI] lpfc 8.3.0 : Add support for Power Management Suspend/Resume=
 operations
      [SCSI] lpfc 8.3.0 : Add kernel-doc headers to lpfc_scsi.c
      [SCSI] lpfc 8.3.0 : Fix system crash due to uninitialized node acce=
ss
      [SCSI] lpfc 8.3.0 : Fix multiple NPIV issues
      [SCSI] lpfc 8.3.0 : Added 3 small features and improve PCI EEH supp=
ort
      [SCSI] lpfc 8.3.0 : Fix issue with assumed Interrupt Enable Block s=
upport
      [SCSI] lpfc 8.3.0 : Fix several minor issues
      [SCSI] lpfc 8.3.0 : Add active interrupt test for enabling MSI/MSI-=
X/INTx
      [SCSI] lpfc 8.3.0 : Fix some memory handling issues
      [SCSI] lpfc 8.3.0 : Add BlockGuard support (T10-DIF) structs and de=
fs
      [SCSI] lpfc 8.3.0 : Add BlockGuard support (T10-DIF) code
      [SCSI] lpfc 8.3.0 : Hook lpfc's debugfs into Kconfig
      [SCSI] lpfc 8.3.0 : Update driver version to 8.3.0
      [SCSI] fc transport: pre-emptively terminate i/o upon dev_loss_tmo =
timeout
      [SCSI] lpfc : correct printk types on PPC compiles
      [SCSI] fc transport: restore missing dev_loss_tmo callback to LLDD

Jan Beulich (10):
      x86: simplify X86_MPPARSE config option
      x86: add two missing unwind annotations
      x86: consolidate __swp_XXX() macros
      allow bug table entries to use relative pointers (and use it on x86=
-64)
      x86, 32-bit: simplify alloc_low_page()
      x86, 32-bit: add some compile time checks to mem_init()
      x86, 32-bit: improve lazy TLB handling code
      kbuild: strip generated symbols from *.ko
      allow stripping of generated symbols under CONFIG_KALLSYMS_ALL
      init/main.c: mark late_time_init as __initdata

Jan Blunck (1):
      memcg: reduce size of mem_cgroup by using nr_cpu_ids

Jan Engelhardt (3):
      Btrfs: Simplify makefile
      Btrfs: bdi_init and bdi_destroy come with 2.6.23
      include: linux/fs.h: put declarations in __KERNEL__

Jan Glauber (8):
      [S390] qdio: fix qeth port count detection
      [S390] qdio: add eqbs/sqbs instruction counters
      [S390] qdio: fix compile warning under 31 bit
      [S390] qdio: rework debug feature logging
      [S390] qdio: improve inbound buffer acknowledgement
      [S390] qdio: fix error reporting for hipersockets
      [S390] convert cpacf printks to pr_xxx macros.
      [S390] qdio: fix broken pointer in case of CONFIG_DEBUG_FS is disab=
led

Jan Kara (36):
      quota: Add callbacks for allocating and destroying dquot structures
      quota: Increase size of variables for limits and inode usage
      quota: Remove bogus 'optimization' in check_idq() and check_bdq()
      quota: Make _SUSPENDED just a flag
      quota: Allow to separately enable quota accounting and enforcing li=
mits
      ext3: Use sb_any_quota_loaded() instead of sb_any_quota_enabled()
      ext4: Use sb_any_quota_loaded() instead of sb_any_quota_enabled()
      reiserfs: Use sb_any_quota_loaded() instead of sb_any_quota_enabled=
().
      quota: Remove compatibility function sb_any_quota_enabled()
      quota: Introduce DQUOT_QUOTA_SYS_FILE flag
      quota: Move quotaio_v[12].h from include/linux/ to fs/
      quota: Split off quota tree handling into a separate file
      quota: Convert union in mem_dqinfo to a pointer
      quota: Allow negative usage of space and inodes
      quota: Keep which entries were set by SETQUOTA quotactl
      quota: Update version number
      quota: Add helpers to allow ocfs2 specific quota initialization, fr=
eeing and recovery
      quota: Implement function for scanning active dquots
      ocfs2: Support nested transactions
      ocfs2: Assign feature bits and system inodes to quota feature and q=
uota files
      ocfs2: Mark system files as not subject to quota accounting
      ocfs2: Implementation of local and global quota file handling
      ocfs2: Add quota calls for allocation and freeing of inodes and spa=
ce
      ocfs2: Implement quota recovery
      ocfs2: Enable quota accounting on mount, disable on umount
      ocfs2: Add missing initialization
      ocfs2: Fix oops when extending quota files
      ocfs2: Make ocfs2_get_quota_block() consistent with ocfs2_read_quot=
a_block()
      ocfs2: Fix build warnings (64-bit types vs long long)
      quota: Unexport dqblk_v1.h and dqblk_v2.h
      quota: Export dquot_alloc() and dquot_destroy() functions
      reiserfs: Add default allocation routines for quota structures
      ext3: Add default allocation routines for quota structures
      ext4: Add default allocation routines for quota structures
      jbd2: Fix oops in jbd2_journal_init_inode() on corrupted fs
      quota: don't set grace time when user isn't above softlimit

Jan Kiszka (17):
      KVM: VMX: include all IRQ window exits in statistics
      KVM: VMX: Use INTR_TYPE_NMI_INTR instead of magic value
      KVM: VMX: Support for NMI task gates
      KVM: x86: Reset pending/inject NMI state on CPU reset
      KVM: VMX: refactor/fix IRQ and NMI injectability determination
      KVM: VMX: refactor IRQ and NMI window enabling
      KVM: VMX: fix real-mode NMI support
      KVM: x86: Enable NMI Watchdog via in-kernel PIT source
      KVM: x86: VCPU with pending NMI is runnabled
      KVM: Kick NMI receiving VCPU
      KVM: x86: Support for user space injected NMIs
      KVM: VMX: Provide support for user space injected NMIs
      KVM: VMX: work around lacking VNMI support
      KVM: x86: Fix and refactor NMI watchdog emulation
      KVM: x86: Optimize NMI watchdog delivery
      KVM: VMX: Fix pending NMI-vs.-IRQ race for user space irqchip
      KVM: x86: Rework user space NMI injection as KVM_CAP_USER_NMI

Janne Kulmala (1):
      x86: enable HPET on Fujitsu u9200

Jarek Poplawski (25):
      pkt_sched: sch_generic: Add Qdisc_ops peek() method.
      pkt_sched: sch_generic: Add generic qdisc->ops->peek() implementati=
on.
      pkt_sched: Add qdisc->ops->peek() implementation.
      pkt_sched: Use qdisc->ops->peek() instead of ->dequeue() & ->requeu=
e()
      pkt_sched: Add peek emulation for non-work-conserving qdiscs.
      sch_netem: Remove classful functionality
      sch_netem: Replace ->requeue() method with open code
      pkt_sched: sch_generic: Kfree gso_skb in qdisc_reset()
      pkt_sched: Fix qdisc len in qdisc_peek_dequeued()
      pkt_sched: Remove qdisc->ops->requeue() etc.
      pkt_sched: sch_drr: Fix qlen in drr_drop()
      net: gen_estimator: Fix gen_kill_estimator() lookups
      pkt_sched: sch_api: Remove qdisc_list_lock
      pkt_sched: gen_estimator: Optimize gen_estimator_active()
      pkt_sched: sch_htb: Remove htb_class aprio field
      pkt_sched: sch_htb: Remove htb_sched nwc_hit field
      pkt_sched: sch_htb: Clean htb_class prio and quantum fields
      pkt_sched: sch_htb: Remove L2T()
      pkt_sched: sch_htb: Replace HTB_ACCNT() macro with inlines
      pkt_sched: sch_htb: Optimize htb_find_next_upper()
      pkt_sched: sch_htb: Optimize WARN_ONs in htb_dequeue_tree() etc.
      pkt_sched: Annotate uninitialized var in sfq_enqueue()
      net: Fix oops in dev_ifsioc()
      pkt_sched: Remove smp_wmb() in qdisc_watchdog()
      pkt_sched: cls_u32: Fix locking in u32_change()

Jarkko Lavinen (1):
      mmc: Add 8-bit bus width support

Jarkko Nikula (14):
      ASoC: Fix supported sample rates of TWL4030 audio codec
      ASoC: OMAP: Add more supported sample rates into McBSP DAI driver
      ASoC: OMAP: Fix preprocessor filled DAI name in McBSP DAI
      i2c-omap: Do not use interruptible wait call in omap_i2c_xfer_msg
      ASoC: OMAP: Apply channel constrains to N810 machine driver
      ASoC: OMAP: Add support for mono audio links in McBSP DAI
      ARM: OMAP: Extend gpio label column width in omap_gpio debugfs file
      ARM: OMAP: make legacy gpio request/free calls superfluous
      ARM: OMAP: Switch to gpio_request/free calls
      ARM: OMAP: Switch ohci-omap to gpio_request/free calls
      ARM: OMAP3: Add OMAP34xx pin multiplexing into I2C bus registration=
 helper
      ASoC: Fix incorrect DSP format in OMAP McBSP DAI and affected drive=
rs
      ASoC: Fix DSP formats in SSM2602 audio codec
      ASoC: OMAP: Select OMAP pin multiplexing when using Nokia N810 ASoC=
 drivers

Jarod Wilson (3):
      crypto: ansi_cprng - Avoid incorrect extra call to _get_more_prng_b=
ytes
      crypto: ansi_cprng - fix inverted DT increment routine
      crypto: des3_ede - permit weak keys unless REQ_WEAK_KEY set

Jaroslav Kysela (6):
      ALSA: Release v1.0.18
      ALSA: Release v1.0.18a
      ALSA: add /sys/class/sound/card#/id (r/w) and card#/number (r/o) fi=
les
      ALSA: when card identification is changed, change also /proc/asound=
 symlink
      ALSA: hdsp/hdspm: remove card->id from rawmidi device name
      ALSA: include/sound/info.h - coding style changed

Jason Jin (1):
      [MTD] [NAND] Set the fsl elbc ECCM according the settings in bootlo=
ader.

Jason Wessel (1):
      tty: Fix sparse static warning for tty_driver_lookup_tty

Jaswinder Singh (14):
      x86: process_64.c declare __switch_to() and sys_arch_prctl before t=
hey get used
      x86: signal.c declare do_notify_resume before they get used
      x86: ldt.c declare sys_modify_ldt before they get used
      x86: setup.c find_and_reserve_crashkernel should be static
      avr32: Introducing asm/syscalls.h
      x86: time_64.c timer_interrupt() should be static
      x86: tls.c declare sys_set_thread_area and sys_get_thread_area befo=
re they get used
      x86: process.c declare c1e_remove_cpu before they get used
      x86: traps.c declare functions before they get used
      x86: common.c boot_cpu_stack and boot_exception_stacks should be st=
atic
      x86: traps.c replace #if CONFIG_X86_32 with #ifdef CONFIG_X86_32
      x86: reboot.c declare port_cf9_safe before they get used
      x86: apic.c x2apic_preenabled and disable_x2apic should be static
      firmware: convert acenic driver to request_firmware()

Jaswinder Singh Rajput (50):
      x86: introducing asm/sys_ia32.h
      x86: apic.c declare pic_mode before they get used
      x86: io_apic.c io_apic_sync should be static
      x86: efi.c declare add_efi_memmap before they get used
      x86_64: pci-gart_64.c iommu_fullflush should be static
      x86, pci: move arch/x86/pci/pci.h to arch/x86/include/asm/pci_x86.h
      x86: amd_iommu_init.c: iommu_enable and iommu_enable_event_logging =
should be static
      x86: amd_iommu.c: prealloc_protection_domains should be static
      x86: genx2apic_phys.c: x2apic_send_IPI_self and init_x2apic_ldr sho=
uld be static
      x86: bios_uv.c: uv_systab should be static
      sched: sched.c declare variables before they get used
      x86: apic.c: xapic_icr_read and x2apic_icr_read should be static
      x86: uv_bau.h: fix dubious bitfield
      x86: xsave.c: restore_user_xstate should be static
      x86: cpuid.c fix style problems
      x86: ldt.c fix style problems
      x86: nmi.c fix style problems
      x86: mpparse.c fix style problems
      AMD IOMMU: prealloc_protection_domains should be static
      x86: rename mp_config_table to mpc_table
      x86: rename mpc_config_bus to mpc_bus
      x86: rename mpc_config_processor to mpc_cpu
      x86: rename mpc_config_ioapic to mpc_ioapic
      x86: rename mpc_config_intsrc to mpc_intsrc
      x86: rename mpc_config_lintsrc to mpc_lintsrc
      x86: rename mpc_config_oemtable to mpc_oemtable
      x86: apic.c fix style problems
      x86: process_32.c fix style problems
      x86: traps.c fix style problems
      x86: irq.c fix style problems
      x86: irq_64.c fix style problems
      x86: time_32.c fix style problems
      x86: time_64.c fix style problems
      x86: ioport.c fix style problems
      x86: irq_32.c fix style problems
      x86: i8259.c fix style problems
      x86: irqinit_32.c fix style problems
      x86: irqinit_64.c fix style problems
      x86: setup_percpu.c fix style problems
      x86: irqinit_64.c init_ISA_irqs should be static
      firmware: convert tg3 driver to request_firmware()
      starfire: use request_firmware()
      x86: rename all fields of mpc_iopic mpc_X to X
      x86: rename all fields of mpc_lintsrc mpc_X to X
      x86: rename all fields of mpc_intsrc mpc_X to X
      x86: rename all fields of mpc_cpu mpc_X to X
      x86: rename all fields of mpc_bus mpc_X to X
      x86: rename all fields of mpc_oemtable oem_X to X
      x86: rename all fields of mpc_table mpc_X to X
      firmware: convert e100 driver to request_firmware()

Jay Fenlason (2):
      firewire: typo in comment
      firewire: improve refcounting of fw_card

Jay Sternberg (3):
      iwlwifi: define firmware file name once
      iwlwifi: expand error lookup and align output
      iwlwifi: indicate txpower is off in sysfs

Jay Vosburgh (3):
      bonding, net: Move last_rx update into bonding recv logic
      bonding: Fix ALB mode to balance traffic on VLANs
      bonding: alternate agg selection policies for 802.3ad

Jaya Kumar (5):
      Input: add support for Wacom W8001 penabled serial touchscreen
      ALSA: cs5535audio: turn off PCM properly if closing the audio devic=
e
      ALSA: cs5535audio: OLPC analog input support
      [ARM] 5337/1: gumstix: move am200 specific gpio pins into am200epd.
      [ARM] pxa/gumstix: fix incorrect init done by am200

Jean Delvare (13):
      ALSA: ASoC: Convert wm8580 to a new-style i2c driver
      ALSA: ASoC: Convert wm8900 to a new-style i2c driver
      i2c: Get rid of remaining bus_id access
      i2c: Drop I2C_CLASS_ALL
      i2c: Drop I2C_CLASS_CAM_ANALOG and I2C_CLASS_SOUND
      i2c: Drop I2C_CLASS_CAM_DIGITAL
      Input: apanel - convert to new i2c binding
      i2c: Use snprintf to set adapter names
      Blackfin arch: Fix typo (channel)
      hwmon: Don't overuse I2C_CLIENT_MODULE_PARM
      hwmon: Check for ACPI resource conflicts
      hwmon: Fix various typos
      USB: Convert ohci-pnx4008 to a new-style i2c driver

Jean-Francois Moine (62):
      V4L/DVB (9691): gspca: Some cleanups at device register
      V4L/DVB (9541): gspca: Add infrared control for sonixj - mi0360.
      V4L/DVB (9544): gspca: Clear the bulk endpoint at starting time whe=
n bulk transfer.
      V4L/DVB (9545): gspca: Add a flag for empty ISOC packets.
      V4L/DVB (9546): gspca: Bad scanning of ISOC packets in tv8532.
      V4L/DVB (9547): gspca: Version change.
      V4L/DVB (9552): gspca: Simplify the ISOC packet scanning in tv8532.
      V4L/DVB (9553): gspca: Webcam 145f:013a added in pac207.
      V4L/DVB (9561): gspca: Cleanup the source of ov519.
      V4L/DVB (9562): gspca: Set the default frame rate to 30 fps for sen=
sor ov764x in ov519.
      V4L/DVB (9565): gspca: Remove empty lines in traces.
      V4L/DVB (9560): gspca: Let gspca handle the webcam 0c45:602c instea=
d of sn9c102.
      V4L/DVB (9563): gspca: Let gspca handle the webcam 0471:0328 instea=
d of sn9c102.
      V4L/DVB (9680): gspca: Let gspca handle the webcam 0c45:613a instea=
d of sn9c102.
      V4L/DVB (9681): gspca: Rewrite the exchanges with the sensor ov7648=
 of sonixj.
      V4L/DVB (9688): gspca: Reset the bulk URB status before resubmittin=
g at irq level.
      V4L/DVB (9708): gspca: Do the sn9c105 - ov7660 work again in sonixj.
      V4L/DVB (9709): gspca: Fix typos and name errors in Kconfig.
      V4L/DVB (9711): gspca: Let gspca handle the webcams 045e:00f5 & 00f=
7 instead of sn9c102.
      V4L/DVB (9713): gspca: Add the ov534 webcams in the gspca documenta=
tion.
      V4L/DVB (9558): gspca: Add the light frequency control for the sens=
or HV7131B in zc3xx
      V4L/DVB (9710): gspca: Remove some unuseful core in main.
      V4L/DVB (9837): gspca: Simplify the brightness/contrast for ov76xx =
sensors in sonixj.
      V4L/DVB (9838): gspca: Delay when trying an other altsetting on str=
eaming start.
      V4L/DVB (9840): gspca: Simplify the pkt_scan of stk014.
      V4L/DVB (9841): gspca: Use msleep instead of mdelay.
      V4L/DVB (9842): gspca: Center the brightness in sonixj.
      V4L/DVB (9843): gspca: Change the colors and add the red and blue c=
ontrols in sonixj.
      V4L/DVB (9845): gspca: Add sensor mi0360 in vc032x.
      V4L/DVB (9846): gspca: Do the webcam microphone work when present.
      V4L/DVB (9847): gspca: Align the 640x480 and 320x240 init of tas513=
0 in zc3xx.
      V4L/DVB (9848): gspca: Webcam 06f8:3004 added in sonixj.
      V4L/DVB (9849): gspca: Add the webcam 0c45:613a in the gspca docume=
ntation.
      V4L/DVB (9850): gspca: Bad color control in sonixj.
      V4L/DVB (9852): gspca: Fix image problem at low resolutions with ov=
7660 in sonixj.
      V4L/DVB (9853): gspca: Webcam 093a:2622 added in pac7311.
      V4L/DVB (9854): gspca: Add the webcam 0c45:60fe in the gspca docume=
ntation.
      V4L/DVB (9861): gspca - ov534: Accept many simultaneous webcams.
      V4L/DVB (9863): gspca - sonixj: Cleanup / simplify code.
      V4L/DVB (9865): gspca - vc032x: Bad check of the sensor mi0360.
      V4L/DVB (9866): gspca - vc032x: V and H flips added for sensors ov7=
660 and 7670.
      V4L/DVB (9867): gspca - vc032x: Remove the autogain control.
      V4L/DVB (9868): gspca - zc3xx: Remove the duplicated register names
      V4L/DVB (9869): gspca - zc3xx: Change the USB exchanges for the sen=
sor pas202b.
      V4L/DVB (9870): gspca - vc032x: Webcam 15b8:6002 and sensor po1200 =
added.
      V4L/DVB (9871): gspca - vc032x: Bad detection of sensor mi0360.
      V4L/DVB (9879): gspca - vc032x: Remove the unused quality/qindex.
      V4L/DVB (9880): gspca - vc032x: Add V&H flips and sharpness control=
s for sensor po1200.
      V4L/DVB (9884): gspca - ov534: Fix a warning when compilation witho=
ut GSPCA_DEBUG.
      V4L/DVB (9984): gspca - pac7311: Webcam 093a:262c added.
      V4L/DVB (9985): gspca - spca561: Cleanup source.
      V4L/DVB (9986): gspca - spca561: Don't get the control values from =
the webcam.
      V4L/DVB (9987): gspca - spca561: Control changes for Rev72a.
      V4L/DVB (9988): gspca - spca561: Separate the bridge and sensor tab=
les of Rev72a
      V4L/DVB (9990): gspca - main: Remove useless tests of the buffer ty=
pe.
      V4L/DVB (9991): gspca - main: Check if a buffer has been queued on =
streamon.
      V4L/DVB (9995): gspca - ov534 and m5602: Set static some functions/=
variables.
      V4L/DVB (9997): gspca - main: Don't lock the kernel on ioctl.
      V4L/DVB (10045): gspca - ov534: Remove empty line in trace.
      V4L/DVB (10046): gspca - ov534: Use the gspca usb buf for usb contr=
ol messages.
      V4L/DVB (10049): gspca - many subdrivers: Set 'const' the pixel for=
mat table.
      V4L/DVB (10050): gspca - vc032x: Webcam 046d:0897 added.

Jean-Marc Spaggiari (1):
      hwmon: (it87) Add support for the ITE IT8720F

Jeff Garzik (1):
      [libata] pata_hpt3x3: correct _freeze() function declaration

Jeff Kirsher (6):
      DCB: fix kconfig option
      ixgbe: cleanup link up/down messages
      e1000: cleanup link up/down messages
      ixgb: cleanup link up/down messages
      e100: cleanup link up/down messages
      igb: fixup AER with proper error handling

Jeff Layton (18):
      lockd: convert reclaimer thread to kthread interface
      sunrpc: fix code that makes auth_gss send destroy_cred message (try=
 #2)
      cifs: remove unused SMB session pointer from struct mid_q_entry
      cifs: display addr and prefixpath options in /proc/mounts
      cifs: take module reference when starting cifsd
      cifs: convert tcpSem to a mutex
      cifs: make dnotify thread experimental code
      cifs: account for IPv6 in ses->serverName and clean up netbios name=
 handling
      cifs: move allocation of new TCP_Server_Info into separate function
      cifs: don't declare smb_vol info on the stack
      cifs: make ipv4_connect take a TCP_Server_Info arg
      cifs: make ipv6_connect take a TCP_Server_Info arg
      cifs: fix wait_for_response to time out sleeping processes correctl=
y
      cifs: zero out session password before freeing it
      cifs: have calc_lanman_hash take more granular args
      cifs: store password in tcon
      sunrpc: add sv_maxconn field to svc_serv (try #3)
      lockd: set svc_serv->sv_maxconn to a more reasonable value (try #3)

Jeff Mahoney (1):
      Btrfs: Add workaround for AppArmor changing remove_suid()

Jelle Foks (1):
      V4L/DVB (9654): new email address

Jens Axboe (21):
      btrfs: 32-bit type problems
      Btrfs: Fix bi_end_io() functions on > 2.6.23 kernels
      Btrfs: KM_IRQ0 usage in end_io handling
      Btrfs: sysfs compile fixup
      block: add comment in blk_rq_timed_out() about why next can not be =
0
      block: leave the request timeout timer running even on an empty lis=
t
      cciss: switch to using hlist for command list management
      block: don't use plugging on SSD devices
      bio: only mempool back the largest bio_vec slab cache
      bio: move the slab pointer inside the bio_set
      bio: allow individual slabs in the bio_set
      bio: add support for inlining a number of bio_vecs inside the bio
      aio: make the lookup_ioctx() lockless
      block: get rid of elevator_t typedef
      nbd: tell the block layer that it is not a rotational device
      cfq-iosched: remove limit of dispatch depth of max 4 times quantum
      block: add one-hit cache for disk partition lookup
      Get rid of CONFIG_LSF
      cfq-iosched: fix race between exiting queue and exiting task
      bounce: don't rely on a zeroed bio_vec list
      bio: get rid of bio_vec clearing

Jeremy Fitzhardinge (12):
      xen: don't reload cr3 on suspend
      x86: remove unused iommu_nr_pages
      swiotlb: allow architectures to override swiotlb pool allocation
      xen: clean up asm/xen/hypervisor.h
      x86: make sure we really have an hpet mapping before using it
      swiotlb: factor out copy to/from device
      swiotlb: support bouncing of HighMem pages
      x86: add swiotlb allocation functions
      x86: unify pci iommu setup and allow swiotlb to compile for 32 bit
      sparseirq, xen: make sure irq_desc is allocated for interrupts
      swiotlb: add hwdev to swiotlb_phys_to_bus() / swiotlb_sg_to_bus()
      mm/apply_to_range: call pte function with lazy updates

Jeremy Kerr (1):
      scripts/package: allow custom options to rpm

Jes Sorensen (1):
      KVM: ia64: Fix kvm_arch_vcpu_ioctl_[gs]et_regs()

Jesper Dangaard Brouer (3):
      NIU: Implement discard counters
      NIU: Implement discard counters, info/debug statements.
      NIU: Implement discard counters, optimize

Jesper Juhl (3):
      swiotlb: Don't include linux/swiotlb.h twice in lib/swiotlb.c
      trivial: update Jesper Juhl CREDITS entry with new email
      include/linux/interrupt.h: do not include linux/irqnr.h twice

Jesse Barnes (6):
      drm: GEM mmap support
      drm/i915: add GEM GTT mapping support
      DRM: i915: add mode setting support
      PCI: check mmap range of /proc/bus/pci files too
      PCI: fixup whitespace in quirks.c
      PCI: set device wakeup capable flag if platform support is present

Jesse Brandeburg (3):
      ixgbe: add device support for 82598AT (copper 10GbE) adapters
      pktgen: add full reset functionality
      ixgbe: fix dma mapping unbalance

Jianjun Kong (13):
      af_unix: clean up net/unix/af_unix.c garbage.c sysctl_net_unix.c
      net: clean up net/ipv4/ah4.c esp4.c fib_semantics.c inet_connection=
_sock.c inetpeer.c ip_output.c
      net: clean up net/ipv4/ipip.c raw.c tcp.c tcp_minisocks.c tcp_yeah.=
c xfrm4_policy.c
      net: clean up net/ipv4/fib_frontend.c fib_hash.c ip_gre.c
      net: clean up net/ipv4/igmp.c
      net: clean up net/ipv4/ip_sockglue.c tcp_output.c
      net: clean up net/ipv4/ipmr.c
      net: clean up net/ipv4/ip_fragment.c tcp_timer.c ip_input.c
      net: clean up net/ipv4/pararp.c
      net: clean up net/ipv4/devinet.c
      net: clean up net/ipv4/tcp_ipv4.c
      net: remove two duplicated #include
      module: fix warning of unused function when !CONFIG_PROC_FS

Jie Zhang (1):
      Blackfin arch: Print FP at level KERN_NOTICE

Jike Song (2):
      x86: clean up comments wrt. rd{msr|tsc|pmc}
      kbuild: reintroduce ALLSOURCE_ARCHS support for tags/cscope

Jim Meyering (2):
      Btrfs: disk-io.c (open_ctree): Don't deref. NULL upon failed kzallo=
c
      Btrfs: disk-io.c (open_ctree): avoid leaks upon allocation failure

Jim Paris (8):
      V4L/DVB (9858): gspca - ov534: Initialization cleanup.
      V4L/DVB (9859): gspca - ov534: Fix frame size so we don't miss the =
last pixel.
      V4L/DVB (9860): gspca - ov534: Frame transfer improvements.
      V4L/DVB (9873): gspca - ov534: Improve payload handling.
      V4L/DVB (9874): gspca - ov534: Explicitly initialize frame format.
      V4L/DVB (9876): gspca - main: Allow subdrivers to handle v4l2_strea=
mparm requests.
      V4L/DVB (9877): gspca - ov534: Add framerate support.
      mtd/ps3vram: Add ps3vram driver for accessing video RAM as MTD

Jim Radford (1):
      ftrace: scripts/recordmcount.pl support for ARM

Jiri Kosina (11):
      HID: ignore mouse interface for unibody macbooks
      HID: non-input reports can also be numbered
      HID: add phys and name ioctls to hidraw
      HID: set proper dev.parent in hidraw
      HID: fix default Kconfig setting for TopSpeed driver
      HID: fix error condition propagation in hid-sony driver
      Merge branch 'upstream-fixes' into for-next
      Input: i8042 - add Dell Vostro 1510 to nomux list
      trivial: Update MAINTAINERS entry
      trivial: printk: fix indentation of new_text_line declaration
      HID: fix hid->hiddev initialization in hiddev_connect()

Jiri Moravec (1):
      fbdev: fix typo in drivers/video/modedb.c

Jiri Slaby (13):
      Ath5k: add AP mode
      x86, 64-bit: update address space documentation
      x86: intel_cacheinfo, minor show_type cleanup
      kbuild: fix make tags/cscope
      kbuild: fix string equality testing in tags.sh
      DMI: add dmi_match
      [libata] ata_piix: cleanup dmi strings checking
      V4L/DVB (9972): v4l: usbvideo, fix module ref count check
      HID: move usbhid flags to usbhid.h
      HID: usbhid, use usb_endpoint_xfer_int
      HID: use GFP_KERNEL in hid_alloc_buffers
      HID: add dynids facility
      x86: fix RIP printout in early_idt_handler

Jirka Pirko (3):
      tokenring/3c359.c: fix allocation null check
      tokenring/3c359.c: Fix error message when allocating tx_ring
      tokenring/3c359.c: Prevent possible mem leak when open failed

Joachim Fenkes (1):
      IB/ehca: Fix locking for shca_list_lock

Joachim Wuttke (1):
      Staging: comedi: add comedi_test driver

Joe Chou (2):
      r6040: fix wrong logic in mdio code
      r6040: save and restore MIER correctly in the interrupt routine

Joe Korty (2):
      forcdeth: increase max_interrupt_work
      x86: change thread_info's flag field back to 32 bits

Joe Perches (3):
      include/net net/ - csum_partial - remove unnecessary casts
      drivers/s390/ - csum_partial - remove unnecessary casts
      net/ipv6/ip6mr.c: Use kmem_cache_zalloc, remove memset

Joe Peterson (4):
      n_tty: Fix loss of echoed characters and remove bkl from n_tty
      n_tty: Fix handling of control characters and continuations
      n_tty: Fix hanfling of buffer full corner cases
      n_tty: Output bells immediately on a full buffer

Joel Becker (62):
      Btrfs: cleaner make clean
      ocfs2: Field prefixes for the xattr_bucket structure
      ocfs2: Convenient access to an xattr bucket's block number.
      ocfs2: Convenient access to xattr bucket data blocks.
      ocfs2: Convenient access to an xattr bucket's header.
      ocfs2: Provide a wrapper to brelse() xattr bucket buffers.
      ocfs2: Improve ocfs2_read_xattr_bucket().
      ocfs2: Wrap journal_access/journal_dirty for xattr buckets.
      ocfs2: Copy xattr buckets with a dedicated function.
      ocfs2: Take ocfs2_xattr_bucket structures off of the stack.
      ocfs2: Use buckets in ocfs2_xattr_bucket_find().
      ocfs2: Use buckets in ocfs2_xattr_create_index_block().
      ocfs2: Use buckets in ocfs2_defrag_xattr_bucket().
      ocfs2: Use buckets in ocfs2_xattr_set_entry_in_bucket().
      ocfs2: Wrap inode block reads in a dedicated function.
      ocfs2: Morph the haphazard OCFS2_IS_VALID_DINODE() checks.
      ocfs2: Consolidate validation of group descriptors.
      ocfs2: Wrap group descriptor reads in a dedicated function.
      ocfs2: Morph the haphazard OCFS2_IS_VALID_GROUP_DESC() checks.
      ocfs2: Wrap extent block reads in a dedicated function.
      ocfs2: Wrap dirblock reads in a dedicated function.
      ocfs2: Wrap xattr block reads in a dedicated function
      ocfs2: Validate metadata only when it's read from disk.
      ocfs2: Wrap virtual block reads in ocfs2_read_virt_blocks()
      ocfs2: Convert ocfs2_read_dir_block() to ocfs2_read_virt_blocks()
      ocfs2: Fix ocfs2_read_quota_block() error handling.
      ocfs2: Dirty the entire bucket in ocfs2_bucket_value_truncate()
      ocfs2: Dirty the entire first bucket in ocfs2_extend_xattr_bucket()
      ocfs2: Dirty the entire first bucket in ocfs2_cp_xattr_cluster().
      ocfs2: Explain t_is_new in ocfs2_cp_xattr_cluster().
      ocfs2: Use ocfs2_cp_xattr_bucket() in ocfs2_mv_xattr_bucket_cross_c=
luster().
      ocfs2: Rename ocfs2_cp_xattr_cluster() to ocfs2_mv_xattr_buckets().
      ocfs2: ocfs2_mv_xattr_buckets() can handle a partial cluster now.
      ocfs2: Use ocfs2_mv_xattr_buckets() in ocfs2_mv_xattr_bucket_cross_=
cluster().
      ocfs2: Start using buckets in ocfs2_adjust_xattr_cross_cluster().
      ocfs2: Pass buckets into ocfs2_mv_xattr_bucket_cross_cluster().
      ocfs2: Move buckets up into ocfs2_add_new_xattr_cluster().
      ocfs2: Move buckets up into ocfs2_add_new_xattr_bucket().
      ocfs2: Pass xs->bucket into ocfs2_add_new_xattr_bucket().
      jbd2: Add buffer triggers
      ocfs2: Add the on-disk structures for metadata checksums.
      ocfs2: Add the underlying blockcheck code.
      ocfs2: Add a validation hook for quota block reads.
      ocfs2: block read meta ecc.
      ocfs2: Add journal_access functions with jbd2 triggers.
      ocfs2: Wrap up the common use cases of ocfs2_new_path().
      ocfs2: Use metadata-specific ocfs2_journal_access_*() functions.
      ocfs2: Add ecc and checksums to ocfs2 xattr buckets.
      ocfs2: Create ocfs2_xattr_value_buf.
      ocfs2: Pull ocfs2_xattr_value_buf up from __ocfs2_remove_xattr_rang=
e().
      ocfs2: Pull ocfs2_xattr_value_buf up into ocfs2_xattr_value_truncat=
e().
      ocfs2: Pass ocfs2_xattr_value_buf into ocfs2_xattr_value_truncate().
      ocfs2: Pass value buf to ocfs2_xattr_update_entry().
      ocfs2: Use ocfs2_xattr_value_buf in ocfs2_xattr_set_entry().
      ocfs2: Pass value buf to ocfs2_remove_value_outside().
      ocfs2: Use proper journal_access function in xattr.c
      ocfs2: Checksum and ECC for directory blocks.
      ocfs2: Validate superblock with checksum and ecc.
      ocfs2: Enable metadata checksums.
      ocfs2: Don't hand-code xor in ocfs2_hamming_encode().
      ocfs2: Another hamming code optimization.
      ocfs2: One more hamming code optimization.

Joerg Roedel (61):
      x86: default to SWIOTLB=3Dy on x86_64
      x86: move GART specific stuff from iommu.h to gart.h
      x86: fix broken flushing in GART nofullflush path
      KVM: rename vtd.c to iommu.c
      introcude linux/iommu.h for an iommu api
      add frontend implementation for the IOMMU API
      select IOMMU_API when DMAR and/or AMD_IOMMU is selected
      KVM: change KVM to use IOMMU API
      VT-d: adapt domain init and destroy functions for IOMMU API
      VT-d: adapt device attach and detach functions for IOMMU API
      VT-d: adapt domain map and unmap functions for IOMMU API
      VT-d: adapt domain iova_to_phys function for IOMMU API
      VT-d: register functions for the IOMMU API
      VT-d: remove now unused intel_iommu_found function
      AMD IOMMU: rename iommu_map to iommu_map_page
      AMD IOMMU: make dma_ops_free_pagetable generic
      AMD IOMMU: add domain id free function
      AMD IOMMU: refactor completion wait handling into separate function=
s
      AMD IOMMU: move invalidation command building to a separate functio=
n
      AMD IOMMU: don't remove protection domain from iommu_pd_list
      AMD IOMMU: add iommu_flush_domain function
      AMD IOMMU: add protection domain flags
      AMD IOMMU: add checks for dma_ops domain to dma_ops functions
      AMD IOMMU: add device reference counting for protection domains
      AMD IOMMU: rename set_device_domain function
      AMD IOMMU: add device detach helper functions
      AMD IOMMU: add device notifier callback
      AMD IOMMU: add domain cleanup helper function
      AMD IOMMU: add domain init function for IOMMU API
      AMD IOMMU: add domain destroy function for IOMMU API
      AMD IOMMU: add device detach function for IOMMU API
      AMD IOMMU: add device attach function for IOMMU API
      AMD IOMMU: add domain map function for IOMMU API
      AMD IOMMU: add domain unmap function for IOMMU API
      AMD IOMMU: add domain address lookup function for IOMMU API
      AMD IOMMU: register functions for the IOMMU API
      AMD IOMMU: add a domain flag for default domains
      AMD IOMMU: allocate a new protection for hotplugged devices
      AMD IOMMU: use dev_name instead of self-build print_devid
      AMD IOMMU: convert iommu->need_sync to bool
      AMD IOMMU: convert amd_iommu_isolate to bool
      AMD IOMMU: use calc_devid in prealloc_protection_domains
      AMD IOMMU: use dev_name in iommu_enable function
      AMD IOMMU: add Kconfig entry for statistic collection code
      AMD IOMMU: add necessary header defines for stats counting
      AMD IOMMU: add init code for statistic collection
      AMD IOMMU: add stats counter for completion wait events
      AMD IOMMU: add stats counter for map_single requests
      AMD IOMMU: add stats counter for unmap_single requests
      AMD IOMMU: add stats counter for map_sg requests
      AMD IOMMU: add stats counter for unmap_sg requests
      AMD IOMMU: add stats counter for alloc_coherent requests
      AMD IOMMU: add stats counter for free_coherent requests
      AMD IOMMU: add stats counter for cross-page request
      AMD IOMMU: add stats counter for single iommu domain tlb flushes
      AMD IOMMU: add stats counter for domain tlb flushes
      AMD IOMMU: add statistics about allocated io memory
      AMD IOMMU: add statistics about total number of map requests
      kvm/iommu: fix compile warning
      Merge branches 'iommu/api' and 'iommu/amd' into for-linus
      AMD IOMMU: remove now unnecessary #ifdefs

Johann Felix Soden (1):
      Staging: et131x: remove unused variable in et1310_tx.c

Johannes Berg (75):
      ALSA: aoa: clean up file names
      mac80211: convert to %pM away from print_mac
      net: convert print_mac to %pM
      net: convert more to %pM
      mac80211: remove aggregation status write support from debugfs
      mac80211: remove writable debugs mesh parameters
      mac80211: minor code cleanups
      mac80211: remove wiphy_to_hw
      mac80211: clean up ieee80211_hw_config errors
      mac80211: remove max_antenna_gain config
      mac80211: fix short slot handling
      802.11: clean up/fix HT support
      mac80211: kill hw.conf.antenna_sel_{rx,tx}
      mac80211: introduce hw config change flags
      mac80211: provide sequence numbers
      nl80211: export HT capabilities
      iwl3945: fix station stuff in RC algorithm
      mac80211: make retry limits part of hw config
      mac80211: move bss_conf into vif
      mac80211: rewrite HT handling
      p54/rtl8187: fix up the seqno patch
      mac80211: add might_sleep to hw_config
      mac80211/drivers: rewrite the rate control API
      p54: implement MRR
      make ieee80211 invisible
      nl80211: fix monitor flags
      mac80211: remove rate_control_clear
      mac80211: inform userspace of probe/auth/assoc timeout
      wireless: don't publish __regulatory_hint
      wireless: remove cfg80211_reg_mutex
      wireless: get rid of pointless request list
      wireless: fix EU check
      mac80211: insert AP sta entry after filling it
      wireless: remove write-only 'granted' variable
      wireless: make regdom passing semantics simpler
      wireless: remove struct regdom hinting
      wireless: clean up regulatory ignore_request function
      wireless regulatory: move ignore_request
      mac80211: fix two kernel-doc warnings
      wireless: move mesh config length constant
      wireless: fix a few sparse warnings
      ath9k: remove useless NULL initialisers
      iwl3945: remove dead code
      iwlwifi: remove implicit direct scan
      iwlwifi: remove unused essid variable
      b43/legacy: remove SSID code
      adm8211: remove SSID code
      mac80211: remove SSID driver code
      iwl3945: remove bogus comment
      don't use net/ieee80211.h
      wireless: implement basic rate helper function
      b43: implement short slot and basic rate handling
      libertas_tf: fix skb tail pointer
      b43legacy: implement short slot and basic rate handling
      b43: remove rate index warning
      wireless: clean up sysfs code using %pM
      ath5k: name pci driver "ath5k" too
      powerpc: Allow the max stack trace depth to be configured
      mac80211: only transition STAs ps->wake on data frames
      cfg80211: handle SIOCGIWNAME
      cfg80211: handle SIOCGIWMODE/SIOCSIWMODE
      wireless: clean up radiotap a bit
      cfg80211: fix wiphy remove if no regulatory request
      cfg80211: "fix" 11d oops
      p54: fix lm87 checksum endianness
      iwlwifi: disable AP mode
      mac80211: improve sta_notify documentation
      cfg80211: fix nl80211 frequency handling
      mac80211: only create default STA interface if supported
      ath9k: remove fragmentation workaround again
      mac80211: remove fragmentation offload functionality
      mac80211/cfg80211: check endianness in sparse runs
      rfkill: strip pointless notifier chain
      forcedeth: don't poll NV event 36
      remove CONFIG_KMOD

Johannes Weiner (4):
      mm: more likely reclaim MADV_SEQUENTIAL mappings
      mm: check for no mmaps in exit_mmap()
      bootmem: print request details before BUG_ON(them)
      dma-coherent: catch oversized requests to dma_alloc_from_coherent()

John Daiker (2):
      ath5k: reduce checkpatch.pl errors
      rt2x00: reduce checkpatch.pl errors

John Linn (1):
      Input: xilinx_ps2 - various cleanups

John W. Linville (22):
      p54: integrate parts of lmac_longbow.h and other parts of stlc45xx
      wireless: consolidate on a single escape_essid implementation
      wireless: remove NETWORK_EMPTY_ESSID flag
      wireless: escape_ssid should handle non-printables
      wireless: use individual buffers for printing ssid values
      wireless: avoid some net/ieee80211.h vs. linux/ieee80211.h conflict=
s
      p54: eliminate warning for uninitialized variable 'tim_len'
      ath9k: correct warning about unintialized variable 'tid'
      netdevice zd1201: Convert directly reference of netdev->priv to net=
dev_priv()
      ipw2100, ipw2200: select LIB80211
      lib80211: absorb crypto bits from net/ieee80211
      lib80211: consolidate crypt init routines
      ipw2x00: relocate ipw2100/ipw2200 to common directory
      net/ieee80211 -> drivers/net/ipw2x00/libipw_* rename
      mac80211: add explicit padding in struct ieee80211_tx_info
      rtl8180: adapt for deprecated IEEE80211_CONF_SHORT_SLOT_TIME flag
      MAINTAINERS: claim maintenance over rtl818x drivers
      mac80211_hwsim: fix-up some print_mac merge damage
      hostap: select required crypto bits in Kconfig
      mac80211: deauth when interface is marked down
      ieee80211_security: correct warning about width of auth_mode
      Staging: at76_usb: update drivers/staging/at76_usb w/ mac80211 port

Jon Callan (2):
      ARMv7: Add SMP initialisation to proc-v7.S
      RealView: Add Cortex-A9 support to the EB board

Jon Tollefson (1):
      powerpc: Hugetlb pgtable cache access cleanup

Jonathan Brassow (4):
      dm raid1: fix error count
      dm snapshot: separate out exception store interface
      dm snapshot: rename struct exception_store
      dm snapshot: extend exception store functions

Jonathan Cameron (2):
      [ARM] pxa: initial support for the Imote2 platform
      rtc: move power of 2 periodic frequency check down into drivers

Jonathan Corbet (1):
      Fix a typo in the development process document.

Jordan Crouse (1):
      ALSA: cs5535audio: Use OLPC/Geode basic infrastructure

Jose Alberto Reguero (1):
      V4L/DVB (9525): af9015: add support for AverMedia Volar X remote.

Josef Bacik (29):
      Btrfs: Implement mknod
      Btrfs: delay commits during fsync to allow more writers
      Btrfs: Add per-root block accounting and sysfs entries
      xattr support for btrfs
      Btrfs: Make ACLs return EOPNOTSUPP for now
      Btrfs: xattr fixes
      Btrfs: Implement new dir index format
      Btrfs: Remove unused xattr code
      Btrfs: Add ACL support
      Btrfs: Create orphan inode records to prevent lost files after a cr=
ash
      Btrfs: Fix a few functions that exit without stopping their transac=
tion
      Btrfs: compile when posix acl's are disabled
      Btrfs: fix cache_block_group error handling
      Btrfs: free space accounting redo
      Btrfs: fix seekiness due to finding the wrong block group
      Btrfs: fix deadlock between alloc_mutex/chunk_mutex
      Btrfs: make tree_search_offset more flexible in its searching
      Btrfs: fix enospc when there is plenty of space
      Btrfs: nuke fs wide allocation mutex V2
      jbd2: improve jbd2 fsync batching
      Btrfs: batch extent inserts/updates/deletions on the extent root
      Btrfs: fix free space leak
      Btrfs: Add some debugging around the ENOSPC bugs
      Btrfs: fix free space accounting when unpinning extents
      Btrfs: Fix for lockdep warnings with alloc_mutex and pinned_mutex
      Btrfs: add support for compat flags to btrfs
      Btrfs: fix panic on error during mount
      Btrfs: add support for multiple csum algorithms
      jbd: improve fsync batching

Josh Boyer (1):
      powerpc: Introduce ppc_pci_flags accessors

Jouni Hogander (1):
      ARM: OMAP: Enable GPIO debounce clock only when debounce is enabled=
 v3

Jouni Malinen (25):
      mac80211_hwsim: Debug info for BSS config changes
      nl80211: Add basic rate configuration for AP mode
      mac80211_hwsim: Debug info for TX queue parameters
      nl80211: Add TX queue parameter configuration
      mac80211_hwsim: Make sure beacon_timer gets deleted
      mac80211: Allow AP mode to be enabled
      mac80211_hwsim: Add support for client PS mode
      mac80211_hwsim: Update documentation (AP mode enabled)
      nl80211: Report max TX power in NL80211_BAND_ATTR_FREQS
      nl80211: Change max TX power to be in mBm instead of dBm
      nl80211: Add frequency configuration (including HT40)
      ath9k: Free Beacon skbs in AP mode
      ath9k: Disable staggered Beacon frame scheduling
      mac80211: Disable requests for new scans in AP mode
      ath9k: Do not remove header padding on RX from short frames
      mac80211: Add HT rates into RX status reporting
      ath9k: Report HT rates in RX status
      mac80211: Send Layer 2 Update frame on reassociation
      mac80211: Remove radiotap rate-present flag for HT
      ath9k: Fix TX status reporting for retries and MCS index
      ath9k: Remove MAC header pad before reporting TX status
      ath9k: Fix a NULL pointer dereference in ath_rate_get
      ath9k: Key cache allocation for AP mode
      ath9k: Fix key cache slot selection for splitmic
      ath9k: Fixed RX decryption status reporting

Juergen Beisert (1):
      i.MX Framebuffer: Use readl/writel instead of direct pointer deref

Julia Lawall (50):
      drivers/net/wireless/ath9k/rc.c: use ARRAY_SIZE
      ALSA: sound/pci/mixart/mixart.c: Add missing snd_card_free
      Bluetooth: Change simple_strtol to simple_strtoul
      powerpc: Eliminate NULL test and memset after alloc_bootmem
      drivers/isdn/mISDN: use ARRAY_SIZE
      [MTD] drivers/mtd/maps/nettel.c: use ARRAY_SIZE
      [ARM] eliminate NULL test and memset after alloc_bootmem
      drivers/net/hamradio: Move a dereference below a NULL test
      IB/ehca: Remove redundant test of vpage
      drivers/net/wan: Remove redundant test
      crypto: md4 - Use ARRAY_SIZE
      [S390] drivers/s390/crypto: Move dereference to after IS_ERR test
      [S390] s390: Remove redundant test
      drivers/net/au1000_eth.c: Remove redundant test
      drivers/net/ehea: Remove redundant test
      drivers/net: Remove redundant test
      drivers/net/wan: Remove redundant test
      net/appletalk: Remove redundant test
      [CIFS] Remove redundant test
      drm/i915: Remove redundant test in error path.
      [SCSI] esp_scsi: Use DIV_ROUND_UP
      [SCSI] fusion: use ARRAY_SIZE
      V4L/DVB (9638): drivers/media: use ARRAY_SIZE
      drivers/net/usb: use USB API functions rather than constants
      Input: gtco - use USB endpoint API
      V4L/DVB (9796): drivers/media/video/cx88/cx88-alsa.c: Adjust error-=
handling code
      V4L/DVB (10130): use USB API functions rather than constants
      powerpc/85xx: Add local_irq_restore in error handling code
      drivers/mmc: Move a dereference below a NULL test
      fs/namespace.c: drop code after return
      ALSA: sound/usb: use USB API functions rather than constants
      ALSA: Use usb_set/get_intfdata
      [SCSI] lpfc: Move a dereference below a NULL test
      [SCSI] fusion: Move a dereference below a NULL test
      V4L/DVB (10171): Use usb_set_intfdata
      ALSA: sound/usb: Use negated usb_endpoint_xfer_control, etc
      GFS2: Use DEFINE_SPINLOCK
      [MTD] [NAND] alauda: use USB API functions rather than constants
      parisc: Use DEFINE_SPINLOCK
      arch/avr32: Eliminate NULL test and memset after alloc_bootmem
      Staging: wlan-ng: p80211wext.c: use ARRAY_SIZE
      mm/page_alloc.c: eliminate NULL test and memset after alloc_bootmem
      drivers/spi: move a dereference below a NULL test
      drivers/rtc: correct an error test
      USB: gadget: change simple_strtol to simple_strtoul
      drivers/pci/hotplug: Add missing pci_dev_get
      PCI hotplug: remove redundant test in cpq hotplug
      V4L/DVB (10185): Use negated usb_endpoint_xfer_control, etc
      powerpc/52xx: Use DEFINE_SPINLOCK
      powerpc/pasemi: Use DEFINE_SPINLOCK

Julian Calaby (2):
      sparc: Clean arch-specific code in prom_common.c
      sparc: Fix minor SPARC32 compile error

Julien Boibessot (1):
      [ARM] MX27: add i.MX27 SDHC1 and SDHC2 GPIO declarations

Julius Volz (3):
      IPVS: Add IPv6 support to SH and DH schedulers
      IPVS: Add IPv6 support to LBLC/LBLCR schedulers
      IPVS: Remove supports_ipv6 scheduler flag

J=C3=BCri Reitel (1):
      rtc-ds1307: remove legacy probe() checks

KAMEZAWA Hiroyuki (23):
      cgroups: make cgroup config a submenu
      memcg: introduce charge-commit-cancel style of functions
      memcg: fix gfp_mask of callers of charge
      memcg: simple migration handling
      memcg: move all acccounting to parent at rmdir()
      memcg: new force_empty to free pages under group
      memcg: handle swap caches
      memcg: mem+swap controller Kconfig
      memcg: swap cgroup for remembering usage
      memcg: mem+swap controller core
      memcg: synchronized LRU
      memcg: avoid unnecessary system-wide-oom-killer
      memcg: fix reclaim result checks
      memcg: revert gfp mask fix
      memcg: swapout refcnt fix
      memcg: rename scan global lru
      memcg: show real limit under hierarchy mode
      memcg: explain details and test document
      memcg: fix swap accounting leak
      memcg: fix double free and make refcnt sane
      memcg: use css_tryget in memcg
      memcg: fix LRU accounting for SwapCache
      memcg: fix shmem's swap accounting

KOSAKI Motohiro (38):
      x86: update CONFIG_NUMA description
      x86/doc: spelling fix for grub
      proc: enclose desc variable of show_stat() in CONFIG_SPARSE_IRQ
      locking, irq: enclose irq_desc_lock_class in CONFIG_LOCKDEP
      hrtimer: remove #include <linux/irq.h>
      irq: for_each_irq_desc() move to irqnr.h
      proc: remove ifdef CONFIG_SPARSE_IRQ from stat.c
      irq: simplify for_each_irq_desc() usage
      getrusage: RUSAGE_THREAD should return ru_utime and ru_stime
      mm: get rid of pagevec_release_nonlru()
      mm: cleanup: remove #ifdef CONFIG_MIGRATION
      memcg: reclaim shouldn't change zone->recent_rotated statistics
      mm: make init_section_page_cgroup() static
      mm: make maddr __iomem
      mm: make mem_cgroup_resize_limit() static
      mm: make scan_all_zones_unevictable_pages() static
      mm: make scan_zone_unevictable_pages() static
      mm: make setup_per_zone_inactive_ratio() static
      mm: make vread() and vwrite() declaration
      vmscan: improve reclaim throughput to bail out patch
      mm: kill zone_is_near_oom()
      mm: remove CONFIG_OUT_OF_LINE_PFN_TO_PAGE
      mm: kill page_queue_congested()
      mm: stop kswapd's infinite loop at high order allocation
      profile: don't include <asm/ptrace.h> twice.
      inactive_anon_is_low: move to vmscan
      mm: introduce zone_reclaim struct
      mm: add zone nr_pages helper function
      mm: make get_scan_ratio() safe for memcg
      memcg: add null check to page_cgroup_zoneinfo()
      memcg: add inactive_anon_is_low()
      memcg: add mem_cgroup_zone_nr_pages()
      memcg: add zone_reclaim_stat
      memcg: remove mem_cgroup_cal_reclaim()
      memcg: show reclaim stat
      memcg: protect prev_priority
      memcg: swappiness
      memcg: fix calculation of active_ratio

Kai Makisara (2):
      [SCSI] st: integrate st_scsi_kern_execute and st_do_scsi
      [SCSI] st: retry enlarge_buffer allocation

Kaiwan N Billimoria (1):
      hwmon: (lm70) Code streamlining and cleanup

Kalle Jokiniemi (1):
      i2c-omap: Enable I2C wakeups for 34xx

Kalle Valo (4):
      mac80211: document ieee80211_tx_info.pad
      mac80211: enable IEEE80211_CONF_PS only when associated
      mac80211: track master queue status
      mac80211: implement dynamic power save

Kamalesh Babulal (5):
      net: Fix more NAPI interface netdev argument drop fallout.
      Staging: asus_oled: fix build dependancy
      Staging: meilhaus: fix __symbol_get problems
      powerpc: Fix iseries drivers build failure without CONFIG_VIOPATH
      [S390] tape block: fix dependencies

Karen Xie (3):
      cxgb3: manage private iSCSI IP address
      [SCSI] cxgb3i: Add cxgb3i iSCSI driver.
      [SCSI] cxgb3i: remove use of skb->sp

Karl Beldan (2):
      ASoC: ssm2602: Fix priv substreams refs
      ASoC: ssm2602: Update supported stream formats

Karl Bongers (1):
      USB: isp1760: Fix probe in PCI glue code

Karsten Keil (3):
      misdn: Fix lockdep warning
      mISDN: Cleanup hfc multiport driver
      mISDN: Add HFC USB driver

Kay Sievers (58):
      Input: struct device - replace bus_id with dev_name(), dev_set_name=
()
      uwb: struct device - replace bus_id with dev_name(), dev_set_name()
      net: struct device - replace bus_id with dev_name(), dev_set_name()
      ssb: struct device - replace bus_id with dev_name(), dev_set_name()
      powerpc: struct device - replace bus_id with dev_name(), dev_set_na=
me()
      rapidio: struct device - replace bus_id with dev_name(), dev_set_na=
me()
      [MTD] struct device - replace bus_id with dev_name(), dev_set_name(=
)
      [S390] struct device - replace bus_id with dev_name(), dev_set_name=
()
      ide: struct device - replace bus_id with dev_name(), dev_set_name()
      V4L/DVB (9473): add DVB_DEVICE_NUM and DVB_ADAPTER_NUM to uevent
      V4L/DVB (9521): V4L: struct device - replace bus_id with dev_name()=
, dev_set_name()
      virtio: struct device - replace bus_id with dev_name(), dev_set_nam=
e()
      [SCSI] struct device - replace bus_id with dev_name(), dev_set_name=
()
      V4L/DVB (10172): add DVB_DEVICE_TYPE=3D to uevent
      HID: struct device - replace bus_id with dev_name(), dev_set_name()
      avr: struct device - replace bus_id with dev_name(), dev_set_name()
      driver core: struct device - replace bus_id with dev_name(), dev_se=
t_name()
      sysfs: clarify SYSFS_DEPRECATED help text
      xen: struct device - replace bus_id with dev_name(), dev_set_name()
      w1: struct device - replace bus_id with dev_name(), dev_set_name()
      video: struct device - replace bus_id with dev_name(), dev_set_name=
()
      tifm: struct device - replace bus_id with dev_name(), dev_set_name(=
)
      thermal: struct device - replace bus_id with dev_name(), dev_set_na=
me()
      swiotlb: struct device - replace bus_id with dev_name(), dev_set_na=
me()
      spi: struct device - replace bus_id with dev_name(), dev_set_name()
      SGI: struct device - replace bus_id with dev_name(), dev_set_name()
      serial: struct device - replace bus_id with dev_name(), dev_set_nam=
e()
      power-supply: struct device - replace bus_id with dev_name(), dev_s=
et_name()
      pnp: struct device - replace bus_id with dev_name(), dev_set_name()
      mwave: struct device - replace bus_id with dev_name(), dev_set_name=
()
      mtd: struct device - replace bus_id with dev_name(), dev_set_name()
      mips: struct device - replace bus_id with dev_name(), dev_set_name(=
)
      memstick: struct device - replace bus_id with dev_name(), dev_set_n=
ame()
      macintosh: struct device - replace bus_id with dev_name(), dev_set_=
name()
      pm: struct device - replace bus_id with dev_name(), dev_set_name()
      ISDN: struct device - replace bus_id with dev_name(), dev_set_name(=
)
      infiniband: struct device - replace bus_id with dev_name(), dev_set=
_name()
      i7300_idle: struct device - replace bus_id with dev_name(), dev_set=
_name()
      IA64: struct device - replace bus_id with dev_name(), dev_set_name(=
)
      i2o: struct device - replace bus_id with dev_name(), dev_set_name()
      hwmon: struct device - replace bus_id with dev_name(), dev_set_name=
()
      gpu: struct device - replace bus_id with dev_name(), dev_set_name()
      gpio: struct device - replace bus_id with dev_name(), dev_set_name(=
)
      gadget: struct device - replace bus_id with dev_name(), dev_set_nam=
e()
      dmi: struct device - replace bus_id with dev_name(), dev_set_name()
      chris: struct device - replace bus_id with dev_name(), dev_set_name=
()
      block: struct device - replace bus_id with dev_name(), dev_set_name=
()
      avr: struct device - replace bus_id with dev_name(), dev_set_name()
      libata: struct device - replace bus_id with dev_name(), dev_set_nam=
e()
      arm: struct device - replace bus_id with dev_name(), dev_set_name()
      staging: struct device - replace bus_id with dev_name(), dev_set_na=
me()
      rtc: struct device: replace bus_id with dev_name(), dev_set_name()
      edac: struct device: replace bus_id with dev_name(), dev_set_name()
      i2c: Replace bus_id with dev_name(), dev_set_name()
      usb: struct device - replace bus_id with dev_name(), dev_set_name()
      oxu210hp-hcd.c: struct device - replace bus_id with dev_name(), dev=
_set_name()
      PCI: struct device - replace bus_id with dev_name(), dev_set_name()
      regulator: struct device - replace bus_id with dev_name(), dev_set_=
name()

Kees Cook (1):
      ELF: implement AT_RANDOM for glibc PRNG seeding

Keith Mannthey (1):
      block: Supress Buffer I/O errors when SCSI REQ_QUIET flag set

Ken Chen (8):
      x86, sched: enable wchan config menu item on 64-bit
      sched: fix inconsistency when redistribute per-cpu tg->cfs_rq share=
s
      sched: fix sd_parent_degenerate on non-numa smp machine
      x86: convert rdtscll() to use __native_read_tsc
      sched, cpuacct: refactoring cpuusage_read / cpuusage_write
      sched, cpuacct: export percpu cpuacct cgroup stats
      schedstat: consolidate per-task cpu runtime stats
      proc: add /proc/*/stack

Kenji Kaneshige (6):
      PCI hotplug: pciehp: remove unnecessary wait after turning power of=
f
      PCI: pciehp: add ACPI based slot detection
      PCI: pciehp: add auto option to pciehp_detect_mode
      PCI hotplug: introduce functions for ACPI slot detection
      PCI: pciehp: ignore undefined bit in link status register
      PCI: pciehp: cleanup register and field definitions

Kent Liu (1):
      crypto: crc32c-intel - Update copyright head

Kentaro Takeda (1):
      introduce new LSM hooks where vfsmount is available.

Kevin Hao (1):
      Add device function for USB serial console

Kevin Hilman (2):
      omap mmc: force MMC module reset on boot
      USB: musb: build fixes for DaVinci

Kim Phillips (2):
      crypto: talitos - Pass correct interrupt status to error handler
      crypto: talitos - Perform auth check in h/w if on sec 2.1 and above

Kiyoshi Ueda (2):
      dm request: add caches
      dm request: extend target interface

Klaus Schmidinger (2):
      V4L/DVB (10164): Add missing S2 caps flag to S2API
      V4L/DVB (10165): Add FE_CAN_2G_MODULATION flag to frontends that su=
pport DVB-S2

Klaus-D. Wacker (1):
      [S390] convert lcs printks to dev_xxx and pr_xxx macros.

Klaus-Dieter Wacker (2):
      qeth: HiperSockets mcl string conversion (pre z9 mach)
      qeth: No large send using EDDP for HiperSockets.

Kolekar, Abhijeet (3):
      iwl3945 : Fix Sparse Warnings
      iwl3945 : Simplify iwl3945_send_beacon_cmd
      iwl3945 : Simplify iwl3945_pci_probe

Komuro (1):
      fmvj18x_cs: write interrupt ack bit for lan and modem to work simul=
taneously.

Krishna Kumar (2):
      nfsd: Minor cleanup of find_stateid
      nfsd: Fix leaked memory in nfs4_make_rec_clidname

Kristian H=C3=B8gsberg (2):
      drm: pin new and unpin old buffer when setting a mode.
      drm/i915: Pin cursor bo and unpin old bo when setting cursor.

Kristian H=EF=BF=BDgsberg (1):
      drm: drop DRM_IOCTL_MODE_REPLACEFB, add+remove works just as well.

Kristoffer Ericson (1):
      [ARM] 5336/1: Formatting/Whitespace cleanups in mach-sa1100

Krzysztof Halasa (1):
      net: PHYLIB mdio fixes #2

Krzysztof Ha=C5=82asa (28):
      WAN: split hd6457x.c into hd64570.c and hd64572.c
      WAN: remove SCA II support from SCA drivers
      WAN: remove SCA support from SCA-II drivers
      WAN: convert HD64572-based drivers to NAPI.
      WAN: TX-done handler now uses the ownership bit in HD64572 drivers.
      WAN: HD64572 already handles TX underruns with DMAC.
      WAN: rework HD64572 interrupts a bit.
      WAN: Simplify HD64572 status handling.
      WAN: don't print HD64572 driver versions anymore.
      WAN: Simplify HD64572 drivers.
      WAN: HD64572 drivers don't use next_desc() anymore.
      WAN: Correct comments in hd6457[02].c
      WAN: Simplify sca_init_port() in HD64572 driver.
      WAN: new synchronous PPP implementation for generic HDLC.
      WAN: syncppp.c is no longer used by any kernel code. Remove it.
      WAN pc300too.c: Fix PC300-X.21 detection
      IXP4xx: check for queue being empty in qmgr_release_queue().
      IXP4xx: clear IRQ stat in qmgr_disable_irq().
      IXP4xx: Silence section mismatch warning in Ethernet driver.
      IXP4xx: Make the Ethernet driver use built-in netdev stats.
      IXP4xx: Add PHYLIB support to Ethernet driver.
      IXP4xx: Add PHYLIB MII ioctl to the Ethernet driver.
      IXP4xx: Add ethtool support to Ethernet driver.
      WAN: Add IXP4xx HSS HDLC driver.
      Update MAINTAINERS entries for IXP4xx and WAN network drivers.
      IXP4xx: move common debugging from network drivers to QMGR module.
      HDLC_PPP: Fix Configure-Ack to return original options as required =
by the standard.
      Convert ixp4xx_eth driver to use net_device_ops.

Kukkonen Mika (1):
      UBIFS: avoid unnecessary checks

Kumar Gala (14):
      powerpc: Add MSR[CE, DE] to the MSR bits we print on show_regs()
      powerpc: hash_page_sync should only be used on SMP & STD_MMU_32
      powerpc: Add a local_flush_tlb_page to handle kmap_atomic invalidat=
es
      powerpc: Use RCU based pte freeing mechanism for all powerpc
      powerpc: Remove unncessary SPE related compiler flag
      powerpc/85xx: minor head_fsl_booke.S cleanup
      powerpc/85xx: Add support for SMP initialization
      powerpc/85xx: Fix compile warnings in mpc85xx_mds.c
      powerpc/85xx: Fix compile issues with mpc8572ds.dts
      powerpc/85xx: Enable SMP support
      powerpc/85xx: Add SMP support to MPC8572 DS
      edac: fix mpc85xx and add mpc8536 mpc8560
      powerpc: Export cacheable_memzero as its now used in a driver
      gianfar: Fixup use of BUS_ID_SIZE

Kuninori Morimoto (15):
      V4L/DVB (9488): Add ov772x driver
      V4L/DVB (9783): Change power on/off sequence on ov772x
      V4L/DVB (9784): Register name fix for ov772x driver
      V4L/DVB (10067): Remove ov772x_default_regs from ov772x driver
      V4L/DVB (10068): Change device ID selection method on ov772x driver
      V4L/DVB (10069): Add ov7725 support to ov772x driver
      V4L/DVB (10086): Add new set_std function on soc_camera
      V4L/DVB (10087): Add new enum_input function on soc_camera
      V4L/DVB (10089): Add interlace support to sh_mobile_ceu_camera.c
      V4L/DVB (10092): Change V4L2 field to ANY from NONE on sh_mobile_ce=
u_camera.c
      V4L/DVB (10094): Add tw9910 driver
      V4L/DVB (10095): The failure of set_fmt is solved in tw9910
      V4L/DVB (10096): ov772x: change dev_info to dev_dbg
      V4L/DVB (10097): ov772x: clear i2c client data on error and remove
      V4L/DVB (10098): ov772x: fix try_fmt calculation method

Kusanagi Kouichi (1):
      tun: Fix SIOCSIFHWADDR error.

Kwangwoo Lee (1):
      Input: add tsc2007 based touchscreen driver

Kyle McMartin (7):
      parisc: use leX_to_cpu in place of __fswabX
      parisc: factor out sid to protid conversion
      parisc: fix braino in commit adding __space_to_prot
      parisc: quiet palo not-found message from "which"
      parisc: fix ipv6 checksum
      parisc: fix kernel crash (protection id trap) when compiling ruby1.=
9
      parisc: export length of os_hpmc vector

Kyungmin Park (2):
      [ARM] S3C64XX: Show uncompress messages
      [ARM] S3C64XX: Mask the pll values correctly

Lachlan McIlroy (21):
      [XFS] Remove kmem_zone_t argument from xfs_inode_init_once()
      [XFS] Use xfs_idestroy() to cleanup an inode.
      [XFS] Fix use-after-free with log and quotas
      [XFS] Unlock inode before calling xfs_idestroy()
      [XFS] Wait for all I/O on truncate to zero file size
      [XFS] Make xfs_btree_check_ptr() debug-only code.
      [XFS] Fix build warning - xfs_fs_alloc_inode() needs a return state=
ment
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-=
2.6
      [XFS] Check return value of xfs_buf_get_noaddr()
      [XFS] Remove unused variable in ktrace_free()
      [XFS] Remove unnecessary assertion
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-=
2.6
      [XFS] Remove unused tracing code
      [XFS] set b_error from bio error in xfs_buf_bio_end_io
      Merge branch 'master' of git+ssh://git.melbourne.sgi.com/git/xfs
      [XFS] Fix merge conflict in fs/xfs/xfs_rename.c
      [XFS] Use the incore inode size in xfs_file_readdir()
      [XFS] Remove XFS_BUF_SHUT() and friends
      [XFS] Fix speculative allocation beyond eof
      [XFS] Fix race in xfs_write() between direct and buffered I/O with =
DMAPI
      [XFS] Fix merge failures

Lai Jiangshan (17):
      markers: simplify marker_set_format()
      markers: remove exported symbol marker_probe_cb_noarg()
      markers: let marker_table be close to its comments
      tracepoint: simplification for tracepoints using RCU
      tracepoint: introduce *_noupdate APIs.
      ring_buffer: fix comments
      tracing/ring-buffer: remove unused ring_buffer size
      ftrace: enable format arguments checking
      cgroups: add lock for child->cgroups in cgroup_post_fork()
      cgroups: fix cgroup_iter_next() bug
      cgroups: don't put struct cgroupfs_root protected by RCU
      cgroups: use task_lock() for access tsk->cgroups safe in cgroup_clo=
ne()
      cgroups: call find_css_set() safely in cgroup_attach_task()
      cgroups: remove rcu_read_lock() in cgroupstats_build()
      devcgroup: use list_for_each_entry_rcu()
      memcontrol: rcu_read_lock() to protect mm_match_cgroup()
      cpuset: rcu_read_lock() to protect task_cs()

Larry Finger (22):
      p54: Move rx_mtu to struct bootrec_desc
      hostap: Fix sparse warnings
      rtl8187: Remove large delays
      rtl8187: Remove OFDM delays
      rtl8187: Remove CCK delays
      rtl8187: Remove msleep calls after calls to rtl8225_write
      rtl8187: Remove primitive write delays
      rtl8187: Reduce channel switch delay
      rtl8187: Change TX power settings
      Move all rtl818x files to a common directory.
      Update of MAINTAINERS for RTL8187
      rtl8187: Update file authorship in comments
      rtl8187: Remove module warning and dependence on CONFIG_EXPERIMENTA=
L
      mac80211: Fix pid rate-setting algorithm to allow rate changes
      rtl8187: Fix transmission count sent to mac80211
      rtl8187: Improve wireless statistics for RTL8187
      rtl8187: Use usb anchor facilities to manage urbs
      b43legacy: Fix sparse warnings
      rtl8187: Fix error returns
      mac80211: Print unknown packet type in tasklet_handler
      [SCSI] aha152x_cs: Fix regression that keeps driver from using shar=
ed interrupts
      hp-wmi: handle rfkill_register() failure

Laurent Pinchart (18):
      V4L/DVB (9567): uvcvideo: Add support for Samsung Q310 integrated w=
ebcam
      V4L/DVB (9568): uvcvideo: Add support for Lenovo Thinkpad SL500 int=
egrated webcam
      V4L/DVB (9569): uvcvideo: Sort the frame descriptors during parsing
      V4L/DVB (9570): uvcvideo: Handle failed video GET_{MIN|MAX|DEF} req=
uests more gracefully
      V4L/DVB (9659): uvcvideo: Use {get|set}_unaligned_le32 macros
      V4L/DVB (9661): uvcvideo: Commit streaming parameters when enabling=
 the video stream
      V4L/DVB (9662): uvcvideo: Fix printk badness when printing ioctl na=
mes
      V4L/DVB (9809): uvcvideo: Add nodrop module parameter to turn incom=
plete frame drop off.
      V4L/DVB (9810): uvcvideo: Add a device quirk to prune bogus control=
s.
      V4L/DVB (9897): v4l2: Add camera zoom controls
      V4L/DVB (9898): v4l2: Add privacy control
      V4L/DVB (9899): v4l2: Add missing control names
      V4L/DVB (9902): uvcvideo: V4L2 privacy control support
      V4L/DVB (9903): uvcvideo: V4L2 zoom controls support
      V4L/DVB (10101): uvcvideo: Fix bulk URB processing when the header =
is erroneous
      V4L/DVB (10102): uvcvideo: Ignore interrupt endpoint for built-in i=
Sight webcams.
      V4L/DVB (10104): uvcvideo: Add support for video output devices
      Check fops_get() return value

Lauri Leukkunen (1):
      ARM: OMAP2: Use omap_rev() instead of system_rev

Lee Nipper (2):
      crypto: talitos - Implement done interrupt mitigation
      crypto: talitos - Ack done interrupt in isr instead of tasklet

Len Brown (21):
      drivers/misc/Makefile, Kconfig: cleanup
      create drivers/platform/x86/ from drivers/misc/
      ACPI: move wmi, asus_acpi, toshiba_acpi to drivers/platform/x86
      ACPI: disable MPS when NO APIC-table found
      ACPI: simplify buffer management for acpi_pci_bind() etc.
      ACPICA: delete acdisasm.h
      ACPICA: delete utcache.c
      ACPI: fix build warning
      ACPICA: create acpica/ directory
      ACPICA: hide private headers
      Merge branch 'alarm' into release
      Merge branch 'asus-eeepc' into release
      Merge branch 'battery' into release
      Merge branches 'release', 'bugzilla-11880', 'bugzilla-12037' and 'b=
ugzilla-12257' into release
      Merge branch 'fluff' into release
      Merge branch 'fujitsu-laptop' into release
      Merge branch 'misc' into release
      Merge branch 'suspend' into release
      Merge branch 'linus' into release
      Merge branch 'simplify_PRT' into release
      Merge branch 'drivers-platform' into release

Lennert Buytenhek (11):
      mv643xx_eth: checkpatch fixes
      mv643xx_eth: introduce per-port register area pointer
      mv643xx_eth: inline txq_alloc_desc_index()
      mv643xx_eth: implement ->set_rx_mode()
      mv643xx_eth: move receive error handling out of line
      mv643xx_eth: calculate descriptor pointer only once in rxq_refill()
      [ARM] Orion: share GPIO handling code
      [ARM] Orion: share GPIO IRQ handling code
      [ARM] Kirkwood: implement GPIO and GPIO interrupt support
      [ARM] mv78xx0: implement GPIO and GPIO interrupt support
      tcp: don't mask EOF and socket errors on nonblocking splice receive

Leon Woestenberg (1):
      Staging: add Driver for Altera PCI Express Chaining DMA reference d=
esign

Leonardo Potenza (1):
      x86: fix section mismatch warnings in mcheck/mce_amd_64.c

Lev Babiev (1):
      HID: driver for TopSeed Cyberlink quirky remote

Li YanBo (1):
      Staging: add agnx wireless driver

Li Yang (1):
      gianfar: ensure ECNTRL[R100] is cleared on link state change

Li Zefan (31):
      Btrfs: async-thread: fix possible memory leak
      sched: cleanup for alloc_rt/fair_sched_group()
      sched: switch sched_features to seqfile
      sched debug: remove sd_level_to_string()
      sched debug: remove NULL checking in print_cfs/rt_rq()
      sched: remove redundant call to unregister_sched_domain_sysctl()
      sched: add sanity check in partition_sched_domains()
      sched: clean up SCHED_CPUMASK_ALLOC
      cls_cgroup: fix an oops when removing a cgroup
      cls_cgroup: clean up for cgroup part
      cls_cgroup: clean up Kconfig
      cpumask: fix bogus kernel-doc
      cgroups: fix a race between cgroup_clone and umount
      sched: mark sched_create_sysfs_power_savings_entries() as __init
      sched: clean up arch_reinit_sched_domains()
      vfs: remove duplicate code in get_fs_type()
      sched: fix double kfree in failure path
      sched: fix section mismatch
      cgroups: documentation updates
      cgroups: remove some redundant NULL checks
      ns_cgroup: remove unused spinlock
      memcg: fix a typo in Kconfig
      cgroups: make root_list contains active hierarchies only
      cgroups: add inactive subsystems to rootnode.subsys_list
      cgroups: introduce link_css_set() to remove duplicate code
      cpuset: remove on stack cpumask_t in cpuset_sprintf_cpulist()
      cpuset: remove on stack cpumask_t in cpuset_can_attach()
      cpuset: convert cpuset_attach() to use cpumask_var_t
      cpuset: don't allocate trial cpuset on stack
      cpuset: convert cpuset->cpus_allowed to cpumask_var_t
      cpuset: remove remaining pointers to cpumask_t

Liming Wang (5):
      ftrace: adding other non-leaving .text sections
      ftrace: improve seq_operation of ftrace
      softirq: remove useless function __local_bh_enable
      function trace: fix a bug of single thread function trace
      ftrace: avoid duplicated function when writing set_graph_function

Lin Ming (15):
      ACPICA: Fix possible memory leak on error in parser
      ACPICA: Allow multiple backslash prefix in namepaths
      ACPICA: Enhance implicit return mechanism
      ACPI: osl.c: replace return_ACPI_STATUS with return
      ACPI: ec.c: call acpi_get_name to get node name
      ACPI: proc.c: remove ACPI_FUNCTION_TRACE
      ACPI: wakeup.c: remove ACPI_FUNCTION_TRACE
      ACPI: main.c: use new public GPE group enable/disable interfaces
      ACPI: sony-laptop.c: call acpi_get_object_info to get node info
      ACPI: power.c: call acpi_get_name to get node name
      ACPI: panasonic-laptop.c: remove ACPI_FUNCTION_TRACE
      ACPI: io_acpi_init.c: call acpi_get_name to get node fullname
      ACPI: io_common.c: call acpi_get_table to avoid using ACPI_SIG_DSDT
      ACPI: reboot.c: use new acpi_reset interface
      ACPI: remove private acpica headers from driver files

Linda Knippers (1):
      btrfsctl -A error code fixup

Linus Torvalds (139):
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/lethal/sh-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/herbert/crypto-=
2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jmorris/security-testing-2.6
      Merge branch 'x86-core-for-linus' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/tip/linux-2.6-tip
      Merge branch 'tracing-core-for-linus' of git://git.kernel.org/pub/s=
cm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'sched-core-for-linus' of git://git.kernel.org/pub/scm=
/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for-linus' of git://git390.osdl.marist.edu/pub/scm/li=
nux-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/roland/infiniband
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/sfrench/cifs-2.=
6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-=
2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/geert/linux-m68k
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/wim/linux-2.6-n=
vram
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/sam/kbuild-next
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jmorris/security-testing-2.6
      Merge branch 'next' of git://git.kernel.org/pub/scm/linux/kernel/gi=
t/paulus/powerpc
      Merge branch 'core-for-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/tip/linux-2.6-tip
      Merge branch 'timers-core-for-linus' of git://git.kernel.org/pub/sc=
m/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'irq-core-for-linus' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for-2.6.29' of git://git.kernel.dk/linux-2.6-block
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-nex=
t-2.6
      Merge branch 'agp-next' of git://git.kernel.org/pub/scm/linux/kerne=
l/git/airlied/agp-2.6
      Merge branch 'drm-next' of git://git.kernel.org/pub/scm/linux/kerne=
l/git/airlied/drm-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/penberg/slab-2.6
      Merge branch 'oprofile-for-linus' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/tip/linux-2.6-tip
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/jgarzik/libata-dev
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/shaggy/jfs-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/bart/ide-2.6
      Merge branch 'devel' of master.kernel.org:/home/rmk/linux-2.6-arm
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/rusty/linux-2.6=
-for-linus
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/mchehab/linux-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/jejb/scsi-misc-=
2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/roland/infiniband
      Merge git://git.linux-nfs.org/projects/trondmy/nfs-2.6
      Merge branch 'for-linus' of git://oss.sgi.com/xfs/xfs
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/hirofumi/fatfs-=
2.6
      Merge branch 'irq-fixes-for-linus-4' of git://git.kernel.org/pub/sc=
m/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/viro/vfs-2.6
      ide-floppy: allocate only toplevel packet commands
      Sanitize gcc version header includes
      Disallow gcc versions 4.1.{0,1}
      Merge branch 'tty-updates' from Alan
      Merge branch 'i8k-updates' from Alan
      Merge branch 'for-upstream' of git://git.kernel.org/pub/scm/linux/k=
ernel/git/dvrabel/uwb
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/bart/ide-2.6
      Merge branch 'kvm-updates/2.6.29' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/avi/kvm
      Merge branch 'cpus4096-for-linus-2' of git://git.kernel.org/pub/scm=
/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/sam/kbuild-next
      Merge branch 'linux-next' of git://git.infradead.org/~dedekind/ubi-=
2.6
      Merge branch 'linux-next' of git://git.infradead.org/ubifs-2.6
      Make %p print '(null)' for NULL pointers
      Merge branch 'cputime' of git://git390.osdl.marist.edu/pub/scm/linu=
x-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/wim/linux-2.6-w=
atchdog
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/drzeus/mmc
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/mchehab/linux-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/joro/linux-2.6-iommu
      Merge branch 'cpus4096-for-linus-3' of git://git.kernel.org/pub/scm=
/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'audit.b61' of git://git.kernel.org/pub/scm/linux/kern=
el/git/viro/audit-current
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/viro/vfs-2.6
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/mfasheh/ocfs2
      Merge branch 'next' of git://git.kernel.org/pub/scm/linux/kernel/gi=
t/davej/cpufreq
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-2.6
      igb: fix anoying type mismatch warning on rx/tx queue sizing
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/steve/gfs2-2.6-=
nmw
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jikos/hid
      Merge branch 'i2c-next' of git://aeryn.fluff.org.uk/bjdooks/linux
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/teigland/dlm
      Merge branch 'core-fixes-for-linus' of git://git.kernel.org/pub/scm=
/linux/kernel/git/tip/linux-2.6-tip
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/rusty/linux-2.6=
-for-linus
      Merge branch 'for-next' of git://git.o-hand.com/linux-mfd
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/agk/linux-2.6-d=
m
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/bart/ide-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/mszeredi/fuse
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-c=
ore-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging-=
2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge branch 'core-fixes-for-linus' of git://git.kernel.org/pub/scm=
/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'irq-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'sched-fixes-for-linus' of git://git.kernel.org/pub/sc=
m/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'timers-fixes-for-linus' of git://git.kernel.org/pub/s=
cm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jmorris/security-testing-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/dtor/input
      Merge branch 'drm-next' of git://git.kernel.org/pub/scm/linux/kerne=
l/git/airlied/drm-2.6
      Fix up 64-bit byte swaps for most 32-bit architectures
      PCI: extend on the ICH motherboard IO decode quirk list
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jikos/trivial
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/czankel/xtensa-=
2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/steve/gfs2-2.6-=
fixes
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/hskinnemoen/avr=
32-2.6
      Merge branch 'i2c-for-linus' of git://jdelvare.pck.nerim.net/jdelva=
re-2.6
      Merge branch 'hwmon-for-linus' of git://jdelvare.pck.nerim.net/jdel=
vare-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/cooloney/blackfin-2.6
      Merge branch 'proc-linus' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/adobriyan/proc
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/ieee1394/linux1394-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/sam/kbuild-fixe=
s
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/arjan/linux-2.6=
-async
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/usb-2.6
      Merge branch 'linux-next' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/jbarnes/pci-2.6
      Merge branch 'sched-fixes-for-linus' of git://git.kernel.org/pub/sc=
m/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for-2.6.29' of git://linux-nfs.org/~bfields/linux
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/mchehab/linux-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-2.6
      Merge branch 'next' of git://git.kernel.org/pub/scm/linux/kernel/gi=
t/benh/powerpc
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/jgarzik/libata-dev
      Merge branch 'for-linus' of git://neil.brown.name/md
      Merge master.kernel.org:/home/rmk/linux-2.6-arm
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/lrg/voltage-2.6
      Merge branch 'docs-next' of git://git.lwn.net/linux-2.6
      Merge branch 'bkl-removal' of git://git.lwn.net/linux-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/jejb/scsi-misc-=
2.6
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tytso/ext4
      Merge branch 'next' of git://git.kernel.org/pub/scm/linux/kernel/gi=
t/djbw/async_tx
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/kyle/parisc-2.6
      Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel=
/git/lenb/linux-acpi-2.6
      Merge git://git.infradead.org/mtd-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/rric/oprofile
      x86: make 'constant_test_bit()' take an unsigned bit number
      Merge branch 'for-2.6.29' of git://git.kernel.dk/linux-2.6-block
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/mason/btrfs-uns=
table
      Merge branch 'for-linus' of git://git.o-hand.com/linux-rpurdie-back=
light
      Merge branch 'for-linus' of git://git.o-hand.com/linux-rpurdie-leds
      Merge branch 'for-linus' of git://git390.osdl.marist.edu/pub/scm/li=
nux-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jmorris/security-testing-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-=
2.6-nommu
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/pkl/squashfs-li=
nus
      Merge branch 'for_2.6.29' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/kkeil/ISDN-2.6
      Merge git://git.infradead.org/mtd-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/ieee1394/linux1394-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-c=
ore-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/arjan/linux-2.6=
-async-2
      btrfs: fix for write_super_lockfs/unlockfs error handling
      Merge branch 'cpus4096-for-linus' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/tip/linux-2.6-tip
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Linux 2.6.29-rc1

Lior Dotan (3):
      Staging: slicoss: use kzalloc
      Staging: slicoss: use correct type for memory allcations
      Staging: slicoss: use request_firmware

Liu Hui (5):
      Btrfs: Some fixes for batching extent insert.
      Btrfs: Fix cow semantic in run_delalloc_nocow()
      Btrfs: Fix cow semantic in run_delalloc_nocow()
      Btrfs: Fix typo in clear_state_cb
      Btrfs: Fix free block discard calls down to the block layer

Liu Yu (4):
      powerpc/math-emu: Fix single float point division bug
      powerpc/math-emu: Adopt new version of _FP_CHOOSENAN
      powerpc/math-emu: Remove redundant 'ret'
      powerpc: Add SPE/EFP math emulation for E500v1/v2 processors.

Lubomir Bulej (1):
      libata: blacklist NCQ on OCZ CORE 2 SSD (resend)

Luis R. Rodriguez (33):
      ath5k/ath9k: correct signal quality
      ath9k: correct signal quality report
      ath5k: correct ath5k signal quality
      mac80211: make use of regulatory tx power settings on change of tx =
power
      ath9k: remove pointless sc_txintrperiod and spin_lock_bh on tx prep=
are
      ath9k: enable RX interrupt mitigation
      ath9k: Allow user to change tx power when asked
      ath9k: use ETH_P_PAE
      cfg80211: a reg rule is invalid if freq diff is 0
      cfg80211: Add regulatory domain intersection capability
      cfg80211: make use of reg macros on REG_RULE
      cfg80211: Add kdoc for struct regulatory_request
      ath5k: allow APs to receive beacons
      ath9k: enable RXing of beacons on STA/IBSS
      cfg80211: mark negative frequencies as invalid
      cfg80211: remove switch from __regulatory_hint()
      cfg80211: remove switch from __set_regdom()
      cfg80211: separate intersection section in __set_regdom()
      cfg80211: expect different rd in cfg80211 when intersecting
      cfg80211: call_crda() won't tell us if CRDA was present
      cfg80211: mark regdomains with > NL80211_MAX_SUPP_REG_RULES invalid
      cfg80211/mac80211: Add 802.11d support
      cfg80211: add support for custom firmware regulatory solutions
      iwlwifi: enable custom fw regulatory solution
      ath9k: Clarify we only want 32-bit DMA
      ath9k: make DMA memory consistent
      mac80211: don't assume driver has been attached on registration
      mac80211: make Minstrel the default rate control algorithm
      ath9k: Handle -ENOMEM on RX gracefully
      nl80211: relicense nl80211.h under the ISC
      ath9k: Check for pci_map_single() errors
      ath9k: Use GFP_ATOMIC when allocating TX private area
      Staging: add otus Atheros wireless network driver

Luiz Fernando N. Capitulino (1):
      fs/exec.c:__bprm_mm_init(): clean up error handling

Lukasz Lubojanski (1):
      HID: force feedback driver for GreenAsia 0x12 PID

Luotao Fu (1):
      smc91x: remove isa stuff from smc91x driver

Magnus Damm (42):
      sh: enable and disable clocks recursively
      sh: sh_mobile clock divider index fix
      sh: use arch_flags for sh_mobile mstpcr clock bits
      sh: new sh_mobile mstpcr clocks base code
      sh: sh_mobile mstpcr clocks for sh7722
      sh: sh_mobile mstpcr clocks for sh7723
      sh: sh_mobile mstpcr clocks for sh7343
      sh: sh_mobile mstpcr clocks for sh7366
      sh: sh_mobile i2c clock framework support
      sh: sh_mobile keysc clock framework support
      sh: sh_mobile ceu clock framework support
      sh: sh_mobile usbf clock framework support
      sh: sh_mobile usb clock framework support
      sh: sh_mobile lcdc clock framework support
      sh: remove old sh_mobile mstpc clocks
      sh: P4 ioremap pass-through
      sh: propagate r_clk
      sh: sh7343 scif configuration update
      sh: fix number of interrupts on se7343
      sh: add st16c2550 devices to se7343
      sh: add isp1161 usb host device to se7343
      sh: remove ioport cruft and smc91x from se7343
      sh: update se7343 defconfig
      sh: move the hp6xx pm code
      sh: allow CONFIG_PM
      sh: allow CONFIG_CPU_IDLE
      sh: add ov772x reset delay on Migo-R
      sh: split coherent pages
      sh_mobile_lcdc: use FB_SYS helpers instead of FB_CFB
      sh: add LCDC interrupt configuration to AP325 and Migo-R
      video: fix deferred io fsync()
      video: deferred io cleanup
      video: deferred io with physically contiguous memory
      video: sh_mobile_lcdcfb deferred io support
      sh: enable deferred io LCDC on Migo-R
      V4L/DVB (10078): video: add NV16 and NV61 pixel formats
      V4L/DVB (10079): sh_mobile_ceu: use new pixel format translation co=
de
      V4L/DVB (10084): sh_mobile_ceu: add NV12 and NV21 support
      V4L/DVB (10085): sh_mobile_ceu: add NV16 and NV61 support
      V4L/DVB (10088): video: sh_mobile_ceu cleanups and comments
      USB: m66592 and r8a66597 resource changes
      vmcore: remove saved_max_pfn check

Manu Abraham (79):
      V4L/DVB (9344): DVB-Core update
      V4L/DVB (9478): Fix: parameters not supplied in the search process
      V4L/DVB (9375): Add STB0899 support
      V4L/DVB (9376): Add STB0899 to build
      V4L/DVB (9377): Add STB6100 Support
      V4L/DVB (9378): Add STB6100 Support
      V4L/DVB (9379): FIX: fix a bug in the charge pump setting
      V4L/DVB (9380): FIX: a possible division by zero
      V4L/DVB (9381): On the KNC1 cards the CLOCK is clamped to a maximum=
 limit of 90MHz, eventhough
      V4L/DVB (9382): Use a delay for tracking acquisition status
      V4L/DVB (9383): Let's neither sleep nor wakeup for now
      V4L/DVB (9384): FIX: register value is not reset to 0 after write
      V4L/DVB (9386): FIX: Add in missing inversion (should be ideally in=
 the config struct)
      V4L/DVB (9387): FIX: Write to the correct register
      V4L/DVB (9392): initial go at TDA8261 tuner
      V4L/DVB (9393): Add TDA8261 to build
      V4L/DVB (9394): cache last successful state
      V4L/DVB (9395): Add initial support for two KNC1 DVB-S2 boards
      V4L/DVB (9396): Fix clocks at stb0899
      V4L/DVB (9397): fix some bugs at tda8261
      V4L/DVB (9399): some cleanups at budget-ci
      V4L/DVB (9400): stb6100: Code Simplification
      V4L/DVB (9401): Code Simplification
      V4L/DVB (9402): TT S2 3200 shouldn't need Inversion ON and Inversio=
n AUTO at the same time
      V4L/DVB (9403): Fix the CA module not working issue
      V4L/DVB (9404): the KNC1 and clones also don't have the I/Q inputs =
swapped
      V4L/DVB (9405): Practical tests show that the TT S2 3200 has I/Q in=
puts inverted, similar to the KNC1.
      V4L/DVB (9407): Optimizations Reduce capture range from 10MHz to 3M=
hz
      V4L/DVB (9408): tda8261: check status to avoid lock loss
      V4L/DVB (9409): Bug! inverted logic
      V4L/DVB (9410): Bug: Missing reference clock definition
      V4L/DVB (9411): Bug! Timing recovery was calculated for 99MHz not 9=
0 MHz
      V4L/DVB (9412): Fix tuner name and comment
      V4L/DVB (9413): Bug: Set Auxilliary Clock Register correctly
      V4L/DVB (9414): Initialize DiSEqC
      V4L/DVB (9416): Hmmph, a proper calculation broke the working behav=
iour.
      V4L/DVB (9417): DVB_ATTACH for STB0899, STB6100, TDA8261
      V4L/DVB (9418): DVB_ATTACH for STB0899, STB6100, TDA8261
      V4L/DVB (9419): Bug: unnecessary large current causes large phasor =
errors
      V4L/DVB (9420): return -EINVAL for invalid parameters
      V4L/DVB (9421): We must wait for the PLL to stabilize
      V4L/DVB (9422): Bug: Fix a typo
      V4L/DVB (9423): Though insignificant, removes an unnecessary read o=
f the LOCK_LOSS register,
      V4L/DVB (9424): Deviation from the reference, pullup is 12k instead
      V4L/DVB (9425): Initialize at 90MHz itself
      V4L/DVB (9426): Add a missing break
      V4L/DVB (9427): Code simplification: Sleep only for the required ti=
me interval.
      V4L/DVB (9431): Bug ID #19: Diseqc works properly at 90MHz only on =
Cut 1.1 and 2.0
      V4L/DVB (9434): Limit initial RF AGC gain
      V4L/DVB (9435): Add post process interfaces
      V4L/DVB (9436): Fix a typo in the previous commit
      V4L/DVB (9437): Disable Symbol rate auto scan feature
      V4L/DVB (9439): Bug! SFRL nibble got swapped
      V4L/DVB (9441): Code simplification: clock is already initialized, =
no need to initialize again.
      V4L/DVB (9442): Revert back previous change to 90MHz
      V4L/DVB (9443): Bug: Bandwidth calculation
      V4L/DVB (9444): Initialize post process events to NULL
      V4L/DVB (9450): Code Review: #4 Consolidate configurations
      V4L/DVB (9451): Bug! F/3 Clock domain was incorrectly used
      V4L/DVB (9452): Fix invalid GCT mode
      V4L/DVB (9453): stb0899: fix compilation warnings
      V4L/DVB (9454): Fix a compile warning
      V4L/DVB (9455): Cleanup: remove some superfluous stuff and dead com=
mented out code
      V4L/DVB (9456): Select STB0899, STB6100, TDA8261 for budget_ci and =
budget_av respectively.
      V4L/DVB (9457): Optimization, Fix a Bug
      V4L/DVB (9458): Bugfix: gate control needs to be handled
      V4L/DVB (9459): We can now reduce the debug levels, just need to lo=
ok at errors only.
      V4L/DVB (9460): Code Simplification
      V4L/DVB (9461): Initialize SYSREG register
      V4L/DVB (9462): Allow specifying clock per device
      V4L/DVB (9463): Make delivery system standalone.
      V4L/DVB (9464): Remove unreferenced delivery
      V4L/DVB (9465): Fix incorrect IF_AGC Bitfield definition
      V4L/DVB (9466): Bug: Fix incorrect Register definitions
      V4L/DVB (9469): Port STB0899 and STB6100
      V4L/DVB (9479): Wait for a maximum of 100mS
      V4L/DVB (9425): Initialize at 90MHz itself
      V4L/DVB (9431): Bug ID #19: Diseqc works properly at 90MHz only on =
Cut 1.1 and 2.0
      V4L/DVB (9442): Revert back previous change to 90MHz

Manuel Lauss (2):
      rtc: Au1000 On-Chip Counter0-as-RTC driver.
      hwmon: (lm70) Add TI TMP121 support

Marc Eshel (1):
      nfsd: delete wrong file comment from nfsd/nfs4xdr.c

Marc Kleine-Budde (3):
      imxmmc: Checkpatch cleanup
      imxmmc: Remove unused variables
      imxmmc: use readl/writel

Marc Zyngier (1):
      [ARM] pxa: cpufreq-pxa2xx: allow frequency table selection

Marcel Holtmann (10):
      Bluetooth: Add fine grained mem_flags usage to btusb driver
      Bluetooth: Handle bulk URBs in btusb driver from notify callback
      Bluetooth: Add suspend/resume support to btusb driver
      Bluetooth: Fix warnings for bt_key_strings and bt_slock_key_strings
      Bluetooth: Remove deprecated hci_usb driver
      Bluetooth: Send HCI Reset command by default on device initializati=
on
      Bluetooth: Allow SCO audio with Asus WL-BTD202 dongle
      Bluetooth: Enable per-module dynamic debug messages
      Bluetooth: Fix format arguments warning
      Bluetooth: Fix RFCOMM release oops when device is still in use

Marcelo Tosatti (7):
      KVM: MMU: optimize set_spte for page sync
      KVM: MMU: use page array in unsync walk
      KVM: MMU: collapse remote TLB flushes on root sync
      KVM: MMU: skip global pgtables on sync due to cr3 switch
      KVM: MMU: prepopulate the shadow on invlpg
      KVM: MMU: check for present pdptr shadow page in walk_shadow
      KVM: MMU: handle large host sptes on invlpg/resync

Marcin Slusarz (3):
      cdrom: split mmc_ioctl to lower stack usage
      cdrom: reduce stack usage of mmc_ioctl_dvd_read_struct
      USB: emi26: fix oops on load

Marco Schluessler (1):
      V4L/DVB (9480): Fix frontend DVBFE_ALGO_CUSTOM Search

Marek Vasut (1):
      ASoC: Add Palm/PXA27x unified ASoC audio driver

Mario Schwalbe (1):
      ide: Fix drive's DWORD-IO handling

Mark Brown (93):
      ALSA: ASoC: Remove snd_soc_dapm_connect_input()
      ASoC: Fix handling of DAPM suspend work
      ASoC: Convert core to use standard debug print macros
      ASoC: Remove DAPM restriction on mixer control name lengths
      ASoC: Add PXA SSP support
      ASoC: Do a warm reset after cold when resetting the WM9713
      ASoC: Use finer grained dependencies in SND_SOC_ALL_CODECS
      ASoC: Remove core version number
      ASoC: Revert "ASoC: Add new parameter to s3c24xx_pcm_enqueue"
      ASoC: Add WM8728 codec driver
      ASoC: Allow writes to uncached registers in WM8990
      ASoC: Enable WM8990 ADC clocking workaround
      ASoC: Manage VMID mode for WM8990
      ASoC: Build tlv320aic23 cleanly
      ASoC: Move uda134x_codec.h to uda134x.h
      ASoC: Remove unused snd_soc_machine_config declaration
      ASoC: s3c24xx_uda134x DAI accessor functions and static cleanup
      ASoC: Convert blackfin machines to use DAI accessor functions
      ASoC: Rename snd_soc_card to snd_soc_machine
      ASoC: Add abbreviation to maintainers for searchability
      ASoC: Move DAI structure definitions into new soc-dai.h
      ASoC: Merge snd_soc_ops into snd_soc_dai_ops
      ASoC: Add Marvell Zylonite machine support
      ASoC: Staticise pxa2xx_pcm_ops
      ASoC: Improve error reporting for AC97 reset failures
      ALSA: ASoC: Fix typo in snd_soc_card update documentation
      ASoC: Use supplied DAI for WM9713 rather than substream
      ASoC: Remove DAI type information
      ASoC: Flag AD1980 as an AC97 interface
      ASoC: Lower priority of resume work logging
      ASoC: Fix word wrapping in OMAP Kconfig
      ALSA: ac97 - Add WM9715 to AC97 IDs
      ASoC: Rename snd_soc_register_card() to snd_soc_init_card()
      ASoC: Annotate core removal function
      ASoC: Remove in-code changelog from AD73311 driver
      ASoC: Don't free static data in WM9713
      ASoC: Push workqueue data into snd_soc_card
      ALSA: ac97 - Include ac97_codec.h for ac97_bus_type declaration
      ASoC: Push platform registration down into the card
      ASoC: Fix WM8903 right mixer bypass path
      ASoC: Push debugfs files out of the snd_soc_device structure
      ASoC: Remove device from platform suspend and resume operations
      ASoC: Remove platform device from DAI suspend and resume operations
      ASoC: Remove obsolete declaration of struct snd_soc_clock_info
      ASoC: Add card registration API
      ASoC: Add DAI registration API
      ASoC: Register platform DAIs
      ASoC: Add platform registration API
      ASoC: Register platform drivers
      ASoC: Register non-AC97 codec DAIs
      ASoC: Initial framework for dynamic card instantiation
      ASoC: Wait for non-AC97 codec DAIs before instantiating
      ASoC: Convert WM8900 to allow registration by machine code
      ASoC: Fix typos in Atmel module registration
      ASoC: Work around warnings from some build environments
      ALSA: Add support for mechanical jack insertion
      ASoC: Add codec registration API
      ASoC: Convert WM8900 to do more work at I2C probe time
      ASoC: Convert WM8903 driver to register at I2C probe time
      ASoC: Stop WM8903 SYSCLK when suspending
      ASoC: Fix variable name for Blackfin I2S DAI
      ALSA: Fix declaration of sound_class
      ASoC: Ease merge difficulties from new architectures
      ASoC: Complain if we fail to create DAPM controls
      ASoC: Add WM8350 AudioPlus codec driver
      [WATCHDOG] Add support for the WM8350 watchdog
      ASoC: Clean up kerneldoc warnings
      mfd: Don't mark WM8350 security register as volatile
      mfd: Remove i.MX31ism from WM8350 i2c driver
      mfd: Add some documentation for WM8350 register lock
      mfd: Add WM8350 revision H support
      mfd: Add AUXADC support for WM8350
      power_supply: Add support for WM8350 PMU
      mfd: Switch WM8350 revision detection to a feature based model
      mfd: Refactor WM8350 chip identification
      power_supply: Add cold to the POWER_SUPPLY_HEALTH report values
      power_supply: Add battery health reporting for WM8350
      mfd: Pass driver_data onto child devices
      mfd: Register WM8400 codec device
      mfd: Add WM8352 support
      mfd: Handle missing WM8350 platform data
      mfd: Support configurable numbers of DCDCs and ISINKs on WM8350
      mfd: Add WM8351 support
      mfd: Add missing break from wm3850-core
      mfd: Fix section mismatch in da903x
      ASoC: Use snd_soc_dapm_nc_pin() in at91sam9g20ek
      ASoC: Fix SND_SOC_ALL_CODECS handling of dual SPI and I2C control b=
uses
      leds: Add WM8350 LED driver
      regulator: Remove extraneous kerneldoc annotations
      regulator: Clean up kerneldoc warnings
      regulator: Add missing kerneldoc
      regulator: Fix some kerneldoc rendering issues
      regulator: Add basic DocBook manual

Mark Fasheh (10):
      Btrfs: Null terminate strings passed in from userspace
      jbd2: Add BH_JBDPrivateStart
      ocfs2: turn __ocfs2_remove_inode_range() into ocfs2_remove_btree_ra=
nge()
      ocfs2: Remove JBD compatibility layer
      ocfs2: Periodic quota syncing
      jbd2: Add BH_JBDPrivateStart
      ocfs2: Use BH_JBDPrivateStart instead of BH_Unshadow
      ocfs2: Add directory block trailers.
      ocfs2: remove unneeded lvb casts
      ocfs2: use min_t in ocfs2_quota_read()

Mark Jackson (1):
      MIMC200: Remove deprecated call

Mark Lord (3):
      /proc/acpi/alarm: handle day-of-month wraparound on readback
      V4L/DVB (10157): Add USB ID for the Sil4701 radio from DealExtreme
      USB: fix minor nit in usbfs checking

Mark McLoughlin (28):
      virtio_net: Recycle some more rx buffer pages
      virtio_net: hook up the set-tso ethtool op
      virtio_net: VIRTIO_NET_F_MSG_RXBUF (imprive rcv buffer allocation)
      virtio_net: large tx MTU support
      virtio: add PCI device release() function
      lguest: struct device - replace bus_id with dev_name()
      KVM: remove the IRQ ACK notifier assertions
      KVM: make kvm_unregister_irq_ack_notifier() safe
      KVM: don't free an unallocated irq source id
      KVM: add KVM_USERSPACE_IRQ_SOURCE_ID assertions
      KVM: split out kvm_free_assigned_irq()
      KVM: fix handling of ACK from shared guest IRQ
      intel-iommu: remove some unused struct intel_iommu fields
      intel-iommu: make init_dmars() static
      intel-iommu: move DMA_32/64BIT_PFN into intel-iommu.c
      intel-iommu: move root entry defs from dma_remapping.h
      intel-iommu: move context entry defs out from dma_remapping.h
      intel-iommu: move DMA PTE defs out of dma_remapping.h
      intel-iommu: move struct dmar_domain def out dma_remapping.h
      intel-iommu: move struct device_domain_info out of dma_remapping.h
      intel-iommu: kill off duplicate def of dmar_disabled
      intel-iommu: move iommu_prepare_gfx_mapping() out of dma_remapping.=
h
      intel-iommu: trivially inline context entry macros
      intel-iommu: trivially inline DMA PTE macros
      driver core: add root_device_register()
      virtio: do not statically allocate root device
      lguest: do not statically allocate root device
      s390: remove s390_root_dev_*()

Mark Nelson (5):
      powerpc: Add new CPU feature: CPU_FTR_UNALIGNED_LD_STD
      powerpc: Update 64bit memcpy() using CPU_FTR_UNALIGNED_LD_STD
      powerpc: Remove map_/unmap_single() from dma_mapping_ops
      powerpc: Update 64bit __copy_tofrom_user() using CPU_FTR_UNALIGNED_=
LD_STD
      [SCSI] ipr: fix lockdep warning from ipr_ioa_reset_done

Mark van Doesburg (3):
      hwmon: (f71882fg) Use sensor_device_attribute_2
      hwmon: (f71882fg) Misc cleanups
      hwmon: (f71882fg) Add PWM support

Marko Schluessler (7):
      V4L/DVB (9388): Reference Clock is in kHz
      V4L/DVB (9389): Use kzalloc instead of kmalloc
      V4L/DVB (9390): Offset Freq has been set in reg
      V4L/DVB (9391): Register definition bugs
      V4L/DVB (9398): Initial support for the Technotrend TT S2 3200
      V4L/DVB (9406): Really silly bug, setting bandwidth into frequency
      V4L/DVB (9428): Fix: assignment of wrong values

Markus Bollinger (5):
      ALSA: pcxhr - add support for pcxhr stereo sound cards
      ALSA: pcxhr - add support for pcxhr stereo sound cards (core change=
)
      ALSA: pcxhr - add support for pcxhr stereo sound cards (firmware su=
pport)
      ALSA: pcxhr - add support for pcxhr stereo sound cards (mixer part)
      ALSA: pcxhr - change firmware filenames

Markus Metzger (12):
      x86, bts: DS and BTS initialization
      x86, bts: base in-kernel ds interface on handles
      x86, bts, ptrace: move BTS buffer allocation from ds.c into ptrace.=
c
      x86, ftrace: call trace->open() before stopping tracing; add trace-=
>print_header()
      x86, bts, ftrace: a BTS ftrace plug-in prototype
      x86, bts: turn BUG_ON into WARN_ON_ONCE
      x86, bts: provide in-kernel branch-trace interface
      x86, bts, ftrace: adapt the hw-branch-tracer to the ds.c interface
      x86, bts: remove recursion from get_context
      x86, bts: correctly report invalid bts records
      x86, bts: add fork and exit handling
      x86, bts: memory accounting

Markus Rechberger (4):
      V4L/DVB (9362): zl10353: add new register configuration for zl10353=
/especially 6mhz taiwan.
      V4L/DVB (9363): tvp5150: add support to enable raw vbi
      V4L/DVB (9364): adding sharp s921 ISDB-T driver
      V4L/DVB (9365): adding lgdt3304 based driver

Markus Trippelsdorf (1):
      x86: remove debug printks (io_apic.c)

Martin Bachem (5):
      mISDN: Use protocol to detect D-channel
      mISDN: Add E-Channel logging features
      mISDN: Return error on E-channel access
      mISDN: Add ISDN_P_TE_UP0 / ISDN_P_NT_UP0
      mISDN: Add layer1 prim MPH_INFORMATION_REQ

Martin K. Petersen (4):
      [SCSI] Fix error handling for DIF/DIX
      [SCSI] sd: DIF: Show app tag on error
      [SCSI] sd: DIF: Fix tagging on platforms with signed char
      [SCSI] sd: Correctly handle 6-byte commands with DIX

Martin Schwidefsky (25):
      [S390] arch_setup_additional_pages arguments
      [S390] introduce vdso on s390
      [S390] serialize stp/etr work
      [S390] service level interface.
      [S390] __page_to_pfn warnings
      [S390] remove ptrace warning on 31 bit.
      [S390] remove warnings with functions ending in BUG
      [S390] Add processor type march=3Dz10 and a processor type safety c=
heck.
      [S390] add new machine types to setup_hwcaps.
      [S390] Remove config options.
      [S390] clear_table inline assembly contraints
      [S390] panic_stack leak in smp_alloc_lowcore
      [S390] convert xpram printks to pr_xxx macros.
      [S390] convert time printks to pr_xxx macros.
      [S390] convert setup printks to pr_xxx macros.
      [S390] convert ap_bus printks to pr_xxx macros.
      [S390] convert sclp printks to pr_xxx macros.
      [S390] convert cpu related printks to pr_xxx macros.
      [S390] convert vmlogrdr printks to pr_xxx macros.
      fix scaled & unscaled cputime accounting
      idle cputime accounting
      improve precision of process accounting.
      improve precision of idle time detection.
      improve idle cputime accounting
      fast vdso implementation for CLOCK_THREAD_CPUTIME_ID

Martin Willi (3):
      xfrm: Notify changes in UDP encapsulation via netlink
      xfrm: Accept XFRM_STATE_AF_UNSPEC SAs on IPv4/IPv6 only hosts
      xfrm: Accept ESP packets regardless of UDP encapsulation mode

Marton Balint (1):
      do_mounts: add device info to mount message

Martyn Welch (2):
      powerpc/86xx: Add use of Epson RTX-8581 RTC to GE Fanuc SBC610 dts
      powerpc/86xx: Basic GPIO support for GE Fanuc SBC610

Masakazu Mokuno (1):
      powerpc/ps3: Fix memory leak in device init

Masami Hiramatsu (10):
      kprobes: bugfix: try_module_get even if calling_mod is NULL
      kprobes: indirectly call kprobe_target
      kprobes: add tests for register_kprobes
      module: add within_module_core() and within_module_init()
      kprobes: add kprobe_insn_mutex and cleanup arch_remove_kprobe()
      kprobes: add __kprobes to kprobe internal functions
      kprobes: support probing module __exit function
      kprobes: remove called_from argument
      module: add MODULE_STATE_LIVE notify
      kprobes: support probing module __init function

Mathieu Desnoyers (15):
      rcu: add rcu_read_*_sched_notrace()
      markers: fix unregister
      markers: use rcu_*_sched_notrace and notrace
      markers: use module notifier
      markers: auto enable tracepoints (new API : trace_mark_tp())
      markers: create DEFINE_MARKER and GET_MARKER (new API)
      tracepoints: samples, fix teardown
      tracepoints: fix disable
      tracepoints: use rcu_*_sched_notrace
      tracepoints: use unregister return value
      tracepoints: do not put arguments in name
      tracepoints: use modules notifiers
      tracepoints: add DECLARE_TRACE() and DEFINE_TRACE()
      tracepoints: documentation fix for teardown
      tracepoints, docs: marker_synchronize_unregister->tracepoint_synchr=
onize_unregister

Matias Zabaljauregui (1):
      lguest: move the initial guest page table creation code to the host

Matt Carlson (30):
      tg3: Add 5761S support
      tg3: Use pci_ioremap_bar()
      tg3: Preserve DASH connectivity when WOL enabled
      tg3: Preserve LAA when device control is released
      tg3: Reclaim TG3_FLG3_5761_5784_AX_FIXES flag
      tg3: Do not enable APE on bcm5700
      tg3: Move phylib report to end of tg3_init_one
      tg3: Refine power management and WOL code
      tg3: Allow WOL for phylib controlled Broadcom phys
      tg3: Refine phylib support
      tg3: 5785 enhancements
      broadcom: Add flow control support
      broadcom: Refine expansion register access routine
      broadcom: Add support for BCM50610
      tg3: Update version to 3.95
      tg3: Use NET_IP_ALIGN
      tg3: Qualify use of tp->pcix_cap
      tg3: Prevent corruption at 10 / 100Mbps w CLKREQ
      tg3: Enable GPHY APD on select devices
      tg3: Extract FW ver from alt NVRAM formats
      tg3: Embrace pci_ioremap_bar()
      tg3: Allow GPHY powerdown on 5761
      tg3: Add 57780 support
      broadcom: Add 57780 support
      tg3: Update version to 3.96
      tg3: WOL fixes
      tg3: Cleanup IPV6 LSO
      tg3: Remove unused cfgspc device members
      tg3: tg3.h cleanups
      tg3: Update version to 3.97

Matt Fleming (10):
      ftrace: align __mcount_loc sections
      sh: dynamic ftrace support.
      ftrace: specify $alignment for sh architecture
      sh: dynamic ftrace support.
      sh: Switch HD64461 from hw_interrupt_type to irq_chip
      sh: Convert Microdev boards from hw_interrupt_type to irq_chip
      sh: Convert SystemH board support from hw_interrupt_type to irq_chi=
p
      sh: Convert Dreamcast support from hw_interrupt_type to irq_chip
      sh: Convert Cayman boards from hw_interrupt_type to irq_chip
      sh: Enable GENERIC_HARDIRQS_NO__DO_IRQ for all SuperH machines

Matt Helsley (1):
      HID: add proper support for pensketch 12x9 tablet

Matt Hsu (2):
      [ARM] S3C64XX: Correct the EINT IRQ type configuration
      [ARM] S3C64XX: Fix EINT group macro definition

Matt Mackall (3):
      tcp: Stop scaring users with "treason uncloaked!"
      shmem: unify regular and tiny shmem
      random: don't try to look at entropy_count outside the lock

Matt Palmer (2):
      [ARM] DNS323: Read MAC address from flash
      [ARM] DNS323: Initialise 88F5182 correctly

Matt Reimer (2):
      [MTD] [NAND] pxa3xx: fix non-page-aligned reads
      [MTD] [NAND] pxa3xx: convert from ns to clock ticks more accurately

Matthew Garrett (5):
      [CPUFREQ] Disable sysfs ui for p4-clockmod.
      Input: atkbd - broaden the Dell DMI signatures
      PCI/ACPI:  acpiphp: Identify more removable slots
      dcdbas: export functionality for use in other drivers
      misc: add dell-laptop driver

Matthew Ranostay (9):
      ALSA: hda: add support for jack detection on IDT/Sigmatel
      ALSA: hda: dynamic jack id
      ALSA: jack: lineout support to jack abstraction layer
      ALSA: hda: add snd_hda_get_jack* functions
      ALSA: hda: add support for jack detection on IDT codecs.
      ALSA: hda: STAC_DELL_M6 EAPD
      ALSA: hda: EAPD mute on suspend
      ALSA: hda: dinput_mux check
      ALSA: hda: fix incorrect mixer index values for 92hd83xx

Matthew Wilcox (3):
      driver core: Rearrange struct device for better packing
      driver core: Remove completion from struct klist_node
      atomic_t: unify all arch definitions

Matthias Fuchs (1):
      powerpc: Add ioctls for RS485 mode control of serial drivers

Matthias Schwarzott (1):
      V4L/DVB (9477): Fix: Commit 9344 breaks tning of cx24123

Matthias Urlichs (5):
      mISDN: Remove the local max-card limit
      mISDN: Added an ioctl to change the device name
      mISDN: Use struct device name field
      mISDN: Create /sys/class/mISDN
      mISDN: Add MODULE_DEVICE_TABLE() to hfcpci

Mauro Carvalho Chehab (95):
      V4L/DVB (9366): Move S921 driver to the proper place and allow it t=
o compile
      V4L/DVB (9367): Move lgdt3304 driver to the proper place and allow =
it to compile
      V4L/DVB (9370): Update README.cx88 with the current status
      V4L/DVB (9498): Simplify video standards enumeration
      V4L/DVB (9532): Properly handle error messages during alsa register=
ing
      V4L/DVB (9572): Whitespace cleanup
      V4L/DVB (9572a): Whitespace cleanup
      V4L/DVB (9578): v4l core: add support for enumerating frame sizes a=
nd intervals
      V4L/DVB (9579): v4l core: a few get ioctls were lacking memory clea=
n
      V4L/DVB (9591): v4l core: fix debug printk for enumberating framera=
tes
      V4L/DVB (9607): em28xx: Properly implement poll support for IR's
      V4L/DVB (9611): em28xx: experimental support for HVR-950 IR
      V4L/DVB (9612): Fix key repetition with HVR-950 IR
      V4L/DVB (9630): Some boards need to specify tuner address
      V4L/DVB (9641): Add chip ID's for em2820 and em2840
      V4L/DVB (9642): Add AC97 registers found on em28xx devices
      V4L/DVB (9643): em28xx: remove the previous register names
      V4L/DVB (9649): em28xx: remove two amux entries used only on one ca=
rd
      V4L/DVB (9650): em28xx: replace magic numbers to something more mea=
ningful
      V4L/DVB (9651): em28xx: Improve audio handling
      V4L/DVB (9652): em28xx: merge AC97 vendor id's into a single var
      V4L/DVB (9653): em28xx: improve AC97 handling
      V4L/DVB (9669): em28xx: Fix a stupid cut-and-paste error
      V4L/DVB (9670): em28xx: allow specifying audio output
      V4L/DVB (9671): em28xx: Add detection of Sigmatel Stac97xx series o=
f AC97 devices
      V4L/DVB (9672): Allow opening more than one output at the same time
      V4L/DVB (9673): em28xx: fix Pixelview PlayTV board entry
      V4L/DVB (9675): em28xx: devices with xc2028/3028 don't have tda9887
      V4L/DVB (9676): em28xx: fix a regression caused by 22c90ec6a5e07173=
ee670dc2ca75e0df0a7772c0
      V4L/DVB (9717): em28xx: improve message probing logs
      V4L/DVB (9747): em28xx: Properly handles XCLK and I2C speed
      V4L/DVB (9751): em28xx: card description cleanups
      V4L/DVB (9752): Remove duplicated fields on em28xx_board and em28xx=
 structs
      V4L/DVB (9753): em28xx: cleanup: saa7115 module auto-detects saa711=
x type
      V4L/DVB (9754): em28xx: improve debug messages
      V4L/DVB (9755): em28xx: cleanup: We need just one tuner callback
      V4L/DVB (9758): em28xx: replace some magic by register descriptions=
 where known
      V4L/DVB (9759): em28xx: move gpio tables to the top of em28xx-cards
      V4L/DVB (9760): em28xx: move gpio lines into board table descriptio=
n
      V4L/DVB (9761): em28xx: replace magic numbers for mux aliases
      V4L/DVB (9762): em28xx: fix tuner absent entries
      V4L/DVB (9763): em28xx: fix gpio settings
      V4L/DVB (9764): em28xx: Add support for suspend the device when not=
 used
      V4L/DVB (9765): em28xx: move tuner gpio's to the cards struct
      V4L/DVB (9766): em28xx: improve probe messages
      V4L/DVB (9767): em28xx: improve board description messages
      V4L/DVB (9756): em28xx: Improve register log format
      V4L/DVB (9769): tuner-xc2028: powers device of when not used
      V4L/DVB (9770): em28xx: turn off tuner when not used
      V4L/DVB (9771): tuner-xc2028: fix a small warning
      V4L/DVB (9772): saa7134: Add support for Kworld Plus TV Analog Lite=
 PCI
      V4L/DVB (9773): tda827x: fix printk message when in FM mode
      V4L/DVB (9774): tda827x: fix returned frequency
      V4L/DVB (9775): tda8290: fix FM radio
      V4L/DVB (9799): em28xx: fix Kworld Hybrid 330 (A316) support
      V4L/DVB (9909): em28xx: move dev->lock from res_free to the caller =
routines
      V4L/DVB (9910): em28xx: move res_get locks to the caller routines
      V4L/DVB (9911): em28xx: vidioc_try_fmt_vid_cap() doesn't need any l=
ock
      V4L/DVB (9912): em28xx: fix/improve em28xx locking schema
      V4L/DVB (9913): tuner-xc2028: allow printing stack trace as debug o=
n sleep code
      V4L/DVB (9925): tuner-core: add debug msg's when asking tuner to sl=
eep
      V4L/DVB (9926): em28xx: Fix a bug that were putting xc2028/3028 tun=
er to sleep
      V4L/DVB (9927): em28xx: use a more standard way to specify video fo=
rmats
      V4L/DVB (9930): em28xx: Fix bad locks on error condition
      V4L/DVB (9931): em28xx: de-obfuscate vidioc_g_ctrl logic
      V4L/DVB (9953): em28xx: Add suport for debugging AC97 anciliary chi=
ps
      V4L/DVB (9969): tvp5150: add support for VIDIOC_G_CHIP_IDENT ioctl
      V4L/DVB (9970): em28xx: Allow get/set registers for debug on i2c sl=
ave chips
      V4L/DVB (9977): Kbuild: fix compilation when dib7000p is not define=
d
      V4L/DVB (9979): em28xx: move usb probe code to a proper place
      V4L/DVB (9980): em28xx: simplify analog logic
      V4L/DVB (10106): gscpa - stv06xx: Fix compilation with kernel tree
      V4L/DVB (10107): More than one driver defines the same var name (du=
mp_bridge). Add
      V4L/DVB (10109): anysee: Fix usage of an unitialized function
      V4L/DVB (10110): v4l2-ioctl: Fix warnings when using .unlocked_ioct=
l =3D __video_ioctl2
      V4L/DVB (10111): quickcam_messenger.c: fix a warning
      V4L/DVB (10111a): usbvideo.h: remove an useless blank line
      V4L/DVB (10116): af9013: Fix gcc false warnings
      V4L/DVB (10118): zoran: fix warning for a variable not used
      V4L/DVB (10154): saa7134: fix a merge conflict on Behold H6 board
      V4L/DVB (10160): em28xx: update chip id for em2710
      V4L/DVB (10162): tuner-simple: Fix tuner type set message
      V4L/DVB (10163): em28xx: allocate adev together with struct em28xx =
dev
      V4L/DVB (10166): dvb frontend: stop using non-C99 compliant comment=
s
      Staging: go7007: Convert driver to use video_ioctl2
      edac: driver for i5400 MCH (Seaburg)
      edac: driver for i5400 MCH (update)
      V4L/DVB (10177): Fix sparse warnings on em28xx
      V4L/DVB (10178): dvb_frontend: Fix some sparse warnings due to stat=
ic symbols
      V4L/DVB (10179): tda8290: Fix two sparse warnings
      V4L/DVB (10180): drivers/media: Fix a number of sparse warnings
      V4L/DVB (10181): v4l2-device: Fix some sparse warnings
      V4L/DVB (10189): dm1105: Fix build with INPUT=3Dm and DVB_DM1105=3D=
y
      V4L/DVB (10190): cx88: Fix some Kbuild troubles
      V4L/DVB (10191a): Update MAINTAINERS entries on media drivers

Mel Gorman (2):
      mm: report the pagesize backing a VMA in /proc/pid/smaps
      mm: report the MMU pagesize in /proc/pid/smaps

Melissa Howland (1):
      [S390] convert monwriter printks to pr_xxx macros.

Miao Xie (1):
      cpusets: set task's cpu_allowed to cpu_possible_map when attaching =
it into top cpuset

Michael Buesch (4):
      b43: Fix some MAC locking
      b43: Suspend MAC while killing the radio
      b43: Add key memory dumping
      parport: ieee1284: use del_timer_sync() in parport_wait_event()

Michael Chan (7):
      bnx2: Add PCI ID for 5716S.
      bnx2: Restrict WoL support.
      bnx2: Set rx buffer water marks based on MTU.
      bnx2: Reorganize timeout constants.
      bnx2: Update version to 1.8.2.
      bnx2: Rename MSI-X vectors.
      bnx2: Update version to 1.9.0.

Michael Ellerman (6):
      of: Add helpers for finding device nodes which have a given propert=
y
      powerpc: Use for_each_node_with_property() in of_irq_map_init()
      powerpc: Use of_find_node_with_property() in cell_iommu_fixed_mappi=
ng_init()
      powerpc/pmac: Use of_find_node_with_property() in pmac_setup_arch()
      IB/ipath: Fix pointer-to-pointer thinko in ipath_fs.c
      powerpc/iseries: Kexec is known not to work on iseries

Michael Ernst (1):
      [S390] convert cio printks to pr_xxx macros.

Michael Halcrow (9):
      eCryptfs: Filename Encryption: Tag 70 packets
      eCryptfs: Filename Encryption: Header updates
      eCryptfs: Filename Encryption: Encoding and encryption functions
      eCryptfs: Filename Encryption: filldir, lookup, and readlink
      eCryptfs: Filename Encryption: mount option
      eCryptfs: Replace %Z with %z
      eCryptfs: Fix data types (int/size_t)
      eCryptfs: kerneldoc for ecryptfs_parse_tag_70_packet()
      eCryptfs: Clean up ecryptfs_decode_from_filename()

Michael Hennerich (20):
      Blackfin arch: BF538/9 Linux kernel Support
      Blackfin arch: lookup channel2irq() only once
      Blackfin arch: Remove useless SSYNCs in DMA code
      Blackfin arch: remove most BUG_ON channel checks
      Blackfin arch: don't assume a specific SPI flash part - take whatev=
er you probe
      Blackfin arch: Enable ISP1760 USB Host Driver in platform device in=
itialization code.
      Blackfin arch: Cleanup and unify Blackfin IRQ and GPIO IRQ handling
      Blackfin arch: Convert Blackfin GPIO driver to use common gpiolib/g=
piochip infrastructure
      Blackfin arch: Fix BUG - Kernel does not link when CONFIG_CPU_FREQ_=
STAT=3Dm
      Blackfin arch: Fix bug - change cpufreq doesn't take effect on bf53=
7 now
      ASoC: Fix Blackfin AC97 DAI probe function return code
      V4L/DVB (9660): uvcvideo: Fix unaligned memory access.
      Blackfin arch: fix bugs and unify BFIN_KERNEL_CLOCK option
      Blackfin arch: gpio.h split into machine subfolders like already do=
ne for BF54x
      Blackfin arch: fix bug - kernel build fails with undefined referenc=
e to pm_overflow_handler
      Blackfin arch: Add BF537-STAMP platform support for ENC28J60 SPI Et=
hernet MAC
      Blackfin arch:  ADP5588 QWERTY I2C Keyboard Input device driver
      Blackfin arch: Make the interrupt edge and polarity type configurab=
le based on IORESOURCE_BITS
      Blackfin arch: Add AD7879 defaults for the Blackfin Landscape LCD E=
Z-Extender
      Blackfin arch: fix bug - kernel crash after config IP for ethernet =
port

Michael Hillmann (1):
      Staging: comedi: add me_daq driver

Michael Holzheu (3):
      [S390] convert hypfs printks to pr_xxx macros.
      [S390] convert s390 debug feature printks to pr_xxx macros.
      [S390] convert zfcp dumper printks to pr_xxx macros.

Michael Kerrisk (1):
      inotify: fix type errors in interfaces

Michael Krufky (11):
      V4L/DVB (9734): sms1xxx: add functions to configure and set gpio
      V4L/DVB (9733): sms1xxx: add autodetection support for Hauppauge Wi=
nTV MiniCard
      V4L/DVB (9735): sms1xxx: turn off LEDs after initialization of Haup=
pauge WinTV MiniStick
      V4L/DVB (9736): sms1xxx: enable power LED on Hauppauge WinTV MiniSt=
ick
      V4L/DVB (9738): sms1xxx: fix invalid unc readings
      V4L/DVB (9739): sms1xxx: enable signal quality indicator LEDs on Ha=
uppauge WinTV MiniStick
      V4L/DVB (9737): sms1xxx: enable LNA control on Hauppauge WinTV Mini=
Card
      V4L/DVB (10167): sms1xxx: add support for inverted gpio
      V4L/DVB (10168): sms1xxx: fix inverted gpio for lna control on tige=
r r2
      V4L/DVB (10170): tuner-simple: prevent possible OOPS caused by divi=
de by zero error
      V4L/DVB (10182): tda8290: fix TDA8290 + TDA18271 initialization

Michael Marineau (1):
      net: Fix for initial link state in 2.6.28

Michael McTernan (1):
      Blackfin arch: add const to some function prototype and struct dma_=
channel

Michael Tokarev (2):
      x86: fix missing space in printk
      x86: fix missing space in printk, #2

Michael Trimarchi (2):
      serial: sh-sci: Codestyle cleanup patch.
      sh: Add SH-4A optimized fastpath mutex implementation.

Michal Schmidt (1):
      selinux: recognize netlink messages for 'ip addrlabel'

Miguel (3):
      Btrfs: Endianess bug fix for v0.13 with kernels
      Btrfs: define write_cache_pages for linux kernel <=3D 2.6.20 instea=
d
      Btrfs: bio_endio support for linux 2.6.23 and older.

Mikael Pettersson (1):
      x86, signals: remove duplicated register setup code in ia32 signal =
delivery

Mike Chan (1):
      [CPUFREQ] Fix on resume, now preserves user policy min/max.

Mike Christie (13):
      [SCSI] iscsi_tcp: prepare helpers for LLDs that can offload some op=
erations
      [SCSI] libiscsi: prepare libiscsi for new offload engines by modify=
ing unsol data code
      [SCSI] iser: convert iser to new alloc_pdu api
      [SCSI] iscsi_tcp: convert to new alloc_hdr api
      [SCSI] iscsi_tcp: remove unused r2t handling
      [SCSI] libiscsi: change login data buffer allocation
      [SCSI] iscsi_tcp: add iscsi_tcp prefix to iscsi_tcp functions
      [SCSI] iscsi_tcp: split module into lib and lld
      [SCSI] iscsi_tcp: hook iscsi_tcp into new libiscsi_tcp module
      [SCSI] libiscsi: allow drivers to modify the itt sent to the target
      [SCSI] libiscsi: pass opcode into alloc_pdu callout
      [SCSI] libiscsi: handle init task failures.
      [SCSI] libiscsi_tcp: support padding offload

Mike Day (1):
      intel-iommu: fix bit shift at DOMAIN_FLAG_P2P_MULTIPLE_DEVICES

Mike Frysinger (121):
      Blackfin arch: unify duplicated bss init code
      Blackfin arch: move EXPORT_SYMBOL to the place where it is actually=
 defined
      Blackfin arch: add an option to allow people to stick exception sta=
ck into L1 scratch
      Blackfin arch: drop unused exports and comment remaining exports
      Blackfin arch: drop redundant BFIN_DMA_5XX depends
      Blackfin arch: put quotes around error to silence a ton of warnings=
 from gcc-4.3
      Blackfin arch: remove unused local define
      Blackfin arch: unify check_gpio() to reduce arch differences
      Blackfin arch: fix cmp_label() so it doesnt incorrectly accept part=
ial leading matches
      Blackfin arch: unify peripheral_request() to reduce arch difference=
s
      Blackfin arch: unify port_setup() to reduce arch differences
      Blackfin arch: refine the gpio check
      Blackfin arch: update anomaly lists to match latest sheets
      Blackfin arch: only add IFLUSH nop padding when anomaly 443 is enab=
led
      smc91x: add __init markings to smc_drv_probe()
      Blackfin arch: update defconfig file for all boards
      Blackfin arch: use sti to set the mask rather than banging on imask
      Blackfin arch: do not bother initializing the first 4k
      Blackfin arch: fixup get_user() macros
      Blackfin arch: enable i2c_bfin_twi0_device in cm_bf548 board
      Blackfin arch: remove useless SSYNC() in irq priority code
      Blackfin arch: use physmap in board resources rather than legacy co=
nfig method
      Blackfin arch: fix unused warning for some blackfin derivatives
      Blackfin arch: make ADI board names consistent
      Blackfin arch: rewrite blackfin_invalidate_entire_dcache function
      Blackfin arch: overlay thread.usp over PT_USP
      Blackfin arch: delete old comments and NO_IRQ define
      Blackfin arch: move ack_bad_irq() prototype to hardirq.h to match o=
ther arches
      Blackfin arch: move SIC_SYSIRQ() to the one file that actually uses=
 it
      Blackfin arch: dont export ack_bad_irq as no one else does
      Blackfin arch: delay PLL_CTL/VR_CTL wrappers
      Blackfin arch: set PM_WAKEUP_GPIO_NUMBER default to 2 for everyone
      Blackfin arch: remove superficial check on blackfin watchdog
      Blackfin arch: move fixed code into init section
      Blackfin arch: delete unused vars and add parenthesis to fixup warn=
ings
      Blackfin arch: fix off-by-one errors on end of memory range
      Blackfin arch: introduce an IM_MEM macro to kgdb
      Blackfin arch: move the PORT registers down
      Blackfin arch: move out irq related functions
      Blackfin arch: rename irq_flags to bfin_irq_flags
      Blackfin arch: do not define decode_instruction if hwtrace is turne=
d off
      Blackfin arch: fix building with CONFIG_DEBUG_DOUBLEFAULT
      Blackfin arch: cleanup the time.c code
      Blackfin arch: use generic xor.h
      Blackfin arch: rename cache_lock() to bfin_cache_lock()
      Blackfin arch: add mmiowb() as some drivers expect
      Blackfin arch: remove BFIN_DMA_5XX option
      Blackfin arch: define BASE_BAUD like everyone else
      Blackfin arch: unify cplbinfo files
      Blackfin arch: remove pointless define IN_KERNEL
      Blackfin arch: change return value
      Blackfin arch: do not include init sections in the kernel lock down=
 as it gets released afterwards
      Blackfin arch: noMMU CPLB lookup tables can be in L1 SRAM
      Blackfin arch: make ROM_BASE depend on ROMKERNEL
      Blackfin arch: add BUG_ON() checks to make sure we dont overflow th=
e cplb tables
      Blackfin arch: only define HI/LO macros for assembly files
      Blackfin arch: add ANOMALY_05000435 to our headers
      Blackfin arch: fix bug - reboot fails on BF527
      ASoC: Blackfin: updates Kconfig for SPORT
      ASoC: Blackfin: do not force TWI bus for ssm2602 codec
      ASoC: Blackfin: always set a default value for that GPIO range
      netdev/smc91x: unify Blackfin code a bit and use proper read/write =
functions
      kbuild: kill output in silent mode of mkcompile_h
      kbuild: introduce $(kecho) convenience echo
      kbuild: use KECHO convenience echo
      [MTD] physmap: make physmap compat explicit
      linux/timex.h: cleanup for userspace
      Input: map_to_7segment.h - convert to __inline__ for userspace
      V4L/DVB (10149): ttusb-budget: make it depend on PCI
      V4L/DVB (10150): ttusb-dec: make it depend on PCI
      headers_check.pl: disallow extern's
      kbuild: in headers_install autoconvert asm/inline/volatile to __xxx=
__
      UIO: uio_pdrv_genirq: allow custom irq_flags
      autodetect_raid: add missing __init marking
      checkpatch: try to catch missing VMLINUX_SYMBOL() in vmlinux.lds.h
      genrtc: disable genrtc on Blackfin systems
      Blackfin arch: delete now unused "cclk" member of blackfin_cpudata
      Blackfin arch: do not allow L2 to be cached on BF561 SMP
      Blackfin arch: add simple-gpio resources to all adi/tinyboards
      Blackfin arch: rewrite cplbinfo to use seq files
      Blackfin arch: cleanup the header file comments
      Blackfin arch: tweak the BUG_ON() check to allow for equal values
      Blackfin arch: rename MAX_BLACKFIN_DMA_CHANNEL to MAX_DMA_CHANNELS =
to match everyone else
      Blackfin arch: remove #if check on L2_LENGTH
      Blackfin arch: dma_memcpy() - do not return NULL when transferring =
a multiple of 65k
      Blackfin arch: Set TWI/I2C Clock to 100kHz
      Blackfin arch: cleanup - use scm for changelog, not file headers
      Blackfin arch: push bf561 PERIPHERAL_MAP oddity into bf561-specific=
 code
      Blackfin arch: check pointers in safe_dma_memcpy
      Blackfin arch: rewrite dma_memcpy() and dma in/out functions
      Blackfin arch: enable DEBUG_KERNEL for ADI boards
      Blackfin arch: include linux/mm.h since we use PAGE_ALIGN and such
      Blackfin arch: drop custom dma_interrupt_t and just use irq_handler=
_t
      Blackfin arch: drop irq_callback from struct dma_channel
      Blackfin arch: set_dma_callback: do not store .irq
      Blackfin arch: dma header file: strip down includes to only necessa=
ry ones
      Blackfin arch: move most dma functions into static inlines
      Blackfin arch: desc_ptr is a pointer, so declare it as such
      Blackfin arch: request_dma() returns 0 on success, not channel
      Blackfin arch: push cache flushing up to dma_memcpy
      Blackfin arch: add bfin_read_MDMA_S0_CONFIG compat for dma_memcpy
      Blackfin arch: dma code: cannot simply OR the ndsize
      Blackfin arch: add __must_check markings to our user functions like=
 other arches
      Blackfin arch: stub out pgprot_noncached() like other people seem t=
o do on nommu
      Blackfin arch: remove unused members of dma_channel struct
      Blackfin arch: add volatile markings to DMA MMRs
      Blackfin arch: add get_dma_config() func to match set_dma_config()
      Blackfin arch: add __init markings to Blackfin timer init functions
      Blackfin arch: show_cpuinfo - consolidate ugly casts
      Blackfin arch: allow clkin_hz to be specified on the command line
      Blackfin arch: do not allow people to pass in a diff clkin_hz value
      Blackfin arch: update anomaly headers to match latest sheets
      Blackfin arch: merge kgdb test code using common CONFIG_KGDB_TESTS
      Blackfin arch: cleanup and unify the ins functions
      Blackfin arch: rewrite get_sclk()/get_vco()
      Blackfin arch: change HWTRACE Kconfig and set it on default
      Blackfin arch: add () to avoid warnings from gcc
      Blackfin arch: fix typo in early printk bit size processing
      Blackfin arch: drop ad73311 test code
      Blackfin arch: fix bug: kernel crash when enable SDIO host driver
      [S390] asm-s390/posix_types.h: drop __USE_ALL usage

Mike Galbraith (2):
      sched: fix wakeup preemption clock
      sched: fix sched_slice()

Mike Lockwood (2):
      Staging: android: add timed_gpio driver
      Staging: android: timed_gpio: Rename android_timed_gpio to timed_gp=
io

Mike Rapoport (8):
      V4L/DVB (10076): v4l: add chip ID for MT9M112 camera sensor from Mi=
cron
      V4L/DVB (10077): mt9m111: add support for mt9m112 since sensors see=
m identical
      mfd: Dialog DA9030 battery charger MFD driver
      power_supply: Add Dialog DA9030 battery charger driver
      regulator: da903x: add '\n' to error messages
      regulator: da903x: make da903x_is_enabled return 0 or 1
      regulator: move set_machine_constraints after regulator device init=
ialization
      backlight: add support for Toppoly TDO35S series to tdo24m lcd driv=
er

Mike Travis (41):
      x86/uv: provide a System Activity Indicator driver
      x86/uv: update SCIR driver to use the idle_cpu() function
      sched: reduce stack size requirements in kernel/sched.c
      x86: fix build error with post-merge of tip/cpus4096 and rr-for-ing=
o/master.
      x86: enable MAXSMP
      x86 smp: modify send_IPI_mask interface to accept cpumask_t pointer=
s
      x86: move and enhance debug printk for nr_cpu_ids etc.
      x86: Add cpu_mask_to_apicid_and
      x86: update add-cpu_mask_to_apicid_and to use struct cpumask*
      x86: Update io_apic.c to use new cpumask API
      xen: convert to cpumask_var_t and new cpumask primitives.
      x86: fixup_irqs() doesnt need an argument.
      x86: cosmetic changes apic-related files.
      x86: Set CONFIG_NR_CPUS even on UP
      x86: prepare for cpumask iterators to only go to nr_cpu_ids
      x86: Use cpumask accessors code for possible/present maps.
      x86: Remove cpumask games in x86/kernel/cpu/intel_cacheinfo.c
      x86: use work_on_cpu in x86/kernel/cpu/mcheck/mce_amd_64.c
      x86: xen: use smp_call_function_many()
      x86: Introduce topology_core_cpumask()/topology_thread_cpumask()
      x86: fix cpu_mask_to_apicid_and to include cpu_online_mask
      x86: use possible_cpus=3DNUM to extend the possible cpus allowed
      cpumask: Add alloc_cpumask_var_node()
      cpumask: documentation for cpumask_var_t
      cpumask: add sysfs displays for configured and disabled cpu maps
      sysfs: add documentation to cputopology.txt for system cpumasks
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/rusty/linux-2.6-cpumask into merge-rr-cpumask
      x86: enable cpus display of kernel_max and offlined cpus
      sched: put back some stack hog changes that were undone in kernel/s=
ched.c
      x86: cleanup some remaining usages of NR_CPUS where s/b nr_cpu_ids
      cpumask: use alloc_cpumask_var_node where appropriate
      cpumask: fix compile error when CONFIG_NR_CPUS is not defined
      ia64: cpumask fix for is_affinity_mask_valid()
      cpumask: update local_cpus_show to use new cpumask API
      cpumask: update pci_bus_show_cpuaffinity to use new cpumask API
      x86: cleanup remaining cpumask_t ops in smpboot code
      cpumask: use work_on_cpu in acpi/cstate.c
      cpumask: use cpumask_var_t in acpi-cpufreq.c
      cpumask: use work_on_cpu in acpi-cpufreq.c for drv_read and drv_wri=
te
      cpumask: use work_on_cpu in acpi-cpufreq.c for read_measured_perf_c=
trs
      x86: fix x86_32 builds for summit and es7000 arch's

Miklos Szeredi (3):
      fuse: style fixes
      fuse: update interface version
      fuse: fix sparse warning in ioctl

Mikulas Patocka (4):
      dm table: drop reference at unbind
      dm snapshot: change yield to msleep
      dm: consolidate target deregistration error handling
      dm table: rework reference counting

Milan Broz (6):
      loop: Flush possible running bios when loop device is released.
      loop: Do not call loop_unplug for not configured loop device.
      dm log: move region_size validation
      dm log: ensure log bitmap fits on log device
      dm ioctl: allow dm_copy_name_and_uuid to return only one field
      dm: add name and uuid to sysfs

Milton Miller (3):
      powerpc: Provide a separate handler for each IPI action
      powerpc/mpic: Use new smp_request_message_ipi
      scsi-ioctl: use clock_t <> jiffies

Ming Lei (4):
      kobject: return the result of uevent sending by netlink
      kernel/ksysfs.c:fix dependence on CONFIG_NET
      driver core:fix duplicate removing driver link in __device_release_=
driver
      USB: mark "reject" field of struct urb as atomic_t

Mingming (1):
      btrfs delete ordered inode handling fix

Miquel van Smoorenburg (1):
      do_mpage_readpage(): don't submit lots of small bios on boundary

Misael Lopez Cruz (1):
      ASoC: Add support for TI SDP3430

Mohamed Abbas (6):
      iwlwifi: clear scanning bits upon failure
      iwlwifi: do not call statistics from rfkill
      iwlagn: fix resume for ADHOC network
      iwl3945: fix resume for ADHOC network
      iwlwifi: fix resume while txpower off
      iwlagn: fix agn rate scaling

Mohan Kumar M (1):
      powerpc: Enable RELOCATABLE option for CRASH_DUMP

Naresh Medisetty (2):
      ASoC: DaVinci: Audio: Fix swapping of channels at start of stereo p=
layback
      ASoC: DaVinci: Fix audio stall when doing full duplex

Nathan Lynch (8):
      powerpc: Move smp_hw_index to 32-bit code
      powerpc/powermac: Use set_hard_smp_processor_id() instead of smp_hw=
_index
      powerpc/pseries: Check for GIQ indicator before calling set-indicat=
or
      powerpc: Add of_find_next_cache_node()
      powerpc: Convert cpu_to_l2cache() to of_find_next_cache_node()
      powerpc: Convert sysfs cache code to of_find_next_cache_node()
      ehea: use get_zeroed_page for alignment-sensitive allocation
      powerpc: Rewrite sysfs processor cache info code

Neil Brown (1):
      block: fix bug in ptbl lookup cache

Neil Horman (5):
      x86: unify appropriate bits from dumpstack_32 and dumpstack_64
      net: implement emergency route cache rebulds when gc_elasticity is =
exceeded
      net: Remove unused netdev arg from some NAPI interfaces.
      crypto: testmgr - Trigger a panic when self test fails in FIPS mode
      crypto: ansi_cprng - Allow resetting of DT value

Neil Turton (1):
      sfc: Add option to use a separate channel for TX completions

NeilBrown (7):
      md: fix bitmap-on-external-file bug.
      md: use sysfs_notify_dirent to notify changes to md/sync_action.
      md: move allocation of ->queue from mddev_find to md_probe
      md: centralise all freeing of an 'mddev' in 'md_free'
      md: make devices disappear when they are no longer needed.
      md: Allow md devices to be created by name.
      md: don't retry recovery of raid1 that fails due to error on source=
 drive.

Nguyen Anh Quynh (1):
      USB: another unusual_devs entry for another bad Argosy storage devi=
ce

Nick Andrew (17):
      wireless: Fix incorrect use of loose in wext.c
      net: Fix incorrect use of loose in spider_net.c
      slub: Fix incorrect use of loose
      Fix incorrect use of loose in c-checksum.c
      trivial: Fix incorrect use of "loose" in event.c
      trivial: Fix misspelled firmware in Kconfig
      trivial: Fix misspelling of "firmware" in atmel.c
      trivial: Fix misspelling of "firmware" in ipw2100.c
      trivial: Fix misspelling of "firmware" in acpi_memhotplug.c
      trivial: Fix misspelling of "firmware" in ql4_mbx.c
      trivial: Fix misspelling of "firmware" in megaraid.c
      trivial: Fix misspelling of "firmware" in a100u2w.c
      trivial: Fix misspelling of "firmware" in qla1280.c
      trivial: Fix misspelling of "firmware" in usb.c
      trivial: Fix misspelling of "firmware" in powerpc Makefile
      trivial: Fix misspelling of "firmware" in docs for ncr53c8xx/sym53c=
8xx
      Blackfin arch: Fix incorrect use of loose in cpufreq.c

Nick Kossifidis (3):
      ath5k: Update interrupt masking code
      ath5k: Update PCU code
      ath5k: Fix IMR init

Nick Pelly (1):
      Bluetooth: Respect HCI_UART_DEBUG config in hci_ll.c

Nick Piggin (27):
      x86: some lock annotations for user copy paths
      x86: some lock annotations for user copy paths, v2
      sched: improve preempt debugging
      x86, mm: enable GBPAGES option by default
      powerpc: Optimise smp_wmb
      powerpc: Optimise smp_rmb
      powerpc: Optimise mutex
      shrink struct dentry
      fs: symlink write_begin allocation context fix
      mm lockless pagecache barrier fix
      mm: don't mark_page_accessed in fault path
      mm: invoke oom-killer from page fault
      mm: write_cache_pages cyclic fix
      mm: write_cache_pages early loop termination
      mm: write_cache_pages writepage error fix
      mm: write_cache_pages integrity fix
      mm: write_cache_pages cleanups
      mm: write_cache_pages optimise page cleaning
      mm: write_cache_pages terminate quickly
      mm: do_sync_mapping_range integrity fix
      mm: vmalloc use mutex for purge
      mm: vmalloc make lazy unmapping configurable
      mm: direct IO starvation improvement
      fs: remove WB_SYNC_HOLD
      fs: sync_sb_inodes fix
      fs: sys_sync fix
      mm: pagecache gfp flags fix

Nicolas Dichtel (1):
      xfrm6: handling fragment

Nicolas Ferre (2):
      mmc: at91_mci: reorder timer setup and mmc_add_host() call
      atmel-mci: move atmel-mci.h file to include/linux

Nicolas Palix (5):
      drivers/hvc: Add missing of_node_put
      sparc: Add missing of_node_put
      powerpc/chrp: Add missing of_node_put in pci.c
      drivers/macintosh: Add missing of_node_put in therm_adt746x.c
      powerpc/powermac: Add missing of_node_put

Nicolas Pitre (14):
      [ARM] fix a couple clear_user_highpage assembly constraints
      [ARM] rationalize memory configuration code some more
      [ARM] split highmem into its own memory bank
      [ARM] mem_init() cleanups
      [ARM] prevent the vmalloc cmdline argument from eating all memory
      [ARM] remove bogus #ifdef CONFIG_HIGHMEM in show_pte()
      [ARM] unconditionally define __virt_to_phys and __phys_to_virt
      [ARM] remove a common set of __virt_to_bus definitions
      [ARM] Feroceon: pass proper -mtune argument to gcc
      [ARM] Kirkwood: update defconfig
      [ARM] 5359/1: Kirkwood: fix compilation error
      [ARM] 5360/1: Orion: fix compilation error
      [ARM] 5361/1: mv78xx0: fix compilation error
      [ARM] 5357/1: Kirkwood: add missing ge01 tclk initialization

Niels de Vos (2):
      x86, apm: remove CONFIG_APM_REAL_MODE_POWER_OFF in favor of a kerne=
l parameter
      serial: set correct baud_base for Oxford Semiconductor Ltd EXSYS EX=
-41092 Dual 16950 Serial adapter

Nikanth Karthikesan (4):
      tracepoints: Documentation TPPROTO misspelt in Documentation/tracep=
oints.txt
      Do not free io context when taking recursive faults in do_exit
      Documentation: remove reference to ll_rw_blk.c and moved drivers/bl=
ock/elevator.c
      memcg: check group leader fix

Nishanth Menon (1):
      i2c-omap: FIFO handling support and broken hw workaround for i2c-om=
ap

Nitin A Kamble (2):
      KVM: Fix cpuid leaf 0xb loop termination
      KVM: Fix cpuid iteration on multiple leaves per eac

Niv Sardi (1):
      Merge branch 'master' of git://oss.sgi.com:8090/xfs/linux-2.6

Nobuhiro Iwamatsu (2):
      sh: sh7760fb: Fix color pallette setting
      sh: sh7760fb: Add support SH7720/SH7721 of Renesas

Nuno Lucas (1):
      Input: usbtouchscreen - fix TSC-10 DM USB controllers without EEPRO=
M

N=C3=A9meth M=C3=A1rton (1):
      V4L/DVB (10128): modify V4L documentation to be a valid XHTML

OGAWA Hirofumi (3):
      fat: drop negative dentry on rename() path
      fat: fix duplicate addition of ->llseek handler
      slub: Add might_sleep_if() to slab_alloc()

Olaf Dabrunz (4):
      pci: add PCI IDs for devices that need boot irq quirks
      PCI quirks: add quirk to disable boot interrupt generation on broad=
com HT1000
      PCI quirks: disable AMD/ATI legacy boot interrupt generation
      PCI quirks: call boot IRQ quirks at end of device init and during r=
esume

Oldrich Jedlicka (1):
      V4L/DVB (9667): Fixed typo in sizeof() causing NULL pointer OOPS

Oleg Nesterov (7):
      account_steal_time: kill the unneeded account_group_system_time()
      thread_group_cputime: kill the bogus ->signal !=3D NULL check
      thread_group_cputime: move a couple of callsites outside of ->siglo=
ck
      posix-timers: use "struct pid*" instead of "struct task_struct*"
      posix-timers: check ->it_signal instead of ->it_pid to validate the=
 timer
      posix-timers: simplify de_thread()->exit_itimers() path
      mm: introduce get_mm_hiwater_xxx(), fix taskstats->hiwater_xxx acco=
unting

Olga Kornievskaia (6):
      nfsd: pass client principal name in rsc downcall
      rpc: pass target name down to rpc level on callbacks
      rpc: allow gss callbacks to client
      nfsd: support callbacks with gss flavors
      rpc: add target field to new upcall
      rpc: add service field to new upcall

Oliver Hartkopp (4):
      vcan: convert to net_device_ops
      vcan: whitespace fixes
      can: update can-bcm for hrtimer hardirq callbacks
      can: omit unneeded skb_clone() calls

Oliver Neukum (11):
      net: prepare usb net drivers for addition of status as a parameter
      net: startup race in hso driver
      HID: hiddev cleanup -- handle all error conditions properly
      HID: fix reference count leak hidraw
      Staging: at76_usb: cleanup dma on stack issues
      Staging: go7007: small cleanup
      USB: storage: extend unusual range for 067b:3507
      USB: power availability check for berry_charge
      USB: extension of anchor API to unpoison an anchor
      net: switch kaweth driver to netdevops
      net: convert pegasus driver to net_device_ops

Ozan =C3=87a=C4=9Flayan (1):
      Input: i8042 - add Gigabyte M912 netbook to noloop exception table

PJ Waskiewicz (1):
      ixgbe: Fix usage of netif_*_all_queues() with netif_carrier_{off|on=
}()

Pablo Neira Ayuso (7):
      netfilter: ctnetlink: use nf_conntrack_get instead of atomic_inc
      netfilter: ctnetlink: use EOPNOTSUPP instead of EINVAL if the connt=
rack	has no helper
      netfilter: ctnetlink: get rid of module refcounting in ctnetlink
      netfilter: nf_conntrack: connection tracking helper name persistent=
 aliases
      netfilter: ctnetlink: helper modules load-on-demand support
      netfilter: ctnetlink: deliver events for conntracks changed from us=
erspace
      filter: add SKF_AD_NLATTR_NEST to look for nested attributes

Pallipadi, Venkatesh (1):
      cpuidle: Add decaying history logic to menu idle predictor

Parag Warudkar (1):
      HID: make boot protocol drivers depend on EMBEDDED

Pascal Terjan (1):
      slab: Fix comment on #endif

Patrice Levesque (1):
      V4L/DVB (9529): cx88: add a second PCI ID for ATI TV Wonder Pro

Patrick Boettcher (4):
      V4L/DVB (9811): Add support for the CX24113 DVB-S tuner driver
      V4L/DVB (9812): [PATCH] short help for Technisat cards to select th=
e right configuration
      V4L/DVB (9887): Minor fixes for cx24113-driver (codingstyle)
      V4L/DVB (9889): CX24113: Fixed more typos

Patrick McHardy (17):
      netlink: constify struct nlattr * arg to parsing functions
      pkt_sched: Add ->peek() methods for fifo, prio and SFQ qdiscs.
      netfilter: nfnetlink_log: fix warning and prototype mismatch
      netfilter: nf_conntrack: fix warning and prototype mismatch
      netlink: avoid memset of 0 bytes sparse warning
      pkt_sched: add DRR scheduler
      pkt_sched: remove unnecessary xchg() in packet schedulers
      pkt_sched: remove unnecessary xchg() in packet classifiers
      netfilter: nf_conntrack_proto_sctp: avoid bogus warning
      netfilter: nf_conntrack_ftp: change "partial ..." message to pr_deb=
ug()
      pkt_sched: sch_drr: fix drr_dequeue loop()
      netlink: allow empty nested attributes
      crypto: hifn_795x - Fix DMA setup
      crypto: hifn_795x - Don't copy src sg list
      crypto: hifn_795x - Fix request context corruption
      crypto: hifn_795x - Fix queue processing
      crypto: hifn_795x - Remove some unused cruft

Paul Bolle (1):
      trivial: Add a space (and a comma) to a printk in 8250 driver

Paul E. McKenney (8):
      rcu: increase RCU stall-check timeouts
      Document RCU and unloadable modules
      rcu: fix rcutorture behavior during reboot
      "Tree RCU": scalable classic RCU implementation
      rcu: fix rcutree grace-period-latency bug on small systems
      rcu: make treercu safe for suspend and resume
      rcu: eliminate synchronize_rcu_xxx macro
      rcu: fix rcutorture bug

Paul Fox (1):
      Input: psmouse - add module parameters to control OLPC touchpad del=
ays

Paul Mackerras (13):
      powerpc: Improve resolution of VDSO clock_gettime
      powerpc: Eliminate unused do_gtod variable
      Merge branch 'linux-2.6' into next
      powerpc: Tell gcc when we clobber the carry in inline asm
      Merge branch 'linux-2.6' into next
      Merge branch 'merge'
      Merge branch 'merge' into next
      Merge branch 'next' of master.kernel.org:/pub/scm/linux/kernel/git/=
jwboyer/powerpc-4xx into next
      Merge branch 'linux-2.6' into next
      powerpc: Fix KVM build on ppc440
      Update powerpc maintainers
      Allow times and time system calls to return small negative values
      powerpc: Fix pciconfig_iobase system call on PCI-Express powermac

Paul Menage (4):
      cgroups: make cgroup_path() RCU-safe
      cgroups: add a per-subsystem hierarchy_mutex
      cgroups: use hierarchy_mutex in memory controller
      cgroups: add css_tryget()

Paul Moore (2):
      netlabel: Update kernel configuration API
      selinux: Deprecate and schedule the removal of the the compat_net f=
unctionality

Paul Mundt (77):
      sh: Move arch_get_unmapped_area() in to arch/sh/mm/mmap.c.
      media: sh_mobile_ceu_camera: Add HAVE_CLK dependency.
      usb: Fix up sh_mobile usbf clock framework warnings.
      sh: Fix clock framework compiler warnings.
      sh: __udivdi3 -> do_div() in softfloat lib.
      sh: Migrate necessary libgcc bits in to arch/sh/lib for SUPERH32.
      sh: Specify sane default image targets for the SH-2 platforms.
      sh: Convert to generic bitops for IRQ-toggling implementation.
      sh: Add exports for __udivsi3/__sdivsi3 and the _i4 versions.
      sh: Add -m4al tuning for SH4AL-DSP.
      sh: Provide optimized non-atomic bitops for SH-2A.
      sh: Provide optimized unaligned loads on SH-4A.
      sh: More movmem alias symbol exports for older compilers.
      sh: Re-add support for best fit ISA tuning if none is available.
      sh: Add a few more branch types to the branch emulator.
      sh: Add a simple code dumper for SUPERH32 show_regs().
      sh: Tidy up backtrace formatting with kallsyms disabled.
      sh: do not latency trace idle.
      sh: Consolidate cpu_relax()/cpu_sleep() definitions across _32/_64.
      sh: Split out the idle loop for reuse between _32/_64 variants.
      sh: Provide a dyn_arch_ftrace struct definition.
      sh: Fix up the SH-4A mutex fastpath semantics.
      sh: Disable -Werror for arch/sh/oprofile/.
      sh: Provide ftrace_make_call()/ftrace_make_nop().
      sh: Consolidate rsk7203/7201 in to a new mach-rsk.
      sh: Enable leds-gpio in rsk7203 defconfig.
      sh: Update rsk701_defconfig to reflect mach-rsk changes.
      sh: Fix an off-by-1 check in __mutex_fastpath_unlock().
      sh: Drop the special qemu defconfig.
      sh: mach-migor: Kill off unused Migo-R machvec.
      sh: Kill off sh64's unused alloc/free_task_struct() definitions.
      sh: Convert sh64 /proc/asids to debugfs and generic sh.
      sh: Fix up the cpu_asid() return value on nommu.
      sh: Fix up syscall_get_nr() comment in syscall_32.h.
      sh: Handle cases where setup{_rt,}_frame() fail on SH-5 signal deli=
very.
      sh: Provide asm/syscall.h for SH-5.
      sh: Provide linux/regset.h interface for SH-5.
      sh: Enable HAVE_ARCH_TRACEHOOK for all SH, now that SH-5 supports i=
t too.
      sh: Generic kgdb stub support.
      serial: sh-sci: Implement CONSOLE_POLL support and kill off old kgd=
b console.
      sh: Kill off remaining CONFIG_SH_KGDB bits.
      sh: Add SH-5 optimized memcpy()/memset()/strcpy()/strlen().
      fb: SH-5 uses __raw I/O accessors now also, drop the special casing.
      sh: Provide sdivsi3/udivsi3/udivdi3 for sh64, kill off libgcc linki=
ng.
      sh: oprofile: Refactor common setup code for multiple driver suppor=
t.
      sh: oprofile: Convert op_model_sh7750 to new common interface.
      serial: sh-sci: Fix up the cpufreq notifier to use the proper port =
clock.
      serial: sh-sci: pr_debug() -> dev_dbg() conversion.
      serial: sh-sci: Tidy up fifo overrun error handling.
      serial: sh-sci: Generalize port pin initialization.
      sh: Run sh_bios through a long overdue Lindent.
      sh: export sh_bios_get_node_addr() symbol for stnic module.
      sh: Kill off sh_bios_in_gdb_mode().
      sh: Kill off the cayman and microdev special heartbeat code.
      sh: Kill off mv_heartbeat() from the machvec.
      sh: Simplify kernel_thread_helper() for sh32.
      sh: Kill off dead mv_init_pci() from machvec.
      sh: board-shmin: Convert shmin to use __set_io_port_base().
      sh: mach-sh03: Move off of cf_enabler to pata_platform, as per land=
isk.
      sh: mach-sh03: Use __set_io_port_base(), kill off special ioport_ma=
p().
      sh: mach-microdev: Split out the fdc37c93xapm initialization code.
      sh: mach-edosk7705: Fix up edosk7705 so it all builds again.
      sh: Add a simple edosk7705_defconfig for build testing.
      sh: Kill off cf-enabler with extreme prejudice.
      serial: sh-sci: sci_poll_get_char() is only used by CONFIG_CONSOLE_=
POLL.
      sh: mrshpc_setup_windows() needs to be inline.
      doc: Update sh cpufreq documentation.
      sh: Enable skipping of bss on debug platforms for sh32 also.
      sh: Kill off the unused SH_ALPHANUMERIC debug option.
      sh: Conditionalize the code dumper on CONFIG_DUMP_CODE.
      sh: dma: Kill off ISA DMA wrapper.
      sh: mach-sh03: Fix up pata_platform build breakage.
      sh: mach-rsk: Use uImage generation by default for rsk7201/7203.
      serial: sh-sci: Fix up port pinmux for SH7366.
      sh: oprofile: Fix up the module build.
      NOMMU: Make mmap allocation page trimming behaviour configurable.
      NOMMU: Teach kobjsize() about VMA regions.

Paul Walmsley (8):
      i2c-omap: Close suspected race between omap_i2c_idle() and omap_i2c=
_isr()
      i2c-omap: Mark init-only functions as __init
      i2c-omap: Don't compile in OMAP15xx I2C ISR for non-OMAP15xx builds
      i2c-omap: fix I2C timeouts due to recursive omap_i2c_{un,}idle()
      i2c-omap: convert 'rev1' flag to generic 'rev' u8
      i2c-omap: reprogram OCP_SYSCONFIG register after reset
      ARM: OMAP2: drop redundant pending write check for gptimer
      ARM: OMAP2: skip unnecessary TLDR write during non-autoreload for g=
ptimer

Paulius Zaleckas (5):
      phylib: rename mdio-ofgpio to mdio-gpio
      phylib: make mdio-gpio work without OF (v4)
      patch-mxc-add-ARCH_MX1
      patch-mx1-UART-support
      patch-mxc-fiq

Paulo Afonso Graner Fessel (1):
      USB: storage: recognizing and enabling Nokia 5200 cell phoes

Pavel Machek (5):
      aperture_64.c: clarify that too small aperture is valid reason for =
this code
      Document handling of bad memory
      Staging: w35und: fix Kconfig
      strict_strto* is not strict enough
      backlight: Catch invalid input in sysfs attributes

Pavel Roskin (3):
      p54: don't report known but unhandled EEPROM codes as unknown
      orinoco: fix last beacon reporting on 64-bit systems
      airport: remove useless return in a function returning void

Pekka Enberg (50):
      slab: remove GFP_THISNODE clearing from alloc_slabmgmt()
      Merge branches 'topic/fixes', 'topic/cleanups' and 'topic/documenta=
tion' into for-linus
      Merge branch 'topic/failslab' into for-linus
      fs: introduce bgl_lock_ptr()
      Staging: w35und: make wb35_probe() and wb35_disconnect() funtions s=
tatic
      Staging: w35und: remove unused wb35_open() and wb35_close() functio=
ns
      Staging: w35und: use msleep() and udelay()
      Staging: w35und: remove the no-op pa_stall_execution macro
      Staging: w35und: purb typedef removal
      Staging: w35und: reg queue struct typedef removal
      Staging: w35und: wb35reg struct typedef removal
      Staging: w35und: padapter struct typedef removal
      Staging: w35und: merge wblinux struct to adapter
      Staging: w35und: wb35_probe() cleanup
      w35und: remove dead code from wbusb_f.h
      Staging: w35und: remove true/false boolean macros
      Staging: w35und: OS_MEMORY_ALLOC wrapper removal
      Staging: w35und: usb_put_dev() is missing from wb35_disconnect()
      Staging: w35und: remove macro magic from MLME_GetNextPacket()
      Staging: w35und: plug memory leak in wbsoft_tx()
      Staging: w35und: move supported band initialization out of wb35_pro=
be()
      Staging: w35und: remove timer wrappers
      Staging: w35und: remove atomic op wrappers
      Staging: w35und: remove memcpy/memcmp wrappers
      Staging: w35und: remove abs() and BIT() macros
      Staging: w35und: remove unused macros from common.h
      Staging: w35und: remove unused link status code
      Staging: w35und: #include cleanup
      Staging: w35und: remove some dead code
      Staging: w35und: move source files to one directory
      Staging: w35und: move struct wbsoft_priv to core.h and use it
      Staging: w35und: remove ->adapter from struct _HW_DATA_T
      Staging: w35und: clean up adapter.h a bit
      Staging: w35und: merge struct wb35_adapter to struct wbsoft_priv
      Staging: w35und: remove global struct ieee80211_hw
      Staging: w35und: inline DRIVER_AUTHOR and DRIVER_DESC macros
      Staging: w35und: clean up wblinux.c a bit
      Staging: w35und: remove unused ->ShutDowned member from struct LOCA=
L_PARA
      Staging: w35und: move global wbsoft_enabled to struct wbsoft_priv
      Staging: w35und: move packet_came() to wb35rx.c
      Staging: w35und: remove ->skb_array from struct wbsoft_priv
      Staging: w35und: remove ->shutdown from struct wbsoft_priv
      Staging: w35und: make functions local to mds.c static
      Staging: w35und: make functions local to mlmetxrx.c static
      Staging: w35und: remove dead code from mto.c
      Staging: w35und: make functions local to wb35rx.c static
      Staging: w35und: make functions local to wb35tx.c static
      Staging: w35und: remove dead code from wbhal.c
      Staging: w35und: remove rxisr.c as dead code
      ext3: allocate ->s_blockgroup_lock separately

Pekka J Enberg (2):
      ftrace: introduce tracing_reset_online_cpus() helper
      ext2: allocate ->s_blockgroup_lock separately

Pekka Paalanen (1):
      trace: add the MMIO-tracer to the tracer menu, cleanup

Pete Eberlein (2):
      Staging: go7007: saa7134 updates
      Staging: go7007: add sensoray 2250/2251 support

Pete Zaitcev (1):
      USB: Allow usbmon as a module even if usbcore is builtin

Peter (1):
      Btrfs: Correct usage of IS_ERR() in extent_io.c

Peter Griffin (2):
      sh: Add support for SH7201 CPU subtype.
      sh: RSK+ 7201 board support.

Peter Gruber (1):
      ALSA: Reduce stall detection timeout in riptide.c

Peter Hutterer (1):
      Input: synaptics - report multi-taps only if supported by the devic=
e

Peter Korsgaard (2):
      setlocalversion: print correct subversion revision
      setlocalversion: add git-svn support

Peter Leckie (2):
      [XFS] Clean up dquot pincount code.
      [XFS] Fix build brakage from patch "Clean up dquot pincount code"

Peter Oberparleiter (2):
      [S390] cio: update sac values
      [S390] cio: fix ccwgroup online vs. ungroup race condition

Peter P Waskiewicz Jr (4):
      ixgbe: Implement PCIe AER support
      net: Init NAPI dev_list on napi_del
      ixgbe: Fix NAPI enable/disable path when using DCB
      ixgbe: Fix set_ringparam in ixgbe to use the same memory pools.

Peter Popovec (1):
      Input: add joystick driver for Walkera WK-0701 RC transmitter

Peter Schlaile (2):
      mISDN: Fix HDLC DSP transmit
      mISDN: Make debug output a little bit more verbose

Peter Staubach (1):
      optimize attribute timeouts for "noac" and "actimeo=3D0"

Peter Tiedemann (1):
      [S390] convert ctcm printks to dev_xxx and pr_xxx macros.

Peter Ujfalusi (26):
      Input: omap-keypad - interrupt disable fix
      Input: omap-keypad - allow more than 6 rows
      ASoC: Fix for master playback/capture volume range for TWL4030 code=
c
      ASoC: TWL4030: Disable soft-volume
      ASoC: TWL4030: Change the Master volume control to TLV
      ASoC: TWL4030: Add CGAIN volume control
      ASoC: TWL4030: Add helper function for output gain controls
      ASoC: TWL4030: Change the capture volume control to TLV
      ASoC: TWL4030: Change the common playback volume controls
      ASoC: TWL4030: Add volume controls for outputs
      ASoC: TWL4030: Correct DAPM_DAC with power control
      ASoC: TWL4030: Add Analog PGA control switch to DAPM
      ASoC: TWL4030: Add DAPM event handler for output MUX selection
      ASoC: TWL4030: DAPM mapping of the Earpiece output
      ASoC: TWL4030: DAPM mapping of the PreDriv outputs
      ASoC: TWL4030: DAPM mapping of the Headset outputs
      ASoC: TWL4030: DAPM mapping of the Carkit outputs
      ASoC: TWL4030: DAPM mapping of the Handsfree outputs
      ASoC: TWL4030: Do not alter the Headset output volume on power-up/d=
own
      ASoC: TWL4030: Add missing Carkit output
      ASoC: TWL4030: Small cleanup
      ASoC: TWL4030: Change the name for the DACs
      ASoC: TWL4030: Make the enum filter generic for twl4030
      ASoC: TWL4030: DAPM based capture implementation
      ASoC: New enum type: value_enum
      ASoC: TWL4030: Convert the bitfield enums to VALUE_ENUM type

Peter Zijlstra (23):
      lockstat: documentation update
      lockdep: add might_lock() / might_lock_read()
      lockstat: fixup signed division
      futex: rely on get_user_pages() for shared futexes
      futex: reduce mmap_sem usage
      futex: use fast_gup()
      futex: cleanup fshared
      futex: fixup get_futex_key() for private futexes
      lockstat: contend with points
      sched, ftrace: trace sched.c
      ftrace: ftrace_dump_on_oops=3D[tracer]
      ftrace: sysrq-z to dump the buffers
      ftrace: sysctl typo
      hrtimer: removing all ur callback modes
      lockdep: change a held lock's class
      hrtimer: removing all ur callback modes, fix hotplug
      hrtimer: removing all ur callback modes, fix
      sched: fix tracepoints in scheduler
      sched: optimize update_curr()
      sched, trace: update trace_sched_wakeup()
      locking, percpu counters: introduce separate lock classes
      hrtimer: fix recursion deadlock by re-introducing the softirq
      sched: fix possible recursive rq->lock

Petr Tesarik (1):
      tcp: remove an unnecessary field in struct tcp_skb_cb

Pham Thanh Nam (2):
      V4L/DVB (10156): saa7134: Add support for Avermedia AVer TV GO 007 =
FM Plus
      V4L/DVB (10161): saa7134: fix autodetection for AVer TV GO 007 FM P=
lus

Phil Endecott (1):
      USB: Remove restrictions on signal numbers in devio.c

Philip Langdale (1):
      Input: refactor evdev 32bit compat to be shareable with uinput

Philip Rakity (1):
      [MTD] [NAND] add cmdline parsing (mtdparts=3D) support to cafe_nand

Philipp Kohlbecher (1):
      x86: documentation fix regarding boot protocol

Philipp Zabel (3):
      [ARM] pxa: cpufreq-pxa2xx: sdram_rows detection support
      USB: otg: gpio_vbus transceiver stub
      USB: otg: add otg_put_transceiver()

Phillip Lougher (17):
      Squashfs: inode operations
      Squashfs: directory lookup operations
      Squashfs: directory readdir operations
      Squashfs: regular file operations
      Squashfs: symlink operations
      Squashfs: super block operations
      Squashfs: export operations
      Squashfs: fragment block operations
      Squashfs: uid/gid lookup operations
      Squashfs: cache operations
      Squashfs: block operations
      Squashfs: header files
      Squashfs: Makefiles
      Squashfs: Kconfig entry
      Squashfs: initrd support
      Squashfs: documentation
      MAINTAINERS: squashfs entry

Pierre Ossman (2):
      sdhci: handle built-in sdhci with modular leds class
      Merge branch 'master' of ../mmc

Prarit Bhargava (1):
      x86: warn of incorrect cpu_khz on AMD systems

Qinghuang Feng (14):
      net: remove redundant argument comments
      ASoC: Clean up kernel-doc for snd_soc_dai_set_fmt
      ALSA: sound/pci/hda/hda_codec.c: cleanup kernel-doc
      [libata] Update kernel-doc comments to match source code
      block/blk-tag.c: cleanup kernel-doc
      Staging: usbip: cleanup kerneldoc
      samples: mark {static|__init|__exit} for {init|exit} functions
      fs/binfmt_misc.c: add terminating newline to /proc/sys/fs/binfmt_mi=
sc/status
      fs/ncpfs/getopt.c: cleanup keneldoc
      fs/ecryptfs/inode.c: cleanup kerneldoc
      USB: gadget: pxa27x_udc.c: cleanup kernel-doc
      USB: serial: ipw.c: mark {__init|__exit} for usb_ipw_{init|exit}
      drivers/xen/xenbus/xenbus_client.c: cleanup kerneldoc
      ext2: fix ext2_splice_branch() comments

Rafael J. Wysocki (32):
      skge: adapt skge to use reworked PCI PM
      e100: adapt to the reworked PCI PM
      Sound: hda - Restore PCI configuration space with interrupts off
      x86: change static allocation of trampoline area
      ACPI hibernate: Add a mechanism to save/restore ACPI NVS memory
      x86 hibernate: Mark ACPI NVS memory region at startup
      ACPI hibernate: Introduce new kernel parameter acpi_sleep=3Ds4_nonv=
s
      Hibernate: Do not oops on resume if image data are incorrect
      Hibernate: Take overlapping zones into account (rev. 2)
      Hibernate: Replace unnecessary evaluation of pfn_to_page()
      ACPI: Do not modify SCI_EN directly
      PM: Simplify the new suspend/hibernation framework for devices
      PCI: Rework default handling of suspend and resume
      PCI: Suspend and resume PCI Express ports with interrupts disabled
      PCI: handle PCI state saving with interrupts disabled
      PCI PM: Fix pci_update_current_state
      PCI PM: Split PCI Express port suspend-resume
      x86/PCI: Do not use interrupt links for devices using MSI-X
      PCI: PCIe portdrv: Add kerneldoc comments to some core functions
      PCI: PCIe portdrv: Fix suspend and resume of PCI Express port servi=
ces
      PCI: PCIe portdrv: Rearrange code so that related things are togeth=
er
      PCI: PCIe portdrv: Add kerneldoc comments to remining core funtions
      PCI PM: Fix poweroff and restore callbacks
      PCI PM: Add suspend counterpart of pci_reenable_device
      PCI PM: Power-manage devices without drivers during suspend-resume
      PCI PM: Move pci_has_legacy_pm_support
      PCI PM: Avoid touching devices behind bridges in unknown state
      PCI PM: Rearrange code in pci-driver.c
      PCI PM: Call pci_fixup_device from legacy routines
      PCI PM: Register power state of devices during initialization
      PCI PM: Run default PM callbacks for all devices using new framewor=
k
      PCI PM: Put PM callbacks in the order of execution

Rafi Rubin (1):
      HID: add n-trig digitizer support

Rakib Mullick (1):
      init: properly placing noinline keyword

Ralph Campbell (3):
      IB/ipath: Improve UD loopback performance by allocating temp array =
only once
      IB/ipath: Fix PSN of send WQEs after an RDMA read resend
      IB/ipath: Check return value of dma_map_single()

Ramax Lo (1):
      [ARM] 5358/1: AT2440EVB: Use new include path of mci.h

Rami Rosen (13):
      mac80211: remove unused declaration of struct sta_attribute.
      mac80211: use HWSIM_STA_MAGIC in hwsim_check_sta_magic() and hwsim_=
set_sta_magic().
      mac80211: check return value of dev_alloc_skb() in ieee80211_sta_jo=
in_ibss().
      mac80211: remove unnecessary include.
      wireless: missing include in lib80211.h
      mac80211: tx module cleanup.
      iwlwifi: cleanup (remove pm_state)
      iwlwifi: fix build error (iwl-rx.c).
      mac80211: misc cleanups
      iwlwifi: fix build warning (iwl-rx.c)
      iwlwifi: remove a parameter (dest) from *_fill_beacon_frame() metho=
ds.
      mac80211: fix a typo in ieee80211_send_assoc() method.
      iwlwifi: iwl-tx.c cleanup (remove unused parameter and unused local=
 variable).

Randy Dunlap (30):
      sched, documentation: update scheduler header file paths
      coda: fix creds reference
      nfsctl: add headers for credentials
      mac80211: remove more excess kernel-doc
      sctp: fix missing label when PROC_FS=3Dn
      [MTD] [NAND] remove excess kernel-doc notation
      kernel-doc: check for extra kernel-doc notations
      doc: fix kernel-parameters.txt formatting
      [SCSI] scsi ioctl: fix kernel-doc warning
      [SCSI] fusion: remove excess kernel-doc notation
      virtio_blk: fix type warning
      kbuild: make *config usage docs
      spi.h uses/needs device.h
      [MTD] [NAND] fix nandsim sched.h references
      fs: use menuconfig to control the Misc. filesystems menu
      fs/inode: fix kernel-doc notation
      sysrq: more explicit, less terse help messages
      fs: fix function param name in kernel-doc
      dmi: fix kernel-doc notation
      i2o: remove extraneous kernel-doc
      kmod: fix varargs kernel-doc
      docs: document how to write @varargs in kernel-doc
      rapidio: remove excess kernel-doc notation
      documentation: update header file paths
      documentation: update s390 header file paths
      documentation: how to use DOC: section blocks
      docs: add more early params to kernel-parameters.txt
      doc: reformat some long lines in kernel-parameters.txt
      jbd: remove excess kernel-doc notation
      regulator: fix kernel-doc warnings

Ravikiran G Thirumalai (1):
      x86: fix incorrect __read_mostly on _boot_cpu_pda

Reinette Chatre (2):
      iwlwifi: rely on API version read from firmware
      mac80211: remove WARN_ON() from ieee80211_hw_config

Reinhard Nissl (8):
      V4L/DVB (9445): Bug: Bandwidth calculation at upper and lower bound=
aries
      V4L/DVB (9446): Bug Fix an overflow in bandwidth calculation
      V4L/DVB (9447): stb6100: improve rounding
      V4L/DVB (9448): Bug: fix array size
      V4L/DVB (9449): Code Simplification: use do_div() instead
      V4L/DVB (9467): Fix runtime verbosity
      V4L/DVB (9468): Miscellaneous fixes
      [SCSI] mvsas: increase port type detection delay to suit Seagate's =
10k6 drive ST3450856SS 0003

Ren=C3=A9 B=C3=BCrgel (1):
      powerpc/mpc5200: Make PSC UART driver update serial errors counters

Richard A. Holden III (3):
      x86: fix arch/x86/kernel/genx2apic_uv_x.c build warning when !CONFI=
G_HOTPLUG_CPU
      x86: fix arch/x86/kernel/setup.c build warning when !CONFIG_X86_RES=
ERVE_LOW_64K
      coda: fix fs/coda/sysctl.c build warnings when !CONFIG_SYSCTL

Richard Kennedy (10):
      irq.h: remove padding from irq_desc on 64bits
      block: reorder struct bio to remove padding on 64bit
      fs: reorder struct inotify_device on 64bits to remove padding
      Staging: wlan-ng: p80211netdev.c fix netdev alloc to prevent oops o=
n device start
      Staging: wlan-ng: prism2_usb.c always enable the card in probe_usb
      Staging: wlan-ng: hfa384x_usb.c use newest version of 384x_drvr_sta=
rt
      Staging: wlan-ng: p80211wext.c add latest changes & remove extra nu=
lls from wext_handlers
      Staging: wlan-ng: p80211wext don't set default key id twice
      Staging: wlan-ng: hfa384x_usbin_callback: check for hardware remove=
d
      Staging: wlan-ng: p80211conv.c copy code from wlan-ng-devel branch =
to not drop packets

Richard Purdie (3):
      backlight: Add suspend/resume support to the backlight core
      leds: Add suspend/resume to the core class
      backlight: Rename the corgi backlight driver to generic

Rik van Riel (1):
      vmscan: bail out of direct reclaim after swap_cluster_max pages

Rikard Ljungstrand (1):
      Input: atkbd - add keyboard quirk for HP Pavilion ZV6100 laptop

Riku Voipio (1):
      leds: leds-pcs9532 - Move i2c work to a workqueque

Risto Suominen (1):
      ALSA: snd-powermac: enable mic on iMac G4

Robert Hancock (1):
      sata_sil: add Large Block Transfer support

Robert Jarzmik (12):
      [ARM] pxa: add muxed gpio wakeup sources on pxa2xx architectures
      [ARM] pxa: add resources for incoming rtc-pxa driver
      [ARM] pxa/MioA701: remove KConfig leds driver requirement
      [ARM] pxa/MioA701: add camera support for Mio A701 board.
      [ARM] pxa/MioA701: change reset function to preserve RTC.
      [ARM] pxa/MioA701: discovered new gpio definitions.
      [ARM] pxa/MioA701: improve power supply sources
      V4L/DVB (9530): Add new pixel format VYUY 16 bits wide.
      V4L/DVB (9791): pxa-camera: pixel format negotiation
      V4L/DVB (10065): mt9m111: add all yuv format combinations.
      V4L/DVB (10073): mt9m111: Add automatic white balance control
      rtc: driver for pxa27x and pxa3xx SoC

Robert Jennings (1):
      powerpc: Correct page-in counter for CMM with 64k pages

Robert Love (4):
      [SCSI] FC protocol definition header files
      [SCSI] libfc: A modular Fibre Channel library
      [SCSI] fcoe: Fibre Channel over Ethernet
      Staging: android: add logging driver

Robert Millan (1):
      make firmware/dsp56k/bootstrap.asm buildable on a56

Robert Olsson (2):
      niu: Naming interrupt vectors.
      ixgbe: Naming interrupt vectors

Robert P. J. Day (1):
      kbuild: remove TAR_IGNORE

Robert Reif (3):
      sparc: Use sparc64 version of prom/printf.c
      sparc: use sparc64 version of scatterlist.h
      sparc: fix array overrun check in of_device_64.c

Robert Richter (50):
      oprofile: comment cleanup
      oprofile: update comment for oprofile_add_sample()
      oprofile: whitspace changes only
      oprofile: fix typo
      x86/oprofile: reordering IBS code in op_model_amd.c
      x86/oprofile: cleanup IBS init/exit functions in op_model_amd.c
      oprofile: implement switch/case in buffer_sync.c
      oprofile: set values to default when creating oprofilefs
      ring_buffer: update description for ring_buffer_alloc()
      ftrace: remove unused function arg in trace_iterator_increment()
      oprofile: adding cpu buffer r/w access functions
      oprofile: adding cpu_buffer_write_commit()
      oprofile: adding cpu_buffer_entries()
      oprofile: moving cpu_buffer_reset() to cpu_buffer.h
      ring_buffer: add remaining cpu functions to ring_buffer.h
      oprofile: port to the new ring_buffer
      oprofile: remove nr_available_slots()
      oprofile: fix lost sample counter
      ring_buffer: adding EXPORT_SYMBOLs
      oprofile: rename kernel-wide identifiers
      oprofile: rename cpu buffer functions
      oprofile: remove ring buffer inline functions in cpu_buffer.h
      x86/oprofile: fix pci_dev use count for AMD northbridge devices
      oprofile: reordering some code in cpu_buffer.c
      oprofile: add inline function __oprofile_add_ext_sample()
      oprofile: simplify add_sample()
      oprofile: simplify sync_buffer()
      oprofile: simplify oprofile_begin_trace()
      oprofile: simplify add_sample() in cpu_buffer.c
      oprofile: simplify add_ibs_begin()
      oprofile: remove unused components in struct oprofile_cpu_buffer
      oprofile: remove unused ibs macro
      oprofile: remove backtrace code for ibs
      oprofile: making add_sample_entry() inline
      oprofile: rename variable ibs_allowed to has_ibs in op_model_amd.c
      oprofile: rename add_sample() in cpu_buffer.c
      oprofile: rename variables in add_ibs_begin()
      oprofile: add op_cpu_buffer_write_reserve()
      oprofile: modify op_cpu_buffer_read_entry()
      oprofile: rework implementation of cpu buffer events
      oprofile: add op_cpu_buffer_add_data()
      oprofile: add op_cpu_buffer_get_data()
      oprofile: use new data sample format for ibs
      ring_buffer: fix ring_buffer_event_length()
      oprofile: remove #ifdef CONFIG_OPROFILE_IBS in non-ibs code
      oprofile: make new cpu buffer functions part of the api
      Merge branch 'oprofile/ring_buffer' into oprofile/oprofile-for-tip
      powerpc/oprofile: fix cell/pr_util.h
      powerpc/oprofile: fix whitespaces in op_model_cell.c
      Merge branch 'oprofile/cell' into oprofile/oprofile-for-tip

Robin Getz (6):
      Blackfin arch: Add basic irq stack checking for Blackfin
      Blackfin arch: Update some inline assembly, tweak some register con=
straints
      Blackfin arch: panic when running on a chip rev below what we are c=
ompiled for
      Blackfin arch: fix bug - kernel detects BF532 incorrectly
      Blackfin arch: fix bug - BF527 0.2 silicon has different CPUID (DSP=
ID) value
      USB: musb: Make sure we program the correct values in only when nec=
essary.

Rodolfo Giometti (2):
      usb host: Oxford OXU210HP HCD driver.
      leds: ledtrig-timer - on deactivation hardware blinking should be d=
isabled

Roel Kluin (19):
      ext4: Use simple_strtol() instead of simple_strtoul() in ext4_ui_pr=
oc_open
      ALSA: sound: Make static
      net: Make static
      Input: make some variables and functions static
      ALSA: ASoC: fix a typo in omp-pcm.c
      qlge: ql_adapter_down() typo
      block: make blk_softirq_init() static
      EtherExpress16: fix printing timed out status
      V4L/DVB (9994): gspca: t613: Bad loop in om6802 reset.
      ACPI: ec.c, pci_link.c, video_detec.c: static
      mmc: balanc pci_iomap with pci_iounmap
      [SCSI] libsas: fix test for negative unsigned and typos
      isdn: capi: &&/|| typos
      DCB: fix kfree(skb)
      parisc: set_time() catch errors
      Staging: wlan-ng: skb_p80211_to_ether() - payload_length is unsigne=
d, check before subtraction
      hugetlb: unsigned ret cannot be negative
      USB: serial: usb_debug: Make static
      Make various things static

Roland Dreier (7):
      cxgb3: Fix sparse warning and micro-optimize is_pure_response()
      mlx4_core: Delete incorrect comment
      Merge branches 'cma', 'ehca', 'ipath', 'iser', 'mlx4' and 'nes' int=
o for-next
      RDMA/addr: Fix build breakage when IPv6 is disabled
      IB/mlx4: Fix reading SL field out of cqe->sl_vid
      Merge branches 'cma' and 'mlx4' into for-linus
      swiotlb: add missing __init annotations

Romain Beauxis (1):
      V4L/DVB (9864): gspca - ov519: Change copyright information.

Ron Lee (1):
      trivial: add missing printk loglevel in start_kernel

Ron Mercer (10):
      qlge: bugfix: Add missing pci_mapping_err checking.
      qlge: bugfix: Add missing pci_unmap_page call in receive path.
      qlge: bugfix: Fix shadow register endian issue.
      qlge: bugfix: Fix ring length setting for rx ring, large/small
      qlge: bugfix: Fix register access error checking.
      qlge: Fix sparse warnings for byte swapping in qlge_ethool.c
      qlge: Fix sparse endian warning for inbound packet control block fl=
ags.
      qlge: Fix sparse endian warning in ql_hw_csum_setup().
      qlge: Fix sparse warning regarding rx buffer queues.
      qlge: Fix sparse warnings for tx ring indexes.

Ronen Shitrit (3):
      [ARM] Orion: add the option to support different ehci phy initializ=
ation
      [ARM] Kirkwood: allow instantiating the second ethernet port
      [ARM] Kirkwood: properly handle the WAN port on newer RD88F6281 boa=
rds

Rui Sousa (2):
      lockdep: fix compilation when CONFIG_TRACE_IRQFLAGS_SUPPORT is not =
set
      lockdep, UML: fix compilation when CONFIG_TRACE_IRQFLAGS_SUPPORT is=
 not set

Russ Anderson (5):
      x86, uv: use consistent names for region size and conherence id on =
x86 and ia64
      x86: uv: Add UV watchlist bios call
      x86: uv: Add UV memory protection bios call
      x86: uv: Add UV reserved page bios call
      sgi-xp: xpc needs to pass the physical address, not virtual

Russell King (97):
      [ARM] remove memzero()
      [ARM] Arrange for platforms to select appropriate CPU support
      [ARM] clps7500: remove support
      [ARM] clkdev: add generic clkdev infrastructure
      [ARM] realview: convert to clkdev and lookup clocks by device name
      [ARM] integrator: convert to clkdev and lookup clocks by device nam=
e
      [ARM] versatile: convert to clkdev and lookup clocks by device name
      [ARM] pxa: convert to clkdev and match clocks by struct device wher=
e possible
      [ARM] pxa: don't pass a consumer clock name for devices with unique=
 clocks
      [ARM] sa1100: match clock by dev_name(dev)
      Merge branches 'core' and 'clks' into devel
      Merge branch 'clps7500' into devel
      Merge branch 'for-rmk' of git://linux-arm.org/linux-2.6 into devel
      [ARM] copypage: convert assembly files to C
      [ARM] copypage: provide our own copy_user_highpage()
      [ARM] clearpage: provide our own clear_user_highpage()
      Merge branch 'highmem' into devel
      [ARM] versatile: remove IRQ mask definitions
      [ARM] rpc: remove obsolete IO accessors
      [ARM] pxa: avoid polluting the kernel's namespace
      [ARM] imx: avoid polluting the kernel's namespace
      [ARM] h720x: avoid polluting the kernel's namespace
      [ARM] l7200: avoid polluting the kernel's namespace
      [ARM] lh7a40x: avoid polluting the kernel's namespace
      [ARM] aaec2000: avoid polluting the kernel's namespace
      [ARM] footbridge: avoid polluting the kernel's namespace
      [ARM] footbridge: mach/hardware.h doesn't require mach/memory.h
      [ARM] clps711x: avoid polluting the kernel's namespace
      [ARM] shark: remove old unused "translated" IO macros
      [ARM] shark: avoid polluting the kernel's namespace
      [ARM] iop3xx: avoid polluting the kernel's namespace
      [ARM] iop13xx: avoid polluting the kernel's namespace
      [ARM] ixp23xx: mach/io.h doesn't need BUG() anymore
      [ARM] ixp4xx: clean up includes
      [ARM] ns9xxx: mach/hardware.h doesn't need asm/memory.h
      [ARM] asm/system.h does not require asm/memory.h
      [ARM] Remove unnecessary mach/hardware.h includes in arch/arm/mm
      [ARM] move MAX_DMA_ADDRESS to mach/memory.h
      [ARM] fix constant values of MAX_DMA_ADDRESS
      [ARM] Hide ISA DMA API when ISA_DMA_API is unset
      [ARM] Rename ISA mach/dma.h header to mach/isa-dma.h
      [ARM] Remove linux/sched.h from asm/cacheflush.h and asm/uaccess.h
      [ARM] give RiscPC a NR_IRQS definition and remove default
      Merge branch 's3c-moves2' of git://aeryn.fluff.org.uk/bjdooks/linux=
 into devel
      [ARM] pnx4008: fix definition of PHYS_OFFSET
      [ARM] integrator: parenthesize __virt_to_bus/__bus_to_virt argument
      [ARM] Add a common typesafe __io implementation
      [ARM] Ensure that both MAX_DMA_ADDRESS and ISA_DMA_THRESHOLD are de=
fined
      [ARM] amba-clcd: don't use SZ_ constants in drivers
      [ARM] davinci: asm/memory.h is not required for mach/vmalloc.h
      [ARM] Update mach-types
      [ARM] ep93xx: convert to clkdev and match clocks by struct device w=
here possible
      [ARM] netx: fix simple clk API
      [ARM] aaec2000: convert to simple clk API
      [ARM] lh7a40x: clocks - cleanup
      [ARM] lh7a40x: convert to simple clk API
      [ARM] amba drivers: don't pass a consumer clock name for devices wi=
th unique clocks
      Merge branch 'clks' into devel
      [ARM] use asm/sections.h
      Merge branch 'for-rmk-realview' of git://linux-arm.org/linux-2.6 in=
to devel
      [ARM] fix missing includes for iop33x and sa1100_ir
      Merge branch 'for-rmk' of git://git.kernel.org/pub/scm/linux/kernel=
/git/ycmiao/pxa-linux-2.6 into devel
      [ARM] netwinder: clean up GPIO naming
      [ARM] dma: correct dma_supported() implementation
      [ARM] fix xm_x2xx_defconfig build errors
      Merge git://git.marvell.com/orion into devel
      [ARM] move asm/xip.h's mach/hardware.h include to mach/xip.h
      Merge branch 'for_rmk' of git://git.mnementh.co.uk/linux-2.6-im int=
o devel
      Merge branch 'omap3-upstream' of git://git.kernel.org/pub/scm/linux=
/kernel/git/tmlind/linux-omap-2.6 into devel
      Merge branch 'hsmmc-init' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/tmlind/linux-omap-2.6 into devel
      Merge branch 'mxc-pu-imxfb' of git://pasiphae.extern.pengutronix.de=
/git/imx/linux-2.6 into devel
      Merge branch 'rmk-devel-mxc-pu-v2' of git://pasiphae.extern.pengutr=
onix.de/git/imx/linux-2.6 into devel
      Merge branch 'next-merged' of git://aeryn.fluff.org.uk/bjdooks/linu=
x into devel
      Merge branch 'for-rmk' of git://git.pengutronix.de/git/imx/linux-2.=
6 into devel
      [ARM] s3c: define __io using the typesafe version
      Merge branch 'for-rmk' of git://git.pengutronix.de/git/ukl/linux-2.=
6 into devel
      Merge git://git.marvell.com/orion into devel
      [ARM] s3c: S3C options should depend on PLAT_S3C
      Merge branch 'for-rmk' of git://git.kernel.org/pub/scm/linux/kernel=
/git/ycmiao/pxa-linux-2.6 into devel
      Merge branch 'for_rmk' of git://git.mnementh.co.uk/linux-2.6-im int=
o devel
      Merge branch 'for-rmk' of git://git.kernel.org/pub/scm/linux/kernel=
/git/ycmiao/pxa-linux-2.6 into devel
      [ARM] footbridge: set dc21285 clock rate from command line
      Merge branch 'for_rmk' of git://git.mnementh.co.uk/linux-2.6-im int=
o devel
      Convert the oxsemi tornado special cases to use the quirk interface=
 and not
      And here's a patch (to be applied on top of the last) which prevent=
s
      remove linux/hardirq.h from asm-generic/local.h
      [ARM] Fix realview build
      [ARM] fix AT91, davinci, h720x, ks8695, msm, mx2, mx3, netx, omap1,=
 omap2, pxa, s3c
      [ARM] clps711x: fix warning in fortunet
      [ARM] clps711x: fix warning in edb7211-mm.c
      [ARM] remove missed CLPS7500 defconfig
      [ARM] fix pxa
      [ARM] fix pnx4008
      [ARM] fix netx
      [ARM] fix pxa930_trkball build errors
      Merge branch 'next-footbridge' of git://aeryn.fluff.org.uk/bjdooks/=
linux
      Merge branch 'devel'

Rusty Russell (117):
      sched: convert sched.c from for_each_cpu_mask to for_each_cpu.
      sched: get rid of boutique sched.c allocations, use cpumask_var_t.
      sched: remove any_online_cpu()
      sched: wrap sched_group and sched_domain cpumask accesses.
      sched: convert struct sched_group/sched_domain cpumask_ts to variab=
le bitmaps
      sched: convert nohz_cpu_mask to cpumask_var_t.
      sched: convert struct root_domain to cpumask_var_t.
      sched: convert nohz struct to cpumask_var_t.
      sched: convert idle_balance() to cpumask_var_t.
      sched: convert rebalance_domains() to cpumask_var_t.
      sched: convert sys_sched_getaffinity() to cpumask_var_t.
      sched: avoid stack var in move_task_off_dead_cpu
      sched: convert struct (sys_)sched_setaffinity() to cpumask_var_t.
      sched: convert sched_domain_debug to cpumask_var_t.
      sched: convert cpu_isolated_map to cpumask_var_t.
      sched: convert falback_doms to cpumask_var_t.
      sched: convert struct cpupri_vec cpumask_var_t.
      sched: convert check_preempt_equal_prio to cpumask_var_t.
      sched: convert local_cpu_mask to cpumask_var_t.
      sched: convert remaining old-style cpumask operators
      sched: convert nohz struct to cpumask_var_t, fix
      sched: convert local_cpu_mask to cpumask_var_t, fix
      sched: avoid stack var in move_task_off_dead_cpu, fix
      [CPUFREQ] clean up speedstep-centrino and reduce cpumask_t usage
      sparc: replace for_each_cpu_mask_nr with for_each_cpu
      cpumask: centralize cpu_online_map and cpu_possible_map
      cpumask: change cpumask_scnprintf, cpumask_parse_user, cpulist_pars=
e, and cpulist_scnprintf to take pointers.
      cpumask: make irq_set_affinity() take a const struct cpumask
      cpumask: convert struct clock_event_device to cpumask pointers.
      cpumask: Add CONFIG_CPUMASK_OFFSTACK
      cpumask: Introduce cpumask_of_{node,pcibus} to replace {node,pcibus=
}_to_cpumask
      cpumask: Use all NR_CPUS bits unless CONFIG_CPUMASK_OFFSTACK
      Merge ../linux-2.6-x86
      x86: remove impossible test in mtrr/main.c
      cpumask: x86: Introduce cpumask_of_{node,pcibus} to replace {node,p=
cibus}_to_cpumask
      cpumask: sparc: Introduce cpumask_of_{node,pcibus} to replace {node=
,pcibus}_to_cpumask
      cpumask: sh: Introduce cpumask_of_{node,pcibus} to replace {node,pc=
ibus}_to_cpumask
      cpumask: powerpc: Introduce cpumask_of_{node,pcibus} to replace {no=
de,pcibus}_to_cpumask
      cpumask: IA64: Introduce cpumask_of_{node,pcibus} to replace {node,=
pcibus}_to_cpumask
      cpumask: Mips: Introduce cpumask_of_{node,pcibus} to replace {node,=
pcibus}_to_cpumask
      cpumask: alpha: Introduce cpumask_of_{node,pcibus} to replace {node=
,pcibus}_to_cpumask
      cpumask: cpu_coregroup_mask(): x86
      cpumask: cpu_coregroup_mask(): sparc
      cpumask: cpu_coregroup_mask(): s390
      cpumask: Replace cpu_coregroup_map with cpu_coregroup_mask
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6
      cpumask: make CONFIG_NR_CPUS always valid.
      bitmap: test for constant as well as small size for inline versions
      bitmap: fix seq_bitmap and seq_cpumask to take const pointer
      cpumask: switch over to cpu_online/possible/active/present_mask: co=
re
      cpumask: make cpumask.h eat its own dogfood.
      cpumask: make set_cpu_*/init_cpu_* out-of-line
      cpumask: smp_call_function_many()
      cpumask: arch_send_call_function_ipi_mask: core
      cpumask: use for_each_online_cpu() in drivers/infiniband/hw/ehca/eh=
ca_irq.c
      cpumask: use new cpumask API in drivers/infiniband/hw/ehca
      cpumask: use new cpumask API in drivers/infiniband/hw/ipath
      cpumask: Use nr_cpu_ids in seq_cpumask
      virtio: Don't use PAGE_SIZE in virtio_pci.c
      virtio: rename 'pagesize' arg to vring_init/vring_size
      virtio: Don't use PAGE_SIZE for vring alignment in virtio_pci.
      virtio: use LGUEST_VRING_ALIGN instead of relying on pagesize
      virtio: use KVM_S390_VIRTIO_RING_ALIGN instead of relying on pagesi=
ze
      virtio: hand virtio ring alignment as argument to vring_new_virtque=
ue
      virtio: set max_segment_size and max_sectors to infinite.
      virtio: block: dynamic maximum segments
      net: make xfrm_statistics_seq_show use generic snmp_fold_field
      cpumask: prepare for iterators to only go to nr_cpu_ids/nr_cpumask_=
bits: net
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6
      KVM: Extract core of kvm_flush_remote_tlbs/kvm_reload_remote_mmus
      KVM: use modern cpumask primitives, no cpumask_t on stack
      KVM: use cpumask_var_t for cpus_hardware_enabled
      cpumask: Remove IA64 definition of total_cpus now it's in core code
      percpu: fix percpu accessors to potentially !cpu_possible() cpus: p=
npbios
      percpu: fix percpu accessors to potentially !cpu_possible() cpus: m=
32r
      cpumask: prepare for iterators to only go to nr_cpu_ids/nr_cpumask_=
bits.: core
      cpumask: Use accessors code in core
      parisc: remove gratuitous cpu_online_map declaration.
      avr32: define __fls
      blackfin: define __fls
      m68k: define __fls
      m68knommu: define __fls
      bitmap: find_last_bit()
      cpumask: Use find_last_bit()
      cpumask: Introduce topology_core_cpumask()/topology_thread_cpumask(=
): sparc
      cpumask: Introduce topology_core_cpumask()/topology_thread_cpumask(=
): s390
      cpumask: Introduce topology_core_cpumask()/topology_thread_cpumask(=
): powerpc
      cpumask: Introduce topology_core_cpumask()/topology_thread_cpumask(=
): ia64
      cpumask: convert kernel trace functions
      cpumask: convert kernel trace functions further
      cpumask: remove any_online_cpu() users: kernel/
      cpumask: remove any_online_cpu() users: mm/
      cpumask: convert kernel/compat.c
      cpumask: convert kernel/workqueue.c
      cpumask: convert kernel time functions
      cpumask: convert kernel/irq
      cpumask: convert RCU implementations
      cpumask: convert kernel/profile.c
      cpumask: convert kernel/cpu.c
      cpumask: convert rest of files in kernel/
      cpumask: convert mm/
      cpumask: replace for_each_cpu_mask_nr with for_each_cpu in kernel/t=
ime/
      cpumask: zero extra bits in alloc_cpumask_var_node
      cpumask: CONFIG_DISABLE_OBSOLETE_CPUMASK_FUNCTIONS
      cris: define __fls
      frv: define __fls
      h8300: define __fls
      m32r: define __fls
      mn10300: define __fls
      xtensa: define __fls
      x86: use cpumask_var_t in acpi/boot.c
      cpumask: convert shared_cpu_map in acpi_processor* structs to cpuma=
sk_var_t
      cpumask: replace CPUMASK_ALLOC etc with cpumask_var_t
      cpumask: convert struct cpufreq_policy to cpumask_var_t
      kobject: Make Documentation/kobject.txt a little more coherent.
      USB: Don't use __module_param_call; use core_param.
      PCI: work_on_cpu: use in drivers/pci/pci-driver.c

R=C3=A9mi Denis-Courmont (8):
      Phonet: use net_device built-in stats for GPRS
      Phonet: basic net namespace support
      Phonet: improve GPRS variable names
      Phonet: allocate a non-Ethernet ARP type
      Phonet: allocate separate ARP type for GPRS over a Phonet pipe
      Phonet: use atomic for packet TX window
      Phonet: get rid of deferred work on the transmission path
      Phonet: USB CDC Phonet function for gadget framework

Saeed Bishara (1):
      rtc: driver for Marvell's SoCs 88F6281 and 88F6192

Sage Weil (8):
      Btrfs: Clone file data ioctl
      Btrfs: transaction ioctls
      Btrfs: fix ioctl-initiated transactions vs wait_current_trans()
      Btrfs: Fix makefile for builing btrfs static
      Btrfs: allow clone of an arbitrary file range
      Btrfs: remove unneeded total_trans
      Btrfs: remove unneeded btrfs_start_delalloc_inodes call
      Btrfs: mnt_drop_write in ioctl_trans_end

Sakari Ailus (2):
      tlan: Remove broken support for big buffers
      V4L/DVB (9815): omap2: add OMAP2 camera driver.

Sally, Gene (1):
      kbuild: gen_init_cpio expands shell variables in file names

Sam Ravnborg (100):
      kbuild: fix -I option expansion with O=3D... builds
      kbuild: expand -I in KBUILD_CPPFLAGS
      kbuild: teach mkmakfile to be silent
      kconfig: fix options to check-lxdialog.sh
      tags and cscope support really belongs in a shell script
      sparc: unify Kconfig.debug
      sparc: refactor Kconfig a little
      sparc64: added more config options to the menus
      sparc: drop UNIX98_PTYS from arch Kconfig
      sparc: use Kconfig.hz
      sparc: add menu "Executable file formats"
      sparc: add "Bus options" to Kconfig
      sparc,sparc64: unify Kconfig files
      sparc,sparc64: add BITS to arch Makefile
      sparc: cleanup math-emu
      sparc: prepare math-emu for unification
      sparc64: unify math-emu
      sparc64: unify arch/sparc64/oprofile/
      sparc: prepare mm/ for unification
      sparc,sparc64: unify mm/
      sparc,sparc64: prepare vmlinux.lds.S for unification
      sparc64: use vmlinux.lds.S from sparc
      sparc,sparc64: unify asm-offsets.c
      sparc: refactor Makefile
      sparc: clean boot/
      sparc: gitignore a few files
      sparc,sparc64: unify Makefile
      sparc: prepare prom/ for unification
      sparc,sparc64: unify prom/
      sparc: prepare lib/ for unification
      sparc,sparc64: unify lib/
      sparc: prepare kernel/ for unification
      sparc,sparc64: unify kernel/
      sparc,sparc64: unify boot/
      sparc: drop CONFIG_SUN_AUXIO
      sparc: unify kernel/init_task
      sparc: beautify kernel/cpu_32.c
      sparc: report "Unknown CPU/FPU" for unknown cpu/fpu
      sparc: fix sparse warnings in cpu_*.c
      sparc: expand cpu table
      sparc: unify kernel/cpu
      sparc: idprom_32.c cleanup
      sparc: unify kernel/idprom.c
      sparc: fix sparse warning in kernel/pmc.c
      sparc: fix trivial style issues in kernel/pmc.c
      sparc: fix sparse warnings in traps_32.c
      sparc: add include guards to kernel.h
      sparc: fix sparse warnings in irq_32.c
      sparc64: do not export pus_fs_struct
      kbuild: fix make incompatibility
      kbuild: simplify use of genksyms
      sparc: fix hardirq.h removal fallout
      sparc: introduce CONFIG_BITS
      sparc: unify module.h
      sparc64: use bit neutral Elf symbols
      sparc64: prepare module_64.c for unification
      sparc: unify module.c
      sparc: use .data.init_task section for init_thread_union
      sparc: unify sections.h
      sparc: drop SUN_IO
      sparc: move select of ARCH_SUPPORTS_MSI
      m68k: fix recursive dependency in Kconfig
      kconfig: explain symbol value defaults
      kconfig: add comments to symbol flags
      kconfig: struct property commented
      kconfig: improve error messages for bad source statements
      kbuild: check for leaked CONFIG_ symbols to userspace
      kbuild: document environment variables
      kbuild: drop debugging leftover in tags.sh
      kbuild: add checks for include of linux/types in userspace headers
      kbuild: ignore a few files in headers_check
      sparc: delete unused config symbols
      sparc: unify posix_types.h
      sparc32: drop __old_kernel_stat
      sparc32: use proper types in struct stat
      sparc: unify stat.h
      sparc64: prepare signal_64 for unification
      sparc: unify signal.h
      sparc: add '32' suffix to reg_window, sigcontext, __siginfo_t
      sparc: unify sigcontext.h
      sparc: unify ptrace.h
      sparc: unify siginfo.h
      sparc: remove ebus definitions from openprom*.h
      sparc: remove linux_prom_pci_assigned_addresses from openprom_32.h
      sparc: prepare openprom for unification
      sparc64: delete unused linux_prom64_ranges from openprom_64.h
      sparc: unify openprom.h
      sparc: fix warning in userspace header jsflash.h
      sparc: fix warnings in userspace header byteorder.h
      sparc: fix warning in userspace header traps.h
      sparc: drop get_tbr() in traps.h
      sparc: remove NO_PROC_ID - it is no longer used
      sparc: unify ipcbuf.h
      MAINTAINERS: update sparc maintainer
      sparc64: refactor code in viohs.c
      sparc64: refactor code in init_64.c
      sparc: refactor code in fault_32.c
      sparc64: Use unsigned long long for u64.
      sparc64: Fix unsigned long long warnings in drivers.
      fix modules_install via NFS

Samuel Ortiz (3):
      iwl3945: Select correct sta ID from find_station()
      mfd: Fix twl4030-core.c build error
      mfd: Use irq_to_desc in twl4030 code

San Mehat (1):
      Staging: android: add lowmemorykiller driver

Sandeep Patil (3):
      [ARM] S3C24A0: arch/arm/mach-s3c24a0/include/mach header files
      [ARM] S3C24A0: Correct S3C2410_PA_GPIO in S3C24XX_VA_GPIO
      [ARM] S3C24A0: Serial port definitions and driver support.

SangSu Park (1):
      USB: Fix goku_udc usb speed handling

Sangtae Ha (1):
      [TCP] CUBIC v2.3

Santosh Shilimkar (1):
      ARM: OMAP3: DMA: Fix for sDMA Errata 1.113

Sascha Hauer (31):
      [ARM] MX2: Add W1 device/resources
      [ARM] MX31: add w1 platform_device and resources
      [ARM] MX2 pcm038: add 1-wire master support
      [ARM] pcm037: add 1wire support
      [ARM] MX2: DMA updates
      MX27: Fix EMMA Base addresses
      [ARM] MX2: Add IRQ_GPIOE definition
      [ARM] MX27ads: remove unused define
      MX27: Add USB pin function defines
      [ARM] MX1/MX2: simplify mxc_gpio_setup_multiple_pins
      [ARM] MX3 iomux: add more pin definitions
      pcm038: add driver for static ram
      [ARM] pcm037: Add support for SRAM device
      [ARM] MX27: Add NAND resources
      [ARM] pcm038: Add NAND support
      [ARM] MX3: add NAND support
      [ARM] pcm037: add NAND support
      MAINTAINERS: Add myself as i.MX Framebuffer driver maintainer
      i.MX Framebuffer: remove gpio setup function
      i.MX Framebuffer: fix margins
      i.MX Framebuffer: remove header file
      i.MX Framebuffer: Cleanup Coding style
      i.MX Framebuffer: rename imxfb_mach_info to imx_fb_platform_data
      i.MX Framebuffer: add TFT support
      [ARM] MX1: Add missing selection of ARM920T
      [ARM] MX27ads: fix function name
      [ARM] MX1/MX2 DMA: add missing local_irq_restore()
      [ARM] MXC: remove dependency to other include files from irqs.h
      [ARM] MXC: do not include mach/hardware.h from mach/timex.h
      [ARM] MXC: do not include mach/hardware.h from mach/memory.h
      w1: add 1-wire master driver for i.MX27 / i.MX31

Sascha Sommer (1):
      sdricoh_cs: Add support for Bay Controller devices

Sathya Perla (5):
      Staging: benet: patch to remove subdirectories
      Staging: benet: fix build errors when CONFIG_NETPOLL is off
      Staging: benet: patch to use offsetof() instead of AMAP_BYTE_OFFSET=
()
      Staging: benet: fix problems reported by checkpatch
      Staging: benet: cleanup a check while posting rx buffers

Scott Feldman (5):
      enic: enable ethtool LRO support
      enic: driver/firmware API updates
      enic: mask off some reserved bits in CQ descriptor for future use
      enic: move wmb closer to where needed: before writing posted_index =
to hw
      enic: misc cleanup items:

Scott Waye (1):
      ALSA: hda - Add MCP67 HDMI support

Scott Wood (1):
      powerpc/bootwrapper: Use the child-bus #address-cells to decide whi=
ch range entry to use

Sean MacLennan (1):
      [MTD] [NAND] ndfc driver

Sebastian Andrzej Siewior (1):
      USB: isp1760: use a specific PLX bridge instead of any bdridge

Sebastian Ott (5):
      [S390] cio: move irritating comment.
      [S390] cio: introduce cio_update_schib
      [S390] cio: introduce cio_commit_config
      [S390] cio: commit all pmcw changes.
      [S390] cio: use pim to check for multipath.

Sebastian Siewior (1):
      powerpc/boot: Allocate more memory for dtb

Sebastien Dugue (3):
      powerpc/pseries: Fix getting the server number size
      powerpc/ibmebus: Get rid of the IRQ mapping in ibmebus_free_irq()
      powerpc/pseries: Fix cpu hotplug

Sedji Gaouaou (2):
      ASoC: Merge AT91 and AVR32 support into a single atmel architecture
      ASoC: Add audio support for the Atmel AT91SAM9G20ek board(uing wolf=
son 8731).

Senthil Balasubramanian (12):
      ath9k: INI update for atheros chipets.
      ath9k: incorrect noise floor threshold values.
      ath9k: Build RFKILL feature even when RFKILL subsystem is a MODULE
      ath9k: IRQ should be disabled before calling free_irq()
      ath9k: Race condition in accessing TX and RX buffers.
      wireless: Incorrect LEAP authentication algorithm identifier.
      ath9k: Adding AR9285 chipset register information.
      ath9k: Adding initvalues for Atheros AR9285 chipset.
      ath9k: Adding support for Atheros AR9285 chipset.
      ath9k: Incorrect band enum causes invalid antenna configuration.
      ath9k: avoid rx frames with corrupted descriptor.
      ath9k: BH shouldn't be enabled when hardirqs are disabled.

Serge E. Hallyn (5):
      file capabilities: add no_file_caps switch (v4)
      user namespaces: let user_ns be cloned with fairsched
      user namespaces: require cap_set{ug}id for CLONE_NEWUSER
      user namespaces: document CFS behavior
      devices cgroup: allow mkfifo

Serge Hallyn (2):
      User namespaces: set of cleanups (v2)
      User namespaces: use the current_user_ns() macro

Sergei Shtylyov (4):
      ide: don't set hwif->dma_ops in init_dma() method
      ide: move read_sff_dma_status() method to 'struct ide_dma_ops'
      ide-dma-sff: factor out ide_dma_sff_write_status()
      scc_pata: make use of scc_dma_sff_read_status()

Sergey Ovcharenko (1):
      USB: storage: unusual_devs.h additions for Macpower MasterBox

Sergio Luis (2):
      smackfs: check for allocation failures in smk_set_access()
      x86: mark get_cpu_leaves() with __cpuinit annotation

Shane Huang (2):
      [libata] ahci: Add SATA GEN3 related messages
      [libata] ahci: Withdraw IGN_SERR_INTERNAL for SB800 SATA

Shane McDonald (1):
      Resurrect IT8172 IDE controller driver

Shaohua Li (1):
      PCI: keep ASPM link state consistent throughout PCIe hierarchy

Shen Feng (2):
      Btrfs: fix a memory leak in btrfs_get_sb
      Btrfs: do not call kfree if kmalloc failed in btrfs_sysfs_add_super

Sheng Yang (24):
      x86: Rename mtrr_state struct and macro names
      x86: Export some definition of MTRR
      KVM: Improve MTRR structure
      KVM: VMX: Add PAT support for EPT
      KVM: Add local get_mtrr_type() to support MTRR
      KVM: Enable MTRR for EPT
      KVM: Clean up kvm_x86_emulate.h
      KVM: MMU: Extend kvm_mmu_page->slot_bitmap size
      KVM: VMX: Move private memory slot position
      KVM: IRQ ACK notifier should be used with in-kernel irqchip
      KVM: Enable Function Level Reset for assigned device
      KVM: Fix kernel allocated memory slot
      KVM: Move ack notifier register and IRQ sourcd ID request
      KVM: Separate update irq to a single function
      KVM: Replace irq_requested with more generic irq_requested_type
      KVM: Clean up assigned_device_update_irq
      KVM: Add fields for MSI device assignment
      KVM: Export ioapic_get_delivery_bitmask
      KVM: Add assigned_device_msi_dispatch()
      KVM: Enable MSI for device assignment
      KVM: MSI to INTx translate
      PCI: Refactor pci_reset_function()
      PCI: add PCI Advanced Feature Capability defines
      PCI: Extend pci_reset_function() to support PCI Advanced Features

Simon Arlott (1):
      netfilter: nf_nat: remove warn_if_extra_mangle

Simon Holm Th=C3=B8gersen (1):
      net/rfkill/rfkill.c: fix unused rfkill_led_trigger() warning

Simon Horman (1):
      IPVS: Make "no destination available" message more consistent betwe=
en schedulers

Sitsofe Wheeler (1):
      x86: change OPTIMIZE_INLINING help to say enabling makes smaller ke=
rnels

Solofo.Ramangalahy-6ktuUTfB/bM@public.gmane.org (1):
      ext4: When resizing set the EXT4_BG_INODE_ZEROED flag for new block=
 groups

Solomon Peachy (20):
      Staging: wlan-ng: Remove PCI/PLX/PCMCIA files.
      Staging: wlan-ng: Update Help text to mention prism3 devices.
      Staging: wlan-ng: Delete PCI/PLX/PCMCIA-specific code.
      Staging: wlan-ng: Make wlan-ng use WEXT mode by default.
      Staging: wlan-ng: Eliminate more <2.6 kernel support.
      Staging: wlan-ng: Eliminate all backwards-compatibility for <2.6.13=
 kernels.
      Staging: wlan-ng: Eliminate a boatload of tertiaryAP-only code.
      Staging: wlan-ng: Remove AP-only code from MLME functions.
      Staging: wlan-ng: Get rid of the MTU tests in the rx conversion pat=
h.
      Staging: wlan-ng: Eliminate one more rx mtu test.
      Staging: wlan-ng: Eliminate local 'version.h'
      Staging: wlan-ng: Eliminate usage of procfs.
      Staging: wlan-ng: Use standard kernel integer (u32/s32/etc) types.
      Staging: wlan-ng: Eliminate all backwards-compatible kernel code.
      Staging: wlan-ng: Wireless Extension support is mandatory.
      Staging: wlan-ng: use WIRELESS_EXT, not CONFIG_WIRELESS_EXT
      Staging: wlan-ng: Delete a large pile of now-unused code.
      Staging: wlan-ng: Delete a pile of unused mibs. And fix WEXT SET_TX=
POWER.
      Staging: wlan-ng: Consolidate wlan-ng into a single module.
      Staging: wlan-ng: Purge all MIBs not used internally.

Sonic Zhang (14):
      Blackfin arch: Fix bug - hardware breakpoint doesn't always work in=
 kgdb
      Blackfin Serial Driver: updates kgdb over Blackfin serial driver wi=
th kgdb framework
      Blackfin Serial Driver: Clean serial console and early prink code.
      Blackfin Serial Driver: Fix bug - BF527-EZKIT unable to receive lar=
ge files over UART in DMA mode
      Blackfin Serial Driver: Remove BI status for known_good_char
      Blackfin arch: Use reads/writes instead of ins/outs directly
      Blackfin arch: disable pthread stack check for SMP at runtime
      Blackfin arch: Make bfin_mac built for bf51x
      Blackfin arch: fix bug - kernel stops at initial console
      Blackfin arch: enable reprogram cclk and sclk for bf518f-ezbrd
      Blackfin arch: Set PB4 as the default irq for bf548 board v1.4+.
      Blackfin arch: update board default configs
      netdev: bfin_mac: enable bfin_mac net dev driver for BF51x
      pata_platform: __pata_platform_remove() shouldn't be in discard sec=
tion

Sonny Rao (1):
      powerpc/BSR: Support multiple OF-node description of BSR

Sripathi Kodi (1):
      sched, lockdep: inline double_unlock_balance()

Stanley.Miao (2):
      ARM: OMAP3: LDP: Add Ethernet device support to make ldp boot succe=
ess
      ASoC: TWL4030: hands-free start-up sequence.

Stefan Assmann (5):
      x86, pci: introduce pci=3Dnoioapicquirk kernel cmdline option
      x86, pci: introduce pci=3Dioapicreroute kernel cmdline option
      pci: add quirk to disable boot interrupt generation on intel 6300ES=
B
      pci, acpi: reroute PCI interrupt to legacy boot interrupt equivalen=
t
      x86, pci: introduce config option for pci reroute quirks (was: [PAT=
CH 0/3] Boot IRQ quirks for Broadcom and AMD/ATI)

Stefan Haberland (3):
      [S390] dasd: improve dasd statistics proc interface
      [S390] dasd: correct sense byte condition for SIM
      [S390] dasd: call cleanup_cqr with request_queue_lock

Stefan Richter (10):
      ieee1394: replace a GFP_ATOMIC by GFP_KERNEL allocation
      ieee1394: mark all hpsb_address_ops instances as const
      ieee1394: ohci1394: pass error codes from request_irq through
      ieee1394: ohci1394: flush MMIO writes before delay in initializatio=
n
      ieee1394: ignore nonzero Bus_Info_Block.max_rom, fetch config ROM i=
n quadlets
      firewire: fw-sbp2: remove unnecessary locking
      firewire: fix small memory leak at module removal
      firewire: fix resetting of bus manager retry counter
      firewire: reorder struct fw_card for better cache efficiency
      firewire: core: fix sleep in atomic context due to driver core chan=
ge

Stefan Roese (2):
      UBI: return -ENOMEM upon failing vmalloc
      powerpc/4xx: Add L2 cache node to AMCC Canyonlands dts file

Stefan Roscher (1):
      IB/ehca: Replace modulus operations in flush error completion path

Stefan Schmidt (4):
      [ARM] pxa/ezx: Remove two memory banks fixup
      [ARM] pxa/ezx: GPIO configuration
      [ARM] pxa/ezx: Keypad configuration
      [ARM] pxa/ezx: I2C configuration

Stefan Weinhuber (1):
      [S390] dasd: send change uevents for dasd block devices

Stefano Panella (5):
      uwb: infrastructure for handling Relinquish Request IEs
      uwb: add commands to add/remove IEs to the debug interface
      uwb: per-radio controller event thread and beacon cache
      uwb: improved MAS allocator and reservation conflict handling
      uwb: remove beacon cache entry after calling uwb_notify()

Stelian Pop (2):
      Input: appletouch - driver refactoring
      [ARM] 5319/1: AT91: support AT91CAP9 revC CPUs

Stephen Hemminger (149):
      vlan: propogate ethtool speed values
      macvlan: add support for ethtool get settings
      atlx: use embedded net_device_stats
      atlx: timer cleanup
      net: increase receive packet quantum
      netem: eliminate unneeded return values
      tracing/fastboot: fix perlcritic warning
      tracing/fastboot: put error message on stderr
      netdev: network device operations infrastructure
      netdev: introduce dev_get_stats()
      netdev: expose ethernet address primitives
      netdev: convert loopback to net_device_ops
      ifb: convert to net_device_ops
      bridge: convert to net_device_ops
      veth: convert to net_device_ops
      macvlan: convert to net_device_ops
      ip: convert to net_device_ops for ioctl
      vlan: convert to net_device_ops
      bonding: convert to net_device_ops
      e1000e: convert to net_device_ops
      sky2: convert to net_device_ops
      skge: convert to net_device_ops
      8139: convert to net_device_ops
      tun: convert to net_device_ops
      atl1e: convert to net_device_ops
      atlx: convert to net_device_ops
      cxgb3: convert to net_device_ops
      cxgb2: convert to net_device_ops
      e1000: convert to net_device_ops
      via-velocity: convert to net_device_ops
      igb: convert to net_device_ops
      e100: convert to net_device_ops
      ppp: convert to net_device_ops
      enic: convert to net_device_ops
      ixgb: convert to net_device_ops
      tg3: convert to net_device_ops
      forcedeth: convert to net_device_ops
      niu: convert to net_device_ops
      acenic: convert to net_device_ops
      netdev: add more functions to netdevice ops
      dummy: convert to net_device_ops
      ipmr: convert ipmr virtual interface to net_device_ops
      fddi: convert to new network device ops
      defxx: convert driver to net_device_ops
      hippi: convert driver to net_device_ops
      ipip: convert to net_device_ops
      ipv6: convert tunnels to net_device_ops
      ipgre: convert to netdevice_ops
      jme: convert driver to net_device_ops
      s2io: convert to net_device_ops
      qlge: convert to net_device_ops
      qlge: fix sparse warnings
      via-rhine: convert to net_device_ops
      myri10ge: convert to net_device_ops
      mlx4: convert to net_device_ops
      bnx2: convert to net_device_ops
      dl2k: convert to net_device_ops
      netxen: convert to net_device_ops
      sfc: convert to net_device_ops
      tehuti: convert to net_device_ops
      sis900: convert to net_device_ops
      r6040: convert to net_device_ops
      yellowfin: convert to net_device_ops
      ns83820: convert to net_device_ops
      bnx2x: convert to net_device_ops
      hamachi: convert to net_device_ops
      qla3xxx: convert to net_device_ops
      sc92031: convert to net_device_ops
      eql: convert to net_device_ops
      ne2k: convert to net_device_ops
      8139too: use err.h macros
      netdev: add HAVE_NET_DEVICE_OPS
      8390: add common net_device ops
      wd: use net_device_ops
      hp-plus: convert to net_device_ops
      smc: convert to net_device_ops
      ne3210: convert to net_device_ops
      es3210: convert to net_device_ops
      e2100: convert to net_device_ops
      lne390: convert to net_device_ops
      hp: convert to net_device_ops
      ne2: convert to net_device_ops
      apne: convert to net_device_ops
      stnic: convert to net_device_ops
      3c503: convert to net_device_ops
      ne2000: convert to net_device_ops
      tc: propogate errors from tcf_hash_create
      tc: check for errors in gen_rate_estimator creation
      tc: policing requires a rate estimator
      etherh: build fix for net-next
      mac8390: update to net_device_ops
      zorro8390: convert to net_device_ops
      hydra: convert to net_device_ops
      ne-h8300: convert to net_device_ops
      irda: convert to internal stats
      bonding: use net_device_ops
      wireless: convert wireless ioctl to net_device_ops
      virtio: convert to net_device_ops
      xen-netfront: convert to net_device_ops
      sch_teql: convert to net_device_ops
      dsa: convert to net_device_ops (v2)
      ieee1394: convert to net_device_ops
      ieee1394: remove unneeded last_rx
      ieee1394: use internal network device stats
      PCI: handle long delays in VPD access
      PCI: revise VPD access interface
      PCI: add interface to set visible size of VPD
      appletalk: convert aarp to net_device_ops
      appletalk: convert ipddp to net_device_ops
      bluetooth: driver API update
      phonet: update to net_device_ops
      cassini: update to net_device_ops
      ipg: update to net_device_ops
      plip: update to net_device_ops
      tlan: update to net_device_ops
      epic100: update to net_device_ops
      sunhme: update to net_device_ops
      sungem: update to net_device_ops
      pcnet32: update to net_device_ops
      typhoon: update to net_device_ops
      enc28j60: update to net_device_ops
      de600: update to net_device_ops
      sis190: update to net_device_ops
      ns83820: fix net_device_ops support
      sb1000: update to net_device_ops
      natsemi: update to net_device_ops
      fealnx: update to net_device_ops
      starfire: update to net_device_ops
      sundance: update to net_device_ops
      tulip: convert devices to new API
      de2104x: convert to net_device_ops
      de4x5: convert to net_device_ops
      xircom: convert devices to new API
      dmfe: convert to new API
      uli526x: convert devices to new API
      windbond: convert devices to new API
      dvb: update network device to current API
      hysdn: convert to net_device_ops and other updates
      I4l: convert to net_device_ops
      fusion: convert devices to new API
      xpnet: convert devices to new API
      gadget: convert devices to new API
      uwb: convert devices to net_device_ops
      slip: convert to net_device_ops
      amd8111e: convert to net_device_ops
      atp: convert to net_device_ops
      b44: convert to net_device_ops
      hp100: update to net_device_ops
      pcnet32: round off carrier watch timer

Stephen M. Cameron (1):
      cciss: simplify parameters to deregister_disk function

Stephen Rothwell (17):
      ALSA: ASoC - restore removed variable declaration
      fs: xfs needs inode_wait to be exported
      powerpc/44x: update ppc44x_defconfig
      sparc: combine unistd_{32,64}.h
      tracing/fastboot: fix len of func buffer
      powerpc/iseries: viodasd needs to depend on CONFIG_BLOCK
      cifs: update for new IP4/6 address printing
      net: ehea NAPI interface cleanup fix
      V4L/DVB (9490): linux-next: v4l-dvb tree build failure
      net/ehea: bitops work on unsigned longs
      uio: make uio_info's name and version const
      net/ehea: use consistant type
      ibmveth: use consistent types
      powerpc/cell: Bitops work on unsigned longs
      powerpc/cell: local_irq_save takes an unsigned long
      powerpc: Remove unnecessary casts
      powerpc/cell: Fix the prototype of create_vma_map()

Stephen Smalley (1):
      SELinux: correctly detect proc filesystems of the form "proc/foo"

Stephen Ware (1):
      ASoC: Fix pxa2xx-pcm checks for invalid DMA channels

Steve Dickson (1):
      NFSD: FIDs need to take precedence over UUIDs

Steve French (8):
      [CIFS] add mount option to send mandatory rather than advisory lock=
s
      [CIFS] remove sparse warning
      [CIFS] fix typo
      [CIFS] various minor cleanups pointed out by checkpatch script
      [CIFS] Can not mount with prefixpath if root directory of share is =
inaccessible
      [CIFS] Cleanup: Move the check for too large R/W requests
      [CIFS] Streamline SendReceive[2] by using "goto out:" in an error c=
ondition
      [CIFS] make sure that DFS pathnames are properly formed

Steve Glendinning (18):
      SMSC LAN911x and LAN921x vendor driver
      smsc95xx: add tx checksum offload support
      smsc911x: add dynamic bus configuration
      smsc9420: SMSC LAN9420 10/100 PCI ethernet adapter
      smsc911x: make smsc911x_poll_controller static
      smsc9420: add netpoll support
      smsc9420: add ethtool eeprom support
      smsc9420: add ethtool register dump support
      net: Move flow control definitions to mii.h
      net: Refactor full duplex flow control resolution
      sh: Add platform-specific constants for SH7709
      sh: fix DMAOR register access on SH7709
      sh: add SH DMAC burst mode constant
      smsc911x: fix BUG if module is removed while interface is up
      smsc911x: convert driver to use net_device_ops
      smsc911x: make smsc911x_ethtool_ops constant
      smsc911x: don't clobber driver_data
      smsc911x: fix platform resource call during module unload

Steve Hodgson (2):
      sfc: Make reset_workqueue driver-global rather than per-NIC
      sfc: Treat probe as unsuccessful if it scheduled a reset

Steve Sakoman (3):
      ASoC: Add support for TWL4030 audio codec
      ASoC: Add support for Gumstix Overo
      ASoC: Add support for Beagleboard

Steven Noonan (1):
      USB: EHCI pci-quirks.c: don't wait so long for BIOS handoff

Steven Rostedt (98):
      ftrace: ftrace dump on oops control
      ftrace: nmi safe code modification
      ftrace: nmi update statistics
      ftrace, kbuild: condense recordmcount.pl parameter code
      ftrace: nmi safe code clean ups
      ftrace: fix hardirq header for non ftrace archs
      ftrace: introduce ftrace_preempt_disable()/enable()
      ftrace: insert in the ftrace_preempt_disable()/enable() functions
      ftrace: function tracer with irqs disabled
      ftrace: add quick function trace stop
      ftrace: soft tracing stop and start
      ftrace: restructure tracing start/stop infrastructure
      ring-buffer: convert to raw spinlocks
      ftrace: split out hardirq ftrace code into own header
      ftrace: fix set_ftrace_filter
      ftrace: fix boot trace sched startup
      ftrace: fix sched_switch API
      ftrace: irqsoff tracer incorrect reset
      ftrace: enable trace_printk by default
      ftrace: remove ctrl_update method
      ftrace: remove trace array ctrl
      ftrace: force pass of preemptoff selftest
      ftrace: display start of CPU buffer in trace output
      ftrace: prevent ftrace_special from recursion
      ring-buffer: replace most bug ons with warn on and disable buffer
      ring-buffer: add reader lock
      ring-buffer: clean up warn ons
      ring-buffer: fix deadlock from reader_lock in read_start
      tracing: profile likely and unlikely annotations
      tracing: likely/unlikely branch annotation tracer
      trace: rename unlikely profiler to branch profiler
      ftrace: rename unlikely iter_ctrl to branch
      ftrace: add tracer called branch
      ftrace: rename trace_unlikely.c file
      ftrace: rename trace_entries to buffer_size_kb
      ftrace: show buffer size in kilobytes
      ftrace: rename iter_ctrl to trace_options
      ftrace: CPU buffer start annotation clean ups
      ftrace: remove condition from ftrace_record_ip
      ftrace: disable ftrace on anomalies in trace start and stop
      ftrace: do not process freed records
      ftrace: replace raw_local_irq_save with local_irq_save
      ftrace: pass module struct to arch dynamic ftrace functions
      ftrace: allow NULL pointers in mcount_loc
      ftrace: fix dyn ftrace filter
      ftrace: make filtered functions effective on setting
      powerpc: ftrace, do not latency trace idle
      powerpc: ftrace, convert to new dynamic ftrace arch API
      powerpc: ftrace, use probe_kernel API to modify code
      powerpc/ppc64: ftrace, handle module trampolines for dyn ftrace
      powerpc/ppc32: ftrace, dynamic ftrace to handle modules
      ftrace: add support for powerpc to recordmcount.pl script
      ftrace: create default variables for archs in recordmcount.pl
      trace: remove extra assign in branch check
      trace: consolidate unlikely and likely profiler
      trace: branch profiling should not print percent without data
      trace: profile all if conditionals
      ring-buffer: add tracing_off_permanent
      ftrace: add ftrace_off_permanent
      trace: fix compiler warning in branch profiler
      ftrace: add function tracing to single thread
      ftrace: use code patching for ftrace graph tracer
      ftrace: let function tracing and function return run together
      ftrace: add thread comm to function graph tracer
      ftrace: add cpu annotation for function graph tracer
      powerpc: ftrace, do nothing in mcount call for dyn ftrace
      powerpc: ftrace, fix cast aliasing and add code verification
      powerpc: ftrace, added missing icache flush
      powerpc: ftrace, use create_branch
      powerpc/ppc32: static ftrace fixes for PPC32
      ftrace: replace raw_local_irq_save with local_irq_save
      ring-buffer: move some metadata into buffer page
      ring-buffer: read page interface
      ftrace: clean up function graph asm
      ftrace: have function graph use mcount caller address
      ftrace: add ftrace_graph_stop()
      ring-buffer: change "page" variable names to "bpage"
      ftrace: print real return in dumpstack for function graph
      ftrace: function graph return for function entry
      ftrace: add checks on ret stack in function graph
      trace: fix output of stack trace
      ftrace: fix race in function graph during fork
      ftrace: graph of a single function
      ftrace: use task struct trace flag to filter on pid
      ftrace: trace single pid for function graph tracer
      pid: fix the do_each_pid_task() macro
      ftrace: use struct pid
      ftrace: add ability to only trace swapper tasks
      ftrace: use init_struct_pid as swapper pid
      trace: add a way to enable or disable the stack tracer
      trace: better use of stack_trace_enabled for boot up code
      ftrace: add not to regex on filtering functions
      ring-buffer: fix dangling commit race
      ring-buffer: prevent false positive warning
      V4L/DVB (10129): dvb: remove deprecated use of RW_LOCK_UNLOCKED in =
frontends
      make INIT_FS use the __RW_LOCK_UNLOCKED initialization
      sparc: make proces_ver_nack a bit more readable
      powerpc: enable dynamic ftrace

Steven Whitehouse (30):
      dlm: fix up memory allocation flags
      dlm: remove kmap/kunmap
      dlm: replace schedule with cond_resched
      GFS2: Support for FIEMAP ioctl
      GFS2: Rationalise header files
      GFS2: Fix up jdata writepage/delete_inode
      GFS2: Move generation number into "proper" part of inode
      GFS2: Move "entries" into "proper" inode
      GFS2: Move di_eattr into "proper" inode
      GFS2: Move i_size from gfs2_dinode_host and rename it to i_disksize
      GFS2: Banish struct gfs2_dinode_host
      GFS2: Move rg_igeneration into struct gfs2_rgrpd
      GFS2: Move rg_free from gfs2_rgrpd_host to gfs2_rgrpd
      GFS2: Banish struct gfs2_rgrpd_host
      GFS2: Add more detail to debugfs glock dumps
      GFS2: Clean up & move gfs2_quotad
      GFS2: Fix "truncate in progress" hang
      GFS2: Move gfs2_recoverd into recovery.c
      GFS2: Kill two daemons with one patch
      GFS2: Send some sensible sysfs stuff
      GFS2: Fix bug in gfs2_lock_fs_check_clean()
      GFS2: Move four functions from super.c
      GFS2: Remove ancient, unused code
      GFS2: Fix use-after-free bug on umount
      GFS2: Send useful information with uevent messages
      GFS2: Streamline alloc calculations for writes
      Revert "GFS2: Fix use-after-free bug on umount"
      GFS2: Fix use-after-free bug on umount (try #2)
      GFS2: Set GFP_NOFS when allocating page on write
      GFS2: LSF and LBD are now one and the same

Stoyan Gaydarov (1):
      Staging: et131x: Cleanup et131x_debug.h defines

Stuart Hopkins (1):
      Input: atkbd - Samsung NC10 key repeat fix

Subbu Seetharaman (1):
      Staging: Add ServerEngines benet 10Gb ethernet driver

Sujith (57):
      mac80211: Change WARN_ON to WARN_ON_ONCE
      ath9k: Check if the STA supports HT when initializing rate control
      mac80211: Re-enable aggregation
      ath9k: Node cleanup
      ath9k: Simplify node attach/detach routines
      ath9k: Revamp transmit control block
      ath9k: Remove SM Power Save as it is not supported now
      ath9k: Ensure ath_node is not NULL when updating tx chainmask
      ath9k: Use bitfields to store tid's state in a single variable
      ath9k: Revamp VAP management
      ath9k: Refactor hw.c
      ath9k: Remove unused function ath_get_currentCountry()
      ath9k: Streamline attach/detach
      ath9k: Remove unnecessary TSF reset
      ath9k: Enable interrupts at the proper place
      ath9k: Remove ath_tx_aggr_resp()
      ath9k: Clear HT info on starting the driver
      ath9k: Remove internal RX A-MPDU processing
      mac80211: Add a new event in ieee80211_ampdu_mlme_action
      ath9k: Fix compilation failure when RFKILL is enabled
      mac80211: Use the HT capabilities from the IE instead of the statio=
n's caps.
      ath9k: Merge struct ath_tx_ratectrl with ath_rate_node
      ath9k: Simplify RC alloc/free functions
      ath9k: Remove ath_setup_rates
      ath9k: Remove ath_rate_newassoc()
      ath9k: Remove half/quarter rate tables
      ath9k: Nuke fixed rate handling in driver
      ath9k: Revamp RX handling
      ath9k: We don't support non-HT devices, so remove superfluous code.
      ath9k: Remove rate control reference in VAP
      ath9k: Remove ath_rate_softc
      ath9k: Use rate_driver_data
      ath9k: Remove ath9k_rate_table
      ath9k: General code scrub
      ath9k: Use helpers
      ath9k: Move TX completion routine to xmit.c
      ath9k: Fix bug in deciphering channel flags
      ath9k: Update TX trigger level on a FIFO underrun.
      ath9k: Use straightforward PCI routines to setup the TX buffer.
      ath9k: Code scrub
      ath9k: Use proper TX channel width for setting channels
      ath9k: Handle channel initialization for AP mode
      ath9k: Use cleaner debug masks
      ath9k: Add ATH9K_DEBUG configuration option
      ath9k: Remove includes that are not needed
      ath9k: Add initial layout for an ath9k specific debugfs mechanism
      ath9k: Add a debugfs file for dumping DMA status
      ath9k: Choose correct ANI calibration period
      ath9k: Fix bug in rate table management
      ath9k: Maintain rate table choice after association
      ath9k: Add a debugfs file to show interrupt statistics
      ath9k: Remove remaining occurrences of CONFIG_SLOW_ANT_DIV
      ath9k: Merge structures ath_atx, ath_node_aggr with ath_node
      ath9k: Refactor struct ath_softc
      mac80211: Fix HT channel selection
      ath9k: Do not use association state to update rate table
      ath9k: Protect config() callback with a mutex

Sukadev Bhattiprolu (12):
      Remove devpts_root global
      Per-mount allocated_ptys
      Per-mount 'config' object
      Extract option parsing to new function
      Add DEVPTS_MULTIPLE_INSTANCES config token
      Define mknod_ptmx()
      Define get_init_pts_sb()
      Enable multiple instances of devpts
      Document usage of multiple-instances of devpts
      SEND_SIG_NOINFO: masquerade si_pid when crossing pid-ns boundary
      SEND_SIG_NOINFO: set si_pid to tgid instead of pid
      mqueue: fix si_pid value in mqueue do_notify()

Sunil Mushran (5):
      ocfs2/dlm: Fix a race between migrate request and exit domain
      ocfs2/dlm: Clean up errors in dlm_proxy_ast_handler()
      ocfs2/dlm: Hold off sending lockres drop ref message while lockres =
is migrating
      ocfs2/dlm: Fix race in adding/removing lockres' to/from the trackin=
g list
      ocfs2/dlm: Fix race during lockres mastery

Suresh Siddha (2):
      x86: fix intel x86_64 llc_shared_map/cpu_llc_id anomolies
      x86: use logical apicid in x2apic_cluster's x2apic_cpu_mask_to_apic=
id_and()

Sven Wegener (7):
      Btrfs: Invalidate dcache entry after creating snapshot and
      Btrfs: Add compatibility for kernels >=3D 2.6.27-rc1
      leds: eds-pca9532: mark pca9532_event() static
      leds: Fixup kdoc comment to match parameter names
      leds: Fix sparse warning in leds-ams-delta
      leds: Fix wrong loop direction on removal in leds-ams-delta
      leds: leds-pca9532 - fix memory leak and properly handle errors

Swen Schillig (1):
      [SCSI] zfcp: register with SCSI layer on ccw registration

Syed Mohammed Khasim (1):
      i2c-omap: Add high-speed support to omap-i2c

Takahiro Yasui (2):
      dm log: fix dm_io_client leak on error paths
      dm log: avoid reinitialising io_req on every operation

Takanari Hayama (1):
      sh: add UIO support for JPU on SH7722.

Takashi Iwai (189):
      ALSA: hda - Add infrastructure for dynamic stream allocation
      ALSA: hda - Add generic arrays
      ALSA: hda - Use generic array helpers
      ALSA: hda - Allocate name string of each codec
      ALSA: hda - Manage kcontrol lists
      ALSA: hda - Add codec reconfiguration feature
      ALSA: hda - Add sysfs entries to hwdep devices
      ALSA: hda - Add init_verbs entries
      ALSA: hda - Add hints for reconfig
      ALSA: Print function symbol in the error messages
      Merge branch 'topic/hda-reconfig' into topic/hda-next
      ALSA: hda - Release jack instance for dynamic reconfigure
      ALSA: pcsp - Fix locking messes in snd-pcsp
      ALSA: Enable SPDIF output on ALC655
      ALSA: ice1724 - Fix TX IRQ lockup
      ALSA: Add hrtimer backend for ALSA timer interface
      Merge branch 'topic/hda-next' into topic/hda
      Merge branch 'topic/asoc-next' into topic/asoc
      Merge branch 'topic/misc-next' into topic/misc
      Merge branch 'topic/fix/asoc' into topic/asoc
      ALSA: hda - Remove old codec-probe limitation
      Merge branch 'topic/fix/hda' into topic/hda
      ALSA: hda - Fix indentation in hda_local.h
      Merge branch 'topic/fix/hda' into topic/hda
      ALSA: Fix a typo in Kconfig
      ALSA: ASoC - Fix a typo in Kconfig
      Merge branch 'topic/fix/asoc' into topic/asoc
      Merge commit 'v2.6.28-rc2' into topic/asoc
      Merge branch 'topic/fix/hda' into topic/hda
      ALSA: hda - Use macros to check array overflow
      ALSA: hda - Unify capture callbacks in realtek codes
      ALSA: hda - Unify capture mixer creation in realtek codes
      ALSA: hda - Re-add input-source control for Realtek
      ALSA: ice1724 - Fix IRQ register initialization
      ALSA: hda - Add ALC299 fujitsu preset model
      ALSA: hda - Fix missing ADC list in ALC260 auto-probe mode
      ALSA: hda - Fix possible NULL dereference
      ALSA: hda - Don't create empty PCM streams
      ALSA: ASoC - Remove unnecessary inclusion of linux/version.h
      ALSA: hda - Fix unused function in patch_intelhdmi.c
      ALSA: hda - Add ASUS V1Sn support
      ALSA: hda - Split ALC268 acer model
      ALSA: ice1724 - Re-fix IRQ mask initialization
      ALSA: hda - simplify hda_bus ops callbacks
      ALSA: hda - Make codec-probing more robust
      ALSA: hda - Add missing NULL check in amp hash allocation
      ALSA: hda - Add max allocation check in array allocator
      ALSA: hda - Fix broken hash chain allocation
      Merge branch 'topic/fix/misc' into topic/misc
      Merge branch 'topic/fix/hda' into topic/hda
      ALSA: Evaluate condition in snd_BUG_ON() in non-debugging case
      ALSA: Document debug macros
      ALSA: hda - Fix ALC260 hp3013 master switch
      ALSA: hda - Fix probe errors on Dell Studio Desktop
      ALSA: hda - Fix another cache list management
      Merge branch 'topic/fix/hda' into topic/hda
      ALSA: powermac - Rename mic-analog loopback mixer element
      Merge branch 'topic/fix/hda' into topic/hda
      ALSA: pcsp - Use HRTIMER_CB_IRQSAFE_UNLOCKED
      ALSA: hda - Support Headphone and Speaker volumes control on VAIO
      Merge branch 'topic/fix/hda' into topic/hda
      ALSA: hda - Create jack detection elements in build_controls
      ALSA: hda - Use init callback in stac92xx_resume()
      ALSA: hda - Fix restore of pin configs at resume for STAC/IDT codec=
s
      Merge branch 'topic/fix/hda' into topic/hda
      ALSA: hda - Allow multiple imux for matrix-type mixers of ALC codec=
s
      ALSA: hda - Show missing GPIO unsol bits
      ALSA: hda - make laptop-eapd model back for AD1986A
      Merge branch 'topic/fix/hda' into topic/hda
      ALSA: hda - Add missing static for snd_hda_eld_proc_new() inline fu=
nciton
      ALSA: hda - Fix double free of jack instances
      ALSA: hda - Release ELD proc file
      ALSA: hda - Make CONFIG_SND_HDA_RECONFIG for codec reconfiguration
      ALSA: hda - Move HD-audio Kconfig items to sound/pci/hda/Kconfig
      ALSA: hda - mark Dell studio 1535 quirk
      Merge branch 'topic/fix/hda' into topic/hda
      ALSA: hda - Fix build without CONFIG_PROC_FS
      ALSA: hda - No 'Headphone as Line-out' swich without line-outs
      ALSA: hda - Add probe_mask quirk for Medion MD96630
      ALSA: hda - Fix proc pcm rate bits
      Merge branch 'topic/fix/hda' into topic/hda
      ALSA: hda - Assign unsol tags dynamically in patch_sigmatel.c
      ALSA: hda - Add quirk for MSI 7260 mobo
      Merge branch 'topic/fix/hda' into topic/hda
      ALSA: hda - Really fix bits value in proc output
      Merge branch 'topic/misc' into topic/pcsp-fix
      ALSA: pcsp - Fix starting the stream with HRTIMER_CB_IRQSAFE_UNLOCK
      ALSA: hda - make some functions static
      ALSA: hda - Move power_save option to hda_intel.c
      ALSA: hda - Fix PCM reconfigure
      ALSA: hda - Fix creation of automatic capture mixers
      ALSA: hda - Modularize HD-audio driver
      ALSA: hda - Fix build error with CONFIG_SND_HDA_POWER_SAVE
      ALSA: hda - Add codec-specific proc hook
      ALSA: hda - Remove unused proc entry in hda_bus struct
      ALSA: hda - Add IDT/STAC-specific proc output
      ALSA: hda - Clear codec->proc_widget_hook at reset
      ALSA: hda - Add quirk for Sony VAIO VGN-SR19XN
      ALSA: hda - Check MODULE instead of CONFIG_SND_HDA_INTEL_MODULE
      ALSA: hda - Don't export symbols when built-in kernel
      ALSA: hda - Remove EXPERIMENTAL from CONFIG_SND_HDA_POWER_SAVE
      ALSA: ac97 - Remove EXPERIMENTAL from CONFIG_SND_AC97_POWER_SAVE
      ALSA: hda - Use amp cache for SPDIF mute controls in patch_sigmatel=
.c
      ALSA: hda - Remove unnecessary caches for power states in patch_sig=
matel.c
      ALSA: Fix a compile warning in cs46xx_lib.c
      ALSA: soc - Fix compile warnings in wm8903.c
      ALSA: soc - Remove obsoleted sound/driver.h inclusion
      Merge branch 'upstream' into topic/asoc
      ALSA: ASoC: Remove superfluous dependency on SND_SOC
      Revert "ALSA: soc - Fix compile warnings in wm8903.c"
      ALSA: ASoC: Fix compile warnings on corgi.c
      ALSA: ASoC: Fix old-style trigger callback in s3c2443-ac97.c
      ALSA: emu10k1 - Add capture boost mixer switch for Audigy
      Merge branch 'topic/hda-modularize' into topic/hda
      ALSA: Add more documentation about HD-audio driver
      ALSA: hda - Add forgotten module alias for Nvidia MCP67 HDMI
      ALSA: hda - Add reference to HD-Audio.txt in ALSA-Configuration.txt
      ALSA: ca0106 - Add power-management support
      ALSA: hda - Fix pin-detection in patch_sigmatel.c
      ALSA: hda - Proper power-map toggling for input pins
      ALSA: timer - Add comments and use ns_to_ktime()
      ALSA: hrtimer - Use hard-irq callback
      ALSA: Updates about bug-reporting in ALSA-Configuration.txt
      ALSA: ASoC - Fix module init entry for twl4030.c
      ALSA: ASoC - Fix wrong section types
      ALSA: ASoC - Fix symbol conflicts in omac-mcbsp.c
      ALSA: ca0106 - Check return value of pci_enable_device() in resume
      ALSA: hda - Update documentation
      ALSA: hda - Add quirk for HP6730B laptop
      ALSA: cs5535 - Make OLPC-stuff depending on MGEODE_LX
      ALSA: hda - Update HD-Audio.txt
      ALSA: ASoC - Fix DAI registration in s3c2443-ac97.c
      ALSA: hda - Fix a compile warning when CONFIG_PM=3Dn
      ALSA: sb8 - Fix a return code in the error path
      ALSA: hda - Fix another typo in HD-Audio.txt
      ALSA: hda - Add development tree URLs in HD-audio.txt
      ALSA: hda - Add Nvidia vendor id string
      ALSA: hda - Add Intel vendor id string
      ALSA: hda - Remove duplicated strings from codec name
      ALSA: hda - Convert from takslet_hi_schedule() to tasklet_schedule(=
)
      Merge branch 'fix/hda' into topic/hda
      Merge branch 'topic/hda-doc' into topic/hda
      ALSA: split HD-audio model list to HD-Audio-Models.txt
      ALSA: hda - Add missing initializations of amp and verb caches
      ALSA: hda - Use snd_hda_ctl_add() in patch_sigmatel.c
      ALSA: ca0106 - Don't override the values at resume
      ALSA: ca0106 - Add IEC958 PCM Stream controls
      ALSA: hda - Fix HD-Audio.txt reference of model list
      ALSA: ca0106 - Fix typo in resume code
      Merge branch 'fix/hda' into topic/hda
      ALSA: hda - Rework on STAC/IDT auto-configuration code
      ALSA: hda - Use more distinct name for a unique volume in STAC/IDT
      ALSA: hda - Add probe_only option
      Merge branch 'fix/asoc' into topic/asoc
      Merge branch 'topic/hda-stac-fix' into topic/hda
      ALSA: hda - Fix unused variable warnings in patch_sigmatel.c
      ALSA: hda - Power up always when no jack detection is available
      ALSA: ca0106 - Check ac97 availability at PM
      ALSA: ca0106 - Add missing card->private_data initialization
      ALSA: ca0106 - disable 44.1kHz capture
      ALSA: ASoC - Add missing __devexit annotation to wm8350.c
      ALSA: hda - Add quirk for another HP dv7
      Merge branch 'topic/pcsp-fix' into topic/misc
      Merge branch 'topic/hda-resume-fix' into topic/hda
      Merge branch 'topic/ca0106-capture-no-44khz' into topic/ca0106
      Merge branch 'topic/ca0106-resume' into topic/ca0106
      Merge branch 'topic/ca0106-spdif-stream' into topic/ca0106
      Merge branch 'fix/hda' into topic/hda
      Merge branch 'topic/aoa' into to-push
      Merge branch 'topic/asoc' into to-push
      Merge branch 'topic/audigy-capture-boost' into to-push
      Merge branch 'topic/ca0106' into to-push
      Merge branch 'topic/convert-tasklet' into to-push
      Merge branch 'topic/cs5535audio' into to-push
      Merge branch 'topic/hda' into to-push
      Merge branch 'topic/jack-mechanical' into to-push
      Merge branch 'topic/oxygen' into to-push
      Merge branch 'topic/pcxhr-update' into to-push
      Merge branch 'topic/snd-hrtimer' into to-push
      Merge branch 'topic/sound-core-fix' into to-push
      Merge branch 'topic/udev-id-rename' into to-push
      Merge branch 'topic/asoc' into for-linus
      Merge branch 'topic/hda' into for-linus
      Merge branch 'topic/usbaudio' into for-linus
      Merge branch 'fixes' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/broonie/sound-2.6 into topic/asoc
      Merge branch 'topic/asoc' into for-linus
      Merge branch 'topic/misc' into for-linus
      Merge branch 'topic/asoc' into for-linus
      Merge branch 'topic/asoc' into for-linus

Takashi Sato (3):
      filesystem freeze: add error handling of write_super_lockfs/unlockf=
s
      filesystem freeze: implement generic freeze feature
      filesystem freeze: remove XFS specific ioctl interfaces for freeze =
feature

Takashi YOSHII (1):
      sh: Add plain udivsi3 (not _i4*) for gcc-4.1 and lower.

Taku Izumi (3):
      PCI: revert additional _OSC evaluation
      PCI/ACPI: Remove unnecessary _OSC evaluation for control request
      pci-acpi: Cleanup _OSC evaluation code

Tao Ma (17):
      ocfs2/xattr: Remove additional bucket allocation in bucket defragme=
nt.
      ocfs2/xattr: Only set buffer update if it doesn't exist in cache.
      ocfs2/xattr: Only extend xattr bucket in need.
      ocfs2: Add clusters free in dealloc_ctxt.
      ocfs2/xattr: Move clusters free into dealloc.
      ocfs2/xattr: Reserve meta/data at the beginning of ocfs2_xattr_set.
      ocfs2/xattr: Merge xattr set transaction.
      ocfs2/xattr: Fix a bug in xattr allocation estimation
      ocfs2/xattr: Restore not_found in xis
      ocfs2: fix indendation in ocfs2_dquot_drop_slow
      ocfs2/quota: sparse fixes for quota
      ocfs2: Narrow the transaction for deleting xattrs from a bucket.
      ocfs2/quota: Add QUOTA in mlog_attribute.
      ocfs2/xattr: Remove extend_trans call and add its credits from the =
beginning
      ocfs2/xattr: Always updating ctime during xattr set.
      ocfs2/xattr: fix credits calculation during index create
      ocfs2: Access the right buffer_head in ocfs2_merge_rec_left.

Tej (1):
      xen: whitespace/checkpatch cleanup

Tejun Heo (23):
      fuse: move FUSE_MINOR to miscdevice.h
      fuse: don't let fuse_req->end() put the base reference
      fuse: implement ioctl support
      fuse: add file kernel handle
      fuse: implement unsolicited notification
      fuse: implement poll support
      fuse: add fuse_ prefix to several functions
      fuse: separate out fuse_conn_init() from new_conn()
      fuse: add fuse_conn->release()
      libata: beef up iterators
      libata: when restoring SControl during detach do the PMP links firs=
t
      libata: perform port detach in EH
      block: reorganize QUEUE_ORDERED_* constants
      block: remove duplicate or unused barrier/discard error paths
      block: make every barrier action optional
      block: make barrier completion more robust
      block: simplify empty barrier implementation
      block: fix empty barrier on write-through w/ ordered tag
      uevent: don't pass envp_ext[] as format string in kobject_uevent_en=
v()
      poll: allow f_op->poll to sleep
      ata_piix: save, use saved and restore IOCFG
      pata_hpt366: reimplement mode programming
      libata: use WARN_ON_ONCE on hot paths

Tetsuo Handa (1):
      do_coredump(): check return from argv_split()

Theodore Ts'o (26):
      ext3: Add support for non-native signed/unsigned htree hash algorit=
hms
      ext4: Add support for non-native signed/unsigned htree hash algorit=
hms
      ext3/4: Fix loop index in do_split() so it is signed
      Update Documentation/filesystems/ext4.txt
      ext4: remove ext4_new_blocks() and call ext4_mb_new_blocks() direct=
ly
      ext4: remove ext4_new_meta_block()
      ext4: remove do_blk_alloc()
      ext4: tone down ext4_da_writepages warnings
      jbd2: Add barrier not supported test to journal_wait_on_commit_reco=
rd
      ext4: remove extraneous newlines from calls to ext4_error() and ext=
4_warning()
      ext4: display average commit time
      ext4: add fsync batch tuning knobs
      ext4: Remove i_ext_generation from ext4_inode_info structure
      ext4: Make ext4_group_t be an unsigned int
      ext4: Change unsigned long to unsigned int
      jbd2: Remove a large array of bh's from the stack of the checkpoint=
 routine
      add releasepage hooks to block devices which can be used by file sy=
stems
      ext4: Remove code to create the journal inode
      ext4: Add markers for better debuggability
      jbd2: Add pid and journal device name to the "kjournald2 starting" =
message
      jbd2: Submit writes to the journal using WRITE_SYNC
      ext4: Add mount option to set kjournald's I/O priority
      ext4: Add sanity checks for the superblock before mounting the file=
system
      ext4: Make printk's consistently prefixed with "EXT4-fs: "
      block: Add Kconfig help which notes that ext4 needs CONFIG_LBD
      ext4: Remove "extents" mount option

Thomas Gleixner (9):
      x86: apic reset counter on shutdown
      Merge branch 'linus' into core/futexes
      futex: make clock selectable for FUTEX_WAIT_BITSET
      trace: fix task state printout
      sched_clock: prevent scd->clock from moving backwards, take #2
      hrtimer: splitout peek ahead functionality
      hrtimer: fix HOTPLUG_CPU=3Dn compile warning
      hrtimer: simplify hotplug migration
      hrtimer: fixup comments

Thomas Graf (1):
      pkt_sched: Control group classifier

Thomas Hommel (1):
      USB: isp1760: don't auto disable Port1 on ISP1761

Thomas Pfaff (1):
      tty: N_TTY SIGIO only works for read

Thomas Reitmayr (1):
      V4L/DVB (9981): [PATCH] usb-urb.c: Fix initialization of URB list.

Tiger Yang (13):
      ocfs2: move new inode allocation out of the transaction
      ocfs2: add ocfs2_xattr_set_handle
      ocfs2: add security xattr API
      ocfs2: add ocfs2_init_security in during file create
      ocfs2: add ocfs2_xattr_get_nolock
      ocfs2: add POSIX ACL API
      ocfs2: add ocfs2_check_acl
      ocfs2: add ocfs2_acl_chmod
      ocfs2: add ocfs2_init_acl in mknod
      ocfs2: add mount option and Kconfig option for acl
      ocfs2: calculate and reserve credits for xattr value in mknod
      ocfs2: alloc xattr bucket in ocfs2_xattr_set_handle
      ocfs2: Add xattr support checking in init_security

Tilman Schmidt (4):
      gigaset: remove unnecessary poll method
      gigaset: get rid of info() and warn() macros
      gigaset: use pr_err() and pr_info()
      gigaset: ifdef cleanup

Tim Abbott (1):
      kernel/module.c: compare symbol values when marking symbols as expo=
rted in /proc/kallsyms.

Tim Gardner (1):
      ipw2x00: change default policy for auto-associate

Tim Shimmin (2):
      [XFS] remove restricted chown parameter from xfs linux
      [XFS] remove restricted chown parameter from xfs linux

Tim Yamin (2):
      powerpc/mpc5200: Bestcomm fixes to ATA support
      powerpc/mpc5200: Add MDMA/UDMA support to MPC5200 ATA driver

Timur Tabi (1):
      ASoC: Disable automatic volume control in the CS4270 sound driver

Tom Tucker (2):
      svc: Move kfree of deferral record to common code
      svc: Clean up deferred requests on transport destruction

Tomas Winkler (34):
      iwlwifi: make initial calibration set configurable
      iwlwifi: take a valid antenna upon rate scale init
      iwlwifi: refactor rxon time command
      iwlwifi: remove host commands structures from iwl_cmd
      iwlwifi: add iwl_cmd_queue_free for readability
      iwlwifi: unify tx antenna toggling
      iwlwifi: fix TX cmd dma unmapping
      iwlwifi: tx command must run on same tfd as packet
      iwlwifi: protect headers from double inclusion
      iwlwifi: refactor TX response flow
      iwlwifi: don't update TFD free counter for invalid station
      iwlwifi: parametrize eeprom versions
      iwlwifi: calibration command namespace renaming
      iwlwifi: refactor tx byte count table usage
      iwlwifi: run through spell checker
      mac80211: fix basic rates setting from association response
      iwlwifi: revamp tx scheduler byte count tables handling
      iwlwifi: move spectrum measurement code to iwl-spectrum.c file
      mac80211: rc80211_pid eliminate sparse warnings
      iwlwifi: consolidate station management code
      iwlwifi: rs: remove fc variable and other cleanups
      iwlwifi: iwl-fh.h cleanup
      iwlwifi: enable base band calibration in 5000 HW
      Bluetooth: Fix TX error path in btsdio driver
      mac80211: disassociate prior to unlinking AP/station
      iwlwifi: properly initialize calibration command header
      iwlwifi: 5150 add support for 5150
      iwlwifi: 5150 enable DC calibration
      iwlwifi: 5150 compute ct kill threshold
      iwlwifi: 5150 parametrize eeprom versions
      iwlwifi: remove unused clip_groups priv member
      iwlwifi: remove includes of iwl-helpers.h where not needed
      iwlwifi: remove 4965 from common uCode API structures
      iwlwifi: add contact email to MODULE_AUTHOR

Tony Breeds (2):
      powerpc: Protect against NULL pointer deref in phyp-dump code
      powerpc: Pass a valid token to rtas_call() in phyp-dump code

Tony Lindgren (8):
      i2c-omap: Clean-up i2c-omap
      ARM: OMAP2: Prepare cpu detection for further improvements
      ARM: OMAP2: Fix cpu detection
      ARM: OMAP3: Warn about spurious interrupts
      omap mmc: Remove broken MMC init code
      omap mmc: Add better MMC low-level init
      omap mmc: Add low-level initialization for hsmmc controller
      USB: otg: sharable otg transceiver ops

Tony Vroon (3):
      ALSA: hda - Add lifebook model for Realtek ALC269
      fujitsu-laptop: Add BL power, LED control and radio state informati=
on
      fujitsu-laptop: Simplify SBLL/SBL2 backlight handling

Toshiyuki Okajima (2):
      ext3: provide function to release metadata pages under memory press=
ure
      ext4: provide function to release metadata pages under memory press=
ure

Trent Piepho (2):
      powerpc: Better setup of boot page TLB entry
      PCI: Make settable sysfs attributes more consistent

Trond Myklebust (37):
      SUNRPC: Remove the last remnant of the BKL...
      SUNRPC: Convert the xdr helpers and rpc_pipefs to EXPORT_SYMBOL_GPL
      SUNRPC: rpcsec_gss modules should not be used by out-of-tree code
      SUNRPC: nfsacl_encode/nfsacl_decode should be exported as GPL-only
      LOCKD: Make lockd_up() and lockd_down() exported GPL-only
      NFSv4: Fix up another delegation related race
      NFSv4: Fix up the dereferencing of delegation->inode
      NFS: Use atomic bitops when changing struct nfs_delegation->flags
      NFSv4: Clean up for the state loss reclaimer
      NFSv4: Callers to nfs4_get_renew_cred() need to hold nfs_client->cl=
_lock
      NFSv4: Fix state recovery when the client runs over the grace perio=
d
      NFSv4: Remove redundant RENEW calls if we know the lease has expire=
d
      NFSv4: Don't tell server we rebooted when not necessary
      NFSv4: Add a recovery marking scheme for state owners
      NFSv4: Ensure that nfs4_reclaim_open_state() doesn't depend on cl_s=
em
      NFS: Remove the unnecessary argument to nfs4_wait_clnt_recover()
      NFSv4: Ensure that file unlock requests don't conflict with state r=
ecovery
      NFSv4: Remove nfs_client->cl_sem
      NFSv4: Add recovery for individual stateids
      NFSv4: Clean up the support for returning multiple delegations
      NFSv4: Clean up NFS4ERR_CB_PATH_DOWN error management...
      NFSv4: Rename the state reclaimer thread
      NFSv4: Don't exit the state management if there are still tasks to =
do
      NFSv4: Fix a BAD_SEQUENCEID condition.
      NFSv4: Clean up nfs_expire_all_delegations()
      NFSv4: Clean up the asynchronous delegation return
      NFSv4: Return unreferenced delegations more promptly
      NFSv4: Fix up delegation callbacks
      NFSv4: Convert delegation->type field to fmode_t
      NFSv4: Clean up is_atomic_open()
      NFSv4: Ensure that we set the verifier when revalidating delegated =
dentries
      NFS: Use delegations to optimise ACCESS calls
      NFSv4: Convert the open and close ops to use fmode
      NFSv4: Fix an infinite loop in the NFS state recovery code
      Merge branch 'devel' into next
      SUNRPC: Ensure the server closes sockets in a timely fashion
      SUNRPC: The sunrpc server code should not be used by out-of-tree mo=
dules

Troy Kisky (11):
      ASoC: Allow setting codec register with debugfs filesystem
      ALSA: SOC: Fix setting codec register with debugfs filesystem merge=
 error
      ASoC: TLV320AIC23B Support more sample rates
      ALSA: ASoC: DaVinci: davinvi-evm, make requests explicit
      ALSA: ASoC: DaVinci: davinci-i2s add comments to explain polarity
      ALSA: ASoC: DaVinci: davinci-i2s clean up
      ALSA: ASoC: DaVinci: davinci-i2s clean up
      ALSA: ASoC: DaVinci: document I2S limitations
      ALSA: ASoC: tlv320aic3x add dsp_a
      ALSA: ASoC: DaVinci: i2s, evm, pass same value to codec and cpu_dai
      ALSA: ASoc: DaVinci: davinci-evm use dsp_b mode

T=C3=B6r=C3=B6k Edwin (10):
      tracing: add support for userspace stacktraces in tracing/iter_ctrl
      vfs, seqfile: make mangle_path() global
      tracing: identify which executable object the userspace address bel=
ongs to
      tracing/stack-tracer: fix style issues
      tracing/stack-tracer: fix locking and refcounts
      tracing/stack-tracer: introduce CONFIG_USER_STACKTRACE_SUPPORT
      tracing/stack-tracer: avoid races accessing file
      vfs, seqfile: fix comment style on mangle_path
      mutex: __used is needed for function referenced only from inline as=
m
      tracing, alpha: fix build: add missing #ifdef CONFIG_STACKTRACE

Udo Steinberg (1):
      V4L/DVB (10173): Missing v4l2_prio_close in radio_release

Ulrich Dangel (2):
      ALSA: hda - add basic jack reporting functions to patch_conexant.c
      ALSA: hda - cxt5051 report jack state

Uri Shkolnik (1):
      V4L/DVB (9740): sms1xxx: add USB suspend and hibernation support

Uros Bizjak (1):
      x86: Implement change_bit with immediate operand as "lock xorb"

Ursula Braun (4):
      [S390] convert iucv printks to dev_xxx and pr_xxx macros.
      qeth: exploit source MAC address for inbound layer3 packets
      qeth: avoid crash in case of layer mismatch for VSWITCH
      af_iucv: avoid left over IUCV connections from failing connects

Uwe Bugla (1):
      V4L/DVB (9888): Patch: fix a typo in cx24113.c

Uwe Kleine-Koenig (1):
      Merge branch 'for-rmk-misc' into for-rmk

Uwe Kleine-K=C3=B6nig (10):
      mach-netx/time.c: codingstyle cleanup
      netx: Use a cpp symbol for the clocksource timer number
      netx: enable GENERIC_TIME
      netx: add support for clockevents
      netx/xc: add a few "const"s to fix compiler warnings
      netx: define register MEMCR
      small doc fix: ftrace_dyn_arch_init is called by ftrace_init
      Fix configure warnings in defconfigs for netX and Picotux 200
      remove a superfluous kconfig type definition
      at91: warn if irqs are enabled in set_next_event

Vaibhav Hiremath (2):
      V4L/DVB (9816): v4l2-int-if: add three new ioctls for std handling =
and routing
      V4L/DVB (9817): v4l: add new tvp514x I2C video decoder driver

Vaidyanathan Srinivasan (8):
      sched: idle_balance() does not call load_balance_newidle()
      sched: convert BALANCE_FOR_xx_POWER to inline functions
      sched: favour lower logical cpu number for sched_mc balance
      sched: nominate preferred wakeup cpu
      sched: bias task wakeups to preferred semi-idle packages
      sched: activate active load balancing in new idle cpus
      sched: add SD_BALANCE_NEWIDLE at MC and CPU level for sched_mc>0
      sched: nominate preferred wakeup cpu, fix

Valentin Longchamp (4):
      MX31: definitions for UART2 pins
      MX31: UART5 pins definition
      [ARM] MX31: basic support for mx31moboard platform
      [ARM] MX31: defconfig for mx31moboard platform

Vasanthakumar Thiagarajan (5):
      ath9k: Configure AR_PHY_SWITCH_COM with apropriate antenna control
      ath9k: Fix panic while unregistering rfkill
      ath9k: Dont update rate control for every AMPDU
      ath9k: Synchronize DMA transfer with CPU at right place
      ath9k: Move rate control alg register/unregister to appropriate pla=
ce

Vedran Miletic (3):
      ALSA: emu10k1: fix device names for Live!/Audigy1/2/4/E-mu
      ALSA: emu10k1: fix faulty commit 18c71092
      ALSA: emu10k1: fix coding style for emu10k1_main.c

Vegard Nossum (6):
      sched: update comment for move_task_off_dead_cpu
      Bluetooth: Fix leak of uninitialized data to userspace
      kbuild: add headerdep used to detect inclusion cycles in header fil=
es
      x86: revert CONFIG_RELOCATABLE=3Dy defconfig change
      netlink: fix (theoretical) overrun in message iteration
      drm: fix leak of uninitialized data to userspace

Venki Pallipadi (1):
      x86: support always running TSC on Intel CPUs

Vernon Sauder (1):
      pxamci: fix dma_unmap_sg length

Vijay Kumar (8):
      Staging: poch: Block size bug fix
      Staging: poch: Update TODO list
      Staging: poch: Correct pages from bytes.
      Staging: poch: minor fixes
      Staging: poch: Fix build warnings
      Staging: poch: Rx control register init
      Staging: poch: Fix user space protocol syncing
      Staging: poch: Fine grained locking

Vikram Pandita (1):
      USB: Avoid 20ms delay in EHCI resume

Viktor Rosendahl (1):
      oops handling: ensure that any oops is flushed to the mtdoops conso=
le

Vincent Pelletier (1):
      V4L/DVB (9536): WinFast DTV2000 H: add support for missing analog i=
nputs

Vincent Petry (2):
      ALSA: hda: Added Realtek ALC888 model entry for Acer Aspire 4930G l=
aptop
      ALSA: hda: Added an ALC888 model entry for Fujitsu-Siemens Amilo Xa=
3530

Vishnu Suresh (1):
      crypto: talitos - Preempt overflow interrupts off-by-one fix

Vitaly Bordug (1):
      USB: powerpc: Workaround for the PPC440EPX USBH_23 errata [take 3]

Vivek Natarajan (1):
      mac80211: Look out for some other AP when disassoc is received.

Vladislav Bolkhovitin (1):
      [SCSI] scsi_error: TASK ABORTED status handling improvement

Volker Lendecke (8):
      [CIFS] In SendReceive, move consistency check out of the mutexed re=
gion
      Simplify allocate_mid() slightly: Remove some unnecessary "else" br=
anches
      [CIFS] Slightly simplify wait_for_free_request(), remove an unneces=
sary "else" branch
      Check the return value of cifs_sign_smb[2]
      Slightly streamline SendReceive[2]
      Streamline SendReceiveBlockingLock: Use "goto out:" in an error con=
dition
      Streamline SendReceiveBlockingLock: Use "goto out:" in an error con=
dition
      Remove an already-checked error condition in SendReceiveBlockingLoc=
k

WANG Cong (4):
      fs/nfs/nfs4proc.c: make nfs4_map_errors() static
      proc: remove write-only variable in proc_pident_lookup()
      fs/exec.c: make do_coredump() void
      ipc: clean up ipc/shm.c

Wang Chen (37):
      airo: Kill directly reference of netdev->priv
      netdevice libertas: Fix directly reference of netdev->priv
      netdevice: safe convert to netdev_priv() #part-1
      netdevice: safe convert to netdev_priv() #part-2
      netdevice: safe convert to netdev_priv() #part-3
      netdevice: safe convert to netdev_priv() #part-4
      netdevice chelsio: Convert directly reference of netdev->priv
      netdevice: 82596: Convert netdev->priv to netdev_priv
      netdevice hamradio: Convert directly reference of netdev->priv
      netdevice lance: Convert directly reference of netdev->priv
      netdevice ppp: Convert directly reference of netdev->priv
      netdevice ni65: Convert directly reference of netdev->priv
      netdevice wanrouter: Convert directly reference of netdev->priv
      ixgbe: convert directly reference of netdev->priv
      netdevice hdlc: Convert directly reference of netdev->priv
      netdevice pc300: Convert directly reference of netdev->priv
      netdevice pc300: Add the reason about PC300 BROKEN in Kconfig
      netdevice sbni: Convert directly reference of netdev->priv
      infiniband: Kill directly reference of netdev->priv
      hysdn: Kill directly reference of netdev->priv
      isdn: Kill directly reference of netdev->priv
      dvb: Kill directly reference of netdev->priv
      mptlan: Kill directly reference of netdev->priv
      bond: Kill directly reference of netdev->priv
      ixgbe: function comment typo
      e1000: e1000_adapter->polling_netdev is useless
      if_usb: Kill directly reference of netdev->priv
      simeth: Kill directly reference of netdev->priv
      xtensa: Kill directly reference of netdev->priv
      um: Kill directly reference of netdev->priv
      sgi-xp: Kill directly reference of netdev->priv
      s390_net: Kill directly reference of netdev->priv
      staging-p80211: Kill directly reference of netdev->priv
      staging-slicoss: Kill directly reference of netdev->priv
      staging-winbond: Kill directly reference of netdev->priv
      netdevice: Kill netdev->priv
      netdevice zd1201: Use after free

Wei Yongjun (6):
      xfrm: Cleanup for unlink SPD entry
      sctp: Bring SCTP_MAXSEG socket option into ietf API extension compl=
iance
      sctp: Fix a typo in socket.c
      sctp: Implement socket option SCTP_GET_ASSOC_NUMBER
      sctp: Avoid memory overflow while FWD-TSN chunk is received with ba=
d stream ID
      sctp: Add validity check for SCTP_PARTIAL_DELIVERY_POINT socket opt=
ion

Weidong Han (17):
      Initialize domain flags to 0
      change P2P domain flags
      Add global iommu list
      Get iommu from g_iommus for deferred flush
      iommu bitmap instead of iommu pointer in dmar_domain
      calculate agaw for each iommu
      iommu coherency
      Add domain flag DOMAIN_FLAG_VIRTUAL_MACHINE
      Add/remove domain device info for virtual machine domain
      Add domain_flush_cache
      Allocation and free functions of virtual machine domain
      Change domain_context_mapping_one for virtual machine domain
      Change intel iommu APIs of virtual machine domain
      Check agaw is sufficient for mapped memory
      KVM: use the new intel iommu APIs
      KVM: support device deassignment
      Deassign device in kvm_free_assgined_device

Werner Almesberger (1):
      remove bashisms from scripts/extract-ikconfig

Will Newton (1):
      init/main.c: use ktime accessor function in initcall_debug code

Willy Tarreau (4):
      Staging: add lcd-panel driver
      Staging: panel: major checkpatch cleanup
      Staging: panel: remove ifdefs and code for pre-2.6 kernels
      Staging: panel: remove support for smartcards

Wim Van Sebroeck (4):
      nvram - CodingStyle
      nvram - convert PRINT_PROC to seq_file
      [WATCHDOG] ib700wdt - add timeout parameter
      [WATCHDOG] Add SMSC SCH311x Watchdog Timer.

Winkler, Tomas (21):
      iwlwifi: reorganize flow handler bitology
      iwlwifi: trivial removal of some 4965 remaining from iwl-agn-rs.h
      iwlwifi: iwl-agn-rs: initialize rs with valid antenna
      iwlwifi: trivial fix in includes
      iwlwifi: don't fail power set when calibration is not done yet
      iwlwifi: move rx queue read pointer into rxq
      iwlwifi: move iwl_print_hex_dump to iwl-debug.h
      iwlwifi: get some more information about command failure
      iwlwifi: move iwl_clear_stations_table to iwl-sta.c
      iwlwifi: 4965 define firmware file name once
      iwlwifi: TX setup fix confusion between TX queue and TX DMA channel
      iwlwifi: TX update chicken bits
      iwlwifi: 5150 enable LO, TXIQ and BB calibrations
      iwlwifi: move host command check function into separate file
      iwlwifi: move disable/enable interrupts to iwl-core.c
      iwlwifi: move channels sysfs to debugfs
      iwlwifi: change email contact information
      iwlifi: remove twice defined SINGLE_FRAME RX FH MASK
      iwlwifi: 3945 remove qos module parameter
      iwlwifi: remove qos module parameter
      iwlwifi: cleanup iwl-dev.h

Wolfgang Grandegger (1):
      [MTD] CFI: remove major/minor version check for command set 0x0002

Wolfram Sang (6):
      powerpc/mpc5200: Remove obsolete code from mpc5200 MDIO driver
      powerpc/mpc5200: add rts/cts handling in PSC UART driver
      powerpc/mpc5200: fix error paths in PSC UART probe function
      checkpatch: Add warning for p0-patches
      kbuild: fix typos (s/bin_shipped/bin.o_shipped/) in Documentation
      leds: Make header variable naming consistent

Woodruff, Richard (1):
      nohz: suppress needless timer reprogramming

Wu Fengguang (50):
      ext4: fix build warning
      ALSA: handle SiI1392 HDMI codec in patch_intelhdmi.c
      ALSA: hda: alc883 model for ASUS P5Q-EM boards
      ALSA: hda-intel: reorder HDMI audio enabling sequence
      ALSA: hda: remove redundant get_amp_nid()
      ALSA: introduce snd_print_pcm_rates()
      ALSA: create hda_eld.c for ELD routines and proc interface
      ALSA: ELD proc interface for HDMI sinks
      ALSA: hda: make standalone hdmi_fill_audio_infoframe()
      ALSA: hda: make global snd_print_channel_allocation()
      ALSA: hda: HDMI channel allocations for audio infoframe
      ALSA: hda: HDMI channel mapping cleanups
      ALSA: hda: minor code cleanups
      ALSA: hda: rename sink_eld to hdmi_eld
      ALSA: hda: minor output message cleanups
      ALSA: hda: make global snd_print_pcm_bits()
      ALSA: hda: compact ELD output messages
      ALSA: azx_probe() cleanup
      ALSA: hda - properly print ELD sample bits
      ALSA: hda: modify monitor name to be consistent with other ELD proc=
 items
      ALSA: hda - support writing to the ELD proc file
      ALSA: hda - minor HDMI code cleanups
      ALSA: hda - report selected CA index for Audio InfoFrame
      ALSA: hda - make HDMI messages more user friendly
      ALSA: hda - ELD proc interface write updates
      ALSA: hda - document the ELD proc interface
      ALSA: hda - fix DisplayPort naming
      ALSA: hda - fix build warning when CONFIG_PROC_FS=3Dn
      markers: comment marker_synchronize_unregister() on data dependency
      generic swap(): ath9k: rename swap() to swap_array()
      iwlwifi: remove useless goto
      nfs: remove redundant tests on reading new pages
      block: don't take lock on changing ra_pages
      KVM: Prevent trace call into unloaded module text
      ALSA: hda - fix name for ALC1200
      trivial: radix-tree: document wrap-around issue of radix_tree_next_=
hole()
      dynamic_printk: reduce one level of indentation
      dm9601: handle corrupt mac address
      dm9601: bring datasheet URL up to date
      USB: make printk messages more searchable
      generic swap(): sparc: rename swap() to swap_ulong()
      generic swap(): iphase: rename swap() to swap_byte_order()
      generic swap(): lib/sort.c: rename swap to swap_func
      generic swap(): introduce global macro swap(a, b)
      generic swap(): ext3: remove local swap() macro
      generic swap(): ext4: remove local swap() macro
      generic swap(): sched: remove local swap() macro
      generic swap(): dcache: use swap() instead of private do_switch()
      dm9601: tell HW about random generated mac address
      dm9601: warn on invalid mac address

Wu, Fengguang (5):
      ALSA: hda - Intel HDMI audio support
      iwlwifi: add line feed to printk
      iwlwifi: update comments on the debug interface
      iwlwifi: use type uint for module param debug
      iwlwifi: use meaningful vars in _iwl_poll_bit()

Wyatt Banks (1):
      Btrfs: Return value checking in module init

Xiantao Zhang (8):
      KVM: ia64: Re-organize data sturure of guests' data area
      KVM: ia64: Remove lock held by halted vcpu
      KVM: ia64: Remove some macro definitions in asm-offsets.c.
      KVM: ia64: Define printk function for kvm-intel module
      KVM: ia64: Add some debug points to provide crash infomation
      KVM: ia64: Add handler for crashed vmm
      KVM: ia64: Clean up vmm_ivt.S using tab to indent every line
      MAINTAINERS: Maintainership changes for kvm/ia64

Xiaochuan-Xu (2):
      UBI: prepare for protection tree improvements
      UBI: simplify PEB protection code

Yan (53):
      fix block readahead in btrfs_next_leaf
      Btrfs: ctree.c cleanups
      Btrfs: Fix mknod to properly send rdev info back to disk
      Btrfs: Add mount into directory support
      Btrfs: Fix oopsen in extent_tree.c during enospc
      Btrfs: Fix off by one error in dirty_and_release_pages
      Btrfs: Fix cache_block_group to catch holes at the start of the gro=
up
      fix found_type decrement in btrfs_truncate_in_trans
      create btrfs_path slab with the correct size
      Btrfs: truncate: don't update inode->i_blocks when extent is a hole
      Btrfs: Fix double free and off by one in inode.c
      Btrfs: Off by one fixes in extent_map.c
      Btrfs: Fix for insert_inline_extent to handle offset !=3D 0
      btrfs_inode_by_name return random value.
      Fix ENOTEMPTY check in btrfs_rmdir
      Btrfs: Fix extent_map leak in extent_bmap
      Fix inline extent handling in btrfs_get_extent
      Minor fix for btrfs_csum_file_block.
      Btrfs: Fix typo and memory leak in extent-tree.c
      Btrfs: small fixes for find_lock_delalloc_range.
      Btrfs: Properly update free space cache in __free_extent
      Btrfs: Fix u32 overflow in dirty_and_release_pages.
      Fix EXTENT_MAP_INLINE off by one in btrfs_drop_extents
      Properly delete csum item in btrfs_truncate_in_trans.
      Btrfs: Add block group pinned accounting back
      Btrfs: Add full_scan parameter to find_search_start
      Btrfs: Off by one fixes for extent-tree.c
      Btrfs: Properly update right_nritems in push_leaf_left
      Btrfs: Fix buffer get/release issue in create_snapshot
      Off by one fix for btrfs_drop_extents
      Btrfs: Add a helper that finds previous extent item
      Btrfs: Properly handle overlapping extent in shrink_extent_tree
      Btrfs: Add inode flags support
      Btrfs: Implement ACLs setting and getting
      Btrfs: Add readonly inode flag
      Btrfs: Fix compile on kernel without ACLs enabled
      Btrfs: Fix compile on 2.6.22 kernel
      Fix for btrfs_find_free_objectid
      Btrfs: Fix for test_range_bit
      Btrfs: Add basic lockfs calls
      Btrfs: Align extent length to sectorsize in
      btrfs_drop_extent fixe for inline items > 8K
      Call btrfs_cow_block while lowering tree level.
      Btrfs: Fix typo in extent_io.c
      Btrfs: Fix hole creation in file_write
      btrfs_drop_extents: handle BTRFS_INODE_REF_KEY types
      Btrfs: Fix "no csum found for inode" issue.
      Fix btrfs_fill_super to return -EINVAL when no FS found
      Btrfs: Dislable acl xattr handlers
      Btrfs: Properly release lock in pin_down_bytes
      Btrfs: Fix .. lookup corner case
      Fix path slots selection in btrfs_search_forward
      Btrfs: implement memory reclaim for leaf reference cache

Yan Zheng (37):
      Btrfs: Properly setup root key while reading the root
      Btrfs: Fix looping on readdir of the subvol roots
      Btrfs: Add a leaf reference cache
      Btrfs: Update and fix mount -o nodatacow
      Btrfs: Various small fixes.
      Btrfs: Update clone file ioctl
      Btrfs: Fix nodatacow for the new data=3Dordered mode
      Btrfs: Count space allocated to file in bytes
      Btrfs: Remove offset field from struct btrfs_extent_ref
      Btrfs: Fix leaf reference cache miss
      Btrfs: Improve space balancing code
      Btrfs: Add root tree pointer transaction ids
      Btrfs: update hole handling v2
      Btrfs: Fix bookend extent race v2
      Btrfs: update nodatacow code v2
      Btrfs: Add fallocate support v2
      Btrfs: Fix csum error for compressed data
      Btrfs: Fix starting search offset inside btrfs_drop_extents
      Btrfs: mount ro and remount support
      Btrfs: Seed device support
      Btrfs: Fix race in btrfs_mark_extent_written
      Btrfs: Drop dirty roots created by log replay immediately when
      Btrfs: superblock duplication
      Btrfs: Add checking of csum tree in balancing code
      Btrfs: fix leaking block group on balance
      Btrfs: shared seed device
      Btrfs: fix nodatasum handling in balancing code
      Btrfs: properly check free space for tree balancing
      Btrfs: Add missing mnt_drop_write in ioctl.c
      Btrfs: properly update block accounting for metadata
      Btrfs: set EXTENT_BOUNDARY bit before marking extent delalloc.
      Btrfs: update directory's size when creating subvol/snapshot
      Btrfs: avoid potential super block corruption
      Btrfs: avoid orphan inode caused by log replay
      Btrfs: Use btrfs_join_transaction to avoid deadlocks during snapsho=
t creation
      Btrfs: don't change file extent's ram_bytes in btrfs_drop_extents
      Btrfs: tree logging checksum fixes

Yang Hongyang (3):
      ipv6: Add IPV6_PKTINFO sticky option support to setsockopt()
      ipv6: fix the return interface index when get it while no message i=
s received
      ipv6: fix the outgoing interface selection order in udpv6_sendmsg()

Yang, Libin (1):
      ALSA: hda - support detecting HD Audio devices with PCI class code

Yasunori Goto (1):
      ext4: Widen type of ext4_sb_info.s_mb_maxs[]

Yehuda Sadeh Weinraub (2):
      Btrfs: fix return value from btrfs_listxattr when buffer size is to=
o small
      Btrfs: fix return value from btrfs_listxattr when buffer size is to=
o small

Yevgeny Petrilin (11):
      mlx4_core: Add support for multiple completion event vectors
      mlx4_en: Memory leak on completion queue free
      mlx4_en: Removed TX locking when polling TX cq
      mlx4_en: Removed redundant cq->armed flag
      mlx4_en: Removed Interrupt moderation module parameters
      mlx4_en: Remove pauses module parameters.
      mlx4_en: Verify number of RX rings doesn't exceed MAX_RX_RINGS
      mlx4_en: Always allocate RX ring for each interrupt vector
      mlx4_en: Added "set_ringparam" Ethtool interface implementation
      mlx4_en: Consider inline packets on completion
      mlx4_en: Returning real Max in get_ringparam

Yi Li (4):
      Blackfin arch: workaround bug: spi_mmc driver working in dma mode m=
ay hang the system
      Blackfin arch: add mmc_spi support to BF537-STAMP
      Blackfin arch: Retire old spi_mmc driver
      Blackfin arch:  merge adeos blackfin part to arch/blackfin/

Ying Han (1):
      mm: make get_user_pages() interruptible

Yinghai Lu (25):
      x86: break up mtrr_cleanup() into several small functions.
      x86: fix wakeup_cpu with numaq/es7000, v2
      x86: fix wakeup_cpu with numaq/es7000, v2, fix
      x86: use update_genapic to get rid of ES7000_CLUSTERED_APIC v2
      x86: fix wakeup_cpu with numaq/es7000 v2 - call ->update_genapic()
      sparse irq_desc[] array: core kernel and x86 changes
      x86: use NR_IRQS_LEGACY
      x86: MSI start irq numbering from nr_irqs_gsi
      x86, MSI: pass irq_cfg and irq_desc
      x86: clean up get_smp_config()
      sparseirq: fix Alpha build failure
      sparseirq: fix !SMP && !PCI_MSI && !HT_IRQ build
      x86, sparseirq: move irq_desc according to smp_affinity, v7
      sparseirq: fix !SMP building, #2
      sparseirq: add kernel-doc notation for new member in irq_desc, -v2
      sparseirq: fix numa_migrate_irq_desc dependency and comments
      x86: fix lguest used_vectors breakage, -v2
      sparseirq: remove duplicated arch_early_irq_init()
      sparseirq: work around compiler optimizing away __weak functions
      sparseirq: set lock_class for legacy irq when sparse_irq is selecte=
d
      sparseirq: fix hang with !SPARSE_IRQ
      sparseirq: move __weak symbols into separate compilation unit
      sparseirq: move set/get_timer_rand_state back to .c
      x86: k8 numa register active regions later
      mm: print out memmap number only if it is not zero

Yoichi Yuasa (1):
      leds: fix Cobalt Raq LED dependency

Yong Yao (2):
      Input: add support for trackball on pxa930 and pxa935
      Input: add support for enhanced rotary controller on pxa930 and pxa=
935

Yoshihiro Shimoda (1):
      sh: pci-sh7780: fix pci memory address mask

Yu Zhao (10):
      VT-d: fix segment number being ignored when searching DRHD
      PCI: enhance pci_ari_enabled()
      PCI: remove unnecessary arg of pci_update_resource()
      PCI: define PCI resource names in an 'enum'
      PCI: remove unnecessary condition check in pci_restore_bars()
      PCI: export __pci_read_base()
      PCI: allow pci_alloc_child_bus() to handle a NULL bridge
      PCI: add a new function to map BAR offsets
      PCI: cleanup pci_bus_add_devices()
      PCI: factor pci_bus_add_child() from pci_bus_add_devices()

Zach Brown (1):
      Btrfs: trivial include fixups

Zachary Amsden (1):
      x86: clean up dead code in vmi_32.c

Zhang Rui (4):
      ACPI: video: Fix reversed brightness behavior on ThinkPad SL series
      Hibernate: Call platform_begin before swsusp_shrink_memory
      video: always update the brightness when poking "brightness"
      bd->props.brightness doesn't reflect the actual backlight level.

Zhao Yakui (2):
      ACPI: Avoid array address overflow when _CST MWAIT hint bits are se=
t
      ACPI : Use RSDT instead of XSDT by adding boot option of "acpi=3Drs=
dt"

Zhaolei (6):
      markers: break the redundant loop in kernel/marker.c
      x86: avoid duplicate running of pud_offset and pmd_offset in one_md=
_table_init()
      Fix debugfs_create_bool's error checking method for wireless/iwlwif=
i/
      Fix debugfs_create_*'s error checking method for wireless/rt2x00/
      correct wrong function name of d_put in kernel document and source =
comment
      fork.c: cleanup for copy_sighand()

Zheng Yan (7):
      Btrfs: Update find free objectid function for orphan cleanup code
      Btrfs: properly set blocksize when adding new device.
      Btrfs: Full back reference support
      Btrfs: allocator fixes for space balancing update
      Btrfs: Add shared reference cache
      Btrfs: extent_map and data=3Dordered fixes for space balancing
      Btrfs: update space balancing code

ZhenwenXu (1):
      mm/mmap.c: fix coding style

Zhenyu Wang (1):
      agp/intel: add support for G41 chipset

Zhu Yi (4):
      mac80211: print reason code for deauth/dissoc frames
      iwlwifi: fix printk size format error
      iwlwifi: fix DMA channel number in iwl_txq_ctx_stop
      iwlwifi: use GFP_KERNEL to allocate Rx SKB memory

Zhu, Yi (9):
      iwlwifi: fix priv->iw_mode setting when multiple vif are configured
      iwlwifi: use Rx single frame mode (one Rx frame per RB)
      iwlwifi: configure_filter rewrite
      iwlwifi: some fh document fix and cleanup
      iwlwifi: fix time interval misuse in iwl_poll_{direct_}bit
      iwlwifi: fix "MAC in deep sleep" error
      iwlwifi: iwl_poll_{direct_}bit cleanup
      iwlwifi: use rmb/wmb to protect indirect mmio operation
      iwlwifi: use iwl_poll_direct_bit in EEPROM reading

Zoltan Devai (1):
      Input: pcspkr - fix PIT lockup on some chipsets

\"J. Bruce Fields\ (9):
      rpc: remove unnecessary assignment
      rpc: factor out warning code from gss_pipe_destroy_msg
      rpc: minor gss_alloc_msg cleanup
      rpc: add an rpc_pipe_open method
      rpc: call release_pipe only on last close
      rpc: track number of users of the gss upcall pipe
      rpc: use count of pipe openers to wait for first open
      rpc: store pointer to pipe inode in gss upcall message
      rpc: implement new upcall

akeemting (1):
      jme: GHC register control fix for new hardware

akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org (1):
      ipc/ipc_sysctl.c: move the definition of ipc_auto_callback()

colin-W/OLz77bvjtBDgjK7y7TUQ@public.gmane.org (1):
      Add nl80211 commands to get and set o11s mesh networking parameters

gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org (1):
      x86: entry_64.S - use X86_EFLAGS_IF instead of hardcoded number

herton (1):
      rtl8187: fix retry count passed in rtl8187_tx

jia zhang (2):
      x86_64: fix the check in stack_overflow_check
      x86, debug: remove the confusing entry in call trace

malahal-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org (1):
      block: optimizations in blk_rq_timed_out_timer()

philipl-tB29R6EoPa3YtjvyW6yDsg@public.gmane.org (1):
      ricoh_mmc: Handle newer models of Ricoh controllers

robert.moore-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org (2):
      ACPICA: FADT: set acpi_gbl_use_default_register_widths to TRUE by d=
efault
      ACPICA: Update version to 20081204.

roel kluin (10):
      slab: unsigned slabp->inuse cannot be less than 0
      powerpc/macintosh: Fix unsigned check in smu_sat_get_sdb_partition(=
)
      powerpc: Make open count variables signed in hvcs/hvsi/hvc_console
      [SCSI] u14-34f: fix scsi_dma_map failure case
      V4L/DVB (10064): mt9m111: mt9m111_get_global_gain() - unsigned >=3D=
 0 is always true
      V4L/DVB (10148): cx23885: unsigned cx23417_mailbox cannot be negati=
ve
      gbefb: unsigned var->pixclock cannot be less than 0
      sm501: unsigned ptr cannot be negative
      USB: clean up redundant tests on unsigned
      romfs: romfs_iget() - unsigned ino >=3D 0 is always true

sandeen-+82itfer+wXR7s880joybQ@public.gmane.org (12):
      [XFS] Move copy_from_user calls out of ioctl helpers into ioctl swi=
tch.
      [XFS] Move compat ioctl structs & numbers into xfs_ioctl32.h
      [XFS] Clean up some existing compat ioctl calls
      [XFS] Add compat handlers for swapext ioctl
      [XFS] Add compat handlers for data & rt growfs ioctls
      [XFS] Make the bulkstat_one compat ioctl handling more sane
      [XFS] Fix xfs_bulkstat_one size checks & error handling
      [XFS] Fix compat XFS_IOC_FSBULKSTAT_SINGLE ioctl
      [XFS] Hook up compat XFS_IOC_ATTRLIST_BY_HANDLE ioctl handler
      [XFS] Hook up compat XFS_IOC_ATTRMULTI_BY_HANDLE ioctl handler
      [XFS] Hook up compat XFS_IOC_FSSETDM_BY_HANDLE ioctl handler
      [XFS] Reorder xfs_ioctl32.c for some tidiness

venkatesh.pallipadi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org (12):
      x86: PAT: store vm_pgoff for all linear_over_vma_region mappings - =
v3
      x86: PAT: add follow_pfnmp_pte routine to help tracking pfnmap page=
s - v3
      x86: PAT: hooks in generic vm code to help archs to track pfnmap re=
gions - v3
      x86: PAT: implement track/untrack of pfnmap regions for x86 - v3
      x86: PAT: change pgprot_noncached to uc_minus instead of strong uc =
- v3
      x86: PAT: add pgprot_writecombine() interface for drivers - v3
      x86: PAT: update documentation to cover pgprot and remap_pfn relate=
d changes - v3
      x86: PAT: clarify is_linear_pfn_mapping() interface
      x86: PAT: modify follow_phys to return phys_addr prot and return va=
lue
      x86: PAT: remove follow_pfnmap_pte in favor of follow_phys
      x86: PAT: move track untrack pfnmap stubs to asm-generic
      x86: PAT: pfnmap documentation update changes

walimis (2):
      ftrace: remove unnecessary if condition of __unregister_ftrace_func=
tion
      ftrace: improve documentation

wanzongshun (2):
      [ARM] 5338/1: Add Nuvoton W90P910 Platform support
      [ARM] 5352/1: add w90p910-plat config file

yanhai zhu (3):
      Btrfs: Check kthread_should_stop() before schedule() in worker_loop
      Btrfs: Add a missing return pointer check
      Btrfs: Fix memset length in btrfs_file_write

=C3=89ric Piel (1):
      sdhci: activate led support also when module

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr

--===============2751593004607479287==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============2751593004607479287==--
