Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 77DD02CA3
	for <containers@lists.linux.dev>; Wed, 26 Jan 2022 14:46:41 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4B2BCC340E3;
	Wed, 26 Jan 2022 14:46:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1643208401;
	bh=cJiDTU9gQID9GLUd0bo9OOnXsiH1fDIWRGx2iU5CFGo=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=amwz4PKzyPjQVWuKQ7wqGmy3Tn84xJxWrb+FSTfzCtPtf2hwttJFmtQEOVkBB4+yi
	 CWyqvr4jYwUmdPTx7tws8wL08moCNcDvCuz6TLYAbfe1X07PdT15331mK+SqJz9V5J
	 KeD7OtnMfM7MxTg66OZXdm6Jee7vb8s4Ct4vhzpYU3A3nxYs5s3j38H0UA0reF6tZv
	 0k7rMiNLlzKB6fMqx02FEcb7X5DvWRyWAYUalBxOsrMoE/XATKkGra52T4FFRCNrqb
	 iHKKbqU5PchFr+OBU4ezTkf1gjBIG/rdHapHl2Xx8p7YdT8dF5mb3AlLDH3EM6qBIq
	 WGlQYl3oQ0qyg==
Date: Wed, 26 Jan 2022 15:46:28 +0100
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
Subject: Re: [PATCH v9 14/23] userns: Add pointer to ima_namespace to
 user_namespace
Message-ID: <20220126144628.mxmpdcxwrxh2pfzj@wittgenstein>
References: <20220125224645.79319-1-stefanb@linux.vnet.ibm.com>
 <20220125224645.79319-15-stefanb@linux.vnet.ibm.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20220125224645.79319-15-stefanb@linux.vnet.ibm.com>

On Tue, Jan 25, 2022 at 05:46:36PM -0500, Stefan Berger wrote:
> From: Stefan Berger <stefanb@linux.ibm.com>
> 
> Add a pointer to ima_namespace to the user_namespace and initialize
> the init_user_ns with a pointer to init_ima_ns.
> 
> Signed-off-by: Stefan Berger <stefanb@linux.ibm.com>
> 
> ---

Looks good,
Acked-by: Christian Brauner <brauner@kernel.org>
