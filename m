Received: from mail-ej1-f48.google.com (mail-ej1-f48.google.com [209.85.218.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F235E2F2B
	for <containers@lists.linux.dev>; Wed,  1 Jun 2022 18:34:40 +0000 (UTC)
Received: by mail-ej1-f48.google.com with SMTP id f21so5478054ejh.11
        for <containers@lists.linux.dev>; Wed, 01 Jun 2022 11:34:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=njosF9y/4mY7h7cHbBRt7eN+aSzBOOky31pVud25XUc=;
        b=NPllnz8RYVxm2SnTV64EXzDNNfLuN5S4zdx4+p5tMDUvBFc2HBR70PHsb0+FhzIYOe
         5QBBj11OZ9MvXzN4JDhTfmL34kBXkF5cWwnTwj9QJCpAIQjmWFGOR+tY8hUC7FXp3TPu
         gpZSXodqw0bfpX1vHBHuU/zTaxExUhW5Sii8s=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=njosF9y/4mY7h7cHbBRt7eN+aSzBOOky31pVud25XUc=;
        b=cyLmqOyrIPx4iQtCmwUlawO3V9B6pEZLzhqN1bQK6q1ioGEb2cp1ZEcEivpkI88djK
         BHWxMBilu/EgLAtW3cCpbSZwOYQz4p+3TW2+k36UMZzllJEQjazoRCMdhbqmIM8G7NzG
         OS8VGgfezXfjl0RcnbxisOYsWkDqleLO/vnwTmi3ggrzenNgUn6guZnVGidx3MA7bIZm
         izmtlH+X6pdevKLmRsfKqzxMY3EFb8My4dnggl/mz4v6u4ppzKcmiONI5Xh1+6fQsPpE
         dOdcNhOIPEcefeydawuGSEgjupY0A5pOqzIKoKH7lNqOWwGpMFlWxGkyzWZCbkKR+5WO
         LUlg==
X-Gm-Message-State: AOAM532vefWPb+G10J8XuPtEEMcvxpTgXT0EOcp4VsJE1JctgAkA+SDr
	fK2h/BvmpWBBeGVK6BnloGt3NzSthvEyr6z6
X-Google-Smtp-Source: ABdhPJxsCsTCeVbrqKFu9UIdnOa2uauECwdYBXbB8MKsvzAFiWmsLGj7039ms48aOdFESPP9M0r4SQ==
X-Received: by 2002:a17:907:7207:b0:6ff:d25:ee3f with SMTP id dr7-20020a170907720700b006ff0d25ee3fmr790388ejc.389.1654108478947;
        Wed, 01 Jun 2022 11:34:38 -0700 (PDT)
Received: from mail-wm1-f41.google.com (mail-wm1-f41.google.com. [209.85.128.41])
        by smtp.gmail.com with ESMTPSA id f22-20020a1709067f9600b006f3ef214db6sm981429ejr.28.2022.06.01.11.34.36
        for <containers@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 01 Jun 2022 11:34:37 -0700 (PDT)
Received: by mail-wm1-f41.google.com with SMTP id o29-20020a05600c511d00b00397697f172dso2873572wms.0
        for <containers@lists.linux.dev>; Wed, 01 Jun 2022 11:34:36 -0700 (PDT)
X-Received: by 2002:a1c:7207:0:b0:397:66ee:9d71 with SMTP id
 n7-20020a1c7207000000b0039766ee9d71mr692055wmc.8.1654108476150; Wed, 01 Jun
 2022 11:34:36 -0700 (PDT)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <CAHk-=whi2SzU4XT_FsdTCAuK2qtYmH+-hwi1cbSdG8zu0KXL=g@mail.gmail.com>
 <cover.1654086665.git.legion@kernel.org> <857cb160a981b5719d8ed6a3e5e7c456915c64fa.1654086665.git.legion@kernel.org>
 <CAHk-=wjJ2CP0ugbOnwAd-=Cw0i-q_xC1PbJ-_1jrvR-aisiAAA@mail.gmail.com> <Ypeu97GDg6mNiKQ8@example.org>
In-Reply-To: <Ypeu97GDg6mNiKQ8@example.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 1 Jun 2022 11:34:18 -0700
X-Gmail-Original-Message-ID: <CAHk-=wgBeQafNgw6DNUwM4vvw4snb83Tb65m_QH9XSic2JSJaQ@mail.gmail.com>
Message-ID: <CAHk-=wgBeQafNgw6DNUwM4vvw4snb83Tb65m_QH9XSic2JSJaQ@mail.gmail.com>
Subject: Re: [RFC PATCH 2/4] sysctl: ipc: Do not use dynamic memory
To: Alexey Gladkov <legion@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, 
	"Eric W . Biederman" <ebiederm@xmission.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Christian Brauner <brauner@kernel.org>, Iurii Zaikin <yzaikin@google.com>, 
	Kees Cook <keescook@chromium.org>, Linux Containers <containers@lists.linux.dev>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, Luis Chamberlain <mcgrof@kernel.org>, 
	Vasily Averin <vvs@virtuozzo.com>
Content-Type: text/plain; charset="UTF-8"

On Wed, Jun 1, 2022 at 11:25 AM Alexey Gladkov <legion@kernel.org> wrote:
>
> I'm not sure how to get rid of ctl_table since net sysctls are heavily
> dependent on it.

I don't actually think it's worth getting rid of entirely, because
there's just a lot of simple cases where it "JustWorks(tm)" and having
just that table entry describe all the semantics is not wrong at all.

The name may suck, but hey, it's not a big deal. Changing it now would
be more pain than it's worth.

No, I was more thinking that things that already need more
infrastructure than that simple static ctl_table entry might be better
off trying to migrate to your new "proper read op" model, and having
more of that dynamic behavior in the read op.

The whole "create dynamic ctl_table entries on the fly" model works,
but it's kind of ugly.

Anyway, I think all of this is "I think there is more room for cleanup
in this area", and maybe we'll never have enough motivation to
actually do that.

Your patches seem to fix the extant issue with the ipc namespace, and
the truly disgusting parts (although maybe there are other truly
disgusting things hiding - I didn't go look for them).

                      Linus
