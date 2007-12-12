From: Edward Shishkin <edward.shishkin@gmail.com>
Subject: Re: [RFC] [PATCH -mm] reiser4: replace uid==0 check with capability
Date: Thu, 13 Dec 2007 02:36:27 +0300
Message-ID: <4760707B.2040007@gmail.com>
References: <20071212210107.GB24708@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <reiserfs-devel-owner@vger.kernel.org>
In-Reply-To: <20071212210107.GB24708@sergelap.austin.ibm.com>
Sender: reiserfs-devel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Linux Containers <containers@lists.osdl.org>, lkml <linux-kernel@vger.kernel.org>, reiserfs-devel@vger.kernel.org
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:

>>From c257cb67ce00c8769730cfa92379a53009d99b28 Mon Sep 17 00:00:00 2001
>From: serue@us.ibm.com <serue@us.ibm.com>
>Date: Wed, 5 Dec 2007 14:02:45 -0800
>Subject: [RFC] [PATCH -mm] reiser4: replace uid==0 check with capability
>
>Reiser4 gives root some reserved blocks.  Replace the uid==0 check, which
>is not safe in the face of user namespaces, with a CAP_SYS_RESOURCE check,
>which seems appropriate.
>
>  
>

Agreed. Thanks,
Edward.

>The per-uid and per-guid reservations appear unimplemented so I'm ignoring
>them.
>
>Signed-off-by: Serge Hallyn <serue@us.ibm.com>
>---
> fs/reiser4/super.c |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
>
>diff --git a/fs/reiser4/super.c b/fs/reiser4/super.c
>index bc4113e..50e3d09 100644
>--- a/fs/reiser4/super.c
>+++ b/fs/reiser4/super.c
>@@ -144,7 +144,7 @@ long reiser4_reserved_blocks(const struct super_block *super	/* super block
> 		reserved += reserved_for_gid(super, gid);
> 	if (REISER4_SUPPORT_UID_SPACE_RESERVATION)
> 		reserved += reserved_for_uid(super, uid);
>-	if (REISER4_SUPPORT_ROOT_SPACE_RESERVATION && (uid == 0))
>+	if (REISER4_SUPPORT_ROOT_SPACE_RESERVATION && capable(CAP_SYS_RESOURCE))
> 		reserved += reserved_for_root(super);
> 	return reserved;
> }
>  
>

