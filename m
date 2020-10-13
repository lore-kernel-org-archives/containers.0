Return-Path: <SRS0=kI60=DU=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.1 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,NICE_REPLY_A,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6BBA5C433E7
	for <containers@archiver.kernel.org>; Tue, 13 Oct 2020 21:55:17 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 9048920EDD
	for <containers@archiver.kernel.org>; Tue, 13 Oct 2020 21:55:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=rasmusvillemoes.dk header.i=@rasmusvillemoes.dk header.b="GO89q5/U"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9048920EDD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=rasmusvillemoes.dk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 24B1D87CD4;
	Tue, 13 Oct 2020 21:55:16 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id BiDnuBthrh7b; Tue, 13 Oct 2020 21:55:15 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 8500387CC9;
	Tue, 13 Oct 2020 21:55:15 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 68EA6C0052;
	Tue, 13 Oct 2020 21:55:15 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 4817BC0051
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 21:55:14 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 2F37E87CD0
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 21:55:14 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id obfguduA5UCf
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 21:55:13 +0000 (UTC)
X-Greylist: delayed 00:05:34 by SQLgrey-1.7.6
Received: from mail-ej1-f68.google.com (mail-ej1-f68.google.com
 [209.85.218.68])
 by hemlock.osuosl.org (Postfix) with ESMTPS id CDFF687CC9
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 21:55:12 +0000 (UTC)
Received: by mail-ej1-f68.google.com with SMTP id c22so1973322ejx.0
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 14:55:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=rasmusvillemoes.dk; s=google;
 h=subject:to:cc:references:from:message-id:date:user-agent
 :mime-version:in-reply-to:content-language:content-transfer-encoding;
 bh=EzSWvplMqO4cdN++0Ux5XsKlBbV7BOhF67AtXcUOeMs=;
 b=GO89q5/UKsCuaRfA42EpuS4jIEk4259OJUr1KkM2uwbGGwvTjVKxPHUcolF8kks7Mo
 +mkXL7oq058MeNpC93YGjZUHhm/CIWona3mza47SaubqG9vncZ7ku8lG6JauvRTbIX6P
 OI+ObqhVYJlbnv5zPa9PqfvmwErfKwr0+UzoQ=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:subject:to:cc:references:from:message-id:date
 :user-agent:mime-version:in-reply-to:content-language
 :content-transfer-encoding;
 bh=EzSWvplMqO4cdN++0Ux5XsKlBbV7BOhF67AtXcUOeMs=;
 b=Mbmya3rsAnEct7BDCUkBNO8IApO8/mUvJXxMDQoTpGxFvKeqUuuDoccmpcBkcC4YIJ
 ET/7KjxqrKB/Y4aR68CmRWLoAzi9oFKBOZLpMmzB7suQJRTdOFDZkhTa/s3897XY46Yj
 KWWalkUVTPc1yh58MtPucaLzb3xDhhqavLuWCvGNcryK1kp9BtUz5WKzJg34xn70AHOR
 h3C40BToaUgZI1gLKy/En2azdv55nrJaXgGW0/9igR+lasYEr9efFTis6dU8pj0G4F5O
 T9KxUWiVaLbCheuIZmXcdE3YvEwJjGkkhnVq8K13HYt2SpBhCwEtzXeh/4PBmnANtcrv
 HeGw==
X-Gm-Message-State: AOAM531mBfa6E+DUsANOqBMLUR7S2LNL5zYezg/VN5ldwJPVlypfg/Qz
 FMYdm/pTryhjOY1OSiWzMsYfjfngXFkVMOMVvtc=
X-Google-Smtp-Source: ABdhPJwABvCvhJd+JSDbSPUX836u6gpnht+hLXQCQn+gFf/NH+wdWUzERRS4w7diiDWA4EN5G3lHTA==
X-Received: by 2002:a17:906:3852:: with SMTP id
 w18mr1824808ejc.551.1602625777024; 
 Tue, 13 Oct 2020 14:49:37 -0700 (PDT)
Received: from [192.168.1.149] (5.186.115.188.cgn.fibianet.dk. [5.186.115.188])
 by smtp.gmail.com with ESMTPSA id a12sm454869edy.87.2020.10.13.14.49.35
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Tue, 13 Oct 2020 14:49:36 -0700 (PDT)
Subject: Re: [PATCH 1/2] fs, close_range: add flag CLOSE_RANGE_CLOEXEC
To: Al Viro <viro@zeniv.linux.org.uk>, Giuseppe Scrivano <gscrivan@redhat.com>
References: <20201013140609.2269319-1-gscrivan@redhat.com>
 <20201013140609.2269319-2-gscrivan@redhat.com>
 <20201013210925.GJ3576660@ZenIV.linux.org.uk>
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Message-ID: <70fa4f70-38cc-7e18-8156-65a3e50c641e@rasmusvillemoes.dk>
Date: Tue, 13 Oct 2020 23:49:34 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.10.0
MIME-Version: 1.0
In-Reply-To: <20201013210925.GJ3576660@ZenIV.linux.org.uk>
Content-Language: en-US
Cc: linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org,
 linux-kernel@vger.kernel.org
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

On 13/10/2020 23.09, Al Viro wrote:
> On Tue, Oct 13, 2020 at 04:06:08PM +0200, Giuseppe Scrivano wrote:
>> +		spin_lock(&cur_fds->file_lock);
>> +		fdt = files_fdtable(cur_fds);
>> +		cur_max = fdt->max_fds - 1;
>> +		max_fd = min(max_fd, cur_max);
>> +		while (fd <= max_fd)
>> +			__set_close_on_exec(fd++, fdt);
>> +		spin_unlock(&cur_fds->file_lock);
> 
> 	First of all, this is an atrocious way to set all bits
> in a range.  What's more, you don't want to set it for *all*
> bits - only for the ones present in open bitmap.  It's probably
> harmless at the moment, but let's not create interesting surprises
> for the future.

Eh, why not? They can already be set for unallocated slots:

commit 5297908270549b734c7c2556745e2385b6d4941d
Author: Mateusz Guzik <mguzik@redhat.com>
Date:   Tue Oct 3 12:58:14 2017 +0200

    vfs: stop clearing close on exec when closing a fd

    Codepaths allocating a fd always make sure the bit is set/unset
    depending on flags, thus clearing on close is redundant.

And while we're on that subject, yours truly suggested exactly that two
years prior [1], with a follow-up [2] in 2018 to do what wasn't done in
5297908, but (still) seems like obvious micro-optimizations, given that
the close_on_exec bitmap is not maintained as a subset of the open
bitmap. Mind taking a look at [2]?

[1]
https://lore.kernel.org/lkml/1446543679-28849-1-git-send-email-linux@rasmusvillemoes.dk/t/#u
[2]
https://lore.kernel.org/lkml/20181024160159.25884-1-linux@rasmusvillemoes.dk/

Rasmus
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
