Received: from mail-pg1-f181.google.com (mail-pg1-f181.google.com [209.85.215.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 778B817E9
	for <containers@lists.linux.dev>; Tue,  3 May 2022 08:11:14 +0000 (UTC)
Received: by mail-pg1-f181.google.com with SMTP id i62so13485208pgd.6
        for <containers@lists.linux.dev>; Tue, 03 May 2022 01:11:14 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=sargun.me; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Uy1D1ynmt1IvB209RVxSGUYOS4OREreCXZ3NiChVu50=;
        b=E2y5XQowGGGTd48FMByGXrfc0z/3P9KkfNQyjB15pahPXOI1SrG4scBxsm0bITCKjU
         SGRDRdUvjyv16VM3dfDCI5156o6d2eQAdn06H7KLaVuaPfHYksWUJpkQG1/Ze2cd9Byr
         EbkuJky7ixTt25HtQq+L5eax4uYHg/qmF0Z5w=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=Uy1D1ynmt1IvB209RVxSGUYOS4OREreCXZ3NiChVu50=;
        b=5CbQ80ED3/YltGnvE0i+MES+YyrsKVnQHl2MPPInm7k+qcXGiGGdeLvkXrJZ9bT89A
         umli1tKA+ti2X8K6nMDP/vb1CenKkrl8+6siJ2O5QLSjrcNtNZMFKWoXZW6xF3+4js2V
         K2tMfw9QJh8enxtlHdzUt85I125w+tZodmDpZkb+MY2wkAArcVpJATDOd7xGwZW1d2Nr
         dv6HsRVccqaXzKzY/AJIkVkpKvlKeK7iPzPRXvKXRMoY2UWKF4RRv/JLi3nKAI1ryxLD
         EqLHwi1bTcyrHbCh/OE1dFnL3Bd7GMPeCh7lf3Y5/PRseygTuOgWVSrEaLaOKDGWf72l
         P4tg==
X-Gm-Message-State: AOAM532FZdzFRraWd0vn9/iVFH5UmaKRNZ4N2e92iLb/XruTcoIuci6k
	+VyvuvRBOYZKLmiwZWUgxk2hMw==
X-Google-Smtp-Source: ABdhPJzOC/8AW6mEMzYOaZsn4tjCI+qEc8+no77r/W35tKH7mGl1EWryWbr6xNiESXlqi83hB4k2/g==
X-Received: by 2002:a05:6a00:164c:b0:50a:472a:6b0a with SMTP id m12-20020a056a00164c00b0050a472a6b0amr15030982pfc.77.1651565473813;
        Tue, 03 May 2022 01:11:13 -0700 (PDT)
Received: from localhost.localdomain (99-0-82-137.lightspeed.sntcca.sbcglobal.net. [99.0.82.137])
        by smtp.gmail.com with ESMTPSA id h2-20020aa786c2000000b0050dc762815dsm5821069pfo.55.2022.05.03.01.11.11
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 03 May 2022 01:11:12 -0700 (PDT)
From: Sargun Dhillon <sargun@sargun.me>
To: Kees Cook <keescook@chromium.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Containers <containers@lists.linux.dev>
Cc: Sargun Dhillon <sargun@sargun.me>,
	Rodrigo Campos <rodrigo@kinvolk.io>,
	Christian Brauner <christian.brauner@ubuntu.com>,
	Giuseppe Scrivano <gscrivan@redhat.com>,
	Will Drewry <wad@chromium.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Tycho Andersen <tycho@tycho.pizza>,
	Alban Crequy <alban@kinvolk.io>,
	linux-kselftest@vger.kernel.org
Subject: [PATCH v4 2/3] selftests/seccomp: Refactor get_proc_stat to split out file reading code
Date: Tue,  3 May 2022 01:09:57 -0700
Message-Id: <20220503080958.20220-3-sargun@sargun.me>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <20220503080958.20220-1-sargun@sargun.me>
References: <20220503080958.20220-1-sargun@sargun.me>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This splits up the get_proc_stat function to make it so we can use it as a
generic helper to read the nth field from multiple different files, versus
replicating the logic in multiple places.

Signed-off-by: Sargun Dhillon <sargun@sargun.me>
Cc: linux-kselftest@vger.kernel.org
---
 tools/testing/selftests/seccomp/seccomp_bpf.c | 54 +++++++++++++------
 1 file changed, 38 insertions(+), 16 deletions(-)

diff --git a/tools/testing/selftests/seccomp/seccomp_bpf.c b/tools/testing/selftests/seccomp/seccomp_bpf.c
index ab340c4759a3..4fb5eda89223 100644
--- a/tools/testing/selftests/seccomp/seccomp_bpf.c
+++ b/tools/testing/selftests/seccomp/seccomp_bpf.c
@@ -4231,32 +4231,54 @@ TEST(user_notification_addfd_rlimit)
 	close(memfd);
 }
 
-static char get_proc_stat(int pid)
+/*
+ * gen_nth - Get the nth, space separated entry in a file.
+ *
+ * Returns the length of the read field.
+ * Throws error if field is zero-lengthed.
+ */
+static ssize_t get_nth(struct __test_metadata *_metadata, const char *path,
+		     const unsigned int position, char **entry)
 {
-	char proc_path[100] = {0};
 	char *line = NULL;
-	size_t len = 0;
+	unsigned int i;
 	ssize_t nread;
-	char status;
+	size_t len = 0;
 	FILE *f;
-	int i;
 
-	snprintf(proc_path, sizeof(proc_path), "/proc/%d/stat", pid);
-	f = fopen(proc_path, "r");
-	if (f == NULL)
-		ksft_exit_fail_msg("%s - Could not open %s\n",
-				   strerror(errno), proc_path);
+	f = fopen(path, "r");
+	ASSERT_NE(f, NULL) {
+		TH_LOG("Coud not open %s: %s", path, strerror(errno));
+	}
 
-	for (i = 0; i < 3; i++) {
+	for (i = 0; i < position; i++) {
 		nread = getdelim(&line, &len, ' ', f);
-		if (nread <= 0)
-			ksft_exit_fail_msg("Failed to read status: %s\n",
-					   strerror(errno));
+		ASSERT_GE(nread, 0) {
+			TH_LOG("Failed to read %d entry in file %s", i, path);
+		}
 	}
+	fclose(f);
+
+	ASSERT_GT(nread, 0) {
+		TH_LOG("Entry in file %s had zero length", path);
+	}
+
+	*entry = line;
+	return nread - 1;
+}
+
+/* For a given PID, get the task state (D, R, etc...) */
+static char get_proc_stat(struct __test_metadata *_metadata, pid_t pid)
+{
+	char proc_path[100] = {0};
+	char status;
+	char *line;
+
+	snprintf(proc_path, sizeof(proc_path), "/proc/%d/stat", pid);
+	ASSERT_EQ(get_nth(_metadata, proc_path, 3, &line), 1);
 
 	status = *line;
 	free(line);
-	fclose(f);
 
 	return status;
 }
@@ -4317,7 +4339,7 @@ TEST(user_notification_fifo)
 	/* This spins until all of the children are sleeping */
 restart_wait:
 	for (i = 0; i < ARRAY_SIZE(pids); i++) {
-		if (get_proc_stat(pids[i]) != 'S') {
+		if (get_proc_stat(_metadata, pids[i]) != 'S') {
 			nanosleep(&delay, NULL);
 			goto restart_wait;
 		}
-- 
2.25.1

