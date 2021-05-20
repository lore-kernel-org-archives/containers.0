Received: from mx0a-00007101.pphosted.com (mx0a-00007101.pphosted.com [148.163.135.28])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 98DBC71
	for <containers@lists.linux.dev>; Thu, 20 May 2021 08:22:33 +0000 (UTC)
Received: from pps.filterd (m0166256.ppops.net [127.0.0.1])
	by mx0a-00007101.pphosted.com (8.16.0.43/8.16.0.43) with SMTP id 14K8MVBa021713
	for <containers@lists.linux.dev>; Thu, 20 May 2021 08:22:33 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=illinois.edu; h=references :
 in-reply-to : from : date : message-id : subject : to : cc : content-type
 : content-transfer-encoding : mime-version; s=campusrelays;
 bh=1vPOD5/SmQsAgA03fHyImG1OAuwriWypWFoAzmvGm6I=;
 b=sPNwiFe6S8wsmQIxVY4LXrjMwLMd7xOh1Hizn+ZctPDGsa2piZ2uwdpFZwoZWkLxp3c/
 vOPPbtujJ3MSOjx6Uwr580BNcpUja1wBzDxPW+z/7odxxgesWtek32ZTNQ8czevptCp7
 nFyoZ1Z6e/kOxk/Pa2BHgCNj667xmJgYIRYi3qgMpBusajhwZ0JdP2oOxYDS7XEX0AvH
 c2BqeS1bgLiWQ4c+ciHVIH5tXEkz1V2M5pcGu+ryqXReB/mLWXI/0GtWSwtq5WjNKGuK
 rTPHAJZETNPm97X7iadUJyf2aOl42tir/VmfyHlGlJVypNlR19WVokxtJAhgfoYRUZRz WQ== 
Received: from nam10-mw2-obe.outbound.protection.outlook.com (mail-mw2nam10lp2104.outbound.protection.outlook.com [104.47.55.104])
	by mx0a-00007101.pphosted.com with ESMTP id 38mvytb18e-4
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT)
	for <containers@lists.linux.dev>; Thu, 20 May 2021 08:22:32 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=IQqHeavvrcNIk6ap+EPQumSzUIVt9lspEKAy9xQW7pkny6K+jJW3rvZY3W8Mf0OVg/XYj+jUS4V9Tzfy2ZcS3jveGfEevnCBEI15izJEWsuTV0FqV6cwfh9MmTmejmuGgUQS+wGGY+A5oVs0KCUFji8slyNyk1ZuHCDxp3kjdBG8FLO+XTsLL955gj3WM7W19IfE9M7bTK3fOtPfh0p0tG3Bq4oz5qxvfIackICuA0aVLCyu4kf3mhojNFXyGjbNkVoJldDUdFmFnh4h3x787Mci8YyEBL9TnftNZQFaLQazocyYhWfJRu3oat+CDE05y6qRxJuCmV/jbr4GIuPubA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=1vPOD5/SmQsAgA03fHyImG1OAuwriWypWFoAzmvGm6I=;
 b=HUGB+BA9iPi7hjmZbOeGNIUc4T2o9nuWDQND07o1RQr9l0m9YakTJHDsEkT6aCbMFMMIXjhKC46fJ5xovD9qqFL6aAXK2MUMUr9st0RO6rkISJNGhoMAIeVPJM2/sClAcpE6SCsCSg1eTVDICOIZw2t6GbA+T8jwyvdY6MrbDhQPK/DvSeB9SZY9DJWB3ZHGekjNif7GXIfD4KKDYLgDjnBoxa8Q1U6vI5uYysGsUklKWJWjpVeV/rJ1jUS126WiEwMBWBikWyDbQcJR78p41RID47GWHXdHQAucTfOMCPOLPoEhWAzBt/gHlYI3C18njvlzelomYsqT05UV6IuNmg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=illinois.edu; dmarc=pass action=none header.from=illinois.edu;
 dkim=pass header.d=illinois.edu; arc=none
Authentication-Results: lists.linux.dev; dkim=none (message not signed)
 header.d=none;lists.linux.dev; dmarc=none action=none
 header.from=illinois.edu;
Received: from DM5PR11MB1692.namprd11.prod.outlook.com (2603:10b6:3:d::23) by
 DM5PR11MB0028.namprd11.prod.outlook.com (2603:10b6:4:67::30) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.4129.29; Thu, 20 May 2021 08:22:28 +0000
Received: from DM5PR11MB1692.namprd11.prod.outlook.com
 ([fe80::21bb:c117:6de2:2ac8]) by DM5PR11MB1692.namprd11.prod.outlook.com
 ([fe80::21bb:c117:6de2:2ac8%8]) with mapi id 15.20.4129.034; Thu, 20 May 2021
 08:22:28 +0000
X-Gm-Message-State: AOAM5307QU8q6x050xyklOTXAHbC6E8hdZ3FHc2E8sc+6FQERYoTgBc1
	+W2ILPGfmq7Pg5r7siX3+yNONw3MECG0btoAZtk=
X-Google-Smtp-Source: ABdhPJzYU8PPIuEKhtS+s4rdR95FWltc+cSLP5SJssuxJoJj622hGX0S886hCqXMZOEN4UXHj5aN0EnLbLZISELxyQ8=
X-Received: by 2002:a25:38ca:: with SMTP id f193mr5520847yba.422.1621498944674;
 Thu, 20 May 2021 01:22:24 -0700 (PDT)
References: <cover.1620499942.git.yifeifz2@illinois.edu> <CALCETrUQBonh5BC4eomTLpEOFHVcQSz9SPcfOqNFTf2TPht4-Q@mail.gmail.com>
 <CABqSeASYRXMwTQwLfm_Tapg45VUy9sPfV7BeeV8p7XJrDoLf+Q@mail.gmail.com>
 <fffbea8189794a8da539f6082af3de8e@DM5PR11MB1692.namprd11.prod.outlook.com>
 <CAGMVDEGzGB4+6gJPTw6Tdng5ur9Jua+mCbqwPoNZ16EFaDcmjA@mail.gmail.com> <eae2a0e5038b41c4af87edcb3d4cdc13@DM5PR11MB1692.namprd11.prod.outlook.com>
In-Reply-To: <eae2a0e5038b41c4af87edcb3d4cdc13@DM5PR11MB1692.namprd11.prod.outlook.com>
From: Tianyin Xu <tyxu@illinois.edu>
Date: Thu, 20 May 2021 03:22:13 -0500
X-Gmail-Original-Message-ID: <CAGMVDEFE8g5XKyQbB1xaK3ve58cENN2hZm3u=ktpGFgmBdQkeQ@mail.gmail.com>
Message-ID: <CAGMVDEFE8g5XKyQbB1xaK3ve58cENN2hZm3u=ktpGFgmBdQkeQ@mail.gmail.com>
Subject: Re: [RFC PATCH bpf-next seccomp 00/12] eBPF seccomp filters
To: Sargun Dhillon <sargun@sargun.me>
Cc: Andy Lutomirski <luto@kernel.org>, YiFei Zhu <zhuyifei1999@gmail.com>,
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
        Kees Cook <keescook@chromium.org>,
        Tobin Feldman-Fitzthum <tobin@ibm.com>,
        Tom Hromatka <tom.hromatka@oracle.com>, Will Drewry <wad@chromium.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Originating-IP: [209.85.219.170]
X-ClientProxiedBy: BN6PR14CA0015.namprd14.prod.outlook.com
 (2603:10b6:404:79::25) To DM5PR11MB1692.namprd11.prod.outlook.com
 (2603:10b6:3:d::23)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
X-MS-Exchange-MessageSentRepresentingType: 1
Received: from mail-yb1-f170.google.com (209.85.219.170) by BN6PR14CA0015.namprd14.prod.outlook.com (2603:10b6:404:79::25) with Microsoft SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.4150.23 via Frontend Transport; Thu, 20 May 2021 08:22:26 +0000
Received: by mail-yb1-f170.google.com with SMTP id w1so10360745ybt.1        for <containers@lists.linux.dev>; Thu, 20 May 2021 01:22:26 -0700 (PDT)
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id: b09e2bb1-b38e-4d0e-3229-08d91b6866cc
X-MS-TrafficTypeDiagnostic: DM5PR11MB0028:
X-Microsoft-Antispam-PRVS: 
	<DM5PR11MB0028F02F6F72CB7DED5370E4BB2A9@DM5PR11MB0028.namprd11.prod.outlook.com>
X-MS-Oob-TLC-OOBClassifiers: OLM:10000;
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam: BCL:0;
X-Microsoft-Antispam-Message-Info: 
	HpDKp2z1+tk0kqxYzI05X/YFG9ELS9WsYSehFIFa2AYkjAd4Hz3Wu5TGh48CYdc3zwpvifFGBt3hZXuytNx+3vAtbb6Y7cGlCfwLVcE7hRmruWN8WqIVAp4Uxaoewv7MjQ7DrNpBQeevzdcMz4uPx1C25D91k7PXkYK4IDaAIoKsBNWCekS9SNpl/kZVsLovhcotHZEHCSUh7KosIWW9DMZuCLfiVEqykwteXZGN8coNHLvB8ogz6VoLBReftaPgNfkyILzyLdE6Uel5q+r9wkJ0lGmIpGhM9Pmb7GWjd7HbUmh+s3Im29nuQDoo60cHmadCfHRPKi81cEF3G29dECBprYC67z0ZTgUl2B42Y+uZOU8eTiRGsvOSDCtF6N9KG7S9o4SX1OKnZBLnfaZes6qxuPCuT8CatBW5a5IQtd1vdo+iAaGLrXqT0qPdLvLA0TCQT4u+rtd/F3pEqHoQqeG/r2LQ8vMs02a57GvmvBcs/2X+VyUAIzFdBnQMa3OzVGDmjFg3JI/UGt4MeHy1ed1arHmcAg7aMrreslQM65qQwNYyqFsmE+nCAdikgKmzuRDw4T7cIDE2NZSTP8WniplGDjX2pE7LtG2Zn590xBYU/cwnaYF9Mgzx29zamF7qJc1aiOafnS+yzvQOw6qp0yhrBgDvAP2eugimKsaPMgTiKeTtslPCVgVxpcBNUtjABg4RvlGSFYyAFWb9C1oAnVRYPhdJJMILGhKM4fm7xpA=
X-Forefront-Antispam-Report: 
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:DM5PR11MB1692.namprd11.prod.outlook.com;PTR:;CAT:NONE;SFS:(136003)(366004)(39850400004)(346002)(396003)(376002)(5660300002)(66476007)(42186006)(186003)(316002)(786003)(75432002)(54906003)(26005)(38350700002)(38100700002)(66946007)(4326008)(8936002)(86362001)(6666004)(478600001)(83380400001)(966005)(2906002)(9686003)(52116002)(8676002)(55236004)(66556008)(6862004)(55446002)(53546011)(107886003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData: 
	=?utf-8?B?czZzNVB2NjNjNFZtbDFoN3lmNnRaUnRrTmtOb0VCNElXakRxcVE1dEw5TjB2?=
 =?utf-8?B?V2g4SHo2MlIvOFY5L3Z0MkRkZ3J0aS9XdWhLSXNZZ1Y1K0VZK0JaUFVjZEd0?=
 =?utf-8?B?WVRtbm9hdThGajY3QktKNXhkZzFTZCtBbEM0d3U0TkdHSEtmS08xQnJLVEdI?=
 =?utf-8?B?QUhnVTVDRGVXejlaYkRtYytwdld1WmZCMmVINkdvbnBWTnpZdUh0S0JXK3g5?=
 =?utf-8?B?UDgxVjhjbTJPeHBkTi84NlM4Y05CUjZGUTFZS0Y5QWI2RnhBVktQbHgza2xp?=
 =?utf-8?B?dmNaY0ladWZBTS93aTgzcUtMcjdIOVJEeHVFUDZ3ZTB6S3hUQ2F3ODBDaGVl?=
 =?utf-8?B?aGY2eEd0cFlaYm52U3NGaHNLNGkzeXlMVnRXa1g4azlQejRCcGhQUDl0TG81?=
 =?utf-8?B?bUlTZ0xGRXI3bUltMTFDTkVaWXI5dy9HNkxuQ3pIMFI0YXpNNXN2VEIxRW5E?=
 =?utf-8?B?VHNNcC9KMDBWY21zV1QrUnBoS0YxdTR4UkhVeXZJUjdDNUNWNS9Gc0NwU2do?=
 =?utf-8?B?a2ZHSXI2OC9keThuemJQNE1iUDBZc1pIWU40VU84d1hCbTJCeFBaYTBvSndG?=
 =?utf-8?B?bm5TYTRqWjM4eWMrYmpXN09OYXpEbCt1Mkx6Z3lUaS93cVZOUzA5TjMwRUJY?=
 =?utf-8?B?VjJLZmY2ZDgzWlduNW5HbldKZStoVFN0eGhkVFJhMkxvQU1tak9hTUNFenB6?=
 =?utf-8?B?OWE0UUhudlRpMTVaTTFJYnV1Mko5ZXV6VHY1WXc1MFpFZUlTcGhTaStGWUVN?=
 =?utf-8?B?d29OeWJUcWJ2emovNmdsbTZhU2RNV1daNkVjaU9JS1oyNlNENlBvbVNvcWhE?=
 =?utf-8?B?ZTZRT2hwMGJhUWdlckZydFQrOXREYkVSRys1YjZrTkVZaUYzTnpIMDJwcG0r?=
 =?utf-8?B?dzZSS2xGRStva1Ztc2pqbmpmUURLSkxZdDlvSnBKSm9WNGZVaWUraytpN1JG?=
 =?utf-8?B?eHAwVDBFVTMyOStCeUFRVlI2NXBLL3RRU2VwNnJhZHYyQVJ0MmloWm5CYUkx?=
 =?utf-8?B?YlVGanJBS3BmYlkvYUxjWjR3bGg5eWNsYWwrV2p6cG1ZWXh2dUVxRW0rUEVJ?=
 =?utf-8?B?YXFQZE5udkxrU3J0d3JZVEJrbGV6VUx0U05YZzE1K2lqQ0RzcC8vWTdzSVYw?=
 =?utf-8?B?SHJNR0FMdFV3M2wwMkliTWJlYWxGZGIxOGhKNTZHd0RxTTBVY2Mwdm9RRXlR?=
 =?utf-8?B?UHpPTUNOV2duam80c1JIdDRXdnlxempFdlE1bXBXWWk0WDVMY1duVzMwaHV1?=
 =?utf-8?B?cElQU1JJTnJhckkzVGFSZ21lMVlLWm12YTZFNkswcW5uSmdsUUNyQXJlK2ZU?=
 =?utf-8?B?WmpNcjlDNngyaHZZY0ZiUU5TT25hTFVJakFJaElPcjlFZ04wZUZRK3N1eUlj?=
 =?utf-8?B?dTk2U0ovd2YvS3VyK042bEdMRHZEWjgybWxsTVI1dlcvQWxMbHhLVlFTNWxa?=
 =?utf-8?B?WnZOM0t5SDlwRVJXODVzKy82ZXRzMmdKL0V0UXd1SnF1RXdvWkZFL1RwRTlP?=
 =?utf-8?B?UGtBaEhvNGlGT3lEZjdQWXp0T0M2UXB4SlNPN0NJdTlHQ3Juc3lLMldiUUp6?=
 =?utf-8?B?KzBVenBDdGhkWGNrREJxMVZmNE5nY2dsUDJrVjZaTmY2WnFCaW4rUHpZcEUz?=
 =?utf-8?B?bFZ0dUNGRjJqcUpJUFNZSVRpUmg4U09aRnhJd0pVdG5rcldIeG0rVmRYVnpi?=
 =?utf-8?B?U3BudCt1NXdqSEpoaDZlbkJsWHlCN1J0bzB0aGdkeUpya2srRXp0YWNMSTVF?=
 =?utf-8?Q?MPTfyF6Wc3prYxzW6qRHClNnmA74mrJRIzloVXU?=
X-OriginatorOrg: illinois.edu
X-MS-Exchange-CrossTenant-Network-Message-Id: b09e2bb1-b38e-4d0e-3229-08d91b6866cc
X-MS-Exchange-CrossTenant-AuthSource: DM5PR11MB1692.namprd11.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 20 May 2021 08:22:26.7271
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 44467e6f-462c-4ea2-823f-7800de5434e3
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: ifNHYK5X1W7tuZy8uDzAtEMHaivl+djPc4a+IzHhLxLorJZJLut05Lk+vkbHW52xy44fS97bUVs2WUEfU9AXSA==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM5PR11MB0028
X-Proofpoint-ORIG-GUID: KDvt9R8IEMA1qgTdCX4i5qT7pM00F6Rh
X-Proofpoint-GUID: KDvt9R8IEMA1qgTdCX4i5qT7pM00F6Rh
X-Spam-Details: rule=cautious_plus_nq_notspam policy=cautious_plus_nq score=0 mlxscore=0
 phishscore=0 clxscore=1015 lowpriorityscore=0 malwarescore=0
 impostorscore=0 priorityscore=1501 bulkscore=0 suspectscore=0 adultscore=0
 spamscore=0 mlxlogscore=999 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.12.0-2104190000 definitions=main-2105200063
X-Spam-Score: 0
X-Spam-OrigSender: tyxu@illinois.edu
X-Spam-Bar: 

On Mon, May 17, 2021 at 12:08 PM Sargun Dhillon <sargun@sargun.me> wrote:
>
> On Sun, May 16, 2021 at 1:39 AM Tianyin Xu <tyxu@illinois.edu> wrote:
> >
> > On Sat, May 15, 2021 at 10:49 AM Andy Lutomirski <luto@kernel.org> wrot=
e:
> > >
> > > On 5/10/21 10:21 PM, YiFei Zhu wrote:
> > > > On Mon, May 10, 2021 at 12:47 PM Andy Lutomirski <luto@kernel.org> =
wrote:
> > > >> On Mon, May 10, 2021 at 10:22 AM YiFei Zhu <zhuyifei1999@gmail.com=
> wrote:
> > > >>>
> > > >>> From: YiFei Zhu <yifeifz2@illinois.edu>
> > > >>>
> > > >>> Based on: https://urldefense.com/v3/__https://lists.linux-foundat=
ion.org/pipermail/containers/2018-February/038571.html__;!!DZ3fjg!thbAoRgmC=
eWjlv0qPDndNZW1j6Y2Kl_huVyUffr4wVbISf-aUiULaWHwkKJrNJyo$
> > > >>>
> > > >>> This patchset enables seccomp filters to be written in eBPF.
> > > >>> Supporting eBPF filters has been proposed a few times in the past=
.
> > > >>> The main concerns were (1) use cases and (2) security. We have
> > > >>> identified many use cases that can benefit from advanced eBPF
> > > >>> filters, such as:
> > > >>
> > > >> I haven't reviewed this carefully, but I think we need to distingu=
ish
> > > >> a few things:
> > > >>
> > > >> 1. Using the eBPF *language*.
> > > >>
> > > >> 2. Allowing the use of stateful / non-pure eBPF features.
> > > >>
> > > >> 3. Allowing the eBPF programs to read the target process' memory.
> > > >>
> > > >> I'm generally in favor of (1).  I'm not at all sure about (2), and=
 I'm
> > > >> even less convinced by (3).
> > > >>
> > > >>>
> > > >>>   * exec-only-once filter / apply filter after exec
> > > >>
> > > >> This is (2).  I'm not sure it's a good idea.
> > > >
> > > > The basic idea is that for a container runtime it may wait to execu=
te
> > > > a program in a container without that program being able to execve
> > > > another program, stopping any attack that involves loading another
> > > > binary. The container runtime can block any syscall but execve in t=
he
> > > > exec-ed process by using only cBPF.
> > > >
> > > > The use case is suggested by Andrea Arcangeli and Giuseppe Scrivano=
.
> > > > @Andrea and @Giuseppe, could you clarify more in case I missed
> > > > something?
> > >
> > > We've discussed having a notifier-using filter be able to replace its
> > > filter.  This would allow this and other use cases without any
> > > additional eBPF or cBPF code.
> > >
> >
> > A notifier is not always a solution (even ignoring its perf overhead).
> >
> > One problem, pointed out by Andrea Arcangeli, is that notifiers need
> > userspace daemons. So, it can hardly be used by daemonless container
> > engines like Podman.
> >
> > And, /* sorry for repeating.. */ the performance overhead of notifiers
> > is not close to ebpf, which prevents use cases that require native
> > performance.
>
> While I agree with you that this is the case right now, there's no reason=
 it
> has to be the case. There's a variety of mechanisms that can be employed
> to significantly speed up the performance of the notifier. For example, r=
ight
> now the notifier is behind one large per-filter lock. That could be remov=
ed
> allowing for better concurrency. There are a large number of mechanisms
> that scale O(n) with the outstanding notifications -- again, something
> that could be improved.

Thanks for the pointer! But, I don=E2=80=99t think this can fundamentally
eliminate the performance gap between the notifiers and the ebpf
filters. IMHO, the additional context switches of user notifiers make
the difference.

>
> The other big improvement that could be made is being able to use somethi=
ng
> like io_uring with the notifier interface, but it would require a
> fairly significant
> user API change -- and a move away from ioctl. I'm not sure if people are
> excited about that idea at the moment.
>

Apologize that I don=E2=80=99t fully understand your proposal. My
understanding about io_uring is that it allows you to amortize the
cost of context switch but not eliminate it, unless you are willing to
dedicate a core for it. I still believe that, even with io_uring, user
notifiers are going to be much slower than eBPF filters.

Btw, our patches are based on your patch set (thank you!). Are you
using user notifiers (with your improved version?) these days? It will
be nice to hear your opinions on ebpf filters.

> >
> >
> > > >> eBPF doesn't really have a privilege model yet.  There was a long =
and
> > > >> disappointing thread about this awhile back.
> > > >
> > > > The idea is that =E2=80=9Cseccomp-eBPF does not make life easier fo=
r an
> > > > adversary=E2=80=9D. Any attack an adversary could potentially utili=
ze
> > > > seccomp-eBPF, they can do the same with other eBPF features, i.e. i=
t
> > > > would be an issue with eBPF in general rather than specifically
> > > > seccomp=E2=80=99s use of eBPF.
> > > >
> > > > Here it is referring to the helpers goes to the base
> > > > bpf_base_func_proto if the caller is unprivileged (!bpf_capable ||
> > > > !perfmon_capable). In this case, if the adversary would utilize eBP=
F
> > > > helpers to perform an attack, they could do it via another
> > > > unprivileged prog type.
> > > >
> > > > That said, there are a few additional helpers this patchset is addi=
ng:
> > > > * get_current_uid_gid
> > > > * get_current_pid_tgid
> > > >   These two provide public information (are namespaces a concern?).=
 I
> > > > have no idea what kind of exploit it could add unless the adversary
> > > > somehow side-channels the task_struct? But in that case, how is the
> > > > reading of task_struct different from how the rest of the kernel is
> > > > reading task_struct?
> > >
> > > Yes, namespaces are a concern.  This idea got mostly shot down for kd=
bus
> > > (what ever happened to that?), and it likely has the same problems fo=
r
> > > seccomp.
> > >
> > > >>
> > > >> What is this for?
> > > >
> > > > Memory reading opens up lots of use cases. For example, logging wha=
t
> > > > files are being opened without imposing too much performance penalt=
y
> > > > from strace. Or as an accelerator for user notify emulation, where
> > > > syscalls can be rejected on a fast path if we know the memory conte=
nts
> > > > does not satisfy certain conditions that user notify will check.
> > > >
> > >
> > > This has all kinds of race conditions.
> > >
> > >
> > > I hate to be a party pooper, but this patchset is going to very high =
bar
> > > to acceptance.  Right now, seccomp has a couple of excellent properti=
es:
> > >
> > > First, while it has limited expressiveness, it is simple enough that =
the
> > > implementation can be easily understood and the scope for
> > > vulnerabilities that fall through the cracks of the seccomp sandbox
> > > model is low.  Compare this to Windows' low-integrity/high-integrity
> > > sandbox system: there is a never ending string of sandbox escapes due=
 to
> > > token misuse, unexpected things at various integrity levels, etc.
> > > Seccomp doesn't have tokens or integrity levels, and these bugs don't
> > > happen.
> > >
> > > Second, seccomp works, almost unchanged, in a completely unprivileged
> > > context.  The last time making eBPF work sensibly in a less- or
> > > -unprivileged context, the maintainers mostly rejected the idea of
> > > developing/debugging a permission model for maps, cleaning up the bpf
> > > object id system, etc.  You are going to have a very hard time
> > > convincing the seccomp maintainers to let any of these mechanism
> > > interact with seccomp until the underlying permission model is in pla=
ce.
> > >
> > > --Andy
> >
> > Thanks for pointing out the tradeoff between expressiveness vs. simplic=
ity.
> >
> > Note that we are _not_ proposing to replace cbpf, but propose to also
> > support ebpf filters. There certainly are use cases where cbpf is
> > sufficient, but there are also important use cases ebpf could make
> > life much easier.
> >
> > Most importantly, we strongly believe that ebpf filters can be
> > supported without reducing security.
> >
> > No worries about =E2=80=9Cparty pooping=E2=80=9D and we appreciate the =
feedback. We=E2=80=99d
> > love to hear concerns and collect feedback so we can address them to
> > hit that very high bar.
> >
> >
> > ~t
> >
> > --
> > Tianyin Xu
> > University of Illinois at Urbana-Champaign
> > https://urldefense.com/v3/__https://tianyin.github.io/__;!!DZ3fjg!o4__O=
b32oapUDg9_f6hzksoFiX9517CJ5-w8qtG9i-WKFs_xWbGQfUHpLjHjCddw$
