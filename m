Received: from mga12.intel.com (mga12.intel.com [192.55.52.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 29EAD168
	for <containers@lists.linux.dev>; Mon,  3 Jan 2022 20:41:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1641242479; x=1672778479;
  h=date:from:to:cc:subject:message-id:references:
   mime-version:in-reply-to;
  bh=mvf/dwn2CN/4T6eA3WyndzrgWr796ef3yoEvKiAHOIY=;
  b=T4Rkos/5hblYVZYFH3ynxwmZUKDCsuu+Yp+HE9R0J8TEV81R9N/HwONi
   +HFCP28JXMYdgMdbKNnBoc0T9bc/Uba8ToTf4KFwxavIfBOt94NWhwsL+
   kW8JLbZ/kR7QHw5++IAQnqa1ubP1GpRhxTghTzbSoGs9T8OUNVN+E89op
   eRVsba7L78rGazKAGr/ncX2h4/2HsPWiBphDDnipHV8Zaitej4hLrpHtb
   UGVx4kPytjHo2qqTEJYCL8/mW2ZjG/lEIu8EK5IlikygL3e2ayXnnXS/+
   2eYw9Fo7+pXeIDHCu6zpT/OyB+WbC1+1ylAfmf/MFYGgCV4OMYDsEgWRv
   Q==;
X-IronPort-AV: E=McAfee;i="6200,9189,10216"; a="222108366"
X-IronPort-AV: E=Sophos;i="5.88,258,1635231600"; 
   d="scan'208";a="222108366"
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by fmsmga106.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 03 Jan 2022 12:41:17 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.88,258,1635231600"; 
   d="scan'208";a="620419301"
Received: from lkp-server01.sh.intel.com (HELO e357b3ef1427) ([10.239.97.150])
  by orsmga004.jf.intel.com with ESMTP; 03 Jan 2022 12:41:14 -0800
Received: from kbuild by e357b3ef1427 with local (Exim 4.92)
	(envelope-from <lkp@intel.com>)
	id 1n4U8n-000EPM-Gm; Mon, 03 Jan 2022 20:41:13 +0000
Date: Tue, 4 Jan 2022 04:41:02 +0800
From: kernel test robot <lkp@intel.com>
To: Alexey Gladkov <legion@kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	Linux Containers <containers@lists.linux.dev>
Cc: kbuild-all@lists.01.org,
	Alexander Mikhalitsyn <alexander.mikhalitsyn@virtuozzo.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	Christian Brauner <christian.brauner@ubuntu.com>,
	Daniel Walsh <dwalsh@redhat.com>, Davidlohr Bueso <dbueso@suse.de>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Kirill Tkhai <ktkhai@virtuozzo.com>
Subject: Re: [PATCH v1] ipc: Store mqueue sysctls in the ipc namespace
Message-ID: <202201040410.Hhzhq6t0-lkp@intel.com>
References: <0f0408bb7fbf3187966a9bf19a98642a5d9669fe.1641225760.git.legion@kernel.org>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0f0408bb7fbf3187966a9bf19a98642a5d9669fe.1641225760.git.legion@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)

Hi Alexey,

Thank you for the patch! Yet something to improve:

[auto build test ERROR on linux/master]
[also build test ERROR on hnaz-mm/master linus/master v5.16-rc8 next-20211224]
[If your patch is applied to the wrong git tree, kindly drop us a note.
And when submitting patch, we suggest to use '--base' as documented in
https://git-scm.com/docs/git-format-patch]

url:    https://github.com/0day-ci/linux/commits/Alexey-Gladkov/ipc-Store-mqueue-sysctls-in-the-ipc-namespace/20220104-000523
base:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git 136057256686de39cc3a07c2e39ef6bc43003ff6
config: arm64-buildonly-randconfig-r005-20220103 (https://download.01.org/0day-ci/archive/20220104/202201040410.Hhzhq6t0-lkp@intel.com/config)
compiler: aarch64-linux-gcc (GCC) 11.2.0
reproduce (this is a W=1 build):
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # https://github.com/0day-ci/linux/commit/637324916f39ec562ac383bfbc22ee9fcbfcb1c0
        git remote add linux-review https://github.com/0day-ci/linux
        git fetch --no-tags linux-review Alexey-Gladkov/ipc-Store-mqueue-sysctls-in-the-ipc-namespace/20220104-000523
        git checkout 637324916f39ec562ac383bfbc22ee9fcbfcb1c0
        # save the config file to linux build tree
        mkdir build_dir
        COMPILER_INSTALL_PATH=$HOME/0day COMPILER=gcc-11.2.0 make.cross O=build_dir ARCH=arm64 SHELL=/bin/bash

If you fix the issue, kindly add following tag as appropriate
Reported-by: kernel test robot <lkp@intel.com>

All errors (new ones prefixed by >>):

   aarch64-linux-ld: Unexpected GOT/PLT entries detected!
   aarch64-linux-ld: Unexpected run-time procedure linkages detected!
   aarch64-linux-ld: ID map text too big or misaligned
   aarch64-linux-ld: ipc/mqueue.o: in function `init_mqueue_fs':
>> mqueue.c:(.init.text+0x64): undefined reference to `setup_mq_sysctls'
   aarch64-linux-ld: ipc/namespace.o: in function `free_ipc':
>> namespace.c:(.text+0xb0): undefined reference to `retire_mq_sysctls'
   aarch64-linux-ld: ipc/namespace.o: in function `copy_ipcs':
>> namespace.c:(.text+0x4d8): undefined reference to `setup_mq_sysctls'

---
0-DAY CI Kernel Test Service, Intel Corporation
https://lists.01.org/hyperkitty/list/kbuild-all@lists.01.org
