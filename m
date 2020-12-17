Return-Path: <SRS0=jS4c=FV=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 663B9C4361B
	for <containers@archiver.kernel.org>; Thu, 17 Dec 2020 12:14:25 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id DE78822D72
	for <containers@archiver.kernel.org>; Thu, 17 Dec 2020 12:14:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE78822D72
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-m68k.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 5FB988691A;
	Thu, 17 Dec 2020 12:14:24 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ZW3YN6xiC4BF; Thu, 17 Dec 2020 12:14:23 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 00094863AC;
	Thu, 17 Dec 2020 12:14:22 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id EDBFFC0893;
	Thu, 17 Dec 2020 12:14:22 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 3230FC013B
 for <containers@lists.linux-foundation.org>;
 Thu, 17 Dec 2020 12:14:21 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 2B9C0876FA
 for <containers@lists.linux-foundation.org>;
 Thu, 17 Dec 2020 12:14:21 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id AlMcNRpUVzc8
 for <containers@lists.linux-foundation.org>;
 Thu, 17 Dec 2020 12:14:19 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ot1-f54.google.com (mail-ot1-f54.google.com
 [209.85.210.54])
 by whitealder.osuosl.org (Postfix) with ESMTPS id BDA10876E7
 for <containers@lists.linux-foundation.org>;
 Thu, 17 Dec 2020 12:14:19 +0000 (UTC)
Received: by mail-ot1-f54.google.com with SMTP id h18so27016835otq.12
 for <containers@lists.linux-foundation.org>;
 Thu, 17 Dec 2020 04:14:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc:content-transfer-encoding;
 bh=g+ZQ9Hep/ihbUcAAKgQBrtb6DKWZjd1MMpk6GQGQBFo=;
 b=Pxh/d81f9RmUtMedRA/doPKjqQji19zDRM8Bs3LV5tJ699ccVhEufUteZ+0qQJMUlG
 4oKYLLVKhuwSFCcdCZkiMShPBqOrGHEvP+8kLggSRrs5HYs144tbFWv1TAvFF4X/lwqj
 fO3hau7ZJfEWbOCOHOHuoa+5guHNM1+KWqBlgOcQCFAap1p7ZoxCo6l0LJSntF+t6iB1
 RM4wl1yK9u03zKigp4dKy/tQcwlefaq3u+jMeZOxR8HagsXWKY60Gb/pMApSRb55wCp2
 CzblK360odCQ9BQKQZQkHDe486GKApNpZq5cRYw7+AzygTQpzuv3z4wE5KP5NWIQQSqN
 UoAA==
X-Gm-Message-State: AOAM531VT+24UwSIYIZ+1H3/y7kqgytSKw2YP/+xF/ONjdorqeH8HvWy
 2nOC2+wshIbwqu9JnThylKqFPVQks7jsoDXFXkY=
X-Google-Smtp-Source: ABdhPJz59bsLl40yU/AMrbYd1pTjEH6DKHmAPNcgiQuY6xiSJuPFg3psehvXyIwiQfTmcEKRkCfg14X04prnuLoQcg4=
X-Received: by 2002:a05:6830:210a:: with SMTP id
 i10mr29145891otc.145.1608207259025; 
 Thu, 17 Dec 2020 04:14:19 -0800 (PST)
MIME-Version: 1.0
References: <cover.1602431034.git.yifeifz2@illinois.edu>
 <4706b0ff81f28b498c9012fd3517fe88319e7c42.1602431034.git.yifeifz2@illinois.edu>
In-Reply-To: <4706b0ff81f28b498c9012fd3517fe88319e7c42.1602431034.git.yifeifz2@illinois.edu>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Thu, 17 Dec 2020 13:14:07 +0100
Message-ID: <CAMuHMdVU1BhmwMiHKDYmnyRHtQfeMtwtwkFLQwinfBPto-rtOQ@mail.gmail.com>
Subject: Re: [PATCH v5 seccomp 5/5] seccomp/cache: Report cache data through
 /proc/pid/seccomp_cache
To: YiFei Zhu <zhuyifei1999@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Kees Cook <keescook@chromium.org>,
 Jann Horn <jannh@google.com>, YiFei Zhu <yifeifz2@illinois.edu>,
 containers@lists.linux-foundation.org, Tobin Feldman-Fitzthum <tobin@ibm.com>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Hubertus Franke <frankeh@us.ibm.com>,
 Aleksa Sarai <cyphar@cyphar.com>, David Laight <David.Laight@aculab.com>,
 Jack Chen <jianyan2@illinois.edu>, Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
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

SGkgWWlmZWksCgpPbiBTdW4sIE9jdCAxMSwgMjAyMCBhdCA4OjA4IFBNIFlpRmVpIFpodSA8emh1
eWlmZWkxOTk5QGdtYWlsLmNvbT4gd3JvdGU6Cj4gRnJvbTogWWlGZWkgWmh1IDx5aWZlaWZ6MkBp
bGxpbm9pcy5lZHU+Cj4KPiBDdXJyZW50bHkgdGhlIGtlcm5lbCBkb2VzIG5vdCBwcm92aWRlIGFu
IGluZnJhc3RydWN0dXJlIHRvIHRyYW5zbGF0ZQo+IGFyY2hpdGVjdHVyZSBudW1iZXJzIHRvIGEg
aHVtYW4tcmVhZGFibGUgbmFtZS4gVHJhbnNsYXRpbmcgc3lzY2FsbAo+IG51bWJlcnMgdG8gc3lz
Y2FsbCBuYW1lcyBpcyBwb3NzaWJsZSB0aHJvdWdoIEZUUkFDRV9TWVNDQUxMCj4gaW5mcmFzdHJ1
Y3R1cmUgYnV0IGl0IGRvZXMgbm90IHByb3ZpZGUgc3VwcG9ydCBmb3IgY29tcGF0IHN5c2NhbGxz
Lgo+Cj4gVGhpcyB3aWxsIGNyZWF0ZSBhIGZpbGUgZm9yIGVhY2ggUElEIGFzIC9wcm9jL3BpZC9z
ZWNjb21wX2NhY2hlLgo+IFRoZSBmaWxlIHdpbGwgYmUgZW1wdHkgd2hlbiBubyBzZWNjb21wIGZp
bHRlcnMgYXJlIGxvYWRlZCwgb3IgYmUKPiBpbiB0aGUgZm9ybWF0IG9mOgo+IDxhcmNoIG5hbWU+
IDxkZWNpbWFsIHN5c2NhbGwgbnVtYmVyPiA8QUxMT1cgfCBGSUxURVI+Cj4gd2hlcmUgQUxMT1cg
bWVhbnMgdGhlIGNhY2hlIGlzIGd1YXJhbnRlZWQgdG8gYWxsb3cgdGhlIHN5c2NhbGwsCj4gYW5k
IGZpbHRlciBtZWFucyB0aGUgY2FjaGUgd2lsbCBwYXNzIHRoZSBzeXNjYWxsIHRvIHRoZSBCUEYg
ZmlsdGVyLgo+Cj4gRm9yIHRoZSBkb2NrZXIgZGVmYXVsdCBwcm9maWxlIG9uIHg4Nl82NCBpdCBs
b29rcyBsaWtlOgo+IHg4Nl82NCAwIEFMTE9XCj4geDg2XzY0IDEgQUxMT1cKPiB4ODZfNjQgMiBB
TExPVwo+IHg4Nl82NCAzIEFMTE9XCj4gWy4uLl0KPiB4ODZfNjQgMTMyIEFMTE9XCj4geDg2XzY0
IDEzMyBBTExPVwo+IHg4Nl82NCAxMzQgRklMVEVSCj4geDg2XzY0IDEzNSBGSUxURVIKPiB4ODZf
NjQgMTM2IEZJTFRFUgo+IHg4Nl82NCAxMzcgQUxMT1cKPiB4ODZfNjQgMTM4IEFMTE9XCj4geDg2
XzY0IDEzOSBGSUxURVIKPiB4ODZfNjQgMTQwIEFMTE9XCj4geDg2XzY0IDE0MSBBTExPVwo+IFsu
Li5dCj4KPiBUaGlzIGZpbGUgaXMgZ3VhcmRlZCBieSBDT05GSUdfU0VDQ09NUF9DQUNIRV9ERUJV
RyB3aXRoIGEgZGVmYXVsdAo+IG9mIE4gYmVjYXVzZSBJIHRoaW5rIGNlcnRhaW4gdXNlcnMgb2Yg
c2VjY29tcCBtaWdodCBub3Qgd2FudCB0aGUKPiBhcHBsaWNhdGlvbiB0byBrbm93IHdoaWNoIHN5
c2NhbGxzIGFyZSBkZWZpbml0ZWx5IHVzYWJsZS4gRm9yCj4gdGhlIHNhbWUgcmVhc29uLCBpdCBp
cyBhbHNvIGd1YXJkZWQgYnkgQ0FQX1NZU19BRE1JTi4KPgo+IFN1Z2dlc3RlZC1ieTogSmFubiBI
b3JuIDxqYW5uaEBnb29nbGUuY29tPgo+IExpbms6IGh0dHBzOi8vbG9yZS5rZXJuZWwub3JnL2xr
bWwvQ0FHNDhlejNPZnFwNGNyWEdrc0xtWlk2PWZHckZfdFd5VUNnN1BCa0FldHZiYk9QZU9BQG1h
aWwuZ21haWwuY29tLwo+IFNpZ25lZC1vZmYtYnk6IFlpRmVpIFpodSA8eWlmZWlmejJAaWxsaW5v
aXMuZWR1PgoKPiBAQCAtMjMxMSwzICsyMzE0LDU5IEBAIHN0YXRpYyBpbnQgX19pbml0IHNlY2Nv
bXBfc3lzY3RsX2luaXQodm9pZCkKPiAgZGV2aWNlX2luaXRjYWxsKHNlY2NvbXBfc3lzY3RsX2lu
aXQpCj4KPiAgI2VuZGlmIC8qIENPTkZJR19TWVNDVEwgKi8KPiArCj4gKyNpZmRlZiBDT05GSUdf
U0VDQ09NUF9DQUNIRV9ERUJVRwo+ICsvKiBDdXJyZW50bHkgQ09ORklHX1NFQ0NPTVBfQ0FDSEVf
REVCVUcgaW1wbGllcyBTRUNDT01QX0FSQ0hfTkFUSVZFICovCgpTaG91bGQgdGhlcmUgYmUgYSBk
ZXBlbmRlbmN5IG9uIFNFQ0NPTVBfQVJDSF9OQVRJVkU/ClNob3VsZCBhbGwgYXJjaGl0ZWN0dXJl
cyB0aGF0IGltcGxlbWVudCBzZWNjb21wIGhhdmUgdGhpcz8KCkUuZy4gbWlwcyBkb2VzIHNlbGVj
dCBIQVZFX0FSQ0hfU0VDQ09NUF9GSUxURVIsIGJ1dCBkb2Vzbid0CmhhdmUgU0VDQ09NUF9BUkNI
X05BVElWRT8KCihub3RpY2VkIHdpdGggcHJlbGltaW5hcnkgb3V0LW9mLXRyZWUgc2VjY29tcCBp
bXBsZW1lbnRhdGlvbiBmb3IgbTY4aywKIHdoaWNoIGRvZXNuJ3QgaGF2ZSBTRUNDT01QX0FSQ0hf
TkFUSVZFCgo+ICtzdGF0aWMgdm9pZCBwcm9jX3BpZF9zZWNjb21wX2NhY2hlX2FyY2goc3RydWN0
IHNlcV9maWxlICptLCBjb25zdCBjaGFyICpuYW1lLAo+ICsgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICBjb25zdCB2b2lkICpiaXRtYXAsIHNpemVfdCBiaXRtYXBfc2l6ZSkK
PiArewo+ICsgICAgICAgaW50IG5yOwo+ICsKPiArICAgICAgIGZvciAobnIgPSAwOyBuciA8IGJp
dG1hcF9zaXplOyBucisrKSB7Cj4gKyAgICAgICAgICAgICAgIGJvb2wgY2FjaGVkID0gdGVzdF9i
aXQobnIsIGJpdG1hcCk7Cj4gKyAgICAgICAgICAgICAgIGNoYXIgKnN0YXR1cyA9IGNhY2hlZCA/
ICJBTExPVyIgOiAiRklMVEVSIjsKPiArCj4gKyAgICAgICAgICAgICAgIHNlcV9wcmludGYobSwg
IiVzICVkICVzXG4iLCBuYW1lLCBuciwgc3RhdHVzKTsKPiArICAgICAgIH0KPiArfQo+ICsKPiAr
aW50IHByb2NfcGlkX3NlY2NvbXBfY2FjaGUoc3RydWN0IHNlcV9maWxlICptLCBzdHJ1Y3QgcGlk
X25hbWVzcGFjZSAqbnMsCj4gKyAgICAgICAgICAgICAgICAgICAgICAgICAgc3RydWN0IHBpZCAq
cGlkLCBzdHJ1Y3QgdGFza19zdHJ1Y3QgKnRhc2spCj4gK3sKPiArICAgICAgIHN0cnVjdCBzZWNj
b21wX2ZpbHRlciAqZjsKPiArICAgICAgIHVuc2lnbmVkIGxvbmcgZmxhZ3M7Cj4gKwo+ICsgICAg
ICAgLyoKPiArICAgICAgICAqIFdlIGRvbid0IHdhbnQgc29tZSBzYW5kYm94ZWQgcHJvY2VzcyB0
byBrbm93IHdoYXQgdGhlaXIgc2VjY29tcAo+ICsgICAgICAgICogZmlsdGVycyBjb25zaXN0IG9m
Lgo+ICsgICAgICAgICovCj4gKyAgICAgICBpZiAoIWZpbGVfbnNfY2FwYWJsZShtLT5maWxlLCAm
aW5pdF91c2VyX25zLCBDQVBfU1lTX0FETUlOKSkKPiArICAgICAgICAgICAgICAgcmV0dXJuIC1F
QUNDRVM7Cj4gKwo+ICsgICAgICAgaWYgKCFsb2NrX3Rhc2tfc2lnaGFuZCh0YXNrLCAmZmxhZ3Mp
KQo+ICsgICAgICAgICAgICAgICByZXR1cm4gLUVTUkNIOwo+ICsKPiArICAgICAgIGYgPSBSRUFE
X09OQ0UodGFzay0+c2VjY29tcC5maWx0ZXIpOwo+ICsgICAgICAgaWYgKCFmKSB7Cj4gKyAgICAg
ICAgICAgICAgIHVubG9ja190YXNrX3NpZ2hhbmQodGFzaywgJmZsYWdzKTsKPiArICAgICAgICAg
ICAgICAgcmV0dXJuIDA7Cj4gKyAgICAgICB9Cj4gKwo+ICsgICAgICAgLyogcHJldmVudCBmaWx0
ZXIgZnJvbSBiZWluZyBmcmVlZCB3aGlsZSB3ZSBhcmUgcHJpbnRpbmcgaXQgKi8KPiArICAgICAg
IF9fZ2V0X3NlY2NvbXBfZmlsdGVyKGYpOwo+ICsgICAgICAgdW5sb2NrX3Rhc2tfc2lnaGFuZCh0
YXNrLCAmZmxhZ3MpOwo+ICsKPiArICAgICAgIHByb2NfcGlkX3NlY2NvbXBfY2FjaGVfYXJjaCht
LCBTRUNDT01QX0FSQ0hfTkFUSVZFX05BTUUsCj4gKyAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgZi0+Y2FjaGUuYWxsb3dfbmF0aXZlLAoKZXJyb3I6IOKAmHN0cnVjdCBhY3Rpb25f
Y2FjaGXigJkgaGFzIG5vIG1lbWJlciBuYW1lZCDigJhhbGxvd19uYXRpdmXigJkKCnN0cnVjdCBh
Y3Rpb25fY2FjaGUgaXMgZW1wdHkgaWYgU0VDQ09NUF9BUkNIX05BVElWRSBpcyBub3QKZGVmaW5l
ZCAoc28gdGhlcmUgYXJlIGNoZWNrcyBmb3IgaXQpLgoKPiArICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICBTRUNDT01QX0FSQ0hfTkFUSVZFX05SKTsKPiArCj4gKyNpZmRlZiBTRUND
T01QX0FSQ0hfQ09NUEFUCj4gKyAgICAgICBwcm9jX3BpZF9zZWNjb21wX2NhY2hlX2FyY2gobSwg
U0VDQ09NUF9BUkNIX0NPTVBBVF9OQU1FLAo+ICsgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgIGYtPmNhY2hlLmFsbG93X2NvbXBhdCwKPiArICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICBTRUNDT01QX0FSQ0hfQ09NUEFUX05SKTsKPiArI2VuZGlmIC8qIFNFQ0NPTVBf
QVJDSF9DT01QQVQgKi8KPiArCj4gKyAgICAgICBfX3B1dF9zZWNjb21wX2ZpbHRlcihmKTsKPiAr
ICAgICAgIHJldHVybiAwOwo+ICt9Cj4gKyNlbmRpZiAvKiBDT05GSUdfU0VDQ09NUF9DQUNIRV9E
RUJVRyAqLwo+IC0tCj4gMi4yOC4wCj4KCgotLSAKR3J7b2V0amUsZWV0aW5nfXMsCgogICAgICAg
ICAgICAgICAgICAgICAgICBHZWVydAoKLS0gCkdlZXJ0IFV5dHRlcmhvZXZlbiAtLSBUaGVyZSdz
IGxvdHMgb2YgTGludXggYmV5b25kIGlhMzIgLS0gZ2VlcnRAbGludXgtbTY4ay5vcmcKCkluIHBl
cnNvbmFsIGNvbnZlcnNhdGlvbnMgd2l0aCB0ZWNobmljYWwgcGVvcGxlLCBJIGNhbGwgbXlzZWxm
IGEgaGFja2VyLiBCdXQKd2hlbiBJJ20gdGFsa2luZyB0byBqb3VybmFsaXN0cyBJIGp1c3Qgc2F5
ICJwcm9ncmFtbWVyIiBvciBzb21ldGhpbmcgbGlrZSB0aGF0LgogICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgIC0tIExpbnVzIFRvcnZhbGRzCl9fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fCkNvbnRhaW5lcnMgbWFpbGluZyBsaXN0CkNvbnRhaW5lcnNA
bGlzdHMubGludXgtZm91bmRhdGlvbi5vcmcKaHR0cHM6Ly9saXN0cy5saW51eGZvdW5kYXRpb24u
b3JnL21haWxtYW4vbGlzdGluZm8vY29udGFpbmVycw==
