Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0EEDC7E2
	for <containers@lists.linux.dev>; Sun, 10 Sep 2023 18:51:54 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C4B2AC433C7;
	Sun, 10 Sep 2023 18:51:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=linux-foundation.org;
	s=korg; t=1694371914;
	bh=lcQ/eq3qsg85fYqfhd3RYpbKKifuQDWF4UJUdssqBkQ=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=WuRCTfCsGfHj9tjIyAuYAWx8LXQlEvwtypaza+PadvEV1upOw063a3sn+jG2vSelP
	 jayGKfGs/tfeOj0bcNQZlaJI7TpRHRHOoZvcwR7rWrYVy5wTxFzoUmsogPwofWMdLs
	 NzyJjLcoY1Aaoc90vVXEoPNsIRMH4iIQgTWeDvU0=
Date: Sun, 10 Sep 2023 11:51:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: dwalsh@redhat.com
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Manfred Spraul
 <manfred@colorfullife.com>, Alexey Gladkov <legion@kernel.org>, LKML
 <linux-kernel@vger.kernel.org>, Linux Containers
 <containers@lists.linux.dev>, Alexander Mikhalitsyn
 <alexander.mikhalitsyn@virtuozzo.com>, Christian Brauner
 <christian.brauner@ubuntu.com>, Davidlohr Bueso <dbueso@suse.de>, Kirill
 Tkhai <ktkhai@virtuozzo.com>, Serge Hallyn <serge@hallyn.com>, Varad Gautam
 <varad.gautam@suse.com>, Vasily Averin <vvs@virtuozzo.com>, kernel test
 robot <lkp@intel.com>
Subject: Re: [PATCH v2] ipc: Store mqueue sysctls in the ipc namespace
Message-Id: <20230910115152.96d3d67d76bab9ec84725b33@linux-foundation.org>
In-Reply-To: <30bb6fe4-55eb-c878-bb14-2a23b37b6c27@redhat.com>
References: <0f0408bb7fbf3187966a9bf19a98642a5d9669fe.1641225760.git.legion@kernel.org>
	<792dcae82bc228cd0bec1fa80ed4d2c9340b0f8f.1641296947.git.legion@kernel.org>
	<c8edba64-9b4b-1ef8-f0b3-1b4beacf1551@colorfullife.com>
	<87v8yzfilp.fsf@email.froward.int.ebiederm.org>
	<40ca86a1-ea36-0185-1ba5-c69005e46d3f@colorfullife.com>
	<87zgob87si.fsf@email.froward.int.ebiederm.org>
	<30bb6fe4-55eb-c878-bb14-2a23b37b6c27@redhat.com>
X-Mailer: Sylpheed 3.8.0beta1 (GTK+ 2.24.33; x86_64-pc-linux-gnu)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Fri, 8 Sep 2023 11:47:21 -0400 Daniel Walsh <dwalsh@redhat.com> wrote:

> On 1/4/22 17:17, Eric W. Biederman wrote:
> > parametres. This poses a problem in the rootless containers.
> 
> Did this ever go into the Linux kernel?

yup.

commit dc55e35f9e810f23dd69cfdc91a3d636023f57a2
Author: Alexey Gladkov <legion@kernel.org>
Date:   Mon Feb 14 19:18:14 2022 +0100

    ipc: Store mqueue sysctls in the ipc namespace


with a couple of later fixups, c579d60f0d0cd87552f64fdebe68b5d941d20309
and 12b677f2c697d61e5ddbcb6c1650050a39392f54
