Received: from mail-pj1-f52.google.com (mail-pj1-f52.google.com [209.85.216.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 445E633C9
	for <containers@lists.linux.dev>; Tue,  3 May 2022 21:22:47 +0000 (UTC)
Received: by mail-pj1-f52.google.com with SMTP id t11-20020a17090ad50b00b001d95bf21996so3447103pju.2
        for <containers@lists.linux.dev>; Tue, 03 May 2022 14:22:47 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=6A2AVhB3i38hjuJtf8B4kMF2LM5SwI8v95owoTGlIsU=;
        b=UC8VXG9FGdX/1g+XOAF13irYs/uk+mdl7nSt8x98nbXKE0wpWdXE6gYGpBwNpWxu98
         jMjyJU4+N/hc/02fCPsPrCvuAOssY4pwc24mkepgMOTYXM3RLqsFzJ09JHMeol3bbdmw
         zOlPc9Q/5bpqP5fW5PD4OMa10kxdUMtmzK3mc=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=6A2AVhB3i38hjuJtf8B4kMF2LM5SwI8v95owoTGlIsU=;
        b=BIHvZ5lv/0g95bikn6Bcs5fUSdqRJkQ+uDpiZw+1Vhl6qHKjDA8k2JGVOzn3uu4edh
         n5lTsYkAibr2KbTmYMrVFCVvTBLbzSwhKTC7pIANWFWGDA5kHd6mrQL2PKzLucksSRo4
         MlCTSZWKabZqxIw2g8qzWncsYaZTlFwpIBnmzr7ZZtPW7YduLMInaLeZmVQjLhyJ9uOx
         XZ83lwASAdK0K5M2fT1kspG/1UmrSEaohSibzq/c2+CKgm+dMQDDeU0pAFcBQF/1/71T
         2Wstc1Qixq/TGZAwiL/l/hr7QslfTV7a3oLfvApD93jC1TZF7OF60hcfRgEQ6zcRg5Mt
         8jVg==
X-Gm-Message-State: AOAM533TuiNO9G9+s6SQUD3aTYu3D55hze+AF9chxtKJkdOdlEoia7q7
	0h1Xb4j7xXtfeq8jpqNRV3iwZA==
X-Google-Smtp-Source: ABdhPJwH9lF9KQCbmuD8slVOXedC8OmP9j4blY1Jned8m/4YkGG9MTBcrnge2aG6a+EkUXBBDPEPvA==
X-Received: by 2002:a17:903:248:b0:155:e8c6:8770 with SMTP id j8-20020a170903024800b00155e8c68770mr17930962plh.129.1651612966688;
        Tue, 03 May 2022 14:22:46 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id g20-20020aa78194000000b0050dc762818fsm6786947pfi.105.2022.05.03.14.22.46
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 03 May 2022 14:22:46 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
To: linux-kernel@vger.kernel.org,
	sargun@sargun.me,
	containers@lists.linux.dev
Cc: Kees Cook <keescook@chromium.org>,
	wad@chromium.org,
	rodrigo@kinvolk.io,
	gscrivan@redhat.com,
	luto@amacapital.net,
	alban@kinvolk.io,
	tycho@tycho.pizza,
	Christian Brauner <brauner@kernel.org>
Subject: Re: [PATCH v4 0/3] Handle seccomp notification preemption
Date: Tue,  3 May 2022 14:22:30 -0700
Message-Id: <165161294755.3926933.6572056353019699340.b4-ty@chromium.org>
X-Mailer: git-send-email 2.32.0
In-Reply-To: <20220503080958.20220-1-sargun@sargun.me>
References: <20220503080958.20220-1-sargun@sargun.me>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Tue, 3 May 2022 01:09:55 -0700, Sargun Dhillon wrote:
> This patchset addresses a race condition we've dealt with recently with
> seccomp. Specifically programs interrupting syscalls while they're in
> progress. This was exacerbated by Golang's[1] recent adoption of
> "Non-cooperative goroutine preemption", in which they try to interrupt any
> syscall that's been running for more than 10ms. During certain syscalls,
> it's non-trivial to write them in a reetrant manner in userspace (mount).
> 
> [...]

Applied to for-next/seccomp, thanks!

[1/3] seccomp: Add wait_killable semantic to seccomp user notifier
      https://git.kernel.org/kees/c/c2aa2dfef243
[2/3] selftests/seccomp: Refactor get_proc_stat to split out file reading code
      https://git.kernel.org/kees/c/922a1b520c5f
[3/3] selftests/seccomp: Add test for wait killable notifier
      https://git.kernel.org/kees/c/3b96a9c522b2

-- 
Kees Cook

