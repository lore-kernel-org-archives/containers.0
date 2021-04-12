Return-Path: <SRS0=RCTg=JJ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7901C4363E
	for <containers@archiver.kernel.org>; Mon, 12 Apr 2021 16:30:49 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 444776128E
	for <containers@archiver.kernel.org>; Mon, 12 Apr 2021 16:30:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 444776128E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp1.osuosl.org (Postfix) with ESMTP id 19ABB83C91;
	Mon, 12 Apr 2021 16:30:49 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
	by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id SvWTlTV-00ZT; Mon, 12 Apr 2021 16:30:48 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp1.osuosl.org (Postfix) with ESMTP id 1722D83C20;
	Mon, 12 Apr 2021 16:30:48 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id E5458C000B;
	Mon, 12 Apr 2021 16:30:47 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [IPv6:2605:bc80:3010::136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 1BFC3C000A
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Apr 2021 16:30:46 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp3.osuosl.org (Postfix) with ESMTP id F1135605A4
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Apr 2021 16:30:45 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp3.osuosl.org (amavisd-new);
 dkim=pass (1024-bit key) header.d=linux-foundation.org
Received: from smtp3.osuosl.org ([127.0.0.1])
 by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id KiSTKaAp5-1V
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Apr 2021 16:30:45 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-lf1-x134.google.com (mail-lf1-x134.google.com
 [IPv6:2a00:1450:4864:20::134])
 by smtp3.osuosl.org (Postfix) with ESMTPS id 24CF1600C6
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Apr 2021 16:30:45 +0000 (UTC)
Received: by mail-lf1-x134.google.com with SMTP id w8so13882933lfr.0
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Apr 2021 09:30:44 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=linux-foundation.org; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=ueR+bzUQyBJ6Gmj9fHXIfDenKkhbJd11CuntNjq4ue8=;
 b=Al2PuI8Jtpzy/NwLxwtBoFYmkJnS/LiklYzPs1W31opZKivVBizLwtQrhvdcCOzNgl
 iFR4SpalKqJenVbjbDxeUakPBfXOWawua9ad3aoLoJ6u71vmqNsjc2z07HewEM5RCZnE
 537Yq4lD1OJ7BIDIr0AJhjMl3v314MH/ZEs9g=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=ueR+bzUQyBJ6Gmj9fHXIfDenKkhbJd11CuntNjq4ue8=;
 b=aLfroEwq0UTFiusN7BFxvcNIh5sBFbC9J+N5fC6Ln4jPpK3hbXqmGzAPx5KamDK1SW
 7vFW+G0aPuCwoS6W9i0r8inWKR7LP2aCtpQypu3ugW5WKEmNnMoidoYN3AdlzitI4jfg
 G+tSG8iujYfoepxsn5SW2L0667bjH+r3zpI2XSiw5riKf6OMlnB9eJ+C/IZRc5xe2tw1
 vKlFioAgaIyG2rjwUoi6N/Ev81LweoKb2syNouUg2kuTrCABRJBnmW3WbPndBmRJf+/q
 SP8Nfhu7aFsZejfSgpAO0r+3Bl5YV/Hucs9cDgj0guQSs25AjgSvhwvXMju938aHO4Aj
 Z0NQ==
X-Gm-Message-State: AOAM532KdIV91E/nO0jauXr9QpccBNWFZ3Ujow//RyNcLzsHL9C7r2cU
 7r/LVsfm171DCDFG7ueHtfhTYl2RPdVHhipAxDg=
X-Google-Smtp-Source: ABdhPJznNO/jlyo2sMVWd35GrB7ToPM/ioWKVdKdWtvtZAUpdkqoZdFA0ZczCOpR4HMW+AiRt+CROw==
X-Received: by 2002:a05:6512:3b82:: with SMTP id
 g2mr8105956lfv.499.1618245042897; 
 Mon, 12 Apr 2021 09:30:42 -0700 (PDT)
Received: from mail-lf1-f42.google.com (mail-lf1-f42.google.com.
 [209.85.167.42])
 by smtp.gmail.com with ESMTPSA id r6sm2528336lfn.27.2021.04.12.09.30.42
 for <containers@lists.linux-foundation.org>
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Mon, 12 Apr 2021 09:30:42 -0700 (PDT)
Received: by mail-lf1-f42.google.com with SMTP id n138so22439070lfa.3
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Apr 2021 09:30:42 -0700 (PDT)
X-Received: by 2002:a05:6512:31c7:: with SMTP id
 j7mr10731751lfe.41.1618244634563; 
 Mon, 12 Apr 2021 09:23:54 -0700 (PDT)
MIME-Version: 1.0
References: <E901E25F-41FA-444D-B3C7-A7A786DDD5D5@tuxera.com>
In-Reply-To: <E901E25F-41FA-444D-B3C7-A7A786DDD5D5@tuxera.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 12 Apr 2021 09:23:38 -0700
X-Gmail-Original-Message-ID: <CAHk-=wiXqbSgqzv53C98sbaHVqpc+c8NZTpXC7bBMQT3OznE4g@mail.gmail.com>
Message-ID: <CAHk-=wiXqbSgqzv53C98sbaHVqpc+c8NZTpXC7bBMQT3OznE4g@mail.gmail.com>
Subject: Re: [PATCH v6 24/40] fs: make helpers idmap mount aware
To: Anton Altaparmakov <anton@tuxera.com>
Cc: "luto@kernel.org" <luto@kernel.org>,
 "zohar@linux.ibm.com" <zohar@linux.ibm.com>,
 "dhowells@redhat.com" <dhowells@redhat.com>,
 "alban@kinvolk.io" <alban@kinvolk.io>, "hch@lst.de" <hch@lst.de>,
 "tycho@tycho.ws" <tycho@tycho.ws>, "paul@paul-moore.com" <paul@paul-moore.com>,
 "corbet@lwn.net" <corbet@lwn.net>,
 "smbarber@chromium.org" <smbarber@chromium.org>,
 "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
 "mpatel@redhat.com" <mpatel@redhat.com>,
 "keescook@chromium.org" <keescook@chromium.org>,
 "arnd@arndb.de" <arnd@arndb.de>,
 "selinux@vger.kernel.org" <selinux@vger.kernel.org>,
 "josh@joshtriplett.org" <josh@joshtriplett.org>,
 "casey@schaufler-ca.com" <casey@schaufler-ca.com>,
 "cyphar@cyphar.com" <cyphar@cyphar.com>,
 "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
 "lennart@poettering.net" <lennart@poettering.net>,
 "hirofumi@mail.parknet.co.jp" <hirofumi@mail.parknet.co.jp>,
 "geofft@ldpreload.com" <geofft@ldpreload.com>,
 "James.Bottomley@hansenpartnership.com"
 <James.Bottomley@hansenpartnership.com>,
 "john.johansen@canonical.com" <john.johansen@canonical.com>,
 "tytso@mit.edu" <tytso@mit.edu>,
 "seth.forshee@canonical.com" <seth.forshee@canonical.com>,
 "dmitry.kasatkin@gmail.com" <dmitry.kasatkin@gmail.com>,
 "containers@lists.linux-foundation.org"
 <containers@lists.linux-foundation.org>,
 "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>,
 "linux-security-module@vger.kernel.org"
 <linux-security-module@vger.kernel.org>,
 "ebiederm@xmission.com" <ebiederm@xmission.com>,
 "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>,
 "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
 "adilger.kernel@dilger.ca" <adilger.kernel@dilger.ca>,
 "linux-integrity@vger.kernel.org" <linux-integrity@vger.kernel.org>,
 "stephen.smalley.work@gmail.com" <stephen.smalley.work@gmail.com>,
 "tkjos@google.com" <tkjos@google.com>
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

On Mon, Apr 12, 2021 at 5:05 AM Anton Altaparmakov <anton@tuxera.com> wrote:
>
> Shouldn't that be using mnt_userns instead of &init_user_ns both for the setattr_prepare() and setattr_copy() calls?

It doesn't matter for a filesystem that hasn't marked itself as
supporting idmaps.

If the filesystem doesn't set FS_ALLOW_IDMAP, then mnt_userns is
always going to be &init_user_ns.

That said, I don't think you are wrong - it would probably be a good
idea to pass down the 'mnt_userns' argument just to avoid confusion.
But if you look at the history, you'll see that adding the mount
namespace argument to the helper functions (like setattr_copy())
happened before the actual "switch the filesystem setattr() function
over to get the namespace argument".

So the current situation is partly an artifact of how the incremental
filesystem changes were done.

           Linus
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
