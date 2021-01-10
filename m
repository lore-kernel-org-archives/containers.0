Return-Path: <SRS0=9Mj4=GN=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94D47C433E0
	for <containers@archiver.kernel.org>; Sun, 10 Jan 2021 18:46:31 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 1BD2C227BF
	for <containers@archiver.kernel.org>; Sun, 10 Jan 2021 18:46:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1BD2C227BF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 3C593866A9;
	Sun, 10 Jan 2021 18:46:30 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id L-Y9ZFARLjhO; Sun, 10 Jan 2021 18:46:29 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 5F8BE86693;
	Sun, 10 Jan 2021 18:46:29 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 458E4C0893;
	Sun, 10 Jan 2021 18:46:29 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 1B6DEC013A
 for <containers@lists.linux-foundation.org>;
 Sun, 10 Jan 2021 18:46:28 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id F191220384
 for <containers@lists.linux-foundation.org>;
 Sun, 10 Jan 2021 18:46:27 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id MMb+avZooLay
 for <containers@lists.linux-foundation.org>;
 Sun, 10 Jan 2021 18:46:27 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-lf1-f52.google.com (mail-lf1-f52.google.com
 [209.85.167.52])
 by silver.osuosl.org (Postfix) with ESMTPS id DEAA620362
 for <containers@lists.linux-foundation.org>;
 Sun, 10 Jan 2021 18:46:26 +0000 (UTC)
Received: by mail-lf1-f52.google.com with SMTP id h205so34689758lfd.5
 for <containers@lists.linux-foundation.org>;
 Sun, 10 Jan 2021 10:46:26 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=linux-foundation.org; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=eQXV1o093eVpYrQ6SjYKMkYU2gxMAjF5N9e9XTlzNEE=;
 b=ZeHp/DLnTCjx/1ndzrrdXLbs+ofveQ60Mwd9VBFVezBZLlHfmdd3j2voOnqpw8488y
 HaLlr1rUwDJNnpcMRpAOAtKBNTqrWuGc2WNSPVEBGtVTzQC0Vzx8mbTatpAO5uM8+7wD
 /TrltXUH7SyNTMyWDX+1SlvDZZeSfzqrCwLlo=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=eQXV1o093eVpYrQ6SjYKMkYU2gxMAjF5N9e9XTlzNEE=;
 b=pONU50XDx9ZUkRTpoCiaWXkVrcc5n8b9KzZEu+Y+Ecwas70fVclG6HSRJgptFksh8a
 f3z/wtpcQ4BNRZ+HKalNMOLmW0tiDWfZ2EVMKgTF6lsJWUQnDQWZ6KftnY+2Vlmq+h7Q
 c208I3IlkKUc/DcNomwTwLV6C76JEmSlXEhtmGSydz215usD4erQ+TuDESg8bTif7CCi
 RiIlJDVAl8hgEqizLRYTNB5QJBxPjvRbZa3Jnn3Mynuxywk5Ecj9uKBsNO6rDlE5+qJZ
 LFfKDN9sK3roE0N4+oB0ZnTsdDv0FrHro1Omj9xNiCtf8cKutrJpiwhKOP/XMNg0qG0G
 TvRA==
X-Gm-Message-State: AOAM533I12FdY57NGcZm+2tD9c0BejHavVvBxjCP7p+EE8K8jRzkS4cK
 TiOEvCks9JXRU6lC43oA6HinRdpXdMteWRsm
X-Google-Smtp-Source: ABdhPJxi4OywPcFqV2ijXCUpCBSSa06pezsMwS7G1tit6UEEKZSlLB218Aab8uZPUXDvRwyp0+QwHQ==
X-Received: by 2002:ac2:5333:: with SMTP id f19mr6182242lfh.344.1610304384291; 
 Sun, 10 Jan 2021 10:46:24 -0800 (PST)
Received: from mail-lj1-f172.google.com (mail-lj1-f172.google.com.
 [209.85.208.172])
 by smtp.gmail.com with ESMTPSA id e6sm2799796lfc.23.2021.01.10.10.46.23
 for <containers@lists.linux-foundation.org>
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Sun, 10 Jan 2021 10:46:23 -0800 (PST)
Received: by mail-lj1-f172.google.com with SMTP id u11so1152223ljo.13
 for <containers@lists.linux-foundation.org>;
 Sun, 10 Jan 2021 10:46:23 -0800 (PST)
X-Received: by 2002:a2e:9b13:: with SMTP id u19mr5614023lji.48.1610304382840; 
 Sun, 10 Jan 2021 10:46:22 -0800 (PST)
MIME-Version: 1.0
References: <cover.1610299857.git.gladkov.alexey@gmail.com>
In-Reply-To: <cover.1610299857.git.gladkov.alexey@gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 10 Jan 2021 10:46:05 -0800
X-Gmail-Original-Message-ID: <CAHk-=wgXZmRu762bjSeK80+T_LTo+UP9y5rP-uvym1vquSxmBw@mail.gmail.com>
Message-ID: <CAHk-=wgXZmRu762bjSeK80+T_LTo+UP9y5rP-uvym1vquSxmBw@mail.gmail.com>
Subject: Re: [RFC PATCH v2 0/8] Count rlimits in each user namespace
To: Alexey Gladkov <gladkov.alexey@gmail.com>
Cc: Kees Cook <keescook@chromium.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 LKML <linux-kernel@vger.kernel.org>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 Alexey Gladkov <legion@kernel.org>, Christian Brauner <christian@brauner.io>
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

On Sun, Jan 10, 2021 at 9:34 AM Alexey Gladkov <gladkov.alexey@gmail.com> wrote:
>
> To address the problem, we bind rlimit counters to each user namespace. The
> result is a tree of rlimit counters with the biggest value at the root (aka
> init_user_ns). The rlimit counter increment/decrement occurs in the current and
> all parent user namespaces.

I'm not seeing why this is necessary.

Maybe it's the right approach, but none of the patches (or this cover
letter email) really explain it to me.

I understand why you might want the _limits_ themselves would form a
tree like this - with the "master limit" limiting the limits in the
user namespaces under it.

But I don't understand why the _counts_ should do that. The 'struct
user_struct' should be shared across even user namespaces for the same
user.

IOW, the very example of the problem you quote seems to argue against this:

> For example, there are two containers (A and B) created by one user. The
> container A sets RLIMIT_NPROC=1 and starts one process. Everything is fine, but
> when container B tries to do the same it will fail because the number of
> processes is counted globally for each user and user has one process already.

Note how the problem was _not_ that the _count_ was global. That part
was fine and all good.

No, the problem was that the _limit_ in container A also ended up
affecting container B.

So to me, that says that it would make sense to continue to use the
resource counts in 'struct user_struct' (because if user A has a hard
limit of X, then creating a new namespace shouldn't expand that
limit), but then have the ability to make per-container changes to the
resource limits (as long as they are within the bounds of the parent
user namespace resource limit).

Maybe there is some reason for this ucounts approach, but if so, I
feel it was not explained at all.

             Linus
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
