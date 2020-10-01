Return-Path: <SRS0=WbUC=DI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A68FC4727E
	for <containers@archiver.kernel.org>; Thu,  1 Oct 2020 18:56:48 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 98F872068E
	for <containers@archiver.kernel.org>; Thu,  1 Oct 2020 18:56:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 98F872068E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.pizza
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 46E2A861B5;
	Thu,  1 Oct 2020 18:56:47 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id q9gDFQbST+JN; Thu,  1 Oct 2020 18:56:43 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id B113C85CB8;
	Thu,  1 Oct 2020 18:56:43 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id A2F2AC0889;
	Thu,  1 Oct 2020 18:56:43 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 8163AC0051
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 18:56:42 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 6A26F8687B
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 18:56:42 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id i1ftH9TpFvix
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 18:56:38 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from wnew1-smtp.messagingengine.com (wnew1-smtp.messagingengine.com
 [64.147.123.26])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 9FDC886879
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 18:56:38 +0000 (UTC)
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
 by mailnew.west.internal (Postfix) with ESMTP id 366651298;
 Thu,  1 Oct 2020 14:56:36 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
 by compute6.internal (MEProxy); Thu, 01 Oct 2020 14:56:37 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tycho.pizza; h=
 date:from:to:cc:subject:message-id:references:mime-version
 :content-type:content-transfer-encoding:in-reply-to; s=fm1; bh=i
 bq8LGhrZAKigNWOBMJB3QC8JFPS6HWHnRsmip0Juf8=; b=faefTIbsKtfeTFnxU
 i6tdavFKCHLFdM2fxfyp1AHD15/aQqHWGz8vNOLmFkRRXqkpjgOsgLXT0+J0TZM5
 qc9c7yfgRZ5TLa2zdVqFAV+uXEpLR/t+uKd9UIHwbYy2BGVLLo8EgUla4FNkk6E4
 vK3g8QjsUQa0GfsJcY5g0+xbOEMp8ktmfX7VVq+AtUqd79eCBD7flPRARFIFWzlM
 S0GS7Nkkh+WsmhH/Fp6zHBe6tCNT9gKvxYm7qiRBoITQYF7S0gAljeOXlTIQrL82
 pFvMNcICudfy1edLjhUhpLzsIIvqI0fqXF7ogOTy6gwY1udn0/b+zhqyhyLacVBM
 HzsKQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
 messagingengine.com; h=cc:content-transfer-encoding:content-type
 :date:from:in-reply-to:message-id:mime-version:references
 :subject:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender
 :x-sasl-enc; s=fm3; bh=ibq8LGhrZAKigNWOBMJB3QC8JFPS6HWHnRsmip0Ju
 f8=; b=vbC/uYymsPNo3iCMQ0xDYDVah+dU7erOdTEDmHcMYHh7/G8rQptUkvKKA
 NXouI6bqPOdVVEmAdVZwFeiyQqzVsU405xvQG6b6xwCBS5EJaDqnmpqNcrJ6RHGU
 ZZK5qXcd1FVgkPQYEnTTcV2dxW2FDhydgh+1Fx9zHU+eN8JrbZQpKUVQve/zvP+N
 PDwR0BRNg01821QELz1wEM1QlrlnrBP0gkYyXXqy1fuB2dA2kpXwmEiq1jb2nIME
 xtGJYrTqngxi8q1mIM12Q+MDu2lGVYN32b1O3nLX8tDxRjRRLsBgVwRqxCcGAi2e
 /8RZ5PMfF6Jl/Czmu7jomZbGVhYJA==
X-ME-Sender: <xms:YSZ2X9IGt_5vqGNirJf3-Ds6_cUvWKo3DzBlb8o4ty41AieBQ4byOQ>
 <xme:YSZ2X5KvnJFI98_uNRJE89n48VbgHilW_yWe1xAJmEAVKIHt2VszIhHsI87kHw-tc
 i6pbRqEYDkpcLMcpJg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedujedrfeeggddufeegucetufdoteggodetrfdotf
 fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
 uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
 cujfgurhepfffhvffukfhfgggtugfgjgesthekredttddtjeenucfhrhhomhepvfihtghh
 ohcutehnuggvrhhsvghnuceothihtghhohesthihtghhohdrphhiiiiirgeqnecuggftrf
 grthhtvghrnhephfeuvddvleeiveeggeejueekueeljedtjeefteefueejfedvledttefh
 hfeukeffnecukfhppeejfedrvddujedruddtrdeitdenucevlhhushhtvghrufhiiigvpe
 dtnecurfgrrhgrmhepmhgrihhlfhhrohhmpehthigthhhosehthigthhhordhpihiiiigr
X-ME-Proxy: <xmx:YSZ2X1tFbDPM3jV86AKWVj2gldrMSRfYkbW-dWu7EJ38u3Xb6M8QKg>
 <xmx:YSZ2X-a1MEqFBm875iKjNBAXqENwyPQ-CZbWrDjZ1GwCziwqtM_CQg>
 <xmx:YSZ2X0bbdbrl1NPEBNDskCUWuTjwkPgT9N_KiGqk3Suy_dZFJ3nMoA>
 <xmx:YyZ2X0rL3WqWEU42QS71IgS-VqUZE0gAbbnzCHbHK1p5jaO9tNUVGFhnQGjv4E6G>
Received: from cisco (c-73-217-10-60.hsd1.co.comcast.net [73.217.10.60])
 by mail.messagingengine.com (Postfix) with ESMTPA id A23DD328005E;
 Thu,  1 Oct 2020 14:56:32 -0400 (EDT)
Date: Thu, 1 Oct 2020 12:56:31 -0600
From: Tycho Andersen <tycho@tycho.pizza>
To: Jann Horn <jannh@google.com>
Subject: Re: For review: seccomp_user_notif(2) manual page
Message-ID: <20201001185631.GD1260245@cisco>
References: <45f07f17-18b6-d187-0914-6f341fe90857@gmail.com>
 <CAG48ez3aqLs_-xgU0bThOLqRiiDWGObxcg-X9iFe6D5RDnLVJg@mail.gmail.com>
 <20201001125043.dj6taeieatpw3a4w@gmail.com>
 <CAG48ez2U1K2XYZu6goRYwmQ-RSu7LkKSOhPt8_wPVEUQfm7Eeg@mail.gmail.com>
 <20201001165850.GC1260245@cisco>
 <CAG48ez1W+Ym5=-PdUhyei_UCJov0agEF4YVyARL=pooWYmdEAg@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAG48ez1W+Ym5=-PdUhyei_UCJov0agEF4YVyARL=pooWYmdEAg@mail.gmail.com>
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

T24gVGh1LCBPY3QgMDEsIDIwMjAgYXQgMDg6MTg6NDlQTSArMDIwMCwgSmFubiBIb3JuIHdyb3Rl
Ogo+IE9uIFRodSwgT2N0IDEsIDIwMjAgYXQgNjo1OCBQTSBUeWNobyBBbmRlcnNlbiA8dHljaG9A
dHljaG8ucGl6emE+IHdyb3RlOgo+ID4gT24gVGh1LCBPY3QgMDEsIDIwMjAgYXQgMDU6NDc6NTRQ
TSArMDIwMCwgSmFubiBIb3JuIHZpYSBDb250YWluZXJzIHdyb3RlOgo+ID4gPiBPbiBUaHUsIE9j
dCAxLCAyMDIwIGF0IDI6NTQgUE0gQ2hyaXN0aWFuIEJyYXVuZXIKPiA+ID4gPGNocmlzdGlhbi5i
cmF1bmVyQGNhbm9uaWNhbC5jb20+IHdyb3RlOgo+ID4gPiA+IE9uIFdlZCwgU2VwIDMwLCAyMDIw
IGF0IDA1OjUzOjQ2UE0gKzAyMDAsIEphbm4gSG9ybiB2aWEgQ29udGFpbmVycyB3cm90ZToKPiA+
ID4gPiA+IE9uIFdlZCwgU2VwIDMwLCAyMDIwIGF0IDE6MDcgUE0gTWljaGFlbCBLZXJyaXNrICht
YW4tcGFnZXMpCj4gPiA+ID4gPiA8bXRrLm1hbnBhZ2VzQGdtYWlsLmNvbT4gd3JvdGU6Cj4gPiA+
ID4gPiA+IE5PVEVTCj4gPiA+ID4gPiA+ICAgICAgICBUaGUgZmlsZSBkZXNjcmlwdG9yIHJldHVy
bmVkIHdoZW4gc2VjY29tcCgyKSBpcyBlbXBsb3llZCB3aXRoIHRoZQo+ID4gPiA+ID4gPiAgICAg
ICAgU0VDQ09NUF9GSUxURVJfRkxBR19ORVdfTElTVEVORVIgIGZsYWcgIGNhbiAgYmUgIG1vbml0
b3JlZCAgdXNpbmcKPiA+ID4gPiA+ID4gICAgICAgIHBvbGwoMiksIGVwb2xsKDcpLCBhbmQgc2Vs
ZWN0KDIpLiAgV2hlbiBhIG5vdGlmaWNhdGlvbiAgaXMgIHBlbmTigJAKPiA+ID4gPiA+ID4gICAg
ICAgIGluZywgIHRoZXNlIGludGVyZmFjZXMgaW5kaWNhdGUgdGhhdCB0aGUgZmlsZSBkZXNjcmlw
dG9yIGlzIHJlYWTigJAKPiA+ID4gPiA+ID4gICAgICAgIGFibGUuCj4gPiA+ID4gPgo+ID4gPiA+
ID4gV2Ugc2hvdWxkIHByb2JhYmx5IGFsc28gcG9pbnQgb3V0IHNvbWV3aGVyZSB0aGF0LCBhcwo+
ID4gPiA+ID4gaW5jbHVkZS91YXBpL2xpbnV4L3NlY2NvbXAuaCBzYXlzOgo+ID4gPiA+ID4KPiA+
ID4gPiA+ICAqIFNpbWlsYXIgcHJlY2F1dGlvbnMgc2hvdWxkIGJlIGFwcGxpZWQgd2hlbiBzdGFj
a2luZyBTRUNDT01QX1JFVF9VU0VSX05PVElGCj4gPiA+ID4gPiAgKiBvciBTRUNDT01QX1JFVF9U
UkFDRS4gRm9yIFNFQ0NPTVBfUkVUX1VTRVJfTk9USUYgZmlsdGVycyBhY3Rpbmcgb24gdGhlCj4g
PiA+ID4gPiAgKiBzYW1lIHN5c2NhbGwsIHRoZSBtb3N0IHJlY2VudGx5IGFkZGVkIGZpbHRlciB0
YWtlcyBwcmVjZWRlbmNlLiBUaGlzIG1lYW5zCj4gPiA+ID4gPiAgKiB0aGF0IHRoZSBuZXcgU0VD
Q09NUF9SRVRfVVNFUl9OT1RJRiBmaWx0ZXIgY2FuIG92ZXJyaWRlIGFueQo+ID4gPiA+ID4gICog
U0VDQ09NUF9JT0NUTF9OT1RJRl9TRU5EIGZyb20gZWFybGllciBmaWx0ZXJzLCBlc3NlbnRpYWxs
eSBhbGxvd2luZyBhbGwKPiA+ID4gPiA+ICAqIHN1Y2ggZmlsdGVyZWQgc3lzY2FsbHMgdG8gYmUg
ZXhlY3V0ZWQgYnkgc2VuZGluZyB0aGUgcmVzcG9uc2UKPiA+ID4gPiA+ICAqIFNFQ0NPTVBfVVNF
Ul9OT1RJRl9GTEFHX0NPTlRJTlVFLiBOb3RlIHRoYXQgU0VDQ09NUF9SRVRfVFJBQ0UgY2FuIGVx
dWFsbHkKPiA+ID4gPiA+ICAqIGJlIG92ZXJyaWRlbiBieSBTRUNDT01QX1VTRVJfTk9USUZfRkxB
R19DT05USU5VRS4KPiA+ID4gPiA+Cj4gPiA+ID4gPiBJbiBvdGhlciB3b3JkcywgZnJvbSBhIHNl
Y3VyaXR5IHBlcnNwZWN0aXZlLCB5b3UgbXVzdCBhc3N1bWUgdGhhdCB0aGUKPiA+ID4gPiA+IHRh
cmdldCBwcm9jZXNzIGNhbiBieXBhc3MgYW55IFNFQ0NPTVBfUkVUX1VTRVJfTk9USUYgKG9yCj4g
PiA+ID4gPiBTRUNDT01QX1JFVF9UUkFDRSkgZmlsdGVycyB1bmxlc3MgaXQgaXMgY29tcGxldGVs
eSBwcm9oaWJpdGVkIGZyb20KPiA+ID4gPiA+IGNhbGxpbmcgc2VjY29tcCgpLiBUaGlzIHNob3Vs
ZCBhbHNvIGJlIG5vdGVkIG92ZXIgaW4gdGhlIG1haW4KPiA+ID4gPiA+IHNlY2NvbXAoMikgbWFu
cGFnZSwgZXNwZWNpYWxseSB0aGUgU0VDQ09NUF9SRVRfVFJBQ0UgcGFydC4KPiA+ID4gPgo+ID4g
PiA+IFNvIEkgd2FzIGFjdHVhbGx5IHdvbmRlcmluZyBhYm91dCB0aGlzIHdoZW4gSSBza2ltbWVk
IHRoaXMgYW5kIGEgd2hpbGUKPiA+ID4gPiBhZ28gYnV0IGZvcmdvdCBhYm91dCB0aGlzIGFnYWlu
Li4uIEFmYWljdCwgeW91IGNhbiBvbmx5IGV2ZXIgbG9hZCBhCj4gPiA+ID4gc2luZ2xlIGZpbHRl
ciB3aXRoIFNFQ0NPTVBfRklMVEVSX0ZMQUdfTkVXX0xJU1RFTkVSIHNldC4gSWYgdGhlcmUKPiA+
ID4gPiBhbHJlYWR5IGlzIGEgZmlsdGVyIHdpdGggdGhlIFNFQ0NPTVBfRklMVEVSX0ZMQUdfTkVX
X0xJU1RFTkVSIHByb3BlcnR5Cj4gPiA+ID4gaW4gdGhlIHRhc2tzIGZpbHRlciBoaWVyYXJjaHkg
dGhlbiB0aGUga2VybmVsIHdpbGwgcmVmdXNlIHRvIGxvYWQgYSBuZXcKPiA+ID4gPiBvbmU/Cj4g
PiA+ID4KPiA+ID4gPiBzdGF0aWMgc3RydWN0IGZpbGUgKmluaXRfbGlzdGVuZXIoc3RydWN0IHNl
Y2NvbXBfZmlsdGVyICpmaWx0ZXIpCj4gPiA+ID4gewo+ID4gPiA+ICAgICAgICAgc3RydWN0IGZp
bGUgKnJldCA9IEVSUl9QVFIoLUVCVVNZKTsKPiA+ID4gPiAgICAgICAgIHN0cnVjdCBzZWNjb21w
X2ZpbHRlciAqY3VyOwo+ID4gPiA+Cj4gPiA+ID4gICAgICAgICBmb3IgKGN1ciA9IGN1cnJlbnQt
PnNlY2NvbXAuZmlsdGVyOyBjdXI7IGN1ciA9IGN1ci0+cHJldikgewo+ID4gPiA+ICAgICAgICAg
ICAgICAgICBpZiAoY3VyLT5ub3RpZikKPiA+ID4gPiAgICAgICAgICAgICAgICAgICAgICAgICBn
b3RvIG91dDsKPiA+ID4gPiAgICAgICAgIH0KPiA+ID4gPgo+ID4gPiA+IHNob3VsZG4ndCB0aGF0
IGJlIHN1ZmZpY2llbnQgdG8gZ3VhcmFudGVlIHRoYXQgVVNFUl9OT1RJRiBmaWx0ZXJzIGNhbid0
Cj4gPiA+ID4gb3ZlcnJpZGUgZWFjaCBvdGhlciBmb3IgdGhlIHNhbWUgdGFzayBzaW1wbHkgYmVj
YXVzZSB0aGVyZSBjYW4gb25seSBldmVyCj4gPiA+ID4gYmUgYSBzaW5nbGUgb25lPwo+ID4gPgo+
ID4gPiBHb29kIHBvaW50LiBFeGNlZWVlcHQgdGhhdCB0aGF0IGNoZWNrIHNlZW1zIGluZWZmZWN0
aXZlIGJlY2F1c2UgdGhpcwo+ID4gPiBoYXBwZW5zIGJlZm9yZSB3ZSB0YWtlIHRoZSBsb2NrcyB0
aGF0IGd1YXJkIGFnYWluc3QgVFNZTkMsIGFuZCBhbHNvCj4gPiA+IGJlZm9yZSB3ZSBkZWNpZGUg
dG8gd2hpY2ggZXhpc3RpbmcgZmlsdGVyIHdlIHdhbnQgdG8gY2hhaW4gdGhlIG5ldwo+ID4gPiBm
aWx0ZXIuIFNvIGlmIHR3byB0aHJlYWRzIHJhY2Ugd2l0aCBUU1lOQywgSSB0aGluayB0aGV5J2xs
IGJlIGFibGUgdG8KPiA+ID4gY2hhaW4gdHdvIGZpbHRlcnMgd2l0aCBsaXN0ZW5lcnMgdG9nZXRo
ZXIuCj4gPgo+ID4gWWVwLCBzZWVtcyB0aGUgY2hlY2sgbmVlZHMgdG8gYWxzbyBiZSBpbiBzZWNj
b21wX2Nhbl9zeW5jX3RocmVhZHMoKSB0bwo+ID4gYmUgdG90YWxseSBlZmZlY3RpdmUsCj4gPgo+
ID4gPiBJIGRvbid0IGtub3cgd2hldGhlciB3ZSB3YW50IHRvIGV0ZXJuYWxpemUgdGhpcyAib25s
eSBvbmUgbGlzdGVuZXIKPiA+ID4gYWNyb3NzIGFsbCB0aGUgZmlsdGVycyIgcmVzdHJpY3Rpb24g
aW4gdGhlIG1hbnBhZ2UgdGhvdWdoLCBvciB3aGV0aGVyCj4gPiA+IHRoZSBtYW4gcGFnZSBzaG91
bGQganVzdCBzYXkgdGhhdCB0aGUga2VybmVsIGN1cnJlbnRseSBkb2Vzbid0IHN1cHBvcnQKPiA+
ID4gaXQgYnV0IHRoYXQgc2VjdXJpdHktd2lzZSB5b3Ugc2hvdWxkIGFzc3VtZSB0aGF0IGl0IG1p
Z2h0IGF0IHNvbWUKPiA+ID4gcG9pbnQuCj4gPgo+ID4gVGhpcyByZXF1aXJlbWVudCBvcmlnaW5h
bGx5IGNhbWUgZnJvbSBBbmR5LCBhcmd1aW5nIHRoYXQgdGhlIHNlbWFudGljcwo+ID4gb2YgdGhp
cyB3ZXJlL2FyZSBjb25mdXNpbmcsIHdoaWNoIHN0aWxsIG1ha2VzIHNlbnNlIHRvIG1lLiBQZXJo
YXBzIHdlCj4gPiBzaG91bGQgZG8gc29tZXRoaW5nIGxpa2UgdGhlIGJlbG93Pwo+IFsuLi5dCj4g
PiArc3RhdGljIGJvb2wgaGFzX2xpc3RlbmVyX3BhcmVudChzdHJ1Y3Qgc2VjY29tcF9maWx0ZXIg
KmNoaWxkKQo+ID4gK3sKPiA+ICsgICAgICAgc3RydWN0IHNlY2NvbXBfZmlsdGVyICpjdXI7Cj4g
PiArCj4gPiArICAgICAgIGZvciAoY3VyID0gY3VycmVudC0+c2VjY29tcC5maWx0ZXI7IGN1cjsg
Y3VyID0gY3VyLT5wcmV2KSB7Cj4gPiArICAgICAgICAgICAgICAgaWYgKGN1ci0+bm90aWYpCj4g
PiArICAgICAgICAgICAgICAgICAgICAgICByZXR1cm4gdHJ1ZTsKPiA+ICsgICAgICAgfQo+ID4g
Kwo+ID4gKyAgICAgICByZXR1cm4gZmFsc2U7Cj4gPiArfQo+IFsuLi5dCj4gPiBAQCAtNDA3LDYg
KzQxOSwxMSBAQCBzdGF0aWMgaW5saW5lIHBpZF90IHNlY2NvbXBfY2FuX3N5bmNfdGhyZWFkcyh2
b2lkKQo+IFsuLi5dCj4gPiArICAgICAgICAgICAgICAgLyogZG9uJ3QgYWxsb3cgVFNZTkMgdG8g
aW5zdGFsbCBtdWx0aXBsZSBsaXN0ZW5lcnMgKi8KPiA+ICsgICAgICAgICAgICAgICBpZiAoZmxh
Z3MgJiBTRUNDT01QX0ZJTFRFUl9GTEFHX05FV19MSVNURU5FUiAmJgo+ID4gKyAgICAgICAgICAg
ICAgICAgICAhaGFzX2xpc3RlbmVyX3BhcmVudCh0aHJlYWQtPnNlY2NvbXAuZmlsdGVyKSkKPiA+
ICsgICAgICAgICAgICAgICAgICAgICAgIGNvbnRpbnVlOwo+IFsuLi5dCj4gPiBAQCAtMTQ2Miwx
MiArMTQ3OSw5IEBAIHN0YXRpYyBjb25zdCBzdHJ1Y3QgZmlsZV9vcGVyYXRpb25zIHNlY2NvbXBf
bm90aWZ5X29wcyA9IHsKPiA+ICBzdGF0aWMgc3RydWN0IGZpbGUgKmluaXRfbGlzdGVuZXIoc3Ry
dWN0IHNlY2NvbXBfZmlsdGVyICpmaWx0ZXIpCj4gWy4uLl0KPiA+IC0gICAgICAgZm9yIChjdXIg
PSBjdXJyZW50LT5zZWNjb21wLmZpbHRlcjsgY3VyOyBjdXIgPSBjdXItPnByZXYpIHsKPiA+IC0g
ICAgICAgICAgICAgICBpZiAoY3VyLT5ub3RpZikKPiA+IC0gICAgICAgICAgICAgICAgICAgICAg
IGdvdG8gb3V0Owo+ID4gLSAgICAgICB9Cj4gPiArICAgICAgIGlmIChoYXNfbGlzdGVuZXJfcGFy
ZW50KGN1cnJlbnQtPnNlY2NvbXAuZmlsdGVyKSkKPiA+ICsgICAgICAgICAgICAgICBnb3RvIG91
dDsKPiAKPiBJIGRpc2xpa2UgdGhpcyBiZWNhdXNlIGl0IGNvbWJpbmVzIGEgbm9uLWxvY2tlZCBj
aGVjayBhbmQgYSBsb2NrZWQKPiBjaGVjay4gQW5kIEkgZG9uJ3QgdGhpbmsgdGhpcyB3aWxsIHdv
cmsgaW4gdGhlIGNhc2Ugd2hlcmUgVFNZTkMgYW5kCj4gbm9uLVRTWU5DIHJhY2UgLSBpZiB0aGUg
bm9uLVRTWU5DIGNhbGwgbmVzdHMgYXJvdW5kIHRoZSBUU1lOQyBmaWx0ZXIKPiBpbnN0YWxsYXRp
b24sIHRoZSB0aHJlYWQgdGhhdCBjYWxsZWQgc2VjY29tcCBpbiBub24tVFNZTkMgbW9kZSB3aWxs
Cj4gc3RpbGwgZW5kIHVwIHdpdGggdHdvIG5vdGlmeWluZyBmaWx0ZXJzLiBIb3cgYWJvdXQgdGhl
IGZvbGxvd2luZz8KClN1cmUsIHlvdSBjYW4gYWRkLAoKUmV2aWV3ZWQtYnk6IFR5Y2hvIEFuZGVy
c2VuIDx0eWNob0B0eWNoby5waXp6YT4KCndoZW4geW91IHNlbmQgaXQuCgpUeWNobwpfX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpDb250YWluZXJzIG1haWxp
bmcgbGlzdApDb250YWluZXJzQGxpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnCmh0dHBzOi8vbGlz
dHMubGludXhmb3VuZGF0aW9uLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2NvbnRhaW5lcnM=
