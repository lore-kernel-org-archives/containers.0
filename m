Return-Path: <SRS0=X0Oq=C6=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0489C4363C
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 19:45:55 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 44C96206CA
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 19:45:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="G6cAASsL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44C96206CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id CFBAD86523;
	Mon, 21 Sep 2020 19:45:53 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id D+IsiwBSbnn4; Mon, 21 Sep 2020 19:45:53 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 567868651F;
	Mon, 21 Sep 2020 19:45:53 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 36398C0889;
	Mon, 21 Sep 2020 19:45:53 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id B203EC0051
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 19:45:51 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id A54AC8532E
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 19:45:51 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 3iBBSGhOGBoB
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 19:45:51 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-vs1-f68.google.com (mail-vs1-f68.google.com
 [209.85.217.68])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 0F21C8532B
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 19:45:51 +0000 (UTC)
Received: by mail-vs1-f68.google.com with SMTP id j3so8848263vsm.0
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 12:45:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=iX2ZpXGFbNOu72F3q0KCqB8Y6bryK806FhnLUU2NMuk=;
 b=G6cAASsLIdBm7YhTBRLehSgS93d9xmCipqJcPtsYE6zI1r6uEQj8RuaqNhWKZm/MSh
 Djat2TbJzt5UKA0QvncwguQxKKMQ0agt0viVUQccQZn3EoyHE8g3ghfJQ6ywAlHnw+pO
 9qE+79PTCaUVi5hgMhQ7X7Bcox4VRzKIvSVhlwYN71gQ0OiTEIB5blID6x01UPtNGizf
 /P1XFDtVCB64JvdhHKuf6XRASxc7PgDU4lyqZ5eV5J8ZesE/8EGHZPFWXBr4ZGEiRTub
 S8y0kVvYfyfgyzL1MZ2Y1nQgr2Rap3Fk9D6NqiPPrieY3VqTUoskxJmiQES1ROkyc2bi
 HcNw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=iX2ZpXGFbNOu72F3q0KCqB8Y6bryK806FhnLUU2NMuk=;
 b=Nr5MEm8OqIA9LK95VShkRn+15hfLHsCx1fnQ3H2SxHWYLvagK0zQhjeYXzUIE9rd5I
 PFPpFv04aNO0Xj//hst+/S9ebtoQFmfRdB3Ej1F4b0uxV2kAsyGVJysDf1ptYqHLgYU8
 e/Bis/fvpd9zP1A7DcrayOPDVbDUlv1cdr5VyHFZzNKHq5/k9+AqL7MazvXeLVojDoPf
 pjqZR0vy5VAfOvDCazJRvcepNaXO0lQxCciTU5neFxFtnUP+53NdBXseh4oTY9ou9EJo
 o7Sz2HWsW6vPrBKQxmPonQhnONTn1sEXUUWmUMa0ogZFDHEagpH5NHaNoAAIR3uJG0Vc
 7Lkg==
X-Gm-Message-State: AOAM532f8t7wLAzDNTw/WMV1SquNo5hpFwUca5wp09NnqjgSZ6An4RMP
 hb2/LHyix5vGt9sukxbRiG+JByWxnW6A0VxIh7KTDA==
X-Google-Smtp-Source: ABdhPJxviktg8cUUe2JlqcrROxU1giGTaebOLk7jJ1ACqAQWlM2uhqXSKmHI3mvsQiPKOfbpu4LWXtjhBeGIsQSOogU=
X-Received: by 2002:a67:e991:: with SMTP id b17mr1266363vso.16.1600717549823; 
 Mon, 21 Sep 2020 12:45:49 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1600661418.git.yifeifz2@illinois.edu>
 <CAG48ez3Ofqp4crXGksLmZY6=fGrF_tWyUCg7PBkAetvbbOPeOA@mail.gmail.com>
 <OF8837FC1A.5C0D4D64-ON852585EA.006B677F-852585EA.006BA663@notes.na.collabserv.com>
In-Reply-To: <OF8837FC1A.5C0D4D64-ON852585EA.006B677F-852585EA.006BA663@notes.na.collabserv.com>
Date: Mon, 21 Sep 2020 21:45:23 +0200
Message-ID: <CAG48ez3+fAjOsktPFmatFPx9cVCvvguQQT5UYbBS6zRZ0RK9WQ@mail.gmail.com>
Subject: Re: [RFC PATCH seccomp 0/2] seccomp: Add bitmap cache of
 arg-independent filter results that allow syscalls
To: Hubertus Franke <frankeh@us.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 Kees Cook <keescook@chromium.org>, YiFei Zhu <yifeifz2@illinois.edu>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 kernel list <linux-kernel@vger.kernel.org>,
 Valentin Rothberg <vrothber@redhat.com>, Jack Chen <jianyan2@illinois.edu>,
 Josep Torrellas <torrella@illinois.edu>, bpf <bpf@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Tianyin Xu <tyxu@illinois.edu>,
 YiFei Zhu <zhuyifei1999@gmail.com>
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

On Mon, Sep 21, 2020 at 9:35 PM Hubertus Franke <frankeh@us.ibm.com> wrote:
> I suggest we first bring it down to the minimal features we what and successively build the functions as these ideas evolve.
> We asked YiFei to prepare a minimal set that brings home the basic features. Might not be 100% optimal but having the hooks, the basic cache in place and getting a good benefit should be a good starting point
> to get this integrated into a linux kernel and then enable a larger experimentation.
> Does that make sense to approach it from that point ?

Sure. As I said, I don't think that the procfs part is a blocker - if
YiFei doesn't want to implement it now, I don't think it's necessary.
(But it would make it possible to write more precise tests.)

By the way: Please don't top-post on mailing lists - instead, quote
specific parts of a message and reply below those quotes. Also, don't
send HTML mail to kernel mailing lists, because they will reject it.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
