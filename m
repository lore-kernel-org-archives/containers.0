From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix running without sysfs
Date: Wed, 26 Sep 2007 22:03:05 -0700 (PDT)
Message-ID: <20070926.220305.130145916.davem@davemloft.net>
References: <m1zlz9rnt1.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <m1zlz9rnt1.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
To: ebiederm@xmission.com
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 26 Sep 2007 17:48:10 -0600

> 
> When sysfs support is compiled out the kernel still keeps and maintains
> the kobject tree.  So it is not safe to skip our kobject reference counting or 
> to avoid becoming members of the kobject tree.  It is safe to not add
> the networking specific sysfs attributes.
> 
> This patch removes the sysfs special cases from net/core/dev.c
> renames functions from netdev_sysfs_xxxx to netdev_kobject_xxxx
> and always compiles in net-sysfs.c
> 
> net-sysfs.c is modified with a CONFIG_SYSFS guard around the parts
> that are actually sysfs specific.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied to net-2.6.24
