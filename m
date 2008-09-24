From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: [PATCH 0/8] I/O bandwidth controller and BIO tracking
Date: Wed, 24 Sep 2008 19:10:59 +0900 (JST)
Message-ID: <20080924.191059.193698894.ryov__4620.92638849771$1222251299$gmane$org@valinux.co.jp>
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
Cc: fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org
List-Id: containers.vger.kernel.org

Hi everyone,

These patchsets are the new releases of dm-ioband and bio-cgroup which
are ported to 2.6.27-rc5-mm1.

dm-ioband
  Dm-ioband is an I/O bandwidth controller implemented as a
  device-mapper driver, which gives specified bandwidth to each job
  running on the same block device. A job is a group of processes
  with the same pid or pgrp or uid or a virtual machine such as KVM
  or Xen. A job can also be a cgroup by applying the bio-cgroup patch.

bio-cgroup
  Bio-cgroup is a BIO tracking mechanism, which is implemented on the
  cgroup memory subsystem. With the mechanism, it is able to determine
  which cgroup each of bio belongs to, even when the bio is one of
  delayed-write requests issued from a kernel thread such as pdflush.

The following is a list of patches:

  [PATCH 1/8] dm-ioband: Patch of device-mapper driver
  [PATCH 2/8] dm-ioband: Documentation of design overview, installation,
                         command reference and examples.
  [PATCH 3/8] bio-cgroup: Introduction
  [PATCH 4/8] bio-cgroup: Split the cgroup memory subsystem into two parts
  [PATCH 5/8] bio-cgroup: Remove a lot of "#ifdef"s
  [PATCH 6/8] bio-cgroup: Implement the bio-cgroup
  [PATCH 7/8] bio-cgroup: Add a cgroup support to dm-ioband
  [PATCH 8/8] bio-cgroup: Dirty page tracking

Please see the following site for more information:
  Linux Block I/O Bandwidth Control Project
  http://people.valinux.co.jp/~ryov/bwctl/

Thanks,
Ryo Tsuruta
