Received: from mga18.intel.com (mga18.intel.com [134.134.136.126])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 568BF2F21
	for <containers@lists.linux.dev>; Wed,  2 Feb 2022 13:20:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1643808017; x=1675344017;
  h=date:from:to:cc:subject:message-id:references:
   mime-version:in-reply-to;
  bh=1y/I8+Cwv/D7OTbXUo7gXNUyyzvhMDlcTuYRYcNTGzM=;
  b=bG6Da/wahMNygY/8EIHPAPClrm4Z4EOu5BW36wNLry/WGfy4VHeg8axf
   V/fYtOqO/59tVAE+U1EWu0+9b/bvSGIzzaAOdww6CpjYRTyyzaAGVPA8M
   T+28hakTsvUfueYu6OZY2w8LjHxy2ZUXeQsNfYVkpXxAqY3G+ccZeRSdW
   ATKDZ9sfU+p/j4enxDLSRaZCXtiMKVnJ7/fPy2Xo+VdZMNEEqD92xoTmp
   BT8Z9rYIaVSm2haduEOdt5tosSc2s2pqyCuu/A66m+h+2AlncE6ByOCH5
   kFZQIDBCQ6JdXAEQtNS5+sz1Dko3cg5c7svcHEbJEQIatdiVKL+0s4AP9
   g==;
X-IronPort-AV: E=McAfee;i="6200,9189,10245"; a="231481696"
X-IronPort-AV: E=Sophos;i="5.88,336,1635231600"; 
   d="scan'208";a="231481696"
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by orsmga106.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 02 Feb 2022 05:20:00 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.88,336,1635231600"; 
   d="scan'208";a="599556250"
Received: from lkp-server01.sh.intel.com (HELO 276f1b88eecb) ([10.239.97.150])
  by fmsmga004.fm.intel.com with ESMTP; 02 Feb 2022 05:19:58 -0800
Received: from kbuild by 276f1b88eecb with local (Exim 4.92)
	(envelope-from <lkp@intel.com>)
	id 1nFFYD-000Ucm-ET; Wed, 02 Feb 2022 13:19:57 +0000
Date: Wed, 2 Feb 2022 21:19:53 +0800
From: kernel test robot <lkp@intel.com>
To: Stefan Berger <stefanb@linux.ibm.com>, linux-integrity@vger.kernel.org
Cc: kbuild-all@lists.01.org, zohar@linux.ibm.com, serge@hallyn.com,
	christian.brauner@ubuntu.com, containers@lists.linux.dev,
	dmitry.kasatkin@gmail.com, ebiederm@xmission.com,
	krzysztof.struczynski@huawei.com, roberto.sassu@huawei.com,
	mpeters@redhat.com
Subject: Re: [PATCH v10 15/27] ima: Implement hierarchical processing of file
 accesses
Message-ID: <202202022159.CBH5XW23-lkp@intel.com>
References: <20220201203735.164593-16-stefanb@linux.ibm.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20220201203735.164593-16-stefanb@linux.ibm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)

Hi Stefan,

Thank you for the patch! Perhaps something to improve:

[auto build test WARNING on v5.16]
[cannot apply to zohar-integrity/next-integrity linux/master linus/master jmorris-security/next-testing v5.17-rc2 v5.17-rc1 next-20220202]
[If your patch is applied to the wrong git tree, kindly drop us a note.
And when submitting patch, we suggest to use '--base' as documented in
https://git-scm.com/docs/git-format-patch]

url:    https://github.com/0day-ci/linux/commits/Stefan-Berger/ima-Namespace-IMA-with-audit-support-in-IMA-ns/20220202-044058
base:    df0cc57e057f18e44dac8e6c18aba47ab53202f9
config: x86_64-randconfig-c003-20220131 (https://download.01.org/0day-ci/archive/20220202/202202022159.CBH5XW23-lkp@intel.com/config)
compiler: gcc-9 (Debian 9.3.0-22) 9.3.0

If you fix the issue, kindly add following tag as appropriate
Reported-by: kernel test robot <lkp@intel.com>


cocci warnings: (new ones prefixed by >>)
>> security/integrity/ima/ima_main.c:424:2-3: Unneeded semicolon

Please review and possibly fold the followup patch.

---
0-DAY CI Kernel Test Service, Intel Corporation
https://lists.01.org/hyperkitty/list/kbuild-all@lists.01.org
