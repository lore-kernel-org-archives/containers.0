Return-Path: <SRS0=YWEV=GP=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6154EC43381
	for <containers@archiver.kernel.org>; Tue, 12 Jan 2021 22:13:55 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id EDC5B2310A
	for <containers@archiver.kernel.org>; Tue, 12 Jan 2021 22:13:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EDC5B2310A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 7329C8558D;
	Tue, 12 Jan 2021 22:13:54 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id xgsjYPwQmfBT; Tue, 12 Jan 2021 22:13:53 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 8BC0085514;
	Tue, 12 Jan 2021 22:13:53 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 862F1C0893;
	Tue, 12 Jan 2021 22:13:53 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 9B674C013A
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:13:52 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 89B2985FB6
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:13:52 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id wFrmqtEqu66a
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:13:51 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id A7D66858BA
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:13:51 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein.fritz.box) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kzRm0-0003bd-Q3; Tue, 12 Jan 2021 22:04:20 +0000
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
 Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org
Subject: [PATCH v5 35/42] fat: handle idmapped mounts
Date: Tue, 12 Jan 2021 23:01:17 +0100
Message-Id: <20210112220124.837960-36-christian.brauner@ubuntu.com>
X-Mailer: git-send-email 2.30.0
In-Reply-To: <20210112220124.837960-1-christian.brauner@ubuntu.com>
References: <20210112220124.837960-1-christian.brauner@ubuntu.com>
MIME-Version: 1.0
X-Patch-Hashes: v=1; h=sha256; i=wF1t0OLeehpDD/Or8zja7KrHnkwazZpHv9hvAGPb0LU=;
 m=IzKHY5UlBsKA0pPEwB9A/OnVkasfk4B8OCNzZgzMRzQ=;
 p=W4xT6agIbCGbQ8L3psvuVW/ITKb4ltRLzEUwTwuzS3I=;
 g=b83c1538a9fca485d728fb60a703fb616e8fd418
X-Patch-Sig: m=pgp; i=christian.brauner@ubuntu.com; s=0x0x91C61BC06578DCA2;
 b=iHUEABYKAB0WIQRAhzRXHqcMeLMyaSiRxhvAZXjcogUCX/4YuAAKCRCRxhvAZXjcou6sAQDySkZ
 L7ZLE/Uxetr6HsqPvqdlEn9zH1QTBH8F1nvuqfQEAh+rG7S7mSaekCQKygAYunPLO7s6jK3u5CuAr
 8VVgEQA=
Cc: Lennart Poettering <lennart@poettering.net>,
 Mimi Zohar <zohar@linux.ibm.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Christoph Hellwig <hch@lst.de>,
 Tycho Andersen <tycho@tycho.ws>, Paul Moore <paul@paul-moore.com>,
 Jonathan Corbet <corbet@lwn.net>, smbarber@chromium.org,
 linux-ext4@vger.kernel.org, Mrunal Patel <mpatel@redhat.com>,
 Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>,
 selinux@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>,
 Seth Forshee <seth.forshee@canonical.com>, Aleksa Sarai <cyphar@cyphar.com>,
 Andy Lutomirski <luto@kernel.org>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>, David Howells <dhowells@redhat.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 Stephen Smalley <stephen.smalley.work@gmail.com>, linux-xfs@vger.kernel.org,
 linux-security-module@vger.kernel.org,
 "Eric W. Biederman" <ebiederm@xmission.com>, linux-api@vger.kernel.org,
 Casey Schaufler <casey@schaufler-ca.com>, Alban Crequy <alban@kinvolk.io>,
 linux-integrity@vger.kernel.org,
 Linus Torvalds <torvalds@linux-foundation.org>, Todd Kjos <tkjos@google.com>
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

TGV0IGZhdCBoYW5kbGUgaWRtYXBwZWQgbW91bnRzLiBUaGlzIGFsbG93cyB0byBoYXZlIHRoZSBz
YW1lIGZhdCBtb3VudAphcHBlYXIgaW4gbXVsdGlwbGUgbG9jYXRpb25zIHdpdGggZGlmZmVyZW50
IGlkIG1hcHBpbmdzLiBUaGlzIGFsbG93cyB0bwpleHBvc2UgYSB2ZmF0IGZvcm1hdHRlZCBVU0Ig
c3RpY2sgdG8gbXVsdGlwbGUgdXNlciB3aXRoIGRpZmZlcmVudCBpZHMgb24KdGhlIGhvc3Qgb3Ig
aW4gdXNlciBuYW1lc3BhY2VzIGFsbG93aW5nIGZvciBkYWMgcGVybWlzc2lvbnM6Cgptb3VudCAt
byB1aWQ9MTAwMCxnaWQ9MTAwMCAvZGV2L3NkYiAvbW50Cgp1MTAwMUBmMi12bTovbG93ZXIxJCBs
cyAtbG4gL21udC8KdG90YWwgNAotcnd4ci14ci14IDEgMTAwMCAxMDAwIDQgT2N0IDI4IDAzOjQ0
IGFhYQotcnd4ci14ci14IDEgMTAwMCAxMDAwIDAgT2N0IDI4IDAxOjA5IGJiYgotcnd4ci14ci14
IDEgMTAwMCAxMDAwIDAgT2N0IDI4IDAxOjEwIGNjYwotcnd4ci14ci14IDEgMTAwMCAxMDAwIDAg
T2N0IDI4IDAzOjQ2IGRkZAotcnd4ci14ci14IDEgMTAwMCAxMDAwIDAgT2N0IDI4IDA0OjAxIGVl
ZQoKbW91bnQtaWRtYXBwZWQgLS1tYXAtbW91bnQgYjoxMDAwOjEwMDE6MQoKdTEwMDFAZjItdm06
L2xvd2VyMSQgbHMgLWxuIC9sb3dlcjEvCnRvdGFsIDQKLXJ3eHIteHIteCAxIDEwMDEgMTAwMSA0
IE9jdCAyOCAwMzo0NCBhYWEKLXJ3eHIteHIteCAxIDEwMDEgMTAwMSAwIE9jdCAyOCAwMTowOSBi
YmIKLXJ3eHIteHIteCAxIDEwMDEgMTAwMSAwIE9jdCAyOCAwMToxMCBjY2MKLXJ3eHIteHIteCAx
IDEwMDEgMTAwMSAwIE9jdCAyOCAwMzo0NiBkZGQKLXJ3eHIteHIteCAxIDEwMDEgMTAwMSAwIE9j
dCAyOCAwNDowMSBlZWUKCnUxMDAxQGYyLXZtOi9sb3dlcjEkIHRvdWNoIC9sb3dlcjEvZmZmCgp1
MTAwMUBmMi12bTovbG93ZXIxJCBscyAtbG4gL2xvd2VyMS9mZmYKLXJ3eHIteHIteCAxIDEwMDEg
MTAwMSAwIE9jdCAyOCAwNDowMyAvbG93ZXIxL2ZmZgoKdTEwMDFAZjItdm06L2xvd2VyMSQgbHMg
LWxuIC9tbnQvZmZmCi1yd3hyLXhyLXggMSAxMDAwIDEwMDAgMCBPY3QgMjggMDQ6MDMgL21udC9m
ZmYKCkNjOiBDaHJpc3RvcGggSGVsbHdpZyA8aGNoQGxzdC5kZT4KQ2M6IERhdmlkIEhvd2VsbHMg
PGRob3dlbGxzQHJlZGhhdC5jb20+CkNjOiBBbCBWaXJvIDx2aXJvQHplbml2LmxpbnV4Lm9yZy51
az4KQ2M6IGxpbnV4LWZzZGV2ZWxAdmdlci5rZXJuZWwub3JnClNpZ25lZC1vZmYtYnk6IENocmlz
dGlhbiBCcmF1bmVyIDxjaHJpc3RpYW4uYnJhdW5lckB1YnVudHUuY29tPgotLS0KLyogdjIgKi8K
dW5jaGFuZ2VkCgovKiB2MyAqLwp1bmNoYW5nZWQKCi8qIHY0ICovCi0gTWF1cmljaW8gVsOhc3F1
ZXogQmVybmFsIDxtYXVyaWNpb0BraW52b2xrLmlvPjoKICAtIEZpeCBtb3VudCBleGFtcGxlIGlu
IGNvbW1pdCBtZXNzYWdlLgoKLSBTZXJnZSBIYWxseW4gPHNlcmdlQGhhbGx5bi5jb20+OgogIC0g
VXNlICJtbnRfdXNlcm5zIiB0byByZWZlciB0byBhIHZmc21vdW50J3MgdXNlcm5zIGV2ZXJ5d2hl
cmUgdG8gbWFrZQogICAgdGVybWlub2xvZ3kgY29uc2lzdGVudC4KCi8qIHY1ICovCmJhc2UtY29t
bWl0OiA3YzUzZjZiNjcxZjRhYmE3MGZmMTVlMWIwNTE0OGIxMGQ1OGMyODM3Ci0tLQogZnMvZmF0
L2ZpbGUuYyAgICAgICAgfCAxNSArKysrKysrKy0tLS0tLS0KIGZzL2ZhdC9uYW1laV9tc2Rvcy5j
IHwgIDIgKy0KIGZzL2ZhdC9uYW1laV92ZmF0LmMgIHwgIDIgKy0KIDMgZmlsZXMgY2hhbmdlZCwg
MTAgaW5zZXJ0aW9ucygrKSwgOSBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9mcy9mYXQvZmls
ZS5jIGIvZnMvZmF0L2ZpbGUuYwppbmRleCA4MGZiZjFiNWJiNmMuLjEwN2U5ZWNlMWE3YyAxMDA2
NDQKLS0tIGEvZnMvZmF0L2ZpbGUuYworKysgYi9mcy9mYXQvZmlsZS5jCkBAIC0zOTgsNyArMzk4
LDcgQEAgaW50IGZhdF9nZXRhdHRyKHN0cnVjdCB1c2VyX25hbWVzcGFjZSAqbW50X3VzZXJucywg
Y29uc3Qgc3RydWN0IHBhdGggKnBhdGgsCiAJCXN0cnVjdCBrc3RhdCAqc3RhdCwgdTMyIHJlcXVl
c3RfbWFzaywgdW5zaWduZWQgaW50IGZsYWdzKQogewogCXN0cnVjdCBpbm9kZSAqaW5vZGUgPSBk
X2lub2RlKHBhdGgtPmRlbnRyeSk7Ci0JZ2VuZXJpY19maWxsYXR0cigmaW5pdF91c2VyX25zLCBp
bm9kZSwgc3RhdCk7CisJZ2VuZXJpY19maWxsYXR0cihtbnRfdXNlcm5zLCBpbm9kZSwgc3RhdCk7
CiAJc3RhdC0+Ymxrc2l6ZSA9IE1TRE9TX1NCKGlub2RlLT5pX3NiKS0+Y2x1c3Rlcl9zaXplOwog
CiAJaWYgKE1TRE9TX1NCKGlub2RlLT5pX3NiKS0+b3B0aW9ucy5uZnMgPT0gRkFUX05GU19OT1NU
QUxFX1JPKSB7CkBAIC00NDcsMTIgKzQ0NywxMyBAQCBzdGF0aWMgaW50IGZhdF9zYW5pdGl6ZV9t
b2RlKGNvbnN0IHN0cnVjdCBtc2Rvc19zYl9pbmZvICpzYmksCiAJcmV0dXJuIDA7CiB9CiAKLXN0
YXRpYyBpbnQgZmF0X2FsbG93X3NldF90aW1lKHN0cnVjdCBtc2Rvc19zYl9pbmZvICpzYmksIHN0
cnVjdCBpbm9kZSAqaW5vZGUpCitzdGF0aWMgaW50IGZhdF9hbGxvd19zZXRfdGltZShzdHJ1Y3Qg
dXNlcl9uYW1lc3BhY2UgKm1udF91c2VybnMsCisJCQkgICAgICBzdHJ1Y3QgbXNkb3Nfc2JfaW5m
byAqc2JpLCBzdHJ1Y3QgaW5vZGUgKmlub2RlKQogewogCXVtb2RlX3QgYWxsb3dfdXRpbWUgPSBz
YmktPm9wdGlvbnMuYWxsb3dfdXRpbWU7CiAKLQlpZiAoIXVpZF9lcShjdXJyZW50X2ZzdWlkKCks
IGlub2RlLT5pX3VpZCkpIHsKLQkJaWYgKGluX2dyb3VwX3AoaW5vZGUtPmlfZ2lkKSkKKwlpZiAo
IXVpZF9lcShjdXJyZW50X2ZzdWlkKCksIGlfdWlkX2ludG9fbW50KG1udF91c2VybnMsIGlub2Rl
KSkpIHsKKwkJaWYgKGluX2dyb3VwX3AoaV9naWRfaW50b19tbnQobW50X3VzZXJucywgaW5vZGUp
KSkKIAkJCWFsbG93X3V0aW1lID4+PSAzOwogCQlpZiAoYWxsb3dfdXRpbWUgJiBNQVlfV1JJVEUp
CiAJCQlyZXR1cm4gMTsKQEAgLTQ3NywxMSArNDc4LDExIEBAIGludCBmYXRfc2V0YXR0cihzdHJ1
Y3QgdXNlcl9uYW1lc3BhY2UgKm1udF91c2VybnMsIHN0cnVjdCBkZW50cnkgKmRlbnRyeSwKIAkv
KiBDaGVjayBmb3Igc2V0dGluZyB0aGUgaW5vZGUgdGltZS4gKi8KIAlpYV92YWxpZCA9IGF0dHIt
PmlhX3ZhbGlkOwogCWlmIChpYV92YWxpZCAmIFRJTUVTX1NFVF9GTEFHUykgewotCQlpZiAoZmF0
X2FsbG93X3NldF90aW1lKHNiaSwgaW5vZGUpKQorCQlpZiAoZmF0X2FsbG93X3NldF90aW1lKG1u
dF91c2VybnMsIHNiaSwgaW5vZGUpKQogCQkJYXR0ci0+aWFfdmFsaWQgJj0gflRJTUVTX1NFVF9G
TEFHUzsKIAl9CiAKLQllcnJvciA9IHNldGF0dHJfcHJlcGFyZSgmaW5pdF91c2VyX25zLCBkZW50
cnksIGF0dHIpOworCWVycm9yID0gc2V0YXR0cl9wcmVwYXJlKG1udF91c2VybnMsIGRlbnRyeSwg
YXR0cik7CiAJYXR0ci0+aWFfdmFsaWQgPSBpYV92YWxpZDsKIAlpZiAoZXJyb3IpIHsKIAkJaWYg
KHNiaS0+b3B0aW9ucy5xdWlldCkKQEAgLTU1MSw3ICs1NTIsNyBAQCBpbnQgZmF0X3NldGF0dHIo
c3RydWN0IHVzZXJfbmFtZXNwYWNlICptbnRfdXNlcm5zLCBzdHJ1Y3QgZGVudHJ5ICpkZW50cnks
CiAJCWZhdF90cnVuY2F0ZV90aW1lKGlub2RlLCAmYXR0ci0+aWFfbXRpbWUsIFNfTVRJTUUpOwog
CWF0dHItPmlhX3ZhbGlkICY9IH4oQVRUUl9BVElNRXxBVFRSX0NUSU1FfEFUVFJfTVRJTUUpOwog
Ci0Jc2V0YXR0cl9jb3B5KCZpbml0X3VzZXJfbnMsIGlub2RlLCBhdHRyKTsKKwlzZXRhdHRyX2Nv
cHkobW50X3VzZXJucywgaW5vZGUsIGF0dHIpOwogCW1hcmtfaW5vZGVfZGlydHkoaW5vZGUpOwog
b3V0OgogCXJldHVybiBlcnJvcjsKZGlmZiAtLWdpdCBhL2ZzL2ZhdC9uYW1laV9tc2Rvcy5jIGIv
ZnMvZmF0L25hbWVpX21zZG9zLmMKaW5kZXggYThmMzM3NWQ5ZDEwLi5lZmJhMzAxZDY4YWUgMTAw
NjQ0Ci0tLSBhL2ZzL2ZhdC9uYW1laV9tc2Rvcy5jCisrKyBiL2ZzL2ZhdC9uYW1laV9tc2Rvcy5j
CkBAIC02NjcsNyArNjY3LDcgQEAgc3RhdGljIHN0cnVjdCBmaWxlX3N5c3RlbV90eXBlIG1zZG9z
X2ZzX3R5cGUgPSB7CiAJLm5hbWUJCT0gIm1zZG9zIiwKIAkubW91bnQJCT0gbXNkb3NfbW91bnQs
CiAJLmtpbGxfc2IJPSBraWxsX2Jsb2NrX3N1cGVyLAotCS5mc19mbGFncwk9IEZTX1JFUVVJUkVT
X0RFViwKKwkuZnNfZmxhZ3MJPSBGU19SRVFVSVJFU19ERVYgfCBGU19BTExPV19JRE1BUCwKIH07
CiBNT0RVTEVfQUxJQVNfRlMoIm1zZG9zIik7CiAKZGlmZiAtLWdpdCBhL2ZzL2ZhdC9uYW1laV92
ZmF0LmMgYi9mcy9mYXQvbmFtZWlfdmZhdC5jCmluZGV4IDIzOTM2ZWNmNzlhNS4uNTM2OWQ4MmUw
YmZiIDEwMDY0NAotLS0gYS9mcy9mYXQvbmFtZWlfdmZhdC5jCisrKyBiL2ZzL2ZhdC9uYW1laV92
ZmF0LmMKQEAgLTEwNjMsNyArMTA2Myw3IEBAIHN0YXRpYyBzdHJ1Y3QgZmlsZV9zeXN0ZW1fdHlw
ZSB2ZmF0X2ZzX3R5cGUgPSB7CiAJLm5hbWUJCT0gInZmYXQiLAogCS5tb3VudAkJPSB2ZmF0X21v
dW50LAogCS5raWxsX3NiCT0ga2lsbF9ibG9ja19zdXBlciwKLQkuZnNfZmxhZ3MJPSBGU19SRVFV
SVJFU19ERVYsCisJLmZzX2ZsYWdzCT0gRlNfUkVRVUlSRVNfREVWIHwgRlNfQUxMT1dfSURNQVAs
CiB9OwogTU9EVUxFX0FMSUFTX0ZTKCJ2ZmF0Iik7CiAKLS0gCjIuMzAuMAoKX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KQ29udGFpbmVycyBtYWlsaW5nIGxp
c3QKQ29udGFpbmVyc0BsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxp
bnV4Zm91bmRhdGlvbi5vcmcvbWFpbG1hbi9saXN0aW5mby9jb250YWluZXJz
