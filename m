Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C3B922F38
	for <containers@lists.linux.dev>; Tue,  1 Feb 2022 20:38:13 +0000 (UTC)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.1.2/8.16.1.2) with SMTP id 211Js69b031070;
	Tue, 1 Feb 2022 20:37:52 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ibm.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=pp1;
 bh=Z61o7XFNtLtEoY0IRwR7hf+c1pRZ1yg1bG/PraBIWHc=;
 b=W3hf6tz3UQY8BjnY/rm0RslrZvTs5LTGewmv2Uj1Y5MBtWBL9EMXUNem817w5Coirq/S
 Uzbs2qHRg1HvGk261zHG+D27k4j+HeGmbj9fwk5Rh/rLhAJCv/jwtQ8pLdh/lYtw8G9J
 zI5cd8Zkit+Syu25iBSPjv1+QkwRKJ3CoMfS4lgk7AiUe8usZ0N5xL/Q/tBn4xsEJ0mj
 hL5Jlge/+SvHJRvKKFPbc81VrD2O98G8wLcR7MTkpuz2jSi5L8K1vtgQaGZQLB1jHsWR
 3+jkhFwmpweK3MhfY4pCBbh0DH6aD3whAcDmvKV3yN2HdcbSkc3WRBzUJC5FEGuP1bQU KQ== 
Received: from pps.reinject (localhost [127.0.0.1])
	by mx0b-001b2d01.pphosted.com with ESMTP id 3dybe58pvy-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Tue, 01 Feb 2022 20:37:52 +0000
Received: from m0098414.ppops.net (m0098414.ppops.net [127.0.0.1])
	by pps.reinject (8.16.0.43/8.16.0.43) with SMTP id 211KLph7024770;
	Tue, 1 Feb 2022 20:37:51 GMT
Received: from ppma03dal.us.ibm.com (b.bd.3ea9.ip4.static.sl-reverse.com [169.62.189.11])
	by mx0b-001b2d01.pphosted.com with ESMTP id 3dybe58pvt-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Tue, 01 Feb 2022 20:37:51 +0000
Received: from pps.filterd (ppma03dal.us.ibm.com [127.0.0.1])
	by ppma03dal.us.ibm.com (8.16.1.2/8.16.1.2) with SMTP id 211KWMRd028009;
	Tue, 1 Feb 2022 20:37:50 GMT
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
	by ppma03dal.us.ibm.com with ESMTP id 3dy0swgmm0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Tue, 01 Feb 2022 20:37:50 +0000
Received: from b01ledav003.gho.pok.ibm.com (b01ledav003.gho.pok.ibm.com [9.57.199.108])
	by b01cxnp22033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id 211KbnAS14746100
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 1 Feb 2022 20:37:49 GMT
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 56886B205F;
	Tue,  1 Feb 2022 20:37:49 +0000 (GMT)
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 3A789B206B;
	Tue,  1 Feb 2022 20:37:49 +0000 (GMT)
Received: from sbct-3.pok.ibm.com (unknown [9.47.158.153])
	by b01ledav003.gho.pok.ibm.com (Postfix) with ESMTP;
	Tue,  1 Feb 2022 20:37:49 +0000 (GMT)
From: Stefan Berger <stefanb@linux.ibm.com>
To: linux-integrity@vger.kernel.org
Cc: zohar@linux.ibm.com, serge@hallyn.com, christian.brauner@ubuntu.com,
        containers@lists.linux.dev, dmitry.kasatkin@gmail.com,
        ebiederm@xmission.com, krzysztof.struczynski@huawei.com,
        roberto.sassu@huawei.com, mpeters@redhat.com, lhinds@redhat.com,
        lsturman@redhat.com, puiterwi@redhat.com, jejb@linux.ibm.com,
        jamjoom@us.ibm.com, linux-kernel@vger.kernel.org, paul@paul-moore.com,
        rgb@redhat.com, linux-security-module@vger.kernel.org,
        jmorris@namei.org, Stefan Berger <stefanb@linux.ibm.com>
Subject: [PATCH v10 02/27] ima: Do not print policy rule with inactive LSM labels
Date: Tue,  1 Feb 2022 15:37:10 -0500
Message-Id: <20220201203735.164593-3-stefanb@linux.ibm.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20220201203735.164593-1-stefanb@linux.ibm.com>
References: <20220201203735.164593-1-stefanb@linux.ibm.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
X-Proofpoint-GUID: WrZdQUFmuUGFFjnwdNXFBN21dRdeGRZo
X-Proofpoint-ORIG-GUID: WIxt4MwYIU1MqaZQa24XpHhQskfp8ZFp
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.205,Aquarius:18.0.816,Hydra:6.0.425,FMLib:17.11.62.513
 definitions=2022-02-01_09,2022-02-01_01,2021-12-02_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 impostorscore=0
 suspectscore=0 priorityscore=1501 malwarescore=0 lowpriorityscore=0
 mlxscore=0 adultscore=0 spamscore=0 bulkscore=0 phishscore=0 clxscore=1015
 mlxlogscore=999 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.12.0-2201110000 definitions=main-2202010114

Before printing a policy rule scan for inactive LSM labels in the policy
rule. Inactive LSM labels are identified by args_p != NULL and
rule == NULL.

Fixes: b16942455193 ("ima: use the lsm policy update notifier")
Signed-off-by: Stefan Berger <stefanb@linux.ibm.com>
---
 security/integrity/ima/ima_policy.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/security/integrity/ima/ima_policy.c b/security/integrity/ima/ima_policy.c
index 320ca80aacab..2a1f6418b10a 100644
--- a/security/integrity/ima/ima_policy.c
+++ b/security/integrity/ima/ima_policy.c
@@ -1967,6 +1967,14 @@ int ima_policy_show(struct seq_file *m, void *v)
 
 	rcu_read_lock();
 
+	/* Do not print rules with inactive LSM labels */
+	for (i = 0; i < MAX_LSM_RULES; i++) {
+		if (entry->lsm[i].args_p && !entry->lsm[i].rule) {
+			rcu_read_unlock();
+			return 0;
+		}
+	}
+
 	if (entry->action & MEASURE)
 		seq_puts(m, pt(Opt_measure));
 	if (entry->action & DONT_MEASURE)
-- 
2.31.1

