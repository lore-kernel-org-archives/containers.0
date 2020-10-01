Return-Path: <SRS0=WbUC=DI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BFF3FC4727E
	for <containers@archiver.kernel.org>; Thu,  1 Oct 2020 16:19:14 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 29ABC208B6
	for <containers@archiver.kernel.org>; Thu,  1 Oct 2020 16:19:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kKCa/HMc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29ABC208B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id EB38A23600;
	Thu,  1 Oct 2020 16:19:13 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id plcUT4XpAvdz; Thu,  1 Oct 2020 16:19:12 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id B6860203EF;
	Thu,  1 Oct 2020 16:19:12 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id AB4C5C0889;
	Thu,  1 Oct 2020 16:19:12 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 79F47C0051
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 16:19:11 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 66F9086980
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 16:19:11 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id lNo8Vxtw4YFB
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 16:19:11 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pg1-f195.google.com (mail-pg1-f195.google.com
 [209.85.215.195])
 by whitealder.osuosl.org (Postfix) with ESMTPS id E8A0F8697D
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 16:19:10 +0000 (UTC)
Received: by mail-pg1-f195.google.com with SMTP id 34so4381592pgo.13
 for <containers@lists.linux-foundation.org>;
 Thu, 01 Oct 2020 09:19:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=MJEN6/5FxUZ7OvX1MfoZIJYkf9njQgwG4hA1l6IMw0I=;
 b=kKCa/HMcidopfQYMgG1MnaV4E7MWeG0ZNU2ueVB6Ep4OYWvKYggKjzJkKTPBYAwfmU
 gDmiCAvNG6U+UyrWHMC4lpV7wI+FQ0u/iuWVHEVsOvXRxPjp1V7PkDYtTs4wIJpOrMVY
 F/3NMyqKUlnHboeHra8Rz17oKGWWKqsgaVoSUVOG4Zp89vGQNUvWDuGQjdA9/qD2wZSl
 ERDpbN98d5N105oqojlolCytrAGPVuFQ7PRqf7i7o2t6B0UxU5SFS2kokt4F4x/GxFLm
 VoBTG8G+9voKvVPNpHrJo425NMhCQOl3OlYzCiG/TGFTFIkIxGMpvQ85PMuSX5eq4u0C
 nArg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=MJEN6/5FxUZ7OvX1MfoZIJYkf9njQgwG4hA1l6IMw0I=;
 b=MU//wj9ce+8oD+TrU/3ap4JysVCiwCoU9J5WYlz2zMHZJ6LXCOk0nr/Zw1bEGpCVhE
 2YcGwG5FjqxxPo3htnRBqStyBSdfwr0TfZTGHyrNGNAfbrkV1MXvVun0l5koBmKxLAxc
 YFaKIeKW2vRwq5eStNdj16f4GmAI/iWwRu8CBdFfNZn+sal5FVMysfLfClsxloggVarJ
 rumepluqfBlpj6qNA+cwF/b2Q4Jo5Vzzvu9nfVuhwRMCo2OE8X931abI9Feb3WFOrURp
 mAbpK3AJgzMTc3Jnib6QvL+Uukg4X8GsMUb+yUlxNfXO3cb2UOKmYi0DqKOLJqtDJim/
 ULKg==
X-Gm-Message-State: AOAM531HbazO/7XmnTJ1I3cd0S713rH/YVihkZD7UyWaXOnFcZcBVHRi
 qP20aywnjBRhfqgBZ8M29Ic5mU5qxv74gFZWrN8=
X-Google-Smtp-Source: ABdhPJyjU9K2yAHHlgJFP8jH9bKHRFNEu8FPzsXId8yBn7IKSN8taOEKNIEPNUGKxDexWM2C51Vpy6MLxd3XFzl9Z4c=
X-Received: by 2002:a63:5043:: with SMTP id q3mr6682178pgl.293.1601569150444; 
 Thu, 01 Oct 2020 09:19:10 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1601478774.git.yifeifz2@illinois.edu>
 <d3d1c05ea0be2b192f480ec52ad64bffbb22dc9d.1601478774.git.yifeifz2@illinois.edu>
 <CAG48ez0whaSTobwnoJHW+Eyqg5a8H4JCO-KHrgsuNiEg0qbD3w@mail.gmail.com>
 <CABqSeATEMTB_hRt9D9teW6GcDvz4VLfMQyvX=nvgR4Uu4+AgoA@mail.gmail.com>
 <CAG48ez3nqG_O3OYLLffVOcFf+ONgFwU9mc+HZ1GixBPbHZLyvw@mail.gmail.com>
In-Reply-To: <CAG48ez3nqG_O3OYLLffVOcFf+ONgFwU9mc+HZ1GixBPbHZLyvw@mail.gmail.com>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Thu, 1 Oct 2020 11:18:59 -0500
Message-ID: <CABqSeATH+n5EdxboQWz84oFYkAnkbAgnjU4irBDqJPTLdExTHA@mail.gmail.com>
Subject: Re: [PATCH v3 seccomp 5/5] seccomp/cache: Report cache data through
 /proc/pid/seccomp_cache
To: Jann Horn <jannh@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Kees Cook <keescook@chromium.org>,
 YiFei Zhu <yifeifz2@illinois.edu>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>,
 kernel list <linux-kernel@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Hubertus Franke <frankeh@us.ibm.com>,
 David Laight <David.Laight@aculab.com>, Jack Chen <jianyan2@illinois.edu>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
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

On Thu, Oct 1, 2020 at 11:05 AM Jann Horn <jannh@google.com> wrote:
> Yeah.
>
> The ONE() entry you're adding to tgid_base_stuff is used to help
> instantiate a "struct inode" when someone looks up the path
> "/proc/$tgid/seccomp_cache"; then when that path is opened, a "struct
> file" is created that holds a reference to the inode; and while that
> file exists, your proc_pid_seccomp_cache() can be invoked.
>
> proc_pid_seccomp_cache() is invoked from proc_single_show()
> ("PROC_I(inode)->op.proc_show" is proc_pid_seccomp_cache), and
> proc_single_show() obtains a temporary reference to the task_struct
> using get_pid_task() on a "struct pid" and drops that reference
> afterwards with put_task_struct(). The "struct pid" is obtained from
> the "struct proc_inode", which is essentially a subclass of "struct
> inode". The "struct pid" is kept refererenced until the inode goes
> away, via proc_pid_evict_inode(), called by proc_evict_inode().
>
> By looking at put_task_struct() and its callees, you can figure out
> which parts of the "struct task" are kept alive by the reference to
> it.

Ah I see. Thanks for the explanation.

> By the way, maybe it'd make sense to add this to tid_base_stuff as
> well? That should just be one extra line of code. Seccomp filters are
> technically per-thread, so it would make sense to have them visible in
> the per-thread subdirectories /proc/$pid/task/$tid/.

Right. Will do.

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
