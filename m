Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 44B49C6A
	for <containers@lists.linux.dev>; Wed, 23 Feb 2022 14:07:10 +0000 (UTC)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.1.2/8.16.1.2) with SMTP id 21NBkkoI005347;
	Wed, 23 Feb 2022 14:06:57 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ibm.com; h=message-id : subject :
 from : to : cc : date : in-reply-to : references : content-type :
 mime-version : content-transfer-encoding; s=pp1;
 bh=giAP6wf/sHfU/F8R0GQ7i0F9uvxdMVq7CyEOMnyvgjM=;
 b=An/wMY7C7rNrohXrlxMe4zHiQEVeLpsuGmN+KTnFWCe4kQQYXVBXL6uoHdq7lERCx4cY
 xS3ZtwWxouy9OS6uD8gOHqE+h74OCFiXGc4RgXgtzRa9C6kq0/OSVbd8+fA166VT3G9z
 FS7APCZO/AhJ/4pTRFayAKYx3t2PwKjp08DYejxn5eLvmlSiMl51ATuVJjVxRmmNKNRz
 pkppY8r9ltMjUr9ssTC+kRi63vqPw9z36AzEGgazL3T3MImfokd03tnPnF88+BaFR5YW
 B1Wp1YVz01FtY1cBbf/rJ5VWQ3v8iuZJAvCdZm2q41wrXFAxldWiohT0q67TqkanZvsG Dw== 
Received: from pps.reinject (localhost [127.0.0.1])
	by mx0b-001b2d01.pphosted.com with ESMTP id 3edmbrb1ne-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Wed, 23 Feb 2022 14:06:57 +0000
Received: from m0098420.ppops.net (m0098420.ppops.net [127.0.0.1])
	by pps.reinject (8.16.0.43/8.16.0.43) with SMTP id 21NCg33S015007;
	Wed, 23 Feb 2022 14:06:57 GMT
Received: from ppma01fra.de.ibm.com (46.49.7a9f.ip4.static.sl-reverse.com [159.122.73.70])
	by mx0b-001b2d01.pphosted.com with ESMTP id 3edmbrb1mh-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Wed, 23 Feb 2022 14:06:56 +0000
Received: from pps.filterd (ppma01fra.de.ibm.com [127.0.0.1])
	by ppma01fra.de.ibm.com (8.16.1.2/8.16.1.2) with SMTP id 21NE34fu019543;
	Wed, 23 Feb 2022 14:06:55 GMT
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by ppma01fra.de.ibm.com with ESMTP id 3ear698wu3-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Wed, 23 Feb 2022 14:06:55 +0000
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id 21NE6pM546530994
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 23 Feb 2022 14:06:51 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A137611C054;
	Wed, 23 Feb 2022 14:06:51 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 4E16711C05C;
	Wed, 23 Feb 2022 14:06:49 +0000 (GMT)
Received: from sig-9-65-80-154.ibm.com (unknown [9.65.80.154])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Wed, 23 Feb 2022 14:06:49 +0000 (GMT)
Message-ID: <959c990eaaea1521424e5a4a9132d4460b8ed4aa.camel@linux.ibm.com>
Subject: Re: [PATCH v10 25/27] ima: Show owning user namespace's uid and gid
 when displaying policy
From: Mimi Zohar <zohar@linux.ibm.com>
To: Stefan Berger <stefanb@linux.ibm.com>, linux-integrity@vger.kernel.org
Cc: serge@hallyn.com, christian.brauner@ubuntu.com, containers@lists.linux.dev,
        dmitry.kasatkin@gmail.com, ebiederm@xmission.com,
        krzysztof.struczynski@huawei.com, roberto.sassu@huawei.com,
        mpeters@redhat.com, lhinds@redhat.com, lsturman@redhat.com,
        puiterwi@redhat.com, jejb@linux.ibm.com, jamjoom@us.ibm.com,
        linux-kernel@vger.kernel.org, paul@paul-moore.com, rgb@redhat.com,
        linux-security-module@vger.kernel.org, jmorris@namei.org
Date: Wed, 23 Feb 2022 09:06:48 -0500
In-Reply-To: <20220201203735.164593-26-stefanb@linux.ibm.com>
References: <20220201203735.164593-1-stefanb@linux.ibm.com>
	 <20220201203735.164593-26-stefanb@linux.ibm.com>
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
X-Proofpoint-ORIG-GUID: x1xQIQAq2Ug6LkXLkKhAQBkRwZvH6XOG
X-Proofpoint-GUID: soBUUwd1EP1GCojYK5iAOjtBZhvXDqhv
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.205,Aquarius:18.0.816,Hydra:6.0.425,FMLib:17.11.64.514
 definitions=2022-02-23_06,2022-02-23_01,2022-02-23_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 lowpriorityscore=0 mlxscore=0
 impostorscore=0 phishscore=0 adultscore=0 clxscore=1015 suspectscore=0
 priorityscore=1501 mlxlogscore=937 bulkscore=0 malwarescore=0 spamscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.12.0-2201110000
 definitions=main-2202230081

On Tue, 2022-02-01 at 15:37 -0500, Stefan Berger wrote:
> Show the uid and gid values relative to the user namespace that is
> currently active. The effect of this changes is that when one displays
> the policy from the user namespace that originally set the policy,
> the same uid and gid values are shown in the policy as those that were
> used when the policy was set.
> 
> Signed-off-by: Stefan Berger <stefanb@linux.ibm.com>

thanks,

Reviewed-by:  Mimi Zohar <zohar@linux.ibm.com>

