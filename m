From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr annotated tag, v2.6.31, created. v2.6.31
Date: Wed, 16 Sep 2009 14:36:53 -0400
Message-ID: <200909161836.n8GIareK001554@gorgona.ncl.cs.columbia.edu>
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

The annotated tag, v2.6.31 has been created
        at  a271b16ba5478acead8773ebe01ee9b6365154d8 (tag)
   tagging  74fca6a42863ffacaf7ba6f1936a9f228950f657 (commit)
  replaces  v2.6.31-rc9
 tagged by  Linus Torvalds
        on  Wed Sep 9 15:14:07 2009 -0700

- Log -----------------------------------------------------------------
Linux 2.6.31
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkqoKLMACgkQF3YsRnbiHLt7ngCgtDzrRqdkYVkmf0hZ6Z6m1uHC
wmsAnjDZScoBrx2UYekMj/u6R1lZfxt7
=5sSF
-----END PGP SIGNATURE-----

Chris Wilson (1):
      drm/i915: Unref old_obj on get_fence_reg() error path

Dave Airlie (1):
      drm/radeon/kms: add LTE/GTE discard + rv515 two sided stencil register.

David S. Miller (1):
      gianfar: Fix build.

Ed Cashin (1):
      aoe: allocate unused request_queue for sysfs

Jesse Barnes (1):
      drm/i915: increase default latency constant (v2 w/comment)

Linus Torvalds (7):
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/anholt/drm-intel
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/ide-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/security-testing-2.6
      Merge branch 'drm-fixes' of git://git.kernel.org/pub/scm/linux/kernel/git/airlied/drm-2.6
      i915: disable interrupts before tearing down GEM state
      Linux 2.6.31

Mimi Zohar (1):
      IMA: update ima_counts_put

Wolfram Sang (1):
      pcmcia: add CNF-CDROM-ID for ide

Zhenyu Wang (2):
      agp/intel: support for new chip variant of IGDNG mobile
      drm/i915: fix mask bits setting

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr
