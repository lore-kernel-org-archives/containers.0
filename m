From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr annotated tag, v2.6.28-rc1, created. v2.6.28-rc1
Date: Wed, 16 Sep 2009 14:36:28 -0400
Message-ID: <200909161836.n8GIaS0i000981@gorgona.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0128749111745310389=="
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

--===============0128749111745310389==
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by smtp1.linux-foundation.org id n8GJTUsU009340

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The annotated tag, v2.6.28-rc1 has been created
        at  cb50773491b0066d0e55f31f8875d5678fa3f8ad (tag)
   tagging  57f8f7b60db6f1ed2c6918ab9230c4623a9dbe37 (commit)
  replaces  v2.6.27
 tagged by  Linus Torvalds
        on  Thu Oct 23 20:07:06 2008 -0700

- Log -----------------------------------------------------------------
Linux 2.6.28-rc1
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkkBO+UACgkQF3YsRnbiHLsnywCfajr6CN576gfWN13UeJmESF45
IHEAn2pYtzpUjTPQ9wrAzv5ZA2nVxwjl
=3Dvmbj
-----END PGP SIGNATURE-----

Aaron Carroll (4):
      deadline-iosched: allow non-sequential batching
      deadline-iosched: non-functional fixes
      block: update documentation for deadline fifo_batch tunable
      cfq-iosched: fix queue depth detection

Abhijeet Kolekar (8):
      iwlwifi : Added bss_info_changed callback to 3945
      iwl3945: fix unbalanced mutex
      iwl3945: replace association and beacon hooks with bss_info_changed=
 cb
      iwl3945: removed bg_post_associate work
      iwl3945: avoid redundant iwl3945_get_active_dwell_time
      iwl3945: enable active scanning on active channels
      iwl3945 : Code cleanup
      mac80211 : Fix mode change hard_start_xmit function

Abhijith Das (1):
      GFS2: GFS2 will panic if you misspell any mount options

Adam Glover (1):
      V4L/DVB (9063): Add ADS Tech Instant HDTV PCI support

Adam Jackson (2):
      x86, debug printouts: IOMMU setup failures should not be KERN_ERR
      sony-laptop: newline-terminate the printk for backlight change fail=
ure

Adam Tkac (1):
      rlimit: permit setting RLIMIT_NOFILE to RLIM_INFINITY

Adrian Bunk (57):
      make selinux_write_opts() static
      powerpc: Use bcd2bin/bin2bcd
      crypto: Kconfig - Replace leading spaces with tabs
      sparc: remove CONFIG_SUN4
      Remove asm/a.out.h files for all architectures without a.out suppor=
t.
      [netdrvr/usb] hso_create_bulk_serial_device(): fix a double free
      [SCSI] qla2xxx: remove the unused SCSI_QLOGIC_FC_FIRMWARE option
      fix fs/nfs/nfsroot.c compilation
      proc: make grab_header() static
      V4L/DVB (8561): make ivtv_claim_stream() static
      add key_revoke() dummy for KEYS=3Dn
      provide generic_block_fiemap() only with BLOCK=3Dy
      net/tc35815.c: fix compilation
      net/au1000_eth.c MDIO namespace fixes
      net/bfin_mac.c MDIO namespace fixes
      coldfire: scheduled SERIAL_COLDFIRE removal
      CRIS: proper defconfig setup
      xtensa: remove dead CONFIG_BLK_DEV_IDE code
      mISDN/dsp_cmx.c: fix size checks
      net: export genphy_restart_aneg
      m68k: use bcd2bin/bin2bcd
      m68k: Remove the broken Hades support
      m68k: remove the dead PCI code
      driver core: make struct platform_pm_ops static
      drivers/firmware/iscsi_ibft.c: make 3 functions static
      asm-h8300/md.h: remove CVS keyword
      Alpha Miata: remove dead URL
      uml: remove the dead TTY_LOG code
      include/linux/mount.h: remove CVS keyword
      kernel/dma.c: remove a CVS keyword
      binfmt_som.c: add MODULE_LICENSE
      pnp: remove printk() with outdated version
      telephony: remove CVS keywords
      reiserfs/procfs.c: remove CVS keywords
      quota: remove CVS keywords
      fs/partitions/acorn.c: remove dead code
      parport: remove CVS keywords
      ipc/sem.c: make free_un() static
      make hp_wmi_notify() static
      make kprobes.c:kretprobe_table_lock() static
      init/do_mounts_md.c must #include <linux/delay.h>
      FB_SIS=3Dm, DRM_SIS=3Dy is not a legal configuration.
      make probe_serial_gsc() static
      make ptrace_untrace() static
      make mm/rmap.c:anon_vma_cachep static
      acpi: use bcd2bin/bin2bcd
      alpha: use bcd2bin/bin2bcd
      cris: use bcd2bin/bin2bcd
      drivers/rtc/: use bcd2bin/bin2bcd
      rtc: use bcd2bin/bin2bcd
      mips: use bcd2bin/bin2bcd
      mn10300: use bcd2bin/bin2bcd
      i2c: use bcd2bin/bin2bcd
      drivers/scsi/sr_vendor.c: use bcd2bin
      remove the obsolete BCD*BIN/BIN*BCD macros
      include/linux/bcd.h: remove comments
      [patch 1/3] FS_MBCACHE: don't needlessly make it built-in

Adrian Hunter (18):
      [MTD] [OneNAND] Add defines for HF and sync write
      [MTD] Define and use MTD_FAIL_ADDR_UNKNOWN instead of 0xffffffff
      [MTD] [OneNAND] Add OMAP2 / OMAP3 OneNAND driver
      [JFFS2] Correct symlink name too long error code
      [MTD] [OneNAND] OMAP3: add delay for GPIO
      [MTD] [NAND] OMAP2: add retry after read timeout
      UBIFS: add bulk-read facility
      UBIFS: add no_chk_data_crc mount option
      UBIFS: improve znode splitting rules
      UBIFS: correct key comparison
      UBIFS: ensure data read beyond i_size is zeroed out correctly
      UBIFS: allow for sync_fs when read-only
      UBIFS: improve garbage collection
      UBIFS: fix bulk-read handling uptodate pages
      UBIFS: add more debugging messages for LPT
      UBIFS: correct condition to eliminate unecessary assignment
      UBIFS: check buffer length when scanning for LPT nodes
      UBIFS: do not read unnecessary bytes when unpacking bits

Ajay Kumar Gupta (2):
      OMAP:MUSB: Fixes the TT programming.
      OMAP:MUSB: Corrects urb unlink function path

Akinobu Mita (6):
      x86: check for ioremap() failure in copy_oldmem_page()
      x86: use platform_device_register_simple()
      [CPUFREQ] acpi-cpufreq: add error handling for cpufreq_register_dri=
ver() error
      [CPUFREQ] add error handling for cpufreq_register_governor() error
      ip2: avoid add_timer with pending timer
      [SCSI] ipr: use memory_read_from_buffer()

Al Viro (105):
      introduce fmode_t, do annotations
      eliminate use of ->f_flags in block methods
      pass mode instead of file to sg_io()
      switch sg_scsi_ioctl() to passing fmode_t
      switch scsi_cmd_ioctl() to passing fmode_t
      lose the unused file argument in generic_ide_ioctl()
      lose unused arguments in dm ioctl callbacks
      move block_device_operations to blkdev.h
      switch cdrom_{open,release,ioctl} to sane APIs
      switch pktcdvd to blkdev_driver_ioctl()
      introduce __blkdev_driver_ioctl()
      don't mess with file in scsi_nonblockable_ioctl()
      switch ide_disk_ops ->ioctl() to sane prototype
      beginning of methods conversion
      switch ubd
      switch DAC960
      switch amiflop
      switch aoeblk
      switch ataflop
      switch brd
      switch cciss
      switch cpqarray
      switch floppy
      switch loop
      switch nbd
      switch pcd
      switch pd
      switch pf
      switch pktdvdcd
      switch swim3
      switch ub
      switch viodasd
      switch virtio_blk
      switch xd
      switch xen
      switch xyspace
      switch z2ram
      switch gdrom
      switch viocd
      switch ide-cd
      switch ide-gd
      switch ide-tape
      switch dm
      switch md
      switch memstick
      switch i2o
      switch mmc
      switch mtd_blkdevs
      switch dasd
      switch dcssblk
      switch tape_block
      switch ide-scsi
      switch sd
      switch sr
      end of methods switch: remove the old ones
      trim file propagation in block/compat_ioctl.c
      kill the unused bsize on the send side of /dev/loop
      pass fmode_t to blkdev_put()
      propagate mode through open_bdev_excl/close_bdev_excl
      propagate mode through swsusp_close()
      remember mode of reiserfs journal
      sanitize blkdev_get() and friends
      get rid of blkdev_driver_ioctl()
      get rid of blkdev_locked_ioctl()
      get rid of struct file use in blkdev_ioctl() BLKBSZSET
      kill the rest of struct file propagation in block ioctls
      x86, um: take arch/um/include/* out of the way
      x86, um: initial part of asm-um move
      x86, um: ... and asm-x86 move
      x86, um: now we can get rid of trivial uml headers
      x86, um: sanitize uml sigcontext.h uses
      x86, um: get rid of uml signal.h
      x86, um: remove dead header (uml module-generic.h; never used these=
 days)
      x86, um: get rid of more uml asm/arch uses
      x86, um: untangle uml ldt.h
      x86, um: uml atomic.h is not needed anymore
      x86, um: get rid of system.h -> system.h include
      x86, um: get rid of uml unistd.h
      x86, um: get rid of uml highmem.h
      x86, um: get rid of uml asm/arch
      x86, um: take vm-flags.h to sysdep
      x86, um: trim the junk from uml ptrace-*.h
      x86, um: get rid of sysdep symlink
      x86, um: merge Kconfig.i386 and Kconfig.x86_64
      x86, um: get rid of header symlinks
      x86, um: get rid of excessive includes of uml-config.h
      x86, um: get rid of arch/um/os symlink
      x86, um: get rid of arch/um/Kconfig.arch
      x86, um: get rid of uml-config.h
      new helper - kern_path()
      finally get rid of nameidata in namespace.c
      no need for noinline stuff in fs/namespace.c anymore
      switch quota_on-related stuff to kern_path()
      sanitize svc_export_parse()
      switch nfsd to kern_path()
      assorted path_lookup() -> kern_path() conversions
      get rid of nameidata in audit_tree
      get rid of path_lookup_create()
      don't pass bogus flags to LOOKUP_PARENT lookup in spufs
      make O_EXCL in nd->intent.flags visible in nd->flags
      reduce the stack footprint of exportfs_decode_fh()
      get rid of on-stack fake dentry in ext3_get_parent()
      get rid of on-stack dentry in ext2_get_parent()
      prepare vfs_readdir() callers to returning filldir result
      get rid of on-stack dentry in udf

Alan Cox (63):
      pcmcia: Fix up legacy driver IRQs
      Export the ROM enable/disable helpers
      [MTD] [NOR] intel_dc21285 switch to ROM API
      x86, early_ioremap: fix fencepost error
      epca: call tty_port_init
      nozomi: Fix close on error
      ftdi: A few errors are err() that should be debug which causes much=
 spewage
      serial_8250: pci_enable_device fail is not fully handled
      tty: move tioclinux from a special case
      uml: small cleanups and note bugs to be dealt with by uml authors...
      tty: split the buffering from tty_io
      tty: Split tty_port into its own file
      pps: Reserve a line discipline number for PPS
      tty: Add a kref count
      tty: use krefs to protect driver module counts
      tty: Cris has a nice RS485 ioctl so we should steal it
      tty: ipw need reworking
      tty: Add termiox
      tty: Termios locking - sort out real_tty confusions and lock reads
      tty: compare the tty winsize
      tty: Make get_current_tty use a kref
      tty: Move tty_write_message out of kernel/printk
      tty: usb-serial krefs
      tty: kref usage for isicom and moxa
      stallion: Use krefs
      mxser: Switch to kref tty
      tty: the vhangup syscall is racy
      tty: Redo current tty locking
      tty: Fix abusers of current->sighand->tty
      pty: If the administrator creates a device for a ptmx slave we shou=
ld not error
      vt: remove bogus lock dropping
      tty: shutdown method
      tty: Remove more special casing and out of place code
      tty: Clean up the tty_init_dev changes further
      tty: kref the tty driver object
      tty: More driver operations
      tty: Finish fixing up the init_dev interface to use ERR_PTR
      tty: extract the pty init time special cases
      pty: Coding style and polish
      pty: Fix allocation failure double free
      pty: simplify unix98 allocation
      tty: simplify ktermios allocation
      tty: some ICANON magic is in the wrong places
      tty: fix up gigaset a bit
      tty: Remove lots of NULL checks
      tty: Minor tidyups and document fixes for n_tty
      applicom: Fix an unchecked user ioctl range and an error return
      fs3270: remove extra locks
      fs3270: Correct error returns
      tty: rename the remaining oddly named n_tty functions
      net: Rationalise email address: Network Specific Parts
      8250: Fix lock warning (and possible crash)
      metronomefb: Fix warning when building 64bit
      lmc: copy_*_user under spinlock
      [netdrvr] ibmtr: PCMCIA IBMTR is ok on 64bit
      serial, 8250: remove NR_IRQ usage
      i2o: Fix 32/64bit DMA locking
      fb: push down the BKL in the ioctl handler
      hfsplus: missing O_LARGEFILE check
      epca: Add infinite break support
      watchdog: Fix warning
      tty: Fix tty_port kref screwup
      [SCSI] aic79xx: user visible misuse wrong SI units (not disk size!)

Alan Horstmann (1):
      sound: ASoC: Fix WM8731 SPI write

Alan Jenkins (1):
      raid, fastboot: hide RAID autodetect option if MD is compiled as a =
module

Alan Stern (14):
      USB: gadget: dummy_hcd: implement set_wedge
      USB: gadget: net2280: implement set_wedge
      usb-storage: report underflow with no sense data
      OHCI: Allow broken controllers to auto-stop
      USB: change hub initialization sleeps to delayed_work
      USB: UHCI: improve scheduling of interrupt URBs
      USB: EHCI, OHCI, UHCI: remove version numbers
      USB: EHCI: log a warning if ehci-hcd is not loaded first
      USB: snoop processes opening usbfs device files
      USB: EHCI: fix remote-wakeup support for ARC/TDI core
      USB: OHCI: fix endless polling behavior
      USB: Speedtouch: add pre_reset and post_reset routines
      USB: don't rebind drivers after failed resume or reset
      [SCSI] sd: remove command-size switching code

Alasdair G Kergon (3):
      dm crypt: remove inc_pending from write_io_submit
      dm: detect lost queue
      dm exception store: refactor zero_area

Albert Aribaud (1):
      [ARM] EDMINIV2: add support for LED and power button

Albert Comerma (1):
      V4L/DVB (9042): Add support for Asus My Cinema U3000 Hybrid

Alberto Bertogli (3):
      bio.h: Remove unused conditional code
      Documentation/block/data-integrity.txt: Fix section numbers
      Fix typo in the FIRMWARE_IN_KERNEL help

Alessandro Zummo (2):
      rtc-max6900 new style driver
      rtc-ds1672 new style driver

Alex Chiang (18):
      HID: fix grammo in HID_COMPAT Kconfig help text
      PCI: connect struct pci_dev to struct pci_slot
      PCI Hotplug core: add 'name' param pci_hp_register interface
      PCI: rename pci_update_slot_number to pci_renumber_slot
      PCI: update pci_create_slot() to take a 'hotplug' param
      PCI: prevent duplicate slot names
      PCI: acpiphp: remove 'name' parameter
      PCI: cpci_hotplug: stop managing hotplug_slot->name
      PCI: cpqphp: stop managing hotplug_slot->name
      PCI, PCI Hotplug: introduce slot_name helpers
      PCI: fakephp: remove 'name' parameter
      PCI: ibmphp: stop managing hotplug_slot->name
      PCI: pciehp: remove 'name' parameter
      PCI: rpaphp: kmalloc/kfree slot->name directly
      PCI: SGI Hotplug: stop managing bss_hotplug_slot->name
      PCI: shcphp: remove 'name' parameter
      PCI: Hotplug core: remove 'name'
      PCI Hotplug: fakephp: add duplicate slot name debugging

Alex Deucher (3):
      drm/radeon: add support for RS740 IGP chipsets.
      radeon: add RS400 family support.
      radeon: fix PCI bus mastering support enables.

Alex Nixon (13):
      x86: add cpu hotplug hooks into smp_ops
      x86_32: clean up play_dead
      x86: unify x86_32 and x86_64 play_dead into one function
      x86: separate generic cpu disabling code from APIC writes in cpu_di=
sable
      xen: implement CPU hotplugging
      Xen: fix cpu_hotplug.c build by replacing is_running_on_xen() with =
xen_pv_domain()
      Xen: fix cpu_hotplug build when !CONFIG_SMP
      x86: build fix for !CONFIG_SMP
      x86/paravirt: Remove duplicate paravirt_pagetable_setup_{start, don=
e}()
      x86, xen: fix build when !CONFIG_HOTPLUG_CPU
      xen: make CPU hotplug functions static
      xen: fix memory access violation bug when CONFIG_HAVE_SPARSE_IRQ is=
 enabled
      xen: Fix bug `do_IRQ: cannot handle IRQ -1 vector 0x6 cpu 1'

Alex Raimondi (3):
      avr32: Replace static clock list with dynamic linked list
      include/linux/clk.h: fix comment
      avr32: Fix bug in LCD pin setup on port C

Alexander Belyakov (2):
      [MTD] [NOR] fix cfi_cmdset_0001 FL_SYNCING race (take 2)
      [JFFS2] Write buffer offset adjustment for NOR-ECC (Sibley) flash

Alexander Beregalov (15):
      ALSA: ice1724/revo: simple clean up
      ALSA: sound/pci/Kconfig: update for ice1712/24
      ALSA: sound/pci: supported cards update
      ALSA: ALSA-Configuration.txt: supported cards update
      ALSA: revo51: add headphone output
      ALSA: ice1712/aureon.c: fix coding style
      ALSA: ice1712/wtm: fix coding style
      ALSA: ice1724.c: fix coding style
      ALSA: ice1712.c: fix coding style
      [SCSI] qla2xxx: fix printk format warnings
      V4L/DVB (8560): replace __FUNCTION__ with __func__
      V4L/DVB (8680): saa7134-core.c: fix warning
      V4L/DVB (8559): replace __FUNCTION__ with __func__
      ext4: fix build failure without procfs
      ide-cd: fix printk format warning

Alexander Duyck (12):
      igb: remove unneeded cleaned variable in clean_tx_irq path
      igb: clean up a stray fake netdev code left in rx path
      ixgbe: change config srrctl to only program one register per VMDq/R=
SS id
      vlan: vlan device not reading gso max size of parent.
      pkt_sched: Add multiqueue scheduler support
      pkt_action: add new action skbedit
      skbedit: Fix a typo in the documentation
      multiq: Further multiqueue cleanup
      multiq: requeue should rewind the current_band
      ixgbe: correctly add and remove napi queues
      ixgbe: whitespace/formatting cleanup
      igb: fix tx data corruption with transition to L0s on 82575

Alexander Graf (1):
      KVM: Ignore DEBUGCTL MSRs with no effect

Alexander Schmidt (1):
      IB/ehca: Generate flush status CQ entries

Alexander van Heukelum (55):
      x86, 64-bit, dwarf2: push pushes 8 bytes and popf pops 8
      i386: remove kprobes' restore_interrupts in favour of conditional_s=
ti
      i386: prepare to convert exceptions to interrupts
      i386: convert hardware exception 0 to an interrupt gate
      i386: expand exception 3 DO_TRAP macro
      i386: convert hardware exception 4 to an interrupt gate
      i386: convert hardware exception 5 to an interrupt gate
      i386: convert hardware exception 6 to an interrupt gate
      i386: convert hardware exception 7 to an interrupt gate
      i386: convert hardware exception 9 to an interrupt gate
      i386: convert hardware exception 10 to an interrupt gate
      i386: convert hardware exception 11 to an interrupt gate
      i386: convert hardware exception 12 to an interrupt gate
      i386: convert hardware exception 13 to an interrupt gate
      i386: convert hardware exception 15 to an interrupt gate
      i386: convert hardware exception 16 to an interrupt gate
      i386: convert hardware exception 17 to an interrupt gate
      i386: convert hardware exception 18 to an interrupt gate
      i386: convert hardware exception 19 to an interrupt gate
      i386: remove temporary DO_TRAP macros, expanding the last one used
      i386: add TRACE_IRQS_OFF to entry_32.S in 'error_code'
      i386: add TRACE_IRQS_OFF for exception 1 (debug)
      i386: add TRACE_IRQS_OFF for the nmi
      i386: add TRACE_IRQS_OFF for the exception 3 (int3)
      i386: trace_hardirqs_fixup should now not be necessary: irqs are of=
f.
      traps: x86_64: add TRACE_IRQS_OFF in error_entry
      traps: x86_64: add TRACE_IRQS_OFF in paranoidentry macro
      traps: x86_64: remove trace_hardirqs_fixup from DO_ERROR_INFO macro
      traps: x86_64: remove trace_hardirqs_fixup from int3 handler
      traps: x86_64: remove trace_hardirqs_fixup from debug handler
      traps: x86: remove trace_hardirqs_fixup from pagefault handler
      traps: i386: make do_trap more like x86_64
      i386: split out dumpstack code from traps_32.c
      x86_64: split out dumpstack code from traps_64.c
      x86, traps: split out math_error and simd_math_error
      x86, traps, i386: factor out lazy io-bitmap copy
      x86, traps: introduce dotraplinkage
      x86, traps: converge do_debug handlers
      traps: x86: converge trap_init functions
      traps: x86_64: make math_state_restore more like i386
      traps: i386: use preempt_conditional_sti/cli in do_int3
      traps: x86_64: make io_check_error equal to the one on i386
      traps: i386: expand clear_mem_error and remove from mach_traps.h
      traps: x86_64: use task_pid_nr(tsk) instead of tsk->pid in do_gener=
al_protection
      traps: x86: various noop-changes preparing for unification of traps=
_xx.c
      traps: x86: make traps_32.c and traps_64.c equal
      traps: x86: finalize unification of traps.c
      dumpstack: x86: move die_nmi to dumpstack_32.c
      dumpstack: x86: make printk_address equal
      dumpstack: x86: add "end" parameter to valid_stack_ptr and print_co=
ntext_stack
      dumptrace: x86: consistently include loglevel, print stack switch
      dumpstack: x86: use log_lvl and unify trace formatting
      dumpstack: i386: make kstack=3D an early boot-param and add oops=3D=
panic
      dumpstack: x86: various small unification steps
      dumpstack: x86: various small unification steps, fix

Alexey Dobriyan (104):
      x86_64: remove empty lines from stack traces/oopses
      net: more #ifdef CONFIG_COMPAT
      [JFFS2] Move JFFS2 config options out of fs/Kconfig
      x86 setup: remove remnants of CONFIG_VIDEO_SELECT (read: vga=3D)
      x86: make setup_xstate_init() __init
      softirq: allocate less vectors
      ext4: fix #11321: create /proc/ext4/*/stats more carefully
      netns bridge: allow bridges in netns!
      netns bridge: cleanup bridges during netns stop
      seccomp: drop now bogus dependency on PROC_FS
      x86: simpler SYSVIPC_COMPAT definition
      netfilter: netns: remove nf_*_net() wrappers
      netfilter: netns: ip6table_raw in netns for real
      netfilter: netns: ip6table_mangle in netns for real
      netfilter: netns: ip6t_REJECT in netns for real
      netfilter: netns nf_conntrack: add netns boilerplate
      netfilter: netns nf_conntrack: add ->ct_net -- pointer from conntra=
ck to netns
      netfilter: netns nf_conntrack: per-netns conntrack count
      netfilter: netns nf_conntrack: per-netns conntrack hash
      netfilter: netns: fix {ip,6}_route_me_harder() in netns
      netfilter: netns nf_conntrack: per-netns expectations
      netfilter: netns nf_conntrack: per-netns unconfirmed list
      netfilter: netns nf_conntrack: pass netns pointer to nf_conntrack_i=
n()
      netfilter: netns nf_conntrack: pass netns pointer to L4 protocol's =
->error hook
      netfilter: netns nf_conntrack: per-netns /proc/net/nf_conntrack, /p=
roc/net/stat/nf_conntrack
      netfilter: netns nf_conntrack: per-netns /proc/net/nf_conntrack_exp=
ect
      netfilter: netns nf_conntrack: per-netns /proc/net/ip_conntrack, /p=
roc/net/stat/ip_conntrack, /proc/net/ip_conntrack_expect
      netns: export netns list
      netfilter: netns nf_conntrack: unregister helper in every netns
      netfilter: netns nf_conntrack: cleanup after L3 and L4 proto unregi=
ster in every netns
      netfilter: netns nf_conntrack: pass conntrack to nf_conntrack_event=
_cache() not skb
      netfilter: netns nf_conntrack: per-netns event cache
      netfilter: netns nf_conntrack: per-netns statistics
      netfilter: netns nf_conntrack: per-netns /proc/net/stat/nf_conntrac=
k, /proc/net/stat/ip_conntrack
      netfilter: netns nf_conntrack: per-netns net.netfilter.nf_conntrack=
_count sysctl
      netfilter: netns nf_conntrack: per-netns net.netfilter.nf_conntrack=
_checksum sysctl
      netfilter: netns nf_conntrack: per-netns net.netfilter.nf_conntrack=
_log_invalid sysctl
      netfilter: netns nf_conntrack: per-netns conntrack accounting
      netfilter: netns nf_conntrack: final netns tweaks
      netfilter: netns nf_conntrack: SIP conntracking in netns
      netfilter: netns nf_conntrack: H323 conntracking in netns
      netfilter: netns nf_conntrack: GRE conntracking in netns
      netfilter: netns nf_conntrack: PPTP conntracking in netns
      netfilter: netns nat: fix ipt_MASQUERADE in netns
      netfilter: netns nat: per-netns NAT table
      netfilter: netns nat: per-netns bysource hash
      netfilter: netns nf_conntrack: fixup DNAT in netns
      netfilter: netns nat: PPTP NAT in netns
      netfilter: enable netfilter in netns
      proc: fix return value of proc_reg_open() in "too late" case
      proc: proc_sys_root tweak
      proc: remove dummy vmcore_open()
      proc: remove unused get_dma_list()
      proc: move PROC_PAGE_MONITOR to fs/proc/Kconfig
      proc: remove now unneeded ADDBUF macro
      proc: remove kernel.maps_protect
      s390: claw compile fixlet
      netns: mib6 section fixlet
      netns: fix net_generic array leak
      netns: correct mib stats in ip6_route_me_harder()
      modules: fix module "notes" kobject leak
      alpha: notify_cpu_starting() compile fixlet
      COMPAT_BINFMT_ELF definition tweak
      proc: move sysrq-trigger out of fs/proc/
      sysctl: simplify ->strategy
      netfilter: xt_iprange: fix range inversion match
      netfilter: xt_recent: use proc_create_data()
      fs/Kconfig: move CIFS out
      fs/Kconfig: move ext2, ext3, ext4, JBD, JBD2 out
      anondev: init IDR statically
      anondev: switch to IDA
      proc: proc_init_inodecache() can't fail
      proc: spread __init
      proc: switch /proc/loadavg to seq_file
      proc: switch /proc/uptime to seq_file
      proc: switch /proc/meminfo to seq_file
      proc: switch /proc/version to seq_file
      proc: move /proc/hardware to m68k-specific code
      proc: move /proc/stram to m68k-specific code
      proc: move /proc/filesystems to fs/filesystems.c
      proc: switch /proc/cmdline to seq_file
      proc: move /proc/execdomains to kernel/exec_domain.c
      proc: remove remnants of ->read_proc in proc_misc.c
      proc: move /proc/kmsg creation to fs/proc/kmsg.c
      proc: move rest of /proc/locks to fs/locks.c
      proc: move /proc/devices code to fs/proc/devices.c
      proc: move /proc/cpuinfo code to fs/proc/cpuinfo.c
      proc: move rest of /proc/partitions code to block/genhd.c
      proc: move /proc/stat to fs/proc/stat.c
      proc: move /proc/interrupts boilerplate code to fs/proc/interrupts.=
c
      proc: move /proc/slab_allocators boilerplate to mm/slab.c
      proc: move /proc/slabinfo boilerplate to mm/slub.c, mm/slab.c
      proc: move /proc/vmallocinfo to mm/vmalloc.c
      proc: move /proc/buddyinfo boilerplate to mm/vmstat.c
      proc: move /proc/pagetypeinfo boilerplate to mm/vmstat.c
      proc: move /proc/vmstat boilerplate to mm/vmstat.c
      proc: move /proc/zoneinfo boilerplate to mm/vmstat.c
      proc: move /proc/diskstats boilerplate to block/genhd.c
      proc: move /proc/modules boilerplate to kernel/module.c
      proc: move /proc/schedstat boilerplate to kernel/sched_stats.h
      proc: move all /proc/kcore stuff to fs/proc/kcore.c
      proc: move pagecount stuff to fs/proc/page.c
      proc: move /proc/vmcore creation to fs/proc/vmcore.c
      proc: remove fs/proc/proc_misc.c

Alexey Klimov (7):
      V4L/DVB (9101): radio-mr800: Add driver for AverMedia MR 800 USB FM=
 radio devices
      V4L/DVB (9151): dsbr100: Add returns and fix codingstyle for vidioc=
_s_ctrl
      V4L/DVB (9152): radio-zoltrix: Add checking for frequency
      V4L/DVB (9303): dsbr100: Correct bus_info string
      V4L/DVB (9304): dsbr100: CodingStyle issue
      V4L/DVB (9305): radio-mr800: Add BKL for usb_amradio_open()
      V4L/DVB (9306): dsbr100: Add frequency check

Alexey Kopytko (2):
      [ARM] Orion: Add Buffalo Linkstation Mini support
      [ARM] Orion: Add Buffalo Linkstation Mini power-off method

Alexey Korolev (2):
      [MTD] [NOR] Add qry_mode_on()/qry_omde_off() to deal with odd chips
      [MTD] [NAND] Fix missing kernel-doc

Alexey Starikovskiy (5):
      ACPI: EC: do transaction from interrupt context
      ACPI: EC: Rename some variables
      ACPI: acpi_driver_data could only be applied to acpi_device
      ACPI: EC: Check for IBF=3D0 periodically if not in GPE mode
      ACPICA: add preemption point after each opcode parse

Alfred E. Heggestad (1):
      Input: add driver for USB VoIP phones with CM109 chipset

Alok Kataria (1):
      x86: VMI, initialize IRQ vector

Ameya Palande (1):
      intel-iommu: typo fix and correct word in the comment

Amit K. Arora (1):
      sched: minor optimizations in wake_affine and select_task_rq_fair

Amit Shah (5):
      KVM: Introduce kvm_set_irq to inject interrupts in guests
      KVM: Device assignment: Check for privileges before assigning irq
      KVM: SVM: Fix typo
      KVM: Use kvm_set_irq to inject interrupts
      KVM: Device Assignment: Free device structures if IRQ allocation fa=
ils

Anders Grafstr=C3=B6m (2):
      [MTD] [NOR] cfi_cmdset_0001: Timeouts for erase, write and unlock o=
perations
      [ARM] 5310/1: Fix cache flush functions for ARMv4

Anders Kaseorg (1):
      ftrace: make ftrace_test_p6nop disassembler-friendly

Anderson Lizardo (7):
      wusb: fix error path for wusb_set_dev_addr()
      wusb: fix bmRequestType for Abort RPipe request
      uwb: Fix handling IEs with empty IE data in uwb_est_get_size()
      uwb: disable command/event filtering for D-Link DUB-1210
      uwb: add Intel i1480 HWA to the UWB RC quirk table
      uwb: i1480: remove MAC/PHY information checking function
      uwb: i1480/GUWA100U: fix firmware download issues

Andi Kleen (20):
      tcp: Skip empty hash buckets faster in /proc/net/tcp
      inet_diag: Add empty bucket optimization to inet_diag too
      x86: drop -funroll-loops for csum_partial_64.c
      x86: capitalize function call interrupts consistently
      mISDN: misc timerdev fixes
      ext4: Avoid double dirtying of super block in ext4_put_super()
      oprofile: drop const in num counters field
      oprofile: Don't report Nehalem as core_2
      oprofile: Implement Intel architectural perfmon support
      oprofile: discover counters for op ppro too
      Add kerneldoc documentation for new printk format extensions
      Add a reference to paper to SubmittingPatches
      Make the taint flags reliable
      SubmittingPatches: add a reference to Andi's OLS paper
      Add kerneldoc documentation for new printk format extensions
      Fix documentation of sysrq-q
      Fix documentation of sysrq-q
      PCI: Document that most pci options are shared between i386 and x86=
-64
      Remove stop_machine during module load v2
      MCE: Don't run 32bit machine checks with interrupts on

Andre Detsch (2):
      powerpc/spufs: Improve search of node for contexts with SPU affinit=
y
      powerpc/spufs: Explain conditional decrement of aff_sched_count

Andre Haupt (1):
      pc8736x_gpio: add support for PC87365 chips

Andre Noll (6):
      md: linear.c: Fix typo in comment.
      md: linear.c: Remove pointless initialization of curr_offset.
      md: linear.c: Remove broken debug code.
      md: linear: Represent dev_info->size and dev_info->offset in sector=
s.
      md: linear.c: Make two local variables sector-based.
      md: Convert remaining 1k representations in linear.c to sectors.

Andrea Righi (3):
      x86, oprofile: BUG: using smp_processor_id() in preemptible code
      [CPUFREQ] Fix BUG: using smp_processor_id() in preemptible code
      documentation: clarify dirty_ratio and dirty_background_ratio descr=
iption

Andrea Shepard (1):
      sparc64: Fix race in arch/sparc64/kernel/trampoline.S

Andreas Herrmann (9):
      x86: compile pat debugfs interface only if CONFIG_X86_PAT is set
      x86: pda_init(): fix memory leak when using CPU hotplug
      x86: cpu_init(): fix memory leak when using CPU hotplug
      x86: hpet: modify IXP400 quirk to enable interrupts
      x86: SB450: skip IRQ0 override if it is not routed to INT2 of IOAPI=
C
      x86: SB600: skip ACPI IRQ0 override if it is not routed to INT2 of =
IOAPIC
      amd_iommu: fix nasty bug that caused ILLEGAL_DEVICE_TABLE_ENTRY err=
ors
      x86: SB600: skip IRQ0 override if it is not routed to INT2 of IOAPI=
C
      x86: call dmi-quirks for HP Laptops after early-quirks are executed

Andreas Mohr (2):
      ALSA: als4000 - Code clean up
      ALSA: ALS4000 driver work, step 2

Andreas Oberritter (1):
      8139too: move wmb before TX DMA start

Andres Salomon (4):
      Input: psmouse - export psmouse_set_state for ps/2 extensions to us=
e
      Input: psmouse - add psmouse_queue_work() for ps/2 extension to mak=
e use of
      Input: psmouse - tweak PSMOUSE_DEFINE_ATTR to support raw set callb=
acks
      Input: psmouse - add OLPC touchpad driver

Andrew G. Harvey (1):
      UIO: Fix mapping of logical and virtual memory

Andrew Kilkenny (1):
      edac mpc85xx: add support for mpc8572

Andrew Morton (25):
      x86, ptrace: PEBS support, warning fix
      arch/x86/pci/irq.c: attempt to clean up code layout
      dlm: choose better identifiers
      softlockup: Documentation/sysctl/kernel.txt: fix softlockup_thresh =
description
      drivers/dma/dmatest.c: switch a GFP_ATOMIC to GFP_KERNEL
      drivers/rtc/Kconfig: don't build rtc-cmos.o on sparc32
      sched: clarify ifdef tangle
      drivers/net/mlx4/alloc.c needs mm.h
      ERROR: code indent should use tabs where possible
      V4L/DVB (9033): drivers/media/video/tda9840.c: unbreak
      serial-make-uart_ports-ioport-unsigned-long-fix
      misdn: use nonseekable_open()
      kbuild: ftrace: don't assume that scripts/recordmcount.pl is execut=
able
      fix warning: "x86: sparse_irq needs spin_lock in allocations"
      sysfs: crash debugging
      mm/page_alloc.c:free_area_init_nodes() fix inappropriate use of enu=
m
      kernel/sys.c: improve code generation
      applicom.c: fix apparently-broken code in do_ac_read()
      drivers/char/tpm/tpm.c: fix error-path memory leak
      hwmon: (max1619) Use inline functions instead of macros
      mfd: ucb1400 needs GPIO
      mfd: further unbork the ucb1400 ac97_bus dependencies
      drivers/hwmon/applesmc.c: remove unneeded casts
      drivers/rtc/rtc-bq4802.c: don't use BIN_2_BCD and BCD_2_BIN
      sh: Kill off duplicate remove_memory() definition.

Andrew Patterson (6):
      Wrapper for lower-level revalidate_disk routines.
      Adjust block device size after an online resize of a disk.
      Check for device resize when rescanning partitions
      SCSI sd driver calls revalidate_disk wrapper.
      Added flush_disk to factor out common buffer cache flushing code.
      Call flush_disk() after detecting an online resize.

Andrew Vasquez (6):
      [SCSI] fc_transport: Add an API to allow an LLD to create vports
      [SCSI] qla2xxx: Change GFP_ATOMIC to GFP_KERNEL for non-atomic allo=
cations.
      [SCSI] qla2xxx: Add Flash Layout Table support.
      [SCSI] qla2xxx: Add NPIV-Config Table support.
      [SCSI] qla2xxx: Additional residual-count corrections during UNDERR=
UN handling.
      [SCSI] qla2xxx: Update version number to 8.02.01-k8.

Andrew Victor (14):
      [ARM] 5257/2: [AT91] Use SZ_ definitions and MTDPART_OFS_NXTBLK ins=
tead of hex-values
      [ARM] 5258/1: [AT91] PWM controller initialization
      [ARM] 5259/2: [AT91] PWM LEDs on AT91SAM9263-EK
      [ARM] 5260/1: [AT91] Touchscreen on AT91SAM9RL
      [ARM] 5262/2: [AT91] Support for GPIO-connected buttons on SAM9260-=
EK board
      [ARM] 5263/2: [AT91] GPIO buttons as wakeup sources
      [ARM] 5264/2: [AT91] Suspend-to-RAM disables main oscillator
      [ARM] 5265/3: [AT91] Add copyright info
      [ARM] 5261/1: [AT91] Support for LEDs on Conitec ARM&EVA board
      [ARM] 5267/1: [AT91] Name conflict in mach-at91/leds.c
      [ARM] 5296/1: [KS8695] Replace macro's with trailing underscores.
      [ARM] 5297/1: [KS8695] Fix two compile-time warnings
      AT91: atmel_pwm only available for certain AT91 processors
      rtc-at91rm9200: remove now-unneeded code

Andrey Borzenkov (4):
      x86: fix ghost EDD devices in /sys again
      x86 setup: fix ghost entries under /sys/firmware/edd take 3
      orinoco: fix unsafe locking in orinoco_cs_resume
      orinoco: reduce stack usage in firmware download path

Andrey Yurovsky (1):
      ath5k: add Mesh Point support

Andy Adamson (1):
      NFS: use correct fs type for v4 submounts and referrals

Andy Fleming (1):
      gianfar: free/iounmap memory after an error in mii bus initializati=
on

Andy Henroid (1):
      i7300_idle driver v1.55

Andy Walls (17):
      V4L/DVB (8770): cx18: get rid of ununsed buffers stolen field
      V4L/DVB (8771): cx18: Remove redundant struct cx18_queue length mem=
ber.
      V4L/DVB (8772): cx18: Convert cx18_queue buffers member to atomic_t
      V4L/DVB (8773): cx18: Fix cx18_find_handle() and add error checking
      V4L/DVB (8774): cx18: Have CX23418 release buffers at end of captur=
e.
      V4L/DVB (8912): cx18: Correct CX23418 PCI configuration settings.
      V4L/DVB (8913): cx18: Create cx18_ specific wrappers for all pci mm=
io accessesors.
      V4L/DVB (8914): cx18: Throttle mmio to/from the CX23418 so boards w=
ork in older systems
      V4L/DVB (8915): cx18: Increment u8 pointers not void pointers.
      V4L/DVB (8924): cx18: Set mmio throttling delay default to 0 nsec.
      V4L/DVB (9110): cx18: Add default behavior of checking and retrying=
 PCI MMIO accesses
      V4L/DVB (9111): cx18: Up the version to 1.0.1
      V4L/DVB (9131): cx18: Add entries for the Leadtek PVR2100 and Toshi=
ba Qosmio DVB-T/Analog
      V4L/DVB (9132): cx18: Fix warning message for DMA done notification=
 for inactive stream.
      V4L/DVB (9297): cx18: Fix memory leak on card initialization failur=
e
      V4L/DVB (9298): cx18: Add __iomem address space qualifier to cx18_l=
og_*_retries() argument
      V4L/DVB (9299): cx18: Don't mask many real init error codes by mapp=
ing them to ENOMEM

Andy Whitcroft (37):
      checkpatch: square brackets -- exemption for array slices in braces
      checkpatch: values: double ampersand may be unary
      checkpatch: conditional indent -- labels have different indent rule=
s
      checkpatch: switch indent allow plain return
      checkpatch: add tests for the attribute matcher
      checkpatch: ____cacheline_aligned et al are modifiers
      checkpatch: complex macros -- fix up extension handling
      checkpatch: fix up comment checks search to scan the entire block
      checkpatch: include/asm checks should be anchored
      checkpatch: reduce warnings for #include of asm/foo.h to check from=
 arch/bar.c
      checkpatch: report any absolute references to kernel source files
      checkpatch: report the real first line of all suspect indents
      checkpatch: suspect indent -- skip over preprocessor, label and bla=
nk lines
      checkpatch: %Lx tests should hand %% as a literal
      checkpatch: report the correct lines for single statement blocks
      checkpatch: perform indent checks on perl
      checkpatch: version: 0.22
      checkpatch: case/default checks should only check changed lines
      checkpatch: suppress errors triggered by short patch
      checkpatch: handle comment/quote nesting correctly
      checkpatch: check line endings in text format files
      checkpatch: suspect indent count condition lines correctly
      checkpatch: ensure we only apply checks to the lines within hunks
      checkpatch: version: 0.23
      checkpatch: do is not a possible type
      checkpatch: labels are not possible types
      checkpatch: handle do without braces if we have enough context
      checkpatch: macros which define structure members are not complex
      checkpatch: accept any sized le/be type
      checkpatch: pull out known acceptable typedefs
      checkpatch: suspect code indent must stop at #else/#elif
      checkpatch: complex macros checks miss square brackets
      checkpatch: DEFINE_ macros are real definitions for exports
      checkpatch: trailing statements ensure we report the end of the lin=
e
      checkpatch: suspect indent handle macro continuation
      checkpatch: allow for comments either side of a brace on case
      checkpatch: version: 0.24

Aneesh Kumar K.V (22):
      ext4: invalidate pages if delalloc block allocation fails.
      ext4: Make sure all the block allocation paths reserve blocks
      ext4: Retry block reservation
      ext4: Add percpu dirty block accounting.
      ext4: Switch to non delalloc mode when we are low on free blocks co=
unt.
      ext4: Signed arithmetic fix
      ext4: Fix ext4 nomballoc allocator for ENOSPC
      ext4: Don't add the inode to journal handle until after the block i=
s allocated
      ext4: Retry block allocation if we have free blocks left
      ext4: truncate block allocated on a failed ext4_write_begin
      ext4: Properly update i_disksize.
      ext4: elevate write count for migrate ioctl
      ext4: hook the ext3 migration interface to the EXT4_IOC_SETFLAGS io=
ctl
      ext4: Free ext4_prealloc_space using kmem_cache_free
      ext4: Do mballoc init before doing filesystem recovery
      ext4: Use an rbtree for tracking blocks freed during transaction.
      ext4: Don't reuse released data blocks until transaction commits
      ext4: Use tag dirty lookup during mpage_da_submit_io
      vfs: Remove the range_cont writeback mode.
      vfs: Add no_nrwrite_index_update writeback control flag
      ext4: Fix file fragmentation during large file write.
      ext3: truncate block allocated on a failed ext3_write_begin

Anna Neal (2):
      libertas: Improvements on automatic tx power control via SIOCSIWTXP=
OW.
      libertas: Improvements on automatic tx power control via SIOCSIWTXP=
OW (fixups)

Anssi Hannula (1):
      HID: fix a lockup regression when using force feedback on a PID dev=
ice

Antoine Jacquet (7):
      V4L/DVB (8731): zr364xx: remove BKL
      V4L/DVB (8732): zr364xx: handle video exclusive open internaly
      V4L/DVB (8734): Initial support for AME DTV-5100 USB2.0 DVB-T
      V4L/DVB (8735): dtv5100: replace dummy frontend by zl10353
      V4L/DVB (8736): dtv5100: CodingStyle cleanups
      V4L/DVB (8738): dtv5100: remove old definition from header
      V4L/DVB (8739): dtv5100: remove prohibited space...

Anton Blanchard (1):
      V4L/DVB (8654): cxusb: add support for DViCO FusionHDTV DVB-T Dual =
Digital 4 (rev 2)

Anton Vorontsov (19):
      genirq: fix irq_desc->depth handling with DEBUG_SHIRQ
      powerpc/83xx: mpc836x_mds: add support for the nor flash
      powerpc/fsl_soc: remove mpc83xx_wdt code
      OF: add fsl,mcu-mpc8349emitx to the exception list
      powerpc: Fix no interrupt handling in pata_of_platform
      [MTD] [NAND] fsl_upm: update driver for the new OF bindings
      of: Add new helper of_parse_phandles_with_args()
      powerpc/QE: move QE_GPIO Kconfig symbol into the platforms/Kconfig
      powerpc/83xx: don't probe broken PCI on mpc837x_mds boards
      powerpc/83xx: add DS1374 RTC support for the MPC837xE-MDS boards
      OF: add fsl,mcu-mpc8349emitx to the exception list
      i2c: MPC8349E-mITX Power Management and GPIO expander driver
      powerpc/83xx: add NAND support for the MPC8360E-RDK boards
      powerpc: fix fsl_upm nand driver modular build
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6
      powerpc: Remove device_type =3D "board_control" properties in .dts =
files
      powerpc/83xx: Add support for MCU microcontroller in .dts files
      powerpc/83xx: Add DS1339 RTC support for MPC8349E-mITX boards .dts
      i2c: Add info->archdata field

Antonio Ospite (2):
      HID: hiddev.h: Fix mixed space and tabs in example code.
      HID: hiddev.h: Fix example code.

Antti Palosaari (12):
      V4L/DVB (8970): mt2060: implement I2C-gate control
      V4L/DVB (8971): initial driver for af9013 demodulator
      V4L/DVB (8972): initial driver for af9015 chipset
      V4L/DVB (8973): af9013: fix compile error coming from u64 div
      V4L/DVB (8975): af9015: cleanup
      V4L/DVB (8976): af9015: Add USB ID for AVerMedia A309
      V4L/DVB (9140): anysee: unlock I2C-mutex in error case
      V4L/DVB (9141): anysee: support for Anysee E30 Combo Plus
      V4L/DVB (9143): af9015: fix wrong GPIO
      V4L/DVB (9144): af9015: enable Maxlinear mxl5005s tuner RSSI
      V4L/DVB (9145): af901x: clean-up
      V4L/DVB (9146): af901x: fix some compiler errors and warnings

Aristeu Rozanski (5):
      Input: add keycodes for remote controls/phone keypads
      x86, NMI watchdog: when booting with reset_devices, clear the perfo=
rmance counters
      x86, NMI watchdog: setup before enabling NMI watchdog
      edac i5000: fix error messages
      edac i5000: fix thermal issues

Arjan van de Ven (57):
      select: Introduce a hrtimeout function
      select: switch select() and poll() over to hrtimers
      hrtimer: add abstraction functions for accessing the "expires" memb=
er
      hrtimer: convert kvm to the new hrtimer apis
      hrtimer: convert timerfd to the new hrtimer apis
      hrtimer: convert net::sched_cbq to the new hrtimer apis
      hrtimer: convert kernel/* to the new hrtimer apis
      hrtimer: convert powerpc/oprofile to the new hrtimer apis
      hrtimer: convert kvm-ia64 to the new hrtimer apis
      hrtimer: convert s390 to the new hrtimer apis
      hrtimer: convert sound/ to the new hrtimer apis
      hrtimer: rename the "expires" struct member to avoid accidental usa=
ge
      hrtimer: turn hrtimers into range timers
      hrtimer: create a "timer_slack" field in the task struct
      hrtimer: make select() and poll() use the hrtimer range feature
      hrtimer: fix build bug found by Ingo
      hrtimer: another build fix
      hrtimer: add a hrtimer_start_range() function
      hrtimer: incorporate feedback from Peter Zijlstra
      hrtimer: show the timer ranges in /proc/timer_list
      hrtimer: fix signed/unsigned bug in slack estimator
      warn: Turn the netdev timeout WARN_ON() into a WARN()
      hrtimer: make the nanosleep() syscall use the per process slack
      hrtimer: make the futex() system call use the per process slack val=
ue
      hrtimer: peek at the timer queue just before going idle
      x86: print DMI information in the oops trace
      x86: use round_jiffies() for the corruption check timer
      select: fix alpha OSF wrapper
      select: fix alpha OSF wrapper
      rangetimer: fix x86 build failure for the !HRTIMERS case
      netdev: uniquify the tx_timeout name
      security: avoid calling a NULL function pointer in drivers/video/tv=
audio.c
      rangetimer: fix BUG_ON reported by Ingo
      Add a script to visualize the kernel boot process / time
      fastboot: fix issues and improve output of bootgraph.pl
      fastboot: make the raid autodetect code wait for all devices to ini=
t
      fastboot: make the RAID autostart code print a message just before =
waiting
      raid: make RAID autodetect default a KConfig option
      rangetimers: fix the bug reported by Ingo for real
      tracing/fastboot: add a script to visualize the kernel boot process=
 / time
      tracing/fastboot: fix printk format typo in boot tracer
      tracing/fastboot: fix issues and improve output of bootgraph.pl
      tty: make sure that proc_clear_tty stores the cpu flags
      device model: Do a quickcheck for driver binding before doing an ex=
pensive check
      debug: Introduce a dev_WARN() function
      debug: use dev_WARN() rather than WARN_ON() in device_pm_add()
      usb: turn dev_warn+WARN_ON combos into dev_WARN
      Merge commit 'linus/master' into merge-linus
      usbmon: fix tiny race exposed by the fastboot patches
      PCI: introduce an pci_ioremap(pdev, barnr) function
      fix WARN() for PPC
      mfd: use pci_ioremap_bar() in sm501
      i2c: Use pci_ioremap_bar()
      fs: add a sanity check in d_free
      proc: use WARN() rather than printk+backtrace
      pci: use pci_ioremap_bar() in drivers/ide
      ide: two more pci_ioremap_bar() conversions

Arnaldo Carvalho de Melo (2):
      net: Use hton[sl]() instead of __constant_hton[sl]() where applicab=
le
      inet_hashtables: Add inet_lookup_skb helpers

Arnaud Ebalard (1):
      xfrm: MIGRATE enhancements (draft-ebalard-mext-pfkey-enhanced-migra=
te)

Arnaud Patard (2):
      fastboot: Fix bootgraph.pl initcall name regexp
      tracing/fastboot: fix bootgraph.pl initcall name regexp

Artem Bityutskiy (11):
      UBI: remove BKL
      UBIFS: add a print, fix comments and more minor stuff
      UBIFS: inline one-line functions
      UBIFS: check data CRC when in error state
      UBIFS: use bit-fields when possible
      UBIFS: fix races in bit-fields
      UBIFS: fix commentary
      UBIFS: update dbg_dump_inode
      UBIFS: correct comment for commit_on_unmount
      UBIFS: commit on sync_fs
      UBIFS: amend printk

Arthur Jones (1):
      e1000e: release hw semaphore after successfully writing EEPROM

Arun KS (6):
      ALSA: ASoC: Add TLV320AIC23 codec driver
      ALSA: ASoC: Add support for osk5912
      ALSA: ASoC: Add DSP DAI format support to the OMAP McBSP driver
      ALSA: ASoC: Add custom SOC_SINGLE_TLV for tlv320aic23 codec
      ALSA: ASoC: Add destination and source port for DMA on OMAP1
      ALSA: ASoC: Fix compile-time warning for tlv320aic23.c

Atsushi Nemoto (27):
      Input: move map_to_7segment.h to include/linux
      MIPS: RBTX4927: More explicit initialization
      MIPS: TXx9: Improve handling of built-in and command-line args
      MIPS: TXx9: Add prom_getenv
      MIPS: TXx9: Early command-line preprocessing
      MIPS: TXx9: Cache fixup
      MIPS: TXx9: Runtime configuration of timeout-error
      MIPS: TXx9: Add mtd support
      MIPS: TXx9: Raise priority of interrupts for errors, timers, SIO
      MIPS: RBTX4938: Add TOSHIBA_RBTX4938_MPLEX_KEEP
      MIPS: TXx9: Make spi_eeprom.c more generic
      MIPS: TXx9: Default machine_restart using watchdog reset
      MIPS: TXx9: Add board_be_init for TX4927/TX4938
      MIPS: TXx9: Add __init tag for tx4938_pcic1_map_irq.
      MIPS: TXx9: Declare smsc_fdc37m81x_config_get() in smsc_fdc37m81x.h
      MIPS: TXx9: stop_unused_modules
      MIPS: TXx9: Microoptimize interrupt handlers
      MIPS: TXx9: IOC LED support
      MIPS: TXx9: Add TX4939 SoC support
      MIPS: TXx9: Add RBTX4939 board support
      MIPS: TXx9: Implement prom_free_prom_memory
      MIPS: TXx9: Add TX4939 ATA support (v2)
      serial_txx9: use %lx for iobase
      net: Make SMC91X selectable on other MIPS boards
      ide: Add tx4939ide driver (v6)
      TXx9: Add TX4938 ATA support (v3)
      ide: Add tx4938ide driver (v2)

Aurelien Jarno (5):
      MIPS: WGT634U: Add machine detection message
      MIPS: BCM47xx: Remove references to BCM947XX
      MIPS: BCM47xx: Use the new SSB GPIO API
      MIPS: WGT634U: Add reset button support
      MIPS: PCI: Scan busses when they are registered

Austin Zhang (1):
      crypto: crc32c - Use Intel CRC32 instruction

Avi Kivity (37):
      x86: default to reboot via ACPI
      KVM: MMU: Separate the code for unlinking a shadow page from its pa=
rents
      KVM: MMU: Simplify kvm_mmu_zap_page()
      KVM: Move NMI IRET fault processing to new vmx_complete_interrupts(=
)
      KVM: VMX: Move nmi injection failure processing to vm exit path
      KVM: Clear exception queue before emulating an instruction
      KVM: VMX: Fix pending exception processing
      KVM: Add a pending interrupt queue
      KVM: VMX: Move interrupt post-processing to vmx_complete_interrupts=
()
      KVM: Consolidate PIC isr clearing into a function
      KVM: VMX: Unify register save/restore across 32 and 64 bit hosts
      KVM: SVM: Unify register save/restore across 32 and 64 bit hosts
      KVM: VMX: Avoid vmwrite(HOST_RSP) when possible
      KVM: Add irq ack notifier list
      KVM: VMX: Use interrupt queue for !irqchip_in_kernel
      KVM: Simplify exception entries by using __ASM_SIZE and _ASM_PTR
      KVM: Handle spurious acks for PIT interrupts
      KVM: VMX: Change cs reset state to be a data segment
      KVM: VMX: Change segment dpl at reset to 3
      KVM: Load real mode segments correctly
      KVM: x86 emulator: remove bad ByteOp specifier from NEG descriptor
      KVM: MMU: Move SHADOW_PT_INDEX to mmu.c
      KVM: MMU: Unify direct map 4K and large page paths
      KVM: MMU: Infer shadow root level in direct_map()
      KVM: MMU: Add generic shadow walker
      KVM: MMU: Convert direct maps to use the generic shadow walker
      KVM: MMU: Convert the paging mode shadow walk to use the generic wa=
lker
      KVM: Allocate guest memory as MAP_PRIVATE, not MAP_SHARED
      KVM: Don't call get_user_pages(.force =3D 1)
      KVM: MMU: Account for npt/ept/realmode page faults
      KVM: MMU: Add locking around kvm_mmu_slot_remove_write_access()
      KVM: MMU: Flush tlbs after clearing write permission when accessing=
 dirty log
      KVM: MMU: Fix setting the accessed bit on non-speculative sptes
      KVM: SVM: No need to unprotect memory during event injection when u=
sing npt
      KVM: Add statistics for guest irq injections
      KVM: x86 emulator: fix jmp r/m64 instruction
      MAINTAINERS: Update Avi Kivity's email address

Ayaz Abdulla (1):
      forcedeth fix: take phy out of reset during power up

Badari Pulavarty (2):
      ecryptfs: convert to use new aops
      mm: cleanup to make remove_memory() arch-neutral

Balbir Singh (1):
      memrlimit: cgroup mm owner callback changes to add task info

Barry Kasindorf (4):
      oprofile: Add support for AMD Family 11h
      x86/oprofile: add IBS support for AMD CPUs, IBS buffer handling rou=
tines
      x86/oprofile: add IBS support for AMD CPUs, model specific code
      OProfile: Fix buffer synchronization for IBS

Bartlomiej Zolnierkiewicz (143):
      ide: remove superfluous check from ide_disk_special()
      ide: cleanup ide_disk_init_mult_count()
      ide: cleanup ide_fix_driveid()
      ide: make drive->id an union (take 2)
      ide: remove drive->driveid
      ide: use ata_id_current_chs_valid()
      ide-disk: use ata_id_wcache_enabled()
      ide-disk: use ata_id_hpa_enabled()
      libata: WIN_* -> ATA_CMD_*
      ide: WIN_* -> ATA_CMD_*
      hd: WIN_* -> ATA_CMD_*
      ide: use ATA_* defines instead of *_STAT and *_ERR ones
      ide: remove no longer needed ide_drive_t fields
      ide: fix EXABYTENEST handling in probe_for_drive()
      ide: enhance ide_busy_sleep()
      ide: remove no longer needed BUG_ON()-s from init_irq()
      ide: remove IDE_CHIPSET_* macros
      ide: remove unused _IDE_C and _IDE_DISK defines
      ide: remove needless drive->present checks from device drivers
      ide: check drive->present in ide_get_paired_drive()
      ide: remove CONFIG_IDEDISK_MULTI_MODE
      ide: include <linux/hdreg.h> only when needed
      ide: call ide_proc_register_driver() later
      ide: preparations for /proc/ide/hd*/settings rework
      ide: /proc/ide/hd*/settings rework
      ide: remove SECTOR_WORDS define
      cmd640: add __set_prefetch_mode()
      ide: remove read-only ->atapi_overlap field from ide_drive_t
      ide: remove ->supports_dsc_overlap field from ide_driver_t
      ide: factor out HDIO_*_NICE ioctl handling to ide_*_nice_ioctl()
      ide: ide_dev_has_iordy() -> ata_id_has_iordy()
      ide: ide_dev_is_sata() -> ata_id_is_sata()
      ide: idedisk_supports_lba48() -> ata_id_lba48_enabled()
      ide: check only for CACHE FLUSH command support in ide_id_has_flush=
_cache()
      ide: ide_id_has_flush_cache() -> ata_id_flush_enabled()
      ide: ide_id_has_flush_cache_ext() -> ata_id_flush_ext_enabled()
      ide: use ata_id_is_cfa()
      ide: ide_id_to_hd_driveid() -> ata_id_to_hd_driveid()
      ide: lba_capacity_is_ok() -> ata_id_is_lba_capacity_ok()
      hpt366: add hpt3xx_disable_fast_irq() helper
      ide: add proper PCI PM support (v2)
      ide: remove ->bus_state field from ide_hwif_t
      ide: add ide_setting_ioctl() helper
      ide: cleanup generic_ide_ioctl()
      ide: move ioctls handling to ide-ioctls.c
      ide: add ide_check_atapi_device() helper
      ide-floppy: remove needless parens
      ide-floppy: add ide_floppy_format_ioctl() helper
      ide-tape: remove idetape_init_rq()
      ide-{floppy,tape}: remove request stack
      ide-{floppy,tape}: remove packet command stack
      ide-floppy: remove MODE_SENSE_* defines
      ide-scsi: cleanup ide_scsi_io_buffers()
      ide: add ide_io_buffers() helper
      ide-floppy: add ide_floppy_set_media_lock() helper
      ide-tape: add ide_tape_set_media_lock() helper
      ide: add ide_init_pc() helper
      ide: add ide_queue_pc_head() helper
      ide: add ide_queue_pc_tail() helper
      ide-floppy: ->{srfp,wp} -> IDE_AFLAG_{SRFP,WP}
      ide-floppy: move floppy ioctls handling to ide-floppy_ioctl.c
      ide: add ide_set_media_lock() helper
      ide: add ide_do_start_stop() helper
      ide: add ide_do_test_unit_ready() helper
      ide: move IDE{FLOPPY,TAPE}_WAIT_CMD defines to <linux/ide.h>
      ide: drop dsc_handle argument from ide_pc_intr()
      ide: add pointer to the current packet command to ide_drive_t
      ide: drop 'timeout' and 'expiry' arguments from ide_pc_intr()
      ide: add request_sense_{pc,rq} to ide_drive_t
      ide: add ide_retry_pc() helper
      ide: add ->pc_{update,io}_buffers methods
      ide: make ide_pc_intr() static
      ide: make ide_transfer_pc() static
      ide: remove CONFIG_BLK_DEV_IDE config option (take 2)
      ide: remove unnecessary MAX_HWIFS checks from ide-probe.c
      ide: fix IDE ACPI for slave device-only configurations
      ide-disk: set_addressing() fixes
      ide-disk: add ide_do_setfeature() helper
      ide: add device flags
      ide: DMA_PIO_RETRY -> IDE_DFLAG_DMA_PIO_RETRY
      ide: remove superfluous ->media field from ide_driver_t
      ide: remove superfluous ->dma field from ide_hwif_t
      ide: remove superfluous ->waiting_for_dma checks
      ide: fix HDIO_DRIVE_TASK[FILE] ioctls for CHS commands on LBA devic=
es
      ide: sanitize ide*_pm_* enums
      cy82c693: remove dead CY82C693_SETDMA_CLOCK code
      cy82c693: remove no longer needed CY82C693_DEBUG_LOGS code
      ide: use 'drive->dn & 1' instead of drive->select.b.unit
      ide: remove [ata_]select_t
      ide: convert 'pio_mode' device setting to use DS_SYNC flag
      ide: factor out reset error reporting from reset_pollfunc()
      ide: merge all TASKFILE_NO_DATA data phase handlers into taskfile_n=
o_intr()
      ide: use unique names for struct pci_driver instances
      ide: ->ide_dma_clear_irq() -> ->clear_irq()
      ide-generic: no need to probe all ports at once
      ide-generic: remove no longer needed ide_probe_legacy()
      ide: remove ide_host_alloc_all()
      ide: set IDE_AFLAG_DRQ_INTERRUPT in do_identify()
      ide-cd: no need to zero drive->special.all
      ide-floppy: move all ioctl handling to ide-floppy_ioctl.c (take 2)
      ide-floppy: move /proc handling to ide-floppy_proc.c (take 2)
      ide-disk: move all ioctl handling to ide-disk_ioctl.c
      ide-disk: move /proc handling to ide-disk_proc.c (take 3)
      pmac: remove superfluous pmif =3D=3D NULL checks
      pmac: remove needless pmac_ide_destroy_dmatable() wrapper
      ide: __ide_dma_end() -> ide_dma_end()
      ide: make ide_dma_lost_irq() available also for CONFIG_BLK_DEV_IDED=
MA_SFF=3Dn
      ide: make ide_dma_timeout() available also for CONFIG_BLK_DEV_IDEDM=
A_SFF=3Dn
      ide: switch to DMA-mapping API part #2
      ide: remove needless includes from ide-dma.c
      ide: cleanup ide_build_dmatable()
      ide: cleanup ide-dma.c
      ide: move SFF DMA code to ide-dma-sff.c
      ide-disk: fix IDE_DFLAG_LBA48 handling on resume
      ide-disk: lock media before checking for media change
      ide-floppy: use alloc_disk_node()
      ide-disk: use to_ide_drv() and ide_drv_g()
      ide-disk: move IDE_DFLAG_DOORLOCKING flag handling to idedisk_set_d=
oorlock()
      ide-{disk,floppy}: set IDE_DFLAG_ATTACH in *_setup()
      ide-floppy: drop 'floppy' argument from idefloppy_setup()
      ide-floppy: use drive->capacity64 for caching current capacity
      ide: IDE_AFLAG_MEDIA_CHANGED -> IDE_DFLAG_MEDIA_CHANGED
      ide: IDE_AFLAG_WP -> IDE_DFLAG_WP
      ide: IDE_AFLAG_FORMAT_IN_PROGRESS -> IDE_DFLAG_FORMAT_IN_PROGRESS
      ide: remove IDE_AFLAG_NO_DOORLOCKING
      ide-disk: factor out generic disk handling code to ide-gd.c
      ide-disk: use IDE_DFLAG_MEDIA_CHANGED
      ide-floppy: factor out generic disk handling code to ide-gd-floppy.=
c
      ide: prepare for merging ide-gd-floppy.c with ide-gd.c
      ide: allow device drivers to specify per-device type /proc settings
      ide: add generic ATA/ATAPI disk driver
      ide: fix support for IDE PCI controllers using MMIO on frv
      ide: remove dead <asm-arm/arch-sa1100/ide.h>
      ide: remove M68K_IDE_SWAPW define from <asm-m68k/ide.h>
      ide: remove unused macros from <asm-parisc/ide.h>
      hpt366: fix compile warning
      ide-floppy: remove idefloppy_floppy_t typedef
      ide: remove broken hpt34x driver
      delkin_cb: add PM support
      ide: re-add TRM290 fix lost during ide_build_dmatable() cleanup
      ide: remove useless subdirs from drivers/ide/
      ide-disk: set non-rotational queue flag for SSD and CF devices
      ide: drivers/ide/generic.c -> drivers/ide/ide-pci-generic.c

Becky Bruce (11):
      powerpc: Rename PTE_SIZE to HPTE_SIZE
      powerpc/85xx: fix build warning, remove silly cast
      cpm_uart: Pass actual dev ptr to dma_* in ucc and cpm_uart serial
      powerpc: Rename dma_64.c to dma.c
      powerpc: Move iommu dma ops from dma.c to dma-iommu.c
      powerpc: Drop archdata numa_node
      powerpc: Merge 32 and 64-bit dma code
      powerpc: Make dma_addr_t a u64 if CONFIG_PHYS_64BIT is set
      POWERPC: Allow 32-bit hashed pgtable code to support 36-bit physica=
l
      powerpc: Drop redundant machine type print in show_cpuinfo
      powerpc: Move memory size print into common show_cpuinfo for 32-bit

Ben Dooks (8):
      drivers/net/bonding: sparse fixes for exported tables
      PATA: RPC now selects HAVE_PATA_PLATFORM for pata platform driver
      [ARM] S3C24XX: Move files out of include/asm-arm/plat-s3c*
      [ARM] S3C24XX: Additional include moves
      [ARM] S3C24XX: Serial driver debug depends on DEBUG_LL
      [ARM] S3C2443: Fix HCLK rate
      spi_s3c24xx: pin configuration updates
      mfd: update sm501 debugging/low information messages

Ben Hutchings (54):
      sfc: Replace net_dev->priv with netdev_priv(net_dev)
      sfc: Change first parameter type of {set,clear}_bit_le() to unsigne=
d
      sfc: Use separate hardware TX queues to select checksum generation
      sfc: Avoid mangling error codes in efx_test_loopback()
      sfc: Reduce delays in SFE4001 initialisation
      sfc: Remove mistaken hardware workaround
      sfc: XMAC statistics fix-ups
      sfc: Remove inclusion of workarounds.h from efx.c
      sfc: Reverse the XOFF/XON pause frame control fifo thresholds
      sfc: Reduce log level for XGXS lane status
      sfc: Self-test reporting cleanup
      sfc: Speed up loopback self-test
      sfc: Don't leak PCI DMA maps in the TSO code when the queue fills u=
p
      sfc: Use pci_map_single() to map the skb header when doing TSO
      sfc: Reduce the size of struct efx_tx_buffer
      sfc: Use explicit bool for boolean variables, parameters and return=
 values
      sfc: Set net_device::vlan_features appropriately
      sfc: Cleaned up struct tso_state fields
      sfc: Removed forced inlining of long functions
      sfc: Export boot configuration in EEPROM through ethtool
      sfc: Move CPU counting for RSS into a separate function, efx_wanted=
_rx_queues()
      sfc: Remove efx_channel::has_interrupt
      sfc: Cleanup RX queue information
      sfc: Remove initialisation of RX_FILTER_CTL_REG.NUM_KER
      sfc: Make efx_for_each_channel_rx_queue() more efficient
      sfc: Remove efx_channel::evqnum field
      sfc: Cleanup RX event processing
      sfc: Implement get_sset_count, replacing get_stats_count and self_t=
est_count
      sfc: Make PHY flash mode a device attribute, not a module parameter
      sfc: Enable TSO for 802.1q VLAN devices
      sfc: Remove efx_nic_dummy_op_int() as redundant with efx_port_dummy=
_op_int()
      sfc: Remove remnants of multi-port abstraction for MAC registers
      sfc: Remove some unreachable error paths
      sfc: Cleanup reset code
      sfc: Rework the bitfield header so that we can identify fields by b=
it number
      sfc: Extend self-tests
      sfc: Remove the STATE_RESETTING flag
      sfc: Rework efx_set_multicast_hash()
      sfc: Add check for memory allocation failure in falcon_probe_nic()
      sfc: Fix memory BAR release call on error path
      sfc: Remove workaround for old firmware bug
      sfc: Serialise tenxpress_special_reset() with statistics fetches
      sfc: Make queue flushes more reliable
      sfc: Stop generating bogus events in tenxpress_check_hw()
      sfc: Insert read memory barrier after checking MAC statistics flag
      sfc: Disable interrupts after a fatal interrupt occurs until reset
      sfc: Remove obsolete comment about PCI modes
      sfc: Use CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS where appropriate
      sfc: Fix type of FALCON_SPI_MAX_LEN
      hwmon: (lm90) Rename temperature conversion functions to match usag=
e
      hwmon: (lm90) Support MAX6646, MAX6647 and MAX6649
      hwmon: (lm87) Fix masking of config register in lm87_init_client()
      hwmon: (lm87) Restore original configuration register on removal
      hwmon: (lm87) Add support for configuration through platform_data

Ben Slusky (1):
      [CPUFREQ] use deferrable delayed work init in conservative governor

Ben-Ami Yassour (4):
      KVM: direct mmio pfn check
      KVM: pci device assignment
      KVM: remove unused field from the assigned dev struct
      KVM: Device Assignment with VT-d

Benjamin Herrenschmidt (27):
      powerpc: Turn get/set_hard_smp_proccessor_id into inlines
      powerpc: Expose PMCs & cache topology in sysfs on 32-bit
      Merge commit 'kumar/kumar-dma'
      Merge commit 'kumar/kumar-mmu'
      Merge commit 'jwb/jwb-next'
      powerpc: Fix sysfs pci mmap on 32-bit machines with 64-bit PCI
      Merge commit 'jk/jk-merge'
      Merge commit 'gcl/gcl-next'
      Merge commit 'kumar/kumar-next'
      powerpc: Fix DMA offset for non-coherent DMA
      powerpc/pci: Improve detection of unassigned bridge resources
      powerpc: Fix link errors on 32-bit machines using legacy DMA
      powerpc: Fix 32-bit SMP boot on CHRP
      powerpc/chrp: Fix detection of Python PCI host bridge on IBM CHRPs
      powerpc: Fix CHRP PCI config access for indirect_pci
      Merge commit 'origin'
      radeonfb: misc cleanup of engine and dst cache handling
      radeonfb: accelerate imageblit and other improvements
      edac cell: fix incorrect edac_mode
      pci: Use new %pR to print resource ranges
      PCI: Add ability to mmap legacy_io on some platforms
      powerpc/PCI: Add legacy PCI access via sysfs
      Merge commit 'jwb/jwb-next'
      Merge commit 'gcl/gcl-next'
      Merge commit 'kumar/kumar-for-2.6.28'
      Merge commit 'origin' into master
      PCI: Workaround invalid P2P bridge bus numbers

Benjamin Li (5):
      bnx2: In bnx2_set_mac_link() return void rather then int
      bnx2: Update MODULE_DESCRIPTION to include the 5716
      bnx2: Remove name field from bnx2 structure
      bnx2: Remove timer_interval field from the bnx2 structure
      bnx2: Handle DMA mapping errors.

Benjamin Marzinski (1):
      dm mpath: use more error codes

Benjamin Thery (1):
      net: fix scheduling of dst_gc_task by __dst_free

Benny Halevy (9):
      nfsd: properly xdr-encode stateid4.seqid as uint32_t for cb_recall
      nfsd: properly xdr-encode deleg stateid returned from open
      nfsd: fix nfsd4_encode_open buffer space reservation
      nfsd: nfs4xdr encode_stateid helper function
      nfsd: don't declare p in ENCODE_SEQID_OP_HEAD
      nfsd: properly xdr-decode NFS4_OPEN_CLAIM_DELEGATE_CUR stateid
      nfsd: nfs4xdr decode_stateid helper function
      nfsd: do_probe_callback should not clear rpc stats
      nfsd: use nfs client rpc callback program

Bernd Schmidt (1):
      Blackfin arch: fixing bug - under IRQ stress, running applications =
may wrongly trigger an ICPLB miss and be killed

Bernd Schubert (1):
      [SCSI] mptfusion: Increase scsi-timeouts, similariy to the LSI 4.x =
driver.

Bernhard Walle (2):
      Document panic_on_unrecovered_nmi sysctl
      Document panic_on_unrecovered_nmi sysctl

Bernhard Weirich (1):
      w1: new driver. DS2431 chip

Bharata B Rao (2):
      sched: call resched_task() conditionally from new task wake up path
      sched: maintain only task entities in cfs_rq->tasks list

Bill Nottingham (1):
      x86_64: be less annoying on boot

Bjoern B. Brandenburg (1):
      sparc: remove unused includes

Bjorn Helgaas (21):
      irda: follow lspci device/vendor style
      [SCSI] qla2xxx: Fix "occured" spelling errors.
      PNP: fix debug formatting (cosmetic)
      PNPACPI: use dev_printk when possible
      PNP: convert the last few pnp_info() uses to printk()
      PNP: use new vsprintf symbolic function pointer format
      PNP: remove some uses of DEBUG ifdef
      PNP: add CONFIG_PNP_DEBUG_MESSAGES and pnp_dbg()
      PNP: convert to using pnp_dbg()
      PNP: remove old CONFIG_PNP_DEBUG option
      V4L/DVB: follow lspci device/vendor style
      rtc-cmos: move wake setup from ACPI glue into RTC driver
      x86: register a platform RTC device if PNP doesn't describe it
      rtc-cmos: look for PNP RTC first, then for platform RTC
      vsprintf: use new vsprintf symbolic function pointer format
      firmware: use dev_printk when possible
      resources: tidy __request_region()
      frv: use generic pci_enable_resources()
      x86/PCI: follow lspci device/vendor style
      PCI: follow lspci device/vendor style
      PCI: tidy PME support messages

Bob Copeland (2):
      ath5k: write beacon control register twice when resetting tsf
      ath5k: fix suspend-related oops on rmmod

Bob Moore (24):
      ACPICA: Allow same ACPI table to be loaded/unloaded more than once
      ACPICA: Fix wrong resource descriptor length for 64-bit build
      ACPICA: Fix table compare code, length then data
      ACPICA: Fix warning for 64-bit build
      ACPICA: Cleanup macro definition file.
      ACPICA: Return method arg count from acpi_get_object_info
      ACPICA: Update version to 20080701
      ACPICA: Add function to decode reference obj types to strings
      ACPICA: Improve object conversion error messages
      ACPICA: x2APIC support: changes for MADT and SRAT ACPI tables
      ACPICA: Update version to 20080729
      ACPICA: Remove obsolete debug levels (WARN and ERROR)
      ACPICA: Add namespace node to operand object union
      ACPICA: Remove obsolete exception codes
      ACPICA: Disallow evaluation of named object types with no value
      ACPICA: Update for Reference ACPI_OPERAND_OBJECT
      ACPICA: Update comments - no functional changes
      ACPICA: Cleanup for internal Reference Object
      ACPICA: Fix possible memory leak in acpi_ns_get_external_pathname
      ACPICA: Update version to 20080829
      ACPICA: Optimize buffer allocation procedure
      ACPICA: New: Validation for predefined ACPI methods/objects
      ACPICA: Add support for zero-length buffer-to-string conversions
      ACPICA: Update version to 20080926

Bob Peterson (2):
      GFS2: rm on multiple nodes causes panic
      GFS2: Direct IO write at end of file error

Bob Sharp (4):
      RDMA/nes: Free NIC TX buffers when destroying NIC QP
      RDMA/nes: Enable MC/UC after changing MTU
      RDMA/nes: Correct MAX TSO frags value
      RDMA/nes: Fix routed RDMA connections

Boris Dores (1):
      V4L/DVB (9301): pvrusb2: Keep MPEG PTSs from drifting away

Borislav Petkov (15):
      ide-floppy: use scatterlists for pio transfers
      ide-generic: handle probing of legacy io-ports v5
      ide: unify conversion macros
      ide: add drive->debug_mask switch
      ide: add a driver-wide debugging macro
      ide-floppy: convert driver to the new debugging macro
      ide-floppy: add a debug_mask module parameter
      ide-cd: convert driver to new ide debugging macro (v3)
      ide-cd: add a debug_mask module parameter
      ide: add ide_drive_t.dma flag
      ide-cd: move cdrom_info.dma to ide_drive_t.dma
      ide-atapi: assign taskfile flags per device type
      ide-cd: debug log enhancements
      ide-cd: small drive type print fix
      ide-cd: remove stale comment

Brandeburg, Jesse (2):
      e1000: remove unused Kconfig option for disabling packet split
      ixgb: fix bug when freeing resources

Brandon Philips (1):
      V4L/DVB (9179): S2API: frontend.h cleanup

Breno Leitao (1):
      s2io: Fix enabling VLAN tag stripping at driver initialization

Brian Cavagnolo (2):
      libertas: support boot commands to write persistent firmware and bo=
otloader
      libertas: add sysfs hooks to update boot2 and persistent firmware

Brian Haley (2):
      bonding: change some __constant_htons() to htons()
      ipvs: change some __constant_htons() to htons()

Brian Rogers (1):
      V4L/DVB (9168): Add support for MSI TV@nywhere Plus remote

Brian Swetland (6):
      [ARM] msm: rename ARCH_MSM7X00A to ARCH_MSM
      [ARM] msm: add proc_comm support, necessary for clock and power con=
trol
      [ARM] msm: clean up iomap and devices
      [ARM] msm: clock: provide clk_*() api support for
      [ARM] msm: dma: various basic dma improvements and bugfixes
      [ARM] msm: vreg interface to msm7k pmic

Brice Goglin (10):
      myri10ge: Stop scaring people when DCA is built but absent
      myri10ge: Rename DCA-related firmware counters
      myri10ge: use DCA if DCA is compiled as a module
      myri10ge: add multiqueue TX
      myri10ge: remove over-paranoid queue number modulus
      myri10ge: update driver version number to 1.4.3-1.369
      mm: stop returning -ENOENT from sys_move_pages() if nothing got mig=
rated
      mm: don't vmalloc a huge page_to_node array for do_pages_stat()
      mm: extract do_pages_move() out of sys_move_pages()
      myri10ge: disable NAPI on failure to setup the interface

Bruce Allan (5):
      e1000e: add support for the 82567LM-4 device
      e1000e: add support for 82567LM-3 and 82567LF-3 (ICH10D) parts
      e1000e: add support for new 82574L part
      e1000e: remove failed request for sw/fw/hw flag
      x86: export set_memory_ro and set_memory_rw

Bruno Pr=C3=A9mont (2):
      r8169: WoL fixes, part 1.
      r8169: WoL fixes, part 2.

Bruno Randolf (5):
      ath5k: rates cleanup
      mac80211: add rx status flag for short preamble
      mac80211: radiotap: assume modulation from rates
      iwlwifi: use generic mac80211 radiotap headers
      ath5k: set short preamble flag for rx

Bryan Wu (6):
      Blackfin arch: use new platform data interface of musb to replace o=
ld one
      Blackfin arch: add dma mapping stub for musb driver port
      Blackfin arch: fix a typo in comments
      Blackfin arch: add read/write IO accessor functions to Blackfin
      usb: musb: do not mess up count number and CSR0 register value
      netdev: DM9000: remove BLACKFIN hacking in DM9000 netdev driver

Carl Love (1):
      powerpc/oprofile: Fix mutex locking for cell spu-oprofile

Carl Shaw (1):
      sh: Subnormal double to float conversion

Carlos Corbacho (3):
      acer-wmi: Add rfkill support for wireless and bluetooth
      acer-wmi: Remove wireless and bluetooth sysfs entries
      acer-wmi: Remove private workqueue

Carlos R. Mafra (1):
      drm: remove #define's for non-linux systems

Casey Schaufler (1):
      smack: limit privilege by label

Catalin Marinas (10):
      [ARM] 5227/1: Add the ENDPROC declarations to the .S files
      [ARM] 5232/1: Do not post-index STRT instruction in clear_user.S
      [ARM] 5230/1: Replace post-indexed LDRT/STRT in uaccess.h
      [ARM] 5231/1: Do not save the frame pointer in the csum_partial_cop=
y_* functions
      [ARM] 5269/1: ARMv7: Use -march=3Darmv7-a as compiler flag
      [ARM] 5229/3: Replace some ARMv7 opcodes with the instruction name
      smc911x: Allow Kconfig dependency on ARM
      smc911x: Add IRQ polarity configuration
      smc911x: Make the driver safer on SMP
      [ARM] 5318/1: Swap the PRRR and NMRR values in proc-v7.S

Cedric Le Goater (1):
      sunrpc: fix oops in rpc_create when the mount namespace is unshared

Chandra Seetharaman (1):
      [SCSI] scsi_dh: Initialize path state to be passive when path is no=
t owned

Chandra Shekhar (2):
      ARM: OMAP: Allocate McBSP devices dynamically
      ARM: OMAP: Add support for McBSP devices 3 - 5 on 34xx

Chandru (1):
      powerpc: Add support for dynamic reconfiguration memory in kexec/kd=
ump kernels

Chen Gong (4):
      [MTD] m25p80.c erase enhance
      [MTD] m25p80.c code cleanup
      [MTD] m25p80.c extended jedec support
      [MTD] m25p80.c extended jedec support (v2)

Chien Tung (10):
      RDMA/nes: Add support for 4-port 1G HP blade card
      RDMA/nes: Module parameter permissions
      RDMA/nes: Add wqm_quanta module option
      RDMA/nes: Fix MDC setting
      RDMA/nes: Fill in firmware version for ethtool
      RDMA/nes: Correct tso_wqe_length
      RDMA/nes: Stop spurious MAC interrupts
      RDMA/nes: Limit critical error interrupts
      RDMA/nes: Correct error_module bit mask
      RDMA/nes: Fix slab corruption

Chr (2):
      p54: take tx_queue's lock in rx_frame_sent
      p54: redo queue numbering

Chris Friesen (2):
      sched: fix list traversal to use _rcu variant
      genirq: fix set_irq_type() when recording trigger type

Chris J Arges (1):
      oprofile: hotplug cpu fix

Chris Lalancette (1):
      block: Expand Xen blkfront for > 16 xvd

Chris Rankin (1):
      V4L/DVB (9047): [PATCH] Add remote control support to Nova-TD (5200=
9)

Chris Smith (2):
      sh: Fix uImage load address in 32-bit mode.
      sh: Add kprobes support.

Chris Snook (2):
      atl2: add atl2 driver
      MAINTAINERS: add Atheros maintainer for atlx

Chris Webb (1):
      md: Fix rdev_size_store with size =3D=3D 0

Chris Zankel (3):
      xtensa: Add support for the Sonic Ethernet device for the XT2000 bo=
ard.
      xtensa: Fix io regions
      xtensa: Add config files for Diamond 232L - Rev B processor variant

Christer Weinigel (1):
      s3cmci: Support transfers which are not multiple of 32 bits.

Christian Borntraeger (4):
      [S390] Fix checkstack for s390
      hvc_console: Fix free_irq in spinlocked section
      KVM: s390: Make facility bits future-proof
      KVM: s390: change help text of guest Kconfig

Christian Ehrhardt (3):
      KVM: kvmtrace: Remove use of bit fields in kvm trace structure
      KVM: kvmtrace: replace get_cycles with ktime_get v3
      KVM: ppc: trace powerpc instruction emulation

Christian Lamparter (17):
      p54: rename prism54xyz -> p54xyz
      p54: fix rssi auto calibration
      p54pci: rx tasklet refactoring
      p54pci: increase ring buffer index counter when skipping
      p54: enhance firmware parser to reduce memory waste
      p54: move eeprom code into common library
      p54usb: support LM87 firmwares
      p54: set_filter refactoring
      p54: better firmware support
      p54: 32-bit tsf timestamps
      p54: add more rx filters
      p54: add lots of useful rx/tx statistics
      p54: control output power levels
      p54: 802.11a 5GHz phy support
      p54: report appropriate rate and band values for 802.11a
      p54usb: Device ID updates
      p54: enable 2.4/5GHz spectrum by eeprom bits.

Christof Schmitt (2):
      [SCSI] zfcp: Update message with input from review
      [SCSI] zfcp: Simplify zfcp data structures

Christoph Hellwig (19):
      x86: kill sys32_pause
      powerpc: Use sys_pause for 32-bit pause entry point
      Fix barrier fail detection in XFS
      [S390] s390: use sys_pause for 31bit pause entry point
      xfs: fix remount rw with unrecognized options
      compat: move cp_compat_stat to common code
      compat: generic compat get/settimeofday
      [IA64] remove sys32_pause
      [IA64] kill sys32_pipe
      dm: kill lookup_device wrapper
      hpfs: cleanup ->setattr
      tidy up chrdev_open
      generic_file_llseek tidyups
      new helper: d_obtain_alias
      switch all filesystems over to d_obtain_alias
      kill d_alloc_anon
      fix ->llseek for more directories
      reiserfs: add missing llseek method
      ext4: remove unused variable in ext4_get_parent

Christoph Lameter (1):
      vmscan: Use an indexed array for LRU variables

Christophe Thommeret (1):
      V4L/DVB (9270): cx24116: optimise emulated auto-pilot

Christopher Leech (1):
      ixgbe: Implement HAVE_SET_RX_MODE

Christopher Moore (2):
      [ARM] Orion: add LaCie Ethernet Disk mini V2 support
      [MTD] cfi_cmdset_0002.c: Add Macronix CFI V1.0 TopBottom detection

Chuck Ebbert (4):
      xen: make CONFIG_XEN_SAVE_RESTORE depend on CONFIG_XEN
      x86: move prefill_possible_map calling early, fix, V2
      x86: allow number of additional hotplug CPUs to be set at compile t=
ime, V2
      PCI: document the pcie_aspm kernel parameter

Chuck Lever (36):
      SUNRPC: Add address family field to svc_serv data structure
      SUNRPC: Use proper INADDR_ANY when setting up RPC services on IPv6
      SUNRPC: Set V6ONLY socket option for RPC listener sockets
      SUNRPC: Simplify rpcb_register() API
      SUNRPC: Split portmap unregister API into separate function
      SUNRPC: Support IPv6 when registering kernel RPC services
      NLM: Clean up before introducing new debugging messages
      lockd: address-family independent printable addresses
      lockd: Specify address family for source address
      lockd: Add address family-agnostic helper for zeroing the port numb=
er
      SUNRPC: Make svc_addr's argument a constant
      lockd: Use sockaddr_storage + length for h_addr field
      lockd: Use sockaddr_storage for h_saddr field
      NSM: Use sockaddr_storage for sm_addr field
      lockd: Teach nlm_cmp_addr() to support AF_INET6 addresses
      lockd: Support AF_INET6 when hashing addresses in nlm_lookup_host
      lockd: Combine __nsm_find() and nsm_find().
      lockd: Update nsm_find() to support non-AF_INET addresses
      SUNRPC: Register both netids for AF_INET6 servers
      SUNRPC: Use short-hand IPv6 ANYADDR for RPCB_SET
      SUNRPC: Fix up svc_unregister()
      SUNRPC: Clean up debug messages in rpcb_clnt.c
      NLM: Convert nlm_lookup_host() to use a single argument
      lockd: Support non-AF_INET addresses in nlm_lookup_host()
      lockd: Adjust nlmclnt_lookup_host() signature to accomodate non-AF_=
INET
      lockd: Adjust nlmsvc_lookup_host() to accomodate AF_INET6 addresses
      lockd: change nlmclnt_grant() to take a "struct sockaddr *"
      lockd: Add helper to sanity check incoming NOTIFY requests
      lockd: Remove unused fields in the nlm_reboot structure
      NLM: Always start both UDP and TCP listeners
      NLM: Remove "proto" argument from lockd_up()
      NLM: Remove unused argument from svc_addsock() function
      NFS: SETCLIENTID truncates client ID and netid
      NFS: fix nfs_parse_ip_address() corner case
      NFS: Enable NFSv4 callback server to listen on AF_INET6 sockets
      NFSD: Fix BUG during NFSD shutdown processing

Cihula, Joseph (1):
      x86, e820: add support for AddressRangeUnusuable ACPI memory type

Claudio Nieder (1):
      backlight: Add driver for Tabletkiosk Sahara TouchIT-213 Tablet PC

Claudio Scordino (1):
      sched: new documentation about CFS

Clemens Ladisch (18):
      ALSA: usb-audio: add BOSS GT-10 support
      ALSA: oxygen: use SPDIF channel status symbols
      ALSA: oxygen: use a copy of the model struct
      ALSA: oxygen: add probe callback
      ALSA: oxygen: remove X-Meridian magic number
      ALSA: oxygen: handle X-Meridian dynamically
      ALSA: virtuoso: handle D2X/DX dynamically
      ALSA: virtuoso: create common functions for GPIO bit switch control=
s
      ALSA: oxygen: rename pcm_dev_cfg
      ALSA: oxygen: configure MIDI via device_config
      ALSA: oxygen: add UART I/O functions
      ALSA: oxygen: add self-documenting functions
      ALSA: virtuoso: allow I2C-connected PCM1796
      ALSA: virtuoso: make number of PCM1796 DACs configurable
      ALSA: virtuoso: rename AC97 callback function
      ALSA: oxygen: rename first PCM device
      ALSA: virtuoso: add Xonar HDAV1.3 support
      ALSA: oxygen: wait for ACK when resetting UART

Cliff Cai (18):
      ALSA: ASoC: AD1980 audio codec driver
      ALSA: ASoC: Add SPI support for WM8731
      ALSA: add dummy function to support shared mmap in nommu Blackfin a=
rch
      ALSA: ASoC codec: fix compiling error in ad1980 driver after ASoC A=
PI changed
      sound: ASoC codec: SSM2602 audio codec driver
      sound: ASoC: Blackfin: SPORT peripheral interface driver
      sound: ASoC: Blackfin: DMA Driver for AC97 sound chip
      sound: ASoC: Blackfin: AC97 Blackfin CPU DAI driver
      sound: ASoC: Blackfin: DMA Driver for I2S sound chip
      sound: ASoC: Blackfin: I2S CPU DAI driver
      sound: ASoC: Blackfin: board driver for AD1980/1 audio codec
      sound: ASoC: Blackfin: board driver for SSM2602 sound chip
      sound: ASoC: Blackfin: add Blackfin arch ASoC Kconfig and Makefile
      sound: ASoC: Blackfin: Include Blackfin architecture support in bui=
ld
      ALSA: ASoC codec: AD73311 audio codec driver
      ALSA: ASoC Blackfin: add I2S DAI support for AD73311
      ALSA: ASoC Blackfin: add asoc ad73311 driver supporting in Blackfin=
 boards
      ALSA: ASoC Blackfin: fix bug - Audio Latency on AD1981 with MMAP en=
abled

Clive Messer (1):
      ALSA: hda - Fix another ALC889A (rev 0x100101)

Colin B Macdonald (1):
      Input: i8042 - add Thinkpad R31 to nomux list

Corentin Chary (1):
      asus-laptop: Fix the led behavior with value > 1

Corentin Labbe (1):
      hwmon: (adm1029) Use mask for fan_div value

Cornelia Huck (8):
      [S390] cio: Update cio_ignore documentation.
      [S390] cio: Exorcise cio_msg=3D from documentation.
      [S390] bus_id -> dev_set_name() changes
      [S390] more bus_id -> dev_name conversions
      [S390] Use s390_root_dev_* in kvm_virtio.
      [S390] bus_id -> dev_set_name() for css and ccw busses
      Driver core: Clarify device cleanup.
      Driver core: Fix cleanup in device_create_vargs().

Cyrill Gorcunov (57):
      x86: DS cleanup - dont treat 0 as NULL
      x86: apic unification - merge down lapic_get_maxlvt
      x86: apic unification - merge down enable_NMI_through_LVT0
      x86: apic interrupts - move assignments to irqinit_32.c, v2
      x86: apic - use SET_APIC_DEST_FIELD instead of hardcoded shift
      x86: apic - unify disable_apic_timer
      x86: apic - unify __setup_APIC_LVTT
      x86: apic - do not clear APIC twice in lapic_shutdown
      x86: apic - get rid of local_apic_timer_verify_ok
      x86: apic - unify verify_local_APIC
      x86: apic - unify sync_Arb_IDs
      x86: apic - sync_Arb_IDs style fixup
      x86: apic - unify init_bsp_APIC
      x86: apic - unify clear_local_APIC
      x86: apic - unify lapic_resume
      x86: apic - unify lapic_suspend
      x86: apic - rearrange functions and comments
      x86: apic - unify lapic_is_integrated
      x86: apic - unify xapic_icr_read
      x86: apic - rearrange maxcpu definition
      x86: apic - unify setup_boot_APIC_clock
      x86: apic - unify disable_local_APIC
      x86: apic - unify lapic_shutdown
      x86: apic - unify connect_bsp_APIC
      x86: apic - unify lapic_setup_esr
      x86: apic - unify __setup_APIC_LVTT
      x86: apic - unify disconnect_bsp_APIC
      x86: apic - generic_processor_info
      x86: apic - unify end_local_APIC_setup
      x86: apic - unify local_apic_timer_interrupt
      x86: apic - unify apic_set_verbosity
      x86: apic - unify disableapic and nolapic setup handlers
      x86: apic - rearrange parse_lapic_timer_c2_ok
      x86: apic - lapic_resume 32bit - unification fix
      x86: apic - compilation warnings fix
      x86: smpboot - check if we have ESR register in wakeup_secondary_cp=
u
      x86: apic_64.c - setup_APIC_timer has to be __cpuinit function
      x86: apic - introduce get_physical_broadcast for 64bit
      x86: apic - unify setup_apicpmtimer
      x86: apic_64.c - add sanity check for spurious vector definition
      x86: apic - unify setup_local_APIC
      x86: apic_32.c should use __cpuinit section
      x86: apic - unify smp_apic_timer_interrupt
      x86: apic - unify smp_spurious/error_interrupt declaration
      x86: io-apic - use ARRAY_SIZE macro
      x86: io-apic - declare irq_cfg_lock for SPARSE_IRQ only
      x86: io-apic - code style cleaning for setup_IO_APIC_irqs
      x86: io-apic - do not use KERN_DEBUG marker too much
      x86: io-apic - get rid of __DO_ACTION macro
      x86: apic - lapic_setup_esr does not handle esr_disable - fix it
      x86: apic - skip writting ESR register if we dont have on
      x86: apic - fix unused vars warning in calibrate_APIC_clock
      x86: io-apic - do not use KERN_DEBUG marker too much, fix
      x86: io-apic - interrupt remapping fix
      x86: io-apic - interrupt remapping fix
      x86: apic - unify APIC_DIVISOR
      x86: do_boot_cpu - check if we have ESR register

Dallas Foley (1):
      [ARM] S3C24XX: pwm-clock set_parent mask fix

Dan Liang (1):
      Input: atmel_tsadcc - improve accuracy

Dan Nicholson (1):
      sundance: set carrier status on link change events

Dan Williams (12):
      libertas: convert CMD_802_11_RF_TX_POWER to a direct command
      libertas: convert CMD_802_11_DEAUTHENTICATE to a direct command
      libertas: convert CMD_802_11_RADIO_CONTROL to a direct command
      libertas: convert adhoc operations to direct commands
      libertas: clear current command on card removal
      async_tx: make async_tx_run_dependencies() easier to read
      libertas: remove unused generic RESET command
      libertas: convert SNMP_MIB to a direct command
      md: fix input truncation in safe_delay_store()
      USB: option: add Ericsson F3507g and Dell 5530
      USB: option: add Pantech cards
      [RFC PATCH] touch_mnt_namespace when the mount flags change

Daniel Gimpelevich (1):
      Input: cm109 - add missing newlines to messages

Daniel Oliveira Nascimento (1):
      V4L/DVB (9041): Add support YUAN High-Tech STK7700D (1164:1f08)

Daniel Rosenthal (1):
      [MTD] [INFTL] Fix infinite loop in INFTL_foldchain

Daniel THOMPSON (1):
      sound: Fix esoteric double free in the dummy sound driver.

Daniel Wagner (2):
      rt2x00mac: In error case stop netdev queue, free skb and return NET=
DEV_TX_OK
      mac80211: Use only precedence level of DSCP field for frame classif=
ication

Daniele Calore (1):
      x86: memtest fix use of reserve_early()

Danny ter Haar (1):
      fix random typos

Dario Faggioli (1):
      sched_rt.c: resch needed in rt_rq_enqueue() for the root rt_rq

Darius Augulis (2):
      MXC: Lets handle IRQ by priority, defined with exported API functio=
n
      MXC: Remove WD IRQ priority setting

Darrick J. Wong (4):
      matroxfb: support G200eV chip
      hwmon: (ibmpex) Automatically load on IBM systems via DMI
      hwmon: (ibmaem) Automatically load on IBM systems via DMI
      hwmon: (adt7470) Add documentation

Darron Broad (27):
      V4L/DVB (9011): S2API: A number of cleanusp from the last 24 months.
      V4L/DVB (9013): S2API: cx24116 Rolloff changes, sysctls cleanup, is=
l power changes.
      V4L/DVB (9015): S2API: cx24116 register description fixes.
      V4L/DVB (9016): HVR3000/4000 Hauppauge related IR cleanups
      V4L/DVB (9069): cx88: Bugfix: all client disconnects put the fronte=
nd to sleep.
      V4L/DVB (9170): cx24116: Sanity checking to data input via S2API to=
 the cx24116 demod.
      V4L/DVB (9171): S2API: Stop an OOPS if illegal commands are dumped =
in S2API.
      V4L/DVB (9172): S2API: Bugfix related to DVB-S / DVB-S2 tuning for =
the legacy API.
      V4L/DVB (9185): S2API: Ensure we have a reasonable ROLLOFF default
      V4L/DVB (9223): MFE: Fix a number of bugs and some tidying up
      V4L/DVB (9224): MFE: bugfix: add missing frontend allocation
      V4L/DVB (9225): MFE: Add configurable gate control
      V4L/DVB (9226): MFE: cx88: Reset cx22702 on hvr-3000/4000
      V4L/DVB (9227): MFE: Add multi-frontend mutual exclusion
      V4L/DVB (9228): cx88: Add audio routing for the hvr-3000/4000
      V4L/DVB (9229): cx88: Add intial config for FM radio support
      V4L/DVB (9264): MFE: bugfix: multi-frontend mutual exclusion parall=
el open
      V4L/DVB (9265): videobuf: data storage optimisation
      V4L/DVB (9266): videobuf: properly handle attachment failure
      V4L/DVB (9267): cx88: Update of audio routing config for FM radio
      V4L/DVB (9268): tuner: add FMD1216MEX tuner
      V4L/DVB (9269): cx88: add I2S-ADC tvaudio method
      V4L/DVB (9271): videobuf: data storage optimisation (2)
      V4L/DVB (9332): cx88: initial fix for analogue only compilation
      V4L/DVB (9334): cx88: dvb_remove debug output
      V4L/DVB (9335): videobuf: split unregister bus creating self-contai=
ned frontend de-allocator
      V4L/DVB (9336): cx88: always de-alloc frontends on fault condition

Dave Airlie (6):
      drm: fix sysfs error path.
      radeon: fix writeback across suspend/resume.
      i915: fixup permissions on gem ioctls.
      i915: add missing return in error path.
      drm: wbinvd is cache coherent.
      drm: make CONFIG_DRM depend on CONFIG_SHMEM.

Dave Graham (2):
      e1000e: don't generate bad checksums for tcp packets with 0 csum
      e1000: don't generate bad checksums for tcp packets with 0 csum

Dave Hansen (5):
      KVM: Reduce kvm stack usage in kvm_arch_vm_ioctl()
      KVM: Reduce stack usage in kvm_vcpu_ioctl()
      KVM: Reduce stack usage in kvm_arch_vcpu_ioctl()
      KVM: Reduce stack usage in kvm_pv_mmu_op()
      profiling: dynamically enable readprofile at runtime

Dave Jones (1):
      Update email addresses.

Dave Kleikamp (1):
      sched_clock: prevent scd->clock from moving backwards

Dave Young (1):
      i386: vmalloc size fix

David Bentham (1):
      V4L/DVB (9057): saa7134: Hauppauge HVR-1110, support for radio and =
analog audio in

David Brownell (44):
      hpet: /dev/hpet - fixes and cleanup
      hpet: /dev/hpet - fixes and cleanup, fix
      [MTD] dataflash OTP support
      [MTD] Compile fix for dataflash OTP support
      [MTD] make dataflash write-verify be optional
      ARM: DaVinci: SOC GPIOs use gpiolib
      ARM: DaVinci: usb setup
      ARM: DaVinci: evm sets up many devices
      [ARM] 5240/1: AT91: eeproms on sam9260ek, sam9263ek
      sparc: arch/sparc/kernel/pmc.c -- extra #include?
      ngw100: export J15 through sysfs
      genirq: record trigger type
      drivers/net/usb/Makefile - shrink logspam
      i2c: Guard against oopses from bad init sequences
      i2c: Do earlier driver model init
      usb gadget: link fixes for serial gadget
      usb gadget: link fixes for gadget zero
      usb gadget: link fixes for MIDI gadget
      usb gadget: link fixes for printer gadget
      usb gadget: link fixes for storage gadget
      usb gadget: link fixes for cdc composite gadget
      usb gadget: link fixes for network gadget
      spi: core and gpio expanders use subsys_init
      rtc: remove some NOP open/release methods
      legacy rtc: remove needless/confusing HPET_RTC_IRQ option
      rtc: file close() consistently disables repeating irqs
      gpio: i2c expanders use subsys_init
      gpiolib: gpio_to_irq() hooks
      omap drivers: switch to standard GPIO calls
      gpiolib: request/free hooks
      usb: gadget Kconfig cleanup
      usb gadget: function activation/deactivation
      usb gadget: defer obex enumeration
      usb gadget: USB_GADGET_VBUS_DRAW Kconfig option
      usb: musb_hdrc build fixes
      usb gadget: cdc ethernet notification bugfix
      mfd: TWL4030 core driver
      mfd: twl4030-core irq simplification
      rtc-cmos: export second NVRAM bank
      gpiolib: fix oops in gpio_get_value_cansleep()
      mfd: twl4030 IRQ handling update
      mfd: rtc-twl4030 driver
      mfd: twl4030-gpio driver
      [ARM] 5316/1: AT91: oops (regression) fix on gpio irq

David Daney (7):
      MIPS: Add HARDWARE_WATCHPOINTS configure option.
      MIPS: Add HARDWARE_WATCHPOINTS definitions and support code.
      MIPS: Probe watch registers and report configuration.
      MIPS: Watch exception handling for HARDWARE_WATCHPOINTS.
      MIPS: Scheduler support for HARDWARE_WATCHPOINTS.
      MIPS: Ptrace support for HARDWARE_WATCHPOINTS
      MIPS: Align .data.cacheline_aligned based on CONFIG_MIPS_L1_CACHE_S=
HIFT

David Ellingsworth (3):
      V4L/DVB (9034): With the recent patch to v4l2 titled "v4l2: use reg=
ister_chrdev_region
      V4L/DVB (9193): stk-webcam: minor cleanup
      V4L/DVB (9194): stk-webcam: fix crash on close after disconnect

David Fries (32):
      [netdrvr] ne: Fix suspend and resume for ISA PnP cards.
      ne.c: fix rmmod, platform driver improvements
      W1: fix deadlocks and remove w1_control_thread
      W1: abort search early on on exit
      W1: don't delay search start
      W1: w1_process, block or sleep
      W1: feature, enable hardware strong pullup
      W1: feature, w1_therm.c use strong pullup and documentation
      W1: be able to manually add and remove slaves
      W1: recode w1_slave_found logic
      W1: new module parameter search_count
      W1: Document add, remove, search_count, and pullup.
      W1: w1_slave_read_id read bug, use device_attribute
      W1: w1_therm fix user buffer overflow and cat
      W1: w1_family, remove unused variable need_exit
      W1: w1_therm consistent mutex access code cleanup
      W1: w1_int.c use first available master number
      W1: w1.c s/printk/dev_dbg/
      W1: w1_io.c reset comments and msleep
      W1: ds1wm.c msleep for reset
      W1: ds2490.c correct print message
      W1: ds2490.c add support for strong pullup
      W1: ds2490.c ds_write_bit, grouping error, disable readback
      W1: ds2490.c disable bit read and write
      W1: ds2490.c simplify and fix ds_touch_bit
      W1: ds2490.c ds_dump_status rework
      W1: ds2490.c ds_reset remove ds_wait_status
      W1: ds2490.c reset ds2490 in init
      W1: ds2490.c magic number work
      W1: ds2490.c ds_write_block remove extra ds_wait_status
      W1: Documentation/w1/masters/ds2490 update
      W1: ds2490.c optimize ds_set_pullup

David Gibson (5):
      powerpc: Update in-kernel dtc and libfdt to version 1.2.0
      powerpc: Clean up hugepage pagetable allocation for powerpc with 16=
G pages
      powerpc: Get USE_STRICT_MM_TYPECHECKS working again
      hugetlb: handle updating of ACCESSED and DIRTY in hugetlb_fault()
      powerpc: Further compile fixup for STRICT_MM_TYPECHECKS

David Howells (9):
      SELinux: Fix a potentially uninitialised variable in SELinux hooks
      clocksource: check range
      CRED: Wrap task credential accesses in the JFFS2 filesystem
      V4L/DVB (8838): CRED: Wrap task credential accesses in video input =
drivers
      MN10300: MEI are renaming themselves to Panasonic
      FRV: Provide dma_map_page() for NOMMU and fix comments
      SiS DRM: fix the memory allocator if the SIS FB is built as a modul=
e
      SiS DRM: fix a pointer cast warning
      drm/cred: wrap task credential accesses in the drm driver.

David John (1):
      HPET: Remove spurious HPET busy warning message.

David Kilroy (22):
      orinoco: Add ESSID specific scanning for Agere fw
      orinoco: Update scan translation
      orinoco: Specify all three parameters to every Hermes command.
      orinoco: Move EXPORT_SYMBOL declarations next to exported function
      orinoco: Add function to execute Hermes initialisation commands syn=
chronously
      orinoco: Move firmware download functionality into new module
      orinoco: Make firmware download logic more generic
      orinoco: Extend hermes_dld routines for Agere firmware
      orinoco: Invoke firmware download in main driver
      orinoco: Fix transmit for Agere/Lucent with fw 9.x
      orinoco: address checkpatch typedef warning
      orinoco: Use extended Agere scans available on 9.x series firmwares
      orinoco: Don't use boolean parameter to record encoding type
      orinoco: Split wevent work thread from wevent sending
      orinoco: Use a macro to define wireless handlers
      orinoco: Add WE-18 ioctls for WPA
      orinoco: Send association events to userspace
      orinoco: Process bulk of receive interrupt in a tasklet
      orinoco: Add MIC on TX and check on RX
      orinoco: Fix compile warnings
      wireless: Read scan flags correctly on x86-64
      orinoco: fix unsafe locking in spectrum_cs_suspend

David Miller (6):
      serial: Make uart_port's ioport "unsigned long".
      serial: allow 8250 to be used on sparc
      sched: kill unused scheduler decl.
      i2c-algo-pcf: Pass adapter data into ->waitforpin() method
      i2c-algo-pcf: Add adapter hooks around xfer begin and end
      i2c-algo-pcf: Fix typo in debugging log message

David Rientjes (1):
      x86: avoid dereferencing beyond stack + THREAD_SIZE

David Rowe (1):
      Staging: add echo cancelation module

David S. Miller (242):
      sparc64: Add JBUS NUMA detection.
      sparc: Add mutex for set property calls.
      sparc: Implement irq_of_parse_and_map() and irq_dispose_mapping().
      sparc: Add GPIO layer support.
      sparc64: Split syscall_trace() into two functions.
      sparc64: Kill duplicated sys_pause() implementation.
      hwmon: Add Ultra45 workstation hwmon driver.
      sparc64: Convert UltraSPARC-III memory controller driver to OF driv=
er probing.
      sparc64: Use consistent chmc_ prefix in variables, types, and funct=
ions.
      sparc64: Add generic interface for registering a dimm printing hand=
ler.
      sparc64: Allow chmc to be built as a module.
      sparc64: Add JBUS UltraSPARC-IIIi support to memory controller driv=
er.
      sparc64: Use the cond_syscall()s in kernel/sys_ni.c instead of home=
-grown copy.
      sparc64: Fix irq_of_parse_and_map() and irq_dispose_mapping().
      Merge branch 'lvs-next-2.6' of git://git.kernel.org/pub/scm/linux/k=
ernel/git/horms/lvs-2.6
      sparc: Delete bare sbus char bpp driver, obsoleted by parport_sunbp=
p
      sparc: Kill videopix SBUS driver.
      sparc: Kill SBUS DVMA layer.
      sparc32: Make IOMMU and IO-UNIT init work with device nodes.
      sparc: Propagate SBUS iommu archdata into real of_device objects.
      sparc: Make SBUS DMA interfaces take struct device.
      sparc32: Make mmu_{get,release}_*() take a struct device pointer.
      sparc32: Implement more generic dma_*() interfaces.
      sparc: Convert all SBUS drivers to dma_*() interfaces.
      sparc: Move SBUS DMA attribute interfaces out of asm/sbus.h
      myri_sbus: Convert to pure OF driver.
      sunbmac: Convert to pure OF driver.
      sunhme: Convert to pure OF driver.
      sunlance: Convert to pure OF driver.
      sunqe: Convert to pure OF driver.
      parport_sunbpp: Convert to pure OF driver.
      sun_esp: Convert to pure OF driver.
      qlogicpti: Convert to pure OF driver.
      amd7930: Convert to pure OF driver.
      dbri: Convert to pure OF driver.
      cs4231: Use SNDRV_DMA_TYPE_DEV instead of SNDRV_DMA_TYPE_SBUS.
      alsa: Remove special SBUS dma support code.
      cs4231: Convert SBUS side to OF driver.
      fore200e: Convert over to pure OF driver.
      sparc: Convert flash driver to OF device probing.
      sparc: Convert uctrl driver to OF driver.
      sparc64: Convert SBUS floppy probing to use OF device objects.
      sparc32: Kill mmu_translate_dvma() usage.
      sparc32: Kill mmu_translate_dvma and implementations.
      sparc32: Make mmu_map_dma_area and mmu_unmap_dma_area take a device=
 pointer.
      sparc32: Convert apc to OF driver.
      sparc32: Convert pmc to OF driver.
      sparc32: Convert sun4d IRQ code to use generic device tree probing.
      sparc: Kill SBUS layer IRQ hooks.
      sparc: Remove SBUS layer resource and irq handling.
      sparc: Remove dinky old-style SBUS probing facilities.
      sparc: Convert remaining sbus_ioremap() and sbus_iounmap() users.
      sparc: Kill sbus_ioremap() and sbus_iounmap().
      sparc: Kill sbus_devaddr() and sbus_dev_slot().
      sparc: Kill OBP property members of sbus_dev and sbus_bus
      sparc32: Kill sbus_is_slave().
      sparc: Kill sbus_arch_preinit().
      sparc: Add OF archdata propagation helper.
      sparc: Remove generic SBUS probing layer.
      sparc: Kill sbus_bus_type.
      sparc32: Kill iounit_map_dma_*().
      sparc: Kill now spurious includes of sbus.h
      sparc: Delete asm/sbus*.h
      sparc: Remove Documentation/sparc/sbus_drivers.txt
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-next-2.6
      rtc: Allow RTC_DRV_CMOS to be used on SPARC.
      sparc64: Select RTC_CLASS
      sparc64: Check for RTC class device in update_persistent_clock().
      sparc64: Convert Mostek rtc to use generic RTC layer driver.
      sparc: asm/mostek.h is now 32-bit only
      sparc64: Use generic CMOS driver.
      rtc: Add TI BQ4802 RTC driver.
      sparc64: Use generic BQ4802 RTC driver.
      rtc: Add Sun4V hypervisor RTC driver.
      sparc64: Use generic sun4v RTC driver.
      rtc: Add Starfire platform RTC driver.
      sparc64: Use generic starfire RTC driver.
      riowatchdog: Convert to pure OF driver.
      riowatchdog: Move under drivers/watchdog
      riowd: Distinguish between driver name and OF device node name.
      cpwatchdog: Cleanup and convert to pure OF driver.
      cpwatchdog: Move to drivers/watchdog/cpwd.c
      sun_uflash: Convert to pure OF driver.
      display7seg: Convert to pure OF device driver.
      envctrl: Convert to pure OF driver.
      bbc_i2c: Convert to pure OF driver.
      sparc64: Propagate PCI device archdata into OF device tree for EBUS.
      bbc_envctrl: Fix build errors from bbc_i2c OF conversion.
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      sparc: Move EBUS DMA interfaces into seperate header file.
      sparc64: Convert EBUS floppy support to pure OF driver.
      cs4231: Convert to EBUS side to pure OF driver.
      sparc32: Convert PC RTC probing to pure OF driver.
      sparc: Kill EBUS driver layer.
      sparc: Kill ebus_bus_type.
      sparc64: Don't invoke power_init() from pcibios_init().
      sparc64: Convert SCHIZO PCI controller driver into a real driver.
      sparc64: Convert SUN4V PCI controller driver into a real driver.
      sparc64: Convert PSYCHO PCI controller driver into a real driver.
      sparc64: Convert SABRE PCI controller driver into a real driver.
      sparc64: Convert FIRE PCI controller driver into a real driver.
      sparc: Stop setting NO_DMA.
      sparc: Annotate of_device_id arrays with const or __initdata.
      sparc64: Simplify error handling in PCI controller probing.
      sparc64: Delete starfire_cpu_setup().
      leds: Add driver for Sunfire UltraSPARC server LEDs.
      sparc64: Rewrite central driver.
      sparc64: Clean up CPU chip type probing code.
      sparc64: Apply const or __initdata to vio_device_id[]
      sparc64: Use ENTRY/ENDPROC in hypervisor asm.
      sparc64: Use ENTRY/ENDPROC in PCI SUN4V asm.
      sparc64: Kill the scan_bus function pointer in struct pci_pbm_info.
      sparc64: Pass proper parent device down into root pci_create_bus() =
call.
      sparc64: Move reboot handling into seperate file and kill power reg=
 programming.
      sparc64: Implement SSTATE purely using notifiers and initcalls.
      pci_psycho: Use of_getintprop_default().
      pci_schizo: Use of_get_property() and delete spurious local vars.
      pci_sun4v: Use of_get_property().
      sparc32: Fix sun4c build warnings.
      sparc: Fix handling of LANCE and ESP parent nodes in of_device.c
      sparc32: use RTC subsystem
      sparc: Kill sbus mostek RTC driver.
      sparc32: Kill remaining asm/mostek.h inclusions.
      sparc32: Kill asm/mostek.h.
      sparc: Remove asm/rtc.h
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/sparc-2.6
      sparc32: Fix coding style of sparc_cpu_model setting code.
      sparc32: Move sun4d show_leds() out of asm/obio.h
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-next-2.6
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/torvalds/linux-2.6
      Merge branch 'dccp' of git://eden-feed.erg.abdn.ac.uk/dccp_exp
      sparc64: Add missing rtc_close() in update_persistent_clock()
      Merge branch 'master' of git://eden-feed.erg.abdn.ac.uk/net-next-2.=
6
      ipsec: Make xfrm_larval_drop default to 1.
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      rtc-bq4802: Fix sparse warnings.
      Merge branch 'lvs-next-2.6' of git://git.kernel.org/pub/scm/linux/k=
ernel/git/horms/lvs-2.6
      ipsec: Add missing list_del() in xfrm_state_gc_task().
      sparc64: Fix return value in update_persistent_clock().
      sparc32: Need to close openned RTC device just like sparc64.
      sparc64: Get rid of pci_controller_info.
      sparc64: Record OF device instead of device node pointer in pci_pbm=
_info.
      sparc64: Start commonizing code common between SABRE and PSYCHO.
      sparc64: Create and use psycho_pbm_init_common().
      sparc64: Commonize large portions of PSYCHO error handling.
      sparc64: Kill hand-crafted I/O accessors in PCI controller drivers.
      ipv6: On interface down/unregister, purge icmp routes too.
      sparc32: Call parse_early_param() in setup_arch().
      net: Add DMA mapping tokens to skb_shared_info.
      net: Add SKB DMA mapping helper functions.
      tg3: Use SKB DMA helper functions for TX.
      tg3: Fix DMA mapping leak in tigon3_dma_hwbug_workaround().
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-next-2.6
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      sparc64: Add __arch64__ to CHECKFLAGS
      sparc64: Fix sparse warnings in global reg snapshotting.
      sysctl: Use CONFIG_SPARC instead of __sparc__ for ifdef tests.
      sysctl: Use header file for sysctl knob declarations on sparc.
      sparc64: Define WANT_PAGE_VIRTUAL
      sparc64: Fix sparse warnings in kernel/time.c
      sparc64: Fix sparse warnings in visemul.c
      sparc64: Fix sparse warnings in prom.c
      sparc64: Fix sparse warnings in of_device.c
      sparc64: Fix sparse warnings in pci.c
      sparc64: Fix sparse warnings in pci_sun4v.c
      sparc64: Fix sparse warnings in vio.c
      sparc64: Remove explicit initialization of mmu_gathers
      sparc64: Fix sparse warnings in fault.c
      sparc64: Kill sparse warnings in mm/init.h
      sparc64: Fix sparse warnings in chmc.c
      sparc: Fix user_regset 'n' field values.
      sparc32: Use PROM device probing for sun4m timer registers.
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/sparc-2.6
      net: Fix build with ARCH=3Dum
      Merge branch 'new-drivers' of master.kernel.org:/pub/scm/linux/kern=
el/git/jgarzik/netdev-2.6
      qlge: Fix warnings in debugging code.
      qlge: Protect qlge_resume() with CONFIG_PM
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-next-2.6
      sparc32: Use PROM device probing for sun4m irq registers.
      sparc32: Use PROM infrastructure for probing and mapping sun4d time=
rs.
      sparc32: Remove some SMP ifdefs in sun4d_irq.c
      sparc32: Remove #if 0'd code from sun4c_irq.c
      sparc32: Call sun4m_clear_profile_irq() directly from sun4m_smp.c
      sparc32: Kill clear_profile_irq btfixup entry.
      sparc32: Stop calling claim_ticker14() from sun4c_irq.c
      sparc32: Delete claim_ticker14().
      sparc32: Use PROM device probing for sun4c interrupt register.
      sparc32: Use PROM device probing for sun4c timers.
      sparc32: Delete master_l10_limit.
      sparc32: Kill irq_rcvreg from sun4m_irq.c
      sparc32: Add more extensive documentation of sun4m interrupts.
      net: Remove __skb_insert() calls outside of skbuff internals.
      atm: idt77252: Use generic SKB queue management instead of home-gro=
wn scheme.
      net: Add new interfaces for SKB list light-weight init and splicing.
      aoe: Use SKB interfaces for list management instead of home-grown s=
tuff.
      bluetooth: hci_bcsp: Use SKB list interfaces instead of home-grown =
stuff.
      isdn: isdn_ppp: Use SKB list facilities instead of home-grown imple=
mentation.
      cxgb3: Use SKB list interfaces instead of home-grown implementation.
      usbnet: Use skb_queue_walk_safe() instead of by-hand implementation.
      net: Fix bus in SKB queue splicing interfaces.
      sctp: Use skb_queue_walk_safe() and skb_queue_split_tail_init().
      pkt_sched: Make qdisc->gso_skb a list.
      pkt_sched: Always use q->requeue in dev_requeue_skb().
      de4x5: Use skb_queue_head instead of by-hand implementation.
      zd1211: Use skb_queue_walk() instead of by-hand implementation.
      usbatm: Use skb_queue_walk_safe() instead of by-hand implementation.
      net: Add skb_queue_is_last().
      tcp: Use skb_queue_is_last() instead of by-hand version.
      net: Add skb_queue_next().
      net: Add skb_queue_walk_from() and skb_queue_walk_from_safe().
      tcp: Use SKB queue handling interfaces instead of by-hand versions.
      neigh: Remove by-hand SKB queue handling.
      ppp_generic: Use skb_peek() in ppp_receive_mp_frame().
      tcp: Fix order of tests in tcp_retransmit_skb()
      tcp: Fix queue traversal in tcp_use_frto().
      aoe: Fix OOPS after SKB queue changes.
      Merge branch 'davem-next' of master.kernel.org:/pub/scm/linux/kerne=
l/git/jgarzik/netdev-2.6
      Revert "ehea: fix mutex and spinlock use"
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-next-2.6
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-next-2.6
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      tcp: Respect SO_RCVLOWAT in tcp_poll().
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-next-2.6
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/kaber/nf-next-2.6
      Merge branch 'lvs-next-2.6' of git://git.kernel.org/pub/scm/linux/k=
ernel/git/horms/lvs-2.6
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/davem/net-2.6
      dsa: Need to select PHYLIB.
      jme: Fix warnings with CONFIG_PM disabled.
      ppp: Use skb_queue_walk() in ppp_mp_insert().
      enic: Attempt to fix build in 32-bit such as i386.
      Merge branch 'r8169' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/romieu/netdev-2.6
      ipvs: Add proper dependencies on IP_VS, and fix description header =
line.
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/torvalds/linux-2.6
      acpi: Make ACPI_TOSHIBA depend on INPUT.
      sparc64: Add missing notify_cpu_starting() call.
      chmc: Mark %ver register inline asm with __volatile__
      serial: fix device name reporting when minor space is shared betwee=
n drivers
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-2.6
      decnet: Fix compiler warning in dn_dev.c
      softirq: Add support for triggering softirq work on softirqs.
      math-emu: Fix thinko in _FP_DIV
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-2.6

David Teigland (5):
      dlm: allow multiple lockspace creates
      dlm: detect available userspace daemon
      dlm: fix locking of lockspace list in dlm_scand
      dlm: fix address compare
      dlm: remove bkl

David Vrabel (17):
      bitmap: add bitmap_copy_le()
      uwb: add the UWB stack (reservation manager)
      uwb: add the UWB stack (debug support)
      uwb: add the umc bus
      uwb: add the driver to enumerate WHCI capabilities
      wusb: WHCI host controller driver
      uwb: initialize the debug sub-system
      uwb: dont tranmit identification IEs
      uwb: add symlinks in sysfs between radio controllers and PALs
      uwb: document UWB and WUSB sysfs files
      uwb: depend on EXPERIMENTAL
      uwb: add entries in the MAINTAINERS file
      Merge branch 'for-upstream' of git://git.kernel.org/pub/scm/linux/k=
ernel/git/dvrabel/uwb into for-upstream
      uwb: use time_after() when purging stale beacons
      uwb: use kcalloc where appropriate
      uwb: don't use printk_ratelimit() so often
      Merge branch 'master' into for-upstream

David Woodhouse (51):
      [MTD] Remove references to TI 'toto' platform.
      [MTD] [NOR] Rename and export new cfi_qry_*() functions
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6
      Fix date output in x86 microcode driver.
      [MTD] [NAND] Minor cleanup of nand_ecc.c
      [JFFS2] Fill in f_fsid field in jffs2_statfs()
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6
      [MTD] [NOR] Select MTD_CFI_UTIL when MTD_CFI probe routine is enabl=
ed
      EFS: Don't set f_fsid in statfs().
      Use PCI_DEVICE_ID_88ALP01 for CAF=C3=89 chip, rather than PCI_DEVIC=
E_ID_CAFE.
      [MTD] [NAND] Define and use PCI_DEVICE_ID_MARVELL_88ALP01_NAND for =
CAF=C3=89
      Define and use PCI_DEVICE_ID_MARVELL_88ALP01_CCIC for CAF=C3=89 cam=
era driver
      Make <asm-generic/statfs.h> suitable for 64-bit platforms.
      ARM: Use <asm-generic/statfs.h>
      IA64: Use <asm-generic/statfs.h>
      x86: blacklist DMAR on Intel G31/G33 chipsets
      x86_64: Use <asm-generic/statfs.h>
      PARISC: Use <asm-generic/statfs.h>
      PowerPC: Use <asm-generic/statfs.h>
      SPARC: Use <asm-generic/statfs.h>
      S390: Update comments about why we don't use <asm-generic/statfs.h>
      Remove redundant CONFIG_ARCH_SUPPORTS_AOUT
      Introduce HAVE_AOUT symbol to remove hard-coded arch list for BINFM=
T_AOUT
      ALSA: hda - Add PCI subsystem ID for MacBookPro4,1
      Fix up comments about matching flags between bio and rq
      Add 'discard' request handling
      Let the block device know when sectors can be discarded
      Support 'discard sectors' operation in translation layer support co=
re
      Support 'discard sectors' operation.
      blktrace: support discard requests
      blktrace: simplify flags handling in __blk_add_trace
      Add BLKDISCARD ioctl to allow userspace to discard sectors
      Allow elevators to sort/merge discard requests
      Kill REQ_TYPE_FLUSH
      Automatic MODULE_ALIAS() for DMI match tables.
      Fix autoloading of MacBook Pro backlight driver.
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6
      [MTD] [MAPS] Remove unused variable after ROM API cleanup.
      Merge branch 'master' of git://git.infradead.org/ubi-2.6
      dmar: fix uninitialised 'ret' variable in dmar_parse_dev()
      Admit to maintaining VT-d, for my sins.
      [MTD] [NAND] GPIO driver depends on ARM... for now.
      Revert "[MTD] m25p80.c code cleanup"
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/torvalds/linux-2.6
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/torvalds/linux-2.6
      Factor out nfsd_do_readdir() into its own function
      Copy XFS readdir hack into nfsd code.
      Remove XFS buffered readdir hack
      [JFFS2] Reinstate NFS exportability
      Optimise NFS readdir hack slightly.
      [JFFS2] Use d_splice_alias() not d_add() in jffs2_lookup()

Davide Libenzi (1):
      epoll: drop unnecessary test

Davide Pesavento (2):
      Fix modpost failure when rx handlers are not inlined.
      wireless: fix typo in Kconfig.

Dean Anderson (2):
      V4L/DVB (8752): s2255drv: firmware improvement patch
      V4L/DVB (8845): s2255drv: adds JPEG compression quality control

Dean Nelson (4):
      irq: error missed ifndef CONFIG_HAVE_SPARSE_IRQ
      irq: set_irq_chip() has redundant call to irq_to_desc()
      x86, UV: add uv_setup_irq() and uv_teardown_irq() functions, v3
      genirq: NULL struct irq_desc's member 'name' in dynamic_irq_cleanup=
()

Deepak Saxena (1):
      UBI: print reserved_peb when it is too large

Denis ChengRq (2):
      wireless: a global static to local static improvement
      block: mark bio_split_pool static

Denis Joseph Barrow (2):
      [netdrvr] usb/hso: throttle to prevent loss of serial data
      USB: option.c remove duplicate device ids now supported in hso.c

Denis V. Lunev (26):
      netns: move /proc/net/dev_snmp6 to struct net
      netns: register /proc/net/dev_snmp6/* in each ns
      ipv6: consolidate ipv6 sock_stat code at the beginning of net/ipv6/=
proc.c
      ipv6: separate seq_ops for global & per/device ipv6 statistics
      netns: register global ipv6 mibs statistics in each namespace
      netns: allow per device ipv6 snmp statistics in non-initial namespa=
ce
      netns: add stub functions for per/namespace mibs allocation
      netns: make udpv6 mib per/namespace
      netns: make uplitev6 mib per/namespace
      nfs: ERR_PTR is expected on failure from nfs_do_clone_mount
      sunrpc: do not pin sunrpc module in the memory
      nfs: BUG_ON in nfs_follow_mountpoint
      ipv6: local dev is actually unused in ip6_fragment
      ipv6: consolidate error paths in ipv6_frag_rcv
      netns: add net parameter to IP6_INC_STATS
      ipv6: added net argument to IP6_INC_STATS_BH
      ipv6: added net argument to IP6_ADD_STATS_BH
      ipv6: added net argument to ICMP6_INC_STATS
      ipv6: added net argument to ICMP6_INC_STATS_BH
      ipv6: added net argument to ICMP6MSGOUT_INC_STATS
      ipv6: added net argument to ICMP6MSGOUT_INC_STATS_BH
      ipv6: ICMP6MSGIN_INC_STATS is not used
      ipv6: added net argument to ICMP6MSGIN_INC_STATS_BH
      ipv6: added net argument to _DEVINC/_DEVADD
      ipv6: making ip and icmp statistics per/namespace
      ipv6: remove unused not init_ipv6_mibs/cleanup_ipv6_mibs

Dennis Aberilla (1):
      rtc: add device driver for Dallas DS3234 SPI RTC chip

Dennis Noordsij (1):
      ACPICA: Copy dynamically loaded tables to local buffer

Denys Vlasenko (4):
      mmap.c: deinline a few functions
      [SCSI] aic7xxx: introduce "dont_generate_debug_code" keyword in aic=
asm parser
      [SCSI] aic7xxx: update .reg files
      [SCSI] aic7xxx: update *_shipped files

Devin Heitmueller (8):
      V4L/DVB (9039): Add support for new i2c API provided in firmware ve=
rsion 1.20
      V4L/DVB (9044): Add support for Pinnacle PCTV HD Pro 801e (ATSC onl=
y)
      V4L/DVB (9045): Add Pinnacle 801e dependencies to KConfig
      V4L/DVB (9046): Add support for Non-Pro version of Pinnacle PCTV HD=
 USB Stick
      V4L/DVB (9114): dib0700: fix bad assignment of dib0700_xc5000_tuner=
_callback after return call
      V4L/DVB (9314): s5h1411: Perform s5h1411 soft reset after tuning
      V4L/DVB (9315): s5h1411: Skip reconfiguring demod modulation if alr=
eady at the desired modulation
      V4L/DVB (9316): s5h1411: Power down s5h1411 when not in use

Dhananjay Phadke (2):
      netxen: add pci ids
      netxen: enable msi-x for quad-gig boards

Dick Hollenbeck (1):
      [ARM] 5250/1: unbalanced enable_irq() for serial_ks8695.c fix

Diego Calleja (2):
      ext4: Update Documentation/filesystems/ext4.txt
      Staging: Fix leak in drivers/staging/at76_usb.c

Dimitri Sivanich (1):
      x86: remove EXPERIMENTAL restriction from CONFIG_HOTPLUG_CPU

Dimitris Michailidis (1):
      net: Fix off-by-one in skb_dma_map

Divy Le Ray (12):
      cxgb3 - remove duplicate tests in lro
      [2.6.28,1/1] cxgb3 - fix race in EEH
      cxgb3: reset the adapter on fatal error
      cxgb3: Allocate multiqueues at init time
      cxgb3: allow for PHY reset status
      cxgb3: simplify port type struct and usage
      cxgb3: More flexible support for PHY interrupts.
      cxgb3: commnonize LASI phy code
      cxgb3: Support for Aeluros 2005 PHY
      cxgb3: Add 1G fiber support
      cxgb3: update driver version
      cxgb3: extend copyrights to 2008

Dmitri Belimov (1):
      V4L/DVB (9065): saa7134: fix I2C remote controls on saa7134

Dmitry Adamushko (6):
      x86-microcode: fix unbalanced use of get_cpu()
      x86-microcode: generic interface refactoring
      x86, microcode rework, v2
      x86: moved microcode.c to microcode_intel.c
      x86, microcode_amd: cleanup, mark request_microcode_user() as unsup=
ported
      x86/microcode: fix sleeping function called from invalid context at=
 kernel/mutex.c

Dmitry Baryshkov (22):
      ALSA: ASoC: Permit simultaneous compilation of both PXA AC97 driver=
s
      [ARM] 5203/1: i2c-pxa: fix scheduling while atomic in i2c_pxa_abort=
()
      sound: ASoC: Support runtime selection of CPU in pxa2xx-i2s
      ALSA: Separate common pxa2xx-ac97 code
      ALSA: pxa2xx-ac97-lib: support building for several CPUs
      ALSA: Separate common pxa2xx-pcm code
      power_supply: fix dependency of tosa_battery
      [ARM] 4733/1: export sharpsl_param
      [ARM] 5298/1: Drop desc_handle_irq()
      [ARM] 5300/1: fixup spitz reset during boot
      platform: add new device registration helper
      gpio: make gpiochip label const
      gpio: max7301: fix the race between chip addition and pins reconfig=
uration
      fbdev: add new TMIO framebuffer driver
      mfd: provide and use setup hook for tc6393xb
      mfd: do tcb6393xb state restore on resume only if requested
      mfd: add OHCI cell to tc6393xb
      mfd: support tmiofb cell on tc6393xb
      backlight: add support for Sharp SL-6000 LCD and backlight drivers
      tosa: add support for bl/lcd driver
      SMC911x: unbreak PXA builds
      USB: ohci: add support for tmio-ohci cell

Dmitry Belimov (3):
      V4L/DVB (8795): saa7134-empress: insert leading null bytes for Beho=
lder M6 empress cards
      V4L/DVB (8796): saa7134-empress: remove incorrect IRQ defines for T=
S
      V4L/DVB (8797): A simple state machine was added to saa7134_ts.

Dmitry Torokhov (10):
      Input: gameport - make gameport_register_driver() return errors
      Input: gameport - check return value of gameport_register_driver()
      Input: gameport - mark gameport_register_driver() __must_check
      Input: expand keycode space
      Input: keyboard - fix potential out of bound access to key_map
      Input: ads7846 - fix cache line sharing issue
      Merge branch 'next' into for-linus
      hwmon: (ams) Fix permissions on 'joystick' module parameter
      hwmon: (ams) Fix locking issues
      hwmon: (ams) Simplify IRQ handling routine

Dominik Brodowski (51):
      pcmcia: only copy CIS override data once
      pcmcia: uniform device IDs of pata_pcmcia and ide-cs
      pcmcia: add pcmcia_loop_config() helper
      pcmcia: use pcmcia_loop_config in pata and ide drivers
      pcmcia: use pcmcia_loop_config in bluetooth drivers
      pcmcia: use pcmcia_loop_config in scsi pcmcia drivers
      pcmcia: use pcmcia_loop_config in ISDN pcmcia drivers
      pcmcia: use pcmcia_loop_config in net pcmcia drivers
      pcmcia: use pcmcia_loop_config in misc pcmcia drivers
      pcmcia: pcmcia_config_loop() ConfigIndex unification
      pcmcia: pcmcia_config_loop() default CIS entry handling
      pcmcia: pcmcia_config_loop() improvement by passing vcc
      pcmcia: use dev_printk and dev_dbg in yenta_socket
      pcmcia: use dev_printk in module pcmcia_core
      pcmcia: use dev_printk in module pcmcia
      pcmcia: use dev_printk in module rsrc_nonstatic
      pcmcia: remove unused cs_socket_name() definition
      pcmcia: don't add extra DEBUG cflag
      Merge branches 'pcmcia-config-loop' and 'pcmcia-printk' into pcmcia
      pcmcia: remove remaining in-kernel pcmcia_get_configuration_info() =
users
      pcmcia: move pccard_get_configuration_info to ioctl
      pcmcia: move config_info_t definition to ioctl-related parts in hea=
der files
      pcmcia: deprecate CS_SUCCESS
      pcmcia: deprecate unused CS_ error codes
      pcmcia: deprecate CS_OUT_OF_RESOURCE
      pcmcia: deprecate CS_UNSUPPORTED_*
      pcmcia: deprecate CS_BAD_VCC and CS_BAD_VPP
      pcmcia: deprecate CS_NO_CARD
      pcmcia: deprecate CS_GENERAL_FAILURE
      pcmcia: deprecate CS_BAD_HANDLE
      pcmcia: deprecate CS_CONFIGURATION_LOCKED
      pcmcia: deprecate CS_IN_USE
      pcmcia: deprecate CS_NO_MORE_ITEMS
      pcmcia: deprecate CS_BAD_ATTRIBUTE, CS_BAD_TYPE and CS_BAD_PAGE
      pcmcia: deprecate CS_BAD_BASE, CS_BAD_IRQ, CS_BAD_OFFSET and CS_BAD=
_SIZE
      pcmcia: deprecate CS_BAD_ARGS
      pcmcia: deprecate CS_BAD_TUPLE
      pcmcia: remove CS_ error codes alltogether
      pcmcia: use dev_printk for cs_error()
      pcmcia: cs_internal.h is internal
      pcmcia: cleanup cs_internal.h
      pcmcia: merge ds_internal.h into cs_internal.h
      pcmcia: cleanup socket services header file
      pcmcia: cleanup device driver header file
      pcmcia: encapsulate ioaddr_t
      pcmcia: device_id header cleanup
      pcmcia: card services header cleanup
      pcmcia: remove unused argument to pcmcia_parse_tuple()
      pcmcia: cistpl header cleanup
      pcmcia: ioctl-internal definitions
      cpufreq: remove policy->governor setting in drivers initialization

Douglas Schilling Landgraf (2):
      V4L/DVB (8936): em28xx-cards: Add vendor/product id for EM2820_BOAR=
D_PROLINK_PLAYTV_USB2
      V4L/DVB (8937): em28xx: Fix and add some validations

Drew Moseley (1):
      PNP: create device attributes via default device attributes

Duane Griffin (2):
      jbd2: abort instead of waiting for nonexistent transaction
      jbd: abort instead of waiting for nonexistent transactions

EG Keizer (1):
      nfs: authenticated deep mounting

Ed Swarthout (1):
      powerpc/85xx: Fix mpc8536ds dma interrupt numbers

Eduardo Habkost (3):
      x86, xen: Use native_pte_flags instead of native_pte_val for .pte_f=
lags
      xen_alloc_ptpage: cast PFN_PHYS() argument to unsigned long
      x86, paravirt_ops: use unsigned long instead of u32 for alloc_p*() =
pfn args

Ehud Gavron (1):
      b43legacy: Fix to enhance TX speed

Elias Oltmanns (7):
      [libata] Introduce ata_id_has_unload()
      libata: Implement disk shock protection support
      block: Fix blk_start_queueing() to not kick a stopped queue
      ide: Remove ide_spin_wait_hwgroup() and use special requests instea=
d
      ide: Two fixes regarding memory allocation
      ide: Implement disk shock protection support (v4)
      ata: Add documentation for hard disk shock protection interface (v3=
)

Elvis Pranskevichus (1):
      Input: ALPS - add signature for DualPoint found in Dell Latitude E6=
500

Emmanuel Grumbach (7):
      mac80211: Fix rate scale initialization in IBSS
      iwlwifi: fix strict_strtoul error checking
      iwlwifi: allow association on radar channel in power save
      iwlwifi: take a fresh set of supported rates at each cycle
      iwlwifi: remove uneeded declarations
      iwlwifi: remove HT flags from RXON when not in HT anymore
      mac80211: fix led behavior in IBSS

Enrico Scholz (6):
      [MTD] [NAND] pxa3xx_nand: moved nand definitions into shared platfo=
rm header
      [MTD] [NAND] pxa3xx_nand: allow to define flash types in the platfo=
rm data
      [MTD] [NAND] pxa3xx_nand: allow to disable builtin flash-type table
      [MTD] [NAND] pxa3xx_nand: added some 'const' annotations to the exp=
orted API
      [MTD] [NAND] pxa3xx_nand: moved some helper variables out from plat=
form data
      [MTD] [NAND] pxa3xx_nand: added warning which tells id of detected =
NAND

Eran Tromer (1):
      ALSA: usb-audio: add support for E-Mu Tracker Pre

Eric Anholt (17):
      agp: Fix stolen memory counting on G4X.
      i915: Add support for MSI and interrupt mitigation.
      Export kmap_atomic_pfn for DRM-GEM.
      drm: Add GEM ("graphics execution manager") to i915 driver.
      i915: Use struct_mutex to protect ring in GEM mode.
      DRM: Return -EBADF on bad object in flink, and return curent name i=
f it exists.
      drm: Avoid oops in GEM execbuffers with bad arguments.
      drm: G33-class hardware has a newer 965-style MCH (no DCC register).
      drm: Use ioremap_wc in i915_driver instead of ioremap, since we alw=
ays want WC.
      drm: Clean up many sparse warnings in i915.
      drm: Increment dev_priv->irq_received so i915_gem_interrupts count =
works.
      i915: GM45 has GM965-style MCH setup.
      drm: Remove two leaks of vblank reference count in error paths.
      i915: Enable IMR passthrough of vblank events before enabling it in=
 pipestat.
      i915: Don't dereference HWS in /proc debug files when it isn't init=
ialized.
      drm: Add 32-bit compatibility for DRM_IOCTL_UPDATE_DRAW.
      drm: Avoid oops in DRM_IOCTL_RM_DRAW if a bad handle is supplied.

Eric Dumazet (6):
      percpu: introduce DEFINE_PER_CPU_PAGE_ALIGNED() macro
      ip: speedup /proc/net/rt_cache handling
      udp: Improve port randomization
      inet: cleanup of local_port_range
      udp: complete port availability checking
      ipv4: Add a missing rcu_assign_pointer() in routing cache.

Eric Miao (64):
      [ARM] pxa: fix incorrect definitions of SSP3 on pxa320
      Input: ads7846 - introduce .gpio_pendown to get pendown state
      Input: ads7846 - introduce .gpio_pendown to get pendown state
      lcd: allow lcd device to handle mode change events
      lcd: add SPI-based LCD and backlight driver for SHARP corgi/spitz
      lcd: add corgibl_limit_intensity() to corgi_lcd
      lcd: add support for Toppoly TDO24M series LCD panels
      hwmon: add max1111 Low-power Multichannel Serial 8-bit ADCs
      hwmon: add max1111_read_channel() for use by sharpsl_pm
      [ARM] pxa/poodle: move scoop/locomo device registration earlier
      [ARM] pxa/poodle: use .gpio_pullup in USB device platform data
      [ARM] pxa/poodle: use new .lcd_conn to specify the LCD info
      [ARM] pxa/poodle: convert to use the new GPIO API
      [ARM] pxa/poodle: convert to use the new MFP API to configure pins
      [ARM] pxa/poodle: use SPI based ads7846 touch screen driver
      [ARM] pxa/corgi: convert to use new GPIO API
      [ARM] pxa/corgi: convert to use new MFP API
      [ARM] pxa/corgi: use SPI-based driver for ads7846, corgi-lcd and ma=
x1111
      [ARM] pxa/spitz: convert to use new GPIO API
      [ARM] pxa/spitz: convert to use new MFP API
      [ARM] pxa/spitz: use new .lcd_conn to specify the LCD info
      [ARM] pxa/spitz: use SPI-based driver for ads7846, corgi-lcd and ma=
x1111
      [ARM] pxa/corgi: remove now unused corgi_ssp.c and corgi_lcd.c
      [ARM] pxa/littleton: add support for SPI-based TDO24M LCD panel dri=
ver
      [ARM] pxa/poodle: prepare scoop for the generic GPIO API
      [ARM] pxa/corgi: use generic GPIO API for SCOOP GPIOs
      [ARM] pxa/corgi: use leds-gpio for led driving and drop leds-corgi
      [ARM] pxa/spitz: use generic GPIO API for SCOOP1/SCOOP2 GPIOs
      [ARM] pxa/spitz: use leds-gpio for led driving and drop leds-spitz
      [ARM] pxa/akita: use pca953x instead of akita-ioexp
      [ARM] corgi_lcd: use GPIO API for BACKLIGHT_ON and BACKLIGHT_CONT
      Documentation: fix the now deprecated reference to {set,reset}_scoo=
p_gpio
      [ARM] pxa: merge common cpu_is_pxa255() code together
      [ARM] pxa: make cpu_is_pxa2* macros more consistent
      [ARM] pxa: introduce cpu_is_pxa26x()
      [ARM] pxa: fix typo in pxa25x MFP definitions
      [ARM] pxa: better MFP low power state support for pxa25x/pxa27x
      [ARM] pxa/lubbock: add missing MFP pin configurations
      [ARM] pxa/colibri: convert to use new MFP API
      [ARM] pxa/idp: convert to use new MFP API
      [ARM] pxa/idp: make use of "lcd_conn", add LCD pin configurations
      [ARM] pxa/idp: remove the unnecessary idp_init_irq()
      [ARM] pxa/lpd270: convert to use new MFP API
      [ARM] pxa/lpd270: use new .lcd_conn to specify LCD info
      [ARM] pxa/pcm027: convert to use new MFP API
      [ARM] pxa: fix incorrect initialization of mfp sysdev when not pxa2=
xx
      [ARM] pxa: move i2c register and bit definitions into i2c-pxa.c
      [ARM] pxa: make additional DCSR bits valid for PXA3xx
      [ARM] pxa: simplify DMA register definitions
      [ARM] pxa: move I2S register and bit definitions into pxa2xx-i2s.c
      [ARM] ohci-pxa27x: introduce flags to avoid direct access to OHCI r=
egisters
      [ARM] ohci-pxa27x: move OHCI controller specific registers into the=
 driver
      [ARM] ohci-pxa27x: use platform_get_{irq,resource} for the resource
      [ARM] ohci-pxa27x: introduce pxa27x_clear_otgph()
      [ARM] ohci-pxa27x: use ioremap() and offset for register access
      [ARM] pxa/zylonite: add support for USB OHCI
      [ARM] pxa: rename cpu-pxa.c to cpufreq-pxa2xx.c
      [ARM] pxa: add missing ACCR bit definitions to pxa3xx-regs.h
      [ARM] pxa: add preliminary CPUFREQ support for PXA3xx
      da903x: add regulator support for DA9030/DA9034
      mfd: add base support for Dialog DA9030/DA9034 PMICs
      Revert "[ARM] pxa/corgi: remove now unused corgi_ssp.c and corgi_lc=
d.c"
      [ARM] pxa: fix the corgi_ssp.c dependency issue in {corgi,spitz}_de=
fconfig
      [ARM] pxa: update {corgi,spitz}_defconfig to favor SPI-based driver=
s

Eric Paris (1):
      securityfs: do not depend on CONFIG_SECURITY

Eric Piel (1):
      HP-WMI: additional keycode (or typo)

Eric Sandeen (5):
      ext4: Avoid printk floods in the face of directory corruption
      ext4: use percpu data structures for lg_prealloc_list
      Hook ext4 to the vfs fiemap interface.
      ext2: avoid printk floods in the face of directory corruption
      ext3: avoid printk floods in the face of directory corruption

Eric Sesterhenn (5):
      hfsplus: fix Buffer overflow with a corrupted image
      hfsplus: check read_mapping_page() return value
      hfs: fix namelength memory corruption
      ext4: Add missing newlines to printk messages
      hfsplus: fix possible deadlock when handling corrupted extents

Eric Van Hensbergen (26):
      9p: consolidate transport structure
      9p: remove duplicate client state
      9p: remove unnecessary prototypes
      9p: consolidate mux_rpc and request structure
      9p: eliminate callback complexity
      9p: move request management to client code
      9p: apply common tagpool handling to trans_fd
      9p: apply common request code to trans_fd
      9p: use the rcall structure passed in the request in trans_fd read_=
work
      9p: make rpc code common and rework flush code
      9p: consolidate read/write functions
      9p: move readn meta-function from client to fs layer
      9p: adjust 9p vfs write operation
      9p: move dirread to fs layer
      9p: encapsulate version function
      9p: add new protocol support code
      9p: remove 9p fcall debug prints
      9p: remove unnecessary tag field from p9_req_t structure
      9p: rework client code to use new protocol support functions
      9p: eliminate depricated conv functions
      9p: Improve debug support
      9p: fix oops in protocol stat parsing error path.
      9p: add more conservative locking
      9p: fix debug build error
      9p: fix format warning
      9p: fix sparse warnings

Eric W. Biederman (3):
      genirq: enable polling for disabled screaming irqs
      kobject: Fix kobject_rename and !CONFIG_SYSFS
      kobject: Cleanup kobject_rename and !CONFIG_SYSFS

Erik Andren (11):
      V4L/DVB (9091): gspca: Subdriver m5602 (ALi) added.
      V4L/DVB (9093): gspca: Cleanup code and small changes.
      V4L/DVB (9094): gspca: Frame counter in ALi m5602.
      V4L/DVB (9095): gspca: Moves some sensor initialization to each sen=
sor in m5602.
      V4L/DVB (9096): gspca: Subdriver selection at config time.
      V4L/DVB (9123): gspca: Add some lost controls to the s5k83a sensor.
      V4L/DVB (9277): gspca: propagate an error in m5602_start_transfer()
      V4L/DVB (9278): gspca: Remove the m5602_debug variable
      V4L/DVB (9279): gspca: Correct some copyright headers
      V4L/DVB (9280): gspca: Use the gspca debug macros
      V4L/DVB (9281): gspca: Add hflip and vflip to the po1030 sensor

Erik Andr=C3=A9n (2):
      V4L/DVB (9282): Properly iterate the urbs when destroying them.
      V4L/DVB (9283): Correct typo and enable setting the gain on the mt9=
m111 sensor

Ester Kummer (1):
      iwlwifi: enable power save setting upon config

Esti Kummer (1):
      iwlwifi: add level for debugging host command

Eugene Dashevsky (1):
      ext3: fix ext3_dx_readdir hash collision handling

FD Cami (1):
      Remove Andrew Morton's http://www.zip.com.au/~akpm/

FUJITA Tomonori (58):
      x86 gart: allocate size-aligned address for alloc_coherent, v2
      dma-mapping.h, x86: remove last user of dma_mapping_ops->map_simple
      x86: dma_*_coherent rework patchset v2, fix
      x86: gart alloc_coherent doesn't need to check NULL device argument
      ia64: dma_alloc_coherent always use GFP_DMA
      x86: move pci-nommu's dma_mask check to common code
      x86: fix nommu_alloc_coherent allocation with NULL device argument
      x86: dma_alloc_coherent sets gfp flags properly
      swiotlb: remove GFP_DMA hack in swiotlb_alloc_coherent
      swiotlb: use map_single instead of swiotlb_map_single in swiotlb_al=
loc_coherent
      swiotlb: use unmap_single instead of swiotlb_unmap_single in swiotl=
b_free_coherent
      swiotlb: add is_swiotlb_buffer helper function
      add is_buffer_dma_capable helper function
      x86: convert gart to use is_buffer_dma_capable helper function
      x86: convert pci-nommu to use is_buffer_dma_capable helper function
      swiotlb: convert swiotlb to use is_buffer_dma_capable helper functi=
on
      x86: remove duplicated extern force_iommu
      x86: convert dma_alloc_coherent to use is_device_dma_capable
      iommu: add iommu_device_max_index IOMMU helper function
      iommu: add dma_get_mask helper function
      x86: make GART to respect device's dma_mask about virtual mappings
      x86: avoid unnecessary low zone allocation in Calgary's alloc_coher=
ent
      x86: gart alloc_coherent does virtual mapppings only when necessary
      convert swiotlb to use dma_get_mask
      AMD IOMMU: avoid unnecessary low zone allocation in alloc_coherent
      iommu: export iommu_area_reserve helper function
      x86: remove set_bit_string()
      iommu: remove fullflush and nofullflush in IOMMU generic option
      x86: export pci-nommu's alloc_coherent
      revert "x86: make GART to respect device's dma_mask about virtual m=
appings"
      x86: restore old GART alloc_coherent behavior
      x86 gart: remove unnecessary initialization
      AMD IOMMU: use iommu_device_max_index
      [SCSI] scsi_dh: no need to initialize rq->cmd with blk_get_request
      block: add gfp_mask argument to blk_rq_map_user and blk_rq_map_user=
_iov
      block: introduce struct rq_map_data to use reserved pages
      sg: convert the non-data path to use the block layer
      sg: convert the direct IO path to use the block layer
      sg: convert the indirect IO path to use the block layer
      bio: convert bio_copy_kern to use bio_copy_user
      block: add blk_rq_aligned helper function
      sg: use blk_rq_aligned helper function
      block: make blk_rq_map_user take a NULL user-space buffer
      sg: set dxferp to NULL for READ with the older SG interface
      sg: rename sg_cmd_done sg_rq_end_io
      sg: remove SG_ALLOW_DIO_CODE define
      sg: remove b_malloc_len in sg_scatter_hold struct
      sg: remove __sg_start_req
      sg: incorporate sg_build_direct into sg_start_req
      sg: remove sg_write_xfer
      sg: remove sg_read_xfer
      sg: remove unnecessary blk_rq_unmap_user
      fix an example of scatterlists handling in DMA-API.txt
      ide-cd: use the new object_is_in_stack() helper
      block: fix nr_phys_segments miscalculation bug
      intel-iommu: use coherent_dma_mask in alloc_coherent
      [SCSI] 3w-xxxx: remove unnecessary local_irq_save/restore for scsi =
sg copy API
      [SCSI] 3w-9xxx: remove unnecessary local_irq_save/restore for scsi =
sg copy API

Faisal Latif (2):
      RDMA/nes: Make mini_cm_connect() static
      RDMA/nes: Handle AE bounds violation

Felipe Balbi (11):
      rfkill: add missing line break
      [WATCHDOG] omap_wdt.c: sync linux-omap changes
      [WATCHDOG] omap_wdt.c: another ioremap() fix
      [WATCHDOG] omap_wdt.c: cleanup a bit omap_wdt.c
      V4L/DVB (8724): dvb: drx397xD: checkpatch.pl cleanups
      i2c/isp1301_omap: Convert to a new-style i2c driver, part 1
      usb gadget: cdc obex glue
      usb: gadget: workaround storage command size issues
      musb: io: only define read/write stubs if they're not defined yet
      usb: musb: general cleanup to musbhsdma.c
      usb: musb: remove dead code from procfs

Felipe Zimmerle (1):
      wusb: wusb-cbaf (CBA driver) sysfs ABI simplification

Felix Fietkau (5):
      mac80211: free up 2 bytes in skb->cb
      mac80211: add multi-rate retry support
      ath5k: implement multi-rate retry support, fix tx status reporting
      mac80211: add the 'minstrel' rate control algorithm
      rt2x00: fix regression introduced by "mac80211: free up 2 bytes in =
skb->cb"

Fenghua Yu (2):
      [IA64] Add Variable Page Size and IA64 Support in Intel IOMMU
      intel-iommu: IA64 support

Fernando Luis V=C3=A1zquez Cao (1):
      virtio_blk: use a wrapper function to access io context information=
 of IO requests

Finn Thain (1):
      V4L/DVB (9038): Add support for the Gigabyte R8000-HT USB DVB-T ada=
pter.

Fiodor Suietov (1):
      ACPICA: Add check for invalid handle in acpi_get_object_info

Flemming Frandsen (1):
      [WATCHDOG] Add driver for winbond w83697ug/uf watchdog feature

Florent Fourcot (1):
      rtl8187: Add USB ID for Belkin F5D7050 with RTL8187B chip

Florian Fainelli (13):
      r6040: fix bad usage of udelay
      r6040: fix wrong assignment in r6040_free_txbufs
      MIPS: RB532: Cleanup and group definitions to their right places
      MIPS: RB532: Use physical addresses for gpio and device controller =
registers
      MIPS: RB532: Remove gpio bootup state
      MIPS: RB532: replace raw volatile read with a readl
      MIPS: RB532: Fix id usage in platform devices
      MIPS: RB532: Remove obsolute reference to setup_serial_port
      MIPS: RB532: Cleanup the headers again
      MIPS: RB532: Remove unused rc32434_sync_delay and rc32434_sync_udel=
ay
      MIPS: RB532: Convert to GPIO lib
      Documentation: Document the RB532 specific kmac tag
      MIPS: RB532: provide GPIO_BUILTIN_NR and irq_to_gpio/gpio_to_irq

Florian Funke (1):
      [S390] introduce dirty bit for kvm live migration

Francesco Virlinzi (1):
      sh: fix the TMU code to allow a fully running NO_HZ system

Francois Cami (1):
      Remove Andrew Morton's old email accounts

Francois Romieu (27):
      r8169: get ethtool settings through the generic mii helper
      r8169: Tx performance tweak helper
      r8169: use pci_find_capability for the PCI-E features
      r8169: add 8168/8101 registers description
      r8169: add hw start helpers for the 8168 and the 8101
      r8169: additional 8101 and 8102 support
      r8169: fix RxMissed register access
      r8169: select MII in Kconfig
      via-velocity: Fix warnings on sparc64.
      r8169: fix early spinlock use
      r8169: wake up the PHY of the 8168
      r8169: update phy init parameters
      r8169: new phy init parameters for the 8168b
      r8169: shuffle some registers handling around (8168 operation only)
      r8169: make room for more specific 8168 hardware start procedure
      r8169: 8168b Tx performance tweak
      r8169: sync existing 8168 device hardware start sequences with vend=
or driver
      r8169: add a new 8168c flavor
      r8169: add a new 8168c flavor (bis)
      r8169: add a new 8168cp flavor
      r8169: change default behavior for mildly identified 8168c chipsets
      r8169: support additional 8168cp chipset
      r8169: preliminary 8168d support
      r8169: add shutdown handler
      r8169: verbose mac address init
      r8169: checks against wrong mac addresse init
      sis190: add identifier for Atheros AR8021 PHY

Frank Leipold (1):
      uwb: wrong sizeof argument in mac address compare

Frank Mandarino (1):
      ALSA: ASoC: Remove references to Endrelia ETI-B1 board

Frank Mayhar (3):
      timers: fix itimer/many thread hang
      timers: fix itimer/many thread hang, v2
      timers: fix itimer/many thread hang, v3

Frank Zago (6):
      V4L/DVB (9077): gspca: Set the right V4L2_DEBUG values in the main =
driver.
      V4L/DVB (9084): gspca: Fixed a few typos in comments.
      V4L/DVB (9085): gspca: URB_NO_TRANSFER_DMA_MAP is required for isoc=
 and bulk transfers.
      V4L/DVB (9086): gspca: Use a kref to avoid potentialy blocking fore=
ver in disconnect.
      V4L/DVB (9088): gspca: New subdriver 'finepix' added.
      V4L/DVB (9090): gspca: Restart the state machine when no frame buff=
er in finepix.

Frans Pop (2):
      e1000e: avoid duplicated output of device name in kernel warning
      pm: document use of RTC in pm_trace

Frederic Bohe (2):
      Update flex_bg free blocks and free inodes counters when resizing.
      ext4: fix initialization of UNINIT bitmap blocks

Frederic Weisbecker (14):
      softirq, warning fix: correct a format to avoid a warning
      cpusets: scan_for_empty_cpusets(), cpuset doesn't seem to be so con=
st
      tracing/ftrace: change the type of the print_line callback
      tracing/ftrace: adapt mmiotrace to the new type of print_line
      tracing/ftrace: adapt the boot tracer to the new print_line type
      tracing/ftrace: adapt mmiotrace to the new type of print_line, fix
      tracing/fastboot: change the printing of boot tracer according to b=
ootgraph.pl
      tracing/fastboot: get the initcall name before it disappears
      tracing/fastboot: only trace non-module initcalls
      ftrace: return an error when setting a nonexistent tracer
      tracing/fastboot: fix initcalls disposition in bootgraph.pl
      tracing/fastboot: fix initcalls disposition in bootgraph.pl
      sparc: correct section of apc_no_idle
      sparc: correct section of current_pc()

From: Greg Kroah-Hartman (1):
      HID: remove warn() macro from usb hid drivers

Fr=C3=A9d=C3=A9ric Marchal (1):
      USB: Unusual dev for Mio moov 330 gps

Fr=C3=A9d=C3=A9ric Weisbecker (11):
      ftrace: fix some mistakes in error messages
      tracing/ftrace: make nop tracer reset previous entries
      tracing/ftrace: tracing engine depends on Nop Tracer
      tracing/ftrace: replace none tracer by nop tracer
      x86/ftrace: use uaccess in atomic context
      tracing/ftrace: add the boot tracer
      tracing/ftrace: make tracing suitable to run the boot tracer
      tracing/ftrace: give an entry on the config for boot tracer
      tracing/ftrace: launch boot tracing after pre-smp initcalls
      ftrace/fastboot: disable tracers self-tests when boot tracer is sel=
ected
      tracing/ftrace: don't consume unhandled entries by boot tracer

Gautham R Shenoy (1):
      sched: fix __load_balance_iterator() for cfq with only one task

Geert Uytterhoeven (20):
      powerpc: Remove remains of /proc/ppc_htab
      powerpc: Remove outdated Documentation/powerpc/smp.txt
      m68k: Use new printk() extension %pS to print symbols
      m68k: Reverse platform MMU logic so Sun 3 is last
      m68k: Modular Amiga keyboard needs key_maps
      m68k: Remove unused atari_kbd_translate()
      m68k: Define rtc_lock on Atari
      m68k: Add missing dma_sync_single_range_for_{cpu,device}()
      m68k: <asm/pci.h> needs <asm-generic/pci-dma-compat.h>
      HP input: kill warnings due to suseconds_t differences
      m68k: init_irq_proc depends on CONFIG_PROC_FS
      m68k: Atari SCSI needs NVRAM
      net/rfkill/rfkill-input.c needs <linux/sched.h>
      identify_ramdisk_image(): correct typo about return value in commen=
t
      rtc: rtc-ds1286 and rtc-m48t35 need <linux/io.h>
      [JFFS2] Correct parameter names of jffs2_compress() in comments
      V4L/DVB (9275): dvb: input data pointer of cx24116_writeregN() shou=
ld be const
      UBIFS: fix ubifs_compress commentary
      Staging: W35UND should depend on USB
      PCI: PCI_QUIRKS depends on PCI

Geoff Levand (2):
      USB: Fix doc for usb_autopm_enable
      USB: Fix spelling in usb/serial.h

George G. Davis (1):
      [MTD] [NOR] Add "Spansion" to MTD_CFI_AMDSTD kconfig menu descripti=
on

Gerald Schaefer (1):
      setup_per_zone_pages_min(): take zone->lock instead of zone->lru_lo=
ck

Gerrit Renker (109):
      dccp: Silently ignore options with nonsensical lengths
      dccp: Fill in the Data fields for "Option Error" Resets
      dccp: Empty the write queue when disconnecting
      dccp: Toggle debug output without module unloading
      dccp ccid-3: Replace lazy BUG_ON with condition
      dccp: Silently ignore options with nonsensical lengths
      dccp: Fill in the Data fields for "Option Error" Resets
      dccp: Empty the write queue when disconnecting
      dccp: Toggle debug output without module unloading
      dccp ccid-3: Replace lazy BUG_ON with condition
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
      dccp: Initialisation framework for feature negotiation
      dccp: Auto-load (when supported) CCID plugins for negotiation
      dccp: Implement both feature-local and feature-remote Sequence Wind=
ow feature
      dccp: Initialisation and type-checking of feature sysctls
      dccp: Debugging functions for feature negotiation
      dccp: Support for the exchange of NN options in established state
      dccp: Support for exchanging of NN options in established state
      dccp ccid-2: Use feature-negotiation to report Ack Ratio changes
      dccp: Leave headroom for options when calculating the MPS
      dccp: Special case of the MPS for client-PARTOPEN with DataAcks
      dccp ccid-2: Remove ccid2hc{tx,rx}_ prefixes
      dccp ccid-3: Remove ccid3hc{tx,rx}_ prefixes
      dccp ccid-3: No more CCID control blocks in LISTEN state
      dccp ccid-3: Bug fix for the inter-packet scheduling algorithm
      dccp ccid-3: Remove ugly RTT-sampling history lookup
      dccp ccid-3: Simplify and consolidate tx_parse_options
      dccp: Add packet type information to CCID-specific option parsing
      dccp tfrc/ccid-3: Computing Loss Rate from Loss Event Rate
      dccp ccid-3: Remove redundant 'options_received' struct
      dccp: Replace magic CCID-specific numbers by symbolic constants
      dccp: Unused argument in CCID tx function
      dccp ccid-3: Remove duplicate documentation
      dccp ccid-3: Remove dead states
      dccp: Schedule an Ack when receiving timestamps
      dccp: Fix the adjustments to AWL and SWL
      dccp: Merge now-reduced connect_init() function
      dccp: Reduce noise in output and convert to ktime_t
      dccp ccid-2: Ack Vector interface clean-up
      dccp ccid-2: Separate internals of Ack Vectors from option-parsing =
code
      dccp ccid-2: Implementation of circular Ack Vector buffer with over=
flow handling
      dccp ccid-2: Algorithm to update buffer state
      dccp ccid-2: Update code for the Ack Vector input/registration rout=
ine
      dccp ccid-2: Consolidate Ack-Vector processing within main DCCP mod=
ule
      dccp ccid-2: Schedule Sync as out-of-band mechanism
      dccp ccid-2: Remove old infrastructure
      dccp ccid-2: Separate option parsing from CCID processing
      dccp: Return-value convention of hc_tx_send_packet()
      dccp: Extend CCID packet dequeueing interface
      dccp: Refine the wait-for-ccid mechanism
      dccp ccid-2: Stop polling
      dccp ccid-2: Remove redundant sanity tests
      dccp ccid-2: Simplify dec_pipe and rearming of RTO timer
      dccp ccid-2: Replace broken RTT estimator with better algorithm
      dccp ccid-2: Remove wrappers around sk_{reset,stop}_timer()
      dccp: Combine the functionality of enqeueing and cloning
      tcp/dccp: Consolidate common code for RFC 3390 conversion
      dccp: Clean up slow-path input processing
      dccp ccid-3: Runtime verification of timer resolution
      dccp ccid-3: Simplified handling of TX states
      dccp tfrc: Suppress unavoidable "below resolution" warning
      dccp tfrc: Receiver history initialisation routine
      dccp tfrc: Perform early loss detection
      dccp tfrc: Return type of update_i_mean is void
      dccp tfrc: Let dccp_tfrc_lib do the sampling work
      dccp ccid-3: Remove duplicate RX states
      dccp ccid-3: Always perform receiver RTT sampling
      dccp: Clamping RTT values
      dccp tfrc: Increase number of RTT samples
      dccp ccid-3: Update the computation of X_recv
      dccp ccid-3: Update the RX history records in one place
      dccp ccid-3: Implement rfc3448bis change to initial-rate computatio=
n
      dccp ccid-3: Tidy up CCID-Kconfig dependencies
      dccp ccid-3: Measuring the packet size s with regard to rfc3448bis-=
06
      dccp ccid-3: Simplify computing and range-checking of t_ipi
      dccp ccid-3: Preventing Oscillations
      This reverts "Merge branch 'dccp' of git://eden-feed.erg.abdn.ac.uk=
/dccp_exp"
      dccp: Port redirection support for DCCP

Gertjan van Wingerde (2):
      rt2x00: Fix build errors due to modularized rfkill or leds and buil=
t-in rt2x00.
      rt2x00: Fix rfkill structure initialization to prevent rfkill WARN_=
ON.

Gilles Chanteperdrix (3):
      i.MX31ADS: Enable the first IMX serial port. (take 3)
      i.MX31ADS: Add CPLD interrupts demultiplexing (take 3).
      [NET] 5268/1: cs89x0: add support for i.MX31ADS ARM board.

Glauber Costa (16):
      x86: use user_mode macro
      x86: coalesce tests
      x86: set bp field in pt_regs properly
      x86: use frame pointer information on x86_64 profile_pc
      x86: remove SEGMENT_IS_FLAT_CODE
      x86: use user_mode_vm instead of user_mode
      x86: bind irq0 irq data to cpu0
      x86: factor out irq initialization for x86_64
      x86: make init_ISA_irqs nonstatic
      x86: rename timer_event_interrupt to timer_interrupt
      x86: replace hardcoded number
      x86: wrap MCA_bus test around an ifdef
      x86: move vgetcpu mode probing to cpu detection
      x86: paravirt: factor out cpu_khz to common code
      x86: KVM guest: use paravirt function to calculate cpu khz
      KVM: Don't destroy vcpu in case vcpu_setup fails

Gleb Natapov (1):
      KVM: don't enter guest after SIPI was received by a CPU

Graf Yang (9):
      Blackfin arch: add CONFIG_APP_STACKS_L1 to enable or disable puttin=
g kernel stacks in L1
      Blackfin arch: add a meaningful name for each irqchip
      Blackfin arch: Modify some funtion names to more genernal ones
      Blackfin arch: Not call generic set_irq_handler() in bfin_gpio_irq_=
type() due to spinlock recursion
      Blackfin arch: fix define error in BF561 memory map macros
      Blackfin arch: correct icache size in show_cpuinfo(), let c_start()=
 return proper pointer
      Blackfin arch: Remove useless head file
      Blackfin Serial Driver: Fix bug - ircp fails on sir over Blackfin U=
ART
      Blackfin arch: Zero out bss region in L1/L2 memory.

Grant Likely (7):
      ALSA: ASoC: Add OpenFirmware helper for matching bus and codec driv=
ers
      ALSA: ASoC: Add mpc5200-psc I2S driver
      ALSA: ASoC: Add Texas Instruments TLV320AIC26 codec driver
      powerpc/mpc5200: fix build warnings on mpc52xx_psc_spi driver
      powerpc/of-bindings: Don't support linux,<modalias> "compatible" va=
lues
      powerpc/52xx: Make cuImage more robust in locating immr node.
      powerpc: Add missing cuImage.initrd.% target

Greg Kroah-Hartman (57):
      uwb: add the UWB stack (build system)
      uwb: add WiMedia LLC Protocol (build system)
      wusb: add the Wireless USB core (build-system)
      Staging: add TAINT_CRAP for all drivers/staging code
      Staging: add TAINT_CRAP flag to drivers/staging modules
      Staging: add Kconfig entries and Makefile infrastructure
      Staging: add MAINTAINERS entry
      Staging: add et131x network driver
      Staging: add Alacritech slicoss network driver
      Staging: add sxg network driver
      Staging: add me4000 firmware files
      Staging: add me4000 pci data collection driver
      Staging: add the go7007 video driver
      Staging: add wlan-ng prism2 usb driver
      V4L/DVB (9116): USB: remove info() macro from usb media drivers
      Staging: workaround build system bug
      HID: remove info() macro from usb HID drivers
      device create: block: convert device_create_drvdata to device_creat=
e
      device create: char: convert device_create_drvdata to device_create
      device create: ieee1394: convert device_create_drvdata to device_cr=
eate
      device create: infiniband: convert device_create_drvdata to device_=
create
      device create: misc: convert device_create_drvdata to device_create
      device create: net: convert device_create_drvdata to device_create
      device create: s390: convert device_create_drvdata to device_create
      device create: scsi: convert device_create_drvdata to device_create
      device create: sound: convert device_create_drvdata to device_creat=
e
      device create: usb: convert device_create_drvdata to device_create
      device create: video: convert device_create_drvdata to device_creat=
e
      device create: ide: convert device_create_drvdata to device_create
      device create: remove device_create_drvdata
      NET: convert the phy_device file to use bus_find_device_by_name
      Driver core: add bus_sort_breadthfirst() function
      USB: add USB test and measurement class driver
      USB: remove warn() macro from usb input drivers
      USB: remove warn() macro from usb media drivers
      USB: remove warn() macro from usb net drivers
      USB: remove warn() macro from usb drivers
      USB: remove warn macro from HID core
      USB: remove info() macro from usb/serial drivers
      USB: remove info() macro from usb/misc drivers
      USB: remove info() macro from remaining usb drivers
      USB: remove info() macro from usb network drivers
      USB: remove info() macro from usb input drivers
      USB: remove info() macro from usb mtd drivers
      USB: remove use of err() in drivers/usb/serial
      USB: remove err() macro from usb class drivers
      USB: remove err() macro from usb core code
      USB: remove err() macro from usb misc drivers
      USB: remove err() macro from more usb drivers
      Staging: document 4k stack problem for winbond driver
      Staging: wlan-ng: fix build error if wireless networking is not ena=
bled
      Staging: pcc-acpi: update to latest version
      Staging: sxg: fix up unused function warnings
      Staging: sxg: fix compiler warnings.
      Staging: wbusb: fix a bunch of compiler warnings
      Staging: me4000: remove some compiler warnings
      Staging: usbip: fix build warning on 64bit kernels

Grumbach, Emmanuel (1):
      iwlwifi: use the results from disconnected antenna algorithm

Guennadi Liakhovetski (8):
      smc911x: Fix external PHY detection
      V4L/DVB (8685): mt9m001, mt9v022: Simplify return code checking
      V4L/DVB (8686): mt9m111: style cleanup
      V4L/DVB (8799): soc-camera: add API documentation
      smc911x: Add support for LAN921{5,7,8} chips from SMSC
      pxa2xx_spi: minor cleanup
      V4L/DVB (9241): soc-camera: move sensor power management to soc_cam=
era_platform.c
      sh: fix soc-camera compile breakage on Migo-R.

Guillaume GARDET (1):
      [ARM] 5228/1: Add the RGB555 wiring for the atmel LCD

Guillaume Thouvenin (3):
      KVM: x86 emulator: Add DstAcc operand type
      KVM: x86 emulator: Add cmp al, imm and cmp ax, imm instructions (oc=
odes 3c, 3d)
      KVM: x86 emulator: Use DstAcc for 'and'

Guo-Fu Tseng (5):
      jme: JMicron Gigabit Ethernet Driver
      jme: Added half-duplex mode and IPv6 RSS fix
      jme: Advances version number
      nf_conntrack_ecache.h: Fix missing braces
      tcpv6: fix error with CONFIG_TCP_MD5SIG disabled

Gustavo F. Padovan (8):
      x86: coding styles fixes to arch/x86/kernel/process_64.c
      x86: add KERN_INFO to printks on process_64.c
      x86: coding style fixes to arch/x86/kernel/crash_dump_64.c
      x86: coding style fixes to arch/x86/kernel/signal_64.c
      x86: coding style fixes to arch/x86/kernel/traps_64.c
      x86: coding style fixes to arch/x86/kernel/sys_x86_64.c
      x86: coding style fixes to arch/x86/kernel/traps_64.c
      x86: remove redundant KERN_DEBUG on pr_debug

Guy Cohen (2):
      iwlwifi: fix searching for best rate in new search column
      iwlwifi: Added support for 3 antennas

H. Peter Anvin (32):
      x86: doc: move x86-generic documentation from Doc/x86/i386
      x86: doc: boot.txt: fix the size of the start_sys field
      x86, xsave: add <asm/xcr.h> header file for XCR registers
      x86, xsave: keep the XSAVE feature mask as an u64
      x86: boot: stub out unimplemented CPU feature words
      x86: add NOPL as a synthetic CPU feature bit
      x86: use X86_FEATURE_NOPL in alternatives
      x86: <asm/asm.h> consistency cleanups
      Merge branch 'x86/urgent' into x86/cleanups
      x86: msr-on-cpu: remove unnecessary level of abstraction
      Merge branch 'x86/urgent' into x86/cpu
      x86: generate names for /proc/cpuinfo from <asm/cpufeature.h>
      x86: cpufeature: add Intel features from CPUID and AVX specs
      x86: <asm/cpufeature.h>: clean up overlong lines, whitespace
      x86: cpufeature: fix SMX flag
      x86: boot/compressed/Makefile: fix "make clean"
      Merge branch 'x86/cpu' into x86/core
      Merge branch 'linus' into x86/core
      Merge branch 'x86/cpu' into x86/xsave
      Merge branch 'x86/cpu' into x86/x2apic
      x86: additional defconfig updates
      x86: when building image.iso, use isohybrid if it exists
      kbuild: fix cc-option and cc-option-yn
      x86: prevent binutils from being "smart" and generating NOPLs for u=
s
      x86 setup: handle more than 8 CPU flag words
      Revert "x86: fix ghost EDD devices in /sys again"
      dyn_array: don't break compiling for !CONFIG_SMP
      x86: Fix ASM_X86__ header guards
      x86: drop double underscores from header guards
      x86: canonicalize remaining header guards
      [SCSI] lib: string_get_size(): don't hang on zero; no decimals on e=
xact
      [SCSI] sd: fix computation of the full size of the device

Haavard Skinnemoen (20):
      avr32: Provide a way to deselect pins in the portmux
      atmel-mci: Initialize BLKR before sending data transfer command
      atmel-mci: Implement tasklet as a state machine
      atmel-mci: Don't stop the clock between transfers
      atmel-mci: Platform code for supporting multiple mmc slots
      atmel-mci: support multiple mmc slots
      atmel-mci: Add experimental DMA support
      atmel-mci: Don't overwrite error bits when NOTBUSY is set
      atmel-mci: Add missing flush_dcache_page() in PIO transfer code
      avr32: Implement {read,write}[bwl]_be
      avr32: Minor pm_power_off cleanup
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/hskinnemoen/atmel-mci-2.6.28
      avr32: Fix build failures in board code
      avr32: Kconfig: Remove pointless if around atstk1000 include
      avr32: Add defconfig for the mimc200 board
      avr32: Add defconfig for the favr-32 board
      [MTD] [NOR] AT49BV6416 has swapped erase regions
      avr32: Scale loops_per_jiffy when cpu frequency changes
      avr32: Fix GPIO initcall breakage
      Merge branches 'boards' and 'fixes' of git://git.kernel.org/pub/scm=
/linux/kernel/git/hskinnemoen/avr32-2.6

Hannes Hering (3):
      ehea: Fix DLPAR memory handling
      ehea: Enable DLPAR memory remove
      ehea: Fix memory hotplug support

Hans J. Koch (2):
      UIO: Add alignment warnings for uio-mem
      UIO: Change driver name of uio_pdrv

Hans Schou (1):
      x86, debug: print more information about unknown CPUs

Hans Verkuil (67):
      V4L/DVB (8613): v4l: move BKL down to the driver level.
      V4L/DVB (8630): First mxb cleanup phase
      V4L/DVB (8635): v4l: add AC-3 audio support to the MPEG Encoding AP=
I
      V4L/DVB (8636): v4l2: add v4l2_ctrl_get_name control support functi=
on.
      V4L/DVB (8637): v4l2: add v4l2_ctrl_query_menu_valid_items support =
function
      V4L/DVB (8639): saa6752hs: cleanup and add AC-3 support
      V4L/DVB (8640): saa6752hs: add PMT table for AC3
      V4L/DVB (8641): arv: fix compilation errors/warnings
      V4L/DVB (8649): v4l2: add AAC bitrate control
      V4L/DVB (8689): dpc7146: remove dpc7146 demonstration board driver
      V4L/DVB (8690): tuner-3036: remove driver
      V4L/DVB (8691): i2c-id: remove obsolete SAB3036 driver ID
      V4L/DVB (8695): usbvideo: add proper error check and add release fu=
nction
      V4L/DVB (8745): v4l2: fix a bunch of compile warnings.
      V4L/DVB (8746): v4l-dvb: fix compile warnings.
      V4L/DVB (8776): radio: replace video_exclusive_open/release
      V4L/DVB (8777): tea575x-tuner: replace video_exclusive_open/release
      V4L/DVB (8780): v4l: replace the last uses of video_exclusive_open/=
release
      V4L/DVB (8781): v4l2-dev: remove obsolete video_exclusive_open/rele=
ase
      V4L/DVB (8782): v4l2-dev: add video_device_release_empty
      V4L/DVB (8783): v4l: add all missing video_device release callbacks
      V4L/DVB (8784): v4l2-dev: make the video_device's release callback =
mandatory
      V4L/DVB (8785): v4l2: add __must_check to v4l2_dev.h
      V4L/DVB (8786): v4l2: remove the priv field, use dev_get_drvdata in=
stead
      V4L/DVB (8787): v4l2-dev: cleanups and add video_drvdata helper fun=
ction
      V4L/DVB (8788): v4l: replace video_get_drvdata(video_devdata(filp))=
 with video_drvdata(filp)
      V4L/DVB (8791): v4l2-dev: do not clear the driver_data field
      V4L/DVB (8850): bt856: fix define conflict
      V4L/DVB (8852): v4l2: use register_chrdev_region instead of registe=
r_chrdev
      V4L/DVB (8856): v4l: fix assorted compile warnings/errors
      V4L/DVB (8857): v4l2-dev: replace panic with BUG
      V4L/DVB (8906): v4l-dvb: fix assorted sparse warnings
      V4L/DVB (8917): saa7134-empress: fix changing the capture standard =
for non-tuner inputs
      V4L/DVB (8918): saa6752hs: simplify writing to registers
      V4L/DVB (8920): cx18/ivtv: fix check of window boundaries for VIDIO=
C_S_FMT
      V4L/DVB (8921): ivtv: fix incorrect capability and assorted sliced =
vbi and video out fmt fixes
      V4L/DVB (8939): cx18: fix sparse warnings
      V4L/DVB (8940): saa7115: fix saa7111(a) support
      V4L/DVB (8941): mxb/tda9840: cleanups, use module saa7115 instead o=
f saa7111.
      V4L/DVB (8942): mxb: coding style cleanups
      V4L/DVB (8943): saa5246a: convert i2c driver for new i2c API
      V4L/DVB (8944): saa5249: convert i2c driver for new i2c API
      V4L/DVB (8945): mxb: use unique i2c adapter name
      V4L/DVB (8946): dib7000m: fix powerpc build error
      V4L/DVB (8904): cx88: add missing unlock_kernel
      V4L/DVB (9133): v4l: disconnect kernel number from minor
      V4L/DVB (9129): zoran: move zoran sources into a zoran subdirectory
      V4L/DVB (9157): cx18/ivtv: add 'PCI:' prefix to bus_info.
      V4L/DVB (9159): saa5249: fix compile errors
      V4L/DVB (9160): v4l: remove vidioc_enum_fmt_vbi_cap
      V4L/DVB (9162): ivtv: fix raw/sliced VBI mixup
      V4L/DVB (9191): ivtv: partially revert an earlier patch that checks=
 the max image height
      V4L/DVB (9198): adv7170: convert i2c driver for new i2c API
      V4L/DVB (9199): adv7175: convert i2c driver for new i2c API
      V4L/DVB (9200): bt819: convert i2c driver for new i2c API
      V4L/DVB (9201): bt856: convert i2c driver for new i2c API
      V4L/DVB (9202): bt866: convert i2c driver for new i2c API
      V4L/DVB (9203): ks0127: convert i2c driver for new i2c API
      V4L/DVB (9204): saa7110: convert i2c driver for new i2c API
      V4L/DVB (9205): saa7111: convert i2c driver for new i2c API
      V4L/DVB (9206): saa7114: convert i2c driver for new i2c API
      V4L/DVB (9207): saa7185: convert i2c driver for new i2c API
      V4L/DVB (9208): vpx3220: convert i2c driver for new i2c API
      V4L/DVB (9209): v4l2: add comment to the v4l2-i2c-drv headers.
      V4L/DVB (9324): v4l2: add video_ioctl2_unlocked for unlocked_ioctl =
support.
      V4L/DVB (9325): ivtv: switch to unlocked_ioctl.
      V4L/DVB (9327): v4l: use video_device.num instead of minor in video=
%d

Hans-Christian Egtvedt (2):
      avr32: Add support for EVKLCD10X addon boards
      avr32: add support for EarthLCD Favr-32 board

Harald Welte (11):
      ALSA: HDA patch_via.c: cleanup
      ALSA: HDA patch_via.c: HP and CD pin connect config
      ALSA: HDA patch_via.c: Fix inversion of surround and side channels
      ALSA: HDA patch_via.c: Add VT1708S and VT1702 support
      ALSA: HDA patch_via.c: Mute on headphone plug-in
      ALSA: HDA patch_via.c: Independent DAC for headphone
      ALSA: HDA patch_via.c: Second S/PDIF (HDMI) support
      ALSA: HDA VIA: Fix crash on codecs without Headphone
      ALSA: HDA VIA: Fix 2nd S/PDIF out function
      ALSA: HDA VIA: Replace buggy Mic Boost
      panasonic-laptop: add Panasonic Let's Note laptop extras driver v0.=
94

Harish Zunjarrao (1):
      [SCSI] qla2xxx: Add input/output byte-count statistics.

Harrison Metzger (1):
      USB: Added driver for a Delcom USB 7-segment LED Display

Hartley Sweeten (5):
      [ARM] 5242/1: ep93xx: bugfix, GPIO port F enable register offset
      [ARM] 5243/1: ep93xx: bugfix, GPIO ports C and F are swapped
      [ARM] 5276/1: ep93xx: allow selecting UART for early kernel message=
s
      [ARM] 5273/2: ep93xx: move ethernet support into core.c
      [ARM] 5293/1: ep93xx: add defines for external chipselects

Harvey Harrison (60):
      x86: early_printk.c trivial sparse fixes
      powerpc: Use the common ascii hex helpers
      powerpc: Replace __FUNCTION__ with __func__
      b43legacy: use le16 frame control directly, avoid byteswapping
      iwlwifi: use le16 frame control directly, use QOS symbolic constant=
 mask
      ath5k: explicitly check skb->len
      mac80211: explicitly check skb->len
      mac80211: wme.h remove unused QOS_CONTROL_LEN
      mac80211: wep.c replace magic numbers in IV/ICV removal
      mac80211: rx.c/tx.c remove more users of tx/rx_data->fc
      mac80211: remove ieee80211_get_hdrlen
      mac80211: remove IEEE80211_FC helper
      mac80211: use ieee80211 frame control directly
      mac80211: remove rx/tx_data->fc member
      mac80211: remove WLAN_FC_DATA_PRESENT
      wireless: replace __FUNCTION__ with __func__
      libertas: use the common frame control functions
      ALSA: ac97_patch make functions static
      avr32: use the new byteorder headers
      mISDN: endian annotations for struct zt
      mISDN: annotate iomem pointer and add statics
      net: em_cmp.c use unaligned access helpers
      rcu: fix sparse shadowed variable warning
      x86: ds.c ptrace.c integer as NULL pointer sparse fixes
      x86, olpc: fix endian bug in openfirmware workaround
      drivers/net: replace __FUNCTION__ with __func__
      bq27x00_battery: use unaligned access helper
      block: kmalloc args reversed, small function definition fixes
      ACPI: toshiba_acpi.c fix sparse signedness mismatch warnings
      V4L/DVB (8725): drx397xD.c sparse annotations
      V4L/DVB (8742): pvrusb2: use proper byteorder interface
      V4L/DVB (8800): [v4l-dvb-maintainer] [PATCH] v4l: mt9m111.c make fu=
nction static
      x86: suppress trivial sparse signedness warnings
      ftrace: fix hex output mode of ftrace
      trace: add build-time check to avoid overrunning hex buffer
      xtensa: replace remaining __FUNCTION__ occurrences
      KVM: make irq ack notifier functions static
      KVM: x86.c make kvm_load_realmode_segment static
      x86: pvclock: fix shadowed variable warning
      olpc: olpc_battery.c sparse endian annotations
      include: replace __FUNCTION__ with __func__
      misc: replace __FUNCTION__ with __func__
      befs: annotate fs32 on tests for superblock endianness
      char: moxa.c sparse annotation
      lib: pull base-guessing logic to helper function
      lib: trivial whitespace tidy
      lib: remove defining macros for strict_strto??
      FRV: Switch unaligned access to the packed-struct implementation
      mm: hugetlb.c make functions static, use NULL rather than 0
      byteorder: add new headers for make headers-install
      byteorder: use generic C version for value byteswapping
      byteorder: provide swabb.h generically in asm/byteorder.h
      byteorder: remove direct includes of linux/byteorder/swab[b].h
      byteorder: remove direct includes of linux/byteorder/swab[b].h
      misc: replace remaining __FUNCTION__ with __func__
      ALSA: hda - correct bracketing in spdif test in patch_sigmatel.c
      Staging: sxg: replace __FUNCTION__ with __func__
      Staging: remove remaining uses of __FUNCTION__
      [SCSI] aic79xx: fix shadowed variables, add statics
      [SCSI] aic79xx: fix shadowed variables

Hefty, Sean (1):
      IB/cm: Correctly free cm_device structure

Heiko Carstens (9):
      [S390] cio: fix cio_tpi.
      [S390] Move private simple udelay function to arch/s390/lib/delay.c.
      [S390] 3215: Remove tasklet.
      dsa: fix compile bug on s390
      PCI: fix pci_ioremap_bar() on s390
      Call init_workqueues before pre smp initcalls.
      workqueue: introduce create_rt_workqueue
      stop_machine: use workqueues instead of kernel threads
      stop_machine: fix error code handling on multiple cpus

Heiko Schocher (2):
      powerpc: Add support for the MPC852 based mgsuvd board from keymile.
      powerpc: Add support for mpc8247 based board MGCOGE from keymile.

Heinz Mauelshagen (1):
      dm raid1: separate region_hash interface part1

Helge Deller (1):
      parisc: convert to generic compat_sys_ptrace

Hendrik Brueckner (5):
      hvc_console: Add a hangup notifier for backends
      hvc_console: Add tty driver flag TTY_DRIVER_RESET_TERMIOS
      hvc_console: Fix loop if put_char() returns 0
      hvc_console: Add support for tty window resizing
      hvc_console: Remove __devexit annotation of hvc_remove()

Henrik Kretzschmar (2):
      V4L/DVB (8748): V4L: fix return value of meye probe callback
      V4L/DVB (8750): V4L: check inval in video_register_device_index()

Henrik Rydberg (8):
      hwmon: applesmc: specified number of bytes to read should match act=
ual
      hwmon: applesmc: fix the 'wait status failed: c !=3D 8' problem
      hwmon: applesmc: prolong status wait
      hwmon: applesmc: allow for variable ALV0 and ALV1 package length
      hwmon: applesmc: add support for Macbook Air
      hwmon: applesmc: Add support for Macbook Pro 4
      hwmon: applesmc: Add support for Macbook Pro 3
      hwmon: applesmc: lighter wait mechanism, drastic improvement

Henrique de Moraes Holschuh (11):
      rfkill: detect bogus double-registering (v2)
      rfkill: add default global states (v2)
      rfkill: add __must_check annotations
      rfkill: introduce RFKILL_STATE_MAX
      rfkill: use strict_strtoul (v2)
      rfkill: add WARN and BUG_ON paranoia (v2)
      rfkill: rename rfkill_mutex to rfkill_global_mutex
      rfkill: remove transmitter blocking on suspend
      rfkill: update LEDs for all state changes
      ACPI: thinkpad-acpi: attempt to preserve fan state on resume
      ACPI: thinkpad-acpi: Remove firmware backlight delays for Intel ACP=
I IGD OpRegion

Herbert Graeber (1):
      V4L/DVB (9147): af9015: Add USB ID for MSI DIGIVOX mini III

Herbert Xu (23):
      crypto: api - Export crypto_alg_lookup instead of __crypto_alg_look=
up
      crypto: api - Display larval objects properly
      crypto: tcrypt - Avoid using contiguous pages
      crypto: tcrypt - Abort and only log if there is an error
      crypto: tcrypt - Add alg_test interface
      crypto: cryptomgr - Add test infrastructure
      crypto: api - Use test infrastructure
      crypto: cryptomgr - Test ciphers using ECB
      crypto: skcipher - Move IV generators into their own modules
      crypto: skcipher - Use RNG interface instead of get_random_bytes
      net: Enable TSO if supported by at least one device
      ipsec: Use RCU-like construct for saved state within a walk
      ipsec: Fix xfrm_state_walk race
      ipsec: Put dumpers on the dump list
      net: BUG instead of corrupting memory in pskb_expand_head
      netdrv: Fix unregister_netdev typos
      gre: Use needed_headroom
      gre: Move MTU setting out of ipgre_tunnel_bind_dev
      gre: Add netlink interface
      gre: Add Transparent Ethernet Bridging
      inet: Make tunnel RX/TX byte counters more consistent
      gre: Initialise rtnl_link tunnel parameters properly
      net: Fix disjunct computation of netdev features

Hermann Pitton (1):
      V4L/DVB (9113): saa7134: fixes for the Asus Tiger Revision 1.00

Herton Ronaldo Krzesinski (7):
      rtl818x: merge tx/rx descriptor flags
      ALSA: hda: fix oopses in snd-hda-intel after digital slave support =
additions
      ALSA: hda - Fix ALC662 DAC mixer mutes also for auto config model
      ata_piix: add Hercules EC-900 mini-notebook to ich_laptop short cab=
le list
      ALSA: hda - Map ALC662 model for Gigabyte 945GCM-S2L
      ALSA: hda - Map ALC662 model for Foxconn 45CMX/45GMX/45CMX-K
      piix: add Hercules EC-900 mini-notebook to ich_laptop short cable l=
ist

Hidehiro Kawai (12):
      jbd2: abort when failed to log metadata buffers
      jbd2: fix error handling for checkpoint io
      ext4: add checks for errors from jbd2
      jbd2: don't dirty original metadata buffer on abort
      ext4: add an option to control error handling on file data
      jbd: abort when failed to log metadata buffers
      jbd: don't dirty original metadata buffer on abort
      ext3: add an option to control error handling on file data
      jbd: ordered data integrity fix
      jbd: fix error handling for checkpoint io
      ext3: add checks for errors from jbd
      jbd: test BH_Write_EIO to detect errors on metadata buffers

Hidetoshi Seto (1):
      doc: Test-by?

Hirofumi Nakagawa (1):
      UBIFS: remove unneeded unlikely()

Hiroshi Miura (2):
      ALSA: hda - Add support of Toshiba RX1
      Staging: add pcc-acpi driver

Hiroshi Shimamoto (27):
      x86_32: use apic_ops at print_local_APIC()
      x86_64: uml: fix rename header guard
      rcuclassic: fix compilation NG
      x86: acpi: move acpi_mcfg_64bit_base_addr into CONFIG_PCI_MMCONFIG
      rcuclassic: fix compiler warning
      x86_32: signal: use syscall_get_nr and error
      x86_32: signal: introduce signal_fault()
      x86: signal: make NR_restart_syscall
      x86: signal: split out frame setups
      x86_32: signal: move signal number conversion to upper layer
      x86: signal_64.c: clean up signal_fault()
      x86: signal_64.c: arg for restore_i387_xstate() is void __user *
      x86: signal_64.c: make handle_signal() similar
      x86: signal: put give_sigsegv of setup frames together
      x86: signal: remove unneeded err handling
      x86: signal: introduce do_rt_sigreturn()
      x86: signal: cosmetic unification of do_signal()
      x86: signal: cosmetic unification of do_notify_resume()
      x86: signal: cosmetic unification of handle_signal()
      x86: signal_32.c: introduce signr_convert()
      x86: signal_64.c: introduce helper function signr_convert()
      x86: signal: introduce helper macro is_ia32
      x86: signal_32.c: introduce macro ia32_setup_frame and ia32_setup_r=
t_frame
      x86: ia32_signal.c: remove unnecessary cast to u32
      x86: ia32_signal.c remove unnecessary function calls
      x86: signal: move macros out from restore_sigcontext()
      x86: signal: remove indent in restore_sigcontext()

Hoang-Nam Nguyen (1):
      IB/ehca: Don't allow creating UC QP with SRQ

Holger Smolinski (1):
      [S390] console flush on panic / reboot

Hollis Blanchard (6):
      KVM: Move KVM TRACE DEFINITIONS to common header
      KVM: ppc: guest breakpoint support
      KVM: ppc: Stop saving host TLB state
      KVM: ppc: Write only modified shadow entries into the TLB on exit
      KVM: powerpc: Map guest userspace with TID=3D0 mappings
      KVM: ppc: kvmppc_44x_shadow_release() does not require mmap_sem to =
be locked

Hongjie Yang (1):
      [S390] dcssblk: add >2G DCSSs support and stacked contiguous DCSSs =
support.

Huang Weiyi (27):
      arch/x86/kernel/genx2apic_uv_x.c: Removed duplicated include
      arch/x86/kernel/visws_quirks.c: Removed duplicated #include
      arch/x86/kernel/acpi/boot.c: removed duplicated #include
      arch/x86/kernel/cpuid.c: removed duplicated #include
      [MTD] [NAND] drivers/mtd/nand/nandsim.c: remove duplicated #include
      [MTD] removed unused #include <version.h>
      arch/x86/kernel/apm_32.c: remove duplicated #include
      [MTD] [NAND] au1550nd.c: remove unused #include <version.h>
      wireless: remove unused #include <version.h>
      [netdrvr] removed unused #include <version.h>
      V4L/DVB: remove unused #include <version.h>
      ALSA: ASoC codec: remove unused #include <version.h>
      wireless: remove duplicated #include
      qlge: remove duplicated #include
      netfilter: remove unused #include <version.h>
      jme: remove unused #include <version.h>
      V4L/DVB: v4l2-dev: remove duplicated #include
      USB: remove unused #include <version.h>
      USB: ti_usb_3410_5052: removed duplicated include
      arch/m68k/bvme6000/rtc.c: remove duplicated include
      mm: remove duplicated #include's
      Staging: SLICOSS: remove duplicated #include's
      Staging: et131x: remove duplicated #include's
      Staging: wlan-ng: prism2: remove duplicated #include
      staging: wlan-ng: prism2: remove more duplicated #include
      Staging: go7007: remove unused #include <version.h>
      Staging: SLICOSS: remove unused #include <version.h>

Huang Ying (1):
      ftrace: fix incorrect comment style of __ftrace_enabled_save()

Hugh Dickins (4):
      x86: add periodic corruption check
      x86: unsigned long pte_pfn
      block: adjust blkdev_issue_discard for swap
      Export tiny shmem_file_setup for DRM-GEM

H=C3=B6gander Jouni (1):
      ARM: OMAP2: Clock: Combine 34xx l3_icks and l4_icks

Ian Armstrong (6):
      V4L/DVB (9163): ivtvfb: fix sparse warnings and improve write funct=
ion
      V4L/DVB (9164): ivtvfb: a small cosmetic change
      V4L/DVB (9165): ivtv: V4L2_FBUF_FLAG_OVERLAY status fix
      V4L/DVB (9166): ivtv - Fix potential race condition in yuv handler
      V4L/DVB (9190): ivtv: yuv write() error handling tweak
      V4L/DVB (9328): ivtvfb: FB_BLANK_POWERDOWN turns off video output

Ian Campbell (1):
      xen: do not reserve 2 pages of padding between hypervisor and fixma=
p.

Ian Kent (4):
      autofs4: cleanup autofs mount type usage
      autofs4: track uid and gid of last mount requester
      autofs4: device node ioctl documentation
      autofs4: add miscellaneous device for ioctls

Ian Molton (5):
      [ARM] eseries: Split machine definitions
      [ARM] eseries: move LCD defs into machine files
      [ARM] eseries: move UDC defs to machine files
      mfd: reduce stack usage in mfd-core.c
      mfd: update TMIO drivers to use the clock API

Igor M. Liplianin (18):
      V4L/DVB (8989): Added support for TeVii S460 DVB-S/S2 card
      V4L/DVB (8991): Added support for DVBWorld 2104 and TeVii S650 USB =
DVB-S2 cards
      V4L/DVB (8992): Kconfig corrections for DVBWorld 2104 and TeVii S65=
0 USB DVB-S2 cards
      V4L/DVB (8993): cx24116: Fix lock for high (above 30000 kSyms) symb=
ol rates
      V4L/DVB (8994): Adjust MPEG initialization in cx24116
      V4L/DVB (9005): Bug fix: ioctl FE_SET_PROPERTY/FE_GET_PROPERTY alwa=
ys return error
      V4L/DVB (9010): Add support for SDMC DM1105 PCI chip
      V4L/DVB (9012): Add support for DvbWorld 2004 DVB-S2 PCI adapter
      V4L/DVB (9014): History update: MPEG initialization in cx24116.
      V4L/DVB (9017): Add support for Silicon Laboratories SI2109/2110 de=
modulators.
      V4L/DVB (9018): Add support for USB card modification with SI2109/2=
110 demodulator.
      V4L/DVB (9026): Add support for ST STV0288 demodulator and cards wi=
th it.
      V4L/DVB (9067): Kconfig correction for USB card modification with S=
I2109/2110 demodulator.
      V4L/DVB (9068): Kconfig dependency fix for DW2002 card with ST STV0=
288 demodulator.
      V4L/DVB (9174): Allow custom inittab for ST STV0288 demodulator.
      V4L/DVB (9175): Remove NULL pointer in stb6000 driver.
      V4L/DVB (9176): Add support for DvbWorld USB cards with STV0288 dem=
odulator.
      V4L/DVB (9296): Patch to remove warning message during cx88-dvb com=
pilation

Ilpo J=C3=A4rvinen (34):
      mpu401: reindent misindented spinlock
      tcp: Add tcp_validate_incoming & put duplicated code there
      tcp: Add tcp_collapse_one to eliminate duplicated code
      tcp: Add tcp_parse_aligned_timestamp
      s2io: reindented misleading for loop
      tcp: Partial hint clearing has again become meaningless
      tcp: move tcp_verify_retransmit_hint
      tcp: add helper for lost bit toggling
      tcp: convert retransmit_cnt_hint to seqno
      tcp: Kill precaution that's very likely obsolete
      tcp: No need to clear retransmit_skb_hint when SACKing
      tcp: add tcp_can_forward_retransmit
      tcp: remove obsolete validity concern
      tcp: Reorganize skb tagbit checks
      tcp: remove tp->lost_out guard to make joining diff nicer
      tcp: reorganize retransmit code loops
      tcp: remove retransmit_skb_hint clearing from failure
      tcp: don't clear retransmit_skb_hint when not necessary
      tcp: don't clear lost_skb_hint when not necessary
      tcp: back retransmit_high when it over-estimated
      ipv6: almost identical frag hashing funcs combined
      tcp: kill pointless urg_mode
      tcp: cleanup messy initializer
      tcp: fix length used for checksum in a reset
      tcpv6: fix option space offsets with md5
      tcpv[46]: fix md5 pseudoheader address field ordering
      tcpv6: trivial formatting changes to send_(ack|reset)
      tcpv6: convert opt[] -> topt in tcp_v6_send_reset
      tcpv6: combine tcp_v6_send_(reset|ack)
      pktgen: fix skb leak in case of failure
      nubus: fix mis-indented statement
      netfilter: snmp nat leaks memory in case of failure
      tcp: should use number of sack blocks instead of -1
      tcp: Restore ordering of TCP options for the sake of inter-operabil=
ity

Ilya Yanok (1):
      powerpc/4xx: Necessary fixes to PCI for 4GB RAM size

Inaky Perez-Gonzalez (17):
      uwb: add initial documentation
      uwb: add the uwb include files
      uwb: add the UWB stack (core files)
      uwb: add the UWB stack (radio controller interface)
      uwb: add the UWB stack (MLME)
      uwb: add whc-rc radio control driver
      uwb: add HWA radio controller driver
      uwb: add the i1480 DFU driver
      uwb: add the i1480 WLP driver
      wusb: add the Wireless USB include files.
      wusb: add the Wireless USB core
      wusb: add the Wireless USB core (protocol)
      wusb: add the Wireless USB core (security)
      wusb: add the USB wusb-cbaf driver
      wusb: add the Wire Adapter (WA) core
      wusb: add HWA host controller driver
      uwb: add credits for the original developers of the UWB/WUSB/WLP su=
bsystems

Ingo Molnar (209):
      x86: PEBS cleanup
      Merge branch 'linus' into timers/hpet
      x86, MM: virtual address debug, cleanups
      Merge branch 'linus' into x86/pebs
      Merge branch 'x86/core' into x86/x2apic
      Merge branch 'linus' into x86/x2apic
      Merge branch 'x86/apic' into x86/x2apic
      Merge branch 'x86/uv' into x86/x2apic
      x86, xen: fix apic_ops build on UP
      x86, lguest: fix apic_ops build on UP
      Merge branch 'linus' into x86/x2apic
      x86, cyrix: debug
      Merge branch 'linus' into x86/pebs
      x86: fix ds.c build error
      Merge branch 'linus' into x86/x2apic
      Merge branch 'linus' into x86/header-guards
      Merge branch 'linus' into x86/cleanups
      Merge branch 'x86/header-guards' into x86/core
      Merge branch 'x86/x2apic' into x86/core
      Merge branch 'x86/urgent' into x86/core
      x86: usb debug port early console, fix
      Merge branch 'linus' into x86/xen
      x86: visws_quirks, fix build error
      Merge core/lib: pick up memparse() change.
      x86: L3 cache index disable for 2.6.26, cleanups
      x86 l3 cache index disable for 2 6 26 fix
      Merge branch 'linus' into x86/cpu
      x86: L3 cache index disable for 2.6.26, fix #2
      Merge branch 'x86-tracehook' of git://git.kernel.org/pub/scm/linux/=
kernel/git/frob/linux-2.6-utrace into x86/tracehook
      x86, microcode support: fix build error
      x86, microcode: fix symbol exports
      x86, microcode: fix module license string
      Merge commit 'v2.6.27-rc1' into x86/microcode
      Merge branch 'x86/fpu' into x86/core
      Merge commit 'v2.6.27-rc1' into x86/core
      Merge branch 'x86/core' into x86/xsave
      Merge branch 'linus' into x86/xen
      Merge branch 'x86/spinlocks' into x86/xen
      Merge branch 'x86/urgent' into x86/xen
      Merge branch 'linus' into timers/hpet
      Merge branch 'linus' into x86/x2apic
      Merge branch 'linus' into x86/cleanups
      Merge branch 'linus' into core/rcu
      rcu, debug: detect stalled grace periods, cleanups
      printk: robustify printk, fix
      Merge branch 'linus' into x86/defconfig
      x86: fix xsave build error
      Merge commit 'v2.6.27-rc3' into x86/xsave
      Merge commit 'v2.6.27-rc3' into x86/prototypes
      Merge branch 'linus' into x86/core
      Merge branches 'x86/prototypes', 'x86/x2apic' and 'x86/debug' into =
x86/core
      Merge branch 'x86/apic' into x86/core
      Merge branch 'x86/core' into x86/apic
      Merge branch 'linus' into x86/cpu
      Merge branch 'linus' into x86/tracehook
      Merge branch 'linus' into x86/gart
      Merge branch 'x86/oprofile' into oprofile
      Merge branch 'linus' into x86/cleanups
      Merge branch 'linus' into x86/xen
      Merge branch 'linus' into x86/doc
      Revert "reduce tlb/cache flush times of agpgart memory allocation"
      Revert "introduce two APIs for page attribute"
      Merge branch 'x86/urgent' into x86/pat
      dma-coherent: export dma_[alloc|release]_from_coherent methods
      Merge branch 'x86/gart' into x86/iommu
      Merge branch 'x86/cpu' into x86/x2apic
      Merge branch 'linus' into x86/xen
      Merge branch 'x86/urgent' into x86/cleanups
      Merge branch 'linus' into sched/devel
      sched: clean up __might_sleep()
      sched: extract walk_tg_tree(), fix
      Merge branch 'linus' into x86/x2apic
      x86: split e820 reserved entries record to late v4
      Merge branch 'core/resources' into x86/core
      Merge branch 'x86/debug' into x86/cpu
      IO resources: fix/remove printk
      x86: quick TSC calibration, improve
      Merge branch 'x86/xsave' into x86/core
      Merge branch 'x86/cpu' into x86/core
      Merge branch 'x86/x2apic' into x86/core
      Merge commit '63cc8c75156462d4b42cbdd76c293b7eee7ddbfe':
      Merge branch 'x86/core' into x86/unify-cpu-detect
      x86: cpu/common*.c, merge whitespaces
      x86, init_64.c: cleanup
      Merge branch 'x86/alternatives' into x86/core
      Merge branch 'linus' into x86/tracehook
      Merge branch 'linus' into x86/defconfig
      Merge branches 'x86/tracehook', 'x86/xsave' and 'x86/prototypes' in=
to x86/signal
      Merge branch 'x86/cleanups' into x86/signal
      Merge branch 'linus' into timers/ntp
      Merge branch 'linus' into sched/devel
      x86, tsc calibration: fix
      Merge branch 'x86/pebs' into x86/unify-cpu-detect
      Merge commit 'v2.6.27-rc6' into core/rcu
      Merge commit 'v2.6.27-rc6' into x86/iommu
      Merge commit 'v2.6.27-rc6' into x86/unify-cpu-detect
      Merge branch 'core/xen' into x86/xen
      Merge commit 'v2.6.27-rc6' into sched/devel
      Merge branch 'linus' into x86/iommu
      x86: cpuid, fix typo
      x86, microcode rework, v2, fix
      timers: fix itimer/many thread hang, fix
      timers: fix itimer/many thread hang, fix #2
      timers: fix itimer/many thread hang, cleanups
      Merge commit 'v2.6.27-rc6' into core/resources
      Merge commit 'v2.6.27-rc6' into x86/pat
      Merge commit 'v2.6.27-rc6' into timers/hpet
      Merge commit 'v2.6.27-rc6' into x86/memory-corruption-check
      x86: add DMI quirk for AMI BIOS which corrupts address 0xc000 durin=
g resume
      x86: reserve low 64K on AMI and Phoenix BIOS boxen
      x86: add X86_RESERVE_LOW_64K
      dmi scan: warn about too early calls to dmi_check_system()
      Merge commit 'v2.6.27-rc6' into x86/cleanups
      Merge commit 'v2.6.27-rc7' into x86/debug
      sched: turn off WAKEUP_OVERLAP
      Merge branch 'x86/signal' into core/signal
      Merge branches 'sched/urgent' and 'sched/rt' into sched/devel
      Merge branch 'timers/urgent' into x86/xen
      Merge commit 'v2.6.27-rc7' into x86/pebs
      Merge commit 'v2.6.27-rc7' into x86/microcode
      IO resources, x86: ioremap sanity check to catch mapping requests e=
xceeding, fix
      x86, pci-hotplug, calgary / rio: fix EBDA ioremap()
      timers: fix itimer/many thread hang, fix
      Merge commit 'v2.6.27-rc8' into oprofile
      Merge branch 'oprofile-for-tip' of git://git.kernel.org/pub/scm/lin=
ux/kernel/git/rric/oprofile into oprofile
      x86: add PCI IDs for AMD Barcelona PCI devices
      Merge commit 'v2.6.27-rc8' into genirq
      Merge commit 'v2.6.27-rc8' into core/rcu
      rcu: RCU-based detection of stalled CPUs for Classic RCU, fix
      Merge commit 'v2.6.27-rc8' into x86/setup
      Merge branch 'linus' into sched/devel
      Merge branch 'x86/header-guards' into x86-v28-for-linus-phase1
      Merge branch 'x86/pebs' into x86-v28-for-linus-phase1
      Merge branch 'x86/prototypes' into x86-v28-for-linus-phase1
      Merge branch 'x86/tracehook' into x86-v28-for-linus-phase1
      Merge branches 'x86/alternatives', 'x86/cleanups', 'x86/commandline=
', 'x86/crashdump', 'x86/debug', 'x86/defconfig', 'x86/doc', 'x86/exports=
', 'x86/fpu', 'x86/gart', 'x86/idle', 'x86/mm', 'x86/mtrr', 'x86/nmi-watc=
hdog', 'x86/oprofile', 'x86/paravirt', 'x86/reboot', 'x86/sparse-fixes', =
'x86/tsc', 'x86/urgent' and 'x86/vmalloc' into x86-v28-for-linus-phase1
      x86: SB450: deprioritize DMI quirks
      Merge branches 'sched/devel', 'sched/cpu-hotplug', 'sched/cpusets' =
and 'sched/urgent' into sched/core
      Merge branch 'linus' into core/rcu
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/arjan/linux-2.6-hrtimer into timers/range-hrtimers
      sched debug: add name to sched_domain sysctl entries
      Merge commit 'v2.6.27' into timers/hpet
      x86, pat: cleanups
      Merge branch 'linus' into x86/pat2
      Merge branches 'core/iommu', 'x86/amd-iommu' and 'x86/iommu' into x=
86-v28-for-linus-phase3-B
      Merge branch 'sched/clock' into sched/urgent
      Merge branch 'x86/apic' into x86-v28-for-linus-phase4-B
      Merge branch 'x86/unify-cpu-detect' into x86-v28-for-linus-phase4-D
      Merge branch 'x86/urgent' into core/signal
      Merge branch 'linus' into x86/xen
      Merge branch 'linus' into x86/spinlocks
      Merge branch 'linus' into x86/quirks
      Merge branch 'linus' into x86/signal
      Merge branch 'x86/signal' into core/signal
      Merge branches 'core/signal' and 'x86/spinlocks' into x86/xen
      Merge branch 'linus' into x86/memory-corruption-check
      x86: memory corruption check - cleanup
      Merge branch 'linus' into x86/xsave
      x86, fpu: check __clear_user() return value
      warnings: fix arch/x86/kernel/early_printk.c
      warnings: fix arch/x86/kernel/io_apic_64.c
      x86, amd-iommu: propagate PCI device enabling error
      x86: extend processor type select help text
      x86: make processor type select depend on CONFIG_EMBEDDED
      Merge branches 'x86/xen', 'x86/build', 'x86/microcode', 'x86/mm-deb=
ug-v2', 'x86/memory-corruption-check', 'x86/early-printk', 'x86/xsave', '=
x86/ptrace-v2', 'x86/quirks', 'x86/setup', 'x86/spinlocks' and 'x86/signa=
l' into x86/core-v2
      warning: fix init do_mounts_md c
      net/mac80211/rx.c: fix build error
      x86: print out EBDA/lowmem address
      x86: remove additional_cpus configurability
      Merge branch 'linus' into oprofile
      Merge branch 'linus' into oprofile-v2
      Merge branches 'oprofile-v2' and 'timers/hpet' into x86/core-v4
      x86/mm: unify init task OOM handling
      tracing: disable tracepoints by default
      sched: clean up tracepoints
      tracing: clean up tracepoints kconfig structure
      ftrace: ignore functions that cannot be kprobe-ed
      ftrace: mark lapic_wd_event() notrace
      ftrace: build fix
      ftrace: ftrace_kill_atomic() build fix
      ftrace: scripts/recordmcount.pl cross-build hack
      ftrace: clean up macro usage
      stack tracer: depends on DEBUG_KERNEL
      ftrace: make it depend on DEBUG_KERNEL
      ring-buffer: fix build error
      tracing/fastboot: build fix
      tracing/stacktrace: improve help text
      tracing/fastboot: improve help text
      hrtimers: fix typo
      Merge branches 'core/softlockup', 'core/softirq', 'core/resources',=
 'core/printk' and 'core/misc' into core-v28-for-linus
      Merge branch 'linus' into genirq
      irq: sparse irqs, export nr_irqs
      irq: sparse irqs, fix #3
      irq: sparse irqs, fix IRQ auto-probe crash
      sparseirq: fix lockdep
      x86: make io_apic_32.c the same as io_apic_64.c
      warning: fix arch x86 kernel io_apic c
      sparseirq: export nr_irqs on m68k/sparc/s390
      x86: HPET_MSI Basic HPET_MSI setup code, cleanups
      x86, UV: add uv_setup_irq() and uv_teardown_irq() functions, v3, fi=
x
      genirq: remove artifacts from sparseirq removal
      io_apic: make irq_mis_count available on 64-bit too
      intr_remapping: fix typo
      m32r: fix build due to notify_cpu_starting() change
      Merge branch 'linus' into core/urgent
      profiling: fix !procfs build
      Merge branch 'linus' into sched/urgent
      sched: disable the hrtick for now
      genirq: fix off by one and coding style

Isaku Yamahata (34):
      xen-netfront: Avoid unaligned accesses to IP header
      ia64/pv_ops: fix paravirtualization of ivt.S with CONFIG_SMP=3Dn
      ia64/pv_ops: avoid name conflict of get_irq_chip().
      ia64/pv_ops: update native/inst.h to clobber predicate.
      ia64: move function declaration, ia64_cpu_local_tick() from .c to .=
h
      ia64/xen: reserve "break" numbers used for xen hypercalls.
      ia64/xen: introduce sync bitops which is necessary for ia64/xen sup=
port.
      ia64/xen: increase IA64_MAX_RSVD_REGIONS.
      ia64/xen: introduce definitions necessary for ia64/xen hypercalls.
      ia64/xen: define several constants for ia64/xen.
      ia64/xen: add a necessary header file to compile include/xen/interf=
ace/xen.h
      ia64/xen: define helper functions for xen related address conversio=
n.
      ia64/xen: define helper functions for xen hypercalls.
      ia64/xen: implement the arch specific part of xencomm.
      ia64/xen: xencomm conversion functions for hypercalls
      ia64/xen: implement arch specific part of xen grant table.
      ia64/xen: add definitions necessary for xen event channel.
      ia64/xen: introduce helper function to identify domain mode.
      ia64/pv_ops/xen: elf note based xen startup.
      ia64/pv_ops/xen: define xen pv_init_ops for various xen initializat=
ion.
      ia64/pv_ops/xen: define xen pv_cpu_ops.
      ia64/pv_ops/xen: define xen paravirtualized instructions for hand w=
ritten assembly code
      ia64/pv_ops/xen: paravirtualize DO_SAVE_MIN for xen.
      ia64/pv_ops/xen: paravirtualize ivt.S for xen.
      ia64/pv_ops/xen: paravirtualize entry.S for ia64/xen.
      ia64/pv_ops/xen: implement xen pv_iosapic_ops.
      ia64/pv_ops/xen: define the nubmer of irqs which xen needs.
      ia64/pv_ops/xen: implement xen pv_irq_ops.
      ia64/pv_ops/xen: implement xen pv_time_ops.
      ia64/xen: define xen machine vector for domU.
      ia64/xen: preliminary support for save/restore.
      ia64/pv_ops: update Kconfig for paravirtualized guest and xen.
      ia64/xen: a recipe for using xen/ia64 with pv_ops.
      ia64/pv_ops: paravirtualized instruction checker.

Ivan Vecera (1):
      r8169: read MAC address from EEPROM on init

Ivo van Doorn (16):
      rt2x00: Implement HW encryption
      rt2x00: Implement HW encryption (rt61pci)
      rt2x00: Implement HW encryption (rt73usb)
      rt2x00: Gather channel information in structure
      rt2x00: Release rt2x00 2.2.0
      rt2x00: Move lna_gain calculation to config() callback
      rt2x00: Add module parameter to disable HW crypto
      rt2x00: Fix race conditions in flag handling
      rt2x00: Map extra_tx_headroom to DMA
      rt2x00: Initialize txop during conf_tx() callback
      rt2x00: Add Signal type flag
      rt2x00: Release rt2x00 2.2.1
      rt2x00: Revert "rt2x00: Fix the beacon length bug"
      rt2x00: Make RFKILL enabled by default
      rt2x00: Make rt2x00 LEDS invisible config option
      rt2x00: Fix HW crypto key handling

J. Bruce Fields (14):
      nfsd: permit unauthenticated stat of export root
      locks: allow lockd to process blocked locks during grace period
      lockd: don't depend on lockd main loop to end grace
      nfsd: common grace period control
      lockd: move grace period checks to common code
      lockd: reject reclaims outside the grace period
      nfs: remove an obsolete nfs_flock comment
      nfs: break up nfs_follow_referral
      nfs: replace while loop by for loops in nfs_follow_referral
      nfs: prepare to share nfs_set_port
      nfs: Fix misparsing of nfsv4 fs_locations attribute
      Merge branch 'from-tomtucker' into for-2.6.28
      NFS: Cleanup nfs_set_port
      nfsd: clean up expkey_parse error cases

J.A. Magall=C3=B3n (1):
      x86: mtrr_cleanup try gran_size to less than 1M, cleanup

J.R. Mauro (5):
      Staging: Fix gcc warnings in sxg
      Staging: Lindent sxg.c
      Staging: Clean up sxg driver
      Staging: Lindent the echo driver
      Staging: sxg: clean up C99 comments

Jack Steiner (5):
      x86, uv: add early detection of UV system types
      x86, uv: fix for size of hub mappings
      x86, UV: new UV genapic functions for x2apic
      x86, uv: fix ordering of calls to uv_system_init & uv_cpu_init
      GRU driver: minor updates

James Bottomley (10):
      [SCSI] add inline functions for recognising created and blocked sta=
tes
      [SCSI] Update the SCSI state model to allow blocking in the created=
 state
      [SCSI] lib: add generic helper to print sizes rounded to the correc=
t SI range
      [SCSI] sd: use generic helper to print capacities in both binary an=
d SI
      [SCSI] scsi_dh: suppress comparison warning
      parisc: initialize unwinder much earlier
      [SCSI] scsi_error: fix target reset handling
      [SCSI] sd: fix compile failure with CONFIG_BLK_DEV_INTEGRITY=3Dn
      [SCSI] fix removable device inability to detect disk changes
      PCI: add routines for debugging and handling lost interrupts

James Morris (6):
      Merge branch 'master' into next
      SELinux: add gitignore file for mdp script
      Merge branch 'master' into next
      Merge branch 'next' into for-linus
      Merge branch 'master' of git://git.infradead.org/users/pcmoore/lbln=
et-2.6_next into next
      Merge branch 'next' into for-linus

James Smart (14):
      [SCSI] scsi_host_lookup: error returns and NULL pointers
      [SCSI] scsi_netlink: Add transport and LLD recieve and event suppor=
t
      [SCSI] lpfc 8.2.8 : Add kernel-doc function headers
      [SCSI] lpfc 8.2.8 : Miscellaneous Discovery Fixes
      [SCSI] lpfc 8.2.8 : Update driver for new SLI-3 features
      [SCSI] lpfc 8.2.8 : Miscellaneous Bug Fixes
      [SCSI] lpfc 8.2.8 : Add new FCOE hardware support
      [SCSI] lpfc 8.2.8 : Add support for PCI-EEH permanent disabling
      [SCSI] lpfc 8.2.8 : Update driver to use new Host byte error code D=
ID_TRANSPORT_DISRUPTED
      [SCSI] lpfc 8.2.8 : Add MSI-X support
      [SCSI] lpfc 8.2.8 : update driver version to 8.2.8
      [SCSI] lpfc 8.2.8 v2 : Revert target busy in favor of transport dis=
rupted
      [SCSI] lpfc 8.2.8 v2 : Add sysfs control of target queue depth hand=
ling
      [SCSI] lpfc 8.2.8 v2 : Add statistical reporting control and additi=
onal fc vendor events

Jamie Wellnitz (1):
      [SCSI] sd: Fix handling of NO_SENSE check condition

Jan Beulich (15):
      x86: ticket spin locks: fix asm constraints
      x86: ticket spin locks: factor out more common code
      x86: ticket spin locks: reduce instruction dependencies
      x86: init annotations in early_printk() setup
      x86: pgd_{c,d}tor() cleanup
      x86: adjust vmalloc_sync_all() for Xen (2nd try)
      x86-64: add two __cpuinit annotations
      x86-64: eliminate dead code
      ACPI: fix FADT parsing
      x86-64: reduce boot fixmap space
      x86-64: slightly stream-line 32-bit syscall entry code
      x86-64: fix combining of regions in init_memory_mapping()
      x86: make mm/gup.c more virtualization friendly
      x86: adjust dependencies for CONFIG_X86_CMOV
      Kconfig: eliminate "def_bool n" constructs

Jan Engelhardt (38):
      netfilter: Use unsigned types for hooknum and pf vars
      netfilter: rename ipt_recent to xt_recent
      netfilter: xt_recent: IPv6 support
      netfilter: Introduce NFPROTO_* constants
      netfilter: x_tables: use NFPROTO_* in extensions
      netfilter: implement NFPROTO_UNSPEC as a wildcard for extensions
      netfilter: ebtables: do centralized size checking
      netfilter: change return types of check functions for Ebtables exte=
nsions
      netfilter: change return types of match functions for ebtables exte=
nsions
      netfilter: Change return types of targets/watchers for Ebtables ext=
ensions
      netfilter: add dummy members to Ebtables code to ease transition to=
 Xtables
      netfilter: ebt_among: obtain match size through different means
      netfilter: change Ebtables function signatures to match Xtables's
      netfilter: move Ebtables to use Xtables
      netfilter: x_tables: output bad hook mask in hexadecimal
      netfilter: ebtables: use generic table checking
      netfilter: implement hotdrop for Ebtables
      netfilter: remove unused Ebtables functions
      netfilter: remove redundant casts from Ebtables
      netfilter: ebtables: fix one wrong return value
      netfilter: xtables: do centralized checkentry call (1/2)
      netfilter: ip6tables: fix name of hopbyhop in Kconfig
      netfilter: ip6tables: fix Kconfig entry dependency for ip6t_LOG
      netfilter: ebtables: make BRIDGE_NF_EBTABLES a menuconfig option
      netfilter: xtables: sort extensions alphabetically in Kconfig
      netfilter: xtables: use "if" blocks in Kconfig
      netfilter: xtables: move extension arguments into compound structur=
e (1/6)
      netfilter: xtables: move extension arguments into compound structur=
e (2/6)
      netfilter: xtables: move extension arguments into compound structur=
e (3/6)
      netfilter: xtables: move extension arguments into compound structur=
e (4/6)
      netfilter: xtables: move extension arguments into compound structur=
e (5/6)
      netfilter: xtables: move extension arguments into compound structur=
e (6/6)
      netfilter: xtables: provide invoked family value to extensions
      netfilter: xtables: cut down on static data for family-independent =
extensions
      netfilter: xtables: use NFPROTO_UNSPEC in more extensions
      netfilter: xtables: remove bogus mangle table dependency of connmar=
k
      ext4: fix kconfig typo and extra whitespace
      netfilter: replace old NF_ARP calls with NFPROTO_ARP

Jan Kiszka (4):
      KVM: Consolidate XX_VECTOR defines
      KVM: VMX: Reinject real mode exception
      KVM: VMX: Cleanup stalled INTR_INFO read
      KVM: x86: Silence various LAPIC-related host kernel messages

Janne Grunau (3):
      V4L/DVB (8634): v4l2: extend MPEG Encoding API with AVC and AAC
      V4L/DVB (8964): dvb/budget: push adapter_nr mod option down to indi=
vidual drivers
      V4L/DVB (9105): correct Makefile symbol for stv0288 frontend

Jarek Poplawski (7):
      pkt_sched: Check the state of tx_queue in dequeue_skb()
      pkt_sched: Remove the tx queue state check in qdisc_run()
      pkt_sched: Fix handling of gso skbs on requeuing
      pkt_sched: Simplify dev_requeue_skb and dequeue_skb
      pkt_sched: Update qdisc requeue stats in dev_requeue_skb()
      lib8390: Fix locking in ei_poll (poll controller)
      pkt_sched: sch_generic: Fix oops in sch_teql

Jarkko Nikula (10):
      ARM: OMAP: Add support for OMAP2430 in McBSP
      ARM: OMAP: Fixes to omap_mcbsp_request function
      ALSA: ASoC: tlv320aic3x: Use uniform tlv320aic naming
      ALSA: ASoC: Remove unused AUDIO_NAME define from codec drivers
      ALSA: ASoC: OMAP: Add multilink support to McBSP DAI driver
      ALSA: ASoC: OMAP: Add support for OMAP2430 and OMAP34xx in McBSP DA=
I driver
      ALSA: ASoC: OMAP: Set DMA stream name at runtime in McBSP DAI drive=
r
      ALSA: ASoC: OMAP: Fix DSP DAI format in McBSP DAI driver
      ALSA: ASoC: OMAP: Continue fixing DSP DAI format in McBSP DAI drive=
r
      ALSA: ASoC: tlv320aic3x: Fix DSP DAI format and signal polarities m=
atching

Jarod Wilson (1):
      HID: blacklist additional SoundGraph iMon LCD models

Jaroslav Kysela (9):
      ALSA: Fix commit: Add automatic model setting for the Acer Aspire 5=
920G laptop
      sound: Revert "ALSA: Fix limit of 8 PCM devices in SNDRV_CTL_IOCTL_=
PCM_NEXT_DEVICE"
      ALSA: hda - put all HDA codec IDs to components for precise hw dete=
ction
      ALSA: dummy driver - do not use assignment in if condition
      ALSA: release v1.0.18rc1
      ALSA: Cosmetic change: CA0106 on MSI K8N Diamond PLUS Motherboard
      ALSA: intel8x0: implement ac97_clock whitelist
      ALSA: Release v1.0.18rc3
      USB: hub.c: Add initial_descriptor_timeout module parameter for usb=
core

Jason Baron (2):
      driver core: basic infrastructure for per-module dynamic debug mess=
ages
      exec.c, compat.c: fix count(), compat_count() bounds checking

Jason Jin (1):
      powerpc/85xx: Enable enhanced functions for 8536 TSEC

Jason Wessel (2):
      usb: fix pl2303 initialization
      tty: tty_io.c shadows sparse fix

Jason Yeh (1):
      Oprofile Multiplexing Patch

Jasper Bryant-Greene (2):
      move ETH_P_PAE from ieee80211_i.h to if_ether.h
      replace net_device arguments with ieee80211_{local,sub_if_data} as =
appropriate

Jaswinder Singh (28):
      x86: Introducing asm/syscalls.h
      x86: process_32.c declare cpu_number before they get used
      x86: signal_XX.c declare do_notify_resume before they get used
      x86: time_XX.c declare functions before they get used
      x86: setup.c declare saved_video_mode before they get used
      x86: e820.c declare pci_mem_start before they get used
      x86: pci-dma.c declare iommu_bio_merge before they get used
      x86: pci-nommu.c declare nommu_dma_ops before they get used
      x86: i387.c declare dump_fpu() before they get used
      x86: ptrace.c declare functions before they get used
      x86: proc.c declare cpuinfo_op before they get used
      x86: common.c declare idle_regs before they get used
      x86: mtrr/main.c declare range_state as static
      x86: apic_XX.c declare functions before they get used
      x86: vm86_32.c declare functions before they get used
      x86: mm/init_XX.c declare functions before they get used
      x86: mm/fault.c declare do_page_fault before they get used
      x86: mm/ioremap.c declare early_ioremap_debug and early_ioremap_nes=
ted as static
      x86: mm/pageattr.c declare arch_report_meminfo before they get used
      x86: mm/pgtable_32.c declare set_pmd_pfn before they get used
      x86: mach-default/setup.c declare no_broadcast before they get used
      x86_64: Declare new_utsname in asm-x86/syscalls.h
      X86_32: declare pt_regs_access as unsigned long
      X86_SMP: smp.c declare functions before they get used
      X86_SMP: smpboot.c declare idle_thread_array and smp_b_stepping as =
static
      X86_SMP: ipi.c declare functions before they get used
      X86_SMP: tlb_XX.c declare smp_invalidate_interrupt before they get =
used
      cassini: use request_firmware

Javier Cardona (2):
      libertas: Reduce the WPA key installation time.
      libertas: Reduce the WPA key installation time (fixups)

Javier Herrero (1):
      Blackfin arch: flash memory map and dm9000 resources updating

Jay Cliburn (5):
      atl2: add tx bytes statistic
      atl1: fix transmit timeout bug
      atl1: remove LLTX
      atl1: remove EXPERIMENTAL label
      atl1: update introductory comments

Jay Fenlason (2):
      firewire: fw_send_request_sync()
      firewire: Add more documentation to firewire-cdev.h

Jaya Kumar (4):
      [ARM] 5186/1: metronomefb: convert printk to dev_dbg/err messages
      [ARM] 5209/1: metronomefb: changes to use platform framebuffer
      [ARM] 5200/1: am200epd: use fb notifiers and gpio api
      [ARM] 5197/1: gumstix: conversion to MFP support and add bluetooth =
support

Jean Delvare (59):
      ALSA: ASoC: Add missing new-line at end of strings
      ALSA: ASoC: Convert uda1380 to a new-style i2c driver
      ALSA: ASoC: Convert ak4535 to a new-style i2c driver
      ALSA: ASoC: Convert wm8750 to a new-style i2c driver
      ALSA: ASoC: Convert wm8731 to a new-style i2c driver
      ALSA: ASoC: Convert wm8990 to a new-style i2c driver
      sound: ASoC: Fix an error path in neo1973_wm8753
      sound: ASoC: Convert wm8753 to a new-style i2c driver
      sound: ASoC: Convert neo1973/lm4857 to a new-style i2c driver
      sound: ASoC: Convert wm8510 to a new-style i2c driver
      ALSA: ASoC: Convert tlv320aic3x to a new-style i2c driver (v2)
      V4L/DVB (8879): bttv: Don't unmask VPRES interrupt
      V4L/DVB (8956): bttv: Turn video_nr, vbi_nr and radio_nr into array=
s
      V4L/DVB (8962): zr36067: VIDIOC_S_FMT returns the colorspace value
      i2c/isp1301_omap: Convert to a new-style i2c driver, part 2
      hwmon: (dme1737) Be less i2c-centric
      hwmon: (dme1737) Convert to a new-style i2c driver
      i2c-parport-light: Don't register a platform device resource
      i2c: Improve dev-interface documentation
      i2c: Document the implementation details of the /dev interface
      i2c: Only build Tyan SMBus mux drivers on x86
      radeonfb: revert "Fix radeon DDC regression"
      hwmon: (lm90) Move 16-bit value read to a separate function
      hwmon: (lm90) Support the extra resolution bits of MAX6657
      hwmon: (lm90) Don't access nonexistent registers on Maxim chips
      hwmon: (lm90) Update datasheet links
      hwmon: (lm90) Don't spam the kernel log
      hwmon: (ams) Convert to a new-style i2c driver
      hwmon: (lm85) Rework the device detection
      hwmon: (lm85) Implement the standard PWM frequency interface
      hwmon: (lm85) Select the closest PWM frequency
      hwmon: (lm85) Support different PWM frequency tables
      hwmon: (lm85) Convert to a new-style i2c driver
      hwmon: (lm85) Simplify RANGE_TO_REG
      hwmon: (lm85) Better label names
      hwmon: (lm78) Fix I/O resource conflict with PNP
      hwmon: (lm78) Detect alias chips
      hwmon: (lm78) Prevent misdetection of Winbond chips
      hwmon: (lm78) Stop abusing struct i2c_client for ISA devices
      hwmon: (lm78) Convert to a new-style i2c driver
      hwmon: (it87) Fix thermal sensor type values
      hwmon: Drop dead links to old National Semiconductor chip datasheet=
s
      hwmon: (w83781d) Refactor beep enable handling
      hwmon: (w83781d) Detect alias chips
      hwmon: (w83781d) Additional information about AS99127F PWM
      hwmon: (w83781d) Stop abusing struct i2c_client for ISA devices
      hwmon: (adm1026) Fix debug messages
      hwmon: (adm1026) Prevent log spamming
      V4L/DVB (9197): zoran: set adapter class to I2C_CLASS_TV_ANALOG
      V4L/DVB (9234): zoran: Drop redundant printk
      V4L/DVB (9240): saa7127: Fix two typos
      PCI: Check dynids driver_data value for validity
      i2c: Delete outdated client porting guide
      i2c: Constify i2c_get_clientdata's parameter
      i2c: Delete legacy model documentation
      i2c: Drop 2-byte address block transfer defines
      i2c: Update and clean up writing-clients document
      i2c: Clean up <linux/i2c.h>
      Schedule removal of the legacy i2c device driver binding model

Jean PIHET (1):
      [ARM] 5195/1: ARMv7 Oprofile support

Jean-Francois Moine (31):
      V4L/DVB (8910): gspca: Add support of image transfer by bulk and mi=
nor change.
      V4L/DVB (8927): gspca: PAC 207 webcam 093a:2476 added.
      V4L/DVB (8928): gspca: Version change to 2.3.0.
      V4L/DVB (8929): gspca: sonixj webcam 0458:702e added.
      V4L/DVB (8930): gspca: The image transfer by bulk is started by the=
 subdrivers.
      V4L/DVB (8931): gspca: Vflip added for sonixj - ov7630.
      V4L/DVB (9074): gspca: sonixj webcam 0c45:60fe added.
      V4L/DVB (9078): gspca: New exported function to retrieve the curren=
t frame buffer.
      V4L/DVB (9079): gspca: Return error code from stream start function=
s.
      V4L/DVB (9081): gspca: Bad webcam name of 046d:092f in documentatio=
n.
      V4L/DVB (9082): gspca: Vertical flip the image by default in sonixj.
      V4L/DVB (9083): gspca: URB_NO_TRANSFER_DMA_MAP is not useful for is=
oc transfers.
      V4L/DVB (9087): gspca: Image transfer by bulk uses altsetting 0 wit=
h any buffer size.
      V4L/DVB (9089): gspca: Remove the duplicated EOF (ff d9) in t613.
      V4L/DVB (9097): gspca: Adjust control values and restore compilatio=
n of sonixj.
      V4L/DVB (9118): gspca: Set the vertical flip at streamon time in so=
nixj.
      V4L/DVB (9119): gspca: Don't destroy the URBs on disconnect.
      V4L/DVB (9120): gspca: sd_desc->start returns a value and static fu=
nctions in m5602.
      V4L/DVB (9121): gspca: Add the subdriver finepix in Kconfig and Mak=
efile.
      V4L/DVB (9122): gspca: Bad name of the sunplus subdriver in Kconfig.
      V4L/DVB (9124): gspca: Bad name of the tv8532 subdriver in Kconfig.
      V4L/DVB (9125): gspca: Big rewrite of t613 driver
      V4L/DVB (9126): gspca: Fix some compilation warnings in m5602.
      V4L/DVB (9286): gspca: Compilation problem of gspca.c and the kerne=
l version.
      V4L/DVB (9287): gspca: Change the name of the multi bytes write fun=
ction in t613.
      V4L/DVB (9288): gspca: Write to the USB device and not USB interfac=
e in t613.
      V4L/DVB (9289): gspca: Other sensor identified as om6802 in t613.
      V4L/DVB (9290): gspca: Adjust the sensor init sequences in t613.
      V4L/DVB (9291): gspca: Do not set the white balance temperature by =
default in t613.
      V4L/DVB (9292): gspca: Call the control setting functions at init t=
ime in t613.
      V4L/DVB (9294): gspca: Add a stop sequence in t613.

Jeff Chua (1):
      x86: make sparsemem more available

Jeff Garzik (3):
      Merge branch 'r8169-fixes' of git://git.kernel.org/pub/scm/linux/ke=
rnel/git/romieu/netdev-2.6 into upstream-next
      Merge branch 'for-2.6.28' of git://git.marvell.com/mv643xx_eth into=
 upstream-next
      [netdrvr] myri10ge, ixgbe: remove broken select INTEL_IOATDMA

Jeff Kirsher (3):
      ixgbe: fix pci_resource allocation as in other drivers
      ixgbe: bump version
      igb: add IGB_DCA instead of selecting INTEL_IOATDMA

Jeff Layton (19):
      cifs: clean up variables in cifs_unlink
      cifs: have find_writeable_file prefer filehandles opened by same ta=
sk
      cifs: move rename and delete-on-close logic into helper function
      cifs: add function to set file disposition
      cifs: fix inverted NULL check after kmalloc
      cifs: work around samba returning -ENOENT on SetFileDisposition cal=
l
      cifs: remove NULL termination from rename target in CIFSSMBRenameOp=
enFIle
      cifs: explicitly revoke SPNEGO key after session setup
      knfsd: allocate readahead cache in individual chunks
      [CIFS] fix some settings of cifsAttrs after calling SetFileInfo and=
 SetPathInfo
      NFS: missing nfs_fattr_init in nfs3_proc_getacl and nfs3_proc_setac=
ls (resend #2)
      [CIFS] cifs: remove pointless lock and unlock of GlobalMid_Lock in =
header_assemble
      [CIFS] eliminate usage of kthread_stop for cifsd
      cifs: don't use CREATE_DELETE_ON_CLOSE in cifs_rename_pending_delet=
e
      cifs: track DeletePending flag in cifsInodeInfo
      cifs: make cifs_rename handle -EACCES errors
      [CIFS] fix saving of resume key before CIFSFindNext
      cifs: fix unlinking of rename target when server doesn't support op=
en file renames
      cifs: handle the TCP_Server_Info->tsk field more carefully

Jens Axboe (30):
      block: add bio_has_data() to detect whether a bio carries data or n=
ot
      block: use bio_has_data() to check for data carrying bio
      block: use bio_has_data() in the IO completion path
      highmem: use bio_has_data() in the bounce path
      block: raid fixups for removal of bi_hw_segments
      block: make bi_phys_segments an unsigned int instead of short
      block: use linux/uaccess.h in elevator.c instead of asm variant
      block: split softirq handling into blk-softirq.c
      block: make kblockd_schedule_work() take the queue as parameter
      block: add support for IO CPU affinity
      block: inherit CPU completion on bio->rq and rq->rq merges
      block: don't use bio_has_data() in the completion path
      Change default value of CONFIG_DEBUG_BLOCK_EXT_DEVT to 'n'
      block: update comment on end_request()
      block: unify request timeout handling
      block: add bio_kmalloc()
      block: add fault injection mechanism for faking request timeouts
      block: use rq complete marking in blk_abort_request()
      block: cleanup some of the integrity stuff in blkdev.h
      block: blk_cleanup_queue() should call blk_sync_queue()
      block: add queue flag for SSD/non-rotational devices
      libata: set queue SSD flag for SSD devices
      block: as/cfq ssd idle check update
      block: reserve some tags just for sync IO
      blktrace: use BLKTRACE_BDEV_SIZE as the name size for setup structu=
re
      block: revert part of d7533ad0e132f92e75c1b2eb7c26387b25a583c1
      block: add some comments around the bio read-write flags
      block: only call ->request_fn when the queue is not stopped
      block: remove __generic_unplug_device() from exports
      libata: switch to using block layer tagging support

Jeremy Fitzhardinge (42):
      x86/paravirt/xen: properly fill out the ldt ops
      x86: split spinlock implementations out into their own files
      x86: fix initialization of 'l' bit in ldt descriptors
      xen: fix allocation and use of large ldts
      generic, memparse(): constify argument
      xen-balloon: fix up sysfs issues
      xen-balloon: clean up unused functions
      xen: suppress known wrmsrs
      xen: compile irq functions without -pg for ftrace
      xen: fix allocation and use of large ldts, cleanup
      x86_64: use save/loadsegment in ia32 compat
      x86: another user of PTE_FLAGS_MASK
      xen: clean up domain mode predicates
      x86/paravirt: add spin_lock_flags lock op
      xen: clarify locking used when pinning a pagetable.
      xen: add xen_ prefixes to make tracing with ftrace easier
      xen: save previous spinlock when blocking
      xen: add debugfs support
      xen: allow interrupts to be enabled while doing a blocking spin
      xen: measure how long spinlocks spend blocking
      x86: build fix in "xen spinlock updates and performance measurement=
s"
      x86: export pv_lock_ops non-GPL
      x86: make sure the CPA test code's use of _PAGE_UNUSED1 is obvious
      x86: check for and defend against BIOS memory corruption
      x86: clean up memory corruption check and add more kernel parameter=
s
      x86: default corruption check to off, but put parameter default in =
Kconfig
      x86: fix compile error with corruption checking disabled
      mm: define USE_SPLIT_PTLOCKS rather than repeating expression
      xen: fix pinning when not using split pte locks
      generic: add phys_addr_t for holding physical addresses
      generic: make PFN_PHYS explicitly return phys_addr_t
      generic: redefine resource_size_t as phys_addr_t
      xen: clean up x86-64 warnings
      xen: remove unused balloon.h
      xen: use spin_lock_nest_lock when pinning a pagetable
      x86: add _PAGE_IOMAP pte flag for IO mappings
      x86: remove duplicate early_ioremap declarations
      x86: add early_memremap()
      x86: use early_memremap() in setup.c
      x86-64: don't check for map replacement
      ftrace: fix build problem with CONFIG_FTRACE
      x86/tlb_uv: remove strange mc146818rtc include

Jeremy Kerr (8):
      powerpc/spufs: set nlink count for spufs root correctly
      powerpc/spufs: use inc_nlink
      powerpc/spufs: sputrace: Only enable logging on open(), prevent mul=
tiple openers
      powerpc/spufs: sputrace: Don't block until the read buffer is full
      powerpc/spufs: Use state_mutex for switch_log locking, and prevent =
multiple openers
      powerpc/spufs: Don't require full buffer in switch_log read
      powerpc/spufs: Don't spu_acquire_saved unnecessarily in regs read
      powerpc/spufs: Use kmalloc rather than kzalloc for switch log buffe=
r

Jerone Young (2):
      KVM: ppc: enable KVM_TRACE building for powerpc
      KVM: ppc: adds trace points for ppc tlb activity

Jesper Nilsson (1):
      [CRIS] Rename boot-linkscripts and fix the path to them.

Jesse Barnes (10):
      i915: Use more consistent names for regs, and store them in a separ=
ate file.
      separate i915 suspend/resume functions into their own file
      new chip name is GM45
      drm: Rework vblank-wait handling to allow interrupt reduction.
      drm: kill drm_device->irq
      PCI: fix -Wakpm warnings in pci_pm_init debug output
      PCI: remove #ifdef DEBUG around dev_dbg call
      PCI: use pci_find_ext_capability everywhere
      PCI: include io.h in pci.h so that ioremap_nocache is defined
      Remove PCI hotplug core MAINTAINERS entry

Jesse Brandeburg (34):
      ixgbe: fix rx csum return status misinterpretation
      ixgbe: add little endian annotations for sparse
      ixgbe: do not update stats twice each receive
      ixgbe: Cleanup references to Tx and Rx rings to becommon across the=
 driver
      ixgbe: disable flow control by default
      ixgbe: Implement Tx Head Writeback
      ixgbe: Lock RSS seed, move rx_buf_len to the rx_ring
      ixgbe: should not use HW_CSUM, should use IP* flags
      ixgbe: update dca to new interface, fix CONFIG_DCA_MODULE
      ixgbe: fix bug where lro settings are per ring
      ixgbe: fix dca hints going to wrong processor
      ixgbe: fix bug where using wake queue instead of start
      ixgbe: fix dca defines to not have spaces
      ixgbe: fix multicast address update
      ixgbe: Update watchdog thread to accomodate longerlink_up events
      ixgbe: link change interrupt was not causing link event
      ixgbe: fix bug with shared interrupts
      ixgbe: limit small mtu to minimum for ipv4 support
      ixgbe: fix ethtool register dump
      ixgbe: fix ethtool disable csum for ipv6
      ixgbe: fix initial interrupt throttle settings
      ixgbe: fix bug with lots of tx queues
      ixgbe: recycle pages in packet split mode
      ixgbe: add device support for XF LR adapters
      ixgbe: fix ring reallocation in ethtool
      ixgbe: lro stats were not counted on first ethtool -Scall
      ixgbe: add clean rx many routine
      ixgbe: update to latest common code module
      ixgbe: refresh the ixgbe_down function
      ixgbe: move set_num_queues and call it after msix failure
      ixgbe: cleanup defines
      ixgbe: lower stack space usage
      ixgbe: xmit frame refactor
      ixgbe: fix DCA dependency in Kconfig

Jie Yang (1):
      atl1e: remove the unneeded (struct atl1e_adapter *)

Jike Song (1):
      PCI: utilize calculated results when detecting MSI features

Jim Cromie (6):
      hwmon/pc87360 separate alarm files: define some constants
      hwmon/pc87360 separate alarm files: add in-min/max-alarms
      hwmon/pc87360 separate alarm files: add temp-min/max/crit/fault-ala=
rms
      hwmon/pc87360 separate alarm files: define LDNI_MAX const
      hwmon/pc87360 separate alarm files: add dev_dbg help
      hwmon/pc87360 separate alarm files: add therm-min/max/crit-alarms

Jiri Kosina (9):
      printk: robustify printk, update comment
      Input: document i8042.debug in kernel-parameters.txt
      HID: introduce list for hiddev creation forcing
      HID: add support for Super Dual Box Pro USB PS2/PS2 adapter
      HID: fix incorrent length condition in hidraw_write()
      HID: add missing blacklist entry for Apple ATV ircontrol
      HID: build drivers for all quirky devices by default
      HID: fix default building of HID-quirk drivers
      HID: fix/improve help texts for quirk drivers

Jiri Slaby (46):
      MM: virtual address debug
      x86, MM: virtual address debug, v2
      Ath5k: unify resets
      Char: cyclades. remove bogus iomap
      Char: sx, fix io unmapping
      Char: merge ip2main and ip2base
      ip2: cleanup globals
      ip2: fix sparse warnings
      ip2: init/deinit cleanup
      modpost: add support for hid
      HID: make a bus from hid code
      HID: hid, make parsing event driven
      HID: move ids into separate file
      HID: move usage input mapping to hid.h
      HID: move logitech quirks
      HID: move ignore quirks
      HID: move apple quirks
      HID: add compat support
      HID: indent switches/cases
      HID: move microsoft quirks
      HID: move sunplus quirks
      HID: move cypress quirks
      HID: move a4tech quirks
      HID: move cherry quirks
      HID: move ezkey quirks
      HID: move chicony quirks
      HID: move belkin quirks
      HID: move petalynx quirks
      HID: move monterey quirks
      HID: move gyration quirks
      HID: move samsung quirks
      HID: remove hid-input-quirks
      HID: remove rdesc quirk support
      HID: move sony quirks
      HID: move dell quirks
      HID: move connect quirks
      HID: move reset leds quirk
      HID: move logitech FF processing
      HID: fix tty<->hid deadlock
      HID: move pantherlord FF processing
      HID: move thrustmaster FF processing
      HID: move zeroplus FF processing
      HID: remove hid-ff
      HID: convert to dev_* prints
      Char: ds1286, eliminate busy waiting
      Char: sx, remove bogus iomap

Jochen Friedrich (1):
      powerpc/cpm1: Fix race condition in CPM1 GPIO library.

Joe Buehler (1):
      x86: add PCI ID for 6300ESB force hpet

Joe Korty (4):
      x86: make poll_idle behave more like the other idle methods
      make might_sleep() display the oopsing process
      message queues: increase range limits
      proc: fix vma display mismatch between /proc/pid/{maps,smaps}

Joe Rouvier (1):
      Input: convert drivers to use strict_strtoul()

Joel Becker (21):
      ocfs2: Prefix the extent tree operations structure.
      ocfs2: Prefix the ocfs2_extent_tree structure.
      ocfs2: Make ocfs2_extent_tree get/put instead of alloc.
      ocfs2: Make 'private' into 'object' on ocfs2_extent_tree.
      ocfs2: Provide the get_root_el() method to ocfs2_extent_tree_operat=
ions.
      ocfs2: Use struct ocfs2_extent_tree in ocfs2_num_free_extents().
      ocfs2: Determine an extent tree's max_leaf_clusters in an et_op.
      ocfs2: Create specific get_extent_tree functions.
      ocfs2: Add an insertion check to ocfs2_extent_tree_operations.
      ocfs2: Make ocfs2_extent_tree the first-class representation of a t=
ree.
      ocfs2: Comment struct ocfs2_extent_tree_operations.
      ocfs2: Change ocfs2_get_*_extent_tree() to ocfs2_init_*_extent_tree=
()
      ocfs2: Limit inode allocation to 32bits.
      ocfs2: Add the 'inode64' mount option.
      ocfs2: Switch over to JBD2.
      ocfs2: Separate out sync reads from ocfs2_read_blocks()
      ocfs2: Require an inode for ocfs2_read_block(s)().
      ocfs2: Simplify ocfs2_read_block()
      ocfs2: Move ocfs2_bread() into dir.c
      ocfs2: Kill the last naked wait_on_buffer() for cached reads.
      ocfs2: Make cached block reads the common case.

Joerg Roedel (55):
      x86: convert pci-dma.c from round_up to roundup
      x86: convert pageattr.c from round_up to roundup
      x86: convert init_64.c from round_up to roundup
      x86: convert numa_64.c from round_up to roundup
      x86: convert discontig_32.c from round_up to roundup
      x86: add alloc_coherent dma_ops callback to GART driver
      x86: add free_coherent dma_ops callback to GART driver
      x86: add free_coherent dma_ops callback to Calgary IOMMU driver
      x86: add alloc_coherent dma_ops callback to NOMMU driver
      x86: add free_coherent dma_ops callback to NOMMU driver
      x86: cleanup dma_*_coherent functions
      x86: move dma_*_coherent functions to include file
      x86, AMD IOMMU: remove obsolete FIXME comment
      x86, pci: add northbridge pci ids for fam 0x11 processors
      x86, gart: add detection of AMD family 0x11 northbridges
      AMD IOMMU: check for invalid device pointers
      AMD IOMMU: move TLB flushing to the map/unmap helper functions
      x86: move GART TLB flushing options to generic code
      AMD IOMMU: implement lazy IO/TLB flushing
      AMD IOMMU: add branch hints to completion wait checks
      AMD IOMMU: align alloc_coherent addresses properly
      AMD IOMMU: add event buffer allocation
      AMD IOMMU: save pci segment from ACPI tables
      AMD IOMMU: save pci_dev instead of devid
      AMD IOMMU: add MSI interrupt support
      AMD IOMMU: add event handling code
      AMD IOMMU: enable event logging
      AMD IOMMU: allow IO page faults from devices
      AMD IOMMU: add dma_supported callback
      AMD IOMMU: don't assign preallocated protection domains to devices
      AMD IOMMU: some set_device_domain cleanups
      AMD IOMMU: replace memset with __GFP_ZERO in alloc_coherent
      AMD IOMMU: simplify dma_mask_to_pages
      AMD IOMMU: free domain bitmap with its allocation order
      AMD IOMMU: remove unnecessary cast to u64 in the init code
      AMD IOMMU: calculate IVHD size with a function
      AMD IOMMU: use cmd_buf_size when freeing the command buffer
      add AMD IOMMU tree to MAINTAINERS file
      AMD IOMMU: use coherent_dma_mask in alloc_coherent
      x86/iommu: make GART driver checkpatch clean
      x86/iommu: convert GART need_flush to bool
      x86/iommu: use __GFP_ZERO instead of memset for GART
      KVM: add MC5_MISC msr read support
      MAINTAINERS: add entry for the KVM AMD module
      introduce generic header file for the software IO/TLB
      x86: rename iommu_num_pages function to iommu_nr_pages
      sparc64: rename iommu_num_pages function to iommu_nr_pages
      powerpc: rename iommu_num_pages function to iommu_nr_pages
      introduce generic iommu_num_pages function
      x86: convert GART driver to generic iommu_num_pages function
      x86, AMD IOMMU: convert driver to generic iommu_num_pages function
      x86: convert Calgary IOMMU driver to generic iommu_num_pages functi=
on
      powerpc: use iommu_num_pages function in IOMMU code
      alpha: use iommu_num_pages function in IOMMU code
      sparc64: use iommu_num_pages function in IOMMU code

Johann Felix Soden (1):
      powerpc/iseries: Remove unused variable in viodasd.c

Johannes Berg (83):
      mac80211: fill start-sequence-number for BA session start
      mac80211: move some RCU locking into an if branch
      mac80211: make conf_tx non-atomic
      mac80211: BSS info: check channel first
      mac80211: fix action frame length checks
      mac80211: fix typo in action frame handling
      mac80211: move IE parsing to util file
      mac80211: reorder mlme code
      mac80211: use sdata pointer for scan interface
      mac80211: remove useless non-NULL tests from scan results code
      mac80211: start moving scan code from mlme
      mac80211: refactor and move scan RX code
      mac80211: move BSS handling to scan code
      mac80211: move some HT code out of mlme.c
      mac80211: move some HT code out of main.c
      mac80211: clarify scan request
      mac80211: simplify scan start
      mac80211: remove useless 'ibss' parameter
      mac80211: reorder frame code in mlme
      mac80211: consolidate deauth/disassoc
      mac80211: split ieee80211_sta_def_wmm_params
      mac80211: initialise queue QoS parameters at hw start
      mac80211: make BA session handling independent of STA mode
      mac80211: move spectrum management code out
      mac80211: make ieee80211_rx_h_mgmt more readable
      mac80211: move frame TX function
      mac80211: move ieee80211_sta_expire
      mac80211: move STA timer restart
      mac80211: dont set REQ_RUN when scan finishes
      mac80211: split off mesh handling entirely
      mac80211: fix work race
      mac80211: fix scan vs. interface removal race
      mac80211: reorder MLME code more
      mac80211: move ieee80211_set_freq to utils
      mac80211: make bridge_packets a virtual interface option
      mac80211: clean up scan namespace
      mac80211: clean up some comments
      mac80211: inform driver of basic rateset
      mac80211: use nl80211 interface types
      mac80211: move regular interface handling
      mac80211: warn on some invalid vlan operations
      mac80211 hwsim: verify vif pointers
      mac80211: share STA information with driver
      mac80211 hwsim: verify sta pointers
      mac80211: small rate control changes
      mac80211: move last_txrate_idx into RC algorithms
      mac80211: share sta->supp_rates
      mac80211: move txrate_idx into RC algorithms
      mac80211: share sta_info->ht_info
      iwlwifi: don't access mac80211's AMPDU state machine
      mac80211: pass AP vif pointer for VLANs
      mac80211: fix virtual interfaces vs. injection
      mac80211 hwsim: make radio list dynamic
      mac80211: fix sta_info kernel-doc warning
      mac80211: clean up kdoc
      mac80211: remove beacon counters
      mac80211: remove debug frame dumping
      cfg80211: fix static regdomains
      cfg80211: clean up regulatory mess
      cfg80211: fix regulatory code const
      cfg80211: clean up static regdomain mess
      cfg80211: fix code ordering in header file
      mac80211: make master iface not wireless
      cfg80211: show interface type
      cfg80211: allow set_interface without type
      mac80211: allow interface settings changes only when down
      cfg80211: reject invalid configuration items
      mac80211: fix mesh action frame handling
      mac80211: clean up rate control API
      mac80211: probe with correct SSID
      iwlagn: downgrade BUG_ON in interrupt
      mac80211: fixups for "make master iface not wireless"
      powerpc: Fix 64-bit hibernation with 64k pages
      powerpc: Enforce sane MAX_ORDER
      mac80211: fix debugfs lockup
      mac80211: fix HT information element parsing
      mac80211: fix debugfs netdev rename
      cfg80211: fix debugfs error handling
      ath9k/mac80211: disallow fragmentation in ath9k, report to userspac=
e
      remove CONFIG_KMOD from drivers
      remove CONFIG_KMOD from fs
      net: Remove CONFIG_KMOD from net/ (towards removing CONFIG_KMOD ent=
irely)
      ALSA: aoa i2sbus: don't overwrite module parameter

Johannes Dickgreber (2):
      MIPS: Fix wrong branch target in new spin_lock code.
      MIPS: show_cpuinfo prints the type of the calling CPU

Johannes Weiner (1):
      vmscan: don't accumulate scan pressure on unrelated lists

John L. Utz III (1):
      ALSA: ac97 - vt1618 7.1 Audio Support

John Lacombe (1):
      RDMA/nes: Use ethtool timer value

John Ogness (1):
      UIO: add automata sercos3 pci card support

John Rigby (3):
      powerpc/fsl: Hide MPC5121 pci bridge.
      powerpc: 83xx: pci: Remove need for get_immrbase from mpc83xx_add_b=
ridge.
      powerpc/5121: Add PCI support.

John Stultz (2):
      clocksource: keep track of original clocksource frequency
      clocksource: introduce CLOCK_MONOTONIC_RAW

John W. Linville (5):
      libertas: correct "limited range of data type" warning
      ieee80211.h: remove superfluous ETH_P_PAE definition
      ath9k: fixup some merge damage
      mac80211: avoid "Wireless Event too big" message for assoc response
      rtl8187: add device ID 0bda:8198

Jon Dufresne (1):
      fbmon: fix EDID parser to detect interlace modes

Jon K Hellan (1):
      USB: Option / AnyData new modem, same ID

Jon Mason (1):
      RDMA/cxgb3: Set active_mtu in ib_port_attr

Jon Smirl (5):
      ALSA: ASoC: Convert bitfields in ASoC into full int width
      ALSA: ASoC: Rename mask to max to reflect usage
      ALSA: ASoC: convert use of uint to unsigned int
      of: Format string bug in drivers/of/of_i2c.c
      [netdrvr] fec_mpc52xx: Implement polling, to make netconsole work.

Jon Tollefson (3):
      powerpc: Reserve in bootmem lmb reserved regions that cross NUMA no=
des
      powerpc/numa: Make memory reserve code more robust
      powerpc: Don't use a 16G page if beyond mem=3D limits

Jonas Bonn (2):
      ALSA: ASoC: Add widgets before setting endpoints on GTA01
      ALSA: ASoC: Drop device registration from GTA01 lm4857 driver

Jonathan Brassow (1):
      dm raid1: kcopyd should stop on error if errors handled

Jonathan Cameron (1):
      [ARM] 5278/1: i2c-pxa fast mode support

Jonathan Corbet (3):
      Add the development process document
      Remove videobook.tmpl
      UIO: BKL removal

Jonathan Woithe (1):
      fujitsu-laptop: better handling of P8010 hotkey

Jordan Crouse (1):
      x86, hpet: SB600 - remove HPET resources from PCI device

Jose Alberto Reguero (1):
      V4L/DVB (9272): mxl5005s: Bug fix stopped DVB-T from working the se=
cond time around.

Josef Bacik (2):
      generic block based fiemap implementation
      ext3: don't try to resize if there are no reserved gdt blocks left

Joseph Chan (16):
      ALSA: hda - Fix VIA recording problem
      viafb: viafb.modes, viafb.txt
      viafb: Makefile, Kconfig
      viafb: accel.c, accel.h
      viafb: chip.h, debug.h
      viafb: dvi.c, dvi.h, global.c and global.h
      viafb: hw.c, hw.h
      viafb: iface.c, iface.h, ioctl.c, ioctl.h
      viafb: lcd.c, lcd.h, lcdtbl.h
      viafb: Makefile, share.h
      viafb: tbl1636.c, tbl1636.h, tblDPASetting.c, tblDPASetting.h
      viafb: viafbdev.c, viafbdev.h
      viafb: viafbdev.c (update)
      viafb: via_i2c.c, via_i2c.h, viamode.c, viamode.h
      viafb: via_utility.c, via_utility.h, vt1636.c, vt1636.h
      viafb: MAINTAINERS entry

Josh Boyer (19):
      powerpc/44x: Add PowerPC 44x simple platform support
      powerpc/44x: Migrate Bamboo support to ppc44x_simple
      powerpc/44x: Migrate Canyonlands support to ppc44x_simple
      powerpc/44x: Migrate Katmai support to ppc44x_simple
      powerpc/44x: Migrate Rainier support to ppc44x_simple
      powerpc/44x: Migrate Sequoia support to ppc44x_simple
      powerpc/44x: Migrate Taishan support to ppc44x_simple
      powerpc/44x: Add explicit support for AMCC Glacier
      powerpc/44x: Add explicit Yosemite support
      ibm_newemac: Allow the "no flow control" EMAC feature to work
      ibm_newemac: Introduce mal_has_feature
      ibm_newemac: MAL support for PowerPC 405EZ
      powerpc: Remove old Makefile workaround for arch/ppc
      powerpc/40x: AMCC PowerPC 405EZ Acadia DTS
      powerpc/40x: Add AMCC PowerPC 405EZ to cputable
      powerpc/40x: Add PowerPC 40x simple platform support
      powerpc/40x: Add cuboot wrapper for Acadia board
      powerpc/40x: Add PowerPC 405EZ Acadia defconfig
      ibm_newemac: Fix new MAL feature handling

Josh Poimboeuf (1):
      powerpc: Fix error path in kernel_thread function

Jouni Hogander (1):
      ARM: OMAP2 Provide function to enable/disable uart clocks

Jouni Malinen (12):
      mac80211/cfg80211: Add BSS configuration options for AP mode
      ath9k: Allow AP mode to be enabled
      ath9k: Updated Beacon generation to use mac80211-style
      ath9k: Fix TX status reporting
      ath9k: Assign seq# when mac80211 requests this
      ath9k: Fix TX control flag use for no ACK and RTS/CTS
      mac80211: Handle scan result IEs in one block
      mac80211_hwsim: Add minimal IEEE 802.11n support
      ath9k: Use mac80211 for multicast power save buffering
      mac80211/cfg80211: HT capabilities for NEW_STA
      mac80211: Reorder debugfs calls during netdev deinit
      mac80211: Fix scan RX processing oops

Julia Lawall (24):
      [MTD] Use DIV_ROUND_UP
      net/ieee80211: adjust error handling
      drivers/dma/ioat_dma.c: drop code after return
      IB: Drop code after return statement
      drivers/isdn/capi/kcapi.c: Adjust error handling code involving cap=
i_ctr_put
      drivers/atm: Use DIV_ROUND_UP
      drivers/net/wan: Use DIV_ROUND_UP
      net/atm/lec.c: drop code after return
      drivers/block: Use DIV_ROUND_UP
      [CPUFREQ] drivers/cpufreq/cpufreq.c: Adjust error handling code inv=
olving cpufreq_cpu_put
      [S390] cio: Correct use of ! and &
      V4L/DVB (8729): Use DIV_ROUND_UP
      V4L/DVB (8954): common/tuners: Drop code after return or goto
      drivers/serial/crisv10.c: add missing put_tty_driver
      drivers/char/hvc_console.c: adjust call to put_tty_driver
      arch/m68k/mm/kmap.c: introduce missing kfree
      ieee1394: Use DIV_ROUND_UP
      fuse: add missing fuse_request_free
      drivers/misc: Use DIV_ROUND_UP
      drivers/net/xen-netfront.c: Use DIV_ROUND_UP
      FRV: Eliminate NULL test and memset after alloc_bootmem
      drivers/usb/class/usblp.c: adjust error handling code
      PCI hotplug: fix logic in Compaq hotplug controller bus speed setup
      [SCSI] sun3x_esp: Convert && to ||

Julian Anastasov (1):
      ipv4: Loosen source address check on IPv4 output

Julien Brunel (8):
      GFS2: Use an IS_ERR test rather than a NULL test
      UBI: fix IS_ERR test
      UBIFS: use an IS_ERR test rather than a NULL test
      ALSA: sound/soc/at32: Useless NULL test
      RDMA/ucma: Test ucma_alloc_multicast() return against NULL, not wit=
h IS_ERR()
      fs/reiserfs: use an IS_ERR test rather than a NULL test
      USB: drivers/usb/misc: Use an IS_ERR test rather than a NULL test
      USB: isp1760: Use an IS_ERR test rather than a NULL test

Julien May (2):
      avr32: Allow fine-grained control over LCDC pins
      avr32: Allow selecting multiple pins at once

Julius Volz (29):
      IPVS: Add genetlink interface definitions to ip_vs.h
      IPVS: Add genetlink interface implementation
      IPVS: Integrate ESP protocol into ip_vs_proto_ah.c
      IPVS: Rename ip_vs_proto_ah.c to ip_vs_proto_ah_esp.c
      IPVS: Add CONFIG_IP_VS_IPV6 option for IPv6 support
      IPVS: Change IPVS data structures to support IPv6 addresses
      IPVS: Add general v4/v6 helper functions / data structures
      IPVS: Add debug macros for v4 and v6 address output
      IPVS: Add internal versions of sockopt interface structs
      IPVS: Convert __ip_vs_svc_get() and __ip_vs_fwm_get()
      IPVS: Add v6 support to ip_vs_service_get()
      IPVS: Add IPv6 support flag to schedulers
      IPVS: Add 'af' args to protocol handler functions
      IPVS: Add protocol debug functions for IPv6
      IPVS: Extend protocol DNAT/SNAT and state handlers
      IPVS: Extend functions for getting/creating connections
      IPVS: Add IPv6 support to xmit() support functions
      IPVS: Add and bind IPv6 xmit functions
      IPVS: Extend scheduling functions for IPv6 support
      IPVS: Add/adjust Netfilter hook functions and helpers for v6
      IPVS: Convert real server lookup functions
      IVPS: Disable sync daemon for IPv6 connections
      IPVS: Turn off FTP application helper for IPv6
      IPVS: Adjust various debug outputs to use new macros
      IPVS: Activate IPv6 Netfilter hooks
      IPVS: Allow adding IPv6 services from userspace
      IPVS: Remove incorrect ip_route_me_harder(), fix IPv6
      IPVS: Move IPVS to net/netfilter/ipvs
      ipvs: Update CONFIG_IP_VS_IPV6 description and help text

J=C3=BCrgen Schindele (3):
      [ARM] 5204/1: Trizeps4 SOM update
      [ARM] 5251/1: remove old LED support for Trizeps4 SOM
      [ARM] 5294/1: Trizeps4 PCMCIA support

KAMEZAWA Hiroyuki (7):
      memcg: move charge swapin under lock
      memcg: make page->mapping NULL before uncharge
      memcg: avoid accounting special pages
      memcg: optimize per-cpu statistics
      memcg: atomic ops for page_cgroup->flags
      memcg: allocate all page_cgroup at boot
      memcg: fix page_cgroup allocation

KOSAKI Motohiro (4):
      swap: use an array for the LRU pagevecs
      vmscan: kill unused lru functions
      coredump_filter: add hugepage dumping
      hugepage: support ZERO_PAGE()

KOVACS Krisztian (15):
      ipv4: Implement IP_TRANSPARENT socket option
      ipv4: Make inet_sock.h independent of route.h
      ipv4: Conditionally enable transparent flow flag when connecting
      tcp: Handle TCP SYN+ACK/ACK/RST transparency
      ipv4: Make Netfilter's ip_route_me_harder() non-local address compa=
tible
      tcp: Port redirection support for TCP
      udp: Export UDP socket lookup function
      inet: Add udplib_lookup_skb() helpers
      inet: Don't lookup the socket if there's a socket attached to the s=
kb
      netfilter: split netfilter IPv4 defragmentation into a separate mod=
ule
      netfilter: iptables tproxy core
      netfilter: iptables socket match
      netfilter: iptables TPROXY target
      netfilter: Add documentation for tproxy
      tcp: Fix IPv6 fallout from 'Port redirection support for TCP'

KaiGai Kohei (1):
      SELinux: add boundary support and thread context assignment

Kaihui Luo (1):
      netfilter: xt_time gives a wrong monthday in a leap year

Kailang Yang (13):
      ALSA: hda - fix spaces in patch_realtek.c
      ALSA: hda - Add support of HP DC7600
      ALSA: hda - Add support of Toshiba S06
      ALSA: hda - Add support of Acer Aspire One
      ALSA: hda - Add support of Quanta FL1
      ALSA: hda - support more ALC888 devices
      ALSA: hda - Add more ALC662/663 codec support
      ALSA: hda - Add auto mic switch in realtek auto-probe mode
      ALSA: hda - Fix PCI SSID of ASUS M90V
      ALSA: hda - Add ALC1200 support
      ALSA: hda - Add ALC887 support
      ALSA: hda - Add support of ALC272
      ALSA: hda - Fix quirk lists for realtek codecs

Kalpak Shah (1):
      ext4: fix xattr deadlock

Kamalesh Babulal (1):
      net: fix driver build errors due to missing net/ip6_checksum.h incl=
ude

Karl Beldan (1):
      [MTD] [NAND] nand_base.c: reset chip first

Karsten Wiese (1):
      ALSA: Add USB US122L driver

Kay Sievers (2):
      [S390] bus_id -> dev_name conversions
      block: sanitize invalid partition table entries

Kay, Allen M (1):
      VT-d: Changes to support KVM

Kazuo Ito (1):
      dm kcopyd: avoid queue shuffle

Kees Cook (1):
      proc: show personality via /proc/pid/personality

Keith Packard (14):
      agp/intel: Reduce extraneous PCI posting reads during init
      i915: remove settable use_mi_batchbuffer_start
      i915: Ignore X server provided mmio address
      i915: Track progress inside of batchbuffers for determining wedgedn=
ess.
      i915: Initialize hardware status page at device load when possible.
      Export shmem_file_setup for DRM-GEM
      i915: Use non-reserved status page index for breadcrumb
      i915: Fix up ring initialization to cover G45 oddities
      i915: Map status page cached for chips with GTT-based HWS location.
      i915: Don't run retire work handler while suspended
      i915: Protect vblank IRQ reg access with spinlock
      i915: Disable MSI on GM965 (errata says it doesn't work)
      drm/i915: hold dev->struct_mutex and DRM lock during vblank ring op=
erations
      drm/i915: use pipes, not planes to label vblank data

Keith Wansbrough (1):
      floppy: support arbitrary first-sector numbers

Ken'ichi Ohmichi (1):
      kdump: add vmlist.addr to vmcoreinfo for x86 vmalloc translation.

Kenji Kaneshige (6):
      PCI: pciehp: fix irq initialization
      PCI hotplug: fix get_##name return value problem
      PCI Hotplug: serialize pci_hp_register and pci_hp_deregister
      PCI hotplug: pciehp: fix possible memory leak in pcie_init
      PCI hotplug: pciehp: poll data link layer link active
      PCI hotplug: cpqphp: fix kernel NULL pointer dereference

Kenneth Kiraly (1):
      sound: ASoC: Add WM8971 CODEC driver

Kevin Diggs (1):
      sched: add kernel doc for the completion, fix kernel-doc-nano-HOWTO=
.txt

Kevin Hao (3):
      x86: get irq for hpet timer
      net: add net poll support for atl2 driver
      net: remove LLTX in atl2 driver

Kevin Hilman (2):
      ARM: DaVinci: Update IO address pointer typechecking
      MUSB: Add sanity check for maximum number of endpoints

Kevin Lloyd (1):
      USB Serial: Sierra: debug message fix

Kevin Lo (3):
      via-rhine: changed to use netdev_alloc_skb() from dev_alloc_skb
      8139cp: use netdev_alloc_skb
      8139too: use netdev_alloc_skb

Kirill A. Shutemov (3):
      V4L/DVB (8959): include <linux/videodev2.h> into linux/ivtv.h
      alpha: introduce field 'taso' into struct linux_binprm
      Allow recursion in binfmt_script and binfmt_misc

Kiyoshi Ueda (14):
      block: add request update interface
      block: add request submission interface
      block: add a queue flag for request stacking support
      block: add lld busy state exporting interface
      virtio_blk: change to use __blk_end_request()
      memstick: change to use __blk_end_request()
      gdrom: change to use __blk_end_request()
      block: change elevator to use __blk_end_request()
      block: remove end_{queued|dequeued}_request()
      dm mpath: remove is_active from struct dm_path
      dm: remove unused flush_all
      dm: tidy local_init
      [SCSI] refactor sdev/starget/shost busy checking
      [SCSI] export busy state via q->lld_busy_fn()

Klaus-Dieter Wacker (1):
      [S390] qdio enhanced SIGA (iqdio) support.

Komal Shah (1):
      ARM: DaVinci: i2c setup

Kou Ishizaki (1):
      powerpc/spufs: add a missing mutex_unlock

Krishna Kumar (3):
      mm: do_generic_file_read() never gets a NULL 'filp' argument
      nfsd: Fix memory leak in nfsd_getxattr
      nfsd: Drop reference in expkey_parse error cases

Kristen Carlson Accardi (1):
      PCI hotplug: rpaphp: make debug var unique

Kristian H=C3=B8gsberg (3):
      i915: Add chip set ID param.
      i915: Make use of sarea_priv conditional.
      i915 gem: install and uninstall irq handler in entervt and leavevt =
ioctls.

Kristoffer Ericson (6):
      [ARM] 5256/1: Update jornada default config
      [ARM] 5270/1: Fix Formatting in mach-sa1100/ machine files
      [ARM] 5277/1: Add basic support for MobilePro 900/c
      fbdev: allow more chip revisions in Epson s1d13... video driver
      fbdev: Epson S1D1 framebuffer maintainer
      [ARM] 5315/1: Fix section mismatch warning (sa1111)

Krzysztof Halasa (1):
      wan/hdlc_x25.c: fix a NULL dereference

Krzysztof Helt (44):
      ALSA: wss_lib: move cs4231_lib into wss_lib
      ALSA: wss_lib: rename cs4231.h into wss.h
      ALSA: wss_lib: rename cs4321_foo to wss_foo
      ALSA: wss_lib: use struct snd_wss instead of snd_ad1848
      ALSA: wss_lib: use wss constants instead of ad1848 ones
      ALSA: wss_lib: replace ad1848 mixer element macros with wss ones
      ALSA: wss_lib: use CS4231P instead of AD1848P (kill the AD1848P)
      ALSA: wss_lib: use wss mixer code instead of ad1848 one
      ALSA: wss_lib: use wss pcm code instead of ad1848 one
      ALSA: wss_lib: use wss detection code instead of ad1848 one
      ALSA: wss_lib: fix opti93x capture formats limitations
      ALSA: wss_lib: remove second mutexes initialization
      ALSA: opl3sa2: drop snd_card pointer from the snd_opl3sa2 structure
      ALSA: wss_lib: snd_wss_calibrate_mute improvement
      ALSA: opl3sa2: replace nd_opl3sa2_info_xxx() with snd_wss_info_xxx(=
)
      ALSA: wss_lib: do not mess mixer settings during probe
      rtc-m48t59: reduce structure m48t59_private
      rtc-m48t59: add support for M48T02 and M48T59 chips
      rtc-m48t59: allow externally mapped ioaddr
      x86: delay early cpu initialization until cpuid is done
      sched: compilation fix with gcc 3.4.6
      sparc64: fix wrong m48t59 RTC year
      rtc-m48t59: fix setting of a year on m48t08 and m48t02 rtcs
      ALSA: fix section mismatch in the sound_core
      x86: merge winchip-2 and winchip-2a cpu choices
      x86: do not allow to optimize flag_is_changeable_p() (rev. 2)
      neofb: reduce panning function
      fbdev: kconfig update
      neofb: kill some redundant code
      vga16fb: remove open_lock mutex
      neofb: remove open_lock mutex
      tdfxfb: do not make changes to default tdfx_fix
      cirrusfb: remove information about memory size during mode change
      cirrusfb: simplify clock calculation
      cirrusfb: remove 24 bpp mode
      cirrusfb: drop device pointers from cirrusfb_info
      cirrusfb: use modedb and add mode_option parameter
      cirrusfb: add __devinit attribute to probing functions
      cirrusfb: eliminate CRT registers from global structure
      cirrusfb: drop clock fields from cirrusfb_regs structure
      cirrusfb: add noaccel module parameter
      cirrusfb: fix 16bpp modes
      cirrusfb: do not change MCLK for Alpine chips
      fb: convert lock/unlock_kernel() into local fb mutex

Krzysztof Oledzki (1):
      x86: add another PCI ID for ICH6 force-hpet

Kumar Gala (28):
      [MTD] remove code associated with !CONFIG_PPC_MERGE
      serial/cpm_uart: Remove dead Kconfig options
      math-emu: Fix compiler warnings
      math-emu: Add support for reporting exact invalid exception
      powerpc: Fix build warnings introduced by PMC support on 32-bit
      powerpc/fsl-booke: Fixup 64-bit PTE reading for SMP support
      powerpc: convert CONFIG_PPC_MERGE to CONFIG_PPC for legacy io check=
s
      powerpc/83xx: Add missing cell-index to dma-channel device nodes
      powerpc/86xx: Introduce a generic mpc86xx_defconfig
      powerpc: Move 8xxx GPIO Kconfig under the platform menu
      powerpc: Introduce local (non-broadcast) forms of tlb invalidates
      powerpc: Fixes for CONFIG_PTE_64BIT for SMP support
      powerpc/mm: Implement _PAGE_SPECIAL & pte_special() for 32-bit
      netdev: drop CONFIG_PPC_MERGE from Kconfig
      fs-enet: remove code associated with !CONFIG_PPC_MERGE
      serial/mpc52xx_uart: remove code associated with !CONFIG_PPC_MERGE
      pata_sil680: convert CONFIG_PPC_MERGE to CONFIG_PPC
      powerpc/math-emu: Use kernel generic math-emu code
      [MTD] [NAND] remove dead Kconfig associated with !CONFIG_PPC_MERGE
      powerpc: Make ppc32 respect the boot cpu id for !CONFIG_SMP
      powerpc/85xx: Wire up RTC interrupt on MPC8536DS
      mpc52xx_psc_spi: remove code associated with !CONFIG_PPC_MERGE
      rtc: use CONFIG_PPC instead of CONFIG_PPC_MERGE
      usb: remove code associated with !CONFIG_PPC_MERGE
      powerpc: Fix build issue with CONFIG_RELOCATABLE=3Dy
      powerpc: Remove Kconfig support for PPC_MERGE
      powerpc/85xx: Move mpc8572ds.dts to address-cells/size-cells =3D <2=
>
      math-emu: Fix signalling of underflow and inexact while packing res=
ult.

Kyle McMartin (10):
      parisc: parisc-agp - fix <asm-parisc/*> -> <asm/*>
      parisc: ropes.h - fix <asm-parisc/*> -> <asm/*>
      parisc: add arch/parisc/kernel/.gitignore
      parisc: unify CCIO_COLLECT_STATS implementation
      parisc: move pdc_result to real2.S
      parisc: move include/asm-parisc to arch/parisc/include/asm
      parisc: add pdc_coproc_cfg_unlocked and set_firmware_width_unlocked
      parisc: hijack jump to start_kernel
      parisc: add new syscalls
      parisc: add rtc platform driver

Lai Jiangshan (15):
      rcu classic: simplify the next pending batch
      rcu classic: new algorithm for callbacks-processing(v2)
      doc/RCU: fix pseudocode in rcuref.txt
      signal, procfs: some lock_task_sighand() users do not need rcu_read=
_lock()
      markers: fix unregister bug and reenter bug
      markers: fix unchecked format
      markers: bit-field is not thread-safe nor smp-safe
      cgroups: fix probable race with put_css_set[_taskexit] and find_css=
_set
      devcgroup: remove spin_lock()
      seq_file: don't call bitmap_scnprintf_len()
      seq_file: add seq_cpumask_list(), seq_nodemask_list()
      cpuset: use seq_*mask_* to print masks
      bitmask: remove bitmap_scnprintf_len()
      rcupdate: fix bug of rcu_barrier*()
      x86/proc: fix /proc/cpuinfo cpu offline bug

Larry Finger (9):
      ssb: Update for Rev. 5 SPROM
      ssb: Clean up extraction of MAC addresses from SPROM
      b43legacy: Fix failure in rate-adjustment mechanism
      b43: Issue warning when RFKILL_INPUT is not enabled
      b43: Fix Bluetooth coexistence SPROM coding error for Motorola 7010=
 variant of BCM4306
      p54: Fix sparse warnings
      b43: Fix Bluetooth Coexistence SPROM programming error for HP 12f8 =
version of BCM4306
      b43: Increase loop tries in do_dummy_tx
      p54: Fix compilation problem on PPC

Laurent Pinchart (9):
      V4L/DVB (8754): uvcvideo: Implement the USB power management reset_=
resume method.
      V4L/DVB (8846): uvcvideo: Supress spurious "EOF in empty payload" t=
race message
      V4L/DVB (8847): uvcvideo: Add support for a Bison Electronics webca=
m found in the Fujitsu Amilo SI2636.
      V4L/DVB (9030): uvcvideo : Add support for Advent 4211 integrated w=
ebcam
      V4L/DVB (9031): uvcvideo: Fix incomplete frame drop when switching =
to a variable size format.
      V4L/DVB (9035): uvcvideo: Declare missing camera and processing uni=
t controls.
      V4L/DVB (9036): uvcvideo: Fix control cache access when setting com=
posite auto-update controls
      V4L/DVB (9169): uvcvideo: Support two new Bison Electronics webcams.
      rtc-pcf8563: remove client validation

Leandro Costantino (1):
      V4L/DVB (9293): gspca: Separate and fix the sensor dependant sequen=
ces in t613.

Lee Howard (2):
      8250: Oxford Semiconductor Devices
      8250: Add more OxSemi devices

Lee Schermerhorn (13):
      pageflag helpers for configed-out flags
      Unevictable LRU Infrastructure
      unevictable lru: add event counting with statistics
      Unevictable LRU Page Statistics
      Ramfs and Ram Disk pages are unevictable
      SHM_LOCKED pages are unevictable
      doc: unevictable LRU and mlocked pages documentation
      mlock: downgrade mmap sem while populating mlocked regions
      swap: cull unevictable pages in fault path
      vmscan: unevictable LRU scan sysctl
      mlock: count attempts to free mlocked page
      mlock: revert mainline handling of mlock error return
      mlock: make mlock error return Posixly Correct

Len Brown (31):
      dock: Shaohua Li is new maintainer
      ACPI: remove unused acpi_is_child_device()
      Merge branch 'FW_BUG' into test
      Merge branch 'acer-wmi' into test
      Merge branch 'bugfixes' into test
      Merge branch 'acpica' into test
      Merge branch 'asus-cleanup' into test
      Merge branch 'bugzilla-10237' into test
      Merge branch 'bugzilla-10503' into test
      Merge branch 'bugzilla-11481' into test
      Merge branch 'cpuidle' into test
      Merge branch 'dock' into test
      Merge branch 'ec' into test
      Merge branch 'eeepc' into test
      Merge branch 'fadt-test' into test
      Merge branch 'fujitsu' into test
      Merge branch 'i7300_idle' into test
      Merge branch 'misc' into test
      Merge branch 'pnp-debug' into test
      Merge branch 'suspend' into test
      Merge branch 'thinkpad' into test
      Merge branch 'ull' into test
      Merge branch 'yinghai' into test
      Merge branch 'panasonic' into test
      panasonic-laptop: fix build
      Merge branch 'linus' into test
      intel_menlo: fix build warning
      ACPI suspend: fix build warning when CONFIG_ACPI_SLEEP=3Dn
      Merge branch 'bugzilla-11715' into test
      ACPI: fix ia64 build warning
      staging: pcc_acpi: delete obsolete driver

Lennert Buytenhek (53):
      [ARM] 5222/1: Allow configuring user:kernel split via Kconfig
      mv643xx_eth: fix 'netdev_priv(dev) =3D=3D dev->priv' assumption
      mv643xx_eth: fix receive buffer DMA unmapping
      mv643xx_eth: get rid of IRQF_SAMPLE_RANDOM
      mv643xx_eth: get rid of modulo operations
      mv643xx_eth: switch ->phy_lock from a spinlock to a mutex
      mv643xx_eth: use the SMI done interrupt to wait for SMI access comp=
letion
      mv643xx_eth: make napi unconditional
      mv643xx_eth: get rid of receive-side locking
      mv643xx_eth: get rid of compile-time configurable transmit checksum=
ming
      mv643xx_eth: require contiguous receive and transmit queue numberin=
g
      mv643xx_eth: smi sharing is a per-unit property, not a per-port one
      mv643xx_eth: remove force_phy_addr field
      mv643xx_eth: get rid of netif_{stop,wake}_queue() calls on link dow=
n/up
      mv643xx_eth: delete unused and uninteresting interrupt source mask =
bits
      mv643xx_eth: transmit multiqueue support
      mv643xx_eth: move all work to the napi poll handler
      mv643xx_eth: switch to netif tx queue lock, get rid of private spin=
lock
      mv643xx_eth: avoid dropping tx lock during transmit reclaim
      mv643xx_eth: replace array of skbs awaiting transmit completion wit=
h a queue
      mv643xx_eth: shrink default receive and transmit queue sizes
      mv643xx_eth: avoid reading ->byte_cnt twice during receive processi=
ng
      mv643xx_eth: add support for chips without transmit bandwidth contr=
ol
      mv643xx_eth: fix receive checksumming
      mv643xx_eth: deal with unexpected ethernet header sizes
      mv643xx_eth: enforce frequent hardware statistics polling
      phylib: allow incremental scanning of an mii bus
      mv643xx_eth: convert to phylib
      mv643xx_eth: bump version to 1.4
      [ARM] Orion: wire up ethernet error interrupt
      [ARM] Kirkwood: wire up ethernet error interrupt
      [ARM] mv78xx0: wire up ethernet error interrupt
      [ARM] Orion: prepare for runtime-determined timer tick rate
      [ARM] Orion: add 88F6183 (Orion-1-90) support
      [ARM] Orion: add RD88F6183AP-GE support
      [ARM] Kirkwood: allow configuring mbus window for on-chip sram
      net: add skb_recycle_check() to enable netdriver skb recycling
      mv643xx_eth: hook up skb recycling
      phylib: phy_mii_ioctl() fixes
      phylib: rename mii_bus::dev to mii_bus::parent
      phylib: move to dynamic allocation of struct mii_bus
      phylib: give mdio buses a device tree presence
      phylib: add mdiobus_{read,write}
      mv643xx_eth: include linux/ip.h to fix build
      net: Distributed Switch Architecture protocol support
      dsa: add support for original DSA tagging format
      dsa: add support for the Marvell 88E6131 switch chip
      dsa: add support for Trailer tagging format
      dsa: add support for the Marvell 88E6060 switch chip
      phylib: two dynamic mii_bus allocation fallout fixes
      orion_spi: handle 88F6183 erratum
      [ARM] mv78xx0: force link speed/duplex on eth2/eth3
      [ARM] Orion: instantiate the dsa switch driver

Li Yang (3):
      usb: add Freescale QE/CPM USB peripheral controller driver
      usb/fsl_qe_udc: fix response to get status request
      usb/fsl_qe_udc: clear data toggle on clear halt request

Li Zefan (8):
      x86: remove nesting CONFIG_HOTPLUG_CPU
      ext4: add missing unlock in ext4_check_descriptors() on error path
      sched: remove redundant code in cpu_cgroup_create()
      ALSA: us122l: fix missing unlock in usb_stream_hwdep_vm_fault()
      block: fix kernel-doc for blk_alloc_devt()
      block: simplify string handling in elv_iosched_store()
      devcgroup: use kmemdup()
      devcgroup: remove unused variable

Liam Girdwood (4):
      ALSA: ASoC: update email address for Liam Girdwood
      regulator: core - Rework machine API to remove string based functio=
ns.
      regulator: update email address for Liam Girdwood
      Input: wm97xx - update email address for Liam Girdwood

Lin Ming (9):
      ACPI: replace AE_BAD_ADDRESS exception code with AE_ERROR
      ACPICA: Add function to dereference returned reference objects
      ACPI: replace ACPI_DEBUG_PRINT((ACPI_DB_ERROR, ...) with printk
      ACPICA: Reduce error to warning for incorrect method arg count
      ACPICA: Remove unused ACPI register bit definition
      ACPICA: Fix fault after mem allocation failure in AML parser
      ACPICA: Fix possible memory leak, error exit path
      ACPICA: Fixed a couple memory leaks associated with "implicit retur=
n"
      ACPICA: Fix for implicit return compatibility

Linus Torvalds (175):
      x86: quick TSC calibration
      wireless: restore revert lost to merge damage
      Merge branch 'upstream-2.6.28' of git://git.kernel.org/pub/scm/linu=
x/kernel/git/jgarzik/libata-dev
      PnP: move pnpacpi/pnpbios_init to after PCI init
      Merge phase #1 of git://git.kernel.org/pub/scm/linux/kernel/git/tip=
/linux-2.6-tip
      Merge branch 'for-2.6.28' of git://git.kernel.dk/linux-2.6-block
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/jejb/scsi-misc-=
2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/steve/gfs2-2.6-=
nmw
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/agk/linux-2.6-d=
m
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/teigland/dlm
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/roland/infiniband
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/herbert/crypto-=
2.6
      Merge branch 'sched-v28-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jmorris/security-testing-2.6
      Merge branch 'rcu-v28-for-linus' of git://git.kernel.org/pub/scm/li=
nux/kernel/git/tip/linux-2.6-tip
      ide: re-code ide_fixstring() loop to be less evil
      Merge branch 'next' of git://git.kernel.org/pub/scm/linux/kernel/gi=
t/davej/cpufreq
      Merge branch 'for-linus' of git://git390.osdl.marist.edu/pub/scm/li=
nux-2.6
      Merge branch 'for-linus' of git://git.alsa-project.org/alsa-kernel
      Merge branch 'upstream' of git://ftp.linux-mips.org/pub/scm/upstrea=
m-linus
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/sfrench/cifs-2.=
6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-=
2.6
      net: fix dummy 'nf_conntrack_event_cache()'
      Merge branch 'for-linus' of master.kernel.org:/home/rmk/linux-2.6-a=
rm
      Merge phase #2 (PAT updates) of git://git.kernel.org/pub/scm/linux/=
kernel/git/tip/linux-2.6-tip
      Merge phase #3 (IOMMU) of git://git.kernel.org/pub/scm/linux/kernel=
/git/tip/linux-2.6-tip
      Merge phase #4 (X2APIC, APIC unification, CPU identification unific=
ation) of git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6-tip
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/bart/ide-2.6
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tytso/ext4
      Fix RTC wakealarm sysfs interface breakage.
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-nex=
t-2.6
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/wim/linux-2.6-w=
atchdog
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/drzeus/mmc
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/hskinnemoen/avr=
32-2.6
      Merge branch 'x86-core-v2-for-linus' of git://git.kernel.org/pub/sc=
m/linux/kernel/git/tip/linux-2.6-tip
      Fix Kconfig dependency for WM97xx battery driver
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/sfrench/cifs-2.=
6
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tytso/ext4
      x86/mm: do not trigger a kernel warning if user-space disables inte=
rrupts and generates a page fault
      Merge phase #5 (misc) of git://git.kernel.org/pub/scm/linux/kernel/=
git/tip/linux-2.6-tip
      Merge git://git.infradead.org/users/dwmw2/random-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jmorris/security-testing-2.6
      Merge branch 'proc' of git://git.kernel.org/pub/scm/linux/kernel/gi=
t/adobriyan/proc
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/cooloney/blackfin-2.6
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/mchehab/linux-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/brodo/pcmcia-2.=
6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/bart/ide-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Revert "vt: fix background color on line feed"
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/arjan/linux-2.6-fastboot
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/lrg/voltage-2.6
      Merge branch 'for-2.6.28' of git://linux-nfs.org/~bfields/linux
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/mfasheh/ocfs2
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jikos/hid
      Merge branch 'i2c-for-linus' of git://jdelvare.pck.nerim.net/jdelva=
re-2.6
      Merge branch 'next' of git://git.kernel.org/pub/scm/linux/kernel/gi=
t/benh/powerpc
      Merge branch 'build_fix' of git://git.kernel.org/pub/scm/linux/kern=
el/git/mfasheh/ocfs2
      Merge branch 'upstream' of git://ftp.linux-mips.org/pub/scm/upstrea=
m-linus
      Introduce is_vmalloc_or_module_addr() and use with DEBUG_VIRTUAL
      Merge branch 'for-linus' of master.kernel.org:/home/rmk/linux-2.6-a=
rm
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jikos/hid
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/dtor/input
      Merge branch 'for-linus' of git://neil.brown.name/md
      Merge branch 'docs' of git://git.lwn.net/linux-2.6
      Merge branch 'personality' of git://git390.osdl.marist.edu/pub/scm/=
linux-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/rusty/linux-2.6=
-for-linus
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-c=
ore-2.6
      Merge branch 'agp-next' of git://git.kernel.org/pub/scm/linux/kerne=
l/git/airlied/agp-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/cooloney/blackfin-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/ieee1394/linux1394-2.6
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'core-v28-for-linus' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/tip/linux-2.6-tip
      Fix kernel/softirq.c printk format warning properly
      Merge branch 'kvm-updates/2.6.28' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/avi/kvm
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge branch 'sched-fixes-for-linus' of git://git.kernel.org/pub/sc=
m/linux/kernel/git/tip/linux-2.6-tip
      Merge git://git.linux-nfs.org/projects/trondmy/nfs-2.6
      {pci,pnp} quirks.c: don't use deprecated print_fn_descriptor_symbol=
()
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/jejb/scsi-misc-=
2.6
      Merge branch 'for-linus' of git://www.jni.nu/cris
      Merge branch 'for-linus' of git://git.kernel.dk/linux-2.6-block
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge branch 'hwmon-for-linus' of git://jdelvare.pck.nerim.net/jdel=
vare-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging-=
2.6
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tytso/ext4
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/mchehab/linux-2.6
      Merge branch 'drm-next' of git://git.kernel.org/pub/scm/linux/kerne=
l/git/airlied/drm-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/usb-2.6
      anon_vma_prepare: properly lock even newly allocated entries
      Merge git://git.infradead.org/mtd-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Implement %pR to print struct resource content
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/lethal/sh-2.6
      Merge branch 'linux-next' of git://git.infradead.org/ubifs-2.6
      Merge branch 'for-next' of git://git.o-hand.com/linux-mfd
      Merge git://git.linux-nfs.org/projects/trondmy/nfs-2.6
      Merge branch 'for-next' of git://git.kernel.org/pub/scm/linux/kerne=
l/git/ericvh/v9fs
      Merge git://git.infradead.org/battery-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/drzeus/mmc
      Update .gitignore files for generated targets
      Remove empty imacfb.c file
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/mszeredi/fuse
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/wim/linux-2.6-w=
atchdog
      Merge branch 'next' of git://git.kernel.org/pub/scm/linux/kernel/gi=
t/djbw/async_tx
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/bart/ide-2.6
      Merge branch 'v28-timers-for-linus' of git://git.kernel.org/pub/scm=
/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'core-fixes-for-linus' of git://git.kernel.org/pub/scm=
/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'genirq-v28-for-linus' of git://git.kernel.org/pub/scm=
/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'tracing-v28-for-linus' of git://git.kernel.org/pub/sc=
m/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'linux-next' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/jbarnes/pci-2.6
      Merge branch 'bkl-removal' of git://git.lwn.net/linux-2.6
      Fix sprintf format warnings in drm_proc.c
      i915: cleanup coding horrors in i915_gem_gtt_pwrite()
      USB: Fix unused label warnings in drivers/usb/host/ehci-hcd.c
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/kyle/parisc-2.6
      i915: Fix format string warnings on x86-64.
      Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel=
/git/aegl/linux-2.6
      Merge branch 'for-linus' of master.kernel.org:/home/rmk/linux-2.6-a=
rm
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/jgarzik/libata-dev
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/roland/infiniband
      Merge branch 'for-next' of git://git.o-hand.com/linux-mfd
      Merge branch 'for-upstream' of git://git.kernel.org/pub/scm/linux/k=
ernel/git/dvrabel/uwb
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/benh/powerpc
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/czankel/xtensa-=
2.6
      Merge branch 'irq-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'sched-fixes-for-linus' of git://git.kernel.org/pub/sc=
m/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'core-fixes-for-linus' of git://git.kernel.org/pub/scm=
/linux/kernel/git/tip/linux-2.6-tip
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/agk/linux-2.6-d=
m
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/bart/ide-2.6
      Merge git://git.infradead.org/iommu-2.6
      Merge branch 'v28-timers-for-linus' of git://git.kernel.org/pub/scm=
/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/mchehab/linux-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/rusty/linux-2.6=
-for-linus
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/rric/oprofile
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging-=
2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/usb-2.6
      Merge branch 'i2c-for-linus' of git://jdelvare.pck.nerim.net/jdelva=
re-2.6
      Merge branch 'for-2.6.28' of git://linux-nfs.org/~bfields/linux
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/ericvh/v9fs
      Merge branch 'linux-next' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/jbarnes/pci-2.6
      Merge branch 'drm-next' of git://git.kernel.org/pub/scm/linux/kerne=
l/git/airlied/drm-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/lethal/sh-2.6
      Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel=
/git/lenb/linux-acpi-2.6
      Merge branch 'x86/um-header' of git://git.kernel.org/pub/scm/linux/=
kernel/git/tip/linux-2.6-tip
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/viro/vfs-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/viro/bdev
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/hskinnemoen/avr=
32-2.6
      compat_blkdev_driver_ioctl: Remove unused variable warning
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/sfrench/cifs-2.=
6
      Merge branch 'v28-range-hrtimers-for-linus-v2' of git://git.kernel.=
org/pub/scm/linux/kernel/git/tip/linux-2.6-tip
      ext3 quota support: fix compile failure
      pcc-acpi: fix compile with new stricter ACPI types
      Merge branch 'proc' of git://git.kernel.org/pub/scm/linux/kernel/gi=
t/adobriyan/proc
      Fix compile warning in kernel/params.c
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/jejb/scsi-misc-=
2.6
      Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel=
/git/lenb/linux-acpi-2.6
      Merge branch 'for-linus' of git://git.o-hand.com/linux-rpurdie-back=
light
      Merge branch 'for-linus' of master.kernel.org:/home/rmk/linux-2.6-a=
rm
      Merge branch 'for-linus' of git://git.o-hand.com/linux-rpurdie-leds
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/bart/ide-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jbarnes/pci-2.6
      Linux 2.6.28-rc1

Lior Dotan (7):
      Staging: SLICOSS: lots of checkpatch fixes
      Staging: SLICOSS: Fix warnings due to static usage
      Staging: SLICOSS: Fix remaining type names
      Staging: SLICOSS: Call pci_release_regions at driver exit
      Staging: Fixes for me4000 pci data collection driver
      Staging: PCC-ACPI: Fix all checkpatch errors
      Staging: SLICOSS: Free multicast list at driver exit

Lorenzo Nava (1):
      b43: fix QoS parameters initialization

Luca Santini (5):
      sh: Enable IRLM mode for SH7760 IRQ_MODE_IRQ.
      sh: Add Renesas EDOSK7760 board support.
      sh: edosk7760 physmap-flash support.
      sh: update edosk7760 defconfig for physmap-flash.
      sh: edosk7760: Correct size of bootloader flash partition.

Luck, Tony (1):
      kexec: fix crash_save_vmcoreinfo_init build problem

Luis Carlos Cobo (6):
      mac80211: allow no mac address until firmware load
      libertas_tf: header file
      libertas_tf: main.c, data paths and mac80211 handlers
      libertas_tf: command helper functions for libertas_tf
      libertas_tf: usb specific functions
      libertas_tf: config and makefile

Luis R. Rodriguez (9):
      cfg80211: keep track of supported interface modes
      cfg80211: Add new wireless regulatory infrastructure
      zd1211rw: make use of new regulatory_hint()
      ath9k: Add a few comments about mibevents
      ath9k: kill ath9k's memzero() and use memset() instead
      ath9k: fix oops on trying to hold the wrong spinlock
      ath9k: enable ANI to help with noisy environments
      ath9k: remove nasty FAIL macro from ath9k_hw_reset()
      ath9k: Fix return code when ath9k_hw_setpower() fails on reset

Luiz Fernando N. Capitulino (1):
      x86: remove 8254 timer texts from Documentation

Luotao Fu (4):
      MX31: add macros to configure spi pins
      mxc: add cscr register defintions
      MXC: add RTCK alternate function definitions
      i.MX3: Fix compiler warnings

Maciej W. Rozycki (3):
      x86: PIC, L-APIC and I/O APIC debug information
      x86: fix up a comment in ack_APIC_irq()
      ntp: let update_persistent_clock() sleep

Magnus Damm (32):
      smc91x: fix nowait printout
      smc91x: SMC_IO_SHIFT platform data support for default case
      smc911x: remove duplicate debug printout
      resource: add resource_type() and IORESOURCE_TYPE_BITS
      V4L/DVB (9235): Precalculate vivi yuv values
      V4L/DVB (9236): Teach vivi about multiple pixel formats
      V4L/DVB (9237): Add uyvy pixel format support to vivi
      V4L/DVB (9238): Add support for rgb565 pixel formats to vivi
      V4L/DVB (9239): Add support for rgb555 pixel formats to vivi
      V4L/DVB (9242): video: add sh_mobile_ceu comments
      V4L/DVB (9243): video: add byte swap to sh_mobile_ceu driver
      V4L/DVB (9244): video: improve sh_mobile_ceu buffer handling
      V4L/DVB (9245): video: add header to soc_camera_platform include fi=
le
      sh: GPIO and pinmux base code
      sh: Add sh7722 pinmux code
      sh: Use sh7722 GPIO on Migo-R board
      sh: Add sh7723 pinmux code
      sh: Use sh7723 GPIO on AP325RXA board
      sh: Add sh7203 pinmux code
      sh: Use sh7203 GPIO on rsk7203 board
      sh: Add sh7720 pinmux code
      sh: Use sh7720 GPIO on magicpanelr2 board
      sh: reduce Migo-R smc91x overruns
      sh: add dynamic crash base address support
      sh: remove consistent alloc cruft
      video: remove unused sh_mobile_lcdc platform data
      video: add sh_mobile_lcdc platform flags
      sh: update ov772x byte order on Migo-R
      sh: Update gpio_set_value() pin value handling
      sh: use 10MHz VIO_CLK for ov772x on Migo-R
      sh: improve pinmux support for single direction pins
      sh: sh7785 pinmux support

Magnus Deininger (1):
      9p: fix device file handling

Malcolm Turnbull (1):
      ipvs: load balance IPv4 connections from a local process

Manfred Spraul (3):
      kernel/cpu.c: Move the CPU_DYING notifiers
      kernel/cpu.c: create a CPU_STARTING cpu_chain notifier
      arch/x86/kernel/smpboot.c: Clarify when irq processing begins.

Manish Katiyar (5):
      ext4: Fix Kconfig typo for ext4dev
      libertas : Remove unused variable warning for "old_channel" from cm=
d.c
      net/802/fc.c: Fix compilation warnings
      ext4: Remove compile warnings when building w/o CONFIG_PROC_FS
      [MTD] [NAND] Fix compilation warnings in drivers/mtd/nand/cs553x_na=
nd.c

Manu Abraham (2):
      V4L/DVB (9195): Frontend API Fix: 32APSK is a valid modulation for =
the DVB-S2 delivery
      V4L/DVB (9196): Add support for DSS delivery

Marc Hulsman (4):
      hwmon: (w83791d) fan 4/5 pins can also be used for gpio
      hwmon: (w83791d) add manual PWM support
      hwmon: (w83791d) add pwm_enable support
      hwmon: (w83791d) add support for thermal cruise mode

Marc Pignat (1):
      rtc: DS1374 wakeup support

Marc Zyngier (9):
      [ARM] 5233/1: Allow PXA to have ISA IRQs numbered 0-15
      Export smc91x led definitions
      Basic support for the Arcom/Eurotech Viper SBC.
      Add support for the Arcom/Eurotech Viper SBC onboard ethernet.
      Add support for the Arcom/Eurotech Viper SBC CompactFlash card slot
      Add default configuration for Arcom/Eurotech Viper SBC
      ALSA: Fix pxa2xx-ac97-lib.c compilation
      [ARM] 5308/1: Fix Viper ISA IRQ handling
      USB: Let some USB host controllers get IRQ flags from resource

Marcelo Tosatti (24):
      KVM: x86: accessors for guest registers
      KVM: irq ack notification
      KVM: PIT: fix injection logic and count
      KVM: set debug registers after "schedulable" section
      KVM: fix i8259 reset irq acking
      KVM: x86: do not execute halted vcpus
      KVM: x86: unhalt vcpu0 on reset
      KVM: opencode gfn_to_page in kvm_vm_fault
      KVM: switch to get_user_pages_fast
      KVM: MMU: flush remote TLBs on large->normal entry overwrite
      KVM: MMU: split mmu_set_spte
      KVM: MMU: move local TLB flush to mmu_set_spte
      KVM: MMU: do not write-protect large mappings
      KVM: MMU: mode specific sync_page
      KVM: MMU: sync roots on mmu reload
      KVM: x86: trap invlpg
      KVM: MMU: mmu_parent_walk
      KVM: MMU: awareness of new kvm_mmu_zap_page behaviour
      KVM: MMU: mmu_convert_notrap helper
      KVM: MMU: out of sync shadow core
      KVM: MMU: speed up mmu_unsync_walk
      KVM: MMU: add "oos_shadow" parameter to disable oos
      KVM: PIC: enhance IPI avoidance
      KVM: VMX: enable invlpg exiting if EPT is disabled

Marcin Obara (1):
      tpm: correct tpm timeouts to jiffies conversion

Marcin Slusarz (11):
      x86, tsc: fix section mismatch warning
      x86: fix MP_processor_info section mismatch warning
      x86: mmconf: fix section mismatch warning
      x86: mpparse.c: fix section mismatch warning
      vgacon: optimize scrolling
      vgacon: vgacon_scrolldelta simplification
      x86: fix section mismatch warning - apic_flat
      x86: fix section mismatch warning - apic_physflat
      x86: fix section mismatch warning - apic_x2apic_uv_x
      x86: fix section mismatch warning - apic_x2apic_cluster
      x86: fix section mismatch warning - apic_x2apic_phys

Marco Stornelli (1):
      avr32: added mem kernel command line option support

Marek Skuczynski (1):
      sh: remove unnecessary memset after alloc_bootmem_low_pages

Marek Vasut (1):
      i2c/tps65010: Vibrator hookup to gpiolib

Marek Va=C5=A1ut (3):
      [ARM] 5199/1: PalmLD: PCMCIA driver
      [ARM] 5184/1: Split ucb1400_ts into core and touchscreen
      [ARM] 5248/1: wm97xx generic battery driver

Mariusz Kozlowski (7):
      [ARM] balance parenthesis in header file
      [ARM] remove extra brace in arch/arm/mach-pxa/trizeps4.c
      ALSA: misc typo fixes
      [ARM] pxa/spitz: fix unbalance parenthesis in header file spitz.h
      staging: fix potential build error in slicoss driver
      staging: balance parenthesis in wlan-ng headers
      ACPI: thinkpad-acpi: trivial fix of error message

Mark Brown (66):
      ALSA: Add jack reporting API
      ALSA: Build jack detection
      ALSA: ASoC: Allow codecs to override register display
      ALSA: ASoC: Make OpenFirmware helper include file conditional
      ALSA: ASoC: Export DAI and codec for TLV320AIC26
      ALSA: ASoC: Staticise keyclick dev_attr in tlv320aic26
      ALSA: ASoC: Add all CODECs Kconfig option
      ALSA: ASoC: Add WM8900 CODEC driver
      ALSA: ASoC: Add WM8580 CODEC driver
      [ARM] 5111/2: zylonite: Configure SSP
      [ARM] 5223/1: zylonite: Staticise zylonite_i2c_board_info
      ALSA: ASoC: Add WM8903 CODEC driver
      ALSA: ASoC: WM8903 I2C cleanups
      ALSA: ASoC: Convert DAPM pop time configuration to debugfs
      ALSA: ASoC: Make all codecs depend on rather than selecting I2C
      ALSA: ASoC: Don't suggest compile time selection of codec access
      ALSA: ASoC: Fix indentation in WM9713
      ALSA: ASoC: Sort Kconfig and Makefile entries for codecs
      ALSA: ASoC: Use codec digital mute when stopping playback
      [ARM] 5224/2: PXA SSP: Introduce register accessors
      sound: ASoC: Fix dependency on AC97_BUS
      sound: ASoC: DAPM support for ADC on WM9713 PCM interface
      sound: ASoC: Add WM8750 SPI support
      ALSA: ASoC: Correct inverted Mic PGA Switch control in wm8510 drive=
r
      ALSA: ASoC: Check for machine type in GTA01 machine driver
      ALSA: ASoC: Allow machine drivers to mark pins as not connected
      ALSA: ASoC: Use snd_soc_dapm_nc_pin() in GTA01 audio driver
      ALSA: ASoC: Use snd_soc_dapm_nc_pin() in Zaurus machine drivers
      ALSA: ASoC: Use snd_soc_dapm_nc_pin() in N810 machine driver
      ALSA: ASoC: Add WM8753 SPI support
      ALSA: ASoC: Add WM8510 SPI support
      ALSA: ASoC: Implement WM8510 bias level control
      ALSA: ASoC: Make WM8510 microphone input a DAPM mixer
      ALSA: ASoC: Make TLV320AIC26 user-visible
      ALSA: ASoC: Fix inverted input PGA mute bits in WM8903
      ALSA: ASoC: Fix build of GTA01 audio driver
      regulator: Fix typo
      regulator: check for init_data on registration
      regulator: Additional diagnostics for machine constraints
      regulator: Enable regulators marked as always_on
      mfd: Core support for the WM8400 AudioPlus HiFi CODEC and PMU
      regulator: Add WM8400 regulator support
      regulator: Export regulator name via sysfs
      mfd: Add WM8350 audio register definitions
      mfd: Add WM8350 GPIO register definitions
      mfd: Add WM8350 PMIC register definitions
      mfd: Add WM8350 PMU register definitions
      mfd: Add WM8350 comparator register definitions
      mfd: Add WM8350 RTC register definitions
      mfd: Add WM8350 watchdog register definitions
      mfd: Core support for the WM8350 AudioPlus PMIC
      mfd: Add I2C control support for WM8350
      mfd: Add GPIO pin configuration support for WM8350
      mfd: Add initialisation callback for WM8350
      mfd: Add WM8350 interrupt support
      regulator: Add WM8350 regulator support
      mfd: Add WM8350 subdevice registration helper
      mfd: Add placeholders for WM8350 client devices
      mfd: Fix warning in WM8350
      ALSA: ASoC: Hide TLV320AIC26 configuration option for non-OpenFirwm=
are users
      ALSA: Handle NULL jacks in snd_jack_report()
      ALSA: ASoC: Convert playpaq_wm8510 to bulk route registration API
      mfd: Don't use NO_IRQ in WM8350
      mailmap: add Mark Brown
      mfd: Don't store volatile bits in WM8350 register cache
      ALSA: Ensure PXA runtime data is initialised

Mark Fasheh (15):
      vfs: vfs-level fiemap interface
      ocfs2: fiemap support
      ocfs2: POSIX file locks support
      ocfs2: Track local alloc bits internally
      ocfs2: throttle back local alloc when low on disk space
      ocfs2: track local alloc state via debugfs
      ocfs2: fix printk format warnings
      ocfs2: Remove pointless !!
      ocfs2: make la_debug_mutex static
      ocfs2: Documentation update for user_xattr / nouser_xattr mount opt=
ions
      ocfs2: use smaller counters in ocfs2_remove_xattr_clusters_from_cac=
he
      ocfs2: Don't check for NULL before brelse()
      ocfs2: Uninline ocfs2_xattr_name_hash()
      ocfs2: Move trusted and user attribute support into xattr.c
      ocfs2: fix build error

Mark Jackson (2):
      avr32: Fix MIMC200 board use of SPD network pins
      avr32: Add MIMC200 board support

Mark Langsdorf (2):
      x86: L3 cache index disable for 2.6.26
      x86: L3 cache index disable for 2.6.26

Mark McLoughlin (2):
      hrtimer: remove hrtimer_clock_base::get_softirq_time()
      hrtimer: remove hrtimer_clock_base::reprogram()

Mark Nelson (2):
      powerpc: Add new CPU feature: CPU_FTR_CP_USE_DCBTZ
      powerpc: New copy_4K_page()

Mark de Wever (1):
      ide-tape: Buildfix when IDETAPE_DEBUG_LOG is set to 1.

Markus Metzger (1):
      x86, ptrace: PEBS support

Martin Dauskardt (1):
      V4L/DVB (9326): ivtv: avoid green flashing when loading ivtv

Martin Gebert (1):
      [netdrvr] au1000_eth: Spinlock initialisation fix

Martin Habets (1):
      sparc: Add checkstack support

Martin K. Petersen (10):
      block: Introduce integrity data ownership flag
      block: Fix double put in blk_integrity_unregister
      block: Switch blk_integrity_compare from bdev to gendisk
      block: gendisk integrity wrapper
      block: Find bio sector offset given idx and offset
      [SCSI] sd: Issue correct protection operation
      [SCSI] sd: Always print actual protection_type
      [SCSI] sd: Correctly handle all combinations of DIF and DIX
      [SCSI] sd: Switch kernel printing level for DIF messages
      dm: mark split bio as cloned

Martin Langer (2):
      powerpc: Fix major revision number for Freescale cores
      de2104x: wrong MAC address fix

Martin Michlmayr (1):
      ext4: Remove an old reference to ext4dev in Makefile comment

Martin Schwidefsky (5):
      [S390] bus_id ->dev_name() conversions in qdio
      [S390] ptrace changes
      [S390] xpram: per device block request queues.
      [S390] fix initialization of stp
      remove unused ibcs2/PER_SVR4 in SET_PERSONALITY

Martin Steigerwald (1):
      CFS scheduler: documentation about scheduling policies

Martyn Welch (5):
      powerpc: Board support for GE Fanuc SBC610
      powerpc: Default configuration for GE Fanuc SBC610
      powerpc: Correct USB support for GE Fanuc SBC610
      powerpc: GE Fanuc's FPGA based PIC controller on the SBC610
      powerpc: FPGA support for GE Fanuc SBC610

Masakazu Mokuno (1):
      ps3: Add ps3av_audio_mute_analog()

Mathieu Desnoyers (22):
      x86: alternatives : fix LOCK_PREFIX race with preemptible kernel an=
d CPU hotplug
      x86: revert replace LOCK_PREFIX in futex.h
      x86: spinlock use LOCK_PREFIX
      rcu: add rcu_read_lock_sched() / rcu_read_unlock_sched()
      tracing: Kernel Tracepoints
      tracing: tracepoints, documentation
      tracing: tracepoints, samples
      tracing, sched: LTTng instrumentation - scheduler
      ftrace: port to tracepoints
      tracepoints: use TABLE_SIZE macro
      tracepoints: use rcu sched
      tracepoints: fix reentrancy
      markers: marker_synchronize_unregister()
      markers: fix unregister bug and reenter bug, cleanup
      markers: probe example, fix teardown
      markers: documentation fix for teardown
      sputrace: use marker_synchronize_unregister()
      markers: re-enable fast batch registration
      markers: turn marker_synchronize_unregister() into an inline
      markers: fix synchronize marker unregister static inline
      tracepoints: tracepoint_synchronize_unregister()
      tracepoints: synchronize unregister static inline

Mats Erik Andersson (1):
      8139too: [cosmetic] fix incorrect register for flash-rom

Matt Helsley (8):
      container freezer: add TIF_FREEZE flag to all architectures
      container freezer: make refrigerator always available
      container freezer: implement freezer cgroup subsystem
      container freezer: skip frozen cgroups during power management resu=
me
      container freezer: prevent frozen tasks or cgroups from changing
      container freezer: make freezer state names less generic
      container freezer: rename check_if_frozen()
      container freezer: document the cgroup freezer subsystem.

Matt Mackall (2):
      x86: remove magic number from ACPI sleep stack buffer
      x86: trim ACPI sleep stack buffer

Matthew Fleming (2):
      MMC: CSD and CID timeout values
      MMC: Use timeout values from CSR

Matthew Garrett (6):
      power_supply: Add function to return system-wide power state
      Input: atkbd - expand Latitude's force release quirk to other Dells
      ACPI: WMI: Enable event methods when registering notifiers
      eeepc-laptop: Use standard interfaces
      ACPI: Clear WAK_STS on resume
      Add Intel ACPI IGD OpRegion support

Matthew Ranostay (25):
      ALSA: hda: digital pc-beep support hd-audio codecs
      ALSA: hda: added 92HD81/83 support
      ALSA: hda: dynamically create capture mux controls
      ALSA: hda: 92HD75xx fixes
      ALSA: hda: SPDIF mux controls
      ALSA: hda: removed unneeded hp_nid references
      ALSA: hda: slave digital out support
      ALSA: hda: digital slave support for IDT codecs
      ALSA: hda: SPDIF mux name change
      ALSA: hda - add missing slave_dig_outs for 92HD73bxx
      ALSA: hda: Added a STAC_HP_M4 quirk
      ALSA: hda: Input port AMP controls
      ALSA: hda: fixed hp_nid DAC for DELL_M6
      ALSA: hda: 92hd73xx fixes
      ALSA: hda: SPDIF mux fixes for STAC927x
      ALSA: hda: use last DAC defined for hp_pin
      ALSA: hda: slave_dig_outs code block in wrong location
      ALSA: hda: 92xx S/PDIF In support
      ALSA: hda: HP laptop quirk
      ALSA: hda: SPDIF stream muting support
      ALSA: hda: STAC_HP_M4
      ALSA: hda: VREF powerdown for headphones
      ALSA: hda: add mixers for analog mixer on 92hd75xx codecs
      ALSA: hda: corrected invalid mixer values
      ALSA: hda: fix nid variable warning

Matthew Wilcox (4):
      [netdrvr] atl1e: Don't take the mdio_lock in atl1e_probe
      [SCSI] qla2xxx: Remove semaphore.h
      ACPI: Change acpi_evaluate_integer to support 64-bit on 32-bit kern=
els
      PCI: Fix reference counting bug

Matthias Fuchs (2):
      powerpc/44x: Add hwmon support to Sequoia device tree
      powerpc/4xx: Allow 4xx PCI bridge to be disabled via device tree

Matthias Hopf (1):
      drm/i915: fix ioremap of a user address for non-root (CVE-2008-3831=
)

Mattias Nissler (2):
      rt2x00: Only configure hardware when radio is enabled
      rt2x00: skb->data pointer should not include TX descriptor

Mauro Carvalho Chehab (22):
      ALSA: hda: Add support for ECS/PC Chips boards with Sigmatel codecs
      V4L/DVB (8553): media/video/Kconfig: get rid of a select
      V4L/DVB (8554): media/video/Kconfig: cosmetic changes and convert s=
elect into depends on
      V4L/DVB (8625): saa7134: Add NEC prococol IR decoding capability
      V4L/DVB (8626): Add support for TCL tuner MF02GIP-5N-E
      V4L/DVB (8627): Fix mute on bttv driver
      V4L/DVB (8628a): Remove duplicated include
      V4L/DVB (8628): bttv: Add support for Encore ENLTV2-FM
      V4L/DVB (8730): drx397xD: fix compilation error caused by changeset=
 71046dfb0853
      V4L/DVB (9055): tuner-xc2028: Do a better job selecting firmware ty=
pe
      V4L/DVB (9059): saa7134: Add support for Encore version 5.3 board
      V4L/DVB (9060): saa7134: Add support for Avermedia PCI pure analog =
(M135A)
      V4L/DVB (9061): saa7134: Add support for Real Audio 220
      V4L/DVB (9062): Add support for Prolink Pixelview Global Extreme
      V4L/DVB (9098): Whitespace cleanups
      HID: fix numlock led on Dell device 0x413c/0x2105
      HID: Don't let Avermedia Radio FM800 be handled by usb hid drivers
      HID: add support for Bright ABNT2 brazilian device
      V4L/DVB (9276): videobuf-dvb: two functions are now static
      V4L/DVB (9330): Get rid of inode parameter at v4l_compat_translate_=
ioctl()
      V4L/DVB (9331): Remove unused inode parameter from video_ioctl2
      V4L/DVB (9333): cx88: Not all boards that requires cx88-mpeg has fr=
ontends

Maximilian Rehkopf (1):
      ALSA: ice1724: enable MIDI on Terratec Aureon 7.1 Universe

Miao Xie (1):
      sched: fix the wrong mask_len

Michael Brooks (1):
      IB/mad: Don't discard BMA responses in kernel

Michael Buesch (14):
      b43: Implement dynamic PHY API
      b43: Rewrite TX power adjustment
      b43: Don't use memcpy for overlapping areas
      b43: Move remaining code from phy.c to phy_a.c
      b43: Move code from nphy.* to phy_n.*
      b43: Add LP-PHY template
      b43: Add LP-PHY read/write phyops
      b43: Add LP-PHY radio register definitions
      b43: Split PHY alloc and init
      b43: Move Analog switching into phy code
      b43: Replace hardcoded Analog switch
      b43: Fix QoS defaults
      b43 G-PHY: Remove mmiowb()
      b43: Remove QoS update workqueue

Michael Chan (5):
      bnx2: Add bnx2_shutdown_chip().
      bnx2: Check netif_running() in all ethtool operations.
      bnx2: Update 5706/5708 firmware.
      bnx2: Eliminate TSO header modifications.
      bnx2: Update version to 1.8.1.

Michael Ellerman (6):
      powerpc: Streamline ret_from_except_lite for non-iSeries platforms
      powerpc: fsl_msi doesn't need it's own of_node
      powerpc: Split-out common MSI bitmap logic into msi_bitmap.c
      powerpc: Convert the FSL MSI code to use msi_bitmap
      powerpc: Convert the MPIC MSI code to use msi_bitmap
      ftrace: make output nicely spaced for up to 999 cpus

Michael Halcrow (1):
      eCryptfs: remove retry loop in ecryptfs_readdir()

Michael Hennerich (9):
      Input: bf54x-keys - add power management support
      Blackfin arch: Add new board support for ADZS-BF526-EZ-BRD
      Blackfin arch: add BF54x / BF52x Rotary Input device driver platfor=
m resource to board file
      Blackfin arch: Fix BUG: anomaly_threshold is used with ANOMALY_0500=
0363
      Blackfin arch: Fix BUG -- BF533 + 0.5 silicon + MPU + UART PIO -> c=
rash
      Blackfin arch: Enable framebuffer support for the BF526-EZkit TFT L=
CD display
      Blackfin arch: AD7879 Touchscreen driver
      Blackfin arch: Fix bogus str_ident check in gpio code
      Blackfin arch: update AD7879 platform resources in board file

Michael Kerrisk (1):
      ALSA: Documentation/sound/alsa/ALSA-Configuration.txt: fix typo

Michael Krufky (14):
      V4L/DVB (8655): cxusb: fix checkpatch warnings & errors
      V4L/DVB (8656): fix DVB_FE_CUSTOMISE for DVB_DIB7000P and DVB_TUNER=
_DIB0070 with dvb-usb-cxusb
      V4L/DVB (8658): lgs8gl5: fix build warnings
      V4L/DVB (8948): xc5000: kill xc5000_priv.h
      V4L/DVB (8949): xc5000: allow multiple driver instances for the sam=
e hardware to share state
      V4L/DVB (8950): xc5000: prevent an OOPS if analog driver is unloade=
d while digital is in use
      V4L/DVB (8951): xc5000: dont pass devptr in xc5000_attach()
      V4L/DVB (8968): replace xc3028 firmware filenames with defined defa=
ult firmware names
      V4L/DVB (9048): add a general-purpose callback pointer to struct dv=
b_frontend
      V4L/DVB (9049): convert tuner drivers to use dvb_frontend->callback
      V4L/DVB (9051): dib0700: use dvb_frontend->callback for xc5000 gpio=
 reset
      V4L/DVB (9149): hvr950q: led feedback based on snr
      V4L/DVB (9247): au0828: add support for another USB id for Hauppaug=
e HVR950Q
      V4L/DVB (9248): sms1xxx: support two new revisions of the Hauppauge=
 WinTV MiniStick

Michael Neuling (1):
      powerpc: Remove empty #else from signal_64.c

Michal Januszewski (4):
      x86: replace a magic number with a named constant in the VESA boot =
code
      uvesafb: don't treat mode info retrieval failures as errors
      MAINTAINERS: add entry for uvesafb
      fbdev: ignore VESA modes if framebuffer does not support them

Mikael Pettersson (1):
      [ARM] 5218/1: arm: improved futex support

Mike Anderson (2):
      block: Add interface to abort queued requests
      dm: Call blk_abort_queue on failed paths

Mike Christie (22):
      [SCSI] libiscsi: return error passed in during iscsi recovery
      [SCSI] Add helper code so transport classes/driver can control queu=
eing (v3)
      [SCSI] qla4xxx: return SCSI_MLQUEUE_TARGET_BUSY when driver has det=
ected session error
      [SCSI] qla2xxx: return SCSI_MLQUEUE_TARGET_BUSY when driver has det=
ected rport error or race
      [SCSI] libiscsi: Use SCSI_MLQUEUE_TARGET_BUSY
      [SCSI] lpfc: use SCSI_MLQUEUE_TARGET_BUSY when catching the rport t=
ransition race
      [SCSI] fc class: unblock target after calling terminate callback (t=
ake 2)
      [SCSI] ibmvfc, qla2xxx, lpfc: remove scsi_target_unblock calls in t=
erminate callbacks
      [SCSI] scsi: add transport host byte errors (v3)
      [SCSI] iscsi class, libiscsi and qla4xxx: convert to new transport =
host byte values
      [SCSI] fc class: Add support for new transport errors
      [SCSI] qla2xxx: use new host byte transport errors.
      [SCSI] block: separate failfast into multiple bits.
      [SCSI] modify scsi to handle new fail fast flags.
      [SCSI] scsi_dh_alua: remove REQ_NOMERGE
      [SCSI] libiscsi: fix data corruption when target has to resend data=
-in packets
      [SCSI] libiscsi: Support drivers initiating session removal
      [SCSI] iscsi class: fix endpoint id handling
      [SCSI] libiscsi: rename host reset to target reset
      [SCSI] iscsi_tcp: return a descriptive error value during connectio=
n errors
      libiscsi: check reason why we are stopping iscsi session to determi=
ne error value
      libiscsi: fix locking in iscsi_eh_device_reset

Mike Crowe (1):
      hfsplus: quieten down mounting hfsplus journaled fs read only

Mike Dahlgren (1):
      asus_acpi: whitespace and comment cleanup

Mike Ditto (2):
      powerpc: Fix boot wrapper memcmp() called with zero length argument
      powerpc: Add del_node() for early boot code to prune inapplicable d=
evices.

Mike Frysinger (35):
      [MTD] [MAPS] Maps: make uclinux mapping driver depend on MTD_RAM
      Blackfin arch: add note about newer ezkits using PB4 for AD7877 ins=
tead of PJ11
      Blackfin arch: only include asm/cplb.h when it is truly used
      Blackfin arch: fix bug - sometimes there is no response to the hitt=
ing key in uboot for bf561-ezkit when running with 50mhz SCLK
      Blackfin arch: mark local gpio_error() as static
      Blackfin arch: fix merge errors during 2.6.26 upgrade
      Blackfin arch: BF561 is supported, no longer a work in progress
      Blackfin arch: fix default silicon rev selection so it works for al=
l supported parts
      Blackfin arch: add support for BF52x-0.2, BF533-0.6, and BF54x-0.2
      Blackfin arch: fix bug -- PTRACE_PEEKDATA does not seem to work whi=
ch breaks umoven() in strace
      Blackfin arch: ptrace - cleanup debug messages and style
      Blackfin arch: use existing ptrace_disable() func to clear TRACE_BI=
TS and create the opposite ptrace_enable()
      Blackfin arch: ptrace - make sure PT_ORIG_R0 and PT_ORIG_P0 offsets=
 are declared
      Blackfin arch: give sys_strace proper entry markings
      Blackfin arch: avoid using actual config name in comment
      Blackfin arch: fix end address for parallel flash and increase kern=
el partition size to 4meg
      Blackfin arch: Move all the silicon rev handling to one place
      Blackfin arch: ptrace - fix off-by-one check on end of memory regio=
ns
      Blackfin arch: have is_user_addr_valid() check for overflows (like =
when address is -1)
      Blackfin arch: emulate a TTY over the EMUDAT/JTAG interface
      Blackfin arch: update board defconfigs
      Blackfin arch: remove non-bf54x ifdef logic since this file is only=
 compiled on bf54x parts
      Blackfin arch: bfin_reset() is an internal reboot function ... ever=
yone should go through machine_restart()
      Blackfin arch: update anomaly headers to match the latest sheet
      Blackfin arch: use the Blackfin on-chip ROM to do software reset wh=
en possible
      Blackfin arch: make sure L2 start and length are always defined (fi=
xes building on BF542)
      Blackfin Serial Driver: use __initdata for data, not __init
      Blackfin Serial Driver: trim trailing whitespace -- no functional c=
hanges
      Blackfin Serial Driver: move common variables out of serial headers=
 and into the serial driver
      Blackfin arch: unify/cleanup cache code
      Blackfin arch: use the new bfin_addr_dcachable() function
      Blackfin arch: move bfin_addr_dcachable() and friends into the cach=
eflush header where it belongs
      Blackfin arch: update cache flush prototypes with argument names to=
 make them less mysterious
      Blackfin arch: disable CONFIG_HW_RANDOM and CONFIG_DAB in defconfig=
 files
      Blackfin arch: make sure cycles is marked as volatile so gcc doesnt=
 reorder on us

Mike Galbraith (1):
      sched: minor fast-path overhead reduction

Mike Isely (10):
      V4L/DVB (8893): pvrusb2: Add comment elaborating on direct use of s=
wab32()
      V4L/DVB (8894): pvrusb2: Remove BKL
      V4L/DVB (8895): pvrusb2: Fail gracefully if an alien USB ID is used
      V4L/DVB (8897): pvrusb2: Mark crop window size change as being disr=
uptive to the encoder
      V4L/DVB (8898): pvrusb2: Be able to programmatically retrieve a con=
trol's default value
      V4L/DVB (8899): pvrusb2: Implement default value retrieval in sysfs=
 interface
      V4L/DVB (8900): pvrusb2: Implement cropping pass through
      V4L/DVB (8901): pvrusb2: Disable virtual IR device when not needed.
      V4L/DVB (8902): pvrusb2: Remove comment lines which refer to checkp=
atch's behavior
      V4L/DVB (9300): pvrusb2: Fix deadlock problem

Mike Pagano (1):
      uvesafb: document mode to mode_option parameter change

Mike Rapoport (16):
      [ARM] 5215/2: Add support for CM-X300 board
      [ARM] 5216/1: Add CM-X300 defconfig
      [ARM] 5217/1: update maintainer entry for CompuLab machines
      [ARM] 5201/1: PXA3xx: Add support for power i2c bus
      [ARM] 5286/2: pxa: rename cm-x270* to cm-x2xx* to allow addition of=
 cm-x255 support
      [ARM] 5280/1: pxa: prepare cm-x2xx.c and cm-x2xx-pci.[ch] for addit=
ion of CM-X255
      [ARM] 5281/1: pxa: split cm-x2xx.c to cm-x2xx.c and cm-x270.c
      [ARM] 5282/1: pxa: add CM-X255 support
      [ARM] 5283/1: pxa: add CM-X255 pcmcia support
      [ARM] 5284/1: pxa: cm-x255: add NOR and NAND flash support
      [ARM] 5285/1: pxa: update xm_x2xx_defconfig
      [ARM] 5306/1: pxa: fix build error on CM-X270
      [ARM] 5307/1: pxa: fix CM-X2XX PCMCIA build error
      [MTD] [NAND] GPIO NAND flash driver
      leds: da903x: Add support for LEDs found on DA9030/DA9034
      backlight: da903x: Add backlight driver for DA9030/DA9034

Mike Travis (1):
      PCI: make CPU list affinity visible

Mikhail Gusarov (1):
      USB: add ZTE MF626 USB GSM modem entry

Mikko Ohtamaa (1):
      V4L/DVB (8974): af9015: Add USB ID for Telestar Starstick 2

Miklos Szeredi (3):
      fuse: fix SEEK_END incorrectness
      move executable checking into ->permission()
      [patch] vfs: make security_inode_setattr() calling consistent

Mikulas Patocka (13):
      block: drop virtual merging accounting
      drop vmerge accounting
      dm exception store: introduce area_location function
      dm exception store: use chunk_t for_areas
      dm: export struct dm_dev
      dm: publish dm_get_mapinfo
      dm: publish dm_table_unplug_all
      dm: publish dm_vcalloc
      dm snapshot: fix primary_pe race
      dm snapshot: drop unused last_percent
      dm exception store: fix misordered writes
      dm: publish array_too_big
      dm: remove dm header from targets

Milan Broz (10):
      dm crypt: tidy inc pending
      dm crypt: tidy crypt alloc
      dm crypt: tidy write loop pending
      dm crypt: move dec_pending on error into write_io_submit
      dm crypt: fix async inc_pending
      dm crypt: tidy ctx pending
      dm crypt: avoid unnecessary wait when splitting bio
      dm crypt: tidy sector
      dm crypt: fix async split
      dm crypt: remove waitqueue

Miloslav Trmac (1):
      audit: Handle embedded NUL in TTY input auditing

Milton Miller (19):
      powerpc/xics: EOI unmapped irqs after disabling them
      powerpc/xics: Update default_server during migrate_irqs_away
      powerpc/xics: Consolidate ipi message encode and decode
      powerpc/xics: Rearrange file to group code by function
      powerpc/xics: Change *_xirr_info_set() prototype to avoid casts
      powerpc/xics: Trim #include list
      powerpc/xics: Initialization code cleanups
      powerpc/xics: Factor out cpu joining/unjoining the GIQ
      powerpc/xics: EOI xics ipi by hand in kexec
      powerpc/xics: Mark xics IPI interrupt as per-cpu
      powerpc/xics: Make printk format strings fit on one line
      powerpc/xics: Reduce and comment xics IPI use of memory barriers
      powerpc/smp: No need to set_need_resched when getting a resched IPI
      powerpc: remove non-dependent load fsl_booke PTE_64BIT
      PCI: remove dynids.use_driver_data
      powerpc: Find and destroy possible stale kernel added properties
      powerpc: Use cpu_thread_in_core in smp_init for of_spin_map
      powerpc: Always trim numa memory to lmb_end_of_DRAM()
      powerpc: Delete unused prom_strtoul and prom_memparse

Mimi Zohar (2):
      integrity: special fs magic
      i_version: remount support

Ming Lei (4):
      hci_usb: replace mb with smp_mb
      V4L/DVB:usbvideo:don't use part of buffer for USB transfer #4
      USB: ehci-dbg: increase debug buffer size for periodic file
      USB: ehci-dbg: fix reading less content of periodic file

Mingming Cao (3):
      percpu counter: clean up percpu_counter_sum_and_set()
      ext2: fix ext2 block reservation early ENOSPC issue
      ext3: fix ext3 block reservation early ENOSPC issue

Misha Zhilin (1):
      ALSA: ice1724 - Support for Terrasoniq/MUSONIK TS22 PCI card

Mohammed Gamal (9):
      KVM: VMX: Remove redundant check in handle_rmode_exception
      KVM: VMX: Add Guest State Validity Checks
      KVM: VMX: Add module parameter and emulation flag.
      KVM: VMX: Add invalid guest state handler
      KVM: VMX: Modify mode switching and vmentry functions
      KVM: x86 emulator: Add mov r, imm instructions (opcodes 0xb0-0xbf)
      KVM: x86 emulator: Add std and cld instructions (opcodes 0xfc-0xfd)
      KVM: x86 emulator: Add in/out instructions (opcodes 0xe4-0xe7, 0xec=
-0xef)
      KVM: x86 emulator: Add call near absolute instruction (opcode 0xff/=
2)

Mohan Kumar M (1):
      powerpc: Support for relocatable kdump kernel

M=C3=A1rton N=C3=A9meth (1):
      ide-cd: add TEAC CD-224E to the NO_AUTOCLOSE list

Naohiro Ooiwa (1):
      sysrq: add enable_mask in sysrq_moom_op

Nate Case (2):
      hwmon: (lm90) Convert some macros to static functions
      hwmon: (lm90) Support ADT7461 in extended mode

Nathan Fontenot (4):
      powerpc: Check rc of notifier chain for memory remove
      powerpc: Oops in pseries_lmb_remove()
      memory hotplug: release memory regions in PAGES_PER_SECTION chunks
      powerpc/pseries: Validate PFN in pseries_remove_lmb()

Nathan Lynch (1):
      powerpc: Remove redundant sysfs_remove_file calls for cache info

Neil Brown (2):
      sysfs: Support sysfs_notify from atomic context with new sysfs_noti=
fy_dirent
      Make nfs_file_cred more robust.

Neil Horman (4):
      crypto: api - Add fips_enable flag
      crypto: rng - RNG interface and implementation
      sctp: reduce memory footprint of sctp_chunk structure
      x86, kexec: fix hang on i386 when panic occurs while console_sem is=
 held

NeilBrown (5):
      md: Allow metadata_version to be updated for externally managed met=
adata.
      md: Don't try to set an array to 'read-auto' if it is already in th=
at state.
      md: Remove unnecessary #includes, #defines, and function declaratio=
ns.
      md: remove space after function name in declaration and call.
      md: Relax minimum size restrictions on chunk_size.

Nelson Castillo (1):
      [ARM] S3C24XX: Fix redefine of DEFINE_TIMER() in s3c24xx pwm-clock.=
c

Nick Kossifidis (7):
      ath5k: HW code cleanup
      ath5k: Fix bad udelay calls on AR5210 code
      ath5k: Update registers and SREV ids v2
      ath5k: Use new srevs to properly attach radio chips
      ath5k: Use QUIET mechanism on tx dma stop
      ath5k: Fix SREV reporting after SREV updates
      ath5k: Add support for AR2417 v2

Nick Piggin (13):
      x86, pat: avoid highmem cache attribute aliasing
      cifs: Convert cifs to new aops.
      sysfs: fix deadlock
      afs: convert to new aops
      vmscan: move isolate_lru_page() to vmscan.c
      mlock: mlocked pages are unevictable
      vmstat: mlocked pages statistics
      mm: pagecache insertion fewer atomics
      mm: unlockless reclaim
      mm: page lock use lock bitops
      fs: buffer lock use lock bitops
      mm: rewrite vmap layer
      mutex: speed up generic mutex implementations

Nick Warne (1):
      [SCSI] tmscsim: Fixup KERN_INFO in printk

Nicolas Pitre (11):
      [ARM] 5206/1: remove kprobe_trap_handler() hack
      [ARM] 5211/2: fix a couple warnings from BUG() usage
      [ARM] 5221/1: fix ldm/stm emulation for kprobes
      [ARM] 5271/1: get rid of pages_to_mb()
      [ARM] 5272/1: remove conditional compilation in show_pte()
      [ARM] Feroceon: small cleanups to L2 cache code
      [ARM] 5274/1: simplify request_standard_resources()
      [ARM] 5295/1: make ZONE_DMA optional
      [ARM] Orion: activate workaround for 88f6183 SPI clock erratum
      [ARM] 5320/1: fix assembly constraints in implementation of do_div(=
)
      [ARM] 5321/1: Kirkwood: fix typo in Makefile

Niels de Vos (1):
      Input: serio_raw - allow attaching to translated (SERIO_I8042XL) po=
rts

Nigel Hislop (1):
      [S390] Add ioctl support for EMC Symmetrix Subsystem Control I/O

Niklaus Giger (1):
      powerpc/40x: Add support for Netstal HCU4 board

Nikolaus Voss (1):
      Add kernel support for oprofile callgraphs on AVR32

Nishant Kamat (2):
      ARM: OMAP3: Add basic board support for OMAP LDP
      ARM: OMAP3: Add default kernel config for OMAP LDP

Nobuhiro Iwamatsu (3):
      sh: ap325rxa: create CPLD data area in mtd
      sh: ap325rxa: Add support RTC RX-8564LC in AP325RXA board
      serial: sh-sci: Add support SCIF of SH7723

Nye Liu (1):
      initramfs: add option to preserve mtime from initramfs cpio images

OGAWA Hirofumi (7):
      Use WRITE_BARRIER in blkdev_issue_flush(), not (1<<BIO_RW_BARRIER)
      vfs: replace parent =3D=3D dentry->d_parent by IS_ROOT()
      vfs: add d_ancestor()
      vfs: add __d_instantiate() helper
      vfs: remove unnecessary fsnotify_d_instantiate()
      vfs: remove LOOKUP_PARENT from non LOOKUP_PARENT lookup
      vfs: add LOOKUP_RENAME_TARGET intent

Oleg Nesterov (19):
      migrate_timers: add comment, use spinlock_irq()
      sched: do_wait_for_common: use signal_pending_state()
      wait_task_inactive(): don't consider task->nivcsw
      wait_task_inactive: "improve" the returned value for ->nvcsw =3D=3D=
 0
      posix-timers: don't switch to ->group_leader if ->it_process dies
      posix-timers: always do get_task_struct(timer->it_process)
      posix-timers: sys_timer_create: remove the buggy PF_EXITING check
      posix-timers: sys_timer_create: simplify and s/tasklist/rcu/
      posix-timers: move the initialization of timer->sigq from send to c=
reate path
      posix-timers: sys_timer_create: cleanup the error handling
      posix-timers: kill ->it_sigev_signo and ->it_sigev_value
      posix-timers: lock_timer: kill the bogus ->it_id check
      posix-timers: lock_timer: make it readable
      do_generic_file_read: s/EINTR/EIO/ if lock_page_killable() fails
      fbcon_set_all_vcs: fix kernel crash when switching the rotated cons=
oles
      pid_ns: de_thread: kill the now unneeded ->child_reaper change
      pid_ns: kill the now unused task_child_reaper()
      coredump: format_corename: don't append .%pid if multi-threaded
      kthread_bind: use wait_task_inactive(TASK_UNINTERRUPTIBLE)

Oleg Roitburd (3):
      V4L/DVB (9019): Added support for Omicom SS4 DVB-S/S2 card
      V4L/DVB (9020): Added support for TBS 8920 DVB-S/S2 card
      V4L/DVB (9186): Added support for Prof 7300 DVB-S/S2 cards

Oliver Endriss (3):
      V4L/DVB (8888): budget: Support Activy DVB-T with TDHD1 tuner
      V4L/DVB (8889): dvb-ttpci: Support full-ts hardware modification
      V4L/DVB (8890): budget: Add callback to load firmware for the TDHD1=
 tuner

Oliver Hartkopp (2):
      can: Add documentation for virtual CAN driver usage
      net: remove ifalias on empty given alias

Oliver Neukum (7):
      USB: kill URBs permanently
      USB: extend poisoning to anchors
      USB: Documentation/usb/anchors.txt #2
      USB: RESET_RESUME needs to block autosuspend when remote wakeup is =
needed
      USB: anchor API changes needed for btusb
      USB: cdc-wdm: make module autoload work
      USB: fix memory leak in cdc-acm

Oliver Schuster (1):
      [WATCHDOG] add watchdog driver IT8716 IT8726 IT8712J/K

Or Gerlitz (2):
      IPoIB: Clean up ethtool support
      IPoIB: Set netdev offload features properly for child (VLAN) interf=
aces

PJ Waskiewicz (1):
      ixgbe: use different context for tso and offload

Pablo Neira Ayuso (2):
      netfilter: ctnetlink: remove bogus module dependency between ctnetl=
ink and nf_nat
      netfilter: fix compilation error with NAT=3Dn

Paolo Ciarrocchi (8):
      x86: coding style fixes to arch/x86/boot/compressed/misc.c
      x86: coding style fixes to arch/x86/kernel/bios_uv.c
      x86: coding style fixes to arch/x86/lib/strstr_32.c
      x86: coding style fixes to arch/x86/lib/string_32.c
      x86: coding style fixes to arch/x86/kernel/paravirt_patch_32.c
      x86: Coding style fixes to arch/x86/oprofile/op_model_p4.c
      [CPUFREQ] Coding style fixes to arch/x86/kernel/cpu/cpufreq/elanfre=
q.c
      [CPUFREQ] Coding style fixes to arch/x86/kernel/cpu/cpufreq/powerno=
w-k6.c

Parag Warudkar (1):
      x86: sysfs: kill owner field from attribute

Pascal Terjan (2):
      ALSA: hda - Fix sound on NEC Versa S9100
      ACPI: thinkpad-acpi: Remove duplicate line

Patrick Boettcher (1):
      V4L/DVB (8866): Add dummy FE to the Kconfig-file and fix it

Patrick Glass (1):
      MIPS: PMC MSP71XX gpio drivers

Patrick McHardy (7):
      gre: fix copy and paste error
      gre: minor cleanups in netlink interface
      e1000: allow VLAN devices to use TSO and CSUM offload
      netfilter: restore lost #ifdef guarding defrag exception
      netfilter: fix ebtables dependencies
      netfilter: ctnetlink: remove obsolete NAT dependency from Kconfig
      netfilter: netns: use NFPROTO_NUMPROTO instead of NUMPROTO for tabl=
es array

Paul Bolle (3):
      x86 setup: drop SWAP_DEV
      x86 setup: remove DEF_INITSEG and DEF_SETUPSEG
      x86 setup: remove IMAGE_OFFSET

Paul E. McKenney (10):
      rcu, debug: detect stalled grace periods
      rcu: prevent console flood when one CPU sees another AWOL via RCU
      rcu: classic RCU locking and memory-barrier cleanups
      rcu: fixes to include/linux/rcupreempt.h
      rcu: remove list_for_each_rcu()
      rcu: fix classic RCU locking cleanup lockdep problem
      rcu: remove redundant ACCESS_ONCE definition from rcupreempt.c
      rcu: fix locking cleanup fallout
      rcu: use irq-safe locks
      rcu: RCU-based detection of stalled CPUs for Classic RCU

Paul Gortmaker (1):
      powerpc/sbc8560: fix compile warning on CPM pin array

Paul Mackerras (9):
      Merge branch 'linux-2.6'
      powerpc: Rearrange head_64.S to move interrupt handler code to the =
beginning
      powerpc: Make it possible to move the interrupt handlers away from =
the kernel
      powerpc: Use LOAD_REG_IMMEDIATE only for constants on 64-bit
      powerpc: Make the 64-bit kernel as a position-independent executabl=
e
      Merge branch 'next' of ssh://master.kernel.org/pub/scm/linux/kernel=
/git/jwboyer/powerpc-4xx
      Merge branch 'powerpc-next' of master.kernel.org:/pub/scm/linux/ker=
nel/git/galak/powerpc
      powerpc: Sync RPA note in zImage with kernel's RPA note
      powerpc: Revert CHRP boot wrapper to real-base =3D 12MB on 32-bit

Paul Menage (2):
      cgroups: convert tasks file to use a seq_file with shared pid array
      cgroups: fix declaration of cgroup_mm_owner_callbacks

Paul Moore (18):
      selinux: Fix an uninitialized variable BUG/panic in selinux_secattr=
_to_sid()
      netlabel: Fix some sparse warnings
      selinux: Cleanup the NetLabel glue code
      selinux: Correctly handle IPv4 packets on IPv6 sockets in all cases
      netlabel: Remove unneeded in-kernel API functions
      selinux: Better local/forward check in selinux_ip_postroute()
      selinux: Fix a problem in security_netlbl_sid_to_secattr()
      selinux: Fix missing calls to netlbl_skbuff_err()
      smack: Fix missing calls to netlbl_skbuff_err()
      netlabel: Replace protocol/NetLabel linking with refrerence counts
      netlabel: Add a generic way to create ordered linked lists of netwo=
rk addrs
      netlabel: Add network address selectors to the NetLabel/LSM domain =
mapping
      netlabel: Add functionality to set the security attributes of a pac=
ket
      selinux: Set socket NetLabel based on connection endpoint
      selinux: Cache NetLabel secattrs in the socket's security struct
      netlabel: Changes to the NetLabel security attributes to allow LSMs=
 to pass full contexts
      cipso: Add support for native local labeling and fixup mapping name=
s
      netlabel: Add configuration support for local labeling

Paul Mundt (103):
      sh: Provide movli.l/movco.l-based bitops.
      sh: Provide movli.l/movco.l-based cmpxchg.
      sh: Kill off unused defines from asm/smp.h.
      sh: smp: Provide a generic IPI handler.
      sh: smp: Hook in to the generic IPI handler for SH-X3 SMP.
      sh: smp: Hook up a timer IPI stub.
      sh: generic clockevent broadcast support.
      sh: smp: shove a cpu_relax() in the plat_start_cpu() busy loop.
      sh: Early dummy clockevent registration on boot CPU.
      sh: Display CPU information in show_regs().
      sh: fixup many sparse errors.
      sh: Don't enable clockevents broadcasting on UP SH-X3 builds.
      sh: Add support for memory hot-remove.
      sh: Add the rest of the boot targets to arch/sh/boot/.gitignore.
      sh: uninline flush_icache_all().
      sh: Add EDOSK7760 mach type.
      sh: Mark kretprobe_trampoline_holder static and __used.
      sh: Disable seccomp support by default.
      sh: kprobes: Hook up kprobe_fault_handler() in the page fault path.
      sh: kprobes: Use trapa #0x3a for breakpoint trap.
      sh: kprobes: Default to NOTIFY_DONE for unhandled debug traps.
      sh: kprobes: Fix up a preemption imbalance on jprobe return.
      sh: kprobes: Fix up race against probe point removal.
      sh: kprobes: __kprobes annotations and formatting cleanups.
      sh: Derive calibrate_delay lpj from clk fwk.
      sh: Add R2D+ defconfig for qemu system emulator.
      sh: kprobes: kretprobe_trampoline needs to be global.
      sh: Provide a fixed UTS_MACHINE definition for sh64.
      sh: ptrace: Introduce user_regset interface for gp regs.
      sh: ioremap_prot support.
      sh: Flag T-bit for syscall restart.
      sh: provide user_stack_pointer(), needed for tracehook support.
      sh: Provide the asm/syscall.h interface, needed by tracehook.
      sh: Enable HAVE_ARCH_TRACEHOOK.
      sh: Fix up NUMA build error with se7722_defconfig.
      sh: Add DSP registers to regset interface.
      sh: Add missing task_user_regset_view() definition.
      sh: Check SR.DSP bit for DSP regset validity.
      sh: Tidy up ELF core dumps.
      sh: latencytop support.
      sh: Fix up fpu emu build.
      sh: Make memory hot-add and hot-remove depend on MMU.
      sh: Fix up signal_64 conflicting handle_signal() definition.
      sh: Consolidate struct sh_cpuinfo definitions across _32/_64 split.
      sh: Fix up headers_check regression.
      sh: HAVE_IOREMAP_PROT depends on MMU.
      sh: Disable 4kB stacks when using PAGE_SIZE_64KB.
      sh: Support kernel stacks smaller than a page.
      sh: Copy in asm/sizes.h helper from ARM.
      sh: Add a few more definitions to asm/sizes.h.
      sh: Move lookup_exception_vector() out to asm/system_32.h.
      sh: Look up the trap vector for the page fault notifier.
      sh: Kill off duplicate page fault notifiers in slow path.
      sh: Trivial trace_mark() instrumentation for core events.
      sh: ftrace support.
      doc: Add remaining SH parameters to kernel-parameters.txt.
      sh: Add missing asm/ftrace.h.
      sh: Add FPU registers to regset interface.
      sh: Force pending restarted system calls to return -EINTR.
      sh: Fix up uaccess_64 put/get_user() cast warnings.
      sh: Fix up signal_64 cast warnings.
      sh: sh_ksyms_64 needs __strncpy_from_user() definition.
      sh: SH-5 clk fwk support.
      sh: Use clk fwk for preset lpj on sh64, too.
      sh: Fix up the __raw_read/writeX() definitions.
      sh: Use __raw_xxx() I/O accessors for INTC and IPR.
      serial: sh-sci: Handle the general UPF_IOREMAP case.
      sh: Move the shared INTC code out to drivers/sh/
      video: sh_mobile_lcdcfb: Support HAVE_CLK=3Dn configurations.
      serial: sh-sci: Dynamic clock management depends on HAVE_CLK.
      Merge branch 'sh/g3-prep'
      sh: More I/O routine overhauling.
      i2c: Renesas Highlander FPGA SMBus support
      rtc: rtc-rs5c372: SMBus conversion/support
      rtc: rtc-rs5c372: add support for Ricoh R2025S/D RTC
      binfmt_elf_fdpic: support auxvec base platform string
      binfmt_elf_fdpic: convert initial stack alignment to arch_align_sta=
ck()
      binfmt_elf_fdpic: wire up AT_EXECFD, AT_EXECFN, AT_SECURE
      Merge branch 'sh/gpiolib'
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/torvalds/linux-2.6
      sh: Fix up some merge damage.
      sh: Move the CPU definition headers from asm/ to cpu/.
      sh: Migrate common board headers to mach-common/.
      sh: Only build in gpio.o when CONFIG_GENERIC_GPIO is selected.
      sh: Move SH-4 CPU headers down one more level.
      binfmt_elf_fdpic: Update for cputime changes.
      sh: Fix up the SH7203 build.
      sh: arch/sh/kernel/smp.c needs linux/cpu.h for notify_cpu_starting(=
).
      sh: gpio: Include asm-generic/gpio.h for non-gpiolib stubs.
      sh: rsk7203: leds-gpio support for RSK+ LEDs.
      sh: gpio: Stub in dummy GPIO<->IRQ mapping routines.
      sh: ap325rxa: Move off of hardcoded pinmux for flctl initialization.
      sh: Hook up PB0->PB7 input-only pins in SH7203 PFC.
      sh: ap325rxa: Kill off unused port definitions.
      sh: Wire up oops reporting in the die notifier chain.
      sh: Export cache flush routines needed by sh_eth on SH7619.
      rtc: Add R2025S/D comment to rs5c372 Kconfig entry.
      sh: Kill off unused p1fc divisors from SH7763 clk fwk.
      sh: update defconfigs.
      sh: mach-highlander: Handle SCIF pinmuxing on R7785RP.
      sh: asm/gpio.h needs linux/kernel.h for might_sleep()/WARN_ON().
      mm: page_cgroup needs linux/vmalloc.h for vmalloc_node()/vfree().
      profiling: fix up CONFIG_PROC_FS=3Dn build

Paul Walmsley (13):
      ARM: OMAP2: Powerdomain: Add base OMAP2/3 powerdomain code
      ARM: OMAP2: Powerdomain: Add OMAP2/3 common powerdomains
      ARM: OMAP2: Powerdomain: Add OMAP2 powerdomains
      ARM: OMAP: Powerdomain: Add OMAP3 powerdomains
      ARM: OMAP2: Clockdomain: Add base OMAP2/3 clockdomain code
      ARM: OMAP2: Clockdomain: Connect clockdomain code to powerdomain co=
de
      ARM: OMAP2: Clockdomain: Encode OMAP2/3 clockdomains
      ARM: OMAP2: Clockdomain: Associate clocks with clockdomains
      ARM: OMAP2: Clockdomain: Integrate OMAP3 clocks with clockdomain co=
de
      [ARM] OMAP3 pwrdm: add hardware save-and-restore (SAR) support
      [ARM] OMAP: clockdomain: add clkdm_get_pwrdm()
      ARM: OMAP2: Fix sparse, checkpatch warnings fro GPMC code, use iore=
map
      ARM: OMAP2: Fix sparse, checkpatch warnings in OMAP2/3 IRQ code

Paulius Zaleckas (2):
      i.MX: Add FIQ support
      USB: ftdi_sio: fix 'product' parameter description

Pavel Machek (3):
      ACPI: catch calls of acpi_driver_data on pointer of wrong type
      Staging: add w35und wifi driver
      leds: Add driver for HP harddisk protection LEDs

Pavel Roskin (1):
      staging: at76_usb wireless driver

Pavel Vasilyev (1):
      fix CONFIG_MMCONFIG=3Dn build warning

Pawel MOLL (4):
      ALSA: Fix limit of 8 PCM devices in SNDRV_CTL_IOCTL_PCM_NEXT_DEVICE
      ALSA: IEC958 definition for consumer status channel update
      ALSA: Fix limit of 8 PCM devices in SNDRV_CTL_IOCTL_PCM_NEXT_DEVICE
      genirq: irq_chip->startup() usage in setup_irq and set_irq_chained =
handler

Pedro Lopez-Cabanillas (2):
      ALSA: snd-usb-audio: support for Edirol UA-4FX device
      ALSA: usb-audio: dynamic detection of MIDI interfaces in uaxx-quirk

Pedro Ribeiro (1):
      IPV6: Fix default gateway criteria wrt. HIGH/LOW preference radv op=
tion

Pekka Enberg (10):
      cifs: don't use GFP_KERNEL with GFP_NOFS
      x86: __show_registers() and __show_regs() API unification
      Staging: w35und: remove some typedefs
      Staging: echo: fix kmalloc()/kfree() uses
      Staging: echo: remove dead code
      Staging: echo: remove __cplusplus macro magic
      Staging: echo: remove annoying "end of function" markers
      Staging: w35und: remove spinlock wrappers
      Staging: w35und: use gotos for error handling
      Staging: w35und: module init cleanup

Pekka Paalanen (9):
      x86: fix mmiotrace 8-bit register decoding
      x86 mmiotrace: fix a rare memory leak
      ftrace: move mmiotrace functions out of trace.c
      ftrace: add trace_vprintk()
      x86 mmiotrace: implement mmiotrace_printk()
      mmiotrace: handle TRACE_PRINT entries
      mmiotrace: remove left-over marker cruft
      ftrace: inject markers via trace_marker file
      tracing/ftrace: fix pipe breaking

Pete Zaitcev (1):
      ub: remove sg_stat

Peter Beutner (1):
      V4L/DVB (9040): TTUSB-DEC DVB-S: claim to have lock

Peter Chubb (1):
      PCI: fix 64-vbit prefetchable memory resource BARs

Peter Jones (1):
      efifb/imacfb consolidation + hardware support

Peter Korsgaard (5):
      powerpc: gpio driver for mpc8349/8572/8610 and compatible
      ALSA: hda: appletv support
      HID: add appletv IR receiver quirk
      Driver core: make bus_find_device_by_name() more robust
      usb core: fix USB_OTG_BLACKLIST_HUB typo

Peter Oberparleiter (3):
      [S390] cio: move device unregistration to dedicated work queue
      [S390] cio: introduce purge function for /proc/cio_ignore
      [S390] cio: inline assembly cleanup

Peter Oruba (21):
      x86: AMD microcode patch loading support v2
      x86: moved Intel microcode patch loader declarations to seperate he=
ader file
      x86: typedef removal
      x86: move per CPU microcode structure declaration to header file
      x86: move microcode.c to microcode_intel.c
      x86: code split to two parts
      x86: structure declaration renaming
      x86: add AMD specific declarations
      x86: first step of refactoring, introducing microcode_ops
      x86: major refactoring
      x86: AMD microcode patch loading support
      x86: AMD microcode patch loader style corrections
      x86: Intel microcode patch loader style corrections
      x86: moved function declarations out from AMD microcode patch loade=
r to heade file
      x86: minor pointer type cast in AMD microcode patch loader
      x86: Microcode patch loader style corrections
      x86: Fixed NULL function pointer dereference in AMD microcode patch=
 loader.
      x86, microcode rework, v2, renaming
      x86, microcode rework, v2, renaming cont.
      x86: microcode patch loader bugfix
      x86: MAINTAINERS change for AMD microcode patch loader

Peter P Waskiewicz (1):
      ixgbe: Whitespace, copyright update and version number change patch

Peter Zijlstra (26):
      printk: robustify printk
      sched: rt-bandwidth for user grouping interface
      sched: rt-bandwidth accounting fix
      sched: rt-bandwidth group disable fixes
      sched: extract walk_tg_tree()
      sched: rt-bandwidth fixes
      printk: robustify printk, fix #2
      sched: wakeup preempt when small overlap
      sched: rework wakeup preemption
      sched: fixlet for group load balance
      sched: add some comments to the bandwidth code
      sched: more sanity checks on the bandwidth settings
      sched: fixup buddy selection
      ipv6: clean up ip6_route_net_init() error handling
      ipv6: initialize ip6_route sysctl vars in ip6_route_net_init()
      net: wrap sk->sk_backlog_rcv()
      net: packet split receive api
      sched: sync wakeups vs avg_overlap
      ftrace: make ftrace_printk usable with the other tracers
      ftrace: sched_switch: show the wakee's cpu
      sched: only update rq->clock while holding rq->lock
      block: move q->unplug_work initialization
      sched: fix the wrong mask_len, cleanup
      sched: optimize group load balancer
      sched: fair scheduler should not resched rt tasks
      sched: revert back to per-rq vruntime

Petr Tesarik (1):
      x86, tracehook: clean up implementation of syscall_get_error()

Petr Vandrovec (2):
      x86: fix early panic on amd64 due to typo in supported CPU section
      r8169: NULL pointer dereference on r8169 load

Phil Dibowitz (1):
      USB: storage: Avoid I/O errors when issuing SCSI ioctls to JMicron =
USB/ATA bridge

Phil Endecott (1):
      intelfb: support 945GME (as used in ASUS Eee 901)

Philip Rakity (1):
      [MTD] cmdlineparts documentation change - explain where mtd-id come=
s from

Philipp Kohlbecher (1):
      x86: fix comment in protected mode header

Phillip Michael Jordan (1):
      ALSA: snd_usb_audio: fix SB Extigy IR Remote regression

Pierre Ossman (15):
      [SCSI] mmc_block: use generic helper to print capacities
      sdhci: let the controller wait for busy state to end
      sdhci: reduce card detection delay
      sdio: make sleep on error interruptable
      sdio: give sdio irq thread a host specific name
      mmc_block: inform block layer about sector count restriction
      mmc_block: indicate strict ordering
      mmc_block: filter out PC requests
      sdhci: force high speed capability on some controllers
      mmc_block: hard code 512 byte block size
      sdio: high-speed support
      mmc: remove redundant "depends on"
      mmc: explicitly mention SDIO support in Kconfig
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/hskinnemoen/atmel-mci-2.6.28
      mmc_block: tell block layer there is no seek penalty

Prakash Mortha (2):
      i2c: Restore i2c_smbus_process_call function
      i2c-viapro: Add support for SMBus Process Call transactions

Prarit Bhargava (1):
      x86, pci: iommu fix potential overflow in alloc_iommu()

Qinghuang Feng (2):
      leds: Fix leds-class.c comment
      fs/dcache.c: update comment of d_validate()

Rafael J. Wysocki (8):
      sky2: Fix WOL regression
      pm: rework disabling of user mode helpers during suspend/hibernatio=
n
      ACPI suspend: Always use the 32-bit waking vector
      ACPI Suspend: Enable ACPI during resume if SCI_EN is not set
      ACPI suspend: Blacklist HP xw4600 Workstation for old code ordering
      x86 ACPI: fix breakage of resume on 64-bit UP systems with SMP kern=
el
      PCI PM: Introduce function pci_wake_from_d3
      ACPI suspend: Fix CONFIG_ACPI_SLEEP dependence and some compilation=
 warnings

Rajiv Andrade (6):
      Remove the BKL calls from the TPM driver, which were added in the o=
verall
      Renames num_open to is_open, as only one process can open the file =
at a time.
      Protect tpm_chip_list when transversing it.
      The tpm_dev_release function is only called for platform devices, n=
ot pnp
      As pointed out by Jonathan Corbet, the timer must be deleted before
      TPM: include "moderated for non-subscribers" notation in MAINTAINER=
S

Rakib Mullick (1):
      cpuset.c: remove extra variable

Ralf Baechle (10):
      MIPS: Optimize get_user and put_user for 64-bit
      MIPS: Alchemy: rename directory
      MIPS: Move headfiles to new location below arch/mips/include
      MIPS: IP checksums: Remove unncessary folding of sum to 16 bit.
      MIPS: IP checksums: Remove unncessary .set pseudos
      MIPS: IP checksums: Optimize adjust of sum on buffers of odd alignm=
ent.
      MIPS: Rewrite spinlocks to ticket locks.
      MIPS: Replace use of <asm-generic/uaccess.h> with native implementa=
tions.
      MIPS: Move ptrace prototypes to ptrace.h
      MIPS: Have a heart for a lonely, lost header file ...

Ralph Campbell (1):
      IB/ipath: Fix SLID generation for RC/UC QPs when LMC > 0

Rami Rosen (4):
      mac80211: remove wme_tx_queue and wme_rx_queue from net/mac80211/st=
a_info.h
      mac80211: remove redundant check in ieee80211_master_start_xmit (ne=
t/mac80211/tx.c)
      ipv4: add mc_count to in_device.
      iwlwifi: fix compilation warning when CONFIG_IWLWIFI_DEBUG is not s=
et.

Randy Dunlap (33):
      documentation: move hpet.txt to timers/ subdirectory
      documentation: move mtrr.txt to Doc/x86/ subdir
      security: add/fix security kernel-doc
      x86, microcode_amd: fix shift warning
      hp-plus: fix link objects
      ath9k: uses/needs led_classdev_[un]register
      mac80211: add missing kernel-doc
      ALSA: us122l - Add missing dependency on CONFIG_SND_HWDEP
      Add some block/ source files to the kernel-api docbook. Fix kernel-=
doc notation in them as needed. Fix changed function parameter names. Fix=
 typos/spellos. In comments, change REQ_SPECIAL to REQ_TYPE_SPECIAL and R=
EQ_BLOCK_PC to REQ_TYPE_BLOCK_PC.
      block_dev: fix kernel-doc in new functions
      doc/cdrom: Trvial documentation error, file not present
      toshiba_acpi: depends on INPUT
      MAINTAINERS: alpha sort
      MAINTAINERS: add F: and acronyms
      MAINTAINERS: remove colon from headings
      MAINTAINERS: move F: line so that it does not break S: line info
      net/phy: add missing kernel-doc
      HID: fix gyration build error
      mac80211: fixme for kernel-doc
      ALSA: kernel docs: fix sound/core/ kernel-doc
      eeepc: depends on RFKILL
      dontdiff: more updates to be closer to gitignore
      documentation: explain memory barriers
      taint: fix kernel-doc
      framebuffer: fix carminefb section mismatch
      docbook: update procfs credits
      block: fix current kernel-doc warnings
      sound: add missing pcm kernel-doc
      mfd: ucb1400 sound driver uses/depends on AC97_BUS:
      usb/gadget: fix kernel-doc warning
      panasonic-laptop: depends on ACPI
      [SCSI] fix netlink kernel-doc
      Fix PCI hotplug printk format

Randy Macleod (1):
      Phonet: Simple doc fix.

Ravi Anand (1):
      [SCSI] qla2xxx: Ignore payload reserved-bits during RSCN processing.

Reinette Chatre (3):
      uwb: add the WiMedia LLC Protocol stack
      uwb: add WiMedia LLC Protocol stack (messages)
      uwb: add WiMedia LLC Protocol stack (WSS)

Remi Cattiau (1):
      HID: ignore iBuddy devices

Remi Denis-Courmont (12):
      Phonet: global definitions
      Phonet: PF_PHONET protocol family support
      Phonet: add CONFIG_PHONET
      Phonet: network device and address handling
      Phonet: Netlink interface
      Phonet: common socket glue
      Phonet: Phonet datagram transport protocol
      Phonet: provide MAC header operations
      Phonet: proc interface for port range
      Phonet: emit errors when a packet cannot be delivered locally
      Phonet: kernel documentation
      phonet: Protect if_phonet.h against multiple inclusions.

Remi Herilier (1):
      Input: wistron - add support for Fujitsu-Siemens Amilo Pro v3505

Renaud CERRATO (1):
      [WATCHDOG] Add AT91SAM9X watchdog

Rene Herman (12):
      ALSA: re-order AC97 codec ID table.
      ALSA: wss_lib: opti92x-ad1848 WSS_HW_DETECT fix
      ALSA: snd-cs4236: add Techmakers MF-4236PW PnP card ID
      ALSA: wss_lib: fix AZT2320 probe.
      ALSA: wss_lib: rework snd_ad1848_probe()
      ALSA: wss_lib: missing closing brace in (ifdeffed out) debug functi=
on.
      x86: {reverve,free}_memtype() take a physical address
      x86: have set_memory_array_{uc,wb} coalesce memtypes.
      agp: enable optimized agp_alloc_pages methods
      ALSA: snd-ad1816a: add different TerraTec EWS64 S model
      i2c-pca-isa: Don't grab arbitrary resources
      pnp: make the resource type an unsigned long

Richard Genoud (1):
      [MTD] [NAND] Bug on atmel_nand HW ECC : OOB info not correctly writ=
ten

Richard Holden (1):
      phonedev: remove BKL

Richard Hughes (1):
      HID: remove ignore quirk for MGE UPS devices

Richard Kennedy (6):
      sched: reorder signal_struct to remove 8 bytes on 64 bit builds
      sched: reorder struct sched_rt_entity to remove padding on 64 bit b=
uilds
      reorder struct prop_local_single to remove padding on 64 bit builds
      hrtimer: reorder struct hrtimer to save 8 bytes on 64bit builds
      libata: reorder ata_device to remove 8 bytes of padding on 64 bits
      NFS: remove 8 bytes of padding from struct nfs_fattr on 64 bit buil=
ds

Richard Purdie (6):
      [MTD] mtdoops: Fix an off by one error
      [MTD] mtdoops: Add a magic number to logged kernel oops
      [MTD] mtdoops: Fix a bug where block may not be erased
      leds: Remove uneeded leds-cm-x270 driver
      leds: Fix trigger registration race
      leds: Simplify logic in leds-ams-delta

Richard Zhao (1):
      ALSA: ASoC: add new param mux to dapm_mux_update_power

Rik van Riel (8):
      vmscan: free swap space on swap-in/activation
      define page_file_cache() function
      vmscan: split LRU lists into anon & file sets
      vmscan: second chance replacement for anonymous pages
      vmscan: fix pagecache reclaim referenced bit check
      vmscan: add newly swapped in pages to the inactive list
      more aggressively use lumpy reclaim
      mmap: handle mlocked pages during map, remap, unmap

Robert Jarzmik (6):
      [ARM] 5202/1: pxa: Added Mitac Mio A701 smartphone support.
      pda_power: Check and handle return value of set_irq_wake
      [ARM] 5244/1: Add hardware CTSRTS flow control to pxa serial driver
      V4L/DVB (8683): Add Micron mt9m111 chip ID in V4L2 identifiers
      V4L/DVB (8684): Add support for Micron MT9M111 camera.
      USB: Fix unneeded endpoint check in pxa27x_udc

Robert P. J. Day (6):
      WIRELESS: Make wireless one-click selectable.
      sound: remove reference to dead sound OSS vars AEDSP16_MSS and SBPR=
O
      XTENSA: warn about including <asm/rwsem.h> directly.
      xtensa: use newer __SPIN_LOCK_UNLOCKED macro
      fuse: config description improvement
      init.h: remove long-dead __setup_null_param() macro

Robert Reif (6):
      sparc32: add init memory poisoning
      rtc-m48t59: Only check century bits on m48t59 chips.
      sparc32: sun4m interrupt mask cleanup
      cg6: disable cursor when leaving graphics mode
      leo: disable cursor when leaving graphics mode
      sparc32: fix build errors

Robert Richter (38):
      x86: add PCI IDs for AMD Barcelona PCI devices
      x86: apic_*.c: add description to AMD's extended LVT functions
      x86/oprofile: introduce model specific init/exit functions
      x86/oprofile: Minor changes in op_model_athlon.c
      x86/oprofile: renaming athlon_*() into op_amd_*()
      drivers/oprofile: coding style fixes in buffer_sync.c
      OProfile: moving increment_tail() in buffer_sync.c
      OProfile: add IBS code macros
      x86/oprofile: separating the IBS handler
      OProfile: change IBS interrupt initialization
      OProfile: Fix build error in op_model_athlon.c
      OProfile: on_each_cpu(): kill unused retry parameter
      OProfile: fix setup_ibs_files() function interface
      OProfile: enable IBS for AMD CPUs
      OProfile: fix IBS build error for UP
      x86/oprofile: macro definition cleanup in op_model_athlon.c
      x86/oprofile: op_model_athlon.c: fix counter reset when reenabling =
IBS OP
      x86: apic: export symbols for extended interrupt LVT functions
      x86: apic: changing export symbols to *_GPL
      x86/oprofile: add CONFIG_OPROFILE_IBS option
      oprofile: fix printk in cpu_buffer.c
      x86/oprofile: reanaming op_model_athlon.c to op_model_amd.c
      x86/oprofile: fix on_each_cpu build error
      x86: cleanup in amd_cpu_notify()
      Revert "Oprofile Multiplexing Patch"
      Merge commit 'v2.6.27-rc5' into tip/oprofile
      OProfile: Rework oprofile_add_ibs_sample() function
      OProfile: Rework string handling in setup_ibs_files()
      OProfile: Rename IBS sysfs dir into "ibs_op"
      oprofile: whitespace fixes
      oprofile: more whitespace fixes
      x86/oprofile: removing unused function parameter in add_ibs_begin()
      x86/oprofile: reordering functions in nmi_int.c
      Merge branch 'oprofile/x86-oprofile-for-tip' into oprofile/oprofile=
-for-tip
      oprofile: fixing whitespaces in drivers/oprofile/*
      oprofile: fixing whitespaces in arch/x86/oprofile/*
      oprofile: fixing whitespaces in arch/x86/oprofile/*
      Merge branch 'oprofile/x86-oprofile-for-tip' into oprofile/for-linu=
s

Robin Getz (11):
      Blackfin arch: add supporting for double fault debug handling
      Blackfin arch: Better error handling of unknown exceptions
      Blackfin arch: Make sure we protect except 2 properly, and print ou=
t memory properly
      Blackfin arch: rename blackfin_sram.c to sram-alloc.c
      Blackfin arch: Use DTEST rather than DMA to poke at L1 SRAM during =
exception context
      Blackfin arch: Make sure we program the correct values in only when=
 necessary for MUSB driver
      Blackfin arch: Fix bug - HW Errors never recover on BF548
      Blackfin arch: Add optional verbose debug
      Blackfin arch: print out error/warning if you are running on the in=
correct CPU type
      Blackfin arch: make sure we include the fix for SPORT hysteresis wh=
en reprogramming clocks
      Blackfin arch: fix bug - build kernel failed at head.S when reprogr=
am clock on all platforms

Robin H. Johnson (5):
      ALSA: HDA: patch_analog: Fix SPDIF output on AD1989B
      ALSA: HDA: hda_local: Less magic numbers.
      ALSA: HDA: hda_proc: Fix printf format specifier
      ALSA: HDA: patch_analog: Implement multiple outputs for AD1988
      ALSA: HDA: patch_analog: Quirk for Asus P5Q Premium/Pro boards.

Rodolfo Giometti (3):
      power_supply: Support for Texas Instruments BQ27200 battery manager=
s
      rtc-ds1307: alarm support for ds1337/ds1339
      leds: Add backlight LED trigger

Roel Kluin (3):
      ALSA: aoa - Remove duplicate assignment of SNDRV_PCM_FMTBIT_S{16,24=
}_BE bits
      powerpc/cell/oprofile: Fix test on overlay_tbl_offset in vma_map
      mfd: check for platform_get_irq() return value in sm501

Roland Dreier (12):
      IPoIB: Fix crash when path record fails after path flush
      IB/mthca: Use pci_request_regions()
      IPoIB: Use netif_tx_lock() and get rid of private tx_lock, LLTX
      powerpc: Avoid integer overflow in page_is_ram()
      Merge branches 'cma', 'cxgb3', 'ehca', 'ipath', 'ipoib', 'mad', 'mi=
sc', 'mlx4', 'mthca' and 'nes' into for-next
      IPoIB: Always initialize poll_timer to avoid crash on unload
      enic: Fix Kconfig headline description
      IB/mad: Use krealloc() to resize snoop table
      Update NetEffect maintainer emails to Intel emails
      PCI: fix MSI-HOWTO.txt info about MSI-X MMIO space
      cxgb3: Fix kernel crash caused by uninitialized l2t_entry.arpq
      Merge branches 'cma', 'cxgb3', 'ehca', 'ipoib', 'mad', 'mlx4' and '=
nes' into for-next

Roland McGrath (9):
      x86: tracehook_signal_handler
      x86: tracehook syscall
      x86: tracehook: asm/syscall.h
      x86 signals: use asm/syscall.h
      x86: tracehook: TIF_NOTIFY_RESUME
      x86: tracehook: CONFIG_HAVE_ARCH_TRACEHOOK
      x86: ioperm user_regset
      add CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS
      x86 syscall.h: fix argument order

Roman Zippel (6):
      clocksource: introduce clocksource_forward_now()
      ntp: fix ADJ_OFFSET_SS_READ bug and do_adjtimex() cleanup
      timekeeping: fix rounding problem during clock update
      ntp: improve adjtimex frequency rounding
      m68k: Put .bss at the end of the data section
      m68k: Add NOTES to init data so its discarded at boot

Ron Mercer (3):
      qlge: New Qlogic 10Gb Ethernet Driver.
      qlge: Fix page size ifdef test.
      qlge: Fix MSI/legacy single interrupt bug.

Ron Rindjunsky (5):
      mac80211: change number of pre-assoc scans
      mac80211: add direct probe before association
      iwlwifi: remove obsolete 4965 forward declarations
      iwlwifi: allow consecutive scans in unassociated state
      iwlwifi: rename ps_mode to sm_ps

Ronen Shitrit (4):
      [ARM] Kirkwood: prepare for runtime-determined timer tick rate
      [ARM] Kirkwood: add support for newer SoC models
      [ARM] Kirkwood: remove uart1 init calls for boards that don't expos=
e uart1
      [ARM] Kirkwood: add support for L2 cache WB/WT selection

Ross Cohen (1):
      Staging: go7007 v4l fixes

Rudolf Marek (1):
      i2c-viapro: Add VX800/VX820 support

Russ Anderson (5):
      x86: trivial printk fix in efi.c
      x86: Add UV EFI table entry v4
      x86: Add UV bios call infrastructure v4
      x86: Add UV partition call v4
      x86: Add sysfs entries for UV v4

Russell King (102):
      [ARM] cputype: separate definitions, use them
      [ARM] cachetype: move definitions to separate header
      [ARM] Update arch/arm/Kconfig for drivers/Kconfig changes, add cpui=
dle
      [ARM] pxa: introduce PXA_HAVE_BOARD_IRQS
      [ARM] sparse: fix several warnings
      [ARM] omap: improve is_omap_port()
      [SERIAL] 8250: serial8250_port_size() - omap ports are larger
      [ARM] omap: remove an io_v2p() usage
      [ARM] omap: allow ioremap() to use our fixed IO mappings
      [ARM] omap: convert OMAP drivers to use ioremap()
      [ARM] omap: convert mcbsp to use ioremap()
      [ARM] omap: Fix IO_ADDRESS() macros
      [ARM] omap: make sure virtual mmio addresses are __iomem pointer-li=
ke
      [ARM] omap: DSP registers don't need to be casted
      [ARM] omap: fix inappropriate casting in gpio.c
      [ARM] omap: fix lots of 'Using plain integer as NULL pointer'
      [ARM] omap: fix a load of "warning: symbol 'xxx' was not declared. =
Should it be static?"
      [ARM] remove pc_pointer()
      [ARM] sparse: quieten arch/arm/kernel/irq.c
      [ARM] move initrd code from kernel/setup.c to mm/init.c
      [ARM] clean up a load of old declarations
      [ARM] Convert asm/uaccess.h to linux/uaccess.h
      [ARM] Convert asm/io.h to linux/io.h
      [ARM] Convert asm/delay.h to linux/delay.h
      [ARM] Convert asm/bitops.h to linux/bitops.h
      [NET] smc91x: provide configurable leds
      Merge branch 'smc91x' into pxa-viper
      [ARM] Add -march=3Dall to assembly file build in arch/arm/boot/comp=
ressed
      [I2C] pxa: provide late suspend and early resume hooks
      [ARM] pxa: Allow platforms to override PSPR setting
      [ARM] Fix IOP13xx build warnings
      [ARM] Update mach-types
      [ARM] pxa: avoid needless pxa_gpio_mode() during resume
      [ARM] pxa: remove references to pxa_gpio_mode() in comments
      [ARM] Remove cache type printks
      [ARM] Introduce new bitmask based cache type macros
      [ARM] Print details relevant to how we handle the cache
      [ARM] dma: rename consistent.c to dma-mapping.c
      [ARM] Update dma_map_sg()/dma_unmap_sg() API
      [ARM] dma: provide a better dma_map_page() implementation
      [ARM] dma: Reduce to one dma_map_sg()/dma_unmap_sg() implementation
      [ARM] pxa: make "gpio_leds" static
      [ARM] dma: Reduce to one dma_sync_sg_* implementation
      [ARM] dma: use new dmabounce_sync_for_xxx() for dma_sync_single_xxx=
()
      [ARM] dma: fix dmabounce dma_sync_xxx() implementations
      [ARM] dma: coding style cleanups
      [ARM] dma: add validation of DMA params
      [ARM] dma: don't touch cache on dma_*_for_cpu()
      [ARM] dma: fix some comments in dma-mapping.h
      [ARM] mm: move validation of membanks to one place
      [ARM] mm: move vmalloc=3D parsing to arch/arm/mm/mmu.c
      [ARM] Convert set_pte_ext implementions to macros
      [ARM] Re-jig Linux PTE bits to allow room for 4 memory type bits
      [ARM] Introduce new PTE memory type bits
      [ARM] Convert Xscale and Xscale3 to use new memory types
      [ARM] Convert ARMv6 and ARMv7 to use new memory types
      [ARM] Convert ARMv7 to use TEX remapping
      [ARM] remove 'prot_pte_ext' from memory type table
      [ARM] Update Xscale and Xscale3 PTE mappings
      [ARM] Remove MT_DEVICE_IXP2000 and associated definitions
      [ARM] Remove MT_NONSHARED_DEVICE alias
      [ARM] Don't include asm/elf.h in asm code
      [ARM] Improve non-executable support
      [ARM] mm: provide helpers for accessing membanks
      [ARM] mm: finish ARM sparsemem support
      [ARM] mm: enable sparsemem on clps7500 and RiscPC
      [ARM] mm: switch SA1100 to use sparsemem
      [ARM] mm: deprecate discontigmem on ARM
      [ARM] mm: allow LH7A40x to use sparsemem
      Merge branch 'omap2-clock' of git://git.kernel.org/pub/scm/linux/ke=
rnel/git/tmlind/linux-omap-2.6.git
      Merge unstable branch 'omap-rmk'
      [ARM] pxa: trizeps4: remove unused variable
      Merge branches 'metronomefb', 'pxa-cm2xx', 'pxa-gumstix', 'pxa-misc=
', 'pxa-mitac', 'pxa-mp900', 'pxa-zylonite' and 'pxa-zaurus' into pxa-mac=
hines
      Merge branch 'pxa-trizeps' into pxa-machines
      Merge branch 'pxa-palm' into pxa-machines
      Merge branch 'viper-for-rmk' of git://www.misterjones.org/linux-2.6=
-arm
      Merge branch 'for_rmk' of git://git.mnementh.co.uk/linux-2.6-im
      Merge branches 'pxa-core' and 'pxa-machines' into pxa-all
      [ARM] pxa: allow multi-machine PCMCIA builds
      Merge branch 'omap2-upstream' of git://git.kernel.org/pub/scm/linux=
/kernel/git/tmlind/linux-omap-2.6 into omap-all
      Merge branches 'machtypes', 'core', 'ep93xx', 'ks8695', 'netdev' an=
d 'sa1100' into devel
      Merge branch 'ptebits' into devel
      Merge branch 'at91' into devel
      Merge branch 'pxa-all' into devel
      Merge branch 'for-rmk' of git://pasiphae.extern.pengutronix.de/git/=
imx/linux-2.6.git
      Merge branch 'for-rmk' of git://source.mvista.com/git/linux-davinci=
-2.6.git
      Merge branch 'for-rmk' of git://git.marvell.com/orion
      Merge branch 'omap3-upstream' of git://git.kernel.org/pub/scm/linux=
/kernel/git/tmlind/linux-omap-2.6 into omap-all
      Merge branch 'omap-all' into devel
      Merge branch 's3c-move' into devel
      Merge branch 'fixes' into for-linus
      [ARM] pxa: fix redefinition of NR_IRQS
      [ARM] pxa: fix 3bca103a1e658d23737d20e1989139d9ca8973bf
      [ARM] dmabounce requires ZONE_DMA
      Merge branch 'for-rmk-fixes' of git://aeryn.fluff.org.uk/bjdooks/li=
nux
      [ARM] pxa: fix trizeps defconfig
      [ARM] pxa: fix trizeps PCMCIA build
      Merge branch 'for-rmk' of git://git.marvell.com/orion into devel
      [ARM] clps711x: add sparsemem definitions
      Merge branch 'for-rmk' of git://git.kernel.org/pub/scm/linux/kernel=
/git/ycmiao/pxa-linux-2.6 into devel
      Merge branch 'for-rmk' of git://git.android.com/kernel into devel
      [ARM] pxa: corgi backlight driver should not select ssp drivers

Rusty Russell (7):
      module: remove CONFIG_KMOD in comment after #endif
      module: simplify load_module.
      module: check kernel param length at compile time, not runtime
      param: Fix duplicate module prefixes
      core_param() for genuinely core kernel parameters
      Make initcall_debug a core_param
      Make panic=3D and panic_on_oops into core_params

R=C3=A9mi Denis-Courmont (10):
      ISDN sockets: add missing lockdep strings
      Phonet: Netlink factorization and cleanup
      Phonet: improve documentation
      Phonet: declare headers
      Phonet: modules auto-loading support
      Phonet: connected sockets glue
      Phonet: Pipe End Point for Phonet Pipes protocol
      Phonet: receive pipe control requests as out-of-band data
      Phonet: implement GPRS virtual interface over PEP socket
      Phonet: pipe end-point protocol documentation

Sakari Ailus (4):
      V4L/DVB (9318): v4l2-int-if: Add command to get slave private data.
      V4L/DVB (9321): v4l2-int-if: Define new power state changes
      V4L/DVB (9322): v4l2-int-if: Export more interfaces to modules
      V4L/DVB (9323): v4l2-int-if: Add enum_framesizes and enum_frameinte=
rvals ioctls.

Sameer Venkatraman (1):
      V4L/DVB (9319): v4l2-int-if: Add cropcap, g_crop and s_crop command=
s.

Samuel Ortiz (1):
      mfd: Fix htc-egpio compile warning

SangSu Park (1):
      USB: g_printer: fix handling zero-length packet

Sarah Sharp (2):
      USB: ftdi-elan: Always pass usb_bulk_msg() a timeout in millisecond=
s.
      USB: Export if an interface driver supports autosuspend.

Sascha Hauer (6):
      [MTD] [NAND] Freescale i.MX2 NAND driver
      MXC: add convenience function to register platform devices
      i.MX3: make SoC devices globally available
      i.MX2: make SoC devices globally available
      i.MX27: add definitions for USB pins
      MX2: Add DMA support for mx2 and (eventually) mx1

Scott Ashcroft (1):
      Fix oti6858 debug level

Scott Feldman (5):
      enic: add Cisco 10G Ethernet NIC driver
      enic: Don't indicate IPv6 pkts using soft-LRO
      enic: fixes for review items from Ben Hutchings
      enic: Bug fix: Free MSI intr with correct data handle
      enic: bug fix: don't set netdev->name too early

Sebastian Andrzej Siewior (2):
      [MTD] remove unused mtd parameter in of_mtd_parse_partitions()
      powerpc: Reflect the used arguments in machine_init() prototype

Sebastian Siewior (1):
      powerpc/boot: Compare _start against ei.loadsize instead ei.memsize

Sebastien Dugue (5):
      powerpc: Separate the irq radix tree insertion and lookup
      powerpc: Make the irq reverse mapping radix tree lockless
      ehea: fix phyp debugging typo
      ehea: fix mutex and spinlock use
      powerpc: Ignore generated vmlinux.lds in git

Semun Lee (1):
      [MTD] [NAND] pxa3xx_nand_flash: Add definition of STM2GbX16 NAND fl=
ashes

Serge E. Hallyn (2):
      selinux: add support for installing a dummy policy (v2)
      file capabilities: uninline cap_safe_nice

Sergei Shtylylov (2):
      sgiioc4: sgiioc4_read_status drive busy check fix
      sgiioc4: fix messages

Sergei Shtylyov (8):
      ide: mask interrupt in ide_config_drive_speed()
      hpt366: cleanup maskproc() method
      sgiioc4: remove maskproc() method
      sgiioc4: kill useless address checks
      sgiioc4: kill duplicate ioremap()
      scc_pata: kill unused variables
      sgiioc4: fix error cleanup path (take 2)
      sgiioc4: use ide_host_add() (take 2)

Sergey Belyashov (1):
      HID: Autocentering support for Logitech MOMO Racing Wheel

Sergey Lapin (4):
      [ARM] 5210/2: AFEB9260: board support
      [ARM] 5219/2: MACB ethernet support for AFEB9260
      [ARM] 5238/2: Very basic Palm Zire 72 support
      [ARM] 5239/1: Palm Zire 72 power management support

Sergio Aguirre (1):
      V4L/DVB (9320): v4l2: Add 10-bit RAW Bayer formats

Seth Heasley (3):
      ata_piix: IDE Mode SATA patch for Intel Ibex Peak DeviceIDs
      x86/PCI: irq and pci_ids patch for Intel Ibex Peak DeviceIDs
      i2c-i801: Add support for Intel Ibex Peak

Shane (2):
      V4L/DVB (9058): spca561: while balance -> white balance typo
      V4L/DVB (9076): gspca: USB direction lacking in spca561.

Shane McDonald (1):
      doc: typo in Documentation/filesystems/nfsroot.txt

Shaohua Li (22):
      introduce two APIs for page attribute
      reduce tlb/cache flush times of agpgart memory allocation
      x86, pageattr: introduce APIs to change pageattr of a page array
      agp: generic_alloc_pages()
      agp: add agp_generic_destroy_pages()
      x86: fix pageattr-test
      ACPI: dock: avoid check _STA method
      dock: fix eject request process (2.6.27-rc1 regression)
      dock: add _LCK support
      dock: add bay and battery hotplug support
      ACPI: introduce notifier change to avoid duplicates
      libata: remove functions now handed by ACPI dock driver
      dock: introduce .uevent for devices in dock, eg libata
      bay: remove driver, all functions now handled by dock driver
      dock: fix for ATA bay in a dock station
      dock: add 'type' sysfs file
      [IA64] utrace syscall.h support for ia64
      [IA64] utrace use generic trace hook
      [IA64] utrace Enable trace hook config
      [IA64] utrace Convert compat ptrace to use compat_sys_ptrace
      memory_probe: fix wrong sysfs file attribute
      dock: make dock driver not a module

Sheng Yang (8):
      x86: move VMX MSRs to msr-index.h
      x86: extended "flags" to show virtualization HW feature in /proc/cp=
uinfo
      KVM: VMX: Rename misnamed msr bits
      KVM: VMX: Clean up magic number 0x66 in init_rmode_tss
      KVM: MMU: Modify kvm_shadow_walk.entry to accept u64 addr
      KVM: VMX: Rename IA32_FEATURE_CONTROL bits
      x86: Move FEATURE_CONTROL bits to msr-index.h
      PCI: add support for function level reset

Shinya Kuribayashi (1):
      MIPS: Kill unused <asm/debug.h> inclusions

Simon Horman (20):
      ipvs: rename __ip_vs_wlc_schedule in lblc and lblcr schedulers
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/davem/net-2.6
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/davem/net-2.6
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/horms/lvs-2.6 into lvs-next-2.6
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/davem/net-2.6
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/davem/net-2.6
      ipvs: load balance ipv6 connections from a local process
      IPVS: fix bogus indentation
      IPVS: use ipv6_addr_copy()
      ipvs: handle PARTIAL_CHECKSUM
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-=
2.6 into lvs-next-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-2.6 i=
nto lvs-next-2.6
      ipvs: only unlock in ip_vs_edit_service() if already locked
      ipvs: supply a valid 0 address to ip_vs_conn_new()
      ipvs: add __aquire/__release annotations to ip_vs_info_seq_start/ip=
_vs_info_seq_stop
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-=
2.6 into lvs-next-2.6
      kdump: update elfcorehdr documentation to reflect supported archite=
ctures
      kdump: use is_kdump_kernel() in sba_init()
      kdump: add is_vmcore_usable() and vmcore_unusable()
      always reserve elfcore header memory in crash kernel

Singh, Vimal (1):
      [MTD] [NAND] nand_ecc.c: adding support for 512 byte ecc

Sonic Zhang (11):
      [libata] pata_bf54x: Add proper PM operation
      Blackfin arch: add supporting for kgdb
      Blackfin arch: Fix bug - kernel build with config kernel debugging =
with remote gdb fails
      Blackfin arch: flags of UART3 mem resource is missing
      Blackfin arch: Make L2 SRAM cacheable
      Blackfin arch: early prink code still use uart core console functio=
ns to parse and set configure option string
      Blackfin arch: fix bug - some serial header files set RTS to an inp=
ut when they should all be outputs
      Blackfin Serial Driver: Fix bug - should suspend/resume/remove all =
uart ports.
      Blackfin Serial Driver: Remove useless stop
      Blackfin Serial Driver: Fix bug - Don't call tx_stop in tx_transfer.
      Blackfin Serial Driver: Fix bug - request UART2/3 peripheral mapped=
 interrupts in PIO mode

Srinivasa Ds (2):
      signals: demultiplexing SIGTRAP signal
      signals: demultiplexing SIGTRAP signal, fix

Stanislaw Gruszka (1):
      atmel_lcdfb: disallow setting larger resolution than the framebuffe=
r memory can handle

Stefan Haberland (1):
      [S390] dasd: fix message flood for unsolicited interrupts

Stefan Herbrechtsmeier (1):
      V4L/DVB (8687): soc-camera: Move .power and .reset from soc_camera =
host to sensor driver

Stefan Raspl (3):
      [SCSI] zfcp: add queue_full sysfs attribute
      blktrace: add support for driver data
      blktrace: pass zfcp driver data

Stefan Richter (13):
      ieee1394: sbp2: stricter dma_sync
      ieee1394: sbp2: check for DMA mapping failures
      ieee1394: sbp2: enforce s/g segment size limit
      ieee1394: raw1394: replace BKL by local mutex, make ioctl() and mma=
p() thread-safe
      ieee1394: raw1394: narrow down the state_mutex protected region
      ieee1394: raw1394: make write() thread-safe
      ieee1394: dv1394, video1394: remove unnecessary expressions
      ieee1394: nodemgr clean up class iterators
      ieee1394: survive a few seconds connection loss
      firewire: fw-sbp2: enforce s/g segment size limit
      firewire: fw-sbp2: fix another small generation access bug
      firewire: fix setting tag and sy in iso transmission
      firewire: fix ioctl() return code

Stefan Roscher (2):
      IB/ehca: Fix reported max number of QPs and CQs in systems with >1 =
adapter
      IB/ehca: Reject dynamic memory add/remove when ehca adapter is pres=
ent

Stefanik G=C3=A1bor (1):
      iwlwifi: enable packet injection for iwlagn

Stephen Hemminger (9):
      sky2: EEPROM read/write bug fixes
      sky2: display product info on boot.
      net: network device name ifalias support
      bonding: add more ethtool support
      netdev: use const for some name functions
      netdev: docbook comment update (revised)
      netdev: change name dropping error codes
      PCI: fix sparse warning in pci_remove_behind_bridge
      8139x: reduce message severity on driver overlap

Stephen Rothwell (18):
      powerpc: Remove include of linux/of_platform.h from asm/of_platform=
.h
      hotplug/rpaphp: Remove unused error path code
      powerpc/drivers: Use linux/of_device.h instead of asm/of_device.h
      powerpc: Remove include of linux/of_device.h from asm/of_device.h
      linux-next: fix x86 tree build failure
      Input: cm109 - don't use obsolete logging macros
      net: ip_vs_proto_{tcp,udp} build fix
      tty: Fallout from tty-move-canon-specials
      ftrace: fix build failure
      md: build failure due to missing delay.h
      DECLARE_PER_CPU needs linux/percpu.h
      powerpc: fix linux-next build failure
      tpm: don't export static functions
      staging: sxg depends on X86
      mfd: don't export wm3850 static functions
      linux-next: build failure
      PCI: don't export linux/io.h from pci.h
      leds/acpi: Fix merge fallout from acpi_driver_data change

Stephen Smalley (2):
      Update selinux info in MAINTAINERS and Kconfig help text
      selinux: use default proc sid on symlinks

Stephen Ware (2):
      usb: vstusb.c : new driver for spectrometers used by Vernier Softwa=
re & Technology, Inc.
      USB: fix up problems in the vtusb driver

Steve Dickson (1):
      NFS: Client mounts hang when exported directory do not exist

Steve French (12):
      [CIFS] use common code for turning off ATTR_READONLY in cifs_unlink
      [CIFS] add constants for string lengths of keynames in SPNEGO upcal=
l string
      [CIFS]  fix busy-file renames and refactor cifs_rename logic
      [CIFS] clean up upcall handling for dns_resolver keys
      [CIFS] update DOS attributes in cifsInode if we successfully change=
d them
      [CIFS]  clean up error handling in cifs_unlink
      [CIFS] make sure we have the right resume info before calling CIFSF=
indNext
      [CIFS] Check that last search entry resume key is valid
      [CIFS] Add nodfs mount option
      [CIFS] undo changes in cifs_rename_pending_delete if it errors out
      [CIFS] fix build error
      [CIFS] improve setlease handling

Steve Glendinning (2):
      net: Add SMSC LAN9500 USB2.0 10/100 ethernet adapter driver
      smsc95xx: fix usb usage on big endian platforms

Steve Hodgson (4):
      sfc: Remove unused field efx_channel::reset_work
      sfc: Do not call netif_{stop,wake}_queue() before register_netdev
      sfc: Don't use EFX_OWORD_FIELD on an event (64-bit, quad-word)
      sfc: Don't include net_driver.h from falcon_io.h

Steve Sakoman (2):
      ARM: OMAP3: Add support for the Gumstix Overo board (rev 3)
      ARM: OMAP3: Defconfig for the Gumstix Overo board (rev 3)

Steve Wise (1):
      RDMA/cxgb3: Remove cmid reference on tid allocation failures

Steven A. Falco (3):
      rtc: rtc-m41t80.c: add support for the ST M41T65 RTC
      powerpc/4xx: Add PowerPC 4xx GPIO driver
      gpio: modify sysfs gpio export so that "value" displays as 0 or 1

Steven Noonan (7):
      x86: unused variable in dma_alloc_coherent_gfp_flags()
      sdhci: 'scratch' may be used uninitialized
      ftrace: add nop tracer
      ftrace: mcount_addr defined but not used
      trace: remove pointless ifdefs
      ftrace: ktime.h not included in ftrace.h
      x86: fix HPET compiler error when not using CONFIG_PCI_MSI

Steven Rostedt (47):
      rcu: just rename call_rcu_bh instead of making it a macro
      rcu: trace fix possible mem-leak
      ftrace: create __mcount_loc section
      ftrace: mcount call site on boot nops core
      ftrace: enable mcount recording for modules
      ftrace: rebuild everything on change to FTRACE_MCOUNT_RECORD
      ftrace: enable using mcount recording on x86
      ftrace: x86 mcount stub
      ftrace: use only 5 byte nops for x86
      ftrace: do not show freed records in available_filter_functions
      ftrace: move notrace to compiler.h
      ftrace: remove old pointers to mcount
      ftrace: new continue entry - separate out from trace_entry
      ftrace: printk formatting infrastructure
      ftrace: ftrace_printk doc moved
      ftrace: dump out ftrace buffers to console on panic
      ftrace: do not init module on ftrace disabled
      ftrace: add necessary locking for ftrace records
      ftrace: update recordmount.pl arch changes
      ftrace: handle weak symbol functions
      ftrace: x86 use copy to and from user functions
      ftrace: objcopy version test for local symbols
      ftrace: add stack tracer
      ftrace: remove direct reference to mcount in trace code
      ftrace: remove warning of old objcopy and local functions
      ftrace: stack trace add indexes
      ftrace: binary and not logical for continue test
      ftrace: print continue index fix
      ftrace: use ftrace_release for all dynamic ftrace functions
      ftrace: fix unlocking of hash
      ftrace: warn on failure to disable mcount callers
      ftrace: give time for wakeup test to run
      tracing: unified trace buffer
      ring_buffer: add paranoid check for buffer page
      ring_buffer: reset buffer page when freeing
      ftrace: make work with new ring buffer
      ftrace: take advantage of variable length entries
      ring_buffer: remove raw from local_irq_save
      ring_buffer: implement new locking
      ftrace: type cast filter+verifier
      ring_buffer: allocate buffer page pointer
      ftrace: preempt disable over interrupt disable
      ring_buffer: map to cpu not page
      ftrace: move pc counter in irqtrace
      ring-buffer: move page indexes into page headers
      ring-buffer: make reentrant
      ftrace: make some tracers reentrant

Steven Toth (67):
      V4L/DVB (8642): cx23885: Factor out common cx23885 tuner callback
      V4L/DVB (8643): Switch Hauppauge HVR1400 and HVR1500 to common cx23=
885 tuner callback
      V4L/DVB (8644): Add support for DViCO FusionHDTV DVB-T Dual Express
      V4L/DVB (8645): Support IR remote on FusionHDTV DVB-T Dual Express
      V4L/DVB (8646): cx23885: Convert framework to use a single tuner ca=
llback function.
      V4L/DVB (8807): Add DVB support for the Leadtek Winfast PxDVR3200 H
      V4L/DVB (8985): S2API: Added dvb frontend changes to support a newe=
r tuning API
      V4L/DVB (8986): cx24116: Adding DVB-S2 demodulator support
      V4L/DVB (8987): cx88: Add support for the Hauppauge HVR4000 and HVR=
4000-LITE (S2) boards
      V4L/DVB (8988): S2API: Allow the properties to call legacy ioctls
      V4L/DVB (8990): S2API: DVB-S/S2 voltage selection bug fix
      V4L/DVB (8995): S2API: tv_ / TV_ to dtv_ / DTV_ namespace changes
      V4L/DVB (8996): S2API: typedefs replaced, _SEQ_'s removed, fixed 16=
 command arrays replaced
      V4L/DVB (8997): S2API: Cleanup SYMBOLRATE, INNERFEC -> SYMBOL_RATE,=
 INNER_FEC
      V4L/DVB (8998): s2api: restore DTV_UNDEFINED
      V4L/DVB (8999): S2API: Reduce demod driver complexity by using a ca=
che sync
      V4L/DVB (9000): S2API: Cleanup code that prepares tuning structures.
      V4L/DVB (9001): S2API: ISDBT_SEGMENT_NUM -> ISDBT_SEGMENT_IDX
      V4L/DVB (9002): S2API: Ensure cache->delivery_system is set at all =
times.
      V4L/DVB (9003): S2API: Remove the DTV_SET_ and DTV_GET_ prefixes
      V4L/DVB (9004): S2API: Implement GET/SET handing to the demods
      V4L/DVB (9006): S2API: Allow reliable use of old and new api on the=
 same frontend, regardless.
      V4L/DVB (9007): S2API: Changed bandwidth to be expressed in HZ
      V4L/DVB (9008): S2API: Bugfix related to syncing the cache when use=
d with the old API.
      V4L/DVB (9009): Nova-se2 / Nova-s-plus Intersil6421 power fix to su=
pport switches.
      V4L/DVB (9021): S2API: Add Kconf dependency
      V4L/DVB (9022): cx88: Enable TDA9887 on HVR1300 / 3000 / 4000
      V4L/DVB (9023): cx88: HVR3000 / 4000 GPIO related changes
      V4L/DVB (9024): S2API: Cleanup dtv_property remove unwanted fields.
      V4L/DVB (9025): S2API: Deactivate the ISDB-T definitions
      V4L/DVB (9070): S2API: Removed the typedef for the commands, used d=
efines instead.
      V4L/DVB (9071): S2API: Implement result codes for individual comman=
ds
      V4L/DVB (9072): S2API: Add DTV_API_VERSION command
      V4L/DVB (9173): S2API: Remove the hardcoded command limit during va=
lidation
      V4L/DVB (9177): S2API: Change _8PSK / _16APSK to PSK_8 and APSK_16
      V4L/DVB (9178): cx24116: Add module parameter to return SNR as ESNO.
      V4L/DVB (9180): S2API: Added support for DTV_CODE_RATE_HP/LP
      V4L/DVB (9181): S2API: Add support fot DTV_GUARD_INTERVAL and DTV_T=
RANSMISSION_MODE
      V4L/DVB (9182): S2API: Added support for DTV_HIERARCHY
      V4L/DVB (9183): S2API: Return error of the caller provides 0 comman=
ds.
      V4L/DVB (9184): cx24116: Change the default SNR units back to perce=
ntage by default.
      V4L/DVB (9222): S2API: Add Multiple-frontend on a single adapter su=
pport.
      V4L/DVB (9230): cx23885: MFE related OOPS fix
      V4L/DVB (9231): cx23885: Define num_frontends as a function of the =
port
      V4L/DVB (9232): cx23885: Move the MFE frontend allocation into the =
correct place
      V4L/DVB (9250): cx88: Convert __FUNCTION__ to __func__
      V4L/DVB (9251): cx23885: Checkpatch compliance
      V4L/DVB (9252): au0828: Checkpatch compliance
      V4L/DVB (9253): cx24116: Checkpatch compliance
      V4L/DVB (9254): cx24116: Checkpatch compliance #2
      V4L/DVB (9255): tda10048: Checkpatch compliance
      V4L/DVB (9256): cx22702: Checkpatch compliance
      V4L/DVB (9257): cx24116: Checkpatch compliance #3
      V4L/DVB (9258): s5h1409: Checkpatch compliance
      V4L/DVB (9259): s5h1411: Checkpatch compliance
      V4L/DVB (9260): cx24123: Checkpatch compliance
      V4L/DVB (9261): xc5000: Checkpatch compliance
      V4L/DVB (9262): cx88: Change spurious buffer message into a debug o=
nly message
      V4L/DVB (9263): mxl5005s: Checkpatch compliance
      V4L/DVB (9273): MFE: videobuf-dvb.c checkpatch cleanup as part of M=
FE merge
      V4L/DVB (9274): Remove spurious messages and turn into debug.
      V4L/DVB (9308): s5h1411: Improvements to the default registers
      V4L/DVB (9309): s5h1411: I/F related bugfix for 3.25 and remove spu=
rious define
      V4L/DVB (9310): s5h1411: read_status() locking detection fixes.
      V4L/DVB (9311): s5h1411: bugfix: Setting serial or parallel mode co=
uld destroy bits
      V4L/DVB (9312): s5h1411: Remove meaningless code
      V4L/DVB (9313): s5h1411: Add the #define for an existing supporting=
 I/F

Steven Whitehouse (9):
      GFS2: Fix debugfs glock file iterator
      GFS2: Fix metafs mounts
      GFS2: Fix & clean up GFS2 rename
      GFS2: Fix race relating to glock min-hold time
      GFS2: The war on bloat
      GFS2: high time to take some time over atime
      GFS2: Add UUID to GFS2 sb
      GFS2: Support for I/O barriers
      vfs: Use const for kernel parser table

Stuart Bennett (1):
      agp/amd-k7: Suspend support for AMD K7 GART driver

Stuart Menefy (4):
      sh: early cached_to_uncached initialization.
      sh: Fix up broken 32-bit initrd support.
      sh: vmalloc pgtable sync fix.
      sh: Fix an unusual memory initialisation error.

St=C3=A9phane Voltz (1):
      V4L/DVB (9066): Pinnacle Hybrid PCTV Pro (pctv310c) DVB-T support

Sujith (23):
      ath9k: Merge reset functions
      ath9k: RX Filter cleanup
      ath9k: Use bitfields for buffer type
      ath9k: Remove a few unnecessary macros
      ath9k: Remove ar5416hal and assign default values directly
      ath9k: Unused macros, variables
      ath9k: Use a single opmode variable
      ath9k: Use bitfields for sc operations
      ath9k: Use ah_curchan and remove sc_curchan which is redundant
      ath9k: Trim struct ath_softc
      ath9k: Remove remaining occurences of ath_skb_map functions
      ath9k: Random cleanup
      ath9k: Miscellaneous fixes
      mac80211: Add an 802.11n definition
      ath9k: Use definition from ieee80211.h
      ath9k: Add IEEE80211_HW_RX_INCLUDES_FCS to hw flags
      ath9k: Remove more dead code
      ath9k: Do not update frame's duration field
      ath9k: Remove sc_lastrx as we don't use it anywhere
      ath9k: rc.h cleanup
      ath9k: Whitespace cleanup
      ath9k: Fix nexttbtt calculation
      ath9k: Fix TSF Adjust usage

Sukadev Bhattiprolu (6):
      tty: Move parts of tty_init_dev into new functions
      Move tty lookup/reopen to caller
      Add an instance parameter devpts interfaces
      Simplify devpts_get_tty()
      Simplify devpts_pty_new()
      Simplify devpts_pty_kill

Sunil Mushran (1):
      ocfs2: Add xattr mount option in ocfs2_show_options()

Suravee Suthikulpanit (1):
      x86/oprofile: add the logic for enabling additional IBS bits

Suresh Siddha (69):
      x64, x2apic/intr-remap: Intel vt-d, IOMMU code reorganization
      x64, x2apic/intr-remap: fix the need for sequential array allocatio=
n of iommus
      x64, x2apic/intr-remap: code re-structuring, to be used by both DMA=
 and Interrupt remapping
      x64, x2apic/intr-remap: use CONFIG_DMAR for DMA-remapping specific =
code
      x64, x2apic/intr-remap: Fix the need for RMRR in the DMA-remapping =
detection
      x64, x2apic/intr-remap: parse ioapic scope under vt-d structures
      x64, x2apic/intr-remap: move IOMMU_WAIT_OP() macro to intel-iommu.h
      x64, x2apic/intr-remap: Queued invalidation infrastructure (part of=
 VT-d)
      x64, x2apic/intr-remap: Interrupt remapping infrastructure
      x64, x2apic/intr-remap: routines managing Interrupt remapping table=
 entries.
      x64, x2apic/intr-remap: generic irq migration support from process =
context
      x64, x2apic/intr-remap: 8259 specific mask/unmask routines
      x64, x2apic/intr-remap: ioapic routines which deal with initial io-=
apic RTE setup
      x64, x2apic/intr-remap: introduce read_apic_id() to genapic routine=
s
      x64, x2apic/intr-remap: Interrupt-remapping and x2apic support, fix
      x64, x2apic/intr-remap: basic apic ops support
      x64, x2apic/intr-remap: cpuid bits for x2apic feature
      x64, x2apic/intr-remap: disable DMA-remapping if Interrupt-remappin=
g is detected (temporary quirk)
      x64, x2apic/intr-remap: x2apic ops for x2apic mode support
      x64, x2apic/intr-remap: introcude self IPI to genapic routines
      x64, x2apic/intr-remap: x2apic cluster mode support
      x64, x2apic/intr-remap: setup init_apic_ldr for UV
      x64, x2apic/intr-remap: IO-APIC support for interrupt-remapping
      x64, x2apic/intr-remap: MSI and MSI-X support for interrupt remappi=
ng infrastructure
      x64, x2apic/intr-remap: add x2apic support, including enabling inte=
rrupt-remapping
      x64, x2apic/intr-remap: support for x2apic physical mode support
      x64, x2apic/intr-remap: introduce CONFIG_INTR_REMAP
      x64, x2apic/intr-remap: Interrupt-remapping and x2apic support
      x2apic: uninline uv_init_apic_ldr()
      x2apic: xen64 paravirt basic apic ops
      x2apic: kernel-parameter documentation for "x2apic_phys"
      x86: let 32bit use apic_ops too - fix
      x86: apic_ops for lguest
      x86: APIC: Remove apic_write_around(); use alternatives, merge fix
      x64, apic: use generic apic_write() for ack_APIC_irq()
      x86, xsave: xsave cpuid feature bits
      x86, xsave: enable xsave/xrstor on cpus with xsave support
      x86, xsave: context switch support using xsave/xrstor
      x86, xsave: dynamically allocate sigframes fpstate instead of stati=
c allocation
      x86, xsave: reorganization of signal save/restore fpstate code layo=
ut
      x86, xsave: xsave/xrstor specific routines
      x86, xsave: struct _fpstate extensions to include extended state in=
formation
      x86, xsave: save/restore the extended state context in sigframe
      x86, xsave: update xsave header bits during ptrace fpregs set
      x86, xsave: remove the redundant access_ok() in setup_rt_frame()
      x86, xsave: clear the user buffer before doing fxsave/xsave
      x86, xsave: use BUG_ON() instead of BUILD_BUG_ON()
      x86: use cpuid vector 0xb when available for detecting cpu topology
      x86: use x2apic id reported by cpuid during topology discovery
      x86: use x2apic id reported by cpuid during topology discovery, fix
      x86: xsave: restore xcr0 during resume
      IO resources, x86: ioremap sanity check to catch mapping requests e=
xceeding the BAR sizes
      x86: xsave: fix error condition in save_i387_xstate()
      x86: xsave: set FP, SSE bits in the xsave header in the user sigcon=
text
      x86, cpa: rename PTE attribute macros for kernel direct mapping in =
early boot
      x86, cpa: remove USER permission from the very early identity mappi=
ng attribute
      x86, cpa: make the kernel physical mapping initialization a two pas=
s sequence
      x86, cpa: dont use large pages for kernel identity mapping with DEB=
UG_PAGEALLOC
      x86, cpa: no need to check alias for __set_pages_p/__set_pages_np
      x86, cpa: remove cpa pool code
      x86, cpa: srlz cpa(), global flush tlb after splitting big page and=
 before doing cpa
      x86: track memtype for RAM in page struct
      x86: fix pagetable init 64-bit breakage
      x86, cpa: make the kernel physical mapping initialization a two pas=
s sequence, fix
      x86: fix compat-vdso
      sparseirq: fix intr-remap with dyn_array/nr_irqs changes]
      dmar: use list_for_each_entry_safe() in dmar_dev_scope_init()
      dmar: fix dmar_parse_dev() devices_cnt error condition check
      dmar: use spin_lock_irqsave() in qi_submit_sync()

Sven Anders (2):
      Input: appletouch - prepare for geyser 3/4 handling
      Input: appletouch - handle geyser 3/4 status bits

Sven Schuetz (1):
      include blktrace_api.h in headers_install

Sven Wegener (18):
      ipvs: Only call init_service, update_service and done_service for s=
chedulers if defined
      ipvs: Create init functions for estimator code
      ipvs: Fix race conditions in lblc scheduler
      ipvs: Fix race conditions in lblcr scheduler
      ipvs: Use pointer to address from sync message
      ipvs: Return negative error values from ip_vs_edit_service()
      ipvs: Mark tcp/udp v4 and v6 debug functions static
      ipvs: Reject ipv6 link-local addresses for destinations
      ipvs: Restrict connection table size via Kconfig
      ipvs: Embed user stats structure into kernel stats structure
      ipvs: Restrict sync message to 255 connections
      ipvs: Fix unused label warning
      ipvs: Remove stray file left over from ipvs move
      [CPUFREQ] Don't export governors for default governor
      md: check for memory allocation failure in faulty personality
      leds: Add leds-wrap default-trigger
      leds: Remove uneeded strlen calls
      leds: leds-pca955x - Mark pca955x_led_set() static

Swen Schillig (10):
      [SCSI] zfcp: remove unused references, declarations and flags
      [SCSI] zfcp: attach and release SAN nameserver port on demand
      [SCSI] zfcp: remove all typedefs and replace them with standards
      [SCSI] zfcp: Simplify get_adapter_by_busid
      [SCSI] zfcp: put threshold data in hba trace
      [SCSI] zfcp: fix deadlock caused by shared work queue tasks
      [SCSI] zfcp: prevent fc_remote_port_delete calls for unregistered r=
port
      [SCSI] zfcp: fix erp list usage without using locks
      [SCSI] zfcp: wait on SCSI work to be finished before proceeding wit=
h init dev
      [SCSI] zfcp: fix double dbf id usage

Syed Mohammed, Khasim (3):
      ARM: OMAP3: Add minimal omap3430 support
      ARM: OMAP3: Add minimal Beagle board support
      ARM: OMAP3: Add Beagle defconfig

Sylver Bruneau (2):
      [ARM] Orion: add Buffalo Terastation Pro II/Live support
      [WATCHDOG] Orion: add hardware watchdog support

Takahiro Hirofuchi (3):
      Staging: USB/IP: add common functions needed
      Staging: USB/IP: add client driver
      Staging: USB/IP: add host driver

Takashi Iwai (59):
      ALSA: hda - use input_free_device()
      ALSA: ac97 - Enable mono-out on ALC203 codec as default
      ALSA: Introduce snd_BUG_ON() macro
      ALSA: Kill snd_assert() in sound/core/*
      ALSA: Kill snd_assert() in sound/isa/*
      ALSA: Kill snd_assert() in sound/pci/*
      ALSA: Kill snd_assert() in other places
      ALSA: Kill snd_assert() definition
      ALSA: Clean up snd_BUG()
      ALSA: hda - Don't reset SPDIF in each status change
      ALSA: hda - initialize node 0x21 properly on AD1988 codecs
      ALSA: Add missing description of usb-audio parameters
      ALSA: usb-audio - Add ignore_ctl_error parameter
      ALSA: fix a typo during snd_assert() removal
      ALSA: hda - Add definitions of HDMI-related verbs
      ALSA: hda - print a few HDMI information in proc
      ALSA: hda - set up HDMI channels
      ALSA: hda - Add AD1882A codec support
      ALSA: hda - disable delayed period-ack with bdl_pos_adj=3D0
      ALSA: Update MAINTAINERS
      ALSA: hda - Create beep control on ALC269 codec
      ALSA: Clean up SG-buffer helper functions and macros
      ALSA: Fix allocation size calculation in snd_dma_alloc_pages_fallba=
ck()
      ALSA: Allocate larger pages in sgbuf
      ALSA: hda - check page continuity
      ALSA: via82xx - ignore buffer preallocation errors
      ALSA: via82xx - check continuous pages in buffer setup
      ALSA: hda - Fix ALC269 capture source
      ALSA: hda - Add descriptions of missing model values
      ALSA: remove obsolete *_FIRMARE_IN_KERNEL in isa/Kconfig
      ALSA: ice1724 - limit channels for multi-channel playback
      ALSA: atiixp - Add PCI ID for SB600 (1002:4382)
      ALSA: intel8x0 - use snd_pci_quirk for clock list
      ALSA: aaci - Fix NULL test at error path
      ALSA: harmony - fix a typo
      ALSA: hda - allow probing of 4 codecs
      ALSA: remove stale files
      ALSA: use correct lock in snd_ctl_dev_disconnect()
      drivers/net/skfp/pmf.c: Use offsetof() macro
      ALSA: Remove bitwise from snd_pcm_hw_param_t
      ALSA: intel8x0 - Add quirk for Fujitsu Lifebook P7010
      ALSA: hda - Fix / clean-up slave digital out codes
      ALSA: usb - Fix possible Oops at USB-MIDI disconnection
      ALSA: hda - Fix PCI SSID for ASROCK K18N78FullHD-hSLI
      ALSA: Increase components array size
      ALSA: Add a note on dependency of RTC stuff
      ALSA: mtpav - Fix race in probe
      ALSA: ASoC - clean up Kconfig for TLV320AIC2
      Merge branches 'topic/asoc' and 'topic/hda' into for-linus
      Merge branches 'topic/misc-fixes', 'topic/hda' and 'topic/asoc' int=
o for-linus
      ALSA: hda - Fix PCM type of Nvidia HDMI devices
      Merge branches 'topic/asoc', 'topic/hda' and 'topic/misc-fixes' int=
o for-linus
      Merge branch 'topic/asoc' into for-linus
      ps3: Add passthru support for non-audio streams
      ALSA: ps3: Add support for SPDIF/HDMI passthru
      go7007 - Add missing dependency on sound subsystem
      Merge branches 'topic/asoc', 'topic/misc-fixes', 'topic/ps3-csbits'=
 and 'topic/staging-fixes' into for-linus
      ALSA: hda - Fix conflicting volume controls on ALC260
      Merge branches 'topic/asoc', 'topic/misc-fixes' and 'topic/hda' int=
o for-linus

Taku Izumi (10):
      PCI: pciehp: change name tag of "hpdriver_portdrv" variable
      PCI: pciehp: replace printk with dev_printk
      ACPI/PCI: Fix possible race condition on _OSC evaluation
      ACPI/PCI: Change pci_osc_control_set() to query control bits first
      ACPI/PCI: Always query _OSC control field in pci_osc_control_set()
      ACPI/PCI: Fix return value of acpi_cuery_osc()
      ACPI/PCI: Set support bit for MSI in support field of _OSC
      PCI hotplug: pciehp: message refinement
      PCI hotplug: shpchp: replace printk with dev_printk
      PCI hotplug: shpchp: message refinement

Tao Ma (19):
      ocfs2: Modify ocfs2_num_free_extents for future xattr usage.
      ocfs2: Use ocfs2_extent_list instead of ocfs2_dinode.
      ocfs2: Abstract ocfs2_extent_tree in b-tree operations.
      ocfs2: Make high level btree extend code generic
      ocfs2: Add the basic xattr disk layout in ocfs2_fs.h
      ocfs2: Add helper function in uptodate.c for removing xattr cluster=
s
      ocfs2: Add extent tree operation for xattr value btrees
      ocfs2: Add xattr index tree operations
      ocfs2: Add xattr bucket iteration for large numbers of EAs
      ocfs2: Add xattr lookup code xattr btrees
      ocfs2: Optionally limit extent size in ocfs2_insert_extent()
      ocfs2: Enable xattr set in index btree
      ocfs2: Delete all xattr buckets during inode removal
      ocfs2: bug-fix for journal extend in xattr.
      ocfs2: Resolve deadlock in ocfs2_xattr_free_block.
      ocfs2/xattr.c: Fix a bug when inserting xattr.
      ocfs2: Add empty bucket support in xattr.
      ocfs2: Calculate EA hash only by its suffix.
      ocfs2: Refactor xattr list and remove ocfs2_xattr_handler().

Tejun Heo (53):
      sound: make OSS sound core optional
      libata: make SCR access ops per-link
      libata: reimplement link iterator
      libata: misc updates to prepare for slave link
      libata: implement slave_link
      ata_piix: drop merged SCR access and use slave_link instead
      libata-eh: clear UNIT ATTENTION after reset
      klist: don't iterate over deleted entries
      driver-core: use klist for class device list and implement iterator
      block: fix partition info printouts
      block: don't grab block_class_lock unnecessarily
      block: use class_dev_iterator instead of class_for_each_device()
      block: allow deleting zero length partition
      block: update add_partition() error handling
      block: misc updates
      block: make variable and argument names more consistent
      block: don't depend on consecutive minor space
      block: fix disk->part[] dereferencing race
      block: fix diskstats access
      block: implement extended dev numbers
      block: adjust formatting for large minors and add ext_range sysfs a=
ttr
      sd/ide-disk: apply extended minors to sd and ide
      block: implement CONFIG_DEBUG_BLOCK_EXT_DEVT
      block: implement and use {disk|part}_to_dev()
      block: introduce partition 0
      block: move capacity from disk to part0
      block: move __dev from disk to part0
      block: unify sysfs size node handling
      block: move policy from disk to part0
      block: move holder_dir from disk to part0
      block: always set bdev->bd_part
      block: kill GENHD_FL_FAIL and use part0->make_it_fail
      block: move stats from disk to part0
      block: make partition array dynamic
      block: replace @ext_minors with GENHD_FL_EXT_DEVT
      block: allow disk to have extended device number
      block: don't test for partition size in bdget_disk() and blk_lookup=
_devt()
      init: DEBUG_BLOCK_EXT_DEVT requires explicit root=3D param
      block: fix duplicate headers for /proc/partitions
      fuse: add include protectors
      fuse: implement nonseekable open
      sysfs: use ilookup5() instead of ilookup5_nowait()
      wait: kill is_sync_wait()
      block: add BIG FAT WARNING to CONFIG_DEBUG_BLOCK_EXT_DEVT
      block: add partition attribute for partition number
      9p-trans_fd: use single poller
      9p: drop broken unused error path from p9_conn_create()
      libata: initialize port_task when !CONFIG_ATA_SFF
      libata-sff: fix ata_sff_post_internal_cmd()
      libata: transfer EHI control flags to slave ehc.i
      libata-eh: fix slave link EH action mask handling
      libata: set device class to NONE if phys_offline
      sata_via: load DEVICE register when CTL changes

Theodore Ts'o (20):
      ext4: Add printk priority levels to clean up checkpatch warnings
      ext4: Fix long long checkpatch warnings
      ext4: Fix whitespace checkpatch warnings/errors
      jbd2: clean up how the journal device name is printed
      ext4: Renumber EXT4_IOC_MIGRATE
      ext4/jbd2: Avoid WARN() messages when failing to write to the super=
block
      ext4: Don't use 'struct dentry' for internal lookups
      ext4: move /proc setup and teardown out of mballoc.c
      ext4: Combine proc file handling into a single set of functions
      ext4: Improve the documentation for ext4's /proc tunables
      ext4: Use readahead when reading an inode from the inode table
      ext4: Remove old legacy block allocator
      ext4: Add debugging markers that can be used by systemtap
      jbd2: Fix buffer head leak when writing the commit block
      Update ext4 MAINTAINERS file
      ext4: Rename ext4dev to ext4
      ext4: let the block device know when unused blocks can be discarded
      ext4: Remove unused mount options: nomballoc, mballoc, nocheck
      ext4: Replace hackish ext4_mb_poll_new_transaction with commit call=
back
      ext4: Remove automatic enabling of the HUGE_FILE feature flag

Thiemo Seufer (1):
      powerpc: Enforce a non-spe kernel build even on broken compilers

Thierry MERLE (2):
      V4L/DVB (9108): cinergyT2: add remote key repeat feature
      V4L/DVB (9155): em28xx-dvb: dvb_init() code factorization

Thomas Bogendoerfer (8):
      sound: oss: remove driver for SGI HAL2 audio device
      tulip: Fix dead 21041 ethernet after ifconfig down
      MIPS: Use compat_sys_ptrace
      MIPS: IP22/28: Switch over to RTC class driver
      MIPS: DS1286: New RTC driver
      MIPS: IP27: Switch over to RTC class driver
      RTC: M48T35: new RTC driver
      MIPS: IP32: Add platform device for CMOS RTC; remove dead code

Thomas Gleixner (45):
      Merge branch 'linus' into x86/pebs
      genirq: remove last NO_IDLE_HZ leftovers
      x86: TSC: define the PIT latch value separate
      x86: TSC: separate hpet/pmtimer calculation out
      x86: TSC: use one set of reference variables
      x86: TSC make the calibration loop smarter
      select: add a timespec_add_safe() function
      select: add poll_select_set_timeout() and poll_select_copy_remainin=
g() helpers
      select: add a poll specific struct to the restart_block union
      softirqs, debug: preemption check
      AMD IOMMU: use iommu_device_max_index, fix
      x86: improve UP kernel when CPU-hotplug and SMP is enabled
      x86: remove additional_cpus
      genirq: define nr_irqs for architectures with GENERIC_HARDIRQS=3Dn
      x86: remove sparse irq from Kconfig
      genirq: consolidate nr_irqs and for_each_irq_desc()
      genirq: use inline function for irq_to_desc
      genirq: remove sparse irq code
      genirq: remove irq_to_desc_alloc
      genirq: revert dynarray
      genirq: cleanup the sparseirq modifications
      x86: cleanup show_interrupts
      x86: unify show_interrupts() and proc helpers
      x86: move ack_bad_irq() to irq.c
      genirq: add reverse iterator for irq_desc
      proc: fixup irq iterator
      genirq: use iterators for irq_desc loops
      genirq: fix name space collision of nr_irqs in autoprobe.c
      genirq: fix name space collisions of nr_irqs in arch/*
      NOHZ: unify the nohz function calls in irq_enter()
      NOHZ: split tick_nohz_restart_sched_tick()
      NOHZ: restart tick device from irq_enter()
      genirq: improve include files
      timer_list: print real timer address
      timer_list: print cpu number of clockevents device
      timer_list: add base address to clock base
      fix documentation of sysrq-q really
      Merge branches 'timers/clocksource', 'timers/hrtimers', 'timers/noh=
z', 'timers/ntp', 'timers/posixtimers' and 'timers/debug' into v28-timers=
-for-linus
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/arjan/linux-2.6-hrtimer into timers/range-hrtimers
      hrtimers: fix docbook comments
      hrtimers: simplify hrtimer_peek_ahead_timers()
      hrtimers: add missing docbook comments to struct hrtimer
      fix CONFIG_HIGHMEM compile error in drivers/gpu/drm/i915/i915_gem.c
      NOHZ: fix thinko in the timer restart code path
      Merge branch 'timers/range-hrtimers' into v28-range-hrtimers-for-li=
nus-v2

Thomas Graf (1):
      netlink: Remove compat API for nested attributes

Thomas Hellstrom (1):
      agp/nvidia: Support agp user-memory on nvidia agp.

Thomas Petazzoni (7):
      x86: make movsl_mask definition non-CPU specific
      x86: move cmpxchg fallbacks to a generic place
      x86: configuration options to compile out x86 CPU support code
      Configure out file locking features
      Fix comment in include/linux/mmc/host.h
      Configure out AIO support
      PCI: allow quirks to be compiled out

Thomas Renninger (5):
      Introduce FW_BUG, FW_WARN and FW_INFO to consistenly tell users abo=
ut BIOS bugs
      ACPI: cpufreq, processor: Detect old BIOS, not supporting CPU freq =
on a recent CPU.
      CPUFREQ: powernow-k8: Try to detect old BIOS, not supporting CPU fr=
eq on a recent AMD CPUs.
      Subject: ACPI dock: Use ACPI_EXCEPTION instead of printk(KERN_ERR
      ACPI: Add expand acpi.debug_layer in kernel-parameters.txt

Tiger Yang (3):
      ocfs2: reserve inline space for extended attribute
      ocfs2: Add extended attribute support
      ocfs2: Add incompatible flag for extended attribute

Tim Bird (2):
      x86, bootup: add built-in kernel command line for x86 (v2)
      tracing/fastboot: add better resolution to initcall debug/tracing

Tim Farrington (1):
      V4L/DVB (9135): cx88 Dvico FusionHDTV Pro

Timothy Lee (1):
      V4L/DVB (8657): cxusb: add lgs8gl5 and support for Magic-Pro DMB-TH=
 usb stick

Timur Tabi (11):
      ALSA: ASoC - fix DMA channel selection in Freescale MPC8610 sound d=
rivers
      powerpc: add SSI-to-DMA properties to Freescale MPC8610 HPCD device=
 tree
      dmatest: properly handle duplicate DMA channels
      fsldma: remove internal self-test from Freescale Elo DMA driver
      fsldma: allow Freescale Elo DMA driver to be compiled as a module
      powerpc: Remove CHRP and PMAC support from FSL defconfigs
      powerpc: make Freescale QE support a selectable Kconfig option
      powerpc: remove support for bootmem-allocated memory for the DIU dr=
iver
      powerpc: disable CHRP and PMAC support in various defconfigs
      powerpc: document the "fsl,ssi-dma-channel" compatible property
      powerpc: reserve two DMA channels for audio in MPC8610 HPCD device =
tree

Tirumala R Marri (1):
      powerpc/44x: AMCC PPC460GT/EX PCI-E de-emphasis adjustment fix

Tobias Brunner (1):
      af_key: fix SADB_X_SPDDELETE response

Tobias Lorenz (7):
      V4L/DVB (9213): si470x: module_param access rights
      V4L/DVB (9214): si470x: improvement of module device support
      V4L/DVB (9215): si470x: improvement of unsupported base controls
      V4L/DVB (9216): si470x: tuner->type handling
      V4L/DVB (9217): si470x: correction of mono/stereo handling
      V4L/DVB (9218): si470x: removement of get/set input/audio
      V4L/DVB (9219): Kernel config comment corrected (radio-silabs -> ra=
dio-si470x)

Tom Quetchenbach (1):
      tcp: advertise MSS requested by user

Tom Talpey (15):
      RPC/RDMA: refactor the inline memory registration code.
      RPC/RDMA: add data types and new FRMR memory registration enum.
      RPC/RDMA: check selected memory registration mode at runtime.
      RPC/RDMA: support FRMR client memory registration.
      RPC/RDMA: suppress retransmit on RPC/RDMA clients.
      RPC/RDMA: maintain the RPC task bytes-sent statistic.
      RPC/RDMA: avoid an oops due to disconnect racing with async upcalls.
      RPC/RDMA: adhere to protocol for unpadded client trailing write chu=
nks.
      RPC/RDMA: return a consistent error, when connect fails.
      RPC/RDMA: fix connect/reconnect resource leak.
      RPC/RDMA: harden connection logic against missing/late rdma_cm upca=
lls.
      RPC/RDMA: reformat a debug printk to keep lines together.
      RPC/RDMA: optionally emit useful transport info upon connect/discon=
nect.
      RPC/RDMA: correct the reconnect timer backoff
      RPC/RDMA: ensure connection attempt is complete before signalling.

Tom Tucker (12):
      svcrdma: Add Fast Reg MR Data Types
      svcrdma: Add FRMR get/put services
      svcrdma: Query device for Fast Reg support during connection setup
      svcrdma: Add a service to register a Fast Reg MR with the device
      svcrdma: Modify post recv path to use local dma key
      svcrdma: Add support to svc_rdma_send to handle chained WR
      svcrdma: Modify the RPC recv path to use FRMR when available
      svcrdma: Modify the RPC reply path to use FRMR when available
      svcrdma: Update svc_rdma_send_error to use DMA LKEY
      svcrdma: Fix IRD/ORD polarity
      RPC/RDMA: fix connection IRD/ORD setting
      9p: rdma: RDMA Transport Support for 9P

Tomas Winkler (29):
      mac80211: add ieee80211_queue_stopped)
      iwlwifi: kill struct iwl4965_lq_mngr
      mac80211: filter probes in ieee80211_rx_mgmt_probe_resp
      mac80211: cleanup mlme state namespace
      mac80211: Fix low bit rate in IBSS
      iwlwifi: clean up hw scan handler
      iwlwifi: align set channel with mac80211
      iwlwifi: use strict_strtoul instead of simple_strtoul
      iwlwifi: replace readl and writel with io/read/write/32
      iwlwifi: remove rfkill warning from iwl-io
      iwlwifi: generic init calibrations framework
      iwlwifi: cleanup PCI register handling
      iwlwifi: fix host command header according the HW spec
      iwlwifi: remove bad language from the comments
      mac80211: change MIMO_PS to SM_PS
      mac80211: restructure disassoc/deauth flows
      mac80211: disassociate when moving to new BSS
      mac80211: remove disassociation code from ieee80211_set_associated
      mac80211: stop queues before carrier off
      iwlwifi: update 5350 Wifi PCI IDs
      iwlwifi: add MODULE_FIRMWARE for 5000 HW
      iwlwifi: don't delay scan in IBSS mode
      iwlwifi: make PS use named constants
      iwlwifi: don't fail if scan is issued too early
      mac80211: remove shadowed variables in ieee80211_master_start_xmit
      iwlwifi: scan correct setting of valid rx_chains
      iwlwifi: scan fix comment
      iwlwifi: remove STATUS_CONF_PENDING in scanning
      iwlwifi: fix ct kill configuration for 5350

Tomasz Grobelny (2):
      dccp: Policy-based packet dequeueing infrastructure
      dccp qpolicy: Parameter checking of cmsg qpolicy parameters

Tomi Orava (1):
      V4L/DVB (9107): Alternative version of Terratec Cinergy T2 driver

Tomoya Adachi (1):
      HID: report descriptor fix for remaining MacBook JIS keyboards

Tony Breeds (4):
      powerpc: Guard htab_dt_scan_hugepage_blocks appropriately
      powerpc: Guard from_rtc_time() in platforms/powermac/time.c
      powerpc: Guard print_device_node_tree() with #if 0
      powerpc/mpc5200: Silence warnings in arch/powerpc/platforms/52xx/mp=
c52xx_pci.c

Tony Lindgren (8):
      ARM: OMAP2: Move sleep.S into sleep24xx.S
      ARM: OMAP2: Use omap_globals for CPU detection for multi-omap
      ARM: OMAP2: Misc updates from linux-omap tree
      [ARM] 5301/1: ARM: OMAP: Add missing irq defines
      [ARM] 5305/1: ARM: OMAP: Fix compile of McBSP by removing unnecessa=
ry check
      [ARM] 5302/1: ARM: OMAP: Revert omap3 WDT changes to avoid merge co=
nflict
      USB: ohci-omap: handle other omap15xx chips
      USB: omap_udc: sync with OMAP tree

Tony Luck (5):
      [IA64] Fix annoying IA64_TR_ALLOC_MAX message.
      Pull compat into release branch
      Pull utrace into release branch
      Pull pv_ops-xen into release branch
      Pull vtd-iommu into release branch

Torsten Krah (1):
      asus-laptop: Add support for P30/P35

Travis Place (1):
      ALSA: hda - Add model for Toshiba L305 laptop

Trent Piepho (6):
      gianfar: Fix error in mdio reset timeout
      PHY: Avoid unnecessary aneg restarts
      phylib: Wake PHY state machine on interrupt
      gianfar: Create net device with carrier down
      sysfs: Make dir and name args to sysfs_notify() const
      leds: Make default trigger fields const

Trond Myklebust (21):
      NFS: Fix nfs_file_llseek()
      NFS: Clean up nfs_sb_active/nfs_sb_deactive
      NFS: Add options for finer control of the lookup cache
      NFS: Don't apply NFS_MOUNT_FLAGMASK to text-based mounts
      NFS: Add mount options for controlling the lookup cache
      NFS: Clean up nfs_refresh_inode() and nfs_post_op_update_inode()
      NFS: Fix the NFS attribute update
      NFS: Fix nfs_post_op_update_inode_force_wcc()
      NFS: Convert __nfs_revalidate_inode() to use nfs_refresh_inode()
      NFS: Don't clear nfsi->cache_validity in nfs_check_inode_attributes=
()
      NFS: Fix up nfs_setattr_update_inode()
      NFS: Allow concurrent inode revalidation
      SUNRPC: Fix autobind on cloned rpc clients
      SUNRPC: Fix a memory leak in rpcb_getport_async
      NFS: Don't use range_cyclic for data integrity syncs
      NFS: Save padding bytes in struct nfs4_setclientid
      NFS: Fix attribute updates
      NFS: Changes to inode->i_nlinks must set the NFS_INO_INVALID_ATTR f=
lag
      NFS: Fix the resolution problem with nfs_inode_attrs_need_update()
      NFS: Fix a resolution problem with nfs_inode->cache_change_attribut=
e
      Merge branch 'next'

Tyler Hicks (1):
      eCryptfs: remove netlink transport

Tzafrir Cohen (5):
      Staging: echo: A separate oslec.h for external interface
      Staging: echo: Export interface functions. Add module headers.
      Staging: echo: Replace echo_can_state_t with struct echo_can_state
      Staging: echo: Changed preffix from echo_can_ to oslec_
      Staging: echo: Replace __BLACKFIN__ASM__ with __bfin__

T=C3=B3th L=C3=A1szl=C3=B3 Attila (1):
      ipv4: Allow binding to non-local addresses if IP_TRANSPARENT is set

Uros Bizjak (1):
      x86, cleanup: use X86_CR4_PGE in x86/power/hibernate_asm_32.S

Ursula Braun (3):
      qeth: use firmware MAC-address for layer2 hsi-devices
      qeth: avoid qeth recovery problems
      [S390] qdio: speed up multicast traffic on full HiperSocket queue

Uwe Kleine-K=C3=B6nig (9):
      Input: gpio-keys - optimize interrupt handler
      Input: gpio-keys - simplify argument list for report_event
      ALSA: fix section for sa11xx-uda1341 platform driver
      x86, debug: gpio_free might sleep
      avr32: Use platform_driver_probe for pio platform driver
      avr32: Use platform_driver_probe for pdc platform driver
      ALSA: Fix section for snd-aica platform driver
      Fix sections for omap-mcbsp platform driver
      gpio_free might sleep, generic part

Vadim Makhervaks (1):
      RDMA/nes: Enhanced PFT management scheme

Valdis Kletnieks (1):
      tpm: work around bug in Broadcom BCM0102 chipset

Vasanthakumar Thiagarajan (3):
      ath9k: Add LED support
      ath9k: Re-order functions in main.c
      ath9k: Add RF kill support

Vedran Miletic (4):
      ALSA: ice1724: Enable MIDI on TerraTec PHASE 22 and PHASE 28
      ALSA: ice1712/ice1724: Coding style fixes part 1 (more coming up)
      ALSA: cs46xx: Add PCI IDs for TerraTec and Hercules cards
      ALSA: hda: add more board-specific information for Realtek ALC662 r=
ev1

Vegard Nossum (7):
      x86: fix spurious '#' in kvm header
      x86: consolidate header guards
      x86: consolidate header guards
      tcp_ipv6: fix use of uninitialized memory
      x86: add memory clobber in switch_to()
      x86: fix virt_addr_valid() with CONFIG_DEBUG_VIRTUAL=3Dy, v2
      utsname: completely overwrite prior information

Venkatesh Pallipadi (4):
      cpuidle: use last_state which can reflect the actual state entered
      cpuidle: update the last_state acpi cpuidle reflecting actual state=
 entered
      cpuidle: upon BIOS bug, default to default_idle rather than polling
      x86 allow modules to register idle notifiers

Venki Pallipadi (3):
      x86: have set_memory_array_{uc,wb} coalesce memtypes, fix
      x86: using HPET in MSI mode and setting up per CPU HPET timers, fix
      hpet: clean up warning

Vernon Sauder (2):
      spi: simplify spi_write_then_read()
      pxa2xx_spi: fix chip_info defaults and documentation.

Vesa-Matti J Kari (2):
      SELinux: Trivial minor fixes that change C null character style
      SELinux: trivial, remove unneeded local variable

Vesa-Matti Kari (2):
      selinux: conditional expression type validation was off-by-one
      selinux: Unify for- and while-loop style

Victor Gallardo (5):
      ibm_newemac: Add support for GPCS, SGMII and M88E1112 PHY
      powerpc/44x: Add AMCC Arches eval board support
      powerpc/44x: Add AMCC Arches DTS
      powerpc/44x: Add AMCC Arches defconfig file
      ibm_newemac: Fix EMAC soft reset on 460EX/GT

Vijay Kumar (1):
      Staging: add poch driver

Vikram Pandita (1):
      ARM: OMAP2: Add pinmux support for omap34xx

Ville Syrjala (2):
      Input: ati_remote2 - add loadable keymap support
      Input: ati_remote2 - add autosuspend support

Vince Busam (2):
      IPVS: Convert procfs files for IPv6 entry output
      IPVS: Add function to determine if IPv6 address is local

Vincent Legoll (1):
      PCI: probing debug message uniformization

Vitaly Mayatskikh (1):
      powerpc: Honor O_NONBLOCK flag when reading RTAS log

Vitja Makarov (1):
      Blackfin arch: introducing bfin_addr_dcachable

Vivek Goyal (1):
      kdump: make elfcorehdr_addr independent of CONFIG_PROC_VMCORE

Vlad Yasevich (11):
      bonding: Do not tx-balance some IPv6 packets on ALB/TLB bonds
      sctp: Only mark chunks as missing when there are gaps
      sctp: Optimize SFR-CACC transport list walking during SACK processi=
ng
      sctp: Retransmit list is ineligable for missing indications
      sctp: try harder to figure out address family when checking wildcar=
ds
      sctp: enable cookie-echo retransmission transport switch
      sctp: correctly save sctp_adaptation from parameter.
      sctp: Rework the tsn map to use generic bitmap.
      sctp: shrink sctp_tsnmap some more by removing gabs array
      sctp: Fix SNMP number of SCTP_MIB_ABORTED during violation handling.
      sctp: update SNMP statiscts when T5 timer expired.

Vladimir Barinov (1):
      ALSA: Correct Vladimir Barinov's e-mail address

Vladimir Sokolovsky (1):
      IB/mlx4: Set RLKEY bit for kernel QPs

Vladimir Vukicevic (1):
      USB: Add Oceanic product ID to ftdi_sio

Vladislav Bogdanov (1):
      edac: make i82443bxgx_edac coexist with intel_agp

Volodymyr G. Lukiianyk (1):
      uclinux: fix gzip header parsing in binfmt_flat.c

WANG Cong (3):
      kernel/kallsyms.c: fix double return
      uml: fix a compile error
      kernel/configs.c: remove useless comments

Wang Chen (1):
      skge: Fix skge_set_ring_param() losing error return

Wei Ni (2):
      ALSA: Support NVIDIA MCP78/7A HDMI audio
      ALSA: Fix for reading RIRB buffer on NVIDIA aza controller with AMD=
 Phenom cpu

Wei Yongjun (9):
      dccp: Always generate a Reset in response to option errors
      dccp: Always generate a Reset in response to option errors
      sctp: Fix to start T5-shutdown-guard timer while enter SHUTDOWN-SEN=
T state
      sctp: Fix the SNMP counter of SCTP_MIB_OUTOFBLUES
      sctp: Fix the SNMP number of SCTP_MIB_CURRESTAB
      sctp: Drop ICMP packet too big message with MTU larger than current=
 PMTU
      sctp: Add check for the TSN field of the SHUTDOWN chunk
      sctp: Fix to handle SHUTDOWN in SHUTDOWN-PENDING state
      sctp: Fix to handle SHUTDOWN in SHUTDOWN_RECEIVED state

Weidong Han (2):
      KVM: Remove useless intel-iommu.h header inclusion
      KVM: Device Assignment: Map mmio pages into VT-d page table

Weiwei Wang (1):
      [netdrvr] convert sbmac tx to spin_lock_irqsave to prevent early IR=
Q enable

Will Newton (12):
      8250: remove a few inlines of dubious value
      fsl_usb2_udc: Make dr_ep_setup function static.
      fsl_usb2_udc: Remove check for udc =3D=3D NULL in dr_controller_set=
up.
      fsl_usb2_udc: Fix some sparse warnings and remove redundant code.
      fsl_usb2_udc: Clean up whitespace in errors and warnings.
      fsl_usb2_udc: Clean up whitespace in /proc debugging output.
      fsl_usb2_udc: Initialize spinlock earlier.
      fsl_usb2_udc: Rename the arguments of the fsl_writel macro.
      fsl_usb2_udc: Uninline udc_reset_ep_queue.
      fsl_usb2_udc: Make fsl_queue_td return type void.
      fsl_usb2_udc: Add a wmb before priming endpoint.
      fsl_usb2_udc: Fix oops on probe failure.

Wim Van Sebroeck (2):
      [WATCHDOG] orion5x_wdt.c: add spinlocking
      [WATCHDOG] ib700wdt.c - fix buffer_underflow bug

Winkler, Tomas (2):
      iwlwifi: refactor rx register initialization
      iwlwifi: use correct DMA_MASK

Wolfgang Grandegger (4):
      i2c-mpc: suppress I2C device probing
      [MTD] [NAND] driver extension to support NAND on TQM85xx modules
      hwmon: (w83781d) Make ISA interface depend on CONFIG_ISA
      hwmon: (w83781d) Use new style driver binding

Wolfgang Ocker (1):
      of/spi: Support specifying chip select as active high via device tr=
ee

Wolfram Sang (6):
      powerpc/mpc5200: trivial printk-fixes in mpc52xx_common
      powerpc/mpc5200: Don't touch pipelining for MPC5200B
      powerpc/mpc5200: Refactor FEC mdio read/write routines
      i2c-cpm: Suppress autoprobing for devices
      i2c: Make clear what the class field of i2c_adapter is good for
      i2c: Inform about deprecated chips directory

Wu Fengguang (2):
      ALSA: hda: comment typo fix
      ALSA: hda: comment typo fix

Xiantao Zhang (12):
      KVM: ia64: add a dummy irq ack notification
      KVM: ia64: Enable virtio driver for ia64 in Kconfig
      KVM: ia64: Implement kvm_arch_vcpu_ioctl_{set,get}_mpstate
      KVM: ia64: Implement a uniform vps interface
      KVM: ia64: add support for Tukwila processors
      KVM: Move device assignment logic to common code
      KVM: Change is_mmio_pfn to kvm_is_mmio_pfn, and make it common for =
all archs
      KVM: Separate irq ack notification out of arch/x86/kvm/irq.c
      KVM: Move irqchip_in_kernel() from ioapic.h to irq.h
      KVM: ia64: Make pmt table be able to hold physical mmio entries.
      KVM: ia64: add directed mmio range support for kvm guests
      KVM: ia64: Add intel iommu support for guests.

Xiaoming.Zhang (1):
      [10/21] driver/net/skge.c: restart the interface when it's options =
or

YanBo (1):
      mac80211: mesh portal functionality support

Yannick Cote (1):
      IB/ipath: Fix hang on module unload

Yanqing_Liu-DYMqY+WieiM@public.gmane.org (1):
      [SCSI] scsi_dh: add Dell product information into rdac device handl=
er

Yauhen Kharuzhy (1):
      USB: Fix s3c2410_udc usb speed handling

Yevgeny Petrilin (7):
      mlx4_core: Add QP range reservation support
      mlx4_core: Support multiple pre-reserved QP regions
      mlx4_core: Get ethernet MTU and default address from firmware
      mlx4_core: Ethernet MAC/VLAN management
      mlx4_core: Multiple port type support
      mlx4_en: Add driver for Mellanox ConnectX 10GbE NIC
      mlx4_core: Add Ethernet PCI device IDs

Yi Yang (2):
      USB: improve ehci_watchdog's side effect in CPU power management
      ACPICA: Return status from global init function

Yinghai Lu (192):
      x86: let 32bit use apic_ops too
      x86: mach_apicdef.h need to include before smp.h
      x86: make read_apic_id return final apicid
      x86: make 64bit have get_apic_id
      x86: let 32bit use apic_ops too - fix
      x86: add apic probe for genapic 64bit, v2
      x86: move declaring x2apic_extra_bits
      usb: move ehci reg def
      x86: usb debug port early console, v4
      x86: add setup_ioapic_ids for numaq in x86_quirks
      x86: mach-bigsmp to bigsmp
      x86: mach_es7000 to es7000
      x86: mach_summit to summit
      x86: mach-numaq to numaq
      x86: add apic probe for genapic 64bit - fix
      x86: print per_cpu data address
      x86: apic - unify lapic_resume - fix
      x86: fix apic version warning
      x86_64: printout msr -v2
      x86: move dir es7000 to es7000_32.c
      x86: split e820 reserved entries record to late v2
      IO resources: add reserve_region_with_split()
      x86: split e820 reserved entries record to late, v7
      x86: unify using pci_mmcfg_insert_resource
      x86: move mtrr cpu cap setting early in early_init_xxxx
      x86: make (early)_identify_cpu more the same between 32bit and 64 b=
it
      x86: order functions in cpu/common.c and cpu/common_64.c v2
      x86: remove cpu_vendor_dev
      x86: make 32bit support show_msr like 64 bit
      x86: make get_mode_name of 64bit the same as 32bit
      x86: move 32bit related functions together
      x86: make detect_ht depend on CONFIG_X86_HT
      x86: make header file the same in arch/x86/kernel/cpu/common_xx.c
      x86: same gdt_page with macro
      x86: cpu/common.c, let 64-bit code have 32-bit only functions
      x86: cpu/common*.c, make 32-bit have 64-bit only functions
      x86: cpu/common*.c have same cpu_init(), with copying and #ifdef
      x86: cpu/common*.c, merge switch_to_new_gdt()
      x86: cpu/common.c, merge default_init()
      x86: cpu/common*.c, merge display_cacheinfo()
      x86: cpu/common*.c, merge detect_ht()
      x86: cpu/common.c: merge get_cpu_cap()
      x86: cpu/common*.c, merge early_identify_cpu()
      x86: cpu/common*.c: merge print_cpu_info()
      x86: cpu/common*.c, merge generic_identify()
      x86: cpu/common*.c, merge identify_cpu()
      x86: use cpu/common.c on 64 bit
      x86: move nonx_setup etc from common.c to init_64.c
      x86: remove duplicated get_model_name() calling
      x86, cpu init: call early_init_xxx in init_xxx
      x86: cpu make amd.c more like amd_64.c v2
      x86: remove duplicated force_mwait
      x86: add srat_detect_node for amd64
      x86: merge header in amd_64.c
      x86: make amd.c have 64bit support code
      x86: make amd_64 have 32 bit code
      x86: make 64 bit to use amd.c
      x86: little clean up of intel.c/intel_64.c
      x86: make intel.c have 64-bit support code
      x86: make intel_64.c the same as intel.c
      x86: let intel 64-bit use intel.c
      x86: intel.c put workaround for old cpus together
      x86: centaur_64.c remove duplicated setting of CONSTANT_TSC
      x86: identify_cpu_without_cpuid v2
      x86: move transmeta cap read to early_init_transmeta()
      x86: fix arch/x86/kernel/cpu/mtrr/main.c warning
      x86: fix CONFIG_X86_RESERVE_LOW_64K=3Dy
      x86: use WARN_ONCE in workaround for mtrr mask
      x86: fix macro with bad_bios_dmi_table
      x86: don't need to go to chunksize to 4G
      x86: mtrr_cleanup optimization, v2
      x86: add mtrr_cleanup_debug command line
      x86: mtrr_cleanup hole size should be less than half of chunk_size,=
 v2
      x86: mtrr_cleanup safe to get more spare regs now
      x86: mtrr_cleanup prepare to make gran_size to less 1M
      x86: mtrr_cleanup try gran_size to less than 1M
      x86: change MTRR_SANITIZER to def_bool y
      x86: mtrr_cleanup try gran_size to less than 1M, v3
      x86, debug: mtrr_cleanup print out var mtrr before change it
      x86: mtrr_cleanup: print out correct type v2
      x86: mtrr_cleanup: first 1M may be covered in var mtrrs
      x86: mtrr_cleanup: treat WRPROT as UNCACHEABLE
      ACPI: don't load acpi_cpufreq if acpi=3Doff
      ACPI: remove unused have_arch_parse_srat
      x86: rename discontig_32.c to numa_32.c
      x86: check dsdt before find oem table for es7000, v2
      x86: cpu don't print duplicated vendor string
      x86: cleanup, remove extra ifdef
      x86: change early_ioremap to use slots instead of nesting
      x86: add after_bootmem flag for 32bit
      x86: remove irq_vectors_limits
      generic: add dyn_array support
      add per_cpu_dyn_array support
      x86: alloc dyn_array all together
      x86: enable dyn_array support
      irq: introduce nr_irqs
      x86: use nr_irqs
      drivers/char: use nr_irqs
      drivers/net: use nr_irqs
      drivers/pci/ intr remapping: use nr_irqs
      drivers/pcmcia: use nr_irqs
      drivers/rtc: use nr_irqs
      drivers/scsi: use nr_irqs
      drivers/serial: use nr_irqs
      fs/proc: use nr_irqs
      drivers/xen: use nr_irqs
      irqs: make irq_timer_state to use dyn_array
      irq: make irq2_iommu to use dyn_array
      irq: make irq_desc to use dyn_array
      irq: make irqs in kernel stat use per_cpu_dyn_array
      x86: use dyn_array in io_apic_xx.c
      x86, irq: get nr_irqs from madt
      x86: remove nr_irq_vectors
      generic: sparse irqs: use irq_desc() together with dyn_array, inste=
ad of irq_desc[]
      x86: add irq_cfg in io_apic_64.c
      x86: put irq_2_pin pointer into irq_cfg
      x86: put timer_rand_state pointer into irq_desc
      x86: move kstat_irqs from kstat to irq_desc
      irq: add irq_desc_without_new
      irq: replace loop with nr_irqs with for_each_irq_desc
      irq, fs/proc: replace loop with nr_irqs for proc/stat
      x86, ioapic: replace loop with nr_irqs with for_each_irq_icfg
      irq: remove >=3D nr_irqs checking with config_have_sparse_irq
      generic: add irq_desc in function in parameter
      x86: check with without_new in show_interrupts
      x86_64: rename irq_desc/irq_desc_alloc
      irq: separate sparse_irqs from sparse_irqs_free
      x86_64: separate irq_cfgx from irq_cfgx_free
      x86_64: make /proc/interrupts work with dyn irq_desc
      x86: put irq_2_iommu pointer into irq_desc
      x86: use 28 bits irq NR for pci msi/msix and ht
      x86: remove irqbalance in kernel for 32 bit
      x86: add irq_cfg for 32bit
      x86: make 32bit use irq_cfg_alloc, etc
      x86: make 32bit to use irq_2_pin in irq_cfg
      x86: make 32 bit to use sparse_irq
      x86: make 32bit support per_cpu vector
      x86: add debug info for 32bit sparse_irq
      x86, io-apic: remove union about dest for log/phy
      x86: ordering functions in io_apic_32.c
      x86: ordering functions in io_apic_64.c
      x86: order variables in io_apic_xx.c
      x86: make headers files the same in io_apic_xx.c
      x86: make 64 handle sis_apic_bug like the 32 bit
      x86: remove ioapic_force
      x86: make io_apic_64.c and io_apic_32.c the same
      rename io_apic_64.c and io_apic_32.c to io_apic.c
      io_apic: make 32 bit have io_apic resource in /proc/iomem
      pci: change msi-x vector to 32bit
      x86: irq: interrupt array size should be NR_VECTORS
      x86: unify mask_IO_APIC_irq
      x86: unify ack_apic_edge
      x86: remove first_free_entry/pin_map_size
      x86: print local APIC of APs one by one
      x86: make HAVE_SPARSE_IRQ support selectable
      x86: probe nr_irqs even only mptable is used
      dyn_array: split dyn_array functions from init/main.c
      x86: sparse_irq needs spin_lock in allocations
      x86: fix 32-bit ioapic lockup with sparseirqs
      x86: fix probe_nr_irqs for xen
      x86: apic_xx.c order variables
      x86: use HAVE_X2APIC in apic_64.c
      x86: add hard_smp_prossor_id with MACRO in io_apic_xx.c
      x86: make apic_32/64.c more like
      x86: merge APIC_init_uniprocessor
      x86: copy detect_init_APIC to the other
      x86: merge header files in apic_xx.c
      x86: apic unify smp_spurious/error_interrupt
      x86: apic copy calibrate_APIC_clock to each other in apic_32/64.c
      x86: apic copy apic_64.c to apic_32.c
      x86: rename apic_32.c and apic_64.c to apic.c
      x86: let 64 bit to use 32 bit calibrate_apic_clock
      sparseirq: move kstat_irqs from kstat to irq_desc - fix
      x2apic: fix reserved APIC register accesses in print_local_APIC()
      dmar: fix using early fixmap mapping for DMAR table parsing
      dmar: initialize the return value in dmar_parse_dev()
      x86: print out if acpi want physical flat of all
      dyn_array: fix typo
      irq: error missed ifndef CONFIG_HAVE_SPARSE_IRQ, v2
      dyn_array: remove one panic
      x86: lapic address print out like io apic addr
      x86: print out apic id in hex format
      dyn_array: use %pF instead of print_fn_descriptor_symbol
      irq: fix irqpoll && sparseirq
      sparseirq: remove some debug print out
      x86: fix typo in irq_desc array
      x86: irq no should not use hex in /proc/interrupts
      x86: print out irq nr for msi/ht, v3
      x86: sparse_irq: fix typo in debug print out
      mm: print out meminit for memmap
      PCI: change MSI-x vector to 32bit
      PCI: use %pF instead of print_fn_descriptor_symbol() in quirks.c

Yitchak Gertner (1):
      bnx2x: EEH recovery fix

Yoichi Yuasa (1):
      cs89x0: fix warning release_irq label

Yoshihiro Shimoda (3):
      [MTD] [NAND] sh_flctl: add support for Renesas SuperH FLCTL
      [MTD] [NAND] sh_flctl: fix compile error
      sh: add support FLCTL for ap325rxa board

Yoshinori Sato (4):
      h8300: update timer handler - delete files
      h8300: update timer handler - new files
      h8300: update timer handler - misc update
      h8300: GENERIC_BUG support

Youquan Song (3):
      dmar: context cache and IOTLB invalidation using queued invalidatio=
n
      dmar: Use queued invalidation interface for IOTLB and context inval=
idation
      dmar: remove the quirk which disables dma-remapping when intr-remap=
ping enabled

Yu Zhao (2):
      PCI: support PCIe ARI capability
      PCI: fix AER capability check

Zhang Rui (4):
      ACPI: fix hotplug race
      ACPI: don't enable control method power button as wakeup device whe=
n Fixed Power button is used
      don't load asus-acpi if model is not supported
      ACPI: Allow overriding to higher critical trip point.

Zhang xiantao (1):
      KVM: Device Assignment: Move vtd.c from arch/x86/kvm/ to virt/kvm/

Zhao Yakui (10):
      ACPI: Enable EC device immediately after ACPI full initialization
      ACPI: Add the support for _TTS object
      ACPI: Ignore AE_NOT_FOUND error of EC _REG method and continue to i=
nitialize EC
      ACPI: Ingore the RESET_REG_SUP bit when using ACPI reset mechanism
      ACPI: Get the device power state in the course of scanning device
      ACPI: Attach the ACPI device to the ACPI handle as early as possibl=
e
      ACPI: Add "acpi.power_nocheck=3D1" to disable power state check in =
power transition
      ACPI: Add DMI check to disable power state check in power transitio=
n
      ACPI : Load device driver according to the status of acpi device
      ACPI: hack around sysfs warning with link order

Zhao, Yu (8):
      PCI: fix hotplug get_##name return value problem
      PCI: use same arg names in PCI_VDEVICE comment
      PCI: use resource_size() everywhere.
      PCI: replace cfg space size (256/4096) by macros.
      PCI: centralize the capabilities code in pci-sysfs.c
      PCI: centralize the capabilities code in probe.c
      PCI: fix ARI code to be compatible with mixed ARI/non-ARI systems
      PCI: remove unused resource assignment in pci_read_bridge_bases()

Zhaolei (4):
      ALSA: Fix debugfs_create_dir's error checking method for sound/soc/
      Fix debugfs_create_dir's error checking method for arch/sh/kernel/
      Fix debugfs_create_file's error checking method for arch/sh/mm/
      USB: Fix debugfs_create_file's error checking method for usb/gadget=
/s3c2410_udc

Zhenyu Wang (2):
      drm: Set cliprects to NULL when changing drawable to having 0 clipr=
ects.
      drm: fix leak of cliprects in drm_rmdraw()

Zhu Yi (2):
      iwlwifi: fix compile warning
      iwl3945: add MODULE_FIRMWARE for 3945 HW

akeemting (1):
      jme: Faulty IRQ handle bug fix

akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org (2):
      PCI: ibmphp: list_for_each to list_for_each_entry
      PCI: ibmphp: list_for_each to list_for_each_entry-checkpatch cleanu=
ps

ben-elnMNo+KYs3pIgCt6eIbzw@public.gmane.org (4):
      s3cmci: Make general protocol errors less noisy
      s3cmci: cpufreq support
      s3cmci: fix continual accesses to host->pio_ptr
      s3cmci: Add Ben Dooks/Simtec Electronics to header & copyright

dcg (1):
      x86_64: be less annoying on boot, v2

donald.d.dugger-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org (1):
      ACPI: Fix possible null ptr dereference

fangxiaozhi (1):
      USB: support Huawei data card product IDs

frans (3):
      [MTD] [NAND] nand_ecc.c: rewrite for improved performance
      [MTD] [NAND] nand_ecc.c: fix big endian, strengthen test, add print=
k
      Fix Documentation/filesystems/ramfs-rootfs-initramfs.txt

hermann pitton (1):
      V4L/DVB (9028): saa7134: add support for the triple Asus Tiger 3in1

philipl-tB29R6EoPa3YtjvyW6yDsg@public.gmane.org (1):
      toshiba_acpi: Add support for bluetooth toggling through rfkill (v8=
)

roel kluin (15):
      ALSA: au88x0: clipping ceiling loop wrong in comment
      iwl-4965: test below 0 on unsigned num_tbs
      ibm_newemac: MAL[12]_IER_EVENTS definition: 2x *_OTE -> *_DE
      sh: intc_prio_data() test before subtraction on unsigned
      sh_eth: unsigned ndev->irq cannot be negative
      rtc-sh: Unsigned rtc->{periodic,carry,alarm}_irq cannot be negative
      powerpc: Fix duplicate test of MACIO_FLAG_SCCB_ON
      V4L/DVB: pxa-camera: Unsigned dma_chans[] cannot be negative
      KVM: x86 emulator: remove duplicate SrcImm
      Altix serial: fix
      powerpc: Unsigned speed cannot be negative in udbg_16559.c
      x86: make variables static
      gianfar: fix handle errors returned by platform_get_irq*()
      AX88796: ax_probe() fix irq assignment
      USB: usbtest.c: length, sglen and vary are unsigned, so cannot be n=
egative

roelkluin (1):
      [ARM] 5303/1: period_cycles should be greater than 1

scameron-3C9H9nn4BS5stOSx8vMUiLIexByqKVI1@public.gmane.org (1):
      cciss: Fix cciss SCSI rescan code to better notice device changes

thomas schorpp (1):
      [SCSI] aic7xxx: Take the LED out of diagnostic mode on PM resume

vdb128-Vz2JLU6dtblAfugRpC6u6w@public.gmane.org (1):
      V4L/DVB (8896): pvrusb2: Implement crop support

venkatesh.pallipadi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org (11):
      x86: PAT documentation updates with debug info
      [CPUFREQ][1/6] cpufreq: Add cpu number parameter to __cpufreq_drive=
r_getavg()
      [CPUFREQ][2/6] cpufreq: Change load calculation in ondemand for sof=
tware coordination
      [CPUFREQ][3/6] cpufreq: get_cpu_idle_time() changes in ondemand for=
 idle-microaccounting
      [CPUFREQ][4/6] cpufreq_ondemand: Parameterize down differential
      [CPUFREQ][5/6] cpufreq: Changes to get_cpu_idle_time_us(), used by =
ondemand governor
      [CPUFREQ][6/6] cpufreq: Add idle microaccounting in ondemand govern=
or
      x86: HPET_MSI change IRQ affinity in process context when it is dis=
abled
      x86: HPET_MSI Refactor code in preparation for HPET_MSI
      x86: HPET_MSI Basic HPET_MSI setup code
      x86: HPET_MSI Initialise per-cpu HPET timers

xiphmont-zeIfkxP3e/s@public.gmane.org (1):
      SG_IO block filter whitelist missing MMC SET READ AHEAD command

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr

--===============0128749111745310389==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============0128749111745310389==--
