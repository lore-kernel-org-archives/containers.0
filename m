From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 4/4] Add some content to the readme.txt for socket c/r
Date: Tue, 17 Nov 2009 07:26:30 -0800
Message-ID: <1258471590-29768-5-git-send-email-danms@us.ibm.com>
References: <1258471590-29768-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1258471590-29768-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
List-Id: containers.vger.kernel.org

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 Documentation/checkpoint/readme.txt |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/Documentation/checkpoint/readme.txt b/Documentation/checkpoint/readme.txt
index 0553d90..d74c144 100644
--- a/Documentation/checkpoint/readme.txt
+++ b/Documentation/checkpoint/readme.txt
@@ -365,6 +365,27 @@ It should always be safe to take a checkpoint of an application
 under LSM_1, and restart it without the RESTART_KEEP_LSM flag
 under LSM_2.
 
+Sockets
+=======
+
+For AF_UNIX sockets, both endpoints must be within the checkpointed
+task set to maintain a connected state after restart.  UNIX sockets
+that are in the process of passing a descriptor will cause the
+checkpoint to fail with -EBUSY indicating a transient state that
+cannot be checkpointed.  Listening sockets with an unaccepted peer
+will also cause an -EBUSY result.
+
+AF_INET sockets with endpoints outside the checkpointed task set may
+remain open if care is taken to avoid TCP timeouts and resets.
+Careful use of a virtual IP address can help avoid emission of an RST
+to the non-checkpointed endpoint.  If desired, the
+RESTART_SOCK_LISTENONLY flag may be passed to the restart syscall
+which will cause all connected AF_INET sockets to be closed during the
+restore process.  Listening sockets will still be restored to their
+original state, which makes this mode a candidate for something like
+an HTTP server.
+
+
 Kernel interfaces
 =================
 
-- 
1.6.2.5
