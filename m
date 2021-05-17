Received: from mail-pj1-f54.google.com (mail-pj1-f54.google.com [209.85.216.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7D7882FB6
	for <containers@lists.linux.dev>; Mon, 17 May 2021 19:39:22 +0000 (UTC)
Received: by mail-pj1-f54.google.com with SMTP id g6-20020a17090adac6b029015d1a9a6f1aso444422pjx.1
        for <containers@lists.linux.dev>; Mon, 17 May 2021 12:39:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=sargun.me; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=Z1mz9PlfYEOhntUBF4HuAgZ54MFnxLx8NEndufo+JXI=;
        b=nDlzVHCmeHw1qXb4ontaMW5zMt/9+gZdA4vt7JBNS8rurtKIRqdSGaWbmrcold0Dlx
         OvnXWKU/ZuZvEAmPd7KO2DbW3dPd54mxnNqakVfV7lushgPihuX81cyqvYkr2atg89sf
         Xg3B6Fv8v1cuwj3jocwekApC9VjDaLKIghgpE=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=Z1mz9PlfYEOhntUBF4HuAgZ54MFnxLx8NEndufo+JXI=;
        b=ScqE+6QVt2wxbWOkioBF0rqh3ggfoQH5eFkFJwl5/WQiAMDYqrO0rRdJcPwwoECGyR
         PWcbCOWysef4xkADHllwpyf1bZ8TWJkBJZJk6xuezqSEDlAUCQs8mFhHdQn/fPayGHmN
         mJ3IG0kfxzcMgXmHc+YrJJNv/PlH2x3c5jZDlktDOWQ8kcQGQwNBrkuWnVKzZnUUOljD
         ZTfu0jQb10jn08SlBGeSMM7tq+fUuIJF++bMB5EyJ9FMH2F5gyt6y3L3upNc5NVGbivf
         YCr3gjXdfQOMMPW8hUvZcRnr26FX++7Q63l3b2QtFS/Vkq+7KKN65V9w2JSZI+mKwgqi
         VxHw==
X-Gm-Message-State: AOAM531pgGcGkrxSsYW15x4tkWG2EOFQueNAwjYXN4g8xZ7vSRJyLZdx
	y0SzZ3PP5uMQ3Uba6HyMOqeEwA==
X-Google-Smtp-Source: ABdhPJw7M3mVzYORwM+TIxIL9dcKP+j6c3DnN1b+J626B6lAgwKaLR3+ZGneR0r6evspU9rFdgiCJA==
X-Received: by 2002:a17:90a:df8d:: with SMTP id p13mr731355pjv.67.1621280361506;
        Mon, 17 May 2021 12:39:21 -0700 (PDT)
Received: from ubuntu.netflix.com (136-25-20-203.cab.webpass.net. [136.25.20.203])
        by smtp.gmail.com with ESMTPSA id r11sm11132110pgl.34.2021.05.17.12.39.20
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 17 May 2021 12:39:20 -0700 (PDT)
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
Subject: [PATCH v2 0/4] Atomic addfd send and reply
Date: Mon, 17 May 2021 12:39:04 -0700
Message-Id: <20210517193908.3113-1-sargun@sargun.me>
X-Mailer: git-send-email 2.25.1
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This is somewhat of a respin of "Handle seccomp notification preemption"
but without the controversial parts.


This patchset addresses a race condition we've dealt with recently with
seccomp. Specifically programs interrupting syscalls while they're in
progress. This was exacerbated by Golang's recent adoption of "async
preemption", in which they try to interrupt any syscall that's been running
for more than 10ms during GC. During certain syscalls, it's non-trivial to
write them in a reetrant manner in userspace (socket).

It focuses on one use cases, which is adding file descriptors to a process
"atomically" during the seccomp reply, as opposed to discretizing the calls
which may result in a potential file descriptor leak and inconsistent
program state.

Changes since v1:
 * Clarifcation to commit comments

Rodrigo Campos (2):
  seccomp: Support atomic "addfd + send reply"
  selftests/seccomp: Add test for atomic addfd+send

Sargun Dhillon (2):
  Documentation: seccomp: Fix user notification documentation
  seccomp: Refactor notification handler to prepare for new semantics

 .../userspace-api/seccomp_filter.rst          | 28 +++++--
 include/uapi/linux/seccomp.h                  |  1 +
 kernel/seccomp.c                              | 79 ++++++++++++++-----
 tools/testing/selftests/seccomp/seccomp_bpf.c | 38 +++++++++
 4 files changed, 120 insertions(+), 26 deletions(-)

-- 
2.25.1

