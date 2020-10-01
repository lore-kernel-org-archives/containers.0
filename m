Return-Path: <SRS0=WbUC=DI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B864DC4727E
	for <containers@archiver.kernel.org>; Thu,  1 Oct 2020 16:59:00 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3AA802075F
	for <containers@archiver.kernel.org>; Thu,  1 Oct 2020 16:59:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3AA802075F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.pizza
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id D87A886B16;
	Thu,  1 Oct 2020 16:58:59 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id w3BPb70JhdNW; Thu,  1 Oct 2020 16:58:58 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id C6E2A86A6B;
	Thu,  1 Oct 2020 16:58:58 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id A691AC0889;
	Thu,  1 Oct 2020 16:58:58 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 759A8C0051
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 16:58:57 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 5C60A86AA2
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 16:58:57 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id xCSUuOoRvicM
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 16:58:56 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from wnew1-smtp.messagingengine.com (wnew1-smtp.messagingengine.com
 [64.147.123.26])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 700ED86A6B
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 16:58:56 +0000 (UTC)
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
 by mailnew.west.internal (Postfix) with ESMTP id 73129C9A;
 Thu,  1 Oct 2020 12:58:54 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
 by compute6.internal (MEProxy); Thu, 01 Oct 2020 12:58:55 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tycho.pizza; h=
 date:from:to:cc:subject:message-id:references:mime-version
 :content-type:content-transfer-encoding:in-reply-to; s=fm1; bh=j
 w8E05t8pF0s/VlD5rMYENGSZUwN/eshe0KaWjZtgSE=; b=RQKAcECy89S2+fERA
 s1+f8jWlq237Tj+3z5yAZW8JrgwJH8Fo8RPQzXtxoPl/bkZRMg8UrBZHR422AUTf
 zV8Hq6lIb7I3AH7tHIBySIKlV6JjsTkyMDuEvktVFDAR560enk/NRYpR/h7jyMU+
 CGmzBQG7OLptq8MOh7acEy7gyykqydAZDLwFw88eVK99+QaEauWs5coa3WwSoSJp
 UaN5hmefFUkOk4DyiGx0haS850p+/Cvv3LUZGbD1Yswk7cUC4rk9dMcw72OXMbxZ
 Pz2pQJ42nKXlHxGrtYeqhcxOHxSVJ+lpKJnxNWZqnvR745QKIXB5M/94JG3huNKW
 c6E/A==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
 messagingengine.com; h=cc:content-transfer-encoding:content-type
 :date:from:in-reply-to:message-id:mime-version:references
 :subject:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender
 :x-sasl-enc; s=fm3; bh=jw8E05t8pF0s/VlD5rMYENGSZUwN/eshe0KaWjZtg
 SE=; b=MrOs6cFrxutvZegwyYNltSEHDLdOSjpwXMiLacNBvZjMrDNbnzFSTmOn1
 6ZfnsPjUePtwG5ESSQ1bXy53R1NMaW3umbaWYXVOI2fOLSmwvfsXbfnofenGAZUr
 3r3WrNw3kCZujuT3R6SZ9j5YGasf6uKJOA9w/QatkRjxTW9hAsdn7iDjnEOREbdH
 3NUBzRi4meYGUBTdsIsM8g0+DIbnrecns5/ek1UUBn+K10l462ltJdu/Q8pkO3Qw
 I+Dh0l3aEFg2hndYc8kWMkYOMsvGPEyKDoPbeqKgvaigWkbeaKUdg+e8FwQ3RYDG
 womaxI3t06K8R8lRekzY5WOJVnN1w==
X-ME-Sender: <xms:zAp2X28Rkx_V8WOUabydtQflqWwCEADvMCXVrznXs9yq7FQjA_nHgw>
 <xme:zAp2X2tCki8uYj66JXivxwdmhljf5l8Uew8D_l50fdRNoXOMpMHP1KGc7r7znhSVD
 qQkMgy9Q1y8zkslj9A>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedujedrfeeggdduuddtucetufdoteggodetrfdotf
 fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
 uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
 cujfgurhepfffhvffukfhfgggtugfgjgesthekredttddtjeenucfhrhhomhepvfihtghh
 ohcutehnuggvrhhsvghnuceothihtghhohesthihtghhohdrphhiiiiirgeqnecuggftrf
 grthhtvghrnhephfeuvddvleeiveeggeejueekueeljedtjeefteefueejfedvledttefh
 hfeukeffnecukfhppeejfedrvddujedruddtrdeitdenucevlhhushhtvghrufhiiigvpe
 dtnecurfgrrhgrmhepmhgrihhlfhhrohhmpehthigthhhosehthigthhhordhpihiiiigr
X-ME-Proxy: <xmx:zAp2X8DB9qT-ZW2Bm7gZpxu9WVMfn9K8DVUNVBI9dfwKeMLkSrRNbg>
 <xmx:zAp2X-dqBlHk6wYD_sYQyDBuUyRjeJyaLYjU8Zsp7QpeUJsbGiRE3w>
 <xmx:zAp2X7PS_l50JJbFV8Tfdu8XwlW1Ma6LmwRNOOEkxQiikC8HnKJZRQ>
 <xmx:zQp2X5tV--qQ2FKSKVYCI7VmhgqYJjOxggJpb_o_zZ1M6ImHDm6OCECtrTvLHuze>
Received: from cisco (c-73-217-10-60.hsd1.co.comcast.net [73.217.10.60])
 by mail.messagingengine.com (Postfix) with ESMTPA id 6A5E33280064;
 Thu,  1 Oct 2020 12:58:51 -0400 (EDT)
Date: Thu, 1 Oct 2020 10:58:50 -0600
From: Tycho Andersen <tycho@tycho.pizza>
To: Jann Horn <jannh@google.com>
Subject: Re: For review: seccomp_user_notif(2) manual page
Message-ID: <20201001165850.GC1260245@cisco>
References: <45f07f17-18b6-d187-0914-6f341fe90857@gmail.com>
 <CAG48ez3aqLs_-xgU0bThOLqRiiDWGObxcg-X9iFe6D5RDnLVJg@mail.gmail.com>
 <20201001125043.dj6taeieatpw3a4w@gmail.com>
 <CAG48ez2U1K2XYZu6goRYwmQ-RSu7LkKSOhPt8_wPVEUQfm7Eeg@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAG48ez2U1K2XYZu6goRYwmQ-RSu7LkKSOhPt8_wPVEUQfm7Eeg@mail.gmail.com>
Cc: linux-man <linux-man@vger.kernel.org>, Song Liu <songliubraving@fb.com>,
 Will Drewry <wad@chromium.org>, Kees Cook <keescook@chromium.org>,
 Daniel Borkmann <daniel@iogearbox.net>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Robert Sesek <rsesek@google.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 lkml <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
 Christian Brauner <christian.brauner@canonical.com>,
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
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

T24gVGh1LCBPY3QgMDEsIDIwMjAgYXQgMDU6NDc6NTRQTSArMDIwMCwgSmFubiBIb3JuIHZpYSBD
b250YWluZXJzIHdyb3RlOgo+IE9uIFRodSwgT2N0IDEsIDIwMjAgYXQgMjo1NCBQTSBDaHJpc3Rp
YW4gQnJhdW5lcgo+IDxjaHJpc3RpYW4uYnJhdW5lckBjYW5vbmljYWwuY29tPiB3cm90ZToKPiA+
IE9uIFdlZCwgU2VwIDMwLCAyMDIwIGF0IDA1OjUzOjQ2UE0gKzAyMDAsIEphbm4gSG9ybiB2aWEg
Q29udGFpbmVycyB3cm90ZToKPiA+ID4gT24gV2VkLCBTZXAgMzAsIDIwMjAgYXQgMTowNyBQTSBN
aWNoYWVsIEtlcnJpc2sgKG1hbi1wYWdlcykKPiA+ID4gPG10ay5tYW5wYWdlc0BnbWFpbC5jb20+
IHdyb3RlOgo+ID4gPiA+IE5PVEVTCj4gPiA+ID4gICAgICAgIFRoZSBmaWxlIGRlc2NyaXB0b3Ig
cmV0dXJuZWQgd2hlbiBzZWNjb21wKDIpIGlzIGVtcGxveWVkIHdpdGggdGhlCj4gPiA+ID4gICAg
ICAgIFNFQ0NPTVBfRklMVEVSX0ZMQUdfTkVXX0xJU1RFTkVSICBmbGFnICBjYW4gIGJlICBtb25p
dG9yZWQgIHVzaW5nCj4gPiA+ID4gICAgICAgIHBvbGwoMiksIGVwb2xsKDcpLCBhbmQgc2VsZWN0
KDIpLiAgV2hlbiBhIG5vdGlmaWNhdGlvbiAgaXMgIHBlbmTigJAKPiA+ID4gPiAgICAgICAgaW5n
LCAgdGhlc2UgaW50ZXJmYWNlcyBpbmRpY2F0ZSB0aGF0IHRoZSBmaWxlIGRlc2NyaXB0b3IgaXMg
cmVhZOKAkAo+ID4gPiA+ICAgICAgICBhYmxlLgo+ID4gPgo+ID4gPiBXZSBzaG91bGQgcHJvYmFi
bHkgYWxzbyBwb2ludCBvdXQgc29tZXdoZXJlIHRoYXQsIGFzCj4gPiA+IGluY2x1ZGUvdWFwaS9s
aW51eC9zZWNjb21wLmggc2F5czoKPiA+ID4KPiA+ID4gICogU2ltaWxhciBwcmVjYXV0aW9ucyBz
aG91bGQgYmUgYXBwbGllZCB3aGVuIHN0YWNraW5nIFNFQ0NPTVBfUkVUX1VTRVJfTk9USUYKPiA+
ID4gICogb3IgU0VDQ09NUF9SRVRfVFJBQ0UuIEZvciBTRUNDT01QX1JFVF9VU0VSX05PVElGIGZp
bHRlcnMgYWN0aW5nIG9uIHRoZQo+ID4gPiAgKiBzYW1lIHN5c2NhbGwsIHRoZSBtb3N0IHJlY2Vu
dGx5IGFkZGVkIGZpbHRlciB0YWtlcyBwcmVjZWRlbmNlLiBUaGlzIG1lYW5zCj4gPiA+ICAqIHRo
YXQgdGhlIG5ldyBTRUNDT01QX1JFVF9VU0VSX05PVElGIGZpbHRlciBjYW4gb3ZlcnJpZGUgYW55
Cj4gPiA+ICAqIFNFQ0NPTVBfSU9DVExfTk9USUZfU0VORCBmcm9tIGVhcmxpZXIgZmlsdGVycywg
ZXNzZW50aWFsbHkgYWxsb3dpbmcgYWxsCj4gPiA+ICAqIHN1Y2ggZmlsdGVyZWQgc3lzY2FsbHMg
dG8gYmUgZXhlY3V0ZWQgYnkgc2VuZGluZyB0aGUgcmVzcG9uc2UKPiA+ID4gICogU0VDQ09NUF9V
U0VSX05PVElGX0ZMQUdfQ09OVElOVUUuIE5vdGUgdGhhdCBTRUNDT01QX1JFVF9UUkFDRSBjYW4g
ZXF1YWxseQo+ID4gPiAgKiBiZSBvdmVycmlkZW4gYnkgU0VDQ09NUF9VU0VSX05PVElGX0ZMQUdf
Q09OVElOVUUuCj4gPiA+Cj4gPiA+IEluIG90aGVyIHdvcmRzLCBmcm9tIGEgc2VjdXJpdHkgcGVy
c3BlY3RpdmUsIHlvdSBtdXN0IGFzc3VtZSB0aGF0IHRoZQo+ID4gPiB0YXJnZXQgcHJvY2VzcyBj
YW4gYnlwYXNzIGFueSBTRUNDT01QX1JFVF9VU0VSX05PVElGIChvcgo+ID4gPiBTRUNDT01QX1JF
VF9UUkFDRSkgZmlsdGVycyB1bmxlc3MgaXQgaXMgY29tcGxldGVseSBwcm9oaWJpdGVkIGZyb20K
PiA+ID4gY2FsbGluZyBzZWNjb21wKCkuIFRoaXMgc2hvdWxkIGFsc28gYmUgbm90ZWQgb3ZlciBp
biB0aGUgbWFpbgo+ID4gPiBzZWNjb21wKDIpIG1hbnBhZ2UsIGVzcGVjaWFsbHkgdGhlIFNFQ0NP
TVBfUkVUX1RSQUNFIHBhcnQuCj4gPgo+ID4gU28gSSB3YXMgYWN0dWFsbHkgd29uZGVyaW5nIGFi
b3V0IHRoaXMgd2hlbiBJIHNraW1tZWQgdGhpcyBhbmQgYSB3aGlsZQo+ID4gYWdvIGJ1dCBmb3Jn
b3QgYWJvdXQgdGhpcyBhZ2Fpbi4uLiBBZmFpY3QsIHlvdSBjYW4gb25seSBldmVyIGxvYWQgYQo+
ID4gc2luZ2xlIGZpbHRlciB3aXRoIFNFQ0NPTVBfRklMVEVSX0ZMQUdfTkVXX0xJU1RFTkVSIHNl
dC4gSWYgdGhlcmUKPiA+IGFscmVhZHkgaXMgYSBmaWx0ZXIgd2l0aCB0aGUgU0VDQ09NUF9GSUxU
RVJfRkxBR19ORVdfTElTVEVORVIgcHJvcGVydHkKPiA+IGluIHRoZSB0YXNrcyBmaWx0ZXIgaGll
cmFyY2h5IHRoZW4gdGhlIGtlcm5lbCB3aWxsIHJlZnVzZSB0byBsb2FkIGEgbmV3Cj4gPiBvbmU/
Cj4gPgo+ID4gc3RhdGljIHN0cnVjdCBmaWxlICppbml0X2xpc3RlbmVyKHN0cnVjdCBzZWNjb21w
X2ZpbHRlciAqZmlsdGVyKQo+ID4gewo+ID4gICAgICAgICBzdHJ1Y3QgZmlsZSAqcmV0ID0gRVJS
X1BUUigtRUJVU1kpOwo+ID4gICAgICAgICBzdHJ1Y3Qgc2VjY29tcF9maWx0ZXIgKmN1cjsKPiA+
Cj4gPiAgICAgICAgIGZvciAoY3VyID0gY3VycmVudC0+c2VjY29tcC5maWx0ZXI7IGN1cjsgY3Vy
ID0gY3VyLT5wcmV2KSB7Cj4gPiAgICAgICAgICAgICAgICAgaWYgKGN1ci0+bm90aWYpCj4gPiAg
ICAgICAgICAgICAgICAgICAgICAgICBnb3RvIG91dDsKPiA+ICAgICAgICAgfQo+ID4KPiA+IHNo
b3VsZG4ndCB0aGF0IGJlIHN1ZmZpY2llbnQgdG8gZ3VhcmFudGVlIHRoYXQgVVNFUl9OT1RJRiBm
aWx0ZXJzIGNhbid0Cj4gPiBvdmVycmlkZSBlYWNoIG90aGVyIGZvciB0aGUgc2FtZSB0YXNrIHNp
bXBseSBiZWNhdXNlIHRoZXJlIGNhbiBvbmx5IGV2ZXIKPiA+IGJlIGEgc2luZ2xlIG9uZT8KPiAK
PiBHb29kIHBvaW50LiBFeGNlZWVlcHQgdGhhdCB0aGF0IGNoZWNrIHNlZW1zIGluZWZmZWN0aXZl
IGJlY2F1c2UgdGhpcwo+IGhhcHBlbnMgYmVmb3JlIHdlIHRha2UgdGhlIGxvY2tzIHRoYXQgZ3Vh
cmQgYWdhaW5zdCBUU1lOQywgYW5kIGFsc28KPiBiZWZvcmUgd2UgZGVjaWRlIHRvIHdoaWNoIGV4
aXN0aW5nIGZpbHRlciB3ZSB3YW50IHRvIGNoYWluIHRoZSBuZXcKPiBmaWx0ZXIuIFNvIGlmIHR3
byB0aHJlYWRzIHJhY2Ugd2l0aCBUU1lOQywgSSB0aGluayB0aGV5J2xsIGJlIGFibGUgdG8KPiBj
aGFpbiB0d28gZmlsdGVycyB3aXRoIGxpc3RlbmVycyB0b2dldGhlci4KClllcCwgc2VlbXMgdGhl
IGNoZWNrIG5lZWRzIHRvIGFsc28gYmUgaW4gc2VjY29tcF9jYW5fc3luY190aHJlYWRzKCkgdG8K
YmUgdG90YWxseSBlZmZlY3RpdmUsCgo+IEkgZG9uJ3Qga25vdyB3aGV0aGVyIHdlIHdhbnQgdG8g
ZXRlcm5hbGl6ZSB0aGlzICJvbmx5IG9uZSBsaXN0ZW5lcgo+IGFjcm9zcyBhbGwgdGhlIGZpbHRl
cnMiIHJlc3RyaWN0aW9uIGluIHRoZSBtYW5wYWdlIHRob3VnaCwgb3Igd2hldGhlcgo+IHRoZSBt
YW4gcGFnZSBzaG91bGQganVzdCBzYXkgdGhhdCB0aGUga2VybmVsIGN1cnJlbnRseSBkb2Vzbid0
IHN1cHBvcnQKPiBpdCBidXQgdGhhdCBzZWN1cml0eS13aXNlIHlvdSBzaG91bGQgYXNzdW1lIHRo
YXQgaXQgbWlnaHQgYXQgc29tZQo+IHBvaW50LgoKVGhpcyByZXF1aXJlbWVudCBvcmlnaW5hbGx5
IGNhbWUgZnJvbSBBbmR5LCBhcmd1aW5nIHRoYXQgdGhlIHNlbWFudGljcwpvZiB0aGlzIHdlcmUv
YXJlIGNvbmZ1c2luZywgd2hpY2ggc3RpbGwgbWFrZXMgc2Vuc2UgdG8gbWUuIFBlcmhhcHMgd2UK
c2hvdWxkIGRvIHNvbWV0aGluZyBsaWtlIHRoZSBiZWxvdz8KClR5Y2hvCgoKZGlmZiAtLWdpdCBh
L2tlcm5lbC9zZWNjb21wLmMgYi9rZXJuZWwvc2VjY29tcC5jCmluZGV4IDNlZTU5Y2UwYTMyMy4u
N2IxMDcyMDdjMmIwIDEwMDY0NAotLS0gYS9rZXJuZWwvc2VjY29tcC5jCisrKyBiL2tlcm5lbC9z
ZWNjb21wLmMKQEAgLTM3Niw2ICszNzYsMTggQEAgc3RhdGljIGludCBpc19hbmNlc3RvcihzdHJ1
Y3Qgc2VjY29tcF9maWx0ZXIgKnBhcmVudCwKIAlyZXR1cm4gMDsKIH0KIAorc3RhdGljIGJvb2wg
aGFzX2xpc3RlbmVyX3BhcmVudChzdHJ1Y3Qgc2VjY29tcF9maWx0ZXIgKmNoaWxkKQoreworCXN0
cnVjdCBzZWNjb21wX2ZpbHRlciAqY3VyOworCisJZm9yIChjdXIgPSBjdXJyZW50LT5zZWNjb21w
LmZpbHRlcjsgY3VyOyBjdXIgPSBjdXItPnByZXYpIHsKKwkJaWYgKGN1ci0+bm90aWYpCisJCQly
ZXR1cm4gdHJ1ZTsKKwl9CisKKwlyZXR1cm4gZmFsc2U7Cit9CisKIC8qKgogICogc2VjY29tcF9j
YW5fc3luY190aHJlYWRzOiBjaGVja3MgaWYgYWxsIHRocmVhZHMgY2FuIGJlIHN5bmNocm9uaXpl
ZAogICoKQEAgLTM4NSw3ICszOTcsNyBAQCBzdGF0aWMgaW50IGlzX2FuY2VzdG9yKHN0cnVjdCBz
ZWNjb21wX2ZpbHRlciAqcGFyZW50LAogICogZWl0aGVyIG5vdCBpbiB0aGUgY29ycmVjdCBzZWNj
b21wIG1vZGUgb3IgZGlkIG5vdCBoYXZlIGFuIGFuY2VzdHJhbAogICogc2VjY29tcCBmaWx0ZXIu
CiAgKi8KLXN0YXRpYyBpbmxpbmUgcGlkX3Qgc2VjY29tcF9jYW5fc3luY190aHJlYWRzKHZvaWQp
CitzdGF0aWMgaW5saW5lIHBpZF90IHNlY2NvbXBfY2FuX3N5bmNfdGhyZWFkcyh1bnNpZ25lZCBp
bnQgZmxhZ3MpCiB7CiAJc3RydWN0IHRhc2tfc3RydWN0ICp0aHJlYWQsICpjYWxsZXI7CiAKQEAg
LTQwNyw2ICs0MTksMTEgQEAgc3RhdGljIGlubGluZSBwaWRfdCBzZWNjb21wX2Nhbl9zeW5jX3Ro
cmVhZHModm9pZCkKIAkJCQkgY2FsbGVyLT5zZWNjb21wLmZpbHRlcikpKQogCQkJY29udGludWU7
CiAKKwkJLyogZG9uJ3QgYWxsb3cgVFNZTkMgdG8gaW5zdGFsbCBtdWx0aXBsZSBsaXN0ZW5lcnMg
Ki8KKwkJaWYgKGZsYWdzICYgU0VDQ09NUF9GSUxURVJfRkxBR19ORVdfTElTVEVORVIgJiYKKwkJ
ICAgICFoYXNfbGlzdGVuZXJfcGFyZW50KHRocmVhZC0+c2VjY29tcC5maWx0ZXIpKQorCQkJY29u
dGludWU7CisKIAkJLyogUmV0dXJuIHRoZSBmaXJzdCB0aHJlYWQgdGhhdCBjYW5ub3QgYmUgc3lu
Y2hyb25pemVkLiAqLwogCQlmYWlsZWQgPSB0YXNrX3BpZF92bnIodGhyZWFkKTsKIAkJLyogSWYg
dGhlIHBpZCBjYW5ub3QgYmUgcmVzb2x2ZWQsIHRoZW4gcmV0dXJuIC1FU1JDSCAqLwpAQCAtNjM3
LDcgKzY1NCw3IEBAIHN0YXRpYyBsb25nIHNlY2NvbXBfYXR0YWNoX2ZpbHRlcih1bnNpZ25lZCBp
bnQgZmxhZ3MsCiAJaWYgKGZsYWdzICYgU0VDQ09NUF9GSUxURVJfRkxBR19UU1lOQykgewogCQlp
bnQgcmV0OwogCi0JCXJldCA9IHNlY2NvbXBfY2FuX3N5bmNfdGhyZWFkcygpOworCQlyZXQgPSBz
ZWNjb21wX2Nhbl9zeW5jX3RocmVhZHMoZmxhZ3MpOwogCQlpZiAocmV0KSB7CiAJCQlpZiAoZmxh
Z3MgJiBTRUNDT01QX0ZJTFRFUl9GTEFHX1RTWU5DX0VTUkNIKQogCQkJCXJldHVybiAtRVNSQ0g7
CkBAIC0xNDYyLDEyICsxNDc5LDkgQEAgc3RhdGljIGNvbnN0IHN0cnVjdCBmaWxlX29wZXJhdGlv
bnMgc2VjY29tcF9ub3RpZnlfb3BzID0gewogc3RhdGljIHN0cnVjdCBmaWxlICppbml0X2xpc3Rl
bmVyKHN0cnVjdCBzZWNjb21wX2ZpbHRlciAqZmlsdGVyKQogewogCXN0cnVjdCBmaWxlICpyZXQg
PSBFUlJfUFRSKC1FQlVTWSk7Ci0Jc3RydWN0IHNlY2NvbXBfZmlsdGVyICpjdXI7CiAKLQlmb3Ig
KGN1ciA9IGN1cnJlbnQtPnNlY2NvbXAuZmlsdGVyOyBjdXI7IGN1ciA9IGN1ci0+cHJldikgewot
CQlpZiAoY3VyLT5ub3RpZikKLQkJCWdvdG8gb3V0OwotCX0KKwlpZiAoaGFzX2xpc3RlbmVyX3Bh
cmVudChjdXJyZW50LT5zZWNjb21wLmZpbHRlcikpCisJCWdvdG8gb3V0OwogCiAJcmV0ID0gRVJS
X1BUUigtRU5PTUVNKTsKIAlmaWx0ZXItPm5vdGlmID0ga3phbGxvYyhzaXplb2YoKihmaWx0ZXIt
Pm5vdGlmKSksIEdGUF9LRVJORUwpOwpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fXwpDb250YWluZXJzIG1haWxpbmcgbGlzdApDb250YWluZXJzQGxpc3RzLmxp
bnV4LWZvdW5kYXRpb24ub3JnCmh0dHBzOi8vbGlzdHMubGludXhmb3VuZGF0aW9uLm9yZy9tYWls
bWFuL2xpc3RpbmZvL2NvbnRhaW5lcnM=
