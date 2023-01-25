Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E63CA33EC
	for <containers@lists.linux.dev>; Wed, 25 Jan 2023 23:36:50 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 53138C433D2;
	Wed, 25 Jan 2023 23:36:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=linux-foundation.org;
	s=korg; t=1674689810;
	bh=qdW7GJEApmAZ3dv73jbkJCPfiH6FFqfAWFb67eqZLg0=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=spPzlcbA9nU2SSJfH0Wm7RoFovVPbqPlr9EUTDq3WpjqP6+Eamp0HEa9LLMqEWf1b
	 z0f6+posc3c5OJtlmxx09xMdn+jHMGKvWj1igwOChNLLhmxU81f+BybI59+3kkUPYJ
	 +XTFDhw1y6rXW2fzFJps+BxJ2DHqVeAnSPeDmoKc=
Date: Wed, 25 Jan 2023 15:36:49 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Alexey Gladkov <legion@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, containers@lists.linux.dev,
 linux-fsdevel@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>, Al
 Viro <viro@zeniv.linux.org.uk>, Christian Brauner <brauner@kernel.org>, Val
 Cowan <vcowan@redhat.com>
Subject: Re: [RFC PATCH v1 2/6] proc: Add allowlist to control access to
 procfs files
Message-Id: <20230125153649.a8524c34b89d6cdbb06bd5a2@linux-foundation.org>
In-Reply-To: <d87edbe023efb28f60ea04a2e694330db44aa868.1674660533.git.legion@kernel.org>
References: <cover.1674660533.git.legion@kernel.org>
	<d87edbe023efb28f60ea04a2e694330db44aa868.1674660533.git.legion@kernel.org>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.33; x86_64-pc-linux-gnu)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Wed, 25 Jan 2023 16:28:49 +0100 Alexey Gladkov <legion@kernel.org> wrote:

> +config PROC_ALLOW_LIST
> +	bool "/proc/allowlist support"
> +	depends on PROC_FS
> +	default n
> +	help
> +	  Provides a way to restrict access to certain files in procfs. Mounting

I'd say "to restrict presence of files in procfs".

> +	  procfs with subset=allowlist will add the file /proc/allowlist which
> +	  contains a list of files and directories that should be accessed. To

s/accessed/present/

> +	  prevent the list from being changed, the file itself must be excluded.


