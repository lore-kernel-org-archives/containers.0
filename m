Received: from mail-ej1-f54.google.com (mail-ej1-f54.google.com [209.85.218.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D5EF62FB6
	for <containers@lists.linux.dev>; Wed,  1 Jun 2022 19:23:25 +0000 (UTC)
Received: by mail-ej1-f54.google.com with SMTP id q1so5728355ejz.9
        for <containers@lists.linux.dev>; Wed, 01 Jun 2022 12:23:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=XQjh59P+YL657/ugkQgJkelCDXFl1T1Vs2NaT8wJJmg=;
        b=ZZSpwU9hNx1vIgT23ZqORpMaSlb67mK71XYRdg7+sMMlwAstjUOjkA0TEXRoOiSjBx
         1jZ+YVX1Q02lET6yIsH0PSBUu0oWXEAM0SWXWzAqwObT9JFumL5b5q+9KN6/0sp3uyvB
         Pok3GJX3EYSYz40c743Gtv1qk9/v1YKTSe4Gk=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=XQjh59P+YL657/ugkQgJkelCDXFl1T1Vs2NaT8wJJmg=;
        b=fs82SzrAwj3bZ4kfYffrLKk/M2tu7pVx2CKQf5/YHiP0Yr0o839F+i1PjVuebQp6Za
         jGcUXtfKzZ0UzSEBlN/Witpmcj6TJMC8hc6r4x5XimSNakio+sW4O+jKeNGz4YHRQCwC
         7Az4F9rA4sW1Zp4oKnrbrS9C7E/5AExY0FdI0p0mM/FP3VCtUd6c0G6XpBCUg38b/6A4
         bLtlnlzfLqQiftLSiOW12WF7IVP1v1BS3XoNWGDur+O2xSw7tjnElGTEW8WOkbpSBdFn
         zr7ATOTmAZj0ymu0RNEJvut6604ceG2jyG/VeRe2BizJBPZS9+QuoGLCb+9ItLyirHgH
         WW+A==
X-Gm-Message-State: AOAM532Kg4AfCEaZ3NihMZL1cXPfK40VDTxkInieyhAKMvjagETU4Xh3
	0C13uycgfO6jh97X6ZCInL+D68QZJHuHjC9x
X-Google-Smtp-Source: ABdhPJw0rwpky1POcQaZaOV1qxMQIGqaIAcBvA5+6qUw00daIm32brAMct1ZU722YVp3DfxRbaOgGw==
X-Received: by 2002:a17:907:1c8c:b0:6ff:144d:e7da with SMTP id nb12-20020a1709071c8c00b006ff144de7damr956661ejc.542.1654111403892;
        Wed, 01 Jun 2022 12:23:23 -0700 (PDT)
Received: from mail-wr1-f47.google.com (mail-wr1-f47.google.com. [209.85.221.47])
        by smtp.gmail.com with ESMTPSA id ly2-20020a170906af4200b006feec47dae9sm991833ejb.157.2022.06.01.12.23.23
        for <containers@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 01 Jun 2022 12:23:23 -0700 (PDT)
Received: by mail-wr1-f47.google.com with SMTP id k19so3646924wrd.8
        for <containers@lists.linux.dev>; Wed, 01 Jun 2022 12:23:23 -0700 (PDT)
X-Received: by 2002:a05:6000:1605:b0:210:307a:a94a with SMTP id
 u5-20020a056000160500b00210307aa94amr744700wrb.97.1654111402828; Wed, 01 Jun
 2022 12:23:22 -0700 (PDT)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <CAHk-=whi2SzU4XT_FsdTCAuK2qtYmH+-hwi1cbSdG8zu0KXL=g@mail.gmail.com>
 <cover.1654086665.git.legion@kernel.org> <5ec6759ab3b617f9c12449a9606b6f0b5a7582d0.1654086665.git.legion@kernel.org>
 <Ype7skNJzEQ1W96v@casper.infradead.org>
In-Reply-To: <Ype7skNJzEQ1W96v@casper.infradead.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 1 Jun 2022 12:23:06 -0700
X-Gmail-Original-Message-ID: <CAHk-=wiTtYMia0FR4h7_nV2RZ5pq=wR-7oMMK3o8o=EgAxMsmg@mail.gmail.com>
Message-ID: <CAHk-=wiTtYMia0FR4h7_nV2RZ5pq=wR-7oMMK3o8o=EgAxMsmg@mail.gmail.com>
Subject: Re: [RFC PATCH 1/4] sysctl: API extension for handling sysctl
To: Matthew Wilcox <willy@infradead.org>
Cc: Alexey Gladkov <legion@kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	"Eric W . Biederman" <ebiederm@xmission.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Christian Brauner <brauner@kernel.org>, Iurii Zaikin <yzaikin@google.com>, 
	Kees Cook <keescook@chromium.org>, Linux Containers <containers@lists.linux.dev>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, Luis Chamberlain <mcgrof@kernel.org>, 
	Vasily Averin <vvs@virtuozzo.com>
Content-Type: text/plain; charset="UTF-8"

On Wed, Jun 1, 2022 at 12:19 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> Why not pass the iocb in ->read and ->write?  We're still regretting not
> doing that with file_operations.

No, all the actual "io" is done by the caller.

There is no way in hell I want the sysctl callbacks to actually
possibly do user space accesses etc.

They get a kernel buffer that has already been set up. There is no
iocb or iovec left for them.

(That also means that they can take whatever locks they need,
including spinlocks, because there's not going to be any random user
accesses or complex pipe buffer lookups or whatever).

                Linus
