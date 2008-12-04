From: Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH 0/3] ftrace: clean ups for tip
Date: Thu, 04 Dec 2008 00:26:38 -0500
Message-ID: <20081204052638.425740534@goodmis.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756127AbYLDF1t@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave@linux.vnet.ibm.com>, containers@lists.osdl.org, Eric Biederman <ebiederm@xmission.com>, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>
List-Id: containers.vger.kernel.org

Ingo,

The following patches are to have ftrace use the pid struct
for filtering on pids.

The following patches are in:

  git://git.kernel.org/pub/scm/linux/kernel/git/rostedt/linux-2.6-trace.git

    branch: tip/devel


Steven Rostedt (3):
      fix the do_each_pid_task macro
      ftrace: use struct pid
      ftrace: add ability to only trace swapper tasks

----
 include/linux/pid.h   |    4 +-
 kernel/trace/ftrace.c |  128 ++++++++++++++++++++++++++++++++++++------------
 kernel/trace/trace.h  |    4 +-
 3 files changed, 100 insertions(+), 36 deletions(-)
-- 
