Return-Path: <SRS0=kI60=DU=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	NICE_REPLY_A,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DFC2C433E7
	for <containers@archiver.kernel.org>; Tue, 13 Oct 2020 21:04:35 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 033A0208D5
	for <containers@archiver.kernel.org>; Tue, 13 Oct 2020 21:04:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=rasmusvillemoes.dk header.i=@rasmusvillemoes.dk header.b="B7TVlQ2c"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 033A0208D5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=rasmusvillemoes.dk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 434032E1BD;
	Tue, 13 Oct 2020 21:04:34 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id m-ffsaddY1Ii; Tue, 13 Oct 2020 21:04:32 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 54DAE2E450;
	Tue, 13 Oct 2020 21:04:31 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 306F4C07FF;
	Tue, 13 Oct 2020 21:04:31 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id B5E5BC0051
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 21:04:27 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 9CF8587BA1
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 21:04:27 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id QIFAiuo8vMYR
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 21:04:26 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ed1-f66.google.com (mail-ed1-f66.google.com
 [209.85.208.66])
 by hemlock.osuosl.org (Postfix) with ESMTPS id A256887B7D
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 21:04:26 +0000 (UTC)
Received: by mail-ed1-f66.google.com with SMTP id 33so877372edq.13
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 14:04:26 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=rasmusvillemoes.dk; s=google;
 h=subject:to:cc:references:from:message-id:date:user-agent
 :mime-version:in-reply-to:content-language:content-transfer-encoding;
 bh=Dpznq1bVtHuTvkgZ0V3uOe64d8urDDLe1UJMO63b1Hs=;
 b=B7TVlQ2cGFtisTvY81goMmv1p7zhU8tVopK6OyjfNs0BEU7T2p+ZQfOnQmGLPH176X
 Ddx44SpYCO2gquP5hbMHKic8xHREKYmC0yPabTFE1gplCRX/1peJ9ZrQtrX6RdXv81VN
 K4JPq9b14w6YErYoiaxnLTBoSOxjd8Vw7AzCY=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:subject:to:cc:references:from:message-id:date
 :user-agent:mime-version:in-reply-to:content-language
 :content-transfer-encoding;
 bh=Dpznq1bVtHuTvkgZ0V3uOe64d8urDDLe1UJMO63b1Hs=;
 b=CwYiowEvbDegIQ6VSDwWN+vGAgStLNt3LRBIhtuZCLFEIVctZkmlaQd/Uv0GfVxFU3
 tpjR8bRR6ln5XXniCgDFWJcwc98eVaLbMoPhU/78piyyz1YBl7ytPOdp8FHQFxs1wIBT
 ucrRs8wXeRGUi9cMRToXVhuZAZR/vmpXw1httYOQtXW0uloYuniEfIZIceBHCSInhmNd
 aLownbdnexlt+43MGM1cJB8Ye8mk9StCXs+cwq6bxUyiZsKRB+Yk64ySrlaKk950RGVI
 gVNQ9rvXIwS5s8oNun+udmHA5jkwrhMOf7zwyYzUL0/3Fp9xVpSYCTQHOyOXaZN6AW0W
 HJ6Q==
X-Gm-Message-State: AOAM533jkX0oQ+lzS9Quo961Q4pMIwzdt54Qyj6xlkmSz3yrEikfAOBZ
 WBJZeke+iPTrj/X/lnm3qth6G26XicVmwp0GNIg=
X-Google-Smtp-Source: ABdhPJw5D4eRrsPzQP92gAP9vfi6hiIqR+4GaLJTcdF3tCuPnywuQSebLETL8Z2Ciy7q0rfo+5zGxQ==
X-Received: by 2002:aa7:d143:: with SMTP id r3mr1636703edo.103.1602623062929; 
 Tue, 13 Oct 2020 14:04:22 -0700 (PDT)
Received: from [192.168.1.149] (5.186.115.188.cgn.fibianet.dk. [5.186.115.188])
 by smtp.gmail.com with ESMTPSA id f23sm543444ejd.5.2020.10.13.14.04.22
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Tue, 13 Oct 2020 14:04:22 -0700 (PDT)
Subject: Re: [PATCH 1/2] fs, close_range: add flag CLOSE_RANGE_CLOEXEC
To: Christian Brauner <christian.brauner@ubuntu.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>
References: <20201013140609.2269319-1-gscrivan@redhat.com>
 <20201013140609.2269319-2-gscrivan@redhat.com>
 <20201013205427.clvqno24ctwxbuyv@wittgenstein>
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Message-ID: <22ff41f8-c009-84f4-849b-a807b7382253@rasmusvillemoes.dk>
Date: Tue, 13 Oct 2020 23:04:21 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.10.0
MIME-Version: 1.0
In-Reply-To: <20201013205427.clvqno24ctwxbuyv@wittgenstein>
Content-Language: en-US
Cc: linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org,
 linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk
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

On 13/10/2020 22.54, Christian Brauner wrote:
> On Tue, Oct 13, 2020 at 04:06:08PM +0200, Giuseppe Scrivano wrote:
> 
> Hey Guiseppe,
> 
> Thanks for the patch!
> 
>> When the flag CLOSE_RANGE_CLOEXEC is set, close_range doesn't
>> immediately close the files but it sets the close-on-exec bit.
> 
> Hm, please expand on the use-cases a little here so people know where
> and how this is useful. Keeping the rationale for a change in the commit
> log is really important.
> 

> I think I don't have quarrels with this patch in principle but I wonder
> if something like the following wouldn't be easier to follow:
> 
> diff --git a/fs/file.c b/fs/file.c
> index 21c0893f2f1d..872a4098c3be 100644
> --- a/fs/file.c
> +++ b/fs/file.c
> @@ -672,6 +672,32 @@ int __close_fd(struct files_struct *files, unsigned fd)
>  }
>  EXPORT_SYMBOL(__close_fd); /* for ksys_close() */
>  
> +static inline void __range_cloexec(struct files_struct *cur_fds,
> +				   unsigned int fd, unsigned max_fd)
> +{
> +	struct fdtable *fdt;
> +	spin_lock(&cur_fds->file_lock);
> +	fdt = files_fdtable(cur_fds);
> +	while (fd <= max_fd)
> +		__set_close_on_exec(fd++, fdt);

Doesn't that want to be

  bitmap_set(fdt->close_on_exec, fd, max_fd - fd + 1)

to do word-at-a-time? I assume this would mostly be called with (3, ~0U)
as arguments or something like that.

Rasmus
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
