Received: from mail-qv1-f51.google.com (mail-qv1-f51.google.com [209.85.219.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4152F70
	for <containers@lists.linux.dev>; Sun,  2 May 2021 00:19:08 +0000 (UTC)
Received: by mail-qv1-f51.google.com with SMTP id b14so930881qvf.9
        for <containers@lists.linux.dev>; Sat, 01 May 2021 17:19:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=sargun.me; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=vfAsECn/fzRz8G1nJMm0ods0ajgpdWjB1GxnEL0hfI8=;
        b=fpbZq7C8+zvIV2lES2K6x9lsB7pyHmvs4Yxy9DkSMbsmefAzZD0E/RgPvUXyJdb6Q+
         TKiP2DEq/Pxqu7/7b055o0hEv0TFebGCinfp9yJUuVm05BmUcNSiL/BkcfH9VT/J9oaq
         JotWx2+KQ5biyK6x3pTn80D1Wzv4ta3gS2qzs=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=vfAsECn/fzRz8G1nJMm0ods0ajgpdWjB1GxnEL0hfI8=;
        b=hM8ts6gyxwlEw+1k13ZoK7HcymS92E/xs629uifbl446TepbHTcY0vGvViKhw9ay0/
         5UwuEBW0f3Gf8jSbFVtIfBMnlw1YKMnc/8IX8LZp/f7j2KZ5T6ZPN1Pw7cZPTcNQp7xC
         ankOHktAWPfUqb2wu+L9UiQzqbijVszZFdPQMdB9TuoMJuskwx5k3pTqr8aRSvxZbHqg
         0mQ82StKi6NYuEFPhenBZiH+ri/sRk46f1gVWqlpJndJuRTFmeWKwC9zecNYci2VUjQ0
         xX5Qc0T30hdSeeE1f3b7wTpz+kV4bRwmTzqjB0fxBT3qO0ksm/NULvcNXSDx1RzLLYbU
         APqg==
X-Gm-Message-State: AOAM530u9BCCchr82y8RVA0uEnr+fiNxNdRoDsLsTt5ri1hjWPUplxPf
	WKTcvVILEMoAFsNum5OaMB2tOg==
X-Google-Smtp-Source: ABdhPJwNAfn4+E6CCzyl/D25KYz95m1jhCAOsy1DssEolXqjzMVufdUNRmGSHjVvoBu+pvuBtTZmrA==
X-Received: by 2002:a05:6214:2503:: with SMTP id gf3mr12604871qvb.61.1619914747252;
        Sat, 01 May 2021 17:19:07 -0700 (PDT)
Received: from ubuntu.netflix.com (136-25-20-203.cab.webpass.net. [136.25.20.203])
        by smtp.gmail.com with ESMTPSA id p5sm5146067qkh.135.2021.05.01.17.19.03
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 01 May 2021 17:19:06 -0700 (PDT)
From: Sargun Dhillon <sargun@sargun.me>
To: Kees Cook <keescook@chromium.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Containers <containers@lists.linux.dev>,
	Tycho Andersen <tycho@tycho.pizza>,
	Andy Lutomirski <luto@kernel.org>
Cc: Sargun Dhillon <sargun@sargun.me>,
	=?UTF-8?q?Mauricio=20V=C3=A1squez=20Bernal?= <mauricio@kinvolk.io>,
	Rodrigo Campos <rodrigo@kinvolk.io>,
	Giuseppe Scrivano <gscrivan@redhat.com>,
	Christian Brauner <christian.brauner@ubuntu.com>,
	=?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@linux.microsoft.com>
Subject: [PATCH 2/4] seccomp: Refactor notification handler to prepare for new semantics
Date: Sat,  1 May 2021 17:18:49 -0700
Message-Id: <20210502001851.3346-3-sargun@sargun.me>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <20210502001851.3346-1-sargun@sargun.me>
References: <20210502001851.3346-1-sargun@sargun.me>
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This refactors the user notification code to have a do / while loop around
the completion condition. This has a small change in semantic, in that
previously we ignored addfd calls upon wakeup if the notification had been
responded to, but instead with the new change we check for an outstanding
addfd calls prior to returning to userspace.

Rodrigo Campos also identified a bug that can result in addfd causing
an early return, when the supervisor didn't actually handle the syscall [1].

[1]: https://lore.kernel.org/lkml/20210413160151.3301-1-rodrigo@kinvolk.io/

Fixes: 7cf97b125455 ("seccomp: Introduce addfd ioctl to seccomp user notifier")
Signed-off-by: Sargun Dhillon <sargun@sargun.me>
---
 kernel/seccomp.c | 30 ++++++++++++++++--------------
 1 file changed, 16 insertions(+), 14 deletions(-)

diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 1d60fc2c9987..93684cc63285 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -1098,28 +1098,30 @@ static int seccomp_do_user_notification(int this_syscall,
 
 	up(&match->notif->request);
 	wake_up_poll(&match->wqh, EPOLLIN | EPOLLRDNORM);
-	mutex_unlock(&match->notify_lock);
 
 	/*
 	 * This is where we wait for a reply from userspace.
 	 */
-wait:
-	err = wait_for_completion_interruptible(&n.ready);
-	mutex_lock(&match->notify_lock);
-	if (err == 0) {
-		/* Check if we were woken up by a addfd message */
+	do {
+		mutex_unlock(&match->notify_lock);
+		err = wait_for_completion_interruptible(&n.ready);
+		mutex_lock(&match->notify_lock);
+		if (err != 0)
+			goto interrupted;
+
 		addfd = list_first_entry_or_null(&n.addfd,
 						 struct seccomp_kaddfd, list);
-		if (addfd && n.state != SECCOMP_NOTIFY_REPLIED) {
+		/* Check if we were woken up by a addfd message */
+		if (addfd)
 			seccomp_handle_addfd(addfd);
-			mutex_unlock(&match->notify_lock);
-			goto wait;
-		}
-		ret = n.val;
-		err = n.error;
-		flags = n.flags;
-	}
 
+	}  while (n.state != SECCOMP_NOTIFY_REPLIED);
+
+	ret = n.val;
+	err = n.error;
+	flags = n.flags;
+
+interrupted:
 	/* If there were any pending addfd calls, clear them out */
 	list_for_each_entry_safe(addfd, tmp, &n.addfd, list) {
 		/* The process went away before we got a chance to handle it */
-- 
2.25.1

