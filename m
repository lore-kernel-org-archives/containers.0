Return-Path: <SRS0=DMKn=EC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.3 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C366C4363A
	for <containers@archiver.kernel.org>; Tue, 27 Oct 2020 19:09:13 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id BB62420756
	for <containers@archiver.kernel.org>; Tue, 27 Oct 2020 19:09:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TDpYEM9j"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB62420756
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 46C222E0DB;
	Tue, 27 Oct 2020 19:09:12 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Okrjgvd8crRR; Tue, 27 Oct 2020 19:09:11 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 8DCF820535;
	Tue, 27 Oct 2020 19:09:11 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 6AF4EC08A1;
	Tue, 27 Oct 2020 19:09:11 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id BCCDCC0051
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 19:09:09 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id B5FC7869BA
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 19:09:09 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 3ZEZmDAPDnly
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 19:09:09 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pj1-f65.google.com (mail-pj1-f65.google.com
 [209.85.216.65])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 2C45E85CE1
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 19:09:09 +0000 (UTC)
Received: by mail-pj1-f65.google.com with SMTP id c17so1269518pjo.5
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 12:09:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=vhFHGlRt/TibQfkAL2EZLq+3HRZ+VxPAD9HYXcgWC/k=;
 b=TDpYEM9j0VTG9y1sK6+P54LMevQ/wxvF5jiUXCKKLZ1FxRRYMYefcVyVQfAc+Om1PS
 ZEe1VRZkmhk0ir6O43G95oBAO2XD+Bq4fVBpHzkVRZw+UriLY30a/R4X0pDFtk1z5MUB
 yLaicL/Mrjl46F0+UFymiiwaSisHRYKw813Q0Kd47cc1WgZhvOJbmIZ6w6cxJxiecpuq
 hwk7hhJezQPq9VDBZdwaoEdHe5L3Ab5JZ4CMwJDp3CVt6wOQRLayWvn4DBgp1j2xyiIA
 Nfr8NKXzTh5ilnJ2tvCD46vw2NdTRtKMK/iutofss4RYEab+Vx7Vu0QT/YxkCzMOQAZw
 APGA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=vhFHGlRt/TibQfkAL2EZLq+3HRZ+VxPAD9HYXcgWC/k=;
 b=suQrFf924z0BdrIsmSnZGQoYEcCkpq8xIbN/TdIRF+qp/MF+Gnk9iN3SjSIVjTR1G6
 pSNv+MmbURrz8m8UQ6J3rJNbCTKmRtDckjQBQPIFmmb+NPU62GbnYgM0LCqoF7tcsW7B
 rWNELXTU0Rybg4c0qTpL7wZbf3O7/z64hmAAhggwmI7tJWM0LRDPjkXBrC7s1SsLlsOG
 faX7aawtIWU9EWNAXr94YTKl2NzkNqWOH7DfAefOWqpaKq/bxQnDcWDZmRRtxJCaD0Cw
 kQIrRleJkky3xwy0S9XBebiRjbVPrdEIf6UdWNGm/GhnDj2yzR6Y2GnIt4b9sr+eMiSg
 6/5Q==
X-Gm-Message-State: AOAM532K0FYIiNWJ1t0wlh15xFeW+aSlIDykwVxWeISnP7rsymyqvycD
 zliX2Um3+tYXkIqVYJ9HxbenbwkxxTNxmLanvyw=
X-Google-Smtp-Source: ABdhPJxT3MVZFdXRiktZytixxJYH/g52Rzd4ej1B/B/6AaacDeKHj7pSvVmudEo7lSKi4TSWV3mmIU7KhXAqNfkE9GM=
X-Received: by 2002:a17:902:6803:b029:d2:42a6:312 with SMTP id
 h3-20020a1709026803b02900d242a60312mr3734880plk.24.1603825748736; Tue, 27 Oct
 2020 12:09:08 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1600951211.git.yifeifz2@illinois.edu>
 <9ede6ef35c847e58d61e476c6a39540520066613.1600951211.git.yifeifz2@illinois.edu>
 <CAMuHMdXTLKr6pvoE+JAdn_P5kVxL6gx8PJ8mqfXcS+SF+pRbkQ@mail.gmail.com>
In-Reply-To: <CAMuHMdXTLKr6pvoE+JAdn_P5kVxL6gx8PJ8mqfXcS+SF+pRbkQ@mail.gmail.com>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Tue, 27 Oct 2020 14:08:56 -0500
Message-ID: <CABqSeAQvZNF4ynayT1XjEm4eP2H-ee46zBwmVRRD1-ZpohqG4w@mail.gmail.com>
Subject: Re: [PATCH v2 seccomp 1/6] seccomp: Move config option SECCOMP to
 arch/Kconfig
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Kees Cook <keescook@chromium.org>,
 Jann Horn <jannh@google.com>, YiFei Zhu <yifeifz2@illinois.edu>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
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

On Tue, Oct 27, 2020 at 4:52 AM Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> Please tell me why SECCOMP is special, and deserves to default to be
> enabled.  Is it really that critical, given only 13.5 (half of sparc
> ;-) out of 24
> architectures implement support for it?

Good point. My thought process is that quite a few system software are
reliant on seccomp for enforcing policies -- systemd, docker, and
other sandboxing tools like browsers and firejail, so when I moved
this to the non-perarch section, it at least has to be default for
x86. Granted, I'm not super familiar with other architectures, so you
are probably right that those that did not have it on by default
should be kept off by default; many of them could be for embedded
devices. What's the best way to do this? Set it as default N in
Kconfig and add CONFIG_SECCOMP=y in each arch's defconfig?

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
