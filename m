From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr annotated tag, v2.6.29-rc2, created. v2.6.29-rc2
Date: Wed, 16 Sep 2009 14:36:40 -0400
Message-ID: <200909161836.n8GIaeFV001218@gorgona.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8960442938097663893=="
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

--===============8960442938097663893==
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by smtp1.linux-foundation.org id n8GJT2Yf009182

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The annotated tag, v2.6.29-rc2 has been created
        at  d31ce8060b0e875179ba5ca1d40475dc2a082cc7 (tag)
   tagging  1de9e8e70f5acc441550ca75433563d91b269bbe (commit)
  replaces  v2.6.29-rc1
 tagged by  Linus Torvalds
        on  Fri Jan 16 12:43:19 2009 -0800

- Log -----------------------------------------------------------------
Linux 2.6.29-rc2
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAklw8WsACgkQF3YsRnbiHLv+dQCgp9ZwHWunWAORwYyyKg3JPFzg
uikAoKdTk3voaFNP6AKpMLdq5MyKopaS
=3D+hyI
-----END PGP SIGNATURE-----

Al Viro (1):
      m68k: Fix --build-id breakage for sun3

Alan Cox (6):
      pty: Fix documentation
      neo: Remove a bogus NULL check
      usb-serial: remove NULL check
      pata_it821x: Update RDC UDMA handling
      tty: Fix race in the flush for some ldiscs
      tty: Fix a kref leak in the HSO driver on re-open

Alessandro Zummo (1):
      rtc: tw4030 add alarm/update interfaces

Alex Murray (1):
      hwmon: applesmc: fix light sensor readings on newer MacBooks

Alexander Beregalov (1):
      irda: fix incomplete conversation to internal stats

Alexey Starikovskiy (2):
      ACPI: EC: Limit workaround for ASUS notebooks even more
      ACPI: EC: Don't trust ECDT tables from ASUS

Alistair John Strachan (3):
      hwmon: (abituguru3) Match partial DMI board name strings
      hwmon: (abituguru3) Enable DMI probing feature on IN9 32X MAX
      hwmon: (abituguru3) Fix CONFIG_DMI=3Dn fallback to probe

Andi Kleen (1):
      x86: avoid theoretical vmalloc fault loop

Andreas Bombe (1):
      m68k: amiflop - Get rid of sleep_on calls

Andreas Herrmann (3):
      hwmon: (k8temp) Warn about fam F rev F errata
      hwmon: (k8temp) Fix wrong sensor selection for AMD K8 RevF/RevG CPU=
s
      hwmon: (k8temp) Fix temperature reporting for (most) K8 RevG CPUs

Andreas Schwab (1):
      m68k: Wire up sys_restart_syscall

Andrew Morton (5):
      smp_call_function_single(): be slightly less stupid
      kernel/up.c: omit it if SMP=3Dy, USE_GENERIC_SMP_HELPERS=3Dn
      revert "mm: vmalloc use mutex for purge"
      lib/idr.c: use kmem_cache_zalloc() for the idr_layer cache
      drivers/ata/pata_ali.c: s/isa_bridge/ali_isa_bridge/ to fix alpha b=
uild

Andrew Price (1):
      rt2x00: Fix radio LED type check

Andrey Yurovsky (1):
      libertas_tf: return NETDEV_TX_OK in TX op

Andy Whitcroft (9):
      sysrq documentation: remove the redundant updated date
      sysrq documentation: document why the command header only is shown
      sysrq: add commentary on why we use the console loglevel over using=
 KERN_EMERG
      checkpatch: handle missing #if open in context
      checkpatch: type/cast spacing should not check prefix spacing
      checkpatch: allow parentheses on return handle array values
      checkpatch: if should not continue a preceeding brace
      checkpatch: struct seq_operations should normally be const
      checkpatch: version: 0.27

Anirban Chakraborty (1):
      [SCSI] qla2xxx: Fix ISP restart bug in multiq code

Anirban Sinha (1):
      MIPS: 64-bit: Use generic 32-bit ptrace compat code.

Anton Vorontsov (4):
      gianfar: Fix soft lockup with multi-interrupt TSECs
      powerpc/83xx: Make serial ports work on MPC8315E-RDB w/ FSL U-Boots
      powerpc/83xx: Move mcu_mpc8349emitx driver out of drivers/i2c/chips=
/
      phylib: Fix Freescale TBI PHY detection

Antonio Ospite (1):
      rtc-pxa: fix build failure

Arjan van de Ven (2):
      script: improve markup_oops.pl to also decode oopses in modules
      async: fix __lowest_in_progress()

Atsushi Nemoto (1):
      tx4938ide: Fix build error due to read_sff_dma_status moving

Ayaz Abdulla (4):
      forcedeth: xmit lock fix
      forcedeth: version bump and copyright
      forcedeth: remove mgmt unit for mcp79 chipset
      forcedeth: napi schedule lock fix

Balaji Rao (7):
      mfd: PCF50633 core driver
      mfd: PCF50633 adc driver
      mfd: PCF50633 gpio support
      rtc: PCF50633 rtc driver
      power_supply: PCF50633 battery charger driver
      input: PCF50633 input driver
      regulator: PCF50633 pmic driver

Bartlomiej Zolnierkiewicz (6):
      ide: fix accidental LOCKDEP breakage caused by local_irq_set() remo=
val
      ide: can't use SSD/non-rotational queue flag for all CFA devices
      via82cxxx: fix cable warning message
      sl82c105: remove dead code
      ide: remove unused CONFIG_BLK_DEV_IDE_AU1XXX_SEQTS_PER_RQ
      ide: fix suspend regression

Ben Dooks (3):
      mfd: Ensure sm501 GPIO pin mode is GPIO when configured
      IDE: fix sparse signed-ness errors with host->host_busy
      gpio: fix probe() error return in gpio driver probes

Ben Hutchings (1):
      sfc: SFT9001: Fix condition for LNPGA power-off

Benjamin Herrenschmidt (6):
      powerpc: Fix cpufreq drivers after cpufreq core changes
      Merge commit 'kumar/kumar-next' into next
      Merge commit 'gcl/gcl-next' into next
      powerpc/powermac: Fix occasional SMP boot failure
      [CVE-2009-0029] powerpc: Enable syscall wrappers for 64-bit
      net: Add init_dummy_netdev() and fix EMAC driver using it

Bernd Schmidt (1):
      Fix timeouts in sys_pselect7

Bob Copeland (1):
      ath5k: fix return values from ath5k_tx

Brandon Philips (2):
      it821x: Add ultra_mask quirk for Vortex86SX
      it821x.c: use dev->revision instead of pci_read_config_byte

Brent Casavant (1):
      [IA64] generic_defconfig: Enable SATA_VITESSE

Brian Hinz (1):
      ALSA: hda - Add codec ID for MCP73 HDMI

Chris Adams (3):
      ti_usb_3410_5052: support alternate firmware
      ti_usb_3410_5052: add Multi-Tech modem support
      ti_usb_3410_5052: add Multi-Tech firmware

Chris Mason (2):
      Btrfs: Clear the device->running_pending flag before bailing on con=
gestion
      Btrfs: fix ioctl arg size (userland incompatible change!)

Christian Borntraeger (1):
      ata: fix wrong WARN_ON_ONCE

Christian Lamparter (5):
      p54: crypto offload fixes
      p54usb: fix random traffic stalls (LM87)
      minstrel: fix warning if lowest supported rate index is not 0
      p54: fix WARN_ON at line 2247 of net/mac80211/rx.c
      mac80211: initialize RC data for all mesh links upon allocation

Christoph Hellwig (4):
      [XFS] pass XFS_IGET_BULKSTAT to xfs_iget for handle operations
      [XFS] fix compile of xfs_btree_readahead_lblock on m68k
      [XFS] truncate readdir offsets to signed 32 bit values
      [XFS] make xfs_ino_t an unsigned long long

Clemens Fruhwirth (1):
      ALSA: hda - Fix typos for AD1882 codecs

Clemens Ladisch (1):
      sound: virtuoso: do not overwrite EEPROM on Xonar D2/D2X

Clifford Wolf (1):
      netdev: gianfar: add MII ioctl handler

Cyrill Gorcunov (1):
      net: ppp_generic - fix regressions caused by IDR conversion

Daisuke Nishimura (4):
      memcg: fix mem_cgroup_get_reclaim_stat_from_page
      memcg: fix error path of mem_cgroup_move_parent
      memcg: fix hierarchical reclaim
      memcg: make oom less frequently

Dan Williams (1):
      net_dma: acquire/release dma channels on ifup/ifdown

Daniel Gagnon (1):
      serial: Add SupraExpress 336i PnP Voice Modem

Daniel Wu (1):
      iwlwifi: Fix typo in iwl-commands.h for CCK rate bit range.

Daniele Venzano (1):
      sis900: generate fake MAC address if the hardware doesn't have one

Dave Airlie (3):
      drm/i915: setup sarea properly in master_priv
      drm/i915: add support for physical memory objects
      drm/i915: lock correct mutex around object unreference.

Dave Kleikamp (1):
      powerpc: is_hugepage_only_range() must account for both 4kB and 64k=
B slices

David Brownell (3):
      mfd: dm355 evm MMC/SD card detection
      drivers/usb/core/hub.c: fix CONFIG_USB_OTG=3Dy build
      ACPI: fix ACPI_FADT_S4_RTC_WAKE comment

David Daney (22):
      MIPS: Add Cavium OCTEON processor CSR definitions
      MIPS: Add Cavium OCTEON processor support files to arch/mips/cavium=
-octeon/executive and asm/octeon.
      MIPS: Add Cavium OCTEON processor support files to arch/mips/cavium=
-octeon.
      MIPS: For Cavium OCTEON handle hazards as per the R10000 handling.
      MIPS: For Cavium OCTEON set hwrena and lazily restore CP2 state.
      MIPS: Add Cavium OCTEON specific register definitions to mipsregs.h
      MIPS: Override assembler target architecture for octeon.
      MIPS: Add Cavium OCTEON processor constants and CPU probe.
      MIPS: Hook Cavium OCTEON cache init into cache.c
      MIPS: Hook up Cavium OCTEON in arch/mips.
      MIPS: Modify core io.h macros to account for the Octeon Errata Core=
-301.
      MIPS: Add Cavium OCTEON cop2/cvmseg state entries to processor.h.
      MIPS: Add Cavium OCTEON specific registers to ptrace.h and asm-offs=
ets.c
      MIPS: Add SMP_ICACHE_FLUSH for the Cavium CPU family.
      MIPS: Cavium OCTEON multiplier state preservation.
      MIPS:  Compute branch returns for Cavium OCTEON specific branch ins=
tructions.
      MIPS: Add Cavium OCTEON slot into proper tlb category.
      MIPS: Adjust the dma-common.c platform hooks.
      MIPS: Add defconfig for Cavium OCTEON.
      MIPS: Add Cavium OCTEON to arch/mips/Kconfig
      libata: Add another column to the ata_timing table.
      libata: New driver for OCTEON SOC Compact Flash interface (v7).

David Graham (1):
      e1000e: Add process name to WARN message when detecting Mutex conte=
ntion

David Kilroy (1):
      orinoco: take the driver lock in the rx tasklet

David Miller (1):
      sparc64: Fix cpumask related build failure

David S. Miller (8):
      sparc: Update 32-bit defconfig.
      sparc: Fix sun4d_irq.c build.
      sparc: Most unaligned_64.c tweaks for branch tracer warnings.
      sparc: Fix asm/signal.h for 32-bit.
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-2.6
      sparc64: Fix UP build failure.
      ARM etherh: Fix build failure.
      xfrm: For 32/64 compatability wrt. xfrm_usersa_info

David Teigland (2):
      dlm: fix seq_file usage in debugfs lock dump
      dlm: change rsbtbl rwlock to spinlock

David Woodhouse (1):
      CREDITS address update for dwmw2.

Dean Nelson (1):
      sgi-xp: eliminate false detection of no heartbeat

Denis Joseph Barrow (3):
      hso: driver fix for big endian machines.
      tty: Fix double grabbing of a spinlock
      hso serial throttled tty kref fix.

Dhananjay Phadke (9):
      netxen: fix endianness in firmware commands
      netxen: fix ipv6 offload and tx cleanup
      netxen: fix link speed reporting for some boards
      netxen: firmware init fix
      netxen: cleanup mac list on driver unload
      netxen: hold tx lock while sending firmware commands
      netxen: handle dma mapping failures
      netxen: avoid invalid iounmap
      netxen: include ipv6.h (fixes build failure)

Dirk Hohndel (1):
      Prevent oops at boot with VT-d

Doug Chapman (1):
      [IA64] dump stack on kernel unaligned warnings

Eilon Greenstein (13):
      bnx2x: Using singlethread work queue
      bnx2x: Missing memory barriers
      bnx2x: Using system page size for SGE
      bnx2x: Missing mask when calculating flow control
      bnx2x: Flow control updated before reporting the link
      bnx2x: Protecting the link change indication
      bnx2x: VLAN tagged packets without VLAN offload
      bnx2x: Endianness issues
      bnx2x: Fixing the doorbell size
      bnx2x: Missing brackets
      bnx2x: Indirection table initialization index
      bnx2x: MTU Filter
      bnx2x: First slow path interrupt race

Eric Dumazet (1):
      b44: GFP_DMA skb should not escape from driver

Eric Piel (1):
      lis3lv02d: merge with leds hp disk

Eric Sandeen (3):
      [XFS] Remove several unused typedefs.
      [XFS] Remove macro-to-function indirections in attr code
      [XFS] Remove macro-to-function indirections in the mask code

Erik Ekman (1):
      Wireless: Fix Kconfig fact error

Felix Fietkau (1):
      b44: fix misalignment and wasted space in rx handling

Florian Fainelli (4):
      r6040: fix ifconfig down and freeing of tx/rx descriptors
      r6040: generate random ethernet MAC address when not initialized
      r6040: no longer mark r6040 as being experimental
      r6040: bump release to 0.21

Frank Blaschka (1):
      qeth: fix usage of netdev_ops

Geert Uytterhoeven (25):
      fbdev: atafb - Fix line length handling
      fbdev: atafb - Fix 16 bpp console
      fbdev: c2p - Correct indentation
      fbdev: c2p - Cleanups
      fbdev: c2p - Extract common c2p core to c2p_core.h
      fbdev: c2p/atafb - Add support for Atari interleaved bitplanes
      fbdev: c2p - Rename c2p to c2p_planar
      m68k: Kill several external declarations in source files
      m68k: amiga core - Kill warn_unused_result warnings
      m68k: apollo core - Kill warn_unused_result warnings
      m68k: atari core - Kill warn_unused_result warnings
      m68k: hp300 core - Kill warn_unused_result warnings
      m68k: mac core - Kill warn_unused_result warnings
      m68k: mvme147 core - Kill warn_unused_result warnings
      m68k: sun3 core - Kill warn_unused_result warnings
      m68k: vme_scc - Kill warn_unused_result warnings
      m68k: ser_a2232 - Kill warn_unused_result warnings
      m68k: amiserial - Kill warn_unused_result warnings
      m68k: atafb - Kill warn_unused_result warnings
      m68k: dio - Kill warn_unused_result warnings
      m68k: zorro - Kill warn_unused_result warnings
      m68k: dmasound - Kill warn_unused_result warnings
      m68k: dio - Kill resource_size_t format warnings
      m68k: zorro - Use %pR to print resources
      fbdev: Kill Atari vblank cursor blinking

Gerrit Renker (1):
      dccp ccid-3: Fix RFC reference

Giuseppe Bilotta (1):
      ALSA: hda - Add quirk for another HP dv5

Grant Likely (1):
      powerpc/mpc52xx: Properly update irq_desc when set_type() is called.

Hannes Reinecke (1):
      [SCSI] Skip deleted devices in __scsi_device_lookup_by_target()

Harvey Harrison (3):
      RDMA/nes: Fix for NIPQUAD removal
      cris: introduce asm/swab.h
      byteorder: make swab.h include asm/swab.h like a regular header

Heiko Carstens (43):
      [CVE-2009-0029] Move compat system call declarations to compat head=
er file
      [CVE-2009-0029] Convert all system calls to return a long
      [CVE-2009-0029] Rename old_readdir to sys_old_readdir
      [CVE-2009-0029] Remove __attribute__((weak)) from sys_pipe/sys_pipe=
2
      [CVE-2009-0029] Make sys_pselect7 static
      [CVE-2009-0029] Make sys_syslog a conditional system call
      [CVE-2009-0029] System call wrapper infrastructure
      [CVE-2009-0029] s390: enable system call wrappers
      [CVE-2009-0029] System call wrapper special cases
      [CVE-2009-0029] System call wrappers part 01
      [CVE-2009-0029] System call wrappers part 02
      [CVE-2009-0029] System call wrappers part 03
      [CVE-2009-0029] System call wrappers part 04
      [CVE-2009-0029] System call wrappers part 05
      [CVE-2009-0029] System call wrappers part 06
      [CVE-2009-0029] System call wrappers part 07
      [CVE-2009-0029] System call wrappers part 08
      [CVE-2009-0029] System call wrappers part 09
      [CVE-2009-0029] System call wrappers part 10
      [CVE-2009-0029] System call wrappers part 11
      [CVE-2009-0029] System call wrappers part 12
      [CVE-2009-0029] System call wrappers part 13
      [CVE-2009-0029] System call wrappers part 14
      [CVE-2009-0029] System call wrappers part 15
      [CVE-2009-0029] System call wrappers part 16
      [CVE-2009-0029] System call wrappers part 17
      [CVE-2009-0029] System call wrappers part 18
      [CVE-2009-0029] System call wrappers part 19
      [CVE-2009-0029] System call wrappers part 20
      [CVE-2009-0029] System call wrappers part 21
      [CVE-2009-0029] System call wrappers part 22
      [CVE-2009-0029] System call wrappers part 23
      [CVE-2009-0029] System call wrappers part 24
      [CVE-2009-0029] System call wrappers part 25
      [CVE-2009-0029] System call wrappers part 26
      [CVE-2009-0029] System call wrappers part 27
      [CVE-2009-0029] System call wrappers part 28
      [CVE-2009-0029] System call wrappers part 29
      [CVE-2009-0029] System call wrappers part 30
      [CVE-2009-0029] System call wrappers part 31
      [CVE-2009-0029] System call wrappers part 32
      [CVE-2009-0029] System call wrappers part 33
      [CVE-2009-0029] s390 specific system call wrappers

Helge Deller (1):
      fix early_serial_setup() regression

Hendrik Brueckner (1):
      hvc_console: Remove tty->low_latency

Henrique de Moraes Holschuh (12):
      ACPI: thinkpad-acpi: update documents for the new location
      ACPI: thinkpad-acpi: debug facility to emulate the rf switches
      ACPI: thinkpad-acpi: resume with radios disabled
      ACPI: thinkpad-acpi: preserve radio state across shutdown
      ACPI: thinkpad-acpi: add UWB radio support
      ACPI: thinkpad-acpi: use killable instead of interruptible mutexes
      ACPI: thinkpad-acpi: clean up hotkey_notify()
      ACPI: thinkpad-acpi: handle HKEY thermal and battery alarms
      ACPI: thinkpad-acpi: start the event hunt season
      ACPI: thinkpad-acpi: clean-up fan subdriver quirk
      ACPI: thinkpad-acpi: handle HKEY event 6030
      ACPI: thinkpad-acpi: bump up version to 0.22

Herbert Xu (7):
      ipcomp: Remove spurious truesize increase
      netfilter 02/09: bridge: Fix handling of non-IP packets in FORWARD/=
POST_ROUTING
      netfilter 03/09: bridge: Disable PPPOE/VLAN processing by default
      ipv6: Fix fib6_dump_table walker leak
      gro: Check for GSO packets and packets with frag_list
      gro: Fix page ref count for skbs freed normally
      gso: Ensure that the packet is long enough

ILLES, Marton (1):
      [SCSI] Add SUN Universal Xport to no attach blacklist

Ilpo J=C3=A4rvinen (3):
      indentation & braces disagree - add braces
      misdn: one handmade ARRAY_SIZE converted
      misdn: indentation and braces disagree - add braces

Inaky Perez-Gonzalez (1):
      wimax: fix typo in kernel-doc for debugfs_dentry in struct wimax_de=
v

Ingo Molnar (9):
      Merge commit 'v2.6.29-rc1' into x86/urgent
      Merge commit 'v2.6.29-rc1' into core/urgent
      smp_call_function_single(): be slightly less stupid, fix
      Merge commit 'v2.6.29-rc1' into sched/urgent
      Revert "sched: improve preempt debugging"
      smp_call_function_single(): be slightly less stupid, fix #2
      Revert "cpumask: use work_on_cpu in acpi-cpufreq.c for drv_read and=
 drv_write"
      Revert "i386: add TRACE_IRQS_OFF for the nmi"
      powerpc: Change u64/s64 to a long long integer type

Isaku Yamahata (1):
      [IA64] Update to use account_{steal,idle}_ticks

Itai Levi (1):
      atmel_serial: fix flow control bug

Ivan Kokshaysky (6):
      alpha: fix vmalloc breakage
      alpha: nautilus - fix compile failure with gcc-4.3
      alpha: nautilus - fix hang on boot
      alpha: fix RTC on marvel
      alpha: .gitignore vmlinux.lds
      alpha: make pte_alloc_one_kernel() inline

Ivo van Doorn (4):
      rt2x00: Fix TX short preamble detection
      rt2x00: Fix segementation fault
      Fix rt2500usb HW crypto: TKIP
      rt2x00: Fix rt2500usb HW crypto: WEP 128 & AES

James Bottomley (1):
      ACPI PCI hotplug: harden against panic regression

Jan Engelhardt (2):
      netfilter 05/09: ebtables: fix inversion in match code
      netfilter 08/09: xt_time: print timezone for user information

Jan Kara (1):
      ext2: also update the inode on disk when dir is IS_DIRSYNC

Jarek Poplawski (2):
      pkt_sched: sch_htb: Consider used jiffies in htb_do_events()
      pkt_sched: sch_htb: Break all htb_do_events() after 2 jiffies

Jason Jin (1):
      powerpc: Fix the ide suspend function in uli1575

Jaswinder Singh Rajput (3):
      x86: fix mpparse.c build error on latest git
      x86: fix apic.c build error on latest git
      include of <linux/types.h> is preferred over <asm/types.h>

Jeff Garzik (1):
      [libata] get-identity ioctl: Fix use of invalid memory pointer

Jesper Dangaard Brouer (1):
      qlge: Naming interrupt vectors

Jesse Barnes (5):
      drm/i915: don't enable vblanks on disabled pipes
      drm/i915: set vblank enabled flag correctly across IRQ install/unin=
stall
      drm: initial KMS config fixes
      drm: handle depth & bpp changes correctly
      drm/i915: make LVDS fixed mode a preferred mode

Jim Paris (1):
      ftdi_sio: fix kref leak

Jiri Slaby (1):
      8250_pci: add support for netmos 9835 IBM devices

Johannes Berg (1):
      rtl8187: Fix module so that rmmod/insmod does not error

John Keller (1):
      [IA64] SN specific version of dma_get_required_mask()

John Linn (1):
      Xilinx: SPI: updated driver for device tree

John W. Linville (5):
      mac80211: fix "=E2=80=98ret=E2=80=99 may be used uninitialized" war=
ning
      b43: fix "=E2=80=98gmode=E2=80=99 may be used uninitialized" warnin=
g
      b43legacy: fix "=E2=80=98up_dev=E2=80=99 may be used uninitialized"=
 warning
      iwl3945: fix "=E2=80=98power_idx=E2=80=99 may be used uninitialized=
" warning
      p54: fix "=E2=80=98ret=E2=80=99 may be used uninitialized" warning

Jon Smirl (1):
      drivers/of: Add the of_find_i2c_device_by_node function.

Jonathan McDowell (1):
      eeepc-laptop: enable Bluetooth ACPI details

Jordan Crouse (1):
      hwmon: Add a driver for the ADT7475 hardware monitoring chip

Jos-Vicente Gilabert (1):
      drivers/net/irda/irda-usb.c: fix buffer overflow

JosephChan-6hSdJfI2Hxp9nmWX13WWKA@public.gmane.org (1):
      sata_via: Add VT8261 support

Jouni Malinen (2):
      ath9k: Enforce module build if rfkill is a module
      ath9k: Revert fix to TX status reporting for retries and MCS index

Julia Lawall (8):
      net/tipc/bcast.h: use ARRAY_SIZE
      net/bridge/netfilter: move a dereference below a NULL test
      drivers/isdn/hardware/mISDN: move a dereference below a NULL test
      drivers/net/hamradio/6pack.c: move a dereference below a NULL test
      drivers/net/wireless/libertas: move a dereference below a NULL test
      MIPS: Alchemy: Change strict_strtol to strict_strtoul
      drivers/isdn/hardware/mISDN: move a dereference below a NULL test
      netfilter 07/09: simplify nf_conntrack_alloc() error handling

Julian Calaby (2):
      sparc: Kill exports of prom internal functions
      sparc: Eliminate PROMLIB_INTERNAL as it does nothing

Karen Xie (1):
      [SCSI] iscsi_tcp: make padbuf non-static

Kars de Jong (2):
      m68k: Add vmlinux.lds to .gitignore
      m68k: zorro - Add devlist.h and gen-devlist to .gitignore

Karsten Keil (3):
      Make parameter debug writable
      Fix small typo
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6 into for_2.6.29

Kashyap, Desai (3):
      [SCSI] mpt fusion: Update MPI Headers to version 01.05.19
      [SCSI] mpt fusion: Add separate msi enable disable for FC,SPI,SAS
      [SCSI] mpt fusion: Add Firmware debug support

Kay Sievers (1):
      ACPI: thinkpad-acpi: struct device - replace bus_id with dev_name()=
, dev_set_name()

Krzysztof Ha=C5=82asa (2):
      WAN: Fix NAPI interface in IXP4xx HSS driver.
      net: Fix a comment in include/linux/netdevice.h.

Kumar Gala (2):
      powerpc/85xx: Fix PCIe error interrupts
      powerpc/e500mc: Doorbells need to be taken w/exceptions disabled

Kyle McMartin (1):
      x86, mtrr: fix types used in userspace exported header

Lachlan McIlroy (2):
      [XFS] Update maintainers
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-=
2.6 into for-linus

Larry Finger (2):
      p54usb: Fix to prevent SKB memory allocation errors with 4K page si=
ze
      rtl8180: Fix to add STA mode

Len Brown (5):
      dell-laptop: move to drivers/platform/x86/ from drivers/misc/
      ACPI: rename main.c to sleep.c
      Merge branches 'bugzilla-11884' and 'bugzilla-8544' into release
      Merge branch 'thinkpad-acpi' into release
      Merge branch 'misc' into release

Leonardo Potenza (1):
      net: fix section mismatch warnings in dccp/ccids/lib/tfrc.c

Li Zefan (6):
      sched: partly revert "sched debug: remove NULL checking in print_cf=
s_rt_rq()"
      cgroups: clean up Kconfig
      cgroups: consolidate cgroup documents
      idr: fix wrong kernel-doc
      memcg: fix section mismatch
      memcg: fix a race when setting memory.swappiness

Lin Ming (1):
      sched: sched_slice() fixlet

Linus Torvalds (38):
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/teigland/dlm
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/geert/linux-m68k
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/wim/linux-2.6-w=
atchdog
      Merge branch 'for_2.6.29' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/kkeil/ISDN-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'upstream' of git://ftp.linux-mips.org/pub/scm/upstrea=
m-linus
      Merge branch 'for-next' of git://git.o-hand.com/linux-mfd
      Merge branch 'core-fixes-for-linus' of git://git.kernel.org/pub/scm=
/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'sched-fixes-for-linus' of git://git.kernel.org/pub/sc=
m/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/jgarzik/libata-dev
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/roland/infiniband
      Merge branch 'core-fixes-for-linus' of git://git.kernel.org/pub/scm=
/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge master.kernel.org:/home/rmk/linux-2.6-arm
      Merge branch 'x86-pat-for-linus' of git://git.kernel.org/pub/scm/li=
nux/kernel/git/tip/linux-2.6-tip
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/bart/ide-2.6
      Merge branch 'for-linus' of git://oss.sgi.com/xfs/xfs
      Merge branch 'syscalls' of git://git390.osdl.marist.edu/pub/scm/lin=
ux-2.6
      Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/benh/powerpc
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel=
/git/aegl/linux-2.6
      Revert "x86 PAT: remove CPA WARN_ON for zero pte"
      Merge branch 'hwmon-for-linus' of git://jdelvare.pck.nerim.net/jdel=
vare-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-2.6
      Merge branch 'sched-fixes-for-linus' of git://git.kernel.org/pub/sc=
m/linux/kernel/git/tip/linux-2.6-tip
      Revert "PCI PM: Register power state of devices during initializati=
on"
      Merge branch 'drm-next' of git://git.kernel.org/pub/scm/linux/kerne=
l/git/airlied/drm-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/jejb/scsi-rc-fi=
xes-2.6
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/jgarzik/libata-dev
      Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/benh/powerpc
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/mason/btrfs-uns=
table
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel=
/git/lenb/linux-acpi-2.6
      Linux 2.6.29-rc2

Lukasz Wojnilowicz (1):
      ALSA: hda - Add quirks for Acer Aspire 5930G and 6930G

Luke Yelavich (1):
      ALSA: hda - Add automatic model setting for Samsung Q45

Magnus Damm (1):
      ax88796: start_xmit fix using net_device_ops

Manuel Lauss (14):
      MIPS: Alchemy: Move development board code to common subdirectory
      MIPS: Alchemy: devboards: consolidate files
      MIPS: Alchemy: move commandline mangling out of common code
      MIPS: Alchemy: update core interrupt code.
      MIPS: Alchemy: pb1200: update CPLD cascade irq handler.
      MIPS: Print irq handler description
      MIPS: Alchemy: remove get/set_au1x00_lcd_clock().
      MIPS: Alchemy: remove cpu_table.
      MIPS: make cp0 counter clocksource/event usable as fallback.
      MIPS: Alchemy: RTC counter clocksource / clockevent support.
      MIPS: Alchemy: move calc_clock function.
      MIPS: Alchemy: Fix up PM code on Au1550/Au1200
      MIPS: Alchemy: dbdma suspend/resume support.
      MIPS: Alchemy: new userspace suspend interface for development boar=
ds.

Marcus Meissner (1):
      Documentation/accounting/getdelays.c: fix endless loop

Mark Brown (1):
      [WATCHDOG] wm8350: Fix section annotations

Martin Bachem (1):
      BUGFIX: used NULL pointer at ioctl(sk,IMGETDEVINFO,&devinfo) when d=
evinfo.id not registered

Martyn Welch (2):
      [WATCHDOG] Basic support for GE Fanuc's FPGA based watchdog timer
      [WATCHDOG] Enable watchdog timer on GE Fanuc's SBC610

Masami Hiramatsu (1):
      kprobes: check CONFIG_FREEZER instead of CONFIG_PM

Matthew Ranostay (1):
      ALSA: hda: stac92hd8xxx amp mixers

Matthias Fuchs (1):
      serial: Add 16850 uart type support to OF uart driver

Matti Halme (1):
      rtc: rtc-twl4030 don't mask alarm interrupts on shutdown

Mauro Carvalho Chehab (4):
      ALSA: hda - Add a new function to seek for a codec ID
      ALSA: patch_sigmatel: Add missing Gateway entries and autodetection
      ALSA: hda - More fixes on Gateway entries
      edac: add MAINTAINERS entry for i5400 EDAC driver

Michael Ellerman (1):
      powerpc: Enable PS3 options and QPACE in ppc64_defconfig

Michael Hennerich (1):
      video/framebuffer: fix bug: jpegview cannot work on framebuffer dev=
ice other than 16BPP

Michael Neuling (1):
      powerpc: Get the number of SLBs from "slb-size" property

Michal Sojka (1):
      sata_fsl: Return non-zero on error in probe()

Michiel (1):
      p54usb: Add USB ID for Thomson Speedtouch 121g

Mike Ditto (1):
      powerpc/fs_enet: Add missing irq free in error path.

Milton Miller (6):
      powerpc: Make dummy section a valid note header
      powerpc/kexec: Check crash_base for relocatable kernel
      hvc_console: Change an mb() to smp_mb() and add some comments
      hvc_console: Call free_irq() only if request_irq() was successful
      hvc_console: Do not set low_latency when using interrupts
      hvc_console: Use kzalloc() instead of kmalloc() + memset()

Mischa Jonker (1):
      When a break signal is detected, the next character should be ignor=
ed.

Nathan Lynch (1):
      powerpc/cacheinfo: Rename cache_dir per-cpu variable

Nick Piggin (3):
      [XFS] remove old vmap cache
      [XFS] use scalable vmap API
      mm: fix assertion

Nicolas Pitre (1):
      [ARM] 5364/1: allow flush_ioremap_region() to be used from modules

Oliver Hartkopp (1):
      can: fix slowpath issue in hrtimer callback function

Patrick McHardy (3):
      netfilter 01/09: remove "happy cracking" message
      netfilter 04/09: x_tables: fix match/target revision lookup
      netfilter 06/09: nf_conntrack: fix ICMP/ICMPv6 timeout sysctls on b=
ig-endian

Paul Bolle (2):
      i4l: do not print a warning when shutting down an i4l ppp interface
      i4l: minor cleanups

Paul E. McKenney (1):
      rcu: fix bug in rcutorture system-shutdown code

Paul Fulghum (1):
      synclink_gt: enable RI interrupt

Pavel Machek (4):
      MAINTAINERS: add entry for freezer
      nbd: do not allow two clients at the same time
      lis3: fix documentation to fit into 80 columns
      hp_accel: do not call ACPI from invalid context

Pavel Roskin (2):
      orinoco_cs: add ID for ARtem Onair Comcard 11
      mac80211: allow mode change if IBSS is not allowed

Peter Ujfalusi (4):
      ASoC: Merge the soc_value_enum to soc_enum struct
      ASoC: TWL4030: Change the soc_value_enum back to soc_enum
      ASoC: TWL4030: Module unloading fix
      ASoC: Fix the power update function for snd_soc_dapm_value_mux

Peter W Morreale (1):
      Update of Documentation: vm.txt and proc.txt

Peter Zijlstra (5):
      lockdep, mm: fix might_fault() annotation
      sched: fix bandwidth validation for UID grouping
      sched: SCHED_IDLE weight change
      sched: SCHED_OTHER vs SCHED_IDLE isolation
      sched: fix update_min_vruntime

Phil Sutter (9):
      korina: fix usage of driver_data
      korina: reset resource buffer size to 1536
      korina: disable napi on close and restart
      korina: rework korina_rx() for use with napi
      korina: do schedule napi after testing for it
      korina: do tx at the right position
      korina: fix handling tx_chain_tail
      korina: do not stop queue here
      korina: do not use IRQF_SHARED with IRQF_DISABLED

Qinghuang Feng (1):
      btrfs & squashfs: Move btrfs and squashfsto's magic number to <linu=
x/magic.h>

Rafael J. Wysocki (1):
      PM: Fix freezer compilation if PM_SLEEP is unset

Ralf Baechle (1):
      MIPS: Only write c0_framemask on CPUs which have this register.

Randy Dunlap (3):
      IB/iser: Add dependency on INFINIBAND_ADDR_TRANS
      jbd: fix missing kernel-doc
      resources: fix parameter name and kernel-doc

Richard Kennedy (1):
      netfilter 09/09: remove padding from struct xt_match on 64bit build=
s

Roland Dreier (5):
      mlx4_core: Fix warning from min()
      IB/mlx4: Don't register IB device for adapters with no IB ports
      cxgb3: Keep LRO off if disabled when interface is down
      Merge branches 'ehca', 'ipoib', 'iser', 'mlx4' and 'nes' into for-n=
ext
      9p: disallow RDMA if RDMA CM isn't available

Ron Mercer (5):
      qlge: Get rid of volatile usage for shadow register.
      qlge: Get rid of split addresses in hardware control blocks.
      qlge: Remove support for device ID 8000.
      qlge: Fix schedule while atomic issue.
      qlge: Remove dynamic alloc of rx ring control blocks.

Russell King (3):
      [ARM] w90x900: fix build errors and warnings
      Merge branch 'for-rmk' of git://git.pengutronix.de/git/imx/linux-2.=
6
      TWL4030: fix clk API usage

Rusty Russell (1):
      cpumask: fix CONFIG_NUMA=3Dy sched.c

Sam Ravnborg (4):
      sparc64: fix warnings in psycho_common after ull conversion
      sparc: Create a new file lib/ksyms.c and add export of all symbols =
defined in assembler in lib/ to this file.
      sparc: move EXPORT_SYMBOL to the symbols definition
      sparc64: move EXPORT_SYMBOL to the symbols definition

Samuel Ortiz (2):
      mfd: Fix twl4030-core build
      iwlwifi: Fix get_cmd_string() for REPLY_3945_RX

Sascha Hauer (3):
      [ARM] i.MX: remove LCDC controller register definitions from imx-re=
gs.h
      [ARM] i.MX: fix breakage from commit 278892736e99330195c8ae5861bcd9=
d791bbf19e
      [ARM] i.MX add missing include

Sean MacLennan (1):
      [WATCHDOG] Pika Warp appliance watchdog timer

Senthil Balasubramanian (1):
      ath9k: Fix incorrect sequence numbering for unaggregated QoS Frame.

Signed-off-by: Peter Stokes (1):
      ALSA: USB quirk for Logitech Quickcam Pro 9000 name

Stanislaw Gruszka (1):
      atmel_spi: allow transfer when max_speed_hz =3D 0

Stefan Lippers-Hollmann (1):
      rt2x00: add USB ID for the Linksys WUSB200.

Steffen Klassert (1):
      3c59x: Use device_set_wakeup_enable

Stephen Hemminger (2):
      netdev: add missing set_mac_address hook
      netdev: missing validate_address hooks

Stephen Rothwell (17):
      IB/ehca: spin_lock_irqsave() takes an unsigned long
      powerpc: Cleanup from l64 to ll64 change: arch code
      powerpc: Cleanup from l64 to ll64 change: drivers/char
      powerpc: Cleanup from l64 to ll64 change: drivers/net
      powerpc: Cleanup from l64 to ll64 change drivers/scsi
      powerpc/ps3: set_dabr() takes an unsigned long
      powerpc/ps3: Use dma_addr_t down through the stack
      powerpc/ps3: The lv1_ routines have u64 parameters
      powerpc/ps3: clear_bit()/set_bit() operate on unsigned longs
      powerpc/ps3: ps3_repository_read_mm_info() takes u64 * arguments
      powerpc/ps3: Printing fixups for l64 to ll64 conversion arch/powerp=
c
      powerpc/ps3: Printing fixups for l64 to ll64 conversion drivers/blo=
ck
      powerpc/ps3: Printing fixups for l64 to ll64 conversion drivers/cha=
r
      powerpc/ps3: Printing fixups for l64 to ll64 conversion sound/ppc
      powerpc/ps3: Printing fixups for l64 to ll64 conversion drivers/ps3
      powerpc/ps3: Printing fixups for l64 to ll64 conversion drivers/scs=
i
      powerpc/ps3: printing fixups for l64 to ll64 conversion drivers/vid=
eo

Steve Brown (1):
      ath5k: Correct usage of AR5K_CFG_ADHOC

Steve Glendinning (2):
      smsc911x: fix smsc911x_reg_read compiler warning
      smsc911x: register irq with device name, not driver name

Steven Noonan (1):
      kernel/sched.c: add missing forward declaration for 'double_rq_lock=
'

Sujith (1):
      ath9k: Fix chainmask handling bug

Takashi Iwai (23):
      ALSA: hda - Add quirk for HP 2230s
      ALSA: caiaq - Fix Oops with MIDI
      ALSA: hda - Add quirk for Dell Inspiron Mini9
      ALSA: caiaq - Version 1.3.10
      ALSA: hda - Use own workqueue
      Merge branch 'topic/asoc' into for-linus
      Merge branch 'topic/hda' into for-linus
      Merge branch 'topic/usb-caiaq' into for-linus
      ALSA: hda - Fix a typo
      ALSA: hda - Add support of NVidia MCP78 HDMI
      ALSA: hda - Use queue_delayed_work()
      Merge branch 'topic/hda-gateway' into topic/hda
      ALSA: hda - Update model descriptions in patch_sigmatel.c
      ALSA: hda - Fix silent headphone output on Panasonic CF-74
      ALSA: hda - Don't reset HP pinctl in patch_sigmatel.c
      ALSA: hda - Fix stac92hd83xxx_amp_nids[]
      ALSA: hda - Fix missing initialization of NID 0x0e for STAC925x
      ALSA: hda - Fix HP dv5 mic input
      Merge branch 'topic/hda' into for-linus
      Merge branch 'topic/usb-fix' into for-linus
      Merge branch 'topic/virtuoso-fix' into for-linus
      ALSA: hda - Fix invalid amp value for STAC925x
      Merge branch 'topic/hda' into for-linus

Tejun Heo (1):
      pata_atiixp: update port enabledness test handling

Timur Tabi (2):
      powerpc/qe: add Ethernet UPSMR definitions to QE library
      ucc_geth: use correct UCCE macros

Tony Luck (1):
      [IA64] Turn on CONFIG_HAVE_UNSTABLE_CLOCK

Trent Piepho (4):
      powerpc/fsl-pci: Better ATMU setup for 85xx/86xx
      powerpc/fsl-pci: Set relaxed ordering on prefetchable ranges
      powerpc/fsl-booke: Don't hard-code size of struct tlbcam
      powerpc/fsl-booke: Remove num_tlbcam_entries

Willy Tarreau (1):
      tcp: splice as many packets as possible at once

Wolfram Sang (1):
      powerpc/mpc52xx: remove dead code from GPIO driver

Wu Fengguang (2):
      ALSA: hda - create hda_codec.control_mutex for kcontrol->private_va=
lue
      ALSA: hda - add support for Intel DX58SO board

Yossi Etigin (2):
      IPoIB: Fix loss of connectivity after bonding failover on both side=
s
      IPoIB: Do not join broadcast group if interface is brought down

Yuri Tikhonov (1):
      powerpc/xsysace: add compatible string for non-ipcore instance

Zhang Rui (1):
      thermal fixup for broken BIOS which has invalid trip points.

roel kluin (1):
      powerpc/mpc5121: fix NULL test in mpc5121_clk_get utility function.

venkatesh.pallipadi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org (5):
      x86 PAT: remove PFNMAP type on track_pfn_vma_new() error
      x86 PAT: consolidate old memtype new memtype check into a function
      x86 PAT: change track_pfn_vma_new to take pgprot_t pointer param
      x86 PAT: return compatible mapping to remap_pfn_range callers
      x86 PAT: remove CPA WARN_ON for zero pte

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr

--===============8960442938097663893==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============8960442938097663893==--
