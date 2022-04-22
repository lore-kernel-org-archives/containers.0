Received: from mail-lf1-f50.google.com (mail-lf1-f50.google.com [209.85.167.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7B62E7A
	for <containers@lists.linux.dev>; Fri, 22 Apr 2022 20:45:13 +0000 (UTC)
Received: by mail-lf1-f50.google.com with SMTP id bu29so16345768lfb.0
        for <containers@lists.linux.dev>; Fri, 22 Apr 2022 13:45:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=k7zvOy4Nu2CZwXC2YGCoJs9vagHX2+J0L34nHsp83yk=;
        b=DfG+M/ORpXZPBdQvWZZK/E9FnBMkrgnax6RCiGFmGYuqE2J2XTjryHKJuwF9GsxnR1
         8TyKRm500f39QvNnoE1Z/T8eT2Y2SHZyDLcpBsXLtb4f0n8UwNW1f33SC/zlmWHx5BNM
         WE42YK0v+aT6a2sp2qnEHIv8xSPVSWn2KhDLU=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=k7zvOy4Nu2CZwXC2YGCoJs9vagHX2+J0L34nHsp83yk=;
        b=a0IMcNrGEKFViJHqsu/gcdbK+kjpLQxaViUlnpf58RMJv976wtqJOl7Koj0l8eXiBt
         U0L1gEdkBNIrJfkAxOdqcsH8VACYBO+w2B6rCxUJrfs69omsBnl8fnWECryUf1HsfQHT
         XmzfdkLuXpWeoIblxArUojA/5tBLOvS9wceMWGV0BrO+WB+HTTin7uuQuOTXxUen2Am7
         NR1VlpQizl7lWGYiNyJ/WXsUmpeWwnUPIKfVty3Kr5mKGmSUbGIf4L2iYr5+7+JFc3aC
         HuARiMvazK/B5yzwGguGbUziAHjrgMFVCJrpmBiNexJ5rmm+gXePjPMnPcDP8rAMnGGP
         5IlA==
X-Gm-Message-State: AOAM530Rq+svSfI3WvcZ5FJTyo0gJ9fnyfGl8z40QPI4bIdjnvzYjL7Q
	TDIqZrTPDgW+zgHEapjcbxvfNa3XX+YQbQMxyxA=
X-Google-Smtp-Source: ABdhPJzXGLaXcnP+Kw0JzHZb8KHF0aSjUUnPeAKRyElk/Cc8Qw2KT+yLXoOIaBkaz81OaqoQgZCkfA==
X-Received: by 2002:a05:6512:3d86:b0:471:b3db:1179 with SMTP id k6-20020a0565123d8600b00471b3db1179mr4449308lfv.72.1650660311287;
        Fri, 22 Apr 2022 13:45:11 -0700 (PDT)
Received: from mail-lf1-f42.google.com (mail-lf1-f42.google.com. [209.85.167.42])
        by smtp.gmail.com with ESMTPSA id d22-20020a056512321600b0046f796b70b5sm345277lfe.87.2022.04.22.13.45.07
        for <containers@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 22 Apr 2022 13:45:07 -0700 (PDT)
Received: by mail-lf1-f42.google.com with SMTP id br15so1882554lfb.9
        for <containers@lists.linux.dev>; Fri, 22 Apr 2022 13:45:07 -0700 (PDT)
X-Received: by 2002:a05:6512:1193:b0:471:af88:2d74 with SMTP id
 g19-20020a056512119300b00471af882d74mr4247383lfr.531.1650660306799; Fri, 22
 Apr 2022 13:45:06 -0700 (PDT)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <CAHk-=wgBB8iPd0W=MQWnQJukMAPAqgsC0QX2wwiSvcct9zu_RA@mail.gmail.com>
 <cover.1650631347.git.legion@kernel.org>
In-Reply-To: <cover.1650631347.git.legion@kernel.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 22 Apr 2022 13:44:50 -0700
X-Gmail-Original-Message-ID: <CAHk-=whi2SzU4XT_FsdTCAuK2qtYmH+-hwi1cbSdG8zu0KXL=g@mail.gmail.com>
Message-ID: <CAHk-=whi2SzU4XT_FsdTCAuK2qtYmH+-hwi1cbSdG8zu0KXL=g@mail.gmail.com>
Subject: Re: [PATCH v1 0/4] ipc: Remove extra1 field abuse to pass ipc namespace
To: Alexey Gladkov <legion@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, 
	"Eric W . Biederman" <ebiederm@xmission.com>, 
	Alexander Mikhalitsyn <alexander.mikhalitsyn@virtuozzo.com>, 
	Andrew Morton <akpm@linux-foundation.org>, 
	Christian Brauner <christian.brauner@ubuntu.com>, Daniel Walsh <dwalsh@redhat.com>, 
	Davidlohr Bueso <dbueso@suse.de>, Kirill Tkhai <ktkhai@virtuozzo.com>, 
	Linux Containers <containers@lists.linux.dev>, Manfred Spraul <manfred@colorfullife.com>, 
	Serge Hallyn <serge@hallyn.com>, Varad Gautam <varad.gautam@suse.com>, 
	Vasily Averin <vvs@virtuozzo.com>
Content-Type: text/plain; charset="UTF-8"

On Fri, Apr 22, 2022 at 5:53 AM Alexey Gladkov <legion@kernel.org> wrote:
>
> Yes, Linus, these changes are not the refactoring you were talking
> about, but I plan to try to do such a refactoring in the my next
> patchset.

Heh. Ok, I'm not saying these patches are pretty, and looking up the
namespace thing is a bit subtle, but it's certainly prettier than the
existing odd "create a new ctl_table entry because of field abuse".

So this certainly looks like an improvement from a quick look.

              Linus
