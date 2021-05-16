Received: from mx0a-00007101.pphosted.com (mx0a-00007101.pphosted.com [148.163.135.28])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 302AB72
	for <containers@lists.linux.dev>; Sun, 16 May 2021 09:20:37 +0000 (UTC)
Received: from pps.filterd (m0166256.ppops.net [127.0.0.1])
	by mx0a-00007101.pphosted.com (8.16.0.43/8.16.0.43) with SMTP id 14G8cceE023521
	for <containers@lists.linux.dev>; Sun, 16 May 2021 08:39:45 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=illinois.edu; h=references :
 in-reply-to : from : date : message-id : subject : to : cc : content-type
 : content-transfer-encoding : mime-version; s=campusrelays;
 bh=qQ/I50w7dcH067HPwFRfmHnYsMmIAPVlMksMp1hIXN4=;
 b=rqSAHwEycdzf4RWDLU8YQefc4TVB83+/qk37vpIwHXFfBOd4D3GPnP0hUYkfK7PJdLEo
 CYYtwMZ0Z9NdbMstLPjR6m6565+3eZ/wmkdQ0Hgmie4E7k1+s0n9STQqP/zKBybIfdUl
 +729UQVDMtYuX/Xi+oxHR4GwuNz5WlRtNIpr0+/dCFWiTnfL3J7nZpiFXmvR/fTYqXUl
 XJ/QUtE+Ec9r/W80PkpO9L/7AvbD3wAz05M4b5IJFinGeo/96CKJd1v07LQFnM7HpVlG
 FHlMdIHGgzjlPFZ7eXP8EMbhDEspD4Rjmtu8DiNgZfB8IeniH95qapo0lmwgf6PjMuzP cg== 
Received: from nam04-bn8-obe.outbound.protection.outlook.com (mail-bn8nam08lp2047.outbound.protection.outlook.com [104.47.74.47])
	by mx0a-00007101.pphosted.com with ESMTP id 38j3d13xfy-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT)
	for <containers@lists.linux.dev>; Sun, 16 May 2021 08:39:45 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=LZ/rn87z9fvmUXIUsrnlCjf0Dzb5kVPIWyNamS+TxkKbGhanITvscPmZG/rJg5BEmW2dB6UGSfHMZ1/UMNE0HR5q6H8kaAvzhJPipjq/3vGKBImqFK1tQqJvRFDHv5YEt0GUM3INpmmtKVc7WquLz4+5RHooyLQbQ+wsjCPtnN1n09cwuI7eK64IFANsqSsTjxjE1kYbr5TbR/S6C6TY55ZzYfFrHMemIoYpeimgreEezm0nJ2SiYNX+a1p0XycsNNPpH+ZdglkVPePflKaMX1KFAz2BbKfaB56frizNLo1FAW4ICJjMAm8yqT0va77NcMtrkASmRrDTGNWXCvUbMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=qQ/I50w7dcH067HPwFRfmHnYsMmIAPVlMksMp1hIXN4=;
 b=e2wCjgKryAnDzh6ccAXvMOcUjO+ORAtsSTYl09eLZyfrJlFUFzNSY6M1mpxtYl1lYN8PpMhHLQPpuE3RklyirYN4aIbMD6uanVDYMQVnUU8D5+BuhUSVf/GN4pxzurRighnm6Lv/Mon/3yrYfb+KuSc7BXYxdCnLJR8/Jn2PHss2nnK1wzorbD7i1KIc9GrN90qTa/NGeT7rBMPCrQzxc3AcqiAmIfe/nv7rVN+v+dRmBlaUe3lzWdZI2Sx/dbKlUlHlRXV3Xwpc37MDMzXR5cdR7PTDNO5u2GODPp8vPaR5ZxwXZ28gHyMHE28pxQvtlditwmPVTUwB82DEo9FPQg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=illinois.edu; dmarc=pass action=none header.from=illinois.edu;
 dkim=pass header.d=illinois.edu; arc=none
Authentication-Results: lists.linux.dev; dkim=none (message not signed)
 header.d=none;lists.linux.dev; dmarc=none action=none
 header.from=illinois.edu;
Received: from DM5PR11MB1692.namprd11.prod.outlook.com (2603:10b6:3:d::23) by
 DM6PR11MB4075.namprd11.prod.outlook.com (2603:10b6:5:198::25) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.4129.25; Sun, 16 May 2021 08:39:42 +0000
Received: from DM5PR11MB1692.namprd11.prod.outlook.com
 ([fe80::21bb:c117:6de2:2ac8]) by DM5PR11MB1692.namprd11.prod.outlook.com
 ([fe80::21bb:c117:6de2:2ac8%8]) with mapi id 15.20.4129.029; Sun, 16 May 2021
 08:39:42 +0000
X-Gm-Message-State: AOAM533vbagX8koD22//YQAcfUVbLj3Z7lYKB2tPXoY31buFMWm3qjec
	7xbKy9tmFKUpbwY6UVLUlabZNOhzWRNO+ReLFB0=
X-Google-Smtp-Source: ABdhPJwuCidSzuAp4N75lRjaxBuC6OMd8MPgC9s7ISUoghSRXUoQottYsgC0o7KUgyu6D/6TlN2GplA6Lv8jd0zYaVg=
X-Received: by 2002:a25:f504:: with SMTP id a4mr76097385ybe.150.1621154381098;
 Sun, 16 May 2021 01:39:41 -0700 (PDT)
References: <cover.1620499942.git.yifeifz2@illinois.edu> <CALCETrUQBonh5BC4eomTLpEOFHVcQSz9SPcfOqNFTf2TPht4-Q@mail.gmail.com>
 <CABqSeASYRXMwTQwLfm_Tapg45VUy9sPfV7BeeV8p7XJrDoLf+Q@mail.gmail.com> <fffbea8189794a8da539f6082af3de8e@DM5PR11MB1692.namprd11.prod.outlook.com>
In-Reply-To: <fffbea8189794a8da539f6082af3de8e@DM5PR11MB1692.namprd11.prod.outlook.com>
From: Tianyin Xu <tyxu@illinois.edu>
Date: Sun, 16 May 2021 03:38:00 -0500
X-Gmail-Original-Message-ID: <CAGMVDEGzGB4+6gJPTw6Tdng5ur9Jua+mCbqwPoNZ16EFaDcmjA@mail.gmail.com>
Message-ID: <CAGMVDEGzGB4+6gJPTw6Tdng5ur9Jua+mCbqwPoNZ16EFaDcmjA@mail.gmail.com>
Subject: Re: [RFC PATCH bpf-next seccomp 00/12] eBPF seccomp filters
To: Andy Lutomirski <luto@kernel.org>
Cc: YiFei Zhu <zhuyifei1999@gmail.com>,
        "containers@lists.linux.dev" <containers@lists.linux.dev>,
        bpf <bpf@vger.kernel.org>, "Zhu, YiFei" <yifeifz2@illinois.edu>,
        LSM List <linux-security-module@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Andrea Arcangeli <aarcange@redhat.com>,
        "Kuo, Hsuan-Chi" <hckuo2@illinois.edu>,
        Claudio Canella <claudio.canella@iaik.tugraz.at>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Gruss <daniel.gruss@iaik.tugraz.at>,
        Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
        Giuseppe Scrivano <gscrivan@redhat.com>,
        Hubertus Franke <frankeh@us.ibm.com>, Jann Horn <jannh@google.com>,
        "Jia, Jinghao" <jinghao7@illinois.edu>,
        "Torrellas, Josep" <torrella@illinois.edu>,
        Kees Cook <keescook@chromium.org>, Sargun Dhillon <sargun@sargun.me>,
        Tobin Feldman-Fitzthum <tobin@ibm.com>,
        Tom Hromatka <tom.hromatka@oracle.com>, Will Drewry <wad@chromium.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Originating-IP: [209.85.219.173]
X-ClientProxiedBy: BN6PR19CA0094.namprd19.prod.outlook.com
 (2603:10b6:404:133::32) To DM5PR11MB1692.namprd11.prod.outlook.com
 (2603:10b6:3:d::23)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
X-MS-Exchange-MessageSentRepresentingType: 1
Received: from mail-yb1-f173.google.com (209.85.219.173) by BN6PR19CA0094.namprd19.prod.outlook.com (2603:10b6:404:133::32) with Microsoft SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.4108.25 via Frontend Transport; Sun, 16 May 2021 08:39:42 +0000
Received: by mail-yb1-f173.google.com with SMTP id y2so4530875ybq.13        for <containers@lists.linux.dev>; Sun, 16 May 2021 01:39:42 -0700 (PDT)
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id: b962c99a-eb68-410c-2e61-08d91846266c
X-MS-TrafficTypeDiagnostic: DM6PR11MB4075:
X-Microsoft-Antispam-PRVS: 
	<DM6PR11MB40759F018E6AE75FE74B02E2BB2E9@DM6PR11MB4075.namprd11.prod.outlook.com>
X-MS-Oob-TLC-OOBClassifiers: OLM:10000;
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam: BCL:0;
X-Microsoft-Antispam-Message-Info: 
	zxcOQUO0kvsxf7+aDYuKl2a+xEyhyMoaoKMeNMQtB9qbgBgYIlLJCBli6EK4CvUHIgx9Y5Ye7hX8Mack9kmeDQAphrWoz9Mchlj05eTFT8SDcxDh5lcaiJq0EsWXc90L0iqZVJLQPhSm8O0Kdnm1DlfvFLdVyzqtle2L2/9qb9qRFgxLETHuN1uwjtn/l4/1rVzmZKpfnSMT4a4i+TtItwgaGiJvbxZNf6hBR8lGDJW4LqfZ4XtGpAxadl/bE4SggTVTJoL7XXxF/eKmvAYCgrK42OnwnaM+hJdqe50LdzvaA2MYl0lu21LCM8W1WhwTg6BN4W4wCRqx6cCSUIym4iPsqLN+16zGTNhRxAuDdiAzxPaTyQwGPWY8zMFRuYbvX3C43QueUwtL6yGmO+xMyIPdPZ3kvK1ewp6RHVf9neKZxx0AK3KOFgkJWR+7+KORw6tsBYtI50sAdJryvhYeu11huo1QyRVRs63Oi4qwjU8TWEI/M1F06Z3BYrrPdeQbG/TGuUwKvXPe6+2ix0vZxcBL1ipeIBBF97bcNOeFfK+cgiii0OH2SSkyV5vNhuNhvEJ6WM4rvkdhtrs2qWK9HKBv+CRrprMsKrqtfRKIJoEB7l9kUyptgNaLofmTgak9RuFnPCK5vAmzjc6vO3+P0o0US3yPUDZD6H78aXQ3p8E3u58i4FfI1DssERwcdDtxqowesYtB4/LTESzbeH0c6vWJtX+wVhRWRqijUWnqCI6h4NJRcYmxkIZ+fU13MrpEMI6y6bHPHbbVp5pZsDSH/g==
X-Forefront-Antispam-Report: 
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:DM5PR11MB1692.namprd11.prod.outlook.com;PTR:;CAT:NONE;SFS:(4636009)(39860400002)(376002)(366004)(396003)(136003)(346002)(55446002)(6862004)(2906002)(42186006)(107886003)(316002)(54906003)(75432002)(5660300002)(38100700002)(8936002)(4326008)(55236004)(83380400001)(66476007)(786003)(186003)(8676002)(66556008)(6666004)(38350700002)(478600001)(86362001)(26005)(966005)(53546011)(9686003)(52116002)(66946007);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData: 
	=?utf-8?B?dU56QVo3T1lJcVY2VkpjeGhINkJZU3pocTBISWUrRWg5c2FYY3kxcXUvOXR6?=
 =?utf-8?B?blVvOGZGUkdZOFVtQXF0MisvcjV0TXA5VUhzMGFRdlpYY2daRHhsK3Y3cGFv?=
 =?utf-8?B?QXJyRktOOWJUeFFnMUgxck5iKzZtV1lhY2VQN3lWeTlJZ2tVYmhVYnNEZ2t6?=
 =?utf-8?B?RHpmcG1Yc0pwbWd3amhZdkRjQllUK0ZoNkc5MkdlUEV6aXovVDN0NHR0ek5R?=
 =?utf-8?B?ckpieHA2MFlwWGxpUVp4N2QxNndkb3V1WjZvUWIrTVhYMHU4RlRYTzRlVTBW?=
 =?utf-8?B?b0xSc2IvakhnQ1p2VXNmV1BIMEo5aGJvSGtJcndqbUZiSFBwS0JxSUYxaWVs?=
 =?utf-8?B?YnlVRHcyQ1pVSGh0OTdXZEtXTHdzZ1pVN292SnlXTGlLc2pLakhORjgydXlM?=
 =?utf-8?B?d2xOVjNLY0xUa2g0N01HKzJkWmpNUGFvcU5mSHUvL0k4WDg5VkhYakNnMXc2?=
 =?utf-8?B?NXZjdzFEQ09DcHZwSmFoY1hwVXE2L2J1UHo4L0lVSDBnejlxS1RNZGxoUXhT?=
 =?utf-8?B?ZmdpQUhEeitVaU4zVzErRElLYWpOQXRmZ2V3aE5lN3hpSHBCbW1sVmZZMUQx?=
 =?utf-8?B?c24zQVUzWjVmUVpjb1o4bk1rU21hcDV2MUR4UmhhaWgzUitlSHYwR3IxeVhD?=
 =?utf-8?B?L2FZTmxicTJrbVJRZ0hZK1hLVnpZUHl1VGM0bU85RWh5VEt1TGRqdmozckVw?=
 =?utf-8?B?SFVaNGVwcnduRERQUFI1QzRudEVES3Z0bFk5b09RQ1ZlbE95cHNLZGg5Tjkr?=
 =?utf-8?B?ZGNYRUtlM2ZMNWt5bWszd0hLeldLd2lkMWFCREtQdDVpeVp5am9aK0FnWDJq?=
 =?utf-8?B?eFpROE1ZUjlhektnVHRmNjlQL3k1a0JJclBSenBSc2xYaVc2eGMyUzVxckw4?=
 =?utf-8?B?ZmZCMU16LzhySzN4Mmp0OFRxVGF4dHJkdUhYK2I5c3ZIS0xQZlZLV0dxSTN5?=
 =?utf-8?B?MksrSGpFUllmRC8rVVBueWVaWE15NUtMK0MzT0V1SERkcGtBVXFORHl3a0xZ?=
 =?utf-8?B?WEpwc3lKWEIzRGhKSzRpSWFFSVBjZ2Z0MzlBMkxoQlROWTQyTFpoMktXMnRs?=
 =?utf-8?B?UDhEeVdSRVNFMkZKNHBPS2JaalNvSDFTc0M5VW9ZQ0VGODU1ay9XaXI5T2JM?=
 =?utf-8?B?bTFTR0Z5Qjd2aGhoOUY1MDE1ejI2bHZROUZsVjQyQW9qN2N5emdDV0VNTmxm?=
 =?utf-8?B?VUFJSW8vRklNUVNRZkY5MU5NekpzeElYS3A0UGFBc3RxNDkvdC9WdXpvY05O?=
 =?utf-8?B?U1U5eFM5OXZvMnVPVG1iMVkvRy9uT0xMZDcwWithc2lCeUdWd1dlM1lRL25Q?=
 =?utf-8?B?UEVPdXQ4K2lwaU50dlZJME1jZmpFSjExTG9VY0FRRi9admViUDRWNUxWK01o?=
 =?utf-8?B?SGdCemR1cjRZYk80RGFjb3FJUDRzWDlKKzdqZXJMUWs3V1J5Z2ZvQXQ5OEg5?=
 =?utf-8?B?VzVFMWI5ZXRmK3VtUXU5cHdxSHovS0d3SzMzcThwSmdmU1FCb3hqSHlVa09o?=
 =?utf-8?B?TGZOWng1L04vaXdxSlM1V1B3c0I4b1Q1QVpVUVdzdG5qRDhseGU4UG1LeWpk?=
 =?utf-8?B?RHJoVi9ka3VJelhPRmhTOUpsZlVodzJURnVlenZwbi83eklqT1V2UkFudmVz?=
 =?utf-8?B?VXZud3lIL3g1SURZVTNxenFIRE5QQmh2UUFBVEoyN3ZLaThMcCtEUlg5YTlH?=
 =?utf-8?B?SlZUL1Y4UzNpUHhERHpuNTcrSG9hYXFUU3h4MEE0cGJ6L1ZPWU5VS25JSk5M?=
 =?utf-8?Q?4blR5AQJBHtgGqt5eK3PT8AJfWAmTUIui4PKIdJ?=
X-OriginatorOrg: illinois.edu
X-MS-Exchange-CrossTenant-Network-Message-Id: b962c99a-eb68-410c-2e61-08d91846266c
X-MS-Exchange-CrossTenant-AuthSource: DM5PR11MB1692.namprd11.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 16 May 2021 08:39:42.4535
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 44467e6f-462c-4ea2-823f-7800de5434e3
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: eP50x3IhrtsUPAG/tRaWBXrJHynR7pIcXyakBOmup5/W89s4bsqaci8zMzMSyj+I8uRsm5MmhjMMdz7mUiqHvA==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR11MB4075
X-Proofpoint-ORIG-GUID: ZNkJZp9pOenA9v-tz9AjbFXZKIj4cnZW
X-Proofpoint-GUID: ZNkJZp9pOenA9v-tz9AjbFXZKIj4cnZW
X-Spam-Details: rule=cautious_plus_nq_notspam policy=cautious_plus_nq score=0 adultscore=0
 clxscore=1011 priorityscore=1501 spamscore=0 lowpriorityscore=0 mlxscore=0
 impostorscore=0 mlxlogscore=999 phishscore=0 malwarescore=0 bulkscore=0
 suspectscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.12.0-2104190000 definitions=main-2105160067
X-Spam-Score: 0
X-Spam-OrigSender: tyxu@illinois.edu
X-Spam-Bar: 

On Sat, May 15, 2021 at 10:49 AM Andy Lutomirski <luto@kernel.org> wrote:
>
> On 5/10/21 10:21 PM, YiFei Zhu wrote:
> > On Mon, May 10, 2021 at 12:47 PM Andy Lutomirski <luto@kernel.org> wrot=
e:
> >> On Mon, May 10, 2021 at 10:22 AM YiFei Zhu <zhuyifei1999@gmail.com> wr=
ote:
> >>>
> >>> From: YiFei Zhu <yifeifz2@illinois.edu>
> >>>
> >>> Based on: https://urldefense.com/v3/__https://lists.linux-foundation.=
org/pipermail/containers/2018-February/038571.html__;!!DZ3fjg!thbAoRgmCeWjl=
v0qPDndNZW1j6Y2Kl_huVyUffr4wVbISf-aUiULaWHwkKJrNJyo$
> >>>
> >>> This patchset enables seccomp filters to be written in eBPF.
> >>> Supporting eBPF filters has been proposed a few times in the past.
> >>> The main concerns were (1) use cases and (2) security. We have
> >>> identified many use cases that can benefit from advanced eBPF
> >>> filters, such as:
> >>
> >> I haven't reviewed this carefully, but I think we need to distinguish
> >> a few things:
> >>
> >> 1. Using the eBPF *language*.
> >>
> >> 2. Allowing the use of stateful / non-pure eBPF features.
> >>
> >> 3. Allowing the eBPF programs to read the target process' memory.
> >>
> >> I'm generally in favor of (1).  I'm not at all sure about (2), and I'm
> >> even less convinced by (3).
> >>
> >>>
> >>>   * exec-only-once filter / apply filter after exec
> >>
> >> This is (2).  I'm not sure it's a good idea.
> >
> > The basic idea is that for a container runtime it may wait to execute
> > a program in a container without that program being able to execve
> > another program, stopping any attack that involves loading another
> > binary. The container runtime can block any syscall but execve in the
> > exec-ed process by using only cBPF.
> >
> > The use case is suggested by Andrea Arcangeli and Giuseppe Scrivano.
> > @Andrea and @Giuseppe, could you clarify more in case I missed
> > something?
>
> We've discussed having a notifier-using filter be able to replace its
> filter.  This would allow this and other use cases without any
> additional eBPF or cBPF code.
>

A notifier is not always a solution (even ignoring its perf overhead).

One problem, pointed out by Andrea Arcangeli, is that notifiers need
userspace daemons. So, it can hardly be used by daemonless container
engines like Podman.

And, /* sorry for repeating.. */ the performance overhead of notifiers
is not close to ebpf, which prevents use cases that require native
performance.


> >> eBPF doesn't really have a privilege model yet.  There was a long and
> >> disappointing thread about this awhile back.
> >
> > The idea is that =E2=80=9Cseccomp-eBPF does not make life easier for an
> > adversary=E2=80=9D. Any attack an adversary could potentially utilize
> > seccomp-eBPF, they can do the same with other eBPF features, i.e. it
> > would be an issue with eBPF in general rather than specifically
> > seccomp=E2=80=99s use of eBPF.
> >
> > Here it is referring to the helpers goes to the base
> > bpf_base_func_proto if the caller is unprivileged (!bpf_capable ||
> > !perfmon_capable). In this case, if the adversary would utilize eBPF
> > helpers to perform an attack, they could do it via another
> > unprivileged prog type.
> >
> > That said, there are a few additional helpers this patchset is adding:
> > * get_current_uid_gid
> > * get_current_pid_tgid
> >   These two provide public information (are namespaces a concern?). I
> > have no idea what kind of exploit it could add unless the adversary
> > somehow side-channels the task_struct? But in that case, how is the
> > reading of task_struct different from how the rest of the kernel is
> > reading task_struct?
>
> Yes, namespaces are a concern.  This idea got mostly shot down for kdbus
> (what ever happened to that?), and it likely has the same problems for
> seccomp.
>
> >>
> >> What is this for?
> >
> > Memory reading opens up lots of use cases. For example, logging what
> > files are being opened without imposing too much performance penalty
> > from strace. Or as an accelerator for user notify emulation, where
> > syscalls can be rejected on a fast path if we know the memory contents
> > does not satisfy certain conditions that user notify will check.
> >
>
> This has all kinds of race conditions.
>
>
> I hate to be a party pooper, but this patchset is going to very high bar
> to acceptance.  Right now, seccomp has a couple of excellent properties:
>
> First, while it has limited expressiveness, it is simple enough that the
> implementation can be easily understood and the scope for
> vulnerabilities that fall through the cracks of the seccomp sandbox
> model is low.  Compare this to Windows' low-integrity/high-integrity
> sandbox system: there is a never ending string of sandbox escapes due to
> token misuse, unexpected things at various integrity levels, etc.
> Seccomp doesn't have tokens or integrity levels, and these bugs don't
> happen.
>
> Second, seccomp works, almost unchanged, in a completely unprivileged
> context.  The last time making eBPF work sensibly in a less- or
> -unprivileged context, the maintainers mostly rejected the idea of
> developing/debugging a permission model for maps, cleaning up the bpf
> object id system, etc.  You are going to have a very hard time
> convincing the seccomp maintainers to let any of these mechanism
> interact with seccomp until the underlying permission model is in place.
>
> --Andy

Thanks for pointing out the tradeoff between expressiveness vs. simplicity.

Note that we are _not_ proposing to replace cbpf, but propose to also
support ebpf filters. There certainly are use cases where cbpf is
sufficient, but there are also important use cases ebpf could make
life much easier.

Most importantly, we strongly believe that ebpf filters can be
supported without reducing security.

No worries about =E2=80=9Cparty pooping=E2=80=9D and we appreciate the feed=
back. We=E2=80=99d
love to hear concerns and collect feedback so we can address them to
hit that very high bar.


~t

--
Tianyin Xu
University of Illinois at Urbana-Champaign
https://tianyin.github.io/
