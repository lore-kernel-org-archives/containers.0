Return-Path: <SRS0=WE+R=II=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1DEF7C433E0
	for <containers@archiver.kernel.org>; Wed, 10 Mar 2021 18:20:26 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C09B364DC4
	for <containers@archiver.kernel.org>; Wed, 10 Mar 2021 18:20:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C09B364DC4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp1.osuosl.org (Postfix) with ESMTP id 7155E8439B;
	Wed, 10 Mar 2021 18:20:25 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
	by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id x0UYV8mKBuB8; Wed, 10 Mar 2021 18:20:24 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [IPv6:2605:bc80:3010:104::8cd3:938])
	by smtp1.osuosl.org (Postfix) with ESMTP id 7632F84165;
	Wed, 10 Mar 2021 18:20:24 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 4FC8BC000A;
	Wed, 10 Mar 2021 18:20:24 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [IPv6:2605:bc80:3010::133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 99E8EC0001
 for <containers@lists.linux-foundation.org>;
 Wed, 10 Mar 2021 18:20:21 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp2.osuosl.org (Postfix) with ESMTP id 875F6431C7
 for <containers@lists.linux-foundation.org>;
 Wed, 10 Mar 2021 18:20:21 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp2.osuosl.org ([127.0.0.1])
 by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id ZtAZiKAzANso
 for <containers@lists.linux-foundation.org>;
 Wed, 10 Mar 2021 18:20:20 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.8.0
Received: from raptor.unsafe.ru (raptor.unsafe.ru [5.9.43.93])
 by smtp2.osuosl.org (Postfix) with ESMTP id 4177D42FC6
 for <containers@lists.linux-foundation.org>;
 Wed, 10 Mar 2021 18:20:20 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com
 (ip-94-113-225-162.net.upcbroadband.cz [94.113.225.162])
 by raptor.unsafe.ru (Postfix) with ESMTPSA id 677E940CE4;
 Wed, 10 Mar 2021 18:20:16 +0000 (UTC)
From: Alexey Gladkov <gladkov.alexey@gmail.com>
To: LKML <linux-kernel@vger.kernel.org>,
 "Eric W . Biederman" <ebiederm@xmission.com>
Subject: [PATCH v5 0/5] proc: Relax check of mount visibility
Date: Wed, 10 Mar 2021 19:19:55 +0100
Message-Id: <cover.1615400395.git.gladkov.alexey@gmail.com>
X-Mailer: git-send-email 2.29.2
MIME-Version: 1.0
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.4
 (raptor.unsafe.ru [0.0.0.0]); Wed, 10 Mar 2021 18:20:19 +0000 (UTC)
Cc: Linux FS Devel <linux-fsdevel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Alexey Gladkov <legion@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>,
 Kees Cook <keescook@chromium.org>
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

If only the dynamic part of procfs is mounted (subset=pid), then there is no
need to check if procfs is fully visible to the user in the new user namespace.

Changelog
---------
v4:
* Set SB_I_DYNAMIC only if pidonly is set.
* Add an error message if subset=pid is canceled during remount.

v3:
* Add 'const' to struct cred *mounter_cred (fix kernel test robot warning).

v2:
* cache the mounters credentials and make access to the net directories
  contingent of the permissions of the mounter of procfs.

--

Alexey Gladkov (5):
  docs: proc: add documentation about mount restrictions
  proc: Show /proc/self/net only for CAP_NET_ADMIN
  proc: Disable cancellation of subset=pid option
  proc: Relax check of mount visibility
  docs: proc: add documentation about relaxing visibility restrictions

 Documentation/filesystems/proc.rst | 18 ++++++++++++++++++
 fs/namespace.c                     | 27 ++++++++++++++++-----------
 fs/proc/proc_net.c                 |  8 ++++++++
 fs/proc/root.c                     | 25 +++++++++++++++++++------
 include/linux/fs.h                 |  1 +
 include/linux/proc_fs.h            |  1 +
 6 files changed, 63 insertions(+), 17 deletions(-)

-- 
2.29.2

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
