Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CDBB12CA7
	for <containers@lists.linux.dev>; Wed, 26 Jan 2022 09:23:49 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BBD23C340E8;
	Wed, 26 Jan 2022 09:23:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1643189029;
	bh=6MkghyPmUVPTPxiV+YdGoUohtGDmOMD9FKIffcmSi+Y=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=W0HJZE84AtCqu3ULhDVAPYQenc2VHLv5xm7Lo0Je2FwUoIM/RmAKpZQViigMyBz5T
	 UPZfYCDbU1atRqNsXRT02+TClxrSQwsR20oQTvY0m718RMMiYLOXu59YKbjiFwOy7O
	 zJUL28f7oYVrePUPqa8jwfQNwErqYmfYrr7ZALYTUL7Y+pIz2MudBKwWTNcC3u6Qf0
	 DgTggdS2RIKqees6FLljxMmU5hxsTaoKCPrr6DAmJWPcjmY3h9uF4O4CpEP9UzHrAZ
	 jas8bn2xxh0UC9ozEERUZ2JB5Dd+tnspS5LkyBDzMecPduAlQ8UGMiEj6tjeJieIdR
	 zpoMp3CddpG2w==
Date: Wed, 26 Jan 2022 10:23:41 +0100
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
Subject: Re: [PATCH v9 09/23] ima: Move some IMA policy and filesystem
 related variables into ima_namespace
Message-ID: <20220126092341.yxxqb2avwco3ezqd@wittgenstein>
References: <20220125224645.79319-1-stefanb@linux.vnet.ibm.com>
 <20220125224645.79319-10-stefanb@linux.vnet.ibm.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20220125224645.79319-10-stefanb@linux.vnet.ibm.com>

On Tue, Jan 25, 2022 at 05:46:31PM -0500, Stefan Berger wrote:
> From: Stefan Berger <stefanb@linux.ibm.com>
> 
> Move the ima_write_mutex, ima_fs_flag, and valid_policy variables into
> ima_namespace. This way each IMA namespace can set those variables
> independently.
> 
> Signed-off-by: Stefan Berger <stefanb@linux.ibm.com>
> ---

Moving into imans looks good,
Acked-by: Christian Brauner <brauner@kernel.org>
