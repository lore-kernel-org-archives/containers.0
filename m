Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 509F52C9D
	for <containers@lists.linux.dev>; Thu, 10 Feb 2022 12:02:45 +0000 (UTC)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.1.2/8.16.1.2) with SMTP id 21ABvjkN023263;
	Thu, 10 Feb 2022 12:02:28 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ibm.com; h=message-id : subject :
 from : to : cc : date : in-reply-to : references : content-type :
 mime-version : content-transfer-encoding; s=pp1;
 bh=cUwwPlcSVq3EbzFweq4B+SWkO7KG9Z5wfG43MKjPP2U=;
 b=anPNHK4FtgNLTUQ1IiIP0Uotkl98mhN759pqyusKTV6XBvUWoXgEMyc3wlTm71nj2Um9
 bqi646UpwIGSIg+lVOowynAhuKJXkEl6x16Gct3yS8SOjRSfXKLnvZkxPtrCuiysoTez
 JJ1gSmHGal+1MV58Bwah59f2jnBWVWMhzPbt/YXX25a8jNkAXeJ/MG9piGe9Jp2G85lU
 4cyor78Gk3WqCxEUofhCXPmCntduZtB3LuceLya+2++QfFkCk93UFMWTuqQ9Tkt3XWy6
 QYy8GACN8ogloJIub0IsQsnPGuR7CFEkfgJbomkJZJLN4qdXwLHhPx2qhY2OyKkYh3SN wQ== 
Received: from pps.reinject (localhost [127.0.0.1])
	by mx0a-001b2d01.pphosted.com with ESMTP id 3e529tr44f-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 10 Feb 2022 12:02:28 +0000
Received: from m0098394.ppops.net (m0098394.ppops.net [127.0.0.1])
	by pps.reinject (8.16.0.43/8.16.0.43) with SMTP id 21ABxJSG002234;
	Thu, 10 Feb 2022 12:02:27 GMT
Received: from ppma06fra.de.ibm.com (48.49.7a9f.ip4.static.sl-reverse.com [159.122.73.72])
	by mx0a-001b2d01.pphosted.com with ESMTP id 3e529tr432-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 10 Feb 2022 12:02:27 +0000
Received: from pps.filterd (ppma06fra.de.ibm.com [127.0.0.1])
	by ppma06fra.de.ibm.com (8.16.1.2/8.16.1.2) with SMTP id 21ABhtsu004979;
	Thu, 10 Feb 2022 12:02:25 GMT
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by ppma06fra.de.ibm.com with ESMTP id 3e1ggjnr85-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 10 Feb 2022 12:02:24 +0000
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id 21AC2KOC41943324
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 10 Feb 2022 12:02:20 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id EF63FAE057;
	Thu, 10 Feb 2022 12:02:19 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 18A3FAE05D;
	Thu, 10 Feb 2022 12:02:16 +0000 (GMT)
Received: from sig-9-65-78-200.ibm.com (unknown [9.65.78.200])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Thu, 10 Feb 2022 12:02:15 +0000 (GMT)
Message-ID: <1a4bc3cf915057bc5c5957c42c164bc2491a9da7.camel@linux.ibm.com>
Subject: Re: [PATCH v10 03/27] ima: Return error code obtained from
 securityfs functions
From: Mimi Zohar <zohar@linux.ibm.com>
To: Stefan Berger <stefanb@linux.ibm.com>, linux-integrity@vger.kernel.org
Cc: serge@hallyn.com, christian.brauner@ubuntu.com, containers@lists.linux.dev,
        dmitry.kasatkin@gmail.com, ebiederm@xmission.com,
        krzysztof.struczynski@huawei.com, roberto.sassu@huawei.com,
        mpeters@redhat.com, lhinds@redhat.com, lsturman@redhat.com,
        puiterwi@redhat.com, jejb@linux.ibm.com, jamjoom@us.ibm.com,
        linux-kernel@vger.kernel.org, paul@paul-moore.com, rgb@redhat.com,
        linux-security-module@vger.kernel.org, jmorris@namei.org
Date: Thu, 10 Feb 2022 07:02:15 -0500
In-Reply-To: <20220201203735.164593-4-stefanb@linux.ibm.com>
References: <20220201203735.164593-1-stefanb@linux.ibm.com>
	 <20220201203735.164593-4-stefanb@linux.ibm.com>
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
X-Proofpoint-GUID: QYOMhTGvl4dJ7n3-icGLZhJ7ApOLOQNV
X-Proofpoint-ORIG-GUID: qZ0v2PLwS90p35q7fqTsNLxo0FfitInL
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.205,Aquarius:18.0.816,Hydra:6.0.425,FMLib:17.11.62.513
 definitions=2022-02-10_05,2022-02-09_01,2021-12-02_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 suspectscore=0
 impostorscore=0 lowpriorityscore=0 malwarescore=0 priorityscore=1501
 adultscore=0 mlxscore=0 bulkscore=0 mlxlogscore=953 clxscore=1015
 phishscore=0 spamscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.12.0-2201110000 definitions=main-2202100066

On Tue, 2022-02-01 at 15:37 -0500, Stefan Berger wrote:
> If an error occurs when creating a securityfs file, return the exact
> error code to the caller.
> 
> Signed-off-by: Stefan Berger <stefanb@linux.ibm.com>

Thanks, Stefan.  Nice cleanup.

Reviewed-by: Mimi Zohar <zohar@linux.ibm.com>

