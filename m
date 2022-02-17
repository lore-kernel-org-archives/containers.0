Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 07D333B29
	for <containers@lists.linux.dev>; Thu, 17 Feb 2022 14:44:31 +0000 (UTC)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.1.2/8.16.1.2) with SMTP id 21HEdom6018081;
	Thu, 17 Feb 2022 14:44:18 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ibm.com; h=message-id : subject :
 from : to : cc : date : in-reply-to : references : content-type :
 mime-version : content-transfer-encoding; s=pp1;
 bh=spMY1+f5fzaepG3IJUmW+zDHj/gJnfmPPnGFIgIiXsU=;
 b=fi7jlNKXVPhmSjf6OqwffLzNHGvgqY7Hrx1kckDn2tONEp7A6FWR7I1SQU6sdtFwEmQU
 NilIRGopIoR5X2zQb/5O/Hgr2Q5sd6K4RAiP3BEeZ7uzBTXYHqsImJRYw5TSc6vXxeDv
 A9hkaQ069E5XjYjsw9M9n8I0p1mAn0yT5U+kaGSRzlbQZMB2asPt2SBMPx5POjDvqdEd
 TIdzvip9RLLYOaAh4yrOjJuVv/3t3n2Mvup5THoXlEV2lLc08ooiWlmpDTn1082blwqV
 82xlpQsUtoeYiho80Z8aVygFwdnHCK8eITdikR8fceGftOGYxajznaHGCg6meUKbRVOW DA== 
Received: from pps.reinject (localhost [127.0.0.1])
	by mx0b-001b2d01.pphosted.com with ESMTP id 3e9q3ma170-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 17 Feb 2022 14:44:18 +0000
Received: from m0098420.ppops.net (m0098420.ppops.net [127.0.0.1])
	by pps.reinject (8.16.0.43/8.16.0.43) with SMTP id 21HEfKqe025294;
	Thu, 17 Feb 2022 14:44:17 GMT
Received: from ppma04fra.de.ibm.com (6a.4a.5195.ip4.static.sl-reverse.com [149.81.74.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 3e9q3ma167-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 17 Feb 2022 14:44:17 +0000
Received: from pps.filterd (ppma04fra.de.ibm.com [127.0.0.1])
	by ppma04fra.de.ibm.com (8.16.1.2/8.16.1.2) with SMTP id 21HEXpFX028151;
	Thu, 17 Feb 2022 14:44:15 GMT
Received: from b06avi18626390.portsmouth.uk.ibm.com (b06avi18626390.portsmouth.uk.ibm.com [9.149.26.192])
	by ppma04fra.de.ibm.com with ESMTP id 3e64hah6hm-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 17 Feb 2022 14:44:15 +0000
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06avi18626390.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id 21HEXkR949807794
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 17 Feb 2022 14:33:46 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id AE5C6A4060;
	Thu, 17 Feb 2022 14:44:11 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 64CFFA4054;
	Thu, 17 Feb 2022 14:44:09 +0000 (GMT)
Received: from sig-9-65-66-221.ibm.com (unknown [9.65.66.221])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Thu, 17 Feb 2022 14:44:09 +0000 (GMT)
Message-ID: <ee5b683e3d52b5aa9d5e7e0895d5d80c108c225c.camel@linux.ibm.com>
Subject: Re: [PATCH v10 09/27] ima: Move some IMA policy and filesystem
 related variables into ima_namespace
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
Date: Thu, 17 Feb 2022 09:44:08 -0500
In-Reply-To: <20220201203735.164593-10-stefanb@linux.ibm.com>
References: <20220201203735.164593-1-stefanb@linux.ibm.com>
	 <20220201203735.164593-10-stefanb@linux.ibm.com>
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
X-Proofpoint-GUID: 32RtK33s3oHJjgIoU6A-VViWq2h7QBOH
X-Proofpoint-ORIG-GUID: PH3FBFc87FnJIVlNd-xDURjIEiw_IVVK
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.205,Aquarius:18.0.816,Hydra:6.0.425,FMLib:17.11.62.513
 definitions=2022-02-17_05,2022-02-17_01,2021-12-02_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 lowpriorityscore=0 clxscore=1015 impostorscore=0 malwarescore=0
 suspectscore=0 mlxscore=0 spamscore=0 adultscore=0 mlxlogscore=999
 phishscore=0 bulkscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.12.0-2201110000 definitions=main-2202170066

On Tue, 2022-02-01 at 15:37 -0500, Stefan Berger wrote:
> Move the variables ima_write_mutex, ima_fs_flag, and valid_policy, which
> are related to updating the IMA policy, into the ima_namespace. This way
> each IMA namespace can set these variables independently in its instance
> of securityfs.
> 
> Signed-off-by: Stefan Berger <stefanb@linux.ibm.com>
> Acked-by: Christian Brauner <brauner@kernel.org>

Thanks,

Reviewed-by: Mimi Zohar <zohar@linux.ibm.com>

