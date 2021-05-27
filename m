Received: from mail-lf1-f48.google.com (mail-lf1-f48.google.com [209.85.167.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7ABBE2FAD
	for <containers@lists.linux.dev>; Thu, 27 May 2021 12:46:04 +0000 (UTC)
Received: by mail-lf1-f48.google.com with SMTP id j10so7769364lfb.12
        for <containers@lists.linux.dev>; Thu, 27 May 2021 05:46:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=kinvolk.io; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=xKdx9IwmtQ3kQh5FjyyZXmziMdiD6yFvHaxu3WVJTOU=;
        b=OCe1eTqhpk/j7vzfd9aZlzKirJb7I1JLrY8ImH2WvZOFGH/v+S2AIXlxk7bvDgd0ao
         oajmplfKMedpZYai9AbVD5BLCrbjBhZt/eQwq0Z8t3TePGPstfVOnYDUu1WQSBj6RWGM
         kffUdBjLLyeAT05Me+FA+NmQ26vyGFj9HKruo=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=xKdx9IwmtQ3kQh5FjyyZXmziMdiD6yFvHaxu3WVJTOU=;
        b=BvbvtTgKYz2kaE03Jq2RdtGNm3GAZbAFWkUiiD1nFb3YIhLSUTeVnbgJk0K+6a3LEK
         e42fA5F0qa3Tl1zkWwyrrOU7FgIOqT59aNkP/FZUmh3fGk121BJWUsd020Y51ptYhIYa
         ZfNOE8aQsueI0Qk4JtgVtZYsCYh06gtKX2KOLHpt482xEiwDtS7auQOKpLg0nFDCDdfP
         Dk3LUp7Y8SlrcC+a+2QOVeTJmi7PQib3SG/bvCCIMI6jeRaSGQ+iBYxbqnmzugTpVpbV
         4VQbgfKkV/5W11jk9WiRwR3FNWsZnT4L27NMPgkoC8ZMUsYPxliQ99j3xYVUp8KuS2Qy
         YOCg==
X-Gm-Message-State: AOAM530liPwESrxxwfzHVT7URAiJFPeA7dzKc30iG+DEyDNombppW1nD
	yF++egjeF9X3wCUJ6Vccx/GgfgCarwio7Z+qUZwaByZXBq2gNFMUBOI=
X-Google-Smtp-Source: ABdhPJy3whwMlWSGTmxRoY7Lh7GgFnV18098vFJxqUb7bVjCMYzFe8X5soQ1YfTDLIAGoFcF1uSdjdekAVFbhBUEVGM=
X-Received: by 2002:a05:6512:128c:: with SMTP id u12mr2265660lfs.160.1622119562570;
 Thu, 27 May 2021 05:46:02 -0700 (PDT)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20210527032948.3730953-1-keescook@chromium.org>
In-Reply-To: <20210527032948.3730953-1-keescook@chromium.org>
From: Rodrigo Campos <rodrigo@kinvolk.io>
Date: Thu, 27 May 2021 14:45:26 +0200
Message-ID: <CACaBj2atO=2aAyK+BO5MPS0B3CQNwc98CSHiuy8X2wvkdvJNDQ@mail.gmail.com>
Subject: Re: [PATCH] selftests/seccomp: More closely track fds being assigned
To: Kees Cook <keescook@chromium.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Sargun Dhillon <sargun@sargun.me>, 
	containers@lists.linux.dev, Tycho Andersen <tycho@tycho.pizza>, 
	=?UTF-8?Q?Mauricio_V=C3=A1squez_Bernal?= <mauricio@kinvolk.io>, 
	Giuseppe Scrivano <gscrivan@redhat.com>, Christian Brauner <christian.brauner@ubuntu.com>, 
	=?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@linux.microsoft.com>, 
	Andy Lutomirski <luto@amacapital.net>, Will Drewry <wad@chromium.org>
Content-Type: text/plain; charset="UTF-8"

On Thu, May 27, 2021 at 5:29 AM Kees Cook <keescook@chromium.org> wrote:
>
> Since the open fds might not always start at "4" (especially when
> running under kselftest, etc), start counting from the first assigned
> fd, rather than using the more permissive EXPECT_GE(fd, 0).
>
> Signed-off-by: Kees Cook <keescook@chromium.org>

Nice cleanup, thanks! Just in case, tested it here, works fine. Feel
free to add:

Reviewed-by: Rodrigo Campos <rodrigo@kinvolk.io>

I can improve the selftest to test the new addfd flag we just added
also in combination existing flags (like setting the fd number to
use), and maybe also split the big chunk test, if you think that is
valuable.

Best,
Rodrigo
