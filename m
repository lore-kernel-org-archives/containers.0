Received: from us-smtp-delivery-44.mimecast.com (us-smtp-delivery-44.mimecast.com [205.139.111.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 31FED4C7D
	for <containers@lists.linux.dev>; Wed, 25 Jan 2023 15:31:02 +0000 (UTC)
Received: from mimecast-mx02.redhat.com (mimecast-mx02.redhat.com
 [66.187.233.88]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 us-mta-595-ZpQQD_SlPyav-ZCRRyDwfg-1; Wed, 25 Jan 2023 10:29:27 -0500
X-MC-Unique: ZpQQD_SlPyav-ZCRRyDwfg-1
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.rdu2.redhat.com [10.11.54.4])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mimecast-mx02.redhat.com (Postfix) with ESMTPS id 2B93E811E9C;
	Wed, 25 Jan 2023 15:29:27 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com (ovpn-208-16.brq.redhat.com [10.40.208.16])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 68BFD2026D4B;
	Wed, 25 Jan 2023 15:29:25 +0000 (UTC)
From: Alexey Gladkov <legion@kernel.org>
To: LKML <linux-kernel@vger.kernel.org>,
	containers@lists.linux.dev,
	linux-fsdevel@vger.kernel.org
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christian Brauner <brauner@kernel.org>,
	Val Cowan <vcowan@redhat.com>
Subject: [RFC PATCH v1 1/6] proc: Fix separator for subset option
Date: Wed, 25 Jan 2023 16:28:48 +0100
Message-Id: <ec2a7c3179e8eb2412289f0683da080b3bc2b18b.1674660533.git.legion@kernel.org>
In-Reply-To: <cover.1674660533.git.legion@kernel.org>
References: <cover.1674660533.git.legion@kernel.org>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.1 on 10.11.54.4

Signed-off-by: Alexey Gladkov <legion@kernel.org>
---
 fs/proc/root.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/proc/root.c b/fs/proc/root.c
index 3c2ee3eb1138..5f1015b6418d 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -91,7 +91,7 @@ static int proc_parse_subset_param(struct fs_context *fc, char *value)
 	struct proc_fs_context *ctx = fc->fs_private;
 
 	while (value) {
-		char *ptr = strchr(value, ',');
+		char *ptr = strchr(value, '+');
 
 		if (ptr != NULL)
 			*ptr++ = '\0';
-- 
2.33.6

