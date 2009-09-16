From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr annotated tag, v2.6.27-rc8, created. v2.6.27-rc8
Date: Wed, 16 Sep 2009 14:36:27 -0400
Message-ID: <200909161836.n8GIaRFo000921@gorgona.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0238639495309585640=="
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

--===============0238639495309585640==
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by smtp1.linux-foundation.org id n8GIjTBT004011

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The annotated tag, v2.6.27-rc8 has been created
        at  7b4e06aa7c0952353096105f87be67615e4382f5 (tag)
   tagging  94aca1dac6f6d21f4b07e4864baf7768cabcc6e7 (commit)
  replaces  v2.6.27-rc7
 tagged by  Linus Torvalds
        on  Mon Sep 29 15:24:12 2008 -0700

- Log -----------------------------------------------------------------
Linux 2.6.27-rc8
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkjhVZAACgkQF3YsRnbiHLvhmwCdEMmssMlp19z2RSLsGUS7Q9eq
goYAn1SQm5iYwdttPkUjVJoLFoKTvXR/
=3DdMzj
-----END PGP SIGNATURE-----

Adrian Bunk (5):
      m32r: remove the unused NOHIGHMEM option
      m32r: don't offer CONFIG_ISA
      m32r: export empty_zero_page
      m32r: export __ndelay
      m32r/kernel/: cleanups

Adrian Hunter (2):
      UBIFS: TNC / GC race fixes
      UBIFS: remove incorrect assert

Akinobu Mita (2):
      [WATCHDOG] ibmasr: remove unnecessary spin_unlock()
      ibmasr: remove unnecessary spin_unlock()

Alan Cox (1):
      pcmcia: Fix broken abuse of dev->driver_data

Alan Stern (2):
      USB: unusual_devs addition for RockChip MP3 player
      USB: revert recovery from transient errors

Alex Chiang (1):
      [IA64] Ski simulator doesn't need check_sal_cache_flush

Alexander Beregalov (1):
      UBIFS: fix printk format warnings

Alexander Duyck (1):
      netdev: simple_tx_hash shouldn't hash inside fragments

Andrea Righi (1):
      x86, oprofile: BUG scheduling while atomic

Andreas Bombe (1):
      usb-serial: Add Siemens EF81 to PL-2303 hack triggers

Andreas Herrmann (1):
      x86: c1e_idle: don't mark TSC unstable if CPU has invariant TSC

Andrew Morton (2):
      Documentation/sysctl/kernel.txt: fix softlockup_thresh description
      USB: drivers/usb/musb/: disable it on SuperH

Andrew Vasquez (1):
      [SCSI] qla2xxx: Defer enablement of RISC interrupts until ISP initi=
alization completes.

Anti Sullin (1):
      atmel_serial: update the powersave handler to match serial core

Atsuo Igarashi (1):
      kgdb: could not write to the last of valid memory with kgdb

Aurelien Jarno (2):
      [MIPS] BCM47xx: Fix build error due to missing PCI functions
      [SSB] Initialise dma_mask for SSB_BUSTYPE_SSB devices

Balbir Singh (1):
      mm owner: fix race between swapoff and exit

Ben Dooks (1):
      [WATCHDOG] wdt285: fix sparse warnings

Boaz Harrosh (2):
      [SCSI] qlogicpti: fix sg list traversal error in continuation entri=
es
      scsi: fix fall out of sg-chaining patch in qlogicpti

Borislav Petkov (1):
      ide-tape: fix vendor strings

Bruno Randolf (2):
      [MIPS] au1000: Fix gpio direction
      [MIPS] au1000: Make sure GPIO value is zero or one

Chris Adams (1):
      usb serial: ti_usb_3410_5052 obviously broken by firmware changes

Craig Shelley (1):
      USB: SERIAL CP2101 add device IDs

Daisuke Nishimura (1):
      memcg: check under limit at shrink_usage

David Almaroad (1):
      usb: unusual devs patch for Nokia 5310 Music Xpress

David Brownell (3):
      USB: ehci: fix some ehci hangs and crashes
      usb gadget: fix omap_udc DMA regression
      USB: fix EHCI periodic transfers

David Howells (3):
      MN10300: Move asm-arm/cnt32_to_63.h to include/linux/
      MN10300: Make sched_clock() report time since boot
      ARM: Delete ARM's own cnt32_to_63.h

David S. Miller (4):
      sparc64: Fix disappearing PCI devices on e3500.
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-2.6
      sparc64: Fix missing devices due to PCI bridge test in of_create_pc=
i_dev().
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-2.6

Eric Van Hensbergen (1):
      9p: fix put_data error handling

Felipe Balbi (1):
      usb: musb: fix include path

Filip Joelsson (1):
      USB: Fixing Nokia 3310c in storage mode

Gaetan Carlier (1):
      usb: ftdi_sio: add support for Domintell devices

Geoff Levand (1):
      USB: fix hcd interrupt disabling

Greg KH (1):
      PCI: fix compiler warnings in pci_get_subsys()

Haavard Skinnemoen (1):
      ALSA: ASoC: Fix at32-pcm build breakage with PM enabled

Henrik Rydberg (1):
      Input: bcm5974 - switch back to normal mode when closing

Ingo Molnar (1):
      timers: fix build error in !oneshot case

Jack Tan (1):
      [MIPS] Fixe the definition of PTRS_PER_PGD

James Bottomley (1):
      [SCSI] Fix hang with split requests

Jaroslav Kysela (1):
      USB: ftdi_sio: Add 0x5050/0x0900 USB IDs (Papouch Quido USB 4/4)

Jason Wessel (4):
      kgdb, x86, arm, mips, powerpc: ignore user space single stepping
      kgdb, x86_64: gdb serial has BX and DX reversed
      kgdb, x86_64: fix PS CS SS registers in gdb serial
      kgdboc,tty: Fix tty polling search to use name correctly

Jay Lan (1):
      [IA64] kexec fails on systems with blocks of uncached memory

Jean Delvare (2):
      i2c: Fix mailing lists in two MAINTAINERS entries
      ALSA: ASoC: Fix another cs4270 error path

Jeremy Katz (1):
      x86: disable apm on the olpc

Joerg Roedel (2):
      AMD IOMMU: set iommu sunc flag after command queuing
      AMD IOMMU: protect completion wait loop with iommu lock

Jonathan Steel (1):
      kexec: fix segmentation fault in kimage_add_entry

Julia Lawall (1):
      9p: introduce missing kfree

Julien Brunel (1):
      9p: use an IS_ERR test rather than a NULL test

Kevin Lloyd (3):
      USB Storage: Sierra: Non-configurable TRU-Install
      USB Serial: Sierra: Device addition & version rev
      USB Serial: Sierra: Add MC8785 VID/PID

Kirill A. Shutemov (1):
      smb.h: do not include linux/time.h in userspace

Kristoffer Ericson (1):
      Input: jornada720_ts - fix build error ( LONG() usage )

Lachlan McIlroy (2):
      [XFS] Fix extent list corruption in xfs_iext_irec_compact_full().
      [XFS] Remove xfs_iext_irec_compact_full()

Liam Girdwood (1):
      ALSA: ASoC: maintainers - update email address for Liam Girdwood

Linus Torvalds (32):
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/dtor/input
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/wim/linux-2.6-w=
atchdog
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel=
/git/aegl/linux-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jbarnes/pci-2.6
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'sched-fixes-for-linus' of git://git.kernel.org/pub/sc=
m/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'timers-fixes-for-linus' of git://git.kernel.org/pub/s=
cm/linux/kernel/git/tip/linux-2.6-tip
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/usb-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/ericvh/v9fs
      Merge branch 'upstream' of git://ftp.linux-mips.org/pub/scm/upstrea=
m-linus
      Merge branch 'timers-fixes-for-linus' of git://git.kernel.org/pub/s=
cm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'i2c-for-linus' of git://jdelvare.pck.nerim.net/jdelva=
re-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'linux-next' of git://git.infradead.org/~dedekind/ubif=
s-2.6
      Merge git://oss.sgi.com:8090/xfs/linux-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Fix NULL pointer dereference in proc_sys_compare
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/jgarzik/libata-dev
      Merge branch 'for-linus' of git://git.kernel.dk/linux-2.6-block
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/jejb/scsi-rc-fi=
xes-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jwessel/linux-2.6-kgdb
      Merge branch 'linux-m32r' of git://www.linux-m32r.org/git/takata/li=
nux-2.6_dev
      Merge branch 'upstream' of git://ftp.linux-mips.org/pub/scm/upstrea=
m-linus
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/bart/ide-2.6
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Linux 2.6.27-rc8

Luis R. Rodriguez (1):
      ath9k: disable MIB interrupts to fix interrupt storm

Marc Dionne (1):
      x86: prevent stale state of c1e_mask across CPU offline/online, fix

Marcel Holtmann (3):
      [Bluetooth] Fix I/O errors on MacBooks with Broadcom chips
      [Bluetooth] Fix wrong URB handling of btusb driver
      [Bluetooth] Fix USB disconnect handling of btusb driver

Marin Mitov (1):
      Documentation/DMA-mapping.txt: update for pci_dma_mapping_error() c=
hanges

Michael Kerrisk (1):
      sys_paccept: disable paccept() until API design is resolved

M=C3=A1rton N=C3=A9meth (1):
      cdrom: update ioctl documentation

Nick Piggin (1):
      mm: tiny-shmem fix lock ordering: mmap_sem vs i_mutex

Oliver Neukum (1):
      USB: update of Documentation/usb/anchors.txt

Otavio Salvador (1):
      USB: serial: add ZTE CDMA Tech id to option driver

Peter Korsgaard (1):
      USB: fsl_usb2_udc: fix VDBG() format string

Rakib Mullick (1):
      sched: fix init_hrtick() section mismatch warning

Ralf Baechle (2):
      [MIPS] IP27: Switch to dynamic interrupt routing avoding panic on e=
rror.
      Swarm: Fix crash due to missing initialization

Randy Dunlap (1):
      kernel-doc: allow structs whose members are all private

Ravikiran G Thirumalai (1):
      x86: fix 27-rc crash on vsmp due to paravirt during module load

Richard Nauber (1):
      USB: Fix the Nokia 6300 storage-mode.

Roland Dreier (1):
      IPoIB: Fix crash when path record fails after path flush

Sebastian Siewior (1):
      UBIFS: create the name of the background thread in every case

Senthil Balasubramanian (2):
      ath9k: connectivity is lost after Group rekeying is done
      ath9k: Fix IRQ nobody cared issue with ath9k

Sitsofe Wheeler (1):
      PCI: Fix pcie_aspm=3Dforce

Sven Wegener (1):
      i2c-dev: Return correct error code on class_create() failure

Takashi Iwai (2):
      ALSA: fix locking in snd_pcm_open*() and snd_rawmidi_open*()
      ALSA: remove unneeded power_mutex lock in snd_pcm_drop

Tejun Heo (7):
      9p: implement proper trans module refcounting and unregistration
      9p-trans_fd: fix trans_fd::p9_conn_destroy()
      9p-trans_fd: clean up p9_conn_create()
      9p-trans_fd: don't do fs segment mangling in p9_fd_poll()
      9p-trans_fd: fix and clean up module init/exit paths
      ide: note that IDE generic may prevent other drivers from attaching
      sata_nv: reinstate nv_hardreset() for non generic controllers

Thomas Gleixner (6):
      clockevents: prevent cpu online to interfere with nohz
      x86: prevent stale state of c1e_mask across CPU offline/online
      clockevents: prevent stale tick_next_period for onlining CPUs
      clockevents: check broadcast device not tick device
      clockevents: prevent mode mismatch on cpu online
      x86: prevent C-states hang on AMD C1E enabled machines

Timur Tabi (1):
      ALSA: make the CS4270 driver a new-style I2C driver

Tony Murray (1):
      USB: Correct Sierra Wireless USB EVDO Modem Device ID

Uwe Kleine-Koenig (1):
      i2c-powermac: Fix section for probe and remove functions

Wim Van Sebroeck (1):
      [WATCHDOG] unlocked_ioctl changes

Yasuyuki Kozakai (1):
      netfilter: ip6t_{hbh,dst}: Rejects not-strict mode on rule insertio=
n

born.into.silence-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org (1):
      wireless: zd1211rw: add device ID fix wifi dongle "trust nw-3100"

zippel-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org (2):
      kconfig: fix silentoldconfig
      kconfig: readd lost change count

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr

--===============0238639495309585640==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============0238639495309585640==--
