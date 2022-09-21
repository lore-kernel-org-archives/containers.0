Received: from mga09.intel.com (mga09.intel.com [134.134.136.24])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8280D7C;
	Wed, 21 Sep 2022 09:39:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1663753163; x=1695289163;
  h=date:from:to:cc:subject:message-id:references:
   mime-version:in-reply-to;
  bh=VJnMfkjVt6R4xqCodT1PncCAy2K/67p9tish/CyCUBQ=;
  b=kZWA3/ycF7/0w2OrkBDTF5ffQ1nGR2fpsZXJ7FoyKAmh5YVdUI1/BcT9
   BbzZTvRuUsJmuA5jhseLg98lK/qiWVbN9kF4Bts9/bV+dEZ47hCluVzVA
   4Ia+PdpUQ803Hrkdu8voe1xUCBZaysRSUSCknpIQwggI3Y4CDhrc6EMyj
   IlIWMY/K5Hurm/CMOOSmfJF/0selEVfw618mAHj9j5MMqoFnlfg4n3gn7
   RKRtQV6Cxx/qLOhf19ZytYe3Nckhhy3FQmWJO1d6ia+LSiNAs9pnJoE6Z
   izQN4hIGrZJpq/0AHZYnE/nuCmS+do6hTclKpaNWSiQ89iFnPjuZ9Z9sv
   A==;
X-IronPort-AV: E=McAfee;i="6500,9779,10476"; a="300792416"
X-IronPort-AV: E=Sophos;i="5.93,333,1654585200"; 
   d="scan'208";a="300792416"
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga102.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 21 Sep 2022 02:39:17 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.93,333,1654585200"; 
   d="scan'208";a="761681806"
Received: from lkp-server01.sh.intel.com (HELO c0a60f19fe7e) ([10.239.97.150])
  by fmsmga001.fm.intel.com with ESMTP; 21 Sep 2022 02:39:15 -0700
Received: from kbuild by c0a60f19fe7e with local (Exim 4.96)
	(envelope-from <lkp@intel.com>)
	id 1oawCI-0003Tl-0N;
	Wed, 21 Sep 2022 09:39:14 +0000
Date: Wed, 21 Sep 2022 17:38:22 +0800
From: kernel test robot <lkp@intel.com>
To: Alexey Gladkov <legion@kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	Linux Containers <containers@lists.linux.dev>
Cc: llvm@lists.linux.dev, kbuild-all@lists.01.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	Christian Brauner <brauner@kernel.org>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Kees Cook <keescook@chromium.org>,
	Manfred Spraul <manfred@colorfullife.com>
Subject: Re: [PATCH v2 1/3] sysctl: Allow change system v ipc sysctls inside
 ipc namespace
Message-ID: <202209211737.0Bu0F40t-lkp@intel.com>
References: <0895bd453013370eb4f9600e26e2a9969ee755de.1663696560.git.legion@kernel.org>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0895bd453013370eb4f9600e26e2a9969ee755de.1663696560.git.legion@kernel.org>

Hi Alexey,

Thank you for the patch! Yet something to improve:

[auto build test ERROR on akpm-mm/mm-everything]
[also build test ERROR on kees/for-next/pstore linus/master v6.0-rc6 next-20220920]
[If your patch is applied to the wrong git tree, kindly drop us a note.
And when submitting patch, we suggest to use '--base' as documented in
https://git-scm.com/docs/git-format-patch#_base_tree_information]

url:    https://github.com/intel-lab-lkp/linux/commits/Alexey-Gladkov/sysctl-Allow-change-system-v-ipc-sysctls-inside-ipc-namespace/20220921-030939
base:   https://git.kernel.org/pub/scm/linux/kernel/git/akpm/mm.git mm-everything
config: hexagon-randconfig-r041-20220921 (https://download.01.org/0day-ci/archive/20220921/202209211737.0Bu0F40t-lkp@intel.com/config)
compiler: clang version 16.0.0 (https://github.com/llvm/llvm-project 791a7ae1ba3efd6bca96338e10ffde557ba83920)
reproduce (this is a W=1 build):
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # https://github.com/intel-lab-lkp/linux/commit/eb972fb9aad60123519d8dd32df26cb58985ce4a
        git remote add linux-review https://github.com/intel-lab-lkp/linux
        git fetch --no-tags linux-review Alexey-Gladkov/sysctl-Allow-change-system-v-ipc-sysctls-inside-ipc-namespace/20220921-030939
        git checkout eb972fb9aad60123519d8dd32df26cb58985ce4a
        # save the config file
        mkdir build_dir && cp config build_dir/.config
        COMPILER_INSTALL_PATH=$HOME/0day COMPILER=clang make.cross W=1 O=build_dir ARCH=hexagon SHELL=/bin/bash

If you fix the issue, kindly add following tag where applicable
| Reported-by: kernel test robot <lkp@intel.com>

All errors (new ones prefixed by >>):

>> ipc/ipc_sysctl.c:215:47: error: passing 'kgid_t' to parameter of incompatible type 'kgid_t *'; take the address with &
           ipc_set_ownership(head, table, &ns_root_uid, ns_root_gid);
                                                        ^~~~~~~~~~~
                                                        &
   ipc/ipc_sysctl.c:195:31: note: passing argument to parameter 'gid' here
                                 kuid_t *uid, kgid_t *gid)
                                                      ^
>> ipc/ipc_sysctl.c:225:13: error: call to undeclared function 'current_euid'; ISO C99 and later do not support implicit function declarations [-Wimplicit-function-declaration]
           if (uid_eq(current_euid(), ns_root_uid))
                      ^
   ipc/ipc_sysctl.c:225:13: note: did you mean 'current_work'?
   include/linux/workqueue.h:467:28: note: 'current_work' declared here
   extern struct work_struct *current_work(void);
                              ^
>> ipc/ipc_sysctl.c:225:13: error: passing 'int' to parameter of incompatible type 'kuid_t'
           if (uid_eq(current_euid(), ns_root_uid))
                      ^~~~~~~~~~~~~~
   include/linux/uidgid.h:61:34: note: passing argument to parameter 'left' here
   static inline bool uid_eq(kuid_t left, kuid_t right)
                                    ^
>> ipc/ipc_sysctl.c:228:11: error: call to undeclared function 'in_egroup_p'; ISO C99 and later do not support implicit function declarations [-Wimplicit-function-declaration]
           else if (in_egroup_p(ns_root_gid))
                    ^
   4 errors generated.


vim +215 ipc/ipc_sysctl.c

   206	
   207	static int ipc_permissions(struct ctl_table_header *head, struct ctl_table *table)
   208	{
   209		struct ipc_namespace *ns =
   210			container_of(head->set, struct ipc_namespace, ipc_set);
   211		int mode = table->mode;
   212		kuid_t ns_root_uid;
   213		kgid_t ns_root_gid;
   214	
 > 215		ipc_set_ownership(head, table, &ns_root_uid, ns_root_gid);
   216	
   217	#ifdef CONFIG_CHECKPOINT_RESTORE
   218		if (((table->data == &ns->ids[IPC_SEM_IDS].next_id) ||
   219		     (table->data == &ns->ids[IPC_MSG_IDS].next_id) ||
   220		     (table->data == &ns->ids[IPC_SHM_IDS].next_id)) &&
   221		    checkpoint_restore_ns_capable(ns->user_ns))
   222			mode = 0666;
   223		else
   224	#endif
 > 225		if (uid_eq(current_euid(), ns_root_uid))
   226			mode >>= 6;
   227	
 > 228		else if (in_egroup_p(ns_root_gid))
   229			mode >>= 3;
   230	
   231		mode &= 7;
   232	
   233		return (mode << 6) | (mode << 3) | mode;
   234	}
   235	

-- 
0-DAY CI Kernel Test Service
https://01.org/lkp
