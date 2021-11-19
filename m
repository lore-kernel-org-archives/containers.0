Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 945E572
	for <containers@lists.linux.dev>; Fri, 19 Nov 2021 14:28:01 +0000 (UTC)
Received: from gandalf.local.home (cpe-66-24-58-225.stny.res.rr.com [66.24.58.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D076261549;
	Fri, 19 Nov 2021 14:27:59 +0000 (UTC)
Date: Fri, 19 Nov 2021 09:27:58 -0500
From: Steven Rostedt <rostedt@goodmis.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: "Eric W. Biederman\"  <ebiederm@xmission.com>, "Yordan Karadzhov
 (VMware)" <y.karadz@gmail.com>, linux-kernel@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, mingo@redhat.com,
 hagen@jauu.net, rppt@kernel.org, akpm@linux-foundation.org,
 vvs@virtuozzo.com, shakeelb@google.com, christian.brauner@ubuntu.com,
 mkoutny@suse.com, Linux Containers <containers@lists.linux.dev>
Subject: Re: [RFC PATCH 0/4] namespacefs: Proof-of-Concept
Message-ID: <20211119092758.1012073e@gandalf.local.home>
In-Reply-To: <1349346e1d5daca991724603d1495ec311cac058.camel@HansenPartnership.com>
References: <20211118181210.281359-1-y.karadz@gmail.com>
	<87a6i1xpis.fsf@email.froward.int.ebiederm.org>
	<20211118142440.31da20b3@gandalf.local.home>
	<1349346e1d5daca991724603d1495ec311cac058.camel@HansenPartnership.com>
X-Mailer: Claws Mail 3.17.8 (GTK+ 2.24.33; x86_64-pc-linux-gnu)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Fri, 19 Nov 2021 07:45:01 -0500
James Bottomley <James.Bottomley@HansenPartnership.com> wrote:

> On Thu, 2021-11-18 at 14:24 -0500, Steven Rostedt wrote:
> > On Thu, 18 Nov 2021 12:55:07 -0600
> > ebiederm@xmission.com (Eric W. Biederman) wrote:
> >   
> > > It is not correct to use inode numbers as the actual names for
> > > namespaces.
> > > 
> > > I can not see anything else you can possibly uses as names for
> > > namespaces.  
> > 
> > This is why we used inode numbers.
> >   
> > > To allow container migration between machines and similar things
> > > the you wind up needing a namespace for your names of namespaces.  
> > 
> > Is this why you say inode numbers are incorrect?  
> 
> The problem is you seem to have picked on one orchestration system
> without considering all the uses of namespaces and how this would
> impact them.  So let me explain why inode numbers are incorrect and it
> will possibly illuminate some of the cans of worms you're opening.
> 
> We have a container checkpoint/restore system called CRIU that can be
> used to snapshot the state of a pid subtree and restore it.  It can be
> used for the entire system or piece of it.  It is also used by some
> orchestration systems to live migrate containers.  Any property of a
> container system that has meaning must be saved and restored by CRIU.
> 
> The inode number is simply a semi random number assigned to the
> namespace.  it shows up in /proc/<pid>/ns but nowhere else and isn't
> used by anything.  When CRIU migrates or restores containers, all the
> namespaces that compose them get different inode values on the restore.
> If you want to make the inode number equivalent to the container name,
> they'd have to restore to the previous number because you've made it a
> property of the namespace.  The way everything is set up now, that's
> just not possible and never will be.  Inode numbers are a 32 bit space
> and can't be globally unique.  If you want a container name, it will
> have to be something like a new UUID and that's the first problem you
> should tackle.

So everyone seems to be all upset about using inode number. We could do
what Kirill suggested and just create some random UUID and use that. We
could have a file in the directory called inode that has the inode number
(as that's what both docker and podman use to identify their containers,
and it's nice to have something to map back to them).

On checkpoint restore, only the directories that represent the container
that migrated matter, so as Kirill said, make sure they get the old UUID
name, and expose that as the directory.

If a container is looking at directories of other containers on the system,
then it gets migrated to another system, it should be treated as though
those directories were deleted under them.

I still do not see what the issue is here.

-- Steve


