Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3AE70C4346E
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 23:57:00 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 78FA4221E2
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 23:56:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="ZoSBF1dT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78FA4221E2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id D2DD62E114;
	Thu, 24 Sep 2020 23:56:58 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id a6DMDEwx9w-9; Thu, 24 Sep 2020 23:56:56 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id BADDC2034B;
	Thu, 24 Sep 2020 23:56:56 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id AB47AC0889;
	Thu, 24 Sep 2020 23:56:56 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 5CDAAC0051
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 23:56:55 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 449AC87537
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 23:56:55 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 3PS9USxVcAMv
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 23:56:54 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pj1-f68.google.com (mail-pj1-f68.google.com
 [209.85.216.68])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 872D387534
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 23:56:54 +0000 (UTC)
Received: by mail-pj1-f68.google.com with SMTP id b17so780706pji.1
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 16:56:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=PEQHQdRyQ9xsSCdQzKyvMmoiCwe5AhDytk6haiQYAYA=;
 b=ZoSBF1dT+8ZzaoiNAlcF2KrzB+hxJVDnGMsShZQ+860GdXPO2wmj7dDRwbYZeZ6FP0
 tzTDEEpd16UQ9NlRiaEe6R1ZIMkEjYQrDuWy5groU3A3GHraaAl994ENGTGfOqf1E+be
 7Fd1TTa/XVDOW8VwnCn8keFubI4lgYN/gRBv4=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=PEQHQdRyQ9xsSCdQzKyvMmoiCwe5AhDytk6haiQYAYA=;
 b=m7L1IL2ancdugiXUHUeq/ytxI+I13lS3qPxImwB10LGILT96FpmiBsRwPHN72Ab4E0
 dWnbEenPw3koKMZT7pTUUfvO5HZjfnq/TE5nh1pgDKleM2ywwdIAz0WfFQn34j5QAI7L
 bLFcPjw/GstLEoM3gQBRbPEsRrwfXfcBCh5CxIdKTm41AsKgxdeU7Pw/N/4HLg38ijed
 wq1fYlPbkmCG5xY2DfHo1MRQ+YO15GI2AI4X12KHdZCqUrIZ6j33IvR/GkEok7hxNICJ
 fBdKpgHvnFj2iXcd2NyYL3T25FS2SpRIPw3uN1yKG2GA2hWKLyvF7DnNt6oxqR2QfHNI
 VjhQ==
X-Gm-Message-State: AOAM532D0ux9l5uQLtQRwlzY2WDFYuDjftl2jBmrlBdcYf4zZwUHcsuO
 4ia85qseBmv7XKFO01UTpkbiMg==
X-Google-Smtp-Source: ABdhPJzyfryL0iIu0PMOcXe+glEbhoRCWk4I6igRlfPAIK3CdtHgMQxMMQcPAkl7466Tlrc0Ju8TcA==
X-Received: by 2002:a17:90a:db56:: with SMTP id u22mr95780pjx.85.1600991814140; 
 Thu, 24 Sep 2020 16:56:54 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id d25sm418889pgl.23.2020.09.24.16.56.52
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Thu, 24 Sep 2020 16:56:53 -0700 (PDT)
Date: Thu, 24 Sep 2020 16:56:52 -0700
From: Kees Cook <keescook@chromium.org>
To: YiFei Zhu <zhuyifei1999@gmail.com>
Subject: Re: [PATCH v2 seccomp 6/6] seccomp/cache: Report cache data through
 /proc/pid/seccomp_cache
Message-ID: <202009241647.2239747F0@keescook>
References: <cover.1600951211.git.yifeifz2@illinois.edu>
 <b11ebe533838af7829a5e7381a7914bca27cb621.1600951211.git.yifeifz2@illinois.edu>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <b11ebe533838af7829a5e7381a7914bca27cb621.1600951211.git.yifeifz2@illinois.edu>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Jann Horn <jannh@google.com>,
 YiFei Zhu <yifeifz2@illinois.edu>, containers@lists.linux-foundation.org,
 Tobin Feldman-Fitzthum <tobin@ibm.com>, linux-kernel@vger.kernel.org,
 Andy Lutomirski <luto@amacapital.net>, Hubertus Franke <frankeh@us.ibm.com>,
 Jack Chen <jianyan2@illinois.edu>, Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 Josep Torrellas <torrella@illinois.edu>, Will Drewry <wad@chromium.org>,
 bpf@vger.kernel.org, Tianyin Xu <tyxu@illinois.edu>
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

On Thu, Sep 24, 2020 at 07:44:21AM -0500, YiFei Zhu wrote:
> From: YiFei Zhu <yifeifz2@illinois.edu>
> 
> Currently the kernel does not provide an infrastructure to translate
> architecture numbers to a human-readable name. Translating syscall
> numbers to syscall names is possible through FTRACE_SYSCALL
> infrastructure but it does not provide support for compat syscalls.
> 
> This will create a file for each PID as /proc/pid/seccomp_cache.
> The file will be empty when no seccomp filters are loaded, or be
> in the format of:
> <hex arch number> <decimal syscall number> <ALLOW | FILTER>
> where ALLOW means the cache is guaranteed to allow the syscall,
> and filter means the cache will pass the syscall to the BPF filter.
> 
> For the docker default profile on x86_64 it looks like:
> c000003e 0 ALLOW
> c000003e 1 ALLOW
> c000003e 2 ALLOW
> c000003e 3 ALLOW
> [...]
> c000003e 132 ALLOW
> c000003e 133 ALLOW
> c000003e 134 FILTER
> c000003e 135 FILTER
> c000003e 136 FILTER
> c000003e 137 ALLOW
> c000003e 138 ALLOW
> c000003e 139 FILTER
> c000003e 140 ALLOW
> c000003e 141 ALLOW
> [...]
> 
> This file is guarded by CONFIG_PROC_SECCOMP_CACHE with a default
> of N because I think certain users of seecomp might not want the
> application to know which syscalls are definitely usable.
> 
> I'm not sure if adding all the "human readable names" is worthwhile,
> considering it can be easily done in userspace.

The question of permissions is my central concern here: who should see
this? Some contained processes have been intentionally blocked from
self-introspection so even the "standard" high bar of "ptrace attach
allowed?" can't always be sufficient.

My compromise about filter visibility in the past was saying that
CAP_SYS_ADMIN was required (see seccomp_get_filter()). I'm nervous to
weaken this. (There is some work that hasn't been sent upstream yet that
is looking to expose the filter _contents_ via /proc that has been
nervous too.)

Now full contents vs "allow"/"filter" are certainly different things,
but I don't feel like I've got enough evidence to show that this
introspection would help debugging enough to justify the partially
imagined safety of not exposing it to potential attackers.

I suspect it _is_ the right thing to do (just look at my own RFC's
"debug" patch), but I'd like this to be well justified in the commit
log.

And yes, while it does hide behind a CONFIG, I'd still want it justified,
especially since distros have a tendency to just turn everything on
anyway. ;)

> +	for (arch = 0; arch < ARRAY_SIZE(syscall_arches); arch++) {
> +		for (nr = 0; nr < NR_syscalls; nr++) {
> +			bool cached = test_bit(nr, f->cache.syscall_ok[arch]);
> +			char *status = cached ? "ALLOW" : "FILTER";
> +
> +			seq_printf(m, "%08x %d %s\n", syscall_arches[arch],
> +				   nr, status
> +			);
> +		}
> +	}

But behavior-wise, yeah, I like it; I'm fine with human-readable and
full AUDIT_ARCH values. (Though, as devil's advocate again, to repeat
Jann's own words back: do we want to add this only to have a new UAPI to
support going forward?)

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
