Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9F2FD168
	for <containers@lists.linux.dev>; Wed, 26 Jan 2022 09:16:50 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6FE54C340E3;
	Wed, 26 Jan 2022 09:16:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1643188610;
	bh=WdvfffKVI6ApzghM8ddJv7JS3Pdt2YGhtMfAC6gP/Po=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=TKr7Zjubut89IiBL5pcdAuYfHLDnWKNOVwZxV2W+EVfYcW0S7WJGrOiRLxEr7mzmv
	 Qrq+CIpuKOXvIzchykg7MWLi1BfhIri9HC4A/X8NzyIlBpkmuSOkclOt2RMuQb5OLN
	 RcVnTPaSTZGwoJ1CYG3d+k5CllfGBLZdJ1/dNTTDfis0JO143wdtMMfmFgDan4yFpt
	 sfd0cw1F3CqhItiJ4IiBbopGrHVUgSSEHJ2fBUK8w4QROQxGWEVVMDhjC6BGA9+Yd/
	 sgoFPHcruwh+VwmS1KJVALFloyHu/pDPPrmA5A0wVOVunvogy+Z8X+uYZKQQa/Oymy
	 h09DWowN89euQ==
Date: Wed, 26 Jan 2022 10:16:42 +0100
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
Subject: Re: [PATCH v9 07/23] ima: Move ima_htable into ima_namespace
Message-ID: <20220126091642.3gvrlgx7767xvmho@wittgenstein>
References: <20220125224645.79319-1-stefanb@linux.vnet.ibm.com>
 <20220125224645.79319-8-stefanb@linux.vnet.ibm.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20220125224645.79319-8-stefanb@linux.vnet.ibm.com>

On Tue, Jan 25, 2022 at 05:46:29PM -0500, Stefan Berger wrote:
> From: Stefan Berger <stefanb@linux.ibm.com>
> 
> Move ima_htable into ima_namespace. This way a front-end like
> securityfs can show the number of violations of an IMA namespace.
> 
> Signed-off-by: Stefan Berger <stefanb@linux.ibm.com>
> ---

Moving into imans looks good,
Acked-by: Christian Brauner <brauner@kernel.org>
