Received: from mx0b-00007101.pphosted.com (mx0b-00007101.pphosted.com [148.163.139.28])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5A99170
	for <containers@lists.linux.dev>; Thu, 20 May 2021 22:49:38 +0000 (UTC)
Received: from pps.filterd (m0166258.ppops.net [127.0.0.1])
	by mx0b-00007101.pphosted.com (8.16.0.43/8.16.0.43) with SMTP id 14KMDJB3001715
	for <containers@lists.linux.dev>; Thu, 20 May 2021 22:21:32 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=illinois.edu; h=references :
 in-reply-to : from : date : message-id : subject : to : cc : content-type
 : content-transfer-encoding : mime-version; s=campusrelays;
 bh=RJKjpAD/kxSp6H26H48Crd+7Yf7A/NW3Y6hjKq96cNM=;
 b=bk3vYZIQPGPnQMuPfYQQwKsmN8EJRdGIL+NQxfzDhhPPRiqKVNjENMQurF8BKG5MGUUE
 DH+6tFINM0d5M9IUhqBeUpGcvuRKG+LdRxXtPZXII+oNClaXhtza2XiLf3ZpMvUYI6Yz
 wKONZQtuROhpIwRJt82MogtjMyp2ecBnrST9jufmU8Hj0v8E4e4GAECzhNdwgi2rRV+B
 0wkWDnnua9ID86KPM3tygIDRhDqsETS5UbaemTkNQzdPvB5xdqDwfQLkBGrv5R62zXw0
 xv434KymtYX23GI97ElxveJd3G8KZTdYsNHfw/t1Iv1CtDNrVYrrjSnenBoWiLnONP25 6g== 
Received: from nam11-co1-obe.outbound.protection.outlook.com (mail-co1nam11lp2174.outbound.protection.outlook.com [104.47.56.174])
	by mx0b-00007101.pphosted.com with ESMTP id 38mx5p2qa0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT)
	for <containers@lists.linux.dev>; Thu, 20 May 2021 22:21:32 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=FLUwgBnRPAV5FxYKYOe9U3uddS7U/TCHQ8kGKBRm9JOLK+yfsLWi0fHXJswaMFOrGFJDYrc2UbRR+Ne1hFsxS9jeE6krjlfQd2rbfF/KZ+l9/1yNf7E6RpuEte8Is3h8+5cpfMga/cX9ZNp7x3NzRZGtznb+7nrmJVsiimJat4vyTphH1AqtoQGOTI0bJZXSdS7oC4A0o+bsK9HVCCiS69SHGuzwdEthfemKZp2c7cJir67TRJmwUbBH+00ZgzHOoq41kqh2GwstKKfLRgwGqCs/Cxh87Tr9nFIC4e+gjuhVq+qw6mnqChZJMpoek33KLERkh/vag9usfKGJanHcBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=RJKjpAD/kxSp6H26H48Crd+7Yf7A/NW3Y6hjKq96cNM=;
 b=d9/NJaorikWJxKL9qCNMZZMkjpofcROaK8/ZFPp1qeO0LV8V2G5Piu7wuX/6C+X4dCHkrS+S6SNJ7aOY3LQZUCVK3rxB5MOSuFAVdN5NGWKidcXxi+jWvwTZcwd1Pz7t0TbDceSTvr7FisSbfsU0+8r6rI9UPym0JsnCMrQZcbmLSCmL0AS/vArytFgF6CIrI6nteX9i5t1zhYFvj560ZI8fJMJDVOkznOcZYt12jCZfUbNwg3257S0p37jWXX8O9XAb8z9g79G9ludszW//JREviBK9JCXqEC7LKdF29N4iGFFKe6pW1JNATBanrpbBLNQQRIcofgz3mJdxdo0m3Q==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=illinois.edu; dmarc=pass action=none header.from=illinois.edu;
 dkim=pass header.d=illinois.edu; arc=none
Authentication-Results: lists.linux.dev; dkim=none (message not signed)
 header.d=none;lists.linux.dev; dmarc=none action=none
 header.from=illinois.edu;
Received: from DM5PR11MB1692.namprd11.prod.outlook.com (2603:10b6:3:d::23) by
 DM6PR11MB2859.namprd11.prod.outlook.com (2603:10b6:5:c9::14) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.4150.23; Thu, 20 May 2021 22:21:30 +0000
Received: from DM5PR11MB1692.namprd11.prod.outlook.com
 ([fe80::21bb:c117:6de2:2ac8]) by DM5PR11MB1692.namprd11.prod.outlook.com
 ([fe80::21bb:c117:6de2:2ac8%8]) with mapi id 15.20.4129.035; Thu, 20 May 2021
 22:21:30 +0000
X-Gm-Message-State: AOAM533EvT5Z+UrnSYteS2ldVhVfYdj3QaJSBc0G5gEQaxKeebPuBDqs
	UPS7ffWm4n67Un+7lMjX53oBSUycriB1bsHTbEo=
X-Google-Smtp-Source: ABdhPJyKZE9fzXRdAm+dG1fr7f8eFaCEyQNE05qg0anNFqDQ6LuCVlYx/95p8Cw3hJfw7d1l/Q/90J1ODZsosSyazMs=
X-Received: by 2002:a25:38ca:: with SMTP id f193mr10483471yba.422.1621548832414;
 Thu, 20 May 2021 15:13:52 -0700 (PDT)
References: <cover.1620499942.git.yifeifz2@illinois.edu> <CALCETrUQBonh5BC4eomTLpEOFHVcQSz9SPcfOqNFTf2TPht4-Q@mail.gmail.com>
 <CABqSeASYRXMwTQwLfm_Tapg45VUy9sPfV7BeeV8p7XJrDoLf+Q@mail.gmail.com>
 <fffbea8189794a8da539f6082af3de8e@DM5PR11MB1692.namprd11.prod.outlook.com>
 <CAGMVDEGzGB4+6gJPTw6Tdng5ur9Jua+mCbqwPoNZ16EFaDcmjA@mail.gmail.com>
 <108b4b9c2daa4123805d2b92cf51374b@DM5PR11MB1692.namprd11.prod.outlook.com>
 <CAGMVDEEkDeUBcJAswpBjcQNWk7QDcO8BZR=uvVfm-+qe714tYg@mail.gmail.com> <00fe481c572d486289bc88780f48e88f@DM5PR11MB1692.namprd11.prod.outlook.com>
In-Reply-To: <00fe481c572d486289bc88780f48e88f@DM5PR11MB1692.namprd11.prod.outlook.com>
From: Tianyin Xu <tyxu@illinois.edu>
Date: Thu, 20 May 2021 17:13:41 -0500
X-Gmail-Original-Message-ID: <CAGMVDEHGgSPnzgORUSfD4a11eVvSDHp7nWNzXmTKLuQqKVNuUw@mail.gmail.com>
Message-ID: <CAGMVDEHGgSPnzgORUSfD4a11eVvSDHp7nWNzXmTKLuQqKVNuUw@mail.gmail.com>
Subject: Re: [RFC PATCH bpf-next seccomp 00/12] eBPF seccomp filters
To: Christian Brauner <christian.brauner@ubuntu.com>
Cc: Tycho Andersen <tycho@tycho.pizza>, Andy Lutomirski <luto@kernel.org>,
        YiFei Zhu <zhuyifei1999@gmail.com>,
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
X-Originating-IP: [209.85.210.45]
X-ClientProxiedBy: SN7PR04CA0054.namprd04.prod.outlook.com
 (2603:10b6:806:120::29) To DM5PR11MB1692.namprd11.prod.outlook.com
 (2603:10b6:3:d::23)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
X-MS-Exchange-MessageSentRepresentingType: 1
Received: from mail-ot1-f45.google.com (209.85.210.45) by SN7PR04CA0054.namprd04.prod.outlook.com (2603:10b6:806:120::29) with Microsoft SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.4150.24 via Frontend Transport; Thu, 20 May 2021 22:21:29 +0000
Received: by mail-ot1-f45.google.com with SMTP id r26-20020a056830121ab02902a5ff1c9b81so16274150otp.11        for <containers@lists.linux.dev>; Thu, 20 May 2021 15:21:29 -0700 (PDT)
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id: 0fb964eb-45b9-404f-030c-08d91bdd9da8
X-MS-TrafficTypeDiagnostic: DM6PR11MB2859:
X-Microsoft-Antispam-PRVS: 
	<DM6PR11MB28597483C3C801C763F94E58BB2A9@DM6PR11MB2859.namprd11.prod.outlook.com>
X-MS-Oob-TLC-OOBClassifiers: OLM:8882;
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam: BCL:0;
X-Microsoft-Antispam-Message-Info: 
	dQu7+9KbmjuZBg+JxP0z8xrai5Jduw14xzZK8dOwkBfUFrtwHQA8OEU1nfC9fQrGenj3hjfgLLtqOEBiybEBKrDSiZieKMiu5iZfsFx89pLbbf9vhwVAUHUvh9KHRnuRgqVlSgpH+63iqZaqb8kBR9xbiTQ6FXqDLwxjfcr4zSzofaZKCn4tp+MHSdHVOOyLmnXShNrbOYAte3hwMF11ikEM/ZjZZDB+pHYvR/9yXtIsnsf8zI4LxxVO4ge5n2BSlYaUBEOrrAnYNbIqBx1M0P2/dyD7udyThFulnuDCh7A/DXJEtUM+Dl8bFfs7EOFaHE4nBSi5sn9v6e4z+9mg8ojpjoXprW02syyWtFR1SsAzcRb90t943BBBy2hy28xMbpChLmIrEh8gVDvIXoSRo371LSvjnwDOh1XClq7nv1Yaxf3WFfyqR5korB0DMFS8ENwEf7S6o1rxVKrmi+HPgUbhgmn+niF6z5dVMZVyu24l8IOKA5YStKuM2g96j2yt3dZsba8v1ox+FBibMQZvdgkfP6Y1JMY15tFjWegGjORqThy2hiepr9oQSLGyuMvynxkBqLgDRMYFPcgjtJlkBeP0SX6J0iYPHAjSm8BmnHeo1dJt40jK/4iUJEwVEq2oDx76RfUnW9KDsx93+ZbZPtNSIU5Zy+uIvugQlIIyD++oE1ZPCN8nG0W83yFPTVvd6BDttgxi1hegL2CVWbfZ6SYFJc1XXhHNfbO+fAP1slpPPgV8gBu7HON0rz+0lujtZoYV9F0e6zTQLSRPjy85xQ==
X-Forefront-Antispam-Report: 
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:DM5PR11MB1692.namprd11.prod.outlook.com;PTR:;CAT:NONE;SFS:(376002)(396003)(136003)(346002)(39860400002)(366004)(6862004)(107886003)(4326008)(66476007)(9686003)(478600001)(966005)(66946007)(5660300002)(75432002)(186003)(786003)(55446002)(2906002)(66556008)(42186006)(6666004)(38100700002)(86362001)(38350700002)(83380400001)(8676002)(54906003)(8936002)(52116002)(53546011)(316002)(26005);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData: 
	=?utf-8?B?MGNlblBGK1Y5T2JZYlhsSlY0eDllLzB3MVlBNjVZcnVyaWZOWDhxTnhTNXlB?=
 =?utf-8?B?V1drRzIrd0pvMjlkbXhhcG12UitnR1k1akxZSUtVS0twQkMyNWhpRXc5NlNn?=
 =?utf-8?B?QXJMNHh3K2hjZkczQnEzUFB2SzUyRFl0RDR4bXhPOGFKdE1DaXhFRitLSThC?=
 =?utf-8?B?VjhnR1RLMmFDRlVqVWs5UFVDM1hTcjNISFFZaUR2R0tFbHhWNFkzMmVBb3pr?=
 =?utf-8?B?OC8vSTJOTkU0ZHVLcXptSmhBTUJjZ0FEQ1VzUjVPVmhMSVNMRXA3ZjZnUXlT?=
 =?utf-8?B?aUxWVGN6MXBEYmF1UmxKMGo3djYzWHh6UzAzME5lUTExeWxPWjNXS0UwNi9Q?=
 =?utf-8?B?QmdNRkFkQzhnakJ5RGNnakVrdHk3TVdGWTJYR0xJNDdCdGMyRVlqcXlTOUJY?=
 =?utf-8?B?TXJPY0t2cFBmcDVxL0F5RGM4MnpiWElJaTkyTGoxUk9EbVF1cEhJUEt5Tlhm?=
 =?utf-8?B?NUJtR2pMSnpkWEtJcmxtdlNneU14KzFNMUYvRG9ZTGhCTlpuWUdrZ0p4MFVh?=
 =?utf-8?B?WW9FSVI2TjhPT2tPc1RSbjg5SU55Rmh1N0hzbUphWWI1SU9hRkxJNCtFWTBM?=
 =?utf-8?B?WnhSY0VUK2p1akpLS1h0dUZaSEpKeGRHTndaaWp0VlUvZXZhVGZ0ZjdSNzlj?=
 =?utf-8?B?bHJ5NStRd0RsKzh0NVFjNnV1a09kMXpiaEczRGlKTm9LTitoSk0zb0NQcVhP?=
 =?utf-8?B?YkdEZS9jdndYTjNwbWZmcllLVHUzc2tOLzBGckpOaGNGMUw5WDBIYXdjMWww?=
 =?utf-8?B?T1JNZmx0d1dLVFcxVUVRT0ZaUXZoZlV4OFJJazVDMXZPWXZ5eFdnUlNoQW00?=
 =?utf-8?B?R3FvWnFTTmNIR3RUbm82ZTJyZkUza3Y0RzlteGtmekxRWTRyTmcrSXFoQ1F0?=
 =?utf-8?B?eWJxRElxMzBlMGFPYkNTNTFHRWwyYjh4Yk03Z0dxS25wWjlOaFJiOE9aM1d4?=
 =?utf-8?B?eVBhdEZqb0hrbTZNTHBOaVh0MWlkaXBIbmNQVFZZOWU4QlVmSzFYQUI2Sy9J?=
 =?utf-8?B?M1pMQ21kdlpmWUJCTXVuUUkvUVJaT0hnVTlmeDdJTE5VNmtKWnNpbFhqKzM0?=
 =?utf-8?B?SEJ4NGlRc0ZvMGVjNytiT2EwdTVuS0xPVWo0bzR2L3krenFYSERXRWRWNmgx?=
 =?utf-8?B?Vnk1c05nQzVSZ3NaVVRIMVFQU2s1YkphNzlHbkF2S08rTFU5VlVSeVlxT3N3?=
 =?utf-8?B?SGVRa3NKM2M5dGF5dkVkTGlwbStOVG1OeWtRYVRxNzh1RnlQRTMyazM1cFA1?=
 =?utf-8?B?K2NoMFVYcXZXZjVXSldnSDhveUw5akN1MDd6aFVPVWZmcXkxcVplNVZ0QWRG?=
 =?utf-8?B?Mkh1azg3c0toRGVjRG1PS1hxdzA1RE5VZFVDa0Rvc0JieDBpNStzdU9WKzVY?=
 =?utf-8?B?OEhrWWhvSG8vNTFpQUdpTk9qaHF2eCtVdVErZFhDRm5pdVBJKzRCYmttVFMz?=
 =?utf-8?B?bTFkbXE1R2VMdC9peU9QZ21pcTJoTFhlTXNOZ21rZ2NVYVhIby9NK0JwRWRh?=
 =?utf-8?B?V08xb1B5UEJoalB5d1dncDlSSG84MUZIVHd3RmlGZlUwK3p5Y3JXNDYvLzVv?=
 =?utf-8?B?SGxIT2l6RFZOSHNPakFJQlQ1a1R3cnJDMU5Ka2JwYzRkek5UZUoyUFdBMzI1?=
 =?utf-8?B?Q2ptU2Q5UWZUUVplYWs3TTkxRmVtYVdjcWlocVJaM1ZrZExkWVloUGJKNitq?=
 =?utf-8?B?cDcrbUtzQ2dBdExuRXc3QmpZTVZNVWRVQlBML3BYQzNZTmpKYUtaK2g1TklU?=
 =?utf-8?Q?/JlW3cWGo84WZ6aMGCkFFdKmhFrRwxJfd1n5eC3?=
X-OriginatorOrg: illinois.edu
X-MS-Exchange-CrossTenant-Network-Message-Id: 0fb964eb-45b9-404f-030c-08d91bdd9da8
X-MS-Exchange-CrossTenant-AuthSource: DM5PR11MB1692.namprd11.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 20 May 2021 22:21:29.9110
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 44467e6f-462c-4ea2-823f-7800de5434e3
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: NQWRKelp1E9F6mv1/3JIeFJBuOSwLKm8lVwGwYI0BXYzn6YKTUCk0sdLiQyBeVcBbfIcKRQuTZxjFofZjUY7ug==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR11MB2859
X-Proofpoint-GUID: WQZC-8ha3If4OSNMcRxgS45Ym30JogdL
X-Proofpoint-ORIG-GUID: WQZC-8ha3If4OSNMcRxgS45Ym30JogdL
X-Spam-Details: rule=cautious_plus_nq_notspam policy=cautious_plus_nq score=0 adultscore=0
 spamscore=0 suspectscore=0 phishscore=0 priorityscore=1501 clxscore=1015
 mlxlogscore=999 impostorscore=0 bulkscore=0 lowpriorityscore=0
 malwarescore=0 mlxscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.12.0-2104190000 definitions=main-2105200140
X-Spam-Score: 0
X-Spam-OrigSender: tyxu@illinois.edu
X-Spam-Bar: 

On Thu, May 20, 2021 at 3:56 AM Christian Brauner
<christian.brauner@ubuntu.com> wrote:
>
> On Thu, May 20, 2021 at 03:16:10AM -0500, Tianyin Xu wrote:
> > On Mon, May 17, 2021 at 10:40 AM Tycho Andersen <tycho@tycho.pizza> wro=
te:
> > >
> > > On Sun, May 16, 2021 at 03:38:00AM -0500, Tianyin Xu wrote:
> > > > On Sat, May 15, 2021 at 10:49 AM Andy Lutomirski <luto@kernel.org> =
wrote:
> > > > >
> > > > > On 5/10/21 10:21 PM, YiFei Zhu wrote:
> > > > > > On Mon, May 10, 2021 at 12:47 PM Andy Lutomirski <luto@kernel.o=
rg> wrote:
> > > > > >> On Mon, May 10, 2021 at 10:22 AM YiFei Zhu <zhuyifei1999@gmail=
.com> wrote:
> > > > > >>>
> > > > > >>> From: YiFei Zhu <yifeifz2@illinois.edu>
> > > > > >>>
> > > > > >>> Based on: https://urldefense.com/v3/__https://lists.linux-fou=
ndation.org/pipermail/containers/2018-February/038571.html__;!!DZ3fjg!thbAo=
RgmCeWjlv0qPDndNZW1j6Y2Kl_huVyUffr4wVbISf-aUiULaWHwkKJrNJyo$
> > > > > >>>
> > > > > >>> This patchset enables seccomp filters to be written in eBPF.
> > > > > >>> Supporting eBPF filters has been proposed a few times in the =
past.
> > > > > >>> The main concerns were (1) use cases and (2) security. We hav=
e
> > > > > >>> identified many use cases that can benefit from advanced eBPF
> > > > > >>> filters, such as:
> > > > > >>
> > > > > >> I haven't reviewed this carefully, but I think we need to dist=
inguish
> > > > > >> a few things:
> > > > > >>
> > > > > >> 1. Using the eBPF *language*.
> > > > > >>
> > > > > >> 2. Allowing the use of stateful / non-pure eBPF features.
> > > > > >>
> > > > > >> 3. Allowing the eBPF programs to read the target process' memo=
ry.
> > > > > >>
> > > > > >> I'm generally in favor of (1).  I'm not at all sure about (2),=
 and I'm
> > > > > >> even less convinced by (3).
> > > > > >>
> > > > > >>>
> > > > > >>>   * exec-only-once filter / apply filter after exec
> > > > > >>
> > > > > >> This is (2).  I'm not sure it's a good idea.
> > > > > >
> > > > > > The basic idea is that for a container runtime it may wait to e=
xecute
> > > > > > a program in a container without that program being able to exe=
cve
> > > > > > another program, stopping any attack that involves loading anot=
her
> > > > > > binary. The container runtime can block any syscall but execve =
in the
> > > > > > exec-ed process by using only cBPF.
> > > > > >
> > > > > > The use case is suggested by Andrea Arcangeli and Giuseppe Scri=
vano.
> > > > > > @Andrea and @Giuseppe, could you clarify more in case I missed
> > > > > > something?
> > > > >
> > > > > We've discussed having a notifier-using filter be able to replace=
 its
> > > > > filter.  This would allow this and other use cases without any
> > > > > additional eBPF or cBPF code.
> > > > >
> > > >
> > > > A notifier is not always a solution (even ignoring its perf overhea=
d).
> > > >
> > > > One problem, pointed out by Andrea Arcangeli, is that notifiers nee=
d
> > > > userspace daemons. So, it can hardly be used by daemonless containe=
r
> > > > engines like Podman.
> > >
> > > I'm not sure I buy this argument. Podman already has a conmon instanc=
e
> > > for each container, this could be a child of that conmon process, or
> > > live inside conmon itself.
> > >
> > > Tycho
> >
> > I checked with Andrea Arcangeli and Giuseppe Scrivano who are working o=
n Podman.
> >
> > You are right that Podman is not completely daemonless. However, =E2=80=
=9Cthe
> > fact it's no entirely daemonless doesn't imply it's a good idea to
> > make it worse and to add complexity to the background conmon daemon or
> > to add more daemons.=E2=80=9D
> >
> > TL;DR. User notifiers are surely more flexible, but are also more
> > expensive and complex to implement, compared with ebpf filters. /*
> > I=E2=80=99ll reply to Sargun=E2=80=99s performance argument in a separa=
te email */
> >
> > I'm sure you know Podman well, but let me still move some jade from
> > Andrea and Giuseppe (all credits on podmon/crun are theirs) to
> > elaborate the point, for folks cced on the list who are not very
> > familiar with Podman.
> >
> > Basically, the current order goes as follows:
> >
> >          podman -> conmon -> crun -> container_binary
> >                                \
> >                                 - seccomp done at crun level, not conmo=
n
> >
> > At runtime, what's left is:
> >
> >          conmon -> container_binary  /* podman disappears; crun disappe=
ars */
> >
> > So, to go through and use seccomp notify to block `exec`, we can
> > either start the container_binary with a seccomp agent wrapper, or
> > bloat the common binary (as pointed out by Tycho).
> >
> > If we go with the first approach, we will have:
> >
> >          podman -> conmon -> crun -> seccomp_agent -> container_binary
> >
> > So, at runtime we'd be left with one more daemon:
> >
> >         conmon -> seccomp_agent -> container_binary
>
> That seems like a strawman. I don't see why this has to be out of
> process or a separate daemon. Conmon uses a regular event loop. Adding
> support for processing notifier syscall notifications is
> straightforward. Moving it to a plugin as you mentioned below is a
> design decision not a necessity.
>
> >
> > Apparently, nobody likes one more daemon. So, the proposal from
>
> I'm not sure such a blanket statements about an indeterminate group of
> people's alleged preferences constitutes a technical argument wny we
> need ebpf in seccomp.
>
> > Giuseppe was/is to use user notifiers as plugins (.so) loaded by
> > conmon:
> > https://urldefense.com/v3/__https://github.com/containers/conmon/pull/1=
90__;!!DZ3fjg!qFZ7PXfFe7eI1Bye9J8zsGOxTQQlfL-pBh0D7Arn1YZKevtEpA9uxKqMTP9kA=
5RJ$
> > https://urldefense.com/v3/__https://github.com/containers/crun/pull/438=
__;!!DZ3fjg!qFZ7PXfFe7eI1Bye9J8zsGOxTQQlfL-pBh0D7Arn1YZKevtEpA9uxKqMTJrKzhU=
D$
> >
> > Now, with the ebpf filter support, one can implement the same thing
> > using an embarrassingly simple ebpf filter and, thanks to Giuseppe,
> > this is well supported by crun.
>
> So I think this is trying to jump the gun by saying "Look, the result
> might be simpler.". That may even be the case - though I'm not yet
> convinced - but Andy's point stands that this brings a slew of issues on
> the table that need clear answers. Bringing stateful ebpf features into
> seccomp is a pretty big step and especially around the
> privilege/security model it looks pretty handwavy right now.
>
> Christian

If an alleged gunshot was the impression I left, I apologize.
Seriously, I have great respect for user notifiers -- my intention was
never to disregard it, or to argue that ebpf filters are always
strictly better.

On the other hand, I do believe (and tried to show) ebpf filters have
their own technical advantages, and can be very useful and efficient
in many use cases. Let me know if you don=E2=80=99t buy this.

It=E2=80=99s kinda weird that we are arguing against ebpf filters with user
notifiers (it=E2=80=99s analogous to "we don=E2=80=99t need Seccomp coz we =
have
ptrace=E2=80=A6")

More importantly, I do really want to provide clear answers to the
privilege/security model, but I don=E2=80=99t precisely know what exactly
you=E2=80=99re referring to as "privilege/security model". Are you referrin=
g
to the one-way transition model of Seccomp (which may no longer be
held in stateful filters), or something different? It will be great if
you can clarify so we can answer explicitly.

Thanks!
