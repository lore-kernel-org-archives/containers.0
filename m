From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr annotated tag, v2.6.28-rc2, created. v2.6.28-rc2
Date: Wed, 16 Sep 2009 14:36:30 -0400
Message-ID: <200909161836.n8GIaUXO001001@gorgona.ncl.cs.columbia.edu>
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

The annotated tag, v2.6.28-rc2 has been created
        at  5eb14db1f80df4eb0ecb0976e47e8e287e3175fc (tag)
   tagging  0173a3265b228da319ceb9c1ec6a5682fd1b2d92 (commit)
  replaces  v2.6.28-rc1
 tagged by  Linus Torvalds
        on  Sun Oct 26 12:13:52 2008 -0700

- Log -----------------------------------------------------------------
Linux 2.6.28-rc2
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkkEwXQACgkQF3YsRnbiHLuoiwCfcX0FvXg+rB1vevdwUJdUcb6Z
GsUAoLhiSmjItWKjmTgnLsHLgPJp/L7c
=Z+zW
-----END PGP SIGNATURE-----

Al Viro (2):
      fix allmodconfig breakage
      arm ide breakage

Alistair John Strachan (2):
      hwmon: (abituguru3) Cosmetic whitespace fixes
      hwmon: (abituguru3) enable DMI probing feature on AW9D-MAX

Arjan van de Ven (2):
      wireless: fix regression caused by regulatory config option
      select: deal with math overflow from borderline valid userland data

Davide Libenzi (1):
      epoll: avoid double-inserts in case of EFAULT

Francois Romieu (1):
      r8169: revert "read MAC address from EEPROM on init"

Geert Uytterhoeven (2):
      hwmon: (w83781d) Fix linking when built-in
      m68k: Disable Amiga serial console support if modular

Jean Delvare (4):
      hwmon-vid: Add support for AMD family 10h CPUs
      hwmon: (lm90) Fix handling of hysteresis value
      hwmon: (lm90) Add support for the LM99 16 degree offset
      hwmon: (adt7473) Fix voltage conversion routines

Jens Axboe (1):
      libata: fix bug with non-ncq devices

Linus Torvalds (4):
      Revert "Call init_workqueues before pre smp initcalls."
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tytso/ext4
      Merge branch 'hwmon-for-linus' of git://jdelvare.pck.nerim.net/jdelvare-2.6
      Linux 2.6.28-rc2

Stephen Rothwell (1):
      cgroup: remove unused variable

Theodore Ts'o (2):
      ext3: Fix duplicate entries returned from getdents() system call
      ext4: Fix duplicate entries returned from getdents() system call

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr
