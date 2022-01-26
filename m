Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 43F83168
	for <containers@lists.linux.dev>; Wed, 26 Jan 2022 08:47:28 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E8114C340E3;
	Wed, 26 Jan 2022 08:47:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1643186847;
	bh=fYjYvin/ncOZkgLTguVdtStT4rh5GTFzqtSVTzTJ5zc=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=fz3RmuSXApVcPfd2W5IX7BNuEBYQ4d/CA4tiX/LmenrLmCpArMF2qcdlYLQqGghN4
	 kcz87olbwJ69uqNx2KuvfDqsGLid6phMh1y7QQ6ZDZkna1T3qDXoi3B54/PL4HxhAk
	 qjJsJKbt74o7ckNIdM5WXtP8wLuxGZmlqPPeZxACkgBgoxnPLDQBDsYvZlNZCeEMYg
	 r72iPq8g4MXzgih9XPna4tWSThd95NHiJg2TUilTWFMRaid5MshhbHKH9ve+Zx7u3i
	 PhGYuWoPHAEXHVLJnnqfliypniJ+DOQbrG9blbksF7BIhGznT10Mb5v+/tRN/MW5b7
	 Yn5BnOWWVQrcA==
Date: Wed, 26 Jan 2022 09:47:15 +0100
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
Subject: Re: [PATCH v9 05/23] ima: Define ima_namespace struct and start
 moving variables into it
Message-ID: <20220126084715.b2wtmlbzoaqtipbp@wittgenstein>
References: <20220125224645.79319-1-stefanb@linux.vnet.ibm.com>
 <20220125224645.79319-6-stefanb@linux.vnet.ibm.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20220125224645.79319-6-stefanb@linux.vnet.ibm.com>

On Tue, Jan 25, 2022 at 05:46:27PM -0500, Stefan Berger wrote:
> From: Stefan Berger <stefanb@linux.ibm.com>
> 
> Define the ima_namespace structure and the ima_namespace variable
> init_ima_ns for the host's IMA namespace. Implement basic functions for
> namespacing support.
> 
> Move variables related to the IMA policy into the ima_namespace. This way
> the IMA policy of an IMA namespace can be set and displayed using a
> front-end like securityfs.
> 
> Implement ima_ns_from_file() to get the IMA namespace via the user
> namespace of the securityfs superblock that a file belongs to.
> 
> To get the current ima_namespace use &init_ima_ns when a function
> that is related to a policy rule is called.
> 
> Signed-off-by: Stefan Berger <stefanb@linux.ibm.com>
> 
> ---

For the approach of introducing struct ima_namespace and moving a bunch
of variables in there at the same time to prepare subsequent further
namespacing:

Acked-by: Christian Brauner <brauner@kernel.org>

I can't speak to the actual ima changes.
