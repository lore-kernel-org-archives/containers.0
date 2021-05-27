Received: from mail-pf1-f171.google.com (mail-pf1-f171.google.com [209.85.210.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BA9AB2FAD
	for <containers@lists.linux.dev>; Thu, 27 May 2021 02:46:04 +0000 (UTC)
Received: by mail-pf1-f171.google.com with SMTP id p39so2507295pfw.8
        for <containers@lists.linux.dev>; Wed, 26 May 2021 19:46:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=iNP/SjcyNaIT9Sh+6s8gT1hO3S0wd0g5pCSpuyaozkw=;
        b=PVk7nItGG9eUgo1RgIty5RHK8WNgpUKygbC/XyLZ+bCNVUctQeKddIwv7nwuobMJmp
         4QWL/b0oxWQqzgu+n3GXsD3vybSuW/8pNpqIO3Reg/9YYX53Q9at+2q9yWKllwV9rOWS
         w8SGJ+mCBoQYkmnaPb3fmb3D3KWBgiFlM4S1g=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=iNP/SjcyNaIT9Sh+6s8gT1hO3S0wd0g5pCSpuyaozkw=;
        b=rt18Ba4ZcExlUgFqu4Ljf+4zppkoCHeB+mWsaPJhEtCZw6Z8EIdbaTpPR/NLgaixx7
         /+CcTfQWQmTh9QdzjMOD/XpNYcZxpgczjvyOxV2e7HMTvdg14MoeD7c8kKtYijY130Yy
         Lg8T9uk24664kHF6ZkQko5MQiqBlsI8R0qBb/UFpQkAIa1Jn8FoaOF6CG/HGs4tZXmsk
         0gGKa9IrQ5de6mIdMAtwxPzAgKUW1IVdTcs6y/wHgBlENUs3X0oWRYYvJrhY+f8j8A1P
         nAawXUOwsgjznBEkOv6cK5vBIAldRpCxjfBHoxd4qhjifV59onDYio10RAp7OGd1my/y
         29Ew==
X-Gm-Message-State: AOAM533uNdCowad/62XlmxzUJ7dsI8diAIXLhHpnzvxusfZ6m99cHJ9/
	83EZomh1nxD5OrryzpqYFU3bRw==
X-Google-Smtp-Source: ABdhPJyLebV7fbvP0NGZ6HxNLgvFI/tiSws2o2+nNKzLsAsea2wvqbAA6v5k04MBPNIORgJ1SVcW2g==
X-Received: by 2002:a63:5a01:: with SMTP id o1mr1563433pgb.313.1622083564242;
        Wed, 26 May 2021 19:46:04 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id k38sm350372pgi.73.2021.05.26.19.46.03
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 26 May 2021 19:46:03 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
To: Tycho Andersen <tycho@tycho.pizza>,
	containers@lists.linux.dev,
	Sargun Dhillon <sargun@sargun.me>,
	Andy Lutomirski <luto@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
Cc: Kees Cook <keescook@chromium.org>,
	Rodrigo Campos <rodrigo@kinvolk.io>,
	=?UTF-8?q?Mauricio=20V=C3=A1squez=20Bernal?= <mauricio@kinvolk.io>,
	Christian Brauner <christian.brauner@ubuntu.com>,
	Giuseppe Scrivano <gscrivan@redhat.com>,
	=?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@linux.microsoft.com>
Subject: Re: [PATCH v2 0/4] Atomic addfd send and reply
Date: Wed, 26 May 2021 19:43:59 -0700
Message-Id: <162208342966.3725800.17683913220837738980.b4-ty@chromium.org>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <20210517193908.3113-1-sargun@sargun.me>
References: <20210517193908.3113-1-sargun@sargun.me>
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Mon, 17 May 2021 12:39:04 -0700, Sargun Dhillon wrote:
> This is somewhat of a respin of "Handle seccomp notification preemption"
> but without the controversial parts.
> 
> 
> This patchset addresses a race condition we've dealt with recently with
> seccomp. Specifically programs interrupting syscalls while they're in
> progress. This was exacerbated by Golang's recent adoption of "async
> preemption", in which they try to interrupt any syscall that's been running
> for more than 10ms during GC. During certain syscalls, it's non-trivial to
> write them in a reetrant manner in userspace (socket).
> 
> [...]

Thanks for your patience on this series! I think this is a clear solution
for the race. Applied to for-next/seccomp, thanks!

[1/4] Documentation: seccomp: Fix user notification documentation
      https://git.kernel.org/kees/c/1e2ca403fa89
[2/4] seccomp: Refactor notification handler to prepare for new semantics
      https://git.kernel.org/kees/c/6a1e0616acde
[3/4] seccomp: Support atomic "addfd + send reply"
      https://git.kernel.org/kees/c/ba9ef89cf83e
[4/4] selftests/seccomp: Add test for atomic addfd+send
      https://git.kernel.org/kees/c/75c98a0d5d3a

-- 
Kees Cook

