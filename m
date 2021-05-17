Received: from mail-pj1-f45.google.com (mail-pj1-f45.google.com [209.85.216.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 856792FB6
	for <containers@lists.linux.dev>; Mon, 17 May 2021 19:39:25 +0000 (UTC)
Received: by mail-pj1-f45.google.com with SMTP id cu11-20020a17090afa8bb029015d5d5d2175so194892pjb.3
        for <containers@lists.linux.dev>; Mon, 17 May 2021 12:39:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=sargun.me; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Nyceh4v/u73eL9ZfugXsj2VXRRlfSGYCZ8L9xP6N9v8=;
        b=qmMI1tdiguzLzSViMkp+Ff6aUGNvPHpXTUNpL8r6ruaeAlLXugEAnt3aVTQPyfQIYY
         swdZUTegn399+mE3neiJHtsEabuJdPbasFhTMx1yEnMU7QpTMGoo2T8JEPH/D7cmNs4o
         wP7CVFSax+DPYBQu/OBfZo2m9HzSc/atqD7+k=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=Nyceh4v/u73eL9ZfugXsj2VXRRlfSGYCZ8L9xP6N9v8=;
        b=PfqZ9zZCtf7e14jrxwK6f5v2dL2W9+1wwazuIejodk5QSOSHRJyfw9CN2fgg9O6JZh
         mmiZwZFXuunqoKahQS2oj68hmDGBxOgo4ccy4R3PQIkttrsYzoTZlcmG00tI6t5xY94G
         pM6sKu1ts4lbp9SF1CRI+G4wRNlZb6iOgO1VTi8NMWLjOkNhTEKqOOKBYw3Gbnhui8as
         f6W0gvGvzBgxRuttZqtlwjfBpLJOEumUwH57D3i1WQRLogiUHAhWRisdHob2AjmiyUcL
         ElSJ3yMC+40xj31rjRS89B0UMbZ3SiyHDeh+I5G+nSahsYSCYzwgK63D+JFWn5tAJEA3
         sKRQ==
X-Gm-Message-State: AOAM531FlaJ5XAPiuZbSTCnUbQNjz9k1Ss82LSp+EZf18CTtaDhmFu6K
	6Tk1ESszcgWETIrbdG5czxJFWw==
X-Google-Smtp-Source: ABdhPJwC6YgRWYJ9pA5MPWw85Dz8urOqHGvqhQ63FEIFIcQYomPQ9KHNtLpwT5ijHJJ0tZpIhVOGYQ==
X-Received: by 2002:a17:90a:d496:: with SMTP id s22mr1093306pju.146.1621280364865;
        Mon, 17 May 2021 12:39:24 -0700 (PDT)
Received: from ubuntu.netflix.com (136-25-20-203.cab.webpass.net. [136.25.20.203])
        by smtp.gmail.com with ESMTPSA id r11sm11132110pgl.34.2021.05.17.12.39.23
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 17 May 2021 12:39:24 -0700 (PDT)
From: Sargun Dhillon <sargun@sargun.me>
To: Kees Cook <keescook@chromium.org>,
	LKML <linux-kernel@vger.kernel.org>,
	containers@lists.linux.dev,
	Tycho Andersen <tycho@tycho.pizza>,
	Andy Lutomirski <luto@kernel.org>
Cc: Sargun Dhillon <sargun@sargun.me>,
	=?UTF-8?q?Mauricio=20V=C3=A1squez=20Bernal?= <mauricio@kinvolk.io>,
	Rodrigo Campos <rodrigo@kinvolk.io>,
	Giuseppe Scrivano <gscrivan@redhat.com>,
	Christian Brauner <christian.brauner@ubuntu.com>,
	=?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@linux.microsoft.com>
Subject: [PATCH v2 2/4] seccomp: Refactor notification handler to prepare for new semantics
Date: Mon, 17 May 2021 12:39:06 -0700
Message-Id: <20210517193908.3113-3-sargun@sargun.me>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <20210517193908.3113-1-sargun@sargun.me>
References: <20210517193908.3113-1-sargun@sargun.me>
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
an early return, when the supervisor didn't actually handle the
syscall [1].

[1]: https://lore.kernel.org/lkml/20210413160151.3301-1-rodrigo@kinvolk.io/

Fixes: 7cf97b125455 ("seccomp: Introduce addfd ioctl to seccomp user notifier")
Signed-off-by: Sargun Dhillon <sargun@sargun.me>
Acked-by: Tycho Andersen <tycho@tycho.pizza>
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

