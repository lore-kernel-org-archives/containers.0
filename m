Received: from mail-il1-f170.google.com (mail-il1-f170.google.com [209.85.166.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 518312F80
	for <containers@lists.linux.dev>; Tue, 25 May 2021 20:44:50 +0000 (UTC)
Received: by mail-il1-f170.google.com with SMTP id m1so27695964ilg.10
        for <containers@lists.linux.dev>; Tue, 25 May 2021 13:44:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=sargun.me; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=dx8YUAQzEnba5PQjYOv49O+Z4yv1QCI8CcdX+kElxFE=;
        b=ds+BZ8WNemLxCRt3hQjDdq00sXt+FZBkfFjPJymgA8OxfQGvoYltlsJs2OuLw9T8CH
         +h96s3THTlhOj6n2IpEF6PFazNr9/Q3OApCcYNX27r9840LIf70pWlZd2RcyB8q0gSr7
         jAZXKrlwZLfd7lQWgROH4hKw/K1/64E1E61AA=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=dx8YUAQzEnba5PQjYOv49O+Z4yv1QCI8CcdX+kElxFE=;
        b=qhxw+Z/XOhnyfJJl/9oYCnNysTAx15bI0xEsDlarQDdwsudznNODXxQib0N0+YvWZi
         RsTBckG/SMCTNDzDrhKVNe1Tyf+Y1V6XDvTibF9EzE96nG2bpsi4YsRoD6wtilyOvWIH
         klGLsOi6yI11F8Tswfp1JEPN/QAxlRGKaGdcFJ29kqlbcOIQFpMtGYejUGjS8OPwFzRx
         1Qm0RtTE2wzdQKNEkbPKDX6t7e3+ZQK25vt8LC+57kqOLI7B/onbWKxyC6GZYeK+D1qT
         EslT8sCaV+yaWynpSo0oLbC9fVfthIS6Nu/8yzJMGTiKXXWnd9uDt6EgGewfctxHUOBz
         zvyg==
X-Gm-Message-State: AOAM530QiyCpbCy5NT/JYHO9nJKpntPidB7F7uQxgSdqgYI/p4Yk1tL8
	pbPJt9nnAghbbyUAt8eoijdQcBmguwKZECvgEidTPg==
X-Google-Smtp-Source: ABdhPJwOVPdbQ5AimxrE2Fag8ZO6aMG1+Yk/QbKoodRm5vnbn68V97yu0dpyxidaRAv8jDcSxoHgtZrAZroAYA1M9R0=
X-Received: by 2002:a92:db07:: with SMTP id b7mr21621412iln.282.1621975489294;
 Tue, 25 May 2021 13:44:49 -0700 (PDT)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20210517193908.3113-1-sargun@sargun.me> <20210517193908.3113-3-sargun@sargun.me>
 <CACaBj2Y5YsrbFCw1m9U=8S8uJFiPo_c4riitDE5z-re65a-x9g@mail.gmail.com>
In-Reply-To: <CACaBj2Y5YsrbFCw1m9U=8S8uJFiPo_c4riitDE5z-re65a-x9g@mail.gmail.com>
From: Sargun Dhillon <sargun@sargun.me>
Date: Tue, 25 May 2021 13:44:13 -0700
Message-ID: <CAMp4zn-CFaPpVd3zcANfmUQXaLCUPnuT2SrC_Kw5RrF4_Ubuhw@mail.gmail.com>
Subject: Re: [PATCH v2 2/4] seccomp: Refactor notification handler to prepare
 for new semantics
To: Rodrigo Campos <rodrigo@kinvolk.io>
Cc: Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>, 
	Linux Containers <containers@lists.linux.dev>, Tycho Andersen <tycho@tycho.pizza>, 
	Andy Lutomirski <luto@kernel.org>, =?UTF-8?Q?Mauricio_V=C3=A1squez_Bernal?= <mauricio@kinvolk.io>, 
	Giuseppe Scrivano <gscrivan@redhat.com>, Christian Brauner <christian.brauner@ubuntu.com>, 
	=?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@linux.microsoft.com>
Content-Type: text/plain; charset="UTF-8"

On Tue, May 25, 2021 at 9:04 AM Rodrigo Campos <rodrigo@kinvolk.io> wrote:
>
> On Mon, May 17, 2021 at 9:39 PM Sargun Dhillon <sargun@sargun.me> wrote:
> >
> > This refactors the user notification code to have a do / while loop around
> > the completion condition. This has a small change in semantic, in that
> > previously we ignored addfd calls upon wakeup if the notification had been
> > responded to, but instead with the new change we check for an outstanding
> > addfd calls prior to returning to userspace.
>
> I understand why this was a readability improvement on the old
> patchset (that included the wait_killable semantics), as it completely
> changed the loop. But now we only have the atomic addfd+send reply
> that does minimal changes to this part (add a param to a function).
>
> Is it worth changing the semantics?
>
I think that as we add more complexity around different things that
can cause the notification to change (status), that this is better,
but I understand wanting to hold off.

> > Rodrigo Campos also identified a bug that can result in addfd causing
> > an early return, when the supervisor didn't actually handle the
> > syscall [1].
> >
> > [1]: https://lore.kernel.org/lkml/20210413160151.3301-1-rodrigo@kinvolk.io/
>
> I was about to resend this, but I'd like to know what others think.
>
> I'm okay with applying any patches to solve the issue (mine linked
> there or this one), slightly in favor of mine as the diff is way
> simpler to backport (applies to 5.9+ kernels) and I don't see a reason
> to change semantics. But no strong opinion.
>
> Opinions?
>
>
> Best,
> Rodrigo
