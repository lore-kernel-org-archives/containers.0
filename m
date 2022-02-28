Received: from mail-wr1-f51.google.com (mail-wr1-f51.google.com [209.85.221.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B567D53A4
	for <containers@lists.linux.dev>; Mon, 28 Feb 2022 11:39:33 +0000 (UTC)
Received: by mail-wr1-f51.google.com with SMTP id n14so14937063wrq.7
        for <containers@lists.linux.dev>; Mon, 28 Feb 2022 03:39:33 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=vAdCnAeNh+/KXi8tE5JN2RpP/3wcVJ4rhcaX9E9RdrA=;
        b=W3vPFEEPyICp8MlhFKv76zhnFJNC9xv8u0PXU1xzwdb2TzfXc0FQISOxrdcEpg4Pym
         b24r8geHTgtGlgoqUdZdb+VRzQxUnsQaVqT4HVSb9fei3+6FspHdp32wi2/DjZnGb8Gt
         hvsF/ZDTmhHMkHshiP4AdTQdDtWSL8H5jGrxyJr1ql+qz3jdTyAgQ9wLhu/LHi4QYirZ
         6sJZYEg1BHZ9mOhW+xu7gVXPj+GDgrMgkA9H3qDtetATyb0amlpscozMVuP0sY0ey7/i
         eBdRMgm+JuNlv4FTCZarbAkAAdZie42tbQYEoQ24ePBLyXEaohO3etcu8TJK64j186XS
         xnyA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=vAdCnAeNh+/KXi8tE5JN2RpP/3wcVJ4rhcaX9E9RdrA=;
        b=LjJu+eij3FkiKkLClyjjlmVQMyRKxYoXPKT8BDYDlAM4NES+PcWdGN4POT5B9T+B4C
         4bhJIKjQIPcpg1PcIud67znnJHIR9iDaUOkE+xfqQ/Lwpr1JFcfLaN2et/FakgOFWYdf
         sgrPB2UIIWX5oTGB+XGo4V/HARKtQp5c2217+H7ahlbeRE085fRIRUBDfxSK1l62KQIv
         y48dGMLQwWS2XwHIqBARbj9wVbfHQLCNBIqMuFpQM7J+4y2PFVMnvh7ifs8rFqlarplL
         TSAEC4v+ckxSgOgS7WR7nYqHzT0cRe/F1HakhcnY67SynFLq57fTL7EHZnFoi/QvbDdf
         XfJg==
X-Gm-Message-State: AOAM530I1CR67bW60bCaho6usR0w4wjkiHlcybphNq6O1hwpYfsDgkLL
	/81XrWs4tU7Hcir8q72N+ZM=
X-Google-Smtp-Source: ABdhPJzCwegu8RMbRSzfsAQ+1JNo6Vm/YBliXUJFP9x33x0YfWht3hz6LdU7WKY2g6lHTJ039q1VTw==
X-Received: by 2002:a5d:67ca:0:b0:1ed:d1e4:bce2 with SMTP id n10-20020a5d67ca000000b001edd1e4bce2mr15282901wrw.493.1646048372055;
        Mon, 28 Feb 2022 03:39:32 -0800 (PST)
Received: from localhost.localdomain ([5.29.13.154])
        by smtp.gmail.com with ESMTPSA id e22-20020adf9bd6000000b001eda1017861sm10584592wrc.64.2022.02.28.03.39.31
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 28 Feb 2022 03:39:31 -0800 (PST)
From: Amir Goldstein <amir73il@gmail.com>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	linux-unionfs@vger.kernel.org,
	containers@lists.linux.dev,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH v2 5/6] ovl: opt-in for per-mount io stats
Date: Mon, 28 Feb 2022 13:39:09 +0200
Message-Id: <20220228113910.1727819-6-amir73il@gmail.com>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <20220228113910.1727819-1-amir73il@gmail.com>
References: <20220228113910.1727819-1-amir73il@gmail.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Traditionally, system administrators have used the iostat utility
to track the amount of io performed to a local disk filesystem.

Similar functionality is provided for NFS mounts via the nfsstat
utility that reads the NFS client's stats from /proc/pid/mountstats.

There is currently no good way for a system administrator or a
monitoring application inside a container to track the amount of io
performed via overlayfs.

Opt-in for generic io stats via /proc/pid/mountstats to provide
that functionality.

This feature depends on CONFIG_MOUNT_IO_STATS.

Signed-off-by: Amir Goldstein <amir73il@gmail.com>
---
 fs/overlayfs/super.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/overlayfs/super.c b/fs/overlayfs/super.c
index 7bb0a47cb615..802e4ed567cc 100644
--- a/fs/overlayfs/super.c
+++ b/fs/overlayfs/super.c
@@ -2165,7 +2165,7 @@ static struct dentry *ovl_mount(struct file_system_type *fs_type, int flags,
 static struct file_system_type ovl_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "overlay",
-	.fs_flags	= FS_USERNS_MOUNT,
+	.fs_flags	= FS_USERNS_MOUNT | FS_MOUNT_STATS,
 	.mount		= ovl_mount,
 	.kill_sb	= kill_anon_super,
 };
-- 
2.25.1

