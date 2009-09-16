From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr annotated tag, v2.6.28-rc3, created. v2.6.28-rc3
Date: Wed, 16 Sep 2009 14:36:30 -0400
Message-ID: <200909161836.n8GIaUfv001021@gorgona.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1067186824955991619=="
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

--===============1067186824955991619==
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by smtp1.linux-foundation.org id n8GJMRMa008412

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The annotated tag, v2.6.28-rc3 has been created
        at  31cb515c75388d457c2f318a0ee9606b3527852f (tag)
   tagging  45beca08dd8b6d6a65c5ffd730af2eac7a2c7a03 (commit)
  replaces  v2.6.28-rc2
 tagged by  Linus Torvalds
        on  Sun Nov 2 14:17:33 2008 -0800

- Log -----------------------------------------------------------------
Linux 2.6.28-rc3
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkkOJwkACgkQF3YsRnbiHLvUnwCffXcoCqStD83rV+DTCdtF2rjj
wE0An3zHo1lP4ig/03dbN3km0XXyT1i4
=3DPU+D
-----END PGP SIGNATURE-----

Adrian Bunk (1):
      MIPS: RB532: Fix build error

Al Viro (8):
      saner FASYNC handling on file close
      oss: fix O_NONBLOCK in dmasound_core
      PM_TEST_SUSPEND should depend on RTC_CLASS, not RTC_LIB
      section fixes for cirrusfb
      missing dependencies on HAVE_CLK in drivers/mfd
      el3_common_init() should be __devinit, not __init
      sparc32: kernel/trace/trace.c wants DIE_OOPS
      sparc32: kernel/trace/trace.c wants DIE_OOPS

Alan Cox (13):
      pcmcia: IRQ_TYPE_EXCLUSIVE is long obsoleted
      pcmcia: Whine harder about use of EXCLUSIVE
      fdomain_cs: Sort out modules with duplicate description
      sound: use a common working email address
      Tidy up addresses in random drivers
      Switch to a valid email address...
      ata: Switch all my stuff to a common address
      pata_ninja32: suspend/resume support
      Switch all my contributions stuff to a single common address
      Rationalise Randy's address a bit
      nfsd: fix vm overcommit crash
      tty: Fix USB kref leak
      ide: Switch to a common address

Alan Jenkins (2):
      tracing/fastboot: fix bootgraph.pl to run with "use strict"
      tracing/fastboot: fix row order in bootgraph.pl

Alan Stern (3):
      USB: fix crash when URBs are unlinked after the device is gone
      USB: prevent autosuspend during hub initialization
      HID: add quirk entry for no-name keyboard (0x13ba/0x0017)

Alexander Beregalov (1):
      IRDA: remove double inclusion of module.h

Alexey Dobriyan (5):
      .gitignore updates
      init/do_mounts_md.c: msleep compile fix
      netns: add register_pernet_gen_subsys/unregister_pernet_gen_subsys
      netfilter: nf_conntrack_proto_gre: switch to register_pernet_gen_su=
bsys()
      key: fix setkey(8) policy set breakage

Andi Kleen (2):
      HID: Remove "default m" for Thrustmaster and Zeroplus
      sysfs: Fix return values for sysdev_store_{ulong,int}

Andreas Schwab (1):
      HID: fix hid_device_id for cross compiling

Andy Gospodarek (1):
      bonding: fix panic when taking bond interface down before removing =
module

Arjan Opmeer (1):
      Input: psmouse - add support for Elantech touchpads

Arjan van de Ven (2):
      pci: use pci_ioremap_bar() in sound/
      [WATCHDOG] pci: use pci_ioremap_bar() in drivers/watchdog

Ashutosh Naik (1):
      kbuild: prevent modpost from looking for a .cmd file for a static l=
ibrary linked into a module

Atsushi Nemoto (9):
      MIPS: Set positive error number to errno on illegal_syscall
      MIPS: Set ENOSYS to errno on illegal system call number for syscall=
(2)
      MIPS: TXx9: 7 segment LED support
      MIPS: RBTX4939: Add smc91x support
      MIPS: TXx9: Fix RBTX4939 ethernet address initialization
      MIPS: RBTX4927: Add GPIO-LED support
      tx4938ide: Check minimum cycle time and SHWT range (v2)
      tx4938ide: Do not call devm_ioremap for whole 128KB
      tx4938ide: Avoid underflow on calculation of a wait cycle

Avi Kivity (1):
      KVM: Future-proof device assignment ABI

Bastien Nocera (1):
      ALSA: intel8x0 - add Dell Optiplex GX620 (AD1981B) to AC97 clock wh=
itelist

Benjamin Herrenschmidt (2):
      edac: fix enabling of polling cell module
      powerpc/pci: Fix unmapping of IO space on 64-bit

Bob Copeland (3):
      ath5k: correct misspelling in debug help
      ath5k: honor FIF_BCN_PRBRESP_PROMISC in STA mode
      ath5k: add self to MAINTAINERS

Borislav Petkov (2):
      ide-cd: fix DMA alignment regression
      ide-gd: re-get capacity on revalidate

Brice Goglin (1):
      myri10ge: fix stop/go mmio ordering

Carl Love (1):
      powerpc/cell/OProfile: Fix on-stack array size in activate spu prof=
iling function

Chris Friesen (1):
      amd8111e: Fix rx return code

Chris Lalancette (1):
      xen: fix Xen domU boot with batched mprotect

Chris Malley (1):
      USB: usbtmc: Use explicit unsigned type for input buffer instead of=
 char*

Christian Borntraeger (2):
      [S390] pgtables: Fix race in enable_sie vs. page table ops
      [S390] s390: Fix build for !CONFIG_S390_GUEST + CONFIG_VIRTIO_CONSO=
LE

Christian Lamparter (2):
      p54: fix misbehavings when firmware can't be found
      p54: fix build warnings

Chuck Lever (1):
      NLM: Set address family before calling nlm_host_rebooted()

Chunbo Luo (1):
      amd8111e: fix dma_free_coherent context

Cliff Cai (1):
      ALSA: ASoC: Blackfin: update SPORT0 port selector (v2)

Cliff Wickman (1):
      x86/uv: memory allocation at initialization

Dan Nicholson (1):
      Revert "HID: Invert HWHEEL mappings for some Logitech mice"

Dan Williams (1):
      [ARM] xsc3: revert writethrough memory-type encoding change

Daniel Laird (1):
      MIPS: Add support for NXP PNX833x (STB222/5) into linux kernel

Darius Augulis (1):
      [ARM] MXC: Fix mxc_gpio_get(), which must read PSR register instead=
 DR.

David Brownell (1):
      at91_ether: request/free GPIO for PHY interrupt

David Daney (3):
      MIPS: Don't unmap the memory for dma_sync*.
      MIPS: Fix KGDB build error
      MIPS: Consider value of c0_ebase when computing value of exception =
base.

David Gibson (1):
      powerpc: Fix bug in kernel copy of libfdt's fdt_subnode_offset_name=
len()

David Milburn (2):
      libata: ahci enclosure management led sync
      libata: ahci enclosure management bit mask

David S. Miller (8):
      Merge branch 'davem-fixes' of master.kernel.org:/pub/scm/linux/kern=
el/git/jgarzik/netdev-2.6
      sparc64: Add missing null terminating entry to bq4802_match[].
      pppoe: Fix socket leak.
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-2.6
      Merge branch 'davem-fixes' of master.kernel.org:/pub/scm/linux/kern=
el/git/jgarzik/netdev-2.6
      Merge branch 'master' of git://git.infradead.org/users/pcmoore/lbln=
et-2.6
      net: Really remove all of LOOPBACK_TSO code.
      sparc64: Kill annoying warning when building compat_binfmt_elf.o

David Vrabel (1):
      uwb: build UWB before USB/WUSB

Dean Nelson (1):
      sgi-xp: only build for ia64-sn2 when CONFIG_IA64_GENERIC specified

Dmitri Vorobiev (2):
      MIPS: IP22: Small cleanups
      INPUT: sgi_btns: Add license specification

Dmitry Baryshkov (4):
      RFKILL: fix input layer initialisation
      [ARM] pxa/spitz: fix spi cs on spitz
      [ARM] corgi_lcd: fix simultaneous compilation with corgi_bl
      [ARM] sharpsl_pm: fix compilation w/o CONFIG_PM

Elias Oltmanns (2):
      ath5k: Reset key cache on interface up, thus fixing resume
      ath5k: Fix reset sequence for AR5212 in general and RF5111 in parti=
cular

Eric Dumazet (1):
      udp: multicast packets need to check namespace

Eric Miao (1):
      leds: da903x: fix the building failure of incomplete type of 'work'

Eric Paris (1):
      SELinux: properly handle empty tty_files list

Eric Sandeen (3):
      merge ext4_claim_free_blocks & ext4_has_free_blocks
      delay capable() check in ext4_has_free_blocks()
      ecryptfs: fix memory corruption when storing crypto info in xattrs

Evgeniy Manachkin (1):
      kbuild: mkspec - fix build rpm

FUJITA Tomonori (5):
      swiotlb: remove panic for alloc_coherent failure
      x86: use GFP_DMA for 24bit coherent_dma_mask
      x86: restore the old swiotlb alloc_coherent behavior
      dmfe: check pci_alloc_consistent errors
      dbri: check dma_alloc_coherent errors

Fenghua Yu (1):
      x86/PCI: build failure at x86/kernel/pci-dma.c with !CONFIG_PCI

Fernando Luis Vazquez Cao (1):
      spi: fix compile error

Florian Fainelli (1):
      MIPS: RB532: Set gpio interrupt status and level for CompactFlash

Florian Westphal (1):
      syncookies: fix inclusion of tcp options in syn-ack

Frank Blaschka (2):
      qeth: fix offset error in non prealloc header path
      qeth: remove unnecessary support ckeck in sysfs route6

Frank Munzert (2):
      [S390] tape block: complete request with correct locking
      [S390] tape: disable interrupts in tape_open and tape_release

Frederic Weisbecker (4):
      tracepoint: check if the probe has been registered
      tracing/ftrace: make boot tracer select the sched_switch tracer
      tracing: fix a build error on alpha
      ftrace: perform an initialization for ftrace to enable it

Gary Hade (1):
      x86: remove debug code from arch_add_memory()

Geert Uytterhoeven (3):
      MIPS: TXx9: CONFIG_TOSHIBA_RBTX4939 spelling
      MIPS: TXx9: Make firmware parameter passing more robust
      rtc: ds3234 doesn't link when built-in

Greg Kroah-Hartman (1):
      Document kernel taint flags properly

Guennadi Liakhovetski (1):
      powerpc: fix i2c on PPC linkstation / kurobox machines

Guillem Jover (1):
      ACPI: Always report a sync event after a lid state change

Hans Ulrich Niedermann (1):
      docbook: fix command spacing

Harvey Harrison (6):
      x86: two trivial sparse annotations
      x86: start annotating early ioremap pointers with __iomem
      sparc64: remove byteshifting from out* helpers
      sparc: use the new byteorder headers
      MIPS: Use the new byteorder headers
      sh: use the new byteorder headers.

Heiko Carstens (4):
      [S390] Fix sysdev class file creation.
      [S390] Change default IPL method to IPL_VM.
      [S390] No more 4kb stacks.
      lockdep: fix irqs on/off ip tracing

Hidehiro Kawai (2):
      ext3: fix a bug accessing freed memory in ext3_abort
      ext4: fix a bug accessing freed memory in ext4_abort

Hitoshi Mitake (1):
      edac x38: new MC driver module

Holger Schurig (1):
      libertas: remove two libertas sparse warning

Huang Weiyi (4):
      mlx4_en: remove duplicated #include
      viafb: removed duplicated #include's
      remove unused #include <version.h>'s
      init/do_mounts_md.c: remove duplicated #include

Hugh Dickins (1):
      sparc64: Fix __copy_{to,from}_user_inatomic defines.

Ian Campbell (1):
      kbuild: do not include arch/<ARCH>/include/asm in find-sources twic=
e.

Ilpo Jarvinen (1):
      dm raid1: fix do_failures

Ilpo J=C3=A4rvinen (2):
      ALSA: sound/ice1712: indentation & braces disagree - add braces
      bpa10x: free sk_buff with kfree_skb

Ingo Molnar (8):
      Merge branch 'linus' into tracing-v28-for-linus-v3
      Merge branch 'tracing/ftrace' into tracing/urgent
      ftrace: fix build failure
      Merge commit 'v2.6.28-rc1' into sched/urgent
      ftrace: warning in kernel/trace/ftrace.c
      Merge commit 'v2.6.28-rc2' into tracing/urgent
      x86: cpu_index build fix
      x86: build fix

Isaku Yamahata (2):
      xen: portability clean up and some minor clean up for xencomm.c
      xen: compilation fix of drivers/xen/events.c on IA64

Ivo van Doorn (1):
      rt2x00: Fix build error when mac80211=3DM rt2x00=3DY

J. Bruce Fields (1):
      nfsd: fix failure to set eof in readdir in some situations

James Bottomley (5):
      x86/voyager: fix boot breakage caused by x86: boot secondary cpus t=
hrough initial_code
      x86: use CONFIG_X86_SMP instead of CONFIG_SMP
      x86/voyager: fix compile breakage casued by x86: move prefill_possi=
ble_map calling early
      x86/voyager: fix compile breakage caused by dc1e35c6e95e8923cf1d351=
0438b63c600fee1e2
      x86/voyager: fix missing cpu_index initialisation

Jan Beulich (2):
      adjust init section definitions
      i386/PAE: fix pud_page()

Jan Glauber (2):
      [S390] qdio: prevent double qdio shutdown in case of I/O errors
      [S390] qdio: remove incorrect memset

Jason Baron (1):
      Driver core: fix 'dynamic_debug' cmd line parameter

Jay Cliburn (1):
      atl1: fix vlan tag regression

Jay Fenlason (4):
      firewire: Survive more than 256 bus resets
      firewire: fix struct fw_node memory leak
      firewire: fw-ohci: don't leak dma memory on module removal
      firewire: fw-sbp2: fix races

Jay Vosburgh (2):
      bonding: fix miimon failure counter
      bonding: Clean up resource leaks

Jean Delvare (1):
      i2c: The i2c mailing list is moving

Jeff Garzik (2):
      drivers/net/wan/syncppp: Fix unused-var warnings
      linux/string.h: fix comment typo

Jens Axboe (3):
      scsi: make sure that scsi_init_shared_tag_map() doesn't overwrite e=
xisting map
      libata: fix NCQ devices behind port multipliers
      libata: add whitelist for devices with known good pata-sata bridges

Jens Taprogge (1):
      USB: Unusual dev for the "Kyocera / Contax SL300R T*" digital camer=
a.

Jeremy Fitzhardinge (1):
      xen: don't reload cr3 on suspend

Jeremy Huntwork (1):
      Fix incompatibility with versions of Perl less than 5.6.0

Jeremy Kerr (2):
      scripts/package: don't break if %{_smp_mflags} isn't set
      OF-device: Don't overwrite numa_node in device registration

Jesper Nilsson (5):
      [CRISv32] Remove warning in io.h
      Merge branch 'for-next' of git://www.jni.nu/cris into cris_merge
      [CRIS] Move header files from include to arch/cris/include.
      [CRIS] Merge asm-offsets.c for both arches into one file.
      [CRIS] Remove links from CRIS build

Jesse Brandeburg (1):
      pktgen: fix multiple queue warning

Jianjun Kong (1):
      af_unix: netns: fix problem of return value

Jiri Kosina (4):
      HID: add support for another Gyration remote control
      HID: quirk for OLED devices present in ASUS G50/G70/G71
      HID: Add support for Sony Vaio VGX-TP1E
      sched: fix documentation reference for sched_min_granularity_ns

Jiri Pirko (1):
      docs: fix ManagementStyle book name

Jiri Slaby (7):
      HID: fix hidraw_exit section mismatch
      HID: add hid_type to general hid struct
      HID: fix hidbus/appletouch device binding regression
      HID: fix lock imbalance in hidraw
      HID: fix lock imbalance in hiddev
      HID: fix oops during suspend of unbound HID devices
      HID: sync on deleted io_retry timer in usbhid driver

Joerg Roedel (1):
      x86, gart: fix gart detection for Fam11h CPUs

Johannes Berg (1):
      libertas: fix buffer overrun

John W. Linville (1):
      mac80211: correct warnings in minstrel rate control algorithm

Jon Smirl (2):
      ALSA: ASoC: Fix some minor errors in mpc5200 psc i2s driver
      powerpc: Fix format string warning in arch/powerpc/boot/main.c

Jonas Bonn (1):
      asm-generic: define DIE_OOPS in asm-generic

Jonathan Cameron (2):
      leds: da903x: (da9030 only) led brightness reversed.
      regulator: da903x regulator bug fix

Josh Boyer (5):
      ibm_newemac: Fix typo in flow control config option
      powerpc/40x: Don't enable HCU4 board by default
      Update stable tree documentation
      powerpc/40x: Update 40x defconfigs
      powerpc/44x: Update 44x defconfigs

Julia Lawall (1):
      i2c-s3c2410: Correct use of ! and &

KAMEZAWA Hiroyuki (1):
      memcg: update menuconfig help text

Kay Sievers (1):
      sound: struct device - replace bus_id with dev_name(), dev_set_name=
()

Ken'ichi Ohmichi (1):
      x86, kdump: fix invalid access on i386 sparsemem

Kristoffer Ericson (1):
      [ARM] 5299/1: Add maintainer for Mobilepro 900/c

Krzysztof Helt (1):
      rtc-m48t59: shift zero year to 1968 on sparc (rev 2)

Kumar Gala (1):
      powerpc/mpic: Fix regression caused by change of default IRQ affini=
ty

Kuninori Morimoto (4):
      sh: Provide a sample defconfig for the UL2 (SH7366) board.
      SH 7366 needs SCIF_ONLY
      Add support usb setting on sh 7366
      sh: Enable NFS root in Migo-R defconfig.

Kurt Garloff (1):
      mm: increase the default mlock limit from 32k to 64k

Len Brown (3):
      toshiba_acpi: always call input_sync() after input_report_switch()
      leds-hp-disk: fix build warning
      Merge branch 'i7300_idle' into release

Lennart Sorensen (1):
      scx200_i2c: Add missing class parameter

Li Zefan (8):
      sched: add CONFIG_SMP consistency
      sched: change sched_debug's mode to 0444
      sched: remove sched-design.txt from 00-INDEX
      freezer_cg: fix improper BUG_ON() causing oops
      freezer_cg: remove redundant check in freezer_can_attach()
      freezer_cg: use thaw_process() in unfreeze_cgroup()
      freezer_cg: simplify freezer_change_state()
      cgroups: tiny cleanups

Linus Torvalds (58):
      Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel=
/git/lenb/linux-acpi-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jikos/hid
      Merge branch 'for-upstream' of git://git.kernel.org/pub/scm/linux/k=
ernel/git/dvrabel/uwb
      Merge branch 'for-linus' of git://git.o-hand.com/linux-mfd
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/dtor/input
      Merge branch 'for-linus' of git://neil.brown.name/md
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/ieee1394/linux1394-2.6
      Merge branch 'upstream' of git://ftp.linux-mips.org/pub/scm/upstrea=
m-linus
      Merge branch 'for-linus' of git://git.kernel.dk/linux-2.6-block
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/jgarzik/libata-dev
      Merge branch 'for-linus' of git://git390.osdl.marist.edu/pub/scm/li=
nux-2.6
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'sched-fixes-for-linus' of git://git.kernel.org/pub/sc=
m/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'irq-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'core-fixes-for-linus' of git://git.kernel.org/pub/scm=
/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'kvm-updates/2.6.28' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/avi/kvm
      Merge branch 'tracing-fixes-for-linus' of git://git.kernel.org/pub/=
scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'tracing-fixes-for-linus' of git://git.kernel.org/pub/=
scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/lrg/voltage-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/usb-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-c=
ore-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jikos/hid
      Merge branch 'i2c-for-linus' of git://jdelvare.pck.nerim.net/jdelva=
re-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jbarnes/pci-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/agk/linux-2.6-d=
m
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'bugfixes' of git://git.linux-nfs.org/projects/trondmy=
/nfs-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/brodo/pcmcia-2.=
6
      Merge branch 'upstream' of git://ftp.linux-mips.org/pub/scm/upstrea=
m-linus
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/wim/linux-2.6-w=
atchdog
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/sam/kbuild-fixe=
s
      Merge master.kernel.org:/home/rmk/linux-2.6-arm
      Merge branch 'core-fixes-for-linus' of git://git.kernel.org/pub/scm=
/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'tracing-fixes-for-linus' of git://git.kernel.org/pub/=
scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'sched-fixes-for-linus' of git://git.kernel.org/pub/sc=
m/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'x86-fixes-for-linus-2' of git://git.kernel.org/pub/sc=
m/linux/kernel/git/tip/linux-2.6-tip
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/rusty/linux-2.6=
-for-linus
      Merge branch 'for-linus' of git://neil.brown.name/md
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/jgarzik/libata-dev
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tytso/ext4
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/lethal/sh-2.6
      Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/paulus/powerpc
      Merge branch 'for-2.6.28' of git://linux-nfs.org/~bfields/linux
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jmorris/security-testing-2.6
      Merge branch 'cris_move' of git://www.jni.nu/cris
      Merge branch 'link_removal' of git://www.jni.nu/cris
      reserve_region_with_split: Fix GFP_KERNEL usage under spinlock
      x86: Clean up late e820 resource allocation
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/bart/ide-2.6
      Linux v2.6.28-rc3

Linus Walleij (1):
      [ARM] 5322/1: Fix fastpath issue in mmci.c

Manish Katiyar (1):
      netlabel: Fix compilation warnings in net/netlabel/netlabel_addrlis=
t.c

Manuel Lauss (1):
      MIPS: Alchemy: Wire up SD controller on DB/PB1200 boards.

Marcelo Tosatti (1):
      KVM: MMU: sync root on paravirt TLB flush

Marcin Slusarz (1):
      fbcon: don't inline updatescrollmode

Mariusz Kozlowski (1):
      hdpuftrs: fix build

Mark Brown (6):
      mfd: Make WM8400 depend on I2C until SPI is submitted
      ALSA: hda: Add HDA vendor ID for Wolfson Microelectronics
      regulator: Build on non-ARM platforms
      ALSA: Warn when control names are truncated
      ALSA: ASoC: Fix mono controls after conversion to support full int =
masks
      ALSA: ASoC: Fix WM9713 ALC Decay Time name

Mark Nelson (2):
      ahci: Add support for Promise PDC42819
      powerpc: Update remaining dma_mapping_ops to use map/unmap_page

Markus Metzger (1):
      x86, bts: improve help text for BTS config

Matt Fleming (1):
      Define SCSPTR1 for SH 7751R

Matthew Garrett (1):
      sony-laptop: ignore missing _DIS method on pic device

Matthias Kaehlcke (1):
      [ARM] ep93xx: fix OHCI DMA mask

Max Dmitrichenko (1):
      sparc64: Fix PCI resource mapping on sparc64

Miao Xie (1):
      ACPI: cpufreq, processor: fix compile error in drivers/acpi/process=
or_perflib.c

Michael Neuling (2):
      powerpc: Fix compiler warning for the relocatable kernel
      powerpc: Fix swapcontext system for VSX + old ucontext size

Michael Trimarchi (1):
      sh: Fix up the shared IRQ demuxer's control bit testing logic.

Mike Crowe (1):
      [ARM] 5323/1: Remove outdated empeg documentation.

Mike Dyer (1):
      powerpc: Remove duplicate DMA entry from mpc8313erdb device tree

Mike Frysinger (3):
      kbuild: setlocalversion: dont include svn change count
      MAINTAINERS: add LTP info to the list
      SMC91x: delete unused local variable "lp"

Mike Galbraith (1):
      sched: weaken sync hint

Mike Travis (1):
      x86, uv: fix compile error in uv_hub.h

Mikulas Patocka (3):
      dm snapshot: fix register_snapshot deadlock
      dm snapshot: wait for chunks in destructor
      framebuffer compat_ioctl deadlock

Milton Miller (3):
      powerpc: Kexec exit should not use magic numbers
      powerpc: Use is_kdump_kernel()
      powerpc/ppc64/kdump: Better flag for running relocatable

Nathan Fontenot (1):
      powerpc/pci: Properly allocate bus resources for hotplug PHBs

NeilBrown (4):
      md: use sysfs_notify_dirent to notify changes to md/array_state
      md: use sysfs_notify_dirent to notify changes to md/dev-xxx/state
      md: allow extended partitions on md devices.
      md: destroy partitions and notify udev when md array is stopped.

Nick Piggin (1):
      fs: remove prepare_write/commit_write

Nobuhiro Iwamatsu (3):
      gdrom: Fix compile error
      sh: Change register name SCSPTR to SCSPTR2
      sh: Add sci_rxd_in of SH4-202

Ondrej Zary (1):
      libata: Fix LBA48 on pata_it821x RAID volumes.

Paul Bolle (1):
      [ARM] build fixes for netX serial driver

Paul Mackerras (5):
      Merge branch 'merge' of master.kernel.org:/pub/scm/linux/kernel/git=
/jwboyer/powerpc-4xx into merge
      powerpc: Work around ld bug in older binutils
      powerpc: Fix compile errors with CONFIG_BUG=3Dn
      Merge branch 'merge' of master.kernel.org:/pub/scm/linux/kernel/git=
/galak/powerpc into merge
      Revert "powerpc: Sync RPA note in zImage with kernel's RPA note"

Paul Moore (1):
      netlabel: Fix compiler warnings in netlabel_mgmt.c

Paul Mundt (14):
      serial: sh-sci: Kill off all of the SCI/SCIF special casing.
      kernel/resource: fix reserve_region_with_split() section mismatch
      sh: oprofile: Fix up the SH7750 performance counter name.
      sh: Fix FPU tuning on toolchains with mismatched multilib targets.
      sh: Add on-chip RTC support for SH7722.
      sh: sh7785lcr: Select uImage as default image target.
      sh: Simplify and lock down the ISA tuning.
      Merge branches 'sh/serial-rework' and 'sh/oprofile'
      sh: Revert "SH 7366 needs SCIF_ONLY"
      sh: Kill off long-dead HD64465 cchip support.
      kernel/profile: fix profile_init() section mismatch
      sh: SHmedia ISA tuning fixups.
      Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/gi=
t/torvalds/linux-2.6
      sh: FTRACE renamed to FUNCTION_TRACER.

Peter Korsgaard (1):
      dm9601: runtime mac address change support

Peter Oruba (3):
      mailmap: add Peter Oruba
      x86: microcode patch loader author update
      x86: AMD microcode patch loader author update

Peter Volkov (1):
      kbuild: fix KBUILD_EXTRA_SYMBOLS

Peter Zijlstra (5):
      tracing: create tracers menu
      sched: fix a find_busiest_group buglet
      sched: more accurate min_vruntime accounting
      sched: re-instate vruntime based wakeup preemption
      sched: virtual time buddy preemption

Phil Sutter (1):
      MIPS: RB532: Disable the right device

Qinghuang Feng (1):
      driver core: drivers/base/sys.c: update comments

Rafael J. Wysocki (2):
      ACPI suspend: build fix for ACPI_SLEEP=3Dn && XEN_SAVE_RESTORE=3Dy.
      ACPI: Oops in ACPI with git latest

Ralf Baechle (10):
      MIPS: SMP: Don't reenable interrupts in stop_this_cpu; use WAIT ins=
truction.
      MIPS: IP22: ip22-int.c header file weeding.
      MIPS: New feature test macro cpu_has_mips_r
      MIPS: Clean up MIPSxx-optimized bitop functions
      MIPS: SMP: Do not initialize __cpu_number_map/__cpu_logical_map for=
 CPU 0.
      MIPS: Switch FPU emulator trap to BREAK instruction.
      MIPS: Probe for watch registers on cores of all vendors, not just M=
TI.
      MIPS: Sort out CPU type to name translation.
      CHAR: Delete old and now unused DS1286 driver.
      CHAR: Delete old and now unused M48T35 RTC driver for SGI IP27.

Randy Dunlap (10):
      kernel-doc: allow more whitespace in macros
      docbooks: fix fatal filename errors
      mac80211.h: fix kernel-doc excesses
      libata: add missing kernel-doc
      i2o: fix kernel-doc warnings
      mm: fix kernel-doc function notation
      fs: remove excess kernel-doc
      kernel.h: fix might_sleep kernel-doc
      ATA: remove excess kernel-doc notation
      net: delete excess kernel-doc notation

Ravikiran G Thirumalai (1):
      x86: fix /dev/mem mmap breakage when PAT is disabled

Remi Denis-Courmont (2):
      Phonet: include generic link-layer header size in MAX_PHONET_HEADER
      Phonet: do not reply to indication reset packets

Roel Kluin (1):
      [S390] appldata: unsigned ops->size cannot be negative

Rog=C3=A9rio Brito (2):
      powerpc: compile kernel for linkstations optimized for size
      powerpc: enable heap randomization for linkstations

Roland Dreier (1):
      libata: Avoid overflow in ata_tf_to_lba48() when tf->hba_lbal > 127

Russell King (3):
      Merge branch 'fixes' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/djbw/xscaleiop
      Merge branch 'fix' of git://git.kernel.org/pub/scm/linux/kernel/git=
/ycmiao/pxa-linux-2.6
      Merge branch 'for-rmk-rc' of git://pasiphae.extern.pengutronix.de/g=
it/imx/linux-2.6

Rusty Russell (3):
      lguest: fix example launcher compile after moved asm-x86 dir.
      lguest: fix early_ioremap.
      lguest: fix irq vectors.

Sam Ravnborg (1):
      kbuild: improve check-symlink

Samuel Ortiz (1):
      mfd: add missing Kconfig entry for da903x

Sascha Hauer (3):
      [ARM] pcm037: map AIPS1 and AIPS2 as nonshared area
      [ARM] MX3: Use ioremap wrapper to map SoC devices nonshared
      [ARM] mx31ads: Add missing include

Scott James Remnant (1):
      ipmi: add MODULE_ALIAS to load ipmi_devintf with ipmi_si

Serge Hallyn (1):
      file caps: always start with clear bprm->caps_*

Sergey Lapin (1):
      [ARM] 5326/1: AFEB9260: Fix for i2c_board_info structure

Sergio Luis (2):
      btsdio: free sk_buff with kfree_skb
      libertas: free sk_buff with kfree_skb

Shaohua Li (1):
      x86, memory hotplug: remove wrong -1 in calling init_memory_mapping=
()

Sheng Yang (1):
      KVM: Fix guest shared interrupt with in-kernel irqchip

Shinya Kuribayashi (12):
      MIPS: Add CONFIG_CPU_R5500 for NEC VR5500 series processors
      MIPS: EMMA: Kconfig reorganization
      MIPS: EMMA: Move arch/mips/emma2rh/ into arch/mips/emma/
      MIPS: EMMA: Move <asm/emma2rh> to <asm/emma> dir
      MIPS: EMMA2RH: Remove emma2rh_sync on read operation
      MIPS: EMMA2RH: Remove emma2rh_irq_base global variable
      MIPS: EMMA2RH: Remove emma2rh_sw_irq_base
      MIPS: EMMA2RH: Remove emma2rh_gpio_irq_base
      MIPS: EMMA: Fold arch/mips/emma/{common,markeins}/irq*.c into marke=
ins/irq.c
      MIPS: Markeins: Remove runtime debug prints
      MIPS: Markeins: Extract ll_emma2rh_* functions
      MIPS: Markeins: Remove unnecessary define and cleanup comments, etc.

Stefan Bader (1):
      Input: i8042 - add Blue FB5601 to noloop exception table

Stefan Richter (2):
      firewire: fw-ohci: initialization failure path fixes
      firewire: fw-sbp2: delay first login to avoid retries

Stephen Hemminger (1):
      net: add documentation for skb recycling

Stephen Rothwell (1):
      trace: fix printk warning for u64

Steven Rostedt (23):
      ftrace: do not enclose logic in WARN_ON
      ftrace: release functions from hash
      ftrace: fix depends
      ftrace: rename FTRACE to FUNCTION_TRACER
      ftrace: rename the ftrace tracer to function
      ftrace: stack tracer only record when on stack
      ring-buffer: fix free page
      ftrace: handle generic arch calls
      ftrace: dynamic ftrace process only text section
      ftrace: return error on failed modified text.
      ftrace: comment arch ftrace code
      ftrace: use probe_kernel
      ftrace: only have ftrace_kill atomic
      ftrace: add ftrace warn on to disable ftrace
      ftrace: disable dynamic ftrace for all archs that use daemon
      ftrace: remove daemon
      ftrace: remove mcount set
      ftrace: remove ftrace hash
      ftrace, powerpc, sparc64, x86: remove notrace from arch ftrace file
      ftrace: use a real variable for ftrace_nop in x86
      ftrace: fix current_tracer error return
      ftrace: fix trace_nop config select
      ftrace: handle archs that do not support irqs_disabled_flags

Sukadev Bhattiprolu (1):
      'kill sig -1' must only apply to caller's namespace

Suresh Siddha (1):
      resources: fix x86info results ioremap.c:226 __ioremap_caller+0xf2/=
0x2d6() WARNINGs

Sven Hartge (1):
      via-velocity: use driver string instead of dev->name before registe=
r_netdev()

Takashi Iwai (8):
      ALSA: hda - Restore default pin configs for realtek codecs
      Merge branches 'topic/fix/asoc', 'topic/fix/hda', 'topic/fix/misc' =
and 'topic/pci-ioremap-bar' into for-linus
      ALSA: hda - Add another HP model for AD1884A
      ALSA: hda - Fix SPDIF mute on IDT/STAC codecs
      ALSA: hda - Add reboot notifier
      Merge branches 'topic/fix/hda' and 'topic/fix/misc' into for-linus
      ALSA: usb - Add quirk for Edirol UA-25EX advanced modes
      Merge branches 'topic/fix/misc' and 'topic/fix/asoc' into for-linus

Tejun Heo (4):
      libata: fix device iteration bugs
      sata_sil24: configure max read request size to 4k
      libata: clear saved xfer_mode and ncq_enabled on device detach
      sata_via: fix support for 5287

Theodore Ts'o (1):
      jbd2: Call the commit callback before the transaction could get dro=
pped

Thomas Klein (1):
      ehea: Detect 16GB hugepages for firmware restriction

Thomas Volpini (1):
      scripts/checksyscalls.sh: fix for non-gnu sed

Tomas Winkler (1):
      iwlwifi: fix suspend to RAM in iwlwifi

Trent Piepho (3):
      kbuild: tag with git revision when git describe is missing
      gianfar: Fix race in TBI/SerDes configuration
      gianfar: Don't reset TBI<->SerDes link if it's already up

Trond Myklebust (4):
      SUNRPC: Respond promptly to server TCP resets
      NFS: Convert nfs_attr_generation_counter into an atomic_long
      SUNRPC: Fix rpcauth_prune_expired
      SUNRPC: Fix potential race in put_rpccred()

Tsugikazu Shibata (1):
      HOWTO: Sync patch for jp_JP/HOWTO

Ursula Braun (2):
      qeth: remove non-recover-thread checkings
      qeth: avoid skb_under_panic for malformatted inbound data

Uwe Hermann (1):
      doc/x86: fix doc subdirs

Uwe Kleine-K=C3=B6nig (1):
      [ARM] gpio_free might sleep, arm architecture

Venki Pallipadi (4):
      i7300_idle: Disable ioat channel only on platforms where ile driver=
 can load
      i7300_idle: Cleanup based review comments
      i7300_idle: Fix compile warning CONFIG_I7300_IDLE_IOAT_CHANNEL not =
defined
      x86: fix AMDC1E and XTOPOLOGY conflict in cpufeature

Xiantao Zhang (2):
      KVM: ia64: Fix halt emulation logic
      KVM: ia64: Makefile fix for forcing to re-generate asm-offsets.h

Yauhen Kharuzhy (2):
      rtc-s3c: fix section mismatch warnings
      rtc S3C: add device_init_wakeup() invokation

Yevgeny Petrilin (1):
      mlx4: Setting the correct offset for default mac address

Yinghai Lu (4):
      x86: keep the /proc/meminfo page count correct
      x86: fix APIC_DEBUG with inquire_remote_apic
      x86: 64 bit print out absent pages num too
      x86: fix init_memory_mapping for [dc000000 - e0000000) - v2

Yoichi Yuasa (1):
      MIPS: Fix KGDB build error

Yoshihiro Shimoda (1):
      sh: fix sh2a cache entry_mask

Zhang Le (1):
      MIPS: lemote/lm2e: Added io_map_base to pci controller

Zhaolei (2):
      MIPS: Fix debugfs_create_*'s error checking method for arch/mips/ma=
th-emu/
      MIPS: Fix debugfs_create_*'s error checking method for mips/kernel/

fernando-gVGce1chcLeIwRZHo2/mJg@public.gmane.org (1):
      xfrm: do not leak ESRCH to user space

qinghuang feng (1):
      lockdep: minor fix for debug_show_all_locks()

roel kluin (3):
      irq: make variable static
      printk: remove unused code from kernel/printk.c
      cipso: unsigned buf_len cannot be negative

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr

--===============1067186824955991619==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============1067186824955991619==--
