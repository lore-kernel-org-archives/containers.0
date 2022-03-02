Received: from mga07.intel.com (mga07.intel.com [134.134.136.100])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 53D302104;
	Wed,  2 Mar 2022 19:17:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1646248664; x=1677784664;
  h=date:from:to:cc:subject:message-id:references:
   mime-version:in-reply-to;
  bh=W5bF9lrLsIRpfJsYdIa+ZYl/EKN3Jruw12F438PMPI0=;
  b=Z2ps7O06v4SHYa+6JYCxgx2z/Zt6767noMP/2TwP1wge5iPniJgQhDUu
   w8W/Xrm0UDBVjmpWrwUSD332gbM2HuaQ/NPrfoFRuSQxiFmh2orMLSIz5
   Yqr9PxKnz1m+LfMR43J1RUlAE/G1IP1UWO8g0/zfFpdnRokgliSITdp6D
   PSIx6KOP94DdTGPwRuEHuyJlY20ezlwfhko3vsm+eEg2O31kzXSdgoS5Q
   UhxvghHjCNrKGXWDKfdfccgfGtqImku/2hzJHLxO7lefgGzEgtAmBBf0D
   a8izunJKQvkCZOESLhKVnwjZtxw8ZF56UhUh0MlHdqGinpInUp3Iusv2L
   w==;
X-IronPort-AV: E=McAfee;i="6200,9189,10274"; a="316698816"
X-IronPort-AV: E=Sophos;i="5.90,150,1643702400"; 
   d="scan'208";a="316698816"
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga105.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 02 Mar 2022 11:17:43 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.90,150,1643702400"; 
   d="scan'208";a="630515739"
Received: from lkp-server02.sh.intel.com (HELO e9605edfa585) ([10.239.97.151])
  by FMSMGA003.fm.intel.com with ESMTP; 02 Mar 2022 11:17:36 -0800
Received: from kbuild by e9605edfa585 with local (Exim 4.92)
	(envelope-from <lkp@intel.com>)
	id 1nPUTa-0001ni-Fw; Wed, 02 Mar 2022 19:17:30 +0000
Date: Thu, 3 Mar 2022 03:16:45 +0800
From: kernel test robot <lkp@intel.com>
To: Stefan Berger <stefanb@linux.ibm.com>, linux-integrity@vger.kernel.org
Cc: llvm@lists.linux.dev, kbuild-all@lists.01.org, zohar@linux.ibm.com,
	serge@hallyn.com, christian.brauner@ubuntu.com,
	containers@lists.linux.dev, dmitry.kasatkin@gmail.com,
	ebiederm@xmission.com, krzysztof.struczynski@huawei.com,
	roberto.sassu@huawei.com, mpeters@redhat.com, lhinds@redhat.com,
	lsturman@redhat.com, puiterwi@redhat.com, jejb@linux.ibm.com,
	jamjoom@us.ibm.com, linux-kernel@vger.kernel.org,
	paul@paul-moore.com, rgb@redhat.com,
	linux-security-module@vger.kernel.org, jmorris@namei.org,
	Stefan Berger <stefanb@linux.ibm.com>
Subject: Re: [PATCH v11 23/27] ima: Introduce securityfs file to activate an
 IMA namespace
Message-ID: <202203030340.kolQS5ma-lkp@intel.com>
References: <20220302134703.1273041-24-stefanb@linux.ibm.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20220302134703.1273041-24-stefanb@linux.ibm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)

Hi Stefan,

Thank you for the patch! Perhaps something to improve:

[auto build test WARNING on linus/master]
[also build test WARNING on v5.17-rc6]
[cannot apply to zohar-integrity/next-integrity linux/master jmorris-security/next-testing next-20220302]
[If your patch is applied to the wrong git tree, kindly drop us a note.
And when submitting patch, we suggest to use '--base' as documented in
https://git-scm.com/docs/git-format-patch]

url:    https://github.com/0day-ci/linux/commits/Stefan-Berger/ima-Namespace-IMA-with-audit-support-in-IMA-ns/20220302-215707
base:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git fb184c4af9b9f4563e7a126219389986a71d5b5b
config: arm64-randconfig-r006-20220302 (https://download.01.org/0day-ci/archive/20220303/202203030340.kolQS5ma-lkp@intel.com/config)
compiler: clang version 15.0.0 (https://github.com/llvm/llvm-project d271fc04d5b97b12e6b797c6067d3c96a8d7470e)
reproduce (this is a W=1 build):
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # install arm64 cross compiling tool for clang build
        # apt-get install binutils-aarch64-linux-gnu
        # https://github.com/0day-ci/linux/commit/59a9ba1130510d6693a61c6eb84c29983fa696df
        git remote add linux-review https://github.com/0day-ci/linux
        git fetch --no-tags linux-review Stefan-Berger/ima-Namespace-IMA-with-audit-support-in-IMA-ns/20220302-215707
        git checkout 59a9ba1130510d6693a61c6eb84c29983fa696df
        # save the config file to linux build tree
        mkdir build_dir
        COMPILER_INSTALL_PATH=$HOME/0day COMPILER=clang make.cross W=1 O=build_dir ARCH=arm64 SHELL=/bin/bash security/integrity/ima/

If you fix the issue, kindly add following tag as appropriate
Reported-by: kernel test robot <lkp@intel.com>

All warnings (new ones prefixed by >>):

>> security/integrity/ima/ima_fs.c:591:3: warning: variable 'ret' is used uninitialized whenever 'if' condition is true [-Wsometimes-uninitialized]
                   if (IS_ERR(active))
                   ^~~~~~~~~~~~~~~~~~~
   include/linux/compiler.h:56:28: note: expanded from macro 'if'
   #define if(cond, ...) if ( __trace_if_var( !!(cond , ## __VA_ARGS__) ) )
                              ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   include/linux/compiler.h:58:30: note: expanded from macro '__trace_if_var'
   #define __trace_if_var(cond) (__builtin_constant_p(cond) ? (cond) : __trace_if_value(cond))
                                ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   security/integrity/ima/ima_fs.c:608:9: note: uninitialized use occurs here
           return ret;
                  ^~~
   security/integrity/ima/ima_fs.c:591:3: note: remove the 'if' if its condition is always false
                   if (IS_ERR(active))
                   ^~~~~~~~~~~~~~~~~~~
   include/linux/compiler.h:56:23: note: expanded from macro 'if'
   #define if(cond, ...) if ( __trace_if_var( !!(cond , ## __VA_ARGS__) ) )
                         ^
   security/integrity/ima/ima_fs.c:516:9: note: initialize the variable 'ret' to silence this warning
           int ret;
                  ^
                   = 0
   1 warning generated.


vim +591 security/integrity/ima/ima_fs.c

   504	
   505	int ima_fs_ns_init(struct user_namespace *user_ns, struct dentry *root)
   506	{
   507		struct ima_namespace *ns = ima_ns_from_user_ns(user_ns);
   508		struct dentry *int_dir;
   509		struct dentry *ima_dir = NULL;
   510		struct dentry *ima_symlink = NULL;
   511		struct dentry *binary_runtime_measurements = NULL;
   512		struct dentry *ascii_runtime_measurements = NULL;
   513		struct dentry *runtime_measurements_count = NULL;
   514		struct dentry *violations = NULL;
   515		struct dentry *active = NULL;
   516		int ret;
   517	
   518		/* FIXME: update when evm and integrity are namespaced */
   519		if (user_ns != &init_user_ns) {
   520			int_dir = securityfs_create_dir("integrity", root);
   521			if (IS_ERR(int_dir))
   522				return PTR_ERR(int_dir);
   523		} else {
   524			int_dir = integrity_dir;
   525		}
   526	
   527		ima_dir = securityfs_create_dir("ima", int_dir);
   528		if (IS_ERR(ima_dir)) {
   529			ret = PTR_ERR(ima_dir);
   530			goto out;
   531		}
   532	
   533		ima_symlink = securityfs_create_symlink("ima", root, "integrity/ima",
   534							NULL);
   535		if (IS_ERR(ima_symlink)) {
   536			ret = PTR_ERR(ima_symlink);
   537			goto out;
   538		}
   539	
   540		binary_runtime_measurements =
   541		    securityfs_create_file("binary_runtime_measurements",
   542					   S_IRUSR | S_IRGRP, ima_dir, NULL,
   543					   &ima_measurements_ops);
   544		if (IS_ERR(binary_runtime_measurements)) {
   545			ret = PTR_ERR(binary_runtime_measurements);
   546			goto out;
   547		}
   548	
   549		ascii_runtime_measurements =
   550		    securityfs_create_file("ascii_runtime_measurements",
   551					   S_IRUSR | S_IRGRP, ima_dir, NULL,
   552					   &ima_ascii_measurements_ops);
   553		if (IS_ERR(ascii_runtime_measurements)) {
   554			ret = PTR_ERR(ascii_runtime_measurements);
   555			goto out;
   556		}
   557	
   558		runtime_measurements_count =
   559		    securityfs_create_file("runtime_measurements_count",
   560					   S_IRUSR | S_IRGRP, ima_dir, NULL,
   561					   &ima_measurements_count_ops);
   562		if (IS_ERR(runtime_measurements_count)) {
   563			ret = PTR_ERR(runtime_measurements_count);
   564			goto out;
   565		}
   566	
   567		violations =
   568		    securityfs_create_file("violations", S_IRUSR | S_IRGRP,
   569					   ima_dir, NULL, &ima_htable_violations_ops);
   570		if (IS_ERR(violations)) {
   571			ret = PTR_ERR(violations);
   572			goto out;
   573		}
   574	
   575		if (!ns->ima_policy_removed) {
   576			ns->ima_policy =
   577			    securityfs_create_file("policy", POLICY_FILE_FLAGS,
   578						   ima_dir, NULL,
   579						   &ima_measure_policy_ops);
   580			if (IS_ERR(ns->ima_policy)) {
   581				ret = PTR_ERR(ns->ima_policy);
   582				goto out;
   583			}
   584		}
   585	
   586		if (ns != &init_ima_ns) {
   587			active =
   588			    securityfs_create_file("active",
   589						   S_IRUSR | S_IWUSR | S_IRGRP, ima_dir,
   590						   NULL, &ima_active_ops);
 > 591			if (IS_ERR(active))
   592				goto out;
   593		}
   594	
   595		return 0;
   596	out:
   597		securityfs_remove(active);
   598		securityfs_remove(ns->ima_policy);
   599		securityfs_remove(violations);
   600		securityfs_remove(runtime_measurements_count);
   601		securityfs_remove(ascii_runtime_measurements);
   602		securityfs_remove(binary_runtime_measurements);
   603		securityfs_remove(ima_symlink);
   604		securityfs_remove(ima_dir);
   605		if (user_ns != &init_user_ns)
   606			securityfs_remove(int_dir);
   607	
   608		return ret;
   609	}
   610	

---
0-DAY CI Kernel Test Service, Intel Corporation
https://lists.01.org/hyperkitty/list/kbuild-all@lists.01.org
