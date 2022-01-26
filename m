Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D987329CA
	for <containers@lists.linux.dev>; Wed, 26 Jan 2022 13:05:40 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 955CBC340E8;
	Wed, 26 Jan 2022 13:05:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1643202340;
	bh=L5G2n0VsE2evv683FWGk9yba/VDo2lpDzUUTpzllFr8=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=VhunVoapP78fwhyMMssIjg2fkzdZFQl3djkCK/XBsXpiRA3Dxk0dxJKB35tXcPGOo
	 S1KCkfcPfO85N2HYhKaWmZheZmcCFnfn0FFKCQ4j3y89sB35UDGtYU8kS9r1aQ08bd
	 CejyXkSoOEIeo0Fg+mi7K6nDxNg1iH730fOJOrYoQNI2h070A1jlSTTflyQVNizBd9
	 xjwiRhI/u86iN+iX+WG8PI9c7kuL05HEwByrTNWQpPlxqMrNfTJ1OEIR456UqmP51M
	 mYoZKgxRCONnizm8WWILPBKAOW5HfBdfE4y9IcyG3tN06PiD4dufwr10/lIjZeoKGY
	 sHC5kRNOue4TA==
Date: Wed, 26 Jan 2022 14:05:32 +0100
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
Subject: Re: [PATCH v9 11/23] ima: Move ima_lsm_policy_notifier into
 ima_namespace
Message-ID: <20220126130532.gvswwt333ojh5xae@wittgenstein>
References: <20220125224645.79319-1-stefanb@linux.vnet.ibm.com>
 <20220125224645.79319-12-stefanb@linux.vnet.ibm.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20220125224645.79319-12-stefanb@linux.vnet.ibm.com>

On Tue, Jan 25, 2022 at 05:46:33PM -0500, Stefan Berger wrote:
> From: Stefan Berger <stefanb@linux.ibm.com>
> 
> Move the ima_lsm_policy_notifier into the ima_namespace. Each IMA
> namespace can now register its own LSM policy change notifier callback.
> The policy change notifier for the init_ima_ns still remains in init_ima()
> and therefore handle the registration of the callback for all other
> namespaces in init_ima_namespace().
> 
> Signed-off-by: Stefan Berger <stefanb@linux.ibm.com>
> ---

I'd double-check that this cannot be used to cause rcu stalls when a lot
of ima namespace with a lot of rules are used leading to a dos situation
during LSM policy update. The good thing at least is that an LSM policy
update can only be triggered for selinux for the whole system.
