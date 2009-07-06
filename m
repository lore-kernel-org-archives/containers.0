From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: build breaks when checkpoint unimplemented by arch
Date: Mon, 06 Jul 2009 16:06:15 -0500
Message-ID: <m3my7hv7w8.fsf@pobox.com>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Oren,

With ckpt-v17-rc1 (as well as ckpt-v16-dev) the powerpc build is broken:

In file included from include/linux/checkpoint.h:28,
                 from kernel/exit.c:53:
include/linux/checkpoint_hdr.h:42:32: error: asm/checkpoint_hdr.h: No such file or directory
In file included from include/linux/checkpoint.h:28,
                 from kernel/exit.c:53:
include/linux/checkpoint_hdr.h:410: error: 'CKPT_ARCH_NSIG' undeclared here (not in a function)
make[1]: *** [kernel/exit.o] Error 1


It appears that any architecture which does not supply
asm/checkpoint_hdr.h is broken in the same way.

Either all architectures need to supply asm/checkpoint_hdr.h (and define
CKPT_ARCH_NSIG), or there needs to be some other fix which allows
as-yet-unsupported arches to build..
