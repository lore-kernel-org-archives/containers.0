From: Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH 0/5] ftrace: rebase patches on top of tip/master + some extras
Date: Wed, 26 Nov 2008 00:16:22 -0500
Message-ID: <20081126051622.134970943@goodmis.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752990AbYKZFR0@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, containers@lists.osdl.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>
List-Id: containers.vger.kernel.org

Ingo,

Here's my patches rebased against latest tip/master. I also
added a couple of goodies at the end to enhance the function-graph
tracer.

The first patch is a repost of the set_ftrace_pid, so I am Cc'ing
the container guys so they can abuse me some more ;-)

The following patches are in:

  git://git.kernel.org/pub/scm/linux/kernel/git/rostedt/linux-2.6-trace.git

    branch: tip/devel


Steven Rostedt (5):
      ftrace: add function tracing to single thread
      ftrace: use code patching for ftrace graph tracer
      ftrace: let function tracing and function return run together
      ftrace: add thread comm to function graph tracer
      ftrace: add cpu annotation for function graph tracer

----
 Documentation/ftrace.txt             |   79 ++++++++++
 arch/x86/kernel/entry_32.S           |    5 +
 arch/x86/kernel/ftrace.c             |   48 ++++++-
 include/linux/ftrace.h               |    5 +
 kernel/trace/ftrace.c                |  264 +++++++++++++++++++++++++--------
 kernel/trace/trace.c                 |    2 +-
 kernel/trace/trace.h                 |    1 +
 kernel/trace/trace_functions_graph.c |   51 +++++--
 8 files changed, 373 insertions(+), 82 deletions(-)

-- 
