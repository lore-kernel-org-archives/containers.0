Received: from mail-il1-f176.google.com (mail-il1-f176.google.com [209.85.166.176])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 17ED870
	for <containers@lists.linux.dev>; Mon, 17 May 2021 17:54:32 +0000 (UTC)
Received: by mail-il1-f176.google.com with SMTP id z1so6887744ils.0
        for <containers@lists.linux.dev>; Mon, 17 May 2021 10:54:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=sargun.me; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=zLSBrGc0WfP3Pu9mRhepzRhhSNQ0d1+mv4ZIuny3PCE=;
        b=apMSSFZpnC0TCNR6wciOFVOjRv8HfBGsEB0/NxZxsirwzsFUiv6nrFHwONXyfMSlEE
         A1gPKjm42FG93MI7TR/J504p6LZ3yq44igR52eJTPS8fSneRQbJ+w67uroW9BpNdf1FK
         f7jpVKFrswoQOw/92eHdDcfxYbpaJ+ymYLPl0=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=zLSBrGc0WfP3Pu9mRhepzRhhSNQ0d1+mv4ZIuny3PCE=;
        b=ite18rFI9LR763Bs5ZdlORJ3eDcn5Kw6lr99NRiKo8MkhF3cGllNX1vyXsXEIbtai1
         TTzCQP2L9mNCzAY0IcWdwsobkBIYSquaPa+ycGg8y+3zOyF9xWeGG6xHrunMCH7SBt5O
         bN0K2cgac5pruGTsykkmkjVVB4VDfaYZrQ2SNtl+EnQeV8SPYcIzmhjlCD3eYZnJ6vrU
         wkLxG269o0cVrtymuemGwCkKBFpyx0bxvNu9ka5lMoAV+AJMbaX51mAyWxkno82ZFIDL
         hAhN8NIZ3Ovf2v2gRQK0DuNn63OkOmp58tSVaul/Vmq43DskIg3IsCo3SMyfS/tIKdPJ
         Cinw==
X-Gm-Message-State: AOAM5323DCjBlgsVqcEzalu6v0c1Omnii4AQzTn7H5Gs5vI+GZuPo6h3
	eODkMz7XY6ZBacUUodqDwY4GKWsmcvCMhpYcZ/HvJQ==
X-Google-Smtp-Source: ABdhPJz0yLEKO0WcXF7iyAjs9lEnYLEYrMbzmli7FuGJ1q9A81v4fu3+IcyiLYeLQyULoMrRAZ/WMgIDAxvC2AxDVno=
X-Received: by 2002:a92:2a0a:: with SMTP id r10mr765713ile.274.1621274071101;
 Mon, 17 May 2021 10:54:31 -0700 (PDT)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20210502001851.3346-1-sargun@sargun.me> <20210502001851.3346-4-sargun@sargun.me>
 <20210511215010.GB1964106@cisco>
In-Reply-To: <20210511215010.GB1964106@cisco>
From: Sargun Dhillon <sargun@sargun.me>
Date: Mon, 17 May 2021 10:53:55 -0700
Message-ID: <CAMp4zn-crcdi6AR9VfAmpb0TO9sDtpdwA4C59ERqwdoQW7yTAg@mail.gmail.com>
Subject: Re: [PATCH 3/4] seccomp: Support atomic "addfd + send reply"
To: Tycho Andersen <tycho@tycho.pizza>
Cc: Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>, 
	Linux Containers <containers@lists.linux.dev>, Andy Lutomirski <luto@kernel.org>, 
	Rodrigo Campos <rodrigo@kinvolk.io>, =?UTF-8?Q?Mauricio_V=C3=A1squez_Bernal?= <mauricio@kinvolk.io>, 
	Giuseppe Scrivano <gscrivan@redhat.com>, Christian Brauner <christian.brauner@ubuntu.com>, 
	=?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@linux.microsoft.com>
Content-Type: text/plain; charset="UTF-8"

On Tue, May 11, 2021 at 2:50 PM Tycho Andersen <tycho@tycho.pizza> wrote:
>
> Hi,
>
> On Sat, May 01, 2021 at 05:18:50PM -0700, Sargun Dhillon wrote:
>
> [snip]
>
> > Other patches in this series add a way to block signals when a syscall
> > is put to wait by seccomp.
>
> I guess we can drop this bit from the message if the series is split.
>
Makes sense.

> > The struct seccomp_notif_resp, used when doing SECCOMP_IOCTL_NOTIF_SEND
> > ioctl() to send a response to the target, has three more fields that we
> > don't allow to set when doing the addfd ioctl() to also return. The
> > reasons to disallow each field are:
> >  * val: This will be set to the new allocated fd. No point taking it
> >    from userspace in this case.
> >  * error: If this is non-zero, the value is ignored. Therefore,
> >    it is pointless in this case as we want to return the value.
> >  * flags: The only flag is to let userspace continue to execute the
> >    syscall. This seems pointless, as we want the syscall to return the
> >    allocated fd.
> >
> > This is why those fields are not possible to set when using this new
> > flag.
>
> I don't quite understand this; you don't need a NOTIF_SEND at all
> with the way this currently works, right?
>
I reworded:

This effectively combines SECCOMP_IOCTL_NOTIF_ADDFD and
SECCOMP_IOCTL_NOTIF_SEND into an atomic opteration. The notification's
return value, nor error can be set by the user. Upon successful invocation
of the SECCOMP_IOCTL_NOTIF_ADDFD ioctl with the SECCOMP_ADDFD_FLAG_SEND
flag, the notifying process's errno will be 0, and the return value will
be the file descriptor number that was installed.

How does that sound?

> > @@ -1113,7 +1136,7 @@ static int seccomp_do_user_notification(int this_syscall,
> >                                                struct seccomp_kaddfd, list);
> >               /* Check if we were woken up by a addfd message */
> >               if (addfd)
> > -                     seccomp_handle_addfd(addfd);
> > +                     seccomp_handle_addfd(addfd, &n);
> >
> >       }  while (n.state != SECCOMP_NOTIFY_REPLIED);
> >
>
> This while() bit is introduced in the previous patch, can we fold this
> deletion into that somehow?
I'm not sure what you're getting at. This just an argument change which
also passes the notification to the addfd function. The patch is split out
to allow it to be backported to stable.

>
> Thanks,
>
> Tycho
