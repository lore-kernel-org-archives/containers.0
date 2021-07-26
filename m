Received: from mx0b-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B904A168
	for <containers@lists.linux.dev>; Mon, 26 Jul 2021 11:39:21 +0000 (UTC)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.43/8.16.0.43) with SMTP id 16QBZ6ad051245;
	Mon, 26 Jul 2021 07:39:11 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ibm.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=pp1;
 bh=RBl+6UdLVky9tWqZDo2q1IFMQU6oHXn0KMujZbMsKoU=;
 b=ed1+OaXPYv7fRZ/JGsE2oVWfvq51dvv9rKTcLqDrhJU2zfLRR3i34wGX++3T9cPET/K8
 BkX5DL2RPgdVPxse7ODsj3Uk3rjbkSPHHz3AKDvfEYNJ979V2QGuAheqyxKBrdROnxbR
 EiIB5WxTiRvjzihnVxNArIxP+d29MLDOioKLO1nBM1Ds4wwTIHU0GlO7IhQ0v6u8nJ7f
 bNMUzG3mzJeKKF0PnIb4AM+cRKQ6K+CGaFvDiv9NQhgiv+eYtAPp/gBq746g9Z7E4zQw
 XNPCMCZaf6XvCVdZReqXflEhc/ROftp4XGxmA3e+vWp4u+redDk/vB7D2Ceyv1awqYjz 1Q== 
Received: from pps.reinject (localhost [127.0.0.1])
	by mx0a-001b2d01.pphosted.com with ESMTP id 3a1us5hbq1-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Mon, 26 Jul 2021 07:39:11 -0400
Received: from m0098421.ppops.net (m0098421.ppops.net [127.0.0.1])
	by pps.reinject (8.16.0.43/8.16.0.43) with SMTP id 16QBZ8ou051358;
	Mon, 26 Jul 2021 07:39:11 -0400
Received: from ppma01fra.de.ibm.com (46.49.7a9f.ip4.static.sl-reverse.com [159.122.73.70])
	by mx0a-001b2d01.pphosted.com with ESMTP id 3a1us5hbnv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Mon, 26 Jul 2021 07:39:10 -0400
Received: from pps.filterd (ppma01fra.de.ibm.com [127.0.0.1])
	by ppma01fra.de.ibm.com (8.16.1.2/8.16.1.2) with SMTP id 16QBcBTY017668;
	Mon, 26 Jul 2021 11:39:09 GMT
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by ppma01fra.de.ibm.com with ESMTP id 3a0ag8rp6k-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Mon, 26 Jul 2021 11:39:08 +0000
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id 16QBd60020906250
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 26 Jul 2021 11:39:06 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 0630EA405B;
	Mon, 26 Jul 2021 11:39:06 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 347A6A406B;
	Mon, 26 Jul 2021 11:39:03 +0000 (GMT)
Received: from [9.199.48.104] (unknown [9.199.48.104])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Mon, 26 Jul 2021 11:39:02 +0000 (GMT)
Subject: Re: [RFD] Provide virtualized CPU system information for containers
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        containers@lists.linux.dev, containers@lists.linux-foundation.org,
        legion@kernel.org, akpm@linux-foundation.org,
        christian.brauner@ubuntu.com, hannes@cmpxchg.org, mhocko@kernel.org,
        Alexey Makhalov
 <amakhalov@vmware.com>, llong@redhat.com,
        pratik.r.sampat@gmail.com
References: <ac76aada-f94d-d596-9b3c-1dca5a9914d0@linux.ibm.com>
 <874kcmmkz4.fsf@disp2133>
From: Pratik Sampat <psampat@linux.ibm.com>
Message-ID: <fe947175-62f5-c3fa-158c-7be2dd886c0e@linux.ibm.com>
Date: Mon, 26 Jul 2021 17:09:02 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101
 Thunderbird/78.11.0
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
In-Reply-To: <874kcmmkz4.fsf@disp2133>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-TM-AS-GCONF: 00
X-Proofpoint-ORIG-GUID: j3Iw1sZBev5z4RiyBqyF6JIhbSrHxozq
X-Proofpoint-GUID: AVKjNkh0thjZ2cfZlB5QDBzvYxPiMJ2A
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:6.0.391,18.0.790
 definitions=2021-07-26_06:2021-07-26,2021-07-26 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 malwarescore=0
 priorityscore=1501 spamscore=0 lowpriorityscore=0 adultscore=0
 clxscore=1015 impostorscore=0 mlxscore=0 mlxlogscore=999 phishscore=0
 suspectscore=0 bulkscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.12.0-2104190000 definitions=main-2107260067

Thank you for your comments.

On 22/07/21 8:52 pm, Eric W. Biederman wrote:
> As stated I think this idea is a non-starter.
>
> There is a real problem that there are applications that have a
> legitimate need to know what cpu resources are available for them to use
> and we don't have a good interfaces for them to request that
> information.
>
> I think MESOS solved this by passing a MAX_CPUS environment variable,
> and at least the JVM was modified to use that variable.
>
> That said as situations can be a bit more dynamic and fluid having
> something where an application can look and see what resources are
> available from it's view of the world seems reasonable.
>
> AKA we need something so applications can stop conflating physical
> cpu resources that are available with cpu resources that are allowed
> to be used in an application.
>
> This might be as simple as implementing a /proc/self/cpus_available
> file.
>
> Without the will to go through find existing open source applications
> that care and update them so that they will use the new interface I
> don't think anything will really happen.

 From a process granular point of view I believe a /proc/self approach solves
this problem at root. However, as you have stated too; applications will now
have to look at another interface for the correct information and that could
potentially be a challenge.

>
> The problem I see with changing existing interfaces that describe the
> hardware is that the definition becomes unclear and so different
> applications can legitimately expect different things, and it would
> become impossible to implement what is needed correctly.

In our experimentation and survey we found out that container applications which
were restricted based on a cgroup restriction - both cpuset or period/quota
benefited from coherent information. That was also my understanding with the
usage of tools like LXCFS in the userspace.

Would you happen to know if there are any applications that expect the full
hardware/topology view even though it itself is restricted in its usage?

>
> The problem I see with using cgroup interfaces is that they are not
> targeted at end user applications and but rather are targeted at the
> problem of controlling access to a resource.  Using them report what is
> available again gets you into the multiple master problem.  Especially
> as cgroups may not be the only thing in the system controlling access to
> your resource.

I agree, cgroup is a control interface and should not be used for presenting of
information and cgroups may not be the only thing in the system controlling
access to the resources.

This is where the idea for a different interface really stemmed from.
That although there are mechanisms to restrict and control usage, there is no
interface that presents information coherently to the userspace

> So I really think the only good solution that people won't mind is to go
> through the applications figure out what information is legitimately
> needed from an application perspective, and build an interface tailored
> for applications to get that information.
>
> Then applications can be updated to use the new interface, and as the
> implementation of the system changes the implementation in the kernel
> can be updated to keep the applications working.

I concur with this approach to build an application first interface.

My current frame of reference for the problems come from tools like LXCFS which
are built around the existing interfaces to present information and the
experiments were designed to quantify those shortcomings.
We could definitely use some help in understanding the shortcomings of the
current interfaces from people who use these applications.

--
Pratik

> Eric

