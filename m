Return-Path: <SRS0=UpRV=EI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 421E3C00A89
	for <containers@archiver.kernel.org>; Mon,  2 Nov 2020 20:37:22 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 967E820678
	for <containers@archiver.kernel.org>; Mon,  2 Nov 2020 20:37:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="aKaoXciH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 967E820678
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 1710A204E7;
	Mon,  2 Nov 2020 20:37:21 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id R4Sucyv3cy6G; Mon,  2 Nov 2020 20:37:19 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id A1537204D9;
	Mon,  2 Nov 2020 20:37:19 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 93A18C088B;
	Mon,  2 Nov 2020 20:37:19 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 0CFEDC0051
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 20:37:18 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id D051A204DD
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 20:37:17 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id s3nkNjUrzR+G
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 20:37:16 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-wr1-f65.google.com (mail-wr1-f65.google.com
 [209.85.221.65])
 by silver.osuosl.org (Postfix) with ESMTPS id 97A67204D9
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 20:37:16 +0000 (UTC)
Received: by mail-wr1-f65.google.com with SMTP id w14so16096901wrs.9
 for <containers@lists.linux-foundation.org>;
 Mon, 02 Nov 2020 12:37:16 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=P6bwcjJ2XDoLMn5CYKNmMHk7XIKE6/VWTbsWHP9UClo=;
 b=aKaoXciH+Pz6gDWihGavAzN/ujpZoxLKjMpbk0qtQE+WdgaClA6/PW02jsZ/IyQiba
 Qwl/n98Sl4nt9BE97wkuciYtsEMvuWuJK2OEzq1W35DoabrGO/rBpCR/Jp0EX5mkl9JH
 2O1AQH2Oov0eCzctSKszffNczo8gdzVQdzgL9UmbOfbMNeUjeGwWvN4ccdxXR6VkuYPn
 tnLYbGCy2RU8DfX/3qehxfdA/dh+HtTki/1vQZ1PmQN1/dknqPHwyCpp9D27NkzIykxN
 zmWJ0GgBtHOudGW4uZVMDrXk2wrCh3zdhSU5xc5Sc2r8bqtVqMXVEb/aD/JVFzFuBsjr
 hlog==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=P6bwcjJ2XDoLMn5CYKNmMHk7XIKE6/VWTbsWHP9UClo=;
 b=gdRthHuLcH8KMn1mx1I005PVLmmrTjBgkqTnoJwSeK7FIs1bUAYJYxYh4wKYHkXVKa
 P9NjdK/UjzcWgxRJJyy7yTlKmsvYwpF6OYZ/1wW9IJtvO6QVRKDVk/J13exiu2KmvW74
 PJRu8SrKutJ9OkC133zYR2TnkDzoJu17DsB0S0/OGu4sR9tYHs3rgxkkob1QzVpkm+kL
 /KyA3C5wj23Kd9C7kfGhwie8trriUl59Eogk9vapaux5GWpBN9tMCTJoqGBqcPKW5Pwh
 anLdvbRRpuNyHgYzTDpRmHXVieRSVUEBHadZm+irMUPyQ7Lx3vwkRqSMZFsmmLRLWzXu
 NjBw==
X-Gm-Message-State: AOAM5333NItrvLfyth+DlEFAW8PMfWwVXE7OTIh/9Jthv7RoRSHvJreP
 8ZcLdDOU6NGue/RWXWA46cGJHQ==
X-Google-Smtp-Source: ABdhPJzXx/XOiYBSftriqL4NwZCBFmoS3l5uwsKoMYq4A2Lbr3Q9wAPU2NS/WPIdFxi6SjgyUI707A==
X-Received: by 2002:a05:6000:118c:: with SMTP id
 g12mr22889111wrx.246.1604349434817; 
 Mon, 02 Nov 2020 12:37:14 -0800 (PST)
Received: from localhost ([2a02:168:96c5:1:55ed:514f:6ad7:5bcc])
 by smtp.gmail.com with ESMTPSA id 9sm672797wmk.5.2020.11.02.12.37.14
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Mon, 02 Nov 2020 12:37:14 -0800 (PST)
To: Kees Cook <keescook@chromium.org>
Subject: [PATCH 2/3] samples: seccomp: simplify user-trap sample
Date: Mon,  2 Nov 2020 21:37:05 +0100
Message-Id: <20201102203706.827510-2-jannh@google.com>
X-Mailer: git-send-email 2.29.1.341.ge80a0c044ae-goog
In-Reply-To: <20201102203706.827510-1-jannh@google.com>
References: <20201102203706.827510-1-jannh@google.com>
MIME-Version: 1.0
Cc: Giuseppe Scrivano <giuseppe@scrivano.org>, Will Drewry <wad@chromium.org>,
 Paul Moore <paul@paul-moore.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>,
 Christian Brauner <christian.brauner@canonical.com>,
 "Michael Kerrisk \(man-pages\)" <mtk.manpages@gmail.com>
X-BeenThere: containers@lists.linux-foundation.org
X-Mailman-Version: 2.1.15
Precedence: list
List-Id: Linux Containers <containers.lists.linuxfoundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers@lists.linux-foundation.org>
List-Help: <mailto:containers-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=subscribe>
From: Jann Horn via Containers <containers@lists.linux-foundation.org>
Reply-To: Jann Horn <jannh@google.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

Now that the blocking unotify API returns when all users of the filter are
gone, get rid of the helper task that kills the blocked task.

Note that since seccomp only tracks whether tasks are completely gone, not
whether they have exited, we need to handle SIGCHLD while blocked on
SECCOMP_IOCTL_NOTIF_RECV. Alternatively we could also set SIGCHLD to
SIG_IGN and let the kernel autoreap exiting children.

Signed-off-by: Jann Horn <jannh@google.com>
---
 samples/seccomp/user-trap.c | 163 +++++++++++++++++++-----------------
 1 file changed, 87 insertions(+), 76 deletions(-)

diff --git a/samples/seccomp/user-trap.c b/samples/seccomp/user-trap.c
index b9e666f15998..92d0f9ba58b6 100644
--- a/samples/seccomp/user-trap.c
+++ b/samples/seccomp/user-trap.c
@@ -15,6 +15,7 @@
 #include <sys/syscall.h>
 #include <sys/user.h>
 #include <sys/ioctl.h>
+#include <sys/prctl.h>
 #include <sys/ptrace.h>
 #include <sys/mount.h>
 #include <linux/limits.h>
@@ -198,6 +199,21 @@ static int handle_req(struct seccomp_notif *req,
 	return ret;
 }
 
+static pid_t worker;
+static int worker_status;
+
+static void sigchld_handler(int sig, siginfo_t *info, void *ctx)
+{
+	if (info->si_pid != worker) {
+		fprintf(stderr, "SIGCHLD from unknown process\n");
+		return;
+	}
+	if (waitpid(worker, &worker_status, 0) != worker) {
+		perror("waitpid");
+		exit(1);
+	}
+}
+
 static void set_blocking(int fd)
 {
 	int file_status_flags = fcntl(fd, F_GETFL);
@@ -211,14 +227,26 @@ static void set_blocking(int fd)
 
 int main(void)
 {
-	int sk_pair[2], ret = 1, status, listener;
-	pid_t worker = 0 , tracer = 0;
+	int sk_pair[2], ret = 1, listener;
+	struct seccomp_notif *req;
+	struct seccomp_notif_resp *resp;
+	struct seccomp_notif_sizes sizes;
+	pid_t parent = getpid();
 
 	if (socketpair(PF_LOCAL, SOCK_SEQPACKET, 0, sk_pair) < 0) {
 		perror("socketpair");
 		return 1;
 	}
 
+	struct sigaction sigchld_act = {
+		.sa_sigaction = sigchld_handler,
+		.sa_flags = SA_SIGINFO
+	};
+	if (sigaction(SIGCHLD, &sigchld_act, NULL)) {
+		perror("sigaction");
+		return 1;
+	}
+
 	worker = fork();
 	if (worker < 0) {
 		perror("fork");
@@ -226,6 +254,14 @@ int main(void)
 	}
 
 	if (worker == 0) {
+		/* quit if the parent dies */
+		if (prctl(PR_SET_PDEATHSIG, SIGKILL)) {
+			perror("PR_SET_PDEATHSIG");
+			exit(1);
+		}
+		if (getppid() != parent)
+			exit(1);
+
 		listener = user_trap_syscall(__NR_mount,
 					     SECCOMP_FILTER_FLAG_NEW_LISTENER);
 		if (listener < 0) {
@@ -283,87 +319,69 @@ int main(void)
 	 */
 	listener = recv_fd(sk_pair[0]);
 	if (listener < 0)
-		goto out_kill;
+		goto close_pair;
 
 	set_blocking(listener);
 
-	/*
-	 * Fork a task to handle the requests. This isn't strictly necessary,
-	 * but it makes the particular writing of this sample easier, since we
-	 * can just wait ofr the tracee to exit and kill the tracer.
-	 */
-	tracer = fork();
-	if (tracer < 0) {
-		perror("fork");
-		goto out_kill;
+	if (seccomp(SECCOMP_GET_NOTIF_SIZES, 0, &sizes) < 0) {
+		perror("seccomp(GET_NOTIF_SIZES)");
+		goto out_close;
 	}
 
-	if (tracer == 0) {
-		struct seccomp_notif *req;
-		struct seccomp_notif_resp *resp;
-		struct seccomp_notif_sizes sizes;
+	req = malloc(sizes.seccomp_notif);
+	if (!req)
+		goto out_close;
+
+	resp = malloc(sizes.seccomp_notif_resp);
+	if (!resp)
+		goto out_req;
+	memset(resp, 0, sizes.seccomp_notif_resp);
+
+	while (1) {
+		memset(req, 0, sizes.seccomp_notif);
+		if (ioctl(listener, SECCOMP_IOCTL_NOTIF_RECV, req)) {
+			if (errno == ENOTCONN) {
+				/* The child process went away. */
+				break;
+			} else if (errno == EINTR) {
+				continue;
+			}
 
-		if (seccomp(SECCOMP_GET_NOTIF_SIZES, 0, &sizes) < 0) {
-			perror("seccomp(GET_NOTIF_SIZES)");
-			goto out_close;
+			perror("ioctl recv");
+			goto out_resp;
 		}
 
-		req = malloc(sizes.seccomp_notif);
-		if (!req)
-			goto out_close;
-
-		resp = malloc(sizes.seccomp_notif_resp);
-		if (!resp)
-			goto out_req;
-		memset(resp, 0, sizes.seccomp_notif_resp);
+		if (handle_req(req, resp, listener) < 0)
+			goto out_resp;
 
-		while (1) {
-			memset(req, 0, sizes.seccomp_notif);
-			if (ioctl(listener, SECCOMP_IOCTL_NOTIF_RECV, req)) {
-				if (errno == ENOTCONN)
-					exit(0);
-
-				perror("ioctl recv");
-				goto out_resp;
-			}
-
-			if (handle_req(req, resp, listener) < 0)
-				goto out_resp;
-
-			/*
-			 * ENOENT here means that the task may have gotten a
-			 * signal and restarted the syscall. It's up to the
-			 * handler to decide what to do in this case, but for
-			 * the sample code, we just ignore it. Probably
-			 * something better should happen, like undoing the
-			 * mount, or keeping track of the args to make sure we
-			 * don't do it again.
-			 */
-			if (ioctl(listener, SECCOMP_IOCTL_NOTIF_SEND, resp) < 0 &&
-			    errno != ENOENT) {
-				perror("ioctl send");
-				goto out_resp;
-			}
+		/*
+		 * ENOENT here means that the task may have gotten a
+		 * signal and restarted the syscall. It's up to the
+		 * handler to decide what to do in this case, but for
+		 * the sample code, we just ignore it. Probably
+		 * something better should happen, like undoing the
+		 * mount, or keeping track of the args to make sure we
+		 * don't do it again.
+		 */
+		if (ioctl(listener, SECCOMP_IOCTL_NOTIF_SEND, resp) < 0 &&
+		    errno != ENOENT) {
+			perror("ioctl send");
+			goto out_resp;
 		}
+	}
+	ret = 0;
+
 out_resp:
-		free(resp);
+	free(resp);
 out_req:
-		free(req);
+	free(req);
 out_close:
-		close(listener);
-		exit(1);
-	}
-
 	close(listener);
 
-	if (waitpid(worker, &status, 0) != worker) {
-		perror("waitpid");
-		goto out_kill;
-	}
-
 	if (umount2("/tmp/foo", MNT_DETACH) < 0 && errno != EINVAL) {
 		perror("umount2");
-		goto out_kill;
+		ret = 1;
+		goto close_pair;
 	}
 
 	if (remove("/tmp/foo") < 0 && errno != ENOENT) {
@@ -371,19 +389,12 @@ int main(void)
 		exit(1);
 	}
 
-	if (!WIFEXITED(status) || WEXITSTATUS(status)) {
+	if (!WIFEXITED(worker_status) || WEXITSTATUS(worker_status)) {
 		fprintf(stderr, "worker exited nonzero\n");
-		goto out_kill;
+		ret = 1;
+		goto close_pair;
 	}
 
-	ret = 0;
-
-out_kill:
-	if (tracer > 0)
-		kill(tracer, SIGKILL);
-	if (worker > 0)
-		kill(worker, SIGKILL);
-
 close_pair:
 	close(sk_pair[0]);
 	close(sk_pair[1]);
-- 
2.29.1.341.ge80a0c044ae-goog

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
