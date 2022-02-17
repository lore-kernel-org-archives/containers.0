Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E46754620
	for <containers@lists.linux.dev>; Thu, 17 Feb 2022 21:24:38 +0000 (UTC)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.1.2/8.16.1.2) with SMTP id 21HLCHZ5012705;
	Thu, 17 Feb 2022 21:24:30 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ibm.com; h=message-id : subject :
 from : to : cc : date : in-reply-to : references : content-type :
 mime-version : content-transfer-encoding; s=pp1;
 bh=npCr+mrD9HJvtwLKXKJmkTr7GrGwwCxh7Azvlo6Ghbw=;
 b=sLkVXxUtFpszMcPMBVyy7J8WbYBid1euE6Pyr+UCQN7FfdMQdU6culcvtwQeyVKyryIK
 ST6yKmq0H+USX5YnARQIIflS9E7afgxZ4neYyVqb//WgNz9trPbTOts4OY+bp5rW97BD
 Ju2gTXizOsNiIidS162tiueyVsNzt+bkvngydTLFX/hX3LUrAL+IRnuheRZwvlayEutQ
 69IOsZPJ8DKOR2EFygf2t9KtapRdBFaeWwl271E54B3F5KdcczbeU3ArZx/uq6Zj5sU+
 /KSCwP64N9HJcLE/uFdFHuEU3LtrPtcAuvTJb2ddI6uPRxZadlMIaS3KEMRYXRK/Gh38 Vg== 
Received: from pps.reinject (localhost [127.0.0.1])
	by mx0b-001b2d01.pphosted.com with ESMTP id 3e9uxjbssf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 17 Feb 2022 21:24:30 +0000
Received: from m0098419.ppops.net (m0098419.ppops.net [127.0.0.1])
	by pps.reinject (8.16.0.43/8.16.0.43) with SMTP id 21HLD72A031021;
	Thu, 17 Feb 2022 21:24:29 GMT
Received: from ppma04ams.nl.ibm.com (63.31.33a9.ip4.static.sl-reverse.com [169.51.49.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 3e9uxjbss6-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 17 Feb 2022 21:24:29 +0000
Received: from pps.filterd (ppma04ams.nl.ibm.com [127.0.0.1])
	by ppma04ams.nl.ibm.com (8.16.1.2/8.16.1.2) with SMTP id 21HLBcl3028269;
	Thu, 17 Feb 2022 21:24:27 GMT
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by ppma04ams.nl.ibm.com with ESMTP id 3e64hansbs-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 17 Feb 2022 21:24:27 +0000
Received: from d06av24.portsmouth.uk.ibm.com (mk.ibm.com [9.149.105.60])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id 21HLOOWW42664344
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 17 Feb 2022 21:24:24 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 27D3C42041;
	Thu, 17 Feb 2022 21:24:24 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A16C542047;
	Thu, 17 Feb 2022 21:24:21 +0000 (GMT)
Received: from sig-9-65-72-122.ibm.com (unknown [9.65.72.122])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Thu, 17 Feb 2022 21:24:21 +0000 (GMT)
Message-ID: <70f47a79438d6962fb5b633e1f2756763bcc6507.camel@linux.ibm.com>
Subject: Re: [PATCH v10 11/27] ima: Move ima_lsm_policy_notifier into
 ima_namespace
From: Mimi Zohar <zohar@linux.ibm.com>
To: Stefan Berger <stefanb@linux.ibm.com>, linux-integrity@vger.kernel.org
Cc: serge@hallyn.com, christian.brauner@ubuntu.com, containers@lists.linux.dev,
        dmitry.kasatkin@gmail.com, ebiederm@xmission.com,
        krzysztof.struczynski@huawei.com, roberto.sassu@huawei.com,
        mpeters@redhat.com, lhinds@redhat.com, lsturman@redhat.com,
        puiterwi@redhat.com, jejb@linux.ibm.com, jamjoom@us.ibm.com,
        linux-kernel@vger.kernel.org, paul@paul-moore.com, rgb@redhat.com,
        linux-security-module@vger.kernel.org, jmorris@namei.org
Date: Thu, 17 Feb 2022 16:24:18 -0500
In-Reply-To: <95a9eb64-654b-8d34-12c7-1dd7666e3420@linux.ibm.com>
References: <20220201203735.164593-1-stefanb@linux.ibm.com>
	 <20220201203735.164593-12-stefanb@linux.ibm.com>
	 <62f946ec160296b6b20bee98986b2bafb8427718.camel@linux.ibm.com>
	 <95a9eb64-654b-8d34-12c7-1dd7666e3420@linux.ibm.com>
Content-Type: text/plain; charset="ISO-8859-15"
X-Mailer: Evolution 3.28.5 (3.28.5-18.el8) 
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-TM-AS-GCONF: 00
X-Proofpoint-GUID: UJLg04jMq_UTBAj1uRstpK6koVGE4Uls
X-Proofpoint-ORIG-GUID: 73VuLoOrFe-toDW-umdrcgsbBvRzr8yB
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.205,Aquarius:18.0.816,Hydra:6.0.425,FMLib:17.11.62.513
 definitions=2022-02-17_08,2022-02-17_01,2021-12-02_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 impostorscore=0 mlxscore=0
 suspectscore=0 phishscore=0 malwarescore=0 bulkscore=0 lowpriorityscore=0
 clxscore=1015 spamscore=0 adultscore=0 priorityscore=1501 mlxlogscore=999
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.12.0-2201110000
 definitions=main-2202170100

On Thu, 2022-02-17 at 15:59 -0500, Stefan Berger wrote:
> >
> >> Move the ima_lsm_policy_notifier into the ima_namespace. Each IMA
> >> namespace can now register its own LSM policy change notifier callback.
> >> The policy change notifier for the init_ima_ns still remains in init_ima()
> >> and therefore handle the registration of the callback for all other
> >> namespaces in init_ima_namespace().
> >>
> >> Suppress the kernel warning 'rule for LSM <label> is undefined` for all
> >> other IMA namespaces than the init_ima_ns.
> > Instead of ignoring the warnings totally, perhaps use either the
> > "ratelimited" or "once" function options for non init_ima_ns.  It would
> > be nice if these functions could be namespace aware, so that each
> > affected IMA namespace would contain at least one warning.
> 
> The problem is that any user can now repeatedly create user namespaces 
> and with that IMA namespaces and cause the kernel log to fill up with 
> these messages and also flood the audit log -- I guess one could 
> describe it as an unwanted side-effect. I am afraid that for as long as 
> the kernel log is not namespaced it's probably best to just turn them 
> off for non-init_ima_ns.

There are functions - pr_warn_once() or pr_warn_ratelimited() - that
limit the number of kernel messages.  In addition to the number of
potential kernel messages, there's also the issue of being able to
differentiate between init_ima_ns and other IMA namespaces.  I think
that is more of a concern than rate limiting.

-- 
thanks,

Mimi




