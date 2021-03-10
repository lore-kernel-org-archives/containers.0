Return-Path: <SRS0=WE+R=II=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F139C433DB
	for <containers@archiver.kernel.org>; Wed, 10 Mar 2021 20:07:23 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 9922164FB3
	for <containers@archiver.kernel.org>; Wed, 10 Mar 2021 20:07:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9922164FB3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp2.osuosl.org (Postfix) with ESMTP id 4C47E40015;
	Wed, 10 Mar 2021 20:07:22 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp2.osuosl.org ([127.0.0.1])
	by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Xcc4GrwdcBWf; Wed, 10 Mar 2021 20:07:21 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp2.osuosl.org (Postfix) with ESMTP id 62FE240001;
	Wed, 10 Mar 2021 20:07:21 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 41C0FC000A;
	Wed, 10 Mar 2021 20:07:21 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [IPv6:2605:bc80:3010::137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id ED9D6C0001
 for <containers@lists.linux-foundation.org>;
 Wed, 10 Mar 2021 20:07:19 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp4.osuosl.org (Postfix) with ESMTP id CF7F746804
 for <containers@lists.linux-foundation.org>;
 Wed, 10 Mar 2021 20:07:19 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp4.osuosl.org (amavisd-new);
 dkim=pass (2048-bit key) header.d=gmail.com
Received: from smtp4.osuosl.org ([127.0.0.1])
 by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id htzNaxv1lTkT
 for <containers@lists.linux-foundation.org>;
 Wed, 10 Mar 2021 20:07:19 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-wr1-x430.google.com (mail-wr1-x430.google.com
 [IPv6:2a00:1450:4864:20::430])
 by smtp4.osuosl.org (Postfix) with ESMTPS id 03E154ECAB
 for <containers@lists.linux-foundation.org>;
 Wed, 10 Mar 2021 20:07:18 +0000 (UTC)
Received: by mail-wr1-x430.google.com with SMTP id d15so24743808wrv.5
 for <containers@lists.linux-foundation.org>;
 Wed, 10 Mar 2021 12:07:18 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=wOgAelLZHWumRUZs21CTsS2zD3FZVsziPeto0jg+ZCE=;
 b=Zhg+3XhgV6ITD4zuHBLaBmmqu/Z4JKzJbm0coqwLukLYblSBSSp/WCkVm8LkMTQNOR
 Vj0myKVkgiOaHwpkAD5hKcBLmyaQWEYaU7rcBaFeDW/8pyHl+ePYLshU5rQM/EIvkDTm
 9OiVlEgLERsreqh8cZrLk2HfMOoGvAyfCZ9xLo/02KC9ttdIa6z/zU4DIfzCFANyw760
 mV4yDz4l2plcY8TtkAtiW41TpzMQlGtEHofIl5K8FiDKCX2M4ZILr+kDW3VEw8Id6UsN
 QNi/pTVSPKd0oDFlzkdw8ZSKBGV5TW+/+WQm8twF2GN/cuY1DznkRNtSkgq05fJdfWNM
 fdHA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=wOgAelLZHWumRUZs21CTsS2zD3FZVsziPeto0jg+ZCE=;
 b=MJsVfLFQtepK8MPxbG2JzYid99rr8cUVecvSBkcr3qr3D61oTx5em0OyZhw7qxEgBi
 7ejoy1nx6M6IsvncboF20ueEPxl7Mn1QME3ZPF2MXcziHzuw8+2B4MyikxkZU2FjWC2Y
 tgvekc0Om4yJt1PasK5K1wh6/LxePXpxpDjDhFLLGw9VoeyuLC5VnPM4ilaYG5lI7Bnn
 rDj8HruZAJfyBDTPt2maSTTMkJaPDVM190MvDrWzTa0+SZ61DILqNCP6v1NK+KQvX6gX
 0a7a8jqbb9bkkYUQvG4h8y1VWsSyOnSdP25LbtTF+RTSZ0HnOSbEZfSdTNtlBKWGuNnl
 6PIw==
X-Gm-Message-State: AOAM532F/t3lhsxodIPg5v4fgdRW0gDKhzL9wY3Q6seawwHavqNLrlmm
 hEvkuZfdFpK+NHVAsTfnmOg=
X-Google-Smtp-Source: ABdhPJwsH5QdZwvtuJJ0km8xhhnO57ZDdDl4ikE88zYJPHafhhROslLpWIbYqemy6BRU1UUjjbJOqQ==
X-Received: by 2002:adf:e548:: with SMTP id z8mr5387658wrm.246.1615406837234; 
 Wed, 10 Mar 2021 12:07:17 -0800 (PST)
Received: from example.org (ip-94-113-225-162.net.upcbroadband.cz.
 [94.113.225.162])
 by smtp.gmail.com with ESMTPSA id g16sm415804wrs.76.2021.03.10.12.07.15
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 10 Mar 2021 12:07:16 -0800 (PST)
Date: Wed, 10 Mar 2021 21:07:12 +0100
From: Alexey Gladkov <gladkov.alexey@gmail.com>
To: LKML <linux-kernel@vger.kernel.org>,
 "Eric W . Biederman" <ebiederm@xmission.com>
Subject: Re: [PATCH v5 0/5] proc: Relax check of mount visibility
Message-ID: <20210310200712.z5yuedjmbz42n2jr@example.org>
References: <cover.1615400395.git.gladkov.alexey@gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <cover.1615400395.git.gladkov.alexey@gmail.com>
Cc: Linux FS Devel <linux-fsdevel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Alexander Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>
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

On Wed, Mar 10, 2021 at 07:19:55PM +0100, Alexey Gladkov wrote:
> If only the dynamic part of procfs is mounted (subset=pid), then there is no
> need to check if procfs is fully visible to the user in the new user namespace.

I'm sorry about that unfinished patch set. Please ignore it.

> Changelog
> ---------
> v4:
> * Set SB_I_DYNAMIC only if pidonly is set.
> * Add an error message if subset=pid is canceled during remount.
> 
> v3:
> * Add 'const' to struct cred *mounter_cred (fix kernel test robot warning).
> 
> v2:
> * cache the mounters credentials and make access to the net directories
>   contingent of the permissions of the mounter of procfs.
> 
> --
> 
> Alexey Gladkov (5):
>   docs: proc: add documentation about mount restrictions
>   proc: Show /proc/self/net only for CAP_NET_ADMIN
>   proc: Disable cancellation of subset=pid option
>   proc: Relax check of mount visibility
>   docs: proc: add documentation about relaxing visibility restrictions
> 
>  Documentation/filesystems/proc.rst | 18 ++++++++++++++++++
>  fs/namespace.c                     | 27 ++++++++++++++++-----------
>  fs/proc/proc_net.c                 |  8 ++++++++
>  fs/proc/root.c                     | 25 +++++++++++++++++++------
>  include/linux/fs.h                 |  1 +
>  include/linux/proc_fs.h            |  1 +
>  6 files changed, 63 insertions(+), 17 deletions(-)
> 
> -- 
> 2.29.2
> 

-- 
Rgrds, legion

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
