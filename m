Received: from mga05.intel.com (mga05.intel.com [192.55.52.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 548C62C9E;
	Thu,  9 Dec 2021 10:57:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1639047448; x=1670583448;
  h=date:from:to:cc:subject:message-id:references:
   mime-version:in-reply-to;
  bh=cKo9r0ZgFuFsQ9Ajq9lc/X0NQStJ7P9DNUg5Lfqrf+o=;
  b=T434XDqRz9t3bv4OoUJZiJ47WVcZZWqqCd81L0CCHlL+mswmhelpOYPz
   4OpDM/TBQtKf3bUwosry+fRh4YozoDzEblc2jaX4sssbhIOG2jFocmL0Y
   bS56zNl01M6i7XLpTbOb1HO5v80iaIW61VJMW1M4i8Vn1zdlF1KR9cAo0
   uNXNsqKgH2Da5gmQ7QF6mNGMUWVEDkZ93bzTzzWB3itzPiG59i+s4JoOA
   44xRTfEDwoxEXOx70znixRVVetFMtMOEznVVFZTJ2d+Is7GnNxnD/8m8g
   pySobQp4fAgJX8WGgEGM3fa7/CeAOKxNNeoq87mV6KJdfl7arDWCn9Pvp
   A==;
X-IronPort-AV: E=McAfee;i="6200,9189,10192"; a="324335970"
X-IronPort-AV: E=Sophos;i="5.88,192,1635231600"; 
   d="scan'208";a="324335970"
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by fmsmga105.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 09 Dec 2021 02:57:26 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.88,192,1635231600"; 
   d="scan'208";a="564716048"
Received: from lkp-server02.sh.intel.com (HELO 9e1e9f9b3bcb) ([10.239.97.151])
  by fmsmga008.fm.intel.com with ESMTP; 09 Dec 2021 02:57:23 -0800
Received: from kbuild by 9e1e9f9b3bcb with local (Exim 4.92)
	(envelope-from <lkp@intel.com>)
	id 1mvH74-0001oH-Hq; Thu, 09 Dec 2021 10:57:22 +0000
Date: Thu, 9 Dec 2021 18:56:27 +0800
From: kernel test robot <lkp@intel.com>
To: Stefan Berger <stefanb@linux.ibm.com>, linux-integrity@vger.kernel.org
Cc: llvm@lists.linux.dev, kbuild-all@lists.01.org, zohar@linux.ibm.com,
	serge@hallyn.com, christian.brauner@ubuntu.com,
	containers@lists.linux.dev, dmitry.kasatkin@gmail.com,
	ebiederm@xmission.com, krzysztof.struczynski@huawei.com,
	roberto.sassu@huawei.com, mpeters@redhat.com
Subject: Re: [PATCH v5 01/16] ima: Add IMA namespace support
Message-ID: <202112091857.y0keGg9v-lkp@intel.com>
References: <20211208221818.1519628-2-stefanb@linux.ibm.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20211208221818.1519628-2-stefanb@linux.ibm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)

Hi Stefan,

Thank you for the patch! Perhaps something to improve:

[auto build test WARNING on zohar-integrity/next-integrity]
[also build test WARNING on linux/master linus/master v5.16-rc4 next-20211208]
[cannot apply to jmorris-security/next-testing]
[If your patch is applied to the wrong git tree, kindly drop us a note.
And when submitting patch, we suggest to use '--base' as documented in
https://git-scm.com/docs/git-format-patch]

url:    https://github.com/0day-ci/linux/commits/Stefan-Berger/ima-Namespace-IMA-with-audit-support-in-IMA-ns/20211209-062017
base:   https://git.kernel.org/pub/scm/linux/kernel/git/zohar/linux-integrity.git next-integrity
config: hexagon-randconfig-r045-20211207 (https://download.01.org/0day-ci/archive/20211209/202112091857.y0keGg9v-lkp@intel.com/config)
compiler: clang version 14.0.0 (https://github.com/llvm/llvm-project 097a1cb1d5ebb3a0ec4bcaed8ba3ff6a8e33c00a)
reproduce (this is a W=1 build):
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # https://github.com/0day-ci/linux/commit/0e5d16c2da02e9c61692836edf0b6f7f227e1867
        git remote add linux-review https://github.com/0day-ci/linux
        git fetch --no-tags linux-review Stefan-Berger/ima-Namespace-IMA-with-audit-support-in-IMA-ns/20211209-062017
        git checkout 0e5d16c2da02e9c61692836edf0b6f7f227e1867
        # save the config file to linux build tree
        mkdir build_dir
        COMPILER_INSTALL_PATH=$HOME/0day COMPILER=clang make.cross W=1 O=build_dir ARCH=hexagon SHELL=/bin/bash

If you fix the issue, kindly add following tag as appropriate
Reported-by: kernel test robot <lkp@intel.com>

All warnings (new ones prefixed by >>):

   In file included from fs/open.c:32:
>> include/linux/ima.h:263:5: warning: 'CONFIG_IMA' is not defined, evaluates to 0 [-Wundef]
   #if CONFIG_IMA
       ^
   1 warning generated.


vim +/CONFIG_IMA +263 include/linux/ima.h

   260	
   261	static inline int create_ima_ns(struct user_namespace *user_ns)
   262	{
 > 263	#if CONFIG_IMA
   264		user_ns->ima_ns = get_ima_ns(&init_ima_ns);
   265	#endif
   266		return 0;
   267	}
   268	

---
0-DAY CI Kernel Test Service, Intel Corporation
https://lists.01.org/hyperkitty/list/kbuild-all@lists.01.org
