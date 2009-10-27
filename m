From: Liu Aleaxander <aleaxander-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] Fix two more typos
Date: Tue, 27 Oct 2009 10:23:14 +0800
Message-ID: <b741c2440910261923o75190755g24c351faa64d2484@mail.gmail.com>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

The two typos make self_checkpoint.c and self_restart.c can't be compiled.

Signed-off-by: Liu Aleaxander <Aleaxander-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 Documentation/checkpoint/self_checkpoint.c |    2 +-
 Documentation/checkpoint/self_restart.c    |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/checkpoint/self_checkpoint.c
b/Documentation/checkpoint/self_checkpoint.c
index e164381..11b17ea 100644
--- a/Documentation/checkpoint/self_checkpoint.c
+++ b/Documentation/checkpoint/self_checkpoint.c
@@ -1,4 +1,4 @@
->/*
+/*
  *  self_checkpoint.c: demonstrate self-checkpoint
  *
  *  Copyright (C) 2008 Oren Laadan
diff --git a/Documentation/checkpoint/self_restart.c
b/Documentation/checkpoint/self_restart.c
index 361f81b..aea2d0b 100644
--- a/Documentation/checkpoint/self_restart.c
+++ b/Documentation/checkpoint/self_restart.c
@@ -22,7 +22,7 @@

 inline static int restart(pid_t pid, int fd, unsigned long flags)
 {
-    return syscall(__NR_restat, pid, fd, flags);
+    return syscall(__NR_restart, pid, fd, flags);
 }

 int main(int argc, char *argv[])
-- 
1.6.2.5


-- 
regards
Liu Aleaxander
