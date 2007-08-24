From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Subject: Re: [PATCH] Memory controller Add Documentation
Date: Fri, 24 Aug 2007 17:48:15 +0900 (JST)
Message-ID: <20070824084816.4F23E1BFA1D@siro.lan>
References: <20070822130612.18981.58696.sendpatchset@balbir-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1765473AbXHXIs2@vger.kernel.org>
In-Reply-To: Your message of "Wed, 22 Aug 2007 18:36:12 +0530"
	<20070822130612.18981.58696.sendpatchset@balbir-laptop>
Sender: linux-kernel-owner@vger.kernel.org
To: balbir@linux.vnet.ibm.com
Cc: akpm@linux-foundation.org, npiggin@suse.de, a.p.zijlstra@chello.nl, dhaval@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ebiederm@xmission.com, containers@lists.osdl.org, menage@google.com, xemul@openvz.org
List-Id: containers.vger.kernel.org

> +echo 1 > /proc/sys/vm/drop_pages will help get rid of some of the pages
> +cached in the container (page cache pages).

drop_caches

YAMAMOTO Takashi
