From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr annotated tag, v2.6.27-rc9, created. v2.6.27-rc9
Date: Wed, 16 Sep 2009 14:36:27 -0400
Message-ID: <200909161836.n8GIaRFs000941@gorgona.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6477325778171687664=="
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

--===============6477325778171687664==
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by smtp1.linux-foundation.org id n8GIfRqF003589

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The annotated tag, v2.6.27-rc9 has been created
        at  5a97794d66909dbe3282062d7637705bcd352815 (tag)
   tagging  4330ed8ed4da360ac1ca14b0fddff4c05b10de16 (commit)
  replaces  v2.6.27-rc8
 tagged by  Linus Torvalds
        on  Mon Oct 6 16:40:09 2008 -0700

- Log -----------------------------------------------------------------
Linux 2.6.27-rc9
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkjqod8ACgkQF3YsRnbiHLsHPgCfZwGvMTh0BZVF4GfRWEzUNoCw
8rMAn1d3Z+E3QlrRNelUvTbAPI6Zm7Gx
=3D3N5k
-----END PGP SIGNATURE-----

Andreas Oberritter (1):
      V4L/DVB (9029): Fix deadlock in demux code

Andrew Morton (2):
      include/linux/stacktrace.h: declare struct task_struct
      V4L/DVB (8960): drivers/media/video/cafe_ccic.c needs mm.h

Andy Whitcroft (1):
      mm: handle initialising compound pages at orders greater than MAX_O=
RDER

Arnaud Ebalard (1):
      XFRM,IPv6: initialize ip6_dst_blackhole_ops.kmem_cachep

Bartlomiej Zolnierkiewicz (1):
      ide: workaround for bogus gcc warning in ide_sysfs_register_port()

Bodo Eggert (1):
      ide-cd: Optiarc DVD RW AD-7200A does play audio

Borislav Petkov (1):
      ide-cd: temporary tray close fix

Bruce Allan (1):
      e1000e: write protect ICHx NVM to prevent malicious write/erase

Chandra Seetharaman (1):
      dm mpath: add missing path switching locking

Costantino Leandro (1):
      V4L/DVB (8933): gspca: Disable light frquency for zc3xx cs2102 Koko=
m.

Dan Carpenter (1):
      fix error-path NULL deref in alloc_posix_timer()

Darron Broad (1):
      V4L/DVB (9099): em28xx: Add detection for K-WORLD DVB-T 310U

David Gibson (1):
      powerpc: Fix PCI in Holly device tree

David Howells (1):
      MN10300: Fix IRQ handling

David Winn (1):
      fbcon: fix monochrome color value calculation

Dean Anderson (1):
      V4L/DVB (8963): s2255drv field count fix

Denis V. Lunev (1):
      ipv6: NULL pointer dereferrence in tcp_v6_send_ack

Devin Heitmueller (1):
      V4L/DVB (8967): Use correct XC3028L firmware for AMD ATI TV Wonder =
600

Douglas Schilling Landgraf (6):
      V4L/DVB (8883): w9968cf: Fix order of usb_alloc_urb validation
      V4L/DVB (8884): em28xx-audio: fix memory leak
      V4L/DVB (8885): cpia2_usb: fix memory leak
      V4L/DVB (8886): ov511: fix memory leak
      V4L/DVB (8887): gspca: fix memory leak
      V4L/DVB (8935): em28xx-cards: Remove duplicate entry (EM2800_BOARD_=
KWORLD_USB2800)

Gerald Schaefer (1):
      memory hotplug: missing zone->lock in test_pages_isolated()

H. Peter Anvin (1):
      x86 setup: correct segfault in generation of 32-bit reloc kernel

Haavard Skinnemoen (2):
      dw_dmac: fix copy/paste bug in tasklet
      atmel-mci: Initialize BLKR before sending data transfer command

Hans Verkuil (4):
      V4L/DVB (8789): wm8739: remove wrong kfree
      V4L/DVB (8904): cx88: add missing unlock_kernel
      V4L/DVB (8905): ov511: fix exposure sysfs attribute bug
      V4L/DVB (8919): cx18: Fix tuner audio input for Compro H900 cards

Hans de Goede (1):
      V4L/DVB (8909): gspca: PAC 7302 webcam 093a:262a added.

Heiko Carstens (2):
      iucv: Fix mismerge again.
      [S390] nohz: Fix __udelay.

Herbert Xu (1):
      ipsec: Fix pskb_expand_head corruption in xfrm_state_check_space

J.A. Magall=C3=B3n (1):
      x86: fix typo in enable_mtrr_cleanup early parameter

Jan Glauber (1):
      [S390] qdio: prevent stack clobber

Jan Kiszka (1):
      kgdb, x86: Avoid invoking kgdb_nmicallback twice per NMI

Jason Wessel (1):
      kgdb: call touch_softlockup_watchdog on resume

Jean Delvare (5):
      ALSA: ASoC: Fix cs4270 error path
      V4L/DVB (8955): bttv: Prevent NULL pointer dereference in radio_ope=
n
      V4L/DVB (8957): zr36067: Restore the default pixel format
      V4L/DVB (8958): zr36067: Return proper bytes-per-line value
      V4L/DVB (8961): zr36067: Fix RGBR pixel format

Jean-Francois Moine (3):
      V4L/DVB (8926): gspca: Bad fix of leak memory (changeset 43d2ead315=
b1).
      V4L/DVB (9080): gspca: Add a delay after writing to the sonixj sens=
ors.
      V4L/DVB (9092): gspca: Bad init values for sonixj ov7660.

Jesse Brandeburg (5):
      e1000e: reset swflag after resetting hardware
      e1000e: do not ever sleep in interrupt context
      e1000e: remove phy read from inside spinlock
      e1000e: drop stats lock
      e1000e: update version from k4 to k6

Johannes Berg (1):
      powerpc: Fix failure to shutdown with CPU hotplug

Kevin D. Kissell (3):
      [MIPS] SMTC: Fix holes in SMTC and FPU affinity support.
      [MIPS] SMTC: Close tiny holes in the SMTC IPI replay system.
      [MIPS] SMTC: Fix SMTC dyntick support.

Krzysztof Helt (1):
      fbdev: fix recursive notifier and locking when fbdev console is bla=
nked

Kumar Gala (1):
      powerpc: Fix boot hang regression on MPC8544DS

Lennert Buytenhek (1):
      orion_spi: fix handling of default transfer speed

Linus Torvalds (23):
      Merge branch 'timers-fixes-for-linus' of git://git.kernel.org/pub/s=
cm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/benh/powerpc
      Merge branch 'for-linus' of git://git.o-hand.com/linux-mfd
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel=
/git/aegl/linux-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/agk/linux-2.6-d=
m
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Check mapped ranges on sysfs resource files
      e1000e: Fix incorrect debug warning
      Fix init/main.c to use regular printk with '%pF' for initcall fn
      Merge branch 'for-linus' of git://git390.osdl.marist.edu/pub/scm/li=
nux-2.6
      Merge branch 'upstream' of git://ftp.linux-mips.org/pub/scm/upstrea=
m-linus
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jmorris/security-testing-2.6
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'timers-fixes-for-linus' of git://git.kernel.org/pub/s=
cm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'fixes' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/mchehab/v4l-dvb
      Merge branch 'upstream' of git://ftp.linux-mips.org/pub/scm/upstrea=
m-linus
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/bart/ide-2.6
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jwessel/linux-2.6-kgdb
      Linux 2.6.27-rc9

Marcin Slusarz (1):
      rtc: fix kernel panic on second use of SIGIO nofitication

Mathieu Desnoyers (1):
      Marker depmod fix core kernel list

Mauro Carvalho Chehab (1):
      V4L/DVB (8559a): Fix a merge conflict at gspca/sonixb

Michael Kerrisk (3):
      MAINTAINERS: add mailing list for man-pages
      SubmitChecklist: interfaces changes should CC linux-api@
      Documentation/HOWTO: info about interface changes should CC linux-a=
pi@vger

Michael Krufky (2):
      V4L/DVB (8978): sms1xxx: fix product name for Hauppauge WinTV MiniS=
tick
      V4L/DVB (8979): sms1xxx: Add new USB product ID for Hauppauge WinTV=
 MiniStick

Mike Isely (1):
      V4L/DVB (8892): pvrusb2: Handle USB ID 2040:2950 same as 2040:2900

Mike Rapoport (1):
      pxa2xx_spi: fix build breakage

Mikulas Patocka (2):
      dm: always allow one page in dm_merge_bvec
      dm: cope with access beyond end of device in dm_merge_bvec

Nick Piggin (2):
      inotify: fix lock ordering wrt do_page_fault's mmap_sem
      mm: tiny-shmem nommu fix

Pascal Terjan (1):
      braille_console: only register notifiers when the braille console i=
s used

Patrick Boettcher (2):
      V4L/DVB (9037): Fix support for Hauppauge Nova-S SE
      V4L/DVB (9043): S5H1420: Fix size of shadow-array to avoid overflow

Paul Jackson (1):
      cpusets: remove pj from cpuset maintainers

Paul Moore (1):
      selinux: Fix an uninitialized variable BUG/panic in selinux_secattr=
_to_sid()

Rafael J. Wysocki (2):
      ACPI: Make /proc/acpi/wakeup interface handle PCI devices (again)
      x86 ACPI: Blacklist two HP machines with buggy BIOSes

Ralf Baechle (5):
      [MIPS] Build fix: Fix irq flags type
      [MIPS] SMTC: Build fix: Fix filename in Makefile
      IDE: Fix platform device registration in Swarm IDE driver (v2)
      [MIPS] Fix CMP Kconfig configuration and mark as broken.
      [MIPS] IP27: Fix build errors if CONFIG_MAPPED_KERNEL=3Dy

Ralph Loader (1):
      V4L/DVB (9053): fix buffer overflow in uvc-video

Risto Suominen (2):
      ALSA: snd-powermac: mixers for PowerMac G4 AGP
      ALSA: snd-powermac: HP detection for 1st iMac G3 SL

Rob Sims (1):
      ASoC: Set correct name for WM8753 rec mixer output

Samuel Ortiz (2):
      mfd: Fix Kconfig accroding to the new gpiolib symbols
      mfd: Fix asic3 compilation

Sergei Shtylylov (1):
      ide-dma: fix ide_build_dmatable() for TRM290

Shane (1):
      V4L/DVB (9075): gspca: Bad check of returned status in i2c_read() s=
pca561.

Sven Wegener (2):
      leds-fsg: change order of initialization and deinitialization
      leds-pca955x: add proper error handling and fix bogus memory handli=
ng

Takashi Iwai (2):
      ALSA: hda - Fix model for Dell Inspiron 1525
      Merge branch 'asoc-fixes' into for-linus

Thomas Gleixner (6):
      hrtimer: migrate pending list on cpu offline
      hrtimer: fix migration of CB_IRQSAFE_NO_SOFTIRQ hrtimers
      hrtimer: mark migration state
      hrtimer: prevent migration of per CPU hrtimers
      e1000e: debug contention on NVM SWFLAG
      clockevents: check broadcast tick device not the clock events devic=
e

Timo Teras (1):
      af_key: Free dumping state on socket close

Tony Luck (1):
      [IA64] Put the space for cpu0 per-cpu area into .data section

Vitaliy Gusev (1):
      tcp: Fix NULL dereference in tcp_4_send_ack()

Wei Yongjun (1):
      sctp: Fix kernel panic while process protocol violation parameter

Wiktor Grebla (1):
      V4L/DVB (9103): em28xx: HVR-900 B3C0 - fix audio clicking issue

Yinghai Lu (1):
      x86: gart iommu have direct mapping when agp is present too

Zachary Amsden (2):
      x86: Fix broken LDT access in VMI
      x86, vmi: fix broken LDT access

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr

--===============6477325778171687664==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============6477325778171687664==--
