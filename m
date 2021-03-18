Return-Path: <SRS0=u2Kp=IQ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7692CC433DB
	for <containers@archiver.kernel.org>; Thu, 18 Mar 2021 18:32:17 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id E837464F2A
	for <containers@archiver.kernel.org>; Thu, 18 Mar 2021 18:32:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E837464F2A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kinvolk.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp3.osuosl.org (Postfix) with ESMTP id 9602D605D9;
	Thu, 18 Mar 2021 18:32:16 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp3.osuosl.org ([127.0.0.1])
	by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 5yqcbQnErZY9; Thu, 18 Mar 2021 18:32:15 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [IPv6:2605:bc80:3010:104::8cd3:938])
	by smtp3.osuosl.org (Postfix) with ESMTP id 99FA96FACA;
	Thu, 18 Mar 2021 18:32:15 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 7289BC000A;
	Thu, 18 Mar 2021 18:32:15 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [IPv6:2605:bc80:3010::137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 35EFBC0001
 for <containers@lists.linux-foundation.org>;
 Thu, 18 Mar 2021 18:32:15 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp4.osuosl.org (Postfix) with ESMTP id 25C1F4EE01
 for <containers@lists.linux-foundation.org>;
 Thu, 18 Mar 2021 18:32:15 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp4.osuosl.org (amavisd-new);
 dkim=pass (1024-bit key) header.d=kinvolk.io
Received: from smtp4.osuosl.org ([127.0.0.1])
 by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id rjzUmDRZyeH4
 for <containers@lists.linux-foundation.org>;
 Thu, 18 Mar 2021 18:32:14 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-lj1-x235.google.com (mail-lj1-x235.google.com
 [IPv6:2a00:1450:4864:20::235])
 by smtp4.osuosl.org (Postfix) with ESMTPS id 1ABB34EB9D
 for <containers@lists.linux-foundation.org>;
 Thu, 18 Mar 2021 18:32:14 +0000 (UTC)
Received: by mail-lj1-x235.google.com with SMTP id s17so8760414ljc.5
 for <containers@lists.linux-foundation.org>;
 Thu, 18 Mar 2021 11:32:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kinvolk.io; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=I+QbzbUUNFTn4CN8f2NhR6mdprqbTaQ/xLSbBU+D4Lw=;
 b=ktk1b8F16oRJUsD5REmRZo2GFMspAiBUUPBqNnurHX+RvDnhFQIESmqlMZJnwmR2LO
 /oc5+/OKyWecXCIlDAu+bPOOx0kHrpL5qrLDXcyyOie9YlFAvRpMwfOU0VL8tQ+tH8/C
 tCVREGkKpB8h+Cra89DsgM0BXuh5vJ6JMNy/0=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=I+QbzbUUNFTn4CN8f2NhR6mdprqbTaQ/xLSbBU+D4Lw=;
 b=cETwXFj+Rt/0JN3RDzwmU5kh3tSP7IPynrg3EyDnxIpq7QrGIxkyb59FK8VRBSf8o2
 5UqzD65md7Y4TF3MWOoPsxKyyxiR9eCrlCWY/cP0oiN+RnPoUjIV1J4uHNtqrDN2vetA
 3ltnG/dW1OXlCL4SoEH+rQdi3L3MLmFgNWTLXjmzbunGvxmqro8mxbq2gVkw5UUcno/r
 Ql0nCuxQXYZ5nnDw0sqgl5VpFQO+lGUNhqcDF/rJDn1e8TbEnzBCou7rS3nSmxPdlSIX
 WXF5XgxAvRrnF+1D9Pqi1PWLLJ26rT7IKQCxW245+aSfTc2f4IbSY5Et6/TkodcChjK1
 LGOw==
X-Gm-Message-State: AOAM531B7a7eZfZivdVGY+jk4+L2zOo7QwSur/+wBQf/gsSIh/qha0Rn
 /x5HIrYYfZw+K57Zy/ztskPhyEfuwac8u2WHe9c/PA==
X-Google-Smtp-Source: ABdhPJzf0IUKEraU90345o5dEc+IbvnKI1MMFHWvW5R2eW7/mkOKVy2chIKRPRYgR/2vfsGWSwT5pa94rgYAgaR2AjM=
X-Received: by 2002:a2e:b5cd:: with SMTP id g13mr6175694ljn.372.1616092331913; 
 Thu, 18 Mar 2021 11:32:11 -0700 (PDT)
MIME-Version: 1.0
References: <20210318051733.2544-1-sargun@sargun.me>
 <20210318051733.2544-6-sargun@sargun.me>
In-Reply-To: <20210318051733.2544-6-sargun@sargun.me>
From: Rodrigo Campos <rodrigo@kinvolk.io>
Date: Thu, 18 Mar 2021 19:31:36 +0100
Message-ID: <CACaBj2ZEtrcjuv_F2=ff+ewfQaxbySqSq3vfFNnf+87n15sApw@mail.gmail.com>
Subject: Re: [PATCH 5/5] selftests/seccomp: Add test for atomic addfd+send
To: Sargun Dhillon <sargun@sargun.me>
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Kees Cook <keescook@chromium.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 LKML <linux-kernel@vger.kernel.org>
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

On Thu, Mar 18, 2021 at 6:17 AM Sargun Dhillon <sargun@sargun.me> wrote:
>
> This just adds a test to verify that when using the new introduced flag
> to ADDFD, a valid fd is added and returned as the syscall result.
>
> Signed-off-by: Rodrigo Campos <rodrigo@kinvolk.io>
> Signed-off-by: Sargun Dhillon <sargun@sargun.me>

I think in the last minutes changes this was removed by mistake:

From: Rodrigo Campos <rodrigo@kinvolk.io>

I'm happy to add more tests if we decide to merge patch 4 :)
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
