Received: from mail-lj1-f182.google.com (mail-lj1-f182.google.com [209.85.208.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BC7C717F
	for <containers@lists.linux.dev>; Tue, 25 May 2021 16:04:15 +0000 (UTC)
Received: by mail-lj1-f182.google.com with SMTP id p20so38847691ljj.8
        for <containers@lists.linux.dev>; Tue, 25 May 2021 09:04:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=kinvolk.io; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=etyw4lsngOCwaxz3lAVhGn8wpFc4o+0N4m07CszuHys=;
        b=WSWDsTyvfIO3jcXBz7rf/aCap0pJvuYkQeFaAHhGi82/yhI/JbGAzmvpxl7wQTCLxP
         kgCDVKtmyO+cBPm1tNHwAeizaDn/ZxYcVHJjmZLTMKdzwSHCzKrbdRrjDjj8hosTkMaT
         mncIr1itc7WzFkx59meZztEqeeSHvi6YzLHBk=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=etyw4lsngOCwaxz3lAVhGn8wpFc4o+0N4m07CszuHys=;
        b=KBsF9s9NVpYEzEtVmWBppUgQGT3rDJDJ57J2aFx1T709B/CIb316HxmqDVu09zE0uu
         mtIYNbgpKg+7crdX9jLedE0CCD8pDPqNGKfCcHYkXd1Hfiu2+C2oipnR1QOqo0kn60Pn
         pbUzeNCIUWQJvRNBCnQlgTQfj8KszBxy+xYrJ8po+np/SiJXPHMKHQ5mOKXjjtbr1H1J
         J6sSBvCXDuJ+239AZVA+KNehoz/npBc6DzJB8QF4uo+dAk46XnjwnVXfETj5yebZCvDI
         yISQ5bBmP1ZFVR90jj6oH/kh5cDe6DK9BfoLheXxJvoeRbkkk/QqX/1dtHV/AvHTeJze
         qsjg==
X-Gm-Message-State: AOAM532JnY9O4FS1eFSCIORKLg5BmGnrVmtmRZix8PzBMnTPStJ6x6dF
	YSN8VeA0sX3Q/wBd3/1AGEO1XAfQaLCVV0SsAGyrlA==
X-Google-Smtp-Source: ABdhPJzpdi9hkHuHgScJG60EVMPuQ6xED6Vl0PloPs9dBGePF9s1iU2bjO0YKLNK+BMtS8rcsUxshhuvWcJjQui+GQ8=
X-Received: by 2002:a2e:908e:: with SMTP id l14mr21340214ljg.372.1621958653833;
 Tue, 25 May 2021 09:04:13 -0700 (PDT)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20210517193908.3113-1-sargun@sargun.me> <20210517193908.3113-3-sargun@sargun.me>
In-Reply-To: <20210517193908.3113-3-sargun@sargun.me>
From: Rodrigo Campos <rodrigo@kinvolk.io>
Date: Tue, 25 May 2021 18:03:38 +0200
Message-ID: <CACaBj2Y5YsrbFCw1m9U=8S8uJFiPo_c4riitDE5z-re65a-x9g@mail.gmail.com>
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

I understand why this was a readability improvement on the old
patchset (that included the wait_killable semantics), as it completely
changed the loop. But now we only have the atomic addfd+send reply
that does minimal changes to this part (add a param to a function).

Is it worth changing the semantics?

> Rodrigo Campos also identified a bug that can result in addfd causing
> an early return, when the supervisor didn't actually handle the
> syscall [1].
>
> [1]: https://lore.kernel.org/lkml/20210413160151.3301-1-rodrigo@kinvolk.io/

I was about to resend this, but I'd like to know what others think.

I'm okay with applying any patches to solve the issue (mine linked
there or this one), slightly in favor of mine as the diff is way
simpler to backport (applies to 5.9+ kernels) and I don't see a reason
to change semantics. But no strong opinion.

Opinions?


Best,
Rodrigo
