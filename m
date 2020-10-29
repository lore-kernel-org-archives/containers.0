Return-Path: <SRS0=MeFG=EE=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42443C5DF9D
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 16:36:22 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6F83B20825
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 16:36:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=sargun.me header.i=@sargun.me header.b="ipmMYI2Z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F83B20825
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sargun.me
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 0483C8755B;
	Thu, 29 Oct 2020 16:36:21 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id giVon5JM+HNa; Thu, 29 Oct 2020 16:36:20 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 582DE87551;
	Thu, 29 Oct 2020 16:36:20 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 3FD51C0859;
	Thu, 29 Oct 2020 16:36:20 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 27607C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 16:36:18 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 152C18755B
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 16:36:18 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id dlTRWmbgYeOm
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 16:36:16 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail-il1-f193.google.com (mail-il1-f193.google.com
 [209.85.166.193])
 by hemlock.osuosl.org (Postfix) with ESMTPS id ACEAB87551
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 16:36:16 +0000 (UTC)
Received: by mail-il1-f193.google.com with SMTP id p10so3699599ile.3
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 09:36:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sargun.me; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to:user-agent;
 bh=+1FzFFklP1YnmghHH9t5lyMT4QSfeCr4QK0lMLwAvZE=;
 b=ipmMYI2Zt/qFpfzA3A9nrn+MY99z/pArhalXX282jU89E0zmQx8CrbLcgUJ0+4BBYr
 gOYagLL2brYfKfSk0M5bDwNOwtJPX2R0TTPBFpS1s+gFhezEv2lm2yr3dsX1V9pnC8ie
 xjQ02ffBZ46hYZ46v5xkCdBsw/A1eNnXgRfJA=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to:user-agent;
 bh=+1FzFFklP1YnmghHH9t5lyMT4QSfeCr4QK0lMLwAvZE=;
 b=nsxulvNQHLaRRFQA0qd8FsMz/U327SwymRQotcjNAUwcoAy4jRbLkpxIGtTvO/f6MJ
 mQNHhlStM9E9NtQQw8z4MNd7/KHmaxQTSwLjGUklOkUmVY3Zf16Pu591GyvhrQY6gdA5
 oF9pbQ9s/bYd+odGcV2Bn3fDmFK7FqQv1jY7a4J/JLdgax4QNlkWMbLPe0Zb8aWU5yvn
 E1vVeF2s/DxfZsQoDtB+os+3tzBjlvBAq09PEG09VhNCrFdSW//pRNtmI5crHOeo7uRL
 aN6KhCQvCbS2SYLZvnnGbdy0nQf1C0kBPp0/drrZXA/G/3D1YQAvVmkHgZfduuJT2huC
 pFcg==
X-Gm-Message-State: AOAM531mpKGlJTXasTt1XCwtLPdkLEpxgQKo1VGRrxqPMsfr98MSBoNi
 EJHZWaGDjx8I+d2TvX/EoeeZgA==
X-Google-Smtp-Source: ABdhPJwdjJsI8P3ncUgKVI0MZeddl6/4SUR4eqZ1yA/w3w9keNoMZjKAVre0rxJASmFJuoRVIJjAng==
X-Received: by 2002:a92:c7c7:: with SMTP id g7mr3777623ilk.303.1603989375791; 
 Thu, 29 Oct 2020 09:36:15 -0700 (PDT)
Received: from ircssh-2.c.rugged-nimbus-611.internal
 (80.60.198.104.bc.googleusercontent.com. [104.198.60.80])
 by smtp.gmail.com with ESMTPSA id t6sm2275768ilk.5.2020.10.29.09.36.14
 (version=TLS1_2 cipher=ECDHE-ECDSA-CHACHA20-POLY1305 bits=256/256);
 Thu, 29 Oct 2020 09:36:14 -0700 (PDT)
Date: Thu, 29 Oct 2020 16:36:13 +0000
From: Sargun Dhillon <sargun@sargun.me>
To: Lennart Poettering <lennart@poettering.net>
Subject: Re: [PATCH 00/34] fs: idmapped mounts
Message-ID: <20201029163612.GA15275@ircssh-2.c.rugged-nimbus-611.internal>
References: <20201029003252.2128653-1-christian.brauner@ubuntu.com>
 <87pn51ghju.fsf@x220.int.ebiederm.org>
 <20201029160502.GA333141@gardel-login>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20201029160502.GA333141@gardel-login>
User-Agent: Mutt/1.9.4 (2018-02-28)
Cc: Mimi Zohar <zohar@linux.ibm.com>, David Howells <dhowells@redhat.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Tycho Andersen <tycho@tycho.ws>,
 Miklos Szeredi <miklos@szeredi.hu>, smbarber@chromium.org,
 Christoph Hellwig <hch@infradead.org>, linux-ext4@vger.kernel.org,
 Mrunal Patel <mpatel@redhat.com>, Kees Cook <keescook@chromium.org>,
 Arnd Bergmann <arnd@arndb.de>, Jann Horn <jannh@google.com>,
 selinux@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>,
 linux-fsdevel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>,
 Andy Lutomirski <luto@kernel.org>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Seth Forshee <seth.forshee@canonical.com>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 Stephen Smalley <stephen.smalley.work@gmail.com>,
 Jonathan Corbet <corbet@lwn.net>, linux-unionfs@vger.kernel.org,
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

On Thu, Oct 29, 2020 at 05:05:02PM +0100, Lennart Poettering wrote:
> On Do, 29.10.20 10:47, Eric W. Biederman (ebiederm@xmission.com) wrote:
> 
> > Is that the use case you are looking at removing the need for
> > systemd-homed to avoid chowning after lugging encrypted home directories
> > from one system to another?  Why would it be desirable to avoid the
> > chown?
> 
> Yes, I am very interested in seeing Christian's work succeed, for the
> usecase in systemd-homed. In systemd-homed each user gets their own
> private file system, and these fs shall be owned by the user's local
> UID, regardless in which system it is used. The UID should be an
> artifact of the local, individual system in this model, and thus
> the UID on of the same user/home on system A might be picked as 1010
> and on another as 1543, and on a third as 1323, and it shouldn't
> matter. This way, home directories become migratable without having to
> universially sync UID assignments: it doesn't matter anymore what the
> local UID is.
> 
> Right now we do a recursive chown() at login time to ensure the home
> dir is properly owned. This has two disadvantages:
> 
> 1. It's slow. In particular on large home dirs, it takes a while to go
>    through the whole user's homedir tree and chown/adjust ACLs for
>    everything.
> 
> 2. Because it is so slow we take a shortcut right now: if the
>    top-level home dir inode itself is owned by the correct user, we
>    skip the recursive chowning. This means in the typical case where a
>    user uses the same system most of the time, and thus the UID is
>    stable we can avoid the slowness. But this comes at a drawback: if
>    the user for some reason ends up with files in their homedir owned
>    by an unrelated user, then we'll never notice or readjust.
> 
> > If the goal is to solve fragmented administration of uid assignment I
> > suggest that it might be better to solve the administration problem so
> > that all of the uids of interest get assigned the same way on all of the
> > systems of interest.
> 
> Well, the goal is to make things simple and be able to use the home
> dir everywhere without any prior preparation, without central UID
> assignment authority.
> 
> The goal is to have a scheme that requires no administration, by
> making the UID management problem go away. Hence, if you suggest
> solving this by having a central administrative authority: this is
> exactly what the model wants to get away from.
> 
> Or to say this differently: just because I personally use three
> different computers, I certainly don't want to set up LDAP or sync
> UIDs manually.
> 
> Lennart
> 
> --
> Lennart Poettering, Berlin

Can you help me understand systemd-homed a little bit?

In the man page it says:

systemd-homed is a system service that may be used to create, remove, change or 
inspect home areas (directories and network mounts and real or loopback block 
devices with a filesystem, optionally encrypted).

It seems that the "underlay?" (If you'll call it that, maybe there is a better 
term) can either be a standalone block device (this sounds close to systemd 
machined?), a btrfs subvolume (which receives its own superblock (IIRC?, I might 
be wrong. It's been a while since I've used btrfs), or just be a directory 
that's mapped?

What decides whether it's just a directory and bind-mounted (or a similar 
vfsmount), or an actual superblock?

How is the mapping of "real UIDs" to "namespace UIDs" works when it's just a 
bind mount? From the perspective of multiple user namespaces, are all 
"underlying" UIDs mapped through, or if I try to look at another user's
home directory will they not show up?

Is there a reason you can't / don't / wont use overlayfs instead of bind mounts?
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
