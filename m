From: Nathan Lynch <ntl@pobox.com>
Subject: [RFC/PATCH 0/3] checkpoint/restart for powerpc
Date: Wed, 28 Jan 2009 16:41:15 -0600
Message-ID: <1233182478-27113-1-git-send-email-ntl__1509.18832882798$1233182731$gmane$org@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
To: containers@lists.osdl.org
Cc: linuxppc-dev@ozlabs.org
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
