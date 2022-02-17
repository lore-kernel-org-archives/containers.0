Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 20E9C3B29
	for <containers@lists.linux.dev>; Thu, 17 Feb 2022 14:46:23 +0000 (UTC)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.1.2/8.16.1.2) with SMTP id 21HClcSB004685;
	Thu, 17 Feb 2022 14:46:16 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ibm.com; h=message-id : subject :
 from : to : cc : date : in-reply-to : references : content-type :
 mime-version : content-transfer-encoding; s=pp1;
 bh=LfEq2DKVxw7frX4SdW5o6kqaOIfZLBqeo1TUgQHtdBs=;
 b=N9zQ/IQW1/ix6WfRSJIyxzrmESLzXmgTXUfB2p8gu1T+EInzOuVIRgZ2m+GqFziXTAcO
 Kgygewxxwh8SB4r1YoefhzgBm/I1RisvHM0OyhdySpOz5PCTYXd1WQYh4Xr6YtOJA7S7
 Go6slghGaT/e+A1x1sDlmK+jM08TI+gG3wXlkgyX//aocP6KKrhHFbbpdBgMzvj/dmbX
 0vYsvUzXMycnPzVI1tCu5Rzr6wQuyTQP7O6sc+PcE6NdeJm+fzqVrJJf7BQ1tFmH7BoZ
 LgoOieTKjdu+pOXFwrJWWwXxvQ3c8762TYGsgcRgnI7oy6aq/NxC2wJ4/4/2KYiR8S1D aw== 
Received: from pps.reinject (localhost [127.0.0.1])
	by mx0b-001b2d01.pphosted.com with ESMTP id 3e9pp9jyub-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 17 Feb 2022 14:46:16 +0000
Received: from m0098419.ppops.net (m0098419.ppops.net [127.0.0.1])
	by pps.reinject (8.16.0.43/8.16.0.43) with SMTP id 21HDLRhP005490;
	Thu, 17 Feb 2022 14:46:16 GMT
Received: from ppma06fra.de.ibm.com (48.49.7a9f.ip4.static.sl-reverse.com [159.122.73.72])
	by mx0b-001b2d01.pphosted.com with ESMTP id 3e9pp9jytw-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 17 Feb 2022 14:46:15 +0000
Received: from pps.filterd (ppma06fra.de.ibm.com [127.0.0.1])
	by ppma06fra.de.ibm.com (8.16.1.2/8.16.1.2) with SMTP id 21HEjT7Y011454;
	Thu, 17 Feb 2022 14:46:14 GMT
Received: from b06avi18878370.portsmouth.uk.ibm.com (b06avi18878370.portsmouth.uk.ibm.com [9.149.26.194])
	by ppma06fra.de.ibm.com with ESMTP id 3e645k97ss-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 17 Feb 2022 14:46:14 +0000
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06avi18878370.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id 21HEk7A824314150
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 17 Feb 2022 14:46:08 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id C37714C05E;
	Thu, 17 Feb 2022 14:46:07 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A7EA24C046;
	Thu, 17 Feb 2022 14:46:05 +0000 (GMT)
Received: from sig-9-65-66-221.ibm.com (unknown [9.65.66.221])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Thu, 17 Feb 2022 14:46:05 +0000 (GMT)
Message-ID: <38ac6915df39fb75fd7ae71c9daf488c772ae4b6.camel@linux.ibm.com>
Subject: Re: [PATCH v10 08/27] ima: Move measurement list related variables
 into ima_namespace
From: Mimi Zohar <zohar@linux.ibm.com>
To: Stefan Berger <stefanb@linux.ibm.com>, linux-integrity@vger.kernel.org
Cc: serge@hallyn.com, christian.brauner@ubuntu.com, containers@lists.linux.dev,
        dmitry.kasatkin@gmail.com, ebiederm@xmission.com,
        krzysztof.struczynski@huawei.com, roberto.sassu@huawei.com,
        mpeters@redhat.com, lhinds@redhat.com, lsturman@redhat.com,
        puiterwi@redhat.com, jejb@linux.ibm.com, jamjoom@us.ibm.com,
        linux-kernel@vger.kernel.org, paul@paul-moore.com, rgb@redhat.com,
        linux-security-module@vger.kernel.org, jmorris@namei.org
Date: Thu, 17 Feb 2022 09:46:05 -0500
In-Reply-To: <20220201203735.164593-9-stefanb@linux.ibm.com>
References: <20220201203735.164593-1-stefanb@linux.ibm.com>
	 <20220201203735.164593-9-stefanb@linux.ibm.com>
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
X-Proofpoint-GUID: 0wa5abw_26jBeXKF7y9-udVZwolj8Fb8
X-Proofpoint-ORIG-GUID: de0yQ7rPNE-AU7GY4PaVYyypyiBErvJW
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.205,Aquarius:18.0.816,Hydra:6.0.425,FMLib:17.11.62.513
 definitions=2022-02-17_05,2022-02-17_01,2021-12-02_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 mlxscore=0 spamscore=0
 mlxlogscore=999 suspectscore=0 malwarescore=0 priorityscore=1501
 lowpriorityscore=0 impostorscore=0 clxscore=1015 phishscore=0 adultscore=0
 bulkscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.12.0-2201110000 definitions=main-2202170066

On Tue, 2022-02-01 at 15:37 -0500, Stefan Berger wrote:
> Move measurement list related variables into the ima_namespace. This way
> a front-end like securityfs can show the measurement list inside an IMA
> namespace.

Also, in order for kexec to allocate memory for the existing
measurement list, the measurement list memory size is stored in the
binary_runtime_size variable.  To avoid special-casing init_ima_ns, as
much as possible, move it into the ima_namespace.

> 
> Signed-off-by: Stefan Berger <stefanb@linux.ibm.com>

Reviewed-by: Mimi Zohar <zohar@linux.ibm.com>

