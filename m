Received: from mail-qk1-f180.google.com (mail-qk1-f180.google.com [209.85.222.180])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2182B70
	for <containers@lists.linux.dev>; Sun,  2 May 2021 00:19:01 +0000 (UTC)
Received: by mail-qk1-f180.google.com with SMTP id t17so1900386qkg.4
        for <containers@lists.linux.dev>; Sat, 01 May 2021 17:19:01 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=sargun.me; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=1Of0XcLlfHKCxHPsgc9mruieTzxAs761HczQBIKnhe0=;
        b=RJJsSKb3J60FEzVIAXoIuWglAxKe/2ieSjFdC/m8M4pCax51twizMiQJD4xRJf5cUP
         1PUHPfJmCTkgdV3QuOfLqnpf4Pq3A3bBE4/lsPM67Mxqg+LY6A9pqmBlfIvvRch3vTS8
         KaXFLUQZEAxFqfZ0qa3rBLWpEhsMn9YW8SQvw=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=1Of0XcLlfHKCxHPsgc9mruieTzxAs761HczQBIKnhe0=;
        b=rOSyIqmu1mVIhKovExCfOuyjQDZXzgVyKcCUgCRpfHCRZR6tQirK8L/ou6zDOC3BkG
         0rdt0J2kfMFx2Em42hscM5045mw1H4V+z5mDb30ceQI54m08U4Fe3rkuVMxfLXWrj3pP
         EXFG+L9ilLmcBJYa/OlQBUSi7vPfx/xprenbJnmUN8o50WDgcHyDOK6tfiXlaSTpPheg
         N6xBOSi5vlp9aUm5f0ySbwxi2TjJSjCHTdHHdqUudVrACpVEyZUM8FaCFTHOYQOZKFYw
         vnIVSg/9mG9qJ4NSvYUKXA0YdVOgP85DIg45PQ3rYCE8hxeC1yfkjOIvvIaJN3p7cHK8
         kdug==
X-Gm-Message-State: AOAM530/HCFRzHU4FLB7zFbVx1Pa0ZpPiP7IbV3txbL1cZfMT7jMMlw+
	5NYpOCUMb/OnT10aKc5DUvlG4Q==
X-Google-Smtp-Source: ABdhPJx+X8W3mQclWNKXDwLEWvNcsz3apjytoglj/cO4uLOZ16u8fa7kuVU/QBHXPMoJFD1AmA5xpw==
X-Received: by 2002:a37:b603:: with SMTP id g3mr12729945qkf.38.1619914740751;
        Sat, 01 May 2021 17:19:00 -0700 (PDT)
Received: from ubuntu.netflix.com (136-25-20-203.cab.webpass.net. [136.25.20.203])
        by smtp.gmail.com with ESMTPSA id p5sm5146067qkh.135.2021.05.01.17.18.58
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 01 May 2021 17:18:59 -0700 (PDT)
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
Subject: [PATCH 0/4] Atomic addfd send and reply
Date: Sat,  1 May 2021 17:18:47 -0700
Message-Id: <20210502001851.3346-1-sargun@sargun.me>
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
preemption", in which they try to interrupt any syscall that's been
running for more than 10ms during GC. During certain syscalls, it's
non-trivial to write them in a reetrant manner in userspace (socket).

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

