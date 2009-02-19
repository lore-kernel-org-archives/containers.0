From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: [PATCH 7/7][v8] SI_USER: Masquerade si_pid when crossing pid ns
	boundary
Date: Wed, 18 Feb 2009 19:07:43 -0800
Message-ID: <20090219030743.GG18990@us.ibm.com>
References: <20090219030207.GA18783@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758745AbZBSDIW@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090219030207.GA18783@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@osdl.org>
Cc: Oleg Nesterov <oleg@tv-sign.ru>, roland@redhat.com, "Eric W. Biederman" <ebiederm@xmission.com>, daniel@hozac.com, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Date: Wed, 24 Dec 2008 14:14:18 -0800
Subject: [PATCH 7/7][v8] SI_USER: Masquerade si_pid when crossing pid ns boundary

When sending a signal to a descendant namespace, set ->si_pid to 0 since
the sender does not have a pid in the receiver's namespace.

Note:
	- If rt_sigqueueinfo() sets si_code to SI_USER when sending a
	  signal across a pid namespace boundary, the value in ->si_pid
	  will be cleared to 0.

Changelog[v5]:
	- (Oleg Nesterov) Address both sys_kill() and sys_tkill() cases
	  in send_signal() to simplify code (this drops patch 7/7 from
	  earlier version of patchset).

Signed-off-by: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
---
 kernel/signal.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/kernel/signal.c b/kernel/signal.c
index c94355b..a416d77 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -883,6 +883,8 @@ static int __send_signal(int sig, struct siginfo *info, struct task_struct *t,
 			break;
 		default:
 			copy_siginfo(&q->info, info);
+			if (from_ancestor_ns)
+				q->info.si_pid = 0;
 			break;
 		}
 	} else if (!is_si_special(info)) {
-- 
1.5.2.5
