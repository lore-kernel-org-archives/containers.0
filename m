From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 0/9] user-cr: update to eclone API; add nsexeccwp
Date: Tue, 17 Nov 2009 18:55:37 -0600
Message-ID: <1258505746-31182-1-git-send-email-ntl@pobox.com>
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
Cc: Oren-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

The following series adds support for eclone to the arch code,
introduces the nsexeccwp utility which allows for isolated testing of
eclone's pid-choosing capability, switches the restart utility to
eclone, and finally phases out the clone_with_pids support code.

I've verified that nsexeccwp works correctly on x86 and powerpc with a
mainline kernel with eclone support (but not checkpoint/restart); s390
needs to be built and tested (Serge?).

Based on ckpt-v19-rc1.

Nathan Lynch (8):
  user-cr: add eclone/clone_args header
  user-cr: x86_32 eclone wrapper
  user-cr: s390 eclone wrapper
  user-cr: ppc32 eclone wrapper
  user-cr: use eclone API for restart
  user-cr: remove x86_32 clone_with_pids
  user-cr: remove s390 clone_with_pids
  user-cr: remove powerpc clone_with_pids

Serge E. Hallyn (1):
  user-cr: add nsexeccwp to test eclone

 Makefile       |    5 +-
 clone.h        |   54 +++++++++
 clone_ppc.c    |   58 ++++++-----
 clone_ppc_.S   |   52 +++++-----
 clone_s390x.c  |   97 ++++++++++-------
 clone_x86_32.c |   87 ++++++++-------
 eclone.h       |   25 +++++
 nsexeccwp.c    |  329 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 restart.c      |   46 +++------
 9 files changed, 588 insertions(+), 165 deletions(-)
 create mode 100644 clone.h
 create mode 100644 eclone.h
 create mode 100644 nsexeccwp.c
