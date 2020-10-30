Return-Path: <SRS0=hUL4=EF=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48CE8C00A89
	for <containers@archiver.kernel.org>; Fri, 30 Oct 2020 19:24:52 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id AF848206E3
	for <containers@archiver.kernel.org>; Fri, 30 Oct 2020 19:24:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="pzahXt25"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF848206E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 1E39E85CD5;
	Fri, 30 Oct 2020 19:24:51 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id sP4k8y-gzes9; Fri, 30 Oct 2020 19:24:50 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 7BDFA86C7C;
	Fri, 30 Oct 2020 19:24:50 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 5FEB6C0859;
	Fri, 30 Oct 2020 19:24:50 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 09D0AC0051
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 19:24:49 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id E44CD229A3
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 19:24:48 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 7dQs1wvfloz7
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 19:24:47 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-lf1-f44.google.com (mail-lf1-f44.google.com
 [209.85.167.44])
 by silver.osuosl.org (Postfix) with ESMTPS id EF92720116
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 19:24:46 +0000 (UTC)
Received: by mail-lf1-f44.google.com with SMTP id y184so7320122lfa.12
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 12:24:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=abdnn1aLwrD2IENap20k3wTn5YnXWcerHLaxedFloWs=;
 b=pzahXt25ftmIlECCNdzBGRH9RP5/phCMd9ilpAa5PAECfwsYXVeY0DSmhD68iGqYPZ
 NgFp0fW27VDKAarsqPlRaGlDExh1uKLxViCss4yRzvI0RvdJuDbwJxy3MiMSmrfb2lf4
 UJ2l0E7MBLpT4mf1Qo8a800BcMFWbk7E/vIBURoS1zMqzZ+7LaGEnRa+g52I2Zgq2Lfp
 SBsGeG66UACfIfh/Sl158f5JmueCza5B/WvSzkUGttF3AIC6g9r95SY04P6DGjd1/r46
 DB4290ojIyQbmI7tBjqYsDYz5YrvWM8H4kzPAdEe7ShWGdTqNylA35SI7lZ3gCugE0Uv
 QABA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=abdnn1aLwrD2IENap20k3wTn5YnXWcerHLaxedFloWs=;
 b=GMf4omQF9I6ucFqULUYQLO36p845+czLRY4sLvoo5id99HoHMXjrnrkKIGai5SvCRv
 uLRuK2YirsqUQv4krkMxChj1ZZy0QUXeRhk69PXnEDmQ1czw1KzYAJsiB1hGML6JdMOO
 LBVme8I8HHEfTljSSSwS4f1Y3wku9IJdjdKLtYpa1dg0gEoX+81xFLmHSnHk4uj4ey7u
 2j+suYGDKhixnspP+vkrCB1HOb3jJoiI8zWXfE7bWlijk5ZIkZTeOrh7oZtrYy4Osg1e
 AeWReH8MPoHn004mpoKkcZAF/S/3a0cGkt/OzW/d1rDqSlrUkne/d9l/++5f1LQbNC8x
 hlNw==
X-Gm-Message-State: AOAM530+NGY7ZhvtHQ/d9K53/Uj5HbCyfNL5MJBQVn4aXiAlS8gh60dw
 Iir6Xnxat6oOgVd7OB0MZQX2r199N0ifFlWu3Ry6GQ==
X-Google-Smtp-Source: ABdhPJztV7eDIdpjXuwWdsQQHK9/EMBt9Y0h0rMl3PMT3/K3SOLSbQwh6j3ZsZyUYuUwItLlGKBUIS59RQSVLDYi5zo=
X-Received: by 2002:a05:6512:1182:: with SMTP id
 g2mr1454663lfr.198.1604085884817; 
 Fri, 30 Oct 2020 12:24:44 -0700 (PDT)
MIME-Version: 1.0
References: <63598b4f-6ce3-5a11-4552-cdfe308f68e4@gmail.com>
 <20201029152609.k3urvzjocf3s7uml@gmail.com>
 <91b74ce1-de95-2b92-c62e-e2715d6071d3@gmail.com>
In-Reply-To: <91b74ce1-de95-2b92-c62e-e2715d6071d3@gmail.com>
Date: Fri, 30 Oct 2020 20:24:18 +0100
Message-ID: <CAG48ez0TZrwBoEi4d6n+FUN19hq6Pc+DOGNrRb-zHDSZVm9kfw@mail.gmail.com>
Subject: Re: For review: seccomp_user_notif(2) manual page [v2]
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Song Liu <songliubraving@fb.com>,
 Will Drewry <wad@chromium.org>, Kees Cook <keescook@chromium.org>,
 Daniel Borkmann <daniel@iogearbox.net>, linux-man <linux-man@vger.kernel.org>,
 Robert Sesek <rsesek@google.com>,
 Containers <containers@lists.linux-foundation.org>,
 lkml <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
 Christian Brauner <christian.brauner@canonical.com>, bpf <bpf@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>,
 Christian Brauner <christian@brauner.io>
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
From: Jann Horn via Containers <containers@lists.linux-foundation.org>
Reply-To: Jann Horn <jannh@google.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Thu, Oct 29, 2020 at 8:53 PM Michael Kerrisk (man-pages)
<mtk.manpages@gmail.com> wrote:
> On 10/29/20 4:26 PM, Christian Brauner wrote:
> > I like this manpage. I think this is the most comprehensive explanation
> > of any seccomp feature
>
> Thanks (at least, I think so...)
>
> > and somewhat understandable.
>       ^^^^^^^^
>
> (... but I'm not sure ;-).)

Relevant: http://tinefetz.net/files/gimgs/78_78_17.jpg
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
