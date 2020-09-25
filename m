Return-Path: <SRS0=50w+=DC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0ACF9C4727E
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 21:13:20 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 76D9F21D42
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 21:13:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="wWJDp7DJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76D9F21D42
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 207C68767E;
	Fri, 25 Sep 2020 21:13:19 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id xtzw7-jqY3GC; Fri, 25 Sep 2020 21:13:18 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 86FF68767A;
	Fri, 25 Sep 2020 21:13:18 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 792B6C0859;
	Fri, 25 Sep 2020 21:13:18 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 2603BC0051
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 21:13:17 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 1869B8767A
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 21:13:17 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id JHtKQSx4M3ip
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 21:13:15 +0000 (UTC)
X-Greylist: delayed 00:05:15 by SQLgrey-1.7.6
Received: from mail-wm1-f66.google.com (mail-wm1-f66.google.com
 [209.85.128.66])
 by hemlock.osuosl.org (Postfix) with ESMTPS id A4B1E87678
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 21:13:15 +0000 (UTC)
Received: by mail-wm1-f66.google.com with SMTP id w2so547034wmi.1
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 14:13:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amacapital-net.20150623.gappssmtp.com; s=20150623;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc:content-transfer-encoding;
 bh=K97X2RHTYq4ARTwka6ZMNlPXc27d+vNcQg3ndyKU7S4=;
 b=wWJDp7DJ/HSLsogZGC8Djl65CIcLMR4WYa3ADAj6UKKThfriQIIl0AP5YkYOCeZjQg
 KvWcIpXuUmNNcLIcy0qIPpol6N1nCEXLafFw0RqOTH4dc3O8g1f6JLmWNIBhig9vRNwL
 DH/d7LjlahlLTw4oUcx+CVrvoJOFZowbGEJCfrBLFxTQxvj+HdwfFKnqKyug0MqleX7P
 7uIXwrDM/O+qcsf+ArWoYr85x58YYnxGkdVf8ILr8dVNn5HGGWFx/QBUt0YIZYC8ubGb
 L8zS0WxjNwMO0RbpE7WFpzZIVgW+bBfk06GgnPTlhDZ6qBiWQ2S3l5yLVpSMzXpDOaK7
 vL8A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc:content-transfer-encoding;
 bh=K97X2RHTYq4ARTwka6ZMNlPXc27d+vNcQg3ndyKU7S4=;
 b=byWfUtXgqjkOcSszLueiy/srL7iIAA4Ou9YmESEhzX7z/C7ozMUhCJ0bzc34/0dAF2
 PXCHvuIQkFpjFOlf6u2i3aUf7bZc77HWqSAyGQwjWjYpzeGVw2U1oiJDceJ8Y3A1cY2K
 7hJoS053GaT2k9E7JdkNw+FeyYT1JpBl+mTKrjoS7TFJEABhoNfyVxG8thhGV2NCViqZ
 8tjh5N+h9pL6us3o2hXDXd9EVSjY/kNXf4CVSdI5OvqbcoE9/id8iye2nOZyG7ZFaww6
 zTJyp3HZqhFApYpXEL9i8skeizQhK7c5VpFjsA3HcEuoKhd8KNgJvi2hPwDXycrhHLv1
 Lqnw==
X-Gm-Message-State: AOAM532Mwb8QBMS9VeFGwu1ZXrUD4rFcdp8JNujaufcNnj5NFFMIE0AZ
 h7Z2+gkPWAX5bM8mY+xQSGpcQgN/iMIjSAlSWgaWqEjQs+k=
X-Google-Smtp-Source: ABdhPJybyFObTULGeYsdiwfil6bHB/bVxxQM+SWeMyX++xGCC6MaJ/cX0aYsdELwah2M/FxoIVL6b6QjN4YOeSHoolY=
X-Received: by 2002:a1c:740c:: with SMTP id p12mr445421wmc.176.1601068078574; 
 Fri, 25 Sep 2020 14:07:58 -0700 (PDT)
MIME-Version: 1.0
References: <202009251223.8E46C831E2@keescook>
 <2FA23A2E-16B0-4E08-96D5-6D6FE45BBCF6@amacapital.net>
 <202009251332.24CE0C58@keescook>
In-Reply-To: <202009251332.24CE0C58@keescook>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 25 Sep 2020 14:07:46 -0700
Message-ID: <CALCETrU_UpcLhXSG84SA6QkAYe8xXn4AXPKeud-=Adp57u54Mg@mail.gmail.com>
Subject: Re: [PATCH v2 seccomp 3/6] seccomp/cache: Add "emulator" to check if
 filter is arg-dependent
To: Kees Cook <keescook@chromium.org>
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

T24gRnJpLCBTZXAgMjUsIDIwMjAgYXQgMTozNyBQTSBLZWVzIENvb2sgPGtlZXNjb29rQGNocm9t
aXVtLm9yZz4gd3JvdGU6Cj4KPiBPbiBGcmksIFNlcCAyNSwgMjAyMCBhdCAxMjo1MToyMFBNIC0w
NzAwLCBBbmR5IEx1dG9taXJza2kgd3JvdGU6Cj4gPgo+ID4KPiA+ID4gT24gU2VwIDI1LCAyMDIw
LCBhdCAxMjo0MiBQTSwgS2VlcyBDb29rIDxrZWVzY29va0BjaHJvbWl1bS5vcmc+IHdyb3RlOgo+
ID4gPgo+ID4gPiDvu79PbiBGcmksIFNlcCAyNSwgMjAyMCBhdCAxMTo0NTowNUFNIC0wNTAwLCBZ
aUZlaSBaaHUgd3JvdGU6Cj4gPiA+PiBPbiBUaHUsIFNlcCAyNCwgMjAyMCBhdCAxMDowNCBQTSBZ
aUZlaSBaaHUgPHpodXlpZmVpMTk5OUBnbWFpbC5jb20+IHdyb3RlOgo+ID4gPj4+PiBXaHkgZG8g
dGhlIHByZXBhcmUgaGVyZSBpbnN0ZWFkIG9mIGR1cmluZyBhdHRhY2g/IChBbmQgbm90ZSB0aGF0
IGl0Cj4gPiA+Pj4+IHNob3VsZCBub3QgYmUgd3JpdHRlbiB0byBmYWlsLikKPiA+ID4+Pgo+ID4g
Pj4+IFJpZ2h0Lgo+ID4gPj4KPiA+ID4+IER1cmluZyBhdHRhY2ggYSBzcGlubG9jayAoY3VycmVu
dC0+c2lnaGFuZC0+c2lnbG9jaykgaXMgaGVsZC4gRG8gd2UKPiA+ID4+IHJlYWxseSB3YW50IHRv
IHB1dCB0aGUgZW11bGF0b3IgaW4gdGhlICJhdG9taWMgc2VjdGlvbiI/Cj4gPiA+Cj4gPiA+IEl0
J3MgYSBnb29kIHBvaW50LCBidXQgSSBoYWQgc29tZSBvdGhlciBpZGVhcyBhcm91bmQgaXQgdGhh
dCBsZWFkIHRvIG1lCj4gPiA+IGEgZGlmZmVyZW50IGNvbmNsdXNpb24uIEhlcmUncyB3aGF0IEkn
dmUgZ290IGluIG15IGhlYWQ6Cj4gPiA+Cj4gPiA+IEkgZG9uJ3QgdmlldyBmaWx0ZXIgYXR0YWNo
IChub3IgdGhlIHNpZ2xvY2spIGFzIGZhc3RwYXRoOiB0aGUgbG9jayBpcwo+ID4gPiByYXJlbHkg
Y29udGVzdGVkIGFuZCB0aGUgImxvbmcgdGltZSIgd2lsbCBvbmx5IGJlIGR1cmluZyBmaWx0ZXIg
YXR0YWNoLgo+ID4gPgo+ID4gPiBXaGVuIHBlcmZvcm1pbmcgZmlsdGVyIGVtdWxhdGlvbiwgYWxs
IHRoZSBzeXNjYWxscyB0aGF0IGFyZSBhbHJlYWR5Cj4gPiA+IG1hcmtlZCBhcyAibXVzdCBydW4g
ZmlsdGVyIiBvbiB0aGUgcHJldmlvdXMgZmlsdGVyIGNhbiBiZSBza2lwcGVkIGZvcgo+ID4gPiB0
aGUgbmV3IGZpbHRlciwgc2luY2UgaXQgY2Fubm90IGNoYW5nZSB0aGUgb3V0Y29tZSwgd2hpY2gg
bWFrZXMgdGhlCj4gPiA+IGVtdWxhdGlvbiBzdGVwIGZhc3Rlci4KPiA+ID4KPiA+ID4gVGhlIHBy
ZXZpb3VzIGZpbHRlcidzIGJpdG1hcCBpc24ndCAic3RhYmxlIiB1bnRpbCBzaWdsb2NrIGlzIGhl
bGQuCj4gPiA+Cj4gPiA+IElmIHdlIGRvIHRoZSBlbXVsYXRpb24gc3RlcCBiZWZvcmUgc2lnbG9j
aywgd2UgaGF2ZSB0byBhbHdheXMgZG8gZnVsbAo+ID4gPiBldmFsdWF0aW9uIG9mIGFsbCBzeXNj
YWxscywgYW5kIHRoZW4gbWVyZ2UgdGhlIGJpdG1hcCBkdXJpbmcgYXR0YWNoLgo+ID4gPiBUaGF0
IG1lYW5zIGFsbCBmaWx0ZXJzIGV2ZXIgYXR0YWNoZWQgd2lsbCB0YWtlIG1heGltYWwgdGltZSB0
byBwZXJmb3JtCj4gPiA+IGVtdWxhdGlvbi4KPiA+ID4KPiA+ID4gSSBwcmVmZXIgdGhlIGlkZWEg
b2YgdGhlIGVtdWxhdGlvbiBzdGVwIHRha2luZyBhZHZhbnRhZ2Ugb2YgdGhlIGJpdG1hcAo+ID4g
PiBvcHRpbWl6YXRpb24sIHNpbmNlIHRoZSBrZXJuZWwgc3BlbmRzIGxlc3MgdGltZSBkb2luZyB3
b3JrIG92ZXIgdGhlIGxpZmUKPiA+ID4gb2YgdGhlIHByb2Nlc3MgdHJlZS4gSXQncyBjZXJ0YWlu
bHkgbWFyZ2luYWwsIGJ1dCBpdCBhbHNvIGxldHMgYWxsIHRoZQo+ID4gPiBiaXRtYXAgbWFuaXB1
bGF0aW9uIHN0YXkgaW4gb25lIHBsYWNlIChhcyBvcHBvc2VkIHRvIGJlaW5nIHNwbGl0IGJldHdl
ZW4KPiA+ID4gInByZXBhcmUiIGFuZCAiYXR0YWNoIikuCj4gPiA+Cj4gPiA+IFdoYXQgZG8geW91
IHRoaW5rPwo+ID4gPgo+ID4gPgo+ID4KPiA+IEnigJltIHdvbmRlcmluZyBpZiB3ZSBzaG91bGQg
YmUgbXVjaCBtdWNoIGxhemllci4gV2UgY291bGQgcG90ZW50aWFsbHkgd2FpdCB1bnRpbCBzb21l
b25lIGFjdHVhbGx5IHRyaWVzIHRvIGRvIGEgZ2l2ZW4gc3lzY2FsbCBiZWZvcmUgd2UgdHJ5IHRv
IGV2YWx1YXRlIHdoZXRoZXIgdGhlIHJlc3VsdCBpcyBmaXhlZC4KPgo+IFRoYXQgc2VlbXMgbGlr
ZSB3ZSdkIG5lZWQgdG8gdHJhY2sgeWV0IGFub3RoZXIgYml0bWFwIG9mICJkaWQgd2UgZW11bGF0
ZQo+IHRoaXMgeWV0PyIgQW5kIGl0IG1lYW5zIHRoZSBmaWx0ZXIgaXNuJ3QgcmVhbGx5ICJkb25l
IiB1bnRpbCB5b3UgcnVuCj4gYW5vdGhlciBzeXNjYWxsPyBlZWgsIEknbSBub3QgYSBmYW46IGl0
IHNjcmF0Y2hlcyBhdCBteSBkZXNpcmUgZm9yCj4gZGV0ZXJtaW5pc20uIDspIE9yIG1heWJlIG15
IGltcGxlbWVudGF0aW9uIGltYWdpbmF0aW9uIGlzIG1pc3NpbmcKPiBzb21ldGhpbmc/Cj4KCldl
J2QgbmVlZCBhdCBsZWFzdCB0aHJlZSBzdGF0ZXMgcGVyIHN5c2NhbGw6IHVua25vd24sIGFsd2F5
cy1hbGxvdywKYW5kIG5lZWQtdG8tcnVuLWZpbHRlci4KClRoZSBkb3duc2lkZXMgYXJlIGxlc3Mg
ZGV0ZXJtaW5pc20gYW5kIGEgYml0IG9mIGFuIHVnbGllcgppbXBsZW1lbnRhdGlvbi4gIFRoZSB1
cHNpZGUgaXMgdGhhdCB3ZSBkb24ndCBuZWVkIHRvIGxvb3Agb3ZlciBhbGwKc3lzY2FsbHMgYXQg
bG9hZCAtLSBpbnN0ZWFkIHRoZSB0aW1lIHRoYXQgZWFjaCBvcGVyYXRpb24gdGFrZXMgaXMKaW5k
ZXBlbmRlbnQgb2YgdGhlIHRvdGFsIG51bWJlciBvZiBzeXNjYWxscyBvbiB0aGUgc3lzdGVtLiAg
QW5kIHdlIGNhbgplbnRpcmVseSBhdm9pZCwgc2F5LCBldmFsdWF0aW5nIHRoZSB4MzIgY2FzZSB1
bnRpbCB0aGUgdGFzayB0cmllcyBhbgp4MzIgc3lzY2FsbC4KCkkgdGhpbmsgaXQncyBhdCBsZWFz
dCB3b3J0aCBjb25zaWRlcmluZy4KCi0tQW5keQpfX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fXwpDb250YWluZXJzIG1haWxpbmcgbGlzdApDb250YWluZXJzQGxp
c3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnCmh0dHBzOi8vbGlzdHMubGludXhmb3VuZGF0aW9uLm9y
Zy9tYWlsbWFuL2xpc3RpbmZvL2NvbnRhaW5lcnM=
