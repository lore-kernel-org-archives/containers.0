Return-Path: <SRS0=hUL4=EF=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.3 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BD41C55179
	for <containers@archiver.kernel.org>; Fri, 30 Oct 2020 09:57:39 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A5822207DE
	for <containers@archiver.kernel.org>; Fri, 30 Oct 2020 09:57:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GRHC3d3u"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A5822207DE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 13C5586403;
	Fri, 30 Oct 2020 09:57:38 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id AKt3WGl2YoU2; Fri, 30 Oct 2020 09:57:37 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id A353685E5C;
	Fri, 30 Oct 2020 09:57:37 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 85B05C0859;
	Fri, 30 Oct 2020 09:57:37 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 9F848C0051
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 09:57:36 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 8A232872D2
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 09:57:36 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 62zWs74+2J3u
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 09:57:35 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-il1-f195.google.com (mail-il1-f195.google.com
 [209.85.166.195])
 by hemlock.osuosl.org (Postfix) with ESMTPS id C344E871E2
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 09:57:35 +0000 (UTC)
Received: by mail-il1-f195.google.com with SMTP id x20so5958032ilj.8
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 02:57:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=/KHmwpEf5KO59HQ9FXioTrkHMQnSCZyA82voNpwNnxU=;
 b=GRHC3d3uHyqgAX2bNvYF5h8/iEP8by/R6OwvXZSq+WCITM51vMsZn4GtwUmgPBcPTE
 JIFj14HuPPgbTZQIawYp/WdHFcCfbmwDz6AQau0lHfSWxoyRMIQGFCa6mC/lT/vC48Fh
 wYTYSi05HENiGIZrygUitWfPOvtbzSnv0hw2foQqpN3bXy/biCRwd2YEEEo1sCaotdD+
 hA6wLP2AV/oTN011TL9T9aeU4s8MfJlR9YyL3VBEDUL1hZNcVpgED15piK/dbU9mR+9J
 OBeYqC0iHVutFieBZGl23BYx95gCrsOrOmHBWMlmgoUyWbvcB9q8hEMkjqBqpL+HaXhc
 2LDQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=/KHmwpEf5KO59HQ9FXioTrkHMQnSCZyA82voNpwNnxU=;
 b=P6/I5SrnOkih56mX9ryIF1CRdd7wO4yUGwdS/7yhZNwa43POV+ua3u32diwHCGOTos
 2dLre9RbEbS/AkPTJpzW3sawSy3ett86km/sTAulbk8Ne7/3coyv3iFgtpR2Xoz1IFik
 +kenX3uSY1O+gV7QvMTXCXSImWdQGtGx2Pd1JOVpB1UnHBAVoHSkdVUTJDGeQn5vll2p
 Fk5eQGMJaCqO1urbaqE2xpOz6qcNnYVDRqvv7YvdMUhbESgbE1gP3C1hklUm6PGlo0Zk
 /jsE5dKmwkvMN4MpqgYIL/1MGTtamdtkve3+CLA1kKOs+0L0+8tdVtbU+4M7TXPxYUEW
 Y77g==
X-Gm-Message-State: AOAM5334WPmoqiU34Vu9wuReiAbgLHGBQmLAmjETnBt9Vmjv6GOc5akk
 5XuUmVPZZ0btfJuR6ATFJUIN7ZjSd+dyFk1x6TU=
X-Google-Smtp-Source: ABdhPJxFlt//ACc/IV26fZ1qCGgWOIH/npCA4rcrvS/8aohcRHMILRDfiUHL83JStMqAq2lFcdcahBWGZNVdziI1h1E=
X-Received: by 2002:a05:6e02:14c9:: with SMTP id
 o9mr1218968ilk.137.1604051855144; 
 Fri, 30 Oct 2020 02:57:35 -0700 (PDT)
MIME-Version: 1.0
References: <20201029003252.2128653-1-christian.brauner@ubuntu.com>
 <20201029003252.2128653-34-christian.brauner@ubuntu.com>
In-Reply-To: <20201029003252.2128653-34-christian.brauner@ubuntu.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Fri, 30 Oct 2020 11:57:24 +0200
Message-ID: <CAOQ4uxjyNB2zE+GE8Wmwjq__C7e4mrWMrS8RDVOOQFLtezjTkg@mail.gmail.com>
Subject: Re: [PATCH 33/34] overlayfs: handle idmapped merged mounts
To: Christian Brauner <christian.brauner@ubuntu.com>
Cc: Lennart Poettering <lennart@poettering.net>,
 Mimi Zohar <zohar@linux.ibm.com>, David Howells <dhowells@redhat.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tycho Andersen <tycho@tycho.ws>, Miklos Szeredi <miklos@szeredi.hu>,
 smbarber@chromium.org, Christoph Hellwig <hch@infradead.org>,
 Ext4 <linux-ext4@vger.kernel.org>, Mrunal Patel <mpatel@redhat.com>,
 Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>,
 Jann Horn <jannh@google.com>, selinux@vger.kernel.org,
 Josh Triplett <josh@joshtriplett.org>,
 linux-fsdevel <linux-fsdevel@vger.kernel.org>,
 Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Seth Forshee <seth.forshee@canonical.com>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 Stephen Smalley <stephen.smalley.work@gmail.com>,
 Jonathan Corbet <corbet@lwn.net>, overlayfs <linux-unionfs@vger.kernel.org>,
 LSM List <linux-security-module@vger.kernel.org>,
 Linux Audit <linux-audit@redhat.com>,
 "Eric W. Biederman" <ebiederm@xmission.com>,
 Linux API <linux-api@vger.kernel.org>,
 Casey Schaufler <casey@schaufler-ca.com>, Alban Crequy <alban@kinvolk.io>,
 linux-integrity <linux-integrity@vger.kernel.org>,
 Todd Kjos <tkjos@google.com>
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

> -int ovl_permission(struct inode *inode, int mask)
> +int ovl_permission_mapped(struct user_namespace *user_ns,
> +                         struct inode *inode, int mask)
>  {
>         struct inode *upperinode = ovl_inode_upper(inode);
>         struct inode *realinode = upperinode ?: ovl_inode_lower(inode);
> -       struct user_namespace *user_ns;
> +       struct user_namespace *real_user_ns;
>         const struct cred *old_cred;
>         int err;
>
> @@ -302,15 +313,15 @@ int ovl_permission(struct inode *inode, int mask)
>         }
>
>         if (upperinode)
> -               user_ns = ovl_upper_mnt_user_ns(OVL_FS(inode->i_sb));
> +               real_user_ns = ovl_upper_mnt_user_ns(OVL_FS(inode->i_sb));
>         else
> -               user_ns = OVL_I(inode)->lower_user_ns;
> +               real_user_ns = OVL_I(inode)->lower_user_ns;

These changes look strange in this patch. Better use real_user_ns in previous
patch.

Thanks,
Amir.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
