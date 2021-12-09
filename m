Received: from frasgout.his.huawei.com (frasgout.his.huawei.com [185.176.79.56])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 42C42173
	for <containers@lists.linux.dev>; Thu,  9 Dec 2021 08:09:24 +0000 (UTC)
Received: from fraeml743-chm.china.huawei.com (unknown [172.18.147.206])
	by frasgout.his.huawei.com (SkyGuard) with ESMTP id 4J8mmL3cVhz685x5;
	Thu,  9 Dec 2021 16:05:06 +0800 (CST)
Received: from lhreml732-chm.china.huawei.com (10.201.108.83) by
 fraeml743-chm.china.huawei.com (10.206.15.224) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.2308.20; Thu, 9 Dec 2021 09:09:21 +0100
Received: from lhreml738-chm.china.huawei.com (10.201.108.188) by
 lhreml732-chm.china.huawei.com (10.201.108.83) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.2308.20; Thu, 9 Dec 2021 08:09:20 +0000
Received: from lhreml738-chm.china.huawei.com ([10.201.108.188]) by
 lhreml738-chm.china.huawei.com ([10.201.108.188]) with mapi id
 15.01.2308.020; Thu, 9 Dec 2021 08:09:20 +0000
From: Denis Semakin <denis.semakin@huawei.com>
To: Stefan Berger <stefanb@linux.ibm.com>, "linux-integrity@vger.kernel.org"
	<linux-integrity@vger.kernel.org>
CC: "zohar@linux.ibm.com" <zohar@linux.ibm.com>, "serge@hallyn.com"
	<serge@hallyn.com>, "christian.brauner@ubuntu.com"
	<christian.brauner@ubuntu.com>, "containers@lists.linux.dev"
	<containers@lists.linux.dev>, "dmitry.kasatkin@gmail.com"
	<dmitry.kasatkin@gmail.com>, "ebiederm@xmission.com" <ebiederm@xmission.com>,
	Krzysztof Struczynski <krzysztof.struczynski@huawei.com>, Roberto Sassu
	<roberto.sassu@huawei.com>, "mpeters@redhat.com" <mpeters@redhat.com>,
	"lhinds@redhat.com" <lhinds@redhat.com>, "lsturman@redhat.com"
	<lsturman@redhat.com>, "puiterwi@redhat.com" <puiterwi@redhat.com>,
	"jejb@linux.ibm.com" <jejb@linux.ibm.com>, "jamjoom@us.ibm.com"
	<jamjoom@us.ibm.com>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "paul@paul-moore.com" <paul@paul-moore.com>,
	"rgb@redhat.com" <rgb@redhat.com>, "linux-security-module@vger.kernel.org"
	<linux-security-module@vger.kernel.org>, "jmorris@namei.org"
	<jmorris@namei.org>
Subject: RE: [PATCH v5 14/16] ima: Use mac_admin_ns_capable() to check
 corresponding capability
Thread-Topic: [PATCH v5 14/16] ima: Use mac_admin_ns_capable() to check
 corresponding capability
Thread-Index: AQHX7IGL3eM2VvpvvUagKdVUk4BPk6wpv2mAgAAOKDA=
Date: Thu, 9 Dec 2021 08:09:20 +0000
Message-ID: <cde301002f884f43bcb7fa244b1c6b84@huawei.com>
References: <20211208221818.1519628-1-stefanb@linux.ibm.com>
 <20211208221818.1519628-15-stefanb@linux.ibm.com> 
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.122.133.14]
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
X-CFilter-Loop: Reflected

Following that thoughts...
Will it be so incorrectly to unbound IMA-ns from USER-ns?
I realize that it could lead a lot of problems but it is still unclear will=
 current IMA-ns will be useful for Kuber...
How userland supposed to use current IMA-ns implementation?

Br,
Denis

-----Original Message-----
From: Denis Semakin=20
Sent: Thursday, December 9, 2021 10:22 AM
To: 'Stefan Berger' <stefanb@linux.ibm.com>; linux-integrity@vger.kernel.or=
g
Cc: zohar@linux.ibm.com; serge@hallyn.com; christian.brauner@ubuntu.com; co=
ntainers@lists.linux.dev; dmitry.kasatkin@gmail.com; ebiederm@xmission.com;=
 Krzysztof Struczynski <krzysztof.struczynski@huawei.com>; Roberto Sassu <r=
oberto.sassu@huawei.com>; mpeters@redhat.com; lhinds@redhat.com; lsturman@r=
edhat.com; puiterwi@redhat.com; jejb@linux.ibm.com; jamjoom@us.ibm.com; lin=
ux-kernel@vger.kernel.org; paul@paul-moore.com; rgb@redhat.com; linux-secur=
ity-module@vger.kernel.org; jmorris@namei.org
Subject: RE: [PATCH v5 14/16] ima: Use mac_admin_ns_capable() to check corr=
esponding capability

Hi.=20
My question won't be about capabilities. I'm wondering how IMA-ns which is =
associated with USER-ns and is created during USER-ns creation would be use=
d by some namespaces orchestration systems, e.g. Kubernetes?.. It seems tha=
t it can be run without any user namespaces...=20
Their community just discuss this opportunity to support User namespaces. (=
see https://github.com/kubernetes/enhancements/pull/2101)
Looks like currently IMA-ns will not be applicable for Kubernetes.

Br,
Denis

-----Original Message-----
From: Stefan Berger [mailto:stefanb@linux.ibm.com]
Sent: Thursday, December 9, 2021 1:18 AM
To: linux-integrity@vger.kernel.org
Cc: zohar@linux.ibm.com; serge@hallyn.com; christian.brauner@ubuntu.com; co=
ntainers@lists.linux.dev; dmitry.kasatkin@gmail.com; ebiederm@xmission.com;=
 Krzysztof Struczynski <krzysztof.struczynski@huawei.com>; Roberto Sassu <r=
oberto.sassu@huawei.com>; mpeters@redhat.com; lhinds@redhat.com; lsturman@r=
edhat.com; puiterwi@redhat.com; jejb@linux.ibm.com; jamjoom@us.ibm.com; lin=
ux-kernel@vger.kernel.org; paul@paul-moore.com; rgb@redhat.com; linux-secur=
ity-module@vger.kernel.org; jmorris@namei.org; Stefan Berger <stefanb@linux=
.ibm.com>; Denis Semakin <denis.semakin@huawei.com>
Subject: [PATCH v5 14/16] ima: Use mac_admin_ns_capable() to check correspo=
nding capability

Use mac_admin_ns_capable() to check corresponding capability to allow read/=
write IMA policy without CAP_SYS_ADMIN but with CAP_MAC_ADMIN.

Signed-off-by: Denis Semakin <denis.semakin@huawei.com>
Signed-off-by: Stefan Berger <stefanb@linux.ibm.com>
---
 include/linux/capability.h      | 6 ++++++
 security/integrity/ima/ima_fs.c | 2 +-
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/linux/capability.h b/include/linux/capability.h index =
65efb74c3585..991579178f32 100644
--- a/include/linux/capability.h
+++ b/include/linux/capability.h
@@ -270,6 +270,12 @@ static inline bool checkpoint_restore_ns_capable(struc=
t user_namespace *ns)
 		ns_capable(ns, CAP_SYS_ADMIN);
 }
=20
+static inline bool mac_admin_ns_capable(struct user_namespace *ns) {
+	return ns_capable(ns, CAP_MAC_ADMIN) ||
+		ns_capable(ns, CAP_SYS_ADMIN);
+}
+
 /* audit system wants to get cap info from files as well */  int get_vfs_c=
aps_from_disk(struct user_namespace *mnt_userns,
 			   const struct dentry *dentry,
diff --git a/security/integrity/ima/ima_fs.c b/security/integrity/ima/ima_f=
s.c index 0e582ceecc7f..a749a3e79304 100644
--- a/security/integrity/ima/ima_fs.c
+++ b/security/integrity/ima/ima_fs.c
@@ -394,7 +394,7 @@ static int ima_open_policy(struct inode *inode, struct =
file *filp)  #else
 		if ((filp->f_flags & O_ACCMODE) !=3D O_RDONLY)
 			return -EACCES;
-		if (!capable(CAP_SYS_ADMIN))
+		if (!mac_admin_ns_capable(ns->user_ns))
 			return -EPERM;
 		return seq_open(filp, &ima_policy_seqops);  #endif
--
2.31.1

