Received: from mail-wr1-f50.google.com (mail-wr1-f50.google.com [209.85.221.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9EE7353AE
	for <containers@lists.linux.dev>; Mon, 28 Feb 2022 11:39:29 +0000 (UTC)
Received: by mail-wr1-f50.google.com with SMTP id x15so14941302wrg.8
        for <containers@lists.linux.dev>; Mon, 28 Feb 2022 03:39:29 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=jkTdmwcYrsD5Ih4jEZkwm344BsEN/Gk7jF7uJgisPq4=;
        b=dNzY3UKZCmSvl+nY+tID9HneHnFkMr5OYQx8eJOsDr5tWtRB5aVksA5dK43OA/Tl4q
         mkADAtfOnDKd9HMNzS4S5EVejOXw6/2p0UXgZTrcA4vQume3kFSUelma0MTU6G2ECR3U
         mnQfNMndyoRFdqhOXUI8SOtgnKkO7YssM06bcD1RUtq4x1B6kdUoxs634V3nfuEEZC5F
         8NTOMzeynEB+f5Gy7ONdK+TMq+p5NCxn7RE/aiSb+c/AHcOI2FnM69OvYwwnInGvcTs8
         sbmIPwSJlCVZA+znrzmrwK9zuqYwxMFAlkut6Xhy1OOGHoaUArP1peAe7tsK0adBDw4y
         fZtg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=jkTdmwcYrsD5Ih4jEZkwm344BsEN/Gk7jF7uJgisPq4=;
        b=7I5qtJm8nrP6UJlHrkiBdB5uH2IjERJQXR50Xi7NpT5UcCIAVpsJaumqVUIvxtOP01
         mWJuviCmigegeNF3adu1HUeXfVqmhlbeHKyyV3qNw5j6VziZAcLzdhdR94569wc757M+
         8XfsQqif2vINIeJXpS02VA2JT1q4gRyS933BVe/XsemzZpyDJ+FXY2HmwPo5xpm3s5CH
         QvATOXm0VfIPFmKs/HzcD0PSN++qeErQ6DeTc6HjxF3ke1yQse6gAEiykOpkbmezAco2
         VQfIzuFAf2TAItjVo1av9fKJKVTZI302gzUf8YGA4VmJKkr4QsxpugG4cb55VAhkzzRq
         d0nQ==
X-Gm-Message-State: AOAM531eGBmRWDXJlk6JFoXOpsxo8OvzBQx+zkoKZJW7bc0cjMHuDCLk
	U3kE18KUlcfN8nYMbaHVzws=
X-Google-Smtp-Source: ABdhPJzesUm0RXrkK88r8t6r301C1qPYSMrKXlf3qgbXcghELP6cKUXTtEwtrt3DFjiqL0ztJPKO2g==
X-Received: by 2002:adf:f7ce:0:b0:1ef:814d:fac9 with SMTP id a14-20020adff7ce000000b001ef814dfac9mr8382623wrq.79.1646048367841;
        Mon, 28 Feb 2022 03:39:27 -0800 (PST)
Received: from localhost.localdomain ([5.29.13.154])
        by smtp.gmail.com with ESMTPSA id e22-20020adf9bd6000000b001eda1017861sm10584592wrc.64.2022.02.28.03.39.26
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 28 Feb 2022 03:39:27 -0800 (PST)
From: Amir Goldstein <amir73il@gmail.com>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	linux-unionfs@vger.kernel.org,
	containers@lists.linux.dev,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH v2 2/6] fs: tidy up fs_flags definitions
Date: Mon, 28 Feb 2022 13:39:06 +0200
Message-Id: <20220228113910.1727819-3-amir73il@gmail.com>
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

Use bit shift for flag constants and abbreviate comments.

Signed-off-by: Amir Goldstein <amir73il@gmail.com>
---
 include/linux/fs.h | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index e2d892b201b0..f220db331dba 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2428,13 +2428,13 @@ int sync_inode_metadata(struct inode *inode, int wait);
 struct file_system_type {
 	const char *name;
 	int fs_flags;
-#define FS_REQUIRES_DEV		1 
-#define FS_BINARY_MOUNTDATA	2
-#define FS_HAS_SUBTYPE		4
-#define FS_USERNS_MOUNT		8	/* Can be mounted by userns root */
-#define FS_DISALLOW_NOTIFY_PERM	16	/* Disable fanotify permission events */
-#define FS_ALLOW_IDMAP         32      /* FS has been updated to handle vfs idmappings. */
-#define FS_RENAME_DOES_D_MOVE	32768	/* FS will handle d_move() during rename() internally. */
+#define FS_REQUIRES_DEV		(1<<0)
+#define FS_BINARY_MOUNTDATA	(1<<1)
+#define FS_HAS_SUBTYPE		(1<<2)
+#define FS_USERNS_MOUNT		(1<<3)	/* Can be mounted by userns root */
+#define FS_DISALLOW_NOTIFY_PERM	(1<<4)	/* Disable fanotify permission events */
+#define FS_ALLOW_IDMAP		(1<<5)	/* FS can handle vfs idmappings */
+#define FS_RENAME_DOES_D_MOVE	(1<<15)	/* FS will handle d_move() internally */
 	int (*init_fs_context)(struct fs_context *);
 	const struct fs_parameter_spec *parameters;
 	struct dentry *(*mount) (struct file_system_type *, int,
-- 
2.25.1

