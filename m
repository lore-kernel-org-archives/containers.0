Received: from mail-wm1-f45.google.com (mail-wm1-f45.google.com [209.85.128.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8154853AF
	for <containers@lists.linux.dev>; Mon, 28 Feb 2022 11:39:32 +0000 (UTC)
Received: by mail-wm1-f45.google.com with SMTP id bg31-20020a05600c3c9f00b00381590dbb33so2027766wmb.3
        for <containers@lists.linux.dev>; Mon, 28 Feb 2022 03:39:32 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=+f9tMcztypYTJErs8jCKoHKno97PRfBI4us/WusXC6M=;
        b=iuzCIIQRuP02qRTnRtb1rJ4cNJavxtG7wk3a3tSlOiudWwhXcp0KHWqnXHzHlDgfwZ
         FQHqxD4YiCYElMCZofPXCXir1rI/4XLPqswZepRjVfdiciC/SXMd1UAhdmoBKCQZAnFA
         ZaLmza9X0kwf+wfdC3Pycq1HNKT9/0Fca+o+wH5LNxEWG75fLe1C4fUqyn3w3ylzfTr1
         JO2PphYw6wo9RWx2OS6EzxADWo39/k327lFSkB3scV6+OT6/lyWhrM7ivFli7ZVc2F5q
         GSlPbZe03ecr2QBihYTeovJ+9jgpTPooYZh3V9gE/QMbDkB9AUgiTrNXoo862BZl5Weq
         n1DQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=+f9tMcztypYTJErs8jCKoHKno97PRfBI4us/WusXC6M=;
        b=KP8vetEI1wZa7/+RoYW8ssONANBrZpGyz+BJbX2r9q2XK/xBW6Hn8ySytZfdPTHwPl
         w76Hu1ZP5drzVxZlJChZdY1HkP7O1YjN1ySjRAsGa/fWGYDN0Zx1bFQL9wm/HTQBMhnN
         wVrmdk+34uf9UJI9nDJJskesmghUDhwL41faQdqzwolpphoIpNZ6zHUITYXAB+Jnnacy
         qNiqhmwrPC+dYVqd+r5P3HqBjSClu6GwWK+tik5lcSqtYwQUGKlkjVzPs8KoKpxSTaf5
         xO0bdRAhDgPE5d8NLHDsSltcV9xNrayNgEf0oRhFlF2JkZVpXObjB2ldUchcMntH/kiH
         m/LA==
X-Gm-Message-State: AOAM531GY6rYyt6uzFZYX0Un/X83xL5tWtz32pIF1cRIyKCb2TqaK1ki
	Z4m16Kjm90c7capwmbxUBDo=
X-Google-Smtp-Source: ABdhPJyCau9G2Gjn6eGoo/A1/STE9A73lLQk33pFaH12vpwbWqO0rZaFSZnN9vSJLp9eg1kNhqt5hw==
X-Received: by 2002:a1c:4e03:0:b0:380:d3cc:61c9 with SMTP id g3-20020a1c4e03000000b00380d3cc61c9mr12486226wmh.193.1646048370903;
        Mon, 28 Feb 2022 03:39:30 -0800 (PST)
Received: from localhost.localdomain ([5.29.13.154])
        by smtp.gmail.com with ESMTPSA id e22-20020adf9bd6000000b001eda1017861sm10584592wrc.64.2022.02.28.03.39.29
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 28 Feb 2022 03:39:30 -0800 (PST)
From: Amir Goldstein <amir73il@gmail.com>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	linux-unionfs@vger.kernel.org,
	containers@lists.linux.dev,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH v2 4/6] fs: report per-mount io stats
Date: Mon, 28 Feb 2022 13:39:08 +0200
Message-Id: <20220228113910.1727819-5-amir73il@gmail.com>
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

Show optional collected per-mount io stats in /proc/<pid>/mountstats
for filesystems that do not implement their own show_stats() method
and opted-in to generic per-mount stats with FS_MOUNT_STATS flag.

Signed-off-by: Amir Goldstein <amir73il@gmail.com>
---
 fs/mount.h          |  1 +
 fs/namespace.c      |  2 ++
 fs/proc_namespace.c | 13 +++++++++++++
 3 files changed, 16 insertions(+)

diff --git a/fs/mount.h b/fs/mount.h
index f98bf4cd5b1a..2ab6308af78b 100644
--- a/fs/mount.h
+++ b/fs/mount.h
@@ -91,6 +91,7 @@ struct mount {
 	int mnt_id;			/* mount identifier */
 	int mnt_group_id;		/* peer group identifier */
 	int mnt_expiry_mark;		/* true if marked for expiry */
+	time64_t mnt_time;		/* time of mount */
 	struct hlist_head mnt_pins;
 	struct hlist_head mnt_stuck_children;
 } __randomize_layout;
diff --git a/fs/namespace.c b/fs/namespace.c
index 3fb8f11a42a1..546f07ed44c5 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -220,6 +220,8 @@ static struct mount *alloc_vfsmnt(const char *name)
 		mnt->mnt_count = 1;
 		mnt->mnt_writers = 0;
 #endif
+		/* For proc/<pid>/mountstats */
+		mnt->mnt_time = ktime_get_seconds();
 
 		INIT_HLIST_NODE(&mnt->mnt_hash);
 		INIT_LIST_HEAD(&mnt->mnt_child);
diff --git a/fs/proc_namespace.c b/fs/proc_namespace.c
index 49650e54d2f8..d744fb8543f5 100644
--- a/fs/proc_namespace.c
+++ b/fs/proc_namespace.c
@@ -232,6 +232,19 @@ static int show_vfsstat(struct seq_file *m, struct vfsmount *mnt)
 	if (sb->s_op->show_stats) {
 		seq_putc(m, ' ');
 		err = sb->s_op->show_stats(m, mnt_path.dentry);
+	} else if (mnt_has_stats(mnt)) {
+		/* Similar to /proc/<pid>/io */
+		seq_printf(m, "\n"
+			   "\ttimes: %lld %lld\n"
+			   "\trchar: %lld\n"
+			   "\twchar: %lld\n"
+			   "\tsyscr: %lld\n"
+			   "\tsyscw: %lld\n",
+			   r->mnt_time, ktime_get_seconds(),
+			   mnt_iostats_counter_read(r, MNTIOS_CHARS_RD),
+			   mnt_iostats_counter_read(r, MNTIOS_CHARS_WR),
+			   mnt_iostats_counter_read(r, MNTIOS_SYSCALLS_RD),
+			   mnt_iostats_counter_read(r, MNTIOS_SYSCALLS_WR));
 	}
 
 	seq_putc(m, '\n');
-- 
2.25.1

