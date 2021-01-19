Return-Path: <SRS0=TkuO=GW=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FCB5C433E0
	for <containers@archiver.kernel.org>; Tue, 19 Jan 2021 15:05:38 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id E79A22250E
	for <containers@archiver.kernel.org>; Tue, 19 Jan 2021 15:05:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E79A22250E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id A7C2D86F80;
	Tue, 19 Jan 2021 15:05:37 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id B5UXFClVA8L7; Tue, 19 Jan 2021 15:05:37 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 2240486F7D;
	Tue, 19 Jan 2021 15:05:37 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 0AD49C088B;
	Tue, 19 Jan 2021 15:05:37 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id F30EAC013A
 for <containers@lists.linux-foundation.org>;
 Tue, 19 Jan 2021 15:05:35 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id E14B2204E4
 for <containers@lists.linux-foundation.org>;
 Tue, 19 Jan 2021 15:05:35 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 660YDf3Xa+kt
 for <containers@lists.linux-foundation.org>;
 Tue, 19 Jan 2021 15:05:31 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-lf1-f46.google.com (mail-lf1-f46.google.com
 [209.85.167.46])
 by silver.osuosl.org (Postfix) with ESMTPS id 5DDFB20477
 for <containers@lists.linux-foundation.org>;
 Tue, 19 Jan 2021 15:05:29 +0000 (UTC)
Received: by mail-lf1-f46.google.com with SMTP id h7so260125lfc.6
 for <containers@lists.linux-foundation.org>;
 Tue, 19 Jan 2021 07:05:29 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=gOmgvCPsNvi85/TpBsHHlznh/AXeaDwbv8LGPCZK7GU=;
 b=jHOv7ZfcUJDyBrUH8oJXnGIi8zR/GVQigV9JsU3VOD2zVPzE8Qi8FcxCv3RN2B9A6r
 xugkjyegXRk25clhQPkHPl6Bgq5is0HjaMKTdere1dxwfXiSoujavM6bCqwMy7DZTLAY
 XzwyrYIOx+UbZ4taCEFKeVgvzFkPqWMiBrHN0cesc58X2THa+V2gdhqFGvQ0m5hl69PP
 86p4cNSHXci62Q5bRCDCUjqJlCKurpnZ2KQ8/bUtutXFEHhOZcuBiBOGHUyG7S3P/OJ0
 UhrskVG5YmmxTBCZMbabr3ZIzMkK81tYRiWGV1k3KMjBXOmM5Zrq6ssCUVgGucgyhjVM
 mc6A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=gOmgvCPsNvi85/TpBsHHlznh/AXeaDwbv8LGPCZK7GU=;
 b=ITNZ0AeVRdl0Q8eQrDilipYRsM1cGNGgKk7df7Rbx9lt33hlgjR1p/ErAwSPPD6oKd
 2ab6yHKmhHxsoDnWvo0jdUitHr1uNrqL6X3/Zjdc10EOcqXfhUyKFO6RMiKs4909D4SR
 c5rVfWD18YmXVobh35unZv5XfVicubpH+g3xq6Yx4WNMXqj5f6+jMyCGJk+SAVXRKMln
 oiFEQOR3FuvvuoTUIOd4PATC0KT1qdr6XT/bW4dkb25UO07H63PF2ZBVeOkAzsCpLD5p
 Y4EILhp+/RNKW9/kh9vT/60WSyNpHv9zdt4BP0P2agyuqWAfY4DQRIsWAwPD7Qy3BTnC
 ZjkA==
X-Gm-Message-State: AOAM532ERpEK3knWqayhIvcy89xUreJ2KkJizaUD+afBISX1wwApmRmh
 jY3UBwdBtNKgqrOkhHtpuLUNfeBv+9S1Axgz37LzbQ==
X-Google-Smtp-Source: ABdhPJxFxS+hG4x6TwLiOwPtHwa+9Zao0MvjeAr8yET1CRB9c/HolYwSYvtkLR07E5CI/h61T92ZT6GwaxlT4i6ykfk=
X-Received: by 2002:a19:197:: with SMTP id 145mr2043470lfb.352.1611068727150; 
 Tue, 19 Jan 2021 07:05:27 -0800 (PST)
MIME-Version: 1.0
References: <20210112220124.837960-1-christian.brauner@ubuntu.com>
 <20210112220124.837960-16-christian.brauner@ubuntu.com>
In-Reply-To: <20210112220124.837960-16-christian.brauner@ubuntu.com>
Date: Tue, 19 Jan 2021 16:05:00 +0100
Message-ID: <CAG48ez3Ccr77+zH56YGimESf9jdy_xnQrebypn1TXEP3Q+xw=w@mail.gmail.com>
Subject: Re: [PATCH v5 15/42] fs: add file_user_ns() helper
To: Christian Brauner <christian.brauner@ubuntu.com>
Cc: Lennart Poettering <lennart@poettering.net>,
 Mimi Zohar <zohar@linux.ibm.com>, David Howells <dhowells@redhat.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Christoph Hellwig <hch@lst.de>, Tycho Andersen <tycho@tycho.ws>,
 Paul Moore <paul@paul-moore.com>, Jonathan Corbet <corbet@lwn.net>,
 Stephen Barber <smbarber@chromium.org>, Christoph Hellwig <hch@infradead.org>,
 Alban Crequy <alban@kinvolk.io>,
 Ext4 Developers List <linux-ext4@vger.kernel.org>,
 Mrunal Patel <mpatel@redhat.com>, Kees Cook <keescook@chromium.org>,
 Arnd Bergmann <arnd@arndb.de>, SElinux list <selinux@vger.kernel.org>,
 Josh Triplett <josh@joshtriplett.org>,
 Seth Forshee <seth.forshee@canonical.com>, Aleksa Sarai <cyphar@cyphar.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 Stephen Smalley <stephen.smalley.work@gmail.com>, linux-xfs@vger.kernel.org,
 linux-security-module <linux-security-module@vger.kernel.org>,
 "Eric W. Biederman" <ebiederm@xmission.com>,
 Linux API <linux-api@vger.kernel.org>,
 Casey Schaufler <casey@schaufler-ca.com>,
 linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-integrity@vger.kernel.org,
 Linus Torvalds <torvalds@linux-foundation.org>, Todd Kjos <tkjos@google.com>
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
From: Jann Horn via Containers <containers@lists.linux-foundation.org>
Reply-To: Jann Horn <jannh@google.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Wed, Jan 13, 2021 at 1:52 AM Christian Brauner
<christian.brauner@ubuntu.com> wrote:
> Add a simple helper to retrieve the user namespace associated with the
> vfsmount of a file. Christoph correctly points out that this makes
> codepaths (e.g. ioctls) way easier to follow that would otherwise
> dereference via mnt_user_ns(file->f_path.mnt).
>
> In order to make file_user_ns() static inline we'd need to include
> mount.h in either file.h or fs.h which seems undesirable so let's simply
> not force file_user_ns() to be inline.
[...]
> +struct user_namespace *file_user_ns(struct file *file)
> +{
> +       return mnt_user_ns(file->f_path.mnt);
> +}

That name is confusing to me, because when I think of "the userns of a
file", it's file->f_cred->user_ns. There are a bunch of places that
look at that, as you can see from grepping for "f_cred->user_ns".

If you really want this to be a separate helper, can you maybe give it
a clearer name? file_mnt_user_ns(), or something like that, idk.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
