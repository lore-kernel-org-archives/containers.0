Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 20FBE29CA
	for <containers@lists.linux.dev>; Wed, 26 Jan 2022 14:04:07 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DDFCFC340E3;
	Wed, 26 Jan 2022 14:04:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1643205846;
	bh=bGvEUJRI1bG7wfCOhDeIKF9pmrHbf4x38nwGcg1z7Ts=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=N2e27McvDhfrxhkO6oQTzyBprEZzQtNwKgJ8KuXiocCe2noWnmZOcGE4C+HV0o39v
	 1ec1O1E8xY/dOT83KAzkdrAvaG9A2c9hvqoDTkZWSmk8wCBnDcNhAaiVUEsgEvpphq
	 X0PzyM9BP531maaoLFXt1NE7i7J4HVw20AQrF/6Y1I7nU36rBzVhc87/4EfOqWWK9A
	 mJ+BFcLC+D2f9NeoSKcdgadYTu/HS+hU6bJ6POFpidaEiEC2NAUo7kOdsSB2fLqpxs
	 g4SmswDFkXpxTEJloNmFfURRu2gZz7PeyTau+Wfue/97v5vef0dphuzaV+X52wqVmM
	 Gjr5dy73SPYJw==
Date: Wed, 26 Jan 2022 15:03:54 +0100
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
	Stefan Berger <stefanb@linux.ibm.com>,
	James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: [PATCH v9 20/23] ima: Setup securityfs for IMA namespace
Message-ID: <20220126140354.rhsr66kr3fpbff6t@wittgenstein>
References: <20220125224645.79319-1-stefanb@linux.vnet.ibm.com>
 <20220125224645.79319-21-stefanb@linux.vnet.ibm.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20220125224645.79319-21-stefanb@linux.vnet.ibm.com>

On Tue, Jan 25, 2022 at 05:46:42PM -0500, Stefan Berger wrote:
> From: Stefan Berger <stefanb@linux.ibm.com>
> 
> Setup securityfs with symlinks, directories, and files for IMA
> namespacing support. The same directory structure that IMA uses on the
> host is also created for the namespacing case.
> 
> The securityfs file and directory ownerships cannot be set when the
> IMA namespace is initialized. Therefore, delay the setup of the file
> system to a later point when securityfs is in securityfs_fill_super.
> 
> Introduce a variable ima_policy_removed in ima_namespace that is used to
> remember whether the policy file has previously been removed and thus
> should not be created again in case of unmounting and again mounting
> securityfs inside an IMA namespace.
> 
> This filesystem can now be mounted as follows:
> 
> mount -t securityfs /sys/kernel/security/ /sys/kernel/security/
> 
> The following directories, symlinks, and files are available
> when IMA namespacing is enabled, otherwise it will be empty:
> 
> $ ls -l sys/kernel/security/
> total 0
> lr--r--r--. 1 root root 0 Dec  2 00:18 ima -> integrity/ima
> drwxr-xr-x. 3 root root 0 Dec  2 00:18 integrity
> 
> $ ls -l sys/kernel/security/ima/
> total 0
> -r--r-----. 1 root root 0 Dec  2 00:18 ascii_runtime_measurements
> -r--r-----. 1 root root 0 Dec  2 00:18 binary_runtime_measurements
> -rw-------. 1 root root 0 Dec  2 00:18 policy
> -r--r-----. 1 root root 0 Dec  2 00:18 runtime_measurements_count
> -r--r-----. 1 root root 0 Dec  2 00:18 violations
> 
> Signed-off-by: Stefan Berger <stefanb@linux.ibm.com>
> Signed-off-by: James Bottomley <James.Bottomley@HansenPartnership.com>
> 
> ---

Acked-by: Christian Brauner <brauner@kernel.org>
