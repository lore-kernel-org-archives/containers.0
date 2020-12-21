Return-Path: <SRS0=sUbK=FZ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-18.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8A7FC433DB
	for <containers@archiver.kernel.org>; Mon, 21 Dec 2020 17:14:56 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 5C8FA22BF3
	for <containers@archiver.kernel.org>; Mon, 21 Dec 2020 17:14:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C8FA22BF3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=paul-moore.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 03A1286B9A;
	Mon, 21 Dec 2020 17:14:56 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ZEBDhu0W7wVk; Mon, 21 Dec 2020 17:14:55 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 4E21E85D6F;
	Mon, 21 Dec 2020 17:14:55 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 3D23AC1825;
	Mon, 21 Dec 2020 17:14:55 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 3A3E7C0893
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Dec 2020 17:14:54 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 2966D87267
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Dec 2020 17:14:54 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id kn9Ky5-s7y6J
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Dec 2020 17:14:52 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ej1-f49.google.com (mail-ej1-f49.google.com
 [209.85.218.49])
 by whitealder.osuosl.org (Postfix) with ESMTPS id B6AFC86968
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Dec 2020 17:14:51 +0000 (UTC)
Received: by mail-ej1-f49.google.com with SMTP id lt17so14477388ejb.3
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Dec 2020 09:14:51 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=paul-moore-com.20150623.gappssmtp.com; s=20150623;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=RDT3CMWkb5v4KlAY6bNjmDFLqwN6ZEiRSV+Z6DSzr0s=;
 b=jrj8LYfQ+G2abRBjq/EQNO52IGqX1ROGqjr73asfsMUx2io1t/Kj5vaWeNRQ05QBws
 7ORYHBk1SfigU2h39+yGI1Lk3AhN50Cgw2pM71/m4zP1hwb+ikD3+K55GDIFL6cu4N9x
 ZXqkVEqq4e9zYCD39Pgl2Yl2UyuINtmv3u1EhVxYVIV2oRUT+oNTfNWmFPJ0oiSuI1AA
 DmducotL7D+1FUZXOZvqHAm9lf7QMa82bUozYx7IzidUTWK7x6Iib27Ho/jYH5ne0Z0S
 Of1Dbmmu0Q124UefwB1rJjBdPSQEFSj36Hggs/J2Zs9T0HFyX0niq795BUINRYC4pEQ5
 L9qw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=RDT3CMWkb5v4KlAY6bNjmDFLqwN6ZEiRSV+Z6DSzr0s=;
 b=EHNFSZKZOpCxMK0wWt8MiP3/cQljEBhnBexWnXlUYUIAgK7BrzwnNrWRlRmgp3MgjN
 QqKKrz2VRhkcjH+xDLcVTsrTFXRoIN0eIZqv0E5sQuwXRJ3SgGbh+hib/WW/PwUYTWel
 CJE06JsGWJSJr43VfhX1FdxJRVZinnBWFLlWYPzE8sJdnAL49FcaY2XTunpEt9ztJoVa
 8rlKXodqz9baBqjJWeE6hrM5sJ15u/ggDsNmrgSkJvaiyjTomduSIp+Qyb2Y5MAUCeNs
 eFckheLWcSJEVdjBEYjbe0X7SoYkJ27rTPoXI3Y3bbsU4dAt00FKGcNcdsPW3WLY6SQl
 JUPA==
X-Gm-Message-State: AOAM530jlHnRZVlxt04XT20K2zLCqlg0vtzl24/mg9ctX3/4cklqXhjH
 nSw/+efVToKkO1dz+toYtm+/SOlMQL4+lMiejTv9
X-Google-Smtp-Source: ABdhPJwPBtlia5uDw63ingozAyc7AR0jROeP8m6nydP3bWYSBIMRH20XUWt+8TeXFSZsv23dBiOY4HZ+Ga0eJQoO4Vg=
X-Received: by 2002:a17:907:d9e:: with SMTP id
 go30mr15735065ejc.488.1608570889830; 
 Mon, 21 Dec 2020 09:14:49 -0800 (PST)
MIME-Version: 1.0
References: <cover.1608225886.git.rgb@redhat.com>
 <982b9adffbd32264a853fe7f4f06f0d0a882c11d.1608225886.git.rgb@redhat.com>
In-Reply-To: <982b9adffbd32264a853fe7f4f06f0d0a882c11d.1608225886.git.rgb@redhat.com>
From: Paul Moore <paul@paul-moore.com>
Date: Mon, 21 Dec 2020 12:14:38 -0500
Message-ID: <CAHC9VhSTuBJ3LXxMY=nD7qBzmKLDjXY0V3hsuN34_siq_xRrig@mail.gmail.com>
Subject: Re: [PATCH ghak90 v10 01/11] audit: collect audit task parameters
To: Richard Guy Briggs <rgb@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, Neil Horman <nhorman@tuxdriver.com>,
 Linux API <linux-api@vger.kernel.org>,
 Linux Containers List <containers@lists.linux-foundation.org>,
 LKML <linux-kernel@vger.kernel.org>, David Howells <dhowells@redhat.com>,
 Linux-Audit Mailing List <linux-audit@redhat.com>,
 Netfilter Devel List <netfilter-devel@vger.kernel.org>,
 "Eric W. Biederman" <ebiederm@xmission.com>, Simo Sorce <simo@redhat.com>,
 Linux NetDev Upstream Mailing List <netdev@vger.kernel.org>,
 Linux FSdevel <linux-fsdevel@vger.kernel.org>,
 Eric Paris <eparis@parisplace.org>, mpatel@redhat.com
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

On Mon, Dec 21, 2020 at 11:57 AM Richard Guy Briggs <rgb@redhat.com> wrote:
>
> The audit-related parameters in struct task_struct should ideally be
> collected together and accessed through a standard audit API and the audit
> structures made opaque to other kernel subsystems.
>
> Collect the existing loginuid, sessionid and audit_context together in a
> new opaque struct audit_task_info called "audit" in struct task_struct.
>
> Use kmem_cache to manage this pool of memory.
> Un-inline audit_free() to be able to always recover that memory.
>
> Please see the upstream github issues
> https://github.com/linux-audit/audit-kernel/issues/81
> https://github.com/linux-audit/audit-kernel/issues/90
>
> Signed-off-by: Richard Guy Briggs <rgb@redhat.com>
> Acked-by: Neil Horman <nhorman@tuxdriver.com>
> Reviewed-by: Ondrej Mosnacek <omosnace@redhat.com>

Did Neil and Ondrej really ACK/Review the changes that you made here
in v10 or are you just carrying over the ACK/Review?  I'm hopeful it
is the former, because I'm going to be a little upset if it is the
latter.

> ---
>  fs/io-wq.c            |   8 +--
>  fs/io_uring.c         |  16 ++---
>  include/linux/audit.h |  49 +++++---------
>  include/linux/sched.h |   7 +-
>  init/init_task.c      |   3 +-
>  init/main.c           |   2 +
>  kernel/audit.c        | 154 +++++++++++++++++++++++++++++++++++++++++-
>  kernel/audit.h        |   7 ++
>  kernel/auditsc.c      |  24 ++++---
>  kernel/fork.c         |   1 -
>  10 files changed, 205 insertions(+), 66 deletions(-)

-- 
paul moore
www.paul-moore.com
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
