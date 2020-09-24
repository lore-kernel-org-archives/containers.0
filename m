Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,NICE_REPLY_A,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38062C4727D
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 13:46:28 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6D16C206F7
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 13:46:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=rasmusvillemoes.dk header.i=@rasmusvillemoes.dk header.b="KCxqPAVE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D16C206F7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=rasmusvillemoes.dk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 3425B86C2F;
	Thu, 24 Sep 2020 13:46:27 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Yn4FSTSEqSyL; Thu, 24 Sep 2020 13:46:25 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 25F72869D8;
	Thu, 24 Sep 2020 13:46:25 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 1C26EC0889;
	Thu, 24 Sep 2020 13:46:25 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 4DF04C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 13:46:23 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 3D12A86A95
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 13:46:23 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id haEJgK2JIpRC
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 13:46:22 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail-lj1-f195.google.com (mail-lj1-f195.google.com
 [209.85.208.195])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id DC89C80C0D
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 13:46:21 +0000 (UTC)
Received: by mail-lj1-f195.google.com with SMTP id u21so2803286ljl.6
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 06:46:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=rasmusvillemoes.dk; s=google;
 h=subject:to:cc:references:from:message-id:date:user-agent
 :mime-version:in-reply-to:content-language:content-transfer-encoding;
 bh=cDrHVTOD+iSWXelVapd6LAkJ7VfbRManFz9vUWJEqwc=;
 b=KCxqPAVEUh0NN2sRqfB2Er3kRv3k3VxWZOlCy1TnuFltpouAeT9UrqF3gbDCWNhLso
 Q4gthE2otk3e6NybEISvLpG5ofuUJ4TsMDfT/fjZlK00Lj8I+w0dolYj3GdjwFPq6Ih8
 CvX8q1UtLGea0tijaEcOFvSd32Yq46wp4o0mI=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:subject:to:cc:references:from:message-id:date
 :user-agent:mime-version:in-reply-to:content-language
 :content-transfer-encoding;
 bh=cDrHVTOD+iSWXelVapd6LAkJ7VfbRManFz9vUWJEqwc=;
 b=tYR2VySYrSu1+hMl58baHTXCIiqJrvsuCMDo9SegMuGPF1jsQW6yTDjM5kjrKxAn7t
 dvNfCLD9hdiW4tsnwQLqNQ5AebKIxQSlq3INdcNQ41qVW592FVqVyA1SbYyqDsg0Rorx
 JI+EdYUZzwvpX0vwnpjlXpOOcvqeei/DieDbxAAUy9W31W1qGXSYjy5xbcvgTIVh68eU
 fDeRNs4NGfjxEePvrKRy3YskKQbACcIpwRVz/XBLPzqAWR7XZ/tYdykI4QgTKiA1vQwu
 1gMBNawoQ5bgoSnycCt/eaW9WtXomi/+jNHi4S8LutAJXOBFUkp8n9j1CL9Iu2o/0lah
 Se9A==
X-Gm-Message-State: AOAM530NvX99LieybDbrOBxQohzA9S9pF2erh6idbkZbiCfwNOKk1/wv
 H89yHF0Ax0snbGqqgDwQyyGCuw5KOk8RlDDg7sY=
X-Google-Smtp-Source: ABdhPJyhP2oOUzht7mmnYmL06kxXBu44hSqGNAaV4Vj6cp2z2M4mFMwQjvAP9vCt1lBA3/mkfw8qIQ==
X-Received: by 2002:a19:6b17:: with SMTP id d23mr362374lfa.190.1600954856089; 
 Thu, 24 Sep 2020 06:40:56 -0700 (PDT)
Received: from [172.16.11.132] ([81.216.59.226])
 by smtp.gmail.com with ESMTPSA id s20sm2085680lfs.135.2020.09.24.06.40.54
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Thu, 24 Sep 2020 06:40:55 -0700 (PDT)
Subject: Re: [PATCH v1 0/6] seccomp: Implement constant action bitmaps
To: Kees Cook <keescook@chromium.org>, YiFei Zhu <yifeifz2@illinois.edu>
References: <20200923232923.3142503-1-keescook@chromium.org>
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Message-ID: <43039bb6-9d9f-b347-fa92-ea34ccc21d3d@rasmusvillemoes.dk>
Date: Thu, 24 Sep 2020 15:40:54 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.10.0
MIME-Version: 1.0
In-Reply-To: <20200923232923.3142503-1-keescook@chromium.org>
Content-Language: en-US
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 bpf@vger.kernel.org, Jann Horn <jannh@google.com>, linux-api@vger.kernel.org,
 containers@lists.linux-foundation.org, Tobin Feldman-Fitzthum <tobin@ibm.com>,
 Hubertus Franke <frankeh@us.ibm.com>, Andy Lutomirski <luto@amacapital.net>,
 Valentin Rothberg <vrothber@redhat.com>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>, Jack Chen <jianyan2@illinois.edu>,
 Josep Torrellas <torrella@illinois.edu>, Tianyin Xu <tyxu@illinois.edu>,
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

On 24/09/2020 01.29, Kees Cook wrote:
> rfc: https://lore.kernel.org/lkml/20200616074934.1600036-1-keescook@chromium.org/
> alternative: https://lore.kernel.org/containers/cover.1600661418.git.yifeifz2@illinois.edu/
> v1:
> - rebase to for-next/seccomp
> - finish X86_X32 support for both pinning and bitmaps
> - replace TLB magic with Jann's emulator
> - add JSET insn
> 
> TODO:
> - add ALU|AND insn
> - significantly more testing
> 
> Hi,
> 
> This is a refresh of my earlier constant action bitmap series. It looks
> like the RFC was missed on the container list, so I've CCed it now. :)
> I'd like to work from this series, as it handles the multi-architecture
> stuff.

So, I agree with Jann's point that the only thing that matters is that
always-allowed syscalls are indeed allowed fast.

But one thing I'm wondering about and I haven't seen addressed anywhere:
Why build the bitmap on the kernel side (with all the complexity of
having to emulate the filter for all syscalls)? Why can't userspace just
hand the kernel "here's a new filter: the syscalls in this bitmap are
always allowed noquestionsasked, for the rest, run this bpf". Sure, that
might require a new syscall or extending seccomp(2) somewhat, but isn't
that a _lot_ simpler? It would probably also mean that the bpf we do get
handed is a lot smaller. Userspace might need to pass a couple of
bitmaps, one for each relevant arch, but you get the overall idea.

I'm also a bit worried about the performance of doing that emulation;
that's constant extra overhead for, say, launching a docker container.

Regardless of how the kernel's bitmap gets created, something like

+	if (nr < NR_syscalls) {
+		if (test_bit(nr, bitmaps->allow)) {
+			*filter_ret = SECCOMP_RET_ALLOW;
+			return true;
+		}

probably wants some nospec protection somewhere to avoid the irony of
seccomp() being used actively by bad guys.

Rasmus
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
