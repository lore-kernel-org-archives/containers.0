Return-Path: <SRS0=hUL4=EF=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0824C5DF9D
	for <containers@archiver.kernel.org>; Fri, 30 Oct 2020 16:17:21 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 57D3A206FA
	for <containers@archiver.kernel.org>; Fri, 30 Oct 2020 16:17:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57D3A206FA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=hallyn.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id BD3E7873D4;
	Fri, 30 Oct 2020 16:17:20 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id PQk5zz3O8wWt; Fri, 30 Oct 2020 16:17:18 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id B490B873A3;
	Fri, 30 Oct 2020 16:17:18 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id A8117C088B;
	Fri, 30 Oct 2020 16:17:18 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 476A7C0051
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 16:17:17 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 26D962040B
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 16:17:17 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id WYj9neVCZAoz
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 16:17:15 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail.hallyn.com (mail.hallyn.com [178.63.66.53])
 by silver.osuosl.org (Postfix) with ESMTPS id 3407C20358
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 16:17:14 +0000 (UTC)
Received: by mail.hallyn.com (Postfix, from userid 1001)
 id D02C58FF; Fri, 30 Oct 2020 11:17:12 -0500 (CDT)
Date: Fri, 30 Oct 2020 11:17:12 -0500
From: "Serge E. Hallyn" <serge@hallyn.com>
To: Christian Brauner <christian.brauner@ubuntu.com>
Subject: Re: [PATCH 00/34] fs: idmapped mounts
Message-ID: <20201030161712.GA30381@mail.hallyn.com>
References: <20201029003252.2128653-1-christian.brauner@ubuntu.com>
 <8E455D54-FED4-4D06-8CB7-FC6291C64259@amacapital.net>
 <20201030120157.exz4rxmebruh7bgp@wittgenstein>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20201030120157.exz4rxmebruh7bgp@wittgenstein>
User-Agent: Mutt/1.9.4 (2018-02-28)
Cc: Lennart Poettering <lennart@poettering.net>,
 Mimi Zohar <zohar@linux.ibm.com>, David Howells <dhowells@redhat.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Tycho Andersen <tycho@tycho.ws>,
 Miklos Szeredi <miklos@szeredi.hu>, smbarber@chromium.org,
 Christoph Hellwig <hch@infradead.org>, linux-ext4@vger.kernel.org,
 Mrunal Patel <mpatel@redhat.com>, Kees Cook <keescook@chromium.org>,
 Arnd Bergmann <arnd@arndb.de>, Jann Horn <jannh@google.com>,
 selinux@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>,
 linux-fsdevel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>,
 Andy Lutomirski <luto@kernel.org>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>,
 James Bottomley <james.bottomley@hansenpartnership.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Seth Forshee <seth.forshee@canonical.com>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 Stephen Smalley <stephen.smalley.work@gmail.com>,
 Jonathan Corbet <corbet@lwn.net>, linux-unionfs@vger.kernel.org,
 Andy Lutomirski <luto@amacapital.net>, linux-security-module@vger.kernel.org,
 linux-audit@redhat.com, "Eric W. Biederman" <ebiederm@xmission.com>,
 linux-api@vger.kernel.org, Casey Schaufler <casey@schaufler-ca.com>,
 Alban Crequy <alban@kinvolk.io>, linux-integrity@vger.kernel.org,
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

T24gRnJpLCBPY3QgMzAsIDIwMjAgYXQgMDE6MDE6NTdQTSArMDEwMCwgQ2hyaXN0aWFuIEJyYXVu
ZXIgd3JvdGU6Cj4gT24gVGh1LCBPY3QgMjksIDIwMjAgYXQgMDI6NTg6NTVQTSAtMDcwMCwgQW5k
eSBMdXRvbWlyc2tpIHdyb3RlOgo+ID4gCj4gPiAKPiA+ID4gT24gT2N0IDI4LCAyMDIwLCBhdCA1
OjM1IFBNLCBDaHJpc3RpYW4gQnJhdW5lciA8Y2hyaXN0aWFuLmJyYXVuZXJAdWJ1bnR1LmNvbT4g
d3JvdGU6Cj4gPiA+IAo+ID4gPiDvu79IZXkgZXZlcnlvbmUsCj4gPiA+IAo+ID4gPiBJIHZhbmlz
aGVkIGZvciBhIGxpdHRsZSB3aGlsZSB0byBmb2N1cyBvbiB0aGlzIHdvcmsgaGVyZSBzbyBzb3Jy
eSBmb3IKPiA+ID4gbm90IGJlaW5nIGF2YWlsYWJsZSBieSBtYWlsIGZvciBhIHdoaWxlLgo+ID4g
PiAKPiA+ID4gU2luY2UgcXVpdGUgYSBsb25nIHRpbWUgd2UgaGF2ZSBpc3N1ZXMgd2l0aCBzaGFy
aW5nIG1vdW50cyBiZXR3ZWVuCj4gPiA+IG11bHRpcGxlIHVucHJpdmlsZWdlZCBjb250YWluZXJz
IHdpdGggZGlmZmVyZW50IGlkIG1hcHBpbmdzLCBzaGFyaW5nIGEKPiA+ID4gcm9vdGZzIGJldHdl
ZW4gbXVsdGlwbGUgY29udGFpbmVycyB3aXRoIGRpZmZlcmVudCBpZCBtYXBwaW5ncywgYW5kIGFs
c28KPiA+ID4gc2hhcmluZyByZWd1bGFyIGRpcmVjdG9yaWVzIGFuZCBmaWxlc3lzdGVtcyBiZXR3
ZWVuIHVzZXJzIHdpdGggZGlmZmVyZW50Cj4gPiA+IHVpZHMgYW5kIGdpZHMuIFRoZSBsYXR0ZXIg
dXNlLWNhc2VzIGhhdmUgYmVjb21lIGV2ZW4gbW9yZSBpbXBvcnRhbnQgd2l0aAo+ID4gPiB0aGUg
YXZhaWxhYmlsaXR5IGFuZCBhZG9wdGlvbiBvZiBzeXN0ZW1kLWhvbWVkIChjZi4gWzFdKSB0byBp
bXBsZW1lbnQKPiA+ID4gcG9ydGFibGUgaG9tZSBkaXJlY3Rvcmllcy4KPiA+ID4gCj4gPiA+IFRo
ZSBzb2x1dGlvbnMgd2UgaGF2ZSB0cmllZCBhbmQgcHJvcG9zZWQgc28gZmFyIGluY2x1ZGUgdGhl
IGludHJvZHVjdGlvbgo+ID4gPiBvZiBmc2lkIG1hcHBpbmdzLCBhIHRpbnkgb3ZlcmxheSBiYXNl
ZCBmaWxlc3lzdGVtLCBhbmQgYW4gYXBwcm9hY2ggdG8KPiA+ID4gY2FsbCBvdmVycmlkZSBjcmVk
cyBpbiB0aGUgdmZzLiBOb25lIG9mIHRoZXNlIHNvbHV0aW9ucyBoYXZlIGNvdmVyZWQgYWxsCj4g
PiA+IG9mIHRoZSBhYm92ZSB1c2UtY2FzZXMuCj4gPiA+IAo+ID4gPiBUaGUgc29sdXRpb24gcHJv
cG9zZWQgaGVyZSBoYXMgaXQncyBvcmlnaW5zIGluIG11bHRpcGxlIGRpc2N1c3Npb25zCj4gPiA+
IGR1cmluZyBMaW51eCBQbHVtYmVycyAyMDE3IGR1cmluZyBhbmQgYWZ0ZXIgdGhlIGVuZCBvZiB0
aGUgY29udGFpbmVycwo+ID4gPiBtaWNyb2NvbmZlcmVuY2UuCj4gPiA+IFRvIHRoZSBiZXN0IG9m
IG15IGtub3dsZWRnZSB0aGlzIGludm9sdmVkIEFsZWtzYSwgU3TDqXBoYW5lLCBFcmljLCBEYXZp
ZCwKPiA+ID4gSmFtZXMsIGFuZCBteXNlbGYuIEEgdmFyaWFudCBvZiB0aGUgc29sdXRpb24gcHJv
cG9zZWQgaGVyZSBoYXMgYWxzbyBiZWVuCj4gPiA+IGRpc2N1c3NlZCwgYWdhaW4gdG8gdGhlIGJl
c3Qgb2YgbXkga25vd2xlZGdlLCBhZnRlciBhIExpbnV4IGNvbmZlcmVuY2UKPiA+ID4gaW4gU3Qu
IFBldGVyc2J1cmcgaW4gUnVzc2lhIGJldHdlZW4gQ2hyaXN0b3BoLCBUeWNobywgYW5kIG15c2Vs
ZiBpbiAyMDE3Cj4gPiA+IGFmdGVyIExpbnV4IFBsdW1iZXJzLgo+ID4gPiBJJ3ZlIHRha2VuIHRo
ZSB0aW1lIHRvIGZpbmFsbHkgaW1wbGVtZW50IGEgd29ya2luZyB2ZXJzaW9uIG9mIHRoaXMKPiA+
ID4gc29sdXRpb24gb3ZlciB0aGUgbGFzdCB3ZWVrcyB0byB0aGUgYmVzdCBvZiBteSBhYmlsaXRp
ZXMuIFR5Y2hvIGhhcwo+ID4gPiBzaWduZWQgdXAgZm9yIHRoaXMgc2xpZ3RobHkgY3JhenkgZW5k
ZWF2b3VyIGFzIHdlbGwgYW5kIGhlIGhhcyBoZWxwZWQKPiA+ID4gd2l0aCB0aGUgY29udmVyc2lv
biBvZiB0aGUgeGF0dHIgY29kZXBhdGhzLgo+ID4gPiAKPiA+ID4gVGhlIGNvcmUgaWRlYSBpcyB0
byBtYWtlIGlkbWFwcGluZ3MgYSBwcm9wZXJ0eSBvZiBzdHJ1Y3QgdmZzbW91bnQKPiA+ID4gaW5z
dGVhZCBvZiB0eWluZyBpdCB0byBhIHByb2Nlc3MgYmVpbmcgaW5zaWRlIG9mIGEgdXNlciBuYW1l
c3BhY2Ugd2hpY2gKPiA+ID4gaGFzIGJlZW4gdGhlIGNhc2UgZm9yIGFsbCBvdGhlciBwcm9wb3Nl
ZCBhcHByb2FjaGVzLgo+ID4gPiBJdCBtZWFucyB0aGF0IGlkbWFwcGluZ3MgYmVjb21lIGEgcHJv
cGVydHkgb2YgYmluZC1tb3VudHMsIGkuZS4gZWFjaAo+ID4gPiBiaW5kLW1vdW50IGNhbiBoYXZl
IGEgc2VwYXJhdGUgaWRtYXBwaW5nLiBUaGlzIGhhcyB0aGUgb2J2aW91cyBhZHZhbnRhZ2UKPiA+
ID4gdGhhdCBpZG1hcHBlZCBtb3VudHMgY2FuIGJlIGNyZWF0ZWQgaW5zaWRlIG9mIHRoZSBpbml0
aWFsIHVzZXIKPiA+ID4gbmFtZXNwYWNlLCBpLmUuIG9uIHRoZSBob3N0IGl0c2VsZiBpbnN0ZWFk
IG9mIHJlcXVpcmluZyB0aGUgY2FsbGVyIHRvIGJlCj4gPiA+IGxvY2F0ZWQgaW5zaWRlIG9mIGEg
dXNlciBuYW1lc3BhY2UuIFRoaXMgZW5hYmxlcyBzdWNoIHVzZS1jYXNlcyBhcyBlLmcuCj4gPiA+
IG1ha2luZyBhIHVzYiBzdGljayBhdmFpbGFibGUgaW4gbXVsdGlwbGUgbG9jYXRpb25zIHdpdGgg
ZGlmZmVyZW50Cj4gPiA+IGlkbWFwcGluZ3MgKHNlZSB0aGUgdmZhdCBwb3J0IHRoYXQgaXMgcGFy
dCBvZiB0aGlzIHBhdGNoIHNlcmllcykuCj4gPiA+IAo+ID4gPiBUaGUgdmZzbW91bnQgc3RydWN0
IGdhaW5zIGEgbmV3IHN0cnVjdCB1c2VyX25hbWVzcGFjZSBtZW1iZXIuIFRoZQo+ID4gPiBpZG1h
cHBpbmcgb2YgdGhlIHVzZXIgbmFtZXNwYWNlIGJlY29tZXMgdGhlIGlkbWFwcGluZyBvZiB0aGUg
bW91bnQuIEEKPiA+ID4gY2FsbGVyIHRoYXQgaXMgZWl0aGVyIHByaXZpbGVnZWQgd2l0aCByZXNw
ZWN0IHRvIHRoZSB1c2VyIG5hbWVzcGFjZSBvZgo+ID4gPiB0aGUgc3VwZXJibG9jayBvZiB0aGUg
dW5kZXJseWluZyBmaWxlc3lzdGVtIG9yIGEgY2FsbGVyIHRoYXQgaXMKPiA+ID4gcHJpdmlsZWdl
ZCB3aXRoIHJlc3BlY3QgdG8gdGhlIHVzZXIgbmFtZXNwYWNlIGEgbW91bnQgaGFzIGJlZW4gaWRt
YXBwZWQKPiA+ID4gd2l0aCBjYW4gY3JlYXRlIGEgbmV3IGJpbmQtbW91bnQgYW5kIG1hcmsgaXQg
d2l0aCBhIHVzZXIgbmFtZXNwYWNlLgo+ID4gCj4gPiBTbyBvbmUgd2F5IG9mIHRoaW5raW5nIGFi
b3V0IHRoaXMgaXMgdGhhdCBhIHVzZXIgbmFtZXNwYWNlIHRoYXQgaGFzIGFuIGlkbWFwcGVkIG1v
dW50IGNhbiwgZWZmZWN0aXZlbHksIGNyZWF0ZSBvciBjaG93biBmaWxlcyB3aXRoICphbnkqIG9u
LWRpc2sgdWlkIG9yIGdpZCBieSBkb2luZyBpdCBkaXJlY3RseSAoaWYgdGhhdCB1aWQgZXhpc3Rz
IGluLW5hbWVzcGFjZSwgd2hpY2ggaXMgbGlrZWx5IGZvciBpbnRlcmVzdGluZyBpZHMgbGlrZSAw
KSBvciBieSBjcmVhdGluZyBhIG5ldyB1c2VybnMgd2l0aCB0aGF0IGlkIGluc2lkZS4KPiA+IAo+
ID4gRm9yIGEgZmlsZSBzeXN0ZW0gdGhhdCBpcyBwcml2YXRlIHRvIGEgY29udGFpbmVyLCB0aGlz
IHNlZW1zIG1vZGVyYXRlbHkgc2FmZSwgYWx0aG91Z2ggdGhpcyBtYXkgZGVwZW5kIG9uIHdoYXQg
ZXhhY3RseSDigJxwcml2YXRl4oCdIG1lYW5zLiBXZSBwcm9iYWJseSB3YW50IGEgbWVjaGFuaXNt
IHN1Y2ggdGhhdCwgaWYgeW91IGFyZSBvdXRzaWRlIHRoZSBuYW1lc3BhY2UsIGEgcmVmZXJlbmNl
IHRvIGEgZmlsZSB3aXRoIHRoZSBuYW1lc3BhY2XigJlzIHZmc21udCBkb2VzIG5vdCBjb25mZXIg
c3VpZCBwcml2aWxlZ2UuCj4gPiAKPiA+IEltYWdpbmUgdGhlIGZvbGxvd2luZyBhdHRhY2s6IHVz
ZXIgY3JlYXRlcyBhIG5hbWVzcGFjZSB3aXRoIGEgcm9vdCB1c2VyIGFuZCBhcnJhbmdlcyB0byBn
ZXQgYW4gaWRtYXBwZWQgZnMsIGUuZy4gYnkgaW5zZXJ0aW5nIGFuIGV4dDQgdXNiIHN0aWNrIG9y
IHVzaW5nIHdoYXRldmVyIGNvbnRhaW5lciBtYW5hZ2VtZW50IHRvb2wgZG9lcyB0aGlzLiAgSW5z
aWRlIHRoZSBuYW1lc3BhY2UsIHRoZSB1c2VyIGNyZWF0ZXMgYSBzdWlkLXJvb3QgZmlsZS4KPiA+
IAo+ID4gTm93LCBvdXRzaWRlIHRoZSBuYW1lc3BhY2UsIHRoZSB1c2VyIGhhcyBwcml2aWxlZ2Ug
b3ZlciB0aGUgbmFtZXNwYWNlLiAgKEnigJltIGFzc3VtaW5nIHRoZXJlIGlzIHNvbWUgdG9vbCB0
aGF0IHdpbGwgaWRtYXAgdGhpbmdzIGluIGEgbmFtZXNwYWNlIG93bmVkIGJ5IGFuIHVucHJpdmls
ZWdlZCB1c2VyLCB3aGljaCBzZWVtcyBsaWtlbHkuKS4gU28gdGhlIHVzZXIgbWFrZXMgYSBuZXcg
YmluZCBtb3VudCBhbmQgaWYgbWFwcyBpdCB0byB0aGUgaW5pdCBuYW1lc3BhY2UuIEdhbWUgb3Zl
ci4KPiA+IAo+ID4gU28gSSB0aGluayB3ZSBuZWVkIHRvIGhhdmUgc29tZSBjb250cm9sIHRvIG1p
dGlnYXRlIHRoaXMgaW4gYSBjb21wcmVoZW5zaWJsZSB3YXkuIEEgYmlnIGhhbW1lciB3b3VsZCBi
ZSB0byByZXF1aXJlIG5vc3VpZC4gQSBzbWFsbGVyIGhhbW1lciBtaWdodCBiZSB0byBzYXkgdGhh
dCB5b3UgY2Fu4oCZdCBjcmVhdGUgYSBuZXcgaWRtYXBwZWQgbW91bnQgdW5sZXNzIHlvdSBoYXZl
IHByaXZpbGVnZSBvdmVyIHRoZSB1c2VybnMgdGhhdCB5b3Ugd2FudCB0byB1c2UgZm9yIHRoZSBp
ZG1hcCBhbmQgdG8gc2F5IHRoYXQgYSB2ZnNtbnTigJlzIHBhdGhzIGRvbuKAmXQgZG8gc3VpZCBv
dXRzaWRlIHRoZSBpZG1hcCBuYW1lc3BhY2UuICBXZSBhbHJlYWR5IGRvIHRoZSBsYXR0ZXIgZm9y
IHRoZSB2ZnNtbnTigJlzIG1udG5z4oCZcyB1c2VybnMuCj4gCj4gV2l0aCB0aGlzIHNlcmllcywg
aW4gb3JkZXIgdG8gY3JlYXRlIGFuIGlkbWFwcGVkIG1vdW50IHRoZSB1c2VyIG11c3QKPiBlaXRo
ZXIgYmUgY2FwX3N5c19hZG1pbiBpbiB0aGUgc3VwZXJibG9jayBvZiB0aGUgdW5kZXJseWluZyBm
aWxlc3lzdGVtCj4gb3IgaWYgdGhlIG1vdW50IGlzIGFscmVhZHkgaWRtYXBwZWQgYW5kIHRoZXkg
d2FudCB0byBjcmVhdGUgYW5vdGhlcgo+IGlkbWFwcGVkIG1vdW50IGZyb20gaXQgdGhleSBtdXN0
IGhhdmUgY2FwX3N5c19hZG1pbiBpbiB0aGUgdXNlcm5zIHRoYXQKPiB0aGUgbW91bnQgaXMgY3Vy
cnJlbnRseSBtYXJrZWQgd2l0aC4gSXQgaXMgYWxzbyBub3QgcG9zc2libGUgdG8gY2hhbmdlCj4g
YW4gaWRtYXBwZWQgbW91bnQgb25jZSBpdCBoYXMgYmVlbiBpZG1hcHBlZCwgaS5lLiB0aGUgdXNl
ciBtdXN0IGNyZWF0ZSBhCj4gbmV3IGRldGFjaGVkIGJpbmQtbW91bnQgZmlyc3QuCgpZZWFoIEkg
c3BlbnQgcXVpdGUgc29tZSB0aW1lIGxhc3QgbmlnaHQgdHJ5aW5nIHRvIGZpZ3VyZSBvdXQgdGhl
IHNjZW5hcmlvCnlvdSB3ZXJlIHByZXNlbnRpbmcsIGJ1dCBJIGZhaWxlZC4gIEFuZHksIGNvdWxk
IHlvdSBlaXRoZXIgcmVwaHJhc2Ugb3IKZ2l2ZSBhIG1vcmUgY29uY3JldGUgZW5kIHRvIGVuZCBh
dHRhY2sgc2NlbmFyaW8/Cl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fCkNvbnRhaW5lcnMgbWFpbGluZyBsaXN0CkNvbnRhaW5lcnNAbGlzdHMubGludXgtZm91
bmRhdGlvbi5vcmcKaHR0cHM6Ly9saXN0cy5saW51eGZvdW5kYXRpb24ub3JnL21haWxtYW4vbGlz
dGluZm8vY29udGFpbmVycw==
