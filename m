Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 26CDA2C9C
	for <containers@lists.linux.dev>; Thu, 10 Feb 2022 12:03:48 +0000 (UTC)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.1.2/8.16.1.2) with SMTP id 21A9GrcA003482;
	Thu, 10 Feb 2022 12:03:39 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ibm.com; h=message-id : subject :
 from : to : cc : date : in-reply-to : references : content-type :
 mime-version : content-transfer-encoding; s=pp1;
 bh=p+BE6Y6sJrfRGA0AJBWVlskZdaJxi0BEOlEnAHgtAKo=;
 b=fI0QNIrvTv6agAKFZY+cfCipuBuiEggpCB8n0QdzHocmvYEKojaSE45HoCVRpArfrRmK
 V84v0sZ96pYdXBp3zt2NgTfFz7XrTJSQqL2S/jsyA37Jfj393digFfihdyMU3pr7k6/M
 jMmgP2loGD5hETTzpfTlfuknMeE4Rc+OUifd/d8YyZqxXZp2FiMWmyYaLXEap6hi8106
 Sex68AqLvtBBNdcdnpMq/oanDOj+m95NNcilAtOFN+PtPlNaEPU/46UwxQQBz+w5W3yd
 NjUwp0Ve6gIILSWLyX+LOXoksrN8bTNLeGqsXVKxGnQo+WGjQKOZtkRjf4cNDceYmOwN FQ== 
Received: from pps.reinject (localhost [127.0.0.1])
	by mx0b-001b2d01.pphosted.com with ESMTP id 3e4m9892wp-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 10 Feb 2022 12:03:39 +0000
Received: from m0098413.ppops.net (m0098413.ppops.net [127.0.0.1])
	by pps.reinject (8.16.0.43/8.16.0.43) with SMTP id 21ABrXrj017771;
	Thu, 10 Feb 2022 12:03:38 GMT
Received: from ppma03ams.nl.ibm.com (62.31.33a9.ip4.static.sl-reverse.com [169.51.49.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 3e4m9892vx-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 10 Feb 2022 12:03:38 +0000
Received: from pps.filterd (ppma03ams.nl.ibm.com [127.0.0.1])
	by ppma03ams.nl.ibm.com (8.16.1.2/8.16.1.2) with SMTP id 21ABgYLF016889;
	Thu, 10 Feb 2022 12:03:36 GMT
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by ppma03ams.nl.ibm.com with ESMTP id 3e1gv9ykqw-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 10 Feb 2022 12:03:36 +0000
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id 21AC3Vrm38797672
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 10 Feb 2022 12:03:31 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 4CF94A4051;
	Thu, 10 Feb 2022 12:03:31 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B2BC9A405D;
	Thu, 10 Feb 2022 12:03:28 +0000 (GMT)
Received: from sig-9-65-78-200.ibm.com (unknown [9.65.78.200])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Thu, 10 Feb 2022 12:03:28 +0000 (GMT)
Message-ID: <39ec72c0776f67c89fc80a0305c75ec4290590ae.camel@linux.ibm.com>
Subject: Re: [PATCH v10 04/27] securityfs: rework dentry creation
From: Mimi Zohar <zohar@linux.ibm.com>
To: Stefan Berger <stefanb@linux.ibm.com>, linux-integrity@vger.kernel.org
Cc: serge@hallyn.com, containers@lists.linux.dev, dmitry.kasatkin@gmail.com,
        ebiederm@xmission.com, krzysztof.struczynski@huawei.com,
        roberto.sassu@huawei.com, mpeters@redhat.com, lhinds@redhat.com,
        lsturman@redhat.com, puiterwi@redhat.com, jejb@linux.ibm.com,
        jamjoom@us.ibm.com, linux-kernel@vger.kernel.org, paul@paul-moore.com,
        rgb@redhat.com, linux-security-module@vger.kernel.org,
        jmorris@namei.org, Christian Brauner <brauner@kernel.org>,
        John Johansen
 <john.johansen@canonical.com>,
        Matthew Garrett <mjg59@srcf.ucam.org>,
        Micah
 Morton <mortonm@chromium.org>,
        Kentaro Takeda <takedakn@nttdata.co.jp>
Date: Thu, 10 Feb 2022 07:03:28 -0500
In-Reply-To: <20220201203735.164593-5-stefanb@linux.ibm.com>
References: <20220201203735.164593-1-stefanb@linux.ibm.com>
	 <20220201203735.164593-5-stefanb@linux.ibm.com>
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
X-Proofpoint-ORIG-GUID: GDSRi3shqM6Q_rqBG1jTy-54l4DqTi2n
X-Proofpoint-GUID: y1yXODbJN_CINniHtnKSINPce3QR-Aof
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.205,Aquarius:18.0.816,Hydra:6.0.425,FMLib:17.11.62.513
 definitions=2022-02-10_03,2022-02-09_01,2021-12-02_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 malwarescore=0 mlxscore=0
 spamscore=0 suspectscore=0 adultscore=0 clxscore=1011 impostorscore=0
 priorityscore=1501 bulkscore=0 lowpriorityscore=0 phishscore=0
 mlxlogscore=999 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.12.0-2201110000 definitions=main-2202100066

[Cc'ing JJ, Matthew, Micah, Kentaro, Casey - maintainers of securityfs
usages, not already cc'ed]

On Tue, 2022-02-01 at 15:37 -0500, Stefan Berger wrote:
> From: Christian Brauner <brauner@kernel.org>
> 
> When securityfs creates a new file or directory via
> securityfs_create_dentry() it will take an additional reference on the
> newly created dentry after it has attached the new inode to the new
> dentry and added it to the hashqueues.
> If we contrast this with debugfs which has the same underlying logic as
> securityfs. It uses a similar pairing as securityfs. Where securityfs
> has the securityfs_create_dentry() and securityfs_remove() pairing,
> debugfs has the __debugfs_create_file() and debugfs_remove() pairing.
> 
> In contrast to securityfs, debugfs doesn't take an additional reference
> on the newly created dentry in __debugfs_create_file() which would need
> to be put in debugfs_remove().
> 
> The additional dget() isn't a problem per se. In the current
> implementation of securityfs each created dentry pins the filesystem via
> until it is removed. Since it is virtually guaranteed that there is at
> least one user of securityfs that has created dentries the initial
> securityfs mount cannot go away until all dentries have been removed.
> 
> Since most of the users of the initial securityfs mount don't go away
> until the system is shutdown the initial securityfs won't go away when
> unmounted. Instead a mount will usually surface the same superblock as
> before. The additional dget() doesn't matter in this scenario since it
> is required that all dentries have been cleaned up by the respective
> users before the superblock can be destroyed, i.e. superblock shutdown
> is tied to the lifetime of the associated dentries.
> 
> However, in order to support ima namespaces we need to extend securityfs
> to support being mounted outside of the initial user namespace. For
> namespaced users the pinning logic doesn't make sense. Whereas in the
> initial namespace the securityfs instance and the associated data
> structures of its users can't go away for reason explained earlier users
> of non-initial securityfs instances do go away when the last users of
> the namespace are gone.
> 
> So for those users we neither want to duplicate the pinning logic nor
> make the global securityfs instance display different information based
> on the namespace. Both options would be really messy and hacky.
> 
> Instead we will simply give each namespace its own securityfs instance
> similar to how each ipc namespace has its own mqueue instance and all
> entries in there are cleaned up on umount or when the last user of the
> associated namespace is gone.
> 
> This means that the superblock's lifetime isn't tied to the dentries.
> Instead the last umount, without any fds kept open, will trigger a clean
> shutdown. But now the additional dget() gets in the way. Instead of
> being able to rely on the generic superblock shutdown logic we would
> need to drop the additional dentry reference during superblock shutdown
> for all associated users. That would force the use of a generic
> coordination mechanism for current and future users of securityfs which
> is unnecessary. Simply remove the additional dget() in
> securityfs_dentry_create().
> 
> In securityfs_remove() we will call dget() to take an additional
> reference on the dentry about to be removed. After simple_unlink() or
> simple_rmdir() have dropped the dentry refcount we can call d_delete()
> which will either turn the dentry into negative dentry if our earlier
> dget() is the only reference to the dentry, i.e. it has no other users,
> or remove it from the hashqueues in case there are additional users.
> 
> All of these changes should not have any effect on the userspace
> semantics of the initial securityfs mount.
> 
> Signed-off-by: Christian Brauner <brauner@kernel.org>

Thanks, Christian, Stefan.

Reviewed-by: Mimi Zohar <zohar@linux.ibm.com>

This change is really independent of the IMA namespacing.  Based on
Greg's request of unification of where platform specific
variables/keys/etc are stored, the consensus so far seems to be
'securityfs/secrets'.  Although this patch isn't a bug fix, let's try
and get this upstreamed.

The current securityfs usages are apparmor, lockdown, safesetid,
tomoyo, core LSM ("security/lsm"), and the TPM.

Only on failure to create securityfs files or directories, are
previously created securityfs files/directories removed.  The one
exception seems to be the TPM, which may be built as a kernel module.

-- 
thanks,

Mimi

