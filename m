Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B8C22168
	for <containers@lists.linux.dev>; Wed, 26 Jan 2022 09:11:12 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D4186C340E3;
	Wed, 26 Jan 2022 09:11:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1643188272;
	bh=81J6WPzY+ci50rtR2WWy0x8FAKIC8UJUQHIK59zO96I=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=McAkAp5dZD7GpxrB2gHhx7l+taB5JCn8xsMZY5FJp3JIY3Vv1nqeAjaZn5HJMlbkW
	 tNbttNjiPfRD0fA0yDHJVGwjq3Cy7M+4DNTqL5EgbvOIo9iBerzAbvgjAwX5Gf+R0X
	 b+GqTvhVUM8j2N0nIPZt9S6oIAuq2BujY+p9wJGbyjdxhCBxng14pAsQk9P/wA2uGv
	 Ns3AWK1vdEfh3MalW6AGWael9UeWyu58w0YGInd50x/Uipb8k7Z+UytQd4xS94TjIW
	 myM1bGpxvsZgDKlsyn6IBZTOa5jAvNtIEveWUR7fOIlkUUWbUpFORHWD4tdF17nDbR
	 pUBBh3uXHj/Lw==
Date: Wed, 26 Jan 2022 10:11:04 +0100
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
Subject: Re: [PATCH v9 06/23] ima: Move arch_policy_entry into ima_namespace
Message-ID: <20220126091104.jbedxrewojcmvy3u@wittgenstein>
References: <20220125224645.79319-1-stefanb@linux.vnet.ibm.com>
 <20220125224645.79319-7-stefanb@linux.vnet.ibm.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20220125224645.79319-7-stefanb@linux.vnet.ibm.com>

On Tue, Jan 25, 2022 at 05:46:28PM -0500, Stefan Berger wrote:
> From: Stefan Berger <stefanb@linux.ibm.com>
> 
> Move the arch_policy_entry pointer into ima_namespace.
> 
> When freeing the memory set the pointer to NULL.
> 
> Signed-off-by: Stefan Berger <stefanb@linux.ibm.com>
> ---

Only relevant for the initial imans (for now) since it is derived from a
boot parameter. Maybe mention this in the commit message.

Move into struct ima_namespace looks good,
Acked-by: Christian Brauner <brauner@kernel.org>
