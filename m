Return-Path: <SRS0=50w+=DC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06A1DC4727C
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 23:49:22 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7E8E92086A
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 23:49:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="Dhq8sDfx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E8E92086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id D85222E190;
	Fri, 25 Sep 2020 23:49:20 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id h-P7B6ggGj8E; Fri, 25 Sep 2020 23:49:18 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id C62732002E;
	Fri, 25 Sep 2020 23:49:17 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id A2C29C0859;
	Fri, 25 Sep 2020 23:49:17 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 7F640C0051
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 23:49:16 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 6633486C93
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 23:49:16 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 4rud8ggg2C1c
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 23:49:15 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pg1-f194.google.com (mail-pg1-f194.google.com
 [209.85.215.194])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 59E6C86C8C
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 23:49:15 +0000 (UTC)
Received: by mail-pg1-f194.google.com with SMTP id 7so3859970pgm.11
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 16:49:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:content-transfer-encoding:in-reply-to;
 bh=14YkEVFhDzQ9kmT8n7KkV3/flMwf37f3cRskNvS9iFY=;
 b=Dhq8sDfxopl4Q3cF0hfW8uacmrZsnxnqM469tF/cbaqQgWxUcLW341eZhdaC9sJJyn
 Vd3sKc0u2BFXSQkNKik6hSID7YkG5IuBWahBwm5WIw/afnoJUjS8JHe0fhpl8qgmW47h
 c60dmZk7pCOxyF5yfTJ+xxs8KpLF0NEK+0wgA=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:content-transfer-encoding
 :in-reply-to;
 bh=14YkEVFhDzQ9kmT8n7KkV3/flMwf37f3cRskNvS9iFY=;
 b=ZciIOrb5GF6MCgzDlP4b0LFfRsmYOlP2Oz/pGbKOZL/zK/YzEPLmmcv0Ka7fRD2/7v
 zmtHcXKysi68h7eM6EZ53/ja7mEn/5/ffPZlj+s6tGfcvCAgKpYbbyqitG2hbtI5PAzH
 gR3rT/fmKwruLTScyx8n+BbYfa/3K0YTz2OzsL37rXv58tlTZwn+UtSxTAF900bsMZ25
 r3+UA1d2qdf87fSwGkP3ZeQ/KY+0XnLE2MhwxG9R4HIOBe0JWpNXf7+WXX0fmTBhUBEi
 coZtZ+chaYOp12xwj2Ndg6z2YHcrx3ZYnkluA1TMpHPdF7fRgB26G1/P42lTThjDIXXZ
 PzqQ==
X-Gm-Message-State: AOAM531bt86VxgeCO7lqAhrLFeHi1zI2vcxYsy1remeEjAAj7ku0RCF0
 QepcbhxFMfEXsV8TeTusxZ0B4A==
X-Google-Smtp-Source: ABdhPJwIDA4II9IqiZJg4n18amMCI4BVRaDrKkBU+CyInzUJOwN0xubRBevoITgIsSZwI/VVaWgDWw==
X-Received: by 2002:a17:902:ba98:b029:d1:e598:3ff2 with SMTP id
 k24-20020a170902ba98b02900d1e5983ff2mr1757301pls.44.1601077754849; 
 Fri, 25 Sep 2020 16:49:14 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id ml20sm240719pjb.20.2020.09.25.16.49.13
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Fri, 25 Sep 2020 16:49:14 -0700 (PDT)
Date: Fri, 25 Sep 2020 16:49:13 -0700
From: Kees Cook <keescook@chromium.org>
To: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v2 seccomp 3/6] seccomp/cache: Add "emulator" to check if
 filter is arg-dependent
Message-ID: <202009251648.4AA27D5B@keescook>
References: <202009251223.8E46C831E2@keescook>
 <2FA23A2E-16B0-4E08-96D5-6D6FE45BBCF6@amacapital.net>
 <202009251332.24CE0C58@keescook>
 <CALCETrU_UpcLhXSG84SA6QkAYe8xXn4AXPKeud-=Adp57u54Mg@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CALCETrU_UpcLhXSG84SA6QkAYe8xXn4AXPKeud-=Adp57u54Mg@mail.gmail.com>
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

T24gRnJpLCBTZXAgMjUsIDIwMjAgYXQgMDI6MDc6NDZQTSAtMDcwMCwgQW5keSBMdXRvbWlyc2tp
IHdyb3RlOgo+IE9uIEZyaSwgU2VwIDI1LCAyMDIwIGF0IDE6MzcgUE0gS2VlcyBDb29rIDxrZWVz
Y29va0BjaHJvbWl1bS5vcmc+IHdyb3RlOgo+ID4KPiA+IE9uIEZyaSwgU2VwIDI1LCAyMDIwIGF0
IDEyOjUxOjIwUE0gLTA3MDAsIEFuZHkgTHV0b21pcnNraSB3cm90ZToKPiA+ID4KPiA+ID4KPiA+
ID4gPiBPbiBTZXAgMjUsIDIwMjAsIGF0IDEyOjQyIFBNLCBLZWVzIENvb2sgPGtlZXNjb29rQGNo
cm9taXVtLm9yZz4gd3JvdGU6Cj4gPiA+ID4KPiA+ID4gPiDvu79PbiBGcmksIFNlcCAyNSwgMjAy
MCBhdCAxMTo0NTowNUFNIC0wNTAwLCBZaUZlaSBaaHUgd3JvdGU6Cj4gPiA+ID4+IE9uIFRodSwg
U2VwIDI0LCAyMDIwIGF0IDEwOjA0IFBNIFlpRmVpIFpodSA8emh1eWlmZWkxOTk5QGdtYWlsLmNv
bT4gd3JvdGU6Cj4gPiA+ID4+Pj4gV2h5IGRvIHRoZSBwcmVwYXJlIGhlcmUgaW5zdGVhZCBvZiBk
dXJpbmcgYXR0YWNoPyAoQW5kIG5vdGUgdGhhdCBpdAo+ID4gPiA+Pj4+IHNob3VsZCBub3QgYmUg
d3JpdHRlbiB0byBmYWlsLikKPiA+ID4gPj4+Cj4gPiA+ID4+PiBSaWdodC4KPiA+ID4gPj4KPiA+
ID4gPj4gRHVyaW5nIGF0dGFjaCBhIHNwaW5sb2NrIChjdXJyZW50LT5zaWdoYW5kLT5zaWdsb2Nr
KSBpcyBoZWxkLiBEbyB3ZQo+ID4gPiA+PiByZWFsbHkgd2FudCB0byBwdXQgdGhlIGVtdWxhdG9y
IGluIHRoZSAiYXRvbWljIHNlY3Rpb24iPwo+ID4gPiA+Cj4gPiA+ID4gSXQncyBhIGdvb2QgcG9p
bnQsIGJ1dCBJIGhhZCBzb21lIG90aGVyIGlkZWFzIGFyb3VuZCBpdCB0aGF0IGxlYWQgdG8gbWUK
PiA+ID4gPiBhIGRpZmZlcmVudCBjb25jbHVzaW9uLiBIZXJlJ3Mgd2hhdCBJJ3ZlIGdvdCBpbiBt
eSBoZWFkOgo+ID4gPiA+Cj4gPiA+ID4gSSBkb24ndCB2aWV3IGZpbHRlciBhdHRhY2ggKG5vciB0
aGUgc2lnbG9jaykgYXMgZmFzdHBhdGg6IHRoZSBsb2NrIGlzCj4gPiA+ID4gcmFyZWx5IGNvbnRl
c3RlZCBhbmQgdGhlICJsb25nIHRpbWUiIHdpbGwgb25seSBiZSBkdXJpbmcgZmlsdGVyIGF0dGFj
aC4KPiA+ID4gPgo+ID4gPiA+IFdoZW4gcGVyZm9ybWluZyBmaWx0ZXIgZW11bGF0aW9uLCBhbGwg
dGhlIHN5c2NhbGxzIHRoYXQgYXJlIGFscmVhZHkKPiA+ID4gPiBtYXJrZWQgYXMgIm11c3QgcnVu
IGZpbHRlciIgb24gdGhlIHByZXZpb3VzIGZpbHRlciBjYW4gYmUgc2tpcHBlZCBmb3IKPiA+ID4g
PiB0aGUgbmV3IGZpbHRlciwgc2luY2UgaXQgY2Fubm90IGNoYW5nZSB0aGUgb3V0Y29tZSwgd2hp
Y2ggbWFrZXMgdGhlCj4gPiA+ID4gZW11bGF0aW9uIHN0ZXAgZmFzdGVyLgo+ID4gPiA+Cj4gPiA+
ID4gVGhlIHByZXZpb3VzIGZpbHRlcidzIGJpdG1hcCBpc24ndCAic3RhYmxlIiB1bnRpbCBzaWds
b2NrIGlzIGhlbGQuCj4gPiA+ID4KPiA+ID4gPiBJZiB3ZSBkbyB0aGUgZW11bGF0aW9uIHN0ZXAg
YmVmb3JlIHNpZ2xvY2ssIHdlIGhhdmUgdG8gYWx3YXlzIGRvIGZ1bGwKPiA+ID4gPiBldmFsdWF0
aW9uIG9mIGFsbCBzeXNjYWxscywgYW5kIHRoZW4gbWVyZ2UgdGhlIGJpdG1hcCBkdXJpbmcgYXR0
YWNoLgo+ID4gPiA+IFRoYXQgbWVhbnMgYWxsIGZpbHRlcnMgZXZlciBhdHRhY2hlZCB3aWxsIHRh
a2UgbWF4aW1hbCB0aW1lIHRvIHBlcmZvcm0KPiA+ID4gPiBlbXVsYXRpb24uCj4gPiA+ID4KPiA+
ID4gPiBJIHByZWZlciB0aGUgaWRlYSBvZiB0aGUgZW11bGF0aW9uIHN0ZXAgdGFraW5nIGFkdmFu
dGFnZSBvZiB0aGUgYml0bWFwCj4gPiA+ID4gb3B0aW1pemF0aW9uLCBzaW5jZSB0aGUga2VybmVs
IHNwZW5kcyBsZXNzIHRpbWUgZG9pbmcgd29yayBvdmVyIHRoZSBsaWZlCj4gPiA+ID4gb2YgdGhl
IHByb2Nlc3MgdHJlZS4gSXQncyBjZXJ0YWlubHkgbWFyZ2luYWwsIGJ1dCBpdCBhbHNvIGxldHMg
YWxsIHRoZQo+ID4gPiA+IGJpdG1hcCBtYW5pcHVsYXRpb24gc3RheSBpbiBvbmUgcGxhY2UgKGFz
IG9wcG9zZWQgdG8gYmVpbmcgc3BsaXQgYmV0d2Vlbgo+ID4gPiA+ICJwcmVwYXJlIiBhbmQgImF0
dGFjaCIpLgo+ID4gPiA+Cj4gPiA+ID4gV2hhdCBkbyB5b3UgdGhpbms/Cj4gPiA+ID4KPiA+ID4g
Pgo+ID4gPgo+ID4gPiBJ4oCZbSB3b25kZXJpbmcgaWYgd2Ugc2hvdWxkIGJlIG11Y2ggbXVjaCBs
YXppZXIuIFdlIGNvdWxkIHBvdGVudGlhbGx5IHdhaXQgdW50aWwgc29tZW9uZSBhY3R1YWxseSB0
cmllcyB0byBkbyBhIGdpdmVuIHN5c2NhbGwgYmVmb3JlIHdlIHRyeSB0byBldmFsdWF0ZSB3aGV0
aGVyIHRoZSByZXN1bHQgaXMgZml4ZWQuCj4gPgo+ID4gVGhhdCBzZWVtcyBsaWtlIHdlJ2QgbmVl
ZCB0byB0cmFjayB5ZXQgYW5vdGhlciBiaXRtYXAgb2YgImRpZCB3ZSBlbXVsYXRlCj4gPiB0aGlz
IHlldD8iIEFuZCBpdCBtZWFucyB0aGUgZmlsdGVyIGlzbid0IHJlYWxseSAiZG9uZSIgdW50aWwg
eW91IHJ1bgo+ID4gYW5vdGhlciBzeXNjYWxsPyBlZWgsIEknbSBub3QgYSBmYW46IGl0IHNjcmF0
Y2hlcyBhdCBteSBkZXNpcmUgZm9yCj4gPiBkZXRlcm1pbmlzbS4gOykgT3IgbWF5YmUgbXkgaW1w
bGVtZW50YXRpb24gaW1hZ2luYXRpb24gaXMgbWlzc2luZwo+ID4gc29tZXRoaW5nPwo+ID4KPiAK
PiBXZSdkIG5lZWQgYXQgbGVhc3QgdGhyZWUgc3RhdGVzIHBlciBzeXNjYWxsOiB1bmtub3duLCBh
bHdheXMtYWxsb3csCj4gYW5kIG5lZWQtdG8tcnVuLWZpbHRlci4KPiAKPiBUaGUgZG93bnNpZGVz
IGFyZSBsZXNzIGRldGVybWluaXNtIGFuZCBhIGJpdCBvZiBhbiB1Z2xpZXIKPiBpbXBsZW1lbnRh
dGlvbi4gIFRoZSB1cHNpZGUgaXMgdGhhdCB3ZSBkb24ndCBuZWVkIHRvIGxvb3Agb3ZlciBhbGwK
PiBzeXNjYWxscyBhdCBsb2FkIC0tIGluc3RlYWQgdGhlIHRpbWUgdGhhdCBlYWNoIG9wZXJhdGlv
biB0YWtlcyBpcwo+IGluZGVwZW5kZW50IG9mIHRoZSB0b3RhbCBudW1iZXIgb2Ygc3lzY2FsbHMg
b24gdGhlIHN5c3RlbS4gIEFuZCB3ZSBjYW4KPiBlbnRpcmVseSBhdm9pZCwgc2F5LCBldmFsdWF0
aW5nIHRoZSB4MzIgY2FzZSB1bnRpbCB0aGUgdGFzayB0cmllcyBhbgo+IHgzMiBzeXNjYWxsLgo+
IAo+IEkgdGhpbmsgaXQncyBhdCBsZWFzdCB3b3J0aCBjb25zaWRlcmluZy4KClllYWgsIHdvcnRo
IGNvbnNpZGVyaW5nLiBJIGRvIHN0aWxsIHRoaW5rIHRoZSB0aW1lIHNwZW50IGluIGVtdWxhdGlv
biBpcwpTTyBzbWFsbCB0aGF0IGl0IGRvZXNuJ3QgbWF0dGVyIHJ1bm5pbmcgYWxsIG9mIHRoZSBz
eXNjYWxscyBhdCBhdHRhY2gKdGltZS4gVGhlIGZpbHRlcnMgYXJlIHRpbnkgYW5kIGZhaWwgcXVp
Y2tseSBpZiBhbnl0aGluZyAiaW50ZXJlc3RpbmciCnN0YXJ0IHRvIGhhcHBlbi4gOykKCi0tIApL
ZWVzIENvb2sKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18K
Q29udGFpbmVycyBtYWlsaW5nIGxpc3QKQ29udGFpbmVyc0BsaXN0cy5saW51eC1mb3VuZGF0aW9u
Lm9yZwpodHRwczovL2xpc3RzLmxpbnV4Zm91bmRhdGlvbi5vcmcvbWFpbG1hbi9saXN0aW5mby9j
b250YWluZXJz
