Return-Path: <SRS0=5CWv=DV=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.8 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,NICE_REPLY_A,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 253B4C433E7
	for <containers@archiver.kernel.org>; Wed, 14 Oct 2020 04:40:45 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 867F3221FE
	for <containers@archiver.kernel.org>; Wed, 14 Oct 2020 04:40:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cmNE/jD7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 867F3221FE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 3024187BFF;
	Wed, 14 Oct 2020 04:40:44 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 1XRwvD4hzrZF; Wed, 14 Oct 2020 04:40:43 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 977B187B89;
	Wed, 14 Oct 2020 04:40:43 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 7E0D9C07FF;
	Wed, 14 Oct 2020 04:40:43 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id B772AC0051
 for <containers@lists.linux-foundation.org>;
 Wed, 14 Oct 2020 04:40:42 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id A546F87F33
 for <containers@lists.linux-foundation.org>;
 Wed, 14 Oct 2020 04:40:42 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id oIEaq7t89Ev8
 for <containers@lists.linux-foundation.org>;
 Wed, 14 Oct 2020 04:40:41 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-wm1-f65.google.com (mail-wm1-f65.google.com
 [209.85.128.65])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 218D487D6A
 for <containers@lists.linux-foundation.org>;
 Wed, 14 Oct 2020 04:40:41 +0000 (UTC)
Received: by mail-wm1-f65.google.com with SMTP id l15so829000wmh.1
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 21:40:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=cc:subject:to:references:from:message-id:date:user-agent
 :mime-version:in-reply-to:content-language:content-transfer-encoding;
 bh=ePLsU1bdkJB4g+ijegYS+YZS8jNr19HgFUEeDCk3fzc=;
 b=cmNE/jD7DOye2TOzxQuV4PDYobqxn1oClxVW2ooNBNH2m4IqaSydPrSSYaE08ZKg41
 1rujSTUhVqvG9wyzOSipSeQ6fQhUHQQKqrDL2dcS+J7IJK/oAQoLJQd/DyoCjexRR49U
 JeZRo9oOXjltwQyIKzcahz97cpAv76Mw8/oLI0U/ebF/xhz3gRfZ3bQ6dXG/pMRGIJhU
 5PT3+NherQaYcx+xZRW197NNzDvaU1Fp8CbthviPh+GQxkRCxJVUZQJkq7i+21PMcOTP
 1CreIEO8fb5v7sbUuxk8c5b4OnWyPzlKQeTAAr/Bso9hBBvGE1Hj5gKQH8BsACVBzFDe
 sHbw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:cc:subject:to:references:from:message-id:date
 :user-agent:mime-version:in-reply-to:content-language
 :content-transfer-encoding;
 bh=ePLsU1bdkJB4g+ijegYS+YZS8jNr19HgFUEeDCk3fzc=;
 b=YoixDquPe9AIzSNVCnec7YSVxkI9xqH1RAFxV2l8I+Q+qDdi29Kj1nCs28Tjiic29w
 NnmghC7EHt9i01hr5a5hQFvdDqEeWExHkaBuGArGee22gbZ8qjamZXaV3mrFeaCAEf4q
 pk1742+jJRlG1+76W6Wj84l3ozBoWAhDvXAJbdTHt3pQnQiv2Lvty2tZSrMkhO34lyq5
 aZux13uUscwjFuXTFo3/SU8UrB6yPsRis5ih7UmmF0QrFxya0zxaC+gGoSKOrlvq+Z/M
 A4puKqLBCpHCfAK9DSZwVR2u3cOwowGmbuPn3Mzvp24X5Gp6pZZSjUg1Wxea6rprImtS
 b3VQ==
X-Gm-Message-State: AOAM531bbOFZTC3wC7KF7Aina/MrVQ5niIYaIS2cZKfYYXnGSslS4laJ
 hE259ppaXHCtbIsVAkdR/cQ=
X-Google-Smtp-Source: ABdhPJy4ORXNMf8bxAsICCzIRlJSAI1SsU+l/svl536z0jTzmcGeSYTrB8eiui5z2m7KNYGayMb+WQ==
X-Received: by 2002:a05:600c:210f:: with SMTP id
 u15mr1494200wml.53.1602650439436; 
 Tue, 13 Oct 2020 21:40:39 -0700 (PDT)
Received: from [192.168.1.10] (static-176-175-73-29.ftth.abo.bbox.fr.
 [176.175.73.29])
 by smtp.gmail.com with ESMTPSA id o6sm2726672wrm.69.2020.10.13.21.40.37
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Tue, 13 Oct 2020 21:40:38 -0700 (PDT)
Subject: Re: For review: seccomp_user_notif(2) manual page
To: Tycho Andersen <tycho@tycho.pizza>
References: <45f07f17-18b6-d187-0914-6f341fe90857@gmail.com>
 <20200930150330.GC284424@cisco>
 <8bcd956f-58d2-d2f0-ca7c-0a30f3fcd5b8@gmail.com>
 <20200930230327.GA1260245@cisco>
 <8f20d586-9609-ef83-c85a-272e37e684d8@gmail.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <7a4497ad-e595-f328-e0e1-9577dfdbd895@gmail.com>
Date: Wed, 14 Oct 2020 06:40:35 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.11.0
MIME-Version: 1.0
In-Reply-To: <8f20d586-9609-ef83-c85a-272e37e684d8@gmail.com>
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

SGkgVHljaG8sCgpQaW5nIG9uIHRoZSBxdWVzdGlvbiBiZWxvdyEKClRoYW5rcywKCk1pY2hhZWwK
Ck9uIDEwLzEvMjAgOTo0NSBBTSwgTWljaGFlbCBLZXJyaXNrIChtYW4tcGFnZXMpIHdyb3RlOgo+
IE9uIDEwLzEvMjAgMTowMyBBTSwgVHljaG8gQW5kZXJzZW4gd3JvdGU6Cj4+IE9uIFdlZCwgU2Vw
IDMwLCAyMDIwIGF0IDEwOjM0OjUxUE0gKzAyMDAsIE1pY2hhZWwgS2VycmlzayAobWFuLXBhZ2Vz
KSB3cm90ZToKPj4+IEhpIFR5Y2hvLAo+Pj4KPj4+IFRoYW5rcyBmb3IgdGFraW5nIHRpbWUgdG8g
bG9vayBhdCB0aGUgcGFnZSEKPj4+Cj4+PiBPbiA5LzMwLzIwIDU6MDMgUE0sIFR5Y2hvIEFuZGVy
c2VuIHdyb3RlOgo+Pj4+IE9uIFdlZCwgU2VwIDMwLCAyMDIwIGF0IDAxOjA3OjM4UE0gKzAyMDAs
IE1pY2hhZWwgS2VycmlzayAobWFuLXBhZ2VzKSB3cm90ZToKPiAKPiBbLi4uXQo+IAo+Pj4+PiAg
ICAgICAg4pSM4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA
4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA
4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSQ
Cj4+Pj4+ICAgICAgICDilIJGSVhNRSAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgIOKUggo+Pj4+PiAgICAgICAg4pSc4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA
4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA
4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA
4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSkCj4+Pj4+ICAgICAgICDilIJJbnRlcmVzdGluZ2x5LCBh
ZnRlciB0aGUgZXZlbnQgIGhhZCAgYmVlbiAgcmVjZWl2ZWQsIOKUggo+Pj4+PiAgICAgICAg4pSC
dGhlICBmaWxlIGRlc2NyaXB0b3IgaW5kaWNhdGVzIGFzIHdyaXRhYmxlICh2ZXJpZmllZCDilIIK
Pj4+Pj4gICAgICAgIOKUgmZyb20gdGhlIHNvdXJjZSBjb2RlIGFuZCBieSBleHBlcmltZW50KS4g
SG93IGlzIHRoaXMg4pSCCj4+Pj4+ICAgICAgICDilIJ1c2VmdWw/ICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgIOKUggo+Pj4+Cj4+Pj4gWW91J3JlIHNheWluZyBp
dCBzaG91bGQganVzdCBkbyBFUE9MTE9VVCBhbmQgbm90IEVQT0xMV1JOT1JNPyBTZWVtcwo+Pj4+
IHJlYXNvbmFibGUuCj4+Pgo+Pj4gTm8sIEknbSBzYXlpbmcgc29tZXRoaW5nIG1vcmUgZnVuZGFt
ZW50YWw6IHdoeSBpcyB0aGUgRkQgaW5kaWNhdGluZyBhcwo+Pj4gd3JpdGFibGU/IENhbiB5b3Ug
d3JpdGUgc29tZXRoaW5nIHRvIGl0PyBJZiB5ZXMsIHdoYXQ/IElmIG5vdCwgdGhlbgo+Pj4gd2h5
IGRvIHRoZXNlIEFQSXMgd2FudCB0byBzYXkgdGhhdCB0aGUgRkQgaXMgd3JpdGFibGU/Cj4+Cj4+
IFlvdSBjYW4ndCB2aWEgcmVhZCgyKSBvciB3cml0ZSgyKSwgYnV0IGNvbmNlcHR1YWxseSBOT1RJ
RllfUkVDViBhbmQKPj4gTk9USUZZX1NFTkQgYXJlIHJlYWRpbmcgYW5kIHdyaXRpbmcgZXZlbnRz
IGZyb20gdGhlIGZkLiBJIGRvbid0IGtub3cKPj4gdGhhdCBtdWNoIGFib3V0IHRoZSBwb2xsIGlu
dGVyZmFjZSB0aG91Z2ggLS0gaXMgaXQgcG9zc2libGUgdG8KPj4gaW5kaWNhdGUgImhlcmUncyBh
IHBzZXVkby1yZWFkIGV2ZW50Ij8gSXQgZGlkbid0IGxvb2sgbGlrZSBpdCwgc28gSQo+PiBqdXN0
IChhYi0pdXNlZCBQT0xMSU4gYW5kIFBPTExPVVQsIGJ1dCBwcm9iYWJseSB0aGF0J3Mgd3Jvbmcu
Cj4gCj4gSSB0aGluayB0aGUgUE9MTElOIHRoaW5nIGlzIGZpbmUuCj4gCj4gU28sIEkgdGhpbmsg
bWF5YmUgSSBub3cgdW5kZXJzdGFuZCB3aGF0IHlvdSBpbnRlbmRlZCB3aXRoIHNldHRpbmcKPiBQ
T0xMT1VUOiB0aGUgbm90aWZpY2F0aW9uIGhhcyBiZWVuIHJlY2VpdmVkICgicmVhZCIpIGFuZCBu
b3cgdGhlCj4gRkQgY2FuIGJlIHVzZWQgdG8gTk9USUZZX1NFTkQgKCJ3cml0ZSIpIGEgcmVzcG9u
c2UuIFJpZ2h0Pwo+IAo+IElmIHRoYXQncyBjb3JyZWN0LCBJIGRvbid0IGhhdmUgYSBwcm9ibGVt
IHdpdGggaXQuIEkganVzdCB3b25kZXI6Cj4gaXMgaXQgdXNlZnVsPyBJT1c6IGFyZSB0aGVyZSBz
aXR1YXRpb25zIHdoZXJlIHRoZSBwcm9jZXNzIGRvaW5nIHRoZQo+IE5PVElGWV9TRU5EIG1pZ2h0
IHdhbnQgdG8gdGVzdCBmb3IgUE9MTE9VVCBiZWNhdXNlIHRoZSBpdCBkb2Vzbid0Cj4ga25vdyB3
aGV0aGVyIGEgTk9USUZZX1JFQ1YgaGFzIG9jY3VycmVkPyAKPiAKPiBUaGFua3MsCj4gCj4gTWlj
aGFlbAo+IAoKCi0tIApNaWNoYWVsIEtlcnJpc2sKTGludXggbWFuLXBhZ2VzIG1haW50YWluZXI7
IGh0dHA6Ly93d3cua2VybmVsLm9yZy9kb2MvbWFuLXBhZ2VzLwpMaW51eC9VTklYIFN5c3RlbSBQ
cm9ncmFtbWluZyBUcmFpbmluZzogaHR0cDovL21hbjcub3JnL3RyYWluaW5nLwpfX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpDb250YWluZXJzIG1haWxpbmcg
bGlzdApDb250YWluZXJzQGxpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnCmh0dHBzOi8vbGlzdHMu
bGludXhmb3VuZGF0aW9uLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2NvbnRhaW5lcnM=
