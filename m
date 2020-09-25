Return-Path: <SRS0=50w+=DC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 319D6C4727F
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 20:37:14 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id AD2752086A
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 20:37:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="iuXRcgXH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD2752086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 30A7987676;
	Fri, 25 Sep 2020 20:37:13 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id pD94arfv-K6r; Fri, 25 Sep 2020 20:37:12 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id A118E87670;
	Fri, 25 Sep 2020 20:37:12 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 859C7C0890;
	Fri, 25 Sep 2020 20:37:12 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 442EEC0051
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 20:37:11 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 3363D203C3
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 20:37:11 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id lahHSRuLvw5C
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 20:37:10 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pf1-f194.google.com (mail-pf1-f194.google.com
 [209.85.210.194])
 by silver.osuosl.org (Postfix) with ESMTPS id EE55520379
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 20:37:09 +0000 (UTC)
Received: by mail-pf1-f194.google.com with SMTP id b124so4319617pfg.13
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 13:37:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:content-transfer-encoding:in-reply-to;
 bh=GfC/K5/eyr5f/R6KNnYNTFVKM8gTDhQ8O0T6Bc65g7I=;
 b=iuXRcgXHEiB9o39H9hbvhItGSIju7sdYkPIXMM1iEESsQCqXomWCjd5+I/Y72J3MmH
 pE8Ycf2qbqERCla+//BzWiE8E/xZAo9m473D7cg0uxM/yJXGtfUTlhDO2rRmdAOvY+dE
 v9Kt55YnQOItQGdI3tA4n/0wtmB/7neNsMa94=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:content-transfer-encoding
 :in-reply-to;
 bh=GfC/K5/eyr5f/R6KNnYNTFVKM8gTDhQ8O0T6Bc65g7I=;
 b=qTsVuuOJEM8xzx09T9dtOExy2uP5Vrno9At3rzspeXddFaRfk3lpy78nmVzmRBKT2d
 oCmqAn58A9kZT1XJtSMLCV79R8k0QF1HrM3YjaEr2uLINOqvDGSfi8olFRnDsiKkhZK8
 Ici7tSK527jbp+coPtdf/kBid0QGrxOPqe5e7u6gJeTaRiuhZkkK/s42L35QrapZkZPN
 YCln9pG3gIAbOUWV4+trmZx1xS1t4ieJYrfsGQRSgD+bgick7kU8sjxvfuzvuXfhgT38
 PCRwDbWwHmH2Ou8041FBQTrlVcAsQixxxK9S4wsFia8H5xh25YFRRlR5iAGXt4nfbaqY
 0dNw==
X-Gm-Message-State: AOAM533vtDrXGFsbHNFQCjJBPO5qAUFZBHdgrbZ1UZ+exScVx65r1WaO
 6hTvvnA4KcCVl5VvQYB/sAp1Wg==
X-Google-Smtp-Source: ABdhPJx5DRTSBJLZM4R1CgkCB9Vmp/ILkSaDUH73jMRCTvs/2F79SPo4ijjl1Tk1Fd/fHgDAR7Ze3g==
X-Received: by 2002:aa7:8249:0:b029:142:2501:34db with SMTP id
 e9-20020aa782490000b0290142250134dbmr982040pfn.52.1601066229568; 
 Fri, 25 Sep 2020 13:37:09 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id z8sm3049258pgr.70.2020.09.25.13.37.08
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Fri, 25 Sep 2020 13:37:08 -0700 (PDT)
Date: Fri, 25 Sep 2020 13:37:07 -0700
From: Kees Cook <keescook@chromium.org>
To: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v2 seccomp 3/6] seccomp/cache: Add "emulator" to check if
 filter is arg-dependent
Message-ID: <202009251332.24CE0C58@keescook>
References: <202009251223.8E46C831E2@keescook>
 <2FA23A2E-16B0-4E08-96D5-6D6FE45BBCF6@amacapital.net>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <2FA23A2E-16B0-4E08-96D5-6D6FE45BBCF6@amacapital.net>
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

T24gRnJpLCBTZXAgMjUsIDIwMjAgYXQgMTI6NTE6MjBQTSAtMDcwMCwgQW5keSBMdXRvbWlyc2tp
IHdyb3RlOgo+IAo+IAo+ID4gT24gU2VwIDI1LCAyMDIwLCBhdCAxMjo0MiBQTSwgS2VlcyBDb29r
IDxrZWVzY29va0BjaHJvbWl1bS5vcmc+IHdyb3RlOgo+ID4gCj4gPiDvu79PbiBGcmksIFNlcCAy
NSwgMjAyMCBhdCAxMTo0NTowNUFNIC0wNTAwLCBZaUZlaSBaaHUgd3JvdGU6Cj4gPj4gT24gVGh1
LCBTZXAgMjQsIDIwMjAgYXQgMTA6MDQgUE0gWWlGZWkgWmh1IDx6aHV5aWZlaTE5OTlAZ21haWwu
Y29tPiB3cm90ZToKPiA+Pj4+IFdoeSBkbyB0aGUgcHJlcGFyZSBoZXJlIGluc3RlYWQgb2YgZHVy
aW5nIGF0dGFjaD8gKEFuZCBub3RlIHRoYXQgaXQKPiA+Pj4+IHNob3VsZCBub3QgYmUgd3JpdHRl
biB0byBmYWlsLikKPiA+Pj4gCj4gPj4+IFJpZ2h0Lgo+ID4+IAo+ID4+IER1cmluZyBhdHRhY2gg
YSBzcGlubG9jayAoY3VycmVudC0+c2lnaGFuZC0+c2lnbG9jaykgaXMgaGVsZC4gRG8gd2UKPiA+
PiByZWFsbHkgd2FudCB0byBwdXQgdGhlIGVtdWxhdG9yIGluIHRoZSAiYXRvbWljIHNlY3Rpb24i
Pwo+ID4gCj4gPiBJdCdzIGEgZ29vZCBwb2ludCwgYnV0IEkgaGFkIHNvbWUgb3RoZXIgaWRlYXMg
YXJvdW5kIGl0IHRoYXQgbGVhZCB0byBtZQo+ID4gYSBkaWZmZXJlbnQgY29uY2x1c2lvbi4gSGVy
ZSdzIHdoYXQgSSd2ZSBnb3QgaW4gbXkgaGVhZDoKPiA+IAo+ID4gSSBkb24ndCB2aWV3IGZpbHRl
ciBhdHRhY2ggKG5vciB0aGUgc2lnbG9jaykgYXMgZmFzdHBhdGg6IHRoZSBsb2NrIGlzCj4gPiBy
YXJlbHkgY29udGVzdGVkIGFuZCB0aGUgImxvbmcgdGltZSIgd2lsbCBvbmx5IGJlIGR1cmluZyBm
aWx0ZXIgYXR0YWNoLgo+ID4gCj4gPiBXaGVuIHBlcmZvcm1pbmcgZmlsdGVyIGVtdWxhdGlvbiwg
YWxsIHRoZSBzeXNjYWxscyB0aGF0IGFyZSBhbHJlYWR5Cj4gPiBtYXJrZWQgYXMgIm11c3QgcnVu
IGZpbHRlciIgb24gdGhlIHByZXZpb3VzIGZpbHRlciBjYW4gYmUgc2tpcHBlZCBmb3IKPiA+IHRo
ZSBuZXcgZmlsdGVyLCBzaW5jZSBpdCBjYW5ub3QgY2hhbmdlIHRoZSBvdXRjb21lLCB3aGljaCBt
YWtlcyB0aGUKPiA+IGVtdWxhdGlvbiBzdGVwIGZhc3Rlci4KPiA+IAo+ID4gVGhlIHByZXZpb3Vz
IGZpbHRlcidzIGJpdG1hcCBpc24ndCAic3RhYmxlIiB1bnRpbCBzaWdsb2NrIGlzIGhlbGQuCj4g
PiAKPiA+IElmIHdlIGRvIHRoZSBlbXVsYXRpb24gc3RlcCBiZWZvcmUgc2lnbG9jaywgd2UgaGF2
ZSB0byBhbHdheXMgZG8gZnVsbAo+ID4gZXZhbHVhdGlvbiBvZiBhbGwgc3lzY2FsbHMsIGFuZCB0
aGVuIG1lcmdlIHRoZSBiaXRtYXAgZHVyaW5nIGF0dGFjaC4KPiA+IFRoYXQgbWVhbnMgYWxsIGZp
bHRlcnMgZXZlciBhdHRhY2hlZCB3aWxsIHRha2UgbWF4aW1hbCB0aW1lIHRvIHBlcmZvcm0KPiA+
IGVtdWxhdGlvbi4KPiA+IAo+ID4gSSBwcmVmZXIgdGhlIGlkZWEgb2YgdGhlIGVtdWxhdGlvbiBz
dGVwIHRha2luZyBhZHZhbnRhZ2Ugb2YgdGhlIGJpdG1hcAo+ID4gb3B0aW1pemF0aW9uLCBzaW5j
ZSB0aGUga2VybmVsIHNwZW5kcyBsZXNzIHRpbWUgZG9pbmcgd29yayBvdmVyIHRoZSBsaWZlCj4g
PiBvZiB0aGUgcHJvY2VzcyB0cmVlLiBJdCdzIGNlcnRhaW5seSBtYXJnaW5hbCwgYnV0IGl0IGFs
c28gbGV0cyBhbGwgdGhlCj4gPiBiaXRtYXAgbWFuaXB1bGF0aW9uIHN0YXkgaW4gb25lIHBsYWNl
IChhcyBvcHBvc2VkIHRvIGJlaW5nIHNwbGl0IGJldHdlZW4KPiA+ICJwcmVwYXJlIiBhbmQgImF0
dGFjaCIpLgo+ID4gCj4gPiBXaGF0IGRvIHlvdSB0aGluaz8KPiA+IAo+ID4gCj4gCj4gSeKAmW0g
d29uZGVyaW5nIGlmIHdlIHNob3VsZCBiZSBtdWNoIG11Y2ggbGF6aWVyLiBXZSBjb3VsZCBwb3Rl
bnRpYWxseSB3YWl0IHVudGlsIHNvbWVvbmUgYWN0dWFsbHkgdHJpZXMgdG8gZG8gYSBnaXZlbiBz
eXNjYWxsIGJlZm9yZSB3ZSB0cnkgdG8gZXZhbHVhdGUgd2hldGhlciB0aGUgcmVzdWx0IGlzIGZp
eGVkLgoKVGhhdCBzZWVtcyBsaWtlIHdlJ2QgbmVlZCB0byB0cmFjayB5ZXQgYW5vdGhlciBiaXRt
YXAgb2YgImRpZCB3ZSBlbXVsYXRlCnRoaXMgeWV0PyIgQW5kIGl0IG1lYW5zIHRoZSBmaWx0ZXIg
aXNuJ3QgcmVhbGx5ICJkb25lIiB1bnRpbCB5b3UgcnVuCmFub3RoZXIgc3lzY2FsbD8gZWVoLCBJ
J20gbm90IGEgZmFuOiBpdCBzY3JhdGNoZXMgYXQgbXkgZGVzaXJlIGZvcgpkZXRlcm1pbmlzbS4g
OykgT3IgbWF5YmUgbXkgaW1wbGVtZW50YXRpb24gaW1hZ2luYXRpb24gaXMgbWlzc2luZwpzb21l
dGhpbmc/CgotLSAKS2VlcyBDb29rCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fCkNvbnRhaW5lcnMgbWFpbGluZyBsaXN0CkNvbnRhaW5lcnNAbGlzdHMubGlu
dXgtZm91bmRhdGlvbi5vcmcKaHR0cHM6Ly9saXN0cy5saW51eGZvdW5kYXRpb24ub3JnL21haWxt
YW4vbGlzdGluZm8vY29udGFpbmVycw==
