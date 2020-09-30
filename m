Return-Path: <SRS0=U9nl=DH=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77ADBC4363D
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 23:12:08 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id E5BA5206C1
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 23:12:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="Qj7K/vkx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E5BA5206C1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id A729187238;
	Wed, 30 Sep 2020 23:12:07 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id TFQPe+BA1uax; Wed, 30 Sep 2020 23:12:03 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id E742286F3A;
	Wed, 30 Sep 2020 23:12:03 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id C3EE4C016F;
	Wed, 30 Sep 2020 23:12:03 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id E594CC0051
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 23:12:01 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id D8EB885DF6
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 23:12:01 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 7pYP0OwsM5tT
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 23:12:01 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ed1-f48.google.com (mail-ed1-f48.google.com
 [209.85.208.48])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id F214F84F24
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 23:12:00 +0000 (UTC)
Received: by mail-ed1-f48.google.com with SMTP id n13so3638444edo.10
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 16:12:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc:content-transfer-encoding;
 bh=5xNLcu2ZBibcOX9eRdIGOJeEwkJ0lfgOo9QwHDvHXzQ=;
 b=Qj7K/vkx1A15tnnaZGTfZl+ftwHdXkr1sOL1XvvbJjxZt6685kUiCjB86O17zRpzT+
 fjB3agEdH+lpJttlavg86WCDK/CZ/w8oa+3tm66zd471+mfvUnVBT4hdtV9fr6yowepg
 +X46wdd3diEHymNJT8fTyl2VcCe6QysxchzK/I0DHPed+T2YFKyVudi6rWQpwhEcD3et
 sd6uMoaB9fxNujxXaN2i+lH8Mzxt31C5S20E50O40rHcNBtvsXjvgoQYX09+AQJ5Z0i6
 m98jq1Z/UM0SauyOxFb+wrxUMwuh71pRjyiDIAwjbJtiW/Y3Mc80NcR6gKB3CqeK9jM1
 /Btg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc:content-transfer-encoding;
 bh=5xNLcu2ZBibcOX9eRdIGOJeEwkJ0lfgOo9QwHDvHXzQ=;
 b=UBF4bpeOdbf9XDFMxTHkgp4uSjbAZ6DKkDMljJZBw29+1DjVTR+OgKpo9sNAxbSlTw
 bCzm6mKsahWNOyWRnG/gtHpSfWPzYzujA9ewJV+E5B6ECe/bFbIRbffFPWtckLkEqZ2o
 mm2G5FTcEj3n+rIzo/x+7b3GOHUxLBjEpHXjuYNR4puDJAwFaX35YTU3/4Qt5kuLZzSY
 eHA4gGltXWl0JVjjcsjQ2GyGyDZ+WmmbtztuSieSvj7hliYnCAhNp7kdf86mHXzMHe9+
 VSzAghHBp7n17dZlHZ+OTINWYOaW6LpoUu+9xqSbC9R3Am4c3cP91kq4qm/jA9SXUx7W
 FwcA==
X-Gm-Message-State: AOAM530eeRS6ejSF2gaIYfkkJGUdecZ2gbKSzgoUFUZek2le7YkrwcWq
 jK9yVA8YfGK79n/shg7eBvYgKTx204Xlf4wXKme0zQ==
X-Google-Smtp-Source: ABdhPJwrGlHwTQPZ++L0mLOF85y9/7LbEqNJ1w3mzMjO76tBkyLKmj9U5lGPSOwZW9qqkPLK2MLrOgZEPPp5jfWkAiQ=
X-Received: by 2002:a50:e807:: with SMTP id e7mr5401960edn.84.1601507519254;
 Wed, 30 Sep 2020 16:11:59 -0700 (PDT)
MIME-Version: 1.0
References: <45f07f17-18b6-d187-0914-6f341fe90857@gmail.com>
 <20200930150330.GC284424@cisco>
 <8bcd956f-58d2-d2f0-ca7c-0a30f3fcd5b8@gmail.com>
 <20200930230327.GA1260245@cisco>
In-Reply-To: <20200930230327.GA1260245@cisco>
Date: Thu, 1 Oct 2020 01:11:33 +0200
Message-ID: <CAG48ez1VOUEHVQyo-2+uO7J+-jN5rh7=KmrMJiPaFjwCbKR1Sg@mail.gmail.com>
Subject: Re: For review: seccomp_user_notif(2) manual page
To: Tycho Andersen <tycho@tycho.pizza>
Cc: linux-man <linux-man@vger.kernel.org>, Song Liu <songliubraving@fb.com>,
 Will Drewry <wad@chromium.org>, Kees Cook <keescook@chromium.org>,
 Daniel Borkmann <daniel@iogearbox.net>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Robert Sesek <rsesek@google.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 lkml <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
 "Michael Kerrisk \(man-pages\)" <mtk.manpages@gmail.com>,
 bpf <bpf@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>,
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
From: Jann Horn via Containers <containers@lists.linux-foundation.org>
Reply-To: Jann Horn <jannh@google.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

T24gVGh1LCBPY3QgMSwgMjAyMCBhdCAxOjAzIEFNIFR5Y2hvIEFuZGVyc2VuIDx0eWNob0B0eWNo
by5waXp6YT4gd3JvdGU6DQo+IE9uIFdlZCwgU2VwIDMwLCAyMDIwIGF0IDEwOjM0OjUxUE0gKzAy
MDAsIE1pY2hhZWwgS2VycmlzayAobWFuLXBhZ2VzKSB3cm90ZToNCj4gPiBPbiA5LzMwLzIwIDU6
MDMgUE0sIFR5Y2hvIEFuZGVyc2VuIHdyb3RlOg0KPiA+ID4gT24gV2VkLCBTZXAgMzAsIDIwMjAg
YXQgMDE6MDc6MzhQTSArMDIwMCwgTWljaGFlbCBLZXJyaXNrIChtYW4tcGFnZXMpIHdyb3RlOg0K
PiA+ID4+ICAgICAgICDilIzilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDi
lIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDi
lIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDi
lIDilIDilJANCj4gPiA+PiAgICAgICAg4pSCRklYTUUgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICDilIINCj4gPiA+PiAgICAgICAg4pSc4pSA4pSA4pSA4pSA
4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA
4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA
4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSkDQo+ID4gPj4gICAgICAgIOKUgkZy
b20gbXkgZXhwZXJpbWVudHMsICBpdCAgYXBwZWFycyAgdGhhdCAgaWYgIGEgIFNFQ+KAkCDilIIN
Cj4gPiA+PiAgICAgICAg4pSCQ09NUF9JT0NUTF9OT1RJRl9SRUNWICAgaXMgIGRvbmUgIGFmdGVy
ICB0aGUgIHRhcmdldCDilIINCj4gPiA+PiAgICAgICAg4pSCcHJvY2VzcyB0ZXJtaW5hdGVzLCB0
aGVuIHRoZSBpb2N0bCgpICBzaW1wbHkgIGJsb2NrcyDilIINCj4gPiA+PiAgICAgICAg4pSCKHJh
dGhlciB0aGFuIHJldHVybmluZyBhbiBlcnJvciB0byBpbmRpY2F0ZSB0aGF0IHRoZSDilIINCj4g
PiA+PiAgICAgICAg4pSCdGFyZ2V0IHByb2Nlc3Mgbm8gbG9uZ2VyIGV4aXN0cykuICAgICAgICAg
ICAgICAgICAgICDilIINCj4gPiA+DQo+ID4gPiBZZWFoLCBJIHRoaW5rIENocmlzdGlhbiB3YW50
ZWQgdG8gZml4IHRoaXMgYXQgc29tZSBwb2ludCwNCj4gPg0KPiA+IERvIHlvdSBoYXZlIGEgcG9p
bnRlciB0aGF0IGRpc2N1c3Npb24/IEkgY291bGQgbm90IGZpbmQgaXQgd2l0aCBhDQo+ID4gcXVp
Y2sgc2VhcmNoLg0KPiA+DQo+ID4gPiBidXQgaXQncyBhDQo+ID4gPiBiaXQgc3RpY2t5IHRvIGRv
Lg0KPiA+DQo+ID4gQ2FuIHlvdSBzYXkgYSBmZXcgd29yZHMgYWJvdXQgdGhlIG5hdHVyZSBvZiB0
aGUgcHJvYmxlbT8NCj4NCj4gSSByZW1lbWJlcmVkIHdyb25nLCBpdCdzIGFjdHVhbGx5IGluIHRo
ZSB0cmVlOiA5OWNkYjhiOWE1NzMgKCJzZWNjb21wOg0KPiBub3RpZnkgYWJvdXQgdW51c2VkIGZp
bHRlciIpLiBTbyBtYXliZSB0aGVyZSdzIGEgYnVnIGhlcmU/DQoNClRoYXQgdGhpbmcgb25seSBu
b3RpZmllcyBvbiAtPnBvbGwsIGl0IGRvZXNuJ3QgdW5ibG9jayBpb2N0bHM7IGFuZA0KTWljaGFl
bCdzIHNhbXBsZSBjb2RlIHVzZXMgU0VDQ09NUF9JT0NUTF9OT1RJRl9SRUNWIHRvIHdhaXQuIFNv
IHRoYXQNCmNvbW1pdCBkb2Vzbid0IGhhdmUgYW55IGVmZmVjdCBvbiB0aGlzIGtpbmQgb2YgdXNh
Z2UuDQpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpDb250
YWluZXJzIG1haWxpbmcgbGlzdApDb250YWluZXJzQGxpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3Jn
Cmh0dHBzOi8vbGlzdHMubGludXhmb3VuZGF0aW9uLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2NvbnRh
aW5lcnM=
