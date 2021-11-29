Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3940968
	for <containers@lists.linux.dev>; Mon, 29 Nov 2021 13:56:46 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5F067C004E1;
	Mon, 29 Nov 2021 13:56:42 +0000 (UTC)
Date: Mon, 29 Nov 2021 14:56:39 +0100
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Stefan Berger <stefanb@linux.ibm.com>
Cc: "Serge E. Hallyn" <serge@hallyn.com>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	linux-integrity@vger.kernel.org, containers@lists.linux.dev,
	Mimi Zohar <zohar@linux.ibm.com>,
	Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	krzysztof.struczynski@huawei.com,
	Roberto Sassu <roberto.sassu@huawei.com>,
	Michael Peters <mpeters@redhat.com>, Luke Hinds <lhinds@redhat.com>,
	Lily Sturmann <lsturman@redhat.com>,
	Patrick Uiterwijk <puiterwi@redhat.com>,
	Christian Brauner <christian@brauner.io>
Subject: Re: [RFC 1/3] userns: add uuid field
Message-ID: <20211129135639.3boeegnusxllho35@wittgenstein>
References: <20211128044558.GA11794@mail.hallyn.com>
 <2e32a6897877ed600de64b3d664dc6014389dbe4.camel@HansenPartnership.com>
 <20211128151805.GA15306@mail.hallyn.com>
 <60c99d461368593dfd51765c527b01c6bf0a9fea.camel@HansenPartnership.com>
 <20211128204715.GA17707@mail.hallyn.com>
 <e1b36c9c36f0f6d3262de6141ad67e8044cfeade.camel@HansenPartnership.com>
 <20211128214906.GA18470@mail.hallyn.com>
 <e1d8fcb0dffd5d88c95140f644ece25273071d79.camel@HansenPartnership.com>
 <20211129015901.GA20161@mail.hallyn.com>
 <9f3466c1-276b-1d7e-917c-37c6f02d5571@linux.ibm.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <9f3466c1-276b-1d7e-917c-37c6f02d5571@linux.ibm.com>

On Mon, Nov 29, 2021 at 08:49:40AM -0500, Stefan Berger wrote:
> 
> On 11/28/21 20:59, Serge E. Hallyn wrote:
> > On Sun, Nov 28, 2021 at 05:56:28PM -0500, James Bottomley wrote:
> > > On Sun, 2021-11-28 at 15:49 -0600, Serge E. Hallyn wrote:
> > > > On Sun, Nov 28, 2021 at 04:21:29PM -0500, James Bottomley wrote:
> > > > > On Sun, 2021-11-28 at 14:47 -0600, Serge E. Hallyn wrote:
> > > > > > On Sun, Nov 28, 2021 at 01:00:28PM -0500, James Bottomley wrote:
> > > > > > > On Sun, 2021-11-28 at 09:18 -0600, Serge E. Hallyn wrote:
> > > [...]
> > > > > > > > So given that 'unique per boot' is sufficient, what would be
> > > > > > > > the problem with simply adding a simple ever-increasing
> > > > > > > > unique atomix count to the struct user_namespace?
> > > > > > > I don't think there is any ... but I equally don't see why
> > > > > > > people would want to save and restore the uuid but not the new
> > > > > > > monotonic identifier ... because it's still just a marker on a
> > > > > > > namespace.
> > > > > > But you've called it "the namespace uuid".  I'm not even really
> > > > > > thinking of checkpoint/restart, just stopping and restarting a
> > > > > > container.  I'm convinced people will want to start using it
> > > > > > because, well, it is a nice feature.
> > > > > Right, but the uniqueness property depends on you not being able to
> > > > > set it.  If you just want a namespace label, you can have that, but
> > > > > anything a user can set is either a pain to guarantee uniqueness
> > > > > (have to check all the other objects) or is simply a non-unique
> > > > > label.
> > > > > 
> > > > > If you want to label a container, which could have many namespaces
> > > > > and be stopped and restarted many times, it does sound like you
> > > > > want a non-unique settable label.  However, IMA definitely needs a
> > > > > guaranteed per namespace unique label.
> > > > > 
> > > > > Is the objection simply you think a UUID sound like it should be
> > > > Objection is too strong.  Concern.
> > > > 
> > > > But yes, to me a uuid (a) feels like it should be generally useful
> > > > including being settable and (b) not super duper 100% absolutely
> > > > guaranteed to always be unique per boot, as an incremented counter
> > > > would be.
> > > OK, but a bunch of cats I found on the Internet agree with me, a UUID
> > > shouldn't be settable:
> > > 
> > > https://en.wikipedia.org/wiki/Universally_unique_identifier
> > > 
> > > The key point being, if you can set the id, it can't be unique ... it
> > Ok, so can you just put a comment above there saying "this must not
> > be settable from userspace" ?
> 
> So I have been working on an IMA namespacing series again as well and would
> like to use some sort of unique identifier for audit messages emitted from
> an IMA/user namespace other than the init_ima_ns. This UUID may just work
> for this, but how would one associate the UUID with a container if it ever
> comes to that when evaluating audit logs? Shouldn't it be settable from user
> space for some sort of 'coordination' between container runtime and kernel?

Wouldn't this be solved by the audit container id patchset? In fact,
can't we use this for IMA as well?
