Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AAC912C82
	for <containers@lists.linux.dev>; Fri, 19 Nov 2021 17:22:55 +0000 (UTC)
Received: from gandalf.local.home (cpe-66-24-58-225.stny.res.rr.com [66.24.58.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id AE66561A89;
	Fri, 19 Nov 2021 17:22:53 +0000 (UTC)
Date: Fri, 19 Nov 2021 12:22:52 -0500
From: Steven Rostedt <rostedt@goodmis.org>
To: Yordan Karadzhov <y.karadz@gmail.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>,
 linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 viro@zeniv.linux.org.uk, mingo@redhat.com, hagen@jauu.net, rppt@kernel.org,
 akpm@linux-foundation.org, vvs@virtuozzo.com, shakeelb@google.com,
 christian.brauner@ubuntu.com, mkoutny@suse.com, Linux Containers
 <containers@lists.linux.dev>, "Eric W. Biederman" <ebiederm@xmission.com>
Subject: Re: [RFC PATCH 0/4] namespacefs: Proof-of-Concept
Message-ID: <20211119122252.2eca350a@gandalf.local.home>
In-Reply-To: <de336e53-68e1-1d4b-7f71-e276b5363b7c@gmail.com>
References: <20211118181210.281359-1-y.karadz@gmail.com>
	<87a6i1xpis.fsf@email.froward.int.ebiederm.org>
	<20211118142440.31da20b3@gandalf.local.home>
	<1349346e1d5daca991724603d1495ec311cac058.camel@HansenPartnership.com>
	<20211119092758.1012073e@gandalf.local.home>
	<47bf8da26b5ec71f98b9bc736dbca2d8277417f2.camel@HansenPartnership.com>
	<de336e53-68e1-1d4b-7f71-e276b5363b7c@gmail.com>
X-Mailer: Claws Mail 3.17.8 (GTK+ 2.24.33; x86_64-pc-linux-gnu)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Fri, 19 Nov 2021 19:14:08 +0200
Yordan Karadzhov <y.karadz@gmail.com> wrote:

>  And you need to add just few more lines of code 
> in order to make it start tracing a selected container.

I would like to add that this is not just about tracing a single container,
but could be tracing several containers and seeing how they interact, and
analyze the contention between them on shared resources. Just to name an
example of what could be done.

-- Steve
