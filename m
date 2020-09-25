Return-Path: <SRS0=50w+=DC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13A01C4363D
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 16:45:21 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 774242075F
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 16:45:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NOC83klT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 774242075F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 0A3E586D08;
	Fri, 25 Sep 2020 16:45:20 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id hNirmbd0JqxV; Fri, 25 Sep 2020 16:45:18 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id B22C986CDD;
	Fri, 25 Sep 2020 16:45:18 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 93865C0890;
	Fri, 25 Sep 2020 16:45:18 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 032EFC0859
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 16:45:17 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id DEE5686DF8
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 16:45:17 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id X6OlSoY1STPo
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 16:45:17 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pg1-f196.google.com (mail-pg1-f196.google.com
 [209.85.215.196])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 5CC3586DF5
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 16:45:17 +0000 (UTC)
Received: by mail-pg1-f196.google.com with SMTP id g29so3091760pgl.2
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 09:45:17 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=ruCEryVFyAOn3Txfm384BRQUI0WS36tIHI9atsfBz/4=;
 b=NOC83klTMa/B6Y6Kt6iQ/A5oCUqhE3U6VAb96tggPynZTwJM2eMUu5p4Z7lpPKAoEa
 HzX4Z0ruwL7YNnauYGynp7rwc1cCrHiDOqjn42iminWT0UhtajgdEfmkP8J+SI0AeSph
 qaT0GLEuXQCEbNgXXjDTFP9od6z43+v9ZGE4sAnqYH3s4f6oCM2r3MN9Fa7EtKQlt8B1
 M998jx/BOxkqJWyOC3L/YpvcDbjvefT8RBs9BOX3k4Q05JGq8q5UuVuJYHOSLrU8KPzk
 sM24X41y9k7PyGoK7GYsmRN6VW/nq2wmRIK0jH6rAukl+nU1Sb17uLYTWq41pwywp4DE
 wncw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=ruCEryVFyAOn3Txfm384BRQUI0WS36tIHI9atsfBz/4=;
 b=FrejQjrsWwnR17AvYXdnseSezitIC0Ip8j1DeWMO6aajej6CRBgVWxllKngs9crUAV
 83CAc5HXtM2FZwcST6MKLB8/I1Q1cb4ne0ToMakD8HoW8yvDa2G8YaXSvxqcUzJowq4a
 lxH21iBBKO+W0lS2nSXkR21edTAGz5xx2rDgz86DTT1q3890xPC8if+C+ms3tAUc6BjG
 +Z9oqWddXjjNKH2CWyT1QAGbG5mIH4RmXbTiHCHt+nd4RW0H661QP3jQwUknCOlS/PDk
 lEGgRWzFf7IebJXuaRalFISpcsQhypgei12Xd84UWYlIfPIDsPjiPrccikvDgMY0GqYr
 ZgQg==
X-Gm-Message-State: AOAM533mZ3WKYVTZ0jIRE4elu97fn/rFiRdKgyad+DdaZBCW4aVvVgp5
 Qy6RWa/6CDPi9mxG9ifprhH/l3JLBwHT+E4b65Y=
X-Google-Smtp-Source: ABdhPJyLs9CmSuxL1C3wljdQpenEpIvO5wqWImFZHDW9uWc8lmXcNuFA4qC9zIGeu17/Yl8ddcf0atBt5fqjZbZZZpM=
X-Received: by 2002:aa7:9491:0:b029:142:2501:396b with SMTP id
 z17-20020aa794910000b02901422501396bmr151396pfk.48.1601052316926; Fri, 25 Sep
 2020 09:45:16 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1600951211.git.yifeifz2@illinois.edu>
 <c14518ba563d4c6bb75b9fac63b69cd4c82f9dcc.1600951211.git.yifeifz2@illinois.edu>
 <202009241601.FFC0CF68@keescook>
 <CABqSeARb7GNU9+sVgGzgqqOmpQNpxq1JsMrZJvS2EC05AyfAVw@mail.gmail.com>
In-Reply-To: <CABqSeARb7GNU9+sVgGzgqqOmpQNpxq1JsMrZJvS2EC05AyfAVw@mail.gmail.com>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Fri, 25 Sep 2020 11:45:05 -0500
Message-ID: <CABqSeASM9B77QrWRbqRF19N9-m-bm779-7a3qEDa8NumjBsorw@mail.gmail.com>
Subject: Re: [PATCH v2 seccomp 3/6] seccomp/cache: Add "emulator" to check if
 filter is arg-dependent
To: Kees Cook <keescook@chromium.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Jann Horn <jannh@google.com>,
 YiFei Zhu <yifeifz2@illinois.edu>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>,
 kernel list <linux-kernel@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Hubertus Franke <frankeh@us.ibm.com>,
 Jack Chen <jianyan2@illinois.edu>, Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 Josep Torrellas <torrella@illinois.edu>, Will Drewry <wad@chromium.org>,
 bpf <bpf@vger.kernel.org>, Tianyin Xu <tyxu@illinois.edu>
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

On Thu, Sep 24, 2020 at 10:04 PM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
> > Why do the prepare here instead of during attach? (And note that it
> > should not be written to fail.)
>
> Right.

During attach a spinlock (current->sighand->siglock) is held. Do we
really want to put the emulator in the "atomic section"?

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
