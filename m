Return-Path: <SRS0=WbUC=DI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10ACEC4727E
	for <containers@archiver.kernel.org>; Thu,  1 Oct 2020 17:06:00 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7ABE120796
	for <containers@archiver.kernel.org>; Thu,  1 Oct 2020 17:05:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7ABE120796
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=canonical.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 04094226F3;
	Thu,  1 Oct 2020 17:05:59 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ct+vNx6NvWu0; Thu,  1 Oct 2020 17:05:56 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id B649A204A9;
	Thu,  1 Oct 2020 17:05:56 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 93F0CC0889;
	Thu,  1 Oct 2020 17:05:56 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 842ADC0051
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 17:05:55 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 6B7A187313
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 17:05:55 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id ljQks8+aOWKa
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 17:05:54 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by hemlock.osuosl.org (Postfix) with ESMTP id 1ED5887311
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 17:05:54 +0000 (UTC)
Received: from mail-ed1-f72.google.com ([209.85.208.72])
 by youngberry.canonical.com with esmtps
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@canonical.com>) id 1kO21f-0007Sb-RS
 for containers@lists.linux-foundation.org; Thu, 01 Oct 2020 17:05:51 +0000
Received: by mail-ed1-f72.google.com with SMTP id n25so2469020edr.13
 for <containers@lists.linux-foundation.org>;
 Thu, 01 Oct 2020 10:05:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:content-transfer-encoding
 :in-reply-to;
 bh=Aap9MP/HBi9/qankX0BesgfqzXvo4bvGgH/pO8G9acQ=;
 b=PR+DtmCEQ7G0laUxf03HEgbrj/r3J670rSpxiHyZpNpuHaPBEEZJuTIrIsx5xjnt/6
 IDBXGcgQjObrRzwh8Pu5+CnHP0XcDeNCrWo0S92/XakrAl6lETwOMCUPPNISUXinUHvf
 QBKRpo+EKELj6ARyOWtX2YRRz2CQUi2pRXGOTE97R3ZllGek2y7FYhd0RH93vMksy6OI
 p0AyqtiwBZdDRREvDaefAjNdQf7oFigObDC8DpegK5QQFbosCN0ul8TcotsMIgzuI1oi
 stQUC+zmZuqiVpan2WAU3ZFStrBRkDo8aTZ9iIwjKvGYEd7GIaQV1rbH/3obr6gy/xWc
 Ge0A==
X-Gm-Message-State: AOAM531G18N1Ol+vop8wAnJX5FQ5UkK0/2Mhr8xPA9Xe1HR1KWxbMXFR
 CxSt/sdH3qlRVUT9ZBhy5zwvU6k/8VSgKVm3NESyCm+mshhdFS0s51wRWUPbt+BhQLw2b93qeUu
 p1ZWeJfFSkRbKaxH0uL82MffHcSEd0HoC5K1cmd3q6QxzDc/K/mgcWA==
X-Received: by 2002:a17:906:71cc:: with SMTP id
 i12mr9027282ejk.507.1601571951466; 
 Thu, 01 Oct 2020 10:05:51 -0700 (PDT)
X-Google-Smtp-Source: ABdhPJy2qQHjfUA/p72XDvjFE/grmCBGTMHvF+wL+iK51zUzW2MkqzKMh3QQkZ07n2iwyU6nbvl5MA==
X-Received: by 2002:a17:906:71cc:: with SMTP id
 i12mr9027243ejk.507.1601571951125; 
 Thu, 01 Oct 2020 10:05:51 -0700 (PDT)
Received: from gmail.com ([176.32.19.8])
 by smtp.gmail.com with ESMTPSA id s7sm4481136ejd.103.2020.10.01.10.05.49
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Thu, 01 Oct 2020 10:05:50 -0700 (PDT)
Date: Thu, 1 Oct 2020 19:05:43 +0200
From: Christian Brauner <christian.brauner@canonical.com>
To: Jann Horn <jannh@google.com>
Subject: Re: For review: seccomp_user_notif(2) manual page
Message-ID: <20201001170501.7umqgtfdx6jenkla@gmail.com>
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

T24gVGh1LCBPY3QgMDEsIDIwMjAgYXQgMDU6NDc6NTRQTSArMDIwMCwgSmFubiBIb3JuIHdyb3Rl
Ogo+IE9uIFRodSwgT2N0IDEsIDIwMjAgYXQgMjo1NCBQTSBDaHJpc3RpYW4gQnJhdW5lcgo+IDxj
aHJpc3RpYW4uYnJhdW5lckBjYW5vbmljYWwuY29tPiB3cm90ZToKPiA+IE9uIFdlZCwgU2VwIDMw
LCAyMDIwIGF0IDA1OjUzOjQ2UE0gKzAyMDAsIEphbm4gSG9ybiB2aWEgQ29udGFpbmVycyB3cm90
ZToKPiA+ID4gT24gV2VkLCBTZXAgMzAsIDIwMjAgYXQgMTowNyBQTSBNaWNoYWVsIEtlcnJpc2sg
KG1hbi1wYWdlcykKPiA+ID4gPG10ay5tYW5wYWdlc0BnbWFpbC5jb20+IHdyb3RlOgo+ID4gPiA+
IE5PVEVTCj4gPiA+ID4gICAgICAgIFRoZSBmaWxlIGRlc2NyaXB0b3IgcmV0dXJuZWQgd2hlbiBz
ZWNjb21wKDIpIGlzIGVtcGxveWVkIHdpdGggdGhlCj4gPiA+ID4gICAgICAgIFNFQ0NPTVBfRklM
VEVSX0ZMQUdfTkVXX0xJU1RFTkVSICBmbGFnICBjYW4gIGJlICBtb25pdG9yZWQgIHVzaW5nCj4g
PiA+ID4gICAgICAgIHBvbGwoMiksIGVwb2xsKDcpLCBhbmQgc2VsZWN0KDIpLiAgV2hlbiBhIG5v
dGlmaWNhdGlvbiAgaXMgIHBlbmTigJAKPiA+ID4gPiAgICAgICAgaW5nLCAgdGhlc2UgaW50ZXJm
YWNlcyBpbmRpY2F0ZSB0aGF0IHRoZSBmaWxlIGRlc2NyaXB0b3IgaXMgcmVhZOKAkAo+ID4gPiA+
ICAgICAgICBhYmxlLgo+ID4gPgo+ID4gPiBXZSBzaG91bGQgcHJvYmFibHkgYWxzbyBwb2ludCBv
dXQgc29tZXdoZXJlIHRoYXQsIGFzCj4gPiA+IGluY2x1ZGUvdWFwaS9saW51eC9zZWNjb21wLmgg
c2F5czoKPiA+ID4KPiA+ID4gICogU2ltaWxhciBwcmVjYXV0aW9ucyBzaG91bGQgYmUgYXBwbGll
ZCB3aGVuIHN0YWNraW5nIFNFQ0NPTVBfUkVUX1VTRVJfTk9USUYKPiA+ID4gICogb3IgU0VDQ09N
UF9SRVRfVFJBQ0UuIEZvciBTRUNDT01QX1JFVF9VU0VSX05PVElGIGZpbHRlcnMgYWN0aW5nIG9u
IHRoZQo+ID4gPiAgKiBzYW1lIHN5c2NhbGwsIHRoZSBtb3N0IHJlY2VudGx5IGFkZGVkIGZpbHRl
ciB0YWtlcyBwcmVjZWRlbmNlLiBUaGlzIG1lYW5zCj4gPiA+ICAqIHRoYXQgdGhlIG5ldyBTRUND
T01QX1JFVF9VU0VSX05PVElGIGZpbHRlciBjYW4gb3ZlcnJpZGUgYW55Cj4gPiA+ICAqIFNFQ0NP
TVBfSU9DVExfTk9USUZfU0VORCBmcm9tIGVhcmxpZXIgZmlsdGVycywgZXNzZW50aWFsbHkgYWxs
b3dpbmcgYWxsCj4gPiA+ICAqIHN1Y2ggZmlsdGVyZWQgc3lzY2FsbHMgdG8gYmUgZXhlY3V0ZWQg
Ynkgc2VuZGluZyB0aGUgcmVzcG9uc2UKPiA+ID4gICogU0VDQ09NUF9VU0VSX05PVElGX0ZMQUdf
Q09OVElOVUUuIE5vdGUgdGhhdCBTRUNDT01QX1JFVF9UUkFDRSBjYW4gZXF1YWxseQo+ID4gPiAg
KiBiZSBvdmVycmlkZW4gYnkgU0VDQ09NUF9VU0VSX05PVElGX0ZMQUdfQ09OVElOVUUuCj4gPiA+
Cj4gPiA+IEluIG90aGVyIHdvcmRzLCBmcm9tIGEgc2VjdXJpdHkgcGVyc3BlY3RpdmUsIHlvdSBt
dXN0IGFzc3VtZSB0aGF0IHRoZQo+ID4gPiB0YXJnZXQgcHJvY2VzcyBjYW4gYnlwYXNzIGFueSBT
RUNDT01QX1JFVF9VU0VSX05PVElGIChvcgo+ID4gPiBTRUNDT01QX1JFVF9UUkFDRSkgZmlsdGVy
cyB1bmxlc3MgaXQgaXMgY29tcGxldGVseSBwcm9oaWJpdGVkIGZyb20KPiA+ID4gY2FsbGluZyBz
ZWNjb21wKCkuIFRoaXMgc2hvdWxkIGFsc28gYmUgbm90ZWQgb3ZlciBpbiB0aGUgbWFpbgo+ID4g
PiBzZWNjb21wKDIpIG1hbnBhZ2UsIGVzcGVjaWFsbHkgdGhlIFNFQ0NPTVBfUkVUX1RSQUNFIHBh
cnQuCj4gPgo+ID4gU28gSSB3YXMgYWN0dWFsbHkgd29uZGVyaW5nIGFib3V0IHRoaXMgd2hlbiBJ
IHNraW1tZWQgdGhpcyBhbmQgYSB3aGlsZQo+ID4gYWdvIGJ1dCBmb3Jnb3QgYWJvdXQgdGhpcyBh
Z2Fpbi4uLiBBZmFpY3QsIHlvdSBjYW4gb25seSBldmVyIGxvYWQgYQo+ID4gc2luZ2xlIGZpbHRl
ciB3aXRoIFNFQ0NPTVBfRklMVEVSX0ZMQUdfTkVXX0xJU1RFTkVSIHNldC4gSWYgdGhlcmUKPiA+
IGFscmVhZHkgaXMgYSBmaWx0ZXIgd2l0aCB0aGUgU0VDQ09NUF9GSUxURVJfRkxBR19ORVdfTElT
VEVORVIgcHJvcGVydHkKPiA+IGluIHRoZSB0YXNrcyBmaWx0ZXIgaGllcmFyY2h5IHRoZW4gdGhl
IGtlcm5lbCB3aWxsIHJlZnVzZSB0byBsb2FkIGEgbmV3Cj4gPiBvbmU/Cj4gPgo+ID4gc3RhdGlj
IHN0cnVjdCBmaWxlICppbml0X2xpc3RlbmVyKHN0cnVjdCBzZWNjb21wX2ZpbHRlciAqZmlsdGVy
KQo+ID4gewo+ID4gICAgICAgICBzdHJ1Y3QgZmlsZSAqcmV0ID0gRVJSX1BUUigtRUJVU1kpOwo+
ID4gICAgICAgICBzdHJ1Y3Qgc2VjY29tcF9maWx0ZXIgKmN1cjsKPiA+Cj4gPiAgICAgICAgIGZv
ciAoY3VyID0gY3VycmVudC0+c2VjY29tcC5maWx0ZXI7IGN1cjsgY3VyID0gY3VyLT5wcmV2KSB7
Cj4gPiAgICAgICAgICAgICAgICAgaWYgKGN1ci0+bm90aWYpCj4gPiAgICAgICAgICAgICAgICAg
ICAgICAgICBnb3RvIG91dDsKPiA+ICAgICAgICAgfQo+ID4KPiA+IHNob3VsZG4ndCB0aGF0IGJl
IHN1ZmZpY2llbnQgdG8gZ3VhcmFudGVlIHRoYXQgVVNFUl9OT1RJRiBmaWx0ZXJzIGNhbid0Cj4g
PiBvdmVycmlkZSBlYWNoIG90aGVyIGZvciB0aGUgc2FtZSB0YXNrIHNpbXBseSBiZWNhdXNlIHRo
ZXJlIGNhbiBvbmx5IGV2ZXIKPiA+IGJlIGEgc2luZ2xlIG9uZT8KPiAKPiBHb29kIHBvaW50LiBF
eGNlZWVlcHQgdGhhdCB0aGF0IGNoZWNrIHNlZW1zIGluZWZmZWN0aXZlIGJlY2F1c2UgdGhpcwo+
IGhhcHBlbnMgYmVmb3JlIHdlIHRha2UgdGhlIGxvY2tzIHRoYXQgZ3VhcmQgYWdhaW5zdCBUU1lO
QywgYW5kIGFsc28KPiBiZWZvcmUgd2UgZGVjaWRlIHRvIHdoaWNoIGV4aXN0aW5nIGZpbHRlciB3
ZSB3YW50IHRvIGNoYWluIHRoZSBuZXcKPiBmaWx0ZXIuIFNvIGlmIHR3byB0aHJlYWRzIHJhY2Ug
d2l0aCBUU1lOQywgSSB0aGluayB0aGV5J2xsIGJlIGFibGUgdG8KPiBjaGFpbiB0d28gZmlsdGVy
cyB3aXRoIGxpc3RlbmVycyB0b2dldGhlci4KClRoYXQncyBhIGJ1ZywgaW1oby4gSSBkb24ndCBo
YXZlIHNvdXJjZSBjb2RlIGluIGZyb250IG9mIG1lIHJpZ2h0IG5vdwp0aG91Z2guCgo+IAo+IEkg
ZG9uJ3Qga25vdyB3aGV0aGVyIHdlIHdhbnQgdG8gZXRlcm5hbGl6ZSB0aGlzICJvbmx5IG9uZSBs
aXN0ZW5lcgo+IGFjcm9zcyBhbGwgdGhlIGZpbHRlcnMiIHJlc3RyaWN0aW9uIGluIHRoZSBtYW5w
YWdlIHRob3VnaCwgb3Igd2hldGhlcgo+IHRoZSBtYW4gcGFnZSBzaG91bGQganVzdCBzYXkgdGhh
dCB0aGUga2VybmVsIGN1cnJlbnRseSBkb2Vzbid0IHN1cHBvcnQKPiBpdCBidXQgdGhhdCBzZWN1
cml0eS13aXNlIHlvdSBzaG91bGQgYXNzdW1lIHRoYXQgaXQgbWlnaHQgYXQgc29tZQo+IHBvaW50
LgoKTWF5YmUuIEkgd291bGQgYXJndWUgdGhhdCBpdCBtaWdodCBiZSB3b3J0aCBoYXZpbmcgYXQg
bGVhc3QgYSBuZXcKZmxhZy9vcHRpb24gdG8gaW5kaWNhdGUgZWl0aGVyICJUaGlzIGlzIGEgbm9u
LW92ZXJyaWRhYmxlIGZpbHRlci4iIG9yIGF0CmxlYXN0IGZvciB0aGUgc2VjY29tcCBub3RpZmll
ciBoYXZlIGFuIG9wdGlvbiB0byBpbmRpY2F0ZSB0aGF0IG5vIG90aGVyCm5vdGlmZXIgY2FuIGJl
IGluc3RhbGxlZC4KCkNocmlzdGlhbgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fXwpDb250YWluZXJzIG1haWxpbmcgbGlzdApDb250YWluZXJzQGxpc3RzLmxp
bnV4LWZvdW5kYXRpb24ub3JnCmh0dHBzOi8vbGlzdHMubGludXhmb3VuZGF0aW9uLm9yZy9tYWls
bWFuL2xpc3RpbmZvL2NvbnRhaW5lcnM=
