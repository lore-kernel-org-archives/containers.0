From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: dm-ioband RPM packages
Date: Fri, 26 Jun 2009 17:46:39 +0900 (JST)
Message-ID: <20090626.174639.193685940.ryov__31940.8877905973$1246006096$gmane$org@valinux.co.jp>
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
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org
List-Id: containers.vger.kernel.org

Hi all,

I'm pleased to announce that the new dm-ioband RPM package (v1.12.0)
has been released at:
  http://sourceforge.net/apps/trac/ioband/wiki/dm-ioband

dm-ioband provides disk bandwidth control on per partition, per user,
per process and per virtual machine (such as KVM or Xen) basis.

The RPM packages are for Red Hat Enterprise Linux 5.x and CentOS
5.x. They were tested on RHEL 5.2 and CentOS 5.3 and will also work on
other 5.x versions.

The major change of this release is that a new bandwidth control
policy "range-bw" is supported. This policy is developed by Dong-Jae
Kang, and it allows users to set a minimum and maximum I/O bandwidth
by absolute numbers. The minimum I/O bandwidth should be guaranteed
for stable performance or reliability of specific process groups, and
I/O bandwidth over the maximum limit should be throttled to protect
the limited I/O resource from over-provisioning in unnecessary usage
or to reserve the I/O bandwidth for another use.

Please visit our website for more information.
  http://sourceforge.net/apps/trac/ioband/wiki/dm-ioband

Any comments and suggestions are welcome!

Thanks,
Ryo Tsuruta
