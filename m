From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 1/5][lxc] Enable static linking of some lxc binaries
Date: Thu, 18 Mar 2010 23:40:24 -0700
Message-ID: <20100319064024.GB25732@us.ibm.com>
References: <20100319063912.GA25732@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100319063912.GA25732-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Wed, 10 Mar 2010 22:12:34 -0800
Subject: [PATCH 1/5][lxc] Enable static linking of some lxc binaries

This is a temporary commit to statically link lxc_checkpoint, lxc_execute
and lxc_restart.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 src/lxc/Makefile2 |   35 +++++++++++++++++++++++++++++++++++
 1 files changed, 35 insertions(+), 0 deletions(-)
 create mode 100644 src/lxc/Makefile2

diff --git a/src/lxc/Makefile2 b/src/lxc/Makefile2
new file mode 100644
index 0000000..26b9cd3
--- /dev/null
+++ b/src/lxc/Makefile2
@@ -0,0 +1,35 @@
+BASEDIR = ../..
+
+USERCR ?= 	$(BASEDIR)/../user-cr-lxc/
+
+CFLAGS = 	-static -I . -I .. -I $(USERCR) -I $(USERCR)/include
+LDFLAGS = 	$(USERCR)/libeclone.a -lutil
+
+LXC_OBJS = 	start.o stop.o conf.o confile.o arguments.o monitor.o	\
+		log.o mainloop.o utils.o commands.o state.o cgroup.o	\
+		error.o namespace.o parse.o network.o af_unix.o 	\
+		console.o nl.o
+
+USERCR_CHECKPOINT_OBJ =	$(USERCR)/checkpoint.o
+
+USERCR_RESTART_OBJ = 	$(USERCR)/restart.o
+
+LXC_CHECKPOINT_OBJS = 	$(LXC_OBJS) $(USERCR_CHECKPOINT_OBJ) \
+			lxc_checkpoint.o checkpoint.o
+
+LXC_RESTART_OBJS = 	$(LXC_OBJS) $(USERCR_RESTART_OBJ) \
+			lxc_restart.o restart.o 
+
+LXC_EXECUTE_OBJS =	$(LXC_OBJS) lxc_execute.o
+
+lxc_checkpoint: $(LXC_CHECKPOINT_OBJS)
+	$(CC) -o lxc_checkpoint $(LXC_CHECKPOINT_OBJS) $(LDFLAGS)
+
+lxc_restart: $(LXC_RESTART_OBJS)
+	$(CC) -o lxc_restart $(LXC_RESTART_OBJS) $(LDFLAGS)
+
+lxc_execute: $(LXC_EXECUTE_OBJS)
+	$(CC) -o lxc_execute $(LXC_EXECUTE_OBJS) $(LDFLAGS)
+
+clean:
+	rm -f $(RESTART_OBJS)
-- 
1.6.6.1
