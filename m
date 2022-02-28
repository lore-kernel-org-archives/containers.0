Received: from mail-il1-f173.google.com (mail-il1-f173.google.com [209.85.166.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6FD937A
	for <containers@lists.linux.dev>; Mon, 28 Feb 2022 17:06:40 +0000 (UTC)
Received: by mail-il1-f173.google.com with SMTP id y5so10447640ill.13
        for <containers@lists.linux.dev>; Mon, 28 Feb 2022 09:06:40 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=yT9BO7LqspGlgx3scrJFgyOokQFAFM+2onJaMqMrNjE=;
        b=Bpl2eRg4BgweC31FKgffeUd8dsL6IerPbWlBrrVCKLBbwk1V/6ikK0M7pGR2Y/VbSj
         9DPu/Q8TYPtZ1lP7a93N0KQ8SsqtsgMC97AlnKFNyKm/fLmqoQ+IemSeyyjcPzlWCCq/
         V02RniZo0X6ig3Y68VUjJ8mnRtbNCWuWDbg/Q3GvXVc4UHPGed3yQGx+oYkdaxT044+P
         gPLo+dQ3qs/ugDaFcyCqT8B0ZdY5OvNuMSOoiYzks0taetWL42eyzzTpmlAKsQHNt5B3
         ypK1hLM6G67O018DkvGprtZfj5Iw6DXgjrhPXLNEdic4lLbPpiYm0rGdnxmWUoDZa48Y
         SGAw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=yT9BO7LqspGlgx3scrJFgyOokQFAFM+2onJaMqMrNjE=;
        b=HJSdQd3R3IZKYebz6uoceaor+q4OX9VroKSFPH6YThriHuYa6xKM8vAwcKGDXaK6n5
         jd/1DZ8nPnN1OuqTMDyEXLRJHrhuEVArplVy2qijAJSv0AA55DemzYiBa1Vkk9HZ7aQK
         4HsenuyPokqiFT5F6E9hIKL8wz2c+CROx1AtM9ctSIMEltKZs3652KorLbyuN3eA9Hva
         G9kB9SyXaFLxX/kKXNUvamw6UJKFdJPA3w5uV27J9BE+BvBZxoXU1fuqlhv6W51q2Bcs
         l9O3pS+AkvuteRgXHIDvq+CKNSOD5sXOZHs2WMB9m4AtHZNbuS8pIF5yKDHcTDplQ1HK
         DOXg==
X-Gm-Message-State: AOAM532UhM0XFwUHTlHS7IU54V3JKE9/Vdhv8ngEsih/kM2mOisJAhK0
	a5S+GG5co0cR8sGS1pff8/1VOON5pK3U5MkmVAEdkpqcCJE=
X-Google-Smtp-Source: ABdhPJwDpld2f9g1ZZXYohkpFIF6uRCef8rrTTHtPcfwwLiC8YFIFot+3c9vivaxwDrxHo6DtETDh48hlWwRbxXA6SE=
X-Received: by 2002:a05:6e02:214a:b0:2bf:a442:cbff with SMTP id
 d10-20020a056e02214a00b002bfa442cbffmr20398650ilv.107.1646067999554; Mon, 28
 Feb 2022 09:06:39 -0800 (PST)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20220228113910.1727819-1-amir73il@gmail.com> <20220228113910.1727819-5-amir73il@gmail.com>
 <CAJfpegvZefGp9NChm_69Km0FgpxwUs+og-uc2mpMAbH6mZ2azQ@mail.gmail.com>
 <CAOQ4uxgg8PDweNvkhXE20Gbb+=OGBbwLXjR6Yffc4ZkiKzGM0w@mail.gmail.com> <CAJfpegvnhsBB_Ym3VGs7xBQM3OWsXCsqBZncBVNFCDJXka_AwA@mail.gmail.com>
In-Reply-To: <CAJfpegvnhsBB_Ym3VGs7xBQM3OWsXCsqBZncBVNFCDJXka_AwA@mail.gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Mon, 28 Feb 2022 19:06:28 +0200
Message-ID: <CAOQ4uxh=VEsspfEyxc8c6V72LJX9_nU1NSfaptsig=k8z7NOkg@mail.gmail.com>
Subject: Re: [PATCH v2 4/6] fs: report per-mount io stats
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Al Viro <viro@zeniv.linux.org.uk>, overlayfs <linux-unionfs@vger.kernel.org>, 
	containers@lists.linux.dev, linux-fsdevel <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"

On Mon, Feb 28, 2022 at 6:31 PM Miklos Szeredi <miklos@szeredi.hu> wrote:
>
> On Mon, 28 Feb 2022 at 17:19, Amir Goldstein <amir73il@gmail.com> wrote:
> >
> > On Mon, Feb 28, 2022 at 5:06 PM Miklos Szeredi <miklos@szeredi.hu> wrote:
> > >
> > > On Mon, 28 Feb 2022 at 12:39, Amir Goldstein <amir73il@gmail.com> wrote:
> > > >
> > > > Show optional collected per-mount io stats in /proc/<pid>/mountstats
> > > > for filesystems that do not implement their own show_stats() method
> > > > and opted-in to generic per-mount stats with FS_MOUNT_STATS flag.
> > >
> > > This would allow some filesystems to report per-mount I/O stats, while
> > > leaving CIFS and NFS reporting a different set of per-sb stats.  This
> > > doesn't sound very clean.
> > >
> > > There was an effort to create saner and more efficient interfaces for
> > > per-mount info.  IMO this should be part of that effort instead of
> > > overloading the old interface.
> > >
> >
> > That's fair, but actually, I have no much need for per-mount I/O stats
> > in overlayfs/fuse use cases, so I could amend the patches to collect and
> > show per-sb I/O stats.
> >
> > Then, the generic show_stats() will not be "overloading the old interface".
> > Instead, it will be creating a common implementation to share among different
> > filesystems and using an existing vfs interface as it was intended.
> >
> > Would you be willing to accept adding per-sb I/O stats to overlayfs
> > and/or fuse via /proc/<pid>/mountstats?
>
> Yes, that would certainly be more sane.   But I'm also wondering if
> there could be some commonality with the stats provided by NFS...
>

hmm, maybe, but look:

device genesis:/shares/media mounted on /mnt/nfs with fstype nfs4 statvers=1.1
opts: rw,vers=4.2,rsize=1048576,wsize=1048576,namlen=255,acregmin=3,acregmax=60,acdirmin=30,acdirmax=60,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=192.168.122.1,local_lock=none
age: 38
impl_id: name='',domain='',date='0,0'
caps: caps=0x3ffbffff,wtmult=512,dtsize=32768,bsize=0,namlen=255
nfsv4: bm0=0xfdffbfff,bm1=0xf9be3e,bm2=0x68800,acl=0x3,sessions,pnfs=not
configured,lease_time=90,lease_expired=0
sec: flavor=1,pseudoflavor=1
events: 0 0 0 0 0 2 4 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
bytes: 0 0 0 0 0 0 0 0
RPC iostats version: 1.1  p/v: 100003/4 (nfs)
xprt: tcp 0 0 2 0 38 27 27 0 27 0 2 0 0
per-op statistics
       NULL: 1 1 0 44 24 0 0 0 0
       READ: 0 0 0 0 0 0 0 0 0
       WRITE: 0 0 0 0 0 0 0 0 0
       COMMIT: 0 0 0 0 0 0 0 0 0
       OPEN: 0 0 0 0 0 0 0 0 0
       OPEN_CONFIRM: 0 0 0 0 0 0 0 0 0
       OPEN_NOATTR: 0 0 0 0 0 0 0 0 0
       OPEN_DOWNGRADE: 0 0 0 0 0 0 0 0 0
       CLOSE: 0 0 0 0 0 0 0 0 0
       ...

Those stats are pretty specific to NFS.
Most of it is RPC protocol stats, not including cached /I/O stats,
so in fact the generic collected io stats could be added to nfs_show_stats()
and they will not break the <tag>:<value> format.

I used the same output format as /proc/<pid>/io for a reason.
The iotop utility parses /proc/<pid>/io to display io per task and
also displays total io stats for block devices.

I am envisioning an extended version of iotop (-m ?) that also
displays total iostats per mount/sb, when available.

Thanks,
Amir.
