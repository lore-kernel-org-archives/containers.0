Received: from mail-lj1-f175.google.com (mail-lj1-f175.google.com [209.85.208.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3B21B71
	for <containers@lists.linux.dev>; Fri, 18 Jun 2021 23:39:02 +0000 (UTC)
Received: by mail-lj1-f175.google.com with SMTP id k8so16075707lja.4
        for <containers@lists.linux.dev>; Fri, 18 Jun 2021 16:39:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Tc6KnzldMt7lAUMkOKZvz0InbTpN/HVH+jn+WvW53/E=;
        b=eL7fdXlfwBHtKxmU60+CMtMA5r/XRaknloeToSvovaCy6C1p3D+StnRGc6RHxSKOyB
         cbYWJzeNoxiX28R42+0V7Is0XqgT4rJZybOUPajsM5WmZT59S1flesvHNzV55nydgD8i
         zrq3N45K8cnGIdEvTrRRZAan57g2JQv+zqU+8zH2iOuH2PmKzAgWc/kX/kfhYxIwNKJa
         5obKI77TLDUM8aw3RbCG8up/2Cdi9EiN+j9Jybf71xqaOyGGi1fq1EdaKDn1VvdWEwre
         jmbSxEbYJwvYUzhjyRt2W8BKdvi7sHpAfYEOsBn1K0jgoqJXweGTYOdJIR0oFJ1ZJyH9
         /Erw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=Tc6KnzldMt7lAUMkOKZvz0InbTpN/HVH+jn+WvW53/E=;
        b=Fz/c3KH9WQOustBLxr/9VDlg53PA0RlKM5iD0Tl0oICTg1CtoAACtl1ED8QQU3xFwp
         ZUmXV2qtVfDWqv45VKxuab18z7wsFnUpQqQ9fQMpUaW34nGVNQfCjlAuTaAHRgmiYBma
         LtpqXm1lXCuE8B8Ig0EVlzk60vWMFcn+M604iEy+DoY91cY6SGuQ93v/sRVtTIAg+ku5
         L7+P2KqSZyTh5WJG4xIgFaQ+ie/Xo4ACm2D/4J7huDYg27jUZJvEEhGrHozGJXQc4VMP
         2/IwGw74n1hm6EJAQlOjgIoQpjwgkvd2EN88nWWpur6PQkeDakdav970+HHPJW0tfrxv
         orqQ==
X-Gm-Message-State: AOAM5339Y4BQE9CKTLTMxbuanh70vrT3W2SXunkHgrApExF6A7NryGnu
	7i6w5SS18HzLVBJoSmTTq7+G985p/UMc7lnZD6M4+g==
X-Google-Smtp-Source: ABdhPJyNRAgajgALbhCeexQMXZgno4VB8f7zK8yOADUk0+qMeoNDo2tJ9pGi8pHJ/tzQZNYzH21l23ame2aoIMzBkxY=
X-Received: by 2002:a05:651c:1108:: with SMTP id d8mr10895928ljo.0.1624059540015;
 Fri, 18 Jun 2021 16:39:00 -0700 (PDT)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <ac070cd90c0d45b7a554366f235262fa5c566435.1622716926.git.legion@kernel.org>
 <20210615113222.edzkaqfvrris4nth@wittgenstein> <20210615124715.nzd5we5tl7xc2n2p@example.org>
 <CALvZod7po_fK9JpcUNVrN6PyyP9k=hdcyRfZmHjSVE5r_8Laqw@mail.gmail.com> <87zgvpg4wt.fsf@disp2133>
In-Reply-To: <87zgvpg4wt.fsf@disp2133>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 18 Jun 2021 16:38:48 -0700
Message-ID: <CALvZod70DNiWF-jTUHp6pOVtVX9pzdvYXaQ1At3GHtdKD=iTwQ@mail.gmail.com>
Subject: Re: [PATCH v1] proc: Implement /proc/self/meminfo
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Alexey Gladkov <legion@kernel.org>, Christian Brauner <christian.brauner@ubuntu.com>, 
	LKML <linux-kernel@vger.kernel.org>, 
	Linux Containers <containers@lists.linux.dev>, 
	Linux Containers <containers@lists.linux-foundation.org>, 
	Linux FS Devel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, 
	Michal Hocko <mhocko@kernel.org>, Chris Down <chris@chrisdown.name>, 
	Cgroups <cgroups@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"

On Wed, Jun 16, 2021 at 9:17 AM Eric W. Biederman <ebiederm@xmission.com> wrote:
>
> Shakeel Butt <shakeelb@google.com> writes:
>
> > On Tue, Jun 15, 2021 at 5:47 AM Alexey Gladkov <legion@kernel.org> wrote:
> >>
> > [...]
> >>
> >> I made the second version of the patch [1], but then I had a conversation
> >> with Eric W. Biederman offlist. He convinced me that it is a bad idea to
> >> change all the values in meminfo to accommodate cgroups. But we agreed
> >> that MemAvailable in /proc/meminfo should respect cgroups limits. This
> >> field was created to hide implementation details when calculating
> >> available memory. You can see that it is quite widely used [2].
> >> So I want to try to move in that direction.
> >>
> >> [1] https://git.kernel.org/pub/scm/linux/kernel/git/legion/linux.git/log/?h=patchset/meminfo/v2.0
> >> [2] https://codesearch.debian.net/search?q=MemAvailable%3A
> >>
> >
> > Please see following two links on the previous discussion on having
> > per-memcg MemAvailable stat.
> >
> > [1] https://lore.kernel.org/linux-mm/alpine.DEB.2.22.394.2006281445210.855265@chino.kir.corp.google.com/
> > [2] https://lore.kernel.org/linux-mm/alpine.DEB.2.23.453.2007142018150.2667860@chino.kir.corp.google.com/
> >
> > MemAvailable itself is an imprecise metric and involving memcg makes
> > this metric even more weird. The difference of semantics of swap
> > accounting of v1 and v2 is one source of this weirdness (I have not
> > checked your patch if it is handling this weirdness). The lazyfree and
> > deferred split pages are another source.
> >
> > So, I am not sure if complicating an already imprecise metric will
> > make it more useful.
>
> Making a good guess at how much memory can be allocated without
> triggering swapping or otherwise stressing the system is something that
> requires understanding our mm internals.
>
> To be able to continue changing the mm or even mm policy without
> introducing regressions in userspace we need to export values that
> userspace can use.

The issue is the dependence of such exported values on mm internals.
MM internal code and policy changes will change this value and there
is a potential of userspace regression.

>
> At a first approximation that seems to look like MemAvailable.
>
> MemAvailable seems to have a good definition.  Roughly the amount of
> memory that can be allocated without triggering swapping.

Nowadays, I don't think MemAvailable giving "amount of memory that can
be allocated without triggering swapping" is even roughly accurate.
Actually IMO "without triggering swap" is not something an application
should concern itself with where refaults from some swap types
(zswap/swap-on-zram) are much faster than refaults from disk.

> Updated
> to include not trigger memory cgroup based swapping and I sounds good.
>
> I don't know if it will work in practice but I think it is worth
> exploring.

I agree.

>
> I do know that hiding the implementation details and providing userspace
> with information it can directly use seems like the programming model
> that needs to be explored.  Most programs should not care if they are in
> a memory cgroup, etc.  Programs, load management systems, and even
> balloon drivers have a legitimately interest in how much additional load
> can be placed on a systems memory.
>

How much additional load can be placed on a system *until what*. I
think we should focus more on the "until" part to make the problem
more tractable.

>
> A version of this that I remember working fairly well is free space
> on compressed filesystems.  As I recall compressed filesystems report
> the amount of uncompressed space that is available (an underestimate).
> This results in the amount of space consumed going up faster than the
> free space goes down.
>
> We can't do exactly the same thing with our memory usability estimate,
> but having our estimate be a reliable underestimate might be enough
> to avoid problems with reporting too much memory as available to
> userspace.
>
> I know that MemAvailable already does that /2 so maybe it is already
> aiming at being an underestimate.  Perhaps we need some additional
> accounting to help create a useful metric for userspace as well.
>

The real challenge here is that we are not 100% sure if a page is
reclaimable until we try to reclaim it. For example we might have file
lrus filled with lazyfree pages which might have been accessed.
MemAvailable will show half the size of file lrus but once we try to
reclaim them, we have to move them back to anon lru and drastic drop
in MemAvailable.

>
> I don't know the final answer.  I do know that not designing an
> interface that userspace can use to deal with it's legitimate concerns
> is sticking our collective heads in the sand and wishing the problem
> will go away.

I am a bit skeptical that a single interface would be enough but first
we should formalize what exactly the application wants with some
concrete use-cases. More specifically, are the applications interested
in avoiding swapping or OOM or stall?

Second, is the reactive approach acceptable? Instead of an upfront
number representing the room for growth, how about just grow and
backoff when some event (oom or stall) which we want to avoid is about
to happen? This is achievable today for oom and stall with PSI and
memory.high and it avoids the hard problem of reliably estimating the
reclaimable memory.
