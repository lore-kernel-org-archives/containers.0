From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 0/4] user-cr: powerpc support etc
Date: Wed, 16 Sep 2009 04:27:47 -0500
Message-ID: <1253093271-16357-1-git-send-email-ntl@pobox.com>
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
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Patch 1 is an obvious fix, I think.

The rest is an assortment of hacks I've employed to get this building
and working on powerpc.

Nathan Lynch (4):
  fix rename fallout
  restart: (build fix hack) define sa_family_t and struct linger
  mktree: initial powerpc support hacks
  makefile hack for powerpc

 Makefile      |    5 +++-
 clone_ppc32.S |   79 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 powerpc_asm.h |   46 +++++++++++++++++++++++++++++++++
 restart.c     |   31 ++++++++++++++++++++++
 4 files changed, 160 insertions(+), 1 deletions(-)
 create mode 100644 clone_ppc32.S
 create mode 100644 powerpc_asm.h
