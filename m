Received: from mail-lj1-f172.google.com (mail-lj1-f172.google.com [209.85.208.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5A48170
	for <containers@lists.linux.dev>; Fri, 28 May 2021 22:32:33 +0000 (UTC)
Received: by mail-lj1-f172.google.com with SMTP id b12so7157085ljp.1
        for <containers@lists.linux.dev>; Fri, 28 May 2021 15:32:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=kinvolk.io; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=nbrsHa/rQMz3BdevUmx8wLV3ihqPlTItaOywe0j/k9E=;
        b=idX417g+x6jiPQOwBGJDlnUAEo09JmsPhMAYuRYmitcN8A130VeL1zBDcQoZd1/Fp6
         2onD5/XnCLhZXuWZkWhLmRk8R4rgHaJP2BW/SYNDUktfK82DUXDLgEjQQttU2nmUU8Xg
         e5ppX/dygP8is9w/IHr06JjTGva8IGhxLjwMA=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=nbrsHa/rQMz3BdevUmx8wLV3ihqPlTItaOywe0j/k9E=;
        b=BGzhDuH+xweLzB7FYGPheSKd9BE/p+Do6S4pFhhcXFygmb0w43Kgrh0bVcgi0F7c2f
         off+VZHF+FM3+TD9HfUORF6g3woO8Dpm+yw5/foT/mdGdNA32HbfEodGDliiH1jSgEf5
         xWQ5su+ef3zzX+6KQ3NXCU1WqCPci4xi8ZvyeuPakGifFiKAWjKaS4tg0kAEskAKta8x
         xd9qhTBeI7B+V0UDqq/CxDUjJhJxt/kI1+ZNWkGJpwiUrfhpvOWmcMbOwStI45WQBcWG
         XNRwjcBLVicoNmXhJvW+yY6p/FZkjz++EGimj2L5RsEAh0u8lCK9hkK8WkoWNdxlo/Uo
         kCFw==
X-Gm-Message-State: AOAM532BUIWFtpBCa07itU1Q7Ce4odxsMLN5imDPvMrz4r1HHGdSyMtu
	gJ48NKnWrl7QXYDrnZsu33R75X4lGABfBZbaN4rGoQ==
X-Google-Smtp-Source: ABdhPJzRLaWOCJV49qefgqtgXRstiScihTWBAfCs2EkuxoSRrLUthng2+WJzOtCsDX/F8NWyp1SuZLOukrk0w6yxpp4=
X-Received: by 2002:a2e:b61b:: with SMTP id r27mr8039309ljn.327.1622241151503;
 Fri, 28 May 2021 15:32:31 -0700 (PDT)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20210517193908.3113-1-sargun@sargun.me> <20210517193908.3113-3-sargun@sargun.me>
 <CACaBj2YUiowSKzvh02OjpQNqQViA8N0eyRMimkK=90NagRF40w@mail.gmail.com>
 <202105271137.C491991621@keescook> <CACaBj2aaDkJwDM8ugR5LxWEOho3nZuHjYLLsth3XYjf39tpaQQ@mail.gmail.com>
 <202105281014.EECE3D3048@keescook>
In-Reply-To: <202105281014.EECE3D3048@keescook>
From: Rodrigo Campos <rodrigo@kinvolk.io>
Date: Sat, 29 May 2021 00:31:55 +0200
Message-ID: <CACaBj2aM0FxsTSeCDu+3tfdBY9-rbPaLA88YW3Fg-ZQDJRGoXQ@mail.gmail.com>
Subject: Re: [PATCH v2 2/4] seccomp: Refactor notification handler to prepare
 for new semantics
To: Kees Cook <keescook@chromium.org>
Cc: Sargun Dhillon <sargun@sargun.me>, LKML <linux-kernel@vger.kernel.org>, 
	containers@lists.linux.dev, Tycho Andersen <tycho@tycho.pizza>, 
	Andy Lutomirski <luto@kernel.org>, =?UTF-8?Q?Mauricio_V=C3=A1squez_Bernal?= <mauricio@kinvolk.io>, 
	Giuseppe Scrivano <gscrivan@redhat.com>, Christian Brauner <christian.brauner@ubuntu.com>, 
	=?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@linux.microsoft.com>
Content-Type: text/plain; charset="UTF-8"

On Fri, May 28, 2021 at 7:14 PM Kees Cook <keescook@chromium.org> wrote:
>
> On Fri, May 28, 2021 at 05:27:39PM +0200, Rodrigo Campos wrote:
> > On Thu, May 27, 2021 at 8:42 PM Kees Cook <keescook@chromium.org> wrote:
> > >
> > > On Thu, May 27, 2021 at 01:51:13PM +0200, Rodrigo Campos wrote:
> > > >
> > > > Kees, as I mentioned in the linked thread, this issue is present in
> > > > 5.9+ kernels. Should we add the cc to stable for this patch? Or should
> > > > we cc to stable the one linked, that just fixes the issue without
> > > > semantic changes to userspace?
> > >
> > > It sounds like the problem is with Go, using addfd, on 5.9-5.13 kernels,
> > > yes?
> >
> > Yes.
> >
> > > Would the semantic change be a problem there? (i.e. it sounds like
> > > the semantic change was fine for the 5.14+ kernels, so I'm assuming it's
> > > fine for earlier ones too.)
> >
> > No, I don't think it will cause any problem.
> >
> > > > Just to be clear, the other patch that fixes the problem without
> > > > userspace visible changes is this:
> > > > https://lore.kernel.org/lkml/20210413160151.3301-1-rodrigo@kinvolk.io/
> > >
> > > I'd prefer to use the now-in-next fix if we can. Is it possible to build
> > > a test case that triggers the race so we can have some certainty that
> > > any fix in -stable covers it appropriately?
> >
> > I've verified that Sargun's patch also solves the problem in mainline.
> > I have now also verified that it applies cleany and fixes the issue
> > for linux-stable/5.10.y and linux-stable/5.12.y too (without the patch
> > I see the problem, with the patch I don't see it).  5.11 is already
> > EOL, so I didn't try it (probably will work as well).
>
> Oh, btw, may I add a Tested-by: from you for this fix?

Oh, right! Yes. Here it goes so it's simpler to add :)

Tested-by: Rodrigo Campos <rodrigo@kinvolk.io>


Thanks!
