From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr annotated tag, v2.6.29-rc5, created. v2.6.29-rc5
Date: Wed, 16 Sep 2009 14:36:42 -0400
Message-ID: <200909161836.n8GIagSA001278@gorgona.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7586253633208077940=="
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

--===============7586253633208077940==
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by smtp1.linux-foundation.org id n8GIuEQk005420

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The annotated tag, v2.6.29-rc5 has been created
        at  1dcda2df87ba4ecc7988be7a45d01645e11c9f4c (tag)
   tagging  d2f8d7ee1a9b4650b4e43325b321801264f7c37a (commit)
  replaces  v2.6.29-rc4
 tagged by  Linus Torvalds
        on  Fri Feb 13 15:31:30 2009 -0800

- Log -----------------------------------------------------------------
Linux 2.6.29-rc5

Woo! Partee!
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkmVrMAACgkQF3YsRnbiHLs3oQCgq7YnL5LatcEEItokYKKe7Whp
LJoAoLWXTNk/Lt54CUqMhg7/7fiDW9Za
=3DJvsA
-----END PGP SIGNATURE-----

Adrian-Ken Rueegsegger (1):
      crypto: shash - Fix module refcount

Alan Stern (2):
      USB: usb-storage: remove WARN from last-sector hacks
      USB: usb-storage: add Pentax to the bad-vendor list

Alex Chiang (1):
      x86: fix grammar in user-visible BIOS warning

Alex Williamson (1):
      tun: Fix unicast filter overflow

Alok Kataria (1):
      x86, vmi: put a missing paravirt_release_pmd in pgd_dtor

Ananth N Mavinakayanahalli (1):
      powerpc: Don't emulate mr. instructions

Andres Salomon (2):
      gxfb: properly alloc cmap and plug cmap leak
      gx1fb: properly alloc cmap and plug cmap leak

Andrew Morton (2):
      net: don't use in_atomic() in gfp_any()
      Documentation/connector/cn_test.c: don't use gfp_any()

Anton Vorontsov (8):
      powerpc/83xx: Fix missing #{address,size}-cells in mpc8313erdb.dts
      powerpc/83xx: Fix TSEC0 workability on MPC8313E-RDB boards
      USB: fsl_qe_udc: Fix oops on QE UDC probe failure
      USB: fsl_qe_udc: Fix recursive locking bug in ch9getstatus()
      USB: fsl_qe_udc: Fix QE USB controller initialization
      USB: fsl_qe_udc: Fix disconnects reporting during bus reset
      USB: fsl_qe_udc: Fix muram corruption by disabled endpoints
      USB: fsl_qe_udc: Fix stalled TX requests bug

Arnd Bergmann (1):
      sound: Remove OSSlib stuff from linux/soundcard.h

Arve Hj=C3=B8nnev=C3=A5g (1):
      Staging: android: ram_console: Disable ECC when early init is enabl=
ed and validate buffer size

Balaji Rao (1):
      pcf50633_charger: Fix typo

Benjamin Herrenschmidt (1):
      powerpc/pci: mmap anonymous memory when legacy_mem doesn't exist

Bob Copeland (1):
      ath5k: fix bf->skb=3D=3DNULL panic in ath5k_tasklet_rx

Borislav Petkov (1):
      x86/Kconfig.cpu: make Kconfig help readable in the console

Carsten Otte (1):
      ext2/xip: refuse to change xip flag during remount with busy inodes

Chris Mason (1):
      Btrfs: don't use spin_is_contended

Chris Wilson (2):
      drm/i915: Unref the object after failing to set tiling mode.
      drm/i915: Unlock mutex on i915_gem_fault() error path

Chuck Ebbert (1):
      pkt_sched: type should be __u32 in header

Clemens Ladisch (1):
      i8327: fix outb() parameter order

Cl=C3=A9ment Lecigne (1):
      net: 4 bytes kernel memory disclosure in SO_BSDCOMPAT gsopt try #2

Cornelia Huck (1):
      [S390] dasd: bus_id -> dev_name() conversion.

Daisuke Nishimura (1):
      migration: migrate_vmas should check "vma"

Dan Carpenter (1):
      USB: ftdi_sio: unlock_kernel() on error in set_serial_info()

Dave Airlie (2):
      i915: fix unneeded locking in i915 LVDS get modes code.
      drm/radeon: fix ioremap conflict with AGP mappings

Dave Young (1):
      USB: usb-serial: fix the aircable_init failure path

David Howells (2):
      RxRPC: Fix a potential NULL dereference
      FRV: in_interrupt() requires #inclusion of linux/hardirq.h not asm/=
hardirq.h now

David S. Miller (7):
      sparc64: Call dump_stack() in die_nmi().
      sparc64: Don't hook up pcr_ops on spitfire chips.
      ipv6: Disallow rediculious flowlabel option sizes.
      net_dma: call dmaengine_get only if NET_DMA enabled
      sunhme: Don't match PCI devices in SBUS probe.
      sparc64: Kill .fixup section bloat.
      sparc64: Fix probe_kernel_{read,write}().

Dhananjay Phadke (2):
      netxen: fix msi-x interrupt handling
      netxen: remove pcie workaround

Dirk De Schepper (1):
      USB: option: New mobile broadband modems to be supported

Eero Nurkkala (1):
      ASoC: TLV320AIC3X: Fix kcontrol's private value use in put callback

Eric Anholt (5):
      drm/i915: Suppress GEM teardown on X Server exit in KMS mode.
      drm/i915: Skip SDVO/HDMI init when the chipset tells us it's not pr=
esent.
      drm/i915: Set up an MTRR covering the GTT at driver load.
      drm/i915: Return error from i915_gem_object_get_fence_reg() when fa=
iling.
      drm/i915: Quiet the message on get/setparam ioctl with an unknown v=
alue.

Eric Leblond (2):
      netfilter: fix tuple inversion for Node information request
      netfilter: nf_conntrack_ipv6: don't track ICMPv6 negotiation messag=
e

Eric Miao (3):
      [ARM] pxa: fix missing of __REG() definition for ac97 registers acc=
ess
      [ARM] pxa: make more SSCR0 bit definitions visible on multiple proc=
essors
      [ARM] pxa: stop and disable IRQ for each DMA channels at startup

Eric Van Hensbergen (1):
      9p: fix endian issues [attempt 3]

Federico Cuello (1):
      writeback: fix break condition

Gautam Kachroo (1):
      neigh: some entries can be skipped during dumping

Greg Kroah-Hartman (3):
      Revert USB: option: add Pantech cards
      Revert Staging: at76_usb: update drivers/staging/at76_usb w/ mac802=
11 port
      Staging: android: fix up units in timed_gpio

Heiko Carstens (1):
      syscall define: fix uml compile bug

Herbert Xu (5):
      crypto: api - Fix algorithm test race that broke aead initialisatio=
n
      crypto: api - Fix zeroing on free
      crypto: shash - Fix tfm destruction
      crypto: scatterwalk - Avoid flush_dcache_page on slab pages
      bridge: Fix LRO crash with tun

Herton Ronaldo Krzesinski (1):
      ALSA: hda - Change HP dv7 (103c:30f4) quirk from hp-m4 to hp-dv5 mo=
del

Hin-Tak Leung (2):
      zd1211rw: adding 0ace:0xa211 as a ZD1211 device
      zd1211rw: treat MAXIM_NEW_RF(0x08) as UW2453_RF(0x09) for TP-Link W=
N322/422G

Hugh Dickins (2):
      mm: fix error case in mlock downgrade reversion
      profiling: fix broken profiling regression

Ian Dall (1):
      w1: w1 temp calculation overflow fix

Ilkka Virta (1):
      sungem: Soft lockup in sungem on Netra AC200 when switching interfa=
ce up

Inaky Perez-Gonzalez (1):
      wimax: fix oops in wimax_dev_get_by_genl_info() when looking up non=
-wimax iface

Ingo Molnar (4):
      Merge branch 'sched/urgent' into timers/urgent
      timers: split process wide cpu clocks/timers, remove spurious warni=
ng
      drm/i915: select framebuffer support automatically
      Merge branch 'tip/tracing/urgent' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/rostedt/linux-2.6-trace into tracing/urgent

Ivan Kuten (1):
      USB: Correct Makefile to make isp1760 buildable

Ivan Vecera (1):
      r8169: Don't update statistics counters when interface is down

J. Bruce Fields (1):
      lockd: fix regression in lockd's handling of blocked locks

James Treacy (1):
      USB: cdc-acm.c: remove duplicate lines for MTK gps support

Jamie Lentin (1):
      Staging: at76_usb: Add support for OQO Model 01+

Jan Kara (2):
      jbd: fix return value of journal_start_commit()
      ext3: revert "ext3: wait on all pending commits in ext3_sync_fs"

Jarek Poplawski (1):
      gianfar: Fix boot hangs while bringing up gianfar ethernet

Jarkko Nikula (1):
      ASoC: WM8990: Fix kcontrol's private value use in put callback

Jason Andryuk (1):
      Staging: at76_usb: fix bugs introduced by "Staging: at76_usb: clean=
up dma on stack issues"

Jeremy Fitzhardinge (2):
      x86: don't apply __supported_pte_mask to non-present ptes
      mm: rearrange exit_mmap() to unlock before arch_exit_mmap

Jesper Dangaard Brouer (1):
      udp: Fix potential wrong ip_hdr(skb) pointers

Jesse Barnes (4):
      drm/i915: add fence register management to execbuf
      drm/i915: sync SDVO code with stable userland modesetting driver
      drm/i915: capture last_vblank count at IRQ uninstall time too
      drm/i915: add get_vblank_counter function for GM45

Jiri Slaby (1):
      parport: parport_serial, don't bind netmos ibm 0299

Johannes Berg (1):
      mac80211: restrict to AP in outgoing interface heuristic

Julia Lawall (3):
      arch/powerpc: Eliminate double sizeof
      drivers/atm: introduce missing kfree
      drivers/isdn: introduce missing kfree

KAMEZAWA Hiroyuki (1):
      memcg: use __GFP_NOWARN in page cgroup allocation

KOSAKI Motohiro (1):
      cgroups: add Li Zefan as a maintainer

Kirill A. Shutemov (1):
      mm: Export symbol ksize()

Kumar Gala (2):
      powerpc/fsl-booke: Fix mapping functions to use phys_addr_t
      powerpc/mm: Fix _PAGE_COHERENT support on classic ppc32 HW

Kyle McMartin (3):
      x86, 64-bit: print DMI info in the oops trace
      x86: disable intel_iommu support by default
      x86: spinlocks: define dummy __raw_spin_is_contended

Li Zefan (1):
      cgroups: fix lockdep subclasses overflow

Linus Torvalds (23):
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/herbert/crypto-=
2.6
      Merge branch 'drm-fixes' of git://git.kernel.org/pub/scm/linux/kern=
el/git/airlied/drm-2.6
      i915: Fix more size_t format string warnings
      Merge branch 'for-2.6.29' of git://linux-nfs.org/~bfields/linux
      Merge branch 'fixes' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/davej/cpufreq
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging-=
2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/usb-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/mason/btrfs-uns=
table
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-2.6
      Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/benh/powerpc
      Merge master.kernel.org:/home/rmk/linux-2.6-arm
      Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/benh/powerpc
      Merge branch 'for-linus' of git://git390.marist.edu/pub/scm/linux-2=
.6
      Merge branch 'tracing-fixes-for-linus' of git://git.kernel.org/pub/=
scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'timers-fixes-for-linus' of git://git.kernel.org/pub/s=
cm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'sched-fixes-for-linus' of git://git.kernel.org/pub/sc=
m/linux/kernel/git/tip/linux-2.6-tip
      Merge git://git.infradead.org/users/cbou/battery-2.6.29
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/penberg/slab-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Linux 2.6.29-rc5

Lopez Cruz, Misael (1):
      ASoC: Update SDP3430 machine driver for snd_soc_card

Mackenzie Morgan (1):
      ALSA: hda - Add quirk for Asus z37e (1043:8284)

Marcel Selhorst (1):
      tpm: correct email address for tpm_infineon-driver

Marco La Porta (1):
      lxfb: properly alloc cmap in all cases and don't leak the memory

Mark Brown (1):
      ASoC: Only register AC97 bus if it's not done already

Mark Langsdorf (1):
      [CPUFREQ] powernow-k8: Get transition latency from ACPI _PSS table

Martin Schwidefsky (2):
      [S390] vdso: fix per cpu vdso pointer in lowcore
      [S390] Update default configuration.

Meelis Roos (2):
      fore200: fix oops on failed firmware load
      sunhme: Fix Quattro HME irq registration on proble failures

Mel Gorman (2):
      Do not account for the address space used by hugetlbfs using VM_ACC=
OUNT
      Do not account for hugetlbfs quota at mmap() time if mapping [SHM|M=
AP]_NORESERVE

Michael Chan (4):
      bnx2: Update 5706/5708 firmware.
      bnx2: Update 5709 firmware.
      bnx2: Fix jumbo frames error handling.
      bnx2: Update version to 1.9.2 and copyright.

Michael Neuling (3):
      powerpc/83xx: Build breakage for CONFIG_PM but no CONFIG_SUSPEND
      powerpc/cell: Add missing #include for oprofile
      powerpc: Add missing sparsemem.h include

Mike Rapoport (1):
      [ARM] pxa: fix NAND and MMC clock initialization for pxa3xx

MinChan Kim (1):
      mm: fix mlocked page counter mismatch

Nick Holloway (1):
      USB: Storage: Update unusual_devs entry for Datafab KECF-USB

Nick Piggin (1):
      Fix page writeback thinko, causing Berkeley DB slowdown

Noriaki TAKAMIYA (1):
      IPv6: fix to set device name when new IPv6 over IPv6 tunnel device =
is created.

Oleg Nesterov (1):
      ptrace, x86: fix the usage of ptrace_fork()

Oliver Neukum (1):
      USB: two more usb ids for ti_usb_3410_5052

Ondrej Zary (1):
      3c509: Fix resume from hibernation for PnP mode.

Pablo Neira Ayuso (2):
      netfilter: ctnetlink: allow changing NAT sequence adjustment in cre=
ation
      netfilter: ctnetlink: fix echo if not subscribed to any multicast g=
roup

Pallipadi, Venkatesh (1):
      x86: add clflush before monitor for Intel 7400 series

Paul Clements (1):
      nbd: fix I/O hang on disconnected nbds

Paul Collins (1):
      drm/i915: skip LVDS initialization on Apple Mac Mini

Paulius Zaleckas (1):
      mdio-gpio: Add mdc pin direction initialization

Pavel Emelyanov (2):
      x86: fix hpet timer reinit for x86_64
      x86: clean up hpet timer reinit

Peter Zijlstra (5):
      signal: re-add dead task accumulation stats.
      timers: split process wide cpu clocks/timers
      timers: split process wide cpu clocks/timers, fix
      timers: fix TIMER_ABSTIME for process wide cpu timers
      sched: revert recent sync wakeup changes

Qu Haoran (1):
      netfilter: xt_sctp: sctp chunk mapping doesn't work

Randy Dunlap (2):
      kernel-doc: preferred ending marker and examples
      kernel-doc: fix syscall wrapper processing

Reinette Chatre (1):
      iwlwifi: fix suspend/resume and its usage of pci saved state

Risto Suominen (1):
      de2104x: force correct order when writing to rx ring

Robert Jarzmik (1):
      rtc: update maintainership of pxa rtc driver

Roel Kluin (6):
      [ARM] AACI: timeout will reach -1
      rtc: t reaches -1, tested 0
      TG3: limit reaches -1
      sun3: print when lance_open() fails
      IRDA: cnt is off by 1
      3c505: do not set pcb->data.raw beyond its size

Ron Mercer (7):
      qlge: bugfix: Use netif_receive_skb() and vlan_hwaccel_receive_skb(=
).
      qlge: bugfix: Fix fatal error recovery hang.
      qlge: bugfix: Add missing put_page() call.
      qlge: bugfix: Add missing dev_kfree_skb_any() call.
      qlge: bugfix: Fix TSO breakage.
      qlge: bugfix: Fix RX scaling values.
      qlge: bugfix: Add missing rx buf clean index on early exit.

Russell King (1):
      Merge branch 'fix' of git://git.kernel.org/pub/scm/linux/kernel/git=
/ycmiao/pxa-linux-2.6

R=C3=A9mi Denis-Courmont (2):
      Phonet: fix double free in GPRS outbound packet error path
      Phonet: do not compute unused value

Sachin P. Sant (1):
      Staging: panel: fix lcd panel driver build failure

Sachin Sant (1):
      [S390] Fix init irq proc build break.

Serge E. Hallyn (1):
      User namespaces: Only put the userns when we unhash the uid

Stefan Richter (1):
      hugetlbfs: fix build failure with !CONFIG_HUGETLBFS

Stefan Weinhuber (1):
      [S390] dasd: fix race in dasd timer handling

Stephane Clerambault (1):
      USB: ftdi_sio: add support for the NDI Polaris system

Steven Rostedt (3):
      powerpc/ftrace: Fix math to calculate offset in TOC
      tracing, x86: fix fixup section to return to original code
      tracing, x86: fix constraint for parent variable

Suresh Siddha (1):
      sched: fix nohz load balancer on cpu offline

Sven Wegener (1):
      mm: fix dirty_bytes/dirty_background_bytes sysctls on 64bit arches

Takashi Iwai (8):
      ALSA: mtpav - Fix initial value for input hwport
      ALSA: hda - Register (new) devices at reconfig
      ALSA: hda - Add missing terminator in slave dig-out array
      ALSA: hda - Add snd_hda_multi_out_dig_cleanup()
      Merge branch 'fix/oss-header-fix' into for-linus
      Merge branch 'fix/misc' into for-linus
      Merge branch 'fix/hda' into for-linus
      Merge branch 'fix/asoc' into for-linus

Tejun Heo (3):
      x86: include correct %gs in a.out core dump
      x86: math_emu info cleanup
      x86: fix math_emu register frame access

Tobias Klauser (1):
      [ARM] Storage class should be before const qualifier

Uwe Kleine-Koenig (1):
      video/framebuffer: move the probe func into .devinit.text in Blackf=
in LCD driver

Venkatesh Pallipadi (1):
      [CPUFREQ] Make ignore_nice_load setting of ondemand work as expecte=
d.

Wu Fengguang (4):
      ALSA: hda - allow multi-channel HDMI audio playback when ELD is not=
 present
      ALSA: hda - enable HDMI audio pin out at module loading time
      ALSA: hda - compute checksum in HDMI audio infoframe
      ALSA: hda - add id for Intel IbexPeak integrated HDMI codec

Yang Hongyang (1):
      netxen: fix compile waring "label =E2=80=98set_32_bit_mask=E2=80=99=
 defined but not used" on IA64 platform

Yinghai Lu (1):
      x86: find nr_irqs_gsi with mp_ioapic_routing

paulfax (1):
      powerpc/cpm2: Fix set interrupt type

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr

--===============7586253633208077940==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============7586253633208077940==--
