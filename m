Return-Path: <SRS0=QcxQ=DD=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74E8FC2D0A8
	for <containers@archiver.kernel.org>; Sat, 26 Sep 2020 04:35:07 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 01BC62076D
	for <containers@archiver.kernel.org>; Sat, 26 Sep 2020 04:35:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="TWHocp6X"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 01BC62076D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 9039186BEF;
	Sat, 26 Sep 2020 04:35:06 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id XuXeWWTzGIer; Sat, 26 Sep 2020 04:35:05 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 88CB786B71;
	Sat, 26 Sep 2020 04:35:05 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 640E8C0891;
	Sat, 26 Sep 2020 04:35:05 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 2692FC0859
 for <containers@lists.linux-foundation.org>;
 Sat, 26 Sep 2020 04:35:04 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 1AA348756D
 for <containers@lists.linux-foundation.org>;
 Sat, 26 Sep 2020 04:35:04 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id e6c0KnjH2RU5
 for <containers@lists.linux-foundation.org>;
 Sat, 26 Sep 2020 04:35:03 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pg1-f193.google.com (mail-pg1-f193.google.com
 [209.85.215.193])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 806D58755B
 for <containers@lists.linux-foundation.org>;
 Sat, 26 Sep 2020 04:35:03 +0000 (UTC)
Received: by mail-pg1-f193.google.com with SMTP id k133so4153327pgc.7
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 21:35:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:content-transfer-encoding:in-reply-to;
 bh=mRcwOzZAXRqD5t0WunR2xZRGQlJgJ5v6Cl490f6L2w4=;
 b=TWHocp6Xnlj+Fal/pEAcaz9wDHWf5v8XigHCHnEgYkDAlglQrvdlT3J1d4RmRbUM5G
 oWQjXg12yMjV+3i57IYSebyR+e7kdcE8TnPGHZXUJLngz9RYIkHXBP8k0L5y0iuLMbmS
 G8h+pUUY+GNQEWLdLBFvHdE3ncAEFTwNfZnkc=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:content-transfer-encoding
 :in-reply-to;
 bh=mRcwOzZAXRqD5t0WunR2xZRGQlJgJ5v6Cl490f6L2w4=;
 b=eIw86KwlQE26B+FYZiJrm0KqodCOSYRd2D/gmRSx4IT/b833LKN6Q7H2uqEAinvyn/
 kmwYOfkxbTe490JvBGowJKBz/SFzN3cRvZJVaIiTx/M1Ixl8iZxn67zXkV4K/+MlpaWa
 7eLRSpgZ458ykKrcXpIc8mpnXCcS1dD/C8ktvx/BpQTuDTtTQNI2oxM422gsxjh58rZV
 fFW32hszJspzyvDsc37NW2XYEshK6whVD1Q1fKpLr8kxs2Ul/as7f069C4DIaKQD3E7N
 0Ws1UnZie67MxJkRAVTGky8rwvd5OLPri/P1t6SSRNLlYdsJZI8D3YpF0XOMWkwdpq0Q
 zmMA==
X-Gm-Message-State: AOAM530GroTe1j2UJH2fI3qhq/VZ4NzPzBe/W4gQ/lvu3HlQg7A/MXOa
 hmd/WZEP+I2DigCqHlZnt74Bzg==
X-Google-Smtp-Source: ABdhPJwZ8nK5Yal21qEXtJstQ1g6ry9hFYoph8xJ4equzc56hECGkz66N29kZWed4jPsUpReqJJ0YA==
X-Received: by 2002:a65:615a:: with SMTP id o26mr1648183pgv.54.1601094903117; 
 Fri, 25 Sep 2020 21:35:03 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id y202sm4057138pfc.179.2020.09.25.21.35.02
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Fri, 25 Sep 2020 21:35:02 -0700 (PDT)
Date: Fri, 25 Sep 2020 21:35:01 -0700
From: Kees Cook <keescook@chromium.org>
To: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v2 seccomp 3/6] seccomp/cache: Add "emulator" to check if
 filter is arg-dependent
Message-ID: <202009252134.871EFAB61@keescook>
References: <CABqSeASR0bQ7Y302SkZ639NM=roSVRmd3ROGm0YDEFCTxxd63w@mail.gmail.com>
 <05109FF5-65C9-491E-9D9D-2FECE4F8B2B0@amacapital.net>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <05109FF5-65C9-491E-9D9D-2FECE4F8B2B0@amacapital.net>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Jann Horn <jannh@google.com>,
 YiFei Zhu <yifeifz2@illinois.edu>,
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

T24gRnJpLCBTZXAgMjUsIDIwMjAgYXQgMDc6NDc6NDdQTSAtMDcwMCwgQW5keSBMdXRvbWlyc2tp
IHdyb3RlOgo+IAo+ID4gT24gU2VwIDI1LCAyMDIwLCBhdCA2OjIzIFBNLCBZaUZlaSBaaHUgPHpo
dXlpZmVpMTk5OUBnbWFpbC5jb20+IHdyb3RlOgo+ID4gCj4gPiDvu79PbiBGcmksIFNlcCAyNSwg
MjAyMCBhdCA0OjA3IFBNIEFuZHkgTHV0b21pcnNraSA8bHV0b0BhbWFjYXBpdGFsLm5ldD4gd3Jv
dGU6Cj4gPj4gV2UnZCBuZWVkIGF0IGxlYXN0IHRocmVlIHN0YXRlcyBwZXIgc3lzY2FsbDogdW5r
bm93biwgYWx3YXlzLWFsbG93LAo+ID4+IGFuZCBuZWVkLXRvLXJ1bi1maWx0ZXIuCj4gPj4gCj4g
Pj4gVGhlIGRvd25zaWRlcyBhcmUgbGVzcyBkZXRlcm1pbmlzbSBhbmQgYSBiaXQgb2YgYW4gdWds
aWVyCj4gPj4gaW1wbGVtZW50YXRpb24uICBUaGUgdXBzaWRlIGlzIHRoYXQgd2UgZG9uJ3QgbmVl
ZCB0byBsb29wIG92ZXIgYWxsCj4gPj4gc3lzY2FsbHMgYXQgbG9hZCAtLSBpbnN0ZWFkIHRoZSB0
aW1lIHRoYXQgZWFjaCBvcGVyYXRpb24gdGFrZXMgaXMKPiA+PiBpbmRlcGVuZGVudCBvZiB0aGUg
dG90YWwgbnVtYmVyIG9mIHN5c2NhbGxzIG9uIHRoZSBzeXN0ZW0uICBBbmQgd2UgY2FuCj4gPj4g
ZW50aXJlbHkgYXZvaWQsIHNheSwgZXZhbHVhdGluZyB0aGUgeDMyIGNhc2UgdW50aWwgdGhlIHRh
c2sgdHJpZXMgYW4KPiA+PiB4MzIgc3lzY2FsbC4KPiA+IAo+ID4gSSB3YXMgcmVhbGx5IGFmcmFp
ZCBvZiBtdWx0aXBsZSB0YXNrcyB3cml0aW5nIHRvIHRoZSBiaXRtYXBzIGF0IG9uY2UsCj4gPiBo
ZW5jZSBJIHVzZWQgYml0bWFwLXBlci10YXNrLiBOb3cgSSB0aGluayBhYm91dCBpdCwgaWYgdGhp
cyBzdGF5cwo+ID4gbG9ja2xlc3MsIHRoZSB3b3JzdCB0aGluZyB0aGF0IGNhbiBoYXBwZW4gaXMg
dGhhdCBhIHdyaXRlIHVuZG8gYSBiaXQKPiA+IHNldCBieSBhbm90aGVyIHRhc2suIEluIHRoaXMg
Y2FzZSwgaWYgdGhlICJrbm93biIgYml0IGlzIGNsZWFyZWQgdGhlbgo+ID4gdGhlIHdvcnN0IHdv
dWxkIGJlIHRoZSBlbXVsYXRpb24gaXMgcnVuIG1hbnkgdGltZXMuIEJ1dCBpZiB0aGUgImFsd2F5
cwo+ID4gYWxsb3ciIGlzIGNsZWFyZWQgYnV0IG5vdCAia25vd24iIGJpdCB0aGVuIHdlIGhhdmUg
YW4gaXNzdWU6IHRoZQo+ID4gc3lzY2FsbCB3aWxsIGFsd2F5cyBiZSBleGVjdXRlZCBpbiBCUEYu
Cj4gPiAKPiAKPiBJZiB5b3UgaW50ZXJsZWF2ZSB0aGUgYml0cywgdGhlbiB5b3UgY2FuIHJlYWQg
YW5kIHdyaXRlIHRoZW0gYXRvbWljYWxseSDigJQgYm90aCBiaXRzIGZvciBhbnkgZ2l2ZW4gc3lz
Y2FsbCB3aWxsIGJlIGluIHRoZSBzYW1lIHdvcmQuCgpJIHRoaW5rIHdlIGNhbiBqdXN0IGhvbGQg
dGhlIHNwaW5sb2NrLiA6KQoKLS0gCktlZXMgQ29vawpfX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fXwpDb250YWluZXJzIG1haWxpbmcgbGlzdApDb250YWluZXJz
QGxpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnCmh0dHBzOi8vbGlzdHMubGludXhmb3VuZGF0aW9u
Lm9yZy9tYWlsbWFuL2xpc3RpbmZvL2NvbnRhaW5lcnM=
