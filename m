Return-Path: <SRS0=RCTg=JJ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC1B5C4360C
	for <containers@archiver.kernel.org>; Mon, 12 Apr 2021 12:16:04 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 202BA61289
	for <containers@archiver.kernel.org>; Mon, 12 Apr 2021 12:16:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 202BA61289
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tuxera.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp4.osuosl.org (Postfix) with ESMTP id CF82B4038C;
	Mon, 12 Apr 2021 12:16:03 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
	by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Vjz4oNFxPWaN; Mon, 12 Apr 2021 12:15:58 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp4.osuosl.org (Postfix) with ESMTP id E29E040382;
	Mon, 12 Apr 2021 12:15:57 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id BAE2AC000B;
	Mon, 12 Apr 2021 12:15:57 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [IPv6:2605:bc80:3010::136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id CB141C000A
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Apr 2021 12:15:56 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp3.osuosl.org (Postfix) with ESMTP id B947E6068C
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Apr 2021 12:15:56 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp3.osuosl.org ([127.0.0.1])
 by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id BxHoaX80ruLz
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Apr 2021 12:15:55 +0000 (UTC)
X-Greylist: delayed 00:10:27 by SQLgrey-1.8.0
Received: from mgw-02.mpynet.fi (mgw-02.mpynet.fi [82.197.21.91])
 by smtp3.osuosl.org (Postfix) with ESMTPS id CE20B60682
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Apr 2021 12:15:54 +0000 (UTC)
Received: from pps.filterd (mgw-02.mpynet.fi [127.0.0.1])
 by mgw-02.mpynet.fi (8.16.0.43/8.16.0.43) with SMTP id 13CBuj4R036297;
 Mon, 12 Apr 2021 15:05:00 +0300
Received: from ex13.tuxera.com (ex13.tuxera.com [178.16.184.72])
 by mgw-02.mpynet.fi with ESMTP id 37vmqsr2ph-1
 (version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
 Mon, 12 Apr 2021 15:05:00 +0300
Received: from tuxera-exch.ad.tuxera.com (10.20.48.11) by
 tuxera-exch.ad.tuxera.com (10.20.48.11) with Microsoft SMTP Server (TLS) id
 15.0.1497.2; Mon, 12 Apr 2021 15:04:59 +0300
Received: from tuxera-exch.ad.tuxera.com ([fe80::552a:f9f0:68c3:d789]) by
 tuxera-exch.ad.tuxera.com ([fe80::552a:f9f0:68c3:d789%12]) with mapi id
 15.00.1497.012; Mon, 12 Apr 2021 15:04:59 +0300
From: Anton Altaparmakov <anton@tuxera.com>
To: "christian.brauner@ubuntu.com" <christian.brauner@ubuntu.com>
Subject: Re: [PATCH v6 24/40] fs: make helpers idmap mount aware
Thread-Topic: [PATCH v6 24/40] fs: make helpers idmap mount aware
Thread-Index: AQHXL5QPJZ+OaKJz8USD3Dodtq0P1w==
Date: Mon, 12 Apr 2021 12:04:59 +0000
Message-ID: <E901E25F-41FA-444D-B3C7-A7A786DDD5D5@tuxera.com>
Accept-Language: en-GB, en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-exchange-transport-fromentityheader: Hosted
x-originating-ip: [109.145.212.130]
Content-ID: <BA514E4FAABFD8498C8B1419EB26396B@ex13.tuxera.com>
MIME-Version: 1.0
X-Proofpoint-GUID: Vd5127wVnEcv9vrUnKYvowNFSa7J_xlE
X-Proofpoint-ORIG-GUID: Vd5127wVnEcv9vrUnKYvowNFSa7J_xlE
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:6.0.391, 18.0.761
 definitions=2021-04-12_09:2021-04-12,
 2021-04-12 signatures=0
X-Proofpoint-Spam-Details: rule=mpy_notspam policy=mpy score=0 adultscore=0
 suspectscore=0
 mlxlogscore=999 mlxscore=0 malwarescore=0 spamscore=0 phishscore=0
 bulkscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.12.0-2104060000 definitions=main-2104120082
Cc: "luto@kernel.org" <luto@kernel.org>,
 "zohar@linux.ibm.com" <zohar@linux.ibm.com>,
 "dhowells@redhat.com" <dhowells@redhat.com>,
 "alban@kinvolk.io" <alban@kinvolk.io>, "hch@lst.de" <hch@lst.de>,
 "tycho@tycho.ws" <tycho@tycho.ws>, "paul@paul-moore.com" <paul@paul-moore.com>,
 "corbet@lwn.net" <corbet@lwn.net>,
 "smbarber@chromium.org" <smbarber@chromium.org>,
 "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
 "mpatel@redhat.com" <mpatel@redhat.com>,
 "keescook@chromium.org" <keescook@chromium.org>,
 "arnd@arndb.de" <arnd@arndb.de>,
 "selinux@vger.kernel.org" <selinux@vger.kernel.org>,
 "josh@joshtriplett.org" <josh@joshtriplett.org>,
 "casey@schaufler-ca.com" <casey@schaufler-ca.com>,
 "cyphar@cyphar.com" <cyphar@cyphar.com>,
 "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
 "lennart@poettering.net" <lennart@poettering.net>,
 "hirofumi@mail.parknet.co.jp" <hirofumi@mail.parknet.co.jp>,
 "geofft@ldpreload.com" <geofft@ldpreload.com>,
 "James.Bottomley@hansenpartnership.com"
 <James.Bottomley@hansenpartnership.com>,
 "john.johansen@canonical.com" <john.johansen@canonical.com>,
 "tytso@mit.edu" <tytso@mit.edu>,
 "seth.forshee@canonical.com" <seth.forshee@canonical.com>,
 "dmitry.kasatkin@gmail.com" <dmitry.kasatkin@gmail.com>,
 "containers@lists.linux-foundation.org"
 <containers@lists.linux-foundation.org>,
 "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>,
 "linux-security-module@vger.kernel.org"
 <linux-security-module@vger.kernel.org>,
 "ebiederm@xmission.com" <ebiederm@xmission.com>,
 "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>,
 "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
 "adilger.kernel@dilger.ca" <adilger.kernel@dilger.ca>,
 "linux-integrity@vger.kernel.org" <linux-integrity@vger.kernel.org>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 "stephen.smalley.work@gmail.com" <stephen.smalley.work@gmail.com>,
 "tkjos@google.com" <tkjos@google.com>
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

Hi,

I noticed this patch got merged into mainline and looking through the HFS+ changes, I noticed something that struck me as odd.  I am not familiar with this patch set so perhaps it is the intention but I wanted to ask you because it just seems strange thing to do.

So you are adding a new argument of "struct user_namespace *mnt_userns" to lots of functions but then inside the functions when they call another function you often make that use "&init_user_ns" instead of the passed in "mnt_userns" which kind of defeats the point of having the new "mnt_userns" argument altogether, doesn't it?

Example after this chunk:

diff --git a/fs/hfsplus/inode.c b/fs/hfsplus/inode.c
index 642e067d8fe8..7a937de9b2ad 100644
--- a/fs/hfsplus/inode.c
+++ b/fs/hfsplus/inode.c
@@ -241,7 +241,8 @@ static int hfsplus_file_release(struct inode *inode, struct file *file)
        return 0;
 }

-static int hfsplus_setattr(struct dentry *dentry, struct iattr *attr)
+static int hfsplus_setattr(struct user_namespace *mnt_userns,
+                    struct dentry *dentry, struct iattr *attr)
 {
        struct inode *inode = d_inode(dentry);
        int error;

The code now looks like this:

static int hfsplus_setattr(struct user_namespace *mnt_userns,
                           struct dentry *dentry, struct iattr *attr)
{
        struct inode *inode = d_inode(dentry);
        int error;

        error = setattr_prepare(&init_user_ns, dentry, attr);
        if (error)
                return error;
[...]
        setattr_copy(&init_user_ns, inode, attr);
        mark_inode_dirty(inode);

        return 0;
}

Shouldn't that be using mnt_userns instead of &init_user_ns both for the setattr_prepare() and setattr_copy() calls?

Please note this is just one example - it seems the kernel is now littered with such examples in current mainline and I don't mean just HFS+ - this is now all over the place...

Best regards,

	Anton
-- 
Anton Altaparmakov <anton at tuxera.com> (replace at with @)
Lead in File System Development, Tuxera Inc., http://www.tuxera.com/
Linux NTFS maintainer

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
