Return-Path: <SRS0=U9nl=DH=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EFEDC4363D
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 23:25:04 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 04B57206F4
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 23:25:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 04B57206F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.pizza
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id A99618506B;
	Wed, 30 Sep 2020 23:25:03 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id KnwGVRJw12cB; Wed, 30 Sep 2020 23:25:02 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id B722E84D2E;
	Wed, 30 Sep 2020 23:25:02 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 9EBD6C0889;
	Wed, 30 Sep 2020 23:25:02 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id C8C84C0051
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 23:25:01 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id B077187234
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 23:25:01 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id Dfnqk-QjRQGF
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 23:25:01 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from wnew2-smtp.messagingengine.com (wnew2-smtp.messagingengine.com
 [64.147.123.27])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 2D635871AD
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 23:25:01 +0000 (UTC)
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
 by mailnew.west.internal (Postfix) with ESMTP id 7DAB696C;
 Wed, 30 Sep 2020 19:24:59 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
 by compute4.internal (MEProxy); Wed, 30 Sep 2020 19:25:00 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tycho.pizza; h=
 date:from:to:cc:subject:message-id:references:mime-version
 :content-type:content-transfer-encoding:in-reply-to; s=fm1; bh=U
 Uv/ycHKk0VmQ9jog/Fu42gbcuiVRCdjLJbHAyQkcMA=; b=ivLuxv4Q55f1KpcuS
 +cwKbc+rREjpPqhNs+z6z6vjquCNIcj/E8v8Busu2VtTJ16rgl8jXLEQjMa40b1D
 ReI1SEVJg30OsggeJY9AInJEz/bd9bbSxaQL8V53iPVzbmGxfhHD4MFwlVStlBwX
 aqRjDgpgWhsmi6JhdsEugslTbAqczxPq5QFgGIMssgwiFRxmgLKxaHJkOqd33zb+
 MuLo/0gCKdB1eeNJEp1lVmD+y7WeJqOoItZ5ISqVZOD0fTGSEijlsx7T3sNwFh83
 WW3/9jZdXT1zRIKZKd3Sk1e9PtvZJzDJjWvFXIMzjAN9WPjctu81EuHOPrC5sD1E
 x0vuw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
 messagingengine.com; h=cc:content-transfer-encoding:content-type
 :date:from:in-reply-to:message-id:mime-version:references
 :subject:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender
 :x-sasl-enc; s=fm3; bh=UUv/ycHKk0VmQ9jog/Fu42gbcuiVRCdjLJbHAyQkc
 MA=; b=NiIOs+5J+ArBtzNXG9vmBi8u7JjTh87LIZHMCkPCZH2PN4i+5633Sijoe
 ouCmaU+C+bvwasFuxNWPFL/DlP77sTXfxsoK/g6MYoImqKTejhm4xwtx2ecJqSJh
 /Kx4k2Mcpn9Z2DX63sPvi270Mnu6uRs7l3eoAbVYL8VAhJGK9kq3fswLVBPOxisp
 Fw8s46jiYOVH8cy0i5Ov/yR7Ljysxlup7/9XHm5HZF8PLwyMPrqZOaDFyZ5kYp9i
 8rNnWKVPpINdn/CzafZq0hA4cAHRvJuhacxWIfGhv2QDoGvdLz9m39k+2YlpcD9D
 8anKe2R87M80SjVwpdVQinitLhbIA==
X-ME-Sender: <xms:yhN1X9H9snWiSjRa58ptv2FGpb0ejiIwBgz0Vxgf8oUxCBJTFTGSTw>
 <xme:yhN1XyX04W_qDhH9mL9Eyd4Nv8JDhhy3Nwt2FaPz3AlwpsKaBLdIXHCc6r5UofNA8
 MdXk4zdRwpO886sjl0>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedujedrfeefgddvvdcutefuodetggdotefrodftvf
 curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
 uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
 fjughrpeffhffvuffkfhggtggugfgjsehtkeertddttdejnecuhfhrohhmpefvhigthhho
 ucetnhguvghrshgvnhcuoehthigthhhosehthigthhhordhpihiiiigrqeenucggtffrrg
 htthgvrhhnpefhuedvvdelieevgeegjeeukeeuleejtdejfeetfeeujeefvdeltdethffh
 ueekffenucfkphepjeefrddvudejrddutddriedtnecuvehluhhsthgvrhfuihiivgeptd
 enucfrrghrrghmpehmrghilhhfrhhomhepthihtghhohesthihtghhohdrphhiiiiirg
X-ME-Proxy: <xmx:yhN1X_KJCsR49coiERRTusNVu4W6LEty5EA-9M2lS4RyJADZ5xQxmA>
 <xmx:yhN1XzGUZzwU4FtsJ9oTnlhQyjxNwOvP4Ao75Mv1L6MQTWidE9f2Mw>
 <xmx:yhN1XzXjrR73t55KZ2EZyMOBk2zVvk1dFlU4TuiKiVpURYMIQ09lbA>
 <xmx:yxN1X0t5pelLdbmhvSRf_uhEPTbbqZwnT9SjA1c3AMwZl1T6qsRQScXk04aFhoda>
Received: from cisco (c-73-217-10-60.hsd1.co.comcast.net [73.217.10.60])
 by mail.messagingengine.com (Postfix) with ESMTPA id 1A15E3064610;
 Wed, 30 Sep 2020 19:24:57 -0400 (EDT)
Date: Wed, 30 Sep 2020 17:24:56 -0600
From: Tycho Andersen <tycho@tycho.pizza>
To: Jann Horn <jannh@google.com>
Subject: Re: For review: seccomp_user_notif(2) manual page
Message-ID: <20200930232456.GB1260245@cisco>
References: <45f07f17-18b6-d187-0914-6f341fe90857@gmail.com>
 <20200930150330.GC284424@cisco>
 <8bcd956f-58d2-d2f0-ca7c-0a30f3fcd5b8@gmail.com>
 <20200930230327.GA1260245@cisco>
 <CAG48ez1VOUEHVQyo-2+uO7J+-jN5rh7=KmrMJiPaFjwCbKR1Sg@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAG48ez1VOUEHVQyo-2+uO7J+-jN5rh7=KmrMJiPaFjwCbKR1Sg@mail.gmail.com>
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

T24gVGh1LCBPY3QgMDEsIDIwMjAgYXQgMDE6MTE6MzNBTSArMDIwMCwgSmFubiBIb3JuIHdyb3Rl
Ogo+IE9uIFRodSwgT2N0IDEsIDIwMjAgYXQgMTowMyBBTSBUeWNobyBBbmRlcnNlbiA8dHljaG9A
dHljaG8ucGl6emE+IHdyb3RlOgo+ID4gT24gV2VkLCBTZXAgMzAsIDIwMjAgYXQgMTA6MzQ6NTFQ
TSArMDIwMCwgTWljaGFlbCBLZXJyaXNrIChtYW4tcGFnZXMpIHdyb3RlOgo+ID4gPiBPbiA5LzMw
LzIwIDU6MDMgUE0sIFR5Y2hvIEFuZGVyc2VuIHdyb3RlOgo+ID4gPiA+IE9uIFdlZCwgU2VwIDMw
LCAyMDIwIGF0IDAxOjA3OjM4UE0gKzAyMDAsIE1pY2hhZWwgS2VycmlzayAobWFuLXBhZ2VzKSB3
cm90ZToKPiA+ID4gPj4gICAgICAgIOKUjOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKU
gOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKU
gOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKU
gOKUgOKUgOKUgOKUgOKUkAo+ID4gPiA+PiAgICAgICAg4pSCRklYTUUgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICDilIIKPiA+ID4gPj4gICAgICAgIOKUnOKU
gOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKU
gOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKU
gOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUpAo+ID4gPiA+PiAg
ICAgICAg4pSCRnJvbSBteSBleHBlcmltZW50cywgIGl0ICBhcHBlYXJzICB0aGF0ICBpZiAgYSAg
U0VD4oCQIOKUggo+ID4gPiA+PiAgICAgICAg4pSCQ09NUF9JT0NUTF9OT1RJRl9SRUNWICAgaXMg
IGRvbmUgIGFmdGVyICB0aGUgIHRhcmdldCDilIIKPiA+ID4gPj4gICAgICAgIOKUgnByb2Nlc3Mg
dGVybWluYXRlcywgdGhlbiB0aGUgaW9jdGwoKSAgc2ltcGx5ICBibG9ja3Mg4pSCCj4gPiA+ID4+
ICAgICAgICDilIIocmF0aGVyIHRoYW4gcmV0dXJuaW5nIGFuIGVycm9yIHRvIGluZGljYXRlIHRo
YXQgdGhlIOKUggo+ID4gPiA+PiAgICAgICAg4pSCdGFyZ2V0IHByb2Nlc3Mgbm8gbG9uZ2VyIGV4
aXN0cykuICAgICAgICAgICAgICAgICAgICDilIIKPiA+ID4gPgo+ID4gPiA+IFllYWgsIEkgdGhp
bmsgQ2hyaXN0aWFuIHdhbnRlZCB0byBmaXggdGhpcyBhdCBzb21lIHBvaW50LAo+ID4gPgo+ID4g
PiBEbyB5b3UgaGF2ZSBhIHBvaW50ZXIgdGhhdCBkaXNjdXNzaW9uPyBJIGNvdWxkIG5vdCBmaW5k
IGl0IHdpdGggYQo+ID4gPiBxdWljayBzZWFyY2guCj4gPiA+Cj4gPiA+ID4gYnV0IGl0J3MgYQo+
ID4gPiA+IGJpdCBzdGlja3kgdG8gZG8uCj4gPiA+Cj4gPiA+IENhbiB5b3Ugc2F5IGEgZmV3IHdv
cmRzIGFib3V0IHRoZSBuYXR1cmUgb2YgdGhlIHByb2JsZW0/Cj4gPgo+ID4gSSByZW1lbWJlcmVk
IHdyb25nLCBpdCdzIGFjdHVhbGx5IGluIHRoZSB0cmVlOiA5OWNkYjhiOWE1NzMgKCJzZWNjb21w
Ogo+ID4gbm90aWZ5IGFib3V0IHVudXNlZCBmaWx0ZXIiKS4gU28gbWF5YmUgdGhlcmUncyBhIGJ1
ZyBoZXJlPwo+IAo+IFRoYXQgdGhpbmcgb25seSBub3RpZmllcyBvbiAtPnBvbGwsIGl0IGRvZXNu
J3QgdW5ibG9jayBpb2N0bHM7IGFuZAo+IE1pY2hhZWwncyBzYW1wbGUgY29kZSB1c2VzIFNFQ0NP
TVBfSU9DVExfTk9USUZfUkVDViB0byB3YWl0LiBTbyB0aGF0Cj4gY29tbWl0IGRvZXNuJ3QgaGF2
ZSBhbnkgZWZmZWN0IG9uIHRoaXMga2luZCBvZiB1c2FnZS4KClllcywgdGhhbmtzLiBBbmQgdGhl
IG9uZXMgc3R1Y2sgaW4gUkVDViBhcmUgd2FpdGluZyBvbiBhIHNlbWFwaG9yZSBzbwp3ZSBkb24n
dCBoYXZlIGEgY291bnQgb2YgYWxsIG9mIHRoZW0sIHVuZm9ydHVuYXRlbHkuCgpXZSBjb3VsZCBt
YXliZSBsb29rIGluc2lkZSB0aGUgd2FpdF9saXN0LCBidXQgdGhhdCB3aWxsIHByb2JhYmx5IG1h
a2UKcGVvcGxlIGFuZ3J5IDopCgpUeWNobwpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fXwpDb250YWluZXJzIG1haWxpbmcgbGlzdApDb250YWluZXJzQGxpc3Rz
LmxpbnV4LWZvdW5kYXRpb24ub3JnCmh0dHBzOi8vbGlzdHMubGludXhmb3VuZGF0aW9uLm9yZy9t
YWlsbWFuL2xpc3RpbmZvL2NvbnRhaW5lcnM=
