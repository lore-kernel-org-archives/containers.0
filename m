Return-Path: <SRS0=KsZc=FE=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20CA0C64E7B
	for <containers@archiver.kernel.org>; Mon, 30 Nov 2020 23:18:02 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 93DA120725
	for <containers@archiver.kernel.org>; Mon, 30 Nov 2020 23:18:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=kinvolk.io header.i=@kinvolk.io header.b="FjoZwlqR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93DA120725
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kinvolk.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 031CE87217;
	Mon, 30 Nov 2020 23:18:01 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id DxaPI+b4mq2Y; Mon, 30 Nov 2020 23:18:00 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 7587F871A0;
	Mon, 30 Nov 2020 23:18:00 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 556CCC0859;
	Mon, 30 Nov 2020 23:18:00 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 9232EC0052
 for <containers@lists.linux-foundation.org>;
 Mon, 30 Nov 2020 23:17:58 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 845A886D50
 for <containers@lists.linux-foundation.org>;
 Mon, 30 Nov 2020 23:17:58 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id f4pq7yk7JDql
 for <containers@lists.linux-foundation.org>;
 Mon, 30 Nov 2020 23:17:55 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail-lf1-f43.google.com (mail-lf1-f43.google.com
 [209.85.167.43])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 0D80286A94
 for <containers@lists.linux-foundation.org>;
 Mon, 30 Nov 2020 23:17:54 +0000 (UTC)
Received: by mail-lf1-f43.google.com with SMTP id d8so37733lfa.1
 for <containers@lists.linux-foundation.org>;
 Mon, 30 Nov 2020 15:17:54 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kinvolk.io; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=1bDJzC+7/EeDz8Z4TYtcl8pVmXB1VZfQyZ+oFPIZuXs=;
 b=FjoZwlqRl25v3f0bwesiLG6VMDJ0cdT+WZsk9oJG7qotZdfQy3Bnzm/ErkRC6KEF0Q
 V8tXzsGFOERVPlB9fDDUrXunF4OR96Byp7o91ITmQ4f6ghX4OplZA9VRfMBWotgDeDXS
 4fMHVDZZFkLBQZtMZ9inRIOYwvw2PRu8hX+wE=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=1bDJzC+7/EeDz8Z4TYtcl8pVmXB1VZfQyZ+oFPIZuXs=;
 b=iKZxj2+qb9ELYyjv9JqHs6JVkNd2WZBGOz2B06Gwylwa5FoapTYgEjP3IftINnjeGv
 TBcI/5f1zq/tC7bsab0Q1LnG5s0c6NUnsvyv0ckWiw0A8DMZA990gGlcUNp7+TaASrkN
 4aAeoYiWHmsjFUdU0DXHP3QqL0R1/IycHGyn0iQjxzwW7Z9w5zrr/r2eL2aW9UOq39FA
 cLxbIdd1m4R1oGnNf/cULyS6wQ4Rif7YBohyGV+xlG7ApFdoFUx8PBtlEKBe4xi4L4MC
 T27q402ZPAjfg2aa2kPFbXN2M4Ih2O+I1yPAKZi8fh/LVA1+bosqqV9iiMvv9ZK6QgsV
 uRUQ==
X-Gm-Message-State: AOAM533vwlTF2j85HZzHLdJoY3tnibAZUWKhVHhTvdJIjl9tz+U4cqeu
 v7nZHCCouc6CCnlqeNUTuy2jlTd1qoMC3YiI147C3Qou6HCMhzgf
X-Google-Smtp-Source: ABdhPJyMsQBDmsS07l72ppmPq7n5DMn6hdGTx4GyLQK7ar2TSxkO0y0Q1aohyJmtrB+4dMWzWOlvHMr1zq5pbE7LHlg=
X-Received: by 2002:a2e:b386:: with SMTP id f6mr10646917lje.320.1606776619482; 
 Mon, 30 Nov 2020 14:50:19 -0800 (PST)
MIME-Version: 1.0
References: <20201128213527.2669807-1-christian.brauner@ubuntu.com>
 <20201128213527.2669807-33-christian.brauner@ubuntu.com>
In-Reply-To: <20201128213527.2669807-33-christian.brauner@ubuntu.com>
From: =?UTF-8?Q?Mauricio_V=C3=A1squez_Bernal?= <mauricio@kinvolk.io>
Date: Mon, 30 Nov 2020 17:50:08 -0500
Message-ID: <CAHap4zu3wjCqjbxaXbsPqz2Q_oNRm0Q=xQMudPStwN8h92Stcw@mail.gmail.com>
Subject: Re: [PATCH v3 32/38] fat: handle idmapped mounts
To: Christian Brauner <christian.brauner@ubuntu.com>
Cc: Andy Lutomirski <luto@kernel.org>, Mimi Zohar <zohar@linux.ibm.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>, Christoph Hellwig <hch@lst.de>,
 Tycho Andersen <tycho@tycho.ws>, Paul Moore <paul@paul-moore.com>,
 Jonathan Corbet <corbet@lwn.net>, smbarber@chromium.org,
 Christoph Hellwig <hch@infradead.org>,
 Casey Schaufler <casey@schaufler-ca.com>, linux-ext4@vger.kernel.org,
 Mrunal Patel <mpatel@redhat.com>, Kees Cook <keescook@chromium.org>,
 Arnd Bergmann <arnd@arndb.de>, selinux@vger.kernel.org,
 Josh Triplett <josh@joshtriplett.org>,
 Seth Forshee <seth.forshee@canonical.com>, Aleksa Sarai <cyphar@cyphar.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Lennart Poettering <lennart@poettering.net>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>, David Howells <dhowells@redhat.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 containers@lists.linux-foundation.org, fstests@vger.kernel.org,
 linux-security-module@vger.kernel.org,
 "Eric W. Biederman" <ebiederm@xmission.com>, linux-api@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, Alban Crequy <alban@kinvolk.io>,
 linux-integrity@vger.kernel.org,
 Stephen Smalley <stephen.smalley.work@gmail.com>, Todd Kjos <tkjos@google.com>
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

>
> mount2 --idmap both:1000:1001:1
>

Nit: missing arguments to mount2.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
