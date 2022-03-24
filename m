Received: from mail-lj1-f181.google.com (mail-lj1-f181.google.com [209.85.208.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7203523BE
	for <containers@lists.linux.dev>; Thu, 24 Mar 2022 22:17:03 +0000 (UTC)
Received: by mail-lj1-f181.google.com with SMTP id r22so8044658ljd.4
        for <containers@lists.linux.dev>; Thu, 24 Mar 2022 15:17:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=PM3ucKwhvfkvF2Nl5Hbh/PREqeRskUbQ3y0OZLEytyc=;
        b=DsMNZxOJXP7mmXLU97e9EnCUy90/iZNAwHF33pAquu/Ky4C7i9EEezsfMrPspBOGeu
         d+qotrhHtIPIDuqRCJ6zaV59LioG7x9hmu2wtEAUyzUXS9eNo094xMc9zGu+dRBJm9pz
         teccZ/n03GN1gLCLba/NZyt6nf4q4pzxwDuvA=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=PM3ucKwhvfkvF2Nl5Hbh/PREqeRskUbQ3y0OZLEytyc=;
        b=0fUmRTE3ddq0wGFsnnT9RUGq1+3rEMEF3Xbe5fiAgo484N9YmlyvJeb3MBEZdvfPaJ
         NBmfcKp+b9fssuR0vMO8is6zDYbSTtvISN8BNDH41dnjS9avINGflHuzA9GDwax1tNbW
         MT6+AjLEATzd5SryqrxGeGSjnAZzE1Hf1kam7MrK5hyd+Py2NFgvNkgP1C68CUjf5h+p
         Kkrw4csYRKFB9rbkFpE1/rIxj0H2GqRIJXGzTMeS1g0JfWiR1cWF/28VgflgxaMBZ2Ib
         ycSGxD0hFnPrSKT9EsVSPm7EDkhE1dUN925F8iUc0rPDJN+6dYL+FGLUyHVvtkyhLlSg
         VUbA==
X-Gm-Message-State: AOAM533T9ky7ryMzxVsADbBv17wuWQ3QIiXD2FhkE7icJxOrs4pGNLvn
	6UkCg4puEB/V02qvuKChaA2Z94fAiYPualUS4tk=
X-Google-Smtp-Source: ABdhPJzlwtHHmd6Ltkw+4nkGQkViiE7FH7AkkIN5vYNkFvo3mnix5/9UbKBvH/uKhklSZTZ42G52aw==
X-Received: by 2002:a2e:9b96:0:b0:249:8705:8f50 with SMTP id z22-20020a2e9b96000000b0024987058f50mr5939216lji.73.1648160221144;
        Thu, 24 Mar 2022 15:17:01 -0700 (PDT)
Received: from mail-lf1-f46.google.com (mail-lf1-f46.google.com. [209.85.167.46])
        by smtp.gmail.com with ESMTPSA id d9-20020a193849000000b0044a54c2ed94sm477323lfj.300.2022.03.24.15.16.59
        for <containers@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 24 Mar 2022 15:16:59 -0700 (PDT)
Received: by mail-lf1-f46.google.com with SMTP id p10so4560984lfa.12
        for <containers@lists.linux.dev>; Thu, 24 Mar 2022 15:16:59 -0700 (PDT)
X-Received: by 2002:a05:6512:3055:b0:44a:3914:6603 with SMTP id
 b21-20020a056512305500b0044a39146603mr5310974lfb.435.1648160218726; Thu, 24
 Mar 2022 15:16:58 -0700 (PDT)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <cover.1644862280.git.legion@kernel.org> <877d8kfmdp.fsf@email.froward.int.ebiederm.org>
 <CAHk-=wgBB8iPd0W=MQWnQJukMAPAqgsC0QX2wwiSvcct9zu_RA@mail.gmail.com> <87czib9g38.fsf@email.froward.int.ebiederm.org>
In-Reply-To: <87czib9g38.fsf@email.froward.int.ebiederm.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 24 Mar 2022 15:16:42 -0700
X-Gmail-Original-Message-ID: <CAHk-=whvvHX8E2DP3WCwnPaOz8ViJDzfjNSBduP98W=L4+PN4A@mail.gmail.com>
Message-ID: <CAHk-=whvvHX8E2DP3WCwnPaOz8ViJDzfjNSBduP98W=L4+PN4A@mail.gmail.com>
Subject: Re: [GIT PULL] ipc: Bind to the ipc namespace at open time.
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Alexey Gladkov <legion@kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	Linux Containers <containers@lists.linux.dev>, 
	Alexander Mikhalitsyn <alexander.mikhalitsyn@virtuozzo.com>, 
	Andrew Morton <akpm@linux-foundation.org>, 
	Christian Brauner <christian.brauner@ubuntu.com>, Daniel Walsh <dwalsh@redhat.com>, 
	Davidlohr Bueso <dbueso@suse.de>, Kirill Tkhai <ktkhai@virtuozzo.com>, 
	Manfred Spraul <manfred@colorfullife.com>, Serge Hallyn <serge@hallyn.com>, 
	Varad Gautam <varad.gautam@suse.com>, Vasily Averin <vvs@virtuozzo.com>
Content-Type: text/plain; charset="UTF-8"

On Thu, Mar 24, 2022 at 2:49 PM Eric W. Biederman <ebiederm@xmission.com> wrote:
>
> I don't see how passing in struct cred does anything helpful.  The
> namespace can not be found in struct cred.

Duh. For some reason I thought we had it there, but yeah, that only
contains the user-namespace.

The rest is in tsk->nsproxy.

So it would have to be squirrelled away in some other way.

> But all of these cleanups I see are moving forward from the current
> point so I don't see why we would not want to merge the code as is
> and then get the tested versions of my cleanups below.

What part of "that code is too ugly to live" did not end up registering.

Maybe it can be cleaned up. But it had better be cleaned up before I pull it.

                Linus
