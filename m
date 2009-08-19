From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [RFC] checkpoint/restart of PTYs
Date: Tue, 18 Aug 2009 20:42:26 -0400
Message-ID: <1250642549-23656-1-git-send-email-orenl@librato.com>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

This short series adds support for checkpoint and restart of PTYs. It
is mildly tested on top of ckpt-v17-dev (with test/pty from user-cr).

I'm not an expert on PTYs, TTYs, line disciplines and the like,
comments are mostly welcome:

* Only handles PTYs related to open files (no signal->...)

* What (additional) values we need to sanitize on restart ?

* What additional locking should be in place ? (especially checkpoint)

* Need to save/restore echo buffer (and position) ?

* /dev/ptmx and /dev/pts/... paths are currently hardcoded

* For restart without restoring PIDs, need to ensure the session and
  pgrp are either -1 (none) or limited to a PID value that belongs to
  the restarted subtree.

* For restart with restoring PIDs, need to create on-the-fly session
  and/or pgrp PIDs that do not exist (e.g. of a dead process). This is
  also necessary to correctly restore pgrp, regardless of PTYs.

* Other security concerns ? ...

* and probably more :p

Oren.
