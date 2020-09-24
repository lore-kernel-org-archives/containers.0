Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MSGID_FROM_MTA_HEADER,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C124EC4363D
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 20:01:35 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id F0A5E21707
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 20:01:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=illinois.edu header.i=@illinois.edu header.b="JtAhWbmh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0A5E21707
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=illinois.edu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 6058F20495;
	Thu, 24 Sep 2020 20:01:34 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id gM2mlTecCU15; Thu, 24 Sep 2020 20:01:33 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 2B04420434;
	Thu, 24 Sep 2020 20:01:33 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 0B4DDC0859;
	Thu, 24 Sep 2020 20:01:33 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 62131C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 20:01:32 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 5BBF386BA8
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 20:01:32 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id rmOsKlnazQSc
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 20:01:31 +0000 (UTC)
X-Greylist: delayed 00:12:29 by SQLgrey-1.7.6
Received: from illinois.edu (relays-agent03.techservices.illinois.edu
 [192.17.82.70])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 032E186B92
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 20:01:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=illinois.edu;
 h=references :
 in-reply-to : from : date : message-id : subject : to : cc : content-type
 : mime-version; s=campusrelays;
 bh=/eDeqaFyUH+t373rLitrTZEIIaPUpbaRV0kHjAm9kjE=;
 b=JtAhWbmh7v/UH98BbWW5+W/NwV77m+uLYAtyxBqBXDaJHYiSyk0B/DyItK0EYH4u8O2K
 TiEabP8aa+GFJkvwrPG3A53rvNBRG6rxp5d/dw50T5rBXBsY5obuanS3Al4AN9Hk+W0f
 XVJMi/1lePj6LCc/O7wbPqjXe5t63RPsfJ5Avh7vqz/uKmC3tqlSE0AY321lvTXr3HvW
 X7GkzwFTtnc/jfKuleexqkuIkRr/csrsVn4zNYHUyHxWIUfVyZ/wBZ3F1Zhz1A78bWtO
 tJIdOa29AH7Ip2SSfmdZR8Rlv5xeHPTSjMCdVzI3uRYXQ9r3W/eQMRTme1xGH7sPPC9G 4w== 
Received: from NAM12-BN8-obe.outbound.protection.outlook.com
 (mail-bn8nam12lp2175.outbound.protection.outlook.com [104.47.55.175])
 by relays-agent03.techservices.illinois.edu (8.16.0.42/8.16.0.42) with ESMTPS
 id 08OJn0Ug013762
 (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT)
 for <containers@lists.linux-foundation.org>; Thu, 24 Sep 2020 14:49:01 -0500
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=F+yC8EeCFtxyT33LaBA5xrq4muwINwrPEhI7p011lFPkPzOz2pdZ4/fcz0vqsXsLqx2tkIi+qVZCoNzVpD5310EIs8LV8raKY/IHgd9V25GF6eXjsaFgDRTC4a9/QNHhJXk20KkZtyiFoJapftMTO1aTGux3/5xqFD2WCKPGPP6C/SjoClZhrSc8lpgCptJSZ4CDlvn0fKvMOpCKOjf5+hvfuK8c4VRa1mpKPn3/NxUHuAAB6FJLnfUqnXAnXC1jSRcSPw1JM5MANlO1FYrxLpGXgc3ahSEPATPNGOcv+phr5v8TyFv+X35Q4wf8FdICa4UJzMDtWBT4IBx72066Nw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=/eDeqaFyUH+t373rLitrTZEIIaPUpbaRV0kHjAm9kjE=;
 b=BmMllYT/PJi5942q+qWFgJviAiGRcFZlOGG/Fg+Xi2wT0lHYs8lYarXe2WCML6qVd63OpzHd3hpUWufmFyxK+pmtopxUrvgT6fksD53FbJjMA4m+6CnZpXGdvSnkn8pCqPUO79FthlD64bBnc4RyEAUwydbeTYcXDcxq9dHNJQExwO2XafchK7HkFWO3Utt5s17olLjQ4ryrhC4lxGAEpCMvZ5/sx62Aw9JY8RjsRoTAQBMa7uwQkA7z81rtDrzRVQGo8vmnF4Mz1jgYz8XDMOfhhm+yPnoy12Nq47b6mUd81Kh+Exc5ACE6+9De26fc3p1MBicyzCBDMoiV6nY+Pw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=illinois.edu; dmarc=pass action=none header.from=illinois.edu;
 dkim=pass header.d=illinois.edu; arc=none
Authentication-Results: lists.linux-foundation.org; dkim=none (message not
 signed) header.d=none;lists.linux-foundation.org; dmarc=none action=none
 header.from=illinois.edu;
Received: from DM5PR11MB1692.namprd11.prod.outlook.com (2603:10b6:3:d::23) by
 DM5PR1101MB2185.namprd11.prod.outlook.com (2603:10b6:4:4f::18) with
 Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.3412.22; Thu, 24 Sep 2020 19:49:00 +0000
Received: from DM5PR11MB1692.namprd11.prod.outlook.com
 ([fe80::c0ad:426c:3acd:3913]) by DM5PR11MB1692.namprd11.prod.outlook.com
 ([fe80::c0ad:426c:3acd:3913%6]) with mapi id 15.20.3391.027; Thu, 24 Sep 2020
 19:48:59 +0000
X-Gm-Message-State: AOAM533GORNtmjAMIPVzaN3DCtUgLq0vBWQOZzK5UiKmQq/UQyPGDLwN
 Dg0l72M4g/d0sEhE9ZCZmYMhUaCJlbejaf49PeA=
X-Google-Smtp-Source: ABdhPJyj+Sk/ztigsJ/n9fAvmUST2Rwf4QsW6kca8GDDYtzy07Ixu5L7nWXa2hpO9pt1Tw2ZB25QgUpKG7lcMyu4pPE=
X-Received: by 2002:a7b:c1d4:: with SMTP id a20mr312371wmj.30.1600976929010;
 Thu, 24 Sep 2020 12:48:49 -0700 (PDT)
References: <20200923232923.3142503-1-keescook@chromium.org>
 <20200924185702.GA9225@redhat.com>
 <9dbe8e3bbdad43a1872202ff38c34ca2@DM5PR11MB1692.namprd11.prod.outlook.com>
In-Reply-To: <9dbe8e3bbdad43a1872202ff38c34ca2@DM5PR11MB1692.namprd11.prod.outlook.com>
From: Tianyin Xu <tyxu@illinois.edu>
Date: Thu, 24 Sep 2020 14:48:37 -0500
X-Gmail-Original-Message-ID: <CAGMVDEEtNXWp4xOhC+EMa_Z_1KMQhKQohCKVY=Z70wTuLr5X+g@mail.gmail.com>
Message-ID: <CAGMVDEEtNXWp4xOhC+EMa_Z_1KMQhKQohCKVY=Z70wTuLr5X+g@mail.gmail.com>
Subject: Re: [PATCH v1 0/6] seccomp: Implement constant action bitmaps
To: Jann Horn <jannh@google.com>
X-ClientProxiedBy: AM0PR10CA0010.EURPRD10.PROD.OUTLOOK.COM
 (2603:10a6:208:17c::20) To DM5PR11MB1692.namprd11.prod.outlook.com
 (2603:10b6:3:d::23)
MIME-Version: 1.0
X-MS-Exchange-MessageSentRepresentingType: 1
Received: from mail-wm1-f43.google.com (209.85.128.43) by
 AM0PR10CA0010.EURPRD10.PROD.OUTLOOK.COM (2603:10a6:208:17c::20) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.3412.20 via Frontend
 Transport; Thu, 24 Sep 2020 19:48:59 +0000
Received: by mail-wm1-f43.google.com with SMTP id e17so321396wme.0 for
 <containers@lists.linux-foundation.org>; Thu, 24 Sep 2020 12:48:59 -0700 (PDT)
X-Gm-Message-State: AOAM533GORNtmjAMIPVzaN3DCtUgLq0vBWQOZzK5UiKmQq/UQyPGDLwN
 Dg0l72M4g/d0sEhE9ZCZmYMhUaCJlbejaf49PeA=
X-Google-Smtp-Source: ABdhPJyj+Sk/ztigsJ/n9fAvmUST2Rwf4QsW6kca8GDDYtzy07Ixu5L7nWXa2hpO9pt1Tw2ZB25QgUpKG7lcMyu4pPE=
X-Received: by 2002:a7b:c1d4:: with SMTP id a20mr312371wmj.30.1600976929010;
 Thu, 24 Sep 2020 12:48:49 -0700 (PDT)
X-Gmail-Original-Message-ID: <CAGMVDEEtNXWp4xOhC+EMa_Z_1KMQhKQohCKVY=Z70wTuLr5X+g@mail.gmail.com>
X-Originating-IP: [209.85.128.43]
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id: 8d613746-b4dd-4577-4436-08d860c2e16b
X-MS-TrafficTypeDiagnostic: DM5PR1101MB2185:
X-Microsoft-Antispam-PRVS: <DM5PR1101MB21859E5084B81F75CB6C2FD4BB390@DM5PR1101MB2185.namprd11.prod.outlook.com>
X-MS-Oob-TLC-OOBClassifiers: OLM:8882;
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam: BCL:0;
X-Microsoft-Antispam-Message-Info: CO+n5OrDmGpl1LfE1gF689yUXJxlPjMavmpEQMBvPmsZ9gSr0mh2HlxrDoPWTCL2llRkQ5FC+CTH13bUsZoKTGkI1WXzU75uN5Kn/B7hm0jIJjrleZLqEvsFS7AlkLBHHpQLeT5zjCHDZK8R0bsZOo+6GdxWGVjrFvsBS4G38ty4/0YFQMq9IDx5lVd8zjGp0P4q2CXScZtLZXkgUkgCSYRWQLGf08KXHv0rZROE488eYjGFlfZ5YJxf7qDOJ97bNrz+5ejEDMItW9lvQM/05jtcE1DPnWtM2qBi4FC+u+FUzzcVWZSflND1NjwwrpF2OavpQh9DBds9+ifVykjV6ZJpze1ZTP6ZSZnOIuaVGlN1SlyOK2H9jW18vYryAFarPZVCGLmFsuQZJ9+w2yR89g==
X-Forefront-Antispam-Report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:DM5PR11MB1692.namprd11.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(376002)(396003)(346002)(136003)(366004)(39860400002)(55446002)(86362001)(52116002)(786003)(478600001)(2906002)(54906003)(6666004)(53546011)(42186006)(186003)(6862004)(107886003)(26005)(66946007)(83380400001)(8676002)(4326008)(66476007)(5660300002)(316002)(66556008)(9686003)(8936002)(83080400001)(75432002)(966005);
 DIR:OUT; SFP:1101; 
X-MS-Exchange-AntiSpam-MessageData: dn+VPok/sQ4juNj105stHt0EKZBiq1tdSovuainzQxB87H+L0jjXFiPvsk0zCGCCJRL3yfBfxoyt9UKbXzBtwdv7Z4e491ejtFJG21POaEaa0R2m3Yn0QQtqxBAEram81HQGU5F+mnOvQQIWNcVIpwI8GwBwEv0YmCly+M/hTtTaLh7YFIcVM2a/GLmkRenE1TiOF7GOf5GAxxTlMZpotj9L1tqnoYjInL94h7LjnZDKP5Q7+FOdnzwBG9Tlhk/ou2tbDm7eoLbImchxXoxKrQZsRlrTNcRDn0XJexier3bucHG2+W9XJ58ZsPcijs3XBViMWADuRZnpq9UUcmc0k4QMCFEdum1C5/QqNO3ESEvgfsQg+xy61UxjWkkGAc4YfwlRfYfaj51B2cbC17ao9HiDlgxlmcA5y7n/BNQ31Kh9YQcmYVQex+ATN14JGDpBghB/2ecCMEmjnFSV6orT9txIKDtrVFxU+01EDqGxvHPsdE8w39tA9jfHaayogBTrFTgtTzgLnJwsVPg2Odps7+wL25itJdQ9v+YS57VphQAvmXOZe/yF/HkdVSj0MlYr9Q6EBPZ3PE2ElQyhhFkM0c6OEagI3BX6tQ43FweLqjbG83cp/sfKH8dEK7EbZcqGdt45pWJv07lTe7td5AcG5g==
X-OriginatorOrg: illinois.edu
X-MS-Exchange-CrossTenant-Network-Message-Id: 8d613746-b4dd-4577-4436-08d860c2e16b
X-MS-Exchange-CrossTenant-AuthSource: DM5PR11MB1692.namprd11.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 24 Sep 2020 19:48:59.6469 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 44467e6f-462c-4ea2-823f-7800de5434e3
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: +oH19cxADcSutoFEj4xSiQSvJzwKEVKNqQBTS75KNOp0/gieaf3tqbK/A/V/lSjM/c0BVx9X/tjdIx343j0ftg==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM5PR1101MB2185
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 Kees Cook <keescook@chromium.org>, "Zhu, YiFei" <yifeifz2@illinois.edu>,
 Linux API <linux-api@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 bpf <bpf@vger.kernel.org>, Tobin Feldman-Fitzthum <tobin@ibm.com>,
 Hubertus Franke <frankeh@us.ibm.com>, Andy Lutomirski <luto@amacapital.net>,
 Valentin Rothberg <vrothber@redhat.com>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>, "Chen,
 Jianyan" <jianyan2@illinois.edu>, "Torrellas, Josep" <torrella@illinois.edu>,
 kernel list <linux-kernel@vger.kernel.org>
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

On Thu, Sep 24, 2020 at 2:19 PM Jann Horn <jannh@google.com> wrote:
>
> On Thu, Sep 24, 2020 at 8:57 PM Andrea Arcangeli <aarcange@redhat.com> wrote:
> >
> > Hello,
> >
> > I'm posting this only for the record, feel free to ignore.
> >
> > On Wed, Sep 23, 2020 at 04:29:17PM -0700, Kees Cook wrote:
> > > rfc: https://lore.kernel.org/lkml/20200616074934.1600036-1-keescook@chromium.org/
> > > alternative: https://lore.kernel.org/containers/cover.1600661418.git.yifeifz2@illinois.edu/
> > > v1:
> > > - rebase to for-next/seccomp
> > > - finish X86_X32 support for both pinning and bitmaps
> >
> > It's pretty clear the O(1) seccomp filter bitmap was first was
> > proposed by your RFC in June (albeit it was located in the wrong place
> > and is still in the wrong place in v1).
> >
> > > - replace TLB magic with Jann's emulator
> >     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> >
> > That's a pretty fundamental change in v1 compared to your the
> > non-competing TLB magic technique you used in the RFC last June.
> >
> > The bitmap isn't the clever part of the patch, the bitmap can be
> > reviewed in seconds, the difficult part to implement and to review is
> > how you fill the bitmap and in that respect there's absolutely nothing
> > in common in between the "rfc:" and the "alternative" link.
> >
> > In June your bitmap-filling engine was this:
> >
> > https://lore.kernel.org/lkml/20200616074934.1600036-5-keescook@chromium.org/
> >
> > Then on Sep 21 YiFei Zhu posted his new innovative BPF emulation
> > innovation that obsoleted your TLB magic of June:
> >
> > https://lists.linuxfoundation.org/pipermail/containers/2020-September/042153.html
> >
> > And on Sep 23 instead of collaborating and helping YiFei Zhu to
> > improve his BPF emulator, you posted the same technique that looks
> > remarkably similar without giving YiFei Zhu any attribution and you
> > instead attribute the whole idea to Jann Horn:
> >
> > https://lkml.kernel.org/r/20200923232923.3142503-5-keescook@chromium.org
>
> You're missing that I did suggest the BPF emulation approach (with
> code very similar to Kees' current code) back in June:
> https://lore.kernel.org/lkml/CAG48ez1p=dR_2ikKq=xVxkoGg0fYpTBpkhJSv1w-6BG=76PAvw@mail.gmail.com/

I don't see it's a bad thing that two (or three?) teams come up with
the same ideas,
and I'm actually happy that the final solution is largely converging,
thanks to all the discussions so far.

It's better to collaborate and help each other, instead of racing on
two separate patches,
and everyone involved should be acknowledged.

Not sure if it matters, we actually started working on seccomp cache
in the end of 2018,
and our idea is to also support arguments in the cache.
We still have the paper draft sent to an academic conference at Apr 2019 :)
Unfortunately, our paper kept being rejected until recently.
Sadly, as academics, we prioritized papers over upstream.

I'm disclosing these not to dismiss anyone's innovations and hardwork.
I do really think we should work together to merge the right pieces of code,
instead of competing or ignoring others' effort.

--
Tianyin Xu
University of Illinois at Urbana-Champaign
https://tianyin.github.io/
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
