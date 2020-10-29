Return-Path: <SRS0=MeFG=EE=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0DF3C4363A
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 18:06:32 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id E13D820825
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 18:06:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E13D820825
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 2E9CC86C9F;
	Thu, 29 Oct 2020 18:06:31 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 7fmgIwG4loXN; Thu, 29 Oct 2020 18:06:28 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 2EB4986C90;
	Thu, 29 Oct 2020 18:06:28 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 18B84C088B;
	Thu, 29 Oct 2020 18:06:28 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id B4683C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 18:06:26 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id A662286FAB
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 18:06:26 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id lztM4nq-jLr3
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 18:06:17 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 75C6A86F6C
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 18:06:12 +0000 (UTC)
Received: from mail-lj1-f177.google.com ([209.85.208.177])
 by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <stgraber@ubuntu.com>) id 1kYCI1-0003zQ-0n
 for containers@lists.linux-foundation.org; Thu, 29 Oct 2020 18:04:45 +0000
Received: by mail-lj1-f177.google.com with SMTP id t13so4052747ljk.12
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 11:04:45 -0700 (PDT)
X-Gm-Message-State: AOAM530ND6iQNSupWYr9gwB/+++jzw9FZpVForEDOxh314M38YMFFgtk
 Kf3YkjDikxyXBWeQ2jdxb4aEfM1Jxnhmr+7c9VUorQ==
X-Google-Smtp-Source: ABdhPJzOR+GvYdcxThjeYM4q+BnWieqIoL3kVTr7F9zyXSA8NyVuuYCL1zVggZkDC4pHflRK6EVUPiYtBnL0ZVxrdaQ=
X-Received: by 2002:ac2:5c49:: with SMTP id s9mr1955451lfp.14.1603994683268;
 Thu, 29 Oct 2020 11:04:43 -0700 (PDT)
MIME-Version: 1.0
References: <20201029003252.2128653-1-christian.brauner@ubuntu.com>
 <87pn51ghju.fsf@x220.int.ebiederm.org> <20201029161231.GA108315@cisco>
 <87blglc77y.fsf@x220.int.ebiederm.org>
In-Reply-To: <87blglc77y.fsf@x220.int.ebiederm.org>
From: =?UTF-8?Q?St=C3=A9phane_Graber?= <stgraber@ubuntu.com>
Date: Thu, 29 Oct 2020 14:04:31 -0400
X-Gmail-Original-Message-ID: <CA+enf=vn1TgdLx9TR3m=wdBzbZxRbxK4NFY4NdYn0v5gzewCyw@mail.gmail.com>
Message-ID: <CA+enf=vn1TgdLx9TR3m=wdBzbZxRbxK4NFY4NdYn0v5gzewCyw@mail.gmail.com>
Subject: Re: [PATCH 00/34] fs: idmapped mounts
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andy Lutomirski <luto@kernel.org>, Mimi Zohar <zohar@linux.ibm.com>,
 David Howells <dhowells@redhat.com>, Andreas Dilger <adilger.kernel@dilger.ca>,
 Miklos Szeredi <miklos@szeredi.hu>, Stephen Barber <smbarber@chromium.org>,
 Christoph Hellwig <hch@infradead.org>, Alban Crequy <alban@kinvolk.io>,
 linux-ext4@vger.kernel.org, Mrunal Patel <mpatel@redhat.com>,
 Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>,
 Jann Horn <jannh@google.com>, selinux@vger.kernel.org,
 Josh Triplett <josh@joshtriplett.org>,
 Seth Forshee <seth.forshee@canonical.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Lennart Poettering <lennart@poettering.net>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Stephen Smalley <stephen.smalley.work@gmail.com>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Jonathan Corbet <corbet@lwn.net>, overlayfs <linux-unionfs@vger.kernel.org>,
 linux-security-module@vger.kernel.org, linux-audit@redhat.com,
 Linux API <linux-api@vger.kernel.org>,
 Casey Schaufler <casey@schaufler-ca.com>,
 linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-integrity@vger.kernel.org,
 Todd Kjos <tkjos@google.com>
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

T24gVGh1LCBPY3QgMjksIDIwMjAgYXQgMTI6NDUgUE0gRXJpYyBXLiBCaWVkZXJtYW4KPGViaWVk
ZXJtQHhtaXNzaW9uLmNvbT4gd3JvdGU6Cj4KPiBUeWNobyBBbmRlcnNlbiA8dHljaG9AdHljaG8u
cGl6emE+IHdyaXRlczoKPgo+ID4gSGkgRXJpYywKPiA+Cj4gPiBPbiBUaHUsIE9jdCAyOSwgMjAy
MCBhdCAxMDo0Nzo0OUFNIC0wNTAwLCBFcmljIFcuIEJpZWRlcm1hbiB3cm90ZToKPiA+PiBDaHJp
c3RpYW4gQnJhdW5lciA8Y2hyaXN0aWFuLmJyYXVuZXJAdWJ1bnR1LmNvbT4gd3JpdGVzOgo+ID4+
Cj4gPj4gPiBIZXkgZXZlcnlvbmUsCj4gPj4gPgo+ID4+ID4gSSB2YW5pc2hlZCBmb3IgYSBsaXR0
bGUgd2hpbGUgdG8gZm9jdXMgb24gdGhpcyB3b3JrIGhlcmUgc28gc29ycnkgZm9yCj4gPj4gPiBu
b3QgYmVpbmcgYXZhaWxhYmxlIGJ5IG1haWwgZm9yIGEgd2hpbGUuCj4gPj4gPgo+ID4+ID4gU2lu
Y2UgcXVpdGUgYSBsb25nIHRpbWUgd2UgaGF2ZSBpc3N1ZXMgd2l0aCBzaGFyaW5nIG1vdW50cyBi
ZXR3ZWVuCj4gPj4gPiBtdWx0aXBsZSB1bnByaXZpbGVnZWQgY29udGFpbmVycyB3aXRoIGRpZmZl
cmVudCBpZCBtYXBwaW5ncywgc2hhcmluZyBhCj4gPj4gPiByb290ZnMgYmV0d2VlbiBtdWx0aXBs
ZSBjb250YWluZXJzIHdpdGggZGlmZmVyZW50IGlkIG1hcHBpbmdzLCBhbmQgYWxzbwo+ID4+ID4g
c2hhcmluZyByZWd1bGFyIGRpcmVjdG9yaWVzIGFuZCBmaWxlc3lzdGVtcyBiZXR3ZWVuIHVzZXJz
IHdpdGggZGlmZmVyZW50Cj4gPj4gPiB1aWRzIGFuZCBnaWRzLiBUaGUgbGF0dGVyIHVzZS1jYXNl
cyBoYXZlIGJlY29tZSBldmVuIG1vcmUgaW1wb3J0YW50IHdpdGgKPiA+PiA+IHRoZSBhdmFpbGFi
aWxpdHkgYW5kIGFkb3B0aW9uIG9mIHN5c3RlbWQtaG9tZWQgKGNmLiBbMV0pIHRvIGltcGxlbWVu
dAo+ID4+ID4gcG9ydGFibGUgaG9tZSBkaXJlY3Rvcmllcy4KPiA+Pgo+ID4+IENhbiB5b3Ugd2Fs
ayB1cyB0aHJvdWdoIHRoZSBtb3RpdmF0aW5nIHVzZSBjYXNlPwo+ID4+Cj4gPj4gQXMgb2YgdGhp
cyB5ZWFyJ3MgTFBDIEkgaGFkIHRoZSBkaXN0aW5jdCBpbXByZXNzaW9uIHRoYXQgdGhlIHByaW1h
cnkgdXNlCj4gPj4gY2FzZSBmb3Igc3VjaCBhIGZlYXR1cmUgd2FzIGR1ZSB0byB0aGUgUkxJTUlU
X05QUk9DIHByb2JsZW0gd2hlcmUgdHdvCj4gPj4gY29udGFpbmVycyB3aXRoIHRoZSBzYW1lIHVz
ZXJzIHN0aWxsIHdhbnRlZCBkaWZmZXJlbnQgdWlkIG1hcHBpbmdzIHRvCj4gPj4gdGhlIGRpc2sg
YmVjYXVzZSB0aGUgdXNlcnMgd2VyZSBjb25mbGljdGluZyB3aXRoIGVhY2ggb3RoZXIgYmVjYXVz
ZSBvZgo+ID4+IHRoZSBwZXIgdXNlciBybGltaXRzLgo+ID4+Cj4gPj4gRml4aW5nIHJsaW1pdHMg
aXMgc3RyYWlnaHQgZm9yd2FyZCB0byBpbXBsZW1lbnQsIGFuZCBlYXNpZXIgdG8gbWFuYWdlCj4g
Pj4gZm9yIGltcGxlbWVudGF0aW9ucyBhbmQgYWRtaW5pc3RyYXRvcnMuCj4gPgo+ID4gT3VyIHVz
ZSBjYXNlIGlzIHRvIGhhdmUgdGhlIHNhbWUgZGlyZWN0b3J5IGV4cG9zZWQgdG8gc2V2ZXJhbAo+
ID4gZGlmZmVyZW50IGNvbnRhaW5lcnMgd2hpY2ggZWFjaCBoYXZlIGRpc2pvaW50IElEIG1hcHBp
bmdzLgo+Cj4gV2h5IGRvIHRoZSB5b3UgaGF2ZSBkaXNqb2ludCBJRCBtYXBwaW5ncyBmb3IgdGhl
IHVzZXJzIHRoYXQgYXJlIHdyaXRpbmcKPiB0byBkaXNrIHdpdGggdGhlIHNhbWUgSUQ/Cj4KPiA+
PiBSZWFkaW5nIHVwIG9uIHN5c3RlbWQtaG9tZWQgaXQgYXBwZWFycyB0byBiZSBhIHdheSB0byBo
YXZlIGVuY3J5cHRlZAo+ID4+IGhvbWUgZGlyZWN0b3JpZXMuICBUaG9zZSBob21lIGRpcmVjdG9y
aWVzIGNhbiBlaXRoZXIgYmUgZW5jcnlwdGVkIGF0IHRoZQo+ID4+IGZzIG9yIGF0IHRoZSBibG9j
ayBsZXZlbC4gIFRob3NlIGhvbWUgZGlyZWN0b3JpZXMgYXBwZWFyIHRvIGhhdmUgdGhlCj4gPj4g
Z29hbCBvZiBiZWluZyBsdWdnYWJsZSBiZXR3ZWVuIHN5c3RlbXMuICBJZiB0aGUgc3lzdGVtcyBp
biBxdWVzdGlvbgo+ID4+IGRvbid0IGhhdmUgY29tbW9uIGFkbWluaXN0cmF0aW9uIG9mIHVpZHMg
YW5kIGdpZHMgYWZ0ZXIgbHVnZ2luZyB5b3VyCj4gPj4gZW5jcnlwdGVkIGhvbWUgZGlyZWN0b3J5
IHRvIGFub3RoZXIgc3lzdGVtIGNob3duaW5nIHRoZSBmaWxlcyBpcwo+ID4+IHJlcXVpcmVkLgo+
ID4+Cj4gPj4gSXMgdGhhdCB0aGUgdXNlIGNhc2UgeW91IGFyZSBsb29raW5nIGF0IHJlbW92aW5n
IHRoZSBuZWVkIGZvcgo+ID4+IHN5c3RlbWQtaG9tZWQgdG8gYXZvaWQgY2hvd25pbmcgYWZ0ZXIg
bHVnZ2luZyBlbmNyeXB0ZWQgaG9tZSBkaXJlY3Rvcmllcwo+ID4+IGZyb20gb25lIHN5c3RlbSB0
byBhbm90aGVyPyAgV2h5IHdvdWxkIGl0IGJlIGRlc2lyYWJsZSB0byBhdm9pZCB0aGUKPiA+PiBj
aG93bj8KPiA+Cj4gPiBOb3QganVzdCBzeXN0ZW1kLWhvbWVkLCBidXQgTFhEIGhhcyB0byBkbyB0
aGlzLAo+Cj4gSSBhc2tlZCB3aHkgdGhlIHNhbWUgZGlzayB1c2VycyBhcmUgYXNzaWduZWQgZGlm
ZmVyZW50IGt1aWRzIGFuZCB0aGUKPiBvbmx5IHJlYXNvbiBJIGhhdmUgaGVhcmQgdGhhdCBMWEQg
ZG9lcyB0aGlzIGlzIHRoZSBSTElNSVRfTlBST0MgcHJvYmxlbS4KPgo+IFBlcmhhcHMgdGhlcmUg
aXMgYW5vdGhlciByZWFzb24uCj4KPiBJbiBwYXJ0IHRoaXMgaXMgd2h5IEkgYW0gZWFnZXIgdG8g
aGVhciBwZW9wbGVzIHVzZSBjYXNlLCBhbmQgd2h5IEkgd2FzCj4gdHJ5aW5nIHZlcnkgaGFyZCB0
byBtYWtlIGNlcnRhaW4gd2UgZ2V0IHRoZSByZXF1aXJlbWVudHMuCj4KPiBJIHdhbnQgdGhlIHJl
YWwgcmVxdWlyZW1lbnRzIHRob3VnaCBhbmQgc29tZSB0aG91Z2h0LCBub3QganVzdCB3ZSBkaWQK
PiB0aGlzIGFuZCBpdCBodXJ0cy4gIENoYW5nbmluZyB0aGUgdWlkcyBvbiB3cml0ZSBpcyBhIHZl
cnkgaGFyZCBwcm9ibGVtLAo+IGFuZCBub3QganVzdCBpbiBpbXBsZW1lbnRhdGluZyBpdCBidXQg
YWxzbyBpbiBtYWludGFpbmluZyBhbmQKPiB1bmRlcnN0YW5kaW5nIHdoYXQgaXMgZ29pbmcgb24u
CgpUaGUgbW9zdCBjb21tb24gY2FzZXMgd2hlcmUgc2hpZnRmcyBpcyB1c2VkIG9yIHdoZXJlIGZv
bGtzIHdvdWxkIGxpa2UKdG8gdXNlIGl0IHRvZGF5IGFyZSAoYnkgaW1wb3J0YW5jZSk6CiAtIEZh
c3QgY29udGFpbmVyIGNyZWF0aW9uIChieSBub3QgaGF2aW5nIHRvIHVpZC9naWQgc2hpZnQgYWxs
IGZpbGVzCmluIHRoZSBkb3dubG9hZGVkIGltYWdlKQogLSBTaGFyaW5nIGRhdGEgYmV0d2VlbiB0
aGUgaG9zdCBzeXN0ZW0gYW5kIGEgY29udGFpbmVyIChzb21lIHBhdGhzCnVuZGVyIC9ob21lIGJl
aW5nIHRoZSBtb3N0IGNvbW1vbikKIC0gU2hhcmluZyBkYXRhIGJldHdlZW4gdW5wcml2aWxlZ2Vk
IGNvbnRhaW5lcnMgd2l0aCBhIGRpc2pvaW50ZWQgbWFwCiAtIFNoYXJpbmcgZGF0YSBiZXR3ZWVu
IG11bHRpcGxlIGNvbnRhaW5lcnMsIHNvbWUgcHJpdmlsZWdlZCwgc29tZSB1bnByaXZpbGVnZWQK
CkZpeGluZyB0aGUgdWxpbWl0IGlzc3VlIG9ubHkgdGFrZXMgY2FyZSBvZiBvbmUgb2YgdGhvc2Ug
KDNyZCBpdGVtKSwgaXQKZG9lcyBub3Qgc29sdmUgYW55IG9mIHRoZSBvdGhlciBjYXNlcy4KClRo
ZSBmaXJzdCBpdGVtIG9uIHRoZXJlIGFsb25lIGNhbiBiZSBxdWl0ZSBzaWduaWZpY2FudC4gQ3Jl
YXRpb24gYW5kCnN0YXJ0dXAgb2YgYSByZWd1bGFyIERlYmlhbiBjb250YWluZXIgb24gbXkgc3lz
dGVtIHRha2VzIGFyb3VuZCA1MDBtcwp3aGVuIHNoaWZ0ZnMgaXMgdXNlZCAoYnRyZnMvbHZtL3pm
cyBjb3B5LW9uLXdyaXRlIGNsb25lIG9mIHRoZSBpbWFnZSwKc2V0dXAgc2hpZnRmcywgc3RhcnQg
Y29udGFpbmVyKSBjb21wYXJlZCB0byAyLTNzIHdoZW4gcnVubmluZyB3aXRob3V0Cml0IChzYW1l
IGNsb25lLCBmb2xsb3dlZCBieSByZXdyaXRlIG9mIGFsbCB1aWQvZ2lkIHByZXNlbnQgb24gdGhl
IGZzLAppbmNsdWRpbmcgYWNscyBhbmQgY2FwYWJpbGl0aWVzLCB0aGVuIHN0YXJ0IGNvbnRhaW5l
cikuIEFuZCB0aGF0J3Mgb24KYSBmYXN0IHN5c3RlbSB3aXRoIGFuIE5WTUUgU1NEIGFuZCBhIHNt
YWxsIHJvb3Rmcy4gV2UgaGF2ZSBoYWQgcmVwb3J0cwpvZiBhIGZldyB1c2VycyBydW5uaW5nIG9u
IHNsb3cgc3Bpbm5pbmcgcnVzdCB3aXRoIGxhcmdlIGNvbnRhaW5lcnMKd2hlcmUgc2hpZnRpbmcg
Y2FuIHRha2Ugc2V2ZXJhbCBtaW51dGVzLgoKVGhlIHNlY29uZCBpdGVtIGNhbiB0ZWNobmljYWxs
eSBiZSB3b3JrZWQgYXJvdW5kIHdpdGhvdXQgc2hpZnRlZApiaW5kLW1vdW50cyBieSBkb2luZyB1
c2VybnMgbWFwIGhvbGUgcHVuY2hpbmcsIG1hcHBpbmcgdGhlIHVzZXIncwp1aWQvZ2lkIGZyb20g
dGhlIGhvc3Qgc3RyYWlnaHQgaW50byB0aGUgY29udGFpbmVyLiBUaGUgZG93bnNpZGUgdG8KdGhp
cyBpcyB0aGF0IGFub3RoZXIgc2hpZnRpbmcgcGFzcyBiZWNvbWVzIG5lZWRlZCBmb3IgYW55IGZp
bGUgb3V0c2lkZQpvZiB0aGUgYmluZC1tb3VudGVkIHBhdGggKG9yIGl0IHdvdWxkIGJlY29tZSBv
d25lZCBieSAtMS8tMSkgYW5kIGl0J3MKdmVyeSBtdWNoIG5vdCBkeW5hbWljLCByZXF1aXJpbmcg
dGhlIGNvbnRhaW5lciBiZSBzdG9wcGVkLCBjb25maWcKdXBkYXRlZCBieSB0aGUgdXNlciwgL2V0
Yy9zdWJ1aWQgYW5kIHN1YmdpZCBtYXBzIGJlaW5nIHVwZGF0ZWQgYW5kCmNvbnRhaW5lciBzdGFy
dGVkIGJhY2sgdXAuIElmIHlvdSBuZWVkIGFub3RoZXIgdXNlci9ncm91cCBiZSBleHBvc2VkLApz
dGFydCBhbGwgb3ZlciBhZ2Fpbi4uLgpUaGlzIGlzIGZhciBtb3JlIGNvbXBsZXgsIHNsb3cgYW5k
IGRpc3J1cHRpdmUgdGhhbiB0aGUgc2hpZnRlZAphcHByb2FjaCB3aGVyZSB3ZSBqdXN0IG5lZWQg
dG8gZG86CiAgIGx4YyBjb25maWcgZGV2aWNlIGFkZCBNWS1DT05UQUlORVIgaG9tZSBkaXNrIHNv
dXJjZT0vaG9tZQpwYXRoPS9ob21lIHNoaWZ0PXRydWUKVG8gaW5qZWN0IGEgbmV3IG1vdW50IG9m
IC9ob21lIGZyb20gdGhlIGhvc3QgaW50byB0aGUgY29udGFpbmVyIHdpdGggYQpzaGlmdGluZyBs
YXllciBpbiBwbGFjZSwgbm8gbmVlZCB0byByZWNvbmZpZyBzdWJ1aWQvc3ViZ2lkLCBubyBuZWVk
IHRvCnJlLWNyZWF0ZSB0aGUgdXNlcm5zIHRvIHVwZGF0ZSB0aGUgbWFwcGluZyBhbmQgbm8gbmVl
ZCB0byBnbyB0aHJvdWdoCnRoZSBjb250YWluZXIncyByb290ZnMgZm9yIGFueSBmaWxlIHdoaWNo
IG1heSBub3cgbmVlZCByZW1hcHBpbmcKYmVjYXVzZSBvZiB0aGUgbWFwIGNoYW5nZS4KClN0w6lw
aGFuZQoKPiBFcmljCj4gX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX18KPiBDb250YWluZXJzIG1haWxpbmcgbGlzdAo+IENvbnRhaW5lcnNAbGlzdHMubGludXgt
Zm91bmRhdGlvbi5vcmcKPiBodHRwczovL2xpc3RzLmxpbnV4Zm91bmRhdGlvbi5vcmcvbWFpbG1h
bi9saXN0aW5mby9jb250YWluZXJzCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fCkNvbnRhaW5lcnMgbWFpbGluZyBsaXN0CkNvbnRhaW5lcnNAbGlzdHMubGlu
dXgtZm91bmRhdGlvbi5vcmcKaHR0cHM6Ly9saXN0cy5saW51eGZvdW5kYXRpb24ub3JnL21haWxt
YW4vbGlzdGluZm8vY29udGFpbmVycw==
