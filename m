Return-Path: <SRS0=D+Sq=EB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1FC7C4363A
	for <containers@archiver.kernel.org>; Mon, 26 Oct 2020 10:31:36 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 38D9C2076D
	for <containers@archiver.kernel.org>; Mon, 26 Oct 2020 10:31:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="BuyO+kGC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 38D9C2076D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id A4E67863FD;
	Mon, 26 Oct 2020 10:31:35 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 6+l3wDshvMND; Mon, 26 Oct 2020 10:31:33 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 0930B8638F;
	Mon, 26 Oct 2020 10:31:33 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id F2989C0859;
	Mon, 26 Oct 2020 10:31:32 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 448D2C0051
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 10:31:32 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 3FA0D8722E
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 10:31:32 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id Tx5SzDlrhNmV
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 10:31:31 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-lf1-f67.google.com (mail-lf1-f67.google.com
 [209.85.167.67])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 192A58721E
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 10:31:31 +0000 (UTC)
Received: by mail-lf1-f67.google.com with SMTP id d24so11037739lfa.8
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 03:31:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc:content-transfer-encoding;
 bh=7HAHmiYh1s6lN4nRq33Z2NFlYANdAjAZHYUwYnpGrSI=;
 b=BuyO+kGChRJ1csFxxBKVeQTgKNwDgqEmjnFCPSmQkVEKWO5lnvrAtD+BM9uHThSSf5
 0iS0M8haTyprzZvG7XUTucFA4nVHpMccNoeEcZJpSpV2JJmJcTwymneHjwpiMLyG8Ws/
 Tt97XdiulcW7Cb8DwTerKvp6XjmjhBqa7N56WUgdiGgMDJvxN16I1sUYFElVLKphHpRo
 NW8wFJ9Jbw/vB853kGWH2sRX/mxDBCl763HERqniTYJv+n71/gwT6uTgNL8ywBx+CxW4
 G+zSWJc7ZL/02SRLfGa/JyMtSzYgMnhmoktVV0pS/Z7uoggnXtAPh0hqywYKbO7NtI//
 QOwA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc:content-transfer-encoding;
 bh=7HAHmiYh1s6lN4nRq33Z2NFlYANdAjAZHYUwYnpGrSI=;
 b=Q/0T03sONT236TI6F0dE2MI/KcqI/gpjHqaDDCQW+0+ZNAqc+Q9sPgji/f480kTBMF
 378mQGoH0zR8fsscRSj+KQs8HekrVs3O3cL1Q5Q/hIf0hDNLFJf0e9tNgGDlLdNffi2i
 DCETXF1ZHSDamYFCnMbcbjneSHlzC8Q4vMl16TkhOCUNkYBKiI5aj3StH3NwRwFxWJp0
 CDkDJBQQ7+w39U07RXCMqiKyujb5w4EZ0x+lGPMfj/HoFKL+ZdcF4hU5quTNYghttFUP
 hJ79hm6Fa8O/Ep4JzFE93JZPUn7dMxvVoN13oRkSiZlV+8Iqs4zUHo9rTpRbzGkTCCCL
 xoqw==
X-Gm-Message-State: AOAM532uiczBGdDvuhZuGJ3sx3xdu8CehXZJVLzscmqhoAeZ0Yiz3Fs3
 oObonRnGCbIEnmALLw/6FilNL/asUuTFZtadHT4u7Q==
X-Google-Smtp-Source: ABdhPJwhyMQilM9FU2cG9Ph4E9v0bbJUqbwFPAqmd1uHa041X8EAhpAghLBydXtVyyYA4w/+ZDVI4zl2X89K8o2czrw=
X-Received: by 2002:a05:6512:52f:: with SMTP id
 o15mr4371434lfc.381.1603708288674; 
 Mon, 26 Oct 2020 03:31:28 -0700 (PDT)
MIME-Version: 1.0
References: <45f07f17-18b6-d187-0914-6f341fe90857@gmail.com>
 <20200930150330.GC284424@cisco>
 <8bcd956f-58d2-d2f0-ca7c-0a30f3fcd5b8@gmail.com>
 <20200930230327.GA1260245@cisco>
 <CAG48ez1VOUEHVQyo-2+uO7J+-jN5rh7=KmrMJiPaFjwCbKR1Sg@mail.gmail.com>
 <20200930232456.GB1260245@cisco>
 <CAG48ez2xn+_KznEztJ-eVTsTzkbf9CVgPqaAk7TpRNAqbdaRoA@mail.gmail.com>
 <202010251725.2BD96926E3@keescook>
 <CAG48ez2b-fnsp8YAR=H5uRMT4bBTid_hyU4m6KavHxDko1Efog@mail.gmail.com>
In-Reply-To: <CAG48ez2b-fnsp8YAR=H5uRMT4bBTid_hyU4m6KavHxDko1Efog@mail.gmail.com>
Date: Mon, 26 Oct 2020 11:31:01 +0100
Message-ID: <CAG48ez2OWhpH3HHUJSrAmokJ8=SVwKrmQMSw0gEbTJmKE4myCw@mail.gmail.com>
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

T24gTW9uLCBPY3QgMjYsIDIwMjAgYXQgMTA6NTEgQU0gSmFubiBIb3JuIDxqYW5uaEBnb29nbGUu
Y29tPiB3cm90ZToKPiBPbiBNb24sIE9jdCAyNiwgMjAyMCBhdCAxOjMyIEFNIEtlZXMgQ29vayA8
a2Vlc2Nvb2tAY2hyb21pdW0ub3JnPiB3cm90ZToKPiA+IE9uIFRodSwgT2N0IDAxLCAyMDIwIGF0
IDAzOjUyOjAyQU0gKzAyMDAsIEphbm4gSG9ybiB3cm90ZToKPiA+ID4gT24gVGh1LCBPY3QgMSwg
MjAyMCBhdCAxOjI1IEFNIFR5Y2hvIEFuZGVyc2VuIDx0eWNob0B0eWNoby5waXp6YT4gd3JvdGU6
Cj4gPiA+ID4gT24gVGh1LCBPY3QgMDEsIDIwMjAgYXQgMDE6MTE6MzNBTSArMDIwMCwgSmFubiBI
b3JuIHdyb3RlOgo+ID4gPiA+ID4gT24gVGh1LCBPY3QgMSwgMjAyMCBhdCAxOjAzIEFNIFR5Y2hv
IEFuZGVyc2VuIDx0eWNob0B0eWNoby5waXp6YT4gd3JvdGU6Cj4gPiA+ID4gPiA+IE9uIFdlZCwg
U2VwIDMwLCAyMDIwIGF0IDEwOjM0OjUxUE0gKzAyMDAsIE1pY2hhZWwgS2VycmlzayAobWFuLXBh
Z2VzKSB3cm90ZToKPiA+ID4gPiA+ID4gPiBPbiA5LzMwLzIwIDU6MDMgUE0sIFR5Y2hvIEFuZGVy
c2VuIHdyb3RlOgo+ID4gPiA+ID4gPiA+ID4gT24gV2VkLCBTZXAgMzAsIDIwMjAgYXQgMDE6MDc6
MzhQTSArMDIwMCwgTWljaGFlbCBLZXJyaXNrIChtYW4tcGFnZXMpIHdyb3RlOgo+ID4gPiA+ID4g
PiA+ID4+ICAgICAgICDilIzilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDi
lIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDi
lIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDi
lIDilIDilJAKPiA+ID4gPiA+ID4gPiA+PiAgICAgICAg4pSCRklYTUUgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICDilIIKPiA+ID4gPiA+ID4gPiA+PiAgICAg
ICAg4pSc4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA
4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA
4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSkCj4g
PiA+ID4gPiA+ID4gPj4gICAgICAgIOKUgkZyb20gbXkgZXhwZXJpbWVudHMsICBpdCAgYXBwZWFy
cyAgdGhhdCAgaWYgIGEgIFNFQ+KAkCDilIIKPiA+ID4gPiA+ID4gPiA+PiAgICAgICAg4pSCQ09N
UF9JT0NUTF9OT1RJRl9SRUNWICAgaXMgIGRvbmUgIGFmdGVyICB0aGUgIHRhcmdldCDilIIKPiA+
ID4gPiA+ID4gPiA+PiAgICAgICAg4pSCcHJvY2VzcyB0ZXJtaW5hdGVzLCB0aGVuIHRoZSBpb2N0
bCgpICBzaW1wbHkgIGJsb2NrcyDilIIKPiA+ID4gPiA+ID4gPiA+PiAgICAgICAg4pSCKHJhdGhl
ciB0aGFuIHJldHVybmluZyBhbiBlcnJvciB0byBpbmRpY2F0ZSB0aGF0IHRoZSDilIIKPiA+ID4g
PiA+ID4gPiA+PiAgICAgICAg4pSCdGFyZ2V0IHByb2Nlc3Mgbm8gbG9uZ2VyIGV4aXN0cykuICAg
ICAgICAgICAgICAgICAgICDilIIKPiA+ID4gPiA+ID4gPiA+Cj4gPiA+ID4gPiA+ID4gPiBZZWFo
LCBJIHRoaW5rIENocmlzdGlhbiB3YW50ZWQgdG8gZml4IHRoaXMgYXQgc29tZSBwb2ludCwKPiA+
ID4gPiA+ID4gPgo+ID4gPiA+ID4gPiA+IERvIHlvdSBoYXZlIGEgcG9pbnRlciB0aGF0IGRpc2N1
c3Npb24/IEkgY291bGQgbm90IGZpbmQgaXQgd2l0aCBhCj4gPiA+ID4gPiA+ID4gcXVpY2sgc2Vh
cmNoLgo+ID4gPiA+ID4gPiA+Cj4gPiA+ID4gPiA+ID4gPiBidXQgaXQncyBhCj4gPiA+ID4gPiA+
ID4gPiBiaXQgc3RpY2t5IHRvIGRvLgo+ID4gPiA+ID4gPiA+Cj4gPiA+ID4gPiA+ID4gQ2FuIHlv
dSBzYXkgYSBmZXcgd29yZHMgYWJvdXQgdGhlIG5hdHVyZSBvZiB0aGUgcHJvYmxlbT8KPiA+ID4g
PiA+ID4KPiA+ID4gPiA+ID4gSSByZW1lbWJlcmVkIHdyb25nLCBpdCdzIGFjdHVhbGx5IGluIHRo
ZSB0cmVlOiA5OWNkYjhiOWE1NzMgKCJzZWNjb21wOgo+ID4gPiA+ID4gPiBub3RpZnkgYWJvdXQg
dW51c2VkIGZpbHRlciIpLiBTbyBtYXliZSB0aGVyZSdzIGEgYnVnIGhlcmU/Cj4gPiA+ID4gPgo+
ID4gPiA+ID4gVGhhdCB0aGluZyBvbmx5IG5vdGlmaWVzIG9uIC0+cG9sbCwgaXQgZG9lc24ndCB1
bmJsb2NrIGlvY3RsczsgYW5kCj4gPiA+ID4gPiBNaWNoYWVsJ3Mgc2FtcGxlIGNvZGUgdXNlcyBT
RUNDT01QX0lPQ1RMX05PVElGX1JFQ1YgdG8gd2FpdC4gU28gdGhhdAo+ID4gPiA+ID4gY29tbWl0
IGRvZXNuJ3QgaGF2ZSBhbnkgZWZmZWN0IG9uIHRoaXMga2luZCBvZiB1c2FnZS4KPiA+ID4gPgo+
ID4gPiA+IFllcywgdGhhbmtzLiBBbmQgdGhlIG9uZXMgc3R1Y2sgaW4gUkVDViBhcmUgd2FpdGlu
ZyBvbiBhIHNlbWFwaG9yZSBzbwo+ID4gPiA+IHdlIGRvbid0IGhhdmUgYSBjb3VudCBvZiBhbGwg
b2YgdGhlbSwgdW5mb3J0dW5hdGVseS4KPiA+ID4gPgo+ID4gPiA+IFdlIGNvdWxkIG1heWJlIGxv
b2sgaW5zaWRlIHRoZSB3YWl0X2xpc3QsIGJ1dCB0aGF0IHdpbGwgcHJvYmFibHkgbWFrZQo+ID4g
PiA+IHBlb3BsZSBhbmdyeSA6KQo+ID4gPgo+ID4gPiBUaGUgZWFzaWVzdCB3YXkgd291bGQgcHJv
YmFibHkgYmUgdG8gb3Blbi1jb2RlIHRoZSBzZW1hcGhvcmUtaXNoIHBhcnQsCj4gPiA+IGFuZCBs
ZXQgdGhlIHNlbWFwaG9yZSBhbmQgcG9sbCBzaGFyZSB0aGUgd2FpdHF1ZXVlLiBUaGUgY3VycmVu
dCBjb2RlCj4gPiA+IGtpbmQgb2YgbWlycm9ycyB0aGUgc2VtYXBob3JlJ3Mgd2FpdHF1ZXVlIGlu
IHRoZSB3cWggLSBvcGVuLWNvZGluZyB0aGUKPiA+ID4gZW50aXJlIHNlbWFwaG9yZSB3b3VsZCBJ
TU8gYmUgY2xlYW5lciB0aGFuIHRoYXQuIEFuZCBpdCdzIG5vdCBsaWtlCj4gPiA+IHNlbWFwaG9y
ZSBzZW1hbnRpY3MgYXJlIGV2ZW4gYSBnb29kIGZpdCBmb3IgdGhpcyBjb2RlIGFueXdheS4KPiA+
ID4KPiA+ID4gTGV0J3Mgc2VlLi4uIGlmIHdlIGRpZG4ndCBoYXZlIHRoZSBleGlzdGluZyBVQVBJ
IHRvIHdvcnJ5IGFib3V0LCBJJ2QKPiA+ID4gZG8gaXQgYXMgZm9sbG93cyAoKmNvbXBsZXRlbHkq
IHVudGVzdGVkKS4gVGhhdCB3YXksIHRoZSBpb2N0bCB3b3VsZAo+ID4gPiBibG9jayBleGFjdGx5
IHVudGlsIGVpdGhlciB0aGVyZSBhY3R1YWxseSBpcyBhIHJlcXVlc3QgdG8gZGVsaXZlciBvcgo+
ID4gPiB0aGVyZSBhcmUgbm8gbW9yZSB1c2VycyBvZiB0aGUgZmlsdGVyLiBUaGUgcHJvYmxlbSBp
cyB0aGF0IGlmIHdlIGp1c3QKPiA+ID4gYXBwbHkgdGhpcyBwYXRjaCwgZXhpc3RpbmcgdXNlcnMg
b2YgU0VDQ09NUF9JT0NUTF9OT1RJRl9SRUNWIHRoYXQgdXNlCj4gPiA+IGFuIGV2ZW50IGxvb3Ag
YW5kIGRvbid0IHNldCBPX05PTkJMT0NLIHdpbGwgYmUgc2NyZXdlZC4gU28gd2UnZAo+ID4KPiA+
IFdhaXQsIHdoeT8gRG8geW91IG1lYW4gYSBpb2N0bCBjYWxsaW5nIGxvb3AgKHJhdGhlciB0aGFu
IGEgcG9sbCBldmVudAo+ID4gbG9vcCk/Cj4KPiBObywgSSdtIHRhbGtpbmcgYWJvdXQgcG9sbCBl
dmVudCBsb29wcy4KPgo+ID4gSSB0aGluayBwb2xsIHdvdWxkIGJlIGZpbmUsIGJ1dCBhICJ0cnkg
Y2FsbGluZyBSRUNWIGFuZCBleHBlY3QgdG8KPiA+IHJldHVybiBFTk9FTlQiIGxvb3Agd291bGQg
Y2hhbmdlLiBCdXQgSSBkb24ndCB0aGluayBhbnlvbmUgd291bGQgZG8gdGhpcwo+ID4gZXhhY3Rs
eSBiZWNhdXNlIGl0IF9jdXJyZW50bHlfIGFjdHMgbGlrZSBPX05PTkJMT0NLLCB5ZXM/Cj4gPgo+
ID4gPiBwcm9iYWJseSBhbHNvIGhhdmUgdG8gYWRkIHNvbWUgc3R1cGlkIGNvdW50ZXIgaW4gcGxh
Y2Ugb2YgdGhlCj4gPiA+IHNlbWFwaG9yZSdzIGNvdW50ZXIgdGhhdCB3ZSBjYW4gdXNlIHRvIHBy
ZXNlcnZlIHRoZSBvbGQgYmVoYXZpb3Igb2YKPiA+ID4gcmV0dXJuaW5nIC1FTk9FTlQgb25jZSBm
b3IgZWFjaCBjYW5jZWxsZWQgcmVxdWVzdC4gOigKPiA+Cj4gPiBJIG9ubHkgc2VlIHRoaXMgaW4g
RGViaWFuIENvZGUgU2VhcmNoOgo+ID4gaHR0cHM6Ly9zb3VyY2VzLmRlYmlhbi5vcmcvc3JjL2Ny
dW4vMC4xNStkZnNnLTEvc3JjL2xpYmNydW4vc2VjY29tcF9ub3RpZnkuYy8/aGw9MTY2I0wxNjYK
PiA+IHdoaWNoIGlzIHVzaW5nIGVwb2xsX3dhaXQoKToKPiA+IGh0dHBzOi8vc291cmNlcy5kZWJp
YW4ub3JnL3NyYy9jcnVuLzAuMTUrZGZzZy0xL3NyYy9saWJjcnVuL2NvbnRhaW5lci5jLz9obD0x
MzI2I0wxMzI2Cj4gPgo+ID4gSSBleHBlY3QgTFhDIGlzIHVzaW5nIGl0LiA6KQo+Cj4gVGhlIHBy
b2JsZW0gaXMgdGhlIHNjZW5hcmlvIHdoZXJlIGEgcHJvY2VzcyBpcyBpbnRlcnJ1cHRlZCB3aGls
ZSBpdCdzCj4gd2FpdGluZyBmb3IgdGhlIHN1cGVydmlzb3IgdG8gcmVwbHkuCj4KPiBDb25zaWRl
ciB0aGUgZm9sbG93aW5nIHNjZW5hcmlvICh3aXRoIHN1cGVydmlzb3IgIlMiIGFuZCB0YXJnZXQg
IlQiOyBTCj4gd2FudHMgdG8gd2FpdCBmb3IgZXZlbnRzIG9uIHR3byBmaWxlIGRlc2NyaXB0b3Jz
IHNlY2NvbXBfZmQgYW5kCj4gb3RoZXJfZmQpOgo+Cj4gUzogc3RhcnRzIHBvbGwoKSB0byB3YWl0
IGZvciBldmVudHMgb24gc2VjY29tcF9mZCBhbmQgb3RoZXJfZmQKPiBUOiBwZXJmb3JtcyBhIHN5
c2NhbGwgdGhhdCdzIGZpbHRlcmVkIHdpdGggUkVUX1VTRVJfTk9USUYKPiBTOiBwb2xsKCkgcmV0
dXJucyBhbmQgc2lnbmFscyByZWFkaW5lc3Mgb2Ygc2VjY29tcF9mZAo+IFQ6IHJlY2VpdmVzIHNp
Z25hbCBTSUdVU1IxCj4gVDogc3lzY2FsbCBhYm9ydHMsIGVudGVycyBzaWduYWwgaGFuZGxlcgo+
IFQ6IHNpZ25hbCBoYW5kbGVyIGJsb2NrcyBvbiB1bmZpbHRlcmVkIHN5c2NhbGwgKGUuZy4gd3Jp
dGUoKSkKPiBTOiBzdGFydHMgU0VDQ09NUF9JT0NUTF9OT1RJRl9SRUNWCj4gUzogYmxvY2tzIGJl
Y2F1c2Ugbm8gc3lzY2FsbHMgYXJlIHBlbmRpbmcKPgo+IERlcGVuZGluZyBvbiB3aGF0IG90aGVy
X2ZkIGlzLCB0aGlzIGNvdWxkIGluIGEgd29yc3QgY2FzZSBldmVuIGxlYWQgdG8KPiBhIGRlYWRs
b2NrIChpZiBlLmcuIHRoZSBzaWduYWwgaGFuZGxlciB3YW50cyB0byB3cml0ZSB0byBzdGRvdXQs
IGJ1dAo+IHRoZSBzdGRvdXQgZmQgaXMgaG9va2VkIHVwIHRvIG90aGVyX2ZkIGluIHRoZSBzdXBl
cnZpc29yLCBidXQgdGhlCj4gc3VwZXJ2aXNvciBjYW4ndCBjb25zdW1lIHRoZSBkYXRhIHdyaXR0
ZW4gYmVjYXVzZSBpdCdzIHN0dWNrIGluCj4gc2VjY29tcCBoYW5kbGluZykuCj4KPiBTbyB3ZSBo
YXZlIHRvIGVuc3VyZSB0aGF0IHdoZW4gZXhpc3RpbmcgY29kZSAobGlrZSB0aGF0IGNydW4gY29k
ZSB5b3UKPiBsaW5rZWQgdG8pIHRyaWdnZXJzIHRoaXMgY2FzZSwgU0VDQ09NUF9JT0NUTF9OT1RJ
Rl9SRUNWIHJldHVybnMKPiBpbW1lZGlhdGVseSBpbnN0ZWFkIG9mIGJsb2NraW5nLgoKT3IgSSBn
dWVzcyB3ZSBjb3VsZCBhbHNvIGp1c3Qgc2V0IE9fTk9OQkxPQ0sgb24gdGhlIGZkIGJ5IGRlZmF1
bHQ/ClNpbmNlIHRoZSBvbmUgZXhpc3RpbmcgdXNlciBpcyBldmVudGxvb3AtYmFzZWQuLi4KX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KQ29udGFpbmVycyBt
YWlsaW5nIGxpc3QKQ29udGFpbmVyc0BsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczov
L2xpc3RzLmxpbnV4Zm91bmRhdGlvbi5vcmcvbWFpbG1hbi9saXN0aW5mby9jb250YWluZXJz
