Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C44A7168
	for <containers@lists.linux.dev>; Wed, 26 Jan 2022 08:30:39 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AC646C340E3;
	Wed, 26 Jan 2022 08:30:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1643185839;
	bh=qKazU28NFPi1JaZnJrqSAMht8qRDH0NxIN7MLjkqLqE=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=NPWQNvgAyMwwqb0Ni1Ase2Q9wL5sOBkJ+9hRMUWNP3bxm9BiQH7CnQIH2dxzcSszN
	 g0z5UOqsQQDEHg50yZDClr4pXnj/GNXR4sQkqc1tREwWE+grwOvcOGo/DMfpoxEDsp
	 VKpKpqBBhYB9gjcZPAaSENV7OstEIHozmvf+wLJ7/Onnl5TTPbSUZySgr2m5k79+Pu
	 22xVzNSkGljlVJmdTmRbF643FrqBvft1U/9Vrt5BA6irynPpNr/lVoesnWMviLvNVe
	 XNIuhb/liA9PytK1+dOMbcXmolTxksY2cnbwfrBCtyG3H2jlShcOg+beYjCWrOUJm7
	 VMWP2wMUmUvVw==
Date: Wed, 26 Jan 2022 09:30:30 +0100
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
Subject: Re: [PATCH v9 01/23] ima: Remove ima_policy file before directory
Message-ID: <20220126083030.theijkt7v3w3fwm5@wittgenstein>
References: <20220125224645.79319-1-stefanb@linux.vnet.ibm.com>
 <20220125224645.79319-2-stefanb@linux.vnet.ibm.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20220125224645.79319-2-stefanb@linux.vnet.ibm.com>

On Tue, Jan 25, 2022 at 05:46:23PM -0500, Stefan Berger wrote:
> From: Stefan Berger <stefanb@linux.ibm.com>
> 
> The removal of ima_dir currently fails since ima_policy still exists, so
> remove the ima_policy file before removing the directory.
> 
> Fixes: 4af4662fa4a9 ("integrity: IMA policy")
> Signed-off-by: Stefan Berger <stefanb@linux.ibm.com>
> ---

Looks good,
Acked-by: Christian Brauner <brauner@kernel.org>
