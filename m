Return-Path: <SRS0=HbWT=HY=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	NICE_REPLY_A,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C132BC433E6
	for <containers@archiver.kernel.org>; Mon, 22 Feb 2021 14:10:05 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 1DE2E64E57
	for <containers@archiver.kernel.org>; Mon, 22 Feb 2021 14:10:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1DE2E64E57
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kernel.dk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id B4B9C85C94;
	Mon, 22 Feb 2021 14:10:03 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id AKdqMLw4ft1h; Mon, 22 Feb 2021 14:10:02 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id E1C3884E5D;
	Mon, 22 Feb 2021 14:09:48 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id B3B45C000B;
	Mon, 22 Feb 2021 14:09:48 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id A0443C0001
 for <containers@lists.linux-foundation.org>;
 Mon, 22 Feb 2021 14:09:47 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 882E6871B6
 for <containers@lists.linux-foundation.org>;
 Mon, 22 Feb 2021 14:09:47 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id AtwSZLMeXFW5
 for <containers@lists.linux-foundation.org>;
 Mon, 22 Feb 2021 14:09:43 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail-il1-f174.google.com (mail-il1-f174.google.com
 [209.85.166.174])
 by hemlock.osuosl.org (Postfix) with ESMTPS id CDCC5871B5
 for <containers@lists.linux-foundation.org>;
 Mon, 22 Feb 2021 14:09:43 +0000 (UTC)
Received: by mail-il1-f174.google.com with SMTP id c10so254306ilo.8
 for <containers@lists.linux-foundation.org>;
 Mon, 22 Feb 2021 06:09:43 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=kernel-dk.20150623.gappssmtp.com; s=20150623;
 h=subject:to:cc:references:from:message-id:date:user-agent
 :mime-version:in-reply-to:content-language:content-transfer-encoding;
 bh=RGQ4/qtHx2bjdFvrHFwyUEeeg/OYwFG54DfzAdrz3+k=;
 b=EDxEVjCtWelZXXeakBVsc8YZubZAU7JLWC6I7/OEx0f857/LgLETMq2fSvd0Wn33yE
 wiNVbR26+rzROP7lOyk1NiniRyN+Tmbx8/TX8kUI+QAHy6SevnynVy4AGjUvS8A4HNrW
 pCv74qIdjzWQJCKOnvqy1CtOlM+Htf3hJJLYYpYvUvMeRVWcDo2x4kYK1hQBYffhJNDX
 gi7OqwkkSeb95SI+OmGKyu1MupaXsqM4zM0NuhjC07//HtEiHCLN43G57FjVdjPqlySD
 jcg+iqtDSpZdyO0qXAId3gbjT0UNioWIR2BzYToAWmT+Iw+GUQRlPAmX5CiWPPei1CwV
 2GzQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:subject:to:cc:references:from:message-id:date
 :user-agent:mime-version:in-reply-to:content-language
 :content-transfer-encoding;
 bh=RGQ4/qtHx2bjdFvrHFwyUEeeg/OYwFG54DfzAdrz3+k=;
 b=Jy4iNlOsNywoJU9Cb/Voji7p+nPzyITehtrAKExxcg8FLUWZJrn49dnpy95+5vurbg
 4cNSnGJSNRmglBn291omLr+FGmwkE/4xGOKvaWGTfqsdefKYrNa7SOnhjiIjUKRezCMA
 6Nl7p/ZUBp2cbTOUMRroDLSw70XnpRk6x7Aca1lvusHsYWbb8mpD0Wlz2cr8MsX4veNE
 BSze/XrSg+xw9BwVC8kUFd0TajQ1dMnKrOV76pBBoC5Oa9BEze2uIZKvfROUPKhtjguR
 JXdRWPqgut1EqQ7n6pL8xfoGI9cPs2T+jBXxoJtbkxH/lhaszkrtz0v7zLe2/crDJyow
 ACiQ==
X-Gm-Message-State: AOAM5303v8+y+Nv24naYtgsOy3TLTZWrb5sKghsBXJ3ucEQB8X0fq6vQ
 vMqDoFr4sNg9/495c2cxPSkrUA==
X-Google-Smtp-Source: ABdhPJwfv5KNzqsw67r+b7VQyZku80bYaY0gjNcsmqJnjU4Ord9470UDNCt6Qu3Xn1tHFTovcoFSOA==
X-Received: by 2002:a05:6e02:1d8a:: with SMTP id
 h10mr14087421ila.224.1614002982921; 
 Mon, 22 Feb 2021 06:09:42 -0800 (PST)
Received: from [192.168.1.30] ([65.144.74.34])
 by smtp.gmail.com with ESMTPSA id g16sm11480253iln.29.2021.02.22.06.09.42
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Mon, 22 Feb 2021 06:09:42 -0800 (PST)
Subject: Re: [PATCH v6 3/7] Reimplement RLIMIT_NPROC on top of ucounts
To: Alexey Gladkov <gladkov.alexey@gmail.com>
References: <cover.1613392826.git.gladkov.alexey@gmail.com>
 <72fdcd154bec7e0dfad090f1af65ddac1e767451.1613392826.git.gladkov.alexey@gmail.com>
 <72214339-57fc-e47f-bb57-d1b39c69e38e@kernel.dk>
 <20210222101141.uve6hnftsakf4u7n@example.org>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <73b37a89-79d2-9c04-0626-2b164e91c3a8@kernel.dk>
Date: Mon, 22 Feb 2021 07:09:41 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.10.0
MIME-Version: 1.0
In-Reply-To: <20210222101141.uve6hnftsakf4u7n@example.org>
Content-Language: en-US
Cc: Kees Cook <keescook@chromium.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Jann Horn <jannh@google.com>, LKML <linux-kernel@vger.kernel.org>,
 Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Linus Torvalds <torvalds@linux-foundation.org>, io-uring@vger.kernel.org
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

On 2/22/21 3:11 AM, Alexey Gladkov wrote:
> On Sun, Feb 21, 2021 at 04:38:10PM -0700, Jens Axboe wrote:
>> On 2/15/21 5:41 AM, Alexey Gladkov wrote:
>>> diff --git a/fs/io-wq.c b/fs/io-wq.c
>>> index a564f36e260c..5b6940c90c61 100644
>>> --- a/fs/io-wq.c
>>> +++ b/fs/io-wq.c
>>> @@ -1090,10 +1091,7 @@ struct io_wq *io_wq_create(unsigned bounded, struct io_wq_data *data)
>>>  		wqe->node = alloc_node;
>>>  		wqe->acct[IO_WQ_ACCT_BOUND].max_workers = bounded;
>>>  		atomic_set(&wqe->acct[IO_WQ_ACCT_BOUND].nr_running, 0);
>>> -		if (wq->user) {
>>> -			wqe->acct[IO_WQ_ACCT_UNBOUND].max_workers =
>>> -					task_rlimit(current, RLIMIT_NPROC);
>>> -		}
>>> +		wqe->acct[IO_WQ_ACCT_UNBOUND].max_workers = task_rlimit(current, RLIMIT_NPROC);
>>
>> This doesn't look like an equivalent transformation. But that may be
>> moot if we merge the io_uring-worker.v3 series, as then you would not
>> have to touch io-wq at all.
> 
> In the current code the wq->user is always set to current_user():
> 
> io_uring_create [1]
> `- io_sq_offload_create
>    `- io_init_wq_offload [2]
>       `-io_wq_create [3]

current vs other wasn't my concern, but we're always setting ->user so
the test was pointless. So looks fine to me.

-- 
Jens Axboe

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
