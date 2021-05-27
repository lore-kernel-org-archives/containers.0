Received: from mail-lj1-f180.google.com (mail-lj1-f180.google.com [209.85.208.180])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C2CE12FB3
	for <containers@lists.linux.dev>; Thu, 27 May 2021 11:51:51 +0000 (UTC)
Received: by mail-lj1-f180.google.com with SMTP id w7so399634lji.6
        for <containers@lists.linux.dev>; Thu, 27 May 2021 04:51:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=kinvolk.io; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=AC3MmOTUuOGnepZXQGZ9Vafob+m6VNi00uwAJjSXdhg=;
        b=iyZqWizjPMOTwqAW/a19v/NIgvvIwslHpX+4ycAXvsYAh93yczNrf6UoKXR00H6+Ad
         eJkLO7BgJ1VRuOffPYI2KsAsoQwB2bTbN1pxGC7D2gPrOb/zS/8P9UNppfs7v4ftRBWd
         L5opBVj+Eigq6yuSPmw+vClubBqnsXFlYOj4Y=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=AC3MmOTUuOGnepZXQGZ9Vafob+m6VNi00uwAJjSXdhg=;
        b=BAtNnnTUz30ERzi/xOoCjDLDnU9XabT/PEkPHppODSwEs0zXIuWYJyiuVBFbQRSOJB
         j9K8Xy+zxP4GBgcBzYuCbTteY6SExAr974uh5f6NIVkSSPS2KO/dS29s+MznmDSOG0Pc
         wJO0cp9BjhdlQuf1mQK8NRrsjzTyQXaQTw5ync/40sSiK9pyc44WmfTHHHkEW6OznHQr
         SXjKDlGtnMq0Fv3y5es5N1vomQ0MTBem6/LikLx31imTxISVhugzt0OWW+IV0DgweMHI
         Pf5WP3GBdo8Ayo+dCE30grCMHLc1B9mWdTGJRz6eaSQ44k8Y0MdkxN61x7io9e9MRUxN
         XeOw==
X-Gm-Message-State: AOAM5339svIay6JVZHVmNfrbRD2VZ0SNjdRRPncU2e0fts5Xec5gTX4R
	98DmNoe4NzT6u6HEa5VgqqpmFKeAt9s6gsGgdE+LrQ==
X-Google-Smtp-Source: ABdhPJwO3O73I5qS7aTaftIM5JMjFZ7cv8RtwV2LsTuk+kYGU6SqcCJiX6IyKH65RR8Sb0/1k1krHdt/yOY+LnGheJA=
X-Received: by 2002:a2e:b4b3:: with SMTP id q19mr2185724ljm.374.1622116309916;
 Thu, 27 May 2021 04:51:49 -0700 (PDT)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20210517193908.3113-1-sargun@sargun.me> <20210517193908.3113-3-sargun@sargun.me>
In-Reply-To: <20210517193908.3113-3-sargun@sargun.me>
From: Rodrigo Campos <rodrigo@kinvolk.io>
Date: Thu, 27 May 2021 13:51:13 +0200
Message-ID: <CACaBj2YUiowSKzvh02OjpQNqQViA8N0eyRMimkK=90NagRF40w@mail.gmail.com>
Subject: Re: [PATCH v2 2/4] seccomp: Refactor notification handler to prepare
 for new semantics
To: Sargun Dhillon <sargun@sargun.me>
Cc: Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>, 
	containers@lists.linux.dev, Tycho Andersen <tycho@tycho.pizza>, 
	Andy Lutomirski <luto@kernel.org>, =?UTF-8?Q?Mauricio_V=C3=A1squez_Bernal?= <mauricio@kinvolk.io>, 
	Giuseppe Scrivano <gscrivan@redhat.com>, Christian Brauner <christian.brauner@ubuntu.com>, 
	=?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@linux.microsoft.com>
Content-Type: text/plain; charset="UTF-8"

On Mon, May 17, 2021 at 9:39 PM Sargun Dhillon <sargun@sargun.me> wrote:
>
> This refactors the user notification code to have a do / while loop around
> the completion condition. This has a small change in semantic, in that
> previously we ignored addfd calls upon wakeup if the notification had been
> responded to, but instead with the new change we check for an outstanding
> addfd calls prior to returning to userspace.
>
> Rodrigo Campos also identified a bug that can result in addfd causing
> an early return, when the supervisor didn't actually handle the
> syscall [1].
>
> [1]: https://lore.kernel.org/lkml/20210413160151.3301-1-rodrigo@kinvolk.io/
>
> Fixes: 7cf97b125455 ("seccomp: Introduce addfd ioctl to seccomp user notifier")
> Signed-off-by: Sargun Dhillon <sargun@sargun.me>
> Acked-by: Tycho Andersen <tycho@tycho.pizza>

Kees, as I mentioned in the linked thread, this issue is present in
5.9+ kernels. Should we add the cc to stable for this patch? Or should
we cc to stable the one linked, that just fixes the issue without
semantic changes to userspace?

Just to be clear, the other patch that fixes the problem without
userspace visible changes is this:
https://lore.kernel.org/lkml/20210413160151.3301-1-rodrigo@kinvolk.io/


Best,
Rodrigo
