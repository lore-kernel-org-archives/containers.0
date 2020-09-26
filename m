Return-Path: <SRS0=QcxQ=DD=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C90CFC4727C
	for <containers@archiver.kernel.org>; Sat, 26 Sep 2020 00:34:39 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A716920759
	for <containers@archiver.kernel.org>; Sat, 26 Sep 2020 00:34:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="0UCfcG1B"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A716920759
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 6432E86DB2;
	Sat, 26 Sep 2020 00:34:38 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id fa_mNTV12E80; Sat, 26 Sep 2020 00:34:37 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id BA29D86DAD;
	Sat, 26 Sep 2020 00:34:37 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 8F58AC0891;
	Sat, 26 Sep 2020 00:34:37 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 67A10C0859
 for <containers@lists.linux-foundation.org>;
 Sat, 26 Sep 2020 00:34:35 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 4FB742E18B
 for <containers@lists.linux-foundation.org>;
 Sat, 26 Sep 2020 00:34:35 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id tNwDbGM2-bDm
 for <containers@lists.linux-foundation.org>;
 Sat, 26 Sep 2020 00:34:33 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pf1-f193.google.com (mail-pf1-f193.google.com
 [209.85.210.193])
 by silver.osuosl.org (Postfix) with ESMTPS id AC7C02E184
 for <containers@lists.linux-foundation.org>;
 Sat, 26 Sep 2020 00:34:33 +0000 (UTC)
Received: by mail-pf1-f193.google.com with SMTP id f18so4816421pfa.10
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 17:34:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amacapital-net.20150623.gappssmtp.com; s=20150623;
 h=content-transfer-encoding:from:mime-version:subject:date:message-id
 :references:cc:in-reply-to:to;
 bh=LQhUSgVwoAzLw92Ygh+sbDkDg9VzTVlbdTb6qu/28UI=;
 b=0UCfcG1B3lmiWLRmVTEkHEUvtYL/+yhH6MaR4BWOvVAYPKMPznhtEUKI/JMwclvII0
 9ugielLLHq/9jC2MBpemsPqqbJ04Wlymmt1JLIvfwrsKOq0QR3OAKlahWJSDERU7+31q
 JuZ9/lnzx2HUSbV0cfM6jynGVVFsUOKZd+x0a9PyXqhvpJQHpAvqteHU50MiHkuhTuTW
 YpimImgQ1rDbVJ8Q1YqS2+R/5tuTyvJC4lKAIbQY5qB+v2UsPjZ/S1g/VyaRpd/gWf2o
 TwKgb9LFhMCnYONj4IYLFVgofXdBJggPp5ck/xABw8LJD/FLU11+fRzv1l0E3btCfsd4
 Q72w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:content-transfer-encoding:from:mime-version
 :subject:date:message-id:references:cc:in-reply-to:to;
 bh=LQhUSgVwoAzLw92Ygh+sbDkDg9VzTVlbdTb6qu/28UI=;
 b=a9JKcX34OxYi1cVwpCTN6Oa4DQ5omlopB5Hit2MK2LyGLeKjKtI5wPtt9muFBCvW+h
 b9gBAYWVEMbRP7bItvYOAGKnnYfqjgtMD2z57MTY8lChrH+GG3ziNBf1O5ZgSdxNfRqQ
 rXoqD6OgA4jjzbnwaSWe14Pxt0E9lpvYW1uz7umbw7L2nsY3sBl9iqDiOhchL7GFr49K
 ZhvFdyD1kvhsGyXQoEsZk0s3hVlxVEl6zqloKuMEpQ85iBYEkR1WggbhD5YNEdzNKw0y
 Sbxz+7zQYPSDvC167f4ETWWl5pCg4p1FuUtRQ2gAf8Deg7Kw6IpTT+svdKBfSZ4YwTBo
 ReDQ==
X-Gm-Message-State: AOAM533vUNaTmUBlKmHTkI0DTt7zlcUYeQ4IbOodjMBHpqcPDDpnOdN0
 XmUe6CHoO6uPJmEp5oTFbQKOcQ==
X-Google-Smtp-Source: ABdhPJz4QibazbedTmXsQcRaU2pyUx8+oz1N5Q2XhtYTgoF1usymw1iGqYSgVjNPq/RGgqqdBMYJXQ==
X-Received: by 2002:a63:4a43:: with SMTP id j3mr1190597pgl.42.1601080473158;
 Fri, 25 Sep 2020 17:34:33 -0700 (PDT)
Received: from localhost.localdomain ([2601:646:c200:1ef2:480b:55cd:6a45:1705])
 by smtp.gmail.com with ESMTPSA id a71sm3563540pfa.26.2020.09.25.17.34.32
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Fri, 25 Sep 2020 17:34:32 -0700 (PDT)
From: Andy Lutomirski <luto@amacapital.net>
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH v2 seccomp 3/6] seccomp/cache: Add "emulator" to check if
 filter is arg-dependent
Date: Fri, 25 Sep 2020 17:34:29 -0700
Message-Id: <677FA6F9-D577-4594-9FDC-D70B0D6900C6@amacapital.net>
References: <202009251648.4AA27D5B@keescook>
In-Reply-To: <202009251648.4AA27D5B@keescook>
To: Kees Cook <keescook@chromium.org>
X-Mailer: iPhone Mail (18A373)
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

Cgo+IE9uIFNlcCAyNSwgMjAyMCwgYXQgNDo0OSBQTSwgS2VlcyBDb29rIDxrZWVzY29va0BjaHJv
bWl1bS5vcmc+IHdyb3RlOgo+IAo+IO+7v09uIEZyaSwgU2VwIDI1LCAyMDIwIGF0IDAyOjA3OjQ2
UE0gLTA3MDAsIEFuZHkgTHV0b21pcnNraSB3cm90ZToKPj4+IE9uIEZyaSwgU2VwIDI1LCAyMDIw
IGF0IDE6MzcgUE0gS2VlcyBDb29rIDxrZWVzY29va0BjaHJvbWl1bS5vcmc+IHdyb3RlOgo+Pj4g
Cj4+PiBPbiBGcmksIFNlcCAyNSwgMjAyMCBhdCAxMjo1MToyMFBNIC0wNzAwLCBBbmR5IEx1dG9t
aXJza2kgd3JvdGU6Cj4+Pj4gCj4+Pj4gCj4+Pj4+IE9uIFNlcCAyNSwgMjAyMCwgYXQgMTI6NDIg
UE0sIEtlZXMgQ29vayA8a2Vlc2Nvb2tAY2hyb21pdW0ub3JnPiB3cm90ZToKPj4+Pj4gCj4+Pj4+
IO+7v09uIEZyaSwgU2VwIDI1LCAyMDIwIGF0IDExOjQ1OjA1QU0gLTA1MDAsIFlpRmVpIFpodSB3
cm90ZToKPj4+Pj4+IE9uIFRodSwgU2VwIDI0LCAyMDIwIGF0IDEwOjA0IFBNIFlpRmVpIFpodSA8
emh1eWlmZWkxOTk5QGdtYWlsLmNvbT4gd3JvdGU6Cj4+Pj4+Pj4+IFdoeSBkbyB0aGUgcHJlcGFy
ZSBoZXJlIGluc3RlYWQgb2YgZHVyaW5nIGF0dGFjaD8gKEFuZCBub3RlIHRoYXQgaXQKPj4+Pj4+
Pj4gc2hvdWxkIG5vdCBiZSB3cml0dGVuIHRvIGZhaWwuKQo+Pj4+Pj4+IAo+Pj4+Pj4+IFJpZ2h0
Lgo+Pj4+Pj4gCj4+Pj4+PiBEdXJpbmcgYXR0YWNoIGEgc3BpbmxvY2sgKGN1cnJlbnQtPnNpZ2hh
bmQtPnNpZ2xvY2spIGlzIGhlbGQuIERvIHdlCj4+Pj4+PiByZWFsbHkgd2FudCB0byBwdXQgdGhl
IGVtdWxhdG9yIGluIHRoZSAiYXRvbWljIHNlY3Rpb24iPwo+Pj4+PiAKPj4+Pj4gSXQncyBhIGdv
b2QgcG9pbnQsIGJ1dCBJIGhhZCBzb21lIG90aGVyIGlkZWFzIGFyb3VuZCBpdCB0aGF0IGxlYWQg
dG8gbWUKPj4+Pj4gYSBkaWZmZXJlbnQgY29uY2x1c2lvbi4gSGVyZSdzIHdoYXQgSSd2ZSBnb3Qg
aW4gbXkgaGVhZDoKPj4+Pj4gCj4+Pj4+IEkgZG9uJ3QgdmlldyBmaWx0ZXIgYXR0YWNoIChub3Ig
dGhlIHNpZ2xvY2spIGFzIGZhc3RwYXRoOiB0aGUgbG9jayBpcwo+Pj4+PiByYXJlbHkgY29udGVz
dGVkIGFuZCB0aGUgImxvbmcgdGltZSIgd2lsbCBvbmx5IGJlIGR1cmluZyBmaWx0ZXIgYXR0YWNo
Lgo+Pj4+PiAKPj4+Pj4gV2hlbiBwZXJmb3JtaW5nIGZpbHRlciBlbXVsYXRpb24sIGFsbCB0aGUg
c3lzY2FsbHMgdGhhdCBhcmUgYWxyZWFkeQo+Pj4+PiBtYXJrZWQgYXMgIm11c3QgcnVuIGZpbHRl
ciIgb24gdGhlIHByZXZpb3VzIGZpbHRlciBjYW4gYmUgc2tpcHBlZCBmb3IKPj4+Pj4gdGhlIG5l
dyBmaWx0ZXIsIHNpbmNlIGl0IGNhbm5vdCBjaGFuZ2UgdGhlIG91dGNvbWUsIHdoaWNoIG1ha2Vz
IHRoZQo+Pj4+PiBlbXVsYXRpb24gc3RlcCBmYXN0ZXIuCj4+Pj4+IAo+Pj4+PiBUaGUgcHJldmlv
dXMgZmlsdGVyJ3MgYml0bWFwIGlzbid0ICJzdGFibGUiIHVudGlsIHNpZ2xvY2sgaXMgaGVsZC4K
Pj4+Pj4gCj4+Pj4+IElmIHdlIGRvIHRoZSBlbXVsYXRpb24gc3RlcCBiZWZvcmUgc2lnbG9jaywg
d2UgaGF2ZSB0byBhbHdheXMgZG8gZnVsbAo+Pj4+PiBldmFsdWF0aW9uIG9mIGFsbCBzeXNjYWxs
cywgYW5kIHRoZW4gbWVyZ2UgdGhlIGJpdG1hcCBkdXJpbmcgYXR0YWNoLgo+Pj4+PiBUaGF0IG1l
YW5zIGFsbCBmaWx0ZXJzIGV2ZXIgYXR0YWNoZWQgd2lsbCB0YWtlIG1heGltYWwgdGltZSB0byBw
ZXJmb3JtCj4+Pj4+IGVtdWxhdGlvbi4KPj4+Pj4gCj4+Pj4+IEkgcHJlZmVyIHRoZSBpZGVhIG9m
IHRoZSBlbXVsYXRpb24gc3RlcCB0YWtpbmcgYWR2YW50YWdlIG9mIHRoZSBiaXRtYXAKPj4+Pj4g
b3B0aW1pemF0aW9uLCBzaW5jZSB0aGUga2VybmVsIHNwZW5kcyBsZXNzIHRpbWUgZG9pbmcgd29y
ayBvdmVyIHRoZSBsaWZlCj4+Pj4+IG9mIHRoZSBwcm9jZXNzIHRyZWUuIEl0J3MgY2VydGFpbmx5
IG1hcmdpbmFsLCBidXQgaXQgYWxzbyBsZXRzIGFsbCB0aGUKPj4+Pj4gYml0bWFwIG1hbmlwdWxh
dGlvbiBzdGF5IGluIG9uZSBwbGFjZSAoYXMgb3Bwb3NlZCB0byBiZWluZyBzcGxpdCBiZXR3ZWVu
Cj4+Pj4+ICJwcmVwYXJlIiBhbmQgImF0dGFjaCIpLgo+Pj4+PiAKPj4+Pj4gV2hhdCBkbyB5b3Ug
dGhpbms/Cj4+Pj4+IAo+Pj4+PiAKPj4+PiAKPj4+PiBJ4oCZbSB3b25kZXJpbmcgaWYgd2Ugc2hv
dWxkIGJlIG11Y2ggbXVjaCBsYXppZXIuIFdlIGNvdWxkIHBvdGVudGlhbGx5IHdhaXQgdW50aWwg
c29tZW9uZSBhY3R1YWxseSB0cmllcyB0byBkbyBhIGdpdmVuIHN5c2NhbGwgYmVmb3JlIHdlIHRy
eSB0byBldmFsdWF0ZSB3aGV0aGVyIHRoZSByZXN1bHQgaXMgZml4ZWQuCj4+PiAKPj4+IFRoYXQg
c2VlbXMgbGlrZSB3ZSdkIG5lZWQgdG8gdHJhY2sgeWV0IGFub3RoZXIgYml0bWFwIG9mICJkaWQg
d2UgZW11bGF0ZQo+Pj4gdGhpcyB5ZXQ/IiBBbmQgaXQgbWVhbnMgdGhlIGZpbHRlciBpc24ndCBy
ZWFsbHkgImRvbmUiIHVudGlsIHlvdSBydW4KPj4+IGFub3RoZXIgc3lzY2FsbD8gZWVoLCBJJ20g
bm90IGEgZmFuOiBpdCBzY3JhdGNoZXMgYXQgbXkgZGVzaXJlIGZvcgo+Pj4gZGV0ZXJtaW5pc20u
IDspIE9yIG1heWJlIG15IGltcGxlbWVudGF0aW9uIGltYWdpbmF0aW9uIGlzIG1pc3NpbmcKPj4+
IHNvbWV0aGluZz8KPj4+IAo+PiAKPj4gV2UnZCBuZWVkIGF0IGxlYXN0IHRocmVlIHN0YXRlcyBw
ZXIgc3lzY2FsbDogdW5rbm93biwgYWx3YXlzLWFsbG93LAo+PiBhbmQgbmVlZC10by1ydW4tZmls
dGVyLgo+PiAKPj4gVGhlIGRvd25zaWRlcyBhcmUgbGVzcyBkZXRlcm1pbmlzbSBhbmQgYSBiaXQg
b2YgYW4gdWdsaWVyCj4+IGltcGxlbWVudGF0aW9uLiAgVGhlIHVwc2lkZSBpcyB0aGF0IHdlIGRv
bid0IG5lZWQgdG8gbG9vcCBvdmVyIGFsbAo+PiBzeXNjYWxscyBhdCBsb2FkIC0tIGluc3RlYWQg
dGhlIHRpbWUgdGhhdCBlYWNoIG9wZXJhdGlvbiB0YWtlcyBpcwo+PiBpbmRlcGVuZGVudCBvZiB0
aGUgdG90YWwgbnVtYmVyIG9mIHN5c2NhbGxzIG9uIHRoZSBzeXN0ZW0uICBBbmQgd2UgY2FuCj4+
IGVudGlyZWx5IGF2b2lkLCBzYXksIGV2YWx1YXRpbmcgdGhlIHgzMiBjYXNlIHVudGlsIHRoZSB0
YXNrIHRyaWVzIGFuCj4+IHgzMiBzeXNjYWxsLgo+PiAKPj4gSSB0aGluayBpdCdzIGF0IGxlYXN0
IHdvcnRoIGNvbnNpZGVyaW5nLgo+IAo+IFllYWgsIHdvcnRoIGNvbnNpZGVyaW5nLiBJIGRvIHN0
aWxsIHRoaW5rIHRoZSB0aW1lIHNwZW50IGluIGVtdWxhdGlvbiBpcwo+IFNPIHNtYWxsIHRoYXQg
aXQgZG9lc24ndCBtYXR0ZXIgcnVubmluZyBhbGwgb2YgdGhlIHN5c2NhbGxzIGF0IGF0dGFjaAo+
IHRpbWUuIFRoZSBmaWx0ZXJzIGFyZSB0aW55IGFuZCBmYWlsIHF1aWNrbHkgaWYgYW55dGhpbmcg
ImludGVyZXN0aW5nIgo+IHN0YXJ0IHRvIGhhcHBlbi4gOykKPiAKClRoZXJl4oCZcyBhIG1pZGRs
ZSBncm91bmQsIHRvbzogZG8gaXQgbGF6aWx5IHBlciBhcmNoLiAgU28gd2Ugd291bGQgYWxsb2Nh
dGUgYW5kIHBvcHVsYXRlIHRoZSBjb21wYXQgYml0bWFwIHRoZSBmaXJzdCB0aW1lIGEgY29tcGF0
IHN5c2NhbGwgaXMgYXR0ZW1wdGVkIGFuZCBkbyB0aGUgc2FtZSBmb3IgeDMyLiBUaGlzIG1heSBo
ZWxwIGF2b2lkIHRoZSBhbm5veWluZyBleHRyYSBtZW1vcnkgdXNhZ2UgYW5kIDN4IHN0YXJ0dXAg
b3ZlcmhlYWQgd2hpbGUgcmV0YWluaW5nIGZ1bGwgZnVuY3Rpb25hbGl0eS4KX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KQ29udGFpbmVycyBtYWlsaW5nIGxp
c3QKQ29udGFpbmVyc0BsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxp
bnV4Zm91bmRhdGlvbi5vcmcvbWFpbG1hbi9saXN0aW5mby9jb250YWluZXJz
