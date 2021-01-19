Return-Path: <SRS0=TkuO=GW=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99112C433DB
	for <containers@archiver.kernel.org>; Tue, 19 Jan 2021 04:42:57 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2B87420848
	for <containers@archiver.kernel.org>; Tue, 19 Jan 2021 04:42:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B87420848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kaiwantech.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 882DF87093;
	Tue, 19 Jan 2021 04:42:56 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 2NGq+d1NMUvU; Tue, 19 Jan 2021 04:42:54 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id BEDEF8708B;
	Tue, 19 Jan 2021 04:42:54 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id ADD6EC088B;
	Tue, 19 Jan 2021 04:42:54 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 0CA2CC013A
 for <containers@lists.linux-foundation.org>;
 Tue, 19 Jan 2021 04:42:53 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id E82668708B
 for <containers@lists.linux-foundation.org>;
 Tue, 19 Jan 2021 04:42:52 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id GsZ6Dl+jzrk0
 for <containers@lists.linux-foundation.org>;
 Tue, 19 Jan 2021 04:42:52 +0000 (UTC)
X-Greylist: delayed 00:07:23 by SQLgrey-1.7.6
Received: from sg2plout10-02.prod.sin2.secureserver.net
 (sg2plout10-02.prod.sin2.secureserver.net [182.50.145.5])
 by hemlock.osuosl.org (Postfix) with ESMTPS id DD94087093
 for <containers@lists.linux-foundation.org>;
 Tue, 19 Jan 2021 04:42:51 +0000 (UTC)
Received: from mail-ot1-f53.google.com ([209.85.210.53])
 by :SMTPAUTH: with ESMTPSA
 id 1ijglAmDLxz4B1ijjlUIXH; Mon, 18 Jan 2021 21:35:24 -0700
X-CMAE-Analysis: v=2.4 cv=SbAyytdu c=1 sm=1 tr=0 ts=6006618d
 a=YKy5iuLXnxoOKB4xgfqhSw==:117 a=IkcTkHD0fZMA:10 a=EmqxpYm9HcoA:10
 a=pGLkceISAAAA:8 a=9vr8BnzVG96gFNSbxsUA:9 a=QEXdDO2ut3YA:10
X-SECURESERVER-ACCT: kaiwan@kaiwantech.com
Received: by mail-ot1-f53.google.com with SMTP id v1so532242ott.10
 for <containers@lists.linux-foundation.org>;
 Mon, 18 Jan 2021 20:35:23 -0800 (PST)
X-Gm-Message-State: AOAM5316rVwo3KZ9rbSSiVh0mGFhjegQw136/EWv9Org/ssQYGuP8Al9
 LKtpmFcypZBrkmqQTsN/gMTW0jmOMw1HEGXQmbQ=
X-Google-Smtp-Source: ABdhPJz0r7vrYUw3z7gsYPwKEPEVuiSgalGCOodz7zAs+w8wsmDs5ru5RxydNPiwFhVZ8XJd00vziAdKjyYOqXKV72E=
X-Received: by 2002:a9d:2c43:: with SMTP id f61mr2091626otb.329.1611030919638; 
 Mon, 18 Jan 2021 20:35:19 -0800 (PST)
MIME-Version: 1.0
References: <cover.1610722473.git.gladkov.alexey@gmail.com>
 <116c7669744404364651e3b380db2d82bb23f983.1610722473.git.gladkov.alexey@gmail.com>
 <CAHk-=wjsg0Lgf1Mh2UiJE4sqBDDo0VhFVBUbhed47ot2CQQwfQ@mail.gmail.com>
 <20210118194551.h2hrwof7b3q5vgoi@example.org>
 <CAHk-=wiNpc5BS2BfZhdDqofJx1G=uasBa2Q1eY4cr8O59Rev2A@mail.gmail.com>
 <20210118205629.zro2qkd3ut42bpyq@example.org>
In-Reply-To: <20210118205629.zro2qkd3ut42bpyq@example.org>
From: Kaiwan N Billimoria <kaiwan@kaiwantech.com>
Date: Tue, 19 Jan 2021 10:05:03 +0530
X-Gmail-Original-Message-ID: <CAPDLWs-fefTqAe+z-7BeALFpinanfPPd-9rmjKwUQ6WRP3_1Tg@mail.gmail.com>
Message-ID: <CAPDLWs-fefTqAe+z-7BeALFpinanfPPd-9rmjKwUQ6WRP3_1Tg@mail.gmail.com>
Subject: Re: [RFC PATCH v3 1/8] Use refcount_t for ucounts reference counting
To: Alexey Gladkov <gladkov.alexey@gmail.com>
X-CMAE-Envelope: MS4xfBuCjVuUNzQ9MWUWLlb8iVSUpyoTLrRRPg51VIhbGaS7pm0Bw8irKwyM9scDEBPH1Ve/IWBxLNkRYxPmWyijiPu1rioDJaX8ISFoOKeL9+KFKxYwx5cb
 zO1Hc1zj/f99Gjfm/89wQNUI+nB6SA04EYnOWedVx+qFTKmJYzwGbfJBX58UcHPY4GwMRqlickEYxb357LkyRMbUKVAr7Aewh3p+dgH7w65xAWXxHx73EY0u
Cc: Jens Axboe <axboe@kernel.dk>, Kees Cook <keescook@chromium.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Jann Horn <jannh@google.com>, LKML <linux-kernel@vger.kernel.org>,
 Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 io-uring <io-uring@vger.kernel.org>
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

(Sorry for the gmail client)
My 0.2, HTH:
a) AFAIK, refcount_inc() (and similar friends) don't return any value
b) they're designed to just WARN() if they saturate or if you're
attempting to increment the value 0 (as it's possibly a UAF bug)
c) refcount_inc_checked() is documented as "Similar to atomic_inc(),
but will saturate at UINT_MAX and WARN"
d) we should avoid using the __foo() when foo() 's present as far as
is sanely possible...

So is one expected to just fix things when they break? - as signalled
by the WARN firing?

--
Regards, kaiwan.


On Tue, Jan 19, 2021 at 2:26 AM Alexey Gladkov <gladkov.alexey@gmail.com> wrote:
>
> On Mon, Jan 18, 2021 at 12:34:29PM -0800, Linus Torvalds wrote:
> > On Mon, Jan 18, 2021 at 11:46 AM Alexey Gladkov
> > <gladkov.alexey@gmail.com> wrote:
> > >
> > > Sorry about that. I thought that this code is not needed when switching
> > > from int to refcount_t. I was wrong.
> >
> > Well, you _may_ be right. I personally didn't check how the return
> > value is used.
> >
> > I only reacted to "it certainly _may_ be used, and there is absolutely
> > no comment anywhere about why it wouldn't matter".
>
> I have not found examples where checked the overflow after calling
> refcount_inc/refcount_add.
>
> For example in kernel/fork.c:2298 :
>
>    current->signal->nr_threads++;
>    atomic_inc(&current->signal->live);
>    refcount_inc(&current->signal->sigcnt);
>
> $ semind search signal_struct.sigcnt
> def include/linux/sched/signal.h:83             refcount_t              sigcnt;
> m-- kernel/fork.c:723 put_signal_struct                 if (refcount_dec_and_test(&sig->sigcnt))
> m-- kernel/fork.c:1571 copy_signal              refcount_set(&sig->sigcnt, 1);
> m-- kernel/fork.c:2298 copy_process                             refcount_inc(&current->signal->sigcnt);
>
> It seems to me that the only way is to use __refcount_inc and then compare
> the old value with REFCOUNT_MAX
>
> Since I have not seen examples of such checks, I thought that this is
> acceptable. Sorry once again. I have not tried to hide these changes.
>
> --
> Rgrds, legion
>
>
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
