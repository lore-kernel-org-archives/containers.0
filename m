Return-Path: <SRS0=WbUC=DI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEF90C47420
	for <containers@archiver.kernel.org>; Thu,  1 Oct 2020 17:12:17 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 32AD12085B
	for <containers@archiver.kernel.org>; Thu,  1 Oct 2020 17:12:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32AD12085B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=canonical.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id B724E229D4;
	Thu,  1 Oct 2020 17:12:16 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 6YsXM9k9GZv4; Thu,  1 Oct 2020 17:12:14 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 7AF77204A9;
	Thu,  1 Oct 2020 17:12:14 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 630D3C016F;
	Thu,  1 Oct 2020 17:12:14 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 7B379C0051
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 17:12:13 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 663F886B2C
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 17:12:13 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 8yWz8sODDpBK
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 17:12:12 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 16E8386B2B
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 17:12:12 +0000 (UTC)
Received: from mail-ej1-f70.google.com ([209.85.218.70])
 by youngberry.canonical.com with esmtps
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@canonical.com>) id 1kO27m-00081g-9K
 for containers@lists.linux-foundation.org; Thu, 01 Oct 2020 17:12:10 +0000
Received: by mail-ej1-f70.google.com with SMTP id w10so2504859ejq.11
 for <containers@lists.linux-foundation.org>;
 Thu, 01 Oct 2020 10:12:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:content-transfer-encoding
 :in-reply-to;
 bh=R1wJmFfDlNS2ZK16MyLmhBE/huODDJnjpuBQkOKkIq0=;
 b=mX6gP5vRkJnKir2CUY1+tz3yAEw8giWLsj6IzdFaI9twHs0r8+p0oH+LPUY8i1rpfR
 4HR9EHSWqp1X55VqqIDgU53DX8WwaKsIacl2tz+s7oKQKFuyYG5wU+Cj+N1wVe69zbKV
 P1lMGShddjtVz3h9D1SfzH3IH1UIbYS0GSuHp7KuBIAKTTUVXKNQLJt2QSfU+UNpjvfn
 yqKhHyGXFVtEvin7Raqb5V7c310YPobYdCEtwDi7vMMOmLEj4+LWCfI8L1WVr9f8HnxG
 qcw3F1fQiycOVJEp845lHXt3ZxJxajyqrFk8IsJEqClRnQEfdLsX9VoR0fiytftnDLzi
 oh9A==
X-Gm-Message-State: AOAM530m0le5iZieDX89ngCb1CSqgYyIetnxb2yBBtZXDE7JJiuxqUa1
 d2c8eWJubaeJDodoJTjh46Nw+PTQUoNIfeuGUOLTpSMaZ0Z95U5qBHIfI2Rg1ZwIpucvTrCbVDu
 1T+B4f2ijzGufuR+VBjlN/SQvnqVIIe3Wnx5IlATi0BbUTxSyKejQsg==
X-Received: by 2002:a17:906:b74a:: with SMTP id
 fx10mr8883939ejb.232.1601572329843; 
 Thu, 01 Oct 2020 10:12:09 -0700 (PDT)
X-Google-Smtp-Source: ABdhPJw4vHLdiKnihkbjdlGKbr1buFcgisWIoA1Dsbv/iU/iTwRqIjmoZt3gmk1xWndAA0SxTZa58g==
X-Received: by 2002:a17:906:b74a:: with SMTP id
 fx10mr8883899ejb.232.1601572329483; 
 Thu, 01 Oct 2020 10:12:09 -0700 (PDT)
Received: from gmail.com ([176.32.19.8])
 by smtp.gmail.com with ESMTPSA id d24sm4644094edp.17.2020.10.01.10.12.07
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Thu, 01 Oct 2020 10:12:08 -0700 (PDT)
Date: Thu, 1 Oct 2020 19:12:06 +0200
From: Christian Brauner <christian.brauner@canonical.com>
To: Tycho Andersen <tycho@tycho.pizza>
Subject: Re: For review: seccomp_user_notif(2) manual page
Message-ID: <20201001171206.jvkdx4htqux5agdv@gmail.com>
References: <45f07f17-18b6-d187-0914-6f341fe90857@gmail.com>
 <CAG48ez3aqLs_-xgU0bThOLqRiiDWGObxcg-X9iFe6D5RDnLVJg@mail.gmail.com>
 <20201001125043.dj6taeieatpw3a4w@gmail.com>
 <CAG48ez2U1K2XYZu6goRYwmQ-RSu7LkKSOhPt8_wPVEUQfm7Eeg@mail.gmail.com>
 <20201001165850.GC1260245@cisco>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20201001165850.GC1260245@cisco>
Cc: linux-man <linux-man@vger.kernel.org>, Song Liu <songliubraving@fb.com>,
 Will Drewry <wad@chromium.org>, Kees Cook <keescook@chromium.org>,
 Daniel Borkmann <daniel@iogearbox.net>, Jann Horn <jannh@google.com>,
 Robert Sesek <rsesek@google.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 lkml <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
 "Michael Kerrisk \(man-pages\)" <mtk.manpages@gmail.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, bpf <bpf@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>,
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

T24gVGh1LCBPY3QgMDEsIDIwMjAgYXQgMTA6NTg6NTBBTSAtMDYwMCwgVHljaG8gQW5kZXJzZW4g
d3JvdGU6Cj4gT24gVGh1LCBPY3QgMDEsIDIwMjAgYXQgMDU6NDc6NTRQTSArMDIwMCwgSmFubiBI
b3JuIHZpYSBDb250YWluZXJzIHdyb3RlOgo+ID4gT24gVGh1LCBPY3QgMSwgMjAyMCBhdCAyOjU0
IFBNIENocmlzdGlhbiBCcmF1bmVyCj4gPiA8Y2hyaXN0aWFuLmJyYXVuZXJAY2Fub25pY2FsLmNv
bT4gd3JvdGU6Cj4gPiA+IE9uIFdlZCwgU2VwIDMwLCAyMDIwIGF0IDA1OjUzOjQ2UE0gKzAyMDAs
IEphbm4gSG9ybiB2aWEgQ29udGFpbmVycyB3cm90ZToKPiA+ID4gPiBPbiBXZWQsIFNlcCAzMCwg
MjAyMCBhdCAxOjA3IFBNIE1pY2hhZWwgS2VycmlzayAobWFuLXBhZ2VzKQo+ID4gPiA+IDxtdGsu
bWFucGFnZXNAZ21haWwuY29tPiB3cm90ZToKPiA+ID4gPiA+IE5PVEVTCj4gPiA+ID4gPiAgICAg
ICAgVGhlIGZpbGUgZGVzY3JpcHRvciByZXR1cm5lZCB3aGVuIHNlY2NvbXAoMikgaXMgZW1wbG95
ZWQgd2l0aCB0aGUKPiA+ID4gPiA+ICAgICAgICBTRUNDT01QX0ZJTFRFUl9GTEFHX05FV19MSVNU
RU5FUiAgZmxhZyAgY2FuICBiZSAgbW9uaXRvcmVkICB1c2luZwo+ID4gPiA+ID4gICAgICAgIHBv
bGwoMiksIGVwb2xsKDcpLCBhbmQgc2VsZWN0KDIpLiAgV2hlbiBhIG5vdGlmaWNhdGlvbiAgaXMg
IHBlbmTigJAKPiA+ID4gPiA+ICAgICAgICBpbmcsICB0aGVzZSBpbnRlcmZhY2VzIGluZGljYXRl
IHRoYXQgdGhlIGZpbGUgZGVzY3JpcHRvciBpcyByZWFk4oCQCj4gPiA+ID4gPiAgICAgICAgYWJs
ZS4KPiA+ID4gPgo+ID4gPiA+IFdlIHNob3VsZCBwcm9iYWJseSBhbHNvIHBvaW50IG91dCBzb21l
d2hlcmUgdGhhdCwgYXMKPiA+ID4gPiBpbmNsdWRlL3VhcGkvbGludXgvc2VjY29tcC5oIHNheXM6
Cj4gPiA+ID4KPiA+ID4gPiAgKiBTaW1pbGFyIHByZWNhdXRpb25zIHNob3VsZCBiZSBhcHBsaWVk
IHdoZW4gc3RhY2tpbmcgU0VDQ09NUF9SRVRfVVNFUl9OT1RJRgo+ID4gPiA+ICAqIG9yIFNFQ0NP
TVBfUkVUX1RSQUNFLiBGb3IgU0VDQ09NUF9SRVRfVVNFUl9OT1RJRiBmaWx0ZXJzIGFjdGluZyBv
biB0aGUKPiA+ID4gPiAgKiBzYW1lIHN5c2NhbGwsIHRoZSBtb3N0IHJlY2VudGx5IGFkZGVkIGZp
bHRlciB0YWtlcyBwcmVjZWRlbmNlLiBUaGlzIG1lYW5zCj4gPiA+ID4gICogdGhhdCB0aGUgbmV3
IFNFQ0NPTVBfUkVUX1VTRVJfTk9USUYgZmlsdGVyIGNhbiBvdmVycmlkZSBhbnkKPiA+ID4gPiAg
KiBTRUNDT01QX0lPQ1RMX05PVElGX1NFTkQgZnJvbSBlYXJsaWVyIGZpbHRlcnMsIGVzc2VudGlh
bGx5IGFsbG93aW5nIGFsbAo+ID4gPiA+ICAqIHN1Y2ggZmlsdGVyZWQgc3lzY2FsbHMgdG8gYmUg
ZXhlY3V0ZWQgYnkgc2VuZGluZyB0aGUgcmVzcG9uc2UKPiA+ID4gPiAgKiBTRUNDT01QX1VTRVJf
Tk9USUZfRkxBR19DT05USU5VRS4gTm90ZSB0aGF0IFNFQ0NPTVBfUkVUX1RSQUNFIGNhbiBlcXVh
bGx5Cj4gPiA+ID4gICogYmUgb3ZlcnJpZGVuIGJ5IFNFQ0NPTVBfVVNFUl9OT1RJRl9GTEFHX0NP
TlRJTlVFLgo+ID4gPiA+Cj4gPiA+ID4gSW4gb3RoZXIgd29yZHMsIGZyb20gYSBzZWN1cml0eSBw
ZXJzcGVjdGl2ZSwgeW91IG11c3QgYXNzdW1lIHRoYXQgdGhlCj4gPiA+ID4gdGFyZ2V0IHByb2Nl
c3MgY2FuIGJ5cGFzcyBhbnkgU0VDQ09NUF9SRVRfVVNFUl9OT1RJRiAob3IKPiA+ID4gPiBTRUND
T01QX1JFVF9UUkFDRSkgZmlsdGVycyB1bmxlc3MgaXQgaXMgY29tcGxldGVseSBwcm9oaWJpdGVk
IGZyb20KPiA+ID4gPiBjYWxsaW5nIHNlY2NvbXAoKS4gVGhpcyBzaG91bGQgYWxzbyBiZSBub3Rl
ZCBvdmVyIGluIHRoZSBtYWluCj4gPiA+ID4gc2VjY29tcCgyKSBtYW5wYWdlLCBlc3BlY2lhbGx5
IHRoZSBTRUNDT01QX1JFVF9UUkFDRSBwYXJ0Lgo+ID4gPgo+ID4gPiBTbyBJIHdhcyBhY3R1YWxs
eSB3b25kZXJpbmcgYWJvdXQgdGhpcyB3aGVuIEkgc2tpbW1lZCB0aGlzIGFuZCBhIHdoaWxlCj4g
PiA+IGFnbyBidXQgZm9yZ290IGFib3V0IHRoaXMgYWdhaW4uLi4gQWZhaWN0LCB5b3UgY2FuIG9u
bHkgZXZlciBsb2FkIGEKPiA+ID4gc2luZ2xlIGZpbHRlciB3aXRoIFNFQ0NPTVBfRklMVEVSX0ZM
QUdfTkVXX0xJU1RFTkVSIHNldC4gSWYgdGhlcmUKPiA+ID4gYWxyZWFkeSBpcyBhIGZpbHRlciB3
aXRoIHRoZSBTRUNDT01QX0ZJTFRFUl9GTEFHX05FV19MSVNURU5FUiBwcm9wZXJ0eQo+ID4gPiBp
biB0aGUgdGFza3MgZmlsdGVyIGhpZXJhcmNoeSB0aGVuIHRoZSBrZXJuZWwgd2lsbCByZWZ1c2Ug
dG8gbG9hZCBhIG5ldwo+ID4gPiBvbmU/Cj4gPiA+Cj4gPiA+IHN0YXRpYyBzdHJ1Y3QgZmlsZSAq
aW5pdF9saXN0ZW5lcihzdHJ1Y3Qgc2VjY29tcF9maWx0ZXIgKmZpbHRlcikKPiA+ID4gewo+ID4g
PiAgICAgICAgIHN0cnVjdCBmaWxlICpyZXQgPSBFUlJfUFRSKC1FQlVTWSk7Cj4gPiA+ICAgICAg
ICAgc3RydWN0IHNlY2NvbXBfZmlsdGVyICpjdXI7Cj4gPiA+Cj4gPiA+ICAgICAgICAgZm9yIChj
dXIgPSBjdXJyZW50LT5zZWNjb21wLmZpbHRlcjsgY3VyOyBjdXIgPSBjdXItPnByZXYpIHsKPiA+
ID4gICAgICAgICAgICAgICAgIGlmIChjdXItPm5vdGlmKQo+ID4gPiAgICAgICAgICAgICAgICAg
ICAgICAgICBnb3RvIG91dDsKPiA+ID4gICAgICAgICB9Cj4gPiA+Cj4gPiA+IHNob3VsZG4ndCB0
aGF0IGJlIHN1ZmZpY2llbnQgdG8gZ3VhcmFudGVlIHRoYXQgVVNFUl9OT1RJRiBmaWx0ZXJzIGNh
bid0Cj4gPiA+IG92ZXJyaWRlIGVhY2ggb3RoZXIgZm9yIHRoZSBzYW1lIHRhc2sgc2ltcGx5IGJl
Y2F1c2UgdGhlcmUgY2FuIG9ubHkgZXZlcgo+ID4gPiBiZSBhIHNpbmdsZSBvbmU/Cj4gPiAKPiA+
IEdvb2QgcG9pbnQuIEV4Y2VlZWVwdCB0aGF0IHRoYXQgY2hlY2sgc2VlbXMgaW5lZmZlY3RpdmUg
YmVjYXVzZSB0aGlzCj4gPiBoYXBwZW5zIGJlZm9yZSB3ZSB0YWtlIHRoZSBsb2NrcyB0aGF0IGd1
YXJkIGFnYWluc3QgVFNZTkMsIGFuZCBhbHNvCj4gPiBiZWZvcmUgd2UgZGVjaWRlIHRvIHdoaWNo
IGV4aXN0aW5nIGZpbHRlciB3ZSB3YW50IHRvIGNoYWluIHRoZSBuZXcKPiA+IGZpbHRlci4gU28g
aWYgdHdvIHRocmVhZHMgcmFjZSB3aXRoIFRTWU5DLCBJIHRoaW5rIHRoZXknbGwgYmUgYWJsZSB0
bwo+ID4gY2hhaW4gdHdvIGZpbHRlcnMgd2l0aCBsaXN0ZW5lcnMgdG9nZXRoZXIuCj4gCj4gWWVw
LCBzZWVtcyB0aGUgY2hlY2sgbmVlZHMgdG8gYWxzbyBiZSBpbiBzZWNjb21wX2Nhbl9zeW5jX3Ro
cmVhZHMoKSB0bwo+IGJlIHRvdGFsbHkgZWZmZWN0aXZlLAo+IAo+ID4gSSBkb24ndCBrbm93IHdo
ZXRoZXIgd2Ugd2FudCB0byBldGVybmFsaXplIHRoaXMgIm9ubHkgb25lIGxpc3RlbmVyCj4gPiBh
Y3Jvc3MgYWxsIHRoZSBmaWx0ZXJzIiByZXN0cmljdGlvbiBpbiB0aGUgbWFucGFnZSB0aG91Z2gs
IG9yIHdoZXRoZXIKPiA+IHRoZSBtYW4gcGFnZSBzaG91bGQganVzdCBzYXkgdGhhdCB0aGUga2Vy
bmVsIGN1cnJlbnRseSBkb2Vzbid0IHN1cHBvcnQKPiA+IGl0IGJ1dCB0aGF0IHNlY3VyaXR5LXdp
c2UgeW91IHNob3VsZCBhc3N1bWUgdGhhdCBpdCBtaWdodCBhdCBzb21lCj4gPiBwb2ludC4KPiAK
PiBUaGlzIHJlcXVpcmVtZW50IG9yaWdpbmFsbHkgY2FtZSBmcm9tIEFuZHksIGFyZ3VpbmcgdGhh
dCB0aGUgc2VtYW50aWNzCj4gb2YgdGhpcyB3ZXJlL2FyZSBjb25mdXNpbmcsIHdoaWNoIHN0aWxs
IG1ha2VzIHNlbnNlIHRvIG1lLiBQZXJoYXBzIHdlCj4gc2hvdWxkIGRvIHNvbWV0aGluZyBsaWtl
IHRoZSBiZWxvdz8KCkkgdGhpbmsgd2Ugc2hvdWxkIGVpdGhlciBrZWVwIHVwIHRoaXMgcmVzdHJp
Y3Rpb24gYW5kIHRoZW4gY2VtZW50IGl0IGluCnRoZSBtYW5wYWdlIG9yIGFkZCBhIGZsYWcgdG8g
aW5kaWNhdGUgdGhhdCB0aGUgbm90aWZpZXIgaXMKbm9uLW92ZXJyaWRhYmxlLgpJIGRvbid0IGNh
cmUgYWJvdXQgdGhlIGRlZmF1bHQgdG9vIG11Y2gsIGkuZS4gd2hldGhlciBpdCdzIG92ZXJyaWRh
YmxlCmJ5IGRlZmF1bHQgYW5kIGV4Y2x1c2l2ZSBpZiBvcHRpbmcgaW4gb3IgdGhlIG90aGVyIHdh
eSBhcm91bmQgZG9lc24ndAptYXR0ZXIgdG9vIG11Y2guIEJ1dCBmcm9tIGEgc3VwZXJ2aXNvcidz
IHBlcnNwZWN0aXZlIGl0J2QgYmUgcXVpdGUgbmljZQp0byBiZSBhYmxlIHRvIGJlIHN1cmUgdGhh
dCBhIG5vdGlmaWVyIGNhbid0IGJlIG92ZXJyaWRlbiBieSBhbm90aGVyCm5vdGlmaWVyLgoKSSB0
aGluayBoYXZpbmcgYSBmbGFnIHdvdWxkIHByb3ZpZGUgdGhlIGdyZWF0ZXN0IGZsZXhpYmlsaXR5
IGJ1dCBJIGFncmVlCnRoYXQgdGhlIHNlbWFudGljcyBvZiBtdWx0aXBsZSBsaXN0ZW5lcnMgYXJl
IGtpbmRhIG9kZC4KCkJlbG93IGxvb2tzIHNhbmUgdG8gbWUgdGhvdWdoIGFnYWluLCBJJ20gbm90
IHNpdHRpbmcgaW4gZnJvbiBvZiBzb3VyY2UKY29kZS4KCkNocmlzdGlhbgoKPiBkaWZmIC0tZ2l0
IGEva2VybmVsL3NlY2NvbXAuYyBiL2tlcm5lbC9zZWNjb21wLmMKPiBpbmRleCAzZWU1OWNlMGEz
MjMuLjdiMTA3MjA3YzJiMCAxMDA2NDQKPiAtLS0gYS9rZXJuZWwvc2VjY29tcC5jCj4gKysrIGIv
a2VybmVsL3NlY2NvbXAuYwo+IEBAIC0zNzYsNiArMzc2LDE4IEBAIHN0YXRpYyBpbnQgaXNfYW5j
ZXN0b3Ioc3RydWN0IHNlY2NvbXBfZmlsdGVyICpwYXJlbnQsCj4gIAlyZXR1cm4gMDsKPiAgfQo+
ICAKPiArc3RhdGljIGJvb2wgaGFzX2xpc3RlbmVyX3BhcmVudChzdHJ1Y3Qgc2VjY29tcF9maWx0
ZXIgKmNoaWxkKQo+ICt7Cj4gKwlzdHJ1Y3Qgc2VjY29tcF9maWx0ZXIgKmN1cjsKPiArCj4gKwlm
b3IgKGN1ciA9IGN1cnJlbnQtPnNlY2NvbXAuZmlsdGVyOyBjdXI7IGN1ciA9IGN1ci0+cHJldikg
ewo+ICsJCWlmIChjdXItPm5vdGlmKQo+ICsJCQlyZXR1cm4gdHJ1ZTsKPiArCX0KPiArCj4gKwly
ZXR1cm4gZmFsc2U7Cj4gK30KPiArCj4gIC8qKgo+ICAgKiBzZWNjb21wX2Nhbl9zeW5jX3RocmVh
ZHM6IGNoZWNrcyBpZiBhbGwgdGhyZWFkcyBjYW4gYmUgc3luY2hyb25pemVkCj4gICAqCj4gQEAg
LTM4NSw3ICszOTcsNyBAQCBzdGF0aWMgaW50IGlzX2FuY2VzdG9yKHN0cnVjdCBzZWNjb21wX2Zp
bHRlciAqcGFyZW50LAo+ICAgKiBlaXRoZXIgbm90IGluIHRoZSBjb3JyZWN0IHNlY2NvbXAgbW9k
ZSBvciBkaWQgbm90IGhhdmUgYW4gYW5jZXN0cmFsCj4gICAqIHNlY2NvbXAgZmlsdGVyLgo+ICAg
Ki8KPiAtc3RhdGljIGlubGluZSBwaWRfdCBzZWNjb21wX2Nhbl9zeW5jX3RocmVhZHModm9pZCkK
PiArc3RhdGljIGlubGluZSBwaWRfdCBzZWNjb21wX2Nhbl9zeW5jX3RocmVhZHModW5zaWduZWQg
aW50IGZsYWdzKQo+ICB7Cj4gIAlzdHJ1Y3QgdGFza19zdHJ1Y3QgKnRocmVhZCwgKmNhbGxlcjsK
PiAgCj4gQEAgLTQwNyw2ICs0MTksMTEgQEAgc3RhdGljIGlubGluZSBwaWRfdCBzZWNjb21wX2Nh
bl9zeW5jX3RocmVhZHModm9pZCkKPiAgCQkJCSBjYWxsZXItPnNlY2NvbXAuZmlsdGVyKSkpCj4g
IAkJCWNvbnRpbnVlOwo+ICAKPiArCQkvKiBkb24ndCBhbGxvdyBUU1lOQyB0byBpbnN0YWxsIG11
bHRpcGxlIGxpc3RlbmVycyAqLwo+ICsJCWlmIChmbGFncyAmIFNFQ0NPTVBfRklMVEVSX0ZMQUdf
TkVXX0xJU1RFTkVSICYmCj4gKwkJICAgICFoYXNfbGlzdGVuZXJfcGFyZW50KHRocmVhZC0+c2Vj
Y29tcC5maWx0ZXIpKQo+ICsJCQljb250aW51ZTsKPiArCj4gIAkJLyogUmV0dXJuIHRoZSBmaXJz
dCB0aHJlYWQgdGhhdCBjYW5ub3QgYmUgc3luY2hyb25pemVkLiAqLwo+ICAJCWZhaWxlZCA9IHRh
c2tfcGlkX3Zucih0aHJlYWQpOwo+ICAJCS8qIElmIHRoZSBwaWQgY2Fubm90IGJlIHJlc29sdmVk
LCB0aGVuIHJldHVybiAtRVNSQ0ggKi8KPiBAQCAtNjM3LDcgKzY1NCw3IEBAIHN0YXRpYyBsb25n
IHNlY2NvbXBfYXR0YWNoX2ZpbHRlcih1bnNpZ25lZCBpbnQgZmxhZ3MsCj4gIAlpZiAoZmxhZ3Mg
JiBTRUNDT01QX0ZJTFRFUl9GTEFHX1RTWU5DKSB7Cj4gIAkJaW50IHJldDsKPiAgCj4gLQkJcmV0
ID0gc2VjY29tcF9jYW5fc3luY190aHJlYWRzKCk7Cj4gKwkJcmV0ID0gc2VjY29tcF9jYW5fc3lu
Y190aHJlYWRzKGZsYWdzKTsKPiAgCQlpZiAocmV0KSB7Cj4gIAkJCWlmIChmbGFncyAmIFNFQ0NP
TVBfRklMVEVSX0ZMQUdfVFNZTkNfRVNSQ0gpCj4gIAkJCQlyZXR1cm4gLUVTUkNIOwo+IEBAIC0x
NDYyLDEyICsxNDc5LDkgQEAgc3RhdGljIGNvbnN0IHN0cnVjdCBmaWxlX29wZXJhdGlvbnMgc2Vj
Y29tcF9ub3RpZnlfb3BzID0gewo+ICBzdGF0aWMgc3RydWN0IGZpbGUgKmluaXRfbGlzdGVuZXIo
c3RydWN0IHNlY2NvbXBfZmlsdGVyICpmaWx0ZXIpCj4gIHsKPiAgCXN0cnVjdCBmaWxlICpyZXQg
PSBFUlJfUFRSKC1FQlVTWSk7Cj4gLQlzdHJ1Y3Qgc2VjY29tcF9maWx0ZXIgKmN1cjsKPiAgCj4g
LQlmb3IgKGN1ciA9IGN1cnJlbnQtPnNlY2NvbXAuZmlsdGVyOyBjdXI7IGN1ciA9IGN1ci0+cHJl
dikgewo+IC0JCWlmIChjdXItPm5vdGlmKQo+IC0JCQlnb3RvIG91dDsKPiAtCX0KPiArCWlmICho
YXNfbGlzdGVuZXJfcGFyZW50KGN1cnJlbnQtPnNlY2NvbXAuZmlsdGVyKSkKPiArCQlnb3RvIG91
dDsKPiAgCj4gIAlyZXQgPSBFUlJfUFRSKC1FTk9NRU0pOwo+ICAJZmlsdGVyLT5ub3RpZiA9IGt6
YWxsb2Moc2l6ZW9mKCooZmlsdGVyLT5ub3RpZikpLCBHRlBfS0VSTkVMKTsKX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KQ29udGFpbmVycyBtYWlsaW5nIGxp
c3QKQ29udGFpbmVyc0BsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxp
bnV4Zm91bmRhdGlvbi5vcmcvbWFpbG1hbi9saXN0aW5mby9jb250YWluZXJz
