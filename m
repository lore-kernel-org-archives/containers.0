Received: from us-smtp-delivery-44.mimecast.com (us-smtp-delivery-44.mimecast.com [205.139.111.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 47B8D28F1
	for <containers@lists.linux.dev>; Fri, 22 Apr 2022 12:54:05 +0000 (UTC)
Received: from mimecast-mx02.redhat.com (mimecast-mx02.redhat.com
 [66.187.233.88]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 us-mta-654-2bZdEIVWPhG6siyfIglrFQ-1; Fri, 22 Apr 2022 08:54:00 -0400
X-MC-Unique: 2bZdEIVWPhG6siyfIglrFQ-1
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.rdu2.redhat.com [10.11.54.8])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mimecast-mx02.redhat.com (Postfix) with ESMTPS id DE24F185A7B2;
	Fri, 22 Apr 2022 12:53:59 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com (unknown [10.36.110.3])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 571E0C44AE4;
	Fri, 22 Apr 2022 12:53:57 +0000 (UTC)
From: Alexey Gladkov <legion@kernel.org>
To: LKML <linux-kernel@vger.kernel.org>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Linus Torvalds <torvalds@linux-foundation.org>
Cc: Alexander Mikhalitsyn <alexander.mikhalitsyn@virtuozzo.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christian Brauner <christian.brauner@ubuntu.com>,
	Daniel Walsh <dwalsh@redhat.com>,
	Davidlohr Bueso <dbueso@suse.de>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Linux Containers <containers@lists.linux.dev>,
	Manfred Spraul <manfred@colorfullife.com>,
	Serge Hallyn <serge@hallyn.com>,
	Varad Gautam <varad.gautam@suse.com>,
	Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH v1 4/4] ipc: Remove extra braces
Date: Fri, 22 Apr 2022 14:53:40 +0200
Message-Id: <8f645e997ff805dcb410cfdd09df9e475c6c845e.1650631347.git.legion@kernel.org>
In-Reply-To: <cover.1650631347.git.legion@kernel.org>
References: <CAHk-=wgBB8iPd0W=MQWnQJukMAPAqgsC0QX2wwiSvcct9zu_RA@mail.gmail.com> <cover.1650631347.git.legion@kernel.org>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.85 on 10.11.54.8

Fix coding style. In the previous commit, I added braces because,
in addition to changing .data, .extra1 also changed. Now this is not
needed.

Signed-off-by: Alexey Gladkov <legion@kernel.org>
---
 ipc/ipc_sysctl.c | 25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/ipc/ipc_sysctl.c b/ipc/ipc_sysctl.c
index 5a58598d48c8..ef313ecfb53a 100644
--- a/ipc/ipc_sysctl.c
+++ b/ipc/ipc_sysctl.c
@@ -222,42 +222,41 @@ bool setup_ipc_sysctls(struct ipc_namespace *ns)
 		int i;
 
 		for (i = 0; i < ARRAY_SIZE(ipc_sysctls); i++) {
-			if (tbl[i].data == &init_ipc_ns.shm_ctlmax) {
+			if (tbl[i].data == &init_ipc_ns.shm_ctlmax)
 				tbl[i].data = &ns->shm_ctlmax;
 
-			} else if (tbl[i].data == &init_ipc_ns.shm_ctlall) {
+			else if (tbl[i].data == &init_ipc_ns.shm_ctlall)
 				tbl[i].data = &ns->shm_ctlall;
 
-			} else if (tbl[i].data == &init_ipc_ns.shm_ctlmni) {
+			else if (tbl[i].data == &init_ipc_ns.shm_ctlmni)
 				tbl[i].data = &ns->shm_ctlmni;
 
-			} else if (tbl[i].data == &init_ipc_ns.shm_rmid_forced) {
+			else if (tbl[i].data == &init_ipc_ns.shm_rmid_forced)
 				tbl[i].data = &ns->shm_rmid_forced;
 
-			} else if (tbl[i].data == &init_ipc_ns.msg_ctlmax) {
+			else if (tbl[i].data == &init_ipc_ns.msg_ctlmax)
 				tbl[i].data = &ns->msg_ctlmax;
 
-			} else if (tbl[i].data == &init_ipc_ns.msg_ctlmni) {
+			else if (tbl[i].data == &init_ipc_ns.msg_ctlmni)
 				tbl[i].data = &ns->msg_ctlmni;
 
-			} else if (tbl[i].data == &init_ipc_ns.msg_ctlmnb) {
+			else if (tbl[i].data == &init_ipc_ns.msg_ctlmnb)
 				tbl[i].data = &ns->msg_ctlmnb;
 
-			} else if (tbl[i].data == &init_ipc_ns.sem_ctls) {
+			else if (tbl[i].data == &init_ipc_ns.sem_ctls)
 				tbl[i].data = &ns->sem_ctls;
 #ifdef CONFIG_CHECKPOINT_RESTORE
-			} else if (tbl[i].data == &init_ipc_ns.ids[IPC_SEM_IDS].next_id) {
+			else if (tbl[i].data == &init_ipc_ns.ids[IPC_SEM_IDS].next_id)
 				tbl[i].data = &ns->ids[IPC_SEM_IDS].next_id;
 
-			} else if (tbl[i].data == &init_ipc_ns.ids[IPC_MSG_IDS].next_id) {
+			else if (tbl[i].data == &init_ipc_ns.ids[IPC_MSG_IDS].next_id)
 				tbl[i].data = &ns->ids[IPC_MSG_IDS].next_id;
 
-			} else if (tbl[i].data == &init_ipc_ns.ids[IPC_SHM_IDS].next_id) {
+			else if (tbl[i].data == &init_ipc_ns.ids[IPC_SHM_IDS].next_id)
 				tbl[i].data = &ns->ids[IPC_SHM_IDS].next_id;
 #endif
-			} else {
+			else
 				tbl[i].data = NULL;
-			}
 		}
 
 		ns->ipc_sysctls = __register_sysctl_table(&ns->ipc_set, "kernel", tbl);
-- 
2.33.2

