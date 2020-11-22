Return-Path: <SRS0=BFUz=E4=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24B50C5519F
	for <containers@archiver.kernel.org>; Sun, 22 Nov 2020 22:17:59 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 83EF220758
	for <containers@archiver.kernel.org>; Sun, 22 Nov 2020 22:17:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=paul-moore-com.20150623.gappssmtp.com header.i=@paul-moore-com.20150623.gappssmtp.com header.b="IsIYVTGV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83EF220758
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=paul-moore.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 1007920352;
	Sun, 22 Nov 2020 22:17:57 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id BZDhgyWh0w3J; Sun, 22 Nov 2020 22:17:55 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 1FA7F20029;
	Sun, 22 Nov 2020 22:17:55 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 00ADAC163C;
	Sun, 22 Nov 2020 22:17:55 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id AA7E9C0052
 for <containers@lists.linux-foundation.org>;
 Sun, 22 Nov 2020 22:17:53 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 8F65085A37
 for <containers@lists.linux-foundation.org>;
 Sun, 22 Nov 2020 22:17:53 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id N30RUWDmvx30
 for <containers@lists.linux-foundation.org>;
 Sun, 22 Nov 2020 22:17:52 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ej1-f66.google.com (mail-ej1-f66.google.com
 [209.85.218.66])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 10D75858BA
 for <containers@lists.linux-foundation.org>;
 Sun, 22 Nov 2020 22:17:52 +0000 (UTC)
Received: by mail-ej1-f66.google.com with SMTP id z5so564824ejp.4
 for <containers@lists.linux-foundation.org>;
 Sun, 22 Nov 2020 14:17:51 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=paul-moore-com.20150623.gappssmtp.com; s=20150623;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=T4CY2UVVySQTR/IgGfrcAE9Yvfw8Rpt8ESDEqvgdlV0=;
 b=IsIYVTGVaCrVj9c5DcaTFqsBEseZHJ9vWNSoDkjdubHWL5RuSrHMX8lpFwvrVEbr+D
 YIaQzOtzE37dPsYUgIX3D0QQOgxuxcNycAVPUzh0u5rzIXxw1LzVcowcy040lmKqzTjc
 mBOGV1IjonOIMMt7fcNcLg0Jv9GavSzdJiCvSUjrG/Em5mfms4rj7V855zdZH+Mebjf/
 3a3ZJ43HzWf5s0G6gG55hnXRwDtz/TIIGYpZD/Dd2APn5UY5ULuxLKkIgKrRUpEgHBra
 zZASjWMuvIFAgw2L7OuVG7b+2NvuCyaLPF5cXQpaqgo8do08Ply0k66nA+LZF82DGHj4
 OyAQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=T4CY2UVVySQTR/IgGfrcAE9Yvfw8Rpt8ESDEqvgdlV0=;
 b=khUr8+WLNbQ9gVuid7v3y9V4BdkKeCz7h9ddX8w2TyfsPvG7DRZMUzgRDfGhkZKBWT
 TWwyKVT0wc+CIX5bu5/gooOW9r5VJUq3fnV14+vFhEzNvgwuyt7BRJDvjuBjSQ1TymZs
 AYd8s5EKj/XqFvdMi1Jq4U2/dIAmR/pziGui36wpPHw7jR4MpX6lTVRI6HbzDeFoI4FI
 8hdyvhdrmBBF+9Ze1JT5u8jjjlvnbUjoYpM9UvRtD5j/sXB6llR/azGm++3hTj+3srJ4
 gG7hraDqdMcz4QBg8qe0X2jTFnp1V2oAMwHF2625BCO8JEq3ZOwV0Ozqpe6+y6HK3GrM
 L09g==
X-Gm-Message-State: AOAM530Rvf2YUQr00bEO04fJHBvlZOtxXcw0x8J5npM6IjGeWUMvj2Pm
 pLt1Qd/VtXrO3pSLPk0P2H7SQj9I+3d6zpSpCMn4
X-Google-Smtp-Source: ABdhPJw12xuRZoIeL/vGVBoUF4Pp6Vi1slczsoOA2TmXfkvzw8XIX8310DsMH/5qvds2YuOjg+U0QMN2daNuxBFO/6M=
X-Received: by 2002:a17:906:7c9:: with SMTP id
 m9mr40871916ejc.178.1606083470433; 
 Sun, 22 Nov 2020 14:17:50 -0800 (PST)
MIME-Version: 1.0
References: <20201115103718.298186-1-christian.brauner@ubuntu.com>
 <20201115103718.298186-32-christian.brauner@ubuntu.com>
In-Reply-To: <20201115103718.298186-32-christian.brauner@ubuntu.com>
From: Paul Moore <paul@paul-moore.com>
Date: Sun, 22 Nov 2020 17:17:39 -0500
Message-ID: <CAHC9VhQ5gcOa0+KKDtKEgg_v4SZV2hPdaKUbPGJAQrVB8mn0jA@mail.gmail.com>
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

On Sun, Nov 15, 2020 at 5:43 AM Christian Brauner
<christian.brauner@ubuntu.com> wrote:
>
> Audit will sometimes log the inode's i_uid and i_gid. Enable audit to log the
> mapped inode when it is accessed from an idmapped mount.

I mentioned this in an earlier patch in this patchset, but it is worth
repeating here: audit currently records information in the context of
the initial/host namespace and I believe it should probably stay that
way until the rest of the namespace smarts that Richard is working on
is merged.  If we do change the context of the inode's UID and GID
information it has the potential to create a rather odd looking audit
record with inconsistent credentials and the filters would yield some
very interesting results.

> Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
> ---
> /* v2 */
> unchanged
> ---
>  fs/namei.c            | 14 +++++++-------
>  include/linux/audit.h | 10 ++++++----
>  ipc/mqueue.c          |  8 ++++----
>  kernel/auditsc.c      | 26 ++++++++++++++------------
>  4 files changed, 31 insertions(+), 27 deletions(-)

-- 
paul moore
www.paul-moore.com
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
