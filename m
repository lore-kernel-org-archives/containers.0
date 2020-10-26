Return-Path: <SRS0=D+Sq=EB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4A26C4363A
	for <containers@archiver.kernel.org>; Mon, 26 Oct 2020 09:32:36 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 30E1A206E5
	for <containers@archiver.kernel.org>; Mon, 26 Oct 2020 09:32:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="bxArDnwn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 30E1A206E5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 7B72B8722C;
	Mon, 26 Oct 2020 09:32:35 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ToNHDOQi5r9C; Mon, 26 Oct 2020 09:32:34 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id B19CC871A6;
	Mon, 26 Oct 2020 09:32:34 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 991F1C088B;
	Mon, 26 Oct 2020 09:32:34 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 2CC88C0051
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 09:32:33 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 27A182E0E8
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 09:32:33 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id UKXOSazLQnGQ
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 09:32:32 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-lf1-f67.google.com (mail-lf1-f67.google.com
 [209.85.167.67])
 by silver.osuosl.org (Postfix) with ESMTPS id AD1EE2E0DF
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 09:32:31 +0000 (UTC)
Received: by mail-lf1-f67.google.com with SMTP id v6so10816990lfa.13
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 02:32:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc:content-transfer-encoding;
 bh=StRkGUih/x/ZPb5WlhQHkdi1r1gUGmh5+DpBU/QI0b8=;
 b=bxArDnwnKKVb47+2JvvYUq8R/IEKsf7ylVrQGNciSnSoYPwE7dnVtR5YwfMO5uBNZw
 fHEDR8Tr/1TRXyiJJq95vuLudMRzpJqxxDTnXOTuZKU6/Z3xjWXSTs4P9xyBhGIaB0Mj
 dEj7BC/L/+TXKWqGb0DXEmgMH0eBzD3NgBeP5L0Bz4eQGAdM3hCz+SHgxO9GytIKoU4w
 JiHeltxTxG2TscaaBmkbuFitP3camZYG1gpykQPwS9aCxt/gwIFltkyjA/3cOBDh9NN8
 32EcuS/qkGiTUBRiM6AmttqPELBPELkKaBF1xwD7TWGHSMVEVSqBV892aAqbMi/3zsVw
 Y4mQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc:content-transfer-encoding;
 bh=StRkGUih/x/ZPb5WlhQHkdi1r1gUGmh5+DpBU/QI0b8=;
 b=ixvxkwfe4Vb/jKZqzM0Z8Q4XFTEcQfEhIchxcjkX0JSZwGLU87yOMeazjzGwv04ooK
 YSuVQmpkHDU7BEiK2SbKN3HiKiWGKSvyLYoC2J8lSjzLuYMdin2MMq6wHpqGJB8YhNoO
 3/HCuGPdpXL9PHLK/AWqr7pkIsB4zLkY0ZexF08sJe0iVHMEfzCVcA84J1iBGH7Ol8d/
 6KlHZYLUHx0TMWa97sjbttwtVoc42/p4fQH3Abj5CkjiRtp+sbB5siVGdKAGNNi3fmGG
 UGvmR59utn2KtUjMaEONVUzlZ+GjhyM1vgqvbTazi0Z3kcOV4XOom9/XJXxXwpoNPNEO
 62Qw==
X-Gm-Message-State: AOAM530TYuoFjn+Z12IKAw8fXyj0HTuHVaFu0Ze7YtuGLVoM3FQZ1HMy
 thMufA1dS16n7+8w+JXlks+x/35st603jk01mAyZPg==
X-Google-Smtp-Source: ABdhPJzBH+MPjCV8ct7DvlWTvTVhdnKL880/VXAqc2B1yNSMODbYCXhKALP0wqXMPnA3SOp/W9yOCEL7k8bIsiJOPMI=
X-Received: by 2002:a05:6512:1182:: with SMTP id
 g2mr4425834lfr.198.1603704749529; 
 Mon, 26 Oct 2020 02:32:29 -0700 (PDT)
MIME-Version: 1.0
References: <45f07f17-18b6-d187-0914-6f341fe90857@gmail.com>
 <CAG48ez3aqLs_-xgU0bThOLqRiiDWGObxcg-X9iFe6D5RDnLVJg@mail.gmail.com>
 <5647b94a-4693-dad0-6e0d-ed178b495d65@gmail.com>
 <CAG48ez1PtJPQLrQ54P+uuuxbt6mri9wcP=1m1wgVuMWOSDMazg@mail.gmail.com>
 <0f41f776-9379-9ee6-df4b-e7538f69313e@gmail.com>
 <CAG48ez1e-xKoJ_1v0DGMZ62WQCG7o7AUw+89DYEVbDpHWrdweA@mail.gmail.com>
 <887d5a29-edaa-2761-1512-370c1f5c3a6f@gmail.com>
In-Reply-To: <887d5a29-edaa-2761-1512-370c1f5c3a6f@gmail.com>
Date: Mon, 26 Oct 2020 10:32:03 +0100
Message-ID: <CAG48ez2TcWb6SQ86XRJDdN-Ab_gO9-sXgpFnJODMXH60mCkBJQ@mail.gmail.com>
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

T24gU2F0LCBPY3QgMjQsIDIwMjAgYXQgMjo1MyBQTSBNaWNoYWVsIEtlcnJpc2sgKG1hbi1wYWdl
cykKPG10ay5tYW5wYWdlc0BnbWFpbC5jb20+IHdyb3RlOgo+IE9uIDEwLzE3LzIwIDI6MjUgQU0s
IEphbm4gSG9ybiB3cm90ZToKPiA+IE9uIEZyaSwgT2N0IDE2LCAyMDIwIGF0IDg6MjkgUE0gTWlj
aGFlbCBLZXJyaXNrIChtYW4tcGFnZXMpCj4gPiA8bXRrLm1hbnBhZ2VzQGdtYWlsLmNvbT4gd3Jv
dGU6ClsuLi5dCj4gPj4gSSdtIG5vdCBzdXJlIGlmIEkgc2hvdWxkIHdyaXRlIGFueXRoaW5nIGFi
b3V0IHRoaXMgc21hbGwgVUFQSQo+ID4+IGJyZWFrYWdlIGluIEJVR1MsIG9yIG5vdC4gWW91ciB0
aG91Z2h0cz8KPiA+Cj4gPiBUaGlua2luZyBhYm91dCBpdCBhIGJpdCBtb3JlOiBBbnkgY29kZSB0
aGF0IHJlbGllcyBvbiBwYXVzZSgpIG9yCj4gPiBlcG9sbF93YWl0KCkgbm90IHJlc3RhcnRpbmcg
aXMgYnVnZ3kgYW55d2F5LCByaWdodD8gQmVjYXVzZSBhIHNpZ25hbAo+ID4gY291bGQgYWxzbyBh
cnJpdmUgZGlyZWN0bHkgYmVmb3JlIGVudGVyaW5nIHRoZSBzeXNjYWxsLCB3aGlsZQo+ID4gdXNl
cnNwYWNlIGNvZGUgaXMgc3RpbGwgZXhlY3V0aW5nPyBTbyBvbmUgY291bGQgYXJndWUgdGhhdCB3
ZSdyZSBqdXN0Cj4gPiBlbmxhcmdpbmcgYSBwcmVleGlzdGluZyByYWNlLiAoVW5sZXNzIHRoZSBz
aWduYWwgaGFuZGxlciBjaGVja3MgdGhlCj4gPiBpbnRlcnJ1cHRlZCByZWdpc3RlciBzdGF0ZSB0
byBmaWd1cmUgb3V0IHdoZXRoZXIgd2UgYWxyZWFkeSBlbnRlcmVkCj4gPiBzeXNjYWxsIGhhbmRs
aW5nPykKPgo+IFllcywgdGhhdCBhbGwgbWFrZXMgc2Vuc2UuCj4KPiA+IElmIHVzZXJzcGFjZSBy
ZWxpZXMgb24gbm9uLXJlc3RhcnRpbmcgYmVoYXZpb3IsIGl0IHNob3VsZCBiZSB1c2luZwo+ID4g
c29tZXRoaW5nIGxpa2UgZXBvbGxfcHdhaXQoKS4gQW5kIHRoYXQgc3R1ZmYgb25seSB1bmJsb2Nr
cyBzaWduYWxzCj4gPiBhZnRlciB3ZSd2ZSBhbHJlYWR5IHBhc3QgdGhlIHNlY2NvbXAgY2hlY2tz
IG9uIGVudHJ5Lgo+Cj4gVGhhbmtzIGZvciBlbGFib3JhdGluZyB0aGF0IGRldGFpbCwgc2luY2Ug
YXMgc29vbiBhcyB5b3UgdGFsa2VkCj4gYWJvdXQgImVubGFyZ2luZyBhIHByZWV4aXN0aW5nIHJh
Y2UiIGFib3ZlLCBJIGltbWVkaWF0ZWx5IHdvbmRlcmVkCj4gc2lnc3VzcGVuZCgpLCBwc2VsZWN0
KCksIGV0Yy4KPgo+IChNaW5kIHlvdSwgSSBzdGlsbCB3b25kZXIgYWJvdXQgdGhlIGVmZmVjdCBv
biBzeXN0ZW0gY2FsbHMgdGhhdAo+IGFyZSBub3JtYWxseSBub25yZXN0YXJ0YWJsZSBiZWNhdXNl
IHRoZXkgaGF2ZSB0aW1lb3V0cy4gTXkKPiB1bmRlcnN0YW5kaW5nIGlzIHRoYXQgdGhlIGtlcm5l
bCBkb2Vzbid0IHJlc3RhcnQgdGhvc2Ugc3lzdGVtCj4gY2FsbHMgYmVjYXVzZSBpdCdzIGltcG9z
c2libGUgZm9yIHRoZSBrZXJuZWwgdG8gcmVzdGFydCB0aGUgY2FsbAo+IHdpdGggdGhlIHJpZ2h0
IHRpbWVvdXQgdmFsdWUuIEkgd29uZGVyIHdoYXQgaGFwcGVucyB3aGVuIHRob3NlCj4gc3lzdGVt
IGNhbGxzIGFyZSByZXN0YXJ0ZWQgaW4gdGhlIHNjZW5hcmlvIHdlJ3JlIGRpc2N1c3NpbmcuKQoK
QWgsIHRoYXQncyBhbiBpbnRlcmVzdGluZyBlZGdlIGNhc2UuLi4KCj4gQW55d2F5LCByZXR1cm5p
bmcgdG8geW91ciBwb2ludC4uLiBTbywgdG8gYmUgY2xlYXIgKGFuZCB0bwo+IHF1aWNrbHkgcmVt
aW5kIG15c2VsZiBpbiBjYXNlIEkgb25lIGRheSByZXJlYWQgdGhpcyB0aHJlYWQpLAo+IHRoZXJl
IGlzIG5vdCBhIHByb2JsZW0gd2l0aCBzaWdzdXNwZW5kKCksIHBzZWxlY3QoKSwgcHBvbGwoKSwK
PiBhbmQgZXBvbGxfcHdhaXQoKSBzaW5jZToKPgo+ICogQmVmb3JlIHRoZSBzeXNjYWxsLCBzaWdu
YWxzIGFyZSBibG9ja2VkIGluIHRoZSB0YXJnZXQuCj4gKiBJbnNpZGUgdGhlIHN5c2NhbGwsIHNp
Z25hbHMgYXJlIHN0aWxsIGJsb2NrZWQgYXQgdGhlIHRpbWUKPiAgIHRoZSBjaGVjayBpcyBtYWRl
IGZvciBzZWNjb21wIGZpbHRlcnMuCj4gKiBJZiBhIHNlY2NvbXAgdXNlci1zcGFjZSBub3RpZmlj
YXRpb24gIGV2ZW50IGtpY2tzLCB0aGUgdGFyZ2V0Cj4gICBpcyBwdXQgdG8gc2xlZXAgd2l0aCB0
aGUgc2lnbmFscyBzdGlsbCBibG9ja2VkLgo+ICogVGhlIHNpZ25hbCB3aWxsIG9ubHkgZ2V0IGRl
bGl2ZXJlZCBhZnRlciB0aGUgc3VwZXJ2aXNvciBlaXRoZXIKPiAgIHRyaWdnZXJzIGEgc3Bvb2Zl
ZCBzdWNjZXNzL2ZhaWx1cmUgcmV0dXJuIGluIHRoZSB0YXJnZXQgb3IgdGhlCj4gICBzdXBlcnZp
c29yIHNlbmRzIGEgQ09OVElOVUUgcmVzcG9uc2UgdG8gdGhlIGtlcm5lbCB0ZWxsaW5nIGl0Cj4g
ICB0byBleGVjdXRlIHRoZSB0YXJnZXQncyBzeXN0ZW0gY2FsbC4gRWl0aGVyIHdheSwgdGhlcmUg
d29uJ3QgYmUKPiAgIGFueSByZXN0YXJ0aW5nIG9mIHRoZSB0YXJnZXQncyBzeXN0ZW0gY2FsbCAo
YW5kIHRoZSBzdXBlcnZpc29yCj4gICB0aHVzIHdvbid0IHNlZSBtdWx0aXBsZSBub3RpZmljYXRp
b25zKS4KPgo+IChSaWdodD8pCgpZZWFoLgoKWy4uLl0KPiA+IFNvIHdlIHNob3VsZCBwcm9iYWJs
eSBkb2N1bWVudCB0aGUgcmVzdGFydGluZyBiZWhhdmlvciBhcyBzb21ldGhpbmcKPiA+IHRoZSBz
dXBlcnZpc29yIGhhcyB0byBkZWFsIHdpdGggaW4gdGhlIG1hbnBhZ2U7IGJ1dCBmb3IgdGhlCj4g
PiAibm9uLXJlc3RhcnRpbmcgc3lzY2FsbHMgY2FuIHJlc3RhcnQgZnJvbSB0aGUgdGFyZ2V0J3Mg
cGVyc3BlY3RpdmUiCj4gPiBhc3BlY3QsIGl0IG1pZ2h0IGJlIGVub3VnaCB0byBkb2N1bWVudCB0
aGlzIGFzIHF1aXJreSBiZWhhdmlvciB0aGF0Cj4gPiBjYW4ndCBhY3R1YWxseSBicmVhayBjb3Jy
ZWN0IGNvZGU/IChPciBub3QgZG9jdW1lbnQgaXQgYXQgYWxsLiBEdW5uby4pCj4KPiBTbywgSSd2
ZSBhZGRlZCB0aGUgZm9sbG93aW5nIHRvIHRoZSBwYWdlOgo+Cj4gICAgSW50ZXJhY3Rpb24gd2l0
aCBTQV9SRVNUQVJUIHNpZ25hbCBoYW5kbGVycwo+ICAgICAgICBDb25zaWRlciB0aGUgZm9sbG93
aW5nIHNjZW5hcmlvOgo+Cj4gICAgICAgIMK3IFRoZSB0YXJnZXQgcHJvY2VzcyBoYXMgdXNlZCBz
aWdhY3Rpb24oMikgIHRvICBpbnN0YWxsICBhICBzaWduYWwKPiAgICAgICAgICBoYW5kbGVyIHdp
dGggdGhlIFNBX1JFU1RBUlQgZmxhZy4KPgo+ICAgICAgICDCtyBUaGUgdGFyZ2V0IGhhcyBtYWRl
IGEgc3lzdGVtIGNhbGwgdGhhdCB0cmlnZ2VyZWQgYSBzZWNjb21wIHVzZXItCj4gICAgICAgICAg
c3BhY2Ugbm90aWZpY2F0aW9uIGFuZCB0aGUgdGFyZ2V0IGlzIGN1cnJlbnRseSBibG9ja2VkIHVu
dGlsIHRoZQo+ICAgICAgICAgIHN1cGVydmlzb3Igc2VuZHMgYSBub3RpZmljYXRpb24gcmVzcG9u
c2UuCj4KPiAgICAgICAgwrcgQSAgc2lnbmFsICBpcyAgZGVsaXZlcmVkIHRvIHRoZSB0YXJnZXQg
YW5kIHRoZSBzaWduYWwgaGFuZGxlciBpcwo+ICAgICAgICAgIGV4ZWN1dGVkLgo+Cj4gICAgICAg
IMK3IFdoZW4gIChpZikgIHRoZSAgc3VwZXJ2aXNvciAgYXR0ZW1wdHMgIHRvICBzZW5kICBhICBu
b3RpZmljYXRpb24KPiAgICAgICAgICByZXNwb25zZSwgIHRoZSBTRUNDT01QX0lPQ1RMX05PVElG
X1NFTkQgaW9jdGwoMikpIG9wZXJhdGlvbiB3aWxsCj4gICAgICAgICAgZmFpbCB3aXRoIHRoZSBF
Tk9FTlQgZXJyb3IuCj4KPiAgICAgICAgSW4gdGhpcyBzY2VuYXJpbywgdGhlIGtlcm5lbCAgd2ls
bCAgcmVzdGFydCAgdGhlICB0YXJnZXQncyAgc3lzdGVtCj4gICAgICAgIGNhbGwuICAgQ29uc2Vx
dWVudGx5LCAgdGhlICBzdXBlcnZpc29yICB3aWxsIHJlY2VpdmUgYW5vdGhlciB1c2VyLQo+ICAg
ICAgICBzcGFjZSBub3RpZmljYXRpb24uICBUaHVzLCBkZXBlbmRpbmcgb24gaG93IG1hbnkgdGlt
ZXMgdGhlIGJsb2NrZWQKPiAgICAgICAgc3lzdGVtIGNhbGwgaXMgaW50ZXJydXB0ZWQgYnkgYSBz
aWduYWwgaGFuZGxlciwgdGhlIHN1cGVydmlzb3IgbWF5Cj4gICAgICAgIHJlY2VpdmUgbXVsdGlw
bGUgbm90aWZpY2F0aW9ucyBmb3IgdGhlIHNhbWUgIHN5c3RlbSAgY2FsbCAgaW4gIHRoZQo+ICAg
ICAgICB0YXJnZXQuCj4KPiAgICAgICAgT25lICBvZGRpdHkgIGlzICB0aGF0ICBzeXN0ZW0gY2Fs
bCByZXN0YXJ0aW5nIGFzIGRlc2NyaWJlZCBpbiB0aGlzCj4gICAgICAgIHNjZW5hcmlvIHdpbGwg
b2NjdXIgZXZlbiBmb3IgdGhlIGJsb2NraW5nIHN5c3RlbSBjYWxscyAgbGlzdGVkICBpbgo+ICAg
ICAgICBzaWduYWwoNykgdGhhdCB3b3VsZCBuZXZlciBub3JtYWxseSBiZSByZXN0YXJ0ZWQgYnkg
dGhlIFNBX1JFU1RBUlQKPiAgICAgICAgZmxhZy4KPgo+IERvZXMgdGhhdCBzZWVtIG9rYXk/CgpT
b3VuZHMgZ29vZCB0byBtZS4KCj4gSW4gYWRkaXRpb24sIEkndmUgcXVldWVkIGEgY3Jvc3MtcmVm
ZXJlbmNlIGluIHNpZ25hbCg3KToKPgo+ICAgICAgICBJbiBjZXJ0YWluIGNpcmN1bXN0YW5jZXMs
IHRoZSBzZWNjb21wKDIpIHVzZXItc3BhY2Ugbm90aWZp4oCQCj4gICAgICAgIGNhdGlvbiAgZmVh
dHVyZSBjYW4gbGVhZCB0byByZXN0YXJ0aW5nIG9mIHN5c3RlbSBjYWxscyB0aGF0Cj4gICAgICAg
IHdvdWxkIG90aGVyd2lzZSAgbmV2ZXIgIGJlICByZXN0YXJ0ZWQgIGJ5ICBTQV9SRVNUQVJUOyAg
Zm9yCj4gICAgICAgIGRldGFpbHMsIHNlZSBzZWNjb21wX3VzZXJfbm90aWYoMikuCl9fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCkNvbnRhaW5lcnMgbWFpbGlu
ZyBsaXN0CkNvbnRhaW5lcnNAbGlzdHMubGludXgtZm91bmRhdGlvbi5vcmcKaHR0cHM6Ly9saXN0
cy5saW51eGZvdW5kYXRpb24ub3JnL21haWxtYW4vbGlzdGluZm8vY29udGFpbmVycw==
