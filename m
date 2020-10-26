Return-Path: <SRS0=D+Sq=EB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC102C388F9
	for <containers@archiver.kernel.org>; Mon, 26 Oct 2020 09:51:38 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 1046F20874
	for <containers@archiver.kernel.org>; Mon, 26 Oct 2020 09:51:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="XQtZGUAH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1046F20874
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 426F62E0ED;
	Mon, 26 Oct 2020 09:51:37 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id NFoTARQg-Apr; Mon, 26 Oct 2020 09:51:34 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 4767D2E0E8;
	Mon, 26 Oct 2020 09:51:34 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 2E054C088B;
	Mon, 26 Oct 2020 09:51:34 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 74D85C0051
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 09:51:32 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 6971A86135
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 09:51:32 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id IS-65D4dwqok
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 09:51:31 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-lj1-f193.google.com (mail-lj1-f193.google.com
 [209.85.208.193])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 3D135860DE
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 09:51:31 +0000 (UTC)
Received: by mail-lj1-f193.google.com with SMTP id 134so8040215ljj.3
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 02:51:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc:content-transfer-encoding;
 bh=cvHwOhMOSComXSdb9JzaD65zvZyc8ZwqG/MT8SEmCr8=;
 b=XQtZGUAHkXcAtHyAFMQ1vUo2SRdyz1VTbCBYc3OxQqPVEDxUROYbSDuXYTV+wPwvOs
 bo6Whtw0w3Gch8zWAmLP2t9kbJxBFNr6Mi5f+xVH3J1ZAVGWhx0VWR2avbCuyOshfRO0
 DWEXO8kzycOpjVtgfOBpaH+M5qb1mNKM5AJxU5TnoJPyU4x6nZfHSebAOZd3yCQV6g+8
 oUjYGls24BaLCdidNGO5roRQAtdFSRSSyxhFr4rA8QHpe/nTUDkeMHDT527K8vAMYO/w
 D3HWTTv7P6xwQKqO0U0SMYcZ/IboJdZHtFdbG8SQYIsx+ANP0tj6ZvjWn9VO557znNi2
 x6hg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc:content-transfer-encoding;
 bh=cvHwOhMOSComXSdb9JzaD65zvZyc8ZwqG/MT8SEmCr8=;
 b=qEeWeSmkxNE/Z56KXqRTNw8VFSTPDWfgKhY3wXexhTYDn9RUpeVGRkisX8J0j26pUD
 vxrMaJiTFno9I4pEocebJvjXsDsqJshhb6mgYVpWosnCGKIKE2i2z/+91/j7Z82InIHC
 pHmOyD/JPSnQlOxUTPzGp9nUMnOfaGHoVGeWX1Wv6B9rVjvQ6jfaAn4Y8Qu7Op0fr0kG
 bqOOTj/1kujKDMGR/RPxb8lVPuI3vLGIeOTAOaj/ys7DANhXPefDi2jk4B1hq/uQmUdk
 qH0B/4LsLjhZR413sJyYnypGJ/m4H9MtYeE57jTwRYx72WYr0q8AlndQK+by+BPDzT2J
 6VZA==
X-Gm-Message-State: AOAM532HI7SiCM63UG2fx+wJguoFnrNq36vaXolzzt1MV9yZ9Wu9yXK7
 pZW476JlPizKt6ha37kdPFl/yHQIgamMp8mZ8H5dlg==
X-Google-Smtp-Source: ABdhPJy3fjEBGpGIryQc4Y6LVPm/reRxy/Wkv+7lUQ8mQvLHz9l8MltT/z36Blg+feaWzbgimjmcpy0nt4YNvjefuK0=
X-Received: by 2002:a2e:9f13:: with SMTP id u19mr5255189ljk.160.1603705889194; 
 Mon, 26 Oct 2020 02:51:29 -0700 (PDT)
MIME-Version: 1.0
References: <45f07f17-18b6-d187-0914-6f341fe90857@gmail.com>
 <20200930150330.GC284424@cisco>
 <8bcd956f-58d2-d2f0-ca7c-0a30f3fcd5b8@gmail.com>
 <20200930230327.GA1260245@cisco>
 <CAG48ez1VOUEHVQyo-2+uO7J+-jN5rh7=KmrMJiPaFjwCbKR1Sg@mail.gmail.com>
 <20200930232456.GB1260245@cisco>
 <CAG48ez2xn+_KznEztJ-eVTsTzkbf9CVgPqaAk7TpRNAqbdaRoA@mail.gmail.com>
 <202010251725.2BD96926E3@keescook>
In-Reply-To: <202010251725.2BD96926E3@keescook>
Date: Mon, 26 Oct 2020 10:51:02 +0100
Message-ID: <CAG48ez2b-fnsp8YAR=H5uRMT4bBTid_hyU4m6KavHxDko1Efog@mail.gmail.com>
Subject: Re: For review: seccomp_user_notif(2) manual page
To: Kees Cook <keescook@chromium.org>
Cc: linux-man <linux-man@vger.kernel.org>, Song Liu <songliubraving@fb.com>,
 Will Drewry <wad@chromium.org>, Robert Sesek <rsesek@google.com>,
 Daniel Borkmann <daniel@iogearbox.net>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
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

T24gTW9uLCBPY3QgMjYsIDIwMjAgYXQgMTozMiBBTSBLZWVzIENvb2sgPGtlZXNjb29rQGNocm9t
aXVtLm9yZz4gd3JvdGU6Cj4gT24gVGh1LCBPY3QgMDEsIDIwMjAgYXQgMDM6NTI6MDJBTSArMDIw
MCwgSmFubiBIb3JuIHdyb3RlOgo+ID4gT24gVGh1LCBPY3QgMSwgMjAyMCBhdCAxOjI1IEFNIFR5
Y2hvIEFuZGVyc2VuIDx0eWNob0B0eWNoby5waXp6YT4gd3JvdGU6Cj4gPiA+IE9uIFRodSwgT2N0
IDAxLCAyMDIwIGF0IDAxOjExOjMzQU0gKzAyMDAsIEphbm4gSG9ybiB3cm90ZToKPiA+ID4gPiBP
biBUaHUsIE9jdCAxLCAyMDIwIGF0IDE6MDMgQU0gVHljaG8gQW5kZXJzZW4gPHR5Y2hvQHR5Y2hv
LnBpenphPiB3cm90ZToKPiA+ID4gPiA+IE9uIFdlZCwgU2VwIDMwLCAyMDIwIGF0IDEwOjM0OjUx
UE0gKzAyMDAsIE1pY2hhZWwgS2VycmlzayAobWFuLXBhZ2VzKSB3cm90ZToKPiA+ID4gPiA+ID4g
T24gOS8zMC8yMCA1OjAzIFBNLCBUeWNobyBBbmRlcnNlbiB3cm90ZToKPiA+ID4gPiA+ID4gPiBP
biBXZWQsIFNlcCAzMCwgMjAyMCBhdCAwMTowNzozOFBNICswMjAwLCBNaWNoYWVsIEtlcnJpc2sg
KG1hbi1wYWdlcykgd3JvdGU6Cj4gPiA+ID4gPiA+ID4+ICAgICAgICDilIzilIDilIDilIDilIDi
lIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDi
lIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDi
lIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilJAKPiA+ID4gPiA+ID4gPj4gICAgICAg
IOKUgkZJWE1FICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
4pSCCj4gPiA+ID4gPiA+ID4+ICAgICAgICDilJzilIDilIDilIDilIDilIDilIDilIDilIDilIDi
lIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDi
lIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDi
lIDilIDilIDilIDilIDilIDilKQKPiA+ID4gPiA+ID4gPj4gICAgICAgIOKUgkZyb20gbXkgZXhw
ZXJpbWVudHMsICBpdCAgYXBwZWFycyAgdGhhdCAgaWYgIGEgIFNFQ+KAkCDilIIKPiA+ID4gPiA+
ID4gPj4gICAgICAgIOKUgkNPTVBfSU9DVExfTk9USUZfUkVDViAgIGlzICBkb25lICBhZnRlciAg
dGhlICB0YXJnZXQg4pSCCj4gPiA+ID4gPiA+ID4+ICAgICAgICDilIJwcm9jZXNzIHRlcm1pbmF0
ZXMsIHRoZW4gdGhlIGlvY3RsKCkgIHNpbXBseSAgYmxvY2tzIOKUggo+ID4gPiA+ID4gPiA+PiAg
ICAgICAg4pSCKHJhdGhlciB0aGFuIHJldHVybmluZyBhbiBlcnJvciB0byBpbmRpY2F0ZSB0aGF0
IHRoZSDilIIKPiA+ID4gPiA+ID4gPj4gICAgICAgIOKUgnRhcmdldCBwcm9jZXNzIG5vIGxvbmdl
ciBleGlzdHMpLiAgICAgICAgICAgICAgICAgICAg4pSCCj4gPiA+ID4gPiA+ID4KPiA+ID4gPiA+
ID4gPiBZZWFoLCBJIHRoaW5rIENocmlzdGlhbiB3YW50ZWQgdG8gZml4IHRoaXMgYXQgc29tZSBw
b2ludCwKPiA+ID4gPiA+ID4KPiA+ID4gPiA+ID4gRG8geW91IGhhdmUgYSBwb2ludGVyIHRoYXQg
ZGlzY3Vzc2lvbj8gSSBjb3VsZCBub3QgZmluZCBpdCB3aXRoIGEKPiA+ID4gPiA+ID4gcXVpY2sg
c2VhcmNoLgo+ID4gPiA+ID4gPgo+ID4gPiA+ID4gPiA+IGJ1dCBpdCdzIGEKPiA+ID4gPiA+ID4g
PiBiaXQgc3RpY2t5IHRvIGRvLgo+ID4gPiA+ID4gPgo+ID4gPiA+ID4gPiBDYW4geW91IHNheSBh
IGZldyB3b3JkcyBhYm91dCB0aGUgbmF0dXJlIG9mIHRoZSBwcm9ibGVtPwo+ID4gPiA+ID4KPiA+
ID4gPiA+IEkgcmVtZW1iZXJlZCB3cm9uZywgaXQncyBhY3R1YWxseSBpbiB0aGUgdHJlZTogOTlj
ZGI4YjlhNTczICgic2VjY29tcDoKPiA+ID4gPiA+IG5vdGlmeSBhYm91dCB1bnVzZWQgZmlsdGVy
IikuIFNvIG1heWJlIHRoZXJlJ3MgYSBidWcgaGVyZT8KPiA+ID4gPgo+ID4gPiA+IFRoYXQgdGhp
bmcgb25seSBub3RpZmllcyBvbiAtPnBvbGwsIGl0IGRvZXNuJ3QgdW5ibG9jayBpb2N0bHM7IGFu
ZAo+ID4gPiA+IE1pY2hhZWwncyBzYW1wbGUgY29kZSB1c2VzIFNFQ0NPTVBfSU9DVExfTk9USUZf
UkVDViB0byB3YWl0LiBTbyB0aGF0Cj4gPiA+ID4gY29tbWl0IGRvZXNuJ3QgaGF2ZSBhbnkgZWZm
ZWN0IG9uIHRoaXMga2luZCBvZiB1c2FnZS4KPiA+ID4KPiA+ID4gWWVzLCB0aGFua3MuIEFuZCB0
aGUgb25lcyBzdHVjayBpbiBSRUNWIGFyZSB3YWl0aW5nIG9uIGEgc2VtYXBob3JlIHNvCj4gPiA+
IHdlIGRvbid0IGhhdmUgYSBjb3VudCBvZiBhbGwgb2YgdGhlbSwgdW5mb3J0dW5hdGVseS4KPiA+
ID4KPiA+ID4gV2UgY291bGQgbWF5YmUgbG9vayBpbnNpZGUgdGhlIHdhaXRfbGlzdCwgYnV0IHRo
YXQgd2lsbCBwcm9iYWJseSBtYWtlCj4gPiA+IHBlb3BsZSBhbmdyeSA6KQo+ID4KPiA+IFRoZSBl
YXNpZXN0IHdheSB3b3VsZCBwcm9iYWJseSBiZSB0byBvcGVuLWNvZGUgdGhlIHNlbWFwaG9yZS1p
c2ggcGFydCwKPiA+IGFuZCBsZXQgdGhlIHNlbWFwaG9yZSBhbmQgcG9sbCBzaGFyZSB0aGUgd2Fp
dHF1ZXVlLiBUaGUgY3VycmVudCBjb2RlCj4gPiBraW5kIG9mIG1pcnJvcnMgdGhlIHNlbWFwaG9y
ZSdzIHdhaXRxdWV1ZSBpbiB0aGUgd3FoIC0gb3Blbi1jb2RpbmcgdGhlCj4gPiBlbnRpcmUgc2Vt
YXBob3JlIHdvdWxkIElNTyBiZSBjbGVhbmVyIHRoYW4gdGhhdC4gQW5kIGl0J3Mgbm90IGxpa2UK
PiA+IHNlbWFwaG9yZSBzZW1hbnRpY3MgYXJlIGV2ZW4gYSBnb29kIGZpdCBmb3IgdGhpcyBjb2Rl
IGFueXdheS4KPiA+Cj4gPiBMZXQncyBzZWUuLi4gaWYgd2UgZGlkbid0IGhhdmUgdGhlIGV4aXN0
aW5nIFVBUEkgdG8gd29ycnkgYWJvdXQsIEknZAo+ID4gZG8gaXQgYXMgZm9sbG93cyAoKmNvbXBs
ZXRlbHkqIHVudGVzdGVkKS4gVGhhdCB3YXksIHRoZSBpb2N0bCB3b3VsZAo+ID4gYmxvY2sgZXhh
Y3RseSB1bnRpbCBlaXRoZXIgdGhlcmUgYWN0dWFsbHkgaXMgYSByZXF1ZXN0IHRvIGRlbGl2ZXIg
b3IKPiA+IHRoZXJlIGFyZSBubyBtb3JlIHVzZXJzIG9mIHRoZSBmaWx0ZXIuIFRoZSBwcm9ibGVt
IGlzIHRoYXQgaWYgd2UganVzdAo+ID4gYXBwbHkgdGhpcyBwYXRjaCwgZXhpc3RpbmcgdXNlcnMg
b2YgU0VDQ09NUF9JT0NUTF9OT1RJRl9SRUNWIHRoYXQgdXNlCj4gPiBhbiBldmVudCBsb29wIGFu
ZCBkb24ndCBzZXQgT19OT05CTE9DSyB3aWxsIGJlIHNjcmV3ZWQuIFNvIHdlJ2QKPgo+IFdhaXQs
IHdoeT8gRG8geW91IG1lYW4gYSBpb2N0bCBjYWxsaW5nIGxvb3AgKHJhdGhlciB0aGFuIGEgcG9s
bCBldmVudAo+IGxvb3ApPwoKTm8sIEknbSB0YWxraW5nIGFib3V0IHBvbGwgZXZlbnQgbG9vcHMu
Cgo+IEkgdGhpbmsgcG9sbCB3b3VsZCBiZSBmaW5lLCBidXQgYSAidHJ5IGNhbGxpbmcgUkVDViBh
bmQgZXhwZWN0IHRvCj4gcmV0dXJuIEVOT0VOVCIgbG9vcCB3b3VsZCBjaGFuZ2UuIEJ1dCBJIGRv
bid0IHRoaW5rIGFueW9uZSB3b3VsZCBkbyB0aGlzCj4gZXhhY3RseSBiZWNhdXNlIGl0IF9jdXJy
ZW50bHlfIGFjdHMgbGlrZSBPX05PTkJMT0NLLCB5ZXM/Cj4KPiA+IHByb2JhYmx5IGFsc28gaGF2
ZSB0byBhZGQgc29tZSBzdHVwaWQgY291bnRlciBpbiBwbGFjZSBvZiB0aGUKPiA+IHNlbWFwaG9y
ZSdzIGNvdW50ZXIgdGhhdCB3ZSBjYW4gdXNlIHRvIHByZXNlcnZlIHRoZSBvbGQgYmVoYXZpb3Ig
b2YKPiA+IHJldHVybmluZyAtRU5PRU5UIG9uY2UgZm9yIGVhY2ggY2FuY2VsbGVkIHJlcXVlc3Qu
IDooCj4KPiBJIG9ubHkgc2VlIHRoaXMgaW4gRGViaWFuIENvZGUgU2VhcmNoOgo+IGh0dHBzOi8v
c291cmNlcy5kZWJpYW4ub3JnL3NyYy9jcnVuLzAuMTUrZGZzZy0xL3NyYy9saWJjcnVuL3NlY2Nv
bXBfbm90aWZ5LmMvP2hsPTE2NiNMMTY2Cj4gd2hpY2ggaXMgdXNpbmcgZXBvbGxfd2FpdCgpOgo+
IGh0dHBzOi8vc291cmNlcy5kZWJpYW4ub3JnL3NyYy9jcnVuLzAuMTUrZGZzZy0xL3NyYy9saWJj
cnVuL2NvbnRhaW5lci5jLz9obD0xMzI2I0wxMzI2Cj4KPiBJIGV4cGVjdCBMWEMgaXMgdXNpbmcg
aXQuIDopCgpUaGUgcHJvYmxlbSBpcyB0aGUgc2NlbmFyaW8gd2hlcmUgYSBwcm9jZXNzIGlzIGlu
dGVycnVwdGVkIHdoaWxlIGl0J3MKd2FpdGluZyBmb3IgdGhlIHN1cGVydmlzb3IgdG8gcmVwbHku
CgpDb25zaWRlciB0aGUgZm9sbG93aW5nIHNjZW5hcmlvICh3aXRoIHN1cGVydmlzb3IgIlMiIGFu
ZCB0YXJnZXQgIlQiOyBTCndhbnRzIHRvIHdhaXQgZm9yIGV2ZW50cyBvbiB0d28gZmlsZSBkZXNj
cmlwdG9ycyBzZWNjb21wX2ZkIGFuZApvdGhlcl9mZCk6CgpTOiBzdGFydHMgcG9sbCgpIHRvIHdh
aXQgZm9yIGV2ZW50cyBvbiBzZWNjb21wX2ZkIGFuZCBvdGhlcl9mZApUOiBwZXJmb3JtcyBhIHN5
c2NhbGwgdGhhdCdzIGZpbHRlcmVkIHdpdGggUkVUX1VTRVJfTk9USUYKUzogcG9sbCgpIHJldHVy
bnMgYW5kIHNpZ25hbHMgcmVhZGluZXNzIG9mIHNlY2NvbXBfZmQKVDogcmVjZWl2ZXMgc2lnbmFs
IFNJR1VTUjEKVDogc3lzY2FsbCBhYm9ydHMsIGVudGVycyBzaWduYWwgaGFuZGxlcgpUOiBzaWdu
YWwgaGFuZGxlciBibG9ja3Mgb24gdW5maWx0ZXJlZCBzeXNjYWxsIChlLmcuIHdyaXRlKCkpClM6
IHN0YXJ0cyBTRUNDT01QX0lPQ1RMX05PVElGX1JFQ1YKUzogYmxvY2tzIGJlY2F1c2Ugbm8gc3lz
Y2FsbHMgYXJlIHBlbmRpbmcKCkRlcGVuZGluZyBvbiB3aGF0IG90aGVyX2ZkIGlzLCB0aGlzIGNv
dWxkIGluIGEgd29yc3QgY2FzZSBldmVuIGxlYWQgdG8KYSBkZWFkbG9jayAoaWYgZS5nLiB0aGUg
c2lnbmFsIGhhbmRsZXIgd2FudHMgdG8gd3JpdGUgdG8gc3Rkb3V0LCBidXQKdGhlIHN0ZG91dCBm
ZCBpcyBob29rZWQgdXAgdG8gb3RoZXJfZmQgaW4gdGhlIHN1cGVydmlzb3IsIGJ1dCB0aGUKc3Vw
ZXJ2aXNvciBjYW4ndCBjb25zdW1lIHRoZSBkYXRhIHdyaXR0ZW4gYmVjYXVzZSBpdCdzIHN0dWNr
IGluCnNlY2NvbXAgaGFuZGxpbmcpLgoKU28gd2UgaGF2ZSB0byBlbnN1cmUgdGhhdCB3aGVuIGV4
aXN0aW5nIGNvZGUgKGxpa2UgdGhhdCBjcnVuIGNvZGUgeW91CmxpbmtlZCB0bykgdHJpZ2dlcnMg
dGhpcyBjYXNlLCBTRUNDT01QX0lPQ1RMX05PVElGX1JFQ1YgcmV0dXJucwppbW1lZGlhdGVseSBp
bnN0ZWFkIG9mIGJsb2NraW5nLgoKKE9oLCBidXQgYnkgdGhlIHdheSwgdGhhdCBjcnVuIGNvZGUg
bG9va3MgYnJva2VuIGFueXdheSwgYmVjYXVzZQpBRkFJQ1MgaXQgdHJlYXRzIGFsbCBlcnJvciBy
ZXR1cm5zIGZyb20gU0VDQ09NUF9JT0NUTF9OT1RJRl9SRUNWCmVxdWFsbHkgYnkgYmFpbGluZyBv
dXQ7IGFuZCBpdCBraW5kYSBsb29rcyBsaWtlIHRoYXQgYmFpbG91dCBwYXRoIHRoZW4KbnVrZXMg
dGhlIGNvbnRhaW5lciwgb3Igc29tZXRoaW5nPyBTbyB0aGF0IG5lZWRzIHRvIGJlIGZpeGVkIGVp
dGhlcgp3YXkuKQpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
XwpDb250YWluZXJzIG1haWxpbmcgbGlzdApDb250YWluZXJzQGxpc3RzLmxpbnV4LWZvdW5kYXRp
b24ub3JnCmh0dHBzOi8vbGlzdHMubGludXhmb3VuZGF0aW9uLm9yZy9tYWlsbWFuL2xpc3RpbmZv
L2NvbnRhaW5lcnM=
