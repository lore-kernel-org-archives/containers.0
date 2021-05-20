Received: from mx0a-00007101.pphosted.com (mx0a-00007101.pphosted.com [148.163.135.28])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 72D4B71
	for <containers@lists.linux.dev>; Thu, 20 May 2021 08:21:54 +0000 (UTC)
Received: from pps.filterd (m0166255.ppops.net [127.0.0.1])
	by mx0a-00007101.pphosted.com (8.16.0.43/8.16.0.43) with SMTP id 14K8CoKh006407
	for <containers@lists.linux.dev>; Thu, 20 May 2021 08:21:48 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=illinois.edu; h=references :
 in-reply-to : from : date : message-id : subject : to : cc : content-type
 : content-transfer-encoding : mime-version; s=campusrelays;
 bh=P75OHpbGg4gLc+T2xmZ5Jksku6+PqUCNPll9iVaZ4uo=;
 b=PsxnFP1i9vMN9c1YTFZ8p8C2B6GnEzqELTEphlSnAE2oZiDvps2IFOImIQ5mGZWnS3yV
 sp0CZIaW2SXL5l2TZJUtuxFhceMuQP+a6a/snUb1j852zLEpRgcRbSPSh0LhBbw4hM1Y
 KO+vjmQTNwTEbRy/c8+Gx8hWFlD5ohCZmTE1FhP5IakEg3BwXkMCsXD+gRvm/YqRb41N
 NCe8paPRh7IlJV2obCjF08g9OYkwfZOGwQL5XSx822md4+PyUFvHHNK0767RtrEEfyES
 08NNg8wMYjedqDW8UrjjameSYuYfDtzlV2rn9jLpPS5etMwzFJ3YXLrBxc869i1hj2af nA== 
Received: from nam10-mw2-obe.outbound.protection.outlook.com (mail-mw2nam10lp2109.outbound.protection.outlook.com [104.47.55.109])
	by mx0a-00007101.pphosted.com with ESMTP id 38msqbbskh-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT)
	for <containers@lists.linux.dev>; Thu, 20 May 2021 08:21:48 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=Fc45QEPERKEOuXuSlcgkHc9h1RrvVUzm31+eaTegodPhJ5JnKaNUFEJPZBQkQ9kk8L73jtuF6VH318B8BTg/TU7k4eNBxHGVpUuuYo4cisLLgwGrtL6C3rmvejYAsAxsmVPLAHl9k4pkjG4JwctaIOKP+LWqhSh5P7G4BIFvGYa1G9mEcOAZeNvWdN9W9vxirWyPTqozR9kVk53QMEHBgudBu7YEz5KIbh6ymbv7vVvZDry6aVQvlPiA94Ql6v63EiDX2ukUZEWjAIuJXhQEmXdrg/dDuk84RQlvf/HcdElO44aAkuYSisPP/C6ozQY27ed04HfuNaEjU/pMGcrOtQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=P75OHpbGg4gLc+T2xmZ5Jksku6+PqUCNPll9iVaZ4uo=;
 b=Sk30JI9U7V0wkPk7fOJ9bmiF6jeIFdsxR5g9HIcNT4QePxLxYV5UygRkiqm92MEYlUJb5E3LssL105uBexxt5Bfvd1AZX2uHGD2dcPGCnnyBXBRgSmq94yhL2DANbF6DJve+oUd5O1M3SuD+C3E77s5EBTPaR156CxdYdxfcTFVwo0hVxxXQsSWcc5e3YN/hKtIlQCOu3i7Lzt/6nmMb5XxnwdJlgqFEQIuwS80M+UShCcnRvjE1sTlCN8LJ32CT9hC9wqvZ2mzT7Fday71Xv4Gz+mDIpOu+/b9ZoCPWAuJnsTUe8FYUVYxmPR0Tst0Ynlqeiob1Uf8ji6YzRK4ZVw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=illinois.edu; dmarc=pass action=none header.from=illinois.edu;
 dkim=pass header.d=illinois.edu; arc=none
Authentication-Results: lists.linux.dev; dkim=none (message not signed)
 header.d=none;lists.linux.dev; dmarc=none action=none
 header.from=illinois.edu;
Received: from DM5PR11MB1692.namprd11.prod.outlook.com (2603:10b6:3:d::23) by
 DM5PR11MB0028.namprd11.prod.outlook.com (2603:10b6:4:67::30) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.4129.29; Thu, 20 May 2021 08:21:46 +0000
Received: from DM5PR11MB1692.namprd11.prod.outlook.com
 ([fe80::21bb:c117:6de2:2ac8]) by DM5PR11MB1692.namprd11.prod.outlook.com
 ([fe80::21bb:c117:6de2:2ac8%8]) with mapi id 15.20.4129.034; Thu, 20 May 2021
 08:21:46 +0000
X-Gm-Message-State: AOAM530tNRTuP9Y7E7YBmplzDgoOLJOwwGrdu/tESiWUmGyEL2078Wyf
	vCosmUjDIQOmx2yw8csJ1KkFFC96C1zHBHGk5WQ=
X-Google-Smtp-Source: ABdhPJxd/76h6hYsz+j3RRKhpoZcDWb6NzUjNdnETEnB99o2ViLI/AGQQmtBUeDNAB9TlGnr5E4zvP29xquv/Z6leak=
X-Received: by 2002:a25:38ca:: with SMTP id f193mr5491303yba.422.1621498581249;
 Thu, 20 May 2021 01:16:21 -0700 (PDT)
References: <cover.1620499942.git.yifeifz2@illinois.edu> <CALCETrUQBonh5BC4eomTLpEOFHVcQSz9SPcfOqNFTf2TPht4-Q@mail.gmail.com>
 <CABqSeASYRXMwTQwLfm_Tapg45VUy9sPfV7BeeV8p7XJrDoLf+Q@mail.gmail.com>
 <fffbea8189794a8da539f6082af3de8e@DM5PR11MB1692.namprd11.prod.outlook.com>
 <CAGMVDEGzGB4+6gJPTw6Tdng5ur9Jua+mCbqwPoNZ16EFaDcmjA@mail.gmail.com> <108b4b9c2daa4123805d2b92cf51374b@DM5PR11MB1692.namprd11.prod.outlook.com>
In-Reply-To: <108b4b9c2daa4123805d2b92cf51374b@DM5PR11MB1692.namprd11.prod.outlook.com>
From: Tianyin Xu <tyxu@illinois.edu>
Date: Thu, 20 May 2021 03:16:10 -0500
X-Gmail-Original-Message-ID: <CAGMVDEEkDeUBcJAswpBjcQNWk7QDcO8BZR=uvVfm-+qe714tYg@mail.gmail.com>
Message-ID: <CAGMVDEEkDeUBcJAswpBjcQNWk7QDcO8BZR=uvVfm-+qe714tYg@mail.gmail.com>
Subject: Re: [RFC PATCH bpf-next seccomp 00/12] eBPF seccomp filters
To: Tycho Andersen <tycho@tycho.pizza>
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
        Kees Cook <keescook@chromium.org>, Sargun Dhillon <sargun@sargun.me>,
        Tobin Feldman-Fitzthum <tobin@ibm.com>,
        Tom Hromatka <tom.hromatka@oracle.com>, Will Drewry <wad@chromium.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Originating-IP: [209.85.210.49]
X-ClientProxiedBy: SN4PR0501CA0130.namprd05.prod.outlook.com
 (2603:10b6:803:42::47) To DM5PR11MB1692.namprd11.prod.outlook.com
 (2603:10b6:3:d::23)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
X-MS-Exchange-MessageSentRepresentingType: 1
Received: from mail-ot1-f49.google.com (209.85.210.49) by SN4PR0501CA0130.namprd05.prod.outlook.com (2603:10b6:803:42::47) with Microsoft SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.4173.12 via Frontend Transport; Thu, 20 May 2021 08:21:46 +0000
Received: by mail-ot1-f49.google.com with SMTP id 80-20020a9d08560000b0290333e9d2b247so3599025oty.7        for <containers@lists.linux.dev>; Thu, 20 May 2021 01:21:46 -0700 (PDT)
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id: 99c10061-82ad-4f3b-f173-08d91b684eb1
X-MS-TrafficTypeDiagnostic: DM5PR11MB0028:
X-Microsoft-Antispam-PRVS: 
	<DM5PR11MB0028B459EA3B681C83373A12BB2A9@DM5PR11MB0028.namprd11.prod.outlook.com>
X-MS-Oob-TLC-OOBClassifiers: OLM:8273;
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam: BCL:0;
X-Microsoft-Antispam-Message-Info: 
	pu9XqBvSScR4IVXWfWSTgqMvA03KNDJLspYO7EECEUDW4Dz/Goe3fDcGOrGmfcGlN5FHwwu1GBRUapLl/5VS7vhkaRDeQGLizKAQCuO+81kYVZwFaizB28CLK3Gno/Ew2LOPxexuPL/FQaufkaukrIcrYRHN15BQqXkHWE50NenEweF2HjELP57LI8MNrXuz0VN+EAIvVJZQdhZ9mkq0YtcllgHA4urF+LSLrnBOaPQORpLvxyuS8duZeu2qj1C9g0tCCh7e6B1D+V0AskFvHQ5yIusL4UT4fTPtf8xT5CkbzErNdigu3Cwv0MeF6PHD0Gn80bxCO7wgZlJEBBM/ZL/9XiKNfj2W9TziH+GVP2S9zP6Xf1Y2KvFzREnmynjsDJfrr1yH546urUVqX37pEZVRkyR3lnHJyZjWJDvdS8H8X7Ihn/HSFeJmWXZZvWTjYFa2zv0+BZxMmqZ1hgwUF3bG7qRYESDNBzZLlNaOgvBqV8PBLGiaa9tMNScYg8WtIpvEmI1MySDKvA+GRd/sDBMUbnPKWHk33QJT6DFhR6TISi8mg7YcEFrLjc/0dNJstJ27SMdWrFFbInDRw4xhWBXGDjK2TtVa7RqYsVKSBQry2DnqUaOF+6vvduoMPtRQnTZZUBEQSiZ9PoNitZer2wrimmKlqERw/3Kcz+zb69g1WwbSaA6CXZP6Q3EFlOZlfhtB83trffO+HWOftUSP6LsjnhUy3LESQQ0QZOIo8rQ=
X-Forefront-Antispam-Report: 
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:DM5PR11MB1692.namprd11.prod.outlook.com;PTR:;CAT:NONE;SFS:(136003)(366004)(39850400004)(346002)(396003)(376002)(5660300002)(66476007)(42186006)(186003)(316002)(786003)(75432002)(54906003)(26005)(38350700002)(38100700002)(66946007)(4326008)(8936002)(86362001)(6666004)(478600001)(83380400001)(966005)(2906002)(9686003)(52116002)(8676002)(66556008)(6862004)(55446002)(53546011)(107886003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData: 
	=?utf-8?B?TUF1MHVpNU11VEFRd1VpS3FFajNDTUVBVTZnOUg4RmZSdmZ5SmF0RzZmMXNN?=
 =?utf-8?B?eEgwVFVrcUtmMEpLZlBNS2ZwRHV6UURIcUt2L3JRd2xZY05ta1Z3cU4rZHV0?=
 =?utf-8?B?VjJQZUZkRFovRXlHMUZWYW1VY3krS3VjTkg0SFVGNXRzbWlkc3ZlWFIzaVJ3?=
 =?utf-8?B?U2RYQVJ2TVJ0Um1GTFIwVEFURnpyTWVNSys5bFZIOUN1RFlUSFpwMU5WR09U?=
 =?utf-8?B?YllOeHdtRU9mNU1UYlRTZ0w5QWk5Sjkray9nR3R1QkJsR3VLbHFiY2VhZU00?=
 =?utf-8?B?VXRSVEVlWjVpYzFGOExqVGJzK2Y0aVJSTTRsMlFXTEpGb1Z3MktXMUx0NXVO?=
 =?utf-8?B?dWVZeVpVdW9WRDhSaUJ6N01XNVBQVjdlYllVYktJZGU5SWxidDJ2ZUpwSk5m?=
 =?utf-8?B?cStKUmxsbXE0dnFBR2FhdElMV3RMWEw2cG5ncndZdTdxNVFOa2prd2N3MUJR?=
 =?utf-8?B?L2ZLOUVVWlMxY0duV29aR3R5M2tPV0Z1cy9IZi9xRnUrS3NvajRjSzRUMjVr?=
 =?utf-8?B?b3JvOFN1NlhYTnhhTFJRSXN0OWV0YVVxczdqQXFpNU9MQ1NKWDZEODY5RkZl?=
 =?utf-8?B?QkhPdWJwV3ZsTGw5N0xndUUwaHVFL3p1WXVrL1NtcFJOakQ3cHZKV1ZJSHNI?=
 =?utf-8?B?bHNNT2QwOTEwVjJQcHorUTRjanJTNnJlZEZzcGZxWGZhd3cxLzA2R21SeDE0?=
 =?utf-8?B?bTJUbFYzVWFiWjVSTm4rT1NSUnREZlB3V1hyVG9YV00xb2ZPZytaam4yamtJ?=
 =?utf-8?B?NkF0ME9yY0NvODBOcERaUEd1N2hYZ2pmMnQ2b092SU95bzU4UUN5NXpLUW1Z?=
 =?utf-8?B?U0Y2aTVhWDZJejhSZHVLNElxRDFUNmQyVFdHS3lROW03TUtVRlRQN2FJUkV0?=
 =?utf-8?B?K2MrZWZCQjFuemNYTTQvSUhxanJuTk9pd2RxWWVUc2tXZUJkSFR6SWNlYU9H?=
 =?utf-8?B?TDJDbVRKTkRUZG5ZQitxN3pHTXZKS0RPaU5JMjdwSjFrdU9uY3p1SDNhejMr?=
 =?utf-8?B?aHRVb2MyMEdya1VMdFJpL1NlOW1HTjJpM1dJcEV3OERHeXJJRWp5RGVNbjZX?=
 =?utf-8?B?aG5xczdYZXc1VmFTU0ptdURsRFRQcnBMT3lrSTYrbXphRkZtaWQ5dEtYZFN6?=
 =?utf-8?B?Nk91WGhVU1lYRDh1R1B3MEdNLy8rUmdZUURnNHZ4NWFqZ1ErS2Vaai9XbkpR?=
 =?utf-8?B?amhOOEVvemN1VTVMYmowajA2Sit0SldySDVZWUVjSEJzMS93RWt5am1lRDV2?=
 =?utf-8?B?VTYyRkNORnFhUzhEamNuQ1FSUTRMNk1qdlB3MDRJQ21sRk9LbS9yNmxwZk1M?=
 =?utf-8?B?b2hwTUh1RHRLTm5sZXdQb2JnRzRqZnY4WE5hcGdQM2VLV05lN29OR0kvMnQ1?=
 =?utf-8?B?QlhOM2pPWithcEhybi9XTEduZHA1UjVwdGlMVm5hK1FFM1JiRjFBNW9GcEVN?=
 =?utf-8?B?aVFaa2xGUlY1UGVuNGVHdnVVSmYyRWVQSXFXL3NhMEt3TUxVQ212a3dMdVNH?=
 =?utf-8?B?VFFEOVQxdEI2RzhFSkpoUVZhY213SVFRVDcrUmc5VGRQTnZ5VU5PUHMxU2w4?=
 =?utf-8?B?czcwOTJhaERBUi8yekg1Snpyb3RtVS90WWw2U2w5VFFIZDdEZzY5MHNZak9X?=
 =?utf-8?B?aENZNWVlZDQzWkxrcjZIZ291U3ZsNDJoemZ2RmVKMDQxNiszem5FdFlBa1VX?=
 =?utf-8?B?UW4yRXkwVHQ2R0draFpNZlJEdDNyL3IyU2l5NGpQUlRZc3RwZ3dpNVZvRkVW?=
 =?utf-8?Q?sC3aJWFjjblY/OJwSL3/rNbwxMnUPC0KJ+/s4rq?=
X-OriginatorOrg: illinois.edu
X-MS-Exchange-CrossTenant-Network-Message-Id: 99c10061-82ad-4f3b-f173-08d91b684eb1
X-MS-Exchange-CrossTenant-AuthSource: DM5PR11MB1692.namprd11.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 20 May 2021 08:21:46.2398
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 44467e6f-462c-4ea2-823f-7800de5434e3
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: 7qqMEb2kTa51kdl2mNBokqWfUKrxDQdmB/b4llRh1pH07LyxV4cTUXF8vZpNzdwW+pOunx5TROlUeiRX+myAfw==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM5PR11MB0028
X-Proofpoint-ORIG-GUID: cay2__6CbAwOneCpxCBUQDAPBO9iLhdr
X-Proofpoint-GUID: cay2__6CbAwOneCpxCBUQDAPBO9iLhdr
X-Spam-Details: rule=cautious_plus_nq_notspam policy=cautious_plus_nq score=0 clxscore=1015
 spamscore=0 priorityscore=1501 phishscore=0 malwarescore=0 adultscore=0
 suspectscore=0 impostorscore=0 mlxlogscore=999 mlxscore=0
 lowpriorityscore=0 bulkscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.12.0-2104190000 definitions=main-2105200062
X-Spam-Score: 0
X-Spam-OrigSender: tyxu@illinois.edu
X-Spam-Bar: 

On Mon, May 17, 2021 at 10:40 AM Tycho Andersen <tycho@tycho.pizza> wrote:
>
> On Sun, May 16, 2021 at 03:38:00AM -0500, Tianyin Xu wrote:
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
>
> I'm not sure I buy this argument. Podman already has a conmon instance
> for each container, this could be a child of that conmon process, or
> live inside conmon itself.
>
> Tycho

I checked with Andrea Arcangeli and Giuseppe Scrivano who are working on Po=
dman.

You are right that Podman is not completely daemonless. However, =E2=80=9Ct=
he
fact it's no entirely daemonless doesn't imply it's a good idea to
make it worse and to add complexity to the background conmon daemon or
to add more daemons.=E2=80=9D

TL;DR. User notifiers are surely more flexible, but are also more
expensive and complex to implement, compared with ebpf filters. /*
I=E2=80=99ll reply to Sargun=E2=80=99s performance argument in a separate e=
mail */

I'm sure you know Podman well, but let me still move some jade from
Andrea and Giuseppe (all credits on podmon/crun are theirs) to
elaborate the point, for folks cced on the list who are not very
familiar with Podman.

Basically, the current order goes as follows:

         podman -> conmon -> crun -> container_binary
                               \
                                - seccomp done at crun level, not conmon

At runtime, what's left is:

         conmon -> container_binary  /* podman disappears; crun disappears =
*/

So, to go through and use seccomp notify to block `exec`, we can
either start the container_binary with a seccomp agent wrapper, or
bloat the common binary (as pointed out by Tycho).

If we go with the first approach, we will have:

         podman -> conmon -> crun -> seccomp_agent -> container_binary

So, at runtime we'd be left with one more daemon:

        conmon -> seccomp_agent -> container_binary

Apparently, nobody likes one more daemon. So, the proposal from
Giuseppe was/is to use user notifiers as plugins (.so) loaded by
conmon:
https://github.com/containers/conmon/pull/190
https://github.com/containers/crun/pull/438

Now, with the ebpf filter support, one can implement the same thing
using an embarrassingly simple ebpf filter and, thanks to Giuseppe,
this is well supported by crun.

--=20
Tianyin Xu
University of Illinois at Urbana-Champaign
https://tianyin.github.io/
