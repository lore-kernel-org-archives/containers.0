From: Ingo Molnar <mingo@elte.hu>
Subject: [PATCH] tracing: fix typo
Date: Thu, 4 Dec 2008 09:30:59 +0100
Message-ID: <20081204083059.GA8131@elte.hu>
References: <20081204052638.425740534@goodmis.org> <20081204081008.GC32594@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754892AbYLDIbm@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081204081008.GC32594@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave@linux.vnet.ibm.com>, containers@lists.osdl.org, Eric Biederman <ebiederm@xmission.com>, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>
List-Id: containers.vger.kernel.org


small fixlet below.

	Ingo

-------------->
From a3c1b9d13bfb96036face4ed424c604c432db393 Mon Sep 17 00:00:00 2001
From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 4 Dec 2008 09:18:28 +0100
Subject: [PATCH] tracing: fix typo

Impact: fix build bug

Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 kernel/trace/trace.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/kernel/trace/trace.h b/kernel/trace/trace.h
index 8b81b4d..96202b3 100644
--- a/kernel/trace/trace.h
+++ b/kernel/trace/trace.h
@@ -529,7 +529,7 @@ static inline int ftrace_graph_addr(unsigned long addr)
 #else
 static inline int ftrace_trace_addr(unsigned long addr)
 {
-	return 1
+	return 1;
 }
 #endif /* CONFIG_DYNAMIC_FTRACE */
 
