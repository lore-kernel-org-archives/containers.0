Received: from mail-il1-f177.google.com (mail-il1-f177.google.com [209.85.166.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9FF427C
	for <containers@lists.linux.dev>; Mon, 28 Feb 2022 16:19:09 +0000 (UTC)
Received: by mail-il1-f177.google.com with SMTP id 9so10335654ily.11
        for <containers@lists.linux.dev>; Mon, 28 Feb 2022 08:19:09 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Vn4WqbIDG/ntBsUraOm1IfhiMXb4IqH7hNoF8dQN1uY=;
        b=Ognv/qoEC0BCigqfD1iUfyFcTQ3UwJB1WPyrj4kfHLT2TSZJTxm0YFpoxUIedWOQzn
         HtDwMr91zfT7JEZ74zqyTZVHyNvbJYHpc3O7w2v0e72mJCKMMQ2Ji3qmb50ofxCjX6tW
         99HjfeVmGQtV1nTJdlYRODEQAL5W+W0WSDBSiHJKrGA3nY1GoNWXU0a0UvoZIl2IIt8l
         E24JKq6cel6fdhzIk8pK0AFYagwaRKmZbrmCFKjpvHU3qDy42fIQpyQfxp3+zxY+A3rJ
         sFvaRlJIISSkevkaIGV3UiQp0zMLzqVUH8PxKBcerX/JzspjNwRx++NHPBfGnhTXMnvg
         WADg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=Vn4WqbIDG/ntBsUraOm1IfhiMXb4IqH7hNoF8dQN1uY=;
        b=L5FdTgLtlws97HFi08/CCpyy4ghpazp6jmVyb+ZtItvA7pWF6+NBxD+hqQkmNYWZOK
         2Zc8d8Pi4qeY2QdadkcprlBGX7uYhRJbcDvg0OMyYCsyfJJPuyCSAQ0cgK1KTXtv8tm7
         OkzpLaVmBCLmlM0TOXweiu/s7PkbCJsi8fGEOIwdSh0BKbFZPVGQJIPtajYpHKqmavJt
         II6aFhOfPojqr3Je4rbTOj9i6MCdkoUdNP/cC0DBF7f3hslWjed9ySiEbuK1cRYMPek4
         17irfdjeD557Gg+6NwSryrmoTM8F2dVKRfOOwUhhKFd+zrAVrZDpPA/uhcwv0qLodMuV
         ZEHQ==
X-Gm-Message-State: AOAM531V0KYajMLi5jL3I9dR04kQgj1pMIzGtMBnlaO3wfUJhLmQbBkY
	XO0kGhTx3M5Hoxg9H5tG2WQjvCa9TrEKb+HiQPp/BtWyD8M=
X-Google-Smtp-Source: ABdhPJyYWLgA3PGjLihMX1l90N0F/cIajbZfCmGKwzaLbv8t8ihI+2SAJMYxBumI8bsenElezTEN8S34LMTmDsUSq+k=
X-Received: by 2002:a05:6e02:1aa2:b0:2c2:2fc1:face with SMTP id
 l2-20020a056e021aa200b002c22fc1facemr20387524ilv.198.1646065148701; Mon, 28
 Feb 2022 08:19:08 -0800 (PST)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20220228113910.1727819-1-amir73il@gmail.com> <20220228113910.1727819-5-amir73il@gmail.com>
 <CAJfpegvZefGp9NChm_69Km0FgpxwUs+og-uc2mpMAbH6mZ2azQ@mail.gmail.com>
In-Reply-To: <CAJfpegvZefGp9NChm_69Km0FgpxwUs+og-uc2mpMAbH6mZ2azQ@mail.gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Mon, 28 Feb 2022 18:18:57 +0200
Message-ID: <CAOQ4uxgg8PDweNvkhXE20Gbb+=OGBbwLXjR6Yffc4ZkiKzGM0w@mail.gmail.com>
Subject: Re: [PATCH v2 4/6] fs: report per-mount io stats
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Al Viro <viro@zeniv.linux.org.uk>, overlayfs <linux-unionfs@vger.kernel.org>, 
	containers@lists.linux.dev, linux-fsdevel <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"

On Mon, Feb 28, 2022 at 5:06 PM Miklos Szeredi <miklos@szeredi.hu> wrote:
>
> On Mon, 28 Feb 2022 at 12:39, Amir Goldstein <amir73il@gmail.com> wrote:
> >
> > Show optional collected per-mount io stats in /proc/<pid>/mountstats
> > for filesystems that do not implement their own show_stats() method
> > and opted-in to generic per-mount stats with FS_MOUNT_STATS flag.
>
> This would allow some filesystems to report per-mount I/O stats, while
> leaving CIFS and NFS reporting a different set of per-sb stats.  This
> doesn't sound very clean.
>
> There was an effort to create saner and more efficient interfaces for
> per-mount info.  IMO this should be part of that effort instead of
> overloading the old interface.
>

That's fair, but actually, I have no much need for per-mount I/O stats
in overlayfs/fuse use cases, so I could amend the patches to collect and
show per-sb I/O stats.

Then, the generic show_stats() will not be "overloading the old interface".
Instead, it will be creating a common implementation to share among different
filesystems and using an existing vfs interface as it was intended.

Would you be willing to accept adding per-sb I/O stats to overlayfs
and/or fuse via /proc/<pid>/mountstats?

Thanks,
Amir.
