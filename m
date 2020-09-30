Return-Path: <SRS0=U9nl=DH=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD302C4741F
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 23:03:39 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 19A072075F
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 23:03:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19A072075F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.pizza
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id B7F698568D;
	Wed, 30 Sep 2020 23:03:38 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id MAkWLRO9I0di; Wed, 30 Sep 2020 23:03:37 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 98AA8855D8;
	Wed, 30 Sep 2020 23:03:37 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 7A5EBC016F;
	Wed, 30 Sep 2020 23:03:37 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 7E7A0C0051
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 23:03:36 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 5CE1E86DF1
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 23:03:36 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 1Pc0bKJnRoZw
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 23:03:34 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from wnew2-smtp.messagingengine.com (wnew2-smtp.messagingengine.com
 [64.147.123.27])
 by hemlock.osuosl.org (Postfix) with ESMTPS id AF2EE86DD6
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 23:03:34 +0000 (UTC)
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
 by mailnew.west.internal (Postfix) with ESMTP id C3B1D9E6;
 Wed, 30 Sep 2020 19:03:31 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
 by compute4.internal (MEProxy); Wed, 30 Sep 2020 19:03:32 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tycho.pizza; h=
 date:from:to:cc:subject:message-id:references:mime-version
 :content-type:content-transfer-encoding:in-reply-to; s=fm1; bh=X
 tI1tB6xpmgOimSVGwz0nFQ2Aj6bySi3TmcGUJtNKDE=; b=YjqRrknkoRvFSexBK
 tWIx+0K77PM+g0q6zBEER8Mt7P/9XETbBwjWGh7driOG1BR0O0UdsvYOnDTthRRc
 ZtHljtdgwIjc9VuXtrIcDEuKUTe6uU0+QeVPTIGm6he4GXmt5AsJuNGuoQP8On+1
 T7L2sLAcw2uTnMsQOtb02PP3pBoDmPd2KeF8pXrWX8dmLM/KPPvGosaD6qnSEHdA
 orkj6krPdLFTt3LWnJgHvHVeIQu8JeHkZR5UPUJiZ9AKn7+zmcYtk9vPPYQAIW67
 8rfHmpgRHqQbLV/Gi6um89WtsDHHNE9+JHhA5SK3BDv7cZeA3D55UAstc6hoS8a2
 1ddsQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
 messagingengine.com; h=cc:content-transfer-encoding:content-type
 :date:from:in-reply-to:message-id:mime-version:references
 :subject:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender
 :x-sasl-enc; s=fm3; bh=XtI1tB6xpmgOimSVGwz0nFQ2Aj6bySi3TmcGUJtNK
 DE=; b=NQaPjYn0VYYM79zUlgVbI/HpUJfbGPk21tjYqk0fMqaQ+2xwfkmvV6TIS
 pWiapS+Fyws9Z5VApdOhGuBwN/Y80rPEh+aeZiXrI373/amdb0AVVblB4/LcZqzR
 EX7YCPM9MOVnsisrs8onXRMXzKU/1SA8FJrP+OGAh5APWHI6LdFxOepBQLBNFo+Q
 s0DQWONJfi5XBUNM+PSLrC9UyGEAm5fPUVKhJUUCHwnm2vwIfMm0NXkV+ykLZA1D
 ZB8lJ2B+MBD/0IkkzdX8wFplAMhfKL6aJEq5E4vvQ9aRHwPQcBoaTM0hkJ4wMSm3
 0Jabe0jwdeHE+vpIy58XYf+HZv2jg==
X-ME-Sender: <xms:wg51X5uj72nxaBN5fR3YSdO-qFbV_CB9A-VQ8jm8XnNanmrnzt8aLg>
 <xme:wg51XycH4OzurAZwKlJz8r0cp0T0_Pct30D0uSeq7bp5L_Cugw99nNA6sHHmSOQUz
 yT9SdbT9jsYltIC0PI>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedujedrfeefgddukecutefuodetggdotefrodftvf
 curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
 uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
 fjughrpeffhffvuffkfhggtggugfgjsehtkeertddttdejnecuhfhrohhmpefvhigthhho
 ucetnhguvghrshgvnhcuoehthigthhhosehthigthhhordhpihiiiigrqeenucggtffrrg
 htthgvrhhnpefhuedvvdelieevgeegjeeukeeuleejtdejfeetfeeujeefvdeltdethffh
 ueekffenucfkphepjeefrddvudejrddutddriedtnecuvehluhhsthgvrhfuihiivgeptd
 enucfrrghrrghmpehmrghilhhfrhhomhepthihtghhohesthihtghhohdrphhiiiiirg
X-ME-Proxy: <xmx:wg51X8xtJIO64eSz3Q3M080KKG4JsHDj7Xiqdk0jQHSVU5u4kJcJjg>
 <xmx:wg51XwN0G_bf6PI8i2pSy7aoPH3QowMLTbZ9x9Tu8Penm-lNtPlKbQ>
 <xmx:wg51X5_b8jwQjzwKX0LihTsNRq6mbv5nYniW8rg6cHHtW5WkhK8iqw>
 <xmx:ww51X9WkyHuURkpU7U4m7pwqtnbF1rpD9uOCHNOs5bTWUUeKuWgnsGDTfR_ZJcnT>
Received: from cisco (c-73-217-10-60.hsd1.co.comcast.net [73.217.10.60])
 by mail.messagingengine.com (Postfix) with ESMTPA id 1083A3064686;
 Wed, 30 Sep 2020 19:03:29 -0400 (EDT)
Date: Wed, 30 Sep 2020 17:03:27 -0600
From: Tycho Andersen <tycho@tycho.pizza>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Subject: Re: For review: seccomp_user_notif(2) manual page
Message-ID: <20200930230327.GA1260245@cisco>
References: <45f07f17-18b6-d187-0914-6f341fe90857@gmail.com>
 <20200930150330.GC284424@cisco>
 <8bcd956f-58d2-d2f0-ca7c-0a30f3fcd5b8@gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <8bcd956f-58d2-d2f0-ca7c-0a30f3fcd5b8@gmail.com>
Cc: linux-man <linux-man@vger.kernel.org>, Song Liu <songliubraving@fb.com>,
 wad@chromium.org, Kees Cook <keescook@chromium.org>,
 Daniel Borkmann <daniel@iogearbox.net>, Jann Horn <jannh@google.com>,
 Robert Sesek <rsesek@google.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 lkml <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
 Giuseppe Scrivano <gscrivan@redhat.com>, bpf@vger.kernel.org,
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

T24gV2VkLCBTZXAgMzAsIDIwMjAgYXQgMTA6MzQ6NTFQTSArMDIwMCwgTWljaGFlbCBLZXJyaXNr
IChtYW4tcGFnZXMpIHdyb3RlOgo+IEhpIFR5Y2hvLAo+IAo+IFRoYW5rcyBmb3IgdGFraW5nIHRp
bWUgdG8gbG9vayBhdCB0aGUgcGFnZSEKPiAKPiBPbiA5LzMwLzIwIDU6MDMgUE0sIFR5Y2hvIEFu
ZGVyc2VuIHdyb3RlOgo+ID4gT24gV2VkLCBTZXAgMzAsIDIwMjAgYXQgMDE6MDc6MzhQTSArMDIw
MCwgTWljaGFlbCBLZXJyaXNrIChtYW4tcGFnZXMpIHdyb3RlOgo+ID4+ICAgICAgICAyLiBJbiBv
cmRlciB0aGF0IHRoZSBzdXBlcnZpc29yIHByb2Nlc3MgY2FuIG9idGFpbiAgbm90aWZpY2F0aW9u
cwo+ID4+ICAgICAgICAgICB1c2luZyAgdGhlICBsaXN0ZW5pbmcgIGZpbGUgIGRlc2NyaXB0b3Is
IChhIGR1cGxpY2F0ZSBvZikgdGhhdAo+ID4+ICAgICAgICAgICBmaWxlIGRlc2NyaXB0b3IgbXVz
dCBiZSBwYXNzZWQgZnJvbSB0aGUgdGFyZ2V0IHByb2Nlc3MgdG8gIHRoZQo+ID4+ICAgICAgICAg
ICBzdXBlcnZpc29yIHByb2Nlc3MuICBPbmUgd2F5IGluIHdoaWNoIHRoaXMgY291bGQgYmUgZG9u
ZSBpcyBieQo+ID4+ICAgICAgICAgICBwYXNzaW5nIHRoZSBmaWxlIGRlc2NyaXB0b3Igb3ZlciBh
IFVOSVggZG9tYWluIHNvY2tldCAgY29ubmVj4oCQCj4gPj4gICAgICAgICAgIHRpb24gYmV0d2Vl
biB0aGUgdHdvIHByb2Nlc3NlcyAodXNpbmcgdGhlIFNDTV9SSUdIVFMgYW5jaWxsYXJ5Cj4gPj4g
ICAgICAgICAgIG1lc3NhZ2UgdHlwZSBkZXNjcmliZWQgaW4gdW5peCg3KSkuICAgQW5vdGhlciAg
cG9zc2liaWxpdHkgIGlzCj4gPj4gICAgICAgICAgIHRoYXQgIHRoZSAgc3VwZXJ2aXNvciAgbWln
aHQgIGluaGVyaXQgIHRoZSBmaWxlIGRlc2NyaXB0b3IgdmlhCj4gPj4gICAgICAgICAgIGZvcmso
MikuCj4gPiAKPiA+IEl0IGlzIHRlY2huaWNhbGx5IHBvc3NpYmxlIHRvIGluaGVyaXQgdGhlIGZk
IHZpYSBmb3JrLCBidXQgaXMgaXQKPiA+IHJlYWxseSB0aGF0IHVzZWZ1bD8gVGhlIGNoaWxkIHBy
b2Nlc3Mgd291bGRuJ3QgYmUgYWJsZSB0byBhY3R1YWxseSBkbwo+ID4gdGhlIHN5c2NhbGwgaW4g
cXVlc3Rpb24sIHNpbmNlIGl0IHdvdWxkIGhhdmUgdGhlIHNhbWUgZmlsdGVyLgo+IAo+IEQnb2gh
IFllcywgb2YgY291cnNlLgo+IAo+IEkgdGhpbmsgSSB3YXMgcmVhY2hpbmcgYmVjYXVzZSBpbiBh
biBlYXJsaWVyIGNvbnZlcnNhdGlvbgo+IHlvdSByZXBsaWVkOgo+IAo+IFtbCj4gPiAzLiBUaGUg
InRhcmdldCBwcm9jZXNzIiBwYXNzZXMgdGhlICJsaXN0ZW5pbmcgZmlsZSBkZXNjcmlwdG9yIgo+
ID4gICAgdG8gdGhlICJtb25pdG9yaW5nIHByb2Nlc3MiIHZpYSB0aGUgVU5JWCBkb21haW4gc29j
a2V0Lgo+IAo+IG9yIHNvbWUgb3RoZXIgbWVhbnMsIGl0IGRvZXNuJ3QgaGF2ZSB0byBiZSB3aXRo
IFNDTV9SSUdIVFMuCj4gXV0KPiAKPiBTbywgd2hhdCBvdGhlciBtZWFucz8KPiAKPiBBbnl3YXks
IEkgcmVtb3ZlZCB0aGUgc2VudGVuY2UgbWVudGlvbmluZyBmb3JrKCkuCgpXaGF0ZXZlciBtZWFu
cyBwZW9wbGUgd2FudCA6KS4gZm9yaygpIGNvdWxkIHdvcmsgKGl0J3MgaG93IHNvbWUgb2YgdGhl
CnRlc3RzIGZvciB0aGlzIGZlYXR1cmUgd29yaywgYnV0IGl0J3Mgbm90IHBhcnRpY3VsYXJseSB1
c2VmdWwgSSBkb24ndAp0aGluayksIGNsb25lKENMT05FX0ZJTEVTKSBpcyBzaW1pbGFyLCBzZWNj
b21wX3B1dGZkLCBvciBtYXliZSBldmVuCmNsb25pbmcgaXQgdmlhIHNvbWUgcGlkZmQgaW50ZXJm
YWNlIHRoYXQgbWlnaHQgYmUgaW52ZW50ZWQgZm9yCnJlLW9wZW5pbmcgZmlsZXMuCgo+ID4+ICAg
ICAgICDilIzilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDi
lIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDi
lIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilJAK
PiA+PiAgICAgICAg4pSCRklYTUUgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICDilIIKPiA+PiAgICAgICAg4pSc4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA
4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA
4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA
4pSA4pSA4pSA4pSA4pSA4pSA4pSkCj4gPj4gICAgICAgIOKUgkZyb20gbXkgZXhwZXJpbWVudHMs
ICBpdCAgYXBwZWFycyAgdGhhdCAgaWYgIGEgIFNFQ+KAkCDilIIKPiA+PiAgICAgICAg4pSCQ09N
UF9JT0NUTF9OT1RJRl9SRUNWICAgaXMgIGRvbmUgIGFmdGVyICB0aGUgIHRhcmdldCDilIIKPiA+
PiAgICAgICAg4pSCcHJvY2VzcyB0ZXJtaW5hdGVzLCB0aGVuIHRoZSBpb2N0bCgpICBzaW1wbHkg
IGJsb2NrcyDilIIKPiA+PiAgICAgICAg4pSCKHJhdGhlciB0aGFuIHJldHVybmluZyBhbiBlcnJv
ciB0byBpbmRpY2F0ZSB0aGF0IHRoZSDilIIKPiA+PiAgICAgICAg4pSCdGFyZ2V0IHByb2Nlc3Mg
bm8gbG9uZ2VyIGV4aXN0cykuICAgICAgICAgICAgICAgICAgICDilIIKPiA+IAo+ID4gWWVhaCwg
SSB0aGluayBDaHJpc3RpYW4gd2FudGVkIHRvIGZpeCB0aGlzIGF0IHNvbWUgcG9pbnQsCj4gCj4g
RG8geW91IGhhdmUgYSBwb2ludGVyIHRoYXQgZGlzY3Vzc2lvbj8gSSBjb3VsZCBub3QgZmluZCBp
dCB3aXRoIGEgCj4gcXVpY2sgc2VhcmNoLgo+IAo+ID4gYnV0IGl0J3MgYQo+ID4gYml0IHN0aWNr
eSB0byBkby4KPiAKPiBDYW4geW91IHNheSBhIGZldyB3b3JkcyBhYm91dCB0aGUgbmF0dXJlIG9m
IHRoZSBwcm9ibGVtPwoKSSByZW1lbWJlcmVkIHdyb25nLCBpdCdzIGFjdHVhbGx5IGluIHRoZSB0
cmVlOiA5OWNkYjhiOWE1NzMgKCJzZWNjb21wOgpub3RpZnkgYWJvdXQgdW51c2VkIGZpbHRlciIp
LiBTbyBtYXliZSB0aGVyZSdzIGEgYnVnIGhlcmU/Cgo+ID4+ICAgICAgICDilIzilIDilIDilIDi
lIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDi
lIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDi
lIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilJAKPiA+PiAgICAgICAg4pSCRklY
TUUgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICDilIIKPiA+
PiAgICAgICAg4pSc4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA
4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA
4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA
4pSkCj4gPj4gICAgICAgIOKUgkludGVyZXN0aW5nbHksIGFmdGVyIHRoZSBldmVudCAgaGFkICBi
ZWVuICByZWNlaXZlZCwg4pSCCj4gPj4gICAgICAgIOKUgnRoZSAgZmlsZSBkZXNjcmlwdG9yIGlu
ZGljYXRlcyBhcyB3cml0YWJsZSAodmVyaWZpZWQg4pSCCj4gPj4gICAgICAgIOKUgmZyb20gdGhl
IHNvdXJjZSBjb2RlIGFuZCBieSBleHBlcmltZW50KS4gSG93IGlzIHRoaXMg4pSCCj4gPj4gICAg
ICAgIOKUgnVzZWZ1bD8gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAg4pSCCj4gPiAKPiA+IFlvdSdyZSBzYXlpbmcgaXQgc2hvdWxkIGp1c3QgZG8gRVBPTExPVVQg
YW5kIG5vdCBFUE9MTFdSTk9STT8gU2VlbXMKPiA+IHJlYXNvbmFibGUuCj4gCj4gTm8sIEknbSBz
YXlpbmcgc29tZXRoaW5nIG1vcmUgZnVuZGFtZW50YWw6IHdoeSBpcyB0aGUgRkQgaW5kaWNhdGlu
ZyBhcwo+IHdyaXRhYmxlPyBDYW4geW91IHdyaXRlIHNvbWV0aGluZyB0byBpdD8gSWYgeWVzLCB3
aGF0PyBJZiBub3QsIHRoZW4KPiB3aHkgZG8gdGhlc2UgQVBJcyB3YW50IHRvIHNheSB0aGF0IHRo
ZSBGRCBpcyB3cml0YWJsZT8KCllvdSBjYW4ndCB2aWEgcmVhZCgyKSBvciB3cml0ZSgyKSwgYnV0
IGNvbmNlcHR1YWxseSBOT1RJRllfUkVDViBhbmQKTk9USUZZX1NFTkQgYXJlIHJlYWRpbmcgYW5k
IHdyaXRpbmcgZXZlbnRzIGZyb20gdGhlIGZkLiBJIGRvbid0IGtub3cKdGhhdCBtdWNoIGFib3V0
IHRoZSBwb2xsIGludGVyZmFjZSB0aG91Z2ggLS0gaXMgaXQgcG9zc2libGUgdG8KaW5kaWNhdGUg
ImhlcmUncyBhIHBzZXVkby1yZWFkIGV2ZW50Ij8gSXQgZGlkbid0IGxvb2sgbGlrZSBpdCwgc28g
SQpqdXN0IChhYi0pdXNlZCBQT0xMSU4gYW5kIFBPTExPVVQsIGJ1dCBwcm9iYWJseSB0aGF0J3Mg
d3JvbmcuCgpUeWNobwpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fXwpDb250YWluZXJzIG1haWxpbmcgbGlzdApDb250YWluZXJzQGxpc3RzLmxpbnV4LWZvdW5k
YXRpb24ub3JnCmh0dHBzOi8vbGlzdHMubGludXhmb3VuZGF0aW9uLm9yZy9tYWlsbWFuL2xpc3Rp
bmZvL2NvbnRhaW5lcnM=
