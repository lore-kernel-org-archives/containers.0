From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [RFC/PATCH 0/3] checkpoint/restart for powerpc
Date: Wed, 28 Jan 2009 16:41:15 -0600
Message-ID: <1233182478-27113-1-git-send-email-ntl__16660.4525912136$1233182917$gmane$org@pobox.com>
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
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
Cc: linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

This series is a first attempt at enabling checkpoint/restart for
powerpc.  It is based on Oren Laadan's v13 checkpoint/restart series:

http://lkml.org/lkml/2009/1/27/227

Nathan Lynch (3):
  powerpc: bare minimum checkpoint/restart implementation
  powerpc: wire up checkpoint and restart syscalls
  allow checkpoint/restart on powerpc

 arch/powerpc/include/asm/checkpoint_hdr.h |   40 +++++
 arch/powerpc/include/asm/systbl.h         |    2 +
 arch/powerpc/include/asm/unistd.h         |    4 +-
 arch/powerpc/mm/Makefile                  |    1 +
 arch/powerpc/mm/checkpoint.c              |  261 +++++++++++++++++++++++++++++
 checkpoint/Kconfig                        |    2 +-
 6 files changed, 308 insertions(+), 2 deletions(-)
 create mode 100644 arch/powerpc/include/asm/checkpoint_hdr.h
 create mode 100644 arch/powerpc/mm/checkpoint.c
