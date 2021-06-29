Received: from mail-lj1-f170.google.com (mail-lj1-f170.google.com [209.85.208.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 87CAC168
	for <containers@lists.linux.dev>; Tue, 29 Jun 2021 20:33:58 +0000 (UTC)
Received: by mail-lj1-f170.google.com with SMTP id w11so12182175ljh.0
        for <containers@lists.linux.dev>; Tue, 29 Jun 2021 13:33:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=fhJdI23bnQTsJQkSv7/yJhByjF9cS8kb5VpeCaNIpgY=;
        b=EPJAHNutQ9iqxU3YC3gGirOdY6LcOSsoptGbcsa3ezTIi/byqkNjxmeo7mQf9v7aml
         gFoXNIXI4TVJUQnPhtOPQEiBWEyU4c0yEbh0cO7fouErX6C0a7lJ+uzQJhA54Er7WR/R
         NVf94tbIri27NQIuLHPMB7ppxiMo5jePufcuk=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=fhJdI23bnQTsJQkSv7/yJhByjF9cS8kb5VpeCaNIpgY=;
        b=N6+LE/C3/elxDF+k4cAcX1ucLUxvcMPBe8pgxImFa8E/zPx7ujARHVdHKVfjLBguzm
         OcvlsvSYMYVoeU7NbjOiut07T/BUsN6I0y/Cc3ehAZRaDPLtlQ9joemEJPBYh3H94kU4
         MNgGzrod7cm44y86nChhINgq9uTs0p1e8FkeNzda5NhF4F6ddE1Irmb4iKQsKjggp0vg
         vB4A8jo676NJtRzNt1mjYOY2UuibhJ1Ups/aupUAEUp1p1DCyqeaGIeDyQ5ARSW0+gxP
         ZfRIq0goy14HxxvSNW9unyBu7RB2U4vL75oh9S1WfeBqZGLJxzU/ia7m3uMUKKc/xthA
         CJXg==
X-Gm-Message-State: AOAM533qS3UsTdec4xjyCf+layY8XB7wBv06L8zwl2AwKCRaEC0WxYCJ
	6Vn4z/m4nwqhXWiiSiZoWamQ0TF/DI411GkkSxE=
X-Google-Smtp-Source: ABdhPJzGWicbqE+6kANWwqQqYQYDuXErLe9nreIxng6pF2Kw5rHWI7dTzzShTfWOmH82cLwdZrf3FA==
X-Received: by 2002:a2e:92cd:: with SMTP id k13mr5185322ljh.282.1624998836410;
        Tue, 29 Jun 2021 13:33:56 -0700 (PDT)
Received: from mail-lf1-f51.google.com (mail-lf1-f51.google.com. [209.85.167.51])
        by smtp.gmail.com with ESMTPSA id w12sm1724148lfl.229.2021.06.29.13.33.55
        for <containers@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 29 Jun 2021 13:33:55 -0700 (PDT)
Received: by mail-lf1-f51.google.com with SMTP id w19so641772lfk.5
        for <containers@lists.linux.dev>; Tue, 29 Jun 2021 13:33:55 -0700 (PDT)
X-Received: by 2002:ac2:42d6:: with SMTP id n22mr24286252lfl.41.1624998835628;
 Tue, 29 Jun 2021 13:33:55 -0700 (PDT)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <87fsx1vcr9.fsf@disp2133> <CAHk-=wj1z-NKxedgZvSS37iH=EKE47PkL=+BYccAUtsuB1sySQ@mail.gmail.com>
 <20210629171757.shyr222zjpm6ev5t@example.org> <CAHk-=wgcpK3XdFKJ98b_YucXbQMJMgJssAk=sQ-XUo-tyiMjVg@mail.gmail.com>
 <20210629202028.gduluywejae75icj@example.org>
In-Reply-To: <20210629202028.gduluywejae75icj@example.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 29 Jun 2021 13:33:39 -0700
X-Gmail-Original-Message-ID: <CAHk-=wjQks3o_3=WewaXw++h+a318B3LTLSFER9Ee4n1pLCZLw@mail.gmail.com>
Message-ID: <CAHk-=wjQks3o_3=WewaXw++h+a318B3LTLSFER9Ee4n1pLCZLw@mail.gmail.com>
Subject: Re: [GIT PULL] ucounts: Count rlimits in each user namespace
To: Alexey Gladkov <legion@kernel.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	Linux Containers <containers@lists.linux.dev>
Content-Type: text/plain; charset="UTF-8"

On Tue, Jun 29, 2021 at 1:20 PM Alexey Gladkov <legion@kernel.org> wrote:
>
> Waaaait. task_ucounts() is a different thing. This function only gets a
> field from the task structure without any reference counting. But the
> get_ucounts() is more like get_user_ns() or get_uid(), but does not ignore
> counter overflow.

Alexey, that code cannot be right.

Look here:

        rcu_read_lock();
        ucounts = task_ucounts(t);
        sigpending = inc_rlimit_ucounts(ucounts, UCOUNT_RLIMIT_SIGPENDING, 1);
        if (sigpending == 1)
                ucounts = get_ucounts(ucounts);
        rcu_read_unlock();

so now we've done that inc_rlimit_ucounts() unconditionally on that
task_ucounts() thing.

And then if the allocation fails (or the limit is hit) the code does

        if (ucounts && dec_rlimit_ucounts(ucounts, UCOUNT_RLIMIT_SIGPENDING, 1))
                put_ucounts(ucounts);

ie now it does the dec_rlimit_ucounts _conditionally_.

See what I'm complaining about? This is not logical, AND IT CANNOT
POSSIBLY BE RIGHT.

My argument is that

 (a) the dec_rlimit_ucounts() has to pair up with
inc_rlimit_ucounts(), or you're leaking counts

 (b) get_ucounts() has to pair up with put_ucounts().

Note that (a) has to be REGARDLESS of whether get_ucounts() was
successful or not.

> Earlier I tried to use refcount_t which never returns errors [1]. We
> talked and you said that ignoring counter overflow errors is bad
> design for this case.

You can't ignore counter overflow errors, no. But that's exactly what
that code is doing.

If get_ucount() fails due to overflow, you don't return an error. You
just miscount the end result!

So yeah, its' "testing" the overflow condition, but that's not an
argument, when it then DOES EXPLICITLY THE WRONG THING.

At that point, the test is actively harmful and wrong. See?

             Linus
