From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH 10/11] netns: Enable tagging for net_class directories
 in sysfs
Date: Mon, 23 Jun 2008 11:18:12 +0900
Message-ID: <485F07E4.4020400@gmail.com>
References: <20080618170729.808539948@theryb.frec.bull.fr> <20080618170731.597904070@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756162AbYFWCSe@vger.kernel.org>
In-Reply-To: <20080618170731.597904070@theryb.frec.bull.fr>
Sender: linux-kernel-owner@vger.kernel.org
To: Benjamin Thery <benjamin.thery@bull.net>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Eric Biederman <ebiederm@xmission.com>, Daniel Lezcano <dlezcano@fr.ibm.com>, Serge Hallyn <serue@us.ibm.com>, linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Benjamin Thery wrote:
> --- linux-mm.orig/fs/sysfs/mount.c
> +++ linux-mm/fs/sysfs/mount.c
> @@ -16,6 +16,8 @@
>  #include <linux/mount.h>
>  #include <linux/pagemap.h>
>  #include <linux/init.h>
> +#include <linux/nsproxy.h>
> +#include <net/net_namespace.h>
>  
>  #include "sysfs.h"
>  
> @@ -78,6 +80,7 @@ static int sysfs_fill_super(struct super
>  	root->d_sb = sb;
>  	sb->s_root = root;
>  	sb->s_fs_info = info;
> +	info->tag.net_ns = hold_net(current->nsproxy->net_ns);
>  	return 0;
>  
>  out_err:
> @@ -95,6 +98,9 @@ static int sysfs_test_super(struct super
>  	struct sysfs_super_info *info = sysfs_info(sb);
>  	int found = 1;
>  
> +	if (task->nsproxy->net_ns != info->tag.net_ns)
> +		found = 0;
> +
>  	return found;
>  }
>  
> @@ -131,6 +137,8 @@ static void sysfs_kill_sb(struct super_b
>  	struct sysfs_super_info *info = sysfs_info(sb);
>  
>  	kill_anon_super(sb);
> +	if (info->tag.net_ns)
> +		release_net(info->tag.net_ns);
>  	kfree(info);
>  }

Ouch... Please don't hard code net_ns functions directly from sysfs.
Please make a proper abstraction for ns, make net_ns register it and
sysfs test the abstract ns.

Thanks.

-- 
tejun
