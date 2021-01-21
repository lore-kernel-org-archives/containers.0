Return-Path: <SRS0=Ull0=GY=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49F92C433E0
	for <containers@archiver.kernel.org>; Thu, 21 Jan 2021 13:31:13 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id B4B16206DC
	for <containers@archiver.kernel.org>; Thu, 21 Jan 2021 13:31:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B4B16206DC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 70B0585A81;
	Thu, 21 Jan 2021 13:31:12 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id hrDdsNPHxbns; Thu, 21 Jan 2021 13:31:11 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 8626685B29;
	Thu, 21 Jan 2021 13:31:11 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 77A37C088B;
	Thu, 21 Jan 2021 13:31:11 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id C3D9CC013A
 for <containers@lists.linux-foundation.org>;
 Thu, 21 Jan 2021 13:31:09 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id B944C86214
 for <containers@lists.linux-foundation.org>;
 Thu, 21 Jan 2021 13:31:09 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id MIs8ldVOwlKL
 for <containers@lists.linux-foundation.org>;
 Thu, 21 Jan 2021 13:31:08 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 585DE861F1
 for <containers@lists.linux-foundation.org>;
 Thu, 21 Jan 2021 13:31:08 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein.fritz.box) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1l2ZvO-0005g7-Jw; Thu, 21 Jan 2021 13:22:58 +0000
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@lst.de>,
 linux-fsdevel@vger.kernel.org
Subject: [PATCH v6 37/40] fat: handle idmapped mounts
Date: Thu, 21 Jan 2021 14:19:56 +0100
Message-Id: <20210121131959.646623-38-christian.brauner@ubuntu.com>
X-Mailer: git-send-email 2.30.0
In-Reply-To: <20210121131959.646623-1-christian.brauner@ubuntu.com>
References: <20210121131959.646623-1-christian.brauner@ubuntu.com>
MIME-Version: 1.0
X-Patch-Hashes: v=1; h=sha256; i=wF1t0OLeehpDD/Or8zja7KrHnkwazZpHv9hvAGPb0LU=;
 m=l68w9z3nuzQbdD8jJ4SY76UNlGeYspBUah720yzK2lY=;
 p=VYd3jcBHTuujai52oTyGbiEhcHfrnzpws7JejgqOZc8=;
 g=b83c1538a9fca485d728fb60a703fb616e8fd418
X-Patch-Sig: m=pgp; i=christian.brauner@ubuntu.com; s=0x0x91C61BC06578DCA2;
 b=iHUEABYKAB0WIQRAhzRXHqcMeLMyaSiRxhvAZXjcogUCYAl9pwAKCRCRxhvAZXjcordaAP4re7G
 uyqs7DvjvSUzPlp4FEdWyIrcV6EowQ75cbIDBBwD+Plx6FOWeHmvAhm6mDL/bm1+7dhqucxmPqBs/
 0J5zLAY=
Cc: Lennart Poettering <lennart@poettering.net>,
 Mimi Zohar <zohar@linux.ibm.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Tycho Andersen <tycho@tycho.ws>,
 Paul Moore <paul@paul-moore.com>, Jonathan Corbet <corbet@lwn.net>,
 smbarber@chromium.org, linux-ext4@vger.kernel.org,
 Mrunal Patel <mpatel@redhat.com>, Kees Cook <keescook@chromium.org>,
 Arnd Bergmann <arnd@arndb.de>, selinux@vger.kernel.org,
 Josh Triplett <josh@joshtriplett.org>,
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
ZmYKCkxpbms6IGh0dHBzOi8vbG9yZS5rZXJuZWwub3JnL3IvMjAyMTAxMTIyMjAxMjQuODM3OTYw
LTM2LWNocmlzdGlhbi5icmF1bmVyQHVidW50dS5jb20KQ2M6IENocmlzdG9waCBIZWxsd2lnIDxo
Y2hAbHN0LmRlPgpDYzogRGF2aWQgSG93ZWxscyA8ZGhvd2VsbHNAcmVkaGF0LmNvbT4KQ2M6IEFs
IFZpcm8gPHZpcm9AemVuaXYubGludXgub3JnLnVrPgpDYzogbGludXgtZnNkZXZlbEB2Z2VyLmtl
cm5lbC5vcmcKU2lnbmVkLW9mZi1ieTogQ2hyaXN0aWFuIEJyYXVuZXIgPGNocmlzdGlhbi5icmF1
bmVyQHVidW50dS5jb20+Ci0tLQovKiB2MiAqLwp1bmNoYW5nZWQKCi8qIHYzICovCnVuY2hhbmdl
ZAoKLyogdjQgKi8KLSBNYXVyaWNpbyBWw6FzcXVleiBCZXJuYWwgPG1hdXJpY2lvQGtpbnZvbGsu
aW8+OgogIC0gRml4IG1vdW50IGV4YW1wbGUgaW4gY29tbWl0IG1lc3NhZ2UuCgotIFNlcmdlIEhh
bGx5biA8c2VyZ2VAaGFsbHluLmNvbT46CiAgLSBVc2UgIm1udF91c2VybnMiIHRvIHJlZmVyIHRv
IGEgdmZzbW91bnQncyB1c2VybnMgZXZlcnl3aGVyZSB0byBtYWtlCiAgICB0ZXJtaW5vbG9neSBj
b25zaXN0ZW50LgoKLyogdjUgKi8KdW5jaGFuZ2VkCmJhc2UtY29tbWl0OiA3YzUzZjZiNjcxZjRh
YmE3MGZmMTVlMWIwNTE0OGIxMGQ1OGMyODM3CgovKiB2NiAqLwp1bmNoYW5nZWQKYmFzZS1jb21t
aXQ6IDE5YzMyOWY2ODA4OTk1YjE0MmIzOTY2MzAxZjIxN2M4MzFlN2NmMzEKLS0tCiBmcy9mYXQv
ZmlsZS5jICAgICAgICB8IDE1ICsrKysrKysrLS0tLS0tLQogZnMvZmF0L25hbWVpX21zZG9zLmMg
fCAgMiArLQogZnMvZmF0L25hbWVpX3ZmYXQuYyAgfCAgMiArLQogMyBmaWxlcyBjaGFuZ2VkLCAx
MCBpbnNlcnRpb25zKCspLCA5IGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL2ZzL2ZhdC9maWxl
LmMgYi9mcy9mYXQvZmlsZS5jCmluZGV4IGRkNzNkMWI3MGM1NS4uZGE3YzU2MjM0MTg5IDEwMDY0
NAotLS0gYS9mcy9mYXQvZmlsZS5jCisrKyBiL2ZzL2ZhdC9maWxlLmMKQEAgLTM5OCw3ICszOTgs
NyBAQCBpbnQgZmF0X2dldGF0dHIoc3RydWN0IHVzZXJfbmFtZXNwYWNlICptbnRfdXNlcm5zLCBj
b25zdCBzdHJ1Y3QgcGF0aCAqcGF0aCwKIAkJc3RydWN0IGtzdGF0ICpzdGF0LCB1MzIgcmVxdWVz
dF9tYXNrLCB1bnNpZ25lZCBpbnQgZmxhZ3MpCiB7CiAJc3RydWN0IGlub2RlICppbm9kZSA9IGRf
aW5vZGUocGF0aC0+ZGVudHJ5KTsKLQlnZW5lcmljX2ZpbGxhdHRyKCZpbml0X3VzZXJfbnMsIGlu
b2RlLCBzdGF0KTsKKwlnZW5lcmljX2ZpbGxhdHRyKG1udF91c2VybnMsIGlub2RlLCBzdGF0KTsK
IAlzdGF0LT5ibGtzaXplID0gTVNET1NfU0IoaW5vZGUtPmlfc2IpLT5jbHVzdGVyX3NpemU7CiAK
IAlpZiAoTVNET1NfU0IoaW5vZGUtPmlfc2IpLT5vcHRpb25zLm5mcyA9PSBGQVRfTkZTX05PU1RB
TEVfUk8pIHsKQEAgLTQ0NywxMiArNDQ3LDEzIEBAIHN0YXRpYyBpbnQgZmF0X3Nhbml0aXplX21v
ZGUoY29uc3Qgc3RydWN0IG1zZG9zX3NiX2luZm8gKnNiaSwKIAlyZXR1cm4gMDsKIH0KIAotc3Rh
dGljIGludCBmYXRfYWxsb3dfc2V0X3RpbWUoc3RydWN0IG1zZG9zX3NiX2luZm8gKnNiaSwgc3Ry
dWN0IGlub2RlICppbm9kZSkKK3N0YXRpYyBpbnQgZmF0X2FsbG93X3NldF90aW1lKHN0cnVjdCB1
c2VyX25hbWVzcGFjZSAqbW50X3VzZXJucywKKwkJCSAgICAgIHN0cnVjdCBtc2Rvc19zYl9pbmZv
ICpzYmksIHN0cnVjdCBpbm9kZSAqaW5vZGUpCiB7CiAJdW1vZGVfdCBhbGxvd191dGltZSA9IHNi
aS0+b3B0aW9ucy5hbGxvd191dGltZTsKIAotCWlmICghdWlkX2VxKGN1cnJlbnRfZnN1aWQoKSwg
aW5vZGUtPmlfdWlkKSkgewotCQlpZiAoaW5fZ3JvdXBfcChpbm9kZS0+aV9naWQpKQorCWlmICgh
dWlkX2VxKGN1cnJlbnRfZnN1aWQoKSwgaV91aWRfaW50b19tbnQobW50X3VzZXJucywgaW5vZGUp
KSkgeworCQlpZiAoaW5fZ3JvdXBfcChpX2dpZF9pbnRvX21udChtbnRfdXNlcm5zLCBpbm9kZSkp
KQogCQkJYWxsb3dfdXRpbWUgPj49IDM7CiAJCWlmIChhbGxvd191dGltZSAmIE1BWV9XUklURSkK
IAkJCXJldHVybiAxOwpAQCAtNDc3LDExICs0NzgsMTEgQEAgaW50IGZhdF9zZXRhdHRyKHN0cnVj
dCB1c2VyX25hbWVzcGFjZSAqbW50X3VzZXJucywgc3RydWN0IGRlbnRyeSAqZGVudHJ5LAogCS8q
IENoZWNrIGZvciBzZXR0aW5nIHRoZSBpbm9kZSB0aW1lLiAqLwogCWlhX3ZhbGlkID0gYXR0ci0+
aWFfdmFsaWQ7CiAJaWYgKGlhX3ZhbGlkICYgVElNRVNfU0VUX0ZMQUdTKSB7Ci0JCWlmIChmYXRf
YWxsb3dfc2V0X3RpbWUoc2JpLCBpbm9kZSkpCisJCWlmIChmYXRfYWxsb3dfc2V0X3RpbWUobW50
X3VzZXJucywgc2JpLCBpbm9kZSkpCiAJCQlhdHRyLT5pYV92YWxpZCAmPSB+VElNRVNfU0VUX0ZM
QUdTOwogCX0KIAotCWVycm9yID0gc2V0YXR0cl9wcmVwYXJlKCZpbml0X3VzZXJfbnMsIGRlbnRy
eSwgYXR0cik7CisJZXJyb3IgPSBzZXRhdHRyX3ByZXBhcmUobW50X3VzZXJucywgZGVudHJ5LCBh
dHRyKTsKIAlhdHRyLT5pYV92YWxpZCA9IGlhX3ZhbGlkOwogCWlmIChlcnJvcikgewogCQlpZiAo
c2JpLT5vcHRpb25zLnF1aWV0KQpAQCAtNTUxLDcgKzU1Miw3IEBAIGludCBmYXRfc2V0YXR0cihz
dHJ1Y3QgdXNlcl9uYW1lc3BhY2UgKm1udF91c2VybnMsIHN0cnVjdCBkZW50cnkgKmRlbnRyeSwK
IAkJZmF0X3RydW5jYXRlX3RpbWUoaW5vZGUsICZhdHRyLT5pYV9tdGltZSwgU19NVElNRSk7CiAJ
YXR0ci0+aWFfdmFsaWQgJj0gfihBVFRSX0FUSU1FfEFUVFJfQ1RJTUV8QVRUUl9NVElNRSk7CiAK
LQlzZXRhdHRyX2NvcHkoJmluaXRfdXNlcl9ucywgaW5vZGUsIGF0dHIpOworCXNldGF0dHJfY29w
eShtbnRfdXNlcm5zLCBpbm9kZSwgYXR0cik7CiAJbWFya19pbm9kZV9kaXJ0eShpbm9kZSk7CiBv
dXQ6CiAJcmV0dXJuIGVycm9yOwpkaWZmIC0tZ2l0IGEvZnMvZmF0L25hbWVpX21zZG9zLmMgYi9m
cy9mYXQvbmFtZWlfbXNkb3MuYwppbmRleCBhOGYzMzc1ZDlkMTAuLmVmYmEzMDFkNjhhZSAxMDA2
NDQKLS0tIGEvZnMvZmF0L25hbWVpX21zZG9zLmMKKysrIGIvZnMvZmF0L25hbWVpX21zZG9zLmMK
QEAgLTY2Nyw3ICs2NjcsNyBAQCBzdGF0aWMgc3RydWN0IGZpbGVfc3lzdGVtX3R5cGUgbXNkb3Nf
ZnNfdHlwZSA9IHsKIAkubmFtZQkJPSAibXNkb3MiLAogCS5tb3VudAkJPSBtc2Rvc19tb3VudCwK
IAkua2lsbF9zYgk9IGtpbGxfYmxvY2tfc3VwZXIsCi0JLmZzX2ZsYWdzCT0gRlNfUkVRVUlSRVNf
REVWLAorCS5mc19mbGFncwk9IEZTX1JFUVVJUkVTX0RFViB8IEZTX0FMTE9XX0lETUFQLAogfTsK
IE1PRFVMRV9BTElBU19GUygibXNkb3MiKTsKIApkaWZmIC0tZ2l0IGEvZnMvZmF0L25hbWVpX3Zm
YXQuYyBiL2ZzL2ZhdC9uYW1laV92ZmF0LmMKaW5kZXggMjM5MzZlY2Y3OWE1Li41MzY5ZDgyZTBi
ZmIgMTAwNjQ0Ci0tLSBhL2ZzL2ZhdC9uYW1laV92ZmF0LmMKKysrIGIvZnMvZmF0L25hbWVpX3Zm
YXQuYwpAQCAtMTA2Myw3ICsxMDYzLDcgQEAgc3RhdGljIHN0cnVjdCBmaWxlX3N5c3RlbV90eXBl
IHZmYXRfZnNfdHlwZSA9IHsKIAkubmFtZQkJPSAidmZhdCIsCiAJLm1vdW50CQk9IHZmYXRfbW91
bnQsCiAJLmtpbGxfc2IJPSBraWxsX2Jsb2NrX3N1cGVyLAotCS5mc19mbGFncwk9IEZTX1JFUVVJ
UkVTX0RFViwKKwkuZnNfZmxhZ3MJPSBGU19SRVFVSVJFU19ERVYgfCBGU19BTExPV19JRE1BUCwK
IH07CiBNT0RVTEVfQUxJQVNfRlMoInZmYXQiKTsKIAotLSAKMi4zMC4wCgpfX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpDb250YWluZXJzIG1haWxpbmcgbGlz
dApDb250YWluZXJzQGxpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnCmh0dHBzOi8vbGlzdHMubGlu
dXhmb3VuZGF0aW9uLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2NvbnRhaW5lcnM=
