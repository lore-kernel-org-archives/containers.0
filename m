From: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 0/9] OpenVZ kernel based checkpointing/restart
Date: Wed,  3 Sep 2008 14:57:47 +0400
Message-ID: <1220439476-16465-1-git-send-email-major@openvz.org>
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
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

This patchset introduces kernel based checkpointing/restart as it is
implemented in OpenVZ project. This patchset has limited functionality and
are able to checkpoint/restart only single process. Recently Oren Laaden
sent another kernel based implementation of checkpoint/restart. The main
differences between this patchset and Oren's patchset are:

* In this patchset checkpointing initiated not from the process
(right now we do not have a container, only namespaces), Oren's patchset
performs checkpointing from the process context.

* Restart in this patchset is initiated from process, which restarts a new
process (in new namespaces) with saved state. Oren's patchset uses the same
process from which restart was initiated and restore saved state over it.

* Checkpoint/restart functionality in this patchset is implemented as a kernel
module


As checkpointing is initiated not from the process which state should be saved
we should freeze a process before saving its state. Right now Container Freezer
from Matt Helsley can be used for this.

This patchset introduce only a concept how kernel based checkpointing/restart
can be implemented and are able to checkpoint/restart only a single process
with simple VMAs. 

I've tried to split my patchset in small patches to make review more easier.
