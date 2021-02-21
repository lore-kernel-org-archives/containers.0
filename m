Return-Path: <SRS0=XC5U=HX=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	NICE_REPLY_A,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 968FBC433E6
	for <containers@archiver.kernel.org>; Sun, 21 Feb 2021 23:38:17 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 08FB964DF0
	for <containers@archiver.kernel.org>; Sun, 21 Feb 2021 23:38:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08FB964DF0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kernel.dk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id DCBD785955;
	Sun, 21 Feb 2021 23:38:16 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id U7AtcDq0jNlC; Sun, 21 Feb 2021 23:38:15 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id DF5E28593F;
	Sun, 21 Feb 2021 23:38:15 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id D2689C000B;
	Sun, 21 Feb 2021 23:38:15 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id B421DC0001
 for <containers@lists.linux-foundation.org>;
 Sun, 21 Feb 2021 23:38:14 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp3.osuosl.org (Postfix) with ESMTP id 953906F4B7
 for <containers@lists.linux-foundation.org>;
 Sun, 21 Feb 2021 23:38:14 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp3.osuosl.org ([127.0.0.1])
 by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 2GtcXH7KVHfZ
 for <containers@lists.linux-foundation.org>;
 Sun, 21 Feb 2021 23:38:13 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.8.0
Received: from mail-pg1-f177.google.com (mail-pg1-f177.google.com
 [209.85.215.177])
 by smtp3.osuosl.org (Postfix) with ESMTPS id 908E06F4A5
 for <containers@lists.linux-foundation.org>;
 Sun, 21 Feb 2021 23:38:12 +0000 (UTC)
Received: by mail-pg1-f177.google.com with SMTP id p21so9115433pgl.12
 for <containers@lists.linux-foundation.org>;
 Sun, 21 Feb 2021 15:38:12 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=kernel-dk.20150623.gappssmtp.com; s=20150623;
 h=subject:to:cc:references:from:message-id:date:user-agent
 :mime-version:in-reply-to:content-language:content-transfer-encoding;
 bh=ewxqEQFZCqRPZepFJZrArWqJzNzRyrMy8DlI7kZWdbY=;
 b=tBabDsQM88C48+TrDFasmGxRf9lo5KwLdwTxTlg6mOAIgYZzAu1QYqLxKOml6fQOpU
 sRCdc7uSzDIWN6ysldM0C5UOcR78C8eihFm52FXeZeU+HQ4csvIauJLeaLgfzaUJ8Qnr
 5JJNoaB/g4w2yfmgFyCLRE7Ps4aKp6JA1lhrUFiAc2A2JIjLe+3z1R0c/lJrPe9Ll3N/
 J2mJXNLavJiiqF/v9E+t0MVLpwv3xigXA33nIZlLGhFCGxR2J11FiNfdpT0diMrfrxQE
 imsmjKZfRkFo6vfVn41CuIorDhu+QEmQ3y9hFxktPLlCaY0wJ8AWWG96mxJpPBkj7MRL
 K8wA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:subject:to:cc:references:from:message-id:date
 :user-agent:mime-version:in-reply-to:content-language
 :content-transfer-encoding;
 bh=ewxqEQFZCqRPZepFJZrArWqJzNzRyrMy8DlI7kZWdbY=;
 b=NgaFAOESUhgAgG2uD+E74E20s6FLheNvn0K84+/dKAQZGQmnd4CwM+hnRwGdf5t1Uo
 zlIWd6qJPCz2Xb5E5kfeY9dZX2aIqO1uf/JWlOgV+iAnFCHKqJi7if4cV7HlAD8NjaPG
 hv5c/8KQgKg562WyVzK197SBQt11lCLUImagPoZ5C4K6R1O6Lz6mcAYN+Evldzw9/qBL
 bQvSlcAVyGGojCWDo/eVptKNLwB9KJ+5Eqg0BENXDd/ltKXxVIVz33O0LfLw8xj/9KtD
 Zle4fXw6VYN8MJNPK0cXRvQJSgx2r84YDg+J1Tp7X9By2TwlPQhzJhv1yGTpdSAacw3N
 OxKw==
X-Gm-Message-State: AOAM531KXkZ8MzbEKOmJZ5eQgpP1HlTnmPOpZFTUY9GperZi5WeMh3YO
 M9W26dDUOfBrUjBGL0mgcoV0yQ==
X-Google-Smtp-Source: ABdhPJzdBl7iEW57AktQz1trvZZaWXb2g0jBAcCa1BGnJzyovv2hB07dcYLx+z1UHy8R8jqqeRueQA==
X-Received: by 2002:a63:c042:: with SMTP id z2mr17881788pgi.201.1613950692408; 
 Sun, 21 Feb 2021 15:38:12 -0800 (PST)
Received: from [192.168.1.134] ([66.219.217.173])
 by smtp.gmail.com with ESMTPSA id h20sm15842126pfv.164.2021.02.21.15.38.10
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Sun, 21 Feb 2021 15:38:11 -0800 (PST)
Subject: Re: [PATCH v6 3/7] Reimplement RLIMIT_NPROC on top of ucounts
To: Alexey Gladkov <gladkov.alexey@gmail.com>,
 LKML <linux-kernel@vger.kernel.org>, io-uring@vger.kernel.org,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux Containers <containers@lists.linux-foundation.org>, linux-mm@kvack.org
References: <cover.1613392826.git.gladkov.alexey@gmail.com>
 <72fdcd154bec7e0dfad090f1af65ddac1e767451.1613392826.git.gladkov.alexey@gmail.com>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <72214339-57fc-e47f-bb57-d1b39c69e38e@kernel.dk>
Date: Sun, 21 Feb 2021 16:38:10 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.10.0
MIME-Version: 1.0
In-Reply-To: <72fdcd154bec7e0dfad090f1af65ddac1e767451.1613392826.git.gladkov.alexey@gmail.com>
Content-Language: en-US
Cc: Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 Oleg Nesterov <oleg@redhat.com>, "Eric W . Biederman" <ebiederm@xmission.com>,
 Andrew Morton <akpm@linux-foundation.org>, Alexey Gladkov <legion@kernel.org>
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

On 2/15/21 5:41 AM, Alexey Gladkov wrote:
> diff --git a/fs/io-wq.c b/fs/io-wq.c
> index a564f36e260c..5b6940c90c61 100644
> --- a/fs/io-wq.c
> +++ b/fs/io-wq.c
> @@ -1090,10 +1091,7 @@ struct io_wq *io_wq_create(unsigned bounded, struct io_wq_data *data)
>  		wqe->node = alloc_node;
>  		wqe->acct[IO_WQ_ACCT_BOUND].max_workers = bounded;
>  		atomic_set(&wqe->acct[IO_WQ_ACCT_BOUND].nr_running, 0);
> -		if (wq->user) {
> -			wqe->acct[IO_WQ_ACCT_UNBOUND].max_workers =
> -					task_rlimit(current, RLIMIT_NPROC);
> -		}
> +		wqe->acct[IO_WQ_ACCT_UNBOUND].max_workers = task_rlimit(current, RLIMIT_NPROC);

This doesn't look like an equivalent transformation. But that may be
moot if we merge the io_uring-worker.v3 series, as then you would not
have to touch io-wq at all.

-- 
Jens Axboe

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
