From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr annotated tag, v2.6.30, created. v2.6.30
Date: Wed, 16 Sep 2009 14:36:45 -0400
Message-ID: <200909161836.n8GIajrI001359@gorgona.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
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

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The annotated tag, v2.6.30 has been created
        at  fa9c4d0983f98945b32d6bd0dfc1ba1b02d3773c (tag)
   tagging  07a2039b8eb0af4ff464efd3dfd95de5c02648c6 (commit)
  replaces  v2.6.30-rc8
 tagged by  Linus Torvalds
        on  Tue Jun 9 20:05:37 2009 -0700

- Log -----------------------------------------------------------------
Linux 2.6.30
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkovIwUACgkQF3YsRnbiHLsL3wCglu4uk4E4/fnfHBd1fsa4peac
xn4AnA9/pAzYCPACryp69le49dFtKil3
=yjIU
-----END PGP SIGNATURE-----

Adam Jackson (1):
      drm: ignore EDID with really tiny modes.

Al Viro (1):
      ext3/4 with synchronous writes gets wedged by Postfix

Alan Cox (3):
      ivtv: Fix PCI DMA direction
      [libata] pata_ali: Use IGN_SIMPLEX
      pata_netcell: Fix typo

Alessandro Rubini (1):
      [ARM] 5543/1: arm: serial amba: add missing declaration in serial.h

Anand Gadiyar (1):
      omap_hsmmc: Trivial fix for a typo in comment

Avi Kivity (2):
      KVM: Explicity initialize cpus_hardware_enabled
      kvm: fix kvm reboot crash when MAXSMP is used

Ben Nizette (1):
      mmc/omap: Use disable_irq_nosync() from within irq handlers.

Ben Skeggs (1):
      drm: don't associate _DRM_DRIVER maps with a master

Chris Mason (1):
      Btrfs: Fix oops and use after free during space balancing

Dave Airlie (2):
      drm: fix irq naming for kms drivers.
      drm/radeon: fix ring free alignment calculations

Dave Jones (1):
      [CPUFREQ] powernow-k8: check space_id of _PCT registers to be FFH

Dave Liu (1):
      sdhci-of: Fix the wrong accessor to HOSTVER register

Eric Anholt (1):
      drm/i915: Remove a bad BUG_ON in the fence management code.

Eric Dumazet (1):
      r8169: fix crash when large packets are received

Eric Lammerts (1):
      fix oops when using console=ttymxcN with N > 0

FUJITA Tomonori (1):
      bsg: setting rq->bio to NULL

Hugh Dickins (1):
      integrity: fix IMA inode leak

Ian Kent (1):
      autofs4: remove hashed check in validate_wait()

James Bottomley (1):
      pata_legacy: wait for async probing

Jan Kara (1):
      jbd: fix race in buffer processing in commit code

Jaswinder Singh Rajput (2):
      drm/i915: intel_lvds.c fix section mismatch
      MIPS: ioctl.h: Fix headers_check warnings

Jonathan Cameron (1):
      [ARM] pxa/imote2: fix UCAM sensor board ADC model number

Keith Packard (3):
      drm: add newlines to text sysfs files
      drm: set permissions on edid file to 0444
      drm: Hook up DPMS property handling in drm_crtc.c. Add drm_helper_connector_dpms.

Kevin Hilman (1):
      mtd: davinci nand: update clock naming

Kumar Gala (1):
      sdhci-of: Add fsl,esdhc as a valid compatible to bind against

Linus Torvalds (20):
      Merge branch 'drm-fixes' of git://git.kernel.org/pub/scm/linux/kernel/git/airlied/drm-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/anholt/drm-intel
      Revert "drm: don't associate _DRM_DRIVER maps with a master"
      Merge branch 'fixes' of git://git.kernel.org/pub/scm/linux/kernel/git/davej/cpufreq
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/libata-dev
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/mason/btrfs-unstable
      Merge branch 'upstream-linus2' of git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/libata-dev
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/jbarnes/pci-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/drzeus/mmc
      Merge master.kernel.org:/home/rmk/linux-2.6-arm
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/bart/ide-2.6
      Merge branch 'kvm-updates/2.6.30' of git://git.kernel.org/pub/scm/virt/kvm/kvm
      Merge branch 'upstream' of git://ftp.linux-mips.org/pub/scm/upstream-linus
      async: Fix lack of boot-time console due to insufficient synchronization
      Merge branch 'for-linus' of git://neil.brown.name/md
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'for-linus' of git://git.kernel.dk/linux-2.6-block
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/rusty/linux-2.6-for-linus
      Linux 2.6.30

Martin Fuzzey (3):
      [ARM] 5534/1: kmalloc must return a cache line aligned buffer
      mxcmmc : Reset the SDHC hardware if software timeout occurs.
      mxcmmc: Fix missing return value checking in DMA setup code.

Matthieu Castet (1):
      SSB: BCM47xx: Export ssb_watchdog_timer_set

Mike Frysinger (2):
      kbuild: fix detection of CONFIG_FRAME_WARN=0
      shm: fix unused warnings on nommu

Minoru Usui (1):
      cls_cgroup: Fix oops when user send improperly 'tc filter add' request

NeilBrown (3):
      md/raid5: use conf->raid_disks in preference to mddev->raid_disk
      md/raid5 - avoid deadlocks in get_active_stripe during reshape
      md/raid5: fix bug in reshape code when chunk_size decreases.

Nicolas Pitre (3):
      mvsdio: allow automatic loading when modular
      mvsdio: ignore high speed timing requests from the core
      mvsdio: fix config failure with some high speed SDHC cards

Oleg Nesterov (2):
      ptrace: tracehook_report_clone: fix false positives
      ptrace: revert "ptrace_detach: the wrong wakeup breaks the ERESTARTxxx logic"

Peter Botha (1):
      char: mxser, fix ISA board lookup

Philipp Zabel (1):
      [ARM] pxa: fix pxa27x_udc default pullup GPIO

Rabin Vincent (1):
      mx[23]: don't put clock lookups in __initdata

Ralf Baechle (2):
      MIPS: Sibyte: Honor CONFIG_CMDLINE
      MIPS: Outline udelay and fix a few issues.

Russell King (3):
      [ARM] ARMv7 errata: only apply fixes when running on applicable CPU
      Merge branch 'for-rmk' of git://git.pengutronix.de/git/imx/linux-2.6
      Merge branch 'fix' of git://git.kernel.org/pub/scm/linux/kernel/git/ycmiao/pxa-linux-2.6

Rusty Russell (1):
      lguest: fix 'unhandled trap 13' with CONFIG_CC_STACKPROTECTOR

Salman Qazi (1):
      drivers/char/mem.c: avoid OOM lockup during large reads from /dev/zero

Sascha Hauer (1):
      mxcmmc: decrease minimum frequency to make MMC cards work

Sergei Shtylyov (3):
      pata_efar: fix PIO2 underclocking
      pdc202xx_old: fix 'pdc20246_dma_ops'
      pdc202xx_old: fix resetproc() method

Tejun Heo (1):
      ahci: add warning messages for hp laptops with broken suspend

Theodore Ts'o (1):
      Fix nobh_truncate_page() to not pass stack garbage to get_block()

Ville Syrjala (1):
      ata_piix: Add HP Compaq nc6000 to the broken poweroff list

Yan Zheng (1):
      Btrfs: set device->total_disk_bytes when adding new device

Yinghai Lu (3):
      x86/pci: fix mmconfig detection with 32bit near 4g
      cpumask: introduce zalloc_cpumask_var
      cpumask: alloc zeroed cpumask for static cpumask_var_ts

Yoichi Yuasa (2):
      MIPS: Kconfig: Remove "Support for" from Cavium system type
      MIPS: Cobalt: PCI bus is always required to obtain the board ID

Yu Zhao (1):
      PCI: use fixed-up device class when configuring device

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr
