Received: from mail-ed1-f54.google.com (mail-ed1-f54.google.com [209.85.208.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 41B523205
	for <containers@lists.linux.dev>; Wed,  1 Jun 2022 19:32:18 +0000 (UTC)
Received: by mail-ed1-f54.google.com with SMTP id z7so3513328edm.13
        for <containers@lists.linux.dev>; Wed, 01 Jun 2022 12:32:18 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=e5mcrmCWuAAdbPHfrDc3j0Y3Y9fXO5pJ7wBIk1OP74A=;
        b=X7Tv7jSyurwqAxOftMCv8MB8L2erC6H7qza7nZau5SMv9NuJDXz++xqv2TCO8O1eNZ
         fqueWV6byN8z2Gu+uMcXfpESO4zCepIeF9lE38C7p3G9ruL4ZOJc2FAVWNdk/Nm5vop/
         sQfYhypjYychJXBmewMMJChgZZn1Gv4yaRaNo=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=e5mcrmCWuAAdbPHfrDc3j0Y3Y9fXO5pJ7wBIk1OP74A=;
        b=tart5OS/OMH2dEN6Y6rK083qqupaJJog3rpw1m5IfFJpukJ8jtPj69WWoelrXzwxUh
         2sI2UN35ownfnPEw0J5m5ZC/FQXDJHFaujQ+yUqQ4XutMiysH2JLCj26zUmCLM+EsAAs
         pdFhEmbyYgAXbAoNFoa3RHZPZJi6MrjF6aK8fF00Oi78IE1U7RWHhzTfcSTc3d1J17uy
         Y4vW6KYtTET40TcZCODyPliwMvDPsBerki3dm07SsrcDew58VSbVh4eVBRaf4vFKttHE
         a/Z/LtYL7GeF9jD7bj3UnSd3M87lMirwC3noBfxyjeLpINQnViPFWNr25n8TMvqzxEcV
         /vfA==
X-Gm-Message-State: AOAM531hMVNuhgdKNfXE+v55bDURJHXOVowMdj839DChsvertqfMEt4C
	lTWMEDSdqY8TC6JPQQxQzYCd+//5IlE9QMJE
X-Google-Smtp-Source: ABdhPJwUCALRWL4CXgMnbRA09AvsbbEOgTllaleZwLFyTb2EouU4+x3zHO4q9qPnhKT2/yFZh6Nkfg==
X-Received: by 2002:a05:6402:3291:b0:42d:dd03:cbb1 with SMTP id f17-20020a056402329100b0042ddd03cbb1mr1429013eda.268.1654111936243;
        Wed, 01 Jun 2022 12:32:16 -0700 (PDT)
Received: from mail-wm1-f53.google.com (mail-wm1-f53.google.com. [209.85.128.53])
        by smtp.gmail.com with ESMTPSA id si28-20020a170906cedc00b006f3ef214e0csm1032413ejb.114.2022.06.01.12.32.14
        for <containers@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 01 Jun 2022 12:32:14 -0700 (PDT)
Received: by mail-wm1-f53.google.com with SMTP id y24so1499268wmq.5
        for <containers@lists.linux.dev>; Wed, 01 Jun 2022 12:32:14 -0700 (PDT)
X-Received: by 2002:a1c:7207:0:b0:397:66ee:9d71 with SMTP id
 n7-20020a1c7207000000b0039766ee9d71mr872637wmc.8.1654111934219; Wed, 01 Jun
 2022 12:32:14 -0700 (PDT)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <CAHk-=whi2SzU4XT_FsdTCAuK2qtYmH+-hwi1cbSdG8zu0KXL=g@mail.gmail.com>
 <cover.1654086665.git.legion@kernel.org> <5ec6759ab3b617f9c12449a9606b6f0b5a7582d0.1654086665.git.legion@kernel.org>
 <Ype7skNJzEQ1W96v@casper.infradead.org> <CAHk-=wiTtYMia0FR4h7_nV2RZ5pq=wR-7oMMK3o8o=EgAxMsmg@mail.gmail.com>
 <Ype9ILKm+8WLOq9W@casper.infradead.org>
In-Reply-To: <Ype9ILKm+8WLOq9W@casper.infradead.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 1 Jun 2022 12:31:58 -0700
X-Gmail-Original-Message-ID: <CAHk-=whqoV60WtDM2V=Abx5U33yqx6wVqvPg0V5NyizsKtoG_w@mail.gmail.com>
Message-ID: <CAHk-=whqoV60WtDM2V=Abx5U33yqx6wVqvPg0V5NyizsKtoG_w@mail.gmail.com>
Subject: Re: [RFC PATCH 1/4] sysctl: API extension for handling sysctl
To: Matthew Wilcox <willy@infradead.org>
Cc: Alexey Gladkov <legion@kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	"Eric W . Biederman" <ebiederm@xmission.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Christian Brauner <brauner@kernel.org>, Iurii Zaikin <yzaikin@google.com>, 
	Kees Cook <keescook@chromium.org>, Linux Containers <containers@lists.linux.dev>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, Luis Chamberlain <mcgrof@kernel.org>, 
	Vasily Averin <vvs@virtuozzo.com>
Content-Type: text/plain; charset="UTF-8"

On Wed, Jun 1, 2022 at 12:25 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> I wasn't suggesting the iovec.  Just the iocb, instead of passing in the
> ki_filp and the ki_pos.

I guess that would work, but would it actually help anything?

I think it's a lot more obvious when it just looks mostly like a
"read/write()" system call (ok, pread/pwrite since you get the pos,
but still).

There is nothing that could possibly be relevant in the kiocb. All
those fields are about odd async or atomicity issues (or "report
completion" issues) that simply cannot possibly be valid for a sysctl
value.

And if they are, that sysctl value is doing something really really
really wrong. So we absolutely don't want to encourage that.

This is not a "do IO" interface. This is a "read or write value" interface.

               Linus
