Received: from mail-pg1-f178.google.com (mail-pg1-f178.google.com [209.85.215.178])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D9C5E17E9
	for <containers@lists.linux.dev>; Tue,  3 May 2022 08:11:10 +0000 (UTC)
Received: by mail-pg1-f178.google.com with SMTP id x12so13475288pgj.7
        for <containers@lists.linux.dev>; Tue, 03 May 2022 01:11:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=sargun.me; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=3ingImJTtvFfkp4DYljnLHHv+bSfMJ3n+N1up5cyEBc=;
        b=ZKtbZh0ltnirTiWTEfFYomv04BeAehvM0gAet6KiXZjvLCZ1xaCyGJuzxXHjOj6eMv
         uSPyMlfeC4XREadNu3xH4/sYr7OCt7jGLoM69eiZrrRYPK87w7As3TcdcpWApU73U0zU
         i8STlqQ8eKen0nwNe25dmuiLfI6EKt7ooWMn4=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=3ingImJTtvFfkp4DYljnLHHv+bSfMJ3n+N1up5cyEBc=;
        b=HgPvZGjytU388c0cNiv1NPzV3XZ0IfibixszyhZO6cHmUGg7I7GbXsO7TmTU1OMebK
         eB6pERkDcSQg/VsNo/qkFLxJv1uzEQ3T9xmQKw7xg+Tk5Ru5nMQUR77pPbeK/bEcrlcS
         2sq7ao5KrAVTHZnNG2UI7IfyvzUcSYgOYT75NKSNDGCXYeTQL+3qDuch6pXKKM9oZEX1
         JxrzfE+0daywx7FywFillQBaBn9cpA0wcfddBeWuVPYDDpMC7pKmNbWcavXBbAFSaaFx
         FaLcBTsI78jAOm6K94qwFtKpeebqx16lNz2OeYQ82Kb6L2h8a0TfR0rilnBCuPPhb1EO
         0CZQ==
X-Gm-Message-State: AOAM531AScZ/IlMH9UeUnLdxRc5mQ1dUVlbPOmRVzK1mzFkyNqMNyx2B
	c0jUfwoirnzz1FZn99dSrwH9mA==
X-Google-Smtp-Source: ABdhPJwCOmpDNmkh3bQetCNPZEgNRPP1XjypzwvoCv3dojW+WgrUkn7VTYGM3DW50Wva/2hftaA3MA==
X-Received: by 2002:a05:6a00:2310:b0:4fa:7eb1:e855 with SMTP id h16-20020a056a00231000b004fa7eb1e855mr14855919pfh.14.1651565470059;
        Tue, 03 May 2022 01:11:10 -0700 (PDT)
Received: from localhost.localdomain (99-0-82-137.lightspeed.sntcca.sbcglobal.net. [99.0.82.137])
        by smtp.gmail.com with ESMTPSA id h2-20020aa786c2000000b0050dc762815dsm5821069pfo.55.2022.05.03.01.11.08
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 03 May 2022 01:11:08 -0700 (PDT)
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
	Alban Crequy <alban@kinvolk.io>
Subject: [PATCH v4 0/3] Handle seccomp notification preemption
Date: Tue,  3 May 2022 01:09:55 -0700
Message-Id: <20220503080958.20220-1-sargun@sargun.me>
X-Mailer: git-send-email 2.25.1
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This patchset addresses a race condition we've dealt with recently with
seccomp. Specifically programs interrupting syscalls while they're in
progress. This was exacerbated by Golang's[1] recent adoption of
"Non-cooperative goroutine preemption", in which they try to interrupt any
syscall that's been running for more than 10ms. During certain syscalls,
it's non-trivial to write them in a reetrant manner in userspace (mount).

It allows a per-filter flag to be set that makes it so that the notifying
process will switch to "TASK_KILLABLE" as opposed to returning to userspace
on non-fatal signals.

Changes since v3[4]:
 * Clean up tests
   * Split out helper function (dedupe code)
   * Add some explanation about whats going on
 * Small documentation edit

Changes since v2[3]:
 * Split out addfd patches
 * Move the flag to be per-filter (as opposed to per notification)

Changes since v1[2]:
 * Fix some documentation
 * Add Rata's patches to allow for direct return from addfd

[1]: https://github.com/golang/proposal/blob/master/design/24543-non-cooperative-preemption.md
[2]: https://lore.kernel.org/lkml/20210220090502.7202-1-sargun@sargun.me/
[3]: https://lore.kernel.org/all/20210426180610.2363-1-sargun@sargun.me/
[4]: https://lore.kernel.org/lkml/20220429023113.74993-1-sargun@sargun.me/

Sargun Dhillon (3):
  seccomp: Add wait_killable semantic to seccomp user notifier
  selftests/seccomp: Refactor get_proc_stat to split out file reading
    code
  selftests/seccomp: Add test for wait killable notifier

 .../userspace-api/seccomp_filter.rst          |  10 +
 include/linux/seccomp.h                       |   3 +-
 include/uapi/linux/seccomp.h                  |   2 +
 kernel/seccomp.c                              |  42 ++-
 tools/testing/selftests/seccomp/seccomp_bpf.c | 282 +++++++++++++++++-
 5 files changed, 320 insertions(+), 19 deletions(-)

-- 
2.25.1

