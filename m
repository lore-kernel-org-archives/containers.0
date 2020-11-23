Return-Path: <SRS0=EloL=E5=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A934C2D0E4
	for <containers@archiver.kernel.org>; Mon, 23 Nov 2020 22:07:04 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id D711C2065E
	for <containers@archiver.kernel.org>; Mon, 23 Nov 2020 22:07:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=paul-moore-com.20150623.gappssmtp.com header.i=@paul-moore-com.20150623.gappssmtp.com header.b="Ihm9gWe+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D711C2065E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=paul-moore.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 44D7C86FCF;
	Mon, 23 Nov 2020 22:07:03 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id AK8YTKdrMvCI; Mon, 23 Nov 2020 22:07:02 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id C299586F90;
	Mon, 23 Nov 2020 22:07:02 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id A9DE9C163C;
	Mon, 23 Nov 2020 22:07:02 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 0F28DC0052
 for <containers@lists.linux-foundation.org>;
 Mon, 23 Nov 2020 22:07:01 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 09E2786FCF
 for <containers@lists.linux-foundation.org>;
 Mon, 23 Nov 2020 22:07:01 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id PLeTdzvHrdJ2
 for <containers@lists.linux-foundation.org>;
 Mon, 23 Nov 2020 22:07:00 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ed1-f66.google.com (mail-ed1-f66.google.com
 [209.85.208.66])
 by hemlock.osuosl.org (Postfix) with ESMTPS id C83F986F90
 for <containers@lists.linux-foundation.org>;
 Mon, 23 Nov 2020 22:06:59 +0000 (UTC)
Received: by mail-ed1-f66.google.com with SMTP id r22so10085382edw.6
 for <containers@lists.linux-foundation.org>;
 Mon, 23 Nov 2020 14:06:59 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=paul-moore-com.20150623.gappssmtp.com; s=20150623;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=ArDHvUzfUiZzh94W960BgkUJZn/5DnacTXHC4Nbv9kI=;
 b=Ihm9gWe+6m2iCUrCqSrzj2hxvAUOkkHpCGtwhE41f3Rdh8c80xsJegtLMifcQSq7l4
 MQxmEg8qFYnoifRMupAHJLQd5lYZm+n6GzQdGqoyCuHFxDt3fXMsW4siDYXty7uFQyR+
 ZiLBHsJEHGtWXoprHv+EbMvUbaSfI62VdYDnQ6kSau+U/tc34IQsesxRL2sYZY1EAFs1
 LsTOG7yiGz9YGo+XzQObpUnu50coOcAWET1QWObW0HN2FliSyDT2/hew7cMEOL8j6Rt4
 CkHD0bLpWTrv0L4vHLaw7qmLF7A/4zumynmI5rzULQJ1fukCf4JWCo9n/ipboGbcKUNv
 ClRg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=ArDHvUzfUiZzh94W960BgkUJZn/5DnacTXHC4Nbv9kI=;
 b=tZTi7AYYzCBjswnYzYnJpqj9fOg9TAbl2SR6JL3jGviDqbuAGkFW7/6RPZUXRW1L8/
 Y2w+281RVCpjZ3ucqhv9DST6l3qCSZhGe4p18broAy0bLEBiOuGL8zZ8Hv+DmVDWjpe/
 v+kIJ0AGQRdknIBahsHGjhTQvl9KPUJn5rhWpU0QlgLG7KiAAdAR7M/hdhR81VQI37bl
 XpgCuAzzx5hO7Zc+uF8d5b0UA9YoKUENZ5GY/NJimI0ozNWs8gJbepr9TB/ywclPGhIk
 9vh+tDPl5wc51WIfh7KkG2yLuW/KwAQjF/Kg1DDORskgkqUjV9PHDeuAdUw0dBgTCYfj
 V0GA==
X-Gm-Message-State: AOAM533QcOjn0z8rYTQ0cKaZV+A8uoB2Ca7PS3RVT+NDOXAuxC8x5Xav
 FcLmD4oj2QP9C5fo08ixvhztm16gARlvF9mMFbIA
X-Google-Smtp-Source: ABdhPJyCGu6X9xaHoLXWBbQARSvPVPAoR3jFBNgP4UppEnyulyojvZlb/ppHqsSx8lMhDFxNpQsOSthLAo4GmR/YyTM=
X-Received: by 2002:a50:a6d0:: with SMTP id f16mr1171069edc.135.1606169217904; 
 Mon, 23 Nov 2020 14:06:57 -0800 (PST)
MIME-Version: 1.0
References: <20201115103718.298186-1-christian.brauner@ubuntu.com>
 <20201115103718.298186-32-christian.brauner@ubuntu.com>
 <CAHC9VhQ5gcOa0+KKDtKEgg_v4SZV2hPdaKUbPGJAQrVB8mn0jA@mail.gmail.com>
 <20201123074157.fqus6fgtcytydp2c@wittgenstein>
In-Reply-To: <20201123074157.fqus6fgtcytydp2c@wittgenstein>
From: Paul Moore <paul@paul-moore.com>
Date: Mon, 23 Nov 2020 17:06:46 -0500
Message-ID: <CAHC9VhTrYDEAkaLbwtF7hQS=8HpM4wx7A_fN4=9pL6EAM-KPGw@mail.gmail.com>
Subject: Re: [PATCH v2 31/39] audit: handle idmapped mounts
To: Christian Brauner <christian.brauner@ubuntu.com>
Cc: Lennart Poettering <lennart@poettering.net>,
 Mimi Zohar <zohar@linux.ibm.com>, David Howells <dhowells@redhat.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Tycho Andersen <tycho@tycho.ws>,
 Jonathan Corbet <corbet@lwn.net>, smbarber@chromium.org,
 Christoph Hellwig <hch@infradead.org>, linux-ext4@vger.kernel.org,
 Mrunal Patel <mpatel@redhat.com>, Kees Cook <keescook@chromium.org>,
 Arnd Bergmann <arnd@arndb.de>, Jann Horn <jannh@google.com>,
 selinux@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>,
 linux-fsdevel@vger.kernel.org, Aleksa Sarai <cyphar@cyphar.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Seth Forshee <seth.forshee@canonical.com>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 Stephen Smalley <stephen.smalley.work@gmail.com>,
 linux-security-module@vger.kernel.org, linux-audit@redhat.com,
 "Eric W. Biederman" <ebiederm@xmission.com>, linux-api@vger.kernel.org,
 Casey Schaufler <casey@schaufler-ca.com>, Alban Crequy <alban@kinvolk.io>,
 linux-integrity@vger.kernel.org, Todd Kjos <tkjos@google.com>
X-BeenThere: containers@lists.linux-foundation.org
X-Mailman-Version: 2.1.15
Precedence: list
List-Id: Linux Containers <containers.lists.linuxfoundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers@lists.linux-foundation.org>
List-Help: <mailto:containers-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Mon, Nov 23, 2020 at 2:42 AM Christian Brauner
<christian.brauner@ubuntu.com> wrote:
> On Sun, Nov 22, 2020 at 05:17:39PM -0500, Paul Moore wrote:
> > On Sun, Nov 15, 2020 at 5:43 AM Christian Brauner
> > <christian.brauner@ubuntu.com> wrote:
> > >
> > > Audit will sometimes log the inode's i_uid and i_gid. Enable audit to log the
> > > mapped inode when it is accessed from an idmapped mount.
> >
> > I mentioned this in an earlier patch in this patchset, but it is worth
>
> I did not receive that message.

I'm guessing just a slow mail relay somewhere as you responded to both
of my emails on this patchset, I think we're all set for now :)

Thanks.

-- 
paul moore
www.paul-moore.com
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
