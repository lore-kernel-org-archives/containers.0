Return-Path: <SRS0=ql3H=ED=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0CD80C4363A
	for <containers@archiver.kernel.org>; Wed, 28 Oct 2020 22:56:15 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 66F2220732
	for <containers@archiver.kernel.org>; Wed, 28 Oct 2020 22:56:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="SEdMz9fs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66F2220732
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id DD7738739A;
	Wed, 28 Oct 2020 22:56:13 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ha4Btuy0v-0s; Wed, 28 Oct 2020 22:56:13 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 7533487289;
	Wed, 28 Oct 2020 22:56:13 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 527A0C088B;
	Wed, 28 Oct 2020 22:56:13 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id C8CDCC0051
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 22:56:11 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id B351487362
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 22:56:11 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id eNRmC8bgPN0M
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 22:56:08 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pl1-f170.google.com (mail-pl1-f170.google.com
 [209.85.214.170])
 by hemlock.osuosl.org (Postfix) with ESMTPS id A8A1387289
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 22:56:08 +0000 (UTC)
Received: by mail-pl1-f170.google.com with SMTP id z1so347400plo.12
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 15:56:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=6zGOuhTIRZSvVyxx3m4aE8CgCO2YW8w7ueb9xYPds3c=;
 b=SEdMz9fsLWNQgMVzf4o0RAPD/AcIAPbuNHJfefzMBnk/O9d9g6sgbDmqXfCec5Xzxj
 caBrjlmHD8fifIVTuqhHxUI5XhRh2T890Af5tLexqvSiZ266TQyAe+pQq/Xy1hRXF9YR
 +U+lTkSiEjRN3SU9Xq1u0+VGj18uqELgouFRA=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=6zGOuhTIRZSvVyxx3m4aE8CgCO2YW8w7ueb9xYPds3c=;
 b=cT+1mcE/BONzeyGiEczWOklFlD0VXO0yJuvA8a65Zude4JszWlXOs1UfotFVEjjf7A
 9RP652UQxDIcNXDMuHRp3MArUo1z+T7F/bweZRhPyQuFj/52AcE7KYuMQ64ixib02czJ
 44O0LpJHGWm7KxTveXusTnODbYp0DkzP8nwPKN3PdWriZZ3EWZQA+uiDSPSwPjahSAjS
 RF7jleC8fFNnqjMct5zmeuS3lLnvRsdyLD5ML0y/b/DM5HCmlMhCq6/9hWoE8cxlmgmK
 HohXTzp/d7PaeP92/RASXTdxBFugwqm7Wx+y5d8+17cGIZOTRU6d0hxVfbt2AMnK0DbW
 dOVw==
X-Gm-Message-State: AOAM532Bxf5X05sh4XUcZgJ1NJlIyVAp6EcUx1sKhNf8S+TV5/v0FJ+E
 Z3XsSf76An59Vg5aoaQd6E6fSQ==
X-Google-Smtp-Source: ABdhPJwAExtMg0Y9nbbQflCfUuQOXDWjgWSEdOk1MQhIgdQjFdwVeqs8tTy00tz6CV1C4vksZxX49Q==
X-Received: by 2002:a17:902:b90c:b029:d6:868d:f566 with SMTP id
 bf12-20020a170902b90cb02900d6868df566mr913093plb.2.1603925768287; 
 Wed, 28 Oct 2020 15:56:08 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id m129sm637972pfd.177.2020.10.28.15.56.07
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 28 Oct 2020 15:56:07 -0700 (PDT)
Date: Wed, 28 Oct 2020 15:56:06 -0700
From: Kees Cook <keescook@chromium.org>
To: Jann Horn <jannh@google.com>
Subject: Re: For review: seccomp_user_notif(2) manual page
Message-ID: <202010281553.A72E162A7@keescook>
References: <45f07f17-18b6-d187-0914-6f341fe90857@gmail.com>
 <20200930150330.GC284424@cisco>
 <8bcd956f-58d2-d2f0-ca7c-0a30f3fcd5b8@gmail.com>
 <20200930230327.GA1260245@cisco>
 <CAG48ez1VOUEHVQyo-2+uO7J+-jN5rh7=KmrMJiPaFjwCbKR1Sg@mail.gmail.com>
 <20200930232456.GB1260245@cisco>
 <CAG48ez2xn+_KznEztJ-eVTsTzkbf9CVgPqaAk7TpRNAqbdaRoA@mail.gmail.com>
 <202010251725.2BD96926E3@keescook>
 <CAG48ez2b-fnsp8YAR=H5uRMT4bBTid_hyU4m6KavHxDko1Efog@mail.gmail.com>
 <CAG48ez2OWhpH3HHUJSrAmokJ8=SVwKrmQMSw0gEbTJmKE4myCw@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAG48ez2OWhpH3HHUJSrAmokJ8=SVwKrmQMSw0gEbTJmKE4myCw@mail.gmail.com>
Cc: linux-man <linux-man@vger.kernel.org>, Song Liu <songliubraving@fb.com>,
 Will Drewry <wad@chromium.org>, Robert Sesek <rsesek@google.com>,
 Daniel Borkmann <daniel@iogearbox.net>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 lkml <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
 "Michael Kerrisk \(man-pages\)" <mtk.manpages@gmail.com>,
 bpf <bpf@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>,
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Mon, Oct 26, 2020 at 11:31:01AM +0100, Jann Horn wrote:
> Or I guess we could also just set O_NONBLOCK on the fd by default?
> Since the one existing user is eventloop-based...

I thought about that initially, but it rubs me the wrong way: it
violates least-surprise for me. File descriptors are expected to be
default-blocking. It *is* a special fd, though, so maybe it could work.
The only case I can think of it would break would be ioctl-loop case
that is already buggy in that it didn't handle non-zero returns?

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
