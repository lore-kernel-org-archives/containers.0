Received: from mail-qk1-f169.google.com (mail-qk1-f169.google.com [209.85.222.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3A46570
	for <containers@lists.linux.dev>; Sun,  2 May 2021 00:19:03 +0000 (UTC)
Received: by mail-qk1-f169.google.com with SMTP id t17so1900412qkg.4
        for <containers@lists.linux.dev>; Sat, 01 May 2021 17:19:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=sargun.me; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=YFrHuiCgVxuk3VucJdjHQohm6Nqxsi7Fn/b9oyEwGz0=;
        b=FoAUu8AC6MTunvQ8yarUmTFUe5rHqCGRgvUD0UYyeUlF4ZAbQmfZZQHt2WGb3+sX+Z
         DACsq6VP9hE39GEHjzoljku5KgxAxA1pzP24nNCoJnvHUXBZW5VjA7bse7e9935VczCP
         SY4Vl6fldwrS0Fbp4kCSOlZ4xUOAQn51kJoys=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=YFrHuiCgVxuk3VucJdjHQohm6Nqxsi7Fn/b9oyEwGz0=;
        b=g0Aw6Xb0rFWj1ImT083G9u/qWYtDgeaOyU1bXsOL4mdvHHjRVaowsT2b8Fux9etT9J
         rsMJ6HGmxLcQOPj9fj9OGZKkdCQ/XHQJ6N9SpYmszI4bvjVqPs7MSOHSPE1NQ7v8IXqM
         0w+CK3uG9ZJLXAbbWZ8idszVmkPvnmKBUQDgDqVASzXkWkBrVR+ZhfC5NxU3b53Tggfb
         zSCKsSr/EWGINaubpZiManJg11QJbOoIrug1ijSUKAtcx6uH/WFGHMTMvHRSbeqIDuBQ
         KyQyroOWn3PffuJBJj9XdYM17IrPQL3N/tvergyuDvXs925mhnopTqKQsHTR6z2oC9F0
         yN9g==
X-Gm-Message-State: AOAM530/8NOKPPha8YxCJMrrqxkqX5Gn6LERmgcZxX3ODCjD/0IlebR6
	2wK0S8ha101eB06pDYPJqx15yw==
X-Google-Smtp-Source: ABdhPJypwSf8TS50lZmHuge623bTNQIf81qG1QW2YfGdO+acApuR7mmBjkWsugo3NrXpKYyzCSiObg==
X-Received: by 2002:a37:7782:: with SMTP id s124mr12425117qkc.305.1619914742997;
        Sat, 01 May 2021 17:19:02 -0700 (PDT)
Received: from ubuntu.netflix.com (136-25-20-203.cab.webpass.net. [136.25.20.203])
        by smtp.gmail.com with ESMTPSA id p5sm5146067qkh.135.2021.05.01.17.19.00
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 01 May 2021 17:19:02 -0700 (PDT)
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
Subject: [PATCH 1/4] Documentation: seccomp: Fix user notification documentation
Date: Sat,  1 May 2021 17:18:48 -0700
Message-Id: <20210502001851.3346-2-sargun@sargun.me>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <20210502001851.3346-1-sargun@sargun.me>
References: <20210502001851.3346-1-sargun@sargun.me>
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The documentation had some previously incorrect information about how
userspace notifications (and responses) were handled due to a change
from a previously proposed patchset.

Signed-off-by: Sargun Dhillon <sargun@sargun.me>
---
 Documentation/userspace-api/seccomp_filter.rst | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/Documentation/userspace-api/seccomp_filter.rst b/Documentation/userspace-api/seccomp_filter.rst
index bd9165241b6c..6efb41cc8072 100644
--- a/Documentation/userspace-api/seccomp_filter.rst
+++ b/Documentation/userspace-api/seccomp_filter.rst
@@ -250,14 +250,14 @@ Users can read via ``ioctl(SECCOMP_IOCTL_NOTIF_RECV)``  (or ``poll()``) on a
 seccomp notification fd to receive a ``struct seccomp_notif``, which contains
 five members: the input length of the structure, a unique-per-filter ``id``,
 the ``pid`` of the task which triggered this request (which may be 0 if the
-task is in a pid ns not visible from the listener's pid namespace), a ``flags``
-member which for now only has ``SECCOMP_NOTIF_FLAG_SIGNALED``, representing
-whether or not the notification is a result of a non-fatal signal, and the
-``data`` passed to seccomp. Userspace can then make a decision based on this
-information about what to do, and ``ioctl(SECCOMP_IOCTL_NOTIF_SEND)`` a
-response, indicating what should be returned to userspace. The ``id`` member of
-``struct seccomp_notif_resp`` should be the same ``id`` as in ``struct
-seccomp_notif``.
+task is in a pid ns not visible from the listener's pid namespace). The
+notification also contains the ``data`` passed to seccomp, and a filters flag.
+The structure should be zeroed out prior to calling the ioctl.
+
+Userspace can then make a decision based on this information about what to do,
+and ``ioctl(SECCOMP_IOCTL_NOTIF_SEND)`` a response, indicating what should be
+returned to userspace. The ``id`` member of ``struct seccomp_notif_resp`` should
+be the same ``id`` as in ``struct seccomp_notif``.
 
 It is worth noting that ``struct seccomp_data`` contains the values of register
 arguments to the syscall, but does not contain pointers to memory. The task's
-- 
2.25.1

