Return-Path: <SRS0=DMKn=EC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,NICE_REPLY_A,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D8A7C4363A
	for <containers@archiver.kernel.org>; Tue, 27 Oct 2020 22:28:33 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A8C67221F7
	for <containers@archiver.kernel.org>; Tue, 27 Oct 2020 22:28:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=linuxfoundation.org header.i=@linuxfoundation.org header.b="UvStF98F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8C67221F7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 222B8870C9;
	Tue, 27 Oct 2020 22:28:32 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id O006zqdI1FRd; Tue, 27 Oct 2020 22:28:30 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 3E7A58731B;
	Tue, 27 Oct 2020 22:28:30 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 2F448C0859;
	Tue, 27 Oct 2020 22:28:30 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 1A55EC0051
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 22:28:29 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 155EE8731B
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 22:28:29 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id uDpaacOS2ECV
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 22:28:28 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-io1-f65.google.com (mail-io1-f65.google.com
 [209.85.166.65])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 775CA870C9
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 22:28:28 +0000 (UTC)
Received: by mail-io1-f65.google.com with SMTP id z17so3290516iog.11
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 15:28:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=linuxfoundation.org; s=google;
 h=subject:to:cc:references:from:message-id:date:user-agent
 :mime-version:in-reply-to:content-language:content-transfer-encoding;
 bh=Yd2294ZBZMy4XljpTTzjUGRIXipCuL8kyBKHe5NQtNI=;
 b=UvStF98FJhE092zgD2uanf57kDNaIOnaSuCHnKirsofWd0aCjRO4Qy5GS3JnhbXeJd
 R0JIdamE6oJenSkkX6e4uPkCcRw420HhLdJjWD91oSYP5oBUv2PrnHcU21GtGHURFmaL
 AqzzPN//XnWoxpYoy6vkYKeKEXLuzf7F4/9rI=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:subject:to:cc:references:from:message-id:date
 :user-agent:mime-version:in-reply-to:content-language
 :content-transfer-encoding;
 bh=Yd2294ZBZMy4XljpTTzjUGRIXipCuL8kyBKHe5NQtNI=;
 b=DTXmwV4ZQHPTPV7/5hJm4QtQJ2pUhKMODsXr/brdcNq5C5n/j1T3xx91J5yKxafCk0
 oYQnG/8AHTrqYN7+yaHP6iU+Gaoz9NVnA9dXwCwQsm6vqQ5SGwO/+HGts/uhgW0xmiSE
 FjhltU3hAec9oePP3WNbqJk3r08A4dKsyCfmZnzoE7n/zVSo1VRNrrDuqWVSnTKWrxwc
 cl7m6MwnfSIGYp3fpItq9eAUfWc//w/C/CSTspNH4R3PNaDVS0JWfEEqbrDzyPCD10Yx
 x64aS8bsv3E7oUFw1xVrghbIVpKRNKxjd/q1Jp4SnJ5XaENRQ5fuRVVN6oD0idBKagm+
 0nbQ==
X-Gm-Message-State: AOAM533/oDmUP4TbPg7xAhjEOJ5xlQB0rr7j4AFhaV3+HF7JFU3J9L0x
 7WcUvf19tBCZ3qRhOrVUiVJsWoIs
X-Google-Smtp-Source: ABdhPJySrsRO6td3S9ry6TCmbA6yj3jZ4Si223/83KN70hGwaMF2taBI3cWZWOi8+OG8ZYgPWvMvBQ==
X-Received: by 2002:a5e:8349:: with SMTP id y9mr3812931iom.188.1603837707726; 
 Tue, 27 Oct 2020 15:28:27 -0700 (PDT)
Received: from [192.168.1.112] (c-24-9-64-241.hsd1.co.comcast.net.
 [24.9.64.241])
 by smtp.gmail.com with ESMTPSA id i201sm1549583ild.12.2020.10.27.15.28.26
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Tue, 27 Oct 2020 15:28:27 -0700 (PDT)
Subject: Re: [PATCH] openat2: reject RESOLVE_BENEATH|RESOLVE_IN_ROOT
To: Aleksa Sarai <cyphar@cyphar.com>, Alexander Viro
 <viro@zeniv.linux.org.uk>, Shuah Khan <shuah@kernel.org>
References: <20201007103608.17349-1-cyphar@cyphar.com>
From: Shuah Khan <skhan@linuxfoundation.org>
Message-ID: <4ce6ba2c-8b23-78aa-47c0-8c9673273e8f@linuxfoundation.org>
Date: Tue, 27 Oct 2020 16:28:26 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.10.0
MIME-Version: 1.0
In-Reply-To: <20201007103608.17349-1-cyphar@cyphar.com>
Content-Language: en-US
Cc: containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
 stable@vger.kernel.org, linux-kselftest@vger.kernel.org,
 Shuah Khan <skhan@linuxfoundation.org>, linux-fsdevel@vger.kernel.org
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
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On 10/7/20 4:36 AM, Aleksa Sarai wrote:
> This was an oversight in the original implementation, as it makes no
> sense to specify both scoping flags to the same openat2(2) invocation
> (before this patch, the result of such an invocation was equivalent to
> RESOLVE_IN_ROOT being ignored).
> 
> This is a userspace-visible ABI change, but the only user of openat2(2)
> at the moment is LXC which doesn't specify both flags and so no
> userspace programs will break as a result.
> 
> Cc: <stable@vger.kernel.org> # v5.6+
> Fixes: fddb5d430ad9 ("open: introduce openat2(2) syscall")
> Acked-by: Christian Brauner <christian.brauner@ubuntu.com>
> Signed-off-by: Aleksa Sarai <cyphar@cyphar.com>
> ---
>   fs/open.c                                      | 4 +++
>   tools/testing/selftests/openat2/openat2_test.c | 8 +++++++-

You are combining fs change with selftest change.

Is there a reason why these two changes are combined?
2 separate patches is better.

thanks,
-- Shuah
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
