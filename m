From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr annotated tag, v2.6.31-rc9, created. v2.6.31-rc9
Date: Wed, 16 Sep 2009 14:37:00 -0400
Message-ID: <200909161837.n8GIb07m001735@gorgona.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3910773831484482190=="
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

--===============3910773831484482190==
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by smtp1.linux-foundation.org id n8GItwgS005252

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The annotated tag, v2.6.31-rc9 has been created
        at  0827eb5df631ed1756653faf74248a9524f202cd (tag)
   tagging  e07cccf4046978df10f2e13fe2b99b2f9b3a65db (commit)
  replaces  v2.6.31-rc8
 tagged by  Linus Torvalds
        on  Sat Sep 5 16:38:24 2009 -0700

- Log -----------------------------------------------------------------
Linux 2.6.31-rc9
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkqi9nUACgkQF3YsRnbiHLtSjACfdPLZfv4D3poZEmRn0rGJaPpK
vBAAn2WPrVJ2H6UWh5e86uN/CNklnL0K
=3DOeuC
-----END PGP SIGNATURE-----

Anton Vorontsov (1):
      mtd: m25p80: fix null pointer dereference bug

Bartlomiej Zolnierkiewicz (1):
      ata_piix: parallel scanning on PATA needs an extra locking

Benjamin Herrenschmidt (1):
      lmb: Also remove __init from lmb_end_of_RAM() declaration in lmb.h

Brian Rogers (1):
      inotify: do not send a block of zeros when no pathname is available

Bruno Pr=C3=A9mont (1):
      drm/i915: Check if BIOS enabled dual-channel LVDS on 8xx, not only =
on 9xx

Chris Wright (1):
      PCI SR-IOV: correct broken resource alignment calculations

Christoph Hellwig (1):
      xfs: actually enable the swapext compat handler

Clemens Ladisch (2):
      sound: oxygen: fix MCLK rate for 192 kHz playback
      sound: oxygen: handle cards with missing EEPROM

Dave Andrews (1):
      Input: atkbd - add Compaq Presario R4000-series repeat quirk

David Howells (1):
      nommu: fix error handling in do_mmap_pgoff()

David M=C3=BCller (ELSOFT AG) (1):
      drm/i915: Improve CRTDDC mapping by using VBT info

David S. Miller (4):
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-2.6
      pkt_sched: Revert tasklet_hrtimer changes.
      sparc64: Kill spurious NMI watchdog triggers by increasing limit to=
 30 seconds.
      sparc64: Fix bootup with mcount in some configs.

Dimitri Gorokhovik (2):
      mtd: nftl: write support is broken
      mtd: nftl: fix offset alignments

Dmitry Torokhov (1):
      Input: i8042 - add Acer Aspire 5536 to the nomux list

Dominik Brodowski (1):
      [CPUFREQ] Re-enable cpufreq suspend and resume code

Eric Anholt (1):
      drm/i915: Fix CPU-spinning hangs related to fence usage by using an=
 LRU.

Eric Dumazet (2):
      tc: Fix unitialized kernel memory leak
      slub: Fix kmem_cache_destroy() with SLAB_DESTROY_BY_RCU

Eric Paris (2):
      inotify: fix length reporting and size checking
      inotify: update the group mask on mark addition

Grant Grundler (1):
      parisc: fix warning in traps.c

H. Peter Anvin (1):
      x86, xen: Initialize cx to suppress warning

Herbert Xu (1):
      crypto: skcipher - Fix skcipher_dequeue_givcrypt NULL test

Ian Kent (1):
      autofs4 - fix missed case when changing to use struct path

Ingo Molnar (2):
      perf_counters: Increase paranoia level
      modules: Fix build error in the !CONFIG_KALLSYMS case

Jarek Poplawski (1):
      net: sk_free() should be allowed right after sk_alloc()

Jeremy Fitzhardinge (1):
      x86, xen: Suppress WP test on Xen

Jiri Bohac (1):
      [IA64] fix csum_ipv6_magic()

Jiri Slaby (1):
      toshiba_acpi: return on a fail path

Joe Perches (1):
      V4L/DVB (12564a): MAINTAINERS: Update gspca sn9c20x name style

Jonathan Brassow (4):
      dm log: fix userspace status output
      dm log: remove incorrect field from userspace table output
      dm raid1: do not allow log_failure variable to unset after being se=
t
      dm log: userspace add luid to distinguish between concurrent log in=
stances

Keith Packard (1):
      ACPI: don't free non-existent backlight in acpi video module

Kiyoshi Ueda (1):
      dm multipath: fix oops when request based io fails when no paths

Lin Ming (1):
      ACPICA: Windows compatibility fix: same buffer/string store

Linus Torvalds (27):
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for-linus' of git://git.infradead.org/users/eparis/no=
tify
      Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel=
/git/lenb/linux-acpi-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/anholt/drm-intel
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/mchehab/linux-2.6
      Merge branch 'fix/hda' of git://git.kernel.org/pub/scm/linux/kernel=
/git/tiwai/sound-2.6
      n_tty: do O_ONLCR translation as a single write
      pty: don't limit the writes to 'pty_space()' inside 'pty_write()'
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/jlbec/ocfs2
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/dtor/input
      Merge branch 'perfcounters-fixes-for-linus' of git://git.kernel.org=
/pub/scm/linux/kernel/git/tip/linux-2.6-tip
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jbarnes/pci-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/agk/linux-2.6-d=
m
      Merge branch 'slab/urgent' of git://git.kernel.org/pub/scm/linux/ke=
rnel/git/penberg/slab-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tj/percpu
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/ryusuke/nilfs2
      Merge branch 'for-linus' of git://oss.sgi.com/xfs/xfs
      Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel=
/git/aegl/linux-2.6
      Merge branch 'fixes' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/davej/cpufreq
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/herbert/crypto-=
2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'fix/oxygen' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/tiwai/sound-2.6
      Merge branch 'for-linus' of git://git.kernel.dk/linux-2.6-block
      Merge git://git.infradead.org/~dwmw2/mtd-2.6.31
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/ieee1394/linux1394-2.6
      Linux 2.6.31-rc9

Luck, Tony (1):
      [IA64] Fix warning in dma-mapping.c

Ma Ling (2):
      drm/i915: Always use SDVO_B detect bit for SDVO output detection.
      drm/i915: Set crtc/clone mask in different output devices

Massimo Cirillo (1):
      JFFS2: add missing verify buffer allocation/deallocation

Mauro Carvalho Chehab (1):
      V4L/DVB (12449): adds webcam for Micron device MT9M111 0x143A to em=
28xx

Mel Gorman (1):
      page-allocator: always change pageblock ownership when anti-fragmen=
tation is disabled

Michael Krufky (1):
      V4L/DVB (12446): sms1xxx: restore GPIO functionality for all Hauppa=
uge devices

Mike Snitzer (3):
      dm snapshot: implement iterate devices
      dm table: add more context to terse warning messages
      dm stripe: expose correct io hints

Mikulas Patocka (5):
      dm table: fix queue_limit checking device iterator
      dm snapshot: refactor zero_disk_area to use chunk_io
      dm snapshot: fix header corruption race on invalidation
      dm exception store: split set_chunk_size
      dm snapshot: fix on disk chunk size validation

Nicolas Pitre (1):
      ext2: fix unbalanced kmap()/kunmap()

Nikanth Karthikesan (1):
      block: Allow changing max_sectors_kb above the default 512

Oleg Nesterov (2):
      workqueues: introduce __cancel_delayed_work()
      exec: do not sleep in TASK_TRACED under ->cred_guard_mutex

Paul Mackerras (1):
      perf_counter/powerpc: Fix cache event codes for POWER7

Peter Zijlstra (1):
      perf_counter: Fix /0 bug in swcounters

Randy Dunlap (1):
      V4L/DVB (12502): gspca - sn9c20x: Fix gscpa sn9c20x build errors.

Roderick Colenbrander (1):
      powerpc: Fix i8259 interrupt driver kernel crash on ML510

Roel Kluin (2):
      drm/i915: Fix typo that broke SVID1 in intel_sdvo_multifunc_encoder=
()
      V4L/DVB (12457): zr364: wrong indexes

Ryusuke Konishi (1):
      nilfs2: fix preempt count underflow in nilfs_btnode_prepare_change_=
key

Sean Young (1):
      drm/i915: Set the multiplier for SDVO on G33 platform

Shine Liu (1):
      V4L/DVB (12495): em28xx: Don't call em28xx_ir_init when disable_ir =
is true

Stefan Richter (4):
      firewire: core: fix crash in iso resource management
      firewire: ohci: fix Agere FW643 and multiple cameras
      firewire: ohci: fix Ricoh R5C832, video reception
      firewire: sbp2: fix freeing of unallocated memory

Sunil Mushran (1):
      ocfs2: ocfs2_write_begin_nolock() should handle len=3D0

Takashi Iwai (2):
      ALSA: hda - Add missing mux check for VT1708
      ALSA: hda - Fix MacBookPro 3,1/4,1 quirk with ALC889A

Tao Ma (1):
      ocfs2: invalidate dentry if its dentry_lock isn't initialized.

Tejun Heo (1):
      percpu: don't assume existence of cpu0

Toru UCHIYAMA (1):
      gianfar: gfar_remove needs to call unregister_netdev()

Trond Myklebust (1):
      SUNRPC: Fix rpc_task_force_reencode

Udi Atar (2):
      V4L/DVB (12450): Siano: Fixed SDIO compilation bugs
      V4L/DVB (12451): Update KConfig File to enable SDIO and USB interfa=
ces

Yinghai Lu (1):
      x86: Fix vSMP boot crash

Zhu Yi (1):
      ipw2200: firmware DMA loading rework

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr

--===============3910773831484482190==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============3910773831484482190==--
