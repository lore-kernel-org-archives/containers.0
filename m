Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C6C782CA7
	for <containers@lists.linux.dev>; Wed, 26 Jan 2022 08:38:22 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9C61EC340E3;
	Wed, 26 Jan 2022 08:38:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1643186302;
	bh=hql5taXDX4ZFmojFgMRXFkOGKx291CxE+GSNeSfAA2c=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=pNb+YTM6/mJuqAYTriG5zewRhHzjPggPybHpoW8TTb59Zd19gxWB+rotrC6gceiZI
	 aNYPvP5pSSYQKToxenZI6nFnIV7BbVqeXKHRsXl7cgtqYGdsk5Ww6saclUG/juZHhU
	 DRwmm4doPU4RrdV1ehlVGIrxpIkOuWVP7huqJsmNMl3eWUgsTBTLkR5Yrq4hUd427k
	 ljHiNHVKcLEGP8sirEGX0NJWHdtNZSW4Jy1GRWON4i9isvXo7vH0Ks+l4EEqwOFil4
	 pqiXmnpmZTP3AdsYYeSaU+mUeO+RysNjQR9OGFglrTSz6GT1PKmkYdn1Js7gEkKTFy
	 x+lyBwK1EV8uw==
Date: Wed, 26 Jan 2022 09:38:14 +0100
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
Subject: Re: [PATCH v9 02/23] ima: Do not print policy rule with inactive LSM
 labels
Message-ID: <20220126083814.3ndwkhivir573aok@wittgenstein>
References: <20220125224645.79319-1-stefanb@linux.vnet.ibm.com>
 <20220125224645.79319-3-stefanb@linux.vnet.ibm.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20220125224645.79319-3-stefanb@linux.vnet.ibm.com>

On Tue, Jan 25, 2022 at 05:46:24PM -0500, Stefan Berger wrote:
> From: Stefan Berger <stefanb@linux.ibm.com>
> 
> Before printing a policy rule scan for inactive LSM labels in the policy
> rule. Inactive LSM labels are identified by args_p != NULL and
> rule == NULL.
> 
> Fixes: b16942455193 ("ima: use the lsm policy update notifier")

That commit message of the referenced patch reads:

"Don't do lazy policy updates while running the rule matching, run the
updates as they happen."

and given that we had a lengthy discussion how to update the rules I'd
really would have liked an explanation why the update needs to run
immediately. Not doing it lazily is the whole reason we have this
notifier infra. Why can't this be done lazily?
