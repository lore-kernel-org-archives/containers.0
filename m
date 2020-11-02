Return-Path: <SRS0=UpRV=EI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9403C00A89
	for <containers@archiver.kernel.org>; Mon,  2 Nov 2020 17:30:33 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2B0432225E
	for <containers@archiver.kernel.org>; Mon,  2 Nov 2020 17:30:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B0432225E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 9E714866F3;
	Mon,  2 Nov 2020 17:30:32 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id sRQ5ac7K4nmK; Mon,  2 Nov 2020 17:30:31 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id EC86786688;
	Mon,  2 Nov 2020 17:30:31 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id C004EC0889;
	Mon,  2 Nov 2020 17:30:31 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id C5FAFC0051
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 17:30:30 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id AF0FA86C67
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 17:30:30 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 1Fq_dst7pXMA
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 17:30:30 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from raptor.unsafe.ru (raptor.unsafe.ru [5.9.43.93])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 233CC86C4D
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 17:30:30 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6
 (ip-89-103-122-167.net.upcbroadband.cz [89.103.122.167])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits))
 (No client certificate requested)
 by raptor.unsafe.ru (Postfix) with ESMTPSA id 028AA209AF;
 Mon,  2 Nov 2020 17:30:28 +0000 (UTC)
Date: Mon, 2 Nov 2020 18:30:24 +0100
From: Alexey Gladkov <gladkov.alexey@gmail.com>
To: Jann Horn <jannh@google.com>
Subject: Re: [RFC PATCH v1 4/4] Allow to change the user namespace in which
 user rlimits are counted
Message-ID: <20201102173024.oflzudkq6cnolqyr@comp-core-i7-2640m-0182e6>
References: <cover.1604335819.git.gladkov.alexey@gmail.com>
 <2718f7b13189dfd159414efb68e3533552593140.1604335819.git.gladkov.alexey@gmail.com>
 <CAG48ez0zGoB4Pr_+nLKaycCgEUtUrAvLJ89JG1ZbcbjKChMcng@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAG48ez0zGoB4Pr_+nLKaycCgEUtUrAvLJ89JG1ZbcbjKChMcng@mail.gmail.com>
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.1
 (raptor.unsafe.ru [5.9.43.93]); Mon, 02 Nov 2020 17:30:29 +0000 (UTC)
Cc: Kees Cook <keescook@chromium.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 LKML <linux-kernel@vger.kernel.org>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
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

On Mon, Nov 02, 2020 at 06:10:06PM +0100, Jann Horn wrote:
> On Mon, Nov 2, 2020 at 5:52 PM Alexey Gladkov <gladkov.alexey@gmail.com> wrote:
> > Add a new prctl to change the user namespace in which the process
> > counter is located. A pointer to the user namespace is in cred struct
> > to be inherited by all child processes.
> [...]
> > +       case PR_SET_RLIMIT_USER_NAMESPACE:
> > +               if (!capable(CAP_SYS_RESOURCE))
> > +                       return -EPERM;
> > +
> > +               switch (arg2) {
> > +               case PR_RLIMIT_BIND_GLOBAL_USERNS:
> > +                       error = set_rlimit_ns(&init_user_ns);
> > +                       break;
> > +               case PR_RLIMIT_BIND_CURRENT_USERNS:
> > +                       error = set_rlimit_ns(current_user_ns());
> > +                       break;
> > +               default:
> > +                       error = -EINVAL;
> > +               }
> > +               break;
> 
> I don't see how this can work. capable() requires that
> current_user_ns()==&init_user_ns, so you can't use this API to bind
> rlimits to any other user namespace.
> 
> Fundamentally, if it requires CAP_SYS_RESOURCE, this probably can't be
> done as an API that a process uses to change its own rlimit scope. In
> that case I would implement this as part of clone3() instead of
> prctl(). (Then init_user_ns can set it if the caller has
> CAP_SYS_RESOURCE. If you want to have support for doing the same thing
> with nested namespaces, you'd also need a flag that the first-level
> clone3() can set on the namespace to say "further rlimit splitting
> should be allowed".)
> 
> Or alternatively, we could say that CAP_SYS_RESOURCE doesn't matter,
> and instead you're allowed to move the rlimit scope if your current
> hard rlimit is INFINITY. That might make more sense? Maybe?

I think you are right. CAP_SYS_RESOURCE is not needed here since you still
cannot exceed the rlimit in the parent user namespace.

-- 
Rgrds, legion

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
