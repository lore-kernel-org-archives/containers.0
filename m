Received: from mail-lj1-f175.google.com (mail-lj1-f175.google.com [209.85.208.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A9F2B2F80
	for <containers@lists.linux.dev>; Thu,  8 Jul 2021 18:44:24 +0000 (UTC)
Received: by mail-lj1-f175.google.com with SMTP id p24so4003672ljj.1
        for <containers@lists.linux.dev>; Thu, 08 Jul 2021 11:44:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=H90Copkue5w9iSGNVPGNAw4Flq6Q55TWkIAdrELCwBM=;
        b=HE5O8LXKCYXmH5RUxvGLH0utBqVBpLQX5Kf2DIhBzYmckquTD2CtnsEicVLDaWZLpc
         5YmOIWhkCu4PgVgf074nK1bz76AdI+h1P29IgsltIWF3Y5QNolavzbcwt7gmupgQM07Q
         i03U7ZtUn1Qe0zcSQgt+se4ZC7u48LjoEYOww=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=H90Copkue5w9iSGNVPGNAw4Flq6Q55TWkIAdrELCwBM=;
        b=jAl7g3hj3r81i/ba0RRLwd7TAVWsgT3FheSSJD5BeEdN6pDR6OGSQ59EqNNZhD0slr
         3P5b99XFHt3xYNWQUfTMahf1cRSiRIS5Ddsw9XpeKHxAIb1iA5Vp+XWMfOmrdLG/bwIq
         JV1PZYBICiykeyBDL7KRK/mIU0JzwK7tcBv7a3ssPp/r3VF9lTVIU3YV2pDbTF5EVocU
         O4HLSie3HW+xp3v+Pawu7KWhQtO+BcuOB2uGfVdCHlr0Baem+XKz/Gyr1NdbutL20Pl6
         HyU08yH5oVwPHPXn49relYxBvit770blFpAmYqqrHxkQE9C/wJ5G4P0SHeRzpL4knM2g
         eRCw==
X-Gm-Message-State: AOAM533A5RLois+7htVBpk8fWxOi9MnrQTCReluJTYe0zp1DPG4iNi19
	MGw10N0YTe8Q36Vrhg4HIY+tysacZwfBSlGwB3I=
X-Google-Smtp-Source: ABdhPJwYtoL9LP75MGmbsdlmAZrXcHivexjdobstRvc0A71JfUOkjz7Uh1+gsbC9aein4C8RMjL6ag==
X-Received: by 2002:a2e:3604:: with SMTP id d4mr1202932lja.510.1625769862359;
        Thu, 08 Jul 2021 11:44:22 -0700 (PDT)
Received: from mail-lf1-f47.google.com (mail-lf1-f47.google.com. [209.85.167.47])
        by smtp.gmail.com with ESMTPSA id q5sm266166lfr.37.2021.07.08.11.44.21
        for <containers@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 08 Jul 2021 11:44:21 -0700 (PDT)
Received: by mail-lf1-f47.google.com with SMTP id a18so18098879lfs.10
        for <containers@lists.linux.dev>; Thu, 08 Jul 2021 11:44:21 -0700 (PDT)
X-Received: by 2002:a05:6512:3585:: with SMTP id m5mr24770812lfr.253.1625769861582;
 Thu, 08 Jul 2021 11:44:21 -0700 (PDT)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <CAHk-=wirhF8G1XniAfxzJXCYUnuAx23Q1WLi_n4+HGsUXv72KQ@mail.gmail.com>
 <20210708103301.2109330-1-legion@kernel.org>
In-Reply-To: <20210708103301.2109330-1-legion@kernel.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 8 Jul 2021 11:44:05 -0700
X-Gmail-Original-Message-ID: <CAHk-=whdEAjawjUSeJ+DV25ARdAhbiW_HZM65ZgJx7M94rvLkg@mail.gmail.com>
Message-ID: <CAHk-=whdEAjawjUSeJ+DV25ARdAhbiW_HZM65ZgJx7M94rvLkg@mail.gmail.com>
Subject: Re: [PATCH v2] Fix UCOUNT_RLIMIT_SIGPENDING counter leak
To: Alexey Gladkov <legion@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	Linux Containers <containers@lists.linux.dev>, "Eric W . Biederman" <ebiederm@xmission.com>, 
	Oleg Nesterov <oleg@redhat.com>
Content-Type: text/plain; charset="UTF-8"

On Thu, Jul 8, 2021 at 3:34 AM Alexey Gladkov <legion@kernel.org> wrote:
>
> We must properly handle an errors when we increase the rlimit counter
> and the ucounts reference counter. We have to this with RCU protection
> to prevent possible use-after-free that could occur due to concurrent
> put_cred_rcu().

Thanks, LGTM. Applied,

            Linus
