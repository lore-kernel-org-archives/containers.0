Return-Path: <SRS0=QcxQ=DD=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B904C4727D
	for <containers@archiver.kernel.org>; Sat, 26 Sep 2020 03:12:48 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6295420829
	for <containers@archiver.kernel.org>; Sat, 26 Sep 2020 03:12:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="aBg5JtNu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6295420829
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 6D36A20490;
	Sat, 26 Sep 2020 03:12:46 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Wuq1kLJgEs7b; Sat, 26 Sep 2020 03:12:45 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id DC7852043A;
	Sat, 26 Sep 2020 03:12:44 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id C0FF2C0890;
	Sat, 26 Sep 2020 03:12:44 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 6D82CC0051
 for <containers@lists.linux-foundation.org>;
 Sat, 26 Sep 2020 03:12:43 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 5E18786CE6
 for <containers@lists.linux-foundation.org>;
 Sat, 26 Sep 2020 03:12:43 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id xthAlPVZUWY8
 for <containers@lists.linux-foundation.org>;
 Sat, 26 Sep 2020 03:12:42 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com
 [209.85.210.196])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 8D6E086C98
 for <containers@lists.linux-foundation.org>;
 Sat, 26 Sep 2020 03:12:42 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id x123so4986295pfc.7
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 20:12:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amacapital-net.20150623.gappssmtp.com; s=20150623;
 h=content-transfer-encoding:from:mime-version:subject:date:message-id
 :references:cc:in-reply-to:to;
 bh=ucCrs5q3YePq0e3RQFFqaDEnUbOvguoKcGVoYbrWhf0=;
 b=aBg5JtNuxhs1Na7XMPn1DSPQq603igvsgaynA6UcbPZvBw/4AvTXEQr7ToAyohBtYU
 1qywQPXmZvtzK+dspR55IISgIuOS4Qq1fGL6qQmGhIKS8cV9U8IeoWPalK4VmbcpnYhK
 d5N36N9yFdvmOhQOEp0RTQHYdrcGuea0EShsQW3m+eOvKS4BWPaJGtgvlgCMggJM/8OE
 xwb74dcvYPDRC2+7MODHZF5Coha8XBxos+gDPo3lhfMhV2lhrSOxZLxpkQ4Ej+9E9jwd
 qtYLkWKpppquHWm/diJRZ6v0Cvsp8tIw6y2pl7dH7P/xMblDpKRC/Q9+ojnC3VumpPxJ
 X/iQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:content-transfer-encoding:from:mime-version
 :subject:date:message-id:references:cc:in-reply-to:to;
 bh=ucCrs5q3YePq0e3RQFFqaDEnUbOvguoKcGVoYbrWhf0=;
 b=dJSIDq1i+XMYB4P7s8rb2xhzxmPUNRfrLpUe7YycQKFv+TXFTzFaDqNaQIaC+plsHX
 Nzh4FHLaxF7My0LiQUTZnFuENMNXCw/iYmw4AgXjTmRC+POrSlNu6blBe3vTP8a2FUf6
 ydBVI4YLNE8BxRZyXZovD+Oklv9t7lGLLdHrIVzUPgy3RBVJQkhEvZ1U+33dKDSB2ucs
 dC4bH1Kfuu6VgnDzLpJOa7uQDiE9BGUx67zpKeXd24jAuvd6ydvma6E91Up0KKrqSXmz
 YBsIO437Gky3X3olAur4rCIwK5uQE6iIGbj30tspijTfd9b7bEZoNaMHbraCxQ2VUyev
 /XoA==
X-Gm-Message-State: AOAM5329pYZbig6zSvKL73CAL/4j/9Dm0KXDbtAvZx7Hit04mnUgA8NY
 pvZq/v/orgGT5dj4Es9tHAJN2/4yaftrNw==
X-Google-Smtp-Source: ABdhPJw6Q5+j8w+qr2BwQrS/6gRAyo8VRGMWToikVfUxPfTvOfnUfQPtFglZAZPSPS1aAtHVS919dw==
X-Received: by 2002:a63:e444:: with SMTP id i4mr1408075pgk.304.1601088470228; 
 Fri, 25 Sep 2020 19:47:50 -0700 (PDT)
Received: from localhost.localdomain (c-67-180-165-146.hsd1.ca.comcast.net.
 [67.180.165.146])
 by smtp.gmail.com with ESMTPSA id 64sm3884252pfz.204.2020.09.25.19.47.49
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Fri, 25 Sep 2020 19:47:49 -0700 (PDT)
From: Andy Lutomirski <luto@amacapital.net>
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH v2 seccomp 3/6] seccomp/cache: Add "emulator" to check if
 filter is arg-dependent
Date: Fri, 25 Sep 2020 19:47:47 -0700
Message-Id: <05109FF5-65C9-491E-9D9D-2FECE4F8B2B0@amacapital.net>
References: <CABqSeASR0bQ7Y302SkZ639NM=roSVRmd3ROGm0YDEFCTxxd63w@mail.gmail.com>
In-Reply-To: <CABqSeASR0bQ7Y302SkZ639NM=roSVRmd3ROGm0YDEFCTxxd63w@mail.gmail.com>
To: YiFei Zhu <zhuyifei1999@gmail.com>
X-Mailer: iPhone Mail (18A373)
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Kees Cook <keescook@chromium.org>,
 Jann Horn <jannh@google.com>, YiFei Zhu <yifeifz2@illinois.edu>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>,
 kernel list <linux-kernel@vger.kernel.org>,
 Hubertus Franke <frankeh@us.ibm.com>, Jack Chen <jianyan2@illinois.edu>,
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
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

Cj4gT24gU2VwIDI1LCAyMDIwLCBhdCA2OjIzIFBNLCBZaUZlaSBaaHUgPHpodXlpZmVpMTk5OUBn
bWFpbC5jb20+IHdyb3RlOgo+IAo+IO+7v09uIEZyaSwgU2VwIDI1LCAyMDIwIGF0IDQ6MDcgUE0g
QW5keSBMdXRvbWlyc2tpIDxsdXRvQGFtYWNhcGl0YWwubmV0PiB3cm90ZToKPj4gV2UnZCBuZWVk
IGF0IGxlYXN0IHRocmVlIHN0YXRlcyBwZXIgc3lzY2FsbDogdW5rbm93biwgYWx3YXlzLWFsbG93
LAo+PiBhbmQgbmVlZC10by1ydW4tZmlsdGVyLgo+PiAKPj4gVGhlIGRvd25zaWRlcyBhcmUgbGVz
cyBkZXRlcm1pbmlzbSBhbmQgYSBiaXQgb2YgYW4gdWdsaWVyCj4+IGltcGxlbWVudGF0aW9uLiAg
VGhlIHVwc2lkZSBpcyB0aGF0IHdlIGRvbid0IG5lZWQgdG8gbG9vcCBvdmVyIGFsbAo+PiBzeXNj
YWxscyBhdCBsb2FkIC0tIGluc3RlYWQgdGhlIHRpbWUgdGhhdCBlYWNoIG9wZXJhdGlvbiB0YWtl
cyBpcwo+PiBpbmRlcGVuZGVudCBvZiB0aGUgdG90YWwgbnVtYmVyIG9mIHN5c2NhbGxzIG9uIHRo
ZSBzeXN0ZW0uICBBbmQgd2UgY2FuCj4+IGVudGlyZWx5IGF2b2lkLCBzYXksIGV2YWx1YXRpbmcg
dGhlIHgzMiBjYXNlIHVudGlsIHRoZSB0YXNrIHRyaWVzIGFuCj4+IHgzMiBzeXNjYWxsLgo+IAo+
IEkgd2FzIHJlYWxseSBhZnJhaWQgb2YgbXVsdGlwbGUgdGFza3Mgd3JpdGluZyB0byB0aGUgYml0
bWFwcyBhdCBvbmNlLAo+IGhlbmNlIEkgdXNlZCBiaXRtYXAtcGVyLXRhc2suIE5vdyBJIHRoaW5r
IGFib3V0IGl0LCBpZiB0aGlzIHN0YXlzCj4gbG9ja2xlc3MsIHRoZSB3b3JzdCB0aGluZyB0aGF0
IGNhbiBoYXBwZW4gaXMgdGhhdCBhIHdyaXRlIHVuZG8gYSBiaXQKPiBzZXQgYnkgYW5vdGhlciB0
YXNrLiBJbiB0aGlzIGNhc2UsIGlmIHRoZSAia25vd24iIGJpdCBpcyBjbGVhcmVkIHRoZW4KPiB0
aGUgd29yc3Qgd291bGQgYmUgdGhlIGVtdWxhdGlvbiBpcyBydW4gbWFueSB0aW1lcy4gQnV0IGlm
IHRoZSAiYWx3YXlzCj4gYWxsb3ciIGlzIGNsZWFyZWQgYnV0IG5vdCAia25vd24iIGJpdCB0aGVu
IHdlIGhhdmUgYW4gaXNzdWU6IHRoZQo+IHN5c2NhbGwgd2lsbCBhbHdheXMgYmUgZXhlY3V0ZWQg
aW4gQlBGLgo+IAoKSWYgeW91IGludGVybGVhdmUgdGhlIGJpdHMsIHRoZW4geW91IGNhbiByZWFk
IGFuZCB3cml0ZSB0aGVtIGF0b21pY2FsbHkg4oCUIGJvdGggYml0cyBmb3IgYW55IGdpdmVuIHN5
c2NhbGwgd2lsbCBiZSBpbiB0aGUgc2FtZSB3b3JkLgoKPiBJcyBpdCB3b3J0aCBob2xkaW5nIGEg
c3BpbmxvY2sgaGVyZT8KPiAKPiBUaG91Z2ggSSdsbCB0cnkgdG8gZ2V0IHRoZSBiZW5jaG1hcmsg
bnVtYmVycyBmb3IgdGhlIGVtdWxhdG9yIGxhdGVyIHRvbmlnaHQuCj4gCj4gWWlGZWkgWmh1Cl9f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCkNvbnRhaW5lcnMg
bWFpbGluZyBsaXN0CkNvbnRhaW5lcnNAbGlzdHMubGludXgtZm91bmRhdGlvbi5vcmcKaHR0cHM6
Ly9saXN0cy5saW51eGZvdW5kYXRpb24ub3JnL21haWxtYW4vbGlzdGluZm8vY29udGFpbmVycw==
