From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr annotated tag, v2.6.27, created. v2.6.27
Date: Wed, 16 Sep 2009 14:36:25 -0400
Message-ID: <200909161836.n8GIaPfd000861@gorgona.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3966827724354499014=="
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

--===============3966827724354499014==
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by smtp1.linux-foundation.org id n8GIdVUG003367

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The annotated tag, v2.6.27 has been created
        at  4b5127df968616dee2f4775d795198878ef1638b (tag)
   tagging  3fa8749e584b55f1180411ab1b51117190bac1e5 (commit)
  replaces  v2.6.27-rc9
 tagged by  Linus Torvalds
        on  Thu Oct 9 15:14:01 2008 -0700

- Log -----------------------------------------------------------------
Linux 2.6.27
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkjugi0ACgkQF3YsRnbiHLuCFQCfVHUOrd2hL45otyOKBSxj/A9F
3QoAoK5GhSrPcKfMR0b1BYoJB+TGgivq
=3D5QrL
-----END PGP SIGNATURE-----

Ali Saidi (1):
      tcp: Fix possible double-ack w/ user dma

Alistair John Strachan (2):
      hwmon: (abituguru3) Enable reading from AUX3 fan on Abit AT8 32X
      hwmon: (abituguru3) Enable DMI probing feature on Abit AT8 32X

Corentin Chary (1):
      eeepc-laptop: Fix hwmon interface

Daniele Lacamera (1):
      tcp: Fix tcp_hybla zero congestion window growth with small rho and=
 large cwnd.

Darrick J. Wong (2):
      hwmon: Define sysfs interface for energy consumption register
      hwmon: (adt7473) Fix some bogosity in documentation file

David S. Miller (3):
      Revert "ax25: Fix std timer socket destroy handling."
      ax25: Quick fix for making sure unaccepted sockets get destroyed.
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/holtmann/bluetooth-2.6

Herbert Xu (1):
      net: Fix netdev_run_todo dead-lock

Jarek Poplawski (1):
      netrom: Fix sock_orphan() use in nr_release

Jean Delvare (1):
      hwmon: (it87) Prevent power-off on Shuttle SN68PT

Linus Torvalds (7):
      Revert "V4L/DVB (8904): cx88: add missing unlock_kernel"
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'upstream' of git://ftp.linux-mips.org/pub/scm/upstrea=
m-linus
      Merge branch 'fixes' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/davej/cpufreq
      Merge branch 'hwmon-for-linus' of git://jdelvare.pck.nerim.net/jdel=
vare-2.6
      Don't allow splice() to files opened with O_APPEND
      Linux 2.6.27

Marcel Holtmann (3):
      [Bluetooth] Fix double frees on error paths of btusb and bpa10x dri=
vers
      [Bluetooth] Add reset quirk for new Targus and Belkin dongles
      [Bluetooth] Add reset quirk for A-Link BlueUSB21 dongle

Matt Mackall (2):
      SLOB: fix bogus ksize calculation
      SLOB: fix bogus ksize calculation fix

N=C3=A9meth M=C3=A1rton (1):
      [CPUFREQ] correct broken links and email addresses

Patrick McHardy (1):
      net: only invoke dev->change_rx_flags when device is UP

Ralf Baechle (1):
      [MIPS] Sibyte: Register PIO PATA device only for Swarm and Litte Su=
r

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr

--===============3966827724354499014==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============3966827724354499014==--
