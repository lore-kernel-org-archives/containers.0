From: sukadev@linux.vnet.ibm.com
Subject: [PATCH] 'kill sig -1' must only apply to caller's namespace
Date: Thu, 23 Oct 2008 08:49:28 -0700
Message-ID: <20081023154928.GA1044@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757124AbYJWPuj@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@osdl.org>
Cc: Oleg Nesterov <oleg@tv-sign.ru>, "Eric W. Biederman" <ebiederm@xmission.com>, daniel@hozac.com, Pavel Emelyanov <xemul@openvz.org>, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: [PATCH] 'kill sig -1' must only apply to caller's namespace

Currently "kill <sig> -1" kills processes in all namespaces and breaks the
isolation of namespaces. Earlier attempt to fix this was discussed at:

	http://lkml.org/lkml/2008/7/23/148

As suggested by Oleg Nesterov in that thread, use "task_pid_vnr() > 1"
check since task_pid_vnr() returns 0 if process is outside the caller's
namespace.

Signed-off-by: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Acked-by: Eric W. Biederman <ebiederm@xmission.com>
Tested-by: Daniel Hokka Zakrisson <daniel@hozac.com>
---
 kernel/signal.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/kernel/signal.c b/kernel/signal.c
index 105217d..4530fc6 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -1144,7 +1144,8 @@ static int kill_something_info(int sig, struct siginfo *info, pid_t pid)
 		struct task_struct * p;
 
 		for_each_process(p) {
-			if (p->pid > 1 && !same_thread_group(p, current)) {
+			if (task_pid_vnr(p) > 1 &&
+					!same_thread_group(p, current)) {
 				int err = group_send_sig_info(sig, info, p);
 				++count;
 				if (err != -EPERM)
-- 
1.5.2.5
