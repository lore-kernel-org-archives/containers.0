From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr annotated tag, v2.6.30-rc7, created. v2.6.30-rc7
Date: Wed, 16 Sep 2009 14:36:52 -0400
Message-ID: <200909161836.n8GIaqBN001504@gorgona.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8965507908793635864=="
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

--===============8965507908793635864==
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by smtp1.linux-foundation.org id n8GIu4fV005306

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The annotated tag, v2.6.30-rc7 has been created
        at  efa3e68c670b745894255af9827b3902bbc9376e (tag)
   tagging  59a3759d0fe8d969888c741bb33f4946e4d3750d (commit)
  replaces  v2.6.30-rc6
 tagged by  Linus Torvalds
        on  Sat May 23 14:47:18 2009 -0700

- Log -----------------------------------------------------------------
Linux 2.6.30-rc7
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkoYbuoACgkQF3YsRnbiHLs0xQCgnYqobF37iHW8trKGEm4d4v+i
ok4AnAmbSiWw/J1WtqUJ4JSZ3PzIecrP
=3DxyLu
-----END PGP SIGNATURE-----

Abhijeet Joglekar (1):
      [SCSI] fnic: Add new Cisco PCI-Express FCoE HBA

Adam Williamson (1):
      ALSA: hda - fix audio on HP TX25xx series notebooks

Ajit Khaparde (1):
      be2net: add two new pci device ids to pci device table

Alan Cox (1):
      piix: The Sony TZ90 needs the cable type hardcoding

Alan Jenkins (2):
      eeepc-laptop: fix wlan rfkill state change during init
      eeepc-laptop: Work around rfkill firmware bug

Alessandro Rubini (1):
      [ARM] 5519/1: amba probe: pass "struct amba_id *" instead of void *

Andreas Mohr (1):
      ALSA: Kill truncate warning by shortening Sigmatel-specific AC97 co=
ntrol name

Andrew Randrianasulu (1):
      MIPS: IP32: Fix hang on shutdown in power button interrupt handler.

Andrew Vasquez (1):
      [SCSI] fc-transport: Close state transition-window during rport del=
etion.

Bartlomiej Zolnierkiewicz (5):
      ide: fix 40-wire cable detection for TSST SH-S202* ATAPI devices (v=
2)
      ide: fix OOPS during ide-cd error recovery
      ide: fix printk() levels in ide_dump_ata[pi]_error()
      ide: improve failed opcode reporting
      ide: report timeouts in ide_busy_sleep()

Ben Dooks (5):
      [ARM] nwfpe: Add decleration for ExtendedCPDO
      [ARM] nwfpe: fix 'floatx80_is_nan' sparse warning
      [ARM] S3C24XX: Fix unused code warning in arch/arm/plat-s3c24xx/dma=
.c
      [ARM] S3C2410: mach-bast.c registering i2c data too early
      [ARM] S3C: Do not set clk->owner field if unset

Benjamin Herrenschmidt (2):
      powerpc: Explicit alignment for .data.cacheline_aligned
      drm: Round size of SHM maps to PAGE_SIZE

Bjorn Helgaas (1):
      PM: check sysdev_suspend(PMSG_FREEZE) return value

Breno Leitao (1):
      icom: fix rmmod crash

Chris Friesen (1):
      ipconfig: handle case of delayed DHCP server

Christian Hohnstaedt (1):
      crypto: ixp4xx - check firmware for crypto support

Corentin Chary (2):
      asus-laptop: fix input keycode
      eeepc-laptop: unregister_rfkill_notifier on failure

Corey Minyard (1):
      ipmi: fix ipmi_si modprobe hang

Darren Salt (1):
      eeepc-laptop: report brightness control events via the input layer

David Rientjes (2):
      slub: enforce MAX_ORDER
      slub: add Documentation/ABI/testing/sysfs-kernel-slab

David S. Miller (3):
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/holtmann/bluetooth-2.6
      Merge branch 'master' of /home/davem/src/GIT/linux-2.6/
      Merge branch 'linux-2.6.30.y' of git://git.kernel.org/pub/scm/linux=
/kernel/git/inaky/wimax

David Woodhouse (1):
      Fix oops on close of hot-unplugged FTDI serial converter

Edward Goggin (1):
      [SCSI] initialize max_target_blocked in scsi_alloc_target

Eric Dumazet (2):
      sch_teql: should not dereference skb after ndo_start_xmit()
      pkt_sched: gen_estimator: use 64 bit intermediate counters for bps

Eric Moore (1):
      [SCSI] mpt2sas: fix driver version inconsistency

Eric Paris (1):
      TPM: get_event_name stack corruption

Frank Filz (1):
      nfs: Fix NFS v4 client handling of MAY_EXEC in nfs_permission.

Frans Pop (1):
      ipv4: make default for INET_LRO consistent with help text

Gabriel Paubert (1):
      mv643xx_eth: fix PPC DMA breakage

Geoff Levand (1):
      powerpc/ps3: Update ps3_defconfig

GeunSik Lim (1):
      tracing: Append prompt in /debug/tracing/README file

Greg Ungerer (1):
      MIPS: 64-bit: Fix system lockup.

Grigori Goronzy (1):
      eeepc-laptop: support for super hybrid engine (SHE)

Harald Welte (1):
      via82cxxx: Add VIA VX855 PCI Device ID

Hartley Sweeten (1):
      [ARM] 5509/1: ep93xx: clkdev enable UARTS

Herbert Xu (2):
      crypto: api - Fix algorithm module auto-loading
      crypto: padlock - Revert aes-all alias to aes

Hugh Dickins (1):
      hugh: update email address

Ian Campbell (2):
      xen/blkfront: allow xenbus state transition to Closing->Closed  whe=
n not Connected
      xen/blkfront: fix warning when deleting gendisk on unplug/shutdown

Ilpo J=C3=A4rvinen (1):
      tcp: fix MSG_PEEK race check

Inaky Perez-Gonzalez (1):
      wimax/i2400m: fix device crash: fix optimization in _roq_queue_upda=
te_ws

Ingo Molnar (1):
      lockdep: increase MAX_LOCKDEP_ENTRIES and MAX_LOCKDEP_CHAINS

Jan Beulich (1):
      x86: fix percpu_{to,from}_op()

Jarkko Nikula (2):
      ARM: OMAP2: Fix tusb6010 init error and compilation warning
      ARM: OMAP2: Fix SPI driver failure on 2420 when running multi-omap =
config

Jeff Layton (1):
      cifs: fix pointer initialization and checks in cifs_follow_symlink =
(try #4)

Jeff Mahoney (3):
      reiserfs: clean up ifdefs
      reiserfs: deal with NULL xattr root w/ xattrs disabled
      reiserfs: fixup perms when xattrs are disabled

Jeremy Fitzhardinge (1):
      x86: Fix performance regression caused by paravirt_ops on native ke=
rnels

Kalle Jokiniemi (1):
      ARM: OMAP3: Fix HW SAVEANDRESTORE shift define

Len Brown (9):
      ACPICA: use acpi.* modparam namespace
      ACPI: video: DMI workaround another broken Acer BIOS enabling displ=
ay brightness
      ACPI: power: update error message
      ACPI: suspend: don't let device _PS3 failure prevent suspend
      ACPI: suspend: restore BM_RLD on resume
      ACPI, i915: build fix
      ACPI: idle: fix init-time TSC check regression
      ACPI: Idle C-states disabled by max_cstate should not disable the T=
SC
      Merge branches 'release', 'bugzilla-13032', 'bugzilla-13041+', 'bug=
zilla-13121', 'bugzilla-13165', 'bugzilla-13243', 'bugzilla-13259', 'resu=
me-sci-en-regression', 'thermal-regression', 'tsc-regression' and 'asus-2=
.6.30' into release

Lin Ming (1):
      ACPI: resume: re-enable SCI-enable workaround

Linus Torvalds (33):
      Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel=
/git/lenb/linux-acpi-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/bart/ide-2.6
      Fix caller information for warn_slowpath_null
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/penberg/slab-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/rafael/suspend-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/herbert/crypto-=
2.6
      Merge branch 'tracing-fixes-for-linus' of git://git.kernel.org/pub/=
scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branches 'sched-fixes-for-linus-2' and 'core-fixes-for-linus-=
2' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/benh/powerpc
      Avoid ICE in get_random_int() with gcc-3.4.5
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/lrg/voltage-2.6
      Merge branch 'fixes-for-linus' of git://git.monstr.eu/linux-2.6-mic=
roblaze
      Merge branch 'core/urgent' of git://git.kernel.org/pub/scm/linux/ke=
rnel/git/tip/linux-2.6-tip
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jmorris/security-testing-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/sameo/mfd-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/sfrench/cifs-2.=
6
      Merge branch 'for-linus' of git://git.kernel.dk/linux-2.6-block
      Merge master.kernel.org:/home/rmk/linux-2.6-arm
      Merge branch 'upstream' of git://ftp.linux-mips.org/pub/scm/upstrea=
m-linus
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jbarnes/drm-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jbarnes/pci-2.6
      Merge branch 'sh/for-2.6.30' of git://git.kernel.org/pub/scm/linux/=
kernel/git/lethal/sh-2.6
      Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/benh/powerpc
      Merge branch 'upstream' of git://ftp.linux-mips.org/pub/scm/upstrea=
m-linus
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/sfrench/cifs-2.=
6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/bart/ide-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/ryusuke/nilfs2
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/sfrench/cifs-2.=
6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/jejb/scsi-rc-fi=
xes-2.6
      Linux 2.6.30-rc7

Magnus Damm (2):
      sh: ap325 camera without i2c driver fix
      video: stop sh_mobile_lcdcfb only if started

Marek Szyprowski (2):
      [ARM] S3C64XX: GPIO include cleanup
      [ARM] S3C64XX: fix GPIO debug

Mark Brown (1):
      mfd: Keep a cache of WM8350 volatile values

Masami Hiramatsu (1):
      x86, 32-bit: fix kernel_trap_sp()

Mel Gorman (2):
      powerpc: Do not assert pte_locked for hugepage PTE entries
      [ARM] Double check memmap is actually valid with a memmap has unexp=
ected holes V2

Michael Ellerman (2):
      powerpc/ftrace: Use pr_devel() in ftrace.c
      powerpc/maple: Add a quirk to disable MSI for IPR on Bimini

Michal Simek (2):
      microblaze: Update Microblaze defconfig
      microblaze: Fix kind-of-intr checking against number of interrupts

Michel D=C3=A4nzer (1):
      drm: Copy back ioctl data to userspace regardless of return code.

Mike Frysinger (1):
      regulator: da903x: add missing __devexit_p()

Nelson Castillo (1):
      mfd: pcf50633: fix unsafe disable_irq()

Nick Piggin (2):
      mm: SLUB fix reclaim_state
      mm: SLOB fix reclaim_state

Nico Schottelius (1):
      Fix scripts/setlocalversion with tagged git commit

Paul Walmsley (1):
      ARM: OMAP: GPIO de-bounce clocks don't affect module idle state

Pavel Emelyanov (1):
      netpoll: don't dereference NULL dev from np

Pavel Roskin (1):
      [ARM] mach-l7200: fix spelling of SYS_CLOCK_OFF

Pekka Enberg (1):
      Merge branches 'topic/documentation', 'topic/slub/fixes' and 'topic=
/urgent' into for-linus

Peter Korsgaard (1):
      mtd_dataflash: unbreak erase support

Rabin Vincent (2):
      [ARM] 5518/1: versatile: don't put clock lookups in __initdata
      [ARM] 5517/1: integrator: don't put clock lookups in __initdata

Rafael J. Wysocki (1):
      PCI PM: Fix initialization and kexec breakage for some devices

Ralf Baechle (4):
      NET: Meth: Fix unsafe mix of irq and non-irq spinlocks.
      MIPS: IP22: Fix hang in power button interrupt handler
      MIPS: IP32: Fix build error due to uninitialized variable.
      MIPS: IP32: Remove unnecessary if not even harmful volatile keyword=
s.

Randy Dunlap (1):
      xen: use header for EXPORT_SYMBOL_GPL

Ricardo Martins (1):
      [ARM] 5513/1: Eurotech VIPER SBC: fix compilation error

Roel Kluin (2):
      asm-generic: fix local_add_unless macro
      cdrom: beyond ARRAY_SIZE of viocd_diskinfo

Ron (1):
      sched: Fix fallback sched_clock()'s offset when using jiffies

Russell King (6):
      Merge branch 'fixes-rc5' of git://aeryn.fluff.org.uk/bjdooks/linux
      Merge branch 'omap-fixes' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/tmlind/linux-omap-2.6
      [ARM] smp: fix cpumask usage in ARM SMP code
      [ARM] realview: remove useless smp_cross_call_done()
      [ARM] realview: fix broadcast tick support
      Merge branch 'smp-fix'

Ryusuke Konishi (1):
      nilfs2: fix memory leak in nilfs_ioctl_clean_segments

Sam Ravnborg (1):
      x86: Fix false positive section mismatch warnings in the apic code

Sergei Shtylyov (1):
      icside: register second channel of version 6 PCB

Steffen Klassert (1):
      crypto: eseqiv - Fix IV generation for sync algorithms

Stephen Hemminger (3):
      bridge: relay bridge multicast pkgs if !STP
      bridge: fix initial packet flood if !STP
      bonding: fix link down handling in 802.3ad mode

Steve French (2):
      [CIFS] fix posix open regression
      [CIFS] Avoid open on possible directories since Samba now rejects t=
hem

Steven Rostedt (2):
      x86/function-graph: fix constraint for recording old return value
      powerpc/ftrace: Fix constraint to be early clobber

Takashi Iwai (3):
      ALSA: pcsp - fix printk format warning again
      Merge branch 'fix/hda' into for-linus
      Merge branch 'fix/misc' into for-linus

Tejun Heo (1):
      ide-tape: remove back-to-back REQUEST_SENSE detection

Thomas Chenault (1):
      net: fix skb_seq_read returning wrong offset/length for page frag d=
ata

Thomas Gleixner (1):
      futex: setup writeable mapping for futex ops which modify user spac=
e data

Tomi Valkeinen (1):
      ARM: OMAP: Fix printing of reserved memory for frambuffer

Tony Lindgren (2):
      ARM: OMAP2/3: Add name for musb clocks
      ARM: OMAP2/3: Change omapfb to use clkdev for dispc and rfbi, v2

Toshiyuki Okajima (1):
      page-writeback: fix the calculation of the oldest_jif in wb_kupdate=
()

Vikram Pandita (1):
      ARM: OMAP3: Fix number of GPIO lines for 34xx

Vladimir Zajac (1):
      thermal: fix off-by-1 error in trip point trigger condition

Wang Tinggong (1):
      Doc: fixed descriptions on /proc/sys/net/core/* and /proc/sys/net/u=
nix/*

Wu Zhangjin (1):
      MIPS: Fix sparse warning in incompatiable argument type of clear_us=
er.

Yevgeny Petrilin (1):
      mlx4_en: Fix not deleted napi structures

Yinghai Lu (2):
      x86: mtrr: Fix high_width computation when phys-addr is >=3D 44bit
      [SCSI] ses: fix problems caused by empty SES provided name

Zhang Rui (3):
      ACPI video: dmi check for broken _BQC on Acer Aspire 5720
      ACPI processor: introduce module parameter processor.ignore_tpc
      ACPI processor: reset the throttling state once it's invalid

adam radford (2):
      [SCSI] 3w-9xxx: scsi_dma_unmap fix
      [SCSI] 3w-xxxx: scsi_dma_unmap fix

peter fuerst (1):
      MIPS: IP28: Change to build with -mr10k-cache-barrier=3Dstore

roel kluin (1):
      Neterion: *FIFO1_DMA_ERR set twice, should 2nd be *FIFO2_DMA_ERR?

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr

--===============8965507908793635864==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============8965507908793635864==--
