Received: from vmicros1.altlinux.org (vmicros1.altlinux.org [194.107.17.57])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 5755D70
	for <containers@lists.linux.dev>; Thu,  8 Jul 2021 11:07:32 +0000 (UTC)
Received: from imap.altlinux.org (imap.altlinux.org [194.107.17.38])
	by vmicros1.altlinux.org (Postfix) with ESMTP id 232EC72C8B4;
	Thu,  8 Jul 2021 14:00:18 +0300 (MSK)
Received: from example.org (ip-89-103-72-154.net.upcbroadband.cz [89.103.72.154])
	by imap.altlinux.org (Postfix) with ESMTPSA id 91AAA4A46ED;
	Thu,  8 Jul 2021 14:00:17 +0300 (MSK)
Date: Thu, 8 Jul 2021 13:00:16 +0200
From: Alexey Gladkov <gladkov.alexey@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Containers <containers@lists.linux.dev>
Subject: Re: [PATCH] ucounts: Fix UCOUNT_RLIMIT_SIGPENDING counter leak
Message-ID: <20210708110016.seeviageyspgctzk@example.org>
References: <CAHk-=wjQks3o_3=WewaXw++h+a318B3LTLSFER9Ee4n1pLCZLw@mail.gmail.com>
 <20210702175442.1603082-1-legion@kernel.org>
 <CAHk-=whfoVN6wiP5VHekckvqivRhpB+b1FnwyWEjz1SB2FN6HQ@mail.gmail.com>
 <20210707165008.tym4352uw3hu7uwp@example.org>
 <CAHk-=wirhF8G1XniAfxzJXCYUnuAx23Q1WLi_n4+HGsUXv72KQ@mail.gmail.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wirhF8G1XniAfxzJXCYUnuAx23Q1WLi_n4+HGsUXv72KQ@mail.gmail.com>

On Wed, Jul 07, 2021 at 10:23:35AM -0700, Linus Torvalds wrote:
> On Wed, Jul 7, 2021 at 9:50 AM Alexey Gladkov <legion@kernel.org> wrote:
> >
> > >   +             dec_rlimit_ucounts(ucounts, UCOUNT_RLIMIT_SIGPENDING, 1);
> > >   +             fallthrough;
> > >   +     case LONG_MAX:
> >
> > I think that the counter should be decreased in this case too.
> > inc_rlimit_ucounts() increments the counter in all parent userns. If we
> > don't decrease the counter then the parent userns will have a counter
> > leak.
> 
> Ack. So basically that patch, but move the dec_rlimit_ucounts() into
> the LONG_MAX case?

Yep.

> Would you mind making a real patch with a commit message, and trying
> whatever test-case you had for that KASAN use-after-free report?

Sure. I will.

-- 
Rgrds, legion

