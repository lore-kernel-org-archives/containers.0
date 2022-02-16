Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6A9851B60
	for <containers@lists.linux.dev>; Wed, 16 Feb 2022 16:40:02 +0000 (UTC)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.1.2/8.16.1.2) with SMTP id 21GGGPjU024471;
	Wed, 16 Feb 2022 16:39:49 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ibm.com; h=message-id : subject :
 from : to : cc : date : in-reply-to : references : content-type :
 mime-version : content-transfer-encoding; s=pp1;
 bh=QFAT4gUY7ssHFMRKnYKL1cpcMiUM8TBsa2LK3fdhHW0=;
 b=CHsh3LQsQlw+AlPF9ZzINxswwd+y6vEDqWW8ApcopHUcmtHE96zS0EBj/kBQ6vgEgPJe
 45LERF2kn+i9i5yxZ9qweO+h/r1W0PCZSAFzNROIADPRPa6PQFz6iilDQLc2HxYK8VOo
 5+TUcnWvyHuciBZWBhNoU/Rfz0OtoFUB5qYy9kKB/oEG4lklVA/q6z+OVpaiWCFfM4+f
 YOlGeZvApqVEjyKl4u7n/44wulVS6MufE1ruR298tspmQc8CEaRJPB/XPRvjpXQLLSxW
 43ClWHUdbHD9vwRUZMu4QpozHgDxqU+opANhFcmmhYNI+k1VvA5IgIu5X6k1Cz8fa7v+ RA== 
Received: from pps.reinject (localhost [127.0.0.1])
	by mx0b-001b2d01.pphosted.com with ESMTP id 3e94n48j4c-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Wed, 16 Feb 2022 16:39:48 +0000
Received: from m0098416.ppops.net (m0098416.ppops.net [127.0.0.1])
	by pps.reinject (8.16.0.43/8.16.0.43) with SMTP id 21GGH85m029532;
	Wed, 16 Feb 2022 16:39:48 GMT
Received: from ppma02fra.de.ibm.com (47.49.7a9f.ip4.static.sl-reverse.com [159.122.73.71])
	by mx0b-001b2d01.pphosted.com with ESMTP id 3e94n48j3q-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Wed, 16 Feb 2022 16:39:47 +0000
Received: from pps.filterd (ppma02fra.de.ibm.com [127.0.0.1])
	by ppma02fra.de.ibm.com (8.16.1.2/8.16.1.2) with SMTP id 21GGWu3o022678;
	Wed, 16 Feb 2022 16:39:46 GMT
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by ppma02fra.de.ibm.com with ESMTP id 3e64ha0y3b-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Wed, 16 Feb 2022 16:39:45 +0000
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id 21GGdgwK43385098
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 16 Feb 2022 16:39:42 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B9DA111C064;
	Wed, 16 Feb 2022 16:39:42 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 5B39011C052;
	Wed, 16 Feb 2022 16:39:40 +0000 (GMT)
Received: from sig-9-65-87-58.ibm.com (unknown [9.65.87.58])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Wed, 16 Feb 2022 16:39:40 +0000 (GMT)
Message-ID: <bf435ffa5d176213acabb8c576c159d2cbd4d395.camel@linux.ibm.com>
Subject: Re: [PATCH v10 06/27] ima: Move arch_policy_entry into ima_namespace
From: Mimi Zohar <zohar@linux.ibm.com>
To: Stefan Berger <stefanb@linux.ibm.com>, linux-integrity@vger.kernel.org
Cc: serge@hallyn.com, christian.brauner@ubuntu.com, containers@lists.linux.dev,
        dmitry.kasatkin@gmail.com, ebiederm@xmission.com,
        krzysztof.struczynski@huawei.com, roberto.sassu@huawei.com,
        mpeters@redhat.com, lhinds@redhat.com, lsturman@redhat.com,
        puiterwi@redhat.com, jejb@linux.ibm.com, jamjoom@us.ibm.com,
        linux-kernel@vger.kernel.org, paul@paul-moore.com, rgb@redhat.com,
        linux-security-module@vger.kernel.org, jmorris@namei.org,
        Christian Brauner <brauner@kernel.org>
Date: Wed, 16 Feb 2022 11:39:39 -0500
In-Reply-To: <20220201203735.164593-7-stefanb@linux.ibm.com>
References: <20220201203735.164593-1-stefanb@linux.ibm.com>
	 <20220201203735.164593-7-stefanb@linux.ibm.com>
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
X-Proofpoint-ORIG-GUID: _kEptbkdhmHsaVrTiedogSKaxYCKIJe9
X-Proofpoint-GUID: Pv9Dws_nJSQV-4Gm67F5Ftf7QF_YBqX_
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.205,Aquarius:18.0.816,Hydra:6.0.425,FMLib:17.11.62.513
 definitions=2022-02-16_07,2022-02-16_01,2021-12-02_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 malwarescore=0
 mlxlogscore=986 suspectscore=0 phishscore=0 clxscore=1015 bulkscore=0
 lowpriorityscore=0 priorityscore=1501 impostorscore=0 spamscore=0
 adultscore=0 mlxscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.12.0-2201110000 definitions=main-2202160097

On Tue, 2022-02-01 at 15:37 -0500, Stefan Berger wrote

Let's update the patch description providing a bit more background
info:

The archictecture specific policy rules, currently defined for EFI and
powerpc, require the kexec kernel image and kernel modules to be
validly signed and measured, based on the system's secure boot and/or
trusted boot mode and the IMA_ARCH_POLICY Kconfig option being enabled.

> Move the arch_policy_entry pointer into ima_namespace.

Perhaps include something about namespaces being allowed or not allowed
to kexec a new kernel or load kernel modules.

thanks,

Mimi
> 
> When freeing the memory set the pointer to NULL.
> 
> Signed-off-by: Stefan Berger <stefanb@linux.ibm.com>
> Acked-by: Christian Brauner <brauner@kernel.org>
> Reviewed-by: Mimi Zohar <zohar@linux.ibm.com>

