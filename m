Received: from mail-lf1-f47.google.com (mail-lf1-f47.google.com [209.85.167.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 45052177
	for <containers@lists.linux.dev>; Tue, 29 Jun 2021 03:47:31 +0000 (UTC)
Received: by mail-lf1-f47.google.com with SMTP id a11so36731401lfg.11
        for <containers@lists.linux.dev>; Mon, 28 Jun 2021 20:47:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=SAkvrvf9vGodn3/SdXI/Z/HezeeoY0M2aYPCWRA/0sw=;
        b=FmHwzUVnPSfz54gaaoFrV1I0m/OZYcDkto7MvfD87BMJlg2wfd6ksfLDQbgEpoWnMe
         GAzSOezqUJyyT5jjyC+szrJQMOrt+WSEMBY7k37vOZp5Td1xrgjvF0meno42vsEqDRBl
         FOMVPDRn63bn/bCTzLCUFsYJJWTGc/rswSo/w=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=SAkvrvf9vGodn3/SdXI/Z/HezeeoY0M2aYPCWRA/0sw=;
        b=h82xCLxoUij52p+ahHRcixCE5hnX12j+AH8pD8/7UwORYNz3mDf5NsA6mLVdmuwZaN
         9qzz36jHnOIt5PxL2oAGfi79DXQ6wJBOlmsmd9ddIoyTsxKbdtuEqNQNbBQJBDnLZnVK
         buPd5CPnGcAZTI4/9jKpl7cEhnraniDdWggkZM1EKd5wMhCL2oFpxhBTISZZ3IGXVl03
         LFKT+OTwm49oBefkCEt3C3dVEyeBSHX3yoQYg0SPAcCsU6XSI1TNPnn8YQ31DeQYQ9Dg
         bDlPrjlnOKO3yFxvU7/yHjVBoIHL35hhdCwKQMHLsj6PzZzHQk7CWRJg0OWYcaJDym4j
         xrvQ==
X-Gm-Message-State: AOAM530Ar+LW+v7j0gnTJdLRODI0vMNW0tP3PZd8v3ROVBSmC5Z0ee2P
	bVZ4bTC4n0Io9bSdJ+2yXXcrOmwT2BgDNsm5Q1k=
X-Google-Smtp-Source: ABdhPJwjQI8VSkM6r/Gxcu8WQeELtslR66uW7na+psdq4qA95PloIkchzMtmTkI0RQbe0O5msKLdKA==
X-Received: by 2002:a19:f505:: with SMTP id j5mr21977945lfb.126.1624938449279;
        Mon, 28 Jun 2021 20:47:29 -0700 (PDT)
Received: from mail-lj1-f181.google.com (mail-lj1-f181.google.com. [209.85.208.181])
        by smtp.gmail.com with ESMTPSA id x15sm1469829lfa.156.2021.06.28.20.47.29
        for <containers@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 28 Jun 2021 20:47:29 -0700 (PDT)
Received: by mail-lj1-f181.google.com with SMTP id k21so8259155ljh.2
        for <containers@lists.linux.dev>; Mon, 28 Jun 2021 20:47:29 -0700 (PDT)
X-Received: by 2002:a2e:b553:: with SMTP id a19mr2124829ljn.507.1624938447840;
 Mon, 28 Jun 2021 20:47:27 -0700 (PDT)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <87fsx1vcr9.fsf@disp2133>
In-Reply-To: <87fsx1vcr9.fsf@disp2133>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 28 Jun 2021 20:47:12 -0700
X-Gmail-Original-Message-ID: <CAHk-=wj1z-NKxedgZvSS37iH=EKE47PkL=+BYccAUtsuB1sySQ@mail.gmail.com>
Message-ID: <CAHk-=wj1z-NKxedgZvSS37iH=EKE47PkL=+BYccAUtsuB1sySQ@mail.gmail.com>
Subject: Re: [GIT PULL] ucounts: Count rlimits in each user namespace
To: "Eric W. Biederman" <ebiederm@xmission.com>, Alexey Gladkov <legion@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	Linux Containers <containers@lists.linux.dev>
Content-Type: text/plain; charset="UTF-8"

On Mon, Jun 28, 2021 at 3:35 PM Eric W. Biederman <ebiederm@xmission.com> wrote:
>
> This is the work mainly by Alexey Gladkov to limit rlimits to the
> rlimits of the user that created a user namespace, and to allow users to
> have stricter limits on the resources created within a user namespace.

I guess all the performance issues got sorted, since I haven't seen
any reports from the test robots.

I do end up with two questions, mainly because of looking at the
result of the conflict resolution.

In particular, in __sigqueue_alloc(), two oddities..

Why the "sigpending < LONG_MAX" test in that

        if (override_rlimit || (sigpending < LONG_MAX && sigpending <=
task_rlimit(t, RLIMIT_SIGPENDING))) {

thing?

And why test for "ucounts" being non-NULL in

                if (ucounts && dec_rlimit_ucounts(ucounts,
UCOUNT_RLIMIT_SIGPENDING, 1))
                        put_ucounts(ucounts);

when afaik both of those should be happy with a NULL 'ucounts' pointer
(if it was NULL, we certainly already used it for the reverse
operations for get_ucounts() and inc_rlimit_ucounts()..)

Hmm?

And somebody should verify that I didn't screw anything up in my merge
resolution. It all looked very straightforward, but mistakes happen..

                   Linus
