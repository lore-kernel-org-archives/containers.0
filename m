Received: from mail-wr1-f42.google.com (mail-wr1-f42.google.com [209.85.221.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F231253AE
	for <containers@lists.linux.dev>; Mon, 28 Feb 2022 11:39:27 +0000 (UTC)
Received: by mail-wr1-f42.google.com with SMTP id v21so14944784wrv.5
        for <containers@lists.linux.dev>; Mon, 28 Feb 2022 03:39:27 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=60gB9AriL6gaM3w175kpPdcTv3rvAhXleKe422vVwHk=;
        b=EvTIWH/jdIDhUHxDSrHTVPySVpj2HzWLxs4IAGQ6uHusQi/DeHlavy9hdipTShJr46
         bXG6JM1wfB1CBJg4afv/WnLrUC6r1cdifAmd0JxSUrJKrpolXWyhkgrb/s8nAVV6hl/q
         AWLy1C+HL10gXPNhMPsm3iWcmp9FLCNFJg/V6n/MphemPdZ364LIZWtnfpeo9Aw7IbPv
         Ps2vgLMKh0ZUpYXH0AMSjOyOI8ZimJBftHcrItAIKoWhyimRzX7pm7LLywxri6SeFOC1
         TUwLWdikWDDjjtmfoCxnVob+3x7+RyF7kW0/89y0ODx+/ZoaFwp0lnpETEzUoSvbZ2lM
         d3hQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=60gB9AriL6gaM3w175kpPdcTv3rvAhXleKe422vVwHk=;
        b=qffdPiRHDfBuG5CLkdnzuutq8Lmd8+sDLKn4lXSYF3+HXtWzQa4rDJHEs3ZXALXQnr
         fme3fVofsoElhnOm7AAbuSITTqtoX8Uy+E2Qq9r6IEGbp4/giR3ZcQYG0jhKan9ItHcE
         2rG6b8X8Jfzp2NCbXSeLOTg9VnWgLWsKKGZSI8sTeACtrePwH18311Pqu1GFoautIEWs
         JxWd9TYyhKaIikt3scwNxiaMvSBAnUuwwPnDVBANgcgs29GIRI2Ma2ZGXTrLFGH2HFGb
         DD/EERPGnWGoxqIjoKjHfIN1jqfnutr6SyR+7i/LSGcr16hAamT86FVh+RN8+2qDwrxc
         uRSA==
X-Gm-Message-State: AOAM531PvV/XlaibsziRn7s9aMH/mA4ZxbGiCJOiCCQfkhtYWs/u0mii
	uuuxbiyfvrX9HROrZ+woT6c=
X-Google-Smtp-Source: ABdhPJzZby2nYbVJIxtneu/jpoJkEFhyJnfzlLRuL5N3pry5CTAbnaTl3XixCUWJh3GkQQ3Ngx4yAw==
X-Received: by 2002:a05:6000:1786:b0:1ea:78aa:5e1b with SMTP id e6-20020a056000178600b001ea78aa5e1bmr15603487wrg.544.1646048366326;
        Mon, 28 Feb 2022 03:39:26 -0800 (PST)
Received: from localhost.localdomain ([5.29.13.154])
        by smtp.gmail.com with ESMTPSA id e22-20020adf9bd6000000b001eda1017861sm10584592wrc.64.2022.02.28.03.39.25
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 28 Feb 2022 03:39:25 -0800 (PST)
From: Amir Goldstein <amir73il@gmail.com>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	linux-unionfs@vger.kernel.org,
	containers@lists.linux.dev,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH v2 1/6] fs: add iostats counters to struct mount
Date: Mon, 28 Feb 2022 13:39:05 +0200
Message-Id: <20220228113910.1727819-2-amir73il@gmail.com>
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

With config MOUNT_IO_STATS, add an array of counters to struct mnt_pcp
that will be used to collect I/O statistics.

Signed-off-by: Amir Goldstein <amir73il@gmail.com>
---
 fs/Kconfig     |  9 +++++++++
 fs/mount.h     | 32 ++++++++++++++++++++++++++++++++
 fs/namespace.c | 17 +++++++++++++++++
 3 files changed, 58 insertions(+)

diff --git a/fs/Kconfig b/fs/Kconfig
index 6c7dc1387beb..60baa861b3e4 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -15,6 +15,15 @@ config VALIDATE_FS_PARSER
 	  Enable this to perform validation of the parameter description for a
 	  filesystem when it is registered.
 
+config FS_MOUNT_STATS
+	bool "Enable per-mount I/O statistics"
+	depends on SMP
+	help
+	  Enable this to allow collecting per-mount I/O statistics and display
+	  them in /proc/<pid>/mountstats.
+
+	  Say N if unsure.
+
 config FS_IOMAP
 	bool
 
diff --git a/fs/mount.h b/fs/mount.h
index 0b6e08cf8afb..b22169b4d24c 100644
--- a/fs/mount.h
+++ b/fs/mount.h
@@ -24,9 +24,25 @@ struct mnt_namespace {
 	unsigned int		pending_mounts;
 } __randomize_layout;
 
+/* Similar to task_io_accounting members */
+enum {
+	MNTIOS_CHARS_RD,	/* bytes read via syscalls */
+	MNTIOS_CHARS_WR,	/* bytes written via syscalls */
+	MNTIOS_SYSCALLS_RD,	/* # of read syscalls */
+	MNTIOS_SYSCALLS_WR,	/* # of write syscalls */
+	_MNTIOS_COUNTERS_NUM
+};
+
+struct mnt_iostats {
+	s64 counter[_MNTIOS_COUNTERS_NUM];
+};
+
 struct mnt_pcp {
 	int mnt_count;
 	int mnt_writers;
+#ifdef CONFIG_FS_MOUNT_STATS
+	struct mnt_iostats iostats;
+#endif
 };
 
 struct mountpoint {
@@ -148,3 +164,19 @@ static inline bool is_anon_ns(struct mnt_namespace *ns)
 }
 
 extern void mnt_cursor_del(struct mnt_namespace *ns, struct mount *cursor);
+
+static inline void mnt_iostats_counter_inc(struct mount *mnt, int id)
+{
+#ifdef CONFIG_FS_MOUNT_STATS
+	this_cpu_inc(mnt->mnt_pcp->iostats.counter[id]);
+#endif
+}
+
+static inline void mnt_iostats_counter_add(struct mount *mnt, int id, s64 n)
+{
+#ifdef CONFIG_FS_MOUNT_STATS
+	this_cpu_add(mnt->mnt_pcp->iostats.counter[id], n);
+#endif
+}
+
+extern s64 mnt_iostats_counter_read(struct mount *mnt, int id);
diff --git a/fs/namespace.c b/fs/namespace.c
index de6fae84f1a1..3fb8f11a42a1 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -306,6 +306,23 @@ static unsigned int mnt_get_writers(struct mount *mnt)
 #endif
 }
 
+s64 mnt_iostats_counter_read(struct mount *mnt, int id)
+{
+	s64 count = 0;
+#ifdef CONFIG_FS_MOUNT_STATS
+	/*
+	 * MOUNT_STATS depends on SMP.
+	 * Should be trivial to implement for !SMP if anyone cares...
+	 */
+	int cpu;
+
+	for_each_possible_cpu(cpu) {
+		count += per_cpu_ptr(mnt->mnt_pcp, cpu)->iostats.counter[id];
+	}
+#endif
+	return count;
+}
+
 static int mnt_is_readonly(struct vfsmount *mnt)
 {
 	if (mnt->mnt_sb->s_readonly_remount)
-- 
2.25.1

