Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4F32129CA
	for <containers@lists.linux.dev>; Wed, 26 Jan 2022 13:19:15 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F3ECDC340E3;
	Wed, 26 Jan 2022 13:19:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1643203155;
	bh=lKH8YDY04maTeVFEgXG3vRNVow0n8FFojBX2uObASL4=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=eyIJyOY4AwdCrefrN53yw5S60cWw5bG6H46HrMjDBuUfr9pDvdXYIEJlCI52QIOaN
	 CePfyKY59M+eyz4Vz/dJPQW/QmBoYe4qVAMtHjesWsBgua1I0ES+j8KS/Mfi3tZxC/
	 X4w0C9wvjmpTmwNHwSFCS59FXqN/i7BL0rtL5z3uFJ+h0ZA5hgZJf4JIMiXDNeIpPl
	 RXw9MFHi5N0V43qS5A3ZR9dACrhH+MhBa+ks6zuz+li1ZRxsG4sVKutRv71Jv/WWcl
	 AGwGSPF+qutru6BJto/Uh9VJHnLC3I0S6FhV+OBREKbmsOY3nuyI9CpGHu3ZZdKMV4
	 kLHRFn3VU6/ow==
Date: Wed, 26 Jan 2022 14:19:07 +0100
From: Christian Brauner <brauner@kernel.org>
To: Stefan Berger <stefanb@linux.vnet.ibm.com>
Cc: linux-integrity@vger.kernel.org, zohar@linux.ibm.com, serge@hallyn.com,
	christian.brauner@ubuntu.com, containers@lists.linux.dev,
	dmitry.kasatkin@gmail.com, ebiederm@xmission.com,
	krzysztof.struczynski@huawei.com, roberto.sassu@huawei.com,
	mpeters@redhat.com, lhinds@redhat.com, lsturman@redhat.com,
	puiterwi@redhat.com, jejb@linux.ibm.com, jamjoom@us.ibm.com,
	linux-kernel@vger.kernel.org, paul@paul-moore.com, rgb@redhat.com,
	linux-security-module@vger.kernel.org, jmorris@namei.org,
	Stefan Berger <stefanb@linux.ibm.com>
Subject: Re: [PATCH v9 00/23] ima: Namespace IMA with audit support in IMA-ns
Message-ID: <20220126131907.5fauajyjfbcnienp@wittgenstein>
References: <20220125224645.79319-1-stefanb@linux.vnet.ibm.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20220125224645.79319-1-stefanb@linux.vnet.ibm.com>

On Tue, Jan 25, 2022 at 05:46:22PM -0500, Stefan Berger wrote:
> From: Stefan Berger <stefanb@linux.ibm.com>
> 
> The goal of this series of patches is to start with the namespacing of
> IMA and support auditing within an IMA namespace (IMA-ns) as the first
> step.
> 
> In this series the IMA namespace is piggy backing on the user namespace
> and therefore an IMA namespace is created when a user namespace is
> created, although this is done late when SecurityFS is mounted inside
> a user namespace. The advantage of piggy backing on the user namespace
> is that the user namespace can provide the keys infrastructure that IMA
> appraisal support will need later on.
> 
> We chose the goal of supporting auditing within an IMA namespace since it
> requires the least changes to IMA. Following this series, auditing within
> an IMA namespace can be activated by a user running the following lines
> that rely on a statically linked busybox to be installed on the host for
> execution within the minimal container environment:
> 
> mkdir -p rootfs/{bin,mnt,proc}
> cp /sbin/busybox rootfs/bin
> cp /sbin/busybox rootfs/bin/busybox2
> echo >> rootfs/bin/busybox2
> PATH=/bin unshare --user --map-root-user --mount-proc --pid --fork \
>   --root rootfs busybox sh -c \
>  "busybox mount -t securityfs /mnt /mnt; \
>   busybox echo 1 > /mnt/ima/active; \
>   busybox echo 'audit func=BPRM_CHECK mask=MAY_EXEC' > /mnt/ima/policy; \

I think we need to limit the number of rules that can be added to an ima
namespace to prevent DOS attacks. The current implementation allows
users to write as many ima rules as they want.

My suggestion would be that you look at real-world data to figure out
what a fairly common number of rules is that people write. Then use this
as the hard-coded limit for a first implementation. If the use-case
arises you can later make this limit configurable by introducing a
ucount for ima rules via /proc/sys/user/max_ima_rules.

Additionally, you should probably switch a lot of ima allocations from
GFP_KERNEL to GFP_KERNEL_ACCOUNT as allocations triggerable from userns
should be treated as untrusted.
