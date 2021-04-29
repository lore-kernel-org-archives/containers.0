Return-Path: <SRS0=7QB5=J2=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,FAKE_REPLY_C,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35F9CC433B4
	for <containers@archiver.kernel.org>; Thu, 29 Apr 2021 14:04:54 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 9FEF46141E
	for <containers@archiver.kernel.org>; Thu, 29 Apr 2021 14:04:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9FEF46141E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp2.osuosl.org (Postfix) with ESMTP id 20E0F40158;
	Thu, 29 Apr 2021 14:04:53 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp2.osuosl.org ([127.0.0.1])
	by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 4AFoDYMi3vhD; Thu, 29 Apr 2021 14:04:52 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp2.osuosl.org (Postfix) with ESMTP id 11554400C0;
	Thu, 29 Apr 2021 14:04:52 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id E1149C000D;
	Thu, 29 Apr 2021 14:04:51 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [IPv6:2605:bc80:3010::137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 34058C0001
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Apr 2021 14:04:51 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp4.osuosl.org (Postfix) with ESMTP id 2804941945
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Apr 2021 14:04:51 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp4.osuosl.org (amavisd-new);
 dkim=pass (2048-bit key) header.d=oracle.com
Received: from smtp4.osuosl.org ([127.0.0.1])
 by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id O7uUJArWHf71
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Apr 2021 14:04:49 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.8.0
Received: from aserp2120.oracle.com (aserp2120.oracle.com [141.146.126.78])
 by smtp4.osuosl.org (Postfix) with ESMTPS id AFE4341940
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Apr 2021 14:04:49 +0000 (UTC)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
 by aserp2120.oracle.com (8.16.0.42/8.16.0.42) with SMTP id 13TDtk9n174920;
 Thu, 29 Apr 2021 14:04:38 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com;
 h=date : from : to : cc
 : subject : message-id : mime-version : content-type : in-reply-to;
 s=corp-2020-01-29; bh=XWujCC1T2A1mMi7XFh+vWKACrp/bu7LxNnRA3pYtwqg=;
 b=h953Gq0Vwb2epbVqoLOWxkGz+aWIeGGh7TYELDFR2oJBUfQYiX+prI5i5pAAK07O3BgG
 zuNASl0NBCIt0UMwga5KsqBIBI452h7Cr3NbtnQ83vhvjL1ofIvS5tuN5lA3liqLwaju
 6iLHG6tS9nh81rpd0WrFDpVelyyh+6UZ9cpXEONciLOPWzUahSrsQ+nlhE1nhJ3xEqw0
 saZHr52QqKS5sZVv2xkfrig5w7MRtcmvc3wuHNFbJVnf6grZI1xdZaYIXz3iWhAR9ZyD
 6gSzam9m8fC8jxTinaK6b+PV8bd6bxVGRC24Bkat4IU5/Nqizx66EvVTXqIMNGPhQnGX 5A== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
 by aserp2120.oracle.com with ESMTP id 385ahbvga1-1
 (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
 Thu, 29 Apr 2021 14:04:38 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
 by userp3020.oracle.com (8.16.0.42/8.16.0.42) with SMTP id 13TDuhWk010686;
 Thu, 29 Apr 2021 14:04:37 GMT
Received: from pps.reinject (localhost [127.0.0.1])
 by userp3020.oracle.com with ESMTP id 384w3wbdhm-1
 (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
 Thu, 29 Apr 2021 14:04:37 +0000
Received: from userp3020.oracle.com (userp3020.oracle.com [127.0.0.1])
 by pps.reinject (8.16.0.36/8.16.0.36) with SMTP id 13TE4afv065013;
 Thu, 29 Apr 2021 14:04:36 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
 by userp3020.oracle.com with ESMTP id 384w3wbdgd-1
 (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
 Thu, 29 Apr 2021 14:04:36 +0000
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
 by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id 13TE4WEV006195;
 Thu, 29 Apr 2021 14:04:32 GMT
Received: from kadam (/102.36.221.92) by default (Oracle Beehive Gateway v4.0)
 with ESMTP ; Thu, 29 Apr 2021 07:04:32 -0700
Date: Thu, 29 Apr 2021 17:04:23 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: kbuild@lists.01.org, legion@kernel.org,
 LKML <linux-kernel@vger.kernel.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 linux-mm@kvack.org
Subject: Re: [PATCH v11 4/9] Reimplement RLIMIT_NPROC on top of ucounts
Message-ID: <202104272256.9Y5ZQxrO-lkp@intel.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <c5286a8aa16d2d698c222f7532f3d735c82bc6bc.1619094428.git.legion@kernel.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-GUID: GnOKWP_uxfwZW1upvqeIeMmTwjRK-LjD
X-Proofpoint-ORIG-GUID: GnOKWP_uxfwZW1upvqeIeMmTwjRK-LjD
X-Proofpoint-Virus-Version: vendor=nai engine=6200 definitions=9969
 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 mlxscore=0
 bulkscore=0 mlxlogscore=999
 priorityscore=1501 clxscore=1011 adultscore=0 suspectscore=0 spamscore=0
 phishscore=0 malwarescore=0 lowpriorityscore=0 impostorscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.12.0-2104060000
 definitions=main-2104290093
Cc: kbuild-all@lists.01.org, lkp@intel.com, Jann Horn <jannh@google.com>,
 Linux Memory Management List <linux-mm@kvack.org>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 Andrew Morton <akpm@linux-foundation.org>, Alexey Gladkov <legion@kernel.org>,
 Christian Brauner <christian.brauner@ubuntu.com>
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

url:    https://github.com/0day-ci/linux/commits/legion-kernel-org/Count-rlimits-in-each-user-namespace/20210427-162857
base:   https://git.kernel.org/pub/scm/linux/kernel/git/shuah/linux-kselftest.git next
config: arc-randconfig-m031-20210426 (attached as .config)
compiler: arceb-elf-gcc (GCC) 9.3.0

If you fix the issue, kindly add following tag as appropriate
Reported-by: kernel test robot <lkp@intel.com>
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>

smatch warnings:
kernel/ucount.c:270 dec_rlimit_ucounts() error: uninitialized symbol 'new'.

vim +/new +270 kernel/ucount.c

176ec2b092cc22 Alexey Gladkov 2021-04-22  260  bool dec_rlimit_ucounts(struct ucounts *ucounts, enum ucount_type type, long v)
176ec2b092cc22 Alexey Gladkov 2021-04-22  261  {
176ec2b092cc22 Alexey Gladkov 2021-04-22  262  	struct ucounts *iter;
176ec2b092cc22 Alexey Gladkov 2021-04-22  263  	long new;
                                                ^^^^^^^^

176ec2b092cc22 Alexey Gladkov 2021-04-22  264  	for (iter = ucounts; iter; iter = iter->ns->ucounts) {
176ec2b092cc22 Alexey Gladkov 2021-04-22  265  		long dec = atomic_long_add_return(-v, &iter->ucount[type]);
176ec2b092cc22 Alexey Gladkov 2021-04-22  266  		WARN_ON_ONCE(dec < 0);
176ec2b092cc22 Alexey Gladkov 2021-04-22  267  		if (iter == ucounts)
176ec2b092cc22 Alexey Gladkov 2021-04-22  268  			new = dec;
176ec2b092cc22 Alexey Gladkov 2021-04-22  269  	}
176ec2b092cc22 Alexey Gladkov 2021-04-22 @270  	return (new == 0);
                                                        ^^^^^^^^
I don't know if this is a bug or not, but I can definitely tell why the
static checker complains about it.

176ec2b092cc22 Alexey Gladkov 2021-04-22  271  }

---
0-DAY CI Kernel Test Service, Intel Corporation
https://lists.01.org/hyperkitty/list/kbuild-all@lists.01.org

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
