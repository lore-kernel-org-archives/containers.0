From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: [PATCH 0/2] dm-ioband v0.0.3: The I/O bandwidth controller:
 Introduction
Date: Tue, 05 Feb 2008 19:17:35 +0900 (JST)
Message-ID: <20080205.191735.193708307.ryov__22539.617381017$1202206794$gmane$org@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
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
Cc: agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi everyone,

This is dm-ioband version 0.0.3 release.

Dm-ioband is an I/O bandwidth controller implemented as a device-mapper driver,
which gives specified bandwidth to each job running on the same physical
device.

Changes since 0.0.2 (23rd January):
   - Ported to linux-2.6.24.
   - Rename the name of this device-mapper device as "ioband."
   - The output format of "dmsetup table" can be recognized by "dmsetup
     create/load/reload."
   - Add a new feature to block processes requesting BIOs in case the number
     of the uncompleted BIOs becomes too large.
   - Gid can be used as an ioband group type.
   - Support "dmsetup suspend --noflush."
   - Fix the problem that "dmsetup detach" doesn't wait the completion of
     all the BIOs in the detaching group.
   - Fix the problem that "dmsetup message attach" can't accept ID 0.
   - Code cleanups. Use prefix "dm_" for the global symbols.
   - Add examples in the document.

Thanks,
Ryo Tsuruta
