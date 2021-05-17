Received: from mail-pg1-f182.google.com (mail-pg1-f182.google.com [209.85.215.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EEE372FB6
	for <containers@lists.linux.dev>; Mon, 17 May 2021 19:39:23 +0000 (UTC)
Received: by mail-pg1-f182.google.com with SMTP id m124so5334279pgm.13
        for <containers@lists.linux.dev>; Mon, 17 May 2021 12:39:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=sargun.me; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=50KkGnCJU7bKH+8peMyZ5115bieY/zEQkJMPARq00Ko=;
        b=oohbAFG2twd1Yfo6ENRfQUAdk1DgUcxI1o5MD2Kr56au4JkxdsaSptXJNUI52pnQ5a
         LoJC3F6Jj9GJepnCwLxr3eZCx5JA/WZKI0BLZpOgwpl1XwFkl65/PnxbdBnj8zApgijL
         lCWcsaKCcYbN0zdvssR5wpseplH3NhxtcWPmg=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=50KkGnCJU7bKH+8peMyZ5115bieY/zEQkJMPARq00Ko=;
        b=HWMx6z0/+ZPy8zzzrbOmsYgkPzecvC2z37ufJ1bO0/qkhqX1r0m06uCInlLi6+E20D
         DheYmOSG4Ym83LcDAIs+qATJz0jqheTTzR/pcCcgmVidjEoRdBEyAULZDj/LaDI7b3A7
         /dzLq48NWf364wlOr8M0yVKt9DcCDXaaAklTvv8mDRuVd81iL7PLVYU5lDmH5As184ph
         O1kevTWBiVKao927Y3jpXVsQULyi1LqzgJB+NC84HpmMs35U0izJH0H+G5i2KpuRWZKO
         RWd68Q8CNUWXLIsIRqUR45atXqLKhZa0P6BedyDlXDvGgklgWQ8z1Gb2YwByL7dxBOsj
         Ikgg==
X-Gm-Message-State: AOAM533ozPermvQJ4lQNAzNHkS8uMOcrNfwCezkVrhGFk8ob331lx8CT
	pdb+ijnpSsKziLpTMPWf3BYVZQ==
X-Google-Smtp-Source: ABdhPJwAzUdkATlZL7dJYe5rK/nwiwJ4JX0LVe1jFwoqZjhABLEGGFqZF+Rkf66Xb1ARMx5ZHvC7sw==
X-Received: by 2002:aa7:8501:0:b029:2cf:c0b8:4b88 with SMTP id v1-20020aa785010000b02902cfc0b84b88mr1173746pfn.61.1621280363227;
        Mon, 17 May 2021 12:39:23 -0700 (PDT)
Received: from ubuntu.netflix.com (136-25-20-203.cab.webpass.net. [136.25.20.203])
        by smtp.gmail.com with ESMTPSA id r11sm11132110pgl.34.2021.05.17.12.39.21
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 17 May 2021 12:39:22 -0700 (PDT)
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
Subject: [PATCH v2 1/4] Documentation: seccomp: Fix user notification documentation
Date: Mon, 17 May 2021 12:39:05 -0700
Message-Id: <20210517193908.3113-2-sargun@sargun.me>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <20210517193908.3113-1-sargun@sargun.me>
References: <20210517193908.3113-1-sargun@sargun.me>
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
Acked-by: Tycho Andersen <tycho@tycho.pizza>
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

