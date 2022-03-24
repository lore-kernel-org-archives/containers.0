Received: from mail-lj1-f172.google.com (mail-lj1-f172.google.com [209.85.208.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3ACD87E
	for <containers@lists.linux.dev>; Thu, 24 Mar 2022 18:12:44 +0000 (UTC)
Received: by mail-lj1-f172.google.com with SMTP id q14so7246675ljc.12
        for <containers@lists.linux.dev>; Thu, 24 Mar 2022 11:12:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=/LSEoPoVBVnfztCSkUFcbwBfE5ukisNTx0Z0bM1jWgk=;
        b=fBZauSq0ACQcCD0aXGuuoIgacGzWbZWvHI/yboiImq3d2gbCBsK4u0P2R6I9rA5s+1
         llLlGyVUkbHFxwANgyrhG7OcuWCL4PearUKXNl+3bWauMSB43nTGA6zaQsGMBIOxTMat
         Y9LYQyxU0oUnKd77In8/8H15bD1XyIFNQEVc4=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=/LSEoPoVBVnfztCSkUFcbwBfE5ukisNTx0Z0bM1jWgk=;
        b=VvDQrvEri3zMycm/bU91eQ7zfr00azy1UxvzN6VDdUdr48+w8AFSn6wVJGUhyk+AHg
         Ji8NClDXEMmm8cL6hupawwlS9J2BOJewAQynieG6ztqCGBjR/ev9ZgrQqISDh4ivaUgA
         ASgUY8dC23ZbnnWUEjtfIiq7Wbc1Q/BPhiDg1X+PADgjpHHpP4xTVm7bhZdJ5xJDexyZ
         xXgN0eylooOmmXzZgLcL3guvJpvgYmqcvvEIXtJ5/XrnlaVPwLnJcGbsWO+QqgpEkAuA
         pQo5ooraLlIn1WU2CXYj0XHFmR5TR8dkdmMkNCgRqn1/iAyJ1e7pPBZTYU/6WH/ZNpfn
         Uk3w==
X-Gm-Message-State: AOAM533d7raiS349s8PSHx3TM8ZB1ZIWU3Lt8O+XhfaqCRKuhP6wcBaP
	P7ex3KT25CMGu8O89YANCGANlAwbTIEiD3iiAUQ=
X-Google-Smtp-Source: ABdhPJw/pmGvt0TyY+3Ez1HDgVugEnCSyxQw5iCzRpbFNSAogQDGpr+0L4SsYabb/bSWDZFSErvPcw==
X-Received: by 2002:a2e:a36c:0:b0:246:4680:e55a with SMTP id i12-20020a2ea36c000000b002464680e55amr4926621ljn.451.1648145561829;
        Thu, 24 Mar 2022 11:12:41 -0700 (PDT)
Received: from mail-lj1-f174.google.com (mail-lj1-f174.google.com. [209.85.208.174])
        by smtp.gmail.com with ESMTPSA id a25-20020a05651c031900b0024924e63577sm418907ljp.139.2022.03.24.11.12.38
        for <containers@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 24 Mar 2022 11:12:39 -0700 (PDT)
Received: by mail-lj1-f174.google.com with SMTP id bn33so7283094ljb.6
        for <containers@lists.linux.dev>; Thu, 24 Mar 2022 11:12:38 -0700 (PDT)
X-Received: by 2002:a2e:a5c4:0:b0:249:9ec3:f2b with SMTP id
 n4-20020a2ea5c4000000b002499ec30f2bmr4898966ljp.358.1648145558024; Thu, 24
 Mar 2022 11:12:38 -0700 (PDT)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <cover.1644862280.git.legion@kernel.org> <877d8kfmdp.fsf@email.froward.int.ebiederm.org>
In-Reply-To: <877d8kfmdp.fsf@email.froward.int.ebiederm.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 24 Mar 2022 11:12:21 -0700
X-Gmail-Original-Message-ID: <CAHk-=wgBB8iPd0W=MQWnQJukMAPAqgsC0QX2wwiSvcct9zu_RA@mail.gmail.com>
Message-ID: <CAHk-=wgBB8iPd0W=MQWnQJukMAPAqgsC0QX2wwiSvcct9zu_RA@mail.gmail.com>
Subject: Re: [GIT PULL] ipc: Bind to the ipc namespace at open time.
To: "Eric W. Biederman" <ebiederm@xmission.com>, Alexey Gladkov <legion@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, 
	Linux Containers <containers@lists.linux.dev>, 
	Alexander Mikhalitsyn <alexander.mikhalitsyn@virtuozzo.com>, 
	Andrew Morton <akpm@linux-foundation.org>, 
	Christian Brauner <christian.brauner@ubuntu.com>, Daniel Walsh <dwalsh@redhat.com>, 
	Davidlohr Bueso <dbueso@suse.de>, Kirill Tkhai <ktkhai@virtuozzo.com>, 
	Manfred Spraul <manfred@colorfullife.com>, Serge Hallyn <serge@hallyn.com>, 
	Varad Gautam <varad.gautam@suse.com>, Vasily Averin <vvs@virtuozzo.com>
Content-Type: text/plain; charset="UTF-8"

On Wed, Mar 23, 2022 at 1:24 PM Eric W. Biederman <ebiederm@xmission.com> wrote:
>
> Please pull the per-namespace-ipc-sysctls-for-v5.18 tag from the git tree:

Ugh.

I pulled this. Then I stared at it for a long time.

And then I decided that this is too ugly to live.

I'm sorry. I think Alexey has probably spent a fair amount of time on
it, but I really think the sysctl code needs to be cleaned up way more
than this.

The old code was horribly hacky too, but that setup_ipc_sysctls() (and
setup_mq_sysctls()) thing that copies the whole sysctls table, and
then walks it entry by entry to modify it, is just too ugly for words.

And then it hides things in .extra1, and because it does that it can't
use the normal "extra1 and extra2 contains the limits" so then at
write() time it copies it into a local one AGAIN only to set the
limits back so that it can call the normal routines again.

Not ok.

Yes, yes, the old code did some similar things - to set the 'data'
pointer. That was disgusting too. Don't get me wrong - the existing
code was nasty too. But this took nasty code, and doubled down on it.

I really think this is a fundamental problem, and needs a more
fundamental fix than adding more and more of these kinds of nasty
hacks.

And yes, that fundamental fix is almost certainly to pass in 'struct
cred *' to all those sysctl helper functions.

Then, when you do the actual 'sysctl()' system calls, you pass in
'current_cred()".

And the /proc users would pass in file->f_cred.

And yes, that patch might be quite messy, because we have quite a lot
of those random .proc_handler users.

But *most* of them by far (at least in random code) use the standard
proc_dointvec_minmax() and friends, and won't even notice.

And then the ones that are about namespace issues will have to
continue to do the nasty "make a copy and update the data pointer",
but *MAYBE* we could also introduce the notion of an "offset" to those
proc_dointvec_minmax() things to help them out (and at least avoid the
"make a copy" thing).

Anyway, I really think we must not make that sysctl code even uglier
than it is today, and I think we need to move towards a model that
actually makes sense. And that "pass in the right cred" is the only
sensible model I can see.

I haven't tried to create such a patch, and maybe Alexey already tried
to do something like that and it turned out to be too ugly for words
and that's why these nasty patches happened.

But at least for now, I can't with a good conscience pull this.

Sorry,
                   Linus
