Received: from mga07.intel.com (mga07.intel.com [134.134.136.100])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CAE4C168
	for <containers@lists.linux.dev>; Fri, 17 Dec 2021 16:22:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1639758143; x=1671294143;
  h=date:from:to:cc:subject:message-id:references:
   mime-version:in-reply-to;
  bh=wNBGXF/gVIsUUSL+KA7+A18FBMlEr0hXyOuboGlwIto=;
  b=lBCmQ1n6un+8DPm9qVVSe9PYhp7B4JHIcbOeUGoLFN/UIE1mvZDUt7Gh
   e3vMlIX4Z+X4Qs+x0MBDp5U5KGGU9fBbcFsSpcsxaKI19ugijep9CGj65
   D0olKlOHZdFR1Qf+p3qqIu7CGkrcz72FzlB5Id4dMJHJLFJj6ZAaVrxHi
   sJT9/w9gXbWsdCr5fqpSUo3RygidNpCumNve059IQBvxPuGplYZQ9vrFV
   TYbyilcvC0JUP/pi65GD+14SJtq55sJatBl4affbqmjZ2QLgU08aQH2wV
   fF6ifDlTTMZ+NtBiNEWANqXFPqTUTIOmUbRN1AqSPTEkpdugGfigimZAy
   Q==;
X-IronPort-AV: E=McAfee;i="6200,9189,10201"; a="303157553"
X-IronPort-AV: E=Sophos;i="5.88,213,1635231600"; 
   d="scan'208";a="303157553"
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga105.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 17 Dec 2021 08:22:22 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.88,213,1635231600"; 
   d="scan'208";a="756518301"
Received: from lkp-server02.sh.intel.com (HELO 9f38c0981d9f) ([10.239.97.151])
  by fmsmga005.fm.intel.com with ESMTP; 17 Dec 2021 08:22:19 -0800
Received: from kbuild by 9f38c0981d9f with local (Exim 4.92)
	(envelope-from <lkp@intel.com>)
	id 1myFzu-0004v1-FF; Fri, 17 Dec 2021 16:22:18 +0000
Date: Sat, 18 Dec 2021 00:21:35 +0800
From: kernel test robot <lkp@intel.com>
To: Stefan Berger <stefanb@linux.vnet.ibm.com>,
	linux-integrity@vger.kernel.org
Cc: kbuild-all@lists.01.org, zohar@linux.ibm.com, serge@hallyn.com,
	christian.brauner@ubuntu.com, containers@lists.linux.dev,
	dmitry.kasatkin@gmail.com, ebiederm@xmission.com,
	krzysztof.struczynski@huawei.com, roberto.sassu@huawei.com,
	mpeters@redhat.com
Subject: [RFC PATCH] securityfs: securityfs_dir_inode_operations can be static
Message-ID: <20211217162135.GA21682@93035147186e>
References: <20211216054323.1707384-11-stefanb@linux.vnet.ibm.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20211216054323.1707384-11-stefanb@linux.vnet.ibm.com>
X-Patchwork-Hint: ignore
User-Agent: Mutt/1.10.1 (2018-07-13)

security/inode.c:43:31: warning: symbol 'securityfs_dir_inode_operations' was not declared. Should it be static?
security/inode.c:48:31: warning: symbol 'securityfs_file_inode_operations' was not declared. Should it be static?

Reported-by: kernel test robot <lkp@intel.com>
Signed-off-by: kernel test robot <lkp@intel.com>
---
 inode.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/security/inode.c b/security/inode.c
index a0d9f086e3d54..ff720c6bedb0a 100644
--- a/security/inode.c
+++ b/security/inode.c
@@ -40,12 +40,12 @@ static int securityfs_permission(struct user_namespace *mnt_userns,
 	return err;
 }
 
-const struct inode_operations securityfs_dir_inode_operations = {
+static const struct inode_operations securityfs_dir_inode_operations = {
 	.permission	= securityfs_permission,
 	.lookup		= simple_lookup,
 };
 
-const struct inode_operations securityfs_file_inode_operations = {
+static const struct inode_operations securityfs_file_inode_operations = {
 	.permission	= securityfs_permission,
 };
 
