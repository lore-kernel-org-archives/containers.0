Return-Path: <SRS0=WbUC=DI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,NICE_REPLY_A,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1CD0C4727E
	for <containers@archiver.kernel.org>; Thu,  1 Oct 2020 07:45:28 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 22AA1207F7
	for <containers@archiver.kernel.org>; Thu,  1 Oct 2020 07:45:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="d/vQ+VVk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 22AA1207F7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 867F3869F2;
	Thu,  1 Oct 2020 07:45:27 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id wokrowuZBe4U; Thu,  1 Oct 2020 07:45:26 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id B811B869EF;
	Thu,  1 Oct 2020 07:45:26 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 9D3A6C0889;
	Thu,  1 Oct 2020 07:45:26 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 5DDFAC0051
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 07:45:25 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 4C167872E0
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 07:45:25 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id NpOq6byZWxb1
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 07:45:24 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-wr1-f66.google.com (mail-wr1-f66.google.com
 [209.85.221.66])
 by hemlock.osuosl.org (Postfix) with ESMTPS id E0611872DF
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 07:45:23 +0000 (UTC)
Received: by mail-wr1-f66.google.com with SMTP id k15so4445520wrn.10
 for <containers@lists.linux-foundation.org>;
 Thu, 01 Oct 2020 00:45:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=cc:subject:to:references:from:message-id:date:user-agent
 :mime-version:in-reply-to:content-language:content-transfer-encoding;
 bh=xF7e0E8Lw4CA2Uq+qVpBw+cIQFKMIBUjuND9PoUrs5Y=;
 b=d/vQ+VVk+keNzkTfJSJxtcXpSwp2e7QCaBNQZVU4obREwDbvYR4ZOkBAIn6nZtjLrb
 3dRvKN+GZdP1oQFFW/WEgNG9Ppq4gVVv6NzUKiTksJwcvN9PabgGRW31N0rtN+ZwizBZ
 Ir7qV4dK/89jGgUAjfx/Dt5qCN9CBfJEHDXQ3wXfHiKFfYxmdygBYHRXbft2M6MJDZht
 8MsO994BspQhR23fIhIiWfa0x2AEEtJL394LV/ThsCeCMiTFdFm/rX53wswTwkK2O5Xj
 iJx9UD43hnd5M2L/jQHIj83U3txiSLHzEMovktlDwd72Doib8y20ewhC18AZ/A7VLimt
 CJeg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:cc:subject:to:references:from:message-id:date
 :user-agent:mime-version:in-reply-to:content-language
 :content-transfer-encoding;
 bh=xF7e0E8Lw4CA2Uq+qVpBw+cIQFKMIBUjuND9PoUrs5Y=;
 b=rvO0oJ2i0mhS1mNP5CXgstrancFuBNkTw7Vb/ECZxVXQTh3e9IJjk+89r4ug+HIk3h
 6ECOE6r8aT30Cndo+chYkRuouFXTZQeGihVN3evz887LuBNmdMaseWfpmsVrKj6lrgVv
 XtYRy9g8ltnfIUo3FHenPZ1LqIGshxflhAC3CoPD8xI9Lmzd9IQoOfrKnmRYPZmkLD8M
 5TQIpb+UL9uXM4Rx5I8XtVyPgt4/3CXcPJpYciuI3mFRYoWVcxWnRLS9MvRULRIJ73M8
 FKjFrs+a5yTiBDWtKIj9vfQIH/6oqJNuEjTMB2wMlioY2kKpeySSlqj2GMOnw+okTXmU
 PPYg==
X-Gm-Message-State: AOAM531RonslA7EdyYWbNwLpD6GUEzPa0g/ezebMe+alCFnV6c+LOM6c
 d5dhbJ4eDpzQUuk8bYAv5QY=
X-Google-Smtp-Source: ABdhPJxwv6BtYFAqC+AMaDOZb3qgtjlHwEicyt0p82kSHbH75ncrgFUe0TsFiNV7de54QZazE4hATA==
X-Received: by 2002:adf:dd44:: with SMTP id u4mr6973042wrm.22.1601538322276;
 Thu, 01 Oct 2020 00:45:22 -0700 (PDT)
Received: from ?IPv6:2001:a61:2479:6801:d8fe:4132:9f23:7e8f?
 ([2001:a61:2479:6801:d8fe:4132:9f23:7e8f])
 by smtp.gmail.com with ESMTPSA id u66sm7145534wmg.44.2020.10.01.00.45.19
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Thu, 01 Oct 2020 00:45:21 -0700 (PDT)
Subject: Re: For review: seccomp_user_notif(2) manual page
To: Tycho Andersen <tycho@tycho.pizza>
References: <45f07f17-18b6-d187-0914-6f341fe90857@gmail.com>
 <20200930150330.GC284424@cisco>
 <8bcd956f-58d2-d2f0-ca7c-0a30f3fcd5b8@gmail.com>
 <20200930230327.GA1260245@cisco>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <8f20d586-9609-ef83-c85a-272e37e684d8@gmail.com>
Date: Thu, 1 Oct 2020 09:45:19 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.10.0
MIME-Version: 1.0
In-Reply-To: <20200930230327.GA1260245@cisco>
Content-Language: en-US
Cc: linux-man <linux-man@vger.kernel.org>, Song Liu <songliubraving@fb.com>,
 wad@chromium.org, Kees Cook <keescook@chromium.org>,
 Daniel Borkmann <daniel@iogearbox.net>, Jann Horn <jannh@google.com>,
 Robert Sesek <rsesek@google.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 lkml <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
 mtk.manpages@gmail.com, Giuseppe Scrivano <gscrivan@redhat.com>,
 bpf@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>,
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
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

T24gMTAvMS8yMCAxOjAzIEFNLCBUeWNobyBBbmRlcnNlbiB3cm90ZToKPiBPbiBXZWQsIFNlcCAz
MCwgMjAyMCBhdCAxMDozNDo1MVBNICswMjAwLCBNaWNoYWVsIEtlcnJpc2sgKG1hbi1wYWdlcykg
d3JvdGU6Cj4+IEhpIFR5Y2hvLAo+Pgo+PiBUaGFua3MgZm9yIHRha2luZyB0aW1lIHRvIGxvb2sg
YXQgdGhlIHBhZ2UhCj4+Cj4+IE9uIDkvMzAvMjAgNTowMyBQTSwgVHljaG8gQW5kZXJzZW4gd3Jv
dGU6Cj4+PiBPbiBXZWQsIFNlcCAzMCwgMjAyMCBhdCAwMTowNzozOFBNICswMjAwLCBNaWNoYWVs
IEtlcnJpc2sgKG1hbi1wYWdlcykgd3JvdGU6CgpbLi4uXQoKPj4+PiAgICAgICAg4pSM4pSA4pSA
4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA
4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA
4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSQCj4+Pj4gICAgICAgIOKU
gkZJWE1FICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg4pSC
Cj4+Pj4gICAgICAgIOKUnOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKU
gOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKU
gOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKU
gOKUgOKUpAo+Pj4+ICAgICAgICDilIJJbnRlcmVzdGluZ2x5LCBhZnRlciB0aGUgZXZlbnQgIGhh
ZCAgYmVlbiAgcmVjZWl2ZWQsIOKUggo+Pj4+ICAgICAgICDilIJ0aGUgIGZpbGUgZGVzY3JpcHRv
ciBpbmRpY2F0ZXMgYXMgd3JpdGFibGUgKHZlcmlmaWVkIOKUggo+Pj4+ICAgICAgICDilIJmcm9t
IHRoZSBzb3VyY2UgY29kZSBhbmQgYnkgZXhwZXJpbWVudCkuIEhvdyBpcyB0aGlzIOKUggo+Pj4+
ICAgICAgICDilIJ1c2VmdWw/ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgIOKUggo+Pj4KPj4+IFlvdSdyZSBzYXlpbmcgaXQgc2hvdWxkIGp1c3QgZG8gRVBPTExP
VVQgYW5kIG5vdCBFUE9MTFdSTk9STT8gU2VlbXMKPj4+IHJlYXNvbmFibGUuCj4+Cj4+IE5vLCBJ
J20gc2F5aW5nIHNvbWV0aGluZyBtb3JlIGZ1bmRhbWVudGFsOiB3aHkgaXMgdGhlIEZEIGluZGlj
YXRpbmcgYXMKPj4gd3JpdGFibGU/IENhbiB5b3Ugd3JpdGUgc29tZXRoaW5nIHRvIGl0PyBJZiB5
ZXMsIHdoYXQ/IElmIG5vdCwgdGhlbgo+PiB3aHkgZG8gdGhlc2UgQVBJcyB3YW50IHRvIHNheSB0
aGF0IHRoZSBGRCBpcyB3cml0YWJsZT8KPiAKPiBZb3UgY2FuJ3QgdmlhIHJlYWQoMikgb3Igd3Jp
dGUoMiksIGJ1dCBjb25jZXB0dWFsbHkgTk9USUZZX1JFQ1YgYW5kCj4gTk9USUZZX1NFTkQgYXJl
IHJlYWRpbmcgYW5kIHdyaXRpbmcgZXZlbnRzIGZyb20gdGhlIGZkLiBJIGRvbid0IGtub3cKPiB0
aGF0IG11Y2ggYWJvdXQgdGhlIHBvbGwgaW50ZXJmYWNlIHRob3VnaCAtLSBpcyBpdCBwb3NzaWJs
ZSB0bwo+IGluZGljYXRlICJoZXJlJ3MgYSBwc2V1ZG8tcmVhZCBldmVudCI/IEl0IGRpZG4ndCBs
b29rIGxpa2UgaXQsIHNvIEkKPiBqdXN0IChhYi0pdXNlZCBQT0xMSU4gYW5kIFBPTExPVVQsIGJ1
dCBwcm9iYWJseSB0aGF0J3Mgd3JvbmcuCgpJIHRoaW5rIHRoZSBQT0xMSU4gdGhpbmcgaXMgZmlu
ZS4KClNvLCBJIHRoaW5rIG1heWJlIEkgbm93IHVuZGVyc3RhbmQgd2hhdCB5b3UgaW50ZW5kZWQg
d2l0aCBzZXR0aW5nClBPTExPVVQ6IHRoZSBub3RpZmljYXRpb24gaGFzIGJlZW4gcmVjZWl2ZWQg
KCJyZWFkIikgYW5kIG5vdyB0aGUKRkQgY2FuIGJlIHVzZWQgdG8gTk9USUZZX1NFTkQgKCJ3cml0
ZSIpIGEgcmVzcG9uc2UuIFJpZ2h0PwoKSWYgdGhhdCdzIGNvcnJlY3QsIEkgZG9uJ3QgaGF2ZSBh
IHByb2JsZW0gd2l0aCBpdC4gSSBqdXN0IHdvbmRlcjoKaXMgaXQgdXNlZnVsPyBJT1c6IGFyZSB0
aGVyZSBzaXR1YXRpb25zIHdoZXJlIHRoZSBwcm9jZXNzIGRvaW5nIHRoZQpOT1RJRllfU0VORCBt
aWdodCB3YW50IHRvIHRlc3QgZm9yIFBPTExPVVQgYmVjYXVzZSB0aGUgaXQgZG9lc24ndAprbm93
IHdoZXRoZXIgYSBOT1RJRllfUkVDViBoYXMgb2NjdXJyZWQ/IAoKVGhhbmtzLAoKTWljaGFlbAoK
LS0gCk1pY2hhZWwgS2VycmlzawpMaW51eCBtYW4tcGFnZXMgbWFpbnRhaW5lcjsgaHR0cDovL3d3
dy5rZXJuZWwub3JnL2RvYy9tYW4tcGFnZXMvCkxpbnV4L1VOSVggU3lzdGVtIFByb2dyYW1taW5n
IFRyYWluaW5nOiBodHRwOi8vbWFuNy5vcmcvdHJhaW5pbmcvCl9fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fCkNvbnRhaW5lcnMgbWFpbGluZyBsaXN0CkNvbnRh
aW5lcnNAbGlzdHMubGludXgtZm91bmRhdGlvbi5vcmcKaHR0cHM6Ly9saXN0cy5saW51eGZvdW5k
YXRpb24ub3JnL21haWxtYW4vbGlzdGluZm8vY29udGFpbmVycw==
