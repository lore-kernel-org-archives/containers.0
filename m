Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 41341A56
	for <containers@lists.linux.dev>; Wed, 23 Feb 2022 11:46:07 +0000 (UTC)
Received: from pps.filterd (m0187473.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.1.2/8.16.1.2) with SMTP id 21NAgfXi002921;
	Wed, 23 Feb 2022 11:45:53 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ibm.com; h=message-id : subject :
 from : to : cc : date : in-reply-to : references : content-type :
 mime-version : content-transfer-encoding; s=pp1;
 bh=mflh59XXUGLuQUJiyd5xbLSaDlOcJaruC9siPCIGWjE=;
 b=Inloe1OmkL9iUmLnKQSuRR1ou//thR9oMz1wvUh74UoLnTjZ6OCakXJlvCm7USBcMKXH
 5jpt9RNrRW1VRsqY42FhwnE49orK5iovmo/Yl82F2DIkZZl/68lxhNkNLvLhNTKLdU7G
 Yb7wGtkZJchucSrvi1k/ami/9VGod5R35Cd1mL3Iv7XhC2Ge4gcxv7E+Ko9uolyqa8id
 dFxo45uATJwjkTDWVhFvJTGc1bvLBR90CJrs9ZozgRkOACwQU1/2Kjk19A69navEejTU
 8XNs3X3GDilUEgzEWk5ZiL2Z0PJfwrhC+EOwc3Y8wR4yNDcJLh92u4I1IYbZz2g5DUPR 6Q== 
Received: from pps.reinject (localhost [127.0.0.1])
	by mx0a-001b2d01.pphosted.com with ESMTP id 3edkdqs4rx-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Wed, 23 Feb 2022 11:45:53 +0000
Received: from m0187473.ppops.net (m0187473.ppops.net [127.0.0.1])
	by pps.reinject (8.16.0.43/8.16.0.43) with SMTP id 21NBf7WL026979;
	Wed, 23 Feb 2022 11:45:52 GMT
Received: from ppma05fra.de.ibm.com (6c.4a.5195.ip4.static.sl-reverse.com [149.81.74.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 3edkdqs4rb-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Wed, 23 Feb 2022 11:45:52 +0000
Received: from pps.filterd (ppma05fra.de.ibm.com [127.0.0.1])
	by ppma05fra.de.ibm.com (8.16.1.2/8.16.1.2) with SMTP id 21NBbpnX000317;
	Wed, 23 Feb 2022 11:45:50 GMT
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by ppma05fra.de.ibm.com with ESMTP id 3ear69fxpw-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Wed, 23 Feb 2022 11:45:50 +0000
Received: from d06av24.portsmouth.uk.ibm.com (mk.ibm.com [9.149.105.60])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id 21NBjk5o50790904
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 23 Feb 2022 11:45:46 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id CCD864204C;
	Wed, 23 Feb 2022 11:45:46 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7328B42049;
	Wed, 23 Feb 2022 11:45:44 +0000 (GMT)
Received: from sig-9-65-80-154.ibm.com (unknown [9.65.80.154])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Wed, 23 Feb 2022 11:45:44 +0000 (GMT)
Message-ID: <edc472a977f40dc254d3cf9c8be5f3a5147f26ad.camel@linux.ibm.com>
Subject: Re: [PATCH v10 23/27] ima: Setup securityfs for IMA namespace
From: Mimi Zohar <zohar@linux.ibm.com>
To: Stefan Berger <stefanb@linux.ibm.com>, linux-integrity@vger.kernel.org
Cc: serge@hallyn.com, christian.brauner@ubuntu.com, containers@lists.linux.dev,
        dmitry.kasatkin@gmail.com, ebiederm@xmission.com,
        krzysztof.struczynski@huawei.com, roberto.sassu@huawei.com,
        mpeters@redhat.com, lhinds@redhat.com, lsturman@redhat.com,
        puiterwi@redhat.com, jejb@linux.ibm.com, jamjoom@us.ibm.com,
        linux-kernel@vger.kernel.org, paul@paul-moore.com, rgb@redhat.com,
        linux-security-module@vger.kernel.org, jmorris@namei.org,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        Christian Brauner
 <brauner@kernel.org>
Date: Wed, 23 Feb 2022 06:45:43 -0500
In-Reply-To: <20220201203735.164593-24-stefanb@linux.ibm.com>
References: <20220201203735.164593-1-stefanb@linux.ibm.com>
	 <20220201203735.164593-24-stefanb@linux.ibm.com>
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
X-Proofpoint-ORIG-GUID: _I-iTB139F16lISvYRV-S9UF49_RYgqP
X-Proofpoint-GUID: 1_gzps_LXdPzqss6EOQborTJl4X_nsVu
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.205,Aquarius:18.0.816,Hydra:6.0.425,FMLib:17.11.64.514
 definitions=2022-02-23_03,2022-02-23_01,2022-02-23_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 impostorscore=0 mlxscore=0
 mlxlogscore=999 priorityscore=1501 clxscore=1015 spamscore=0 adultscore=0
 lowpriorityscore=0 phishscore=0 malwarescore=0 suspectscore=0 bulkscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.12.0-2201110000
 definitions=main-2202230064

On Tue, 2022-02-01 at 15:37 -0500, Stefan Berger wrote:
> Setup securityfs with symlinks, directories, and files for IMA
> namespacing support. The same directory structure that IMA uses on the
> host is also created for the namespacing case.
> 
> The securityfs file and directory ownerships cannot be set when the
> IMA namespace is initialized. Therefore, delay the setup of the file
> system to a later point when securityfs is in securityfs_fill_super.
> 
> Introduce a variable ima_policy_removed in ima_namespace that is used to
> remember whether the policy file has previously been removed and thus
> should not be created again in case of unmounting and again mounting
> securityfs inside an IMA namespace.

When the ability of extending the custom IMA policy was added, support
for displaying  the policy was added.  (Refer to the IMA_READ_POLICY
Kconfig.)  This patch set adds support for a user, true root in the
namespace, to be able to write a custom policy.   If the
IMA_READ_POLICY is not enabled, then nobody, including host root, will
be able to view it.

Instead of continuing to support not being able to read the IMA policy,
updating the IMA_READ_POLICY Kconfig for the IMA_NS case to require it
seems preferable.

> This filesystem can now be mounted as follows:
> 
> mount -t securityfs /sys/kernel/security/ /sys/kernel/security/
> 
> The following directories, symlinks, and files are available
> when IMA namespacing is enabled, otherwise it will be empty:
> 
> $ ls -l sys/kernel/security/
> total 0
> lr--r--r--. 1 root root 0 Dec  2 00:18 ima -> integrity/ima
> drwxr-xr-x. 3 root root 0 Dec  2 00:18 integrity
> 
> $ ls -l sys/kernel/security/ima/
> total 0
> -r--r-----. 1 root root 0 Dec  2 00:18 ascii_runtime_measurements
> -r--r-----. 1 root root 0 Dec  2 00:18 binary_runtime_measurements
> -rw-------. 1 root root 0 Dec  2 00:18 policy
> -r--r-----. 1 root root 0 Dec  2 00:18 runtime_measurements_count
> -r--r-----. 1 root root 0 Dec  2 00:18 violations
> 
> Signed-off-by: Stefan Berger <stefanb@linux.ibm.com>
> Signed-off-by: James Bottomley <James.Bottomley@HansenPartnership.com>
> Acked-by: Christian Brauner <brauner@kernel.org>

Otherwise,

Reviewed-by: Mimi Zohar <zohar@linux.ibm.com>

