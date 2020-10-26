Return-Path: <SRS0=D+Sq=EB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 765EDC4363A
	for <containers@archiver.kernel.org>; Mon, 26 Oct 2020 15:54:39 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id ADA7122400
	for <containers@archiver.kernel.org>; Mon, 26 Oct 2020 15:54:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="ds1ibtfW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADA7122400
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 39C79870BB;
	Mon, 26 Oct 2020 15:54:38 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id XRgeVXylqufA; Mon, 26 Oct 2020 15:54:37 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 81156870A8;
	Mon, 26 Oct 2020 15:54:37 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 74540C088B;
	Mon, 26 Oct 2020 15:54:37 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 87DA5C0051
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 15:54:36 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 838E8870B0
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 15:54:36 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id VNQhqn4KgAGe
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 15:54:35 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-lj1-f195.google.com (mail-lj1-f195.google.com
 [209.85.208.195])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 4026C870A8
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 15:54:34 +0000 (UTC)
Received: by mail-lj1-f195.google.com with SMTP id x16so10766599ljh.2
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 08:54:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc:content-transfer-encoding;
 bh=f9BpXZd1dePTO41DoQrRpftD/OWsykwv67IUek0mRlE=;
 b=ds1ibtfW9ahR96Tlz4l3O2V/NUXaipvZr+aslTh6VXSfEM3kHadDmcLxHX3+fim6vJ
 XY0aMB/b/crNHJ+KYUBJZ9iGD5uXLpL3GlW/LXPeqfuahvJ/oHJALa+ujnz4qCr+aF3G
 r3YPp5iqz7DHWZi7sVTcnGmjsSpbh0UvP+A1D/jSGedwgiDcEzQA2CCrlL6Pp0TOOfRR
 YMZcHkmybCLa/INJ/1vhYw0788bYvORlLQPrQTIeXQW7YGQIcVcM1gEQN52jutOBxAoP
 ZwBh7dYIIgqLz9FcZRZd4P1UVyI45sguGjVKNUDIESjDnNWyFcFcsZjbvjMRfKowcfFd
 EtFw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc:content-transfer-encoding;
 bh=f9BpXZd1dePTO41DoQrRpftD/OWsykwv67IUek0mRlE=;
 b=eSg0I7WElNabOBOiXIfas/VpI82qqrPkyK4exXa3h6NEn2V1eLoMwuteoywUZLoZIa
 ruhrj/H6N4cqPnQ2q81IUsr0bSxq75cof2Z/DJo08lkeKjoBHEffoQwoqh1YgpHmywqv
 Mf+SDPDuIM4LifpVFPiz1eQWyGV757KBMo5FOXrLx0JMCUPBFq4MUZ9AVyw358oGEQOq
 bL+ICtO4Uepk5Y7mNOXSPFF/qi/yMA/hIlG5HC2MlrYogInyubl/TeVk1n3JYJhDewG9
 Qr2s8iSjLpXoaRH8rR1n8GmRUedfGoJ6BK8QEM3lKqgOQqMUSMO0LAkFF9OWm2Hn9hRq
 DlDg==
X-Gm-Message-State: AOAM532WtM4Bz6WS0Jf3pbllyBMdRBPQ3WpcmxGQU1W54T5r2Ok432Kw
 JUJmiZcKQCcz1aCtqJcoI9ZtbG/B7/VWGUKDkRS4+Q==
X-Google-Smtp-Source: ABdhPJyfsg6Pn+1Y835UYicEETWbwyo+C5rrlUHlNo3ycyK5+vUjxRkzYBMWwSKKTQZitV4IVanOMj2G237Mp8vT7As=
X-Received: by 2002:a2e:9c84:: with SMTP id x4mr5972527lji.326.1603727672694; 
 Mon, 26 Oct 2020 08:54:32 -0700 (PDT)
MIME-Version: 1.0
References: <45f07f17-18b6-d187-0914-6f341fe90857@gmail.com>
 <20200930150330.GC284424@cisco>
 <8bcd956f-58d2-d2f0-ca7c-0a30f3fcd5b8@gmail.com>
 <20200930230327.GA1260245@cisco>
 <CAG48ez1VOUEHVQyo-2+uO7J+-jN5rh7=KmrMJiPaFjwCbKR1Sg@mail.gmail.com>
 <20200930232456.GB1260245@cisco>
 <CAG48ez2xn+_KznEztJ-eVTsTzkbf9CVgPqaAk7TpRNAqbdaRoA@mail.gmail.com>
 <CAG48ez3kpEDO1x_HfvOM2R9M78Ach9O_4+Pjs-vLLfqvZL+13A@mail.gmail.com>
 <656a37b5-75e3-0ded-6ba8-3bb57b537b24@gmail.com>
In-Reply-To: <656a37b5-75e3-0ded-6ba8-3bb57b537b24@gmail.com>
Date: Mon, 26 Oct 2020 16:54:05 +0100
Message-ID: <CAG48ez2Uy8=Tz9k1hcr0suLPHjbJi1qUviSGzDQ-XWEGsdNU+A@mail.gmail.com>
Subject: Re: For review: seccomp_user_notif(2) manual page
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: linux-man <linux-man@vger.kernel.org>, Song Liu <songliubraving@fb.com>,
 Will Drewry <wad@chromium.org>, Kees Cook <keescook@chromium.org>,
 Daniel Borkmann <daniel@iogearbox.net>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Robert Sesek <rsesek@google.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 lkml <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
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

T24gU3VuLCBPY3QgMjUsIDIwMjAgYXQgNTozMiBQTSBNaWNoYWVsIEtlcnJpc2sgKG1hbi1wYWdl
cykKPG10ay5tYW5wYWdlc0BnbWFpbC5jb20+IHdyb3RlOgo+IE9uIDEwLzEvMjAgNDoxNCBBTSwg
SmFubiBIb3JuIHdyb3RlOgo+ID4gT24gVGh1LCBPY3QgMSwgMjAyMCBhdCAzOjUyIEFNIEphbm4g
SG9ybiA8amFubmhAZ29vZ2xlLmNvbT4gd3JvdGU6Cj4gPj4gT24gVGh1LCBPY3QgMSwgMjAyMCBh
dCAxOjI1IEFNIFR5Y2hvIEFuZGVyc2VuIDx0eWNob0B0eWNoby5waXp6YT4gd3JvdGU6Cj4gPj4+
IE9uIFRodSwgT2N0IDAxLCAyMDIwIGF0IDAxOjExOjMzQU0gKzAyMDAsIEphbm4gSG9ybiB3cm90
ZToKPiA+Pj4+IE9uIFRodSwgT2N0IDEsIDIwMjAgYXQgMTowMyBBTSBUeWNobyBBbmRlcnNlbiA8
dHljaG9AdHljaG8ucGl6emE+IHdyb3RlOgo+ID4+Pj4+IE9uIFdlZCwgU2VwIDMwLCAyMDIwIGF0
IDEwOjM0OjUxUE0gKzAyMDAsIE1pY2hhZWwgS2VycmlzayAobWFuLXBhZ2VzKSB3cm90ZToKPiA+
Pj4+Pj4gT24gOS8zMC8yMCA1OjAzIFBNLCBUeWNobyBBbmRlcnNlbiB3cm90ZToKPiA+Pj4+Pj4+
IE9uIFdlZCwgU2VwIDMwLCAyMDIwIGF0IDAxOjA3OjM4UE0gKzAyMDAsIE1pY2hhZWwgS2Vycmlz
ayAobWFuLXBhZ2VzKSB3cm90ZToKPiA+Pj4+Pj4+PiAgICAgICAg4pSM4pSA4pSA4pSA4pSA4pSA
4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA
4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA
4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSQCj4gPj4+Pj4+Pj4gICAgICAgIOKUgkZJ
WE1FICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg4pSCCj4g
Pj4+Pj4+Pj4gICAgICAgIOKUnOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKU
gOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKU
gOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKU
gOKUgOKUgOKUpAo+ID4+Pj4+Pj4+ICAgICAgICDilIJGcm9tIG15IGV4cGVyaW1lbnRzLCAgaXQg
IGFwcGVhcnMgIHRoYXQgIGlmICBhICBTRUPigJAg4pSCCj4gPj4+Pj4+Pj4gICAgICAgIOKUgkNP
TVBfSU9DVExfTk9USUZfUkVDViAgIGlzICBkb25lICBhZnRlciAgdGhlICB0YXJnZXQg4pSCCj4g
Pj4+Pj4+Pj4gICAgICAgIOKUgnByb2Nlc3MgdGVybWluYXRlcywgdGhlbiB0aGUgaW9jdGwoKSAg
c2ltcGx5ICBibG9ja3Mg4pSCCj4gPj4+Pj4+Pj4gICAgICAgIOKUgihyYXRoZXIgdGhhbiByZXR1
cm5pbmcgYW4gZXJyb3IgdG8gaW5kaWNhdGUgdGhhdCB0aGUg4pSCCj4gPj4+Pj4+Pj4gICAgICAg
IOKUgnRhcmdldCBwcm9jZXNzIG5vIGxvbmdlciBleGlzdHMpLiAgICAgICAgICAgICAgICAgICAg
4pSCCj4gPj4+Pj4+Pgo+ID4+Pj4+Pj4gWWVhaCwgSSB0aGluayBDaHJpc3RpYW4gd2FudGVkIHRv
IGZpeCB0aGlzIGF0IHNvbWUgcG9pbnQsCj4gPj4+Pj4+Cj4gPj4+Pj4+IERvIHlvdSBoYXZlIGEg
cG9pbnRlciB0aGF0IGRpc2N1c3Npb24/IEkgY291bGQgbm90IGZpbmQgaXQgd2l0aCBhCj4gPj4+
Pj4+IHF1aWNrIHNlYXJjaC4KPiA+Pj4+Pj4KPiA+Pj4+Pj4+IGJ1dCBpdCdzIGEKPiA+Pj4+Pj4+
IGJpdCBzdGlja3kgdG8gZG8uCj4gPj4+Pj4+Cj4gPj4+Pj4+IENhbiB5b3Ugc2F5IGEgZmV3IHdv
cmRzIGFib3V0IHRoZSBuYXR1cmUgb2YgdGhlIHByb2JsZW0/Cj4gPj4+Pj4KPiA+Pj4+PiBJIHJl
bWVtYmVyZWQgd3JvbmcsIGl0J3MgYWN0dWFsbHkgaW4gdGhlIHRyZWU6IDk5Y2RiOGI5YTU3MyAo
InNlY2NvbXA6Cj4gPj4+Pj4gbm90aWZ5IGFib3V0IHVudXNlZCBmaWx0ZXIiKS4gU28gbWF5YmUg
dGhlcmUncyBhIGJ1ZyBoZXJlPwo+ID4+Pj4KPiA+Pj4+IFRoYXQgdGhpbmcgb25seSBub3RpZmll
cyBvbiAtPnBvbGwsIGl0IGRvZXNuJ3QgdW5ibG9jayBpb2N0bHM7IGFuZAo+ID4+Pj4gTWljaGFl
bCdzIHNhbXBsZSBjb2RlIHVzZXMgU0VDQ09NUF9JT0NUTF9OT1RJRl9SRUNWIHRvIHdhaXQuIFNv
IHRoYXQKPiA+Pj4+IGNvbW1pdCBkb2Vzbid0IGhhdmUgYW55IGVmZmVjdCBvbiB0aGlzIGtpbmQg
b2YgdXNhZ2UuCj4gPj4+Cj4gPj4+IFllcywgdGhhbmtzLiBBbmQgdGhlIG9uZXMgc3R1Y2sgaW4g
UkVDViBhcmUgd2FpdGluZyBvbiBhIHNlbWFwaG9yZSBzbwo+ID4+PiB3ZSBkb24ndCBoYXZlIGEg
Y291bnQgb2YgYWxsIG9mIHRoZW0sIHVuZm9ydHVuYXRlbHkuCj4gPj4+Cj4gPj4+IFdlIGNvdWxk
IG1heWJlIGxvb2sgaW5zaWRlIHRoZSB3YWl0X2xpc3QsIGJ1dCB0aGF0IHdpbGwgcHJvYmFibHkg
bWFrZQo+ID4+PiBwZW9wbGUgYW5ncnkgOikKPiA+Pgo+ID4+IFRoZSBlYXNpZXN0IHdheSB3b3Vs
ZCBwcm9iYWJseSBiZSB0byBvcGVuLWNvZGUgdGhlIHNlbWFwaG9yZS1pc2ggcGFydCwKPiA+PiBh
bmQgbGV0IHRoZSBzZW1hcGhvcmUgYW5kIHBvbGwgc2hhcmUgdGhlIHdhaXRxdWV1ZS4gVGhlIGN1
cnJlbnQgY29kZQo+ID4+IGtpbmQgb2YgbWlycm9ycyB0aGUgc2VtYXBob3JlJ3Mgd2FpdHF1ZXVl
IGluIHRoZSB3cWggLSBvcGVuLWNvZGluZyB0aGUKPiA+PiBlbnRpcmUgc2VtYXBob3JlIHdvdWxk
IElNTyBiZSBjbGVhbmVyIHRoYW4gdGhhdC4gQW5kIGl0J3Mgbm90IGxpa2UKPiA+PiBzZW1hcGhv
cmUgc2VtYW50aWNzIGFyZSBldmVuIGEgZ29vZCBmaXQgZm9yIHRoaXMgY29kZSBhbnl3YXkuCj4g
Pj4KPiA+PiBMZXQncyBzZWUuLi4gaWYgd2UgZGlkbid0IGhhdmUgdGhlIGV4aXN0aW5nIFVBUEkg
dG8gd29ycnkgYWJvdXQsIEknZAo+ID4+IGRvIGl0IGFzIGZvbGxvd3MgKCpjb21wbGV0ZWx5KiB1
bnRlc3RlZCkuIFRoYXQgd2F5LCB0aGUgaW9jdGwgd291bGQKPiA+PiBibG9jayBleGFjdGx5IHVu
dGlsIGVpdGhlciB0aGVyZSBhY3R1YWxseSBpcyBhIHJlcXVlc3QgdG8gZGVsaXZlciBvcgo+ID4+
IHRoZXJlIGFyZSBubyBtb3JlIHVzZXJzIG9mIHRoZSBmaWx0ZXIuIFRoZSBwcm9ibGVtIGlzIHRo
YXQgaWYgd2UganVzdAo+ID4+IGFwcGx5IHRoaXMgcGF0Y2gsIGV4aXN0aW5nIHVzZXJzIG9mIFNF
Q0NPTVBfSU9DVExfTk9USUZfUkVDViB0aGF0IHVzZQo+ID4+IGFuIGV2ZW50IGxvb3AgYW5kIGRv
bid0IHNldCBPX05PTkJMT0NLIHdpbGwgYmUgc2NyZXdlZC4gU28gd2UnZAo+ID4+IHByb2JhYmx5
IGFsc28gaGF2ZSB0byBhZGQgc29tZSBzdHVwaWQgY291bnRlciBpbiBwbGFjZSBvZiB0aGUKPiA+
PiBzZW1hcGhvcmUncyBjb3VudGVyIHRoYXQgd2UgY2FuIHVzZSB0byBwcmVzZXJ2ZSB0aGUgb2xk
IGJlaGF2aW9yIG9mCj4gPj4gcmV0dXJuaW5nIC1FTk9FTlQgb25jZSBmb3IgZWFjaCBjYW5jZWxs
ZWQgcmVxdWVzdC4gOigKPiA+Pgo+ID4+IEkgZ3Vlc3MgdGhpcyBpcyBhIG5pY2UgcG9pbnQgaW4g
ZmF2b3Igb2YgTWljaGFlbCdzIHVzdWFsIGNvbXBsYWludAo+ID4+IHRoYXQgaWYgdGhlcmUgYXJl
IG5vIG1hbiBwYWdlcyBmb3IgYSBmZWF0dXJlIGJ5IHRoZSB0aW1lIHRoZSBmZWF0dXJlCj4gPj4g
bGFuZHMgdXBzdHJlYW0sIHRoZXJlJ3MgYSBoaWdoZXIgY2hhbmNlIHRoYXQgdGhlIFVBUEkgd2ls
bCBzdWNrCj4gPj4gZm9yZXZlci4uLgo+ID4KPiA+IEFuZCBJIGd1ZXNzIHRoaXMgd291bGQgYmUg
dGhlIFVBUEktY29tcGF0aWJsZSB2ZXJzaW9uIC0gbm90IGFjdHVhbGx5Cj4gPiBhcyB0ZXJyaWJs
ZSBhcyBJIHRob3VnaHQgaXQgbWlnaHQgYmUuIERvIHknYWxsIHdhbnQgdGhpcz8gSWYgc28sIGZl
ZWwKPiA+IGZyZWUgdG8gZWl0aGVyIHR1cm4gdGhpcyBpbnRvIGEgcHJvcGVyIHBhdGNoIHdpdGgg
Q28tZGV2ZWxvcGVkLWJ5LCBvcgo+ID4gdGVsbCBtZSB0aGF0IEkgc2hvdWxkIGRvIGl0IGFuZCBJ
J2xsIHRyeSB0byBnZXQgYXJvdW5kIHRvIHR1cm5pbmcgaXQKPiA+IGludG8gc29tZXRoaW5nIHBy
b3Blci4KPgo+IFRoYW5rcyBmb3IgdGFraW5nIGEgc2hvdCBhdCB0aGlzLgo+Cj4gSSB0cmllZCBh
cHBseWluZyB0aGUgcGF0Y2ggYmVsb3cgdG8gdmFuaWxsYSA1LjkuMC4KPiAoVGhlcmUncyBvbmUg
dHlwbzogcy9FTk9UQ09OL0VOT1RDT05OKS4KPgo+IEl0IHNlZW1zIG5vdCB0byB3b3JrIHRob3Vn
aDsgd2hlbiBJIHNlbmQgYSBzaWduYWwgdG8gbXkgdGVzdAo+IHRhcmdldCBwcm9jZXNzIHRoYXQg
aXMgc2xlZXBpbmcgd2FpdGluZyBmb3IgdGhlIG5vdGlmaWNhdGlvbgo+IHJlc3BvbnNlLCB0aGUg
cHJvY2VzcyBlbnRlcnMgdGhlIHVuaW50ZXJydXB0aWJsZSBEIHN0YXRlLgo+IEFueSB0aG91Z2h0
cz8KCkFoLCB5ZWFoLCBJIHRoaW5rIEkgd2FzIGNvbXBsZXRlbHkgbWlzdXNpbmcgdGhlIHdhaXQg
QVBJLiBJJ2xsIGdvIGNoYW5nZSB0aGF0LgoKKEJ0dywgaW4gZ2VuZXJhbCwgZm9yIHJlcG9ydHMg
YWJvdXQgaGFuZ3MgbGlrZSB0aGF0LCBpdCBjYW4gYmUgaGVscGZ1bAp0byBoYXZlIHRoZSBjb250
ZW50cyBvZiAvcHJvYy8kcGlkL3N0YWNrLiBBbmQgZm9yIGNhc2VzIHdoZXJlIENQVXMgYXJlCnNw
aW5uaW5nLCB0aGUgcmVsZXZhbnQgcGFydCBmcm9tIHRoZSBvdXRwdXQgb2YgdGhlICJMIiBzeXNy
cSwgb3IKc29tZXRoaW5nIGxpa2UgdGhhdC4pCgpBbHNvLCBJIGd1ZXNzIHdlIGNhbiBwcm9iYWJs
eSBicmVhayB0aGlzIHBhcnQgb2YgVUFQSSBhZnRlciBhbGwsIHNpbmNlCnRoZSBvbmx5IHVzZXIg
b2YgdGhpcyBpbnRlcmZhY2Ugc2VlbXMgdG8gY3VycmVudGx5IGJlIGNvbXBsZXRlbHkKYnJva2Vu
IGluIHRoaXMgY2FzZSBhbnl3YXk/IFNvIEkgdGhpbmsgd2Ugd2FudCB0aGUgb3RoZXIKaW1wbGVt
ZW50YXRpb24gd2l0aG91dCB0aGUgLT5jYW5jZWxlZF9yZXFzIGxvZ2ljIGFmdGVyIGFsbC4KCkkn
bSBhIGJpdCBvbiB0aGUgZmVuY2Ugbm93IG9uIHdoZXRoZXIgbm9uLWJsb2NraW5nIG1vZGUgc2hv
dWxkIHVzZQpFTk9UQ09OTiBvciBub3QuLi4gSSBndWVzcyBpZiB3ZSByZXR1cm5lZCBFTk9FTlQg
ZXZlbiB3aGVuIHRoZXJlIGFyZQpubyBtb3JlIGxpc3RlbmVycywgeW91J2QgaGF2ZSB0byBkaXNh
bWJpZ3VhdGUgdGhyb3VnaCB0aGUgcG9sbCgpCnJldmVudHMsIHdoaWNoIHdvdWxkIGJlIGtpbmRh
IHVnbHk/CgpJJ2xsIHRyeSB0byB0dXJuIHRoaXMgaW50byBhIHByb3BlciBwYXRjaCBzdWJtaXNz
aW9uLi4uCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCkNv
bnRhaW5lcnMgbWFpbGluZyBsaXN0CkNvbnRhaW5lcnNAbGlzdHMubGludXgtZm91bmRhdGlvbi5v
cmcKaHR0cHM6Ly9saXN0cy5saW51eGZvdW5kYXRpb24ub3JnL21haWxtYW4vbGlzdGluZm8vY29u
dGFpbmVycw==
