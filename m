Return-Path: <SRS0=NWjS=FF=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99908C64E7B
	for <containers@archiver.kernel.org>; Tue,  1 Dec 2020 10:29:01 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id D75CE2080A
	for <containers@archiver.kernel.org>; Tue,  1 Dec 2020 10:29:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D75CE2080A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 4328986D50;
	Tue,  1 Dec 2020 10:29:00 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id O0vrq1dFf64H; Tue,  1 Dec 2020 10:28:59 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id A274D86D34;
	Tue,  1 Dec 2020 10:28:59 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 893A8C163C;
	Tue,  1 Dec 2020 10:28:59 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 3D499C0052
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Dec 2020 10:28:58 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 1FE3A86B34
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Dec 2020 10:28:58 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id x_CrtYpntMvC
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Dec 2020 10:28:57 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id A4A2A86AC8
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Dec 2020 10:28:57 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kk2to-0007qT-Na; Tue, 01 Dec 2020 10:28:44 +0000
Date: Tue, 1 Dec 2020 11:28:42 +0100
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Mauricio =?utf-8?Q?V=C3=A1squez?= Bernal <mauricio@kinvolk.io>
Subject: Re: [PATCH v3 33/38] ext4: support idmapped mounts
Message-ID: <20201201102842.ycodrxuxjwt4jyoa@wittgenstein>
References: <20201128213527.2669807-1-christian.brauner@ubuntu.com>
 <20201128213527.2669807-34-christian.brauner@ubuntu.com>
 <CAHap4zvDuSpZzeyZPc61mQURu_0oGKjkiROohYXkAFYyD85Vvw@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAHap4zvDuSpZzeyZPc61mQURu_0oGKjkiROohYXkAFYyD85Vvw@mail.gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, Mimi Zohar <zohar@linux.ibm.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>, Christoph Hellwig <hch@lst.de>,
 Tycho Andersen <tycho@tycho.ws>, Paul Moore <paul@paul-moore.com>,
 Jonathan Corbet <corbet@lwn.net>, smbarber@chromium.org,
 Christoph Hellwig <hch@infradead.org>,
 Casey Schaufler <casey@schaufler-ca.com>, linux-ext4@vger.kernel.org,
 Mrunal Patel <mpatel@redhat.com>, Kees Cook <keescook@chromium.org>,
 Arnd Bergmann <arnd@arndb.de>, selinux@vger.kernel.org,
 Josh Triplett <josh@joshtriplett.org>,
 Seth Forshee <seth.forshee@canonical.com>, Aleksa Sarai <cyphar@cyphar.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Lennart Poettering <lennart@poettering.net>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>, David Howells <dhowells@redhat.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 containers@lists.linux-foundation.org, fstests@vger.kernel.org,
 linux-security-module@vger.kernel.org,
 "Eric W. Biederman" <ebiederm@xmission.com>, linux-api@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, Alban Crequy <alban@kinvolk.io>,
 linux-integrity@vger.kernel.org,
 Stephen Smalley <stephen.smalley.work@gmail.com>, Todd Kjos <tkjos@google.com>
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

T24gTW9uLCBOb3YgMzAsIDIwMjAgYXQgMDU6NTI6MDRQTSAtMDUwMCwgTWF1cmljaW8gVsOhc3F1
ZXogQmVybmFsIHdyb3RlOgo+ID4gZGlmZiAtLWdpdCBhL2ZzL2V4dDQvS2NvbmZpZyBiL2ZzL2V4
dDQvS2NvbmZpZwo+ID4gaW5kZXggNjE5ZGQzNWRkZDQ4Li41OTE4YzA1Y2ZlNWIgMTAwNjQ0Cj4g
PiAtLS0gYS9mcy9leHQ0L0tjb25maWcKPiA+ICsrKyBiL2ZzL2V4dDQvS2NvbmZpZwo+ID4gQEAg
LTExOCwzICsxMTgsMTIgQEAgY29uZmlnIEVYVDRfS1VOSVRfVEVTVFMKPiA+ICAgICAgICAgICB0
byB0aGUgS1VuaXQgZG9jdW1lbnRhdGlvbiBpbiBEb2N1bWVudGF0aW9uL2Rldi10b29scy9rdW5p
dC8uCj4gPgo+ID4gICAgICAgICAgIElmIHVuc3VyZSwgc2F5IE4uCj4gPiArCj4gPiArY29uZmln
IEVYVDRfSURNQVBfTU9VTlRTCj4gPiArICAgICAgIGJvb2wgIlN1cHBvcnQgdmZzIGlkbWFwcGVk
IG1vdW50cyBpbiBleHQ0Igo+ID4gKyAgICAgICBkZXBlbmRzIG9uIEVYVDRfRlMKPiA+ICsgICAg
ICAgZGVmYXVsdCBuCj4gPiArICAgICAgIGhlbHAKPiA+ICsgICAgICAgICBUaGUgdmZzIGFsbG93
cyB0byBleHBvc2UgYSBmaWxlc3lzdGVtIGF0IGRpZmZlcmVudCBtb3VudHBvaW50cyB3aXRoCj4g
PiArICAgICAgICAgZGlmZmVybmV0IGlkbWFwcGluZ3MuIEFsbG93IGV4dDQgdG8gYmUgZXhwb3Nl
ZCB0aHJvdWdoIGlkbWFwcGVkCj4gCj4gcy9kaWZmZXJuZXQvZGlmZmVyZW50L2cKCkZpeGVkLCB0
aGFua3MhCkNocmlzdGlhbgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fXwpDb250YWluZXJzIG1haWxpbmcgbGlzdApDb250YWluZXJzQGxpc3RzLmxpbnV4LWZv
dW5kYXRpb24ub3JnCmh0dHBzOi8vbGlzdHMubGludXhmb3VuZGF0aW9uLm9yZy9tYWlsbWFuL2xp
c3RpbmZvL2NvbnRhaW5lcnM=
