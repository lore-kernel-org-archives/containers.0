Return-Path: <SRS0=wqWt=J3=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-18.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A2F1C433ED
	for <containers@archiver.kernel.org>; Fri, 30 Apr 2021 18:10:10 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id EE1A76146D
	for <containers@archiver.kernel.org>; Fri, 30 Apr 2021 18:10:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE1A76146D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=xmission.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp1.osuosl.org (Postfix) with ESMTP id B360E84A03;
	Fri, 30 Apr 2021 18:10:09 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
	by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 9wtf-ggQqqNT; Fri, 30 Apr 2021 18:10:08 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp1.osuosl.org (Postfix) with ESMTP id AEED28482F;
	Fri, 30 Apr 2021 18:10:08 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 88AFFC000E;
	Fri, 30 Apr 2021 18:10:08 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [IPv6:2605:bc80:3010::133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id C423DC0001
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 18:10:06 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp2.osuosl.org (Postfix) with ESMTP id AAD3B40207
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 18:10:06 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp2.osuosl.org ([127.0.0.1])
 by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id nO9QBLjKe0XQ
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 18:10:05 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.8.0
Received: from out01.mta.xmission.com (out01.mta.xmission.com [166.70.13.231])
 by smtp2.osuosl.org (Postfix) with ESMTPS id 8FA5240129
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 18:10:05 +0000 (UTC)
Received: from in01.mta.xmission.com ([166.70.13.51])
 by out01.mta.xmission.com with esmtps (TLS1.2) tls
 TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 (Exim 4.93)
 (envelope-from <ebiederm@xmission.com>)
 id 1lcXaU-00CRau-5a; Fri, 30 Apr 2021 12:10:02 -0600
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95]
 helo=fess.xmission.com) by in01.mta.xmission.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256) (Exim 4.87)
 (envelope-from <ebiederm@xmission.com>)
 id 1lcXaR-00085W-UW; Fri, 30 Apr 2021 12:10:01 -0600
From: ebiederm@xmission.com (Eric W. Biederman)
To: Dan Carpenter <dan.carpenter@oracle.com>
References: <202104272256.9Y5ZQxrO-lkp@intel.com>
Date: Fri, 30 Apr 2021 13:09:55 -0500
In-Reply-To: <202104272256.9Y5ZQxrO-lkp@intel.com> (Dan Carpenter's message of
 "Thu, 29 Apr 2021 17:04:23 +0300")
Message-ID: <m1tunny77w.fsf@fess.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
X-XM-SPF: eid=1lcXaR-00085W-UW; ; ; mid=<m1tunny77w.fsf@fess.ebiederm.org>; ; ;
 hst=in01.mta.xmission.com; ; ; ip=68.227.160.95; ; ; frm=ebiederm@xmission.com;
 ; ; spf=neutral
X-XM-AID: U2FsdGVkX18u6Xoo8s58CoWsQdxvXXEoS28W8e953RU=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
Subject: [PATCH] ucounts: Silence warning in dec_rlimit_ucounts
X-SA-Exim-Version: 4.2.1 (built Thu, 05 May 2016 13:38:54 -0600)
X-SA-Exim-Scanned: Yes (on in01.mta.xmission.com)
Cc: kbuild-all@lists.01.org, lkp@intel.com,
 Christian Brauner <christian.brauner@ubuntu.com>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Jann Horn <jannh@google.com>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 legion@kernel.org, kbuild@lists.01.org
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


Dan Carpenter <dan.carpenter@oracle.com> wrote:
>
> url:    https://github.com/0day-ci/linux/commits/legion-kernel-org/Count-rlimits-in-each-user-namespace/20210427-162857
> base:   https://git.kernel.org/pub/scm/linux/kernel/git/shuah/linux-kselftest.git next
> config: arc-randconfig-m031-20210426 (attached as .config)
> compiler: arceb-elf-gcc (GCC) 9.3.0
>
> If you fix the issue, kindly add following tag as appropriate
> Reported-by: kernel test robot <lkp@intel.com>
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
>
> smatch warnings:
> kernel/ucount.c:270 dec_rlimit_ucounts() error: uninitialized symbol 'new'.
>
> vim +/new +270 kernel/ucount.c
>
> 176ec2b092cc22 Alexey Gladkov 2021-04-22  260  bool dec_rlimit_ucounts(struct ucounts *ucounts, enum ucount_type type, long v)
> 176ec2b092cc22 Alexey Gladkov 2021-04-22  261  {
> 176ec2b092cc22 Alexey Gladkov 2021-04-22  262   struct ucounts *iter;
> 176ec2b092cc22 Alexey Gladkov 2021-04-22  263   long new;
>                                                 ^^^^^^^^
>
> 176ec2b092cc22 Alexey Gladkov 2021-04-22  264   for (iter = ucounts; iter; iter = iter->ns->ucounts) {
> 176ec2b092cc22 Alexey Gladkov 2021-04-22  265    long dec = atomic_long_add_return(-v, &iter->ucount[type]);
> 176ec2b092cc22 Alexey Gladkov 2021-04-22  266    WARN_ON_ONCE(dec < 0);
> 176ec2b092cc22 Alexey Gladkov 2021-04-22  267    if (iter == ucounts)
> 176ec2b092cc22 Alexey Gladkov 2021-04-22  268     new = dec;
> 176ec2b092cc22 Alexey Gladkov 2021-04-22  269   }
> 176ec2b092cc22 Alexey Gladkov 2021-04-22 @270   return (new == 0);
>                                                         ^^^^^^^^
> I don't know if this is a bug or not, but I can definitely tell why the
> static checker complains about it.
>
> 176ec2b092cc22 Alexey Gladkov 2021-04-22  271  }

In the only two cases that care about the return value of
dec_rlimit_ucounts the code first tests to see that ucounts is not
NULL.  In those cases it is guaranteed at least one iteration of the
loop will execute guaranteeing the variable new will be initialized.

Initialize new to -1 so that the return value is well defined even
when the loop does not execute and the static checker is silenced.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 kernel/ucount.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/ucount.c b/kernel/ucount.c
index d316bac3e520..12a48457bb86 100644
--- a/kernel/ucount.c
+++ b/kernel/ucount.c
@@ -263,7 +263,7 @@ long inc_rlimit_ucounts(struct ucounts *ucounts, enum ucount_type type, long v)
 bool dec_rlimit_ucounts(struct ucounts *ucounts, enum ucount_type type, long v)
 {
 	struct ucounts *iter;
-	long new;
+	long new = -1; /* Silence compiler warnings */
 	for (iter = ucounts; iter; iter = iter->ns->ucounts) {
 		long dec = atomic_long_add_return(-v, &iter->ucount[type]);
 		WARN_ON_ONCE(dec < 0);
-- 
2.30.1

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
