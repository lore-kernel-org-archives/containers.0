From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 0/8] checkpoint: improve handling of pending signals
Date: Tue, 13 Jul 2010 10:44:16 -0500
Message-ID: <1279035864-10533-1-git-send-email-ntl@pobox.com>
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
To: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Oren,

The following series improves the support for checkpointing pending
signal state and (I think) is exhaustive.  These have been tested on
top of your ckpt-v22-dev branch on x86 and powerpc systems for the
last couple of weeks.

Nathan Lynch (8):
  checkpoint: model ckpt_siginfo on signalfd_siginfo
  checkpoint: add const qualifiers to siginfo handlers
  checkpoint: clean up pending posix timer signal handling
  checkpoint: clean up __SI_POLL siginfo save/restore
  checkpoint: clean up __SI_FAULT siginfo save/restore
  checkpoint: clean up __SI_CHLD siginfo save/restore
  checkpoint: __SI_KILL does not use si_ptr
  checkpoint: handle siginfo->si_code < 0

 include/linux/checkpoint_hdr.h |   29 +++++----
 kernel/signal.c                |  134 +++++++++++++++++++++++++++-------------
 2 files changed, 107 insertions(+), 56 deletions(-)
