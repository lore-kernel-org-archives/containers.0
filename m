Received: from mail-ed1-f42.google.com (mail-ed1-f42.google.com [209.85.208.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 84E0F3D65
	for <containers@lists.linux.dev>; Fri,  3 Jun 2022 22:59:53 +0000 (UTC)
Received: by mail-ed1-f42.google.com with SMTP id n28so11941904edb.9
        for <containers@lists.linux.dev>; Fri, 03 Jun 2022 15:59:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=9z4AdzgDWuQPwQgbpxeMmLcgt6+lYKFImpeM73S4cMM=;
        b=LHWjMTkCf7hqgYzvwOgDh7lbnpwJTOkPjkJZFLGY79Q5G92YiPn3piJIjTkey6jBm/
         klS4oZwkf0LRsgqEbR5XKsuTY8FBPE8ZJBWDuz1fOYqVLoJ9EZoV/fD8K//Ux92GKhae
         cERo55lHkG0T00YQ1S4cA2U3ao7/6JYX2AKQg=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=9z4AdzgDWuQPwQgbpxeMmLcgt6+lYKFImpeM73S4cMM=;
        b=uJrxDOjdzfofOqui1mwYNzmeqMQVSRi3jBPS85eC8EJKGI5f7QKiNc3LJ4BfJWdhMH
         tJ5TtorKV6bU76pz/TQUNGQwgTGor1biXp8tAbUtzRkNYdf9Vcn3LIOC61VpXi1mcChT
         ihYJrz0BqG7XM+bx/fbpc7P+a9L2cLXtYP3v8bTCrCulFeImbdtSFLi2Gc5CsnWr//n9
         ULpl0Hxjxh0C9+p3KoHfpWKuStErR3Y9O0y+/xhXklQohY+xfb+GqPrp3L66R7iTA2lq
         8B/h8ILzYsZTWprhJ7/iHl5PUzeD2oX8x3VlkSUZucDnfZAshjaAQcUTTfYc6aquuvNq
         QBdg==
X-Gm-Message-State: AOAM530t02sQWDGhC7NgB4UIzuyqrwLc77t2I4O/VfJey1N2nwa/Szlt
	BQtjf0NA/bKmS/2nG5Rs3lQNjxK7ErmhBJbx
X-Google-Smtp-Source: ABdhPJxwqXQsVsGprCH+cOovPtKvNP1r5+66kktvEaDlNNyHoRQqlqXIIhvFLODPaGOZmiLXTnazOg==
X-Received: by 2002:aa7:d4c6:0:b0:42e:561:8c70 with SMTP id t6-20020aa7d4c6000000b0042e05618c70mr13090669edr.131.1654297191515;
        Fri, 03 Jun 2022 15:59:51 -0700 (PDT)
Received: from mail-wr1-f48.google.com (mail-wr1-f48.google.com. [209.85.221.48])
        by smtp.gmail.com with ESMTPSA id g1-20020a170906348100b00702d8b37a03sm3391685ejb.17.2022.06.03.15.59.49
        for <containers@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 03 Jun 2022 15:59:50 -0700 (PDT)
Received: by mail-wr1-f48.google.com with SMTP id k16so12102510wrg.7
        for <containers@lists.linux.dev>; Fri, 03 Jun 2022 15:59:49 -0700 (PDT)
X-Received: by 2002:a05:6000:16c4:b0:20f:cd5d:4797 with SMTP id
 h4-20020a05600016c400b0020fcd5d4797mr10192231wrf.193.1654297189459; Fri, 03
 Jun 2022 15:59:49 -0700 (PDT)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <875ylh8xxx.fsf@email.froward.int.ebiederm.org>
In-Reply-To: <875ylh8xxx.fsf@email.froward.int.ebiederm.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 3 Jun 2022 15:59:33 -0700
X-Gmail-Original-Message-ID: <CAHk-=wh0ZYiQuCJmohyYpk99mch=Nb+_m4DWxBX03DQWnsvCZA@mail.gmail.com>
Message-ID: <CAHk-=wh0ZYiQuCJmohyYpk99mch=Nb+_m4DWxBX03DQWnsvCZA@mail.gmail.com>
Subject: Re: [GIT PULL] ipc: per namespace ipc sysctl changes for v5.19
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Alexey Gladkov <legion@kernel.org>, 
	Linux Containers <containers@lists.linux.dev>
Content-Type: text/plain; charset="UTF-8"

On Fri, Jun 3, 2022 at 10:21 AM Eric W. Biederman <ebiederm@xmission.com> wrote:
>
> These changes were sent for v5.18[1] but were dropped because some
> additional cleanups were requested.  Linus has given his nod[2] to the
> cleanups so I hope enough cleanups are present this time.

Well, I'll be happier still when the next set of cleanups hits:

   https://lore.kernel.org/all/CAHk-=wjJ2CP0ugbOnwAd-=Cw0i-q_xC1PbJ-_1jrvR-aisiAAA@mail.gmail.com/

but yeah, that further cleanup series clearly wasn't quite ready yet.

              Linus
