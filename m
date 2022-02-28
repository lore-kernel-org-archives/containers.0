Received: from mail-vs1-f50.google.com (mail-vs1-f50.google.com [209.85.217.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C71237A
	for <containers@lists.linux.dev>; Mon, 28 Feb 2022 16:31:26 +0000 (UTC)
Received: by mail-vs1-f50.google.com with SMTP id g20so13547581vsb.9
        for <containers@lists.linux.dev>; Mon, 28 Feb 2022 08:31:26 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=szeredi.hu; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=rEXCndZSqLw0KM8FF9WWJNcYaW+CrKBAI4mMearLYPA=;
        b=ANoxucz13gEbrU2XLyJD6T/y/p9MiAGAUqM62cR9ahEyy/aYJzqZDmd7hBIkvtPvy1
         xJr6OR3uS9molaigPyNOU44vUw3vClQbGNZvsckB+Lzc8zRvHP4e/sc81iswdocSlcwz
         mzVk6xW932C2C+84CVZgHEydzH2p6eY3ohp1k=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=rEXCndZSqLw0KM8FF9WWJNcYaW+CrKBAI4mMearLYPA=;
        b=OzkbBa7cypSDyKJE0A5saUPxIO6zGz63e2jdXCSCj5pbdU4bKth42OnzXLNsexQkf8
         /UiPX+5FBQIKgoRtM5F5jRHiKguZGGcwWeRfZ7V8Znwn7gNcOaKOPkul07X0W5bcfYAA
         xRnl5KLmItglF3TzKI1Ud+g1Yltes1abdw31O3iDWqG8b5/onSNoF/4mtJQH3E8mGqNM
         Sy1x4/sPJXaLghA/TBgLQfZIv9ECMOkAurQbhKaBRE2u+PebBwYc6EWHMucNlxr04PHH
         vUI8Zx78j+40RN/ruhjsel+MBssE7p/Y1AAxQ3bEbaMxaFC3tEN4mrIlb83QHIM4T7i8
         Jzug==
X-Gm-Message-State: AOAM532VzYmY0a2NF0KZtrWSxs3ubaV7CS56Zygmn1cRdj5ifHHuJUZm
	Pe8viDogBqVFcLI26XcKAIs4XXQv9u5Wbh+ttVMang==
X-Google-Smtp-Source: ABdhPJxl9qhvXsw99bcbpm0zcQ74AP/OgSf/MYNZUyPpf3nKztuC8fS11Im4ziH++b6Yi5zrBpk+AdkBUkJhAQz8K4M=
X-Received: by 2002:a05:6102:32c7:b0:31b:8f98:5fd with SMTP id
 o7-20020a05610232c700b0031b8f9805fdmr7917679vss.24.1646065885559; Mon, 28 Feb
 2022 08:31:25 -0800 (PST)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20220228113910.1727819-1-amir73il@gmail.com> <20220228113910.1727819-5-amir73il@gmail.com>
 <CAJfpegvZefGp9NChm_69Km0FgpxwUs+og-uc2mpMAbH6mZ2azQ@mail.gmail.com> <CAOQ4uxgg8PDweNvkhXE20Gbb+=OGBbwLXjR6Yffc4ZkiKzGM0w@mail.gmail.com>
In-Reply-To: <CAOQ4uxgg8PDweNvkhXE20Gbb+=OGBbwLXjR6Yffc4ZkiKzGM0w@mail.gmail.com>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 28 Feb 2022 17:31:14 +0100
Message-ID: <CAJfpegvnhsBB_Ym3VGs7xBQM3OWsXCsqBZncBVNFCDJXka_AwA@mail.gmail.com>
Subject: Re: [PATCH v2 4/6] fs: report per-mount io stats
To: Amir Goldstein <amir73il@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, overlayfs <linux-unionfs@vger.kernel.org>, 
	containers@lists.linux.dev, linux-fsdevel <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"

On Mon, 28 Feb 2022 at 17:19, Amir Goldstein <amir73il@gmail.com> wrote:
>
> On Mon, Feb 28, 2022 at 5:06 PM Miklos Szeredi <miklos@szeredi.hu> wrote:
> >
> > On Mon, 28 Feb 2022 at 12:39, Amir Goldstein <amir73il@gmail.com> wrote:
> > >
> > > Show optional collected per-mount io stats in /proc/<pid>/mountstats
> > > for filesystems that do not implement their own show_stats() method
> > > and opted-in to generic per-mount stats with FS_MOUNT_STATS flag.
> >
> > This would allow some filesystems to report per-mount I/O stats, while
> > leaving CIFS and NFS reporting a different set of per-sb stats.  This
> > doesn't sound very clean.
> >
> > There was an effort to create saner and more efficient interfaces for
> > per-mount info.  IMO this should be part of that effort instead of
> > overloading the old interface.
> >
>
> That's fair, but actually, I have no much need for per-mount I/O stats
> in overlayfs/fuse use cases, so I could amend the patches to collect and
> show per-sb I/O stats.
>
> Then, the generic show_stats() will not be "overloading the old interface".
> Instead, it will be creating a common implementation to share among different
> filesystems and using an existing vfs interface as it was intended.
>
> Would you be willing to accept adding per-sb I/O stats to overlayfs
> and/or fuse via /proc/<pid>/mountstats?

Yes, that would certainly be more sane.   But I'm also wondering if
there could be some commonality with the stats provided by NFS...

Thanks,
Miklos
