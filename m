From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr annotated tag, v2.6.28, created. v2.6.28
Date: Wed, 16 Sep 2009 14:36:28 -0400
Message-ID: <200909161836.n8GIaSfX000961@gorgona.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0887627565054532199=="
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

--===============0887627565054532199==
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by smtp1.linux-foundation.org id n8GIqH9k004878

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The annotated tag, v2.6.28 has been created
        at  8a38e7fd7a30cd44be954f9a3b062e607cec5d41 (tag)
   tagging  4a6908a3a050aacc9c3a2f36b276b46c0629ad91 (commit)
  replaces  v2.6.28-rc9
 tagged by  Linus Torvalds
        on  Wed Dec 24 15:26:58 2008 -0800

- Log -----------------------------------------------------------------
Linux 2.6.28
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAklSxUcACgkQF3YsRnbiHLtgHACfYFKiZBoZ2QVoeYTNOKBLevwq
sIkAnA2TiLltms7+p+DPA8+scOL+f92d
=3D3MdI
-----END PGP SIGNATURE-----

Andi Kleen (1):
      x86: re-enable MCE on secondary CPUS after suspend/resume

Antti Sepp=C3=A4l=C3=A4 (1):
      V4L/DVB (9781): [PATCH] Cablestar 2 I2C retries (fix CableStar2 sup=
port)

Bjorn Helgaas (2):
      x86 gart: don't complain if no AMD GART found
      ACPI: fix 2.6.28 acpi.debug_level regression

Brian King (1):
      [SCSI] ibmvstgt: move crq_queue_create to the end of initialization

Chris Elston (1):
      rtc: rtc-isl1208: reject invalid dates

Dave Airlie (2):
      drm/i915: GEM on PAE has problems - disable it for now.
      drm/radeon: fix correctness of irq_enabled check for radeon.

David Daney (2):
      MIPS: Fix preprocessor warnings flaged by GCC 4.4
      MIPS: MIPS64R2: Fix buggy __arch_swab64

Devin Heitmueller (2):
      V4L/DVB (9780): dib0700: Stop repeating after user stops pushing bu=
tton
      V4L/DVB (9920): em28xx: fix NULL pointer dereference in call to VID=
IOC_INT_RESET command

Dmitry Adamushko (1):
      x86: fix resume (S2R) broken by Intel microcode module, on A110L

Duane Griffin (1):
      9p: Remove potentially bad parameter from function entry debug prin=
t.

Eric Anholt (1):
      drm/i915: Don't return busy for buffers left on the flushing list.

Evgeniy Polyakov (1):
      w1: fix slave selection on big-endian systems

Hans Verkuil (1):
      V4L/DVB (9906): v4l2-compat: test for unlocked_ioctl as well.

Harry Ciao (1):
      edac: fix edac core deadlock when removing a device

Herton Ronaldo Krzesinski (1):
      ALSA: hda - Add missing terminators in patch_sigmatel.c

Hidetoshi Seto (1):
      PCI: fix aer resume sanity check

Hillier, Gernot (1):
      [SCSI] aacraid: disable Dell Percraid quirk on Adaptec 2200S and 21=
20S

Ingo Molnar (2):
      Merge branch 'iommu-fixes-2.6.28' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/joro/linux-2.6-iommu into x86/urgent
      x86: disable X86_PTRACE_BTS

James Bottomley (2):
      [SCSI] scsi_lib: only call scsi_unprep_request() under queue lock
      [SCSI] mpt fusion: clear list of outstanding commands on host reset

James Chapman (1):
      ppp: fix segfaults introduced by netdev_priv changes

Jim Paris (1):
      V4L/DVB (9875): gspca - main: Fix vidioc_s_jpegcomp locking.

Jiri Slaby (1):
      V4L/DVB (9908a): MAINTAINERS: mark linux-uvc-devel as subscribers o=
nly

Joerg Roedel (3):
      AMD IOMMU: allocate rlookup_table with __GFP_ZERO
      AMD IOMMU: set cmd buffer pointers to zero manually
      AMD IOMMU: panic if completion wait loop fails

Joerg Schirottke (1):
      ALSA: hda - Add quirk for Dell Studio 17

Julia Lawall (2):
      fs/9p: change simple_strtol to simple_strtoul
      drivers/ide/{cs5530.c,sc1200.c}: Move a dereference below a NULL te=
st

Justin Chen (1):
      PCI hotplug: acpiphp wants a 64-bit _SUN

Kenji Kaneshige (1):
      PCI: pciehp: fix unexpected power off with pciehp_force

Kyle McMartin (1):
      parisc: disable UP-optimized flush_tlb_mm

Li Zefan (1):
      cgroups: avoid accessing uninitialized data in failure path

Linus Torvalds (17):
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jbarnes/pci-2.6
      Merge branch 'for-linus' of git://neil.brown.name/md
      Merge branch 'drm-fixes' of git://git.kernel.org/pub/scm/linux/kern=
el/git/airlied/drm-2.6
      Merge branch 'for-linus' of git://git.kernel.dk/linux-2.6-block
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/jejb/scsi-rc-fi=
xes-2.6
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/ericvh/v9fs
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'upstream' of git://ftp.linux-mips.org/pub/scm/upstrea=
m-linus
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/bart/ide-2.6
      Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel=
/git/lenb/linux-acpi-2.6
      Merge branch 'drm-fixes' of git://git.kernel.org/pub/scm/linux/kern=
el/git/airlied/drm-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/mchehab/linux-2.6
      Linux 2.6.28

Mauro Carvalho Chehab (1):
      V4L/DVB (9885): drivers/media Kconfig's: fix bugzilla #12204

Mike Christie (1):
      [SCSI] libiscsi REGRESSION: fix passthrough support with older iscs=
i tools

Neil Horman (1):
      PCI hotplug: ibmphp: Fix module ref count underflow

NeilBrown (1):
      md: Don't read past end of bitmap when reading bitmap.

Sharyathi Nagesh (1):
      cgroups: suppress bogus warning messages

Stanley Miao (1):
      ALSA: Fix a Oops bug in omap soc driver.

Stephen M. Cameron (1):
      cciss: fix problem that deleting multiple logical drives could caus=
e a panic

Takashi Iwai (5):
      ALSA: hda - Fix silent HP output on D975
      ALSA: Revert "ALSA: hda: removed unneeded hp_nid references"
      ALSA: hda - Add no-jd model for IDT 92HD73xx
      ALSA: hda - Remove non-working headphone control for Dell laptops
      Merge branch 'fix/asoc' into for-linus

Thomas Gleixner (1):
      Null pointer deref with hrtimer_try_to_cancel()

Wei Yongjun (1):
      net: Fix module refcount leak in kernel_accept()

Wu Fengguang (2):
      ACPI: don't cond_resched() when irqs_disabled()
      9p: convert d_iname references to d_name.name

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr

--===============0887627565054532199==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============0887627565054532199==--
