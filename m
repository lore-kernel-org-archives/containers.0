Received: from us-smtp-delivery-44.mimecast.com (us-smtp-delivery-44.mimecast.com [207.211.30.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AB62D4680
	for <containers@lists.linux.dev>; Tue, 12 Jul 2022 16:24:19 +0000 (UTC)
Received: from mimecast-mx02.redhat.com (mimecast-mx02.redhat.com
 [66.187.233.88]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 us-mta-394-LZqbPCi_PCW3Nr9iU68zBQ-1; Tue, 12 Jul 2022 12:17:49 -0400
X-MC-Unique: LZqbPCi_PCW3Nr9iU68zBQ-1
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.rdu2.redhat.com [10.11.54.8])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mimecast-mx02.redhat.com (Postfix) with ESMTPS id F144E811E84;
	Tue, 12 Jul 2022 16:17:48 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com (unknown [10.40.208.6])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7E302C04482;
	Tue, 12 Jul 2022 16:17:47 +0000 (UTC)
From: Alexey Gladkov <legion@kernel.org>
To: LKML <linux-kernel@vger.kernel.org>,
	Linux Containers <containers@lists.linux.dev>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christian Brauner <brauner@kernel.org>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Kees Cook <keescook@chromium.org>,
	Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH v1] sysctl: Allow change system v ipc sysctls inside ipc namespace
Date: Tue, 12 Jul 2022 18:17:38 +0200
Message-Id: <54e6b6b1b430537748a7136e854923498443f78a.1657642613.git.legion@kernel.org>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.85 on 10.11.54.8

Rootless containers are not allowed to modify kernel IPC parameters such
as kernel.msgmnb.

It seems to me that we can allow customization of these parameters if
the user has CAP_SYS_RESOURCE in that ipc namespace.

CAP_SYS_RESOURCE is already needed in order to overcome mqueue limits
(msg_max and msgsize_max).

Signed-off-by: Alexey Gladkov <legion@kernel.org>
---
 ipc/ipc_sysctl.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/ipc/ipc_sysctl.c b/ipc/ipc_sysctl.c
index ef313ecfb53a..e79452867720 100644
--- a/ipc/ipc_sysctl.c
+++ b/ipc/ipc_sysctl.c
@@ -193,16 +193,19 @@ static int set_is_seen(struct ctl_table_set *set)
 static int ipc_permissions(struct ctl_table_header *head, struct ctl_table *table)
 {
 	int mode = table->mode;
-
-#ifdef CONFIG_CHECKPOINT_RESTORE
 	struct ipc_namespace *ns = current->nsproxy->ipc_ns;
 
+#ifdef CONFIG_CHECKPOINT_RESTORE
 	if (((table->data == &ns->ids[IPC_SEM_IDS].next_id) ||
 	     (table->data == &ns->ids[IPC_MSG_IDS].next_id) ||
 	     (table->data == &ns->ids[IPC_SHM_IDS].next_id)) &&
 	    checkpoint_restore_ns_capable(ns->user_ns))
 		mode = 0666;
+	else
 #endif
+	if (ns_capable(ns->user_ns, CAP_SYS_RESOURCE))
+		mode = 0666;
+
 	return mode;
 }
 
-- 
2.33.3

