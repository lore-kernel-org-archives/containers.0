Received: from mga05.intel.com (mga05.intel.com [192.55.52.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 81EC2173
	for <containers@lists.linux.dev>; Fri, 17 Dec 2021 16:30:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1639758623; x=1671294623;
  h=date:from:to:cc:subject:message-id:references:
   mime-version:in-reply-to;
  bh=hJxvFXlqstxE0A6tB6h1DuKJXHT/CIYN0MSb8KW7MYw=;
  b=Xo3j4stz+gVAM6U0fOoPlNSksJGsG1/YvFHbhxPLc1e2+7vm+u6/Uk9G
   BrcIiFpRsEWeJ2dvNvBmtO5IzxwTkwF/Q7rDwA5I4+8m0/2zkcPykXfX7
   Te/hNTPxKSl/YGBvfUux9ufpjpOx13ijopOI9chYS6i3MLuLt0AEbB7QO
   hGH9F8dsJc8bv0iUhe6oByGOCmIToIXFaTWA6RVNpD+LNUQv8zHPlh++x
   k1k0GtTp+ECzbnFeL8aUZKMOZ7xAMGwHD3vCyPNYfCM9ZIiIWftVGilY4
   y2Tw9j2pkiAutaYGXYczEeD+6b1wvzc06ihKVLLfP+Wy/iX4zxQTTNfCs
   w==;
X-IronPort-AV: E=McAfee;i="6200,9189,10201"; a="326074828"
X-IronPort-AV: E=Sophos;i="5.88,213,1635231600"; 
   d="scan'208";a="326074828"
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga105.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 17 Dec 2021 08:30:22 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.88,213,1635231600"; 
   d="scan'208";a="683439808"
Received: from lkp-server02.sh.intel.com (HELO 9f38c0981d9f) ([10.239.97.151])
  by orsmga005.jf.intel.com with ESMTP; 17 Dec 2021 08:30:19 -0800
Received: from kbuild by 9f38c0981d9f with local (Exim 4.92)
	(envelope-from <lkp@intel.com>)
	id 1myG7e-0004vk-Py; Fri, 17 Dec 2021 16:30:18 +0000
Date: Sat, 18 Dec 2021 00:29:27 +0800
From: kernel test robot <lkp@intel.com>
To: Stefan Berger <stefanb@linux.vnet.ibm.com>,
	linux-integrity@vger.kernel.org
Cc: kbuild-all@lists.01.org, zohar@linux.ibm.com, serge@hallyn.com,
	christian.brauner@ubuntu.com, containers@lists.linux.dev,
	dmitry.kasatkin@gmail.com, ebiederm@xmission.com,
	krzysztof.struczynski@huawei.com, roberto.sassu@huawei.com,
	mpeters@redhat.com
Subject: Re: [PATCH v7 10/14] securityfs: Extend securityfs with namespacing
 support
Message-ID: <202112180002.CNO8riQv-lkp@intel.com>
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
User-Agent: Mutt/1.10.1 (2018-07-13)

Hi Stefan,

Thank you for the patch! Perhaps something to improve:

[auto build test WARNING on zohar-integrity/next-integrity]
[also build test WARNING on linux/master linus/master v5.16-rc5]
[cannot apply to jmorris-security/next-testing next-20211217]
[If your patch is applied to the wrong git tree, kindly drop us a note.
And when submitting patch, we suggest to use '--base' as documented in
https://git-scm.com/docs/git-format-patch]

url:    https://github.com/0day-ci/linux/commits/Stefan-Berger/ima-Namespace-IMA-with-audit-support-in-IMA-ns/20211216-134611
base:   https://git.kernel.org/pub/scm/linux/kernel/git/zohar/linux-integrity.git next-integrity
config: i386-randconfig-s002-20211216 (https://download.01.org/0day-ci/archive/20211218/202112180002.CNO8riQv-lkp@intel.com/config)
compiler: gcc-9 (Debian 9.3.0-22) 9.3.0
reproduce:
        # apt-get install sparse
        # sparse version: v0.6.4-dirty
        # https://github.com/0day-ci/linux/commit/fac0e082272f4058a9a9b27762fbf9cecca8772b
        git remote add linux-review https://github.com/0day-ci/linux
        git fetch --no-tags linux-review Stefan-Berger/ima-Namespace-IMA-with-audit-support-in-IMA-ns/20211216-134611
        git checkout fac0e082272f4058a9a9b27762fbf9cecca8772b
        # save the config file to linux build tree
        mkdir build_dir
        make W=1 C=1 CF='-fdiagnostic-prefix -D__CHECK_ENDIAN__' O=build_dir ARCH=i386 SHELL=/bin/bash

If you fix the issue, kindly add following tag as appropriate
Reported-by: kernel test robot <lkp@intel.com>


sparse warnings: (new ones prefixed by >>)
>> security/inode.c:43:31: sparse: sparse: symbol 'securityfs_dir_inode_operations' was not declared. Should it be static?
>> security/inode.c:48:31: sparse: sparse: symbol 'securityfs_file_inode_operations' was not declared. Should it be static?

Please review and possibly fold the followup patch.

---
0-DAY CI Kernel Test Service, Intel Corporation
https://lists.01.org/hyperkitty/list/kbuild-all@lists.01.org
